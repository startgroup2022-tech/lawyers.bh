import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'client_shell.dart';
import 'lawyer_shell.dart';

/// Chooses the workspace by role.
///
/// One app, two rooms: a client account lands in the consumer shell, a
/// professional account (lawyer / firm owner / manager / staff) lands in the
/// lawyer workspace. The decision is made from the identity returned by
/// `GET /auth/me`, so it survives a restart and never depends on which screen
/// the login happened to pass through.
class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isProfessional = context.select<AppState, bool>((s) => s.isProfessional);
    return isProfessional ? const LawyerShell() : const ClientShell();
  }
}

