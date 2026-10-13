import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'finance.dart';
import 'otr_finance.dart';
import 'number_format.dart';

const bg=Color(0xFF0D161C),panel=Color(0xFF18282E),mint=Color(0xFF6DE5C1),muted=Color(0xFFADC2C0),stroke=Color(0xFF30494C);
const otrStorage='ac_saved_otr_v8';
class OtrScreen extends StatefulWidget{
 const OtrScreen({super.key,this.initialInsurance,this.initialRoadTax,this.showSaved=false});
 final double? initialInsurance,initialRoadTax;
 final bool showSaved;
 @override State<OtrScreen> createState()=>_OtrScreenState();
}
class _OtrScreenState extends State<OtrScreen>{
 final car=TextEditingController(),rebate=TextEditingController(),insurance=TextEditingController(),
 roadTax=TextEditingController(),fees=TextEditingController(),booking=TextEditingController(),
 equity=TextEditingController(),custom=TextEditingController(),rate=TextEditingController(),
 caption=TextEditingController(),advisor=TextEditingController(),phone=TextEditingController();
 int? years;
 LoanMode rateMode=LoanMode.flat;
 FinanceShare finance=FinanceShare.ninety;
 List<String> saved=[];
 List<TextEditingController> get fields=>[car,rebate,insurance,roadTax,fees,booking,equity,custom,rate,caption,advisor,phone];
 @override void initState(){
  super.initState();
  if(widget.initialInsurance!=null)insurance.text=groupedDigits(widget.initialInsurance!.toStringAsFixed(2));
  if(widget.initialRoadTax!=null)roadTax.text=groupedDigits(widget.initialRoadTax!.toStringAsFixed(2));
  for(final x in fields)x.addListener(repaint);
  load();
  if(widget.showSaved)WidgetsBinding.instance.addPostFrameCallback((_){if(mounted)history();});
 }
 void repaint(){if(mounted)setState((){});}
 @override void dispose(){for(final x in fields)x.dispose();super.dispose();}
 double? number(TextEditingController c)=>double.tryParse(c.text.replaceAll(',','').trim());
 double optional(TextEditingController c)=>number(c)??0;
 OtrBreakdown? get estimate{
  final p=number(car),r=number(rate);
  if(p==null||r==null||years==null)return null;
  try{return calculateOtr(carPrice:p,rebate:optional(rebate),insurance:optional(insurance),
   roadTax:optional(roadTax),fees:optional(fees),booking:optional(booking),
   tradeInEquity:optional(equity),annualRate:r,years:years!,
   rateMode:rateMode,financeShare:finance,customLoanAmount:number(custom));}
  catch(_){return null;}
 }
 Future<void> load()async{
  final p=await SharedPreferences.getInstance();
  if(mounted)setState((){
   saved=p.getStringList(otrStorage)??[];
   advisor.text=p.getString('ac_sa')??'';
   phone.text=p.getString('ac_phone')??'';
  });
 }
 Map<String,dynamic> data()=>{
  'title':caption.text,'car':car.text,'rebate':rebate.text,'insurance':insurance.text,
  'roadTax':roadTax.text,'fees':fees.text,'booking':booking.text,'equity':equity.text,
  'custom':custom.text,'rate':rate.text,'years':years,
  'rateMode':rateMode.name,'finance':finance.name,
  'date':DateTime.now().toIso8601String(),
 };
 Future<void> save()async{
  if(estimate==null)return;
  saved.insert(0,jsonEncode(data()));
  if(saved.length>70)saved.removeLast();
  final p=await SharedPreferences.getInstance();
  await p.setStringList(otrStorage,saved);
  if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(
   const SnackBar(content:Text('OTR quotation saved offline')));}
 }
 void restore(String raw){
  final d=jsonDecode(raw) as Map<String,dynamic>;
  final pairs={'title':caption,'car':car,'rebate':rebate,'insurance':insurance,
   'roadTax':roadTax,'fees':fees,'booking':booking,'equity':equity,
   'custom':custom,'rate':rate};
  pairs.forEach((k,v)=>v.text=(d[k]??'').toString());
  setState((){
   years=(d['years'] as num?)?.toInt();
   rateMode=d['rateMode']=='eir'?LoanMode.eir:LoanMode.flat;
   finance=d['finance']=='full'?FinanceShare.full:
      d['finance']=='custom'?FinanceShare.custom:FinanceShare.ninety;
  });
  Navigator.pop(context);
 }
 void history()=>showModalBottomSheet<void>(context:context,isScrollControlled:true,showDragHandle:true,
  backgroundColor:bg,builder:(ctx)=>SafeArea(child:SizedBox(height:400,
   child:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Saved OTR Quotes',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    if(saved.isEmpty)const Padding(padding:EdgeInsets.all(24),child:
      Text('No saved OTR quotes yet.',style:TextStyle(color:muted))),
    ...List.generate(saved.length,(i){
     final q=jsonDecode(saved[i]) as Map<String,dynamic>;
     return Card(child:ListTile(
      title:Text((q['title']??'').toString().isEmpty?'Vehicle quotation':q['title'].toString(),
       maxLines:1,overflow:TextOverflow.ellipsis),
      subtitle:Text(q['car']?.toString()??''),
      onTap:()=>restore(saved[i]),
      trailing:IconButton(tooltip:'Delete saved quote',
       icon:const Icon(Icons.delete_outline),
       onPressed:()async{
        final next=List<String>.from(saved)..removeAt(i);
        final p=await SharedPreferences.getInstance();
        await p.setStringList(otrStorage,next);
        if(mounted)setState(()=>saved=next);
        if(ctx.mounted){Navigator.pop(ctx);history();}
       }),
     ));
    }),
   ]))));
 Widget field(String title,Widget child)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Text(title,style:const TextStyle(fontSize:11,color:muted,fontWeight:FontWeight.w600),
   overflow:TextOverflow.ellipsis,maxLines:1),
  const SizedBox(height:5),
  SizedBox(height:49,child:child),
 ]);
 Widget num(String title,TextEditingController ctrl,{bool required=false})=>field(title,
   TextField(controller:ctrl,inputFormatters:const [GroupedNumberInputFormatter()],
    keyboardType:const TextInputType.numberWithOptions(decimal:true),
    style:const TextStyle(fontSize:14),
    decoration:InputDecoration(isDense:true,
     hintText:required?'Enter amount':'0',prefixText:'RM ',
     contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:13))));
 Widget duo(Widget a,Widget b)=>Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Expanded(child:a),const SizedBox(width:9),Expanded(child:b)]);
 Widget infoRow(String title,double amount,{bool small=false})=>Padding(
  padding:const EdgeInsets.symmetric(vertical:3),
  child:Row(children:[Expanded(child:Text(title,style:TextStyle(
   fontSize:small?11:12,color:muted))),Text(myr(amount,cents:true),
   style:TextStyle(fontWeight:FontWeight.w800,fontSize:small?11:12,
    color:small?muted:Colors.white))]));
 Widget heading(String s)=>Padding(padding:const EdgeInsets.only(top:13,bottom:8),
   child:Text(s,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w800)));
 @override Widget build(BuildContext context){
  final x=estimate;
  return Scaffold(backgroundColor:bg,appBar:AppBar(title:const Text('OTR & Down Payment'),
   backgroundColor:bg,actions:[IconButton(tooltip:'Saved OTR quotations',
     onPressed:history,icon:const Icon(Icons.bookmarks_outlined,color:mint))]),
   body:ListView(padding:const EdgeInsets.fromLTRB(16,5,16,26),children:[
    const Text('Vehicle quotation',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
    const Text('Calculate on-the-road cost and cash required.',
     style:TextStyle(color:muted,fontSize:11)),
    heading('Vehicle price & charges'),
    num('Car price',car,required:true),
    const SizedBox(height:9),duo(num('Rebate',rebate),num('Insurance',insurance)),
    const SizedBox(height:9),duo(num('Road tax',roadTax),num('Other fees',fees)),
    heading('Financing'),
    SegmentedButton<FinanceShare>(selected:{finance},showSelectedIcon:false,
     style:ButtonStyle(visualDensity:VisualDensity.compact),
     segments:const [ButtonSegment(value:FinanceShare.full,label:Text('Full')),
      ButtonSegment(value:FinanceShare.ninety,label:Text('90%')),
      ButtonSegment(value:FinanceShare.custom,label:Text('Custom'))],
     onSelectionChanged:(s)=>setState(()=>finance=s.first)),
    if(finance==FinanceShare.custom)...[const SizedBox(height:9),
      num('Custom loan amount',custom,required:true)],
    const SizedBox(height:9),
    duo(field('Interest (% per annum)',TextField(controller:rate,
      keyboardType:const TextInputType.numberWithOptions(decimal:true),
      decoration:const InputDecoration(isDense:true,hintText:'2.70',
       contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:13)))),
     field('Years',DropdownButtonFormField<int>(
      key:ValueKey('otr-$years'),initialValue:years,isExpanded:true,
      hint:const Text('Choose',style:TextStyle(fontSize:13)),
      items:List.generate(12,(i)=>DropdownMenuItem(value:i+1,
       child:Text((i+1).toString()+' years',style:const TextStyle(fontSize:12)))),
      decoration:const InputDecoration(isDense:true,
       contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:12)),
      onChanged:(v)=>setState(()=>years=v)))),
    const SizedBox(height:10),
    SegmentedButton<LoanMode>(selected:{rateMode},showSelectedIcon:false,
     segments:const [ButtonSegment(value:LoanMode.flat,label:Text('Flat')),
      ButtonSegment(value:LoanMode.eir,label:Text('EIR reducing'))],
     onSelectionChanged:(s)=>setState(()=>rateMode=s.first)),
    heading('Credits'),
    duo(num('Booking paid',booking),num('Trade-in equity',equity)),
    const SizedBox(height:17),
    if(x==null)const Text('Enter car price, rate and years to calculate.',
      style:TextStyle(color:muted,fontSize:12))
    else Container(
     padding:const EdgeInsets.all(16),
     decoration:BoxDecoration(
      gradient:const LinearGradient(colors:[Color(0xFF205043),Color(0xFF19333A)]),
      border:Border.all(color:const Color(0xFF3D806F)),
      borderRadius:BorderRadius.circular(18)),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('ESTIMATED MONTHLY',
       style:TextStyle(color:muted,fontSize:11,letterSpacing:1)),
      const SizedBox(height:4),
      Text(myr(x.loanPlan.monthlyRounded),style:const TextStyle(
       color:mint,fontWeight:FontWeight.w900,fontSize:31)),
      const Divider(color:stroke,height:20),
      infoRow('Estimated OTR',x.otrPrice),
      infoRow('Financed amount',x.loanAmount),
      infoRow('Down payment',x.deposit),
      infoRow('Cash due after credits',x.cashDue),
      if(x.excessCredit>0)infoRow('Unused credit',x.excessCredit,small:true),
      infoRow('Final installment (indicative)',
       x.loanPlan.finalInstallment,small:true),
     ])),
    if(x!=null)...[
     const SizedBox(height:12),
     field('Quote name (optional)',TextField(controller:caption,
      decoration:const InputDecoration(isDense:true,hintText:'e.g. Jetour Dashing',
       contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:13)))),
     const SizedBox(height:11),
     duo(FilledButton.icon(onPressed:save,icon:const Icon(Icons.bookmark_add_outlined),
       label:const Text('Save')),
      FilledButton.icon(onPressed:()=>showModalBottomSheet<void>(
       context:context,isScrollControlled:true,showDragHandle:true,
       backgroundColor:bg,builder:(_)=>OtrSharePreview(
        result:x,title:caption.text.trim(),advisor:advisor.text,phone:phone.text)),
       icon:const Icon(Icons.share_outlined),label:const Text('Share PNG'),
       style:FilledButton.styleFrom(backgroundColor:mint,foregroundColor:bg))),
    ],
    const SizedBox(height:13),
    const Text('Insurance, road tax and fees are cash expenses by default. Booking and trade-in equity reduce cash due, not car price. Actual lender financing eligibility may differ.',
     style:TextStyle(color:muted,fontSize:11)),
   ]));
 }
}
class OtrSharePreview extends StatefulWidget{
 const OtrSharePreview({super.key,required this.result,required this.title,
  required this.advisor,required this.phone});
 final OtrBreakdown result;final String title,advisor,phone;
 @override State<OtrSharePreview> createState()=>_OtrSharePreviewState();
}
class _OtrSharePreviewState extends State<OtrSharePreview>{
 final capture=GlobalKey();bool busy=false;
 Widget row(String label,double n,{bool quiet=false})=>Padding(
  padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[
   Expanded(child:Text(label,style:TextStyle(color:const Color(0xFF647970),
    fontSize:quiet?10:12))),
   Text(myr(n,cents:true),style:TextStyle(color:const Color(0xFF183B2F),
    fontWeight:FontWeight.w800,fontSize:quiet?11:12)),
  ]));
 Future<void> share()async{
  if(busy)return;
  setState(()=>busy=true);
  try{
   final boundary=capture.currentContext!.findRenderObject() as RenderRepaintBoundary;
   final image=await boundary.toImage(pixelRatio:3);
   final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
   if(bytes==null)throw Exception('PNG export failed');
   final file=File((await getTemporaryDirectory()).path+'/autocalc_otr.png');
   await file.writeAsBytes(bytes.buffer.asUint8List(),flush:true);
   await SharePlus.instance.share(ShareParams(files:[XFile(file.path,mimeType:'image/png')],
    text:'AutoCalc MY indicative OTR quotation'));
  }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content:Text('Share failed: $e')));}
  finally{if(mounted)setState(()=>busy=false);}
 }
 @override Widget build(BuildContext context){
  final x=widget.result;
  return SafeArea(child:SingleChildScrollView(
   padding:const EdgeInsets.fromLTRB(15,0,15,20),child:Column(children:[
    const Text('CUSTOMER QUOTATION',style:TextStyle(fontWeight:FontWeight.w800)),
    const SizedBox(height:12),
    RepaintBoundary(key:capture,child:Container(width:double.infinity,
     padding:const EdgeInsets.all(23),color:const Color(0xFFF7FAF8),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text.rich(TextSpan(children:[TextSpan(text:'AutoCalc ',style:
       TextStyle(color:Color(0xFF1A4131))),TextSpan(text:'MY',
       style:TextStyle(color:Color(0xFF148B6B)))]),
       style:TextStyle(fontSize:23,fontWeight:FontWeight.w900)),
      const Text('INDICATIVE VEHICLE QUOTATION',style:TextStyle(
       color:Color(0xFF779086),fontSize:10,letterSpacing:1)),
      const Divider(height:23,color:Color(0xFFD0DED6)),
      Text(widget.title.isEmpty?'Car Quotation':widget.title,style:const TextStyle(
       color:Color(0xFF1B4030),fontSize:16,fontWeight:FontWeight.w800)),
      const SizedBox(height:12),
      const Text('Estimated monthly',style:TextStyle(fontSize:12,
       color:Color(0xFF71847A))),
      FittedBox(fit:BoxFit.scaleDown,child:Text(myr(x.loanPlan.monthlyRounded),
       style:const TextStyle(color:Color(0xFF0B6347),
        fontWeight:FontWeight.w900,fontSize:38))),
      const SizedBox(height:9),
      row('OTR (incl. selected costs)',x.otrPrice),
      row('Net car price',x.netCarPrice),
      row('Financed amount',x.loanAmount),
      row('Down payment',x.deposit),
      row('Cash due after credits',x.cashDue),
      row('Adjusted last installment',x.loanPlan.finalInstallment,quiet:true),
      const SizedBox(height:7),
      Text(x.loanPlan.ratePercent.toStringAsFixed(2)+'% '+
        (x.loanPlan.mode==LoanMode.flat?'flat':'effective')+' / '+
        x.loanPlan.years.toString()+' years',
       style:const TextStyle(color:Color(0xFF6A8076),fontSize:11)),
      if(widget.advisor.isNotEmpty||widget.phone.isNotEmpty)...[
       const Divider(height:24,color:Color(0xFFD0DED6)),
       if(widget.advisor.isNotEmpty)Text(widget.advisor,style:const TextStyle(
        color:Color(0xFF173B30),fontWeight:FontWeight.w800)),
       if(widget.phone.isNotEmpty)Text(widget.phone,
        style:const TextStyle(color:Color(0xFF6A8076),fontSize:12)),
      ],
      const SizedBox(height:18),
      const Text('Estimate only • Subject to bank, insurance and JPJ confirmation.',
       style:TextStyle(color:Color(0xFF87988E),fontSize:10)),
     ]))),
    const SizedBox(height:12),
    SizedBox(width:double.infinity,child:FilledButton.icon(
     onPressed:busy?null:share,icon:const Icon(Icons.ios_share),
     label:Text(busy?'Preparing image...':'Share PNG to customer'))),
   ])));
 }
}
