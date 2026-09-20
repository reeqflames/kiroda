# KIRODA — Project State

Last updated: 2026-09-21
Status: DEVELOPMENT STARTED
Repository: reeqflames/kiroda

## Latest approved state
KIRODA is the working brand for an Android-first Malaysia car financial decision app. It starts as a fast car-loan decision tool but is architected to expand into affordability, settlement, insurance, road tax and ownership cost.

## Locked V1
- Flutter / Android first
- BM default + English
- Offline calculations; no login or sensitive-document collection
- Manual vehicle price first; vehicle database post-V1
- Financing: LEGACY_FLAT, REDUCING_FIXED, REDUCING_VARIABLE
- Deposit + tenure; 5/7/9 year comparison
- Reverse calculator: monthly budget -> estimated maximum principal/car price
- Rate Translator: distinguish flat rate from EIR
- Scenario Lab A/B/C and comparison
- Share result as image/text for WhatsApp
- No aggressive ads/affiliate in V1

## Calculation policy
High precision internally; round for display. Legacy flat interest = principal × annual flat rate × years. Reducing balance uses standard amortisation. Never infer reducing-balance solely from financing date. Settlement is post-V1 and must not claim to reproduce bank goodwill discounts.

## UX targets
Result <10s; understand tenure/deposit consequence <20s; save/share <30s. Simple inputs first, advanced financing details second.

## Data/source policy
Future regulatory, road-tax, vehicle-price and financing rules require source + effective date + last verified date.

## Development next
1. Bootstrap Flutter project.
2. Pure Dart calculation domain + tests.
3. Calculator UI.
4. Comparison/reverse/Rate Translator.
5. Scenario Lab/local persistence.
6. Share card.
7. QA + Android release pipeline.

## Change log
- 2026-09-21: Repository verified; canonical project-state file created; development baseline locked.
