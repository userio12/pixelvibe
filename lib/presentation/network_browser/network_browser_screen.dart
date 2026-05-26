import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../data/database/app_database.dart';
import '../../services/network_service.dart';

final connectionListProvider = FutureProvider.autoDispose<List<NetworkConnection>>((ref) {
  return ref.watch(networkConnectionDaoProvider).getAll();
});

final networkServiceProvider = Provider.autoDispose<NetworkService>((ref) => NetworkService());

class NetworkBrowserScreen extends ConsumerStatefulWidget {
  const NetworkBrowserScreen({super.key});

  @override
  ConsumerState<NetworkBrowserScreen> createState() => _NetworkBrowserScreenState();
}

class _NetworkBrowserScreenState extends ConsumerState<NetworkBrowserScreen> {
  bool _autoConnected = false;

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(connectionListProvider);
    final theme = Theme.of(context);

    if (!_autoConnected) {
      _autoConnected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoConnect());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add connection',
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
            itemBuilder: (_, i) => _ConnectionTile(
              connection: list[i],
              onConnect: _connect,
            ),
          );
        },
      ),
    );
  }

  Future<void> _autoConnect() async {
    final dao = ref.read(networkConnectionDaoProvider);
    final connections = await dao.getAll();
    final auto = connections.where((c) => c.autoConnect).firstOrNull;
    if (auto == null || !mounted) return;
    _connect(auto);
  }

  Future<void> _connect(NetworkConnection conn) async {
    final service = ref.read(networkServiceProvider);
    final id = 'conn_${conn.id}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to ${conn.name}...'), duration: const Duration(seconds: 1)),
    );

    final ok = await service.connect(
      id: id,
      protocol: conn.protocol,
      host: conn.host,
      port: conn.port,
      username: conn.username,
      password: conn.password,
    );

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection failed')));
      return;
    }

    final files = await service.listFiles(id: id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connected — ${files.length} items'), duration: const Duration(seconds: 2)),
    );

    if (files.isEmpty) return;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('${conn.name} — /'),
        children: [
          ...files.take(20).map((f) => ListTile(
                dense: true,
                leading: Icon(f.isDirectory ? Icons.folder : Icons.movie_outlined),
                title: Text(f.name, overflow: TextOverflow.ellipsis),
                subtitle: Text(f.isDirectory ? 'Directory' : '${f.size}B'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Browsed: ${f.path}')));
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
}

class _ConnectionTile extends ConsumerWidget {
  final NetworkConnection connection;
  final void Function(NetworkConnection) onConnect;
  const _ConnectionTile({required this.connection, required this.onConnect});

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
      child: Semantics(
        label: connection.name,
        child: ListTile(
          leading: Icon(icon),
          title: Text(connection.name),
          subtitle: Text('${connection.protocol.toUpperCase()} · ${connection.host}:${connection.port}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onConnect(connection),
        ),
      ),
    );
  }
}
