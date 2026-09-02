import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  static String formatRelativeTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(date);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static String formatChatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('h:mm a').format(date);
    }
    return DateFormat('MMM d, h:mm a').format(date);
  }
}
