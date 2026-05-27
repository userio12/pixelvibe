import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_provider.dart';
import '../enums/view_mode.dart';

class DisplayOptionsSheet extends ConsumerStatefulWidget {
  const DisplayOptionsSheet({super.key});

  @override
  ConsumerState<DisplayOptionsSheet> createState() => _DisplayOptionsSheetState();
}

class _DisplayOptionsSheetState extends ConsumerState<DisplayOptionsSheet> {
  var _fieldsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedSort = ref.watch(sortModeProvider);
    final isAscending = ref.watch(sortAscendingProvider);
    final viewMode = ref.watch(viewModeProvider);
    final layout = ref.watch(layoutProvider);
    final fields = ref.watch(displayFieldsProvider);

    const bgColor = Color(0xFF22282D);
    const accentColor = Color(0xFF135A74);
    const surfaceColor = Color(0xFF33393F);

    return Container(
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Sort & View Options', style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 24),
            Text('Sort by', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SquareButton(
                  icon: const Icon(Icons.text_fields, color: Colors.white, size: 24),
                  label: 'Title',
                  selected: selectedSort == SortMode.name,
                  onTap: () => ref.read(sortModeProvider.notifier).update(SortMode.name),
                ),
                _SquareButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white, size: 22),
                  label: 'Date',
                  selected: selectedSort == SortMode.date,
                  onTap: () => ref.read(sortModeProvider.notifier).update(SortMode.date),
                ),
                _SquareButton(
                  icon: const Icon(Icons.compare_arrows, color: Colors.white, size: 24),
                  label: 'Size',
                  selected: selectedSort == SortMode.size,
                  onTap: () => ref.read(sortModeProvider.notifier).update(SortMode.size),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: surfaceColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!isAscending) ref.read(sortAscendingProvider.notifier).toggle();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: isAscending ? accentColor : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                        ),
                        child: Text('^ A-Z', style: TextStyle(
                          color: isAscending ? Colors.white : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        )),
                      ),
                    ),
                    Container(width: 1, height: 20, color: surfaceColor),
                    GestureDetector(
                      onTap: () {
                        if (isAscending) ref.read(sortAscendingProvider.notifier).toggle();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: !isAscending ? accentColor : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                        ),
                        child: Text('v Z-A', style: TextStyle(
                          color: !isAscending ? Colors.white : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('View Mode', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SquareButton(
                            icon: const Icon(Icons.grid_view, color: Colors.white, size: 22),
                            label: 'Folder',
                            selected: viewMode == ViewMode.folder,
                            onTap: () => ref.read(viewModeProvider.notifier).update(ViewMode.folder),
                          ),
                          _SquareButton(
                            icon: const Icon(Icons.account_tree, color: Colors.white, size: 22),
                            label: 'Tree',
                            selected: viewMode == ViewMode.tree,
                            onTap: () => ref.read(viewModeProvider.notifier).update(ViewMode.tree),
                          ),
                          _SquareButton(
                            icon: const Icon(Icons.photo_library, color: Colors.white, size: 22),
                            label: 'Albums',
                            selected: viewMode == ViewMode.albums,
                            onTap: () => ref.read(viewModeProvider.notifier).update(ViewMode.albums),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 24, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layout', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SquareButton(
                            icon: const Icon(Icons.view_list, color: Colors.white, size: 22),
                            label: 'List',
                            selected: layout == LayoutMode.list,
                            onTap: () => ref.read(layoutProvider.notifier).update(LayoutMode.list),
                          ),
                          _SquareButton(
                            icon: const Icon(Icons.grid_view, color: Colors.white, size: 22),
                            label: 'Grid',
                            selected: layout == LayoutMode.grid,
                            onTap: () => ref.read(layoutProvider.notifier).update(LayoutMode.grid),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _fieldsExpanded = !_fieldsExpanded),
                  child: Row(
                    children: [
                      Text('Fields', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      const Spacer(),
                      Icon(
                        _fieldsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
                if (_fieldsExpanded) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DisplayField.values.map((field) {
                      final selected = fields.contains(field);
                      return GestureDetector(
                        onTap: () => ref.read(displayFieldsProvider.notifier).toggle(field),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF135A74) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: selected ? null : Border.all(color: const Color(0xFF4A5158)),
                          ),
                          child: Text(
                            _fieldLabel(field),
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fieldLabel(DisplayField field) => switch (field) {
    DisplayField.fullName => 'Full Name',
    DisplayField.path => 'Path',
    DisplayField.totalVideos => 'Total Videos',
    DisplayField.totalDuration => 'Total Duration',
    DisplayField.folderSize => 'Folder Size',
    DisplayField.date => 'Date',
  };
}

class _SquareButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SquareButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF135A74) : const Color(0xFF33393F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            color: selected ? Colors.white : Colors.grey[400],
            fontSize: 12,
          )),
        ],
      ),
    );
  }
}
