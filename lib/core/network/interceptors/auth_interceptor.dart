import 'package:dio/dio.dart';
import 'package:lawyers_bh/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _tryRefreshToken();
      if (refreshed && err.requestOptions.path != '/auth/refresh') {
        // Retry the original request
        final accessToken = await _secureStorage.getAccessToken();
        if (accessToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
          try {
            final response = await Dio().fetch(err.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            // If retry fails, clear tokens and redirect to login
            await _secureStorage.clearAuthData();
          }
        }
      } else {
        await _secureStorage.clearAuthData();
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${err.requestOptions.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        await _secureStorage.saveAuthTokens(newAccessToken, newRefreshToken);
        return true;
      }
    } catch (_) {}
    return false;
  }
}