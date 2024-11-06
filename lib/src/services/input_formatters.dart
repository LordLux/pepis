import 'package:flutter/services.dart';

class DateFormatInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final selection = newValue.selection;

    // Allow only numbers, spaces, dashes, and slashes
    final filteredText = text.replaceAll(RegExp(r'[^0-9\s/-]'), '');

    // Replace spaces and dashes with slashes
    final replacedText = filteredText.replaceAll(RegExp(r'[\s-]'), '/');

    // Replace double slashes with a single slash
    final finalText = replacedText.replaceAll(RegExp(r'//+'), '/');

    // Calculate the new cursor position
    int cursorPosition = selection.baseOffset;
    if (cursorPosition > finalText.length) cursorPosition = finalText.length;

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class KIInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final selection = newValue.selection;

    // Allow only numbers and letters
    String filteredText = text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Ensure the format is "n.n.n" by removing extra dots
    final parts = filteredText.split('.');
    if (parts.length > 3) filteredText = parts.sublist(0, 3).join('.');

    // Calculate the new cursor position
    int cursorPosition = selection.baseOffset;
    if (cursorPosition > filteredText.length) cursorPosition = filteredText.length;

    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
