class AppConstants {
  static const String appName = 'محامون البحرين';
  static const String appNameEn = 'Lawyers.bh';
  static const String packageName = 'com.lawyersbh.app';
  static const String bundleId = 'com.lawyersbh.app';

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.lawyers.bh/v1',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://api.lawyers.bh/ws',
  );

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String biometricEnabledKey = 'biometric_enabled';

  static const int maxFileSize = 10 * 1024 * 1024;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  static const double defaultBorderRadius = 14.0;
  static const double smallBorderRadius = 10.0;
  static const double largeBorderRadius = 22.0;

  static const String defaultAvatarPlaceholder = 'assets/images/placeholder_avatar.png';
  static const String defaultLawyerPlaceholder = 'assets/images/placeholder_lawyer.png';

  static const int pageSize = 20;
  static const int maxSearchHistory = 10;

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'ar',
  };
}