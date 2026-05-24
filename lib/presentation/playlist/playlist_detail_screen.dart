import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../data/database/app_database.dart';
import 'package:go_router/go_router.dart';

final playlistDetailProvider = FutureProvider.family<PlaylistWithItems, int>((ref, id) async {
  final dao = ref.watch(playlistDaoProvider);
  final playlists = await dao.getAllPlaylists();
  final playlist = playlists.firstWhere((p) => p.id == id);
  final items = await dao.getItems(id);
  return PlaylistWithItems(playlist: playlist, items: items);
});

class PlaylistWithItems {
  final Playlist playlist;
  final List<PlaylistItem> items;
  PlaylistWithItems({required this.playlist, required this.items});
}

class PlaylistDetailScreen extends ConsumerWidget {
  final int playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(playlistDetailProvider(playlistId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(data.asData?.value.playlist.name ?? 'Playlist')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) {
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
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: d.items.length,
            onReorder: (oldIndex, newIndex) async {
              final items = d.items;
              final ids = items.map((e) => e.id).toList();
              final moved = ids.removeAt(oldIndex);
              ids.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, moved);
              await ref.read(playlistDaoProvider).reorderItems(playlistId, ids);
              ref.invalidate(playlistDetailProvider(playlistId));
            },
            itemBuilder: (_, i) {
              final item = d.items[i];
              return Card(
                key: ValueKey(item.id),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.movie_outlined),
                  title: Text(item.title ?? item.filePath.split('/').last),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove video?'),
                          content: Text('Remove "${item.title ?? item.filePath.split('/').last}" from this playlist?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Remove', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true || !context.mounted) return;
                      await ref.read(playlistDaoProvider).deleteItem(item.id);
                      if (!context.mounted) return;
                      ref.invalidate(playlistDetailProvider(playlistId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Removed from playlist')),
                      );
                    },
                  ),
                  onTap: () {
                    final encoded = Uri.encodeComponent(item.filePath);
                    context.push('/player/$encoded');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
