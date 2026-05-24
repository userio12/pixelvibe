import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entities/recently_played_entity.dart';
part 'recently_played_dao.g.dart';

@DriftAccessor(tables: [RecentlyPlayed])
class RecentlyPlayedDao extends DatabaseAccessor<AppDatabase> with _$RecentlyPlayedDaoMixin {
  RecentlyPlayedDao(super.db);

  Future<List<RecentlyPlayedData>> recentItems(int limit) {
    return (select(recentlyPlayed)
      ..orderBy([(t) => OrderingTerm(expression: t.playedAt, mode: OrderingMode.desc)])
      ..limit(limit))
    .get();
  }

  Future<void> record(String filePath, String? title, String? thumbnailPath) {
    return into(recentlyPlayed).insert(
      RecentlyPlayedCompanion(
        filePath: Value(filePath),
        title: Value(title),
        thumbnailPath: Value(thumbnailPath),
        playedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
