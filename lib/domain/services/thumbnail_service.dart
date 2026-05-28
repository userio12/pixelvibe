import 'package:flutter/services.dart';
import '../../services/logger.dart';

class ThumbnailService {
  static const _channel = MethodChannel('com.pixelvibe/thumbnails');

  Future<String?> getThumbnailPath(String videoPath, {int width = 320}) async {
    try {
      return await _channel.invokeMethod<String>('getThumbnail', {
        'path': videoPath,
        'width': width,
      });
    } catch (e) {
      Logger.error('ThumbnailService.getThumbnailPath failed', e);
      return null;
    }
  }
}
