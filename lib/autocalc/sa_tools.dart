
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'number_format.dart';
import 'insurance_tariff.dart';
import 'otr_screen.dart';
import 'road_tax.dart';
const _bg=Color(0xFF0D161C),_panel=Color(0xFF18282E),_mint=Color(0xFF6DE5C1),_muted=Color(0xFFADC2C0),_stroke=Color(0xFF30494C);
double? parsePositive(String value,{bool zero=false}){
 final n=double.tryParse(value.replaceAll(',','').trim());
 if(n==null||!n.isFinite||n<0||(!zero&&n==0))return null;
 return n;
}
double? peninsularRoadTax(int cc,{required bool nonSaloon}) =>
    annualPrivateRoadTax(electric:false,eastMalaysia:false,
     nonSaloon:nonSaloon,engineCc:cc);
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
 final insured=TextEditingController(),windscreenAmount=TextEditingController();
 int? engineBand; double? ncd;
 InsuranceCover cover=InsuranceCover.comprehensive;
 InsuranceRegion region=InsuranceRegion.peninsular;
 bool windscreen=false,showBreakdown=false;
 @override void initState(){
  super.initState();
  insured.addListener(redraw);windscreenAmount.addListener(redraw);
 }
 void redraw(){if(mounted)setState((){});}
 @override void dispose(){insured.dispose();windscreenAmount.dispose();super.dispose();}
 Widget _field(String label,Widget control,{Key? key})=>Column(
  key:key,crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:_muted),
    maxLines:1,overflow:TextOverflow.ellipsis),
   const SizedBox(height:4),
   SizedBox(height:49,width:double.infinity,child:control),
  ]);
 Widget _duo(Widget a,Widget b)=>Row(
  crossAxisAlignment:CrossAxisAlignment.start,children:[
   Expanded(child:a),const SizedBox(width:9),Expanded(child:b)]);
 Widget _breakRow(String a,String b)=>Padding(padding:const EdgeInsets.symmetric(vertical:5),
  child:Row(children:[
   Expanded(child:Text(a,style:const TextStyle(color:_muted,fontSize:11))),
   Text(b,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:12)),
  ]));
 void _info()=>showModalBottomSheet<void>(context:context,backgroundColor:_panel,
  showDragHandle:true,builder:(_)=>const SafeArea(
   child:Padding(padding:EdgeInsets.fromLTRB(18,4,18,22),child:
    Text('This is a baseline estimate using the former Malaysian Motor Tariff, '
     'not a real-time insurer quote. Premiums depend on insurer and risk profile. '
     'NCD is applied to eligible basic premium only. Windscreen uses a provisional '
     '15% of glass cover; SST 8% and RM10 stamp duty are included for illustration.',
     style:TextStyle(color:_muted,height:1.5,fontSize:13)))));
 @override Widget build(BuildContext context){
  final comprehensive=cover==InsuranceCover.comprehensive;
  final glassOn=comprehensive&&windscreen;
  final glass=glassOn?parsePositive(windscreenAmount.text):0.0;
  final quote=estimateMotorInsurance(
   sumInsured:parsePositive(insured.text),engineCc:engineBand,
   ncdPercent:ncd,cover:cover,region:region,
   windscreenSum:glass??double.nan,
  );
  final inputStyle=const TextStyle(fontSize:13,fontWeight:FontWeight.w600);
  const dense=InputDecoration(isDense:true,
   contentPadding:EdgeInsets.symmetric(horizontal:11,vertical:12));
  return Scaffold(backgroundColor:_bg,
   appBar:AppBar(title:const Text('Insurance Estimate'),backgroundColor:_bg,
    actions:[IconButton(tooltip:'How estimate works',onPressed:_info,
     icon:const Icon(Icons.info_outline,color:_mint))]),
   body:ListView(padding:const EdgeInsets.fromLTRB(15,6,15,24),children:[
    SegmentedButton<InsuranceCover>(selected:{cover},showSelectedIcon:false,
     style:ButtonStyle(visualDensity:VisualDensity.compact),
     segments:const [
      ButtonSegment(value:InsuranceCover.comprehensive,
       label:Text('Comprehensive',style:TextStyle(fontSize:12))),
      ButtonSegment(value:InsuranceCover.thirdParty,
       label:Text('Third Party',style:TextStyle(fontSize:12))),
     ],onSelectionChanged:(v)=>setState(()=>cover=v.first)),
    const SizedBox(height:12),
    _field('Market Value / Sum Insured (RM)',TextField(
     controller:insured,keyboardType:const TextInputType.numberWithOptions(decimal:true),
     inputFormatters:const [GroupedNumberInputFormatter()],
     style:inputStyle,decoration:dense.copyWith(hintText:'e.g. 50,000')),
     key:const ValueKey('sum-insured-field')),
    const SizedBox(height:10),
    _duo(
     _field('Engine Capacity',DropdownButtonFormField<int>(
      key:ValueKey('cc-$engineBand'),initialValue:engineBand,isExpanded:true,
      hint:const Text('Choose',style:TextStyle(fontSize:12)),
      decoration:dense,
      items:const [
       DropdownMenuItem(value:1400,child:Text('0 – 1,400 cc')),
       DropdownMenuItem(value:1650,child:Text('1,401 – 1,650 cc')),
       DropdownMenuItem(value:2200,child:Text('1,651 – 2,200 cc')),
       DropdownMenuItem(value:3050,child:Text('2,201 – 3,050 cc')),
       DropdownMenuItem(value:4100,child:Text('3,051 – 4,100 cc')),
       DropdownMenuItem(value:4250,child:Text('4,101 – 4,250 cc')),
       DropdownMenuItem(value:4400,child:Text('4,251 – 4,400 cc')),
       DropdownMenuItem(value:4401,child:Text('Over 4,400 cc')),
      ].map((x)=>DropdownMenuItem<int>(value:x.value,
       child:DefaultTextStyle(style:inputStyle,child:x.child))).toList(),
      onChanged:(v)=>setState(()=>engineBand=v)),
      key:const ValueKey('engine-field')),
     _field('Location',DropdownButtonFormField<InsuranceRegion>(
      key:ValueKey('reg-$region'),initialValue:region,isExpanded:true,
      decoration:dense,
      items:const [
       DropdownMenuItem(value:InsuranceRegion.peninsular,
        child:Text('Peninsular')),
       DropdownMenuItem(value:InsuranceRegion.eastMalaysia,
        child:Text('Sabah / Sarawak')),
      ],onChanged:(v){if(v!=null)setState(()=>region=v);}),
      key:const ValueKey('location-field')),
    ),
    const SizedBox(height:10),
    _duo(
     _field('NCD',DropdownButtonFormField<double>(
      key:ValueKey('ncd-$ncd'),initialValue:ncd,isExpanded:true,
      hint:const Text('Choose',style:TextStyle(fontSize:12)),
      decoration:dense,
      items:const [0.0,25.0,30.0,38.33,45.0,55.0].map((v)=>
       DropdownMenuItem<double>(value:v,child:Text(
        v==38.33?'38.33%':v.toStringAsFixed(0)+'%'))).toList(),
      onChanged:(v)=>setState(()=>ncd=v)),
      key:const ValueKey('ncd-field')),
     _field('Windscreen',Material(
      color:_panel,borderRadius:BorderRadius.circular(12),
      clipBehavior:Clip.antiAlias,
      child:SwitchListTile.adaptive(
       title:const Text('Optional',style:TextStyle(fontSize:12)),
       contentPadding:const EdgeInsets.only(left:10,right:6),
       dense:true,
       activeColor:_mint,
       value:windscreen&&comprehensive,
       onChanged:comprehensive?(v)=>setState(()=>windscreen=v):null),
     ),key:const ValueKey('windscreen-toggle-field')),
    ),
    if(glassOn)...[
     const SizedBox(height:10),
     _field('Windscreen Sum Insured (RM)',TextField(
      controller:windscreenAmount,
      inputFormatters:const [GroupedNumberInputFormatter()],
      keyboardType:const TextInputType.numberWithOptions(decimal:true),
      style:inputStyle,decoration:dense.copyWith(hintText:'e.g. 2,000'))),
    ],
    const SizedBox(height:13),
    if(quote==null)const Padding(
     padding:EdgeInsets.symmetric(vertical:12),
     child:Text('Enter sum insured, engine category and NCD to calculate.',
      style:TextStyle(color:_muted,fontSize:12)))
    else Container(
     padding:const EdgeInsets.fromLTRB(14,13,14,12),
     decoration:BoxDecoration(color:const Color(0xFF19372F),
      border:Border.all(color:const Color(0xFF397363)),
      borderRadius:BorderRadius.circular(17)),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('ESTIMATED YEARLY INSURANCE',style:TextStyle(
       color:_muted,fontSize:10,letterSpacing:1)),
      const SizedBox(height:4),
      Text(money(quote.total),style:const TextStyle(fontSize:30,
       color:_mint,fontWeight:FontWeight.w900)),
      const SizedBox(height:3),
      InkWell(onTap:()=>setState(()=>showBreakdown=!showBreakdown),
       child:Padding(padding:const EdgeInsets.symmetric(vertical:5),
        child:Row(children:[
         const Expanded(child:Text('Incl. SST 8% & RM10 stamp duty',
          style:TextStyle(color:_muted,fontSize:11))),
         Text(showBreakdown?'Hide details':'Breakdown',
          style:const TextStyle(color:_mint,fontSize:11,fontWeight:FontWeight.w700)),
         Icon(showBreakdown?Icons.expand_less:Icons.expand_more,color:_mint,size:18),
        ]))),
      if(showBreakdown)...[
       const Divider(color:_stroke),
       _breakRow('Basic premium',money(quote.basicPremium)),
       _breakRow('NCD saving','− '+money(quote.ncdSaving)),
       if(glassOn)_breakRow('Windscreen',money(quote.windscreenPremium)),
       _breakRow('SST',money(quote.serviceTax)),
       _breakRow('Stamp duty',money(quote.stampDuty)),
      ],
     ])),
    if(quote!=null)...[
     const SizedBox(height:9),
     SizedBox(width:double.infinity,child:OutlinedButton.icon(
      onPressed:()=>Navigator.of(context).push(MaterialPageRoute(
       builder:(_)=>OtrScreen(initialInsurance:quote.total))),
      icon:const Icon(Icons.receipt_long_outlined,size:17),
      label:const Text('Use estimated insurance in OTR'))),
    ],
    const SizedBox(height:6),
    const Text('Indicative former Motor Tariff baseline; verify insurer quotation.',
     style:TextStyle(color:_muted,fontSize:10)),
   ]));
 }
}
class RoadTaxTool extends StatefulWidget {
 const RoadTaxTool({super.key});
 @override State<RoadTaxTool> createState()=>_RoadTaxToolState();
}
class _RoadTaxToolState extends State<RoadTaxTool>{
 final engine=TextEditingController(),kw=TextEditingController();
 bool electric=false,nonSaloon=false,east=false;
 @override void initState(){
  super.initState();engine.addListener(refresh);kw.addListener(refresh);
 }
 void refresh(){if(mounted)setState((){});}
 @override void dispose(){engine.dispose();kw.dispose();super.dispose();}
 Widget field(String title,Widget child)=>Column(
  crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(title,style:const TextStyle(color:_muted,
    fontSize:11,fontWeight:FontWeight.w700)),
   const SizedBox(height:5),
   SizedBox(height:49,width:double.infinity,child:child),
  ]);
 @override Widget build(BuildContext context){
  final value=annualPrivateRoadTax(electric:electric,
   eastMalaysia:east,nonSaloon:nonSaloon,
   engineCc:int.tryParse(engine.text.replaceAll(',','')),
   motorKw:double.tryParse(kw.text.replaceAll(',','')));
  const dense=InputDecoration(isDense:true,
   contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:12));
  return Scaffold(backgroundColor:_bg,
   appBar:AppBar(backgroundColor:_bg,title:const Text('Road Tax Calculator')),
   body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,25),children:[
    const Text('Annual Road Tax',style:TextStyle(
     fontSize:20,fontWeight:FontWeight.w900)),
    const SizedBox(height:4),
    const Text('Private passenger cars • 2026 LKM estimate',
     style:TextStyle(color:_muted,fontSize:11)),
    const SizedBox(height:13),
    SegmentedButton<bool>(selected:{electric},showSelectedIcon:false,
     segments:const [
      ButtonSegment(value:false,label:Text('Petrol / Diesel')),
      ButtonSegment(value:true,label:Text('Electric (EV)')),
     ],onSelectionChanged:(v)=>setState(()=>electric=v.first)),
    const SizedBox(height:12),
    field(electric?'Motor power (kW)':'Engine capacity (cc)',TextField(
     controller:electric?kw:engine,
     keyboardType:const TextInputType.numberWithOptions(decimal:true),
     inputFormatters:[GroupedNumberInputFormatter(decimalPlaces:electric?1:0)],
     decoration:dense.copyWith(hintText:electric?'e.g. 150':'e.g. 1,498'),
    )),
    const SizedBox(height:10),
    Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Expanded(child:field('Region',DropdownButtonFormField<bool>(
      key:ValueKey('region-$east-$electric'),
      initialValue:electric?false:east,isExpanded:true,
      decoration:dense,
      items: [
       DropdownMenuItem(value:false,child:Text(electric?'Nationwide':'Peninsular',
        style:const TextStyle(fontSize:12))),
       if(!electric)const DropdownMenuItem(value:true,
        child:Text('Sabah / Sarawak',style:TextStyle(fontSize:12))),
      ],
      onChanged:electric?null:(v)=>setState(()=>east=v??false)))),
     const SizedBox(width:9),
     Expanded(child:field('Body type',DropdownButtonFormField<bool>(
      key:ValueKey('body-$nonSaloon-$electric'),initialValue:nonSaloon,isExpanded:true,
      decoration:dense,
      items:const [
       DropdownMenuItem(value:false,child:Text('Saloon',style:TextStyle(fontSize:12))),
       DropdownMenuItem(value:true,child:Text('SUV / MPV',style:TextStyle(fontSize:12))),
      ],
      onChanged:electric?null:(v)=>setState(()=>nonSaloon=v??false)))),
    ]),
    const SizedBox(height:15),
    if(value==null)const Text('Enter vehicle engine capacity or EV power.',
     style:TextStyle(color:_muted,fontSize:12))
    else Container(padding:const EdgeInsets.all(17),
     decoration:BoxDecoration(color:const Color(0xFF1B3B32),
      border:Border.all(color:const Color(0xFF367663)),
      borderRadius:BorderRadius.circular(18)),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('ESTIMATED ANNUAL ROAD TAX',
       style:TextStyle(color:_muted,letterSpacing:1,fontSize:11)),
      const SizedBox(height:7),
      Text(money(value),style:const TextStyle(fontWeight:FontWeight.w900,
       color:_mint,fontSize:31)),
      const SizedBox(height:5),
      Text(electric?'Electric 2026 • nationwide':
       (east?'Sabah / Sarawak':'Peninsular')+' • '+
       (nonSaloon?'Non-saloon':'Saloon'),
       style:const TextStyle(color:_muted,fontSize:11)),
     ])),
    if(value!=null)...[
     const SizedBox(height:11),
     SizedBox(width:double.infinity,child:OutlinedButton.icon(
      onPressed:()=>Navigator.of(context).push(MaterialPageRoute(
       builder:(_)=>OtrScreen(initialRoadTax:value))),
      icon:const Icon(Icons.receipt_long_outlined,size:17),
      label:const Text('Use in OTR quotation'))),
    ],
    const SizedBox(height:12),
    const Text('Indicative private-car JPJ schedule. Company, commercial, '
     'special registrations and EV power above 810 kW require official verification.',
     style:TextStyle(color:_muted,fontSize:11)),
    TextButton.icon(onPressed:()=>_open(
      'https://www.jpj.gov.my/panduan-pengiraan-kadar-lkm/'),
     icon:const Icon(Icons.open_in_new,size:17),
     label:const Text('Check JPJ rate schedules')),
   ]));
 }
}
