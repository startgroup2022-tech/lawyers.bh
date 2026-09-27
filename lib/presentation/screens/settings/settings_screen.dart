import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';
import 'package:lawyers_bh/presentation/providers/theme_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(title: 'عام', children: [
            _SettingsTile(
              icon: Icons.language,
              title: l10n.language,
              subtitle: 'العربية',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.palette_outline,
              title: l10n.theme,
              subtitle: 'فاتح',
              trailing: Consumer(builder: (context, ref, _) {
                final themeMode = ref.watch(themeProvider);
                return Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) => ref.read(themeProvider.notifier).setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                  activeColor: AppColors.navy,
                );
              }),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),

          _SettingsSection(title: 'الإشعارات', children: [
            _SettingsTile(
              icon: Icons.notifications_active,
              title: l10n.notificationsSettings,
              subtitle: 'إدارة إشعارات التطبيق',
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.navy),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.email,
              title: 'إشعارات البريد الإلكتروني',
              subtitle: 'استلام التحديثات عبر البريد',
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.navy),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.sms,
              title: 'إشعارات الرسائل القصيرة',
              subtitle: 'رموز التحقق والتنبيهات الهامة',
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.navy),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),

          _SettingsSection(title: 'البيانات والتخزين', children: [
            _SettingsTile(
              icon: Icons.clear_all,
              title: 'مسح ذاكرة التخزين المؤقت',
              subtitle: 'تحرير مساحة التخزين',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.download,
              title: 'تنزيل البيانات',
              subtitle: 'طلب نسخة من بياناتك',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),

          _SettingsSection(title: 'حول التطبيق', children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'إصدار التطبيق',
              subtitle: _appVersion,
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.license,
              title: 'التراخيص مفتوحة المصدر',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.ink3)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink2, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium),
                  if (subtitle != null) Text(subtitle!, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (trailing != null) trailing! else Icon(Icons.chevron_left, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}