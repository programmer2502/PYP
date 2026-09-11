class PortfolioMediaModel {
  final String id;
  final String photographerId;
  final String title;
  final String? description;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String mediaType; // 'PHOTO', 'VIDEO', 'REEL'
  final String category; // 'Wedding', 'Portrait', 'Event', 'Fashion', etc.
  final String styleTag; // 'Cinematic', 'Candid', 'Editorial', 'Moody & Dark', etc.
  final bool isFeatured;
  final int sortOrder;
  final DateTime createdAt;

  PortfolioMediaModel({
    required this.id,
    required this.photographerId,
    this.title = '',
    this.description,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.mediaType = 'PHOTO',
    this.category = 'Portrait',
    this.styleTag = 'Cinematic',
    this.isFeatured = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  bool get isPhoto => mediaType.toUpperCase() == 'PHOTO';
  bool get isVideo => mediaType.toUpperCase() == 'VIDEO';
  bool get isReel => mediaType.toUpperCase() == 'REEL';

  factory PortfolioMediaModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return PortfolioMediaModel(
      id: id ?? data['id']?.toString() ?? '',
      photographerId: data['photographer_id']?.toString() ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      mediaUrl: data['media_url'] ?? '',
      thumbnailUrl: data['thumbnail_url'] ?? data['media_url'],
      mediaType: (data['media_type'] ?? 'PHOTO').toString().toUpperCase(),
      category: data['category'] ?? 'Portrait',
      styleTag: data['style_tag'] ?? 'Cinematic',
      isFeatured: data['is_featured'] ?? false,
      sortOrder: (data['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photographer_id': photographerId,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'media_type': mediaType.toUpperCase(),
      'category': category,
      'style_tag': styleTag,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PortfolioMediaModel copyWith({
    String? id,
    String? photographerId,
    String? title,
    String? description,
    String? mediaUrl,
    String? thumbnailUrl,
    String? mediaType,
    String? category,
    String? styleTag,
    bool? isFeatured,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return PortfolioMediaModel(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaType: mediaType ?? this.mediaType,
      category: category ?? this.category,
      styleTag: styleTag ?? this.styleTag,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
