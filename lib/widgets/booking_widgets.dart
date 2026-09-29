import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/consultation_method.dart';
import '../theme/app_theme.dart';
import 'state_views.dart';

/// The paid consultation methods, backed by the platform catalogue
/// (`GET /api/consultation-methods`). Shared by the lawyer profile and the
/// booking flow so both present the same real prices and durations.
Future<List<ConsultationMethod>> loadConsultationMethods(
  Future<List<Map<String, dynamic>>> Function() fetch,
) async {
  final rows = await fetch();
  return rows.map(ConsultationMethod.fromJson).toList(growable: false);
}

/// The next [days] calendar dates starting today, as `YYYY-MM-DD`.
List<DateTime> upcomingDates({int days = 14, DateTime? from}) {
  final today = DateUtils.dateOnly(from ?? DateTime.now());
  return List.generate(days, (i) => today.add(Duration(days: i)));
}

/// `YYYY-MM-DD` for the platform's date parameters.
String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// A compact weekday + day/month label, e.g. `الأحد ٢٨/٩`.
String arabicDateLabel(DateTime date) {
  const weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  // DateTime.weekday: 1 = Monday … 7 = Sunday.
  return '${weekdays[date.weekday - 1]} ${date.day}/${date.month}';
}

/// A horizontally scrollable date picker over the next two weeks.
class DateStrip extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  const DateStrip({
    super.key,
    required this.dates,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final date = dates[i];
          final isSelected = DateUtils.isSameDay(date, selected);
          return InkWell(
            onTap: () => onSelected(date),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              width: 78,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandDark : AppColors.surface,
                border: Border.all(
                    color: isSelected ? AppColors.brandDark : AppColors.line),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    arabicDateLabel(date),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.tajawal(
                      size: 11.5,
                      weight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.ink,
                    ),
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

/// A grid of the backend's free slots for the selected date.
class SlotGrid extends StatelessWidget {
  final List<String> starts;
  final String? selected;
  final ValueChanged<String> onSelected;

  const SlotGrid({
    super.key,
    required this.starts,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (starts.isEmpty) {
      return const EmptyState(
        message: 'لا توجد أوقات متاحة في هذا اليوم',
        icon: Icons.event_busy_outlined,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: starts.map((start) {
        final isSelected = start == selected;
        return InkWell(
          onTap: () => onSelected(start),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandRed : AppColors.surface,
              border: Border.all(
                  color: isSelected ? AppColors.brandRed : AppColors.line),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              start,
              style: AppTextStyles.tajawal(
                size: 13,
                weight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

/// A method row: icon, name, duration and the platform's real price.
class ConsultationMethodTile extends StatelessWidget {
  final ConsultationMethod method;
  final bool selected;
  final VoidCallback onTap;

  const ConsultationMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  static IconData iconFor(String code) {
    switch (code) {
      case 'video':
        return Icons.videocam_outlined;
      case 'office':
        return Icons.location_on_outlined;
      case 'whatsapp':
        return Icons.chat_outlined;
      default:
        return Icons.phone_in_talk_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
              color: selected ? AppColors.brandRed : AppColors.line,
              width: selected ? 1.4 : 1),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutralBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconFor(method.code), size: 20, color: AppColors.neutralInk),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name,
                      style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${method.durationMinutes} دقيقة',
                      style: AppTextStyles.tajawal(size: 11.5, color: AppColors.ink2)),
                ],
              ),
            ),
            Text(method.priceLabel,
                style: AppTextStyles.cairo(
                    size: 12.5, weight: FontWeight.w800, color: AppColors.brandRed)),
          ],
        ),
      ),
    );
  }
}
