import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lawyers_bh/core/constants/app_constants.dart';

abstract class SecureStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveAuthTokens(String accessToken, String refreshToken);
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearAuthData();
  Future<void> clearAll();
  Future<bool> hasAuthToken();
}

class SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorageImpl(this._storage);

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveAuthTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    import 'dart:convert';
    await _storage.write(key: AppConstants.userDataKey, value: jsonEncode(userData));
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    import 'dart:convert';
    final data = await _storage.read(key: AppConstants.userDataKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  @override
  Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.userDataKey),
    ]);
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> hasAuthToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}