import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/di/providers.dart';
import 'player_provider.dart';

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
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('sub-auto', state ? 'all' : 'no');
    }
  }
}

// --- New subtitle styling providers ---

final subtitleFontFamilyProvider = NotifierProvider.autoDispose<SubtitleFontFamilyNotifier, String>(
  SubtitleFontFamilyNotifier.new,
);

class SubtitleFontFamilyNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getString('subtitle_font_family', '');
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setString('subtitle_font_family', v);
  }
}

final subtitleBoldProvider = NotifierProvider.autoDispose<SubtitleBoldNotifier, bool>(
  SubtitleBoldNotifier.new,
);

class SubtitleBoldNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool('subtitle_bold', false);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool('subtitle_bold', state);
  }
}

final subtitleItalicProvider = NotifierProvider.autoDispose<SubtitleItalicNotifier, bool>(
  SubtitleItalicNotifier.new,
);

class SubtitleItalicNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool('subtitle_italic', false);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool('subtitle_italic', state);
  }
}

final subtitleTextColorProvider = NotifierProvider.autoDispose<SubtitleTextColorNotifier, int>(
  SubtitleTextColorNotifier.new,
);

class SubtitleTextColorNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('subtitle_text_color', 0xFFFFFFFF);
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setInt('subtitle_text_color', v);
  }
}

final subtitleBgColorProvider = NotifierProvider.autoDispose<SubtitleBgColorNotifier, int>(
  SubtitleBgColorNotifier.new,
);

class SubtitleBgColorNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('subtitle_bg_color', 0xAA000000);
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setInt('subtitle_bg_color', v);
  }
}

enum SubtitleBorderStyle { none, dropShadow, outline }

final subtitleBorderStyleProvider = NotifierProvider.autoDispose<SubtitleBorderStyleNotifier, SubtitleBorderStyle>(
  SubtitleBorderStyleNotifier.new,
);

class SubtitleBorderStyleNotifier extends Notifier<SubtitleBorderStyle> {
  @override
  SubtitleBorderStyle build() {
    final v = ref.watch(preferencesServiceProvider).getString('subtitle_border_style', 'none');
    return SubtitleBorderStyle.values.firstWhere((e) => e.name == v, orElse: () => SubtitleBorderStyle.none);
  }

  Future<void> update(SubtitleBorderStyle v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setString('subtitle_border_style', v.name);
  }
}

final subtitleBorderColorProvider = NotifierProvider.autoDispose<SubtitleBorderColorNotifier, int>(
  SubtitleBorderColorNotifier.new,
);

class SubtitleBorderColorNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('subtitle_border_color', 0xFF000000);
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setInt('subtitle_border_color', v);
  }
}

final subScaleByWindowProvider = NotifierProvider.autoDispose<SubScaleByWindowNotifier, bool>(
  SubScaleByWindowNotifier.new,
);
class SubScaleByWindowNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getScaleByWindow();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setScaleByWindow(state);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('sub-scale-by-window', state ? 'yes' : 'no');
    }
  }
}

// --- mpv-side subtitle providers (via setProperty) ---

final subtitleJustifyProvider = NotifierProvider.autoDispose<SubtitleJustifyNotifier, int>(
  SubtitleJustifyNotifier.new,
);

class SubtitleJustifyNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('subtitle_justify', 0);
  Future<void> update(int v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setInt('subtitle_justify', v);
    _applyMpvProperty();
  }

  void _applyMpvProperty() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('sub-align-x', state.toString());
    }
  }
}

final subtitleSecondaryProvider = NotifierProvider.autoDispose<SubtitleSecondaryNotifier, int>(
  SubtitleSecondaryNotifier.new,
);

class SubtitleSecondaryNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('subtitle_secondary_sid', -1);
  Future<void> update(int v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setInt('subtitle_secondary_sid', v);
    _applyMpvProperty();
  }

  void _applyMpvProperty() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('secondary-sid', state.toString());
    }
  }
}

final subtitleAssOverrideProvider = NotifierProvider.autoDispose<SubtitleAssOverrideNotifier, bool>(
  SubtitleAssOverrideNotifier.new,
);

class SubtitleAssOverrideNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool('subtitle_ass_override', false);
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setBool('subtitle_ass_override', state);
    _applyMpvProperty();
  }

  void _applyMpvProperty() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('sub-ass-override', state ? 'force' : 'no');
    }
  }
}

// --- Builder: converts all providers into a SubtitleViewConfiguration ---

final subtitleViewConfigProvider = Provider.autoDispose<SubtitleViewConfiguration>((ref) {
  final fontSize = ref.watch(subtitleFontSizeProvider);
  final position = ref.watch(subtitlePositionProvider);
  final fontFamily = ref.watch(subtitleFontFamilyProvider);
  final bold = ref.watch(subtitleBoldProvider);
  final italic = ref.watch(subtitleItalicProvider);
  final textColor = Color(ref.watch(subtitleTextColorProvider));
  final bgColor = Color(ref.watch(subtitleBgColorProvider));
  final borderStyle = ref.watch(subtitleBorderStyleProvider);
  final borderColor = Color(ref.watch(subtitleBorderColorProvider));

  final bottomPadding = (position / 100 * 60).clamp(8.0, 200.0);

  TextStyle style = TextStyle(
    fontSize: fontSize,
    fontFamily: fontFamily.isNotEmpty ? fontFamily : null,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: textColor,
    backgroundColor: bgColor,
    height: 1.4,
  );

  switch (borderStyle) {
    case SubtitleBorderStyle.dropShadow:
      style = style.copyWith(
        shadows: [
          Shadow(color: borderColor, offset: const Offset(1, 1), blurRadius: 2),
          Shadow(color: borderColor, offset: const Offset(-1, -1), blurRadius: 2),
          Shadow(color: borderColor, offset: const Offset(1, -1), blurRadius: 2),
          Shadow(color: borderColor, offset: const Offset(-1, 1), blurRadius: 2),
        ],
      );
    case SubtitleBorderStyle.outline:
      style = style.copyWith(
        shadows: [
          Shadow(color: borderColor, offset: const Offset(0, 0), blurRadius: 4),
          Shadow(color: borderColor, offset: const Offset(0, 0), blurRadius: 4),
        ],
      );
    case SubtitleBorderStyle.none:
      break;
  }

  return SubtitleViewConfiguration(
    style: style,
    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
    textAlign: TextAlign.center,
  );
});
