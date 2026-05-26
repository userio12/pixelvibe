import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../services/logger.dart';
import '../../utils/platform_helper.dart';
import '../player/gesture_config_provider.dart';
import '../player/video_quality_provider.dart';
import '../player/widgets/control_layout_editor.dart';
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
                if (_matches(['Seekbar']))
                  _buildSeekbarStyle(),
                if (_matches(['Close after end']))
                  _buildSwitch('Close after end', 'Close player when video ends', ref.watch(preferencesServiceProvider).getCloseAfterEnd(), () {
                    final prefs = ref.read(preferencesServiceProvider);
                    prefs.setCloseAfterEnd(!prefs.getCloseAfterEnd());
                  }),
                if (_matches(['Watched']))
                  _buildSlider('Watched threshold', '${ref.watch(preferencesServiceProvider).getWatchedThreshold()}%', ref.watch(preferencesServiceProvider).getWatchedThreshold().toDouble(), 50, 100, 10, (v) {
                    ref.read(preferencesServiceProvider).setWatchedThreshold(v.round());
                  }),
                if (_matches(['Control layout']))
                  ListTile(
                    leading: const Icon(Icons.grid_view),
                    title: const Text('Control layout'),
                    subtitle: const Text('Customize player buttons'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => const ControlLayoutEditor(),
                    ),
                  ),
                if (_matches(['Playback', 'Speed', 'Resume', 'PiP', 'Skip', 'Autoplay', 'Time', 'Reduce', 'Close', 'Watched', 'Control']))
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
                if (_matches(['Audio', 'Normalize', 'Channels']))
                  _SectionHeader(title: 'Audio'),
                if (_matches(['Audio background']))
                  _buildSwitch('Audio background', 'Keep playing with notification when leaving', ref.watch(audioBackgroundProvider), () => ref.read(audioBackgroundProvider.notifier).toggle()),
                if (_matches(['Normalize']))
                  _buildSwitch('Volume normalization', 'Dynamic audio normalization (dynaudnorm)', ref.watch(volumeNormalizationProvider), () => ref.read(volumeNormalizationProvider.notifier).toggle()),
                if (_matches(['Channels']))
                  _buildAudioChannels(),
                if (_matches(['Audio', 'Background', 'Normalize', 'Channels']))
                  const Divider(height: 32),

                if (_matches(['Video', 'Hwdec', 'Decoder', 'Gpu', 'Seek', 'Mirror', 'Flip', 'Subs']))
                  _SectionHeader(title: 'Video'),
                if (_matches(['Hwdec']))
                  _buildHwdec(),
                if (_matches(['Gpu']))
                  _buildGpuApi(),
                if (_matches(['Seek']))
                  _buildSwitch('Precise seeking', 'hr-seek frame-accurate jumps', ref.watch(hrSeekProvider), () => ref.read(hrSeekProvider.notifier).toggle()),
                if (_matches(['Mirror']))
                  _buildSwitch('Mirror (hflip)', '', ref.watch(mirrorProvider), () => ref.read(mirrorProvider.notifier).toggle()),
                if (_matches(['Flip']))
                  _buildSwitch('Flip (vflip)', '', ref.watch(flipProvider), () => ref.read(flipProvider.notifier).toggle()),
                if (_matches(['Subs']))
                  _buildSwitch('Subtitles in screenshot', 'subs-with-subs', ref.watch(screenshotSubsProvider), () => ref.read(screenshotSubsProvider.notifier).toggle()),
                if (_matches(['Video', 'Hwdec', 'Decoder', 'Gpu', 'Seek', 'Mirror', 'Flip', 'Subs']))
                  const Divider(height: 32),

                if (_matches(['Update', 'Auto.*update']))
                  _buildSwitch('Auto-update check', 'Check for updates on startup', ref.watch(preferencesServiceProvider).getAutoUpdateCheck(), () async {
                    await ref.read(preferencesServiceProvider).setAutoUpdateCheck(!ref.read(preferencesServiceProvider).getAutoUpdateCheck());
                  }),
                if (_matches(['Update', 'Auto.*update']))
                  const Divider(height: 32),

                if (_matches(['HTTP headers', 'Headers']))
                  _buildHttpHeaders(),
                if (_matches(['HTTP headers', 'Headers']))
                  const Divider(height: 32),

                if (_matches(['Export', 'Import', 'Settings']))
                  _SectionHeader(title: 'Settings Data'),
                if (_matches(['Export']))
                  ListTile(
                    leading: const Icon(Icons.file_upload_outlined),
                    title: const Text('Export settings'),
                    subtitle: const Text('Save settings to JSON file'),
                    onTap: () => _exportSettings(context),
                  ),
                if (_matches(['Import']))
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined),
                    title: const Text('Import settings'),
                    subtitle: const Text('Load settings from JSON file'),
                    onTap: () => _importSettings(context),
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

  Future<void> _exportSettings(BuildContext context) async {
    try {
      final prefs = ref.read(preferencesServiceProvider);
      final json = prefs.exportToJson();
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export settings',
        fileName: 'pixelvibe_settings.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return;
      await File(result).writeAsString(json);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings exported to $result')),
        );
      }
    } catch (e) {
      Logger.error('Export settings error', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importSettings(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;
      final json = await File(path).readAsString();
      final prefs = ref.read(preferencesServiceProvider);
      await prefs.importFromJson(json);
      ref.invalidate(preferencesServiceProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings imported. Restart the app for all changes to take effect.')),
        );
      }
    } catch (e) {
      Logger.error('Import settings error', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Widget _buildSeekbarStyle() {
    if (!_matches(['seekbar'])) return const SizedBox.shrink();
    final style = ref.watch(seekbarStyleProvider);
    return Semantics(
      label: 'Seekbar style',
      child: ListTile(
        title: const Text('Seekbar style'),
        trailing: SegmentedButton<SeekbarStyle>(
          segments: const [
            ButtonSegment(value: SeekbarStyle.standard, icon: Icon(Icons.bar_chart), label: Text('Std')),
            ButtonSegment(value: SeekbarStyle.wavy, icon: Icon(Icons.waves), label: Text('Wave')),
            ButtonSegment(value: SeekbarStyle.thick, icon: Icon(Icons.bubble_chart), label: Text('Thick')),
          ],
          selected: {style},
          onSelectionChanged: (s) => ref.read(seekbarStyleProvider.notifier).update(s.first),
          showSelectedIcon: false,
        ),
      ),
    );
  }

  Widget _buildAudioChannels() {
    if (!_matches(['channels'])) return const SizedBox.shrink();
    final current = ref.watch(audioChannelsProvider);
    const options = ['auto', 'stereo', 'surround', '5.1', '7.1'];
    return ListTile(
      title: const Text('Audio channels'),
      trailing: DropdownButton<String>(
        value: current,
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) => ref.read(audioChannelsProvider.notifier).update(v ?? 'auto'),
      ),
    );
  }

  Widget _buildHwdec() {
    if (!_matches(['hwdec'])) return const SizedBox.shrink();
    final current = ref.watch(hwdecProvider);
    return ListTile(
      title: const Text('Hardware decoder'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Auto')),
          DropdownMenuItem(value: 'auto-safe', child: Text('Auto (safe)')),
          DropdownMenuItem(value: 'no', child: Text('Software')),
          DropdownMenuItem(value: 'mediacodec', child: Text('MediaCodec')),
          DropdownMenuItem(value: 'cuda', child: Text('CUDA')),
        ],
        onChanged: (v) => ref.read(hwdecProvider.notifier).update(v ?? 'auto'),
      ),
    );
  }

  Widget _buildGpuApi() {
    if (!_matches(['gpu'])) return const SizedBox.shrink();
    final current = ref.watch(gpuApiProvider);
    return ListTile(
      title: const Text('GPU backend'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Auto')),
          DropdownMenuItem(value: 'vulkan', child: Text('Vulkan')),
          DropdownMenuItem(value: 'opengl', child: Text('OpenGL')),
        ],
        onChanged: (v) => ref.read(gpuApiProvider.notifier).update(v ?? 'auto'),
      ),
    );
  }

  Widget _buildHttpHeaders() {
    if (!_matches(['headers'])) return const SizedBox.shrink();
    final current = ref.watch(preferencesServiceProvider).getHttpHeaders();
    return ListTile(
      title: const Text('HTTP headers'),
      subtitle: const Text('One per line: Key: Value'),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _editHttpHeaders(current),
      ),
    );
  }

  Future<void> _editHttpHeaders(String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('HTTP headers'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Authorization: Bearer xxx\nX-Custom: value',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      await ref.read(preferencesServiceProvider).setHttpHeaders(result);
    }
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
