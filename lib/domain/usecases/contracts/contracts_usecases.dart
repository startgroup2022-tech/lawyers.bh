import 'package:lawyers_bh/domain/entities/contract.dart';
import 'package:lawyers_bh/domain/repositories/repositories.dart';

class GetContractsUseCase {
  final ContractsRepository _repository;

  GetContractsUseCase(this._repository);

  Future<List<Contract>> call({ContractStatus? status, int page = 1, int limit = 20}) {
    return _repository.getContracts(status: status, page: page, limit: limit);
  }
}

class GetContractDetailsUseCase {
  final ContractsRepository _repository;

  GetContractDetailsUseCase(this._repository);

  Future<Contract> call(String id) {
    return _repository.getContractDetails(id);
  }
}

class CreateContractUseCase {
  final ContractsRepository _repository;

  CreateContractUseCase(this._repository);

  Future<Contract> call({
    required String lawyerId,
    required ContractType type,
    required double amount,
    String? description,
  }) {
    return _repository.createContract(
      lawyerId: lawyerId,
      type: type,
      amount: amount,
      description: description,
    );
  }
}

class SignContractUseCase {
  final ContractsRepository _repository;

  SignContractUseCase(this._repository);

  Future<Contract> call(String id, String signatureData) {
    return _repository.signContract(id, signatureData);
  }
}

class CancelContractUseCase {
  final ContractsRepository _repository;

  CancelContractUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.cancelContract(id);
  }
}

class GetContractDocumentUrlUseCase {
  final ContractsRepository _repository;

  GetContractDocumentUrlUseCase(this._repository);

  Future<String> call(String id) {
    return _repository.getContractDocumentUrl(id);
  }
}

class GetSignedContractUrlUseCase {
  final ContractsRepository _repository;

  GetSignedContractUrlUseCase(this._repository);

  Future<String> call(String id) {
    return _repository.getSignedContractUrl(id);
  }
}