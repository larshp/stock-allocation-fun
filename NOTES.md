# Development notes

## 2026-10-17

- Checked packed totals in non-dated cross-plant allocation: source-location sums, same-location stock plus projected receipts, qualifying receipt totals, and per-plant availability now use the checked quantity helper. Added two maximum-value regressions and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,989 ABAP Unit methods.

- Preserved individual open RESB rows in bulk sales-order reservation reads instead of summing same-date rows into packed `RESB-BDMNG`. Consumers reconcile separate rows without an overflowing intermediate. Added a two-maximum-reservation regression and updated the grouped-row contract test. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,987 ABAP Unit methods.

- Hardened confirmed PO receipt totals in single-request and bulk dated allocation. Stock and each qualifying receipt now combine through the checked `decfloat34` helper before MARD-LABST conversion. Added two maximum-value regressions and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,986 ABAP Unit methods.

- Checked dated cross-plant availability totals and per-plant confirmed receipt additions before narrowing to MARD-LABST. Overflow now raises `zcx_invalid_stock_request`; added maximum-value regressions and a PLAN guard. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,984 ABAP Unit methods.

- Hardened sales-order ATP previews against daily and cumulative demand overflow. Both single-order and multi-order previews now add grouped quantities in `decfloat34` and reject totals outside MARD-LABST before calling SAP ATP. Added two maximum-value regressions and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,982 ABAP Unit methods.

- Hardened WBS reservation coverage grouping: project stock, reservations,
  and available stock now aggregate in `decfloat34` before checked conversion
  to `MSPR-PRLAB`. Coverage and available-stock UOM reads now reject overflow
  and nonzero quantities rounded to zero. Added maximum-value and rounding
  regressions plus PLAN guards. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,980 ABAP Unit
  methods.
- Replaced packed arithmetic in production-order ATP release, cost-center
  reservation validation, all plant/two-step goods movement allocation checks,
  and sales-order FEFO reservation validation with `decfloat34` comparisons.
  Added maximum-quantity regressions and PLAN guards; invalid totals are
  rejected before release, reservation, or movement API calls. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,975 ABAP Unit methods.
- Extended checked aggregation to production-component ATP daily and cumulative requests and monthly shortage groups. Added regressions for same-date and cross-date ATP overflow and monthly shortage overflow.
- Hardened production-order ATP summaries: grouped component and order quantities now use checked high-precision totals, rejecting results outside MARD-LABST instead of overflowing. Added regressions for component and order-level summaries plus a PLAN guard.
- Added checked high-precision accumulation to ATP allocation groups, daily demand totals, and cumulative requests. Totals beyond MARD-LABST now raise the stock-request exception before an SAP ATP call; added an overflow regression and PLAN guard.
- Preserved individual open RESB rows in bulk location and batch status reads
  so their high-precision calculators can net large reservation sets without
  an overflowing `RESB-BDMNG` intermediate. Added SQLite regressions for two
  maximum reservations at both scopes and a PLAN guard. Full npm test passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,966 ABAP Unit methods. Target SAP SQL result behavior remains to be checked.
- Hardened scalar and bulk stock-transfer location totals. MARD rows now
  accumulate in `decfloat34`, then convert with an explicit range check;
  overflow raises `ZCX_INVALID_STOCK_REQUEST` through the repository
  interface. Added two-maximum-balance coverage and a PLAN guard. Full npm
  test passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,965 ABAP Unit methods. Target SAP conversion
  behavior remains to be checked.
- Checked repeated projected receipt additions to scoped component
  location and batch balances. Out-of-range aggregates now raise the stock
  request exception; added a two-maximum-receipt regression and a PLAN
  guard. Full npm test passed: PLAN validation, 0 abaplint issues across
  247 files, transpilation, and all 1,964 ABAP Unit methods.
- Hardened scoped component allocation sums. Batch totals, demand scope
  availability, and shared group availability now accumulate in high
  precision before location clamping and checked result conversion. Added
  a regression with two maximum batch balances under one location and a
  PLAN guard. Full npm test passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,963 ABAP Unit methods.
- Hardened sales-order stock snapshots against aggregate overflow. The
  service now sums unrestricted stock and eligible open reservations in
  high precision, then rejects totals outside the snapshot fields. Added
  stock and reservation boundary coverage plus a PLAN guard. Full npm test
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,962 ABAP Unit methods.
- Moved location reservation sums and batch negative-stock carry to
  decfloat34 so multiple large rows can be netted without intermediate
  quantity overflow. Added calculator regressions where the internal total
  exceeds SAP quantity range but the final available result is zero. Added
  PLAN guards and documented the boundary. Full npm test passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all
  1,961 ABAP Unit methods.
- Fixed plant stock-status reads to retain LGORT in the bulk projection, so
  equal balances from separate locations are not deduplicated. Stock category
  and reservation totals now accumulate in high precision with checked SAP
  quantity conversion. Scalar unrestricted availability also nets MARD and
  open RESB quantities in high precision and checks the final result. Added
  regressions for identical maximum balances, stock overflow, reservation
  overflow, and the zero clamp. Full npm test passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,959 ABAP Unit
  methods.
- Hardened plant-date availability aggregation in the stock repository.
  Storage stock, reservations, receipts, and outgoing transfers now net in
  high precision before the final MARD-LABST conversion; unrepresentable
  results raise the request exception. Added a boundary regression and updated
  the repository contract and PLAN guard. Full npm test passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,957
  ABAP Unit methods.
- Hardened quota-split PR preparation against oversized candidate proposals.
  A split that exceeds MARD-LABST now raises the request exception before
  request submission. Added public preparation coverage and a PLAN guard. Full
  npm test passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,956 ABAP Unit methods.
- Hardened projected-receipt base-unit conversion in the stock repository.
  Oversized values and nonzero amounts that round to zero now raise the stock
  request exception across PO, scheduling agreement, STO, production, PR,
  planned-order, and confirmed-PO receipts. Added public-read regression
  coverage and a PLAN guard. Full npm test passed: PLAN validation, 0 abaplint
  issues across 247 files, transpilation, and all 1,955 ABAP Unit methods.
- Hardened production-component replenishment quantity conversion. Aggregate
  and receipt quantities that exceed MARD-LABST now raise the request
  exception, including lot-multiple rounding beyond the field limit. Added
  regression coverage and a PLAN guard. Full npm test passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,954 ABAP Unit
  methods.
- Hardened purchase-order suggestion preparation for purchasing-unit overflow.
  It now raises the request exception before any BAPI call; added a public
  preparation regression and PLAN guard. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all
  1,953 ABAP Unit methods.
- Hardened stock-transfer quantity conversion for unit-aware inquiries.
  Overflow and nonzero base quantities that round to zero now raise the
  request exception; added public inquiry coverage for both boundaries and a
  PLAN guard. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,952 ABAP Unit methods.
- Hardened replenishment PR purchasing-unit conversion. Overflow and nonzero
  base quantities that round to zero now raise the request exception before
  any BAPI call; added preparation regressions and a PLAN guard. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,951 ABAP Unit methods.
- Hardened sales-order allocation result conversion. Overflowing sales-unit
  quantities and nonzero base quantities that round to zero now raise the
  stock-request exception. Added public preview regressions for both cases and
  PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,950 ABAP Unit methods.
- Added a checked base-unit converter to production component stock and ATP
  previews. Overflow and nonzero reservation quantities that round to zero
  now fail before stock reads; added a public preview regression and PLAN
  guard, and documented the boundary. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all
  1,949 ABAP Unit methods.
- Routed stock-service alternative-unit demand conversions through one checked
  converter. It rejects overflow and nonzero source quantities that round to
  zero at stock precision before reading stock. Added a public allocation
  regression and PLAN guard. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,948 ABAP Unit
  methods.
- Netted negative unrestricted MCHB batch balances against positive batches
  in stable location/batch order so batch availability reconciles with the
  plant total. Added direct calculator coverage and SQLite scalar/bulk checks
  that compare batch availability with plant-level MARD status; the negative
  batch sorts after positive stock. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,945 ABAP Unit methods.
- Fixed location availability when an active reservation names a storage
  location with no MARD row. The open demand now joins the existing
  ascending-location distribution, keeping it in the plant-level net total.
  Added a calculator regression and SQLite repository coverage. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,944 ABAP Unit methods.
- Reconciled location availability with plant totals when negative location
  stock is allowed. Location deficits are carried across positive locations so
  the location results do not exceed plant-level net stock. Added a regression
  for -10 at one location and +100 at another; full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,943
  ABAP Unit methods.
- Made all shared material-unit conversion paths return an unsuccessful result
  when the converted quantity overflows `MARD-LABST` or a nonzero source rounds
  to zero. Added coverage for direct sales-unit ratios, MARM lookups, reverse
  conversion, and sales-order rejected-item mapping. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,942 ABAP Unit methods. Target-SAP quantity precision remains an anomaly to
  verify.
- Hardened `SIMULATE_SPLIT_QUOTA` duplicate-item validation: repeated rows for
  one quota item must agree on minimum/maximum lot sizes and its once-only flag.
  Added a regression with conflicting duplicate values. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,939 ABAP Unit methods.
- Fixed split-quota failure handling: when all assigned quota items are already
  at `MAXMG`, or every proposed share would reach the maximum, the preview now
  raises `zcx_invalid_stock_request` instead of returning an empty split list.
  Added regressions for both exhausted stored quantities and un-coverable
  proposed shares. Updated the quota-filter expectation for the vendor-specific
  active-quota flag. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and ABAP Unit.
- Fixed `has_active_vendor_quota` so a candidate is marked only when its own
  vendor has an in-date, external-supplier quota item with a positive quota.
  Previously, any active arrangement for the material and plant marked every
  vendor candidate as having a quota. Updated the internal match field and
  documented the result contract in README.
- Fixed reservation aggregation so an over-withdrawn RESB item cannot
  cancel another item's open demand. Added a shared
  `max(BDMNG - ENMNG, 0)` calculator and applied it before aggregation in
  plant, date, storage-location, batch, and sales-order stock reads.
  Added SQLite regressions for over-withdrawn rows across scalar and bulk
  paths, and PLAN guards for the shared clamp and aggregation readers.
  Updated README and `ANOMALIES.md` with the behavior and target-SAP
  query limitation. Full `npm test` passed: PLAN validation, 0 abaplint
  issues across 247 files, transpilation, and all 1,936 ABAP Unit methods.
- Extended the WBS project-reservation repository to use the shared
  per-item open-quantity clamp. Added over-withdrawn RESB data to its
  direct SQLite tests, checking that open reservation reads exclude it while
  active-item inquiry retains the source quantities. PLAN validation now
  guards both WBS query paths and the regression fixture. Corrected the
  project-stock documentation to reflect direct SQL coverage. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,936 ABAP Unit methods.
- Added a SQLite-backed integration test that runs
  `GET_VALID_OUTLINE_SOURCES` through the real EORD/EKKO/EKPO/MARC
  repository and service. It verifies agreement filtering, exclusion of
  a matching blocked source, and source-list flags; PLAN validation now
  guards the integration fixture.
  Updated README and `ANOMALIES.md` to distinguish local SQL coverage from
  target-SAP verification. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,937 ABAP Unit
  methods.
- Extended the source integration fixture with a deleted agreement header
  and a delivery-complete item. Repository assertions verify both flags
  survive the SQL reads, while the service still returns only the two valid
  agreements. PLAN validation now guards both fixtures and mapped fields.
- Added a deleted agreement item and a valid scheduling agreement to the same
  SQLite integration fixture. Repository assertions cover item deletion and
  K/L category mapping; the service result confirms deleted items are filtered
  while a valid L-category agreement remains eligible. PLAN validation guards
  the new cases. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,937 ABAP Unit methods.
- Both PIR and outline-source selection now reject impossible Gregorian
  delivery dates before reading source data. Added `20260230` regressions for
  each API, PLAN validation guards, and README/`ANOMALIES.md` documentation.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,938 ABAP Unit methods.
- Expanded the SQLite outline fixture to check exact-date inclusive validity
  at both EORD and EKKO, plus rejection of an EORD source-list entry and an
  agreement header that begin after the requested delivery date. PLAN guards
  the mapped boundaries and the end-to-end candidate result. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,938 ABAP Unit methods.
- Added an end-to-end SQLite test for `GET_VALID_PIR_CANDIDATES` using the real
  EINA/EINE/EORD/MARC and quota repository reads. It checks general and
  purchasing-record deletion filtering, source-list eligibility, fixed/MRP and
  automatic-sourcing flags, vendor-specific blocked-source exclusion, the
  auto-source filter, and exclusion after the source-list validity date. It
  also verifies unlisted records remain visible when the source-list flag is
  off and disappear when `iv_require_source_listed` is enabled. PLAN validation
  guards the integration fixture and assertions. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,939
  ABAP Unit methods.

## 2026-10-16

- Added `validate:plan` to check that the required abaplint rules, open-abap-core
  dependency, SAP stub inputs, and Z-object source layout stay aligned with
  `PLAN.md`. It also checks the MARD and RESB fields used by the current stock
  and reservation queries. Direct Node execution passed; the WSL 1 `npm`
  launcher is unavailable here, so lint, transpilation, and ABAP Unit were run
  through their local binaries.
- Added `PREVIEW_SCOPED_COMPONENTS` and its bulk variant for local production
  component estimates that respect `RESB-LGORT` and `RESB-CHARG`. The stock
  allocator shares location totals with batch sub-balances, allocates by
  required date and scope, and deducts competing open reservations from raw
  unrestricted balances by required date after excluding selected component
  reservation keys. Competing reservations due later do not reduce earlier
  component allocations; their balances are deducted before components due on
  those later dates. Batchless scoped demands also skip batches that expire
  before the component required date; competing reservations use only batches
  eligible through their due date.
  The default stock preview now selects this path whenever a component has an
  assigned scope and no projected receipt option is on. Regression coverage
  checks batch limits, location limits, shared stock, and competing open
  reservations, and expiry filtering for batchless demands. Future receipts are
  not included, and snapshot limitations are documented in `ANOMALIES.md`.
  Scoped rows also carry a date-group estimate whose available quantity counts
  shared stock once across the union of component scopes.
- Extended the explicit scoped component previews with caller-assigned dated
  batch receipts. Receipt events enter the shared ledger before same-date
  reservations and cannot cover earlier reservation demand. Receipts inherit a
  known batch expiry when omitted and replenish any remaining safety-stock
  buffer before becoming allocatable. Regression coverage checks receipt date
  ordering against a competing reservation, safety-stock replenishment, and
  expiry inheritance when an earlier receipt is fully withheld.
  ATP preview wrappers now accept the same input for their local estimate while
  leaving the cumulative SAP ATP requests unchanged; that mode rejects the
  SAP-derived receipt flags rather than mixing incompatible receipt balances.
  These receipts remain caller-resolved and are not checked against SAP receipt
  documents; automatic SAP-derived receipt options still use the plant-level
  estimate. abaplint reported 0 issues across 138 files, transpilation passed,
  and the 1,866-method ABAP Unit suite exited 0. Plan validation also passed.
  Target-system limits are recorded in `ANOMALIES.md`.
- Added `it_projected_location_receipts` to scoped, stock, and ATP component
  previews for caller-assigned non-batch supply. Receipts enter the assigned
  location's residual pool on their arrival date, replenish remaining protected
  safety stock, and precede same-date reservations. Coverage checks dated
  allocation, location scope, and forwarding through ATP while preserving the
  SAP request. abaplint, transpilation, and all 1,867 ABAP Unit methods passed.
  Both receipt inputs are caller-resolved; the SAP request remains plant-level.
- Added combined batch and location receipt coverage through scoped, stock, and
  ATP bulk previews across two production orders. The regression confirms that
  batch supply stays restricted to its batch and location-only supply serves a
  batchless component; ATP requests remain grouped by required date. abaplint
  reported 0 issues across 138 files, transpilation succeeded, all 1,868 ABAP
  Unit methods passed, and `validate:plan` passed.
- Extended SAP-derived PO, issued/unissued STO, and scheduling-agreement
  projections with receiving-location and schedule-line batch assignments.
  Scoped component stock and ATP previews now feed those rows into the shared
  location/batch ledger when every selected receipt has a storage location.
  This first extension covered those three source families. Added `EKPO-LGORT`
  and `EKET-CHARG` stubs and required them in plan
  validation. Regression coverage checks exact-batch and location receipt
  matching, ATP forwarding, and the plant-level fallback. abaplint reported
  0 issues across 138 files, transpilation succeeded, all 1,869 ABAP Unit
  methods passed, and `validate:plan` passed. The repository SQL still needs
  validation against the target SAP release.
- Extended scoped SAP-derived receipts to production orders, PR/STO PRs, and
  planned/fixed planned orders. Production rows carry `AFPO-LGORT` and
  `AFPO-CHARG`; requisitions carry `EBAN-LGORT`; planned orders carry
  `PLAF-LGORT`. Scoped stock and ATP previews now use all these receipt sources
  when every selected receipt has a location, with the existing plant-level
  fallback for missing locations or outgoing-STO subtraction. Added table stub
  fields and a mixed-source regression covering all receipt categories.
  abaplint reported 0 issues across 138 files, transpilation succeeded, all
  1,869 ABAP Unit methods passed, `validate:plan` passed, and the CRLF-aware diff
  check was clean. Real SAP SQL behavior still needs target-system validation.
- Added confirmation-aware PO receipts to single and bulk component stock/ATP
  previews. Supplier confirmation rows carry `EKPO-LGORT` and `EKES-CHARG`, and
  the schedule remainder rows retain `EKPO-LGORT` and `EKET-CHARG`; the PO
  confirmation option remains exclusive with ordinary PO receipts. The scoped
  regression now exercises ordinary PO and confirmation-aware PO batch supply
  alongside the other mapped receipt sources, plus missing-location fallback
  and mutually exclusive PO option validation. SAP field mappings and
  target-query validation are recorded in [ANOMALIES.md](ANOMALIES.md).
  abaplint reported 0 issues across
  138 files, transpilation succeeded, all 1,869 ABAP Unit methods passed,
  `validate:plan` passed, and the CRLF-aware diff check was clean.
- Strengthened `validate:plan` to check that receipt storage-location stubs
  are `CHAR(4)` and batch stubs are `CHAR(10)`, in addition to checking field
  presence. The validator passes against the current SAP table stubs.
- Limited scoped receipt reads to each material/plant's latest component date.
  This keeps a later unlocated receipt for one plant from forcing plant-level
  fallback for another plant whose component horizon ends sooner. The regression
  covers separate plants with different horizons and a later unlocated PO row.
  abaplint reported 0 issues, transpilation succeeded, all 1,869 ABAP Unit
  methods passed, and `validate:plan` passed.
- Added `CREATE_PROD_COMP_SERVICE()` to the production factory and reused it
  when wiring the production-order ATP release gate. Applications can now get
  the SAP-backed component service directly. Factory coverage checks both
  component and production-order service construction.
- Added factory methods for planned-order and production-order read services.
  They wire the existing bulk read services to the PLAF and production-order
  repositories, and the factory test checks all three production services.
- Added `CREATE_SO_RES_READ_SERVICE()` to wire sales-order reservation detail
  reads to the reservation BAPI adapter, and covered it in the factory test.
- Added `CREATE_SO_RESERVATION_SERVICE()` for SAP-backed order reservation
  release workflows, with the BAPI adapter and reservation finder wired in the
  factory and included in factory coverage.
- Verification passed: abaplint reported 0 issues across 138 files, the
  transpiler completed, and all 1,861 ABAP Unit methods ran with exit code 0.

## 2026-10-15

- Added priority-only ordering to cost-center FEFO previews. Higher-priority
  demands consume shared plant batches first; preview rows retain caller order
  and echo each priority. Tests cover split selection, invalid flags before
  stock reads, and summary ordering. `npm run lint` found 0 issues across 138
  files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added priority-only ordering to aggregate sales-order issue previews in base
  and alternative units. Higher priorities consume a shared item/cutoff
  balance first, results return in caller order, and malformed option flags are
  rejected before stock reads. Tests cover partial coverage and converted UOM
  totals. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Added priority-only ordering to sales-order FEFO preview and issue flows.
  Base-unit and UOM requests now allocate shared item stock by descending
  priority without requiring dates, preserve caller order in results, and
  recheck with the same ordering before movement 231. Tests cover priority batch
  splits in both units and both posting workflows. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0.
- Added `SEND_QUALITY_FEFO_PRIORITY` to apply priority-ordered unrestricted
  stock FEFO to movement 322. The service repeats the priority allocation,
  verifies priority echoes and batch splits, and supports location filters and
  safety-stock protection. Tests cover priority stock consumption, movement
  type, split quantities, and rejection of a modified priority or changed stock
  split before posting. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `RELEASE_QUALITY_FEFO_PRIORITY` to connect priority-ordered quality
  stock allocation to movement 321. The service recomputes the same priority
  preview, verifies priority echoes and batch splits, then posts unit-mapped
  quantities. Tests cover a high-priority demand consuming the earliest batch
  first, rejection of a modified priority, and rejection of a changed split
  before the goods-movement call. `npm run lint` found 0 issues across 138
  files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `ALLOCATE_DEMANDS_UOM_ATP` for ordinary bulk alternative-unit
  allocations. It preserves the unit-aware local result and checks cumulative
  positive quantities by material, plant, and base unit; the optional ATP date
  defaults to `sy-datum`. Tests cover mixed units, grouped partial confirmation,
  the default date, and early rejection of blank rules or invalid dates.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_PRIO_ATP` and
  `PREVIEW_TRANSFER_LOC_PRIO_ATP` for undated priority-ordered WBS transfers.
  They report grouped plant ATP diagnostics for positive local allocations
  without changing caller-order priority results; the optional check date
  defaults to `sy-datum`. Tests cover repeated IDs, priority FEFO/location
  splits, destination assignments, ATP grouping, and early rejection of bad
  dates and blank rules. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_PRIORITY_ATP` and `PREVIEW_LOCATION_PRIORITY_ATP` for
  undated priority-ordered WBS allocations. Their ATP checks aggregate positive
  quantities by material, plant, base unit, and check date while retaining the
  local priority allocation and caller-order rows. Tests cover repeated IDs,
  priority stock selection, grouped ATP quantities, date defaults/validation,
  and blank-rule rejection before reads. `npm run lint` found 0 issues across
  138 files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_ATP` and `PREVIEW_TRANSFER_LOC_ATP` for undated
  project WBS transfer previews. Checks group positive allocations by material,
  plant, base unit, and ATP date; the optional date defaults to `sy-datum` and
  does not alter the local transfer split. Tests cover batch/location splits,
  destination mapping, aggregation, date validation, and blank-rule rejection
  before reads. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_ATP` and `PREVIEW_BY_LOCATION_ATP` for undated project
  WBS previews. Both check positive allocations cumulatively by material,
  plant, base unit, and ATP date; the optional date defaults to `sy-datum` and
  does not change the current local stock estimate. Tests cover grouping,
  location preference, custom/default dates, and blank-rule or invalid-date
  rejection before reads. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_DATE_ATP` and `PREVIEW_TRANSFER_LOC_DATE_ATP`
  for cumulative plant-level ATP diagnostics on dated project WBS transfers.
  Checks group positive local allocations by material, plant, base unit, and
  required date; they do not alter batch or location splits. Tests cover
  repeated IDs, destination assignments, transfer stock splits, aggregation,
  and blank-rule rejection before reads. `npm run lint` found 0 issues across
  138 files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_BY_LOCATION_DATE_ATP`, pairing batchless dated WBS location
  allocation with cumulative plant-level SAP ATP diagnostics. Checks aggregate
  positive allocations by material, plant, base unit, and date; they do not
  alter the local location split. Tests cover duplicate IDs, location priority,
  same-date ATP aggregation, and blank-rule rejection before stock reads.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_BY_DATE_ATP`, which keeps the dated project WBS FEFO
  estimate and reports cumulative plant-level SAP ATP checks by material,
  plant, base unit, and required date. Confirmed/unconfirmed quantities remain
  diagnostic and do not gate the local allocation. Tests cover cumulative date
  grouping, partial confirmations, and rejection of a blank check rule before
  stock reads. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Updated `PREVIEW_FEFO_BY_DATE`, `PREVIEW_BY_LOCATION_DATE`,
  `PREVIEW_TRANSFER_FEFO_BY_DATE`, and `PREVIEW_TRANSFER_LOCATION_DATE` to
  assign unique internal IDs to each input row. Repeated caller IDs now work in
  direct dated preview calls as well as transfer wrappers, and allocations,
  splits, and assignments retain caller order and IDs. Added regression tests
  for all four preview types. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Updated `TRANSFER_WBS_BY_LOCATION_DATE` to use unique internal IDs through
  the dated source-WBS location preview, recheck, and 415/Q movement posting.
  Repeated caller IDs now work across required dates, and the result restores
  caller IDs/order for allocations, location splits, and transfer assignments.
  Tests cover date-based location choice and destination WBS mapping. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Updated `TRANSFER_WBS_FEFO_BY_DATE` to use unique internal IDs through the
  dated source-WBS preview, recheck, and 415/Q movement posting. Repeated caller
  IDs now work across required dates, with caller IDs and input order restored
  in allocations, batch splits, and transfer assignments. Tests cover distinct
  date-based batches and destination WBS mapping. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Updated `RESERVE_WBS_BY_LOCATION_DATE` to use unique internal IDs through
  the dated location preview, recheck, and reservation steps. Repeated caller
  IDs now work across requirement dates, while returned previews preserve the
  original IDs and input order. Tests cover separate date groups, locations
  selected by date order, and duplicate ID mapping. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP
  Unit with exit 0.
- Updated `RESERVE_WBS_FEFO_BY_DATE` to use unique internal IDs through the
  dated preview, recheck, and reservation steps. Repeated caller IDs now work
  across multiple required dates, with caller IDs and order restored in the
  preview. Tests cover duplicate IDs, date-prioritized FEFO batch selection,
  and separate reservation groups per date. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Added `RESERVE_WBS_LOCATION_PRIORITY` for rechecked priority-ordered
  batchless WBS reservations. Higher priorities consume shared stock first and
  equal priorities keep input order; returned previews restore caller order and
  IDs, while internal IDs preserve repeated demands during posting. Full
  quantity is required by default, with partial reservation opt-in. Tests cover
  repeated IDs, preferred-location allocation, grouped item quantities, and
  rejection when rechecking finds a newly preferred location. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added `RESERVE_WBS_FEFO_PRIORITY` for rechecked priority-ordered undated WBS
  batch reservations. It preserves stable input order for ties, restores caller
  order and IDs in the preview, and uses unique internal IDs through reservation
  creation so repeated caller IDs remain safe. Full quantity is required by
  default; partial reservations are opt-in. Tests cover duplicate IDs, FEFO
  split grouping, and stale allocation rejection before writes. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added `TRANSFER_WBS_LOC_PRIORITY` to recheck priority-ordered batchless WBS
  location splits before posting movement 415/Q. Internal IDs preserve distinct
  demands with repeated caller IDs, while the result preview restores caller
  IDs. Full demand coverage is required by default; partial transfer is
  opt-in. Tests cover storage-location preference, caller-order posting, and
  stale snapshot rejection. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `TRANSFER_WBS_FEFO_PRIORITY`, which runs the undated priority FEFO
  preview twice, compares the full source/destination batch transfer splits,
  then posts the matched result as movement 415/Q. Internal IDs keep duplicate
  caller IDs distinct through posting while the returned preview preserves
  caller IDs. Full demand is required by default; partial priority transfer is
  opt-in. Tests cover priority allocation, posted batch/WBS mapping, and stale
  snapshot rejection. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_PRIORITY` and
  `PREVIEW_TRANSFER_LOC_PRIORITY` for undated WBS stock transfers. Higher
  priorities consume shared source-WBS batch or location balances first, ties
  preserve input order, and allocation splits plus WBS assignments return in
  caller order with priority echoed. Internal row IDs allow repeated caller
  request IDs. Tests cover FEFO and location splitting, stable ties, and source
  location preference. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_BY_LOCATION_PRIORITY` for undated batchless project/WBS stock.
  Higher priorities allocate shared location balances first, ties preserve
  input order, and summaries, location splits, and WBS assignments return in
  caller order with priority echoed. Internal row IDs support repeated caller
  request IDs; the test also checks storage-location preference. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_PRIORITY` for undated project/WBS stock demands. Higher
  priorities allocate shared project batches first, ties preserve input order,
  and summaries, batch splits, and WBS assignments return in caller order with
  priority echoed. Internal row IDs preserve repeated caller request IDs.
  Regression coverage checks shared FEFO batches and duplicate IDs.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0. Snapshot and correlation limits are
  documented in `README.md` and `ANOMALIES.md`.
- Added `ALLOCATE_DEMANDS_UOM_ATP_PRIO` for grouped ATP checks on positive
  priority-based local UOM allocations. Higher priorities retain shared stock
  precedence; confirmations remain separate from the local allocation.
  Regression coverage checks caller-order quantities and grouped confirmation.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added `ALLOCATE_FEFO_UOM_ATP_PRIO` to check priority-aware single-plant FEFO
  UOM allocations against grouped plant ATP. ATP confirmations remain separate
  from the local batch split. Regression coverage checks priority allocation,
  caller-order results, and confirmed/unconfirmed totals. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0.
- Added priority-aware single-plant exact-batch allocation for base-unit and
  UOM demands, plus a grouped UOM ATP wrapper. Higher priorities consume shared
  batch stock first, ties preserve input order, and summaries/batch splits
  return in caller order with priority echoed. Repeated request IDs are
  preserved through internal row mapping. Regression coverage checks base/UOM
  quantities and grouped ATP confirmation. `npm run lint` found 0 issues across
  138 files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added priority-aware base-unit and UOM allocation across single-plant storage
  locations, plus a UOM ATP wrapper. Higher priorities consume shared stock
  first, ties preserve input order, and summaries/location splits return in
  caller order with priority echoed. Repeated request IDs are preserved through
  internal row mapping. Regression coverage checks duplicate IDs, UOM
  conversions, location preferences, and grouped ATP quantities. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added priority-aware undated ordinary cross-plant allocation for base-unit
  and UOM demands, preserving projected receipt and cutoff inputs. Higher
  priorities consume shared source balances first, stable ties preserve input
  order, and results return in caller order. Added the UOM ATP wrapper, which
  checks grouped source-plant quantities separately. Tests cover shared
  receipts, stable ties, base/UOM allocations, duplicate rejection before UOM
  reads, and ATP grouping. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added priority-aware cross-plant exact-batch allocation for base and
  alternative-unit demands, plus a UOM ATP wrapper. Priority applies among
  requests with the same as-of date, while earlier dates remain first. Results
  return in caller order with priorities echoed, and duplicate IDs fail before
  stock or UOM reads. Regression coverage checks base/UOM quantities,
  location splits, duplicate rejection, and grouped ATP quantities.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added priority-aware undated cross-plant FEFO allocation for base and
  alternative-unit demands. Higher priorities consume shared source-plant
  batches first, equal priorities preserve input order, and summaries plus
  source/batch splits return in caller order with priority echoed. Duplicate
  IDs are rejected before stock reads or UOM conversion. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0. The snapshot and SAP batch-determination limits are recorded in
  `README.md` and `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_FEFO_UOM_ATP` for priority-aware UOM cross-plant FEFO.
  It preserves the caller-order local split and checks positive allocations by
  material, source plant, and base unit, returning confirmations separately.
  Regression coverage verifies priority allocation and grouped ATP quantity.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0. ATP remains plant-level and does not
  confirm batch/location selection.
- Added priority-aware quality FEFO allocation for base and alternative-unit
  demands. Higher priorities consume shared quality batches first, while
  summaries and splits return in caller order. Both entry points reject
  duplicate IDs before repository or UOM reads. Regression coverage verifies
  base and UOM quantities, split restoration, and duplicate rejection.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added priority-aware FEFO allocation for base and alternative-unit demands.
  Higher priorities consume shared batches first, equal priorities keep input
  order, and summaries plus batch splits return in caller order with priority
  echoed. Missing or duplicate request IDs fail before stock reads. Tests cover
  stable ties, shared FEFO batches, UOM amounts, caller order, and duplicate
  rejection. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Rejected positive stock-service UOM demand that rounds to zero at
  `MARD-LABST` precision, before any stock read. Centralized the guard across
  unit-aware allocation paths and covered single, bulk, and dated location
  allocation with a tiny ratio. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added opt-in prioritized bulk allocation entry points for base and
  alternative-unit demand. Higher integer priority consumes shared
  material/plant stock first, ties keep input order, and results return in
  caller order with priority echoed. Duplicate or missing request IDs are
  rejected before stock reads. Tests cover base/UOM allocation, stable ties,
  echoed priorities, and duplicate rejection. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Extended dated cross-plant ordinary and FEFO allocation with per-demand
  `require_full_quantity`, including date UOM and ATP wrappers. The row flag
  combines with the shared option, is validated before stock/UOM reads, and
  leaves shared balances untouched when a short request is skipped. README and
  anomaly notes document the policy. `npm run lint` found 0 issues across 138
  files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Extended dated location-aware cross-plant ordinary allocation with the same
  per-demand policy in base and UOM requests, including the ATP wrapper. The
  flag passes through date/priority sorting into shared plant/location balance
  allocation, and invalid UOM row values are rejected before conversion.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added per-demand `require_full_quantity` to exact-batch cross-plant base and
  UOM demands in both undated and date-prioritized allocation. The shared flag
  still applies to all rows, and ATP wrappers preserve the local decision.
  Invalid row values are rejected before stock reads or UOM conversion.
  Regression coverage includes mixed row policies for local and cross-plant
  location, batch, dated, UOM, FEFO, and ATP paths. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP
  Unit with exit 0.
- Extended per-demand `require_full_quantity` to single-plant ordinary and
  location-aware base/UOM allocation, including dated location previews and ATP
  wrappers. Also added it to single-plant exact-batch base/UOM demand rows.
  Short flagged lines consume no shared balance, and invalid UOM row flags are
  rejected before conversion. README and anomaly notes document the scope.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Extended request-level `require_full_quantity` to ordinary and undated FEFO
  cross-plant base/UOM demands. A short flagged row consumes no source-plant
  stock and leaves it for later rows; the shared flag and ATP diagnostics keep
  their existing behavior. Mixed-demand and invalid-flag tests cover base,
  UOM, FEFO, ATP, and pre-conversion validation. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Added request-level `require_full_quantity` to stock-service FEFO base and
  UOM demands, including quality-stock FEFO and cost-center dated/undated
  previews. A short flagged request gets no batch split and leaves its eligible
  balance for later requests; the existing shared flag still applies to all
  rows. Preview results echo the cost-center row policy, and invalid values are
  rejected before stock reads or UOM conversion. Mixed-policy regression tests
  cover base, converted-unit, quality, and cost-center flows. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added per-request `require_full_quantity` to sales-order FEFO base and UOM
  demands. It combines with the existing shared flag; a short row receives no
  split and leaves remaining stock for subsequent requests, while unflagged
  rows retain partial behavior. Invalid values fail before stock reads.
  Regression coverage verifies mixed policies in base and converted-unit
  demand sets. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Carried the shared and per-request SO FEFO location filters in the allocation
  result. Goods-issue and reservation writers check every selected split
  against it; rechecks also compare filter metadata, and selected request
  results keep only the matching scoped rows. Regression cases cover excluded
  issue/reservation splits, scope changes at recheck, and filter preservation
  through selected and generated reservation previews. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0.
- Added request-specific storage-location scopes to SO FEFO previews, issue
  rechecks, and reservation previews. Scope rows intersect with the shared
  allowlist; mixed-demand tests cover separate location sets in base and UOM
  flows, invalid scope rejection before reads, and issue/reservation forwarding.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added a shared SO FEFO storage-location allowlist for base and UOM previews,
  plus fresh goods-issue and reservation preview paths. A preferred location
  must belong to the allowlist; excluded locations do not contribute to
  availability or splits. Tests cover both units, rejection before reads, and
  propagation through issue and reservation. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0. The SAP storage-type and authorization limits are recorded in
  `ANOMALIES.md`.
- Sales-order FEFO now rejects malformed nonblank expiration dates from the
  repository before sorting or allocating; a regression supplies an impossible
  Gregorian date. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Added per-demand preferred storage locations with optional fallback to
  sales-order FEFO previews in base and alternative units. Expiry and batch
  order remain primary; preference breaks location ties within the same batch
  and expiration date. Issue and reservation consumers validate the echoed
  preference, and full-location fallback tests cover both posting paths.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added a per-demand `require_known_expiry` option to sales-order FEFO requests.
  It excludes unknown-expiry batches for that demand while other requests can
  still use them under the shared undated-batch setting. Summaries and splits
  report the effective policy; base and UOM tests cover mixed demands and bad
  flag rejection before reads. The issue workflow regression confirms an
  undated batch is not posted for a known-expiry demand. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP
  Unit with exit 0. Local expiry metadata limits remain documented in
  `ANOMALIES.md`.
- Added a per-demand `minimum_shelf_life_days` constraint to sales-order FEFO
  previews in base and alternative units. The greater of the request value and
  shared `iv_min_days` now drives batch eligibility; summaries and splits echo
  the effective value so issue and reservation consumers retain the rule.
  Regression coverage checks differing minima against shared balances, UOM
  propagation, and rejection before reads for negative values. Validation
  passed: `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0. SAP expiry and batch
  determination limits are recorded in `ANOMALIES.md`.
- Hardened sales-order FEFO posting after finding that rechecked previews did
  not compare newly added summary `required_date` and `priority` fields, and
  posting did not require those values to match batch splits. Rechecks now
  compare them; posting validates date syntax/cutoff and matching split metadata.
  Added regressions for changed summaries, inconsistent splits, and dates after
  the effective cutoff. `npm run lint` passed with 0 issues across 136 files;
  `npm run unit` passed transpilation and ABAP Unit with exit 0. The combined
  `npm test` wrapper still fails at WSL 1 startup; individual scripts work.
- Added `ZCL_SO_FEFO_ISSUE_SERVICE->ISSUE_FEFO` and `ISSUE_FEFO_UOM` to recompute
  the same sales-order FEFO demand snapshot immediately before posting through
  the existing rechecked movement path. Optional request IDs select a subset
  from a multi-demand result after validating the IDs before stock reads. Added
  production factory wiring and tests for matching previews, base-unit movement
  mapping, selected cutoffs, stale stock rejection before the movement API, and
  empty input. `npm run lint` passed with 0 issues across 138 files;
  `npm run unit` passed transpilation and ABAP Unit with exit 0. The combined
  `npm test` wrapper still fails at WSL 1 startup; individual scripts work.
- Added exact storage-location filtering to sales-order FEFO demands in base and
  alternative units. The requested location is echoed on summaries and batch
  splits; goods issue and reservation creation now reject splits that violate
  it, including during refreshed-preview comparisons. Tests cover location-only
  FEFO in both units and pre-write rejection in both posting paths. Final lint
  passed with 0 issues across 138 files; transpilation and ABAP Unit passed
  with exit 0. The combined `npm test` wrapper still fails at WSL 1 startup;
  individual scripts work.
- Added `ALLOCATE_LOCATION_DATE_ATP` for dated location demands already
  expressed in base units. The caller supplies each demand's base unit; positive
  local allocations are combined by material, plant, unit, and required date,
  then checked cumulatively so later dates include earlier allocations. Tests
  cover early rejection, same-date aggregation, confirmations, and cumulative
  requests. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Plant-level ATP does not
  confirm the storage-location split; see `ANOMALIES.md`.
- Added `ALLOCATE_QUALITY_BY_EXPIRY_ATP`, which combines the quality-inspection
  FEFO UOM preview with grouped plant-level ATP checks for positive batch
  allocations. Tests verify early rule rejection, UOM conversion, FEFO splits,
  and partial ATP confirmation. `npm test` passed with 0 abaplint issues across
  136 files, successful transpilation, and ABAP Unit exit 0. ATP's coverage of
  quality stock and the exact batch remains target-system dependent.
- Added caller-resolved, dated storage-location receipts to
  `ALLOCATE_LOCATION_BY_DATE` and its base-unit ATP diagnostic. Receipts become
  available at their location on the stated date, are shared by later demands,
  and replenish any uncovered static safety-stock buffer first. Tests cover an
  invalid date, late receipt eligibility, location scope, safety-stock
  protection, and ATP forwarding. `npm test` passed with 0 abaplint issues
  across 136 files, successful transpilation, and ABAP Unit exit 0. Receipt
  identity remains caller-provided; see `ANOMALIES.md`.
- Added `ALLOCATE_QUALITY_BY_EXPIRY` and its `ALLOCATE_QUALITY_BY_EXPIRY_UOM`
  form. Both allocate raw `MCHB-CINSM` stock in FEFO order, share each
  material/plant balance across demands, preserve batch/location splits, apply
  expiry and minimum-shelf-life rules, and support all-or-nothing allocation.
  The UOM method returns base and source quantities. Tests cover expiry,
  undated-stock filtering, shared balances, full-quantity behavior, and UOM
  conversion. `npm test` passed with 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0. Quality-management and stock
  snapshot limits are recorded in `ANOMALIES.md`.
- Added `RELEASE_QUALITY_FEFO_RECHECKED` to post a unit-aware quality FEFO
  allocation after requiring an identical refreshed summary and batch split.
  It validates mappings, base/source quantities, split totals, and batch
  eligibility through the posting date, then posts canonical base-unit
  quantities with movement 321. Tests cover successful posting and stale
  preview rejection before the BAPI call. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit exit 0. The
  stock snapshot race and SAP quality controls are recorded in `ANOMALIES.md`.
- Added `SEND_QUALITY_FEFO_RECHECKED` for movement 322. It shares the same
  matching-preview, conversion, split-total, and posting-date eligibility
  checks, and preserves FEFO batches in the movement items. Tests verify both
  batch lines and base-unit quantities. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit exit 0.
- Added `ZCL_QUALITY_STOCK_SERVICE` to recompute quality or unrestricted FEFO
  allocations from the stock service immediately before posting movements 321
  or 322. Changed batch splits are rejected before the goods-movement API call;
  tests cover matching rechecks, changed QI stock, and empty requests.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
- Added storage-location priorities and allowlists to quality FEFO base and UOM
  allocation, and passed the options through the fresh quality-release service.
  Tests cover tie-breaking order, filtering, invalid preferred locations, and
  unit-aware rechecking with a filter. `npm test` passed with 0 abaplint issues
  across 136 files, successful transpilation, and ABAP Unit exit 0.
- Added optional exact-batch filters to base and unit-aware FEFO demands. Both
  unrestricted and quality FEFO now limit availability and splits to the
  requested batch while retaining expiry checks and shared balances. Tests
  cover base and UOM allocation for both stock categories. `npm test` passed
  with 0 abaplint issues across 136 files, successful transpilation, and ABAP
  Unit exit 0.

## 2026-10-14

- Added quality-inspection batch visibility to the batch stock-status readers.
  Base and bulk results now report `MCHB-CINSM` and `MCHB-CSPEM` beside
  unrestricted and reservation-net availability; UOM results convert all four
  quantities. The repository aggregates batch quantities in one `MCHB` query.
  Tests cover field mapping and alternative-unit conversion. `npm test` passed:
  0 abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0. The database mapping limitation is recorded in `ANOMALIES.md`.
- Added own-stock quality-inspection transfers: `RELEASE_QUALITY_STOCK`/321
  and `SEND_STOCK_TO_QUALITY`/322, with base and alternative-unit forms. Shared
  validation preserves location and optional batch data. Tests cover movement
  mapping and UOM conversion. `npm test` passed with 0 abaplint issues across
  134 files, successful transpilation, and ABAP Unit exit 0. SAP quality
  management controls are recorded in `ANOMALIES.md`.
- Added `BLOCK_UNRESTRICTED_STOCK` and `BLOCK_UNRESTRICTED_STOCK_UOM` using
  movement 344. The APIs preserve plant, storage location, optional batch, and
  quantity, with UOM conversion to the mapped material base unit. Tests cover
  movement mapping, batch forwarding, conversion, and invalid input rejection.
  `npm test` passed with 0 abaplint issues across 134 files, successful
  transpilation, and ABAP Unit exit 0.
- Added `RELEASE_BLOCKED_STOCK` and `RELEASE_BLOCKED_STOCK_UOM` using movement
  343. Requests retain plant, storage location, optional batch, and quantity;
  the UOM path converts to the mapped material base unit. Tests cover movement
  mapping, batch forwarding, conversion, and rejection before the API call.
  `npm test` passed with 0 abaplint issues across 134 files, successful
  transpilation, and ABAP Unit exit 0.
- Extended sales-order FEFO issue previews with an optional exact-batch filter
  in base and alternative units. Each demand allocates only from its selected
  batch, repeated demands share that batch's remaining balance, and expiration
  and shelf-life checks still apply. Reservation assignment remains global
  FEFO where the reservation has no physical batch scope; the aggregate stock
  snapshot is retained for audit. Tests cover repeated batch demands, partial
  coverage, expired batches, and UOM quantities. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added sales-order stock reads by owning sales document and item. Callers can
  supply item/material/plant directly or resolve material and plant from `VBAP`.
  The service reads `MSKA` stock, nets open `RESB` special-stock E reservations,
  and returns gross stock rows, open reservation detail, base unit, and
  aggregate availability. Added stubs, production factory wiring, tests, and
  docs. `npm test` passed: zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit. Target query semantics and stock snapshot limits
  are recorded in `ANOMALIES.md`.
- Added an optional reservation cutoff to sales-order stock reads. Reservations
  due after `RESB-BDTER` cutoff dates no longer reduce the net available total;
  undated requirements still count, and all open rows remain available for
  audit. The cutoff flows through both explicit material/plant reads and
  `VBAP`-resolved item reads. Tests cover the date boundary, undated rows,
  invalid dates, and forwarding. `npm test` passed with zero lint issues across
  134 files, successful transpilation, and ABAP Unit. The current-stock-only
  scope is recorded in `ANOMALIES.md`.
- Added `PREVIEW_ISSUE_DEMANDS` for multiple sales-order item quantities. It
  resolves materials and plants from `VBAP`, compares base-unit requests with
  net `MSKA`/`RESB` availability, and returns covered amounts and shortfalls
  with each stock snapshot. Duplicate item requests are rejected to prevent
  double counting; results are aggregate and do not assign a batch/location
  split. Tests cover full coverage, shortfall, duplicate demand, and empty
  input. `npm test` passed with zero lint issues across 134 files, successful
  transpilation, and ABAP Unit. Split and snapshot limits are in
  `ANOMALIES.md`.
- Added `PREVIEW_ISSUE_DEMANDS_IN_UNIT` to the sales-order stock service. It
  converts demand through the material UOM converter and returns requested,
  available, covered, and shortfall quantities in both source and base units.
  Unknown ratios and positive quantities that convert to zero are rejected.
  Tests cover exact coverage, partial coverage with fractional source units,
  unknown units, and sub-precision conversion. `npm test` passed with zero lint
  issues across 134 files, successful transpilation, and ABAP Unit. Target
  conversion data and aggregate-only limitations are recorded in
  `ANOMALIES.md`.
- Extended both sales-order demand previews to allow multiple request rows for
  one item without reusing the same available stock. Each row consumes the
  shared item's remaining balance in input order; unit-aware rows can use
  different units. Rows with the same item and cutoff share a balance. Tests
  cover partial cumulative coverage and cross-unit allocation. `npm test` passed
  with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit. Target aggregate-snapshot and
  date-cutoff limits remain in `ANOMALIES.md`.
- Extended both sales-order demand previews to accept multiple cutoffs for the
  same item. Each cutoff gets an independent remaining-availability pool, while
  requests within one item/cutoff group still consume stock cumulatively in
  input order. Tests cover base and UOM demand at two cutoffs. `npm test` passed
  with zero abaplint issues across 134 files, successful transpilation, and
  ABAP Unit.
- Added FEFO sales-order issue previews in base and alternative units. They
  return batch/location splits after deducting scoped reservations, allocating
  unscoped reservations against eligible batches, applying expiry and minimum
  shelf-life filters, and reconciling splits to aggregate availability. Tests
  cover multiple demands, cutoff handling, alternate units, expired and undated
  stock, minimum shelf life, and aggregation of duplicate stock rows. `npm test`
  passed with zero abaplint issues across 134 files, successful transpilation,
  and ABAP Unit.
  Target `MCHA`/`MCH1` and reservation assignment behavior remain documented in
  `ANOMALIES.md`.
- Added `ISSUE_SALES_ORDER_FEFO` to consume the new preview. It validates each
  summary and batch/location split, confirms base-unit mappings and the echoed
  expiry/shelf-life/undated-batch policy, then posts one 231/E document. Full
  allocation is required by default; partial posting is opt-in. Tests cover
  split preservation, default shortfall rejection, partial posting, and
  expired-batch rejection. `npm test` passed with zero abaplint issues across
  134 files, successful transpilation, and ABAP Unit.
- Added `ISSUE_SO_FEFO_RECHECKED` for callers that rerun the same preview before
  posting. It compares every result summary, physical stock and reservation row,
  and batch/location split, then posts only the identical refreshed result.
  Tests cover matching previews plus changed batch and stock snapshots.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Hardened FEFO posting against combining independent cutoff scenarios for the
  same sales-order item. Repeated demands with one cutoff remain supported;
  mixed-cutoff groups are rejected before the movement API so identical
  physical stock cannot be suggested twice in one posting. Tests cover both
  same-cutoff cumulative posting and mixed-cutoff rejection.
- Added `ISSUE_SO_FEFO_SELECTED` to post selected request IDs from a multi-demand
  preview. This lets callers post one cutoff scenario while retaining the
  duplicate-stock guard on the remaining requests. Tests verify selection from
  a result containing multiple cutoff scenarios, and reject unknown or
  duplicate IDs. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit.
- Added `ISSUE_SO_FEFO_SEL_RECHECKED` to extract the requested IDs from both an
  original multi-demand preview and its fresh rerun, compare the selected stock,
  reservation, summary, and split data, and post the refreshed selection only
  when unchanged. Tests cover successful selected recheck and changed splits.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added `reserve_so_stock_fefo` to turn sales-order stock FEFO splits into
  movement-231 reservation requests, preserving the order item, batch, location,
  and base-unit quantity. Full allocation is required by default; partial
  reservation is opt-in. The method validates split/cutoff/expiry metadata,
  supports simulation, checks returned reservation rows, and commits once with
  rollback on API or commit failure. Tests cover mapping, simulation, shortfall,
  expiry, API failure, and commit failure. `npm test` passed with zero abaplint
  issues across 134 files, successful transpilation, and ABAP Unit.
- Added `reserve_so_stock_fefo_selected` to reserve selected request IDs from a
  multi-cutoff preview. It filters summaries and matching batch splits, then
  runs the shared full-allocation, cutoff, expiry, API-result, and transaction
  checks. Empty, duplicate, and unknown IDs are rejected. Tests verify that one
  cutoff can be reserved without mixing the other pool. `npm test` passed with
  zero abaplint issues across 134 files, successful transpilation, and ABAP Unit.
- Added `reserve_so_fefo_rechecked` for full or selected FEFO reservation
  previews. It compares the caller's fresh result with the original, including
  stock balances, open reservations, allocation summaries, and batch/location
  splits, and reserves only from an unchanged result. Tests cover matching full
  and selected results plus changed stock. `npm test` passed with zero abaplint
  issues across 134 files, successful transpilation, and ABAP Unit. The remaining
  post-check stock race is documented in `ANOMALIES.md`.
- Added `reserve_so_fefo_demands` and `reserve_so_fefo_demands_uom` to run a
  sales-order FEFO stock preview and create the resulting reservations in one
  call. The UOM path converts to material base-unit quantities before sending
  the batch/location requests. Both methods support selected request IDs for
  multi-cutoff previews. Full allocation remains the default, and the methods
  support simulation and shelf-life/undated-batch options. Wired the stock
  service through `CREATE_SALES_ORDER_ALLOC`. Tests cover direct and selected
  FEFO reservation, UOM-to-base mapping, and shortfall rejection. `npm test`
  passed with zero abaplint issues across 134 files, successful transpilation,
  and ABAP Unit; the stock race before the BAPI call is recorded in
  `ANOMALIES.md`.
- Added `reserve_so_fefo_recheck` and `reserve_so_fefo_uom_recheck` to refresh a
  previously displayed FEFO preview internally before reservation creation.
  They compare the fresh preview with the original, support selected cutoff
  request IDs, and make no reservation API call when stock or splits changed.
  Tests cover unchanged base-unit previews, selected cutoffs, changed stock,
  and UOM demand. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit. The remaining stock race after the
  refresh is documented in `ANOMALIES.md`.
- Added `release_so_fefo_reservations` to release reservation numbers from a
  successful, committed FEFO creation result. It validates number uniqueness
  and matches reservation rows to the original batch/location splits before
  delegating to the existing transactional delete service. Test-run, delete
  failure, commit rollback, uncommitted-result rejection, and tampered-row cases
  are covered. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit; SAP reservation status rules remain
  documented in `ANOMALIES.md`.
- Added single and bulk sales-order stock reads in a requested unit. Results
  expose unrestricted, reserved, and available quantities in both the requested
  unit and material base unit; duplicate item reads share one stock snapshot.
  Tests cover alternate-unit conversion, shared bulk reads, and unknown units.
  `npm test` passed with zero abaplint issues across
  134 files, successful transpilation, and ABAP Unit. Target conversion data and
  rounding remain documented in `ANOMALIES.md`.
- Extended bulk unit stock reads to accept different reservation cutoffs for the
  same sales-order item. The service reuses the batched physical-stock read and
  calculates each cutoff's reservation and availability totals independently.
  Tests verify both cutoff totals and the retained cutoff in each result.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added order-scoped reservation issue methods for base-unit and UOM quantities.
  They check every reservation header for movement type 231 and the requested
  sales order/item before reusing the existing issue validation and posting
  flow. Tests cover valid base/UOM issues, wrong sales-order assignment, and a
  non-231 reservation. `npm test` passed with zero abaplint issues across 134
  files, successful transpilation, and ABAP Unit. Target BAPI header behavior
  and SAP-side stock checks remain in `ANOMALIES.md`.
- Added matching sales-order reservation reversal methods in base units and
  alternative units. They validate the same movement type and order/item header
  scope and reuse the existing withdrawn-quantity limit and movement code 06
  flow. Tests cover base and UOM reversals and a mismatched sales order.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added bulk sales-order issue and reversal methods for base-unit and UOM
  quantities. Each reservation document is checked against movement type 231
  and the requested order/item before its separate posting; a scope failure is
  isolated to that reservation while later reservations continue. Tests cover
  all four entry points and continuation after a mismatched reservation.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added `CREATE_RES_ISSUE_SERVICE()` to wire the reservation reader,
  goods-movement adapter, and UOM repository through the production factory.
  Construction coverage and README usage are updated.
- Extended sales-order issue and return postings with opt-in special stock E in
  both base-unit and unit-aware methods. The shared movement validator permits
  E only for movements 231/232 with sales-order assignment; blank remains the
  unrestricted-stock default. Tests cover E mapping and rejection of other
  indicators. `npm test` passed with zero lint issues and successful ABAP Unit;
  target movement customizing and return eligibility remain in
  `ANOMALIES.md`.
- Added `TRANSFER_SALES_ORDER_STOCK`/411E and `TRANSFER_TO_SALES_STOCK`/413E,
  with UOM variants for both directions between sales-order stock and own stock.
  The shared movement validator requires the special-stock indicator, correct
  GM code, and sales-order/item assignment. Tests cover base and converted
  quantities plus missing assignment rejection.
  `npm test` passed with zero lint issues across 134 files, successful
  transpilation, and ABAP Unit. Target authorizations and movement configuration
  are recorded in `ANOMALIES.md`.
- Added `TRANSFER_SALES_ORDER_ALLOC` to post the location/batch splits from a
  sales-order allocation preview as movement 413/E. It reuses the strict
  summary/split validation shared with sales-order issue posting, and requires
  full allocation by default. Tests verify 413/E mapping and split preservation.
  `npm test` passed with zero lint issues and ABAP Unit; preview snapshot limits
  are documented in `ANOMALIES.md`.
- Added `ISSUE_SO_ALLOC_RECHECKED` and `TRANSFER_SO_ALLOC_RECHECKED` to compare
  an original sales-order allocation preview with a caller-regenerated preview
  before posting. They check summary, sales-item, location, and batch rows, and
  post the fresh result only when all rows match. Changed previews are rejected
  before the movement API call. Tests cover a 231 issue, a 413 transfer, and
  changed splits. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit. Caller freshness and the remaining
  stock race are documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_REPL_SOURCE_SERVICE` to expose
  SAP-backed purchasing-source selection through the production factory.
  Added its constructor to the wiring test and README. Source-list and quota
  query semantics remain documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_SALES_ORDER_SERVICE` for the
  standard sales-order read and change workflow, backed by the SAP sales-order
  BAPI adapter. Added the constructor to production coverage and README;
  target BAPI semantics remain in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_CC_RESERVATION_SERVICE` to bind
  cost-center reservation flows to MARD stock, the reservation BAPI and
  reader, material units, and ATP. Added construction coverage and README
  wiring instructions. SAP reservation semantics remain documented in
  `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PREQ_SERVICE` to bind the
  replenishment-requisition workflow to its standard BAPI adapter. Added it to
  construction coverage and the production wiring README. Target PR API
  behavior remains documented in `ANOMALIES.md`.
- Added production factory methods for planned-order and production-order
  services. The production-order constructor now includes its component ATP
  checker, so the existing ATP-gated release methods are available through the
  standard composition. Extended construction coverage and README; target BAPI
  and ATP semantics remain recorded in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PURCHASE_ORDER_SERVICE` to wire
  PO workflows to the purchase-order BAPI and material UOM converter.
  Construction coverage and README now include the production entry point.
  Local validation checks the binding; purchasing BAPI behavior remains
  documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_STOCK_TRANSFER_SERVICE` to wire
  in-transit stock reads to the SAP transfer-stock repository and material UOM
  converter. Extended the construction test and README. Target STO and
  `MARD-UMLME` query behavior remains documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PROJECT_RESV_SERVICE` to compose
  the project reservation BAPI, WBS stock reader, shared material UOM
  converter, and goods-movement adapter used for reservation issues. Extended
  production construction coverage and README. Local validation confirms
  construction only; target BAPI and WBS behavior remain listed in
  `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PROJECT_STOCK_SERVICE` to wire
  WBS stock and reservation reads to the project-stock repository and UOM
  converter. Extended production construction coverage and README; local tests
  verify construction, while target `MSPR`/`RESB` query semantics remain
  documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_SALES_ORDER_ALLOC`
  to wire the sales-order allocation workflow to its sales-order BAPI, MARD
  stock repository, ATP adapter, and reservation BAPI. Extended the production
  construction coverage and README. Local validation checks service
  construction; target BAPI behavior remains covered by the existing
  sales-order reservation notes in `ANOMALIES.md`.
- Added item- and schedule-line-specific FEFO minimum shelf life to sales-order
  previews and reservations. Schedule-line settings override item-wide
  settings, while `iv_fefo_min_days` remains a floor; batch results report the
  effective minimum. Negative values and positive settings without FEFO are
  rejected before reads, and duplicate or unknown demand keys stop allocation.
  An opt-in required-date mode now checks each dated demand's expiry eligibility
  from the later of its requested date and the shared FEFO as-of date, returning
  that effective date on each batch split. Base-unit and unit-aware stock FEFO
  demand types also accept a per-demand as-of date; the shared minimum-shelf-life
  floor is still applied from the effective date.
  `npm run lint` reports zero issues across 128 files, and `npm run unit`
  passes after transpiling 1,141 outputs.
- Added `minimum_shelf_life_days` to ordinary and project-stock FEFO demands,
  including unit-aware ordinary-stock demands and WBS transfers. Each demand
  uses the greater of its own minimum and the shared minimum, which remains a
  floor for all demands. Cross-plant base-unit, dated, unit-aware, and ATP FEFO
  variants now follow the same rule; ordinary methods sharing their demand
  types reject nonzero FEFO options before stock reads. Splits report the
  effective minimum so reservation prevalidation preserves the policy.
  Cost-center FEFO previews and atomic/bulk cost-center reservations now carry
  the same per-demand rule; reservation result rows report its effective value.
  The FEFO stock-balance merge now rejects duplicate batch/location rows with
  conflicting expiry dates instead of silently keeping whichever date arrived
  first, and rejects impossible nonblank expiry dates before allocating them.
  Location-only and location-transfer previews reject shelf-life options before
  reads because those paths cannot validate batch expiry. Regression tests
  cover these checks and both bad-data cases.
  Tests cover different buffers within one request set, the shared floor,
  negative-value rejection before reads, transfer forwarding, and a reservation
  that skips a batch too close to expiry. Cross-plant tests cover base-unit,
  dated, unit-aware, and ATP forwarding plus ordinary allocator rejection.
  `npm run lint` reports zero issues across 128 files, and `npm run unit` passes
  after transpiling 1,141 outputs and running 1,388 test methods. Explicitly
  typing the date difference as an integer also fixes a transpiler inference
  that had treated the day count as a date.
- Added `TRANSFER_WBS_FEFO` and `TRANSFER_WBS_BY_LOCATION` as one-call WBS Q
  stock transfer flows. Each returns its preview, reruns the allocation before
  posting, and refuses the 415/Q movement when the batch or location split has
  changed. Tests cover successful batch/location posting and stale batch or
  preferred-location choices. `npm run lint` passed with zero issues across
  128 files; `npm run unit` exited successfully after transpiling 1,141 outputs.
- Added a second FEFO/location preview before WBS reservation creation and
  compare the full split plan. The one-call paths stop without a write if
  availability, batch expiry, FEFO order, or location priority changes between
  previews. Regression cases cover shared demand IDs, reduced stock, changed
  expiry, a newly available earlier batch, and a newly available preferred
  location. `npm run lint` passed with zero issues across 128 files, and
  `npm run unit` exited successfully after transpiling 1,141 outputs.
- Resolved the test-runner environment issue: native Linux Node is installed at
  `/home/lars/.nvm/versions/node/v22.22.2/bin`. Running
  `PATH=/home/lars/.nvm/versions/node/v22.22.2/bin:$PATH npm test` now passes:
  abaplint reports zero issues across 128 files, transpilation writes 1,140
  outputs, and ABAP Unit exits successfully. Earlier WSL errors came from
  invoking the Windows Node launcher.
- The full suite exposed that `prepare_from_suggestions` accepted impossible
  Gregorian required dates although bulk preparation rejected them. Added the
  missing date check in `build_suggestion_order_request`; the header date was
  already checked. The existing `rejects_bad_po_dates` regression covers it.
- Added `RESERVE_ORDERS_BY_DATE_BULK`, which shares the dated multi-order
  allocation preview and its full-allocation/ATP gates, then commits each
  order independently and continues after a failed create or commit. Results
  preserve each order's messages, reservations, success, test-run, and commit
  status; the top-level result makes partial failure visible. Added coverage
  for failed creates, failed commits, test runs, and continuation after failure.
  Repeated reservation BAPI LUW behavior and stale-stock exposure between
  preview and commits are recorded in `ANOMALIES.md`.
- Added `DELETE_ORDERS_RELEASE_BULK`, which discovers reservations with one
  validated grouped lookup and deletes/commits per order, continuing after an
  order failure. The result includes per-order messages and commit status and
  preserves earlier and later successes. Tests cover continuation after a
  failed delete and test-run behavior; target BAPI transaction behavior is
  noted in `ANOMALIES.md`.
- Sales-order allocation now rejects malformed Gregorian dates returned on
  open schedule lines, covering requested delivery dates and selected material
  availability dates in single- and multi-order previews/reservations. Local
  tests cover malformed EDATU and MBDAT plus no allocation, ATP, or reservation
  write. Bulk order reservation lookup still occurs before sales-order reads in
  the multi-order path.
- Added saved sales-order header mapping for order type, sales area, sold-to,
  customer PO, and document date using `BAPISDORDER_GETDETAILEDLIST` header
  output. The adapter requests these fields through the BAPI's header view.
  Header mapper tests cover the fields. Multi-document BAPI output behavior
  still needs target-SAP verification, recorded in `ANOMALIES.md`.
- Optimized `ZCL_SALES_ORDER_SERVICE->READ_ORDERS` to send the validated list
  through one API dispatch. The BAPI adapter now calls
  `BAPISDORDER_GETDETAILEDLIST` once for all requested sales documents, and the
  delivery repository groups its `VBAP`, `VBUP`, and `VBEP` reads by that list.
  Results retain caller order. Tests verify prevalidation, header mapping, and
  one batch API dispatch; actual BAPI multi-document behavior and grouped SQL
  behavior still need target-SAP verification, recorded in `ANOMALIES.md`.
  `npm test` passed with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and a successful ABAP Unit run.
- Added `ISSUE_PROJECT_WBS_BULK` for base-unit WBS issues. It prevalidates all
  request rows, posts and commits once per WBS, retains results in request
  order, and continues after a posting failure. Tests cover separate commits,
  continuation, prevalidation, test-run mode, and original request indexes.
  Target BAPI and transaction behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_PROJECT_WBS_BULK_UOM`, which converts all source quantities to
  each material's mapped base unit before the first posting call, then delegates
  to the bulk WBS posting flow. Tests cover multi-WBS conversion, batch
  preservation, separate commits, and rejection of a later unsupported unit
  before any write. Target unit ratios and ISO mappings are noted in
  `ANOMALIES.md`.
- Added `RETURN_PROJECT_WBS_BULK` for movement-222 returns across WBS elements.
  It prevalidates all rows, commits each WBS independently, preserves input
  ordering, reports partial failures, and supports test-run mode. Tests cover
  WBS/special-stock/batch mapping, continuation, prevalidation, and simulation.
  Target transaction behavior and the unreferenced-return limitation are
  recorded in `ANOMALIES.md`.
- Added `RETURN_PROJECT_WBS_BULK_UOM`, which converts every source-unit row to
  the mapped base unit before the first movement-222 call. Tests verify
  quantities, base units, batch/WBS mapping, and prevalidation when a later
  conversion is unsupported. Target material ratios and ISO mappings are
  recorded in `ANOMALIES.md`.
- Added atomic bulk WBS issue and return forms. They prevalidate all rows,
  stage one goods-movement BAPI call per WBS, commit once, and roll back the
  group after a create or commit failure. Results expose attempt, commit, and
  rollback state for each row and the group. Target SAP LUW behavior is
  recorded in `ANOMALIES.md`.
- Added unit-aware atomic WBS issue and return wrappers. Shared conversion now
  prepares and validates all source quantities before any BAPI call; the same
  conversion path serves per-WBS bulk and atomic modes. Tests cover conversions
  for both movements and rejection of a later unsupported unit before writes.
- Added `ISSUE_RESERVED_WBS_ITEMS` for selected items on an existing WBS
  reservation. It checks WBS/reservation/item scope and open status, then uses
  the reservation-backed issue service for SAP state validation, unit
  conversion, and posting. New tests cover base posting with alternative-unit
  conversion, simulation, and WBS scope rejection. The full suite also exposed
  a missing storage-location assignment in the shared reservation issue flow;
  it now retains the reservation's location, with production-component tests
  updated for that mapping. `npm test` passed: abaplint found zero issues in
  128 files, transpilation wrote 1,141 outputs, and ABAP Unit succeeded. SAP
  reservation-reference and 221/Q behavior are recorded in `ANOMALIES.md`.
- Added `ISSUE_RESERVED_WBS_ITEMS_BULK` for selected items across multiple WBS
  reservations. It checks every WBS/item scope before posting, then uses the
  reservation issue service's per-reservation material documents, commits, and
  continuation behavior. Tests cover two WBS reservations and rejection of a
  later wrong-WBS row before any issue call. Target multi-call transaction
  behavior is documented in `ANOMALIES.md`.
- Added single and bulk WBS reservation returns. The service requires a
  withdrawn balance but allows finalized items, then uses the reservation
  reversal API to return quantities up to the live withdrawn amount. Tests
  cover alternative-unit return, final-item reversal, and one commit per
  reservation. SAP reversal and `XSTOB` behavior are documented in
  `ANOMALIES.md`. `npm test` passed with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added atomic WBS reservation issues and returns across unique reservations.
  The service stages one reservation-referenced movement per reservation and
  commits once; create, validation, or commit failure rolls back the group.
  Tests cover group commit, later create failure, commit failure, finalized
  item reversal, and the shared suite passes with zero lint issues, 1,141
  transpiler outputs, and successful ABAP Unit. Target LUW behavior is recorded
  in `ANOMALIES.md`.
- Added `RESERVE_WBS_BULK` for direct reservation requests across unique WBS
  elements. It validates dates, stock keys, and every unit conversion before
  the first create; requests commit independently by default or share one
  atomic commit/rollback when requested. Test-run avoids transaction calls.
  Tests cover base-unit conversion, no-write prevalidation, bulk continuation,
  group commit, create and commit rollback, and simulation. `npm test` passed
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit. Target multi-call BAPI behavior is recorded in
  `ANOMALIES.md`.
- Extended `RESERVE_BATCH_ALLOCATION` and `RESERVE_LOCATION_ALLOCATION` to
  accept a distinct required date for each assigned WBS, alongside the existing
  shared-date option. The service validates complete, unique date coverage
  before any create, sends each WBS date to its reservation call, and returns
  the applied date in each result row. Tests cover separate dates for batch and
  location flows, atomic batches, and missing-date rejection before writes.
  Target BAPI date and LUW behavior is recorded in `ANOMALIES.md`. `npm test`
  passed with zero lint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Added `READ_AVAILABLE_STOCK_BULK` with per-request reservation cutoffs and
  detailed batch/location stock rows. It groups by cutoff, deduplicates stock
  keys within each group, and returns rows in request order. Tests verify
  different net availability across horizons, shared results for duplicate
  keys at one cutoff, grouped repository reads, invalid-date prevalidation, and
  empty input behavior. Target grouped query behavior is recorded in
  `ANOMALIES.md`. `npm test` passed with zero lint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added `READ_OPEN_RESERVATIONS_BULK` with an individual required-through date
  per WBS request. It groups repository reads by date, deduplicates WBS elements
  within each group, and preserves request order. Tests cover undated and dated
  reservations, shared request horizons, invalid-date prevalidation, empty
  input, and grouped reads. Target RESB/PRPS query behavior is recorded in
  `ANOMALIES.md`. The complete `npm test` run passed with zero lint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Validation after atomic and unit-aware WBS additions passed: `npm test`
  reported zero abaplint issues across 128 files, transpilation produced 1,141
  outputs, and ABAP Unit exited successfully. The CRLF-aware diff check passed.
- Validation after the WBS bulk additions passed: `npm test` reported zero
  abaplint issues across 128 files, wrote 1,141 transpiler outputs, and exited
  successfully after the ABAP Unit suite. The CRLF-aware diff whitespace check
  also passed.
- Extended `ZCL_PURCHASE_ORDER_SERVICE` to reject impossible Gregorian PO
  document and item delivery dates before `BAPI_PO_CREATE1`. The bulk and
  atomic entry points validate all request dates before their first write;
  suggestion preparation rejects malformed header and required dates too.
  Added cases for bad header dates, bad delivery dates, malformed dates in
  later bulk and atomic requests, and suggestion preparation. SAP
  purchasing-date eligibility is recorded in `ANOMALIES.md`.
- Extended the purchase-order schedule update service to reject malformed
  Gregorian delivery dates before `BAPI_PO_CHANGE`. Single, bulk, and atomic
  forms share the check, and regression coverage verifies invalid dates are
  rejected before any PO update.
- Added `CHANGE_RESV_STOCK_ATOMIC` for coordinated changes across WBS
  reservations. It validates all request fields and item scopes before any
  BAPI call, applies one API call per reservation, and uses one group commit or
  rollback. Test-run performs the same scope checks without BAPI or transaction
  calls. Local tests cover success, pre-write scope rejection, BAPI failure,
  commit failure, and simulation. Target SAP LUW behavior is recorded in
  `ANOMALIES.md`. Initial lint caught identifiers over ABAP's 30-character
  method-name limit; shortening them resolved the issue. Final `npm test`
  passed with zero lint issues across 126 files, 1,136 transpiler outputs, and
  successful ABAP Unit execution.
- Added `CHANGE_RESV_QTY_ATOMIC` for all-or-nothing quantity updates across WBS
  reservations. It validates all item scopes, entry units, UOM conversions,
  and withdrawn-quantity limits before BAPI writes, then shares one commit or
  rollback. Tests cover conversion-aware success, pre-write scope rejection,
  BAPI failure, commit failure, and test-run. Target SAP LUW behavior is
  recorded in `ANOMALIES.md`. Initial lint caught a misaligned parameter in
  the API payload expression; the explicit mapping loop resolved it. Final
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `RESCHEDULE_ITEMS_ATOMIC` for required-date updates across multiple WBS
  reservations. It validates the complete request and every item scope before
  BAPI writes, then shares one commit or rollback; test-run skips all update and
  transaction calls. Tests cover group success, pre-write scope rejection,
  BAPI failure, commit failure, and simulation. Target repeated-call LUW
  behavior is recorded in `ANOMALIES.md`. `npm test` passed with zero lint
  issues across 126 files, 1,136 transpiler outputs, and successful ABAP Unit
  execution.
- Added `SET_RESV_FINAL_ATOMIC` to mark open or reset finalized WBS reservation
  items across multiple reservations in one transaction. It prevalidates every
  requested item state before writes and supports test-run. Tests cover both
  mark and reset success, invalid current state, BAPI failure, commit failure,
  and simulation. Target SAP LUW behavior is documented in `ANOMALIES.md`.
  Initial lint found parameter alignment errors in the test calls; aligning the
  `it_requests` parameter resolved them. `npm test` passed with zero lint
  issues across 126 files, 1,136 transpiler outputs, and successful ABAP Unit
  execution.
- Added `DELETE_RESV_ITEMS_ATOMIC` for WBS reservation-item deletions across
  multiple reservations. It validates every item scope before the first BAPI
  call, then uses one group commit or rollback. Tests cover group success,
  pre-write scope rejection, a later API failure, commit failure, and test-run.
  Target SAP repeated-call LUW behavior is recorded in `ANOMALIES.md`.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `DELETE_RESERVATIONS_ATOMIC` for full reservation cancellation across
  multiple reservation numbers. It prevalidates the complete unique list and
  shares one live commit or rollback; test-run forwards SAP's simulation mode
  and makes no transaction call. Tests cover success, duplicate rejection,
  later BAPI failure, commit failure, and simulation. Target SAP repeated-call
  LUW behavior is recorded in `ANOMALIES.md`. Initial lint caught duplicate
  test method names with item deletion; renaming the whole-reservation cases
  resolved it. `npm test` passed with zero lint issues across 126 files, 1,136
  transpiler outputs, and successful ABAP Unit execution.

- Added optional atomic creation to `RESERVE_BATCH_ALLOCATION` and
  `RESERVE_LOCATION_ALLOCATION`. With `iv_atomic = abap_true`, allocation
  splits for all WBS elements are validated before BAPI calls, then the staged
  reservations share one commit or rollback. Test-run simulates each WBS
  request without transaction calls. Aggregate results expose row messages and
  report committed state when all independent live reservations succeeded.
  Tests cover both allocation modes, full prevalidation, BAPI and commit
  failures, duplicate returned numbers, and simulation. Target LUW and
  reservation-number behavior are documented in `ANOMALIES.md`. `npm test`
  passed with zero lint issues across 126 files, 1,136 transpiler outputs, and
  successful ABAP Unit execution.
- Added Gregorian calendar validation for WBS reservation required dates.
  Added reusable `ZCL_DATE_VALIDATION` and applied it to direct and allocation-
  based reservation creation, single/bulk/atomic rescheduling, project-stock
  cutoff reads, reservation coverage horizons, and FEFO as-of dates. Invalid
  numeric dates, impossible month/day combinations, and invalid leap days are
  rejected before reads or writes; optional empty cutoffs remain supported.
  Tests cover Gregorian century rules, invalid input across entry points, and
  rejection before repository access. SAP business-date and planning-horizon
  behavior remains authoritative and is recorded in `ANOMALIES.md`. `npm test`
  passed with zero lint issues across 128 files, 1,140 transpiler outputs, and
  successful ABAP Unit execution.
- Extended `ZCL_DATE_VALIDATION` to stock-service receipt cutoffs, FEFO status
  dates, dated allocation demands, and their unit-aware, cross-plant, batch, and
  ATP entry points. Invalid caller dates are rejected before UOM, stock, or ATP
  access. Added ABAP Unit cases for impossible demand, unit-aware, and FEFO
  dates, including pre-read rejection. Documentation records the remaining
  target-SAP planning-date checks. Static lint passed with zero issues across
  128 files before these integration cases were added. The final `npm test` and
  lint reruns could not start because the WSL 1 Node launcher rejected this
  environment before transpilation or ABAP Unit execution.
- Extended Gregorian date validation to goods-movement posting and document
  dates, plus optional cancellation posting dates. Bulk cancellation validates
  every supplied date before the first BAPI call, preserving group preflight.
  Added tests for invalid movement headers and cancellation dates; run the
  repository verifier after the WSL 1 Node launcher issue is resolved.
- Extended Gregorian date validation to stock-transfer purchase-order schedule
  dates from dated allocations, FEFO allocations, and caller-supplied batch
  dates. Invalid values are rejected while building requests, before any order
  create call. Regression cases cover dated and batch requests. The full test
  command remains unavailable because the WSL 1 Node launcher exits before
  lint, transpilation, or ABAP Unit starts; targeted source checks pass.

## 2026-10-13

- Added `RESCHEDULE_RESERVATION_ITEMS` and its bulk form to change the required
  date on selected open WBS reservation items. The service verifies item scope,
  supports scope-only test runs, and commits or rolls back each reservation
  independently. Tests cover live change, wrong-WBS rejection, simulation,
  commit failure, and bulk continuation after a BAPI error. Classic BAPI field
  and target LUW behavior still require SAP verification in `ANOMALIES.md`.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `CHANGE_RESERVATION_ITEM_QTY` and its bulk form for open WBS reservation
  items. Callers provide a new total quantity in each item's current entry unit;
  the service checks unit identity, converts to base units before comparing with
  withdrawn quantity, and commits each reservation independently. Tests cover
  a BOX entry quantity against an EA base unit, reductions above withdrawn
  quantity, rejection at the withdrawn quantity, test-run, and bulk continuation
  after a BAPI error. Classic BAPI fields and target availability-check behavior
  remain to verify in `ANOMALIES.md`. `npm test` passed with zero lint issues
  across 126 files,
  1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `CHANGE_RESERVATION_ITEM_STOCK` and its bulk form to adjust open WBS
  reservation items' storage location and/or batch. Per-field flags allow an
  explicit value or clear operation. The service verifies WBS scope and commits
  each reservation independently. Tests cover combined location/batch changes,
  batch clearing, scope rejection, test-run, commit rollback, and bulk
  continuation. Target BAPI fields and availability checks are in
  `ANOMALIES.md`. `npm test` passed with zero lint issues across 126 files,
  1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `MARK_RESERVATION_ITEMS_FINAL` and `RESET_RESERVATION_ITEMS_FINAL`,
  with bulk forms, for WBS reservation items. `READ_RESERVATION_ITEMS` now
  includes active final and fully withdrawn rows with their final-issue state.
  The service verifies open or finalized state and scope, supports test-run, and
  commits each reservation independently. Tests cover the raw reader, live mark
  and reset, scope rejection, simulation, and bulk continuation after a BAPI
  error. Classic BAPI fields and target behavior are recorded in `ANOMALIES.md`.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `READ_RESERVATION_COVERAGE_BULK` for keyed WBS coverage requests with
  independent required-through dates. It batches distinct WBS elements by date,
  returns results in caller order, rejects blank or duplicate request IDs, and
  skips reads for empty input. Tests cover mixed horizons, query grouping,
  validation, and empty input. `npm test` passed with zero lint issues across
  126 files, 1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `READ_RESERVATION_COVERAGE`, grouping project stock and open reservation
  quantity by WBS/material/plant in material base units. It reports free stock,
  reservation shortfall, open-item count, and full-coverage status; it supports
  the required-through date filter and excludes unlocated stock that previews
  cannot allocate. Tests cover exact and broad reservations, date cutoff,
  unlocated stock, and an uncovered reservation. `npm test` passed with zero
  lint issues across 126 files, 1,136 transpiler outputs, and successful ABAP
  Unit execution. Query limitations are recorded in `ANOMALIES.md`.
- Added `DELETE_RESERVATION_ITEMS` and `DELETE_RESERVATION_ITEMS_BULK` for
  WBS-scoped item cancellation. The service validates item ownership against
  open Q reservations before calling SAP, simulates scope checks without BAPI
  writes, and commits each reservation independently. Tests cover live deletion,
  wrong-WBS rejection, simulation, commit failure, and continuing after a failed
  reservation.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution. Target change-BAPI behavior is
  documented in `ANOMALIES.md`.
- Added `READ_OPEN_RESERVATIONS` to return open Q reservation items for scoped
  WBS elements, with reservation item identity and remaining open
  quantity. It filters rows outside requested WBS elements, validates item
  identities, rejects duplicates, and returns date/document/item order. Tests
  cover open quantity, WBS filtering, duplicate rejection, and the empty-input
  path. An optional required-through date filters later dated items and keeps
  undated rows; tests cover this cutoff.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution. Target SQL and DDIC checks are in
  `ANOMALIES.md`.
- Added `DELETE_RESERVATION` and `DELETE_RESERVATIONS_BULK` for WBS reservation
  cancellation. Bulk requests validate before processing and return per-number
  results while each deletion commits independently. Tests cover live delete,
  test-run without a transaction, duplicate rejection, and continuing after an
  individual failure and commit failure. `npm test` passed with zero lint
  issues across 126 files, 1,136 transpiler outputs, and successful ABAP Unit
  execution. Target BAPI and deletion eligibility checks are recorded in
  `ANOMALIES.md`.
- Added `RESERVE_BATCH_ALLOCATION` and `RESERVE_LOCATION_ALLOCATION` to bridge
  project-stock previews into WBS reservations. They validate assignments and
  split totals before writing, combine repeated stock-key splits, and create one
  independently committed reservation per WBS. Short allocations are rejected
  by default, with partial reservation opt-in. Tests cover two-WBS batch
  grouping, duplicate split aggregation, batchless location mapping, and
  default shortfall rejection. `npm test` passed with zero lint issues across
  126 files, 1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `ZCL_PROJECT_RESV_SERVICE=>RESERVE_FOR_WBS` with a dedicated
  `BAPI_RESERVATION_CREATE1` adapter for project/WBS reservations. It maps
  movement type 221 and WBS assignment, converts alternative units to base
  units, and supports test-run, commit, and rollback handling. Tests cover
  multi-item creation, BOX-to-EA conversion, duplicate-key rejection,
  simulation, create failure, and commit failure. Target BAPI fields,
  reservation special-stock output, and project configuration checks are
  documented in `ANOMALIES.md`. `npm test` passed with zero lint issues across
  126 files, 1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `READ_AVAILABLE_STOCK` to `ZCL_PROJECT_STOCK_SERVICE` for direct
  material/plant/WBS balance inquiries. It returns located batch and batchless
  rows with net available quantity and material base unit, and accepts the same
  reservation-date cutoff as the previews. Reservation netting runs across
  both stock types together so broad reservations are deducted only once.
  Tests cover key scoping, mixed batch stock, batch-specific and broad
  reservations, and cutoff behavior. `npm test` passed with zero lint issues
  across 122 files, 1,129 transpiler outputs, and successful ABAP Unit
  execution. Target SAP query and DDIC behavior remains noted in
  `ANOMALIES.md`.
- Added direct project-WBS goods issues (movement 221) and returns (movement
  222), with unit-aware variants that convert to supplied material base-unit
  mappings. The BAPI adapter maps WBS_ELEMENT, and the service validates the
  project account assignment and rejects mixed account keys. Tests cover both
  movements, batch preservation, BOX-to-EA conversion, and missing-WBS
  rejection. `npm test` passed with zero lint issues across 118 files, 1,118
  transpiler outputs, and successful ABAP Unit execution. SAP's WBS requirement
  and target-system checks are recorded in `ANOMALIES.md`.
- Added `ISSUE_PROJECT_WBS_ALLOCATION` to post location splits from the stock
  service's unit-aware allocation result. It maps request IDs to WBS elements,
  validates demand/split totals and unit mappings, and requires full allocation
  by default with partial posting opt-in. Tests cover mixed WBS assignments,
  multiple locations, and default shortfall rejection. `npm test` passed with
  zero lint issues across 118 files, 1,118 transpiler outputs, and successful
  ABAP Unit execution.
- Added `ISSUE_PROJECT_WBS_BATCH_ALLOC` for explicit-batch and FEFO unit
  allocation results. It retains each batch/location split under the mapped
  WBS element and validates totals and unit mappings before posting. Tests
  cover multiple dated batches and storage locations. `npm test` passed with
  zero lint issues across 118 files, 1,118 transpiler outputs, and successful
  ABAP Unit execution.
- Added project special-stock `Q` support to direct WBS issue/return methods,
  including their UOM variants. The adapter maps `SPEC_STOCK`; blank remains
  the unrestricted-stock default, and allocation-based issue paths remain
  restricted to unrestricted stock. Tests cover Q propagation through all four
  methods and rejection of unsupported special-stock codes. `npm test` passed
  with zero lint issues across 118 files, 1,118 transpiler outputs, and
  successful ABAP Unit execution.
- Added `ZCL_PROJECT_STOCK_REPOSITORY` for Q stock reads from `MSPR` joined to
  `PRPS`, and `ZCL_PROJECT_STOCK_SERVICE=>PREVIEW_FEFO` for WBS-scoped,
  unit-aware batch allocation from project stock. It honors expiry and location
  filters, shares stock across demands, and returns WBS assignments with the
  batch splits. `ISSUE_PROJECT_WBS_BATCH_ALLOC` now accepts special stock Q so
  the preview can be posted as movement 221. Tests cover BOX-to-EA allocation,
  FEFO ordering, WBS separation, shared balances, and Q propagation. `npm test`
  passed with zero lint issues across 122 files, 1,127 transpiler outputs, and
  successful ABAP Unit execution. SQL target-system validation and the
  batch-managed/valuated-unrestricted scope are recorded in `ANOMALIES.md`.
- Added `PREVIEW_BY_LOCATION` for batchless Q project stock. It aggregates
  unbatched `PRLAB` balances by storage location, applies location priority,
  converts units, and retains WBS assignments; batched rows and explicit batch
  demands are excluded. `ISSUE_PROJECT_WBS_ALLOCATION` now accepts special
  stock Q for this result. Tests cover unit conversion, priority ordering,
  batch exclusion, and Q propagation. `npm test` passed with zero lint issues
  across 122 files, 1,127 transpiler outputs, and successful ABAP Unit
  execution. The caller must pair the Q flag with a project-stock preview.
- Added `TRANSFER_PROJECT_WBS_STOCK` for same-plant, same-location movement
  415/Q transfers between WBS elements. It converts material units, retains
  batches, sets the receiving stock keys, and maps destination/source WBS
  values to `WBS_ELEMENT` and `VAL_WBS_ELEM`; same-WBS transfers are rejected.
  Tests cover the Q movement,
  source/destination mapping, BOX-to-EA conversion, batch retention, and
  self-transfer rejection. `npm test` passed with zero lint issues across 122
  files, 1,127 transpiler outputs, and successful ABAP Unit execution. SAP
  grouping-WBS eligibility and BAPI behavior are documented in `ANOMALIES.md`.
- Added `PREVIEW_TRANSFER_FEFO` to allocate dated project-stock batches from a
  source WBS for transfer to a destination WBS, plus `TRANSFER_WBS_BATCH_ALLOC`
  to validate and post those splits as 415/Q. The poster checks demand and
  batch totals, retains source/destination assignments and batches, and
  requires full allocation by default. Tests cover FEFO selection, WBS mapping,
  multiple batch splits, and default shortfall rejection. `npm test` passed
  with zero lint issues across 122 files, 1,127 transpiler outputs, and
  successful ABAP Unit execution. SAP validates grouping-WBS eligibility and
  stock at posting time.
- Added `PREVIEW_TRANSFER_BY_LOCATION` and `TRANSFER_WBS_LOCATION_ALLOC` for
  batchless project-stock transfers. The preview scopes availability to each
  source WBS and returns prioritized storage-location splits with the
  source/destination WBS assignments; the poster validates totals and posts
  movement 415/Q with full allocation required by default and partial posting
  available by opt-in. Tests cover batched-row exclusion, location splits, WBS
  mapping, default shortfall rejection, and partial posting. `npm test` passed
  with zero lint issues across 122 files, 1,127 transpiler outputs, and
  successful ABAP Unit execution. SAP validates grouping-WBS eligibility and
  stock at posting time.
- Made project-stock previews subtract outstanding Q reservations from the
  same WBS/material/plant before allocating. The repository reads RESB rows with
  `SOBKZ = 'Q'`, excludes deleted and final-issued rows, and the service nets
  `BDMNG - ENMNG` against matching location/batch balances, applying specific
  reservations first and keeping any over-reservation within its WBS. Tests
  cover exact-batch, location-specific, partially withdrawn, and cross-WBS
  reservations. `npm test` passed with zero lint issues across 122 files,
  1,127 transpiler outputs, and successful ABAP Unit execution. The RESB/PRPS
  query still needs validation against the target SAP release.
- Restricted reservation deductions to the stock rows eligible for each
  project preview before applying them. This prevents unlocated rows and
  batched rows in the batchless location path from absorbing reservations and
  inflating eligible balances. Batch-specific reservations are excluded from
  the batchless path. Regression tests cover both preview modes.
  `npm test` passed with zero lint issues across 122 files, 1,127 transpiler
  outputs, and successful ABAP Unit execution.
- Added material-level `MCH1-VFDAT` fallback when the project-stock repository
  has no plant-level `MCHA-VFDAT`, matching the generic stock repository's
  batch-expiry lookup. The existing MCH1 SAP stub supports linting and
  transpilation. `npm test` passed with zero lint issues across 122 files,
  1,127 transpiler outputs, and successful ABAP Unit execution. The local suite
  does not execute either batch-master SQL query; the target-release query
  check is recorded in `ANOMALIES.md`.
- Added `RETURN_FROM_SALES_ORDER` for direct movement-232 returns and
  `RETURN_FROM_SALES_ORDER_UOM` for alternative-unit quantities. Both preserve
  sales order, item, and batch assignments; the UOM form converts to base
  units and checks the supplied ISO map. Tests cover mapping, BOX-to-base
  conversion, and invalid quantity rejection. `npm test` passed with zero lint
  issues across 118 files, 1,118 transpiler outputs, and successful ABAP Unit
  execution. Movement semantics and target-release checks are in
  `ANOMALIES.md`.
- Added `RETURN_TO_PRODUCTION_ORDER` for direct movement-262 component
  returns and `RETURN_TO_PRODUCTION_ORDER_UOM` for alternative-unit requests.
  Both retain the supplied production order, plant/location, and batch; the
  UOM form converts to the material base unit. Tests cover return mapping,
  BOX-to-base conversion, and invalid quantities. `npm test` passed with zero
  lint issues across 118 files, 1,118 transpiler outputs, and successful ABAP
  Unit execution. SAP target behavior and the unreferenced-return limitation
  are recorded in `ANOMALIES.md`.
- Added `REVERSE_TO_COST_CENTER` for direct movement-202 returns without a
  reservation or source-document key, plus `REVERSE_TO_COST_CENTER_UOM` for
  alternative-unit quantities. The UOM form converts to the material base unit
  and checks the supplied base-unit/ISO map. Tests cover 202 mapping, batch and
  cost-center preservation, BOX-to-base conversion, and invalid quantities.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution. SAP's unreferenced and partial
  reversal behavior and target BAPI checks are recorded in `ANOMALIES.md`.
- Added `ISSUE_COST_CENTER_BATCHES` and `ISSUE_COST_CENTER_FEFO` to post
  multi-demand explicit-batch and FEFO previews. They preserve each demand's
  cost center, batch, and location splits, validate preview totals and unit
  mappings, and post one 201 document. Full allocation is required by default;
  partial issue is opt-in. Tests cover mixed cost centers and units, batch and
  FEFO split preservation, partial posting, shortfall rejection, and split
  mismatch. `npm test` passed with zero lint issues across 118 files, 1,118
  transpiler outputs, and successful ABAP Unit execution. Target multi-account
  BAPI behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_COST_CENTER_LOCATIONS` to post multi-demand cost-center
  location previews together in one movement-201 document while retaining each
  demand's cost center. It validates unique request IDs, base-unit mappings,
  summary totals, and storage split sums; full allocation is the default and
  partial issue is opt-in. Tests cover mixed cost centers and units, multiple
  location lines, partial posting, shortfall rejection, and split mismatch.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution. Multi-account-assignment BAPI
  behavior in the target release is recorded in `ANOMALIES.md`.
- Added `ISSUE_COST_CENTER_ALLOCATION` to turn a successful cost-center
  preview into 201 goods movement items while preserving its storage-location
  and batch splits. It requires a matching base-unit/ISO mapping, rejects a
  result that already carries a reservation number, and requires full
  allocation by default. Tests cover location and batch issues, partial issue,
  shortfall rejection, reservation-result rejection, and split mismatch.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution.
- Added `ISSUE_SALES_ORDER_ALLOCATION` to turn a successful single-order stock
  preview into movement 231 items. It preserves location and selected-batch
  splits, requires matching base-unit/ISO mappings, reconciles both preview
  summaries and split totals, and defaults to requiring full allocation.
  Unrestricted-stock only; preview stock is not re-read at posting time. Tests
  cover location and batch posting, partial posting, shortfall rejection, and
  split mismatch. `npm test` passed with zero lint issues across 118 files,
  1,118 transpiler outputs, and successful ABAP Unit execution.
- Added `ISSUE_UNPLANNED_PROD_BULK`, which accepts distinct production
  orders and posts a separate movement 261 document for each. It prevalidates
  the complete batch before the first BAPI call, continues after per-order
  failures, and reports attempted, committed, successful, and failed rows.
  Tests cover multiple order mapping, continuation after failure, and rejection
  of a malformed later request before posting, plus test-run simulation.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution.
- Added direct sales-order issues with movement type 231 and unplanned
  production-order issues with movement type 261. Both have unit-aware forms
  that convert quantities to material base units and validate caller-provided
  base-unit/ISO mappings. The production method explicitly supports withdrawals
  outside the order component list; reservation-backed issue remains the path
  that updates reservation quantities. Tests cover field mapping, conversion,
  simulation, commit, and invalid-unit/input rejection. `npm test` passed with
  zero lint issues across 118 files, 1,118 transpiler outputs, and successful
  ABAP Unit execution. Target SAP behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_TO_COST_CENTER` for direct 201 goods issue without a reservation
  key, plus `ISSUE_TO_COST_CENTER_IN_UNIT` for alternative-unit quantities. The
  methods post one document with standard simulation and transaction handling;
  the unit-aware form converts to base quantities and checks caller-provided
  base-unit/ISO mappings. Tests cover field mapping, conversion, mapping and
  unit rejection, blank cost center, invalid quantity, commit, and simulation.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution. Target stock, UOM, batch, and
  authorization behavior are recorded in `ANOMALIES.md`.
- Added cost-center-scoped reservation issue and reversal entry points for
  base-unit and alternative-unit requests, including independent
  per-reservation bulk posting. Issues require open items under the requested
  cost center; reversals use a key-based `RESB`/`RKPF` lookup so fully issued
  items remain in scope. Tests cover successful issue/reversal, rejection of a
  wrong cost center before movement, and BOX-to-base conversion for both issue
  directions. `npm run lint` passed with zero issues across 118 files;
  `npm run unit` passed with 1,118 transpiler outputs and successful ABAP Unit
  execution. Snapshot timing, SQL validation, and target authorization are
  recorded in `ANOMALIES.md`.
- Added unit-aware goods issue and reversal methods, including per-reservation
  bulk variants. Each line's quantity converts through the material UOM ratio
  into the reservation item's base unit before open/withdrawn quantity checks;
  SAP receives the converted quantity and reservation ISO unit. Tests cover
  single issue, single/bulk reversal, grouped multi-item issue, unknown units,
  and base-unit mismatch rejection.
  `npm run lint` passed with zero issues across 118 files; `npm run unit`
  passed with 1,118 transpiler outputs and successful ABAP Unit execution.
  Target MARM ratios and rounding are recorded in `ANOMALIES.md`.
- Added `POST_GOODS_ISSUE_BULK` and `POST_GOODS_ISSUE_REVERSAL_BULK` for
  independent reservation movement documents. Requests are grouped by
  reservation in first-seen order; selected items for one reservation share a
  document, while read, validation, or posting failures leave later groups
  eligible to proceed. Added success, read/commit failure continuation,
  simulation, reversal, duplicate-key prevalidation, and empty-input tests.
  `npm run lint` passed with zero issues across 118 files; `npm run unit`
  passed with 1,118 transpiler outputs and successful ABAP Unit execution.
  Target BAPI grouping and commit behavior is recorded in `ANOMALIES.md`.
- Added `RESERVE_COST_CENTERS_BULK` for independent reservation creation. It
  prevalidates request keys and shared options, then processes demands in caller
  order with a separate reservation and commit per successful demand. Failures
  roll back that demand and later demands continue; test runs skip commits.
  Tests cover success, API and commit failure continuation, simulation,
  duplicate request keys, and empty input. `npm run lint` passed with zero
  issues across 118 files; `npm run unit` passed with 1,118 transpiler outputs
  and successful ABAP Unit execution. Target LUW behavior is recorded in
  `ANOMALIES.md`.
- Added `READ_CC_RESERVATIONS_BULK` to read open reservation items for multiple
  cost centers with one repository call. Results preserve caller order, empty
  centers succeed, and blank/duplicate center keys or malformed repository
  rows fail validation. Tests cover grouping, order, input errors, duplicate
  rows, and empty input. `npm test` passed: zero abaplint issues across 118
  files, 1,118 transpiler outputs, and successful ABAP Unit execution. Target
  SQL validation is recorded in `ANOMALIES.md`.
- Added `DELETE_CC_RESERVATION_ITEMS` to release selected open items without
  deleting their entire reservation document. The service verifies cost-center
  scope and open status before using `BAPI_RESERVATION_CHANGE`, and commits or
  rolls back the update. Test runs validate the local snapshot only. Tests cover
  selective deletion, malformed and unscoped keys, simulation, and API/commit
  rollback; BAPI details are recorded in `ANOMALIES.md`. `npm test` passed:
  zero abaplint issues across 118 files, 1,118 transpiler outputs, and
  successful ABAP Unit execution.
- Added `DELETE_RESERVATION_ITEMS_BULK` to apply selected-item deletion across
  reservation documents. It prevalidates all request keys, rejects duplicate
  reservation groups, commits each document separately, and continues after
  per-document failures. Tests cover partial success, simulation,
  prevalidation, and empty input. `npm test` passed: zero abaplint issues
  across 118 files, 1,118 transpiler outputs, and successful ABAP Unit
  execution. BAPI LUW validation is recorded in `ANOMALIES.md`.
- Added `READ_COST_CENTER_RESERVATIONS` to list open movement-type 201
  reservation items by header cost center. The repository joins `RESB` to
  `RKPF`, returns required, withdrawn, and open quantities plus item identity,
  and orders the result by material, plant, and requirement date. The service
  validates reservation keys, cost-center scope, quantities, and duplicate
  items. Added success, malformed-row, duplicate-row, and blank-key tests; SQL
  and status filters are documented in `ANOMALIES.md`. `npm test` passed: zero abaplint
  issues across 118 files, 1,116 transpiler outputs, and successful ABAP Unit
  execution.
- Added opt-in MBDAT scheduling to single- and multi-order sales-order previews
  and reservations. The delivery repository reads `VBEP-MBDAT`; allocation,
  ATP checks, and reservation requirement dates can use it instead of
  `VBEP-EDATU`. Single-order date-prioritized allocations sort by MBDAT. Open
  items without a dated schedule line are rejected in this mode; MBDAT alone is
  sufficient when EDATU is blank. Added
  allocation, reservation, ATP-date, missing-date, and invalid-flag tests;
  target SAP field population is recorded in `ANOMALIES.md`.
  `npm test` passed: zero abaplint issues across 116 files, 1,112 transpiler
  outputs, and successful ABAP Unit execution.
- Added `DELETE_RESERVATIONS_BULK` for independent cost-center reservation
  deletion. It validates the entire list before calling SAP, commits each
  document separately, continues after API or commit failures, and returns
  per-reservation messages and transaction status. Added tests for partial
  success, commit failure continuation, simulation, and prevalidation.
  `npm test` passed: zero abaplint issues across 116 files, 1,112 transpiler
  outputs, and successful ABAP Unit execution.
- Added `DELETE_RESERVATIONS` to the cost-center reservation service. It
  prevalidates reservation numbers, calls `BAPI_RESERVATION_DELETE` for each
  complete document, supports test runs, and commits once or rolls back after
  API/commit errors. Added tests for success, simulation, both rollback paths,
  and invalid lists. SAP eligibility and multi-document LUW behavior are
  recorded in `ANOMALIES.md`. `npm test` passed: zero abaplint issues across
  116 files, 1,112 transpiler outputs, and successful ABAP Unit execution.
- Extended `READ_CONFIRMATIONS_BULK` to return each confirmation's raw yield,
  rework, and scrap quantities with the AFRU entry unit. Expanded the local
  AFRU stub and added service mapping assertions. SAP documents these as
  separate confirmation quantities; local values remain unconverted and
  reversal quantity semantics need target-system validation, recorded in
  `ANOMALIES.md`. `npm test` passed: abaplint found zero issues across 116
  files, transpilation wrote 1,112 outputs, and all ABAP Unit tests passed.
- Added `CREATE_CONFIRMATIONS_ATOMIC` for production-order time tickets. The
  adapter can defer its normal per-ticket commit so the service can commit the
  group once or roll it back after a BAPI or commit failure. Its `iv_test_run`
  option stages and rolls back the complete group; result flags distinguish a
  successful simulation from committed confirmations, and generated keys are
  documented as provisional. Tests cover shared commit, API and commit failure,
  test-run rollback, and invalid test-run values. `npm test` passed: abaplint
  found zero issues across 116 files, transpilation wrote 1,112 outputs, and
  all ABAP Unit tests passed. Target-system LUW and automatic goods-movement
  behavior is recorded in `ANOMALIES.md`.

## 2026-10-11

- Added `PREPARE_FROM_SUGGESTIONS` to `ZCL_PURCHASE_ORDER_SERVICE`. It returns
  the validated single-PO request with selected sources, schedule lines, and
  converted quantities without calling the PO API; creation submits that same
  request. Tests cover source and unit mapping plus no-write preparation.
- Added `PREPARE_FROM_SUGGESTIONS_BULK` to expose the validated PO request
  groups before writing. Bulk and atomic suggestion creation now share those
  prepared groups. Tests cover vendor grouping, original suggestion indexes,
  converted quantities, and no-write preparation. `npm.cmd test` passed with
  zero abaplint issues across 116 files and 1,156 transpiler outputs; all unit
  tests passed.
- Added `PREPARE_FROM_REQUISITION_ITEMS` to the PO service. It validates
  selected PR rows and returns the header plus remaining-quantity PO items and
  PR references without calling the PO API. `CREATE_FROM_REQUISITION_ITEMS`
  now submits this prepared request. Tests verify the request and the no-write
  preparation path. `npm.cmd test` passed with zero abaplint issues across 116
  files and 1,156 transpiler outputs; all unit tests passed.
- Added `PREPARE_FROM_REQUISITIONS` for grouped PO conversion from selected PR
  items. It validates all references and returns first-seen vendor/organization
  groups with remaining quantities; bulk and atomic creation now consume this
  same prepared list. Tests cover grouping, item mapping, and no-write preview.
  `npm.cmd test` passed with zero abaplint issues across 116 files and 1,156
  transpiler outputs; all unit tests passed.
- Added `PREPARE_FROM_SUGGESTIONS`, `PREPARE_FROM_SELECTED_SOURCES`, and
  `PREPARE_FROM_QUOTA_SPLITS` to the purchase-requisition service. They validate
  and map direct replenishment rows, caller-selected sources, or reconciled
  quota shares into the exact PR request without an API call. All matching
  create methods now submit those prepared requests, preserving source indexes
  and unit conversions. Tests cover split quantities, source/unit mapping,
  quota reconciliation, and no-write preparation. `npm.cmd test` passed with
  zero abaplint issues across 116 files and 1,156 transpiler outputs; all unit
  tests passed.
- Added `READ_CONFIRMATIONS_BULK` to retrieve production-operation time
  confirmations by order from AFRU and join AFVC for operation/sequence data.
  Results preserve confirmation number/counter, posting date, final flag, and
  reversal status; empty results are reported per order. The repository and
  service validate requested orders and returned confirmation keys.
  `npm.cmd test` passed with zero abaplint issues across 116 files and 1,156
  transpiler outputs; all unit tests passed.
- Added `READ_OPERATIONS_BULK` for production and process orders. It reads the
  AFKO routing key and joins AFVC to return ordered operations, including their
  internal counter, sequence, operation/suboperation numbers, description, and
  control key. Results preserve request order, report empty orders, and reject
  foreign or duplicate repository rows before grouping. `npm.cmd test` passed
  with zero abaplint issues across 116 files and 1,156 transpiler outputs; all
  unit tests passed. Target table/query details remain in `ANOMALIES.md`.
- Added per-operation production time-ticket confirmations through
  `BAPI_PRODORDCONF_CREATE_TT`. Requests carry the order, operation and
  sequence, posting date, yield/scrap/rework quantities, ISO unit, final flag,
  and optional reservation clearing. The adapter closes each SAP LUW directly
  after the BAPI call; the service maps detail-return keys and messages and
  continues after failures. Local validation, mapper, bulk continuation, and
  commit-failure tests were added; SAP's BAPI call and automatic inventory
  effects still require target-system verification.
- Added atomic and per-confirmation bulk cancellation through
  `BAPI_PRODORDCONF_CANCEL`. Requests require unique confirmation/counter pairs
  and a posting date; the service maps SAP messages, shares rollback for atomic
  groups, and commits bulk cancellations independently while continuing after
  errors. `npm.cmd test` passed: abaplint found zero issues across 116 files,
  transpilation wrote 1,151 outputs, and all 1,024 ABAP Unit methods passed.
- Added atomic and per-operation bulk release for production-order operations
  through `BAPI_PRODORD_RELEASE_OPERATION`. Requests use unique order/operation
  keys and four-character internal operation numbers; atomic release shares one
  commit/rollback while bulk release commits each operation and continues after
  errors. Adapter tests cover detail-message mapping; service tests cover
  commits, rollback, continuation, and key validation. `npm.cmd test` passed:
  abaplint found zero issues across 116 files, transpilation wrote 1,151
  outputs, and all 1,019 ABAP Unit methods passed.
- Added atomic and per-order bulk quantity/date changes for production orders
  through `BAPI_PRODORD_CHANGE`. Requests explicitly select quantity with its
  unit, basic start date, and/or basic finish date; the adapter sets matching
  X-structure flags. The service prevalidates the full request, supports shared
  rollback or independent commits, and continues bulk processing after
  failures. `npm.cmd test` passed: abaplint found zero issues across 116 files,
  transpilation wrote 1,150 outputs, and all 1,014 ABAP Unit methods passed.
- Extended `ZCL_PROD_ORDER_READ_SERVICE->READ_ORDERS_BULK` with active system
  and user statuses for production and process orders. The repository filters
  inactive JEST rows and resolves language-specific text from TJ02T or TJ30T;
  status codes remain available when a translation is missing. Added SAP table
  stubs for JEST and status texts, and extended AUFK with its object number and
  status profile. `npm.cmd test` passed: abaplint found zero issues across 116
  files, transpilation wrote 1,148 outputs, and all 1,007 ABAP Unit methods
  passed.
- Added atomic and per-order bulk deletion-indicator operations for production
  orders through `BAPI_PRODORD_SET_DEL_INDICATOR`. They apply DLT after SAP has
  set DLFL; atomic mode shares one commit/rollback, while bulk mode continues
  after per-order failures. Tests cover adapter mapping, rollback, commit
  failures, continuation, and prevalidation. `npm.cmd test` passed: abaplint
  found zero issues across 116 files, transpilation wrote 1,145 outputs, and
  all 1,006 ABAP Unit methods passed.
- Added `CLOSE_ORDERS_ATOMIC` and `CLOSE_ORDERS_BULK` to the production-order
  service through `BAPI_PRODORD_CLOSE`. Atomic close shares one commit and
  rolls back the group on a BAPI or commit error; bulk close commits each order
  and continues after failures. Tests cover mapping, rollback, continuation,
  commit errors, and request validation. `npm.cmd test` passed: abaplint found
  zero issues across 116 files, transpilation wrote 1,145 outputs, and all
  1,000 ABAP Unit methods passed.
- Added `ZCL_PROD_ORDER_READ_SERVICE->READ_ORDERS_BULK` for production and
  process orders. It groups all AFPO output items under each requested order
  while preserving request order. It converts ordered, received, and open
  quantities to the material base unit,
  and exposes basic dates and raw order/item indicators. Missing orders and
  unit conversion failures are counted separately; duplicate or blank keys
  fail before the repository query. `npm.cmd test` passed: abaplint reported
  zero issues across 116 files, transpilation wrote 1,145 outputs, and all 978
  ABAP Unit methods passed.
- Added `RELEASE_ORDERS_BULK_AFTER_ATP` to the production-order service. It
  validates the complete ATP response before writing, skips orders with short
  components, then releases each ready order with an independent commit while
  continuing after release/commit failures. Results keep original request
  indexes and per-order readiness, release, and commit status. Tests cover a
  mixed ready/short request, continuation after a release error, incomplete
  checker results, and missing checker configuration. `npm.cmd test` passed:
  abaplint reported zero issues across 116 files, transpilation wrote 1,145
  outputs, and all 982 ABAP Unit methods passed.
- Added atomic and per-order bulk technical completion for production orders
  through `BAPI_PRODORD_COMPLETE_TECH`. Atomic completion shares one commit and
  rolls back on the first BAPI/commit failure; bulk completion commits each
  order and continues after failures. Tests cover shared rollback, continuation
  after a completion and commit error, and prevalidation. `npm.cmd test` passed:
  abaplint reported zero issues across 116 files, transpilation wrote 1,145
  outputs, and all 988 ABAP Unit methods passed.
- Added atomic and per-order bulk production-order deletion-flag operations
  through `BAPI_PRODORD_SET_DELETION_FLAG`. They validate the full key list
  before writing; atomic mode shares one commit/rollback, while bulk mode
  continues after per-order failures. Tests cover mapping, rollback, commit
  failures, continuation, and prevalidation. `npm.cmd test` passed: abaplint
  reported zero issues across 116 files, transpilation wrote 1,145 outputs,
  and all 994 ABAP Unit methods passed.
- Sales-order reads now expose rejected quantities in both the sales unit and
  material base unit. The adapter converts each rejected item using its
  sales-unit ratio, retains the rejection reason, and reports a failed read
  when conversion is unavailable. Added mapper tests for alternative-unit
  conversion and missing ratios. `npm.cmd test` passed: abaplint reported zero
  issues across 95 files, transpilation wrote 1,101 outputs, and all 925 ABAP
  Unit methods passed.
- Added `ZCL_PLANNED_ORDER_SERVICE` and a `BAPI_PLANNEDORDER_CREATE` adapter.
  `CREATE_FROM_SUGGESTIONS` maps in-house suggestions to one planned order per
  receipt lot, preserving required dates and source suggestion/lot indexes;
  `PREPARE_FROM_SUGGESTIONS` returns the exact validated per-lot requests and
  source indexes without calling SAP, so callers can review the payload before
  writing. `CREATE_ORDERS_ATOMIC` also accepts explicit requests. All orders
  share one commit, and create or commit failure rolls back the group and
  clears provisional order numbers. Tests cover BAPI field mapping, lot
  splitting, no-write preparation, source types, prevalidation, create failure,
  and commit failure.
  `npm.cmd test` passed: abaplint reported zero issues across 100 files,
  transpilation wrote 1,112 outputs, and all 933 ABAP Unit methods passed.
- Added `DELETE_ORDERS_ATOMIC` through `BAPI_PLANNEDORDER_DELETE`. It rejects
  blank or duplicate planned-order numbers before writes, stops on the first
  delete error, and shares one commit or rollback across the group. Tests cover
  successful batches, prevalidation, BAPI failure, and commit failure.
  `npm.cmd test` passed: abaplint reported zero issues across 100 files,
  transpilation wrote 1,112 outputs, and all 937 ABAP Unit methods passed.
- Added `CREATE_ORDERS_BULK` and `DELETE_ORDERS_BULK` for planned orders. Both
  prevalidate the complete list, commit each operation independently, continue
  after BAPI or commit failures, and return per-row status plus success/failure
  counts. Tests cover individual commits, failure continuation, and clearing
  provisional create numbers and delete rollback after commit errors.
  `npm.cmd test` passed:
  abaplint reported zero issues across 100 files, transpilation wrote 1,112
  outputs, and all 942 ABAP Unit methods passed.
- Added `CREATE_FROM_SUGGESTIONS_BULK` for planned-order receipt lots. It uses
  the validated suggestion-to-lot preparation path, commits each lot
  independently, and retains the original suggestion and receipt indexes in
  each row so partial completion can be reconciled. Its test covers multiple
  lots, independent commits, a failed lot, continuation, and source index
  mapping. `npm.cmd test` passed: abaplint reported zero issues across 100
  files, transpilation wrote 1,112 outputs, and all 943 ABAP Unit methods
  passed.
- Added atomic and bulk planned-order changes through
  `BAPI_PLANNEDORDER_CHANGE`. Requests explicitly select quantity, start and
  finish dates, and firming state, reject blank, duplicate, ambiguous, or invalid updates
  before writes, and expose per-order commit status in bulk mode. Adapter tests
  cover field mapping and update flags; service tests cover group rollback,
  per-order continuation, and commit failures. `npm.cmd test` passed: abaplint
  reported zero issues across 100 files, transpilation wrote 1,114 outputs, and
  all 950 ABAP Unit methods passed.
- Added `READ_ORDERS_BULK` for planned orders. It reads requested headers in a
  single `PLAF` query, returns rows in input order, exposes fixed/scenario/
  special-stock/assignment state, and converts quantities to the material base
  unit when `MARM` has a valid ratio. Missing numbers and failed conversions are
  explicit per-row results; blank and duplicate inputs fail before the query.
  Tests cover ordering, conversion, missing orders, missing ratios, duplicate
  validation, and empty input. `npm.cmd test` passed: abaplint reported zero
  issues across 104 files, transpilation wrote 1,121 outputs, and all 955 ABAP
  Unit methods passed.
- Extended planned-order changes to update the start date through
  `BAPIPLAF_I2-ORDER_START_DATE` and its X flag. Selected dates must be supplied;
  a start date supplied without its change flag is rejected. Mapper and service
  tests cover start/end scheduling fields and prevalidation. `npm.cmd test`
  passed: abaplint reported zero issues across 104 files, transpilation wrote
  1,121 outputs, and all 955 ABAP Unit methods passed.
- Added planned-order conversion through `BAPI_PRODORD_CREATE_FROM_PLORD`.
  `CONVERT_PLANNED_ORDERS_ATOMIC` validates all order numbers before one shared
  commit and clears provisional production-order numbers after rollback.
  `CONVERT_PLANNED_ORDERS_BULK` commits each conversion independently, continues
  after failures, and returns per-order commit results and counts. SAP-side BAPI
  availability and LUW behavior remain target-release checks recorded in
  `ANOMALIES.md`. `npm.cmd test` passed: abaplint reported zero issues across
  104 files, transpilation wrote 1,121 outputs, and all 960 ABAP Unit methods
  passed.
- Added `ZCL_PROD_ORDER_SERVICE` release operations through
  `BAPI_PRODORD_RELEASE`. Atomic release sends the full validated order list in
  one BAPI call and commit; bulk release commits each order independently and
  continues after failures. Both require a caller-supplied SAP release-control
  value, map per-order BAPI messages, and reject blank or duplicate keys before
  writing. Added local DDIC stubs for the BAPI order key, detail return, and
  application log. `npm.cmd test` passed: abaplint reported zero issues across
  109 files, transpilation wrote 1,133 outputs, and all 967 ABAP Unit methods
  passed.
- Added `RELEASE_ORDERS_AFTER_ATP`. A configured component ATP checker runs the
  existing bulk ATP preview and produces per-order readiness totals. The
  release service calls `BAPI_PRODORD_RELEASE` only when every open component
  is fully confirmed; incomplete or malformed readiness data blocks the call.
  Tests cover the fully confirmed path, a short component, missing rows,
  summary mapping, and orders without open components. `npm.cmd test` passed:
  abaplint reported zero issues across 112 files, transpilation wrote 1,138
  outputs, and all 972 ABAP Unit methods passed.
- Added demand-to-source reconciliation before ordinary STO writes. Single-pair,
  one-target multi-source, and multi-target pair creation now reject source
  plant rows that do not match each demand's allocated base quantity. A
  tampered-total test confirms rejection before the first order call. `npm.cmd
  test` passed: abaplint reported zero issues across 94 files, transpilation
  wrote 1,099 outputs, and all 922 ABAP Unit methods passed.
- Extended undated exact-batch STO creation to retain issuing-location splits as
  separate PO items with `SUPPL_STLOC`. Before writing, demand quantities must
  match source-plant totals, and source-plant totals must match location splits
  when they are supplied. Legacy results without location detail keep their
  plant-level item mapping. The same increment keeps dated FEFO total checks at
  the shared STO boundary and corrects fixtures that mixed source-unit values
  with base-unit totals. `npm.cmd test` passed: abaplint reported zero issues
  across 94 files, transpilation wrote 1,099 outputs, and all 921 ABAP Unit
  methods passed.
- Hardened dated exact-batch STO input validation: demand base quantities must
  reconcile to source-plant splits, then to location splits, before creating
  orders. Added tampered-summary and tampered-location rejection cases.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 917 ABAP Unit methods passed.
- Added `create_dated_batch_pairs` for date/priority exact-batch previews. It
  maps each selected batch and issuing location to an STO item with the
  request's required date, and preserves one shared atomic commit across all
  source/target pairs. Tests cover multiple required dates in one pair order.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 916 ABAP Unit methods passed.
- Added `create_dated_batch_atp_pairs` to prevalidate full cumulative ATP
  confirmation for every material/source-plant/base-unit/date group before
  creating any STO. It keeps each selected exact batch and issuing location,
  puts the required date on its item, and uses one shared commit in atomic mode.
  Tests cover a multi-date order and reject short confirmation before writes.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 915 ABAP Unit methods passed.
- Added date- and priority-ordered exact-batch cross-plant allocation, including
  the alternative-unit wrapper and `allocate_plants_date_batch_atp`. ATP checks
  group positive local allocations by material, source plant, base unit, and
  required date, accumulating quantities through each date; the local exact
  batch splits remain unchanged. Tests cover date/priority allocation order,
  mixed-unit cumulative checks, and invalid ATP rules before reads. `npm.cmd
  test` passed: abaplint reported zero issues across 94 files, transpilation
  wrote 1,099 outputs, and all 913 ABAP Unit methods passed.
- Added `allocate_plants_fefo_atp` for undated unit-aware cross-plant FEFO
  allocations. It retains local batch/location splits and groups positive source
  allocations by material, source plant, and base unit for current-date SAP ATP
  checks. ATP remains separate from batch selection and local quantities. Tests
  cover invalid options before reads, full-quantity shortfall skipping ATP,
  mixed-unit groups, and confirmation splitting. `npm.cmd test` passed:
  abaplint reported zero issues across 94 files and transpilation wrote 1,099
  outputs; all 901 ABAP Unit methods passed.
- Added `create_for_fefo_atp_pairs` to turn undated FEFO ATP results into STOs.
  It validates full ATP confirmation for each material/source-plant/base-unit
  group before any BAPI write, assigns the caller's delivery date to every
  selected batch item, and retains source-unit quantities and atomic commit
  support. Tests cover batch and UOM item mapping, delivery date, shared commit,
  and short ATP rejection before writes. `npm.cmd test` passed: abaplint reported
  zero issues across 94 files, transpilation wrote 1,099 outputs, and all 903
  ABAP Unit methods passed.
- Added `allocate_plants_batch_atp` for unit-aware exact-batch cross-plant
  allocation. It preserves batch/location splits and groups positive source
  quantities by material, source plant, and base unit for current-date SAP ATP
  checks. Tests cover mixed-unit batches, grouped requests, partial confirmation,
  and check-rule rejection before reads. `npm.cmd test` passed: abaplint reported
  zero issues across 94 files, transpilation wrote 1,099 outputs, and all 905
  ABAP Unit methods passed.
- Added `create_for_atp_batch_pairs` for exact-batch ATP results. It requires a
  matching, fully confirmed ATP check for every positive material/source-plant/
  base-unit group before creating orders, then carries the caller's delivery
  date, exact batches, source units, receiving locations, and atomic commit
  behavior into the STOs. Tests cover multi-pair batch item mapping and reject a
  short confirmation before writes. `npm.cmd test` passed: abaplint reported
  zero issues across 94 files, transpilation wrote 1,099 outputs, and all 907
  ABAP Unit methods passed.
- Added `iv_include_undated_batches` to single-plant and cross-plant FEFO
  previews, including UOM, dated, and ATP wrappers. It defaults to true;
  setting it false removes undated batches from eligible availability,
  safety-stock handling, and allocation splits. Invalid values fail before UOM
  or stock reads. `npm.cmd test` passed: abaplint reported zero issues across
  94 files, transpilation wrote 1,099 outputs, and all 900 ABAP Unit methods
  passed.
- Extended `iv_require_full_quantity` across single-plant ordinary, dated,
  storage-location, exact-batch, and FEFO allocation, including unit-aware and
  ATP wrappers where available. A demand that exceeds remaining eligible stock
  receives zero local allocation, so later rows can use the unchanged balance;
  the default still permits partial allocation. Invalid values fail before UOM
  or stock reads. Dated ATP still checks the requested quantity. `npm.cmd test`
  passed: abaplint reported zero issues across 94 files, transpilation wrote
  1,099 outputs, and all 898 ABAP Unit methods passed.
- Added opt-in `iv_require_full_quantity` to undated and dated cross-plant
  ordinary, exact-batch, and FEFO allocation, including unit and ATP variants.
  The default keeps partial allocation; when enabled, insufficient requests
  allocate zero and leave stock for later demands after all source, location,
  safety-stock, batch, shelf-life, and date rules are applied. ATP wrappers
  check only positive local splits. Tests cover no-consumption-on-shortfall,
  later-demand reuse, unit forwarding, dated FEFO, ATP skipping, and invalid
  flags before reads. `npm.cmd test` passed: abaplint reported zero issues
  across 94 files, transpilation wrote 1,099 outputs, and all 895 ABAP Unit
  methods passed.
- Added `allocate_plants_atp` for undated unit-aware cross-plant allocation.
  It groups positive local source splits by material, source plant, and base
  unit, checks SAP ATP once per group for the current date, and returns capped
  confirmed/unconfirmed base quantities alongside the unchanged local estimate.
  Missing check rules fail before stock/UOM reads. Tests cover mixed input units,
  grouped ATP requests, partial confirmations, and pre-read rejection.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 892 ABAP Unit methods passed.
- Added per-request, per-source-plant `it_source_locations` scopes to ordinary,
  exact-batch, and FEFO cross-plant allocation and their unit-aware variants.
  The scopes intersect the existing shared allowlist and location priority;
  when supplied, every source pair must have at least one mapped location.
  Duplicate, blank, and unmapped entries fail before stock/UOM reads, while
  safety stock remains based on each full source-plant balance. Tests cover all
  six allocation paths and pre-read validation. `npm.cmd test` passed: abaplint
  reported zero issues across 94 files, transpilation wrote 1,099 outputs, and
  all 890 ABAP Unit methods passed.
- Extended `it_allowed_storage_locations` to ordinary, exact-batch, and FEFO
  cross-plant allocations and their unit-aware variants. The shared list filters
  candidate locations in every source plant; empty or omitted lists leave all
  locations eligible. Safety stock is still deducted from each full source-plant
  balance before filtering. Tests cover ordinary, batch, FEFO, and UOM paths.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 886 ABAP Unit methods passed.
- Added optional `it_storage_location_priority` to ordinary, exact-batch, and
  FEFO cross-plant allocations and their unit-aware variants. Source-plant order
  remains primary; ordinary and exact-batch paths prefer listed locations,
  while FEFO uses location order only for the same batch and expiration date.
  The existing allowlist still filters both availability and allocation, and
  invalid priorities fail before stock/UOM reads. Tests cover priority order,
  allowlist interaction, FEFO ties, unit-aware forwarding, and pre-read checks.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 886 ABAP Unit methods passed.
- Extended caller location priority to dated cross-plant FEFO and its unit-aware
  and ATP variants. Location order breaks ties only for the same batch and
  expiration date; required-date, source-plant, expiry, and batch order stay
  primary. Duplicate priorities fail before stock or UOM reads. Tests cover
  base-unit selection, UOM and ATP forwarding, allowlist interaction, and
  pre-read validation.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 888 ABAP Unit methods passed.
- Added optional `it_allowed_storage_locations` filtering to single-plant
  location, exact-batch, and FEFO allocation. Empty or omitted lists preserve
  unrestricted behavior; blank and duplicate entries are rejected before
  stock/UOM reads, and a preferred location outside a nonempty list is rejected.
  Caller priority orders only allowed candidates. Safety stock remains deducted
  from the full inventory balance before candidate filtering. Forwarded the
  option through sales-order preview/reservation, cost-center previews, atomic
  reservations, and single cost-center paths. Added unit tests for filtered
  stock splits, exact batch/FEFO filtering, pre-read validation, and wrapper
  propagation. `npm.cmd test` passed: abaplint reported zero issues across 94
  files, transpilation wrote 1,099 outputs, and all 882 ABAP Unit methods
  passed.
- Added caller-defined storage-location priority to
  `allocate_by_storage_location` and its unit-aware variant. Explicit per-demand
  locations remain first; listed fallback locations follow caller order, then
  unlisted locations follow ascending code order. Blank and duplicate priority
  entries are rejected before repository reads. The option now passes through
  sales-order preview/reservation, cost-center location, batch, and FEFO
  previews, atomic reservations, and single cost-center preview/reservation.
  Explicit preferred locations remain first. FEFO expiration and batch order
  remain primary, with location priority resolving same-batch, same-expiration
  ties. Tests cover wrapper forwarding, preferred-location precedence, custom
  fallback order, UOM forwarding, and duplicate rejection.
- Extended exact-batch stock allocation with the caller-defined storage-location
  priority. Preferred locations remain first, listed fallback locations follow
  caller order, and unlisted locations follow the existing ascending-code order.
  The option is available in base and unit-aware stock allocation and passes
  through sales-order and cost-center exact-batch flows. Tests cover split order,
  selected-batch isolation, unit-aware preview forwarding, and reservation
  forwarding.
- Extended FEFO stock allocation with location-priority tie-breaking. Expiration
  date and batch remain primary; the caller order resolves locations only for
  matching batch/date rows, while a demand's preferred location remains first.
  The option passes through the unit-aware, sales-order, and cost-center FEFO
  paths. `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and ABAP Unit completed successfully.
- Expanded dated open production receipts to include released process orders
  (`AUFK-AUTYP = 40`) alongside PP production orders (`AUTYP = 10`). The
  projection keeps its existing opt-in flag and quantity/date rules, and labels
  rows as `PROCESS_ORDER` so callers can distinguish their source. SAP table
  joins and release-phase behavior still need validation on the target release;
  see `ANOMALIES.md`.
- Added `iv_test_run` to STO item deletion and delivery completion, including
  the single-pair and atomic pair methods. Both adapters pass `TESTRUN` to
  `BAPI_PO_CHANGE`; successful simulations set `is_successful` and
  `is_test_run`, leave `is_deleted`/`is_completed` false, and skip
  commit/rollback. Atomic simulations validate all pairs independently and
  preserve each pair's outcome, including after a failed pair. Tests cover
  forwarding, success/error result flags, continued validation, transaction
  suppression, and invalid flags. `npm.cmd test` passed: abaplint reported zero
  issues across 94 files, transpilation wrote 1,099 outputs, and ABAP Unit
  completed successfully. Target BAPI behavior and messages remain to be
  confirmed; see `ANOMALIES.md`.
- Added `iv_test_run` to PO item deletion, delivery completion, schedule changes,
  item quantity changes, and their bulk, atomic, and base-unit variants. The BAPI
  adapter forwards the flag to `BAPI_PO_CHANGE`; simulations return per-PO
  messages and skip commit/rollback. Atomic simulations validate each PO call
  independently and do not establish multi-PO commit behavior. Invalid flags are
  rejected before reads or writes. Tests cover service flag forwarding, single
  and atomic simulations, transaction suppression, and invalid-flag rejection.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and ABAP Unit completed successfully.
  `BAPI_PO_CHANGE` test-run behavior and returned messages still need validation
  on the target SAP release; see `ANOMALIES.md`.
- Added `iv_include_po_confirmations` to the standard projected-receipt APIs,
  including base-unit, requested-unit, global bulk, and per-request option
  variants. Bulk option requests can select different PO projections for the
  same material/plant; each request rejects selecting both regular and
  confirmation-aware PO receipts. Added the option to single, grouped,
  unit-aware, ATP, and cross-plant dated allocation; grouped demands share one
  confirmation projection per material/source plant through the latest demand
  date. Tests cover source merging, UOM conversion, deadline filtering, grouped
  queries, chronological netting, source-plant allocation, and conflicting-
  source validation. `npm.cmd test` passed with zero abaplint issues across 94
  files and 1,099 transpiler outputs. EKES/EKET confirmation semantics still
  need target-SAP validation as recorded in `ANOMALIES.md`.

## 2026-10-03

- Added `SIMULATE_SPLIT_QUOTA` for a bounded split preview over one request's
  quota-assigned standard vendor candidates. It checks shared arrangement and
  base-unit context, distributes by quota value, uses the maintained
  `EQUK-SCMNG` minimum split quantity (with an optional caller override) for
  small requests and trailing remainders, and returns each positive source
  split with its candidate. The caller confirms that split-quota customizing
  applies. Added tests for candidate propagation, a four-source split,
  below-minimum routing, and unit mismatch. SAP source
  rating recalculation, per-source lot sizes/capacity, and quota maximums
  remain outside the preview; see `ANOMALIES.md`.
- Added quota-item priority to PIR candidates and split ordering. Sources with
  a maintained priority are ordered ahead of unprioritized sources, smallest
  number first; ties and unprioritized rows follow quota value. Split amounts
  remain quota-ratio based. Tests cover priority propagation and an override of
  the default quota order without changing the calculated share, including
  multiple priority values and below-minimum allocation selection.
- Applied quota-item `MINLS`/`MAXLS` to split proposal quantities and carried
  the maintained once-only indicator. Results now distinguish demand-share
  `allocated_quantity` from source-adjusted `proposal_quantity`; max lots expand
  into multiple rows and minimum lots can exceed their demand share. An
  only-once source whose share exceeds its max is rejected because overflow
  redistribution and quota re-evaluation are not modeled. Tests cover field
  propagation, min/max lot behavior, and once-only rejection.
- Verification after split quota threshold, priority, and lot-size support: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 707 objects, and
  all 453 ABAP Unit methods passed. `git diff --check` passed.

## 2026-10-02

- Added opt-in projection of dated stock-transfer schedule quantities that
  have not yet been issued. The stock repository calculates the difference
  between `EKET-MENGE` and `EKET-WAMNG`, converts it to the material base unit,
  and shares the existing STO filters and schedule-date cutoff. It skips items
  marked completely delivered and can be combined with issued in-transit
  quantities.
- Carried the option through single, bulk, unit-aware, ATP, and cross-plant
  dated allocation methods. Added quantity-calculator and local allocation
  tests for default-off behavior, alternative STO states, and combined totals.
- Target-system verification remains necessary for STO query filters and
  schedule-line quantity/unit semantics; local tests use repository doubles.
- Verification: `npm.cmd test` passed; abaplint reported zero issues across 64
  files, and the transpiler ran all 332 ABAP Unit methods.
- Added `iv_subtract_unissued_sto` to subtract open outbound STO schedule
  quantities from the supplying plant's dated balance. The amount is
  `EKET-MENGE - EKET-WAMNG`, converted to the material base unit and scoped by
  `EKKO-RESWK`, with STO item/document filters and a due-date cutoff. It is
  opt-in and carried through single, bulk, unit-aware, ATP, and cross-plant date paths.
  Added service coverage for single requests, shared bulk priority, and
  cross-plant source balances.
- Verification after outgoing STO deductions: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 333 ABAP
  Unit methods.
- Added `preview_orders_by_date` for multi-sales-order dated allocation. Open
  items share each material/plant balance, requested dates determine priority,
  and document/item order resolves same-date ties. The preview subtracts each
  order's active reservations, returns sales- and base-unit summaries, and
  supports confirmed-demand sizing plus optional dated receipts, STO
  quantities, production receipts, safety-stock protection, and cumulative
  SAP ATP checks. Added coverage for shared stock, confirmed quantities, ATP
  aggregation, and sales-unit conversions across orders.
- Verification after multi-order dated preview: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 335 ABAP
  Unit methods.
- Added `reserve_orders_by_date` to reserve positive allocations from the
  shared multi-order date plan. It supports simulation and full-allocation
  enforcement, sends all line requests through one reservation transaction,
  and rolls back if creation or commit fails. Allocation results now retain
  required dates for reservation mapping. Tests cover cross-order quantities,
  full-allocation rejection, simulation, and create/commit rollback.
- Latest verification after multi-order reservation support: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files, and the transpiler ran
  all 340 ABAP Unit methods.
- Sorted multi-order reservation requests by material, plant, and required
  date so API calls follow the same due-date priority as shared-stock planning;
  stable sorting preserves caller order for ties. Added a regression test with
  input document/date order reversed.
- Verification after due-date-ordered reservation submission: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files, and the transpiler ran
  all 341 ABAP Unit methods.
- Added reservation-response reconciliation to both single- and multi-order
  flows. Each returned row must match one pending request by request ID,
  quantity, date, and any explicit storage location or batch; regular runs also
  require a reservation number. A mismatch rolls back before commit. Added a
  malformed cross-order response test.
- Verification after reservation-response validation: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files, and the transpiler ran all
  342 ABAP Unit methods.
- Added a bulk sales-order reservation query and used it in multi-order dated
  previews, replacing one reservation read per order with one keyed query.
  Empty document lists return without running the database selection; the
  preview validates blank and duplicate keys before the bulk call. Added tests
  for per-order matching and read-count reduction.
- Verification after bulk reservation reads: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 343 ABAP
  Unit methods.
- `reserve_orders_by_date` now accepts the preview's optional cumulative ATP
  diagnostics and returns them beside its reservation results. The diagnostics
  remain separate from local allocation and the reservation API's own ATP
  checks. Extended cross-order reservation coverage for shared-date ATP totals.
- Verification after ATP diagnostics on multi-order reservation: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files, and the transpiler ran
  all 343 ABAP Unit methods.
- Replaced multi-order request-context scans with a hashed request-ID index
  and sorted bulk-reservation rows by sales document, avoiding repeated full
  table scans while retaining caller and date priority.
- Verification after keyed multi-order lookups: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 343 ABAP
  Unit methods.

## 2026-09-23

- Sales-order reads retain the `BAPISDIT-SALES_QTY1/SALES_QTY2` conversion
  ratio. Preview and reserve results now include sales-unit allocation
  summaries while keeping allocations and reservation requests in the base
  unit. Alternative-unit lines without a usable ratio fail before stock reads.
- Added tests for sales-unit requested, available, allocated, and shortfall
  quantities, reserve-result propagation, and missing-ratio rejection.
- Added cross-plant allocation preview with ordered source-plant splits,
  source-location splits, shared source balances across demand rows,
  per-demand shortfalls, optional source safety-stock protection, and input
  validation before stock reads. The preview does not create transfers or
  reservations.
- Added test coverage for ordered location splits and protected source-plant
  safety stock.
- Added `allocate_plants_in_units`, which caches unit ratios, converts demand
  before stock reads, and returns source-unit and base-unit demand, plant, and
  location quantities. Added allocation and unknown-unit rejection tests.
- Added exact-batch allocation across source plants with per-plant and
  batch/location splits, optional source safety-stock protection, and tests for
  source priority, shared stock, batch preservation, safety-stock protection,
  and missing-batch rejection.
- Added `allocate_plants_batch_in_units` for exact-batch cross-plant demands in
  material-specific units. It caches and validates ratios before stock reads
  and returns converted demand, plant, and location quantities. Added tests for
  shared converted allocations and unknown-unit rejection.
- Added cross-plant FEFO allocation with caller-ordered source plants,
  minimum-shelf-life filtering, optional safety-stock protection, and
  batch/location detail. Added tests for FEFO ordering and invalid input.
- Added `ALLOCATE_PLANTS_FEFO_IN_UNITS` to convert alternative-unit cross-plant
  FEFO demands before stock reads and return both unit views for demand, plant,
  and batch/location results. Added tests for shared stock across plants,
  FEFO/minimum-shelf-life filtering, rounded source units, and unknown units.
- Added opt-in confirmed-demand sizing for sales-order previews and reservations
  using schedule-line confirmed quantities, capped at ordered open quantities.
  Confirmed demand is converted to the material base unit; open item-level
  fallback rows are rejected before stock reads. Added preview, reservation,
  alternative-unit summary, and missing-schedule tests.
- Added `TRANSFER_PLANT_ALLOCATION`, which validates cross-plant demand and
  location splits and posts them as one 301 goods movement using per-request
  destination locations and per-material base-unit/ISO mappings. Complete
  allocation is required by default, with an explicit partial-transfer option.
  Added tests for multiple source splits, success, shortfall rejection, and
  inconsistent split rejection.
- Added `TRANSFER_PLANT_BATCH_ALLOC` and `TRANSFER_PLANT_FEFO_ALLOC` to post
  exact-batch and FEFO cross-plant location splits while preserving batch IDs.
  Shared demand/split validation with the non-batch bridge. Added tests for
  exact-batch and multi-batch FEFO transfers, shortfall rejection, split
  mismatch, and missing-batch rejection.
- Added `TRANSFER_PLANT_UNITS_ALLOC` and `TRANSFER_PLANT_BATCH_UNITS` so
  unit-aware cross-plant allocation results post directly from canonical
  base-unit split quantities. The service checks result base units against the
  supplied material-unit mapping. Added tests for non-batch splits, batch
  preservation, base-unit quantities, and mapping mismatch rejection.
- Added `TRANSFER_PLANT_FEFO_UNITS` to post unit-aware FEFO cross-plant splits
  as a single 301 movement, retaining batch IDs and canonical base-unit
  quantities. Added success and base-unit mismatch tests.
- Resolved the earlier schedule-date note: schedule-line dates now pass into
  reservations; confirmed delivery dates remain outside the read model.
- Latest verification: `npm.cmd test` passed; abaplint reported zero issues
  and the transpiler ran all 241 ABAP Unit test methods.

## 2026-09-22

- Bootstrapped abaplint and open-abap transpiler configuration with the required
  `open-abap-core` dependency.
- Added a local SAP `MARD` dictionary stub in `stubs/` and included that directory
  in both lint and transpiler inputs.
- Pointed abaplint at the existing local `open-abap-core` checkout and enabled
  every additional rule requested in `PLAN.md`.
- Added the first feature: read unrestricted-use quantity (`MARD-LABST`) for a
  material and plant through an injectable stock repository.
- Added service unit tests for a positive stock quantity and a zero-stock case.
- Added allocation previews that cap an individual request to available stock,
  report a shortfall, treat negative stock as unavailable, and reject negative
  requested quantities.
- Added ordered multi-line allocation with per-material/plant stock caching so
  repeated demand lines cannot allocate the same stock more than once.
- Added confirmed goods-movement posting through `BAPI_GOODSMVT_CREATE`, with
  test-run support, validation for cost center, order, and sales order goods
  issues plus one-step storage/plant transfers, and commit/rollback handling
  through an injectable API.
- Added sales-order item reads through `BAPISDORDER_GETDETAILEDLIST` and sales
  order create/change through `BAPI_SALESORDER_CREATEFROMDAT2` and
  `BAPI_SALESORDER_CHANGE`, with test-run support and transaction handling.
- Added partial local DDIC stubs for the BAPI structures used by the adapters.
- Added a material-unit converter that reads the base unit from `MARA` and uses
  the sales-to-stockkeeping-unit ratio returned on each sales order item.
- Sales-order reads now retain the requested sales-unit quantity and add its
  converted base-unit quantity; reads fail when an alternative-unit item has
  no usable ratio or material base unit.
- Added open-demand quantities by reading delivered quantity and item delivery
  status from `VBAP` and `VBUP`; complete and non-delivery items return zero,
  while open and partially delivered items subtract delivered quantity from
  requested quantity and clamp over-delivery to zero.
- Added an order allocation preview that converts positive open base-unit
  quantities into prioritized batch demands and keys results by sales document
  and item. Failed reads and open lines missing material, plant, or base unit
  do not reach the stock repository.
- Added `reserve_order` to create movement type 231 reservations for each
  positively allocated sales order item with `BAPI_RESERVATION_CREATE1`. The
  BAPI ATP check is enabled, all item reservations share one commit/rollback
  boundary, and test runs do not commit.
- Stock availability now subtracts undelivered quantities of active, non-deleted
  unrestricted-stock reservations in `RESB` from physical unrestricted stock
  in `MARD`. The quantity calculator clamps negative balances to zero.
- Added storage-location stock reads grouped from `MARD` and `RESB`. Allocation
  consumes locations in ascending `LGORT` order, returns the quantity split by
  location, and reserves each positive split against its source location.
- Plant-level reservations without `LGORT` are deducted from available
  storage locations in ascending location-code order. This preserves the total
  free quantity but is a deterministic estimate of location-level availability.
- Extracted location balance calculation into a pure class with unit tests for
  location reservations, plant-level reservations, and over-reserved locations.
- Added partial local stubs for `BAPI2093_RES_HEAD`, `BAPI2093_RES_ITEM`,
  `BAPI2093_ATPCHECK`, `BAPI2093_RES_KEY`, and the queried `RESB` fields.
- Added reservation API fakes and tests for partial allocation reservation,
  simulation, create errors, commit errors, and failed sales-order reads. Added
  helper tests for open-reservation subtraction and stock balance clamping.
- Remaining reservation limits: schedule-line requirement dates are not read,
  so reservation items currently use today's date. Stock checks subtract open
  `RESB` reservations but do not reproduce all SAP ATP/customizing rules; the
  BAPI ATP behavior and movement type must be validated in the target release.
- Added a local `MARA` stub, the conversion fields to the partial `BAPISDIT`
  stub, partial `VBAP` and `VBUP` stubs, and tests for unit conversion and open
  quantity status rules.
- Verification before the reservation feature: `npm.cmd test` passed; abaplint
  reported zero issues and the transpiler ran all 42 ABAP Unit test methods.
- Remaining integration work: validate adapter calls, `BAPISDIT` conversion
  fields, the `VBAP`/`VBUP` reads, and reservation behavior against the target
  SAP release. Schedule-line-specific confirmed quantities are not yet used.
  No live SAP system was available for posting or interface validation.
- Latest verification after location-aware allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 56 ABAP Unit methods.
- Added reservation release by reservation number through
  `BAPI_RESERVATION_DELETE`, with duplicate/blank input validation, simulation,
  and one commit/rollback boundary for the requested list. Added service tests
  for success, simulation, deletion errors, commit errors, and invalid input.
- SAP decides whether each complete reservation document is eligible for
  deletion; no live system was available to verify delete behavior or the
  target release's exact BAPI signature.
- Latest verification after reservation release: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 61 ABAP Unit methods.
- Added reservation detail reads through `BAPI_RESERVATION_GETDETAIL1` with an
  injectable reader adapter. Results include reservation item identity, record
  type, status flags, requested and withdrawn quantities, and material/location
  details. Failed or empty reads do not expose partial item data.
- Latest verification after reservation inquiry: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 66 ABAP Unit methods.
- Added goods issue posting against reservation items through
  `BAPI_GOODSMVT_CREATE` using GM code 03. The service reads reservation
  details, validates issueable status and remaining base-unit quantity, uses
  the reservation's ISO base unit, and posts all requested items in one
  material document. Added tests for success, simulation, read errors,
  over-issue, closed items, and duplicates.
- Reservation-linked goods movement fields and quantity behavior still need
  validation against the target SAP release; local tests use API doubles.
- Goods movement requests now carry both the SAP entry unit and its ISO code;
  requests missing either value are rejected before calling the BAPI.
- Latest verification after reservation issue posting: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 74 ABAP Unit methods.
- Added batch stock reads from `MCHB-CLABS`, subtracting open reservation
  quantities by batch and storage location. Reservations missing either
  dimension are distributed deterministically across matching balances; excess
  over-reservation is deducted conservatively from remaining stock.
- Added exact-batch allocation previews with optional storage-location
  restriction, ordered demand consumption, location splits, caching, and
  shortfall reporting. A missing requested batch is rejected and another batch
  is never substituted. SAP automatic batch determination and non-batch-managed
  valuation-type allocation remain outside this feature.
- Latest verification after batch-aware allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 81 ABAP Unit methods.
- Added `ALLOCATE_BY_EXPIRY`, an explicit FEFO batch preview that sorts dated
  stock by expiration date, excludes dates earlier than its as-of date, puts
  undated batches last, and honors optional storage-location restrictions. The
  batch repository reads expiration from plant-level `MCHA-VFDAT`, falling back
  to material-level `MCH1-VFDAT`. This does not reproduce configurable SAP batch
  search strategies. Tests cover FEFO order, expired and undated batches,
  location filtering, and invalid input.
- Latest verification after FEFO preview: `npm.cmd test` passed; abaplint
  reported zero issues and the transpiler ran all 122 ABAP Unit methods.
- Added optional per-item batch choices to sales-order previews and reservation
  creation. Selected batches flow into `BAPI2093_RES_ITEM-BATCH`; partial or
  duplicate selection sets are rejected before reading stock or creating
  reservations. Added tests for a batch split across locations and incomplete
  item selection.
- SAP reservation documentation exposes batch and valuation-type requirements;
  with batch-managed split valuation, the supplied batch identifies the
  valuation type. Non-batch valuation-type allocation remains unmodeled.
- Latest verification after batch-aware order reservations: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 83 ABAP Unit
  methods.
- Sales-order reads now expand schedule lines from `VBEP`, calculate each
  line's open quantity from `WMENG - VSMNG`, and carry its requested date into
  stock priority and reservation `REQ_DATE`. Items without schedule rows keep
  the prior item-level quantity behavior and current-date reservation default.
- Added a local `VBEP` stub and a reservation-flow test proving separate
  schedule-line allocations retain unique keys, due dates, and ordered stock
  priority. Confirmed schedule quantities/dates and live SAP query behavior
  remain to be validated.
- Latest verification after schedule-line-aware allocation: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 85 ABAP Unit
  methods.
- Batch selections for sales-order reservations can now be keyed by both item
  and schedule line, so one item may allocate different schedule lines from
  different batches. The existing item-only selection still applies one batch
  across all open schedule lines. Duplicate, partial, and mixed selection modes
  are rejected before stock access; tests cover different batches per line and
  incomplete schedule-line choices.
- Latest verification after schedule-line-specific batch selection:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 89 ABAP Unit methods.
- Added purchase-order goods receipt posting through the existing goods
  movement service. It requires GM code 01, movement type 101, movement
  indicator `B`, PO number/item, quantity, and entry unit; SAP can derive
  material, plant, and storage location from the PO item. Added service tests
  for a valid receipt, a missing PO item, a wrong GM code, and mixed PO/non-PO
  items in one request.
- Latest verification after purchase-order receipt support: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 93 ABAP Unit
  methods.
- Added `iv_require_full_allocation` to sales-order reservation creation. When
  enabled, any local preview shortfall prevents all reservation BAPI calls;
  the default still reserves partial quantities. Added tests for shortfall
  rejection and a fully covered order.
- Latest verification after full-allocation reservation mode: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 95 ABAP Unit
  methods.
- Added storage-location selections for sales-order previews and reservations.
  Choices can be keyed per schedule line or apply item-wide; selected locations
  are hard restrictions by default. `allow_fallback` makes a location the
  first preference before ascending-code fallback. Batch and location
  selections cannot be combined. Tests cover schedule-line and item-wide
  locations, incomplete choices, exclusivity, restricted shortfall, and
  preferred-location fallback.
- Latest verification after sales-order location selection: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 101 ABAP Unit
  methods.
- Added production-order goods receipts to the goods-movement service using GM
  code 02, movement type 101, movement indicator `F`, and the production order
  reference. The service validates receipt fields and prevents mixing these
  items with other movement modes. Tests cover a successful receipt, missing
  movement indicator, and mixed receipt/item movements.
- Latest verification after production-order receipt support: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 104 ABAP Unit
  methods.
- Added full material-document cancellation through `BAPI_GOODSMVT_CANCEL`.
  Callers provide the original material document and year, with an optional
  reversal posting date. The service validates the key, checks for a returned
  cancellation document, and commits or rolls back the BAPI transaction. Tests
  cover successful cancellation, a missing document key or return document,
  SAP errors, and commit failure.
- Latest verification after goods-movement cancellation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 109 ABAP Unit methods.
- Extended goods-movement cancellation to support selected material-document
  items through `BAPI_GOODSMVT_CANCEL`; an empty item list continues to cancel
  the full document. Duplicate or blank item numbers are rejected before the
  BAPI call. Added the standard `BAPI2017_GM_ITEM_04` structure stub and tests
  for selected-item forwarding and duplicate rejection.
- Latest verification after item-level cancellation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 112 ABAP Unit methods.
- Added PO-referenced returns to vendor with movement type 122, GM code 01,
  movement indicator `B`, and purchase-order/item references. The existing
  validation now permits both PO receipts (101) and returns (122), while
  rejecting a return with the wrong goods movement code. Tests cover posting
  and rejection before the BAPI call.
- Latest verification after PO returns: `npm.cmd test` passed; abaplint reported
  zero issues and the transpiler ran all 114 ABAP Unit methods.
- Added two-step stock transfers: plant removal/putaway with movement types
  303/305 and storage-location removal/putaway with 313/315. The service
  validates each movement's destination fields and posts each leg through the
  existing goods-movement transaction flow. Tests cover all four postings and
  missing destinations on the removal legs.
- Latest verification after two-step transfer support: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 116 ABAP Unit methods.
- Added a stock-in-transfer inquiry backed by `MARC-UMLMC` and `MARD-UMLME`.
  Callers can request one storage location or aggregate storage-location
  transfer quantities across the plant. In-transfer stock stays separate from
  allocatable unrestricted stock. Added partial standard table stubs and
  service tests for location selection and required keys.
- Latest verification after stock-in-transfer inquiry: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 119 ABAP Unit methods.
- Integrated FEFO batch allocation with sales-order preview and reservation via
  opt-in `iv_use_fefo_batches`; `iv_fefo_as_of_date` defaults to the current
  date. The resulting batch splits are passed into reservation requests without
  manual batch selections. FEFO can use a hard location restriction or honor
  `allow_fallback` by searching the preferred location first, then other
  locations in FEFO order. Explicit batch selections and FEFO mode are rejected
  together. Tests cover order preview, split reservations, preferred-location
  fallback, and conflicting inputs.
- Latest verification after FEFO sales-order integration: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 126 ABAP Unit methods.

## 2026-09-23

- Added opt-in safety-stock protection using static `MARC-EISBE`, exposed by
  `iv_protect_safety_stock` on stock allocation and sales-order preview and
  reservation methods. The flag defaults to false. Location and batch paths
  distribute the buffer deterministically; FEFO preserves earlier-expiring
  batches first.
- Added stock-level tests for unrestricted, location, exact-batch, and FEFO
  allocations, plus a sales-order reservation integration test. SAP ATP and
  time-dependent safety-stock behavior remain outside this calculation.
- Latest verification after safety-stock protection: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 131 ABAP Unit methods.
- Added a minimum remaining shelf-life filter to FEFO stock allocation and
  sales-order preview/reservation. The day count is measured from the as-of
  date; the boundary date is eligible, while undated batches are excluded when
  the count is positive. Positive counts require FEFO mode and negative counts
  are rejected before stock reads.
- Added unit and end-to-end tests for the cutoff boundary, undated stock,
  invalid inputs, preview output, and reservation batch selection.
- Latest verification after the FEFO shelf-life filter: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 136 ABAP Unit methods.
- Added opt-in `iv_prioritize_by_date` for sales-order preview and reservation.
  It orders all dated open lines by requested date across the whole order,
  keeps source order for equal dates, and places undated item-level demand
  after dated lines. Reservation requests use the same priority order.
- Added preview coverage for the default and date-priority paths plus a
  reservation-flow test proving that the earlier-due line receives stock first.
- Latest verification after order date priority: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 138 ABAP Unit methods.
- Added `GET_STOCK_STATUS` to report plant totals for unrestricted,
  quality-inspection, and blocked stock separately, with active reservations
  net of withdrawals and an unrestricted availability estimate. Added
  `MARD-INSME` and `MARD-SPEME` to the local stub; quality and blocked stock
  do not enter allocation.
- Added `GET_STOCK_STATUS_BY_LOCATION` for category totals and available
  unrestricted quantities by `LGORT`. It uses the same deterministic handling
  of plant-level reservations as location-aware allocation.
- Added static `MARC-EISBE` and `available_after_safety_qty` to the plant status
  result, with a pure calculator that clamps negative safety-stock values and
  availability at zero. Existing opt-in allocation protection now uses the
  same calculator.
- Added service tests for plant and location status mapping; fake repositories
  do not exercise the MARD/RESB/MARC aggregate queries.
- Latest verification after stock-status safety metrics: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 141 ABAP Unit methods.
- Added `GET_STOCK_STATUS_BY_BATCH` to report unrestricted and available
  quantities with expiration date by storage location and batch. Zero-available
  batches remain in the result, and allocation and inquiry now share the same
  repository calculation.
- Added service mapping coverage for populated and zero-available batch rows;
  fake repositories do not exercise the MCHB/MCHA/MCH1/RESB reads.
- Latest verification after batch stock status: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 142 ABAP Unit methods.
- Order previews and reservations now subtract active movement type 231
  reservations assigned to the sales order. The repository groups RESB
  quantities by item, schedule line, and requirement date; unmatched quantities
  are distributed across the same item's open lines in allocation order.
- Added tests for schedule-line and date matching and for skipping a BAPI call
  when the order's open quantity is already reserved. Local doubles do not
  exercise the RESB query or prove field population in the target SAP release.
- Latest verification after existing order reservation handling: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 144 ABAP Unit
  methods.
- Added single-request allocation in a material-specific alternative unit. The
  service reads `MARA-MEINS` and `MARM-UMREZ`/`UMREN`, converts to base quantity,
  then delegates to the existing allocator. The result preserves the source
  unit and quantity and returns base-unit quantity with allocation details.
- Added a local `MARM` stub and converter/service tests for ratio conversion,
  partial allocation, and unknown-unit rejection. Local doubles do not exercise
  the SAP `MARA`/`MARM` queries.
- Latest verification after alternative-unit allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 149 ABAP Unit
  methods.
- Explicit batch reservations can now prefer a selected storage location and,
  when enabled, fill the remainder from other locations for the same batch.
  Added allocator and order-reservation tests for preference order, plus input
  validation when fallback is requested without a preferred location.
- Latest verification after batch-location fallback: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 152 ABAP Unit
  methods.
- Added `GET_FEFO_BATCH_STATUS` to show batch-status rows that satisfy an
  as-of date and minimum remaining shelf-life requirement. Dated rows are
  sorted by earliest expiration; undated rows appear last when the minimum is
  zero. A shared eligibility calculator now drives this inquiry and FEFO
  allocation.
- Latest verification after FEFO-eligible batch inquiry: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 161 ABAP Unit
  methods.
- Added a cost-center reservation service for movement type 201. It validates
  the material base unit, previews unrestricted stock at one storage location
  and optional batch, then creates a reservation for the allocated quantity
  through an injectable BAPI adapter. Full-allocation and test-run options are
  supported; create or commit errors trigger rollback.
- Added fake API and repository tests for partial and batch reservations,
  full-stock requirements, simulation, no-stock handling, errors, and unit
  validation. Updated the partial SAP reservation header stub with `COSTCENTER`.
- Latest verification after cost-center reservations: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 169 ABAP Unit
  methods.
- Cost-center reservations now accept material-specific alternative units.
  The service converts requested quantities to the material base unit for
  allocation and BAPI creation, while returning both source and base quantities
  and units. Added coverage for a partial allocation after unit conversion.
- Latest verification after cost-center alternative-unit support:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 171 ABAP Unit methods.
- Cost-center requests can now omit the storage location to allocate across
  locations in ascending code order. The BAPI adapter creates one reservation
  with an item for each positive location split, including split items for an
  exact batch across locations. Supplied locations remain hard restrictions.
- Added tests for unbatched location splits and batch/location splits; local
  doubles do not validate the multi-item BAPI call in SAP.
- Latest verification after multi-location cost-center reservations:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 174 ABAP Unit methods.
- Cost-center reservation requests can opt into FEFO batch selection with an
  as-of date and minimum remaining shelf life. The service reserves the
  resulting batch/location splits in the same multi-item BAPI request and
  rejects mixing FEFO with a manual batch or using shelf-life days without
  FEFO.
- Added coverage for expiry ordering, the minimum-day boundary, expired and
  undated exclusions, and invalid FEFO options.
- Latest verification after FEFO cost-center reservations: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 178 ABAP
  Unit methods.
- Added `preview_for_cost_center`, which returns the same allocation and
  validation result as reservation creation without calling the BAPI. Both
  paths now share the preparation method, keeping UOM conversion, FEFO,
  location splits, and full-allocation handling consistent.
- Added tests for a FEFO preview with no transaction API calls and a full-stock
  preview that reports shortfall without creating a reservation.
- Latest verification after cost-center reservation preview:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 180 ABAP Unit methods.
- Cost-center reservation previews and creations now accept
  `iv_allow_fallback` to prefer a supplied storage location, then use other
  locations for any remainder. This applies to location, exact-batch, and FEFO
  allocation; fallback without a location is rejected. Tests check preferred
  location ordering and reservation item splits in all three paths.
- Latest verification after cost-center location fallback:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 184 ABAP Unit methods.
- Added `ZCL_PROD_COMP_SERVICE->GET_OPEN_COMPONENTS` to read active, open
  production-order component reservation items from `RESB`. Results include
  reservation/item keys and the remaining quantity, ready for selection by the
  existing reservation issue service. `ISSUE_COMPONENTS` validates selected
  keys and quantities against those open rows before delegating to the existing
  reservation issue service. Added local tests for partial, complete, deleted,
  final-issue, over-withdrawn, and mismatched-order rows, plus successful
  selected-item issue and rejection of an item outside the order.
- Added partial `RESB` stub fields for production order, reservation keys, and
  reservation unit; live SAP query behavior remains an integration check.
- Latest verification after production-order component inquiry:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 189 ABAP Unit methods.
- Added `GET_STOCK_STATUS_IN_UNIT`, which converts the full plant stock status
  from the material base unit to a requested material-specific unit. The
  converter now exposes one validated `MARM` numerator/denominator ratio and
  converts in both directions. Tests cover the ratio, reverse conversion,
  all stock-status values, and unknown-unit rejection before stock reads.
- Latest verification after stock-status unit conversion:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 194 ABAP Unit methods.
- Added `ALLOCATE_DEMANDS_IN_UNITS` to convert and allocate multiple
  material-specific demand units in one shared allocation pass. It validates
  all material/unit ratios before reading stock, caches each ratio during the
  request, and returns both source-unit and base-unit details. Tests cover
  competing demands against shared stock and reject an unknown unit before any
  stock read.
- Latest verification after bulk alternative-unit allocation:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 196 ABAP Unit methods.
- Added alternative-unit stock-status inquiries by location and batch, plus a
  FEFO batch inquiry in the requested unit. Results preserve their location,
  batch, and expiration details, report both units, and validate the unit before
  stock reads. FEFO results keep the existing date filter and ordering. Tests
  cover conversion, ordering, and rejecting unknown units before repository
  reads.
- Latest verification after location and batch status unit conversion:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 200 ABAP Unit methods.
- Added `GET_STOCK_IN_TRANSFER_IN_UNIT`, converting the plant and optional
  storage-location in-transfer quantities to a requested material unit. It
  returns both base and requested units, and rejects missing or invalid ratios
  before reading transfer balances. Tests cover both conversions and unknown-
  unit rejection without a repository read.
- Latest verification after in-transfer unit conversion: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 202 ABAP Unit
  methods.
- Added `ALLOCATE_BY_EXPIRY_IN_UNITS` for shared FEFO allocation from multiple
  demands in material-specific units. The service validates and caches each
  material/unit ratio before stock reads, keeps demand order and existing FEFO
  rules, and returns base-unit summaries and splits with converted source-unit
  quantities. Tests cover mixed units consuming shared batches and rejecting
  an unknown unit before stock access.
- Latest verification after unit-aware FEFO allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 204 ABAP Unit
  methods.
- Added `ALLOCATE_BY_BATCH_IN_UNITS` for multiple exact-batch requests in
  material-specific units. It validates and caches ratios before stock reads,
  keeps each requested batch fixed, shares balances across input demands, and
  returns base and source-unit summaries plus location/batch splits. Tests cover
  mixed-unit demands, preferred-location fallback, shared stock, and rejection
  before reads for an unknown unit.
- Latest verification after exact-batch unit allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 206 ABAP Unit
  methods.
- Added `ALLOCATE_BY_LOCATION_IN_UNITS` for shared storage-location allocation
  from demands in material-specific units. It preserves preferred-location
  fallback, validates all ratios before stock reads, and returns base and
  source-unit summaries and location splits. Tests cover mixed-unit requests
  sharing balances across locations and unknown-unit rejection before reads.
- Latest verification after location unit allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 208 ABAP Unit
  methods.
- Added `ALLOCATE_REQUEST_BY_DATE` for a date-scoped plant availability estimate.
  It nets active unrestricted reservations due by the requested date, returns
  the usual available/allocated/shortfall quantities, and supports optional
  static safety-stock protection. Tests cover the dated split, safety-stock
  adjustment, and missing-date rejection. This remains a local estimate based
  on current stock and does not model future receipts or SAP ATP.
- Latest verification after date-scoped allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 244 ABAP Unit
  methods.
- Added the `ZIF_MATERIAL_AVAILABILITY_API` boundary and BAPI adapter for
  `BAPI_MATERIAL_AVAILABILITY`. `ALLOCATE_REQUEST_DATE_ATP` now returns the
  SAP-confirmed quantity/date and dialog status beside the date-scoped local
  allocation, using the caller's unit and checking rule. Tests verify request
  mapping and preserve the distinction between local and SAP quantities; the
  adapter still requires validation against the target SAP function signature.
- Latest verification after the ATP adapter: `npm.cmd test` passed; abaplint
  reported zero issues and the transpiler ran all 246 ABAP Unit methods.
- Extended `preview_order` with opt-in `iv_check_atp` and a caller-supplied
  checking rule. It requests a check per positive open schedule line using the
  cumulative open demand for that material, plant, and base unit through the
  required date. Same-date lines use the combined quantity due that day, and
  results retain both line and cumulative quantities in original order. The
  checks remain separate from local allocations. It rejects missing rules
  before order/stock reads and missing dates before stock allocation. Tests
  cover out-of-order and same-date lines, separate ATP/local quantities, and
  invalid rule/date inputs. SAP documents accumulation limits for this BAPI,
  so target checking configuration and live results still require validation.
- Latest verification after cumulative sales-order ATP checks: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 249 ABAP
  Unit methods.
- Added `ALLOCATE_DEMANDS_BY_DATE` for a set of requests sharing dated stock.
  It validates the full list before reads, allocates in ascending required-date
  order with input order as the tie-breaker, shares stock across later dates,
  caches repeated date snapshots and safety stock, and returns rows in input
  order. Tests cover an out-of-order list, repeated dates, shared stock,
  safety-stock protection, read caching, and rejection before reads.
- Latest verification after bulk dated allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 251 ABAP Unit
  methods.
- Added opt-in `iv_include_po_receipts` to single-date, bulk-date, and
  date-based ATP comparison methods. The MARD repository adds the open
  remainder of dated standard stock
  PO schedule lines from `EKET`, filters deleted, completed, account-assigned,
  return, no-GR, and non-unrestricted stock-type items in `EKPO`, and converts
  PO units to base units through `UMREZ/UMREN`. Added a pure schedule-quantity
  converter with tests for partial receipts, conversion ratios, closed lines,
  and invalid ratios. The option is off by default; PO release and supplier-
  confirmation state are not modeled.
- Latest verification after purchase-receipt projections: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 256 ABAP Unit
  methods.
- Added opt-in `iv_include_sto_in_transit` to single-date, bulk-date, and
  date-based ATP comparison methods. The MARD repository projects schedule-line
  quantities already issued from stock-transfer items (`EKPO-PSTYP = '7'`) and
  still outstanding at receipt (`EKET-WAMNG - EKET-WEMNG`), due by the required
  date. It requires a supplying plant, excludes transport-document types and
  statistical items, and accepts PO/scheduling-agreement document categories.
  It converts the PO unit to the base unit and filters deleted,
  account-assigned, returns, no-GR, and non-unrestricted receiving items. Planned
  but unissued transfers are excluded, and the flag is off by default. Tests
  cover the converter, independent and combined PO/STO options, bulk allocation,
  and ATP comparison. Live STO schedule data and stock-type behavior still need
  validation in the target SAP system.
- Latest verification after STO in-transit projection: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 258 ABAP Unit
  methods.
- Added opt-in `iv_include_prod_receipts` to single-date, bulk-date, and
  date-based ATP comparison. The MARD repository projects open production-order
  item quantity (`AFPO-PSMNG - AFPO-WEMNG`) from released, GR-relevant category
  10 orders due by `AFKO-GLTRP`. It excludes deleted, completed, make-to-order,
  and account-assigned items and converts production units with
  `AFPO-UMREZ/UMREN`. A pure converter and dated-allocation tests cover partial
  receipts, closed orders, invalid conversions, and the opt-in behavior. Basic
  finish date and expected stock type remain estimates; target SAP validation
  is still needed.
- Latest verification after production-receipt projection: `npm.cmd test`
  passed; abaplint reported zero issues across 63 files and the transpiler ran
  all 262 ABAP Unit methods.
- Extended `ZIF_MATERIAL_AVAILABILITY_API` results with all `WMDVEX` dated
  confirmation lines, including requested date/quantity and confirmed
  date/quantity. The BAPI adapter maps every returned row; the existing scalar
  confirmation fields continue to mirror the first row. Added pure mapping
  tests for multiple and empty confirmation tables, plus a stock-service test
  that verifies multiple rows survive the ATP comparison result.
- Latest verification after preserving full ATP confirmations: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 264 ABAP Unit methods.
- Added `ENDLEADTME` to the material availability result as
  `end_of_replenishment_lead_time`, typed from `BAPICM61M-WZTER`. The BAPI
  adapter maps the date and the stock-service test verifies it survives the ATP
  result path. SAP documents that this date is returned when replenishment lead
  time is active; the target release's function signature still needs live
  validation.
- Latest verification after exposing the replenishment lead-time date:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 264 ABAP Unit methods.
- Updated sales-order ATP preview to call the availability API once per unique
  material/plant/base-unit/required-date group. Same-date lines continue to
  report their individual demand and shared cumulative quantity, while reusing
  the group's ATP result. The regression test verifies two calls for three
  positive schedule lines spanning two dates.
- Latest verification after reusing same-date ATP results: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 264 ABAP Unit methods.
- Added `ALLOCATE_DATE_DEMANDS_IN_UNITS` to combine date-priority allocation
  with material-specific input units. It validates request IDs and unit ratios
  before stock reads, caches repeated ratios, shares dated balances in base
  units, applies the existing receipt and safety-stock options, and returns
  canonical base quantities with rounded source-unit availability/allocation
  values. Tests cover out-of-order mixed-unit demand, all three receipt options,
  safety stock, and unknown-unit rejection before stock reads.
- Latest verification after dated unit-aware allocation: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 266
  ABAP Unit methods.
- Added `ALLOCATE_PLANTS_BY_DATE` to allocate dated demands from caller-ordered
  source plants. It processes earliest dates first, shares each source balance
  across requests, caches date snapshots and safety stock, supports projected
  PO/STO/production receipts, and returns plant splits in request/source order.
  It is a planning preview without storage-location splits. Tests cover reversed
  input dates, per-request source priority, shared stock across dates, receipts,
  safety-stock protection, and missing-source rejection before stock reads.
- Latest verification after dated cross-plant allocation: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 268 ABAP Unit methods.
- Added `ALLOCATE_PLANTS_DATE_UNITS` to combine dated cross-plant allocation
  with material-specific input units. It caches unit ratios, converts demand to
  base units, preserves date priority and caller source order, and returns
  converted demand and source-plant split details alongside canonical base-unit
  values. Tests cover receipt projection, shared stock across dates, source
  priority, output order, unit conversion, and unknown-unit rejection.
- Latest verification after dated cross-plant unit allocation: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 270 ABAP Unit methods.
- Corrected `ALLOCATE_REQUEST_DATE_ATP` to convert the caller's unit quantity
  to the material base unit for the local stock estimate while keeping the
  original unit and quantity on the SAP ATP request. Added an alternative-unit
  regression test and supplied the UOM test double to the existing ATP test.
- Latest verification after the ATP unit correction: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 271
  ABAP Unit methods.
- Added `ALLOCATE_DATE_DEMANDS_ATP` to compare unit-aware dated allocations with
  SAP ATP using cumulative base-unit demand per material/plant/unit/date. It
  shares one ATP response across same-day requests, returns results in input
  order, and keeps SAP ATP separate from the local receipt/safety-stock estimate.
  The test covers mixed input units, same-day aggregation, date priority, and
  reduced ATP calls for shared date groups.
- Latest verification after bulk dated ATP comparison: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 273
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_ALLOCATION` to post `ALLOCATE_BY_STORAGE_LOCATION`
  source splits as movement 311 items to a caller-selected destination per
  request. It reuses transfer completeness, split-total, unit-mapping, simulation,
  and transaction checks, and rejects a destination equal to a source location.
  Tests cover multiple source locations and same-location rejection.
- Latest verification after storage-location allocation transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 275 ABAP Unit methods.
- Added `TRANSFER_LOCATION_BATCH_ALLOC` for exact-batch `ALLOCATE_BY_BATCH`
  results. It posts movement 311 items per source location, retains each batch,
  and rejects a result that mixes batches for one request before calling SAP.
  Tests cover a multi-location batch transfer and mixed-batch rejection.
- Latest verification after batch location transfer: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 277
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_UNITS_ALLOC` to post unit-aware storage-location
  allocations as movement 311 items, carrying canonical base-unit split
  quantities and validating the result's base unit against the supplied
  material mapping. Tests cover multiple base-unit splits and unit mismatch
  rejection.
- Latest verification after unit-aware location transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 298 ABAP Unit methods.
- Added `TRANSFER_LOCATION_BATCH_UNITS` to post unit-aware exact-batch location
  allocations as movement 311 items. It preserves each batch, uses canonical
  base-unit split quantities, and rejects mixed batches or base-unit mismatches
  before the BAPI call. Tests cover a multi-location transfer and both invalid
  result cases.
- Latest verification after unit-aware batch location transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 301 ABAP Unit methods.
- Added `TRANSFER_LOCATION_FEFO_ALLOC` to post same-plant FEFO batch/location
  splits as 311 items. It carries each selected batch and keeps the preview's
  split order, including requests allocated from more than one batch. Tests
  cover a two-batch transfer and missing-batch rejection before the BAPI call.
- Latest verification after FEFO location transfer: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 303
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_FEFO_UNITS` for unit-aware FEFO location results. It
  posts canonical base-unit quantities and supports multiple FEFO-selected
  batches per request, preserving the preview's split order. Tests cover a
  mixed-batch transfer and rejection of a base-unit mismatch.
- Latest verification after unit-aware FEFO location transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 305 ABAP Unit methods.
- Added `TRANSFER_LOCATION_TWO_STEP` to turn validated storage-location splits
  into movement 313 removals and one 315 putaway item per request. Its result
  exposes both posting responses and marks stock still in transit when the
  second posting fails after removal committed. Tests cover both steps,
  preflight rejection, test run behavior, and pending putaway reporting.
- Latest verification after two-step location transfer: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 311
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_2STEP_UNITS`, which validates unit-aware location
  summaries and splits against material base-unit mappings before using the
  313/315 flow. It posts canonical base-unit quantities and reuses the two-step
  result status for failures between removal and putaway. Tests cover posting
  both legs and pre-post rejection of summary and split unit mismatches.
- Latest verification after unit-aware two-step location transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 314 ABAP Unit methods.
- Added `TRANSFER_PLANT_TWO_STEP` to map cross-plant allocation location splits
  to movement 303 removals and one 305 putaway item per request. The shared
  two-step flow validates all demands and source splits before posting and
  reports in-transit stock when putaway fails after removal. Tests cover the
  two movement legs and reject same-plant source splits before calling SAP.
- Latest verification after cross-plant two-step transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 316 ABAP Unit methods.
- Added `TRANSFER_PLANT_2STEP_UNITS` to accept unit-aware cross-plant location
  allocations. It checks summary and split base units against material unit
  mappings, then posts canonical base-unit quantities through 303/305.
  Tests cover both posting legs and pre-post summary and split unit mismatches.
- Latest verification after unit-aware cross-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 319 ABAP Unit methods.
- Added a plant two-step regression for a 303 removal that commits before the
  305 putaway fails. It confirms the result reports stock in transit and keeps
  the removal and putaway responses separate.
- Latest verification after plant putaway failure coverage: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 320 ABAP Unit methods.
- Added `TRANSFER_PLANT_BATCH_TWO_STEP` for exact-batch cross-plant allocations.
  It preserves a demand's selected batch across every 303 removal and its 305
  putaway, and rejects mismatched source batches before posting. Tests cover
  multiple source splits and batch mismatch rejection.
- Latest verification after batch-aware cross-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 322 ABAP Unit methods.
- Added `TRANSFER_PLANT_BATCH_2STEP_UOM` for unit-aware exact-batch cross-plant
  results. It checks summary and split base units against the material mapping
  and posts canonical quantities through 303/305 without losing the batch.
  Tests cover both posting legs and pre-post summary and split unit mismatches.
- Latest verification after unit-aware batch two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 325 ABAP Unit methods.
- Added `TRANSFER_PLANT_FEFO_TWO_STEP` for cross-plant FEFO results. It retains
  preview order on 303 removals and groups putaway quantities by request and
  batch, so source splits from one batch become one 305 item. Tests cover
  multiple batches, same-batch split grouping, and missing batch rejection.
- Latest verification after cross-plant FEFO two-step transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 327 ABAP Unit methods.
- Added `TRANSFER_PLANT_FEFO_2STEP_UOM` for unit-aware cross-plant FEFO results.
  It checks summary and batch split base units against the supplied material
  mapping and retains canonical quantities through grouped 303/305 posting.
  Tests cover batch grouping and pre-post summary and split unit mismatches.
- Latest verification after unit-aware cross-plant FEFO two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 330 ABAP Unit methods.
- Added `TRANSFER_LOCATION_FEFO_2STEP` for same-plant FEFO results. It retains
  preview order on 313 removals and combines same-batch source-location splits
  into per-batch 315 putaway items. Tests cover order, grouping, and rejection
  of a missing batch before posting.
- Latest verification after same-plant FEFO two-step transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 332 ABAP Unit methods.
- Added `TRANSFER_LOC_FEFO_2STEP_UOM` for unit-aware same-plant FEFO results.
  It checks summary and batch split base units against material mappings, then
  posts canonical quantities through grouped 313/315 movements. Tests cover
  batch grouping and pre-post summary and split unit mismatches.
- Latest verification after unit-aware same-plant FEFO two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 335 ABAP Unit methods.
- Added `TRANSFER_LOCATION_BATCH_2STEP` for exact-batch location allocation
  results. It preserves the one batch across 313 source removals and combines
  same-batch source-location splits into one 315 putaway per request. Tests
  cover movement fields, combined quantity, and rejection of mixed batches
  before posting.
- Latest verification after exact-batch same-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 337 ABAP Unit methods.
- Added `TRANSFER_LOC_BATCH_2STEP_UOM` for unit-aware exact-batch location
  results. It checks the summary and source split base units against the
  material mapping, then posts canonical quantities through 313/315. Tests
  cover grouped batch quantities and pre-post summary and split unit mismatches.
- Latest verification after unit-aware exact-batch same-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 340 ABAP Unit methods.
- Added optional SAP ATP checking to `PREVIEW_FOR_COST_CENTER`. The result
  carries a separate plant-level ATP response based on the requested material
  base quantity and required date; it does not alter local allocation or
  success. Tests cover a local shortfall with ATP confirmation and missing-rule
  rejection before stock reads.
- Latest verification after cost-center preview ATP support: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 342 ABAP Unit methods.
- Added `GET_STOCK_IN_TRANSFER_BY_BATCH` for storage-location stock in transfer
  from `MCHB-CUMLM`, plus `GET_BATCH_TRANSFER_IN_UNIT` for requested-unit
  quantities with the base-unit balance retained. Tests cover batch/location
  mapping, alternative-unit conversion, and validation before repository reads.
- Latest verification after batch-level stock-transfer inquiry: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 346 ABAP Unit methods.
- Added `ALLOCATE_PLANTS_DATE_ATP` for unit-aware dated cross-plant estimates.
  It returns the unchanged local allocation plus plant-level ATP checks for
  positive source splits, grouping allocated base quantities cumulatively by
  source plant and date. Tests cover shared same-date groups, later cumulative
  quantities across requests, and early rejection of a missing check rule.
- Latest verification after dated cross-plant ATP support: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 348 ABAP Unit methods.
- Added sales-order-scoped reservation release. The finder discovers open
  movement-231 RESB documents, excluding documents with another non-deleted
  item outside the requested order and stock scope. The service reuses the
  existing simulation, commit, and rollback path; no matching reservations is
  an idempotent success. It also previews eligible numbers without calling the
  BAPI and supports narrowing to one order item. Item-scoped releases skip a
  reservation document containing a non-deleted item for another order line.
  Local tests cover preview, item-scope forwarding, deletion, simulation, no
  matches, and blank order input. The database query still needs target-SAP
  validation.
- Latest verification after reservation release preview: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 353
  ABAP Unit methods.
- Added optional sales-order item scoping to reservation preview and release.
  The finder only returns complete documents whose non-deleted items match that
  order item. The item filter is forwarded through the injectable finder and is
  covered by preview and committing deletion tests.
- Latest verification after item-scoped reservation release: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 355 ABAP Unit methods.
- Added bulk sales-order reservation release for a unique order list. The finder
  uses one bulk candidate read and one scope-verification read, maps eligible
  reservation numbers back to each order, and deletes the deduplicated list in
  one transaction. `PREVIEW_ORDERS_RELEASE` returns those scopes without calling
  the delete BAPI. Empty matches are an idempotent success; blank or duplicate
  order numbers are rejected before database access. Tests cover grouped results,
  duplicate candidate deduplication, ambiguous reservation ownership rejection,
  read-only preview, one commit, empty matches, and invalid lists.
- Latest verification after bulk release preview:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 360 ABAP Unit methods.
- Added bulk reservation preview and release for explicit sales-order/item
  pairs. One bulk `RESB` read finds open matching lines and a second read excludes
  reservation documents containing a non-deleted row for another item. All
  selected item scopes share one delete transaction. Tests cover grouped item
  results, preview without BAPI calls, test-run without commit, invalid scopes,
  and ambiguous reservation ownership.
- Latest verification after item-scoped bulk release: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 365
  ABAP Unit methods.
- Added bulk production-order component inquiry and issue. The repository reads
  component rows for a unique order list in one guarded query. The service
  validates each selected reservation item against its originating order and
  sends multi-order issue requests through one goods-movement transaction.
  Existing single-order methods now use the shared bulk paths. Tests cover sorted
  component results, one repository read, one combined multi-order posting, and
  invalid order lists rejected before repository access.
- Latest verification after bulk production component issue: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 368 ABAP Unit methods.
- Two-step transfer results now retain their exact planned putaway items.
  `RETRY_TRANSFER_PUTAWAY` validates a pending transfer and posts only its 305 or
  315 items, preserving the committed removal. Simulations and failed retries
  remain in transit; only a successful committed retry clears the state. Tests
  cover simulation, repeated failure, recovery, completed-transfer rejection,
  and rejection of a removal movement in the putaway payload.
- Latest verification after putaway retry support: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 370
  ABAP Unit methods.
- Added `CANCEL_TRANSFER_IN_TRANSIT` as the compensating recovery path. It
  cancels the original removal document through the existing cancellation API,
  retains the pending state after a cancellation error, and exposes the reversal
  result plus an `is_cancelled` flag after commit. Tests cover cancellation API
  and commit failures followed by success, plus rejection of a second
  cancellation after completion.
- Latest verification after pending-transfer cancellation: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 372 ABAP Unit methods, including recovery of a same-plant 313/315 transfer.
- Added `ALLOCATE_PLANTS_FEFO_BY_DATE` for cross-plant date-prioritized batch
  allocation. Earlier requirements consume shared balances first, shelf life is
  checked against each required date, and source-plant order remains caller
  controlled. Static safety stock can be protected, and output order matches the
  input. Tests cover date priority, per-demand expiry eligibility, safety-stock
  protection, input ordering, and missing-date rejection.
- Latest verification after dated cross-plant FEFO: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 370
  ABAP Unit methods.
- Added `ALLOCATE_PLANTS_FEFO_DATE_UOM`, which converts dated cross-plant FEFO
  requests to base units while preserving date priority, per-demand shelf-life
  filtering, and unit-aware demand/source/batch results. Added
  `TRANSFER_FEFO_DATE_UOM` and `TRANSFER_FEFO_DATE_UOM_2STEP` adapters for 301
  and 303/305 goods movements. Tests cover date-sorted shared allocation, unit
  conversion, required-date validation, and both transfer flows.
- Added `ALLOCATE_PLANTS_FEFO_DATE_ATP` to compare positive FEFO source-plant
  allocations with cumulative SAP ATP by required date and base unit. The local
  FEFO estimate and ATP confirmations remain separate in the result.
- Latest verification after dated FEFO ATP and transfer adapters:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 376 ABAP Unit methods.
- Added an optional `it_allowed_storage_locations` allowlist to base, unit-aware,
  and ATP-enabled dated cross-plant FEFO allocation. The same validated list is
  applied to every source plant; empty input retains unrestricted selection.
  Tests verify excluded earlier-expiring stock, allowlist propagation through
  unit and ATP paths, and rejection of blank or duplicate locations before stock
  reads.
- Latest verification after FEFO source-location filtering: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 378 ABAP Unit methods.
- Added `it_source_locations` for request/source-plant-specific storage
  restrictions across base, unit-aware, and ATP-enabled dated FEFO allocation.
  The table must cover every source pair; when the shared allowlist is also set,
  the filters intersect. Tests cover distinct location assignments per request,
  propagation through unit conversion and ATP, and invalid/uncovered mappings.
- Latest verification after scoped FEFO storage rules: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 380
  ABAP Unit methods.
- Added direct confirmed and unconfirmed base-unit quantities to dated
  cross-plant ATP checks, including FEFO ATP.
  The service totals multiple confirmation lines, caps the confirmation
  at the cumulative quantity checked, and leaves the raw SAP result intact.
  Tests cover partial multi-line confirmation and the fully available case.
- Latest verification after ATP quantity splits: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 380
  ABAP Unit methods.
- Extended the direct quantity split to `ALLOCATE_DATE_DEMANDS_ATP`; repeated
  dated rows now expose the same cumulative confirmed and unconfirmed base
  quantities. Tests cover a multi-line partial confirmation shared by requests
  due on the same date.
- Latest verification after dated ATP response consistency: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 380 ABAP Unit methods.
- Added the same base-unit confirmation split to `ALLOCATE_REQUEST_DATE_ATP`.
  The helper converts all alternative-unit confirmation lines with the validated
  material ratio before capping the total. Tests cover multiple confirmations
  in base and alternative units.
- Latest verification after single-request ATP quantity reporting:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 380 ABAP Unit methods.
- Promoted `GET_ATP_CONFIRMATION_SPLIT` as a shared stock-service API and added
  base-unit confirmed/unconfirmed quantities to single-order and multi-order ATP
  checks. Same-date sales-order rows reuse the same split; tests cover
  multi-line confirmations and the multi-order reservation preview path.
- Latest verification after sales-order ATP quantity reporting: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 380 ABAP Unit methods.
- Hardened the shared ATP confirmation splitter to reject negative requested
  base quantities and nonpositive conversion ratios before calculation. Added a
  regression test for a zero denominator and negative request.
- Latest verification after ATP split input validation: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 381
  ABAP Unit methods.
- Extended `preview_for_cost_center` with direct confirmed and unconfirmed
  base-unit quantities from its optional ATP check. The preview shares the
  cross-service splitter, and its alternative-unit request is already converted
  before ATP, so returned split quantities remain in the stock base unit.
- Latest verification after cost-center ATP quantity reporting: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 381 ABAP Unit methods.
- Added single-order and bulk production-component ATP previews. They convert
  open reservation quantities to base units, accumulate checks by material,
  plant, base unit, and required date, and return raw SAP ATP results with
  confirmed/unconfirmed cumulative quantities. Blank rules and undated or
  incomplete open components are rejected before any ATP call.
- Latest verification after production-component ATP preview: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 385 ABAP Unit methods. The SAP repository query and live ATP behavior
  remain unverified locally.
- Extended both production-component ATP preview entry points with a separate
  local dated stock estimate. It shares stock across component dates and can
  include PO/STO/production receipts, subtract unissued STO demand, and protect
  static safety stock. Added coverage for date-group aggregation, receipt
  projection, safety-stock protection, and the single-order wrapper.
- Latest verification after component stock/ATP comparison: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 385 ABAP Unit methods.
- Added `component_local_estimate` so each production component gets a
  deterministic share of the date group's local allocation. Components consume
  the shared date balance in production-order, reservation, and item order;
  group-level estimates remain available beside the per-component split. Tests
  cover partial allocation across same-date components, including an
  alternative-unit component.
- Latest verification after per-component stock splits: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 385
  ABAP Unit methods.
- Added `SUMMARIZE_COMPONENT_READINESS` to roll local component allocations up
  by production order, including covered/short counts, date range, first
  shortage date, and a local-ready flag. It validates reservation keys and
  quantity consistency. Tests cover mixed-ready orders, date ranges, first
  shortage selection, and malformed rows.
- Latest verification after component readiness summaries: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 387 ABAP Unit methods.
- Added single-order and bulk local-only component stock previews. They share
  the same conversion, dated stock grouping, receipt projection, safety-stock,
  and component-split logic as ATP previews, while skipping the ATP API and
  checking-rule requirement. Tests verify local shortfall output and zero ATP
  calls through both entry points.
- Latest verification after local-only component previews: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 388 ABAP Unit methods.
- Added `SUMMARIZE_COMPONENT_SHORTAGES`, which groups valid component preview
  rows by material, plant, base unit, and required date. It reports component
  counts, distinct affected production orders, and summed requested, allocated,
  and shortfall quantities, returning only groups with local shortfall. The
  validation also ensures every local allocation matches the row's available
  quantity before this roll-up is calculated.
- Latest verification after component shortage summaries: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 389 ABAP Unit methods.
- Added component-level ATP confirmation and unconfirmed quantities. The split
  assigns each date's nonnegative increase in cumulative confirmation across
  same-date component rows in production-order/reservation/item order, while
  preserving the existing repeated cumulative group totals. Tests cover
  partial same-date allocation and the increase at a later required date.
- Latest verification after per-component ATP confirmation splits:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 389 ABAP Unit methods.
- Added `SUMMARIZE_ORDER_ATP` for check-relevant component ATP rows. It groups
  counts and quantities by production order, material, plant, and base unit,
  tracks date range and first unconfirmed date, and rejects inconsistent or
  unchecked ATP rows. Tests cover partial, full, and unconfirmed components
  across different base units and dates.
- Latest verification after order ATP summaries: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 390
  ABAP Unit methods.
- Made production-component ATP confirmation date-aware. The shared confirmation
  splitter now accepts an optional required-date cutoff; component previews use
  it to exclude confirmations after the requirement date and undated lines,
  while retaining the complete raw ATP response. Existing callers without a
  cutoff keep their prior all-lines behavior. Tests cover due, later, and
  undated confirmation lines and the downstream component split.
- Latest verification after date-limited component ATP confirmation:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 391 ABAP Unit methods.
- Added `SUGGEST_COMP_REPLENISHMENT` to turn local component shortage rows into
  base-unit quantity suggestions using optional per-material/plant/unit
  minimums and order multiples. It rounds up, reports surplus, validates
  policy and shortage keys, and uses the exact shortfall if no policy is
  supplied. It does not create SAP purchasing documents or adjust dates for
  lead times.
- Latest verification after component replenishment suggestions:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 393 ABAP Unit methods.
- Integrated replenishment suggestions with a bulk MARC/MARA policy repository.
  Caller overrides win. SAP lot-for-lot (`DISLS = EX`) applies `BSTMI` and
  `BSTRF`; fixed lot (`FX`) applies `BSTFE`; other procedures return the exact
  shortfall with an explicit unsupported origin. Results report policy origin
  and lot-size procedure. Added MARC stubs for the required planning fields and
  documented the procedures that are not modeled.
- Latest verification after procedure-aware MARC replenishment policies:
  `npm.cmd test` passed; abaplint reported zero issues across 67 files and the
  transpiler ran all 393 ABAP Unit methods. `git diff --check` passed.
- Added maximum-lot splitting for `EX` replenishment suggestions from
  `MARC-BSTMA`. Results include total receipt count and the final receipt
  quantity; a split remainder is raised to minimum quantity and rounded. Invalid
  minimum/maximum combinations or an unfit rounded remainder are marked
  unsupported and fall back to the exact shortage.
- Latest verification after maximum-lot splitting: `npm.cmd test` passed;
  abaplint reported zero issues across 67 files and the transpiler ran all 393
  ABAP Unit methods.
- Added the raw material procurement type (`MARC-BESKZ`) and special
  procurement key (`MARC-SOBSL`) to the policy lookup and recommendation result.
  This exposes SAP's routing context to callers without trying to resolve
  vendor/source-of-supply customizing in the quantity suggestion service.
- Latest verification after adding procurement-route context: `npm.cmd test`
  passed; abaplint reported zero issues across 67 files and the transpiler ran
  all 393 ABAP Unit methods.
- Added material-master lead-time estimates to replenishment suggestions for
  externally procured materials without a special procurement key. The bulk
  lookup now returns `MARC-PLIFZ`/`WEBAZ`, `T001W-FABKL`, and `T399D-BZTEK`;
  the dates use calendar days for planned delivery and factory-calendar
  workdays for goods receipt and purchasing processing. Results distinguish
  missing policy/calendar data, special sourcing, in-house/ambiguous
  procurement, unsupported procurement, calendar errors, and estimates. Public
  status constants make the result contract easier for callers to consume.
  Added tests for a successful date calculation, unsupported routes, missing
  calendar data, and calendar API failure. The estimate is material-master
  based and indicative; source-specific purchasing data and MRP margins are not
  modeled. The target SAP calendar function modules and joined customizing
  tables still require target-release validation.
- Latest verification after replenishment timing estimates and status constants:
  `npm.cmd test` passed; abaplint reported zero issues across 69 files and the
  transpiler ran all 393 ABAP Unit methods.
- Added source-specific planned delivery time support for a purchasing info
  record already resolved by the caller. Caller policies can pass vendor,
  purchasing organization, info-record number/category, and `EINE-APLFZ`; a
  positive source lead time takes precedence over the policy's generic planned
  delivery value. Zero falls back to that caller-supplied material lead time.
  Suggestions preserve source identity and identify the source of effective
  planned delivery days. Incomplete source identity or a source supplied for a
  non-external/special-procurement policy is rejected. Added minimal EINA/EINE
  stubs for DDIC typing and tests for positive source override, zero fallback,
  and invalid source context. No automatic source determination or EINA/EINE
  query is performed; the host must apply SAP's source-list, quota, validity,
  and purchasing-organization rules before passing a source.
- Latest verification after source-specific delivery-time support:
  `npm.cmd test` passed; abaplint reported zero issues across 69 files and the
  transpiler ran all 393 ABAP Unit methods.
- Added deterministic requisition-release urgency to replenishment suggestions.
  Callers can supply an as-of date; it defaults to `sy-datum`. When a release
  date estimate exists, results report whether that date is overdue and the
  elapsed calendar days. Tests cover an overdue source-based date and a release
  due today, including the explicit as-of date in the result.
- Latest verification after release-date urgency: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 393
  ABAP Unit methods.
- Added optional chronological netting of lot-size rounding surplus across
  dated component shortages. The default still plans each date independently;
  `iv_net_prior_surplus = abap_true` orders shortages by material, plant, unit,
  and date, carries leftover surplus forward, and emits `COVERED_BY_SURPLUS`
  rows when no new receipt is needed. Results expose each row's net planning
  quantity, prior surplus used, and remaining carry. The behavior only nets
  suggestions produced in this call and assumes prior surplus is available by
  later required dates; it does not replace projected receipt previews.
- Latest verification after dated surplus netting: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 394
  ABAP Unit methods. `git diff --check` passed.
- Added optional dated receipt netting to replenishment suggestions. Callers can
  pass validated PO, stock-transfer, or production receipt quantities; the
  service consumes supply by material, plant, unit, and receipt date, and
  reports `projected_receipt_used_qty` separately from suggestion rounding
  surplus. Optional receipt source identities are returned with each consumed
  line for traceability. Fully covered dates identify receipt-only or combined
  receipt and surplus coverage. Receipt input triggers chronological shortage
  processing through a key/date-sorted supply index that preserves caller order
  within a date; the service performs no receipt-source query.
- Latest verification after projected receipt netting: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 395
  ABAP Unit methods.
- Added `GET_PROJECTED_RECEIPTS` to the stock repository and stock service. It
  exposes source-level PO, issued/unissued STO, and released production receipt
  rows with base-unit quantity, receipt date, and document/item/schedule-line
  identity. Callers can map those rows directly into replenishment suggestions;
  each source group remains opt-in and the target SAP queries still require
  release validation.
- Added `SUGGEST_COMP_REPL_FROM_STOCK`, which gathers selected receipt
  types once per unique material/plant through the latest shortage date, then
  nets the returned rows by base-unit key and required date. This removes the
  manual receipt mapping step while preserving caller policy and date controls.
- Latest verification after receipt-source integration: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 397
  ABAP Unit methods.
- Filtered PO, STO, and production receipt rows after conversion to the stock
  quantity type. Very small positive calculated quantities can round to zero at
  that boundary; the adapter now omits those zero-quantity rows so the public
  receipt contract stays strictly positive.
- Latest verification after the SAP receipt precision guard: `npm.cmd test`
  passed; abaplint reported zero issues across 69 files and the transpiler ran
  all 397 ABAP Unit methods. `git diff --check` passed.
- Added `pr_release_urgency` to replenishment suggestions as a direct status for
  estimated requisition release timing: `NO_ESTIMATE`, `OVERDUE`, `DUE_TODAY`,
  or `UPCOMING`. Existing release-date, overdue flag, and day-count fields stay
  available. Tests cover all four states using a fixed as-of date.
- Latest verification after release urgency categorization: `npm.cmd test`
  passed; abaplint reported zero issues across 69 files and the transpiler ran
  all 398 ABAP Unit methods. `git diff --check` passed.
- Added purchase requisition creation from replenishment suggestions through a
  `BAPI_PR_CREATE` adapter and injectable API. Positive suggestions become one
  requisition item per planned receipt lot, preserving maximum/fixed lot splits;
  inconsistent count/quantity combinations are rejected before the BAPI call.
  The service supports BAPI test-run mode, commits only successful writes with a
  returned requisition number, and rolls back API, document-number, and commit
  failures. Covered zero-quantity suggestions are a successful no-op. The
  service accepts a caller-selected PR type plus optional purchasing group and
  organization, and leaves vendor/source selection to SAP.
- Added minimal local DDIC stubs for the BAPI PR header and item structures.
  The function module and transaction calls are isolated in the SAP adapter;
  local service tests use a fake. Target-release BAPI fields and customizing
  remain unverified here.
- Latest verification after requisition creation: `npm.cmd test` passed;
  abaplint reported zero issues across 73 files and the transpiler ran all 403
  ABAP Unit methods. `git diff --check` passed.
- Restricted requisition creation to suggestions explicitly marked as externally
  procured (`F`) with no special procurement key. Missing, in-house, ambiguous,
  and special-procurement routes now fail validation before any BAPI call;
  tests cover those cases.
- Latest verification after requisition procurement-route validation:
  `npm.cmd test` passed; abaplint reported zero issues across 73 files and the
  transpiler ran all 403 ABAP Unit methods. `git diff --check` passed.
- Added `submitted_items` to the requisition result. Each row returns its PR
  item number and 1-based source suggestion index, preserving the mapping when
  a maximum/fixed-lot suggestion expands into multiple PR items. The mapping is
  available for normal writes and BAPI test-runs.
- Latest verification after PR item-to-suggestion mapping: `npm.cmd test`
  passed; abaplint reported zero issues across 73 files and the transpiler ran
  all 403 ABAP Unit methods. `git diff --check` passed.
- Added optional per-suggestion purchasing group and purchasing organization
  overrides for requisition creation. Controls use the returned 1-based source
  suggestion index; blank fields inherit method defaults. Duplicate,
  out-of-range, covered-suggestion, and empty controls fail before the BAPI.
- Latest verification after per-suggestion purchasing controls: `npm.cmd test`
  passed; abaplint reported zero issues across 73 files and the transpiler ran
  all 403 ABAP Unit methods. `git diff --check` passed.
- Preserved structured `BAPIRET2` message context in requisition results,
  including message class/number, variables, parameter, item row, field,
  system, and log identifiers for create and commit messages. Tests confirm
  errors retain their field/item context through rollback handling.
- Latest verification after structured requisition diagnostics: `npm.cmd test`
  passed; abaplint reported zero issues across 73 files and the transpiler ran
  all 403 ABAP Unit methods. `git diff --check` passed.
- Mapped BAPI `PRITEM` and `PRITEMX` message rows back to the generated
  requisition item number and original source suggestion index. Rows outside
  the submitted item table remain unlinked instead of being assigned a false
  source.
- Latest verification after requisition message-to-suggestion correlation:
  `npm.cmd test` passed; abaplint reported zero issues across 73 files and the
  transpiler ran all 403 ABAP Unit methods. `git diff --check` passed.
- Added explicit requisition outcome flags for test-run mode, whether the BAPI
  was called, and whether commit succeeded. Covered-only suggestions return a
  successful no-op with both BAPI/commit flags false; simulation calls remain
  uncommitted.
- Latest verification after requisition outcome flags: `npm.cmd test` passed;
  abaplint reported zero issues across 73 files and the transpiler ran all 403
  ABAP Unit methods. `git diff --check` passed.
- Preserved caller-resolved purchasing source details when creating requisitions:
  the selected vendor is sent as the PR fixed vendor, the source purchasing
  organization is used ahead of the global default, and explicit per-suggestion
  controls remain able to override it. Extracted BAPI item/flag mapping into a
  testable mapper and reject partial source identities before calling SAP.
- Latest verification after selected-source propagation: `npm.cmd test`
  passed; abaplint reported zero issues across 75 files and the transpiler ran
  all 404 ABAP Unit methods. `git diff --check` passed.
- Forwarded the selected purchasing info-record number to the PR item as
  `INFO_REC`, including its X flag; the mapper test also confirms both values
  stay initial for automatically sourced items. Source category remains
  available in the originating suggestion.
- Latest verification after info-record propagation: `npm.cmd test` passed;
  abaplint reported zero issues across 75 files and the transpiler ran all 404
  ABAP Unit methods. `git diff --check` passed.
- Added opt-in purchase requisition receipts to projected supply. Remaining
  quantity is `EBAN-MENGE - EBAN-BSMNG`, converted from the requisition unit to
  the material base unit and traced to BANFN/BNFPO. The repository excludes
  deleted, completed, requester-blocked, nonstandard, account-assigned, and
  special-stock items. The flag flows through stock receipt reads and component
  replenishment suggestions; it defaults off. Release strategy and supplier
  commitment are not evaluated, so the projection remains indicative.
- Added local quantity-calculator and service coverage for open and fully
  ordered quantities, alternate-unit conversion, default-off behavior, and
  shortage netting. Typed the calculator test values to avoid character-based
  numeric comparison in the transpiler runtime.
- Latest verification after PR receipt projection: `npm.cmd test` passed;
  abaplint reported zero issues across 77 files and the transpiler ran all 407
  ABAP Unit methods. `git diff --check` passed.
- Extended `iv_include_pr_receipts` through single, bulk, unit-aware, ATP
  preview, and cross-plant dated stock allocation. Dated local availability
  reuses the centralized projected-receipt rows and adds only PRs due by the
  requested date. SAP ATP requests remain unchanged. Added coverage for
  default-off and opt-in dated allocation.
- Verification after dated PR receipt support: `npm.cmd test` passed;
  abaplint reported zero issues across 77 files and the transpiler ran all 407
  ABAP Unit methods. `git diff --check` passed.
- Carried the option into component stock/ATP previews and multi-sales-order
  dated previews and reservations. Component coverage verifies local supply
  changes while ATP stays independent; sales-order coverage verifies the
  default-off and enabled paths.
- Verification after higher-level PR projection integration: `npm.cmd test`
  passed; abaplint reported zero issues across 77 files and the transpiler ran
  all 407 ABAP Unit methods. `git diff --check` passed.
- Added a distinct opt-in `iv_include_sto_pr_receipts` source for stock-transfer
  requisitions (EBAN item category 7). It projects open `MENGE - BSMNG` by
  requested date, converts to the base unit, identifies rows as `STO_PR`, and
  exposes issuing plant `RESWK` as `source_plant`. The option flows through
  dated allocation, component replenishment, component previews, and
  multi-sales-order previews/reservations. It remains separate from direct
  vendor PRs and stock-transfer orders.
- Added local coverage for source selection/traceability, default-off and
  enabled dated allocation, component replenishment, and sales-order preview.
  Verification after stock-transfer requisition projection: `npm.cmd test`
  passed; abaplint reported zero issues across 77 files and the transpiler ran
  all 409 ABAP Unit methods. `git diff --check` passed.
- Added opt-in planned-order supply from `PLAF`, distinct from released
  production orders. The projection excludes fixed orders, planning scenarios,
  special stock, and sales-order-specific proposals. It converts `GSMNG` to the
  material base unit, dates supply by `PEDTR`, and requires the basic start and
  finish dates to fall within the
  current allocation horizon. `PLANNED_ORDER` preserves the source order number.
  The new flag defaults off and flows through stock allocation, component
  replenishment and previews, and sales-order dated preview/reservation APIs.
- Added calculator and service-double coverage for unit conversion,
  default-off behavior, dated availability, replenishment netting, and the
  component and sales-order flows. Planned-order database selection remains
  unverified against a live SAP release; see `ANOMALIES.md` for the field and
  lifecycle assumptions.
- Verification after planned-order supply support: `npm.cmd test` passed;
  abaplint reported zero issues across 79 files and the transpiler ran all 413
  ABAP Unit methods. `git diff --check` passed.
- Added a bulk read-only purchasing info-record candidate lookup keyed by
  material, plant, purchasing organization, and delivery date. It filters
  standard, nondeleted candidates within inclusive validity dates, keeps both
  plant-specific and organization-level records, and ranks an optional
  preferred vendor first followed by plant-specific matches. It returns all
  matches so the caller can apply configured SAP source-list/quota/contract
  rules and choose the source. Local service
  tests cover ranking, date boundaries, filtering, and invalid requests; the
  live EINA/EINE join still needs target-release validation.
- Added optional request-level preferred-vendor ranking to source candidates.
  Preferred vendors sort before plant-specific scope; both flags are returned
  and all valid matches remain visible for caller review. Added coverage for a
  preferred organization-level candidate outranking a plant-specific record.
- Included the info-record's inclusive `valid_from`/`valid_to` dates in each
  candidate so callers can display the matched source window alongside the
  requested delivery date.
- Latest verification after source candidate ranking and validity details:
  `npm.cmd test` passed; abaplint reported zero issues across 83 files, the
  transpiler wrote 699 objects, and the transpiler ran all 417 ABAP Unit
  methods. `git diff --check` passed.
- Extended purchasing-source review with plant source-list rules. The repository
  bulk-reads `MARC-KORDB` and `EORD`; blocked matching sources are excluded, and
  mandatory source lists require an unblocked entry covering the delivery date.
  Only vendor-only source-list records validate an info-record candidate;
  outline-agreement entries remain separate sources.
  Candidates expose fixed-source and MRP-use flags plus the source-list record
  and validity period, and return the material's quota-arrangement usage flag.
  When quota usage is configured, the service reads active classic
  external-supplier items from `EQUK`/`EQUP`, calculates their documented
  `(allocated + base) / quota` rating, and ranks matching quota items before
  the existing fixed-source, preferred-vendor, and plant-specific signals.
  Equal zero ratings use higher quota first. Candidates with no matching quota
  item remain available after assigned quota candidates. Tests cover quota
  ratings, zero-rating ties, and avoiding quota reads when `MARC-USEQU` is
  unset, alongside source-list filtering and date rules.
  This remains an advisory snapshot: it does not reserve quota, model splitting
  quotas or special procurement, or replace SAP source determination.
- Verification after quota-aware candidate ranking: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 702
  objects, and the project contains 425 ABAP Unit test methods.
  `git diff --check` passed. The `EQUK`/`EQUP` SQL has not been executed against a live
  SAP system.
- Added a bulk `TMQ2` read keyed by the material's `MARC-USEQU` code. Candidate
  results now carry the configured inclusion flags for requisitions, purchase
  orders, scheduling-agreement schedules, planned orders, automatic MRP,
  production orders, and invoices; quota items are loaded only when a matching
  usage rule exists. For direct requisition previews, equal quota ratings now
  follow quota item sequence. SAP Help and its direct requisition sourcing
  guidance describe different zero-rating tie behavior, so the discrepancy and
  target-workflow validation are documented in `ANOMALIES.md`.
- Verification after quota-usage context support: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, transpilation wrote 703
  objects, and 426 ABAP Unit test methods are present. `git diff --check`
  passed. The `TMQ2`/`EQUK`/`EQUP` queries still need target-system validation.
- Added `EINE-AUT_SOURCE` to the info-record read and expose it on each candidate
  as `is_auto_source_relevant`. This closes the automatic-sourcing visibility
  gap while retaining non-marked records for manual review; the flag does not
  replace source determination. SAP identifies the field in KBA 2411004 and
  documents its MRP role. Tests cover both marked and unmarked candidate
  results. The backend `EINE` field and query still need target-release
  validation.
- Verification after automatic-sourcing metadata: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, transpilation wrote 703
  objects, and the project contains 427 ABAP Unit test methods.
  `git diff --check` passed.
- Added optional base-unit request quantities to source candidate lookup.
  Candidates now return `EINE-MINBM`/`EINE-BSTMA` in the purchasing unit and
  converted bounds using `EINA-UMREZ`/`UMREN`; `quantity_limit_status` reports
  inclusive range, below/above limit, unit mismatch, missing conversion, or
  invalid range. Requests without a quantity retain the candidate and report
  `NOT_REQUESTED`. The result is advisory because SAP MRP may handle minimum
  quantities differently by workflow; see `ANOMALIES.md`.
- Verification after quantity-range preview: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, transpilation wrote 703 objects, and
  431 ABAP Unit test methods are present. The transpiled runner executed the
  source-candidate boundary, conversion, unit-mismatch, missing-conversion,
  invalid-range, and request-validation tests. `git diff --check` passed.
- Added `GET_VALID_OUTLINE_SOURCES` as a separate read-only preview for
  source-list-linked purchase contracts and scheduling agreements. It joins
  the source-list entry to its purchasing document and item, filters agreement
  category and both validity windows, excludes blocked/deleted/completed rows
  and source-list/header vendor mismatches, honors vendor-level source blocks,
  and returns fixed-source, MRP-use, and preferred-vendor details. Fixed sources
  rank ahead of the preferred vendor. It does not resolve SAP release status,
  agreement capacity, prices, schedule lines, or final source assignment.
- Added repository-double coverage for result metadata/ranking, validity and
  lifecycle filters, vendor-level blocks, and invalid requests. Extended the
  local EKKO stub with the fields used by the read.
- Carried caller-selected outline agreements through replenishment policies
  and suggestions into purchase-requisition items. The mapper sends `AGREEMENT`
  and `AGMT_ITEM` plus their update flags; the requisition service also passes
  the selected vendor and purchasing organization. Info-record and agreement
  references are exclusive, and incomplete pairs are rejected before writing.
- Added coverage for agreement-reference propagation in component suggestions,
  PR creation inputs, BAPI item mapping, and rejection of partial or mixed
  source identities. Expanded the local BAPI input and update-flag stubs.
- Verification after the agreement-source requisition path: `npm.cmd test`
  passed; abaplint reported zero issues across 83 files, the transpiler wrote
  703 objects, and all 436 ABAP Unit methods ran. `git diff --check` passed.
- Added an opt-in scheduling-agreement receipt source to projected-receipt
  reads and component replenishment suggestions. It projects open external
  standard-item schedule quantities by delivery date and returns agreement,
  item, and schedule-line identity; it remains disabled by default.
- Separated purchasing-document categories in the existing PO receipt query,
  so scheduling-agreement lines cannot leak into the PO source when the new
  flag is false. Fixture tests cover opt-in filtering and source identity.
- Verification after scheduling-agreement receipt support: `npm.cmd test`
  passed; abaplint reported zero issues across 83 files, the transpiler wrote
  703 objects, and all 438 ABAP Unit methods ran. `git diff --check` passed.
- Extended the scheduling-agreement switch through dated stock availability,
  single, bulk, unit-aware, plant-source and ATP allocation paths, component
  stock/ATP previews, and multi-sales-order previews/reservations. The dated
  repository aggregates scheduling-agreement quantities through the shared
  projected-receipt source; these quantities affect local estimates, not SAP
  ATP requests.
- Added coverage for dated stock allocation, component preview, sales-order
  preview, and simulated reservation propagation with the switch both off and
  on. Updated the README and anomaly notes with the wider API coverage and ATP
  behavior.
- Verification after dated scheduling-agreement support: `npm.cmd test`
  passed; abaplint reported zero issues across 83 files, the transpiler wrote
  703 objects, and all 439 ABAP Unit methods ran. `git diff --check` passed.
- Added optional `iv_require_auto_source` filtering to purchasing info-record
  candidates. The default still exposes unmarked records for review; callers
  can require `EINE-AUT_SOURCE = 'X'` when they need that indicator. Expanded
  the existing test to cover default and filtered results.
- Verification after automatic-sourcing filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 439 ABAP Unit methods ran. `git diff --check` passed.
- Added optional `iv_require_source_listed` filtering to info-record
  candidates. The default keeps unlisted valid records when source lists are
  not mandatory; callers can require an active matching vendor entry, subject
  to the existing date, block, and outline-agreement rules. Tests cover both
  default visibility and opt-in filtering.
- Verification after source-list filtering: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 440 ABAP Unit methods ran. `git diff --check` passed.
- Validated both source-candidate filter flags before processing requests, so
  unsupported `abap_bool` values raise `zcx_invalid_stock_request`, including
  for an empty request table. Added test coverage for each invalid option.
- Verification after source-filter validation: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 441 ABAP Unit methods ran. `git diff --check` passed.
- Added `iv_require_mrp_relevant` to require a matching listed source with its
  `EORD-AUTET` automatic-MRP usage set. Tests distinguish general source-list
  membership from MRP-relevant membership; all source-filter booleans are
  validated even for empty request lists.
- Verification after MRP source-list filtering: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 441 ABAP Unit methods ran. `git diff --check` passed.
- Added caller-supplied integer priority to dated plant/material demands. Earlier
  required dates still allocate first; within a date, larger priorities allocate
  before smaller values, with input order breaking ties. Results remain in input
  order and echo priority. The unit-aware wrapper carries the same priority
  through base-unit conversion; ATP checks remain grouped by date.
- Added coverage proving date precedence, descending same-date priority, stable
  ties, input-order results, and priority propagation through unit conversion.
- Verification after dated request priorities: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  the runner passed all 443 ABAP Unit methods. `git diff --check` passed.
- Corrected the recent scheduling and source-filter test counts above after
  comparing them with the executable test-method inventory.
- Extended dated request priority to cross-plant demand allocation and its
  unit-aware wrapper. Earlier dates still win; higher same-date priority is
  allocated first while each request keeps its caller-ordered source plants.
  Priority is echoed in demand summaries and source-plant split rows; ATP stays
  grouped by material, source plant, unit, and date.
- Added tests for cross-plant priority, output ordering, source split order,
  date precedence, and unit conversion.
- Verification after cross-plant demand priorities: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and the runner passed all 445 ABAP Unit methods. `git diff --check`
  passed.
- Extended same-date caller priority to cross-plant FEFO allocation, its
  unit-aware wrapper, and its ATP preview path. Earlier dates still take shared
  batches first; within each date, higher priority consumes eligible batches
  first while each request retains source-plant order. Priority is echoed on
  demand, source, and batch split rows; ATP remains grouped by date.
- Expanded FEFO tests to prove earlier-date precedence over a higher later
  priority, priority ordering within a date, FEFO batch choice, input-order
  results, and priority propagation through unit conversion.
- Verification after dated FEFO priorities: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  the runner passed all 445 ABAP Unit methods. `git diff --check` passed.
- Added HB replenishment up to maximum stock for supplied component shortages.
  The policy repository reads `MARC-MABST`; caller policies can supply the same
  maximum-stock value. Suggestions cover the remaining shortage or top up to
  the configured maximum, whichever is larger. Added material-master and
  caller-policy tests for both cases, and documented that this is not a full
  MRP stock/requirements calculation.
- Verification after HB maximum-stock sizing: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 446 ABAP Unit methods passed. `git diff --check` passed.
- Added opt-in `iv_require_qty_in_range` filtering to purchase-info-record
  candidates. For requests with a quantity, it retains only candidates whose
  converted minimum/maximum status is within range. Requests without a quantity
  remain reviewable; the filter is disabled by default because MRP does not
  necessarily enforce every maintained minimum quantity. Boolean validation
  also covers empty request lists.
- Verification after quantity-feasible source filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 446 ABAP Unit methods passed. `git diff --check` passed.
- Added opt-in sequential quota simulation to `GET_VALID_PIR_CANDIDATES`.
  Requests are evaluated by material, plant, due date, and input order; each
  selected source is added to a local quota balance when a positive request
  quantity is supplied and the quota usage rule counts purchase requisitions.
  Later candidate rankings use the updated local rating while the existing
  quota fields continue to show the stored snapshot. The nested
  `quota_simulation` result reports the selected source and pre-request quota
  rating and balance. It remains a local preview and does not write SAP quota
  data. Added coverage for due-date sequencing, changed later selection,
  unchanged default rankings, quota-usage configuration, and unit validation.
- Verification after sequential quota simulation: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added optional `iv_require_mrp_relevant` filtering to
  `GET_VALID_OUTLINE_SOURCES`. The default retains valid agreements for manual
  review; callers can require a matching source-list agreement entry marked
  for automatic MRP. Invalid filter values are rejected even for empty input.
  Tests cover the default list, filtered list, and invalid boolean validation.
- Verification after outline-source MRP filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added independent `iv_require_fixed_source` filtering to
  `GET_VALID_OUTLINE_SOURCES`. Callers can require the source-list fixed
  indicator; the default keeps non-fixed valid agreements visible. Invalid
  filter values are rejected even for empty input, with test coverage alongside
  the MRP-relevance filter.
- Verification after outline-source fixed filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added the matching `iv_require_fixed_source` option to
  `GET_VALID_PIR_CANDIDATES`, so callers can require that an info-record source
  list entry is fixed; unlisted and non-fixed sources are omitted only when
  requested. Empty-request boolean validation and fixed/non-fixed result cases
  are covered by the existing source-list tests.
- Verification after PIR fixed-source filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added integer request priority to source-preview requests. Quota simulation
  processes earlier delivery dates first, then higher priorities within a date,
  using input position to break ties; candidate output remains in input order
  and echoes the priority. Added same-date quota-consumption coverage where the
  higher-priority later input receives the first quota item.
- Verification after priority-aware quota simulation: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added per-request `candidate_rank` to PIR and outline-source results. PIR
  ranks preserve either the stored quota ordering or the simulated ordering;
  outline ranks preserve fixed-source and preferred-vendor ordering. Tests
  verify rank sequence in both APIs and the per-request rank reset during
  quota simulation.
- Verification after explicit source candidate ranks: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added calendar-month (`MB`) lot sizing to component replenishment previews.
  Same-material/plant/unit shortages in a calendar month consolidate into one
  suggestion after projected receipts are applied against each shortage date.
  The result reports period bounds and grouped shortage count; the first
  shortage date drives the timing estimate. Added a leap-year month-boundary
  case with a receipt between two shortage dates and a second monthly group.
  The advisory limitations around planning-calendar settings and aggregated
  affected-order counts are recorded in `ANOMALIES.md`.
- Verification after monthly `MB` grouping: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 449 ABAP Unit methods passed. `git diff --check` passed.
- Added weekly (`WB`) component replenishment grouping, with caller-selectable
  `iv_week_start_weekday` from Monday=1 through Sunday=7 (default Monday).
  Date-specific projected receipts are netted before the weekly total is
  lot-sized. Tests cover a week crossing the year boundary, a between-demand
  receipt, a Sunday-start week, and invalid weekday input. SAP's planning
  calendar and full MRP behavior remain outside this preview; see `ANOMALIES.md`.
- Verification after weekly `WB` grouping: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 450 ABAP Unit methods passed. `git diff --check` passed.
- Added planning-calendar (`PK`) replenishment grouping from resolved SAP
  `T439I` periods. The MARC policy read now returns `MRPPP`; the service bulk
  loads overlapping plant/calendar windows for shortage horizons, while
  caller-supplied periods can bypass that lookup. It validates period bounds and
  overlap, nets projected receipts before lot sizing, and keeps shortages
  without a matching period at date level. See `ANOMALIES.md` for the limits.
- Verification after `PK` grouping and `T439I` loading: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 452 ABAP Unit methods passed. `git diff --check` passed.
- Added `EQUP-MAXMG` to the quota arrangement repository read and candidate
  snapshot. Split previews now omit exhausted items and recalculate shares when
  a proposed share, including minimum-lot expansion, would reach the item
  maximum; below-threshold requests try the next ranked eligible item.
- Sequential quota assignment also omits exhausted items and skips a proposed
  base-unit request that would reach the maximum when `TMQ2` counts purchase
  requisitions. The previews use stored `QUMNG` snapshots and do not reserve
  quota; see `ANOMALIES.md` for scope limits and target-release checks.
- Verification after quota-maximum eligibility: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 453 ABAP Unit methods passed. `git diff --check` passed.
- Added optional `affected_production_orders` identities to component shortage
  rows and replenishment suggestions. `SUMMARIZE_COMPONENT_SHORTAGES` supplies
  distinct order IDs; monthly, weekly, and planning-calendar groups now union
  complete identity lists and count an order once across dates. Legacy or mixed
  inputs retain additive counts and omit partial order lists. Supplied lists
  reject blank IDs or a mismatch with `affected_order_count`.
- Verification after period-group affected-order deduplication:
  `npm.cmd test` passed; abaplint reported zero issues across 86 files, the
  transpiler wrote 707 objects, and all 453 ABAP Unit methods passed.
- Added `CANCEL_COMPONENT_ISSUE` to reverse a posted component issue by its
  material document, fiscal year, and optional item numbers. It shares the
  goods movement API instance used for issue posting and reuses cancellation's
  validation, commit, and rollback path. Tests cover selected-line routing and
  commit. This cancels complete document lines; partial-quantity returns are
  handled separately by `RETURN_COMPONENTS` and `RETURN_COMPONENTS_BULK`.
- Verification after component issue cancellation: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 454 ABAP Unit methods passed. `git diff --check` passed.
- Added `RETURN_COMPONENTS` and `RETURN_COMPONENTS_BULK` for partial returns
  against production component reservations. The service requires a live
  movement-type-261 component with a positive withdrawn balance, validates the
  requested return against `RESB-ENMNG` and reservation detail, and submits
  BAPI goods movement code 06 with `XSTOB` so SAP derives movement type 262.
  Unit coverage includes a partial return against a final-issue reservation
  and rejection above the withdrawn balance. A bulk case posts returns for
  two production orders in one material document.
- Verification after partial component returns: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 707 objects, and
  all 459 ABAP Unit methods passed. `git diff --check` passed.
- Updated `SIMULATE_SPLIT_QUOTA` for an only-once source whose ratio share
  exceeds `MAXLS`: it assigns one max-lot proposal, removes that source, and
  recalculates the remaining shares over eligible candidates. Below-threshold
  remainders continue through ranked fallback; the preview rejects when no
  alternate source can cover the request. Tests cover proportional
  redistribution, below-threshold fallback, and the no-alternate case.
- Verification after once-only max-lot redistribution: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 459 ABAP Unit methods passed. `git diff --check` passed.
- Extended `SIMULATE_SPLIT_QUOTA` so a non-once source that reaches `MAXLS`
  emits one max-lot proposal and recalculates shares for the remaining demand.
  Its simulated `QUMNG` is advanced for `MAXMG` checks; only-once sources still
  leave the candidate pool after one proposal. Tests cover repeated max lots,
  minimum-lot interaction, cumulative `MAXMG` eligibility, and exact demand
  conservation. SAP's split-quota documentation confirms that shares use quota
  values, while the lot-size documentation describes quota redetermination
  after maximum-sized proposals.
- Verification after iterative max-lot re-rating: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 459 ABAP Unit methods passed. `git diff --check` passed.
- Added quota-item static rounding-profile support to `SIMULATE_SPLIT_QUOTA`.
  Candidate lookup exposes `EQUP-RDPRF`; the repository loads plant/profile
  levels from `RDPR`, and each proposal uses the threshold-based upward rounding
  procedure. Rounded quantities participate in `MAXMG` eligibility. The preview
  rejects a rounding result above `MAXLS`. Tests cover threshold examples,
  unchanged quantities below the lowest threshold, max-lot proposals, the
  `MAXMG` boundary, and incompatible profile/max-lot settings.
- Verification after quota-item rounding profiles: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 459 ABAP Unit methods passed. `git diff --check` passed.
- Added static material and caller rounding-profile support to
  `SUGGEST_COMP_REPLENISHMENT`. The policy read returns `MARC-RDPRF`, then
  loads threshold levels from `RDPR`; each modeled receipt is rounded after
  lot sizing, and totals, receipt counts, final receipt sizes, and rounding
  surplus reflect that result. Missing profile data and rounded quantities
  above maximum lot size are rejected. The requisition creator validates and
  emits fixed-lot receipts at the rounded final quantity while preserving the
  original fixed-lot setting. Tests cover caller and MARC profiles, fixed-lot
  and max-lot splits, PR item creation, and both rejection cases.
- Verification after replenishment rounding profiles: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 462 ABAP Unit methods passed. `git diff --check` passed.
- Added `get_suggestion_pir_candidates` to connect replenishment suggestions
  with the existing ranked standard PIR lookup. It maps each candidate back to
  the original suggestion index, passes quantity/date/purchasing-organization
  context through existing source filters and quota logic, and leaves source
  selection to the caller. Internal, special-source, covered, and
  unspecified-procurement rows are omitted; outline agreements remain separate.
  Tests cover filtered-index mapping, delivery-date propagation, quantity-limit
  evaluation, and the required purchasing organization.
- Verification after suggestion source options: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 464 ABAP Unit methods passed. `git diff --check` passed.
- Added `get_suggestion_outline_sources` to connect eligible replenishment
  suggestions with ranked outline-agreement candidates. It returns contract and
  scheduling-agreement options mapped to original suggestion indexes, passes
  the suggested quantity/unit and required date, and supports preferred-vendor,
  fixed-source, and MRP-relevant filtering. It leaves source selection to the
  caller. Tests cover filtered-index mapping, ranking, date propagation, and
  required purchasing organization.
- Verification after suggestion outline options: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 466 ABAP Unit methods passed. `git diff --check` passed.
- Added `get_suggestion_source_options` as a combined view over standard PIR and
  outline agreement suggestions. It returns the original suggestion index,
  source kind, local candidate rank, and the matching typed candidate; results
  are grouped by suggestion with PIR before outline options. Ranking remains
  local to each source kind and no source is assigned. A combined lookup test
  checks the two option variants and their source identities.
- Verification after combined suggestion sources: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 467 ABAP Unit methods passed. `git diff --check` passed.
- Added `apply_suggestion_source_option` to copy a selected PIR or agreement
  identity onto the indexed replenishment suggestion. It checks the candidate
  against the unchanged suggestion's material, plant, and date, clears the
  unselected source fields, and preserves the caller's original table. It does
  not reread customizing; SAP remains the final source validator at requisition
  creation. Tests cover both source mappings and mismatched-candidate rejection.
- Verification after applying source options: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 708 objects, and
  all 469 ABAP Unit methods passed. `git diff --check` passed.
- Added `apply_selected_source_options` for applying a set of reviewed source
  choices to multiple suggestions in one call. It returns a copied table,
  leaves unselected rows unchanged, reuses the single-option consistency
  checks, and rejects duplicate choices for one suggestion. Tests cover mixed
  PIR/agreement application and duplicate selection rejection.
- Verification after bulk source selection: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 708 objects, and
  all 471 ABAP Unit methods passed. `git diff --check` passed.
- Added `create_from_selected_sources` to connect reviewed PIR/agreement
  options directly to the existing purchase-requisition workflow. It applies
  chosen options to a copied suggestion list, then runs the same validation,
  BAPI simulation/write, and commit behavior as `create_from_suggestions`.
  Unselected rows retain normal SAP source determination. An integration test
  submits both PIR and agreement identities through the fake API.
- Verification after selected-source requisition creation: `npm.cmd test`
  passed; abaplint reported zero issues across 86 files, the transpiler wrote
  708 objects, and all 472 ABAP Unit methods passed. `git diff --check` passed.
- Added `ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_ALLOCATION` to build a single
  `UB` stock transport order for one selected source/target plant pair from
  dated unit-aware allocation rows. Items preserve source units and demand
  dates; short allocation is rejected by default, and BAPI test runs skip the
  commit. A BAPI adapter maps purchase-order items and schedule lines, with
  transaction commit/rollback handling. Tests cover source-pair selection,
  order mapping, test-run behavior, shortfall rejection, and rollback after
  create or commit errors.
- Verification after STO creation: `npm.cmd test` passed; abaplint reported
  zero issues across 90 files, the transpiler wrote 718 objects, and all 477
  ABAP Unit methods passed. `git diff --check` passed.
- Added `ISSUE_STOCK_TRANSPORT_ORDER` to post movement 351 against a selected
  STO item from the supplying plant/storage location, with optional batch and
  test-run support. The service uses BAPI movement code 04 and SAP's blank
  movement-indicator rule, then reuses the existing commit/rollback flow.
  Tests cover the BAPI payload, simulation, and rejection of incomplete issue
  data.
- Verification after STO goods issue support: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 480 ABAP Unit methods passed. `git diff --check` passed.
- Added the companion `RECEIVE_STOCK_TRANSPORT_ORDER` helper for 101 receipts
  against STO PO items. It maps indicator `B`, source item identity, quantity,
  units, and optional receiving plant/location/material/batch; test runs reuse
  the same no-commit behavior. Tests cover payload mapping, simulation, and
  incomplete-item rejection.
- Verification after STO goods receipt support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 483 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FROM_SOURCE_PLANTS` to turn the positive allocation rows for one
  receiving plant into one prevalidated STO request per supplying plant,
  preserving source priority. It attempts each independent order and returns
  per-source committed results plus an aggregate success flag; later suppliers
  still run if one BAPI creation fails. Tests cover grouping, no writes before
  full validation, and partial failure reporting.
- Verification after grouped STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 486 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FOR_ALL_PLANT_PAIRS` for dated unit-aware allocations spanning
  multiple receiving plants. It creates one request per positive source/target
  pair, applies a validated target-plant storage-location map, and prepares all
  requests before writing. Per-pair results preserve independent commit status.
  Tests cover pair grouping, target-location mapping, prevalidation, and partial
  BAPI failure reporting.
- Verification after all-pair STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 489 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FROM_BATCH_ALLOCATION` for unit-aware exact-batch allocations.
  Each selected request/material/batch becomes a separate STO item, preserving
  batch and source-unit quantity; the caller supplies the schedule date because
  this allocator does not produce one. The BAPI adapter maps `BATCH` and its
  item-X flag. Tests cover batch/unit/date mapping and reject missing batch
  identity before any write. Verify target-system behavior with the site's SAP
  release and batch configuration.
- Verification after batch-aware STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 491 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FOR_BATCH_PAIRS` to carry exact-batch allocations through the
  multi-target STO workflow. It prepares one batch-preserving `UB` order per
  source/target pair, applies validated receiving-location mappings, and keeps
  independent per-order commit results. Tests cover multi-target batch splits
  and reject a malformed later pair before any BAPI call.
- Verification after multi-pair batch STO creation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 493 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FOR_FEFO_PAIRS` to build one STO per positive pair from dated,
  unit-aware FEFO output. It preserves selected batch/location splits, maps
  the issuing storage location to `SUPPL_STLOC`, uses each split's required
  date, and applies target-plant receiving-location mappings. Tests verify
  batch, both storage locations, source-unit quantity, per-split dates, and
  all-pair validation before the first write. SAP's STO availability check
  does not check batch stock when a batch is entered, so posting remains a
  later revalidation step.
- Verification after FEFO-aware STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 495 ABAP Unit methods passed. `git diff --check` passed.
- Added `ISSUE_CREATED_STO` as a bridge from a committed STO result to the
  existing 351 goods-issue path. It maps PO item identity, selected batch,
  source plant/location, quantity, and caller-supplied unit ISO data, and
  rejects uncommitted/test-run orders or incomplete items before the BAPI.
  Tests cover payload preservation and missing commit/unit-ISO validation.
- Verification after the committed-STO issue bridge: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 498 ABAP Unit methods passed. `git diff --check` passed.
- Added `ISSUE_CREATED_STO_PAIRS` to dispatch multi-pair STO creation results.
  It prevalidates every successful, committed PO before issuing, skips failed
  creations, and continues across independent 351 transactions after a pair
  failure. Per-pair results preserve STO status, issue result, attempted state,
  and committed in-transit state. Tests cover multiple POs, a later issue
  failure, and no writes when a later PO item is malformed.
- Verification after multi-pair STO issue support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 502 ABAP Unit methods passed. `git diff --check` passed.
- Added `RECEIVE_ISSUED_STO` and `RECEIVE_ISSUED_STO_PAIRS` to continue the
  no-delivery STO lifecycle from committed in-transit issue results. They copy
  PO item, batch, receiving
  plant/location, quantity, and caller-mapped ISO unit into one 101 per PO.
  It prevalidates eligible pairs, skips pairs not in transit, preserves transit
  after failed or simulated receipts, and continues after an individual receipt
  failure. Tests cover single and multiple orders, payload mapping, partial failure,
  simulation, and prevalidation before the first BAPI call.
- Verification after multi-pair STO receipt support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 508 ABAP Unit methods passed. `git diff --check` passed.
- Added `CANCEL_ISSUED_STO` and `CANCEL_ISSUED_STO_PAIRS` to reverse committed
  351 issue material documents while their issue results still show in-transit
  stock. Every eligible PO document/year is validated before the first cancel;
  each cancellation commits independently, and a failed reversal leaves that
  pair in transit while later pairs continue. SAP's cancellation BAPI has no
  test-run mode, so SAP remains the authority for whether document history and
  current stock allow reversal. Tests cover single and multiple documents,
  independent failure, and all-document prevalidation.
- Verification after STO issue cancellation support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 512 ABAP Unit methods passed. `git diff --check` passed.
- Added opt-in fixed planned-order receipts through `PLAF-AUFFX`, while keeping
  the existing `iv_include_planned_receipts` flag scoped to unfixed orders.
  `iv_include_fixed_planned` returns fixed rows as `FIXED_PLAN_ORDER` and can
  be combined with the unfixed flag. The option flows through dated stock reads
  and allocations, production component previews, and component replenishment
  suggestions. Corrected the PLAF selection so the fixed-order branch is not
  suppressed by an unconditional blank-`AUFFX` filter. Tests cover both flag
  combinations, component supply netting, and invalid option values. Target SAP
  SQL and DDIC behavior still require validation; see `ANOMALIES.md`.
- Verification after fixed planned-order receipts: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 512 ABAP Unit methods passed. `git diff --check` passed.
- Added `CANCEL_RECEIVED_STO` and `CANCEL_RECEIVED_STO_PAIRS` to reverse a
  committed 101 receipt from its receipt result. Eligible documents are all
  validated before cancellation starts, each reversal commits independently,
  and successful reversals return the pair to in-transit state so callers can
  then reverse the original 351 issue. Failed receipts remain received while
  later documents continue. Tests cover single and multiple receipts, partial
  failure, and prevalidation before the first BAPI call.
- Verification after received-STO cancellation support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 515 ABAP Unit methods passed. `git diff --check` passed.
- Added `CANCEL_STO_RECEIPT_CHAIN` and `CANCEL_STO_RECEIPT_CHAIN_PAIRS` to
  reverse both committed goods movements for received STO pairs. They validate
  every eligible 101 and 351 document/year key before the first cancellation,
  reverse 101 first, and reverse 351 only when the receipt reversal succeeds.
  Results distinguish receipt reversal, issue reversal, in-transit state, and
  complete movement reversal. Tests cover the successful chain, failures at
  both reversal steps with later-pair processing, and all-pair prevalidation.
- Verification after STO receipt-chain cancellation support: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 519 ABAP Unit methods passed. `git diff --check` passed.
- Added `MARK_STO_FOR_DELETION` and `MARK_STO_PAIRS_FOR_DELETION` to set the
  item deletion indicator on eligible items from committed STO creation results.
  The pair workflow prevalidates eligible item identities, skips failed,
  simulated, or uncommitted orders, commits each PO independently, and
  continues after item/API/commit failures. Local tests cover success, skip,
  prevalidation, independent failure, and rollback behavior. SAP retains
  eligibility checks and this operation marks items logically rather than
  physically deleting a PO; see `ANOMALIES.md`.
- Verification after STO deletion-indicator support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 524 ABAP Unit methods passed.
- Added `MARK_STO_DELIVERY_COMPLETE` and `MARK_STO_PAIRS_DELIV_COMPLETE` to set
  the purchase-order delivery-completed indicator on submitted items from
  committed STO results. SAP can close the remaining open PO quantity even
  after partial receipt, so this method represents a business decision that no
  more receipt is expected; it does not post stock. Tests cover single and
  multi-pair calls, independent failures, prevalidation, skipping uncommitted
  orders, and rollback after a failed commit. SAP-side BAPI behavior, including
  split valuation cases, remains a target-system check documented in
  `ANOMALIES.md`.
- Verification after STO delivery-completion support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 529 ABAP Unit methods passed.
- Added caller-supplied `it_demand_priorities` to multi-sales-order dated
  previews and reservations. Priorities key sales document, item, and schedule
  line; higher values win only within the same material/plant/date, while
  earlier dates and stable input-order ties remain unchanged. Invalid, duplicate,
  foreign-order, or unknown item/schedule keys fail before physical allocation.
  Each returned sales-unit allocation echoes the applied priority. Tests cover
  equal-date prioritization, reservation propagation, and invalid-order-key
  rejection. ATP remains cumulative by date and is not reordered by local
  priority; see `ANOMALIES.md`.
- Verification after multi-order demand priority: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 532 ABAP Unit methods passed.
- Aligned sequential `BAPI_RESERVATION_CREATE1` calls with same-date caller
  priorities in `reserve_orders_by_date`; the API adapter processes reservations
  one at a time, so the higher-priority requests are now sent first. Added a
  regression test that verifies the actual request order when both demands fit.
- Verification after priority-aware reservation sequencing: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 533 ABAP Unit methods passed. `git diff --check` passed.
- Added optional `it_item_priorities` to single-order previews and reservations.
  Same-date item/schedule lines now use caller priority after requested date;
  earlier dates still win, omitted values default to zero, and ties retain the
  order's source sequence. Invalid and duplicate keys fail before stock
  allocation. Sales-unit results echo the applied priority, and reservation
  BAPI calls follow the same order. A test caught and fixed source-index capture
  after priority-map lookup. ATP remains cumulative by date; see `ANOMALIES.md`.
- Verification after single-order item priority: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 536 ABAP Unit methods passed.
- Extended sales-order `atp_checks` with the caller priority for each item or
  schedule line in both single-order and multi-order previews. The SAP request
  still aggregates demand by date, and confirmation quantities remain shared at
  that date level. Added checks that both APIs echo priority without changing
  the cumulative ATP quantity.
- Verification after ATP priority diagnostics: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 537 ABAP Unit methods passed.
- Added optional `iv_check_atp` and `iv_atp_check_rule` to `reserve_order` and
  returned its per-line ATP diagnostics in the reservation result. The check
  uses the same grouped logic as `preview_order`, validates dates and rule
  before stock reads, and remains diagnostic; the reservation BAPI performs its
  own ATP check. Extended coverage for priority propagation and missing-rule
  rejection.
- Verification after single-order reservation ATP diagnostics: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 537 ABAP Unit methods passed.
- Added `iv_require_atp_confirmation` to single-order and multi-order
  reservations. It requires `iv_check_atp`, compares each cumulative date
  confirmation to its demand, and returns the ATP diagnostics without calling
  the reservation API if any date is short. The reservation BAPI still performs
  its own ATP check. Tests cover short and full confirmations in both flows and
  reject the gate when ATP checking is omitted, and reject invalid boolean
  values before repository reads.
- Verification after ATP-gated reservations: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 541 ABAP Unit methods passed.
- Extended the ATP precheck and strict confirmation gate to cost-center
  reservations. The gate compares the confirmed base quantity with the full
  requested base quantity and blocks the reservation API on a short response;
  tests cover short and full confirmation, missing ATP enablement, missing
  check rules, and invalid gate values.
- Latest verification after cost-center ATP-gated reservations: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 544 ABAP Unit methods passed.
- Passed required dates to the shared ATP confirmation splitter from dated
  stock, cross-plant/FEFO, sales-order, and cost-center flows. Confirmation
  lines after the demand date, plus undated lines, remain in the raw SAP result
  but no longer count as confirmed for that date. Added strict-gate tests for
  later confirmations and updated dated fixtures.
- Latest verification after date-scoped ATP confirmation splits:
  `npm.cmd test` passed; abaplint reported zero issues across 90 files, the
  transpiler wrote 718 objects, and all 547 ABAP Unit methods passed.
- Added `CREATE_FROM_ATP_SOURCE_PLANTS`, which accepts dated plant-allocation
  ATP results and prevalidates a matching full confirmation for every positive
  source split before the first STO BAPI call. Tests cover successful multi-
  supplier creation and short-confirmation rejection with zero writes.
- Latest verification after ATP-gated STO creation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 549 ABAP Unit methods passed.
- Added opt-in `iv_atomic` mode to multi-source STO creation, including the ATP-
  gated entry point. It creates all prepared supplier orders before one shared
  commit, rolls back and stops on create or commit failure, and marks all
  returned order results uncommitted when the group fails. Added tests for the
  single shared commit, create failure rollback, and commit failure rollback.
- Latest verification after atomic multi-source STO creation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 552 ABAP Unit methods passed.
- Extended `iv_atomic` to all-pair, batch-pair, and FEFO-pair STO creation using
  a shared executor. Pair test coverage now checks one commit on success and
  group rollback on both create and commit failures.
- Latest verification after atomic multi-pair STO creation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 554 ABAP Unit methods passed.
- Added `CREATE_FOR_ATP_PLANT_PAIRS` to prevalidate full, relevant date ATP
  confirmations for every positive source/target split before creating orders
  across receiving plants. Added successful atomic creation and short-check
  rejection coverage.
- Latest verification after ATP-gated multi-pair STO creation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 556 ABAP Unit methods passed.
- Added `CREATE_FOR_ATP_FEFO_PAIRS`, which accepts FEFO plant-allocation ATP
  output, validates positive source/date totals before writes, and preserves
  batch/location items through the FEFO pair creator. Added success and short-
  confirmation tests using atomic commit mode.
- Latest verification after ATP-gated FEFO STO creation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 558 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `MARK_STO_PAIRS_FOR_DELETION`. Atomic mode refuses
  mixed or ineligible input groups before writing, stages all item changes
  before one commit, and clears every deletion result after a change or commit
  failure. Added shared-commit and rollback coverage.
- Latest verification after atomic STO pair deletion: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 562 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `MARK_STO_PAIRS_DELIV_COMPLETE`. Atomic mode
  rejects mixed or ineligible groups before writes, stages each delivery
  completion before one shared commit, and clears completion results after a
  change or commit failure. Added success, rollback, commit-failure, and
  ineligible-input coverage.
- Latest verification after atomic STO pair delivery completion: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 566 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `ISSUE_CREATED_STO_PAIRS`. Atomic mode requires
  eligible committed STOs before writes, stages every 351 movement before a
  shared commit, and reports `is_in_transit` only after that commit. A movement
  or commit failure clears the group's uncommitted material document IDs.
- Added opt-in `iv_atomic` to `RECEIVE_ISSUED_STO_PAIRS`. Atomic mode requires
  every pair to remain in transit, stages all 101 receipts in one LUW, and
  clears transit only after the shared commit. Failures roll back the group
  while preserving the in-transit state.
- Latest verification after atomic pair issue and receipt: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 574 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `CANCEL_ISSUED_STO_PAIRS`. Atomic mode requires
  every supplied issue to remain in transit, stages all 352 reversals in one
  LUW, and clears transit only after a shared commit. A reversal or commit
  failure rolls the group back and clears uncommitted reversal document IDs.
- Latest verification after atomic issue cancellation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 578 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `CANCEL_RECEIVED_STO_PAIRS`. Atomic mode requires
  every supplied receipt to remain received, stages all 102 reversals in one
  LUW, and restores transit only after the group commits. A reversal or commit
  failure rolls back the group and preserves received status.
- Latest verification after atomic receipt cancellation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 582 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `CANCEL_STO_RECEIPT_CHAIN` and
  `CANCEL_STO_RECEIPT_CHAIN_PAIRS`. Atomic mode requires every pair to be
  received, stages each 101 reversal before its matching 351 reversal, then
  commits the full group once. A cancellation or commit failure rolls back the
  group and restores received state. Tests cover the single-pair and multi-pair
  entry points, one shared commit, failure at both reversal stages, commit
  failure, and rejection before writes when a pair is not received.
  Target-release rollback behavior is documented in `ANOMALIES.md`.
- Latest verification after atomic receipt-chain cancellation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 588 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `RETRY_STO_CHAIN_ISSUE` and `RETRY_STO_CHAIN_ISSUE_PAIRS` to retry a
  pending 351 reversal from prior receipt-chain cancellation output. The retry
  validates the prior receipt reversal, preserves already completed pairs,
  leaves rows with a failed 101 reversal untouched, and can atomically commit
  the outstanding issue reversals. Tests cover recovery after a failed 351,
  grouped retry, preservation of completed rows, API failure rollback, commit
  failure, and receipt-pending rejection in atomic mode. The retry scope and
  SAP state caveat are recorded in `ANOMALIES.md`.
- Latest verification after STO issue-reversal retry support: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 594 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `RETRY_STO_CHAIN_RECEIPT` and `RETRY_STO_CHAIN_RECEIPT_PAIRS` to retry
  101 reversals for pairs still received after a failed cancellation or atomic
  chain rollback. The methods preserve completed rows and 351-pending rows,
  restore in-transit status after a successful 101 retry, and keep the
  aggregate result incomplete until the issue reversal is also complete.
  Atomic mode groups the pending 101 retries in one LUW. Tests cover recovery
  through both retry stages, group-abort recovery, shared commit, rollback, and
  commit failure; target SAP status and rollback limits are recorded in
  `ANOMALIES.md`.
- Latest verification after STO receipt-reversal retry support: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 599 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `RETRY_STO_CHAIN` and `RETRY_STO_CHAIN_PAIRS` to resume mixed
  receipt-chain cancellation results. Non-atomic recovery commits each
  outstanding stage independently; atomic recovery stages all remaining 101
  and 351 reversals in one LUW while preserving the input states on failure.
  Added tests for mixed pending stages, completed-row preservation, atomic
  rollback, and the single-pair wrapper. SAP eligibility and rollback caveats
  are recorded in `ANOMALIES.md`.
- Latest verification after composite STO chain retry: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 604 ABAP Unit methods passed, and `git diff --check`
  passed.
- Hardened plant, storage-location, and batch stock-status reads against blank
  material or plant keys. The service now raises `ZCX_INVALID_STOCK_REQUEST`
  before repository access, avoiding broad database reads from incomplete
  selection keys. Added no-read regression coverage and documented the boundary.
- Latest verification after stock-status key validation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 605 ABAP Unit methods passed, and `git diff --check`
  passed.
- Extended the stock-read key guard to `GET_UNRESTRICTED_STOCK`, and reject
  invalid `iv_protect_safety_stock` values before the repository read. Added
  regression coverage for blank material, blank plant, and invalid flags.
- Latest verification after unrestricted-stock key validation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 606 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added key validation to the sales-order reservation read methods. Single
  reads reject a blank sales document; bulk reads reject blank entries and
  return immediately for an empty input list. Added no-read coverage for each
  case and updated the stock-read assumptions.
- Latest verification after sales-order reservation key validation:
  `npm.cmd test` passed; abaplint reported zero issues across 90 files, the
  transpiler wrote 1090 output files, all 607 ABAP Unit methods passed, and
  `git diff --check` passed.
- Added `GET_STOCK_STATUS_BULK` to read keyed material/plant status requests in
  one repository call. The MARD, RESB, and MARC rows are selected in batches,
  aggregated by material/plant, and returned in request order. The service
  rejects blank fields, duplicate request IDs, and malformed repository result
  sets; empty input returns without a read. Tests cover input validation,
  output ordering, one repository call, and mismatched or missing repository
  results. SQL execution in SAP remains to be checked as recorded in
  `ANOMALIES.md`.
- Latest verification after bulk stock-status reads: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 610 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_LOCATION_STOCK_STATUS_BULK` for keyed material/plant requests. It
  batches MARD and RESB reads, aggregates by material, plant, and storage
  location, then applies the existing location reservation calculator. Results
  retain zero-available MARD locations and request order. Blank fields,
  duplicate request IDs, malformed repository results, and empty input follow
  the same validation contract as the plant-level bulk read. Both bulk RESB
  selections include reservation number and item so identical quantity rows
  stay distinct under `FOR ALL ENTRIES`; the target SQL behavior remains listed
  in `ANOMALIES.md`.
- Latest verification after bulk location stock status: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 612 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_BATCH_STOCK_STATUS_BULK` for multiple keyed material/plant
  requests. It batches MCHB stock, MCHA/MCH1 expiration-date, and RESB
  reservation reads, then reuses the batch reservation calculator. Results
  preserve request and location/batch order, retain zero-available MCHB rows,
  and resolve plant-specific expiration dates before global batch dates. The
  service rejects blank keys, duplicate request IDs, and malformed repository
  results; empty input returns without a read. Local SQL validation limits are
  in `ANOMALIES.md`.
- Latest verification after bulk batch stock status: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 614 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_FEFO_BATCH_STATUS_BULK` with a per-request as-of date and minimum
  shelf-life window. It validates the full input set before reading, performs
  one bulk batch-status read, and filters and sorts each response with the
  existing FEFO eligibility helper. Tests cover request-specific windows,
  dated-first ordering, undated batches at a zero-day minimum, zero-available
  batches, invalid inputs, and one repository call. SAP batch determination
  and ATP remain outside this local estimate, as recorded in `ANOMALIES.md`.
- Latest verification after bulk FEFO batch status: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 616 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_FEFO_BATCH_STATUS_BULK_UOM`. Each request supplies its material
  unit; the service returns eligible batch rows with quantities in that unit
  and both base/request unit codes. It caches conversion ratios by
  material/unit, validates all requests and ratios before the single batch
  stock read, and retains the same per-request FEFO filtering and ordering.
  Tests cover repeated ratio reuse, quantity conversion, different shelf-life
  windows, unit errors, and one stock read. Target-system ratio/precision and
  ATP limitations are recorded in `ANOMALIES.md`.
- Latest verification after bulk FEFO unit conversion: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 618 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_STOCK_STATUS_BULK_IN_UNIT` for keyed material/plant/unit requests.
  It validates the full request set, caches ratios by material/unit, reads
  plant statuses in one bulk call, and converts all stock, reservation,
  availability, safety-stock, quality, and blocked quantities to the requested
  units. Tests cover all converted fields, ratio reuse, input ordering, invalid
  and unknown units, empty input, and one stock read. SAP ratio and rounding
  assumptions are documented in `ANOMALIES.md`.
- Latest verification after bulk stock status unit conversion: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 620 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `GET_LOCATION_STOCK_BULK_UOM` for keyed material/plant/unit requests.
  It validates inputs and conversion ratios before reading, caches ratios by
  material/unit, performs one bulk location-status read, and converts
  unrestricted, available, quality-inspection, and blocked quantities while
  preserving zero-available locations. Tests cover request order, all converted
  fields, zero availability, repeated ratio reuse, invalid and unknown units,
  empty input, and one stock read. Target-system ratio and rounding assumptions
  are documented in `ANOMALIES.md`.
- Added `GET_BATCH_STOCK_BULK_UOM` for keyed batch-status requests with a
  requested material unit. It validates all keys and ratios before one bulk
  batch read, then converts unrestricted and available quantities while
  preserving batch, location, and expiration details, including zero-available
  batches. Tests cover request order, quantity conversion, ratio reuse, invalid
  and unknown units, empty input, and one stock read. Target-system ratio and
  rounding assumptions are documented in `ANOMALIES.md`.
- Added `GET_ORDER_RES_BULK_UOM` for keyed sales-document/material/plant/unit
  requests. It validates all keys and conversion ratios before reading,
  deduplicates sales documents for one bulk reservation read, and converts
  matching open reservation quantities while preserving request order and line
  details. Tests cover conversion, ratio reuse, ordering, invalid and unknown
  units, empty input, and one read. The assumption that repository reservation
  quantities are in the material base unit is recorded in `ANOMALIES.md` for
  target-system confirmation.
- Added `GET_PROJECTED_RECEIPTS_IN_UNIT` to return PO, STO, production,
  requisition, planned-order, and scheduling-agreement receipt rows in a
  requested material unit. It preserves source identity, dates, and both unit
  codes, validates all source flags and the conversion ratio before reading,
  and reuses the existing projection query. Tests cover converted quantities,
  source metadata, invalid flags, unknown units, and one repository read.
  Target-system conversion and rounding assumptions are in `ANOMALIES.md`.
- Added `GET_PROJECTED_RECEIPTS_BULK` for keyed material/plant/deadline
  requests with shared receipt-source flags. It preserves request order and
  returns each deadline's matching receipt rows. Repeated material/plant pairs
  share one projection through their latest deadline; empty requests and
  requests with no enabled source types perform no repository read. Tests cover
  per-deadline filtering, repeated-pair grouping, distinct-pair reads, invalid
  keys and flags, empty input, and no-source behavior. Existing SQL limitations
  are documented in `ANOMALIES.md`.
- Added `GET_PROJ_RECEIPTS_BULK_UOM` with per-request material units. It
  validates request keys and all conversion ratios before calling the bulk
  projection service, then converts quantities while preserving deadline
  filtering, source identity, request order, and base/request unit codes. Ratio
  caching is by material/unit and projection grouping remains by material/plant.
  Tests cover quantity conversion, per-deadline filtering, ratio reuse, invalid
  flags and units, duplicate IDs, and no-read cases. Target-system conversion
  assumptions are in `ANOMALIES.md`.
- Added `GET_PROJ_RECEIPTS_OPTS_BULK` with receipt-source flags on each
  material/plant/deadline request. It unions source types per material/plant,
  queries through the latest deadline, and filters each result by that row's
  own date and source options. Requests with no enabled sources skip repository
  reads, including when other request groups do have sources. Tests cover
  different source types, per-request deadline filtering, grouped reads,
  disabled source groups, duplicate IDs, invalid dates/options, and empty input.
  Existing projection SQL limitations remain documented in `ANOMALIES.md`.
- Added `GET_PROJ_RECEIPTS_OPTS_UOM` to combine per-request receipt-source
  choices and requested units. It validates all request keys, source flags,
  and unit ratios before calling the grouped projection service; results retain
  per-request filtering, source details, order, and both unit codes. Tests cover
  different source types, unit conversion, ratio reuse, malformed options,
  duplicate IDs, missing and unknown units, and empty input. Target-system UOM
  assumptions are recorded in `ANOMALIES.md`.
- Latest verification after per-request source selection with UOM:
  `npm.cmd test` passed; abaplint reported zero issues across 90 files, the
  transpiler wrote 1090 output files, all 636 ABAP Unit methods passed, and
  `git diff --check` passed.
## Latest progress

- Added `GET_STOCK_IN_TRANSFER_BULK` with request IDs and optional storage
  locations. It validates required keys and duplicate IDs before repository
  access, returns rows in request order, and lets each request aggregate either
  one location or the full plant. The repository reads MARC and MARD rows in
  bulk and applies each request's location filter. Tests cover mixed location
  aggregation, result ordering, blank keys, duplicate IDs, mismatched or
  incomplete repository output, and empty input. SAP SQL checks are documented
  in `ANOMALIES.md`.
- Added `GET_STOCK_IN_TRANSFER_BULK_UOM` for requests with material-specific
  units. It validates request IDs and conversion ratios before stock access,
  caches repeated material/unit ratios, and returns both base and converted
  quantities in request order. Tests cover conversion, ratio reuse, invalid
  units, duplicate IDs, and empty input. Target-system UOM assumptions are in
  `ANOMALIES.md`.
- Verification after the aggregate transfer bulk additions: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, ABAP Unit passed, and `git diff --check` passed.
- Added `GET_TRANSFER_BATCHES_BULK` with keyed material/plant
  requests and nested batch results. The repository reads matching `MCHB`
  rows once, and the service preserves request order while sorting each result
  by storage location and batch. Tests cover grouping, ordering, duplicate IDs,
  mismatched repository rows, and empty input; SAP query validation is noted in
  `ANOMALIES.md`.
- Added `GET_TRANSFER_BATCHES_BULK_UOM` for per-request units. It validates the
  full request set before UOM reads, caches repeated material/unit ratios, and
  returns base and converted batch quantities with the sorted batch details.
  Tests cover conversion, cache reuse, invalid units, duplicate IDs, and empty
  input; target-system conversion assumptions are in `ANOMALIES.md`.
- Verification after the bulk batch transfer additions: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, ABAP Unit passed, and `git diff --check` passed.
- Added purchasing-unit support to replenishment requisition items. A selected
  PIR source carries its EINA order-unit ratio into every split lot; callers can
  also provide a per-suggestion purchasing unit and ratio directly. The service
  validates ratios before BAPI access and returns converted item quantities
  with the submitted unit. Tests cover selected-source ratio propagation,
  split-lot conversion, direct unit controls, and invalid ratios; SAP mapping
  assumptions are in `ANOMALIES.md`.
- Verification after purchasing-unit support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, ABAP Unit passed, and `git diff --check` passed.
- Added `read_orders` to the sales order service. It validates all document
  numbers and duplicates before reading, preserves caller order, and returns
  each API result independently. Tests cover ordering, invalid lists, and empty
  input; each document still uses the standard detail BAPI, as recorded in
  `ANOMALIES.md`.
- Latest verification after the sales order multi read: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, ABAP Unit passed, and `git diff --check` passed.
- Added `change_orders_atomic` for multiple sales orders. It validates all
  documents and item lists before BAPI access, preserves one write result per
  order, and performs a single commit or group rollback; test runs skip the
  commit. Tests cover success, simulated execution, change and commit failures,
  and duplicate-key rejection. Validate the SAP LUW boundary in the target
  release as recorded in `ANOMALIES.md`.
- Added `create_orders_atomic` with full header and item prevalidation, one
  result per created order, and a single commit or group rollback. Non-test
  creates without a returned document number fail the group. Tests cover
  success, test runs, BAPI errors, missing document numbers, and rejection
  before any create call; target SAP LUW assumptions are in `ANOMALIES.md`.
- Shared atomic commit handling between multi-create and multi-change calls.
  Single writes now reject invalid test-run flags, detect error-severity commit
  messages, and return a clear error when a write fails without a message.
  Latest validation: `npm.cmd test` passed with zero abaplint issues, 1,090
  transpiler outputs, ABAP Unit success, and `git diff --check` passed.
- Added `preview_cost_center_demands` for multi-line cost-center planning. It
  validates all request IDs and fields before conversion or stock reads,
  converts per-material units, shares each material/plant balance in caller
  order, and returns per-request allocations and shortfalls without creating
  reservations. Tests cover conversion, shared stock, order preservation,
  duplicate IDs, and empty input. See `ANOMALIES.md` for plant-level scope.
- Wired the cost center service's configured UOM converter into its stock
  allocator, keeping conversions on the injected repository in tests and
  integrations. Verification after the bulk preview: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1,090
  outputs, ABAP Unit completed successfully, and `git diff --check` passed.
- Added `preview_cost_center_by_date` with shared stock across dated demands,
  material-specific units, same-date priority, optional projected receipt
  sources, and safety-stock protection. It returns results in input order and
  performs no reservation writes. Tests cover date before priority, priority
  ties, unit conversion, duplicate IDs, invalid dates and flags, and empty
  input. SAP query and unit assumptions are in `ANOMALIES.md`.
- Added `preview_cost_center_locations` with per-demand hard locations or
  preferred-location fallback. It shares location balances across requests,
  returns converted location splits, validates the full request list before
  reads, and does not create reservations. Tests cover preferred-first splits,
  alternative-unit quantities, duplicate IDs, invalid flags, and empty input.
  `npm.cmd test` passed with zero abaplint issues, 1,090 transpiler outputs,
  ABAP Unit success, and `git diff --check` passed; SAP query limits are in
  `ANOMALIES.md`.
- Added `preview_cost_center_batches` for explicit batch demand lines. It
  shares the selected batch/location balances in caller order, supports
  preferred-location fallback without batch substitution, returns expiration
  and unit-converted splits, and validates all rows before stock reads. Tests
  cover split conversion, duplicate IDs, missing batches, invalid flags, and
  empty input. A stocked alternate batch does not satisfy a selected-batch
  shortfall. Verification: `npm.cmd test` passed with zero abaplint issues,
  1,090 transpiler outputs, ABAP Unit success, and `git diff --check` passed;
  target-system batch query assumptions are in `ANOMALIES.md`.
- Added `preview_cost_center_fefo` for multiple cost center demands. It shares
  batch balances in caller order, applies one as-of date and minimum shelf life,
  preserves preferred-location fallback, and returns converted per-batch
  splits. Tests cover date eligibility, shared stock shortfalls, preferred
  locations, unit conversion, invalid input, and empty input. Target-system
  query and batch-determination limits are recorded in `ANOMALIES.md`.
- Extended `preview_cost_center_by_date` with optional cumulative ATP
  diagnostics. Requests are checked by material, plant, base unit, and required
  date; local dated allocations remain separate and results stay in caller
  order. Tests cover grouped cumulative quantities, unit conversion, invalid
  ATP options, and zero reservation writes. Target ATP behavior is recorded in
  `ANOMALIES.md`. Latest combined validation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 1,090 outputs,
  ABAP Unit completed successfully, and `git diff --check` passed.
- Added `reserve_cost_centers_atomic` for all-or-nothing multi-demand writes. It
  validates the full list, preallocates shared location stock, requires full
  quantity coverage, creates one reservation per demand, and commits once or
  rolls back on an API or commit failure. Tests cover shared location splits,
  stock shortfall before writes, create and commit rollback, simulation, invalid
  input, and empty input. Confirm SAP LUW behavior as recorded in
  `ANOMALIES.md`. Validation passed: abaplint reported zero issues across 90
  files, the transpiler wrote 1,090 outputs, and ABAP Unit completed
  successfully. Extended the same method to support groups using either an
  explicit batch on every demand or automatic FEFO selection. Tests cover
  shared batch balances, alternate-batch exclusion, expiry filtering, and batch
  fields in reservation items; mixed batch strategies are rejected before
  stock reads. The full suite passed again after this extension.
- Added optional cumulative ATP diagnostics and an all-or-nothing confirmation
  gate to `reserve_cost_centers_atomic`. Demand is grouped by material, plant,
  base unit, and required date; each check receives the cumulative quantity
  through that date. The gate returns before any reservation API call if any
  group is short. Tests cover same-date aggregation, later-date cumulative
  demand, gate rejection, and invalid ATP options. `npm.cmd test` passed with
  zero abaplint issues across 90 files, 1,090 transpiler outputs, and ABAP Unit
  success. Target availability rule and confirmation behavior are recorded in
  `ANOMALIES.md`.
- Atomic reservation creates now reject duplicate reservation numbers returned
  for distinct demands and roll the group back. Reservation numbers are cleared
  from every item after create or commit rollback. Tests cover duplicate API
  results and cleared numbers after commit failure. Final `npm.cmd test` passed:
  abaplint reported zero issues across 90 files, the transpiler wrote 1,090
  outputs, and ABAP Unit completed successfully; `git diff --check` passed.
- Added `read_reservations` to the reservation inquiry service. It validates all
  reservation numbers before any reads, rejects blanks and duplicates, preserves
  caller order, and returns each document's existing validation result. Tests
  cover ordered reads, mixed success/failure, invalid lists, and empty input; SAP
  detail-field limits remain documented in `ANOMALIES.md`. `npm.cmd test` passed
  with zero abaplint issues across 90 files, 1,090 transpiler outputs, and ABAP
  Unit success; `git diff --check` passed.
- Refactored reservation goods issue to validate every selected item and the
  test-run flag before inquiry, then read distinct reservation documents through
  `read_reservations` in first-seen order. A read failure prevents the single
  goods movement call. Tests cover invalid late input with zero reads and issue
  items from multiple reservation documents in caller order. `npm.cmd test`
  passed with zero abaplint issues across 90 files, 1,090 transpiler outputs,
  and ABAP Unit success.
- Reservation detail reads now reject repeated item numbers within one document
  and clear all items on a malformed response. Added a regression test for a
  duplicate item number; `npm.cmd test` passed with zero abaplint issues across
  90 files, 1,090 transpiler outputs, and ABAP Unit success.
- Component stock and ATP previews now exclude the selected components' own
  reservation keys from dated `RESB` deductions before allocating their open
  quantities. Other active reservations remain netted, preventing the selected
  components from being counted twice. Added a fake-repository regression case
  for restoring the component's reservation quantity and allocating it once.
  `npm.cmd test` passed: abaplint reported zero issues across 90 files, the
  transpiler wrote 1,090 outputs, and ABAP Unit completed successfully.
- Added `cancel_material_documents_bulk` for validated multi-document reversals.
  It returns per-document attempt and cancellation state, supports item-specific
  cancellation and posting dates, and offers independent commits or one atomic
  LUW. Tests cover atomic success, rollback after an API and commit failure,
  continued processing in independent mode, and prevalidation before any BAPI
  call. Verify the target SAP release's multi-call LUW behavior as recorded in
  `ANOMALIES.md`. `npm.cmd test` passed: abaplint reported zero issues across 90
  files, the transpiler wrote 1,090 outputs, and ABAP Unit completed
  successfully.
- Exposed the bulk material-document reversal through
  `cancel_component_issues_bulk`, preserving the production-component service
  entry point while carrying item selections, posting dates, per-document
  results, and atomic mode through to the shared cancellation implementation.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,090
  transpiler outputs, and ABAP Unit success.
- Added `mark_pr_items_deleted` to flag selected replenishment requisition items
  through `BAPI_PR_CHANGE`, including test-run support and shared commit/rollback
  handling. The service validates the complete item list before the BAPI call;
  local DDIC stubs now include the deletion value and update flag. SAP item
  eligibility and exact target-release mapping remain recorded in
  `ANOMALIES.md`.
- Added two multi-requisition deletion modes. `delete_pr_items_atomic` validates
  the full group, commits once on success, and rolls back the group after the
  first BAPI error; `delete_pr_items_bulk` commits or rolls back each request
  and continues through later requisitions. Both preserve per-document
  messages, item-level message mapping, and test-run behavior. Requisition
  validation is shared across both modes. PR writes now also treat error-level
  commit messages as failure, even when the adapter success flag is true.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,090
  transpiler outputs, and ABAP Unit success; target SAP LUW behavior is
  documented in `ANOMALIES.md`.
- Added prepared-item multi-create methods. `create_requisitions_atomic`
  validates every document before calling `BAPI_PR_CREATE`, commits once, and
  rolls back and clears returned document numbers after any create or commit
  failure. `create_requisitions_bulk` commits or rolls back each requisition
  independently and keeps processing after errors. Test runs skip commits, and
  result rows preserve SAP messages and item mappings. Shared PR write handling
  now reports an error-level fallback when an adapter indicates a failed write
  or commit without an error message. Tests cover prevalidation, required live
  document numbers, item-level message mapping, group rollback, independent
  continuation, simulation, and commit-message inconsistencies. `npm.cmd test`
  passed with zero abaplint issues across 90 files, 1,090 transpiler outputs,
  and ABAP Unit success; `git diff --check` passed. Target SAP transaction
  behavior is documented in `ANOMALIES.md`.
- Expanded `update_pr_items` and `update_pr_items_bulk` to change purchasing
  group, purchasing organization, fixed vendor, info record, and outline
  agreement references alongside quantity and delivery date. Each selected
  field receives its `PRITEMX` update flag; a selected blank source reference
  can clear that value, while unselected values must remain initial. Mapper and
  service tests cover all fields, invalid flags, payload propagation, bulk
  modes, and transaction failures. `npm.cmd test` passed: abaplint reported
  zero issues across 90 files, the transpiler wrote 1,090 outputs, and ABAP Unit
  completed successfully. Live SAP field eligibility and clearing behavior
  remain release-dependent as documented in `ANOMALIES.md`.
- Added `read_pr_items` through `BAPI_PR_GETDETAIL` and the validated
  `read_pr_items_bulk` wrapper. Item results include material, stock location,
  quantity/unit, delivery date, buyer and source assignments, release and
  processing state, ordered quantity, follow-on PO keys, and fixed/closed
  indicators. Bulk reads preserve order, prevalidate all keys, return one row
  per requisition, and continue after failures; empty input makes no call. The
  `BAPIMEREQITEM` local stub models only the fields used here. `npm.cmd test`
  passed: abaplint reported zero issues across 90 files, the transpiler wrote
  1,091 outputs, and ABAP Unit completed successfully. Target-system BAPI fields,
  permissions, and result behavior remain documented in `ANOMALIES.md`.
- Added `delete_all_pr_items`, which reads a requisition and submits every item
  without a deletion indicator through the existing test-run and commit path.
  Read failures prevent writes; already-deleted requisitions return success
  without a change call. Tests cover active/deleted item selection, no-op
  behavior, read failure, and the successful commit path. `npm.cmd test` passed:
  abaplint reported zero issues across 90 files, the transpiler wrote 1,091
  outputs, and ABAP Unit completed successfully. The read/change race and target
  deletion rules are recorded in `ANOMALIES.md`.
- Added `delete_all_pr_items_bulk` for validated multi-requisition deletion by
  document number. Each requisition is read and processed independently; later
  requests continue after a read, change, or commit failure, with per-row
  messages and commit state. Tests cover continuation after read failure and
  validation before any read. `npm.cmd test` passed: abaplint reported zero
  issues across 90 files, the transpiler wrote 1,091 outputs, and ABAP Unit
  completed successfully. SAP read/change race and per-document transaction
  limits are recorded in `ANOMALIES.md`.
- Added `create_orders_bulk` and `change_orders_bulk` for independent sales-order
  writes. Both validate every request before writing, commit/rollback per order,
  and continue after a failed row. `ty_write_result` now reports test-run and
  commit state for single, bulk, and atomic operations; atomic rollback marks
  every row unsuccessful and clears document numbers from rolled-back creates.
  Tests cover mixed successes, validation before any write, simulations, and
  atomic rollback status. `npm.cmd test` passed: abaplint reported zero issues
  across 90 files, the transpiler wrote 1,091 outputs, and ABAP Unit completed
  successfully. SAP transaction limits are documented in `ANOMALIES.md`.
- Added sales-order item rejection updates using `BAPISDITM-REASON_REJ` and its
  `BAPISDITMX` update flag. `reject_order_items` validates unique item numbers
  and nonblank reason codes; `reject_orders_bulk` commits each order
  independently, and `reject_orders_atomic` uses one shared commit or rollback.
  All modes preserve SAP messages and support test runs. Tests cover single
  commits, simulations, bulk continuation, atomic success, and atomic rollback.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,091
  transpiler outputs, and ABAP Unit success. Target-system rejection reasons,
  BAPI field behavior, and transaction handling are recorded in `ANOMALIES.md`.
- Order reads now return rejected items separately from active allocation items,
  including item number, material, plant, sales quantity/unit, and rejection
  reason. A fully rejected order remains a successful read with a warning; its
  items cannot flow into the active-demand collection. Tests cover mixed and
  rejected-only read results. `npm.cmd test` passed with zero abaplint issues,
  1,091 transpiler outputs, and ABAP Unit success. Verify the target release's
  `BAPISDIT` output fields and rejected-item quantity semantics as documented in
  `ANOMALIES.md`.
- Added rejection clearing for single orders and for multi-order bulk or atomic
  groups. Each selected item is sent with a blank rejection reason and the BAPI
  update flag set; clear requests validate distinct item numbers and distinct
  document keys before writing. Tests verify the blank payload, independent
  bulk continuation, shared atomic commit, and rollback on an atomic failure.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,091
  transpiler outputs, and ABAP Unit success. SAP documents blank-reason clearing
  for sales-order processing, but the `BAPI_SALESORDER_CHANGE` behavior must be
  confirmed on the target release as recorded in `ANOMALIES.md`.
- Added `ZCL_PURCHASE_ORDER_SERVICE` for standard external POs from explicitly
  selected PIR or outline-agreement sources, plus bulk independent and atomic
  creation. Bulk input is fully validated before any BAPI call; individual
  failures do not prevent later requests from running. Atomic creation shares
  one commit and rolls back the group on a create or commit failure. Added
  `DELETE_ORDER_ITEMS` and `DELETE_ORDERS_ITEMS_BULK` to set SAP's PO item
  deletion indicator, and added `MARK_DELIVERY_COMPLETE` with a validated bulk
  counterpart to close remaining open-order quantity when no further supply is
  expected. Added `READ_ORDER` and `READ_ORDERS` for saved header, item-status,
  quantity, and schedule-line details via `BAPI_PO_GETDETAIL1`. Added
  `CREATE_FROM_SUGGESTIONS` to turn source-selected external replenishment rows
  into PO items with optional base-to-purchasing-unit conversion.
  Tests cover mixed outcomes, continuation, atomic rollback, prevalidation,
  selected item payloads, multi-PO reads, suggestion source/quantity mapping,
  and simulations for creation.
  `npm.cmd test` passed:
  abaplint reported zero issues across 94 files, the transpiler wrote 1,098
  outputs, and all 805 ABAP Unit methods completed. The local API double cannot
  verify target BAPI fields, source pricing, item eligibility, or multi-PO LUW
  behavior, or BAPI output population; delivery-completion and read limits are
  recorded in `ANOMALIES.md`.
- Added `CREATE_FROM_SUGGESTIONS_BULK`, which groups positive replenishment rows
  by vendor and purchasing organization, validates all mapped groups before
  writing, and then creates one independently committed PO per group while
  continuing after failures. Each item retains its original suggestion index in
  `source_request_id`; an all-zero batch returns a successful no-op result.
  Tests cover vendor grouping, quantity conversion, batch continuation,
  prevalidation, and the no-op path. `npm.cmd test` passed with zero abaplint
  issues across 94 files, 1,098 transpiler outputs, and all 809 ABAP Unit methods.
  Target BAPI source, pricing, UOM, locking, and per-PO transaction behavior are
  documented in `ANOMALIES.md`.
- Added `CREATE_FROM_REQUISITION_ITEMS` to create one PO from selected rows of a
  purchase requisition read. It carries `PREQ_NO`/`PREQ_ITEM` to each PO item,
  uses the unconverted quantity remaining after prior orders, and rejects
  deleted, closed, exhausted, duplicate, vendor-mismatched, or organization-
  mismatched rows before writing. Tests cover reference and quantity mapping,
  commit behavior, and prevalidation. `npm.cmd test` passed with zero abaplint
  issues across 94 files, 1,098 transpiler outputs, and all 811 ABAP Unit
  methods. Validate target BAPI fields, release/source checks, PR quantity
  semantics, and reference updates as recorded in `ANOMALIES.md`.
- Added `CREATE_FROM_REQUISITIONS_BULK` to combine selected PR items into one PO
  per first-seen vendor and purchasing-organization group. It preserves each
  PR item reference, uses remaining quantity, and validates all groups before
  writing; individual PO failures do not stop later groups. Tests cover
  grouping, mapping, continuation, and no writes after a later validation
  error. `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 817 ABAP Unit methods. Target BAPI and PR status
  behavior are recorded in `ANOMALIES.md`.
- Added `CHANGE_ORDER_SCHEDULES` and its bulk counterpart for explicit
  schedule-line quantity and delivery-date changes through `BAPI_PO_CHANGE`.
  The bulk method validates every PO group first, then commits each PO
  independently and continues after a failed change. Tests cover field mapping,
  per-order continuation, rollback after failure, and batch prevalidation.
  `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 814 ABAP Unit methods. Target schedule eligibility,
  PO item quantity consistency, and BAPI update behavior are recorded in
  `ANOMALIES.md`.
- Added `CREATE_REQUISITIONS_ATOMIC` for selected PR rows grouped by the chosen
  vendor and purchasing organization. It validates all groups before writing,
  commits all created POs together, and rolls the batch back on create or commit
  failure. Tests cover successful grouped creation and rollback cleanup.
  `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 819 ABAP Unit methods. Target SAP LUW behavior is
  recorded in `ANOMALIES.md`.
- Added `CREATE_FROM_SUGGESTIONS_ATOMIC`, using the same grouped request builder
  and optional purchasing-unit conversion as the independent batch path. All
  supplier POs commit together; a create failure rolls back the batch, and an
  all-zero selection returns a no-op result. Tests cover mapping, one shared
  commit, failure cleanup, and the no-op case. `npm.cmd test` passed with zero
  abaplint issues across 94 files, 1,098 transpiler outputs, and all 822 ABAP
  Unit methods. Target SAP LUW behavior is recorded in `ANOMALIES.md`.
- Added `CHANGE_ORDER_SCHEDULES_ATOMIC` for multi-PO schedule-line changes. It
  validates every PO first, applies all schedule updates, and commits once;
  failed updates or commits roll back the batch. Tests cover prevalidation,
  update mapping, one shared commit, and both rollback paths. `npm.cmd test`
  passed with zero abaplint issues across 94 files, 1,098 transpiler outputs,
  and all 826 ABAP Unit methods. Target SAP LUW behavior is documented in
  `ANOMALIES.md`.
- Added atomic multi-PO item deletion and delivery-completion methods. They
  validate the full selection before writing, commit all changes together, and
  roll back the batch after any failed update or commit. Tests cover both
  actions, result mapping, prevalidation, and update failure rollback.
  `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 830 ABAP Unit methods. Target SAP LUW and item
  eligibility checks are documented in `ANOMALIES.md`.
- Added support for the standard `TB` daily lot-size procedure in replenishment
  suggestions. Each daily period uses the shortage date as both boundaries and
  keeps the procedure's configured lot constraints. Tests verify daily period
  output. `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 831 ABAP Unit methods. Remaining configured
  custom period intervals are still noted in `ANOMALIES.md`.
- Added caller-resolved replenishment periods for period-based or custom lot-size
  procedure keys, including separate ranges by plant and procedure. The service
  validates dates, duplicate/overlapping ranges, and coverage for shortage dates;
  custom procedures apply their configured minimum, maximum, and order multiple
  to netted period requirements. Tests cover `W2` and `PB` groupings, overlap,
  uncovered-date rejection, and PO receipt netting through the stock-backed
  convenience method. `npm.cmd test` passed with zero abaplint issues across 94
  files and 1,098 transpiler outputs.
- Added PO item quantity changes through `BAPI_PO_CHANGE`, including single-PO,
  per-PO bulk, and shared-commit atomic methods. Requests require unique item
  numbers and positive quantities in the existing purchase-order unit. Tests
  cover request mapping, prevalidation, batch continuation, atomic commit, and
  rollback after an update or commit failure. `npm.cmd test` passed with zero
  abaplint issues across 94 files and 1,098 transpiler outputs; SAP field
  controls and multi-PO LUW behavior remain documented in `ANOMALIES.md`.
- Added `CHANGE_QTY_FROM_BASE` plus bulk and atomic forms. They read each PO,
  validate selected items, and convert material base-unit quantities to the PO
  item's unit before any writes. Missing conversion data rejects the full
  request. Tests cover conversion, validation before writes, atomic commit, and
  conversion failure. `npm.cmd test` passed with zero abaplint issues across 94
  files and 1,098 transpiler outputs. Target UOM ratios, PO item eligibility,
  and multi-document LUW behavior remain documented in `ANOMALIES.md`.
- Added `CHANGE_BASE_SCHEDULES` plus bulk and atomic forms. Quantity-bearing
  schedule rows convert material base units to the PO item unit after reading
  and validating the item; date-only rows keep the existing no-read path. Bulk
  and atomic forms finish all reads/conversions before writes. Tests cover
  conversion, date-only preservation, batch prevalidation, atomic commit, and
  conversion rejection. `npm.cmd test` passed with zero abaplint issues across
  94 files and 1,098 transpiler outputs. Target UOM and schedule eligibility
  behavior remains in `ANOMALIES.md`.
- Added `CREATE_FROM_QUOTA_SPLITS` to bridge quota split previews to PR creation.
  It validates that allocated shares reconcile to each selected suggestion,
  then creates one vendor-specific PR item per split at the proposal quantity,
  including purchasing-unit conversion and original suggestion-index mapping.
  Tests cover two-source item mapping, conversion, commit, and incomplete-split
  rejection. `npm.cmd test` passed with zero abaplint issues across 94 files
  and 1,098 transpiler outputs. Quota snapshot staleness and SAP source
  acceptance remain documented in `ANOMALIES.md`.
- Added `GET_PO_CONFIRMED_RECEIPTS` to return standard PO schedule remainder
  rows alongside open MRP-relevant EKES supplier confirmations. It uses the
  stored EKET/EKES MRP-reduced quantities and converts each row to the material
  base unit; `GET_PO_CONF_RECEIPTS_IN_UNIT` also converts the result to a
  requested material unit. `GET_PO_CONF_RECEIPTS_BULK` and its `_UOM` variant
  group repeated material/plant requests, filter by each deadline, and cache
  unit ratios. `SUGGEST_COMP_REPL_FROM_STOCK` can net these confirmations into
  component shortage suggestions through `iv_include_po_confirmations`, which
  is mutually exclusive with regular PO receipt projection. Tests cover service
  contracts, invalid horizons, query grouping, deadline filtering, ratio reuse,
  conversion, reduction arithmetic, shortage netting, and source exclusivity.
  `npm.cmd test` passed with zero abaplint issues across 94 files and 1,099
  transpiler outputs. Confirmation-category configuration and DABMG/WEMNG
  behavior still require target-SAP validation, documented in `ANOMALIES.md`.
- Added `ISSUE_COMPONENTS_IN_UNIT` and `ISSUE_COMPONENTS_BULK_IN_UNIT` for
  production component issues requested in a material's alternative unit. The
  service reads each reservation component once, converts all requested lines
  to the component's base unit, validates the complete batch, and posts one
  reservation goods movement. Tests cover box-to-base conversion, base-unit
  BAPI mapping, a single component read, and rejection of an unknown unit in a
  mixed batch before any goods movement. `npm.cmd test` passed with zero
  abaplint issues across 116 files and 1,156 transpiler outputs. Live
  `MARA`/`MARM` ratio, rounding, and reservation behavior remain documented in
  `ANOMALIES.md`.
- Added `RETURN_COMPONENTS_IN_UNIT` and `RETURN_COMPONENTS_BULK_IN_UNIT` for
  partial component returns requested in an alternative material unit. The
  service reads the selected component rows once, converts every quantity to
  its reservation unit, validates all lines against withdrawn quantities, and
  posts one reservation reversal. Tests cover box-to-base reversal mapping,
  single-read behavior, and unknown-unit rejection before posting. The latest
  `npm.cmd test` run passed with zero abaplint issues across 116 files and
  1,156 transpiler outputs; live UOM and reversal behavior is recorded in
  `ANOMALIES.md`.
- Added direct `CREATE_ORDER` support to `ZCL_PROD_ORDER_SERVICE` through
  `BAPI_PRODORD_CREATE`, for callers that need a production order without a
  planned-order conversion. The service validates material, plants, order type,
  quantity/unit, and basic dates, defaults planning plant to production plant,
  and owns the commit/rollback boundary. Added the SAP `BAPI_PP_ORDER_CREATE`
  stub with only mapped fields. Tests cover BAPI input/result mapping, valid
  creation, input rejection before the API, and rollback after create or commit
  failure. `npm.cmd test` passed: zero abaplint issues across 116 files,
  1,157 transpiler outputs, and a successful ABAP Unit run. Target BAPI and
  order-master behavior remain documented in `ANOMALIES.md`.
- Added `CREATE_ORDERS_BULK` and `CREATE_ORDERS_ATOMIC` for multi-order direct
  production-order creation. Both validate the complete request before calling
  SAP. Bulk mode commits each order independently and continues after an item
  failure; atomic mode shares one commit and rolls back the group on a create
  or commit failure. Tests cover partial bulk failure, continued processing,
  shared commit, prevalidation, duplicate returned order numbers, and atomic
  rollback. `npm.cmd test` passed with zero abaplint issues across 116 files,
  1,157 transpiler outputs, and a successful ABAP Unit run. Repeated-call LUW
  behavior still requires target-SAP validation, as recorded in
  `ANOMALIES.md`.
- Added typed `RECEIVE_PURCHASE_ORDER`, `RECEIVE_PURCHASE_ORDERS_BULK`, and
  `RECEIVE_PURCHASE_ORDERS_ATOMIC` methods for PO goods receipts. They map PO
  references and item quantities to movement 101/code 01 with indicator `B`,
  prevalidate the full request, and provide either per-PO commits or one shared
  commit with rollback. Tests cover field mapping, partial bulk failure,
  continued processing, invalid duplicate-PO input, rollback on receipt
  failure, and rollback on commit failure. Target-SAP repeated-call LUW
  behavior is recorded in `ANOMALIES.md`. The complete `npm.cmd test` run
  passed with zero abaplint issues across 116 files, 1,157 transpiler outputs,
  and a successful ABAP Unit run.
- Added typed `RECEIVE_PROD_ORDER`, `RECEIVE_PROD_ORDERS_BULK`, and
  `RECEIVE_PROD_ORDERS_ATOMIC` methods for production-order goods receipts.
  They map finished output to movement 101/code 02 with indicator `F`,
  prevalidate each order and quantity/unit, and support independent commits or
  a shared rollback boundary. Tests cover mapping, bulk continuation, atomic
  create and commit failures, duplicate-order rejection, and test-run behavior.
  The complete `npm.cmd test` run passed with zero abaplint issues across 116
  files, 1,157 transpiler outputs, and a successful ABAP Unit run. SAP receipt
  eligibility and repeated-call LUW behavior are recorded in `ANOMALIES.md`.
- Added optional `iv_reservation_through_date` to project-stock FEFO, location,
  and WBS transfer previews. The repository now returns `RESB-BDTER`; open
  reservations dated after the cutoff are excluded, while undated reservations
  and the prior all-open default remain conservative. Tests cover the cutoff
  and default behavior for batch and batchless stock and verify cutoff
  forwarding through WBS transfers. Target `RESB-BDTER` behavior and the fact
  that this remains a current-stock snapshot are documented in `ANOMALIES.md`.
- Added `CREATE_FROM_PROJ_SHORTFALLS` to the replenishment requisition
  service. It builds one `Q` account-assigned PR item per validated shortfall,
  retaining the material, base unit, delivery date, and stock-bearing WBS.
  `BAPI_PR_CREATE` now receives matching `PRACCOUNT` and `PRACCOUNTX` rows; the
  standard item/account DDIC stubs and mapper tests cover those fields. Added
  service tests for successful multiple-WBS creation and rejection before SAP
  calls. Target BAPI signature, account assignment rules, and WBS validity are
  documented in `ANOMALIES.md`.
- Added FEFO batch-expiry validation to `RESERVE_BATCH_ALLOCATION`. A selected
  batch must remain valid through its WBS required date, and the new optional
  `iv_minimum_shelf_life_days` can require additional remaining life. Unknown
  expiry is allowed with no minimum and rejected with a positive minimum.
  Tests cover per-WBS expiry, the shelf-life boundary, short shelf life, and
  unknown expiry before writes. Target SAP batch checks and snapshot limits are
  documented in `ANOMALIES.md`.
- Added `RESERVE_WBS_FEFO` to run the project-stock FEFO preview and batch
  reservation in one service call, returning both results. Complete coverage
  is the default; a preview shortfall is returned to the caller without any
  create call, while opt-in partial mode reserves the available splits. The
  wrapper forwards WBS-specific required dates, shelf-life rules, test-run,
  and atomic options. Tests cover FEFO batch order, split quantities, required
  date forwarding, commit, and shortfall no-write behavior.
- Added `RESERVE_WBS_BY_LOCATION` for one-call batchless project-stock preview
  and reservation. It returns both results, defaults to full coverage, and
  retains a shortfall preview without making reservation calls. Required-date
  input validation is shared with the FEFO wrapper and runs before stock reads.
  Tests cover storage-location reservation mapping, commit, and no-write
  shortfall handling. `npm test` passed after both reservation enhancements:
  abaplint found zero issues across 128 files, transpilation wrote 1,141
  outputs, and ABAP Unit exited successfully.
- Updated project-stock FEFO to accept `fefo_as_of_date` on each demand. The
  later of the demand date and shared as-of date drives the shelf-life check,
  and each returned batch split echoes that effective date. `RESERVE_WBS_FEFO`
  now previews against the WBS required date, so it skips batches that cannot
  survive to the reservation date and can use later eligible batches. Added
  coverage for per-demand expiry, invalid date rejection before reads, and the
  later-batch reservation case, including WBS transfers. A positive shelf-life
  minimum also excludes undated batches in the reservation preview, returning
  a shortfall without a create attempt. The subsequent full `npm test` passed
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Extended cost-center FEFO with per-demand `fefo_as_of_date`. Preview rows
  use the later of the shared as-of date and the row override; single and
  atomic reservations also include the reservation's required date. Results
  and batch splits report the effective date, and bulk reservations preserve
  the same row behavior. Tests cover preview, single, atomic, and bulk flows,
  batches that expire before the effective date, and invalid row dates rejected
  before stock reads. `npm test` passes with zero abaplint issues across 128
  files and a successful transpile and ABAP Unit run.
- Added required-date expiry filtering to exact-batch cost-center allocation.
  Single preview and reservation calls check the chosen batch through the
  required date; `iv_batch_min_days` can require more remaining life. Atomic and
  bulk demand rows carry their required date and optional minimum through the
  unit-aware batch allocator. Expired or short-life stock yields a shortfall
  without a reservation write; unknown expiry remains eligible with no minimum.
  Tests cover expiration before the date, the inclusive date boundary, extra
  shelf life, and atomic no-write handling. `npm test` passes with zero
  abaplint issues across 128 files, 1,141 transpiler outputs, and successful
  ABAP Unit. Target SAP batch behavior is recorded in `ANOMALIES.md`.
- Fixed cost-center reservation date validation: atomic and bulk requests now
  require every `required_date` to be a valid Gregorian date, even when FEFO is
  disabled. This prevents malformed dates from reaching stock allocation or
  the reservation API. Regression tests verify both entry points reject an
  invalid date before stock reads or writes. The resolved gap is recorded in
  `ANOMALIES.md`. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added expiry filtering to explicit sales-order batch selection. Each selected
  batch is checked through its schedule requested date, or `sy-datum` for an
  undated item, matching the reservation adapter's effective required date.
  Expired stock produces a preview shortfall; full-allocation reservation mode
  makes no write. Expiry on the required date remains eligible. Target SAP batch
  validation and snapshot limits are recorded in `ANOMALIES.md`. `npm test`
  passes with zero abaplint issues across 128 files, 1,141 transpiler outputs,
  and successful ABAP Unit.
- Added `minimum_shelf_life_days` to explicit sales-order batch selections.
  Each item or schedule line can require extra days beyond its effective
  reservation date; the boundary is inclusive and unknown expiry is excluded
  when the minimum is positive. Negative minimums fail before repository reads.
  Tests cover the boundary, short shelf life, unknown expiry, and early
  validation. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Sales-order batch and location selections now validate `allow_fallback` as
  `abap_true` or `abap_false` before reading reservations or stock. Regression
  tests verify malformed flags fail before repository reads. `npm test` passes
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- The shared stock allocator now validates `fallback_to_other_locations` in
  location, exact-batch, and FEFO demands, including unit-aware variants.
  Malformed flags fail before stock or unit-conversion reads. Tests cover all
  six allocation entry points. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Location, exact-batch, and FEFO allocation methods now also validate
  `iv_protect_safety_stock` in base and unit-aware forms. Invalid values fail
  before stock or unit-conversion reads; tests cover all six entry points.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit.
- Single-plant stock, dated, unit-aware, and ATP allocation entry points now
  also accept only `abap_true` or `abap_false` for
  `iv_protect_safety_stock`. Cross-plant, dated, FEFO, batch, unit, and ATP
  entry points apply the same check before stock or UOM access. Regression
  tests cover the single-plant and cross-plant method families, including no
  repository reads for malformed values. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Dated single-plant and cross-plant allocation now validate all receipt-option
  flags as `abap_true` or `abap_false` before stock, UOM, or ATP work. The
  existing PO receipts and PO confirmations mutual exclusion is checked by
  the same validator. Tests cover each malformed option and all dated
  allocation entry points. `npm test` passes with zero abaplint issues across
  128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Completed the allocation-flag audit for `iv_require_full_quantity`. The
  single-request and dated cross-plant batch ATP entry points now reject
  malformed values locally before delegating or reading stock. Regression
  tests cover both paths with zero repository reads. `npm test` passes with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Added `ALLOCATE_BY_EXPIRY_ATP` for unit-aware single-plant FEFO demands. It
  returns the local FEFO estimate and groups ATP checks by material, plant,
  base unit, and effective FEFO date, accumulating allocated quantity through
  each date. It skips ATP when no eligible stock was allocated. Tests cover
  split selection, cumulative dates and confirmations, missing-rule rejection
  before reads, and no ATP call for an expired-only shortfall. `npm test` passes
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit. Target ATP behavior is recorded in `ANOMALIES.md`.
- Added `ALLOCATE_BY_BATCH_ATP` for exact-batch unit-aware demands. It fills
  omitted row dates from `iv_as_of_date`, preserves explicit dates and the
  selected batch, applies local expiry checks, then reuses the shared
  date-grouped ATP confirmation logic. Tests cover exact batch selection,
  partial allocation, row-date override, cumulative confirmations, and bad
  check-rule rejection before reads. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
  Target ATP behavior is recorded in `ANOMALIES.md`.
- Added `ALLOCATE_BY_LOCATION_ATP` for unit-aware single-plant location demand.
  It aggregates positive local allocations by material, plant, and base unit,
  then checks ATP at an optional date that defaults to today. The local estimate
  remains based on current stock. Tests cover aggregation across demand rows,
  unit conversion, partial confirmations, early rule/date rejection, and
  skipping ATP after a full-quantity local shortfall. Target SAP checking scope
  is documented in `ANOMALIES.md`. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Added `ALLOCATE_LOCATION_BY_DATE_UOM` for dated unit-aware location demands.
  It allocates earlier dates first and higher priorities within a date, then
  preserves input order for equal-date, equal-priority requests and returns
  demand and storage-location splits in caller order. Dates and unique request
  IDs are validated before UOM or stock reads. The preview uses current
  location balances only; the receipt-location limitation is recorded in
  `ANOMALIES.md`. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added `ALLOCATE_LOCATION_DATE_UOM_ATP` for dated location previews. It checks
  positive allocations cumulatively by material, plant, base unit, and required
  date, and returns confirmation and unconfirmed quantities without changing
  local allocation. Tests cover cumulative requests, partial confirmation,
  invalid-rule rejection before reads, and no ATP call for a zero allocation.
  Target-system ATP scope is recorded in `ANOMALIES.md`. `npm test` passes with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Added `READ_AVAILABLE_STOCK_IN_UNIT` and `READ_AVAILABLE_STOCK_BULK_UOM` for
  project stock. They preserve location, batch, and expiry details while
  returning both requested-unit and base-unit quantities. The bulk method
  caches material/unit ratios, retains the cutoff-grouped stock read, and
  rejects every unknown unit before stock access. Tests cover conversion,
  ratio reuse, and no reads on invalid units. `npm test` passes with zero
  abaplint issues across 128 files, 1,141 transpiler outputs, and successful
  ABAP Unit.
- Added `PREVIEW_FEFO_BY_DATE` for project stock. Earlier required dates consume
  shared WBS/material/plant balances first; same-date priority runs descending,
  and equal priorities retain input order. Results and batch splits return in
  caller order with required date and priority. Batch expiry is checked through
  each requirement date, and invalid dates or duplicate request IDs fail before
  stock reads. Tests cover date/priority allocation and caller-order results.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Snapshot limitations are in
  `ANOMALIES.md`.
- Added `RESERVE_WBS_FEFO_BY_DATE` to reserve the date-prioritized project FEFO
  preview. It groups items by WBS and required date, reruns and compares the
  complete batch split before writing, and supports the existing test-run and
  atomic transaction options. Tests cover stock consumption priority, caller
  order, multiple reservation dates for one WBS, and invalid dates before reads.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Target BAPI behavior is recorded
  in `ANOMALIES.md`.
- Added `PREVIEW_BY_LOCATION_DATE` for batchless project stock. It allocates
  earlier requirements first, then higher priorities within the same date,
  while preserving caller order for summaries and location splits. Invalid
  dates and duplicate IDs are rejected before stock reads. Tests cover date and
  priority ordering plus caller-order results. `npm test` passes with zero
  abaplint issues across 128 files, 1,141 transpiler outputs, and successful
  ABAP Unit. Location snapshot limitations are recorded in `ANOMALIES.md`.
- Added `RESERVE_WBS_BY_LOCATION_DATE` to reserve dated batchless project-stock
  allocations. It groups reservations by WBS and required date, checks the
  location split again before writing, and supports full-quantity, test-run,
  and atomic transaction options. Tests verify priority allocation, date-based
  reservation grouping, and invalid-date rejection before reads. `npm test`
  passes with zero abaplint issues across 128 files, 1,141 transpiler outputs,
  and successful ABAP Unit. Target behavior is recorded in `ANOMALIES.md`.
- Added `READ_RESERVATION_COVERAGE_UOM` for a single material/plant/WBS key.
  It returns requested-unit and base-unit totals and checks the material UOM
  ratio before stock or reservation reads. Tests cover conversion and early
  rejection of an unknown unit. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
  Target unit semantics are recorded in `ANOMALIES.md`.
- Added `READ_RESV_COVERAGE_BULK_UOM` for multiple material/plant/WBS requests.
  It validates and caches each requested-unit ratio before delegating to the
  cutoff-grouped coverage reader, then returns both unit views in request
  order. Tests cover conversion, shared reads, and unknown-unit rejection before
  stock access. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit. Query limitations are in
  `ANOMALIES.md`.
- Added `READ_RESERVATION_ITEMS_BULK` for multiple WBS requests. It validates
  unique request IDs, deduplicates WBS reads, and preserves final and fully
  withdrawn items in each response. Tests cover repeated WBS requests, item
  ordering, shared reads, and rejection before a read on duplicate IDs.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Query limitations are in
  `ANOMALIES.md`.
- Added `PREVIEW_TRANSFER_FEFO_BY_DATE` and `TRANSFER_WBS_FEFO_BY_DATE` for
  date and priority ordered project-stock batch transfers. The goods movement
  adapter repeats the dated preview and rejects changed batch splits before
  posting 415/Q. Tests cover caller-order output, date and priority allocation,
  successful posting, invalid dates before reads, and stale snapshot rejection.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Target SAP snapshot and
  movement limitations are recorded in `ANOMALIES.md`.
- Added `PREVIEW_TRANSFER_LOCATION_DATE` and
  `TRANSFER_WBS_BY_LOCATION_DATE` for dated batchless WBS transfers. The preview
  applies date and same-date priority ordering while preserving caller-order
  results; the movement adapter compares the repeated location split before
  posting 415/Q. Tests cover priority allocation, posting, and stale snapshot
  rejection. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit. Target snapshot behavior
  is recorded in `ANOMALIES.md`.
- Added a GitHub Actions validation workflow for pushes and pull requests. It
  installs Node.js 22, checks out the exact open-abap-core revision used in
  this workspace, and runs `npm test`. The workflow YAML parses locally, and
  the same validation command passes with zero lint issues and 1,141
  transpiler outputs.
- Added `ALLOCATE_LOCATION_BY_DATE` for base-unit location demand. Earlier
  required dates consume shared stock first, same-date priority runs descending,
  and input order breaks ties. Results return in caller order and retain the
  existing location priority, allowlist, safety-stock, and full-quantity
  options. Tests cover date and priority ordering, output ordering, invalid
  dates and duplicate IDs before reads. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
  Current location snapshot limits are in `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_BY_DATE_LOC` for date-prioritized cross-plant
  allocation from current location balances. It preserves each request's
  source-plant order, returns plant and location splits in caller order, and
  supports location scopes, priority, safety stock, and full-quantity policy.
  Tests cover date-over-priority ordering, same-date input ties, split ordering,
  shared stock across requests, and invalid dates before reads. `npm test`
  passes with zero abaplint issues across 128 files, 1,141 transpiler outputs,
  and successful ABAP Unit. Receipt and snapshot limits are recorded in
  `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_DATE_LOC_UOM` for dated, unit-aware cross-plant
  allocation with location splits. It caches material/unit ratios, preserves
  date and priority allocation plus caller-order results, and returns demand,
  source-plant, and location quantities in both units. Tests cover competing
  dates and priorities, rounded alternate-unit splits, conversion reuse, and
  unknown-unit rejection before stock reads. Receipt and stock snapshot limits
  are recorded in `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_DATE_LOC_ATP` to compare positive dated source-plant
  splits with SAP ATP. It groups cumulative quantities by source plant and
  required date, retains location-level local results, and skips checks for
  unallocated shortfalls. Tests cover date accumulation, caller-order results,
  skipped shortfalls, and invalid-rule rejection before reads. ATP scope limits
  are recorded in `ANOMALIES.md`. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Added `CREATE_DATE_LOC_PAIRS` and `CREATE_DATE_LOC_ATP_PAIRS` to create STOs
  from dated, unit-aware source-location allocations. Each source location
  becomes a dated PO item in canonical base units; demand, plant, and location
  totals are checked before writes. The ATP entry point rejects incomplete
  cumulative confirmation before BAPI calls. Tests cover item mapping, atomic
  commit, test-run behavior, split mismatch, and short ATP. Target BAPI field
  behavior is recorded in `ANOMALIES.md`. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Added `TRANSFER_PLANT_DATE_LOC_UOM` and `TRANSFER_DATE_LOC_UOM_2STEP` to
  post dated cross-plant location results as 301 or 303/305 transfers. Both
  preserve source locations and canonical base quantities, validate date and
  priority consistency, and check unit mappings. Tests cover both posting flows
  and reject mismatched split dates before a BAPI call. `npm test` passed with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit execution.
- Added `TRANSFER_DATE_LOC_ATP` and `TRANSFER_DATE_LOC_ATP_2STEP` for dated
  location allocations with ATP diagnostics. Both require one matching,
  relevant, cumulatively confirmed ATP check per positive source/date split
  before posting, and reconcile the ATP-confirmed source quantities with the
  location rows. Tests cover both posting flows and reject short ATP and a
  mismatched source-location split before creating a goods movement. Target ATP
  and movement behavior is recorded in `ANOMALIES.md`. `npm test` passed with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit execution.
- Added `GET_TRANSFER_LOCATIONS`, `GET_TRANSFER_LOCATIONS_BULK`, and unit-aware
  variants to enumerate aggregate `MARD-UMLME` quantities by storage location.
  Bulk results preserve request order and sort locations, reject duplicate or
  mismatched rows, and cache repeated unit ratios. Tests cover single and bulk
  reads, conversion, requests with no transfer rows, empty input, and invalid
  repository rows. `npm test` passed
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit execution. Aggregate-versus-batch query semantics are
  recorded in `ANOMALIES.md`.
- Added `TRANSFER_FEFO_DATE_ATP` and `TRANSFER_FEFO_DATE_ATP_2STEP` for dated
  FEFO allocation results with ATP checks. Before posting 301 or 303/305, the
  adapters require one matching relevant ATP result per positive request,
  source, and date, require full cumulative confirmation, and reconcile plant
  totals with batch/location splits. Tests cover both movement flows, short
  ATP, and split mismatch; plant-level ATP and stock-snapshot limits are
  recorded in `ANOMALIES.md`. `npm test` passed: zero abaplint issues across
  128 files, 1,141 transpiler outputs, and successful ABAP Unit execution.
- Strengthened the dated FEFO ATP movement gate to recompute confirmations from
  the raw ATP result using the required-date cutoff and compare them with the
  convenience confirmed/unconfirmed totals. Added a rejection case for
  inconsistent summary values. The gate also verifies demand/source dates,
  priorities, units, and allocated totals, since the posting adapter otherwise
  strips date metadata. Tests cover date-cutoff confirmations and reject a
  demand/source date mismatch. `npm test` passed with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit
  execution. Details are in `ANOMALIES.md`.
- Added required-date and priority checks to the existing dated unit-aware FEFO
  301 and 303/305 movement adapters. The checks keep demand, source, and batch
  split metadata consistent before posting drops date/priority fields. Tests
  reject a mismatched demand date before the goods-movement API; `npm test`
  passed with zero abaplint issues, 1,141 transpiler outputs, and successful
  ABAP Unit execution.
- Added `ZCL_STOCK_ALLOCATION_FACTORY` as a production composition root for
  stock preview, goods movement, and STO creation. It binds the standard MARD,
  UOM, ATP, movement, and purchase-order adapters; direct constructor injection
  remains available for custom integrations and tests. Construction is covered
  by ABAP Unit. `npm test` passed with zero lint issues across 130 files and
  1,145 transpiler outputs. Target SAP API validation remains in
  `ANOMALIES.md`.
- Added `POST_SO_ISSUE_REMAINING` to issue all remaining quantities from a
  caller-selected set of reservations for one sales-order item. It verifies
  movement type and order/item scope, skips fully withdrawn items, derives
  base-unit requests, and delegates to the existing per-reservation bulk issue
  path for a second state check and posting. Tests cover open-quantity mapping,
  wrong scope, and fully withdrawn reservations. The double read, live BAPI
  validation, and independent per-reservation commits are recorded in
  `ANOMALIES.md`.
- Added `POST_SO_ISSUE_REMAINING_ATOMIC`, which uses the same validated open
  quantities and sales-order scope but stages all selected reservation issues
  before one shared commit. Tests cover successful posting and rollback when
  the order scope changes between the initial read and the posting recheck.
  Verify shared-LUW behavior in the target SAP release; see `ANOMALIES.md`.
- Added request-ID selection to `RELEASE_SO_FEFO_RESERVATIONS`. The method still
  validates the full committed result, then deletes all batch/location
  reservations for selected demand IDs; empty selection releases all. Tests
  cover selecting one of two demands and duplicate-ID rejection before the
  delete API.
- Added reservation-number selection to `RELEASE_SO_FEFO_RESERVATIONS` so a
  caller can release one batch/location split from a multi-split FEFO demand.
  The service validates selected numbers against the fully matched committed
  result, rejects duplicates, unknown numbers, and mixed selector modes, and
  keeps the existing all-rows default when no selector is supplied.
- Hardened release validation to reject blank, nonpositive, or duplicate
  request/location/batch split keys before deletion, including a correlated
  result tampering case where both preview and reservation rows repeat a split.
- Added `PREVIEW_SO_ISSUE_REMAINING` as a read-only entry point for the selected
  sales-order reservations. It returns issueable item keys, remaining base-unit
  quantities, base-unit ISO codes, locations, and batches without posting; it
  rejects missing ISO mappings, and the posting methods keep their own re-read
  and eligibility checks.
- Added `PREVIEW_CC_ISSUE_REMAINING` and `POST_CC_ISSUE_REMAINING`. The preview
  can list all open cost-center reservations or filter by selected reservation
  numbers; posting requires an explicit selection and issues the open
  base-unit quantities through the existing scope-checked bulk path.
- Added `POST_CC_ISSUE_REMAINING_ATOMIC`. It uses the same selected open
  quantities, rechecks cost-center scope before each reservation movement, and
  requests one shared commit or rollback. Target LUW behavior remains noted in
  `ANOMALIES.md`.
- Added `POST_CC_ISSUE_REV_ATOMIC` for unit-aware cost-center withdrawal
  reversals. It rejects invalid simulation flags and missing posting dates
  before repository reads, validates the full selected scope before staging the
  group, and requests one shared commit or rollback. Tests cover unit conversion,
  commit behavior, and early flag rejection; target scope-query and LUW behavior
  remain noted in `ANOMALIES.md`.
- Added `PREVIEW_REMAINING_COMPONENTS` and `ISSUE_REMAINING_COMPONENTS` for an
  explicit set of production-order reservation items. The preview returns only
  open 261 components; posting issues the captured open quantities through the
  existing bulk path, which rereads and revalidates before one material
  document. Duplicate keys, invalid test flags, and non-261 issues are rejected;
  invalid flags fail before reads. The read snapshot limits are recorded in
  `ANOMALIES.md`.
- Added `PREVIEW_RETURNABLE_COMPONENTS` and `RETURN_REMAINING_COMPONENTS` for
  selected production-order reservation items. The preview includes fully
  withdrawn 261 items and reports the withdrawn balance; posting rereads and
  reverses those captured quantities together. Tests cover final-issue rows,
  duplicate selection, UOM-free full-balance posting, and early test-flag
  rejection. SAP reversal eligibility remains documented in `ANOMALIES.md`.
- Added `PREVIEW_CC_REV_REMAINING` and `POST_CC_REV_REMAINING_ATOMIC` for
  selected cost-center reservation items. The preview requires movement 201
  and reports withdrawn base quantities; posting reverses the full selected
  balances in one LUW and rechecks cost-center scope before staging each
  reservation. Tests cover preview mapping, one-commit posting, duplicate-key
  rejection, and rollback when scope changes. Target SAP behavior is recorded
  in `ANOMALIES.md`.
- Added `PREVIEW_CC_REMAINING_ITEMS` and `POST_CC_REMAINING_ITEMS_ATOMIC` so
  callers can choose exact reservation/item keys instead of issuing every item
  in selected reservation documents. Duplicate or missing keys are rejected;
  atomic posting rechecks cost-center scope and commits the selected items once.
  Exact-item tests cover selection, quantity mapping, and duplicate rejection.
- Added `POST_CC_REMAINING_ITEMS` as the independent-commit counterpart. It
  applies the exact item selection, then continues per reservation while
  returning per-document bulk results; the partial-success behavior is
  recorded in `ANOMALIES.md`.
- Added `POST_CC_REV_REMAINING_BULK` alongside the atomic full-balance reversal.
  It uses the same exact item preview but commits each reservation separately;
  tests verify two selected reservations produce two documents and commits.
  Partial-success and target SAP behavior remain in `ANOMALIES.md`.
- Added `PREVIEW_SO_REV_REMAINING` and bulk/atomic posting methods for the
  withdrawn balances of selected sales-order reservation documents. The preview
  validates movement 231 and sales-order item scope, rejects duplicate or
  missing selections, rejects negative or over-withdrawn rows, and skips
  zero-withdrawal items. Posting repeats the
  reservation check; bulk mode commits per reservation and atomic mode requests
  one shared commit. Tests cover quantity mapping, malformed balances,
  two-document bulk behavior, atomic grouping, and mismatched order scope.
  Target SAP LUW and reversal
  behavior are recorded in `ANOMALIES.md`. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit completion.
- Added exact-item sales-order reversal selection with
  `PREVIEW_SO_REV_REMAINING_ITEMS`, `POST_SO_REV_REM_ITEMS_BULK`, and
  `POST_SO_REV_REM_ITEMS_ATOMIC`. It reuses the movement-231 and order-item
  validation, rejects duplicate or unavailable reservation/item keys, and
  delegates posting to the per-reservation or shared-LUW paths. Tests cover
  selecting one of two items, bulk and atomic posting, missing keys, and
  duplicate-key rejection. Snapshot and SAP reversal limits are in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  transpilation completed, and ABAP Unit exited successfully.
- Added exact-item sales-order issue methods with
  `PREVIEW_SO_ISSUE_REM_ITEMS`, `POST_SO_ISSUE_REM_ITEMS_BULK`, and
  `POST_SO_ISSUE_REM_ITEMS_ATOMIC`. They validate movement 231 and order-item
  scope, require positive open quantities on every selected key, and re-read
  selected reservations before posting. Tests cover selecting one of two items,
  bulk and atomic posting, and missing/duplicate-key rejection. Snapshot and SAP
  LUW limits are recorded in `ANOMALIES.md`. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit completion.
- Added `RETURN_REMAINING_BULK` to return selected production component balances
  with independent per-reservation commits. It reuses the exact-key preview,
  groups multiple selected items into one reservation movement, rereads each
  production order before posting, and reports success or failure per
  reservation. Tests cover two reservations producing separate documents and
  commits, plus continuation after a later reservation read fails. Target SAP
  reversal and snapshot limits are recorded in `ANOMALIES.md`. `npm test` passed
  with 0 abaplint issues across 134 files, successful transpilation, and ABAP
  Unit completion.
- Added `ISSUE_REMAINING_BULK` for selected production component balances. It
  groups open 261 quantities per reservation, commits each group independently,
  returns per-reservation outcomes, and continues after a failed group. Tests
  cover multiple items grouped into one reservation document, separate
  reservation commits, and continuation after a later reservation detail read
  fails. Snapshot and
  partial-success limits are recorded in `ANOMALIES.md`. `npm test` passed:
  0 abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added optional production order item mapping to production receipts. The
  typed receipt line now carries AFPO's item number through the goods-movement
  interface to BAPI `ORDER_ITM`, enabling co-product receipt selection. A test
  verifies the production item survives receipt request construction; target
  BAPI field behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_UNPLANNED_PROD_BULK_UOM`. It converts all production-order
  issue lines to their mapped material base unit before the first goods
  movement, then preserves the existing per-order commit and continuation
  results. Tests cover two converted orders and reject a bad later unit before
  any create or commit. Target ratios and BAPI quantity behavior are noted in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added `RETURN_PROD_ORDERS_BULK` and `RETURN_PROD_ORDERS_BULK_UOM` for direct
  movement-262 returns across distinct production orders. The base-unit path
  validates all orders and lines before posting, commits independently per
  order, and continues after a BAPI failure. The UOM path converts every line
  before the first post. Tests cover continuation, two converted orders, and
  rejection of an unsupported later unit before any create or commit. SAP
  posting and reversal limits are recorded in `ANOMALIES.md`.
- Added `RETURN_PROD_ORDERS_ATOMIC` and `RETURN_PROD_ORDERS_ATOMIC_UOM` to stage
  one 262 movement per order and commit the group once, rolling back all staged
  results when a movement or commit fails. The UOM wrapper converts the full
  request before staging. Tests cover success, create and commit rollback,
  converted quantities, and invalid-unit prevalidation. Repeated-call LUW
  behavior remains a target SAP verification item. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added `RETURN_SALES_ORDERS_BULK` and `RETURN_SALES_ORDERS_BULK_UOM` for
  independent movement-232 returns across distinct sales documents. Bulk mode
  validates every order and line before posting, then continues after a failed
  order while retaining per-order outcomes. The UOM variant converts the full
  request before the first post. Tests cover special-stock E mapping,
  continuation, converted quantities, and unsupported later-unit rejection.
  Sales-order and stock eligibility remain SAP checks in `ANOMALIES.md`.
- Added `RETURN_SALES_ORDERS_ATOMIC` and `RETURN_SALES_ORDERS_ATOMIC_UOM` to
  stage one movement-232 document per distinct sales order and commit the group
  once. Movement and commit failures roll back provisional results; the UOM
  method converts the full request before staging. Tests cover group success,
  movement and commit rollback, special-stock E, converted quantities, and
  invalid-unit prevalidation. Target SAP LUW behavior is in `ANOMALIES.md`.
  `npm test` passed: 0 abaplint issues across 134 files, successful
  transpilation, and ABAP Unit exit 0.
- Added `ISSUE_SALES_ORDERS_BULK` and `ISSUE_SALES_ORDERS_BULK_UOM` for
  independent movement-231 issues across distinct sales documents. The base
  path prevalidates the full request and continues after an order failure; the
  UOM path converts every line before the first post. Tests cover special-stock
  E mapping, failure continuation, converted quantities, and rejection of an
  unsupported later unit before any create or commit. SAP issue eligibility is
  recorded in `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134
  files, successful transpilation, and ABAP Unit exit 0.
- Added `ISSUE_SALES_ORDERS_ATOMIC` and `ISSUE_SALES_ORDERS_ATOMIC_UOM` to stage
  one movement-231 document per distinct sales order and commit the group once.
  Movement and commit failures roll back provisional results; UOM conversion
  validates the full request before staging. Tests cover group success,
  movement and commit rollback, special-stock E, converted quantities, and
  invalid-unit prevalidation. Target SAP LUW behavior is recorded in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added `ISSUE_PROD_ORDERS_ATOMIC` and `ISSUE_PROD_ORDERS_ATOMIC_UOM` for
  group-wide movement-261 issue across distinct production orders. The service
  validates every order and line before staging, converts all UOM lines before
  staging, and rolls back provisional results when a movement or shared commit
  fails. Tests cover success, movement and commit rollback, converted
  quantities, and invalid-unit prevalidation. Repeated-call SAP LUW behavior is
  recorded in `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134
  files, successful transpilation, and ABAP Unit exit 0.
- Added `TRANSFER_SALES_STOCK_BULK` and `TRANSFER_SALES_STOCK_ATOMIC` for
  movement-411/E transfers from sales-order stock to own stock across distinct
  sales documents, with UOM variants. Bulk mode commits each order separately
  and continues after a posting failure; atomic mode stages all orders and
  commits once, clearing provisional document results after movement or commit
  failure. Tests cover mapping, continuation, shared commit and rollback,
  converted quantities, and invalid-unit prevalidation. SAP LUW and eligibility
  checks are noted in `ANOMALIES.md`. `npm test` passed with 0 abaplint issues
  across 134 files, successful transpilation, and ABAP Unit exit 0.
- Added grouped movement-413/E transfers from own stock into sales-order stock:
  `TRANSFER_TO_SALES_STOCK_BULK`, `TRANSFER_TO_SALES_STOCK_ATOMIC`, and their
  UOM forms. Bulk mode commits independently and continues after a failed order;
  atomic mode stages one document per order and rolls back on movement or commit
  failure. Tests cover mapping, continuation, atomic commit and rollback,
  converted quantities, and full-request invalid-unit rejection. Target SAP LUW
  and eligibility checks are in `ANOMALIES.md`. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit exit
  0.
- Added UOM-aware production receipts for single orders and multi-order bulk
  and atomic posting. The service requires material identity for conversion,
  applies caller-supplied base-unit/ISO mappings, and preserves optional batch,
  location, and co-product item fields. Multi-order UOM methods convert the
  full request before posting. Tests cover the single, bulk, and atomic mappings
  and reject an unsupported later unit before any movement. Target ratio,
  rounding, and BAPI unit behavior are recorded in `ANOMALIES.md`. `npm test`
  passed: 0 abaplint issues across 134 files, transpilation succeeded, and ABAP
  Unit exited 0.
- Added UOM-aware purchase-order receipts for single, bulk, and atomic flows.
  The service converts each material quantity to the mapped base unit while
  preserving PO item, plant, storage location, and batch fields. Bulk and
  atomic forms convert and validate the complete request before posting. Tests
  cover all three entry points and reject an unsupported later unit before any
  receipt call. PO-unit, open-quantity, and rounding checks are recorded in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added `ISSUE_STO_UOM` and `RECEIVE_STO_UOM` for alternative-unit STO goods
  issue and receipt. Both prevalidate material mappings and all lines, convert
  quantities to mapped base units, and preserve PO item, batch, and plant/
  storage-location data. Tests verify 351/101 movement mapping and reject a
  later unsupported unit before any BAPI call. Target STO item-unit and
  remaining-quantity behavior is recorded in `ANOMALIES.md`. `npm test` passed
  with 0 abaplint issues across 134 files, successful transpilation, and ABAP
  Unit exit 0.
- Added grouped cost-center issue APIs. Bulk mode prevalidates all distinct
  cost centers and lines, commits once per center, and continues after errors;
  its UOM form converts all quantities before posting. Atomic mode stages all
  center documents and shares one commit, with rollback and provisional-result
  clearing after movement or commit failure. Tests cover unit conversion,
  invalid later units, and both rollback paths. Target LUW limits are recorded
  in `ANOMALIES.md`.
- Added grouped cost-center return APIs for movement 202. Bulk and atomic forms
  mirror the issue transaction scopes, with UOM variants converting the full
  request before posting. The result preserves per-center outcomes, and atomic
  failures clear staged document identifiers after rollback. Tests cover the
  movement mapping, per-center continuation, conversion, invalid later units,
  and both rollback paths. `npm test` passed with 0 abaplint issues across 134
  files, successful transpilation, and ABAP Unit exit 0.
- Added typed PO vendor returns with movement 122: single, bulk, atomic, and
  UOM-aware entry points. Bulk mode commits each PO independently; atomic mode
  shares one commit and clears provisional document identifiers on failure.
  UOM forms convert the full request before posting. Tests cover mapping,
  conversion, continuation, prevalidation, and rollback. Target PO eligibility
  and LUW behavior are recorded in `ANOMALIES.md`. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added material-to-material transfer posting with movement 309 and an
  alternative-unit form. The service carries source and receiving materials,
  optional receiving plant/location and batch, converts source quantities to
  base units, and requires matching base-unit/ISO mappings for both materials.
  Movement-309 target-system and catch-weight limitations are recorded in
  `ANOMALIES.md`. `npm test` passed with 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added direct material-to-material LIFO posting with movement 310 and a UOM
  form. Both entry points share the 309 validation and preserve receiving
  plant/location and batch fields; UOM quantities convert to the matched
  source/receiving base unit. SAP's direct-MIGO LIFO description and the API
  posting-path caveat are recorded in `ANOMALIES.md`. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added an optional exact batch to multi-demand cost-center FEFO previews. The
  selected batch remains subject to the same effective expiry and shelf-life
  checks, and other batches cannot fill its shortfall. Tests cover a partial
  allocation with another eligible batch available. `npm test` passed with 0
  abaplint issues across 136 files, successful transpilation, and ABAP Unit
  exit 0; validation details are in `ANOMALIES.md`.
- Extended atomic cost-center FEFO reservations to accept an optional exact
  batch on individual demand rows while other rows continue normal FEFO. The
  full group still preallocates before creating reservations. `npm test` passed
  with 0 abaplint issues across 136 files, successful transpilation, and ABAP
  Unit exit 0; SAP stock and reservation behavior remains documented in
  `ANOMALIES.md`.
- Extended single cost-center FEFO preview and reservation to accept an exact
  batch filter. `iv_batch_min_days` can further raise that selected batch's
  minimum remaining shelf life; FEFO still applies the later effective date.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
- Extended sales-order FEFO with partial exact-batch selections. Selected items
  or schedule lines stay on their chosen batch; unselected demand still follows
  FEFO, and per-selection shelf-life requirements combine with FEFO minimums.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
- Extended bulk cost-center FEFO to honor an optional exact batch per demand,
  forwarding the filter through the atomic per-demand allocation path. The
  selected lot still must meet the effective expiry date. `npm test` passed
  with 0 abaplint issues across 136 files, successful transpilation, and ABAP
  Unit exit 0.
- Extended `ALLOCATE_LOCATION_BY_DATE_UOM` and
  `ALLOCATE_LOCATION_DATE_UOM_ATP` with the same caller-resolved projected
  location receipts accepted by the base-unit APIs. Demand quantities convert
  through cached material UOM ratios; receipt quantities stay in base units,
  and both results preserve caller order. Regression coverage checks receipt
  date validation before reads, source/base-unit splits, location selection,
  safety-stock replenishment, duplicate-request rejection before repository
  reads, and cumulative ATP checks. `npm test` passed with 0 abaplint issues
  across 136 files, successful transpilation, and ABAP Unit exit 0. Validation
  notes are in `ANOMALIES.md`.
- Extended `ALLOCATE_PLANTS_BY_DATE_LOC`, its UOM wrapper, and its ATP preview
  with caller-resolved location receipts in material base units. Receipts are
  source-plant scoped, become available on their date, replenish any remaining
  static safety-stock buffer, and retain source-location filtering. Regression
  tests cover date ordering, late receipt availability, location splits,
  safety-stock protection, invalid-date rejection before reads, UOM conversion,
  and ATP requests. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Target-system limitations are
  in `ANOMALIES.md`.
- Extended dated cross-plant FEFO allocation, its UOM wrapper, and its ATP
  preview with caller-resolved projected batch receipts in material base units.
  Receipts enter the shared FEFO balance on their receipt date and keep the
  existing expiry, shelf-life, location-filter, and safety-stock behavior.
  Regression coverage checks date gating, safety-stock replenishment, UOM
  quantities, ATP forwarding, and invalid receipt dates before stock reads.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
  Callers provide the receipt's source plant, location, batch, expiry, and
  quantity; the service does not derive or confirm those assignments from SAP
  planning documents. Details and target-system caveats are in `README.md` and
  `ANOMALIES.md`.
- Extended the as-of-date cross-plant FEFO snapshot, its unit-aware wrapper, and
  its ATP preview with the same caller-resolved batch receipts. Receipts dated
  on or before the snapshot date join its balances before safety-stock
  protection; later receipts are ignored. Regression coverage checks the
  snapshot cutoff, FEFO splits, safety-stock handling, base-unit conversion,
  ATP request totals, and invalid dates before stock or UOM reads. `npm test`
  passed with 0 abaplint issues across 136 files, successful transpilation, and
  ABAP Unit exit 0. Callers still provide the snapshot quantity and SAP ATP does
  not receive the batch assignments; details are in `README.md` and
  `ANOMALIES.md`.
- Extended single-plant FEFO allocation, its unit-aware wrapper, and its ATP
  preview with caller-resolved dated batch receipts. Per-demand as-of dates
  gate receipt availability even when demands are processed out of date order,
  and due receipts replenish a remaining static safety-stock buffer before
  allocation. Regression coverage checks date gating, buffer replenishment,
  UOM conversion, ATP forwarding, and invalid receipt rejection before UOM
  reads. `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Target-system limits are in
  `README.md` and `ANOMALIES.md`.
- Extended quality-stock FEFO, its UOM wrapper, and ATP comparison with
  caller-resolved projected batch receipts interpreted as future
  quality-inspection stock. Receipts follow per-demand as-of dates and retain
  expiry, location, and batch filters. Tests cover receipt cutoff, unit
  conversion, ATP forwarding, and bad-date rejection before UOM or stock reads.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Target stock-category and ATP limits are
  recorded in `ANOMALIES.md`.
- Extended exact-batch allocation, its UOM wrapper, and ATP preview with
  caller-resolved projected batch receipts. Receipt availability follows each
  demand's as-of date, and due receipts replenish the residual static
  safety-stock buffer before allocation. Regression coverage checks cutoff,
  safety-stock, UOM, ATP, and pre-UOM date validation. `npm test` passed with 0
  abaplint issues across 136 files, successful transpilation, and ABAP Unit exit
  0. Target-system limits are recorded in `README.md` and `ANOMALIES.md`.
- Extended cross-plant exact-batch allocation, date-prioritized allocation,
  their UOM wrappers, and ATP previews with caller-resolved projected batch
  receipts in material base units. Receipt quantities enter the mapped source
  plant/batch balance on their receipt date, using each demand's `as_of_date`
  or `required_date` as its cutoff. Due receipts replenish a remaining static
  safety-stock buffer. Regression coverage checks current-date and dated
  cutoffs, date ordering, unit conversion, and invalid source mapping before
  UOM reads. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. SAP routing, receipt, and ATP
  behavior limits are in `README.md` and `ANOMALIES.md`.
- Added per-demand `minimum_shelf_life_days` to cross-plant exact-batch
  allocation, date-prioritized demands, UOM conversions, and ATP previews.
  The base demand form requires an explicit as-of date for positive minimums;
  the undated UOM wrapper uses today and date-aware wrappers use
  `required_date`. Positive minimums reject unknown or too-near expiry and
  filter both availability totals and source/location splits.
  Regression coverage checks the expiry boundary and the date ATP/UOM
  propagation. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. SAP batch master and ATP
  behavior limits are in `README.md` and `ANOMALIES.md`.
- Added `iv_include_undated_batches` to single- and cross-plant exact-batch
  allocation, including date-prioritized, UOM, and ATP wrappers. Its default
  keeps existing behavior; setting it false excludes current stock and
  projected receipts without a known expiry from availability and allocation
  splits. Invalid flag values fail before UOM or stock reads. Regression
  coverage checks both current and projected undated batches, wrapper
  forwarding, ATP suppression for excluded stock, and pre-read validation.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Target expiry-data and ATP limits are in
  `README.md` and `ANOMALIES.md`.
- Added `iv_include_undated_batches` to cost-center exact-batch and FEFO
  previews, atomic and bulk reservations, and single-demand preview/reservation.
  The default preserves inclusion of batches with unknown expiry; setting the
  flag false removes them from available quantity and selected splits. Tests
  cover batch and FEFO selection and option forwarding across reservation
  entry points. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Target metadata and ATP
  limits are recorded in `README.md` and `ANOMALIES.md`.
- Added `iv_require_full_quantity` to cost-center plant, dated, location,
  exact-batch, and FEFO multi-demand previews. Short demands now receive zero
  allocation under this option, leaving the remaining balance available for
  later requests; dated ATP previews apply the same local rule while retaining
  separate SAP diagnostics. Regression coverage exercises every preview path
  and both dated ATP modes. `npm test` passed with 0 abaplint issues across 136
  files, successful transpilation, and ABAP Unit exit 0. The snapshot and
  concurrency limits are documented in `ANOMALIES.md`.
- Added `iv_require_full_quantity` to sales-order FEFO previews in base and
  alternative units. An underfilled request receives zero allocation and does
  not consume eligible item stock, allowing a later smaller request to use the
  balance. The option is validated before stock reads and defaults to the
  existing partial behavior. Regression coverage includes repeated base-unit
  and UOM requests. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Snapshot and locking limits
  are recorded in `README.md` and `ANOMALIES.md`.
- Extended `iv_require_full_quantity` to aggregate sales-order issue previews
  in base and alternative units. Underfilled requests now receive zero
  coverage without consuming the shared item/cutoff balance. Tests verify a
  later smaller request can use that balance, including after UOM conversion.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Snapshot limits remain in
  `ANOMALIES.md`.
- Added `preview_cost_center_fefo_date` for date-prioritized batch previews.
  Earlier required dates consume shared stock first, descending integer
  priority breaks same-date ties, and input order is stable for equal keys.
  Results return in caller order and echo each date and priority; expiry checks
  use the latest of shared as-of, row FEFO as-of, and required date. Regression
  coverage checks date/priority allocation, caller-order results, and rejection
  of invalid dates before stock reads. `npm run lint` reported zero issues,
  and `npm run unit` completed transpilation and ABAP Unit with exit 0. The
  combined `npm test` launcher hits a WSL 1 nested-Node error, so its two
  constituent scripts were run separately.
- Added `reserve_cc_fefo_date_atomic`, which applies required-date and
  descending-priority order to the existing preallocate/create/commit flow and
  returns result items in caller order. Its regression checks allocation order,
  same-date priority, caller-order results with echoed date/priority, and
  test-run behavior. `npm run lint` reported zero issues, and `npm run unit`
  completed transpilation and ABAP Unit with exit 0. Validate the local snapshot
  and concurrency limits in `ANOMALIES.md`.
- Added `reserve_cc_fefo_date_bulk`, which runs independent FEFO reservations
  in required-date and descending-priority order, then returns item rows in
  caller order with echoed date/priority. Regression coverage checks call
  ordering, output ordering, and invalid-date rejection before stock reads. The
  bulk method keeps per-demand commit behavior, so earlier successful calls
  remain committed after a later failure. `npm run lint` reported zero issues,
  and `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added opt-in required-date/priority ordering to aggregate sales-order stock
  issue previews in base and alternative units. Earlier dates consume repeated
  item/cutoff balances first, higher priorities run first within a date, and
  equal keys preserve input order. Results return in caller order and echo date
  and priority; invalid required dates are rejected before repository reads.
  `npm run lint` reported zero issues and `npm run unit` completed transpilation
  and ABAP Unit with exit 0. The reservation cutoff remains independent from
  demand ordering; the snapshot limit is recorded in `ANOMALIES.md`.
- Extended FEFO sales-order stock issue previews in base and alternative units
  with the same optional date/priority ordering. A demand's required date raises
  its expiry cutoff, so earlier requests can use a batch that expires before a
  later demand; result summaries and splits return in caller order. Regression
  coverage checks batch eligibility by row date, priority, UOM conversion, and
  invalid-date rejection before reads. `npm run lint` reported zero issues and
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added opt-in priority handling to cost-center FEFO atomic and bulk reservations.
  Atomic allocation and create calls now process higher integer priorities
  first while keeping result rows and API responses attached to caller-order
  requests. Bulk reservation calls run independently in priority order and
  restore caller order afterward. Invalid flags and priority mode on unbatched
  non-FEFO requests are rejected before stock reads. Tests verify FEFO batch
  assignment, create-call order, result order, and priority echo. `npm run lint`
  reported zero issues across 138 files; `npm run unit` completed transpilation
  and ABAP Unit with exit 0. Stock snapshot and concurrency limits are in
  `ANOMALIES.md`.
- Added the same priority option to explicit-batch cost-center previews and
  reservation flows. Shared stock for the selected batch is allocated by
  descending priority with stable input-order ties; atomic and bulk create calls
  follow that order while returning results in caller order. Unbatched requests
  cannot enable priority mode. Regression tests cover shared batch/location
  allocation, API dispatch order, echoed priority, and response mapping.
  `npm run lint` reported zero issues across 138 files, and `npm run unit`
  completed transpilation and ABAP Unit with exit 0. The snapshot and SAP
  reservation visibility limits are recorded in `ANOMALIES.md`.
- Split automatic projected-receipt previews by material/plant pair: a pair with
  any selected receipt missing its receiving location now falls back to the
  plant-level allocator without disabling scoped allocation for other pairs.
  Each pair still queries only through its latest component required date.
  Added stock and ATP regressions for a missing-location receipt beside a
  scoped pair with a later out-of-horizon receipt. Updated README and anomaly
  notes to match. `abaplint` reported zero issues across 138 files;
  transpilation and `validate:plan` passed; ABAP Unit passed all 1,869 cases;
  `git diff --check` passed with CRLF handling.
- Expanded `validate:plan` to derive every SAP `table~field` used by the stock
  repository and verify that the corresponding local table stub declares it.
  This now covers the receipt-source queries alongside the explicit MARD,
  RESB, PO, confirmation, production, requisition, and planned-order checks.
  All referenced fields were already present in the stubs. README development
  instructions now describe the validator.
- Added a multi-pair repository read for confirmation-aware purchase-order
  receipts. It fetches schedule remainders and MRP-relevant confirmations in
  two queries across all requested pairs, filters each pair to its own maximum
  deadline, and returns request rows in caller order. Shared-flag, per-request
  option, and UOM bulk projections now use that path. Local tests cover horizon
  filtering and verify that the service dispatches one repository bulk call;
  live EKET/EKES joins remain a target-system validation item. `abaplint` found
  zero issues across 138 files, PLAN validation passed, transpilation succeeded,
  and all 1,869 ABAP Unit cases passed. `git diff --check` passed with CRLF
  handling.
- Applied the per-material/plant deadline inside both FAE statements, so a
  longer horizon for one pair does not widen another pair's database read.
  Extended `validate:plan` to require those EKET and EKES deadline predicates.
  PLAN validation, abaplint, transpilation, all 1,869 ABAP Unit cases, and the
  CRLF-aware diff check passed. SAP execution of the joins remains unverified.
- Extended the repository bulk projection to batch purchase-order,
  scheduling-agreement, STO, production, requisition, and planned-order reads
  across unique material/plant scopes. Each FAE query now uses that pair's own
  maximum deadline; results are trimmed to each request cutoff and returned in
  caller order. The plan validator checks source-query counts, batching, date
  bounds, and service delegation. Regression coverage verifies one bulk
  repository dispatch alongside request ordering and cutoff filtering.
  `validate:plan` passed, abaplint reported zero issues across 138 files,
  transpilation passed, and all 1,869 ABAP Unit cases passed. SAP execution of
  the receipt joins and query plans remains unverified.
- Batched `GET_PROJ_RECEIPTS_OPTS_BULK` by matching material/plant source
  selections, while keeping PO confirmations on their separate bulk path. Each
  pair still queries only through its own latest request date, and each result
  retains its per-request source and date filters. Regression coverage checks
  that different pairs with the same combined source selection use one
  repository bulk dispatch. `validate:plan` passed, abaplint reported zero
  issues across 138 files, transpilation passed, all 1,869 ABAP Unit cases
  passed, and the CRLF-aware diff check passed. SAP query execution remains
  unverified.
- Added `get_available_stock_date_bulk` and switched dated demand allocation to
  fetch unique material/plant/date availability scopes together. The repository
  batches MARD stock, cutoff-scoped RESB rows, PO/STO schedules, outgoing STOs,
  and production receipts, and reuses the projected-receipt bulk path for PR,
  planned-order, and scheduling-agreement sources. The service still applies
  PO confirmations and safety stock per cutoff before sharing balances. Tests
  verify allocation output, duplicate-scope caching, and one bulk dispatch.
  `validate:plan` now checks batch scopes, per-request date predicates, and
  selected row keys that prevent duplicate FAE rows from collapsing. abaplint
  reported zero issues across 138 files, transpilation passed, all 1,869 ABAP
  Unit cases passed, and the CRLF-aware diff check passed. Target SAP SQL checks
  remain open.
- Extended the same dated availability batch to `ALLOCATE_PLANTS_BY_DATE`.
  Candidate source-plant/date scopes are deduplicated across all demands, read
  together, then combined with cutoff-specific PO confirmations and cached
  safety stock before source balances are allocated. Regression coverage checks
  one repository bulk dispatch across four source-plant/date scopes. abaplint
  reported zero issues across 138 files, transpilation passed, all 1,869 ABAP
  Unit cases passed, and the CRLF-aware diff check passed. Target SAP SQL
  behavior remains unverified.
- Changed `ALLOCATE_PLANTS_FEFO_BY_DATE` to fetch batch status for all unique
  material/source-plant pairs in one validated bulk repository call. The
  service keeps positive-quantity filtering, safety-stock protection, source
  location rules, projected receipts, and existing FEFO ordering. Added a
  regression assertion for one bulk dispatch despite repeated demands sharing
  a pair, and added a plan-validator check that prevents reintroducing the
  per-pair read. Target SAP query-plan and reservation-subtraction behavior
  remain to be checked.
- Applied the same bulk batch-status read to `ALLOCATE_PLANTS_BY_EXPIRY`. It
  retains caller-ordered source plants, date eligibility, receipt handling,
  location rules, and safety-stock behavior while deduplicating current-stock
  reads by material/source-plant pair. The FEFO regression now checks one bulk
  dispatch across repeated demands. `validate:plan` checks both cross-plant
  FEFO entry points for bulk dispatches; SAP query-plan and reservation
  subtraction behavior remain unverified. Verification after both FEFO changes:
  plan validation passed, abaplint reported zero issues across 138 files,
  transpilation passed, and all 1,869 ABAP Unit cases passed.
- Changed `ALLOCATE_PLANTS_BY_BATCH` to load all unique material/source-plant
  batch statuses through one validated bulk call. Dated, undated, and unit-aware
  wrappers inherit the single dispatch while preserving exact-batch matching,
  cutoff ordering, projected receipts, and safety-stock behavior. Added bulk
  dispatch assertions and extended `validate:plan` to catch per-pair reads.
  `validate:plan` passed, abaplint reported zero issues across 138 files,
  transpilation passed, and all 1,869 ABAP Unit cases passed. Target SAP query
  plans and reservation subtraction still need review.
- Batched current stock in the single-plant `ALLOCATE_BY_BATCH` preview after
  validating all demands and receipt options. The allocator fetches each unique
  material/plant batch status once, then preserves its existing batch, date,
  location, receipt, and safety-stock calculations. Added bulk-dispatch coverage
  for multiple requests sharing one pair and extended `validate:plan` to reject
  the per-pair read. Updated cost-center and sales-order test doubles to return
  configured batch stock from the bulk API. `validate:plan` passed, abaplint
  reported zero issues across 138 files, transpilation passed, and all 1,869
  ABAP Unit cases passed. Target SAP query plans and reservation subtraction
  still need review.
- Changed single-plant `ALLOCATE_BY_EXPIRY` to fetch all unique material/plant
  batch statuses in one validated bulk call after demand and receipt validation.
  Positive stock filtering and existing FEFO, location, shelf-life, receipt,
  and safety-stock behavior are unchanged. Added a wrapper regression assertion
  and extended `validate:plan` to prevent the per-pair read. Updated the
  quality-stock test double to model unrestricted batch reads and rechecks
  separately from quality stock. `validate:plan` passed, abaplint reported zero
  issues across 138 files, transpilation passed, and all 1,869 ABAP Unit cases
  passed. Target SAP query plans and reservation subtraction still need review.
- Batched scoped component reads for location stock, batch stock, open
  reservations, and protected safety stock. `ALLOCATE_COMPONENT_STOCK`
  deduplicates material/plant scopes before dispatch and maps validated
  responses into the existing per-scope balance logic. The MARD adapter reads
  eligible RESB rows and MARC safety stock through guarded `FOR ALL ENTRIES`
  queries; safety stock is read only when protection is enabled. The RESB query
  retains the single-scope filters for special stock, deletion, final issue,
  and open quantity. A two-plant regression checks four dispatches and
  allocation results. Also batched safety-stock reads in single-plant exact
  batch, single-plant FEFO, and dated and undated cross-plant FEFO and exact
  batch allocation; two-scope regressions verify one safety dispatch for each
  allocator and preserve their allocations. `validate:plan` guards service and
  repository paths. Plan validation passed, abaplint reported zero issues across
  138 files, transpilation passed, all 1,871 ABAP Unit cases passed, and the
  CRLF-aware diff check passed. Target SAP query plans and reservation
  visibility remain unverified.
- Replaced per-scope location reads in `ALLOCATE_ACROSS_PLANTS`,
  `ALLOCATE_BY_STORAGE_LOCATION`, and the projected-receipt path of
  `ALLOCATE_LOCATION_BY_DATE` with one validated
  `GET_LOCATION_STOCK_STATUS_BULK` dispatch across unique material/plant pairs.
  The repository already applies the same reservation-adjusted location
  quantity calculation as the former single-pair method. Safety stock is also
  fetched once per allocator, then consumed across locations before projected
  receipts are applied. Regressions cover two-scope dispatch counts and
  existing allocation outputs; `validate:plan` guards both bulk paths.
  Plan validation passed, abaplint reported zero issues across 138 files,
  transpilation passed, all 1,871 ABAP Unit cases passed, and the CRLF-aware
  diff check passed.
- Added SQLite-backed Open SQL integration cases for bulk MARC safety stock,
  eligible RESB reservations and open quantities, and reservation-adjusted MARD
  location balances. `scripts/run-unit.mjs` configures the default SQLite
  connection and test schemas before the generated ABAP Unit runner starts.
  `validate:plan` passed, abaplint found 0 issues across 139 files,
  transpilation passed, and all 1,874 ABAP Unit cases passed. Target SAP DDIC,
  query-plan, and live reservation-visibility checks remain outstanding.

- Extended SQLite-backed adapter coverage to batch stock. The new case executes
  the MCHB, MCHA, MCH1, and RESB query paths, checking plant expiry precedence,
  global expiry fallback, duplicate scope results, stock categories, and both
  specific and unassigned reservation deductions. Full `npm test` passed:
  plan validation, 0 abaplint issues across 139 files, transpilation, and all
  1,875 ABAP Unit cases. Target SAP checks remain recorded in `ANOMALIES.md`.

- Added SAP import scaffolding: `.abapgit.xml` points abapGit at `/src/`,
  `src/package.devc.xml` defines the installable package, and all 67 classes and
  29 interfaces now have object metadata. Added `npm run generate:abapgit` for
  new objects and plan validation that checks metadata coverage and unit-test
  flags. README now documents package assignment and SAP-side activation checks.
  Metadata follows abapGit's documented XML shape; a target SAP import remains
  unverified.
  `npm run generate:abapgit` reports no missing files on a second run. `npm test`
  passes with 0 abaplint issues across 236 files, successful transpilation, and
  all 1,875 ABAP Unit cases; all 98 abapGit XML files parse and the diff check
  is clean. Target SAP import and activation remain unverified.

- Hardened the public batch-eligibility check to validate the as-of date and every dated expiry as Gregorian dates before date comparison. Invalid calendar dates now raise `zcx_invalid_stock_request`; blank expiry remains the supported undated-batch representation. Added ABAP Unit cases for an impossible as-of date and expiry. Full `npm test` passed: plan validation, 0 abaplint issues across 236 files, transpilation, and all 1,877 ABAP Unit cases.

- Hardened projected-supply quantity calculators against negative receipt,
  ordered, issue, and MRP-reduction counters. Invalid negative counters now
  yield zero projected quantity instead of inflating open supply; valid
  partial quantities and unit conversion are unchanged. Added regression
  coverage for PO schedule, PO confirmation, unissued STO, PR, and
  production-order calculations. Full `npm test` passed: plan validation,
  0 abaplint issues across 236 files, transpilation, and 1,880 ABAP Unit
  cases.

- Added SQLite-backed Open SQL coverage for `ZCL_MATERIAL_UOM_REPOSITORY`: MARA base-unit reads, MARM alternative unit ratios keyed by material and unit, and missing-row results. Extended the runner schema and PLAN validation for required MARA/MARM fields, and added MANDT to both client-dependent table stubs. Full `npm test` passed with 0 abaplint issues across 237 files and all 1,884 ABAP Unit cases. Target SAP DDIC behavior remains to be checked.

- Added SQLite-backed Open SQL tests for `ZCL_MARC_REPL_POLICY_REPO`, covering MARC policy selection, required MARA base units, optional T001W/T399D values, missing materials, and RDPR profile levels. Reworked the join into batched reads and kept RDPR fields unqualified to avoid malformed FAE SQL generated by the local transpiler. Updated the local schema, PLAN checks, README, and target-SAP caveats. Full `npm test` passed: PLAN validation, 0 abaplint issues across 238 files, transpilation, and all 1,886 ABAP Unit cases. Target SAP DDIC and SQL behavior remain to be checked.

- Added SQLite-backed Open SQL coverage for `ZCL_T439I_CAL_PERIOD_REPO`. The test checks inclusive overlap at both horizon boundaries and filters out rows for other plants, calendars, and dates. Kept query fields unqualified for correct local FAE code generation. Added the T439I schema and required stub fields to PLAN validation; updated the README and target-SAP caveat. Full `npm test` passed: PLAN validation, 0 abaplint issues across 238 files, transpilation, and all 1,887 ABAP Unit cases. Target SAP T439I behavior remains unverified.

- Added SQLite-backed tests for `ZCL_PLAF_ORDER_READ_REPO` covering order selection and sorting, base units, alternative-unit ratios, and left-join behavior when MARA or MARM data is missing. Replaced the alias-qualified join with batched PLAF/MARA/MARM reads to keep local FAE generation correct. Added client field `MANDT` to the PLAF stub, extended its PLAN checks and local SQLite schema, and documented the coverage. Full `npm test` passed: PLAN validation, 0 abaplint issues across 239 files, transpilation, and all 1,889 ABAP Unit cases. Target SAP DDIC and SQL behavior remain to be checked.

- Added SQLite-backed tests for `ZCL_PROD_COMP_REPO` that execute the RESB bulk query and single-order wrapper, verify reservation-item ordering and component mapping, and ensure deleted/final-issue rows remain available to downstream service logic. Added its required source artifact to PLAN validation and documented the SQL coverage. Full `npm test` passed: PLAN validation, 0 abaplint issues across 240 files, transpilation, and all 1,891 ABAP Unit cases. Target SAP RESB behavior remains unverified.

- Added SQLite-backed SQL coverage for `ZCL_STOCK_TRANSFER_REPOSITORY`: plant-level transfer totals, all-location and exact-location balances, nonzero location/batch detail reads, the ordered single-batch query, and empty bulk guards. Added required MARC/MARD/MCHB field checks to PLAN validation and updated the local SQL coverage notes. Full `npm test` passed: PLAN validation, 0 abaplint issues across 241 files, transpilation, and all 1,894 ABAP Unit cases. Target SAP transfer-stock behavior remains unverified.

- Strengthened PLAN validation after finding that unqualified SQL field names bypassed its `table~field` scan. The validator now checks typed SAP table-field references in every custom ABAP source against the local DDIC stubs, while retaining explicit checks for query-required fields. Full `npm test` passed: PLAN validation, 0 abaplint issues across 241 files, transpilation, and all 1,894 ABAP Unit cases.

- Added SQLite-backed tests for `ZCL_SO_STOCK_REPOSITORY` covering order-item resolution, base-unit reads, MSKA stock filtering and MARA-required rows, plant/global expiry precedence, RESB open-reservation filters, and empty-request guards. Reworked the stock join into batched MSKA/MARA reads while preserving its inner-join behavior. Added MANDT to the VBAP stub and query-field validation/schema, including KWMENG and VSMNG in the runner’s VBAP DDL for test-environment inserts. Full `npm test` passed: PLAN validation, 0 abaplint issues across 242 files, transpilation, and all 1,898 ABAP Unit cases. Target SAP DDIC and SQL behavior remain to be checked.
- Added SQLite-backed Open SQL tests for `ZCL_SALES_ORDER_DELIVERY_REPO`, checking ordered schedule lines, requested and material-availability dates, ordered/confirmed/delivered quantities, status presence, multi-document selection, VBAP fallback for items without schedule lines, the single-document wrapper, and empty input. Added client/key metadata to VBUP and local VBEP/VBUP schemas, and expanded PLAN validation and integration notes. Full validation passed: PLAN validation, 0 abaplint issues across 243 files, transpilation, and all 1,900 ABAP Unit cases. Target SAP query behavior remains to be checked.
- Added SQLite-backed Open SQL tests for `ZCL_CC_RESERVATION_READ_REPO`, covering RESB/RKPF cost-center scope, movement and status filters, remaining quantity, sort order, the single-center wrapper, item-scope lookup, and empty requests. Reworked the join into batched header and item reads to avoid malformed local transpiler join/FAE SQL while preserving inner-join behavior; moved the remaining-quantity comparison into the merge loop. Added RKPF schema and PLAN field checks, and updated the SQL coverage caveat. Full `npm test` passed: PLAN validation, 0 abaplint issues across 244 files, transpilation, and all 1,903 ABAP Unit cases. Target SAP query plans and authorization remain to be checked.
- Added SQLite-backed Open SQL coverage for all five `ZCL_PROJECT_STOCK_REPOSITORY` methods. Tests cover MSPR positive-Q stock selection by key and WBS, PRPS mapping, plant-first/global-fallback expiry, open RESB quantity filters and calculations, and final-issue/fully withdrawn reservation-item visibility. Reworked aliased joins as batched PRPS/MSPR and PRPS/RESB reads while preserving WBS and lifecycle filters; moved the two-column open-quantity comparisons into ABAP. Added MSPR/PRPS schemas and PLAN field checks and updated target-system notes. Full `npm test` passed: PLAN validation, 0 abaplint issues across 245 files, transpilation, and all 1,908 ABAP Unit cases. Target SAP query plans and DDIC behavior remain unverified.
- Added SQLite-backed Open SQL tests for all six `ZCL_REPL_SOURCE_REPO` methods, covering purchasing info records across exact and global plants, source-list agreement joins and source contexts, quota headers/items, rounding levels, usage rules, and empty-input guards. Corrected the local EINA MATNR stub to match the 40-character material type used by the repository, replaced broad reads with explicit field lists, keyed EINE reads by info record/org/plant, and changed source-context FAE selects to unqualified fields. Expanded SQLite schemas, PLAN field/shape checks, class test metadata, and integration notes. Full `npm test` passed: PLAN validation, 0 abaplint issues across 246 files, transpilation, and all 1,915 ABAP Unit cases. Confirm the EINA material-number length and source/quota data semantics against the target SAP release.
- Added SQLite-backed Open SQL tests for all four `ZCL_PROD_ORDER_READ_REPO` methods, covering AFPO item mapping and sorting, active JEST status filtering with TJ02T/TJ30T text, AFRU/AFVC confirmation joins and ordering, AFKO/AFVC operation mapping, category filters, and empty input. Replaced multi-table joins with narrow batched reads and ABAP key merges after local tests returned no rows from the aliased joins; added the SQLite schemas, required PLAN stub fields, and class test metadata. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,920 ABAP Unit cases. Target SAP DDIC fields, status semantics, and operation-key behavior remain unverified.

- Added SQLite-backed Open SQL coverage for bulk projected purchase-order
  receipts. The test exercises narrow EKPO/EKKO/MARA/EKET reads and key merges,
  including open-item filters, schedule cutoffs, partial receipt netting, and
  PO-unit conversion. Reworked the joined PO receipt read into guarded batched
  selects after the local transpiler returned no joined rows, and updated PLAN
  validation to accept item-key deadlines derived from material/plant scopes.
  Updated README and ANOMALIES coverage notes. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,921
  ABAP Unit methods. Target SAP DDIC and schedule semantics remain unverified.

- Added SQLite-backed coverage for the bulk scheduling-agreement receipt
  path and replaced its alias-qualified EKET/EKPO/EKKO/MARA join with guarded
  batched reads and keyed merges. The test verifies the blank supplying-plant
  rule, category and item filters, schedule cutoffs, quantity conversion, and
  source metadata. PLAN validation accepts the derived item-deadline keys.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,922 ABAP Unit methods. Target SAP field and schedule
  behavior remain unverified.

- Added SQLite-backed coverage for bulk STO projected receipts and replaced
  the alias-qualified EKET/EKPO/EKKO/MARA join with guarded batch reads and
  keyed merges. Tests exercise both issued-minus-received in-transit supply
  and scheduled-minus-issued supply, PO-unit conversion, per-request dates,
  document categories, supplying-plant and transport-document rules, and
  item deletion, statistical, account-assignment, returns, GR, and inspection
  stock filters. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,923 ABAP Unit methods. Target SAP
  transfer-order lifecycle and DDIC behavior remain unverified.

- Added SQLite-backed Open SQL coverage for the bulk confirmation-aware PO
  receipt repository. The join-based EKET/EKPO/EKKO/MARA and
  EKES/EKPO/EKKO/MARA reads now use guarded item, header, material, schedule,
  and confirmation batches merged by document/item keys. Coverage checks
  schedule and confirmation MRP reductions, KZDIS/deletion filters, eligible
  PO/header rows, unit conversion, and per-request deadlines. Updated PLAN
  validation, SQLite schema, README, and ANOMALIES. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,924 ABAP Unit methods. Target SAP confirmation semantics remain to be
  checked.

- Added SQLite-backed coverage for standard and stock-transfer purchase
  requisition projections. Replaced alias-qualified EBAN/MARA/MARM joins with
  separate guarded EBAN reads plus MARA/MARM batches merged by material and
  requisition unit. The merge applies open-quantity and STO supplying-plant
  comparisons, preserves the MARA-required and optional-MARM behavior, and
  combines the two EBAN results without the local FAE `APPENDING` reset. Tests
  cover item filters, unit conversion, missing material/unit rows, and
  request-specific deadlines. Updated PLAN validation and integration notes.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,925 ABAP Unit methods. Verify EBAN/MARM DDIC and PR
  planning semantics in the target release.

- Added SQLite-backed coverage for bulk production-order projected receipts.
  Replaced the alias-qualified AFPO/AFKO/AUFK/MARA join with guarded AFPO,
  AFKO, AUFK, and MARA reads merged by order/material keys; the merge retains
  each scope deadline and checks the ten-character AFPO-KDAUF blank value.
  Tests cover production and process order categories, receipt/item/release
  eligibility, base-unit quantities, storage location, batch, and per-request
  dates. Updated PLAN validation and target-system notes. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,926 ABAP Unit methods. Confirm target release fields and order
  status semantics in SAP.

- Added SQLite-backed coverage for bulk date-availability outgoing-STO
  deductions. Replaced the EKET/EKPO/EKKO join with guarded item, header, and
  schedule reads merged by document/item, carrying the maximum date for each
  material/source-plant scope and checking the receiving plant during the
  merge. Tests verify open scheduled-minus-issued quantities, UOM conversion,
  request cutoffs, document and item categories, special procurement, deleted
  items, and same-plant exclusion. Updated PLAN validation, README, and
  ANOMALIES. Full `npm test` passed: PLAN validation, 0 abaplint issues across
  247 files, transpilation, and all 1,927 ABAP Unit methods. Verify target
  transfer lifecycle and DDIC behavior in SAP.

- Added SQLite-backed coverage for bulk planned and fixed planned-order
  receipts. Replaced the PLAF/MARA/MARM join with guarded PLAF proposal, MARA
  base-unit, and MARM conversion batches merged by material/order unit. The
  merge applies fixed/unfixed, scenario, special-stock, and sales-order rules;
  the PLAF-PLSCN and PLAF-KDAUF blank checks avoid local fixed-width SQLite
  comparison differences. Tests cover both inclusion flags, storage location,
  alternative-unit conversion, missing MARM, and request-specific dates.
  Updated PLAN validation and integration notes. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,928 ABAP Unit methods. Confirm proposal eligibility and field behavior in
  the target SAP release.

- Added direct SQLite coverage for bulk date-availability standard PO,
  incoming STO, and production-order receipts. The method now reuses
  `GET_PROJECTED_RECEIPTS_BULK` for standard PO and incoming STO quantities;
  its production path batches AFPO items, AFKO dates, and AUFK release data by
  material/plant and unique order keys, then applies the maximum request date
  and production/process-order eligibility during the merge. The scalar date
  method now delegates to the same bulk implementation and forwards excluded
  reservation keys. Tests verify early and late horizons, both STO quantity
  components, UOM conversion, make-to-order exclusion, process-order inclusion,
  and scalar/bulk parity. Updated PLAN validation, README, and ANOMALIES. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,930 ABAP Unit methods. Confirm query and release-
  status behavior in the target SAP system.

- Added SQLite-backed coverage for scalar `GET_PROJECTED_RECEIPTS` and routed
  its single material/plant/date request through `GET_PROJECTED_RECEIPTS_BULK`.
  The scalar method maps the keyed receipt rows back to its result and retains
  source/date sorting, removing duplicate schedule/order joins. The test checks
  standard PO and process-order quantities, PO batch and location metadata,
  and make-to-order exclusion. Added a PLAN validator check to keep the scalar
  method on the shared bulk path. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods. Verify query behavior and source filters against the target SAP
  release.

- Added direct SQLite checks for scalar `GET_PO_CONFIRMED_RECEIPTS` and routed
  its one-request result through `GET_PO_CONFIRMED_RECEIPTS_BULK`. This removes
  duplicate EKET/EKES joins while retaining PO schedule and confirmation rows.
  Assertions cover result count, reduced quantities, and confirmation batch
  metadata. PLAN validation now prevents reintroducing scalar SELECTs. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods. Verify confirmation fields
  and behavior in the target SAP release.

- Changed the sales-order delivery bulk reader to keep VBUP status rows in a
  hashed table and VBEP schedule rows in document/item/date order. The item
  loop can now use keyed access instead of scanning all status and schedule
  rows for every VBAP item. Existing SQLite tests verify date ordering,
  delivered and confirmed quantities, status fallback, and empty input. Added
  a PLAN validation guard for both table keys. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,931
  ABAP Unit methods.

- Changed stock-transfer bulk reads to fetch MARC totals directly into a
  hashed table and aggregate MARD quantities once into hashed material/plant
  and material/plant/location totals. Location and batch detail rows now use
  sorted keys for their request scopes. SQLite tests cover repeated requests
  as well as existing ordering and quantity cases. Added a PLAN validation
  guard for these table keys. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Changed replenishment outline-agreement reads to de-duplicate request scopes,
  range over EORD rows by material/plant, and read EKKO/EKPO rows by hashed
  document and item keys. SQLite coverage checks duplicate P001 requests and
  separate P002 matching, while retaining plant and agreement values. Added a
  PLAN validation guard for the keys. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Changed replenishment candidate reads to keep EINA rows ordered by material
  and EINE rows ordered by info record/purchasing org/plant, so repeated
  candidate assembly uses keyed ranges. SQLite coverage adds a separate
  purchasing-org case alongside repeated dates and plant-specific records.
  Added a PLAN validation guard for both keys. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,931
  ABAP Unit methods.

- Changed quota-arrangement assembly to read matching EQUP items from a sorted
  quota-number range rather than scanning the full item buffer for every EQUK
  header. Existing SQLite coverage checks multiple headers and their item
  fields. Added a PLAN validation guard for the key. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,931 ABAP Unit methods.

- Changed source-context enrichment to build a hashed MARC policy lookup keyed
  by material/plant while keeping the returned context table in its original
  standard form. SQLite coverage now maps two policy scopes onto their source
  list rows. Added a PLAN guard for the lookup key. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,931 ABAP Unit methods.

- Changed production-order status assembly to keep active JEST rows sorted by
  object number, so each AUFK header reads its matching status range. Existing
  SQLite coverage checks active/inactive rows and system/user status texts.
  Added a PLAN guard for the key. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Changed production-order operation assembly to keep AFKO routing rows sorted
  by routing number, so AFVC operations use their matching routing range.
  Existing SQLite coverage checks operation ordering and suboperations across
  orders. Added a PLAN validation guard for the key. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,931 ABAP Unit methods.

- Changed project-stock WBS mappings to hashed lookups by external element and
  internal PSPNR. Key-scoped reads use the element index; stock and reservation
  reads driven by WBS lists build the reverse index once per call. Existing
  SQLite coverage exercises multiple WBS stock/reservation mappings. Added a
  PLAN guard for both directions. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Added secondary material/plant keys to the MARD, reservation, outgoing-STO,
  and production-receipt buffers used by bulk date availability. Request merges
  now iterate only each scope's indexed range while retaining request-date and
  exclusion checks. PLAN validation guards all four keys and merge loops. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Changed the bulk safety-stock MARC result buffer to a hashed material/plant
  key and used an explicit table-key read for each output row. Existing SQLite
  coverage checks duplicate requests and a missing plant result. PLAN
  validation now guards the hash and read key. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,931
  ABAP Unit methods.

- Added keyed reservation ranges to bulk open-stock reservation assembly and
  to the sales-order reservation-number and item checks. These loops now read
  the matching material/plant or reservation-number range rather than scanning
  every fetched RESB row per request or candidate. PLAN validation guards all
  three keys and loops. Full `npm test` passed: PLAN validation, 0 abaplint
  issues across 247 files, transpilation, and all 1,931 ABAP Unit methods.

- Added a sorted material/plant key to the bulk projected-receipt buffer.
  Each request now reads its matching scope range, then applies its cutoff date
  while retaining the existing row order and deterministic result sort. PLAN
  validation guards the key, loop, and sort.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Added an order-preserving scope index for confirmed-PO receipt batches. The
  sorted index stores material, plant, and each receipt's original row number;
  matching requests visit those positions in source order. Single-request calls
  keep the direct traversal. PLAN validation guards the index and both paths.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Reused the PO schedule, production-order, and available-quantity calculator
  objects across requests in bulk date availability. The calculators are
  stateless, so the method now creates each enabled calculator once per call.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Indexed multi-center cost-center reservation results by cost center and
  original row number. Bulk validation now gathers each center's reservations
  from its indexed positions while preserving the reader's row order; one-center
  calls retain direct traversal. Added a PLAN shape guard. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,931 ABAP Unit methods.

- Indexed BAPI sales-order delivery rows by document, item, requested date, and
  schedule line, so each BAPI item reads only its schedule range. Documented
  the row-order contract on the delivery repository interface and added a PLAN
  guard for the keyed mapping loop. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Hashed the BAPI sales-order headers by document and added a sorted
  document/row-position index for item batches. Mapping now visits each
  document's BAPI item rows in their original order; single-document calls use
  the direct filter. PLAN validation guards both lookups. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,931 ABAP Unit methods.


- Added direct SQLite-backed coverage for sales-order reservation aggregation
  from `RESB`. The test verifies grouping by document, item, schedule line,
  requirement date, material, and plant; nets withdrawals; filters fully
  withdrawn, deleted, final-issue, wrong-movement, and special-stock rows; and
  checks the final document/item ordering. The PLAN validator now guards the
  query filters, grouping, open-quantity calculation, and test method. Updated
  README integration limits and recorded the remaining target-SAP key and
  fallback checks in `ANOMALIES.md`.


- Added SQLite-backed tests for both `ZIF_SO_RESERVATION_FINDER` repository
  methods. The test runs the RESB candidate and full-document reads, exercises
  order-wide multi-item ownership versus exact-item ownership, and excludes
  mixed sales documents, wrong movement types, special stock, fully withdrawn,
  deleted, and final-issue candidates. It also checks empty input, optional
  item scoping, and deterministic result order. Extended PLAN validation to
  guard request filters, lifecycle fields, owner checks, and both test calls.
  README and `ANOMALIES.md` record the coverage and remaining target-SAP
  deletion checks.


- Added direct SQLite coverage for the plant-level `GET_STOCK_STATUS` aggregate.
  It checks unrestricted, quality, and blocked MARD totals; nets open RESB
  withdrawals and filters closed, deleted, special-stock, and other-material
  reservations; reads MARC safety stock; and verifies available quantities
  before and after safety-stock subtraction. The PLAN validator now guards the
  query fields and safety-stock calculation. Updated README coverage and the
  target-system caveat in `ANOMALIES.md`.


- Extended the SQLite stock-status test to execute `GET_STOCK_STATUS_BULK` as
  well as the scalar method. It verifies batched MARD/RESB/MARC aggregation,
  repeated material/plant requests, missing scopes, and caller-order output.
  Added PLAN guards for the hashed material/plant totals, lifecycle filters,
  and bulk merge loop. Updated README and `ANOMALIES.md` to describe the expanded
  coverage and target-system limits.


- Extended the direct stock-status repository test to execute
  `GET_UNRESTRICTED_STOCK` as well. It verifies normal MARD/RESB netting and the
  zero clamp when open reservations exceed unrestricted stock, without applying
  safety stock. Added a PLAN guard for the scalar query and clamp path, and
  updated README and `ANOMALIES.md` coverage notes.


- Added direct SQLite coverage for scalar `GET_STOCK_BY_LOCATION` and
  `GET_STOCK_STATUS_BY_LOCATION`. Tests verify gross category totals, exact
  location deductions, distribution of unscoped reservations in ascending
  location order, and exclusion of closed, deleted, and special-stock rows.
  The PLAN validator now guards both grouped queries and their RESB filters.
  Updated README and `ANOMALIES.md` with the direct coverage and SAP limits.


- Fixed `GET_STOCK_BY_LOCATION`: its grouped MARD and RESB selects returned
  `LGORT` into `CORRESPONDING FIELDS` structures named `storage_location`,
  dropping the location key and producing an empty allocation result. Both
  queries now alias the key correctly. The new direct SQL test reproduces the
  empty result without the aliases and verifies both location balances after
  exact and unscoped reservations.


- Extended the direct RESB Open SQL test to cover scalar
  `GET_OPEN_STOCK_RESERVATIONS` as well as the bulk method. It checks reservation
  number/item, requirement date, location, batch, net open quantity, and the
  empty result for a missing material. Added a PLAN guard for the scalar query's
  scope/lifecycle filters and output mapping; documented the expanded local
  coverage in README.


- Fixed scalar batch reservation mapping: `GET_STOCK_STATUS_BY_BATCH` selected
  `RESB-LGORT` and `RESB-CHARG` into differently named fields, dropping the
  exact reservation scope. Added scalar SQLite coverage for exact batch/location
  deduction, zero-balance status, closed/special-stock filters, and
  `GET_STOCK_BY_BATCH` positive-row ordering; strengthened the shared batch
  fixture so the bulk method covers the same cases. Added a PLAN guard and
  documented the defect and target-SAP limitation. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,935
  ABAP Unit methods.


- Added direct SQLite coverage for scalar `GET_SAFETY_STOCK`, verifying a
  present result, separate values for the same material at two plants, and the
  initial result for a missing material. Added a PLAN guard for the scalar MARC
  query and all three cases. Updated README and `ANOMALIES.md` to distinguish
  scalar and bulk safety-stock coverage. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,935
  ABAP Unit methods.


- Added direct SQLite coverage for scalar `GET_SAFETY_STOCK` with both an
  existing and missing MARC row, alongside the existing aggregate and bulk
  coverage. PLAN validation now guards the scalar query and its two result
  cases. Updated README and `ANOMALIES.md` to distinguish scalar and bulk
  coverage. Full `npm test` passed: PLAN validation, 0 abaplint issues across
  247 files, transpilation, and all 1,935 ABAP Unit methods.


- Strengthened production-order readiness overflow coverage. The regression
  now independently rejects overflowing requested, confirmed, and unconfirmed
  totals, and PLAN validation checks each packed-field conversion and boundary
  case. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247
  files, transpilation, and all 1,989 ABAP Unit methods.


- Added an end-to-end stock allocation test using the production factory and
  SQLite-backed MARD/RESB reads. It checks reservation netting and shared stock
  consumption across two demands. PLAN validation guards the factory-backed
  path; README and `ANOMALIES.md` record coverage and the SAP-runtime limit.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,990 ABAP Unit methods.


- Extended the factory integration to FEFO allocation with SQLite MCHB, MCHA,
  MCH1, and RESB rows. It verifies that an open batch reservation reduces the
  earliest-expiry lot, then checks the resulting two-lot split and expiry order.
  PLAN validation guards the scenario. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,991 ABAP Unit
  methods.


- Fixed cross-plant preview validation so a request cannot list its receiving
  plant as a source. The transfer-order service already rejected those pairs,
  which let previews suggest unusable stock splits. Added regression coverage
  for ordinary, dated, location-aware, FEFO, and batch allocator paths, plus a
  PLAN guard and README/`ANOMALIES.md` notes. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,992
  ABAP Unit methods.
