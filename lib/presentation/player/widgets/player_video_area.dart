import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../player_provider.dart';

class PlayerVideoArea extends ConsumerWidget {
  const PlayerVideoArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    return Video(controller: VideoController(player));
  }
}
