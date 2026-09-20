import 'loan_calculator.dart';

class LoanScenario {
  const LoanScenario({required this.name,required this.vehiclePrice,required this.deposit,required this.annualRatePercent,required this.months,required this.method});
  final String name;
  final double vehiclePrice, deposit, annualRatePercent;
  final int months;
  final FinancingMethod method;
  double get principal => vehiclePrice-deposit;
}

class ScenarioComparison {
  const ScenarioComparison({required this.a,required this.b,required this.aResult,required this.bResult});
  final LoanScenario a,b;
  final LoanResult aResult,bResult;
  double get monthlyDifference => bResult.monthlyPayment-aResult.monthlyPayment;
  double get totalDifference => bResult.totalPayment-aResult.totalPayment;
}

class ScenarioLab {
  const ScenarioLab(this.calculator);
  final LoanCalculator calculator;
  ScenarioComparison compare(LoanScenario a,LoanScenario b) {
    LoanResult calc(LoanScenario s)=>calculator.calculate(principal:s.principal,annualRatePercent:s.annualRatePercent,months:s.months,method:s.method);
    return ScenarioComparison(a:a,b:b,aResult:calc(a),bResult:calc(b));
  }
}