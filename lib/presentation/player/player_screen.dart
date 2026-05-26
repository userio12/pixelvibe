import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/di/platform_providers.dart';
import '../../core/di/providers.dart';
import '../../presentation/playlist/widgets/add_to_playlist_sheet.dart';
import '../../domain/services/thumbnail_service.dart';
import '../../services/logger.dart';
import '../../utils/permissions/permission_handler.dart';
import '../../utils/format_utils.dart';
import '../../utils/platform_helper.dart';
import '../settings/settings_provider.dart';
import 'ab_loop_provider.dart';
import 'control_layout_provider.dart';
import 'player_button.dart';
import 'player_provider.dart';
import 'video_quality_provider.dart';
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
import 'widgets/video_quality_sheet.dart';
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
  StreamSubscription? _audioFocusSub;
  bool _controlsVisible = true;
  bool _seekBarVisible = true;
  bool _wasPlayingBeforePip = false;
  bool _playerLocked = false;
  bool _watchedNotified = false;

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
    _setupAudioFocus();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _saveTimer?.cancel();
    _pipToggleSub?.cancel();
    _playingSub?.cancel();
    _noisySub?.cancel();
    _audioFocusSub?.cancel();
    PlayerOrientation.reset();
    ref.read(backgroundServiceProvider).stopService();
    super.dispose();
  }

  void _openMedia() {
    final player = ref.read(playerProvider);
    final headers = _parseHttpHeaders();
    player.open(Media(widget.filePath, httpHeaders: headers), play: true);
    _applyPlayerConfig(player);
    _autoloadSubtitle(player);
  }

  Map<String, String>? _parseHttpHeaders() {
    final raw = ref.read(preferencesServiceProvider).getHttpHeaders();
    if (raw.isEmpty) return null;
    try {
      final lines = raw.split('\n');
      final map = <String, String>{};
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final colon = trimmed.indexOf(':');
        if (colon > 0) {
          map[trimmed.substring(0, colon).trim()] = trimmed.substring(colon + 1).trim();
        }
      }
      return map;
    } catch (_) {
      return null;
    }
  }

  void _autoloadSubtitle(Player player) {
    if (!widget.filePath.startsWith('http://') && !widget.filePath.startsWith('https://') && !widget.filePath.startsWith('smb://')) return;
    final base = widget.filePath.substring(0, widget.filePath.lastIndexOf('.'));
    final subExtensions = ['.srt', '.ass', '.ssa', '.vtt', '.sub'];
    for (final ext in subExtensions) {
      final subPath = '$base$ext';
      try {
        player.setSubtitleTrack(SubtitleTrack.uri(subPath));
        break;
      } catch (_) {}
    }
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
          _handleEndOfVideo();
        }
      } else if (playing && mounted) {
        _checkAbLoop(player);
        _checkWatchedThreshold(player);
      }
    });
  }

  void _checkAbLoop(Player player) {
    final ab = ref.read(abLoopProvider);
    if (!ab.isActive) return;
    final pos = player.state.position.inMilliseconds;
    if (ab.bPointMs != null && pos >= ab.bPointMs!) {
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

  void _handleEndOfVideo() {
    final closeAfterEnd = ref.read(preferencesServiceProvider).getCloseAfterEnd();
    if (closeAfterEnd && mounted) {
      Navigator.of(context).maybePop();
      return;
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoreFileBrightness();
  }

  void _restoreFileBrightness() {
    final prefs = ref.read(preferencesServiceProvider);
    final saved = prefs.getFileBrightness(widget.filePath);
    if (saved != 1.0) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: saved > 0.5 ? Brightness.light : Brightness.dark,
        statusBarIconBrightness: saved > 0.5 ? Brightness.dark : Brightness.light,
      ));
    }
  }

  void _setupAudioFocus() {
    final pip = ref.read(pipServiceProvider);
    pip.requestAudioFocus();
    _audioFocusSub = pip.onAudioFocusChange.listen((focusChange) {
      if (!mounted) return;
      final player = ref.read(playerProvider);
      if (focusChange < 0) {
        player.pause();
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
    _getThumbnailPath().then((thumb) {
      bg.updateMetadata(
        title: widget.filePath.split('/').last.split('.').first,
        durationMs: dur.inMilliseconds,
        thumbnail: thumb,
      );
    });
    bg.updatePlaybackState(playing: true, positionMs: pos.inMilliseconds);
  }

  Future<String?> _getThumbnailPath() async {
    try {
      final path = widget.filePath;
      if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('smb://')) {
        return null;
      }
      return await ThumbnailService().getThumbnailPath(path);
    } catch (_) {
      return null;
    }
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
    if (ref.read(audioBackgroundProvider)) return;
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
    final layout = ref.watch(controlLayoutProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ...layout.topLeft.map((btn) => _buildButton(btn)),
          const Spacer(),
          ...layout.topRight.map((btn) => _buildButton(btn)),
        ],
      ),
    );
  }

  Widget _buildButton(PlayerButton btn) {
    switch (btn) {
      case PlayerButton.backArrow:
        return IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: btn.tooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        );
      case PlayerButton.videoTitle:
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.filePath.split('/').last.split('.').first,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      case PlayerButton.speed:
        return _buildIconButton(ref.read(defaultSpeedProvider) != 1.0
            ? Icons.speed : Icons.speed_outlined, Colors.white, btn.tooltip, _showSpeedSheet);
      case PlayerButton.skipBack:
        return _buildIconButton(Icons.replay_10, Colors.white, btn.tooltip, () => _skip(-ref.read(skipIntervalProvider)));
      case PlayerButton.skipForward:
        return _buildIconButton(Icons.forward_10, Colors.white, btn.tooltip, () => _skip(ref.read(skipIntervalProvider)));
      case PlayerButton.playPause:
        return Consumer(
          builder: (_, ref, child) {
            final playing = ref.watch(playerIsPlayingProvider).asData?.value ?? false;
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: IconButton(
                icon: Icon(playing ? Icons.pause : Icons.play_arrow, fill: 1),
                iconSize: 40,
                color: Colors.white,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final p = ref.read(playerProvider);
                  if (playing) { p.pause(); } else { p.play(); }
                },
              ),
            );
          },
        );
      case PlayerButton.abLoop:
        return Consumer(
          builder: (_, ref, child) {
            final ab = ref.watch(abLoopProvider);
            return _buildIconButton(
              ab.isActive ? Icons.loop : Icons.loop_outlined,
              ab.isActive ? Colors.cyan : Colors.white,
              btn.tooltip,
              _handleAbLoop,
            );
          },
        );
      case PlayerButton.frameNav:
        return Consumer(
          builder: (_, ref, child) {
            final playing = ref.watch(playerIsPlayingProvider).asData?.value ?? false;
            if (playing) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white70, size: 20),
                  tooltip: 'Frame back',
                  onPressed: () => ref.read(frameStepProvider).stepBackward(),
                ),
                Text('Frame', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54)),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white70, size: 20),
                  tooltip: 'Frame forward',
                  onPressed: () => ref.read(frameStepProvider).stepForward(),
                ),
              ],
            );
          },
        );
      case PlayerButton.audioTrack:
        return _buildIconButton(Icons.audiotrack, Colors.white, btn.tooltip, _showAudioTrackSheet);
      case PlayerButton.subtitles:
        return _buildIconButton(Icons.subtitles, Colors.white, btn.tooltip, () => showModalBottomSheet(
          context: context,
          builder: (_) => const SizedBox(),
        ));
      case PlayerButton.chapters:
        return _buildIconButton(Icons.chat_bubble_outline, Colors.white, btn.tooltip, _showChapterSheet);
      case PlayerButton.repeat:
        return Consumer(
          builder: (_, ref, child) {
            final mode = ref.watch(repeatModeProvider);
            final icon = switch (mode) {
              LoopMode.off => Icons.repeat,
              LoopMode.one => Icons.repeat_one,
              LoopMode.all => Icons.repeat,
            };
            return _buildIconButton(icon, mode != LoopMode.off ? Colors.cyan : Colors.white, 'Repeat: ${mode.name}', () {
              ref.read(repeatModeProvider.notifier).cycle();
              final newMode = ref.read(repeatModeProvider);
              ref.read(playerOverlayProvider.notifier).show(RepeatModeChange(newMode.name));
            });
          },
        );
      case PlayerButton.shuffle:
        return Consumer(
          builder: (_, ref, child) {
            final shuffled = ref.watch(shuffleEnabledProvider);
            return _buildIconButton(
              Icons.shuffle,
              shuffled ? Colors.cyan : Colors.white,
              'Shuffle: ${shuffled ? "On" : "Off"}',
              () => ref.read(shuffleEnabledProvider.notifier).toggle(),
            );
          },
        );
      case PlayerButton.playlist:
        return _buildIconButton(Icons.playlist_play, Colors.white, btn.tooltip, _showPlaylistQueue);
      case PlayerButton.info:
        return _buildIconButton(Icons.info_outline, Colors.white, btn.tooltip, _showMediaInfo);
      case PlayerButton.screenshot:
        return _buildIconButton(Icons.screenshot, Colors.white, btn.tooltip, _takeScreenshot);
      case PlayerButton.aspectRatio:
        return _buildIconButton(Icons.aspect_ratio, Colors.white, btn.tooltip, _showAspectRatioSheet);
      case PlayerButton.zoom:
        return _buildIconButton(Icons.zoom_in, Colors.white, btn.tooltip, _showZoomSheet);
      case PlayerButton.more:
        return _buildIconButton(Icons.more_vert, Colors.white, btn.tooltip, () => showModalBottomSheet(
          context: context,
          builder: (_) => const PlayerMoreSheet(),
        ));
      case PlayerButton.lock:
        return _buildIconButton(
          _playerLocked ? Icons.lock : Icons.lock_open,
          Colors.white,
          _playerLocked ? 'Unlock controls' : 'Lock controls',
          _toggleLock,
        );
      case PlayerButton.pip:
        return _buildIconButton(Icons.picture_in_picture_alt, Colors.white, btn.tooltip, _enterPip);
      case PlayerButton.sleepTimer:
        return Consumer(
          builder: (_, ref, child) {
            final timer = ref.watch(sleepTimerProvider);
            if (timer.state != SleepTimerState.inactive) {
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
                          const Icon(Icons.timer, size: 14, color: Colors.cyan),
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
            }
            return _buildIconButton(Icons.timer_outlined, Colors.white, btn.tooltip, () => showModalBottomSheet(
              context: context,
              builder: (_) => const SleepTimerSheet(),
            ));
          },
        );
      case PlayerButton.volume:
        return Consumer(
          builder: (_, ref, child) => VolumeSlider(
            volume: ref.watch(playerVolumeProvider).asData?.value ?? 1.0,
            onChanged: (v) => ref.read(playerProvider).setVolume(v),
          ),
        );
      case PlayerButton.addToPlaylist:
        return _buildIconButton(Icons.playlist_add, Colors.white, btn.tooltip, _showAddToPlaylist);
      case PlayerButton.loadSubtitle:
        return _buildIconButton(Icons.subtitles_outlined, Colors.white, btn.tooltip, _loadSubtitle);
      case PlayerButton.decoder:
        return _buildIconButton(Icons.settings, Colors.white, btn.tooltip, _showDecoderSheet);
      case PlayerButton.filters:
        return _buildIconButton(Icons.filter, Colors.white, btn.tooltip, _showFilterSheet);
    }
  }

  Widget _buildIconButton(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
    );
  }

  void _handleAbLoop() {
    final ab = ref.read(abLoopProvider);
    if (ab.isActive) {
      ref.read(abLoopProvider.notifier).clear();
      ref.read(playerOverlayProvider.notifier).show(const ABLoopUpdate(false));
      return;
    }
    final pos = ref.read(playerProvider).state.position.inMilliseconds;
    if (ab.aPointMs == null) {
      ref.read(abLoopProvider.notifier).setA(pos);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Point A set. Seek to B and press again.'), duration: Duration(seconds: 2)),
      );
    } else {
      ref.read(abLoopProvider.notifier).setB(pos);
      ref.read(playerOverlayProvider.notifier).show(const ABLoopUpdate(true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A-B loop activated'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _takeScreenshot() async {
    try {
      final player = ref.read(playerProvider);
      final data = await player.screenshot();
      if (data != null && mounted) {
        final dir = await getApplicationDocumentsDirectory();
        final ssDir = Directory('${dir.path}/pixelvibe_screenshots');
        if (!await ssDir.exists()) await ssDir.create(recursive: true);
        final file = File('${ssDir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Screenshot saved: ${file.path}')),
          );
        }
      }
    } catch (e) {
      Logger.error('Screenshot error', e);
    }
  }

  void _showSpeedSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const _SpeedSheet(),
    );
  }

  void _showAudioTrackSheet() {}
  void _showChapterSheet() {}
  void _showAspectRatioSheet() {}
  void _showZoomSheet() {}
  void _showDecoderSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Decoder', style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(height: 1),
          const _HwdecTile(),
          const _GpuApiTile(),
          const _HrSeekTile(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SizedBox(
        height: 600,
        child: VideoQualitySheet(),
      ),
    );
  }
  void _showPlaylistQueue() {
    final queue = ref.read(playlistQueueProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Playlist Queue', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: queue.filePaths.length,
                itemBuilder: (_, i) => ListTile(
                  leading: Icon(
                    i == queue.currentIndex ? Icons.play_circle_filled : Icons.movie_outlined,
                    color: i == queue.currentIndex ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(
                    queue.titles.isNotEmpty ? queue.titles[i] : queue.filePaths[i].split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: i == queue.currentIndex,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
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

class _SpeedSheet extends ConsumerWidget {
  const _SpeedSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 3.0, 4.0];
    final current = ref.watch(defaultSpeedProvider);
    final player = ref.read(playerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Playback Speed', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 8),
          ...speeds.map((s) => ListTile(
            leading: Icon(Icons.speed, color: s == current ? Theme.of(context).colorScheme.primary : null),
            title: Text('${s}x'),
            trailing: s == current ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              ref.read(defaultSpeedProvider.notifier).update(s);
              player.setRate(s);
              ref.read(playerOverlayProvider.notifier).show(SpeedChange(s));
              Navigator.of(context).pop();
            },
          )),
        ],
      ),
    );
  }
}

