import 'package:flutter/material.dart';
import '../theme/app_animations.dart';
import '../theme/app_theme_extensions.dart';

class _StateLayout extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const _StateLayout({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            const SizedBox(height: 24),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = PixelvibeColors.of(context);
    return PulsingOpacity(
      child: _StateLayout(
        icon: Icon(icon, size: 48, color: colors.playerOverlayText.withValues(alpha: 0.7)),
        title: title,
        subtitle: subtitle,
        action: action,
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  final String title;
  final String? subtitle;

  const LoadingState({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PulsingOpacity(
      child: _StateLayout(
        icon: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 3, color: theme.colorScheme.primary),
        ),
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}

class PermissionDeniedState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final String? helpLink;

  const PermissionDeniedState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.helpLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StateLayout(
      icon: Icon(Icons.warning_amber_rounded, size: 48, color: theme.colorScheme.error),
      title: title,
      subtitle: subtitle,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: onButtonPressed,
            icon: const Icon(Icons.settings),
            label: Text(buttonLabel),
          ),
          if (helpLink != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: Text(helpLink!, style: theme.textTheme.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}
