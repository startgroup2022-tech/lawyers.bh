import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/domain/usecases/payments/process_payment_usecase.dart';
import 'package:lawyers_bh/domain/usecases/payments/get_payments_usecase.dart';
import 'package:lawyers_bh/domain/usecases/payments/get_payment_details_usecase.dart';
import 'package:lawyers_bh/domain/usecases/payments/refund_payment_usecase.dart';
import 'package:lawyers_bh/domain/entities/payment.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class PaymentsState {
  final List<Payment> payments;
  final Payment? selectedPayment;
  final bool isLoading;
  final bool isProcessing;
  final String? error;

  const PaymentsState({
    this.payments = const [],
    this.selectedPayment,
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
  });

  PaymentsState copyWith({
    List<Payment>? payments,
    Payment? selectedPayment,
    bool? isLoading,
    bool? isProcessing,
    String? error,
  }) {
    return PaymentsState(
      payments: payments ?? this.payments,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}

class PaymentsProvider extends StateNotifier<PaymentsState> {
  final ProcessPaymentUseCase _processPaymentUseCase;
  final GetPaymentsUseCase _getPaymentsUseCase;
  final GetPaymentDetailsUseCase _getPaymentDetailsUseCase;
  final RefundPaymentUseCase _refundPaymentUseCase;

  PaymentsProvider({
    required ProcessPaymentUseCase processPaymentUseCase,
    required GetPaymentsUseCase getPaymentsUseCase,
    required GetPaymentDetailsUseCase getPaymentDetailsUseCase,
    required RefundPaymentUseCase refundPaymentUseCase,
  })  : _processPaymentUseCase = processPaymentUseCase,
        _getPaymentsUseCase = getPaymentsUseCase,
        _getPaymentDetailsUseCase = getPaymentDetailsUseCase,
        _refundPaymentUseCase = refundPaymentUseCase,
        super(const PaymentsState());

  Future<Payment> processPayment({
    required String contractId,
    required PaymentMethod method,
    required double amount,
  }) async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final payment = await _processPaymentUseCase(
        contractId: contractId,
        method: method,
        amount: amount,
      );
      state = state.copyWith(
        payments: [payment, ...state.payments],
        isProcessing: false,
        selectedPayment: payment,
      );
      return payment;
    } on AppException catch (e) {
      state = state.copyWith(isProcessing: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: 'حدث خطأ غير متوقع');
      rethrow;
    }
  }

  Future<void> loadPayments({PaymentStatus? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payments = await _getPaymentsUseCase(status: status);
      state = state.copyWith(payments: payments, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> loadPaymentDetails(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payment = await _getPaymentDetailsUseCase(id);
      state = state.copyWith(selectedPayment: payment, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> refundPayment(String id) async {
    try {
      await _refundPaymentUseCase(id);
      final updatedPayments = state.payments.map((p) {
        if (p.id == id) return p.copyWith(status: PaymentStatus.refunded);
        return p;
      }).toList();
      state = state.copyWith(payments: updatedPayments);
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}