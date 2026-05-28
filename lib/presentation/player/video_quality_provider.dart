import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../core/di/providers.dart';
import '../../domain/models/mpv_profile.dart';
import '../../services/preferences_service.dart';
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

final vfPresetProvider = NotifierProvider.autoDispose<VfPresetNotifier, String>(VfPresetNotifier.new);
class VfPresetNotifier extends Notifier<String> {
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

// ── Built-in MPV profiles ───────────────────────────────────────────
const builtInProfiles = <MpvProfile>[
  MpvProfile(
    name: 'Default',
    isBuiltIn: true,
    properties: {
      'hwdec': 'auto',
      'gpu-api': 'auto',
      'vf': '',
      'glsl-shaders': '',
      'brightness': '0',
      'contrast': '0',
      'saturation': '0',
      'gamma': '0',
      'hr-seek': 'yes',
      'subs-with-subs': 'yes',
    },
  ),
  MpvProfile(
    name: 'High Performance',
    isBuiltIn: true,
    properties: {
      'hwdec': 'mediacodec',
      'gpu-api': 'opengl',
      'vf': '',
      'glsl-shaders': '',
      'brightness': '0',
      'contrast': '0',
      'saturation': '0',
      'gamma': '0',
      'hr-seek': 'no',
      'subs-with-subs': 'yes',
    },
  ),
  MpvProfile(
    name: 'High Quality',
    isBuiltIn: true,
    properties: {
      'hwdec': 'auto',
      'gpu-api': 'vulkan',
      'vf': 'deband',
      'glsl-shaders': 'Anime4K_Restore_CNN_L.glsl',
      'brightness': '0',
      'contrast': '0',
      'saturation': '0',
      'gamma': '0',
      'hr-seek': 'yes',
      'subs-with-subs': 'yes',
    },
  ),
  MpvProfile(
    name: 'Software (compat)',
    isBuiltIn: true,
    properties: {
      'hwdec': 'no',
      'gpu-api': 'auto',
      'vf': '',
      'glsl-shaders': '',
      'brightness': '0',
      'contrast': '0',
      'saturation': '0',
      'gamma': '0',
      'hr-seek': 'yes',
      'subs-with-subs': 'yes',
    },
  ),
];

// ── Helper: read all profiles (built-in + custom) ───────────────────
List<MpvProfile> _loadProfiles(PreferencesService prefs) {
  final customJson = prefs.getMpvProfiles();
  final custom = (jsonDecode(customJson) as List)
      .cast<Map<String, dynamic>>()
      .map(MpvProfile.fromJson)
      .toList();
  return [...builtInProfiles, ...custom];
}

Future<void> _saveProfiles(PreferencesService prefs, List<MpvProfile> customOnly) async {
  final json = jsonEncode(customOnly.map((p) => p.toJson()).toList());
  await prefs.setMpvProfiles(json);
}

// ── MPV profile selector ────────────────────────────────────────────
final mpvProfileProvider = NotifierProvider.autoDispose<MpvProfileNotifier, String>(MpvProfileNotifier.new);

class MpvProfileNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(preferencesServiceProvider).getMpvActiveProfile();

  List<MpvProfile> get allProfiles => _loadProfiles(ref.read(preferencesServiceProvider));

  Future<void> select(String name) async {
    final prefs = ref.read(preferencesServiceProvider);
    final profiles = _loadProfiles(prefs);
    final profile = profiles.firstWhere((p) => p.name == name);
    state = name;
    await prefs.setMpvActiveProfile(name);
    _apply(profile);
  }

  void _apply(MpvProfile profile) {
    final player = ref.read(playerProvider);
    if (player.platform is! NativePlayer) return;
    final native = player.platform as NativePlayer;
    for (final entry in profile.properties.entries) {
      native.setProperty(entry.key, entry.value);
    }
  }

  Future<void> saveCurrentAs(String name) async {
    final prefs = ref.read(preferencesServiceProvider);
    final properties = <String, String>{
      'hwdec': ref.read(hwdecProvider),
      'gpu-api': ref.read(gpuApiProvider),
      'vf': filterPresetMap[ref.read(vfPresetProvider)] ?? '',
      'glsl-shaders': ref.read(shaderPresetProvider),
      'brightness': ref.read(videoBrightnessProvider).toString(),
      'contrast': ref.read(videoContrastProvider).toString(),
      'saturation': ref.read(videoSaturationProvider).toString(),
      'gamma': ref.read(videoGammaProvider).toString(),
      'hr-seek': ref.read(hrSeekProvider) ? 'yes' : 'no',
      'subs-with-subs': ref.read(screenshotSubsProvider) ? 'yes' : 'no',
    };
    final custom = [..._loadProfiles(prefs).where((p) => !p.isBuiltIn), MpvProfile(name: name, properties: properties)];
    await _saveProfiles(prefs, custom.where((p) => !p.isBuiltIn).toList());
    state = name;
    await prefs.setMpvActiveProfile(name);
  }

  Future<void> deleteCustom(String name) async {
    final prefs = ref.read(preferencesServiceProvider);
    final custom = _loadProfiles(prefs).where((p) => !p.isBuiltIn && p.name != name).toList();
    await _saveProfiles(prefs, custom);
    if (state == name) {
      state = 'Default';
      await prefs.setMpvActiveProfile('Default');
    }
  }
}
