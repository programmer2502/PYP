class ChatMessageModel {
  final String id;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final String? mediaUrl;
  final String mediaType; // 'text', 'image', 'booking_card', 'location', 'timeline'
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.text,
    this.mediaUrl,
    this.mediaType = 'text',
    this.metadata,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> data, {String? id, String? bookingId}) {
    return ChatMessageModel(
      id: id ?? data['id']?.toString() ?? '',
      bookingId: bookingId ?? data['booking_id']?.toString() ?? data['bookingId']?.toString() ?? '',
      senderId: data['sender_id']?.toString() ?? data['senderId']?.toString() ?? '',
      senderName: data['sender_name'] ?? data['senderName'] ?? '',
      senderAvatar: data['sender_avatar'] ?? data['senderAvatar'],
      text: data['text'] ?? '',
      mediaUrl: data['media_url'] ?? data['mediaUrl'],
      mediaType: data['media_type'] ?? data['mediaType'] ?? 'text',
      metadata: data['metadata'] is Map<String, dynamic> ? data['metadata'] as Map<String, dynamic> : null,
      isRead: data['is_read'] ?? data['isRead'] ?? false,
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'text': text,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
