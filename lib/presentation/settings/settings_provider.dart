import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../core/di/providers.dart';
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
