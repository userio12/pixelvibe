import 'dart:async';
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
      final List<Map<String, dynamic>> allVideos = [];
      const int limit = 500;
      int offset = 0;
      
      while (true) {
        final result = await _channel
            .invokeMethod<List<dynamic>>('scanVideos', {'offset': offset, 'limit': limit})
            .timeout(const Duration(seconds: 30));
        
        if (result == null || result.isEmpty) break;
        
        allVideos.addAll(result.map((e) => Map<String, dynamic>.from(e as Map)));
        
        if (result.length < limit) break;
        offset += limit;
      }
      
      return allVideos;
    } on TimeoutException {
      Logger.error('ScanService.scanVideos timed out after 30s');
      return [];
    } catch (e) {
      Logger.error('ScanService.scanVideos failed', e);
      return [];
    }
  }
}
