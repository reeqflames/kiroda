import 'package:flutter_test/flutter_test.dart';
import 'package:kiroda/domain/loan_calculator.dart';
import 'package:kiroda/domain/share_text.dart';

void main(){
  test('share text contains core result and disclaimer',(){
    const calc=LoanCalculator();
    final r=calc.calculate(principal:90000,annualRatePercent:3,months:108,method:FinancingMethod.legacyFlat);
    final text=buildShareText(vehiclePrice:100000,deposit:10000,annualRatePercent:3,months:108,method:FinancingMethod.legacyFlat,result:r);
    expect(text,contains('KIRODA'));
    expect(text,contains('RM1058.33'));
    expect(text,contains('bukan tawaran atau kelulusan bank'));
  });
}
