import 'package:flutter_test/flutter_test.dart';
import 'package:pixelvibe/utils/subtitle_utils.dart';
import 'package:pixelvibe/domain/models/subtitle_file.dart';

void main() {
  group('parseSubtitleFile', () {
    test('parses .srt', () {
      final sub = parseSubtitleFile('/videos/sub.srt');
      expect(sub, isNotNull);
      expect(sub!.name, 'sub.srt');
      expect(sub.format, SubtitleFormat.srt);
    });

    test('parses .ass', () {
      final sub = parseSubtitleFile('/videos/sub.ass');
      expect(sub, isNotNull);
      expect(sub!.format, SubtitleFormat.ass);
    });

    test('parses .ssa', () {
      final sub = parseSubtitleFile('/videos/sub.ssa');
      expect(sub, isNotNull);
      expect(sub!.format, SubtitleFormat.ass);
    });

    test('parses .vtt', () {
      final sub = parseSubtitleFile('/videos/sub.vtt');
      expect(sub, isNotNull);
      expect(sub!.format, SubtitleFormat.vtt);
    });

    test('parses .webvtt', () {
      final sub = parseSubtitleFile('/videos/sub.webvtt');
      expect(sub, isNotNull);
      expect(sub!.format, SubtitleFormat.vtt);
    });

    test('unknown extension returns null', () {
      expect(parseSubtitleFile('/videos/sub.txt'), isNull);
      expect(parseSubtitleFile('/videos/file.mp4'), isNull);
    });

    test('extracts filename from path', () {
      final sub = parseSubtitleFile('/videos/subtitles/english.srt');
      expect(sub!.name, 'english.srt');
    });

    test('handles backslash paths', () {
      final sub = parseSubtitleFile('C:\\Videos\\sub.srt');
      expect(sub!.name, 'sub.srt');
    });
  });
}
