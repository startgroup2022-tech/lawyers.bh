import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'root_shell.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _phoneCtrl = TextEditingController(text: '+973');
  final _codeCtrl = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      await appState.auth.sendOtp(_phoneCtrl.text.trim());
      setState(() => _otpSent = true);
    } on ApiException catch (e) {
      setState(() => _error = _friendlyError(e.error));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      final (token, user) = await appState.auth.verifyOtp(_phoneCtrl.text.trim(), _codeCtrl.text.trim());
      await appState.completeLogin(token, user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RootShell()));
    } on ApiException catch (e) {
      setState(() => _error = _friendlyError(e.error));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'invalid_phone':
        return 'رقم الهاتف غير صحيح';
      case 'invalid_or_expired_code':
        return 'الرمز غير صحيح أو منتهي الصلاحية';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  Future<void> _sosBeforeLogin() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('نجدة قانونية عاجلة', style: AppTextStyles.cairo(size: 15)),
        content: Text(
          'لتفعيل زر النجدة نحتاج تسجيل دخولك أولًا برقم هاتفك — العملية تأخذ ثوانٍ فقط.',
          style: AppTextStyles.tajawal(size: 13),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const BrandSeal(size: 42),
                  const SizedBox(width: 10),
                  Text('محامون البحرين', style: AppTextStyles.cairo(size: 16, weight: FontWeight.w800)),
                  const Spacer(),
                  InkWell(
                    onTap: _sosBeforeLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration:
                          BoxDecoration(color: AppColors.crimson, borderRadius: BorderRadius.circular(20)),
                      child: Text('SOS',
                          style: AppTextStyles.cairo(size: 11, weight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.navy, Color(0xFF132644), AppColors.crimson],
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تسجيل سريع ونجدة قانونية',
                        style: AppTextStyles.cairo(size: 18, weight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      'أنشئ حسابك برقم هاتفك واحصل على تحقق فوري (OTP)، أو اطلب نجدة قانونية عاجلة بضغطة واحدة.',
                      style: AppTextStyles.tajawal(size: 12, color: const Color(0xFFC9D3E4), height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('رقم الهاتف', style: AppTextStyles.tajawal(size: 11.5, weight: FontWeight.w600, color: AppColors.ink2)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneCtrl,
                enabled: !_otpSent,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.tajawal(size: 14),
                decoration: const InputDecoration(hintText: '+973XXXXXXXX'),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 14),
                Text('رمز التحقق (OTP)',
                    style: AppTextStyles.tajawal(size: 11.5, weight: FontWeight.w600, color: AppColors.ink2)),
                const SizedBox(height: 6),
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: AppTextStyles.tajawal(size: 14),
                  decoration: const InputDecoration(hintText: '000000', counterText: ''),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: AppTextStyles.tajawal(size: 12, color: AppColors.red)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                child: _loading
                    ? const SizedBox(
                        height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_otpSent ? 'تأكيد الرمز والدخول' : 'إرسال رمز التحقق'),
              ),
              if (_otpSent)
                TextButton(
                  onPressed: _loading ? null : () => setState(() => _otpSent = false),
                  child: Text('تغيير رقم الهاتف', style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
