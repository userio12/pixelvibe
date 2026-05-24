import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final VoidCallback onPlayPause;
  final VoidCallback onSkipBack;
  final VoidCallback onSkipForward;
  final bool isPlaying;

  const PlayerControls({
    super.key,
    required this.onPlayPause,
    required this.onSkipBack,
    required this.onSkipForward,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 32,
          onPressed: onSkipBack,
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer,
          ),
          child: IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, fill: 1),
            iconSize: 40,
            onPressed: onPlayPause,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.forward_10),
          iconSize: 32,
          onPressed: onSkipForward,
        ),
      ],
    );
  }
}
