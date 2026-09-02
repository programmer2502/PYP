class AppConstants {
  AppConstants._();

  static const String appName = 'PYP';
  static const String appFullName = 'PYP - Pick Your Photographer';
  static const String appTagline = 'Pick Your Photographer — Book Elite Creators On-Demand';

  // Categories
  static const List<String> categories = [
    'Photography',
    'Videography',
    'Reels',
    'Drone',
    'Product Photography',
    'Events',
    'Wedding',
    'Fashion',
    'Portrait',
    'Real Estate',
  ];

  // Category Icons & Slugs
  static const Map<String, String> categoryIcons = {
    'Photography': 'camera',
    'Videography': 'video',
    'Reels': 'film',
    'Drone': 'plane',
    'Product Photography': 'cube',
    'Events': 'calendar',
    'Wedding': 'heart',
    'Fashion': 'sparkles',
    'Portrait': 'user',
    'Real Estate': 'home',
  };

  // Photography Styles
  static const List<String> styles = [
    'Cinematic',
    'Minimalist',
    'Moody & Dark',
    'Vibrant & Warm',
    'Editorial',
    'Candid',
    'Vintage / Retro',
    'Commercial',
  ];

  // Equipment tags
  static const List<String> equipmentTags = [
    'Sony A7 IV',
    'Sony FX3',
    'Canon R5',
    'Canon R6 II',
    'DJI Mavic 3 Pro',
    'DJI Ronin RS3',
    'Profoto B10',
    'Godox AD200',
    '4K 120fps Cinema',
    'Wireless Lavalier Mics',
  ];

  // Booking Statuses
  static const String statusRequested = 'requested';
  static const String statusConfirmed = 'confirmed';
  static const String statusShootDay = 'shoot_day';
  static const String statusEditing = 'editing';
  static const String statusDelivered = 'delivered';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Platform Fee Percentage (e.g. 5%)
  static const double platformFeeRate = 0.05;
  static const double taxRate = 0.18; // 18% GST/Tax

  // Collections
  static const String collectionUsers = 'users';
  static const String collectionPhotographers = 'photographers';
  static const String collectionBookings = 'bookings';
  static const String collectionChats = 'chats';
  static const String collectionMessages = 'messages';
  static const String collectionDeliverables = 'deliverables';
  static const String collectionFiles = 'files';
  static const String collectionPackages = 'packages';
  static const String collectionReviews = 'reviews';
  static const String collectionPortfolio = 'portfolio';
}
