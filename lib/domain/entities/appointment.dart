import 'package:equatable/equatable.dart';

enum AppointmentStatus { requested, confirmed, cancelled, completed, rescheduled }
enum ConsultationType { video, voice, inPerson }

class Appointment extends Equatable {
  final String id;
  final String clientId;
  final String lawyerId;
  final String lawyerName;
  final String lawyerSpecialty;
  final DateTime scheduledAt;
  final int durationMinutes;
  final ConsultationType type;
  final AppointmentStatus status;
  final String? meetingLink;
  final String? location;
  final String? notes;
  final double fee;
  final String currency;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancellationReason;

  const Appointment({
    required this.id,
    required this.clientId,
    required this.lawyerId,
    required this.lawyerName,
    required this.lawyerSpecialty,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.type,
    required this.status,
    this.meetingLink,
    this.location,
    this.notes,
    required this.fee,
    required this.currency,
    required this.createdAt,
    this.updatedAt,
    this.cancellationReason,
  });

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now()) && 
      (status == AppointmentStatus.requested || status == AppointmentStatus.confirmed);
  bool get isPast => scheduledAt.isBefore(DateTime.now()) || status == AppointmentStatus.completed;
  bool get canCancel => status == AppointmentStatus.requested || status == AppointmentStatus.confirmed;
  bool get canJoin => status == AppointmentStatus.confirmed && 
      scheduledAt.difference(DateTime.now()).inMinutes <= 15 &&
      scheduledAt.isAfter(DateTime.now());

  String get formattedDateTime => 
      '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year} ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';

  String get formattedFee => '$fee $currency';

  @override
  List<Object?> get props => [
    id, clientId, lawyerId, lawyerName, lawyerSpecialty, scheduledAt,
    durationMinutes, type, status, meetingLink, location, notes,
    fee, currency, createdAt, updatedAt, cancellationReason,
  ];
}