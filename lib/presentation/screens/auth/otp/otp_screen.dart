import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _phone = '';
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is String) {
        _phone = extra;
      }
      _startCountdown();
    });
  }

  void _startCountdown() {
    _canResend = false;
    _resendCountdown = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _resendCountdown--);
        return _resendCountdown > 0;
      }
      return false;
    }).then((_) {
      if (mounted) setState(() => _canResend = true);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    if (_otpCode.length != 6) return;

    final authProvider = ref.read(authProvider.notifier);
    try {
      await authProvider.verifyOtp(phone: _phone, code: _otpCode);
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // Error handled in provider
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;

    final authProvider = ref.read(authProvider.notifier);
    try {
      await authProvider.forgotPassword(_phone);
      _startCountdown();
    } catch (e) {
      // Error handled in provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => context.go(AppRoutes.forgotPassword),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                l10n.otp,
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'أدخل رمز التحقق المرسل إلى ',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink2),
                    ),
                    TextSpan(
                      text: _phone,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTextStyles.displayMedium.copyWith(fontSize: 24),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          borderSide: const BorderSide(color: AppColors.navy, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_otpCode.length == 6) {
                          _handleVerify();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم تستلم الرمز؟ ',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2),
                  ),
                  _canResend
                      ? TextButton(
                          onPressed: _handleResend,
                          child: Text(
                            l10n.resendCode,
                            style: AppTextStyles.labelMedium,
                          ),
                        )
                      : Text(
                          'إعادة الإرسال خلال $_resendCountdown ثانية',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink3),
                        ),
                ],
              ),
              const SizedBox(height: 16),

              // Error message
              if (authState.error != null && authState.flow == AuthFlow.otp) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    border: Border.all(color: AppColors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Spacer(),

              // Verify button (auto-verify when 6 digits entered)
              if (_otpCode.length < 6)
                AppButton(
                  text: l10n.verifyCode,
                  onPressed: _otpCode.length == 6 ? _handleVerify : null,
                  isLoading: authState.isLoading && authState.flow == AuthFlow.otp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}