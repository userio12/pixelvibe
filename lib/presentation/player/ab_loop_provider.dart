import 'package:flutter_riverpod/flutter_riverpod.dart';

final abLoopProvider = NotifierProvider<AbLoopNotifier, AbLoopState>(
  AbLoopNotifier.new,
);

class AbLoopState {
  final int? aPointMs;
  final int? bPointMs;

  const AbLoopState({this.aPointMs, this.bPointMs});

  bool get isActive => aPointMs != null && bPointMs != null;
}

class AbLoopNotifier extends Notifier<AbLoopState> {
  @override
  AbLoopState build() => const AbLoopState();

  void setA(int positionMs) {
    state = AbLoopState(
      aPointMs: positionMs,
      bPointMs: state.bPointMs,
    );
  }

  void setB(int positionMs) {
    final a = state.aPointMs ?? positionMs;
    final aFinal = a <= positionMs ? a : positionMs;
    final bFinal = a <= positionMs ? positionMs : a;
    state = AbLoopState(aPointMs: aFinal, bPointMs: bFinal);
  }

  void clear() {
    state = const AbLoopState();
  }

  void toggle() {
    if (state.isActive) {
      clear();
    }
  }
}
