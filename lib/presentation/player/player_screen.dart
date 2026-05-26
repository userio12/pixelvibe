import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/di/platform_providers.dart';
import '../../core/di/providers.dart';
import '../../presentation/playlist/widgets/add_to_playlist_sheet.dart';
import '../settings/settings_provider.dart';
import 'player_provider.dart';
import 'widgets/frame_navigation_controls.dart';
import 'widgets/media_info_sheet.dart';
import 'widgets/player_controls.dart';
import 'widgets/resume_dialog.dart';
import 'widgets/seek_bar.dart';
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
  bool _controlsVisible = true;
  bool _wasPlayingBeforePip = false;

  @override
  void initState() {
    super.initState();
    _openMedia();
    _startHideTimer();
    _startSaveTimer();
    _setupPipCallback();
    _recordRecentlyPlayed();
    _checkResume();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _saveTimer?.cancel();
    _pipToggleSub?.cancel();
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

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
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
        debugPrint('Save position error: $e');
      }
    });
  }

  Future<void> _recordRecentlyPlayed() async {
    try {
      await ref.read(recentlyPlayedDaoProvider).record(
        widget.filePath,
        widget.filePath.split('/').last.split('.').first,
        null,
      );
    } catch (e) {
      debugPrint('Record recently played error: $e');
    }
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _startHideTimer();
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
      debugPrint('Resume check error: $e');
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
      builder: (_) => MediaInfoSheet(player: ref.read(playerProvider)),
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
    final player = ref.watch(playerProvider);
    final position = ref.watch(playerPositionProvider).asData?.value ?? Duration.zero;
    final duration = ref.watch(playerDurationProvider).asData?.value ?? Duration.zero;
    final isPlaying = ref.watch(playerIsPlayingProvider).asData?.value ?? false;
    final volume = ref.watch(playerVolumeProvider).asData?.value ?? 1.0;
    final buffer = ref.watch(playerBufferProvider).asData?.value ?? Duration.zero;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          final half = (context.size?.width ?? MediaQuery.of(context).size.width) / 2;
          final interval = ref.read(skipIntervalProvider);
          if (details.localPosition.dx < half) {
            _skip(-interval);
          } else {
            _skip(interval);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Video(controller: VideoController(player)),
            ),
            if (_controlsVisible) ...[
              Positioned(
                top: MediaQuery.of(context).padding.top + 4,
                left: 0,
                right: 0,
                child: _buildTopBar(context),
              ),
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 0,
                right: 0,
                child: _buildBottomBar(context, position, duration, isPlaying, volume, buffer),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showMediaInfo,
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add, color: Colors.white),
            onPressed: _showAddToPlaylist,
          ),
          IconButton(
            icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
            tooltip: 'Load subtitles',
            onPressed: _loadSubtitle,
          ),
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
            onPressed: _enterPip,
          ),
          const SizedBox(width: 8),
          VolumeSlider(
            volume: ref.watch(playerVolumeProvider).asData?.value ?? 1.0,
            onChanged: (v) => ref.read(playerProvider).setVolume(v),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    Duration position,
    Duration duration,
    bool isPlaying,
    double volume,
    Duration buffer,
  ) {
    final player = ref.read(playerProvider);
    final bufferProgress = duration.inMilliseconds > 0
        ? buffer.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SeekBar(
          position: position,
          duration: duration,
          bufferProgress: bufferProgress,
          onSeek: (pos) => player.seek(pos),
        ),
        const SizedBox(height: 8),
        PlayerControls(
          isPlaying: isPlaying,
          onPlayPause: () {
            if (isPlaying) {
              player.pause();
            } else {
              player.play();
            }
          },
          onSkipBack: () {
            final interval = ref.read(skipIntervalProvider);
            _skip(-interval);
          },
          onSkipForward: () {
            final interval = ref.read(skipIntervalProvider);
            _skip(interval);
          },
        ),
        if (!isPlaying) ...[
          const SizedBox(height: 8),
          FrameNavigationControls(
            onStepBack: () => ref.read(frameStepProvider).stepBackward(),
            onStepForward: () => ref.read(frameStepProvider).stepForward(),
          ),
        ],
      ],
    );
  }

  void _skip(int seconds) {
    final player = ref.read(playerProvider);
    final current = ref.read(playerPositionProvider).asData?.value ?? Duration.zero;
    final dur = ref.read(playerDurationProvider).asData?.value ?? Duration.zero;
    final ms = (current.inMilliseconds + seconds * 1000).clamp(0, dur.inMilliseconds);
    player.seek(Duration(milliseconds: ms));
  }
}
