import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/media_repository.dart';
import '../../domain/models/media_file.dart';
import '../../utils/permissions/permission_handler.dart';
import 'enums/view_mode.dart';

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(ViewModeNotifier.new);

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.grid;
  void update(ViewMode v) => state = v;
}

final browserProvider = FutureProvider<List<MediaFile>>((ref) async {
  final granted = await requestStoragePermission();
  if (!granted) return [];

  final repo = ref.watch(mediaRepositoryProvider);
  return repo.scanDevice();
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

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

final filteredVideosProvider = FutureProvider<List<MediaFile>>((ref) async {
  final videos = await ref.watch(browserProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return videos;
  return videos.where((v) => v.name.toLowerCase().contains(query)).toList();
});
