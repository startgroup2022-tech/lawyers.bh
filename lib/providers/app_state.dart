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

  /// True when the signed-in account should get the lawyer workspace.
  bool get isProfessional => currentUser?.isProfessional ?? false;

  bool can(String permission) => currentUser?.can(permission) ?? false;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenPrefsKey);
    if (token != null) {
      api.setToken(token);
      try {
        currentUser = await auth.me();
      } catch (_) {
        await prefs.remove(_tokenPrefsKey);
        api.setToken(null);
      }
    }
    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> completeLogin(String token, AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenPrefsKey, token);
    api.setToken(token);

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenPrefsKey);
    api.setToken(null);
    currentUser = null;
    notifyListeners();
  }

  bool get isLoggedIn => currentUser != null;
}
