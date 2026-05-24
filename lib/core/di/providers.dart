import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bootstrap.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/playback_state_dao.dart';
import '../../data/database/daos/recently_played_dao.dart';
import '../../data/database/daos/video_metadata_dao.dart';
import '../../data/database/daos/network_connection_dao.dart';
import '../../data/database/daos/playlist_dao.dart';
import '../../services/preferences_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) => database);
final playbackStateDaoProvider = Provider<PlaybackStateDao>((ref) => ref.watch(databaseProvider).playbackStateDao);
final recentlyPlayedDaoProvider = Provider<RecentlyPlayedDao>((ref) => ref.watch(databaseProvider).recentlyPlayedDao);
final videoMetadataDaoProvider = Provider<VideoMetadataDao>((ref) => ref.watch(databaseProvider).videoMetadataDao);
final networkConnectionDaoProvider = Provider<NetworkConnectionDao>((ref) => ref.watch(databaseProvider).networkConnectionDao);
final playlistDaoProvider = Provider<PlaylistDao>((ref) => ref.watch(databaseProvider).playlistDao);

final preferencesServiceProvider = Provider<PreferencesService>((ref) => preferencesService);
