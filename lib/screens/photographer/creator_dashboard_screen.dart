import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/booking_model.dart';
import '../../models/availability_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../services/supabase_service.dart';

class CreatorDashboardScreen extends ConsumerStatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  ConsumerState<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends ConsumerState<CreatorDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final profileAsync = ref.watch(creatorProfileProvider);
    final user = ref.watch(currentUserProvider);

    final pAvatar = profileAsync.value?.avatarUrl;
    final uAvatar = user?.avatarUrl;
    final String? avatarUrl = (pAvatar != null && pAvatar.isNotEmpty)
        ? pAvatar
        : (uAvatar != null && uAvatar.isNotEmpty ? uAvatar : null);
    final String creatorDisplayName = profileAsync.value?.name ?? (user?.name ?? 'Creator Studio');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(
                      creatorDisplayName.isNotEmpty ? creatorDisplayName[0].toUpperCase() : 'C',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creatorDisplayName,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: const [
                      Icon(Icons.verified_rounded, color: AppColors.primary, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Verified Studio Pro',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Online / Offline Toggle
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: (profileAsync.value?.isOnline ?? true)
                        ? const Color(0xFF00A86B)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  (profileAsync.value?.isOnline ?? true) ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: (profileAsync.value?.isOnline ?? true)
                        ? const Color(0xFF00A86B)
                        : Colors.grey,
                  ),
                ),
                Switch.adaptive(
                  value: profileAsync.value?.isOnline ?? true,
                  activeThumbColor: const Color(0xFF00A86B),
                  onChanged: (val) async {
                    if (user != null) {
                      final db = ref.read(supabaseServiceProvider);
                      await db.togglePhotographerOnlineStatus(user.id, val);
                      ref.invalidate(creatorProfileProvider);
                    }
                  },
                ),
              ],
            ),
          ),

          // Notifications bell with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimaryLight),
                tooltip: 'Notifications',
                onPressed: () => context.push('/creator-notifications'),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _HomeTab(onTabChange: (i) => setState(() => _currentTabIndex = i)),
          const _CalendarTab(),
          const _BookingsTab(),
          const _MessagesTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note_rounded),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 0: HOME / DASHBOARD OVERVIEW
// ============================================================================
class _HomeTab extends ConsumerWidget {
  final Function(int) onTabChange;

