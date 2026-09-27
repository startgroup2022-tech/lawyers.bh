import 'package:lawyers_bh/domain/entities/user.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';
import 'package:lawyers_bh/domain/entities/case.dart';
import 'package:lawyers_bh/domain/entities/contract.dart';
import 'package:lawyers_bh/domain/entities/payment.dart';
import 'package:lawyers_bh/domain/entities/notification.dart';
import 'package:lawyers_bh/domain/entities/appointment.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String fullName,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<User> refreshToken();
  Future<void> forgotPassword(String email);
  Future<void> verifyOtp({required String email, required String code});
  Future<User> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> changePassword({required String current, required String newPassword});
  Future<void> enableBiometric(bool enabled);
}

abstract class LawyersRepository {
  Future<List<Lawyer>> getLawyers({LawyerFilter? filter});
  Future<Lawyer> getLawyerDetails(String id);
  Future<List<Lawyer>> searchLawyers(String query, {LawyerFilter? filter});
  Future<List<Lawyer>> getRecommendedLawyers({int limit = 10});
  Future<List<Lawyer>> getLawyersBySpecialty(String specialty, {int limit = 20});
  Future<void> toggleFavorite(String lawyerId);
  Future<List<Lawyer>> getFavoriteLawyers();
}

abstract class CasesRepository {
  Future<List<Case>> getCases({CaseStatus? status, int page = 1, int limit = 20});
  Future<Case> getCaseDetails(String id);
  Future<Case> createCase({
    required String title,
    required String description,
    required String lawyerId,
  });
  Future<void> updateCaseStatus(String id, CaseStatus status);
  Future<void> addDocument(String caseId, CaseDocument document);
  Future<void> deleteDocument(String caseId, String documentId);
}

abstract class ContractsRepository {
  Future<List<Contract>> getContracts({ContractStatus? status, int page = 1, int limit = 20});
  Future<Contract> getContractDetails(String id);
  Future<Contract> createContract({
    required String lawyerId,
    required ContractType type,
    required double amount,
    String? description,
  });
  Future<Contract> signContract(String id, String signatureData);
  Future<void> cancelContract(String id);
  Future<String> getContractDocumentUrl(String id);
  Future<String> getSignedContractUrl(String id);
}

abstract class PaymentsRepository {
  Future<Payment> processPayment({
    required String contractId,
    required PaymentMethod method,
    required double amount,
  });
  Future<Payment> getPaymentDetails(String id);
  Future<List<Payment>> getPayments({PaymentStatus? status, int page = 1, int limit = 20});
  Future<void> refundPayment(String id);
}

abstract class NotificationsRepository {
  Future<List<Notification>> getNotifications({bool unreadOnly = false, int page = 1, int limit = 20});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}