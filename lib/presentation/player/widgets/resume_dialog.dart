import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/format_utils.dart';

class ResumeDialog extends StatelessWidget {
  final String filePath;
  final String title;
  final int positionMs;

  const ResumeDialog({
    super.key,
    required this.filePath,
    required this.title,
    required this.positionMs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Resume Playback?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'Resume from ${formatDuration(positionMs)}?',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            final encoded = Uri.encodeComponent(filePath);
            context.push('/player/$encoded');
          },
          child: const Text('Start Over'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            final encoded = Uri.encodeComponent(filePath);
            context.push('/player/$encoded');
          },
          child: const Text('Resume'),
        ),
      ],
    );
  }
}
