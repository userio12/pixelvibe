import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/media_file.dart';

class MediaRepository {
  final List<MediaFile> _videos = [];
  bool _scanned = false;

  bool get isScanned => _scanned;

  Future<List<MediaFile>> scanDevice() async {
    // Phase 2 placeholder: returns empty list.
    // Will be wired to Android ContentResolver in a follow-up.
    _scanned = true;
    return _videos;
  }

  List<MediaFile> search(String query) {
    if (query.isEmpty) return _videos;
    final q = query.toLowerCase();
    return _videos.where((v) => v.name.toLowerCase().contains(q)).toList();
  }
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) => MediaRepository());
