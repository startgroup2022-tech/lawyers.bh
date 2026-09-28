import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contract.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';
import 'contract_payment_screen.dart';

class MyContractsScreen extends StatefulWidget {
  final VoidCallback onBrowseAll;
  const MyContractsScreen({super.key, required this.onBrowseAll});

  @override
  State<MyContractsScreen> createState() => _MyContractsScreenState();
}

class _MyContractsScreenState extends State<MyContractsScreen> {
  late Future<List<LegalContract>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<AppState>().cases.myContracts();

  Future<void> _reload() async {
    setState(_load);
    await _future.catchError((_) => <LegalContract>[]);
  }

  (String, BadgeTone) _statusInfo(String status) {
    switch (status) {
      case 'signed':
        return ('موقّع', BadgeTone.green);
      case 'awaiting_signature':
        return ('بانتظار التوقيع', BadgeTone.amber);
      case 'cancelled':
        return ('ملغى', BadgeTone.red);
      default:
        return ('مسودة', BadgeTone.neutral);
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
            const SectionTitle(title: 'التعاقد الآمن والدفع'),
            Expanded(
              child: FutureBuilder<List<LegalContract>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) return _ContractsErrorRetry(onRetry: _reload);
                  final list = snap.data ?? const <LegalContract>[];
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.description_outlined, size: 40, color: AppColors.ink3),
                          const SizedBox(height: 10),
                          Text('لا يوجد عقود حاليًا', style: AppTextStyles.tajawal(size: 13, color: AppColors.ink2)),
                          const SizedBox(height: 10),
                          ElevatedButton(onPressed: widget.onBrowseAll, child: const Text('ابحث عن محامٍ')),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      final (label, tone) = _statusInfo(c.status);
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ContractPaymentScreen(contractId: c.id, caseId: c.caseId),
                          ),
                        ),
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
                                    Text('المحامي: ${c.lawyerName} · ${c.feeAmount.toStringAsFixed(0)} د.ب',
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

class _ContractsErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _ContractsErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.ink3),
            const SizedBox(height: 10),
            Text('تعذّر تحميل العقود من الخادم',
                style: AppTextStyles.tajawal(size: 13, color: AppColors.ink2)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
}
