import 'package:flutter/services.dart';

enum PlayerOrientation {
  free,
  video,
  portrait,
  reversePortrait,
  sensorPortrait,
  landscape,
  reverseLandscape,
  sensorLandscape;

  void apply() {
    switch (this) {
      case PlayerOrientation.free:
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      case PlayerOrientation.video:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      case PlayerOrientation.portrait:
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      case PlayerOrientation.reversePortrait:
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown]);
      case PlayerOrientation.sensorPortrait:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      case PlayerOrientation.landscape:
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
      case PlayerOrientation.reverseLandscape:
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
      case PlayerOrientation.sensorLandscape:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
    }
  }

  static void reset() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}
