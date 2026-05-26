import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sleep_timer_provider.dart';

class SleepTimerSheet extends ConsumerWidget {
  const SleepTimerSheet({super.key});

  static const _presets = [
    ('15 minutes', 900),
    ('30 minutes', 1800),
    ('45 minutes', 2700),
    ('60 minutes', 3600),
    ('90 minutes', 5400),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(sleepTimerProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Sleep Timer', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: [
                ..._presets.map(
                  (p) => ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(p.$1),
                    trailing: timer.state == SleepTimerState.counting && timer.totalSeconds == p.$2
                        ? Text('${timer.formattedRemaining} remaining', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12))
                        : null,
                    onTap: () {
                      ref.read(sleepTimerProvider.notifier).startCountdown(p.$2);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.last_page),
                  title: const Text('End of file'),
                  subtitle: const Text('Stop when current file ends'),
                  trailing: timer.state == SleepTimerState.endOfFile
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(sleepTimerProvider.notifier).startEndOfFile();
                    Navigator.of(context).pop();
                  },
                ),
                if (timer.state != SleepTimerState.inactive) ...[
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
                    title: Text('Cancel timer', style: TextStyle(color: theme.colorScheme.error)),
                    onTap: () {
                      ref.read(sleepTimerProvider.notifier).cancel();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
