import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/insurance_tariff.dart';

void main(){
 const west = InsuranceRegion.peninsular;
 const east = InsuranceRegion.eastMalaysia;
 const comp = InsuranceCover.comprehensive;
 const third = InsuranceCover.thirdParty;

 test('iMoney benchmark RM50,000 1498cc 55% NCD ≈ RM777.64', (){
  final r=estimateMotorInsurance(
    sumInsured:50000,engineCc:1498,ncdPercent:55,cover:comp,region:west);
  expect(r,isNotNull);
  expect(r!.baseRate,305.50);
  expect(r.valueLoading,1274.00);
  expect(r.basicPremium,1579.50);
  expect(r.afterNcd,710.78);
  expect(r.ncdSaving,868.72);
  expect(r.serviceTax,56.86);
  expect(r.total,777.64);
  expect(r.basicPremium,r.afterNcd+r.ncdSaving);
 });

 test('windscreen 3k adds 450 plus SST, does not get NCD',(){
  final r=estimateMotorInsurance(sumInsured:50000,engineCc:1498,
   ncdPercent:55,cover:comp,region:west,windscreenSum:3000)!;
  expect(r.windscreenPremium,450);
  expect(r.ncdSaving,868.72);
  expect(r.serviceTax,92.86);
  expect(r.total,1263.64);
 });

 test('third party depends on cc, not sum insured',(){
  final a=estimateMotorInsurance(sumInsured:null,engineCc:1498,ncdPercent:0,
     cover:third,region:west)!;
  final b=estimateMotorInsurance(sumInsured:250000,engineCc:1498,ncdPercent:0,
     cover:third,region:west)!;
  expect(a.total,b.total);
  expect(a.basicPremium,135);
  expect(a.total,155.80);
  expect(a.valueLoading,0);
  expect(estimateMotorInsurance(sumInsured:null,engineCc:1498,ncdPercent:0,
     cover:third,region:west,windscreenSum:1000),null);
 });

 test('Sabah Sarawak uses RM20.30 per 1k extra',(){
  final r=estimateMotorInsurance(sumInsured:50000,engineCc:1498,
     ncdPercent:0,cover:comp,region:east)!;
  expect(r.baseRate,220);
  expect(r.valueLoading,994.70);
  expect(r.basicPremium,1214.70);
 });

 test('any part of additional 1000 is rounded up as a full block',(){
  final r=estimateMotorInsurance(sumInsured:50000.01,engineCc:1498,
    ncdPercent:0,cover:comp,region:west)!;
  expect(r.valueLoading,1300);
  expect(r.basicPremium,1605.50);
 });

 test('engine capacity bands follow the published motor tariff',(){
  final lo=estimateMotorInsurance(sumInsured:1000,engineCc:1400,
     ncdPercent:0,cover:comp,region:west)!;
  final hi=estimateMotorInsurance(sumInsured:1000,engineCc:1401,
     ncdPercent:0,cover:comp,region:west)!;
  expect(lo.basicPremium,273.80);
  expect(hi.basicPremium,305.50);
 });

 test('Special Perils 0.2 percent uses vehicle sum insured, not premium',(){
  final r=estimateMotorInsurance(sumInsured:50000,engineCc:1498,
   ncdPercent:55,cover:comp,region:west,specialPerilsRatePercent:0.2)!;
  expect(r.basicPremium,1579.50);
  expect(r.ncdSaving,868.72);
  expect(r.specialPerilsPremium,100);
  expect(r.serviceTax,64.86);
  expect(r.total,885.64);
 });

 test('both independently selected add-ons reconcile including SST',(){
  final r=estimateMotorInsurance(sumInsured:50000,engineCc:1498,
   ncdPercent:55,cover:comp,region:west,windscreenSum:2000,
   specialPerilsRatePercent:0.2)!;
  expect(r.windscreenPremium,300);
  expect(r.specialPerilsPremium,100);
  expect(r.ncdSaving,868.72);
  expect(r.serviceTax,88.86);
  expect(r.total,1209.64);
 });

 test('rate may be overridden without incorrectly applying NCD to add-on',(){
  final r=estimateMotorInsurance(sumInsured:50000,engineCc:1498,
    ncdPercent:55,cover:comp,region:west,specialPerilsRatePercent:0.5)!;
  expect(r.specialPerilsPremium,250);
  expect(r.total,1047.64);
  expect(estimateMotorInsurance(sumInsured:50000,engineCc:1498,
    ncdPercent:55,cover:comp,region:west,specialPerilsRatePercent:-0.1),isNull);
  expect(estimateMotorInsurance(sumInsured:50000,engineCc:1498,
    ncdPercent:55,cover:comp,region:west,specialPerilsRatePercent:double.nan),isNull);
 });

 test('Special Perils is unavailable for Third Party only',(){
  expect(estimateMotorInsurance(sumInsured:50000,engineCc:1498,
    ncdPercent:55,cover:third,region:west,specialPerilsRatePercent:0.2),isNull);
  expect(estimateMotorInsurance(sumInsured:50000,engineCc:1498,
    ncdPercent:55,cover:third,region:west),isNotNull);
 });

 test('requires sum insured for comprehensive, but not for third party',(){
  expect(estimateMotorInsurance(sumInsured:null,engineCc:1500,ncdPercent:55,
    cover:comp,region:west),null);
  expect(estimateMotorInsurance(sumInsured:50000,engineCc:null,ncdPercent:55,
    cover:comp,region:west),null);
  expect(estimateMotorInsurance(sumInsured:50000,engineCc:1500,ncdPercent:null,
    cover:comp,region:west),null);
  expect(estimateMotorInsurance(sumInsured:null,engineCc:1500,ncdPercent:0,
    cover:third,region:west),isNotNull);
 });
}
