import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/case_timeline.dart';

class CaseTrackingScreen extends StatefulWidget {
  final int caseId;
  const CaseTrackingScreen({super.key, required this.caseId});

  @override
  State<CaseTrackingScreen> createState() => _CaseTrackingScreenState();
}

class _CaseTrackingScreenState extends State<CaseTrackingScreen> {
  late Future<LegalCase> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AppState>().cases.caseDetail(widget.caseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة متابعة القضية')),
      body: FutureBuilder<LegalCase>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final c = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title, style: AppTextStyles.cairo(size: 15, weight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('المحامي المسؤول: ${c.lawyerName}',
                        style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('الجدول الزمني', style: AppTextStyles.cairo(size: 14, weight: FontWeight.w800, color: AppColors.navy)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: CaseTimelineWidget(steps: c.timeline),
              ),
              if (c.documents.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text('المستندات', style: AppTextStyles.cairo(size: 14, weight: FontWeight.w800, color: AppColors.navy)),
                const SizedBox(height: 10),
                ...c.documents.map(
                  (d) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, size: 18, color: AppColors.navyLight),
                        const SizedBox(width: 10),
                        Expanded(child: Text(d.title, style: AppTextStyles.tajawal(size: 12.5))),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
