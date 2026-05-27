import 'package:flutter_test/flutter_test.dart';
import 'package:pixelvibe/domain/models/media_file.dart';

void main() {
  final baseFile = MediaFile(
    path: '/storage/videos/movie.mp4',
    name: 'movie.mp4',
    extension: 'mp4',
    sizeBytes: 1048576, // 1 MB
    durationMs: 60000,
  );

  group('MediaFile.directory', () {
    test('extracts directory from path', () {
      expect(baseFile.directory, '/storage/videos');
    });

    test('handles backslash paths', () {
      final file = MediaFile(
        path: 'C:\\Videos\\movie.mp4',
        name: 'movie.mp4',
        extension: 'mp4',
        sizeBytes: 0,
        durationMs: 0,
      );
      expect(file.directory, 'C:\\Videos');
    });

    test('root path', () {
      final file = MediaFile(
        path: '/movie.mp4',
        name: 'movie.mp4',
        extension: 'mp4',
        sizeBytes: 0,
        durationMs: 0,
      );
      expect(file.directory, '/');
    });
  });

  group('MediaFile.sizeFormatted', () {
    test('bytes', () {
      final file = MediaFile(
        path: '/a.txt', name: 'a.txt', extension: 'txt',
        sizeBytes: 500, durationMs: 0,
      );
      expect(file.sizeFormatted, '500 B');
    });

    test('kilobytes', () {
      final file = MediaFile(
        path: '/a.txt', name: 'a.txt', extension: 'txt',
        sizeBytes: 1536, durationMs: 0,
      );
      expect(file.sizeFormatted, '1.5 KB');
    });

    test('megabytes', () {
      final file = MediaFile(
        path: '/a.txt', name: 'a.txt', extension: 'txt',
        sizeBytes: 2097152, durationMs: 0,
      );
      expect(file.sizeFormatted, '2.0 MB');
    });

    test('gigabytes', () {
      final file = MediaFile(
        path: '/a.txt', name: 'a.txt', extension: 'txt',
        sizeBytes: 3221225472, durationMs: 0,
      );
      expect(file.sizeFormatted, '3.0 GB');
    });
  });

  group('MediaFile.resolutionLabel', () {
    test('null dimensions returns empty', () {
      expect(baseFile.resolutionLabel, '');
    });

    test('4K', () {
      final file = MediaFile(
        path: '/v.mp4', name: 'v.mp4', extension: 'mp4',
        sizeBytes: 0, durationMs: 0,
        width: 3840, height: 2160,
      );
      expect(file.resolutionLabel, '4K');
    });

    test('1080p', () {
      final file = MediaFile(
        path: '/v.mp4', name: 'v.mp4', extension: 'mp4',
        sizeBytes: 0, durationMs: 0,
        width: 1920, height: 1080,
      );
      expect(file.resolutionLabel, '1080p');
    });

    test('720p', () {
      final file = MediaFile(
        path: '/v.mp4', name: 'v.mp4', extension: 'mp4',
        sizeBytes: 0, durationMs: 0,
        width: 1280, height: 720,
      );
      expect(file.resolutionLabel, '720p');
    });

    test('custom resolution below 480p', () {
      final file = MediaFile(
        path: '/v.mp4', name: 'v.mp4', extension: 'mp4',
        sizeBytes: 0, durationMs: 0,
        width: 640, height: 360,
      );
      expect(file.resolutionLabel, '640x360');
    });
  });

  group('MediaFile.isVideo', () {
    for (final ext in ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v']) {
      test('$ext is video', () {
        final file = MediaFile(
          path: '/v.$ext', name: 'v.$ext', extension: ext,
          sizeBytes: 0, durationMs: 0,
        );
        expect(file.isVideo, isTrue);
      });
    }

    test('non-video extension', () {
      final file = MediaFile(
        path: '/a.txt', name: 'a.txt', extension: 'txt',
        sizeBytes: 0, durationMs: 0,
      );
      expect(file.isVideo, isFalse);
    });
  });

  group('MediaFile.isPlaylist', () {
    test('m3u is playlist', () {
      final file = MediaFile(
        path: '/p.m3u', name: 'p.m3u', extension: 'm3u',
        sizeBytes: 0, durationMs: 0,
      );
      expect(file.isPlaylist, isTrue);
    });

    test('m3u8 is playlist', () {
      final file = MediaFile(
        path: '/p.m3u8', name: 'p.m3u8', extension: 'm3u8',
        sizeBytes: 0, durationMs: 0,
      );
      expect(file.isPlaylist, isTrue);
    });
  });
}
