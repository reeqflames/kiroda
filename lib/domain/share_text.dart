import 'loan_calculator.dart';

String buildShareText({
  required double vehiclePrice,
  required double deposit,
  required double annualRatePercent,
  required int months,
  required FinancingMethod method,
  required LoanResult result,
}) {
  final methodLabel = switch (method) {
    FinancingMethod.legacyFlat => 'Flat rate',
    FinancingMethod.reducingFixed => 'Reducing balance / EIR',
    FinancingMethod.reducingVariable => 'Reducing balance (variable scenario)',
  };
  String rm(double v) => 'RM${v.toStringAsFixed(2)}';
  final years = months / 12;
  final tenure = years == years.roundToDouble()
      ? '${years.toInt()} tahun'
      : '${years.toStringAsFixed(1)} tahun';

  return [
    'KIRODA — Kira sebelum pandu.',
    '',
    'Harga kereta: ${rm(vehiclePrice)}',
    'Deposit: ${rm(deposit)}',
    'Jumlah pembiayaan: ${rm(result.principal)}',
    'Tempoh: $tenure ($months bulan)',
    'Kadar: ${annualRatePercent.toStringAsFixed(2)}%',
    'Kaedah: $methodLabel',
    '',
    'Anggaran bulanan: ${rm(result.monthlyPayment)}',
    'Jumlah bayaran: ${rm(result.totalPayment)}',
    'Kos pembiayaan: ${rm(result.financingCost)}',
    '',
    'Anggaran untuk perbandingan sahaja; bukan tawaran atau kelulusan bank.',
  ].join('\n');
}
