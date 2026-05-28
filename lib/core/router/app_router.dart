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
import '../../presentation/settings/sections/subtitles_screen.dart';
import '../../presentation/settings/sections/decoder_screen.dart';
import '../../presentation/settings/sections/advanced_screen.dart';
import '../../presentation/settings/sections/appearance_screen.dart';
import '../../presentation/settings/sections/player_layout_screen.dart';
import '../../services/preferences_service.dart';
import 'routes.dart';

class AppRouter {
  late final GoRouter router;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => ScaffoldWithNav(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.home,
                  builder: (_, _) => homeScreen,
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.playlists,
                  builder: (_, _) => playlistsScreen,
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.network,
                  builder: (_, _) => const NetworkScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.settings,
                  builder: (_, _) => settingsScreen,
                ),
              ],
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
            child: const AppearanceScreen(),
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
            child: const PlayerLayoutScreen(),
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
            child: const DecoderScreen(),
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
            child: const SubtitlesScreen(),
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
            child: const AdvancedScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
      ],
    );
  }
}

class ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => navigationShell.goBranch(i),
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
