import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/media_file.dart';
import '../../utils/m3u_parser.dart';
import '../../services/logger.dart';
import '../../core/router/routes.dart';
import '../player/playlist_queue_provider.dart';
import 'home_provider.dart';
import 'enums/view_mode.dart';
import 'widgets/recently_played_section.dart';
import 'widgets/most_played_section.dart';
import 'widgets/url_input_dialog.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/video_grid_tile.dart';
import 'widgets/video_list_tile.dart';
import 'widgets/folder_list_tile.dart';
import 'widgets/empty_state.dart';
import 'widgets/file_context_menu.dart';
import 'widgets/display_options_sheet.dart';
import 'widgets/skeleton_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;
  static const _tabs = ['Files', 'Recently Played'];
  final _selectedFiles = <MediaFile>{};
  var _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSelection(MediaFile file) {
    setState(() {
      if (_selectedFiles.contains(file)) {
        _selectedFiles.remove(file);
        if (_selectedFiles.isEmpty) _selectionMode = false;
      } else {
        _selectedFiles.add(file);
        _selectionMode = true;
      }
    });
  }

  void _onFileLongPress(MediaFile file) {
    if (_selectionMode) {
      _toggleSelection(file);
    } else {
      FileContextMenu.show(context, ref, file);
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedFiles.clear();
      _selectionMode = false;
    });
  }

  Future<void> _bulkDelete() async {
    final files = List<MediaFile>.from(_selectedFiles);
    if (files.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete files'),
        content: Text('Delete ${files.length} file(s)? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    for (final f in files) {
      try {
        await File(f.path).delete();
      } catch (e) {
        Logger.error('Delete failed', e);
      }
    }
    _exitSelectionMode();
    ref.invalidate(homeProvider);
    messenger.showSnackBar(SnackBar(content: Text('Deleted ${files.length} file(s)')));
  }

  void _bulkAddToPlaylist() {
    final files = List<MediaFile>.from(_selectedFiles);
    if (files.isEmpty) return;
    final paths = files.map((f) => f.path).toList();
    final titles = files.map((f) => f.name).toList();
    ref.read(playlistQueueProvider.notifier).load(paths, titles: titles);
    _exitSelectionMode();
    if (context.mounted) {
      final encoded = Uri.encodeComponent(files.first.path);
      context.push('${Routes.player}/$encoded');
    }
  }

  void _retryScan(BuildContext context, WidgetRef ref) {
    ref.invalidate(homeProvider);
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(homeProvider);
    await ref.read(homeProvider.future);
  }

  void _showDisplayOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DisplayOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(viewModeProvider);
    final videosAsync = ref.watch(filteredVideosProvider);
    final currentDir = ref.watch(currentDirectoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedFiles.length} selected')
            : Text(currentDir != null ? currentDir.split('/').last : 'Browse'),
        leading: _selectionMode
            ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelectionMode)
            : (currentDir != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => ref.read(currentDirectoryProvider.notifier).leave(),
                  )
                : null),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.playlist_add),
              tooltip: 'Add to playlist',
              onPressed: _bulkAddToPlaylist,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete selected',
              onPressed: _bulkDelete,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.link),
              tooltip: 'Open URL',
              onPressed: () => showDialog(context: context, builder: (_) => const UrlInputDialog()),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Rescan device',
              onPressed: () => ref.invalidate(homeProvider),
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Display options',
              onPressed: _showDisplayOptionsSheet,
            ),
          ],
        ],
        bottom: currentDir == null
            ? TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              )
            : null,
      ),
      body: Column(
        children: [
          if (!_selectionMode)
            BrowserSearchBar(
              controller: _searchController,
              onChanged: (q) => ref.read(searchQueryProvider.notifier).update(q),
              onClear: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).update('');
              },
            ),
          Expanded(
            child: currentDir != null
                ? _buildFilesView(context, videosAsync, viewMode)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFilesTab(context, videosAsync, viewMode),
                      const _RecentAndMostPlayed(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesTab(BuildContext context, AsyncValue<List<MediaFile>> videosAsync, ViewMode viewMode) {
    return videosAsync.when(
      loading: () => _buildSkeleton(context),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load videos',
        subtitle: e.toString(),
        action: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          onPressed: () => _retryScan(context, ref),
        ),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                EmptyState(
                  icon: Icons.video_library_outlined,
                  title: 'No videos found',
                  subtitle: 'Tap the refresh button to scan.',
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: _buildView(context, videos, viewMode),
        );
      },
    );
  }

  Widget _buildFilesView(BuildContext context, AsyncValue<List<MediaFile>> videosAsync, ViewMode viewMode) {
    return videosAsync.when(
      loading: () => _buildSkeleton(context),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Error',
        subtitle: e.toString(),
        action: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          onPressed: () => _retryScan(context, ref),
        ),
      ),
      data: (videos) => RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildView(context, videos, viewMode),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final layout = ref.watch(layoutProvider);
    return layout == LayoutMode.grid
        ? GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 8,
            itemBuilder: (context, index) => const SkeletonTile(isGrid: true),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: 12,
            itemBuilder: (context, index) => const SkeletonTile(isGrid: false),
          );
  }

  Widget _buildView(BuildContext context, List<MediaFile> videos, ViewMode viewMode) {
    final layout = ref.watch(layoutProvider);
    switch (viewMode) {
      case ViewMode.folder:
        return layout == LayoutMode.grid
            ? GridView.builder(
                padding: const EdgeInsets.all(8),
                cacheExtent: 1000,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: videos.length,
                itemBuilder: (_, i) => VideoGridTile(
                  file: videos[i],
                  selected: _selectionMode && _selectedFiles.contains(videos[i]),
                  onTap: () => _onFileTap(context, videos[i]),
                  onLongPress: () => _onFileLongPress(videos[i]),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                cacheExtent: 1000,
                itemCount: videos.length,
                itemBuilder: (_, i) => VideoListTile(
                  file: videos[i],
                  selected: _selectionMode && _selectedFiles.contains(videos[i]),
                  onTap: () => _onFileTap(context, videos[i]),
                  onLongPress: () => _onFileLongPress(videos[i]),
                ),
              );
      case ViewMode.tree:
        return _buildFolderTree(context);
      case ViewMode.albums:
        return _buildAlbumsView(context);
    }
  }

  Widget _buildAlbumsView(BuildContext context) {
    final foldersAsync = ref.watch(folderListProvider);
    final videosAsync = ref.watch(homeProvider);
    return foldersAsync.when(
      loading: () => _buildSkeleton(context),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Error',
        subtitle: e.toString(),
        action: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          onPressed: () => _retryScan(context, ref),
        ),
      ),
      data: (folders) {
        if (folders.isEmpty) {
          return const EmptyState(icon: Icons.folder_open, title: 'No folders', subtitle: 'Scan your device first');
        }
        return videosAsync.when(
          loading: () => _buildSkeleton(context),
          error: (_, _) => const SizedBox.shrink(),
          data: (videos) {
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              cacheExtent: 1000,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: folders.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _AlbumCard(
                    name: 'All Videos',
                    count: videos.length,
                    thumbnailPath: videos.isNotEmpty ? videos.first.thumbnailPath : null,
                    onTap: () => ref.read(viewModeProvider.notifier).update(ViewMode.folder),
                  );
                }
                final dir = folders[i - 1];
                final count = videos.where((v) => v.directory == dir).length;
                final firstVideo = videos.firstWhere((v) => v.directory == dir, orElse: () => MediaFile(path: '', name: '', extension: '', sizeBytes: 0, durationMs: 0));
                return _AlbumCard(
                  name: dir.split('/').last,
                  subtitle: dir,
                  count: count,
                  thumbnailPath: firstVideo.thumbnailPath,
                  onTap: () {
                    ref.read(currentDirectoryProvider.notifier).enter(dir);
                    ref.read(viewModeProvider.notifier).update(ViewMode.folder);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFolderTree(BuildContext context) {
    final foldersAsync = ref.watch(folderListProvider);
    return foldersAsync.when(
      loading: () => _buildSkeleton(context),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Error',
        subtitle: e.toString(),
        action: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          onPressed: () => _retryScan(context, ref),
        ),
      ),
      data: (folders) {
        if (folders.isEmpty) {
          return const EmptyState(icon: Icons.folder_open, title: 'No folders', subtitle: 'Scan your device first');
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          cacheExtent: 1000,
          children: [
            FolderListTile(
              name: 'All Videos',
              itemCount: folders.length,
              onTap: () => ref.read(viewModeProvider.notifier).update(ViewMode.folder),
            ),
            ...folders.map((dir) => FolderListTile(
              name: dir.split('/').last,
              subtitle: dir,
              onTap: () => ref.read(currentDirectoryProvider.notifier).enter(dir),
            )),
          ],
        );
      },
    );
  }



  void _onFileTap(BuildContext context, MediaFile file) {
    if (_selectionMode) {
      _toggleSelection(file);
      return;
    }
    if (file.isPlaylist) {
      _openPlaylist(context, file);
      return;
    }
    final encoded = Uri.encodeComponent(file.path);
    context.push('/player/$encoded');
  }

  Future<void> _openPlaylist(BuildContext context, MediaFile file) async {
    try {
      final content = await File(file.path).readAsString();
      final playlist = M3uParser.parse(content);
      if (playlist.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empty playlist file')),
          );
        }
        return;
      }
      final paths = playlist.entries.map((e) => e.path).toList();
      final titles = playlist.entries.map((e) => e.title ?? e.path.split('/').last.split('.').first).toList();
      ref.read(playlistQueueProvider.notifier).load(paths, titles: titles);
      final firstPath = paths.first;
      final encoded = Uri.encodeComponent(firstPath);
      if (context.mounted) context.push('/player/$encoded');
    } catch (e) {
      Logger.error('Failed to parse M3U playlist', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load playlist: $e')),
        );
      }
    }
  }
}

class _AlbumCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final int count;
  final String? thumbnailPath;
  final VoidCallback onTap;

  const _AlbumCard({
    required this.name,
    this.subtitle,
    required this.count,
    this.thumbnailPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: thumbnailPath != null
                      ? Image.file(
                          File(thumbnailPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          Icons.photo_library_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(name, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text('$count videos', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentAndMostPlayed extends StatelessWidget {
  const _RecentAndMostPlayed();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 180, child: RecentlyPlayedSection()),
        SizedBox(height: 180, child: MostPlayedSection()),
      ],
    );
  }
}
