import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'client_shell.dart';
import 'root_shell.dart';

/// Sign in and account creation against the Lawyers.bh platform API.
///
/// Sign-in is email + password (`/api/mobile/client-auth/login`). Creating an
/// account emails a 6-digit code (`request` then `verify`); the platform has no
/// SMS OTP, so the form asks for an email and a password rather than a phone
/// number alone.
class LoginOtpScreen extends StatefulWidget {
  /// Optional banner shown above the form, e.g. when a session expired.
  final String? notice;
  const LoginOtpScreen({super.key, this.notice});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+973');
  final _licenseCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();

  /// Which sign-in door the form is on. A client signs in with email + password
  /// and can create an account; a lawyer signs in with their licence number +
  /// password. The platform keeps the two as separate accounts, so the choice is
  /// explicit rather than guessed from the credentials.
  bool _lawyerMode = false;
  bool _register = false;
  bool _codeSent = false;
  bool _loading = false;
  bool _guestLoading = false;
  String? _challengeId;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    _codeCtrl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _selectDoor({required bool lawyer}) {
    setState(() {
      _lawyerMode = lawyer;
      // Lawyer accounts are not created through this door, so drop any
      // half-finished registration state when switching.
      _register = false;
      _codeSent = false;
      _challengeId = null;
      _codeCtrl.clear();
      _error = null;
    });
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
    if (!RegExp(r'^[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+$').hasMatch(email)) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (password.length < 8) return 'كلمة المرور 8 أحرف على الأقل';
    return null;
  }

