import 'base_preferences.dart';

mixin AdvancedPreferences on BasePreferences {
  static const _configStoragePath = 'config_storage_path';
  static const _autoUpdateCheck = 'auto_update_check';
  static const _mpvActiveProfile = 'mpv_active_profile';
  static const _mpvProfiles = 'mpv_profiles';
  static const _luaScripts = 'lua_scripts';
  static const _recentlyPlayed = 'recently_played';

  String getConfigStoragePath() => getString(_configStoragePath, '');
  Future<void> setConfigStoragePath(String v) => setString(_configStoragePath, v);

  bool getAutoUpdateCheck() => getBool(_autoUpdateCheck, true);
  Future<void> setAutoUpdateCheck(bool v) => setBool(_autoUpdateCheck, v);

  String getMpvActiveProfile() => getString(_mpvActiveProfile, 'Default');
  Future<void> setMpvActiveProfile(String v) => setString(_mpvActiveProfile, v);

  String getMpvProfiles() => getString(_mpvProfiles, '[]');
  Future<void> setMpvProfiles(String v) => setString(_mpvProfiles, v);

  bool getLuaScripts() => getBool(_luaScripts, false);
  Future<void> setLuaScripts(bool v) => setBool(_luaScripts, v);

  bool getRecentlyPlayed() => getBool(_recentlyPlayed, true);
  Future<void> setRecentlyPlayed(bool v) => setBool(_recentlyPlayed, v);
}
