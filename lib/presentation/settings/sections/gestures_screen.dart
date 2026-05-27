import 'package:flutter/material.dart';
import '../widgets/settings_card_group.dart';
import '../widgets/standard_action_tile.dart';
import '../widgets/custom_switch_tile.dart';
import '../widgets/info_block.dart';

class GesturesScreen extends StatelessWidget {
  const GesturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Gestures',
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
              sectionTitle: 'Double tap',
              skipDividerAfter: {5},
              children: [
                const StandardActionTile(
                  title: 'Double tap seek duration',
                  subtitle: '10s',
                ),
                const StandardActionTile(
                  title: 'Double Tap Seek Area Width',
                  subtitle: 'Current: 35%',
                ),
                const StandardActionTile(
                  title: 'Double tap (left)',
                  subtitle: 'Seek',
                ),
                const StandardActionTile(
                  title: 'Double tap (center)',
                  subtitle: 'Play/Pause',
                ),
                const StandardActionTile(
                  title: 'Double tap (right)',
                  subtitle: 'Seek',
                ),
                const CustomSwitchTile(
                  title: 'Use single tap for center gesture',
                  subtitle: 'Use a single tap in the center for gestures (like play/pause) instead of a double tap.',
                  value: false,
                ),
                const InfoBlock(
                  text:
                      'You can bind custom actions to these gestures in input.conf using the following key codes:\n\n'
                      'Left: MBTN_LEFT_DBL\n'
                      'Center: MBTN_MID_DBL\n'
                      'Right: MBTN_RIGHT_DBL',
                ),
              ],
            ),
            SettingsCardGroup(
              sectionTitle: 'Media controls',
              skipDividerAfter: {2},
              children: [
                const StandardActionTile(
                  title: 'Previous',
                  subtitle: 'Seek',
                ),
                const StandardActionTile(
                  title: 'Play/Pause',
                  subtitle: 'Play/Pause',
                ),
                const StandardActionTile(
                  title: 'Next',
                  subtitle: 'Seek',
                ),
                const InfoBlock(
                  text:
                      'You can bind custom actions to media controls in input.conf using the following key codes:\n\n'
                      'Previous: PREV\n'
                      'Play/Pause: PLAYPAUSE\n'
                      'Next: NEXT',
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
