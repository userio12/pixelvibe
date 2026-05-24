import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../data/database/app_database.dart';
import '../../services/network_service.dart';
import 'package:go_router/go_router.dart';

final connectionListProvider = FutureProvider<List<NetworkConnection>>((ref) {
  return ref.watch(networkConnectionDaoProvider).getAll();
});

final networkServiceProvider = Provider<NetworkService>((ref) => NetworkService());

class NetworkBrowserScreen extends ConsumerWidget {
  const NetworkBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(connectionListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/network-connection-form'),
          ),
        ],
      ),
      body: connections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_outlined, size: 72, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No network connections', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Add an SMB, FTP, or WebDAV connection', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: list.length,
            itemBuilder: (_, i) => _ConnectionTile(connection: list[i]),
          );
        },
      ),
    );
  }
}

class _ConnectionTile extends ConsumerWidget {
  final NetworkConnection connection;
  const _ConnectionTile({required this.connection});

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final service = ref.read(networkServiceProvider);
    final id = 'conn_${connection.id}';

    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(content: Text('Connecting to ${connection.name}...'), duration: const Duration(seconds: 1)),
    );

    final ok = await service.connect(
      id: id,
      protocol: connection.protocol,
      host: connection.host,
      port: connection.port,
      username: connection.username,
      password: connection.password,
    );

    if (!ok) {
      scaffold.showSnackBar(const SnackBar(content: Text('Connection failed')));
      return;
    }

    final files = await service.listFiles(id: id);

    if (!context.mounted) return;

    scaffold.showSnackBar(
      SnackBar(content: Text('Connected — ${files.length} items'), duration: const Duration(seconds: 2)),
    );

    if (files.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('${connection.name} — /'),
        children: [
          ...files.take(20).map((f) => ListTile(
                dense: true,
                leading: Icon(f.isDirectory ? Icons.folder : Icons.movie_outlined),
                title: Text(f.name, overflow: TextOverflow.ellipsis),
                subtitle: Text(f.isDirectory ? 'Directory' : '${f.size}B'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  scaffold.showSnackBar(SnackBar(content: Text('Browsed: ${f.path}')));
                },
              )),
          if (files.length > 20)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('+ ${files.length - 20} more items'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = switch (connection.protocol) {
      'smb' => Icons.computer,
      'ftp' => Icons.cloud,
      'webdav' => Icons.web,
      _ => Icons.link,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(connection.name),
        subtitle: Text('${connection.protocol.toUpperCase()} · ${connection.host}:${connection.port}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _connect(context, ref),
      ),
    );
  }
}
