import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

final ambientModeProvider = NotifierProvider.autoDispose<AmbientModeNotifier, bool>(AmbientModeNotifier.new);

class AmbientModeNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool('ambient_mode', false);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool('ambient_mode', state);
  }
}

class AmbientGlow extends StatefulWidget {
  const AmbientGlow({super.key});

  @override
  State<AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<AmbientGlow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.6 + _controller.value * 0.3,
              colors: [
                primary.withValues(alpha: 0.25),
                tertiary.withValues(alpha: 0.12),
                primary.withValues(alpha: 0.04),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }
}
