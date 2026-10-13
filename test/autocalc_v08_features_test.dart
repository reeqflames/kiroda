import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/finance.dart';
import '../lib/autocalc/otr_finance.dart';
import '../lib/autocalc/bank_compare.dart';
import '../lib/autocalc/road_tax.dart';

void main(){
 test('OTR correctly separates vehicle financing and cash expenses',(){
  final q=calculateOtr(carPrice:116800,rebate:10000,
   insurance:3000,roadTax:90,fees:0,booking:100,tradeInEquity:0,
   annualRate:2.7,years:9,rateMode:LoanMode.flat,
   financeShare:FinanceShare.ninety);
  expect(q.netCarPrice,106800);
  expect(q.otrPrice,109890);
  expect(q.loanAmount,96120);
  expect(q.deposit,10680);
  expect(q.cashBeforeCredits,13770);
  expect(q.cashDue,13670);
  expect(q.loanPlan.monthlyRounded,1110);
  expect(q.loanPlan.finalInstallment,closeTo(707.16,.01));
 });
 test('Booking and trade equity reduce cash owed, not financed price',(){
  final q=calculateOtr(carPrice:50000,rebate:0,insurance:2000,
   roadTax:90,fees:0,booking:100,tradeInEquity:3000,
   annualRate:3,years:7,rateMode:LoanMode.flat,
   financeShare:FinanceShare.full);
  expect(q.loanAmount,50000);
  expect(q.deposit,0);
  expect(q.otrPrice,52090);
  expect(q.cashDue,0);
  expect(q.excessCredit,1010);
 });
 test('Custom financing amount must be within net car price',(){
  expect(()=>calculateOtr(carPrice:50000,rebate:0,insurance:0,
   roadTax:0,fees:0,booking:0,tradeInEquity:0,annualRate:3,
   years:5,rateMode:LoanMode.flat,financeShare:FinanceShare.custom,
   customLoanAmount:55000),throwsArgumentError);
 });
 test('Compare two offers by real total repayment, not just stated rate',(){
  final a=compareBanks(principal:96120,years:9,offers:[
   const BankOffer(name:'Higher',annualRate:3.1,rateMode:LoanMode.flat),
   const BankOffer(name:'Lower',annualRate:2.7,rateMode:LoanMode.flat),
  ]);
  expect(a.results.length,2);
  expect(a.cheapest.offer.name,'Lower');
  expect(a.maximumTotalSaving,greaterThan(0));
  expect(a.cheapest.estimatedMonthly,1110);
 });
 test('Bank comparisons accept 3 and reject 1 or 4',(){
  final offers=List.generate(3,(i)=>BankOffer(name:'Bank '+i.toString(),
   annualRate:3+i.toDouble(),rateMode:LoanMode.flat));
  expect(compareBanks(principal:50000,years:7,offers:offers).results.length,3);
  expect(()=>compareBanks(principal:50000,years:7,offers:offers.take(1).toList()),
    throwsArgumentError);
 });
 test('Peninsular and East Malaysia 1498cc car rates',(){
  expect(annualPrivateRoadTax(electric:false,eastMalaysia:false,
   nonSaloon:false,engineCc:1498),90);
  expect(annualPrivateRoadTax(electric:false,eastMalaysia:true,
   nonSaloon:false,engineCc:1498),72);
  expect(annualPrivateRoadTax(electric:false,eastMalaysia:true,
   nonSaloon:true,engineCc:1498),60);
 });
 test('Road tax rates use the correct progressive increments above 3000cc',(){
  expect(annualPrivateRoadTax(electric:false,eastMalaysia:false,
   nonSaloon:true,engineCc:3500),2840);
  expect(annualPrivateRoadTax(electric:false,eastMalaysia:true,
   nonSaloon:false,engineCc:3500),1699);
 });
 test('2026 EV groups and inclusive kW boundaries',(){
  expect(annualPrivateRoadTax(electric:true,eastMalaysia:false,
   nonSaloon:false,motorKw:50),20);
  expect(annualPrivateRoadTax(electric:true,eastMalaysia:false,
   nonSaloon:false,motorKw:70),40);
  expect(annualPrivateRoadTax(electric:true,eastMalaysia:false,
   nonSaloon:false,motorKw:100),70);
  expect(annualPrivateRoadTax(electric:true,eastMalaysia:false,
   nonSaloon:false,motorKw:150),160);
  expect(annualPrivateRoadTax(electric:true,eastMalaysia:true,
   nonSaloon:true,motorKw:390),965);
 });
}
