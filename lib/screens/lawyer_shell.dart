import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'lawyer_cases_screen.dart';
import 'lawyer_dashboard_screen.dart';
import 'lawyer_more_screen.dart';
import 'lawyer_network_screen.dart';
import 'lead_pipeline_screen.dart';

/// The professional workspace shell.
///
/// The app bar carries the official brand red and the same logo as the client
/// side, because this is one product used by both roles; the two rooms differ in
/// layout and density rather than in palette. The five tabs cover a practice:
/// dashboard, CRM pipeline, case files, the professional network, and settings.
class LawyerShell extends StatefulWidget {
  const LawyerShell({super.key});

  @override
  State<LawyerShell> createState() => _LawyerShellState();
}

class _LawyerShellState extends State<LawyerShell> {
  int _index = 0;

  void _goToCrm() => setState(() => _index = 1);
  void _goToCases() => setState(() => _index = 2);

  late final List<Widget> _tabs = [
    LawyerDashboardScreen(onOpenCrm: _goToCrm, onOpenCases: _goToCases),
    const LeadPipelineScreen(),
    const LawyerCasesScreen(),
    const LawyerNetworkScreen(),
    const LawyerMoreScreen(),
  ];

  static const _titles = ['مكتب المحاماة', 'العملاء المحتملون', 'القضايا', 'الشبكة المهنية', 'المزيد'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        titleSpacing: 4,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandSeal(size: 30),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_titles[_index],
                    style: AppTextStyles.cairo(
                        size: 15, weight: FontWeight.w800, color: Colors.white)),
                Text('لوحة المحامي',
                    style: AppTextStyles.tajawal(size: 9.5, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: LawyerColors.surface,
        indicatorColor: LawyerColors.accentSoft,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'اللوحة'),
          NavigationDestination(
              icon: Icon(Icons.handshake_outlined),
              selectedIcon: Icon(Icons.handshake),
              label: 'CRM'),
          NavigationDestination(
              icon: Icon(Icons.folder_open_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'القضايا'),
          NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'الشبكة'),
          NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'المزيد'),
        ],
      ),
    );
  }
}
