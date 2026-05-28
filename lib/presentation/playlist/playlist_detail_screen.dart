import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/router/routes.dart';
import '../../data/database/app_database.dart';
import 'package:go_router/go_router.dart';

const _pageSize = 100;

final playlistDetailProvider = FutureProvider.autoDispose.family<PlaylistWithItems, int>((ref, id) async {
  final dao = ref.watch(playlistDaoProvider);
  final playlists = await dao.getAllPlaylists();
  final playlist = playlists.firstWhere((p) => p.id == id, orElse: () => throw Exception('Playlist not found: $id'));
  final items = await dao.getItems(id);
  return PlaylistWithItems(playlist: playlist, items: items);
});

class PlaylistWithItems {
  final Playlist playlist;
  final List<PlaylistItem> items;
  PlaylistWithItems({required this.playlist, required this.items});
}

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final int playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  final _scrollController = ScrollController();
  List<PlaylistItem> _loadedItems = [];
  bool _loadingMore = false;
  bool _allLoaded = false;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTotalCount();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTotalCount() async {
    final count = await ref.read(playlistDaoProvider).getItemCount(widget.playlistId);
    if (mounted) setState(() => _totalCount = count);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_loadingMore && !_allLoaded) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _allLoaded) return;
    setState(() => _loadingMore = true);
    final more = await ref.read(playlistDaoProvider).getItemsPaged(widget.playlistId, limit: _pageSize, offset: _loadedItems.length);
    if (mounted) {
      setState(() {
        _loadedItems.addAll(more);
        _loadingMore = false;
        if (more.length < _pageSize) _allLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(playlistDetailProvider(widget.playlistId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(data.asData?.value.playlist.name ?? 'Playlist')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) {
          if (_loadedItems.isEmpty && d.items.isNotEmpty) {
            _loadedItems = d.items.take(_pageSize).toList();
            _allLoaded = d.items.length <= _pageSize;
          }
          if (d.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.video_library_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No videos in this playlist', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }
          return PrimaryScrollController(
            controller: _scrollController,
            child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: _loadedItems.length + (_allLoaded ? 0 : 1),
            onReorder: (oldIndex, newIndex) async {
              final ids = _loadedItems.map((e) => e.id).toList();
              final moved = ids.removeAt(oldIndex);
              ids.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, moved);
              await ref.read(playlistDaoProvider).reorderItems(widget.playlistId, ids);
              ref.invalidate(playlistDetailProvider(widget.playlistId));
              setState(() => _loadedItems = []);
            },
            itemBuilder: (_, i) {
              if (i >= _loadedItems.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: _loadingMore
                        ? const CircularProgressIndicator()
                        : Text('$_totalCount items'),
                  ),
                );
              }
              final item = _loadedItems[i];
              return Card(
                key: ValueKey(item.id),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Semantics(
                  label: item.title ?? item.filePath.split('/').last,
                  child: ListTile(
                    leading: const Icon(Icons.movie_outlined),
                    title: Text(item.title ?? item.filePath.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      tooltip: 'Remove',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove video?'),
                            content: Text('Remove "${item.title ?? item.filePath.split('/').last}" from this playlist?'),
                            actions: [
                              Tooltip(
                                message: 'Cancel',
                                child: TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              ),
                              Tooltip(
                                message: 'Remove',
                                child: TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true || !context.mounted) return;
                        await ref.read(playlistDaoProvider).deleteItem(item.id);
                        if (!context.mounted) return;
                        ref.invalidate(playlistDetailProvider(widget.playlistId));
                        if (mounted) {
                          setState(() => _loadedItems.removeWhere((e) => e.id == item.id));
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removed from playlist')),
                        );
                      },
                    ),
                    onTap: () {
                      final encoded = Uri.encodeComponent(item.filePath);
                      context.push('${Routes.player}/$encoded');
                    },
                  ),
                ),
              );
            },
          ),
          );
        },
      ),
    );
  }
}
