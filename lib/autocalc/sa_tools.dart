
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
 InsuranceCover cover=InsuranceCover.comprehensive;
 InsuranceRegion region=InsuranceRegion.peninsular;
 int? selectedEngineBand;
 double? ncd;
 bool windscreen=false, showBreakdown=false;
 @override void initState(){
  super.initState();
  insured.addListener(refresh);windscreenAmount.addListener(refresh);
 }
 void refresh(){if(mounted)setState((){});}
 @override void dispose(){insured.dispose();windscreenAmount.dispose();super.dispose();}

 InputDecoration _input({String? hint})=>InputDecoration(
   hintText:hint,isDense:true,contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:12),
   filled:true,fillColor:const Color(0xFF13252B),
   border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),
     borderSide:const BorderSide(color:_stroke)),
   enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),
     borderSide:const BorderSide(color:_stroke)),
 );
 Widget _field(String title, Widget control)=>Column(
   crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,
   children:[
    SizedBox(height:19,child:Text(title,maxLines:1,overflow:TextOverflow.ellipsis,
      style:const TextStyle(color:_muted,fontSize:11,fontWeight:FontWeight.w600))),
    const SizedBox(height:4),
    SizedBox(height:49,child:control),
   ]);
 Widget _group({required Widget left,required Widget right})=>Row(
   crossAxisAlignment:CrossAxisAlignment.start,children:[
    Expanded(child:left),const SizedBox(width:10),Expanded(child:right),
   ]);

 @override Widget build(BuildContext context){
  final comprehensive=cover==InsuranceCover.comprehensive;
  final glassSelected=comprehensive&&windscreen;
  final glassValue=glassSelected?parsePositive(windscreenAmount.text):0.0;
  final estimate=estimateMotorInsurance(
   sumInsured:parsePositive(insured.text),engineCc:selectedEngineBand,
   ncdPercent:ncd,cover:cover,region:region,
   windscreenSum:glassValue??double.nan,
  );
  return Scaffold(
   backgroundColor:_bg,
   appBar:AppBar(toolbarHeight:54,title:const Text('Insurance Estimate',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800))),
   body:SafeArea(child:ListView(
    padding:const EdgeInsets.fromLTRB(16,9,16,24),
    children:[
     SizedBox(height:46,child:SegmentedButton<InsuranceCover>(
      selected:{cover},
      segments:const [
       ButtonSegment(value:InsuranceCover.comprehensive,
        label:Text('Comprehensive',style:TextStyle(fontSize:12))),
       ButtonSegment(value:InsuranceCover.thirdParty,
        label:Text('Third Party',style:TextStyle(fontSize:12))),
      ],
      onSelectionChanged:(v)=>setState(()=>cover=v.first),
      style:const ButtonStyle(visualDensity:VisualDensity.compact),
     )),
     const SizedBox(height:12),
     _field('Market Value / Sum Insured (RM)',
       TextField(controller:insured,
         keyboardType:const TextInputType.numberWithOptions(decimal:true),
         inputFormatters:const [GroupedNumberInputFormatter()],
         decoration:_input(hint:'e.g. 50,000'))),
     const SizedBox(height:10),
     _group(
      left:_field('Engine Capacity',
        DropdownButtonFormField<int>(
         initialValue:selectedEngineBand,isExpanded:true,
         hint:const Text('Select CC',style:TextStyle(fontSize:12)),
         decoration:_input(),
         items:const [
          DropdownMenuItem(value:1400,child:Text('0 – 1,400 cc',style:TextStyle(fontSize:12))),
          DropdownMenuItem(value:1650,child:Text('1,401 – 1,650 cc',style:TextStyle(fontSize:12))),
          DropdownMenuItem(value:2200,child:Text('1,651 – 2,200 cc',style:TextStyle(fontSize:12))),
          DropdownMenuItem(value:3050,child:Text('2,201 – 3,050 cc',style:TextStyle(fontSize:12))),
          DropdownMenuItem(value:4100,child:Text('3,051 – 4,100 cc',style:TextStyle(fontSize:12))),
          DropdownMenuItem(value:4250,child:Text('4,101 – 4,250 cc',style:TextStyle(fontSize:12))),
          DropdownMenuItem(value:4400,child:Text('4,251 – 4,400 cc',style:TextStyle(fontSize:12))),
          DropdownMenuItem(value:4401,child:Text('Over 4,400 cc',style:TextStyle(fontSize:12))),
         ],
         onChanged:(v)=>setState(()=>selectedEngineBand=v),
        )),
      right:_field('Location',
        DropdownButtonFormField<InsuranceRegion>(
          initialValue:region,isExpanded:true,
          decoration:_input(),
          items:const [
           DropdownMenuItem(value:InsuranceRegion.peninsular,
            child:Text('Peninsular',style:TextStyle(fontSize:12))),
           DropdownMenuItem(value:InsuranceRegion.eastMalaysia,
            child:Text('Sabah / Sarawak',style:TextStyle(fontSize:12))),
          ],
          onChanged:(v){if(v!=null)setState(()=>region=v);},
        )),
     ),
     const SizedBox(height:10),
     _group(
      left:_field('NCD',
        DropdownButtonFormField<double>(
          initialValue:ncd,isExpanded:true,decoration:_input(),
          hint:const Text('Select NCD',style:TextStyle(fontSize:12)),
          items:const [0.0,25.0,30.0,38.33,45.0,55.0].map((n)=>
           DropdownMenuItem<double>(value:n,
            child:Text(n==38.33?'38.33%':n.toStringAsFixed(0)+'%',
             style:const TextStyle(fontSize:12)))).toList(),
          onChanged:(v)=>setState(()=>ncd=v),
        )),
      right:_field('Windscreen (optional)',
        Row(children:[
         Expanded(child:TextField(
           controller:windscreenAmount,enabled:glassSelected,
           keyboardType:const TextInputType.numberWithOptions(decimal:true),
           inputFormatters:const [GroupedNumberInputFormatter()],
           decoration:_input(hint:comprehensive?'Amount RM':'N/A'))),
         Transform.scale(scale:.75,child:Switch.adaptive(
           value:glassSelected,onChanged:comprehensive
             ? (v)=>setState(()=>windscreen=v) : null,
           activeColor:_mint)),
        ])),
     ),
     const SizedBox(height:14),
     Container(
      padding:const EdgeInsets.fromLTRB(15,14,15,12),
      decoration:BoxDecoration(color:const Color(0xFF18332F),
       border:Border.all(color:const Color(0xFF37675C)),
       borderRadius:BorderRadius.circular(17)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       const Text('ESTIMATED YEARLY INSURANCE',
        style:TextStyle(fontSize:10,letterSpacing:1,color:_muted)),
       const SizedBox(height:4),
       Text(estimate==null?'—':money(estimate.total),
        style:const TextStyle(fontSize:29,color:_mint,fontWeight:FontWeight.w900)),
       const SizedBox(height:8),
       InkWell(onTap:estimate==null?null:()=>setState(()=>showBreakdown=!showBreakdown),
        child:Row(children:[
         const Expanded(child:Text('Premium Breakdown',
          style:TextStyle(fontSize:11,fontWeight:FontWeight.w600,color:_muted))),
         Icon(showBreakdown?Icons.expand_less:Icons.expand_more,color:_mint,size:20),
        ])),
       if(showBreakdown&&estimate!=null)...[
        const Divider(color:_stroke,height:16),
        _line('Basic premium',money(estimate.basicPremium)),
        _line('NCD saving','− '+money(estimate.ncdSaving)),
        if(glassSelected)_line('Windscreen',money(estimate.windscreenPremium)),
        _line('SST · 8%',money(estimate.serviceTax)),
        _line('Stamp duty',money(estimate.stampDuty)),
       ]
      ])),
     const SizedBox(height:10),
     Text(comprehensive
       ? 'Indicative tariff-based estimate, not an insurer quote.'
       : 'Third Party covers liability only. Sum Insured is retained for switching back.',
      style:const TextStyle(fontSize:11,color:_muted)),
    ],
   )),
  );
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
