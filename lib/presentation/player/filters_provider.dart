import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/filter_presets.dart';

final filterPresetProvider = NotifierProvider<FilterPresetNotifier, FilterPreset>(FilterPresetNotifier.new);
class FilterPresetNotifier extends Notifier<FilterPreset> {
  @override
  FilterPreset build() => FilterPreset.none;
  void update(FilterPreset v) => state = v;
}

final videoHueProvider = NotifierProvider<SimpleDoubleNotifier, double>(SimpleDoubleNotifier.new);
final videoSharpnessProvider = NotifierProvider<SimpleDoubleNotifier, double>(SimpleDoubleNotifier.new);

class SimpleDoubleNotifier extends Notifier<double> {
  @override
  double build() => 0.0;
  void update(double v) => state = v;
}
