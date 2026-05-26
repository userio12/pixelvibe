import 'package:drift/drift.dart';

class VideoMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get title => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get codec => text().nullable()();
  TextColumn get bitrate => text().nullable()();
  IntColumn get addedAt => integer()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  BoolColumn get watched => boolean().withDefault(const Constant(false))();
}
