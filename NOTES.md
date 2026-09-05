# Progress

## 2026-09-05

- Repository started with PLAN.md only; no existing implementation or tests.
- Implemented deterministic priority/date/ID allocation, partial and complete-only
  policies, safety stock, per-location isolation and input validation.
- Added injectable stock source and simulation service, MARD/MARA reader and SQLite
  fixtures. Reads ignore deleted locations and clamp negative physical stock to zero.
- Added cost-center reservation adapter (movement 201), default BAPI simulation,
  ATP-check request, error-message preservation and no internal commit/rollback.
- Added Gregorian calendar validation and hashed stock/request lookup tables.
- Added RESB order-component demand ingestion with horizon and withdrawal handling;
  excludes deleted, finally issued, receipt and special-stock components.
- Added committed quantities and an adjustable stock-source wrapper, rejecting
  incompatible units, duplicate policies and overwriting existing adjustments.
- Added CI and pinned/cached open-abap-core for reproducible lint/transpiler runs.
- Added optional lot sizes, rounding partial allocations down to whole lots and
  rejecting demands that are not whole lots. Integer thousandths avoid fractional
  modulo differences between native ABAP and JavaScript.
- Goal was observed paused after the passing lot-size run; recording this checkpoint.

## Next iterations

- Add a read-only executable example using the pure allocation engine.
- Broaden SAP adapter failure-path coverage (abort messages, duplicate allocations,
  invalid dates and empty writes) and portable service test-double coverage.
- Validate real SAP integration contracts, authorizations and client handling when
  a development system becomes available; do not treat local stubs as SAP proof.
- Revisit bulk stock reads when the transpiler supports the joined FAE expression.
- All custom ABAP objects live in src; SAP standard test substitutes live in stubs.
- SAP import is restricted to src through .abapgit.xml.

## Validation

- Initial core: 12 transpiled ABAP Unit tests passed.
- Stock source and simulation: 19 tests passed.
- Reservation adapter plus dates/scalability: 30 tests passed.
- Order component integration: 36 tests passed.
- Commitments/adjustments: 42 tests passed; zero abaplint issues.
- Locked dependency workflow passed the same 42 tests.
- Lot-size/decimal arithmetic suite: `npm test` passed all 46 ABAP Unit methods,
  zero abaplint issues; tests ran successfully using the local pinned dependency cache.
