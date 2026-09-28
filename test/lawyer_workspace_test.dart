import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_bh_client/models/lead.dart';
import 'package:lawyers_bh_client/models/legal_case.dart';
import 'package:lawyers_bh_client/models/lawyer_profile.dart';
import 'package:lawyers_bh_client/models/user.dart';
import 'package:lawyers_bh_client/services/messages_service.dart';
import 'package:lawyers_bh_client/widgets/pro_badge.dart';

void main() {
  group('role-based routing', () {
    test('a lawyer lands in the professional workspace', () {
      final user = AppUser(id: 1, phone: '+97339000001', role: 'lawyer');
      expect(user.isProfessional, isTrue);
    });

    test('a client lands in the consumer workspace', () {
      final user = AppUser(id: 2, phone: '+97339000002', role: 'client');
      expect(user.isProfessional, isFalse);
    });

    test('a firm manager is professional even though the primary role differs', () {
      // `/auth/me` can grant extra roles; `role` stays the primary one.
      final user = AppUser(
        id: 3,
        phone: '+97339000003',
        role: 'client',
        roles: ['client', 'law_firm_manager'],
      );
      expect(user.isProfessional, isTrue);
    });

    test('permissions are read from the identity payload', () {
      final user = AppUser(
        id: 1,
        phone: '+97339000001',
        role: 'lawyer',
        permissions: ['leads.view', 'cases.view'],
      );
      expect(user.can('leads.view'), isTrue);
      expect(user.can('payments.refund'), isFalse);
    });

    test('parses the identity shape returned by GET /auth/me', () {
      final user = AppUser.fromJson({
        'id': 1,
        'uuid': 'e1be62c1-cfeb-4cef-ac40-e3b5fa9a6fe2',
        'phone': '+97339000001',
        'name': 'Ahmed Al Mansoori',
        'role': 'lawyer',
        'roles': ['lawyer'],
        'permissions': ['leads.view'],
        'is_verified': true,
        'preferred_language': 'ar',
        'avatar_path': null,
      });
      expect(user.id, 1);
      expect(user.isProfessional, isTrue);
      expect(user.isVerified, isTrue);
      expect(user.initials, 'AA');
    });
  });

  group('LawyerProfile parsing', () {
    // Shape captured from the live GET /lawyer/profile response.
    test('parses the profile row with its related collections', () {
      final profile = LawyerProfile.fromJson({
        'id': 1,
        'professional_name': 'Ahmed Al Mansoori',
        'experience_years': 14,
        'consultation_fee': '35.00',
        'currency': 'BHD',
        'city': 'Manama',
        'rating': '4.8',
        'reviews_count': 27,
        'completed_cases_count': 61,
        'accepts_online': 1,
        'accepts_inperson': 1,
        'verification_status': 'verified',
        'profile_status': 'published',
        'languages': '["ar","en"]',
        'specializations': [
          {'id': 3, 'name_ar': 'القانون التجاري', 'is_primary': 1, 'years_experience': 14},
        ],
        'availability': [
          {
            'weekday': 0,
            'start_time': '09:00:00',
            'end_time': '17:00:00',
            'slot_duration_minutes': 30,
            'consultation_type': 'any',
          },
        ],
        'verification': [
          {'to_status': 'verified', 'notes': null, 'created_at': '2026-09-01 10:00:00'},
        ],
      });

      expect(profile.isVerified, isTrue);
      expect(profile.isPublished, isTrue);
      expect(profile.experienceYears, 14);
      expect(profile.consultationFee, 35);
      expect(profile.rating, 4.8);
      // `languages` arrives as a JSON-encoded string, not a real array.
      expect(profile.languages, ['ar', 'en']);
      expect(profile.specializations.single.nameAr, 'القانون التجاري');
      expect(profile.specializations.single.isPrimary, isTrue);
      expect(profile.availability.single.weekdayName, 'الأحد');
      expect(profile.availability.single.range, '09:00:00 – 17:00:00');
      expect(profile.verification.single.toStatus, 'verified');
    });

    test('survives missing optional fields', () {
      final profile = LawyerProfile.fromJson({'id': 7, 'professional_name': 'X'});
      expect(profile.experienceYears, 0);
      expect(profile.consultationFee, 0);
      expect(profile.languages, isEmpty);
      expect(profile.isVerified, isFalse);
    });
  });

  group('Lead parsing', () {
    test('parses the lead shape returned by GET /leads', () {
      final lead = Lead.fromJson({
        'id': 2,
        'uuid': 'b88b53d1-baf9-11f1-bc05-e62b4b6e49f9',
        'reference': 'LEAD-TEST-1',
        'subject': 'استشارة تجارية حول عقد توريد',
        'status': 'new',
        'priority': 'high',
        'source': 'app',
        'contact_name': 'شركة الخليج التجارية',
        'contact_phone': '+97339000099',
        'estimated_value': '150.00',
        'currency': 'BHD',
        'follow_up_at': null,
        'converted_at': null,
        'converted_case_id': null,
        'created_at': '2026-09-28 01:00:00',
      });

      expect(lead.isOpen, isTrue);
      expect(lead.isConverted, isFalse);
      expect(lead.estimatedValue, 150);
      expect(lead.priority, 'high');
    });

    test('a converted lead is no longer open', () {
      final lead = Lead.fromJson({
        'id': 3,
        'subject': 'x',
        'status': 'converted',
        'converted_case_id': 9,
      });
      expect(lead.isOpen, isFalse);
      expect(lead.isConverted, isTrue);
    });

    test('reads the activity shape returned by GET /leads/{id}', () {
      // The endpoint selects `a.notes AS ...` style fields; the model accepts
      // both the server's `notes` and the column's `body`.
      final activity = LeadActivity.fromJson({
        'id': 5,
        'activity_type': 'call',
        'notes': 'اتصال أولي',
        'created_at': '2026-09-28 01:10:00',
        'actor_name': 'Ahmed Al Mansoori',
      });
      expect(activity.activityType, 'call');
      expect(activity.summary, 'اتصال أولي');
      expect(activity.authorName, 'Ahmed Al Mansoori');
    });
  });

  group('case workspace parsing', () {
    test('parses a case with its counters', () {
      final c = LegalCase.fromJson({
        'id': 4,
        'title': 'نزاع تجاري',
        'status': 'active',
        'priority': 'high',
        'lawyer_id': 1,
        'lawyer_name': 'Ahmed Al Mansoori',
        'client_name': 'شركة الخليج التجارية',
        'agreed_fee': '500.00',
        'currency': 'BHD',
        'hearings_count': 2,
        'open_tasks': 3,
      });
      expect(c.agreedFee, 500);
      expect(c.hearingsCount, 2);
      expect(c.openTasks, 3);
      expect(c.clientName, 'شركة الخليج التجارية');
    });

    test('parses a task and reads its completion state', () {
      final t = CaseTask.fromJson({'id': 1, 'title': 'إعداد المذكرة', 'status': 'completed'});
      expect(t.isDone, isTrue);
    });

    test('parses a note and reads its visibility', () {
      final internal = CaseNote.fromJson({'id': 1, 'visibility': 'internal', 'body': 'x'});
      final shared = CaseNote.fromJson({'id': 2, 'visibility': 'client_visible', 'body': 'y'});
      expect(internal.isInternal, isTrue);
      expect(shared.isInternal, isFalse);
    });
  });

  group('messages parsing', () {
    test('parses the conversation shape returned by GET /conversations', () {
      final conversation = Conversation.fromJson({
        'id': 7,
        'conversation_type': 'case',
        'subject': 'قضية تجارية',
        'case_id': 12,
        'last_message_preview': 'شكرًا',
        'messages_count': '3',
      });
      expect(conversation.id, 7);
      expect(conversation.type, 'case');
      expect(conversation.caseId, 12);
      expect(conversation.messagesCount, 3);
    });

    test('a conversation without a case reads as null case_id', () {
      final conversation = Conversation.fromJson({
        'id': 8,
        'conversation_type': 'client_lawyer',
        'case_id': null,
      });
      expect(conversation.caseId, isNull);
      expect(conversation.type, 'client_lawyer');
    });

    test('parses the message shape returned by GET /conversations/{id}/messages', () {
      final message = Message.fromJson({
        'id': 21,
        'body': 'تم رفع المستند',
        'sender_user_id': 4,
        'sender_name': 'أحمد المنصوري',
        'created_at': '2026-09-28 10:00:00',
      });
      expect(message.id, 21);
      expect(message.body, 'تم رفع المستند');
      expect(message.senderUserId, 4);
      expect(message.senderName, 'أحمد المنصوري');
    });
  });

  group('status mappings', () {

    test('maps lead stages to Arabic labels', () {
      expect(ProBadge.leadStatus('new').$1, 'جديد');
      expect(ProBadge.leadStatus('won').$1, 'مكتسب');
      expect(ProBadge.leadStatus('lost').$1, 'خسارة');
    });

    test('maps case states to Arabic labels', () {
      expect(ProBadge.caseStatus('active').$1, 'نشطة');
      expect(ProBadge.caseStatus('closed').$1, 'مغلقة');
    });

    test('maps priorities, defaulting to normal', () {
      expect(ProBadge.priorityOf('urgent').$1, 'عاجل');
      expect(ProBadge.priorityOf('').$1, 'عادي');
    });
  });
}
