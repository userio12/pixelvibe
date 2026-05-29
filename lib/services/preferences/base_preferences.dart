import 'package:shared_preferences/shared_preferences.dart';

mixin BasePreferences {
  SharedPreferences get prefs;

  String getString(String key, [String defaultValue = '']) => prefs.getString(key) ?? defaultValue;
  Future<void> setString(String key, String v) => prefs.setString(key, v);
  
  double getDouble(String key, [double defaultValue = 0.0]) => prefs.getDouble(key) ?? defaultValue;
  Future<void> setDouble(String key, double v) => prefs.setDouble(key, v);
  
  int getInt(String key, [int defaultValue = 0]) => prefs.getInt(key) ?? defaultValue;
  Future<void> setInt(String key, int v) => prefs.setInt(key, v);
  
  bool getBool(String key, [bool defaultValue = false]) => prefs.getBool(key) ?? defaultValue;
  Future<void> setBool(String key, bool v) => prefs.setBool(key, v);
}
