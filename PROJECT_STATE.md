# KIRODA — Project State

Last updated: 2026-09-21
Status: CORE IMPLEMENTATION IN PROGRESS
Repository: reeqflames/kiroda

## Latest approved state
KIRODA is the working brand for an Android-first Malaysia car financial decision app, architected to expand from loan decisions into affordability, settlement, insurance, road tax and ownership cost.

## Locked V1
Flutter/Android first; BM default + English; offline calculations; no login/sensitive documents; manual vehicle price first. Financing methods: LEGACY_FLAT, REDUCING_FIXED, REDUCING_VARIABLE. Deposit/tenure from 1-9 years in 6-month increments (12-108 months), 5/7/9 quick comparison, reverse calculator, Rate Translator, Scenario Lab A/B/C, and WhatsApp-friendly sharing. No aggressive ads/affiliate in V1.

## Implemented
- Flutter package manifest + lint config
- Main tenure selector: 12-108 months in 6-month increments
- 5/7/9 quick comparison UI
- Reverse monthly-budget UI
- Rate Translator domain module + test
- Scenario Lab comparison domain module + test
- GitHub Actions Flutter analyze/test workflow
- Pure Dart loan calculation domain
- Legacy flat-rate calculation
- Reducing-balance fixed/EIR calculation
- Variable method represented for scenario calculations
- Reverse monthly-budget -> principal calculation
- Initial automated tests, including RM90k @ 3% flat / 9y reference case
- First BM calculator UI with price, deposit, rate, method, 1-9 year tenure and live result card

## Important validation status
Source code has been committed, but Flutter SDK execution is not available in the current chat runtime, so tests/build are not yet claimed as executed. Android platform scaffolding and CI are still required before an APK can be produced.

## Calculation policy
High precision internally; round for display. Legacy flat interest = principal × annual flat rate × years. Reducing balance uses standard amortisation. Never infer reducing-balance solely from financing date.

## Next
1. Complete Android platform scaffold so CI can build the app.
2. Add Rate Translator UI/education flow.
3. Scenario Lab local persistence + UI.
4. Share card.
5. BM/English localization and accessibility QA.
6. Build release-ready Android artifact.

## Change log
- 2026-09-21: Tenure 12-108 months, quick comparison, reverse UI, Rate Translator/Scenario domain modules and Flutter CI workflow committed.
- 2026-09-21: Core calculation engine, reverse calculation, unit tests and first calculator UI committed.
- 2026-09-21: Repository verified; canonical project-state file created; development baseline locked.
