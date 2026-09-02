import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/network_image_view.dart';
import '../../models/package_model.dart';
import '../../models/photographer_model.dart';

class BookingSummaryScreen extends ConsumerWidget {
  final Map<String, dynamic> bookingData;

  const BookingSummaryScreen({
    super.key,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photographer = bookingData['photographer'] as PhotographerModel;
    final package = bookingData['package'] as PackageModel?;
    final eventDate = bookingData['eventDate'] as DateTime;
    final timeSlot = bookingData['timeSlot'] as String;
    final eventType = bookingData['eventType'] as String;
    final locationAddress = bookingData['locationAddress'] as String;
    final customNotes = bookingData['customNotes'] as String?;
    final basePrice = bookingData['basePrice'] as double;
    final platformFee = bookingData['platformFee'] as double;
    final taxAmount = bookingData['taxAmount'] as double;
    final totalAmount = bookingData['totalAmount'] as double;

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
          'Booking Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Midnight Header Creator Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkHeader,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkHeader.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: NetworkImageView(
                        imageUrl: photographer.avatarUrl,
                        width: 56,
                        height: 56,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            photographer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            package?.title ?? '$eventType Session',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            photographer.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkHeaderSubtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Session Details Card
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today_rounded,
                      'Date',
                      DateFormatter.formatDate(eventDate),
                      AppColors.badgeGreenBg,
                      AppColors.badgeGreenIcon,
                    ),
                    const Divider(color: AppColors.cardBorderLight, height: 24),
                    _buildDetailRow(
                      Icons.schedule_rounded,
                      'Time Slot',
                      timeSlot,
                      AppColors.badgeSkyBg,
                      AppColors.badgeSkyIcon,
                    ),
                    const Divider(color: AppColors.cardBorderLight, height: 24),
                    _buildDetailRow(
                      Icons.category_outlined,
                      'Shoot Type',
                      eventType,
                      AppColors.badgeCoralBg,
                      AppColors.badgeCoralIcon,
                    ),
                    const Divider(color: AppColors.cardBorderLight, height: 24),
                    _buildDetailRow(
                      Icons.pin_drop_outlined,
                      'Venue',
                      locationAddress,
                      AppColors.badgePinkBg,
                      AppColors.badgePinkIcon,
                    ),
                    if (customNotes != null && customNotes.isNotEmpty) ...[
                      const Divider(color: AppColors.cardBorderLight, height: 24),
                      _buildDetailRow(
                        Icons.notes_rounded,
                        'Notes',
                        customNotes,
                        AppColors.badgeAmberBg,
                        AppColors.badgeAmberIcon,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Price Breakdown Card
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Package / Base Rate', basePrice),
                    const SizedBox(height: 10),
                    _buildPriceRow('Platform Protection Fee (5%)', platformFee),
                    const SizedBox(height: 10),
                    _buildPriceRow('GST / Taxes (18%)', taxAmount),
                    const Divider(color: AppColors.cardBorderLight, height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(totalAmount),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Guarantee Badge Pill
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.badgeGreenBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.badgeGreenIcon, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PYP 100% Protection: Free cancellation up to 24 hours prior to the shoot date with instant full refund.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 5. Proceed CTA Button
              CustomButton(
                text: 'Proceed to Payment (${CurrencyFormatter.format(totalAmount)})',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: () {
                  context.push(
                    '/payment-checkout',
                    extra: bookingData,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color bg, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount) {
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
          CurrencyFormatter.format(amount),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
