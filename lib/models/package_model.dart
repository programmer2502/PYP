class PackageModel {
  final String id;
  final String photographerId;
  final String title;
  final String description;
  final double price;
  final int durationMinutes;
  final List<String> inclusions;
  final int deliverablesCount;
  final int turnaroundDays;
  final bool isPopular;

  PackageModel({
    required this.id,
    required this.photographerId,
    required this.title,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.inclusions,
    required this.deliverablesCount,
    required this.turnaroundDays,
    this.isPopular = false,
  });

  factory PackageModel.fromMap(Map<String, dynamic> data, {String? id, String? photographerId}) {
    return PackageModel(
      id: id ?? data['id']?.toString() ?? '',
      photographerId: photographerId ?? data['photographer_id']?.toString() ?? data['photographerId']?.toString() ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (data['duration_minutes'] as num?)?.toInt() ?? (data['durationMinutes'] as num?)?.toInt() ?? 60,
      inclusions: (data['inclusions'] is List) ? List<String>.from(data['inclusions']) : (data['features'] is List ? List<String>.from(data['features']) : []),
      deliverablesCount: (data['deliverables_count'] as num?)?.toInt() ?? (data['photos_count'] as num?)?.toInt() ?? (data['deliverablesCount'] as num?)?.toInt() ?? 20,
      turnaroundDays: (data['turnaround_days'] as num?)?.toInt() ?? (data['delivery_days'] as num?)?.toInt() ?? (data['turnaroundDays'] as num?)?.toInt() ?? 3,
      isPopular: data['is_popular'] ?? data['isPopular'] ?? false,
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
      'inclusions': inclusions,
      'deliverables_count': deliverablesCount,
      'turnaround_days': turnaroundDays,
      'is_popular': isPopular,
    };
  }
}
