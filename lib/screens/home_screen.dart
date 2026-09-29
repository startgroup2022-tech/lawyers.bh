import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lawyer.dart';
import '../models/user.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/lawyer_row.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';
import '../widgets/state_views.dart';
import 'lawyer_profile_screen.dart';

/// The client home.
///
/// Order, per the platform brief: branded header → **one** animated slider →
/// main categories → services → featured lawyers.
///
/// The header carries the official platform wordmark (the same asset the slider
/// and the splash use), not a separate circular mark.
///
/// Sections are **navigation/categories** — the persistent structure of the app
/// (lawyers, specialisations, consultations, contracts). Bookable offerings
/// (voice consultation, video consultation, appointments, emergency dispatch)
/// are **services**, shown in their own strip below the categories, never mixed
/// into the category grid. A capability with no mobile endpoint is tagged
/// "قريبًا" and explains the gap when tapped rather than opening a fabricated
/// screen.
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

  /// A capability the app cannot open yet. It says so plainly instead of routing
  /// nowhere.
  void _unavailable(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('«$feature» غير متاح في التطبيق حاليًا.')),
      );
  }

  /// Navigation categories — the app's real structure. Only destinations that
  /// exist are listed; nothing is invented to fill the grid.
  List<HomeSection> _categories() {
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
        label: 'الخدمات القانونية',
        icon: Icons.assignment_outlined,
        tint: AppColors.brandBlue,
        onTap: widget.onBrowseAll,
      ),
      HomeSection(
        label: 'التعاقد والدفع',
        icon: Icons.description_outlined,
        tint: AppColors.brandBlue,
        onTap: widget.onBrowseAll,
      ),
    ];
  }

  /// Services/actions — bookable offerings, kept out of the category grid.
  List<ServiceItem> _services() {
    return [
      ServiceItem(
        label: 'استشارة صوتية',
        icon: Icons.mic_none_outlined,
        available: false,
        onTap: () => _unavailable('الاستشارة الصوتية'),
      ),
      ServiceItem(
        label: 'استشارة مرئية',
        icon: Icons.videocam_outlined,
        available: false,
        onTap: () => _unavailable('الاستشارة المرئية'),
      ),
      ServiceItem(
        label: 'حجز موعد',
        icon: Icons.event_available_outlined,
        available: false,
        onTap: () => _unavailable('حجز موعد'),
      ),
      ServiceItem(
        label: 'النجدة العاجلة',
        icon: Icons.emergency_outlined,
        available: false,
        onTap: () => _unavailable('النجدة العاجلة'),
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _header(),
            const SizedBox(height: 14),
            // One animated carousel only — two slides inside it, no second
            // static banner.
            PromoBanner(
              slides: [
                BannerSlide(
                  title: 'منصّتك القانونية الموثوقة',
                  subtitle: 'محامون معتمدون في مملكة البحرين.',
                  icon: Icons.verified_outlined,
                  colors: const [AppColors.brandRedDark, AppColors.brandRed],
                  actionLabel: 'ابحث عن محامٍ',
                  onAction: widget.onBrowseAll,
                  showWordmark: true,
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
            const SizedBox(height: 18),
            // Main categories, directly under the slider.
            const SectionTitle(title: 'الأقسام الرئيسية'),
            SectionGrid(sections: _categories()),
            const SizedBox(height: 18),
            // Services live apart from the categories.
            const SectionTitle(title: 'الخدمات'),
            ServicesStrip(services: _services()),
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

  /// A welcome header. The platform wordmark itself lives in the app bar above
  /// (the real header), so this does not repeat it.
  Widget _header() {
    final user = context.select<AppState, AppUser?>((s) => s.currentUser);
    final name = user?.displayName.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name.isEmpty ? 'أهلًا بك' : 'أهلًا $name',
            style: AppTextStyles.cairo(size: 17, weight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text('ابحث عن محامٍ معتمد وابدأ استشارتك.',
            style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
      ],
    );
  }
}
