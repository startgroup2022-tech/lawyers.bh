import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/legal_case.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';
import 'case_workspace_screen.dart';

/// The lawyer's case list, filterable by state.
class LawyerCasesScreen extends StatefulWidget {
  const LawyerCasesScreen({super.key});

  @override
  State<LawyerCasesScreen> createState() => _LawyerCasesScreenState();
}

class _LawyerCasesScreenState extends State<LawyerCasesScreen> {
  static const _filters = <(String, String)>[
    ('all', 'الكل'),
    ('open', 'مفتوحة'),
    ('closed', 'مغلقة'),
  ];

  String _filter = 'all';
  List<LegalCase> _cases = const [];
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
      final cases = await context.read<AppState>().cases.myCases();
      if (mounted) {
        setState(() {
          _cases = cases;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message ?? 'تعذّر تحميل القضايا';
          _loading = false;
        });
      }
    }
  }

  List<LegalCase> get _visible {
    switch (_filter) {
      case 'open':
        return _cases.where((c) => !['closed', 'won', 'lost'].contains(c.status)).toList();
      case 'closed':
        return _cases.where((c) => ['closed', 'won', 'lost'].contains(c.status)).toList();
      default:
        return _cases;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawyerColors.canvas,
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        title: const Text('ملفات القضايا'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: LawyerColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: ProSectionTitle(title: 'قضايا المكتب', subtitle: 'كل ما يخص قضاياك'),
                  ),
                  ..._filters.map((f) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(f.$2),
                          selected: _filter == f.$1,
                          selectedColor: LawyerColors.accentSoft,
                          onSelected: (_) => setState(() => _filter = f.$1),
                        ),
                      )),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
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
    final list = _visible;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open_outlined, size: 42, color: LawyerColors.ink3),
            const SizedBox(height: 10),
            Text('لا توجد قضايا في هذا التصنيف',
                style: AppTextStyles.tajawal(size: 13, color: LawyerColors.ink2)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final c = list[i];
          return InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CaseWorkspaceScreen(caseId: c.id)))
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
                        child: Text(c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
                      ),
                      ProBadge.forCase(c.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 13, color: LawyerColors.ink3),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(c.clientName ?? '—',
                            style: AppTextStyles.tajawal(size: 11, color: LawyerColors.ink2)),
                      ),
                      if (c.caseNumber != null)
                        Text(c.caseNumber!,
                            style: AppTextStyles.tajawal(size: 10, color: LawyerColors.ink3)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pill(Icons.event_outlined, '${c.hearingsCount} جلسة'),
                      const SizedBox(width: 8),
                      _pill(Icons.checklist_outlined, '${c.openTasks} مهمة'),
                      if (c.nextHearingAt != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: _pill(Icons.schedule_outlined, c.nextHearingAt!),
                        ),
                      ],
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

  Widget _pill(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: LawyerColors.ink3),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink2)),
        ],
      );
}
