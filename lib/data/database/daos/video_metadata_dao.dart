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
}
