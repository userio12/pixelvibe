import 'base_preferences.dart';

mixin GesturePreferences on BasePreferences {
  static const _horizontalSwipeSeek = 'horizontal_swipe_seek';
  static const _brightnessGesture = 'brightness_gesture';
  static const _volumeGesture = 'volume_gesture';
  static const _pinchToZoomGesture = 'pinch_to_zoom_gesture';
  static const _doubleTapSeek = 'double_tap_seek';
  static const _gestureSensitivity = 'gesture_sensitivity';
  static const _allowGesturesInPanels = 'allow_gestures_in_panels';
  static const _centerGestureSingleTap = 'center_gesture_single_tap';
  static const _doubleTapLeftAction = 'double_tap_left_action';
  static const _doubleTapRightAction = 'double_tap_right_action';
  static const _mediaControlsDoubleTap = 'media_controls_double_tap';
  static const _mediaControlsSingleTap = 'media_controls_single_tap';
  static const _mediaControlsLongPress = 'media_controls_long_press';
  static const _mediaControlsSwipe = 'media_controls_swipe';

  bool getHorizontalSwipeSeek() => getBool(_horizontalSwipeSeek, true);
  Future<void> setHorizontalSwipeSeek(bool v) => setBool(_horizontalSwipeSeek, v);

  bool getBrightnessGesture() => getBool(_brightnessGesture, true);
  Future<void> setBrightnessGesture(bool v) => setBool(_brightnessGesture, v);

  bool getVolumeGesture() => getBool(_volumeGesture, true);
  Future<void> setVolumeGesture(bool v) => setBool(_volumeGesture, v);

  bool getPinchToZoomGesture() => getBool(_pinchToZoomGesture, true);
  Future<void> setPinchToZoomGesture(bool v) => setBool(_pinchToZoomGesture, v);

  bool getDoubleTapSeek() => getBool(_doubleTapSeek, true);
  Future<void> setDoubleTapSeek(bool v) => setBool(_doubleTapSeek, v);

  double getGestureSensitivity() => getDouble(_gestureSensitivity, 1.0);
  Future<void> setGestureSensitivity(double v) => setDouble(_gestureSensitivity, v);

  bool getAllowGesturesInPanels() => getBool(_allowGesturesInPanels, false);
  Future<void> setAllowGesturesInPanels(bool v) => setBool(_allowGesturesInPanels, v);

  bool getCenterGestureSingleTap() => getBool(_centerGestureSingleTap, false);
  Future<void> setCenterGestureSingleTap(bool v) => setBool(_centerGestureSingleTap, v);

  String getDoubleTapLeftAction() => getString(_doubleTapLeftAction, 'Seek');
  Future<void> setDoubleTapLeftAction(String v) => setString(_doubleTapLeftAction, v);

  String getDoubleTapRightAction() => getString(_doubleTapRightAction, 'Seek');
  Future<void> setDoubleTapRightAction(String v) => setString(_doubleTapRightAction, v);

  bool getMediaControlsDoubleTap() => getBool(_mediaControlsDoubleTap, true);
  Future<void> setMediaControlsDoubleTap(bool v) => setBool(_mediaControlsDoubleTap, v);

  bool getMediaControlsSingleTap() => getBool(_mediaControlsSingleTap, true);
  Future<void> setMediaControlsSingleTap(bool v) => setBool(_mediaControlsSingleTap, v);

  bool getMediaControlsLongPress() => getBool(_mediaControlsLongPress, true);
  Future<void> setMediaControlsLongPress(bool v) => setBool(_mediaControlsLongPress, v);

  bool getMediaControlsSwipe() => getBool(_mediaControlsSwipe, true);
  Future<void> setMediaControlsSwipe(bool v) => setBool(_mediaControlsSwipe, v);
}
