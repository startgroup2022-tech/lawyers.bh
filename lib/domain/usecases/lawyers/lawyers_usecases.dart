import 'package:lawyers_bh/domain/entities/lawyer.dart';
import 'package:lawyers_bh/domain/repositories/repositories.dart';

class GetLawyersUseCase {
  final LawyersRepository _repository;

  GetLawyersUseCase(this._repository);

  Future<List<Lawyer>> call({LawyerFilter? filter}) {
    return _repository.getLawyers(filter: filter);
  }
}

class GetLawyerDetailsUseCase {
  final LawyersRepository _repository;

  GetLawyerDetailsUseCase(this._repository);

  Future<Lawyer> call(String id) {
    return _repository.getLawyerDetails(id);
  }
}

class SearchLawyersUseCase {
  final LawyersRepository _repository;

  SearchLawyersUseCase(this._repository);

  Future<List<Lawyer>> call(String query, {LawyerFilter? filter}) {
    return _repository.searchLawyers(query, filter: filter);
  }
}

class GetRecommendedLawyersUseCase {
  final LawyersRepository _repository;

  GetRecommendedLawyersUseCase(this._repository);

  Future<List<Lawyer>> call({int limit = 10}) {
    return _repository.getRecommendedLawyers(limit: limit);
  }
}

class GetLawyersBySpecialtyUseCase {
  final LawyersRepository _repository;

  GetLawyersBySpecialtyUseCase(this._repository);

  Future<List<Lawyer>> call(String specialty, {int limit = 20}) {
    return _repository.getLawyersBySpecialty(specialty, limit: limit);
  }
}

class ToggleFavoriteLawyerUseCase {
  final LawyersRepository _repository;

  ToggleFavoriteLawyerUseCase(this._repository);

  Future<void> call(String lawyerId) {
    return _repository.toggleFavorite(lawyerId);
  }
}

class GetFavoriteLawyersUseCase {
  final LawyersRepository _repository;

  GetFavoriteLawyersUseCase(this._repository);

  Future<List<Lawyer>> call() {
    return _repository.getFavoriteLawyers();
  }
}