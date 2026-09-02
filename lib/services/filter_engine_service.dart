import 'dart:math';
import '../models/photographer_model.dart';
import '../models/filter_model.dart';
import '../models/booking_model.dart';
import 'supabase_service.dart';

/// Represents a matched photographer along with their computed match score & insights.
class ScoredPhotographer {
  final PhotographerModel photographer;
  final double score;
  final List<String> matchHighlights;
  final bool isAvailable;

  const ScoredPhotographer({
    required this.photographer,
    required this.score,
    required this.matchHighlights,
    this.isAvailable = true,
  });
}

/// 3-Tier Filter & Matching Engine
/// Architecture: Filter Panel -> Filter Engine (PostgREST DB, Location, Availability) -> Matching Engine -> Ranker
class FilterEngineService {
  final SupabaseService _supabaseService;

  FilterEngineService({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Executes the full Filter & Matching Engine pipeline
  Future<List<PhotographerModel>> executeFilterPipeline({
    required FilterModel filter,
    double? userLat,
    double? userLon,
    int limit = 20,
  }) async {
    // TIER 1: SUPABASE DATABASE FILTER LAYER
    List<PhotographerModel> candidates = await _supabaseService.getPhotographers(
      category: filter.category,
      location: filter.location,
      minRating: filter.minRating,
      maxPrice: filter.maxPrice,
      styles: filter.styles,
      equipment: filter.equipment,
      limit: limit * 2,
    );

    // TIER 2: LOCATION PROXIMITY FILTER LAYER
    if (filter.location != null && filter.location!.isNotEmpty) {
      final locQuery = filter.location!.toLowerCase().trim();
      candidates = candidates.where((p) {
        final pLoc = p.location.toLowerCase();
        return pLoc.contains(locQuery) || locQuery.contains(pLoc);
      }).toList();
    }

    if (filter.maxDistanceKm != null && userLat != null && userLon != null) {
      candidates = candidates.where((p) {
        if (p.latitude == null || p.longitude == null) return true;
        final dist = _calculateHaversineDistance(
          userLat,
          userLon,
          p.latitude!,
          p.longitude!,
        );
        return dist <= filter.maxDistanceKm!;
      }).toList();
    }

    // TIER 3: AVAILABILITY ENGINE LAYER (Conflict Resolution)
    if (filter.date != null) {
      final availableCandidates = <PhotographerModel>[];
      for (final candidate in candidates) {
        final isFree = await _checkPhotographerAvailability(
          photographerId: candidate.id,
          requestedDate: filter.date!,
          requestedTimeSlot: filter.timeSlot,
        );
        if (isFree) {
          availableCandidates.add(candidate);
        }
      }
      candidates = availableCandidates;
    }

    // TIER 4: MATCHING & RANKING ENGINE LAYER
    final scoredList = _scoreAndRankCandidates(
      candidates: candidates,
      filter: filter,
      userLat: userLat,
      userLon: userLon,
    );

    return scoredList.map((s) => s.photographer).take(limit).toList();
  }

  /// Checks if the photographer has conflicting bookings for the requested date and time slot
  Future<bool> _checkPhotographerAvailability({
    required String photographerId,
    required DateTime requestedDate,
    String? requestedTimeSlot,
  }) async {
    try {
      final bookedSlots = await _firestoreService.getBookedSlots(
        photographerId: photographerId,
        date: requestedDate,
      );

      if (requestedTimeSlot != null && requestedTimeSlot.isNotEmpty) {
        return !bookedSlots.contains(requestedTimeSlot);
      }

      // If no specific slot given, consider available if not completely booked (<= 3 slots)
      return bookedSlots.length < 4;
    } catch (_) {
      return true; // Fallback to available if query fails gracefully
    }
  }

  /// Calculates intelligent multi-dimensional matching score for each candidate
  List<ScoredPhotographer> _scoreAndRankCandidates({
    required List<PhotographerModel> candidates,
    required FilterModel filter,
    double? userLat,
    double? userLon,
  }) {
    final scoredList = <ScoredPhotographer>[];

    for (final p in candidates) {
      double score = 100.0; // Base score
      final highlights = <String>[];

      // 1. Text Search Query Match
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        if (p.name.toLowerCase().contains(query)) {
          score += 40.0;
          highlights.add('Name match');
        }
        if (p.bio != null && p.bio!.toLowerCase().contains(query)) {
          score += 20.0;
        }
        if (p.specialties.any((s) => s.toLowerCase().contains(query))) {
          score += 35.0;
          highlights.add('Specialty match');
        }
      }

      // 2. Style Overlap Match
      if (filter.styles.isNotEmpty) {
        int matchedStyles = 0;
        for (final reqStyle in filter.styles) {
          if (p.styles.any((s) => s.toLowerCase() == reqStyle.toLowerCase()) ||
              p.specialties.any((s) => s.toLowerCase() == reqStyle.toLowerCase())) {
            matchedStyles++;
          }
        }
        score += (matchedStyles * 25.0);
        if (matchedStyles > 0) {
          highlights.add('$matchedStyles style match');
        }
      }

      // 3. Equipment & Gear Overlap Match
      if (filter.equipment.isNotEmpty) {
        int matchedGear = 0;
        for (final reqGear in filter.equipment) {
          if (p.equipment.any((e) => e.toLowerCase().contains(reqGear.toLowerCase()))) {
            matchedGear++;
          }
        }
        score += (matchedGear * 15.0);
        if (matchedGear > 0) {
          highlights.add('$matchedGear gear match');
        }
      }

      // 4. Rating & Quality Score Weight
      score += (p.rating * 15.0);
      if (p.rating >= 4.8) {
        score += 20.0;
        highlights.add('Top Rated 4.8+');
      }

      // 5. Verification & Experience Weight
      if (p.isVerified) {
        score += 25.0;
        highlights.add('PRO Verified');
      }

      if (filter.minExperienceYears != null) {
        if (p.experienceYears >= filter.minExperienceYears!) {
          score += 20.0;
          highlights.add('${p.experienceYears}+ yrs experience');
        }
      } else {
        score += (p.experienceYears * 2.0);
      }

      // 6. Price Value Alignment
      if (filter.minPrice != null && filter.maxPrice != null) {
        if (p.startingPrice >= filter.minPrice! && p.startingPrice <= filter.maxPrice!) {
          score += 20.0;
        }
      }

      scoredList.add(ScoredPhotographer(
        photographer: p,
        score: score,
        matchHighlights: highlights,
        isAvailable: true,
      ));
    }

    // Sort according to requested strategy
    switch (filter.sortBy) {
      case 'rating':
        scoredList.sort((a, b) => b.photographer.rating.compareTo(a.photographer.rating));
        break;
      case 'price_asc':
        scoredList.sort((a, b) => a.photographer.startingPrice.compareTo(b.photographer.startingPrice));
        break;
      case 'price_desc':
        scoredList.sort((a, b) => b.photographer.startingPrice.compareTo(a.photographer.startingPrice));
        break;
      case 'experience':
        scoredList.sort((a, b) => b.photographer.experienceYears.compareTo(a.photographer.experienceYears));
        break;
      case 'best_match':
      default:
        scoredList.sort((a, b) => b.score.compareTo(a.score));
        break;
    }

    return scoredList;
  }

  /// Calculates geographical distance between two GPS points in Kilometers
  double _calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
