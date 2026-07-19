import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  const SecureTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> writeRefreshToken(String token) {
    return _storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> clear() => _storage.deleteAll();
}
