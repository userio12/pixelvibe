import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(preferencesServiceProvider).getThemeMode();
  void update(ThemeMode mode) {
    state = mode;
    ref.read(preferencesServiceProvider).setThemeMode(mode);
  }
}

final dynamicColorProvider = NotifierProvider<DynamicColorNotifier, bool>(DynamicColorNotifier.new);
class DynamicColorNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesServiceProvider).getDynamicColor();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setDynamicColor(state);
  }
}

final defaultSpeedProvider = NotifierProvider<DefaultSpeedNotifier, double>(DefaultSpeedNotifier.new);
class DefaultSpeedNotifier extends Notifier<double> {
  @override
  double build() => ref.read(preferencesServiceProvider).getDefaultSpeed();
  void update(double speed) {
    state = speed;
    ref.read(preferencesServiceProvider).setDefaultSpeed(speed);
  }
}

final resumePlaybackProvider = NotifierProvider<ResumePlaybackNotifier, bool>(ResumePlaybackNotifier.new);
class ResumePlaybackNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesServiceProvider).getResumePlayback();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setResumePlayback(state);
  }
}

final autoPipProvider = NotifierProvider<AutoPipNotifier, bool>(AutoPipNotifier.new);
class AutoPipNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesServiceProvider).getAutoPip();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAutoPip(state);
  }
}

final skipIntervalProvider = NotifierProvider<SkipIntervalNotifier, int>(SkipIntervalNotifier.new);
class SkipIntervalNotifier extends Notifier<int> {
  @override
  int build() => ref.read(preferencesServiceProvider).getSkipInterval();
  void update(int seconds) {
    state = seconds;
    ref.read(preferencesServiceProvider).setSkipInterval(seconds);
  }
}
