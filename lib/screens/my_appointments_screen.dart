import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/section_title.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

/// The signed-in client's appointments, from `GET /api/mobile/client-appointments`.
///
/// Upcoming and past are separated locally from the backend's own ordering; the
/// status shown is the backend's, and cancel is offered only when the backend
/// would accept it (a completed or already-cancelled booking is refused).
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late Future<List<ClientAppointment>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = context.read<AppState>().appointments.list();
    });
  }

  Future<void> _cancel(ClientAppointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إلغاء الموعد',
            style: AppTextStyles.cairo(size: 15, weight: FontWeight.w800)),
        content: Text(
            'هل تريد إلغاء موعدك مع ${appointment.lawyerName} بتاريخ ${appointment.date}؟',
            style: AppTextStyles.tajawal(size: 12.5, height: 1.7)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('تراجع')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد الإلغاء')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final service = context.read<AppState>().appointments;
    try {
      await service.cancel(appointment.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم إلغاء الموعد')));
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.error == 'not_allowed'
            ? 'لا يمكن إلغاء هذا الموعد'
            : (e.message ?? 'تعذّر إلغاء الموعد')),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذّر إلغاء الموعد')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مواعيدي')),
      body: SafeArea(
        child: FutureBuilder<List<ClientAppointment>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingState(label: 'جارٍ تحميل مواعيدك…'),
              );
            }
            if (snap.hasError) {
              return Center(
                child: ErrorState(message: 'تعذّر تحميل المواعيد', onRetry: _reload),
              );
            }
            final all = snap.data ?? const <ClientAppointment>[];
            if (all.isEmpty) {
              return const Center(
                child: EmptyState(
                  message: 'لا توجد مواعيد محجوزة بعد',
                  icon: Icons.event_note_outlined,
                ),
              );
            }

            final today = DateUtils.dateOnly(DateTime.now());
            bool isPast(ClientAppointment a) {
              final parsed = DateTime.tryParse(a.date);
              if (parsed == null) return false;
              return DateUtils.dateOnly(parsed).isBefore(today);
            }

            final upcoming = all.where((a) => !isPast(a)).toList(growable: false);
            final past = all.where(isPast).toList(growable: false);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  const SectionTitle(title: 'القادمة'),
                  ...upcoming.map((a) => _card(a)),
                  const SizedBox(height: 8),
                ],
                if (past.isNotEmpty) ...[
                  const SectionTitle(title: 'السابقة'),
                  ...past.map((a) => _card(a)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(ClientAppointment a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(a.lawyerName,
                    style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
              ),
              _statusBadge(a),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 14, color: AppColors.ink3),
              const SizedBox(width: 6),
              Text('${a.date} · ${a.timeRange}',
                  style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
            ],
          ),
          if (a.service.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.gavel_outlined, size: 14, color: AppColors.ink3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(a.service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.tajawal(size: 12, color: AppColors.ink2)),
                ),
              ],
            ),
          ],
          if (a.canCancel) ...[
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton.icon(
                onPressed: () => _cancel(a),
                icon: const Icon(Icons.close, size: 16),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: Color(0xFFE7C7C7)),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                label: const Text('إلغاء الموعد'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(ClientAppointment a) {
    if (a.isCancelled) return const StatusBadge(label: 'ملغى', tone: BadgeTone.red);
    if (a.isCompleted) return const StatusBadge(label: 'مكتمل', tone: BadgeTone.neutral);
    if (a.status == 'confirmed') {
      return const StatusBadge(label: 'مؤكّد', tone: BadgeTone.green);
    }
    return const StatusBadge(label: 'محجوز', tone: BadgeTone.green);
  }
}
