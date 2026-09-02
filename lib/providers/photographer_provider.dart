import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photographer_model.dart';
import '../models/package_model.dart';
import '../models/review_model.dart';
import '../models/filter_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../services/filter_engine_service.dart';
import 'location_provider.dart';

final filterEngineServiceProvider = Provider<FilterEngineService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return FilterEngineService(supabaseService: supabase);
});

// Active filter provider
final activeFilterProvider = StateProvider<FilterModel>((ref) {
  return const FilterModel();
});

// Top rated photographers provider
final topRatedPhotographersProvider =
    FutureProvider<List<PhotographerModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getPhotographers(minRating: 4.8, limit: 6);
});

// Single photographer family provider
final photographerDetailProvider =
    FutureProvider.family<PhotographerModel?, String>((ref, id) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getPhotographerById(id);
});

// Photographer packages family
final photographerPackagesProvider =
    FutureProvider.family<List<PackageModel>, String>((ref, photographerId) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getPackages(photographerId);
});

// Photographer reviews family
final photographerReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, photographerId) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getReviews(photographerId);
});

// Paginated Photographers State
class PhotographersState {
  final List<PhotographerModel> photographers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const PhotographersState({
    this.photographers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PhotographersState copyWith({
    List<PhotographerModel>? photographers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return PhotographersState(
      photographers: photographers ?? this.photographers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class PhotographersNotifier extends StateNotifier<PhotographersState> {
  final FilterEngineService _filterEngineService;
  final Ref _ref;

  PhotographersNotifier(this._filterEngineService, this._ref)
      : super(const PhotographersState()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final filter = _ref.read(activeFilterProvider);
      final locationState = _ref.read(locationProvider);

      // Execute Filter & Matching Engine pipeline via Supabase
      final results = await _filterEngineService.executeFilterPipeline(
        filter: filter,
        userLat: locationState.latitude,
        userLon: locationState.longitude,
        limit: 15,
      );

      state = state.copyWith(
        photographers: results,
        hasMore: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
  }

  void refresh() {
    fetchInitial();
  }
}

final paginatedPhotographersProvider =
    StateNotifierProvider<PhotographersNotifier, PhotographersState>((ref) {
  final engine = ref.watch(filterEngineServiceProvider);
  return PhotographersNotifier(engine, ref);
});
