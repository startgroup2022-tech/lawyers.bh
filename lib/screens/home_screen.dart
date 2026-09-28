import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/category_tile.dart';
import '../widgets/lawyer_row.dart';
import '../widgets/section_title.dart';
import 'lawyer_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onBrowseAll;
  const HomeScreen({super.key, required this.onBrowseAll});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<LegalCategory>> _categoriesFuture;
  late Future<List<Lawyer>> _lawyersFuture;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _categoriesFuture = appState.lawyers.categories();
    _lawyersFuture = appState.lawyers.search(sort: 'rating');
  }

  void _openProfile(Lawyer lawyer) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LawyerProfileScreen(lawyerId: lawyer.id)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                const BrandLogo(height: 26, onDark: true),
                const SizedBox(height: 12),
                Text('تسجيل سريع ونجدة قانونية',
                    style: AppTextStyles.cairo(size: 18, weight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  'أنشئ حسابك برقم هاتفك واحصل على تحقق فوري (OTP)، أو اطلب نجدة قانونية عاجلة بضغطة واحدة.',
                  style: AppTextStyles.tajawal(size: 12, color: const Color(0xFFC9D3E4), height: 1.6),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: widget.onBrowseAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.crimson,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('ابحث عن محامٍ'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionTitle(title: 'تصفح حسب التخصص'),
          FutureBuilder<List<LegalCategory>>(
            future: _categoriesFuture,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final cats = snap.data!;
              return GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
                children: cats
                    .map((c) => CategoryTile(category: c, onTap: widget.onBrowseAll))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          SectionTitle(title: 'محامون موصى بهم', actionLabel: 'عرض الكل', onAction: widget.onBrowseAll),
          FutureBuilder<List<Lawyer>>(
            future: _lawyersFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Text('تعذّر تحميل المحامين حاليًا',
                    style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2));
              }
              final list = snap.data!.take(2).toList();
              return Column(children: list.map((l) => LawyerRow(lawyer: l, onTap: () => _openProfile(l))).toList());
            },
          ),
        ],
      ),
    );
  }
}
