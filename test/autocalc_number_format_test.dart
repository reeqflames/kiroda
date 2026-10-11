import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/number_format.dart';
void main() {
 test('commas inserted during typing', () {
  final result = const GroupedNumberInputFormatter().formatEditUpdate(
    const TextEditingValue(),
    const TextEditingValue(text: '50000', selection: TextSelection.collapsed(offset: 5)));
  expect(result.text, '50,000');
  expect(result.selection.baseOffset, 6);
 });
 test('currency format keeps cents', () {
  expect(currencyAmount(50000), 'RM 50,000.00');
  expect(currencyAmount(1234567.89), 'RM 1,234,567.89');
 });
 test('decimal and empty input', () {
  const f=GroupedNumberInputFormatter();
  expect(f.formatEditUpdate(const TextEditingValue(),
    const TextEditingValue(text:'50000.50',selection:TextSelection.collapsed(offset:8))).text,
    '50,000.50');
  expect(f.formatEditUpdate(const TextEditingValue(),const TextEditingValue()).text,'');
 });
}
