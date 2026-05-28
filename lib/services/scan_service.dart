import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'logger.dart';

class ScanService {
  static const _channel = MethodChannel('com.pixelvibe/scan');
  static void Function()? _onContentChanged;

  static void setOnContentChanged(void Function() callback) {
    _onContentChanged = callback;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'contentChanged') {
        _onContentChanged?.call();
      }
    });
  }

  Future<List<Map<String, dynamic>>> scanVideos() async {
    try {
      final result = await _channel
          .invokeMethod<String>('scanVideos')
          .timeout(const Duration(seconds: 30));
      if (result == null) return [];
      return (json.decode(result) as List).cast<Map<String, dynamic>>();
    } on TimeoutException {
      Logger.error('ScanService.scanVideos timed out after 30s');
      return [];
    } catch (e) {
      Logger.error('ScanService.scanVideos failed', e);
      return [];
    }
  }
}
