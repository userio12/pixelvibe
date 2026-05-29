import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import '../player_button.dart';
import '../player_provider.dart';
import '../player_screen_provider.dart';
import '../player_overlay.dart';
import '../player_updates.dart';
import '../ab_loop_provider.dart';
import '../playlist_queue_provider.dart';
import '../sleep_timer_provider.dart';
import '../video_quality_provider.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../settings/settings_provider.dart';
import '../../../core/di/platform_providers.dart';
import '../../../services/logger.dart';
import '../../../utils/format_utils.dart';
import 'audio_track_sheet.dart';
import 'chapter_sheet.dart';
import 'subtitle_settings_sheet.dart';
import 'media_info_sheet.dart';
import 'aspect_ratio_sheet.dart';
import 'player_more_sheet.dart';
import 'video_quality_sheet.dart';
import 'sleep_timer_sheet.dart';
import 'volume_slider.dart';
import '../../playlist/widgets/add_to_playlist_sheet.dart';

class PlayerButtonWidget extends ConsumerWidget {
  final PlayerButton btn;
  final String filePath;

  const PlayerButtonWidget({super.key, required this.btn, required this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenNotifier = ref.read(playerScreenProvider.notifier);
    final locked = ref.watch(playerScreenProvider.select((s) => s.locked));
    final playerColors = PixelvibeColors.of(context);

    switch (btn) {
      case PlayerButton.backArrow:
        return IconButton(
          icon: Icon(Icons.arrow_back_ios, color: playerColors.playerControlColor),
          tooltip: btn.tooltip,
          onPressed: () => context.pop(),
        );
      case PlayerButton.videoTitle:
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              filePath.split('/').last.split('.').first,
              style: TextStyle(color: playerColors.playerControlColor, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      case PlayerButton.speed:
        return _buildIconButton(ref, context, ref.read(defaultSpeedProvider) != 1.0
            ? Icons.speed : Icons.speed_outlined, playerColors.playerControlColor, btn.tooltip, () => _showSpeedSheet(context, ref));
      case PlayerButton.skipBack:
        return _buildIconButton(ref, context, Icons.replay_10, playerColors.playerControlColor, btn.tooltip, () => _skip(ref, -ref.read(skipIntervalProvider)));
      case PlayerButton.skipForward:
        return _buildIconButton(ref, context, Icons.forward_10, playerColors.playerControlColor, btn.tooltip, () => _skip(ref, ref.read(skipIntervalProvider)));
      case PlayerButton.playPause:
        final playing = ref.watch(playerIsPlayingProvider).asData?.value ?? false;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: IconButton(
            icon: Icon(playing ? Icons.pause : Icons.play_arrow, fill: 1),
            iconSize: 40,
            color: playerColors.playerControlColor,
            onPressed: () {
              HapticFeedback.selectionClick();
              final p = ref.read(playerProvider);
              if (playing) { p.pause(); } else { p.play(); }
            },
          ),
        );
      case PlayerButton.abLoop:
        final ab = ref.watch(abLoopProvider);
        return _buildIconButton(ref, context,
          ab.isActive ? Icons.loop : Icons.loop_outlined,
          ab.isActive ? playerColors.playerControlActiveColor : playerColors.playerControlColor,
          btn.tooltip,
          () => _handleAbLoop(context, ref),
        );
      case PlayerButton.frameNav:
        final playing = ref.watch(playerIsPlayingProvider).asData?.value ?? false;
        if (playing) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous, color: playerColors.playerControlSecondaryColor, size: 20),
              tooltip: 'Frame back',
              onPressed: () => ref.read(frameStepProvider).stepBackward(),
            ),
            Text('Frame', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: playerColors.playerControlSecondaryColor)),
            IconButton(
              icon: Icon(Icons.skip_next, color: playerColors.playerControlSecondaryColor, size: 20),
              tooltip: 'Frame forward',
              onPressed: () => ref.read(frameStepProvider).stepForward(),
            ),
          ],
        );
      case PlayerButton.audioTrack:
        return _buildIconButton(ref, context, Icons.audiotrack, playerColors.playerControlColor, btn.tooltip, () => _showAudioTrackSheet(context));
      case PlayerButton.subtitles:
        return _buildIconButton(ref, context, Icons.subtitles, playerColors.playerControlColor, btn.tooltip, () => showModalBottomSheet(
          context: context,
          builder: (_) => const SubtitleSettingsSheet(),
        ));
      case PlayerButton.chapters:
        return _buildIconButton(ref, context, Icons.chat_bubble_outline, playerColors.playerControlColor, btn.tooltip, () => _showChapterSheet(context, ref));
      case PlayerButton.repeat:
        final mode = ref.watch(repeatModeProvider);
        final icon = switch (mode) {
          LoopMode.off => Icons.repeat,
          LoopMode.one => Icons.repeat_one,
          LoopMode.all => Icons.repeat,
        };
        return _buildIconButton(ref, context, icon, mode != LoopMode.off ? playerColors.playerControlActiveColor : playerColors.playerControlColor, 'Repeat: ${mode.name}', () {
          ref.read(repeatModeProvider.notifier).cycle();
          final newMode = ref.read(repeatModeProvider);
          ref.read(playerOverlayProvider.notifier).show(RepeatModeChange(newMode.name));
        });
      case PlayerButton.shuffle:
        final shuffled = ref.watch(shuffleEnabledProvider);
        return _buildIconButton(ref, context,
          Icons.shuffle,
          shuffled ? playerColors.playerControlActiveColor : playerColors.playerControlColor,
          'Shuffle: ${shuffled ? "On" : "Off"}',
          () => ref.read(shuffleEnabledProvider.notifier).toggle(),
        );
      case PlayerButton.playlist:
        return _buildIconButton(ref, context, Icons.playlist_play, playerColors.playerControlColor, btn.tooltip, () => _showPlaylistQueue(context, ref));
      case PlayerButton.info:
        return _buildIconButton(ref, context, Icons.info_outline, playerColors.playerControlColor, btn.tooltip, () => _showMediaInfo(context, ref));
      case PlayerButton.screenshot:
        return _buildIconButton(ref, context, Icons.screenshot, playerColors.playerControlColor, btn.tooltip, () => _takeScreenshot(context, ref));
      case PlayerButton.aspectRatio:
        return _buildIconButton(ref, context, Icons.aspect_ratio, playerColors.playerControlColor, btn.tooltip, () => _showAspectRatioSheet(context, ref));
      case PlayerButton.zoom:
        return _buildIconButton(ref, context, Icons.zoom_in, playerColors.playerControlColor, btn.tooltip, () => _showZoomSheet(context));
      case PlayerButton.more:
        return _buildIconButton(ref, context, Icons.more_vert, playerColors.playerControlColor, btn.tooltip, () => showModalBottomSheet(
          context: context,
          builder: (_) => const PlayerMoreSheet(),
        ));
      case PlayerButton.lock:
        return _buildIconButton(ref, context,
          locked ? Icons.lock : Icons.lock_open,
          playerColors.playerControlColor,
          locked ? 'Unlock controls' : 'Lock controls',
          () => screenNotifier.toggleLock(),
        );
      case PlayerButton.pip:
        return _buildIconButton(ref, context, Icons.picture_in_picture_alt, playerColors.playerControlColor, btn.tooltip, () => _enterPip(ref));
      case PlayerButton.sleepTimer:
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
                    color: playerColors.playerControlBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 14, color: playerColors.playerControlActiveColor),
                      const SizedBox(width: 4),
                      Text(
                        timer.formattedRemaining,
                        style: TextStyle(color: playerColors.playerControlActiveColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return _buildIconButton(ref, context, Icons.timer_outlined, playerColors.playerControlColor, btn.tooltip, () => showModalBottomSheet(
          context: context,
          builder: (_) => const SleepTimerSheet(),
        ));
      case PlayerButton.volume:
        return VolumeSlider(
          volume: ref.watch(playerVolumeProvider).asData?.value ?? 1.0,
          onChanged: (v) => ref.read(playerProvider).setVolume(v),
        );
      case PlayerButton.addToPlaylist:
        return _buildIconButton(ref, context, Icons.playlist_add, playerColors.playerControlColor, btn.tooltip, () => _showAddToPlaylist(context, ref));
      case PlayerButton.loadSubtitle:
        return _buildIconButton(ref, context, Icons.subtitles_outlined, playerColors.playerControlColor, btn.tooltip, () => _loadSubtitle(context, ref));
      case PlayerButton.decoder:
        return _buildIconButton(ref, context, Icons.settings, playerColors.playerControlColor, btn.tooltip, () => _showDecoderSheet(context, ref));
      case PlayerButton.filters:
        return _buildIconButton(ref, context, Icons.filter, playerColors.playerControlColor, btn.tooltip, () => _showFilterSheet(context));
    }
  }

  Widget _buildIconButton(WidgetRef ref, BuildContext context, IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
        ref.read(playerScreenProvider.notifier).startHideTimer();
      },
    );
  }

  void _skip(WidgetRef ref, int seconds) {
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
    ref.read(playerScreenProvider.notifier).showSeekBarTemporarily();
  }

  void _showSpeedSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const _SpeedSheet(),
    );
  }

  void _showAudioTrackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AudioTrackSheet(filePath: filePath),
    );
  }

  Future<void> _showChapterSheet(BuildContext context, WidgetRef ref) async {
    final player = ref.read(playerProvider);
    final platform = player.platform;
    List<Chapter> chapters = const [];
    if (platform is NativePlayer) {
      try {
        final raw = await platform.getProperty('chapter-list');
        final list = jsonDecode(raw) as List;
        chapters = list.map((c) {
          final map = c as Map<String, dynamic>;
          final title = map['title'] as String? ?? '';
          final time = (map['time'] as num?)?.toDouble() ?? 0.0;
          return Chapter(title: title, start: Duration(milliseconds: (time * 1000).round()), end: Duration.zero);
        }).toList();
        for (var i = 0; i < chapters.length - 1; i++) {
          chapters[i] = Chapter(title: chapters[i].title, start: chapters[i].start, end: chapters[i + 1].start);
        }
      } catch (e) {
        Logger.error('Failed to load chapters', e);
      }
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => ChapterSheet(player: player, chapters: chapters),
    );
  }

  void _showAspectRatioSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AspectRatioSheet(
        current: VideoAspectRatio.fit,
        onSelect: (ar) {
          Navigator.of(context).pop();
          final platform = ref.read(playerProvider).platform;
          if (platform is! NativePlayer) return;
          final native = platform;
          switch (ar) {
            case VideoAspectRatio.fit:
              native.setProperty('video-aspect-override', '-1');
            case VideoAspectRatio.crop:
              native.setProperty('video-aspect-override', '-1');
              native.setProperty('panscan', '1.0');
            case VideoAspectRatio.stretch:
              native.setProperty('video-aspect-override', '0');
          }
        },
      ),
    );
  }

  void _showZoomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _ZoomSheet(),
    );
  }

  void _showDecoderSheet(BuildContext context, WidgetRef ref) {
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SizedBox(
        height: 600,
        child: VideoQualitySheet(),
      ),
    );
  }

  void _showPlaylistQueue(BuildContext context, WidgetRef ref) {
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

  void _handleAbLoop(BuildContext context, WidgetRef ref) {
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

  Future<void> _takeScreenshot(BuildContext context, WidgetRef ref) async {
    try {
      final player = ref.read(playerProvider);
      final data = await player.screenshot();
      if (data != null) {
        final dir = await getApplicationDocumentsDirectory();
        final ssDir = Directory('${dir.path}/pixelvibe_screenshots');
        if (!await ssDir.exists()) await ssDir.create(recursive: true);
        final file = File('${ssDir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(data);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Screenshot saved: ${file.path}')),
          );
        }
      }
    } catch (e) {
      Logger.error('Screenshot error', e);
    }
  }

  void _showMediaInfo(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => MediaInfoSheet(player: ref.read(playerProvider), filePath: filePath),
    );
  }

  void _showAddToPlaylist(BuildContext context, WidgetRef ref) {
    final player = ref.read(playerProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => AddToPlaylistSheet(
        filePath: filePath,
        title: filePath.split('/').last,
        durationMs: player.state.duration.inMilliseconds,
      ),
    );
  }

  Future<void> _loadSubtitle(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'ssa', 'vtt', 'sub', 'webvtt'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    final player = ref.read(playerProvider);
    await player.setSubtitleTrack(SubtitleTrack.uri(path));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subtitle loaded: ${result.files.first.name}')),
      );
    }
  }

  Future<void> _enterPip(WidgetRef ref) async {
    if (ref.read(audioBackgroundProvider)) return;
    if (!ref.read(autoPipProvider)) return;
    final pip = ref.read(pipServiceProvider);
    final supported = await pip.isPipSupported();
    if (supported) {
      final playing = ref.read(playerIsPlayingProvider).asData?.value ?? false;
      await pip.enterPip(playing: playing);
    }
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

class _ZoomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final zoomLevels = [
      ('Default', 0.0),
      ('Zoom 2x', 1.0),
      ('Zoom 3x', 1.5),
      ('Zoom 4x', 2.0),
    ];
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Zoom', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: zoomLevels.map<Widget>((entry) {
                final label = entry.$1;
                final value = entry.$2;
                return ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: Text(label),
                  onTap: () {
                    final platform = ref.read(playerProvider).platform;
                    if (platform is! NativePlayer) return;
                    final native = platform;
                    native.setProperty('video-zoom', value.toString());
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
