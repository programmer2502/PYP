class AvailabilityModel {
  final String id;
  final String photographerId;
  final DateTime date;
  final String status; // 'AVAILABLE', 'BOOKED', 'BLOCKED', 'PARTIALLY_AVAILABLE'
  final String startTime;
  final String endTime;
  final String? notes;
  final DateTime createdAt;

  AvailabilityModel({
    required this.id,
    required this.photographerId,
    required this.date,
    this.status = 'AVAILABLE',
    this.startTime = '09:00 AM',
    this.endTime = '08:00 PM',
    this.notes,
    required this.createdAt,
  });

  bool get isAvailable => status.toUpperCase() == 'AVAILABLE';
  bool get isBooked => status.toUpperCase() == 'BOOKED';
  bool get isBlocked => status.toUpperCase() == 'BLOCKED';
  bool get isPartiallyAvailable => status.toUpperCase() == 'PARTIALLY_AVAILABLE';

  factory AvailabilityModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return AvailabilityModel(
      id: id ?? data['id']?.toString() ?? '',
      photographerId: data['photographer_id']?.toString() ?? '',
      date: data['date'] != null
          ? DateTime.tryParse(data['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: (data['status'] ?? 'AVAILABLE').toString().toUpperCase(),
      startTime: data['start_time'] ?? '09:00 AM',
      endTime: data['end_time'] ?? '08:00 PM',
      notes: data['notes'],
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photographer_id': photographerId,
      'date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'status': status.toUpperCase(),
      'start_time': startTime,
      'end_time': endTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AvailabilityModel copyWith({
    String? id,
    String? photographerId,
    DateTime? date,
    String? status,
    String? startTime,
    String? endTime,
    String? notes,
    DateTime? createdAt,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      date: date ?? this.date,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
