import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

final subtitleFontSizeProvider = NotifierProvider.autoDispose<SubtitleFontSizeNotifier, double>(
  SubtitleFontSizeNotifier.new,
);

class SubtitleFontSizeNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getDouble('subtitle_font_size', 55);
  void update(double v) {
    state = v;
    ref.read(preferencesServiceProvider).setDouble('subtitle_font_size', v);
  }
}

final subtitlePositionProvider = NotifierProvider.autoDispose<SubtitlePositionNotifier, double>(
  SubtitlePositionNotifier.new,
);

class SubtitlePositionNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getDouble('subtitle_position', 100);
  void update(double v) {
    state = v;
    ref.read(preferencesServiceProvider).setDouble('subtitle_position', v);
  }
}

final subtitleDelayMsProvider = NotifierProvider.autoDispose<SubtitleDelayNotifier, int>(
  SubtitleDelayNotifier.new,
);

class SubtitleDelayNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('subtitle_delay_ms', 0);
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setInt('subtitle_delay_ms', v);
  }
}

final autoloadSubtitlesProvider = NotifierProvider.autoDispose<AutoloadSubtitlesNotifier, bool>(
  AutoloadSubtitlesNotifier.new,
);

class AutoloadSubtitlesNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool('autoload_subtitles', true);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool('autoload_subtitles', state);
  }
}
