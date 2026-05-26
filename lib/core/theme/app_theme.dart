import 'package:flutter/material.dart';
import 'app_theme_extensions.dart';

class AppTheme {
  static const _seedColor = Color(0xFF6750A4);

  static ThemeData light({bool useDynamicColor = true, bool useAmoled = false, double contrast = 0.0}) {
    final colorScheme = useDynamicColor
        ? ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light, contrastLevel: contrast)
        : ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, brightness: Brightness.light);
    final custom = useAmoled ? PixelvibeColors.amoled : PixelvibeColors.light;
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
      extensions: [custom, PixelvibeRippleConfig.light],
    );
  }

  static ThemeData dark({bool useDynamicColor = true, bool useAmoled = false, double contrast = 0.0}) {
    final colorScheme = useDynamicColor
        ? ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark, contrastLevel: contrast)
        : ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, brightness: Brightness.dark);
    final custom = useAmoled ? PixelvibeColors.amoled : PixelvibeColors.dark;
    final surfaceColor = useAmoled ? Colors.black : colorScheme.surface;
    return ThemeData(
      useMaterial3: useDynamicColor,
      colorScheme: colorScheme.copyWith(surface: surfaceColor),
      scaffoldBackgroundColor: useAmoled ? Colors.black : null,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: colorScheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: surfaceColor,
      ),
      cardTheme: CardThemeData(
        color: useAmoled ? const Color(0xFF0A0A0A) : null,
      ),
      extensions: [custom, PixelvibeRippleConfig.dark],
    );
  }
}
