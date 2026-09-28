import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lawyer_profile.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';

/// Manages the weekly availability grid and blocked dates.
///
/// The availability PUT is a full replacement, so the screen keeps the whole
/// week in memory and submits it on save.
class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final Map<int, List<_Slot>> _week = {};
  List<BlockedDate> _blocked = const [];
  bool _loading = true;
  bool _saving = false;
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
    final app = context.read<AppState>();
    try {
      final profile = await app.lawyer.profile();
      _week.clear();
      for (final slot in profile.availability) {
        _week.putIfAbsent(slot.weekday, () => []).add(_Slot.fromModel(slot));
      }
      _error = null;
    } on ApiException catch (e) {
      _error = e.message ?? 'تعذّر تحميل أوقات العمل';
    }
    try {
      _blocked = await app.lawyer.blockedDates();
    } on ApiException {
      _blocked = const [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final payload = <Map<String, dynamic>>[];
      _week.forEach((weekday, slots) {
        for (final s in slots) {
          payload.add({
            'weekday': weekday,
            'start_time': s.start,
            'end_time': s.end,
            'slot_duration_minutes': s.duration,
            'consultation_type': s.type,
          });
        }
      });
      await context.read<AppState>().lawyer.syncAvailability(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حفظ أوقات العمل')));
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر حفظ أوقات العمل')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addSlot(int weekday) async {
    final slot = await showModalBottomSheet<_Slot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SlotSheet(),
    );
    if (slot == null) return;
    setState(() => _week.putIfAbsent(weekday, () => []).add(slot));
  }

  Future<void> _blockDate() async {
    final result = await showModalBottomSheet<(String, String, String?)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BlockSheet(),
    );
    if (result == null || !mounted) return;
    // Capture the service before the first await: after it the widget may be
    // gone and `context` would be unsafe.
    final lawyer = context.read<AppState>().lawyer;
    try {
      await lawyer.blockDate(
        date: result.$1,
        reasonType: result.$2,
        reason: result.$3,
      );
      if (!mounted) return;
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر حجب التاريخ')));
      }
    }
  }

  Future<void> _unblock(int id) async {
    try {
      await context.read<AppState>().lawyer.unblockDate(id);
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر إلغاء الحجب')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawyerColors.canvas,
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        title: const Text('أوقات العمل'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF3E7),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: const Color(0xFFEBD3AE)),
                    ),
                    child: Text('تعذّر تحميل الأوقات الحالية: $_error',
                        style: AppTextStyles.tajawal(size: 11.5, color: const Color(0xFF8A5B12))),
                  ),
                const ProSectionTitle(
                  title: 'الجدول الأسبوعي',
                  subtitle: 'أضف الفترات التي تستقبل فيها المواعيد',
                ),
                ...List.generate(7, (weekday) => _dayCard(weekday)),
                const SizedBox(height: 18),
                ProSectionTitle(
                  title: 'الأيام المحجوبة',
                  subtitle: '${_blocked.length} تاريخ',
                  actionLabel: 'حجب تاريخ',
                  onAction: _blockDate,
                ),
                if (_blocked.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LawyerColors.surface,
                      border: Border.all(color: LawyerColors.line),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Text('لا توجد أيام محجوبة',
                        style: AppTextStyles.tajawal(size: 12, color: LawyerColors.ink2)),
                  )
                else
                  ..._blocked.map((b) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: LawyerColors.surface,
                          border: Border.all(color: LawyerColors.line),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_busy_outlined,
                                size: 17, color: LawyerColors.base2),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.blockedDate,
                                      style: AppTextStyles.tajawal(
                                          size: 12.5, weight: FontWeight.w600)),
                                  if (b.reason != null)
                                    Text(b.reason!,
                                        style: AppTextStyles.tajawal(
                                            size: 10.5, color: LawyerColors.ink3)),
                                ],
                              ),
                            ),
                            ProBadge(
                                label: b.allDay ? 'يوم كامل' : 'جزئي',
                                tone: LawyerColors.accent),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: LawyerColors.ink3),
                              onPressed: () => _unblock(b.id),
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LawyerColors.base,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('حفظ الجدول الأسبوعي'),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _dayCard(int weekday) {
    final slots = _week[weekday] ?? const <_Slot>[];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LawyerColors.surface,
        border: Border.all(color: LawyerColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AvailabilitySlot.weekdayNames[weekday],
                  style: AppTextStyles.cairo(size: 12.5, weight: FontWeight.w700)),
              const Spacer(),
              if (slots.isEmpty)
                Text('مغلق',
                    style: AppTextStyles.tajawal(size: 11, color: LawyerColors.ink3)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20, color: LawyerColors.accent),
                onPressed: () => _addSlot(weekday),
              ),
            ],
          ),
          ...slots.map((s) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: LawyerColors.accentSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${s.start} – ${s.end}',
                          style: AppTextStyles.cairo(
                              size: 11, weight: FontWeight.w700, color: AppColors.neutralInk)),
                    ),
                    const SizedBox(width: 8),
                    Text('${s.duration} دقيقة',
                        style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink3)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: LawyerColors.ink3),
                      onPressed: () => setState(() => _week[weekday]!.remove(s)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Slot {
  final String start;
  final String end;
  final int duration;
  final String type;

  _Slot({required this.start, required this.end, required this.duration, required this.type});

  factory _Slot.fromModel(AvailabilitySlot s) => _Slot(
        start: s.startTime.length >= 5 ? s.startTime.substring(0, 5) : s.startTime,
        end: s.endTime.length >= 5 ? s.endTime.substring(0, 5) : s.endTime,
        duration: s.slotDurationMinutes,
        type: s.consultationType,
      );
}

class _SlotSheet extends StatefulWidget {
  const _SlotSheet();

  @override
  State<_SlotSheet> createState() => _SlotSheetState();
}

class _SlotSheetState extends State<_SlotSheet> {
  final _start = TextEditingController(text: '09:00');
  final _end = TextEditingController(text: '17:00');
  int _duration = 30;

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: LawyerColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('إضافة فترة',
                style: AppTextStyles.cairo(
                    size: 16, weight: FontWeight.w800, color: LawyerColors.base)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _tf('من', _start)),
                const SizedBox(width: 10),
                Expanded(child: _tf('إلى', _end)),
              ],
            ),
            const SizedBox(height: 12),
            Text('مدة الموعد (دقيقة)',
                style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [15, 30, 45, 60].map((d) {
                return ChoiceChip(
                  label: Text('$d'),
                  selected: _duration == d,
                  selectedColor: LawyerColors.accentSoft,
                  onSelected: (_) => setState(() => _duration = d),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LawyerColors.base,
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: () {
                final re = RegExp(r'^\d{2}:\d{2}$');
                if (!re.hasMatch(_start.text.trim()) || !re.hasMatch(_end.text.trim())) return;
                Navigator.pop(
                  context,
                  _Slot(start: _start.text.trim(), end: _end.text.trim(), duration: _duration, type: 'any'),
                );
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(String label, TextEditingController c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
          const SizedBox(height: 5),
          TextField(
            controller: c,
            style: AppTextStyles.tajawal(size: 13),
            decoration: const InputDecoration(hintText: 'HH:MM'),
          ),
        ],
      );
}

class _BlockSheet extends StatefulWidget {
  const _BlockSheet();

  @override
  State<_BlockSheet> createState() => _BlockSheetState();
}

class _BlockSheetState extends State<_BlockSheet> {
  final _date = TextEditingController();
  final _reason = TextEditingController();
  String _type = 'vacation';

  @override
  void dispose() {
    _date.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: LawyerColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('حجب تاريخ',
                style: AppTextStyles.cairo(
                    size: 16, weight: FontWeight.w800, color: LawyerColors.base)),
            const SizedBox(height: 14),
            TextField(
              controller: _date,
              style: AppTextStyles.tajawal(size: 13),
              decoration: const InputDecoration(hintText: 'التاريخ (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reason,
              style: AppTextStyles.tajawal(size: 13),
              decoration: const InputDecoration(hintText: 'السبب (اختياري)'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ('vacation', 'إجازة'),
                ('holiday', 'عطلة'),
                ('court', 'محكمة'),
                ('personal', 'شخصي'),
                ('other', 'أخرى'),
              ].map((t) {
                return ChoiceChip(
                  label: Text(t.$2),
                  selected: _type == t.$1,
                  selectedColor: LawyerColors.accentSoft,
                  onSelected: (_) => setState(() => _type = t.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LawyerColors.base,
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: () {
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_date.text.trim())) return;
                Navigator.pop(context, (
                  _date.text.trim(),
                  _type,
                  _reason.text.trim().isEmpty ? null : _reason.text.trim(),
                ));
              },
              child: const Text('حجب'),
            ),
          ],
        ),
      ),
    );
  }
}
