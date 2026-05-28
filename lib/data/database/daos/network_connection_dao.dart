import 'package:drift/drift.dart';
import '../../../services/credential_service.dart';
import '../app_database.dart';
import '../entities/network_connection_entity.dart';
part 'network_connection_dao.g.dart';

@DriftAccessor(tables: [NetworkConnections])
class NetworkConnectionDao extends DatabaseAccessor<AppDatabase> with _$NetworkConnectionDaoMixin {
  NetworkConnectionDao(super.db);

  Future<List<NetworkConnection>> getAll() async {
    final connections = await select(networkConnections).get();
    final results = <NetworkConnection>[];
    for (final c in connections) {
      final pwd = await CredentialService.fetchPassword(c.id.toString());
      results.add(c.copyWith(password: pwd));
    }
    return results;
  }

  Future<void> insertOne(NetworkConnectionsCompanion companion) async {
    final password = companion.password.value;
    final id = await into(networkConnections).insert(companion.copyWith(
      password: const Value(''),
    ));
    await CredentialService.storePassword(id.toString(), password);
  }

  Future<void> deleteOne(int id) async {
    await (delete(networkConnections)..where((t) => t.id.equals(id))).go();
    await CredentialService.deletePassword(id.toString());
  }
}
