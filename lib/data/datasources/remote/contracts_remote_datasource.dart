import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/contract_models.dart';

abstract class ContractsRemoteDataSource {
  Future<ContractsListResponseModel> getContracts({Map<String, dynamic>? query});
  Future<ContractModel> getContractDetails(String id);
  Future<ContractModel> createContract(CreateContractRequestModel request);
  Future<ContractModel> signContract(String id, SignContractRequestModel request);
  Future<void> cancelContract(String id);
  Future<String> getContractDocumentUrl(String id);
  Future<String> getSignedContractUrl(String id);
}

class ContractsRemoteDataSourceImpl implements ContractsRemoteDataSource {
  final ApiClient _apiClient;

  ContractsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ContractsListResponseModel> getContracts({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get('/contracts', queryParameters: query);
    return ContractsListResponseModel.fromJson(response.data);
  }

  @override
  Future<ContractModel> getContractDetails(String id) async {
    final response = await _apiClient.get('/contracts/$id');
    return ContractModel.fromJson(response.data);
  }

  @override
  Future<ContractModel> createContract(CreateContractRequestModel request) async {
    final response = await _apiClient.post('/contracts', data: request.toJson());
    return ContractModel.fromJson(response.data);
  }

  @override
  Future<ContractModel> signContract(String id, SignContractRequestModel request) async {
    final response = await _apiClient.post('/contracts/$id/sign', data: request.toJson());
    return ContractModel.fromJson(response.data);
  }

  @override
  Future<void> cancelContract(String id) async {
    await _apiClient.delete('/contracts/$id');
  }

  @override
  Future<String> getContractDocumentUrl(String id) async {
    final response = await _apiClient.get('/contracts/$id/document');
    return response.data['url'] as String;
  }

  @override
  Future<String> getSignedContractUrl(String id) async {
    final response = await _apiClient.get('/contracts/$id/signed-document');
    return response.data['url'] as String;
  }
}