import 'package:flutter_test/flutter_test.dart';
import 'package:kiroda/domain/loan_calculator.dart';
import 'package:kiroda/domain/scenario.dart';

void main(){
  test('scenario comparison exposes monthly and total differences',(){
    const lab=ScenarioLab(LoanCalculator());
    const a=LoanScenario(name:'A',vehiclePrice:100000,deposit:10000,annualRatePercent:3,months:84,method:FinancingMethod.legacyFlat);
    const b=LoanScenario(name:'B',vehiclePrice:100000,deposit:10000,annualRatePercent:3,months:108,method:FinancingMethod.legacyFlat);
    final x=lab.compare(a,b);
    expect(x.bResult.monthlyPayment,lessThan(x.aResult.monthlyPayment));
    expect(x.bResult.totalPayment,greaterThan(x.aResult.totalPayment));
  });
}