import 'package:lawyers_bh/data/datasources/remote/contracts_remote_datasource.dart';
import 'package:lawyers_bh/domain/repositories/contracts_repository.dart';
import 'package:lawyers_bh/domain/entities/contract.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  final ContractsRemoteDataSource _remoteDataSource;

  ContractsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Contract>> getContracts({ContractStatus? status, int page = 1, int limit = 20}) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) {
        query['status'] = status.name;
      }

      final response = await _remoteDataSource.getContracts(query: query);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Contract> getContractDetails(String id) async {
    try {
      final model = await _remoteDataSource.getContractDetails(id);
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Contract> createContract({
    required String lawyerId,
    required ContractType type,
    required double amount,
    String? description,
  }) async {
    try {
      final model = await _remoteDataSource.createContract(
        CreateContractRequestModel(
          lawyerId: lawyerId,
          type: type.name,
          amount: amount,
          description: description,
        ),
      );
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Contract> signContract(String id, String signatureData) async {
    try {
      final model = await _remoteDataSource.signContract(
        id,
        SignContractRequestModel(signatureData: signatureData),
      );
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> cancelContract(String id) async {
    try {
      await _remoteDataSource.cancelContract(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<String> getContractDocumentUrl(String id) async {
    try {
      return await _remoteDataSource.getContractDocumentUrl(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<String> getSignedContractUrl(String id) async {
    try {
      return await _remoteDataSource.getSignedContractUrl(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }
}