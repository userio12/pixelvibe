import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ThumbnailService {
  static const _channel = MethodChannel('com.pixelvibe/thumbnails');

  Future<String?> getThumbnailPath(String videoPath, {int width = 320}) async {
    try {
      return await _channel.invokeMethod<String>('getThumbnail', {
        'path': videoPath,
        'width': width,
      });
    } catch (e) {
      debugPrint('ThumbnailService.getThumbnailPath error: $e');
      return null;
    }
  }
}
