import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_appearance.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/appearance_service.dart';
import '../services/appointments_service.dart';
import '../services/auth_service.dart';
import '../services/case_service.dart';
import '../services/documents_service.dart';
import '../services/lawyer_auth_service.dart';
import '../services/lawyer_service.dart';
import '../services/lawyers_service.dart';
import '../services/leads_service.dart';
import '../services/messages_service.dart';
import '../services/notifications_service.dart';
import '../services/payments_service.dart';
import '../services/sos_service.dart';

const _tokenPrefsKey = 'auth_token';
const _guestPrefsKey = 'guest_mode';

/// Which door the stored token came through, so a restart restores the session
/// against the right endpoint. A client token is validated by
/// `/api/mobile/client-auth/session`; a lawyer token by
/// `/api/mobile/lawyer/session`. The tokens are not interchangeable.
const _accountKindPrefsKey = 'account_kind';

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
  late final AppearanceService appearance = AppearanceService(api);
  late final LawyerAuthService lawyerAuth = LawyerAuthService(api);
  late final LawyersService lawyers = LawyersService(api);
  late final AppointmentsService appointments = AppointmentsService(api);
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

  /// The admin-configured app background. Starts with the bundled image so the
  /// first frame already shows the global background, then is refreshed from
  /// the backend.
  AppAppearance appAppearance = AppAppearance.demoBackground;

  /// Fetches the background from the backend. Called after bootstrap so the app
  /// has already painted; a failure keeps the current/default value and is
  /// never surfaced as an error, because the background is decoration.
  Future<void> loadAppearance({String countryCode = 'BH'}) async {
    AppAppearance next;
    try {
      next = await appearance.load(countryCode: countryCode);
    } catch (_) {
      // The service already falls back on API failures; this guards the rest
      // (e.g. local storage) so a background refresh can never break startup.
      return;
    }
    if (next == appAppearance) return;
    appAppearance = next;
    notifyListeners();
  }

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
      // Restore against the door the token came through. A client token only
      // validates on the client session route and a lawyer token only on the
      // lawyer one, so reading the kind is what keeps a restart from silently
      // demoting a lawyer to a client.
      final kind = _kindFromPrefs(prefs.getString(_accountKindPrefsKey));
      api.setToken(token);
      try {
        currentUser = await (identityLoader ?? () => _loadIdentity(kind))();
        isGuest = false;
        await prefs.remove(_guestPrefsKey);
        result = BootstrapResult.authenticated;
      } on ApiException catch (e) {
        // Only a definitive auth rejection invalidates the session. A network
        // or server-side failure must not; treat it as a temporary outage and
        // keep the stored token so a retry can restore the session.
        if (_isAuthRejection(e)) {
          await _clearSession(prefs);
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

  Future<AppUser> _loadIdentity(AccountKind kind) =>
      kind == AccountKind.lawyer ? lawyerAuth.session() : auth.session();

  static AccountKind _kindFromPrefs(String? value) =>
      value == AccountKind.lawyer.name ? AccountKind.lawyer : AccountKind.client;

  /// Drops every trace of the current session: token, account kind and guest
  /// flag. Used on logout, on a rejected session, and before switching accounts,
  /// so no role or identity can survive into the next sign-in.
  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.remove(_tokenPrefsKey);
    await prefs.remove(_accountKindPrefsKey);
    await prefs.remove(_guestPrefsKey);
    api.setToken(null);
    currentUser = null;
    isGuest = false;
  }

  Future<void> completeLogin(String token, AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenPrefsKey, token);
    await prefs.setString(_accountKindPrefsKey, user.kind.name);
    api.setToken(token);
    isGuest = false;
    sessionExpired = false;

    // The login/session response already carries the full profile, so no
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
    // Drop any previous session first: switching to guest must not leave a
    // token or a role behind for the next sign-in to inherit.
    await _clearSession(prefs);
    await prefs.setBool(_guestPrefsKey, true);
    isGuest = true;
    sessionExpired = false;
    notifyListeners();
  }

  Future<void> logout() async {
    // Best-effort server-side teardown before clearing locally, against the
    // door the session came through: a client session is revoked with
    // DELETE /api/mobile/client-auth/session; a lawyer token is stateless and
    // has no logout route, so clearing it locally is the whole operation. A
    // failed call must not leave the user stuck signed in.
    if (currentUser?.kind != AccountKind.lawyer) {
      try {
        await auth.logout();
      } catch (_) {
        // Ignore: clearing local state below is what matters.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
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
    // (e.g. a wrong code, which the login screen reports itself).
    if (currentUser == null) return;
    // Clear the in-memory session synchronously so no screen can keep using a
    // token the backend has already rejected; the stored copy follows.
    sessionExpired = true;
    api.setToken(null);
    currentUser = null;
    isGuest = false;
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.remove(_tokenPrefsKey);
      await prefs.remove(_accountKindPrefsKey);
      await prefs.remove(_guestPrefsKey);
    });
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
