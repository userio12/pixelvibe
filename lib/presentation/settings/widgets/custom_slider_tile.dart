import 'package:flutter/material.dart';
import 'vertical_bar_thumb.dart';

class CustomSliderTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;

  const CustomSliderTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFF90959A),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF71C4D4),
              inactiveTrackColor: const Color(0xFF2C3136),
              trackHeight: 6,
              thumbColor: const Color(0xFF71C4D4),
              thumbShape: const VerticalBarShape(),
              overlayShape: SliderComponentShape.noOverlay,
              activeTickMarkColor: const Color(0xFF71C4D4),
              inactiveTickMarkColor: const Color(0xFF2C3136),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
