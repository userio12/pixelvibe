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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => await m.createAll(),
      onUpgrade: (m, from, to) async {
        // Add schema migrations here when schemaVersion is incremented
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'pixelvibe');
  }
}
