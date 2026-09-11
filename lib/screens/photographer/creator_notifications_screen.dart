import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/creator_provider.dart';
import '../../services/supabase_service.dart';

class CreatorNotificationsScreen extends ConsumerWidget {
  const CreatorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(creatorNotificationsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimaryLight, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Studio Notifications',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Notifications Yet',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'New booking alerts, chat messages, and escrow updates will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notif = notifs[index];
              return _buildNotificationTile(context, ref, notif);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, WidgetRef ref, NotificationModel notif) {
    IconData icon = Icons.notifications_rounded;
    Color color = AppColors.primary;

    switch (notif.type) {
      case 'booking_request':
        icon = Icons.calendar_month_rounded;
        color = const Color(0xFF2563EB);
        break;
      case 'payment_completed':
        icon = Icons.account_balance_wallet_rounded;
        color = const Color(0xFF00A86B);
        break;
      case 'chat_message':
        icon = Icons.chat_bubble_rounded;
        color = AppColors.primary;
        break;
      case 'review':
        icon = Icons.star_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case 'shoot_reminder':
        icon = Icons.alarm_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.primary;
    }

    final timeStr = DateFormat('hh:mm a • dd MMM').format(notif.createdAt);

    return InkWell(
      onTap: () async {
        if (!notif.isRead) {
          final db = ref.read(supabaseServiceProvider);
          await db.markNotificationRead(notif.id);
        }

        if (context.mounted && notif.targetRoute != null && notif.targetRoute!.isNotEmpty) {
          context.push(notif.targetRoute!);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? Colors.grey.shade200 : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
