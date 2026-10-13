# AutoCalc MY v0.8 — Pre-build Audit (2026-10-14)

Scope: review the real `autocalc-my-v0-7` source and regression tests, and compare with the available screenshots of the original Car Loan Calculator (Malaysia). The original reference APK bytes have not been provided in this conversation, so a complete binary feature audit cannot be claimed.

## Existing and verified by reading source
- Flat hire-purchase calculation, annual effective rate reducing-balance plan, simulated repayment table, RM10 ceiling, adjusted final installment, and indicative reducing-balance settlement.
- Insurance market value / coverage / engine-category dropdown / region / NCD / optional windscreen and old Motor Tariff estimate.
- Private Peninsular petrol/diesel road-tax by actual engine cc, saloon/non-saloon.
- PNG quote sharing for basic loan, offline saved loan calculations, in-app registration-number cards plus verified external-source link.
- Native Android Flutter, no advertising SDK or login dependency.

## Gaps to resolve BEFORE claiming v0.8 feature completeness
1. Quick calculator tenure dropdown currently stops at **9**, although engine accepts **1–12**.
2. Insurance UI is too tall; large vertically stacked cards/fields push the premium below the fold. Need consistent two-column field geometry, labels outside outlines, selected state persistence, and optional breakdown.
3. OTR/down-payment calculator is wholly absent. Define insurance and road-tax inclusion in OTR separately from the **financeable car price**; booking and trade-in equity reduce cash-to-pay, not car price unless explicitly set.
4. Bank comparison is wholly absent. Calculate the same loan across multiple rates; distinguish **flat** vs **effective annual EIR**, and compare monthly, total interest, total repayment, and difference.
5. Existing PNG quote lacks the vehicle-price/rebate/deposit/OTR breakdown; OTR needs a dedicated customer-friendly share image and offline save/read/delete.
6. Saved history only contains simple loan quotes, not OTR. Preserve backwards compatibility for saved entries.
7. The Latest Plates feed presently points to an Apps Script endpoint which returns AutoQuote variants/settings, not a `plates` response. It **cannot currently be called LIVE**. Do not modify Ema production/staging backend or scrape third-party data without permission. Maintain an honest offline/unavailable state and official JPJ verification, with an optional independently authorized feed in future.
8. Existing road tax is private Peninsular ICE-only. Do not present it as complete JPJ coverage for East Malaysia, EVs, commercial use, or special registrations.
9. The old Motor Tariff is **not** a live insurer quote, and 15% glass cover is indicative. Clarify this in insurance and shared quotation UI.
10. Legacy flat amortization is a **simulated financing-cost allocation**, not lender principal schedule / early settlement. Keep disclaimer. EIR rate is effective annual and converted to an equivalent monthly rate. Do not imply all bank settlement quotes follow this exact method.

## v0.8 implementation plan
- Central compact inputs with equal heights, 2-column grid and fixed spacing, plus unit/widget tests on small screens.
- OTR+deposit calculator with Full, 90%, custom finance modes; live fields and inclusive cash-due breakdown.
- Bank comparison 2–3 scenarios with clear apples-to-apples rate-mode labeling.
- OTR quotation PNG share/preview, save/load/delete locally.
- Keep Flat/EIR, schedule, early settlement, insurance, road tax, plates and existing loan history; ensure navigation reaches each without adding excess bottom tabs.
- Run static analysis and unit/widget tests before APK compilation.
- Resolve all test/build failures and make no production backend changes.

## Release caveats
- Plate feed pending authorized functional endpoint.
- Actual bank contract/insurance premium can differ.
- The initial release may be limited to Peninsular ICE road-tax; clearly identify this instead of guessing.
