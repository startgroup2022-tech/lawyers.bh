import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../services/documents_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';

/// The document vault: everything the lawyer may see, filterable by scope.
class LawyerDocumentsScreen extends StatefulWidget {
  const LawyerDocumentsScreen({super.key});

  @override
  State<LawyerDocumentsScreen> createState() => _LawyerDocumentsScreenState();
}

class _LawyerDocumentsScreenState extends State<LawyerDocumentsScreen> {
  static const _scopes = <(String, String)>[
    ('', 'الكل'),
    ('case', 'القضايا'),
    ('client', 'العملاء'),
    ('contract', 'العقود'),
    ('lawyer', 'مهنية'),
    ('general', 'عامة'),
  ];

  String _scope = '';
  List<CaseDoc> _docs = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final docs = await context.read<AppState>().documents.list(scope: _scope);
      if (mounted) setState(() => _docs = docs);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'تعذّر تحميل المستندات');
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تحميل المستندات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so the global app background shows through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        title: const Text('خزنة المستندات'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: LawyerColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProSectionTitle(title: 'المستندات', subtitle: 'مرتبة حسب آخر تحديث'),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _scopes
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ChoiceChip(
                                  label: Text(s.$2),
                                  selected: _scope == s.$1,
                                  selectedColor: LawyerColors.accentSoft,
                                  onSelected: (_) {
                                    setState(() => _scope = s.$1);
                                    _load();
                                  },
                                ),
                              ))
                          .toList(),
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
    if (_docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_copy_outlined, size: 42, color: LawyerColors.ink3),
            const SizedBox(height: 10),
            Text('لا توجد مستندات',
                style: AppTextStyles.tajawal(size: 13, color: LawyerColors.ink2)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _docs.length,
        itemBuilder: (context, i) {
          final d = _docs[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LawyerColors.surface,
              border: Border.all(color: LawyerColors.line),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: LawyerColors.accentSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(_iconFor(d.scope), size: 18, color: LawyerColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.tajawal(size: 12.5, weight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (d.categoryName != null) d.categoryName!,
                          'إصدار ${d.currentVersion}',
                          if (d.currentSize != null) _size(d.currentSize!),
                        ].join(' · '),
                        style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink3),
                      ),
                    ],
                  ),
                ),
                ProBadge(
                  label: d.visibility == 'internal' ? 'داخلي' : 'مشترك',
                  tone: d.visibility == 'internal' ? LawyerColors.base2 : LawyerColors.emerald,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static IconData _iconFor(String scope) {
    switch (scope) {
      case 'case':
        return Icons.folder_outlined;
      case 'client':
        return Icons.person_outline;
      case 'contract':
        return Icons.description_outlined;
      case 'lawyer':
        return Icons.badge_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  static String _size(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} م.ب';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} ك.ب';
    return '$bytes بايت';
  }
}
