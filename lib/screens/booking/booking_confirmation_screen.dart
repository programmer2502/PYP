import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../providers/booking_provider.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(singleBookingStreamProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: bookingAsync.when(
          data: (booking) {
            if (booking == null) {
              return const Center(child: Text('Booking confirmed. Loading details...'));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Success Badge Icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.badgeGreenBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your session with ${booking.photographerName} has been booked.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Receipt Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.cardBorderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildReceiptRow('Booking Ref', '#${booking.id.substring(0, 8).toUpperCase()}'),
                        const Divider(color: AppColors.cardBorderLight, height: 20),
                        _buildReceiptRow('Shoot Date', DateFormatter.formatDate(booking.eventDate)),
                        const Divider(color: AppColors.cardBorderLight, height: 20),
                        _buildReceiptRow('Time Slot', booking.timeSlot),
                        const Divider(color: AppColors.cardBorderLight, height: 20),
                        _buildReceiptRow('Amount Paid', CurrencyFormatter.format(booking.totalAmount)),
                        if (booking.paymentId != null) ...[
                          const Divider(color: AppColors.cardBorderLight, height: 20),
                          _buildReceiptRow('Payment ID', booking.paymentId!),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  CustomButton(
                    text: 'View Booking Details',
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    onPressed: () => context.go('/booking/${booking.id}'),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Back to Home',
                    isOutlined: true,
                    onPressed: () => context.go('/'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
          loading: () => const Center(child: LoadingIndicator(message: 'Loading confirmation...')),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