  const _HomeTab({required this.onTabChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(creatorBookingsStreamProvider);
    final earningsAsync = ref.watch(creatorEarningsProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(creatorEarningsProvider);
        ref.invalidate(creatorProfileProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Studio Performance & Earnings Cards
            earningsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => const SizedBox.shrink(),
              data: (earnings) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Available Payout',
                          value: '₹${earnings.availableEarnings.toInt()}',
                          subtitle: 'Instant Payout Ready',
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF00A86B),
                          onTap: () => context.push('/creator-earnings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Pending Escrow',
                          value: '₹${earnings.pendingEarnings.toInt()}',
                          subtitle: 'In shoot / editing',
                          icon: Icons.hourglass_top_rounded,
                          color: const Color(0xFFF59E0B),
                          onTap: () => context.push('/creator-earnings'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Completed Shoots',
                          value: '${earnings.completedShootsCount} Shoots',
                          subtitle: '100% On-Time Delivery',
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF2563EB),
                          onTap: () => onTabChange(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Profile Conversion',
                          value: '18.5%',
                          subtitle: 'Top 5% in Mumbai',
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF8B5CF6),
                          onTap: () => onTabChange(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pending Booking Requests Banner
            bookingsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (bookings) {
                final pendingList = bookings
                    .where((b) => b.status == 'pending' || b.status == 'requested')
                    .toList();
                if (pendingList.isEmpty) return const SizedBox.shrink();

                final firstReq = pendingList.first;
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 20),
                              SizedBox(width: 6),
                              Text(
                                'NEW BOOKING REQUEST',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${pendingList.length} PENDING',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${firstReq.customerName} requested ${firstReq.eventType}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd MMM').format(firstReq.shootDate)} • ${firstReq.timeSlot} • ₹${firstReq.totalAmount.toInt()}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.push('/creator-booking/${firstReq.id}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Review & Accept',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Today's Booking Section
            bookingsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (bookings) {
                final today = DateTime.now();
                final todayBookings = bookings.where((b) {
                  return b.shootDate.year == today.year &&
                      b.shootDate.month == today.month &&
                      b.shootDate.day == today.day &&
                      b.status != 'cancelled' &&
                      b.status != 'rejected';
                }).toList();

                if (todayBookings.isEmpty) return const SizedBox.shrink();
                final todayShoot = todayBookings.first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Shoot',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                todayShoot.customerName,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'TODAY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(todayShoot.eventType,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Text(todayShoot.timeSlot,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  todayShoot.location,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.push('/chat/${todayShoot.id}'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Chat with Client',
                                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.push('/creator-booking/${todayShoot.id}'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Start Shoot',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

            // Studio Quick Actions
            const Text(
              'Studio Operations',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            _StudioActionTile(
              title: 'Portfolio & 4K Showcase Reels',
              subtitle: 'Upload photos, cinematic video reels, tag styles',
              icon: Icons.photo_library_rounded,
              color: AppColors.primary,
              onTap: () => context.push('/creator-portfolio'),
            ),
            const SizedBox(height: 10),

            _StudioActionTile(
              title: 'Services & Package Management',
              subtitle: 'Manage pricing, video duration, reels count, add-ons',
              icon: Icons.sell_rounded,
              color: const Color(0xFFF59E0B),
              onTap: () => context.push('/creator-packages'),
            ),
            const SizedBox(height: 10),

            _StudioActionTile(
              title: 'Earnings Ledger & Payout Settings',
              subtitle: 'View escrow settlements, bank account and UPI details',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF00A86B),
              onTap: () => context.push('/creator-earnings'),
            ),
            const SizedBox(height: 10),

            _StudioActionTile(
              title: 'Client Reviews & Reputation',
              subtitle: 'Read verified shoot feedback and ratings breakdown',
              icon: Icons.star_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () => context.push('/creator-reviews'),
            ),
            const SizedBox(height: 28),

            // Upcoming Bookings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Confirmed Shoots',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () => onTabChange(2),
                  child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => const SizedBox.shrink(),
              data: (bookings) {
                final confirmedList = bookings
                    .where((b) => b.status == 'confirmed' || b.status == 'shoot_day')
                    .take(3)
                    .toList();

                if (confirmedList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text('No upcoming confirmed shoots',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Accepted requests will show here.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: confirmedList.map((b) => _buildBookingCard(context, b)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel b) {
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(b.shootDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.customerName,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹${b.totalAmount.toInt()}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(b.eventType, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('$dateStr • ${b.timeSlot}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b.location,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => context.push('/creator-booking/${b.id}'),
                child: const Text(
                  'Manage Shoot →',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: CALENDAR & AVAILABILITY MANAGEMENT
// ============================================================================
class _CalendarTab extends ConsumerStatefulWidget {
  const _CalendarTab();

  @override
  ConsumerState<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<_CalendarTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final availabilityAsync = ref.watch(creatorAvailabilityProvider);
    final bookingsAsync = ref.watch(creatorBookingsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Working Hours
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Studio Calendar',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                tooltip: 'Working Hours',
                onPressed: () => _showWorkingHoursDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Control your open slots, mark blackout dates, and prevent double bookings.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Status Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(const Color(0xFF00A86B), 'Available'),
                _buildLegendItem(Colors.red, 'Booked'),
                _buildLegendItem(const Color(0xFFF59E0B), 'Pending'),
                _buildLegendItem(Colors.grey, 'Blocked'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Calendar Card (CalendarDatePicker)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Selected Date Details Card
          _buildDateStatusCard(context, ref, _selectedDate, availabilityAsync.value ?? [], bookingsAsync.value ?? []),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDateStatusCard(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    List<AvailabilityModel> availList,
    List<BookingModel> bookings,
  ) {
    final dateBookings = bookings.where((b) {
      return b.shootDate.year == date.year &&
          b.shootDate.month == date.month &&
          b.shootDate.day == date.day &&
          b.status != 'cancelled' &&
          b.status != 'rejected';
    }).toList();

    final availMatch = availList.firstWhere(
      (a) =>
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day,
      orElse: () => AvailabilityModel(
        id: 'avail_default',
        photographerId: '',
        date: date,
        status: dateBookings.isNotEmpty ? 'BOOKED' : 'AVAILABLE',
        createdAt: DateTime.now(),
      ),
    );

    final isBlocked = availMatch.status == 'BLOCKED';
    final formatted = DateFormat('EEEE, dd MMMM yyyy').format(date);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatted,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBlocked
                      ? Colors.grey.shade200
                      : (dateBookings.isNotEmpty
                          ? Colors.red.shade50
                          : const Color(0xFF00A86B).withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBlocked
                      ? 'UNAVAILABLE'
                      : (dateBookings.isNotEmpty ? 'BOOKED' : 'AVAILABLE'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isBlocked
                        ? Colors.grey.shade700
                        : (dateBookings.isNotEmpty ? Colors.red : const Color(0xFF00A86B)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (dateBookings.isNotEmpty) ...[
            const Text('Confirmed Sessions on this day:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey)),
            const SizedBox(height: 6),
            ...dateBookings.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_seat_rounded, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${b.customerName} (${b.timeSlot}) - ${b.eventType}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 12),
                        onPressed: () => context.push('/creator-booking/${b.id}'),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final user = ref.read(currentUserProvider);
                    if (user == null) return;
                    final db = ref.read(supabaseServiceProvider);

                    final newStatus = isBlocked ? 'AVAILABLE' : 'BLOCKED';
                    final model = AvailabilityModel(
                      id: 'avail_${user.id}_${date.year}_${date.month}_${date.day}',
                      photographerId: user.id,
                      date: date,
                      status: newStatus,
                      createdAt: DateTime.now(),
                    );
                    await db.setAvailabilityDate(model);
                    ref.invalidate(creatorAvailabilityProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBlocked ? 'Date marked as Available' : 'Date marked as Blocked / Unavailable'),
                          backgroundColor: isBlocked ? const Color(0xFF00A86B) : Colors.black87,
                        ),
                      );
                    }
                  },
                  icon: Icon(isBlocked ? Icons.check_circle_outline : Icons.block_rounded,
                      size: 16, color: Colors.white),
                  label: Text(
                    isBlocked ? 'Mark Available' : 'Block this Day',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBlocked ? const Color(0xFF00A86B) : Colors.grey.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWorkingHoursDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Studio Working Hours',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Clients can only book within your daily operational window.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Start Time', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('08:00 AM', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('End Time', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('08:00 PM', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Working Hours',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: BOOKINGS LIST & REQUESTS MANAGEMENT
// ============================================================================
class _BookingsTab extends ConsumerStatefulWidget {
  const _BookingsTab();

  @override
  ConsumerState<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends ConsumerState<_BookingsTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(creatorBookingsStreamProvider);

    return Column(
      children: [
        // Filter Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Requests', 'Confirmed', 'Shoot Day', 'Completed'].map((filter) {
                final isSel = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // List View
        Expanded(
          child: bookingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(child: Text('Error loading bookings: $err')),
            data: (bookings) {
              final filtered = bookings.where((b) {
                if (_selectedFilter == 'Requests') {
                  return b.status == 'pending' || b.status == 'requested';
                }
                if (_selectedFilter == 'Confirmed') {
                  return b.status == 'confirmed';
                }
                if (_selectedFilter == 'Shoot Day') {
                  return b.status == 'shoot_day' || b.status == 'in_progress';
                }
                if (_selectedFilter == 'Completed') {
                  return b.status == 'completed' || b.status == 'delivered';
                }
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No $_selectedFilter bookings found',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final b = filtered[index];
                  return _buildFullBookingCard(context, b);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFullBookingCard(BuildContext context, BookingModel b) {
    final dateStr = DateFormat('dd MMM yyyy').format(b.shootDate);
    final isPending = b.status == 'pending' || b.status == 'requested';

    final hasCustAvatar = b.customerAvatar != null && b.customerAvatar!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending ? const Color(0xFFF59E0B) : Colors.grey.shade200,
          width: isPending ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: hasCustAvatar ? NetworkImage(b.customerAvatar!) : null,
                child: !hasCustAvatar
                    ? Text(
                        b.customerName.isNotEmpty ? b.customerName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.customerName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(b.eventType, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text(
                '₹${b.totalAmount.toInt()}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('$dateStr • ${b.timeSlot}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b.location,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/chat/${b.id}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/creator-booking/${b.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Manage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 3: REALTIME CHAT MESSAGES INBOX
// ============================================================================
class _MessagesTab extends ConsumerWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(creatorBookingsStreamProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, _) => Center(child: Text('Error loading inbox: $err')),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('No Active Conversations',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Messages with your clients will appear here.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final b = bookings[index];
            final hasCustAvatar = b.customerAvatar != null && b.customerAvatar!.isNotEmpty;

            return ListTile(
              onTap: () => context.push('/chat/${b.id}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: hasCustAvatar ? NetworkImage(b.customerAvatar!) : null,
                child: !hasCustAvatar
                    ? Text(
                        b.customerName.isNotEmpty ? b.customerName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              title: Text(
                b.customerName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                '${b.eventType} • ${b.status.toUpperCase()}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// TAB 4: CREATOR PROFILE & PUBLIC PREVIEW
// ============================================================================
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(creatorProfileProvider);
    final user = ref.watch(currentUserProvider);
    final profile = profileAsync.value;

    final pAvatar = profile?.avatarUrl;
    final uAvatar = user?.avatarUrl;
    final String? avatarUrl = (pAvatar != null && pAvatar.isNotEmpty)
        ? pAvatar
        : (uAvatar != null && uAvatar.isNotEmpty ? uAvatar : null);
    final String creatorName = profile?.name ?? (user?.name ?? 'Creator Studio');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(
                          creatorName.isNotEmpty ? creatorName[0].toUpperCase() : 'C',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  creatorName,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.tagline.isNotEmpty == true
                      ? profile!.tagline
                      : 'Verified Professional Visual Creator',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatPill(
                      profile?.rating != null && profile!.rating > 0
                          ? '★ ${profile.rating.toStringAsFixed(1)}'
                          : '★ --',
                      'Rating',
                    ),
                    const SizedBox(width: 12),
                    _buildStatPill(
                      profile?.experienceYears != null && profile!.experienceYears > 0
                          ? '${profile.experienceYears} Yrs'
                          : '-- Yrs',
                      'Experience',
                    ),
                    const SizedBox(width: 12),
                    _buildStatPill(
                      profile?.startingPrice != null && profile!.startingPrice > 0
                          ? '₹${profile.startingPrice.toInt()}'
                          : '₹--',
                      'Starting',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Preview Public Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final id = profile?.id ?? (user?.id ?? '');
                      if (id.isNotEmpty) {
                        context.push('/photographer/$id');
                      }
                    },
                    icon: const Icon(Icons.visibility_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Preview Public Profile (Client View)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Studio Management Navigation Links
          const Text(
            'Studio Settings',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),

          _buildProfileNavTile(
            title: 'Portfolio & 4K Showcase Reels',
            icon: Icons.photo_library_outlined,
            onTap: () => context.push('/creator-portfolio'),
          ),
          _buildProfileNavTile(
            title: 'Services & Package Tiers',
            icon: Icons.sell_outlined,
            onTap: () => context.push('/creator-packages'),
          ),
          _buildProfileNavTile(
            title: 'Bank & UPI Payout Settings',
            icon: Icons.account_balance_outlined,
            onTap: () => context.push('/creator-payout-settings'),
          ),
          _buildProfileNavTile(
            title: 'Client Reviews & Ratings',
            icon: Icons.star_border_rounded,
            onTap: () => context.push('/creator-reviews'),
          ),
          _buildProfileNavTile(
            title: 'Switch to Client Mode',
            icon: Icons.swap_horiz_rounded,
            onTap: () => context.go(AppRoutes.home),
          ),
          _buildProfileNavTile(
            title: 'Sign Out',
            icon: Icons.logout_rounded,
            color: Colors.red,
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go(AppRoutes.roleSelection);
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatPill(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildProfileNavTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: color ?? AppColors.textPrimaryLight,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _StudioActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StudioActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
