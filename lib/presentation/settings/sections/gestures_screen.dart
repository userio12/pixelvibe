import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../settings_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/info_block.dart';

class GesturesScreen extends ConsumerWidget {
  const GesturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleTapSeekDuration = ref.watch(doubleTapSeekDurationProvider);
    final doubleTapSeekAreaWidth = ref.watch(doubleTapSeekAreaWidthProvider);
    final centerGestureSingleTap = ref.watch(centerGestureSingleTapProvider);
    final doubleTapLeftAction = ref.watch(doubleTapLeftActionProvider);
    final doubleTapRightAction = ref.watch(doubleTapRightActionProvider);
    final mediaControlsDoubleTap = ref.watch(mediaControlsDoubleTapProvider);
    final mediaControlsSingleTap = ref.watch(mediaControlsSingleTapProvider);
    final mediaControlsLongPress = ref.watch(mediaControlsLongPressProvider);
    final mediaControlsSwipe = ref.watch(mediaControlsSwipeProvider);

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
                _SliderTile(
                  title: 'Double tap seek duration',
                  subtitle: '${doubleTapSeekDuration}s',
                  value: doubleTapSeekDuration.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  labelSuffix: 's',
                  onChanged: (v) => ref.read(doubleTapSeekDurationProvider.notifier).update(v.round()),
                ),
                _SliderTile(
                  title: 'Double Tap Seek Area Width',
                  subtitle: 'Current: $doubleTapSeekAreaWidth%',
                  value: doubleTapSeekAreaWidth.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 8,
                  labelSuffix: '%',
                  onChanged: (v) => ref.read(doubleTapSeekAreaWidthProvider.notifier).update(v.round()),
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
                  onChanged: (_) => ref.read(centerGestureSingleTapProvider.notifier).toggle(),
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
                  onChanged: (_) => ref.read(mediaControlsDoubleTapProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Single tap',
                  value: mediaControlsSingleTap,
                  onChanged: (_) => ref.read(mediaControlsSingleTapProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Long press',
                  value: mediaControlsLongPress,
                  onChanged: (_) => ref.read(mediaControlsLongPressProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Swipe',
                  value: mediaControlsSwipe,
                  onChanged: (_) => ref.read(mediaControlsSwipeProvider.notifier).toggle(),
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

class _SliderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String labelSuffix;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelSuffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF90959A), fontSize: 13)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: const Color(0xFF71C4D4),
            inactiveColor: const Color(0xFF2C3136),
            label: '${value.round()}$labelSuffix',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
