import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final dynamicColor = ref.watch(dynamicColorProvider);
    final defaultSpeed = ref.watch(defaultSpeedProvider);
    final resume = ref.watch(resumePlaybackProvider);
    final autoPip = ref.watch(autoPipProvider);
    final skipInterval = ref.watch(skipIntervalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Done',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionHeader(title: 'Appearance'),
          _ThemeTile(themeMode: themeMode),
          Semantics(
            label: 'Dynamic color',
            child: SwitchListTile(
              title: const Text('Dynamic color'),
              subtitle: const Text('Use Material You dynamic color'),
              value: dynamicColor,
              onChanged: (_) => ref.read(dynamicColorProvider.notifier).toggle(),
            ),
          ),
          const Divider(height: 32),

          _SectionHeader(title: 'Playback'),
          _SpeedTile(defaultSpeed: defaultSpeed),
          Semantics(
            label: 'Resume playback',
            child: SwitchListTile(
              title: const Text('Resume playback'),
              subtitle: const Text('Save and resume position'),
              value: resume,
              onChanged: (_) => ref.read(resumePlaybackProvider.notifier).toggle(),
            ),
          ),
          Semantics(
            label: 'Auto PiP',
            child: SwitchListTile(
              title: const Text('Auto PiP'),
              subtitle: const Text('Enter PiP when leaving the app'),
              value: autoPip,
              onChanged: (_) => ref.read(autoPipProvider.notifier).toggle(),
            ),
          ),
          Semantics(
            label: 'Skip interval',
            child: ListTile(
              title: const Text('Skip interval'),
              trailing: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 5, label: Text('5s')),
                  ButtonSegment(value: 10, label: Text('10s')),
                  ButtonSegment(value: 30, label: Text('30s')),
                ],
                selected: {skipInterval},
                onSelectionChanged: (s) => ref.read(skipIntervalProvider.notifier).update(s.first),
                showSelectedIcon: false,
              ),
            ),
          ),
          const Divider(height: 32),

          Semantics(
            label: 'About pixelvibe',
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About pixelvibe'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/about'),
            ),
          ),
        ],
      ),
    );
  }

}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  final ThemeMode themeMode;
  const _ThemeTile({required this.themeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Theme mode',
      child: ListTile(
        title: const Text('Theme mode'),
        trailing: SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto)),
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
          ],
          selected: {themeMode},
          onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).update(s.first),
          showSelectedIcon: false,
        ),
      ),
    );
  }
}

class _SpeedTile extends ConsumerWidget {
  final double defaultSpeed;
  const _SpeedTile({required this.defaultSpeed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0];
    return Semantics(
      label: 'Default speed',
      child: ListTile(
        title: const Text('Default speed'),
        subtitle: Text('${defaultSpeed}x'),
        trailing: SizedBox(
          width: 200,
          child: DropdownButton<double>(
            value: defaultSpeed,
            isExpanded: true,
            items: speeds.map((s) => DropdownMenuItem(value: s, child: Text('${s}x'))).toList(),
            onChanged: (v) => ref.read(defaultSpeedProvider.notifier).update(v ?? 1.0),
          ),
        ),
      ),
    );
  }
}
