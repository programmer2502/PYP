class ReviewModel {
  final String id;
  final String bookingId;
  final String photographerId;
  final String customerId;
  final String customerName;
  final String? customerAvatar;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.photographerId,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return ReviewModel(
      id: id ?? data['id']?.toString() ?? '',
      bookingId: data['booking_id']?.toString() ?? data['bookingId']?.toString() ?? '',
      photographerId: data['photographer_id']?.toString() ?? data['photographerId']?.toString() ?? '',
      customerId: data['customer_id']?.toString() ?? data['customerId']?.toString() ?? '',
      customerName: data['customer_name'] ?? data['customerName'] ?? 'Anonymous',
      customerAvatar: data['customer_avatar'] ?? data['customerAvatar'],
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment'] ?? '',
      photos: (data['photos'] is List) ? List<String>.from(data['photos']) : [],
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'photographer_id': photographerId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
