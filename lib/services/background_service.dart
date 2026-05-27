import 'package:flutter/services.dart';
import 'logger.dart';

typedef BackgroundEventHandler = void Function(String method, dynamic arguments);

class BackgroundService {
  static const _channel = MethodChannel('com.pixelvibe/background');
  BackgroundEventHandler? onEvent;

  BackgroundService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    onEvent?.call(call.method, call.arguments);
  }

  Future<void> startService({String title = 'pixelvibe', String content = 'Playing'}) async {
    try {
      await _channel.invokeMethod('startService', {
        'title': title,
        'content': content,
      });
    } catch (e) {
      Logger.error('BackgroundService.startService failed', e);
    }
  }

  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
    } catch (e) {
      Logger.error('BackgroundService.stopService failed', e);
    }
  }

  Future<void> updateMetadata({required String title, required int durationMs, String? thumbnail}) async {
    try {
      await _channel.invokeMethod('updateMetadata', {
        'title': title,
        'duration': durationMs,
        'thumbnail': ?thumbnail,
      });
    } catch (e) {
      Logger.error('BackgroundService.updateMetadata failed', e);
    }
  }

  Future<void> updatePlaybackState({required bool playing, required int positionMs}) async {
    try {
      await _channel.invokeMethod('updatePlaybackState', {
        'playing': playing,
        'position': positionMs,
      });
    } catch (e) {
      Logger.error('BackgroundService.updatePlaybackState failed', e);
    }
  }
}
