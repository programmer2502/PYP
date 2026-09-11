class EarningsSummaryModel {
  final double totalEarnings;
  final double pendingEarnings;
  final double availableEarnings;
  final int completedShootsCount;
  final double thisMonthGrowthPercent;

  EarningsSummaryModel({
    this.totalEarnings = 0.0,
    this.pendingEarnings = 0.0,
    this.availableEarnings = 0.0,
    this.completedShootsCount = 0,
    this.thisMonthGrowthPercent = 0.0,
  });

  factory EarningsSummaryModel.fromMap(Map<String, dynamic> data) {
    return EarningsSummaryModel(
      totalEarnings: (data['total_earnings'] as num?)?.toDouble() ?? 0.0,
      pendingEarnings: (data['pending_earnings'] as num?)?.toDouble() ?? 0.0,
      availableEarnings: (data['available_earnings'] as num?)?.toDouble() ?? 0.0,
      completedShootsCount: (data['completed_shoots_count'] as num?)?.toInt() ?? 0,
      thisMonthGrowthPercent: (data['growth_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TransactionModel {
  final String id;
  final String bookingId;
  final String bookingNumber;
  final String customerName;
  final double amount;
  final double platformFee;
  final double netPayout;
  final String status; // 'completed', 'escrow_hold', 'processing', 'withdrawn'
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.bookingId,
    required this.bookingNumber,
    required this.customerName,
    required this.amount,
    required this.platformFee,
    required this.netPayout,
    this.status = 'completed',
    required this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final rawAmount = (data['amount'] as num?)?.toDouble() ?? (data['total_amount'] as num?)?.toDouble() ?? 0.0;
    final fee = (data['platform_fee'] as num?)?.toDouble() ?? (rawAmount * 0.10);
    final net = (data['net_payout'] as num?)?.toDouble() ?? (rawAmount - fee);
    final rawId = id ?? data['id']?.toString() ?? '';

    return TransactionModel(
      id: rawId,
      bookingId: data['booking_id']?.toString() ?? data['id']?.toString() ?? '',
      bookingNumber: data['booking_number'] ?? data['bookingNumber'] ?? (rawId.isNotEmpty ? 'BK-${rawId.substring(0, rawId.length >= 6 ? 6 : rawId.length)}' : ''),
      customerName: data['customer_name'] ?? data['customerName'] ?? 'Verified Client',
      amount: rawAmount,
      platformFee: fee,
      netPayout: net,
      status: data['status'] ?? 'completed',
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'booking_number': bookingNumber,
      'customer_name': customerName,
      'amount': amount,
      'platform_fee': platformFee,
      'net_payout': netPayout,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
