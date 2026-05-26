import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../../core/di/providers.dart';
import '../../../utils/format_utils.dart';

class MediaInfoSheet extends ConsumerStatefulWidget {
  final Player player;
  final String? filePath;

  const MediaInfoSheet({super.key, required this.player, this.filePath});

  @override
  ConsumerState<MediaInfoSheet> createState() => _MediaInfoSheetState();
}

class _MediaInfoSheetState extends ConsumerState<MediaInfoSheet> {
  StreamSubscription<Duration>? _posSub;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _posSub = widget.player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.player.state;
    final tracks = state.tracks;

    final infoItems = <MapEntry<String, String>>[
      MapEntry('Duration', formatDuration(state.duration.inMilliseconds)),
      MapEntry('Position', formatDuration(_position.inMilliseconds)),
      MapEntry('Volume', '${(state.volume * 100).round()}%'),
      MapEntry('Speed', '${state.rate}x'),
      if (state.width != null && state.height != null)
        MapEntry('Resolution', '${state.width}x${state.height}'),
      MapEntry('Buffer', '${(state.bufferingPercentage * 100).round()}%'),
      MapEntry('Video', tracks.video.firstOrNull?.title ?? tracks.video.firstOrNull?.language ?? 'Unknown'),
      MapEntry('Audio', tracks.audio.firstOrNull?.title ?? tracks.audio.firstOrNull?.language ?? 'Unknown'),
      MapEntry('Subtitles', tracks.subtitle.firstOrNull?.title ?? tracks.subtitle.firstOrNull?.language ?? 'None'),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Media Info', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...infoItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.key, style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                      Flexible(child: Text(item.value, style: theme.textTheme.bodyMedium, textAlign: TextAlign.end)),
                    ],
                  ),
                )),
                const Divider(),
                _DbInfoSection(filePath: widget.filePath),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DbInfoSection extends ConsumerWidget {
  final String? filePath;
  const _DbInfoSection({this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filePath == null || filePath!.isEmpty) return const SizedBox.shrink();
    final metaAsync = ref.watch(videoMetadataByPathProvider(filePath!));
    return metaAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (meta) {
        if (meta == null) return const SizedBox.shrink();
        final file = File(meta.filePath);
        final size = file.existsSync() ? file.statSync().size : 0;
        final dbItems = <MapEntry<String, String>>[];
        if (meta.codec != null) dbItems.add(MapEntry('Codec', meta.codec!));
        if (meta.bitrate != null) dbItems.add(MapEntry('Bitrate', meta.bitrate!));
        if (size > 0) dbItems.add(MapEntry('File size', _formatSize(size)));
        if (meta.playCount > 0) dbItems.add(MapEntry('Play count', '${meta.playCount}'));
        dbItems.add(MapEntry('Added', _formatDate(meta.addedAt)));

        return Column(
          children: dbItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.key, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
                Flexible(child: Text(item.value, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.end)),
              ],
            ),
          )).toList(),
        );
      },
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
