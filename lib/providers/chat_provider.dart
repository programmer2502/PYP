import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message_model.dart';
import '../models/deliverable_file_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// Stream of messages for a specific booking chat via Supabase Realtime
final chatMessagesStreamProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, bookingId) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamMessages(bookingId);
});

// Stream of unread messages count for the current user
final totalUnreadCountStreamProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return 0;

  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getUnreadMessagesCount(user.id);
});

// Stream of deliverables for a booking
final deliverablesStreamProvider =
    FutureProvider.family<List<DeliverableFileModel>, String>((ref, bookingId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getDeliverables(bookingId);
});
