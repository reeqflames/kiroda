import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiroda/main.dart';

void main() {
  testWidgets('core calculator journey renders', (tester) async {
    await tester.pumpWidget(const KirodaApp());
    expect(find.text('Kira sebelum pandu.'), findsOneWidget);
    expect(find.text('Harga kereta (RM)'), findsOneWidget);
    expect(find.text('Deposit (RM)'), findsOneWidget);
    expect(find.text('ANGGARAN BULANAN'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
    expect(find.text('Kongsi'), findsOneWidget);
  });

  testWidgets('advanced tools stay progressively disclosed', (tester) async {
    await tester.pumpWidget(const KirodaApp());
    expect(find.byType(ExpansionTile), findsNWidgets(2));
    expect(find.text('Flat rate vs EIR'), findsOneWidget);
    expect(find.text('Anggar jumlah pembiayaan dari bajet anda'), findsOneWidget);
  });
}
