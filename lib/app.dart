import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/browser/browser_screen.dart';
import 'presentation/player/player_screen.dart';
import 'presentation/playlist/playlist_list_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/settings/settings_provider.dart';
import 'services/app_localizations.dart';

class PixelvibeApp extends ConsumerWidget {
  const PixelvibeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final useDynamicColor = ref.watch(dynamicColorProvider);
    final useAmoled = ref.watch(amoledModeProvider);
    final contrast = ref.watch(contrastLevelProvider);
    final router = AppRouter(
      browseScreen: const BrowserScreen(),
      playlistsScreen: const PlaylistListScreen(),
      settingsScreen: const SettingsScreen(),
      playerScreenBuilder: (filePath) => PlayerScreen(filePath: filePath),
    );
    return MaterialApp.router(
      title: 'pixelvibe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useDynamicColor: useDynamicColor, useAmoled: useAmoled, contrast: contrast),
      darkTheme: AppTheme.dark(useDynamicColor: useDynamicColor, useAmoled: useAmoled, contrast: contrast),
      themeMode: themeMode,
      routerConfig: router.router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
    );
  }
}
