import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bootstrap.dart';
import '../../data/repositories/media_repository.dart';
import '../../domain/models/media_file.dart';
import '../../utils/permissions/permission_handler.dart';
import 'enums/view_mode.dart';

final currentDirectoryProvider = NotifierProvider.autoDispose<CurrentDirectoryNotifier, String?>(CurrentDirectoryNotifier.new);
class CurrentDirectoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void enter(String dir) => state = dir;
  void leave() => state = null;
}

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(ViewModeNotifier.new);

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.folder;
  void update(ViewMode v) => state = v;
}

final layoutProvider = NotifierProvider.autoDispose<LayoutNotifier, LayoutMode>(LayoutNotifier.new);
class LayoutNotifier extends Notifier<LayoutMode> {
  @override
  LayoutMode build() => LayoutMode.list;
  void update(LayoutMode v) => state = v;
}

final displayFieldsProvider = NotifierProvider.autoDispose<DisplayFieldsNotifier, Set<DisplayField>>(DisplayFieldsNotifier.new);
class DisplayFieldsNotifier extends Notifier<Set<DisplayField>> {
  static const _key = 'display_fields';

  @override
  Set<DisplayField> build() {
    final raw = preferencesService.getString(_key);
    if (raw.isEmpty) return {DisplayField.path, DisplayField.totalVideos, DisplayField.folderSize};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.map((e) => DisplayField.values.firstWhere((f) => f.name == e)).toSet();
    } catch (_) {
      return {DisplayField.path, DisplayField.totalVideos, DisplayField.folderSize};
    }
  }

  void toggle(DisplayField field) {
    final updated = Set<DisplayField>.from(state);
    if (updated.contains(field)) {
      updated.remove(field);
    } else {
      updated.add(field);
    }
    state = updated;
    _persist(updated);
  }

  Future<void> _persist(Set<DisplayField> fields) async {
    final encoded = jsonEncode(fields.map((f) => f.name).toList());
    await preferencesService.setString(_key, encoded);
  }
}

final homeProvider = FutureProvider.autoDispose<List<MediaFile>>((ref) async {
  final granted = await requestStoragePermission();
  if (!granted) throw Exception('Storage permission denied. Please grant video access in your device settings.');

  final repo = ref.watch(mediaRepositoryProvider);
  return repo.scanDevice();
});

final searchQueryProvider = NotifierProvider.autoDispose<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  void update(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = q;
    });
  }
}

final sortModeProvider = NotifierProvider.autoDispose<SortModeNotifier, SortMode>(SortModeNotifier.new);
class SortModeNotifier extends Notifier<SortMode> {
  @override
  SortMode build() => SortMode.name;
  void update(SortMode m) => state = m;
}

final sortAscendingProvider = NotifierProvider.autoDispose<SortAscendingNotifier, bool>(SortAscendingNotifier.new);
class SortAscendingNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final mediaTypeFilterProvider = NotifierProvider.autoDispose<MediaTypeFilterNotifier, MediaTypeFilter>(MediaTypeFilterNotifier.new);
class MediaTypeFilterNotifier extends Notifier<MediaTypeFilter> {
  @override
  MediaTypeFilter build() => MediaTypeFilter.all;
  void update(MediaTypeFilter f) => state = f;
}

final filteredVideosProvider = FutureProvider.autoDispose<List<MediaFile>>((ref) async {
  final videos = await ref.watch(homeProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final sortMode = ref.watch(sortModeProvider);
  final ascending = ref.watch(sortAscendingProvider);
  final filter = ref.watch(mediaTypeFilterProvider);
  final dir = ref.watch(currentDirectoryProvider);

  var result = videos;

  if (dir != null) {
    result = result.where((v) => v.directory == dir).toList();
  }

  if (query.isNotEmpty) {
    result = result.where((v) => v.name.toLowerCase().contains(query)).toList();
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
});

final folderListProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final videos = await ref.watch(homeProvider.future);
  final dirs = videos.map((v) => v.directory).toSet().toList()..sort();
  return dirs;
});
