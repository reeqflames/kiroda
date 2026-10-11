
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _bg=Color(0xFF0D161C), _mint=Color(0xFF6DE5C1), _sub=Color(0xFFADC2C0), _card=Color(0xFF18282E);
class LatestPlatesScreen extends StatefulWidget {
 const LatestPlatesScreen({super.key});
 @override State<LatestPlatesScreen> createState()=>_LatestPlatesScreenState();
}
class _LatestPlatesScreenState extends State<LatestPlatesScreen> {
 static const platehaus='https://www.platehaus.my/plate-index';
 static const jpj='https://www.jpj.gov.my/semakan-nombor-pendaftaran-terkini/';
 late final WebViewController browser;
 int source=0,loading=0;
 String? error;
 final urls=[platehaus,jpj];
 @override void initState() {
  super.initState();
  browser=WebViewController()
   ..setJavaScriptMode(JavaScriptMode.unrestricted)
   ..setBackgroundColor(const Color(0xFFFFFFFF))
   ..setNavigationDelegate(NavigationDelegate(
    onProgress:(p){if(mounted)setState(()=>loading=p);},
    onPageStarted:(_){if(mounted)setState((){loading=0;error=null;});},
    onPageFinished:(_){if(mounted)setState(()=>loading=100);},
    onWebResourceError:(e){if(e.isForMainFrame??true){if(mounted)setState(()=>error=e.description);}},
   ))
   ..loadRequest(Uri.parse(platehaus));
 }
 void choose(int v){
  setState((){source=v;error=null;loading=0;});
  browser.loadRequest(Uri.parse(urls[v]));
 }
 Future<void> outside()async{
  final uri=Uri.parse(urls[source]);
  if(!await launchUrl(uri,mode:LaunchMode.externalApplication)&&mounted){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Unable to open browser')));
  }
 }
 @override Widget build(BuildContext context)=>Column(children:[
  Padding(padding:const EdgeInsets.fromLTRB(16,5,16,10),
   child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Row(children:[
     Icon(Icons.pin_outlined,color:_mint,size:25),SizedBox(width:8),
     Text('Latest JPJ Plates',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900))]),
    const SizedBox(height:5),
    const Text('View the original live source inside AutoCalc MY.',
     style:TextStyle(color:_sub,fontSize:12)),
    const SizedBox(height:12),
    Container(padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:_card,borderRadius:BorderRadius.circular(15)),
     child:Row(children:[
      _choice('Platehaus',0),
      _choice('Official JPJ',1),
     ])),
    const SizedBox(height:9),
    Row(children:[
     const Expanded(child:Text('SOURCE WEBSITE · no data copied or modified',style:TextStyle(color:_sub,fontSize:9))),
     IconButton(onPressed:()=>browser.reload(),tooltip:'Refresh source',icon:const Icon(Icons.refresh,color:_mint)),
     IconButton(onPressed:outside,tooltip:'Open source in browser',icon:const Icon(Icons.open_in_new,color:_mint)),
    ]),
    if(loading<100)LinearProgressIndicator(value:loading<=0?null:loading/100,
      minHeight:2,color:_mint,backgroundColor:_card),
   ])),
  Expanded(child:Container(
   margin:const EdgeInsets.fromLTRB(10,0,10,10),
   clipBehavior:Clip.hardEdge,
   decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17)),
   child:error!=null?Center(child:Padding(padding:const EdgeInsets.all(25),child:Column(
    mainAxisAlignment:MainAxisAlignment.center,children:[
     const Icon(Icons.wifi_off_rounded,color:Colors.black87,size:40),
     const SizedBox(height:10),
     const Text('Source did not load',style:TextStyle(color:Colors.black87,fontWeight:FontWeight.w800)),
     const SizedBox(height:5),Text(error!,textAlign:TextAlign.center,
      style:const TextStyle(color:Colors.black54,fontSize:12)),
     const SizedBox(height:12),
     FilledButton(onPressed:(){setState(()=>error=null);browser.reload();},child:const Text('Try again')),
     TextButton(onPressed:outside,child:const Text('Open in browser')),
    ]))):WebViewWidget(controller:browser),
  )),
  const Padding(padding:EdgeInsets.fromLTRB(16,0,16,7),
   child:Text('Platehaus is an independent website. JPJ may request manual verification. Numbers shown are controlled by their original sources.',
    style:TextStyle(color:_sub,fontSize:10),textAlign:TextAlign.center)),
 ]);
 Widget _choice(String s,int value)=>Expanded(child:InkWell(
  onTap:()=>choose(value),
  borderRadius:BorderRadius.circular(12),
  child:AnimatedContainer(duration:const Duration(milliseconds:150),
   padding:const EdgeInsets.symmetric(vertical:12),
   decoration:BoxDecoration(color:source==value?const Color(0xFF285A48):Colors.transparent,
    borderRadius:BorderRadius.circular(12)),
   child:Text(s,textAlign:TextAlign.center,
    style:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:source==value?_mint:_sub)))));
}
