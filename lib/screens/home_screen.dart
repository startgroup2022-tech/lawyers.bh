import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/lawyer_row.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';
import '../widgets/state_views.dart';
import 'lawyer_profile_screen.dart';

/// The client home.
///
/// Order, per the platform brief: welcome header → banner → **main sections** →
/// featured lawyers. The banner is kept short so the sections stay above the
/// fold.
///
/// Every section maps to a real destination. A capability the mobile API does
/// not expose (voice consultation, appointments, emergency dispatch, payments)
/// is shown as "قريبًا" and explains the gap when tapped rather than opening a
/// fabricated screen or inventing data.
class HomeScreen extends StatefulWidget {
  final VoidCallback onBrowseAll;
  const HomeScreen({super.key, required this.onBrowseAll});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Lawyer>> _lawyersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final future = context.read<AppState>().lawyers.directory();
    // The FutureBuilder below renders the failure, but a second listener is
    // attached so the error is also marked handled. Without it the rejected
    // future can surface as an unhandled async error while the screen is on a
    // frame that has not yet rebuilt.
    future.then<void>((_) {}, onError: (_) {});
    _lawyersFuture = future;
  }

  Future<void> _reload() async {
    setState(_load);
    await _lawyersFuture.catchError((_) => <Lawyer>[]);
  }

  void _openProfile(Lawyer lawyer) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LawyerProfileScreen(lawyer: lawyer)));
  }

  /// A section the app cannot open yet. It says so plainly instead of routing
  /// nowhere.
  void _unavailable(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('«$feature» غير متاح في التطبيق حاليًا.')),
      );
  }

  List<HomeSection> _sections() {
    final professional = context.read<AppState>().isProfessional;
    return [
      HomeSection(
        label: 'المحامون',
        icon: Icons.gavel_outlined,
        tint: AppColors.brandRed,
        onTap: widget.onBrowseAll,
      ),
      HomeSection(
        label: 'الاستشارات القانونية',
        icon: Icons.chat_bubble_outline,
        tint: AppColors.brandBlue,
        onTap: widget.onBrowseAll,
      ),
      HomeSection(
        label: 'الاستشارة الصوتية',
        icon: Icons.mic_none_outlined,
        tint: AppColors.brandBlue,
        available: false,
        onTap: () => _unavailable('الاستشارة الصوتية'),
      ),
      HomeSection(
        label: 'حجز موعد',
        icon: Icons.event_available_outlined,
        tint: AppColors.brandBlue,
        available: false,
        onTap: () => _unavailable('حجز موعد'),
      ),
      HomeSection(
        label: 'الخدمات القانونية',
        icon: Icons.assignment_outlined,
        tint: AppColors.brandBlue,
        onTap: widget.onBrowseAll,
      ),
      HomeSection(
        label: 'النجدة العاجلة',
        icon: Icons.emergency_outlined,
        tint: AppColors.brandRed,
        available: false,
        onTap: () => _unavailable('النجدة العاجلة'),
      ),
      if (professional)
        HomeSection(
          label: 'لوحة المحامي',
          icon: Icons.workspace_premium_outlined,
          tint: AppColors.brandRed,
          onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _welcomeHeader(),
            const SizedBox(height: 16),
            PromoBanner(
              slides: [
                BannerSlide(
                  title: 'منصّتك القانونية الموثوقة',
                  subtitle: 'محامون معتمدون في مملكة البحرين، بخبرات موثّقة.',
                  icon: Icons.verified_outlined,
                  colors: const [AppColors.brandRedDark, AppColors.brandRed],
                  actionLabel: 'ابحث عن محامٍ',
                  onAction: widget.onBrowseAll,
                ),
                BannerSlide(
                  title: 'تصفّح حسب التخصص',
                  subtitle: 'اعرف المحامي المناسب لقضيتك قبل التواصل.',
                  icon: Icons.search_outlined,
                  colors: const [AppColors.brandDark, AppColors.navyLight],
                  actionLabel: 'استعرض الدليل',
                  onAction: widget.onBrowseAll,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Main sections, directly under the banner.
            const SectionTitle(title: 'الأقسام الرئيسية'),
            SectionGrid(sections: _sections()),
            const SizedBox(height: 22),
            SectionTitle(
              title: 'محامون موصى بهم',
              actionLabel: 'عرض الكل',
              onAction: widget.onBrowseAll,
            ),
            FutureBuilder<List<Lawyer>>(
              future: _lawyersFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const LawyerListSkeleton(count: 3);
                }
                if (snap.hasError) {
                  return ErrorState(
                    message: 'تعذّر تحميل المحامين حاليًا',
                    onRetry: _reload,
                  );
                }
                final list = (snap.data ?? const <Lawyer>[]).take(3).toList();
                if (list.isEmpty) {
                  return EmptyState(
                    message: 'لا يوجد محامون منشورون بعد',
                    icon: Icons.person_search_outlined,
                    actionLabel: 'تصفّح الدليل',
                    onAction: widget.onBrowseAll,
                  );
                }
                return Column(
                  children: list
                      .map((l) => LawyerRow(lawyer: l, onTap: () => _openProfile(l)))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.navy, Color(0xFF132644), AppColors.brandRed],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLogo(height: 24, onDark: true),
          const SizedBox(height: 12),
          Text('منصّتك القانونية الموثوقة',
              style: AppTextStyles.cairo(
                  size: 17, weight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            'ابحث عن محامٍ معتمد في مملكة البحرين، وتعرّف على خدماتهم قبل التواصل.',
            style: AppTextStyles.tajawal(
                size: 12, color: const Color(0xFFC9D3E4), height: 1.6),
          ),
        ],
      ),
    );
  }
}
