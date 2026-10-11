
import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/sa_tools.dart';
void main(){
 test('insurance: NCD applies to base premium, not full amount',(){
  final r=estimateInsurance(base:3000,extra:200,sstPercent:8,stamp:10,ncd:55);
  expect(r,isNotNull);
  expect(r!.ncdDeduction,1650);
  expect(r.baseAfterNcd,1350);
  expect(r.sst,124);
  expect(r.total,1684);
 });
 test('windscreen add-on uses 15 percent of coverage amount',(){
  final cover=3000.0;
  final additional=estimateWindscreenPremium(cover);
  expect(additional,450);
  final r=estimateInsurance(base:3000,extra:additional,
      sstPercent:8,stamp:10,ncd:55);
  expect(r,isNotNull);
  expect(r!.ncdDeduction,1650);
  expect(r.sst,144);
  expect(r.total,1954);
 });
 test('windscreen not selected: optional zero-cost extra is accepted',(){
  final r=estimateInsurance(base:3000,extra:0,
      sstPercent:8,stamp:10,ncd:55);
  expect(r!.total,1468);
 });
 test('all input is required for insurance quote',(){
  expect(estimateInsurance(base:null,extra:0,sstPercent:8,stamp:10,ncd:0),null);
 });
 test('Peninsular saloon standard rates and progressive tiers',(){
  expect(peninsularRoadTax(998,nonSaloon:false),20);
  expect(peninsularRoadTax(1498,nonSaloon:false),90);
  expect(peninsularRoadTax(1798,nonSaloon:false),closeTo(279.20,.001));
  expect(peninsularRoadTax(1996,nonSaloon:false),378);
 });
 test('Peninsular non-saloon standard rates',(){
  expect(peninsularRoadTax(1498,nonSaloon:true),120);
  expect(peninsularRoadTax(1800,nonSaloon:true),360);
  expect(peninsularRoadTax(2000,nonSaloon:true),440);
 });
 test('reject invalid engine cc',(){
  expect(peninsularRoadTax(0,nonSaloon:true),null);
 });
}
