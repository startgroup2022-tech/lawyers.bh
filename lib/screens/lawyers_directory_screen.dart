import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/lawyer_row.dart';
import '../widgets/section_title.dart';
import 'lawyer_profile_screen.dart';

class LawyersDirectoryScreen extends StatefulWidget {
  const LawyersDirectoryScreen({super.key});

  @override
  State<LawyersDirectoryScreen> createState() => _LawyersDirectoryScreenState();
}

class _LawyersDirectoryScreenState extends State<LawyersDirectoryScreen> {
  List<LegalCategory> _categories = [];
  int? _selectedCategoryId;
  String _query = '';
  Timer? _debounce;
  late Future<List<Lawyer>> _future;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    appState.lawyers.categories().then((c) => setState(() => _categories = c));
    _future = appState.lawyers.search();
  }

  void _reload() {
    final appState = context.read<AppState>();
    setState(() {
      _future = appState.lawyers.search(categoryId: _selectedCategoryId, query: _query);
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _query = value;
      _reload();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(title: 'دليل المحامين'),
            TextField(
              onChanged: _onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'ابحث بالاسم أو التخصص أو المدينة...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'الكل',
                    selected: _selectedCategoryId == null,
                    onTap: () {
                      setState(() => _selectedCategoryId = null);
                      _reload();
                    },
                  ),
                  ..._categories.map((c) => _CategoryChip(
                        label: c.nameAr,
                        selected: _selectedCategoryId == c.id,
                        onTap: () {
                          setState(() => _selectedCategoryId = c.id);
                          _reload();
                        },
                      )),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<Lawyer>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text('تعذّر تحميل النتائج', style: AppTextStyles.tajawal(color: AppColors.ink2)),
                    );
                  }
                  final list = snap.data!;
                  if (list.isEmpty) {
                    return Center(
                      child: Text('لا يوجد محامون مطابقون', style: AppTextStyles.tajawal(color: AppColors.ink2)),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) => LawyerRow(
                      lawyer: list[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LawyerProfileScreen(lawyerId: list[i].id)),
                      ),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : Colors.white,
            border: Border.all(color: selected ? AppColors.navy : AppColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.tajawal(
              size: 12,
              weight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? Colors.white : AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}
