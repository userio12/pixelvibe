import 'package:flutter_test/flutter_test.dart';
import 'package:pixelvibe/domain/models/media_file.dart';
import 'package:pixelvibe/presentation/home/enums/view_mode.dart';
import 'package:pixelvibe/utils/media_filter_utils.dart';

void main() {
  final videos = [
    MediaFile(
      path: '/storage/Video1.mp4',
      name: 'Video1',
      extension: 'mp4',
      sizeBytes: 1000,
      durationMs: 60000,
      lastModified: DateTime(2023, 1, 1),
    ),
    MediaFile(
      path: '/storage/Movies/Action.mkv',
      name: 'Action',
      extension: 'mkv',
      sizeBytes: 5000,
      durationMs: 120000,
      lastModified: DateTime(2023, 2, 1),
    ),
    MediaFile(
      path: '/storage/Anime/Show.mp4',
      name: 'Show',
      extension: 'mp4',
      sizeBytes: 2000,
      durationMs: 30000,
      lastModified: DateTime(2023, 1, 15),
    ),
  ];

  group('MediaFilterUtils.applyFilters', () {
    test('filters by query', () {
      final result = MediaFilterUtils.applyFilters(
        videos: videos,
        query: 'action',
        sortMode: SortMode.name,
        ascending: true,
        filter: MediaTypeFilter.all,
      );
      expect(result, hasLength(1));
      expect(result.first.name, 'Action');
    });

    test('filters by directory', () {
      final result = MediaFilterUtils.applyFilters(
        videos: videos,
        query: '',
        sortMode: SortMode.name,
        ascending: true,
        filter: MediaTypeFilter.all,
        dir: '/storage/Movies',
      );
      expect(result, hasLength(1));
      expect(result.first.name, 'Action');
    });

    test('sorts by name ascending', () {
      final result = MediaFilterUtils.applyFilters(
        videos: videos,
        query: '',
        sortMode: SortMode.name,
        ascending: true,
        filter: MediaTypeFilter.all,
      );
      expect(result[0].name, 'Action');
      expect(result[1].name, 'Show');
      expect(result[2].name, 'Video1');
    });

    test('sorts by name descending', () {
      final result = MediaFilterUtils.applyFilters(
        videos: videos,
        query: '',
        sortMode: SortMode.name,
        ascending: false,
        filter: MediaTypeFilter.all,
      );
      expect(result[0].name, 'Video1');
      expect(result[1].name, 'Show');
      expect(result[2].name, 'Action');
    });

    test('sorts by size', () {
      final result = MediaFilterUtils.applyFilters(
        videos: videos,
        query: '',
        sortMode: SortMode.size,
        ascending: true,
        filter: MediaTypeFilter.all,
      );
      expect(result[0].sizeBytes, 1000);
      expect(result[1].sizeBytes, 2000);
      expect(result[2].sizeBytes, 5000);
    });

    test('sorts by date', () {
      final result = MediaFilterUtils.applyFilters(
        videos: videos,
        query: '',
        sortMode: SortMode.date,
        ascending: true,
        filter: MediaTypeFilter.all,
      );
      expect(result[0].name, 'Video1'); // Jan 1
      expect(result[1].name, 'Show');   // Jan 15
      expect(result[2].name, 'Action'); // Feb 1
    });
  });
}
