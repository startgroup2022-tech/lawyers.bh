import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lead.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';

/// A single lead: its details, its activity trail, and the actions that move
/// it forward (log a call, advance the stage, convert to a case).
class LeadDetailScreen extends StatefulWidget {
  final int leadId;
  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  Lead? _lead;
  List<LeadActivity> _activities = const [];
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _activitiesError;

  static const _stages = <(String, String)>[
    ('new', 'جديد'),
    ('contacted', 'تم التواصل'),
    ('qualified', 'مؤهّل'),
    ('consultation', 'استشارة'),
    ('proposal', 'عرض مقدّم'),
    ('negotiation', 'تفاوض'),
    ('won', 'مكتسب'),
    ('lost', 'خسارة'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _activitiesError = null;
    });
    try {
      final (lead, activities) = await context.read<AppState>().leads.detail(widget.leadId);
      if (mounted) {
        setState(() {
          _lead = lead;
          _activities = activities;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        // The lead itself loaded but the activity query failed, or the whole
        // read failed. Either way, show the server's message.
        setState(() {
          _error = e.message ?? 'تعذّر تحميل بيانات العميل المحتمل';
          _activitiesError = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'تعذّر تحميل بيانات العميل المحتمل';
          _activitiesError = 'تعذّر تحميل النشاط';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _advance(String status) async {
    setState(() => _busy = true);
    try {
      await context.read<AppState>().leads.update(widget.leadId, status: status);
      await _load();
    } on ApiException catch (e) {
      _snack(e.message ?? 'تعذّر تحديث المرحلة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logActivity() async {
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ActivitySheet(),
    );
    if (result == null || !mounted) return;
    setState(() => _busy = true);
    final leads = context.read<AppState>().leads;
    try {
      await leads.addActivity(
            widget.leadId,
            type: result.$1,
            notes: result.$2,
          );
      await _load();
    } on ApiException catch (e) {
      _snack(e.message ?? 'تعذّر تسجيل النشاط');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _convert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحويل إلى قضية',
            style: AppTextStyles.cairo(size: 15, weight: FontWeight.w800)),
        content: Text(
          'سيتم إنشاء ملف قضية مرتبط بهذا العميل المحتمل. هل تريد المتابعة؟',
          style: AppTextStyles.tajawal(size: 12.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تحويل')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final leads = context.read<AppState>().leads;
    try {
      await leads.convert(widget.leadId);
      _snack('تم إنشاء القضية بنجاح');
      await _load();
    } on ApiException catch (e) {
      _snack(e.message ?? 'تعذّر تحويل العميل المحتمل');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so the global app background shows through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        title: const Text('ملف العميل المحتمل'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _lead == null
              ? _errorBody()
              : _content(_lead!),
      bottomNavigationBar: _lead == null ? null : _actionsBar(_lead!),
    );
  }

  Widget _errorBody() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 40, color: LawyerColors.ink3),
              const SizedBox(height: 12),
              Text(_error ?? 'تعذّر تحميل البيانات',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tajawal(size: 12.5, color: LawyerColors.ink2)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );

  Widget _content(Lead lead) {
    final (priorityLabel, priorityTone) = ProBadge.priorityOf(lead.priority);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [LawyerColors.base, LawyerColors.base2],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(lead.subject,
                        style: AppTextStyles.cairo(
                            size: 15, weight: FontWeight.w800, color: Colors.white)),
                  ),
                  ProBadge.lead(lead.status),
                ],
              ),
              if (lead.reference != null) ...[
                const SizedBox(height: 6),
                Text(lead.reference!,
                    style: AppTextStyles.tajawal(size: 10.5, color: const Color(0xFF9FB0C7))),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _stat('القيمة', lead.estimatedValue == null
                      ? '—'
                      : '${lead.estimatedValue!.toStringAsFixed(0)} ${lead.currency}'),
                  _stat('الأولوية', priorityLabel, tone: priorityTone),
                  _stat('التخصص', lead.specializationName ?? '—'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const ProSectionTitle(title: 'مرحلة الخط', subtitle: 'انقل العميل بين المراحل'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LawyerColors.surface,
            border: Border.all(color: LawyerColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _stages.map((s) {
              final selected = lead.status == s.$1;
              return ChoiceChip(
                label: Text(s.$2),
                selected: selected,
                selectedColor: LawyerColors.accentSoft,
                onSelected: _busy || selected ? null : (_) => _advance(s.$1),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        const ProSectionTitle(title: 'بيانات التواصل'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LawyerColors.surface,
            border: Border.all(color: LawyerColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            children: [
              _kv(Icons.person_outline, 'جهة الاتصال', lead.contactName ?? '—'),
              _kv(Icons.phone_outlined, 'الهاتف', lead.contactPhone ?? '—'),
              _kv(Icons.source_outlined, 'المصدر', lead.source ?? '—'),
              if (lead.followUpAt != null)
                _kv(Icons.event_outlined, 'متابعة في', lead.followUpAt!),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ProSectionTitle(
          title: 'سجل النشاط',
          actionLabel: 'تسجيل نشاط',
          onAction: _busy ? null : _logActivity,
        ),
        if (_activitiesError != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF3E7),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: const Color(0xFFEBD3AE)),
            ),
            child: Text(
              'سجل النشاط غير متاح حاليًا: $_activitiesError',
              style: AppTextStyles.tajawal(size: 11.5, color: const Color(0xFF8A5B12)),
            ),
          )
        else if (_activities.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LawyerColors.surface,
              border: Border.all(color: LawyerColors.line),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Text('لا يوجد نشاط مسجّل بعد',
                style: AppTextStyles.tajawal(size: 12, color: LawyerColors.ink2)),
          )
        else
          ..._activities.map((a) => _activityRow(a)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _actionsBar(Lead lead) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: LawyerColors.surface,
        border: Border(top: BorderSide(color: LawyerColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _logActivity,
                icon: const Icon(Icons.note_add_outlined, size: 16),
                label: const Text('نشاط'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lead.isConverted ? LawyerColors.ink3 : LawyerColors.emerald,
                ),
                onPressed: _busy || lead.isConverted ? null : _convert,
                icon: const Icon(Icons.gavel_outlined, size: 16),
                label: Text(lead.isConverted ? 'محوّل' : 'تحويل لقضية'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityRow(LeadActivity a) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: LawyerColors.surface,
          border: Border.all(color: LawyerColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: LawyerColors.accentSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(_activityIcon(a.activityType), size: 15, color: LawyerColors.accent),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.summary ?? a.activityType,
                      style: AppTextStyles.tajawal(size: 12, color: LawyerColors.ink)),
                  const SizedBox(height: 3),
                  Text(
                    [a.authorName, a.createdAt].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
                    style: AppTextStyles.tajawal(size: 10, color: LawyerColors.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  static IconData _activityIcon(String type) {
    switch (type) {
      case 'call':
        return Icons.call_outlined;
      case 'email':
        return Icons.mail_outline;
      case 'meeting':
        return Icons.groups_outlined;
      case 'follow_up':
        return Icons.schedule_outlined;
      case 'status_changed':
        return Icons.swap_horiz;
      default:
        return Icons.sticky_note_2_outlined;
    }
  }

  Widget _stat(String label, String value, {Color? tone}) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.tajawal(size: 10, color: const Color(0xFF9FB0C7))),
            const SizedBox(height: 3),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cairo(
                    size: 12.5, weight: FontWeight.w700, color: tone ?? Colors.white)),
          ],
        ),
      );

  Widget _kv(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(icon, size: 16, color: LawyerColors.ink3),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tajawal(size: 12.5, color: LawyerColors.ink)),
            ),
          ],
        ),
      );
}

/// The activity logger: type plus a note.
class _ActivitySheet extends StatefulWidget {
  const _ActivitySheet();

  @override
  State<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends State<_ActivitySheet> {
  final _notes = TextEditingController();
  String _type = 'note';

  static const _types = <(String, String)>[
    ('note', 'ملاحظة'),
    ('call', 'اتصال'),
    ('email', 'بريد'),
    ('meeting', 'اجتماع'),
    ('follow_up', 'متابعة'),
    ('other', 'أخرى'),
  ];

  @override
  void dispose() {
    _notes.dispose();
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
            Text('تسجيل نشاط',
                style: AppTextStyles.cairo(
                    size: 16, weight: FontWeight.w800, color: LawyerColors.base)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: _types
                  .map((t) => ChoiceChip(
                        label: Text(t.$2),
                        selected: _type == t.$1,
                        selectedColor: LawyerColors.accentSoft,
                        onSelected: (_) => setState(() => _type = t.$1),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _notes,
              maxLines: 4,
              style: AppTextStyles.tajawal(size: 13),
              decoration: const InputDecoration(hintText: 'تفاصيل النشاط…'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LawyerColors.base,
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: () {
                final notes = _notes.text.trim();
                if (notes.isEmpty) return;
                Navigator.pop(context, (_type, notes));
              },
              child: const Text('حفظ النشاط'),
            ),
          ],
        ),
      ),
    );
  }
}
