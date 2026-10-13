import 'finance.dart';

class BankOffer {
 const BankOffer({required this.name,required this.annualRate,
  required this.rateMode});
 final String name;final double annualRate;final LoanMode rateMode;
}

class ComparedOffer {
 const ComparedOffer(this.offer,this.plan);
 final BankOffer offer; final LoanPlan plan;
 double get estimatedMonthly=>plan.monthlyRounded;
 double get totalRepayment=>plan.totalRepayment;
 double get totalInterest=>plan.totalInterest;
}

class BankComparison {
 const BankComparison(this.results);
 final List<ComparedOffer> results;
 ComparedOffer get cheapest => results.first;
 double get maximumTotalSaving => results.last.totalRepayment-results.first.totalRepayment;
}

BankComparison compareBanks({
 required double principal,
 required int years,
 required List<BankOffer> offers,
}) {
 if(offers.length<2||offers.length>3)throw ArgumentError('Compare 2 or 3 banks.');
 final result=offers.map((offer){
  if(offer.name.trim().isEmpty)throw ArgumentError('Enter a name for each quote.');
  return ComparedOffer(offer,calculateLoan(amount:principal,
   ratePercent:offer.annualRate,years:years,mode:offer.rateMode));
 }).toList();
 result.sort((a,b)=>a.plan.totalRepayment.compareTo(b.plan.totalRepayment));
 return BankComparison(List.unmodifiable(result));
}
