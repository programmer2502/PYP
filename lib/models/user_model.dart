class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' or 'creator' / 'photographer'
  final String? avatarUrl;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? geohash;
  final String? bio;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'customer',
    this.avatarUrl,
    this.location,
    this.latitude,
    this.longitude,
    this.geohash,
    this.bio,
    this.fcmToken,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPhotographer => role == 'photographer' || role == 'creator';

  factory UserModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return UserModel(
      id: id ?? data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      avatarUrl: data['avatar_url'] ?? data['avatarUrl'],
      location: data['location'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      geohash: data['geohash'],
      bio: data['bio'],
      fcmToken: data['fcm_token'] ?? data['fcmToken'],
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? DateTime.tryParse(data['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'bio': bio,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatarUrl,
    String? location,
    double? latitude,
    double? longitude,
    String? geohash,
    String? bio,
    String? fcmToken,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      bio: bio ?? this.bio,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
