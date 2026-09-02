import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/photographer_provider.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  bool _isCancelling = false;

  Future<void> _handleCancelBooking(BookingModel booking) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Booking?',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this booking? Free cancellation is applicable if done >24 hours prior to the session.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: AppColors.textPrimaryLight),
              decoration: InputDecoration(
                hintText: 'Reason for cancellation...',
                fillColor: AppColors.backgroundLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorderLight),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isCancelling = true);
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final user = ref.read(userProfileProvider).value;

        await firestoreService.updateBookingStatus(
          bookingId: booking.id,
          status: AppConstants.statusCancelled,
          cancellationReason: reasonController.text.trim().isNotEmpty
              ? reasonController.text.trim()
              : 'Cancelled by client',
          cancelledBy: user?.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully.'),
              backgroundColor: AppColors.info,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(singleBookingStreamProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimaryLight),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: bookingAsync.when(
          data: (booking) {
            if (booking == null) {
              return const ErrorView(message: 'Booking not found');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Header
                  Container(
                    padding: const EdgeInsets.all(18),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking Reference',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '#${booking.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        StatusBadge(status: booking.status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Timeline
                  const Text(
                    'Booking Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTimeline(booking.status),
                  const SizedBox(height: 24),

                  // Photographer Info
                  const Text(
                    'Creator Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorderLight),
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
                              Text(
                                booking.photographerName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                booking.packageTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.badgeGreenBg,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 20),
                            onPressed: () => context.push('/chat/${booking.id}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Session Schedule & Venue
                  const Text(
                    'Session Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorderLight),
                    ),
                    child: Column(
                      children: [
                        _buildRow(Icons.calendar_today_rounded, 'Date', DateFormatter.formatDate(booking.eventDate)),
                        const Divider(color: AppColors.cardBorderLight, height: 20),
                        _buildRow(Icons.schedule_rounded, 'Time', booking.timeSlot),
                        const Divider(color: AppColors.cardBorderLight, height: 20),
                        _buildRow(Icons.pin_drop_outlined, 'Location', booking.locationAddress),
                        if (booking.customNotes != null && booking.customNotes!.isNotEmpty) ...[
                          const Divider(color: AppColors.cardBorderLight, height: 20),
                          _buildRow(Icons.notes_rounded, 'Special Notes', booking.customNotes!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Summary
                  const Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorderLight),
                    ),
                    child: Column(
                      children: [
                        _buildRow(Icons.receipt_outlined, 'Base Price', CurrencyFormatter.format(booking.basePrice)),
                        const SizedBox(height: 8),
                        _buildRow(Icons.shield_outlined, 'Protection Fee', CurrencyFormatter.format(booking.platformFee)),
                        const SizedBox(height: 8),
                        _buildRow(Icons.account_balance_outlined, 'Taxes', CurrencyFormatter.format(booking.taxAmount)),
                        const Divider(color: AppColors.cardBorderLight, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Paid',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(booking.totalAmount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Deliverables Button
                  if (booking.status == AppConstants.statusDelivered ||
                      booking.status == AppConstants.statusCompleted) ...[
                    CustomButton(
                      text: 'View & Download Deliverables',
                      icon: Icons.photo_library_outlined,
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      onPressed: () => context.push('/deliverables/${booking.id}'),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Review Button
                  if ((booking.status == AppConstants.statusCompleted ||
                          booking.status == AppConstants.statusDelivered) &&
                      !booking.hasReviewed) ...[
                    CustomButton(
                      text: 'Write a Review for ${booking.photographerName}',
                      isSecondary: true,
                      icon: Icons.star_outline_rounded,
                      onPressed: () => context.push(
                        '/review/${booking.id}',
                        extra: booking,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Cancel Booking Button
                  if (booking.canCancel) ...[
                    CustomButton(
                      text: 'Cancel Booking',
                      isOutlined: true,
                      textColor: AppColors.error,
                      backgroundColor: Colors.white,
                      isLoading: _isCancelling,
                      onPressed: () => _handleCancelBooking(booking),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: LoadingIndicator(message: 'Loading booking...')),
          error: (e, _) => ErrorView(message: e.toString()),
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final steps = [
      {'key': AppConstants.statusRequested, 'title': 'Requested'},
      {'key': AppConstants.statusConfirmed, 'title': 'Confirmed'},
      {'key': AppConstants.statusShootDay, 'title': 'Shoot Day'},
      {'key': AppConstants.statusEditing, 'title': 'Editing'},
      {'key': AppConstants.statusDelivered, 'title': 'Delivered'},
      {'key': AppConstants.statusCompleted, 'title': 'Completed'},
    ];

    if (currentStatus == AppConstants.statusCancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              'This booking has been cancelled.',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    int currentIdx = steps.indexWhere((s) => s['key'] == currentStatus);
    if (currentIdx == -1) currentIdx = 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderLight),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final isPast = index <= currentIdx;
          final isCurrent = index == currentIdx;
          final isLast = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : isPast
                              ? AppColors.primary
                              : AppColors.backgroundLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPast ? AppColors.primary : AppColors.cardBorderLight,
                      ),
                    ),
                    child: Center(
                      child: isPast
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 28,
                      color: isPast ? AppColors.primary : AppColors.cardBorderLight,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    steps[index]['title']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isPast ? AppColors.textPrimaryLight : AppColors.textMutedLight,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
