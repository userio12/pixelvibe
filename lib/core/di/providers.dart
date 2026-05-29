import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bootstrap.dart' as bootstrap;
import '../../data/database/app_database.dart';
import '../../data/database/daos/playback_state_dao.dart';
import '../../data/database/daos/recently_played_dao.dart';
import '../../data/database/daos/video_metadata_dao.dart';
import '../../data/database/daos/network_connection_dao.dart';
import '../../data/database/daos/playlist_dao.dart';
import '../../services/deep_link_service.dart';
import '../../services/preferences_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) => bootstrap.database);
final playbackStateDaoProvider = Provider<PlaybackStateDao>((ref) => ref.watch(databaseProvider).playbackStateDao);
final recentlyPlayedDaoProvider = Provider<RecentlyPlayedDao>((ref) => ref.watch(databaseProvider).recentlyPlayedDao);
final videoMetadataDaoProvider = Provider<VideoMetadataDao>((ref) => ref.watch(databaseProvider).videoMetadataDao);
final networkConnectionDaoProvider = Provider<NetworkConnectionDao>((ref) => ref.watch(databaseProvider).networkConnectionDao);
final playlistDaoProvider = Provider<PlaylistDao>((ref) => ref.watch(databaseProvider).playlistDao);

final preferencesServiceProvider = Provider<PreferencesService>((ref) => bootstrap.preferencesService);

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final s = DeepLinkService();
  ref.onDispose(() => s.dispose());
  return s;
});

final videoMetadataByPathProvider = FutureProvider.family<VideoMetadataData?, String>(
  (ref, path) => ref.watch(videoMetadataDaoProvider).findByPath(path),
);
