import 'dart:math' as math;

enum LoanMode { flat, eir }

double toCents(double n) => (n * 100).roundToDouble() / 100;
double roundUpTen(double n) => (n / 10 - 1e-10).ceil() * 10.0;

/// The EIR input means effective ANNUAL rate. Nominal p.a. / daily accrual bank
/// products cannot be estimated correctly with this model without adjustment.
class PaymentRow {
  const PaymentRow(this.month, this.payment, this.principal, this.interest, this.balance);
  final int month;
  final double payment, principal, interest, balance;
}

class LoanPlan {
  LoanPlan._(this.amount, this.ratePercent, this.years, this.mode,
      this.exactMonthly, this.monthlyRounded, this.totalInterest, this.totalRepayment, this.rows);
  final double amount, ratePercent;
  final int years;
  final LoanMode mode;
  final double exactMonthly, monthlyRounded, totalInterest, totalRepayment;
  final List<PaymentRow> rows;
  int get contractedMonths => years * 12;
  int get simulatedPaidMonths => rows.length;
  double get finalInstallment => rows.isEmpty ? 0 : rows.last.payment;
  double get remainingAtStart => amount;

  double balanceAfter(int completedPayments) {
    if (completedPayments <= 0) return amount;
    if (completedPayments >= rows.length) return 0;
    return rows[completedPayments - 1].balance;
  }

  /// For EIR: remaining principal after selected month (excludes bank charges,
  /// daily interest, fees, and rebates). For flat: NOT a settlement quote.
  double indicativeSettlement(int completedPayments) =>
      mode == LoanMode.eir ? balanceAfter(completedPayments) : double.nan;

  /// Future simulated interest saved by early payoff, not contractual rebate.
  double futureInterest(int completedPayments) => toCents(rows
      .skip(completedPayments.clamp(0, rows.length))
      .fold<double>(0, (sum, row) => sum + row.interest));
}

LoanPlan calculateLoan({
  required double amount,
  required double ratePercent,
  required int years,
  required LoanMode mode,
}) {
  if (!amount.isFinite || !ratePercent.isFinite || amount <= 0 ||
      amount > 100000000 || ratePercent < 0 || ratePercent > 100 ||
      years < 1 || years > 12) {
    throw ArgumentError('Please enter a valid loan amount, annual rate and tenure.');
  }
  final p = toCents(amount);
  final n = years * 12;
  if (mode == LoanMode.flat) {
    final interestTotal = toCents(p * ratePercent / 100 * years);
    final total = toCents(p + interestTotal);
    final raw = total / n;
    final rounded = roundUpTen(raw);
    final rows = <PaymentRow>[];
    var principalRemaining = p;
    var interestRemaining = interestTotal;
    var totalRemaining = total;
    final monthlyInterest = toCents(interestTotal / n);
    for (var m = 1; m <= n && totalRemaining > 0.005; m++) {
      final payment = toCents(m == n ? totalRemaining : math.min(rounded, totalRemaining));
      final financeCost = m == n ? interestRemaining : math.min(monthlyInterest, interestRemaining);
      final principalPaid = toCents(math.max(0, math.min(principalRemaining, payment - financeCost)));
      principalRemaining = toCents(math.max(0, principalRemaining - principalPaid));
      interestRemaining = toCents(math.max(0, interestRemaining - financeCost));
      totalRemaining = toCents(math.max(0, totalRemaining - payment));
      rows.add(PaymentRow(m, payment, principalPaid, financeCost, principalRemaining));
    }
    return LoanPlan._(p, ratePercent, years, mode, raw, rounded, interestTotal, total, rows);
  }

  // Effective annual -> equivalent monthly rate, NOT EIR / 12.
  final r = ratePercent == 0 ? 0.0 : math.pow(1 + ratePercent / 100, 1 / 12).toDouble() - 1;
  final raw = r == 0 ? p / n : p * r / (1 - math.pow(1 + r, -n).toDouble());
  final rounded = roundUpTen(raw);
  final rows = <PaymentRow>[];
  var balance = p;
  var interestSum = 0.0;
  var repaymentSum = 0.0;
  for (var m = 1; m <= n && balance > 0.005; m++) {
    final interest = toCents(balance * r);
    final payment = toCents(math.min(m == n ? balance + interest : rounded, balance + interest));
    final principal = toCents(math.min(balance, math.max(0, payment - interest)));
    balance = toCents(math.max(0, balance - principal));
    interestSum = toCents(interestSum + interest);
    repaymentSum = toCents(repaymentSum + payment);
    rows.add(PaymentRow(m, payment, principal, interest, balance));
  }
  return LoanPlan._(p, ratePercent, years, mode, raw, rounded, interestSum, repaymentSum, rows);
}

String myr(num n, {bool cents = false}) {
  final parts = n.toStringAsFixed(cents ? 2 : 0).split('.');
  final grouped = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return 'RM ' + grouped + (cents ? '.' + parts[1] : '');
}