// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_connection_dao.dart';

// ignore_for_file: type=lint
mixin _$NetworkConnectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $NetworkConnectionsTable get networkConnections =>
      attachedDatabase.networkConnections;
  NetworkConnectionDaoManager get managers => NetworkConnectionDaoManager(this);
}

class NetworkConnectionDaoManager {
  final _$NetworkConnectionDaoMixin _db;
  NetworkConnectionDaoManager(this._db);
  $$NetworkConnectionsTableTableManager get networkConnections =>
      $$NetworkConnectionsTableTableManager(
        _db.attachedDatabase,
        _db.networkConnections,
      );
}
