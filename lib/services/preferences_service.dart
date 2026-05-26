import 'dart:convert';
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

  String getString(String key, [String defaultValue = '']) => _prefs.getString(key) ?? defaultValue;
  Future<void> setString(String key, String v) => _prefs.setString(key, v);
  double getDouble(String key, [double defaultValue = 0]) => _prefs.getDouble(key) ?? defaultValue;
  Future<void> setDouble(String key, double v) => _prefs.setDouble(key, v);
  int getInt(String key, [int defaultValue = 0]) => _prefs.getInt(key) ?? defaultValue;
  Future<void> setInt(String key, int v) => _prefs.setInt(key, v);
  bool getBool(String key, [bool defaultValue = false]) => _prefs.getBool(key) ?? defaultValue;
  Future<void> setBool(String key, bool v) => _prefs.setBool(key, v);

  String exportToJson() {
    final keys = _prefs.getKeys();
    final map = <String, dynamic>{};
    for (final key in keys) {
      final v = _prefs.get(key);
      if (v != null) map[key] = v;
    }
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<void> importFromJson(String json) async {
    final map = jsonDecode(json) as Map<String, dynamic>;
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is String) {
        await _prefs.setString(entry.key, v);
      } else if (v is bool) {
        await _prefs.setBool(entry.key, v);
      } else if (v is int) {
        await _prefs.setInt(entry.key, v);
      } else if (v is double) {
        await _prefs.setDouble(entry.key, v);
      }
    }
  }

  static const _seekbarStyle = 'seekbar_style';
  String getSeekbarStyle() => _prefs.getString(_seekbarStyle) ?? 'standard';
  Future<void> setSeekbarStyle(String v) => _prefs.setString(_seekbarStyle, v);

  // Control layout
  static const _topLeftControls = 'top_left_controls';
  static const _topRightControls = 'top_right_controls';
  static const _bottomCenterControls = 'bottom_center_controls';
  static const _defaultTopLeft = 'backArrow';
  static const _defaultTopRight = 'info,loadSubtitle,addToPlaylist,more,lock,pip,sleepTimer,volume';
  static const _defaultBottomCenter = 'skipBack,playPause,skipForward';

  String getTopLeftControls() => _prefs.getString(_topLeftControls) ?? _defaultTopLeft;
  Future<void> setTopLeftControls(String v) => _prefs.setString(_topLeftControls, v);
  String getTopRightControls() => _prefs.getString(_topRightControls) ?? _defaultTopRight;
  Future<void> setTopRightControls(String v) => _prefs.setString(_topRightControls, v);
  String getBottomCenterControls() => _prefs.getString(_bottomCenterControls) ?? _defaultBottomCenter;
  Future<void> setBottomCenterControls(String v) => _prefs.setString(_bottomCenterControls, v);

  // A-B loop
  // Volume normalization
  // Audio-only background
  static const _audioBackground = 'audio_background';
  bool getAudioBackground() => _prefs.getBool(_audioBackground) ?? false;
  Future<void> setAudioBackground(bool v) => _prefs.setBool(_audioBackground, v);

  static const _volumeNormalization = 'volume_normalization';
  bool getVolumeNormalization() => _prefs.getBool(_volumeNormalization) ?? false;
  Future<void> setVolumeNormalization(bool v) => _prefs.setBool(_volumeNormalization, v);

  // Audio channel config
  static const _audioChannels = 'audio_channels';
  String getAudioChannels() => _prefs.getString(_audioChannels) ?? 'auto';
  Future<void> setAudioChannels(String v) => _prefs.setString(_audioChannels, v);

  static const _abLoopEnabled = 'ab_loop_enabled';
  bool getAbLoopEnabled() => _prefs.getBool(_abLoopEnabled) ?? false;
  Future<void> setAbLoopEnabled(bool v) => _prefs.setBool(_abLoopEnabled, v);

  // Close after end
  static const _closeAfterEnd = 'close_after_end';
  bool getCloseAfterEnd() => _prefs.getBool(_closeAfterEnd) ?? false;
  Future<void> setCloseAfterEnd(bool v) => _prefs.setBool(_closeAfterEnd, v);

  // Watched threshold
  static const _watchedThreshold = 'watched_threshold';
  int getWatchedThreshold() => _prefs.getInt(_watchedThreshold) ?? 95;
  Future<void> setWatchedThreshold(int v) => _prefs.setInt(_watchedThreshold, v);

  // Auto-update check
  static const _autoUpdateCheck = 'auto_update_check';
  bool getAutoUpdateCheck() => _prefs.getBool(_autoUpdateCheck) ?? true;
  Future<void> setAutoUpdateCheck(bool v) => _prefs.setBool(_autoUpdateCheck, v);

  // HTTP headers for streaming
  static const _httpHeaders = 'http_headers';
  String getHttpHeaders() => _prefs.getString(_httpHeaders) ?? '';
  Future<void> setHttpHeaders(String v) => _prefs.setString(_httpHeaders, v);

  // Per-file brightness
  static const _fileBrightnessPrefix = 'file_br_';
  double getFileBrightness(String path) => _prefs.getDouble('$_fileBrightnessPrefix$path') ?? 1.0;
  Future<void> setFileBrightness(String path, double v) => _prefs.setDouble('$_fileBrightnessPrefix$path', v);

  // Video quality
  static const _hwdec = 'hwdec';
  String getHwdec() => _prefs.getString(_hwdec) ?? 'auto';
  Future<void> setHwdec(String v) => _prefs.setString(_hwdec, v);

  static const _gpuApi = 'gpu_api';
  String getGpuApi() => _prefs.getString(_gpuApi) ?? 'auto';
  Future<void> setGpuApi(String v) => _prefs.setString(_gpuApi, v);

  static const _filterPreset = 'filter_preset';
  String getFilterPreset() => _prefs.getString(_filterPreset) ?? 'none';
  Future<void> setFilterPreset(String v) => _prefs.setString(_filterPreset, v);

  static const _mirror = 'mirror';
  bool getMirror() => _prefs.getBool(_mirror) ?? false;
  Future<void> setMirror(bool v) => _prefs.setBool(_mirror, v);

  static const _flip = 'flip';
  bool getFlip() => _prefs.getBool(_flip) ?? false;
  Future<void> setFlip(bool v) => _prefs.setBool(_flip, v);

  static const _brightness = 'video_brightness';
  int getVideoBrightness() => _prefs.getInt(_brightness) ?? 0;
  Future<void> setVideoBrightness(int v) => _prefs.setInt(_brightness, v);

  static const _contrast = 'video_contrast';
  int getVideoContrast() => _prefs.getInt(_contrast) ?? 0;
  Future<void> setVideoContrast(int v) => _prefs.setInt(_contrast, v);

  static const _saturation = 'video_saturation';
  int getVideoSaturation() => _prefs.getInt(_saturation) ?? 0;
  Future<void> setVideoSaturation(int v) => _prefs.setInt(_saturation, v);

  static const _gamma = 'video_gamma';
  int getVideoGamma() => _prefs.getInt(_gamma) ?? 0;
  Future<void> setVideoGamma(int v) => _prefs.setInt(_gamma, v);

  static const _shaderPreset = 'shader_preset';
  String getShaderPreset() => _prefs.getString(_shaderPreset) ?? 'none';
  Future<void> setShaderPreset(String v) => _prefs.setString(_shaderPreset, v);

  static const _screenshotSubs = 'screenshot_subs';
  bool getScreenshotSubs() => _prefs.getBool(_screenshotSubs) ?? true;
  Future<void> setScreenshotSubs(bool v) => _prefs.setBool(_screenshotSubs, v);

  static const _hrSeek = 'hr_seek';
  bool getHrSeek() => _prefs.getBool(_hrSeek) ?? true;
  Future<void> setHrSeek(bool v) => _prefs.setBool(_hrSeek, v);
}
