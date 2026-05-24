import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../models/media_file.dart';

class MediaScanner {
  List<String> get videoExtensions => ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'];

  MediaFile fromMetadata(VideoMetadataData meta) {
    final uri = Uri.parse(meta.filePath);
    final segments = uri.pathSegments;
    final name = segments.isNotEmpty ? segments.last : meta.filePath;
    final dot = name.lastIndexOf('.');
    return MediaFile(
      path: meta.filePath,
      name: dot > 0 ? name.substring(0, dot) : name,
      extension: dot > 0 ? name.substring(dot + 1).toLowerCase() : '',
      sizeBytes: 0,
      durationMs: meta.durationMs ?? 0,
      width: meta.width,
      height: meta.height,
      lastModified: DateTime.fromMillisecondsSinceEpoch(meta.addedAt),
    );
  }

  VideoMetadataCompanion toMetadata(MediaFile file) {
    return VideoMetadataCompanion(
      filePath: Value(file.path),
      title: Value(file.name),
      durationMs: Value(file.durationMs),
      width: Value(file.width),
      height: Value(file.height),
      addedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
  }
}
