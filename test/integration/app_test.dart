import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixelvibe/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Integration Test', () {
    testWidgets('Basic app flow: Launch, navigation, and settings', (tester) async {
      // Mock initial data
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'smart_subtitle_auto_select': true,
      });

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // 1. Verify we are on the Home screen
      expect(find.text('All Videos'), findsWidgets);
      expect(find.byType(NavigationBar), findsOneWidget);

      // 2. Navigate to Network tab
      final networkTab = find.byIcon(Icons.cloud_outlined);
      await tester.tap(networkTab);
      await tester.pumpAndSettle();
      expect(find.text('Stream Link'), findsOneWidget);

      // 3. Navigate to Playlists tab
      final playlistTab = find.byIcon(Icons.playlist_play_outlined);
      await tester.tap(playlistTab);
      await tester.pumpAndSettle();
      expect(find.text('Playlists'), findsOneWidget);

      // 4. Navigate to Settings
      final settingsTab = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // 5. Open Player Settings
      final playerSetting = find.text('Player');
      await tester.tap(playerSetting);
      await tester.pumpAndSettle();
      expect(find.text('Orientation, gestures and controls'), findsOneWidget);
      
      // 6. Test a toggle (Resume playback)
      final resumeToggle = find.text('Resume playback');
      expect(resumeToggle, findsOneWidget);
      await tester.tap(resumeToggle);
      await tester.pumpAndSettle();

      // Go back to home
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      final homeTab = find.byIcon(Icons.movie_outlined);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
      
      expect(find.text('All Videos'), findsWidgets);
    });
  });
}
