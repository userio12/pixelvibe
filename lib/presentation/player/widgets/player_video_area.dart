import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../ambient_glow.dart';
import '../player_provider.dart';
import '../subtitle_settings_provider.dart';

class PlayerVideoArea extends ConsumerWidget {
  const PlayerVideoArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final subtitleConfig = ref.watch(subtitleViewConfigProvider);
    final ambientMode = ref.watch(ambientModeProvider);
    return Stack(
      children: [
        if (ambientMode) const Positioned.fill(child: AmbientGlow()),
        Positioned.fill(
          child: Video(
            controller: VideoController(player),
            subtitleViewConfiguration: subtitleConfig,
          ),
        ),
      ],
    );
  }
}
