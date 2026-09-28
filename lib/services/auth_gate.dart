import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../screens/login_otp_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

/// The professional prompt shown whenever a guest reaches a protected feature.
///
/// A guest can browse the public directory, specialties and services, but any
/// private action (booking, contracts, cases, messages, SOS) needs a real
/// account. This is a UI affordance only — it never mints a token or a fake
/// user, and the backend remains the authority on every protected endpoint.
///
/// Returns `true` when the guest chose to go to the login screen.
Future<bool> promptSignIn(BuildContext context, {String? feature}) async {
  final goToLogin = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const BrandSeal(size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('تسجيل الدخول مطلوب',
                      style: AppTextStyles.cairo(
                          size: 15, weight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              feature == null
                  ? 'هذه الميزة متاحة للحسابات المسجّلة. سجّل دخولك برقم هاتفك خلال ثوانٍ، أو تابع تصفّح المحامين والتخصصات كزائر.'
                  : '«$feature» متاح للحسابات المسجّلة. سجّل دخولك برقم هاتفك خلال ثوانٍ، أو تابع تصفّح المحامين والتخصصات كزائر.',
              style: AppTextStyles.tajawal(
                  size: 13, height: 1.7, color: AppColors.ink2),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تسجيل الدخول / إنشاء حساب'),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('متابعة التصفّح كزائر',
                  style:
                      AppTextStyles.tajawal(size: 12.5, color: AppColors.ink2)),
            ),
          ],
        ),
      ),
    ),
  );

  if (goToLogin == true && context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginOtpScreen()),
    );
    return true;
  }
  return false;
}

/// Runs [action] for a signed-in user, or shows the sign-in prompt otherwise.
Future<void> requireSignIn(
  BuildContext context,
  Future<void> Function() action, {
  String? feature,
}) async {
  if (context.read<AppState>().isLoggedIn) {
    await action();
    return;
  }
  await promptSignIn(context, feature: feature);
}
