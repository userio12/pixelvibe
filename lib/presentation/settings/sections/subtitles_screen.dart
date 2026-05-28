import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';

final _autoLoadSubsProvider = NotifierProvider<_AutoLoadSubsNotifier, bool>(_AutoLoadSubsNotifier.new);
class _AutoLoadSubsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAutoLoadSubtitles();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAutoLoadSubtitles(state);
  }
}

final _overrideAssProvider = NotifierProvider<_OverrideAssNotifier, bool>(_OverrideAssNotifier.new);
class _OverrideAssNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getOverrideAssSsa();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setOverrideAssSsa(state);
  }
}

final _scaleByWindowProvider = NotifierProvider<_ScaleByWindowNotifier, bool>(_ScaleByWindowNotifier.new);
class _ScaleByWindowNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getScaleByWindow();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setScaleByWindow(state);
  }
}

class SubtitlesScreen extends ConsumerWidget {
  const SubtitlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoad = ref.watch(_autoLoadSubsProvider);
    final overrideAss = ref.watch(_overrideAssProvider);
    final scaleByWindow = ref.watch(_scaleByWindowProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Subtitles',
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
              sectionTitle: 'General',
              children: [
                StandardActionTile(
                  title: 'Preferred languages',
                  subtitle: 'Not set (will use video default)',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                CustomSwitchTile(
                  title: 'Automatically load subtitles',
                  subtitle: 'Automatically load external subtitles with the same name.',
                  value: autoLoad,
                  onChanged: (_) => ref.read(_autoLoadSubsProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Override ASS/SSA subtitles',
                  subtitle: 'Force override ASS/SSA subtitle formatting',
                  value: overrideAss,
                  onChanged: (_) => ref.read(_overrideAssProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Scale by window',
                  subtitle: 'Scale subtitles by window size and use video margins',
                  value: scaleByWindow,
                  onChanged: (_) => ref.read(_scaleByWindowProvider.notifier).toggle(),
                ),
                StandardActionTile(
                  title: 'Fonts directory',
                  subtitle: 'Not set (using system fonts)',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Subtitle Search',
              children: [
                StandardActionTile(
                  title: 'Subtitle Save Location',
                  subtitle: 'Not set (will use video default)',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                StandardActionTile(
                  title: 'Subtitle Sources',
                  subtitle: 'All',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                StandardActionTile(
                  title: 'Subtitle Languages',
                  subtitle: 'English',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                StandardActionTile(
                  title: 'Advanced Search Filters',
                  titleColor: const Color(0xFF71C4D4),
                  trailing: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF71C4D4)),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                StandardActionTile(
                  title: 'Clear Subtitle Downloads',
                  subtitle: 'Delete all files in the current save location',
                  titleColor: const Color(0xFFDCA7A7),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Subtitle Downloads'),
                        content: const Text('Are you sure you want to delete all downloaded subtitle files?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Downloads cleared')),
                              );
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 16, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtitle Search provided by',
                    style: TextStyle(color: Color(0xFF90959A), fontSize: 12),
                  ),
                  Text(
                    'sub.wyzie.ru',
                    style: TextStyle(color: Color(0xFF71C4D4), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
