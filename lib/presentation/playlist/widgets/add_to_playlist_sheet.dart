import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../data/database/app_database.dart';

final allPlaylistsProvider = FutureProvider<List<Playlist>>((ref) {
  return ref.watch(playlistDaoProvider).getAllPlaylists();
});

class AddToPlaylistSheet extends ConsumerWidget {
  final String filePath;
  final String? title;
  final int? durationMs;

  const AddToPlaylistSheet({
    super.key,
    required this.filePath,
    this.title,
    this.durationMs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(allPlaylistsProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Add to Playlist', style: theme.textTheme.titleLarge),
          ),
          const Divider(),
          Expanded(
            child: playlists.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text('No playlists yet. Create one first.', style: theme.textTheme.bodyMedium),
                  );
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final pl = list[i];
                    return ListTile(
                      leading: const Icon(Icons.playlist_add),
                      title: Text(pl.name),
                      onTap: () async {
                        await ref.read(playlistDaoProvider).addItem(
                          pl.id,
                          filePath,
                          title,
                          durationMs,
                        );
                        if (context.mounted) Navigator.of(context).pop();
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
