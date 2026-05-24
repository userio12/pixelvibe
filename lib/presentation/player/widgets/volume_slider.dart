import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;

  const VolumeSlider({
    super.key,
    required this.volume,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = volume == 0
        ? Icons.volume_off
        : volume < 0.5
            ? Icons.volume_down
            : Icons.volume_up;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface),
        SizedBox(
          width: 120,
          child: Slider(
            value: volume,
            onChanged: onChanged,
            min: 0,
            max: 1,
            divisions: 100,
          ),
        ),
      ],
    );
  }
}
