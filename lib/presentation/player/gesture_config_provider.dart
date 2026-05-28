import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

final horizontalSwipeSeekProvider = NotifierProvider.autoDispose<HorizontalSwipeSeekNotifier, bool>(
  HorizontalSwipeSeekNotifier.new,
);

class HorizontalSwipeSeekNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getHorizontalSwipeSeek();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setHorizontalSwipeSeek(state);
  }
}

final brightnessGestureProvider = NotifierProvider.autoDispose<BrightnessGestureNotifier, bool>(
  BrightnessGestureNotifier.new,
);

class BrightnessGestureNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getBrightnessGesture();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBrightnessGesture(state);
  }
}

final volumeGestureProvider = NotifierProvider.autoDispose<VolumeGestureNotifier, bool>(
  VolumeGestureNotifier.new,
);

class VolumeGestureNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getVolumeGesture();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setVolumeGesture(state);
  }
}

final pinchToZoomGestureProvider = NotifierProvider.autoDispose<PinchToZoomGestureNotifier, bool>(
  PinchToZoomGestureNotifier.new,
);

class PinchToZoomGestureNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getPinchToZoomGesture();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setPinchToZoomGesture(state);
  }
}

final doubleTapSeekProvider = NotifierProvider.autoDispose<DoubleTapSeekNotifier, bool>(
  DoubleTapSeekNotifier.new,
);

class DoubleTapSeekNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getDoubleTapSeek();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setDoubleTapSeek(state);
  }
}

final gestureSensitivityProvider = NotifierProvider.autoDispose<GestureSensitivityNotifier, double>(
  GestureSensitivityNotifier.new,
);

class GestureSensitivityNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getGestureSensitivity();
  void update(double v) {
    state = v;
    ref.read(preferencesServiceProvider).setGestureSensitivity(v);
  }
}
