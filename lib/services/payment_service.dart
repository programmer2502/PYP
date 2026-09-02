import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/booking_model.dart';

enum PaymentResultType { success, failure, wallet }

class PaymentCallbackResult {
  final PaymentResultType type;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final int? errorCode;
  final String? errorMessage;

  PaymentCallbackResult({
    required this.type,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
    this.errorMessage,
  });
}

class PaymentService {
  late Razorpay _razorpay;
  Function(PaymentCallbackResult)? _onResult;

  // Razorpay Test / Live Key
  static const String razorpayKeyId = 'rzp_test_51a2b3c4d5e6';

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// Open Razorpay Checkout for a booking
  void openCheckout({
    required BookingModel booking,
    required String userEmail,
    required String userPhone,
    required Function(PaymentCallbackResult) onResult,
  }) {
    _onResult = onResult;

    // Amount in subunits (e.g. paisa/cents, multiplied by 100)
    final amountInSubunits = (booking.totalAmount * 100).toInt();

    final options = {
      'key': razorpayKeyId,
      'amount': amountInSubunits,
      'name': 'PYP - Pick Your Photographer',
      'description': 'Booking: ${booking.packageTitle} with ${booking.photographerName}',
      'prefill': {
        'contact': userPhone.isNotEmpty ? userPhone : '9876543210',
        'email': userEmail.isNotEmpty ? userEmail : 'client@pyp.app',
      },
      'notes': {
        'bookingId': booking.id,
        'photographerId': booking.photographerId,
        'customerId': booking.customerId,
      },
      'theme': {
        'color': '#6366F1',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _onResult?.call(
        PaymentCallbackResult(
          type: PaymentResultType.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _onResult?.call(
      PaymentCallbackResult(
        type: PaymentResultType.success,
        paymentId: response.paymentId,
        orderId: response.orderId,
        signature: response.signature,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onResult?.call(
      PaymentCallbackResult(
        type: PaymentResultType.failure,
        errorCode: response.code,
        errorMessage: response.message ?? 'Payment cancelled or failed',
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onResult?.call(
      PaymentCallbackResult(
        type: PaymentResultType.wallet,
        paymentId: response.walletName,
      ),
    );
  }
}
