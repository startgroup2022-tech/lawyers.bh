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
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );

      await _secureStorage.saveAuthTokens(response.token, '');
      await _localDataSource.cacheUser(response.client.toEntity());

      return response.client.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<User> register({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        RegisterRequestModel(
          email: email,
          fullName: fullName,
          phone: phone,
          password: password,
          locale: 'ar',
        ),
      );

      // Registration returns a challenge ID, need to verify OTP
      return User(
        id: '',
        email: '',
        phone: '',
        fullName: '',
        role: UserRole.client,
        status: UserStatus.pending,
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        darkMode: false,
        preferredLanguage: 'ar',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        await _remoteDataSource.logout(token);
      }
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
      final token = await _secureStorage.getAccessToken();
      if (token == null) throw TokenExpiredException('No access token');

      final session = await _remoteDataSource.getSession(token);
      if (session.client != null) {
        await _localDataSource.cacheUser(session.client!.toEntity());
        return session.client!.toEntity();
      }
      throw TokenExpiredException('Session expired');
    } catch (e) {
      if (e is AppException) rethrow;
      throw TokenExpiredException('Failed to refresh session');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(
        ForgotPasswordRequestModel(email: email, locale: 'ar'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    try {
      await _remoteDataSource.verifyOtp(
        VerifyOtpRequestModel(id: '', code: code),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) throw TokenExpiredException('No access token');

      final session = await _remoteDataSource.getSession(token);
      if (session.client != null) {
        await _localDataSource.cacheUser(session.client!.toEntity());
        return session.client!.toEntity();
      }
      throw TokenExpiredException('No session');
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
      final token = await _secureStorage.getAccessToken();
      if (token == null) throw TokenExpiredException('No access token');

      final response = await _remoteDataSource.updateProfile(
        token,
        UpdateProfileRequestModel(
          fullName: data['fullName'] as String,
          phone: data['phone'] as String,
        ),
      );
      await _localDataSource.cacheUser(response.client.toEntity());
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> changePassword({required String current, required String newPassword}) async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) throw TokenExpiredException('No access token');

      await _remoteDataSource.changePassword(
        token,
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