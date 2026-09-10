import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class ChatInboxScreen extends ConsumerWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(customerBookingsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(customerBookingsStreamProvider);
          },
          child: bookingsAsync.when(
            data: (bookings) {
              if (bookings.isEmpty) {
                return ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    EmptyStateView(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No Conversations',
                      message: 'When you book a creator, your dedicated chat channel will appear here.',
                      actionText: 'Find Creators',
                      onAction: () => context.go('/home'),
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _buildConversationTile(context, booking);
                },
              );
            },
            loading: () => const Center(
              child: LoadingIndicator(message: 'Loading conversations...'),
            ),
            error: (e, _) => ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sync_problem_rounded, size: 48, color: AppColors.textSecondaryLight),
                        const SizedBox(height: 12),
                        const Text(
                          'Live updates unavailable',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pull down to refresh or check your connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => ref.invalidate(customerBookingsStreamProvider),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, BookingModel booking) {
    return GestureDetector(
      onTap: () => context.push('/chat/${booking.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarView(
              avatarUrl: booking.photographerAvatar,
              name: booking.photographerName,
              radius: 24,
              showBorder: true,
              borderColor: AppColors.primary,
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
                          booking.photographerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormatter.formatChatTime(booking.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.packageTitle} • ${booking.status.toUpperCase()}',
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
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight, size: 18),
          ],
        ),
      ),
    );
  }
}
