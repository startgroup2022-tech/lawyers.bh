import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lead.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';
import 'lead_detail_screen.dart';

/// The Legal CRM: the lead pipeline.
///
/// A horizontally scrollable stage filter sits over the pipeline list, so a
/// lawyer can work one stage at a time. Counts come from the fetched list, and
/// the backend's own visibility scoping decides what is in it.
class LeadPipelineScreen extends StatefulWidget {
  const LeadPipelineScreen({super.key});

  @override
  State<LeadPipelineScreen> createState() => _LeadPipelineScreenState();
}

class _LeadPipelineScreenState extends State<LeadPipelineScreen> {
  static const _stages = <(String, String)>[
    ('', 'الكل'),
    ('new', 'جديد'),
    ('contacted', 'تم التواصل'),
    ('qualified', 'مؤهّل'),
    ('consultation', 'استشارة'),
    ('proposal', 'عرض'),
    ('negotiation', 'تفاوض'),
    ('won', 'مكتسب'),
    ('lost', 'خسارة'),
  ];

  String _status = '';
  List<Lead> _leads = const [];
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
      final leads = await context.read<AppState>().leads.list(status: _status);
      if (mounted) setState(() => _leads = leads);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'تعذّر تحميل العملاء المحتملين');
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تحميل العملاء المحتملين');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawyerColors.canvas,
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        title: const Text('العملاء المحتملون (CRM)'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: LawyerColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProSectionTitle(
                    title: 'خط أنابيب العملاء',
                    subtitle: 'اختر المرحلة لتصفية القائمة',
                  ),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _stages
                          .map((s) => _StageChip(
                                label: s.$2,
                                selected: _status == s.$1,
                                onTap: () {
                                  setState(() => _status = s.$1);
                                  _load();
                                },
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: LawyerColors.accent,
        foregroundColor: Colors.white,
        onPressed: _newLead,
        icon: const Icon(Icons.add),
        label: const Text('عميل محتمل جديد'),
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
    if (_leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search_outlined, size: 42, color: LawyerColors.ink3),
            const SizedBox(height: 10),
            Text('لا يوجد عملاء محتملون في هذه المرحلة',
                style: AppTextStyles.tajawal(size: 13, color: LawyerColors.ink2)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        itemCount: _leads.length,
        itemBuilder: (context, i) {
          final l = _leads[i];
          final (priorityLabel, priorityTone) = ProBadge.priorityOf(l.priority);
          return InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LeadDetailScreen(leadId: l.id)))
                .then((_) => _load()),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
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
                      Expanded(
                        child: Text(l.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
                      ),
                      ProBadge.lead(l.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.business_outlined, size: 13, color: LawyerColors.ink3),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(l.contactName ?? '—',
                            style: AppTextStyles.tajawal(size: 11, color: LawyerColors.ink2)),
                      ),
                      if (l.estimatedValue != null)
                        Text('${l.estimatedValue!.toStringAsFixed(0)} ${l.currency}',
                            style: AppTextStyles.cairo(
                                size: 11.5, weight: FontWeight.w700, color: LawyerColors.base)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ProBadge(label: priorityLabel, tone: priorityTone),
                      const SizedBox(width: 6),
                      if (l.specializationName != null && l.specializationName!.isNotEmpty)
                        ProBadge(label: l.specializationName!, tone: LawyerColors.base2),
                      const Spacer(),
                      Text(_shortDate(l.createdAt),
                          style: AppTextStyles.tajawal(size: 10, color: LawyerColors.ink3)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _newLead() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewLeadSheet(),
    );
    if (created == true) _load();
  }

  static String _shortDate(String iso) {
    if (iso.length >= 10) return iso.substring(0, 10);
    return iso;
  }
}

class _StageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StageChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? LawyerColors.base : Colors.white,
            border: Border.all(color: selected ? LawyerColors.base : LawyerColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.tajawal(
              size: 12,
              weight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? Colors.white : LawyerColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewLeadSheet extends StatefulWidget {
  const _NewLeadSheet();

  @override
  State<_NewLeadSheet> createState() => _NewLeadSheetState();
}

class _NewLeadSheetState extends State<_NewLeadSheet> {
  final _subject = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _value = TextEditingController();
  String _priority = 'normal';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _contact.dispose();
    _phone.dispose();
    _value.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subject.text.trim().length < 3) {
      setState(() => _error = 'العنوان مطلوب (3 أحرف على الأقل)');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final leads = context.read<AppState>().leads;
      await leads.create(
        subject: _subject.text.trim(),
        contactName: _contact.text.trim().isEmpty ? null : _contact.text.trim(),
        contactPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        priority: _priority,
        estimatedValue: double.tryParse(_value.text.trim()),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          // Surface the server's own message rather than a generic one.
          _error = e.message ?? 'تعذّر إنشاء العميل المحتمل';
          _busy = false;
        });
      }
    }
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('عميل محتمل جديد',
                  style: AppTextStyles.cairo(
                      size: 16, weight: FontWeight.w800, color: LawyerColors.base)),
              const SizedBox(height: 16),
              _field('الموضوع', _subject),
              const SizedBox(height: 10),
              _field('اسم جهة الاتصال', _contact),
              const SizedBox(height: 10),
              _field('رقم الهاتف', _phone, keyboard: TextInputType.phone),
              const SizedBox(height: 10),
              _field('القيمة المتوقعة (د.ب)', _value, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              Text('الأولوية',
                  style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
              const SizedBox(height: 6),
              Row(
                children: ['low', 'normal', 'high', 'urgent'].map((p) {
                  final (label, tone) = ProBadge.priorityOf(p);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _priority == p,
                      selectedColor: tone.withValues(alpha: 0.18),
                      onSelected: (_) => setState(() => _priority = p),
                    ),
                  );
                }).toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: AppTextStyles.tajawal(size: 11.5, color: AppColors.red)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LawyerColors.base,
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType? keyboard}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
          const SizedBox(height: 5),
          TextField(controller: c, keyboardType: keyboard, style: AppTextStyles.tajawal(size: 13)),
        ],
      );
}
