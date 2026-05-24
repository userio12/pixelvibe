import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/media_file.dart';
import '../../domain/services/media_scanner.dart';
import '../database/app_database.dart';
import '../database/daos/video_metadata_dao.dart';
import '../../core/di/providers.dart';
import '../../services/scan_service.dart';

class MediaRepository {
  final VideoMetadataDao _dao;
  final MediaScanner _scanner;
  final ScanService _scanService;
  List<MediaFile> _videos = [];
  bool _scanned = false;

  MediaRepository(this._dao, this._scanner, this._scanService);

  bool get isScanned => _scanned;

  Future<List<MediaFile>> scanDevice() async {
    final rawVideos = await _scanService.scanVideos();

    final files = <MediaFile>[];
    for (final v in rawVideos) {
      try {
        final path = v['path'] as String? ?? '';
        if (path.isEmpty) continue;
        final title = v['title'] as String? ?? '';
        final dot = title.lastIndexOf('.');
        final name = dot > 0 ? title.substring(0, dot) : title;
        final ext = path.split('.').last.toLowerCase();
        if (!_scanner.videoExtensions.contains(ext)) continue;

        final file = MediaFile(
          path: path,
          name: name,
          extension: ext,
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
          filePath: Value(path),
          title: Value(name),
          durationMs: Value(file.durationMs),
          width: Value(file.width),
          height: Value(file.height),
          addedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
      } catch (e) {
        debugPrint('MediaRepository.scanDevice item error: $e');
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

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final dao = ref.watch(videoMetadataDaoProvider);
  final scanner = MediaScanner();
  final scanService = ScanService();
  return MediaRepository(dao, scanner, scanService);
});
