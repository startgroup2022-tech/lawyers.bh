abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class BadRequestException extends AppException {
  const BadRequestException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.code});
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.code});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(super.message, {this.errors, super.code});
}

class CancelledException extends AppException {
  const CancelledException(super.message, {super.code});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException(super.message, {super.code});
}

class InvalidTokenException extends AuthException {
  const InvalidTokenException(super.message, {super.code});
}

class BiometricException extends AppException {
  const BiometricException(super.message, {super.code});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}