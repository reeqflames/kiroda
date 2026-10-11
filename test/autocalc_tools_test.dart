import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/sa_tools.dart';
void main(){
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
