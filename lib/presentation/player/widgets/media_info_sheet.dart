import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../../../utils/format_utils.dart';

class MediaInfoSheet extends StatelessWidget {
  final Player player;

  const MediaInfoSheet({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = player.state;
    final tracks = state.tracks;

    final infoItems = <MapEntry<String, String>>[
      MapEntry('Duration', formatDuration(state.duration.inMilliseconds)),
      MapEntry('Position', formatDuration(state.position.inMilliseconds)),
      MapEntry('Volume', '${(state.volume * 100).round()}%'),
      MapEntry('Speed', '${state.rate}x'),
      if (state.width != null && state.height != null)
        MapEntry('Resolution', '${state.width}x${state.height}'),
      MapEntry('Buffer', '${(state.bufferingPercentage * 100).round()}%'),
      MapEntry('Video Track', tracks.video.firstOrNull?.title ?? tracks.video.firstOrNull?.language ?? 'Unknown'),
      MapEntry('Audio Track', tracks.audio.firstOrNull?.title ?? tracks.audio.firstOrNull?.language ?? 'Unknown'),
      MapEntry('Subtitle Track', tracks.subtitle.firstOrNull?.title ?? tracks.subtitle.firstOrNull?.language ?? 'None'),
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
              children: infoItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.key, style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                    Text(item.value, style: theme.textTheme.bodyMedium),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
