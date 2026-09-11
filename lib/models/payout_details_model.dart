class PayoutDetailsModel {
  final String id;
  final String photographerId;
  final String accountHolderName;
  final String bankName;
  final String accountNumberMask;
  final String ifscCode;
  final String? upiId;
  final String payoutStatus; // 'active', 'pending_verification', 'suspended'
  final DateTime? updatedAt;

  PayoutDetailsModel({
    required this.id,
    required this.photographerId,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumberMask,
    required this.ifscCode,
    this.upiId,
    this.payoutStatus = 'active',
    this.updatedAt,
  });

  factory PayoutDetailsModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return PayoutDetailsModel(
      id: id ?? data['id']?.toString() ?? '',
      photographerId: data['photographer_id']?.toString() ?? '',
      accountHolderName: data['account_holder_name'] ?? '',
      bankName: data['bank_name'] ?? 'HDFC Bank',
      accountNumberMask: data['account_number_mask'] ?? '••••••••1234',
      ifscCode: data['ifsc_code'] ?? '',
      upiId: data['upi_id'],
      payoutStatus: data['payout_status'] ?? 'active',
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photographer_id': photographerId,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number_mask': accountNumberMask,
      'ifsc_code': ifscCode,
      'upi_id': upiId,
      'payout_status': payoutStatus,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  PayoutDetailsModel copyWith({
    String? id,
    String? photographerId,
    String? accountHolderName,
    String? bankName,
    String? accountNumberMask,
    String? ifscCode,
    String? upiId,
    String? payoutStatus,
    DateTime? updatedAt,
  }) {
    return PayoutDetailsModel(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      accountNumberMask: accountNumberMask ?? this.accountNumberMask,
      ifscCode: ifscCode ?? this.ifscCode,
      upiId: upiId ?? this.upiId,
      payoutStatus: payoutStatus ?? this.payoutStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
