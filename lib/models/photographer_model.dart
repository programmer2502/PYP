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
  final double latitude;
  final double longitude;
  final String geohash;
  final bool isVerified;
  final bool isAvailable;
  final List<String> portfolioImages;
  final List<String> portfolioVideos;
  final DateTime createdAt;

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
    this.rating = 4.9,
    this.reviewCount = 0,
    this.experienceYears = 1,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.geohash = '',
    this.isVerified = true,
    this.isAvailable = true,
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
      startingPrice: (data['starting_price'] as num?)?.toDouble() ?? (data['startingPrice'] as num?)?.toDouble() ?? 4999.0,
      hourlyRate: (data['hourly_rate'] as num?)?.toDouble() ?? (data['hourlyRate'] as num?)?.toDouble() ?? 2499.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (data['review_count'] as num?)?.toInt() ?? (data['reviewCount'] as num?)?.toInt() ?? 0,
      experienceYears: (data['experience_years'] as num?)?.toInt() ?? (data['experienceYears'] as num?)?.toInt() ?? 3,
      location: data['location'] ?? 'Mumbai, India',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 19.0760,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 72.8777,
      geohash: data['geohash'] ?? '',
      isVerified: data['is_verified'] ?? data['isVerified'] ?? true,
      isAvailable: data['is_available'] ?? data['isAvailable'] ?? true,
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
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'cover_url': coverImageUrl,
      'bio': bio,
      'tagline': tagline,
      'categories': categories,
      'styles': styles,
      'equipment': equipment,
      'starting_price': startingPrice,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'review_count': reviewCount,
      'experience_years': experienceYears,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'portfolio_images': portfolioImages,
      'portfolio_videos': portfolioVideos,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
