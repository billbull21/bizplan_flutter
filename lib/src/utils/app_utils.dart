import 'package:intl/intl.dart';

class AppUtils {

  static final currencyFormat = NumberFormat('#,###', 'id_ID');
  
  static formatNumber(double value) {
    // Format with up to 2 decimal places
    String formatted = value.toStringAsFixed(2);

    // Remove trailing zeros and possible dangling decimal
    formatted = formatted.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");

    return formatted;
  }

  static String formatCurrency(double value) {
    // Menghilangkan 0 di belakang koma jika tidak diperlukan
    if (value == value.toInt()) {
      // Jika nilai adalah bilangan bulat (tidak ada desimal)
      return 'Rp ${currencyFormat.format(value.toInt())}';
    } else {
      // Jika nilai memiliki desimal
      return 'Rp ${currencyFormat.format(value)}';
    }
  }
}
