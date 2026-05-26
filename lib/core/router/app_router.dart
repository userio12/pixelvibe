import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/network_browser/network_browser_screen.dart';
import '../../presentation/network_browser/connection_form_screen.dart';
import '../../presentation/playlist/playlist_detail_screen.dart';
import '../../presentation/about/about_screen.dart';
import 'routes.dart';

class AppRouter {
  late final GoRouter router;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  AppRouter({
    required Widget browseScreen,
    required Widget playlistsScreen,
    required Widget settingsScreen,
    required Widget Function(String filePath) playerScreenBuilder,
  }) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.browse,
      routes: [
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
              path: Routes.settings,
              pageBuilder: (_, _) => NoTransitionPage(child: settingsScreen),
            ),
          ],
        ),
        GoRoute(
          path: '${Routes.player}/:filePath',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, state) {
            final filePath = Uri.decodeComponent(state.pathParameters['filePath'] ?? '');
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
          path: Routes.networkBrowser,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, _) => CustomTransitionPage(
            key: ValueKey(Routes.networkBrowser),
            child: const NetworkBrowserScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
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
    if (location.startsWith(Routes.settings)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(location), child: child),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(location),
        onDestinationSelected: (i) {
          final paths = [Routes.browse, Routes.playlists, Routes.settings];
          context.go(paths[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.video_library_outlined), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.playlist_play_outlined), label: 'Playlists'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
