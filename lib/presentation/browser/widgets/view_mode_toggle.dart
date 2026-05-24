import 'package:flutter/material.dart';
import '../enums/view_mode.dart';

class ViewModeToggle extends StatelessWidget {
  final ViewMode current;
  final ValueChanged<ViewMode> onChanged;

  const ViewModeToggle({super.key, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ViewMode>(
      segments: const [
        ButtonSegment(value: ViewMode.grid, icon: Icon(Icons.grid_view_outlined)),
        ButtonSegment(value: ViewMode.list, icon: Icon(Icons.list_outlined)),
        ButtonSegment(value: ViewMode.tree, icon: Icon(Icons.folder_outlined)),
      ],
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}
