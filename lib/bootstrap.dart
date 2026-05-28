import 'package:shared_preferences/shared_preferences.dart';
import 'data/database/app_database.dart';
import 'services/preferences_service.dart';

AppDatabase get database => _database;
PreferencesService get preferencesService => _preferencesService;

late final AppDatabase _database;
late final PreferencesService _preferencesService;

Future<void> bootstrap() async {
  _database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();
  _preferencesService = PreferencesService(prefs);
}
