import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/logger.dart';
import '../filters_provider.dart';
import '../player_provider.dart';
import '../player_overlay.dart';
import '../player_updates.dart';
import 'aspect_ratio_sheet.dart';
import 'decoder_sheet.dart';
import 'filter_sheet.dart';
import 'filter_presets.dart';
import 'subtitle_settings_sheet.dart';
import 'subtitle_search_sheet.dart';

class PlayerMoreSheet extends ConsumerWidget {
  const PlayerMoreSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentFilter = ref.watch(filterPresetProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('More', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: [
                _OptionTile(
                  icon: Icons.filter_vintage,
                  title: 'Video Filters',
                  subtitle: currentFilter == FilterPreset.none ? 'None' : currentFilter.label,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => FilterSheet(
                      current: currentFilter,
                      onSelect: (preset) {
                        ref.read(filterPresetProvider.notifier).update(preset);
                        ref.read(playerOverlayProvider.notifier).show(
                          ShowText('Filter: ${preset.label}'),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                _OptionTile(
                  icon: Icons.aspect_ratio,
                  title: 'Aspect Ratio',
                  subtitle: 'Fit',
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => AspectRatioSheet(
                      current: VideoAspectRatio.fit,
                      onSelect: (ar) {
                        ref.read(playerOverlayProvider.notifier).show(
                          AspectRatioChange(ar.label),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                _OptionTile(
                  icon: Icons.settings_overscan,
                  title: 'Decoder',
                  subtitle: 'Auto Copy',
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => DecoderSheet(
                      current: DecoderMode.autoCopy,
                      onSelect: (mode) {
                        ref.read(playerOverlayProvider.notifier).show(
                          ShowText('Decoder: ${mode.label}'),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                _OptionTile(
                  icon: Icons.language,
                  title: 'Search Subtitles Online',
                  subtitle: 'subdl.com',
                  onTap: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const SubtitleSearchSheet(),
                    );
                  },
                ),
                _OptionTile(
                  icon: Icons.subtitles_outlined,
                  title: 'Subtitle Settings',
                  subtitle: 'Font, position, delay',
                  onTap: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const SubtitleSettingsSheet(),
                    );
                  },
                ),
                const Divider(),
                _OptionTile(
                  icon: Icons.screenshot,
                  title: 'Screenshot',
                  subtitle: 'Capture current frame',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _takeScreenshot(ref, context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takeScreenshot(WidgetRef ref, BuildContext context) async {
    try {
      final player = ref.read(playerProvider);
      final data = await player.screenshot();
      if (data == null) throw Exception('No screenshot data');
      final dir = Directory('/storage/emulated/0/Pictures/pixelvibe');
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File('${dir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot saved')),
        );
      }
    } catch (e) {
      Logger.error('Screenshot failed', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot failed: $e')),
        );
      }
    }
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
