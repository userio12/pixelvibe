import 'package:flutter/services.dart';

class BackgroundService {
  static const _channel = MethodChannel('com.pixelvibe/background');

  Future<void> startService({String title = 'pixelvibe', String content = 'Playing'}) async {
    try {
      await _channel.invokeMethod('startService', {
        'title': title,
        'content': content,
      });
    } catch (_) {}
  }

  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
    } catch (_) {}
  }

  Future<void> updateMetadata({required String title, required int durationMs}) async {
    try {
      await _channel.invokeMethod('updateMetadata', {
        'title': title,
        'duration': durationMs,
      });
    } catch (_) {}
  }

  Future<void> updatePlaybackState({required bool playing, required int positionMs}) async {
    try {
      await _channel.invokeMethod('updatePlaybackState', {
        'playing': playing,
        'position': positionMs,
      });
    } catch (_) {}
  }
}
