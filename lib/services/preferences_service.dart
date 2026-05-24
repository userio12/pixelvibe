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
}
