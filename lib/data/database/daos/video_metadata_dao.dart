import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entities/video_metadata_entity.dart';
part 'video_metadata_dao.g.dart';

@DriftAccessor(tables: [VideoMetadata])
class VideoMetadataDao extends DatabaseAccessor<AppDatabase> with _$VideoMetadataDaoMixin {
  VideoMetadataDao(super.db);

  Future<VideoMetadataData?> findByPath(String path) {
    return (select(videoMetadata)..where((t) => t.filePath.equals(path))).getSingleOrNull();
  }

  Future<void> upsert(VideoMetadataCompanion companion) {
    return into(videoMetadata).insertOnConflictUpdate(companion);
  }

  Future<List<VideoMetadataData>> search(String query) {
    return (select(videoMetadata)..where((t) => t.title.like('%$query%'))).get();
  }

  Future<void> incrementPlayCount(String path) async {
    final existing = await findByPath(path);
    if (existing == null) return;
    await upsert(existing.copyWith(playCount: existing.playCount + 1).toCompanion(false));
  }

  Future<List<VideoMetadataData>> mostPlayed(int limit) {
    return (select(videoMetadata)
      ..orderBy([(t) => OrderingTerm(expression: t.playCount, mode: OrderingMode.desc)])
      ..limit(limit))
    .get();
  }
}
