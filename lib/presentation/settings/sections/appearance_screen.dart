import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../settings_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/custom_slider_tile.dart';
import '../widgets/pref_notifiers.dart';

final _showFullNamesProvider = boolPref('show_full_file_names', false);
final _showNewLabelProvider = boolPref('show_new_label', true);
final _daysThresholdProvider = intPref('days_threshold', 7);
final _autoScrollProvider = boolPref('auto_scroll_to_last_played', false);
final _tapThumbnailProvider = boolPref('tap_thumbnail_to_select', false);
final _showNetworkThumbsProvider = boolPref('show_network_thumbnails', false);

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final amoled = ref.watch(amoledModeProvider);
    final showFullNames = ref.watch(_showFullNamesProvider);
    final showNewLabel = ref.watch(_showNewLabelProvider);
    final daysThreshold = ref.watch(_daysThresholdProvider);
    final autoScroll = ref.watch(_autoScrollProvider);
    final watchedThreshold = ref.watch(preferencesServiceProvider).getWatchedThreshold();
    final tapThumbnail = ref.watch(_tapThumbnailProvider);
    final showNetworkThumbs = ref.watch(_showNetworkThumbsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Appearance',
          style: TextStyle(
            color: Color(0xFF71C4D4),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SettingsCardGroup(
              sectionTitle: 'App Theme',
              children: [
                _ThemeSegmentedControl(
                  value: themeMode,
                  onChanged: (m) => ref.read(themeModeProvider.notifier).update(m),
                ),
                const _ThemeCarousel(),
                CustomSwitchTile(
                  title: 'AMOLED Black Mode',
                  value: amoled,
                  onChanged: (_) => ref.read(amoledModeProvider.notifier).toggle(),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'File Browser',
              children: [
                CustomSwitchTile(
                  title: 'Show full file names',
                  subtitle: 'Display complete file names instead of truncated ones',
                  value: showFullNames,
                  onChanged: (_) => ref.read(_showFullNamesProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Show new label',
                  subtitle: 'Show a "New" label on files added within the threshold',
                  value: showNewLabel,
                  onChanged: (_) => ref.read(_showNewLabelProvider.notifier).toggle(),
                ),
                CustomSliderTile(
                  title: 'Days threshold',
                  subtitle: '$daysThreshold days — Consider files added within this period as new',
                  value: daysThreshold.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  onChanged: (v) => ref.read(_daysThresholdProvider.notifier).update(v.round()),
                ),
                CustomSwitchTile(
                  title: 'Auto-scroll to last played',
                  subtitle: 'Automatically scroll to the last played file when opening a folder',
                  value: autoScroll,
                  onChanged: (_) => ref.read(_autoScrollProvider.notifier).toggle(),
                ),
                CustomSliderTile(
                  title: 'Watched threshold',
                  subtitle: '$watchedThreshold% — Mark videos as watched at this playback percentage',
                  value: watchedThreshold.toDouble(),
                  min: 50,
                  max: 100,
                  divisions: 50,
                  onChanged: (v) => ref.read(preferencesServiceProvider).setWatchedThreshold(v.round()),
                ),
                CustomSwitchTile(
                  title: 'Tap thumbnail to select',
                  subtitle: 'Tap a thumbnail to enter selection mode',
                  value: tapThumbnail,
                  onChanged: (_) => ref.read(_tapThumbnailProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Show network thumbnails',
                  subtitle: 'Download and cache thumbnails for network files',
                  value: showNetworkThumbs,
                  onChanged: (_) => ref.read(_showNetworkThumbsProvider.notifier).toggle(),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmentedControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
    const labels = ['Dark', 'Light', 'System'];
    const icons = [Icons.dark_mode, Icons.light_mode, Icons.auto_mode];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E23),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(options.length, (i) {
            final selected = value == options[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(options[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF71C4D4) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[i],
                        color: selected ? const Color(0xFF0D2228) : const Color(0xFF8A929A),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: selected ? const Color(0xFF0D2228) : const Color(0xFF8A929A),
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ThemeCarousel extends StatelessWidget {
  const _ThemeCarousel();

  static const _themes = [
    ('Default', Color(0xFF6750A4)),
    ('Dynamic', Color(0xFF71C4D4)),
    ('Catppuccin', Color(0xFFCBA6F7)),
    ('Cloud', Color(0xFF89DCEB)),
    ('Rose Pine', Color(0xFFEBBCBA)),
    ('Dracula', Color(0xFFBD93F9)),
    ('Nord', Color(0xFF81A1C1)),
    ('Solarized', Color(0xFF268BD2)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _themes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (name, color) = _themes[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Theme: $name')),
              );
            },
            child: Container(
              width: 72,
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha(60),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withAlpha(120)),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(color: Color(0xFF90959A), fontSize: 10),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
