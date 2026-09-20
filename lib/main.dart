import 'package:flutter/material.dart';
import 'domain/loan_calculator.dart';

void main() => runApp(const KirodaApp());

class KirodaApp extends StatelessWidget {
  const KirodaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'KIRODA',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
    home: const CalculatorPage(),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final price = TextEditingController(text: '100000');
  final deposit = TextEditingController(text: '10000');
  final rate = TextEditingController(text: '3');
  final calculator = const LoanCalculator();
  int years = 9;
  FinancingMethod method = FinancingMethod.legacyFlat;

  LoanResult? get result {
    final p = double.tryParse(price.text);
    final d = double.tryParse(deposit.text);
    final r = double.tryParse(rate.text);
    if (p == null || d == null || r == null || p < d) return null;
    return calculator.calculate(principal: p - d, annualRatePercent: r, months: years * 12, method: method);
  }

  String money(double value) => 'RM' + value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final x = result;
    return Scaffold(
      appBar: AppBar(title: const Text('KIRODA')),
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Kira sebelum pandu.', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga kereta (RM)', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          TextField(controller: deposit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Deposit (RM)', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          TextField(controller: rate, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Kadar setahun (%)', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          DropdownButtonFormField<FinancingMethod>(
            initialValue: method,
            decoration: const InputDecoration(labelText: 'Kaedah pembiayaan', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: FinancingMethod.legacyFlat, child: Text('Flat rate (legacy)')),
              DropdownMenuItem(value: FinancingMethod.reducingFixed, child: Text('Reducing balance / EIR')),
              DropdownMenuItem(value: FinancingMethod.reducingVariable, child: Text('Reducing balance (variable scenario)')),
            ],
            onChanged: (v) => setState(() => method = v!),
          ),
          const SizedBox(height: 20),
          Text('Tempoh: ' + years.toString() + ' tahun'),
          Slider(value: years.toDouble(), min: 1, max: 9, divisions: 8, label: years.toString(), onChanged: (v) => setState(() => years = v.round())),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(20), child: x == null
            ? const Text('Semak nilai yang dimasukkan.')
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ANGGARAN BULANAN'),
                const SizedBox(height: 6),
                Text(money(x.monthlyPayment), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 14),
                Text('Jumlah loan: ' + money(x.principal)),
                Text('Jumlah bayaran: ' + money(x.totalPayment)),
                Text('Kos pembiayaan: ' + money(x.financingCost)),
              ]))),
          const SizedBox(height: 12),
          const Text('Anggaran untuk perbandingan sahaja. Tawaran sebenar bergantung pada penyedia pembiayaan.'),
        ],
      )),
    );
  }
}
