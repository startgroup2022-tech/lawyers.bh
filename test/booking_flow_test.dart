import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/models/appointment.dart';
import 'package:lawyers_bh_client/models/lawyer.dart';
import 'package:lawyers_bh_client/models/user.dart';
import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/screens/booking_screen.dart';
import 'package:lawyers_bh_client/screens/my_appointments_screen.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// Booking-flow coverage against the real services and screens, with only the
/// socket stubbed. It asserts the app speaks the shipped mobile contract:
/// the paid-method catalogue, the lawyer's free slots, booking, and the
/// client's appointment list with its cancel rules.

http.Response _json(Object payload, [int status = 200]) => http.Response(
      jsonEncode(payload),
      status,
      headers: {'content-type': 'application/json'},
    );

AppUser _client() => AppUser(id: '00000000-0000-0000-0000-000000000001', phone: '+97339000001', kind: AccountKind.client);

AppState _app(MockClient client) =>
    AppState(apiClient: ApiClient(httpClient: client));

final _lawyer = Lawyer(
  id: 'e449b317-cfb6-4128-ad37-cba515a23e85',
  name: 'محمد ناجي',
  status: 'approved',
  subscriptionType: 'lawyer',
);

const _methods = {
  'ok': true,
  'methods': [
    {'id': 'm1', 'code': 'phone', 'nameAr': 'مكالمة صوتية', 'nameEn': 'Voice Call', 'price': 30, 'currencyCode': 'BHD', 'durationMinutes': 15, 'iconKey': 'phone', 'sortOrder': 20},
    {'id': 'm2', 'code': 'video', 'nameAr': 'مكالمة فيديو', 'nameEn': 'Video Call', 'price': 35, 'currencyCode': 'BHD', 'durationMinutes': 20, 'iconKey': 'video', 'sortOrder': 30},
  ],
};

const _slots = {
  'ok': true,
  'lawyerId': 'e449b317-cfb6-4128-ad37-cba515a23e85',
  'date': '2026-09-28',
  'weekday': 1,
  'slots': [
    {'start': '09:00:00', 'end': '09:30:00', 'consultationType': 'any'},
    {'start': '10:00:00', 'end': '10:30:00', 'consultationType': 'any'},
  ],
};

