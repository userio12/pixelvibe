import 'package:drift/drift.dart';

class NetworkConnections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get protocol => text()();
  TextColumn get host => text()();
  IntColumn get port => integer()();
  TextColumn get username => text()();
  TextColumn get password => text()();
  TextColumn get path => text()();
  BoolColumn get autoConnect => boolean().withDefault(const Constant(false))();
}
