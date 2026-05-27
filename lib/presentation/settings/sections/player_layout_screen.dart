import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../settings_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/custom_slider_tile.dart';

NotifierProvider<_BoolNotifier, bool> _boolPref(String key, bool defaultValue) {
  return NotifierProvider<_BoolNotifier, bool>(() => _BoolNotifier(key, defaultValue));
}

class _BoolNotifier extends Notifier<bool> {
  final String _key;
  final bool _defaultValue;
  _BoolNotifier(this._key, this._defaultValue);

  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool(_key, _defaultValue);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool(_key, state);
  }
}

final _tapToToggleVisibilityProvider = _boolPref('tap_to_toggle_visibility', true);
final _displaySeekbarSecondsProvider = _boolPref('display_seekbar_seconds', true);
final _doubleTapAnimationProvider = _boolPref('double_tap_animation', true);
final _disableControlsTouchInputProvider = _boolPref('disable_controls_touch_input', false);

class PlayerLayoutScreen extends ConsumerWidget {
  const PlayerLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seekbarStyle = ref.watch(seekbarStyleProvider);
    final tapToToggle = ref.watch(_tapToToggleVisibilityProvider);
    final displaySeconds = ref.watch(_displaySeekbarSecondsProvider);
    final dimSeconds = ref.watch(preferencesServiceProvider).getDimControlsSeconds();
    final doubleTapAnim = ref.watch(_doubleTapAnimationProvider);
    final disableTouch = ref.watch(_disableControlsTouchInputProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
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
                StandardActionTile(
                  title: 'Top left controls',
                  subtitle: ref.watch(preferencesServiceProvider).getTopLeftControls(),
                  onTap: () {},
                ),
                StandardActionTile(
                  title: 'Top right controls',
                  subtitle: ref.watch(preferencesServiceProvider).getTopRightControls(),
                  onTap: () {},
                ),
                StandardActionTile(
                  title: 'Bottom center controls',
                  subtitle: ref.watch(preferencesServiceProvider).getBottomCenterControls(),
                  onTap: () {},
                ),
                StandardActionTile(
                  title: 'Reset to defaults',
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
                  onChanged: (_) => ref.read(_tapToToggleVisibilityProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Display seekbar seconds',
                  subtitle: 'Show remaining time next to the seekbar',
                  value: displaySeconds,
                  onChanged: (_) => ref.read(_displaySeekbarSecondsProvider.notifier).toggle(),
                ),
                CustomSliderTile(
                  title: 'Dim controls after (s)',
                  subtitle: '$dimSeconds seconds — Auto-hide controls after inactivity',
                  value: dimSeconds.toDouble(),
                  min: 2,
                  max: 30,
                  divisions: 28,
                  onChanged: (v) => ref.read(preferencesServiceProvider).setDimControlsSeconds(v.round()),
                ),
                CustomSwitchTile(
                  title: 'Double tap animation',
                  subtitle: 'Show ripple animation on double tap',
                  value: doubleTapAnim,
                  onChanged: (_) => ref.read(_doubleTapAnimationProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Disable controls with touch input',
                  subtitle: 'Disable on-screen playback controls while using touch input',
                  value: disableTouch,
                  onChanged: (_) => ref.read(_disableControlsTouchInputProvider.notifier).toggle(),
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
