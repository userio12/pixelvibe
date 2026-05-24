import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BackgroundService {
  static const _channel = MethodChannel('com.pixelvibe/background');

  Future<void> startService({String title = 'pixelvibe', String content = 'Playing'}) async {
    try {
      await _channel.invokeMethod('startService', {
        'title': title,
        'content': content,
      });
    } catch (e) {
      debugPrint('BackgroundService.startService error: $e');
    }
  }

  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
    } catch (e) {
      debugPrint('BackgroundService.stopService error: $e');
    }
  }

  Future<void> updateMetadata({required String title, required int durationMs}) async {
    try {
      await _channel.invokeMethod('updateMetadata', {
        'title': title,
        'duration': durationMs,
      });
    } catch (e) {
      debugPrint('BackgroundService.updateMetadata error: $e');
    }
  }

  Future<void> updatePlaybackState({required bool playing, required int positionMs}) async {
    try {
      await _channel.invokeMethod('updatePlaybackState', {
        'playing': playing,
        'position': positionMs,
      });
    } catch (e) {
      debugPrint('BackgroundService.updatePlaybackState error: $e');
    }
  }
}
