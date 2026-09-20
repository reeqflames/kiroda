import 'package:flutter_test/flutter_test.dart';
import 'package:kiroda/domain/loan_calculator.dart';
import 'package:kiroda/domain/rate_translator.dart';

void main(){
  test('same numeric flat and EIR are not equivalent',(){
    const t=RateTranslator(LoanCalculator());
    final x=t.compareSameNumericRate(principal:90000,annualRatePercent:3,months:108);
    expect(x.flat.totalPayment,isNot(closeTo(x.reducing.totalPayment,.01)));
  });
}