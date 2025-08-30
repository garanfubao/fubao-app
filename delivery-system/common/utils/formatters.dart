import 'package:intl/intl.dart';

class AppFormatters {
  // Date and Time Formatters
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _shortDateFormatter = DateFormat('dd/MM');
  static final DateFormat _longDateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');

  static String formatDate(DateTime date) => _dateFormatter.format(date);
  static String formatTime(DateTime time) => _timeFormatter.format(time);
  static String formatDateTime(DateTime dateTime) => _dateTimeFormatter.format(dateTime);
  static String formatShortDate(DateTime date) => _shortDateFormatter.format(date);
  static String formatLongDate(DateTime date) => _longDateFormatter.format(date);

  // Money Formatter
  static final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static String formatMoney(double amount) => _moneyFormatter.format(amount);

  // Number Formatters
  static final NumberFormat _numberFormatter = NumberFormat('#,##0', 'vi_VN');
  static final NumberFormat _decimalFormatter = NumberFormat('#,##0.0', 'vi_VN');

  static String formatNumber(num number) => _numberFormatter.format(number);
  static String formatDecimal(double number) => _decimalFormatter.format(number);

  // Distance Formatter
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  // Duration Formatter
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Phone Number Formatter
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 10) {
      // Format: 0123 456 789
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    } else if (digits.length == 11 && digits.startsWith('84')) {
      // Format: +84 123 456 789
      return '+84 ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    }
    
    return phoneNumber; // Return original if format is unknown
  }

  // Relative Time Formatter
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // Order ID Formatter
  static String formatOrderId(String orderId) {
    // Format: ORDER-001234
    if (orderId.startsWith('order_')) {
      final number = orderId.substring(6);
      return 'ORDER-${number.padLeft(6, '0').toUpperCase()}';
    }
    return orderId.toUpperCase();
  }

  // File Size Formatter
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  // Percentage Formatter
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }

  // Rating Formatter
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  // Vehicle Number Formatter
  static String formatVehicleNumber(String vehicleNumber) {
    // Format: 29A-12345 -> 29A - 12345
    final regex = RegExp(r'^(\d{2})([A-Z]{1,2})-?(\d{4,5})$');
    final match = regex.firstMatch(vehicleNumber.toUpperCase());
    
    if (match != null) {
      return '${match.group(1)}${match.group(2)} - ${match.group(3)}';
    }
    
    return vehicleNumber.toUpperCase();
  }
}
