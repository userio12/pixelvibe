import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

enum LogLevel { debug, info, warn, error }

class Logger {
  static File? _logFile;
  static bool _initialized = false;
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationSupportDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _logFile = File('${logDir.path}/current_log.txt');
      
      // Basic rotation: if current log is > 2MB, move it to old_log.txt
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > 2 * 1024 * 1024) {
          final oldLog = File('${logDir.path}/old_log.txt');
          if (await oldLog.exists()) await oldLog.delete();
          await _logFile!.rename(oldLog.path);
          _logFile = File('${logDir.path}/current_log.txt');
        }
      }

      _initialized = true;
      info('Logger initialized. Log file: ${_logFile!.path}');
    } catch (e) {
      dev.log('Failed to initialize file logger: $e');
    }
  }

  static void setLogLevel(LogLevel level) {
    _minLevel = level;
  }

  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  static void info(String message) {
    _log(LogLevel.info, message);
  }

  static void warning(String message, [Object? error]) {
    _log(LogLevel.warn, '$message${error != null ? ' — $error' : ''}');
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    _log(LogLevel.error, '$message${error != null ? ' — $error' : ''}', stack);
  }

  static void _log(LogLevel level, String message, [StackTrace? stack]) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final tag = level.name.toUpperCase().padRight(5);
    final logLine = '[$timestamp] $tag: $message';

    // Log to console
    dev.log(logLine, stackTrace: stack);

    // Log to file
    if (_initialized && _logFile != null) {
      _logFile!.writeAsStringSync('$logLine\n${stack != null ? "$stack\n" : ""}', mode: FileMode.append, flush: true);
    }
  }

  static Future<String?> getLogFilePath() async {
    if (_logFile != null && await _logFile!.exists()) {
      return _logFile!.path;
    }
    return null;
  }

  static Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('', mode: FileMode.write, flush: true);
    }
  }
}
