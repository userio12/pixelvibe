import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/network/network_screen.dart';
import '../../presentation/network/connection_form_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/playlist/playlist_detail_screen.dart';
import '../../presentation/about/about_screen.dart';
import '../../presentation/settings/sections/folders_screen.dart';
import '../../presentation/settings/sections/audio_screen.dart';
import '../../presentation/settings/sections/player_settings_screen.dart';
import '../../presentation/settings/sections/gestures_screen.dart';
import '../../services/preferences_service.dart';
import 'routes.dart';

class AppRouter {
  late final GoRouter router;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  AppRouter({
    required PreferencesService preferencesService,
    required Widget homeScreen,
    required Widget playlistsScreen,
    required Widget settingsScreen,
    required Widget Function(String filePath) playerScreenBuilder,
  }) {
    final onboardingComplete = preferencesService.isOnboardingComplete();
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: onboardingComplete ? Routes.home : Routes.onboarding,
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 64),
              const SizedBox(height: 16),
              Text('Could not find: ${state.uri}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
      redirect: (context, state) {
        final onOnboarding = state.matchedLocation == Routes.onboarding;
        final done = preferencesService.isOnboardingComplete();
        if (!done && !onOnboarding) return Routes.onboarding;
        if (done && onOnboarding) return Routes.home;
        return null;
      },
      routes: [
        GoRoute(
          path: Routes.onboarding,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.onboarding),
            child: const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => ScaffoldWithNav(child: child),
          routes: [
            GoRoute(
              path: Routes.home,
              pageBuilder: (_, _) => NoTransitionPage(child: homeScreen),
            ),
            GoRoute(
              path: Routes.playlists,
              pageBuilder: (_, _) => NoTransitionPage(child: playlistsScreen),
            ),
            GoRoute(
              path: Routes.network,
              pageBuilder: (_, _) => NoTransitionPage(child: const NetworkScreen()),
            ),
            GoRoute(
              path: Routes.settings,
              pageBuilder: (_, _) => NoTransitionPage(child: settingsScreen),
            ),
          ],
        ),
        GoRoute(
          path: '${Routes.player}/:filePath',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, state) {
            final filePath = state.pathParameters['filePath'] ?? '';
            return CustomTransitionPage(
              key: state.pageKey,
              child: playerScreenBuilder(filePath),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOut))),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
            );
          },
        ),
        GoRoute(
          path: Routes.networkConnectionForm,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.networkConnectionForm),
            child: const ConnectionFormScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '${Routes.playlistDetail}/:playlistId',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, state) {
            final id = int.tryParse(state.pathParameters['playlistId'] ?? '') ?? 0;
            return CustomTransitionPage(
              key: state.pageKey,
              child: PlaylistDetailScreen(playlistId: id),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          },
        ),
        GoRoute(
          path: Routes.about,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.about),
            child: const AboutScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        // Settings sub-routes — builders replaced as each screen is created
        GoRoute(
          path: Routes.settingsAppearance,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsAppearance),
            child: const _PlaceholderScreen(title: 'Appearance'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsPlayerLayout,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsPlayerLayout),
            child: const _PlaceholderScreen(title: 'Player Layout'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsPlayer,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsPlayer),
            child: const PlayerSettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsGestures,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsGestures),
            child: const GesturesScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsFolders,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsFolders),
            child: const FoldersScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsDecoder,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsDecoder),
            child: const _PlaceholderScreen(title: 'Decoder'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsSubtitles,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsSubtitles),
            child: const _PlaceholderScreen(title: 'Subtitles'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsAudio,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsAudio),
            child: const AudioScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: Routes.settingsAdvanced,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.settingsAdvanced),
            child: const _PlaceholderScreen(title: 'Advanced'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
      ],
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: const TextStyle(color: Color(0xFF71C4D4))),
      ),
      body: const Center(
        child: Text(
          'Coming soon',
          style: TextStyle(color: Color(0xFF90959A), fontSize: 16),
        ),
      ),
    );
  }
}

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.startsWith(Routes.home)) return 0;
    if (location.startsWith(Routes.playlists)) return 1;
    if (location.startsWith(Routes.network)) return 2;
    if (location.startsWith(Routes.settings)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: IndexedStack(
        key: ValueKey(location),
        index: _currentIndex(location),
        children: [child],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: NavigationBar(
          selectedIndex: _currentIndex(location),
          onDestinationSelected: (i) {
            final paths = [
              Routes.home,
              Routes.playlists,
              Routes.network,
              Routes.settings,
            ];
            context.go(paths[i]);
          },
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.video_library_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.playlist_play_outlined), label: 'Playlists'),
            NavigationDestination(icon: Icon(Icons.cloud_outlined), label: 'Network'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