  /// International numbers stored in E.164 (`+` then 8–15 digits).
  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[\s()-]'), '');
    if (digits.isEmpty) return 'الرجاء إدخال رقم الهاتف';
    if (!RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(digits)) {
      return 'أدخل رقمًا دوليًا صحيحًا مثل +97339000000';
    }
    return null;
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().length < 2) return 'الرجاء إدخال الاسم الكامل';
    return null;
  }

  String? _validateCode(String? value) {
    if (!RegExp(r'^[0-9]{6}$').hasMatch((value ?? '').trim())) {
      return 'الرمز مكوّن من 6 أرقام';
    }
    return null;
  }

  String? _validateLicense(String? value) {
    if ((value ?? '').trim().isEmpty) return 'الرجاء إدخال رقم الترخيص';
    return null;
  }

  Future<void> _signIn() async {
    if (_lawyerMode) return _signInAsLawyer();

    final emailError = _validateEmail(_emailCtrl.text);
    final passwordError = _validatePassword(_passwordCtrl.text);
    if (emailError != null || passwordError != null) {
      setState(() => _error = emailError ?? passwordError);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      final (token, user) =
          await appState.auth.login(_emailCtrl.text, _passwordCtrl.text);
      await appState.completeLogin(token, user);
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const RootShell()));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تسجيل الدخول، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// The professional door: licence number + password against
  /// `POST /api/lawyers/login`. A client account cannot sign in here, and a
  /// lawyer account cannot sign in through the client door — the platform keeps
  /// them as separate accounts.
  Future<void> _signInAsLawyer() async {
    final licenseError = _validateLicense(_licenseCtrl.text);
    final passwordError = _validatePassword(_passwordCtrl.text);
    if (licenseError != null || passwordError != null) {
      setState(() => _error = licenseError ?? passwordError);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      final (token, user) = await appState.lawyerAuth.login(
        licenseNumber: _licenseCtrl.text,
        password: _passwordCtrl.text,
      );
      await appState.completeLogin(token, user);
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const RootShell()));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تسجيل الدخول، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestRegistration() async {
    final errors = [
      _validateName(_nameCtrl.text),
      _validateEmail(_emailCtrl.text),
      _validatePassword(_passwordCtrl.text),
      _validatePhone(_phoneCtrl.text),
    ].whereType<String>().toList();
    if (errors.isNotEmpty) {
      setState(() => _error = errors.first);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      final (challengeId, _) = await appState.auth.requestAccount(
        mode: 'register',
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        fullName: _nameCtrl.text,
        phone: _phoneCtrl.text,
      );
      if (!mounted) return;
      setState(() {
        _challengeId = challengeId;
        _codeSent = true;
      });
      _codeFocus.requestFocus();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر إرسال الرمز، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyRegistration() async {
    final codeError = _validateCode(_codeCtrl.text);
    if (codeError != null) {
      setState(() => _error = codeError);
      _codeFocus.requestFocus();
      return;
    }
    final challengeId = _challengeId;
    if (challengeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      final (token, user) =
          await appState.auth.verify(challengeId, _codeCtrl.text.trim());
      await appState.completeLogin(token, user);
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const RootShell()));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر التحقق من الرمز، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() => _register
      ? (_codeSent ? _verifyRegistration() : _requestRegistration())
      : _signIn();

  /// Continues into the app without an account. No token, no fake user.
  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    try {
      await context.read<AppState>().continueAsGuest();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ClientShell(guest: true)));
    } finally {
      if (mounted) setState(() => _guestLoading = false);
    }
  }

  /// Maps a backend failure to an Arabic message.
  ///
  /// The client door answers with a stable error *code*; the lawyer door
  /// (`/api/lawyers/login`) answers with a `message` and a status, so a code we
  /// do not recognise falls back to the status rather than a generic string.
  String _friendlyError(ApiException e) {
    switch (e.error) {
      case 'invalid_credentials':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'invalid_email':
        return 'البريد الإلكتروني غير صحيح';
      case 'invalid_password':
        return 'كلمة المرور 8 أحرف على الأقل';
      case 'invalid_name':
        return 'الرجاء إدخال الاسم الكامل';
      case 'invalid_phone':
        return 'رقم الهاتف غير صحيح';
      case 'invalid_code':
        return 'الرمز غير صحيح أو منتهي الصلاحية';
      case 'account_exists':
        return 'يوجد حساب بهذا البريد بالفعل، سجّل الدخول';
      case 'account_required':
        return 'أكمل بيانات الحساب أولًا';
      case 'account_unavailable':
      case 'ACCOUNT_UNAVAILABLE':
        return 'الحساب غير متاح، تواصل مع الدعم';
      case 'rate_limited':
        return 'محاولات كثيرة، حاول بعد قليل';
      case 'network_error':
        return 'تعذّر الاتصال بالخادم، تحقق من اتصالك بالإنترنت';
      case 'network_timeout':
        return 'انتهت مهلة الاتصال بالخادم، حاول مرة أخرى';
    }
    // Lawyer login answers with a message and a status, not a code.
    if (e.statusCode == 401) return 'بيانات الدخول غير صحيحة';
    if (e.statusCode == 403) return 'الحساب غير متاح، تواصل مع الدعم';
    if (e.statusCode == 400) return 'تحقّق من البيانات المدخلة وحاول مرة أخرى';
    return 'حدث خطأ، حاول مرة أخرى';
  }

  Future<void> _sosBeforeLogin() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('نجدة قانونية عاجلة', style: AppTextStyles.cairo(size: 15)),
        content: Text(
          'لتفعيل زر النجدة نحتاج تسجيل دخولك أولًا — العملية تأخذ ثوانٍ فقط.',
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final busy = _loading || _guestLoading;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const BrandSeal(size: 44),
                      const SizedBox(width: 10),
                      Text('محامون البحرين',
                          style: AppTextStyles.cairo(size: 16, weight: FontWeight.w800)),
                      const Spacer(),
                      InkWell(
                        onTap: _sosBeforeLogin,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: AppColors.crimson,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('SOS',
                              style: AppTextStyles.cairo(
                                  size: 11, weight: FontWeight.w700, color: Colors.white)),
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
                        colors: [AppColors.brandRedDark, AppColors.brandRed, Color(0xFF9E1717)],
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
                                size: 19, weight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          'سجّل دخولك للوصول إلى حسابك في منصة محامون البحرين.',
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
                    _banner(widget.notice!, AppColors.amberBg, AppColors.amber,
                        Icons.info_outline),
                    const SizedBox(height: 16),
                  ],
                  if (!_lawyerMode)
                    Row(
                      children: [
                        Expanded(
                          child: _modeTab('تسجيل الدخول', !_register, () {
                            setState(() {
                              _register = false;
                              _codeSent = false;
                              _error = null;
                            });
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _modeTab('حساب جديد', _register, () {
                            setState(() {
                              _register = true;
                              _codeSent = false;
                              _error = null;
                            });
                          }),
                        ),
                      ],
                    ),
                  if (!_lawyerMode) const SizedBox(height: 18),
                  // The professional door is chosen explicitly, because a lawyer
                  // account and a client account are separate on the platform.
                  if (!_register)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _modeTab('عميل', !_lawyerMode,
                                () => _selectDoor(lawyer: false)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _modeTab('محامٍ', _lawyerMode,
                                () => _selectDoor(lawyer: true)),
                          ),
                        ],
                      ),
                    ),
                  if (_register) ...[
                    _label('الاسم الكامل'),
                    TextField(
                      controller: _nameCtrl,
                      enabled: !_codeSent && !busy,
                      textInputAction: TextInputAction.next,
                      style: AppTextStyles.tajawal(size: 15),
                      decoration: const InputDecoration(
                        hintText: 'الاسم كما في الهوية',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_lawyerMode) ...[
                    _label('رقم الترخيص'),
                    TextField(
                      controller: _licenseCtrl,
                      enabled: !busy,
                      textInputAction: TextInputAction.next,
                      style: AppTextStyles.tajawal(size: 15),
                      decoration: const InputDecoration(
                        hintText: 'رقم القيد في نقابة المحامين',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                    ),
                  ] else ...[
                    _label('البريد الإلكتروني'),
                    TextField(
                      controller: _emailCtrl,
                      enabled: !_codeSent && !busy,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: AppTextStyles.tajawal(size: 15),
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.mail_outline, size: 20),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _label('كلمة المرور'),
                  TextField(
                    controller: _passwordCtrl,
                    enabled: !_codeSent && !busy,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: AppTextStyles.tajawal(size: 15),
                    decoration: const InputDecoration(
                      hintText: '٨ أحرف على الأقل',
                      prefixIcon: Icon(Icons.lock_outline, size: 20),
                    ),
                  ),
                  if (_register) ...[
                    const SizedBox(height: 14),
                    _label('رقم الهاتف'),
                    TextField(
                      controller: _phoneCtrl,
                      enabled: !_codeSent && !busy,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      style: AppTextStyles.tajawal(size: 15),
                      decoration: const InputDecoration(
                        hintText: '+973XXXXXXXX',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                  ],
                  if (_codeSent) ...[
                    const SizedBox(height: 14),
                    _label('رمز التحقق المُرسل بالبريد'),
                    TextField(
                      controller: _codeCtrl,
                      focusNode: _codeFocus,
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      style: AppTextStyles.tajawal(size: 15, height: 1.2),
                      decoration: const InputDecoration(
                        hintText: '000000',
                        counterText: '',
                        prefixIcon: Icon(Icons.verified_outlined, size: 20),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    _banner(_error!, AppColors.redBg, AppColors.red, Icons.error_outline),
                  ],
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(_lawyerMode
                            ? 'دخول لوحة المحامي'
                            : (_register
                                ? (_codeSent ? 'تأكيد الرمز وإنشاء الحساب' : 'إرسال رمز التحقق')
                                : 'تسجيل الدخول')),
                  ),
                  if (_codeSent)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => setState(() {
                                _codeSent = false;
                                _challengeId = null;
                                _codeCtrl.clear();
                                _error = null;
                              }),
                      child: Text('تغيير البيانات',
                          style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('أو',
                            style: AppTextStyles.tajawal(size: 12, color: AppColors.ink3)),
                      ),
                      const Expanded(child: Divider(color: AppColors.line)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: busy ? null : _continueAsGuest,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.brandRed, width: 1.4),
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
                            size: 13.5, weight: FontWeight.w700, color: AppColors.brandRed)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'يمكنك تصفّح المحامين كزائر، أما الخدمات الخاصة فتحتاج تسجيل دخول.',
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
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: AppTextStyles.tajawal(
                size: 11.5, weight: FontWeight.w600, color: AppColors.ink2)),
      );

  Widget _modeTab(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          border: Border.all(color: selected ? AppColors.navy : AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Text(label,
            style: AppTextStyles.cairo(
                size: 13,
                weight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.ink2)),
      ),
    );
  }

  Widget _banner(String text, Color bg, Color fg, IconData icon) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: AppTextStyles.tajawal(size: 12.5, color: fg, height: 1.5)),
            ),
          ],
        ),
      );
}
