import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'domain/loan_calculator.dart';
import 'domain/rate_translator.dart';
import 'domain/share_text.dart';
import 'ui/kiroda_theme.dart';

void main() => runApp(const KirodaApp());

class KirodaApp extends StatelessWidget {
  const KirodaApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'KIRODA',
    theme: buildKirodaTheme(),
    home: const CalculatorPage(),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final price = TextEditingController(text: '100000');
  final deposit = TextEditingController(text: '10000');
  final rate = TextEditingController(text: '3');
  final budget = TextEditingController(text: '1200');
  final calculator = const LoanCalculator();
  int months = 108;
  FinancingMethod method = FinancingMethod.legacyFlat;
  final List<String> savedScenarios = [];
  static const tenures = [12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108];

  double? number(TextEditingController c) => double.tryParse(c.text.replaceAll(',', ''));
  String money(double v) => 'RM${v.toStringAsFixed(2)}';
  String tenureLabel(int m) {
    final y = m / 12;
    final years = y == y.roundToDouble() ? y.toInt().toString() : y.toStringAsFixed(1);
    return '$years tahun ($m bulan)';
  }

  LoanResult? get result {
    final p=number(price), d=number(deposit), r=number(rate);
    if (p==null || d==null || r==null || p<0 || d<0 || d>p) return null;
    return calculator.calculate(principal:p-d, annualRatePercent:r, months:months, method:method);
  }

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    final prefs=await SharedPreferences.getInstance();
    if(!mounted) return;
    setState(()=>savedScenarios.addAll(prefs.getStringList('scenarios') ?? const []));
  }

  Future<void> clearScenarios() async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove('scenarios');
    if(mounted) setState(savedScenarios.clear);
  }

  Future<void> saveScenario() async {
    final x=result, p=number(price), d=number(deposit), r=number(rate);
    if(x==null||p==null||d==null||r==null) return;
    final item='${DateTime.now().millisecondsSinceEpoch}|$p|$d|$r|$months|${method.index}|${x.monthlyPayment}';
    setState(() { savedScenarios.insert(0,item); if(savedScenarios.length>3) savedScenarios.removeLast(); });
    final prefs=await SharedPreferences.getInstance();
    await prefs.setStringList('scenarios',savedScenarios);
  }

  Future<void> shareResult() async {
    final x=result, p=number(price), d=number(deposit), r=number(rate);
    if(x==null||p==null||d==null||r==null) return;
    final text=buildShareText(vehiclePrice:p,deposit:d,annualRatePercent:r,months:months,method:method,result:x);
    await SharePlus.instance.share(ShareParams(text:text,subject:'KIRODA'));
  }

  @override Widget build(BuildContext context) {
    final x=result;
    return Scaffold(
      appBar: AppBar(title: const Text('KIRODA',style:TextStyle(fontWeight:FontWeight.w800,letterSpacing:1.2)),centerTitle:false),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Kira sebelum pandu.', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height:6),
        Text('Nampak komitmen sebenar sebelum pilih kereta.',style:Theme.of(context).textTheme.bodyMedium?.copyWith(color:Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height:20),
        field(price,'Harga kereta (RM)'), const SizedBox(height:12),
        field(deposit,'Deposit (RM)'), const SizedBox(height:12),
        field(rate,'Kadar setahun (%)', decimal:true), const SizedBox(height:12),
        DropdownButtonFormField<int>(
          initialValue: months, decoration: const InputDecoration(labelText:'Tempoh pembiayaan', border:OutlineInputBorder()),
          items: tenures.map((m)=>DropdownMenuItem(value:m, child:Text(tenureLabel(m)))).toList(),
          onChanged:(v)=>setState(()=>months=v!),
        ), const SizedBox(height:12),
        DropdownButtonFormField<FinancingMethod>(
          initialValue:method, decoration:const InputDecoration(labelText:'Kaedah pembiayaan', border:OutlineInputBorder()),
          items:const [
            DropdownMenuItem(value:FinancingMethod.legacyFlat, child:Text('Flat rate (legacy)')),
            DropdownMenuItem(value:FinancingMethod.reducingFixed, child:Text('Reducing balance / EIR')),
            DropdownMenuItem(value:FinancingMethod.reducingVariable, child:Text('Reducing balance - variable scenario')),
          ], onChanged:(v)=>setState(()=>method=v!),
        ), const SizedBox(height:16),
        if (x!=null) resultCard(x) else const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Semak nilai yang dimasukkan.'))),
        if(x!=null) Row(children:[
          Expanded(child:FilledButton.icon(onPressed:saveScenario,icon:const Icon(Icons.bookmark_add_outlined),label:const Text('Simpan'))),
          const SizedBox(width:8),
          Expanded(child:OutlinedButton.icon(onPressed:shareResult,icon:const Icon(Icons.share_outlined),label:const Text('Kongsi'))),
        ]),
        if(savedScenarios.isNotEmpty) savedScenarioCard(),
        const SizedBox(height:20),
        Text('Banding cepat',style:Theme.of(context).textTheme.titleMedium), const SizedBox(height:8),
        Row(children:[60,84,108].map((m)=>Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:4),
          child:OutlinedButton(onPressed:()=>setState(()=>months=m), child:Text('${m~/12} tahun'))))).toList()),
        const SizedBox(height:8),
        ...quickRows(),
        const SizedBox(height:16),
        ExpansionTile(
          tilePadding:EdgeInsets.zero,
          title:const Text('Faham kadar'),
          subtitle:const Text('Flat rate vs EIR'),
          children:[rateTranslatorCard()],
        ),
        ExpansionTile(
          tilePadding:EdgeInsets.zero,
          title:const Text('Kira dari bajet bulanan'),
          subtitle:const Text('Anggar jumlah pembiayaan dari bajet anda'),
          children:[field(budget,'Bajet bulanan (RM)'),const SizedBox(height:8),reverseCard()],
        ),
        const SizedBox(height:20),
        const Text('Anggaran untuk perbandingan sahaja. Tawaran sebenar, kadar dan tempoh tersedia bergantung pada penyedia pembiayaan.',style:TextStyle(fontSize:12)),
      ])),
    );
  }

  Widget savedScenarioCard() => Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Scenario Lab',style:Theme.of(context).textTheme.titleMedium),
    const SizedBox(height:6),
    ...savedScenarios.asMap().entries.map((e){
      final p=e.value.split('|');
      final monthly=double.tryParse(p.length>6?p[6]:'') ?? 0;
      final m=int.tryParse(p.length>4?p[4]:'') ?? 0;
      return ListTile(contentPadding:EdgeInsets.zero,dense:true,title:Text('Scenario ${String.fromCharCode(65+e.key)}'),subtitle:Text(tenureLabel(m)),trailing:Text('${money(monthly)}/bln'));
    }),
    Row(children:[
      const Expanded(child:Text('Disimpan pada telefon ini sahaja. Maksimum 3 scenario.',style:TextStyle(fontSize:12))),
      TextButton(onPressed:clearScenarios,child:const Text('Padam semua')),
    ]),
  ])));

  List<Widget> quickRows() {
    final p=number(price), d=number(deposit), r=number(rate);
    if(p==null||d==null||r==null||d>p) return const [];
    return [60,84,108].map((m){
      final q=calculator.calculate(principal:p-d,annualRatePercent:r,months:m,method:method);
      return ListTile(dense:true,title:Text('${m~/12} tahun'),trailing:Text('${money(q.monthlyPayment)} / bulan'));
    }).toList();
  }

  Widget rateTranslatorCard() {
    final p=number(price), d=number(deposit), r=number(rate);
    if(p==null||d==null||r==null||d>p) return const SizedBox.shrink();
    final x=RateTranslator(calculator).compareSameNumericRate(principal:p-d, annualRatePercent:r, months:months);
    return Padding(padding:const EdgeInsets.only(bottom:12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${r.toStringAsFixed(2)}% flat tidak sama dengan ${r.toStringAsFixed(2)}% EIR.'),
      const SizedBox(height:10),
      line('Flat: jumlah bayaran',money(x.flat.totalPayment)),
      line('EIR: jumlah bayaran',money(x.reducing.totalPayment)),
      const SizedBox(height:6),
      const Text('Perbandingan ini menggunakan nombor kadar yang sama untuk menerangkan perbezaan kaedah kiraan; ia bukan penukaran kadar bank.',style:TextStyle(fontSize:12)),
    ]));
  }

  Widget reverseCard() {
    final b=number(budget), r=number(rate);
    if(b==null||r==null||b<0) return const SizedBox.shrink();
    final max=calculator.maxPrincipalForMonthly(monthlyBudget:b,annualRatePercent:r,months:months,method:method);
    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Anggaran jumlah pembiayaan maksimum'),
      Text(money(max),style:Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height:4), const Text('Simulasi matematik, bukan kelulusan bank.',style:TextStyle(fontSize:12)),
    ])));
  }

  Widget field(TextEditingController c,String label,{bool decimal=false}) => TextField(
    controller:c, keyboardType:TextInputType.numberWithOptions(decimal:decimal),
    textInputAction:TextInputAction.next,
    decoration:InputDecoration(labelText:label,border:const OutlineInputBorder()), onChanged:(_)=>setState((){}));

  Widget resultCard(LoanResult x) => Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('ANGGARAN BULANAN',style:Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing:1.1,color:Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height:6),
    Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(money(x.monthlyPayment),style:Theme.of(context).textTheme.headlineLarge),const SizedBox(width:6),Padding(padding:const EdgeInsets.only(bottom:5),child:Text('/ bulan',style:Theme.of(context).textTheme.bodyMedium))]),
    const Divider(height:24), line('Jumlah pembiayaan',money(x.principal)),
    line('Jumlah bayaran',money(x.totalPayment)), line('Kos pembiayaan',money(x.financingCost)),
  ])));

  Widget line(String a,String b) => Padding(padding:const EdgeInsets.symmetric(vertical:3),child:Row(
    mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(a),Text(b,style:const TextStyle(fontWeight:FontWeight.w600))]));
}