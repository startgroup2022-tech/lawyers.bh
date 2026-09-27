import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/domain/usecases/auth/login_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/register_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/logout_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/forgot_password_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:lawyers_bh/domain/repositories/auth_repository.dart';
import 'package:lawyers_bh/domain/entities/user.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final AuthFlow flow;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.flow = AuthFlow.initial,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    AuthFlow? flow,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      flow: flow ?? this.flow,
    );
  }
}

enum AuthFlow { initial, login, register, forgotPassword, otp, verified, authenticated }

class AuthProvider extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final AuthRepository _authRepository;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _refreshTokenUseCase = refreshTokenUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _authRepository = authRepository,
        super(const AuthState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          flow: AuthFlow.authenticated,
        );
      } else {
        state = state.copyWith(isLoading: false, flow: AuthFlow.initial);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, flow: AuthFlow.initial);
    }
  }

  Future<void> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, error: null, flow: AuthFlow.login);
    try {
      final user = await _loginUseCase(phone: phone, password: password);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        flow: AuthFlow.authenticated,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message, flow: AuthFlow.login);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع', flow: AuthFlow.login);
      rethrow;
    }
  }

  Future<void> register({
    required String phone,
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null, flow: AuthFlow.register);
    try {
      final user = await _registerUseCase(
        phone: phone,
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        flow: AuthFlow.authenticated,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message, flow: AuthFlow.register);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع', flow: AuthFlow.register);
      rethrow;
    }
  }

  Future<void> forgotPassword(String phone) async {
    state = state.copyWith(isLoading: true, error: null, flow: AuthFlow.forgotPassword);
    try {
      await _forgotPasswordUseCase(phone);
      state = state.copyWith(isLoading: false, flow: AuthFlow.otp);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message, flow: AuthFlow.forgotPassword);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع', flow: AuthFlow.forgotPassword);
      rethrow;
    }
  }

  Future<void> verifyOtp({required String phone, required String code}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _verifyOtpUseCase(phone: phone, code: code);
      state = state.copyWith(isLoading: false, flow: AuthFlow.verified);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message, flow: AuthFlow.otp);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع', flow: AuthFlow.otp);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _logoutUseCase();
      state = const AuthState(flow: AuthFlow.initial);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setFlow(AuthFlow flow) {
    state = state.copyWith(flow: flow);
  }
}