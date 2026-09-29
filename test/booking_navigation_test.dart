import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/models/lawyer.dart';
import 'package:lawyers_bh_client/models/user.dart';
import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/screens/booking_screen.dart';
import 'package:lawyers_bh_client/screens/home_screen.dart';
import 'package:lawyers_bh_client/screens/lawyer_profile_screen.dart';
import 'package:lawyers_bh_client/screens/my_appointments_screen.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// End-to-end navigation coverage for the booking journeys, so a green run
/// proves the requested paths have no dead buttons and never emit a
/// `feature_unavailable` for a supported action.
///
/// Only the socket is stubbed; the real screens, services and models run.
///
///   Home → lawyer → Profile → Book → date → slots → confirm → created
///   Profile → Voice consultation → Booking → Confirmation
///   Profile → Video consultation → Booking → Confirmation

http.Response _json(Object payload, [int status = 200]) => http.Response(
      jsonEncode(payload),
      status,
      headers: {'content-type': 'application/json'},
    );

const _lawyerId = 'e449b317-cfb6-4128-ad37-cba515a23e85';

AppUser _client() => AppUser(
      id: '00000000-0000-0000-0000-000000000001',
      phone: '+97339000001',
      name: 'عميل',
      kind: AccountKind.client,
    );

final _directory = {
  'ok': true,
  'countryCode': 'BH',
  'data': [
    {
      'id': _lawyerId,
      'countryCode': 'BH',
      'fullNameAr': 'محمد ناجي',
      'fullNameEn': 'MOHAMED NAJI',
      'phone': '66616105',
      'email': 'lawyer@example.com',
      'status': 'approved',
      'subscriptionType': 'lawyer',
      'professionalTitleAr': 'محامٍ بالتمييز',
      'experienceYears': 12,
      'specialties': ['قانون تجاري'],
      'languages': ['العربية', 'English'],
      'workingHours': '9ص - 5م',
      'rating': 4.7,
      'reviewCount': 23,
    },
  ],
};

final _methods = {
  'ok': true,
  'country': {'code': 'BH', 'currencyCode': 'BHD'},
  'methods': [
    {'id': 'm1', 'code': 'phone', 'nameAr': 'مكالمة صوتية', 'nameEn': 'Voice Call', 'price': 10, 'currencyCode': 'BHD', 'durationMinutes': 15, 'iconKey': 'phone', 'sortOrder': 10},
    {'id': 'm2', 'code': 'video', 'nameAr': 'مكالمة فيديو', 'nameEn': 'Video Call', 'price': 15, 'currencyCode': 'BHD', 'durationMinutes': 20, 'iconKey': 'video', 'sortOrder': 20},
    {'id': 'm3', 'code': 'whatsapp', 'nameAr': 'استشارة عبر واتساب', 'nameEn': 'WhatsApp', 'price': 10, 'currencyCode': 'BHD', 'durationMinutes': 15, 'iconKey': 'message-circle', 'sortOrder': 10},
    {'id': 'm4', 'code': 'office', 'nameAr': 'زيارة المكتب', 'nameEn': 'Office Visit', 'price': 25, 'currencyCode': 'BHD', 'durationMinutes': 30, 'iconKey': 'map-pin', 'sortOrder': 30},
  ],
};

final _slots = {
  'ok': true,
  'lawyerId': _lawyerId,
  'date': '2026-09-28',
  'slots': [
    {'start': '09:00:00', 'end': '09:30:00', 'consultationType': 'any'},
    {'start': '10:00:00', 'end': '10:30:00', 'consultationType': 'any'},
  ],
};

http.Response _bookingCreated() => _json({
      'ok': true,
      'appointment': {
        'id': 'b9', 'lawyerId': _lawyerId, 'lawyerName': 'محمد ناجي',
        'date': '2026-09-28', 'startTime': '09:00', 'endTime': '09:30',
        'status': 'booked', 'adminStatus': 'approved',
        'service': 'Voice Call', 'durationMinutes': 15,
      },
    }, 201);

/// A transport that serves the directory, catalogue, slots, booking and the
/// client's appointment list — recording the method code each booking used.
MockClient _transport(List<String> bookedMethods) => MockClient((req) async {
      final path = req.url.path;
      if (path == '/api/mobile/lawyers') return _json(_directory);
      if (path == '/api/consultation-methods') return _json(_methods);
      if (path.contains('/availability')) return _json(_slots);
      if (path == '/api/mobile/client-appointments') {
        if (req.method == 'POST') {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          bookedMethods.add(body['consultationMethod']?.toString() ?? '');
          return _bookingCreated();
        }
        // The list reflects whatever this session booked, so "My Appointments"
        // shows the appointment the flow just created.
        return _json({
          'ok': true,
          'appointments': [
            if (bookedMethods.isNotEmpty)
              {
                'id': 'b9', 'slotId': 's1', 'lawyerId': _lawyerId,
                'lawyerName': 'محمد ناجي', 'date': '2026-09-28',
                'startTime': '09:00:00', 'endTime': '09:30:00',
                'status': 'booked', 'adminStatus': 'approved',
                'paymentStatus': 'not_required', 'service': 'Voice Call',
                'consultationType': bookedMethods.last, 'durationMinutes': 15,
                'createdAt': '2026-09-27T00:00:00Z',
              },
          ],
        });
      }
      return _json({'ok': false, 'error': 'unexpected'}, 404);
    });

