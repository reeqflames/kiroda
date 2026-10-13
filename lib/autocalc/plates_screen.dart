import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'plates_data.dart';

const b=Color(0xFF0D161C), surface=Color(0xFF18282E), mint=Color(0xFF6DE5C1),
  muted=Color(0xFFADC2C0), stroke=Color(0xFF30494C);
const key='autocalc_plates_last_good_v8';
const feedSetting='ac_authorized_plates_feed_v8';
const jpj='https://www.jpj.gov.my/en/inquiry-of-latest-registration-number/';

class LatestPlatesScreen extends StatefulWidget {
 const LatestPlatesScreen({super.key});
 @override State<LatestPlatesScreen> createState()=>_LatestPlatesScreenState();
}
class _LatestPlatesScreenState extends State<LatestPlatesScreen>{
 PlateSnapshot? snapshot;
 bool loading=false, failed=false, expanded=false;
 String feedUrl=platesFeedUrl;
 @override void initState(){super.initState();init();}
 Future<void> init()async{
  try {
   final p=await SharedPreferences.getInstance();
   feedUrl=p.getString(feedSetting)??platesFeedUrl;
   final old=p.getString(key);
   if(old!=null&&mounted){
    final cached=PlateSnapshot.fromJson(jsonDecode(old),cached:true);
    if(cached!=null)setState(()=>snapshot=cached);
   }
  }catch(_){}
  if(feedUrl.isNotEmpty)await refresh();
 }
 Future<void> refresh()async{
  if(loading)return;
  if(!validPlateFeedUrl(feedUrl)){
   if(mounted)setState(()=>failed=true);
   return;
  }
  setState((){loading=true;failed=false;});
  try {
   final r=await http.get(Uri.parse(feedUrl),headers:const {'Accept':'application/json'})
    .timeout(const Duration(seconds:15));
   if(r.statusCode!=200||r.body.length>350000)throw const FormatException('Unusable response');
   final fresh=PlateSnapshot.fromJson(jsonDecode(r.body));
   if(fresh==null)throw const FormatException('Invalid response');
   if(mounted)setState(()=>snapshot=fresh);
   if(!fresh.stale){
    final p=await SharedPreferences.getInstance();
    await p.setString(key,r.body);
   }
  }catch(_){if(mounted)setState(()=>failed=true);}
  finally{if(mounted)setState(()=>loading=false);}
 }
 Future<void> configure()async{
  final url=TextEditingController(text:feedUrl);
  await showDialog<void>(context:context,builder:(dialogCtx)=>AlertDialog(
   title:const Text('Plate data source'),
   content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Enter a permitted HTTPS JSON feed URL. AutoCalc expects a success, plates, fetchedAt payload. '
     'This does not change AutoQuote Ema.',style:TextStyle(fontSize:12)),
    const SizedBox(height:12),
    TextField(controller:url,autocorrect:false,keyboardType:TextInputType.url,
     decoration:const InputDecoration(labelText:'Authorized feed URL')),
   ]),
   actions:[
    TextButton(onPressed:()=>Navigator.pop(dialogCtx),child:const Text('Cancel')),
    TextButton(onPressed:()async{
     final input=url.text.trim();
     if(input.isNotEmpty&&!validPlateFeedUrl(input)){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
       content:Text('Please enter a valid HTTPS endpoint.')));
      return;
     }
     final p=await SharedPreferences.getInstance();
     await p.setString(feedSetting,input);
     if(input!=feedUrl)await p.remove(key);
     if(mounted)setState((){
      feedUrl=input;snapshot=null;failed=input.isEmpty;
     });
     if(dialogCtx.mounted)Navigator.pop(dialogCtx);
     if(input.isNotEmpty)await refresh();
    },child:const Text('Save')),
   ]));
  url.dispose();
 }
 Future<void> openJpj()async{
  if(!await launchUrl(Uri.parse(jpj),mode:LaunchMode.externalApplication)&&mounted){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Unable to open JPJ')));
  }
 }
 @override Widget build(BuildContext context){
  final data=snapshot;
  final status=feedUrl.isEmpty?'NOT CONNECTED':data==null?'UNAVAILABLE':(failed||data.stale?'SAVED':'LIVE');
  return RefreshIndicator(onRefresh:refresh,color:mint,child:ListView(
   physics:const AlwaysScrollableScrollPhysics(),
   padding:const EdgeInsets.fromLTRB(16,8,16,28),children:[
    Row(children:[
     const Icon(Icons.confirmation_number_outlined,color:mint,size:26),
     const SizedBox(width:9),
     const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Latest Plate Numbers',style:TextStyle(fontWeight:FontWeight.w900,fontSize:21)),
      Text('Malaysia running numbers',style:TextStyle(color:muted,fontSize:12))])),
     IconButton(tooltip:'Configure authorized plate feed',onPressed:configure,
      icon:const Icon(Icons.settings_outlined,color:muted)),
     IconButton(tooltip:'Refresh',onPressed:loading?null:refresh,
      icon:loading?const SizedBox(width:21,height:21,child:CircularProgressIndicator(strokeWidth:2,color:mint))
       :const Icon(Icons.refresh_rounded,color:mint)),
    ]),
    const SizedBox(height:13),
    Row(children:[
     Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
      decoration:BoxDecoration(color:status=='LIVE'?const Color(0xFF1C5647):const Color(0xFF334349),
       borderRadius:BorderRadius.circular(99)),
      child:Text(status,style:TextStyle(fontSize:10,color:status=='LIVE'?mint:muted,fontWeight:FontWeight.w900))),
     const SizedBox(width:10),
     Expanded(child:Text(data==null?(feedUrl.isEmpty?'Connect a permitted data source':'No saved data yet'):
      (data.sourceUpdatedAt.isEmpty?'Update time unavailable':data.sourceUpdatedAt),
       maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:muted,fontSize:11))),
    ]),
    const SizedBox(height:14),
    if(data==null)_empty(),
    if(data!=null)...[
     if(failed||data.stale)const Padding(padding:EdgeInsets.only(bottom:12),
      child:Text('Saved data. Verify the latest number with JPJ before using it.',
       style:TextStyle(color:Color(0xFFE6D09E),fontSize:11))),
     const Text('FEATURED',style:TextStyle(color:muted,fontSize:10,letterSpacing:1.4,fontWeight:FontWeight.bold)),
     const SizedBox(height:9),
     ...data.featured.map((p)=>Padding(padding:const EdgeInsets.only(bottom:9),child:_featured(p))),
     if(data.featured.isEmpty)const Text('KL and Selangor not available',style:TextStyle(color:muted)),
     const SizedBox(height:9),
     InkWell(onTap:()=>setState(()=>expanded=!expanded),borderRadius:BorderRadius.circular(15),
      child:Container(padding:const EdgeInsets.all(14),
       decoration:BoxDecoration(color:surface,border:Border.all(color:stroke),borderRadius:BorderRadius.circular(15)),
       child:Row(children:[
        const Icon(Icons.map_outlined,color:mint),const SizedBox(width:10),
        Expanded(child:Text('Other areas ('+data.others.length.toString()+')',
         style:const TextStyle(fontSize:13,fontWeight:FontWeight.w800))),
        Icon(expanded?Icons.expand_less:Icons.expand_more,color:muted),
       ]))),
     if(expanded)...[
      const SizedBox(height:9),
      ...data.others.map((p)=>Padding(padding:const EdgeInsets.only(bottom:7),child:_other(p))),
     ],
    ],
    const SizedBox(height:14),
    OutlinedButton.icon(onPressed:openJpj,icon:const Icon(Icons.verified_outlined),
     label:const Text('Verify with JPJ'),
     style:OutlinedButton.styleFrom(foregroundColor:mint,minimumSize:const Size.fromHeight(48),
      side:const BorderSide(color:stroke))),
    const SizedBox(height:6),
    const Text('External tracking data, not an official JPJ confirmation.',
     textAlign:TextAlign.center,style:TextStyle(color:muted,fontSize:10)),
   ]));
 }
 Widget _shell(Widget child)=>Container(
  padding:const EdgeInsets.all(15),
  decoration:BoxDecoration(color:surface,border:Border.all(color:stroke),borderRadius:BorderRadius.circular(17)),
  child:child);
 Widget _empty()=>_shell(Column(children:[
  const Icon(Icons.wifi_off_rounded,color:muted,size:34),
  const SizedBox(height:9),
  Text(feedUrl.isEmpty?'Plate feed not connected':'Latest numbers unavailable',
   style:const TextStyle(fontWeight:FontWeight.bold)),
  const SizedBox(height:5),
  Text(feedUrl.isEmpty?'Add an authorized data feed in Settings, or verify directly with JPJ.':
   'Data source could not provide verified plate numbers. Check it and try again.',
   style:TextStyle(color:muted,fontSize:12),textAlign:TextAlign.center),
  TextButton.icon(onPressed:feedUrl.isEmpty?configure:(loading?null:refresh),
   icon:Icon(feedUrl.isEmpty?Icons.settings:Icons.refresh),
   label:Text(feedUrl.isEmpty?'Configure source':'Try again')),
 ]));
 Widget _featured(PlateRecord p)=>_shell(Row(children:[
  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(p.state,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w900)),
   const SizedBox(height:4),
   const Text('RUNNING NUMBER',style:TextStyle(fontSize:9,color:muted,letterSpacing:1)),
  ])),
  const SizedBox(width:8),
  Container(constraints:const BoxConstraints(minWidth:118),
   padding:const EdgeInsets.symmetric(horizontal:12,vertical:12),
   decoration:BoxDecoration(color:Colors.black,border:Border.all(color:const Color(0xFF6A7B7E)),
    borderRadius:BorderRadius.circular(10)),
   child:Text(p.plate,textAlign:TextAlign.center,
    style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:17,letterSpacing:1))),
 ]));
 Widget _other(PlateRecord p)=>_shell(Row(children:[
  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(p.state,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:13)),
   Text(p.region,style:const TextStyle(color:muted,fontSize:10)),
  ])),
  const SizedBox(width:8),
  Text(p.plate,style:const TextStyle(color:mint,fontSize:15,fontWeight:FontWeight.w900)),
 ]));
}
