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

## 2026-09-22

- Verified existing order/reservation provenance propagation and independent-write
  guards, including the four regression methods absent from earlier progress notes.
  The starting suite contained 96 ABAP Unit methods. Updated README with the contract.
- Added optional inclusive `from_date` to order source, policy and simulation APIs.
  Kept the existing defaults and calls compatible. Reversed/invalid windows fail
  before reads; injected sources cannot return earlier demand. Five new tests cover
  boundaries, validation, empty results and preservation of stock when earlier RESB
  components are excluded. All 101 methods passed at this checkpoint.
- Fixed dependency pinning when npm `ignore-scripts=true` disables prelint/preunit.
  Both main scripts now explicitly verify/prepare open-abap-core. Fetched the locked
  revision and confirmed lint/transpile use the local cache; recorded in ANOMALIES.md.
- Added `zcl_stock_alloc_comparison` for per-request scenario gains/losses, before/after
  shortages and deterministic output. It rejects different request sets or changed
  demand/origin, preserves units and handles decimal and maximum-quantity deltas.
  Seven tests include a real priority-change allocation scenario and malformed inputs.
- `npm.cmd test` passes 108 ABAP Unit methods, the demo and stock SQL-read checks with
  zero abaplint issues against the locked dependency; npm lifecycle hooks remain disabled.
- Added `zcl_stock_order_summary` with per-order component counts, quantity-derived
  status, earliest shortage date and original shortage allocations for drill-down.
  It rejects missing order origins and invalid results, keeps unlike units separate,
  and produces stable ordering. Seven pure tests and one RESB/service integration
  fixture brought the passing suite to 116 methods.
- Reproduced acceptance of demand from an unselected order returned by an injected
  source. Order simulation now checks origins against a hashed order selection and
  requires each request to retain the selected priority/partial policy before any
  stock read. Four tests cover unselected/missing origins, policy overrides and
  valid multi-order prioritization. Documented the stricter custom-source contract.
- Latest `npm.cmd test`: 120 ABAP Unit methods, demo and SQL-count checks passed;
  zero lint issues. The new reporting and source contract are documented in README.
- Verified SAP's GM code 03 reservation-reference contract and added
  `zif_stock_reserved_issue` / `zcl_stock_reserved_issue_sap`. Maps full reservation
  keys, quantity, unit and storage; leaves SAP-derived material/plant/movement/account
  fields initial. Requires complete, unique reservation references even for zero rows.
  Default simulation, caller-owned LUW and no forced final issue mirror existing APIs.
- Extracted the shared goods-issue BAPI call, error-message preservation and document
  key validation into an abstract protected base. Existing cost-center tests still
  pass. Extended standard item stubs under stubs only; abapGit imports remain src-only.
- Added 13 reserved-issue tests covering decimals, references, duplicate keys, blank
  record types/manual reservations, simulation, warnings/errors, document keys and
  the failing standard stub. A RESB-to-service-to-adapter fixture checks planned
  withdrawals of 8 and 2 without forcing completion of the remaining shortage.
- Confirmed fresh transpiler 2.13.90 output correctly declares `$return` in both BAPI
  function groups. Removed the obsolete generated-JavaScript patch and reran tests
  directly against unmodified transpiler output. Recorded the resolution in ANOMALIES.md.
- Latest `npm.cmd test`: 133 ABAP Unit methods, demo and SQL-count checks pass with
  zero lint issues. Real SAP posting, locks and reservation revalidation remain
  integration responsibilities documented alongside the new usage example.
- Added injectable `zif_stock_reservation_source` with a keyed RESB implementation
  for fresh outstanding issue quantities and reservation identity. Includes manual
  reservations, excludes closed/non-issue/special-stock rows, deduplicates read keys
  and rejects incomplete references and negative open-item quantities.
- Added `zcl_stock_reserved_checked`, a reserved-writer wrapper checking the exact
  positive-allocation key set, identity and sufficient outstanding demand before
  invoking a writer. It validates input before reads, checks all rows before writing,
  preserves parameters/results/errors and rereads on every call. Locking and fresh
  stock checks remain caller responsibilities. Shared reservation-key validation now
  serves both the low-level writer and this wrapper.
- Reproduced a runtime failure on nested hashed-table keys in transpiler/runtime
  2.13.90. Replaced the index with flat reservation keys and an embedded request;
  documented the workaround in ANOMALIES.md without modifying generated JavaScript.
- Added ten wrapper tests and six SAP-reader fixture tests, including fractional
  manual demand, stale identity, all-row validation, exact quantity boundaries and
  source anomalies. Extended the existing order-to-BAPI mapping fixture through the
  new checker and real local RESB reader. `npm.cmd test` passes all 149 methods,
  demo and SQL-count checks with zero lint issues.

## Next iterations

- Add optional stock revalidation for proposed issue quantities, preserving safety
  stock/commitment policies and checking cumulative consumption at each location.
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
