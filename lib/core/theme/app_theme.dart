import 'package:flutter/material.dart';
import 'app_theme_extensions.dart';

class AppTheme {
  static const _defaultSeed = Color(0xFF6750A4);

  static const Map<String, Color> themeSwatches = {
    'Default': Color(0xFF6750A4),
    'Dynamic': Color(0xFF71C4D4),
    'Catppuccin': Color(0xFFCBA6F7),
    'Cloud': Color(0xFF89DCEB),
    'Rose Pine': Color(0xFFEBBCBA),
    'Dracula': Color(0xFFBD93F9),
    'Nord': Color(0xFF81A1C1),
    'Solarized': Color(0xFF268BD2),
  };

  static Color _seedColor(String? swatch) =>
      swatch != null && themeSwatches.containsKey(swatch)
          ? themeSwatches[swatch]!
          : _defaultSeed;

  static ThemeData light({bool useDynamicColor = true, bool useAmoled = false, double contrast = 0.0, String? seedSwatch}) {
    final seed = _seedColor(seedSwatch);
    final colorScheme = useDynamicColor
        ? ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light, contrastLevel: contrast)
        : ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, brightness: Brightness.light);
    final custom = useAmoled ? PixelvibeColors.amoled : PixelvibeColors.light;
    return ThemeData(
      useMaterial3: true,
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

  static ThemeData dark({bool useDynamicColor = true, bool useAmoled = false, double contrast = 0.0, String? seedSwatch}) {
    final seed = _seedColor(seedSwatch);
    final colorScheme = useDynamicColor
        ? ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark, contrastLevel: contrast)
        : ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, brightness: Brightness.dark);
    final custom = useAmoled ? PixelvibeColors.amoled : PixelvibeColors.dark;
    final surfaceColor = useAmoled ? Colors.black : colorScheme.surface;
    return ThemeData(
      useMaterial3: true,
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
