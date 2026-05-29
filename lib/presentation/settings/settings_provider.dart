import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../core/di/providers.dart';
import '../../services/preferences_service.dart';
import '../../utils/platform_helper.dart';
import '../player/playlist_queue_provider.dart';
import '../player/player_provider.dart';

final themeModeProvider = NotifierProvider.autoDispose<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(preferencesServiceProvider).getThemeMode();
  void update(ThemeMode mode) {
    state = mode;
    ref.read(preferencesServiceProvider).setThemeMode(mode);
  }
}

final dynamicColorProvider = NotifierProvider.autoDispose<DynamicColorNotifier, bool>(DynamicColorNotifier.new);
class DynamicColorNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getDynamicColor();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setDynamicColor(state);
  }
}

final defaultSpeedProvider = NotifierProvider.autoDispose<DefaultSpeedNotifier, double>(DefaultSpeedNotifier.new);
class DefaultSpeedNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getDefaultSpeed();
  void update(double speed) {
    state = speed;
    ref.read(preferencesServiceProvider).setDefaultSpeed(speed);
  }
}

final resumePlaybackProvider = NotifierProvider.autoDispose<ResumePlaybackNotifier, bool>(ResumePlaybackNotifier.new);
class ResumePlaybackNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getResumePlayback();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setResumePlayback(state);
  }
}

final autoPipProvider = NotifierProvider.autoDispose<AutoPipNotifier, bool>(AutoPipNotifier.new);
class AutoPipNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAutoPip();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAutoPip(state);
  }
}

final skipIntervalProvider = NotifierProvider.autoDispose<SkipIntervalNotifier, int>(SkipIntervalNotifier.new);
class SkipIntervalNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getSkipInterval();
  void update(int seconds) {
    state = seconds;
    ref.read(preferencesServiceProvider).setSkipInterval(seconds);
  }
}

final amoledModeProvider = NotifierProvider.autoDispose<AmoledModeNotifier, bool>(AmoledModeNotifier.new);
class AmoledModeNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAmoledMode();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAmoledMode(state);
  }
}

final contrastLevelProvider = NotifierProvider.autoDispose<ContrastLevelNotifier, double>(ContrastLevelNotifier.new);
class ContrastLevelNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getContrastLevel();
  void update(double level) {
    state = level;
    ref.read(preferencesServiceProvider).setContrastLevel(level);
  }
}

final repeatModeProvider = NotifierProvider.autoDispose<LoopModeNotifier, LoopMode>(LoopModeNotifier.new);
class LoopModeNotifier extends Notifier<LoopMode> {
  @override
  LoopMode build() {
    final v = ref.watch(preferencesServiceProvider).getRepeatMode();
    return LoopMode.values.firstWhere((e) => e.name == v, orElse: () => LoopMode.off);
  }

  void setMode(LoopMode mode) {
    state = mode;
    ref.read(preferencesServiceProvider).setRepeatMode(mode.name);
  }

  void cycle() {
    final modes = LoopMode.values;
    final next = (modes.indexOf(state) + 1) % modes.length;
    setMode(modes[next]);
  }
}

final shuffleEnabledProvider = NotifierProvider.autoDispose<ShuffleEnabledNotifier, bool>(ShuffleEnabledNotifier.new);
class ShuffleEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShuffleEnabled();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShuffleEnabled(state);
    ref.read(playlistQueueProvider.notifier).toggleShuffle();
  }
}

final autoplayNextProvider = NotifierProvider.autoDispose<AutoplayNextNotifier, bool>(AutoplayNextNotifier.new);
class AutoplayNextNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAutoplayNext();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAutoplayNext(state);
  }
}

final playerOrientationProvider = NotifierProvider.autoDispose<PlayerOrientationNotifier, PlayerOrientation>(
  PlayerOrientationNotifier.new,
);
class PlayerOrientationNotifier extends Notifier<PlayerOrientation> {
  @override
  PlayerOrientation build() {
    final v = ref.watch(preferencesServiceProvider).getPlayerOrientation();
    return PlayerOrientation.values.firstWhere((e) => e.name == v, orElse: () => PlayerOrientation.free);
  }

