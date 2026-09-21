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

## Current build status
- Flutter CI run #15: analyze PASS, tests PASS, Android debug APK build PASS.
- Debug APK artifact generated successfully in GitHub Actions.
- Scenario Lab now stores up to 3 scenarios locally on-device.
- Native share sheet result sharing implemented.
- Rate Translator education UI implemented.

## Next
1. Validate latest Scenario Lab/share dependency CI run.
2. Improve Scenario Lab comparison/edit/delete UX.
3. Add BM/English localization and accessibility QA.
4. Add share-image card (text sharing already works).
5. Prepare signed Play Store release workflow once signing credentials are available.

## Change log
- 2026-09-21: Flutter CI #15 fully green and produced first working debug APK artifact.
- 2026-09-21: Added offline Scenario Lab (max 3), native result sharing, and share-text test.
- 2026-09-21: Tenure 12-108 months, quick comparison, reverse UI, Rate Translator/Scenario domain modules and Flutter CI workflow committed.
- 2026-09-21: Core calculation engine, reverse calculation, unit tests and first calculator UI committed.
- 2026-09-21: Repository verified; canonical project-state file created; development baseline locked.
