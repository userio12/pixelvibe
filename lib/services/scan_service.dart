import 'dart:convert';
import 'package:flutter/services.dart';
import 'logger.dart';

class ScanService {
  static const _channel = MethodChannel('com.pixelvibe/scan');

  Future<List<Map<String, dynamic>>> scanVideos() async {
    try {
      final result = await _channel.invokeMethod<String>('scanVideos');
      if (result == null) return [];
      return (json.decode(result) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      Logger.error('ScanService.scanVideos failed', e);
      return [];
    }
  }
}
