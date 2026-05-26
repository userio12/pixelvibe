import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

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
