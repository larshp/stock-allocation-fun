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

## 2026-09-06

- Added executable report ZSTOCK_ALLOC_DEMO and a transpiled output smoke check;
  fixed sample demand demonstrates the pure engine without database access.
- Added six portable service tests for unbound sources, read avoidance, error
  propagation, duplicate stock rejection and fresh snapshots on repeated calls.
- Added six reservation tests for abort/exit messages, duplicate allocations,
  invalid dates, empty writes, invalid test mode and preservation of SAP warnings.
- `npm.cmd test` passed 58 ABAP Unit methods plus the demo smoke check with zero
  abaplint issues. Documented report transpiler and PowerShell execution findings.
- Added optional request min_allocation, checked after lot rounding. Rejected
  small allocations leave stock for later demand; invalid minimum bounds fail validation.
- Minimum-quantity suite passed: 63 ABAP Unit methods and demo smoke, zero lint issues.
- Added structured allocation reason codes and per-request availability before/after
  allocation, with policy-precedence tests. 65 ABAP Unit methods and demo smoke pass.
- Added injectable order simulation service, shared selection validation and horizon
  checks. Empty work skips reads; source errors propagate. SAP fixture integration
  now exercises the service. 72 ABAP Unit methods plus demo smoke pass, zero lint issues.
- Fixed a reproduced fractional reservation validation failure in the transpiled
  runtime; the 0.300/0.100/0.200 regression passes (73 methods).
- Added grouped allocation summaries with counts, earliest shortage date, unit/key
  isolation, deterministic ordering and quantity overflow checks. Shared allocation
  result validation now serves summaries and reservations. All 79 unit methods and
  demo smoke pass with zero lint issues, including maximum-quantity boundaries.
- Added cost-center goods-issue BAPI adapter (GM code 03, movement 201), default
  simulation, complete material-document key validation and caller-owned LUW.
  Added separate SAP standard BAPI2017 stubs that always fail locally. Eight new
  tests cover field mapping, decimal quantities, test mode, SAP errors/warnings,
  invalid inputs, incomplete document keys and the standard stub. All 87 methods
  plus the demo smoke pass; zero lint issues. SAP documentation linked in README.
- Stock reads now reuse MARA units across sorted locations within each call. 88
  ABAP Unit methods pass. Added SQL-read-count checks proving three location reads
  use only two material reads and that a second call sees changed base units.
- Demo execution now imports only the pure runtime/classes and needs no database
  fixtures. Its output smoke check still passes.
- Added inclusive from_date/through_date to general simulations. All input demand
  is validated before filtering; out-of-window demand does not consume stock or
  trigger reads. 92 ABAP Unit methods, demo and SQL-count checks pass; zero lint issues.

## Next iterations

- Preserve SAP order/reservation provenance and reject accidental independent
  cost-center writes for demand that already references a reservation.
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
