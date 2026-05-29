import 'base_preferences.dart';

mixin SubtitlePreferences on BasePreferences {
  static const _autoLoadSubtitles = 'auto_load_subtitles';
  static const _overrideAssSsa = 'override_ass_ssa';
  static const _scaleByWindow = 'scale_by_window';
  static const _subtitleLanguages = 'subtitle_languages';
  static const _subtitleFontsDirectory = 'subtitle_fonts_directory';
  static const _subtitleSaveLocation = 'subtitle_save_location';
  static const _subtitleSources = 'subtitle_sources';
  static const _screenshotSubs = 'screenshot_subs';

  bool getAutoLoadSubtitles() => getBool(_autoLoadSubtitles, true);
  Future<void> setAutoLoadSubtitles(bool v) => setBool(_autoLoadSubtitles, v);

  bool getOverrideAssSsa() => getBool(_overrideAssSsa, false);
  Future<void> setOverrideAssSsa(bool v) => setBool(_overrideAssSsa, v);

  bool getScaleByWindow() => getBool(_scaleByWindow, true);
  Future<void> setScaleByWindow(bool v) => setBool(_scaleByWindow, v);

  String getSubtitleLanguages() => getString(_subtitleLanguages, 'en');
  Future<void> setSubtitleLanguages(String v) => setString(_subtitleLanguages, v);

  String getSubtitleFontsDirectory() => getString(_subtitleFontsDirectory, '');
  Future<void> setSubtitleFontsDirectory(String v) => setString(_subtitleFontsDirectory, v);

  String getSubtitleSaveLocation() => getString(_subtitleSaveLocation, '');
  Future<void> setSubtitleSaveLocation(String v) => setString(_subtitleSaveLocation, v);

  String getSubtitleSources() => getString(_subtitleSources, 'opensubtitles,embedded,podnapisi');
  Future<void> setSubtitleSources(String v) => setString(_subtitleSources, v);

  bool getScreenshotSubs() => getBool(_screenshotSubs, true);
  Future<void> setScreenshotSubs(bool v) => setBool(_screenshotSubs, v);
}
