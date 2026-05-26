import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../subtitle_settings_provider.dart';

class SubtitleSettingsSheet extends ConsumerWidget {
  const SubtitleSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(subtitleFontSizeProvider);
    final position = ref.watch(subtitlePositionProvider);
    final delayMs = ref.watch(subtitleDelayMsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Subtitle Settings', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _SliderTile(
                  label: 'Font Size',
                  value: fontSize,
                  min: 30,
                  max: 200,
                  divisions: 34,
                  displayValue: '${fontSize.round()}',
                  onChanged: (v) => ref.read(subtitleFontSizeProvider.notifier).update(v),
                ),
                _SliderTile(
                  label: 'Position',
                  value: position,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  displayValue: '${position.round()}%',
                  onChanged: (v) => ref.read(subtitlePositionProvider.notifier).update(v),
                ),
                _SliderTile(
                  label: 'Delay',
                  value: delayMs.toDouble(),
                  min: -5000,
                  max: 5000,
                  divisions: 100,
                  displayValue: '${delayMs}ms',
                  onChanged: (v) => ref.read(subtitleDelayMsProvider.notifier).update(v.round()),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Autoload matching subtitles'),
                  value: ref.watch(autoloadSubtitlesProvider),
                  onChanged: (_) => ref.read(autoloadSubtitlesProvider.notifier).toggle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            Text(displayValue, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
