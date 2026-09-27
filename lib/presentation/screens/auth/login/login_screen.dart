import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = ref.read(authProvider.notifier);
    try {
      await authProvider.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        context.go(AppRoutes.home);
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
          onPressed: () => context.go(AppRoutes.onboarding),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  l10n.login,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بعودتك! سجل الدخول للوصول إلى حسابك',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink2),
                ),
                const SizedBox(height: 32),

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
                const SizedBox(height: 16),

                // Password field
                AppInputField(
                  label: l10n.password,
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.ink3),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.ink3,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Remember me and forgot password
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      activeColor: AppColors.navy,
                    ),
                    Text(l10n.rememberMe, style: AppTextStyles.bodyMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.forgotPassword),
                      child: Text(
                        l10n.forgotPassword,
                        style: AppTextStyles.labelMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login button
                AppButton(
                  text: l10n.login,
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading && authState.flow == AuthFlow.login,
                ),
                const SizedBox(height: 16),

                // Error message
                if (authState.error != null && authState.flow == AuthFlow.login) ...[
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

                // Divider
                Row(
                  children: [
                    const Expanded(child: AppDivider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.orLoginWith,
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const Expanded(child: AppDivider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Social login buttons
                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(
                        text: 'Google',
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/icons/google.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppOutlinedButton(
                        text: 'Apple',
                        onPressed: () {},
                        icon: const Icon(Icons.apple, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: Text(
                        l10n.register,
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