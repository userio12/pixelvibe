import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../core/di/platform_providers.dart';
import '../../core/di/providers.dart';
import '../../presentation/playlist/widgets/add_to_playlist_sheet.dart';
import '../../services/logger.dart';
import '../../utils/permissions/permission_handler.dart';
import '../../utils/format_utils.dart';
import '../../utils/platform_helper.dart';
import '../settings/settings_provider.dart';
import 'player_provider.dart';
import 'player_overlay.dart';
import 'player_updates.dart';
import 'playlist_queue_provider.dart';
import 'sleep_timer_provider.dart';
import 'widgets/gesture_handler.dart';
import 'widgets/media_info_sheet.dart';
import 'widgets/player_controls_bar.dart';
import 'widgets/player_video_area.dart';
import 'widgets/resume_dialog.dart';
import 'widgets/sleep_timer_sheet.dart';
import 'widgets/player_more_sheet.dart';
import 'widgets/volume_slider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String filePath;

  const PlayerScreen({super.key, required this.filePath});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Timer? _hideTimer;
  Timer? _saveTimer;
  StreamSubscription? _pipToggleSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _noisySub;
  bool _controlsVisible = true;
  bool _seekBarVisible = true;
  bool _wasPlayingBeforePip = false;
  bool _playerLocked = false;

  @override
  void initState() {
    super.initState();
    _openMedia();
    _startHideTimer();
    _startSaveTimer();
    _setupPipCallback();
    _setupAutoplay();
    _recordRecentlyPlayed();
    _checkResume();
    _setupNoisyReceiver();
    ref.read(playerOrientationProvider).apply();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _saveTimer?.cancel();
    _pipToggleSub?.cancel();
    _playingSub?.cancel();
    _noisySub?.cancel();
    PlayerOrientation.reset();
    ref.read(backgroundServiceProvider).stopService();
    super.dispose();
  }

  void _openMedia() {
    final player = ref.read(playerProvider);
    player.open(Media(widget.filePath), play: true);
    _applyPlayerConfig(player);
  }

  void _applyPlayerConfig(Player player) {
    final speed = ref.read(defaultSpeedProvider);
    if (speed != 1.0) player.setRate(speed);
  }

  void _startHideTimer({bool isFullToggle = true}) {
    _hideTimer?.cancel();
    if (isFullToggle) {
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _controlsVisible = false;
            _seekBarVisible = false;
          });
        }
      });
    } else {
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _seekBarVisible = false);
        }
      });
    }
  }

  void _startSaveTimer() {
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      try {
        final player = ref.read(playerProvider);
        final pos = player.state.position;
        final dur = player.state.duration;
        if (pos.inMilliseconds > 0) {
          await ref.read(playbackStateDaoProvider).upsetPosition(
            widget.filePath,
            pos.inMilliseconds,
            dur.inMilliseconds,
          );
        }
      } catch (e) {
        Logger.error('Save position error', e);
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
    } catch (e) {
      Logger.error('Record recently played error', e);
    }
  }

  void _toggleControls() {
    if (_playerLocked) return;
    setState(() {
      _controlsVisible = !_controlsVisible;
      _seekBarVisible = _controlsVisible;
      if (_controlsVisible) HapticFeedback.lightImpact();
    });
    PlatformHelper.setSystemBarsVisible(_controlsVisible);
    if (_controlsVisible) _startHideTimer();
  }

  void _toggleLock() {
    setState(() {
      _playerLocked = !_playerLocked;
      if (_playerLocked) {
        _controlsVisible = false;
        _seekBarVisible = false;
        PlatformHelper.setSystemBarsVisible(false);
      } else {
        _controlsVisible = true;
        _seekBarVisible = true;
        PlatformHelper.setSystemBarsVisible(true);
        _startHideTimer();
      }
    });
  }

  void _setupAutoplay() {
    final player = ref.read(playerProvider);
    _playingSub = player.stream.playing.listen((playing) {
      if (!playing && mounted) {
        final pos = player.state.position.inMilliseconds;
        final dur = player.state.duration.inMilliseconds;
        if (dur > 0 && pos >= dur - 500) {
          _playNextInQueue();
        }
      }
    });
  }

  void _playNextInQueue() {
    final sleepTimer = ref.read(sleepTimerProvider);
    if (sleepTimer.state == SleepTimerState.endOfFile) {
      ref.read(sleepTimerProvider.notifier).cancel();
      return;
    }
    final queue = ref.read(playlistQueueProvider);
    if (!queue.hasMultiple) return;
    final repeatMode = ref.read(repeatModeProvider);
    final path = ref.read(playlistQueueProvider.notifier).next(repeatMode, ref.read(autoplayNextProvider));
    if (path != null && path.isNotEmpty) {
      ref.read(playerProvider).open(Media(path), play: true);
      ref.read(playerOverlayProvider.notifier).show(ShowText('Now playing: ${path.split('/').last.split('.').first}'));
    }
  }

  void _setupNoisyReceiver() {
    final pip = ref.read(pipServiceProvider);
    _noisySub = pip.onNoisy.listen((_) {
      if (!mounted) return;
      ref.read(playerProvider).pause();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Headphones disconnected — playback paused')),
        );
      }
    });
  }

  void _setupPipCallback() {
    final pip = ref.read(pipServiceProvider);
    pip.onPipModeChanged((isInPip) {
      if (!mounted) return;
      if (isInPip) {
        _wasPlayingBeforePip = ref.read(playerIsPlayingProvider).asData?.value ?? false;
        if (_wasPlayingBeforePip) {
          _updateBackgroundService();
        }
      } else {
        if (_wasPlayingBeforePip) {
          ref.read(playerProvider).play();
        }
      }
    });
    _pipToggleSub = pip.onTogglePlayback.listen((_) {
      if (!mounted) return;
      final player = ref.read(playerProvider);
      if (ref.read(playerIsPlayingProvider).asData?.value ?? false) {
        player.pause();
      } else {
        player.play();
      }
    });
  }

  void _updateBackgroundService() {
    requestNotificationPermission();
    final pos = ref.read(playerPositionProvider).asData?.value ?? Duration.zero;
    final dur = ref.read(playerDurationProvider).asData?.value ?? Duration.zero;
    final bg = ref.read(backgroundServiceProvider);
    bg.startService();
    bg.updateMetadata(
      title: widget.filePath.split('/').last.split('.').first,
      durationMs: dur.inMilliseconds,
    );
    bg.updatePlaybackState(playing: true, positionMs: pos.inMilliseconds);
  }

  Future<void> _checkResume() async {
    if (!ref.read(resumePlaybackProvider)) return;
    final dao = ref.read(playbackStateDaoProvider);
    try {
      final state = await dao.findByPath(widget.filePath);
      if (state == null || state.positionMs <= 0 || !mounted) return;
      final resume = await showDialog<bool>(
        context: context,
        builder: (_) => ResumeDialog(
          filePath: widget.filePath,
          title: widget.filePath.split('/').last,
          positionMs: state.positionMs,
        ),
      );
      if (resume == true && mounted) {
        final player = ref.read(playerProvider);
        await player.seek(Duration(milliseconds: state.positionMs));
      }
    } catch (e) {
      Logger.error('Resume check error', e);
    }
  }

  Future<void> _enterPip() async {
    if (!ref.read(autoPipProvider)) return;
    final pip = ref.read(pipServiceProvider);
    final supported = await pip.isPipSupported();
    if (supported) {
      final playing = ref.read(playerIsPlayingProvider).asData?.value ?? false;
      _wasPlayingBeforePip = playing;
      await pip.enterPip(playing: playing);
    }
  }

  void _showMediaInfo() {
    showModalBottomSheet(
      context: context,
      builder: (_) => MediaInfoSheet(player: ref.read(playerProvider), filePath: widget.filePath),
    );
  }

  void _showAddToPlaylist() {
    final player = ref.read(playerProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => AddToPlaylistSheet(
        filePath: widget.filePath,
        title: widget.filePath.split('/').last,
        durationMs: player.state.duration.inMilliseconds,
      ),
    );
  }

  Future<void> _loadSubtitle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'ssa', 'vtt', 'sub', 'webvtt'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    final player = ref.read(playerProvider);
    await player.setSubtitleTrack(SubtitleTrack.uri(path));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subtitle loaded: ${result.files.first.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(playerIsPlayingProvider).asData?.value ?? false;

    final hardwareMap = <ShortcutActivator, VoidCallback>{
      SingleActivator(LogicalKeyboardKey.mediaPlayPause): () {
        final p = ref.read(playerProvider);
        if (isPlaying) { p.pause(); } else { p.play(); }
      },
      SingleActivator(LogicalKeyboardKey.mediaTrackNext): () => _skip(10),
      SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): () => _skip(-10),
      SingleActivator(LogicalKeyboardKey.arrowLeft): () => _skip(-ref.read(skipIntervalProvider)),
      SingleActivator(LogicalKeyboardKey.arrowRight): () => _skip(ref.read(skipIntervalProvider)),
      SingleActivator(LogicalKeyboardKey.space): () {
        final p = ref.read(playerProvider);
        if (isPlaying) { p.pause(); } else { p.play(); }
      },
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: CallbackShortcuts(
        bindings: hardwareMap,
        child: GestureHandler(
          onTap: _toggleControls,
          onSkip: _skip,
          locked: _playerLocked,
          child: Stack(
          children: [
            const Positioned.fill(child: PlayerVideoArea()),
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: _buildTopBar(context),
                ),
              ),
            ),
            const PlayerOverlay(),
            if (_playerLocked)
              Positioned(
                top: MediaQuery.of(context).padding.top + 4,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                  tooltip: 'Tap to unlock',
                  onPressed: _toggleLock,
                ),
              ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _seekBarVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_seekBarVisible,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: _controlsVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !_controlsVisible,
                          child: PlayerControlsBar(isPlaying: isPlaying),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        ), // CallbackShortcuts end
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Close player',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Media info',
            onPressed: _showMediaInfo,
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add, color: Colors.white),
            tooltip: 'Add to playlist',
            onPressed: _showAddToPlaylist,
          ),
          IconButton(
            icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
            tooltip: 'Load subtitles',
            onPressed: _loadSubtitle,
          ),
          IconButton(
            icon: Icon(_playerLocked ? Icons.lock : Icons.lock_open, color: Colors.white),
            tooltip: _playerLocked ? 'Unlock controls' : 'Lock controls',
            onPressed: _toggleLock,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'More options',
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const PlayerMoreSheet(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
            tooltip: 'Picture-in-picture',
            onPressed: _enterPip,
          ),
          Consumer(
            builder: (_, ref, child) {
              final timer = ref.watch(sleepTimerProvider);
              if (timer.state == SleepTimerState.inactive) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: 'Sleep: ${timer.formattedRemaining}',
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(context: context, builder: (_) => const SleepTimerSheet()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, size: 14, color: Colors.cyan),
                          const SizedBox(width: 4),
                          Text(
                            timer.formattedRemaining,
                            style: const TextStyle(color: Colors.cyan, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.timer_outlined, color: Colors.white),
            tooltip: 'Sleep timer',
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const SleepTimerSheet(),
            ),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (_, ref, child) => VolumeSlider(
              volume: ref.watch(playerVolumeProvider).asData?.value ?? 1.0,
              onChanged: (v) => ref.read(playerProvider).setVolume(v),
            ),
          ),
        ],
      ),
    );
  }

  void _skip(int seconds) {
    HapticFeedback.mediumImpact();
    final player = ref.read(playerProvider);
    final current = ref.read(playerPositionProvider).asData?.value ?? Duration.zero;
    final dur = ref.read(playerDurationProvider).asData?.value ?? Duration.zero;
    final newMs = (current.inMilliseconds + seconds * 1000).clamp(0, dur.inMilliseconds);
    player.seek(Duration(milliseconds: newMs));

    ref.read(playerOverlayProvider.notifier).show(
      HorizontalSeek(
        timeText: formatDuration(newMs),
        deltaText: '${seconds > 0 ? '+' : ''}${seconds}s',
        isForward: seconds > 0,
      ),
    );

    setState(() {
      _seekBarVisible = true;
    });
    _startHideTimer(isFullToggle: false);
  }
}
