import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';
import 'lawyer_profile_screen.dart';

/// The professional network: browse peers by specialization.
///
/// Reuses the public lawyers directory, but presented in the professional
/// palette and framed as colleague discovery rather than consumer matching.
class LawyerNetworkScreen extends StatefulWidget {
  const LawyerNetworkScreen({super.key});

  @override
  State<LawyerNetworkScreen> createState() => _LawyerNetworkScreenState();
}

class _LawyerNetworkScreenState extends State<LawyerNetworkScreen> {
  List<LegalCategory> _categories = const [];
  int? _categoryId;
  String _query = '';
  Timer? _debounce;
  List<Lawyer> _lawyers = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    app.lawyers.categories().then((c) {
      if (mounted) setState(() => _categories = c);
    }).catchError((_) {});
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context
          .read<AppState>()
          .lawyers
          .search(categoryId: _categoryId, query: _query);
      if (mounted) setState(() => _lawyers = list);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'تعذّر تحميل المحامين');
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تحميل المحامين');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _query = v;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawyerColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: LawyerColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ProSectionTitle(
                    title: 'الشبكة المهنية',
                    subtitle: 'زملاء المحاماة حسب التخصص',
                  ),
                  TextField(
                    onChanged: _onQuery,
                    style: AppTextStyles.tajawal(size: 13),
                    decoration: const InputDecoration(
                      hintText: 'ابحث بالاسم أو التخصص أو المدينة…',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _chip('الكل', _categoryId == null, () {
                          setState(() => _categoryId = null);
                          _load();
                        }),
                        ..._categories.map((c) => _chip(c.nameAr, _categoryId == c.id, () {
                              setState(() => _categoryId = c.id);
                              _load();
                            })),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          selectedColor: LawyerColors.accentSoft,
          onSelected: (_) => onTap(),
        ),
      );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 40, color: LawyerColors.ink3),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tajawal(size: 12.5, color: LawyerColors.ink2)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }
    if (_lawyers.isEmpty) {
      return Center(
        child: Text('لا يوجد محامون مطابقون',
            style: AppTextStyles.tajawal(size: 13, color: LawyerColors.ink2)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lawyers.length,
        itemBuilder: (context, i) {
          final l = _lawyers[i];
          return InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LawyerProfileScreen(lawyerId: l.id)),
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LawyerColors.surface,
                border: Border.all(color: LawyerColors.line),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: LawyerColors.base2,
                    child: Text(l.initials,
                        style: AppTextStyles.cairo(
                            size: 14, weight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.name,
                            style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${l.categoryName} · ${l.location}',
                            style: AppTextStyles.tajawal(size: 11, color: LawyerColors.ink2)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            ProBadge(label: '${l.experienceYears} سنة', tone: LawyerColors.base2),
                            if (l.tags.isNotEmpty)
                              ProBadge(label: l.tags.first, tone: LawyerColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.chevron_left, color: LawyerColors.ink3, size: 19),
                      const SizedBox(height: 4),
                      Text('★ ${l.rating.toStringAsFixed(1)}',
                          style: AppTextStyles.cairo(
                              size: 11.5, weight: FontWeight.w700, color: LawyerColors.base)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
