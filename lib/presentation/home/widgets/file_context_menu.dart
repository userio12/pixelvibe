import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/media_file.dart';
import '../../../services/logger.dart';
import '../../playlist/widgets/add_to_playlist_sheet.dart';
import '../home_provider.dart';

class FileContextMenu {
  static void show(BuildContext context, WidgetRef ref, MediaFile file) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FileContextSheet(ref: ref, file: file),
    );
  }
}

class _FileContextSheet extends StatelessWidget {
  final WidgetRef ref;
  final MediaFile file;

  const _FileContextSheet({required this.ref, required this.file});

  void _rename(BuildContext context) {
    final ctl = TextEditingController(text: file.name);
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()), child: const Text('Rename')),
        ],
      ),
    ).then((newName) async {
      if (newName == null || newName.isEmpty || newName == file.name) return;
      try {
        final newPath = '${file.directory}/$newName';
        await File(file.path).rename(newPath);
        ref.invalidate(homeProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Renamed to "$newName"')),
          );
        }
      } catch (e) {
        Logger.error('Rename failed', e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rename failed: $e')),
          );
        }
      }
    });
  }

  Future<void> _copyTo(BuildContext context) async {
    final dest = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Copy "${file.name}" to...',
    );
    if (dest == null) return;
    try {
      await File(file.path).copy('$dest/${file.name}');
      ref.invalidate(homeProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied to $dest')),
        );
      }
    } catch (e) {
      Logger.error('Copy failed', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copy failed: $e')),
        );
      }
    }
  }

  Future<void> _moveTo(BuildContext context) async {
    final dest = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Move "${file.name}" to...',
    );
    if (dest == null) return;
    try {
      await File(file.path).rename('$dest/${file.name}');
      ref.invalidate(homeProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved to $dest')),
        );
      }
    } catch (e) {
      Logger.error('Move failed', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Move failed: $e')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete file'),
        content: Text('Delete "${file.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await File(file.path).delete();
      ref.invalidate(homeProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${file.name}"')),
        );
      }
    } catch (e) {
      Logger.error('Delete failed', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _addToPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddToPlaylistSheet(
        filePath: file.path,
        title: file.name,
        durationMs: file.durationMs > 0 ? file.durationMs : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(file.name, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Rename'),
          onTap: () { Navigator.of(context).pop(); _rename(context); },
        ),
        ListTile(
          leading: const Icon(Icons.copy),
          title: const Text('Copy to...'),
          onTap: () { Navigator.of(context).pop(); _copyTo(context); },
        ),
        ListTile(
          leading: const Icon(Icons.drive_file_move),
          title: const Text('Move to...'),
          onTap: () { Navigator.of(context).pop(); _moveTo(context); },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Add to playlist'),
          onTap: () { Navigator.of(context).pop(); _addToPlaylist(context); },
        ),
        ListTile(
          leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          title: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
          onTap: () { Navigator.of(context).pop(); _delete(context); },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
