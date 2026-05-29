import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../player_screen_provider.dart';
import 'player_controls_bar.dart';

class PlayerBottomBar extends ConsumerWidget {
  const PlayerBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(playerScreenProvider);
    final visible = screenState.seekBarVisible;
    final controlsVisible = screenState.controlsVisible;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !visible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !controlsVisible,
                  child: const PlayerControlsBar(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
