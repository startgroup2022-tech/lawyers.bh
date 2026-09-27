import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lawyers_bh/domain/entities/user.dart';
import 'package:lawyers_bh/domain/usecases/auth/login_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/register_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/logout_usecase.dart';
import 'package:lawyers_bh/domain/repositories/auth_repository.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockRefreshTokenUseCase mockRefreshTokenUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockRefreshTokenUseCase = MockRefreshTokenUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthProvider Tests', () {
    test('initial state should be correct', () {
      final provider = AuthProvider(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshTokenUseCase: mockRefreshTokenUseCase,
        forgotPasswordUseCase: mockForgotPasswordUseCase,
        verifyOtpUseCase: mockVerifyOtpUseCase,
        authRepository: mockAuthRepository,
      );

      expect(provider.state.user, isNull);
      expect(provider.state.isLoading, isFalse);
      expect(provider.state.isAuthenticated, isFalse);
      expect(provider.state.flow, equals(AuthFlow.initial));
    });

    test('login should update state on success', () async {
      final user = User(
        id: '1',
        email: 'test@example.com',
        phone: '0501234567',
        fullName: 'Test User',
        role: UserRole.client,
        status: UserStatus.active,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        darkMode: false,
        preferredLanguage: 'ar',
      );

      when(() => mockLoginUseCase(phone: '0501234567', password: 'password123'))
          .thenAnswer((_) async => user);
      when(() => mockAuthRepository.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => user);

      final provider = AuthProvider(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshTokenUseCase: mockRefreshTokenUseCase,
        forgotPasswordUseCase: mockForgotPasswordUseCase,
        verifyOtpUseCase: mockVerifyOtpUseCase,
        authRepository: mockAuthRepository,
      );

      await provider.login(phone: '0501234567', password: 'password123');

      expect(provider.state.user, equals(user));
      expect(provider.state.isAuthenticated, isTrue);
      expect(provider.state.flow, equals(AuthFlow.authenticated));
      expect(provider.state.isLoading, isFalse);
    });

    test('login should update state on failure', () async {
      when(() => mockLoginUseCase(phone: '0501234567', password: 'wrong'))
          .thenThrow(const UnauthorizedException('Invalid credentials'));

      final provider = AuthProvider(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshTokenUseCase: mockRefreshTokenUseCase,
        forgotPasswordUseCase: mockForgotPasswordUseCase,
        verifyOtpUseCase: mockVerifyOtpUseCase,
        authRepository: mockAuthRepository,
      );

      await expectLater(
        () => provider.login(phone: '0501234567', password: 'wrong'),
        throwsA(isA<UnauthorizedException>()),
      );

      expect(provider.state.isAuthenticated, isFalse);
      expect(provider.state.error, equals('Invalid credentials'));
      expect(provider.state.flow, equals(AuthFlow.login));
    });

    test('register should update state on success', () async {
      final user = User(
        id: '1',
        email: 'new@example.com',
        phone: '0501234568',
        fullName: 'New User',
        role: UserRole.lawyer,
        status: UserStatus.active,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        darkMode: false,
        preferredLanguage: 'ar',
      );

      when(() => mockRegisterUseCase(
        phone: '0501234568',
        email: 'new@example.com',
        password: 'password123',
        fullName: 'New User',
        role: UserRole.lawyer,
      )).thenAnswer((_) async => user);

      final provider = AuthProvider(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshTokenUseCase: mockRefreshTokenUseCase,
        forgotPasswordUseCase: mockForgotPasswordUseCase,
        verifyOtpUseCase: mockVerifyOtpUseCase,
        authRepository: mockAuthRepository,
      );

      await provider.register(
        phone: '0501234568',
        email: 'new@example.com',
        password: 'password123',
        fullName: 'New User',
        role: UserRole.lawyer,
      );

      expect(provider.state.user, equals(user));
      expect(provider.state.isAuthenticated, isTrue);
    });

    test('logout should reset state', () async {
      final user = User(
        id: '1',
        email: 'test@example.com',
        phone: '0501234567',
        fullName: 'Test User',
        role: UserRole.client,
        status: UserStatus.active,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        darkMode: false,
        preferredLanguage: 'ar',
      );

      when(() => mockAuthRepository.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => user);
      when(() => mockLogoutUseCase()).thenAnswer((_) async => {});

      final provider = AuthProvider(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshTokenUseCase: mockRefreshTokenUseCase,
        forgotPasswordUseCase: mockForgotPasswordUseCase,
        verifyOtpUseCase: mockVerifyOtpUseCase,
        authRepository: mockAuthRepository,
      );

      // Simulate logged in state
      await provider.initialize();

      await provider.logout();

      expect(provider.state.user, isNull);
      expect(provider.state.isAuthenticated, isFalse);
      expect(provider.state.flow, equals(AuthFlow.initial));
    });
  });
}