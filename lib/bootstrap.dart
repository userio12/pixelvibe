import 'package:shared_preferences/shared_preferences.dart';
import 'data/database/app_database.dart';
import 'services/preferences_service.dart';

late final AppDatabase database;
late final PreferencesService preferencesService;

Future<void> bootstrap() async {
  database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();
  preferencesService = PreferencesService(prefs);
}
