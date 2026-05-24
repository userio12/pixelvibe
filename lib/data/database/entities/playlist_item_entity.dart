import 'package:drift/drift.dart';

class PlaylistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer()();
  TextColumn get filePath => text()();
  TextColumn get title => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get sortOrder => integer()();
  IntColumn get addedAt => integer()();
}
