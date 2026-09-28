import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../models/contract.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../services/payments_service.dart';
import '../theme/app_theme.dart';
import 'case_tracking_screen.dart';

class ContractPaymentScreen extends StatefulWidget {
  final int contractId;
  final int? caseId;
  const ContractPaymentScreen({super.key, required this.contractId, this.caseId});

  @override
  State<ContractPaymentScreen> createState() => _ContractPaymentScreenState();
}

class _ContractPaymentScreenState extends State<ContractPaymentScreen> {
  late Future<LegalContract> _future;
  final SignatureController _sigCtrl = SignatureController(penStrokeWidth: 2.4, penColor: AppColors.brandDark);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<AppState>().cases.contractDetail(widget.contractId);
  }

  @override
  void dispose() {
    _sigCtrl.dispose();
    super.dispose();
  }

  Future<void> _sign() async {
    if (_sigCtrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء التوقيع أولًا')));
      return;
    }
    setState(() => _busy = true);
    try {
      // Resolve the service before the first await: after it, the widget may
      // have been disposed and touching `context` would be unsafe.
      final cases = context.read<AppState>().cases;
      final bytes = await _sigCtrl.toPngBytes();
      final base64Sig = bytes != null ? base64Encode(bytes) : '';
      await cases.signContract(widget.contractId, base64Sig);
      if (mounted) setState(_reload);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر حفظ التوقيع')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay(String method) async {
    setState(() => _busy = true);
    try {
      final appState = context.read<AppState>();

      // 1. Create the payment intent for the signed contract.
      final payment = await appState.payments.create(
        contractId: widget.contractId,
        method: method,
        idempotencyKey: 'contract-${widget.contractId}-$method',
      );

      // 2. Ask the backend for the parameters the gateway SDK needs.
      final initiation = await appState.payments.initiate(payment.id);

      // 3. Present the gateway's own payment sheet (Tap Payments).
      //
      // This is the one step that needs the gateway SDK and its public key,
      // neither of which is configured yet. Until they are, we stop here
      // rather than inventing a reference: confirming a made-up reference
      // would either be rejected by the server or, worse, mark a payment as
      // paid without money moving.
      final reference = await _presentGatewaySheet(initiation);
      if (reference == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بوابة الدفع غير مهيأة بعد. تم إنشاء طلب الدفع وسيُستكمل بعد ربط Tap Payments.')),
        );
        setState(_reload);
        return;
      }

      // 4. Hand the gateway's reference back for server-side verification.
      //    The server asks the gateway what really happened; only then does
      //    the payment become paid.
      final confirmed = await appState.payments.confirm(payment.id, gatewayReference: reference);

      if (!mounted) return;
      if (!confirmed.isPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم تأكيد الدفع (الحالة: ${confirmed.status})')),
        );
        setState(_reload);
        return;
      }

      if (widget.caseId != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CaseTrackingScreen(caseId: widget.caseId!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الدفع بنجاح، الأموال محفوظة بحساب الضمان')),
        );
        setState(_reload);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      // A missing gateway configuration is a setup problem, not a failed
      // payment, so it gets its own message.
      final message = e.error == 'gateway_not_configured'
          ? 'بوابة الدفع غير مهيأة على الخادم بعد. يرجى المحاولة لاحقًا.'
          : 'تعذّر إتمام الدفع';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر إتمام الدفع')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Opens the Tap Payments sheet and returns the charge reference.
  ///
  /// Returns null while the gateway SDK is not wired up. To finish this,
  /// add the Tap SDK and its public key, then return the `tap_id` the SDK
  /// produces. The server verifies that reference against Tap before the
  /// payment is considered paid.
  Future<String?> _presentGatewaySheet(PaymentInitiation initiation) async {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التعاقد الآمن والدفع')),
      body: FutureBuilder<LegalContract>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final c = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Text('المحامي: ${c.lawyerName}', style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('قيمة الأتعاب', style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
                          Text('${c.feeAmount.toStringAsFixed(2)} د.ب',
                              style: AppTextStyles.cairo(size: 14, weight: FontWeight.w800, color: AppColors.navy)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (c.status == 'awaiting_signature' || c.status == 'draft') ...[
                  Text('التوقيع الإلكتروني', style: AppTextStyles.cairo(size: 14, weight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 8),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Signature(controller: _sigCtrl, backgroundColor: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(onPressed: () => _sigCtrl.clear(), child: const Text('مسح التوقيع')),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _busy ? null : _sign,
                        child: Text(_busy ? '...' : 'توقيع الكترولي'),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: AppColors.green, size: 18),
                      const SizedBox(width: 6),
                      Text('تم توقيع العقد إلكترونيًا', style: AppTextStyles.tajawal(size: 12.5, color: AppColors.green)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('الدفع الآمن (حساب الضمان)',
                      style: AppTextStyles.cairo(size: 14, weight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 4),
                  Text(
                    'يتم تجميد المبلغ بحساب ضمان محايد، ولا يُصرف للمحامي إلا بعد إنجاز الاتفاق.',
                    style: AppTextStyles.tajawal(size: 11.5, color: AppColors.ink2, height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _busy ? null : () => _pay('benefitpay'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.payGreen),
                    icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                    label: const Text('الدفع عبر BenefitPay'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _busy ? null : () => _pay('applepay'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.payBlack),
                    icon: const Icon(Icons.apple, size: 18),
                    label: const Text('الدفع عبر Apple Pay'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
