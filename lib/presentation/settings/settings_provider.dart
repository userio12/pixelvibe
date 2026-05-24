import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;
  void update(ThemeMode mode) => state = mode;
}

final dynamicColorProvider = NotifierProvider<DynamicColorNotifier, bool>(DynamicColorNotifier.new);
class DynamicColorNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final defaultSpeedProvider = NotifierProvider<DefaultSpeedNotifier, double>(DefaultSpeedNotifier.new);
class DefaultSpeedNotifier extends Notifier<double> {
  @override
  double build() => 1.0;
  void update(double speed) => state = speed;
}

final resumePlaybackProvider = NotifierProvider<ResumePlaybackNotifier, bool>(ResumePlaybackNotifier.new);
class ResumePlaybackNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final autoPipProvider = NotifierProvider<AutoPipNotifier, bool>(AutoPipNotifier.new);
class AutoPipNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final skipIntervalProvider = NotifierProvider<SkipIntervalNotifier, int>(SkipIntervalNotifier.new);
class SkipIntervalNotifier extends Notifier<int> {
  @override
  int build() => 10;
  void update(int seconds) => state = seconds;
}

final subtitleFontSizeProvider = NotifierProvider<SubtitleFontSizeNotifier, double>(SubtitleFontSizeNotifier.new);
class SubtitleFontSizeNotifier extends Notifier<double> {
  @override
  double build() => 16.0;
  void update(double size) => state = size;
}

final hwdecProvider = NotifierProvider<HwdecNotifier, String>(HwdecNotifier.new);
class HwdecNotifier extends Notifier<String> {
  @override
  String build() => 'auto';
  void update(String mode) => state = mode;
}

final gpuApiProvider = NotifierProvider<GpuApiNotifier, String>(GpuApiNotifier.new);
class GpuApiNotifier extends Notifier<String> {
  @override
  String build() => 'auto';
  void update(String api) => state = api;
}
