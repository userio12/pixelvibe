import 'package:flutter/material.dart';
import '../enums/view_mode.dart';

class ViewModeToggle extends StatelessWidget {
  final ViewMode current;
  final ValueChanged<ViewMode> onChanged;

  const ViewModeToggle({super.key, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final all = ViewMode.values;
    return SegmentedButton<ViewMode>(
      segments: all.map((v) => ButtonSegment(
        value: v,
        icon: Icon(_icon(v)),
      )).toList(),
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }

  IconData _icon(ViewMode mode) => switch (mode) {
    ViewMode.grid => Icons.grid_view_outlined,
    ViewMode.list => Icons.list_outlined,
    ViewMode.tree => Icons.folder_outlined,
    ViewMode.albums => Icons.photo_library_outlined,
  };
}
