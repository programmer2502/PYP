import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../providers/creator_provider.dart';
import '../../services/supabase_service.dart';

class CreatorBookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const CreatorBookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<CreatorBookingDetailScreen> createState() => _CreatorBookingDetailScreenState();
}

class _CreatorBookingDetailScreenState extends ConsumerState<CreatorBookingDetailScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _timelineSteps = [
    {'status': 'pending', 'label': 'Requested', 'desc': 'Awaiting your review'},
    {'status': 'accepted', 'label': 'Accepted', 'desc': 'Client notified for payment'},
    {'status': 'confirmed', 'label': 'Confirmed', 'desc': 'Escrow advance deposited'},
    {'status': 'shoot_day', 'label': 'Shoot Day', 'desc': 'In progress on location'},
    {'status': 'completed', 'label': 'Completed', 'desc': 'Editing in progress'},
    {'status': 'delivered', 'label': 'Deliverables', 'desc': 'High-Res gallery delivered'},
  ];

  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'requested':
        return 0;
      case 'accepted':
      case 'payment_pending':
        return 1;
      case 'confirmed':
        return 2;
      case 'shoot_day':
      case 'in_progress':
        return 3;
      case 'completed':
      case 'editing':
        return 4;
      case 'delivered':
      case 'deliverables':
      case 'reviewed':
        return 5;
      case 'rejected':
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(creatorBookingsStreamProvider);

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
          'Booking Management',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
            tooltip: 'Open Chat',
            onPressed: () {
              context.push('/chat/${widget.bookingId}');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (bookings) {
                final booking = bookings.where((b) => b.id == widget.bookingId).firstOrNull;

                if (booking == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'Booking Not Found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The requested booking could not be found or has been removed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final currentStep = _getStepIndex(booking.status);
                final isCancelled = booking.status == 'rejected' || booking.status == 'cancelled';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card with Booking Status
                      _buildHeaderCard(booking, isCancelled),
                      const SizedBox(height: 20),

                      // Status Timeline
                      _buildTimelineCard(currentStep, isCancelled),
                      const SizedBox(height: 20),

                      // Client Info Card
                      _buildClientCard(booking),
                      const SizedBox(height: 20),

                      // Shoot Details Card
                      _buildShootDetailsCard(booking),
                      const SizedBox(height: 20),

                      // Financial Breakdown & Escrow
                      _buildFinancialCard(booking),
                      const SizedBox(height: 20),

                      // Special Notes / Requirements
                      if (booking.specialRequirements != null &&
                          booking.specialRequirements!.isNotEmpty) ...[
                        _buildRequirementsCard(booking.specialRequirements!),
                        const SizedBox(height: 24),
                      ],

                      // Action Buttons Area
                      _buildActionButtons(booking),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeaderCard(BookingModel booking, bool isCancelled) {
    Color badgeColor = const Color(0xFF2563EB);
    if (isCancelled) {
      badgeColor = Colors.red;
    } else if (booking.status == 'completed' || booking.status == 'delivered') {
      badgeColor = const Color(0xFF00A86B);
    } else if (booking.status == 'pending' || booking.status == 'requested') {
      badgeColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
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
                'BOOKING #${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Colors.grey.shade500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking.eventType,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.packageTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(int currentStep, bool isCancelled) {
    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Booking Cancelled / Declined',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontSize: 14)),
                  SizedBox(height: 2),
                  Text('This session slot is now open and available for other clients.',
                      style: TextStyle(fontSize: 12, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shoot Lifecycle Timeline',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          ..._timelineSteps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isDone = idx <= currentStep;
            final isCurrent = idx == currentStep;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.primary : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 4)
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text('${idx + 1}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600)),
                      ),
                    ),
                    if (idx < _timelineSteps.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: idx < currentStep ? AppColors.primary : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['label'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isDone ? AppColors.textPrimaryLight : Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          step['desc'],
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClientCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Information',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: (booking.customerAvatar != null && booking.customerAvatar!.isNotEmpty)
                    ? NetworkImage(booking.customerAvatar!)
                    : null,
                child: (booking.customerAvatar == null || booking.customerAvatar!.isEmpty)
                    ? Text(
                        booking.customerName.isNotEmpty ? booking.customerName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.customerPhone.isNotEmpty ? booking.customerPhone : 'Verified PYP Client',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () => context.push('/chat/${booking.id}'),
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShootDetailsCard(BookingModel booking) {
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(booking.shootDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shoot Schedule & Venue',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.calendar_today_rounded, 'Date', formattedDate),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time_rounded, 'Time Slot', booking.timeSlot),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_rounded, 'Location Venue', booking.location),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialCard(BookingModel booking) {
    final netPayout = booking.totalAmount - booking.platformFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial & Escrow',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking.paymentStatus == 'paid'
                      ? const Color(0xFF00A86B).withValues(alpha: 0.1)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.paymentStatus == 'paid' ? 'ESCROW DEPOSITED' : 'PAYMENT PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: booking.paymentStatus == 'paid'
                        ? const Color(0xFF00A86B)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Package Gross Price', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Text('₹${booking.totalAmount.toInt()}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PYP Platform Fee (10%)', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Text('- ₹${booking.platformFee.toInt()}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red.shade400)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Net Creator Payout',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Outfit'),
              ),
              Text(
                '₹${netPayout.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00A86B),
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.notes_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Client Special Requirements',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BookingModel booking) {
    final status = booking.status.toLowerCase();

    // 1. Pending / Requested: Accept or Reject
    if (status == 'pending' || status == 'requested') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleReject(booking),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Decline Request', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleAccept(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Accept Booking',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    }

    // 2. Confirmed: Start Shoot Day
    if (status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handleStartShoot(booking),
          icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white),
          label: const Text('Start Shoot Session Today',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    // 3. Shoot Day: Complete Shoot & Upload Deliverables
    if (status == 'shoot_day' || status == 'in_progress') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleCompleteShoot(booking),
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: const Text('Mark Shoot as Completed',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/deliverables/${booking.id}'),
              icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary),
              label: const Text('Upload Deliverables Gallery',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }

    // 4. Completed / Delivered
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.push('/deliverables/${booking.id}'),
        icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
        label: const Text('View Delivered Gallery',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _handleAccept(BookingModel booking) async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(supabaseServiceProvider);
      await db.acceptBookingRequest(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request accepted! Client has been notified.'),
            backgroundColor: Color(0xFF00A86B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReject(BookingModel booking) async {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Booking Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason so the client is informed politely:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Schedule conflict with another destination shoot',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final db = ref.read(supabaseServiceProvider);
                await db.rejectBookingRequest(booking.id, reason: reasonCtrl.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking declined'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartShoot(BookingModel booking) async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(supabaseServiceProvider);
      await db.startShootDay(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shoot session marked as In Progress! Have a great shoot! 📸'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCompleteShoot(BookingModel booking) async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(supabaseServiceProvider);
      await db.completeShootBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shoot marked as completed! You can now upload deliverables.'),
            backgroundColor: Color(0xFF00A86B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
