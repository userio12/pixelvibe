import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entities/network_connection_entity.dart';
part 'network_connection_dao.g.dart';

@DriftAccessor(tables: [NetworkConnections])
class NetworkConnectionDao extends DatabaseAccessor<AppDatabase> with _$NetworkConnectionDaoMixin {
  NetworkConnectionDao(super.db);

  Future<List<NetworkConnection>> getAll() => select(networkConnections).get();

  Future<void> insertOne(NetworkConnectionsCompanion companion) {
    return into(networkConnections).insert(companion);
  }

  Future<void> deleteOne(int id) {
    return (delete(networkConnections)..where((t) => t.id.equals(id))).go();
  }
}
