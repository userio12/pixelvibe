import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pip_service.dart';
import '../../services/background_service.dart';

final pipServiceProvider = Provider<PiPService>((ref) => PiPService());
final backgroundServiceProvider = Provider<BackgroundService>((ref) => BackgroundService());
