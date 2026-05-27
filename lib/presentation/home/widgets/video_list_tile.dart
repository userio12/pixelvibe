import 'package:flutter/material.dart';
import '../../../domain/models/media_file.dart';
import '../../../utils/format_utils.dart';

class VideoListTile extends StatelessWidget {
  final MediaFile file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  const VideoListTile({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: file.name,
      child: ListTile(
        selected: selected,
        selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        leading: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: file.isVideo
                    ? const Icon(Icons.movie_outlined)
                    : const Icon(Icons.playlist_play),
              ),
            ),
            if (file.durationMs > 0)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    formatDuration(file.durationMs),
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Text(file.sizeFormatted),
            if (file.width != null && file.height != null) ...[
              const Text(' · '),
              Text('${file.width}x${file.height}'),
            ],
          ],
        ),
        trailing: selected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Properties',
                onPressed: () => _showProperties(context, file),
              ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  void _showProperties(BuildContext context, MediaFile file) {
    showDialog(context: context, builder: (_) => _FilePropertiesDialog(file: file));
  }
}

class _FilePropertiesDialog extends StatelessWidget {
  final MediaFile file;
  const _FilePropertiesDialog({required this.file});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(file.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Path', file.path, context),
          _row('Size', file.sizeFormatted, context),
          _row('Duration', formatDuration(file.durationMs), context),
          if (file.width != null && file.height != null)
            _row('Resolution', '${file.width}x${file.height}', context),
          _row('Type', file.extension.toUpperCase(), context),
          if (file.lastModified != null)
            _row('Modified', file.lastModified.toString().split('.')[0], context),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  Widget _row(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
