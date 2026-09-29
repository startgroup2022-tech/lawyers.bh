import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';
import 'lawyer_profile_screen.dart';

/// The professional network: browse peers from the public directory.
///
/// Reuses `GET /api/mobile/lawyers` in the professional palette. Filtering is
/// client-side because the endpoint returns the whole country list and has no
/// server-side category or query parameters.
class LawyerNetworkScreen extends StatefulWidget {
  const LawyerNetworkScreen({super.key});

  @override
  State<LawyerNetworkScreen> createState() => _LawyerNetworkScreenState();
}

class _LawyerNetworkScreenState extends State<LawyerNetworkScreen> {
  String _query = '';
  Timer? _debounce;
  List<Lawyer> _all = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
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
      final list = await context.read<AppState>().lawyers.directory();
      if (mounted) setState(() => _all = list);
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
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  List<Lawyer> get _filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            (l.nameEn ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                    subtitle: 'زملاء المحاماة المسجّلون في المنصة',
                  ),
                  TextField(
                    onChanged: _onQuery,
                    style: AppTextStyles.tajawal(size: 13),
                    decoration: const InputDecoration(
                      hintText: 'ابحث بالاسم…',
                      prefixIcon: Icon(Icons.search, size: 20),
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
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Text('لا يوجد محامون مطابقون',
            style: AppTextStyles.tajawal(size: 13, color: LawyerColors.ink2)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final l = list[i];
          return InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LawyerProfileScreen(lawyer: l)),
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
                        Text(l.nameEn ?? '',
                            style: AppTextStyles.tajawal(size: 11, color: LawyerColors.ink2)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            if (l.subscriptionType != null)
                              ProBadge(label: l.subscriptionType!, tone: LawyerColors.base2),
                            if (l.isEmergencyReady)
                              const ProBadge(label: 'نجدة عاجلة', tone: LawyerColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: LawyerColors.ink3, size: 19),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
