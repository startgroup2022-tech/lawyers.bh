import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, kReleaseMode, TargetPlatform;
import 'package:http/http.dart' as http;

/// Thrown when the backend reports a failure.
class ApiException implements Exception {
  /// Machine-readable code, e.g. `invalid_or_expired_code`.
  final String error;
  final int statusCode;

  /// Human-readable message from the backend, when it sends one.
  final String? message;

  const ApiException(this.error, this.statusCode, {this.message});

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
  /// A release build must always carry a real host: the production API is
  /// injected at build time (Codemagic sets `API_BASE_URL` for release
  /// workflows). `kReleaseMode` without that define would otherwise silently
  /// point at localhost and look "connected" while every call fails, so the
  /// canonical host is used as the release fallback. Debug/profile builds keep
  /// the localhost convenience for day-to-day development.
  ///
  /// Override for a device/emulator build:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
  static const String productionBaseUrl = 'https://api.lawyers.bh';

  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');
    }
    if (kReleaseMode) {
      return productionBaseUrl;
    }
    // Android emulators reach the host through 10.0.2.2, not localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
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

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await _send(() => _http.delete(_uri(path), headers: _headers));
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

  /// Unwraps the canonical `{success, data, message}` envelope, and also
  /// tolerates the legacy `{ok, data}` one.
  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('invalid_server_response', res.statusCode);
    }

    // Canonical envelope: {"success": true, "data": {...}, "message": null}
    // Legacy envelope:   {"ok": true, "data": {...}}
    final bool? success = json['success'] as bool?;
    final bool? ok = json['ok'] as bool?;
    final succeeded = success ?? ok ?? false;

    if (!succeeded) {
      final message = json['message']?.toString();
      final error = json['error']?.toString() ?? _codeFrom(json) ?? message ?? 'unknown_error';
      if (res.statusCode == 401) {
        // 401 means the session is gone; 403 is a permission denial on a valid
        // session and must not log the user out.
        onAuthRejection?.call();
      }
      throw ApiException(error, res.statusCode, message: message);
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is List) return {'items': data};
    return <String, dynamic>{};
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

