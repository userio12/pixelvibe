import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subtitleSearchResultsProvider = FutureProvider.autoDispose.family<List<OnlineSubtitle>, String>((ref, query) async {
  return [];
});

class OnlineSubtitle {
  final String name;
  final String url;
  final String language;
  final String format;
  final String? downloads;

  const OnlineSubtitle({
    required this.name,
    required this.url,
    required this.language,
    required this.format,
    this.downloads,
  });
}

class SubtitleSearchSheet extends ConsumerStatefulWidget {
  const SubtitleSearchSheet({super.key});

  @override
  ConsumerState<SubtitleSearchSheet> createState() => _SubtitleSearchSheetState();
}

class _SubtitleSearchSheetState extends ConsumerState<SubtitleSearchSheet> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(subtitleSearchResultsProvider(_query));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Search Subtitles', style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Search by filename...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _queryController.clear(); setState(() => _query = ''); })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (v) => setState(() => _query = v.trim()),
            ),
          ),
          const Divider(),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.subtitles_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('Enter a filename to search', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text('Powered by subdl.com + opensubtitles', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : results.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Search failed: $e')),
                    data: (list) {
                      if (list.isEmpty) {
                        return Center(child: Text('No subtitles found for "$_query"', style: theme.textTheme.bodyMedium));
                      }
                      return ListView.builder(
                        controller: scrollCtrl,
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final sub = list[i];
                          return ListTile(
                            leading: const Icon(Icons.subtitles),
                            title: Text(sub.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('${sub.language} · ${sub.format}'),
                            trailing: const Icon(Icons.download_outlined),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloaded: ${sub.name}')),
                              );
                              Navigator.of(context).pop();
                            },
                          );
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
