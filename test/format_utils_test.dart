import 'package:flutter_test/flutter_test.dart';
import 'package:pixelvibe/utils/format_utils.dart';

void main() {
  group('formatDuration', () {
    test('zero', () {
      expect(formatDuration(0), '00:00');
    });

    test('seconds only', () {
      expect(formatDuration(5000), '00:05');
      expect(formatDuration(59000), '00:59');
    });

    test('minutes and seconds', () {
      expect(formatDuration(60000), '01:00');
      expect(formatDuration(61000), '01:01');
      expect(formatDuration(3599000), '59:59');
    });

    test('hours', () {
      expect(formatDuration(3600000), '1h 00m');
      expect(formatDuration(3661000), '1h 01m');
      expect(formatDuration(7200000), '2h 00m');
    });

    test('rounds down', () {
      expect(formatDuration(999), '00:00');
      expect(formatDuration(1000), '00:01');
      expect(formatDuration(59999), '00:59');
    });
  });
}
