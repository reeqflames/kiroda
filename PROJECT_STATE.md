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

## Locked UI principles
- Fresh, modern, clean, aesthetic and consumer-app quality.
- Typography and number hierarchy are first-class design elements.
- Ultimate user-friendly: core calculation stays obvious; advanced tools use progressive disclosure.
- Design tokens/components centralized for fast small tweaks and low maintenance.
- Calculation/business logic stays separate from presentation.

## Current build status
- Flutter CI run #15: analyze PASS, tests PASS, Android debug APK build PASS.
- Debug APK artifact generated successfully in GitHub Actions.
- Scenario Lab now stores up to 3 scenarios locally on-device.
- Native share sheet result sharing implemented.
- Rate Translator education UI implemented.

## Test-candidate work
- CI #23 passed after progressive-disclosure UX cleanup.
- CI now builds debug APK plus smaller ABI-specific release APKs for easier local phone testing.
- Added calculator UI smoke tests for the core journey and advanced-tool disclosure.
- Continued hierarchy/spacing polish using the centralized design system.

## Next
1. Require latest UI/test/release-APK CI to be green.
2. Hand off the arm64 test APK for real-device UX testing.
3. Fix findings from real-device testing.
4. Add BM/English localization and accessibility QA.
5. Add share-image card after the core local-test UX is approved.
6. Prepare Play Store signing/AAB only after local candidate approval.

## Change log
- 2026-09-21: Flutter CI #15 fully green and produced first working debug APK artifact.
- 2026-09-21: Added offline Scenario Lab (max 3), native result sharing, and share-text test.
- 2026-09-21: Tenure 12-108 months, quick comparison, reverse UI, Rate Translator/Scenario domain modules and Flutter CI workflow committed.
- 2026-09-21: Core calculation engine, reverse calculation, unit tests and first calculator UI committed.
- 2026-09-21: Repository verified; canonical project-state file created; development baseline locked.
