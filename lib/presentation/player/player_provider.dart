import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../settings/settings_provider.dart';

final playerProvider = Provider<Player>((ref) {
  final player = Player();
  ref.onDispose(() => player.dispose());
  return player;
});

final playerConfigWatcherProvider = Provider<void>((ref) {
  final player = ref.watch(playerProvider);

  ref.listen(defaultSpeedProvider, (_, speed) {
    if (speed != 1.0) player.setRate(speed);
  });
});

final playerPositionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(playerProvider).stream.position;
});

final playerDurationProvider = StreamProvider<Duration>((ref) {
  return ref.watch(playerProvider).stream.duration;
});

final playerVolumeProvider = StreamProvider<double>((ref) {
  return ref.watch(playerProvider).stream.volume;
});

final playerIsPlayingProvider = StreamProvider<bool>((ref) {
  return ref.watch(playerProvider).stream.playing;
});

final playerBufferProvider = StreamProvider<Duration>((ref) {
  return ref.watch(playerProvider).stream.buffer;
});

final frameStepProvider = Provider<FrameStepService>((ref) {
  final player = ref.watch(playerProvider);
  return FrameStepService(player);
});

class FrameStepService {
  final Player _player;

  FrameStepService(this._player);

  static const _stepMs = 40;

  Future<void> stepForward() async {
    await _player.pause();
    final current = _player.state.position;
    final dur = _player.state.duration;
    final next = (current.inMilliseconds + _stepMs).clamp(0, dur.inMilliseconds);
    await _player.seek(Duration(milliseconds: next));
  }

  Future<void> stepBackward() async {
    await _player.pause();
    final current = _player.state.position;
    final dur = _player.state.duration;
    final next = (current.inMilliseconds - _stepMs).clamp(0, dur.inMilliseconds);
    await _player.seek(Duration(milliseconds: next));
  }
}
