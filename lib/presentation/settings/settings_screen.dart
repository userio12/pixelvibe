import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import 'widgets/settings_card_group.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Preferences',
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
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF22272C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search settings...',
                    hintStyle: const TextStyle(color: Color(0xFF90959A)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF90959A)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF90959A)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_matches('UI & Appearance', 'Appearance', 'Dark mode, Material You', 'Player Layout', 'Customize player button layout'))
              SettingsCardGroup(
                sectionTitle: 'UI & Appearance',
                children: [
                  _SettingsMenuTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'Dark mode, Material You',
                    onTap: () => context.push(Routes.settingsAppearance),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.space_dashboard_outlined,
                    title: 'Player Layout',
                    subtitle: 'Customize player button layout',
                    onTap: () => context.push(Routes.settingsPlayerLayout),
                  ),
                ],
              ),
            if (_matches('Playback & Controls', 'Player', 'Orientation, gestures and controls', 'Gestures', 'Double tap, media controls'))
              SettingsCardGroup(
                sectionTitle: 'Playback & Controls',
                children: [
                  _SettingsMenuTile(
                    icon: Icons.play_circle_outline,
                    title: 'Player',
                    subtitle: 'Orientation, gestures and controls',
                    onTap: () => context.push(Routes.settingsPlayer),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.gesture,
                    title: 'Gestures',
                    subtitle: 'Double tap, media controls',
                    onTap: () => context.push(Routes.settingsGestures),
                  ),
                ],
              ),
            if (_matches('File Management', 'Folders', 'Manage folder blacklist'))
              SettingsCardGroup(
                sectionTitle: 'File Management',
                children: [
                  _SettingsMenuTile(
                    icon: Icons.folder_outlined,
                    title: 'Folders',
                    subtitle: 'Manage folder blacklist',
                    onTap: () => context.push(Routes.settingsFolders),
                  ),
                ],
              ),
            if (_matches('Media Settings', 'Decoder', 'Hardware decoding, pixel format, debanding', 'Subtitles', 'Preferred languages, fonts and search', 'Audio', 'Preferred languages, audio channels, pitch correction'))
              SettingsCardGroup(
                sectionTitle: 'Media Settings',
                children: [
                  _SettingsMenuTile(
                    icon: Icons.memory,
                    title: 'Decoder',
                    subtitle: 'Hardware decoding, pixel format, debanding',
                    onTap: () => context.push(Routes.settingsDecoder),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.subtitles_outlined,
                    title: 'Subtitles',
                    subtitle: 'Preferred languages, fonts and search',
                    onTap: () => context.push(Routes.settingsSubtitles),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.music_note_outlined,
                    title: 'Audio',
                    subtitle: 'Preferred languages, audio channels, pitch correction',
                    onTap: () => context.push(Routes.settingsAudio),
                  ),
                ],
              ),
            if (_matches('Advanced & About', 'Advanced', 'Configuration location, mpv.conf', 'About', 'Acknowledgments, licenses'))
              SettingsCardGroup(
                sectionTitle: 'Advanced & About',
                children: [
                  _SettingsMenuTile(
                    icon: Icons.code,
                    title: 'Advanced',
                    subtitle: 'Configuration location, mpv.conf',
                    onTap: () => context.push(Routes.settingsAdvanced),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Acknowledgments, licenses',
                    onTap: () => context.push(Routes.about),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _matches(String section, String t1, String s1, [String? t2, String? s2, String? t3, String? s3]) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    final terms = [
      section, 
      t1, 
      s1,
      if (t2 != null) t2,
      if (s2 != null) s2,
      if (t3 != null) t3,
      if (s3 != null) s3,
    ];
    return terms.any((t) => t.toLowerCase().contains(query));
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF71C4D4), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF90959A), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF90959A), size: 20),
          ],
        ),
      ),
    );
  }
}
