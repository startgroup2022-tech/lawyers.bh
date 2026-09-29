import 'package:flutter/material.dart';

import '../services/auth_gate.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/sos_button.dart';
import 'home_screen.dart';
import 'lawyers_directory_screen.dart';
import 'my_cases_screen.dart';
import 'my_contracts_screen.dart';
import 'client_profile_screen.dart';
import 'messages_screen.dart';

/// Maps a bottom-bar destination to its child index in the client shell.
///
/// A signed-in client sees every tab, so the mapping is the identity. A guest
/// sees only the public tabs (home, directory, profile) — the two private
/// destinations are removed and the surviving ones fold onto a shorter list:
/// 0→home, 1→directory and 4→profile. Kept outside the widget so the fold can
/// be tested on its own.
int tabIndexFor(int destination, {required bool guest}) {
  if (!guest) return destination;
  switch (destination) {
    case 0:
      return 0;
    case 1:
      return 1;
    case 4:
      return 2;
    default:
      return 0;
  }
}

/// The consumer workspace: browse lawyers, sign, pay, track a case.
///
/// In [guest] mode the same public surfaces (home, directory) are shown, but
/// the two private tabs (contracts, cases) stay locked and route the guest to
/// the sign-in prompt instead of exposing private data.
class ClientShell extends StatefulWidget {
  final bool guest;

  const ClientShell({super.key, this.guest = false});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  /// Selected bottom-bar destination. Always 0..4, matching [_titles] and the
  /// five destinations, regardless of guest mode.
  int _selected = 0;

  late final List<Widget> _tabs = [
    HomeScreen(onBrowseAll: _goToDirectory),
    const LawyersDirectoryScreen(),
    if (!widget.guest) MyContractsScreen(onBrowseAll: _goToDirectory),
    if (!widget.guest) MyCasesScreen(onBrowseAll: _goToDirectory),
    ClientProfileScreen(guest: widget.guest),
  ];

  static const _titles = [
    'محامون البحرين',
    'دليل المحامين',
    'التعاقد والدفع',
    'متابعة القضية',
    'حسابي',
  ];

  void _goToDirectory() => setState(() => _selected = 1);

  /// The [_tabs] position for the selected destination.
  int get _tabIndex => tabIndexFor(_selected, guest: widget.guest);

  /// Guards the private tabs for guests: selecting one prompts for sign-in
  /// instead of revealing private data.
  void _onDestinationSelected(int destination) {
    if (widget.guest && (destination == 2 || destination == 3)) {
      promptSignIn(context, feature: _titles[destination]);
      return;
    }
    setState(() => _selected = destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The official platform wordmark — the same asset the slider uses —
            // rather than a separate circular mark.
            const BrandLogo(height: 20, onDark: true),
            const SizedBox(width: 10),
            Text(_titles[_selected]),
          ],
        ),
        actions: [
          if (!widget.guest)
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
      body: IndexedStack(
        index: _tabIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.neutralBg,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'المطابقة'),
          NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'العقد والدفع'),
          NavigationDestination(
              icon: Icon(Icons.timeline_outlined),
              selectedIcon: Icon(Icons.timeline),
              label: 'متابعة القضية'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'حسابي'),
        ],
      ),
    );
  }
}
