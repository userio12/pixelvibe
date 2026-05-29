import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../ambient_glow.dart';
import '../player_provider.dart';
import '../subtitle_settings_provider.dart';

class PlayerVideoArea extends ConsumerWidget {
  final String? filePath;
  const PlayerVideoArea({super.key, this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final subtitleConfig = ref.watch(subtitleViewConfigProvider);
    final ambientMode = ref.watch(ambientModeProvider);
    
    // In test environment, skip native Video widget to avoid missing DLL exceptions
    final bool isTest = kDebugMode && Platform.environment.containsKey('FLUTTER_TEST');

    return Stack(
      children: [
        if (filePath != null)
          Positioned.fill(
            child: Hero(
              tag: filePath!,
              child: const SizedBox.shrink(),
            ),
          ),
        if (ambientMode) const Positioned.fill(child: AmbientGlow()),
        Positioned.fill(
          child: isTest
              ? const Center(child: Icon(Icons.play_circle_outline, size: 100, color: Colors.white24))
              : Video(
                  controller: VideoController(player),
                  subtitleViewConfiguration: subtitleConfig,
                ),
        ),
      ],
    );
  }
}
