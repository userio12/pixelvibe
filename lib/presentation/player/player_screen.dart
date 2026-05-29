import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import '../../core/di/platform_providers.dart';
import '../../core/di/providers.dart';
import '../../services/background_service.dart';
import '../../services/logger.dart';
import '../../services/network_service.dart';
import '../../utils/platform_helper.dart';
import '../settings/settings_provider.dart';
import 'player_provider.dart';
import 'player_screen_provider.dart';
import 'playlist_queue_provider.dart';
import 'sleep_timer_provider.dart';
import 'ab_loop_provider.dart';
import 'widgets/player_video_area.dart';
import 'widgets/player_error_overlay.dart';
import 'widgets/player_top_bar.dart';
import 'widgets/player_bottom_bar.dart';
import 'widgets/gesture_handler.dart';
import 'widgets/resume_dialog.dart';
import 'player_overlay.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String filePath;
  const PlayerScreen({super.key, required this.filePath});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  StreamSubscription? _pipToggleSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _noisySub;
  StreamSubscription? _audioFocusSub;
  StreamSubscription? _tracksSub;
  StreamSubscription? _errorSub;
  bool _wasPlayingBeforePip = false;
  bool _watchedNotified = false;
  Timer? _saveTimer;
  late final BackgroundService _backgroundService;

  @override
  void initState() {
    super.initState();
    _backgroundService = ref.read(backgroundServiceProvider);
    _setupErrorListener();
    _startSaveTimer();
    _setupPipCallback();
    _setupAutoplay();
    _recordRecentlyPlayed();
    _checkResume();
    _setupNoisyReceiver();
    ref.read(playerOrientationProvider).apply();
    _setupAudioFocus();
    _setupBackgroundHandler();
    
    // Initial hide timer and media opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(playerScreenProvider.notifier).startHideTimer();
      _openMedia();
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _pipToggleSub?.cancel();
    _playingSub?.cancel();
    _noisySub?.cancel();
    _audioFocusSub?.cancel();
    _tracksSub?.cancel();
    _errorSub?.cancel();
    
    _backgroundService.stopService();
    if (widget.filePath.startsWith('http://127.0.0.1:')) {
      NetworkService().stopProxy();
    }
    
    super.dispose();
  }

  void _setupErrorListener() {
    final player = ref.read(playerProvider);
    _errorSub = player.stream.error.listen((error) {
      if (!mounted) return;
      ref.read(playerScreenProvider.notifier).setErrorMessage(error);
      Logger.error('Player error stream', error);
    });
  }

  void _openMedia() {
    ref.read(playerScreenProvider.notifier).setErrorMessage(null);
    try {
      final player = ref.read(playerProvider);
      final raw = ref.read(preferencesServiceProvider).getHttpHeaders();
      Map<String, String>? headers;
      if (raw.isNotEmpty) {
        try {
          headers = Map.fromEntries(raw.split('\n').where((l) => l.contains(':')).map((l) {
            final parts = l.split(':');
            return MapEntry(parts[0].trim(), parts.sublist(1).join(':').trim());
          }));
        } catch (_) {}
      }
      player.open(Media(widget.filePath, httpHeaders: headers), play: true);
      
      final speed = ref.read(defaultSpeedProvider);
      if (speed != 1.0) player.setRate(speed);

      _autoloadSubtitle(player);
      _setupSmartSubtitle(player);
    } catch (e) {
      Logger.error('Failed to open media', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open file: $e')));
      }
    }
  }

  void _autoloadSubtitle(Player player) {
    if (!widget.filePath.startsWith('http') && !widget.filePath.startsWith('smb://')) return;
    final base = widget.filePath.substring(0, widget.filePath.lastIndexOf('.'));
    for (final ext in ['.srt', '.ass', '.ssa', '.vtt', '.sub']) {
      try {
        player.setSubtitleTrack(SubtitleTrack.uri('$base$ext'));
        break;
      } catch (_) {}
    }
  }

  void _setupSmartSubtitle(Player player) {
    if (!ref.read(smartSubtitleAutoSelectProvider)) return;
    _tracksSub?.cancel();
    _tracksSub = player.stream.tracks.listen((tracks) {
      if (!mounted || tracks.audio.isEmpty) return;
      
      final audioPrefs = ref.read(preferredAudioLanguagesProvider);
      final subPrefs = ref.read(preferredSubtitleLanguagesProvider);
      
      final audioLang = (tracks.audio.firstOrNull?.language ?? '').toLowerCase();
      final matchesAudio = audioPrefs.any((p) => audioLang.startsWith(p));
      
      if (matchesAudio) {
        final platform = player.platform;
        if (platform is NativePlayer) {
          for (final sub in tracks.subtitle) {
            final subLang = (sub.language ?? '').toLowerCase();
            if (subPrefs.any((p) => subLang.startsWith(p))) {
              platform.setProperty('sid', sub.id.toString());
              break;
            }
          }
        }
      }
      _tracksSub?.cancel();
    });
  }

  void _startSaveTimer() {
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final player = ref.read(playerProvider);
      if (player.state.position.inMilliseconds > 0) {
        await ref.read(playbackStateDaoProvider).upsertPosition(
          widget.filePath,
          player.state.position.inMilliseconds,
          player.state.duration.inMilliseconds,
        );
      }
    });
  }

  Future<void> _recordRecentlyPlayed() async {
    try {
      final queueTitle = ref.read(playlistQueueProvider).currentTitle;
      await ref.read(recentlyPlayedDaoProvider).record(
        widget.filePath,
        queueTitle.isNotEmpty ? queueTitle : widget.filePath.split('/').last.split('.').first,
        null,
      );
      await ref.read(videoMetadataDaoProvider).incrementPlayCount(widget.filePath);
    } catch (_) {}
  }

  void _setupAutoplay() {
    final player = ref.read(playerProvider);
    _playingSub = player.stream.playing.listen((playing) {
      if (!mounted) return;
      if (!playing) {
        final pos = player.state.position.inMilliseconds;
        final dur = player.state.duration.inMilliseconds;
        if (dur > 0 && pos >= dur - 500) _handleEndOfVideo();
      } else {
        _checkAbLoop(player);
        _checkWatchedThreshold(player);
        _updateBackgroundService();
      }
    });
  }

  void _handleEndOfVideo() {
    if (ref.read(preferencesServiceProvider).getCloseAfterEnd() && mounted) {
      context.pop();
      return;
    }
    if (ref.read(sleepTimerProvider).state == SleepTimerState.endOfFile) {
      ref.read(sleepTimerProvider.notifier).cancel();
      return;
    }
    final path = ref.read(playlistQueueProvider.notifier).next(ref.read(repeatModeProvider), ref.read(autoplayNextProvider));
    if (path != null && path.isNotEmpty) {
      ref.read(playerProvider).open(Media(path), play: true);
    }
  }

  void _checkAbLoop(Player player) {
    final ab = ref.read(abLoopProvider);
    if (ab.isActive && ab.bPointMs != null && player.state.position.inMilliseconds >= ab.bPointMs!) {
      player.seek(Duration(milliseconds: ab.aPointMs!));
    }
  }

  void _checkWatchedThreshold(Player player) {
    if (_watchedNotified) return;
    final threshold = ref.read(preferencesServiceProvider).getWatchedThreshold();
    final pos = player.state.position.inMilliseconds;
    final dur = player.state.duration.inMilliseconds;
    if (dur > 0 && (pos * 100 ~/ dur) >= threshold) {
      _watchedNotified = true;
      ref.read(videoMetadataDaoProvider).markAsWatched(widget.filePath);
    }
  }

  void _updateBackgroundService() {
    final player = ref.read(playerProvider);
    ref.read(backgroundServiceProvider).updateMetadata(
      title: widget.filePath.split('/').last.split('.').first,
      durationMs: player.state.duration.inMilliseconds,
    );
    ref.read(backgroundServiceProvider).updatePlaybackState(
      playing: true,
      positionMs: player.state.position.inMilliseconds,
    );
  }

  void _setupNoisyReceiver() {
    _noisySub = ref.read(pipServiceProvider).onNoisy.listen((_) {
      if (mounted) ref.read(playerProvider).pause();
    });
  }

  void _setupAudioFocus() {
    ref.read(pipServiceProvider).requestAudioFocus();
    _audioFocusSub = ref.read(pipServiceProvider).onAudioFocusChange.listen((focus) {
      if (mounted && focus < 0) ref.read(playerProvider).pause();
    });
  }

  void _setupBackgroundHandler() {
    ref.read(backgroundServiceProvider).onEvent = (method, args) {
      if (!mounted) return;
      final player = ref.read(playerProvider);
      switch (method) {
        case 'onPlay': player.play(); break;
        case 'onPause': player.pause(); break;
        case 'onStop': player.pause(); ref.read(backgroundServiceProvider).stopService(); break;
        case 'onSeekTo':
          final pos = (args as Map)['position'] as int?;
          if (pos != null) player.seek(Duration(milliseconds: pos));
          break;
      }
    };
  }

  void _setupPipCallback() {
    ref.read(pipServiceProvider).onPipModeChanged((isInPip) {
      if (!mounted) return;
      if (isInPip) {
        _wasPlayingBeforePip = ref.read(playerIsPlayingProvider).value ?? false;
      } else if (_wasPlayingBeforePip) {
        ref.read(playerProvider).play();
      }
    });
    _pipToggleSub = ref.read(pipServiceProvider).onTogglePlayback.listen((_) {
      if (!mounted) return;
      final p = ref.read(playerProvider);
      if (p.state.playing) {
        p.pause();
      } else {
        p.play();
      }
    });
  }

  Future<void> _checkResume() async {
    if (!ref.read(resumePlaybackProvider)) return;
    final state = await ref.read(playbackStateDaoProvider).findByPath(widget.filePath);
    if (state != null && state.positionMs > 0 && mounted) {
      final resume = await showDialog<bool>(
        context: context,
        builder: (_) => ResumeDialog(filePath: widget.filePath, title: widget.filePath.split('/').last, positionMs: state.positionMs),
      );
      if (resume == true && mounted) {
        ref.read(playerProvider).seek(Duration(milliseconds: state.positionMs));
      }
    }
  }

  void _skip(int seconds) {
    HapticFeedback.mediumImpact();
    final player = ref.read(playerProvider);
    final pos = player.state.position.inMilliseconds;
    final dur = player.state.duration.inMilliseconds;
    final newMs = (pos + seconds * 1000).clamp(0, dur);
    player.seek(Duration(milliseconds: newMs));
    ref.read(playerScreenProvider.notifier).showSeekBarTemporarily();
  }

  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(playerScreenProvider);
    final locked = screenState.locked;
    final isPlaying = ref.watch(playerIsPlayingProvider).asData?.value ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CallbackShortcuts(
        bindings: {
          SingleActivator(LogicalKeyboardKey.mediaPlayPause): () => isPlaying ? ref.read(playerProvider).pause() : ref.read(playerProvider).play(),
          SingleActivator(LogicalKeyboardKey.space): () => isPlaying ? ref.read(playerProvider).pause() : ref.read(playerProvider).play(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): () => _skip(-ref.read(skipIntervalProvider)),
          SingleActivator(LogicalKeyboardKey.arrowRight): () => _skip(ref.read(skipIntervalProvider)),
        },
        child: GestureHandler(
          onTap: () => ref.read(playerScreenProvider.notifier).toggleControls(),
          onSkip: _skip,
          locked: locked,
          child: Stack(
            children: [
              Positioned.fill(child: PlayerVideoArea(filePath: widget.filePath)),
              PlayerErrorOverlay(onRetry: _openMedia),
              PlayerTopBar(filePath: widget.filePath),
              const PlayerOverlay(),
              if (locked)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                    onPressed: () => ref.read(playerScreenProvider.notifier).toggleLock(),
                  ),
                ),
              const PlayerBottomBar(),
            ],
          ),
        ),
      ),
    );
  }
}
