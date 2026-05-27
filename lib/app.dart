import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/player/player_screen.dart';
import 'presentation/playlist/playlist_list_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/settings/settings_provider.dart';
import 'core/di/providers.dart';
import 'data/repositories/media_repository.dart';
import 'services/app_localizations.dart';
import 'services/logger.dart';
import 'services/update_checker.dart';
import 'utils/permissions/permission_handler.dart';

class PixelvibeApp extends ConsumerStatefulWidget {
  const PixelvibeApp({super.key});

  @override
  ConsumerState<PixelvibeApp> createState() => _PixelvibeAppState();
}

class _PixelvibeAppState extends ConsumerState<PixelvibeApp> {
  late final AppRouter _appRouter;
  bool _deepLinkInitialized = false;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      preferencesService: preferencesService,
      homeScreen: const HomeScreen(),
      playlistsScreen: const PlaylistListScreen(),
      settingsScreen: const SettingsScreen(),
      playerScreenBuilder: (filePath) => PlayerScreen(filePath: filePath),
    );
    _checkUpdate();
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerAutoScan());
  }

  Future<void> _triggerAutoScan() async {
    try {
      final granted = await requestStoragePermission();
      if (!granted) return;
      if (!mounted) return;
      final repo = ref.read(mediaRepositoryProvider);
      await repo.scanDevice();
      Logger.info('Auto-scan completed');
    } catch (e) {
      Logger.error('Auto-scan failed', e);
    }
  }

  Future<void> _checkUpdate() async {
    if (!ref.read(preferencesServiceProvider).getAutoUpdateCheck()) return;
    final checker = UpdateChecker();
    final update = await checker.check();
    if (update == null || !mounted) return;
    showUpdateDialog(context, update);
  }

  Future<void> _initDeepLinks() async {
    if (_deepLinkInitialized) return;
    _deepLinkInitialized = true;
    try {
      final s = ref.read(deepLinkServiceProvider);
      s.onLink = (uri) {
        if (!mounted) return;
        final videoUrl = _extractVideoUrl(uri);
        if (videoUrl != null) {
          _appRouter.router.go('/player/${Uri.encodeComponent(videoUrl)}');
        }
      };
      await s.init();
    } catch (e) {
      Logger.error('DeepLink init', e);
    }
  }

  String? _extractVideoUrl(String uri) {
    final parsed = Uri.tryParse(uri);
    if (parsed == null) return null;
    if (parsed.scheme == 'pixelvibe' && parsed.host == 'play') {
      return parsed.queryParameters['url'];
    }
    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      final path = parsed.path;
      final videoExts = ['.mp4', '.mkv', '.avi', '.mov', '.webm', '.flv', '.wmv', '.m4v'];
      if (videoExts.any((e) => path.endsWith(e))) {
        return uri;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final useDynamicColor = ref.watch(dynamicColorProvider);
    final useAmoled = ref.watch(amoledModeProvider);
    final contrast = ref.watch(contrastLevelProvider);
    return MaterialApp.router(
      title: 'pixelvibe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useDynamicColor: useDynamicColor, useAmoled: useAmoled, contrast: contrast),
      darkTheme: AppTheme.dark(useDynamicColor: useDynamicColor, useAmoled: useAmoled, contrast: contrast),
      themeMode: themeMode,
      routerConfig: _appRouter.router,
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
