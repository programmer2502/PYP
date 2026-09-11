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
import '../models/availability_model.dart';
import '../models/portfolio_media_model.dart';
import '../models/earnings_model.dart';
import '../models/payout_details_model.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

/// Centralized Database Service powered by Supabase (PostgreSQL + Realtime)
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  // --------------------------------------------------------------------------
  // USER PROFILES
  // --------------------------------------------------------------------------
  Future<bool> isPhotographerUser(String userId) async {
    try {
      final validId = AuthService.toValidUuid(userId);
      final response = await _client
          .from('photographers')
          .select('id')
          .or('user_id.eq.$validId,id.eq.$validId')
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('SupabaseService.isPhotographerUser check notice: $e');
      return false;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final validId = AuthService.toValidUuid(userId);
      final response = await _client
          .from('users')
          .select()
          .eq('id', validId)
          .maybeSingle();

      if (response == null) return null;
      var user = UserModel.fromMap(response);
      if (!user.isPhotographer) {
        final isPhoto = await isPhotographerUser(user.id);
        if (isPhoto) {
          user = user.copyWith(role: 'creator');
        }
      }
      return user;
    } catch (e) {
      debugPrint('SupabaseService.getUserProfile error: $e');
      return null;
    }
  }

  Future<UserModel?> getUserProfileByEmail(String email) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .ilike('email', email.trim())
          .maybeSingle();

      if (response == null) return null;
      var user = UserModel.fromMap(response);
      if (!user.isPhotographer) {
        final isPhoto = await isPhotographerUser(user.id);
        if (isPhoto) {
          user = user.copyWith(role: 'creator');
        }
      }
      return user;
    } catch (e) {
      debugPrint('SupabaseService.getUserProfileByEmail error: $e');
      return null;
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _client.from('users').upsert(user.toMap(), onConflict: 'email');
    } catch (e) {
      debugPrint('SupabaseService.createUserProfile error (retrying with id): $e');
      try {
        await _client.from('users').upsert(user.toMap(), onConflict: 'id');
      } catch (e2) {
        debugPrint('SupabaseService.createUserProfile fallback error: $e2');
      }
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      final validId = AuthService.toValidUuid(user.id);
      await _client
          .from('users')
          .update(user.toMap())
          .eq('id', validId);
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
      return list;
    } catch (e) {
      debugPrint('SupabaseService.getPhotographers error: $e');
      return [];
    }
  }

  Future<PhotographerModel?> getPhotographerById(String id) async {
    try {
      final validId = AuthService.toValidUuid(id);
      final response = await _client
          .from('photographers')
          .select()
          .eq('id', validId)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return PhotographerModel.fromMap(response);
    } catch (e) {
      debugPrint('SupabaseService.getPhotographerById error: $e');
      return null;
    }
  }

  Future<void> createPhotographerProfile(PhotographerModel photographer) async {
    try {
      await _client.from('photographers').upsert(photographer.toMap());
    } catch (e) {
      debugPrint('SupabaseService.createPhotographerProfile error: $e');
    }
  }

  Future<void> updatePhotographerProfile(PhotographerModel photographer) async {
    try {
      final validId = AuthService.toValidUuid(photographer.id);
      await _client.from('photographers').update(photographer.toMap()).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.updatePhotographerProfile error: $e');
      rethrow;
    }
  }

  Future<void> togglePhotographerOnlineStatus(String photographerId, bool isOnline) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      await _client.from('photographers').update({'is_online': isOnline}).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.togglePhotographerOnlineStatus notice: $e');
    }
  }

  // --------------------------------------------------------------------------
  // PACKAGES (Creator Services CRUD)
  // --------------------------------------------------------------------------
  Future<List<PackageModel>> getPackages(String photographerId) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      final response = await _client
          .from('packages')
          .select()
          .eq('photographer_id', validId);

      return (response as List).map((data) => PackageModel.fromMap(data)).toList();
    } catch (e) {
      debugPrint('SupabaseService.getPackages error: $e');
      return [];
    }
  }

  Future<void> createPackage(PackageModel package) async {
    try {
      await _client.from('packages').insert(package.toMap());
    } catch (e) {
      debugPrint('SupabaseService.createPackage error: $e');
      rethrow;
    }
  }

  Future<void> updatePackage(PackageModel package) async {
    try {
      final validId = AuthService.toValidUuid(package.id);
      await _client.from('packages').update(package.toMap()).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.updatePackage error: $e');
      rethrow;
    }
  }

  Future<void> deletePackage(String packageId) async {
    try {
      final validId = AuthService.toValidUuid(packageId);
      await _client.from('packages').delete().eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.deletePackage error: $e');
      rethrow;
    }
  }

  Future<void> togglePackageActive(String packageId, bool isActive) async {
    try {
      final validId = AuthService.toValidUuid(packageId);
      await _client.from('packages').update({'is_active': isActive}).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.togglePackageActive notice: $e');
    }
  }

  // --------------------------------------------------------------------------
  // BOOKINGS (Reservations & Escrow)
  // --------------------------------------------------------------------------
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _client.from('bookings').insert(booking.toDatabaseMap());
    } catch (e) {
      debugPrint('SupabaseService.createBooking error: $e');
      rethrow;
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      final response = await _client
          .from('bookings')
          .select()
          .eq('id', validId)
          .maybeSingle();

      if (response == null) return null;
      return BookingModel.fromMap(response);
    } catch (e) {
      debugPrint('SupabaseService.getBookingById error: $e');
      return null;
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final validId = AuthService.toValidUuid(userId);
      final response = await _client
          .from('bookings')
          .select()
          .eq('customer_id', validId)
          .order('shoot_date', ascending: false);

      return (response as List)
          .map((data) => BookingModel.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getUserBookings error: $e');
      return [];
    }
  }

  /// Resilient Stream of user bookings with instant initial fetch and Realtime updates
  Stream<List<BookingModel>> streamUserBookings(String userId) async* {
    final validId = AuthService.toValidUuid(userId);

    // 1. Emit instant initial data via PostgREST REST
    try {
      final initialData = await getUserBookings(validId);
      yield initialData;
    } catch (e) {
      debugPrint('streamUserBookings initial fetch notice: $e');
    }

    // 2. Listen to Realtime CDC stream with graceful error recovery
    try {
      final realtimeStream = _client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('customer_id', validId)
          .map((list) => list.map((data) => BookingModel.fromMap(data)).toList());

      await for (final update in realtimeStream.handleError((err) {
        debugPrint('streamUserBookings realtime notice: $err');
      })) {
        yield update;
      }
    } catch (e) {
      debugPrint('streamUserBookings realtime setup notice: $e');
    }
  }

  Future<BookingModel> createBookingWithTransaction(BookingModel booking) async {
    try {
      await _client.from('bookings').insert(booking.toDatabaseMap());
      return booking;
    } catch (e) {
      debugPrint('SupabaseService.createBookingWithTransaction error: $e');
      rethrow;
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    String? paymentId,
    String? paymentStatus,
    String? cancellationReason,
    String? cancelledBy,
  }) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      final Map<String, dynamic> updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (paymentId != null) updates['payment_id'] = paymentId;
      if (paymentStatus != null) updates['payment_status'] = paymentStatus;
      if (cancellationReason != null) updates['cancellation_reason'] = cancellationReason;
      if (cancelledBy != null) updates['cancelled_by'] = cancelledBy;

      await _client.from('bookings').update(updates).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.updateBookingStatus error: $e');
      rethrow;
    }
  }

  Future<List<String>> getBookedSlots(String photographerId, DateTime date) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      final response = await _client
          .from('bookings')
          .select('time_slot')
          .eq('photographer_id', validId)
          .gte('shoot_date', start.toIso8601String())
          .lt('shoot_date', end.toIso8601String());

      return (response as List).map((e) => e['time_slot'].toString()).toList();
    } catch (e) {
      debugPrint('SupabaseService.getBookedSlots error: $e');
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // REVIEWS
  // --------------------------------------------------------------------------
  Future<List<ReviewModel>> getReviews(String photographerId) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      final response = await _client
          .from('reviews')
          .select()
          .eq('photographer_id', validId)
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

  Future<void> submitReview({required ReviewModel review}) async => addReview(review);

  // --------------------------------------------------------------------------
  // DELIVERABLES
  // --------------------------------------------------------------------------
  Future<List<DeliverableFileModel>> getDeliverables(String bookingId) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      final response = await _client
          .from('deliverables')
          .select()
          .eq('booking_id', validId)
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
  Stream<List<ChatMessageModel>> streamMessages(String bookingId) async* {
    final validId = AuthService.toValidUuid(bookingId);

    // 1. Initial REST fetch
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('booking_id', validId)
          .order('created_at', ascending: true);
      final initial = (response as List).map((d) => ChatMessageModel.fromMap(d)).toList();
      yield initial;
    } catch (e) {
      debugPrint('streamMessages initial fetch notice: $e');
    }

    // 2. Realtime Stream
    try {
      final realtimeStream = _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('booking_id', validId)
          .order('created_at', ascending: true)
          .map((list) => list.map((data) => ChatMessageModel.fromMap(data)).toList());

      await for (final update in realtimeStream.handleError((err) {
        debugPrint('streamMessages realtime notice: $err');
      })) {
        yield update;
      }
    } catch (e) {
      debugPrint('streamMessages realtime setup notice: $e');
    }
  }

  Future<void> sendChatMessage({
    required String bookingId,
    required ChatMessageModel message,
  }) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      await _client.from('messages').insert(message.toDatabaseMap());
      await _client.from('bookings').update({
        'last_message': message.text.isNotEmpty ? message.text : '[Attachment]',
        'last_message_time': message.createdAt.toIso8601String(),
        'last_sender_id': AuthService.toValidUuid(message.senderId),
      }).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.sendChatMessage error: $e');
    }
  }

  Future<void> markMessagesAsRead(String bookingId, String userId) async {
    try {
      final validBookingId = AuthService.toValidUuid(bookingId);
      final validUserId = AuthService.toValidUuid(userId);
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('booking_id', validBookingId)
          .neq('sender_id', validUserId);
    } catch (_) {}
  }

  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final validUserId = AuthService.toValidUuid(userId);
      final response = await _client
          .from('messages')
          .select('id')
          .eq('is_read', false)
          .neq('sender_id', validUserId);
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  // --------------------------------------------------------------------------
  // CREATOR BOOKINGS MANAGEMENT
  // --------------------------------------------------------------------------
  Future<List<BookingModel>> getCreatorBookings(String photographerId) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      final response = await _client
          .from('bookings')
          .select()
          .eq('photographer_id', validId)
          .order('shoot_date', ascending: false);

      return (response as List)
          .map((data) => BookingModel.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getCreatorBookings error: $e');
      return [];
    }
  }

  Stream<List<BookingModel>> streamCreatorBookings(String photographerId) async* {
    final validId = AuthService.toValidUuid(photographerId);

    // Initial fetch
    try {
      final initialData = await getCreatorBookings(validId);
      yield initialData;
    } catch (e) {
      debugPrint('streamCreatorBookings initial fetch notice: $e');
    }

    // Realtime stream
    try {
      final realtimeStream = _client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('photographer_id', validId)
          .map((list) => list.map((data) => BookingModel.fromMap(data)).toList());

      await for (final update in realtimeStream.handleError((err) {
        debugPrint('streamCreatorBookings realtime notice: $err');
      })) {
        yield update;
      }
    } catch (e) {
      debugPrint('streamCreatorBookings realtime setup notice: $e');
    }
  }

  Future<void> acceptBookingRequest(String bookingId) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      await _client.from('bookings').update({
        'status': 'accepted',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.acceptBookingRequest error: $e');
      rethrow;
    }
  }

  Future<void> rejectBookingRequest(String bookingId, {String? reason}) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      await _client.from('bookings').update({
        'status': 'rejected',
        'cancellation_reason': reason ?? 'Declined by creator',
        'cancelled_by': 'photographer',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.rejectBookingRequest error: $e');
      rethrow;
    }
  }

  Future<void> startShootDay(String bookingId) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      await _client.from('bookings').update({
        'status': 'shoot_day',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.startShootDay error: $e');
      rethrow;
    }
  }

  Future<void> completeShootBooking(String bookingId) async {
    try {
      final validId = AuthService.toValidUuid(bookingId);
      await _client.from('bookings').update({
        'status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.completeShootBooking error: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // AVAILABILITY & CALENDAR
  // --------------------------------------------------------------------------
  Future<List<AvailabilityModel>> getPhotographerAvailability(String photographerId) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      final response = await _client
          .from('availability')
          .select()
          .eq('photographer_id', validId);

      return (response as List)
          .map((data) => AvailabilityModel.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getPhotographerAvailability notice: $e');
      return [];
    }
  }

  Future<void> setAvailabilityDate(AvailabilityModel model) async {
    try {
      await _client.from('availability').upsert(model.toMap());
    } catch (e) {
      debugPrint('SupabaseService.setAvailabilityDate error: $e');
      rethrow;
    }
  }

  Future<void> blockTimeSlot(
    String photographerId,
    DateTime date,
    String startTime,
    String endTime, {
    String? notes,
  }) async {
    final validId = AuthService.toValidUuid(photographerId);
    final model = AvailabilityModel(
      id: AuthService.toValidUuid('avail_${validId}_${date.year}_${date.month}_${date.day}'),
      photographerId: validId,
      date: date,
      status: 'BLOCKED',
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await setAvailabilityDate(model);
  }

  // --------------------------------------------------------------------------
  // PORTFOLIO MEDIA (Photos, Videos, Reels)
  // --------------------------------------------------------------------------
  Future<List<PortfolioMediaModel>> getPortfolioMedia(String photographerId) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      final response = await _client
          .from('portfolio_media')
          .select()
          .eq('photographer_id', validId)
          .order('created_at', ascending: false);

      final list = (response as List).map((d) => PortfolioMediaModel.fromMap(d)).toList();
      if (list.isNotEmpty) return list;

      // Seed fallback portfolio items if empty
      final photoProfile = await getPhotographerById(validId);
      if (photoProfile != null && photoProfile.portfolioImages.isNotEmpty) {
        return photoProfile.portfolioImages.map((url) {
          return PortfolioMediaModel(
            id: 'media_${url.hashCode.abs()}',
            photographerId: validId,
            title: 'Featured Portfolio Work',
            mediaUrl: url,
            mediaType: 'PHOTO',
            category: 'Portrait',
            styleTag: 'Cinematic',
            isFeatured: true,
            createdAt: DateTime.now(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('SupabaseService.getPortfolioMedia notice: $e');
      return [];
    }
  }

  Future<void> savePortfolioMedia(PortfolioMediaModel item) async {
    try {
      await _client.from('portfolio_media').upsert(item.toMap());
    } catch (e) {
      debugPrint('SupabaseService.savePortfolioMedia error: $e');
      rethrow;
    }
  }

  Future<void> deletePortfolioMedia(String mediaId) async {
    try {
      final validId = AuthService.toValidUuid(mediaId);
      await _client.from('portfolio_media').delete().eq('id', validId);
    } catch (e) {
      debugPrint('SupabaseService.deletePortfolioMedia error: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // EARNINGS & PAYOUT DETAILS
  // --------------------------------------------------------------------------
  Future<EarningsSummaryModel> getEarningsSummary(String photographerId) async {
    try {
      final bookings = await getCreatorBookings(photographerId);
      double total = 0;
      double pending = 0;
      double available = 0;
      int completedCount = 0;

      for (final b in bookings) {
        if (b.status == 'completed' || b.status == 'delivered') {
          total += b.totalAmount * 0.90; // Net payout after 10% platform fee
          available += b.totalAmount * 0.90;
          completedCount++;
        } else if (b.status == 'confirmed' || b.status == 'shoot_day' || b.status == 'editing') {
          total += b.totalAmount * 0.90;
          pending += b.totalAmount * 0.90;
        }
      }

      return EarningsSummaryModel(
        totalEarnings: total,
        pendingEarnings: pending,
        availableEarnings: available,
        completedShootsCount: completedCount,
        thisMonthGrowthPercent: 0.0,
      );
    } catch (e) {
      debugPrint('SupabaseService.getEarningsSummary notice: $e');
      return EarningsSummaryModel(
        totalEarnings: 0.0,
        pendingEarnings: 0.0,
        availableEarnings: 0.0,
        completedShootsCount: 0,
        thisMonthGrowthPercent: 0.0,
      );
    }
  }

  Future<List<TransactionModel>> getEarningsTransactions(String photographerId) async {
    try {
      final bookings = await getCreatorBookings(photographerId);
      if (bookings.isEmpty) {
        return [];
      }

      return bookings.map((b) => TransactionModel(
        id: 'tx_${b.id}',
        bookingId: b.id,
        bookingNumber: b.id.length > 8 ? b.id.substring(0, 8).toUpperCase() : b.id,
        customerName: b.customerName,
        amount: b.totalAmount,
        platformFee: b.platformFee,
        netPayout: b.totalAmount - b.platformFee,
        status: (b.status == 'completed' || b.status == 'delivered') ? 'completed' : 'escrow_hold',
        createdAt: b.createdAt,
      )).toList();
    } catch (e) {
      debugPrint('SupabaseService.getEarningsTransactions notice: $e');
      return [];
    }
  }

  Future<PayoutDetailsModel?> getPayoutDetails(String photographerId) async {
    try {
      final validId = AuthService.toValidUuid(photographerId);
      final response = await _client
          .from('payout_details')
          .select()
          .eq('photographer_id', validId)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return PayoutDetailsModel.fromMap(response);
    } catch (e) {
      debugPrint('SupabaseService.getPayoutDetails notice: $e');
      return null;
    }
  }

  Future<void> savePayoutDetails(PayoutDetailsModel details) async {
    try {
      await _client.from('payout_details').upsert(details.toMap());
    } catch (e) {
      debugPrint('SupabaseService.savePayoutDetails error: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // NOTIFICATIONS
  // --------------------------------------------------------------------------
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final validId = AuthService.toValidUuid(userId);
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', validId)
          .order('created_at', ascending: false);

      return (response as List).map((d) => NotificationModel.fromMap(d)).toList();
    } catch (e) {
      debugPrint('SupabaseService.getNotifications notice: $e');
      return [];
    }
  }

  Stream<List<NotificationModel>> streamNotifications(String userId) async* {
    final validId = AuthService.toValidUuid(userId);
    try {
      final initial = await getNotifications(validId);
      yield initial;
    } catch (_) {}

    try {
      final realtimeStream = _client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', validId)
          .order('created_at', ascending: false)
          .map((list) => list.map((d) => NotificationModel.fromMap(d)).toList());

      await for (final update in realtimeStream.handleError((_) {})) {
        yield update;
      }
    } catch (_) {}
  }

  Future<void> markNotificationRead(String notificationId) async {
    try {
      final validId = AuthService.toValidUuid(notificationId);
      await _client.from('notifications').update({'is_read': true}).eq('id', validId);
    } catch (_) {}
  }

  Future<void> uploadDeliverableFile(DeliverableFileModel deliverable) async {
    try {
      await _client.from('deliverables').insert(deliverable.toMap());
    } catch (e) {
      debugPrint('SupabaseService.uploadDeliverableFile error: $e');
      rethrow;
    }
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Alias for seamless backward-compatibility during provider migration
final firestoreServiceProvider = supabaseServiceProvider;
