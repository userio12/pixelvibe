import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

final playerProvider = Provider<Player>((ref) {
  final player = Player();
  ref.onDispose(() => player.dispose());
  return player;
});

final playerPositionProvider = StreamProvider.autoDispose<Duration>((ref) {
  return ref.watch(playerProvider).stream.position;
});

final playerDurationProvider = StreamProvider.autoDispose<Duration>((ref) {
  return ref.watch(playerProvider).stream.duration;
});

final playerVolumeProvider = StreamProvider.autoDispose<double>((ref) {
  return ref.watch(playerProvider).stream.volume;
});

final playerIsPlayingProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref.watch(playerProvider).stream.playing;
});

final playerBufferProvider = StreamProvider.autoDispose<Duration>((ref) {
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
