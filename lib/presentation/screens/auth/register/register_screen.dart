import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.client;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = ref.read(authProvider.notifier);
    try {
      await authProvider.register(
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        role: _selectedRole,
      );
      if (mounted) {
        context.go(AppRoutes.otp);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  l10n.register,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'أنشئ حسابك الجديد للانضمام إلى منصة محامين البحرين',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink2),
                ),
                const SizedBox(height: 32),

                // Role selection
                Text(
                  'نوع الحساب',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'عميل',
                        subtitle: 'أبحث عن محامٍ',
                        icon: Icons.person_outline,
                        isSelected: _selectedRole == UserRole.client,
                        onTap: () => setState(() => _selectedRole = UserRole.client),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        title: 'محامٍ',
                        subtitle: 'أقدم خدمات قانونية',
                        icon: Icons.gavel,
                        isSelected: _selectedRole == UserRole.lawyer,
                        onTap: () => setState(() => _selectedRole = UserRole.lawyer),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Full name
                AppInputField(
                  label: 'الاسم الكامل',
                  hint: 'أحمد محمد',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.ink3),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'يرجى إدخال الاسم الأول والأخير';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone
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
                      return 'رقم هاتف غير صالح (يجب أن يبدأ بـ 05 ويحتوي على 10 أرقام)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                AppInputField(
                  label: l10n.email,
                  hint: 'email@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.ink3),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'بريد إلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
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
                    if (value.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password
                AppInputField(
                  label: l10n.confirmPassword,
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.ink3),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.ink3,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى تأكيد كلمة المرور';
                    }
                    if (value != _passwordController.text) {
                      return l10n.passwordsNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Register button
                AppButton(
                  text: l10n.register,
                  onPressed: _handleRegister,
                  isLoading: authState.isLoading && authState.flow == AuthFlow.register,
                ),
                const SizedBox(height: 16),

                // Error message
                if (authState.error != null && authState.flow == AuthFlow.register) ...[
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

                // Terms and conditions
                Text(
                  'بإنشاء حساب، أنت توافق على ${l10n.termsConditions} و ${l10n.privacyPolicy}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.ink3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
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

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimationDuration,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldBg : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.navy : AppColors.ink2,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected ? AppColors.navy : AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}