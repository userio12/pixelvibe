import 'package:flutter/material.dart';
import '../../services/update_checker.dart';
import '../settings/widgets/settings_card_group.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'About',
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
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF71C4D4).withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.video_library_rounded,
                      size: 40,
                      color: Color(0xFF71C4D4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'pixelvibe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'v1.0.0+1',
                    style: TextStyle(
                      color: Color(0xFF90959A),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Built with Flutter + media_kit (libmpv)',
                    style: TextStyle(
                      color: Color(0xFF90959A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF71C4D4),
                  foregroundColor: const Color(0xFF0D2228),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => _checkUpdate(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.system_update_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Check for updates', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SettingsCardGroup(
              sectionTitle: 'Libraries',
              children: _libraries.map((lib) => _LibraryRow(lib['name']!, lib['license']!)).toList(),
            ),
            SettingsCardGroup(
              sectionTitle: 'Permissions',
              children: const [
                _PermissionRow('READ_MEDIA_VIDEO', 'Browse local videos'),
                _PermissionRow('MANAGE_EXTERNAL_STORAGE', 'Access files in custom folders'),
                _PermissionRow('POST_NOTIFICATIONS', 'Playback notification'),
                _PermissionRow('FOREGROUND_SERVICE', 'Background playback'),
                _PermissionRow('FOREGROUND_SERVICE_MEDIA_PLAYBACK', 'Media playback in background'),
                _PermissionRow('INTERNET', 'Network streaming and browsing'),
              ],
            ),
            const SizedBox(height: 8),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'MIT License · © 2026 pixelvibe',
                  style: TextStyle(color: Color(0xFF90959A), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    final checker = UpdateChecker();
    final update = await checker.check();
    if (!context.mounted) return;
    if (update == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No updates found or unable to check')),
      );
      return;
    }
    showUpdateDialog(context, update);
  }
}

class _LibraryRow extends StatelessWidget {
  final String name;
  final String license;

  const _LibraryRow(this.name, this.license);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            license,
            style: const TextStyle(color: Color(0xFF90959A), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String name;
  final String description;

  const _PermissionRow(this.name, this.description);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF71C4D4), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Color(0xFF90959A), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _libraries = [
  {'name': 'Flutter', 'license': 'BSD-3-Clause'},
  {'name': 'media_kit (libmpv)', 'license': 'MIT'},
  {'name': 'Riverpod', 'license': 'MIT'},
  {'name': 'GoRouter', 'license': 'BSD-3-Clause'},
  {'name': 'Drift (SQLite)', 'license': 'MIT'},
  {'name': 'NanoHTTPD', 'license': 'BSD-2-Clause'},
  {'name': 'SMBJ (jcifs-ng)', 'license': 'LGPL-2.1'},
  {'name': 'Apache Commons Net', 'license': 'Apache-2.0'},
  {'name': 'Permission Handler', 'license': 'MIT'},
];
