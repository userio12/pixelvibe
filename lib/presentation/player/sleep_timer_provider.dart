import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player_provider.dart';

enum SleepTimerState { inactive, counting, endOfFile }

class SleepTimer {
  final SleepTimerState state;
  final int remainingSeconds;
  final int totalSeconds;

  const SleepTimer({
    this.state = SleepTimerState.inactive,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
  });

  String get formattedRemaining {
    if (state != SleepTimerState.counting) return '';
    final h = remainingSeconds ~/ 3600;
    final m = (remainingSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${remainingSeconds % 60}s';
  }

  double get progress => totalSeconds > 0 ? remainingSeconds / totalSeconds : 0;
}

final sleepTimerProvider = NotifierProvider<SleepTimerNotifier, SleepTimer>(
  SleepTimerNotifier.new,
);

class SleepTimerNotifier extends Notifier<SleepTimer> {
  Timer? _timer;

  @override
  SleepTimer build() {
    ref.onDispose(() => _timer?.cancel());
    return const SleepTimer();
  }

  void startCountdown(int seconds) {
    _timer?.cancel();
    state = SleepTimer(state: SleepTimerState.counting, remainingSeconds: seconds, totalSeconds: seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _fire();
        return;
      }
      state = SleepTimer(
        state: SleepTimerState.counting,
        remainingSeconds: state.remainingSeconds - 1,
        totalSeconds: state.totalSeconds,
      );
    });
  }

  void startEndOfFile() {
    _timer?.cancel();
    state = const SleepTimer(state: SleepTimerState.endOfFile);
  }

  void cancel() {
    _timer?.cancel();
    state = const SleepTimer();
  }

  void _fire() {
    _timer?.cancel();
    state = const SleepTimer();
    final player = ref.read(playerProvider);
    player.pause();
  }
}
