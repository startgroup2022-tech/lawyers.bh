import 'package:lawyers_bh/domain/entities/user.dart';
import 'package:lawyers_bh/domain/repositories/repositories.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<User> call({
    required String email,
    required String fullName,
    required String phone,
    required String password,
  }) {
    return _repository.register(
      email: email,
      fullName: fullName,
      phone: phone,
      password: password,
    );
  }
}

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}

class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<User> call() {
    return _repository.refreshToken();
  }
}

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.forgotPassword(email);
  }
}

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<void> call({required String email, required String code}) {
    return _repository.verifyOtp(email: email, code: code);
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User> call() {
    return _repository.getCurrentUser();
  }
}

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<void> call(Map<String, dynamic> data) {
    return _repository.updateProfile(data);
  }
}

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<void> call({required String current, required String newPassword}) {
    return _repository.changePassword(current: current, newPassword: newPassword);
  }
}

class EnableBiometricUseCase {
  final AuthRepository _repository;

  EnableBiometricUseCase(this._repository);

  Future<void> call(bool enabled) {
    return _repository.enableBiometric(enabled);
  }
}