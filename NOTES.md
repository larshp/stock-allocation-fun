# Development notes

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
- Resolved the earlier schedule-date note: schedule-line dates now pass into
  reservations; confirmed delivery dates remain outside the read model.
- Latest verification: `npm.cmd test` passed; abaplint reported zero issues
  and the transpiler ran all 239 ABAP Unit test methods.

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