  void setOrientation(PlayerOrientation orientation) {
    state = orientation;
    ref.read(preferencesServiceProvider).setPlayerOrientation(orientation.name);
    orientation.apply();
  }

  void reset() {
    setOrientation(PlayerOrientation.free);
  }
}

final reduceMotionProvider = NotifierProvider.autoDispose<ReduceMotionNotifier, bool>(ReduceMotionNotifier.new);
class ReduceMotionNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getReduceMotion();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setReduceMotion(state);
  }
}

final showTimeRemainingProvider = NotifierProvider.autoDispose<ShowTimeRemainingNotifier, bool>(
  ShowTimeRemainingNotifier.new,
);
class ShowTimeRemainingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowTimeRemaining();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowTimeRemaining(state);
  }
}

final selectedThemeSwatchProvider = NotifierProvider.autoDispose<SelectedThemeSwatchNotifier, String>(
  SelectedThemeSwatchNotifier.new,
);
class SelectedThemeSwatchNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getSelectedThemeSwatch();
  void update(String swatch) {
    state = swatch;
    ref.read(preferencesServiceProvider).setSelectedThemeSwatch(swatch);
  }
}

enum SeekbarStyle { standard, wavy, thick }

final seekbarStyleProvider = NotifierProvider.autoDispose<SeekbarStyleNotifier, SeekbarStyle>(
  SeekbarStyleNotifier.new,
);
class SeekbarStyleNotifier extends Notifier<SeekbarStyle> {
  @override
  SeekbarStyle build() {
    final v = ref.watch(preferencesServiceProvider).getSeekbarStyle();
    return SeekbarStyle.values.firstWhere((e) => e.name == v, orElse: () => SeekbarStyle.standard);
  }

  Future<void> update(SeekbarStyle style) async {
    state = style;
    await ref.read(preferencesServiceProvider).setSeekbarStyle(style.name);
  }
}

final audioBackgroundProvider = NotifierProvider.autoDispose<AudioBackgroundNotifier, bool>(
  AudioBackgroundNotifier.new,
);
class AudioBackgroundNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAudioBackground();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setAudioBackground(state);
  }
}

final audioPitchCorrectionProvider = NotifierProvider.autoDispose<AudioPitchCorrectionNotifier, bool>(
  AudioPitchCorrectionNotifier.new,
);
class AudioPitchCorrectionNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAudioPitchCorrection();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setAudioPitchCorrection(state);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty(
        'audio-pitch-correction',
        state ? 'yes' : 'no',
      );
    }
  }
}

final volumeNormalizationProvider = NotifierProvider.autoDispose<VolumeNormalizationNotifier, bool>(
  VolumeNormalizationNotifier.new,
);
class VolumeNormalizationNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getVolumeNormalization();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setVolumeNormalization(state);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty(
        'af',
        state ? 'dynaudnorm' : '',
      );
    }
  }
}

final closeAfterEndProvider = NotifierProvider.autoDispose<CloseAfterEndNotifier, bool>(CloseAfterEndNotifier.new);
class CloseAfterEndNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getCloseAfterEnd();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setCloseAfterEnd(state);
  }
}

final showRippleProvider = NotifierProvider.autoDispose<ShowRippleNotifier, bool>(ShowRippleNotifier.new);
class ShowRippleNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowRippleWhenSeeking();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowRippleWhenSeeking(state);
  }
}

final showSeekTimeProvider = NotifierProvider.autoDispose<ShowSeekTimeNotifier, bool>(ShowSeekTimeNotifier.new);
class ShowSeekTimeNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowSeekTime();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowSeekTime(state);
  }
}

