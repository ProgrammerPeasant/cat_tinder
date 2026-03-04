import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageService {
  Future<void> savePassword(String key, String value);
  Future<String?> getPassword(String key);
  Future<void> deletePassword(String key);
}

class SecureStorageServiceImpl implements SecureStorageService {
  const SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> savePassword(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> getPassword(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> deletePassword(String key) async {
    await _storage.delete(key: key);
  }
}
