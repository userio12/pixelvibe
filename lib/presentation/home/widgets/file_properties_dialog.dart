import 'package:flutter/material.dart';
import '../../../domain/models/media_file.dart';
import '../../../utils/format_utils.dart';

class FilePropertiesDialog extends StatelessWidget {
  final MediaFile file;
  const FilePropertiesDialog({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(file.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Path', file.path, theme),
          _row('Size', file.sizeFormatted, theme),
          _row('Duration', formatDuration(file.durationMs), theme),
          if (file.width != null && file.height != null)
            _row('Resolution', '${file.width}x$file.height', theme),
          _row('Type', '${file.extension.toUpperCase()} ${file.resolutionLabel.isNotEmpty ? "· ${file.resolutionLabel}" : ""}', theme),
          if (file.lastModified != null)
            _row('Modified', file.lastModified.toString().split('.')[0], theme),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  Widget _row(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
