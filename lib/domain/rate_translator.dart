import 'loan_calculator.dart';

class RateTranslation {
  const RateTranslation({required this.flat, required this.reducing});
  final LoanResult flat;
  final LoanResult reducing;
  double get monthlyDifference => reducing.monthlyPayment - flat.monthlyPayment;
  double get totalDifference => reducing.totalPayment - flat.totalPayment;
}

class RateTranslator {
  const RateTranslator(this.calculator);
  final LoanCalculator calculator;
  RateTranslation compareSameNumericRate({required double principal,required double annualRatePercent,required int months}) {
    return RateTranslation(
      flat:calculator.calculate(principal:principal,annualRatePercent:annualRatePercent,months:months,method:FinancingMethod.legacyFlat),
      reducing:calculator.calculate(principal:principal,annualRatePercent:annualRatePercent,months:months,method:FinancingMethod.reducingFixed),
    );
  }
}