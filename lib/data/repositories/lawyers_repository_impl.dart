import 'package:lawyers_bh/data/datasources/remote/lawyers_remote_datasource.dart';
import 'package:lawyers_bh/domain/repositories/lawyers_repository.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class LawyersRepositoryImpl implements LawyersRepository {
  final LawyersRemoteDataSource _remoteDataSource;

  LawyersRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Lawyer>> getLawyers({LawyerFilter? filter}) async {
    try {
      final countryCode = filter?.location ?? 'BH';
      final response = await _remoteDataSource.getLawyersMobile(countryCode: countryCode);
      return response.data
          .where((e) => !e.isReviewAccount)
          .map((e) => e.toEntity())
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Lawyer> getLawyerDetails(String id) async {
    try {
      final response = await _remoteDataSource.getLawyerDetails(id);
      return response.data.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> searchLawyers(String query, {LawyerFilter? filter}) async {
    try {
      final countryCode = filter?.location ?? 'BH';
      final response = await _remoteDataSource.searchLawyers(query, countryCode: countryCode);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> getRecommendedLawyers({int limit = 10}) async {
    try {
      final response = await _remoteDataSource.getLawyersMobile(countryCode: 'BH');
      return response.data
          .where((e) => !e.isReviewAccount)
          .take(limit)
          .map((e) => e.toEntity())
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> getLawyersBySpecialty(String specialty, {int limit = 20}) async {
    try {
      final response = await _remoteDataSource.getLawyersMobile(countryCode: 'BH');
      return response.data
          .where((e) => !e.isReviewAccount && e.subscriptionType == specialty)
          .take(limit)
          .map((e) => e.toEntity())
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> toggleFavorite(String lawyerId) async {
    try {
      // Not available in mobile API yet
      throw UnsupportedError('toggleFavorite not available in mobile API');
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> getFavoriteLawyers() async {
    try {
      // Not available in mobile API yet
      return [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }
}