final hrSeekProvider = NotifierProvider.autoDispose<HrSeekNotifier, bool>(HrSeekNotifier.new);
class HrSeekNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getHrSeek();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setHrSeek(state);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty(
        'hr-seek',
        state ? 'yes' : 'no',
      );
    }
  }
}

final rememberBrightnessProvider = NotifierProvider.autoDispose<RememberBrightnessNotifier, bool>(RememberBrightnessNotifier.new);
class RememberBrightnessNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getRememberBrightness();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setRememberBrightness(state);
  }
}

final keepScreenOnProvider = NotifierProvider.autoDispose<KeepScreenOnNotifier, bool>(KeepScreenOnNotifier.new);
class KeepScreenOnNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getKeepScreenOnWhenPaused();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setKeepScreenOnWhenPaused(state);
  }
}

final swapVolumeBrightnessProvider = NotifierProvider.autoDispose<SwapVolumeBrightnessNotifier, bool>(SwapVolumeBrightnessNotifier.new);
class SwapVolumeBrightnessNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getSwapVolumeBrightness();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setSwapVolumeBrightness(state);
  }
}

final showLoadingCircleProvider = NotifierProvider.autoDispose<ShowLoadingCircleNotifier, bool>(ShowLoadingCircleNotifier.new);
class ShowLoadingCircleNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowLoadingCircle();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowLoadingCircle(state);
  }
}

final showStatusBarProvider = NotifierProvider.autoDispose<ShowStatusBarNotifier, bool>(ShowStatusBarNotifier.new);
class ShowStatusBarNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowStatusBarWithControls();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowStatusBarWithControls(state);
  }
}

final showNavBarProvider = NotifierProvider.autoDispose<ShowNavBarNotifier, bool>(ShowNavBarNotifier.new);
class ShowNavBarNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowNavBarWithControls();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowNavBarWithControls(state);
  }
}

final dynamicSpeedOverlayProvider = NotifierProvider.autoDispose<DynamicSpeedOverlayNotifier, bool>(DynamicSpeedOverlayNotifier.new);
class DynamicSpeedOverlayNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getDynamicSpeedOverlay();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setDynamicSpeedOverlay(state);
  }
}

final holdSpeedProvider = NotifierProvider.autoDispose<HoldSpeedNotifier, double>(HoldSpeedNotifier.new);
class HoldSpeedNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getDouble('hold_speed', 2.0);
  void update(double v) {
    state = v;
    ref.read(preferencesServiceProvider).setDouble('hold_speed', v);
  }
}

final nextPrevNavProvider = NotifierProvider.autoDispose<NextPrevNavNotifier, bool>(NextPrevNavNotifier.new);
class NextPrevNavNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getEnableNextPrevNavigation();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setEnableNextPrevNavigation(state);
  }
}

final allowGesturesInPanelsProvider = NotifierProvider.autoDispose<AllowGesturesInPanelsNotifier, bool>(AllowGesturesInPanelsNotifier.new);
class AllowGesturesInPanelsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAllowGesturesInPanels();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAllowGesturesInPanels(state);
  }
}

final gpuNextProvider = NotifierProvider.autoDispose<GpuNextNotifier, bool>(GpuNextNotifier.new);
class GpuNextNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getGpuNext();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setGpuNext(state);
  }
}

final yuv420pProvider = NotifierProvider.autoDispose<Yuv420pNotifier, bool>(Yuv420pNotifier.new);
class Yuv420pNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getYuv420p();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setYuv420p(state);
  }
}

final anime4kProvider = NotifierProvider.autoDispose<Anime4kNotifier, bool>(Anime4kNotifier.new);
class Anime4kNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAnime4k();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAnime4k(state);
  }
}

final debandingProvider = NotifierProvider.autoDispose<DebandingNotifier, String>(DebandingNotifier.new);
class DebandingNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getDebanding();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setDebanding(v);
  }
}

