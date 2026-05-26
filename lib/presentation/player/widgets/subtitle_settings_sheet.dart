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
    final bold = ref.watch(subtitleBoldProvider);
    final italic = ref.watch(subtitleItalicProvider);
    final textColor = Color(ref.watch(subtitleTextColorProvider));
    final bgColor = Color(ref.watch(subtitleBgColorProvider));
    final borderStyle = ref.watch(subtitleBorderStyleProvider);
    final borderColor = Color(ref.watch(subtitleBorderColorProvider));
    final justify = ref.watch(subtitleJustifyProvider);
    final assOverride = ref.watch(subtitleAssOverrideProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
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
                _SectionTitle('Style'),
                _SliderTile(
                  label: 'Font Size',
                  value: fontSize,
                  min: 20,
                  max: 200,
                  divisions: 36,
                  displayValue: '${fontSize.round()}',
                  onChanged: (v) => ref.read(subtitleFontSizeProvider.notifier).update(v),
                ),
                const SizedBox(height: 8),
                _ColorPickerTile(
                  label: 'Text Color',
                  color: textColor,
                  onChanged: (v) => ref.read(subtitleTextColorProvider.notifier).update(v),
                ),
                const SizedBox(height: 8),
                _ColorPickerTile(
                  label: 'Background Color',
                  color: bgColor,
                  onChanged: (v) => ref.read(subtitleBgColorProvider.notifier).update(v),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Bold'),
                  value: bold,
                  onChanged: (_) => ref.read(subtitleBoldProvider.notifier).toggle(),
                ),
                SwitchListTile(
                  title: const Text('Italic'),
                  value: italic,
                  onChanged: (_) => ref.read(subtitleItalicProvider.notifier).toggle(),
                ),

                _SectionTitle('Border'),
                ListTile(
                  title: const Text('Border Style'),
                  trailing: SegmentedButton<SubtitleBorderStyle>(
                    segments: const [
                      ButtonSegment(value: SubtitleBorderStyle.none, label: Text('None')),
                      ButtonSegment(value: SubtitleBorderStyle.dropShadow, label: Text('Shadow')),
                      ButtonSegment(value: SubtitleBorderStyle.outline, label: Text('Outline')),
                    ],
                    selected: {borderStyle},
                    onSelectionChanged: (s) => ref.read(subtitleBorderStyleProvider.notifier).update(s.first),
                    showSelectedIcon: false,
                  ),
                ),
                if (borderStyle != SubtitleBorderStyle.none)
                  _ColorPickerTile(
                    label: 'Border Color',
                    color: borderColor,
                    onChanged: (v) => ref.read(subtitleBorderColorProvider.notifier).update(v),
                  ),

                _SectionTitle('Position'),
                _SliderTile(
                  label: 'Vertical Position',
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

                _SectionTitle('Advanced'),
                ListTile(
                  title: const Text('Justification'),
                  trailing: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Left')),
                      ButtonSegment(value: 1, label: Text('Center')),
                      ButtonSegment(value: 2, label: Text('Right')),
                    ],
                    selected: {justify},
                    onSelectionChanged: (s) => ref.read(subtitleJustifyProvider.notifier).update(s.first),
                    showSelectedIcon: false,
                  ),
                ),
                SwitchListTile(
                  title: const Text('ASS Override'),
                  subtitle: const Text('Force override ASS subtitle styles'),
                  value: assOverride,
                  onChanged: (_) => ref.read(subtitleAssOverrideProvider.notifier).toggle(),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
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

class _ColorPickerTile extends StatefulWidget {
  final String label;
  final Color color;
  final ValueChanged<int> onChanged;

  const _ColorPickerTile({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_ColorPickerTile> createState() => _ColorPickerTileState();
}

class _ColorPickerTileState extends State<_ColorPickerTile> {
  static const _presets = [
    Color(0xFFFFFFFF),
    Color(0xFFE0E0E0),
    Color(0xFFFFEB3B),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
    Color(0xFFFF4081),
    Color(0xFF000000),
    Color(0xAA000000),
    Color(0x00000000),
  ];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.label),
      trailing: GestureDetector(
        onTap: () => _showPicker(context),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((c) {
              return GestureDetector(
                onTap: () {
                  widget.onChanged(c.toARGB32());
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
