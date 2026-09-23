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
Previews do not reserve stock, so availability can change before posting.
Storage-location transfers (311/312) require a receiving storage location;
two-step transfers use separate 313 removal and 315 putaway postings. It
posts purchase-order goods receipts with movement type 101 and PO-referenced
returns to vendor with movement type 122, both with movement indicator `B` and
purchase-order/item reference; and production-order receipts with GM
code 02, movement type 101, order reference, and indicator `F`. Material, plant,
and storage location may be inherited from the referenced order. It requires
each movement quantity to include both SAP's unit and its ISO code. It supports
BAPI test runs and commits or rolls back based on the BAPI result ([BAPI
movement codes and required receipt fields](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
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
Pass `iv_use_confirmed_qty = abap_true` to `preview_order` or `reserve_order`
to size demand from each schedule line's confirmed quantity minus deliveries,
capped at its ordered open quantity. The default continues to use ordered open
quantity. Confirmed-quantity mode requires schedule-line confirmation data and
returns an error before stock reads for an open item without it.

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
service asks SAP to run an ATP check and commits the reservations in one BAPI
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
required and withdrawn quantities, and the remaining open quantity. The
`ISSUE_COMPONENTS` method accepts selected reservation keys and quantities,
checks them against those open lines, and delegates posting to the existing
reservation issue service. It supports test runs and SAP transaction handling.
Quantities use the component reservation unit. SAP generates component
reservations when production orders are created; movement type 261 is the
standard goods issue for order components
([withdrawing material components](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/c803b753128eb44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest)).

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

`preview_for_cost_center` runs the same allocation and validation steps but
does not call the reservation API. It returns the available quantity,
allocation, shortfall, and location or batch splits for callers that need to
review a cost-center request before creating it. Full-allocation requirements
are reported in the preview result.

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
`GET_STOCK_STATUS` reports raw plant totals for `MARD-LABST`, `MARD-INSME`, and
`MARD-SPEME`, plus active unrestricted `RESB` reservations net of withdrawals
and a clamped available-unrestricted estimate. Local tests use a fake
repository and do not execute the MARD, RESB, or MARC database queries. The
report also returns static `MARC-EISBE` and an available quantity after that
buffer; neither quantity represents every ATP element or dynamic safety-stock
behavior.
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
