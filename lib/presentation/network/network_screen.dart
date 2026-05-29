import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../core/router/routes.dart';
import '../../data/database/app_database.dart';
import '../../services/network_service.dart';
import '../../services/network_discovery_service.dart';

final connectionListProvider = FutureProvider.autoDispose<List<NetworkConnection>>((ref) {
  return ref.watch(networkConnectionDaoProvider).getAll();
});

final networkServiceProvider = Provider.autoDispose<NetworkService>((ref) => NetworkService());

class NetworkScreen extends ConsumerStatefulWidget {
  const NetworkScreen({super.key});

  @override
  ConsumerState<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends ConsumerState<NetworkScreen> {
  final _urlController = TextEditingController();
  var _hasUrl = false;
  var _autoConnected = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(() {
      setState(() => _hasUrl = _urlController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(connectionListProvider);

    if (!_autoConnected) {
      _autoConnected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoConnect());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        title: const Text(
          'Network',
          style: TextStyle(
            color: Color(0xFF4DB6AC),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreamLinkSection(),
            const SizedBox(height: 24),
            _buildDiscoveredSection(),
            const SizedBox(height: 24),
            _buildLocalNetworkSection(connections),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF056580),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Connection'),
        onPressed: () => context.push(Routes.networkConnectionForm),
      ),
    );
  }

  Widget _buildStreamLinkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 12),
          child: Text(
            'Stream Link',
            style: TextStyle(
              color: Color(0xFF4DB6AC),
              fontSize: 18,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF22262B),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFA0A5AA)),
                  hintText: 'Video URL',
                  hintStyle: const TextStyle(color: Color(0xFFA0A5AA)),
                  filled: true,
                  fillColor: const Color(0xFF121518),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4A5158)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4A5158)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4DB6AC)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: Icons.paste,
                    label: 'Paste',
                    backgroundColor: const Color(0xFF354854),
                    foregroundColor: Colors.white,
                    onPressed: _pasteUrl,
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.play_arrow,
                    label: 'Play',
                    backgroundColor: _hasUrl ? const Color(0xFF056580) : const Color(0xFF2C3136),
                    foregroundColor: _hasUrl ? Colors.white : const Color(0xFF5A6066),
                    onPressed: _hasUrl ? _playStream : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveredSection() {
    final discovered = ref.watch(discoveredServicesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Discovered on Network',
            style: TextStyle(
              color: Color(0xFF4DB6AC),
              fontSize: 18,
            ),
          ),
        ),
        discovered.when(
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )),
          error: (e, _) => const SizedBox.shrink(),
          data: (services) {
            if (services.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF22262B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Searching for local servers...',
                  style: TextStyle(color: Color(0xFFA0A5AA), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF22262B),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: services.map((s) => _buildDiscoveredCard(s)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDiscoveredCard(DiscoveredService service) {
    final icon = switch (service.type) {
      NetworkServiceType.smb => Icons.computer,
      NetworkServiceType.ftp => Icons.cloud,
      NetworkServiceType.webdav => Icons.web,
      NetworkServiceType.sftp => Icons.security,
    };

    return Card(
      color: const Color(0xFF2C3136),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF71C4D4)),
        title: Text(service.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${service.type.name.toUpperCase()} \u00b7 ${service.host}:${service.port}',
          style: const TextStyle(color: Color(0xFFA0A5AA)),
        ),
        trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF4DB6AC)),
        onTap: () {
          context.push(Routes.networkConnectionForm, extra: {
            'protocol': service.type.name,
            'host': service.host,
            'port': service.port,
            'name': service.name,
          });
        },
      ),
    );
  }

  Widget _buildLocalNetworkSection(AsyncValue<List<NetworkConnection>> connections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Local Network',
            style: TextStyle(
              color: Color(0xFF4DB6AC),
              fontSize: 18,
            ),
          ),
        ),
        connections.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Color(0xFFA0A5AA)))),
          data: (list) {
            if (list.isEmpty) return _buildEmptyState();
            return _buildConnectionList(list);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        color: const Color(0xFF22262B),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 56, color: Color(0xFF4A5158)),
          const SizedBox(height: 16),
          const Text(
            'No network connections',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add SMB, FTP, or WebDAV connections\nto browse network files',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA0A5AA),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionList(List<NetworkConnection> list) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF22262B),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: list.map((conn) => _buildConnectionCard(conn)).toList(),
      ),
    );
  }

  Widget _buildConnectionCard(NetworkConnection conn) {
    final icon = switch (conn.protocol) {
      'smb' => Icons.computer,
      'ftp' => Icons.cloud,
      'webdav' => Icons.web,
      _ => Icons.link,
    };
    return Card(
      color: const Color(0xFF2C3136),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4DB6AC)),
        title: Text(conn.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${conn.protocol.toUpperCase()} \u00b7 ${conn.host}:${conn.port}',
          style: const TextStyle(color: Color(0xFFA0A5AA)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFA0A5AA)),
        onTap: () => _connect(conn),
      ),
    );
  }

  Future<void> _pasteUrl() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && mounted) {
      _urlController.text = data!.text!;
    }
  }

  Future<void> _playStream() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    final encoded = Uri.encodeComponent(url);
    if (mounted) context.push('${Routes.player}/$encoded');
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
      SnackBar(content: Text('Connected \u2014 ${files.length} items'), duration: const Duration(seconds: 2)),
    );

    if (files.isEmpty) return;
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('${conn.name} \u2014 /'),
        children: [
          ...files.take(20).map((f) => ListTile(
                dense: true,
                leading: Icon(f.isDirectory ? Icons.folder : Icons.movie_outlined),
                title: Text(f.name, overflow: TextOverflow.ellipsis),
                subtitle: Text(f.isDirectory ? 'Directory' : '${f.size}B'),
                onTap: () async {
                  if (f.isDirectory) {
                    Navigator.of(ctx).pop();
                    _connect(conn.copyWith(host: '${conn.host}${f.path}')); // Simple recursive browsing attempt
                    return;
                  }
                  
                  final proxyUrl = await service.streamFile(id: id, path: f.path);
                  if (!mounted) return;
                  if (proxyUrl != null) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    final encoded = Uri.encodeComponent(proxyUrl);
                    context.push('${Routes.player}/$encoded');
                  }
                },
              )),
          if (files.length > 20)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('+ more items'),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foregroundColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
