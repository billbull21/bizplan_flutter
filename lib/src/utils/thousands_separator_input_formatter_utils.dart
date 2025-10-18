// Custom formatter untuk thousand separator
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatterUtils extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hanya proses jika ada perubahan
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    // Hapus semua karakter non-digit
    final String newValueText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newValueText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse ke angka
    final int value = int.parse(newValueText);
    final String formattedText = _numberFormat.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
