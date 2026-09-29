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
/// expired session / first run → [LoginOtpScreen]. [BootstrapResult.offline]
/// stays on the splash so the failure is surfaced with a retry.
Widget? splashDestination(BootstrapResult result) {
  switch (result) {
    case BootstrapResult.authenticated:
      return const RootShell();
    case BootstrapResult.guest:
      return const ClientShell(guest: true);
    case BootstrapResult.sessionExpired:
      return const LoginOtpScreen(
          notice: 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد.');
    case BootstrapResult.firstRun:
      return const LoginOtpScreen();
    case BootstrapResult.offline:
      return null;
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

  /// Set when the stored session could not be validated because the backend
  /// was unreachable; the splash shows the failure and a retry instead of
  /// routing with a guess.
  String? _bootError;
  bool _retrying = false;

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

  Future<void> _boot({bool revealBrand = true}) async {
    final appState = context.read<AppState>();
    // Run the real session restore and, on first launch, a short brand reveal
    // together so the splash never lingers longer than necessary. The app
    // background is fetched alongside them; it is public and failure-tolerant,
    // so it never delays or blocks the hand-off.
    final delay =
        Future<void>.delayed(Duration(milliseconds: revealBrand ? 1100 : 0));
    final results = await Future.wait([
      appState.bootstrap(),
      appState.loadAppearance(),
      delay,
    ]);
    final result = results.first as BootstrapResult;
    if (!mounted) return;

    final next = splashDestination(result);
    if (next == null) {
      // Offline with a stored session: keep the user here and let them retry
      // rather than silently discarding a possibly-valid session.
      setState(() {
        _bootError =
            'تعذّر الاتصال بالخادم. تحقّق من اتصالك بالإنترنت ثم أعد المحاولة.';
        _retrying = false;
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _retry() {
    setState(() {
      _bootError = null;
      _retrying = true;
    });
    _boot(revealBrand: false);
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
                          // A true circle: the disc is square, and the 4:1
                          // wordmark is scaled to fit inside it rather than
                          // sizing the disc (which used to make an ellipse).
                          Container(
                            width: 250,
                            height: 250,
                            padding: const EdgeInsets.all(30),
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
                            child: const Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: BrandLogo(height: 48),
                              ),
                            ),
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
                    if (_bootError == null) ...[
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
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          _bootError!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.tajawal(
                              size: 12.5, height: 1.7, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _retrying ? null : _retry,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                        ),
                        child: _retrying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('إعادة المحاولة'),
                      ),
                    ],
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
