import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/media_file.dart';
import 'browser_provider.dart';
import 'enums/view_mode.dart';
import 'widgets/recently_played_section.dart';
import 'widgets/view_mode_toggle.dart';
import 'widgets/search_bar.dart';
import 'widgets/video_grid_tile.dart';
import 'widgets/video_list_tile.dart';
import 'widgets/folder_list_tile.dart';
import 'widgets/empty_state.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(viewModeProvider);
    final videosAsync = ref.watch(browserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ViewModeToggle(
              current: viewMode,
              onChanged: (v) => ref.read(viewModeProvider.notifier).update(v),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          BrowserSearchBar(
            controller: _searchController,
            onChanged: (q) => ref.read(searchQueryProvider.notifier).update(q),
            onClear: () {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).update('');
            },
          ),
          Expanded(child: _buildContent(context, videosAsync, viewMode)),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncValue<List<MediaFile>> videosAsync,
    ViewMode viewMode,
  ) {
    return videosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load videos',
        subtitle: e.toString(),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return const EmptyState(
            icon: Icons.video_library_outlined,
            title: 'No videos found',
            subtitle: 'Tap the refresh button to scan your device',
          );
        }
        return Column(
          children: [
            const RecentlyPlayedSection(),
            Expanded(child: _buildView(context, videos, viewMode)),
          ],
        );
      },
    );
  }

  Widget _buildView(BuildContext context, List<MediaFile> videos, ViewMode viewMode) {
    switch (viewMode) {
      case ViewMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: videos.length,
          itemBuilder: (_, i) => VideoGridTile(
            file: videos[i],
            onTap: () => _openPlayer(context, videos[i]),
          ),
        );
      case ViewMode.list:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: videos.length,
          itemBuilder: (_, i) => VideoListTile(
            file: videos[i],
            onTap: () => _openPlayer(context, videos[i]),
          ),
        );
      case ViewMode.tree:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            FolderListTile(name: 'All Videos', itemCount: videos.length, onTap: () {}),
            FolderListTile(name: 'Recent', itemCount: 0, onTap: () {}),
          ],
        );
    }
  }

  void _openPlayer(BuildContext context, MediaFile file) {
    final encoded = Uri.encodeComponent(file.path);
    context.push('/player/$encoded');
  }
}