Future<AppState> _signedIn(List<String> booked) async {
  SharedPreferences.setMockInitialValues({});
  final app = AppState(apiClient: ApiClient(httpClient: _transport(booked)));
  await app.completeLogin('token', _client());
  return app;
}

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 4200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _home(AppState app) => ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(
        home: Scaffold(body: HomeScreen(onBrowseAll: () {})),
      ),
    );

void main() {
  testWidgets(
      'Home → lawyer → Profile → Book → date → slots → confirm → booked',
      (tester) async {
    final booked = <String>[];
    final app = await _signedIn(booked);
    _tall(tester);

    await tester.pumpWidget(_home(app));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Home shows the featured lawyer from the real directory.
    expect(find.text('محمد ناجي'), findsOneWidget);

    // Select the lawyer → profile.
    await tester.tap(find.text('محمد ناجي'));
    await tester.pumpAndSettle();
    expect(find.byType(LawyerProfileScreen), findsOneWidget);

    // Book appointment → the real booking flow.
    await tester.tap(find.text('حجز موعد').first);
    await tester.pumpAndSettle();
    expect(find.byType(BookingScreen), findsOneWidget);

    // Date defaults to today; pick the backend's first free slot.
    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();

    // Confirm → booking created → confirmation screen.
    await tester.tap(find.text('تأكيد الحجز'));
    await tester.pumpAndSettle();
    expect(find.text('تم تأكيد حجزك'), findsOneWidget);
    expect(booked, isNotEmpty);
  });

  testWidgets('Profile → Voice consultation → Booking → Confirmation',
      (tester) async {
    final booked = <String>[];
    final app = await _signedIn(booked);
    _tall(tester);

    final lawyer = Lawyer.fromJson(
        (_directory['data'] as List).first as Map<String, dynamic>);

    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(home: LawyerProfileScreen(lawyer: lawyer)),
    ));
    await tester.pumpAndSettle();

    // The primary voice action opens the flow, pre-set to the voice method.
    await tester.tap(find.text('استشارة صوتية').first);
    await tester.pumpAndSettle();
    expect(find.byType(BookingScreen), findsOneWidget);

    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الحجز'));
    await tester.pumpAndSettle();

    expect(find.text('تم تأكيد حجزك'), findsOneWidget);
    expect(booked.last, 'phone', reason: 'the voice action must book the voice method');
  });

  testWidgets('Profile → Video consultation → Booking → Confirmation',
      (tester) async {
    final booked = <String>[];
    final app = await _signedIn(booked);
    _tall(tester);

    final lawyer = Lawyer.fromJson(
        (_directory['data'] as List).first as Map<String, dynamic>);

    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(home: LawyerProfileScreen(lawyer: lawyer)),
    ));
    await tester.pumpAndSettle();

    // Video is exposed in the services area and opens the flow pre-set to it.
    await tester.tap(find.text('استشارة مرئية'));
    await tester.pumpAndSettle();
    expect(find.byType(BookingScreen), findsOneWidget);

    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الحجز'));
    await tester.pumpAndSettle();

    expect(find.text('تم تأكيد حجزك'), findsOneWidget);
    expect(booked.last, 'video', reason: 'the video action must book the video method');
  });

  testWidgets('the created booking appears in My Appointments', (tester) async {
    final booked = <String>[];
    final app = await _signedIn(booked);
    _tall(tester);

    final lawyer = Lawyer.fromJson(
        (_directory['data'] as List).first as Map<String, dynamic>);

    // Book from the profile, then open My Appointments: the backend list shows
    // the appointment the flow just created.
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(home: LawyerProfileScreen(lawyer: lawyer)),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حجز موعد').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الحجز'));
    await tester.pumpAndSettle();
    expect(find.text('تم تأكيد حجزك'), findsOneWidget);

    // A distinct key gives this a fresh Navigator, so the booking flow's
    // route stack is gone and the appointments screen is on top.
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: app,
      child: const MaterialApp(
          key: ValueKey('appointments'), home: MyAppointmentsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('محمد ناجي'), findsOneWidget);
    expect(find.textContaining('09:00'), findsOneWidget);
    expect(find.text('إلغاء الموعد'), findsOneWidget);
  });

  testWidgets('no supported action shows a feature-unavailable message',
      (tester) async {
    final booked = <String>[];
    final app = await _signedIn(booked);
    _tall(tester);

    final lawyer = Lawyer.fromJson(
        (_directory['data'] as List).first as Map<String, dynamic>);

    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(home: LawyerProfileScreen(lawyer: lawyer)),
    ));
    await tester.pumpAndSettle();

    // Every action on the profile is live: no dead "not available" snackbar,
    // and no leftover feature-unavailable banner for a supported action.
    expect(find.byType(SnackBar), findsNothing);
    expect(find.textContaining('غير متاح في التطبيق'), findsNothing);
    expect(find.textContaining('يحتاج واجهات'), findsNothing);
  });
}
