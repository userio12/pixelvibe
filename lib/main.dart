import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'bootstrap.dart';
import 'services/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  FlutterError.onError = (details) {
    Logger.error(details.exceptionAsString(), details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    Logger.error('Platform error', error, stack);
    return true;
  };
  try {
    await bootstrap();
  } catch (e, s) {
    Logger.error('Bootstrap failed', e, s);
  }
  runApp(const ProviderScope(child: PixelvibeApp()));
}
