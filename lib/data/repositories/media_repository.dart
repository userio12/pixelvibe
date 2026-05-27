import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/media_file.dart';
import '../../domain/services/media_scanner.dart';
import '../database/app_database.dart';
import '../database/daos/video_metadata_dao.dart';
import '../../core/di/providers.dart';
import '../../services/logger.dart';
import '../../services/scan_service.dart';

class MediaRepository {
  final VideoMetadataDao _dao;
  final MediaScanner _scanner;
  final ScanService _scanService;
  List<MediaFile> _videos = [];
  bool _scanned = false;

  MediaRepository(this._dao, this._scanner, this._scanService);

  bool get isScanned => _scanned;

  Future<List<MediaFile>> scanDevice({bool force = false}) async {
    if (_scanned && !force) return _videos;
    final rawVideos = await _scanService.scanVideos();

    final files = <MediaFile>[];
    for (final v in rawVideos) {
      try {
        final filePath = v['filePath'] as String? ?? '';
        final contentUri = v['path'] as String? ?? '';
        final displayName = v['displayName'] as String? ?? '';
        if (filePath.isEmpty) continue;

        final dot = filePath.lastIndexOf('.');
        final ext = dot > 0 ? filePath.substring(dot + 1).toLowerCase() : '';
        if (!_scanner.videoExtensions.contains(ext)) continue;

        final fileName = dot > 0 ? filePath.substring(0, dot) : filePath;
        final name = displayName.isNotEmpty
            ? (displayName.lastIndexOf('.') > 0
                ? displayName.substring(0, displayName.lastIndexOf('.'))
                : displayName)
            : fileName.split('/').last.split('\\').last;

        final file = MediaFile(
          path: filePath,
          name: name,
          extension: ext,
          contentUri: contentUri.isNotEmpty ? contentUri : null,
          sizeBytes: v['size'] as int? ?? 0,
          durationMs: v['durationMs'] as int? ?? 0,
          width: v['width'] as int?,
          height: v['height'] as int?,
          lastModified: v['lastModified'] != null
              ? DateTime.fromMillisecondsSinceEpoch(v['lastModified'] as int)
              : null,
        );
        files.add(file);

        await _dao.upsert(VideoMetadataCompanion(
          filePath: Value(filePath),
          contentUri: Value(contentUri.isNotEmpty ? contentUri : null),
          title: Value(name),
          durationMs: Value(file.durationMs),
          width: Value(file.width),
          height: Value(file.height),
          addedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
      } catch (e) {
        Logger.error('MediaRepository.scanDevice item error', e);
      }
    }

    _videos = files;
    _scanned = true;
    return files;
  }

  List<MediaFile> search(String query) {
    if (query.isEmpty) return _videos;
    final q = query.toLowerCase();
    return _videos.where((v) => v.name.toLowerCase().contains(q)).toList();
  }
}

final mediaRepositoryProvider = Provider.autoDispose<MediaRepository>((ref) {
  final dao = ref.watch(videoMetadataDaoProvider);
  final scanner = MediaScanner();
  final scanService = ScanService();
  return MediaRepository(dao, scanner, scanService);
});
