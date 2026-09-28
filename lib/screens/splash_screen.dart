import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'client_shell.dart';
import 'login_otp_screen.dart';
import 'root_shell.dart';

/// The experience a completed bootstrap should hand off to.
///
/// Kept as a pure function so the routing decision is testable on its own:
/// auth client/lawyer → [RootShell], returning guest → guest [ClientShell],
/// expired session / first run → [LoginOtpScreen].
Widget splashDestination(BootstrapResult result) {
  switch (result) {
    case BootstrapResult.authenticated:
      return const RootShell();
    case BootstrapResult.guest:
      return const ClientShell(guest: true);
    case BootstrapResult.sessionExpired:
      return const LoginOtpScreen(notice: 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد.');
    case BootstrapResult.firstRun:
      return const LoginOtpScreen();
  }
}

/// The mandatory launch screen.
///
/// It stays up while [AppState.bootstrap] resolves the stored session, then
/// hands off to the right experience via [splashDestination]. The hand-off is
/// driven by the session result, not by a fixed timer, so there is no
/// artificial delay — the logo is only on screen as long as the real
/// initialisation takes (with a short minimum so the brand is seen).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _fade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.7, curve: Curves.easeOutBack)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final appState = context.read<AppState>();
    // Run the real session restore and a short brand reveal together, so the
    // splash never lingers longer than necessary.
    final results = await Future.wait([
      appState.bootstrap(),
      Future<void>.delayed(const Duration(milliseconds: 1100)),
    ]);
    final result = results.first as BootstrapResult;
    if (!mounted) return;

    final next = splashDestination(result);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.brandRedDark,
              AppColors.brandRed,
              Color(0xFF9E1717)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const BrandLogo(height: 60),
                          ),
                          const SizedBox(height: 22),
                          Text('محامون البحرين',
                              style: AppTextStyles.cairo(
                                  size: 24,
                                  weight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 8),
                          Container(
                              width: 46,
                              height: 3,
                              color: Colors.white.withValues(alpha: 0.55)),
                          const SizedBox(height: 10),
                          Text('منصّتك القانونية الموثوقة',
                              style: AppTextStyles.tajawal(
                                  size: 13.5,
                                  color: Colors.white.withValues(alpha: 0.92))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 44),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.4),
                    ),
                    const SizedBox(height: 14),
                    Text('جارٍ تحضير جلستك…',
                        style: AppTextStyles.tajawal(
                            size: 12.5,
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