void main() {
  group('AppointmentsService contract', () {
    test('parses the method catalogue with real prices and durations', () async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((req) async {
        expect(req.url.path, '/api/consultation-methods');
        return _json(_methods);
      }));

      final rows = await app.appointments.consultationMethods();
      expect(rows, hasLength(2));
      final video = rows.firstWhere((r) => r['code'] == 'video');
      expect(video['price'], 35);
      expect(video['durationMinutes'], 20);
    });

    test('parses free slots, trimming seconds from the times', () async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((req) async {
        expect(req.url.path, '/api/mobile/lawyers/${_lawyer.id}/availability');
        expect(req.url.queryParameters['date'], '2026-09-28');
        return _json(_slots);
      }));

      final slots = await app.appointments.availableSlots(
        lawyerId: _lawyer.id,
        date: '2026-09-28',
      );
      expect(slots, hasLength(2));
      expect(slots.first.start, '09:00');
      expect(slots.first.end, '09:30');
    });

    test('books a slot and returns the confirmed appointment', () async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/api/mobile/client-appointments');
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['consultationMethod'], 'video');
        expect(body['startTime'], '09:00');
        expect(body['endTime'], '09:30');
        return _json({
          'ok': true,
          'appointment': {
            'id': 'b1', 'lawyerId': _lawyer.id, 'lawyerName': 'محمد ناجي',
            'date': '2026-09-28', 'startTime': '09:00', 'endTime': '09:30',
            'status': 'booked', 'adminStatus': 'approved',
            'service': 'Video Call', 'durationMinutes': 20,
          },
        }, 201);
      }));
      await app.completeLogin('t', _client());

      final appointment = await app.appointments.book(
        lawyerId: _lawyer.id,
        date: '2026-09-28',
        startTime: '09:00',
        endTime: '09:30',
        consultationMethod: 'video',
      );
      expect(appointment.id, 'b1');
      expect(appointment.status, 'booked');
      expect(appointment.durationMinutes, 20);
    });

    test('a taken slot surfaces the backend conflict code', () async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((_) async => _json({'ok': false, 'error': 'slot_taken'}, 409)));
      await app.completeLogin('t', _client());

      await expectLater(
        app.appointments.book(
          lawyerId: _lawyer.id, date: '2026-09-28',
          startTime: '09:00', endTime: '09:30', consultationMethod: 'video',
        ),
        throwsA(isA<ApiException>().having((e) => e.error, 'error', 'slot_taken')),
      );
    });

    test('cancels through the client-appointments delete route', () async {
      SharedPreferences.setMockInitialValues({});
      String? method;
      String? path;
      final app = _app(MockClient((req) async {
        method = req.method;
        path = req.url.path;
        return _json({'ok': true});
      }));
      await app.completeLogin('t', _client());

      await app.appointments.cancel('b1');
      expect(method, 'DELETE');
      expect(path, '/api/mobile/client-appointments/b1');
    });
  });

  group('ClientAppointment cancel rules', () {
    ClientAppointment from(Map<String, dynamic> extra) => ClientAppointment.fromJson({
          'id': 'b1', 'slotId': 's1', 'lawyerId': 'l1', 'lawyerName': 'ن',
          'date': '2026-09-28', 'startTime': '09:00:00', 'endTime': '09:30:00',
          'status': 'booked', 'adminStatus': 'approved', 'paymentStatus': 'not_required',
          'service': 'Voice Call', 'consultationType': 'phone', 'durationMinutes': 15,
          'createdAt': '2026-09-27T00:00:00Z', ...extra,
        });

    test('an active booking can be cancelled', () {
      expect(from({}).canCancel, isTrue);
    });

    test('a completed booking cannot be cancelled', () {
      expect(from({'adminStatus': 'completed'}).canCancel, isFalse);
    });

    test('an already-cancelled booking cannot be cancelled again', () {
      expect(from({'status': 'cancelled'}).isCancelled, isTrue);
      expect(from({'status': 'cancelled'}).canCancel, isFalse);
      expect(from({'adminStatus': 'rejected'}).isCancelled, isTrue);
    });
  });

  group('MyAppointmentsScreen', () {
    testWidgets('lists upcoming and past appointments from the backend',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((req) async {
        expect(req.url.path, '/api/mobile/client-appointments');
        return _json({
          'ok': true,
          'appointments': [
            {
              'id': 'b1', 'slotId': 's1', 'lawyerId': 'l1', 'lawyerName': 'محمد ناجي',
              'date': '2099-01-01', 'startTime': '09:00:00', 'endTime': '09:30:00',
              'status': 'booked', 'adminStatus': 'approved', 'paymentStatus': 'not_required',
              'service': 'Voice Call', 'consultationType': 'phone', 'durationMinutes': 15,
              'createdAt': '2026-09-27T00:00:00Z',
            },
            {
              'id': 'b2', 'slotId': 's2', 'lawyerId': 'l2', 'lawyerName': 'سارة',
              'date': '2000-01-01', 'startTime': '11:00:00', 'endTime': '11:30:00',
              'status': 'cancelled', 'adminStatus': 'cancelled', 'paymentStatus': 'not_required',
              'service': 'Video Call', 'consultationType': 'video', 'durationMinutes': 20,
              'createdAt': '2026-09-27T00:00:00Z',
            },
          ],
        });
      }));
      await app.completeLogin('t', _client());

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: app,
        child: const MaterialApp(home: MyAppointmentsScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('القادمة'), findsOneWidget);
      expect(find.text('السابقة'), findsOneWidget);
      expect(find.text('محمد ناجي'), findsOneWidget);
      expect(find.text('سارة'), findsOneWidget);
      expect(find.text('ملغى'), findsOneWidget);
      // The cancelled row offers no cancel action; the active one does.
      expect(find.text('إلغاء الموعد'), findsOneWidget);
    });

    testWidgets('an empty account shows the empty state, not a blank list',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((_) async => _json({'ok': true, 'appointments': []})));
      await app.completeLogin('t', _client());

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: app,
        child: const MaterialApp(home: MyAppointmentsScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('لا توجد مواعيد محجوزة بعد'), findsOneWidget);
    });
  });

  group('BookingScreen', () {
    testWidgets('loads real methods, shows free slots and books one',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((req) async {
        if (req.url.path == '/api/consultation-methods') return _json(_methods);
        if (req.url.path.contains('/availability')) return _json(_slots);
        if (req.url.path == '/api/mobile/client-appointments') {
          return _json({
            'ok': true,
            'appointment': {
              'id': 'b9', 'lawyerId': _lawyer.id, 'lawyerName': 'محمد ناجي',
              'date': '2026-09-28', 'startTime': '09:00', 'endTime': '09:30',
              'status': 'booked', 'adminStatus': 'approved',
              'service': 'مكالمة صوتية', 'durationMinutes': 15,
            },
          }, 201);
        }
        return _json({'ok': false, 'error': 'unexpected'}, 404);
      }));
      await app.completeLogin('t', _client());

      tester.view.physicalSize = const Size(1200, 4200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: app,
        child: MaterialApp(home: BookingScreen(lawyer: _lawyer)),
      ));
      await tester.pumpAndSettle();

      // The catalogue's real method names and prices are shown.
      expect(find.text('مكالمة صوتية'), findsOneWidget);
      expect(find.text('مكالمة فيديو'), findsOneWidget);
      expect(find.textContaining('30.000 BHD'), findsOneWidget);

      // The backend's free slots are offered, not derived locally.
      await tester.tap(find.text('09:00'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تأكيد الحجز'));
      await tester.pumpAndSettle();

      expect(find.text('تم تأكيد حجزك'), findsOneWidget);
      expect(find.text('مكالمة صوتية'), findsWidgets);
    });

    testWidgets('a slot conflict is reported and the list refreshes',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = _app(MockClient((req) async {
        if (req.url.path == '/api/consultation-methods') return _json(_methods);
        if (req.url.path.contains('/availability')) return _json(_slots);
        return _json({'ok': false, 'error': 'slot_taken'}, 409);
      }));
      await app.completeLogin('t', _client());

      tester.view.physicalSize = const Size(1200, 4200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: app,
        child: MaterialApp(home: BookingScreen(lawyer: _lawyer)),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('09:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تأكيد الحجز'));
      await tester.pumpAndSettle();

      expect(find.textContaining('لم يعد متاحًا'), findsOneWidget);
      // Still on the booking screen, ready to pick another slot.
      expect(find.text('تأكيد الحجز'), findsOneWidget);
    });
  });
}
