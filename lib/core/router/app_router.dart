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
              builder: (_, _) => browseScreen,
            ),
            GoRoute(
              path: Routes.playlists,
              builder: (_, _) => playlistsScreen,
            ),
            GoRoute(
              path: Routes.settings,
              builder: (_, _) => settingsScreen,
            ),
          ],
        ),
        GoRoute(
          path: '${Routes.player}/:filePath',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, state) {
            final filePath = Uri.decodeComponent(state.pathParameters['filePath'] ?? '');
            return playerScreenBuilder(filePath);
          },
        ),
        GoRoute(
          path: Routes.networkBrowser,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) => const NetworkBrowserScreen(),
        ),
        GoRoute(
          path: Routes.networkConnectionForm,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) => const ConnectionFormScreen(),
        ),
        GoRoute(
          path: '${Routes.playlistDetail}/:playlistId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['playlistId'] ?? '') ?? 0;
            return PlaylistDetailScreen(playlistId: id);
          },
        ),
        GoRoute(
          path: Routes.about,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) => const AboutScreen(),
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
      body: child,
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
