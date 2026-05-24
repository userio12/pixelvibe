import 'package:drift/drift.dart';

class RecentlyPlayed extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  TextColumn get title => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get playedAt => integer()();
}
