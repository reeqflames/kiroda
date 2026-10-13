import 'package:flutter/material.dart';
import 'finance.dart';
import 'bank_compare.dart';
import 'number_format.dart';

const _bg=Color(0xFF0D161C),_card=Color(0xFF18282E),_mint=Color(0xFF6DE5C1),
  _muted=Color(0xFFADC2C0),_stroke=Color(0xFF30494C);

class LoanComparisonScreen extends StatefulWidget {
 const LoanComparisonScreen({super.key,this.initialLoan,this.initialRate,
  this.initialYears,this.initialMode=LoanMode.flat});
 final double? initialLoan,initialRate;
 final int? initialYears;
 final LoanMode initialMode;
 @override State<LoanComparisonScreen> createState()=>_LoanComparisonScreenState();
}
class _LoanComparisonScreenState extends State<LoanComparisonScreen> {
 final amount=TextEditingController();
 final name=[TextEditingController(text:'Offer A'),TextEditingController(text:'Offer B'),
     TextEditingController(text:'Offer C')];
 final rates=[TextEditingController(),TextEditingController(),TextEditingController()];
 late final List<LoanMode> methods;
 late int? years;
 bool three=false;
 @override void initState(){
  super.initState();
  years=widget.initialYears;
  methods=[widget.initialMode,widget.initialMode,widget.initialMode];
  if(widget.initialLoan!=null)amount.text=groupedDigits(widget.initialLoan!.toStringAsFixed(2));
  if(widget.initialRate!=null)rates[0].text=widget.initialRate!.toStringAsFixed(2);
  amount.addListener(redraw);
  for(final v in [...name,...rates])v.addListener(redraw);
 }
 void redraw(){if(mounted)setState((){});}
 @override void dispose(){
  amount.dispose();
  for(final c in [...name,...rates])c.dispose();
  super.dispose();
 }
 BankComparison? get outcome{
  final a=double.tryParse(amount.text.replaceAll(',',''));
  if(a==null||years==null)return null;
  final bids=<BankOffer>[];
  for(var i=0;i<(three?3:2);i++){
   final rate=double.tryParse(rates[i].text.trim());
   if(rate==null||name[i].text.trim().isEmpty)return null;
   bids.add(BankOffer(name:name[i].text.trim(),annualRate:rate,rateMode:methods[i]));
  }
  try{return compareBanks(principal:a,years:years!,offers:bids);}
  catch(_){return null;}
 }
 Widget field(String name,Widget child)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Text(name,style:const TextStyle(color:_muted,fontSize:11,fontWeight:FontWeight.w600)),
  const SizedBox(height:5),SizedBox(height:49,child:child),
 ]);
 Widget row(String label,String value,{bool primary=false})=>Padding(
  padding:const EdgeInsets.symmetric(vertical:4),child:Row(children:[
   Expanded(child:Text(label,style:const TextStyle(fontSize:12,color:_muted))),
   Text(value,style:TextStyle(fontWeight:FontWeight.w800,
    fontSize:primary?14:12,color:primary?_mint:Colors.white)),
  ]));
 @override Widget build(BuildContext context){
  final comparison=outcome;
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Compare Loan Offers'),
   backgroundColor:_bg),
   body:ListView(padding:const EdgeInsets.fromLTRB(16,6,16,28),children:[
    const Text('Compare financing',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900)),
    const SizedBox(height:3),
    const Text('Same loan and tenure, different offers.',
     style:TextStyle(fontSize:11,color:_muted)),
    const SizedBox(height:16),
    Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Expanded(flex:3,child:field('Loan amount',TextField(
      controller:amount,inputFormatters:const [GroupedNumberInputFormatter()],
      keyboardType:const TextInputType.numberWithOptions(decimal:true),
      decoration:const InputDecoration(isDense:true,prefixText:'RM ',
       contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:13))))),
     const SizedBox(width:9),
     Expanded(flex:2,child:field('Years',DropdownButtonFormField<int>(
      key:ValueKey('compare-$years'),initialValue:years,isExpanded:true,
      hint:const Text('Choose',style:TextStyle(fontSize:12)),
      items:List.generate(12,(i)=>DropdownMenuItem<int>(
       value:i+1,child:Text((i+1).toString()+' years',
        style:const TextStyle(fontSize:12)))),
      decoration:const InputDecoration(isDense:true,
       contentPadding:EdgeInsets.symmetric(horizontal:10,vertical:12)),
      onChanged:(v)=>setState(()=>years=v)))),
    ]),
    const SizedBox(height:13),
    for(var i=0;i<(three?3:2);i++)...[
     _offer(i),
     const SizedBox(height:9),
    ],
    SwitchListTile.adaptive(
     contentPadding:EdgeInsets.zero,
     activeColor:_mint,
     title:const Text('Compare third offer',style:TextStyle(fontSize:13)),
     value:three,onChanged:(v)=>setState(()=>three=v)),
    const SizedBox(height:12),
    if(comparison==null)
     const Text('Enter the loan, years and each offer’s annual rate.',
      style:TextStyle(color:_muted,fontSize:12))
    else ...[
     Container(padding:const EdgeInsets.all(16),
      decoration:BoxDecoration(
       gradient:const LinearGradient(colors:[Color(0xFF204C40),Color(0xFF19343B)]),
       borderRadius:BorderRadius.circular(18),
       border:Border.all(color:const Color(0xFF397663))),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       const Text('LOWEST ESTIMATED TOTAL REPAYMENT',
        style:TextStyle(color:_muted,fontSize:10,letterSpacing:1)),
       const SizedBox(height:7),
       Text(comparison.cheapest.offer.name,style:const TextStyle(
        fontWeight:FontWeight.w900,fontSize:19)),
       Text(myr(comparison.cheapest.totalRepayment,cents:true),
        style:const TextStyle(fontWeight:FontWeight.w900,fontSize:26,color:_mint)),
       const SizedBox(height:6),
       row('Difference versus most expensive',
        myr(comparison.maximumTotalSaving,cents:true),primary:true),
      ])),
     const SizedBox(height:13),
     for(final offer in comparison.results)...[
      _resultCard(offer,identical(offer,comparison.cheapest)),
      const SizedBox(height:8),
     ],
    ],
    const SizedBox(height:13),
    const Text('Compare offers only when loan principal and tenure are the same. '
      'EIR means an effective annual rate. Insurance, fees and early settlement '
      'terms vary by bank. Indicative calculations, not approved bank offers.',
     style:TextStyle(color:_muted,fontSize:11)),
   ]));
 }
 Widget _offer(int i)=>Container(
  padding:const EdgeInsets.all(12),
  decoration:BoxDecoration(color:_card,borderRadius:BorderRadius.circular(15),
   border:Border.all(color:_stroke)),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text('OFFER '+String.fromCharCode(65+i),style:const TextStyle(
    color:_mint,fontWeight:FontWeight.w900,fontSize:10,letterSpacing:1)),
   const SizedBox(height:8),
   Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Expanded(child:field('Bank / label',TextField(controller:name[i],
     style:const TextStyle(fontSize:13),
     decoration:const InputDecoration(isDense:true,
      contentPadding:EdgeInsets.symmetric(horizontal:11,vertical:12))))),
    const SizedBox(width:9),
    Expanded(child:field('Rate (%)',TextField(controller:rates[i],
     keyboardType:const TextInputType.numberWithOptions(decimal:true),
     style:const TextStyle(fontSize:13),
     decoration:const InputDecoration(isDense:true,
      contentPadding:EdgeInsets.symmetric(horizontal:11,vertical:12))))),
   ]),
   const SizedBox(height:7),
   SegmentedButton<LoanMode>(
    selected:{methods[i]},showSelectedIcon:false,
    style:ButtonStyle(visualDensity:VisualDensity.compact),
    segments:const [ButtonSegment(value:LoanMode.flat,label:Text('Flat')),
      ButtonSegment(value:LoanMode.eir,label:Text('EIR reducing'))],
    onSelectionChanged:(v)=>setState(()=>methods[i]=v.first)),
  ]));
 Widget _resultCard(ComparedOffer offer,bool best)=>Container(
  padding:const EdgeInsets.all(13),
  decoration:BoxDecoration(color:_card,borderRadius:BorderRadius.circular(14),
   border:Border.all(color:best?_mint:_stroke)),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Row(children:[
    Expanded(child:Text(offer.offer.name,
      style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800))),
    if(best)const Text('LOWEST TOTAL',style:TextStyle(
     color:_mint,fontSize:10,fontWeight:FontWeight.w800)),
   ]),
   const SizedBox(height:7),
   row('Estimated monthly',myr(offer.estimatedMonthly)),
   row('Total interest',myr(offer.totalInterest,cents:true)),
   row('Total repayment',myr(offer.totalRepayment,cents:true)),
   row('Last installment',myr(offer.plan.finalInstallment,cents:true)),
   Text(offer.offer.annualRate.toStringAsFixed(2)+'% '+
    (offer.offer.rateMode==LoanMode.flat?'flat per annum':'effective annually'),
    style:const TextStyle(color:_muted,fontSize:10)),
  ]));
}
