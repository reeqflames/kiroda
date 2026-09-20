import 'package:flutter_test/flutter_test.dart';
import 'package:kiroda/domain/loan_calculator.dart';

void main() {
  const c = LoanCalculator();
  test('legacy RM90k 3% 9y', () {
    final r = c.calculate(principal: 90000, annualRatePercent: 3, months: 108, method: FinancingMethod.legacyFlat);
    expect(r.financingCost, closeTo(24300, .001));
    expect(r.totalPayment, closeTo(114300, .001));
    expect(r.monthlyPayment, closeTo(1058.333333, .001));
  });
  test('reducing zero rate', () {
    final r = c.calculate(principal: 12000, annualRatePercent: 0, months: 12, method: FinancingMethod.reducingFixed);
    expect(r.monthlyPayment, closeTo(1000, .001));
  });
  test('longer reducing tenure lowers monthly', () {
    final a = c.calculate(principal: 90000, annualRatePercent: 5, months: 84, method: FinancingMethod.reducingFixed);
    final b = c.calculate(principal: 90000, annualRatePercent: 5, months: 108, method: FinancingMethod.reducingFixed);
    expect(b.monthlyPayment, lessThan(a.monthlyPayment));
  });
  test('reverse legacy round-trip', () {
    final p = c.maxPrincipalForMonthly(monthlyBudget: 1058.333333, annualRatePercent: 3, months: 108, method: FinancingMethod.legacyFlat);
    expect(p, closeTo(90000, .01));
  });
}
