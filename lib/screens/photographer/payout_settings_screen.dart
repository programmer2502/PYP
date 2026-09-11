import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/payout_details_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../services/supabase_service.dart';

class PayoutSettingsScreen extends ConsumerStatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  ConsumerState<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends ConsumerState<PayoutSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderNameCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();

  bool _isInit = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final payout = ref.read(creatorPayoutDetailsProvider).value;
      if (payout != null) {
        _holderNameCtrl.text = payout.accountHolderName;
        _bankNameCtrl.text = payout.bankName;
        _accountNumberCtrl.text = payout.accountNumberMask;
        _ifscCtrl.text = payout.ifscCode;
        _upiCtrl.text = payout.upiId ?? '';
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _holderNameCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Payout & Bank Details',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Direct Escrow Settlements',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          SizedBox(height: 2),
                          Text(
                            'Funds from completed bookings are deposited directly to your bank account within 24 hours of gallery delivery.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Bank Account Information',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 14),

              _buildField(
                label: 'Account Holder Name',
                controller: _holderNameCtrl,
                hint: 'Full name as per bank records',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              _buildField(
                label: 'Bank Name',
                controller: _bankNameCtrl,
                hint: 'e.g. HDFC Bank, ICICI Bank, SBI',
                icon: Icons.account_balance_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              _buildField(
                label: 'Account Number',
                controller: _accountNumberCtrl,
                hint: 'Enter your 9-18 digit account number',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              _buildField(
                label: 'IFSC Code',
                controller: _ifscCtrl,
                hint: 'e.g. HDFC0001234',
                icon: Icons.pin_outlined,
                textCapitalization: TextCapitalization.characters,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'UPI Instant Settlement (Optional)',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 14),

              _buildField(
                label: 'UPI ID / VPA',
                controller: _upiCtrl,
                hint: 'e.g. photographer@okhdfcbank',
                icon: Icons.qr_code_rounded,
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Payout Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Outfit',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider);
      final photographerId = user?.id ?? 'creator_current';
      final mask = _accountNumberCtrl.text.trim().length > 4
          ? '••••••••${_accountNumberCtrl.text.trim().substring(_accountNumberCtrl.text.trim().length - 4)}'
          : _accountNumberCtrl.text.trim();

      final details = PayoutDetailsModel(
        id: 'payout_$photographerId',
        photographerId: photographerId,
        accountHolderName: _holderNameCtrl.text.trim(),
        bankName: _bankNameCtrl.text.trim(),
        accountNumberMask: mask,
        ifscCode: _ifscCtrl.text.trim().toUpperCase(),
        upiId: _upiCtrl.text.trim(),
        payoutStatus: 'verified',
        updatedAt: DateTime.now(),
      );

      final db = ref.read(supabaseServiceProvider);
      await db.savePayoutDetails(details);
      ref.invalidate(creatorPayoutDetailsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout details saved successfully! 🏦'),
            backgroundColor: Color(0xFF00A86B),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving payout details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
