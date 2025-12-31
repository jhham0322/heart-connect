import 'package:flutter/services.dart';

/// Formats a phone number string (digits only) into 000-0000-0000 format
String formatPhone(String digits) {
  final cleaned = digits.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.length < 10) return digits;
  if (cleaned.length == 10) {
     return '${cleaned.substring(0,3)}-${cleaned.substring(3,6)}-${cleaned.substring(6)}';
  }
  if (cleaned.length == 11) {
     return '${cleaned.substring(0,3)}-${cleaned.substring(3,7)}-${cleaned.substring(7)}';
  }
  return digits;
}

/// TextInputFormatter for auto-hyphenating phone numbers
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted;
    
    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 7) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      final clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
      final midLen = clipped.length == 10 ? 3 : 4;
      formatted = '${clipped.substring(0, 3)}-${clipped.substring(3, 3 + midLen)}-${clipped.substring(3 + midLen)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
