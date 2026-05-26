import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../utils/platform_helper.dart';
import '../player/playlist_queue_provider.dart';

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
