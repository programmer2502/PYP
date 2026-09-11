class PackageModel {
  final String id;
  final String photographerId;
  final String title;
  final String description;
  final double price;
  final int durationMinutes;
  final String serviceType;
  final int numPhotographers;
  final int numVideographers;
  final int videoDurationMinutes;
  final int numReels;
  final List<String> inclusions;
  final int deliverablesCount;
  final int turnaroundDays;
  final bool isPopular;
  final bool isActive;
  final List<String> addOns;

  PackageModel({
    required this.id,
    required this.photographerId,
    required this.title,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.serviceType = 'Photography',
    this.numPhotographers = 1,
    this.numVideographers = 0,
    this.videoDurationMinutes = 0,
    this.numReels = 0,
    required this.inclusions,
    required this.deliverablesCount,
    required this.turnaroundDays,
    this.isPopular = false,
    this.isActive = true,
    this.addOns = const [],
  });

  factory PackageModel.fromMap(Map<String, dynamic> data, {String? id, String? photographerId}) {
    return PackageModel(
      id: id ?? data['id']?.toString() ?? '',
      photographerId: photographerId ?? data['photographer_id']?.toString() ?? data['photographerId']?.toString() ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (data['duration_minutes'] as num?)?.toInt() ?? 
          ((data['duration_hours'] as num?)?.toInt() != null ? (data['duration_hours'] as num).toInt() * 60 : null) ?? 
          (data['durationMinutes'] as num?)?.toInt() ?? 60,
      serviceType: data['service_type'] ?? data['serviceType'] ?? 'Photography',
      numPhotographers: (data['num_photographers'] as num?)?.toInt() ?? (data['numPhotographers'] as num?)?.toInt() ?? 1,
      numVideographers: (data['num_videographers'] as num?)?.toInt() ?? (data['numVideographers'] as num?)?.toInt() ?? 0,
      videoDurationMinutes: (data['video_duration_minutes'] as num?)?.toInt() ?? (data['videoDurationMinutes'] as num?)?.toInt() ?? 0,
      numReels: (data['num_reels'] as num?)?.toInt() ?? (data['numReels'] as num?)?.toInt() ?? 0,
      inclusions: (data['inclusions'] is List) 
          ? List<String>.from(data['inclusions']) 
          : (data['features'] is List ? List<String>.from(data['features']) : []),
      deliverablesCount: (data['deliverables_count'] as num?)?.toInt() ?? (data['photos_count'] as num?)?.toInt() ?? (data['deliverablesCount'] as num?)?.toInt() ?? 20,
      turnaroundDays: (data['turnaround_days'] as num?)?.toInt() ?? (data['delivery_days'] as num?)?.toInt() ?? (data['turnaroundDays'] as num?)?.toInt() ?? 3,
      isPopular: data['is_popular'] ?? data['isPopular'] ?? false,
      isActive: data['is_active'] ?? data['isActive'] ?? true,
      addOns: (data['add_ons'] is List) ? List<String>.from(data['add_ons']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photographer_id': photographerId,
      'title': title,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'duration_hours': (durationMinutes / 60).round(),
      'service_type': serviceType,
      'num_photographers': numPhotographers,
      'num_videographers': numVideographers,
      'video_duration_minutes': videoDurationMinutes,
      'num_reels': numReels,
      'features': inclusions,
      'inclusions': inclusions,
      'photos_count': deliverablesCount,
      'deliverables_count': deliverablesCount,
      'delivery_days': turnaroundDays,
      'turnaround_days': turnaroundDays,
      'is_popular': isPopular,
      'is_active': isActive,
      'add_ons': addOns,
    };
  }

  PackageModel copyWith({
    String? id,
    String? photographerId,
    String? title,
    String? description,
    double? price,
    int? durationMinutes,
    String? serviceType,
    int? numPhotographers,
    int? numVideographers,
    int? videoDurationMinutes,
    int? numReels,
    List<String>? inclusions,
    int? deliverablesCount,
    int? turnaroundDays,
    bool? isPopular,
    bool? isActive,
    List<String>? addOns,
  }) {
    return PackageModel(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      serviceType: serviceType ?? this.serviceType,
      numPhotographers: numPhotographers ?? this.numPhotographers,
      numVideographers: numVideographers ?? this.numVideographers,
      videoDurationMinutes: videoDurationMinutes ?? this.videoDurationMinutes,
      numReels: numReels ?? this.numReels,
      inclusions: inclusions ?? this.inclusions,
      deliverablesCount: deliverablesCount ?? this.deliverablesCount,
      turnaroundDays: turnaroundDays ?? this.turnaroundDays,
      isPopular: isPopular ?? this.isPopular,
      isActive: isActive ?? this.isActive,
      addOns: addOns ?? this.addOns,
    );
  }
}
