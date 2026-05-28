import 'package:flutter/material.dart';
import 'filter_presets.dart';

class FilterSheet extends StatelessWidget {
  final FilterPreset current;
  final ValueChanged<FilterPreset> onSelect;

  const FilterSheet({
    super.key,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Video Filters', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: GridView.count(
              controller: scrollCtrl,
              crossAxisCount: 3,
              padding: const EdgeInsets.all(12),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
              children: filterPresets.map((preset) {
                final selected = preset == current;
                return Material(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelect(preset),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          preset.icon,
                          size: 28,
                          color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preset.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
