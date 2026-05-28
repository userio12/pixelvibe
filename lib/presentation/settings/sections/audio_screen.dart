import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../settings_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/custom_slider_tile.dart';
import '../widgets/language_picker.dart';

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

const _audioChannelOptions = ['Auto Safe', 'Stereo', 'Surround', '5.1', '7.1'];

class AudioScreen extends ConsumerWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchCorrection = ref.watch(audioPitchCorrectionProvider);
    final volumeNormalization = ref.watch(volumeNormalizationProvider);
    final backgroundPlayback = ref.watch(audioBackgroundProvider);
    final volumeBoostCap = ref.watch(_volumeBoostCapProvider);
    final audioChannels = ref.watch(audioChannelsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => context.pop(),
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
                _LanguageTile(
                  title: 'Preferred languages',
                  currentValue: ref.watch(preferencesServiceProvider).getPreferredAudioLanguages(),
                  onSave: (v) => ref.read(preferencesServiceProvider).setPreferredAudioLanguages(v),
                ),
                CustomSwitchTile(
                  title: 'Enable audio pitch correction',
                  subtitle: 'Prevents the audio from becoming high-pitched at faster speeds and low-pitched at slower speeds',
                  value: pitchCorrection,
                  onChanged: (_) => ref.read(audioPitchCorrectionProvider.notifier).toggle(),
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
                  subtitle: audioChannels,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1E2227),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Audio Channels',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFF2C3136)),
                            ..._audioChannelOptions.map((option) {
                              final selected = audioChannels == option;
                              return ListTile(
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    color: selected ? const Color(0xFF71C4D4) : Colors.white70,
                                  ),
                                ),
                                trailing: selected
                                    ? const Icon(Icons.check, color: Color(0xFF71C4D4))
                                    : null,
                                onTap: () {
                                  ref.read(audioChannelsProvider.notifier).update(option);
                                  Navigator.of(ctx).pop();
                                },
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    );
                  },
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

class _LanguageTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final void Function(String) onSave;

  const _LanguageTile({
    required this.title,
    required this.currentValue,
    required this.onSave,
  });

  String _displayValue() {
    if (currentValue.isEmpty) return 'Not set (will use video default)';
    final codes = currentValue.split(',');
    final names = codes.map((c) {
      final trimmed = c.trim().toLowerCase();
      final match = commonLanguages.firstWhere(
        (e) => e.$1 == trimmed,
        orElse: () => ('', trimmed),
      );
      return match.$1 == '' ? trimmed : match.$2;
    });
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return StandardActionTile(
      title: title,
      subtitle: _displayValue(),
      onTap: () => showLanguagePicker(context, currentValue, onSave),
    );
  }
}
