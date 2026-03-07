import 'package:intl/intl.dart';

abstract class AppUtils {
  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  static String formatCurrency(double value) {
    if (value == value.toInt()) {
      return 'Rp ${_currencyFormat.format(value.toInt())}';
    }
    return 'Rp ${_currencyFormat.format(value)}';
  }

  static String formatNumber(double value) {
    String formatted = value.toStringAsFixed(2);
    formatted = formatted.replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
    return formatted;
  }

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}
