import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'player_updates.dart';

final playerOverlayProvider = NotifierProvider<PlayerOverlayNotifier, PlayerUpdates>(
  PlayerOverlayNotifier.new,
);

class PlayerOverlayNotifier extends Notifier<PlayerUpdates> {
  Timer? _dismissTimer;

  @override
  PlayerUpdates build() {
    ref.onDispose(() => _dismissTimer?.cancel());
    return const None();
  }

  void show(PlayerUpdates update) {
    _dismissTimer?.cancel();
    state = update;
    final ms = _dismissDuration(update);
    if (ms > 0) {
      _dismissTimer = Timer(Duration(milliseconds: ms), () {
        state = const None();
      });
    }
  }

  void dismiss() {
    _dismissTimer?.cancel();
    state = const None();
  }

  int _dismissDuration(PlayerUpdates update) => switch (update) {
    HorizontalSeek _ => 800,
    ShowText _ => 800,
    SpeedChange _ => 1500,
    AspectRatioChange _ => 1500,
    ZoomChange _ => 1500,
    RepeatModeChange _ => 1500,
    ShuffleChange _ => 1500,
    FrameInfo _ => 10000,
    None _ => 0,
  };
}

class PlayerOverlay extends ConsumerWidget {
  const PlayerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(playerOverlayProvider);
    final colors = PixelvibeColors.of(context);

    return switch (update) {
      None _ => const SizedBox.shrink(),
      HorizontalSeek(:final timeText, :final deltaText, :final isForward) =>
        _SeekOverlay(timeText: timeText, deltaText: deltaText, isForward: isForward, colors: colors),
      SpeedChange(:final speed) =>
        _TextOverlay(text: 'Speed: ${speed}x', colors: colors),
      AspectRatioChange(:final label) =>
        _TextOverlay(text: 'Aspect: $label', colors: colors),
      ZoomChange(:final zoom) =>
        _TextOverlay(text: 'Zoom: ${zoom.toStringAsFixed(1)}x', colors: colors),
      RepeatModeChange(:final label) =>
        _TextOverlay(text: 'Repeat: $label', colors: colors),
      ShuffleChange(:final enabled) =>
        _TextOverlay(text: enabled ? 'Shuffle: On' : 'Shuffle: Off', colors: colors),
      FrameInfo(:final frame, :final totalFrames) =>
        _TextOverlay(text: 'Frame $frame / $totalFrames', colors: colors),
      ShowText(:final message) =>
        _TextOverlay(text: message, colors: colors),
    };
  }
}

class _SeekOverlay extends StatelessWidget {
  final String timeText;
  final String deltaText;
  final bool isForward;
  final PixelvibeColors colors;

  const _SeekOverlay({
    required this.timeText,
    required this.deltaText,
    required this.isForward,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: colors.playerOverlayBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isForward ? Icons.fast_forward : Icons.fast_rewind,
                color: colors.playerOverlayText,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(deltaText, style: TextStyle(color: colors.playerOverlayText, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(width: 1, height: 24, color: colors.playerOverlayText.withValues(alpha: 0.3), margin: const EdgeInsets.symmetric(horizontal: 12)),
              Text(timeText, style: TextStyle(color: colors.playerOverlayText, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextOverlay extends StatelessWidget {
  final String text;
  final PixelvibeColors colors;

  const _TextOverlay({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: colors.playerOverlayBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(text, style: TextStyle(color: colors.playerOverlayText, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
