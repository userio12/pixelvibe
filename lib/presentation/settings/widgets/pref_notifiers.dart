// ignore_for_file: library_private_types_in_public_api

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';

NotifierProvider<_BoolNotifier, bool> boolPref(String key, bool defaultValue) {
  return NotifierProvider<_BoolNotifier, bool>(() => _BoolNotifier(key, defaultValue));
}

class _BoolNotifier extends Notifier<bool> {
  final String _key;
  final bool _defaultValue;
  _BoolNotifier(this._key, this._defaultValue);

  @override
  bool build() => ref.watch(preferencesServiceProvider).getBool(_key, _defaultValue);
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setBool(_key, state);
  }
}

NotifierProvider<_IntNotifier, int> intPref(String key, int defaultValue) {
  return NotifierProvider<_IntNotifier, int>(() => _IntNotifier(key, defaultValue));
}

class _IntNotifier extends Notifier<int> {
  final String _key;
  final int _defaultValue;
  _IntNotifier(this._key, this._defaultValue);

  @override
  int build() => ref.watch(preferencesServiceProvider).getInt(_key, _defaultValue);
  void update(int v) {
    state = v;
    ref.read(preferencesServiceProvider).setInt(_key, v);
  }
}

NotifierProvider<_DoubleNotifier, double> doublePref(String key, double defaultValue) {
  return NotifierProvider<_DoubleNotifier, double>(() => _DoubleNotifier(key, defaultValue));
}

class _DoubleNotifier extends Notifier<double> {
  final String _key;
  final double _defaultValue;
  _DoubleNotifier(this._key, this._defaultValue);

  @override
  double build() => ref.watch(preferencesServiceProvider).getDouble(_key, _defaultValue);
  void update(double v) {
    state = v;
    ref.read(preferencesServiceProvider).setDouble(_key, v);
  }
}

NotifierProvider<_StringNotifier, String> stringPref(String key, String defaultValue) {
  return NotifierProvider<_StringNotifier, String>(() => _StringNotifier(key, defaultValue));
}

class _StringNotifier extends Notifier<String> {
  final String _key;
  final String _defaultValue;
  _StringNotifier(this._key, this._defaultValue);

  @override
  String build() => ref.watch(preferencesServiceProvider).getString(_key, _defaultValue);
  void update(String v) {
    state = v;
    ref.read(preferencesServiceProvider).setString(_key, v);
  }
}
