import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../data/database/app_database.dart';

class ConnectionFormScreen extends ConsumerStatefulWidget {
  final NetworkConnection? existing;

  const ConnectionFormScreen({super.key, this.existing});

  @override
  ConsumerState<ConnectionFormScreen> createState() => _ConnectionFormScreenState();
}

class _ConnectionFormScreenState extends ConsumerState<ConnectionFormScreen> {
  final _nameCtrl = TextEditingController();
  final _hostCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _pathCtrl = TextEditingController();
  String _protocol = 'smb';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final c = widget.existing!;
      _nameCtrl.text = c.name;
      _hostCtrl.text = c.host;
      _portCtrl.text = c.port.toString();
      _usernameCtrl.text = c.username;
      _passwordCtrl.text = c.password;
      _pathCtrl.text = c.path;
      _protocol = c.protocol;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _pathCtrl.dispose();
    super.dispose();
  }

  int get _defaultPort {
    switch (_protocol) {
      case 'smb':
        return 445;
      case 'ftp':
        return 21;
      case 'webdav':
        return 80;
      default:
        return 0;
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _hostCtrl.text.isEmpty) return;

    await ref.read(networkConnectionDaoProvider).insertOne(
      NetworkConnectionsCompanion(
        name: Value(_nameCtrl.text),
        protocol: Value(_protocol),
        host: Value(_hostCtrl.text),
        port: Value(int.tryParse(_portCtrl.text) ?? _defaultPort),
        username: Value(_usernameCtrl.text),
        password: Value(_passwordCtrl.text),
        path: Value(_pathCtrl.text),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection saved')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Connection' : 'New Connection'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'My NAS'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _protocol,
            items: const [
              DropdownMenuItem(value: 'smb', child: Text('SMB')),
              DropdownMenuItem(value: 'ftp', child: Text('FTP')),
              DropdownMenuItem(value: 'webdav', child: Text('WebDAV')),
            ],
            onChanged: (v) {
              setState(() => _protocol = v ?? _protocol);
              if (_portCtrl.text.isEmpty) {
                _portCtrl.text = _defaultPort.toString();
              }
            },
            decoration: const InputDecoration(labelText: 'Protocol'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hostCtrl,
            decoration: const InputDecoration(labelText: 'Host', hintText: '192.168.1.100'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _portCtrl,
            decoration: InputDecoration(
              labelText: 'Port',
              hintText: _defaultPort.toString(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pathCtrl,
            decoration: const InputDecoration(labelText: 'Root Path', hintText: '/videos'),
          ),
        ],
      ),
    );
  }
}
