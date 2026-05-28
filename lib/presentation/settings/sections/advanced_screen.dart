import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../services/logger.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';

NotifierProvider<_BoolNotifier, bool> _boolPref(String key, bool defaultValue) {
  return NotifierProvider<_BoolNotifier, bool>(() => _BoolNotifier(key, defaultValue));
}

class _BoolNotifier extends Notifier<bool> {
  final String _key;
  final bool _defaultValue;
  _BoolNotifier(this._key, this._defaultValue);

  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool(_key, _defaultValue);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool(_key, state);
  }
}

final _luaScriptsProvider = _boolPref('lua_scripts', false);
final _recentlyPlayedProvider = _boolPref('recently_played', true);

class AdvancedScreen extends ConsumerWidget {
  const AdvancedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final luaScripts = ref.watch(_luaScriptsProvider);
    final recentlyPlayed = ref.watch(_recentlyPlayedProvider);

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
          'Advanced',
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
              sectionTitle: 'Backup & Restore',
              children: [
                StandardActionTile(
                  leadingIcon: Icons.file_upload_outlined,
                  title: 'Export Settings',
                  subtitle: 'Export settings to an XML file',
                  onTap: () => _exportSettings(context, ref),
                ),
                StandardActionTile(
                  leadingIcon: Icons.file_download_outlined,
                  title: 'Import Settings',
                  subtitle: 'Import settings from an XML file',
                  onTap: () => _importSettings(context, ref),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'MPV Configuration',
              children: [
                StandardActionTile(
                  title: 'Pick configuration storage location',
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 1,
                        height: 24,
                        child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF2C3136))),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.close, color: Color(0xFFDCA7A7)),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Storage location picker coming soon')),
                    );
                  },
                ),
                StandardActionTile(
                  title: 'Edit mpv.conf',
                  subtitle: 'Tap to edit configuration',
                  onTap: () {
                    Logger.info('mpv.conf editor requested');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File editor coming soon')),
                    );
                  },
                ),
                StandardActionTile(
                  title: 'Edit input.conf',
                  subtitle: 'Tap to edit configuration',
                  onTap: () {
                    Logger.info('input.conf editor requested');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File editor coming soon')),
                    );
                  },
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Scripts',
              children: [
                CustomSwitchTile(
                  title: 'Enable Lua Scripts',
                  subtitle: 'Load Lua scripts from configuration directory',
                  value: luaScripts,
                  onChanged: (_) => ref.read(_luaScriptsProvider.notifier).toggle(),
                ),
                const StandardActionTile(
                  title: 'Manage Lua Scripts',
                  subtitle: 'Set storage location and enable Lua scripts first',
                  isDisabled: true,
                ),
                const StandardActionTile(
                  title: 'Custom Lua',
                  subtitle: 'Create and manage custom Lua buttons',
                  isDisabled: true,
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'History',
              children: [
                CustomSwitchTile(
                  title: 'Recently Played',
                  subtitle: 'Track and display recently played videos and playlists',
                  value: recentlyPlayed,
                  onChanged: (_) => ref.read(_recentlyPlayedProvider.notifier).toggle(),
                ),
                StandardActionTile(
                  title: 'Clear playback history',
                  onTap: () => _confirmClear(context, 'playback history'),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Cache',
              children: [
                StandardActionTile(
                  title: 'Clear config cache',
                  subtitle: 'Clear the cached mpv.conf settings',
                  onTap: () => _confirmClear(context, 'config cache'),
                ),
                StandardActionTile(
                  title: 'Clear thumbnail cache',
                  subtitle: 'Delete all cached video thumbnails (will regenerate as you browse folders)',
                  onTap: () => _confirmClear(context, 'thumbnail cache'),
                ),
                StandardActionTile(
                  title: 'Clear cached fonts',
                  subtitle: 'Remove all cached subtitle fonts',
                  onTap: () => _confirmClear(context, 'cached fonts'),
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

Future<void> _confirmClear(BuildContext context, String label) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E2228),
      title: const Text('Clear?', style: TextStyle(color: Colors.white)),
      content: Text('Clear $label?', style: const TextStyle(color: Color(0xFF90959A))),
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
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label cleared')),
    );
  }
}

Future<void> _exportSettings(BuildContext context, WidgetRef ref) async {
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

Future<void> _importSettings(BuildContext context, WidgetRef ref) async {
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
