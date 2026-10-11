
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
String money(double n)=>'RM '+n.toStringAsFixed(2);
Widget _card(Widget child)=>Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(color:_panel,
 border:Border.all(color:_stroke),borderRadius:BorderRadius.circular(18)),child:child);
Widget _line(String label,String value,{bool highlight=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:7),
 child:Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:12,color:_muted))),
  Text(value,style:TextStyle(fontSize:14,fontWeight:FontWeight.bold,color:highlight?_mint:Colors.white))]));
Future<void> _open(String url)=>launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication);
class InsuranceTool extends StatefulWidget {
 const InsuranceTool({super.key});
 @override State<InsuranceTool> createState()=>_InsuranceToolState();
}
class _InsuranceToolState extends State<InsuranceTool>{
 final base=TextEditingController(),addon=TextEditingController(),sst=TextEditingController(text:'8'),stamp=TextEditingController(text:'10');
 double? ncd;
 @override void initState(){super.initState();for(final c in [base,addon,sst,stamp]){c.addListener(update);}}
 void update(){if(mounted)setState((){});}
 @override void dispose(){for(final c in [base,addon,sst,stamp]){c.dispose();}super.dispose();}
 @override Widget build(BuildContext context){
  final r=estimateInsurance(base:parsePositive(base.text),extra:parsePositive(addon.text,zero:true),
   sstPercent:parsePositive(sst.text,zero:true),stamp:parsePositive(stamp.text,zero:true),ncd:ncd);
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Insurance Estimate')),
   body:ListView(padding:const EdgeInsets.all(17),children:[
    const Text('Private Car Insurance',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
    const SizedBox(height:6),
    const Text('Enter the basic premium quoted by an insurer, BEFORE NCD. This does not generate an insurer premium.',
     style:TextStyle(color:_muted,fontSize:12)),
    const SizedBox(height:18),
    TextField(controller:base,keyboardType:const TextInputType.numberWithOptions(decimal:true),
     decoration:const InputDecoration(labelText:'Basic premium before NCD (RM)')),
    const SizedBox(height:10),
    DropdownButtonFormField<double>(value:ncd,
     hint:const Text('Choose NCD'),decoration:const InputDecoration(labelText:'NCD (%)'),
     items:[0.0,25.0,30.0,38.33,45.0,55.0].map((v)=>
      DropdownMenuItem<double>(value:v,child:Text('${v.toStringAsFixed(v==38.33?2:0)}%'))).toList(),
     onChanged:(v)=>setState(()=>ncd=v)),
    const SizedBox(height:10),
    TextField(controller:addon,keyboardType:const TextInputType.numberWithOptions(decimal:true),
     decoration:const InputDecoration(labelText:'Other cover / add-ons (RM)',hintText:'Enter 0 if none')),
    const SizedBox(height:10),
    Row(children:[
     Expanded(child:TextField(controller:sst,keyboardType:const TextInputType.numberWithOptions(decimal:true),
      decoration:const InputDecoration(labelText:'SST (%)'))),
     const SizedBox(width:10),
     Expanded(child:TextField(controller:stamp,keyboardType:const TextInputType.numberWithOptions(decimal:true),
      decoration:const InputDecoration(labelText:'Stamp duty (RM)'))),
    ]),
    const SizedBox(height:17),
    if(r==null)_card(const Text('Enter basic premium, NCD and add-ons to see an estimated total.',
     style:TextStyle(color:_muted)))
    else _card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('ESTIMATED TOTAL',style:TextStyle(color:_muted,fontSize:11,letterSpacing:1)),
     const SizedBox(height:7),Text(money(r.total),style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900,color:_mint)),
     const Divider(color:_stroke,height:26),
     _line('NCD discount','- '+money(r.ncdDeduction)),
     _line('Premium after NCD',money(r.baseAfterNcd)),
     _line('Add-on premiums',money(parsePositive(addon.text,zero:true)!)),
     _line('Estimated service tax',money(r.sst)),
     _line('Stamp duty',money(parsePositive(stamp.text,zero:true)!)),
    ])),
    const SizedBox(height:12),
    const Text('NCD is applied to eligible basic premium, not to the complete OTR / insurance total. '
     'Add-on tax treatment and actual premium depend on the insurer. Confirm official quotation before sharing.',
     style:TextStyle(color:_muted,fontSize:11)),
    const SizedBox(height:8),
    TextButton.icon(onPressed:()=>_open('https://piam.org.my/news-media/stay-ahead/articles/page/how-to-transfer-your-ncd-when-buying-a-new-car-in-malaysia/'),
     icon:const Icon(Icons.open_in_new),label:const Text('PIAM NCD reference')),
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
  final v=int.tryParse(cc.text);
  final estimate=v==null?null:peninsularRoadTax(v,nonSaloon:nonSaloon);
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Road Tax Calculator')),
   body:ListView(padding:const EdgeInsets.all(17),children:[
    const Text('Annual Road Tax',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
    const SizedBox(height:5),const Text('Private petrol/diesel · Peninsular Malaysia · 12 months',
     style:TextStyle(fontSize:12,color:_muted)),
    const SizedBox(height:18),
    TextField(controller:cc,keyboardType:TextInputType.number,
     decoration:const InputDecoration(labelText:'Engine capacity (cc)',hintText:'e.g. 1498')),
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
      const SizedBox(height:11),_line('Engine capacity','$v cc'),
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
