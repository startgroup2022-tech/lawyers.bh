import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/legal_case.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/case_timeline.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';

/// The case workspace: everything a lawyer needs on one case.
///
/// Five tabs, each backed by its own endpoint. A tab whose endpoint fails
/// shows the server's message in place, so a broken module does not take the
/// rest of the workspace down with it.
class CaseWorkspaceScreen extends StatefulWidget {
  final int caseId;
  const CaseWorkspaceScreen({super.key, required this.caseId});

  @override
  State<CaseWorkspaceScreen> createState() => _CaseWorkspaceScreenState();
}

class _CaseWorkspaceScreenState extends State<CaseWorkspaceScreen> {
  LegalCase? _case;
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
      final c = await context.read<AppState>().cases.caseDetail(widget.caseId);
      if (mounted) {
        setState(() {
          _case = c;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message ?? 'تعذّر تحميل القضية';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: LawyerColors.canvas,
        appBar: AppBar(
          backgroundColor: LawyerColors.base,
          title: Text(_case?.title ?? 'ملف القضية', overflow: TextOverflow.ellipsis),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: LawyerColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF9FB0C7),
            labelStyle: AppTextStyles.cairo(size: 12, weight: FontWeight.w700),
            tabs: const [
              Tab(text: 'نظرة عامة'),
              Tab(text: 'المهام'),
              Tab(text: 'الجلسات'),
              Tab(text: 'الملاحظات'),
              Tab(text: 'المستندات'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _case == null
                ? _errorBody()
                : TabBarView(
                    children: [
                      _OverviewTab(legalCase: _case!, onChanged: _load),
                      _TasksTab(caseId: widget.caseId),
                      _HearingsTab(caseId: widget.caseId),
                      _NotesTab(caseId: widget.caseId),
                      _DocumentsTab(caseId: widget.caseId),
                    ],
                  ),
      ),
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
              Text(_error ?? 'تعذّر تحميل القضية',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tajawal(size: 12.5, color: LawyerColors.ink2)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
}

// ---------------------------------------------------------------- overview

class _OverviewTab extends StatelessWidget {
  final LegalCase legalCase;
  final Future<void> Function() onChanged;
  const _OverviewTab({required this.legalCase, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LawyerColors.surface,
            border: Border.all(color: LawyerColors.line),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProBadge.forCase(legalCase.status),
                  const SizedBox(width: 8),
                  if (legalCase.caseNumber != null)
                    ProBadge(label: legalCase.caseNumber!, tone: LawyerColors.base2),
                  const Spacer(),
                  ProBadge.forPriority(legalCase.priority),
                ],
              ),
              const SizedBox(height: 12),
              _row('العميل', legalCase.clientName ?? '—'),
              _row('النوع', legalCase.caseType ?? '—'),
              _row('المحكمة', legalCase.courtName ?? '—'),
              _row('الأتعاب المتفق عليها',
                  legalCase.agreedFee == null ? '—' : '${legalCase.agreedFee!.toStringAsFixed(2)} ${legalCase.currency}'),
              _row('الجلسات', '${legalCase.hearingsCount}'),
              _row('المهام المفتوحة', '${legalCase.openTasks}'),
              if (legalCase.firmName != null) _row('المكتب', legalCase.firmName!),
            ],
          ),
        ),
        if (legalCase.timeline.isNotEmpty) ...[
          const SizedBox(height: 18),
          const ProSectionTitle(title: 'الجدول الزمني'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LawyerColors.surface,
              border: Border.all(color: LawyerColors.line),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: CaseTimelineWidget(steps: legalCase.timeline),
          ),
        ],
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('إغلاق القضية',
                    style: AppTextStyles.cairo(size: 15, weight: FontWeight.w800)),
                content: Text('سيتم تعليم القضية كمغلقة. هل تريد المتابعة؟',
                    style: AppTextStyles.tajawal(size: 12.5)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('إغلاق')),
                ],
              ),
            );
            if (confirmed != true || !context.mounted) return;
            final cases = context.read<AppState>().cases;
            try {
              await cases.closeCase(legalCase.id);
              await onChanged();
            } on ApiException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر إغلاق القضية')));
              }
            }
          },
          icon: const Icon(Icons.lock_outline, size: 16),
          label: const Text('إغلاق القضية'),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tajawal(size: 12.5, color: LawyerColors.ink)),
            ),
          ],
        ),
      );
}

