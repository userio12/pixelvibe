import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../player_screen_provider.dart';
import '../control_layout_provider.dart';
import 'player_button_widget.dart';

class PlayerTopBar extends ConsumerWidget {
  final String filePath;
  const PlayerTopBar({super.key, required this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(playerScreenProvider.select((s) => s.controlsVisible));
    final layout = ref.watch(controlLayoutProvider);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 4,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !visible,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ...layout.topLeft.map((btn) => PlayerButtonWidget(btn: btn, filePath: filePath)),
                const Spacer(),
                ...layout.topRight.map((btn) => PlayerButtonWidget(btn: btn, filePath: filePath)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
