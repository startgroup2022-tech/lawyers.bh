import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'case_tracking_screen.dart';

class MyCasesScreen extends StatefulWidget {
  final VoidCallback onBrowseAll;
  const MyCasesScreen({super.key, required this.onBrowseAll});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  late Future<List<LegalCase>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<AppState>().cases.myCases();

  Future<void> _reload() async {
    setState(_load);
    await _future.catchError((_) => <LegalCase>[]);
  }

  (String, BadgeTone) _statusInfo(String status) {
    switch (status) {
      case 'active':
        return ('نشطة', BadgeTone.green);
      case 'closed':
        return ('مغلقة', BadgeTone.neutral);
      case 'awaiting_signature':
        return ('بانتظار التوقيع', BadgeTone.amber);
      default:
        return ('قيد المطابقة', BadgeTone.neutral);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(title: 'لوحة متابعة القضية'),
            Expanded(
              child: FutureBuilder<List<LegalCase>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return _ErrorRetry(onRetry: _reload);
                  }
                  final list = snap.data ?? const <LegalCase>[];
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.folder_open_outlined, size: 40, color: AppColors.ink3),
                          const SizedBox(height: 10),
                          Text('لا توجد قضايا حاليًا', style: AppTextStyles.tajawal(size: 13, color: AppColors.ink2)),
                          const SizedBox(height: 10),
                          ElevatedButton(onPressed: widget.onBrowseAll, child: const Text('ابحث عن محامٍ')),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      final (label, tone) = _statusInfo(c.status);
                      return InkWell(
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => CaseTrackingScreen(caseId: c.id))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.title, style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text('المحامي المسؤول: ${c.lawyerName}',
                                        style: AppTextStyles.tajawal(size: 11, color: AppColors.ink2)),
                                  ],
                                ),
                              ),
                              StatusBadge(label: label, tone: tone),
                            ],
                          ),
                        ),
                      );
                    },
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

/// Shared "the API call failed" state with a retry action.
class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.ink3),
            const SizedBox(height: 10),
            Text('تعذّر تحميل البيانات من الخادم',
                style: AppTextStyles.tajawal(size: 13, color: AppColors.ink2)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
}
