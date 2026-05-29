import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../player_screen_provider.dart';
import '../../../utils/player_error_utils.dart';
import '../../../core/theme/app_theme_extensions.dart';

class PlayerErrorOverlay extends ConsumerWidget {
  final VoidCallback onRetry;
  const PlayerErrorOverlay({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = ref.watch(playerScreenProvider.select((s) => s.errorMessage));
    if (errorMessage == null) return const SizedBox.shrink();

    final friendlyMessage = PlayerErrorUtils.mapMpvError(errorMessage);
    final playerColors = PixelvibeColors.of(context);

    return Positioned.fill(
      child: Container(
        color: playerColors.playerErrorBg,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: playerColors.playerErrorIcon, size: 64),
            const SizedBox(height: 16),
            Text(
              'Playback Error',
              style: TextStyle(color: playerColors.playerErrorText, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              friendlyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: playerColors.playerControlSecondaryColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

