import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PiPService {
  static const _channel = MethodChannel('com.pixelvibe/pip');

  final _toggleController = StreamController<void>.broadcast();
  Stream<void> get onTogglePlayback => _toggleController.stream;
  bool _handlerSet = false;
  bool _disposed = false;

  Future<bool> isPipSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isPipSupported');
      return result ?? false;
    } catch (e) {
      debugPrint('PiPService.isPipSupported error: $e');
      return false;
    }
  }

  Future<void> enterPip({int width = 16, int height = 9, bool playing = true}) async {
    try {
      await _channel.invokeMethod('enterPip', {
        'width': width,
        'height': height,
        'playing': playing,
      });
    } catch (e) {
      debugPrint('PiPService.enterPip error: $e');
    }
  }

  void onPipModeChanged(void Function(bool isInPip) callback) {
    if (_handlerSet) return;
    _handlerSet = true;
    _channel.setMethodCallHandler((call) async {
      if (_disposed) return null;
      if (call.method == 'onPictureInPictureModeChanged') {
        final args = call.arguments;
        if (args is Map<dynamic, dynamic>) {
          callback(args['isInPip'] as bool? ?? false);
        }
      } else if (call.method == 'togglePlayback') {
        _toggleController.add(null);
      }
      return null;
    });
  }

  void dispose() {
    _disposed = true;
    _channel.setMethodCallHandler(null);
    _toggleController.close();
  }
}
