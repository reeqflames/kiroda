import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'number_format.dart';

/// JPJ (Circular 01/2026 dated 1 April 2026), Appendix A section 2.
/// https://www.jpj.gov.my/wp-content/uploads/2026/07/Lampiran-B-01.04.2026-Garis-Panduan-Kadar-LKM-Bagi-Kenderaan-Motor-Elektrik-ZEVs.pdf
/// Annual rate for private EVs (excluding motorcycles). Not for hybrids.
double? privateEvRoadTax(double? motorKw) {
  if (motorKw == null || !motorKw.isFinite || motorKw <= 0 || motorKw > 10000) return null;
  final watts=(motorKw*1000).round();
  if(watts <= 50000) return 20;
  if(watts > 1010000) return 20000;
  const bands=<(int,int,double,double)>[
    (50000,100000,30,10),
    (100000,210000,80,20),
    (210000,310000,305,30),
    (310000,410000,615,50),
    (410000,510000,1140,100),
    (510000,610000,2165,150),
    (610000,710000,3690,200),
    (710000,810000,5715,250),
    (810000,910000,8240,300),
    (910000,1010000,11265,350),
  ];
  for(final (lower, maxW, fee, increment) in bands){
    if(watts <= maxW) return fee + ((watts-lower-1) ~/ 10000)*increment;
  }
  return 20000;
}
class EvRoadTaxPage extends StatefulWidget {
  const EvRoadTaxPage({super.key});
  @override State<EvRoadTaxPage> createState()=>_EvRoadTaxPageState();
}
class _EvRoadTaxPageState extends State<EvRoadTaxPage>{
  final kw=TextEditingController();
  @override void initState(){super.initState();kw.addListener(recalc);}
  void recalc(){if(mounted)setState((){});}
  @override void dispose(){kw.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final power=double.tryParse(kw.text.replaceAll(',',''));
    final amount=privateEvRoadTax(power);
    return Scaffold(
      appBar:AppBar(title:const Text('EV Road Tax')),
      body:ListView(padding:const EdgeInsets.fromLTRB(16,15,16,24),children:[
        const Text('Electric Vehicle · 2026',style:TextStyle(fontSize:21,fontWeight:FontWeight.w800)),
        const SizedBox(height:4),
        const Text('Private ZEV, annual LKM · All Malaysia',
          style:TextStyle(fontSize:12,color:Color(0xFFADC2C0))),
        const SizedBox(height:18),
        const Text('Motor Output (kW)',style:TextStyle(fontSize:12,color:Color(0xFFADC2C0))),
        const SizedBox(height:6),
        TextField(controller:kw,
          keyboardType:const TextInputType.numberWithOptions(decimal:true),
          inputFormatters:const [GroupedNumberInputFormatter(decimalPlaces:3)],
          decoration:const InputDecoration(hintText:'e.g. 150',prefixIcon:Icon(Icons.bolt))),
        const SizedBox(height:16),
        if(amount==null)
          const Text('Enter the motor output shown in the vehicle specification.',
            style:TextStyle(fontSize:12,color:Color(0xFFADC2C0)))
        else Container(
          padding:const EdgeInsets.all(19),
          decoration:BoxDecoration(
            color:const Color(0xFF18362E),borderRadius:BorderRadius.circular(18)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('ESTIMATED ANNUAL ROAD TAX',
              style:TextStyle(color:Color(0xFFADC2C0),letterSpacing:1,fontSize:11)),
            const SizedBox(height:7),
            Text(currencyAmount(amount),style:const TextStyle(
              color:Color(0xFF6DE5C1),fontSize:30,fontWeight:FontWeight.w900)),
            const SizedBox(height:9),
            Text('Motor output: '+power!.toStringAsFixed(1)+' kW',
              style:const TextStyle(fontSize:12)),
          ]),
        ),
        const SizedBox(height:14),
        const Text('For full electric passenger vehicles only. '
          'Hybrid and PHEV road tax follows the appropriate vehicle/engine category. '
          'Confirm the registered rated motor output and JPJ quotation.',
          style:TextStyle(fontSize:11,color:Color(0xFFADC2C0))),
        TextButton.icon(
          icon:const Icon(Icons.open_in_new,size:16),
          label:const Text('Official JPJ 2026 EV LKM schedule'),
          onPressed:()=>launchUrl(Uri.parse(
            'https://www.jpj.gov.my/panduan-pengiraan-kadar-lkm/'),
            mode:LaunchMode.externalApplication),
        ),
      ]),
    );
  }
}