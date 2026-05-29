import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'logger.dart';

enum NetworkServiceType {
  smb('_smb._tcp'),
  ftp('_ftp._tcp'),
  webdav('_webdav._tcp'),
  sftp('_sftp-ssh._tcp');

  final String type;
  const NetworkServiceType(this.type);
}

class DiscoveredService {
  final String name;
  final String host;
  final int port;
  final NetworkServiceType type;

  DiscoveredService({
    required this.name,
    required this.host,
    required this.port,
    required this.type,
  });

  @override
  String toString() => '$name ($type) at $host:$port';
}

class NetworkDiscoveryService {
  final Map<NetworkServiceType, Discovery?> _discoveries = {};
  final StreamController<List<DiscoveredService>> _controller = StreamController.broadcast();
  final List<DiscoveredService> _results = [];

  Stream<List<DiscoveredService>> get services => _controller.stream;

  Future<void> start() async {
    _results.clear();
    _controller.add([]);
    
    for (final type in NetworkServiceType.values) {
      try {
        final discovery = await startDiscovery(type.type);
        _discoveries[type] = discovery;
        
        discovery.addListener(() {
          for (final service in discovery.services) {
            if (service.host != null && service.port != null) {
              final ds = DiscoveredService(
                name: service.name ?? 'Unknown',
                host: service.host!,
                port: service.port!,
                type: type,
              );
              
              if (!_results.any((e) => e.host == ds.host && e.port == ds.port && e.type == ds.type)) {
                _results.add(ds);
                _controller.add(List.unmodifiable(_results));
                Logger.info('Discovered service: $ds');
              }
            }
          }
        });
      } catch (e) {
        Logger.error('Failed to start discovery for ${type.type}', e);
      }
    }
  }

  Future<void> stop() async {
    for (final type in _discoveries.keys) {
      final discovery = _discoveries[type];
      if (discovery != null) {
        await stopDiscovery(discovery);
      }
    }
    _discoveries.clear();
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

final networkDiscoveryServiceProvider = Provider.autoDispose<NetworkDiscoveryService>((ref) {
  final service = NetworkDiscoveryService();
  ref.onDispose(() => service.dispose());
  return service;
});

final discoveredServicesProvider = StreamProvider.autoDispose<List<DiscoveredService>>((ref) {
  final discovery = ref.watch(networkDiscoveryServiceProvider);
  discovery.start();
  return discovery.services;
});
