import 'package:flutter/material.dart';
import '../../services/update_checker.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.video_library_rounded, size: 72, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text('pixelvibe', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('v1.0.0+1', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('Built with Flutter + media_kit (libmpv)', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.system_update_outlined),
              label: const Text('Check for updates'),
              onPressed: () => _checkUpdate(context),
            ),
          ),
          const SizedBox(height: 24),
          Text('Libraries', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._libraries.map((lib) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(lib['name']!, style: theme.textTheme.bodyMedium)),
                Text(lib['license']!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          )),
          const SizedBox(height: 24),
          Text('Permissions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '• READ_MEDIA_VIDEO — Browse local videos\n'
            '• MANAGE_EXTERNAL_STORAGE — Access files in custom folders\n'
            '• POST_NOTIFICATIONS — Playback notification\n'
            '• FOREGROUND_SERVICE — Background playback\n'
            '• FOREGROUND_SERVICE_MEDIA_PLAYBACK — Media playback in background\n'
            '• INTERNET — Network streaming and browsing',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('MIT License · © 2026 pixelvibe', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
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
