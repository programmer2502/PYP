class QuoteModel {
  final String id;
  final String photographerId;
  final String customerId;
  final String? bookingId;
  final String serviceTitle;
  final String description;
  final double price;
  final int durationHours;
  final int photosCount;
  final int videoDurationMinutes;
  final int reelsCount;
  final int numPhotographers;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;

  QuoteModel({
    required this.id,
    required this.photographerId,
    required this.customerId,
    this.bookingId,
    required this.serviceTitle,
    required this.description,
    required this.price,
    this.durationHours = 2,
    this.photosCount = 30,
    this.videoDurationMinutes = 0,
    this.reelsCount = 0,
    this.numPhotographers = 1,
    this.status = 'pending',
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  factory QuoteModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return QuoteModel(
      id: id ?? data['id']?.toString() ?? '',
      photographerId: data['photographer_id']?.toString() ?? '',
      customerId: data['customer_id']?.toString() ?? '',
      bookingId: data['booking_id']?.toString(),
      serviceTitle: data['service_title'] ?? data['title'] ?? 'Custom Photography Session',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 4999.0,
      durationHours: (data['duration_hours'] as num?)?.toInt() ?? 2,
      photosCount: (data['photos_count'] as num?)?.toInt() ?? 30,
      videoDurationMinutes: (data['video_duration_minutes'] as num?)?.toInt() ?? 0,
      reelsCount: (data['reels_count'] as num?)?.toInt() ?? 0,
      numPhotographers: (data['num_photographers'] as num?)?.toInt() ?? 1,
      status: data['status'] ?? 'pending',
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photographer_id': photographerId,
      'customer_id': customerId,
      'booking_id': bookingId,
      'service_title': serviceTitle,
      'description': description,
      'price': price,
      'duration_hours': durationHours,
      'photos_count': photosCount,
      'video_duration_minutes': videoDurationMinutes,
      'reels_count': reelsCount,
      'num_photographers': numPhotographers,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuoteModel copyWith({
    String? id,
    String? photographerId,
    String? customerId,
    String? bookingId,
    String? serviceTitle,
    String? description,
    double? price,
    int? durationHours,
    int? photosCount,
    int? videoDurationMinutes,
    int? reelsCount,
    int? numPhotographers,
    String? status,
    DateTime? createdAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      customerId: customerId ?? this.customerId,
      bookingId: bookingId ?? this.bookingId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      description: description ?? this.description,
      price: price ?? this.price,
      durationHours: durationHours ?? this.durationHours,
      photosCount: photosCount ?? this.photosCount,
      videoDurationMinutes: videoDurationMinutes ?? this.videoDurationMinutes,
      reelsCount: reelsCount ?? this.reelsCount,
      numPhotographers: numPhotographers ?? this.numPhotographers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
