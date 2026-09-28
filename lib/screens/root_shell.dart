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
    if (expired) {
      // Stay on login until a real sign-in clears the flag (see
      // AppState.completeLogin). Returning a workspace here would bounce the
      // user straight back into screens that can only fail.
      return const LoginOtpScreen(
        notice: 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد.',
      );
    }

    final isProfessional = context.select<AppState, bool>((s) => s.isProfessional);
    return isProfessional ? const LawyerShell() : const ClientShell();
  }
}

