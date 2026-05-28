import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pip_service.dart';
import '../../services/background_service.dart';

final pipServiceProvider = Provider.autoDispose<PiPService>((ref) {
  final service = PiPService();
  ref.onDispose(() => service.dispose());
  return service;
});
final backgroundServiceProvider = Provider.autoDispose<BackgroundService>((ref) => BackgroundService());
