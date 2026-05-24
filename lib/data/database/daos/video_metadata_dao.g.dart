// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_metadata_dao.dart';

// ignore_for_file: type=lint
mixin _$VideoMetadataDaoMixin on DatabaseAccessor<AppDatabase> {
  $VideoMetadataTable get videoMetadata => attachedDatabase.videoMetadata;
  VideoMetadataDaoManager get managers => VideoMetadataDaoManager(this);
}

class VideoMetadataDaoManager {
  final _$VideoMetadataDaoMixin _db;
  VideoMetadataDaoManager(this._db);
  $$VideoMetadataTableTableManager get videoMetadata =>
      $$VideoMetadataTableTableManager(_db.attachedDatabase, _db.videoMetadata);
}
