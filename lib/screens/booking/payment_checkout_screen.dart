import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../models/booking_model.dart';
import '../../models/package_model.dart';
import '../../models/photographer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/photographer_provider.dart';
import '../../services/payment_service.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentCheckoutScreen({
    super.key,
    required this.bookingData,
  });

  @override
  ConsumerState<PaymentCheckoutScreen> createState() =>
      _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends ConsumerState<PaymentCheckoutScreen> {
  String _selectedPaymentMethod = 'razorpay';
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _startPayment() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue booking.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final photographer =
        widget.bookingData['photographer'] as PhotographerModel;
    final package = widget.bookingData['package'] as PackageModel?;
    final eventDate = widget.bookingData['eventDate'] as DateTime;
    final timeSlot = widget.bookingData['timeSlot'] as String;
    final eventType = widget.bookingData['eventType'] as String;
    final locationAddress = widget.bookingData['locationAddress'] as String;
    final customNotes = widget.bookingData['customNotes'] as String?;
    final basePrice = widget.bookingData['basePrice'] as double;
    final platformFee = widget.bookingData['platformFee'] as double;
    final taxAmount = widget.bookingData['taxAmount'] as double;
    final totalAmount = widget.bookingData['totalAmount'] as double;

    final firestoreService = ref.read(firestoreServiceProvider);
    final paymentService = ref.read(paymentServiceProvider);

    try {
      // 1. Double-booking check & atomic booking creation via Firestore Transaction
      final draftBooking = BookingModel(
        id: '', // Will be assigned by Firestore doc
        customerId: user.id,
        customerName: user.name,
        customerPhone: user.phone,
        customerAvatar: user.avatarUrl,
        photographerId: photographer.id,
        photographerName: photographer.name,
        photographerAvatar: photographer.avatarUrl,
        packageId: package?.id ?? 'custom',
        packageTitle: package?.title ?? '$eventType Session',
        eventType: eventType,
        eventDate: eventDate,
        timeSlot: timeSlot,
        locationAddress: locationAddress,
        latitude: photographer.latitude,
        longitude: photographer.longitude,
        customNotes: customNotes,
        basePrice: basePrice,
        platformFee: platformFee,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        status: AppConstants.statusRequested,
        paymentStatus: 'pending',
        createdAt: DateTime.now(),
      );

      final createdBooking =
          await firestoreService.createBookingWithTransaction(draftBooking);

      // 2. Launch Razorpay / Gateway SDK
      paymentService.openCheckout(
        booking: createdBooking,
        userEmail: user.email,
        userPhone: user.phone,
        onResult: (result) async {
          if (result.type == PaymentResultType.success) {
            await firestoreService.updateBookingStatus(
              bookingId: createdBooking.id,
              status: AppConstants.statusConfirmed,
              paymentId: result.paymentId,
              paymentStatus: 'paid',
            );

            if (mounted) {
              context.go('/booking-confirmation/${createdBooking.id}');
            }
          } else {
            await firestoreService.updateBookingStatus(
              bookingId: createdBooking.id,
              status: AppConstants.statusRequested,
              paymentStatus: 'failed',
            );

            if (mounted) {
              setState(() {
                _isProcessing = false;
                _errorMessage = result.errorMessage ??
                    'Payment was cancelled or could not be processed.';
              });
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString().replaceFirst(RegExp(r'^\[.*?\]\s*'), '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.bookingData['totalAmount'] as double;

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
              onPressed: _isProcessing ? null : () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          'Payment Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Midnight Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.darkHeader,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkHeader.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount Due',
                      style: TextStyle(
                        color: AppColors.darkHeaderSubtitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),

              _buildPaymentOption(
                id: 'razorpay',
                title: 'Razorpay / UPI / Cards / NetBanking',
                subtitle: 'GPay, PhonePe, Paytm, All Credit & Debit Cards',
                icon: Icons.account_balance_wallet_outlined,
                badgeBg: AppColors.badgeGreenBg,
                badgeIcon: AppColors.badgeGreenIcon,
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                id: 'stripe',
                title: 'International Cards (Stripe)',
                subtitle: 'Visa, Mastercard, Amex, Apple Pay',
                icon: Icons.credit_card_rounded,
                badgeBg: AppColors.badgeSkyBg,
                badgeIcon: AppColors.badgeSkyIcon,
              ),

              const Spacer(),

              // Security notice
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textSecondaryLight),
                  SizedBox(width: 6),
                  Text(
                    '256-Bit Encrypted Secure Checkout',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Pay CTA
              CustomButton(
                text: 'Pay ${CurrencyFormatter.format(totalAmount)}',
                isLoading: _isProcessing,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: _isProcessing ? null : _startPayment,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color badgeBg,
    required Color badgeIcon,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipSelectedBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: badgeIcon, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.circle, size: 8, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
