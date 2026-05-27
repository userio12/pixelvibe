import 'package:flutter/material.dart';

class VerticalBarShape extends SliderComponentShape {
  final double thumbHeight;
  final double thumbWidth;

  const VerticalBarShape({
    this.thumbHeight = 24,
    this.thumbWidth = 6,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: thumbWidth,
        height: thumbHeight,
      ),
      Radius.circular(thumbWidth / 2),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = sliderTheme.thumbColor ?? const Color(0xFF71C4D4),
    );
  }
}
