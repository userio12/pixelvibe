import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/logger.dart';
import '../settings_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/custom_slider_tile.dart';

void _showControlPicker(BuildContext context,
    String title, String currentValue,
    Future<void> Function(String) onSave) {
  final allControls = [
    'backArrow', 'info', 'loadSubtitle', 'addToPlaylist',
    'more', 'lock', 'pip', 'sleepTimer', 'volume',
    'skipBack', 'skipForward', 'playPause',
  ];
  final selected = currentValue.split(',').map((s) => s.trim()).toSet();

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E2227),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final localSelected = {...selected};
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFF2C3136)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allControls.map((control) {
                    final sel = localSelected.contains(control);
                    return FilterChip(
                      label: Text(control),
                      selected: sel,
                      onSelected: (v) {
                        setSheetState(() {
                          if (v) { localSelected.add(control); }
                          else { localSelected.remove(control); }
                        });
                      },
                      selectedColor: const Color(0xFF71C4D4),
                      checkmarkColor: const Color(0xFF0D2228),
                      backgroundColor: const Color(0xFF2C3136),
                      labelStyle: TextStyle(
                        color: sel ? const Color(0xFF0D2228) : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF71C4D4),
                      foregroundColor: const Color(0xFF0D2228),
                    ),
                    onPressed: () {
                      onSave(localSelected.join(','));
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class PlayerLayoutScreen extends ConsumerWidget {
  const PlayerLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seekbarStyle = ref.watch(seekbarStyleProvider);
    final tapToToggle = ref.watch(tapToToggleVisibilityProvider);
    final displaySeconds = ref.watch(displaySeekbarSecondsProvider);
    final dimSeconds = ref.watch(dimControlsSecondsProvider);
    final doubleTapAnim = ref.watch(doubleTapAnimationProvider);
    final disableTouch = ref.watch(disableControlsTouchInputProvider);
    final topLeft = ref.watch(topLeftControlsProvider);
    final topRight = ref.watch(topRightControlsProvider);
    final bottomCenter = ref.watch(bottomCenterControlsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Player Layout',
          style: TextStyle(
            color: Color(0xFF71C4D4),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SettingsCardGroup(
              sectionTitle: 'Seekbar Style',
              children: [
                _RadioTile(
                  title: 'Standard',
                  value: SeekbarStyle.standard,
                  groupValue: seekbarStyle,
                  onChanged: (v) => ref.read(seekbarStyleProvider.notifier).update(v),
                ),
                _RadioTile(
                  title: 'Wavy',
                  value: SeekbarStyle.wavy,
                  groupValue: seekbarStyle,
                  onChanged: (v) => ref.read(seekbarStyleProvider.notifier).update(v),
                ),
                _RadioTile(
                  title: 'Thick',
                  value: SeekbarStyle.thick,
                  groupValue: seekbarStyle,
                  onChanged: (v) => ref.read(seekbarStyleProvider.notifier).update(v),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Control Buttons',
              children: [
                _ControlPickerTile(
                  title: 'Top left controls',
                  currentValue: topLeft,
                  onSave: (v) async => ref.read(topLeftControlsProvider.notifier).update(v),
                ),
                _ControlPickerTile(
                  title: 'Top right controls',
                  currentValue: topRight,
                  onSave: (v) async => ref.read(topRightControlsProvider.notifier).update(v),
                ),
                _ControlPickerTile(
                  title: 'Bottom center controls',
                  currentValue: bottomCenter,
                  onSave: (v) async => ref.read(bottomCenterControlsProvider.notifier).update(v),
                ),
                StandardActionTile(
                  title: 'Reset to defaults',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1E23),
                        title: const Text('Reset to defaults', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'This will reset top left, top right, and bottom center controls to their default values.',
                          style: TextStyle(color: Color(0xFF90959A)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A929A))),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(topLeftControlsProvider.notifier).update('backArrow');
                              ref.read(topRightControlsProvider.notifier).update('info,loadSubtitle,addToPlaylist,more,lock,pip,sleepTimer,volume');
                              ref.read(bottomCenterControlsProvider.notifier).update('skipBack,playPause,skipForward');
                              Navigator.of(ctx).pop();
                              Logger.info('Controls reset to defaults');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Controls reset to defaults')),
                              );
                            },
                            child: const Text('Reset', style: TextStyle(color: Color(0xFF71C4D4))),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Misc',
              children: [
                CustomSwitchTile(
                  title: 'Tap to toggle visibility',
                  subtitle: 'Tap on player to show or hide controls',
                  value: tapToToggle,
                  onChanged: (_) => ref.read(tapToToggleVisibilityProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Display seekbar seconds',
                  subtitle: 'Show remaining time next to the seekbar',
                  value: displaySeconds,
                  onChanged: (_) => ref.read(displaySeekbarSecondsProvider.notifier).toggle(),
                ),
                CustomSliderTile(
                  title: 'Dim controls after (s)',
                  subtitle: '$dimSeconds seconds — Auto-hide controls after inactivity',
                  value: dimSeconds.toDouble(),
                  min: 2,
                  max: 30,
                  divisions: 28,
                  onChanged: (v) => ref.read(dimControlsSecondsProvider.notifier).update(v.round()),
                ),
                CustomSwitchTile(
                  title: 'Double tap animation',
                  subtitle: 'Show ripple animation on double tap',
                  value: doubleTapAnim,
                  onChanged: (_) => ref.read(doubleTapAnimationProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Disable controls with touch input',
                  subtitle: 'Disable on-screen playback controls while using touch input',
                  value: disableTouch,
                  onChanged: (_) => ref.read(disableControlsTouchInputProvider.notifier).toggle(),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String title;
  final SeekbarStyle value;
  final SeekbarStyle groupValue;
  final ValueChanged<SeekbarStyle> onChanged;

  const _RadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF71C4D4) : const Color(0xFF8A929A),
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: selected ? const Color(0xFF71C4D4) : Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlPickerTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final Future<void> Function(String) onSave;

  const _ControlPickerTile({
    required this.title,
    required this.currentValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return StandardActionTile(
      title: title,
      subtitle: currentValue,
      onTap: () => _showControlPicker(context, title, currentValue, onSave),
    );
  }
}
