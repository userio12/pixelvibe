import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/media_repository.dart';
import '../../domain/models/media_file.dart';
import 'enums/view_mode.dart';

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(ViewModeNotifier.new);

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.grid;
  void update(ViewMode v) => state = v;
}

final browserProvider = FutureProvider<List<MediaFile>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.scanDevice();
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String q) => state = q;
}
