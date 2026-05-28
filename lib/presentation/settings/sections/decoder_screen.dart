import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../player/video_quality_provider.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/pref_notifiers.dart';

final _gpuNextProvider = boolPref('gpu_next', false);
final _yuv420pProvider = boolPref('yuv420p', false);
final _anime4kProvider = boolPref('anime4k', false);

class DecoderScreen extends ConsumerWidget {
  const DecoderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hwdec = ref.watch(hwdecProvider);
    final hwdecEnabled = hwdec != 'no';
    final gpuNext = ref.watch(_gpuNextProvider);
    final gpuApi = ref.watch(gpuApiProvider);
    final debanding = ref.watch(preferencesServiceProvider).getDebanding();
    final yuv420p = ref.watch(_yuv420pProvider);
    final anime4k = ref.watch(_anime4kProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Decoder',
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
              sectionTitle: 'Decoder',
              children: [
                StandardActionTile(
                  title: 'MPV Profile',
                  subtitle: ref.watch(preferencesServiceProvider).getMpvActiveProfile(),
                ),
                CustomSwitchTile(
                  title: 'Try hardware decoding',
                  value: hwdecEnabled,
                  onChanged: (_) => ref.read(hwdecProvider.notifier).update(
                    hwdecEnabled ? 'no' : 'auto',
                  ),
                ),
                CustomSwitchTile(
                  title: 'Use gpu-next',
                  subtitle: 'A new rendering backend',
                  value: gpuNext,
                  onChanged: (v) {
                    ref.read(_gpuNextProvider.notifier).toggle();
                    ref.read(gpuApiProvider.notifier).update(v ? 'gpu-next' : 'auto');
                  },
                ),
                CustomSwitchTile(
                  title: 'Use Vulkan (Experimental)',
                  subtitle: 'Not supported (requires Android 13+ with Vulkan 1.3)',
                  value: gpuApi == 'vulkan',
                  isDisabled: true,
                  isSubtitleError: true,
                ),
                StandardActionTile(
                  title: 'Debanding',
                  subtitle: _debandingLabel(debanding),
                  onTap: () => _showDebandingPicker(context, ref),
                ),
                CustomSwitchTile(
                  title: 'Use YUV420P pixel format',
                  subtitle: 'May fix black screens on some video codecs, can also improve performance at the cost of quality',
                  value: yuv420p,
                  onChanged: (_) => ref.read(_yuv420pProvider.notifier).toggle(),
                ),
                CustomSwitchTile(
                  title: 'Anime4K upscaling (Experimental)',
                  value: anime4k,
                  onChanged: (_) => ref.read(_anime4kProvider.notifier).toggle(),
                  customSubtitle: const _Anime4KSubtitle(),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _debandingLabel(String v) {
    switch (v) {
      case 'weak': return 'Weak';
      case 'strong': return 'Strong';
      default: return 'None';
    }
  }

  void _showDebandingPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1E23),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Debanding', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            _debandingOption(ctx, ref, 'None', 'none'),
            _debandingOption(ctx, ref, 'Weak', 'weak'),
            _debandingOption(ctx, ref, 'Strong', 'strong'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _debandingOption(BuildContext ctx, WidgetRef ref, String label, String value) {
    final current = ref.watch(preferencesServiceProvider).getDebanding();
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: current == value
          ? const Icon(Icons.check, color: Color(0xFF71C4D4))
          : null,
      onTap: () {
        ref.read(preferencesServiceProvider).setDebanding(value);
        ref.invalidate(preferencesServiceProvider);
        Navigator.of(ctx).pop();
      },
    );
  }
}

class _Anime4KSubtitle extends StatelessWidget {
  const _Anime4KSubtitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enable Anime4K upscaling filter',
          style: TextStyle(color: Color(0xFF90959A), fontSize: 13),
        ),
        SizedBox(height: 2),
        Text(
          'github.com/bloc97/Anime4K',
          style: TextStyle(
            color: Color(0xFF71C4D4),
            fontSize: 13,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
