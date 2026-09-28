import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lawyer_profile.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_section_title.dart';
import 'availability_screen.dart';

/// Edits the lawyer's own profile.
///
/// `PATCH /lawyer/profile` writes every validated field it receives, so this
/// screen always submits the complete editable set — omitting a field would
/// null it on the server. The form is seeded from `GET /lawyer/profile`; if
/// that read fails, the lawyer can still fill the form in and save, and the
/// failure is shown plainly rather than blocking the screen.
class LawyerProfileEditorScreen extends StatefulWidget {
  const LawyerProfileEditorScreen({super.key});

  @override
  State<LawyerProfileEditorScreen> createState() => _LawyerProfileEditorScreenState();
}

class _LawyerProfileEditorScreenState extends State<LawyerProfileEditorScreen> {
  final _name = TextEditingController();
  final _nameEn = TextEditingController();
  final _bio = TextEditingController();
  final _city = TextEditingController();
  final _location = TextEditingController();
  final _experience = TextEditingController();
  final _fee = TextEditingController();
  final _feeMin = TextEditingController();
  final _feeMax = TextEditingController();
  final _licenseAuthority = TextEditingController();
  final _barAssociation = TextEditingController();
  final _barNumber = TextEditingController();

  bool _acceptsOnline = true;
  bool _acceptsInperson = true;
  List<String> _languages = ['ar'];
  String _profileStatus = 'draft';

  LawyerProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _nameEn,
      _bio,
      _city,
      _location,
      _experience,
      _fee,
      _feeMin,
      _feeMax,
      _licenseAuthority,
      _barAssociation,
      _barNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final p = await context.read<AppState>().lawyer.profile();
      _profile = p;
      _name.text = p.professionalName;
      _nameEn.text = p.professionalNameEn ?? '';
      _bio.text = p.bio ?? '';
      _city.text = p.city ?? '';
      _location.text = p.location ?? '';
      _experience.text = '${p.experienceYears}';
      _fee.text = p.consultationFee.toStringAsFixed(0);
      _feeMin.text = p.caseFeeMin?.toStringAsFixed(0) ?? '';
      _feeMax.text = p.caseFeeMax?.toStringAsFixed(0) ?? '';
      _licenseAuthority.text = p.licenseAuthority ?? '';
      _barAssociation.text = p.barAssociation ?? '';
      _barNumber.text = p.barNumber ?? '';
      _acceptsOnline = p.acceptsOnline;
      _acceptsInperson = p.acceptsInperson;
      _languages = p.languages.isEmpty ? ['ar'] : p.languages;
      _profileStatus = p.profileStatus;
    } on ApiException catch (e) {
      _loadError = e.message ?? 'تعذّر تحميل الملف المهني';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 2) {
      _snack('الاسم المهني مطلوب');
      return;
    }
    setState(() => _saving = true);
    try {
      // Send the complete editable payload; the endpoint overwrites every
      // field it validates.
      await context.read<AppState>().lawyer.updateProfile({
        'professional_name': _name.text.trim(),
        'professional_name_en': _nameEn.text.trim(),
        'bio': _bio.text.trim(),
        'city': _city.text.trim(),
        'location': _location.text.trim(),
        'experience_years': int.tryParse(_experience.text.trim()) ?? 0,
        'consultation_fee': double.tryParse(_fee.text.trim()) ?? 0,
        if (_feeMin.text.trim().isNotEmpty)
          'case_fee_min': double.tryParse(_feeMin.text.trim()),
        if (_feeMax.text.trim().isNotEmpty)
          'case_fee_max': double.tryParse(_feeMax.text.trim()),
        if (_licenseAuthority.text.trim().isNotEmpty)
          'license_authority': _licenseAuthority.text.trim(),
        if (_barAssociation.text.trim().isNotEmpty)
          'bar_association': _barAssociation.text.trim(),
        if (_barNumber.text.trim().isNotEmpty) 'bar_number': _barNumber.text.trim(),
        'languages': _languages,
        'accepts_online': _acceptsOnline,
        'accepts_inperson': _acceptsInperson,
        'profile_status': _profileStatus,
      });
      _snack('تم حفظ الملف المهني');
      await _load();
    } on ApiException catch (e) {
      _snack(e.message ?? 'تعذّر حفظ الملف');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawyerColors.canvas,
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        title: const Text('الملف المهني'),
        actions: [
          if (_profile != null)
            IconButton(
              tooltip: 'أوقات العمل',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AvailabilityScreen()),
              ),
              icon: const Icon(Icons.schedule_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_loadError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF3E7),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: const Color(0xFFEBD3AE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_outlined,
                                size: 16, color: Color(0xFFB7791F)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('تعذّر تحميل الملف الحالي',
                                  style: AppTextStyles.cairo(
                                      size: 12, weight: FontWeight.w700, color: const Color(0xFF8A5B12))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(_loadError!,
                            style: AppTextStyles.tajawal(size: 11, color: const Color(0xFF8A5B12))),
                        const SizedBox(height: 6),
                        Text('يمكنك تعبئة الحقول والحفظ مباشرة.',
                            style: AppTextStyles.tajawal(size: 11, color: const Color(0xFF8A5B12))),
                      ],
                    ),
                  ),
                if (_profile != null) ...[
                  _statusCard(_profile!),
                  const SizedBox(height: 18),
                ],
                const ProSectionTitle(title: 'الهوية المهنية'),
                _card([
                  _field('الاسم المهني *', _name),
                  _field('الاسم بالإنجليزية', _nameEn),
                  _field('نبذة مهنية', _bio, maxLines: 4),
                ]),
                const SizedBox(height: 16),
                const ProSectionTitle(title: 'الخبرة والأتعاب'),
                _card([
                  Row(
                    children: [
                      Expanded(child: _field('سنوات الخبرة', _experience, number: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _field('أتعاب الاستشارة (د.ب)', _fee, number: true)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field('أدنى أتعاب قضية', _feeMin, number: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _field('أقصى أتعاب قضية', _feeMax, number: true)),
                    ],
                  ),
                ]),
                const SizedBox(height: 16),
                const ProSectionTitle(title: 'الموقع والتواصل'),
                _card([
                  _field('المدينة', _city),
                  _field('العنوان', _location),
                ]),
                const SizedBox(height: 16),
                const ProSectionTitle(title: 'الترخيص والاعتماد'),
                _card([
                  _field('جهة الترخيص', _licenseAuthority),
                  _field('جمعية المحامين', _barAssociation),
                  _field('رقم العضوية', _barNumber),
                ]),
                const SizedBox(height: 16),
                const ProSectionTitle(title: 'اللغات ونمط العمل'),
                _card([
                  Wrap(
                    spacing: 8,
                    children: [
                      ('ar', 'العربية'),
                      ('en', 'الإنجليزية'),
                    ].map((l) {
                      final selected = _languages.contains(l.$1);
                      return FilterChip(
                        label: Text(l.$2),
                        selected: selected,
                        selectedColor: LawyerColors.accentSoft,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _languages = [..._languages, l.$1];
                          } else {
                            _languages = _languages.where((e) => e != l.$1).toList();
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _acceptsOnline,
                    activeThumbColor: LawyerColors.base,
                    title: Text('استشارات عن بُعد', style: AppTextStyles.tajawal(size: 12.5)),
                    onChanged: (v) => setState(() => _acceptsOnline = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _acceptsInperson,
                    activeThumbColor: LawyerColors.base,
                    title: Text('استشارات حضورية', style: AppTextStyles.tajawal(size: 12.5)),
                    onChanged: (v) => setState(() => _acceptsInperson = v),
                  ),
                  const SizedBox(height: 8),
                  Text('حالة الملف',
                      style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ('draft', 'مسودة'),
                      ('published', 'منشور'),
                      ('hidden', 'مخفي'),
                    ].map((s) {
                      return ChoiceChip(
                        label: Text(s.$2),
                        selected: _profileStatus == s.$1,
                        selectedColor: LawyerColors.accentSoft,
                        onSelected: (_) => setState(() => _profileStatus = s.$1),
                      );
                    }).toList(),
                  ),
                  if (_profile != null && !_profile!.isVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('لا يمكن النشر قبل اكتمال التوثيق.',
                          style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink3)),
                    ),
                ]),
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
                      : const Text('حفظ الملف المهني'),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _statusCard(LawyerProfile p) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LawyerColors.surface,
          border: Border.all(color: LawyerColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            ProBadge(
              label: p.isVerified ? 'موثّق' : 'قيد التوثيق',
              tone: p.isVerified ? LawyerColors.emerald : LawyerColors.accent,
              filled: true,
            ),
            const SizedBox(width: 8),
            ProBadge(label: p.isPublished ? 'منشور' : 'غير منشور', tone: LawyerColors.base2),
            const Spacer(),
            Text('★ ${p.rating.toStringAsFixed(1)}',
                style: AppTextStyles.cairo(
                    size: 13, weight: FontWeight.w800, color: LawyerColors.base)),
          ],
        ),
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LawyerColors.surface,
          border: Border.all(color: LawyerColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );

  Widget _field(String label, TextEditingController c, {int maxLines = 1, bool number = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
            const SizedBox(height: 5),
            TextField(
              controller: c,
              maxLines: maxLines,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              style: AppTextStyles.tajawal(size: 13),
            ),
          ],
        ),
      );
}
