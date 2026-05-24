import 'data/database/app_database.dart';

late final AppDatabase database;

Future<void> bootstrap() async {
  database = AppDatabase();
}
