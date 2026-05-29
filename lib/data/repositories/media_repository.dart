import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
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
  Completer<List<MediaFile>>? _scanInProgress;

  MediaRepository(this._dao, this._scanner, this._scanService);

  bool get isScanned => _scanned;

  Future<List<MediaFile>> scanDevice({bool force = false}) async {
    if (_scanned && !force) return _videos;
    if (_scanInProgress != null) return _scanInProgress!.future;
    _scanInProgress = Completer<List<MediaFile>>();
    try {
      final rawVideos = await _scanService.scanVideos();

      final result = await compute(_processVideosInIsolate, {
        'rawVideos': rawVideos,
        'videoExtensions': _scanner.videoExtensions,
      });
      final files = result.files;
      final companions = result.companions;

      await _dao.upsertBatch(companions);

      _videos = files;
      _scanned = true;
      _scanInProgress!.complete(files);
      return files;
    } catch (e) {
      _scanInProgress!.completeError(e);
      rethrow;
    } finally {
      _scanInProgress = null;
    }
  }

  static Future<({List<MediaFile> files, List<VideoMetadataCompanion> companions})> _processVideosInIsolate(Map<String, dynamic> params) async {
    final rawVideos = params['rawVideos'] as List<Map<String, dynamic>>;
    final videoExtensions = (params['videoExtensions'] as List<String>).toSet();
    
    final files = <MediaFile>[];
    final companions = <VideoMetadataCompanion>[];
    
    for (final v in rawVideos) {
      try {
        final filePath = v['filePath'] as String? ?? '';
        final contentUri = v['path'] as String? ?? '';
        final displayName = v['displayName'] as String? ?? '';
        
        if (filePath.isEmpty && contentUri.isEmpty) continue;

        final effectivePath = filePath.isNotEmpty ? filePath : contentUri;
        final dot = effectivePath.lastIndexOf('.');
        final ext = dot > 0 ? effectivePath.substring(dot + 1).toLowerCase() : '';
        
        if (filePath.isNotEmpty && !filePath.startsWith('content://')) {
          if (!videoExtensions.contains(ext)) continue;
        }

        final fileName = dot > 0 ? effectivePath.substring(0, dot) : effectivePath;
        final name = displayName.isNotEmpty
            ? (displayName.lastIndexOf('.') > 0
                ? displayName.substring(0, displayName.lastIndexOf('.'))
                : displayName)
            : fileName.split('/').last.split('\\').last;

        final file = MediaFile(
          path: filePath.isNotEmpty ? filePath : contentUri,
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

        companions.add(VideoMetadataCompanion(
          filePath: Value(file.path),
          contentUri: Value(contentUri.isNotEmpty ? contentUri : null),
          title: Value(name),
          durationMs: Value(file.durationMs),
          width: Value(file.width),
          height: Value(file.height),
          addedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
      } catch (e) {
        // Log locally or pass back errors
      }
    }
    return (files: files, companions: companions);
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
