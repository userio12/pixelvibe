import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../../core/di/providers.dart';
import '../../../services/logger.dart';
import '../../../services/subtitle_api_service.dart';
import '../player_provider.dart';

final subtitleSearchResultsProvider = FutureProvider.autoDispose.family<List<OnlineSubtitle>, String>((ref, query) async {
  final apiKey = ref.watch(preferencesServiceProvider).getString('opensubtitles_api_key', '');
  if (apiKey.isEmpty) return [];
  final service = SubtitleApiService(apiKey);
  return service.search(query);
});

class SubtitleSearchSheet extends ConsumerStatefulWidget {
  const SubtitleSearchSheet({super.key});

  @override
  ConsumerState<SubtitleSearchSheet> createState() => _SubtitleSearchSheetState();
}

class _SubtitleSearchSheetState extends ConsumerState<SubtitleSearchSheet> {
  final _queryController = TextEditingController();
  String _query = '';
  bool _isDownloading = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _downloadAndLoad(OnlineSubtitle sub) async {
    setState(() => _isDownloading = true);
    try {
      final apiKey = ref.read(preferencesServiceProvider).getString('opensubtitles_api_key', '');
      final service = SubtitleApiService(apiKey);
      final path = await service.download(sub.fileId);
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download subtitle')),
        );
        return;
      }
      if (!mounted) return;
      final player = ref.read(playerProvider);
      await player.setSubtitleTrack(SubtitleTrack.uri(path));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded: ${sub.fileName}')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      Logger.error('Subtitle download error', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading subtitle')),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
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
                        Text('Powered by OpenSubtitles', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : results.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Search failed: $e')),
                    data: (list) {
                      if (list.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('No subtitles found for "$_query"', style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Text('Try a shorter filename', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          ListView.builder(
                            controller: scrollCtrl,
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final sub = list[i];
                              return ListTile(
                                leading: const Icon(Icons.subtitles),
                                title: Text(sub.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${sub.language} · ${sub.format} · ${sub.downloads} downloads'),
                                trailing: _isDownloading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.download_outlined),
                                onTap: _isDownloading ? null : () => _downloadAndLoad(sub),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
