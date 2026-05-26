import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._prefs);
  final SharedPreferences _prefs;

  static const _themeMode = 'theme_mode';
  static const _dynamicColor = 'dynamic_color';
  static const _defaultSpeed = 'default_speed';
  static const _resumePlayback = 'resume_playback';
  static const _autoPip = 'auto_pip';
  static const _skipInterval = 'skip_interval';
  static const _amoledMode = 'amoled_mode';
  static const _contrastLevel = 'contrast_level';
  static const _repeatMode = 'repeat_mode';
  static const _shuffleEnabled = 'shuffle_enabled';
  static const _autoplayNext = 'autoplay_next';
  static const _horizontalSwipeSeek = 'horizontal_swipe_seek';
  static const _brightnessGesture = 'brightness_gesture';
  static const _volumeGesture = 'volume_gesture';
  static const _pinchToZoomGesture = 'pinch_to_zoom_gesture';
  static const _doubleTapSeek = 'double_tap_seek';
  static const _gestureSensitivity = 'gesture_sensitivity';
  static const _playerOrientation = 'player_orientation';
  static const _reduceMotion = 'reduce_motion';
  static const _showTimeRemaining = 'show_time_remaining';

  ThemeMode getThemeMode() {
    final v = _prefs.getString(_themeMode);
    if (v == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere((e) => e.name == v, orElse: () => ThemeMode.system);
  }

  Future<void> setThemeMode(ThemeMode mode) => _prefs.setString(_themeMode, mode.name);

  bool getDynamicColor() => _prefs.getBool(_dynamicColor) ?? true;
  Future<void> setDynamicColor(bool v) => _prefs.setBool(_dynamicColor, v);

  double getDefaultSpeed() => _prefs.getDouble(_defaultSpeed) ?? 1.0;
  Future<void> setDefaultSpeed(double v) => _prefs.setDouble(_defaultSpeed, v);

  bool getResumePlayback() => _prefs.getBool(_resumePlayback) ?? true;
  Future<void> setResumePlayback(bool v) => _prefs.setBool(_resumePlayback, v);

  bool getAutoPip() => _prefs.getBool(_autoPip) ?? true;
  Future<void> setAutoPip(bool v) => _prefs.setBool(_autoPip, v);

  int getSkipInterval() => _prefs.getInt(_skipInterval) ?? 10;
  Future<void> setSkipInterval(int v) => _prefs.setInt(_skipInterval, v);

  bool getAmoledMode() => _prefs.getBool(_amoledMode) ?? false;
  Future<void> setAmoledMode(bool v) => _prefs.setBool(_amoledMode, v);

  double getContrastLevel() => _prefs.getDouble(_contrastLevel) ?? 0.0;
  Future<void> setContrastLevel(double v) => _prefs.setDouble(_contrastLevel, v);

  String getRepeatMode() => _prefs.getString(_repeatMode) ?? 'off';
  Future<void> setRepeatMode(String v) => _prefs.setString(_repeatMode, v);

  bool getShuffleEnabled() => _prefs.getBool(_shuffleEnabled) ?? false;
  Future<void> setShuffleEnabled(bool v) => _prefs.setBool(_shuffleEnabled, v);

  bool getAutoplayNext() => _prefs.getBool(_autoplayNext) ?? true;
  Future<void> setAutoplayNext(bool v) => _prefs.setBool(_autoplayNext, v);

  bool getHorizontalSwipeSeek() => _prefs.getBool(_horizontalSwipeSeek) ?? true;
  Future<void> setHorizontalSwipeSeek(bool v) => _prefs.setBool(_horizontalSwipeSeek, v);

  bool getBrightnessGesture() => _prefs.getBool(_brightnessGesture) ?? true;
  Future<void> setBrightnessGesture(bool v) => _prefs.setBool(_brightnessGesture, v);

  bool getVolumeGesture() => _prefs.getBool(_volumeGesture) ?? true;
  Future<void> setVolumeGesture(bool v) => _prefs.setBool(_volumeGesture, v);

  bool getPinchToZoomGesture() => _prefs.getBool(_pinchToZoomGesture) ?? true;
  Future<void> setPinchToZoomGesture(bool v) => _prefs.setBool(_pinchToZoomGesture, v);

  bool getDoubleTapSeek() => _prefs.getBool(_doubleTapSeek) ?? true;
  Future<void> setDoubleTapSeek(bool v) => _prefs.setBool(_doubleTapSeek, v);

  double getGestureSensitivity() => _prefs.getDouble(_gestureSensitivity) ?? 1.0;
  Future<void> setGestureSensitivity(double v) => _prefs.setDouble(_gestureSensitivity, v);

  String getPlayerOrientation() => _prefs.getString(_playerOrientation) ?? 'free';
  Future<void> setPlayerOrientation(String v) => _prefs.setString(_playerOrientation, v);

  bool getReduceMotion() => _prefs.getBool(_reduceMotion) ?? false;
  Future<void> setReduceMotion(bool v) => _prefs.setBool(_reduceMotion, v);

  bool getShowTimeRemaining() => _prefs.getBool(_showTimeRemaining) ?? false;
  Future<void> setShowTimeRemaining(bool v) => _prefs.setBool(_showTimeRemaining, v);

  double getDouble(String key, [double defaultValue = 0]) => _prefs.getDouble(key) ?? defaultValue;
  Future<void> setDouble(String key, double v) => _prefs.setDouble(key, v);
  int getInt(String key, [int defaultValue = 0]) => _prefs.getInt(key) ?? defaultValue;
  Future<void> setInt(String key, int v) => _prefs.setInt(key, v);
  bool getBool(String key, [bool defaultValue = false]) => _prefs.getBool(key) ?? defaultValue;
  Future<void> setBool(String key, bool v) => _prefs.setBool(key, v);
}
