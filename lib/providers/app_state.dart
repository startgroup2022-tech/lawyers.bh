import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/case_service.dart';
import '../services/documents_service.dart';
import '../services/lawyer_service.dart';
import '../services/lawyers_service.dart';
import '../services/leads_service.dart';
import '../services/messages_service.dart';
import '../services/notifications_service.dart';
import '../services/payments_service.dart';
import '../services/sos_service.dart';

const _tokenPrefsKey = 'auth_token';
const _guestPrefsKey = 'guest_mode';

/// How the app started. Drives which experience the splash hands off to.
enum BootstrapResult {
  /// The app is brand new to this device — no stored token, no prior choice.
  firstRun,

  /// A stored token was validated: an authenticated client or lawyer.
  authenticated,

  /// The user previously chose to continue as a guest.
  guest,

  /// A stored token existed but the backend rejected it (expired/invalid).
  sessionExpired,
}

class AppState extends ChangeNotifier {
  final ApiClient api = ApiClient();
  late final AuthService auth = AuthService(api);
  late final LawyersService lawyers = LawyersService(api);
  late final CaseService cases = CaseService(api);
  late final SosService sos = SosService(api);
  late final MessagesService messages = MessagesService(api);
  late final NotificationsService notifications = NotificationsService(api);
  late final PaymentsService payments = PaymentsService(api);

  /// Professional (lawyer) workspace services.
  late final LawyerService lawyer = LawyerService(api);
  late final LeadsService leads = LeadsService(api);
  late final DocumentsService documents = DocumentsService(api);

  AppUser? currentUser;
  bool isBootstrapping = true;

  /// True once the user asked to browse without an account.
  ///
  /// Guest is purely a local UI state; it is never a token and never a user.
  /// Protected screens check `isLoggedIn`, so a guest can never reach them.
  bool isGuest = false;

  /// True when the signed-in account should get the lawyer workspace.
  bool get isProfessional => currentUser?.isProfessional ?? false;

  bool can(String permission) => currentUser?.can(permission) ?? false;

  Future<BootstrapResult> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenPrefsKey);
    var result = BootstrapResult.firstRun;

    if (token != null && token.isNotEmpty) {
      api.setToken(token);
      try {
        currentUser = await auth.me();
        isGuest = false;
        await prefs.remove(_guestPrefsKey);
        result = BootstrapResult.authenticated;
      } catch (_) {
        // Expired or invalid token: clear it and ask for a fresh login.
        await prefs.remove(_tokenPrefsKey);
        api.setToken(null);
        currentUser = null;
        isGuest = false;
        result = BootstrapResult.sessionExpired;
      }
    } else if (prefs.getBool(_guestPrefsKey) == true) {
      // The user chose guest browsing on a previous launch; restore it.
      isGuest = true;
      currentUser = null;
      result = BootstrapResult.guest;
    }

    isBootstrapping = false;
    notifyListeners();
    return result;
  }

  Future<void> completeLogin(String token, AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenPrefsKey, token);
    api.setToken(token);
    isGuest = false;

    // The OTP response carries the primary role only. Fetch the full identity
    // so `roles`/`permissions` are populated before the shell decides which
    // workspace to open.
    currentUser = user;
    try {
      currentUser = await auth.me();
    } catch (_) {
      // Keep the OTP-provided user; role-based routing still works off `role`.
    }
    notifyListeners();
  }

  /// Enters the app as a guest: public browsing only, no token, no account.
  ///
  /// The choice is remembered so the next launch restores the guest experience,
  /// but it is never a credential — `isLoggedIn` stays false throughout.
  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestPrefsKey, true);
    isGuest = true;
    currentUser = null;
    api.setToken(null);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenPrefsKey);
    await prefs.remove(_guestPrefsKey);
    api.setToken(null);
    currentUser = null;
    isGuest = false;
    notifyListeners();
  }

  bool get isLoggedIn => currentUser != null;
}
