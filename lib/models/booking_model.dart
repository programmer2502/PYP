import '../core/constants/app_constants.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? customerAvatar;
  final String photographerId;
  final String photographerName;
  final String? photographerAvatar;
  final String packageId;
  final String packageTitle;
  final String eventType;
  final DateTime eventDate;
  final String timeSlot;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final String? customNotes;
  final double basePrice;
  final double platformFee;
  final double taxAmount;
  final double totalAmount;
  final String status;
  final String? paymentId;
  final String? paymentStatus;
  final String? cancellationReason;
  final String? cancelledBy;
  final bool hasReviewed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerAvatar,
    required this.photographerId,
    required this.photographerName,
    this.photographerAvatar,
    required this.packageId,
    required this.packageTitle,
    required this.eventType,
    required this.eventDate,
    required this.timeSlot,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    this.customNotes,
    required this.basePrice,
    required this.platformFee,
    required this.taxAmount,
    required this.totalAmount,
    this.status = AppConstants.statusRequested,
    this.paymentId,
    this.paymentStatus = 'pending',
    this.cancellationReason,
    this.cancelledBy,
    this.hasReviewed = false,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isUpcoming =>
      status == AppConstants.statusRequested || status == AppConstants.statusConfirmed;

  bool get isInProgress =>
      status == AppConstants.statusShootDay || status == AppConstants.statusEditing;

  bool get isCompleted =>
      status == AppConstants.statusDelivered || status == AppConstants.statusCompleted;

  bool get isCancelled => status == AppConstants.statusCancelled;

  bool get canCancel {
    if (isCancelled || isCompleted) return false;
    final now = DateTime.now();
    return eventDate.difference(now).inHours > 24;
  }

  factory BookingModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return BookingModel(
      id: id ?? data['id']?.toString() ?? data['booking_number'] ?? '',
      customerId: data['customer_id']?.toString() ?? data['customerId']?.toString() ?? '',
      customerName: data['customer_name'] ?? data['customerName'] ?? 'Customer',
      customerPhone: data['customer_phone'] ?? data['customerPhone'] ?? '',
      customerAvatar: data['customer_avatar'] ?? data['customerAvatar'],
      photographerId: data['photographer_id']?.toString() ?? data['photographerId']?.toString() ?? '',
      photographerName: data['photographer_name'] ?? data['photographerName'] ?? 'Photographer',
      photographerAvatar: data['photographer_avatar'] ?? data['photographerAvatar'],
      packageId: data['package_id']?.toString() ?? data['packageId']?.toString() ?? '',
      packageTitle: data['package_title'] ?? data['packageTitle'] ?? data['service_name'] ?? 'Session Package',
      eventType: data['event_type'] ?? data['eventType'] ?? 'Photography',
      eventDate: data['shoot_date'] != null 
          ? DateTime.tryParse(data['shoot_date'].toString()) ?? DateTime.now()
          : (data['eventDate'] != null ? DateTime.tryParse(data['eventDate'].toString()) ?? DateTime.now() : DateTime.now()),
      timeSlot: data['time_slot'] ?? data['timeSlot'] ?? '10:00 AM',
      locationAddress: data['venue'] ?? data['locationAddress'] ?? 'Mumbai, India',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 19.0596,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 72.8295,
      customNotes: data['notes'] ?? data['customNotes'],
      basePrice: (data['subtotal'] as num?)?.toDouble() ?? (data['basePrice'] as num?)?.toDouble() ?? 4999.0,
      platformFee: (data['platform_fee'] as num?)?.toDouble() ?? (data['platformFee'] as num?)?.toDouble() ?? 250.0,
      taxAmount: (data['tax'] as num?)?.toDouble() ?? (data['taxAmount'] as num?)?.toDouble() ?? 884.0,
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? (data['totalAmount'] as num?)?.toDouble() ?? 6133.0,
      status: data['status'] ?? AppConstants.statusRequested,
      paymentId: data['razorpay_payment_id'] ?? data['paymentId'],
      paymentStatus: data['payment_status'] ?? data['paymentStatus'] ?? 'paid',
      cancellationReason: data['cancellation_reason'] ?? data['cancellationReason'],
      cancelledBy: data['cancelled_by'] ?? data['cancelledBy'],
      hasReviewed: data['has_reviewed'] ?? data['hasReviewed'] ?? false,
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
      'booking_number': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_avatar': customerAvatar,
      'photographer_id': photographerId,
      'photographer_name': photographerName,
      'photographer_avatar': photographerAvatar,
      'package_id': packageId,
      'package_title': packageTitle,
      'event_type': eventType,
      'shoot_date': eventDate.toIso8601String(),
      'time_slot': timeSlot,
      'venue': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'notes': customNotes,
      'subtotal': basePrice,
      'platform_fee': platformFee,
      'tax': taxAmount,
      'total_amount': totalAmount,
      'status': status,
      'razorpay_payment_id': paymentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
