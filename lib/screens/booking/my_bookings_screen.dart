import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(customerBookingsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Active'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: SafeArea(
        child: bookingsAsync.when(
          data: (bookings) {
            final upcoming = bookings.where((b) => b.isUpcoming).toList();
            final inProgress = bookings.where((b) => b.isInProgress).toList();
            final completed = bookings.where((b) => b.isCompleted).toList();
            final cancelled = bookings.where((b) => b.isCancelled).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(upcoming, 'No Upcoming Sessions', 'Book a top photographer for your upcoming events!'),
                _buildBookingList(inProgress, 'No Active Sessions', 'Your in-progress shoots & editing files will appear here.'),
                _buildBookingList(completed, 'No Past Sessions', 'Completed bookings & downloadable galleries will appear here.'),
                _buildBookingList(cancelled, 'No Cancelled Sessions', 'Cancelled requests will appear here.'),
              ],
            );
          },
          loading: () => const Center(
            child: LoadingIndicator(message: 'Loading your bookings...'),
          ),
          error: (e, _) => ErrorView(message: e.toString()),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingModel> items,
    String emptyTitle,
    String emptySubtitle,
  ) {
    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.calendar_today_outlined,
        title: emptyTitle,
        message: emptySubtitle,
        actionText: 'Explore Creators',
        onAction: () => context.go('/home'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = items[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return GestureDetector(
      onTap: () => context.push('/booking/${booking.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarView(
                  avatarUrl: booking.photographerAvatar,
                  name: booking.photographerName,
                  radius: 24,
                  showBorder: true,
                  borderColor: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.photographerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.packageTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: booking.status),
              ],
            ),
            const Divider(color: AppColors.cardBorderLight, height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  DateFormatter.formatDate(booking.eventDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.timeSlot,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(booking.totalAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
