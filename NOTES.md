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
