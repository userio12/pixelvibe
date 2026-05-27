import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../settings_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/custom_slider_tile.dart';

final _pitchCorrectionProvider = NotifierProvider.autoDispose<_PitchNotifier, bool>(_PitchNotifier.new);
class _PitchNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesServiceProvider).getAudioPitchCorrection();
  void toggle() {
    state = !state;
    ref.read(preferencesServiceProvider).setAudioPitchCorrection(state);
  }
}

final _volumeBoostCapProvider = NotifierProvider.autoDispose<_VolumeBoostNotifier, double>(
  _VolumeBoostNotifier.new,
);
class _VolumeBoostNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesServiceProvider).getVolumeBoostCap();
  void update(double v) {
    state = v;
    ref.read(preferencesServiceProvider).setVolumeBoostCap(v);
  }
}

class AudioScreen extends ConsumerWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchCorrection = ref.watch(_pitchCorrectionProvider);
    final volumeNormalization = ref.watch(volumeNormalizationProvider);
    final backgroundPlayback = ref.watch(audioBackgroundProvider);
    final volumeBoostCap = ref.watch(_volumeBoostCapProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Audio',
          style: TextStyle(
            color: Color(0xFF71C4D4),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SettingsCardGroup(
              sectionTitle: 'Audio',
              children: [
                StandardActionTile(
                  title: 'Preferred languages',
                  subtitle: 'Not set (will use video default)',
                ),
                CustomSwitchTile(
                  title: 'Enable audio pitch correction',
                  subtitle: 'Prevents the audio from becoming high-pitched at faster speeds and low-pitched at slower speeds',
                  value: pitchCorrection,
                  onChanged: (_) => ref.read(_pitchCorrectionProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Volume normalization',
                  subtitle: 'Automatically adjust audio volume to maintain consistent loudness levels',
                  value: volumeNormalization,
                  onChanged: (_) => ref.read(volumeNormalizationProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Background playback',
                  subtitle: null,
                  value: backgroundPlayback,
                  onChanged: (_) => ref.read(audioBackgroundProvider.notifier).toggle(),
                ),
                StandardActionTile(
                  title: 'Audio channels',
                  subtitle: 'Auto Safe',
                ),
                CustomSliderTile(
                  title: 'Volume boost cap',
                  subtitle: '${(volumeBoostCap * 100).round()}',
                  value: volumeBoostCap,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: (v) => ref.read(_volumeBoostCapProvider.notifier).update(v),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
