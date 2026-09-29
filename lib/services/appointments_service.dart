import '../models/appointment.dart';
import 'api_client.dart';

/// The client-facing booking API.
///
/// Every route here already exists on the platform:
///
///   GET    /api/consultation-methods?countryCode=BH   the paid method catalogue
///   GET    /api/mobile/lawyers/{id}/availability       the lawyer's free slots
///   GET    /api/mobile/client-appointments             the client's appointments
///   POST   /api/mobile/client-appointments             book a slot
///   DELETE /api/mobile/client-appointments/{id}        cancel a booking
///
/// Availability is always computed by the backend; the app never derives slots.
class AppointmentsService {
  final ApiClient api;
  AppointmentsService(this.api);

  /// The paid consultation methods for a country.
  Future<List<Map<String, dynamic>>> consultationMethods({
    String countryCode = 'BH',
  }) async {
    final data = await api.get('/api/consultation-methods', query: {'countryCode': countryCode});
    final list = data['methods'];
    if (list is! List) return const [];
    return list.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  /// The free slots for a lawyer on a `YYYY-MM-DD` date.
  Future<List<AvailableSlot>> availableSlots({
    required String lawyerId,
    required String date,
    String countryCode = 'BH',
  }) async {
    final data = await api.get(
      '/api/mobile/lawyers/$lawyerId/availability',
      query: {'countryCode': countryCode, 'date': date},
    );
    final list = data['slots'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AvailableSlot.fromJson)
        .toList(growable: false);
  }

  /// The signed-in client's appointments, newest first.
  Future<List<ClientAppointment>> list() async {
    final data = await api.get('/api/mobile/client-appointments');
    final list = data['appointments'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ClientAppointment.fromJson)
        .toList(growable: false);
  }

  /// Books a slot. The backend re-checks availability inside the booking
  /// transaction, so a `slot_taken`/`slot_unavailable` error is authoritative.
  Future<ClientAppointment> book({
    required String lawyerId,
    required String date,
    required String startTime,
    required String endTime,
    required String consultationMethod,
    String countryCode = 'BH',
    String? notes,
  }) async {
    final data = await api.post('/api/mobile/client-appointments', {
      'countryCode': countryCode,
      'lawyerId': lawyerId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'consultationMethod': consultationMethod,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    final appointment = data['appointment'];
    if (appointment is Map<String, dynamic>) return ClientAppointment.fromJson(appointment);
    throw const ApiException('invalid_server_response', 200);
  }

  /// Cancels one of the client's own appointments.
  Future<void> cancel(String bookingId, {String? reason}) async {
    await api.delete(
      '/api/mobile/client-appointments/$bookingId',
      body: reason == null || reason.trim().isEmpty ? null : {'reason': reason.trim()},
    );
  }
}
