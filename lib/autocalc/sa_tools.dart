
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'number_format.dart';
import 'insurance_tariff.dart';
const _bg=Color(0xFF0D161C),_panel=Color(0xFF18282E),_mint=Color(0xFF6DE5C1),_muted=Color(0xFFADC2C0),_stroke=Color(0xFF30494C);
double? parsePositive(String value,{bool zero=false}){
 final n=double.tryParse(value.replaceAll(',','').trim());
 if(n==null||!n.isFinite||n<0||(!zero&&n==0))return null;
 return n;
}
double? peninsularRoadTax(int cc,{required bool nonSaloon}){
 if(cc<=0||cc>20000)return null;
 if(cc<=1000)return 20;
 if(cc<=1200)return nonSaloon?85:55;
 if(cc<=1400)return nonSaloon?100:70;
 if(cc<=1600)return nonSaloon?120:90;
 if(cc<=1800)return (nonSaloon?300:200)+(cc-1600)*(nonSaloon?0.30:0.40);
 if(cc<=2000)return (nonSaloon?360:280)+(cc-1800)*(nonSaloon?0.40:0.50);
 if(cc<=2500)return (nonSaloon?440:380)+(cc-2000)*(nonSaloon?0.80:1.00);
 if(cc<=3000)return (nonSaloon?840:880)+(cc-2500)*(nonSaloon?1.60:2.50);
 return (nonSaloon?1640:2130)+(cc-3000)*(nonSaloon?1.60:4.50);
}
String money(double n)=>currencyAmount(n);
Widget _card(Widget child)=>Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(color:_panel,
 border:Border.all(color:_stroke),borderRadius:BorderRadius.circular(18)),child:child);
Widget _line(String label,String value,{bool highlight=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:7),
 child:Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:12,color:_muted))),
  Text(value,style:TextStyle(fontSize:14,fontWeight:FontWeight.bold,color:highlight?_mint:Colors.white))]));
Future<void> _open(String url) async { await launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication); }
class InsuranceTool extends StatefulWidget {
 const InsuranceTool({super.key});
 @override State<InsuranceTool> createState()=>_InsuranceToolState();
}

class _InsuranceToolState extends State<InsuranceTool>{
 final insured=TextEditingController();
 final windscreenAmount=TextEditingController();
 int? selectedEngineBand;
 InsuranceCover cover=InsuranceCover.comprehensive;
 InsuranceRegion region=InsuranceRegion.peninsular;
 double? ncd;
 bool windscreen=false;

 @override void initState(){
  super.initState();
  for(final input in [insured,windscreenAmount]){input.addListener(refresh);}
 }
 void refresh(){if(mounted)setState((){});}
 @override void dispose(){
  insured.dispose();windscreenAmount.dispose();super.dispose();
 }

