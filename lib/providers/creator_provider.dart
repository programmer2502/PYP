import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photographer_model.dart';
import '../models/package_model.dart';
import '../models/booking_model.dart';
import '../models/availability_model.dart';
import '../models/portfolio_media_model.dart';
import '../models/earnings_model.dart';
import '../models/payout_details_model.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// Creator Profile Provider (PhotographerModel)
final creatorProfileProvider = FutureProvider.autoDispose<PhotographerModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.getPhotographerById(user.id);
});

// Creator Realtime Bookings Stream Provider
final creatorBookingsStreamProvider = StreamProvider.autoDispose<List<BookingModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.streamCreatorBookings(user.id);
});

// Creator Packages Provider
final creatorPackagesProvider = FutureProvider.autoDispose<List<PackageModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.getPackages(user.id);
});

// Creator Availability Calendar Provider
final creatorAvailabilityProvider = FutureProvider.autoDispose<List<AvailabilityModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.getPhotographerAvailability(user.id);
});

// Creator Portfolio Media Provider
final creatorPortfolioMediaProvider = FutureProvider.autoDispose<List<PortfolioMediaModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.getPortfolioMedia(user.id);
});

// Creator Earnings Summary Provider
final creatorEarningsProvider = FutureProvider.autoDispose<EarningsSummaryModel>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return EarningsSummaryModel();
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.getEarningsSummary(user.id);
});

// Creator Transactions Ledger Provider
final creatorTransactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.getEarningsTransactions(user.id);
});

// Creator Payout Details Provider
final creatorPayoutDetailsProvider = FutureProvider.autoDispose<PayoutDetailsModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.getPayoutDetails(user.id);
});

// Creator Notifications Stream Provider
final creatorNotificationsStreamProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final dbService = ref.watch(supabaseServiceProvider);
  return dbService.streamNotifications(user.id);
});

// Unread Notifications Count
final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifs = ref.watch(creatorNotificationsStreamProvider).value ?? [];
  return notifs.where((n) => !n.isRead).length;
});
