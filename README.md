# Stock Allocation Fun

An ABAP stock allocation solution designed for integration with an existing SAP
system. Development is incremental; SAP dependencies used by local tooling live
under `stubs/`, while custom `Z*` objects live under `src/`.

## Current features

The stock service reads unrestricted-use quantity for a material and plant from
`MARD-LABST` (in the material's base unit), then subtracts remaining active
reservations in `RESB`. The database read is isolated in
`ZCL_MARD_STOCK_REPOSITORY` and can be replaced through
`ZIF_STOCK_REPOSITORY` in tests or other integrations. The service can preview
one request or a batch of demand lines, returning each allocated amount and
shortfall. Location-aware allocations by default split demand across available
storage locations in ascending location-code order; sales-order callers may
apply an explicit location restriction per item or schedule line. Batch lines
use the input order as priority; each summary reports the remaining balance
before its line is allocated. Each material/plant balance is read once and
consumed across the matching lines. Negative requests raise
`ZCX_INVALID_STOCK_REQUEST`; negative available stock is treated as zero.
Previews do not persist allocations or write stock.

`ZCL_STOCK_SERVICE->ALLOCATE_REQUEST_IN_UNIT` accepts one demand in a
material-specific alternative unit. It reads the base unit from `MARA-MEINS`
and the numerator/denominator from `MARM`, converts the request to base units,
then returns both the original request and the base-unit allocation details.
SAP manages stock in a base unit and converts quantities entered in alternative
units using the material master ([SAP units of measure](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91b21005dded4984bcccf4a69ae1300c/a07cbd534f22b44ce10000000a174cb4.html)).
Unknown units and missing or nonpositive ratios raise
`ZCX_INVALID_STOCK_REQUEST` before stock is read.
`ALLOCATE_DEMANDS_IN_UNITS` accepts a list of demands in material-specific
units, converts them to base units, and allocates them together in input order.
Stock is read once per material/plant and shared across those demands; each
result retains the source quantity/unit and reports its base-unit allocation.
Repeated material/unit ratios are read once per allocation call.
`ALLOCATE_ACROSS_PLANTS` accepts base-unit demands and a caller-ordered source
plant list for each request. It reports availability, allocation, and shortfall
for the target plant, plus the amount assigned to each source plant and source
storage location. Locations are consumed in ascending `LGORT` order within
each source plant. Demand order consumes shared source-plant balances; each
material/source-plant stock balance is read once. The optional
`iv_protect_safety_stock` flag subtracts static source-plant safety stock before
allocation. This is an allocation preview only; it does not reserve stock or
post an interplant transfer.
`ALLOCATE_PLANTS_BY_DATE` adds required dates and uses the same caller-ordered
source plants. Earlier demands consume shared material/source-plant balances
before later dates. The integer `priority` defaults to zero; within the same
date, higher values allocate first and input order breaks ties. A later date
cannot outrank an earlier requirement. Each demand keeps its caller-ordered
source plants, and results return in input order with priority and source-plant
splits. It supports the dated PO, issued or unissued STO, and production receipt
projections plus source safety-stock protection. This is a planning estimate
and does not return storage-location splits or create a transfer because
projected receipts have no storage-location assignment.
`ALLOCATE_PLANTS_DATE_UNITS` accepts the same dated cross-plant requests in
material-specific units. It converts demand to base units before stock reads,
preserves date and same-date caller priority plus each request's source-plant
order, and returns both unit views for demand and source-plant splits. Optional
dated PO, issued or
unissued STO, and production receipts and safety-stock protection follow the
base-unit method.
`ALLOCATE_PLANTS_DATE_ATP` accepts those unit-aware dated requests and adds SAP
ATP checks for positive local source-plant allocations. It groups quantities by
source plant and required date, checks the cumulative base-unit quantity through
each date, and returns each source split's allocated quantity and cumulative
ATP result separately from the local estimate. Each check also reports
`confirmed_base_quantity` and `unconfirmed_base_quantity`, summed from the
returned confirmation lines dated on or before the group's required date and
capped at the cumulative quantity checked. Later or undated lines remain in the
raw result but do not count as confirmed for that date. These convenience values
are zero for ATP checks marked not relevant. The checks do not change local
allocations or resolve local shortfalls.
`ALLOCATE_PLANTS_IN_UNITS` accepts material-specific demand units and returns
the demand summary plus plant and location splits in both the source unit and
base unit. It caches and validates material/unit ratios before reading stock.
Base-unit quantities remain canonical when a converted split rounds to the
quantity field's precision.
`ALLOCATE_PLANTS_BY_BATCH` keeps the caller-selected batch fixed while
allocating across the ordered source plants. It returns plant and source
location splits with batch and expiration details, and never substitutes stock
from another batch. It can also protect each source plant's static safety
stock.
`ALLOCATE_PLANTS_BATCH_IN_UNITS` accepts the same exact-batch demand in a
material-specific alternative unit. It validates and caches conversion ratios
before reading stock and returns demand, plant, and location splits in both
units; base-unit quantities remain canonical when converted amounts round.
`ALLOCATE_PLANTS_BY_EXPIRY` applies FEFO across caller-ordered source plants.
The source-plant order takes priority between plants, and eligible batches are
then consumed by earliest expiration date within each plant, with batch and
location as tie breakers. It accepts an as-of date and minimum remaining shelf
life, returns source plant and batch/location splits, and can protect static
safety stock at each source plant. Undated batches are excluded when the
minimum shelf life is greater than zero. This is a preview based on local stock
estimates and does not run SAP batch determination or create a transfer.
`ALLOCATE_PLANTS_FEFO_BY_DATE` combines that cross-plant FEFO split with dated
demand priority. Earlier required dates consume shared batches first. Within
the same date, higher integer `priority` values consume shared batches first;
the default zero keeps input order, which also breaks equal-priority ties.
Results still return in input order with priorities on demand and batch splits.
Each batch must meet the requested minimum shelf life as of that demand's
required date.
Optional safety-stock protection withholds the buffer from latest-expiring
batches eligible for the earliest compatible demand. Undated batches qualify
only when `iv_min_days = 0` and sort after dated batches. The method considers
current batch stock only; it does not add projected receipts or replace SAP's
configured batch determination.
All dated cross-plant FEFO variants accept an optional shared
`it_allowed_storage_locations` allowlist. When supplied, stock from every other
storage location is excluded for all requests and source plants; an empty list
keeps the unrestricted location behavior.
For request-specific routing, `it_source_locations` maps each request and source
plant to its permitted storage locations. Every request/source-plant pair needs
at least one mapping when this table is supplied. If both location filters are
present, the selected stock must satisfy both.
`ALLOCATE_PLANTS_FEFO_DATE_UOM` accepts these dated demands in a material unit
such as BOX, converts once to the canonical base unit, and returns dated demand,
source-plant, and batch splits in both units. Conversion ratios are validated
before stock is read; converted quantities follow the same rounding rules as
other unit-aware allocations.
`ALLOCATE_PLANTS_FEFO_DATE_ATP` adds SAP ATP checks to that local estimate. It
checks positive allocations cumulatively by material, source plant, base unit,
and required date, and returns the ATP confirmations separately from the FEFO
allocation. Each check also reports `confirmed_base_quantity` and
`unconfirmed_base_quantity`, derived by totaling the returned confirmation
lines dated on or before the required date and limiting the total to the
cumulative quantity checked. Later or undated lines stay in the raw response
but do not count toward that date. These direct fields are zero when SAP marks a
check as not relevant. ATP does not reserve stock or change the local batch
selection.
`ALLOCATE_PLANTS_FEFO_IN_UNITS` accepts the same cross-plant FEFO demand in a
material-specific unit. It validates and caches conversion ratios before stock
reads, and returns demand, plant, and batch/location splits in both requested
and base units. Base-unit quantities remain canonical when converted split
amounts round.
`ALLOCATE_BY_LOCATION_IN_UNITS` accepts demands in material-specific units and
shares storage-location balances across input rows. It preserves the existing
preferred-location and fallback behavior, returns base-unit summaries, and
includes each location split in both base and source units.

`ZCL_STOCK_SERVICE->GET_STOCK_STATUS` reports plant totals for unrestricted
(`MARD-LABST`), quality-inspection (`MARD-INSME`), and blocked (`MARD-SPEME`)
stock, aggregated across storage locations. It also reports active unrestricted
reservations net of withdrawn quantity and `available_unrestricted_qty`, which
clamps unrestricted stock minus those reservations at zero. The report also
returns static plant safety stock from `MARC-EISBE` and
`available_after_safety_qty`, which subtracts that buffer from available
unrestricted stock and clamps the result at zero. This estimate does not include
every SAP planning element; quality-inspection and blocked stock remain separate
from allocation. SAP's standard
withdrawal rules exclude these two stock types, though system Customizing can
change their availability ([SAP stock types](https://help.sap.com/doc/a6a8c7536e8e2a4be10000000a174cb4/700_SFIN3E%20006/en-US/299bc7536e8e2a4be10000000a174cb4.html)).
`GET_STOCK_STATUS_IN_UNIT` returns the same stock categories, reservations,
available quantity, and safety-stock values in a requested material unit. The
result includes both the requested unit and the material base unit; conversion
uses the material's `MARA`/`MARM` ratio.
`ALLOCATE_REQUEST_BY_DATE` estimates a single material/plant allocation for a
required date. It subtracts active unrestricted reservations due on or before
that date, including reservations without a requirement date, and returns the
available quantity, allocation, and shortfall. Optional static safety-stock
protection works like the other plant allocation methods. Set
`iv_include_po_receipts = abap_true` to add remaining standard stock PO schedule
quantities due by that date, converted from the PO unit to the base unit. This
excludes PO items marked for quality-inspection or blocked stock. The actual
goods receipt can still use a different stock type, so treat this as a local
projection rather than SAP ATP or a historical stock reconstruction.
Set `iv_include_sto_in_transit = abap_true` to also include stock-transfer
schedule quantities already issued but not yet received, dated by the schedule
delivery date. Planned but unissued transfers are excluded by default. This
estimate starts from `MARD-LABST` and does not add SAP's separate in-transit
stock balance.
Set `iv_include_unissued_sto = abap_true` to project the scheduled STO
quantity that has not yet been issued (`EKET-MENGE - EKET-WAMNG`) by its
schedule delivery date, converted to the material base unit. It skips items
marked completely delivered. This option is off by default and can be combined
with the in-transit option to include both unissued and issued-but-unreceived
quantities. SAP exposes the schedule, issued, and received quantities on STO
schedule lines ([STO schedule-line quantities](https://help.sap.com/docs/PRODUCT_ID/368810f3ef2842fab17899c6ffd4e0c8/662f8e536beee647e10000000a441470.html)).
Treat planned transfers as a local estimate; they may not be issued or received
on schedule.
Set `iv_subtract_unissued_sto = abap_true` on dated allocations to reduce the
supplying plant's available quantity by open outgoing STO schedule quantities
that have not yet been issued and are due by the requested date. The estimate
uses `EKKO-RESWK` for the issuing plant and subtracts `EKET-MENGE -
EKET-WAMNG`, converted to the material base unit. This option is off by
default; it accounts for planned outbound transfers without changing the
physical-stock read. SAP identifies `RESWK` as the supplying plant in an STO
([EKKO field definition](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/6b120435270a45c8b81b203e74c62aae/a1cfb17cbdfa48418b665ae94c15dc79.html)).
Set `iv_include_prod_receipts = abap_true` to add open receipts from released
production orders whose basic finish date is on or before the requested date.
The estimate excludes make-to-order and completed order items; production output
may still be delayed or posted to a different stock type.
Set `iv_include_planned_receipts = abap_true` to include unfixed planned orders
whose basic start and finish dates fall between today and the requested date.
Set `iv_include_fixed_planned = abap_true` to include fixed planned orders in
that same date range. The two flags can be enabled together to include both
groups.
The projection converts `PLAF-GSMNG` from the planned-order unit to the material
base unit and identifies each row as `PLANNED_ORDER`, keyed by the planned order
number; fixed rows use `FIXED_PLAN_ORDER`. Both flags default to false. The
projection excludes planning-scenario orders, special stock, and orders assigned
to a sales document. Planned orders can be changed or deleted before conversion,
so this is indicative supply rather than a firm receipt; these flags do not
affect SAP ATP. SAP documents the planned-order
selection fields and conversion lifecycle ([selection criteria](https://help.sap.com/docs/SCMCSCPP/b654ceec39734aca96c6d395cdc7c69f/f39d21900a69431c9a71f12ea897ccc4.html), [planned-order conversion](https://help.sap.com/docs/PRODUCT_ID/af9ef57f504840d2b81be8667206d485/c498b6535fe6b74ce10000000a44147b.html?locale=en-US&state=PRODUCTION&version=latest)).
`GET_PROJECTED_RECEIPTS` exposes those same open PO, issued or unissued STO,
released production, and planned-order quantities as dated base-unit rows with
source-document identity and item/schedule-line fields where they apply. Each
source group is opt-in with its own receipt flag; `source_type` is `PO`,
`STO_IN_TRANSIT`, `STO_UNISSUED`, `PRODUCTION`, `PLANNED_ORDER`,
`FIXED_PLAN_ORDER`, or `SCHED_AGREEMENT`. Production rows have no schedule-line
number, and planned-order rows have no item or schedule-line number. Convert its
result with `CORRESPONDING #( )` to
`ZCL_PROD_COMP_SERVICE=>TY_PROJECTED_RECEIPTS` and pass it to
`SUGGEST_COMP_REPLENISHMENT` for date-aware netting. This shares the stock
repository's documented filters and remains a projection; callers should
review supplier, transfer, production, planned-order, and receipt-status
assumptions before acting on it. `SUGGEST_COMP_REPL_FROM_STOCK` combines those calls: it
loads the selected receipt types once per material/plant through the latest
shortage date, then nets eligible receipts by required date.
`ALLOCATE_DEMANDS_BY_DATE` handles a list of dated requests with unique request
IDs. It allocates earlier requirements first, shares each material/plant
balance across dates, and uses input order for same-date requests by default.
The integer `priority` defaults to zero; a higher value allocates that request
before lower-priority requests with the same material, plant, and required date.
Earlier required dates always take precedence; input order breaks equal-priority
ties. Each result echoes the request priority while results remain in input
order.
Identical material/plant/date estimates are read once, and optional static
safety-stock protection is cached per material/plant. The result is returned in
input order; each row's available quantity reflects stock remaining after
earlier requests for that material/plant. The same opt-in receipt flags apply
to each dated stock estimate, including unfixed and fixed planned orders and
scheduling agreements when their respective receipt flags are enabled.
`ALLOCATE_DATE_DEMANDS_IN_UNITS` accepts the same dated request list in
material-specific units. It validates and caches unit ratios before stock
reads, converts demands to base units, and returns each dated allocation with
both base-unit quantities and rounded source-unit quantities. It uses the same
date and caller-priority order, safety-stock protection, and optional PO,
issued or unissued STO,
production, planned-order, and scheduling-agreement receipt projections as
`ALLOCATE_DEMANDS_BY_DATE`.
`ALLOCATE_DATE_DEMANDS_ATP` also checks those dated requests with SAP ATP. It
converts them to base units for local allocation and sends one cumulative ATP
check per material/plant/base-unit/required-date group. Requests sharing a date
share that result, so request priority changes local allocation order only;
returned rows stay in input order and include both the local
estimate and cumulative base-unit quantity sent to SAP. They also include
`confirmed_base_quantity` and `unconfirmed_base_quantity`, summed from the ATP
confirmation lines dated on or before the required date and capped at the
cumulative request; later or undated lines remain visible but do not count as
confirmed for that date. The convenience values are zero when SAP marks the
check as not relevant.
`ALLOCATE_REQUEST_DATE_ATP` returns that local estimate together with a
`BAPI_MATERIAL_AVAILABILITY` result for the supplied material, plant, unit,
checking rule, date, and quantity. The SAP result includes plant-level
available quantity, every dated confirmation line, the replenishment lead-time
end date when configured, and the dialog status, so callers can review
configured ATP alongside the local allocation result. The legacy scalar
confirmation date and quantity mirror the first line. SAP returns the lead-time
end date only when replenishment lead time is active for the check. The local
estimate accepts the optional PO, issued or unissued STO, and production receipt
flags. The result also includes confirmed and unconfirmed base-unit quantities
summed from confirmation lines dated on or before the requested date; later or
undated lines remain in the raw result but do not count as confirmed by that
date. Returned quantities in an alternative request unit are converted through
the material's unit ratio.
The SAP check retains the supplied unit and quantity; the local estimate
converts the request to the material base unit before reading stock.
For sales orders, `preview_order` can set `iv_check_atp = abap_true` and provide
`iv_atp_check_rule`; the result contains one plant-level ATP check for each
positive open schedule line in `atp_checks`. The SAP request uses the cumulative
open quantity for the same material, plant, and base unit through that line's
required date. Lines sharing a date receive the same cumulative quantity.
Each result also reports the line quantity and cumulative quantity separately.
ATP checks include `confirmed_base_quantity` and
`unconfirmed_base_quantity`, summed from confirmation lines and capped at the
cumulative request. Only lines dated on or before the required date count;
later or undated lines remain in the raw result. The raw result remains
available for checking status and individual confirmation dates.
These checks do not replace local allocation splits or change the local preview
success flag, so callers should inspect the ATP statuses separately. Open
item-level fallback rows without a requested date are rejected in this mode.
`ZCL_STOCK_SERVICE->GET_ATP_CONFIRMATION_SPLIT` exposes the same bounded
calculation to other services using raw ATP results; supply the cumulative base
quantity and a positive numerator/denominator when the response uses an
alternative unit. Date-scoped allocation and reservation callers also pass the
required date: only confirmation lines dated on or before it count toward the
confirmed quantity. Later or undated lines remain visible in the raw ATP result
but do not satisfy that date's demand. Callers that omit the optional date
continue to total all returned lines. Invalid ratios raise
`ZCX_INVALID_STOCK_REQUEST`.
`GET_STOCK_STATUS_BY_LOCATION` returns the same stock-category breakdown for
each storage location, along with available unrestricted quantity after active
reservations. Plant-level reservations are distributed across locations in
ascending location-code order, matching location-aware allocation.
`GET_STOCK_STATUS_BY_BATCH` reports each batch's storage location and expiration
date, unrestricted quantity from `MCHB-CLABS`, and quantity available after the
reservation estimate. It includes batches with zero available quantity so
fully reserved or depleted balances remain visible. The availability uses the
same deterministic assignment for reservations missing a batch or location as
batch allocation. `GET_FEFO_BATCH_STATUS` applies the same as-of date and
minimum-days eligibility rule as FEFO allocation, returns only eligible batch
rows, and orders dated batches earliest first with undated batches last when
the minimum is zero. Eligible rows with no available stock remain visible.
`GET_STOCK_BY_LOCATION_IN_UNIT` and `GET_STOCK_BY_BATCH_IN_UNIT` return those
location and batch stock quantities in a requested material unit while
preserving their location, batch, and expiration details. The result rows
include both the requested unit and material base unit. For FEFO-filtered rows,
`GET_FEFO_BATCH_STATUS_IN_UNIT` keeps the existing eligibility and ordering
rules and converts the eligible batch quantities. Unknown units are rejected
before the stock repository is read.

Batch-aware previews read unrestricted batch quantities from `MCHB-CLABS` and
subtract open `RESB` quantities for the matching batch and location.
`ZCL_STOCK_SERVICE->ALLOCATE_BY_BATCH` requires the caller to specify a batch
for each demand and never fills a request from another batch. An optional
storage location narrows the allocation as a hard restriction. Set
`fallback_to_other_locations = abap_true` to prefer that location first, then
use remaining stock for the same batch from other locations in ascending code
order. Batch stock is tracked separately by storage location ([SAP working
with batches](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/d664bd534f22b44ce10000000a174cb4.html)).
Results include remaining availability, allocated quantity, shortfall, and
location-level batch splits.
`ALLOCATE_BY_BATCH_IN_UNITS` accepts multiple requests in material-specific
units while keeping each requested batch fixed. It shares that batch's stock
across demands in input order and supports the same preferred-location fallback
as the base-unit method. Results include base-unit summaries and location/batch
splits together with converted source-unit quantities; they do not substitute
stock from a different batch.
`ZCL_STOCK_SERVICE->ALLOCATE_BY_EXPIRY` provides an explicit FEFO preview that
chooses the earliest-expiring eligible batches first. It reads batch expiration
dates, excludes batches expired before the requested as-of date, places batches
without an expiration date last, and can restrict each demand to a storage
location. With fallback enabled, it uses that location first and then considers
other locations in expiration-date order. This is a simple VFDAT ordering;
SAP's configurable batch determination and search strategies are not reproduced
([batch stock](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/d664bd534f22b44ce10000000a174cb4.html),
[batch search strategies](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/4eb099dbc8a6435c9b36a854a7e05522/16feb753128eb44ce10000000a174cb4.html),
[ascending shelf-life expiration sort](https://help.sap.com/docs/SAP_ERP_SPV/96bf9ad642cf4b26a29595e3d573fb8c/fa60bd534f22b44ce10000000a174cb4.html)).
`ALLOCATE_BY_EXPIRY_IN_UNITS` accepts multiple FEFO demands in material-specific
units, validates and caches every material/unit ratio before reading stock, and
allocates shared batch stock in demand order. Results include base-unit
allocation summaries and batch splits alongside converted source-unit
quantities. Base-unit split quantities remain the canonical values when
conversion to a source unit rounds to `MARD-LABST` precision.

Confirmed stock changes go through `ZCL_GOODS_MOVEMENT_SERVICE`, which calls
`BAPI_GOODSMVT_CREATE` through an injectable adapter. It validates common item
fields and cost center or order assignments for movement types 201/202 and
261/262; sales-order issues (231/232) require the sales order and item. One-step
plant transfers (301/302) require a receiving plant and storage location;
two-step plant transfers use separate 303 removal and 305 putaway postings.
`TRANSFER_PLANT_ALLOCATION` converts the base-unit location splits from
`ALLOCATE_ACROSS_PLANTS` into a single 301 goods movement. Supply a receiving
storage location by request ID and each material's base unit and ISO unit code.
It requires complete allocation by default; set
`iv_require_full_allocation = abap_false` to post only the allocated portion.
`TRANSFER_PLANT_BATCH_ALLOC` and `TRANSFER_PLANT_FEFO_ALLOC` accept the
corresponding batch-aware cross-plant previews and carry each selected batch to
its own movement item. `TRANSFER_PLANT_UNITS_ALLOC` and
`TRANSFER_PLANT_BATCH_UNITS` accept ordinary and exact-batch unit-aware
allocation results directly and post their canonical base-unit split quantities,
checking the result's base unit against the supplied material unit mapping.
`TRANSFER_PLANT_FEFO_UNITS` does the same for unit-aware FEFO results while
preserving each selected batch in its own movement item.
`TRANSFER_PLANT_TWO_STEP` accepts cross-plant allocation results with source
location splits and posts 303 removals followed by one 305 putaway item per
request. It returns both posting results and sets `is_in_transit` when removal
commits but putaway fails. Supply a destination storage location per request;
complete allocation is required by default, and test runs simulate both steps.
The result includes the exact `putaway_items` payload. Pass a pending result to
`RETRY_TRANSFER_PUTAWAY` to post only those 305 or 315 items after a failure;
this avoids repeating the committed removal. A retry simulation or failed retry
keeps the result in transit, and a successful committed retry clears that state.
If the transfer should return to its source instead, pass the pending result to
`CANCEL_TRANSFER_IN_TRANSIT` with an optional posting date. It cancels the
removal document and marks the transfer cancelled only after the reversal
commits.
`TRANSFER_PLANT_2STEP_UNITS` accepts unit-aware cross-plant results and checks
the summary and source split base units against each material mapping before
posting the same 303/305 flow.
`TRANSFER_PLANT_BATCH_TWO_STEP` accepts exact-batch cross-plant allocations,
requires each source split to match the request batch, and preserves that batch
on the 303 removal and 305 putaway items.
`TRANSFER_PLANT_BATCH_2STEP_UOM` accepts unit-aware exact-batch allocations,
checks summary and source split base units against the supplied material unit
mapping, and posts canonical base-unit quantities while retaining the batch.
`TRANSFER_PLANT_FEFO_TWO_STEP` accepts cross-plant FEFO results, posts 303
removals in preview order, and posts one 305 item per request and selected
batch, combining same-batch source splits at the destination.
`TRANSFER_PLANT_FEFO_2STEP_UOM` checks the unit-aware FEFO summary and each
batch split against the material base-unit mapping, then posts canonical
base-unit quantities through the same grouped 303/305 flow.
`TRANSFER_FEFO_DATE_UOM` accepts a dated unit-aware FEFO result for a 301
cross-plant transfer. `TRANSFER_FEFO_DATE_UOM_2STEP` posts the same selected
batch splits through the 303/305 in-transit flow. Both validate the canonical
base unit against the material mapping; partial allocation must be enabled
explicitly when the dated result has a shortfall.
`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_ALLOCATION` creates an intra-company
stock transport order from a dated, unit-aware cross-plant allocation result.
Each call creates one `UB` purchase order for one supplying/receiving plant
pair; each matching allocation becomes a `U` item with its source-unit
quantity and requested date on one schedule line. The target storage location
is optional. Short target demand is rejected by default; set
`iv_allow_partial = abap_true` to order only the allocated quantities. Set
`iv_test_run = abap_true` to call `BAPI_PO_CREATE1` in test mode without
committing. This creates the order proposal only; it does not post goods issue
or receipt. SAP documents `UB` and item category `U` for a stock transport
order without delivery, with subsequent 351/101 goods movements
([STO without delivery](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/5213b953495bb44ce10000000a174cb4.html)).
The adapter maps the request through `BAPI_PO_CREATE1`; its `TESTRUN` flag
suppresses database updates and successful writes use the BAPI transaction
commit ([BAPI_PO_CREATE1](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167600.html),
[BAPI transaction commit](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167428.html)).
`CREATE_FROM_SOURCE_PLANTS` handles an allocation for one receiving plant
across multiple supplying plants. It prepares one `UB` order per supplying
plant in allocation priority order, validates every order request before the
first BAPI call, and returns the result and submitted items for each order.
Each order commits independently; the service continues with later suppliers
after a BAPI failure, so inspect both the aggregate success flag and each
source-plant result for partial completion. Test-run mode simulates every
prepared order without committing. Set `iv_atomic = abap_true` to defer the
commit until all supplier orders have been created successfully. A create or
commit failure rolls back the pending group and stops further supplier calls;
successful results are marked committed only after the shared commit succeeds.
`CREATE_FROM_ATP_SOURCE_PLANTS` accepts the wrapper returned by
`ALLOCATE_PLANTS_DATE_ATP` and creates orders only when each positive source
split for the selected receiving plant has one matching, check-relevant ATP
result whose full cumulative quantity is confirmed by that date. Missing,
misaligned, or short checks fail before the first BAPI call. It then uses the
same per-supplier order behavior and supports the same opt-in `iv_atomic`
commit mode as `CREATE_FROM_SOURCE_PLANTS`.
The ATP result is a precheck, not a stock reservation; availability may change
before PO creation.
`CREATE_FOR_ATP_PLANT_PAIRS` accepts the same ATP wrapper for allocations that
span multiple receiving plants. It requires one matching, relevant, fully
confirmed date check for every positive source/target split before calling the
pair-order creator. Receiving locations are still supplied by target plant,
and `iv_atomic = abap_true` defers the shared commit until every pair order is
created.
`CREATE_FOR_ALL_PLANT_PAIRS` extends this to allocation results spanning
multiple receiving plants. It creates one order per positive source/target
plant pair and accepts a receiving-storage-location map keyed by receiving
plant; targets without a map entry leave the location blank for SAP defaulting.
It validates the full result and every location entry before writing, and
returns per-pair results. Orders commit independently by default. Set
`iv_atomic = abap_true` on this method, `CREATE_FOR_BATCH_PAIRS`, or
`CREATE_FOR_FEFO_PAIRS` to defer one shared commit until all pair orders are
created; a create or commit failure rolls back the pending group and stops
further pair calls.
Previews do not reserve stock, so availability can change before posting.
`CREATE_FROM_BATCH_ALLOCATION` accepts a unit-aware exact-batch allocation for
one supplying/receiving plant pair. It emits one PO item per request/material/
batch with the allocated source-unit quantity, selected batch, caller-supplied
delivery date, and optional receiving storage location. The batch allocator
does not select a delivery date, so the caller must provide one. Complete
allocation is required unless `iv_allow_partial` is enabled. The adapter maps
the batch through the `BAPIMEPOITEM` item and its corresponding `POITEMX`
selection flag. This still creates an STO proposal only; goods issue and
receipt remain separate operations.
`CREATE_FOR_BATCH_PAIRS` carries exact-batch allocations across multiple
source/receiving plant pairs. It prepares one `UB` order per positive pair,
accepts the same receiving-location map, and returns per-pair results. A shared
delivery date is required because the batch allocation has no PO schedule
date. Orders commit independently by default; `iv_atomic = abap_true` defers
the commit across every pair as described above. The S/4HANA Cloud STO OData V4 API does not support item
batch; that OData constraint does not define the separate `BAPI_PO_CREATE1`
behavior ([OData V4 constraints](https://help.sap.com/docs/SAP_S4HANA_CLOUD/bb9f1469daf04bd894ab2167f8132a1a/807b2c79e22c4ef7a4c30c928bb3344e.html)).
`CREATE_FOR_FEFO_PAIRS` accepts the dated, unit-aware cross-plant FEFO result
and creates one order per positive source/target pair. Each selected
batch/location split becomes a PO item with its batch, issuing storage
location, source-unit quantity, and FEFO required date. The caller can map a
receiving storage location per target plant. FEFO is a preview and does not
reserve stock; SAP also documents that STO availability checks do not check
batch stock when a batch is entered ([STO availability check](https://help.sap.com/docs/SAP_ERP_SPV/96bf9ad642cf4b26a29595e3d573fb8c/b160bd534f22b44ce10000000a174cb4.html)).
Orders commit independently by default; the opt-in `iv_atomic` mode defers the
commit across all source/target pairs.
`CREATE_FOR_ATP_FEFO_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_DATE_ATP` output and
checks each positive source/target/date total before creating any pair order.
The ATP check remains plant-level; it does not confirm a specific batch, and it
does not reserve stock. This entry point also supports the shared `iv_atomic`
commit mode.
`TRANSFER_LOCATION_ALLOCATION` accepts an `ALLOCATE_BY_STORAGE_LOCATION`
result and posts each source-location split as a 311 goods movement within the
same plant. Supply a receiving storage location by request ID and each material's
base unit and ISO code. Complete allocation is required by default; partial
transfer can be enabled explicitly. The destination must differ from each
source location.
`TRANSFER_LOCATION_BATCH_ALLOC` accepts `ALLOCATE_BY_BATCH` results and keeps
each exact batch on its source-location movement item. It rejects missing or
mixed batches within one request and uses the same complete-allocation and
destination rules as the non-batch transfer.
`TRANSFER_LOCATION_UNITS_ALLOC` accepts unit-aware location allocation results
and posts the canonical base-unit quantity for each source-location split.
Supply the matching material base-unit mapping and destination per request.
`TRANSFER_LOCATION_BATCH_UNITS` accepts `ALLOCATE_BY_BATCH_IN_UNITS` results,
preserves each batch on its source-location item, and posts canonical base-unit
split quantities. Each request must resolve to one consistent batch.
`TRANSFER_LOCATION_FEFO_ALLOC` accepts `ALLOCATE_BY_EXPIRY` results and posts
each selected batch/location split in the preview's order, allowing one request
to move multiple FEFO-selected batches.
`TRANSFER_LOCATION_FEFO_UNITS` accepts unit-aware FEFO results and posts each
split using its canonical base-unit quantity while preserving the selected
batches and their order.
Storage-location transfers (311/312) require a receiving storage location.
`TRANSFER_LOCATION_TWO_STEP` accepts storage-location allocation results and
posts 313 removals followed by one 315 putaway item per request, with the
request's split quantities combined. Its result carries both posting results
and sets `is_in_transit` if removal committed but putaway failed. Test runs
simulate both steps without committing.
The result also includes the exact `putaway_items` payload. Use
`RETRY_TRANSFER_PUTAWAY` with a pending result to post only those 315 items;
the retry leaves the committed 313 removal untouched. Simulations and failed
retries retain the in-transit state until a committed putaway succeeds.
`CANCEL_TRANSFER_IN_TRANSIT` can reverse the removal document instead; it
reports cancellation only after SAP accepts and commits the reversal.
`TRANSFER_LOCATION_BATCH_2STEP` accepts exact-batch allocation results,
preserves the selected batch on each 313 removal, and combines source-location
splits into one 315 putaway item per request. It rejects a request whose splits
contain more than one batch.
`TRANSFER_LOC_BATCH_2STEP_UOM` accepts unit-aware exact-batch results, checks
the summary and each source split against the material base-unit mapping, and
posts the canonical quantities through the same grouped 313/315 path.
`TRANSFER_LOCATION_2STEP_UNITS` accepts unit-aware storage-location allocation
results and uses each split's canonical base-unit quantity, after checking the
summary and split base units against the supplied material mapping.
`TRANSFER_LOCATION_FEFO_2STEP` accepts same-plant FEFO results, posts 313
removals in preview order, then posts one 315 item per request and batch,
combining same-batch source-location splits at the destination.
`TRANSFER_LOC_FEFO_2STEP_UOM` validates the unit-aware FEFO summary and each
batch split against material base-unit mappings, then posts canonical quantities
through the same grouped 313/315 path.
The service also posts purchase-order goods receipts with movement type 101 and
PO-referenced returns to vendor with movement type 122, both with movement
indicator `B` and purchase-order/item reference; and production-order receipts
with GM code 02, movement type 101, order reference, and indicator `F`. Material,
plant, and storage location may be inherited from the referenced order. It
requires each movement quantity to include both SAP's unit and its ISO code. It supports
BAPI test runs and commits or rolls back based on the BAPI result ([BAPI
movement codes and required receipt fields](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
`ISSUE_STOCK_TRANSPORT_ORDER` posts movement 351 against a stock transport
purchase-order item from the supplying plant and storage location. It accepts
an optional batch per item, uses BAPI movement code 04 with a blank movement
indicator, and supports test runs. SAP describes 351 as the issuing-plant
goods issue for an STO without delivery; the receiving plant carries the
quantity in transit until the 101 goods receipt is posted
([STO issue flow](https://help.sap.com/docs/SAP_ERP/b704a8db767040a08100adc846218964/0601b953495bb44ce10000000a174cb4.html),
[BAPI movement codes](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
`ISSUE_CREATED_STO` accepts one successfully committed STO result, maps its
submitted PO items to 351 issue items, and resolves each source unit's ISO code
from a caller-supplied mapping. This connects `CREATE_FOR_FEFO_PAIRS` results
to issuing without manually copying batch, item, quantity, plant, or source
storage location fields. Use it once per successful plant-pair result. The
goods issue commits separately from STO creation; an issue failure leaves the
STO committed. It also requires every item to include its source storage
location and rejects test-run or uncommitted STO results.
`ISSUE_CREATED_STO_PAIRS` consumes the per-pair results from a multi-pair STO
creation call. It prevalidates every successfully committed PO item payload
before the first goods movement, then issues each PO in its own 351 transaction.
Failed or uncommitted PO results are skipped and marked unsuccessful; a failed
351 for one pair does not stop later pairs. Each pair returns its STO result,
goods-issue result, whether issue was attempted, and whether stock is now in
transit. Test-run mode simulates the goods issues for already committed STOs
and does not set `is_in_transit`.
Orders commit independently by default. Set `iv_atomic = abap_true` to require
all input orders to be eligible, commit the 351 movements together, and mark
the pairs in transit only after the shared commit succeeds. A failed movement
or commit rolls back the staged group.
`RECEIVE_ISSUED_STO` handles one pair result; `RECEIVE_ISSUED_STO_PAIRS`
consumes the complete issue result. Both only prepare receipts for pairs marked
in transit after a successful committed 351 issue. They prevalidate all
eligible PO items before the first receipt, then post one 101
per PO. Failed receipts leave that pair in transit while later pairs continue;
test-run receipts also leave the status in transit and do not set `is_received`.
Receipts commit independently by default. Set `iv_atomic = abap_true` to
require every pair to be in transit, post the 101 movements in one LUW, and
clear transit only after a shared commit succeeds. A receipt or commit failure
rolls back the group and leaves every pair in transit.
`CANCEL_ISSUED_STO` and `CANCEL_ISSUED_STO_PAIRS` reverse the whole committed
351 material document for an eligible in-transit pair through
`BAPI_GOODSMVT_CANCEL`. They prevalidate all document/year keys, cancel each PO
in a separate transaction, and continue after a failed cancellation. A
successful reversal clears that pair's in-transit status. SAP selects the
reversal movement type and checks whether the document can be canceled; the
cancellation API has no test-run option ([SAP goods-movement BAPIs](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html), [STO movement types](https://help.sap.com/docs/IRPA_S4HANA/18862e3cddb74ce7ac751f49e568c1e0/a99a1bcb969f4939957469ea7d251e78.html)).
Pair cancellations commit independently by default. Set `iv_atomic =
abap_true` on `CANCEL_ISSUED_STO_PAIRS` to require every pair to be in transit,
stage all reversals in one LUW, and clear transit only after one shared commit.
A reversal or commit failure rolls the group back.
`CANCEL_RECEIVED_STO` handles one received pair, and
`CANCEL_RECEIVED_STO_PAIRS` processes the full receipt result. They reverse each
committed 101 document independently after validating every eligible
document/year key. A successful reversal clears `is_received` and restores
`is_in_transit`, so callers can then reverse the original 351 issue if needed.
Failures leave the receipt state unchanged while later documents continue.
The cancellation BAPI has no test-run option; SAP checks whether document
history, posting period, and current stock allow each reversal.
Receipt cancellations commit independently by default. Set `iv_atomic =
abap_true` on `CANCEL_RECEIVED_STO_PAIRS` to require every pair to be received,
stage all 102 reversals together, and restore in-transit status only after the
shared commit succeeds. A reversal or commit failure rolls the group back.
`CANCEL_STO_RECEIPT_CHAIN` and `CANCEL_STO_RECEIPT_CHAIN_PAIRS` reverse both
goods movements for received pairs. They validate every eligible 101 and 351
document key before writing, then reverse the receipt first and the issue only
after that reversal succeeds. `is_cancelled` reports the receipt reversal,
`is_issue_cancelled` reports the 351 reversal, and `is_fully_cancelled` is true
when both movements are reversed. A failed 101 stays received; a failed 351
leaves the reversed receipt in transit. This reverses the movements but does
not delete or close the STO purchase order.
`MARK_STO_FOR_DELETION` can separately set the deletion indicator on submitted
items from one successfully committed STO result, and
`MARK_STO_PAIRS_FOR_DELETION` can process a multi-pair result. Both reject
test-run or uncommitted orders, prevalidate eligible item identities before the
first change, commit each PO independently, and continue after an individual
failure by default. Set `iv_atomic = abap_true` on
`MARK_STO_PAIRS_FOR_DELETION` to require every input order to be eligible,
defer the commit across all pair changes, and roll back the group if a change
or commit fails. This is a logical item deletion indicator through
`BAPI_PO_CHANGE`, not a physical purchase-order deletion. SAP still checks
whether each item can
be marked for deletion based on its document history and system rules
([SAP BAPI_PO_CHANGE example](https://help.sap.com/docs/SUPPORT_CONTENT/home/3361892108.html?locale=ru-RU)).
`MARK_STO_DELIVERY_COMPLETE` and `MARK_STO_PAIRS_DELIV_COMPLETE` separately
set the delivery-completed indicator on submitted items from committed STO
results. Use this when the business has decided that no more goods receipt is
expected: SAP can treat even a partially received item as complete and set its
open PO quantity to zero. This only changes purchasing status; it does not post
or reverse stock movements. SAP's BAPI field is `NO_MORE_GR` and the BAPI's
item selection structure must also flag it; target systems can reject or fail
to apply the update under release-specific conditions, including split
valuation ([delivery-completed indicator](https://help.sap.com/docs/SAP_ERP/39615c43587c4405aba2de8ebf33cd66/35cee35751bfd812e10000000a4450e5.html),
[SAP BAPI_PO_CHANGE issue](https://userapps.support.sap.com/sap/support/knowledge/en/3731949)).
The pair method commits each order independently by default. Set
`iv_atomic = abap_true` to require every order to be eligible and defer the
commit until all pair changes succeed; a change or shared-commit failure rolls
back the group.
`RECEIVE_STOCK_TRANSPORT_ORDER` posts the matching movement 101 receipt against
the same STO and item, using movement indicator `B`. Material, receiving plant,
storage location, and batch can be supplied when required; otherwise SAP can
derive order data where the document and configuration allow it. The receipt
also supports BAPI test runs and the usual commit/rollback behavior.
It can cancel a complete material document or selected items by document number
and year; an optional posting date sets the reversal date. An empty item list
cancels the complete document. SAP's cancellation rules decide whether the
original document can be reversed.

`ZCL_STOCK_TRANSFER_SERVICE` reports plant-level stock in transfer from
`MARC-UMLMC` and storage-location transfer stock from `MARD-UMLME`. The caller
may request one storage location or leave it blank to aggregate across the
plant's storage locations. These quantities stay separate from allocatable
unrestricted stock ([SAP stock in transfer fields](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362168094.html)).
`GET_STOCK_IN_TRANSFER_IN_UNIT` returns both transfer quantities in a requested
material-specific unit and includes the requested and base units. It uses the
material's `MARA`/`MARM` conversion ratio and rejects an unknown unit before
reading transfer balances.
`GET_STOCK_IN_TRANSFER_BY_BATCH` reports nonzero storage-location transfer
quantities by batch and storage location from `MCHB-CUMLM`.
`GET_BATCH_TRANSFER_IN_UNIT` adds the requested-unit quantity while
retaining the canonical base-unit balance. These batch rows describe transfers
between storage locations; plant-to-plant transfer stock remains available only
as an aggregate plant quantity.

`ZCL_SALES_ORDER_SERVICE` reads sales order item details through
`BAPISDORDER_GETDETAILEDLIST` and creates orders through
`BAPI_SALESORDER_CREATEFROMDAT2`. It can also change specified items and
schedule lines through `BAPI_SALESORDER_CHANGE`. Create and change operations
support test runs and use the BAPI transaction commit or rollback APIs. Both
services depend on interfaces so their behavior can be tested without posting
to SAP. Order reads retain requested and delivered quantities in the sales
unit, calculate the undelivered open quantity, and provide requested and open
quantities in the material base unit using the sales item's conversion ratio.
An alternative-unit item with no valid ratio or material base unit makes the
read unsuccessful. Schedule-line reads also retain `VBEP-BMENG` confirmed
quantities and the undelivered confirmed amount in both sales and base units.
Pass `iv_use_confirmed_qty = abap_true` to `preview_order`, `reserve_order`, or
`preview_orders_by_date` to size demand from each schedule line's confirmed
quantity minus deliveries, capped at its ordered open quantity. The default
continues to use ordered open quantity. Confirmed-quantity mode requires
schedule-line confirmation data and returns an error before stock reads for an
open item without it.

`ZCL_SALES_ORDER_ALLOC_SERVICE` connects that open demand to the batch stock
preview and returns allocations keyed by sales document and item. By default,
sales-order items retain their input order and schedule lines use requested
date order within each item. Pass `iv_prioritize_by_date = abap_true` to
`preview_order` or `reserve_order` to prioritize dated open lines across the
whole order; undated item-level demand is placed last and ties retain input
order. `reserve_order` creates a
movement type 231 SAP reservation for each positive order schedule-line
allocation, including its requested date, storage location, and caller-selected
batch when supplied. It returns allocations keyed by order item and schedule
line, the source locations, selected batches, and reservation numbers. Both
preview and reserve results include `sales_unit_allocations` with requested,
available, allocated, and shortfall quantities in the order's sales unit and
the material base unit. The existing allocation and reservation quantities
remain in the base unit; sales-unit quantities are converted from the retained
`BAPISDIT-SALES_QTY1/SALES_QTY2` ratio and rounded to the quantity field's
precision. Schedule
lines are prioritized by requested date within each sales order item. The
reservation BAPI runs its ATP check and commits the reservations in one
transaction; an error rolls the transaction back. Partial allocations are
reserved and the shortfall remains in the result. Test runs call the reservation
BAPI in simulation mode and do not commit. Callers may require full allocation;
any preview shortfall then stops the operation before the reservation BAPI is
called. Before preview or reservation, the service subtracts open quantities
from active reservations for movement type 231 assigned to the same order item.
It matches the schedule line when available and otherwise uses the requirement
date. Any unmatched remainder is deducted across that item's open lines in allocation
order. Repeating a reservation call therefore only considers the unreserved
open quantity. By default, the service reserves partial quantities. Callers may
select one storage location per open schedule line, or an item-wide location
for all its open lines. A selected location is a hard restriction by default;
set `allow_fallback` to use it first and then try other locations in ascending
code order. Separate batch and location selection lists cannot be combined.
Callers can select a batch for each open schedule line, or provide one
item-wide choice to apply to all its open schedule lines. A batch selection
can include a preferred `storage_location`; set `allow_fallback = abap_true`
to use other locations for that same batch if the preferred location is short.
Preview and reservation use only the selected batch and pass it through to the
reservation BAPI. Item-wide and schedule-line choices cannot be mixed on one
item.

For either reservation method, set `iv_require_atp_confirmation = abap_true`
with `iv_check_atp = abap_true` and `iv_atp_check_rule` to require full
cumulative ATP confirmation. If any material/plant/unit/date group is short,
the result includes the ATP diagnostics and no reservation API calls are made.
The reservation BAPI still performs its own ATP check when reservations are
created. The flag accepts only `abap_true` and `abap_false`; an invalid value
raises `zcx_invalid_stock_request` before stock or order reads.

For same-date lines within one order, pass `it_item_priorities` with
`iv_prioritize_by_date = abap_true` to `preview_order` or `reserve_order`.
Entries key the priority by item and schedule line; higher integer values
allocate first among lines with the same requested date. Earlier dates still
take precedence, omitted priorities default to zero, and equal priorities keep
the order's input sequence. The preview echoes the applied value in each
`sales_unit_allocations` row and in its `atp_checks` when requested; reservations
are sent in the resulting order. ATP requests and confirmed quantities remain
grouped by material, plant, unit, and date; the echoed priority does not change
SAP's aggregate response.
Duplicate keys or keys that do not match an order item/schedule line are
rejected before stock allocation.

`preview_orders_by_date` previews open items from multiple sales documents
against shared material/plant stock. Pass unique, nonblank document numbers in
`it_sales_documents`. The service loads their active reservations in one bulk
repository read, subtracts them from each order, and requires a requested date
on every remaining open item.
Earlier dates receive stock first; items with the same date follow document
and item/schedule input order. The method only previews and does not create
reservations. Its `sales_unit_allocations` retain document, item, and schedule
keys plus requested, available, allocated, and shortfall quantities in both
sales and base units. Pass `iv_use_confirmed_qty = abap_true` to size each
line from confirmed open quantity. Optional dated stock inputs include PO
receipts, issued or unissued STO quantities, production and planned-order
receipts, and safety-stock protection. Pass `iv_check_atp = abap_true` with
`iv_atp_check_rule` to include SAP ATP responses in `atp_checks`; requests are
combined across the supplied orders by material, plant, and date, with demand
accumulated through each date. ATP responses are reported separately and do
not change the local allocation or its success flag. Each row also reports
confirmed and unconfirmed base quantities, shared by rows with the same date;
the split sums lines dated on or before that date and caps the confirmed amount
at the cumulative quantity checked. Later or undated lines stay in the raw ATP
result. `reserve_orders_by_date` carries these diagnostics through with its
reservation result.

To control same-date allocation across different documents, pass
`it_demand_priorities` to either multi-order method. Each entry keys a caller
priority by sales document, item, and schedule line; use a blank schedule line
for an item-level demand. Higher integer values receive stock first among
demands for the same material, plant, and date. Earlier dates still take
precedence; omitted priorities default to zero, and equal priorities preserve
input order. Results echo each applied priority in `sales_unit_allocations` and
`atp_checks`. Duplicate keys, entries for unselected orders, and keys that do
not match an order item/schedule line are rejected before allocation.
`reserve_orders_by_date` carries the same
ordering into the quantities sent for reservation. This caller priority only
controls the local allocation sequence; it is not written to the sales order,
and same-date ATP diagnostics remain cumulative across all orders.

`reserve_orders_by_date` creates reservations for the positive allocations from
the same shared dated preview and accepts the same receipt, confirmed-demand,
and safety-stock options. Each request ID retains its sales document,
item, and schedule-line key, with the required date carried separately; SAP
determines the storage location and batch because this aggregate dated
allocation does not select either. All created reservations commit in one
transaction, and any creation or commit error triggers rollback. Set
`iv_test_run = abap_true` to simulate the reservation calls. By default,
positive allocations are reserved and shortfalls remain in the result; set
`iv_require_full_allocation = abap_true` to reject any preview shortfall before
the reservation API is called. Reservation requests are submitted by material,
plant, and required date; higher priorities are sent first within a date, and
input order breaks equal-priority ties. Before commit, the service matches
every API response to one pending request and
checks its quantity, date, and any requested location or batch; mismatches roll
back the transaction. Set `iv_check_atp = abap_true` and provide
  `iv_atp_check_rule` to return cumulative ATP diagnostics in `atp_checks` with
  the reservation result. These diagnostics do not change the local allocation;
  the reservation API still runs its own ATP check for each reservation request.
  Set `iv_require_atp_confirmation = abap_true` with those options to stop before
  the reservation API if any cumulative date quantity lacks full confirmation.

Call `preview_order` or `reserve_order` with `iv_use_fefo_batches = abap_true`
to choose batches automatically by earliest expiration date. The as-of date
defaults to the current date and can be set with `iv_fefo_as_of_date`. FEFO can
be combined with location selections: by default the selected location is a
hard restriction; with `allow_fallback`, it is used first and other locations
are searched afterward in expiration-date order. FEFO cannot be combined with
explicit batch selections. The service does not run SAP's configured batch
search strategy ([reservation requirements](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/0ca1613d5bcb4fcda6e66a8c57fa8624.html?locale=en-US&state=PRODUCTION&version=2023.latest)).

FEFO calls can set `iv_min_days` on `ALLOCATE_BY_EXPIRY`, or `iv_fefo_min_days`
on `preview_order` / `reserve_order`, to require a minimum number of days from
the as-of date through batch expiration. A batch expiring exactly on the
minimum date remains eligible. The default is zero days; undated batches are
excluded when the minimum is positive. The order parameter requires
`iv_use_fefo_batches = abap_true`.

Pass `iv_protect_safety_stock = abap_true` to a stock allocation method or to
`preview_order` / `reserve_order` to keep the material/plant safety stock in
`MARC-EISBE` out of the allocatable quantity. The flag defaults to
`abap_false`. The buffer is distributed deterministically across storage
locations or batch balances before allocation; FEFO protects earlier-expiring
batches first. This uses the static plant-level `EISBE` value and does not
reproduce time-dependent buffers or the target system's configured ATP scope
([SAP safety stock in availability checking](https://help.sap.com/docs/PRODUCT_ID/32da8359c8ee4e8b8e8c5e15cacba5aa/741d645473c50d4ee10000000a423f68.html)).

`ZCL_SO_RESERVATION_SERVICE` releases one or more reservation documents by
number through `BAPI_RESERVATION_DELETE`. It rejects an empty list, blank
numbers, and duplicate numbers, then deletes the list in one transaction. The
service supports BAPI test runs and rolls back if a delete or commit fails.
Its sales-order method discovers open movement-231 reservations from `RESB`.
It only releases a document when every non-deleted item belongs to the
requested sales order and uses the same movement and stock scope. An order can
preview eligible reservation numbers without a BAPI call, optionally scoped to one
sales-order item. Item-scoped release requires every non-deleted document item
to match that item. An order with no matching documents returns success without
starting a BAPI transaction.
`DELETE_ORDERS_RESERVATIONS` accepts a unique list of sales documents, returns
eligible reservation numbers grouped by order, and deletes the combined list in
one BAPI transaction. Empty matches are a successful no-op; blank or duplicate
sales document numbers are rejected before the finder runs. A reservation number
mapped to multiple orders is rejected before deletion.
`PREVIEW_ORDERS_RELEASE` returns the same grouped candidates without calling the
delete BAPI.
`PREVIEW_ORDER_ITEMS_RELEASE` and `DELETE_ITEMS_RESERVATIONS` accept unique,
nonblank sales-order/item pairs. They return candidates grouped by item; release
deletes the combined list in one transaction. A document is eligible only when
all non-deleted rows match that exact order item.

`ZCL_SO_RESERVATION_READ_SERVICE` reads reservation items through
`BAPI_RESERVATION_GETDETAIL1`, including their SAP item number, record type,
status flags, requirement and withdrawal quantities, material, plant,
storage location, batch, and units. Failed reads do not return partial item
data.

`ZCL_RESERVATION_ISSUE_SERVICE` posts a goods issue against selected
reservation items. It reads each reservation once, rejects duplicate or
unissueable items and quantities above the remaining requirement, then sends
the reservation number, item, record type, quantity, and unit through
`BAPI_GOODSMVT_CREATE` with goods movement code 03. SAP derives the movement
type and material from the reservation. An unplanned storage location or
batch can be supplied by the caller. All issue items post as one material
document and share the goods movement service's simulation and transaction
handling.

`ZCL_PROD_COMP_SERVICE->GET_OPEN_COMPONENTS` reads open component reservation
items for a production order from `RESB`. It returns the reservation number and
item, material, plant, location, batch, movement type, required date, unit,
required and withdrawn quantities, and the remaining open quantity.
`GET_OPEN_COMPONENTS_BULK` reads a unique list of production orders together
through one bulk repository call and returns components sorted by order and
reservation key. `ISSUE_COMPONENTS` accepts selected reservation keys and
quantities for one order; `ISSUE_COMPONENTS_BULK` accepts requests across
orders, validates each key against its originating order, and posts the selected
components together in one material document and transaction. Both methods
support test runs. Quantities use the component reservation unit. SAP generates component
reservations when production orders are created; movement type 261 is the
standard goods issue for order components
([withdrawing material components](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/c803b753128eb44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest)).
`RETURN_COMPONENTS` and `RETURN_COMPONENTS_BULK` post partial returns for
issued component reservations. They require a non-deleted `RESB` component
with movement type 261 and positive withdrawn quantity, then cap each request
at the amount still withdrawn in both the repository and reservation detail.
The service submits reservation-backed reversals with BAPI goods movement code
06 and `XSTOB`; SAP derives the reversal movement type (262 for 261) from the
reservation. Return quantities use the reservation base unit. An unplanned
storage location or batch can be supplied, and test runs do not commit. SAP's
BAPI movement guide describes reservation-linked reversals and the `XSTOB`
field ([goods movement BAPI guidance](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
`CANCEL_COMPONENT_ISSUE` reverses a committed issue by calling
`BAPI_GOODSMVT_CANCEL` with its material document and fiscal year. Pass item
numbers to reverse only selected document lines; omit them to cancel the whole
document. SAP posts the corresponding reversal (261 issues reverse as 262).
This cancels full document lines. The method has no test-run mode. Use the
material document returned by the component issue call and let SAP validate
whether it is still reversible
([261-to-262 reversal](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/cc86c401ad5c40e1a09a6b5e49672b8d.html),
[goods movement BAPI guidance](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
`PREVIEW_COMPONENTS_ATP` and `PREVIEW_COMPONENTS_ATP_BULK` check open
components against SAP ATP without posting a goods movement. They convert
reservation quantities to each material's base unit, then make one ATP request
per material, plant, base unit, and required-date group using the cumulative
open quantity through that date. Each returned component includes its own base
quantity, the cumulative quantity, the SAP result, confirmed and unconfirmed
quantities for the cumulative check, and a local dated stock estimate.
Components sharing a date share the group estimate and cumulative ATP values;
the local estimate allocates the date's total after earlier component dates.
`component_local_estimate` also allocates that date's local quantity to
individual component rows in production-order, reservation, and item order. It
reports each row's requested, available-before-row, allocated, and shortfall
base quantities, so partial local stock can be traced to a specific component.
The group-level ATP confirmation remains cumulative and repeats on each row.
For component previews it counts dated confirmations on or before each required
date; future or undated confirmation lines remain visible in `atp_result` but
do not count as confirmed by that component date.
`component_confirmed_quantity` and `component_unconfirmed_quantity` allocate
the increase in due-date confirmation between cumulative checks across the
components on that date, in production-order/reservation/item order. They give
a deterministic component view of the aggregate ATP result; SAP does not
confirm an individual production reservation through this grouped request.
The local estimate can include PO receipts, issued STO receipts, unissued STO
receipts, released production receipts, unfixed and fixed planned orders,
outgoing unissued STO demand, and static safety stock with
`iv_include_po_receipts`,
`iv_include_sto_in_transit`, `iv_include_unissued_sto`,
`iv_include_prod_receipts`, `iv_include_planned_receipts`,
`iv_include_fixed_planned`,
`iv_subtract_unissued_sto`, and `iv_protect_safety_stock`. These options affect
the local estimate only. The SAP request covers only the supplied orders and
does not add local batch or storage-location restrictions.
`PREVIEW_COMPONENTS_STOCK` and `PREVIEW_COMPONENTS_STOCK_BULK` return the same
local date-group and per-component estimates without requiring an ATP checking
rule or calling the availability API. In those results, ATP confirmation
quantities and the raw ATP result remain initial.
`SUMMARIZE_COMPONENT_READINESS` rolls preview rows up by production order. It
reports the open, locally covered, and locally short component counts, the
required-date range, the first local shortage date, and `is_locally_ready`.
This status uses the local component allocations only; review the ATP results
separately for SAP confirmation status. `SUMMARIZE_COMPONENT_SHORTAGES` groups
the same rows by material, plant, base unit, and required date. It reports
component and affected-order counts, the distinct `affected_production_orders`
list, and requested, allocated, and shortfall base quantities, omitting groups
with no local shortfall. When callers provide this list, its nonblank unique IDs
must match `affected_order_count`. `SUMMARIZE_ORDER_ATP`
summarizes the per-component ATP split by production order, material, plant,
and base unit. It reports fully, partially, and unconfirmed component counts,
requested/confirmed/unconfirmed base quantities, required-date range, first
unconfirmed date, and `is_split_fully_confirmed`. Quantities remain separated
by material and unit, and the status describes the deterministic component
split rather than an order-level result returned by SAP.
`SUGGEST_COMP_REPLENISHMENT` turns component shortage rows into base-unit
quantity suggestions. Caller policies override material master planning data.
For materials without an override, the service reads the base unit from `MARA`
and `MARC-DISLS`/`MRPPP`/`RDPRF`, lot quantities `BSTMI`/`BSTMA`/`MABST`/`BSTFE`/`BSTRF`,
procurement type `BESKZ`, special procurement key `SOBSL`, lead-time fields
`PLIFZ` and `WEBAZ`, plant calendar `T001W-FABKL`, and purchasing processing days
`T399D-BZTEK` in one bulk read. Lot-for-lot
(`EX`) suggestions apply minimum quantity, maximum lot
size, and PO rounding value; fixed lot (`FX`) suggestions use the fixed
quantity. Monthly (`MB`) and weekly (`WB`) lot sizing group supplied shortage
rows by material/plant/unit and calendar period. Planning-calendar (`PK`) lot
sizing uses `MARC-MRPPP` and overlapping periods read from `T439I`, keyed by
plant and calendar ID. Callers can pass resolved periods to bypass that lookup.
Projected receipts are netted against each shortage date before
each period total is lot-sized. A `PK` shortage without a matching period
remains a date-level suggestion. The result uses the first shortage
date and includes `planning_calendar_id`, `lot_size_period_start`,
`lot_size_period_end`, and `grouped_shortage_count` for resolved periods. `WB`
uses `iv_week_start_weekday` (Monday=1 through Sunday=7, default Monday). The
service does not generate or extend SAP planning-calendar periods and does not
evaluate the full MRP stock/requirements list. Shortage inputs and suggestions
can carry `affected_production_orders`; when every date row in a period group
has a complete identity list, the result unions the IDs and returns a distinct
`affected_order_count`. Legacy rows or mixed groups without complete identity
data keep additive counts and return an empty order list. SAP describes period
lot sizing as grouping requirements in an interval
and applying lot constraints to the period total ([SAP period lot-sizing
procedures](https://help.sap.com/docs/SAP_ERP_SPV/85d3fce10e264972a0155c8b46ecf93b/cb97b6535fe6b74ce10000000a174cb4.html),
[SAP planning calendars](https://help.sap.com/docs/SAP_ERP/85d3fce10e264972a0155c8b46ecf93b/f1f8c0534b22b64ce10000000a174cb4.html)).
For `EX`, `MB`, `WB`, and resolved `PK` periods, the result includes the aggregate
quantity, receipt count, and final receipt quantity after maximum-lot splitting.
For supported lot-sizing policies, a caller or material-master `MARC-RDPRF`
applies static threshold rounding from plant/profile `RDPR` rows to each receipt
after lot sizing. The result reports the profile and updates the aggregate,
receipt count, final receipt, and rounding surplus. A profile that rounds a
receipt above its configured maximum lot size raises
`zcx_invalid_stock_request`; keep maximum lot size compatible with the profile.
SAP documents lot sizing before rounding and threshold-based static profiles
([procurement quantity calculation](https://help.sap.com/docs/SAP_ERP_SPV/85d3fce10e264972a0155c8b46ecf93b/dca5bb53707db44ce10000000a174cb4.html),
[static rounding profiles](https://help.sap.com/docs/SAP_ERP/85d3fce10e0e1416d83c0fdfa4060189d/f597b6535fe6b74ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest)).
Other lot-sizing procedures or incompatible `EX`/`MB`/`WB`/`PK` settings return the
exact shortfall and mark
`policy_origin` as `UNSUPPORTED`. `HB` uses a positive maximum stock quantity
(`MARC-MABST` or a caller policy) as a shortage-triggered replenishment target:
the suggestion is the greater of the remaining planning shortfall and that
maximum stock quantity. This is scoped to supplied shortage rows and does not
reproduce all MRP stock and requirement elements. Results identify whether a
policy came from the caller, MARC, was missing, or was unsupported. Caller policies without a
lot-sizing procedure continue to treat their minimum, fixed quantity, and
order multiple as direct rules. Results also return the raw procurement type
and special procurement key for caller routing; the service does not determine
a vendor or source of supply. For external procurement without a special key,
results also estimate `estimated_delivery_date`, `latest_purchase_order_date`,
and `latest_pr_release_date` using the material/plant lead times and plant
factory calendar. `WEBAZ` and `BZTEK` are treated as workdays; `PLIFZ` is treated
as calendar days. `lead_time_status` can be `MATERIAL_ESTIMATE`, `NO_POLICY`,
`IN_HOUSE`, `AMBIGUOUS`, `SPECIAL_SOURCE`, `MISSING_CALENDAR`,
`CALENDAR_ERROR`, `UNSUPPORTED`, `COVERED_BY_SURPLUS`,
`COVERED_BY_RECEIPT`, or `COVERED_BY_SUPPLY`. A caller that has already resolved a
purchasing info record can provide its vendor, purchasing organization, record
number, category, and `source_planned_delivery_days` on the caller policy. A
positive info-record lead time overrides `planned_delivery_days`; zero falls
back to the caller's `planned_delivery_days` value. The result preserves source
identity and reports `lead_time_days_origin` as `INFO_RECORD`, `CALLER`,
`MATERIAL`, or `NONE`. The estimate does not determine a SAP source or evaluate
quota arrangements, contracts, prices, or purchasing-organization policy.
`ZCL_REPL_SOURCE_SERVICE->GET_VALID_PIR_CANDIDATES` bulk-lists standard
purchasing info records whose material, purchasing organization, plant scope,
deletion indicators, and inclusive validity dates match each request. It reads
`MARC-KORDB` and matching `EORD` entries: blocked matching sources are excluded;
when the source-list requirement is set, only candidates with an unblocked
vendor entry without an outline-agreement item, valid on the requested delivery
date, are returned. Candidates
include both info-record and source-list validity windows, fixed-source status,
MRP source-list usage, whether the info record is marked for automatic sourcing,
the material's quota-arrangement usage setting, and whether they are listed.
The automatic-sourcing flag is returned as `is_auto_source_relevant`; candidates
with the flag off remain visible for manual review by default. Set
`iv_require_auto_source = abap_true` to omit candidates whose `EINE-AUT_SOURCE`
flag is not set. This filters only that indicator and does not perform complete
SAP source determination. Set `iv_require_source_listed = abap_true` to return
only candidates with an active matching vendor source-list entry, even when
the material does not require a source list. This option still honors the
requested delivery date, blocked entries, and outline-agreement exclusions.
Set `iv_require_mrp_relevant = abap_true` to further require that the matching
source-list entry has `EORD-AUTET` set for automatic MRP use. An info-record
candidate without such a listed entry is omitted when this filter is enabled.
Set `iv_require_fixed_source = abap_true` to additionally require that the
matching source-list entry is fixed. This omits unlisted and non-fixed
candidates even when the material does not require a source list.
These flags accept only `abap_true` or `abap_false`; invalid values raise
`zcx_invalid_stock_request`, including when the request list is empty.
When `MARC-USEQU` is set,
it also reads active classic external-supplier quota items and reports each matching vendor's
`(quota-allocated quantity + quota base quantity) / quota` rating. Assigned
quota items rank by lowest rating; equal ratings in this purchase-requisition
candidate path follow quota item sequence. The classic quota guide describes a
higher-quota tie for zero ratings, so validate the target source-determination
workflow before treating preview order as an assignment. Candidates then rank
by fixed-source flag, optional request
`preferred_vendor`, and plant-specific info records. A vendor without a
matching quota item remains visible after quota-assigned candidates so callers
can review the whole candidate set. Each result also includes the matching
`TMQ2` usage rule, showing whether purchase requisitions, purchase orders,
scheduling-agreement schedules, planned orders, automatic MRP, production
orders, and invoices contribute to quota allocation.
Each PIR result includes `candidate_rank`, starting at one for the highest
ranked candidate within that request. When quota simulation is enabled, ranks
reflect the simulated per-request ratings; otherwise they reflect the stored
quota snapshot and existing tie-breakers.
Set `iv_simulate_quota_assignment = abap_true` to preview a sequential
assignment across the request batch. Requests are simulated by material, plant,
delivery date, descending request `priority`, and then input order. Larger
priority values consume quota first among same-date requests; the default is
zero. Candidates within each request are ranked again using quota quantities
assigned to earlier simulated requests. Results echo `request_priority`, and
`request_index` still identifies the original input order. The first-ranked
candidate is marked in `quota_simulation-is_selected_source`, and
that structure reports the simulated quota item, rating, and allocated quantity
before the request. The existing `quota_*` fields remain the stored snapshot.
Only requests with a supplied quantity increment simulated quota usage, and
only when the selected item's `TMQ2` rule includes purchase requisitions. Such
quantities must use the candidate material's base unit. The sequential,
single-source preview skips an item whose stored `QUMNG` has reached `MAXMG`;
when the `TMQ2` rule counts purchase requisitions, it also skips a positive
base-unit request that would bring stored or locally simulated usage to that
boundary. It writes no quota data and does not reproduce the
rest of SAP source determination. The separate split preview below also applies
the classic quota-item maximum quantity. This option defaults to false and is
validated even for an empty request list.
To retrieve standard PIR options for existing replenishment rows, call
`get_suggestion_pir_candidates` with the suggestions and a purchasing
organization. It queries positive, explicitly external (`F`) suggestions with
no special-procurement key, using the suggested base-unit quantity and required
date. Each option pairs a `suggestion_index` from the original list with the
ranked candidate returned by `GET_VALID_PIR_CANDIDATES`; covered, internal,
special-source, and other non-matching rows produce no options. The method does
not change the suggestions or choose a source. A caller can review an option,
copy its source identity into the selected suggestion, and then pass that row to
`ZCL_REPLENISHMENT_REQ_SERVICE`. Outline-agreement options remain available
through `get_suggestion_outline_sources`, which applies the same suggestion
eligibility and index mapping to valid contracts and scheduling agreements.
It accepts a purchasing organization and optional preferred vendor, and can
require fixed or MRP-relevant source-list entries. Each option carries the
original suggestion index and the ranked outline candidate. It does not change
the suggestions or choose a source; callers can still use
`GET_VALID_OUTLINE_SOURCES` directly for requests that are not replenishment
suggestions.
For a single result list across both source kinds, call
`get_suggestion_source_options`. It applies the same filters and returns one
row per PIR or outline candidate with `source_kind` (`P` for PIR, `O` for
outline), the original suggestion index, that source's candidate rank, and the
matching nested candidate structure. Results are grouped by suggestion, with
PIR rows before outline rows; ranks are local to each source kind, so they do
not compare PIR and outline options against each other. This is still a review
list and does not assign a source.
To apply a reviewed row, pass the original suggestions and one option to
`apply_suggestion_source_option`. It returns a copied suggestion table with
that row's vendor and purchasing organization set, plus the selected PIR or
agreement identity. It clears the other source kind's fields and checks that
the option index, rank, material, plant, required date, and source identity are
consistent. It does not reread source customizing, so apply an option to the
same suggestion set used to retrieve it and let SAP validate the source again
when creating the requisition.
For selections across several rows, `apply_selected_source_options` accepts a
table of reviewed options and applies them to a copied suggestion table in one
call. Unselected suggestions stay unchanged, and the method rejects multiple
source choices for the same suggestion index. Each option is checked with the
same consistency rules as the single-option method.
`ZCL_REPL_SOURCE_SERVICE->SIMULATE_SPLIT_QUOTA` separately previews a split for
one request index from this candidate set. It uses only quota-assigned standard
vendor candidates from one material, plant, purchasing organization, delivery
date, quota arrangement, and base unit. For a request at or above the maintained
minimum, it distributes quantity by quota value. A maintained `quota_priority`
overrides the usual descending-quota sequence: priority-bearing candidates come
first, with smaller priority numbers first; quota value orders ties and
candidates without priorities. Split amounts remain quota-based. SAP documents
both the split-sequence override and smallest-number-first priority order
([split quotas](https://help.sap.com/docs/SAP_ERP_SPV/66326f67e0e1416d83c0fdfa4060189d/8697b6535fe6b74ce10000000a174cb4.html),
[quota priorities](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/9297b6535fe6b74ce10000000a174cb4.html)); this preview applies those rules as a static order. If the trailing remainder falls below the minimum, it assigns that remainder to the next candidate in that order. A request below the minimum uses the highest-ranked candidate for the full quantity. Pass the requested quantity in the candidate base unit. By default the method uses the
quota arrangement's maintained minimum from `EQUK-SCMNG`; pass
`iv_minimum_split_quantity` in the base unit to override it. The returned rows
contain `split_sequence`, `allocated_quantity`, and the candidate identity.
SAP exposes item priority as `QuotaDeterminationPriority` in its [quota
arrangement API example](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91af7f8d3acd47da90d33aaacfcd0d59/58072494f7514201a032fb4adb30bf01.html).
This is a deterministic preview: the caller must establish that split-quota
customizing applies. SAP exposes the maintained minimum as `SCMNG` in the
released [purchasing quota-arrangement CDS view](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/6aece8e36db0478ebd6b31f0a90a7db7.html).
Quota-item `EQUP-MINLS` and `EQUP-MAXLS`, in the candidate material's base
unit, are applied after the required demand shares are calculated. The result
keeps that share in `allocated_quantity` and reports the suggested order amount
in `proposal_quantity`: a minimum can make the proposal larger than its demand
share, while a maximum can produce multiple proposal rows. SAP documents that
quota-item lot limits override material-master values and that each maximum-lot
proposal restarts quota determination
([quota-item lot sizes](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/8c97b6535fe6b74ce10000000a174cb4.html?locale=en-US&version=6.18.latest),
[quota arrangement API fields](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91af7f8d3acd47da90d33aaacfcd0d59/58072494f7514201a032fb4adb30bf01.html)). When a quota-derived share exceeds its max lot, the preview emits one max-lot proposal and recalculates shares for the remaining demand. A non-once source stays eligible for recalculation and may receive several max-lot proposals; an only-once source is removed after its first proposal and its remainder is recalculated over the other eligible candidates. If the remaining candidates cannot cover the request, the preview rejects it. SAP states that split shares use quota values rather than quota ratings
([splitting quota arrangement](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/8697b6535fe6b74ce10000000a174cb4.html?version=6.18.latest)); this local ratio preview does not model every MRP proposal and planning-element interaction.

A quota item's `EQUP-RDPRF` is returned as `quota_rounding_profile` and selects a
plant rounding profile. The preview reads its static levels from `RDPR` and
rounds each proposed quantity up by the threshold and rounding values;
quantities below the lowest threshold stay unchanged. Demand shares remain in
`allocated_quantity`, while rounded order amounts appear in
`proposal_quantity`. Rounded proposals count toward `MAXMG` eligibility. If
rounding would make a proposal exceed `MAXLS`, the preview rejects the
incompatible limits. SAP documents threshold-based static rounding and
quota-item profile use ([static rounding](https://help.sap.com/docs/SAP_ERP/85d3fce10e264972a0155c8b46ecf93b/f597b6535fe6b74ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest),
[quota-item rounding profiles](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/8c97b6535fe6b74ce10000000a174cb4.html?locale=en-US&version=6.18.latest)).

`EQUP-MAXMG` is read in the candidate material's base unit: zero means no
maximum, and an item is ineligible when stored `EQUP-QUMNG` is already at the
maximum or its proposed quantity (including minimum-lot and rounding expansion)
would reach it. The preview recalculates shares across remaining items and tries
the next ranked item for below-minimum requests. SAP describes an item as
unavailable if its allocated quantity is, or would become, greater than or
equal to its maximum ([quota-arrangement learning](https://learning.sap.com/courses/sourcing-in-sap-s4hana/controlling-source-determination-with-quota-arrangements)). Quota-maximum eligibility uses the stored `QUMNG` snapshot; the preview does not reserve quota or load every planning-element usage source. It supports static profiles only and does not apply other procurement categories. Verify `EQUK-SCMNG`, `EQUP-RDPRF`, `RDPR` fields, and `EQUP-PREIH`/`MINLS`/`MAXLS`/`KZEIN`/`MAXMG` availability and SQL behavior in the target release.
Requests can optionally include `requested_quantity` and
`requested_quantity_unit` in the info record's base unit. Candidates return the
raw `EINE-MINBM` and `EINE-BSTMA` limits in `purchase_order_unit`, plus their
converted values as `minimum_order_quantity_base` and
`maximum_order_quantity_base` in `base_unit`. `quantity_limit_status` is `N`
when no quantity was supplied, `I` within the inclusive range, `L` below
minimum, `H` above maximum, `U` when the request/base units differ, `C` when a
needed unit conversion is missing, or `R` for an invalid stored range. This
compares the maintained info-record limits; it is not a source assignment. SAP
documents that the minimum quantity may be ignored by MRP in some PR creation
scenarios
([KBA 2468048](https://userapps.support.sap.com/sap/support/knowledge/en/2468048)),
so validate the host workflow and release. Set
`iv_require_qty_in_range = abap_true` to omit candidates whose supplied request
has any status except
`I`. Requests without a quantity keep their candidates because there is no
quantity to compare. The option defaults to false, and its boolean value is
validated even for an empty request list.
For materials without a source-list requirement, an unlisted info record can
still appear if no active blocking entry matches it. The method returns the
`EINE-AUT_SOURCE` indicator and can optionally omit candidates where it is not
set, but does not assign a source or treat the flag as a complete
source-determination result. Callers must evaluate the remaining SAP
source-determination rules before acting on a candidate. The quota rating is a
read-only snapshot and does not reserve quota or reproduce SAP's complete source
determination. `SIMULATE_SPLIT_QUOTA` provides a separate ratio-based split
preview with classic quota-item maximum-quantity eligibility, but other
procurement categories, special procurement types, additional source-specific
constraints, and release-specific behavior remain for the host application to
evaluate. SAP documents the
quota-rating formula in its [quota source determination guide](https://help.sap.com/docs/PRODUCT_ID/af9ef57f504840d2b81be8667206d485/907fb65334e6b54ce10000000a174cb4.html). SAP describes
different tie behavior for quota determination and direct requisition source
determination ([requisition sourcing](https://learning.sap.com/courses/purchasing-in-sap-s-4hana/controlling-source-determination-with-quota-arrangements-1));
validate the actual workflow and release.

`ZCL_REPL_SOURCE_SERVICE->GET_VALID_OUTLINE_SOURCES` returns a separate list of
source-list-linked purchase contracts (`EKKO-BSTYP = 'K'`) and scheduling
agreements (`BSTYP = 'L'`) for the requested material, plant, purchasing
organization, and delivery date. SAP defines those agreement types as source
documents and source-list validity as the period during which a source can be
used ([source determination](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/79bbb853dcfcb44ce10000000a174cb4.html),
[source-list entries](https://help.sap.com/docs/SAP_ERP/967e1c2a6a8c4183b7e07d28e7574445/7b7fb65334e6b54ce10000000a174cb4.html),
[contract category](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/29193bf0ebdd4583930b2176cb993268/59acf04a594348839b8020ff725eb520.html),
[scheduling-agreement category](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/29193bf0ebdd4583930b2176cb993268/b1cbbdc144ed44fa82645ae0a84c7640.html)).
Results include the agreement/item, vendor, document and source-list validity
windows, fixed-source and MRP-use flags, and preferred-vendor match. Fixed
sources sort first, followed by the request's preferred vendor. Blocked source
list rows (including applicable vendor-level blocks), deleted documents/items,
completed items, source-list/header vendor mismatches, and sources outside
either validity window are omitted. This is review data: it does not check
release status, prices, remaining contract
quantity, scheduling-agreement schedule lines, or delivery confirmation, and
it does not assign or create a source. Validate the `EORD`/`EKKO`/`EKPO` join
and target-specific source rules in the host SAP release.
Each result includes `candidate_rank`, starting at one within its request, so
callers can retain the fixed-source/preferred-vendor ranking explicitly.
Set `iv_require_mrp_relevant = abap_true` to omit agreements whose matching
source-list entry does not have `EORD-AUTET` set for automatic MRP use. The
filter defaults to false so contracts and scheduling agreements remain
available for manual review; only `abap_true` and `abap_false` are accepted,
including for an empty request list.
Set `iv_require_fixed_source = abap_true` to require the source-list fixed
indicator. Both filters are independent and default to false; invalid values
raise `zcx_invalid_stock_request`, including for empty requests.

The replenishment
estimate also returns `as_of_date`, `pr_release_is_overdue`, and
`pr_release_days_overdue`. Pass `iv_as_of_date` for a fixed evaluation date; it
defaults to `sy-datum`. The overdue day count uses calendar days and is
calculated only when a requisition release date was estimated; otherwise it is
zero. `pr_release_urgency` gives a direct status of `NO_ESTIMATE`, `OVERDUE`,
`DUE_TODAY`, or `UPCOMING`; use the date and overdue-day fields when a numeric
lead time is needed. The estimate
remains indicative and does not create purchase documents or reserve stock.
Pass returned suggestions to `zcl_replenishment_req_service` to create a
purchase requisition through `BAPI_PR_CREATE`. It creates one requisition item
for each planned receipt lot, preserving the lot split, base unit, plant,
quantity, and required date; zero-quantity covered rows are skipped.
For a fixed-lot suggestion rounded by `MARC-RDPRF`, it validates that the total
equals the rounded final receipt quantity times the receipt count and creates
each item at that rounded quantity.
`iv_test_run = abap_true` asks the BAPI to simulate creation and skips commit.
Normal writes commit only after the BAPI succeeds and returns a requisition
number; errors trigger rollback. The service accepts a requisition type (default
`NB`) and optional purchasing group and organization. It leaves vendor/source
selection to SAP when the suggestion has no caller-resolved source. Suggestions
that carry a complete purchasing info-record source preserve its vendor as the
fixed vendor and use its purchasing organization; explicit per-suggestion
controls can override that organization. The info-record number remains source
metadata and is passed on the PR item as `INFO_REC`; the source category stays
in the suggestion. For a source-list agreement, put the selected vendor,
purchasing organization, agreement number, and item in the matching
`ty_replenishment_policy` row; the suggestion preserves that identity and the
PR mapper sends `AGREEMENT` and `AGMT_ITEM` with their update flags. Info-record
and agreement references are mutually exclusive, and incomplete source
identities fail before the BAPI call. The caller still chooses the candidate;
without a caller-resolved source, SAP determines it. SAP's integration mapping
uses the agreement item field on requisition items
([BAPI item mapping](https://help.sap.com/docs/SAP%20Fieldglass%20Integration%20Add-On/e745d2cc4d114bbf92d2eea49eda9af4/33fb634641b64daf8599330f98360856.html)).
It only accepts externally procured (`F`) suggestions
without a special procurement key; in-house, ambiguous, special-source, and
unresolved routes are rejected. Verify BAPI availability, required item fields,
document type, and purchasing configuration in the target SAP release. The
result's `submitted_items` echoes the PR item number and a 1-based
`source_suggestion_index` for every line, including split lots and BAPI
test-runs, so the caller can reconcile each item to its original suggestion.
When source options have already been reviewed, call
`create_from_selected_sources` with the original suggestions and chosen option
rows. It applies those identities and then uses the same PR validation, BAPI,
test-run, and commit behavior as `create_from_suggestions`. Unselected rows
remain unchanged and are left for SAP source determination. This method does
not retrieve or choose source options itself.
Pass optional `it_purchasing_controls` rows keyed by that 1-based suggestion
index to override purchasing group and/or organization for only that
suggestion; each blank control field inherits the method-level default.
Duplicate indexes, indexes outside the suggestion table, covered suggestions,
and rows with neither value are rejected before the BAPI call.
Each returned SAP message preserves its BAPIRET2 type, class, number, text
variables, parameter, row, field, system, and log identifiers so callers can
present or log structured item-level diagnostics. Messages that point to a
`PRITEM` or `PRITEMX` row also include the corresponding generated item number
and source suggestion index when the row maps to a submitted item.
The result reports `is_test_run`, `bapi_was_called`, and `is_committed` so a
successful simulation or covered-row no-op can be distinguished from a
requisition committed to SAP.
With no projected receipts and `iv_net_prior_surplus = abap_false`, each dated
shortage is lot-sized independently and results keep the input order, except
that `MB` shortages for the same material, plant, unit, and calendar month and
`WB` shortages for the same material, plant, unit, and calendar week are
grouped into one suggestion. Set
`iv_net_prior_surplus = abap_true` to process shortages in
material, plant, unit, and required-date order, and carry unused rounding
surplus from an earlier suggestion into later dates for the same material,
plant, and unit. `planning_shortfall_qty` reports the quantity still to plan;
`prior_surplus_used_qty` reports the amount covered by that carry. A fully
covered date remains in the result with zero suggested quantity and
`lead_time_status = COVERED_BY_SURPLUS`. In this mode,
`rounding_surplus_base_quantity` reports the remaining carry after that date.
Pass `it_projected_receipts` to net caller-supplied PO, stock-transfer, or
production receipts against shortages. Each row provides material, plant, base
unit, receipt date, and positive quantity. Optional source type/document/item
fields are returned per consumed line in `projected_receipt_uses`; source type
and document must be supplied together. Receipts dated on or before a required
date are consumed earliest-date first. Results report the total in
`projected_receipt_used_qty`; a date covered by projected receipts has
`COVERED_BY_RECEIPT` status, or `COVERED_BY_SUPPLY` when prior suggestion
surplus also contributes. Supplying receipts makes shortages process in
chronological key/date order even when `iv_net_prior_surplus` is false. The
service does not query receipt sources itself: pass only receipts the caller
has validated for the relevant dates. Review timing estimates and statuses
before using the quantities for execution.
For repository-backed receipt reads, set `iv_include_pr_receipts = abap_true`
on `zcl_stock_service=>get_projected_receipts`; the default is false. The
returned `PR` rows identify the requisition through `source_document` (BANFN)
and `source_item` (BNFPO), and include only the unconverted amount
`EBAN-MENGE - EBAN-BSMNG` due by `EBAN-LFDAT`, converted to the material base
unit. `zcl_prod_comp_service=>suggest_comp_repl_from_stock` accepts the same
flag and nets those rows into shortage dates automatically. PR rows are
restricted to nondeleted, incomplete, nonblocked standard stock items without
account assignment or special stock; review [the PR receipt assumptions](ANOMALIES.md)
for release-status and target-system limits. The dated stock allocation methods
also accept `iv_include_pr_receipts`, adding eligible PR quantities to each
date's local available-stock estimate. When an allocation method also requests
SAP ATP, the flag affects only the local estimate; it does not change the ATP
request or SAP's response. The same flag is available on component stock/ATP
previews and multi-sales-order dated previews/reservations, so those workflows
can use the same opt-in projection. Reservation writes still depend on SAP
accepting the actual request; confirm stock and ATP before committing a write
based on projected future supply.
Planned-order rows can also be netted into component replenishment suggestions
through `iv_include_planned_receipts = abap_true` on
`suggest_comp_repl_from_stock`; the flag is available on component previews and
multi-sales-order dated previews and reservations. Review the planned-order
selection assumptions in [ANOMALIES.md](ANOMALIES.md) before acting on this
nonfirm MRP proposal quantity.
Stock-transfer requisitions use a separate opt-in,
`iv_include_sto_pr_receipts = abap_true`. Their returned `STO_PR` rows retain
the issuing plant in `source_plant` (`EBAN-RESWK`) and the receiving plant in
`plant` (`EBAN-WERKS`). This keeps direct procurement PR and interplant PR
supply independently selectable.
Scheduling-agreement delivery schedule lines can be included separately with
`iv_include_sched_agmt_receipts = abap_true` on
`zcl_stock_service=>get_projected_receipts`, or on
`zcl_prod_comp_service=>suggest_comp_repl_from_stock`. The same switch is
available on dated stock allocations, component stock/ATP previews, and
multi-sales-order dated previews/reservations. In ATP variants it changes the
local estimate only; it does not alter SAP's ATP request or result. The default
is false.
Each `SCHED_AGREEMENT` row identifies the agreement/item/schedule line and
projects its due-date open quantity (`EKET-MENGE - EKET-WEMNG`) into the
material base unit. This is an advisory schedule-line projection; it does not
confirm that a vendor release was transmitted or that the vendor confirmed the
delivery. SAP describes scheduling-agreement schedule lines separately from
the release sent to the vendor ([schedule lines and releases](https://help.sap.com/docs/SAP_ERP/15f6005df5a343d096f63b554e47e14a/217fb65334e6b54ce10000000a174cb4.html)).
Review the local [assumptions](ANOMALIES.md) and validate representative
agreements in the target SAP release before using these quantities.
Compare statuses and origins with the public
`ZCL_PROD_COMP_SERVICE=>C_REPL_*` constants. See
[replenishment assumptions](ANOMALIES.md) for target-release validation details.

`ZCL_CC_RESERVATION_SERVICE` creates material reservations for a cost center
with movement type 201. A request may specify one batch. A supplied storage
location is a hard restriction by default; set `iv_allow_fallback = abap_true`
to try that location first and use other locations in ascending code order for
the remainder. This option applies to exact-batch and FEFO allocations too.
Omit the storage location to allocate across locations in ascending code order.
The resulting location or batch/location splits are sent as items in one
reservation document. The service accepts the material's
base unit or a material-specific alternative unit, converts the requested
quantity using
`MARA`/`MARM`, and uses the base unit for stock allocation and the BAPI request.
Results retain the input quantity and unit and report allocated quantities in
the base unit, including availability and shortfall. It reserves the full
available amount by default; set
`iv_require_full_alloc = abap_true` to reject short allocations. The BAPI runs
with an ATP check and supports simulation and transaction rollback. SAP defines
movement type 201 as goods issue to cost center and stores the movement type
and account assignment on the reservation header ([movement type](https://help.sap.com/docs/SAP_ERP/a70c5fce76eb44adb0c86a9d3059e4dd/1663bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest), [reservation structure](https://help.sap.com/docs/SAP_ERP/c8f06b9bc95747ca832ad21e94f577fb/ade0ba538c95b54ce10000000a174cb4.html)).

`reserve_for_cost_center` can also return its own ATP precheck when
`iv_check_atp = abap_true` and `iv_atp_check_rule` are supplied. Set
`iv_require_atp_confirmation = abap_true` to stop before the reservation API
when SAP confirms less than the requested base quantity. This gate requires ATP
checking; a short result retains the ATP details and creates no reservation.
The BAPI still performs its own ATP check. As with the preview, this precheck is
plant-level and does not constrain ATP to the selected batch or storage
location.

`preview_for_cost_center` runs the same allocation and validation steps but
does not call the reservation API. Set `iv_check_atp = abap_true` and supply
`iv_atp_check_rule` to attach a SAP ATP result in `atp_result`. ATP checks the
base-unit request at plant level and does not constrain the result to a selected
batch or storage location. The preview also reports confirmed and unconfirmed
base quantities derived from the ATP confirmation lines. The ATP data is
separate from local allocation and does not change the preview success flag or
splits. Full-allocation requirements are reported in the preview result.

Set `iv_use_fefo_batches = abap_true` to reserve automatically selected
batches by earliest expiration date. The as-of date defaults to today;
`iv_fefo_min_days` can require a minimum remaining shelf life. Expired batches
are excluded, and undated batches are excluded when the minimum is positive.
FEFO cannot be combined with an explicit `iv_batch`; a supplied storage
location remains a hard restriction unless `iv_allow_fallback = abap_true` is
passed, in which case it is tried first and other locations are considered
afterward.

## Integration limits

The `stubs/src/` definitions model only fields used by the local tooling; SAP's
delivered dictionary and function module signatures are authoritative at
deployment. Local verification uses fake APIs and does not connect to an SAP
system. `quantity` and `base_quantity` describe the requested item quantity;
`open_quantity` and `open_base_quantity` describe the undelivered portion.
Open quantities use `VBEP-WMENG - VBEP-VSMNG` per schedule line and the item
delivery status in `VBUP`; the requested schedule date comes from `VBEP-EDATU`
([schedule-line fields](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/6b356c79dea443c4bbeeaf0865e04207/fa2da7433e464b5b8b24abf99caa620a.html),
[delivered schedule quantity](https://help.sap.com/docs/BI_CONTENT_707/8283ab99b2f540c18afbe5cbb34501e3/6a497053bbe77c1ee10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=7.07.24)).
`confirmed_quantity` retains the schedule-line value from `VBEP-BMENG`;
`open_confirmed_quantity` subtracts delivered quantity from it. The
corresponding `_base_quantity` fields are converted using the sales item's
ratio. When `iv_use_confirmed_qty` is true, allocation demand uses
`BMENG - VSMNG`, clamped to the open ordered quantity.
Confirmed delivery dates are not read; requested dates still come from
`VBEP-EDATU` ([schedule-line field definitions](https://help.sap.com/saphelp_snc70/helpdata/en/dd/db9e759d4f453a8e081ad7df5f7770/content.htm?no_cache=true)).
If an item has no schedule lines, the read falls back to its `VBAP` item
quantities and has no requested date. Confirmed-quantity mode rejects open
items without schedule-line confirmation data before reading stock.
The allocation service only passes positive open base-unit quantities to the
stock preview and skips a failed or incomplete order read. Active, non-deleted
reservations for unrestricted stock are subtracted from `MARD-LABST`; this is
not a full ATP calculation and does not include every SAP planning element.
Set `iv_check_atp = abap_true` and supply `iv_atp_check_rule` on `preview_order`
or `reserve_order` to request SAP ATP diagnostics for remaining open schedule
lines. The result includes one BAPI call per unique
material/plant/base-unit/required-date group using the cumulative open demand
through that date, then includes the shared result on each matching schedule
line. Each line's own and cumulative quantities are returned alongside the SAP
result, separately from local allocation; ATP checks do not alter the local
splits or success flag. `reserve_order` returns these diagnostics before its
reservation calls, but the diagnostic does not block the reservation; the
reservation BAPI performs its own ATP check.
`GET_STOCK_STATUS` reports raw plant totals for `MARD-LABST`, `MARD-INSME`, and
`MARD-SPEME`, plus active unrestricted `RESB` reservations net of withdrawals
and a clamped available-unrestricted estimate. Local tests use a fake
repository and do not execute the MARD, RESB, or MARC database queries. The
report also returns static `MARC-EISBE` and an available quantity after that
buffer; neither quantity represents every ATP element or dynamic safety-stock
behavior.
Date-based projections can add PO receipts, issued or unissued STO quantities,
subtract unissued outgoing STO quantities, and add released production and
unfixed planned-order receipts. These are local schedule estimates from
`EKET`, `EKPO`, `EKKO`, `AFPO`, `AFKO`, `AUFK`, and `PLAF`; repository doubles do not
execute those database queries or validate live schedule filters and units.
They do not replace SAP ATP.
`GET_STOCK_STATUS_BY_LOCATION` aggregates the same category quantities by
`LGORT`; its available-unrestricted values use the location reservation
calculator, including the deterministic distribution of plant-level
reservations.
`GET_STOCK_STATUS_BY_BATCH` returns unrestricted batch quantities and their
available estimates by `LGORT` and batch, including zero-available rows. It
reads the partial `MCHB`, `MCHA`, `MCH1`, and `RESB` stubs and uses the batch
reservation calculator; local tests verify service mapping but do not execute
those queries.
Sales-order previews also read active `RESB` reservations assigned to the order
and subtract `BDMNG - ENMNG` from matching open demand. The query uses
`KDAUF`, `KDPOS`, `KDEIN`, and `BDTER`; target-system BAPI field propagation and
the fallback when schedule-line/date keys do not match need validation. Local
tests use reservation data doubles rather than executing that query.
Cost-center reservations use movement type 201 and the `COSTCENTER` header
assignment with `BAPI_RESERVATION_CREATE1`; alternative units are converted
through `MARA`/`MARM`. The local tests use repository/API doubles and do not
execute those queries or the BAPI, verify its target-release fields, or
exercise live ATP and account-assignment configuration. The reservation
preview is a local stock estimate; SAP performs its own ATP check during BAPI
creation. Verify conversion ratios and decimal precision in the target release.
Reservations without a storage location are deducted from the remaining
location balances in ascending location-code order; this keeps the total
available quantity conservative but does not identify SAP's physical pick
location.
Optional safety-stock protection subtracts static plant-level `MARC-EISBE` when
`iv_protect_safety_stock` is true; it is off by default. The local tests cover
the allocation arithmetic but do not execute the `MARC` query or validate the
target system's ATP configuration. This does not model time-dependent safety
stock or every checking-rule scope.
Batch availability is a separate estimate based on `MCHB-CLABS` and open
`RESB` quantities. Reservations without a batch or storage location are
deducted from compatible balances in ascending location and batch order. If a
reservation exceeds its matching batch/location stock, the excess is deducted
from other remaining balances in that same order to avoid overstating free
quantity. `ALLOCATE_BY_BATCH` requires a caller-selected batch and never
substitutes another batch. Sales-order batch selections must cover every
positive-open schedule line; item-wide choices cover all open lines, while
schedule-line choices can select different batches on one item. Partial,
duplicate, or mixed item-wide and schedule-line choices are rejected before
stock is read. FEFO mode selects batches automatically by expiration date but
does not run SAP's configured batch determination. Batch-managed split valuation
uses the selected batch; valuation-type selection for non-batch-managed split
valuation is not modeled. Verify later reservations or goods issues against the
target system's batch strategy.
Reservations created for schedule lines use their requested dates. Reservations
for items without schedule lines use the current date. Verify
`BAPI_RESERVATION_CREATE1`, movement type 231, `ATPCHECK`, and reservation
fields against the target SAP release. Reservations made outside this service
are included in subsequent previews if they have matching material/plant and
unrestricted-stock assignment.
Reservation deletion acts on the complete reservation document by number;
SAP determines whether a reservation can still be deleted after goods issues
or other changes.
Reservation goods issue quantities are expressed in the detail item's base
unit. The service uses the reservation's base-unit ISO code and lets SAP
validate movement-type and posting-period rules. Verify reservation-linked
goods movement fields against the target SAP release.
Order changes require explicit item and schedule-line numbers. Verify that the
target release populates `BAPISDIT-SALES_QTY1` and `SALES_QTY2` in the
detail-list BAPI output.

## Development

Requires Node.js 22 or newer and npm.

```sh
npm install
npm test
```

`npm test` runs abaplint, transpiles the ABAP sources with open-abap-core, and
runs ABAP Unit tests through the transpiler runtime. The `MARD` definition in
`stubs/src/` is only a local tooling stub; the target SAP system supplies the
real standard table.

See [PLAN.md](PLAN.md) for implementation requirements and [NOTES.md](NOTES.md)
for progress.
