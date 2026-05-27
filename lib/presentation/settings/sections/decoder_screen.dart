import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';

class DecoderScreen extends ConsumerWidget {
  const DecoderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const StandardActionTile(
                  title: 'MPV Profile',
                  subtitle: 'Fast',
                ),
                const CustomSwitchTile(
                  title: 'Try hardware decoding',
                  value: true,
                ),
                const CustomSwitchTile(
                  title: 'Use gpu-next',
                  subtitle: 'A new rendering backend',
                  value: false,
                ),
                const CustomSwitchTile(
                  title: 'Use Vulkan (Experimental)',
                  subtitle: 'Not supported (requires Android 13+ with Vulkan 1.3)',
                  value: false,
                  isDisabled: true,
                  isSubtitleError: true,
                ),
                const StandardActionTile(
                  title: 'Debanding',
                  subtitle: 'None',
                ),
                const CustomSwitchTile(
                  title: 'Use YUV420P pixel format',
                  subtitle: 'May fix black screens on some video codecs, can also improve performance at the cost of quality',
                  value: false,
                ),
                const CustomSwitchTile(
                  title: 'Anime4K upscaling (Experimental)',
                  value: false,
                  customSubtitle: _Anime4KSubtitle(),
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
