import 'package:drift/drift.dart';

class PlaybackStates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  IntColumn get positionMs => integer()();
  IntColumn get durationMs => integer()();
  IntColumn get lastPlayedAt => integer()();
}
