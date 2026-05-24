import 'dart:convert';
import 'package:flutter/services.dart';

class NetworkFile {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final int lastModified;

  const NetworkFile({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    this.lastModified = 0,
  });

  factory NetworkFile.fromJson(Map<String, dynamic> json) => NetworkFile(
        name: json['name'] as String,
        path: json['path'] as String,
        isDirectory: json['isDirectory'] as bool,
        size: json['size'] as int? ?? 0,
        lastModified: json['lastModified'] as int? ?? 0,
      );
}

class NetworkService {
  static const _channel = MethodChannel('com.pixelvibe/network');

  Future<bool> connect({
    required String id,
    required String protocol,
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('connect', {
        'id': id,
        'protocol': protocol,
        'host': host,
        'port': port,
        'username': username,
        'password': password,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<List<NetworkFile>> listFiles({
    required String id,
    String path = '/',
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('listFiles', {
        'id': id,
        'path': path,
      });
      if (result == null) return [];
      final list = jsonDecode(result) as List<dynamic>;
      return list.map((e) => NetworkFile.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> streamFile({required String id, required String path}) async {
    try {
      return await _channel.invokeMethod<String>('streamFile', {
        'id': id,
        'path': path,
      });
    } catch (e) {
      return null;
    }
  }

  Future<bool> disconnect(String id) async {
    try {
      final result = await _channel.invokeMethod<bool>('disconnect', {'id': id});
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
