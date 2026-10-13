/// Reference: JPJ/MOT LKM rate schedules and published 2026 kW bands.
/// Estimation for private individual passenger cars only.
/// Excludes commercial/special registration, motorcycles and taxi licensing.
double? annualPrivateRoadTax({
 required bool electric,
 required bool eastMalaysia,
 required bool nonSaloon,
 int? engineCc,
 double? motorKw,
}) {
 if(electric) return _ev2026(motorKw);
 if(engineCc==null || engineCc<1 || engineCc>20000)return null;
 final cc=engineCc;
 if(!eastMalaysia)return _west(cc,nonSaloon);
 return _east(cc,nonSaloon);
}
double _west(int c,bool n){
 if(c<=1000)return 20;
 if(c<=1200)return n?85:55;
 if(c<=1400)return n?100:70;
 if(c<=1600)return n?120:90;
 if(c<=1800)return (n?300:200)+(c-1600)*(n?.30:.40);
 if(c<=2000)return (n?360:280)+(c-1800)*(n?.40:.50);
 if(c<=2500)return (n?440:380)+(c-2000)*(n?.80:1.00);
 if(c<=3000)return (n?840:880)+(c-2500)*(n?1.60:2.50);
 return (n?1640:2130)+(c-3000)*(n?2.40:4.50);
}
double _east(int c,bool n){
 if(c<=1000)return 20;
 if(c<=1200)return n?42.50:44;
 if(c<=1400)return n?50:56;
 if(c<=1600)return n?60:72;
 if(c<=1800)return (n?150:160)+(c-1600)*(n?.15:.32);
 if(c<=2000)return (n?180:224)+(c-1800)*(n?.20:.25);
 if(c<=2500)return (n?220:274)+(c-2000)*(n?.40:.50);
 if(c<=3000)return (n?420:524)+(c-2500)*(n?.80:1.00);
 return (n?820:1024)+(c-3000)*(n?1.20:1.35);
}
double? _ev2026(double? kw){
 if(kw==null||!kw.isFinite||kw<=0||kw>810)return null;
 if(kw<=50)return 20;
 if(kw<=100)return 20+((kw-50)/10).ceil()*10;
 const groups=<List<num>>[
  [210,100,80,20],
  [310,210,305,30],
  [410,310,615,50],
  [510,410,1115,70],
  [610,510,1835,90],
  [710,610,2825,110],
  [810,710,4045,130],
 ];
 for(final p in groups){
  if(kw<=p[0]){
   final additional=((kw-p[1])/10).ceil()-1;
   return p[2].toDouble()+additional*p[3];
  }
 }
 return null;
}
