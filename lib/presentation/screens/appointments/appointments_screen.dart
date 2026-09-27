import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';
import 'package:lawyers_bh/domain/entities/appointment.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.appointments),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'القادمة'),
            Tab(text: 'السابقة'),
            Tab(text: 'الملغية'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList(AppointmentStatus.confirmed),
          _buildAppointmentsList(AppointmentStatus.completed),
          _buildAppointmentsList(AppointmentStatus.cancelled),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(AppointmentStatus status) {
    final l10n = AppLocalizations.of(context);

    // Mock data
    final appointments = _getMockAppointments(status);

    if (appointments.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy,
        title: 'لا توجد مواعيد',
        subtitle: status == AppointmentStatus.confirmed
            ? 'احجز استشارة جديدة لتظهر هنا'
            : 'لا توجد مواعيد ${status == AppointmentStatus.completed ? 'سابقة' : 'ملغية'}',
        action: status == AppointmentStatus.confirmed
            ? AppButton(text: l10n.searchLawyers, onPressed: () => context.go(AppRoutes.search))
            : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(appointment: appointment);
      },
    );
  }

  List<Appointment> _getMockAppointments(AppointmentStatus status) {
    final now = DateTime.now();
    final all = [
      Appointment(
        id: '1',
        clientId: 'user1',
        lawyerId: 'lawyer1',
        lawyerName: 'أحمد الحمادي',
        lawyerSpecialty: 'قانون تجاري',
        scheduledAt: now.add(const Duration(days: 2)),
        durationMinutes: 30,
        type: ConsultationType.video,
        status: AppointmentStatus.confirmed,
        meetingLink: 'https://meet.example.com/123',
        fee: 250,
        currency: 'د.ب',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Appointment(
        id: '2',
        clientId: 'user1',
        lawyerId: 'lawyer2',
        lawyerName: 'منى السيد',
        lawyerSpecialty: 'أحوال شخصية',
        scheduledAt: now.add(const Duration(days: 5)),
        durationMinutes: 45,
        type: ConsultationType.inPerson,
        status: AppointmentStatus.confirmed,
        location: 'مكتب المحامية، المنامة',
        fee: 120,
        currency: 'د.ب',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Appointment(
        id: '3',
        clientId: 'user1',
        lawyerId: 'lawyer3',
        lawyerName: 'خالد مراد',
        lawyerSpecialty: 'قضايا جنائية',
        scheduledAt: now.subtract(const Duration(days: 10)),
        durationMinutes: 60,
        type: ConsultationType.voice,
        status: AppointmentStatus.completed,
        fee: 300,
        currency: 'د.ب',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Appointment(
        id: '4',
        clientId: 'user1',
        lawyerId: 'lawyer1',
        lawyerName: 'أحمد الحمادي',
        lawyerSpecialty: 'قانون تجاري',
        scheduledAt: now.subtract(const Duration(days: 20)),
        durationMinutes: 30,
        type: ConsultationType.video,
        status: AppointmentStatus.cancelled,
        cancellationReason: 'تعارض في المواعيد',
        fee: 250,
        currency: 'د.ب',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
    ];
    return all.where((a) => a.status == status).toList();
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.goldBg,
                child: Text(
                  appointment.lawyerName.split(' ').map((w) => w[0]).take(2).join().toUpperCase(),
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.navy),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.lawyerName, style: AppTextStyles.titleMedium),
                    Text(appointment.lawyerSpecialty, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              _StatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.ink3),
              const SizedBox(width: 8),
              Text(appointment.formattedDateTime, style: AppTextStyles.bodyMedium),
              const SizedBox(width: 16),
              Icon(_getTypeIcon(appointment.type), size: 16, color: AppColors.ink3),
              const SizedBox(width: 8),
              Text(_getTypeLabel(l10n, appointment.type), style: AppTextStyles.bodyMedium),
            ],
          ),
          if (appointment.meetingLink != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.link, size: 16, color: AppColors.ink3),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'رابط الاجتماع متاح',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy),
                  ),
                ),
                AppButton(
                  text: 'انضمام',
                  onPressed: () {},
                  fullWidth: false,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ],
          if (appointment.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.ink3),
                const SizedBox(width: 8),
                Expanded(child: Text(appointment.location!, style: AppTextStyles.bodyMedium)),
              ],
            ),
          ],
          if (appointment.cancellationReason != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.cancel, size: 16, color: AppColors.red),
                const SizedBox(width: 8),
                Expanded(child: Text('السبب: ${appointment.cancellationReason}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.red))),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appointment.formattedFee, style: AppTextStyles.labelMedium.copyWith(color: AppColors.navy)),
              if (appointment.canCancel)
                AppButton(
                  text: 'إلغاء',
                  onPressed: () {},
                  fullWidth: false,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redBg,
                    foregroundColor: AppColors.red,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ConsultationType type) {
    switch (type) {
      case ConsultationType.video:
        return Icons.videocam;
      case ConsultationType.voice:
        return Icons.call;
      case ConsultationType.inPerson:
        return Icons.meeting_room;
    }
  }

  String _getTypeLabel(AppLocalizations l10n, ConsultationType type) {
    switch (type) {
      case ConsultationType.video:
        return l10n.videoCall;
      case ConsultationType.voice:
        return l10n.voiceCall;
      case ConsultationType.inPerson:
        return l10n.inPerson;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case AppointmentStatus.confirmed:
        color = AppColors.green;
        label = 'مؤكد';
        break;
      case AppointmentStatus.completed:
        color = AppColors.navy;
        label = 'مكتمل';
        break;
      case AppointmentStatus.cancelled:
        color = AppColors.red;
        label = 'ملغي';
        break;
      case AppointmentStatus.requested:
        color = AppColors.amber;
        label = 'بانتظار التأكيد';
        break;
      case AppointmentStatus.rescheduled:
        color = AppColors.gold;
        label = 'معاد جدولته';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}