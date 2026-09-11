class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'booking_request', 'booking_accepted', 'payment_completed', 'message', 'shoot_reminder', 'review'
  final String? bookingId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'booking_request',
    this.bookingId,
    this.isRead = false,
    required this.createdAt,
  });

  String? get targetRoute {
    if (bookingId != null && bookingId!.isNotEmpty) {
      if (type == 'chat_message') return '/chat/$bookingId';
      return '/creator-booking/$bookingId';
    }
    if (type == 'payment_completed') return '/creator-earnings';
    if (type == 'review') return '/creator-reviews';
    return null;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return NotificationModel(
      id: id ?? data['id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'booking_request',
      bookingId: data['booking_id']?.toString(),
      isRead: data['is_read'] ?? false,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'booking_id': bookingId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
