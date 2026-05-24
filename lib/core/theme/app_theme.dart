import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF6750A4);

  static ThemeData light({bool useDynamicColor = true}) {
    final colorScheme = useDynamicColor
        ? ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light)
        : ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: useDynamicColor,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  static ThemeData dark({bool useDynamicColor = true}) {
    final colorScheme = useDynamicColor
        ? ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark)
        : ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: useDynamicColor,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
