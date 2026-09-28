import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/lawyer_row.dart';
import '../widgets/section_title.dart';
import 'lawyer_profile_screen.dart';

/// The public directory of approved lawyers, backed by `GET /api/mobile/lawyers`.
///
/// Search is client-side over the directory response: the endpoint returns the
/// full country list in one call and has no server-side query parameter.
class LawyersDirectoryScreen extends StatefulWidget {
  const LawyersDirectoryScreen({super.key});

  @override
  State<LawyersDirectoryScreen> createState() => _LawyersDirectoryScreenState();
}

class _LawyersDirectoryScreenState extends State<LawyersDirectoryScreen> {
  String _query = '';
  Timer? _debounce;
  late Future<List<Lawyer>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final appState = context.read<AppState>();
    setState(() {
      _future = appState.lawyers.directory();
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<Lawyer> _filter(List<Lawyer> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            (l.nameEn ?? '').toLowerCase().contains(q))
        .toList();
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
                hintText: 'ابحث بالاسم...',
                prefixIcon: Icon(Icons.search, size: 20),
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.ink3),
                            const SizedBox(height: 12),
                            Text('تعذّر تحميل النتائج',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.tajawal(color: AppColors.ink2)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                                onPressed: _reload, child: const Text('إعادة المحاولة')),
                          ],
                        ),
                      ),
                    );
                  }
                  final list = _filter(snap.data ?? const <Lawyer>[]);
                  if (list.isEmpty) {
                    return Center(
                      child: Text('لا يوجد محامون مطابقون',
                          style: AppTextStyles.tajawal(color: AppColors.ink2)),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) => LawyerRow(
                      lawyer: list[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LawyerProfileScreen(lawyer: list[i])),
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
