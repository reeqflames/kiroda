import 'dart:math' as math;

/// Indicative legacy Malaysian Motor Tariff baseline for private cars.
/// Comprehensive cover has been detariffed since 1 July 2017; this is not
/// a current insurer quotation and excludes insurer-specific risk loadings.
/// Table independently published by Malaysian Form 5 Mathematics textbooks,
/// iMoney and PlateX. Service tax 8%; stamp duty RM10.
enum InsuranceCover { comprehensive, thirdParty }
enum InsuranceRegion { peninsular, eastMalaysia }

class MotorTariffRow {
 const MotorTariffRow(this.maxCc, this.westComprehensive, this.westThirdParty,
     this.eastComprehensive, this.eastThirdParty);
 final int maxCc;
 final double westComprehensive, westThirdParty;
 final double eastComprehensive, eastThirdParty;
}

const motorTariffRows = <MotorTariffRow>[
 MotorTariffRow(1400,273.80,120.60,196.20,67.50),
 MotorTariffRow(1650,305.50,135.00,220.00,75.60),
 MotorTariffRow(2200,339.10,151.20,243.90,85.20),
 MotorTariffRow(3050,372.60,167.40,266.50,93.60),
 MotorTariffRow(4100,404.30,181.80,290.40,101.70),
 MotorTariffRow(4250,436.00,196.20,313.00,110.10),
 MotorTariffRow(4400,469.60,212.40,336.90,118.20),
 MotorTariffRow(20000,501.30,226.80,359.50,126.60),
];

double _cents(double value) => (value * 100).roundToDouble() / 100;

class MotorInsuranceEstimate {
 const MotorInsuranceEstimate({
  required this.baseRate,
  required this.valueLoading,
  required this.basicPremium,
  required this.ncdSaving,
  required this.afterNcd,
  required this.windscreenPremium,
  required this.specialPerilsPremium,
  required this.serviceTax,
  required this.stampDuty,
  required this.total,
 });
 final double baseRate, valueLoading, basicPremium, ncdSaving, afterNcd,
    windscreenPremium, specialPerilsPremium, serviceTax, stampDuty, total;
}

/// The sumInsured is ignored for THIRD PARTY; its tariff is by engine cc only.
/// For comprehensive cover, the rate covers first RM1,000; every remaining
/// RM1,000 or PART of RM1,000 is charged the zone's additional block rate.
/// Glass cover uses 15% of insured glass value as an OPTIONAL illustration.
/// Optional Special Perils premium is % of *vehicle Sum Insured* (before SST).
/// Different insurers charge different rates and may offer reduced scopes;
/// this calculator does not claim all policies include identical perils.
/// NCD does not reduce either separately purchased add-on.
MotorInsuranceEstimate? estimateMotorInsurance({
 required double? sumInsured,
 required int? engineCc,
 required double? ncdPercent,
 required InsuranceCover cover,
 required InsuranceRegion region,
 double windscreenSum = 0,
 double specialPerilsRatePercent = 0,
}) {
 if (engineCc == null || engineCc <= 0 || engineCc > 20000 ||
     ncdPercent == null || !ncdPercent.isFinite ||
     ncdPercent < 0 || ncdPercent > 55 ||
     !windscreenSum.isFinite || windscreenSum < 0 || windscreenSum > 1000000 ||
     !specialPerilsRatePercent.isFinite || specialPerilsRatePercent < 0 ||
     specialPerilsRatePercent > 2) {
  return null;
 }
 if (cover == InsuranceCover.comprehensive &&
    (sumInsured == null || !sumInsured.isFinite ||
     sumInsured < 1000 || sumInsured > 10000000)) return null;
 if (cover == InsuranceCover.thirdParty &&
    (windscreenSum > 0 || specialPerilsRatePercent > 0)) return null;

 final row = motorTariffRows.firstWhere((t) => engineCc <= t.maxCc);
 final west = region == InsuranceRegion.peninsular;
 final baseRate = switch ((cover,west)) {
  (InsuranceCover.comprehensive,true) => row.westComprehensive,
  (InsuranceCover.comprehensive,false) => row.eastComprehensive,
  (InsuranceCover.thirdParty,true) => row.westThirdParty,
  (InsuranceCover.thirdParty,false) => row.eastThirdParty,
 };
 final blocks = cover == InsuranceCover.comprehensive
   ? math.max(0, ((sumInsured! - 1000) / 1000).ceil()) : 0;
 final loading = blocks * (west ? 26.0 : 20.30);
 final basic = _cents(baseRate + loading);

 // Compute payable first so the displayed NCD saving always reconciles exactly
 // with basic premium (rather than adding two separately rounded half-cents).
 final discounted = _cents(basic * (1 - ncdPercent / 100));
 final discount = _cents(basic - discounted);
 final glass = _cents(windscreenSum * 0.15);
 final peril = specialPerilsRatePercent == 0 ? 0.0 :
     _cents(sumInsured! * specialPerilsRatePercent / 100);
 final tax = _cents((discounted + glass + peril) * 0.08);
 final total = _cents(discounted + glass + peril + tax + 10);
 return MotorInsuranceEstimate(
  baseRate: _cents(baseRate),
  valueLoading: _cents(loading),
  basicPremium: basic,
  ncdSaving: discount,
  afterNcd: discounted,
  windscreenPremium: glass,
  specialPerilsPremium: peril,
  serviceTax: tax,
  stampDuty: 10,
  total: total,
 );
}
