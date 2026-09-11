class PhotographerModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String bio;
  final String tagline;
  final List<String> categories;
  final List<String> styles;
  final List<String> equipment;
  final double startingPrice;
  final double hourlyRate;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final String location;
  final String serviceArea;
  final String creatorType; // 'photography', 'videography', 'both'
  final double latitude;
  final double longitude;
  final String geohash;
  final bool isVerified;
  final bool isAvailable;
  final bool isOnline;
  final int completedShootsCount;
  final double responseRate;
  final String workingHoursStart;
  final String workingHoursEnd;
  final List<String> portfolioImages;
  final List<String> portfolioVideos;
  final DateTime createdAt;

  List<String> get portfolioUrls => portfolioImages;
  List<String> get specialties => categories;

  PhotographerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.coverImageUrl,
    required this.bio,
    this.tagline = 'Verified Professional Visual Creator',
    required this.categories,
    this.styles = const [],
    this.equipment = const [],
    required this.startingPrice,
    required this.hourlyRate,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.experienceYears = 0,
    required this.location,
    this.serviceArea = '',
    this.creatorType = 'both',
    required this.latitude,
    required this.longitude,
    this.geohash = '',
    this.isVerified = true,
    this.isAvailable = true,
    this.isOnline = true,
    this.completedShootsCount = 0,
    this.responseRate = 1.0,
    this.workingHoursStart = '08:00 AM',
    this.workingHoursEnd = '09:00 PM',
    this.portfolioImages = const [],
    this.portfolioVideos = const [],
    required this.createdAt,
  });

  factory PhotographerModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return PhotographerModel(
      id: id ?? data['id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? data['userId']?.toString() ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatar_url'] ?? data['avatarUrl'],
      coverImageUrl: data['cover_url'] ?? data['coverImageUrl'],
      bio: data['bio'] ?? '',
      tagline: data['tagline'] ?? 'Verified Professional Visual Creator',
      categories: (data['categories'] is List) ? List<String>.from(data['categories']) : [],
      styles: (data['styles'] is List) ? List<String>.from(data['styles']) : [],
      equipment: (data['equipment'] is List) ? List<String>.from(data['equipment']) : [],
      startingPrice: (data['starting_price'] as num?)?.toDouble() ?? (data['startingPrice'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (data['hourly_rate'] as num?)?.toDouble() ?? (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['review_count'] as num?)?.toInt() ?? (data['reviewCount'] as num?)?.toInt() ?? 0,
      experienceYears: (data['experience_years'] as num?)?.toInt() ?? (data['experienceYears'] as num?)?.toInt() ?? 0,
      location: data['location'] ?? '',
      serviceArea: data['service_area'] ?? data['serviceArea'] ?? '',
      creatorType: data['creator_type'] ?? data['creatorType'] ?? 'both',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 19.0760,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 72.8777,
      geohash: data['geohash'] ?? '',
      isVerified: data['is_verified'] ?? data['isVerified'] ?? true,
      isAvailable: data['is_available'] ?? data['isAvailable'] ?? true,
      isOnline: data['is_online'] ?? data['isOnline'] ?? true,
      completedShootsCount: (data['completed_shoots_count'] as num?)?.toInt() ?? 0,
      responseRate: (data['response_rate'] as num?)?.toDouble() ?? 1.0,
      workingHoursStart: data['working_hours_start'] ?? '08:00 AM',
      workingHoursEnd: data['working_hours_end'] ?? '09:00 PM',
      portfolioImages: (data['portfolio_images'] is List) 
          ? List<String>.from(data['portfolio_images']) 
          : (data['portfolioImages'] is List) ? List<String>.from(data['portfolioImages']) : [],
      portfolioVideos: (data['portfolio_videos'] is List) 
          ? List<String>.from(data['portfolio_videos']) 
          : (data['portfolioVideos'] is List) ? List<String>.from(data['portfolioVideos']) : [],
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'bio': bio,
      'tagline': tagline,
      'location': location,
      'service_area': serviceArea,
      'creator_type': creatorType,
      'latitude': latitude,
      'longitude': longitude,
      'starting_price': startingPrice,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'review_count': reviewCount,
      'experience_years': experienceYears,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'is_online': isOnline,
      'completed_shoots_count': completedShootsCount,
      'response_rate': responseRate,
      'working_hours_start': workingHoursStart,
      'working_hours_end': workingHoursEnd,
      'categories': categories,
      'styles': styles,
      'equipment': equipment,
      'portfolio_images': portfolioImages,
      'portfolio_videos': portfolioVideos,
      'created_at': createdAt.toIso8601String(),
    };
    if (userId.isNotEmpty) map['user_id'] = userId;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) map['avatar_url'] = avatarUrl;
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) map['cover_url'] = coverImageUrl;
    return map;
  }

  PhotographerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? coverImageUrl,
    String? bio,
    String? tagline,
    List<String>? categories,
    List<String>? styles,
    List<String>? equipment,
    double? startingPrice,
    double? hourlyRate,
    double? rating,
    int? reviewCount,
    int? experienceYears,
    String? location,
    String? serviceArea,
    String? creatorType,
    double? latitude,
    double? longitude,
    String? geohash,
    bool? isVerified,
    bool? isAvailable,
    bool? isOnline,
    int? completedShootsCount,
    double? responseRate,
    String? workingHoursStart,
    String? workingHoursEnd,
    List<String>? portfolioImages,
    List<String>? portfolioVideos,
    DateTime? createdAt,
  }) {
    return PhotographerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bio: bio ?? this.bio,
      tagline: tagline ?? this.tagline,
      categories: categories ?? this.categories,
      styles: styles ?? this.styles,
      equipment: equipment ?? this.equipment,
      startingPrice: startingPrice ?? this.startingPrice,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experienceYears: experienceYears ?? this.experienceYears,
      location: location ?? this.location,
      serviceArea: serviceArea ?? this.serviceArea,
      creatorType: creatorType ?? this.creatorType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      completedShootsCount: completedShootsCount ?? this.completedShootsCount,
      responseRate: responseRate ?? this.responseRate,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      portfolioVideos: portfolioVideos ?? this.portfolioVideos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
