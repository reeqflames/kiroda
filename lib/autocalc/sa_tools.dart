
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'number_format.dart';
const _bg=Color(0xFF0D161C),_panel=Color(0xFF18282E),_mint=Color(0xFF6DE5C1),_muted=Color(0xFFADC2C0),_stroke=Color(0xFF30494C);
double? parsePositive(String value,{bool zero=false}){
 final n=double.tryParse(value.replaceAll(',','').trim());
 if(n==null||!n.isFinite||n<0||(!zero&&n==0))return null;
 return n;
}
double roundCents(double v)=>(v*100).roundToDouble()/100;
class InsuranceResult {
 const InsuranceResult(this.baseAfterNcd,this.ncdDeduction,this.sst,this.total);
 final double baseAfterNcd,ncdDeduction,sst,total;
}
InsuranceResult? estimateInsurance({required double? base,required double? extra,required double? sstPercent,
 required double? stamp,required double? ncd}) {
 if(base==null||extra==null||sstPercent==null||stamp==null||ncd==null||base<=0||
 extra<0||sstPercent<0||sstPercent>30||stamp<0||ncd<0||ncd>55)return null;
 final discount=roundCents(base*ncd/100);
 final after=roundCents(base-discount);
 final sst=roundCents((after+extra)*sstPercent/100);
 return InsuranceResult(after,discount,sst,roundCents(after+extra+sst+stamp));
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
/// 15% is a commonly advertised windscreen add-on rate, not a universal quote.
double estimateWindscreenPremium(double sumInsured) =>
    roundCents(sumInsured * 0.15);

enum CoverType { comprehensive, thirdParty }

class InsuranceTool extends StatefulWidget {
 const InsuranceTool({super.key});
 @override State<InsuranceTool> createState()=>_InsuranceToolState();
}
class _InsuranceToolState extends State<InsuranceTool>{
 final base=TextEditingController();
 final glassCover=TextEditingController();
 double? ncd;
 CoverType cover=CoverType.comprehensive;
 bool windscreen=false;
 @override void initState(){
  super.initState();
  base.addListener(update);
  glassCover.addListener(update);
 }
 void update(){if(mounted)setState((){});}
 @override void dispose(){base.dispose();glassCover.dispose();super.dispose();}
 @override Widget build(BuildContext context){
  final hasGlass=cover==CoverType.comprehensive&&windscreen;
  final insuredGlass=hasGlass?parsePositive(glassCover.text):0.0;
  final glassPremium=insuredGlass==null?null:estimateWindscreenPremium(insuredGlass);
  final premium=estimateInsurance(
   base:parsePositive(base.text),
   extra:glassPremium,
   sstPercent:8,
   stamp:10,
   ncd:ncd,
  );
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Insurance Estimate')),
   body:ListView(padding:const EdgeInsets.fromLTRB(17,12,17,28),children:[
    const Text('Private Car Insurance',
     style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
    const SizedBox(height:5),
    const Text('Use the basic premium provided by your insurer.',
     style:TextStyle(color:_muted,fontSize:12)),
    const SizedBox(height:16),
    const Text('Type of Coverage',style:TextStyle(fontWeight:FontWeight.w700,fontSize:13)),
    const SizedBox(height:9),
    SegmentedButton<CoverType>(
      segments:const [
       ButtonSegment(value:CoverType.comprehensive,label:Text('Comprehensive')),
       ButtonSegment(value:CoverType.thirdParty,label:Text('Third Party')),
      ],
      selected:{cover},
      onSelectionChanged:(v)=>setState(()=>cover=v.first),
      style:ButtonStyle(visualDensity:VisualDensity.compact),
    ),
    const SizedBox(height:15),
    TextField(
     controller:base,keyboardType:const TextInputType.numberWithOptions(decimal:true),
     inputFormatters:const [GroupedNumberInputFormatter()],
     decoration:const InputDecoration(
      labelText:'Basic Premium Before NCD (RM)',
      hintText:'e.g. 2,500',
     ),
    ),
    const SizedBox(height:11),
    DropdownButtonFormField<double>(
      key:ValueKey(ncd),
      initialValue:ncd,
      hint:const Text('Select NCD'),
      decoration:const InputDecoration(labelText:'No Claim Discount (NCD)'),
      items:const [0.0,25.0,30.0,38.33,45.0,55.0].map((v)=>
        DropdownMenuItem<double>(value:v,
          child:Text(v==38.33?'38.33%':v.toStringAsFixed(0)+'%'))).toList(),
      onChanged:(value)=>setState(()=>ncd=value),
    ),
    if(cover==CoverType.comprehensive)...[
      const SizedBox(height:14),
      Container(
       decoration:BoxDecoration(color:_panel,borderRadius:BorderRadius.circular(16),
        border:Border.all(color:_stroke)),
       child:SwitchListTile.adaptive(
        contentPadding:const EdgeInsets.symmetric(horizontal:14),
        title:const Text('Windscreen Cover',style:TextStyle(fontSize:14,fontWeight:FontWeight.w700)),
        subtitle:const Text('Optional',style:TextStyle(fontSize:11,color:_muted)),
        activeColor:_mint,value:windscreen,
        onChanged:(v)=>setState(()=>windscreen=v),
       ),
      ),
      if(windscreen)...[
       const SizedBox(height:10),
       TextField(
        controller:glassCover,
        inputFormatters:const [GroupedNumberInputFormatter()],
        keyboardType:const TextInputType.numberWithOptions(decimal:true),
        decoration:const InputDecoration(
         labelText:'Windscreen Sum Insured (RM)',hintText:'e.g. 3,000'),
       ),
       const SizedBox(height:6),
       Text(glassPremium==null
        ? 'Estimated windscreen premium: 15% of sum insured'
        : 'Estimated windscreen premium: '+money(glassPremium)+' (15%)',
        style:const TextStyle(color:_muted,fontSize:11)),
      ]
    ],
    const SizedBox(height:17),
    if(premium!=null)...[
     _card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('ESTIMATED YEARLY INSURANCE',
       style:TextStyle(color:_muted,fontSize:11,letterSpacing:1)),
      const SizedBox(height:9),
      FittedBox(fit:BoxFit.scaleDown,alignment:Alignment.centerLeft,
       child:Text(money(premium.total),
        style:const TextStyle(color:_mint,fontSize:32,fontWeight:FontWeight.w900))),
      const Divider(color:_stroke,height:25),
      _line('Basic premium',money(parsePositive(base.text)!)),
      _line('NCD discount','- '+money(premium.ncdDeduction)),
      if(hasGlass)_line('Windscreen add-on',money(glassPremium!)),
      _line('SST (8%)',money(premium.sst)),
      _line('Stamp duty',money(10)),
     ])),
    ]else const Padding(
      padding:EdgeInsets.symmetric(vertical:12),
      child:Text('Enter basic premium and NCD to view your estimate.',
       style:TextStyle(color:_muted,fontSize:12)),
    ),
    const SizedBox(height:13),
    const Text(
     'Indicative calculation only. SST and RM10 stamp duty are included automatically. '
     'Insurer add-on rates and taxable amounts may differ; verify the final insurer quotation.',
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
