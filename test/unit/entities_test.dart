import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_bh/domain/entities/user.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';
import 'package:lawyers_bh/domain/entities/case.dart';
import 'package:lawyers_bh/domain/entities/contract.dart';

void main() {
  group('User Entity Tests', () {
    test('User initials should be correct for Arabic names', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        phone: '0501234567',
        fullName: 'أحمد محمد',
        role: UserRole.client,
        status: UserStatus.active,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        darkMode: false,
        preferredLanguage: 'ar',
      );

      expect(user.initials, equals('أح'));
    });

    test('User initials should be correct for English names', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        phone: '0501234567',
        fullName: 'Ahmed Mohammed',
        role: UserRole.client,
        status: UserStatus.active,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        darkMode: false,
        preferredLanguage: 'en',
      );

      expect(user.initials, equals('AM'));
    });

    test('User copyWith should work correctly', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        phone: '0501234567',
        fullName: 'أحمد محمد',
        role: UserRole.client,
        status: UserStatus.active,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        darkMode: false,
        preferredLanguage: 'ar',
      );

      final updated = user.copyWith(fullName: 'محمد أحمد');
      expect(updated.fullName, equals('محمد أحمد'));
      expect(updated.initials, equals('مح'));
    });
  });

  group('Lawyer Entity Tests', () {
    test('Lawyer initials should be correct', () {
      final lawyer = Lawyer(
        id: '1',
        fullName: 'أحمد الحمادي',
        specialty: 'قانون تجاري',
        location: 'المنامة',
        rating: 4.9,
        reviewsCount: 112,
        experienceYears: 15,
        consultationFee: 250,
        badgeText: 'استشارة أولى مجانية',
        badgeType: LawyerBadgeType.freeConsultation,
        tags: ['قانون تجاري', 'عقود'],
        bio: 'محامٍ متخصص...',
        isAvailable: true,
        availableConsultationTypes: [ConsultationType.video, ConsultationType.voice],
        languages: ['العربية', 'الإنجليزية'],
        createdAt: DateTime.now(),
      );

      expect(lawyer.initials, equals('أح'));
      expect(lawyer.formattedFee, equals('250 د.ب'));
      expect(lawyer.formattedExperience, equals('15 سنة خبرة'));
      expect(lawyer.formattedRating, equals('★ 4.9'));
      expect(lawyer.formattedReviews, equals('112 تقييمات'));
    });

    test('Lawyer badge type mapping', () {
      final lawyer = Lawyer(
        id: '1',
        fullName: 'Test',
        specialty: 'Test',
        location: 'Test',
        rating: 5.0,
        reviewsCount: 10,
        experienceYears: 10,
        consultationFee: 100,
        badgeText: 'Available Today',
        badgeType: LawyerBadgeType.availableToday,
        tags: [],
        bio: 'Test',
        isAvailable: true,
        availableConsultationTypes: [ConsultationType.video],
        languages: ['Arabic'],
        createdAt: DateTime.now(),
      );

      expect(lawyer.badgeType, equals(LawyerBadgeType.availableToday));
    });
  });

  group('Case Entity Tests', () {
    test('Case progress calculation', () {
      final timeline = [
        CaseTimelineEvent(id: '1', label: 'Step 1', step: CaseStep.requestReceived, status: TimelineStatus.done),
        CaseTimelineEvent(id: '2', label: 'Step 2', step: CaseStep.lawyerMatched, status: TimelineStatus.done),
        CaseTimelineEvent(id: '3', label: 'Step 3', step: CaseStep.awaitingContract, status: TimelineStatus.active),
        CaseTimelineEvent(id: '4', label: 'Step 4', step: CaseStep.active, status: TimelineStatus.pending),
      ];

      final case_ = Case(
        id: '1',
        title: 'Test Case',
        description: 'Test',
        clientId: '1',
        lawyerId: '1',
        lawyerName: 'Test Lawyer',
        status: CaseStatus.active,
        timeline: timeline,
        documents: [],
        createdAt: DateTime.now(),
      );

      expect(case_.completedStepsCount, equals(2));
      expect(case_.progress, equals(0.5));
      expect(case_.currentStep?.label, equals('Step 3'));
    });
  });

  group('Contract Entity Tests', () {
    test('Contract status helpers', () {
      final contract = Contract(
        id: '1',
        title: 'Test Contract',
        type: ContractType.representation,
        status: ContractStatus.pendingSignature,
        clientId: '1',
        lawyerId: '1',
        lawyerName: 'Test Lawyer',
        clientName: 'Test Client',
        amount: 1000,
        currency: 'BHD',
        createdAt: DateTime.now(),
        signatures: [],
      );

      expect(contract.isPendingSignature, isTrue);
      expect(contract.isActive, isFalse);
      expect(contract.isCompleted, isFalse);
      expect(contract.formattedAmount, equals('1000 BHD'));
    });
  });
}