import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entities/playlist_entity.dart';
import '../entities/playlist_item_entity.dart';
part 'playlist_dao.g.dart';

@DriftAccessor(tables: [Playlists, PlaylistItems])
class PlaylistDao extends DatabaseAccessor<AppDatabase> with _$PlaylistDaoMixin {
  PlaylistDao(super.db);

  Future<List<Playlist>> getAllPlaylists() => select(playlists).get();

  Future<int> createPlaylist(String name) {
    return into(playlists).insert(
      PlaylistsCompanion(
        name: Value(name),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        sortOrder: const Value(0),
      ),
    );
  }

  Future<void> deletePlaylist(int id) {
    return transaction(() async {
      await (delete(playlistItems)..where((t) => t.playlistId.equals(id))).go();
      await (delete(playlists)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<PlaylistItem>> getItems(int playlistId) {
    return (select(playlistItems)..where((t) => t.playlistId.equals(playlistId))).get();
  }

  Future<void> addItem(int playlistId, String filePath, String? title, int? durationMs) {
    return into(playlistItems).insert(
      PlaylistItemsCompanion(
        playlistId: Value(playlistId),
        filePath: Value(filePath),
        title: Value(title),
        durationMs: Value(durationMs),
        sortOrder: const Value(0),
        addedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
