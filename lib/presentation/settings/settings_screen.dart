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
    final fontSize = ref.watch(subtitleFontSizeProvider);
    final hwdec = ref.watch(hwdecProvider);
    final gpuApi = ref.watch(gpuApiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionHeader(title: 'Appearance'),
          _ThemeTile(themeMode: themeMode),
          SwitchListTile(
            title: const Text('Dynamic color'),
            subtitle: const Text('Use Material You dynamic color'),
            value: dynamicColor,
            onChanged: (_) => ref.read(dynamicColorProvider.notifier).toggle(),
          ),
          const Divider(height: 32),

          _SectionHeader(title: 'Playback'),
          _SpeedTile(defaultSpeed: defaultSpeed),
          SwitchListTile(
            title: const Text('Resume playback'),
            subtitle: const Text('Save and resume position'),
            value: resume,
            onChanged: (_) => ref.read(resumePlaybackProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Auto PiP'),
            subtitle: const Text('Enter PiP when leaving the app'),
            value: autoPip,
            onChanged: (_) => ref.read(autoPipProvider.notifier).toggle(),
          ),
          ListTile(
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
          const Divider(height: 32),

          _SectionHeader(title: 'Subtitles'),
          ListTile(
            title: const Text('Font size'),
            subtitle: Text('${fontSize.round()}pt'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: fontSize,
                min: 10,
                max: 36,
                divisions: 13,
                onChanged: (v) => ref.read(subtitleFontSizeProvider.notifier).update(v),
              ),
            ),
          ),
          const Divider(height: 32),

          _SectionHeader(title: 'Decoder'),
          ListTile(
            title: const Text('Hardware decoding'),
            trailing: DropdownButton<String>(
              value: hwdec,
              items: const [
                DropdownMenuItem(value: 'auto', child: Text('Auto')),
                DropdownMenuItem(value: 'yes', child: Text('Force on')),
                DropdownMenuItem(value: 'no', child: Text('Force off')),
              ],
              onChanged: (v) => ref.read(hwdecProvider.notifier).update(v ?? 'auto'),
            ),
          ),
          ListTile(
            title: const Text('GPU API'),
            trailing: DropdownButton<String>(
              value: gpuApi,
              items: const [
                DropdownMenuItem(value: 'auto', child: Text('Auto')),
                DropdownMenuItem(value: 'vulkan', child: Text('Vulkan')),
                DropdownMenuItem(value: 'opengl', child: Text('OpenGL')),
              ],
              onChanged: (v) => ref.read(gpuApiProvider.notifier).update(v ?? 'auto'),
            ),
          ),
          const Divider(height: 32),

          _SectionHeader(title: 'Advanced'),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('mpv.conf'),
            subtitle: const Text('Load and edit mpv configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editConfig(context, 'mpv.conf'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('input.conf'),
            subtitle: const Text('Load and edit mpv input bindings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editConfig(context, 'input.conf'),
          ),
          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text('Lua scripts'),
            subtitle: const Text('Browse and load scripts into mpv'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _browseScripts(context),
          ),
          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About pixelvibe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }

  void _editConfig(BuildContext context, String filename) {
    // TODO: Implement config file picker + editor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$filename editor coming soon')),
    );
  }

  void _browseScripts(BuildContext context) {
    // TODO: Implement Lua script browser
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lua script browser coming soon')),
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
    return ListTile(
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
    );
  }
}

class _SpeedTile extends ConsumerWidget {
  final double defaultSpeed;
  const _SpeedTile({required this.defaultSpeed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0];
    return ListTile(
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
    );
  }
}
