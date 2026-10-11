
import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/finance.dart';
void main() {
 test('flat: RM96120 2.7% 9y => rounded 1110 final 707.16', () {
  final p=calculateLoan(amount:96120,ratePercent:2.7,years:9,mode:LoanMode.flat);
  expect(p.exactMonthly,closeTo(1106.27,0.00001));
  expect(p.monthlyRounded,1110);
  expect(p.finalInstallment,closeTo(707.16,0.01));
  expect(p.totalRepayment,closeTo(119477.16,0.01));
  expect(p.rows.length,108);
 });
 test('zero rate EIR repays principal with no interest', () {
  final p=calculateLoan(amount:12000,ratePercent:0,years:1,mode:LoanMode.eir);
  expect(p.monthlyRounded,1000);
  expect(p.totalInterest,0);
  expect(p.finalInstallment,1000);
  expect(p.balanceAfter(12),0);
 });
 test('EIR payment schedule reconciles principal and total', () {
  final p=calculateLoan(amount:96120,ratePercent:5.1,years:9,mode:LoanMode.eir);
  expect(p.monthlyRounded,1110);
  expect(p.rows.first.interest,greaterThan(p.rows.last.interest));
  expect(p.rows.last.balance,0);
  expect(p.rows.fold<double>(0,(sum,row)=>sum+row.payment),closeTo(p.totalRepayment,0.06));
  expect(p.totalRepayment,closeTo(p.amount+p.totalInterest,0.06));
  expect(p.balanceAfter(12),lessThan(p.amount));
  expect(p.futureInterest(0),closeTo(p.totalInterest,0.05));
 });
 test('round UP to nearest RM10', () {
  expect(roundUpTen(1106.27),1110);
  expect(roundUpTen(1110.00),1110);
  expect(roundUpTen(1110.50),1120);
  expect(roundUpTen(987.20),990);
 });
 test('reject invalid input', () {
  expect(()=>calculateLoan(amount:-1,ratePercent:2,years:9,mode:LoanMode.flat),throwsArgumentError);
  expect(()=>calculateLoan(amount:1000,ratePercent:-2,years:9,mode:LoanMode.eir),throwsArgumentError);
 });
}