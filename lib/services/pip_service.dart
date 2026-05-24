import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PiPService {
  static const _channel = MethodChannel('com.pixelvibe/pip');

  final _toggleController = StreamController<void>.broadcast();
  Stream<void> get onTogglePlayback => _toggleController.stream;
  bool _handlerSet = false;

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
      if (call.method == 'onPictureInPictureModeChanged') {
        final args = call.arguments as Map<dynamic, dynamic>;
        callback(args['isInPip'] as bool);
      } else if (call.method == 'togglePlayback') {
        _toggleController.add(null);
      }
    });
  }

  void dispose() {
    _toggleController.close();
  }
}
