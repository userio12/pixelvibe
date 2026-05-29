import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences/base_preferences.dart';
import 'preferences/appearance_preferences.dart';
import 'preferences/player_preferences.dart';
import 'preferences/subtitle_preferences.dart';
import 'preferences/gesture_preferences.dart';
import 'preferences/browser_preferences.dart';
import 'preferences/decoder_preferences.dart';
import 'preferences/advanced_preferences.dart';

class PreferencesService 
    with 
        BasePreferences, 
        AppearancePreferences, 
        PlayerPreferences, 
        SubtitlePreferences, 
        GesturePreferences, 
        BrowserPreferences, 
        DecoderPreferences, 
        AdvancedPreferences {
  
  PreferencesService(this.prefs);

  @override
  final SharedPreferences prefs;

  String exportToJson() {
    final keys = prefs.getKeys();
    final map = <String, dynamic>{};
    for (final key in keys) {
      final v = prefs.get(key);
      if (v != null) map[key] = v;
    }
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<void> importFromJson(String json) async {
    final map = jsonDecode(json) as Map<String, dynamic>;
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is String) {
        await prefs.setString(entry.key, v);
      } else if (v is bool) {
        await prefs.setBool(entry.key, v);
      } else if (v is int) {
        await prefs.setInt(entry.key, v);
      } else if (v is double) {
        await prefs.setDouble(entry.key, v);
      }
    }
  }
}
