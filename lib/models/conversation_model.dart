/// Comprehensive Conversation & Booking Context Model for the Supabase Chat System Architecture
class ConversationModel {
  final String id;
  final String bookingId;
  
  // User Data: Customer & Creator
  final String customerId;
  final String customerName;
  final String? customerAvatar;
  
  final String creatorId;
  final String creatorName;
  final String? creatorAvatar;
  final bool isCreatorVerified;
  final String creatorSpecialty;
  final bool isCreatorOnline;

  // Booking Context
  final String bookingNumber;
  final String serviceName;
  final DateTime? shootDate;
  final String venue;
  final String bookingStatus; // 'confirmed', 'shoot_day', 'editing', 'delivered', 'completed'
  final double totalAmount;

  // Conversation Metadata
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatar,
    this.isCreatorVerified = true,
    this.creatorSpecialty = 'Editorial & Wedding',
    this.isCreatorOnline = true,
    required this.bookingNumber,
    required this.serviceName,
    this.shootDate,
    required this.venue,
    this.bookingStatus = 'confirmed',
    this.totalAmount = 4999.0,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return ConversationModel(
      id: id ?? data['id']?.toString() ?? data['booking_number'] ?? '',
      bookingId: data['booking_id']?.toString() ?? data['bookingId']?.toString() ?? data['id']?.toString() ?? '',
      customerId: data['customer_id']?.toString() ?? data['customerId']?.toString() ?? '',
      customerName: data['customer_name'] ?? data['customerName'] ?? 'Customer',
      customerAvatar: data['customer_avatar'] ?? data['customerAvatar'],
      creatorId: data['photographer_id']?.toString() ?? data['creatorId']?.toString() ?? '',
      creatorName: data['photographer_name'] ?? data['creatorName'] ?? 'Creator',
      creatorAvatar: data['photographer_avatar'] ?? data['creatorAvatar'],
      isCreatorVerified: data['is_creator_verified'] ?? data['isCreatorVerified'] ?? true,
      creatorSpecialty: data['creator_specialty'] ?? data['creatorSpecialty'] ?? 'Editorial & Wedding',
      isCreatorOnline: data['is_creator_online'] ?? data['isCreatorOnline'] ?? true,
      bookingNumber: data['booking_number'] ?? data['bookingNumber'] ?? '#BK-9021',
      serviceName: data['service_name'] ?? data['package_title'] ?? data['serviceName'] ?? 'Editorial Portrait Standard',
      shootDate: data['shoot_date'] != null ? DateTime.tryParse(data['shoot_date'].toString()) : null,
      venue: data['venue'] ?? data['locationAddress'] ?? 'Bandra West, Mumbai',
      bookingStatus: data['status'] ?? data['bookingStatus'] ?? 'confirmed',
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? (data['totalAmount'] as num?)?.toDouble() ?? 4999.0,
      lastMessage: data['last_message'] ?? data['lastMessage'] ?? '',
      lastMessageTime: data['last_message_time'] != null 
          ? DateTime.tryParse(data['last_message_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastSenderId: data['last_sender_id']?.toString() ?? data['lastSenderId']?.toString() ?? '',
      unreadCount: (data['unread_count'] as num?)?.toInt() ?? (data['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'photographer_id': creatorId,
      'photographer_name': creatorName,
      'photographer_avatar': creatorAvatar,
      'is_creator_verified': isCreatorVerified,
      'creator_specialty': creatorSpecialty,
      'is_creator_online': isCreatorOnline,
      'booking_number': bookingNumber,
      'service_name': serviceName,
      'shoot_date': shootDate?.toIso8601String(),
      'venue': venue,
      'status': bookingStatus,
      'total_amount': totalAmount,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'last_sender_id': lastSenderId,
    };
  }
}
