import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialService {
  static const _storage = FlutterSecureStorage();
  static const _prefix = 'network_pwd_';

  static Future<void> storePassword(String connectionId, String password) async {
    if (password.isEmpty) return;
    await _storage.write(key: '$_prefix$connectionId', value: password);
  }

  static Future<String> fetchPassword(String connectionId) async {
    return await _storage.read(key: '$_prefix$connectionId') ?? '';
  }

  static Future<void> deletePassword(String connectionId) async {
    await _storage.delete(key: '$_prefix$connectionId');
  }
}
