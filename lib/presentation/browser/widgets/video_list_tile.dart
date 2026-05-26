import 'package:flutter/material.dart';
import '../../../domain/models/media_file.dart';
import '../../../utils/format_utils.dart';

class VideoListTile extends StatelessWidget {
  final MediaFile file;
  final VoidCallback onTap;

  const VideoListTile({super.key, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: file.name,
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.movie_outlined),
        ),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Text(formatDuration(file.durationMs)),
            if (file.width != null && file.height != null) ...[
              const Text(' · '),
              Text('${file.width}x${file.height}'),
            ],
          ],
        ),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: onTap,
      ),
    );
  }
}
