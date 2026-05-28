import 'dart:developer' as dev;

class Logger {
  static void error(String message, [Object? error, StackTrace? stack]) {
    dev.log('ERROR: $message${error != null ? ' — $error' : ''}', stackTrace: stack);
  }

  static void info(String message) {
    dev.log('INFO: $message');
  }

  static void warning(String message, [Object? error]) {
    dev.log('WARN: $message${error != null ? ' — $error' : ''}');
  }
}