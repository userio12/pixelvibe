import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../../../utils/format_utils.dart';

class Chapter {
  final String title;
  final Duration start;
  final Duration end;

  const Chapter({required this.title, required this.start, required this.end});
}

class ChapterSheet extends StatefulWidget {
  final Player player;
  final List<Chapter> chapters;

  const ChapterSheet({super.key, required this.player, required this.chapters});

  @override
  State<ChapterSheet> createState() => _ChapterSheetState();
}

class _ChapterSheetState extends State<ChapterSheet> {
  int? _currentChapterIndex;

  @override
  void initState() {
    super.initState();
    widget.player.stream.position.listen((pos) {
      if (!mounted) return;
      final idx = widget.chapters.lastIndexWhere((c) => pos >= c.start);
      if (idx != _currentChapterIndex) {
        setState(() => _currentChapterIndex = idx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.chapters.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text('No chapters found', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Chapters (${widget.chapters.length})', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: widget.chapters.length,
              itemBuilder: (_, i) {
                final ch = widget.chapters[i];
                final isCurrent = i == _currentChapterIndex;
                return ListTile(
                  selected: isCurrent,
                  selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('${i + 1}', style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      )),
                    ),
                  ),
                  title: Text(ch.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(formatDuration(ch.start.inMilliseconds)),
                  trailing: isCurrent ? Icon(Icons.play_arrow, color: theme.colorScheme.primary) : null,
                  onTap: () {
                    widget.player.seek(ch.start);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
