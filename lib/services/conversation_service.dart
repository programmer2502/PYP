import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../core/supabase/supabase_config.dart';
import 'supabase_service.dart';
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
  Stream<List<ChatMessageModel>> streamMessages(String bookingId) {
    try {
      return _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('booking_id', bookingId)
          .order('created_at', ascending: true)
          .map((list) => list.map((data) => ChatMessageModel.fromMap(data)).toList());
    } catch (e) {
      debugPrint('ConversationService.streamMessages error: $e');
      return Stream.value([]);
    }
  }

  /// Realtime Stream of Conversation List (Inbox) with Booking Context & User Data
  Stream<List<ConversationModel>> streamUserConversations(String userId) {
    try {
      return _client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('customer_id', userId)
          .map((list) => list.map((data) => ConversationModel.fromMap(data)).toList());
    } catch (e) {
      debugPrint('ConversationService.streamUserConversations error: $e');
      return Stream.value([]);
    }
  }

  /// Realtime Stream of Single Conversation & Booking Context
  Stream<ConversationModel?> streamConversationContext(String bookingId) {
    try {
      return _client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('id', bookingId)
          .map((list) {
        if (list.isEmpty) return null;
        return ConversationModel.fromMap(list.first);
      });
    } catch (e) {
      debugPrint('ConversationService.streamConversationContext error: $e');
      return Stream.value(null);
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
      // 1. Insert Message to Supabase PostgreSQL
      await _client.from('messages').insert(message.toMap());

      // 2. Update Booking Conversation Metadata
      await _client.from('bookings').update({
        'last_message': message.text.isNotEmpty ? message.text : '[Attachment]',
        'last_message_time': message.createdAt.toIso8601String(),
        'last_sender_id': message.senderId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

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
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('booking_id', bookingId)
          .neq('sender_id', currentUserId);
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
