import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  /// Format date as "15 Dec 2024"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format time as "02:30 PM"
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Format date and time as "15 Dec 2024, 02:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format as "15 Dec"
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Get relative time string (e.g., "Today", "Yesterday", "2 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}
