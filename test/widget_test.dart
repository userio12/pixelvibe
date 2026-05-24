import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixelvibe/app.dart';
import 'package:pixelvibe/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      await bootstrap();
    });
    await tester.pumpWidget(const ProviderScope(child: PixelvibeApp()));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
  });
}
