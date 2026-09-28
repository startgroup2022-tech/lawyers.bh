import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'client_shell.dart';
import 'root_shell.dart';

class LoginOtpScreen extends StatefulWidget {
  /// Optional banner shown above the form, e.g. when a session expired.
  final String? notice;
  const LoginOtpScreen({super.key, this.notice});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _phoneCtrl = TextEditingController(text: '+973');
  final _codeCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _loading = false;
  bool _guestLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  /// Bahrain numbers: +973 followed by 8 digits (first digit 3, 6 or 1).
  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return 'الرجاء إدخال رقم الهاتف';
    if (!RegExp(r'^\+?973[0-9]{8}$').hasMatch(digits)) {
      return 'أدخل رقم بحريني صحيح مثل +97339000000';
    }
    return null;
  }

  String? _validateCode(String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) {
      return 'الرجاء إدخال رمز التحقق';
    }
    if (!RegExp(r'^[0-9]{4,6}$').hasMatch(code)) {
      return 'الرمز مكوّن من 4 إلى 6 أرقام';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    if (_validatePhone(_phoneCtrl.text) != null) {
      setState(() => _error = _validatePhone(_phoneCtrl.text));
      _phoneFocus.requestFocus();
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      await appState.auth.sendOtp(_phoneCtrl.text.trim());
      if (!mounted) return;
      setState(() => _otpSent = true);
      _codeFocus.requestFocus();
    } on ApiException catch (e) {
      setState(() => _error = _friendlyError(e.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_validateCode(_codeCtrl.text) != null) {
      setState(() => _error = _validateCode(_codeCtrl.text));
      _codeFocus.requestFocus();
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      final (token, user) = await appState.auth
          .verifyOtp(_phoneCtrl.text.trim(), _codeCtrl.text.trim());
      await appState.completeLogin(token, user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RootShell()));
    } on ApiException catch (e) {
      setState(() => _error = _friendlyError(e.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Continues into the app without an account. No token, no fake user.
  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    await context.read<AppState>().continueAsGuest();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ClientShell(guest: true)));
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'invalid_phone':
        return 'رقم الهاتف غير صحيح';
      case 'invalid_or_expired_code':
        return 'الرمز غير صحيح أو منتهي الصلاحية';
      case 'network_error':
        return 'تعذّر الاتصال بالخادم، تحقق من اتصالك بالإنترنت';
      case 'network_timeout':
        return 'انتهت مهلة الاتصال بالخادم، حاول مرة أخرى';
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
          FilledButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const BrandSeal(size: 44),
                        const SizedBox(width: 10),
                        Text('محامون البحرين',
                            style: AppTextStyles.cairo(
                                size: 16, weight: FontWeight.w800)),
                        const Spacer(),
                        InkWell(
                          onTap: _sosBeforeLogin,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                                color: AppColors.crimson,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('SOS',
                                style: AppTextStyles.cairo(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.brandRedDark,
                            AppColors.brandRed,
                            Color(0xFF9E1717)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandLogo(height: 30, onDark: true),
                          const SizedBox(height: 14),
                          Text('منصّتك القانونية الموثوقة',
                              style: AppTextStyles.cairo(
                                  size: 19,
                                  weight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            'سجّل دخولك برقم هاتفك خلال ثوانٍ للتعاقد الآمن، متابعة القضية، والنجدة القانونية العاجلة.',
                            style: AppTextStyles.tajawal(
                                size: 12.5,
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.7),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (widget.notice != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.amberBg,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 18, color: AppColors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(widget.notice!,
                                  style: AppTextStyles.tajawal(
                                      size: 12.5,
                                      color: AppColors.amber,
                                      height: 1.5)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text('رقم الهاتف',
                        style: AppTextStyles.tajawal(
                            size: 11.5,
                            weight: FontWeight.w600,
                            color: AppColors.ink2)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneCtrl,
                      focusNode: _phoneFocus,
                      enabled: !_otpSent && !_loading,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.send,
                      autovalidateMode: AutovalidateMode.disabled,
                      onFieldSubmitted: (_) =>
                          _otpSent ? _verifyOtp() : _sendOtp(),
                      validator: _validatePhone,
                      style: AppTextStyles.tajawal(size: 15),
                      decoration: const InputDecoration(
                        hintText: '+973XXXXXXXX',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    if (_otpSent) ...[
                      const SizedBox(height: 16),
                      Text('رمز التحقق (OTP)',
                          style: AppTextStyles.tajawal(
                              size: 11.5,
                              weight: FontWeight.w600,
                              color: AppColors.ink2)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _codeCtrl,
                        focusNode: _codeFocus,
                        enabled: !_loading,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _verifyOtp(),
                        validator: _validateCode,
                        style: AppTextStyles.tajawal(size: 15, height: 1.2),
                        decoration: const InputDecoration(
                          hintText: '000000',
                          counterText: '',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.redBg,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 18, color: AppColors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: AppTextStyles.tajawal(
                                      size: 12.5, color: AppColors.red)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed:
                          _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_otpSent
                              ? 'تأكيد الرمز والدخول'
                              : 'إرسال رمز التحقق'),
                    ),
                    if (_otpSent)
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() {
                                  _otpSent = false;
                                  _codeCtrl.clear();
                                  _error = null;
                                }),
                        child: Text('تغيير رقم الهاتف',
                            style: AppTextStyles.tajawal(
                                size: 12, color: AppColors.ink2)),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('أو',
                              style: AppTextStyles.tajawal(
                                  size: 12, color: AppColors.ink3)),
                        ),
                        const Expanded(child: Divider(color: AppColors.line)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed:
                          (_loading || _guestLoading) ? null : _continueAsGuest,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                            color: AppColors.brandRed, width: 1.4),
                        foregroundColor: AppColors.brandRed,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm)),
                      ),
                      icon: _guestLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.brandRed))
                          : const Icon(Icons.explore_outlined, size: 18),
                      label: Text('الدخول كزائر',
                          style: AppTextStyles.cairo(
                              size: 13.5,
                              weight: FontWeight.w700,
                              color: AppColors.brandRed)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'يمكنك تصفّح المحامين والتخصصات كزائر، أما الخدمات الخاصة فتحتاج تسجيل دخول.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tajawal(
                          size: 11.5, color: AppColors.ink3, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
