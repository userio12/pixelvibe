import 'package:flutter_test/flutter_test.dart';
import 'package:pixelvibe/utils/m3u_parser.dart';

void main() {
  group('M3uParser.isM3uFile', () {
    test('detects .m3u', () {
      expect(M3uParser.isM3uFile('playlist.m3u'), isTrue);
    });

    test('detects .m3u8', () {
      expect(M3uParser.isM3uFile('playlist.m3u8'), isTrue);
    });

    test('rejects other extensions', () {
      expect(M3uParser.isM3uFile('video.mp4'), isFalse);
      expect(M3uParser.isM3uFile('audio.mp3'), isFalse);
      expect(M3uParser.isM3uFile('file.txt'), isFalse);
    });

    test('case insensitive', () {
      expect(M3uParser.isM3uFile('PLAYLIST.M3U'), isTrue);
    });
  });

  group('M3uParser.parse', () {
    test('parses basic playlist', () {
      const content = 'file1.mp4\nfile2.mp4\nfile3.mp4';
      final result = M3uParser.parse(content);
      expect(result.isExtended, isFalse);
      expect(result.entries, hasLength(3));
      expect(result.entries[0].path, 'file1.mp4');
      expect(result.entries[1].path, 'file2.mp4');
    });

    test('parses extended playlist', () {
      const content = '#EXTM3U\n#EXTINF:123,Test Title\n/video.mp4\n#EXTINF:456,Track 2\n/audio.mp3';
      final result = M3uParser.parse(content);
      expect(result.isExtended, isTrue);
      expect(result.entries, hasLength(2));
      expect(result.entries[0].title, 'Test Title');
      expect(result.entries[0].durationMs, 123000);
      expect(result.entries[0].path, '/video.mp4');
      expect(result.entries[1].title, 'Track 2');
      expect(result.entries[1].durationMs, 456000);
    });

    test('resolves relative paths with basePath', () {
      const content = 'subdir/video.mp4\n';
      final result = M3uParser.parse(content, basePath: '/videos');
      expect(result.entries[0].path, '/videos/subdir/video.mp4');
    });

    test('skips HTTP URLs with basePath', () {
      const content = 'https://example.com/video.mp4\nlocal.mp4\n';
      final result = M3uParser.parse(content, basePath: '/videos');
      expect(result.entries[0].path, 'https://example.com/video.mp4');
      expect(result.entries[1].path, '/videos/local.mp4');
    });

    test('ignores comments and blank lines', () {
      const content = '# comment\n  \nfile.mp4\n# another\n';
      final result = M3uParser.parse(content);
      expect(result.entries, hasLength(1));
      expect(result.entries[0].path, 'file.mp4');
    });

    test('empty content', () {
      final result = M3uParser.parse('');
      expect(result.entries, isEmpty);
      expect(result.isExtended, isFalse);
    });
  });

  group('M3uParser.generate', () {
    test('generates standard playlist', () {
      final entries = [
        const M3uEntry(path: 'file1.mp4'),
        const M3uEntry(path: 'file2.mp4'),
      ];
      final result = M3uParser.generate(entries);
      expect(result, contains('#EXTM3U\n'));
      expect(result, contains('file1.mp4\n'));
      expect(result, contains('file2.mp4'));
    });

    test('generates extended playlist', () {
      final entries = [
        const M3uEntry(path: 'video.mp4', title: 'Test', durationMs: 123000),
      ];
      final result = M3uParser.generate(entries);
      expect(result, contains('#EXTINF:123,Test\n'));
      expect(result, contains('video.mp4\n'));
    });
  });

  group('M3uPlaylist', () {
    test('isEmpty returns true for empty entries', () {
      final playlist = M3uPlaylist(isExtended: false, entries: []);
      expect(playlist.isEmpty, isTrue);
    });

    test('hasNetworkStreams detects HTTP', () {
      final playlist = M3uPlaylist(isExtended: false, entries: [
        const M3uEntry(path: 'https://example.com/video.mp4'),
      ]);
      expect(playlist.hasNetworkStreams, isTrue);
    });

    test('hasNetworkStreams detects RTMP', () {
      final playlist = M3uPlaylist(isExtended: false, entries: [
        const M3uEntry(path: 'rtmp://stream.example.com/live'),
      ]);
      expect(playlist.hasNetworkStreams, isTrue);
    });
  });

  group('M3uEntry.isNetworkStream', () {
    test('local file is not network', () {
      expect(const M3uEntry(path: '/storage/video.mp4').isNetworkStream, isFalse);
    });

    test('HTTP is network', () {
      expect(const M3uEntry(path: 'http://example.com/v.mp4').isNetworkStream, isTrue);
    });

    test('HTTPS is network', () {
      expect(const M3uEntry(path: 'https://example.com/v.mp4').isNetworkStream, isTrue);
    });

    test('RTMP is network', () {
      expect(const M3uEntry(path: 'rtmp://stream.tv/live').isNetworkStream, isTrue);
    });
  });
}
