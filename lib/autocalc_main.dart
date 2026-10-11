
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'autocalc/finance.dart';
import 'autocalc/plates_screen.dart';
import 'autocalc/sa_tools.dart';

const bg=Color(0xFF0D161C), cardColor=Color(0xFF18282E), accent=Color(0xFF6DE5C1), muted=Color(0xFFADC2C0), border=Color(0xFF2F4A4C);
void main(){WidgetsFlutterBinding.ensureInitialized();runApp(const AutoCalcApp());}
class AutoCalcApp extends StatelessWidget{
 const AutoCalcApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(
  title:'AutoCalc MY',debugShowCheckedModeBanner:false,
  theme:ThemeData(useMaterial3:true,brightness:Brightness.dark,scaffoldBackgroundColor:bg,
   colorScheme:const ColorScheme.dark(primary:accent,surface:cardColor),
   inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:const Color(0xFF14242A),
    border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)),
    contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:15))),
  home:const AutoHome());
}
class AutoHome extends StatefulWidget{
 const AutoHome({super.key});
 @override State<AutoHome> createState()=>_AutoHomeState();
}
class _AutoHomeState extends State<AutoHome>{
 final loan=TextEditingController(),rate=TextEditingController(),label=TextEditingController(text:'Car Loan Estimate'),sa=TextEditingController(),phone=TextEditingController();
 int? years; int tab=0,paid=0; LoanMode mode=LoanMode.flat;List<String> history=[];
 @override void initState(){super.initState();loan.addListener(refresh);rate.addListener(refresh);label.addListener(refresh);load();}
 void refresh(){if(mounted)setState((){});}
 @override void dispose(){loan.dispose();rate.dispose();label.dispose();sa.dispose();phone.dispose();super.dispose();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();if(mounted)setState((){
   history=p.getStringList('ac_quotes')??[];sa.text=p.getString('ac_sa')??'';phone.text=p.getString('ac_phone')??'';
 });}
 LoanPlan? get calc{final a=double.tryParse(loan.text.replaceAll(',','')),r=double.tryParse(rate.text);
  if(a==null||r==null||years==null)return null;try{return calculateLoan(amount:a,ratePercent:r,years:years!,mode:mode);}catch(_){return null;}}
 void info(String t){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t)));}
 Future<void> save()async{final x=calc;if(x==null)return;
  setState((){history.insert(0,jsonEncode({'title':label.text,'amount':x.amount,'rate':x.ratePercent,'years':years,'mode':mode.name}));if(history.length>60)history.removeLast();});
  final p=await SharedPreferences.getInstance();await p.setStringList('ac_quotes',history);info('Saved offline');
 }
 void restore(String q){final m=jsonDecode(q) as Map<String,dynamic>;
  loan.text=(m['amount'] as num).toString();rate.text=(m['rate'] as num).toString();label.text=m['title'].toString();
  setState((){years=(m['years'] as num).toInt();mode=m['mode']=='eir'?LoanMode.eir:LoanMode.flat;tab=0;});
 }
 @override Widget build(BuildContext context){final x=calc;
  return Scaffold(
   appBar:AppBar(toolbarHeight:70,backgroundColor:bg,title:Row(children:[
    Container(padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:const Color(0xFF21463C),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.directions_car_filled,color:accent)),
    const SizedBox(width:10),const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text.rich(TextSpan(children:[TextSpan(text:'AutoCalc '),TextSpan(text:'MY',style:TextStyle(color:accent))]),style:TextStyle(fontSize:21,fontWeight:FontWeight.w900)),
     Text('SA EDITION  •  AD-FREE',style:TextStyle(fontSize:10,letterSpacing:1,color:muted))])]),
    actions:[IconButton(tooltip:'Tools',onPressed:tools,icon:const Icon(Icons.grid_view_rounded,color:muted)),
     IconButton(tooltip:'SA Profile',onPressed:profile,icon:const Icon(Icons.tune_rounded,color:muted))]),
   body:SafeArea(child:tab==0?calculator(x):tab==1?schedule(x):tab==2?const LatestPlatesScreen():saved()),
   bottomNavigationBar:NavigationBar(height:68,backgroundColor:const Color(0xFF122229),indicatorColor:const Color(0xFF205244),selectedIndex:tab,
    onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const [
     NavigationDestination(icon:Icon(Icons.calculate_outlined),selectedIcon:Icon(Icons.calculate,color:accent),label:'Calculator'),
     NavigationDestination(icon:Icon(Icons.calendar_month_outlined),selectedIcon:Icon(Icons.calendar_month,color:accent),label:'Schedule'),
     NavigationDestination(icon:Icon(Icons.pin_outlined),selectedIcon:Icon(Icons.pin,color:accent),label:'Plates'),
     NavigationDestination(icon:Icon(Icons.bookmark_border),selectedIcon:Icon(Icons.bookmark,color:accent),label:'Saved'),
    ]));
 }
 Widget panel(Widget inner)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:cardColor,border:Border.all(color:border),borderRadius:BorderRadius.circular(19)),child:inner);
 Widget title(String a,String b)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900)),
  const SizedBox(height:3),Text(b,style:const TextStyle(color:muted,fontSize:12)),const SizedBox(height:15)]);
 Widget line(String l,String v,{bool quiet=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[
  Expanded(child:Text(l,style:TextStyle(fontSize:quiet?11:12,color:muted))),Text(v,style:TextStyle(color:quiet?muted:Colors.white,fontWeight:FontWeight.w700,fontSize:quiet?12:13))]));
 Widget action(String text,IconData icon,VoidCallback call,{bool primary=false})=>FilledButton.icon(
  style:FilledButton.styleFrom(minimumSize:const Size(0,49),backgroundColor:primary?accent:cardColor,foregroundColor:primary?bg:accent,
   side:primary?null:const BorderSide(color:border),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),
  onPressed:call,icon:Icon(icon,size:17),label:Text(text,style:const TextStyle(fontSize:12,fontWeight:FontWeight.bold)));
 Widget modeTab(String text,LoanMode value)=>Expanded(child:InkWell(onTap:()=>setState((){mode=value;paid=0;}),
  child:AnimatedContainer(duration:const Duration(milliseconds:160),padding:const EdgeInsets.symmetric(vertical:13),
   decoration:BoxDecoration(color:mode==value?const Color(0xFF295849):Colors.transparent,borderRadius:BorderRadius.circular(13)),
   alignment:Alignment.center,child:Text(text,style:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:mode==value?accent:muted)))));
 Widget calculator(LoanPlan? x)=>ListView(padding:const EdgeInsets.fromLTRB(18,6,18,30),children:[
  title('Quick Loan Calculator','Three inputs. Instant results.'),
  Container(padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:cardColor,borderRadius:BorderRadius.circular(16)),
   child:Row(children:[modeTab('Flat Rate',LoanMode.flat),modeTab('Reducing · EIR',LoanMode.eir)])),
  const SizedBox(height:14),
  TextField(controller:loan,keyboardType:const TextInputType.numberWithOptions(decimal:true),
   decoration:const InputDecoration(labelText:'Loan Amount (RM)',prefixIcon:Icon(Icons.account_balance_wallet_outlined))),
  const SizedBox(height:12),
  Row(children:[
   Expanded(child:TextField(controller:rate,keyboardType:const TextInputType.numberWithOptions(decimal:true),
    decoration:const InputDecoration(labelText:'Annual Interest (%)',prefixIcon:Icon(Icons.percent)))),
   const SizedBox(width:10),
   Expanded(child:DropdownButtonFormField<int>(initialValue:years,isExpanded:true,
    hint:const Text('Choose'),
    decoration:const InputDecoration(labelText:'Years',prefixIcon:Icon(Icons.timelapse)),
    items:List.generate(9,(i)=>DropdownMenuItem(value:i+1,child:Text('${i+1} years'))),
    onChanged:(v)=>setState((){years=v;paid=0;}))),
  ]),
  const SizedBox(height:18),
  if(x==null)const Padding(padding:EdgeInsets.symmetric(vertical:8),child:Text('Enter Loan Amount, Interest and Years to calculate.',style:TextStyle(color:muted,fontSize:12)))else ...[
   Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(
    gradient:const LinearGradient(colors:[Color(0xFF1D4C40),Color(0xFF19353A),Color(0xFF15272F)]),
    border:Border.all(color:const Color(0xFF478B78)),borderRadius:BorderRadius.circular(23)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('ESTIMATED MONTHLY',style:TextStyle(color:muted,fontSize:11,letterSpacing:1.4,fontWeight:FontWeight.w700)),
     const SizedBox(height:10),FittedBox(fit:BoxFit.scaleDown,child:Text(myr(x.monthlyRounded),style:const TextStyle(fontSize:43,fontWeight:FontWeight.w900,letterSpacing:-1.1))),
     const Text('/ month · rounded up to RM10',style:TextStyle(color:muted,fontSize:12)),
     const Divider(color:border,height:24),line('Loan amount',myr(x.amount)),
     line('Interest / tenure',x.ratePercent.toStringAsFixed(2)+'% '+(mode==LoanMode.eir?'EIR':'flat')+' · $years years'),
     line('Adjusted final installment',myr(x.finalInstallment,cents:true),quiet:true),
    ])),
   const SizedBox(height:12),
   Row(children:[Expanded(child:action('Payment Table',Icons.table_rows_outlined,()=>setState(()=>tab=1))),const SizedBox(width:9),
    Expanded(child:action('Share PNG',Icons.ios_share,()=>preview(x),primary:true))]),
   const SizedBox(height:9),action('Save this calculation',Icons.bookmark_add_outlined,save),
   const SizedBox(height:15),
   panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('PAYMENT BREAKDOWN',style:TextStyle(color:muted,fontSize:11,letterSpacing:1.1)),
    const SizedBox(height:9),line('Total principal',myr(x.amount,cents:true)),
    line('Total interest',myr(x.totalInterest,cents:true)),const Divider(color:border),
    line('Total repayment',myr(x.totalRepayment,cents:true)),
   ])),

  ],
  const SizedBox(height:17),
  const Text('Indicative only · Bank approval, interest and repayment schedule may differ.',style:TextStyle(color:muted,fontSize:11)),
 ]);
 Widget metric(String label,String value)=>Expanded(child:panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Text(label,style:const TextStyle(color:muted,fontSize:10)),
  const SizedBox(height:8),FittedBox(fit:BoxFit.scaleDown,alignment:Alignment.centerLeft,
   child:Text(value,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900))),
 ])));
 Widget schedule(LoanPlan? x){
  if(x==null)return const Center(child:Text('Enter valid inputs in Calculator first.'));
  final completed=(paid.clamp(0,x.rows.length) as int),ratio=x.amount/x.totalRepayment;
  return ListView(padding:const EdgeInsets.fromLTRB(16,5,16,32),children:[
   title('Full Amortization Schedule',mode==LoanMode.eir?'Reducing balance · Effective Annual Rate':'Flat-rate · Illustrative payment allocation'),
   panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('ESTIMATED MONTHLY',style:TextStyle(color:muted,fontSize:11)),
    Text(myr(x.monthlyRounded),style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900)),
    line('Loan amount',myr(x.amount)),line('Annual rate · tenure',x.ratePercent.toStringAsFixed(2)+'% · $years years'),
    line('Adjusted final installment',myr(x.finalInstallment,cents:true),quiet:true),
   ])),
   const SizedBox(height:10),
   Row(children:[metric('TOTAL PRINCIPAL',myr(x.amount)),const SizedBox(width:8),metric('TOTAL INTEREST',myr(x.totalInterest))]),
   const SizedBox(height:8),
   Row(children:[metric('TOTAL REPAYMENT',myr(x.totalRepayment)),const SizedBox(width:8),metric('PAYMENT COUNT',x.rows.length.toString())]),
   const SizedBox(height:10),
   panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('PAYMENT COMPOSITION',style:TextStyle(fontWeight:FontWeight.w800,fontSize:12)),
    const SizedBox(height:11),
    ClipRRect(borderRadius:BorderRadius.circular(12),child:Row(children:[
     Expanded(flex:(ratio*1000).round().clamp(1,999).toInt(),child:Container(height:12,color:accent)),
     Expanded(flex:((1-ratio)*1000).round().clamp(1,999).toInt(),child:Container(height:12,color:const Color(0xFF426973))),
    ])),
    const SizedBox(height:8),
    Text('Principal '+(ratio*100).toStringAsFixed(1)+'% · Interest '+((1-ratio)*100).toStringAsFixed(1)+'%',style:const TextStyle(color:muted,fontSize:11)),
   ])),
   const SizedBox(height:10),
   panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Icon(Icons.bolt,color:accent),const SizedBox(width:5),
     const Expanded(child:Text('Early Settlement',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17))),
     Text('After $completed payments',style:const TextStyle(fontSize:11,color:muted))]),
    Slider(min:0,max:x.rows.length.toDouble(),divisions:x.rows.length,value:completed.toDouble(),onChanged:(v)=>setState(()=>paid=v.round())),
    Wrap(spacing:5,children:[0,12,36,60,84,108].where((n)=>n<=x.rows.length).map((n)=>
     ActionChip(label:Text('$n',style:const TextStyle(fontSize:11)),onPressed:()=>setState(()=>paid=n))).toList()),
    if(mode==LoanMode.eir)...[
     line('Principal still outstanding',myr(x.balanceAfter(completed),cents:true)),
     line('Future interest potentially avoided',myr(x.futureInterest(completed),cents:true),quiet:true),
     const Text('Estimate excludes bank charges, accrued daily interest and lender-specific adjustments.',style:TextStyle(fontSize:11,color:muted)),
    ]else const Text('Flat-rate early settlement and interest rebate require an official bank settlement statement. No payoff estimate is asserted here.',
      style:TextStyle(color:Color(0xFFE8D098),fontSize:11)),
   ])),
   const SizedBox(height:17),
   title('Payment Table',x.rows.length.toString()+' rows · Scroll vertically and horizontally'),
   Container(decoration:BoxDecoration(color:cardColor,borderRadius:BorderRadius.circular(17),border:Border.all(color:border)),
    child:ClipRRect(borderRadius:BorderRadius.circular(17),child:SingleChildScrollView(scrollDirection:Axis.horizontal,
     child:SizedBox(width:650,child:Column(children:[
      Container(height:43,color:const Color(0xFF244247),child:const Row(children:[
       Cell('MONTH',70,header:true),Cell('PAYMENT',130,header:true),Cell('PRINCIPAL',130,header:true),
       Cell('INTEREST',130,header:true),Cell('BALANCE',180,header:true)])),
      SizedBox(height:405,child:ListView.builder(itemCount:x.rows.length,itemBuilder:(c,i){
       final r=x.rows[i],last=i==x.rows.length-1;
       return Container(height:39,color:last?const Color(0xFF205043):(i.isEven?const Color(0xFF12252B):cardColor),
        child:Row(children:[
         Cell(r.month.toString(),70,last:last),
         Cell(myr(r.payment,cents:true).substring(3),130,last:last),
         Cell(myr(r.principal,cents:true).substring(3),130,last:last),
         Cell(myr(r.interest,cents:true).substring(3),130,last:last),
         Cell(myr(r.balance,cents:true).substring(3),180,last:last),
        ]));
      })),
     ]))))),
   const SizedBox(height:13),action('Share Customer Estimate',Icons.ios_share,()=>preview(x),primary:true),
   const SizedBox(height:10),
   const Text('Illustrative schedule only. For EIR, effective annual rate is converted to equivalent monthly rate.',style:TextStyle(color:muted,fontSize:11)),
  ]);
 }
 Widget saved()=>ListView(padding:const EdgeInsets.fromLTRB(18,5,18,30),children:[
  title('Saved Calculations','Offline and private on this phone'),
  if(history.isEmpty)panel(const Padding(padding:EdgeInsets.all(20),child:Text('No saved calculations yet.',style:TextStyle(color:muted))))
  else ...List.generate(history.length,(i){
   final m=jsonDecode(history[i]) as Map<String,dynamic>;
   return Padding(padding:const EdgeInsets.only(bottom:8),child:panel(Row(children:[
    const Icon(Icons.receipt_outlined,color:accent),const SizedBox(width:9),
    Expanded(child:InkWell(onTap:()=>restore(history[i]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text(m['title'].toString(),maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w800)),
     Text(myr((m['amount'] as num).toDouble())+' · '+m['years'].toString()+' yrs',style:const TextStyle(color:muted,fontSize:11)),
    ]))),
    IconButton(tooltip:'Delete',onPressed:()async{setState(()=>history.removeAt(i));
     final p=await SharedPreferences.getInstance();await p.setStringList('ac_quotes',history);
    },icon:const Icon(Icons.delete_outline,color:muted)),
   ])));
  }),
 ]);
 void preview(LoanPlan x)=>showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:bg,
  showDragHandle:true,builder:(_)=>QuotePreview(x:x,title:label.text,adviser:sa.text,phone:phone.text));
 Future<void> go(String url)async{if(!await launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication))info('Unable to open link');}
 void tools()=>showModalBottomSheet<void>(context:context,backgroundColor:cardColor,showDragHandle:true,
  builder:(c)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,children:[
   const Text('SA TOOLS',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),
   ListTile(leading:const Icon(Icons.pin_outlined,color:accent),title:const Text('Latest Plates · In-app'),
    onTap:(){Navigator.pop(c);setState(()=>tab=2);}),
   ListTile(leading:const Icon(Icons.shield_outlined,color:accent),title:const Text('Insurance Estimate'),
    onTap:(){Navigator.pop(c);Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const InsuranceTool()));}),
   ListTile(leading:const Icon(Icons.car_repair_outlined,color:accent),title:const Text('Road Tax Calculator'),
    onTap:(){Navigator.pop(c);Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const RoadTaxTool()));}),
   ListTile(leading:const Icon(Icons.verified_outlined,color:accent),title:const Text('JPJ · Official Plate Check'),
    onTap:(){Navigator.pop(c);go('https://www.jpj.gov.my/semakan-nombor-pendaftaran-terkini/');}),
   const Text('Bank comparison, full OTR and EV road tax are planned for future builds.',style:TextStyle(fontSize:11,color:muted)),
  ]))));
 void profile()=>showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:cardColor,
  showDragHandle:true,builder:(c)=>Padding(padding:EdgeInsets.fromLTRB(18,4,18,MediaQuery.viewInsetsOf(c).bottom+22),
   child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Text('Sales Advisor Profile',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    const SizedBox(height:13),
    TextField(controller:sa,decoration:const InputDecoration(labelText:'SA name (optional)')),
    const SizedBox(height:10),
    TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'WhatsApp (optional)')),
    const SizedBox(height:12),
    FilledButton(onPressed:()async{final p=await SharedPreferences.getInstance();
     await p.setString('ac_sa',sa.text);await p.setString('ac_phone',phone.text);
     if(c.mounted)Navigator.pop(c);info('Profile saved');
    },child:const Text('Save')),
   ])));
}
class Cell extends StatelessWidget{
 const Cell(this.label,this.width,{super.key,this.header=false,this.last=false});
 final String label;final double width;final bool header,last;
 @override Widget build(BuildContext context)=>SizedBox(width:width,
  child:Center(child:Text(label,style:TextStyle(fontSize:header?10:11,
   color:last?accent:(header?muted:Colors.white),fontWeight:header||last?FontWeight.w800:FontWeight.w500))));
}
class QuotePreview extends StatefulWidget{
 const QuotePreview({super.key,required this.x,required this.title,required this.adviser,required this.phone});
 final LoanPlan x;final String title,adviser,phone;
 @override State<QuotePreview> createState()=>_QuotePreviewState();
}
class _QuotePreviewState extends State<QuotePreview>{
 final imageKey=GlobalKey();bool busy=false;
 Future<void> share()async{
  setState(()=>busy=true);
  try{
   final boundary=imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
   final picture=await boundary.toImage(pixelRatio:3);
   final data=await picture.toByteData(format:ui.ImageByteFormat.png);
   if(data==null)throw Exception('Could not export PNG');
   final file=File((await getTemporaryDirectory()).path+'/autocalc_quote.png');
   await file.writeAsBytes(data.buffer.asUint8List(),flush:true);
   await SharePlus.instance.share(ShareParams(files:[XFile(file.path,mimeType:'image/png')],
    text:'AutoCalc MY - indicative finance quotation'));
  }catch(err){
   if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Share failed: $err')));
  }finally{if(mounted)setState(()=>busy=false);}
 }
 Widget row(String a,String b,{bool quiet=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[
  Expanded(child:Text(a,style:TextStyle(fontSize:quiet?10:12,color:const Color(0xFF687C73)))),
  Text(b,style:TextStyle(color:const Color(0xFF193C2F),fontSize:quiet?11:12,fontWeight:FontWeight.w700))]));
 @override Widget build(BuildContext context){final x=widget.x;
  return SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(16,0,16,20),child:Column(children:[
   const Text('CUSTOMER QUOTATION',style:TextStyle(letterSpacing:1.1,fontWeight:FontWeight.w900)),
   const SizedBox(height:12),
   RepaintBoundary(key:imageKey,child:Container(width:double.infinity,color:const Color(0xFFF8FBF9),
    padding:const EdgeInsets.all(23),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text.rich(TextSpan(children:[TextSpan(text:'AutoCalc ',style:TextStyle(color:Color(0xFF17372D))),
      TextSpan(text:'MY',style:TextStyle(color:Color(0xFF149075)))]),
      style:TextStyle(fontWeight:FontWeight.w900,fontSize:24)),
     const Text('INDICATIVE LOAN ESTIMATE',style:TextStyle(fontSize:10,letterSpacing:1.1,color:Color(0xFF718780))),
     const Divider(height:26,color:Color(0xFFCFDBD7)),
     Text(widget.title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16,color:Color(0xFF163B2E))),
     const SizedBox(height:19),
     const Text('Estimated Monthly',style:TextStyle(fontSize:12,color:Color(0xFF718076))),
     const SizedBox(height:5),
     FittedBox(fit:BoxFit.scaleDown,child:Text(myr(x.monthlyRounded),style:const TextStyle(fontSize:41,fontWeight:FontWeight.w900,color:Color(0xFF0F533F)))),
     const SizedBox(height:17),
     row('Loan amount',myr(x.amount)),
     row('Interest',x.ratePercent.toStringAsFixed(2)+'% '+(x.mode==LoanMode.eir?'EIR':'flat')),
     row('Tenure',x.years.toString()+' years'),
     row('Total repayment',myr(x.totalRepayment,cents:true)),
     const Divider(height:25,color:Color(0xFFCFDBD7)),
     row('Adjusted final installment',myr(x.finalInstallment,cents:true),quiet:true),
     const SizedBox(height:9),
     const Text('Rounded estimate only. Bank-issued installment and final payment may differ.',
      style:TextStyle(color:Color(0xFF849188),fontSize:10)),
     if(widget.adviser.isNotEmpty||widget.phone.isNotEmpty)...[
      const Divider(height:25,color:Color(0xFFCFDBD7)),
      if(widget.adviser.isNotEmpty)Text(widget.adviser,style:const TextStyle(fontWeight:FontWeight.w800,color:Color(0xFF174332))),
      if(widget.phone.isNotEmpty)Text(widget.phone,style:const TextStyle(color:Color(0xFF576E63),fontSize:11)),
     ],
     const SizedBox(height:22),
     const Text('Estimate only · Subject to financier approval.',style:TextStyle(color:Color(0xFF849188),fontSize:10)),
    ]))),
   const SizedBox(height:15),
   SizedBox(width:double.infinity,child:FilledButton.icon(
    onPressed:busy?null:share,icon:const Icon(Icons.ios_share),
    label:Text(busy?'Preparing image...':'Share PNG to Customer'))),
  ])));
 }
}