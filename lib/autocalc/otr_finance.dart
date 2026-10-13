import 'dart:math' as math;
import 'finance.dart';

enum FinanceShare { full, ninety, custom }

double _money(double value) => (value * 100).roundToDouble() / 100;

/// Car price and loan amount exclude insurance/road-tax/registration by
/// default. A dealer's true financeable amount may differ.
class OtrBreakdown {
  const OtrBreakdown._({
    required this.netCarPrice,
    required this.otrPrice,
    required this.loanAmount,
    required this.deposit,
    required this.cashBeforeCredits,
    required this.cashDue,
    required this.excessCredit,
    required this.insurance,
    required this.roadTax,
    required this.fees,
    required this.booking,
    required this.tradeInEquity,
    required this.rebate,
    required this.loanPlan,
  });

  final double netCarPrice, otrPrice, loanAmount, deposit, cashBeforeCredits,
      cashDue, excessCredit, insurance, roadTax, fees, booking, tradeInEquity,
      rebate;
  final LoanPlan loanPlan;
}

OtrBreakdown calculateOtr({
  required double carPrice,
  required double rebate,
  required double insurance,
  required double roadTax,
  required double fees,
  required double booking,
  required double tradeInEquity,
  required double annualRate,
  required int years,
  required LoanMode rateMode,
  required FinanceShare financeShare,
  double? customLoanAmount,
}) {
  final money = [carPrice, rebate, insurance, roadTax, fees, booking, tradeInEquity];
  if (money.any((n) => !n.isFinite || n < 0 || n > 100000000) ||
      carPrice <= 0 || rebate >= carPrice) {
    throw ArgumentError('Invalid car price, rebate or charges.');
  }
  final netCarPrice = _money(carPrice - rebate);
  final loanAmount = _money(switch (financeShare) {
    FinanceShare.full => netCarPrice,
    FinanceShare.ninety => netCarPrice * 0.90,
    FinanceShare.custom => customLoanAmount ?? double.nan,
  });
  if (!loanAmount.isFinite || loanAmount <= 0 || loanAmount > netCarPrice) {
    throw ArgumentError('Loan must be above zero and not exceed the net car price.');
  }

  final plan = calculateLoan(
    amount: loanAmount, ratePercent: annualRate, years: years, mode: rateMode);
  final otr = _money(netCarPrice + insurance + roadTax + fees);
  final deposit = _money(netCarPrice - loanAmount);
  final cashBefore = _money(deposit + insurance + roadTax + fees);
  final credit = _money(booking + tradeInEquity);
  return OtrBreakdown._(
    netCarPrice: netCarPrice, otrPrice: otr, loanAmount: loanAmount,
    deposit: deposit, cashBeforeCredits: cashBefore,
    cashDue: _money(math.max(0, cashBefore - credit)),
    excessCredit: _money(math.max(0, credit - cashBefore)),
    insurance: _money(insurance), roadTax: _money(roadTax),
    fees: _money(fees), booking: _money(booking),
    tradeInEquity: _money(tradeInEquity), rebate: _money(rebate),
    loanPlan: plan,
  );
}
