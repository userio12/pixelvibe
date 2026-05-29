import 'base_preferences.dart';

mixin DecoderPreferences on BasePreferences {
  static const _hwdec = 'hwdec';
  static const _gpuApi = 'gpu_api';
  static const _filterPreset = 'filter_preset';
  static const _shaderPreset = 'shader_preset';
  static const _gpuNext = 'gpu_next';
  static const _yuv420p = 'yuv420p';
  static const _debanding = 'debanding';
  static const _anime4k = 'anime4k';

  String getHwdec() => getString(_hwdec, 'auto');
  Future<void> setHwdec(String v) => setString(_hwdec, v);

  String getGpuApi() => getString(_gpuApi, 'auto');
  Future<void> setGpuApi(String v) => setString(_gpuApi, v);

  String getFilterPreset() => getString(_filterPreset, 'none');
  Future<void> setFilterPreset(String v) => setString(_filterPreset, v);

  String getShaderPreset() => getString(_shaderPreset, 'none');
  Future<void> setShaderPreset(String v) => setString(_shaderPreset, v);

  bool getGpuNext() => getBool(_gpuNext, false);
  Future<void> setGpuNext(bool v) => setBool(_gpuNext, v);

  bool getYuv420p() => getBool(_yuv420p, false);
  Future<void> setYuv420p(bool v) => setBool(_yuv420p, v);

  String getDebanding() => getString(_debanding, 'none');
  Future<void> setDebanding(String v) => setString(_debanding, v);

  bool getAnime4k() => getBool(_anime4k, false);
  Future<void> setAnime4k(bool v) => setBool(_anime4k, v);
}
