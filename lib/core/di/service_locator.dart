import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:lawyers_bh/core/constants/app_constants.dart';
import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/core/network/interceptors/auth_interceptor.dart';
import 'package:lawyers_bh/core/network/interceptors/logging_interceptor.dart';
import 'package:lawyers_bh/core/storage/secure_storage.dart';
import 'package:lawyers_bh/core/storage/preferences_storage.dart';
import 'package:lawyers_bh/data/datasources/remote/auth_remote_datasource.dart';
import 'package:lawyers_bh/data/datasources/remote/lawyers_remote_datasource.dart';
import 'package:lawyers_bh/data/datasources/remote/cases_remote_datasource.dart';
import 'package:lawyers_bh/data/datasources/remote/contracts_remote_datasource.dart';
import 'package:lawyers_bh/data/datasources/remote/payments_remote_datasource.dart';
import 'package:lawyers_bh/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:lawyers_bh/data/datasources/local/auth_local_datasource.dart';
import 'package:lawyers_bh/data/datasources/local/settings_local_datasource.dart';
import 'package:lawyers_bh/data/repositories/auth_repository_impl.dart';
import 'package:lawyers_bh/data/repositories/lawyers_repository_impl.dart';
import 'package:lawyers_bh/data/repositories/cases_repository_impl.dart';
import 'package:lawyers_bh/data/repositories/contracts_repository_impl.dart';
import 'package:lawyers_bh/data/repositories/payments_repository_impl.dart';
import 'package:lawyers_bh/data/repositories/notifications_repository_impl.dart';
import 'package:lawyers_bh/domain/repositories/auth_repository.dart';
import 'package:lawyers_bh/domain/repositories/lawyers_repository.dart';
import 'package:lawyers_bh/domain/repositories/cases_repository.dart';
import 'package:lawyers_bh/domain/repositories/contracts_repository.dart';
import 'package:lawyers_bh/domain/repositories/payments_repository.dart';
import 'package:lawyers_bh/domain/repositories/notifications_repository.dart';
import 'package:lawyers_bh/domain/usecases/auth/login_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/register_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/logout_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/forgot_password_usecase.dart';
import 'package:lawyers_bh/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/get_lawyers_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/get_lawyer_details_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/search_lawyers_usecase.dart';
import 'package:lawyers_bh/domain/usecases/cases/get_cases_usecase.dart';
import 'package:lawyers_bh/domain/usecases/cases/get_case_details_usecase.dart';
import 'package:lawyers_bh/domain/usecases/contracts/get_contracts_usecase.dart';
import 'package:lawyers_bh/domain/usecases/contracts/sign_contract_usecase.dart';
import 'package:lawyers_bh/domain/usecases/payments/process_payment_usecase.dart';
import 'package:lawyers_bh/domain/usecases/notifications/get_notifications_usecase.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/presentation/providers/lawyers_provider.dart';
import 'package:lawyers_bh/presentation/providers/cases_provider.dart';
import 'package:lawyers_bh/presentation/providers/contracts_provider.dart';
import 'package:lawyers_bh/presentation/providers/payments_provider.dart';
import 'package:lawyers_bh/presentation/providers/notifications_provider.dart';
import 'package:lawyers_bh/presentation/providers/theme_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<SecureStorage>(() => SecureStorageImpl(sl()));
  sl.registerLazySingleton<PreferencesStorage>(() => PreferencesStorageImpl(sl()));

  // Network
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
      headers: AppConstants.headers,
    ));

    dio.interceptors.addAll([
      sl<AuthInterceptor>(),
      sl<LoggingInterceptor>(),
    ]);

    return dio;
  });

  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(sl()));
  sl.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());
  sl.registerLazySingleton<ApiClient>(() => ApiClientImpl(sl()));

  // Data Sources - Remote
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LawyersRemoteDataSource>(() => LawyersRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CasesRemoteDataSource>(() => CasesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ContractsRemoteDataSource>(() => ContractsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PaymentsRemoteDataSource>(() => PaymentsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<NotificationsRemoteDataSource>(() => NotificationsRemoteDataSourceImpl(sl()));

  // Data Sources - Local
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl(), sl()));
  sl.registerLazySingleton<SettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    secureStorage: sl(),
  ));

  sl.registerLazySingleton<LawyersRepository>(() => LawyersRepositoryImpl(
    remoteDataSource: sl(),
  ));

  sl.registerLazySingleton<CasesRepository>(() => CasesRepositoryImpl(
    remoteDataSource: sl(),
  ));

  sl.registerLazySingleton<ContractsRepository>(() => ContractsRepositoryImpl(
    remoteDataSource: sl(),
  ));

  sl.registerLazySingleton<PaymentsRepository>(() => PaymentsRepositoryImpl(
    remoteDataSource: sl(),
  ));

  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(
    remoteDataSource: sl(),
  ));

  // Use Cases - Auth
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<RefreshTokenUseCase>(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton<ForgotPasswordUseCase>(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton<VerifyOtpUseCase>(() => VerifyOtpUseCase(sl()));

  // Use Cases - Lawyers
  sl.registerLazySingleton<GetLawyersUseCase>(() => GetLawyersUseCase(sl()));
  sl.registerLazySingleton<GetLawyerDetailsUseCase>(() => GetLawyerDetailsUseCase(sl()));
  sl.registerLazySingleton<SearchLawyersUseCase>(() => SearchLawyersUseCase(sl()));

  // Use Cases - Cases
  sl.registerLazySingleton<GetCasesUseCase>(() => GetCasesUseCase(sl()));
  sl.registerLazySingleton<GetCaseDetailsUseCase>(() => GetCaseDetailsUseCase(sl()));

  // Use Cases - Contracts
  sl.registerLazySingleton<GetContractsUseCase>(() => GetContractsUseCase(sl()));
  sl.registerLazySingleton<SignContractUseCase>(() => SignContractUseCase(sl()));

  // Use Cases - Payments
  sl.registerLazySingleton<ProcessPaymentUseCase>(() => ProcessPaymentUseCase(sl()));

  // Use Cases - Notifications
  sl.registerLazySingleton<GetNotificationsUseCase>(() => GetNotificationsUseCase(sl()));

  // Presentation Providers
  sl.registerFactory<AuthProvider>(() => AuthProvider(
    loginUseCase: sl(),
    registerUseCase: sl(),
    logoutUseCase: sl(),
    refreshTokenUseCase: sl(),
    forgotPasswordUseCase: sl(),
    verifyOtpUseCase: sl(),
    authRepository: sl(),
  ));

  sl.registerFactory<LawyersProvider>(() => LawyersProvider(
    getLawyersUseCase: sl(),
    getLawyerDetailsUseCase: sl(),
    searchLawyersUseCase: sl(),
  ));

  sl.registerFactory<CasesProvider>(() => CasesProvider(
    getCasesUseCase: sl(),
    getCaseDetailsUseCase: sl(),
  ));

  sl.registerFactory<ContractsProvider>(() => ContractsProvider(
    getContractsUseCase: sl(),
    signContractUseCase: sl(),
  ));

  sl.registerFactory<PaymentsProvider>(() => PaymentsProvider(
    processPaymentUseCase: sl(),
  ));

  sl.registerFactory<NotificationsProvider>(() => NotificationsProvider(
    getNotificationsUseCase: sl(),
  ));

  sl.registerFactory<ThemeProvider>(() => ThemeProvider(sl()));
  sl.registerFactory<LocaleProvider>(() => LocaleProvider(sl()));
}