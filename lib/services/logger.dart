import 'package:flutter/foundation.dart';

class Logger {
  static void error(String message, [Object? error, StackTrace? stack]) {
    debugPrint('ERROR: $message${error != null ? ' — $error' : ''}');
    if (stack != null) {
      debugPrint('STACK: $stack');
    }
  }

  static void info(String message) {
    debugPrint('INFO: $message');
  }

  static void warning(String message, [Object? error]) {
    debugPrint('WARN: $message${error != null ? ' — $error' : ''}');
  }
}