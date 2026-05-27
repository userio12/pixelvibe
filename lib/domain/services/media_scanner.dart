import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../models/media_file.dart';

class MediaScanner {
  List<String> get videoExtensions => ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'];

  MediaFile fromMetadata(VideoMetadataData meta) {
    final path = meta.filePath;
    final dot = path.lastIndexOf('.');
    final name = dot > 0 ? path.substring(0, dot) : path;
    return MediaFile(
      path: path,
      name: name.split('/').last.split('\\').last,
      extension: dot > 0 ? path.substring(dot + 1).toLowerCase() : '',
      contentUri: meta.contentUri,
      sizeBytes: 0,
      durationMs: meta.durationMs ?? 0,
      width: meta.width,
      height: meta.height,
      lastModified: DateTime.fromMillisecondsSinceEpoch(meta.addedAt),
      watched: meta.watched,
    );
  }

  VideoMetadataCompanion toMetadata(MediaFile file) {
    return VideoMetadataCompanion(
      filePath: Value(file.path),
      contentUri: Value(file.contentUri),
      title: Value(file.name),
      durationMs: Value(file.durationMs),
      width: Value(file.width),
      height: Value(file.height),
      addedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
  }
}
