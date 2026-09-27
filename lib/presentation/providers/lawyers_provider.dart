import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/get_lawyers_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/get_lawyer_details_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/search_lawyers_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/get_recommended_lawyers_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/get_lawyers_by_specialty_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/toggle_favorite_lawyer_usecase.dart';
import 'package:lawyers_bh/domain/usecases/lawyers/get_favorite_lawyers_usecase.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class LawyersState {
  final List<Lawyer> lawyers;
  final List<Lawyer> recommendedLawyers;
  final Lawyer? selectedLawyer;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final LawyerFilter? currentFilter;

  const LawyersState({
    this.lawyers = const [],
    this.recommendedLawyers = const [],
    this.selectedLawyer,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.currentFilter,
  });

  LawyersState copyWith({
    List<Lawyer>? lawyers,
    List<Lawyer>? recommendedLawyers,
    Lawyer? selectedLawyer,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    LawyerFilter? currentFilter,
  }) {
    return LawyersState(
      lawyers: lawyers ?? this.lawyers,
      recommendedLawyers: recommendedLawyers ?? this.recommendedLawyers,
      selectedLawyer: selectedLawyer ?? this.selectedLawyer,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class LawyersProvider extends StateNotifier<LawyersState> {
  final GetLawyersUseCase _getLawyersUseCase;
  final GetLawyerDetailsUseCase _getLawyerDetailsUseCase;
  final SearchLawyersUseCase _searchLawyersUseCase;
  final GetRecommendedLawyersUseCase _getRecommendedLawyersUseCase;
  final GetLawyersBySpecialtyUseCase _getLawyersBySpecialtyUseCase;
  final ToggleFavoriteLawyerUseCase _toggleFavoriteLawyerUseCase;
  final GetFavoriteLawyersUseCase _getFavoriteLawyersUseCase;

  LawyersProvider({
    required GetLawyersUseCase getLawyersUseCase,
    required GetLawyerDetailsUseCase getLawyerDetailsUseCase,
    required SearchLawyersUseCase searchLawyersUseCase,
    required GetRecommendedLawyersUseCase getRecommendedLawyersUseCase,
    required GetLawyersBySpecialtyUseCase getLawyersBySpecialtyUseCase,
    required ToggleFavoriteLawyerUseCase toggleFavoriteLawyerUseCase,
    required GetFavoriteLawyersUseCase getFavoriteLawyersUseCase,
  })  : _getLawyersUseCase = getLawyersUseCase,
        _getLawyerDetailsUseCase = getLawyerDetailsUseCase,
        _searchLawyersUseCase = searchLawyersUseCase,
        _getRecommendedLawyersUseCase = getRecommendedLawyersUseCase,
        _getLawyersBySpecialtyUseCase = getLawyersBySpecialtyUseCase,
        _toggleFavoriteLawyerUseCase = toggleFavoriteLawyerUseCase,
        _getFavoriteLawyersUseCase = getFavoriteLawyersUseCase,
        super(const LawyersState());

  Future<void> loadLawyers({LawyerFilter? filter, bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1, hasMore: true);
    } else if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final currentFilter = filter ?? state.currentFilter ?? const LawyerFilter(page: 1);
      final page = refresh ? 1 : state.currentPage;
      final filterWithPage = currentFilter.copyWith(page: page);

      final lawyers = await _getLawyersUseCase(filter: filterWithPage);

      if (refresh) {
        state = state.copyWith(
          lawyers: lawyers,
          currentPage: 1,
          hasMore: lawyers.length >= filterWithPage.limit,
          isLoading: false,
          currentFilter: filterWithPage,
        );
      } else {
        state = state.copyWith(
          lawyers: [...state.lawyers, ...lawyers],
          currentPage: page,
          hasMore: lawyers.length >= filterWithPage.limit,
          isLoadingMore: false,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> loadRecommendedLawyers({int limit = 10}) async {
    try {
      final lawyers = await _getRecommendedLawyersUseCase(limit: limit);
      state = state.copyWith(recommendedLawyers: lawyers);
    } catch (_) {}
  }

  Future<void> loadLawyerDetails(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lawyer = await _getLawyerDetailsUseCase(id);
      state = state.copyWith(selectedLawyer: lawyer, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> searchLawyers(String query, {LawyerFilter? filter}) async {
    state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    try {
      final lawyers = await _searchLawyersUseCase(query, filter: filter ?? const LawyerFilter());
      state = state.copyWith(
        lawyers: lawyers,
        currentPage: 1,
        hasMore: false,
        isLoading: false,
        currentFilter: (filter ?? const LawyerFilter()).copyWith(searchQuery: query),
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> loadBySpecialty(String specialty, {int limit = 20}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lawyers = await _getLawyersBySpecialtyUseCase(specialty, limit: limit);
      state = state.copyWith(lawyers: lawyers, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> toggleFavorite(String lawyerId) async {
    try {
      await _toggleFavoriteLawyerUseCase(lawyerId);
      final updatedLawyers = state.lawyers.map((lawyer) {
        if (lawyer.id == lawyerId) {
          // Toggle favorite status would need to be tracked in the entity
          return lawyer;
        }
        return lawyer;
      }).toList();
      state = state.copyWith(lawyers: updatedLawyers);
    } catch (_) {}
  }

  Future<void> loadFavorites() async {
    try {
      final lawyers = await _getFavoriteLawyersUseCase();
      state = state.copyWith(lawyers: lawyers);
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelection() {
    state = state.copyWith(selectedLawyer: null);
  }
}