final doubleTapSeekDurationProvider = NotifierProvider.autoDispose<DoubleTapSeekDurationNotifier, int>(DoubleTapSeekDurationNotifier.new);
class DoubleTapSeekDurationNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getDoubleTapSeekDuration();
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setDoubleTapSeekDuration(v);
  }
}

final doubleTapSeekAreaWidthProvider = NotifierProvider.autoDispose<DoubleTapSeekAreaWidthNotifier, int>(DoubleTapSeekAreaWidthNotifier.new);
class DoubleTapSeekAreaWidthNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getDoubleTapSeekAreaWidth();
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setDoubleTapSeekAreaWidth(v);
  }
}

final centerGestureSingleTapProvider = NotifierProvider.autoDispose<CenterGestureSingleTapNotifier, bool>(CenterGestureSingleTapNotifier.new);
class CenterGestureSingleTapNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getCenterGestureSingleTap();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setCenterGestureSingleTap(state);
  }
}

final doubleTapLeftActionProvider = NotifierProvider.autoDispose<DoubleTapLeftActionNotifier, String>(DoubleTapLeftActionNotifier.new);
class DoubleTapLeftActionNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getDoubleTapLeftAction();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setDoubleTapLeftAction(v);
  }
}

final doubleTapRightActionProvider = NotifierProvider.autoDispose<DoubleTapRightActionNotifier, String>(DoubleTapRightActionNotifier.new);
class DoubleTapRightActionNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getDoubleTapRightAction();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setDoubleTapRightAction(v);
  }
}

final mediaControlsDoubleTapProvider = NotifierProvider.autoDispose<MediaControlsDoubleTapNotifier, bool>(MediaControlsDoubleTapNotifier.new);
class MediaControlsDoubleTapNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getMediaControlsDoubleTap();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setMediaControlsDoubleTap(state);
  }
}

final mediaControlsSingleTapProvider = NotifierProvider.autoDispose<MediaControlsSingleTapNotifier, bool>(MediaControlsSingleTapNotifier.new);
class MediaControlsSingleTapNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getMediaControlsSingleTap();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setMediaControlsSingleTap(state);
  }
}

final mediaControlsLongPressProvider = NotifierProvider.autoDispose<MediaControlsLongPressNotifier, bool>(MediaControlsLongPressNotifier.new);
class MediaControlsLongPressNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getMediaControlsLongPress();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setMediaControlsLongPress(state);
  }
}

final mediaControlsSwipeProvider = NotifierProvider.autoDispose<MediaControlsSwipeNotifier, bool>(MediaControlsSwipeNotifier.new);
class MediaControlsSwipeNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getMediaControlsSwipe();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setMediaControlsSwipe(state);
  }
}

final volumeBoostCapProvider = NotifierProvider.autoDispose<VolumeBoostCapNotifier, double>(VolumeBoostCapNotifier.new);
class VolumeBoostCapNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getVolumeBoostCap();
  void update(double v) {
    state = v;
    ref.read(preferencesServiceProvider).setVolumeBoostCap(v);
  }
}

final preferredAudioLanguagesProvider = NotifierProvider.autoDispose<PreferredAudioLanguagesNotifier, List<String>>(
  PreferredAudioLanguagesNotifier.new,
);
class PreferredAudioLanguagesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final raw = ref.watch(preferencesServiceProvider).getPreferredAudioLanguages();
    if (raw.isEmpty) return ['ja', 'jpn', 'jap'];
    return raw.split(',').map((e) => e.trim().toLowerCase()).toList();
  }
  void update(List<String> langs) {
    state = langs;
    ref.read(preferencesServiceProvider).setPreferredAudioLanguages(langs.join(','));
  }
}

final smartSubtitleAutoSelectProvider = NotifierProvider.autoDispose<SmartSubtitleAutoSelectNotifier, bool>(
  SmartSubtitleAutoSelectNotifier.new,
);
class SmartSubtitleAutoSelectNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool('smart_subtitle_auto_select', true);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool('smart_subtitle_auto_select', state);
  }
}

