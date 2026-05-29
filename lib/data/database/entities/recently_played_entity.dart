import 'package:drift/drift.dart';

class RecentlyPlayed extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get title => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get playedAt => integer()();

  List<Index> get indexes => [Index('recent_played_at', 'CREATE INDEX recent_played_at ON recently_played (played_at)')];
}
