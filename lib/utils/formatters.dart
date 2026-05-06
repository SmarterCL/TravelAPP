import 'package:intl/intl.dart';

class Formatters {
  // Practice #7: Use correct formats (e.g., date: YYYY-MM-DD)
  static String formatDateApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  static String formatDisplayTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatCurrency(double amount, String currency) {
    return NumberFormat.currency(symbol: currency).format(amount);
  }
}
