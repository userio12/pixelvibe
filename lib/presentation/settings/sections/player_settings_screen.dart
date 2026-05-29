import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/player/gesture_config_provider.dart';
import '../../../utils/platform_helper.dart';
import '../settings_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/custom_slider_tile.dart';

String _sensitivityLevel(double s) {
  final v = (s * 50).round();
  if (v >= 67) return 'High';
  if (v >= 34) return 'Medium';
  return 'Low';
}

const _orientationOptions = [
  PlayerOrientation.video,
  PlayerOrientation.free,
  PlayerOrientation.landscape,
  PlayerOrientation.portrait,
];

String _orientationLabel(PlayerOrientation o) {
  switch (o) {
    case PlayerOrientation.video:
      return 'Video';
    case PlayerOrientation.free:
      return 'Free';
    case PlayerOrientation.landscape:
      return 'Landscape';
    case PlayerOrientation.portrait:
      return 'Portrait';
    default:
      return o.name;
  }
}

class PlayerSettingsScreen extends ConsumerWidget {
  const PlayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumePlaybackProvider);
    final closeAfterEnd = ref.watch(closeAfterEndProvider);
    final autoplayNext = ref.watch(autoplayNextProvider);
    final nextPrevNav = ref.watch(nextPrevNavProvider);
    final rememberBrightness = ref.watch(rememberBrightnessProvider);
    final autoPip = ref.watch(autoPipProvider);
    final keepScreenOn = ref.watch(keepScreenOnProvider);
    final showRipple = ref.watch(showRippleProvider);
    final showSeekTime = ref.watch(showSeekTimeProvider);
    final preciseSeek = ref.watch(hrSeekProvider);
    final brightnessGesture = ref.watch(brightnessGestureProvider);
    final volumeGesture = ref.watch(volumeGestureProvider);
    final pinchZoom = ref.watch(pinchToZoomGestureProvider);
    final horizontalSwipe = ref.watch(horizontalSwipeSeekProvider);
    final sensitivity = ref.watch(gestureSensitivityProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final allowPanels = ref.watch(allowGesturesInPanelsProvider);
    final swapVolBright = ref.watch(swapVolumeBrightnessProvider);
    final showLoading = ref.watch(showLoadingCircleProvider);
    final showStatus = ref.watch(showStatusBarProvider);
    final showNav = ref.watch(showNavBarProvider);
    final dynamicOverlay = ref.watch(dynamicSpeedOverlayProvider);
    final skipInterval = ref.watch(skipIntervalProvider);
    final playerOrientation = ref.watch(playerOrientationProvider);
    final holdSpeed = ref.watch(holdSpeedProvider);

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
          'Player',
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
              sectionTitle: 'General',
              children: [
                StandardActionTile(
                  title: 'Orientation',
                  subtitle: _orientationLabel(playerOrientation),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1E2227),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Orientation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFF2C3136)),
                            ..._orientationOptions.map((option) {
                              final selected = playerOrientation == option;
                              return ListTile(
                                title: Text(
                                  _orientationLabel(option),
                                  style: TextStyle(
                                    color: selected ? const Color(0xFF71C4D4) : Colors.white70,
                                  ),
                                ),
                                trailing: selected
                                    ? const Icon(Icons.check, color: Color(0xFF71C4D4))
                                    : null,
                                onTap: () {
                                  ref.read(playerOrientationProvider.notifier).setOrientation(option);
                                  Navigator.of(ctx).pop();
                                },
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    );
                  },
                ),
                CustomSwitchTile(
                  title: 'Save position on quit',
                  value: resume,
                  onChanged: (_) => ref.read(resumePlaybackProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Close after the end of playback',
                  value: closeAfterEnd,
                  onChanged: (_) => ref.read(closeAfterEndProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Autoplay next video',
                  subtitle: 'Automatically play next video when current ends',
                  value: autoplayNext,
                  onChanged: (_) => ref.read(autoplayNextProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Enable next/previous navigation',
                  subtitle: 'Show next/previous buttons for all videos in folder',
                  value: nextPrevNav,
                  onChanged: (_) => ref.read(nextPrevNavProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Remember display brightness',
                  value: rememberBrightness,
                  onChanged: (_) => ref.read(rememberBrightnessProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Auto Picture-in-Picture',
                  subtitle: 'Automatically enter PIP mode when pressing home or back',
                  value: autoPip,
                  onChanged: (_) => ref.read(autoPipProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Keep screen on when paused',
                  subtitle: 'Screen can turn off while video is paused',
                  value: keepScreenOn,
                  onChanged: (_) => ref.read(keepScreenOnProvider.notifier).toggle(),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Seeking',
              children: [
                CustomSwitchTile(
                  title: 'Show ripple when double tap seeking',
                  value: showRipple,
                  onChanged: (_) => ref.read(showRippleProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Show seek time',
                  value: showSeekTime,
                  onChanged: (_) => ref.read(showSeekTimeProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Use precise seeking',
                  value: preciseSeek,
                  onChanged: (_) => ref.read(hrSeekProvider.notifier).toggle(),
                ),
                CustomSliderTile(
                  title: 'Custom skip duration',
                  subtitle: 'Duration to skip forward on custom skip button ($skipInterval s)',
                  value: skipInterval.toDouble(),
                  min: 5,
                  max: 300,
                  divisions: 59,
                  onChanged: (v) => ref.read(skipIntervalProvider.notifier).update(v.round()),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Gestures',
              children: [
                CustomSwitchTile(
                  title: 'Brightness gestures',
                  value: brightnessGesture,
                  onChanged: (_) => ref.read(brightnessGestureProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Volume gestures',
                  value: volumeGesture,
                  onChanged: (_) => ref.read(volumeGestureProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Pinch to zoom',
                  value: pinchZoom,
                  onChanged: (_) => ref.read(pinchToZoomGestureProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Horizontal swipe to seek',
                  value: horizontalSwipe,
                  onChanged: (_) => ref.read(horizontalSwipeSeekProvider.notifier).toggle(),
                ),
                CustomSliderTile(
                  title: 'Horizontal swipe sensitivity',
                  subtitle: 'Current: ${(sensitivity * 50).round()}/100 (${_sensitivityLevel(sensitivity)})',
                  value: sensitivity,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (v) => ref.read(gestureSensitivityProvider.notifier).update(v),
                ),
                CustomSliderTile(
                  title: 'Hold for multi - x speed',
                  subtitle: '${holdSpeed.toStringAsFixed(2)}x',
                  value: holdSpeed,
                  min: 1.0,
                  max: 5.0,
                  divisions: 40,
                  onChanged: (v) => ref.read(holdSpeedProvider.notifier).update(v),
                ),
                CustomSwitchTile(
                  title: 'Dynamic Speed Overlay',
                  subtitle: 'Show advance overlay for speed control during long press and swipe',
                  value: dynamicOverlay,
                  onChanged: (_) => ref.read(dynamicSpeedOverlayProvider.notifier).toggle(),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Controls',
              children: [
                CustomSwitchTile(
                  title: 'Allow gestures in panels',
                  value: allowPanels,
                  onChanged: (_) => ref.read(allowGesturesInPanelsProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Swap volume and brightness slider',
                  value: swapVolBright,
                  onChanged: (_) => ref.read(swapVolumeBrightnessProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Show loading circle',
                  value: showLoading,
                  onChanged: (_) => ref.read(showLoadingCircleProvider.notifier).toggle(),
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Display',
              children: [
                CustomSwitchTile(
                  title: 'Show system status bar with controls',
                  value: showStatus,
                  onChanged: (_) => ref.read(showStatusBarProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Show navigation bar with controls',
                  value: showNav,
                  onChanged: (_) => ref.read(showNavBarProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Reduce player animation',
                  value: reduceMotion,
                  onChanged: (_) => ref.read(reduceMotionProvider.notifier).toggle(),
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
