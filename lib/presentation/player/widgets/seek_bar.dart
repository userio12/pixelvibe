import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/settings_provider.dart';

class SeekBar extends ConsumerWidget {
  final Duration position;
  final Duration duration;
  final double bufferProgress;
  final ValueChanged<Duration> onSeek;

  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.bufferProgress = 0.0,
    required this.onSeek,
  });

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showRemaining = ref.watch(showTimeRemainingProvider);
    final totalMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.toDouble().clamp(0, totalMs);
    final progress = totalMs > 0 ? posMs / totalMs : 0.0;

    final rightText = showRemaining
        ? '-${_format(duration - position)}'
        : _format(duration);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Semantics(
            label: 'Seek position',
            child: Slider(
              value: progress,
              onChanged: (v) => onSeek(Duration(milliseconds: (v * totalMs).round())),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(position), style: theme.textTheme.labelSmall),
              Text(rightText, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}
