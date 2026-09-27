import 'package:lawyers_bh/core/storage/secure_storage.dart';
import 'package:lawyers_bh/core/storage/preferences_storage.dart';
import 'package:lawyers_bh/data/models/auth_models.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUserCache();
  Future<void> saveOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
  Future<void> saveLastRole(String role);
  Future<String?> getLastRole();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;
  final PreferencesStorage _preferencesStorage;

  AuthLocalDataSourceImpl(this._secureStorage, this._preferencesStorage);

  @override
  Future<void> cacheUser(UserModel user) async {
    await _secureStorage.saveUserData(user.toJson());
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final data = await _secureStorage.getUserData();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> clearUserCache() async {
    await _secureStorage.clearAuthData();
  }

  @override
  Future<void> saveOnboardingCompleted() async {
    await _preferencesStorage.setOnboardingCompleted(true);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _preferencesStorage.isOnboardingCompleted();
  }

  @override
  Future<void> saveLastRole(String role) async {
    await _preferencesStorage.setLastSelectedRole(role);
  }

  @override
  Future<String?> getLastRole() async {
    return _preferencesStorage.getLastSelectedRole();
  }
}