import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = ref.read(authProvider.notifier);
    try {
      await authProvider.forgotPassword(_phoneController.text.trim());
      if (mounted) {
        context.go(AppRoutes.otp, extra: _phoneController.text.trim());
      }
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
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  l10n.resetPassword,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل رقم هاتفك المسجل وسنرسل لك رمز التحقق لإعادة تعيين كلمة المرور',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink2),
                ),
                const SizedBox(height: 40),

                // Phone field
                AppInputField(
                  label: l10n.phone,
                  hint: '05XXXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.ink3),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
                      return 'رقم هاتف غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Send button
                AppButton(
                  text: l10n.verifyCode,
                  onPressed: _handleForgotPassword,
                  isLoading: authState.isLoading && authState.flow == AuthFlow.forgotPassword,
                  icon: const Icon(Icons.send, size: 20),
                ),
                const SizedBox(height: 16),

                // Error message
                if (authState.error != null && authState.flow == AuthFlow.forgotPassword) ...[
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
                ],

                const Spacer(),

                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تذكرت كلمة المرور؟ ',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        l10n.login,
                        style: AppTextStyles.labelMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}