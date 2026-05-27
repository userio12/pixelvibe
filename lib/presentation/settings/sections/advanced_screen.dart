import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../services/logger.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';

class AdvancedScreen extends ConsumerWidget {
  const AdvancedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                ),
                const StandardActionTile(
                  title: 'Edit mpv.conf',
                  subtitle: 'Tap to edit configuration',
                ),
                const StandardActionTile(
                  title: 'Edit input.conf',
                  subtitle: 'Tap to edit configuration',
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Scripts',
              children: [
                const CustomSwitchTile(
                  title: 'Enable Lua Scripts',
                  subtitle: 'Load Lua scripts from configuration directory',
                  value: false,
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
                const CustomSwitchTile(
                  title: 'Recently Played',
                  subtitle: 'Track and display recently played videos and playlists',
                  value: true,
                ),
                const StandardActionTile(
                  title: 'Clear playback history',
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Cache',
              children: [
                const StandardActionTile(
                  title: 'Clear config cache',
                  subtitle: 'Clear the cached mpv.conf settings',
                ),
                const StandardActionTile(
                  title: 'Clear thumbnail cache',
                  subtitle: 'Delete all cached video thumbnails (will regenerate as you browse folders)',
                ),
                const StandardActionTile(
                  title: 'Clear cached fonts',
                  subtitle: 'Remove all cached subtitle fonts',
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
