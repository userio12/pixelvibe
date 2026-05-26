import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../data/database/app_database.dart';
import 'widgets/playlist_form_dialog.dart';
import 'package:go_router/go_router.dart';

final playlistListProvider = FutureProvider.autoDispose<List<Playlist>>((ref) {
  return ref.watch(playlistDaoProvider).getAllPlaylists();
});

class PlaylistListScreen extends ConsumerWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create playlist',
            onPressed: () => _createPlaylist(context, ref),
          ),
        ],
      ),
      body: playlists.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.playlist_play, size: 72, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No playlists yet', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Create one to organize your videos', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: list.length,
            itemBuilder: (_, i) => _PlaylistTile(playlist: list[i]),
          );
        },
      ),
    );
  }

  void _createPlaylist(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const PlaylistFormDialog(),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(playlistDaoProvider).createPlaylist(name);
      ref.invalidate(playlistListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playlist "$name" created')),
        );
      }
    }
  }
}

class _PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: playlist.name,
        child: ListTile(
          leading: const Icon(Icons.playlist_play),
          title: Text(playlist.name),
          subtitle: Text('Created ${DateTime.fromMillisecondsSinceEpoch(playlist.createdAt).toLocal().toString().split(' ')[0]}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/playlist-detail/${playlist.id}'),
        ),
      ),
    );
  }
}
