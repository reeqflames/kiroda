import 'package:flutter/material.dart';
import 'finance.dart';
import 'number_format.dart';
const _bg=Color(0xFF0D161C),_card=Color(0xFF18282E),_mint=Color(0xFF6DE5C1),_muted=Color(0xFFADC2C0);
double? cash(String value)=>double.tryParse(value.replaceAll(',','').trim());
Widget sheet(Widget child)=>Container(padding:const EdgeInsets.all(14),
 decoration:BoxDecoration(color:_card,borderRadius:BorderRadius.circular(16)),child:child);
Widget pair(String name,String value)=>Padding(padding:const EdgeInsets.symmetric(vertical:4),
 child:Row(children:[Expanded(child:Text(name,style:const TextStyle(color:_muted,fontSize:12))),
 Text(value,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:13))]));
class BankOption{
 BankOption();
 final bank=TextEditingController(),rate=TextEditingController();
 int years=9;
 LoanMode mode=LoanMode.flat;
 void dispose(){bank.dispose();rate.dispose();}
}
class BankComparePage extends StatefulWidget{
 const BankComparePage({super.key,this.principal,this.onSelect});
 final double? principal;
 final void Function(double,int,LoanMode)? onSelect;
 @override State<BankComparePage> createState()=>_BankComparePageState();
}
class _BankComparePageState extends State<BankComparePage>{
 late final amount=TextEditingController(text:widget.principal==null?'':groupedDigits(widget.principal!.toStringAsFixed(2)));
 final offers=<BankOption>[BankOption(),BankOption()];
 @override void initState(){super.initState();amount.addListener(redraw);for(final x in offers)x.rate.addListener(redraw);}
 void redraw(){if(mounted)setState((){});}
 @override void dispose(){amount.dispose();for(final x in offers)x.dispose();super.dispose();}
 LoanPlan? calculate(BankOption x){
  final p=cash(amount.text),r=double.tryParse(x.rate.text);
  if(p==null||p<=0||r==null)return null;
  try{return calculateLoan(amount:p,ratePercent:r,years:x.years,mode:x.mode);}catch(_){return null;}
 }
 @override Widget build(BuildContext context){
  final plans=offers.map(calculate).toList();
  final equalTerm=plans.every((x)=>x!=null)&&plans.map((x)=>x!.years).toSet().length==1;
  final costs=plans.whereType<LoanPlan>().map((x)=>x.totalRepayment).toList();
  final cheapest=costs.isEmpty?null:costs.reduce((a,b)=>a<b?a:b);
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Compare Bank Offers')),
   body:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Compare up to 3 financing offers',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800)),
    const SizedBox(height:6),
    const Text('Use rates supplied by a bank. Rates are not downloaded automatically.',
     style:TextStyle(color:_muted,fontSize:11)),
    const SizedBox(height:14),
    TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),
     inputFormatters:const [GroupedNumberInputFormatter()],
     decoration:const InputDecoration(labelText:'Loan Amount (RM)')),
    const SizedBox(height:12),
    ...List.generate(offers.length,(index){
     final item=offers[index],result=plans[index];
     return Padding(padding:const EdgeInsets.only(bottom:10),child:sheet(Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
       Row(children:[
        Expanded(child:Text('OFFER '+(index+1).toString(),style:const TextStyle(color:_mint,fontWeight:FontWeight.w800))),
        if(offers.length>2)IconButton(onPressed:()=>setState((){
         offers.removeAt(index);item.dispose();
        }),icon:const Icon(Icons.close,size:18)),
       ]),
       TextField(controller:item.bank,decoration:const InputDecoration(labelText:'Bank / Offer (optional)',isDense:true)),
       const SizedBox(height:8),
       Row(children:[
        Expanded(child:TextField(controller:item.rate,
         keyboardType:const TextInputType.numberWithOptions(decimal:true),
         decoration:const InputDecoration(labelText:'Rate % p.a.',isDense:true))),
        const SizedBox(width:8),
        Expanded(child:DropdownButtonFormField<int>(
         initialValue:item.years,isExpanded:true,
         decoration:const InputDecoration(labelText:'Years',isDense:true),
         items:List.generate(9,(j)=>DropdownMenuItem(value:j+1,child:Text((j+1).toString()+' years'))),
         onChanged:(v)=>setState(()=>item.years=v??9))),
       ]),
       const SizedBox(height:9),
       SegmentedButton<LoanMode>(
        selected:{item.mode},segments:const [
         ButtonSegment(value:LoanMode.flat,label:Text('Flat')),
         ButtonSegment(value:LoanMode.eir,label:Text('EIR')),
        ],onSelectionChanged:(v)=>setState(()=>item.mode=v.first)),
       if(result!=null)...[
        const Divider(height:24),
        pair('Estimated monthly',myr(result.monthlyRounded)),
        pair('Total interest',myr(result.totalInterest,cents:true)),
        pair('Total repayment',myr(result.totalRepayment,cents:true)),
        pair('Final installment',myr(result.finalInstallment,cents:true)),
        if(equalTerm&&cheapest==result.totalRepayment)
         const Text('Lowest total at equal tenure',style:TextStyle(fontSize:10,color:_mint)),
        if(widget.onSelect!=null)Align(alignment:Alignment.centerRight,
         child:TextButton(onPressed:(){
          widget.onSelect!(result.ratePercent,result.years,result.mode);
          Navigator.pop(context);
         },child:const Text('Apply offer'))),
       ],
      ]))));
    }),
    if(offers.length<3)OutlinedButton.icon(
     onPressed:()=>setState((){
      final item=BankOption();item.rate.addListener(redraw);offers.add(item);
     }),icon:const Icon(Icons.add),label:const Text('Add a third offer')),
    const SizedBox(height:12),
    const Text('Loan amounts and tenures must match for a fair cost comparison. '
      'All outputs are estimates, not bank approvals.',
      style:TextStyle(fontSize:11,color:_muted)),
   ]));
 }
}
class AffordabilityPage extends StatefulWidget{
 const AffordabilityPage({super.key,this.monthly});
 final double? monthly;
 @override State<AffordabilityPage> createState()=>_AffordabilityPageState();
}
class _AffordabilityPageState extends State<AffordabilityPage>{
 final net=TextEditingController(),commitments=TextEditingController(),installment=TextEditingController();
 int planningCeiling=60;
 @override void initState(){
  super.initState();
  if(widget.monthly!=null)installment.text=groupedDigits(widget.monthly!.toStringAsFixed(2));
  for(final c in [net,commitments,installment])c.addListener(redraw);
 }
 void redraw(){if(mounted)setState((){});}
 @override void dispose(){net.dispose();commitments.dispose();installment.dispose();super.dispose();}
 @override Widget build(BuildContext context){
  final income=cash(net.text),existing=cash(commitments.text),car=cash(installment.text);
  final valid=income!=null&&income>0&&existing!=null&&existing>=0&&car!=null&&car>=0;
  final ratio=valid?(existing!+car!)/income!*100:null;
  final ndi=valid?income!-existing!-car!:null;
  final allowance=valid?income!*planningCeiling/100-existing!:null;
  return Scaffold(backgroundColor:_bg,appBar:AppBar(title:const Text('Affordability / DSR')),
   body:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Can I Afford This Car?',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),
    const SizedBox(height:7),
    const Text('Personal planning calculation. Actual bank NDI/DSR rules differ.',
     style:TextStyle(fontSize:11,color:_muted)),
    const SizedBox(height:15),
    ...[(net,'Net monthly income (RM)'),(commitments,'Existing monthly commitments (RM)'),
        (installment,'Proposed car installment (RM)')].map((e)=>
     Padding(padding:const EdgeInsets.only(bottom:10),
      child:TextField(controller:e.$1,
       inputFormatters:const [GroupedNumberInputFormatter()],
       keyboardType:const TextInputType.numberWithOptions(decimal:true),
       decoration:InputDecoration(labelText:e.$2)))),
    Row(children:[
     const Expanded(child:Text('Planning DSR limit',style:TextStyle(color:_muted))),
     DropdownButton<int>(value:planningCeiling,
      items:[40,50,60,70].map((n)=>DropdownMenuItem(value:n,child:Text(n.toString()+'%'))).toList(),
      onChanged:(v)=>setState(()=>planningCeiling=v??60)),
    ]),
    const SizedBox(height:12),
    if(valid)sheet(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('AFFORDABILITY SNAPSHOT',style:TextStyle(color:_muted,fontSize:10)),
     const SizedBox(height:9),
     pair('Calculated DSR',ratio!.toStringAsFixed(1)+'%'),
     pair('Net disposable income',currencyAmount(ndi!)),
     pair('Max installment at selected DSR',currencyAmount(allowance!<0?0:allowance)),
     Text(ratio<=planningCeiling?'Within chosen planning limit':'Above chosen planning limit',
      style:TextStyle(color:ratio<=planningCeiling?_mint:const Color(0xFFFFC17C),
       fontWeight:FontWeight.w800,fontSize:12)),
    ]))else const Text('Enter all three amounts to calculate.',
      style:TextStyle(fontSize:12,color:_muted)),
    const SizedBox(height:10),
    const Text('DSR = (commitments + installment) / net income. '
     'NDI = net income − commitments − installment. '
     'The selected DSR is not a published bank approval threshold.',
     style:TextStyle(fontSize:11,color:_muted)),
   ]));
 }
}
