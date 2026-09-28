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

  /// A stored token existed but the backend could not be reached. The session
  /// is kept — a later retry may still succeed — and the user is shown an
  /// offline state rather than being forced to log in again.
  offline,
}

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : api = apiClient ?? ApiClient() {
    api.onAuthRejection = _handleAuthRejection;
  }

  final ApiClient api;
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

  /// Test seam: when set, [bootstrap] resolves the stored-session identity
  /// through this instead of the live `/auth/me` call. Lets tests exercise the
  /// accepted/rejected/offline branches without a running backend.
  Future<AppUser> Function()? identityLoader;

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
        currentUser = await (identityLoader ?? auth.session)();
        isGuest = false;
        await prefs.remove(_guestPrefsKey);
        result = BootstrapResult.authenticated;
      } on ApiException catch (e) {
        // Only a definitive auth rejection invalidates the session. A network
        // or server-side failure must not; treat it as a temporary outage and
        // keep the stored token so a retry can restore the session.
        if (_isAuthRejection(e)) {
          await prefs.remove(_tokenPrefsKey);
          api.setToken(null);
          currentUser = null;
          isGuest = false;
          result = BootstrapResult.sessionExpired;
        } else {
          currentUser = null;
          isGuest = false;
          result = BootstrapResult.offline;
        }
      } catch (_) {
        currentUser = null;
        isGuest = false;
        result = BootstrapResult.offline;
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
    sessionExpired = false;

    // The verify response already carries the full client profile, so no
    // follow-up identity call is needed; keep it simple and use it directly.
    currentUser = user;
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
    sessionExpired = false;
    currentUser = null;
    api.setToken(null);
    notifyListeners();
  }

  Future<void> logout() async {
    // Best-effort server-side session teardown before clearing locally. A
    // failed call must not leave the user stuck signed in.
    try {
      await auth.logout();
    } catch (_) {
      // Ignore: clearing local state below is what matters.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenPrefsKey);
    await prefs.remove(_guestPrefsKey);
    api.setToken(null);
    currentUser = null;
    isGuest = false;
    sessionExpired = false;
    notifyListeners();
  }

  bool get isLoggedIn => currentUser != null;

  /// Set when the backend rejected the session mid-use (a 401 on any call).
  /// The shell listens for this and routes back to login with a notice, so an
  /// expired token never leaves the user staring at a failed screen.
  bool sessionExpired = false;

  void _handleAuthRejection() {
    // Only a signed-in session can expire; ignore rejections while logged out
    // (e.g. a wrong OTP code, which the login screen reports itself).
    if (currentUser == null) return;
    sessionExpired = true;
    currentUser = null;
    isGuest = false;
    api.setToken(null);
    SharedPreferences.getInstance().then((p) => p.remove(_tokenPrefsKey));
    notifyListeners();
  }

  /// True when the backend definitively rejected the session, as opposed to
  /// being unreachable. `statusCode == 0` marks a transport failure.
  static bool _isAuthRejection(ApiException e) {
    if (e.statusCode == 401 || e.statusCode == 403) return true;
    return const {
      'unauthenticated',
      'unauthorized',
      'invalid_token',
      'token_expired',
      'session_expired',
      'auth_required',
    }.contains(e.error);
  }
}
