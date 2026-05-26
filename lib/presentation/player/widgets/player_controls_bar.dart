import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../settings/settings_provider.dart';
import '../player_provider.dart';
import '../playlist_queue_provider.dart';
import '../player_overlay.dart';
import '../player_updates.dart';
import 'frame_navigation_controls.dart';
import 'player_controls.dart';
import 'seek_bar.dart';
import 'volume_slider.dart';

class PlayerControlsBar extends ConsumerWidget {
  final bool isPlaying;

  const PlayerControlsBar({super.key, required this.isPlaying});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final position = ref.watch(playerPositionProvider).asData?.value ?? Duration.zero;
    final duration = ref.watch(playerDurationProvider).asData?.value ?? Duration.zero;
    final volume = ref.watch(playerVolumeProvider).asData?.value ?? 1.0;
    final buffer = ref.watch(playerBufferProvider).asData?.value ?? Duration.zero;
    final queue = ref.watch(playlistQueueProvider);
    final repeatMode = ref.watch(repeatModeProvider);

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
        if (queue.hasMultiple)
          _PlaylistNavRow(queue: queue, repeatMode: repeatMode, isPlaying: isPlaying, player: player, ref: ref),
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
            _skip(ref, -interval);
          },
          onSkipForward: () {
            final interval = ref.read(skipIntervalProvider);
            _skip(ref, interval);
          },
        ),
        if (!isPlaying) ...[
          const SizedBox(height: 8),
          FrameNavigationControls(
            onStepBack: () => ref.read(frameStepProvider).stepBackward(),
            onStepForward: () => ref.read(frameStepProvider).stepForward(),
          ),
        ],
        if (true) ...[
          const SizedBox(height: 8),
          VolumeSlider(
            volume: volume,
            onChanged: (v) => ref.read(playerProvider).setVolume(v),
          ),
        ],
      ],
    );
  }

  void _skip(WidgetRef ref, int seconds) {
    HapticFeedback.mediumImpact();
    final player = ref.read(playerProvider);
    final current = ref.read(playerPositionProvider).asData?.value ?? Duration.zero;
    final dur = ref.read(playerDurationProvider).asData?.value ?? Duration.zero;
    final ms = (current.inMilliseconds + seconds * 1000).clamp(0, dur.inMilliseconds);
    player.seek(Duration(milliseconds: ms));
  }
}

class _PlaylistNavRow extends StatelessWidget {
  final PlaylistQueue queue;
  final LoopMode repeatMode;
  final bool isPlaying;
  final dynamic player;
  final WidgetRef ref;

  const _PlaylistNavRow({
    required this.queue,
    required this.repeatMode,
    required this.isPlaying,
    required this.player,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _navButton(
            icon: Icons.skip_previous,
            tooltip: 'Previous',
            onPressed: queue.hasPrev ? () => _playPrevious() : null,
          ),
          const SizedBox(width: 8),
          _navButton(
            icon: Icons.shuffle,
            tooltip: 'Shuffle: ${queue.shuffled ? "On" : "Off"}',
            onPressed: () => _toggleShuffle(),
            isActive: queue.shuffled,
          ),
          const SizedBox(width: 8),
          _navButton(
            icon: _repeatIcon(repeatMode),
            tooltip: 'Repeat: ${repeatMode.name}',
            onPressed: () => _cycleRepeat(),
            isActive: repeatMode != LoopMode.off,
          ),
          const SizedBox(width: 8),
          _navButton(
            icon: Icons.skip_next,
            tooltip: 'Next',
            onPressed: () => _playNext(),
          ),
          const SizedBox(width: 8),
          _navButton(
            icon: Icons.playlist_play,
            tooltip: 'Playlist',
            onPressed: () => _showPlaylistSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 24,
      color: isActive ? Colors.cyan : Colors.white70,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  IconData _repeatIcon(LoopMode mode) => switch (mode) {
    LoopMode.off => Icons.repeat,
    LoopMode.one => Icons.repeat_one,
    LoopMode.all => Icons.repeat,
  };

  void _playNext() {
    final path = ref.read(playlistQueueProvider.notifier).next(repeatMode, true);
    if (path != null && path.isNotEmpty) {
      player.open(Media(path), play: true);
    }
  }

  void _playPrevious() {
    final path = ref.read(playlistQueueProvider.notifier).previous();
    if (path != null && path.isNotEmpty) {
      player.open(Media(path), play: true);
    }
  }

  void _toggleShuffle() {
    ref.read(shuffleEnabledProvider.notifier).toggle();
  }

  void _cycleRepeat() {
    ref.read(repeatModeProvider.notifier).cycle();
    final mode = ref.read(repeatModeProvider);
    ref.read(playerOverlayProvider.notifier).show(
      RepeatModeChange(mode.name),
    );
  }

  void _showPlaylistSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _PlaylistQueueSheet(queue: queue),
    );
  }
}

class _PlaylistQueueSheet extends StatelessWidget {
  final PlaylistQueue queue;

  const _PlaylistQueueSheet({required this.queue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Playlist Queue', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: queue.filePaths.length,
              itemBuilder: (_, i) => ListTile(
                leading: Icon(
                  i == queue.currentIndex ? Icons.play_circle_filled : Icons.movie_outlined,
                  color: i == queue.currentIndex ? theme.colorScheme.primary : null,
                ),
                title: Text(
                  queue.titles.isNotEmpty ? queue.titles[i] : queue.filePaths[i].split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: i == queue.currentIndex,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
