import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../services/payment_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final service = PaymentService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Stream of all bookings for the currently signed-in user via Supabase Realtime
final customerBookingsStreamProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value([]);

  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.streamUserBookings(user.id);
});

// Single booking provider
final singleBookingProvider =
    FutureProvider.family<BookingModel?, String>((ref, bookingId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final user = ref.watch(userProfileProvider).value;
  final bookings = await supabaseService.getUserBookings(user?.id ?? 'user_naveen');
  return bookings.firstWhere((b) => b.id == bookingId, orElse: () => bookings.first);
});

// Single booking stream
final singleBookingStreamProvider =
    StreamProvider.family<BookingModel?, String>((ref, bookingId) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final user = ref.watch(userProfileProvider).value;
  return supabaseService.streamUserBookings(user?.id ?? 'user_naveen').map((list) {
    if (list.isEmpty) return null;
    return list.firstWhere((b) => b.id == bookingId, orElse: () => list.first);
  });
});