final preferredSubtitleLanguagesProvider = NotifierProvider.autoDispose<PreferredSubtitleLanguagesNotifier, List<String>>(
  PreferredSubtitleLanguagesNotifier.new,
);
class PreferredSubtitleLanguagesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final raw = ref.watch(preferencesServiceProvider).getSubtitleLanguages();
    if (raw.isEmpty) return ['en', 'eng'];
    return raw.split(',').map((e) => e.trim().toLowerCase()).toList();
  }
  void update(List<String> langs) {
    state = langs;
    ref.read(preferencesServiceProvider).setSubtitleLanguages(langs.join(','));
  }
}

final subtitleLanguagesProvider = NotifierProvider.autoDispose<SubtitleLanguagesNotifier, String>(
  SubtitleLanguagesNotifier.new,
);
class SubtitleLanguagesNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getSubtitleLanguages();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setSubtitleLanguages(v);
  }
}

final subtitleFontsDirectoryProvider = NotifierProvider.autoDispose<SubtitleFontsDirectoryNotifier, String>(
  SubtitleFontsDirectoryNotifier.new,
);
class SubtitleFontsDirectoryNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getSubtitleFontsDirectory();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setSubtitleFontsDirectory(v);
  }
}

final subtitleSaveLocationProvider = NotifierProvider.autoDispose<SubtitleSaveLocationNotifier, String>(
  SubtitleSaveLocationNotifier.new,
);
class SubtitleSaveLocationNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getSubtitleSaveLocation();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setSubtitleSaveLocation(v);
  }
}

final subtitleSourcesProvider = NotifierProvider.autoDispose<SubtitleSourcesNotifier, String>(
  SubtitleSourcesNotifier.new,
);
class SubtitleSourcesNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getSubtitleSources();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setSubtitleSources(v);
  }
}

final showFullFileNamesProvider = NotifierProvider.autoDispose<ShowFullFileNamesNotifier, bool>(ShowFullFileNamesNotifier.new);
class ShowFullFileNamesNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowFullFileNames();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowFullFileNames(state);
  }
}

final showNewLabelProvider = NotifierProvider.autoDispose<ShowNewLabelNotifier, bool>(ShowNewLabelNotifier.new);
class ShowNewLabelNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowNewLabel();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowNewLabel(state);
  }
}

final daysThresholdProvider = NotifierProvider.autoDispose<DaysThresholdNotifier, int>(DaysThresholdNotifier.new);
class DaysThresholdNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getDaysThreshold();
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setDaysThreshold(v);
  }
}

final autoScrollToLastPlayedProvider = NotifierProvider.autoDispose<AutoScrollToLastPlayedNotifier, bool>(AutoScrollToLastPlayedNotifier.new);
class AutoScrollToLastPlayedNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAutoScrollToLastPlayed();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAutoScrollToLastPlayed(state);
  }
}

final watchedThresholdProvider = NotifierProvider.autoDispose<WatchedThresholdNotifier, int>(WatchedThresholdNotifier.new);
class WatchedThresholdNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getWatchedThreshold();
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setWatchedThreshold(v);
  }
}

final tapThumbnailToSelectProvider = NotifierProvider.autoDispose<TapThumbnailToSelectNotifier, bool>(TapThumbnailToSelectNotifier.new);
class TapThumbnailToSelectNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getTapThumbnailToSelect();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setTapThumbnailToSelect(state);
  }
}

final showNetworkThumbnailsProvider = NotifierProvider.autoDispose<ShowNetworkThumbnailsNotifier, bool>(ShowNetworkThumbnailsNotifier.new);
class ShowNetworkThumbnailsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getShowNetworkThumbnails();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setShowNetworkThumbnails(state);
  }
}

