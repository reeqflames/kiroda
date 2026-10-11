import 'package:flutter/services.dart';

/// Groups the integer portion without changing the amount represented.
String groupedDigits(String value) {
  final dot = value.indexOf('.');
  final whole = dot < 0 ? value : value.substring(0, dot);
  final fraction = dot < 0 ? '' : value.substring(dot);
  final sign = whole.startsWith('-') ? '-' : '';
  final digits = sign.isEmpty ? whole : whole.substring(1);
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return sign + grouped + fraction;
}

String currencyAmount(num value) =>
    'RM ' + groupedDigits(value.toStringAsFixed(2));

/// Adds commas as the person types. Preserves decimals and cursor location.
/// Does not prepopulate inputs or change their numeric values.
class GroupedNumberInputFormatter extends TextInputFormatter {
  const GroupedNumberInputFormatter({this.decimalPlaces = 2});
  final int decimalPlaces;

  String _sanitize(String input) {
    var raw = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (raw.isEmpty) return '';
    if (decimalPlaces <= 0) return raw.replaceAll('.', '');
    final dot = raw.indexOf('.');
    if (dot < 0) return raw;
    final integer = raw.substring(0, dot);
    final fractional = raw.substring(dot + 1)
        .replaceAll('.', '');
    final limitedFraction = fractional.length > decimalPlaces
        ? fractional.substring(0, decimalPlaces)
        : fractional;
    return (integer.isEmpty ? '0' : integer) + '.' + limitedFraction;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (!newValue.composing.isCollapsed) return newValue;
    final plain = _sanitize(newValue.text);
    final formatted = groupedDigits(plain);
    final origin = newValue.selection.extentOffset;
    final before = newValue.text.substring(
        0, origin.clamp(0, newValue.text.length));
    final want = _sanitize(before).length;

    // Map cursor from unformatted numeric characters to formatted text.
    var position = 0;
    var consumed = 0;
    while (position < formatted.length && consumed < want) {
      if (formatted[position] != ',') consumed++;
      position++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: position),
    );
  }
}
