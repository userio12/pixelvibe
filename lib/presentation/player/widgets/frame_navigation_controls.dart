import 'package:flutter/material.dart';

class FrameNavigationControls extends StatelessWidget {
  final VoidCallback onStepBack;
  final VoidCallback onStepForward;

  const FrameNavigationControls({
    super.key,
    required this.onStepBack,
    required this.onStepForward,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white70),
          iconSize: 20,
          tooltip: 'Frame back',
          onPressed: onStepBack,
        ),
        const SizedBox(width: 4),
        Text(
          'Frame',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white70),
          iconSize: 20,
          tooltip: 'Frame forward',
          onPressed: onStepForward,
        ),
      ],
    );
  }
}