// ------------------------------------------------------------------ tasks

class _TasksTab extends StatefulWidget {
  final int caseId;
  const _TasksTab({required this.caseId});

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> with _TabStateMixin<List<CaseTask>, _TasksTab> {
  @override
  Future<List<CaseTask>> fetch() => context.read<AppState>().cases.tasks(widget.caseId);

  @override
  Widget buildLoaded(List<CaseTask> tasks) {
    if (tasks.isEmpty) return const _EmptyTab(text: 'لا توجد مهام', icon: Icons.checklist_outlined);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final t = tasks[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LawyerColors.surface,
            border: Border.all(color: LawyerColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Checkbox(
                value: t.isDone,
                activeColor: LawyerColors.emerald,
                onChanged: (_) async {
                  final cases = context.read<AppState>().cases;
                  try {
                    await cases.updateTask(
                          widget.caseId,
                          t.id,
                          {'status': t.isDone ? 'pending' : 'completed'},
                        );
                    reload();
                  } on ApiException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر التحديث')));
                    }
                  }
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: AppTextStyles.tajawal(
                          size: 12.5,
                          color: t.isDone ? LawyerColors.ink3 : LawyerColors.ink,
                          weight: t.isDone ? FontWeight.w400 : FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ProBadge(
                          label: ProBadge.priorityOf(t.priority).$1,
                          tone: ProBadge.priorityOf(t.priority).$2,
                        ),
                        if (t.dueAt != null) ...[
                          const SizedBox(width: 6),
                          Text('استحقاق ${_date(t.dueAt!)}',
                              style: AppTextStyles.tajawal(size: 10, color: LawyerColors.ink3)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget buildFloating() => FloatingActionButton(
        backgroundColor: LawyerColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _addTask(context, widget.caseId, reload),
        child: const Icon(Icons.add),
      );

  static String _date(String iso) => iso.length >= 10 ? iso.substring(0, 10) : iso;
}

Future<void> _addTask(BuildContext context, int caseId, VoidCallback reload) async {
  final title = TextEditingController();
  String priority = 'normal';
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: LawyerColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('مهمة جديدة',
                  style: AppTextStyles.cairo(
                      size: 16, weight: FontWeight.w800, color: LawyerColors.base)),
              const SizedBox(height: 14),
              TextField(
                controller: title,
                style: AppTextStyles.tajawal(size: 13),
                decoration: const InputDecoration(hintText: 'عنوان المهمة'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['low', 'normal', 'high', 'urgent'].map((p) {
                  return ChoiceChip(
                    label: Text(ProBadge.priorityOf(p).$1),
                    selected: priority == p,
                    selectedColor: ProBadge.priorityOf(p).$2.withValues(alpha: 0.18),
                    onSelected: (_) => setSheet(() => priority = p),
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
                  if (title.text.trim().length < 3) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (ok == true && context.mounted) {
    final cases = context.read<AppState>().cases;
    try {
      await cases.addTask(caseId, title: title.text.trim(), priority: priority);
      reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر إضافة المهمة')));
      }
    }
  }
  title.dispose();
}

// --------------------------------------------------------------- hearings

class _HearingsTab extends StatefulWidget {
  final int caseId;
  const _HearingsTab({required this.caseId});

  @override
  State<_HearingsTab> createState() => _HearingsTabState();
}

class _HearingsTabState extends State<_HearingsTab> with _TabStateMixin<List<CaseHearing>, _HearingsTab> {
  @override
  Future<List<CaseHearing>> fetch() => context.read<AppState>().cases.hearings(widget.caseId);

  @override
  Widget buildLoaded(List<CaseHearing> hearings) {
    if (hearings.isEmpty) return const _EmptyTab(text: 'لا توجد جلسات', icon: Icons.event_busy_outlined);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      itemCount: hearings.length,
      itemBuilder: (context, i) {
        final h = hearings[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LawyerColors.surface,
            border: Border.all(color: LawyerColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: LawyerColors.accentSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.gavel_outlined, size: 18, color: LawyerColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_typeLabel(h.hearingType),
                        style: AppTextStyles.cairo(size: 12.5, weight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      [h.scheduledAt, h.courtName, h.judgeName]
                          .whereType<String>()
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink2),
                    ),
                  ],
                ),
              ),
              ProBadge(label: h.status, tone: LawyerColors.base2),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget buildFloating() => FloatingActionButton(
        backgroundColor: LawyerColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _addHearing(context, widget.caseId, reload),
        child: const Icon(Icons.add),
      );

  static String _typeLabel(String type) {
    switch (type) {
      case 'preliminary':
        return 'جلسة تمهيدية';
      case 'first':
        return 'الجلسة الأولى';
      case 'evidence':
        return 'جلسة إثبات';
      case 'pleading':
        return 'مرافعة';
      case 'judgment':
        return 'نطق بالحكم';
      case 'appeal':
        return 'استئناف';
      default:
        return 'جلسة';
    }
  }
}

Future<void> _addHearing(BuildContext context, int caseId, VoidCallback reload) async {
  final date = TextEditingController();
  final court = TextEditingController();
  final judge = TextEditingController();
  String type = 'other';
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: LawyerColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('إضافة جلسة',
                  style: AppTextStyles.cairo(
                      size: 16, weight: FontWeight.w800, color: LawyerColors.base)),
              const SizedBox(height: 14),
              TextField(
                controller: date,
                style: AppTextStyles.tajawal(size: 13),
                decoration: const InputDecoration(hintText: 'التاريخ (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: court,
                style: AppTextStyles.tajawal(size: 13),
                decoration: const InputDecoration(hintText: 'المحكمة'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: judge,
                style: AppTextStyles.tajawal(size: 13),
                decoration: const InputDecoration(hintText: 'القاضي'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: const [
                  ('preliminary', 'تمهيدية'),
                  ('first', 'أولى'),
                  ('evidence', 'إثبات'),
                  ('pleading', 'مرافعة'),
                  ('judgment', 'حكم'),
                  ('appeal', 'استئناف'),
                ].map((t) {
                  return ChoiceChip(
                    label: Text(t.$2),
                    selected: type == t.$1,
                    selectedColor: LawyerColors.accentSoft,
                    onSelected: (_) => setSheet(() => type = t.$1),
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
                  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date.text.trim())) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('إضافة الجلسة'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (ok == true && context.mounted) {
    final cases = context.read<AppState>().cases;
    try {
      await cases.addHearing(
            caseId,
            date: date.text.trim(),
            hearingType: type,
            courtName: court.text.trim().isEmpty ? null : court.text.trim(),
            judgeName: judge.text.trim().isEmpty ? null : judge.text.trim(),
          );
      reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر إضافة الجلسة')));
      }
    }
  }
  date.dispose();
  court.dispose();
  judge.dispose();
}

// ------------------------------------------------------------------ notes

class _NotesTab extends StatefulWidget {
  final int caseId;
  const _NotesTab({required this.caseId});

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> with _TabStateMixin<List<CaseNote>, _NotesTab> {
  @override
  Future<List<CaseNote>> fetch() => context.read<AppState>().cases.notes(widget.caseId);

  @override
  Widget buildLoaded(List<CaseNote> notes) {
    if (notes.isEmpty) return const _EmptyTab(text: 'لا توجد ملاحظات', icon: Icons.sticky_note_2_outlined);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        final n = notes[i];
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
                  ProBadge(
                    label: n.isInternal ? 'داخلية' : 'مرئية للعميل',
                    tone: n.isInternal ? LawyerColors.base2 : LawyerColors.emerald,
                  ),
                  const Spacer(),
                  Text(n.createdAt,
                      style: AppTextStyles.tajawal(size: 10, color: LawyerColors.ink3)),
                ],
              ),
              const SizedBox(height: 8),
              Text(n.body, style: AppTextStyles.tajawal(size: 12.5, height: 1.6)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget buildFloating() => FloatingActionButton(
        backgroundColor: LawyerColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _addNote(context, widget.caseId, reload),
        child: const Icon(Icons.add),
      );
}

Future<void> _addNote(BuildContext context, int caseId, VoidCallback reload) async {
  final body = TextEditingController();
  bool internal = true;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: LawyerColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ملاحظة جديدة',
                  style: AppTextStyles.cairo(
                      size: 16, weight: FontWeight.w800, color: LawyerColors.base)),
              const SizedBox(height: 14),
              TextField(
                controller: body,
                maxLines: 4,
                style: AppTextStyles.tajawal(size: 13),
                decoration: const InputDecoration(hintText: 'نص الملاحظة…'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: internal,
                activeThumbColor: LawyerColors.base,
                title: Text(internal ? 'ملاحظة داخلية' : 'ملاحظة مرئية للعميل',
                    style: AppTextStyles.tajawal(size: 12.5)),
                onChanged: (v) => setSheet(() => internal = v),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LawyerColors.base,
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: () {
                  if (body.text.trim().isEmpty) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (ok == true && context.mounted) {
    final cases = context.read<AppState>().cases;
    try {
      await cases.addNote(
            caseId,
            body: body.text.trim(),
            visibility: internal ? 'internal' : 'client_visible',
          );
      reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'تعذّر إضافة الملاحظة')));
      }
    }
  }
  body.dispose();
}

// -------------------------------------------------------------- documents

class _DocumentsTab extends StatefulWidget {
  final int caseId;
  const _DocumentsTab({required this.caseId});

  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  List<CaseDocLite> _docs = const [];
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
      final docs = await context.read<AppState>().documents.list(caseId: widget.caseId);
      if (mounted) {
        setState(() {
          _docs = docs.map((d) => CaseDocLite(d.id, d.title, d.categoryName, d.currentVersion)).toList();
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message ?? 'تعذّر تحميل المستندات';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _EmptyTab(text: _error!, icon: Icons.cloud_off_outlined);
    if (_docs.isEmpty) return const _EmptyTab(text: 'لا توجد مستندات', icon: Icons.folder_outlined);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _docs.length,
      itemBuilder: (context, i) {
        final d = _docs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LawyerColors.surface,
            border: Border.all(color: LawyerColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 20, color: LawyerColors.base2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.tajawal(size: 12.5, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      [d.category, 'إصدار ${d.version}'].whereType<String>().join(' · '),
                      style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A trimmed document projection used inside the workspace.
class CaseDocLite {
  final int id;
  final String title;
  final String? category;
  final int version;
  CaseDocLite(this.id, this.title, this.category, this.version);
}

// ------------------------------------------------------------------ shared

/// A tab that owns a single remote list, with its own loading/error state.
mixin _TabStateMixin<T, W extends StatefulWidget> on State<W> {
  T? _data;
  bool _loading = true;
  String? _error;

  Future<T> fetch();

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await fetch();
      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message ?? 'تعذّر تحميل البيانات';
          _loading = false;
        });
      }
    }
  }

  Widget buildLoaded(T data);

  Widget buildFloating() => const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _EmptyTab(text: _error!, icon: Icons.cloud_off_outlined, onRetry: reload);
    } else {
      body = buildLoaded(_data as T);
    }
    return Stack(
      children: [
        body,
        Positioned(bottom: 16, left: 16, child: buildFloating()),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onRetry;
  const _EmptyTab({required this.text, required this.icon, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 38, color: LawyerColors.ink3),
            const SizedBox(height: 10),
            Text(text,
                textAlign: TextAlign.center,
                style: AppTextStyles.tajawal(size: 12.5, color: LawyerColors.ink2)),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
            ],
          ],
        ),
      ),
    );
  }
}
