import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/network_browser/network_browser_screen.dart';
import '../../presentation/network_browser/connection_form_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/playlist/playlist_detail_screen.dart';
import '../../presentation/about/about_screen.dart';
import '../../services/preferences_service.dart';
import 'routes.dart';

class AppRouter {
  late final GoRouter router;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  AppRouter({
    required PreferencesService preferencesService,
    required Widget browseScreen,
    required Widget playlistsScreen,
    required Widget settingsScreen,
    required Widget Function(String filePath) playerScreenBuilder,
  }) {
    final onboardingComplete = preferencesService.isOnboardingComplete();
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: onboardingComplete ? Routes.browse : Routes.onboarding,
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
                onPressed: () => context.go(Routes.browse),
                child: const Text('Go to Browse'),
              ),
            ],
          ),
        ),
      ),
      redirect: (context, state) {
        final onOnboarding = state.matchedLocation == Routes.onboarding;
        final done = preferencesService.isOnboardingComplete();
        if (!done && !onOnboarding) return Routes.onboarding;
        if (done && onOnboarding) return Routes.browse;
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
              path: Routes.browse,
              pageBuilder: (_, _) => NoTransitionPage(child: browseScreen),
            ),
            GoRoute(
              path: Routes.playlists,
              pageBuilder: (_, _) => NoTransitionPage(child: playlistsScreen),
            ),
            GoRoute(
              path: Routes.networkBrowser,
              pageBuilder: (_, _) => NoTransitionPage(child: const NetworkBrowserScreen()),
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
      ],
    );
  }
}

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.startsWith(Routes.browse)) return 0;
    if (location.startsWith(Routes.playlists)) return 1;
    if (location.startsWith(Routes.networkBrowser)) return 2;
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
              Routes.browse,
              Routes.playlists,
              Routes.networkBrowser,
              Routes.settings,
            ];
            context.go(paths[i]);
          },
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.video_library_outlined), label: 'Browse'),
            NavigationDestination(icon: Icon(Icons.playlist_play_outlined), label: 'Playlists'),
            NavigationDestination(icon: Icon(Icons.cloud_outlined), label: 'Network'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
