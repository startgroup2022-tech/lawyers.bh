import 'package:equatable/equatable.dart';

enum CaseStatus { pending, active, completed, cancelled, onHold }
enum CaseStep { requestReceived, lawyerMatched, awaitingContract, active, completed }

class Case extends Equatable {
  final String id;
  final String title;
  final String description;
  final String clientId;
  final String lawyerId;
  final String lawyerName;
  final CaseStatus status;
  final List<CaseTimelineEvent> timeline;
  final List<CaseDocument> documents;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const Case({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    required this.lawyerId,
    required this.lawyerName,
    required this.status,
    required this.timeline,
    required this.documents,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  CaseTimelineEvent? get currentStep {
    try {
      return timeline.firstWhere((e) => e.status == TimelineStatus.active);
    } catch (_) {
      return timeline.isNotEmpty ? timeline.last : null;
    }
  }

  int get completedStepsCount => timeline.where((e) => e.status == TimelineStatus.done).length;

  double get progress => timeline.isEmpty ? 0 : completedStepsCount / timeline.length;

  @override
  List<Object?> get props => [
    id, title, description, clientId, lawyerId, lawyerName, status,
    timeline, documents, createdAt, updatedAt, completedAt,
  ];
}

class CaseTimelineEvent extends Equatable {
  final String id;
  final String label;
  final CaseStep step;
  final TimelineStatus status;
  final DateTime? completedAt;
  final String? notes;

  const CaseTimelineEvent({
    required this.id,
    required this.label,
    required this.step,
    required this.status,
    this.completedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, label, step, status, completedAt, notes];
}

enum TimelineStatus { pending, active, done }

class CaseDocument extends Equatable {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime uploadedAt;
  final String uploadedBy;

  const CaseDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [id, name, url, type, size, uploadedAt, uploadedBy];
}