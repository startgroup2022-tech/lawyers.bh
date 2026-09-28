import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/sos_button.dart';
import 'home_screen.dart';
import 'lawyers_directory_screen.dart';
import 'my_cases_screen.dart';
import 'my_contracts_screen.dart';
import 'client_profile_screen.dart';
import 'messages_screen.dart';

/// The consumer workspace: browse lawyers, sign, pay, track a case.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  void _goToDirectory() => setState(() => _index = 1);

  late final List<Widget> _tabs = [
    HomeScreen(onBrowseAll: _goToDirectory),
    const LawyersDirectoryScreen(),
    MyContractsScreen(onBrowseAll: _goToDirectory),
    MyCasesScreen(onBrowseAll: _goToDirectory),
    const ClientProfileScreen(),
  ];

  static const _titles = [
    'محامون البحرين',
    'دليل المحامين',
    'التعاقد والدفع',
    'متابعة القضية',
    'حسابي',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandSeal(size: 30),
            const SizedBox(width: 9),
            Text(_titles[_index]),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الرسائل',
            icon: const Icon(Icons.forum_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MessagesScreen()),
            ),
          ),
          const Padding(padding: EdgeInsets.only(left: 4), child: SosButton()),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.neutralBg,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search), label: 'المطابقة'),
          NavigationDestination(
              icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'العقد والدفع'),
          NavigationDestination(
              icon: Icon(Icons.timeline_outlined), selectedIcon: Icon(Icons.timeline), label: 'متابعة القضية'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
