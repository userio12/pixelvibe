import '../domain/models/media_file.dart';
import '../presentation/home/enums/view_mode.dart';

class MediaFilterUtils {
  static List<MediaFile> applyFilters({
    required List<MediaFile> videos,
    required String query,
    required SortMode sortMode,
    required bool ascending,
    required MediaTypeFilter filter,
    String? dir,
  }) {
    var result = List<MediaFile>.from(videos);

    if (dir != null) {
      result = result.where((v) => v.directory == dir).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((v) => v.name.toLowerCase().contains(q)).toList();
    }

    switch (filter) {
      case MediaTypeFilter.video:
        result = result.where((v) => v.isVideo).toList();
      case MediaTypeFilter.playlist:
        result = result.where((v) => v.isPlaylist).toList();
      case MediaTypeFilter.all:
        break;
    }

    result.sort((a, b) {
      int cmp;
      switch (sortMode) {
        case SortMode.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortMode.date:
          final da = a.lastModified ?? DateTime(0);
          final db = b.lastModified ?? DateTime(0);
          cmp = da.compareTo(db);
        case SortMode.size:
          cmp = a.sizeBytes.compareTo(b.sizeBytes);
        case SortMode.type:
          cmp = a.extension.compareTo(b.extension);
      }
      return ascending ? cmp : -cmp;
    });

    return result;
  }
}
