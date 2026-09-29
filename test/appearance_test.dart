@TestOn('vm')
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/models/app_appearance.dart';
import 'package:lawyers_bh_client/services/api_client.dart';
import 'package:lawyers_bh_client/services/appearance_service.dart';
import 'package:lawyers_bh_client/widgets/app_background.dart';

/// Coverage for the admin-controlled app background on the client side.
///
/// Drives the real [AppearanceService] through the real [ApiClient] with only
/// the socket stubbed, so the request, parsing and caching paths that ship are
/// the ones under test.
http.Response _ok(Map<String, dynamic> payload) => http.Response(
      jsonEncode({'ok': true, ...payload}),
      200,
      headers: {'content-type': 'application/json'},
    );

http.Response _fail(String error, int status) => http.Response(
      jsonEncode({'ok': false, 'error': error}),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AppAppearance model', () {
    test('parses percentages into 0..1 fractions and keeps the image URL', () {
      final appearance = AppAppearance.fromJson({
        'backgroundUrl': 'https://cdn.example/bg.webp',
        'backgroundOpacity': 60,
        'overlayOpacity': 25,
        'backgroundColor': '#082B67',
      });

      expect(appearance.backgroundUrl, 'https://cdn.example/bg.webp');
      expect(appearance.imageOpacity, closeTo(0.6, 1e-9));
      expect(appearance.overlayOpacity, closeTo(0.25, 1e-9));
      expect(appearance.backgroundColor, const Color(0xFF082B67));
      expect(appearance.hasImage, isTrue);
    });

    test('treats an empty URL as no background and clamps bad percentages', () {
      final appearance = AppAppearance.fromJson({
        'backgroundUrl': '',
        'backgroundOpacity': 250,
        'overlayOpacity': -10,
        'backgroundColor': 'not-a-colour',
      });

      expect(appearance.backgroundUrl, isNull);
      expect(appearance.imageOpacity, 1.0);
      expect(appearance.overlayOpacity, 0.0);
      expect(appearance.backgroundColor, isNull);
      expect(appearance.hasImage, isFalse);
      expect(appearance.hasBackground, isFalse);
    });

    test('round-trips through JSON for the offline cache', () {
      const original = AppAppearance(
        backgroundUrl: 'https://cdn.example/bg.webp',
        imageOpacity: 0.4,
        overlayOpacity: 0.2,
        backgroundColor: Color(0xFF123456),
      );
      final restored = AppAppearance.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );
      expect(restored, original);
    });
  });

  group('AppearanceService', () {
    test('reads the appearance record and caches it', () async {
      final service = AppearanceService(ApiClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/mobile/appearance');
          expect(request.url.queryParameters['countryCode'], 'BH');
          return _ok({
            'countryCode': 'BH',
            'appearance': {
              'backgroundUrl': 'https://cdn.example/bg.webp',
              'backgroundOpacity': 80,
              'overlayOpacity': 10,
              'backgroundColor': '#F5F4F1',
            },
          });
        }),
      ));

      final appearance = await service.load();
      expect(appearance.imageOpacity, closeTo(0.8, 1e-9));
      expect(appearance.backgroundColor, const Color(0xFFF5F4F1));

      // The cache is what a later offline start reads.
      final cached = await service.cached();
      expect(cached, appearance);
    });

    test('falls back to the default on a backend error, never throwing', () async {
      final service = AppearanceService(ApiClient(
        httpClient: MockClient((_) async => _fail('server_error', 500)),
      ));

      final appearance = await service.load();
      expect(appearance, AppAppearance.defaults);
    });

    test('serves the last cached value when the backend is unreachable', () async {
      final online = AppearanceService(ApiClient(
        httpClient: MockClient((_) async => _ok({
              'appearance': {'backgroundUrl': 'https://cdn.example/bg.webp', 'backgroundOpacity': 100},
            })),
      ));
      await online.load();

      final offline = AppearanceService(ApiClient(
        httpClient: MockClient((_) async => _fail('network_error', 0)),
      ));
      final appearance = await offline.load();
      expect(appearance.backgroundUrl, 'https://cdn.example/bg.webp');
    });
  });

  group('AppBackground', () {
    Widget wrap(AppAppearance appearance) => MaterialApp(
          home: AppBackground(
            appearance: appearance,
            child: const Text('content'),
          ),
        );

    testWidgets('renders no image layer for the default appearance', (tester) async {
      await tester.pumpWidget(wrap(AppAppearance.defaults));
      expect(find.byType(Image), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('renders the image at the configured opacity', (tester) async {
      await tester.pumpWidget(wrap(const AppAppearance(
        backgroundUrl: 'https://cdn.example/bg.webp',
        imageOpacity: 0.5,
      )));

      final opacity = tester.widget<Opacity>(find.ancestor(
        of: find.byType(Image),
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, closeTo(0.5, 1e-9));
    });

    testWidgets('keeps content visible when the image fails to load', (tester) async {
      await tester.pumpWidget(wrap(const AppAppearance(
        backgroundUrl: 'https://cdn.example/bg.webp',
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('content'), findsOneWidget);
    });
  });
}
