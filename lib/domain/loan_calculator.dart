import 'dart:math' as math;

enum FinancingMethod { legacyFlat, reducingFixed, reducingVariable }

class LoanResult {
  const LoanResult({required this.principal, required this.monthlyPayment, required this.totalPayment, required this.financingCost, required this.months, required this.method});
  final double principal, monthlyPayment, totalPayment, financingCost;
  final int months;
  final FinancingMethod method;
}

class LoanCalculator {
  const LoanCalculator();
  LoanResult calculate({required double principal, required double annualRatePercent, required int months, required FinancingMethod method}) {
    if (principal < 0 || annualRatePercent < 0 || months <= 0) throw ArgumentError('Invalid loan input');
    if (method == FinancingMethod.legacyFlat) {
      final interest = principal * (annualRatePercent / 100) * (months / 12);
      final total = principal + interest;
      return LoanResult(principal: principal, monthlyPayment: total / months, totalPayment: total, financingCost: interest, months: months, method: method);
    }
    final r = annualRatePercent / 100 / 12;
    final payment = r == 0 ? principal / months : principal * r * math.pow(1 + r, months) / (math.pow(1 + r, months) - 1);
    final total = payment * months;
    return LoanResult(principal: principal, monthlyPayment: payment, totalPayment: total, financingCost: total - principal, months: months, method: method);
  }
  double maxPrincipalForMonthly({required double monthlyBudget, required double annualRatePercent, required int months, required FinancingMethod method}) {
    if (monthlyBudget < 0 || annualRatePercent < 0 || months <= 0) throw ArgumentError('Invalid reverse input');
    if (method == FinancingMethod.legacyFlat) return monthlyBudget * months / (1 + (annualRatePercent / 100) * (months / 12));
    final r = annualRatePercent / 100 / 12;
    if (r == 0) return monthlyBudget * months;
    return monthlyBudget * (math.pow(1 + r, months) - 1) / (r * math.pow(1 + r, months));
  }
}