// ── Decoder sheet tiles ────────────────────────────────────────────
class _HwdecTile extends ConsumerWidget {
  const _HwdecTile();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(hwdecProvider);
    return ListTile(
      title: const Text('Hardware decoder'),
      subtitle: const Text('hwdec profile'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Auto')),
          DropdownMenuItem(value: 'auto-safe', child: Text('Auto (safe)')),
          DropdownMenuItem(value: 'no', child: Text('Software')),
          DropdownMenuItem(value: 'mediacodec', child: Text('MediaCodec')),
          DropdownMenuItem(value: 'cuda', child: Text('CUDA')),
          DropdownMenuItem(value: 'd3d11va', child: Text('D3D11VA')),
          DropdownMenuItem(value: 'vaapi', child: Text('VAAPI')),
        ],
        onChanged: (v) => ref.read(hwdecProvider.notifier).update(v ?? 'auto'),
      ),
    );
  }
}

class _GpuApiTile extends ConsumerWidget {
  const _GpuApiTile();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(gpuApiProvider);
    return ListTile(
      title: const Text('GPU backend'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Auto')),
          DropdownMenuItem(value: 'vulkan', child: Text('Vulkan')),
          DropdownMenuItem(value: 'opengl', child: Text('OpenGL')),
        ],
        onChanged: (v) => ref.read(gpuApiProvider.notifier).update(v ?? 'auto'),
      ),
    );
  }
}

class _HrSeekTile extends ConsumerWidget {
  const _HrSeekTile();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(hrSeekProvider);
    return SwitchListTile(
      title: const Text('Precise seeking'),
      subtitle: const Text('hr-seek (frame-accurate jumps)'),
      value: v,
      onChanged: (_) => ref.read(hrSeekProvider.notifier).toggle(),
    );
  }
}
