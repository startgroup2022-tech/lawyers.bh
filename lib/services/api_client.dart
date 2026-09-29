import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when the backend reports a failure.
class ApiException implements Exception {
  /// Machine-readable code, e.g. `invalid_or_expired_code`.
  final String error;
  final int statusCode;

  /// Human-readable message from the backend, when it sends one.
  final String? message;

  const ApiException(this.error, this.statusCode, {this.message});

  /// The caller asked for a capability the platform API does not expose.
  ///
  /// Used by the parts of the app that map to a booking/CRM model the mobile
  /// API has no endpoints for, so they fail loudly instead of pretending to
  /// have loaded nothing.
  factory ApiException.featureUnavailable([String? message]) =>
      ApiException('feature_not_available', 501, message: message);

  @override
  String toString() => 'ApiException($statusCode): ${message ?? error}';
}

class ApiClient {
  ApiClient({http.Client? httpClient, Duration? requestTimeout})
      : _http = httpClient ?? http.Client(),
        requestTimeout = requestTimeout ?? const Duration(seconds: 20);

  /// The transport. Injectable so tests can drive the real request/parse/state
  /// code against a controlled socket without a live server.
  final http.Client _http;

  /// Backend base URL, without a trailing slash.
  ///
  /// The mobile API is part of the main Lawyers.bh Next.js deployment — the
  /// website, the admin/lawyer portals and this app all read and write the same
  /// database through it. There is no separate API host: `api.lawyers.bh` does
  /// not resolve, which is why release builds pointed at a dead socket and every
  /// screen failed to load.
  ///
  /// Override for a local or device build:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
  static const String productionBaseUrl = 'https://www.lawyers.bh';

  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');
    }
    return productionBaseUrl;
  }

  String? _token;

  void setToken(String? token) => _token = token;

  /// Invoked whenever the backend rejects the session (401). Wiring this to
  /// the app state lets an expired token discovered mid-session drop the user
  /// back to login instead of leaving every screen showing an error.
  void Function()? onAuthRejection;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = query?.map((k, v) => MapEntry(k, '$v'));
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanQuery == null || cleanQuery.isEmpty ? null : cleanQuery,
    );
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _send(() => _http.get(_uri(path, query), headers: _headers));
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    final res = await _send(
      () => _http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? const {})),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final res = await _send(
      () => _http.patch(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await _send(
      () => _http.put(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> delete(String path, {Map<String, dynamic>? body}) async {
    final res = await _send(() => _http.delete(
          _uri(path),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        ));
    return _decode(res);
  }

  /// Hard cap on a single request. Without it a socket that never answers
  /// (dropped connection, wrong host, blocked port) leaves the caller awaiting
  /// forever — which shows up in the UI as a spinner that never stops.
  final Duration requestTimeout;

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(requestTimeout);
    } on TimeoutException {
      throw const ApiException('network_timeout', 0, message: 'انتهت مهلة الاتصال بالخادم');
    } on ApiException {
      rethrow;
    } on http.ClientException {
      // The http package surfaces connection failures (including a refused
      // socket) as ClientException, so this covers "server unreachable".
      throw const ApiException('network_error', 0, message: 'تعذّر الاتصال بالخادم');
    } catch (_) {
      // Any other transport-level failure (DNS, TLS handshake, socket close)
      // must still surface as a typed error so callers clear their loading
      // state instead of awaiting forever.
      throw const ApiException('network_error', 0, message: 'تعذّر الاتصال بالخادم');
    }
  }

  /// Unwraps the Lawyers.bh mobile envelope.
  ///
  /// Every `/api/mobile/*` route answers `{"ok": true, ...payload}` on success
  /// and `{"ok": false, "error": "code"}` on failure. The payload keys sit at
  /// the **top level** — there is no `data` wrapper — so the whole body is
  /// returned and callers read their own keys. The `{success, data, message}`
  /// envelope is still unwrapped if a route returns it.
  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('invalid_server_response', res.statusCode);
    }

    final bool? success = json['success'] as bool?;
    final bool? ok = json['ok'] as bool?;

    if (success == false || ok == false) {
      final message = json['message']?.toString();
      final error = json['error']?.toString() ?? _codeFrom(json) ?? message ?? 'unknown_error';
      if (res.statusCode == 401) {
        // 401 means the session is gone; 403 is a permission denial on a valid
        // session and must not log the user out.
        onAuthRejection?.call();
      }
      throw ApiException(error, res.statusCode, message: message);
    }

    // Canonical `{success, data}` envelope.
    if (success == true) {
      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is List) return {'items': data};
      return <String, dynamic>{};
    }

    // Mobile `{ok, ...payload}` envelope, or a bare object on a 2xx.
    if (ok == true) return json;
    if (res.statusCode >= 200 && res.statusCode < 300) return json;

    throw ApiException(json['error']?.toString() ?? 'unknown_error', res.statusCode);
  }

  /// Pulls a code out of the canonical `errors` block, which the backend may
  /// send as `{"field": ["message"]}` or `{"field": "message"}`.
  String? _codeFrom(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return null;
  }
}

