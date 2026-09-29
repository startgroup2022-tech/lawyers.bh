@TestOn('vm')
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:lawyers_bh_client/models/lawyer.dart';
import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/screens/home_screen.dart';
import 'package:lawyers_bh_client/screens/lawyer_profile_screen.dart';
import 'package:lawyers_bh_client/screens/login_otp_screen.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// Widget coverage for the UX pass: the home section grid, the lawyer profile
/// presentation, and the password-recovery entry on the sign-in form.
///
/// These drive the real screens through the real [ApiClient] with only the
/// socket stubbed, matching the existing test style. They assert presentation
/// and navigation only — never invented data.

http.Response _lawyersOk() => http.Response(
      jsonEncode({
        'ok': true,
        'countryCode': 'BH',
        'data': [
          {
            'id': 'e449b317-cfb6-4128-ad37-cba515a23e85',
            'countryCode': 'BH',
            'fullNameAr': 'محمد ناجي',
            'fullNameEn': 'MOHAMED NAJI',
            'phone': '66616105',
            'email': 'lawyer@example.com',
            'status': 'approved',
            'subscriptionType': 'lawyer',
          },
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

AppState _state() =>
    AppState(apiClient: ApiClient(httpClient: MockClient((_) async => _lawyersOk())));

Widget _wrap(AppState app, Widget child) => ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(home: child),
    );

void main() {
  group('home screen layout', () {
    testWidgets('renders main sections under the banner, with honest gaps',
        (tester) async {
      // A tall logical window so the lazy ListView builds every section below
      // the banner without needing to scroll.
      tester.view.physicalSize = const Size(1200, 3400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
          _wrap(_state(), Scaffold(body: HomeScreen(onBrowseAll: () {}))));
      // Explicit pumps: the banner auto-advances on a timer, so pumpAndSettle
      // would never settle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Sections sit directly under the banner.
      expect(find.text('الأقسام الرئيسية'), findsOneWidget);
      expect(find.text('المحامون'), findsOneWidget);
      expect(find.text('الاستشارات القانونية'), findsOneWidget);
      expect(find.text('الاستشارة الصوتية'), findsOneWidget);
      expect(find.text('حجز موعد'), findsOneWidget);
      expect(find.text('الخدمات القانونية'), findsOneWidget);

      // Capabilities without a backend route are marked, not faked.
      expect(find.text('قريبًا'), findsWidgets);

      // Real directory data still renders below the sections.
      expect(find.text('محامون موصى بهم'), findsOneWidget);
      expect(find.text('محمد ناجي'), findsOneWidget);
    });

    testWidgets('an unavailable section explains itself instead of navigating',
        (tester) async {
      await tester.pumpWidget(
          _wrap(_state(), Scaffold(body: HomeScreen(onBrowseAll: () {}))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('الاستشارة الصوتية'));
      await tester.pump();
      expect(find.textContaining('غير متاح في التطبيق'), findsOneWidget);
    });
  });

  group('lawyer profile', () {
    final lawyer = Lawyer(
      id: 'e449b317-cfb6-4128-ad37-cba515a23e85',
      name: 'محمد ناجي',
      nameEn: 'MOHAMED NAJI',
      phone: '66616105',
      email: 'lawyer@example.com',
      status: 'approved',
      subscriptionType: 'lawyer',
    );

    testWidgets('shows the real published fields and the two action buttons',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
          MaterialApp(home: LawyerProfileScreen(lawyer: lawyer)));
      await tester.pumpAndSettle();

      expect(find.text('محمد ناجي'), findsOneWidget);
      expect(find.text('MOHAMED NAJI'), findsOneWidget);
      expect(find.text('66616105'), findsOneWidget);
      expect(find.text('lawyer@example.com'), findsOneWidget);
      expect(find.text('استشارة صوتية'), findsWidgets);
      expect(find.text('حجز موعد'), findsWidgets);
      // Services exist but are honestly tagged as not yet available.
      expect(find.text('قريبًا'), findsWidgets);
    });

    testWidgets('a lawyer without contact data shows an empty note, not blanks',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: LawyerProfileScreen(
              lawyer: Lawyer(id: 'x', name: 'بلا بيانات'))));
      await tester.pumpAndSettle();

      expect(find.textContaining('لا توجد بيانات تواصل'), findsOneWidget);
    });
  });

  group('password recovery on the sign-in form', () {
    testWidgets('offers a recovery entry that switches the form', (tester) async {
      await tester.pumpWidget(_wrap(_state(), const LoginOtpScreen()));
      await tester.pumpAndSettle();

      expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
      // Guest entry is a browsing affordance, present on plain sign-in.
      expect(find.text('الدخول كزائر'), findsOneWidget);

      await tester.tap(find.text('نسيت كلمة المرور؟'));
      await tester.pumpAndSettle();

      expect(find.textContaining('استعادة كلمة المرور'), findsOneWidget);
      expect(find.text('كلمة المرور الجديدة'), findsOneWidget);
      expect(find.text('إرسال رمز التحقق'), findsOneWidget);
      // Recovery is not a browsing surface.
      expect(find.text('الدخول كزائر'), findsNothing);
    });
  });
}
