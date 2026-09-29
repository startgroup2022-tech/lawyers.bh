import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lead.dart';
import '../models/legal_case.dart';
import '../models/lawyer_profile.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/kpi_tile.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_header.dart';
import '../widgets/pro_section_title.dart';
import 'case_workspace_screen.dart';
import 'lawyer_profile_editor_screen.dart';
import 'lead_detail_screen.dart';

/// The lawyer's practice dashboard.
///
/// Everything here is drawn from the professional endpoints: the profile
/// header from `/lawyer/profile`, the pipeline and case counts from `/leads`
/// and `/cases`. When the backend declines a section (a module returning an
/// error), that section degrades to an explanatory card instead of failing the
/// whole screen.
class LawyerDashboardScreen extends StatefulWidget {
  final VoidCallback onOpenCrm;
  final VoidCallback onOpenCases;

  const LawyerDashboardScreen({
    super.key,
    required this.onOpenCrm,
    required this.onOpenCases,
  });

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen> {
  LawyerProfile? _profile;
  List<Lead> _leads = const [];
  List<LegalCase> _cases = const [];
  bool _loading = true;
  String? _profileError;
  String? _leadsError;
  String? _casesError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final app = context.read<AppState>();

    // Each section loads independently so one broken endpoint cannot blank the
    // dashboard. `finally` guarantees the spinner clears no matter what fails.
    try {
      try {
        _profile = await app.lawyer.profile();
        _profileError = null;
      } on ApiException catch (e) {
        _profileError = e.message ?? 'تعذّر تحميل الملف المهني';
      } catch (_) {
        _profileError = 'تعذّر تحميل الملف المهني';
      }

      try {
        _leads = await app.leads.list();
        _leadsError = null;
      } on ApiException catch (e) {
        _leadsError = e.message ?? 'تعذّر تحميل العملاء المحتملين';
      } catch (_) {
        _leadsError = 'تعذّر تحميل العملاء المحتملين';
      }

      try {
        _cases = await app.cases.myCases();
        _casesError = null;
      } on ApiException catch (e) {
        _casesError = e.message ?? 'تعذّر تحميل القضايا';
      } catch (_) {
        _casesError = 'تعذّر تحميل القضايا';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final user = app.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProHeader(
                user: user!,
                profile: _profile,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LawyerProfileEditorScreen()),
                ),
              ),
              if (_profileError != null) ...[
                const SizedBox(height: 10),
                _Notice(text: _profileError!, onRetry: _load),
              ],
              const SizedBox(height: 20),
              const ProSectionTitle(title: 'نظرة على المكتب', subtitle: 'مؤشرات اليوم'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  KpiTile(
                    label: 'عملاء محتملون نشطون',
                    value: _leadsError != null ? '—' : '${_leads.where((l) => l.isOpen).length}',
                    icon: Icons.person_search_outlined,
                    accent: LawyerColors.accent,
                    onTap: widget.onOpenCrm,
                  ),
                  KpiTile(
                    label: 'قضايا مفتوحة',
                    value: _casesError != null
                        ? '—'
                        : '${_cases.where((c) => !['closed', 'won', 'lost'].contains(c.status)).length}',
                    icon: Icons.folder_open_outlined,
                    accent: LawyerColors.emerald,
                    onTap: widget.onOpenCases,
                  ),
                  KpiTile(
                    label: 'إجمالي القضايا',
                    value: _casesError != null ? '—' : '${_cases.length}',
                    icon: Icons.gavel_outlined,
                    accent: LawyerColors.base2,
                    onTap: widget.onOpenCases,
                  ),
                  KpiTile(
                    label: 'قيمة خط الأنابيب',
                    value: _leadsError != null
                        ? '—'
                        : _leads
                            .where((l) => l.isOpen)
                            .fold<double>(0, (sum, l) => sum + (l.estimatedValue ?? 0))
                            .toStringAsFixed(0),
                    icon: Icons.payments_outlined,
                    accent: LawyerColors.accent,
                    onTap: widget.onOpenCrm,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ProSectionTitle(
                title: 'أحدث العملاء المحتملين',
                actionLabel: 'كل الـ CRM',
                onAction: widget.onOpenCrm,
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_leadsError != null)
                _Notice(text: _leadsError!, onRetry: _load)
              else if (_leads.isEmpty)
                _Empty(text: 'لا يوجد عملاء محتملون بعد', icon: Icons.person_search_outlined)
              else
                ..._leads.take(4).map((l) => _LeadRow(lead: l, onTap: () => _openLead(l))),
              const SizedBox(height: 18),
              ProSectionTitle(
                title: 'قضايا حديثة',
                actionLabel: 'كل القضايا',
                onAction: widget.onOpenCases,
              ),
              if (_casesError != null)
                _Notice(text: _casesError!, onRetry: _load)
              else if (!_loading && _cases.isEmpty)
                _Empty(text: 'لا توجد قضايا بعد', icon: Icons.folder_open_outlined)
              else
                ..._cases.take(3).map((c) => _CaseRow(legalCase: c, onTap: () => _openCase(c))),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _openLead(Lead lead) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LeadDetailScreen(leadId: lead.id)),
      );

  void _openCase(LegalCase legalCase) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CaseWorkspaceScreen(caseId: legalCase.id)),
      );
}

class _LeadRow extends StatelessWidget {
  final Lead lead;
  final VoidCallback onTap;
  const _LeadRow({required this.lead, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: LawyerColors.accentSoft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.handshake_outlined, size: 18, color: LawyerColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lead.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cairo(size: 12.5, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    [lead.contactName, lead.specializationName]
                        .whereType<String>()
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ProBadge.lead(lead.status),
          ],
        ),
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  final LegalCase legalCase;
  final VoidCallback onTap;
  const _CaseRow({required this.legalCase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LawyerColors.surface,
          border: Border.all(color: LawyerColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(legalCase.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cairo(size: 12.5, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    '${legalCase.clientName ?? '—'}${legalCase.caseNumber != null ? ' · ${legalCase.caseNumber}' : ''}',
                    style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink2),
                  ),
                ],
              ),
            ),
            ProBadge.forCase(legalCase.status),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;
  const _Notice({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3E7),
        border: Border.all(color: const Color(0xFFEBD3AE)),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFB7791F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTextStyles.tajawal(size: 11.5, color: const Color(0xFF8A5B12))),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة')),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Empty({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LawyerColors.surface,
        border: Border.all(color: LawyerColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: LawyerColors.ink3),
          const SizedBox(height: 8),
          Text(text, style: AppTextStyles.tajawal(size: 12, color: LawyerColors.ink2)),
        ],
      ),
    );
  }
}
