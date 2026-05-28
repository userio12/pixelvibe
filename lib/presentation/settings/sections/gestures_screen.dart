import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/info_block.dart';

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

NotifierProvider<_IntNotifier, int> _intPref(String key, int defaultValue) {
  return NotifierProvider<_IntNotifier, int>(() => _IntNotifier(key, defaultValue));
}

class _IntNotifier extends Notifier<int> {
  final String _key;
  final int _defaultValue;
  _IntNotifier(this._key, this._defaultValue);

  @override
  int build() => ref.watch(preferencesServiceProvider).getInt(_key, _defaultValue);
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setInt(_key, v);
  }
}

NotifierProvider<_StringNotifier, String> _stringPref(String key, String defaultValue) {
  return NotifierProvider<_StringNotifier, String>(() => _StringNotifier(key, defaultValue));
}

class _StringNotifier extends Notifier<String> {
  final String _key;
  final String _defaultValue;
  _StringNotifier(this._key, this._defaultValue);

  @override
  String build() => ref.watch(preferencesServiceProvider).getString(_key, _defaultValue);
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setString(_key, v);
  }
}

final _doubleTapSeekDurationProvider = _intPref('double_tap_seek_duration', 10);
final _centerGestureSingleTapProvider = _boolPref('center_gesture_single_tap', false);
final _doubleTapLeftActionProvider = _stringPref('double_tap_left_action', 'Seek');
final _doubleTapRightActionProvider = _stringPref('double_tap_right_action', 'Seek');
final _mediaControlsDoubleTapProvider = _boolPref('media_controls_double_tap', true);
final _mediaControlsSingleTapProvider = _boolPref('media_controls_single_tap', true);
final _mediaControlsLongPressProvider = _boolPref('media_controls_long_press', true);
final _mediaControlsSwipeProvider = _boolPref('media_controls_swipe', true);

class GesturesScreen extends ConsumerWidget {
  const GesturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleTapSeekDuration = ref.watch(_doubleTapSeekDurationProvider);
    final centerGestureSingleTap = ref.watch(_centerGestureSingleTapProvider);
    final doubleTapLeftAction = ref.watch(_doubleTapLeftActionProvider);
    final doubleTapRightAction = ref.watch(_doubleTapRightActionProvider);
    final mediaControlsDoubleTap = ref.watch(_mediaControlsDoubleTapProvider);
    final mediaControlsSingleTap = ref.watch(_mediaControlsSingleTapProvider);
    final mediaControlsLongPress = ref.watch(_mediaControlsLongPressProvider);
    final mediaControlsSwipe = ref.watch(_mediaControlsSwipeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Gestures',
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
              sectionTitle: 'Double tap',
              skipDividerAfter: {5},
              children: [
                StandardActionTile(
                  title: 'Double tap seek duration',
                  subtitle: '${doubleTapSeekDuration}s',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon: duration picker')),
                  ),
                ),
                StandardActionTile(
                  title: 'Double Tap Seek Area Width',
                  subtitle: 'Current: 35%',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon: width picker')),
                  ),
                ),
                StandardActionTile(
                  title: 'Double tap (left)',
                  subtitle: doubleTapLeftAction,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Left action: $doubleTapLeftAction')),
                  ),
                ),
                const StandardActionTile(
                  title: 'Double tap (center)',
                  subtitle: 'Play/Pause',
                ),
                StandardActionTile(
                  title: 'Double tap (right)',
                  subtitle: doubleTapRightAction,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Right action: $doubleTapRightAction')),
                  ),
                ),
                CustomSwitchTile(
                  title: 'Use single tap for center gesture',
                  subtitle: 'Use a single tap in the center for gestures (like play/pause) instead of a double tap.',
                  value: centerGestureSingleTap,
                  onChanged: (_) => ref.read(_centerGestureSingleTapProvider.notifier).toggle(),
                ),
                const InfoBlock(
                  text:
                      'You can bind custom actions to these gestures in input.conf using the following key codes:\n\n'
                      'Left: MBTN_LEFT_DBL\n'
                      'Center: MBTN_MID_DBL\n'
                      'Right: MBTN_RIGHT_DBL',
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Media controls',
              skipDividerAfter: {6},
              children: [
                const StandardActionTile(
                  title: 'Previous',
                  subtitle: 'Seek',
                ),
                const StandardActionTile(
                  title: 'Play/Pause',
                  subtitle: 'Play/Pause',
                ),
                const StandardActionTile(
                  title: 'Next',
                  subtitle: 'Seek',
                ),
                CustomSwitchTile(
                  title: 'Double tap',
                  value: mediaControlsDoubleTap,
                  onChanged: (_) => ref.read(_mediaControlsDoubleTapProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Single tap',
                  value: mediaControlsSingleTap,
                  onChanged: (_) => ref.read(_mediaControlsSingleTapProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Long press',
                  value: mediaControlsLongPress,
                  onChanged: (_) => ref.read(_mediaControlsLongPressProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Swipe',
                  value: mediaControlsSwipe,
                  onChanged: (_) => ref.read(_mediaControlsSwipeProvider.notifier).toggle(),
                ),
                const InfoBlock(
                  text:
                      'You can bind custom actions to media controls in input.conf using the following key codes:\n\n'
                      'Previous: PREV\n'
                      'Play/Pause: PLAYPAUSE\n'
                      'Next: NEXT',
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
