import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/domain/usecases/contracts/get_contracts_usecase.dart';
import 'package:lawyers_bh/domain/usecases/contracts/get_contract_details_usecase.dart';
import 'package:lawyers_bh/domain/usecases/contracts/create_contract_usecase.dart';
import 'package:lawyers_bh/domain/usecases/contracts/sign_contract_usecase.dart';
import 'package:lawyers_bh/domain/usecases/contracts/cancel_contract_usecase.dart';
import 'package:lawyers_bh/domain/entities/contract.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class ContractsState {
  final List<Contract> contracts;
  final Contract? selectedContract;
  final bool isLoading;
  final String? error;

  const ContractsState({
    this.contracts = const [],
    this.selectedContract,
    this.isLoading = false,
    this.error,
  });

  ContractsState copyWith({
    List<Contract>? contracts,
    Contract? selectedContract,
    bool? isLoading,
    String? error,
  }) {
    return ContractsState(
      contracts: contracts ?? this.contracts,
      selectedContract: selectedContract ?? this.selectedContract,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ContractsProvider extends StateNotifier<ContractsState> {
  final GetContractsUseCase _getContractsUseCase;
  final GetContractDetailsUseCase _getContractDetailsUseCase;
  final CreateContractUseCase _createContractUseCase;
  final SignContractUseCase _signContractUseCase;
  final CancelContractUseCase _cancelContractUseCase;

  ContractsProvider({
    required GetContractsUseCase getContractsUseCase,
    required GetContractDetailsUseCase getContractDetailsUseCase,
    required CreateContractUseCase createContractUseCase,
    required SignContractUseCase signContractUseCase,
    required CancelContractUseCase cancelContractUseCase,
  })  : _getContractsUseCase = getContractsUseCase,
        _getContractDetailsUseCase = getContractDetailsUseCase,
        _createContractUseCase = createContractUseCase,
        _signContractUseCase = signContractUseCase,
        _cancelContractUseCase = cancelContractUseCase,
        super(const ContractsState());

  Future<void> loadContracts({ContractStatus? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contracts = await _getContractsUseCase(status: status);
      state = state.copyWith(contracts: contracts, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> loadContractDetails(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contract = await _getContractDetailsUseCase(id);
      state = state.copyWith(selectedContract: contract, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<Contract> createContract({
    required String lawyerId,
    required ContractType type,
    required double amount,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contract = await _createContractUseCase(
        lawyerId: lawyerId,
        type: type,
        amount: amount,
        description: description,
      );
      state = state.copyWith(contracts: [contract, ...state.contracts], isLoading: false);
      return contract;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
      rethrow;
    }
  }

  Future<void> signContract(String id, String signatureData) async {
    try {
      final contract = await _signContractUseCase(id, signatureData);
      final updatedContracts = state.contracts.map((c) {
        if (c.id == id) return contract;
        return c;
      }).toList();
      state = state.copyWith(contracts: updatedContracts, selectedContract: contract);
    } catch (_) {}
  }

  Future<void> cancelContract(String id) async {
    try {
      await _cancelContractUseCase(id);
      final updatedContracts = state.contracts.map((c) {
        if (c.id == id) return c.copyWith(status: ContractStatus.cancelled);
        return c;
      }).toList();
      state = state.copyWith(contracts: updatedContracts);
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}