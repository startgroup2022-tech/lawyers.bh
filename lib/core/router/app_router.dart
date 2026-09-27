import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/presentation/screens/splash/splash_screen.dart';
import 'package:lawyers_bh/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:lawyers_bh/presentation/screens/auth/login/login_screen.dart';
import 'package:lawyers_bh/presentation/screens/auth/register/register_screen.dart';
import 'package:lawyers_bh/presentation/screens/auth/forgot_password/forgot_password_screen.dart';
import 'package:lawyers_bh/presentation/screens/auth/otp/otp_screen.dart';
import 'package:lawyers_bh/presentation/screens/home/home_screen.dart';
import 'package:lawyers_bh/presentation/screens/lawyers/directory/lawyers_directory_screen.dart';
import 'package:lawyers_bh/presentation/screens/lawyers/profile/lawyer_profile_screen.dart';
import 'package:lawyers_bh/presentation/screens/services/services_screen.dart';
import 'package:lawyers_bh/presentation/screens/appointments/appointments_screen.dart';
import 'package:lawyers_bh/presentation/screens/messages/messages_screen.dart';
import 'package:lawyers_bh/presentation/screens/favorites/favorites_screen.dart';
import 'package:lawyers_bh/presentation/screens/profile/profile_screen.dart';
import 'package:lawyers_bh/presentation/screens/settings/settings_screen.dart';
import 'package:lawyers_bh/presentation/screens/help/help_screen.dart';
import 'package:lawyers_bh/presentation/screens/about/about_screen.dart';
import 'package:lawyers_bh/presentation/screens/terms/terms_screen.dart';
import 'package:lawyers_bh/presentation/screens/privacy/privacy_screen.dart';
import 'package:lawyers_bh/presentation/screens/lawyer_dashboard/lawyer_dashboard_screen.dart';
import 'package:lawyers_bh/presentation/screens/admin/admin_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeScreen(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeTabScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) => const LawyersDirectoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.appointments,
                name: 'appointments',
                builder: (context, state) => const AppointmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                name: 'messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.lawyerProfile,
        name: 'lawyerProfile',
        builder: (context, state) => LawyerProfileScreen(lawyerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.services,
        name: 'services',
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.help,
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.lawyerDashboard,
        name: 'lawyerDashboard',
        builder: (context, state) => const LawyerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('الصفحة غير موجودة', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(state.error.toString(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String search = '/search';
  static const String appointments = '/appointments';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String lawyerProfile = '/lawyer/:id';
  static const String services = '/services';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String lawyerDashboard = '/lawyer-dashboard';
  static const String admin = '/admin';
}