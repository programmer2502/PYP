import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase/supabase_config.dart';
import '../models/user_model.dart';
import '../models/photographer_model.dart';
import '../models/package_model.dart';
import '../models/booking_model.dart';
import '../models/chat_message_model.dart';
import '../models/review_model.dart';
import '../models/deliverable_file_model.dart';

/// Centralized Database Service powered by Supabase (PostgreSQL + Realtime)
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  // --------------------------------------------------------------------------
  // USER PROFILES
  // --------------------------------------------------------------------------
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(response);
    } catch (e) {
      debugPrint('SupabaseService.getUserProfile error: $e');
      return null;
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _client.from('users').upsert(user.toMap());
    } catch (e) {
      debugPrint('SupabaseService.createUserProfile error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _client
          .from('users')
          .update(user.toMap())
          .eq('id', user.id);
    } catch (e) {
      debugPrint('SupabaseService.updateUserProfile error: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // PHOTOGRAPHERS & CREATORS (PostgREST Queries)
  // --------------------------------------------------------------------------
  Future<List<PhotographerModel>> getPhotographers({
    String? category,
    String? location,
    double? minRating,
    double? maxPrice,
    List<String>? styles,
    List<String>? equipment,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('photographers').select();

      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.contains('categories', [category]);
      }

      if (location != null && location.isNotEmpty) {
        query = query.ilike('location', '%$location%');
      }

      if (minRating != null && minRating > 0) {
        query = query.gte('rating', minRating);
      }

      if (maxPrice != null && maxPrice > 0) {
        query = query.lte('starting_price', maxPrice);
      }

      final response = await query.limit(limit);
      final list = (response as List)
          .map((data) => PhotographerModel.fromMap(data))
          .toList();
      if (list.isEmpty) {
        return _getSeedPhotographers();
      }
      return list;
    } catch (e) {
      debugPrint('SupabaseService.getPhotographers error (falling back to default seed): $e');
      return _getSeedPhotographers();
    }
  }

  Future<PhotographerModel?> getPhotographerById(String id) async {
    try {
      final response = await _client
          .from('photographers')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        final seed = _getSeedPhotographers();
        return seed.firstWhere((p) => p.id == id, orElse: () => seed.first);
      }
      return PhotographerModel.fromMap(response);
    } catch (e) {
      debugPrint('SupabaseService.getPhotographerById fallback: $e');
      final seed = _getSeedPhotographers();
      return seed.firstWhere((p) => p.id == id, orElse: () => seed.first);
    }
  }

  // --------------------------------------------------------------------------
  // PACKAGES
  // --------------------------------------------------------------------------
  Future<List<PackageModel>> getPackages(String photographerId) async {
    try {
      final response = await _client
          .from('packages')
          .select()
          .eq('photographer_id', photographerId);

      if ((response as List).isEmpty) {
        return _getDefaultPackages(photographerId);
      }
      return response.map((data) => PackageModel.fromMap(data)).toList();
    } catch (e) {
      debugPrint('SupabaseService.getPackages fallback: $e');
      return _getDefaultPackages(photographerId);
    }
  }

  // --------------------------------------------------------------------------
  // BOOKINGS (Reservations & Escrow)
  // --------------------------------------------------------------------------
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _client.from('bookings').insert(booking.toMap());
    } catch (e) {
      debugPrint('SupabaseService.createBooking error: $e');
      rethrow;
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('customer_id', userId)
          .order('shoot_date', ascending: false);

      return (response as List)
          .map((data) => BookingModel.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getUserBookings error: $e');
      return [];
    }
  }

  Stream<List<BookingModel>> streamUserBookings(String userId) {
    try {
      return _client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('customer_id', userId)
          .map((list) => list.map((data) => BookingModel.fromMap(data)).toList());
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _client
          .from('bookings')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', bookingId);
    } catch (e) {
      debugPrint('SupabaseService.updateBookingStatus error: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // REVIEWS
  // --------------------------------------------------------------------------
  Future<List<ReviewModel>> getReviews(String photographerId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('photographer_id', photographerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => ReviewModel.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getReviews error: $e');
      return [];
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      await _client.from('reviews').insert(review.toMap());
    } catch (e) {
      debugPrint('SupabaseService.addReview error: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // DELIVERABLES
  // --------------------------------------------------------------------------
  Future<List<DeliverableFileModel>> getDeliverables(String bookingId) async {
    try {
      final response = await _client
          .from('deliverables')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => DeliverableFileModel.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getDeliverables error: $e');
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // REALTIME CHAT MESSAGES
  // --------------------------------------------------------------------------
  Stream<List<ChatMessageModel>> streamMessages(String bookingId) {
    try {
      return _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('booking_id', bookingId)
          .order('created_at', ascending: true)
          .map((list) => list.map((data) => ChatMessageModel.fromMap(data)).toList());
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<void> sendChatMessage({
    required String bookingId,
    required ChatMessageModel message,
  }) async {
    try {
      await _client.from('messages').insert(message.toMap());
      await _client.from('bookings').update({
        'last_message': message.text.isNotEmpty ? message.text : '[Attachment]',
        'last_message_time': message.createdAt.toIso8601String(),
        'last_sender_id': message.senderId,
      }).eq('id', bookingId);
    } catch (e) {
      debugPrint('SupabaseService.sendChatMessage error: $e');
    }
  }

  Future<void> markMessagesAsRead(String bookingId, String userId) async {
    try {
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('booking_id', bookingId)
          .neq('sender_id', userId);
    } catch (_) {}
  }

  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final response = await _client
          .from('messages')
          .select('id')
          .eq('is_read', false)
          .neq('sender_id', userId);
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  // --------------------------------------------------------------------------
  // SEED & FALLBACK DATA HELPERS
  // --------------------------------------------------------------------------
  List<PhotographerModel> _getSeedPhotographers() {
    return [
      PhotographerModel(
        id: 'photo_arjun_mehta',
        userId: 'user_arjun',
        name: 'Arjun Mehta',
        email: 'arjun@pyp.com',
        phone: '+91 98201 12345',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
        coverImageUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1200&q=80',
        bio: 'Award-winning celebrity and high-fashion editorial photographer with 8+ years experience in Mumbai & Paris.',
        tagline: 'Vogue Featured • Cinematic Light Specialist',
        categories: ['Wedding', 'Portrait', 'Fashion', 'Editorial'],
        styles: ['Cinematic', 'Editorial', 'Moody & Dark', 'Vibrant & Warm'],
        equipment: ['Sony A7 IV', '85mm f/1.4 GM', '50mm f/1.2 GM', 'Profoto B10 Plus', 'Godox AD200'],
        startingPrice: 4999.0,
        hourlyRate: 2499.0,
        rating: 4.95,
        reviewCount: 128,
        experienceYears: 8,
        location: 'Bandra West, Mumbai',
        latitude: 19.0596,
        longitude: 72.8295,
        portfolioImages: [
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
        ],
        createdAt: DateTime.now(),
      ),
      PhotographerModel(
        id: 'photo_priya_sharma',
        userId: 'user_priya',
        name: 'Priya Sharma',
        email: 'priya@pyp.com',
        phone: '+91 98202 23456',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500&q=80',
        coverImageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=1200&q=80',
        bio: 'Specializing in royal Indian destination weddings, candid emotional moments, and heirloom visual stories.',
        tagline: 'Luxury Destination Wedding & Candid Storyteller',
        categories: ['Wedding', 'Event', 'Portrait'],
        styles: ['Candid', 'Vibrant & Warm', 'Cinematic'],
        equipment: ['Canon R5', '28-70mm f/2 L', '70-200mm f/2.8 IS', 'Profoto A1X'],
        startingPrice: 7999.0,
        hourlyRate: 3500.0,
        rating: 4.92,
        reviewCount: 94,
        experienceYears: 6,
        location: 'Juhu, Mumbai',
        latitude: 19.1075,
        longitude: 72.8263,
        createdAt: DateTime.now(),
      ),
      PhotographerModel(
        id: 'photo_kabir_sen',
        userId: 'user_kabir',
        name: 'Kabir Sen',
        email: 'kabir@pyp.com',
        phone: '+91 98203 34567',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
        coverImageUrl: 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=1200&q=80',
        bio: 'Viral 9:16 short-form creator, reel director, and certified 4K cinema drone pilot for luxury brands and festivals.',
        tagline: 'Viral Reels & 4K Cinema Drone Specialist',
        categories: ['Reels', 'Drone', 'Event', 'Commercial'],
        styles: ['Cinematic', 'Vibrant & Warm', 'Commercial'],
        equipment: ['Sony FX3', 'DJI Mavic 3 Pro', 'DJI Ronin RS3', 'Wireless Lavalier Mics'],
        startingPrice: 3999.0,
        hourlyRate: 1999.0,
        rating: 4.88,
        reviewCount: 76,
        experienceYears: 5,
        location: 'Andheri West, Mumbai',
        latitude: 19.1363,
        longitude: 72.8277,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<PackageModel> _getDefaultPackages(String photographerId) {
    return [
      PackageModel(
        id: 'pkg_standard',
        photographerId: photographerId,
        title: 'Editorial Portrait Standard',
        description: 'Perfect for studio headshots, model portfolios, and personal branding.',
        price: 4999.0,
        durationMinutes: 120,
        inclusions: [
          '2 Hours High-End Shoot',
          '35 Color Graded High-Res Photos',
          '2 Outfit Looks & Moodboard Styling',
          'Online High-Res Delivery Gallery',
          '3-Day Turnaround Guarantee',
        ],
        deliverablesCount: 35,
        turnaroundDays: 3,
        isPopular: true,
      ),
      PackageModel(
        id: 'pkg_cinematic',
        photographerId: photographerId,
        title: 'Cinematic Story & 4K Reels',
        description: 'Comprehensive photography session plus 3 viral-ready 9:16 video reels with sound design.',
        price: 8999.0,
        durationMinutes: 240,
        inclusions: [
          '4 Hours Half-Day Shoot',
          '75 Color Graded High-Res Photos',
          '3 Viral 9:16 Reels Edited & Graded',
          'Drone Establishing Shots Included',
          'Online Private Gallery for 1 Year',
        ],
        deliverablesCount: 75,
        turnaroundDays: 5,
        isPopular: false,
      ),
    ];
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Alias for seamless backward-compatibility during provider migration
final firestoreServiceProvider = supabaseServiceProvider;
