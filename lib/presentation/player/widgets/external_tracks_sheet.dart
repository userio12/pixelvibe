import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../player_provider.dart';

class ExternalTracksSheet extends ConsumerWidget {
  const ExternalTracksSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('External Tracks', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: [
                ListTile(
                  leading: const Icon(Icons.subtitles_outlined),
                  title: const Text('Load External Subtitle'),
                  subtitle: const Text('SRT, ASS, VTT, etc.'),
                  onTap: () => _pickSubtitle(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.audiotrack_outlined),
                  title: const Text('Load External Audio'),
                  subtitle: const Text('MP3, M4A, OPUS, etc.'),
                  onTap: () => _pickAudio(context, ref),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Note: External tracks might not sync perfectly if the source has a different frame rate or delay.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSubtitle(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'ssa', 'vtt', 'sub', 'webvtt'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    
    final player = ref.read(playerProvider);
    await player.setSubtitleTrack(SubtitleTrack.uri(path));
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subtitle loaded: ${result.files.first.name}')),
      );
    }
  }

  Future<void> _pickAudio(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    
    final player = ref.read(playerProvider);
    await player.setAudioTrack(AudioTrack.uri(path));
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio track loaded: ${result.files.first.name}')),
      );
    }
  }
}
