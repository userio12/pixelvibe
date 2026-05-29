import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerScreenState {
  final bool controlsVisible;
  final bool seekBarVisible;
  final bool locked;
  final String? errorMessage;

  PlayerScreenState({
    this.controlsVisible = true,
    this.seekBarVisible = true,
    this.locked = false,
    this.errorMessage,
  });

  PlayerScreenState copyWith({
    bool? controlsVisible,
    bool? seekBarVisible,
    bool? locked,
    String? errorMessage,
  }) {
    return PlayerScreenState(
      controlsVisible: controlsVisible ?? this.controlsVisible,
      seekBarVisible: seekBarVisible ?? this.seekBarVisible,
      locked: locked ?? this.locked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PlayerScreenNotifier extends Notifier<PlayerScreenState> {
  Timer? _hideTimer;

  @override
  PlayerScreenState build() {
    ref.onDispose(() => _hideTimer?.cancel());
    return PlayerScreenState();
  }

  void toggleControls() {
    if (state.locked) return;
    final visible = !state.controlsVisible;
    state = state.copyWith(
      controlsVisible: visible,
      seekBarVisible: visible,
    );
    if (visible) startHideTimer();
  }

  void toggleLock() {
    final locked = !state.locked;
    if (locked) {
      state = state.copyWith(locked: true, controlsVisible: false, seekBarVisible: false);
    } else {
      state = state.copyWith(locked: false, controlsVisible: true, seekBarVisible: true);
      startHideTimer();
    }
  }

  void startHideTimer({bool isFullToggle = true}) {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (isFullToggle) {
        state = state.copyWith(controlsVisible: false, seekBarVisible: false);
      } else {
        state = state.copyWith(seekBarVisible: false);
      }
    });
  }

  void setErrorMessage(String? message) {
    state = state.copyWith(errorMessage: message);
  }
  
  void showSeekBarTemporarily() {
    state = state.copyWith(seekBarVisible: true);
    startHideTimer(isFullToggle: false);
  }
}

final playerScreenProvider = NotifierProvider.autoDispose<PlayerScreenNotifier, PlayerScreenState>(PlayerScreenNotifier.new);
