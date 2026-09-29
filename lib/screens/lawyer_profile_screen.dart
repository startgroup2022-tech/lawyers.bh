import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/lawyer.dart';
import '../services/auth_gate.dart';
import '../theme/app_theme.dart';
import 'booking_screen.dart';

/// A lawyer's public profile.
///
/// The directory endpoint (`GET /api/mobile/lawyers`) now publishes the real
/// published profile: name (Arabic + English), phone, email, status,
/// subscription type, photo, professional title, experience, specialties,
/// languages, working hours and rating. Fields a lawyer has not filled in
/// arrive empty and are shown as an explicit gap, never invented.
///
/// The two prominent actions — voice consultation and booking — open the real
/// booking flow, which is backed by the mobile availability and appointment
/// routes. Emergency dispatch has no client route on this deployment, so a
/// lawyer's emergency badge is informational rather than a button.
class LawyerProfileScreen extends StatelessWidget {
  final Lawyer lawyer;
  const LawyerProfileScreen({super.key, required this.lawyer});

  /// Opens the real booking flow, asking a guest to sign in first because the
  /// booking route is authenticated.
  Future<void> _book(BuildContext context, {String? methodCode}) async {
    await requireSignIn(context, () async {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingScreen(lawyer: lawyer, initialMethodCode: methodCode),
        ),
      );
    }, feature: 'الحجز');
  }

  /// A human label for the lawyer's subscription tier.
  String get _roleLabel {
    switch (lawyer.subscriptionType) {
      case 'consultant':
        return 'استشاري قانوني';
      case 'mediator':
        return 'وسيط';
      case 'arbitrator':
        return 'محكّم';
      case 'expert':
        return 'خبير';
      case 'emergency':
      case 'sos':
        return 'محامي نجدة عاجلة';
      default:
        return 'محامٍ';
    }
  }

  bool get _isApproved => lawyer.status == 'approved';

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('تم نسخ $label')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          _header(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _identityCard(),
                const SizedBox(height: 16),
                _primaryActions(context),
                const SizedBox(height: 18),
                _sectionTitle('المعلومات المهنية'),
                _professionalCard(),
                const SizedBox(height: 18),
                _sectionTitle('معلومات التواصل'),
                _contactCard(context),
                const SizedBox(height: 18),
                _sectionTitle('الخدمات التي يقدّمها'),
                _servicesCard(context),
                const SizedBox(height: 16),
                _profileDataNotice(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 42),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.brandDark, AppColors.navyLight],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCBD5E1)),
                      const SizedBox(width: 6),
                      Text('رجوع',
                          style: AppTextStyles.tajawal(
                              size: 13, color: const Color(0xFFCBD5E1))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      // The platform publishes a real photo when the lawyer
                      // uploaded one; otherwise the initials stand in.
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        foregroundImage: lawyer.hasPhoto
                            ? NetworkImage(lawyer.photoUrl!)
                            : null,
                        child: Text(lawyer.initials,
                            style: AppTextStyles.cairo(
                                size: 26,
                                weight: FontWeight.w800,
                                color: AppColors.navy)),
                      ),
                    ),
                    if (!lawyer.hasPhoto)
                      Transform.translate(
                        offset: const Offset(0, 10),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neutralBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text('لا تتوفر صورة',
                              style: AppTextStyles.tajawal(
                                  size: 9, color: AppColors.ink2)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(lawyer.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cairo(
                        size: 19, weight: FontWeight.w800, color: Colors.white)),
              ),
              if ((lawyer.nameEn ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(lawyer.nameEn!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tajawal(
                          size: 12, color: const Color(0xFFC9D3E4))),
                ),
              ],
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _pill(_roleLabel, Icons.badge_outlined),
                    if (lawyer.hasRating)
                      _pill('${lawyer.rating.toStringAsFixed(1)} ★ (${lawyer.reviewCount})',
                          Icons.star_outline),
                    if (_isApproved) _pill('معتمد', Icons.verified_outlined),
                    if (lawyer.isEmergencyReady)
                      _pill('نجدة عاجلة', Icons.emergency_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.tajawal(
                  size: 11.5, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  /// Pulls the identity card up over the gradient for a layered, professional
  /// look, and lists the fields that exist versus those the API withholds.
  Widget _identityCard() {
    return Transform.translate(
      offset: const Offset(0, -26),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(Icons.badge_outlined, 'الصفة المهنية', _roleLabel),
            _row(Icons.verified_user_outlined, 'الحالة',
                _isApproved ? 'محامٍ معتمد على المنصة' : lawyer.status),
            if (lawyer.isEmergencyReady)
              _row(Icons.emergency_outlined, 'الخدمات', 'متاح للنجدة القانونية العاجلة'),
          ],
        ),
      ),
    );
  }

  Widget _primaryActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _book(context, methodCode: 'phone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.mic_none_outlined, size: 20),
                label: const Text('استشارة صوتية'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _book(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.event_available_outlined, size: 20),
                label: const Text('حجز موعد'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'اختر نوع الاستشارة والوقت المتاح من شبكة عمل المحامي، ويتم تأكيد الحجز فورًا.',
          textAlign: TextAlign.center,
          style: AppTextStyles.tajawal(size: 11, color: AppColors.ink3, height: 1.5),
        ),
      ],
    );
  }

  /// The professional profile laid out in full. Fields the mobile API does not
  /// publish are shown with an explicit marker rather than omitted, so the
  /// reader can tell a missing backend field from a lawyer who simply has none.
  Widget _professionalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(Icons.work_outline, 'المسمى المهني', _roleLabel),
          _field(Icons.category_outlined, 'التخصصات القانونية',
              lawyer.specialties.isEmpty ? null : lawyer.specialties.join('، ')),
          _field(Icons.timeline_outlined, 'سنوات الخبرة',
              lawyer.experienceYears > 0 ? '${lawyer.experienceYears} سنة' : null),
          _field(Icons.translate_outlined, 'اللغات',
              lawyer.languages.isEmpty ? null : lawyer.languages.join('، ')),
          _field(Icons.schedule_outlined, 'ساعات العمل',
              lawyer.workingHours.trim().isEmpty ? null : lawyer.workingHours),
          _field(Icons.badge_outlined, 'رقم القيد',
              (lawyer.registrationNo ?? '').trim().isEmpty ? null : lawyer.registrationNo),
          _field(Icons.star_border, 'التقييمات',
              lawyer.hasRating
                  ? '${lawyer.rating.toStringAsFixed(1)} من 5 (${lawyer.reviewCount} تقييم)'
                  : null),
        ],
      ),
    );
  }

  /// A professional field that is either filled from the real API or, when the
  /// lawyer has not published it, marked as absent rather than blank.
  Widget _field(IconData icon, String label, String? value) {
    if (value == null || value.trim().isEmpty) return _emptyRow(icon, label);
    return _row(icon, label, value);
  }

  Widget _emptyRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.ink3),
          const SizedBox(width: 10),
          Text('$label: ',
              style: AppTextStyles.tajawal(
                  size: 12.5, weight: FontWeight.w600, color: AppColors.ink2)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neutralBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('غير منشور',
                  style: AppTextStyles.tajawal(size: 10.5, color: AppColors.ink3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(BuildContext context) {
    final hasPhone = (lawyer.phone ?? '').isNotEmpty;
    final hasEmail = (lawyer.email ?? '').isNotEmpty;
    if (!hasPhone && !hasEmail) {
      return _emptyCard('لا توجد بيانات تواصل منشورة لهذا المحامي.');
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          if (hasPhone)
            _contactTile(
              context,
              icon: Icons.call_outlined,
              label: 'الهاتف',
              value: lawyer.phone!,
              actionLabel: 'نسخ',
              onAction: () => _copy(context, 'رقم الهاتف', lawyer.phone!),
            ),
          if (hasEmail)
            _contactTile(
              context,
              icon: Icons.mail_outline,
              label: 'البريد الإلكتروني',
              value: lawyer.email!,
              actionLabel: 'نسخ',
              onAction: () => _copy(context, 'البريد الإلكتروني', lawyer.email!),
            ),
        ],
      ),
    );
  }

  Widget _contactTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.neutralBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.neutralInk),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.tajawal(size: 11, color: AppColors.ink3)),
                const SizedBox(height: 1),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(value,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.tajawal(
                          size: 13.5, weight: FontWeight.w600, color: AppColors.ink)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel,
                style: AppTextStyles.tajawal(size: 12, color: AppColors.brandRed)),
          ),
        ],
      ),
    );
  }

  Widget _servicesCard(BuildContext context) {
    // The three bookable consultation types map to real catalogue codes; each
    // row opens the booking flow already on that type. Emergency dispatch has no
    // client route on this deployment, so it stays informational.
    final services = <({String label, IconData icon, String? methodCode, bool bookable})>[
      (label: 'استشارة صوتية', icon: Icons.mic_none_outlined, methodCode: 'phone', bookable: true),
      (label: 'استشارة مرئية', icon: Icons.videocam_outlined, methodCode: 'video', bookable: true),
      (label: 'استشارة عبر واتساب', icon: Icons.chat_outlined, methodCode: 'whatsapp', bookable: true),
      (label: 'زيارة المكتب', icon: Icons.location_on_outlined, methodCode: 'office', bookable: true),
      if (lawyer.isEmergencyReady)
        (label: 'نجدة قانونية عاجلة', icon: Icons.emergency_outlined, methodCode: null, bookable: false),
    ];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          for (final s in services)
            InkWell(
              onTap: s.bookable ? () => _book(context, methodCode: s.methodCode) : null,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.neutralBg,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(s.icon, size: 18, color: AppColors.neutralInk),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s.label,
                          style: AppTextStyles.tajawal(
                              size: 13.5, weight: FontWeight.w600)),
                    ),
                    if (s.bookable)
                      const Icon(Icons.chevron_left, size: 20, color: AppColors.ink3)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.neutralBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('قريبًا',
                            style: AppTextStyles.tajawal(size: 10, color: AppColors.ink2)),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _profileDataNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutralBg,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, size: 18, color: AppColors.ink2),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'يعرض هذا الملف البيانات المنشورة للمحامي على المنصة. '
              'الحقول المعلّمة بـ «غير منشور» لم يملأها المحامي بعد؛ أما النبذة والمؤهلات والمدينة فغير متاحة في واجهة الـ API الحالية.',
              style: TextStyle(fontSize: 11.5, color: AppColors.ink2, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 2),
        child: Text(title,
            style: AppTextStyles.cairo(
                size: 14, weight: FontWeight.w800, color: AppColors.navy)),
      );

  Widget _emptyCard(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Text(message,
            textAlign: TextAlign.center,
            style: AppTextStyles.tajawal(size: 12.5, color: AppColors.ink2)),
      );

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.brandBlue),
          const SizedBox(width: 10),
          Text('$label: ',
              style: AppTextStyles.tajawal(
                  size: 12.5, weight: FontWeight.w600, color: AppColors.ink2)),
          Expanded(
            child: Text(value,
                style: AppTextStyles.tajawal(size: 12.5, color: AppColors.navy)),
          ),
        ],
      ),
    );
  }

}
