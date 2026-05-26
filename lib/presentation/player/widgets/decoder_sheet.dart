import 'package:flutter/material.dart';

enum DecoderMode {
  autoCopy,
  autoMode,
  software,
  hardware,
  hardwarePlus;

  String get label {
    switch (this) {
      case DecoderMode.autoCopy: return 'Auto Copy';
      case DecoderMode.autoMode: return 'Auto';
      case DecoderMode.software: return 'Software';
      case DecoderMode.hardware: return 'Hardware';
      case DecoderMode.hardwarePlus: return 'Hardware+';
    }
  }
}

class DecoderSheet extends StatelessWidget {
  final DecoderMode current;
  final ValueChanged<DecoderMode> onSelect;

  const DecoderSheet({
    super.key,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.25,
      maxChildSize: 0.6,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Decoder', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: DecoderMode.values.map((mode) {
                final selected = mode == current;
                return ListTile(
                  title: Text(mode.label),
                  trailing: selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                  selected: selected,
                  onTap: () => onSelect(mode),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
