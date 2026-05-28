import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entities/playback_state_entity.dart';
part 'playback_state_dao.g.dart';

@DriftAccessor(tables: [PlaybackStates])
class PlaybackStateDao extends DatabaseAccessor<AppDatabase> with _$PlaybackStateDaoMixin {
  PlaybackStateDao(super.db);

  Future<PlaybackState?> findByPath(String path) {
    return (select(playbackStates)..where((t) => t.filePath.equals(path))).getSingleOrNull();
  }

  Future<void> upsertPosition(String path, int positionMs, int durationMs) {
    return into(playbackStates).insertOnConflictUpdate(
      PlaybackStatesCompanion(
        filePath: Value(path),
        positionMs: Value(positionMs),
        durationMs: Value(durationMs),
        lastPlayedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deleteByPath(String path) {
    return (delete(playbackStates)..where((t) => t.filePath.equals(path))).go();
  }
}
