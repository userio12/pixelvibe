import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../services/logger.dart';
import 'player_button.dart';

final controlLayoutProvider =
    NotifierProvider<ControlLayoutNotifier, ControlLayoutState>(
  ControlLayoutNotifier.new,
);

class ControlLayoutState {
  final List<PlayerButton> topLeft;
  final List<PlayerButton> topRight;
  final List<PlayerButton> bottomCenter;

  const ControlLayoutState({
    required this.topLeft,
    required this.topRight,
    required this.bottomCenter,
  });
}

class ControlLayoutNotifier extends Notifier<ControlLayoutState> {
  @override
  ControlLayoutState build() {
    final prefs = ref.watch(preferencesServiceProvider);
    return ControlLayoutState(
      topLeft: _parseList(prefs.getTopLeftControls()),
      topRight: _parseList(prefs.getTopRightControls()),
      bottomCenter: _parseList(prefs.getBottomCenterControls()),
    );
  }

  List<PlayerButton> _parseList(String csv) {
    if (csv.isEmpty) return [];
    return csv.split(',').map((s) {
      try {
        return PlayerButton.values.firstWhere((b) => b.name == s.trim());
      } catch (e) {
        Logger.warning('Unknown player button: ${s.trim()}', e);
        return PlayerButton.backArrow;
      }
    }).toList();
  }

  String _toCsv(List<PlayerButton> buttons) =>
      buttons.map((b) => b.name).join(',');

  Future<void> setTopLeft(List<PlayerButton> buttons) async {
    final csv = _toCsv(buttons);
    await ref.read(preferencesServiceProvider).setTopLeftControls(csv);
    state = ControlLayoutState(
      topLeft: buttons,
      topRight: state.topRight,
      bottomCenter: state.bottomCenter,
    );
  }

  Future<void> setTopRight(List<PlayerButton> buttons) async {
    final csv = _toCsv(buttons);
    await ref.read(preferencesServiceProvider).setTopRightControls(csv);
    state = ControlLayoutState(
      topLeft: state.topLeft,
      topRight: buttons,
      bottomCenter: state.bottomCenter,
    );
  }

  Future<void> setBottomCenter(List<PlayerButton> buttons) async {
    final csv = _toCsv(buttons);
    await ref.read(preferencesServiceProvider).setBottomCenterControls(csv);
    state = ControlLayoutState(
      topLeft: state.topLeft,
      topRight: state.topRight,
      bottomCenter: buttons,
    );
  }
}
