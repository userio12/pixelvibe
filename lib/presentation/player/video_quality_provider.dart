import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../core/di/providers.dart';
import 'player_provider.dart';

// ── Hwdec profile ──────────────────────────────────────────────────
final hwdecProvider = NotifierProvider.autoDispose<HwdecNotifier, String>(HwdecNotifier.new);
class HwdecNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getHwdec();
  Future<void> update(String v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setHwdec(v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('hwdec', state);
    }
  }
}

// ── GPU API (decoder backend) ──────────────────────────────────────
final gpuApiProvider = NotifierProvider.autoDispose<GpuApiNotifier, String>(GpuApiNotifier.new);
class GpuApiNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getGpuApi();
  Future<void> update(String v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setGpuApi(v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('gpu-api', state);
    }
  }
}

// ── Filter presets ─────────────────────────────────────────────────
const filterPresetMap = <String, String>{
  'none': '',
  'deband': 'deband',
  'sharpen': 'unsharp',
  'denoise': 'hqdn3d',
  'deband+sharpen': 'deband,unsharp',
  'deband+denoise': 'deband,hqdn3d',
};

final filterPresetProvider = NotifierProvider.autoDispose<FilterPresetNotifier, String>(FilterPresetNotifier.new);
class FilterPresetNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getFilterPreset();
  Future<void> update(String v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setFilterPreset(v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      final vf = filterPresetMap[state] ?? '';
      (player.platform as NativePlayer).setProperty('vf', vf);
    }
  }
}

// ── Mirror / Flip ──────────────────────────────────────────────────
final mirrorProvider = NotifierProvider.autoDispose<MirrorNotifier, bool>(MirrorNotifier.new);
class MirrorNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getMirror();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setMirror(state);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty(
        'video-rotate',
        state ? 'hflip' : '0',
      );
    }
  }
}

final flipProvider = NotifierProvider.autoDispose<FlipNotifier, bool>(FlipNotifier.new);
class FlipNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getFlip();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setFlip(state);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty(
        'video-rotate',
        state ? 'vflip' : '0',
      );
    }
  }
}

// ── Color controls ─────────────────────────────────────────────────
final videoBrightnessProvider = NotifierProvider.autoDispose<VideoBrightnessNotifier, int>(VideoBrightnessNotifier.new);
class VideoBrightnessNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('video_brightness');
  Future<void> update(int v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setInt('video_brightness', v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('brightness', state.toString());
    }
  }
}

final videoContrastProvider = NotifierProvider.autoDispose<VideoContrastNotifier, int>(VideoContrastNotifier.new);
class VideoContrastNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('video_contrast');
  Future<void> update(int v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setInt('video_contrast', v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('contrast', state.toString());
    }
  }
}

final videoSaturationProvider = NotifierProvider.autoDispose<VideoSaturationNotifier, int>(VideoSaturationNotifier.new);
class VideoSaturationNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('video_saturation');
  Future<void> update(int v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setInt('video_saturation', v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('saturation', state.toString());
    }
  }
}

final videoGammaProvider = NotifierProvider.autoDispose<VideoGammaNotifier, int>(VideoGammaNotifier.new);
class VideoGammaNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(preferencesServiceProvider).getInt('video_gamma');
  Future<void> update(int v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setInt('video_gamma', v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('gamma', state.toString());
    }
  }
}

// ── Shader presets (Anime4K etc) ───────────────────────────────────
final shaderPresetProvider = NotifierProvider.autoDispose<ShaderPresetNotifier, String>(ShaderPresetNotifier.new);
class ShaderPresetNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getShaderPreset();
  Future<void> update(String v) async {
    state = v;
    await ref.read(preferencesServiceProvider).setShaderPreset(v);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty('glsl-shaders', state);
    }
  }
}

// ── Screenshot with subtitles ──────────────────────────────────────
final screenshotSubsProvider = NotifierProvider.autoDispose<ScreenshotSubsNotifier, bool>(ScreenshotSubsNotifier.new);
class ScreenshotSubsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getScreenshotSubs();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setScreenshotSubs(state);
    _apply();
  }
  void _apply() {
    final player = ref.read(playerProvider);
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty(
        'subs-with-subs',
        state ? 'yes' : 'no',
      );
    }
  }
}

// ── Precise seeking (hr-seek) ──────────────────────────────────────
final hrSeekProvider = NotifierProvider.autoDispose<HrSeekNotifier, bool>(HrSeekNotifier.new);
class HrSeekNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getHrSeek();
  Future<void> toggle() async {
    state = !state;
    await ref.read(preferencesServiceProvider).setHrSeek(state);
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