 @override Widget build(BuildContext context){
  final comprehensive=cover==InsuranceCover.comprehensive;
  final glassSelected=comprehensive&&windscreen;
  final glassValue=glassSelected?parsePositive(windscreenAmount.text):0.0;
  final estimate=estimateMotorInsurance(
   sumInsured:parsePositive(insured.text),
   engineCc:selectedEngineBand,
   ncdPercent:ncd,cover:cover,region:region,
   windscreenSum:glassValue??double.nan,
  );
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Insurance Estimate')),
   body:ListView(padding:const EdgeInsets.fromLTRB(17,12,17,27),children:[
    const Text('Car Insurance Calculator',
     style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
    const SizedBox(height:5),
    const Text('Estimate automatically from your vehicle details.',
     style:TextStyle(color:_muted,fontSize:12)),
    const SizedBox(height:16),
    const Text('Type of Coverage',style:TextStyle(fontWeight:FontWeight.w700,fontSize:13)),
    const SizedBox(height:8),
    SegmentedButton<InsuranceCover>(
     selected:{cover},
     segments:const [
      ButtonSegment(value:InsuranceCover.comprehensive,
       label:Text('Comprehensive',style:TextStyle(fontSize:12))),
      ButtonSegment(value:InsuranceCover.thirdParty,
       label:Text('Third Party',style:TextStyle(fontSize:12))),
     ],
     onSelectionChanged:(selection)=>setState(()=>cover=selection.first),
     style:ButtonStyle(visualDensity:VisualDensity.compact),
    ),
    const SizedBox(height:15),
    TextField(
     controller:insured,
     keyboardType:const TextInputType.numberWithOptions(decimal:true),
     inputFormatters:const [GroupedNumberInputFormatter()],
     decoration:const InputDecoration(
      labelText:'Market Value / Sum Insured (RM)',
      hintText:'e.g. 50,000',
     ),
    ),
    if(!comprehensive)...[
     const SizedBox(height:5),
     const Text(
      'For reference only. Third Party covers third-party liability, '
      'not damage to your own car. Market value does not affect this estimate.',
      style:TextStyle(color:_muted,fontSize:11),
     ),
    ],
    const SizedBox(height:11),
    DropdownButtonFormField<int>(
     initialValue:selectedEngineBand,
     isExpanded:true,
     hint:const Text('Select engine capacity'),
     decoration:const InputDecoration(labelText:'Engine Capacity'),
     items:const [
      DropdownMenuItem(value:1400,child:Text('0 – 1,400 cc')),
      DropdownMenuItem(value:1650,child:Text('1,401 – 1,650 cc')),
      DropdownMenuItem(value:2200,child:Text('1,651 – 2,200 cc')),
      DropdownMenuItem(value:3050,child:Text('2,201 – 3,050 cc')),
      DropdownMenuItem(value:4100,child:Text('3,051 – 4,100 cc')),
      DropdownMenuItem(value:4250,child:Text('4,101 – 4,250 cc')),
      DropdownMenuItem(value:4400,child:Text('4,251 – 4,400 cc')),
      DropdownMenuItem(value:4401,child:Text('Over 4,400 cc')),
     ],
     onChanged:(v)=>setState(()=>selectedEngineBand=v),
    ),
    const SizedBox(height:11),
    DropdownButtonFormField<InsuranceRegion>(
     initialValue:region,isExpanded:true,
     decoration:const InputDecoration(labelText:'Location'),
     items:const [
      DropdownMenuItem(value:InsuranceRegion.peninsular,
       child:Text('Peninsular Malaysia')),
      DropdownMenuItem(value:InsuranceRegion.eastMalaysia,
       child:Text('Sabah / Sarawak')),
     ],
     onChanged:(next){if(next!=null)setState(()=>region=next);},
    ),
    const SizedBox(height:11),
    DropdownButtonFormField<double>(
     initialValue:ncd,isExpanded:true,
     hint:const Text('Choose NCD'),
     decoration:const InputDecoration(labelText:'No Claim Discount (NCD)'),
     items:const [0.0,25.0,30.0,38.33,45.0,55.0].map((v)=>
      DropdownMenuItem<double>(value:v,
       child:Text(v==38.33?'38.33%':v.toStringAsFixed(0)+'%'))).toList(),
     onChanged:(next)=>setState(()=>ncd=next),
    ),
    if(comprehensive)...[
     const SizedBox(height:14),
     Material(
      color:_panel,
      shape:RoundedRectangleBorder(
       borderRadius:BorderRadius.circular(16),
       side:const BorderSide(color:_stroke)),
      clipBehavior:Clip.antiAlias,
      child:SwitchListTile.adaptive(
       contentPadding:const EdgeInsets.symmetric(horizontal:14),
       title:const Text('Windscreen Cover',
        style:TextStyle(fontSize:14,fontWeight:FontWeight.w700)),
       subtitle:const Text('Optional',style:TextStyle(fontSize:11,color:_muted)),
       activeColor:_mint,value:windscreen,
       onChanged:(checked)=>setState(()=>windscreen=checked),
      ),
     ),
     if(windscreen)...[
      const SizedBox(height:10),
      TextField(
       controller:windscreenAmount,
       keyboardType:const TextInputType.numberWithOptions(decimal:true),
       inputFormatters:const [GroupedNumberInputFormatter()],
       decoration:const InputDecoration(
        labelText:'Windscreen Sum Insured (RM)',
        hintText:'e.g. 3,000',
       ),
      ),
      const SizedBox(height:6),
      const Text('Indicative premium: 15% of windscreen cover.',
       style:TextStyle(color:_muted,fontSize:11)),
     ]
    ],
    const SizedBox(height:17),
    if(estimate==null)
     const Padding(padding:EdgeInsets.symmetric(vertical:10),
      child:Text('Enter the required vehicle details to see the estimated premium.',
       style:TextStyle(color:_muted,fontSize:12)))
    else _card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('ESTIMATED YEARLY INSURANCE',
      style:TextStyle(color:_muted,fontSize:11,letterSpacing:1)),
     const SizedBox(height:8),
     FittedBox(fit:BoxFit.scaleDown,alignment:Alignment.centerLeft,
      child:Text(money(estimate.total),
       style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900,color:_mint))),
     const Divider(color:_stroke,height:26),
     _line('Estimated basic premium',money(estimate.basicPremium)),
     _line('NCD discount','− '+money(estimate.ncdSaving)),
     if(glassSelected)_line('Windscreen premium',money(estimate.windscreenPremium)),
     _line('SST (8%)',money(estimate.serviceTax)),
     _line('Stamp duty',money(estimate.stampDuty)),
    ])),
    const SizedBox(height:12),
    const Text(
     'Baseline based on the former Malaysian Motor Tariff, not a live insurer quote. '
     'Current premiums vary by insurer, driver, car model and risk profile. '
     'Confirm the final amount with your insurer.',
     style:TextStyle(color:_muted,fontSize:11)),
   ]));
 }
}
class RoadTaxTool extends StatefulWidget{
 const RoadTaxTool({super.key});
 @override State<RoadTaxTool> createState()=>_RoadTaxToolState();
}
class _RoadTaxToolState extends State<RoadTaxTool>{
 final cc=TextEditingController(); bool nonSaloon=false;
 @override void initState(){super.initState();cc.addListener(refresh);}
 void refresh(){if(mounted)setState((){});}
 @override void dispose(){cc.dispose();super.dispose();}
 @override Widget build(BuildContext context){
  final v=int.tryParse(cc.text.replaceAll(',',''));
  final estimate=v==null?null:peninsularRoadTax(v,nonSaloon:nonSaloon);
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Road Tax Calculator')),
   body:ListView(padding:const EdgeInsets.all(17),children:[
    const Text('Annual Road Tax',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
    const SizedBox(height:5),const Text('Private petrol/diesel · Peninsular Malaysia · 12 months',
     style:TextStyle(fontSize:12,color:_muted)),
    const SizedBox(height:18),
    TextField(controller:cc,keyboardType:TextInputType.number,
     inputFormatters:const [GroupedNumberInputFormatter(decimalPlaces:0)],
     decoration:const InputDecoration(labelText:'Engine capacity (cc)',hintText:'e.g. 1,498')),
    const SizedBox(height:14),
    SegmentedButton<bool>(segments:const [
     ButtonSegment(value:false,label:Text('Saloon')),
     ButtonSegment(value:true,label:Text('Non-saloon'))],
     selected:{nonSaloon},onSelectionChanged:(v)=>setState(()=>nonSaloon=v.first)),
    const SizedBox(height:17),
    estimate==null?_card(const Text('Enter engine capacity to calculate.',style:TextStyle(color:_muted))):
     _card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('ESTIMATED ANNUAL ROAD TAX',style:TextStyle(fontSize:11,color:_muted,letterSpacing:1)),
      const SizedBox(height:10),Text(money(estimate),style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900,color:_mint)),
      const SizedBox(height:11),_line('Engine capacity',groupedDigits(v.toString())+' cc'),
      _line('Usage','Private ${nonSaloon?'non-saloon':'saloon'}'),
      _line('Region','Peninsular Malaysia'),
     ])),
    const SizedBox(height:15),
    const Text('Other regions, electric vehicles, commercial registration and special vehicle classes can have different rates. '
     'This calculator is limited to the JPJ private Peninsular category shown above.',
     style:TextStyle(color:_muted,fontSize:11)),
    TextButton.icon(onPressed:()=>_open('https://www.mot.gov.my/en/land/operators/road-taxes'),
     icon:const Icon(Icons.open_in_new),label:const Text('JPJ / MOT official rate references')),
   ]));
 }
}
