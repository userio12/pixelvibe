import 'package:flutter/material.dart';
import 'visual_feedback.dart';

class ModeIndicatorBar extends StatelessWidget {
  final double speed;
  final String? aspectLabel;
  final double? zoom;

  const ModeIndicatorBar({
    super.key,
    this.speed = 1.0,
    this.aspectLabel,
    this.zoom,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (speed != 1.0) {
      chips.add(ModeIndicator(icon: Icons.speed, label: '${speed}x', color: Colors.cyan));
    }
    if (aspectLabel != null) {
      chips.add(ModeIndicator(icon: Icons.aspect_ratio, label: aspectLabel!, color: Colors.orange));
    }
    if (zoom != null && zoom != 1.0) {
      chips.add(ModeIndicator(icon: Icons.zoom_in, label: '${zoom!.toStringAsFixed(1)}x', color: Colors.green));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.45,
      left: 16,
      child: Opacity(
        opacity: 0.9,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: chips,
        ),
      ),
    );
  }
}
