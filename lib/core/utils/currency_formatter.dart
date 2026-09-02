import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(num? amount, {String currencySymbol = '₹'}) {
    if (amount == null) return '$currencySymbol 0';
    final formatter = NumberFormat('#,##,###');
    return '$currencySymbol${formatter.format(amount)}';
  }

  static String formatUsd(num? amount) {
    if (amount == null) return '\$0';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }
}
