class FilterModel {
  // 1. Basic Filters
  final String? category;
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final String? serviceType; // e.g. 'Standard', 'Premium', 'Drone Included', 'Cinematic'

  // 2. Availability Filters
  final DateTime? date;
  final String? timeSlot; // e.g. 'Morning', 'Afternoon', 'Golden Hour', 'Evening'
  final int? durationHours; // e.g. 1, 2, 4, 8

  // 3. Advanced Filters
  final List<String> styles;
  final List<String> equipment;
  final double? minRating;
  final int? minExperienceYears;
  final double? maxDistanceKm;

  // Search & Ranking
  final String? searchQuery;
  final String sortBy; // 'best_match', 'rating', 'price_asc', 'price_desc', 'experience', 'distance'

  const FilterModel({
    this.category,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.serviceType,
    this.date,
    this.timeSlot,
    this.durationHours,
    this.styles = const [],
    this.equipment = const [],
    this.minRating,
    this.minExperienceYears,
    this.maxDistanceKm,
    this.searchQuery,
    this.sortBy = 'best_match',
  });

  bool get hasActiveFilters =>
      category != null ||
      location != null ||
      minPrice != null ||
      maxPrice != null ||
      serviceType != null ||
      date != null ||
      timeSlot != null ||
      durationHours != null ||
      styles.isNotEmpty ||
      equipment.isNotEmpty ||
      minRating != null ||
      minExperienceYears != null ||
      maxDistanceKm != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  int get activeFilterCount {
    int count = 0;
    if (category != null && category != 'All') count++;
    if (location != null && location!.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (serviceType != null) count++;
    if (date != null) count++;
    if (timeSlot != null) count++;
    if (durationHours != null) count++;
    if (styles.isNotEmpty) count += styles.length;
    if (equipment.isNotEmpty) count += equipment.length;
    if (minRating != null) count++;
    if (minExperienceYears != null) count++;
    if (maxDistanceKm != null) count++;
    return count;
  }

  FilterModel copyWith({
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? serviceType,
    DateTime? date,
    String? timeSlot,
    int? durationHours,
    List<String>? styles,
    List<String>? equipment,
    double? minRating,
    int? minExperienceYears,
    double? maxDistanceKm,
    String? searchQuery,
    String? sortBy,
    bool clearCategory = false,
    bool clearLocation = false,
    bool clearPrice = false,
    bool clearServiceType = false,
    bool clearDate = false,
    bool clearTimeSlot = false,
    bool clearDuration = false,
    bool clearRating = false,
    bool clearExperience = false,
    bool clearDistance = false,
    bool clearQuery = false,
  }) {
    return FilterModel(
      category: clearCategory ? null : (category ?? this.category),
      location: clearLocation ? null : (location ?? this.location),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      serviceType: clearServiceType ? null : (serviceType ?? this.serviceType),
      date: clearDate ? null : (date ?? this.date),
      timeSlot: clearTimeSlot ? null : (timeSlot ?? this.timeSlot),
      durationHours: clearDuration ? null : (durationHours ?? this.durationHours),
      styles: styles ?? this.styles,
      equipment: equipment ?? this.equipment,
      minRating: clearRating ? null : (minRating ?? this.minRating),
      minExperienceYears: clearExperience ? null : (minExperienceYears ?? this.minExperienceYears),
      maxDistanceKm: clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      searchQuery: clearQuery ? null : (searchQuery ?? this.searchQuery),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
