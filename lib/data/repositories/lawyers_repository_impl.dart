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
      final query = <String, dynamic>{};
      if (filter != null) {
        if (filter.specialty != null) query['specialty'] = filter.specialty;
        if (filter.location != null) query['location'] = filter.location;
        if (filter.minRating != null) query['min_rating'] = filter.minRating;
        if (filter.maxFee != null) query['max_fee'] = filter.maxFee;
        if (filter.minExperience != null) query['min_experience'] = filter.minExperience;
        if (filter.consultationTypes != null && filter.consultationTypes!.isNotEmpty) {
          query['consultation_types'] = filter.consultationTypes!.map((e) => e.name).join(',');
        }
        if (filter.badges != null && filter.badges!.isNotEmpty) {
          query['badges'] = filter.badges!.map((e) => e.name).join(',');
        }
        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          query['search'] = filter.searchQuery;
        }
        query['page'] = filter.page;
        query['limit'] = filter.limit;
      }

      final response = await _remoteDataSource.getLawyers(query: query);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Lawyer> getLawyerDetails(String id) async {
    try {
      final model = await _remoteDataSource.getLawyerDetails(id);
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> searchLawyers(String query, {LawyerFilter? filter}) async {
    try {
      final response = await _remoteDataSource.searchLawyers(query, filters: filter?.toJson());
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> getRecommendedLawyers({int limit = 10}) async {
    try {
      final response = await _remoteDataSource.getRecommendedLawyers(limit: limit);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> getLawyersBySpecialty(String specialty, {int limit = 20}) async {
    try {
      final response = await _remoteDataSource.getLawyersBySpecialty(specialty, limit: limit);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> toggleFavorite(String lawyerId) async {
    try {
      await _remoteDataSource.toggleFavorite(lawyerId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Lawyer>> getFavoriteLawyers() async {
    try {
      final response = await _remoteDataSource.getFavoriteLawyers();
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }
}