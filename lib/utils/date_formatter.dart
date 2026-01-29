import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatDateMedium(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  // days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  //if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  //if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Get expiry status
  static String getExpiryStatus(DateTime expiryDate) {
    final daysLeft = daysUntil(expiryDate);

    if (daysLeft < 0) {
      return 'Expired ${-daysLeft} days ago';
    } else if (isToday(expiryDate)) {
      return 'Expires today';
    } else if (isTomorrow(expiryDate)) {
      return 'Expires tomorrow';
    } else if (daysLeft <= 7) {
      return 'Expires in $daysLeft days';
    } else {
      return 'Expires on ${formatDate(expiryDate)}';
    }
  }

  // Format a date as "time ago" string
  static String timeAgo(DateTime date) {
    final daysDiff = DateTime.now().difference(date).inDays;

    if (daysDiff == 0) return 'today';
    if (daysDiff == 1) return 'yesterday';
    if (daysDiff < 30) return '$daysDiff days ago';

    final months = (daysDiff / 30).floor();
    if (months < 12) return months == 1 ? '1 month ago' : '$months months ago';

    final years = (daysDiff / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  }

  //placeholder
  static String formatDateOrPlaceholder(DateTime? date, String placeholder) {
    return date != null ? formatDate(date) : placeholder;
  }
}
