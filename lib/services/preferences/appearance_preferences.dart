import 'package:flutter/material.dart';
import 'base_preferences.dart';

mixin AppearancePreferences on BasePreferences {
  static const _themeMode = 'theme_mode';
  static const _dynamicColor = 'dynamic_color';
  static const _amoledMode = 'amoled_mode';
  static const _contrastLevel = 'contrast_level';
  static const _selectedThemeSwatch = 'selected_theme_swatch';

  ThemeMode getThemeMode() {
    final v = getString(_themeMode);
    if (v.isEmpty) return ThemeMode.system;
    return ThemeMode.values.firstWhere((e) => e.name == v, orElse: () => ThemeMode.system);
  }
  Future<void> setThemeMode(ThemeMode mode) => setString(_themeMode, mode.name);

  bool getDynamicColor() => getBool(_dynamicColor, true);
  Future<void> setDynamicColor(bool v) => setBool(_dynamicColor, v);

  bool getAmoledMode() => getBool(_amoledMode, false);
  Future<void> setAmoledMode(bool v) => setBool(_amoledMode, v);

  double getContrastLevel() => getDouble(_contrastLevel, 0.0);
  Future<void> setContrastLevel(double v) => setDouble(_contrastLevel, v);

  String getSelectedThemeSwatch() => getString(_selectedThemeSwatch, 'Default');
  Future<void> setSelectedThemeSwatch(String v) => setString(_selectedThemeSwatch, v);
}
