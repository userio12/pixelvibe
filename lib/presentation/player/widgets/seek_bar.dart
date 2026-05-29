import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../settings/settings_provider.dart';

class SeekBar extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  Duration? _dragPosition;
  bool _isDragging = false;

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showRemaining = ref.watch(showTimeRemainingProvider);
    final style = ref.watch(seekbarStyleProvider);
    
    final displayPosition = _isDragging && _dragPosition != null ? _dragPosition! : widget.position;
    
    final totalMs = widget.duration.inMilliseconds.toDouble();
    final posMs = displayPosition.inMilliseconds.toDouble().clamp(0, totalMs);
    final progress = totalMs > 0 ? posMs / totalMs : 0.0;

    final rightText = showRemaining
        ? '-${_format(widget.duration - displayPosition)}'
        : _format(widget.duration);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style == SeekbarStyle.standard)
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
                onChangeStart: (_) {
                  HapticFeedback.lightImpact();
                  setState(() => _isDragging = true);
                },
                onChangeEnd: (v) {
                  HapticFeedback.mediumImpact();
                  setState(() => _isDragging = false);
                  widget.onSeek(Duration(milliseconds: (v * totalMs).round()));
                },
                onChanged: (v) => setState(() => _dragPosition = Duration(milliseconds: (v * totalMs).round())),
              ),
            ),
          ),
        if (style == SeekbarStyle.wavy)
          _WavySeekbar(progress: progress, totalMs: totalMs, onSeek: widget.onSeek),
        if (style == SeekbarStyle.thick)
          _ThickSeekbar(progress: progress, totalMs: totalMs, onSeek: widget.onSeek),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(displayPosition), style: theme.textTheme.labelSmall),
              Text(rightText, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _WavySeekbar extends StatelessWidget {
  final double progress;
  final double totalMs;
  final ValueChanged<Duration> onSeek;

  const _WavySeekbar({required this.progress, required this.totalMs, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Seek position',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTapDown: (d) {
            HapticFeedback.lightImpact();
            onSeek(Duration(milliseconds: (d.localPosition.dx / (MediaQuery.of(context).size.width - 32) * totalMs).round().clamp(0, totalMs.toInt())));
          },
          child: CustomPaint(
            size: const Size(double.infinity, 32),
            painter: _WavyPainter(
              progress: progress,
              color: PixelvibeColors.of(context).playerControlActiveColor,
              trackColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}

class _WavyPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _WavyPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final path = Path();
    const waveCount = 5;
    final waveWidth = size.width / waveCount;
    final amplitude = 4.0;

    path.moveTo(0, size.height / 2);

    for (var i = 0; i < waveCount; i++) {
      final x0 = i * waveWidth;
      final x1 = x0 + waveWidth / 2;
      final x2 = x0 + waveWidth;
      path.cubicTo(x1 - waveWidth / 4, size.height / 2 - amplitude, x1 + waveWidth / 4, size.height / 2 + amplitude, x2, size.height / 2);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final splitX = size.width * progress;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, splitX, size.height));
    paint.color = color;
    canvas.drawPath(path, paint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(splitX, 0, size.width - splitX, size.height));
    paint.color = trackColor;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WavyPainter old) => old.progress != progress;
}

class _ThickSeekbar extends StatelessWidget {
  final double progress;
  final double totalMs;
  final ValueChanged<Duration> onSeek;

  const _ThickSeekbar({required this.progress, required this.totalMs, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Seek position',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTapDown: (d) {
            HapticFeedback.lightImpact();
            onSeek(Duration(milliseconds: (d.localPosition.dx / (MediaQuery.of(context).size.width - 32) * totalMs).round().clamp(0, totalMs.toInt())));
          },
          child: CustomPaint(
            size: const Size(double.infinity, 16),
            painter: _ThickPainter(
              progress: progress,
              color: PixelvibeColors.of(context).playerControlActiveColor,
              trackColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThickPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _ThickPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final height = size.height;
    final radius = height / 2;
    final roundedRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, height), Radius.circular(radius));
    canvas.drawRRect(roundedRect, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final progressWidth = size.width * progress;
    if (progressWidth > 0) {
      final progressRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, progressWidth, height), Radius.circular(radius));
      canvas.drawRRect(progressRect, progressPaint);
    }

    final thumbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(progressWidth.clamp(radius, size.width - radius), height / 2), radius + 2, thumbPaint);
  }

  @override
  bool shouldRepaint(_ThickPainter old) => old.progress != progress;
}
