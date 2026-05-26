import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/platform_helper.dart';
import '../player/gesture_config_provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final dynamicColor = ref.watch(dynamicColorProvider);
    final amoled = ref.watch(amoledModeProvider);
    final contrast = ref.watch(contrastLevelProvider);
    final defaultSpeed = ref.watch(defaultSpeedProvider);
    final resume = ref.watch(resumePlaybackProvider);
    final autoPip = ref.watch(autoPipProvider);
    final skipInterval = ref.watch(skipIntervalProvider);
    final autoplayNext = ref.watch(autoplayNextProvider);
    final showRemaining = ref.watch(showTimeRemainingProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final orientation = ref.watch(playerOrientationProvider);
    final horizontalSwipe = ref.watch(horizontalSwipeSeekProvider);
    final brightnessGesture = ref.watch(brightnessGestureProvider);
    final volumeGesture = ref.watch(volumeGestureProvider);
    final pinchZoom = ref.watch(pinchToZoomGestureProvider);
    final doubleTap = ref.watch(doubleTapSeekProvider);
    final sensitivity = ref.watch(gestureSensitivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search settings...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (_matches(['Theme', 'Dynamic color', 'AMOLED', 'Contrast', 'Appearance']))
                  _SectionHeader(title: 'Appearance'),
                if (_matches(['Theme']))
                  _ThemeTile(themeMode: themeMode),
                if (_matches(['Dynamic color']))
                  _buildSwitch('Dynamic color', 'Material You dynamic color', dynamicColor, () => ref.read(dynamicColorProvider.notifier).toggle()),
                if (_matches(['AMOLED']))
                  _buildSwitch('AMOLED dark mode', 'Pure black dark theme', amoled, () => ref.read(amoledModeProvider.notifier).toggle()),
                if (_matches(['Contrast']))
                  _buildSlider('Contrast level', contrast.toStringAsFixed(1), contrast, -1.0, 1.0, 20, (v) => ref.read(contrastLevelProvider.notifier).update(v)),
                if (_matches(['Appearance', 'Theme', 'Dynamic', 'AMOLED', 'Contrast']))
                  const Divider(height: 32),

                if (_matches(['Speed', 'Resume', 'PiP', 'Skip', 'Autoplay', 'Time', 'Reduce', 'Playback']))
                  _SectionHeader(title: 'Playback'),
                if (_matches(['speed']))
                  _SpeedTile(defaultSpeed: defaultSpeed),
                if (_matches(['Resume']))
                  _buildSwitch('Resume playback', 'Save and resume position', resume, () => ref.read(resumePlaybackProvider.notifier).toggle()),
                if (_matches(['Auto PiP']))
                  _buildSwitch('Auto PiP', 'Enter PiP when leaving', autoPip, () => ref.read(autoPipProvider.notifier).toggle()),
                if (_matches(['Skip']))
                  _buildSkipInterval(skipInterval),
                if (_matches(['Autoplay']))
                  _buildSwitch('Autoplay next', 'Auto-play next in playlist', autoplayNext, () => ref.read(autoplayNextProvider.notifier).toggle()),
                if (_matches(['Time remaining']))
                  _buildSwitch('Show time remaining', 'Show remaining instead of total', showRemaining, () => ref.read(showTimeRemainingProvider.notifier).toggle()),
                if (_matches(['Reduce motion']))
                  _buildSwitch('Reduce motion', 'Minimize animations', reduceMotion, () => ref.read(reduceMotionProvider.notifier).toggle()),
                if (_matches(['Playback', 'Speed', 'Resume', 'PiP', 'Skip', 'Autoplay', 'Time', 'Reduce']))
                  const Divider(height: 32),

                if (_matches(['Gesture', 'Swipe', 'Brightness', 'Volume', 'Pinch', 'Double', 'Sensitivity']))
                  _SectionHeader(title: 'Gestures'),
                if (_matches(['Swipe']))
                  _buildSwitch('Horizontal swipe seek', 'Swipe left/right to seek', horizontalSwipe, () => ref.read(horizontalSwipeSeekProvider.notifier).toggle()),
                if (_matches(['Brightness']))
                  _buildSwitch('Brightness gesture', 'Swipe left edge to adjust', brightnessGesture, () => ref.read(brightnessGestureProvider.notifier).toggle()),
                if (_matches(['Volume']))
                  _buildSwitch('Volume gesture', 'Swipe right edge to adjust', volumeGesture, () => ref.read(volumeGestureProvider.notifier).toggle()),
                if (_matches(['Pinch']))
                  _buildSwitch('Pinch to zoom', 'Pinch gesture for zoom', pinchZoom, () => ref.read(pinchToZoomGestureProvider.notifier).toggle()),
                if (_matches(['Double']))
                  _buildSwitch('Double-tap seek', 'Double-tap sides to seek', doubleTap, () => ref.read(doubleTapSeekProvider.notifier).toggle()),
                if (_matches(['Sensitivity']))
                  _buildSlider('Swipe sensitivity', sensitivity.toStringAsFixed(1), sensitivity, 0.5, 2.0, 15, (v) => ref.read(gestureSensitivityProvider.notifier).update(v)),
                if (_matches(['Gesture', 'Swipe', 'Brightness', 'Volume', 'Pinch', 'Double', 'Sensitivity']))
                  const Divider(height: 32),

                if (_matches(['Orientation']))
                  _buildOrientation(orientation),
                if (_matches(['Orientation']))
                  const Divider(height: 32),

                if (_matches(['About']))
                  _SectionHeader(title: 'Info'),
                if (_matches(['About']))
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
          ),
        ],
      ),
    );
  }

  bool _matches(List<String> keywords) {
    if (_searchQuery.isEmpty) return true;
    return keywords.any((k) => k.toLowerCase().contains(_searchQuery));
  }

  Widget _buildSwitch(String title, String subtitle, bool value, VoidCallback onChanged) {
    final matches = _searchQuery.isEmpty || title.toLowerCase().contains(_searchQuery) || subtitle.toLowerCase().contains(_searchQuery);
    if (!matches) return const SizedBox.shrink();
    return Semantics(
      label: title,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: (_) => onChanged(),
      ),
    );
  }

  Widget _buildSlider(String title, String display, double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    final matches = _searchQuery.isEmpty || title.toLowerCase().contains(_searchQuery);
    if (!matches) return const SizedBox.shrink();
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: 160,
        child: Row(
          children: [
            Expanded(
              child: Slider(value: value.clamp(min, max), min: min, max: max, divisions: divisions, onChanged: onChanged),
            ),
            SizedBox(width: 32, child: Text(display, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipInterval(int skipInterval) {
    if (!_matches(['skip'])) return const SizedBox.shrink();
    return Semantics(
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
    );
  }

  Widget _buildOrientation(PlayerOrientation orientation) {
    if (!_matches(['orientation'])) return const SizedBox.shrink();
    return Semantics(
      label: 'Player orientation',
      child: ListTile(
        title: const Text('Player orientation'),
        subtitle: Text(orientation.name),
        trailing: SegmentedButton<PlayerOrientation>(
          segments: const [
            ButtonSegment(value: PlayerOrientation.free, icon: Icon(Icons.screen_rotation), label: Text('Free')),
            ButtonSegment(value: PlayerOrientation.landscape, icon: Icon(Icons.landscape), label: Text('Land')),
            ButtonSegment(value: PlayerOrientation.portrait, icon: Icon(Icons.portrait), label: Text('Port')),
          ],
          selected: {orientation},
          onSelectionChanged: (s) => ref.read(playerOrientationProvider.notifier).setOrientation(s.first),
          showSelectedIcon: false,
        ),
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
