import 'package:flutter/material.dart';

enum VideoAspectRatio {
  fit,
  crop,
  stretch;

  String get label {
    switch (this) {
      case VideoAspectRatio.fit: return 'Fit';
      case VideoAspectRatio.crop: return 'Crop';
      case VideoAspectRatio.stretch: return 'Stretch';
    }
  }

  IconData get icon {
    switch (this) {
      case VideoAspectRatio.fit: return Icons.photo_size_select_large;
      case VideoAspectRatio.crop: return Icons.crop;
      case VideoAspectRatio.stretch: return Icons.photo;
    }
  }
}

class AspectRatioSheet extends StatelessWidget {
  final VideoAspectRatio current;
  final ValueChanged<VideoAspectRatio> onSelect;

  const AspectRatioSheet({
    super.key,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Aspect Ratio', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: VideoAspectRatio.values.map((ar) {
                final selected = ar == current;
                return ListTile(
                  leading: Icon(ar.icon),
                  title: Text(ar.label),
                  trailing: selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                  selected: selected,
                  onTap: () => onSelect(ar),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
