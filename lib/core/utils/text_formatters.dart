import 'package:flutter/services.dart';

class PriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');

    // Allow empty
    if (text.isEmpty) return newValue;

    // Reject more than one decimal separator
    if ('.'.allMatches(text).length > 1) return oldValue;

    // Reject more than 2 decimal places
    final parts = text.split('.');
    if (parts.length == 2 && parts[1].length > 2) return oldValue;

    // Only digits and . or ,
    if (!RegExp(r'^[0-9.,]*$').hasMatch(newValue.text)) return oldValue;

    return newValue;
  }
}

class PercentFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');

    // Allow empty
    if (text.isEmpty) return newValue;

    // Reject more than one decimal separator
    if ('.'.allMatches(text).length > 1) return oldValue;

    // Only digits and . or ,
    if (!RegExp(r'^[0-9.,]*$').hasMatch(newValue.text)) return oldValue;

    // Parse value and disallow above 100
    final value = double.tryParse(text);
    if (value == null) return oldValue;
    if (value > 100) return oldValue;

    return newValue;
  }
}