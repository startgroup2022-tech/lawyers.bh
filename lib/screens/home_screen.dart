import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lawyer.dart';
import '../models/user.dart';
import '../providers/app_state.dart';
import '../services/auth_gate.dart';
import '../theme/app_theme.dart';
import '../widgets/lawyer_row.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';
import '../widgets/state_views.dart';
import 'booking_screen.dart';
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
/// (voice consultation, video consultation, appointments) are **services**, shown
/// in their own strip below the categories, never mixed into the category grid.
/// A service opens the real booking flow; a capability with no mobile endpoint
/// (emergency dispatch) is tagged "قريبًا" and explains the gap when tapped
/// rather than opening a fabricated screen.
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

  /// Opens the real booking flow. A guest is asked to sign in first because the
  /// booking route is authenticated; the flow then starts on the method the
  /// shortcut named.
  Future<void> _bookConsultation(String methodCode) async {
    await requireSignIn(context, () async {
      if (!mounted) return;
      await _openBookingFlow(methodCode: methodCode);
    }, feature: 'الاستشارة');
  }

  /// Opens the booking flow from a lawyer row, where signing in is still needed
  /// but the method is chosen inside the flow.
  Future<void> _openBookingFlow({String? methodCode, Lawyer? lawyer}) async {
    if (!mounted) return;
    final selected = lawyer ?? await _pickLawyerForBooking();
    if (selected == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(lawyer: selected, initialMethodCode: methodCode),
      ),
    );
    // A new booking may have been made; refresh nothing here, the directory
    // list is unaffected. The appointments screen reloads on its own.
  }

  /// The booking flow needs a lawyer. When opened from a service shortcut the
  /// client chooses one from the directory-backed list, so the shortcut is a
  /// real path rather than a dead end.
  Future<Lawyer?> _pickLawyerForBooking() async {
    return showModalBottomSheet<Lawyer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LawyerPickerSheet(loader: () => context.read<AppState>().lawyers.directory()),
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
  /// The three consultation types open the real booking flow; emergency dispatch
  /// has no client-facing route on this deployment, so it stays honestly marked.
  List<ServiceItem> _services() {
    return [
      ServiceItem(
        label: 'استشارة صوتية',
        icon: Icons.mic_none_outlined,
        available: true,
        onTap: () => _bookConsultation('phone'),
      ),
      ServiceItem(
        label: 'استشارة مرئية',
        icon: Icons.videocam_outlined,
        available: true,
        onTap: () => _bookConsultation('video'),
      ),
      ServiceItem(
        label: 'حجز موعد',
        icon: Icons.event_available_outlined,
        available: true,
        onTap: () => _bookConsultation(''),
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

/// A simple bottom sheet listing lawyers from the real directory so a service
/// shortcut can resolve to a lawyer before entering the booking flow.
class _LawyerPickerSheet extends StatefulWidget {
  final Future<List<Lawyer>> Function() loader;
  const _LawyerPickerSheet({required this.loader});

  @override
  State<_LawyerPickerSheet> createState() => _LawyerPickerSheetState();
}

class _LawyerPickerSheetState extends State<_LawyerPickerSheet> {
  late Future<List<Lawyer>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink3,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SectionTitle(title: 'اختر المحامي'),
            ),
            Expanded(
              child: FutureBuilder<List<Lawyer>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LawyerListSkeleton(count: 3),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: ErrorState(
                        message: 'تعذّر تحميل المحامين',
                        onRetry: () => setState(() => _future = widget.loader()),
                      ),
                    );
                  }
                  final list = snap.data ?? const <Lawyer>[];
                  if (list.isEmpty) {
                    return const Center(
                      child: EmptyState(
                        message: 'لا يوجد محامون منشورون بعد',
                        icon: Icons.person_search_outlined,
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, i) => LawyerRow(
                      lawyer: list[i],
                      onTap: () => Navigator.of(context).pop(list[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
