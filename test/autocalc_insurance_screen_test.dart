import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/sa_tools.dart';

void main() {
  testWidgets('Coverage toggles within same screen and retains Sum Insured', (tester) async {
    tester.view.physicalSize = const Size(1080, 2300);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: InsuranceTool()));
    final insured = find.byType(TextField).first;
    await tester.enterText(insured, '50000');
    await tester.pump();
    expect(tester.widget<TextField>(insured).controller!.text, '50,000');

    await tester.tap(find.text('Third Party'));
    await tester.pumpAndSettle();
    expect(find.text('Market Value / Sum Insured (RM)'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, '50,000');
    expect(find.byKey(const ValueKey('sum-insured-field')), findsOneWidget);

    await tester.tap(find.text('Comprehensive'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, '50,000');
  });

  testWidgets('Engine capacity is a selection dropdown with the original 8 ranges', (tester) async {
    tester.view.physicalSize = const Size(1080, 2300);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: InsuranceTool()));
    final cc = find.byType(DropdownButtonFormField<int>).first;
    expect(cc, findsOneWidget);
    await tester.tap(cc);
    await tester.pumpAndSettle();
    expect(find.text('1,401 – 1,650 cc'), findsWidgets);
    expect(find.text('Over 4,400 cc'), findsWidgets);
    await tester.tap(find.text('1,401 – 1,650 cc').last);
    await tester.pumpAndSettle();
    expect(find.text('1,401 – 1,650 cc'), findsOneWidget);
  });
}
