import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/settings_provider.dart';
import '../player_provider.dart';
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
