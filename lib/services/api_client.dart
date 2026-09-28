import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:http/http.dart' as http;

/// Thrown when the backend reports a failure.
class ApiException implements Exception {
  /// Machine-readable code, e.g. `invalid_or_expired_code`.
  final String error;
  final int statusCode;

  /// Human-readable message from the backend, when it sends one.
  final String? message;

  ApiException(this.error, this.statusCode, {this.message});

  @override
  String toString() => 'ApiException($statusCode): ${message ?? error}';
}

class ApiClient {
  /// Backend base URL, without a trailing slash.
  ///
  /// Override at build time so a device build can point at a LAN address:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');
    }
    // Android emulators reach the host through 10.0.2.2, not localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  String? _token;

  void setToken(String? token) => _token = token;

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
    final res = await _send(() => http.get(_uri(path, query), headers: _headers));
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    final res = await _send(
      () => http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? const {})),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final res = await _send(
      () => http.patch(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await _send(
      () => http.put(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await _send(() => http.delete(_uri(path), headers: _headers));
    return _decode(res);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw ApiException('network_timeout', 0, message: 'انتهت مهلة الاتصال بالخادم');
    } on http.ClientException {
      // The http package surfaces connection failures (including a refused
      // socket) as ClientException, so this covers "server unreachable".
      throw ApiException('network_error', 0, message: 'تعذّر الاتصال بالخادم');
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

