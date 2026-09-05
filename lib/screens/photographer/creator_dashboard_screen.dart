import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Creator Studio',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimaryLight,
                  ),
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
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_rounded, color: AppColors.primary),
            tooltip: 'View Client Feed',
            onPressed: () => context.go(AppRoutes.home),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go(AppRoutes.roleSelection);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Studio Metrics Grid
            Row(
              children: const [
                Expanded(
                  child: _MetricCard(
                    title: 'Escrow Earnings',
                    value: '₹ 68,500',
                    subtitle: '+18% this month',
                    icon: Icons.account_balance_wallet_rounded,
                    color: Color(0xFF00A86B),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Bookings',
                    value: '14 Shoots',
                    subtitle: '3 Upcoming',
                    icon: Icons.event_available_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _MetricCard(
                    title: 'Client Rating',
                    value: '4.95 ★',
                    subtitle: '128 Reviews',
                    icon: Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Profile Views',
                    value: '1.8k Views',
                    subtitle: 'Top 5% Mumbai',
                    icon: Icons.trending_up_rounded,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Actions Section
            const Text(
              'Studio Management',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 14),

            _StudioActionTile(
              title: 'Upload Portfolio & 4K Reels',
              subtitle: 'Add new photos and showcase videos to Supabase Storage',
              icon: Icons.add_photo_alternate_rounded,
              color: AppColors.primary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Portfolio uploader ready. Media synced to Supabase Storage.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            _StudioActionTile(
              title: 'Deliver Client Gallery',
              subtitle: 'Upload finished photos and generate master ZIP download',
              icon: Icons.cloud_upload_rounded,
              color: const Color(0xFF2563EB),
              onTap: () {
                context.push('/deliverables/booking_live_1');
              },
            ),
            const SizedBox(height: 10),

            _StudioActionTile(
              title: 'Manage Packages & Pricing',
              subtitle: 'Edit standard ₹4,999 and cinematic ₹8,999 tiers',
              icon: Icons.sell_rounded,
              color: const Color(0xFFF59E0B),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Packages updated and synced to Supabase PostgreSQL.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Upcoming Shoots List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Shoots',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.bookings),
                  child: const Text('View All', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _ShootCard(
              clientName: 'Aarav & Meera',
              eventType: 'Pre-Wedding & Sunset Shoot',
              dateTime: 'Saturday, 12 Sept • 4:00 PM',
              location: 'Marine Drive & Bandstand, Mumbai',
              status: 'CONFIRMED',
              payout: '₹ 8,999',
            ),
            const SizedBox(height: 12),
            _ShootCard(
              clientName: 'Siddharth Rao',
              eventType: 'Editorial Studio Portrait',
              dateTime: 'Tuesday, 15 Sept • 11:00 AM',
              location: 'Studio A, Khar West, Mumbai',
              status: 'CONFIRMED',
              payout: '₹ 4,999',
            ),
            const SizedBox(height: 24),
          ],
        ),
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

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              fontFamily: 'Outfit',
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
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
              width: 44,
              height: 44,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
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

class _ShootCard extends StatelessWidget {
  final String clientName;
  final String eventType;
  final String dateTime;
  final String location;
  final String status;
  final String payout;

  const _ShootCard({
    required this.clientName,
    required this.eventType,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.payout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                clientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(eventType, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(dateTime, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                payout,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.primary,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
