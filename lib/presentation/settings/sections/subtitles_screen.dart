import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../presentation/player/subtitle_settings_provider.dart';
import '../../../services/logger.dart';
import '../widgets/language_picker.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';

class SubtitlesScreen extends ConsumerWidget {
  const SubtitlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoad = ref.watch(autoloadSubtitlesProvider);
    final overrideAss = ref.watch(subtitleAssOverrideProvider);
    final scaleByWindow = ref.watch(subScaleByWindowProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
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
                _SubtitleLanguageTile(
                  title: 'Preferred languages',
                  currentValue: ref.watch(preferencesServiceProvider).getSubtitleLanguages(),
                  onSave: (v) => ref.read(preferencesServiceProvider).setSubtitleLanguages(v),
                ),
                CustomSwitchTile(
                  title: 'Automatically load subtitles',
                  subtitle: 'Automatically load external subtitles with the same name.',
                  value: autoLoad,
                  onChanged: (_) => ref.read(autoloadSubtitlesProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Override ASS/SSA subtitles',
                  subtitle: 'Force override ASS/SSA subtitle formatting',
                  value: overrideAss,
                  onChanged: (_) => ref.read(subtitleAssOverrideProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Scale by window',
                  subtitle: 'Scale subtitles by window size and use video margins',
                  value: scaleByWindow,
                  onChanged: (_) => ref.read(subScaleByWindowProvider.notifier).toggle(),
                ),
                _DirectoryTile(
                  title: 'Fonts directory',
                  subtitle: ref.watch(preferencesServiceProvider).getSubtitleFontsDirectory(),
                  displayEmpty: 'Not set (using system fonts)',
                  onSave: (v) => ref.read(preferencesServiceProvider).setSubtitleFontsDirectory(v),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Subtitle Search',
              children: [
                _DirectoryTile(
                  title: 'Subtitle Save Location',
                  subtitle: ref.watch(preferencesServiceProvider).getSubtitleSaveLocation(),
                  displayEmpty: 'Not set (will use video default)',
                  onSave: (v) => ref.read(preferencesServiceProvider).setSubtitleSaveLocation(v),
                ),
                _SubtitleSourcesTile(
                  title: 'Subtitle Sources',
                  currentValue: ref.watch(preferencesServiceProvider).getSubtitleSources(),
                  onSave: (v) => ref.read(preferencesServiceProvider).setSubtitleSources(v),
                ),
                _SubtitleLanguageTile(
                  title: 'Subtitle Languages',
                  currentValue: ref.watch(preferencesServiceProvider).getSubtitleLanguages(),
                  onSave: (v) => ref.read(preferencesServiceProvider).setSubtitleLanguages(v),
                ),
                StandardActionTile(
                  title: 'Advanced Search Filters',
                  titleColor: const Color(0xFF71C4D4),
                  trailing: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF71C4D4)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
                StandardActionTile(
                  title: 'Clear Subtitle Downloads',
                  subtitle: 'Delete all files in the current save location',
                  titleColor: const Color(0xFFDCA7A7),
                  onTap: () => _clearSubtitleDownloads(context, ref),
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

Future<void> _clearSubtitleDownloads(BuildContext context, WidgetRef ref) async {
  final dir = ref.read(preferencesServiceProvider).getSubtitleSaveLocation();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E2228),
      title: const Text('Clear Subtitle Downloads', style: TextStyle(color: Colors.white)),
      content: const Text('Are you sure you want to delete all downloaded subtitle files?',
        style: TextStyle(color: Color(0xFF90959A))),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Clear'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (dir.isNotEmpty) {
    try {
      final directory = Directory(dir);
      if (await directory.exists()) {
        final files = directory.listSync().whereType<File>().toList();
        for (final f in files) {
          await f.delete();
        }
        Logger.info('Cleared ${files.length} subtitle downloads');
      }
    } catch (e) {
      Logger.error('Error clearing subtitle downloads', e);
    }
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloads cleared')),
    );
  }
}

class _SubtitleLanguageTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final void Function(String) onSave;

  const _SubtitleLanguageTile({
    required this.title,
    required this.currentValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return StandardActionTile(
      title: title,
      subtitle: currentValue.isEmpty ? 'Not set (will use video default)' : currentValue,
      onTap: () => showLanguagePicker(context, currentValue, onSave),
    );
  }
}

class _DirectoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String displayEmpty;
  final Future<void> Function(String) onSave;

  const _DirectoryTile({
    required this.title,
    required this.subtitle,
    required this.displayEmpty,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return StandardActionTile(
      title: title,
      subtitle: subtitle.isEmpty ? displayEmpty : subtitle,
      onTap: () async {
        final result = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select $title',
        );
        if (result != null) {
          await onSave(result);
        }
      },
    );
  }
}

class _SubtitleSourcesTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final Future<void> Function(String) onSave;

  const _SubtitleSourcesTile({
    required this.title,
    required this.currentValue,
    required this.onSave,
  });

  static const _allSources = [
    ('opensubtitles', 'OpenSubtitles'),
    ('embedded', 'Embedded'),
    ('podnapisi', 'Podnapisi'),
    ('subdb', 'SubDB'),
    ('yifysubs', 'YIFY Subs'),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = currentValue.split(',').map((s) => s.trim()).toSet();
    return StandardActionTile(
      title: title,
      subtitle: currentValue == 'opensubtitles,embedded,podnapisi' ? 'All' : currentValue,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E2227),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
            return StatefulBuilder(
              builder: (ctx, setSheetState) {
                final localSelected = {...selected};
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF2C3136)),
                    ..._allSources.map((entry) {
                      final (code, name) = entry;
                      final sel = localSelected.contains(code);
                      return CheckboxListTile(
                        title: Text(name, style: const TextStyle(color: Colors.white70)),
                        value: sel,
                        activeColor: const Color(0xFF71C4D4),
                        checkColor: const Color(0xFF0D2228),
                        onChanged: (v) {
                          setSheetState(() {
                            if (v == true) { localSelected.add(code); }
                            else { localSelected.remove(code); }
                          });
                        },
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF71C4D4),
                            foregroundColor: const Color(0xFF0D2228),
                          ),
                          onPressed: () {
                            onSave(localSelected.join(','));
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
