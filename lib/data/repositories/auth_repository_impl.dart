import 'package:lawyers_bh/data/datasources/remote/auth_remote_datasource.dart';
import 'package:lawyers_bh/data/datasources/local/auth_local_datasource.dart';
import 'package:lawyers_bh/core/storage/secure_storage.dart';
import 'package:lawyers_bh/domain/repositories/auth_repository.dart';
import 'package:lawyers_bh/domain/entities/user.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required SecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _secureStorage = secureStorage;

  @override
  Future<User> login({required String phone, required String password}) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestModel(phone: phone, password: password, rememberMe: true),
      );

      await _secureStorage.saveAuthTokens(response.accessToken, response.refreshToken);
      await _localDataSource.cacheUser(response.user);

      return response.user.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<User> register({
    required String phone,
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        RegisterRequestModel(
          phone: phone,
          email: email,
          password: password,
          fullName: fullName,
          role: role.name,
        ),
      );

      await _secureStorage.saveAuthTokens(response.accessToken, response.refreshToken);
      await _localDataSource.cacheUser(response.user);

      return response.user.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout errors
    } finally {
      await _secureStorage.clearAuthData();
      await _localDataSource.clearUserCache();
    }
  }

  @override
  Future<User> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) throw TokenExpiredException('No refresh token');

      final response = await _remoteDataSource.refreshToken(refreshToken);
      await _secureStorage.saveAuthTokens(response.accessToken, response.refreshToken);

      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.cacheUser(user);

      return user.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw TokenExpiredException('Failed to refresh token');
    }
  }

  @override
  Future<void> forgotPassword(String phone) async {
    try {
      await _remoteDataSource.forgotPassword(phone);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> verifyOtp({required String phone, required String code}) async {
    try {
      await _remoteDataSource.verifyOtp(
        VerifyOtpRequestModel(phone: phone, code: code),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        // Try to get fresh data from server
        try {
          final freshUser = await _remoteDataSource.getCurrentUser();
          await _localDataSource.cacheUser(freshUser);
          return freshUser.toEntity();
        } catch (_) {
          return cachedUser.toEntity();
        }
      }

      // No cached user, try to get from server
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.cacheUser(user);
      return user.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasAuthToken();
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = await _remoteDataSource.updateProfile(data);
      await _localDataSource.cacheUser(user);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> changePassword({required String current, required String newPassword}) async {
    try {
      await _remoteDataSource.changePassword(
        ChangePasswordRequestModel(currentPassword: current, newPassword: newPassword),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> enableBiometric(bool enabled) async {
    await _localDataSource.saveLastRole(enabled.toString());
  }
}