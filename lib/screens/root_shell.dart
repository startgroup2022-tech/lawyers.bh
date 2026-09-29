import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'client_shell.dart';
import 'lawyer_shell.dart';
import 'login_otp_screen.dart';

/// Chooses the workspace by role.
///
/// One app, two rooms: a client account lands in the consumer shell, a
/// professional account (lawyer / firm owner / manager / staff) lands in the
/// lawyer workspace. The decision is made from the identity returned by
/// `GET /auth/me`, so it survives a restart and never depends on which screen
/// the login happened to pass through.
///
/// It also owns the mid-session expiry path: when any call is rejected with
/// 401/403, [AppState.sessionExpired] flips and the workspace is replaced by
/// the login screen with a notice, instead of leaving the user on a screen
/// that can only ever fail.
class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final expired = context.select<AppState, bool>((s) => s.sessionExpired);
    final loggedIn = context.select<AppState, bool>((s) => s.isLoggedIn);
    if (expired || !loggedIn) {
      // Stay on login until a real sign-in restores the session (see
      // AppState.completeLogin). This is also what makes logout and an
      // account switch land on the login screen: once the session is cleared
      // there is no identity left to build a workspace from, so returning one
      // would show the previous role's screens with no account behind them.
      return LoginOtpScreen(
        notice: expired ? 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد.' : null,
      );
    }

    final isProfessional = context.select<AppState, bool>((s) => s.isProfessional);
    return isProfessional ? const LawyerShell() : const ClientShell();
  }
}

