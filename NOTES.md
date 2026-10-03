# Development notes

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
