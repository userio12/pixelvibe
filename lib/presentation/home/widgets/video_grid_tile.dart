import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/models/media_file.dart';
import '../../../utils/format_utils.dart';

class VideoGridTile extends StatelessWidget {
  final MediaFile file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  const VideoGridTile({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Hero(
                        tag: file.path,
                        child: file.thumbnailPath != null
                            ? Image.file(
                                File(file.thumbnailPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.movie_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                              )
                            : Icon(Icons.movie_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  if (file.resolutionLabel.isNotEmpty)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          file.resolutionLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        formatDuration(file.durationMs),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                file.sizeFormatted,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