final configStoragePathProvider = NotifierProvider.autoDispose<ConfigStoragePathNotifier, String>(ConfigStoragePathNotifier.new);
class ConfigStoragePathNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getConfigStoragePath();
  Future<void> update(String v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setConfigStoragePath(v);
  }
}

final luaScriptsProvider = NotifierProvider.autoDispose<LuaScriptsNotifier, bool>(LuaScriptsNotifier.new);
class LuaScriptsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getLuaScripts();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setLuaScripts(state);
  }
}

final recentlyPlayedProvider = NotifierProvider.autoDispose<RecentlyPlayedNotifier, bool>(RecentlyPlayedNotifier.new);
class RecentlyPlayedNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getRecentlyPlayed();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setRecentlyPlayed(state);
  }
}

final blacklistedFoldersProvider = NotifierProvider.autoDispose<BlacklistedFoldersNotifier, List<String>>(BlacklistedFoldersNotifier.new);
class BlacklistedFoldersNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.watch(preferencesServiceProvider).getBlacklistedFolders();
  Future<void> add(String path) async {
    if (state.contains(path)) return;
    state = [...state, path];
    await ref.read(preferencesServiceProvider).setBlacklistedFolders(state);
  }
  Future<void> remove(String path) async {
    state = state.where((p) => p != path).toList();
    await ref.read(preferencesServiceProvider).setBlacklistedFolders(state);
  }
}

final topLeftControlsProvider = NotifierProvider.autoDispose<TopLeftControlsNotifier, String>(TopLeftControlsNotifier.new);
class TopLeftControlsNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getTopLeftControls();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setTopLeftControls(v);
  }
}

final topRightControlsProvider = NotifierProvider.autoDispose<TopRightControlsNotifier, String>(TopRightControlsNotifier.new);
class TopRightControlsNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getTopRightControls();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setTopRightControls(v);
  }
}

final bottomCenterControlsProvider = NotifierProvider.autoDispose<BottomCenterControlsNotifier, String>(BottomCenterControlsNotifier.new);
class BottomCenterControlsNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getBottomCenterControls();
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setBottomCenterControls(v);
  }
}

final tapToToggleVisibilityProvider = NotifierProvider.autoDispose<TapToToggleVisibilityNotifier, bool>(TapToToggleVisibilityNotifier.new);
class TapToToggleVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getTapToToggleVisibility();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setTapToToggleVisibility(state);
  }
}

final displaySeekbarSecondsProvider = NotifierProvider.autoDispose<DisplaySeekbarSecondsNotifier, bool>(DisplaySeekbarSecondsNotifier.new);
class DisplaySeekbarSecondsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getDisplaySeekbarSeconds();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setDisplaySeekbarSeconds(state);
  }
}

final dimControlsSecondsProvider = NotifierProvider.autoDispose<DimControlsSecondsNotifier, int>(DimControlsSecondsNotifier.new);
class DimControlsSecondsNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getDimControlsSeconds();
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setDimControlsSeconds(v);
  }
}

final doubleTapAnimationProvider = NotifierProvider.autoDispose<DoubleTapAnimationNotifier, bool>(DoubleTapAnimationNotifier.new);
class DoubleTapAnimationNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getDoubleTapAnimation();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setDoubleTapAnimation(state);
  }
}

final disableControlsTouchInputProvider = NotifierProvider.autoDispose<DisableControlsTouchInputNotifier, bool>(DisableControlsTouchInputNotifier.new);
class DisableControlsTouchInputNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getDisableControlsTouchInput();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setDisableControlsTouchInput(state);
  }
}

final audioChannelsProvider = NotifierProvider.autoDispose<AudioChannelsNotifier, String>(
  AudioChannelsNotifier.new,
);
class AudioChannelsNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getAudioChannels();
  Future<void> update(String v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setAudioChannels(v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty(
        'audio-channels',
        state,
      );
    }
  }
}

final settingsProvider = Provider.autoDispose<PreferencesService>((ref) => ref.watch(preferencesServiceProvider));
