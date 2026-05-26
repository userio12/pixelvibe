import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../control_layout_provider.dart';
import '../player_button.dart';

class ControlLayoutEditor extends ConsumerStatefulWidget {
  const ControlLayoutEditor({super.key});

  @override
  ConsumerState<ControlLayoutEditor> createState() => _ControlLayoutEditorState();
}

class _ControlLayoutEditorState extends ConsumerState<ControlLayoutEditor> {
  List<PlayerButton> _topLeft = [];
  List<PlayerButton> _topRight = [];
  List<PlayerButton> _bottomCenter = [];
  final Set<PlayerButton> _available = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final state = ref.read(controlLayoutProvider);
    _topLeft = List.from(state.topLeft);
    _topRight = List.from(state.topRight);
    _bottomCenter = List.from(state.bottomCenter);
    _available.addAll(PlayerButton.values);
    for (final b in [..._topLeft, ..._topRight, ..._bottomCenter]) {
      _available.remove(b);
    }
    setState(() {});
  }

  Future<void> _save() async {
    await ref.read(controlLayoutProvider.notifier).setTopLeft(_topLeft);
    await ref.read(controlLayoutProvider.notifier).setTopRight(_topRight);
    await ref.read(controlLayoutProvider.notifier).setBottomCenter(_bottomCenter);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildArea(String title, List<PlayerButton> buttons, ValueChanged<List<PlayerButton>> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: buttons.length,
            onReorder: (oldI, newI) {
              final updated = List<PlayerButton>.from(buttons);
              final item = updated.removeAt(oldI);
              updated.insert(newI, item);
              onChanged(updated);
            },
            itemBuilder: (_, i) {
              final btn = buttons[i];
              return ListTile(
                key: ValueKey(btn),
                leading: btn.icon != null ? Icon(btn.icon, color: Colors.cyan) : null,
                title: Text(btn.label),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    final updated = List<PlayerButton>.from(buttons)..removeAt(i);
                    onChanged(updated);
                    setState(() => _available.add(btn));
                  },
                ),
              );
            },
          ),
          if (buttons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('(empty area)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Control Layout', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildArea('Top Left', _topLeft, (v) => setState(() => _topLeft = v)),
                  _buildArea('Top Right', _topRight, (v) => setState(() => _topRight = v)),
                  _buildArea('Bottom Center', _bottomCenter, (v) => setState(() => _bottomCenter = v)),
                  const Divider(),
                  Text('Available Buttons', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (_available.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('All buttons are in use.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _available.map((btn) {
                        return ActionChip(
                          avatar: btn.icon != null ? Icon(btn.icon, size: 16) : null,
                          label: Text(btn.label, style: const TextStyle(fontSize: 12)),
                          onPressed: () {
                            setState(() {
                              _bottomCenter.add(btn);
                              _available.remove(btn);
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
