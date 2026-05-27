import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/router/routes.dart';
import '../../data/database/app_database.dart';

import '../../utils/format_utils.dart';
import 'widgets/playlist_form_dialog.dart';
import 'package:go_router/go_router.dart';

final playlistListProvider = FutureProvider.autoDispose<List<Playlist>>((ref) {
  return ref.watch(playlistDaoProvider).getAllPlaylists();
});

final playlistStatsProvider = FutureProvider.autoDispose
    .family<({int count, int totalDuration}), int>((ref, id) {
  return ref.watch(playlistDaoProvider).getPlaylistStats(id);
});

class PlaylistListScreen extends ConsumerStatefulWidget {
  const PlaylistListScreen({super.key});

  @override
  ConsumerState<PlaylistListScreen> createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends ConsumerState<PlaylistListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF16191D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16191D),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Playlists',
          style: const TextStyle(
            color: Color(0xFF4FA9C9),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.search_off : Icons.search,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white70),
            onPressed: () => _createPlaylist(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search playlists...',
                  hintStyle: const TextStyle(color: Color(0xFFA0A5AA)),
                  filled: true,
                  fillColor: const Color(0xFF22262B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          Expanded(
            child: playlists.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.white70)),
              ),
              data: (list) {
                final filtered = _searchController.text.isNotEmpty
                    ? list.where((p) => p.name
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                        .toList()
                    : list;

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.queue_music,
                          size: 72,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Playlists Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first playlist to organize your videos',
                          style: TextStyle(color: Color(0xFFA0A5AA), fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _PlaylistTile(
                    playlist: filtered[i],
                    onRenamed: () => ref.invalidate(playlistListProvider),
                    onDeleted: () => ref.invalidate(playlistListProvider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createPlaylist() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const PlaylistFormDialog(),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(playlistDaoProvider).createPlaylist(name);
      ref.invalidate(playlistListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playlist "$name" created')),
      );
    }
  }
}

class _PlaylistTile extends ConsumerWidget {
  final Playlist playlist;
  final VoidCallback onRenamed;
  final VoidCallback onDeleted;

  const _PlaylistTile({
    required this.playlist,
    required this.onRenamed,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(playlistStatsProvider(playlist.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('${Routes.playlistDetail}/${playlist.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF22262B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3136),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.playlist_play,
                  color: Color(0xFF4FA9C9),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    statsAsync.when(
                      loading: () => const SizedBox(
                        width: 80,
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0xFF2C3136),
                        ),
                      ),
                      error: (_, _) => const Text(
                        '0 videos',
                        style: TextStyle(color: Color(0xFFA0A5AA), fontSize: 13),
                      ),
                      data: (stats) => Text(
                        '${stats.count} ${stats.count == 1 ? 'video' : 'videos'} \u2022 ${formatDuration(stats.totalDuration)}',
                        style: const TextStyle(
                          color: Color(0xFFA0A5AA),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF), size: 20),
                color: const Color(0xFF2C3136),
                elevation: 4,
                onSelected: (value) async {
                  if (value == 'rename') {
                    final name = await showDialog<String>(
                      context: context,
                      builder: (_) => PlaylistFormDialog(initialName: playlist.name),
                    );
                    if (name != null &&
                        name.isNotEmpty &&
                        name != playlist.name) {
                      await ref.read(playlistDaoProvider).renamePlaylist(playlist.id, name);
                      onRenamed();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Renamed to "$name"')),
                      );
                    }
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF22262B),
                        title: const Text(
                          'Delete Playlist',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Delete "${playlist.name}" and all its items?',
                          style: const TextStyle(color: Color(0xFFA0A5AA)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Color(0xFFEF5350)),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(playlistDaoProvider).deletePlaylist(playlist.id);
                      onDeleted();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('"${playlist.name}" deleted')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text('Rename', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Color(0xFFEF5350), size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Color(0xFFEF5350))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
