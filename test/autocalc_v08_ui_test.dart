import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/autocalc/sa_tools.dart';
import '../lib/autocalc/otr_screen.dart';
import '../lib/autocalc/loan_compare_screen.dart';

void main(){
 setUp(()=>SharedPreferences.setMockInitialValues({}));

 testWidgets('Insurance compact columns have aligned tops, heights and widths',(tester)async{
  tester.view.physicalSize=const Size(1170,2532);
  tester.view.devicePixelRatio=3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home:InsuranceTool()));
  await tester.pumpAndSettle();
  final engine=tester.getRect(find.byKey(const ValueKey('engine-field')));
  final loc=tester.getRect(find.byKey(const ValueKey('location-field')));
  final ncd=tester.getRect(find.byKey(const ValueKey('ncd-field')));
  final glass=tester.getRect(find.byKey(const ValueKey('windscreen-toggle-field')));
  expect((engine.top-loc.top).abs(),lessThan(.5));
  expect((engine.height-loc.height).abs(),lessThan(.5));
  expect((engine.width-loc.width).abs(),lessThan(.5));
  expect((ncd.top-glass.top).abs(),lessThan(.5));
  expect((ncd.height-glass.height).abs(),lessThan(.5));
  expect((ncd.width-glass.width).abs(),lessThan(.5));
  expect(tester.takeException(),isNull);
 });
 testWidgets('Comprehensive and Third Party retain Sum Insured',(tester)async{
  tester.view.physicalSize=const Size(1170,2532);
  tester.view.devicePixelRatio=3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home:InsuranceTool()));
  final entered=find.byType(TextField).first;
  await tester.enterText(entered,'50000');
  await tester.tap(find.text('Third Party'));
  await tester.pumpAndSettle();
  expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text,'50,000');
  await tester.tap(find.text('Comprehensive'));
  await tester.pumpAndSettle();
  expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text,'50,000');
  expect(tester.takeException(),isNull);
 });
 testWidgets('Special Perils toggle and rate are aligned and optional',(tester)async{
  tester.view.physicalSize=const Size(1170,2532);
  tester.view.devicePixelRatio=3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home:InsuranceTool()));
  await tester.pumpAndSettle();
  final toggleField=find.byKey(const ValueKey('special-perils-toggle-field'));
  final rateField=find.byKey(const ValueKey('special-perils-rate-field'));
  final left=tester.getRect(toggleField);
  final right=tester.getRect(rateField);
  expect((left.top-right.top).abs(),lessThan(.5));
  expect((left.width-right.width).abs(),lessThan(.5));
  expect((left.height-right.height).abs(),lessThan(.5));

  final toggle=find.byKey(const ValueKey('special-perils-toggle'));
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
  expect(tester.widget<SwitchListTile>(toggle).value,isTrue);
  expect(tester.takeException(),isNull);

  await tester.tap(find.text('Third Party'));
  await tester.pumpAndSettle();
  expect(tester.widget<SwitchListTile>(toggle).value,isFalse);
  expect(tester.widget<SwitchListTile>(toggle).onChanged,isNull);

  await tester.tap(find.text('Comprehensive'));
  await tester.pumpAndSettle();
  expect(tester.widget<SwitchListTile>(toggle).value,isTrue);
  expect(tester.takeException(),isNull);
 });

 testWidgets('OTR opens blank and offers full/90/custom options',(tester)async{
  tester.view.physicalSize=const Size(1170,2532);
  tester.view.devicePixelRatio=3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home:OtrScreen()));
  await tester.pumpAndSettle();
  expect(find.text('OTR & Down Payment'),findsOneWidget);
  expect(find.text('Full'),findsOneWidget);
  expect(find.text('90%'),findsOneWidget);
  expect(find.text('Custom'),findsOneWidget);
  expect(tester.takeException(),isNull);
 });
 testWidgets('Bank comparison opens and shows two offers',(tester)async{
  tester.view.physicalSize=const Size(1170,2532);
  tester.view.devicePixelRatio=3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home:LoanComparisonScreen()));
  await tester.pumpAndSettle();
  expect(find.text('Compare Loan Offers'),findsOneWidget);
  expect(find.text('OFFER A'),findsOneWidget);
  expect(find.text('OFFER B'),findsOneWidget);
  expect(tester.takeException(),isNull);
 });
}
