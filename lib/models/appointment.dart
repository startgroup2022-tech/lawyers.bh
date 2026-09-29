/// One free appointment slot the backend returned for a lawyer on a date.
///
/// Slots are computed server-side (`GET /api/mobile/lawyers/{id}/availability`)
/// from the lawyer's published windows, their blocked dates and what is already
/// booked. The app only displays them — it never derives times itself.
class AvailableSlot {
  final String start;
  final String end;

  /// The window's consultation type, e.g. `any` or a method code.
  final String consultationType;

  AvailableSlot({
    required this.start,
    required this.end,
    required this.consultationType,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
        start: '${json['start']}'.split(':').take(2).join(':'),
        end: '${json['end']}'.split(':').take(2).join(':'),
        consultationType: json['consultationType']?.toString() ?? 'any',
      );
}

/// A booking the signed-in client owns, from `GET /api/mobile/client-appointments`.
class ClientAppointment {
  final String id;
  final String slotId;
  final String lawyerId;
  final String lawyerName;
  final String date;
  final String startTime;
  final String endTime;

  /// Slot lifecycle: `booked`, `confirmed` or `cancelled`.
  final String status;

  /// The booking's own status: `approved`, `completed`, `cancelled`, …
  final String adminStatus;
  final String paymentStatus;
  final String service;
  final String consultationType;
  final int durationMinutes;
  final String? videoProvider;
  final String createdAt;

  ClientAppointment({
    required this.id,
    required this.slotId,
    required this.lawyerId,
    required this.lawyerName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.adminStatus,
    required this.paymentStatus,
    required this.service,
    required this.consultationType,
    required this.durationMinutes,
    this.videoProvider,
    required this.createdAt,
  });

  bool get isCancelled =>
      status == 'cancelled' || adminStatus == 'cancelled' || adminStatus == 'rejected';

  bool get isCompleted => adminStatus == 'completed';

  /// Whether the backend will accept a cancel: a completed or already-cancelled
  /// booking is refused, matching `cancelAppointment`.
  bool get canCancel => !isCancelled && !isCompleted;

  String get timeRange => '$startTime – $endTime';

  factory ClientAppointment.fromJson(Map<String, dynamic> json) => ClientAppointment(
        id: json['id']?.toString() ?? '',
        slotId: json['slotId']?.toString() ?? '',
        lawyerId: json['lawyerId']?.toString() ?? '',
        lawyerName: json['lawyerName']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        startTime: '${json['startTime']}'.split(':').take(2).join(':'),
        endTime: '${json['endTime']}'.split(':').take(2).join(':'),
        status: json['status']?.toString() ?? 'booked',
        adminStatus: json['adminStatus']?.toString() ?? '',
        paymentStatus: json['paymentStatus']?.toString() ?? '',
        service: json['service']?.toString() ?? '',
        consultationType: json['consultationType']?.toString() ?? '',
        durationMinutes: int.tryParse('${json['durationMinutes']}') ?? 0,
        videoProvider: json['videoProvider']?.toString(),
        createdAt: json['createdAt']?.toString() ?? '',
      );
}
