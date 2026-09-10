import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../core/supabase/supabase_config.dart';
import 'auth_service.dart';
import 'notification_service.dart';

/// Conversation API, Supabase Realtime Stream & Notifications Layer
class ConversationService {
  final SupabaseClient _client;
  final NotificationService _notificationService;

  ConversationService({
    SupabaseClient? client,
    NotificationService? notificationService,
  })  : _client = client ?? SupabaseConfig.client,
        _notificationService = notificationService ?? NotificationService();

  /// Realtime Stream of Messages for a specific Booking Conversation via Supabase Realtime CDC
  Stream<List<ChatMessageModel>> streamMessages(String bookingId) async* {
    final validBookingId = AuthService.toValidUuid(bookingId);

    // 1. Initial REST fetch
    try {
      final res = await _client
          .from('messages')
          .select()
          .eq('booking_id', validBookingId)
          .order('created_at', ascending: true);
      final initial = (res as List).map((d) => ChatMessageModel.fromMap(d)).toList();
      yield initial;
    } catch (e) {
      debugPrint('ConversationService.streamMessages initial fetch notice: $e');
    }

    // 2. Realtime Stream
    try {
      final realtimeStream = _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('booking_id', validBookingId)
          .order('created_at', ascending: true)
          .map((list) => list.map((data) => ChatMessageModel.fromMap(data)).toList());

      await for (final update in realtimeStream.handleError((err) {
        debugPrint('ConversationService.streamMessages realtime notice: $err');
      })) {
        yield update;
      }
    } catch (e) {
      debugPrint('ConversationService.streamMessages realtime setup notice: $e');
    }
  }

  /// Realtime Stream of Conversation List (Inbox) with Booking Context & User Data
  Stream<List<ConversationModel>> streamUserConversations(String userId) async* {
    final validUserId = AuthService.toValidUuid(userId);

    // 1. Initial REST fetch
    try {
      final res = await _client
          .from('bookings')
          .select()
          .eq('customer_id', validUserId)
          .order('shoot_date', ascending: false);
      final initial = (res as List).map((d) => ConversationModel.fromMap(d)).toList();
      yield initial;
    } catch (e) {
      debugPrint('ConversationService.streamUserConversations initial fetch notice: $e');
    }

    // 2. Realtime Stream
    try {
      final realtimeStream = _client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('customer_id', validUserId)
          .map((list) => list.map((data) => ConversationModel.fromMap(data)).toList());

      await for (final update in realtimeStream.handleError((err) {
        debugPrint('ConversationService.streamUserConversations realtime notice: $err');
      })) {
        yield update;
      }
    } catch (e) {
      debugPrint('ConversationService.streamUserConversations realtime setup notice: $e');
    }
  }

  /// Realtime Stream of Single Conversation & Booking Context
  Stream<ConversationModel?> streamConversationContext(String bookingId) async* {
    final validBookingId = AuthService.toValidUuid(bookingId);

    // 1. Initial REST fetch
    try {
      final res = await _client
          .from('bookings')
          .select()
          .eq('id', validBookingId)
          .maybeSingle();
      if (res != null) {
        yield ConversationModel.fromMap(res);
      }
    } catch (e) {
      debugPrint('ConversationService.streamConversationContext initial fetch notice: $e');
    }

    // 2. Realtime Stream
    try {
      final realtimeStream = _client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('id', validBookingId)
          .map((list) {
        if (list.isEmpty) return null;
        return ConversationModel.fromMap(list.first);
      });

      await for (final update in realtimeStream.handleError((err) {
        debugPrint('ConversationService.streamConversationContext realtime notice: $err');
      })) {
        yield update;
      }
    } catch (e) {
      debugPrint('ConversationService.streamConversationContext realtime setup notice: $e');
    }
  }

  /// Sends a message, updates conversation lastMessage in Supabase Realtime Layer, and fires Notifications
  Future<void> sendMessage({
    required String bookingId,
    required ChatMessageModel message,
    required String receiverId,
    String? receiverToken,
  }) async {
    try {
      final validBookingId = AuthService.toValidUuid(bookingId);
      // 1. Insert Message to Supabase PostgreSQL
      await _client.from('messages').insert(message.toDatabaseMap());

      // 2. Update Booking Conversation Metadata
      await _client.from('bookings').update({
        'last_message': message.text.isNotEmpty ? message.text : '[Attachment]',
        'last_message_time': message.createdAt.toIso8601String(),
        'last_sender_id': AuthService.toValidUuid(message.senderId),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', validBookingId);

      // 3. Trigger Notification Layer for Receiver
      try {
        await _notificationService.showLocalNotification(
          id: message.createdAt.millisecondsSinceEpoch ~/ 1000,
          title: message.senderName,
          body: message.text.isNotEmpty ? message.text : 'Sent an attachment',
          payload: '/chat/$bookingId',
        );
      } catch (_) {}
    } catch (e) {
      debugPrint('ConversationService.sendMessage error: $e');
    }
  }

  /// Marks all incoming messages as read in the Supabase Realtime Layer
  Future<void> markAsRead(String bookingId, String currentUserId) async {
    try {
      final validBookingId = AuthService.toValidUuid(bookingId);
      final validUserId = AuthService.toValidUuid(currentUserId);
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('booking_id', validBookingId)
          .neq('sender_id', validUserId);
    } catch (_) {}
  }
}

final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService();
});

/// Realtime provider for messages stream
final realtimeMessagesStreamProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, bookingId) {
  final service = ref.watch(conversationServiceProvider);
  return service.streamMessages(bookingId);
});

/// Realtime provider for conversation & booking context stream
final realtimeConversationContextProvider =
    StreamProvider.family<ConversationModel?, String>((ref, bookingId) {
  final service = ref.watch(conversationServiceProvider);
  return service.streamConversationContext(bookingId);
});
