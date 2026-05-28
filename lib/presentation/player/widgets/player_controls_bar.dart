import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../settings/settings_provider.dart';
import '../ab_loop_provider.dart';
import '../control_layout_provider.dart';
import '../player_button.dart';
import '../player_provider.dart';
import '../playlist_queue_provider.dart';
import '../player_overlay.dart';
import '../player_updates.dart';
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
        _ConfigurableCenterControls(isPlaying: isPlaying),
      ],
    );
  }

}

class _ConfigurableCenterControls extends ConsumerWidget {
  final bool isPlaying;

  const _ConfigurableCenterControls({required this.isPlaying});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(controlLayoutProvider);
    final buttons = layout.bottomCenter;
    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final btn in buttons) _buildCenterButton(context, ref, btn),
      ],
    );
  }

  Widget _buildCenterButton(BuildContext context, WidgetRef ref, PlayerButton btn) {
    switch (btn) {
      case PlayerButton.skipBack:
        return _iconBtn(Icons.replay_10, btn.tooltip, () {
          final interval = ref.read(skipIntervalProvider);
          _skip(ref, -interval);
        });
      case PlayerButton.playPause:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, fill: 1),
              iconSize: 40,
              onPressed: () {
                HapticFeedback.selectionClick();
                final p = ref.read(playerProvider);
                if (isPlaying) { p.pause(); } else { p.play(); }
              },
            ),
          ),
        );
      case PlayerButton.skipForward:
        return _iconBtn(Icons.forward_10, btn.tooltip, () {
          final interval = ref.read(skipIntervalProvider);
          _skip(ref, interval);
        });
      case PlayerButton.frameNav:
        if (isPlaying) return const SizedBox.shrink();
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
      case PlayerButton.repeat:
        return Consumer(
          builder: (_, ref, child) {
            final mode = ref.watch(repeatModeProvider);
            final icon = switch (mode) {
              LoopMode.off => Icons.repeat,
              LoopMode.one => Icons.repeat_one,
              LoopMode.all => Icons.repeat,
            };
            return _iconBtn(icon, 'Repeat: ${mode.name}', () {
              ref.read(repeatModeProvider.notifier).cycle();
              ref.read(playerOverlayProvider.notifier).show(RepeatModeChange(ref.read(repeatModeProvider).name));
            }, active: ref.read(repeatModeProvider) != LoopMode.off);
          },
        );
      case PlayerButton.shuffle:
        return Consumer(
          builder: (_, ref, child) {
            final shuffled = ref.watch(shuffleEnabledProvider);
            return _iconBtn(Icons.shuffle, 'Shuffle: ${shuffled ? "On" : "Off"}',
              () => ref.read(shuffleEnabledProvider.notifier).toggle(),
              active: shuffled,
            );
          },
        );
      case PlayerButton.playlist:
        return _iconBtn(Icons.playlist_play, btn.tooltip, () {
          final queue = ref.read(playlistQueueProvider);
          showModalBottomSheet(
            context: context,
            builder: (_) => _PlaylistQueueSheet(queue: queue),
          );
        });
      case PlayerButton.volume:
        return SizedBox(
          width: 120,
          child: VolumeSlider(
            volume: ref.watch(playerVolumeProvider).asData?.value ?? 1.0,
            onChanged: (v) => ref.read(playerProvider).setVolume(v),
          ),
        );
      case PlayerButton.abLoop:
        return Consumer(
          builder: (_, ref, child) {
            final ab = ref.watch(abLoopProvider);
            return _iconBtn(ab.isActive ? Icons.loop : Icons.loop_outlined, btn.tooltip, () {
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
            }, active: ab.isActive);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onPressed, {bool active = false}) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 28,
      color: active ? Colors.cyan : Colors.white70,
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      tooltip: tooltip,
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
    final q = ref.read(playlistQueueProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => _PlaylistQueueSheet(queue: q),
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
