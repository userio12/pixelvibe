import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../player_provider.dart';

const _audioExtensions = {'aac', 'mka', 'mp3', 'flac', 'ogg', 'opus', 'wav', 'ac3', 'eac3', 'dts', 'm4a', 'wma'};

class AudioTrackSheet extends ConsumerStatefulWidget {
  final String filePath;
  const AudioTrackSheet({super.key, required this.filePath});

  @override
  ConsumerState<AudioTrackSheet> createState() => _AudioTrackSheetState();
}

class _AudioTrackSheetState extends ConsumerState<AudioTrackSheet> {
  List<FileSystemEntity> _externalFiles = [];
  bool _loadingExternal = true;

  @override
  void initState() {
    super.initState();
    _loadExternalFiles();
  }

  Future<void> _loadExternalFiles() async {
    try {
      final dir = File(widget.filePath).parent;
      if (!await dir.exists()) {
        setState(() => _loadingExternal = false);
        return;
      }
      final files = await dir.list().toList();
      setState(() {
        _externalFiles = files
            .where((f) => f is File && _audioExtensions.contains(f.path.split('.').last.toLowerCase()))
            .toList();
        _loadingExternal = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingExternal = false);
    }
  }

  void _selectTrack(AudioTrack track, String label) {
    final player = ref.read(playerProvider);
    player.setAudioTrack(track);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio: $label')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickExternal() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _audioExtensions.toList(),
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final path = result.files.first.path;
    if (path == null) return;
    final name = result.files.first.name;
    _selectTrack(AudioTrack.uri(path, title: name), name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = ref.read(playerProvider);
    final internalTracks = player.state.tracks.audio;
    final currentTrack = player.state.track.audio;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Audio Tracks', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: [
                if (internalTracks.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text('Internal Tracks', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                  ),
                  ...internalTracks.map((t) => ListTile(
                        leading: Icon(
                          Icons.audiotrack,
                          color: t.id == currentTrack.id ? theme.colorScheme.primary : null,
                        ),
                        title: Text(t.title ?? t.language ?? 'Track ${t.id}'),
                        subtitle: t.language != null ? Text(t.language!) : null,
                        trailing: t.id == currentTrack.id
                            ? Icon(Icons.check, color: theme.colorScheme.primary)
                            : null,
                        onTap: t.id == currentTrack.id
                            ? null
                            : () => _selectTrack(AudioTrack(t.id, t.title, t.language), t.title ?? t.language ?? 'Track ${t.id}'),
                      )),
                  const Divider(height: 24),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('External Files', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                ),
                if (_loadingExternal)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_externalFiles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No audio files found in the same directory', style: theme.textTheme.bodySmall),
                  )
                else
                  ..._externalFiles.map((f) {
                    final name = f.path.split('/').last.split('\\').last;
                    return ListTile(
                      leading: const Icon(Icons.audio_file),
                      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => _selectTrack(AudioTrack.uri(f.path, title: name), name),
                    );
                  }),
                const Divider(height: 16),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('Pick from device...'),
                  onTap: _pickExternal,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
