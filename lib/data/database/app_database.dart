import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'entities/playback_state_entity.dart';
import 'entities/recently_played_entity.dart';
import 'entities/video_metadata_entity.dart';
import 'entities/network_connection_entity.dart';
import 'entities/playlist_entity.dart';
import 'entities/playlist_item_entity.dart';
import 'daos/playback_state_dao.dart';
import 'daos/recently_played_dao.dart';
import 'daos/video_metadata_dao.dart';
import 'daos/network_connection_dao.dart';
import 'daos/playlist_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PlaybackStates,
    RecentlyPlayed,
    VideoMetadata,
    NetworkConnections,
    Playlists,
    PlaylistItems,
  ],
  daos: [
    PlaybackStateDao,
    RecentlyPlayedDao,
    VideoMetadataDao,
    NetworkConnectionDao,
    PlaylistDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => await m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(videoMetadata, videoMetadata.contentUri);
          await m.addColumn(videoMetadata, videoMetadata.playCount);
          await m.addColumn(videoMetadata, videoMetadata.watched);
        }
        if (from < 3) {
          await m.createIndex(Index('video_added_at', 'CREATE INDEX video_added_at ON video_metadata (added_at)'));
          await m.createIndex(Index('recent_played_at', 'CREATE INDEX recent_played_at ON recently_played (played_at)'));
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'pixelvibe');
  }
}
