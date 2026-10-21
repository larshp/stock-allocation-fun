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
Use `ALLOCATE_DEMANDS_BY_PRIORITY` or `ALLOCATE_DEMANDS_UOM_PRIORITY` for
base-unit or alternative-unit bulk requests that need explicit precedence.
Higher integer priorities consume shared material/plant stock first; input order
breaks ties. Results return in caller order and echo each priority. These
methods require unique request IDs and remain local previews that do not reserve
stock.
`ALLOCATE_DEMANDS_UOM_ATP` returns the same unit-aware local allocations with
cumulative plant ATP diagnostics for positive quantities, grouped by material,
plant, and base unit. Its optional `iv_atp_check_date` defaults to `sy-datum`;
ATP confirmation remains diagnostic and does not change the local allocation.
`ALLOCATE_DEMANDS_UOM_ATP_PRIO` adds grouped plant ATP confirmation for positive
local allocations by material, plant, and base unit at an optional check date.
The ATP result is diagnostic and does not change the priority allocation. ATP
result rows from `ZCL_STOCK_SERVICE` and sales-order allocation previews expose
`is_fully_confirmed`, including per-demand dated ATP results. It is true only
when confirmed base quantity covers the requested or cumulative quantity checked.
Use `ALLOCATE_BY_EXPIRY_PRIORITY` or `ALLOCATE_FEFO_UOM_PRIORITY` when FEFO
demands sharing stock need explicit precedence. In the default mode, higher
integer priorities allocate first without requiring per-demand FEFO dates;
input order breaks ties. FEFO still orders
eligible batches for each demand, while allocation summaries and batch splits
return in caller order and echo each priority. Request IDs must be unique.
`ALLOCATE_FEFO_UOM_ATP_PRIO` adds grouped plant ATP checks by material, plant,
base unit, and check date while keeping the local FEFO split and its priority
echo intact.
Set `iv_prioritize_by_date = abap_true` on the priority FEFO allocation and ATP
methods to process earlier per-demand `fefo_as_of_date` values first, then higher
integer priority for same-date requests. Every demand must supply a valid FEFO
date in this mode. Results still return in caller order, and ATP and quality
posting rechecks forward the same ordering option. The default remains
priority-first.
`ALLOCATE_QUALITY_FEFO_PRIORITY` and `ALLOCATE_QUALITY_UOM_PRIORITY` apply
the same ordering to quality-inspection batch balances. The UOM form returns
source and base-unit quantities.
Unit-aware stock allocation rejects a positive requested quantity when its
conversion rounds to zero in the material base unit, before reading stock.
The shared material-unit converter also reports an unsuccessful result when a
nonzero quantity rounds to zero or the conversion exceeds the `MARD-LABST`
range.
`ZCL_SO_STOCK_SERVICE` reads stock assigned to a sales document item from
`MSKA` and nets open special-stock E reservations from `RESB`. Its bulk method
keeps each sales document/item/material/plant key separate and returns location
and batch rows with aggregate available quantity in the material base unit.
Stock and reservation totals accumulate in high precision; totals that do not
fit their result quantity fields raise `ZCX_INVALID_STOCK_REQUEST`.
The result also includes the open reservation rows and each row's outstanding
quantity for audit and explanation. `READ_SALES_ORDER_ITEM` and
`READ_SALES_ORDER_ITEMS_BULK` resolve material and plant from the sales item,
so callers can request the stock by sales document and item alone.
`READ_STOCK_IN_UNIT` and `READ_STOCK_BULK_IN_UNIT` return unrestricted,
reserved, and available quantities in both the material base unit and a
requested unit. Bulk rows for the same item and cutoff share one calculated
snapshot, including when requested in different units. The same item can be
requested at different reservation cutoffs; each cutoff gets its own reserved
and available totals while using the same batched stock read. Each result
retains the base-unit stock snapshot and reservation details.
Set `reservation_through_date` on a request, or pass
`iv_reservation_through_date` to the single-item readers, to exclude later-dated
reservations from the deducted total. Undated reservations are still deducted;
all open rows remain in the result for audit.
`PREVIEW_ISSUE_DEMANDS` checks base-unit demand for multiple sales-order items
against these aggregate balances and returns the covered quantity and shortfall
with each stock snapshot. Multiple request rows may target the same item. Rows
for the same item and cutoff consume one shared availability snapshot in input
order; each row's `available_quantity` is the balance remaining before that row,
while `stock_snapshot` retains the original balance. Different cutoffs use
independent availability pools, so one cutoff scenario does not consume another
scenario's balance. Both previews report aggregate coverage without assigning
net availability to a location or batch.
Each result also reports `allocation_outcome`: `F` when the request is fully
covered, `P` when it is partially covered, and `U` when none of its quantity is
covered. With `iv_require_full_quantity = abap_true`, an underfilled request is
reported as `U` because its covered quantity is zero. The unit-aware preview
determines the outcome from base-unit quantities, so unit conversion rounding
does not change the outcome code.
Set `minimum_coverage_pct` on an individual request to require a minimum fill
from 0 through 100 percent; the initial value, zero, preserves partial
allocation behavior. If provisional coverage falls below the threshold, the
preview allocates nothing for that request and leaves the stock for later
requests sharing the same item and cutoff. The threshold is compared against
unrounded base-unit quantities and is echoed on the result. The unit-aware
preview uses the same base-unit rule. `iv_require_full_quantity = abap_true`
continues to require 100 percent coverage.
Set `iv_prioritize_by_date = abap_true` on either aggregate preview to process
rows by ascending `required_date`, then descending integer `priority`; input
order breaks ties. This option requires a valid required date on every row and
returns rows in caller order with the date and priority echoed. It orders
demands sharing an item and reservation cutoff; `reservation_through_date`
continues to control which open reservations are deducted.
Set `iv_prioritize_by_priority = abap_true` to process shared item/cutoff
balances by descending priority without requiring required dates; input order
breaks ties. If date ordering is enabled, required date remains primary and
priority breaks ties within a date. Results still return in caller order.
`PREVIEW_ISSUE_DEMANDS_IN_UNIT` accepts alternative-unit quantities and returns
requested, available, covered, and shortfall amounts in both the requested and
material base units. Repeated item requests share the same remaining base-unit
balance even when their requested units differ. It rejects unknown unit ratios
and positive demands that convert to zero base quantity.
Both aggregate previews accept `iv_require_full_quantity = abap_true`. An
underfilled request gets zero covered quantity and leaves the remaining item
balance for later requests with the same reservation cutoff; the default keeps
partial coverage. The unit-aware form makes this comparison in base units.
`PREVIEW_ISSUE_DEMANDS_BY_FEFO` returns an eligible batch/location split for
each demand, ordered by expiration date, batch, and storage location.
`PREVIEW_ISSUE_FEFO_UOM` accepts alternative-unit quantities and returns split
quantities in both source and base units. Both methods exclude expired batches.
Each request can set `minimum_coverage_pct` from 0 through 100. If total
eligible base-unit stock is below that threshold, the preview allocates nothing
to the request and leaves its candidate batches available to later requests.
The threshold is echoed on the summary and any batch split. FEFO summaries also
report `allocation_outcome` as `F`, `P`, or `U`; unit-aware results derive the
code from base quantities. Call-wide and per-request full-quantity options
continue to require complete coverage.
`iv_as_of_date` defaults to today, `iv_min_days` defaults to zero, and undated
batches are included by default. A reservation with location or batch detail is
deducted from matching balances first. Unscoped reservations consume eligible
balances in FEFO order before the service reconciles the split total to the
aggregate reserved-net quantity. Repeated demands share balances in input order
within the same item and reservation cutoff; different cutoffs use independent
balances. Set `batch` on a request to restrict that demand to one batch; repeated
requests for that batch share its remaining balance. Expiry and minimum shelf
life rules still apply. Set `minimum_shelf_life_days` on a demand to require a
longer remaining life for that demand; the greater of this value and shared
`iv_min_days` applies. The effective minimum is echoed on the summary and each
batch split. Set `require_known_expiry = abap_true` to exclude undated batches
for just that demand, even when `iv_include_undated_batches` allows them for
other rows. Nonblank expiration dates returned by the sales-order stock
repository are validated as Gregorian dates; a malformed value rejects the
preview. Set `storage_location` to restrict a demand to one exact location;
the exact-batch filter can be combined with either location mode. By default,
the location is a hard restriction. Set `allow_location_fallback` to
`abap_true` to prefer that location and allow other locations when needed.
Expiry and batch order remain primary; the preference breaks ties within the
same batch and expiration date, and remaining locations follow ascending code.
The preference and fallback flag are echoed on summaries and splits. Issue and
reservation consumers validate their consistency, and hard restrictions still
require every split to use the selected location. The attached stock snapshot
remains the item's aggregate snapshot. These are previews and do not reserve
stock. Pass `it_location_allowlist` to limit the whole request set to an
approved set of storage locations; summaries report availability within that
scope, and the fresh issue and reservation preview paths accept the same
allowlist so a recheck preserves the restriction. A selected preferred location
must also be in the allowlist. `it_request_locations` adds request-specific
location sets by request ID. When both options are supplied, each request uses
their intersection; requests without a request-specific set use the shared
allowlist alone. Unknown request IDs, duplicate scope rows, and preferred
locations outside a request's set are rejected before stock reads. The preview
returns both filters with its allocation; issue and reservation consumers
revalidate every selected split against those filters, and rechecks compare the
filters along with stock snapshots and splits. Selected-request results retain
the shared allowlist and only the selected requests' location scopes.
Both FEFO previews accept `iv_require_full_quantity = abap_true` as a shared
all-or-nothing policy. Each base-unit or UOM request can also set
`require_full_quantity = abap_true` individually. A flagged request that
exceeds its remaining eligible item/batch/location balance receives no split
and leaves the balance for later requests sharing the same item and reservation
cutoff. Other requests keep partial allocation unless the shared option is set.
UOM requests apply the rule after conversion to base units, and invalid row
flags are rejected before stock reads.
A FEFO request may set `required_date`; the later of it and `iv_as_of_date`
controls that demand's expiry eligibility and is returned on its summary and
batch splits. Set `iv_prioritize_by_date = abap_true` to require dates on all
rows and consume shared item/cutoff balances by ascending required date,
descending integer priority, then stable input order. Summary rows and batch
splits return in caller order and echo date and priority. This does not change
the independent `reservation_through_date` used to net open reservations.
Set `iv_prioritize_by_priority = abap_true` to allocate FEFO requests by
descending integer priority without requiring dates; input order breaks ties.
When both options are enabled, required date remains primary and priority
breaks ties on the same date. `ZCL_SO_FEFO_ISSUE_SERVICE` accepts the same
option and repeats the ordering during its fresh allocation check.
Both FEFO preview methods also accept `it_storage_location_priority`. For
matching expiry dates and batch numbers, listed locations are consumed in the
caller's order; unlisted locations follow by storage-location code. This order
breaks ties after FEFO date and batch ordering. Blank or repeated locations are
rejected before stock reads, and `ISSUE_FEFO` and `ISSUE_FEFO_UOM` forward the
same list during their fresh allocation checks. If fallback is enabled for a
request with a selected location, that selected location stays first within a
tie, ahead of the supplied list.
Both preview methods also accept `it_request_location_priorities` for
request-specific tie ordering. Each row names a known request ID, a storage
location, and a positive `priority_rank`; a request/location pair can appear
only once. For requests with local rows, lower ranks are consumed first and
override the shared location order; equal ranks and unranked locations are
ordered by location code, with unranked locations after ranked ones. A
selected location with fallback enabled remains first. `ISSUE_FEFO` and
`ISSUE_FEFO_UOM` forward these rows during their fresh allocation checks.
`RESERVE_SO_FEFO_DEMANDS`, its UOM variant, and both reservation recheck
methods accept and forward the shared and request-specific orders so the fresh
preview uses the same split order as the original.
The unrestricted-stock base, unit-aware, priority, and ATP FEFO allocators also
accept `it_request_locations`. Each request is limited to its listed locations,
intersected with the shared allowlist; the scope filters on-hand batches and
projected batch receipts while preserving FEFO order among eligible stock.
Preferred locations must be inside the request scope. Blank, unknown, duplicate,
and preferred-outside-scope rows fail before stock reads or UOM conversion.
Priority and unit-aware adapters map scopes through internal request IDs and
echo the caller-facing rows.
Construct the SAP-backed reader with
`ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_SALES_STOCK_SERVICE()`.
`ALLOCATE_BY_STORAGE_LOCATION` accepts an optional
`it_storage_location_priority` list. For a demand with a preferred storage
location and fallback enabled, that location remains first, followed by listed
locations in caller order; remaining locations follow in ascending code order.
Without a preferred location, the list is applied first. Unlisted locations
remain eligible, so this is an ordering rule rather than an allowlist. Blank or
duplicate entries are rejected before stock reads. The unit-aware variant
accepts and forwards the same priority list. An optional
`it_request_location_priorities` table can override the shared order for
individual demand IDs. Rows use positive ranks; lower ranks are consumed first,
rank ties and unranked locations use storage-location code, and unranked
locations follow ranked ones. A preferred location remains first when fallback
is enabled. Unknown demand IDs, duplicate request/location pairs, blank
locations, and nonpositive ranks are rejected before stock or UOM reads. This
table orders candidates without filtering their eligibility. The unit-aware
variant applies each request's ranks after converting it to an internal row
ID. An optional
`it_allowed_storage_locations` list filters eligible locations; an omitted or
empty list keeps all locations eligible. Blank and duplicate allowlist entries
are rejected before stock or UOM reads. A preferred location outside a
nonempty allowlist is invalid. Priority entries outside the allowlist are
ignored. Safety stock is deducted across the full plant inventory before the
allowlist filters allocation candidates. The base location allocator and its
unit-aware and ATP forms also accept `it_request_locations`. Each request's
locations intersect the shared allowlist; blank, unknown, or duplicate scope
rows and preferred locations outside the scope fail before stock or UOM reads.
The unit-aware adapter maps scopes through internal demand IDs and restores the
caller rows in its result; the ATP forms preserve them in their local estimates.
Priority and UOM-priority allocators, including the priority ATP adapter, accept
the same scope rows and apply them after mapping each priority demand to its
internal allocation ID. Date-first location and UOM allocators also enforce
scopes when projected receipts add stock to a location; their ATP adapters
preserve the caller-facing rows.
Single-plant location allocation sums available stock, allocated totals, and
matching projected receipt balances with checked high-precision arithmetic.
An aggregate outside the `MARD-LABST` range raises
`ZCX_INVALID_STOCK_REQUEST` before the preview returns.
The same `it_location_priority` and `it_allowed_storage_locations` options are
available on sales-order preview and reservation, cost-center location, exact-
batch, and FEFO previews, atomic cost-center reservations, and single
cost-center preview/reservation. A demand's preferred location stays first.
Exact-batch allocations remain within the selected batch; FEFO keeps expiration
and batch order, using location priority only to break ties for the same batch
and expiration date.
`ALLOCATE_LOCATION_PRIORITY` allocates shared single-plant location stock by
descending integer demand priority; ties preserve input order. Its UOM variant
`ALLOCATE_LOCATION_UOM_PRIORITY` returns quantities in both base and source
units. Both keep the existing preferred-location and fallback rules, location
ordering, allowlists, safety-stock policy, and full-quantity option. Summaries
and location splits return in caller order and echo each priority; repeated
request IDs are supported. `ALLOCATE_LOCATION_UOM_ATP_PRIO` adds a grouped
plant-level ATP check (with an optional check date) without changing the local
location split. `ALLOCATE_LOCATION_BY_DATE` and its UOM form accept the same
request-specific ranks. The dated ATP forms forward them to their local
estimate; with projected receipts, ranks order locations after receipts become
available for each demand date.
`GET_UNRESTRICTED_STOCK` requires both a material and plant key. It validates
`iv_protect_safety_stock` as `abap_true` or `abap_false` before reading.

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
Repeated material/unit ratios are read once per allocation call. Unit conversions reject overflow and nonzero source quantities that round to zero at MARD-LABST precision.
The single-request, base, unit-aware, priority, and ATP variants also accept
`it_excluded_reservations`. Each key must be complete and unique. Matching open
standard-stock RESB rows are omitted from the material/plant reservation net
for the full call, so the released quantity is shared by matching demands.
UOM variants validate the keys before conversion or stock reads. This is a
planning override and does not close or update SAP reservations.
Single-plant storage-location base, priority, UOM, dated, and ATP allocators
accept the same keys and forward them into location stock status reads. Matching
open RESB rows are omitted from location-level reservation deductions for the
material/plant. The same call-wide option is also accepted by single-plant
unrestricted-stock exact-batch and FEFO allocators and their priority, UOM, and
ATP variants. Matching open reservation rows are omitted from batch stock
netting for the material/plant; UOM paths validate keys before conversion.
Cross-plant undated base, UOM, priority, and ATP allocators accept the same
call-wide option and apply the keys to matching source material/plant balances.
`ALLOCATE_REQUEST`, `ALLOCATE_DEMANDS`, and their unit-aware variants accept
`iv_require_full_quantity`, defaulting to `abap_false`. When enabled, a demand
is allocated only when its full base-unit quantity is available after safety
stock protection. A short demand gets zero allocation and leaves that stock
available to later input rows. The single-request and bulk dated methods also
accept the flag, including unit and ATP wrappers; dated requests use the same
all-or-nothing rule after receipts, reservations, and safety-stock protection
are applied. In ATP variants, the flag changes the local estimate; ATP still
checks the requested quantities. Invalid flag values are rejected before
stock or unit-conversion reads. This remains a local estimate and does not
reserve stock. Ordinary base and UOM demand rows can set
`require_full_quantity = abap_true` individually; dated base and UOM rows do
the same through their ATP wrappers. Single-plant location and dated-location
demand rows also carry the per-row option into their base and UOM previews.
`ALLOCATE_REQUEST` and `ALLOCATE_REQUEST_IN_UNIT` accept scalar
`iv_minimum_coverage_pct`; base, UOM, priority, and ATP bulk demand rows use
`minimum_coverage_pct`. Both accept values from 0 to 100, and zero preserves
partial allocation. Each demand compares provisional base-unit coverage with
the requested percentage before consuming the shared material/plant balance.
A demand below the floor receives zero allocation and leaves stock available
to later demands. Results echo the threshold; unit-aware variants apply it
after conversion to base units. Local date-first single requests and base/UOM
demand rows accept the same threshold, including date-first ATP wrappers. The
floor is applied against eligible availability on the required date before the
shared balance is consumed, and the dated allocation summary echoes it.
Undated `ALLOCATE_BY_STORAGE_LOCATION` demand rows also accept
`minimum_coverage_pct`. The floor is compared after allowed locations, request
scopes, fallback rules, and safety-stock protection determine eligible
base-unit availability. A rejected location demand consumes no location
balance, so later demands can use it; UOM, priority, and ATP wrappers preserve
the row threshold.
`ALLOCATE_LOCATION_BY_DATE` and its UOM and ATP forms accept the same row
threshold. With projected receipts, the service compares coverage using stock
available by that demand's required date after earlier demands have consumed
their share. A rejected dated demand leaves that balance for later requests.
Exact-batch, FEFO, and quality FEFO demand rows also accept
`minimum_coverage_pct` from 0 through 100. Their base, UOM, priority, and ATP
forms compare the floor with eligible base-unit stock after batch, expiry,
shelf-life, location, receipt-date, and safety-stock rules. A row below its
floor consumes no stock, and later demands can use the balance. FEFO summaries
and batch splits echo the floor; UOM conversion does not affect the comparison.
`PREVIEW_BY_VALTYPE` base and UOM demand rows accept the same floor. It is
compared with eligible base-unit availability after valuation-type, location,
batch, projected-source, expiry, receipt-date, and safety-stock scopes. A row
below its floor consumes no balance, and its allocation summary echoes the
threshold; UOM and ATP wrappers preserve it.
Cross-plant ordinary, priority, UOM, and dated demands also accept the
per-row floor. It is compared with combined eligible source-plant availability
after location, receipt, cutoff, and safety-stock rules; a rejected row
preserves every source balance for later demands. Date-based previews evaluate
availability at each required date, and UOM and ATP wrappers preserve the
threshold.
Shared material/plant, location, batch, FEFO, and cross-plant ordinary, dated,
exact-batch, and FEFO allocation summaries report `allocation_outcome`: `F`
for full coverage, `P` for partial coverage, or `U` when no quantity was
allocated. They also report `allocation_coverage_pct`, the allocated quantity
as a percentage of requested quantity in base units, rounded to two decimal
places. It is zero when requested quantity is zero. Unit-aware, priority, and
ATP results preserve both values on their local allocation summary. Local
date-first request and demand allocations report the same outcome and
percentage, and their UOM and ATP results preserve them from base quantities.
`ALLOCATE_BY_STORAGE_LOCATION`, `ALLOCATE_BY_BATCH`, and `ALLOCATE_BY_EXPIRY`
also accept `iv_require_full_quantity`, as do their unit-aware variants. The
request must fit within eligible stock after location filters, safety-stock
protection, exact-batch selection, and FEFO shelf-life checks are applied. A
short request gets zero allocation and leaves its stock available to later
demands. Unit-aware results report the full shortfall in both base and source
units.
`ALLOCATE_ACROSS_PLANTS` accepts base-unit demands and a caller-ordered source
plant list for each request. It reports availability, allocation, and shortfall
for the target plant, plus the amount assigned to each source plant and source
storage location. A source plant must differ from that request's target plant;
same-plant stock belongs in a local allocator, and a same-plant source is
rejected before stock reads. The optional `it_storage_location_priority` list orders
locations within each source plant; unlisted locations follow ascending
`LGORT`. With no list, the existing ascending order remains. Source-plant order
still takes precedence. Demand order consumes shared source-plant balances; each
material/source-plant stock balance is read once. The optional
`it_allowed_storage_locations` list filters candidates across every source
plant; an empty list leaves all locations eligible. The same option is
available on unit-aware, exact-batch, and FEFO cross-plant allocation. Safety
stock is deducted across each full source-plant balance before the allowlist
filters allocation candidates, and priority entries outside that list are
ignored. Exact-batch allocation uses the same location order within the
requested batch. The optional `it_source_locations` list scopes locations by
request and source plant across ordinary, exact-batch, and FEFO allocation. If
provided, each request/source-plant pair must have at least one listed
location; omitting it preserves unrestricted request/source routing, and a
provided scope further narrows the shared allowlist. The same options are
available on unit-aware variants. The optional `iv_protect_safety_stock` flag
subtracts static source-plant safety stock before location filters. This is an
allocation preview only; it does not reserve stock or post an interplant
transfer.
Cross-plant FEFO (standard and date-first) and exact-batch allocation use
checked high-precision sums for merged projected receipts, eligible
availability, and source-plant allocation summaries. Totals outside the
`MARD-LABST` range raise `ZCX_INVALID_STOCK_REQUEST` before returning.
The base, UOM, priority, and ATP allocators also accept
`it_request_location_priorities`. Positive per-request ranks override the
shared location order within each source plant; unranked locations follow in
ascending location code, while caller source-plant order remains primary. The
dated location, dated UOM, and dated ATP forms accept and forward the same
rows. UOM forms validate request IDs before conversion reads, and invalid rank
rows fail before stock reads.
Use `ALLOCATE_PLANTS_PRIORITY` or `ALLOCATE_PLANTS_UOM_PRIORITY` when
undated ordinary demands share source-plant balances and need explicit
precedence. Higher integer priorities allocate first; stable input order breaks
ties. Source-plant ordering still applies within each demand, and all summaries
and source/location splits return in caller order with priority echoed. These
methods preserve projected receipts and per-request receipt cutoffs. The UOM
form rejects duplicate IDs before conversion and returns source and base-unit
quantities. `ALLOCATE_PLANTS_UOM_ATP_PRIO` adds grouped, current-date ATP checks
by material, source plant, and base unit; ATP does not change the local split.
These undated cross-plant allocation methods and their unit-aware variants
accept `iv_require_full_quantity`. It defaults to `abap_false`, preserving
partial allocations. When enabled, a request is allocated only if its entire
quantity is available after the selected source plants, location scopes,
allowlist, safety-stock protection, exact-batch restriction, and FEFO
eligibility are applied. Otherwise the request receives zero allocation, its
full quantity is reported as shortfall, and its balances remain available to
later requests. The ATP wrapper checks only positive local allocations, so a
request rejected by this local policy produces no ATP call. This is still a
preview policy, not an atomic SAP reservation.
Undated ordinary, exact-batch, and FEFO cross-plant base and unit-aware demand
rows can also set `require_full_quantity = abap_true` individually. The
row flag combines with the shared option, leaves source balances untouched when
that request is short, and is forwarded through the corresponding ATP wrappers.
Invalid row values are rejected before stock reads or UOM conversion.
Ordinary cross-plant rows can also set a minimum coverage floor from zero
through 100. It uses combined eligible availability from the selected source
plants after location scopes, projected-receipt cutoffs, and safety-stock
protection. A rejected row consumes no source balance; priority, UOM, and ATP
adapters carry the threshold and allocation summaries echo it.
Cross-plant exact-batch and FEFO demands, including date-first variants, accept
the same floor. Their combined source-plant availability reflects exact-batch,
expiry, shelf-life, location, projected-receipt, and safety-stock eligibility.
A rejected demand leaves those batch balances for later requests. Base, UOM,
priority, and ATP adapters preserve the value, allocation summaries echo it,
and FEFO batch splits retain the floor.
`ALLOCATE_PLANTS_ATP` adds a current-date SAP ATP comparison to the
unit-aware cross-plant preview. It groups positive local source allocations by
material, source plant, and base unit, then checks each group once with the
supplied `iv_check_rule`. The result keeps the local location splits and reports
the grouped ATP result plus confirmed and unconfirmed base quantities and
`is_fully_confirmed`; the flag is false when SAP marks the check not relevant.
ATP does not change the local allocation or resolve its shortfalls.
`ALLOCATE_PLANTS_FEFO_ATP` adds the same current-date ATP comparison to
undated cross-plant FEFO allocations. It preserves source-plant and batch/location
splits from the local FEFO estimate, and groups positive allocations by material,
source plant, and base unit for ATP checks. ATP remains a plant-level diagnostic;
it does not confirm a selected batch or change its FEFO allocation. When
`it_projected_batch_receipts` is supplied, those rows affect the local estimate
only; the SAP ATP request does not carry the caller's receipt assignments.
`ALLOCATE_PLANTS_BY_DATE` adds required dates and uses the same caller-ordered
source plants. Earlier demands consume shared material/source-plant balances
before later dates. The integer `priority` defaults to zero; within the same
date, higher values allocate first and input order breaks ties. A later date
cannot outrank an earlier requirement. Each demand keeps its caller-ordered
source plants, and results return in input order with priority and source-plant
splits. It supports the dated PO, issued or unissued STO, and production receipt
projections plus source safety-stock protection. This is a planning estimate
and does not return storage-location splits or create a transfer because
projected receipts have no storage-location assignment. All unique
material/source-plant/date availability scopes are fetched in one repository
bulk call; confirmation receipts remain a separate batched read.
`ALLOCATE_PLANTS_BY_DATE_LOC` applies the same date and priority ordering to
location stock and returns the actual source-plant and storage-location splits
in caller order. It supports source-plant order, source-location scopes,
location priority, allowlists, safety-stock protection, and full-quantity
allocation. Each demand row can also set `require_full_quantity = abap_true`;
it combines with the shared option and passes through the unit and ATP
wrappers. Invalid row flags fail before stock reads or UOM conversion. Its
demands also accept a minimum coverage floor. Coverage uses eligible stock by
the required date, including projected receipts, before any source balance is
consumed. Rejected rows preserve the balance, and allocation summaries echo
the floor through UOM and ATP wrappers. The planning-source date method applies
the same floor to its date-scoped availability and carries it through UOM and
ATP forms. The optional `it_projected_receipts` input accepts caller-resolved
material, source plant, storage location, receipt date, and base-unit quantity.
Receipts become available on their receipt date, are shared with later
demands, and first replenish any remaining static safety-stock buffer.
Each returned location split also carries `available_from_date`: posted stock
leaves it initial, while projected supply reports its receipt date. The date is
preserved by priority, dated, UOM, and ATP result adapters. Multiple splits can
repeat a location when posted and projected balances both contribute; each
split's quantities refer to its own date balance. Projected receipt rows can
also provide `source_type`, `source_document`, `source_item`, `source_plant`,
and `source_schedule_line` under the same pairing rules as the single-plant
location allocator. Cross-plant location results echo these on the nested
allocation; `receipt_source_plant` identifies the receipt source plant while
`source_plant` continues to identify the stock source plant. Rows with matching
source metadata and date are combined.
`ALLOCATE_PLANTS_DATE_LOC_UOM` accepts the same dated location-aware
cross-plant demands in material-specific units. It preserves date and priority
ordering, caller-order summaries and splits, and returns demand, source-plant,
and location quantities in both source and base units. Repeated material/unit
ratios are read once per call; base-unit quantities remain canonical when a
converted split rounds to the quantity field's precision. It accepts the same
optional `it_projected_receipts` input; receipt quantities remain in base units.
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
`ALLOCATE_PLANTS_DATE_LOC_ATP` adds these cumulative checks to dated,
unit-aware cross-plant allocations with storage-location splits. It checks only
positive source-plant allocations, groups them by source plant and required
date, and retains the caller-order local demand, plant, and location results.
It accepts the same optional base-unit `it_projected_receipts` input as the
local location allocator. ATP remains diagnostic and does not change the local
location allocation.

Dated cross-plant base, UOM, and ATP allocators also accept
`it_excluded_reservations`. Each key must be complete and unique. Matching
open standard-stock reservation rows are omitted from RESB netting for the
allocation call, so their released quantity is shared by demands using the same
source material and plant. Only rows in queried source material/plant scopes
can affect the result. The ordinary dated availability query still applies its
required-date cutoff; the location-aware query uses the open reservation rows
in its location stock status. This is a planning override and does not change
or close SAP reservations.
Same-plant and cross-plant unrestricted-stock exact-batch and FEFO base, UOM,
priority, and ATP allocators accept the same call-wide keys. They validate keys before UOM
conversion, then apply them to matching source material/plant batch balances;
expiry, exact-batch, location, and source-plant eligibility rules still apply.

ATP groups and cumulative requests use checked high-precision sums. If a grouped
quantity exceeds the `MARD-LABST` range accepted by the SAP ATP interface, the
service raises `zcx_invalid_stock_request` before making the ATP call.
The dated ordinary cross-plant methods and their unit/ATP variants also accept
`iv_require_full_quantity`. It defaults to `abap_false`; when enabled, each
date/priority-ordered request consumes stock only when its full quantity is
available at that point in the shared allocation. A short request allocates
zero and leaves stock available to later requests. Dated ATP checks are made
only for positive local allocations. Base and unit-aware demand rows can also
set `require_full_quantity = abap_true` individually; this combines with the
shared option, and invalid row values are rejected before stock reads or UOM
conversion. ATP wrappers preserve the row policy.
`ALLOCATE_PLANTS_IN_UNITS` accepts material-specific demand units and returns
the demand summary plus plant and location splits in both the source unit and
base unit. It caches and validates material/unit ratios before reading stock.
Base-unit quantities remain canonical when a converted split rounds to the
quantity field's precision.
`ALLOCATE_PLANTS_BY_BATCH` keeps the caller-selected batch fixed while
allocating across the ordered source plants. It returns plant and source
location splits with batch and expiration details, and never substitutes stock
from another batch. It loads current batch status for all unique
material/source-plant pairs with one bulk repository call. Caller-resolved
`it_projected_batch_receipts` can add
dated quantities for the exact material, source plant, and batch. The undated
method uses each demand's optional `as_of_date` (defaulting to today), consumes
shared balances by ascending cutoff date with input order breaking ties, and
returns demand summaries in that processing order. The date-prioritized method
uses its `required_date`. A positive per-demand `minimum_shelf_life_days`
filters out the batch when its expiry is unknown or falls before the cutoff
plus the requested shelf life. The base demand method requires `as_of_date`
when this minimum is positive; its undated UOM wrapper uses today, while the
date-prioritized method uses `required_date`. Due receipts can replenish a
remaining source-plant safety-stock buffer. The UOM and ATP wrappers forward
receipts and shelf-life requirements; ATP still does not confirm the local
batch split. Either method can protect each source plant's static safety
stock. `iv_include_undated_batches` defaults to `abap_true`; set it to
`abap_false` to exclude current or projected exact-batch quantities with no
known expiry, even when no minimum shelf life is requested. Date, UOM, and ATP
wrappers forward the option, and invalid values are rejected before UOM or
stock reads. Base and unit-aware exact-batch demand rows can also set
`require_full_quantity = abap_true`; the row policy combines with the shared
option and passes through the ATP wrapper. Base, dated, unit-aware, priority,
and ATP demand rows can set `require_known_expiry = abap_true` to reject
undated stock for just that request, even when the shared option is inclusive.
The result summary and any location split echo this policy. Each location split
also reports `available_from_date`: it is initial for posted stock and contains
the receipt date for projected supply, including date-first, priority, UOM, and
ATP results. Invalid row values are rejected before stock reads or UOM
conversion.
Cross-plant exact-batch methods also accept `it_request_location_priorities`.
Within each source plant and selected batch, the request's positive local ranks
override the shared location order; unranked locations follow by location
code. The caller's source-plant order remains primary. Dated, UOM, priority,
and ATP variants forward the same ranks, and UOM forms validate request IDs
before conversion reads.
Use `ALLOCATE_PLANTS_BATCH_PRIORITY` or `ALLOCATE_PLANTS_BATCH_UOM_PRIO` to
order requests that share exact-batch stock. Both demand types accept an
`as_of_date`; blank dates use today. Earlier dates consume shared batch stock
first, then higher integer priority consumes first for same-date requests, with
input order breaking ties. Summaries, source-plant rows, and location splits
return in caller order and echo priority. Request IDs must be unique.
`ALLOCATE_PLANTS_BATCH_UOM_ATP` groups positive source allocations by material,
source plant, base unit, and demand as-of date while preserving the local split.
`ALLOCATE_PLANTS_BATCH_ATP` adds a SAP ATP comparison to the unit-aware
exact-batch cross-plant preview. It groups positive source splits by material,
source plant, base unit, and demand `as_of_date`; blank dates use today. It
preserves the caller's batch and storage-location allocations. ATP confirmation
is reported separately and does not change the local split or reserve stock.
`ALLOCATE_PLANTS_BATCH_IN_UNITS` accepts the same exact-batch demand in a
material-specific alternative unit. It validates and caches conversion ratios
before reading stock and returns demand, plant, and location splits in both
units; base-unit quantities remain canonical when converted amounts round.
`ALLOCATE_PLANTS_BATCH_BY_DATE` adds required-date ordering and integer priority
to exact-batch cross-plant allocation. Earlier dates consume shared batch stock
first; higher priority values run first within a date, with input order breaking
ties. Results return in caller order with date, priority, batch, plant, and
location details. `ALLOCATE_PLANTS_DATE_BATCH_UOM` accepts these dated requests
in material-specific units and validates conversions before stock reads. Both
undated and dated exact-batch base/UOM demand rows can set
`require_full_quantity = abap_true`; the row policy combines with the shared
option and is forwarded through ATP wrappers. Invalid row values fail before
stock reads or UOM conversion.
`ALLOCATE_PLANTS_DATE_BATCH_ATP` adds cumulative SAP ATP checks by material,
source plant, base unit, and required date for positive local allocations.
Priorities govern the local stock split; SAP ATP checks combine allocations
with the same date. ATP remains diagnostic and does not change the local batch
allocation.
`ALLOCATE_PLANTS_BY_EXPIRY` applies FEFO across caller-ordered source plants.
The source-plant order takes priority between plants, and eligible batches are
then consumed by earliest expiration date within each plant. Batch order stays
ahead of location priority; the optional `it_storage_location_priority` list
breaks ties between locations holding the same batch with the same expiration
date. It accepts an as-of date and minimum remaining shelf life, returns source
plant and batch/location splits, and can protect static safety stock at each
source plant. Undated batches are excluded when the minimum shelf life is
greater than zero. Set `require_known_expiry = abap_true` on an individual
demand to exclude batches without an expiry date for that row even when the
shared `iv_include_undated_batches` option is true. Ordinary allocators that
share these demand structures reject set expiry-policy flags before reading
stock. Set
`allow_undated_batches = abap_true` to opt one row into undated stock when the
shared option is false. The two row flags cannot both be true. Demand summaries
and selected batch splits echo both flags; each defaults to false. This is a preview
based on local stock estimates and does not run SAP batch determination or
create a transfer.
Stock for all unique material/source-plant pairs is loaded through one bulk
repository call before the FEFO split is built.
Use `ALLOCATE_PLANTS_FEFO_PRIORITY` or `ALLOCATE_PLANTS_FEFO_UOM_PRIO` when
undated demands sharing source-plant stock need explicit precedence. A higher
integer priority consumes eligible stock first; input order breaks ties. FEFO
and source-plant ordering still apply within each demand. Summaries, source
plant allocations, and batch splits return in caller order and echo priority.
Request IDs must be unique. The UOM method accepts alternative units and
returns quantities in both source and base units. `ALLOCATE_PLANTS_FEFO_UOM_ATP`
adds cumulative source-plant ATP checks in the material base unit; ATP reports
availability separately and does not change the priority-based local split.
These methods produce local previews and do not reserve stock.
It also accepts caller-resolved `it_projected_batch_receipts` with material,
source plant, storage location, batch, optional expiration date, receipt date,
and base quantity. Only rows dated on or before `iv_as_of_date` enter the
snapshot; later rows are ignored. Included receipts share the same FEFO,
shelf-life, location-filter, and safety-stock rules as current stock. The
unit-aware and ATP variants forward these rows in base units. The caller must
supply the quantity still expected to be available at the snapshot date; the
method does not derive receipts or intervening issues from SAP documents.
Cross-plant FEFO batch splits report `available_from_date` through base,
priority, date-first, unit-aware, and ATP results. Posted stock leaves it
initial; projected split balances retain their individual receipt dates, even
when they share a batch and location with posted stock or another receipt.
`ALLOCATE_PLANTS_BY_EXPIRY`, `ALLOCATE_PLANTS_FEFO_BY_DATE`, and their
unit-aware and ATP variants also accept `iv_include_undated_batches`, defaulting
to `abap_true`. It is the default for each demand row. Set it to `abap_false`
to exclude undated batches, then set `allow_undated_batches = abap_true` only
on rows that opt back in. `require_known_expiry = abap_true` excludes undated
batches for its row regardless of the shared setting. Invalid or conflicting
flags are rejected before UOM or stock reads.
`ALLOCATE_PLANTS_FEFO_BY_DATE` combines that cross-plant FEFO split with dated
demand priority. Earlier required dates consume shared batches first. Within
the same date, higher integer `priority` values consume shared batches first;
the default zero keeps input order, which also breaks equal-priority ties.
Results still return in input order with priorities on demand and batch splits.
Current batch stock for all unique material/source-plant pairs is fetched in one
bulk repository call before the FEFO balances are built.
Each batch must meet the requested minimum shelf life as of that demand's
required date. Set `require_known_expiry = abap_true` on a row to exclude
undated batches for that demand. A row can set `allow_undated_batches = abap_true`
to opt into undated stock when the shared `iv_include_undated_batches` option is
false; the two row flags cannot both be true. Both policies flow through the
unit-aware and ATP variants and are echoed in demand and split results.
`it_storage_location_priority` breaks ties between locations
holding the same batch and expiration date without changing demand, source-plant,
expiry, or batch order.
Optional safety-stock protection withholds the buffer from latest-expiring
batches eligible for the earliest compatible demand. Undated batches qualify
only when `iv_min_days = 0` and sort after dated batches. The base-unit method
also accepts caller-resolved `it_projected_batch_receipts`, containing material,
source plant, storage location, batch, optional expiration date, receipt date,
and base quantity. A receipt enters the shared FEFO balance on its receipt date;
the usual expiry, shelf-life, source-location, allowlist, and safety-stock rules
still apply. The UOM and ATP variants forward the same base-unit receipt table.
Callers must resolve receipt quantities, plants, locations, and batch expiry
from their planning data; the method does not run SAP batch determination or
replace SAP's configured batch strategy.
`ALLOCATE_PLANTS_FEFO_BY_DATE` and its unit-aware and ATP variants also accept
`iv_require_full_quantity`. The request must be fully coverable by batches that
meet its shelf-life requirement at its required date after source-location and
allowlist filters; a rejected short request leaves those batches available to
later dated demands. Each base and unit-aware demand row can also set
`require_full_quantity = abap_true`; this combines with the shared option and
is forwarded through the ATP wrapper. Invalid row values fail before stock
reads or UOM conversion.
Each cross-plant FEFO demand can set `minimum_shelf_life_days`; the greater of
that value and the shared `iv_min_days` is applied to that demand and returned
on its batch split. The base-unit, dated, unit-aware, and ATP variants forward
the per-demand value. Ordinary cross-plant allocators that share these demand
types reject a nonzero value because they do not evaluate batch expiry.
All dated cross-plant FEFO variants accept an optional shared
`it_allowed_storage_locations` allowlist. When supplied, stock from every other
storage location is excluded for all requests and source plants; an empty list
keeps the unrestricted location behavior. They also accept the optional
`it_storage_location_priority` list for same-batch, same-expiration location
ties; priority entries outside the allowlist have no effect.
For request-specific routing, `it_source_locations` maps each request and source
plant to its permitted storage locations. Every request/source-plant pair needs
at least one mapping when this table is supplied. If both location filters are
present, the selected stock must satisfy both.
`ALLOCATE_PLANTS_BY_EXPIRY`, `ALLOCATE_PLANTS_FEFO_BY_DATE`, and their UOM,
priority, and ATP variants also accept `it_request_location_priorities`. These
request/location ranks override the shared location order only within the same
source plant, expiry date, and batch. Earlier-expiring batches and the caller's
source-plant order remain primary; locations without a request rank follow the
ranked locations by storage-location code. The UOM methods validate request IDs
and ranks before conversion reads, and ATP wrappers forward the same rows.
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
amounts round. The dated unit-aware FEFO and ATP methods accept the same optional
location priority and apply it only to same-batch, same-expiration ties.
`ALLOCATE_BY_LOCATION_IN_UNITS` accepts demands in material-specific units and
shares storage-location balances across input rows. It preserves the existing
preferred-location and fallback behavior, returns base-unit summaries, and
includes each location split in both base and source units. It accepts the same
optional `it_storage_location_priority` list as the base-unit method.
`ALLOCATE_LOCATION_BY_DATE` accepts base-unit location demands with required
dates and priorities. Earlier dates consume shared locations first; higher
priority wins within a date and input order breaks ties. It returns allocation
summaries and location splits in caller order, and supports the same location
priority, allowlist, safety-stock, and full-quantity options. Its optional
`it_projected_receipts` input adds caller-resolved future supply by material,
plant, storage location, and receipt date; quantities are in the material base
unit. A receipt is available on its receipt date and is shared with later
demands. When safety-stock protection is enabled, receipts first replenish any
uncovered static plant buffer. Each returned `storage_allocation` also carries
`available_from_date`: it is initial for posted stock and contains the receipt
date for projected supply. The date is preserved by the UOM and dated ATP
adapters. A location can appear in multiple split rows when more than one
availability-date balance contributes; each row's available and allocated
quantities refer to its own date balance.
Projected receipt rows can optionally include source metadata. Set
`source_type` and `source_document` together; `source_item`, `source_plant`, and
`source_schedule_line` require a source document. The nested storage allocation
echoes those fields. Receipts at one location/date with the same metadata are
combined; different metadata stays in separate splits.
`ALLOCATE_LOCATION_BY_DATE_UOM` adds required dates and integer priority to
these location demands. Earlier dates consume shared location balances first;
higher priorities win within the same date, with input order breaking ties.
Results include dates and priorities and return in caller order. It accepts the
same optional `it_projected_receipts` input as the base-unit allocator. Receipt
quantities remain in the material base unit even when demands use another unit.
`ALLOCATE_LOCATION_DATE_UOM_ATP` adds cumulative ATP checks for positive local
allocations, grouped by material, plant, base unit, and required date. The ATP
quantity for a later date includes earlier local allocations in that group;
zero local allocations do not trigger a check. It also accepts the same optional
base-unit `it_projected_receipts` input. The result remains a comparison preview
and does not reserve stock.
`ALLOCATE_LOCATION_DATE_ATP` provides the same diagnostic for quantities
already expressed in base units. Set `base_unit` on each dated demand so the
ATP request uses the material's base unit; rows sharing a material, plant, unit,
and date are combined before checking, and later checks include earlier local
allocations. It accepts the same `it_projected_receipts` input as
`ALLOCATE_LOCATION_BY_DATE`.
`ALLOCATE_BY_LOCATION_ATP` returns that local estimate with ATP checks for
positive allocations, grouped by material, plant, and base unit using the
optional `iv_atp_check_date`, which defaults to the current date. The local
estimate still uses current stock. A full-quantity shortfall produces no ATP
check when the local estimate allocates zero. ATP results are diagnostic and
do not reserve stock.

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
uses the material's `MARA`/`MARM` ratio. Stock-service unit conversions reject
overflow and nonzero quantities that round to zero at `MARD-LABST` precision.
`GET_STOCK_STATUS_BULK_IN_UNIT` accepts keyed material/plant/unit requests and
returns the same status fields in each requested unit. It preserves request
order, caches ratios by material/unit, and performs one bulk plant-status read.
Blank fields, duplicate request IDs, or unknown units raise
`ZCX_INVALID_STOCK_REQUEST` before stock is read; empty input returns without a
repository read.
`GET_STOCK_STATUS_BULK` accepts multiple uniquely keyed material/plant pairs
and returns each plant status in the same order as the requests. It reads the
MARD, RESB, and MARC data through one repository call, making it suitable for
callers that need repeated plant status checks. Blank keys, duplicate request
IDs, or an incomplete repository response raise
`ZCX_INVALID_STOCK_REQUEST`; an empty request returns an empty result without a
repository read.
`GET_OPEN_STOCK_RES_BULK` returns each request's matching open RESB rows and
accepts an optional `iv_required_through_date`. Later dated reservations are
excluded while undated rows remain; the date is validated before reads, pushed
into the repository query, and applied again by the service.
`GET_OPEN_STOCK_RES_REQ_BULK` accepts unique request IDs with one cutoff per
material/plant request. It groups reads by date, returns each cutoff with its
reservation rows, and restores results in request order. IDs, keys, and dates
are validated before the first read; empty input returns without a repository
call.
`GET_OPEN_STOCK_RES_UOM_BULK` adds a requested unit to each keyed request and
returns required, withdrawn, and open reservation quantities in both the base
and requested units, with the base and requested units and cutoff. It caches
ratios by material/unit, validates all ratios before reservation reads, and
preserves request order while reusing the date-grouped bulk reader.
`GET_OPEN_STOCK_RES_UOM` provides the same row shape for one material, plant,
unit, and optional cutoff by delegating to the keyed bulk method.
`GET_LOCATION_STOCK_STATUS_BULK` accepts the same keyed requests and returns a
location breakdown for each material/plant pair in request order. Each nested
location row includes unrestricted, quality-inspection, and blocked stock plus
available unrestricted stock after the existing deterministic reservation
distribution. It keeps each open RESB row through allocation so large totals do
not overflow an intermediate reservation quantity. Its input validation and
empty-request behavior match `GET_STOCK_STATUS_BULK`.
`GET_LOCATION_STOCK_BULK_UOM` adds a requested unit to each keyed request and
converts every location quantity while preserving its storage-location key.
It retains zero-available locations, caches ratios by material/unit, and uses
one bulk location read for the whole request set.
`GET_STOCK_STATUS`, `GET_STOCK_STATUS_BY_LOCATION`, and
`GET_STOCK_STATUS_BY_BATCH` require both a material and plant key. A blank key
raises `ZCX_INVALID_STOCK_REQUEST` before the repository read.
`GET_SALES_ORDER_RESERVATIONS` rejects a blank sales-document key, and
`GET_ORDER_RESERVATIONS_BULK` rejects blank entries. Both accept an optional
call-wide `iv_required_through_date`; later dated reservation rows are omitted,
undated rows remain, and the cutoff is validated before reads and reapplied by
the service. An empty bulk request returns an empty result without reading the
repository. Returned rows must carry unique, nonblank RESB reservation number
and item keys and must belong to a requested sales document; malformed
repository rows raise `ZCX_INVALID_STOCK_REQUEST`.
`GET_ORDER_RES_BULK_UOM` accepts keyed sales-document, material, plant, and unit
requests and returns matching open reservation rows in that unit, with both
base and requested unit codes. Each reservation row includes the RESB
`reservation_number` and `reservation_item` for traceability, plus storage
location and batch. Each reservation row includes `base_open_quantity` and
converted `open_quantity`, as well as `required_quantity`,
`withdrawn_quantity`, and `open_quantity` in the requested unit. It also
returns `base_required_quantity`, `base_withdrawn_quantity`, and
`base_open_quantity`, so quantities can be reconciled in the base unit.
request may specify a
`required_through_date`; later dated rows are omitted and undated rows remain.
Cutoffs are validated before reads and echoed in each result. The method caches
ratios by material/unit, preserves request order, and reads all distinct sales
documents once. Blank keys, duplicate request IDs, and unknown units are
rejected before the reservation read; empty input returns without a repository
read.
`GET_ORDER_RES_UOM` returns the same unit-aware result for one sales-document,
material, and plant key by delegating to the bulk method; its optional
`iv_required_through_date` follows the same cutoff rules.
`ALLOCATE_REQUEST_BY_DATE` estimates a single material/plant allocation for a
required date. It subtracts active unrestricted reservations due on or before
that date, including reservations without a requirement date, and returns the
available quantity, allocation, and shortfall. Optional static safety-stock
protection works like the other plant allocation methods. Set
`it_excluded_reservations` to omit selected active standard-stock reservation
items from the RESB netting used by the preview. Each key must have a
reservation number and item, and keys must be unique. The dated single, bulk,
unit, and ATP wrappers forward the same call-wide key list. Invalid keys raise
`ZCX_INVALID_STOCK_REQUEST` when incomplete or duplicated; unknown or closed
keys do not match an active row and have no effect. Same-plant single-request,
multi-demand, unit, and ATP methods forward this call-wide option. It does not
modify reservations.
`iv_include_po_receipts = abap_true` to add remaining standard stock PO schedule
quantities due by that date, converted from the PO unit to the base unit. This
excludes PO items marked for quality-inspection or blocked stock. The actual
goods receipt can still use a different stock type, so treat this as a local
projection rather than SAP ATP or a historical stock reconstruction.
Set `iv_include_po_confirmations = abap_true` to use the confirmation-aware PO
schedule and supplier-confirmation projection instead. The PO flags are
mutually exclusive. `ALLOCATE_DEMANDS_BY_DATE` batches availability reads across
its unique material/plant/date scopes and groups confirmation reads by
material/plant through the latest demand date. It adds only receipts due by
each demand date before sharing the resulting stock across demands. Unit and
ATP dated-allocation methods, including cross-plant source allocation, pass this
option through to the same local estimate. Cross-plant reads group by
material/source plant through the latest mapped demand date.
The date-first allocators also maintain cumulative allocated quantities per
material and plant while sharing stock across dates. These packed totals use
checked high-precision addition and raise `ZCX_INVALID_STOCK_REQUEST` if they
exceed `MARD-LABST` range.
`ALLOCATE_REQUEST_BY_DATE` uses the same bulk repository implementation with a
single keyed request, preserving excluded-reservation keys while keeping its
receipt filters consistent with bulk dated allocation.
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
PP production orders and process orders whose basic finish date is on or before
the requested date. Receipt rows use source types `PRODUCTION` and
`PROCESS_ORDER`, respectively. The estimate excludes make-to-order and
completed order items; production output may still be delayed or posted to a
different stock type.
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
assumptions before acting on it. `SUGGEST_COMP_REPL_FROM_STOCK` combines those
calls and accepts the same resolved lot-size periods: it loads the selected
receipt types once per material/plant through the latest shortage date, then
nets eligible receipts by required date before applying the period grouping.
Rows with negative received, ordered, issued, or MRP-reduced counters contribute
no projected quantity, so malformed source counters cannot increase availability.
Set `iv_include_po_confirmations = abap_true` to include confirmation-aware PO
receipts in this netting. This option is mutually exclusive with
`iv_include_po_receipts`, since both project the same PO supply. The helper
groups confirmation requests by material/plant through the latest shortage date
and applies each confirmation by its expected receipt date.
`GET_PO_CONFIRMED_RECEIPTS` provides a confirmation-aware alternative for
standard stock purchase orders. It returns the unconfirmed schedule remainder
as `PO` rows and open MRP-relevant supplier confirmations as
`PO_CONFIRMATION` rows, all in the material base unit. Use this method instead
of `iv_include_po_receipts` in `GET_PROJECTED_RECEIPTS`. The general projected
receipt methods also accept `iv_include_po_confirmations = abap_true` to add
this projection directly, including their unit and bulk variants. The two PO
flags are mutually exclusive because both include the PO schedule remainder.
SAP stores vendor confirmations in
EKES and marks MRP-relevant confirmation rows with `KZDIS`; the method nets
`EKES-DABMG` and `EKET-DABMG` values that SAP maintains for confirmation
sequence reduction ([confirmation fields](https://help.sap.com/saphelp_SCM700_ehp02/helpdata/en/b0/487053bbe77c1ee10000000a174cb4/content.htm?no_cache=true),
[reduced-quantity sequence behavior](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362168302.html)).
The method still projects expected supply; it does not run SAP ATP.
`GET_PROJECTED_RECEIPTS_IN_UNIT` returns the same dated source rows with each
quantity converted to a requested material unit. It preserves source identity
and returns both base and requested units; receipt-source flags and filters are
the same as `GET_PROJECTED_RECEIPTS`.
`GET_PO_CONF_RECEIPTS_IN_UNIT` applies the same material-specific conversion
to confirmation-aware PO rows and preserves `PO`/`PO_CONFIRMATION` source
identity.
`GET_PO_CONF_RECEIPTS_BULK` accepts uniquely keyed material/plant/deadline
requests, batches schedule-line and confirmation reads across the requested
material/plant pairs, and filters each result to its request's horizon. Its
`_UOM` variant converts receipts to each requested unit and reuses conversion
ratios by material/unit.
`GET_PROJECTED_RECEIPTS_BULK` accepts uniquely keyed material/plant/deadline
requests with shared receipt-source flags, including
`iv_include_po_confirmations`. It returns one result per request in input order
and filters each receipt list to that request's deadline. Repeated
material/plant pairs share projections through their latest requested date.
The repository batches its purchase-order, scheduling-agreement, STO,
production, requisition, and planned-order reads across those pairs. Each query
uses that pair's latest deadline; returned receipts are then filtered to each
request's own date. The PO-confirmation path applies the same batching and
deadline rules to schedule remainders and confirmations.
Invalid keys or source flags are rejected before reads; empty input and requests
with no enabled receipt sources do not read the repository.
`GET_PROJ_RECEIPTS_OPTS_BULK` accepts source flags on each keyed request. It
accepts `include_po_confirmations` as an alternative to `include_po_receipts`,
unions enabled source types for each material/plant read through that pair's
latest deadline, then filters rows by each request's own source flags and date.
Pairs with matching source selections share one bulk repository call; PO
confirmations use their separate batched query. Requests sharing a pair may
select different PO projections; one request may not select both.
Results preserve input order; request groups with no enabled source types skip
the repository read.
`GET_PROJ_RECEIPTS_BULK_UOM` adds a requested material unit per keyed request
and returns converted receipt quantities with base/request unit codes. It
rejects duplicate request IDs before unit conversion, validates every ratio
before projection reads, and reuses both ratio and material/plant deadline
caches across the call.
`GET_PROJ_RECEIPTS_OPTS_UOM` combines per-request source selection with
per-request material units. It preserves the same grouped reads, source and
deadline filtering, request order, and base/request unit reporting.
`ALLOCATE_DEMANDS_BY_DATE` handles a list of dated requests with unique request
IDs. It allocates earlier requirements first, shares each material/plant
balance across dates, and uses input order for same-date requests by default.
The integer `priority` defaults to zero; a higher value allocates that request
before lower-priority requests with the same material, plant, and required date.
Earlier required dates always take precedence; input order breaks equal-priority
ties. Each result echoes the request priority while results remain in input
order.
Stock, reservations, and selected dated receipts are fetched across the unique
material/plant/date scopes in one repository bulk call; duplicate scopes are
read once. PO confirmation rows remain a separate batched read, and optional
static safety-stock protection is cached per material/plant. The result is
returned in input order; each row's available quantity reflects stock remaining
after earlier requests for that material/plant. The same opt-in receipt flags apply
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
Each check includes `is_fully_confirmed`, true when cumulative confirmation
covers the cumulative request. ATP checks include `confirmed_base_quantity` and
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
reservations. Plant-level reservations and reservations assigned to locations with no
MARD stock row are distributed across locations in ascending location-code
order, matching location-aware allocation. Negative location balances reduce
the plant total, so their deficit is carried across positive locations.
`GET_STOCK_STATUS_BY_BATCH` reports each batch's storage location and expiration
date, unrestricted quantity from `MCHB-CLABS`, and quantity available after the
reservation estimate. It includes batches with zero available quantity so
fully reserved or depleted balances remain visible. Negative batch balances
reduce positive batch availability so the net does not exceed plant stock. The
availability uses the same deterministic assignment for reservations missing
a batch or location as batch allocation. `GET_FEFO_BATCH_STATUS` applies the
same as-of date and
minimum-days eligibility rule as FEFO allocation, returns only eligible batch
rows, and orders dated batches earliest first with undated batches last when
the minimum is zero. Eligible rows with no available stock remain visible.
`GET_FEFO_BATCH_STATUS_BULK` applies per-request as-of dates and minimum-days
windows after one bulk batch read. It returns results in request order and sorts
each result's dated batches earliest first, followed by undated batches when
the requested minimum-days value is zero. It rejects blank keys, duplicate
request IDs, blank dates, and negative minimum-days values before reading stock.
`GET_FEFO_BATCH_STATUS_BULK_UOM` adds a requested material unit to each FEFO
request and returns each batch's unrestricted and available quantities in that
unit, together with the base unit. It caches ratios by material/unit and uses
one bulk batch read for the request set. Unknown units, invalid dates, negative
minimum-days values, and duplicate request IDs are rejected before stock reads.
`GET_BATCH_STOCK_STATUS_BULK` returns this batch breakdown for multiple keyed
material/plant requests in one repository call. Results preserve request order,
include zero-available batches, and resolve expiration dates from plant batch
data before falling back to the global batch master. Blank request fields and
duplicate IDs raise `ZCX_INVALID_STOCK_REQUEST`; empty input returns without a
repository read. Each batch row also reports quality-inspection and blocked
stock quantities separately from unrestricted stock.
`GET_BATCH_STOCK_BULK_UOM` adds a requested unit to each keyed batch-status
request and converts unrestricted, available, quality-inspection, and blocked
quantities for every batch. It retains zero-available batches and their storage
locations and expiration dates, caches ratios by material/unit, and uses one
bulk batch read.
The bulk batch status reader keeps individual open RESB rows through allocation
so large same-batch reservation totals do not overflow an intermediate
quantity. It rejects blank fields, duplicate request IDs, and unknown units
before the stock read; empty input returns without a repository read.
`GET_BATCH_EXPIRY_EXPOSURE_BULK` reports batch-managed stock that is already
expired or expires within each request's inclusive date window. It preserves
storage location, batch, valuation type, expiry, and unrestricted, available,
quality-inspection, and blocked quantities on each balance row. Per-request
totals separate expired from upcoming stock and use checked positive balances;
the available quantity is the local estimate after open reservations.

Set `positive_available_only` to `abap_true` to retain only rows whose reservation-net `available_quantity` is positive. The selector accepts only `abap_true` or `abap_false` and defaults to false. It applies to dated and undated rows before expiry counts, category totals, source/status summaries, and detail paging; category balances on retained rows are unchanged. Base and UOM results echo the selector.
Optional inclusive `available_quantity_from` and `available_quantity_to` bounds, enabled by `filter_available_from` and `filter_available_to`, filter each row by reservation-net available quantity. Either bound may be used alone; two active bounds must be ascending, and zero or negative thresholds are valid. Thresholds use the material base stock unit for both base and UOM requests. Inactive values must be initial; base and UOM results echo the flags and values. The bounds compose with `positive_available_only` and all other filters before dated and undated summaries, counts, and detail paging.
Optional inclusive `available_pct_from` and `available_pct_to` bounds, enabled by `filter_available_pct_from` and `filter_available_pct_to`, select rows by their two-decimal `available_pct_of_unrestricted` value. The value is zero when unrestricted quantity is zero or negative; it can exceed 100 or be negative. Thresholds are unitless; either bound may be used alone, and two active bounds must be ascending. Inactive values must be initial. Base and UOM results echo the flags and values. These bounds compose with availability quantity bounds and all other filters before dated and undated summaries, counts, and detail paging.

Set `filter_positive_category` to `abap_true` and `positive_stock_category` to `U` for unrestricted, `A` for reservation-net available, `Q` for quality-inspection, or `B` for blocked quantity. Only these codes are accepted; the category must be initial when disabled. The filter retains rows with a positive balance in the selected category and composes with `positive_available_only` and all availability filters before counts, totals, and paging. Other category balances remain unchanged. Base and UOM results echo the selector, and allocation trace rows keep their independent scope.

Optional inclusive `category_quantity_from` and `category_quantity_to` bounds, enabled by `filter_category_quantity_from` and `filter_category_quantity_to`, further narrow rows selected by `filter_positive_category`. They use the category named by `positive_stock_category`, in material base units for both base and UOM requests. Either bound may be used alone; two active bounds must be ascending, inactive values must be initial, and base and UOM results echo the flags and values. These bounds apply before exposure summaries, counts, and paging; other category balances remain unchanged.

Optional inclusive `resv_deduction_from` and `resv_deduction_to` bounds, enabled by `filter_resv_deduction_from` and `filter_resv_deduction_to`, filter the signed difference `reservation_deduction_qty` = `unrestricted_quantity` − `available_quantity`. Either bound may be used alone; two active bounds must be ascending, and inactive values must be initial. The thresholds use material base stock units for both base and UOM requests. Base and UOM results echo the flags and values. The bounds apply before expiry summaries, counts, and detail paging.

Each
dated row includes `expiration_date_source`: `P` means plant-level MCHA,
`G` means global MCH1 fallback, and blank means no expiry date resolved. The
expired, upcoming, and after-window row summaries echo their corresponding
`first_expired_date_source`, `next_upcoming_date_source`, and
`after_next_date_source` values. UOM results preserve these source markers.
The result also reports `plant_expiry_source_row_count` and
`global_expiry_source_row_count` for positive-stock rows with resolved expiry
dates, including rows after the requested window. UOM results echo these counts.
`other_expiry_source_row_count` counts dated positive-stock rows with an other
or blank source marker. The three counts partition all dated positive-stock
rows, including rows after the requested window; UOM results echo them unchanged.
`plant_exp_unrestr_qty`, `plant_exp_avail_qty`, `plant_exp_quality_qty`, and
`plant_exp_blocked_qty` report unrestricted, available, quality-inspection, and
blocked stock with plant-level expiry dates. `global_exp_*` and `other_exp_*`
report the same categories for global-fallback and other/blank sources. These
quantity totals use the same dated positive-stock scope as the source counts,
including rows after the requested window. UOM results expose matching `base_*`
quantities and converted `src_*` quantities.
`expired_plant_src_count`, `expired_global_src_count`, and
`expired_other_src_count` split expired rows by date source. The matching
`upcoming_plant_src_count`, `upcoming_global_src_count`, and
`upcoming_other_src_count` split in-window upcoming rows, while
`after_window_plant_src_count`, `after_window_global_src_count`, and
`after_window_other_src_count` split positive-stock rows after `through_date`.
Each trio partitions its corresponding expired, upcoming, or after-window row
count; UOM results echo all nine counts unchanged.
Each result also includes `expiry_src_statuses`, a fixed nine-row matrix in
plant (`P`), global fallback (`G`), and other or blank (`O`) source order, with
expired (`E`), upcoming (`U`), and after-window (`A`) rows for each source.
Every row carries `row_count`, its first and last expiration dates, and
unrestricted, available, quality-inspection, and blocked quantities. The
dates show the actual span within each source/status combination; `expiration_date_span_days` is last minus first in elapsed calendar days and is zero for empty or single-date cells. These dates stay
initial for zero-count rows; zero-count combinations remain present. UOM results preserve the same row order with `base_*` and `unit_*` quantity members for each stock category and echo those date spans and elapsed day values unchanged.
The source-age, upcoming lead-time, and after-window source rows also expose `expiration_date_span_days` as last minus first in elapsed calendar days. Empty and single-date rows report zero; UOM rows echo the values unchanged.
Expired rows also include `expiry_src_age_bands`, a fixed 12-row matrix ordered
by source (`P`, `G`, `O`) and age band (`1` = 1–7 days, `2` = 8–30,
`3` = 31–90, `4` = over 90). Each row reports its positive-stock count, first
and last expiration dates, and four category totals. These dates show the actual
span within each source-age combination and remain initial when the row is empty.
The matrix partitions every disjoint expired-age bucket by date source and
retains zero-count combinations. Each row's `row_share_pct` is its percentage of
all matching expired rows, and its four `*_qty_share_pct` fields give its
percentage of each matching full expired category total. `source_row_share_pct`
shows its share of expired rows for that source, while `age_band_row_share_pct`
shows its share of all expired rows in that band across sources. Percentages round to
two decimals, are zero when their denominator is zero, and may sum slightly away
from 100 due to independent rounding. UOM rows preserve the
same order, counts, percentages, and date spans with base and requested-unit
category quantities. Four `source_*_share_pct` fields divide each category
quantity by the full expired total for that source; their shares across age
bands sum to 100 per nonzero source/category, aside from rounding. Four
`band_*_share_pct` fields divide the category quantity by the matching full
category total for that age band across sources.
`after_window_src_bands` applies the source split to the rows beyond the
inclusive `through_date`, with 1–7, 8–30, 31–90, and over-90 day overrun bands.
Its 12 rows partition the after-window summary and preserve zero combinations.
Each row's `row_share_pct` is its percentage of all matching after-window rows,
rounded to two decimals and zero when none match; independent rounding may shift
the sum slightly from 100. Every row reports its first and last expiration
dates; both stay initial when empty. `source_row_share_pct` gives its share of
after-window rows for the same source, and `through_band_row_share_pct` gives
its share of rows in that band across sources. Four `source_*_share_pct` fields
divide each category quantity by the full after-window total for that source;
their shares across bands sum to 100 per nonzero source/category, aside from
rounding. Four `band_*_share_pct` fields divide each category quantity by the
full total for that band across sources. Four `*_qty_share_pct` fields give each row's share of the
corresponding full after-window category total, rounded to two decimals and
zero when the denominator is zero. UOM results echo the
percentages and dates unchanged alongside counts and base/requested-unit
category totals.
The result also reports `expired_batch_row_count` and
`upcoming_batch_row_count`,
counting returned batch/location/valuation rows with positive stock. The
cumulative `within_7d_batch_row_count`, `within_30d_batch_row_count`, and
`within_90d_batch_row_count` values, each with four stock-category totals,
summarize upcoming rows with positive stock expiring from `as_of_date` through
7, 30, and 90 calendar days later, respectively, inclusive and within the
requested window. The shorter horizons are subsets of the longer horizons. UOM
results carry each category total in base and requested units and preserve the
counts. Separate non-overlapping buckets report `within_7d_batch_row_count` for days
0–7, `from_8_to_30d_batch_row_count` for days 8–30,
`from_31_90d_batch_row_count` for days 31–90, and
`over_90d_batch_row_count` for day 91 onward, each with four category totals.
Together they partition upcoming positive-stock rows and their category totals;
counts and quantities reconcile to the upcoming totals. UOM results carry each
bucket in base and requested units and preserve the counts. `upcoming_src_bands`
adds a fixed 12-row source/lead-time matrix for upcoming stock, ordered by
`P`/`G`/`O` source and the `1` (0–7 days), `2` (8–30), `3` (31–90), and `4`
(over 90) bands. Every row also reports its first and last expiration date,
which show the actual span and remain initial for empty combinations. Each row's
`row_share_pct` is its percentage of all matching upcoming rows, rounded to two
decimals and zero when none match; independent rounding may shift the sum
slightly from 100. Each row also has four `*_qty_share_pct` fields showing its
share of the matching full upcoming category total. Quantity shares round to
two decimals and are zero when their denominator is zero. It includes zero
combinations. `source_row_share_pct` gives its share of upcoming rows for the
same source, and `through_band_row_share_pct` gives its share of rows in that
lead-time band across sources. Four `source_*_share_pct` fields divide each
category quantity by the full total for that source; their shares across bands
sum to 100 per nonzero source/category, aside from rounding. It partitions
upcoming counts and quantities, and carries base and
requested-unit category totals, percentages, and unchanged date spans in UOM
results. Expired positive-stock rows are also split into non-overlapping age buckets:
`expired_1_7_row_count` (1–7 days overdue), `expired_8_30_row_count`
(8–30 days), `expired_31_90_row_count` (31–90 days), and
`expired_ov90_row_count` (91 or more days). Matching `expired_*` totals report
unrestricted, reservation-net available, quality-inspection, and blocked
quantities. Together, the buckets partition the expired counts and totals. UOM
results echo the counts and return each category quantity in base and requested
units. Expiry on `as_of_date` has age zero, remains upcoming, and does not enter
an expired bucket.
Cumulative summaries are also available through the first 7, 30, and 90 days
after expiration via `expired_7d_row_count`, `expired_30d_row_count`, and
`expired_90d_row_count`, with four matching category totals. The shorter
horizons are subsets of the longer ones and reconcile to the disjoint buckets.
UOM results preserve the counts and return base and requested-unit totals.

It also reports `undated_batch_row_count` and base-unit unrestricted,
available, quality-inspection, and blocked totals for returned batch/location/valuation
rows with positive stock and no resolved expiry date. Those rows remain out of
dated detail and dated totals. The separate `undated_batches` list returns
each positive-stock undated row, sorted by batch, storage location, and
valuation type. UOM results include the base row, base and requested units, and
converted category balances for each undated row. The result also identifies
the first undated row through
`first_undated_storage_location`, `first_undated_batch`,
`first_undated_valuation_type`, and `first_undated_expiry_source`, ordered by
batch, location, and valuation. The source marker preserves the selected row's
raw value, including blank or unknown values, and is echoed unchanged by UOM.
Its four stock-category balances are included in base units; UOM results carry
base and requested-unit values. These identity fields are initial and balances
zero when there is no positive-stock undated row. Each result includes a UTC `snapshot_timestamp`
captured after its grouped batch-status read completes; requests sharing that
exclusion-set read share the timestamp. It marks read completion; it does not
make the stock read transactionally consistent. A batch expiring on the as-of
date is upcoming and remains eligible on that date, in line with the FEFO date
rule. Undated batches and batches expiring after the requested window remain
out of the dated detail. The result reports `after_window_batch_row_count`
for positive-stock batch/location/valuation rows with valid expiry dates after
the requested window, with unrestricted, available, QI, and blocked totals
separately. It also identifies the earliest such row through
`after_next_storage_location`, `after_next_batch`, and
`after_next_valuation_type`, with `after_next_expiration_date` and
`days_to_after_next_expiration`. `days_after_window_end` reports how many days
the expiry falls beyond the inclusive `through_date`. These fields follow
expiry, batch, location, and valuation sort order, and remain initial when
there are no positive-stock rows after the window. UOM results echo these
identity and date fields.
The selected row's unrestricted, reservation-net available, QI, and blocked
quantities are included in base units; UOM results include both base and
requested-unit quantities. `after_next_expiry_batch_count` counts all
positive-stock rows sharing `after_next_expiration_date`;
`after_next_exp_unrestr_qty`, `after_next_exp_available_qty`,
`after_next_exp_quality_qty`, and `after_next_exp_blocked_qty` aggregate their
four categories. UOM results echo the count and include base/requested totals;
all are zero when there is no after-window row.
`after_next_exp_plant_count`, `after_next_exp_global_count`, and
`after_next_exp_other_count` split that cohort by resolved date source and
partition `after_next_expiry_batch_count`; UOM results echo them unchanged.
Non-batch split-valuation rows are omitted. Status `A` marks after-window,
`E` expired, and `U` upcoming stock. Within each request, rows sort by
status, expiration date, batch,
storage location, and valuation type, so the key order is deterministic. Set
`maximum_batch_rows` to 1–500 to page the dated `batches` list;
`maximum_batch_rows = 0` keeps the complete legacy list. A continuation sets
`filter_batch_cursor` and supplies the previous
page's `next_cursor_*` tuple in the matching `batch_cursor_*` fields.
`total_dated_batch_row_count` reports all matching dated rows, and
`returned_batch_row_count` reports rows in the current page. `is_truncated`
indicates another page exists. When true, `next_cursor_*` identifies the last
returned row; otherwise the continuation fields are initial. The cursor is exclusive
and follows status, date, batch, location, and valuation
type order. Blank batch, location, and valuation values are valid cursor keys;
without an active cursor, all cursor fields must be initial. Summary counts,
quantities, and first/next cohorts still cover the full filtered result. Set
`omit_dated_batch_rows = abap_true` to suppress the dated `batches` list while
preserving full-scope summaries; it requires `maximum_batch_rows = 0` and no
active dated cursor. The returned dated count and page summaries are zero, page
dates and cursors remain initial, and `is_truncated` is false. Undated paging
continues independently. Base and UOM results echo the flag, and UOM full
summaries retain their converted values. The dated page also reports
`page_expired_row_count`, `page_upcoming_row_count`, and
`page_after_window_row_count`, plus four category totals in `page_*_qty`. The
independent undated page reports its category totals in `undated_page_*_qty`.
Both page totals also expose `page_avail_pct` and signed
`page_reservation_deduction_qty`; the undated page uses
`und_page_avail_pct` and
`und_page_resv_deduct_qty`. Percentages are available quantity as
a share of unrestricted quantity, rounded to two decimals and zero for a zero
denominator. Deductions are unrestricted minus available and preserve negative
values. UOM results echo both percentages and provide base/requested-unit
values through `base_page_resv_deduct_qty` /
`src_page_resv_deduct_qty` and
`base_und_page_resv_deduct_qty` /
`src_und_page_resv_deduct_qty`.

Each dated page also reports its earliest and latest expiration date and the
elapsed day span in `page_earliest_expiration_date`,
`page_latest_expiration_date`, and `page_expiration_date_span_days`. These
values cover only returned rows; empty pages have initial dates and a zero
span, and UOM results echo them unchanged.

Each dated page includes a fixed `page_expiry_statuses` breakdown for expired,
upcoming, and after-window rows. Each status row reports its count, `row_share_pct`, and four stock-category
quantities. The percentage uses the returned dated row count, rounds to two
decimals, and stays zero on an empty page; independent rounding may shift the sum
slightly from 100. Each status also reports its first and last expiration date
and elapsed span across returned rows of that status. Empty status buckets have
initial dates and a zero span. UOM status rows echo the percentage and date
range and carry both base and requested-unit quantities.

Each page status also reports what percentage of the page total comes from that
status for unrestricted, available, quality-inspection, and blocked quantities.
These percentages use the matching category's page total, round to two decimals,
and remain zero when that category total is zero. UOM results preserve them.

Paged results also return `page_expiry_src_statuses`, the fixed nine-cell
source/status matrix. It reports row counts, `row_share_pct` across the page,
`status_row_share_pct` within each matching status, and `source_row_share_pct`
within each matching source, plus date ranges and category quantities and
shares. Row percentages use the returned dated row count; status-relative
percentages use the matching page status count; source-relative percentages use
the matching page source count. All round to two decimals and stay zero when
their denominator is empty. Blank and unknown sources appear in `O`. The full
`expiry_src_statuses` matrix reports the same three row-share percentages
across all matching positive-stock dated rows after request filters,
including after-window rows and independent of page cursors and limits.
Status-relative percentages use the full matching status count, while
source-relative percentages use the full matching source count. The four
`*_qty_share_pct` fields give each cell's share of its page or full category
total. The four `status_*_share_pct` fields give its share of the matching
status's category total, summing to 100 across sources for a nonzero status
category except for rounding. The four `source_*_share_pct` fields give each
cell's share of the matching source's category total, summing to 100 across
statuses for a nonzero source category except for rounding. All sets are zero
when their denominator is zero. UOM rows preserve keys, dates, and percentages
and include base and requested quantities.

Full results also include `expiry_statuses`, a fixed three-row summary for
expired, upcoming, and after-window stock. Each row reports its count and share
of all matching dated rows, first/last expiration dates and their span, four
category totals, and each category's share of the complete dated total. These
values include after-window stock and remain stable across cursors, page limits,
and omitted detail rows. Empty statuses remain present with zero shares and
initial date ranges. UOM results preserve dates, counts, spans, and percentages
while providing base and requested-unit quantities.


`expiry_sources` and `page_expiry_sources` provide direct three-row summaries
for plant (`P`), global (`G`), and other (`O`) dated stock; blank and unknown
markers map to `O`. They report row counts, date ranges, all four stock-category
quantities, and row/category shares rounded to two decimals. Page shares use
returned dated rows and page totals; full shares use all matching dated rows
and full totals, including after-window stock. Shares are zero when their
denominator is zero, and full summaries remain stable across cursors and page
limits. UOM results preserve counts, dates, and shares and include base and
requested-unit quantities.


Each page source/status cell reports its share of each category's total
page quantity and of its matching status's category total. The first set uses
the returned-page category total; the second uses the matching page status
total. Percentages round to two decimals, sum to 100 across source/status cells
for each nonzero page category and across sources for each nonzero status
category, and stay zero when their denominator is zero. UOM results preserve
these percentages.

Each dated page also includes `page_expiry_src_age_bands`, a fixed 12-cell
source/age matrix for expired rows only. It crosses `P`, `G`, and `O` expiry
sources with the 1–7, 8–30, 31–90, and over-90-day age bands. Rows include
counts, shares of the page's expired rows, expiration-date spans, all four
stock-category quantities, and shares of each matching page-expired category
total. Empty cells remain present; all shares are zero when their denominator
is zero. `source_row_share_pct` divides each cell by returned expired rows for
its source; `age_band_row_share_pct` divides it by returned expired rows in the
same age band across sources. Four `band_*_share_pct` fields divide category
quantities by the matching returned-page category total for that age band across
sources. UOM rows preserve keys, dates, counts, and shares
and include base and requested-unit quantities. Four `source_*_share_pct`
fields divide each cell's category quantity by the matching returned-page
expired category total for its source.

Paged expiry results also include `page_upcoming_src_bands` and
`page_after_window_src_bands`. Each is a fixed 12-cell matrix crossing `P`,
`G`, and `O` sources with four lead-time bands. Upcoming bands use days from
`as_of_date` (0–7, 8–30, 31–90, and over 90) and include only dates through
`through_date`; after-window bands use 1–7, 8–30, 31–90, and over 90 days after
`through_date`. Rows report counts and `row_share_pct` within their matching
page status, `source_row_share_pct` within that status and source, and
`through_band_row_share_pct` within that status and band. They also include
expiration-date spans, all four stock-category quantities, and four
`*_qty_share_pct` fields using their matching page status category totals.
Four `source_*_share_pct` fields use the matching page-status category total
for that source. Four `band_*_share_pct` fields use the matching page-status
category total within each band across sources. Source row shares use returned
rows for that status and source; band row shares use returned rows for that
status and band across sources.
Empty cells remain present;
quantity shares are zero when their denominator is zero. UOM results preserve
metadata and include base and requested-unit values.

## Batch expiry age/window availability ratios

Full and page source/age and source/window cells include
`available_pct_of_unrestricted`, calculated as the cell's reservation-net
`available_qty` divided by its `unrestricted_qty`, times 100. Full matrices
use full filtered cell quantities, while page matrices use only returned
rows. The percentage rounds to two decimals and is zero when unrestricted
quantity is zero. Each cell also reports `reservation_deduction_qty` as
unrestricted quantity minus available quantity. UOM rows provide
`base_reservation_deduction_qty` and converted
`unit_reservation_deduction_qty`; negative raw differences are preserved.
UOM rows echo the percentage unchanged.

## Batch expiry summary availability and reservation deductions

Full and page `expiry_statuses`, `page_expiry_statuses`, `expiry_sources`,
`page_expiry_sources`, `undated_expiry_sources`,
`undated_page_expiry_sources`, and source/status matrix rows report
`available_pct_of_unrestricted` and `reservation_deduction_qty` for their own
aggregate. The ratio is reservation-net `available_qty` divided by
`unrestricted_qty`, multiplied by 100 and rounded to two decimals; it is zero
when unrestricted quantity is zero. The deduction is unrestricted quantity
minus available quantity and preserves signed differences. UOM status rows,
source rows, undated source rows, and source/status rows echo the ratio and
provide base and converted deduction quantities. Full and summary-only results
use full filtered totals; page results use their returned detail scope.
The result also reports `dated_unrestricted_quantity`,
`dated_available_quantity`, `dated_quality_quantity`, and
`dated_blocked_quantity` across expired, upcoming, and after-window rows,
with `dated_avail_pct` and signed
`dated_resv_deduct_qty`. The ratio uses the combined dated total and
is zero when unrestricted quantity is zero. UOM results echo the percentage
and provide `base_dated_unrestricted_qty` / `src_dated_unrestricted_qty`,
`base_dated_available_qty` / `src_dated_available_qty`,
`base_dated_quality_qty` / `src_dated_quality_qty`,
`base_dated_blocked_qty` / `src_dated_blocked_qty`, and
`base_dated_resv_deduct_qty` /
`src_dated_resv_deduct_qty`. These full-scope values remain available
when dated details are omitted.

## Batch expiry full through-date aggregates

`through_unrestricted_quantity`, `through_available_quantity`,
`through_quality_quantity`, and `through_blocked_quantity` combine the expired
(`E`) and upcoming (`U`) status totals for stock with expiration dates on or
before the requested `through_date`; they exclude after-window (`A`) stock.
The totals are calculated before page limits and cursors and remain available
when dated detail rows are omitted. `through_avail_pct`
and `through_resv_deduct_qty` use those same through-date
unrestricted and available totals; the ratio is zero for a zero denominator
and the signed deduction is unrestricted minus available. UOM results echo
the ratio and provide `base_through_unrestricted_qty` /
`src_through_unrestricted_qty`, `base_through_available_qty` /
`src_through_available_qty`, `base_through_quality_qty` /
`src_through_quality_qty`, `base_through_blocked_qty` /
`src_through_blocked_qty`, and `base_through_resv_deduct_qty` /
`src_through_resv_deduct_qty`.

## Batch expiry detail availability and reservation deductions

Dated and undated batch detail rows report `available_pct_of_unrestricted` and
`reservation_deduction_qty` for that batch. The percentage is available quantity
as a share of unrestricted quantity, rounded to two decimals; it is zero when
unrestricted quantity is zero and may exceed 100 when available quantity is
larger. The signed deduction is unrestricted quantity minus available quantity.
After-window rows use the same fields. UOM detail rows echo the percentage and
carry the base deduction in `base_row-reservation_deduction_qty` plus its
requested-unit value in `source_resv_deduction_qty`.

Undated rows preserve their raw `expiration_date_source`, and each undated page
adds a fixed `undated_page_expiry_sources` summary for `P`, `G`, and `O`. Each
source row reports its count, `row_share_pct`, four category quantities, and
`unrestricted_qty_share_pct`, `available_qty_share_pct`,
`quality_qty_share_pct`, and `blocked_qty_share_pct`. Blank and unknown sources
map to `O`. Page shares use returned-row and returned-category totals, remain
zero when their denominator is zero, and UOM summaries echo them unchanged
while exposing base and requested-unit quantities. Independent rounding can
make source percentages sum to slightly above or below 100.

The full result also includes `undated_expiry_sources`, a fixed `P`, `G`, and
`O` breakdown across every matching positive-stock undated row. It stays stable
across cursor continuations and is independent of page limits or omitted detail
rows. Each source's `row_share_pct` uses the full undated row count; its four
category-share fields use the full filtered undated category totals. All shares
are rounded to two decimals and zero when their denominator is zero. Row counts
and category quantities reconcile to the full undated totals; UOM results echo
percentages and provide base and requested-unit values. The full undated scalar
totals also report `undated_avail_pct` and signed
`undated_resv_deduct_qty`. UOM results echo the percentage and provide
`base_undated_resv_deduct_qty` and
`src_undated_resv_deduct_qty`.

These page values describe rows returned after the cursor and page limit. UOM
results preserve the counts and expose dated totals through `base_page_*_qty`
and `src_page_*_qty`, and undated totals through `base_und_page_*_qty` and
`src_und_page_*_qty`; full filtered summaries remain unchanged. Undated rows use an independent page limit: `maximum_undated_batch_rows = 0`
keeps the full list, and 1–500 caps each page. A continuation sets
`filter_undated_batch_cursor` and supplies the previous page's
`next_undated_cursor_*` tuple in `undated_cursor_batch`,
`undated_cursor_location`, and `undated_cursor_val_type`. The cursor is
exclusive and follows batch, location, and valuation type order; blank key
values are valid. `total_undated_batch_row_count` and the existing
`undated_batch_row_count` report all matching rows, while
`returned_undated_row_count` reports the current page size.
`is_undated_truncated` indicates another page exists. When true,
`next_undated_cursor_batch`, `next_undated_cursor_location`, and
`next_undated_cursor_val_type` identify its last row; otherwise those fields are
initial. Without an active cursor, all `undated_cursor_*` fields must be initial.
Setting `omit_undated_batch_rows = abap_true` suppresses details while preserving
counts, quantities, and earliest-row summary; it cannot be combined with an
active undated cursor or positive undated page limit. The flag defaults to
`abap_false`. UOM requests use both paging contracts and convert each returned
detail row. Each continuation is a new stock read, so it does not pin the first
page's snapshot. A nonblank `storage_location`
filters to that exact location; set `filter_storage_location` to `abap_true` to
select blank locations. The flag accepts only `abap_true` or `abap_false`, and
the request location and flag are echoed. A nonblank `batch` filters to that
exact batch; set `filter_batch` to `abap_true` to select blank batches. A
nonblank `valuation_type` filters to that exact valuation type; set
`filter_valuation_type` to `abap_true` to select blank valuation types. All
four flags accept only `abap_true` or `abap_false`; the location, batch, and
valuation scopes intersect and are echoed. `expiry_source` accepts `P` for
plant-level dates, `G` for the global fallback, and `O` for any other source
value, including blank. Set `filter_expiry_source` to `abap_true` with a blank
`expiry_source` to select only rows without a resolved source; nonblank values
must be `P`, `G`, or `O`. The expiry-source scope intersects with the other
filters and is echoed. Optional
inclusive `expiration_date_from` and `expiration_date_to` bounds filter rows by
resolved expiry date; either bound may be supplied, and two bounds must be in
ascending order. Supplying either bound omits undated rows from the undated list,
counts, and totals. These bounds do not change status relative to `as_of_date`
or the after-window test relative to `through_date`; base and UOM results echo
both bounds. Set `filter_expiry_status = abap_true` with `expiry_status` `E` for dates before `as_of_date`, `U` for dates from `as_of_date` through `through_date` inclusive, or `A` for dates after `through_date`. The status scope intersects with location, batch, valuation, source, and expiration-date bounds before dated counts, totals, and batch paging. When active, undated rows are omitted from undated details, counts, and totals. Only `E`, `U`, and `A` are accepted; `expiry_status` must be initial when disabled, and base and UOM results echo both selector fields. Allocation trace rows retain their independent scope. Set `filter_expiry_age_band = abap_true` with `expiry_age_band` `1` for 1–7 days since expiry, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector returns only expired rows, composes with status, source, and date bounds before counts, totals, and paging, and omits upcoming, after-window, and undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both selector fields. Set `filter_expiry_upcoming_band = abap_true` with `expiry_upcoming_band` `1` for 0–7 days from `as_of_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes the as-of date and only dates through the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. Set `filter_exp_after_window_band = abap_true` with `expiry_after_window_band` `1` for 1–7 days after `through_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes only dates after the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. Optional `filter_expiry_days_from` and `filter_expiry_days_to` with `expiry_days_from` and `expiry_days_to` set inclusive signed `expiration_date - as_of_date` bounds. Either bound may be used alone; expired values are negative, the as-of date is zero, future values are positive, and active bounds omit undated rows. Two active bounds must be ascending. These bounds compose before exposure counts, totals, and paging, and base and UOM results echo both flags and values.

Batch rows, expiry and source counts, and stock-category totals
reflect the selected scope. The repository still reads material/plant stock to
calculate reservation-net quantities across all locations; the filters narrow
returned stock rows, expiry and source counts, and stock-category totals after
netting.
Reservation summaries remain material/plant-wide. Stock exposure filters do
not narrow allocation trace rows; the independent reservation and pass filters
can narrow the details while summary quantities and counts remain full scope. Each
dated detail row also
includes `days_to_expiration`, calculated as `expiration_date - as_of_date`;
negative values are expired, zero expires on the as-of date, and positive
values are upcoming. UOM detail rows echo the date distance in their nested
base row. All reported quantities are in the material base unit. Call-wide
reservation exclusions apply to every
request; each request can also carry its own excluded reservation/item keys.
The local availability estimate uses the union of both sets for that request.
Exclusions do not change SAP reservations. Base and UOM results echo the
effective keys used for each request, the row counts, and the same
`snapshot_timestamp`; counts and timestamps are not converted.
Direct batch-status bulk results also include a UTC `snapshot_timestamp`,
captured once after their grouped repository read. The UOM batch-status result
echoes the timestamp, and all rows from one bulk read share it.
`open_reservation_row_count` counts eligible RESB rows with positive
remaining quantities after effective exclusions are applied. It records the
rows considered by local availability calculation; use batch balances for
quantity amounts.
`excluded_open_resv_row_count` counts RESB rows whose remaining quantity is
positive and whose reservation/item keys match the effective exclusions. The
`unmatched_open_resv_excl_count` counts effective exclusion keys that do
not match a positive open RESB row for the request, and
`unmatched_excl_reservations` returns those keys in reservation/item order.
UOM results echo all three counts and the key list unchanged.
`open_reservation_quantity` sums positive remaining quantities passed to the
local availability calculator; `excluded_open_resv_quantity` sums positive
remaining quantities removed by effective exclusions. These raw reservation
totals are in the material base unit and do not measure stock deductions. UOM
results provide `base_open_resv_qty` and `src_open_resv_qty`, plus
`base_excluded_open_resv_qty` and `src_excluded_open_resv_qty`.
`fully_allocated_resv_count`, `partially_allocated_resv_count`, and
`unallocated_resv_count` classify eligible open reservation rows by local
allocation outcome. Fully allocated rows have no residual; partially allocated
rows have both a deduction and a residual; unallocated rows have no local
deduction. The three counts sum to `open_reservation_row_count`, and excluded
reservations are not included. UOM expiry results echo the counts. The three open-quantity totals, `fully_alloc_resv_open_qty`, `part_alloc_resv_open_qty`, and `unalloc_resv_open_qty`, partition eligible `open_reservation_quantity` by outcome using each row's entire open demand; excluded reservations are omitted. UOM expiry results provide base and requested-unit values for each total.
`matched_allocation_quantity` and `fallback_allocation_quantity` summarize
deductions from the selector-matching and fallback passes. Their sum plus
`uncovered_open_resv_quantity` equals eligible `open_reservation_quantity`;
excluded demand is outside this reconciliation. UOM results provide
`base_matched_allocation_qty` / `src_matched_allocation_qty` and
`base_fallback_allocation_qty` / `src_fallback_allocation_qty`, so callers can
compare the passes without summing `allocation_details` rows.
`allocation_coverage_pct` reports matched plus fallback quantity as a percentage
of eligible open demand; `allocation_shortage_pct` reports the uncovered share.
Both use two decimal places, are zero when there is no eligible open demand,
and are echoed unchanged by UOM results.
`matched_share_pct` and `fallback_share_pct` split that coverage by
allocation pass, each as a percentage of eligible open demand. They use two
decimal places, are zero when there is no eligible demand, and may sum to a
value that differs from coverage by 0.01 due to independent rounding. UOM
results echo both unchanged.
Each `resv_alloc_summaries` row also includes `allocation_coverage_pct` and
`allocation_shortage_pct` for that reservation's allocated and uncovered shares
of its positive open demand. It now reports `matched_share_pct` and
`fallback_share_pct` to show each allocation pass as a percentage of the same
open demand. The three shares are rounded to two decimals; matched and fallback
shares sum to coverage, and coverage plus shortage sums to 100.00, apart from a
possible 0.01 difference from independent rounding. UOM summary rows echo all
four percentages unchanged.
`matched_allocation_row_count` and `fallback_allocation_row_count` count the
trace rows for each pass; each row represents one positive deduction against
one stock row, so these are not counts of distinct reservations. UOM results
echo both counts unchanged.
`uncovered_open_resv_quantity` reports the eligible open reservation demand
left after the calculator's matching and fallback passes. It is a local
unallocated demand amount, not an SAP-confirmed shortage. UOM results include
`base_uncovered_open_resv_qty` and `src_uncovered_open_resv_qty`.
`uncovered_open_resv_keys` lists the reservation/item keys with a positive
residual after local allocation, sorted by reservation and item; UOM results
echo these keys unchanged.
`allocation_sequence` is one-based across positive eligible open reservations
and records calculator processing order: more specific selectors go first,
selector values break ties, and identical selector tuples retain caller input
order. Stock rows traverse by location, batch, valuation type, and expiry date;
equal stock keys retain input order. Trace and uncovered rows carry the
sequence, and UOM rows echo it. Result collections remain sorted by
reservation/item; sorting by `allocation_sequence` restores shared-stock
consumption order.
`uncovered_open_reservations` returns each such key with its positive
uncovered quantity, requirement date, storage location, batch, valuation
type, required quantity, withdrawn quantity, open quantity, and locally
allocated quantity. Required and withdrawn quantities retain the RESB source
values, and open equals required minus withdrawn. Open quantity equals matched
plus fallback plus uncovered quantity, and allocated quantity equals matched
plus fallback. The matched quantity comes from the
selector-matching pass; fallback quantity comes from the second pass, which
can widen location and batch matching while retaining a specified valuation
type. Uncovered row quantities sum to `uncovered_open_resv_quantity`. UOM rows
echo the reservation context and include base and requested-unit values for
required, withdrawn, open, allocated, matched, fallback, and uncovered
quantities.
Each uncovered row also reports `allocation_coverage_pct`,
`allocation_shortage_pct`, `matched_share_pct`, and `fallback_share_pct` as
percentages of that row's open quantity. They use two decimal places. UOM
detail rows echo the percentages unchanged.

`uncovered_open_resv_row_count` counts all positive residual rows, even
when the detail list is paged; expiry and UOM results preserve the full count.

Uncovered-reservation details have an independent keyset page.
`maximum_uncovered_rows = 0` returns all details; values 1–500 cap a page.
Set `filter_uncovered_cursor = abap_true` with both the reservation number and
item from the previous page's last row to continue. The cursor is exclusive and
uses reservation/item order. Without an active cursor, both cursor fields must
be initial. `total_uncovered_detail_count` counts all matching residual rows,
`returned_uncovered_row_count` gives the current page size, and
`is_uncovered_truncated` indicates another page. When truncated,
`next_uncovered_cursor_number` and `next_uncovered_cursor_item` identify the
last returned row. In paged requests, `uncovered_open_resv_keys` and
`uncovered_open_reservations` contain the same page. UOM results echo the page
metadata and convert the returned details. Each continuation recalculates
from current reservation data; pages do not retain a shared snapshot. Set `filter_uncovered_due_horizon = abap_true` with `uncovered_due_horizon` set to `O`, `T`, `1`, `2`, `3`, `4`, or `U` to select overdue, due-today, 1–7, 8–30, 31–90, over-90, or undated detail rows. Each returned uncovered detail row also exposes `due_horizon_band` using the same codes relative to `as_of_date`; UOM detail rows echo the code unchanged. Each uncovered detail also exposes `allocation_outcome`: `P` when allocated quantity is positive and `U` when it is zero; UOM detail rows echo the code unchanged. Overdue rows also report `overdue_age_days` as the exact positive calendar days late and `overdue_age_band` as `1` for 1–7 days late, `2` for 8–30, `3` for 31–90, or `4` for more than 90 days late. Both fields are initial for due-today, future, and undated rows; UOM detail rows echo them unchanged. `filtered_uncov_overdue_ages` returns four stable rows for 1-7, 8-30, 31-90, and over-90 days late, including empty bands. Each row summarizes every selector-matching overdue detail before cursor and page selection with partial/unallocated counts, base and source quantities, and weighted coverage, shortage, matched, and fallback percentages; percentages stay zero for empty demand. Partial and unallocated open quantities partition each band's open demand, and their shortage quantities partition uncovered demand. Each band also reports partial-only coverage, shortage, matched, and fallback percentages using partial open quantity as the denominator; these remain zero without partial demand. UOM rows convert all four outcome quantities and echo the percentages. Each row also reports `first_required_date` and `last_required_date` across its matching dated reservations; both remain initial for empty bands and UOM results echo both dates. UOM results preserve the band order and percentages and convert quantities. Set `filter_uncovered_age_band = abap_true` with `uncovered_age_band` set to `1`, `2`, `3`, or `4` to select overdue details 1-7, 8-30, 31-90, or over 90 days late. It composes with the other detail selectors before filtered summaries, counts, and paging; the disabled value must be initial, and UOM results echo both fields. Set `filter_overdue_age_days_from` and/or `filter_overdue_age_days_to` with the matching `overdue_age_days_from` and `overdue_age_days_to` values to select an inclusive overdue-age day range. Either bound may be omitted; active bounds must be positive and ascending, and inactive values must be initial. A day range excludes due-today, future, and undated rows, composes with the age-band and other detail selectors before totals and paging, and UOM results echo both flags and bounds. The selector filters details before cursor and page selection; `total_uncovered_detail_count` counts all horizon-matching rows independent of the cursor, while `uncovered_open_resv_row_count` and the reservation-level quantity summaries stay full-scope. Invalid active values and nonblank inactive selectors are rejected, and UOM results echo both fields. Set `omit_uncovered_detail_rows = abap_true` to return no uncovered detail rows or parallel keys while retaining the filtered detail total and full-scope shortage summaries. The flag requires `maximum_uncovered_rows = 0` and no active uncovered cursor; UOM results echo it, and non-boolean values are rejected. Summary-only mode still calculates the filtered totals and fixed due-horizon and overdue-age summaries from repository reservation rows without building detail or key tables. Set `filter_uncovered_sequence = abap_true` with a positive `uncovered_sequence` to select one reservation's shortage row in shared-stock allocation order. It composes with the due-horizon filter and cursor before detail totals and paging. The disabled selector must be initial, and UOM results echo both fields. Optional inclusive `uncovered_required_date_from` and `uncovered_required_date_to` bounds select a caller-chosen required-date window. Either bound may be supplied; two bounds must be valid and ascending. When a bound is set, undated rows are omitted. The bounds compose with sequence, due-horizon, and cursor scopes before counts and paging, and UOM results echo both dates. Set `filter_uncovered_reservation = abap_true` with both `uncovered_reservation_number` and `uncovered_reservation_item` to select one shortage row. Both key fields are required when active and must be initial otherwise. This selector composes with sequence, due-horizon, date bounds, and cursor scopes before counts and paging; an active cursor must match the selected key, and UOM results echo all three selector fields. Set `filter_uncovered_outcome = abap_true` with `uncovered_outcome` set to `P` for rows with positive local allocated quantity (partially allocated), or `U` for rows with zero local allocated quantity (unallocated). The selector composes with reservation, sequence, due-horizon, date-window, and cursor scopes before filtered totals and paging; full-scope shortage summaries stay unchanged. Only `P` and `U` are valid active values, the disabled selector must be initial, and UOM results echo both fields. Set `filter_uncovered_pct_from = abap_true` with `uncovered_pct_from` and/or `filter_uncovered_pct_to = abap_true` with `uncovered_pct_to` to filter each row by `allocation_shortage_pct`. Bounds are inclusive and accept 0–100; if both are active they must ascend, and inactive values must be initial. The selector composes with the other detail filters before filtered totals and page selection; full-scope shortage summaries stay unchanged. UOM results echo both flags and values. Set `filter_uncovered_qty_from = abap_true` with `uncovered_qty_from` and/or `filter_uncovered_qty_to = abap_true` with `uncovered_qty_to` to filter each detail row by inclusive `uncovered_quantity` in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Quantity bounds compose with the other detail filters before filtered totals and page selection; full-scope shortage summaries stay unchanged. UOM results echo both flags and base-unit bounds unchanged. The result also reports `filtered_uncovered_qty`, the sum of `uncovered_quantity` for every row matching the detail selectors before cursor and page selection. The total stays the same across cursor continuations; UOM results report `base_filtered_uncovered_qty` and `src_filtered_uncovered_qty`. Set an open-demand detail range with `filter_uncovered_open_from = abap_true` and `uncovered_open_qty_from` and/or `filter_uncovered_open_to = abap_true` and `uncovered_open_qty_to` to filter each uncovered row by inclusive `open_quantity` in the material base unit. Bounds must be nonnegative; either is optional, both must be ascending, and disabled values must be initial. The range composes with the other detail selectors before filtered counts and sums, cursor, and page selection; UOM results echo both flags and base-unit bounds. The filtered uncovered-detail totals also include `filtered_open_demand_qty`, the sum of `open_quantity` for every row matching the detail selectors before cursor and page selection. This total stays the same across cursor continuations; `filtered_uncovered_qty` continues to report the shortage amount. UOM results report `base_filtered_open_demand_qty` and `src_filtered_open_demand_qty`. Filtered details also report `filtered_uncovered_alloc_qty`, the sum of `allocated_quantity` for every matching row before cursor and page selection. Filtered open demand reconciles as allocated plus uncovered quantity. UOM results report `base_filtered_uncov_alloc_qty` and `src_filtered_uncov_alloc_qty`. Filtered allocation is also split into `filtered_uncov_matched_qty` and `filtered_uncov_fallback_qty`, summing the matched and fallback quantities for the same rows. These totals reconcile with `filtered_uncovered_alloc_qty`; together with shortage they reconcile to open demand. UOM results report `base_uncov_matched_qty` / `src_uncov_matched_qty` and `base_uncov_fallback_qty` / `src_uncov_fallback_qty`. Results also include `filtered_uncov_partial_count` and `filtered_uncov_unalloc_count` across that same selector-matching row set before cursor and page selection. The two counts partition `total_uncovered_detail_count`; UOM results echo them unchanged. The weighted `filtered_uncov_coverage_pct` and `filtered_uncov_shortage_pct` use the same matched rows: allocated and uncovered totals divided by open-demand total. They sum to 100 when matching open demand exists and remain zero for an empty result; UOM results echo both percentages unchanged. Weighted `filtered_uncov_matched_pct` and `filtered_uncov_fallback_pct` also report matched/open and fallback/open for the same filtered rows; together they equal coverage. UOM results echo all four percentages unchanged. `filtered_uncov_due_horizons` returns the same selector-matching residual rows as a fixed seven-row due-horizon summary (`O`, `T`, `1`, `2`, `3`, `4`, `U`), including empty bands. Each band’s `partial_row_count` and `unalloc_row_count` partition its `row_count`. Open, allocated, matched, fallback, and uncovered quantities reconcile to the filtered totals before cursor and page selection; UOM results preserve band order and all counts and provide base and source quantities. Each band also reports weighted `coverage_pct`, `shortage_pct`, `matched_pct`, and `fallback_pct` from its own totals. Coverage and shortage, and matched and fallback, reconcile within 0.01 percentage points from independent rounding; percentages are zero for empty bands. UOM results echo these percentages unchanged. Partial-only `partial_coverage_pct`, `partial_shortage_pct`, `partial_matched_pct`, and `partial_fallback_pct` use `partial_open_qty` as their denominator: allocated, partial shortage, matched, and fallback quantities respectively. They stay zero when a band has no partial rows. Coverage and shortage, and matched and fallback, reconcile within 0.01 percentage points from independent rounding. UOM results echo these percentages unchanged.  The filtered detail result also exposes `filtered_partial_open_qty`, `filtered_unalloc_open_qty`, `filtered_partial_short_qty`, and `filtered_unalloc_short_qty`. The open quantities partition `filtered_open_demand_qty`; the shortage quantities partition `filtered_uncovered_qty`. UOM results provide base and source quantities for all four totals. Top-level `partial_coverage_pct`, `partial_shortage_pct`, `partial_matched_pct`, and `partial_fallback_pct` use the filtered partial open quantity as their denominator, matching the seven-band partial-only percentages. They remain zero when no partial rows match, reconcile within 0.01 percentage points from independent rounding, and UOM results echo unchanged. The outcome split also exposes `partial_open_qty`, `unalloc_open_qty`, `partial_short_qty`, and `unalloc_short_qty`; the first pair sums to `open_demand_quantity` and the second to `uncovered_quantity`. UOM rows return base and source quantities for all four. `first_required_date` and `last_required_date` show the actual date span among dated rows in each band. They remain initial for empty or undated bands; UOM results echo both dates unchanged.
`allocation_details` returns every positive reservation deduction by
reservation and actual stock row. Each row includes the reservation's requested
location, batch, and valuation type alongside the actual stock row's location,
batch, valuation type, expiry date, and quantity. Each row also carries
`days_until_required`, calculated as `required_date - as_of_date`; negative is
overdue, zero is due on the as-of date, and positive is future-dated. An
initial required date leaves zero, and UOM rows echo the day count.
`allocation_pass` is `M` when
the first pass honored the reservation selectors and `F` when fallback widened location and
batch matching while retaining any specified valuation type. Rows sort by
reservation/item and preserve pass order and stock traversal within each key. For each
reservation listed in `uncovered_open_reservations`, detail quantities sum to
its `allocated_quantity`. Fully covered reservations still appear in the trace
but have no uncovered-summary row. UOM results echo the detail and include
base and requested-unit quantities.

Allocation-trace details have an independent keyset page. `maximum_allocation_rows = 0`
returns every trace row; values 1–500 cap a page. Set
`filter_allocation_cursor = abap_true` with the previous row's reservation
number, item, allocation pass, actual storage location, batch, valuation type,
and expiration date in the `allocation_cursor_*` fields. The exclusive order is
reservation/item, pass (`M` before `F`), then stock traversal by location, batch,
valuation type, and expiration date. Blank actual stock keys and dates are valid
cursor components. Without an active cursor, all cursor fields must be initial.
`total_allocation_detail_count` counts the full trace,
`returned_allocation_row_count` gives the current page size, and
`is_allocation_truncated` indicates another page. When truncated, the
`next_alloc_cursor_*` fields identify the last returned row. UOM results echo
the page metadata and convert only the returned rows. The base result's `filtered_allocation_quantity` sums every row matching the active allocation-detail filters before cursor and page selection, even when detail rows are omitted. UOM results expose the base-unit `base_filtered_alloc_qty` and converted `source_filtered_alloc_qty`. `filtered_allocation_passes` adds a fixed two-row (`M`, `F`) breakdown for the same filter scope before cursor and page selection, retaining zero-count passes; its counts and quantities reconcile to the filtered total. UOM rows preserve pass order and counts with base and converted quantities. `filtered_alloc_expiry_sources` adds a fixed six-row (`P/M`, `P/F`, `G/M`, `G/F`, blank/M, blank/F) breakdown for that same filter scope before cursor and page selection, retaining zero cells and reconciling counts and quantities to the filtered total. UOM rows preserve source/pass order and counts with base and converted quantities. `filtered_expiry_due_gap_bands` adds a fixed 20-row breakdown for that same filter scope before cursor and page selection, retaining empty band/pass combinations; its counts and quantities reconcile to the filtered total. UOM rows preserve band/pass order and counts and provide base and converted quantities. Each continuation reads
current reservation and stock data; pages do not retain a shared snapshot.
`filtered_alloc_src_gap_bands` adds a fixed 60-row source/gap-band/pass matrix
for the same active filter scope before cursor and page selection. It orders
expiry sources `P`, `G`, blank; gap bands `P4`, `P3`, `P2`, `P1`, `Z`, `N1`,
`N2`, `N3`, `N4`, `U`; and passes `M`, `F`. Empty cells remain present, and
counts and quantities reconcile to the filtered total. UOM rows preserve this
order and the counts, and include base and converted quantities.
`filtered_exp_src_statuses` adds a fixed 24-row source/expiry-status/pass
matrix for the active filter scope, ordered by source (`P`, `G`, blank), status
(`E`, `U`, `A`, `D`), and pass (`M`, `F`). It retains empty cells and
reconciles counts and quantities to the filtered total. UOM results preserve
row order and counts and include base and converted quantities.
`filtered_alloc_exp_statuses` adds the corresponding fixed eight-row
expiry-status/pass matrix without the source dimension. It uses the same
filtered scope and state/pass order, retains empty cells, and reconciles counts
and quantities to the filtered total. UOM rows preserve order and counts and
include base and converted quantities.
`filtered_alloc_due_src_bands` adds a fixed 42-row source/required-date-horizon/pass
matrix for the active filter scope. The order is sources `P`, `G`, blank;
horizons overdue (`O`), today (`T`), 1–7 (`1`), 8–30 (`2`), 31–90 (`3`),
over 90 (`4`), and undated (`U`); then passes `M`, `F`. Empty cells remain,
and counts and quantities reconcile to the filtered total. UOM results preserve
the order and counts and include base and converted quantities.
`filtered_alloc_due_horizons` provides the corresponding fixed 14-row
required-date-horizon/pass marginal. It uses the same active filter scope and
horizon order, retains empty combinations, and reconciles counts and quantities
to the filtered total. UOM results preserve the order and counts and convert
quantities.
`filtered_alloc_date_buckets` adds a fixed eight-row required-date-bucket/pass
summary ordered by overdue (`O`), today (`T`), future (`F`), and undated (`U`),
then pass (`M`, `F`). It uses the active filter scope before pagination,
retains empty cells, and reconciles counts and quantities to the filtered
total. UOM results preserve order and counts and convert quantities.
`filtered_alloc_risk_matrix` adds a fixed 32-cell expiry-status /
required-date-bucket / pass matrix, ordered by expiry status (`E`, `U`, `A`,
`D`), required-date bucket (`O`, `T`, `F`, `U`), and pass (`M`, `F`). It uses
the same active trace-filter scope before pagination, retains empty cells, and
reconciles counts and quantities to the filtered total. UOM results preserve
the order and counts and convert quantities.
`filtered_expiry_due_relations` adds a fixed eight-row relation/pass matrix for
the same filter scope, ordered by relation (`B`, `S`, `A`, `U`) and pass (`M`,
`F`). It retains empty cells and reconciles counts and quantities to the
filtered total. UOM rows preserve the order and counts and include base and
converted quantities.
`filtered_exp_src_relations` adds a fixed 24-row source/relation/pass matrix
ordered by source (`P`, `G`, blank), relation (`B`, `S`, `A`, `U`), and pass
(`M`, `F`). Empty cells remain present; counts and quantities reconcile to the
filtered total. UOM results preserve row order and counts and include base and
converted quantities.
`filtered_max_due_after_exp_gap` identifies the first filtered allocation row
with the greatest positive `required_date - expiration_date` gap;
`filtered_max_before_exp_gap` does the same for the greatest positive
`expiration_date - required_date` gap. Both summaries include reservation,
pass, stock keys, dates, and quantity, and remain initial when no filtered row
qualifies. UOM results preserve those identities and convert the quantities.
Set `omit_allocation_detail_rows = abap_true` to omit detail rows while
retaining the filter-scoped `total_allocation_detail_count` and full pass
quantities and row counts. The option requires `maximum_allocation_rows = 0`
and no active allocation cursor; UOM results echo the flag. Allocation-trace
pages can be scoped to one reservation with
`filter_allocation_reservation = abap_true` and its reservation number and item.
The scope is applied before pagination, so `total_allocation_detail_count` counts
matching trace rows while pass quantities, pass row counts, and reservation
summaries remain material/plant-wide. Both key fields are required when enabled
and initial when disabled. With an active cursor, its reservation key must match
the selected key. Add `filter_allocation_pass = abap_true` and set
`allocation_pass` to `M` or `F` to select matched or fallback rows; this filter
intersects with the reservation scope. An active cursor must use the selected
pass. UOM results echo both scopes. Set
`filter_allocation_date_bucket = abap_true` with `allocation_date_bucket` set
to `O` overdue, `T` due today, `F` future-dated, or `U` undated to restrict
trace rows by `as_of_date`. The selector applies before counting and pagination,
composes with reservation and pass filters, and is echoed by UOM results. Allocation-trace pages also accept `filter_allocation_due_horizon = abap_true` with `allocation_due_horizon` set to `O`, `T`, `1`, `2`, `3`, `4`, or `U`, using the same calendar-day bands as open-demand summaries. It composes with the coarse date bucket, reservation, pass, and required-date range scopes before counts and pagination; unknown active codes and nonblank inactive selectors are rejected, and UOM results echo the selector. Set `filter_allocation_sequence = abap_true` with a positive `allocation_sequence` to select one exact position in shared-stock allocation order. It composes with the reservation, pass, date bucket, due horizon, and required-date range scopes before counts and pagination. A disabled sequence selector must be initial; invalid active values and noninitial inactive values are rejected, and UOM results echo both selector fields. Optional inclusive `allocation_required_date_from` and
`allocation_required_date_to` bounds restrict trace rows by `required_date`.
Either bound may be supplied, and two bounds must be ascending. When either is
set, undated trace rows are omitted. Date bounds compose with the bucket,
reservation, and pass filters before counting and pagination; UOM results echo
the selected bounds. Set `filter_allocation_val_type = abap_true` to select trace rows with `allocation_val_type`, including a blank value to select rows without a valuation type. The selector composes with reservation, pass, sequence, date-bucket, due-horizon, and required-date scopes before filtered totals and pagination; full allocation totals and reservation summaries stay material/plant-wide. The value must be initial when disabled, and UOM results echo both selector fields. Set `filter_allocation_location = abap_true` with `allocation_location` and `filter_allocation_batch = abap_true` with `allocation_batch` to narrow trace rows to those stock keys; either active filter can select a blank key. Both filters intersect with valuation type and the other trace scopes before filtered totals and paging. Their values must be initial when disabled, and UOM results echo both flags and values. Optional inclusive `allocation_expiry_date_from` and `allocation_expiry_date_to` bounds also restrict trace rows by the stock row's expiration date. Either bound may be supplied; two bounds must be valid and ascending. When either is set, rows without an expiry date are omitted. Expiry-date bounds compose with valuation type, stock keys, reservation, pass, and required-date scopes before counts and paging; UOM results echo both dates. Set `filter_allocation_expiry = abap_true` with `allocation_expiry_status` set to `E` for rows expiring before `as_of_date`, `U` for rows expiring from `as_of_date` through `through_date` inclusive, `A` for rows after `through_date`, or `D` for rows without an expiry date. The status filter composes with expiry-date bounds and other trace scopes before filtered totals and paging. Only these four active codes are accepted; the value must be initial when disabled, and UOM results echo both fields. Set `filter_allocation_expiry_band = abap_true` with `allocation_expiry_band` `1` for 0–7 days from `as_of_date`, `2` for 8–30, `3` for 31–90, or `4` for over 90. It selects dated upcoming rows only, including `as_of_date` and dates through the inclusive `through_date`; it composes with expiry status, date bounds, and other trace scopes before filtered totals and paging. UOM results echo both fields; invalid active codes and noninitial disabled values are rejected. Set `filter_allocation_after_band = abap_true` with `allocation_after_band` `1` for 1–7 days after `through_date`, `2` for 8–30, `3` for 31–90, or `4` for over 90. It selects only dated rows after the inclusive `through_date`; it composes with expiry status, date bounds, and other trace scopes before filtered totals and paging. UOM results echo both fields; invalid active codes and noninitial disabled values are rejected. Set `filter_allocation_age_band = abap_true` with `allocation_age_band` `1` for 1–7 days since expiry, `2` for 8–30, `3` for 31–90, or `4` for over 90. It selects only rows expiring before `as_of_date`; it composes with other trace scopes before filtered totals and paging. UOM results echo both fields; invalid active codes and noninitial disabled values are rejected. Set `filter_allocation_qty_from` with `allocation_qty_from` and `filter_allocation_qty_to` with `allocation_qty_to` independently to select rows by inclusive allocation-quantity bounds in base units. Active bounds may be zero but not negative; disabled bound values must be initial, and two active bounds must be ascending. Quantity bounds compose with the other trace scopes before filtered totals and paging; UOM requests forward them and results echo the base-unit values. Each batch expiry result also reports `allocation_expiry_statuses`, a fixed eight-row matrix keyed by expiry state (`E`, `U`, `A`, `D`) and allocation pass (`M`, `F`) in that order. Zero combinations remain present. The counts sum to matched plus fallback allocation row counts, and the quantities sum to matched plus fallback allocation quantity; this summary stays full-scope across trace filters and pages. UOM results preserve expiry-state/pass order and counts and include base and requested-unit quantities. Allocation detail rows expose `expiration_date_source`: `P` for the plant-level MCHA date, `G` for the global MCH1 fallback, or blank when no source was resolved; UOM details echo the marker. Set `filter_allocation_source = abap_true` and `allocation_expiry_source` to `P`, `G`, or blank to select that source. An active blank value selects blank markers; only `P`, `G`, and blank are valid, and the value must be initial when disabled. This filter composes with the other allocation scopes before filtered totals and paging. Each result also includes `allocation_expiry_sources`, a fixed six-row matrix in source/pass order: `P/M`, `P/F`, `G/M`, `G/F`, blank/M, blank/F. Its counts and quantities reconcile to the full matched plus fallback allocation totals and stay full-scope across trace filters and pages. UOM rows retain source/pass order and counts and provide base and requested-unit quantities. The `alloc_expiry_src_statuses` result adds a fixed 24-row cross-matrix ordered by source (`P`, `G`, blank), expiry status (`E`, `U`, `A`, `D`), and allocation pass (`M`, `F`). It partitions both existing matrices, keeps zero combinations, and reports counts plus quantities; UOM rows preserve this order and convert each quantity. Each result also includes `alloc_expiry_src_gap_bands`, a fixed 60-row source/gap-band/pass matrix. It partitions allocation details by expiry source (`P`, `G`, blank), all ten signed gap bands, and pass (`M`, `F`), retaining zero combinations and reconciling counts and quantities to the full trace. UOM rows preserve the order and counts and convert each quantity. Each allocation result also includes `alloc_due_src_bands`, a fixed 42-row matrix ordered by expiry-date source (`P`, `G`, blank), due horizon (`O` overdue, `T` today, `1` 1–7 days, `2` 8–30, `3` 31–90, `4` over 90, `U` undated), and allocation pass (`M`, `F`). It partitions the full allocation details by source and pass, retains zero combinations, and reports row counts and quantities; UOM results preserve the order and counts and convert each quantity. Allocation detail rows also report `days_to_expiration`, calculated as `expiration_date - as_of_date`: negative values are expired, zero is the as-of date, and positive values are upcoming or after-window. The value remains initial for undated rows and is echoed unchanged in UOM detail. Optional `filter_alloc_expiry_days_from` with `alloc_expiry_days_from` and `filter_alloc_expiry_days_to` with `alloc_expiry_days_to` apply inclusive signed day-delta bounds; either bound can be used alone, and two active bounds must be ascending. Negative values select expired rows, zero selects expirations on `as_of_date`, and positive values select upcoming or after-window rows. Active bounds omit undated rows, and UOM results echo the base-day values. Allocation detail rows also report `expiry_due_relation`: `B` when expiry precedes the required date, `S` on the same date, `A` after the required date, or `U` when either date is missing. `days_required_after_expiry` is the signed difference `required_date - expiration_date`; positive values show how many days demand follows expiry, negative values show expiry follows demand, and the value is initial when either date is missing. UOM detail rows echo both fields. Set `filter_allocation_expiry_due = abap_true` and `allocation_expiry_due` to `B`, `S`, `A`, or `U` to filter allocation details by this relation. The selector composes with the other allocation filters before filtered counts and pagination; UOM results echo both fields. Each allocation result also includes `expiry_due_relations`, a fixed eight-row summary ordered by relation (`B`, `S`, `A`, `U`) and allocation pass (`M`, `F`). It reports full-scope row counts and quantities across trace filters and pages, retains zero combinations, and reconciles to matched plus fallback totals; UOM results preserve the order and counts and convert each quantity. The active selector uses both inclusive signed bounds; zero is a valid endpoint, and `allocation_expiry_gap_from` must not exceed `allocation_expiry_gap_to`. Rows with either date missing are omitted. The filter composes before counts and pagination, and UOM results echo the flag and bounds. Allocation details also expose `expiry_due_gap_band`: `P1` through `P4` mean demand falls 1–7, 8–30, 31–90, or over 90 days after expiry; `Z` is the same day; `N1` through `N4` mean expiry falls 1–7, 8–30, 31–90, or over 90 days after demand; `U` means either date is missing. Each result includes `expiry_due_gap_bands`, a fixed 20-row matrix ordered by those ten bands and allocation pass (`M`, `F`), retaining empty combinations. Counts and quantities reconcile to matched plus fallback allocations across trace filters and pages. UOM details echo the band, and UOM summary rows preserve order and counts while converting quantities. Set `filter_allocation_gap_band = abap_true` with `allocation_gap_band` set to `P1`, `P2`, `P3`, `P4`, `Z`, `N1`, `N2`, `N3`, `N4`, or `U` to filter trace details by one named band. It composes with the signed range and other allocation scopes before counts and pagination. Invalid active codes and noninitial inactive values are rejected; UOM results echo both fields. Each allocation result also reports `max_expiry_due_gap`, the largest positive `required_date - expiration_date` difference across the full trace, with reservation, pass, actual stock keys, dates, and quantity. Equal gaps keep the first row in stable detail order; fields are initial when no allocation has a positive gap.  Each result also includes `max_required_before_expiry_gap`, the largest positive `expiration_date - required_date` difference across the full trace, with reservation, pass, actual stock keys, dates, and quantity. Equal gaps keep the first row in stable detail order; fields are initial when no allocation expires after its required date. UOM results echo the identity and convert the quantity.

Every eligible open reservation now has one `resv_alloc_summaries` row,
including fully allocated reservations. Each row carries the reservation context,
required, withdrawn, open, allocated, matched, fallback, and uncovered quantities,
plus `allocation_outcome`: `F` fully allocated, `P` partially allocated, or `U`
unallocated. Each row also carries `days_until_required`, calculated as
`required_date - as_of_date`: negative is overdue, zero is due on the as-of
date, and positive is future-dated. An initial required date leaves the count
at zero, so use the date field to identify undated rows. UOM summaries echo
the day count. Rows sort by reservation/item. `maximum_resv_alloc_rows = 0`
returns all rows; values 1–500 cap the page. Set
`filter_resv_alloc_cursor = abap_true` with the previous reservation number and
item in `resv_alloc_cursor_number` and `resv_alloc_cursor_item` for an exclusive
continuation. `total_resv_alloc_summary_count`,
`returned_resv_alloc_row_count`, and `is_resv_alloc_truncated` describe the page;
when truncated, `next_resv_alloc_cursor_number` and
`next_resv_alloc_cursor_item` identify its last row. Allocation summary totals
remain complete across pages. Set
`filter_resv_alloc_outcome = abap_true` with `resv_alloc_outcome` set to
`F`, `P`, or `U` to restrict summary rows before pagination. The summary
total count covers matching outcomes within the other active summary filters,
while allocation counts and quantities stay full scope; UOM results echo
this filter. Set `filter_resv_alloc_date_bucket = abap_true` with
`resv_alloc_date_bucket` set to `O` for overdue, `T` for due today, `F` for
future-dated, or `U` for undated rows, based on `as_of_date`. The bucket filter
is applied before counting and pagination and composes with the other summary
filters; UOM results echo the flag and bucket. Set
`filter_resv_alloc_reservation = abap_true` with
`resv_alloc_reservation_number` and `resv_alloc_reservation_item` to select
one summary. Both key fields are required when enabled and initial otherwise.
The reservation scope combines with the outcome filter before pagination; an
active cursor must use the selected reservation key. UOM results echo the
selected key. Optional inclusive `resv_alloc_required_date_from` and
`resv_alloc_required_date_to` bounds filter by required date. Either bound is
allowed, and two bounds must be ascending. When either is set, undated rows
are omitted. Date and selector filters apply before pagination, and UOM
results echo the bounds. Set `filter_resv_alloc_cov_from = abap_true` with `resv_alloc_coverage_from` and/or `filter_resv_alloc_cov_to = abap_true` with `resv_alloc_coverage_to` to select an inclusive allocation-coverage percentage range from 0 through 100. Either bound is optional; when both are enabled, the lower bound must not exceed the upper bound. A disabled bound must be initial. Coverage bounds compose with the other summary selectors before filtered counts and pagination, and UOM results echo both flags and values. Set `filter_resv_fallback_pct_from = abap_true` with `resv_fallback_pct_from` and/or `filter_resv_fallback_pct_to = abap_true` with `resv_fallback_pct_to` to select an inclusive 0–100 range over each summary row’s `fallback_share_pct`. Either bound is optional; when both are enabled, the lower bound must not exceed the upper bound. A disabled bound must be initial. Fallback-share bounds apply before summary counts and pagination and compose with the other selectors. UOM results echo both flags and values.
Matched-share bounds apply before summary counts and pagination and compose with the other selectors. Set `filter_resv_matched_pct_from = abap_true` with `resv_matched_pct_from` and/or `filter_resv_matched_pct_to = abap_true` with `resv_matched_pct_to` to select an inclusive 0–100 range over each summary row’s `matched_share_pct`. Either bound is optional; when both are enabled, the lower bound must not exceed the upper bound. A disabled bound must be initial. UOM results echo both flags and values.
Set `filter_resv_short_pct_from = abap_true` with `resv_short_pct_from` and/or `filter_resv_short_pct_to = abap_true` with `resv_short_pct_to` to select an inclusive 0–100 range over each summary row’s `allocation_shortage_pct`. Either bound is optional; when both are enabled, the lower bound must not exceed the upper bound. A disabled bound must be initial. Shortage-percentage bounds apply before summary counts and pagination and compose with the other selectors. UOM results echo both flags and values.
Set `filter_resv_fallback_qty_from = abap_true` with `resv_fallback_qty_from` and/or `filter_resv_fallback_qty_to = abap_true` with `resv_fallback_qty_to` to filter summary rows by an inclusive fallback-allocation quantity range in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. The quantity range composes with other summary selectors before filtered counts and paging. UOM results echo the flags and base-unit bounds unchanged.
Set `filter_resv_matched_qty_from = abap_true` with `resv_matched_qty_from` and/or `filter_resv_matched_qty_to = abap_true` with `resv_matched_qty_to` to filter summary rows by an inclusive matched-allocation quantity range in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Matched quantity bounds compose with the fallback and shortage selectors before filtered counts and paging. UOM results echo the flags and base-unit bounds unchanged.
Set `filter_resv_alloc_qty_from = abap_true` with `resv_alloc_qty_from` and/or `filter_resv_alloc_qty_to = abap_true` with `resv_alloc_qty_to` to filter summary rows by inclusive `allocated_quantity` in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Allocated-quantity bounds apply before summary counts and paging and compose with matched, fallback, and shortage selectors. UOM results echo the flags and base-unit bounds unchanged.
Set `filter_resv_open_qty_from = abap_true` with `resv_open_qty_from` and/or `filter_resv_open_qty_to = abap_true` with `resv_open_qty_to` to filter summary rows by an inclusive `open_quantity` (remaining reservation demand) range in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Open-quantity bounds apply before summary counts and paging and compose with allocated, matched, fallback, and shortage selectors. UOM results echo the flags and base-unit bounds unchanged.
Set `filter_resv_req_qty_from = abap_true` with `resv_req_qty_from` and/or `filter_resv_req_qty_to = abap_true` with `resv_req_qty_to` to filter summary rows by an inclusive `required_quantity` range in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Required-quantity bounds apply before summary counts and paging and compose with the other summary selectors. UOM results echo the flags and base-unit bounds unchanged.
Set `filter_resv_withdraw_qty_from = abap_true` with `resv_withdraw_qty_from` and/or `filter_resv_withdraw_qty_to = abap_true` with `resv_withdraw_qty_to` to filter summary rows by an inclusive `withdrawn_quantity` range in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Withdrawn-quantity bounds apply before summary counts and paging and compose with the other summary selectors. UOM results echo the flags and base-unit bounds unchanged.
Set `filter_resv_alloc_short_from = abap_true` with `resv_alloc_short_from` and/or `filter_resv_alloc_short_to = abap_true` with `resv_alloc_short_to` to select an inclusive range of per-reservation `uncovered_quantity`. Bounds must be nonnegative and use the material base unit; either bound is optional, both must be ascending, and disabled values must be initial. Shortage bounds compose with the other summary selectors before filtered counts and pagination. UOM results echo the flags and base-unit bounds unchanged.
Set `omit_resv_alloc_summary_rows = abap_true` to
omit summary-row payload while retaining the scoped total count. It requires
`maximum_resv_alloc_rows = 0` and no active summary cursor; UOM results echo
the flag. UOM pages include base and requested-unit amounts for every
quantity; each continuation recalculates against current
reservation and stock data.

`first_uncovered_required_date`, `first_uncovered_resv_number`, and
`first_uncovered_resv_item` identify the earliest known requirement date among
those rows. Undated rows do not set this summary; equal dates use reservation
and item order. UOM results echo the date and key unchanged.
`days_until_first_uncovered_req` gives that date's calendar-day distance from
`as_of_date`; negative values are overdue, zero is due on the as-of date, and
positive values are due later. UOM results echo this count unchanged.
Each expiry detail row also includes `days_until_required`, measured from the
request's `as_of_date`. Negative is overdue; zero is due that day when
`required_date` is present. An initial required date leaves this integer at
zero, so check the date field to distinguish an undated row. UOM rows echo the
day count unchanged. Uncovered residuals are also grouped into overdue,
due-today, future-dated, and undated buckets. The base result returns each
bucket's quantity and row count as `overdue_uncovered_resv_qty` /
`overdue_uncovered_row_count`, `due_today_uncovered_resv_qty` /
`due_today_uncovered_row_count`, `future_uncovered_resv_qty` /
`future_uncovered_row_count`, and `undated_uncovered_resv_qty` /
`undated_uncovered_row_count`. The four quantities sum to
`uncovered_open_resv_quantity` and the counts sum to
`uncovered_open_resv_row_count`. UOM results provide converted amounts through
`base_overdue_uncovered_qty` / `src_overdue_uncovered_qty`,
`base_due_today_uncovered_qty` / `src_due_today_uncovered_qty`,
`base_future_uncovered_qty` / `src_future_uncovered_qty`, and
`base_undated_uncovered_qty` / `src_undated_uncovered_qty`; counts are echoed.
All eligible open demand is also grouped into overdue, due-today, future-dated, and undated buckets, regardless of local allocation outcome. The four quantities reconcile to `open_reservation_quantity`, and the counts reconcile to `open_reservation_row_count`; demand already allocated remains included. UOM expiry results expose `base_overdue_open_resv_qty` / `src_overdue_open_resv_qty`, `base_due_today_open_resv_qty` / `src_due_today_open_resv_qty`, `base_future_open_resv_qty` / `src_future_open_resv_qty`, and `base_undated_open_resv_qty` / `src_undated_open_resv_qty`; counts are echoed unchanged.
`resv_alloc_open_demand_bands` cross-tabulates the same demand by allocation outcome (`F` fully allocated, `P` partial, `U` unallocated) and required-date bucket (`O` overdue, `T` due today, `F` future, `U` undated). It always returns all 12 combinations in outcome/date order, including zero rows; quantities and counts reconcile to `open_reservation_quantity` and `open_reservation_row_count`. UOM bands preserve the order and expose `base_open_quantity` and `source_open_quantity` with the row counts unchanged. `open_resv_due_horizon_bands` returns a fixed seven-row breakdown: `O` overdue, `T` due today, `1` due in 1–7 days, `2` due in 8–30 days, `3` due in 31–90 days, `4` due after 90 days, and `U` undated. These calendar-day ranges are non-overlapping and use `as_of_date`; counts and quantities sum to the eligible open reservation totals. UOM bands preserve order and counts and provide `base_open_quantity` and `source_open_quantity`. reservation summary pages can filter by the same codes with `filter_resv_alloc_due_horizon = abap_true` and `resv_alloc_due_horizon`; the scope composes with outcome, coarse date bucket, exact reservation, date range, and cursor filters before totals and pagination. unknown active codes and nonblank inactive selectors are rejected, and uom results echo the selector. set `filter_resv_alloc_sequence = abap_true` with a positive `resv_alloc_sequence` to select one summary by its shared-stock allocation processing position. This selector composes with the other summary filters before totals and pagination; a disabled selector must be initial, and UOM results echo both fields. Set `filter_resv_alloc_seq_from = abap_true` with `resv_alloc_seq_from` and/or `filter_resv_alloc_seq_to = abap_true` with `resv_alloc_seq_to` to filter summary rows by an inclusive `allocation_sequence` range. Bounds must be positive integers; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Sequence bounds apply before summary counts and paging, compose with the exact-sequence selector, and leave full-scope allocation-detail counts unchanged. UOM results echo both flags and values. The result also reports `filtered_resv_alloc_qty`, `filtered_resv_matched_qty`, `filtered_resv_fallback_qty`, `filtered_resv_open_qty`, and `filtered_resv_uncovered_qty` for every summary row matching the selectors before cursor and page selection. These totals reconcile as allocated = matched + fallback and open = allocated + uncovered, and remain unchanged across cursor continuations. UOM results report base and requested-unit totals in `base_filtered_resv_alloc_qty` / `src_filtered_resv_alloc_qty`, `base_filtered_resv_matched_qty` / `src_filtered_resv_matched_qty`, `base_filtered_fallback_qty` / `src_filtered_fallback_qty`, `base_filtered_resv_open_qty` / `src_filtered_resv_open_qty`, and `base_filtered_resv_short_qty` / `src_filtered_resv_short_qty`. Filtered summary pages also report weighted `filtered_resv_coverage_pct` and `filtered_resv_shortage_pct`, based on allocated/open and uncovered/open totals for matching rows before cursor and page selection. The percentages sum to 100 when filtered open demand exists and remain zero when it does not; UOM results echo them unchanged. The same summaries report weighted `filtered_resv_matched_pct` and `filtered_resv_fallback_pct`, calculated from matched/open and fallback/open totals; together they equal coverage. UOM results echo both percentages unchanged. The base result also identifies `next_open_resv_required_date`, the earliest eligible dated open reservation with a required date on or after `as_of_date`; overdue and undated rows are skipped. `next_open_resv_number` and `next_open_resv_item` identify it, and `days_until_next_open_resv_req` reports the calendar-day distance, including zero when due today. Equal-date rows break ties by reservation number and item. UOM results echo all four fields unchanged.
Each result also identifies the earliest positive-stock upcoming row through
`next_upcoming_storage_location`, `next_upcoming_batch`, and
`next_upcoming_valuation_type`. Its `next_upcoming_expiration_date` and
`days_to_next_expiration` identify the date and its calendar-day distance from
the as-of date. Ties follow the row sort order. The selected row's unrestricted,
reservation-net available, QI, and blocked quantities are included in base
units; UOM results include both base and requested-unit quantities.
`next_expiry_batch_count` counts all positive-stock batch/location/valuation
rows sharing that earliest upcoming date. `next_expiry_unrestricted_qty`,
`next_expiry_available_qty`, `next_expiry_quality_qty`, and
`next_expiry_blocked_qty` total those rows across locations, batches, and
valuation types. The UOM result echoes the count and carries the aggregate
quantities in base and requested units; all are zero when there is no in-window
upcoming row.
`next_expiry_plant_src_count`, `next_expiry_global_src_count`, and
`next_expiry_other_src_count` split that cohort by the resolved date source
(`p`, global fallback `g`, or other/blank). They partition
`next_expiry_batch_count`; UOM results echo them unchanged.
The day
count is zero when a batch expires on the as-of date. Identity and date fields
remain initial and quantities remain zero when no upcoming row has positive
stock. UOM results echo the identity and date fields unchanged.
Each result also identifies the first positive-stock expired row through
`first_expired_storage_location`, `first_expired_batch`, and
`first_expired_valuation_type`, with its expiration date and
`days_since_first_expired_date`. It follows expiration, batch, location, and
valuation order. Its unrestricted, reservation-net available, QI, and blocked
balances are included in base units; UOM results carry base and requested-unit
values. These fields are initial or zero when there is no positive-stock
expired row.
`first_expiry_batch_count` counts all positive-stock batch/location/valuation
rows sharing `first_expired_expiration_date`. `first_expiry_unrestricted_qty`,
`first_expiry_available_qty`, `first_expiry_quality_qty`, and
`first_expiry_blocked_qty` total those rows across locations, batches, and
valuation types. UOM results echo the count and include the aggregate amounts
in base and requested units; all are zero when no expired row has positive stock.
`first_expiry_plant_src_count`, `first_expiry_global_src_count`, and
`first_expiry_other_src_count` split that cohort by the resolved date
source (`p`, global fallback `g`, or other/blank). The three counts partition
`first_expiry_batch_count`; UOM results echo them unchanged.
`GET_EXPIRY_EXPOSURE_UOM_BULK` adds one requested unit per keyed request. Each
batch row and each expired, upcoming, undated, and after-window total includes
the material base-unit quantity and the converted quantity; undated and
after-window quantities are summary only. The batch identity and expiry status
remain nested with dated rows. The method caches ratios by material/unit and
runs one bulk batch read.
Bad date windows, duplicate request IDs, and unknown units are rejected before
the batch stock read. Request-specific reservation keys are validated before
unit conversion and are combined with call-wide keys for that request.
`SCRAP_EXPIRED_BATCH_STOCK` accepts a base-unit expiry exposure result and
selected storage-location, batch, valuation-type, cost-center, and quantity
values. Expiry status describes each batch at the report's as-of date and is
validated against that date. Scrap eligibility compares the expiration date
with the posting date, so a row reported as upcoming can qualify when it expires
before posting, provided its expiry is on or before the inclusive
`through_date`. Rows after that window belong in the after-window summary and
are rejected by direct preview and posting paths. Each quantity is limited to
the report's available unrestricted balance.
It sends movement type 551 with goods-movement code 03; `iv_test_run` supports
SAP simulation. SAP documents 551 as withdrawal for scrapping from
unrestricted-use stock ([movement types](https://help.sap.com/docs/SAP_ERP/cfff13ea14f3430488af41bbc02dbb69/96d7c353b677b44ce10000000a174cb4.html?locale=en-US)).
Every rechecked scrap entry point compares the supplied second report before
posting. If the original report has a `snapshot_timestamp`, the rechecked
report must carry a strictly later timestamp; reports created before timestamp
support retain the earlier comparison behavior. The timestamp confirms read
order but does not lock stock through SAP posting.
`SCRAP_EXPIRED_QI_BATCH_STOCK` applies the expiry checks to quality-inspection
stock and posts movement type 553. Each selected quantity is capped by that
batch row's reported QI balance; unrestricted availability does not increase
the QI limit. It sends goods-movement code 03 and supports SAP simulation with
`iv_test_run`.
`SCRAP_EXPIRED_QI_BATCH_UOM` accepts per-selection units, converts each
quantity to the material base unit, then applies the same expiry and QI-balance
checks before posting movement 553.
`SCRAP_EXPIRED_QI_RECHECKED` compares each selected batch's expiry and
stock-category balances and effective reservation exclusion keys across the
original and rechecked exposures, then posts against the rechecked QI quantity.
The comparison narrows the stale-snapshot window but does not lock stock
through SAP posting.
`SCRAP_EXPIRED_QI_RECHECKED_UOM` converts each selected quantity to the material
base unit before applying that same snapshot comparison and QI-balance check.
`SCRAP_EXPIRED_BLOCKED_STOCK` posts movement type 555 from blocked stock and
limits each selected quantity to that batch row's reported blocked balance.
SAP documents 555 as withdrawal for scrapping from blocked stock
([movement types](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/ee6ff9b281d8448f96b4fe6c89f2bdc8/8b7b5fe73ef54063a2bfcfbe83cebd38.html)).
`SCRAP_EXPIRED_BLOCKED_UOM` converts per-selection quantities to the material
base unit before applying the same expiry and blocked-balance checks.
`SCRAP_EXPIRED_BLOCKED_RECHECKED` compares each selected batch's expiry and
stock-category balances and effective reservation exclusion keys across two
exposures, then posts against the rechecked blocked quantity. It narrows the
stale-snapshot window but does not lock stock through posting.
`SCRAP_EXPIRED_BLOCKED_RECHECKED_UOM` converts the selected
quantities to base units before that comparison.
`SCRAP_EXPIRED_SCRAP` and `SCRAP_EXPIRED_SCRAP_UOM` accept the stock category
with the selected quantities, then route to its guarded 551 unrestricted, 553
QI, or 555 blocked posting path. The UOM form converts each selection before
the category-specific balance check. Invalid categories are rejected before a
goods-movement call.
`SCRAP_EXPIRED_CAT_RECHECKED` and `SCRAP_EXP_CAT_RECHECK_UOM` apply the same
category selection to the original and rechecked expiry snapshots. They retain
the category-specific change checks and post against the rechecked snapshot;
the UOM form converts selections before those comparisons.
`PREVIEW_EXPIRED_SCRAP` accepts a stock category, selects expired batches in
earliest expiry order, and returns base-unit quantities ready for the matching
scrap posting method. Rows without a storage location or batch are rejected
before allocation. It reports a shortfall when stock is insufficient;
upcoming batches can qualify by the posting date only if they expire on or
before the exposure's inclusive `through_date`.
`iv_require_full_quantity` clears the proposed splits unless the full request
can be covered. `selection_details` returns each split's expiration date,
`expiration_date_source`, and `days_expired_at_posting` (posting date minus
expiration date) in the same order as `selections`; all-or-nothing shortfalls
clear both lists. Each detail row includes `location_priority_rank`: zero
without a priority list, the caller's rank for listed locations, and one after
the list for locations not listed. This explains location tie ordering in
FEFO results.
The material-base-unit `category_balance` is the source quantity used to cap
that split: reservation-net `available_quantity` for unrestricted stock,
`quality_inspection_quantity` for QI stock, or `blocked_quantity` for blocked
stock. It may exceed the selected `quantity` when the preview allocates only
part of the batch balance.
`snapshot_timestamp` echoes the source exposure timestamp and
remains initial for legacy reports without one. The result echoes the exposure
request ID, material, plant, as-of date, through date, and posting date; UOM and
FEFO results preserve this context in their nested preview.
`excluded_reservations` echoes the source exposure's reservation exclusions
unchanged, including an empty list; UOM and FEFO results preserve them in the
nested preview. Storage-location priority
breaks expiry-date ties. The blocked,
QI, and unrestricted preview methods (`PREVIEW_EXPIRED_BLOCKED_SCRAP`,
`PREVIEW_EXPIRED_QI_SCRAP`, and `PREVIEW_EXP_UNRESTRICTED_SCRAP`) are
category-specific wrappers. Their
balances are blocked quantity, reported QI quantity, and reservation-net
`available_quantity`, respectively, and their movement types are 555, 553, and
551.
`PREVIEW_EXPIRED_SCRAP_UOM` converts a requested alternative-unit quantity to
the material base unit before allocation for any category. It echoes the
original quantity/unit and base quantity/unit; selections remain in base units
for posting, and the nested preview retains each split's expiry provenance.
`PREVIEW_EXPIRED_BLOCKED_SCRAP_UOM` remains as a blocked-category compatibility
wrapper.
`SCRAP_EXPIRED_FEFO` and `SCRAP_EXPIRED_FEFO_UOM` combine the category preview
with its matching posting call. They return the preview alongside the posting
result and mark whether posting was attempted. Full allocation is required by
default; set `iv_require_full_quantity = abap_false` to post an available
partial allocation. A supplied `is_rechecked_exposure` is validated before
allocation and checks selected splits against a second snapshot before posting.
Its `is_rechecked` flag and `rechecked_snapshot_timestamp` are returned even
when full-quantity shortfall prevents posting. Without a supplied recheck,
`is_rechecked` stays false and the timestamp stays initial. Bulk and atomic nested
FEFO rows, including bulk UOM requests, preserve this metadata on shortfall and
skipped requests. Skipped UOM rows also retain the converted base requested
quantity and shortfall preview. `iv_test_run` retains SAP's simulation
behavior. Direct FEFO results echo `require_full_quantity` so
saved summaries identify whether partial posting was allowed. Bulk and atomic
results echo the policy at the group level and on each request's nested FEFO
result, including empty, shortfall, and skipped rows.
`SCRAP_EXPIRED_FEFO_BULK` and `SCRAP_EXPIRED_FEFO_BULK_UOM` prevalidate all
request IDs, units, and supplied second exposures, then return an outcome row
for each request while continuing after a failed goods-movement response. Each
request has its own goods-movement call. Successful requests commit
independently outside test-run mode, so earlier successful requests remain
committed if a later request fails. The bulk summary reports successful and
failed counts, test-run state, and whether any request committed. Set a
request's `rechecked_exposure` to compare selected batch status, expiry, and
category balances across snapshots before the first post. The complete supplied
recheck is validated for matching request context, reservation exclusions,
timestamp order, unique batch keys, and valid expiry status/date even when no
selection results. Optional positive
`it_request_priorities` ranks, keyed by exposure `request_id`, post lower ranks
first; unranked requests follow ranked requests, and ties keep caller order.
All priority rows are validated before posting. Result rows stay in caller
order and echo `priority_rank` and `is_priority_ranked`; unranked rows use rank
zero and false. With no priority rows, requests post in caller order.
Stop-on-failure follows the ranked posting order; result rows remain in caller
order. Each result row exposes a one-based `allocation_sequence` in posting
order; skipped rows retain their scheduled sequence.
Set `iv_stop_on_failure = abap_true` to stop after the first request shortfall,
returned posting error, or captured request-level exception. Later requests
are marked `is_skipped`; their count appears in `skipped_count`, separate from
`failed_count`. The default is to
continue processing the remaining requests.
`stopped_on_failure` is true whenever the option stops the execution loop,
including when the failed request was last and `skipped_count` is zero.
A `zcx_invalid_goods_movement` raised during a request's posting operation is
captured as an error message on that request row; the bulk summary still
reports earlier independent commits. The row sets `is_exception` and leaves
`is_attempted` false because no goods-movement result was returned.
`exception_count` counts these request-level exceptions; it is a subset of
`failed_count`.
`SCRAP_EXP_FEFO_BULK_ATOMIC` and `SCRAP_EXP_FEFO_BULK_ATOMIC_UOM` provide an
all-or-nothing alternative. They validate all request IDs, exposure data, and
unit conversions before the first goods-movement call, defer each movement's
commit, and commit once after every request succeeds. A full-quantity shortfall
prevents all movement calls; with partial allocation enabled, every request
still needs at least one positive selection. Any movement or shared-commit
failure rolls back the group and clears provisional document numbers from the
result. Set `rechecked_exposure` per request to compare the selected batches
with a second snapshot before any movement call. Before allocation, the
recheck must match request identity, date window, and reservation exclusions;
timestamped originals require a later timestamp. Every recheck row must have a
unique batch key and a valid expiry status/date, even when a full-quantity
shortfall leaves that request with no selection. The group preflight also
aggregates quantities for matching material, plant, location, batch, valuation
type, and stock category, capped by the smallest balance in the supplied
exposures, to prevent overlapping snapshots from allocating the same stock
twice. Atomic result `shared_capacities` returns each pooled
material/plant/location/batch/valuation/category key, including keys with no
planned selection. Each row reports the material `base_unit`, the minimum
`available_quantity` across supplied initial and recheck exposures, the
`allocated_quantity` planned by preflight, and `remaining_quantity` after that
plan. It also reports exposure-row and distinct-request counts, the
`rechecked_exposure_count`, positive-balance counts, minimum and maximum
request IDs and tie counts, capacity spread, timestamp bounds, untimestamped
count, and selection-row count. Rows sort by key. These are planned selections
from the supplied snapshots, not committed stock changes; the summary remains
available on preflight shortfall or a later rollback. Optional positive
`it_request_priorities` ranks, keyed by exposure `request_id`, allocate and post
lower ranks first, followed by unranked requests and caller-order ties. Shared
capacity is consumed in this order when partial allocation is enabled. Invalid,
duplicate, and unknown priority rows are
rejected before stock reads in the stock-backed method; result rows remain in
caller order and echo rank metadata. Each row also exposes a one-based
`allocation_sequence` in shared-capacity allocation and posting order. A
`zcx_invalid_goods_movement` raised during one deferred movement is captured on that request row; the service
rolls back pending movements outside
test-run mode and clears provisional documents. The row sets `is_exception`
and leaves `is_attempted` false because no goods-movement result was returned.
`exception_count` reports the request-level exception and is included in
`failed_count`, which counts the whole failed group. Test-run mode simulates
each movement and skips the shared commit.
`SCRAP_FEFO_ATOMIC_FROM_STOCK` combines the stock read and atomic posting. It
accepts material, plant, expiry window, requested quantity/unit, category, and
cost center for each request, bulk-loads the exposure snapshots, and forwards
call-wide and request-specific reservation exclusions to both reads. Each
request-specific exclusion set is combined with the call-wide set only for that
request's availability estimate. It validates request identities, dates,
categories, base-unit mappings, and requested units before either stock read.
Request fields, complete and unique call-wide and per-request reservation
exclusions, and priority rows are prevalidated before any UOM conversion or
repository read.
It reads a second exposure by default
and rejects changes to selected batches before posting. The result includes
both snapshots and the atomic posting result. The factory-created goods
movement service is wired with the repository-backed expiry reader; callers
that construct it directly can inject `zif_batch_expiry_reader` themselves.
The reader interface exposes both base-unit and unit-aware bulk expiry reads
and forwards reservation exclusions to the stock service.
The exposure is a local snapshot and does not lock or re-read stock before the
posting call, so SAP remains authoritative for the quantity at posting time.
A supplied second exposure narrows this window; it does not prevent stock from
changing after the comparison. If the original snapshot has a timestamp, the
recheck must have a strictly later timestamp; untimestamped legacy reports use
the existing batch-state comparison. Both snapshots must echo each request's
call-wide and request-specific exclusion union. Rows without a storage
location or batch, and duplicate location/batch/valuation rows, reject the
request before allocation or posting. The first snapshot is validated before
requesting the recheck, so an invalid original stops after one stock read.
Optional `it_request_priorities` also applies to this stock-backed atomic
method. It validates ranks before the exposure reads and returns ranked rows in
caller order; partial selections consume shared snapshot capacity by rank.
`SCRAP_FEFO_BULK_FROM_STOCK` provides the same stock-backed inputs with
independently committed posting. It validates all request IDs, dates,
categories, unit mappings, requested units, and priority rows before its first
stock read. Request fields, complete and unique call-wide and per-request reservation
exclusions, and priority rows are prevalidated before any UOM conversion or
repository read. It bulk-loads the expiry exposures once, then reads a second
snapshot by default and compares the selected batches before posting. If the
original snapshot is timestamped, the recheck must be strictly later.
`iv_recheck_exposure = abap_false` uses only the first snapshot.

Optional positive `it_request_priorities` ranks, keyed by exposure
`request_id`, post lower ranks first; unranked requests follow and ties keep
caller order. Result rows remain in caller order and echo rank metadata.
The preflight pools matching material/plant/location/batch/valuation/category
capacity across requests, using the smallest reported balance across both
exposure reads. A request consumes its allocation only after a successful
movement result, so a failed request releases that capacity to later requests.
Call-wide `it_excluded_reservations` applies to every exposure request, while
each request may add its own excluded reservation/item keys. The union is used
only for that request and is forwarded to both exposure reads. Requests with
matching effective exclusion sets share a bulk stock read. Both snapshots are
validated against the request's effective exclusion union. Rows without a
storage location or batch, and duplicate location/batch/valuation rows, are
rejected before posting. The first snapshot is validated before requesting the
recheck, so an invalid original stops after one stock read. Each successful
request commits independently, so a later posting failure does not undo earlier
successes. The result returns the exposure snapshots it read with the posting
summary.
`iv_stop_on_failure = abap_true` stops later posts after the first shortfall,
returned posting error, or captured request-level exception and marks their
result rows as skipped. The posting summary sets `stopped_on_failure`, even if
the failure is on the final row. When priorities are supplied, stopping follows
ranked execution order while result rows stay in caller order.
The bulk summary also reports request-level posting exceptions through
`exception_count`, included in `failed_count`.
`PREVIEW_EXP_SCRAP_FROM_STOCK` bulk-reads an expiry exposure and returns a
posting-ready FEFO preview for each request without calling the goods-movement
BAPI. It validates unique request IDs, dates, categories, base-unit mappings,
and requested units before reading stock. Request fields, complete and unique call-wide and per-request reservation
exclusions, and priority rows are prevalidated before any UOM conversion or
repository read. It
supports call-wide exclusions and per-request excluded reservation/item keys; matching effective sets share a
bulk read. Each returned exposure is validated against the request's effective
exclusions before allocation. Request identity and dates must be complete and
valid. Each dated row must have a valid expiry date and a status consistent
with its as-of date. Upcoming rows after the inclusive `through_date` are rejected;
they belong in the after-window summary. Negative available-unrestricted
balances and available balances above nonnegative unrestricted stock are also
rejected. A row without a
storage location or batch is rejected before capacity is pooled. Duplicate
location/batch/valuation rows in one exposure are also rejected before
capacity is pooled. It requires full allocation
by default. Set `iv_require_full_quantity` to
`abap_false` to request partial preview selections. These selections are local
snapshots and do not reserve inventory. Nested preview `selection_details`
retain each selected batch's expiration date, expiry source marker, and days
past expiry on the requested posting date. Matching
batches across requests share
capacity by material, plant, location, batch, valuation type, and category; the
preview uses the smallest reported balance and consumes it in caller order.
`shared_capacities` returns each pooled key with its material base unit, the
smallest reported balance as `available_quantity`, total selections across
requests as `allocated_quantity`, and their difference as `remaining_quantity`.
`reported_exposure_count` counts contributing exposure rows, and
`contributing_request_count` counts distinct requests represented by those rows;
initial and recheck snapshots from one request count once.
`rechecked_exposure_count` counts rows from supplied second snapshots; it is
zero for stock-backed previews, which read one snapshot per request.
`positive_exposure_count` counts rows whose selected stock category has a
positive balance. `earliest_snapshot_timestamp` and `latest_snapshot_timestamp`
bound the UTC read times of contributing rows with timestamps; both remain
initial when none have one. `untimestamped_exposure_count` counts rows without a read
timestamp. `limiting_request_id` identifies a request whose balance set the
minimum; ties
keep the first request in caller order. `minimum_exposure_count` counts
exposure rows tied at that minimum. `maximum_reported_quantity` is the
largest observed balance. `maximum_reported_request_id` identifies a request
that supplied it; ties keep the first request in caller order.
`maximum_exposure_count` counts exposure rows tied at that maximum.
`capacity_spread_quantity` is the maximum minus the minimum;
`available_quantity` remains the allocation cap.
`allocation_row_count` counts the positive request-preview selection rows that
drew from that key.
Rows sort by material, plant, location, batch, valuation type, and category.
The result also includes total request, fully allocated, and shortfall counts
and a group-level `is_fully_allocated` flag. Empty input returns zero counts and
`abap_true` for that flag. `require_full_quantity` echoes the all-or-nothing
policy used for the call, including when the request list is empty.
Optional positive `it_request_priorities` ranks allocate smaller ranks first.
Requests without a rank follow ranked requests; equal ranks preserve caller
order, and returned results always stay in caller order. Duplicate, unknown, or
nonpositive priority rows are rejected before stock is read. Each preview row
echoes its rank and ranked status; unranked rows use rank zero and false. The
one-based `allocation_sequence` reports priority processing order while rows
remain in caller order. Each preview row also echoes its request's UTC
`snapshot_timestamp` and effective `excluded_reservations` from the source
exposure. Rows also carry the request's `material`, `plant`, `as_of_date`,
`through_date`, and `stock_category` so callers can identify the preview scope
without looking up the original request. Rows also echo `cost_center`,
`movement_reason`, and `storage_location_priority`, even when a request selects
no stock.
`SCRAP_EXPIRED_BATCH_RECHECKED` accepts the original exposure and a second
exposure read immediately before posting. It rejects changes to the selected
batch's expiry, stock categories, available quantity, or effective reservation
exclusion keys, then posts against the rechecked result. This narrows the
stale-snapshot window; it does not lock stock between the recheck and SAP
posting.
`SCRAP_EXPIRED_RECHECKED_UOM` combines this comparison with per-selection unit
conversion; both reports must use the same request key, material, plant, and
date window.
`SCRAP_EXPIRED_BATCH_UOM` accepts a unit on each selected quantity, converts it
to the material base unit, and applies the same expiry, cost-center, and
available-balance checks before posting. Unknown units and positive quantities
that convert to zero are rejected. Each selection can include an optional
`movement_reason`; use a value configured for movement type 551 in the target
system when its configuration requires one.
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
location-level batch splits. An optional
`it_storage_location_priority` list orders fallback locations after the
preferred location; unlisted locations follow ascending code order.
The base, unit-aware, priority, and ATP batch allocators also accept
`it_request_location_priorities`. A request's positive local ranks override the
shared order; lower ranks come first, ties use location code, and unranked
locations follow by code. The selected location remains first when fallback is
enabled. Unknown request IDs, duplicate request/location rows, blank keys, and
nonpositive ranks fail before stock reads or UOM conversion. Priority and UOM
adapters map the rows through internal demand IDs, including repeated caller
IDs. Ranks order the locations within the requested batch and do not broaden
batch or location eligibility.
Base, unit-aware, priority, and ATP exact-batch allocators also accept
`it_request_locations`. Each request is limited to its listed locations, in
intersection with the shared allowlist. Scopes apply to current batch balances
and projected batch receipts; invalid scopes and preferred locations outside
their scope fail before stock or UOM reads. Priority and UOM wrappers map scopes
through internal demand IDs and return the caller-facing scope rows.
Base and UOM exact-batch demand rows can also set
`require_full_quantity = abap_true` individually. It combines with the shared
option, leaves a short row's batch balances for later demands, and passes
through ATP. Invalid row values fail before stock reads or UOM conversion.
They can also set `minimum_coverage_pct`; the service compares eligible stock
for the selected batch and location scope before consuming any location
balance. A row below its floor receives no split, preserving that stock for
later demands. UOM, priority, and ATP adapters carry the value through.
The base, unit-aware, and ATP variants also accept caller-resolved
`it_projected_batch_receipts` in material base units. Each receipt names its
material, plant, storage location, exact batch, expiry, receipt date, and
quantity. A receipt is available only on or after its receipt date and only
for a demand whose `as_of_date` reaches that date; when the date is blank, the
current date is used for receipt gating. With safety-stock protection enabled,
receipts first replenish the residual static plant buffer. The ATP wrapper
checks the local allocation but does not send projected batch assignments to
SAP. The service does not derive these rows from planning documents.
Each returned batch allocation carries `available_from_date`. It is initial
for posted stock and contains the receipt date for projected stock; unit-aware
splits also expose the same value at the split level. Exact-batch cost-center
previews use the same metadata contract.
`iv_include_undated_batches` defaults to `abap_true`; set it to `abap_false`
to exclude current or projected exact-batch quantities without a known expiry,
even when no minimum shelf life is requested. Single-plant and cross-plant
exact-batch demand rows can set `require_known_expiry = abap_true` to exclude
undated stock for just that request, or `allow_undated_batches = abap_true` to
opt into undated stock when the shared setting is false. Cost-center batch and
FEFO preview and reservation demand rows support the same overrides, and the
single cost-center preview and reservation methods accept them as scalar
inputs. Those single methods also accept `iv_minimum_coverage_pct` from 0
through 100; it is checked against eligible base-unit stock and echoed on the
result, and a reservation is skipped when the floor leaves no allocation. The
flags cannot both be true. Base summaries and batch/location splits echo both
row settings. Date, priority, UOM, and ATP wrappers forward them. Invalid
values are rejected before UOM or stock reads.
`ALLOCATE_BY_BATCH_IN_UNITS` accepts multiple requests in material-specific
units while keeping each requested batch fixed. It shares that batch's stock
across demands in input order and supports the same preferred-location fallback
as the base-unit method. Results include base-unit summaries and location/batch
splits together with converted source-unit quantities; they do not substitute
stock from a different batch.
Use `ALLOCATE_BY_BATCH_PRIORITY` or `ALLOCATE_BY_BATCH_UOM_PRIORITY` when
requests sharing exact-batch stock need explicit precedence. Higher integer
priorities allocate first and stable ties preserve input order. Both retain the
existing location, expiry, projected-receipt, safety-stock, and full-quantity
rules; summaries and batch splits return in caller order with priority echoed.
The per-demand expiry flags also flow through both priority methods and their
ATP variants. Repeated request IDs are supported. Set
`iv_prioritize_by_date = abap_true` to
process earlier per-demand `as_of_date` values first, then higher priority for
same-date requests; each demand must provide a valid date. The UOM form returns
source and base quantities, and `ALLOCATE_BY_BATCH_UOM_ATP_PRIO` adds grouped
ATP checks by material, plant, base unit, and check date while forwarding the
same ordering option. Its blank demand dates use the shared `iv_as_of_date`.
`ZCL_STOCK_SERVICE->ALLOCATE_BY_EXPIRY` provides an explicit FEFO preview that
chooses the earliest-expiring eligible batches first. It reads batch expiration
dates, excludes batches expired before the requested as-of date, places batches
without an expiration date last, and can restrict each demand to a storage
location. With fallback enabled, it uses that location first and then considers
other locations in expiration-date order. It fetches batch status for all
unique material/plant pairs through one validated bulk repository call. An
optional `it_storage_location_priority` list breaks ties between locations for
the same batch and expiration date; it does not override the FEFO order. A
request can also pass `it_request_location_priorities` to override that shared
tie order for one request. The base, UOM, priority, and ATP variants accept the
same rows; UOM ranks map through internal demand IDs, and invalid or unknown
rows fail before stock or conversion reads. These ranks only order locations
for matching expiry and batch values, so earlier-expiring batches and batch
order remain primary. An explicit preferred location stays first when fallback
is enabled. A
`batch` field on a demand restricts it to that exact batch while retaining expiry and
minimum-shelf-life checks. Repeated demands for the same batch share its
remaining quantity in input order. This is a simple VFDAT ordering;
SAP's configurable batch determination and search strategies are not reproduced
([batch stock](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/d664bd534f22b44ce10000000a174cb4.html),
[batch search strategies](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/4eb099dbc8a6435c9b36a854a7e05522/16feb753128eb44ce10000000a174cb4.html),
[ascending shelf-life expiration sort](https://help.sap.com/docs/SAP_ERP_SPV/96bf9ad642cf4b26a29595e3d573fb8c/fa60bd534f22b44ce10000000a174cb4.html)).
`ALLOCATE_QUALITY_BY_EXPIRY` applies the same FEFO preview to raw
quality-inspection batch quantities from `MCHB-CINSM`. It shares each
material/plant balance across requests in input order, supports per-demand
location restrictions, fallback, and exact-batch filters, and applies shared
or per-demand expiry and minimum-shelf-life rules. `iv_require_full_quantity`
makes short requests all-or-nothing. Its batch/location splits are a local
preview; they do not
reserve stock or establish that SAP quality-management controls permit a 321
posting. `ALLOCATE_QUALITY_BY_EXPIRY_UOM` accepts material-specific
alternative-unit requests and returns the same canonical base-unit splits with
converted source quantities. `ALLOCATE_QUALITY_BY_EXPIRY_ATP` adds a grouped
plant-level ATP comparison for positive UOM allocations; it does not change the
quality-stock allocation or prove that ATP covers quality-inspection stock.
`ALLOCATE_QUALITY_UOM_ATP_PRIO` applies descending integer priority to shared
quality stock, returns summaries and batch splits in caller order with priority
echoed, then adds grouped plant ATP checks by material, plant, base unit, and
effective as-of date. ATP remains diagnostic and does not change the quality
allocation. Both quality ATP methods can report confirmation for the same plant
and date while SAP's checking rule may not include quality-inspection stock.
All six quality FEFO methods accept `it_request_location_priorities` to
override the shared location order for one request within matching batch and
expiration-date ties. Earlier expiry and batch order remain primary; UOM rows
are validated before conversion reads and mapped through internal demand IDs.
Preferred-location fallback remains first, and invalid ranks fail before stock
reads.
All six quality FEFO methods also accept `it_request_locations`; each request is
limited to its listed storage locations, intersected with the shared allowlist.
The scope applies to quality stock and projected batch receipts while preserving
expiry order among eligible stock. A preferred demand location must be inside
its request scope. Blank, unknown, duplicate, and preferred-outside-scope rows
fail before stock reads or UOM conversion, and the unit and priority adapters
echo the caller-facing scope rows.
These quality FEFO methods accept optional caller-resolved
`it_projected_batch_receipts`; for these APIs, the base-unit quantity represents
future quality-inspection stock. Receipts become available on their receipt
date and remain subject to the demand's effective as-of date, expiry, location,
and batch filters. The rows are not derived from SAP planning documents, and
quality ATP checks do not send projected batch assignments to SAP.
`ALLOCATE_BY_EXPIRY` and `ALLOCATE_BY_EXPIRY_IN_UNITS` accept
`iv_include_undated_batches`, defaulting to `abap_true`. Set it to
`abap_false` to exclude batches without an expiration date from availability,
safety-stock protection, and allocation. Single-plant FEFO and quality FEFO
rows can set `require_known_expiry = abap_true` to skip undated stock for just
that demand, or `allow_undated_batches = abap_true` to opt into it when the
shared setting is false. The flags cannot both be true. Summaries and batch
splits echo both settings, and safety-stock protection considers undated stock
only when a compatible demand can use it. Unit, priority, and ATP methods
forward the row policies. Invalid values are rejected before unit conversion
or stock reads.
`ALLOCATE_BY_EXPIRY_IN_UNITS` accepts multiple FEFO demands in material-specific
units, validates and caches every material/unit ratio before reading stock, and
allocates shared batch stock in demand order. Results include base-unit
allocation summaries and batch splits alongside converted source-unit
quantities. Base-unit split quantities remain the canonical values when
conversion to a source unit rounds to `MARD-LABST` precision.
Base and unit-aware FEFO demands can set `batch` to restrict a request to one
exact batch. Its expiration and minimum-shelf-life rules still apply; if that
batch is unavailable or ineligible, the demand receives a shortfall rather than
substituting another batch.
Each base-unit or unit-aware FEFO demand can set `minimum_shelf_life_days`.
The greater of this value and the shared `iv_min_days` applies to that demand;
a positive effective minimum excludes undated batches. Batch splits report the
effective minimum, and the unit-aware method carries each demand's value through
base-unit conversion.
Base-unit and unit-aware FEFO demands can also set `fefo_as_of_date`; the later
of that date and the shared `iv_as_of_date` controls expiry checks, and batch
splits report the effective date.
Base and UOM demand rows for `ALLOCATE_BY_EXPIRY` and
`ALLOCATE_QUALITY_BY_EXPIRY` can set `require_full_quantity = abap_true` to
make that row all-or-nothing. A short row receives no batch split and leaves
its eligible balance for later rows. The request flag combines with the
existing shared `iv_require_full_quantity`; an invalid row value is rejected
before stock reads or unit conversion.
These demand rows also accept `minimum_coverage_pct` from 0 through 100. FEFO
compares eligible dated or undated batch stock after per-demand expiry,
shelf-life, location, and receipt-date rules; quality FEFO applies the same
floor to quality-inspection stock. The check happens before any batch balance
is consumed. A demand below the floor receives no allocation, and the summary
and batch splits echo the requested threshold through UOM, priority, and ATP
wrappers.
`ALLOCATE_BY_EXPIRY_ATP` accepts unit-aware FEFO demands and a checking rule.
It returns the local FEFO estimate plus ATP checks grouped by material, plant,
base unit, and effective FEFO date. Each check covers the cumulative local
allocation through that date; rows with no local allocation do not trigger an
ATP call. This remains a preview and does not reserve stock.
`ALLOCATE_BY_EXPIRY`, `ALLOCATE_BY_EXPIRY_IN_UNITS`, and
`ALLOCATE_BY_EXPIRY_ATP` accept optional caller-resolved
`it_projected_batch_receipts` in material base units. Each receipt identifies
its material, plant, storage location, batch, expiry, receipt date, and
quantity. It becomes available only on its receipt date, including when
demands are processed out of date order; per-demand FEFO as-of dates still
control whether it can be used. With safety-stock protection enabled, due
receipts replenish any remaining static buffer before allocation. These rows
are not derived from SAP planning documents, and the ATP wrapper checks local
allocations without passing their projected batch assignments to SAP.
Base batch allocations expose the source date as
`batch_allocation-available_from_date`; unit-aware splits also expose
`available_from_date` directly. Posted stock leaves both fields initial, while
projected receipts carry their receipt date through standard and quality FEFO,
priority, date-first, ATP, and cost-center previews.
Single-plant and cross-plant exact-batch and standard FEFO splits, plus
single-plant quality FEFO splits, also echo optional projected receipt source
metadata. Component-scoped allocations expose per-demand `batch_allocations`
and `location_allocations` with receipt identity and `available_from_date`.
Automatic SAP-derived batch and location receipt projections preserve that
identity when the component preview maps them into its scoped ledger.
Set `source_type` and `source_document` together;
`source_item`, `source_plant`, and `source_schedule_line` require a source
document. Balances with different metadata remain separate, and posted stock
leaves these source fields initial. Priority, date-first, unit-aware, and ATP
wrappers preserve the metadata. Cross-plant batch splits expose the receipt's
origin as `receipt_source_plant`, since `source_plant` identifies the plant
whose stock supplied the split. Component-scoped location splits cover
residual stock, including batchless projected receipts; the allocation
summary remains authoritative for total quantities.
Single-plant exact-batch, standard FEFO, and quality FEFO allocation use checked
high-precision sums for merged projected receipt balances, available totals,
and allocation summaries. Totals outside `MARD-LABST` range raise
`ZCX_INVALID_STOCK_REQUEST` before the preview returns.
`ALLOCATE_BY_BATCH_ATP` provides the same comparison for unit-aware demands
that name an exact batch. A row's `as_of_date` overrides the shared
`iv_as_of_date` default, and the selected batch is retained through local
expiry filtering and allocation. ATP checks group the positive batch splits
by material, plant, base unit, and date, with cumulative quantities through
each date. It does not substitute a different batch or reserve stock.

Confirmed stock changes go through `ZCL_GOODS_MOVEMENT_SERVICE`, which calls
`BAPI_GOODSMVT_CREATE` through an injectable adapter. Successful postings and cancellations require both the returned material-document number and fiscal year.
Only successful create simulations may omit that generated key.
It validates common item fields and cost center or order assignments for
movement types 201/202 and
261/262; sales-order issues (231/232) require the sales order and item, and
project-WBS movements (221/222) require a WBS element. One-step plant transfers
(301/302) require a receiving plant and storage location;
two-step plant transfers use separate 303 removal and 305 putaway postings.
`ISSUE_TO_COST_CENTER` posts caller-selected material lines directly to one
cost center with movement type 201 and GM code 03. Each line includes plant,
storage location, optional batch and valuation type, quantity, and entry
unit/ISO code; the unit is passed through without local conversion. Supply
`valuation_type` for non-batch split-valuated stock. SAP validates the
valuation-type and stock combination; this direct posting method does not read
availability or run an allocation preview. All lines share one material
document and the standard simulation and commit handling.
`ISSUE_TO_COST_CENTER_IN_UNIT` accepts per-line source units and converts each
quantity to the material base unit. Pass one base-unit/ISO mapping per material;
the service checks that the conversion agrees with that mapping before posting.
Allocation-backed cost-center, project-WBS, sales-order, and quality-stock issue
adapters sum supplied split quantities in high precision before comparing them
with the preview summary. An overfull split set is rejected before the movement
API call instead of overflowing during validation. Dated location and FEFO
ATP transfer rechecks also aggregate source and batch/location totals in high
precision before comparing them with the confirmed plant quantities. Plant
transfer split totals use the same high-precision check before one-step or
two-step movement creation. Cost-center goods-issue adapters revalidate each
echoed `minimum_coverage_pct` against requested and allocated base quantities
before posting; a positive allocation below its floor is rejected, while zero
allocation remains a floor rejection subject to the existing
`iv_require_full_allocation` behavior. Sales-order aggregate and FEFO issue
adapters and quality FEFO posting adapters also revalidate each echoed floor
against requested and allocated base-unit quantities before movement creation.
Project-WBS issue and transfer adapters validate each echoed floor against
requested and allocated base-unit quantities before movement creation.
Row-wise independent-commit bulk goods-movement results expose top-level
`is_committed`: it is true when at least one non-test
row committed, including partial batches, and false for test runs or when no
row committed. Per-row statuses retain which movement succeeded.
`REVERSE_TO_COST_CENTER` posts movement type 202 for caller-selected return
quantities without a material-document reference. Its UOM-aware form,
`REVERSE_TO_COST_CENTER_UOM`, converts quantities to the mapped base unit first.
Both retain the cost center, optional batch, and caller-supplied valuation type
and use the standard simulation and commit handling; a partial quantity can be
returned.
`ISSUE_COST_CENTERS_BULK` accepts distinct cost centers and validates every
request before posting one movement-201 document per cost center. It commits
each document independently and continues after an issue failure by default.
Set `iv_stop_on_failure = abap_true` to stop after the first failed movement;
later result rows remain in request order with `is_skipped`, and the summary
reports `skipped_count` separately from `failed_count` and sets
`stopped_on_failure`, including when the failure occurs on the last request.
The stop flag is also
available on the UOM form, which converts the full request before posting.
`ISSUE_COST_CENTERS_BULK_UOM` converts every line to its mapped base unit before
the first post. `ISSUE_COST_CENTERS_ATOMIC` stages the documents and commits
once, rolling back the group after an issue or commit failure;
`ISSUE_COST_CENTERS_ATOMIC_UOM` adds full-request unit conversion before
staging. Test runs skip commit and rollback.
`RETURN_COST_CENTERS_BULK` and `RETURN_COST_CENTERS_BULK_UOM` provide the same
per-center flow for movement-202 returns, including the optional
`iv_stop_on_failure` behavior and separate skipped-row accounting. Only
`abap_true` and `abap_false` are accepted; invalid values fail before posting.
`RETURN_COST_CENTERS_ATOMIC` stages all center returns before one shared
commit, and `RETURN_COST_CENTERS_ATOMIC_UOM` converts the complete request
before staging. Both return paths retain the caller-supplied cost center and
optional batch.
`ISSUE_COST_CENTER_ALLOCATION` accepts a successful
`ZCL_CC_RESERVATION_SERVICE=>PREVIEW_FOR_COST_CENTER` result and the matching
material base-unit/ISO mapping. It posts the preview's location or batch splits
as movement 201 items. It rejects results that already carry a reservation
number, so the same reserved allocation cannot be posted through this direct
path. Full allocation is required by default; set
`iv_require_full_allocation = abap_false` to post only allocated quantities.
The preview is a stock snapshot and is not re-read before posting.
`ISSUE_COST_CENTER_LOCATIONS` accepts the multi-demand result from
`PREVIEW_COST_CENTER_LOCATIONS` and posts all selected location splits in one
movement-201 document. Each demand keeps its own cost center. It validates
unique request IDs, unit mappings, preview totals, and each location-split sum;
full allocation is required by default, with partial posting available as an
explicit option. The preview is not re-read before posting.
`ISSUE_COST_CENTER_BATCHES` consumes `PREVIEW_COST_CENTER_BATCHES`, preserving
the selected batch and its storage-location splits for each demand.
`ISSUE_COST_CENTER_FEFO` consumes `PREVIEW_COST_CENTER_FEFO` and preserves each
selected batch split. Both methods validate the per-demand summary and split
totals, retain each cost center, and post one movement-201 document; full
allocation is the default and partial posting is opt-in.
`ISSUE_TO_SALES_ORDER` supports direct movement type 231 issues with a sales
document and item on each line. `ISSUE_TO_SALES_ORDER_IN_UNIT` converts each
line to the material base unit and checks the supplied base-unit/ISO mapping.
Both methods post all selected items in one material document; they do not read
the sales order or estimate available stock. Each line can include a caller-
supplied `valuation_type` for non-batch split valuation. Both accept
`iv_special_stock`, which defaults to blank for unrestricted stock; pass `E` to
issue from the specified sales-order stock.
`ISSUE_SALES_ORDERS_BULK` accepts distinct sales documents and commits one 231
movement per order, continuing after individual BAPI failures by default.
Set `iv_stop_on_failure = abap_true` to stop after the first failure; later
rows remain in request order with `is_skipped`, and skipped requests are counted
separately. Its UOM variant supports the same option and converts every line
against the supplied base-unit/ISO mappings before the first post. Both retain
per-order results and accept `iv_special_stock = 'E'` for sales-order stock;
inspect each result for partial success.
`ISSUE_SALES_ORDERS_ATOMIC` stages one 231 movement per distinct sales document
and commits once, rolling back staged results if an issue or commit fails. Its
UOM variant converts the full request before staging. Both return per-order
results, support simulation, and accept the same special-stock option.
`ISSUE_SALES_ORDER_FEFO` consumes `ZCL_SO_STOCK_SERVICE` FEFO previews and
preserves each selected sales-order item, batch, and storage-location split in
one 231/E material document. It checks preview totals, base-unit mappings, and
the echoed expiry and shelf-life rules before posting. It also validates each
required date and priority against its batch splits; a required date must be a
valid date no later than the effective FEFO cutoff. Full allocation is required
by default; set `iv_require_full_allocation = abap_false` to post only the
covered quantities. A posting can include repeated demands for one item
when they share a reservation cutoff; separate cutoff scenarios must be posted
separately because each preview has an independent stock pool. The preview
remains a stock snapshot and is not re-read before posting.
`ISSUE_SO_FEFO_SELECTED` accepts request IDs from a multi-demand result, filters
the result to those rows, then applies the same validation and posting rules.
Use it to post one cutoff scenario from a preview that contains other scenarios.
`ISSUE_SO_FEFO_SEL_RECHECKED` takes the original and freshly recomputed
multi-demand results plus the selected request IDs. It compares the matching
subsets and posts only the refreshed subset if they match.
`ISSUE_SO_FEFO_RECHECKED` accepts the original preview and one freshly
recomputed with the same demands and options. It compares every summary,
stock/reservation row, and batch/location split, then posts only the refreshed
preview if they match. The comparison catches changed stock and batch selection
before the movement call; SAP still validates stock at posting time.
`ZCL_SO_FEFO_ISSUE_SERVICE->ISSUE_FEFO` runs that fresh preview and comparison
inside one service call. Supply the original allocation, the same FEFO demands
and options, and the posting data; the service posts only if the new snapshot
matches. `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_SO_FEFO_ISSUE_SERVICE` builds the
production composition. `ISSUE_FEFO_UOM` does the same for alternative-unit
demands and posts the converted base-unit splits. Pass `it_request_ids` to
recheck and post a selected subset from a multi-demand preview; IDs must be
unique and present in the supplied demand list.
Both methods validate their boolean options before returning a successful no-op
for an empty request list.
`RETURN_FROM_SALES_ORDER` posts movement type 232 against the supplied sales
order and item keys. `RETURN_FROM_SALES_ORDER_UOM` converts source quantities
to the mapped base unit first; both retain batch assignments and use the
standard simulation and commit flow. They accept the same `iv_special_stock`
option, including `E` for sales-order stock. Return lines can also include a
caller-supplied `valuation_type` for non-batch split valuation. Returns are
entered without a reference to the original material document.
`RETURN_SALES_ORDERS_BULK` accepts distinct sales documents and commits one
movement-232 document per sales order, continuing after individual BAPI
failures by default. Its UOM variant supports `iv_stop_on_failure` and converts
every line against the supplied material base-unit/ISO mappings before the
first posting. When enabled, later requests remain in order and are marked
`is_skipped`; the summary separates skipped and failed counts. Both support
sales-order stock returns through `iv_special_stock = 'E'`; inspect each row
for partial success.
`RETURN_SALES_ORDERS_ATOMIC` stages one 232 movement per distinct sales
document and commits once, rolling back the group if a movement or the commit
fails. The UOM variant converts all lines before staging. Both return per-order
results and support simulation.
`TRANSFER_SALES_ORDER_STOCK` moves selected sales-order stock to own stock with
movement 411 and special-stock indicator E. Its unit-aware form converts to the
material base unit. Both require the sales document and item, support the
standard test-run flow, and post one material document; they do not re-read or
estimate stock availability. `TRANSFER_SALES_STOCK_BULK` accepts distinct
sales documents and posts one independently committed 411/E document per
order, continuing after an individual failure by default. Set
`iv_stop_on_failure = abap_true` to stop after the first failure; later result
rows are marked `is_skipped` and counted separately. Its UOM form supports the
same option and converts every line before the first post.
`TRANSFER_SALES_STOCK_ATOMIC`
stages one movement per sales document and commits the group once, rolling
back all staged movements after a posting or commit failure.
`TRANSFER_SO_STOCK_ATOMIC_UOM` converts and validates the full request before
staging; both atomic methods support simulation. `TRANSFER_TO_SALES_STOCK`
moves own stock into the
selected sales-order item with movement 413/E and has the same unit-aware form.
`TRANSFER_TO_SALES_STOCK_BULK` posts one independently committed movement per
distinct sales document and continues after an individual failure by default.
Its base-unit and UOM forms accept `iv_stop_on_failure`; later rows are marked
`is_skipped` and reported in `skipped_count` after the first failure.
`TRANSFER_TO_SO_STOCK_BULK_UOM` converts the full request before posting.
`TRANSFER_TO_SALES_STOCK_ATOMIC` stages one 413/E movement per sales document
and commits once, rolling back the group on a movement or commit failure.
`TRANSFER_TO_SALES_ATOMIC_UOM` converts and validates the whole group before
staging; both atomic forms support simulation.
`TRANSFER_SALES_ORDER_ALLOC` consumes the result of the sales-order allocation
preview and posts its validated location or batch splits as 413/E, using the
material base-unit mapping. Full allocation is required by default; partial
posting is opt-in. `TRANSFER_SO_ALLOC_RECHECKED` accepts that preview and a
fresh preview the caller recomputes with the same options immediately before
transfer. It compares the sales document, allocation totals, line allocations,
and every location or batch split, then posts the fresh result only when they
match. A changed or failed preview is rejected before the goods-movement API
is called. SAP remains the final authority on stock at posting time.
`ISSUE_TO_PROJECT_WBS` posts movement 221 to the supplied WBS element, and
`RETURN_FROM_PROJECT_WBS` posts movement 222 back to that WBS element. Their
unit-aware forms convert each source quantity to the supplied material
base-unit/ISO mapping. Both preserve optional batch assignments and use the
standard simulation and commit flow. `iv_special_stock` defaults to blank for
unrestricted stock; pass `Q` to use project stock. These direct methods do not
validate WBS status or stock availability, and returns do not reference an
original material document.
`ISSUE_PROJECT_WBS_BULK` accepts a list of WBS assignments with base-unit issue
items. It validates the full request before the first posting call, then posts
and commits one material document per WBS, retaining each result in input order
and continuing after a posting failure by default. Set
`iv_stop_on_failure = abap_true` to stop after the first failed posting; later
rows remain in input order with `is_skipped`, and skipped counts are separate
from failed counts. Review every row for partial success. Its test-run mode
simulates each WBS without committing.
`ISSUE_PROJECT_WBS_BULK_UOM` accepts source units with a material base-unit/ISO
mapping, converts and validates the complete request first, then uses the same
per-WBS posting and stop-on-failure behavior.
`RETURN_PROJECT_WBS_BULK` accepts base-unit return items and posts one movement
222 document per WBS. It validates the full request before posting and returns
per-WBS outcomes in input order, continuing after a failed posting by default.
Its `iv_stop_on_failure` option marks later requests as skipped after a failure.
These returns do not reference an original material document.
`RETURN_PROJECT_WBS_BULK_UOM` accepts source units and a base-unit/ISO mapping,
converts every row before the first return posting, and preserves the same
per-WBS transaction and stop-on-failure behavior.
`ISSUE_PROJECT_WBS_BULK_ATOMIC` and `RETURN_PROJECT_WBS_BULK_ATOMIC` stage one
goods-movement call per WBS and commit the group once. A failed movement stops
the group and rolls back earlier staged documents; a failed group commit also
rolls the group back. Their result includes per-WBS messages and attempt state,
plus group commit/rollback status. Use the non-atomic bulk forms when each WBS
should commit independently and later rows should continue after a failure.
`ISSUE_PROJECT_WBS_ATOMIC_UOM` and `RETURN_PROJECT_WBS_ATOMIC_UOM` accept
source-unit requests with material base-unit/ISO mappings. They convert and
validate the complete request before staging any WBS call, then use the same
group commit/rollback behavior.
`ZCL_PROJECT_RESV_SERVICE=>RESERVE_FOR_WBS` creates one reservation for a WBS
element with multiple material, plant, location, and batch items. It converts
requested units to each material's base unit and assigns the required date to
the reservation items. It rejects dates that are not valid Gregorian calendar
dates before calling SAP. Use it to persist selected project-stock demand
before issue; the reservation will then be included in later project-stock
previews.
`iv_test_run = abap_true` simulates creation without commit or rollback. Live
creation commits the reservation and returns its number. The local availability
preview is not re-read or locked before the BAPI call, so SAP performs the final
availability, business-date, and project-configuration checks.
`RESERVE_WBS_BULK` accepts one direct reservation request per unique WBS
element. It validates every date and stock item and converts all quantities to
material base units before the first BAPI call. By default, each WBS commits
independently and later requests continue after a failure. Set
`iv_stop_on_failure = abap_true` to stop later creates after the first failed
create or commit; unattempted rows remain in request order with `is_skipped`,
and skipped counts are separate from failed counts. Set `iv_atomic = abap_true`
to stage the group under one commit or rollback boundary. In atomic mode,
stop-on-failure also skips later create calls, while any attempted group still
rolls back on failure. Test-run calls simulate each attempted row without
commit or rollback.
`ISSUE_RESERVED_WBS_ITEMS` issues selected items from an existing reservation
after confirming that each item belongs to the supplied WBS and reservation,
is not finally issued, and has remaining quantity. It accepts a quantity and
unit per item, then uses the reservation-backed goods-issue flow to convert the
quantity, re-read SAP reservation details, and post one material document.
Test-run validates and simulates the movement without commit. SAP remains the
final authority for current reservation state and goods-movement eligibility.
`ISSUE_RESERVED_WBS_ITEMS_BULK` accepts one unique request per reservation,
validates all WBS/item scopes before posting, and issues one material document
per reservation. It preserves request order, commits each reservation
independently, and returns each reservation's result. By default, later
reservations are still attempted after a failure. Set `iv_stop_on_failure =
abap_true` to stop after the first failed posting; later rows remain in order
with `is_skipped`, and skipped counts are separate from failures. Earlier
successful reservations remain committed. Test-run simulates every reservation
without commit.
`RETURN_RESERVED_WBS_ITEMS` reverses a selected quantity already withdrawn
from a WBS reservation. It checks that the item is scoped to the WBS and has a
withdrawn balance, then posts a reservation-referenced reversal; finalized
items remain eligible when they have a withdrawn quantity. Its bulk form
accepts unique reservations, checks every WBS/item before posting, and commits
one return document per reservation. It continues after failures by default;
set `iv_stop_on_failure = abap_true` to stop later returns and mark the
unattempted rows skipped with separate counts. Earlier successful returns
remain committed. The requested return quantity is checked against the current
SAP withdrawn amount.
`ISSUE_RESERVED_WBS_ATOMIC` and `RETURN_RESERVED_WBS_ATOMIC` accept one unique
request per reservation, validate the complete WBS/item scope, stage one
reservation-referenced movement per reservation, and commit the group once.
A failed movement or group commit rolls back the staged group. Their results
include per-reservation attempt and commit state; test-run simulates the group
without transaction calls.
`RESERVE_BATCH_ALLOCATION` and `RESERVE_LOCATION_ALLOCATION` accept the
corresponding project-stock preview result and its WBS assignments. They
validate summary and split quantities, combine repeated stock-key splits, and
create one reservation per WBS. Each WBS reservation commits independently by
default, so review every returned row for partial success. Set
`iv_atomic = abap_true` to stage all WBS reservations under one commit or
rollback boundary. Its test-run mode simulates each WBS reservation without a
transaction call. Full allocation is required by default; set
`iv_require_full_allocation = abap_false` to reserve available splits only.
Pass `iv_required_date` to apply one date to all WBS reservations, or supply
`it_wbs_required_dates` with one unique valid date per assigned WBS. The two
date inputs are mutually exclusive, and result rows include the applied date.
Batch reservations also reject a known batch expiry before its WBS required
date. Set `iv_minimum_shelf_life_days` to require additional remaining shelf
life; undated batches are rejected when this minimum is positive. The direct
preview reservation adapters validate summary quantity identities and each
row's `require_full_quantity` policy. Split and grouped reservation quantities
are accumulated in high precision and rejected when they exceed the
`MARD-LABST` range. They reject inconsistent summaries and partial allocations
marked strict, even when global partial reservation is enabled.
`RESERVE_WBS_FEFO` combines `PREVIEW_FEFO` with batch reservation and returns
both the preview and reservation outcome. It accepts the same location,
reservation-cutoff, and shelf-life options plus a shared required date or a
date per WBS. It also accepts request-specific location ranks and applies them
to both the preview and fresh allocation check. Full demand coverage is
required by default; if the preview has a shortfall, the method returns that
preview and creates nothing. Set
`iv_require_full_quantity = abap_false` to reserve available splits. Test-run
and atomic commit behavior are forwarded to the reservation step.
`RESERVE_WBS_FEFO_PRIORITY` applies integer priority to undated FEFO demands;
higher priorities consume shared stock first and equal priorities keep input
order. The preview returns in caller order, including when request IDs repeat.
It repeats the priority FEFO preview and compares the batch splits before
creating reservations. Full demand coverage is required by default; partial
reservation is opt-in with `iv_require_full_quantity = abap_false`. It accepts
the same date, shelf-life, location, test-run, and atomic options as
`RESERVE_WBS_FEFO`, including request-specific location ranks.
`RESERVE_WBS_FEFO_BY_DATE` uses required date and integer priority on each
demand. Earlier dates consume shared stock first, and higher priorities lead
within a date; equal priorities keep input order. The preview and batch splits
return in caller order, including when caller request IDs repeat. Internal IDs
keep repeated requests separate through rechecking and reservation creation.
Reservations are grouped by WBS and required date, so a WBS with multiple
requirement dates receives a separate reservation per date.
Each group commits independently by default; `iv_atomic = abap_true` stages all
groups for one commit or rollback. The method reruns the dated preview and
compares all batch splits before creating reservations. It accepts
`it_request_location_priorities` and forwards the rows to both previews, so
request-specific location ranks survive the fresh allocation check. Base,
priority, and date-first FEFO reservations also honor each demand's
`require_full_quantity` value when the shared option permits partial coverage.
A strict short row reserves nothing while eligible partial rows can proceed;
fresh checks compare allocation summaries as well as batch splits so changes to
zero-split rows prevent writes.
`RESERVE_WBS_BY_LOCATION_DATE` applies the same date and priority ordering to
batchless project stock. It reruns the preview and compares location splits
before writing, grouping reservations by WBS and required date. Different dates
for one WBS can share an atomic commit with `iv_atomic = abap_true`. Repeated
caller request IDs are supported across dates; the returned preview keeps the
caller IDs and input order. It accepts request-specific location ranks and
forwards them to the initial preview and fresh split check.
`RESERVE_WBS_BY_LOCATION` provides the same one-call flow for batchless stock,
using `PREVIEW_BY_LOCATION` and returning both preview and reservation result.
It accepts storage-location priority/allow lists and a reservation cutoff. Full
coverage is required by default; a shortfall returns the preview without
creating reservations, while `iv_require_full_quantity = abap_false` reserves
available splits. A demand may set `allow_location_fallback = abap_true` to
prefer its selected storage location and use other eligible locations only
when needed; the same preference is used during the fresh preview.
`RESERVE_WBS_LOCATION_PRIORITY` applies integer priority to batchless WBS
location demands. Higher priorities consume shared stock first, equal
priorities keep input order, and the preview returns in caller order even when
request IDs repeat. The flow rechecks location splits before creating grouped
WBS reservations. Full demand coverage is required by default; partial
reservation is opt-in. It accepts location preference/allow lists, a
reservation cutoff, required-date options, test-run, and atomic commit options.
Request-specific location ranks override the shared location order for each
caller ID and are retained through the fresh preview, including repeated IDs.
Base, priority, and date-first WBS location reservations also honor a demand's
`require_full_quantity = abap_true` when the shared option allows partial
reservation. A strict short row consumes no stock, so other rows can still be
reserved. Each fresh check compares allocation summaries as well as splits,
including strict rows with no location splits.
These direct allocation methods and the one-call FEFO, priority, dated, and
location reservation methods also accept `iv_stop_on_failure`, defaulting to
`abap_false`. The flag is validated before preview reads or allocation
conversion; after a failed WBS create or commit, later groups remain in caller
order as skipped rows with separate counts. In atomic mode the option stops
later create calls, but any attempted group still rolls back as one unit.
The top-level `is_committed` is true when at least one independent WBS
reservation committed; atomic mode sets it only after the group commit succeeds.
`DELETE_RESERVATION` cancels one reservation by number. Its test-run mode
reports the BAPI result without commit, and a live delete is reported as
deleted only after commit succeeds. `DELETE_RESERVATIONS_BULK` validates the
full list first, then processes each reservation in its own transaction and
returns a result per number. By default, an individual failure is rolled back
while later numbers continue. Set `iv_stop_on_failure = abap_true` to retain
later numbers as skipped after the first deletion or commit failure; the result
reports separate successful, failed, and skipped counts. SAP determines
whether a reservation can be deleted based on its current use and status.
`DELETE_RESERVATIONS_ATOMIC` prevalidates the full unique list, then requests
one shared commit or rollback. Test-run calls the delete BAPI in simulation
mode and skips transaction calls.
`DELETE_RESERVATION_ITEMS` deletes selected open item numbers after confirming
they belong to the supplied WBS and reservation. Its test-run mode performs the
scope check without calling the change BAPI. Live requests mark the selected
items for deletion and commit; `DELETE_RESERVATION_ITEMS_BULK` processes one
reservation per request and reports each outcome. It continues after failures
by default; `iv_stop_on_failure = abap_true` marks later requests skipped and
reports separate success, failure, and skip counts. Earlier document commits
remain committed.
`DELETE_RESV_ITEMS_ATOMIC` validates all open item scopes first, then stages
one change per reservation and commits the group once or rolls it back.
`MARK_RESERVATION_ITEMS_FINAL` marks selected open items complete with SAP's
final-issue indicator, including items with quantity still open after a partial
withdrawal. Test-run checks WBS and item scope; live changes commit per
reservation. The bulk form reports each outcome and continues after failures.
`RESET_RESERVATION_ITEMS_FINAL` clears the indicator for selected finalized
items scoped to the WBS and reservation, so they can be proposed for later goods
issues again. It has the same test-run and per-reservation bulk behavior.
`SET_RESV_FINAL_ATOMIC` sets or clears the indicator across several
reservations. Pass `iv_final_issue = abap_true` to mark open items or
`abap_false` to reset finalized items. It validates the requested current state
for the whole group before writes and commits once or rolls the group back.
`RESCHEDULE_RESERVATION_ITEMS` changes the required date for selected open
items after the same WBS and reservation scope check. All reschedule forms
reject impossible calendar dates before reading or updating reservations.
Test-run validates the scope without a BAPI write; live changes commit per
reservation. The bulk form returns an outcome for each reservation and
continues after individual failures by default. Set
`iv_stop_on_failure = abap_true` to mark later requests as skipped after the
first failure; the result reports separate success, failure, and skip counts.
Earlier committed date changes remain. `RESCHEDULE_ITEMS_ATOMIC` accepts several
reservation date changes, validates every WBS/item scope before writes, and
uses one group commit or rollback. Test-run validates the entire group without
calling the update BAPI.
`CHANGE_RESERVATION_ITEM_QTY` updates selected open items' total required
quantity in each item's existing reservation unit. Supply that unit with each
quantity; the service rejects unit mismatches and quantities at or below the
already withdrawn amount. Test-run validates scope and quantities without a
BAPI write. Live updates commit per reservation, and the bulk form reports and
continues per reservation. Delete an item when no remaining quantity is
needed.
`CHANGE_RESV_QTY_ATOMIC` accepts multiple reservation quantity updates, checks
all WBS/item scopes, entry units, unit conversions, and withdrawn-quantity
limits before writing, then commits once for the group. A failed BAPI call or
commit rolls back all staged updates. Test-run performs the full validation
without BAPI writes or transaction calls.
`CHANGE_RESERVATION_ITEM_STOCK` changes a selected open item's storage
location, batch, or both after checking its WBS and reservation scope. Set the
per-field change flags to update or clear that field; SAP remains responsible
for validating the destination batch, location, and availability. Test-run
checks scope and input flags without a BAPI write. Live changes commit per
reservation, and the bulk form reports and continues after failures.
`CHANGE_RESV_STOCK_ATOMIC` accepts multiple reservation requests,
validates every WBS/item scope before writing, then commits the group once.
Any BAPI or commit error rolls back the whole group. Its test-run mode performs
the complete input and scope checks without BAPI writes or transaction calls.
Each independent bulk mutation returns top-level `is_committed` when at least
one reservation change committed. It remains false for simulations and when no
row committed; per-reservation results identify the committed rows.
The reschedule, quantity-change, final-issue mark/reset, and stock-change bulk
methods accept `iv_stop_on_failure`, defaulting to `abap_false`. When enabled,
the first failed reservation operation stops later calls; those requests remain
as skipped rows with separate successful, failed, and skipped counts. Earlier
independent commits remain committed.
`TRANSFER_PROJECT_WBS_STOCK` posts movement 415/Q between a source and
destination WBS element in one plant and storage location. It accepts source
quantities in material units, converts to the mapped base unit, preserves the
batch, and sets the BAPI's receiving material, plant, storage location, and
batch to those same stock keys. It maps the destination WBS to `WBS_ELEMENT`
and the source WBS to `VAL_WBS_ELEM`. SAP describes movement 415 as a
project-stock transfer and 416 as its cancellation. The method does not
validate grouping-WBS eligibility or stock availability; use material-document
cancellation to reverse a posted transfer.
`ZCL_PROJECT_STOCK_SERVICE=>PREVIEW_TRANSFER_FEFO` previews eligible
source-WBS batches and returns source/destination assignments with the batch
allocation. `TRANSFER_WBS_BATCH_ALLOC` validates allocation totals and
assignments, then posts the batch splits as 415/Q. Full allocation is required
by default; the preview is a snapshot and is not reserved before posting.
`TRANSFER_WBS_FEFO` supports repeated caller request IDs by assigning internal
row IDs through both batch previews and movement validation, then restoring the
caller IDs in the result.
Each base, priority, and dated transfer demand may set
`require_full_quantity = abap_true`. With the shared
`iv_require_full_quantity = abap_false`, a short strict row receives no batch
splits while fully covered or partial rows can still transfer. The allocation
summary echoes the effective rule, and `TRANSFER_WBS_BATCH_ALLOC` rejects a
forged partial split for a strict row before posting. `TRANSFER_WBS_FEFO`
compares allocation summaries and batch splits across both stock snapshots, so
a changed strict-row summary with zero splits also prevents posting.
The base, priority, and dated WBS location transfer methods also accept
`require_full_quantity = abap_true` on each demand. With global partial transfer
enabled, strict rows remain all-or-none while other rows may use partial
location balances; their adapters compare allocation summaries and location
splits across both stock snapshots before posting.
Base, priority, and dated FEFO transfer previews accept
`it_request_location_priorities`. A request's positive ranks decide among
matching expiry and batch candidates after FEFO ordering; locations without a
rank follow the shared order and then location code. Priority/date previews
map ranks through their internal rows, and ATP adapters forward the same rows.
`TRANSFER_WBS_FEFO`, `TRANSFER_WBS_FEFO_PRIORITY`, and
`TRANSFER_WBS_FEFO_BY_DATE` reuse those mapped ranks during both stock reads
before movement posting.
These transfer previews also accept `it_request_locations` to constrain
eligible source storage locations per transfer. Each request's scope intersects
the shared allowlist; unknown IDs, blank values, and duplicate request/location
pairs fail before UOM conversion or stock reads. Priority and date-first
variants map scopes through internal row IDs, preserve caller-facing scope rows
in results, and forward the scopes through ATP adapters. FEFO and batchless
transfer methods retain their existing source/destination WBS assignments.
The six WBS transfer posting methods also accept these scopes. They map
caller IDs through internal preview rows, reuse the same locations during the
fresh stock recheck, and return the caller-facing scope with the preview before
posting the validated 415/Q movement. All six validate `iv_test_run` before taking either stock snapshot.
`PREVIEW_TRANSFER_FEFO_ATP` adds cumulative plant-level ATP diagnostics for
positive undated batch allocations, grouped by material, plant, and base unit.
Its optional `iv_atp_check_date` defaults to `sy-datum` and does not change the
local batch estimate or confirm special WBS stock or a selected batch.
`PREVIEW_TRANSFER_FEFO_BY_DATE` adds each transfer's required date and integer
priority. Earlier dates consume shared source-WBS stock first; higher priority
runs first on the same date, and input order breaks ties. The dated allocation
and batch splits return in caller order with date and priority attached.
`TRANSFER_WBS_FEFO_BY_DATE` reruns that same dated preview and compares the
batch, source and destination WBS, expiry, quantity, and unit before posting.
It posts the validated splits as 415/Q through the existing movement path.
Both dated preview methods and the transfer method support repeated caller
request IDs. They correlate rows internally and restore caller IDs and input
order in the result; retain a separate row key when consumers need to tell rows
with the same request ID apart.
Batch expiry is checked through each transfer's required date, but the dated
preview remains a current stock snapshot and does not reserve stock until the
movement is posted.
`PREVIEW_TRANSFER_FEFO_DATE_ATP` adds cumulative plant-level ATP diagnostics
for positive batch allocations, grouped by material, plant, base unit, and
required date. The checks do not change the local batch preview or confirm
special WBS stock or a specific batch. They do not reserve stock; verify the
checking rule and confirmation lines in the target SAP system.
`PREVIEW_TRANSFER_FEFO_PRIORITY` applies descending priority to shared
source-WBS FEFO demand by default; input order breaks ties. Set
`iv_prioritize_by_date = abap_true` to process earlier per-demand
`fefo_as_of_date` values first, then higher priority for same-date requests.
Each demand must provide a valid FEFO date in that mode. Its allocation
summaries, batch splits, and source/destination assignments return in caller
order and echo priority. Repeated request IDs are supported through internal
row IDs; its ATP wrapper forwards the same ordering option.
`TRANSFER_WBS_FEFO_PRIORITY` reruns that preview immediately before posting and
compares source and destination WBS, material, plant, location, batch, expiry,
quantity, and unit. It uses distinct internal request IDs through posting, then
returns the preview with caller IDs restored. Full demand coverage is required
by default; set `iv_require_full_quantity = abap_false` to allow partial
priority allocations. It accepts `iv_prioritize_by_date = abap_true` and uses
the same earlier-date, same-date-priority order in both posting snapshots.
The stock read remains a snapshot and is not locked.
`PREVIEW_TRANSFER_LOC_PRIORITY` applies the same order to batchless
source-WBS/location demands while preserving the configured storage-location
preference. These priority previews do not post a movement or reserve stock.
`PREVIEW_TRANSFER_FEFO_PRIO_ATP` and `PREVIEW_TRANSFER_LOC_PRIO_ATP` add
cumulative plant-level ATP diagnostics for positive priority allocations,
grouped by material, plant, base unit, and check date. Their optional
`iv_atp_check_date` defaults to `sy-datum`; the diagnostic preserves the local
priority split and caller-order result but does not confirm special WBS stock,
a selected batch, or a selected storage location.
`TRANSFER_WBS_LOC_PRIORITY` reruns the location preview and compares source and
destination WBS, material, plant, location, quantity, and unit before posting
the validated batchless splits as movement 415/Q. Repeated caller IDs remain
distinct during posting, and the returned preview restores the caller IDs.
Full demand coverage is required by default; partial transfer is opt-in. The
second stock read does not lock project stock.
`ISSUE_PROJECT_WBS_ALLOCATION` accepts the location allocation result from
`ZCL_STOCK_SERVICE=>ALLOCATE_BY_LOCATION_IN_UNITS` and a request-ID-to-WBS
mapping. It posts the positive location splits as movement 221 items, keeps
each demand assigned to its WBS element, and checks split totals and unit maps.
Full allocation is required by default; partial issue is opt-in. The allocation
is a stock snapshot and is not re-read before posting.
ISSUE_PROJECT_WBS_LOCATION accepts project WBS demands and the same location
priority, allowed-location scope, full-allocation option, and reservation cutoff
as PREVIEW_BY_LOCATION. It supports repeated caller request IDs through
internal row IDs. It reruns the preview before writing and compares allocation
totals, location splits, units, and WBS assignments. A changed snapshot returns
a warning without calling the movement API; matching splits post as 221/Q. This
narrows the stale-preview window but does not lock stock. It accepts
`it_request_location_priorities` and retains the mapped ranks through both
previews. The optional `allow_location_fallback` demand flag lets its preferred
location run first and uses other eligible locations for any remainder.
ISSUE_PROJECT_WBS_LOC_PRIORITY adds descending request priority to the same
flow and accepts repeated caller request IDs. It uses internal IDs through both
previews and movement validation, then restores caller IDs in the preview. The
second preview uses the same priority order and request-specific location ranks.
ISSUE_PROJECT_WBS_LOC_DATE applies required-date order, then descending
priority for same-date requests, to batchless WBS location issue. It preserves
repeated caller IDs through internal row IDs, returns allocations in caller
order with date and priority metadata, and rechecks the same ordering before
posting 221/Q. Request-specific location ranks are mapped through internal
IDs and retained for the fresh preview. The second stock read narrows the stale
window but does not lock project stock. These three batchless issue methods
also accept `it_request_locations`; each caller scope intersects the shared
allowlist, maps through internal request IDs, and is reused for the fresh check.
The returned preview preserves the caller-facing scope rows.
Each demand may set `require_full_quantity = abap_true` to require its whole
quantity even when `iv_require_full_quantity = abap_false` enables partial
issues for other rows. A short strict row leaves stock available to later
demands; the allocation summary echoes the effective rule and the fresh
preview rechecks it before posting.
`ISSUE_PROJECT_WBS_BATCH_ALLOC` consumes the corresponding unit-aware
batch allocation result, so explicit-batch and FEFO allocations retain each
selected batch and storage location on the 221 item. It applies the same WBS
mapping, unit checks, and full-allocation default. Pass
`iv_special_stock = 'Q'` when the preview represents project special stock.
`ZCL_STOCK_SERVICE` allocation results represent unrestricted plant stock;
use `ZCL_PROJECT_STOCK_SERVICE=>PREVIEW_FEFO` for a project-stock preview.
`ZCL_PROJECT_STOCK_SERVICE=>READ_AVAILABLE_STOCK` returns net available stock
for unique material/plant/WBS keys as one row per located batch or batchless
balance. Each row includes its storage location, expiration date, base-unit
quantity, and material base unit. It applies the same Q-reservation matching
rules as the previews. An optional `iv_reservation_through_date` excludes later
dated reservations while still deducting undated reservations. This is a
current snapshot and does not reserve stock. Its exact-key RESB query receives
the same cutoff, retains undated rows, and leaves the service-side check in
place.
SQLite-backed Open SQL tests cover all five project-stock repository methods,
including WBS stock selection, plant/global batch-expiry fallback, open
reservation filtering, and final-issue item reads. SAP DDIC and query behavior
still require target-system verification.
`READ_AVAILABLE_STOCK_BULK` accepts unique request IDs with a material,
plant, WBS element, and optional reservation cutoff for each request. It groups
requests by cutoff and reads each distinct stock key once per date group,
returns detailed batch/location rows in request order, and copies the result to
requests sharing the same key and cutoff. Invalid keys, dates, or duplicate IDs
are rejected before reads; empty input performs no reads. The two bulk stock
readers also accept `it_request_excl_reservations`, keyed by request ID and
RESB reservation/item. Rows must reference an existing request and be complete
and unique. Identical exclusion sets share reads within each cutoff group, while
different sets for the same WBS/cutoff produce separate stock results.
Call-wide and request-specific keys are merged once; UOM reads validate both
sets before conversion.
`READ_AVAILABLE_STOCK_IN_UNIT` returns the same project-stock detail in a
requested material unit while preserving its base-unit quantity. The bulk
`READ_AVAILABLE_STOCK_BULK_UOM` accepts a unit per request, caches conversion
ratios by material and unit, and validates every ratio before stock reads.
Repeated WBS stock keys still share the existing cutoff-grouped read.
The four `READ_AVAILABLE_STOCK` methods and all project-stock preview methods
also accept call-wide `it_excluded_reservations` keys. Each key needs a
reservation number and item, and duplicate keys are rejected. Matching open
WBS reservation items are omitted from local stock netting; unknown or closed
keys have no effect. UOM reads validate the keys before conversion. In ATP
previews, exclusions change only the local project-stock estimate; SAP ATP
continues to use its supplied checking rule. The option does not update SAP
reservations.
`READ_OPEN_RESERVATIONS` returns open Q reservation items for unique WBS
elements, including reservation and item numbers, material/plant, storage
location, batch, requirement date, base and entry units, required and withdrawn
quantities, and remaining open quantity. It omits deleted and final-issued
rows. Results are ordered by requirement date, reservation number, and item; an empty key
list returns no rows without a repository read. An optional
`iv_required_through_date` excludes later dated items and keeps undated open
reservations.
`READ_OPEN_RESERVATIONS_BULK` accepts unique request IDs with one WBS element
and required-through date per row. It groups shared dates and WBS reads, then
returns each request's sorted reservation details in input order. All keys and
dates are validated before reads; empty input performs no reads.
`READ_OPEN_RESERVATIONS_UOM` accepts one material and requested unit for a
unique WBS list. Each result nests the original RESB row and adds required,
withdrawn, and open quantities in the requested unit and the material base
unit. The unit ratio and WBS keys are validated before reservation reads; source
units and quantities remain available on the nested row. Base quantities remain
available for reconciliation. Converted required quantity is derived from the
converted withdrawn and open quantities so the returned values reconcile after
rounding.
`READ_OPEN_RESV_BULK_UOM` accepts request IDs with a material, WBS element,
requested unit, and required-through date per row. It caches material/unit
ratios before grouped reservation reads, applies shared and per-request
exclusions, and returns each request in input order with its original RESB rows
and converted quantities.
`READ_OPEN_RESERVATIONS` also accepts call-wide `it_excluded_reservations`;
matching open items are omitted from its result. The bulk reader accepts those
shared keys and `it_request_excl_reservations`, keyed by request ID and RESB
reservation/item. Request-specific keys must be complete, unique, and reference
an existing request. It filters each request's result after shared WBS/date
reads, so different exclusion sets do not repeat the repository read.
`READ_RESERVATION_ITEMS` returns active Q reservation items for unique WBS
elements, including final-issue state, base and entry units, required and
withdrawn quantities, and the remaining quantity, clamped to zero when
withdrawals meet or exceed the required quantity. It includes finalized and
fully withdrawn items that `READ_OPEN_RESERVATIONS` omits. It also accepts
call-wide `it_excluded_reservations` keys to omit selected rows from the local
result; the underlying SAP reservations are not changed.
`READ_RESERVATION_ITEMS_BULK` accepts unique request IDs and WBS elements,
reads the full item view once for distinct WBS values, and returns each WBS's
items in request order. Repeating a WBS under another request ID reuses the
read; final and fully withdrawn items remain included. It accepts the same
call-wide keys and per-request `it_request_excl_reservations` keys. Request IDs
and reservation/item pairs must be complete and unique. It applies request
keys while mapping the shared item read into each result, so different request
filters do not repeat the repository read.
`READ_RESERVATION_ITEMS_UOM` accepts one material and requested unit for a
unique WBS list. It returns every active Q item for that material, including
final and fully withdrawn rows. Each detail keeps the complete source
reservation and adds required, withdrawn, and open quantities in both requested
and base units. Converted required quantity is the sum of converted withdrawn
and open quantities. `READ_RESV_ITEMS_BULK_UOM` accepts those material/unit choices
per request, caches conversion ratios before shared WBS reads, and supports
call-wide and per-request reservation exclusions.
`READ_RESERVATION_COVERAGE` summarizes by WBS/material/plant, returning
eligible project stock, open reserved quantity, free quantity after
reservations, and any reservation shortfall. It includes batch and batchless
stock with a storage location, converts reservation quantities to the
material base unit, and accepts the same optional required-through date. All
All six coverage methods accept call-wide `it_excluded_reservations`; complete,
unique keys are validated before reads or UOM conversion, and matching open
items are omitted from reserved quantity, open-item count, and stock netting.
All three bulk methods also accept `it_request_excl_reservations` rows keyed
by request ID and reservation key. Request IDs must exist, keys must be
complete, and duplicate request/key rows are rejected. Requests with identical
per-request exclusion sets share reads within each date group; the same WBS/date
with different sets produces separate coverage. Call-wide and per-request keys
are combined, and an overlapping key is applied once. Each result's
`open_reservation_items` count matches the item keys in `open_reservation_keys`,
which identify open reservations included in the reserved quantity.
`open_reservations` adds each included item's quantity in the result unit plus
its canonical `base_reserved_quantity` and `base_unit`. It also carries the
source RESB required, withdrawn, and open quantities, material and entry units,
requirement date, storage location, and batch; those source fields stay
unchanged in UOM results. Summing the base quantities reconciles to
`reserved_quantity` in base results and `base_reserved_quantity` in UOM results.
`excluded_open_resv_items` and `excluded_reservations` report matching open
items omitted from that WBS/material/plant balance.
`excluded_open_reservations` includes each omitted open row with its original
RESB `open_quantity` and `unit`; these source-unit details stay unchanged in
UOM results. The key list, detail list, and count describe the same excluded
rows. Unknown or closed keys appear in none of these fields. Both included and
excluded details appear in base-unit and UOM results.
These options affect only this local snapshot and do not change SAP
reservations. The method does not lock stock or assign each reservation to a
batch.
`READ_RESERVATION_COVERAGE_BULK` accepts request IDs with individual WBS
elements and required-through dates. It groups requests by date and identical
per-request exclusion set for shared stock and reservation reads, returns
coverage in request order, and performs no reads for an empty request list.
Request IDs must be nonblank and unique.
`READ_RESV_COVERAGE_FOR_KEY` reads one material/plant/WBS key and returns a
zero-quantity row with the material base unit when no stock or reservation
balance exists. `READ_RESV_COVERAGE_KEYS_BULK` accepts keyed requests with
individual cutoffs, groups exact-key MSPR and RESB reads by cutoff and identical
per-request exclusion set, and returns exactly one coverage row per request in
input order. These keyed methods read only requested material/plant/WBS keys;
both support call-wide exclusions, and the bulk method also supports
per-request exclusions. The cutoff is passed into both keyed and WBS-level
RESB repository reads, retaining undated reservations and rows due through the
cutoff; the service applies the same cutoff check again before allocation.
Every base and UOM coverage row includes sorted `stock_details`, with one row
per eligible storage-location/batch balance (blank batch denotes batchless
stock). Each row reports gross project stock, the reservation deduction
applied to that stock key, and remaining available quantity. Base detail stock
and available quantities sum to their summary fields; applied deductions equal
gross minus available. In UOM results, requested-unit values are converted per
row and base-unit fields preserve the original amounts. Per-row rounding can
make requested-unit detail sums differ slightly from summary totals; base-unit
quantities are the exact reconciliation basis. Reservation quantity above
eligible stock remains in the summary shortfall and has no stock detail row.
Coverage rows also include sorted `stock_reservation_deductions` that link each
applied quantity to its reservation number/item and storage-location/batch
key. For each stock key, base deduction quantities sum to the matching detail
row's `base_reserved_quantity`. UOM deduction quantities convert per row; use
their base quantities to reconcile exactly.
Each included `open_reservations` row also reports `uncovered_quantity` after
the local stock allocation, plus `covered_quantity` applied to eligible WBS
stock. `base_covered_quantity` plus `base_uncovered_quantity` equals
`base_reserved_quantity` for each reservation; summed base uncovered quantities
equal the coverage `shortfall_quantity`. UOM `covered_quantity` is computed as
converted `reserved_quantity` minus `uncovered_quantity` so each requested-unit
row still reconciles. These are local preview amounts, not persisted SAP
reservation assignments.
`READ_RESERVATION_COVERAGE_UOM` returns the same coverage for one
material/plant/WBS key in a requested material unit, along with the canonical
base-unit quantities. It validates the material's UOM ratio before stock and
reservation reads, checks its base unit against the UOM repository, then
supplies that unit to the shared coverage core for balance construction. A key
with no stock or reservations returns zero quantities and the requested/base
units.
`READ_RESV_COVERAGE_BULK_UOM` accepts a requested unit and reservation cutoff
per unique request. It caches material/unit ratios before the grouped coverage
reads, checks one repository base unit per material against those ratios, then
seeds the keyed bulk reader with the validated units to avoid separate lookups
in the keyed and grouped reads. The grouped coverage core uses the same map
when it creates stock and excluded-reservation balances. It returns only each exact
material/plant/WBS row, including zero coverage with the base unit. It respects
call-wide and request-specific reservation exclusions and returns converted
and base-unit quantities in request order.
Project-stock previews read positive `PRLAB` quantities from `MSPR` for the
requested WBS elements and return FEFO batch splits with the matching WBS
assignments.
It also reads open project reservations from `RESB`, maps `RESB-PSPEL` through
`PRPS`, and deducts `max(BDMNG - ENMNG, 0)` per reservation item for the
same WBS, material, and plant. SQLite-backed tests execute both keyed and WBS
reservation reads and cover partial, fully withdrawn, and over-withdrawn rows.
Location, FEFO, and ATP totals are checked against the `MARD-LABST` range;
unrepresentable sums fail before returning an allocation or calling ATP.
The production factory also has a SQLite-backed WBS FEFO scenario that combines
`MSPR`, `PRPS`, `MCHA`, and `RESB`: an open early-batch reservation reduces the
first lot before the service selects its FEFO split.
Reservations with a storage location or batch are matched to those stock keys
first; blank keys apply more broadly within that WBS. Deleted and final-issued
reservation rows are ignored. SAP's project reservation view defines open
quantity from required and withdrawn quantities ([open reservations for
projects](https://help.sap.com/saphelp_ssb/helpdata/en/d9/663952f8b2a91ae10000000a445394/content.htm?no_cache=true)).
Reservation deductions are applied only to rows eligible for the selected
preview: FEFO requires a batch, while location allocation requires batchless
stock; both require a storage location. Batch-specific reservations do not
reduce the batchless location preview.
For FEFO, batch expiry comes from plant-level `MCHA-VFDAT` when maintained,
then falls back to material-level `MCH1-VFDAT`, so materials using either SAP
batch level keep their expiry ordering ([SAP batch expiry fields](https://help.sap.com/doc/6afeeafa6a424b9b8060d91da975c497/2025.1/en-US/CPP-EN.pdf)).
Its result can be passed to `ISSUE_PROJECT_WBS_BATCH_ALLOC` with special stock
Q. The preview covers batch-managed stock with a storage location, and is a
snapshot that is not re-read or reserved before posting. It does not include
quality-inspection, blocked, or other project-stock categories.
For batchless project stock, `ZCL_PROJECT_STOCK_SERVICE=>PREVIEW_BY_LOCATION`
returns unit-aware storage-location splits and WBS assignments; pass those to
`ISSUE_PROJECT_WBS_ALLOCATION` with `iv_special_stock = 'Q'`. That preview
ignores batch-managed rows so the posted item never loses a selected batch.
It accepts `it_request_location_priorities` to override the shared location
order for one request; unranked locations follow by location code, and invalid
or duplicate rank rows fail before UOM conversion or stock reads.
`PREVIEW_BY_LOCATION` also accepts caller-resolved
`it_projected_location_receipts` for WBS-specific batchless future supply.
Each base-unit row names its WBS element, material, plant, storage location,
receipt date, and quantity. A demand can set `location_as_of_date`; otherwise
the shared `iv_as_of_date` applies. Receipts become eligible when the effective
date reaches their receipt date and remain subject to location scopes and
priority rules. Priority, date-first, and ATP preview variants forward the same
rows. These forecast rows are preview inputs; reservation and goods-issue
methods re-read posted project stock.
Each location split reports `available_from_date`: it is initial for posted
stock and echoes the receipt date for projected supply, so same-location
on-hand and forecast allocations remain distinguishable.
Batchless WBS transfer previews also accept `it_projected_location_receipts`;
each row must match the transfer's source WBS, material, and plant. The shared
`iv_as_of_date` gates receipt availability, while a demand's
`location_as_of_date` or date-first `required_date` can move its cutoff later.
Priority, date-first, and ATP transfer previews preserve the same forecast
inputs. Transfer posting still compares fresh previews against posted project
stock and does not use projected receipts.
A batchless WBS demand may set `allow_location_fallback = abap_true` with a
preferred `storage_location`. The preferred location is consumed first, then
other eligible locations can cover the remainder. This applies to base,
priority, and date-first location previews and survives WBS reservation,
goods-issue, and transfer rechecks. The preferred location must remain in any
shared allowlist; caller ranks order the remaining locations after the preference.
Base, priority, and per-request-date WBS `PREVIEW_FEFO` and
`PREVIEW_BY_LOCATION` variants, including ATP adapters, accept
`it_request_locations`: each request may name its own allowed storage
locations. A request's set intersects the shared allowlist; requests without
rows use the shared allowlist alone. Unknown request IDs, blank fields, and
duplicate request/location pairs fail before UOM conversion or stock reads.
A preferred location must be inside the request's set. Priority and date-first
adapters map scopes with their internal request IDs and return the caller's
validated rows in preview results.
`RESERVE_WBS_FEFO`, `RESERVE_WBS_BY_LOCATION`, and their priority/date-first
variants use the same scope for both the initial allocation and the fresh
pre-reservation check, so a changed out-of-scope lot cannot alter the recheck.
Project-stock FEFO and location previews subtract open Q reservations before
allocation; their results remain snapshots and do not lock project stock.
`PREVIEW_FEFO` and `PREVIEW_BY_LOCATION` demand rows may set
`minimum_coverage_pct` from 0 through 100. The local allocator compares
eligible base-unit availability with the floor before consuming WBS stock; a
demand below it receives zero so later rows can use the balance. Their
priority, date-first, and ATP previews preserve the floor. Allocation
summaries report F/P/U outcome and two-decimal base-unit coverage, and FEFO
batch splits echo the floor.
WBS transfer FEFO and location previews apply the same floor to eligible stock
on the source WBS. A rejected transfer receives zero allocation and leaves
source stock available to later demands; priority, date-first, and ATP transfer
adapters preserve the threshold.
WBS FEFO and location reservation methods carry the floor through their first
preview and fresh recheck, including priority and date-first methods.
Priority and date-first WBS location and FEFO issue wrappers, and WBS transfer
posting wrappers, carry the floor through their fresh stock rechecks.
`PREVIEW_FEFO` also accepts caller-resolved `it_projected_batch_receipts` for
WBS-specific future supply. Each base-unit row names its WBS element, material,
plant, storage location, batch, receipt date, and expiry date. FEFO and WBS
transfer previews match the row to the demand's WBS (the source WBS for a
transfer), material, and plant. A receipt is eligible only after the demand's
effective FEFO date reaches its receipt date; normal batch-expiry and location
policies still apply. Priority, date-first, and ATP preview variants forward
the same rows. Receipt rows are preview inputs and do not create SAP stock or
reservations. Reservation and goods-issue methods re-read posted project stock
and do not accept projected receipt inputs.
Each FEFO batch split reports `available_from_date`: it is initial for posted
stock and echoes the receipt date for projected supply. The nested
`batch_allocation` row carries the same value.
Project-stock FEFO and location allocation previews also accept optional
`iv_reservation_through_date`. When supplied, reservations with `RESB-BDTER`
after that date are left out of the deduction; undated open reservations remain
deducted. Omit the option to retain the default behavior, which deducts all
open project reservations. The cutoff is applied in the exact-key RESB query as
well as during service-side subtraction. This date filter does not project
receipts or change the current `MSPR` stock snapshot.
FEFO as-of dates and all explicitly supplied reservation cutoffs must be
valid Gregorian calendar dates. Invalid values are rejected before project
stock reads; omitting an optional cutoff keeps the existing default behavior.
Each FEFO demand can set `fefo_as_of_date`; the later of it and the shared
`iv_as_of_date` controls that demand's expiry and minimum-shelf-life filter.
The effective date is echoed in each returned batch split. `RESERVE_WBS_FEFO`
uses the assigned WBS required date for this filter, so it can skip an earlier
batch that will expire before the reservation date and select a later eligible
batch instead. Demands can also set `minimum_shelf_life_days`; the greater of
that value and the shared `iv_minimum_shelf_life_days` applies to the demand.
Returned splits echo the effective minimum, which the reservation flow checks
again before creating reservations. Nonblank expiry dates must be valid
Gregorian dates, and duplicate batch/location rows must agree on expiry.
FEFO demands can set `allow_undated_batches = abap_true` to include undated
stock when the shared option is false, or `require_known_expiry = abap_true` to
exclude it when the shared option is true. The row flags cannot both be true,
and a positive effective minimum shelf life still excludes undated batches.
Allocation summaries and batch splits echo each row policy; WBS FEFO reservation
and transfer posting flows preserve and check it during their fresh stock rechecks.
Base, priority, and date-first WBS FEFO reservations also honor per-demand
`require_full_quantity` when shared partial coverage is enabled. Their fresh
snapshot checks compare summaries alongside positive batch splits, so changed
availability on a strict zero-split row blocks reservation creation.
WBS FEFO demands may set `allow_location_fallback = abap_true` with a preferred
`storage_location`. The preferred location leads other eligible locations for
stock with the same expiry date; shared allowlists still constrain the choice,
and location ranks order the remaining candidates. Base, priority, and
date-first previews and ATP estimates preserve the preference. Reservation,
goods-issue, and WBS FEFO transfer wrappers reuse it during their fresh stock
checks. The flag requires a preferred location, and any shared allowlist must
include it.
The base FEFO preview and `PREVIEW_FEFO_ATP` also accept
`it_request_location_priorities`. Positive per-request ranks override the
shared location order for equal expiry and batch candidates; unranked locations
follow by location code. Invalid, duplicate, or unknown rows fail before UOM
conversion or stock reads. `RESERVE_WBS_FEFO` forwards the rows to both its
initial preview and fresh recheck, so unchanged ranked splits can be reserved.
`ISSUE_PROJECT_WBS_FEFO` previews the requested WBS batch demand twice and
posts movement 221/Q only when the complete allocation, effective expiry
policy, and WBS assignments match between snapshots. It validates the selected
splits through the existing project-WBS batch issue path. It supports repeated
caller request IDs through unique internal row IDs and restores the caller IDs
in its preview. If stock or the FEFO selection changes, it returns a warning and
posts nothing. The check narrows the stale-preview window but does not lock
stock between the second read and the movement post.
`ISSUE_PROJECT_WBS_FEFO_BY_DATE` applies the required-date and same-date
priority ordering from `PREVIEW_FEFO_BY_DATE`, then repeats that preview before
posting. It supports repeated caller request IDs by using distinct internal row
IDs during allocation and movement validation, and restores the caller IDs in
the returned preview. It posts 221/Q only when allocation, expiry metadata,
required date, priority, and WBS assignments still match; a changed snapshot
returns a warning and leaves the movement API untouched.
`ISSUE_PROJECT_WBS_FEFO_PRIO` applies the priority order from
`PREVIEW_FEFO_PRIORITY` and accepts its optional date-first ordering flag. It
repeats the same priority preview before posting, keeps repeated caller IDs
distinct through movement validation, and returns the original IDs. The
allocation, effective expiry policy, priority, and WBS assignment must match
both snapshots before it posts movement 221/Q. All three FEFO issue methods
also accept `it_request_locations`, remap those rows through internal request
IDs, use the same scope in both stock snapshots, and return the caller-facing
rows.
All three issue variants accept `it_request_location_priorities`; they validate
ranks against caller IDs, expand them to each internal row when IDs repeat, and
reuse the same rows for both previews.

`PREVIEW_FEFO_BY_DATE` adds a required date and integer priority to each
project-stock FEFO demand. Earlier dates consume shared WBS/material/plant
balances first; higher priorities run first within the same date, and input
order breaks ties. Allocations and batch splits return in caller order and echo
the required date and priority. Repeated caller request IDs are supported
through internal row IDs; keep a separate row key to distinguish repeated IDs
downstream. `it_request_location_priorities` applies request-specific location
ranks within equal-expiry batch candidates, including when caller IDs repeat.
Expiry eligibility uses the latest of the shared as-of date, the demand's
`fefo_as_of_date`, and its required date. This is still a current
project-stock snapshot and does not add future receipts or reserve the selected
batches.
WBS FEFO demand rows may set `require_full_quantity = abap_true` for
row-level all-or-none allocation. If a strict row cannot be fully covered, it
gets no batch splits and leaves stock available for later rows. The shared
`iv_require_full_quantity` option still applies to every row. Priority and
required-date wrappers preserve the rule while sorting internally, restore
caller order, and echo the effective rule in each allocation summary. WBS FEFO
goods-issue adapters carry it through both stock snapshots, so a partial-issue
request can post eligible partial rows without partially issuing a strict row.
Invalid row values fail before project stock reads or UOM conversion.

`PREVIEW_FEFO_BY_DATE_ATP` returns the same local estimate with cumulative
plant-level ATP checks for positive allocations, grouped by material, plant,
base unit, and required date. Pass `iv_check_rule` to request the SAP check.
Confirmed and unconfirmed quantities are diagnostics only; they do not change
the WBS stock estimate or confirm a particular batch.
`PREVIEW_FEFO_ATP` pairs the undated FEFO estimate with cumulative plant-level
ATP checks for its positive allocations, grouped by material, plant, and base
unit. `iv_atp_check_date` defaults to `sy-datum` and affects only the ATP
request; batch eligibility and local allocation still use the FEFO as-of date
and current project stock. ATP does not confirm the selected WBS batch.
`PREVIEW_FEFO_PRIORITY` applies stable priority ordering across shared
project-stock FEFO demands by default: higher priorities consume shared
WBS/material/plant batch balances first, and input order breaks ties. Set
`iv_prioritize_by_date = abap_true` to process earlier per-demand
`fefo_as_of_date` values first, then higher priority for same-date requests.
Every demand must provide a valid FEFO date in this mode. Its allocation
summaries, batch splits, and WBS assignments return in caller order and echo
priority. Repeated caller request IDs are supported because the preview
correlates rows with internal IDs; keep an additional row key if a downstream
consumer needs to distinguish repeated IDs.
It also accepts `it_request_location_priorities`; each caller ID's ranks are
mapped to its internal request rows, so repeated IDs use the same local order
through the preview and its ATP adapter.
`PREVIEW_FEFO_PRIORITY_ATP` returns that local estimate with plant-level ATP
checks for positive allocations, grouped by material, plant, and base unit. Its
optional `iv_atp_check_date` defaults to `sy-datum`; the ATP wrapper forwards
the same date-first option, and its diagnostic does not change allocation or
confirm a specific WBS batch.
`PREVIEW_BY_LOCATION_DATE` applies the same required-date and same-date
priority ordering to batchless project stock. It returns allocation and
storage-location splits in caller order and echoes date and priority. Repeated
caller request IDs are supported through internal row IDs; keep a separate row
key to distinguish repeated IDs downstream. `it_request_location_priorities`
sets each demand's location order; ranks are mapped to internal rows when
caller IDs repeat, and unranked locations follow by location code. The preview
uses current batchless location balances and does not assign future receipts
to locations.
`PREVIEW_BY_LOCATION_DATE_ATP` returns this local estimate with cumulative
plant-level ATP checks for positive allocations, grouped by material, plant,
base unit, and required date. Pass `iv_check_rule` to request SAP diagnostics.
The ATP response does not change the location allocation or confirm a specific
storage location.
`PREVIEW_BY_LOCATION_ATP` adds the same plant-level diagnostic to undated
batchless location previews. Its optional `iv_atp_check_date` defaults to
`sy-datum`; choosing a future check date does not phase the local stock by date
or confirm the selected storage location.
`PREVIEW_BY_LOCATION_PRIORITY` applies descending priority to undated
batchless project-stock demands. Higher priorities consume shared
WBS/material/plant/location balances first, input order breaks ties, and its
allocation summaries, location splits, and WBS assignments return in caller
order with priority echoed. As with the FEFO priority preview, repeated caller
request IDs are supported through internal row IDs. Request-specific location
ranks override the shared location order for one caller ID; unranked locations
follow by location code. The ATP wrapper preserves the same rank rows.
`PREVIEW_LOCATION_PRIORITY_ATP` returns this local estimate with cumulative
plant-level checks for positive allocations, grouped by material, plant, and
base unit. The optional `iv_atp_check_date` defaults to `sy-datum`; ATP does
not change the priority allocation or confirm a specific storage location.
Shelf-life filters apply only to batch FEFO; location-only previews reject a
nonzero demand-level minimum because those balances have no batch expiry to
check.
For a batchless transfer, `PREVIEW_TRANSFER_BY_LOCATION` scopes the preview to
each source WBS and returns source/destination assignments with its location
splits. `TRANSFER_WBS_LOCATION_ALLOC` validates those totals and posts the
positive splits as movement 415/Q; full allocation is required by default.
Set `iv_require_full_allocation = abap_false` to post only available splits.
The preview is a stock snapshot and is not reserved before posting.
`TRANSFER_WBS_BY_LOCATION` repeats the preview before posting and supports
repeated caller request IDs by using distinct internal row IDs through transfer
validation, then restores the caller IDs in its preview. A changed location
split returns an error without posting; the second read still does not lock
stock.
The base, priority, and dated transfer previews accept
`it_request_location_priorities`. Each row assigns a positive rank to one
request and storage location; ranks override the shared location order for
that request, while unranked locations follow by location code. ATP adapters
forward the same rows. `TRANSFER_WBS_BY_LOCATION`,
`TRANSFER_WBS_LOC_PRIORITY`, and `TRANSFER_WBS_BY_LOCATION_DATE` map caller
ranks to their internal request IDs and reuse them for the posting recheck.
`PREVIEW_TRANSFER_LOC_ATP` adds cumulative plant-level ATP diagnostics
for positive undated location allocations. The optional `iv_atp_check_date`
defaults to `sy-datum`; it does not change the local location split or confirm
special WBS stock or a selected storage location.
`PREVIEW_TRANSFER_LOCATION_DATE` adds required dates and integer priorities to
batchless WBS transfers. Earlier dates consume source WBS location balances
first; priority breaks ties, then input order. It returns location splits and
source/destination assignments in caller order. `TRANSFER_WBS_BY_LOCATION_DATE`
repeats the dated preview and checks the location, source and destination WBS,
quantity, and unit before posting 415/Q. Repeated caller request IDs are
supported by both the dated preview and transfer method; results restore caller
IDs and input order after correlating rows internally. Retain a separate row
key when consumers need to distinguish repeated IDs. It uses current batchless
stock and does not assign future receipts to locations. Request-specific
location ranks override the shared location order for each dated demand and
survive the fresh transfer snapshot.
`PREVIEW_TRANSFER_LOC_DATE_ATP` adds cumulative plant-level ATP diagnostics
for positive location allocations, grouped by material, plant, base unit, and
required date. The checks do not change the local location split or confirm
special WBS stock or a specific storage location. They do not reserve stock;
verify the checking rule and confirmation lines in the target SAP system.
`ISSUE_SALES_ORDER_ALLOCATION` accepts a successful single-order preview from
`ZCL_SALES_ORDER_ALLOC_SERVICE=>PREVIEW_ORDER` and the material base-unit/ISO
mappings. It posts the preview's positive location or batch splits as 231 items,
preserving selected storage locations and batches. Full allocation is required
by default; set `iv_require_full_allocation = abap_false` to post only allocated
quantities. The service verifies the preview summaries and split totals before
posting. This path covers unrestricted stock represented by the preview, not
special sales-order stock. A preview is a stock snapshot; SAP remains the final
authority when stock or order state changes before posting.
`ISSUE_SO_ALLOC_RECHECKED` accepts the original and a fresh preview the caller
recomputes with the same allocation options immediately before issue. It
compares summaries and all location or batch splits, then posts the fresh
result as movement 231 only when they match.
`PREVIEW_ORDER` and `RESERVE_ORDER` accept `minimum_coverage_pct` on each
`it_allocation_requirements` row, keyed by sales document, item, and optional
schedule line. A row without a schedule line applies to that item's schedule
lines unless a line-specific row is supplied. The floor ranges from 0 to 100
and is checked against eligible base-unit stock before the shared balance is
consumed; a demand below its floor receives zero allocation and leaves stock
for later demands. `PREVIEW_ORDERS_BY_DATE`, `RESERVE_ORDERS_BY_DATE`, and the
bulk dated reservation method preserve the same per-item floor. Allocation
results echo the floor, F/P/U outcome, and two-decimal base-unit coverage
percentage. Full-allocation requirements continue to apply alongside the
floor.
`ISSUE_UNPLANNED_PROD_ORDER` posts direct movement 261 withdrawals to a
production order, including materials not listed as order components. Its
unit-aware variant converts quantities to the material base unit using the
supplied base-unit/ISO mapping. Use reservation-backed component issue methods
when the reservation withdrawal quantity must be updated; direct unplanned
issues do not read components or estimate available stock.
`RETURN_TO_PRODUCTION_ORDER` posts movement type 262 against a production order
for caller-selected returned components. `RETURN_TO_PRODUCTION_ORDER_UOM`
converts source quantities to mapped base units first; both retain batch and
order assignments and support partial returns through the standard simulation
and commit flow.
`RETURN_PROD_ORDERS_BULK` accepts distinct production orders and posts one
independent movement per order, continuing after an individual BAPI failure
by default. Set `iv_stop_on_failure = abap_true` to stop after the first
failure; later rows are marked `is_skipped` and counted separately. Review each
row because earlier returns may be committed when a later one fails.
`RETURN_PROD_ORDERS_BULK_UOM` supports the same option and converts and validates
every line against the supplied material base-unit/ISO mappings before posting.
`RETURN_PROD_ORDERS_ATOMIC` stages one movement call per distinct order and
commits the group once; a failed call or commit rolls back the staged returns.
`RETURN_PROD_ORDERS_ATOMIC_UOM` converts and validates the full group before
staging it. Both atomic methods support simulation and return per-order
document results only when the group succeeds.
`ISSUE_UNPLANNED_PROD_BULK` accepts distinct production orders and
posts one independent material document per order. It validates every order
and line before posting, then continues after an individual posting failure by
default. Its `iv_stop_on_failure` option stops later orders and marks them as
skipped after the first failure; review each row result because the batch can
partially succeed. Test runs simulate each order without committing.
`ISSUE_UNPLANNED_PROD_BULK_UOM` accepts the same grouping and option, and
converts and validates every line against the supplied base-unit/ISO mappings
before the first post.
`ISSUE_PROD_ORDERS_ATOMIC` stages one movement-261 document per distinct order
and commits the whole group once; a movement or commit failure rolls back the
staged group. `ISSUE_PROD_ORDERS_ATOMIC_UOM` converts and validates every line
before staging. Both atomic methods support simulation and return per-order
document results only when the group succeeds.
`TRANSFER_PLANT_ALLOCATION` converts the base-unit location splits from
`ALLOCATE_ACROSS_PLANTS` into a single 301 goods movement. Supply a receiving
storage location by request ID and each material's base unit and ISO unit code.
It requires complete allocation by default; set
`iv_require_full_allocation = abap_false` to post only the allocated portion.
`TRANSFER_MATERIAL_TO_MATERIAL` posts movement type 309 for each supplied
source/receiving-material pair in one material document. Source plant and
storage location are required; receiving plant, storage location, and batch can
be supplied when the target stock assignment differs. For non-batch split
valuation, supply `valuation_type` for the source and
`receiving_valuation_type` for the destination; both flow to the BAPI transfer
item. The UOM form, `TRANSFER_MAT_TO_MAT_UOM`, converts source quantities to
base units and requires both materials to have the same mapped base unit and
ISO code before posting.
For direct LIFO re-identification, `TRANSFER_MAT_TO_MAT_LIFO` and
`TRANSFER_MAT_TO_MAT_LIFO_UOM` post movement type 310 with the same material
and unit validation. Both 309 and 310 carry source and receiving valuation
types through their base-unit variants. SAP documents changing valuation types
in transfer postings and direct movement 310 as reducing old stock in LIFO
order; confirm those behaviors for the target release and posting path.
`RELEASE_BLOCKED_STOCK` posts movement type 343 to transfer blocked stock into
unrestricted-use stock. The UOM form converts each quantity to its mapped
material base unit. Both forms preserve the source batch and storage location;
they post own stock only and leave SAP to validate actual stock and movement
configuration. `BLOCK_UNRESTRICTED_STOCK` and its UOM form post movement type
344 to move own unrestricted-use stock into blocked stock, with the same batch,
location, and base-unit handling.
`RELEASE_QUALITY_STOCK` posts movement type 321 from quality-inspection stock
to unrestricted-use stock. `SEND_STOCK_TO_QUALITY` posts movement type 322 in
the other direction. Both have UOM forms and retain the source batch and
location; SAP applies the target system's quality-management controls.
`RELEASE_QUALITY_FEFO_RECHECKED` accepts a unit-aware quality FEFO preview and
its freshly recomputed result. It requires matching summaries and batch splits,
verifies unit mappings, quantities, and batch eligibility through the posting
date, then posts movement 321 using the selected base-unit split quantities.
Full allocation is required by default; callers can opt into partial
allocation. The caller supplies both previews, and stock can change between
the refresh and posting because this flow does not lock the stock.
`RELEASE_QUALITY_FEFO_PRIORITY` runs the same recheck for priority-ordered
quality FEFO demands. Higher priorities consume shared inspection stock first;
the method compares the priority echoes and batch splits before posting 321.
Request IDs must be unique, and full allocation remains the default.
`SEND_QUALITY_FEFO_PRIORITY` applies priority ordering to unrestricted-stock
FEFO demands, rechecks the priority echoes and batch splits, then posts movement
322 into quality inspection stock. It also accepts location priorities,
allowlists, safety-stock protection, and partial allocation.
Request IDs must be unique; full allocation is required by default. Both
methods accept `iv_prioritize_by_date = abap_true` to process earlier per-demand
FEFO dates first and higher priorities first on ties; each demand then needs a
valid FEFO date, and the same option is used during the posting recheck.
`SEND_QUALITY_FEFO_RECHECKED` applies the same recheck and split validation to
an unrestricted-stock FEFO allocation, then posts movement 322 to quality
inspection stock with the selected batches and base-unit quantities.
`ALLOCATE_QUALITY_BY_EXPIRY` and its UOM form accept storage-location priority
and allowlist options. Priority orders locations within the same expiration
date and batch; remaining eligible locations follow ascending location code.
Both forms, their priority adapters, and both ATP forms also accept
`it_request_location_priorities`; local ranks override shared order only within
the same batch and expiration date. UOM adapters validate the rows before
conversion and remap them through internal request IDs.
An empty allowlist keeps every location eligible, and priority entries outside
a nonempty allowlist are ignored. A demand's preferred location must be inside
the allowlist when one is supplied. `RELEASE_QUALITY_FEFO` forwards these same
options while recomputing the confirmed allocation.
`ZCL_QUALITY_STOCK_SERVICE` runs the complete confirmation workflow: it takes
the original preview and the exact demand/options used to build it, recomputes
the eligible allocation from the stock repository, and posts only if the
allocation still matches. `RELEASE_QUALITY_FEFO` reads quality-inspection
stock; `SEND_QUALITY_FEFO` reads unrestricted stock and also accepts location
priority, location filters, and safety-stock protection. Both use the supplied
unit mappings for posting and default to requiring full allocation.
`RELEASE_QUALITY_FEFO_PRIORITY` and `SEND_QUALITY_FEFO_PRIORITY` retain priority
ordering across the recheck; the send form reads unrestricted stock and supports
safety-stock protection. Construct the service with
`ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_QUALITY_STOCK_SERVICE()`.
All four methods validate their boolean options before handling an empty-demand
no-op, including `iv_test_run` and allocation policy flags.
All four quality FEFO posting methods accept `it_request_location_priorities`
and use the same per-request ranks when they recompute the preview. This keeps
location splits stable within matching batch and expiry ties; a changed split
is rejected before posting.
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
explicitly when the dated result has a shortfall. Positive source and batch
splits must retain their demand's required date and priority before those date
fields are mapped out of the movement request.
`TRANSFER_FEFO_DATE_ATP` and `TRANSFER_FEFO_DATE_ATP_2STEP` accept
`ALLOCATE_PLANTS_FEFO_DATE_ATP` results. Each requires exactly one matching,
relevant, fully confirmed cumulative ATP check per positive source/date
allocation, and verifies that the selected batch/location splits sum to the
confirmed source quantities before posting. The ATP check's derived
confirmation totals must also agree with its raw ATP result. Source splits
must retain the demand date and priority, and source totals must match the
demand allocation. ATP remains plant-level and does not reserve the selected
batches or locations.
`TRANSFER_PLANT_DATE_LOC_UOM` and `TRANSFER_DATE_LOC_UOM_2STEP` accept
`ALLOCATE_PLANTS_DATE_LOC_UOM` results. They preserve each source-location
split and post its canonical base-unit quantity through either 301 or 303/305.
Both verify that each location split matches its demand's required date and
priority, and check base units against the supplied material mappings. Required
dates determine the preview allocation; goods movements use the posting date
from the shared header.
`TRANSFER_DATE_LOC_ATP` and `TRANSFER_DATE_LOC_ATP_2STEP` accept
`ALLOCATE_PLANTS_DATE_LOC_ATP` results and apply the same movement paths only
when each positive source/date allocation has exactly one matching, relevant,
fully confirmed cumulative ATP check. They also reconcile the confirmed plant
quantities to the location splits before posting. ATP checks remain plant-level
diagnostics and do not reserve stock or identify a specific location.
`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_ALLOCATION` creates an intra-company
stock transport order from a dated, unit-aware cross-plant allocation result.
Each call creates one `UB` purchase order for one supplying/receiving plant
pair; each matching allocation becomes a `U` item with its source-unit
quantity and requested date on one schedule line. Before writing, it verifies
that each demand's allocated base quantity equals the sum of its source-plant
splits. The target storage location is optional. Short target demand is rejected
by default; set
`iv_allow_partial = abap_true` to order only the allocated quantities. Set
`iv_test_run = abap_true` to call `BAPI_PO_CREATE1` in test mode without
committing. Live stock-transfer order creates require the returned PO number;
successful test runs may omit it. This creates the order proposal only; it does not post goods issue
or receipt. SAP documents `UB` and item category `U` for a stock transport
order without delivery, with subsequent 351/101 goods movements
([STO without delivery](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/5213b953495bb44ce10000000a174cb4.html)).
Schedule dates taken from dated allocations and caller-supplied batch delivery
dates must be valid Gregorian calendar dates before `BAPI_PO_CREATE1` is called.
SAP still determines whether a valid date satisfies purchasing and planning
rules for the target system. Before building any order request, the service
also validates each carried `minimum_coverage_pct` from 0 through 100 against
the demand's requested and allocated base quantities. A positive allocation
below its floor is rejected; a zero allocation remains a valid floor-rejected
demand and follows the existing partial-allocation rules.
The adapter maps the request through `BAPI_PO_CREATE1`; live creates require
the returned purchase-order number before reporting success, while successful
test runs may omit that simulated number. Its `TESTRUN` flag suppresses
database updates and successful writes use the BAPI transaction commit ([BAPI_PO_CREATE1](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167600.html),
[BAPI transaction commit](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167428.html)).
For external procurement, `ZCL_PURCHASE_ORDER_SERVICE->CREATE_ORDER` accepts an
explicit vendor and a list of items, each tied to exactly one selected
info-record or outline-agreement source. It submits the selected source through
`BAPI_PO_CREATE1`; it does not run source determination. Header vendor,
document type, company code, purchasing organization/group, document date, and
each item's delivery date must be supplied. Test runs skip the commit.
Document and item delivery dates are checked as Gregorian calendar dates before
the BAPI call. Bulk and atomic creation validate every request date before the
first write; SAP still decides purchasing-date eligibility.
`CREATE_ORDERS_BULK` validates every request before writing, then creates each
PO and commits it independently. By default it continues after an order fails
and returns one result per request. Every request in one bulk call must use the
same test-run setting. Check the per-order messages and commit state for partial
completion.
`CREATE_ORDERS_ATOMIC` validates the complete batch, submits every PO in one
SAP LUW, and commits once only when all creates succeed. A create or commit
failure rolls back the group and clears its returned PO numbers; test runs skip
the commit. Confirm multi-PO rollback behavior in the target release before
relying on this transaction boundary.
Validate the target release's mapped fields and selected-source behavior using
the assumptions in [ANOMALIES.md](ANOMALIES.md).
`CREATE_FROM_SUGGESTIONS` converts selected external replenishment suggestions
into one PO request. Every positive suggestion must match the header vendor and
purchasing organization and carry one selected PIR or agreement source; zero
quantity rows are skipped. Each positive suggestion becomes one PO item and
one dated schedule line. Optional per-suggestion purchasing controls convert
the base quantity using the supplied order-to-base ratio. Overflow and nonzero
quantities that round to zero raise `ZCX_INVALID_STOCK_REQUEST` before the
BAPI call. Review candidates
first with `zcl_repl_source_service`, apply the selected options, and pass the
resulting suggestions here. The method does not perform source determination or
split a single call across vendors. Verify selected-source, quantity precision,
and UOM behavior in the target SAP release.
`PREPARE_FROM_SUGGESTIONS` returns this validated PO request, including item
numbers, selected source references, schedule lines, and converted quantities,
without calling SAP; it rejects malformed header and suggestion dates during
preparation. `CREATE_FROM_SUGGESTIONS` submits that same request.
`CREATE_FROM_SUGGESTIONS_BULK` accepts the same header template and groups the
positive rows by vendor and purchasing organization in first-seen order. It
validates and maps every group before creating any PO, then commits each PO
independently and continues after a failed group. Item `source_request_id`
preserves the suggestion's original index. Review every per-order result because
the batch can be partially completed; verify the same source and unit behavior
in the target release. An all-zero batch succeeds as an informational no-op
without calling SAP.
`PREPARE_FROM_SUGGESTIONS_BULK` returns those validated vendor/organization
requests without an API call. Bulk and atomic creation use the same prepared
groups, so callers can inspect every supplier PO and item mapping first.
`CREATE_FROM_SUGGESTIONS_ATOMIC` applies the same grouping, source checks, and
optional unit conversion, then commits all supplier POs together. A create or
commit failure rolls back the batch and clears provisional PO numbers. An
all-zero batch returns an informational no-op result. Validate multi-PO LUW
behavior in the target SAP release before relying on the transaction boundary.
`CREATE_FROM_REQUISITION_ITEMS` maps selected rows from
`read_pr_items` into one PO and keeps the requisition number and item on every
PO line. It uses the remaining quantity (`quantity - ordered_quantity`) and
copies material, plant, storage location, unit, and delivery date from the PR
read result. The header vendor and purchasing organization must agree with any
source values present on the selected rows. Deleted, closed, exhausted, or
duplicate items are rejected before the BAPI call; SAP still validates release
state and source eligibility. `PREPARE_FROM_REQUISITION_ITEMS` returns the
validated PO header and mapped items without calling SAP; creation uses that
same prepared request. Test runs follow the ordinary `CREATE_ORDER` behavior.
SAP's BAPI guide and requisition-reference field mapping describe the
underlying PO item interface
([BAPI_PO_CREATE1](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167600.html),
[PO requisition fields](https://help.sap.com/doc/44c78f4213c44c46bfcf544e832c5ad9/2025.1/de-DE/MCF%28Konfig%29-DE.pdf)).
`CREATE_FROM_REQUISITIONS_BULK` accepts selected rows from one or more PR reads.
Each row carries its requisition key and selected vendor/purchasing organization;
rows are grouped in first-seen order, with one PO per vendor/organization pair.
Each PO item keeps its PR reference and uses that row's remaining quantity.
Every group is mapped and validated before the first create call, then each PO
commits independently and processing continues after failures. Review each
per-order result for partial completion. SAP still validates source, release,
and PR conversion behavior in the target system.
`PREPARE_FROM_REQUISITIONS` returns those same validated supplier-grouped PO
requests without calling SAP. Both the bulk and atomic create methods use this
prepared group list; callers can review vendors, purchasing organizations,
remaining quantities, and PR item references before writing.
`CREATE_REQUISITIONS_ATOMIC` accepts the same selected rows and grouping inputs,
but creates every group in one transaction: any failed create or commit rolls
back the batch and clears provisional PO numbers from its results. Run this
path only after validating multi-PO LUW behavior in the target SAP release.
`CHANGE_ORDER_SCHEDULES` changes selected PO schedule lines by item and schedule
line number through `BAPI_PO_CHANGE`. A row can change its positive scheduled
quantity, delivery date, or both. `CHANGE_ORDER_SCHEDULES_BULK` validates all
PO groups before writing, then commits each PO independently and continues
after failures; inspect every per-order result for partial completion. These
methods accept `iv_test_run = abap_true` to ask `BAPI_PO_CHANGE` to validate
without committing. The bulk form simulates each PO independently. The atomic
form also simulates each PO, but does not create a shared transaction or prove
that the complete group can commit together. SAP validates whether the
schedule line and item are still changeable and how the new schedule quantity
relates to the PO item total. Changed delivery dates must be valid Gregorian
calendar dates; bulk and atomic forms check the complete list before any BAPI
update. The request uses SAP's `POSCHEDULE`/`POSCHEDULEX` structures
([SAP BAPI_PO_CHANGE example](https://help.sap.com/docs/SUPPORT_CONTENT/home/3361892108.html),
[SAP schedule-line field mapping](https://help.sap.com/http.svc/rc/c89a68e4c09c490d9ba03d6f2a3dca88/7.0/en-US/CGIntegrationW7op12.pdf)).
`CHANGE_ORDER_SCHEDULES_ATOMIC` validates all selected PO groups first, applies
the schedule changes, and commits once. A failed change or commit rolls back
the batch and preserves the affected PO numbers in the result. With
`iv_test_run = abap_true`, it reports each simulated result without commit or
rollback. Verify multi-PO LUW behavior in the target SAP release before live
atomic use.
`CHANGE_BASE_SCHEDULES` accepts schedule quantities in the material base unit
and converts them to the item's PO unit before calling the existing schedule
change flow. It forwards `iv_test_run` through its single, bulk, and atomic
forms. Date-only rows keep working without a PO read. The bulk and atomic
forms read and convert every quantity-bearing PO schedule before any writes;
quantity changes for missing, deleted, or delivery-complete items are rejected.
Bulk commits each PO independently, while atomic commits all POs together.
`CHANGE_ITEM_QUANTITIES` updates selected PO item quantities through the
`BAPI_PO_CHANGE` `POITEM`/`POITEMX` tables. Quantities are in each item's
purchase-order unit; blank/duplicate item numbers and nonpositive quantities
are rejected before the BAPI call. The bulk method validates every PO first,
then commits each document independently and continues after failures. The
atomic method validates the complete group, commits once, and rolls the pending
changes back if any PO update or the shared commit fails. These live changes
accept `iv_test_run = abap_true` to simulate each BAPI update without commit or
rollback. The atomic simulation does not test a shared commit. SAP applies its
item field controls and determines how the changed item quantity affects
schedule lines. Review every result and
validate representative received, released, and multi-schedule items in the
target system. SAP's BAPI example maps item quantity in `POITEM` and its update
flag in `POITEMX` ([SAP quantity update example](https://help.sap.com/docs/SUPPORT_CONTENT/ABAP/3353524339.html?locale=en-US&state=PRODUCTION&version=LATEST));
successful BAPI changes require `BAPI_TRANSACTION_COMMIT`
([SAP purchasing BAPIs](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167428.html)).
`CHANGE_QTY_FROM_BASE` accepts the same item selection with quantities in each
material's base unit. It reads the PO, converts each quantity to the item's
purchase-order unit through the material UOM service, and rejects missing item
data or conversion ratios before writing. Its bulk and atomic forms complete
all PO reads and conversions before the first update; bulk then commits each PO
independently, while atomic commits the complete group together. Bulk write
results expose top-level `is_committed` when at least one purchase order commits,
so partial persistence remains visible after a later failure. The target SAP
system still controls item eligibility and how changed quantities affect
receipts, schedules, and confirmations. Pass `iv_test_run = abap_true` to
simulate these updates; the option is forwarded by both bulk forms and both
atomic forms, which skip commit and rollback in test mode.
`DELETE_ORDER_ITEMS` marks selected items for deletion with `BAPI_PO_CHANGE`;
SAP keeps the purchase order and applies its normal deletion and document
history rules. `DELETE_ORDERS_ITEMS_BULK` validates the complete list first,
then commits each purchase order independently and continues after failures.
Pass `iv_test_run = abap_true` to simulate the single or bulk updates without
committing. SAP's sample shows the item deletion flag in
`POITEM` and `POITEMX`
([BAPI_PO_CHANGE deletion example](https://help.sap.com/docs/SUPPORT_CONTENT/home/3361892108.html)).
`DELETE_ORDERS_ITEMS_ATOMIC` validates all PO/item groups before changing any,
then commits the deletions together. A failed update or commit rolls back the
batch. In test-run mode it simulates each PO without commit or rollback; this
does not validate a shared multi-PO commit. Verify multi-PO LUW behavior in the
target SAP release.
`MARK_DELIVERY_COMPLETE` sets the selected items' delivery-completed indicator
through `BAPI_PO_CHANGE`; `MARK_DELIVERY_COMPLETE_BULK` validates all documents
first and commits each change independently. SAP then treats the remaining open
order quantity as zero even when some quantity is undelivered; a later receipt
can still be possible under SAP's rules. Pass `iv_test_run = abap_true` to
simulate single and bulk calls without committing. See the
[SAP delivery-completed indicator behavior](https://help.sap.com/doc/saphelp_em700_ehp01/7.0.1/en-US/c7/51a6390f515130e10000000a114084/content.htm?no_cache=true).
`MARK_DELIVERY_COMPLETE_ATOMIC` validates all selected PO/item groups and
commits their delivery-completed flags together, rolling back on any failed
update or commit. In test-run mode it simulates each selected PO without commit
or rollback; SAP still decides whether each item is eligible for the status
change.
Purchase-order independent bulk writes accept `iv_stop_on_failure`, defaulting
to `abap_false`: PO creation, suggestion and requisition grouped creation, item
deletion, delivery completion, schedule changes, and item quantity changes.
They validate the complete request before calling SAP. With `abap_true`, the
first failed PO operation stops later calls; every PO remains in caller order,
and unattempted rows have `is_attempted = abap_false` and `is_skipped =
abap_true`. The summary reports separate successful, failed, and skipped
counts, and `stopped_on_failure` stays true when the failed row is last.
Base-unit quantity and schedule bulk methods validate and convert all rows
before forwarding the flag. Skipped suggestion and requisition creation rows
retain their source references in `submitted_items`. Earlier independent
commits remain committed; atomic methods keep their existing shared-LUW
behavior.
`READ_ORDER` and `READ_ORDERS` retrieve the saved header, item quantities and
status flags, and every returned schedule line through
`BAPI_PO_GETDETAIL1`. The bulk method validates all PO numbers before reading
and returns one result with SAP messages per document. The schedule output
includes the dated quantities SAP returns; it does not calculate remaining
open quantity from purchase history. For projected supply and received
quantities, use `GET_PROJECTED_RECEIPTS` described above. SAP's
[purchase-order notification flow](https://help.sap.com/docs/sap_erp_spv/1a781c11dd4f41829c798db4d8ff3a41/c2ae57a5ad6511dc2b8d000f20fcb6a9.html)
uses `BAPI_PO_GETDETAIL1`; its [purchase-order schedule view](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/8308e6d301d54584a33cd04a9861bc52/6e52f71dfb5a481b810ce0697708baf2.html)
documents schedule-line quantities and dates.
All four release/send methods also accept `it_request_locations` and apply the same scope during their fresh quality or unrestricted-stock allocation check. Empty-demand calls reject nonempty scopes.


`CREATE_FROM_SOURCE_PLANTS` handles an allocation for one receiving plant
across multiple supplying plants. It prepares one `UB` order per supplying
plant in allocation priority order, validates every order request before the
first BAPI call, including that source-plant base quantities reconcile to each
demand's allocated base quantity, and returns the result and submitted items
for each order.
Each order commits independently; the service continues with later suppliers
after a BAPI failure, so inspect both the aggregate success flag and each
source-plant result for partial completion. The top-level `is_committed` is true
when at least one order was committed, including a partial non-atomic run. It is
false for simulations and for atomic batches that fail before the shared commit.
Test-run mode simulates every prepared order without committing. Set
`iv_atomic = abap_true` to defer the commit until all supplier orders have been
created successfully. A create or commit failure rolls back the pending group
and stops further supplier calls; successful results are marked committed only
after the shared commit succeeds.
`CREATE_FROM_SOURCE_PLANTS` and its ATP wrapper also accept
`iv_stop_on_failure`, defaulting to `abap_false`. With it enabled, the first
failed create stops later supplier calls; the complete caller-order result
still includes later suppliers as `is_skipped`. Summary counts separate
successful, failed, and skipped suppliers, and `stopped_on_failure` remains
true when the last supplier fails. Earlier independent commits remain. Atomic
failures roll back the staged suppliers and identify unattempted suppliers as
skipped.
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
`CREATE_FOR_BASE_PLANT_PAIRS` accepts `ALLOCATE_ACROSS_PLANTS` output, and
`CREATE_FOR_PRIO_PLANT_PAIRS` accepts `ALLOCATE_PLANTS_PRIORITY` output.
Both require a material-to-base-unit table because those allocation results
contain quantities but no unit. They validate the mapping before writing,
preserve source-location splits and priority, and apply the supplied delivery
date. Callers must provide each material's actual `MARA-MEINS` value.
`CREATE_FOR_UNIT_PLANT_PAIRS` accepts `ALLOCATE_PLANTS_IN_UNITS` output, and
`CREATE_FOR_UOM_PLANT_PAIRS` accepts `ALLOCATE_PLANTS_UOM_PRIORITY` output. Both
preserve source-location splits, write the allocated base quantity and base unit,
apply the caller-supplied delivery date, and accept the same receiving-location
map and atomic commit option.
`CREATE_FOR_UNIT_ATP_PAIRS` accepts `ALLOCATE_PLANTS_ATP` output, and
`CREATE_FOR_UOM_ATP_PLANT_PAIRS` accepts `ALLOCATE_PLANTS_UOM_ATP_PRIO`
output. It requires full current-date confirmation for each positive
material/source-plant/base-unit group before creating any order, preserves the
source-location splits, and puts the caller's delivery date on each item.
Quantities are written in the material base unit. It accepts the same receiving
location map and atomic commit option.
`CREATE_FOR_ALL_PLANT_PAIRS` extends this to allocation results spanning
multiple receiving plants. It creates one order per positive source/target
plant pair and accepts a receiving-storage-location map keyed by receiving
plant; targets without a map entry leave the location blank for SAP defaulting.
It validates the full result, demand-to-source totals, and every location entry
before writing, and returns per-pair results. All pair-order creation methods
expose top-level `is_committed`; it is true when at least one order committed,
so partial non-atomic runs remain distinguishable from simulations and atomic
failures. Orders commit independently by default. Set
`iv_atomic = abap_true` on this method, `CREATE_FOR_BATCH_PAIRS`, or
`CREATE_FOR_FEFO_PAIRS` to defer one shared commit until all pair orders are
created; a create or commit failure rolls back the pending group and stops
further pair calls.
All STO pair creation methods and the source-plant methods accept
`iv_stop_on_failure`, defaulting to `abap_false`. In non-atomic mode, the
default continues after an individual create failure; the option stops later
BAPI calls and returns their rows with `is_skipped`. Pair results report
successful, failed, and skipped counts, plus `stopped_on_failure`. A shared
atomic commit failure also sets `stopped_on_failure` when the option is on;
the rollback leaves every attempted pair unsuccessful and no pair skipped.
Previews do not reserve stock, so availability can change before posting.
`CREATE_FOR_BASE_DATE_PAIRS` accepts `ALLOCATE_PLANTS_BY_DATE` output with a
caller material/base-unit map. It retains the per-demand delivery dates,
creates one order per source/target plant pair, and writes base-unit
quantities through the validated atomic pair-order path.
`CREATE_FOR_BASE_DATE_LOC_PAIRS` accepts `ALLOCATE_PLANTS_BY_DATE_LOC` output
with a caller material/base-unit map. It keeps each allocation date, priority,
and source-location split, writes base quantities, and uses the validated
date/location pair-order path.
`CREATE_DATE_LOC_PAIRS` accepts `ALLOCATE_PLANTS_DATE_LOC_UOM` output and
creates one `UB` order per positive source/receiving plant pair. Each selected
source-location split becomes an item with its supplying storage location and
required date. Items use canonical base-unit quantities so rounded
alternative-unit splits do not change the allocated stock total. Demand-to-
plant and plant-to-location totals are validated before any BAPI call; full
allocation is required unless `iv_allow_partial` is enabled. Receiving
locations are mapped by target plant, and `iv_atomic` enables the shared
commit behavior.
`CREATE_DATE_LOC_ATP_PAIRS` accepts `ALLOCATE_PLANTS_DATE_LOC_ATP` output and
requires a matching, relevant, fully confirmed cumulative ATP check for every
positive source/date split before creating orders. ATP remains a precheck and
does not reserve the source stock.
`CREATE_FROM_BATCH_ALLOCATION` accepts a unit-aware exact-batch allocation for
one supplying/receiving plant pair. It emits one PO item per request/material/
batch with the allocated source-unit quantity, selected batch, caller-supplied
delivery date, and optional receiving storage location. When the allocation
includes source-location splits, it emits one item per batch/location split and
sets the supplying storage location on each item. Before writing, it verifies
that demand base quantities match source-plant totals and, when location splits
are present, that those totals match the location rows. Older results without
location splits keep the plant-level item mapping. The batch allocator does not
select a delivery date, so the caller must provide one. Complete allocation is
required unless `iv_allow_partial` is enabled. The adapter maps the batch
through the `BAPIMEPOITEM` item and its corresponding `POITEMX` selection flag.
This still creates an STO proposal only; goods issue and receipt remain
separate operations.
`CREATE_FOR_BATCH_PAIRS` carries exact-batch allocations across multiple
source/receiving plant pairs. It prepares one `UB` order per positive pair,
accepts the same receiving-location map, preserves supplying storage-location
splits as separate items when present, and returns per-pair results. It
validates demand, source-plant, and location totals in base units before any
order write. A shared delivery date is required because the batch allocation
has no PO schedule date. Orders commit independently by default;
`iv_atomic = abap_true` defers the commit across every pair as described above.
The S/4HANA Cloud STO OData V4 API does not support item batch; that OData
constraint does not define the separate `BAPI_PO_CREATE1` behavior
([OData V4 constraints](https://help.sap.com/docs/SAP_S4HANA_CLOUD/bb9f1469daf04bd894ab2167f8132a1a/807b2c79e22c4ef7a4c30c928bb3344e.html)).
`CREATE_FOR_PRIO_FEFO_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_PRIORITY` output
with the caller material/base-unit map and delivery date. It preserves FEFO
priority, batch, and issuing-location splits before delegating to the
validated FEFO pair-order path.
`CREATE_FOR_BASE_FEFO_PAIRS` accepts `ALLOCATE_PLANTS_BY_EXPIRY` output
and requires a caller material/base-unit map and delivery date. It keeps
the selected FEFO batch and issuing location on each item, writes base-unit
quantities, and uses the validated atomic pair-order workflow.
`CREATE_FOR_PRIO_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_BATCH_PRIORITY` output
and applies a caller material/base-unit map while retaining priority, batch,
and source-location splits. It writes base quantities and supports the same
delivery date, receiving-location map, and atomic commit options.
`CREATE_FOR_BASE_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_BY_BATCH` output and
requires the same caller-supplied material/base-unit map as the base plant
adapter. It preserves batch and source-location splits, uses base-unit
quantities, and validates the mapping before creating any order.
`CREATE_FOR_UOM_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_BATCH_UOM_PRIO` output
and retains its exact batch, issuing-location, priority-selected split, and
source-unit quantities in the STO items. Supply one delivery date for these
undated exact-batch allocations; the method supports the shared `iv_atomic`
commit option.
`CREATE_FOR_ATP_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_BATCH_ATP` output, and
`CREATE_FOR_UOM_ATP_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_BATCH_UOM_ATP` output.
Both require full confirmation for each positive material/source-plant/base-
unit/demand-as-of-date group before creating orders; blank demand dates use
today. They retain exact batches and UOM quantities, use the caller's shared
delivery date, and support the receiving-location map and atomic commit option.
`CREATE_DATED_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_DATE_BATCH_UOM` output and
creates one order per positive source/target pair. It retains each exact batch
and issuing location, and puts that request's required date on its PO item.
Before writing, it checks that demand quantities match source-plant totals and
that each source-plant base quantity matches its issuing-location splits.
Orders commit independently by default; `iv_atomic` shares one commit across
all pair orders. This entry point does not run or validate SAP ATP.
`CREATE_BASE_DATED_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_BATCH_BY_DATE`
output with a caller material/base-unit map. It retains each request date,
exact batch, and source-location split through the existing dated pair-order
validation and atomic commit path.
`CREATE_BASE_DATED_FEFO_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_BY_DATE`
output with a caller material/base-unit map. It preserves each request date,
FEFO priority, selected batch, and source-location split, writes base-unit
quantities, and delegates to the validated FEFO pair-order path.
`CREATE_DATED_BATCH_ATP_PAIRS` accepts `ALLOCATE_PLANTS_DATE_BATCH_ATP` output.
It validates full cumulative confirmation at every source/date group before any
write, then creates one order per positive source/target pair with an item for
each selected request, batch, and issuing location. Each item carries its
required date as the delivery date; `iv_atomic` shares one commit across all
pair orders. Grouped source, batch, and location quantity checks accumulate in
high precision, so overfull caller splits fail validation before order creation.
`CREATE_FOR_UNIT_FEFO_PAIRS` accepts unit-aware cross-plant FEFO output and
applies one caller-supplied delivery date to each selected batch/location item.
It preserves source-unit quantities and uses the validated FEFO pair-order path.
`CREATE_FOR_FEFO_PAIRS` accepts the dated, unit-aware cross-plant FEFO result
and creates one order per positive source/target pair. Each selected
batch/location split becomes a PO item with its batch, issuing storage
location, source-unit quantity, and FEFO required date. Before writing, it
checks that demand totals match source-plant totals and that source-plant totals
match batch/location splits in base units. It also rechecks each split's echoed
as-of date, minimum shelf life, effective undated-stock setting, and row policy
before the first PO call. The caller can map a receiving storage location per
target plant. FEFO is a preview and does not reserve stock; SAP also documents
that STO availability checks do not check batch stock when a batch is entered ([STO availability check](https://help.sap.com/docs/SAP_ERP_SPV/96bf9ad642cf4b26a29595e3d573fb8c/b160bd534f22b44ce10000000a174cb4.html)).
Orders commit independently by default; the opt-in `iv_atomic` mode defers the
commit across all source/target pairs.
`CREATE_FOR_ATP_FEFO_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_DATE_ATP` output and
checks each positive source/target/date total before creating any pair order.
The ATP check remains plant-level; it does not confirm a specific batch, and it
does not reserve stock. This entry point also supports the shared `iv_atomic`
commit mode.
`CREATE_FOR_UOM_FEFO_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_UOM_PRIO` output.
It carries the priority-ordered FEFO batch/location splits and source-unit
quantities into STO items, applying the caller's shared delivery date. The method
supports the same receiving-location map and atomic commit option.
`CREATE_FOR_FEFO_ATP_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_ATP` output, and
`CREATE_FOR_UOM_FEFO_ATP_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_UOM_ATP` output.
Both require one matching, fully confirmed current-date ATP check per positive
material/source-plant/base-unit group before writing. The caller supplies one
delivery date for the undated FEFO request; each selected batch/location split
becomes an STO item in its source unit. ATP is a precheck and does not reserve
the selected stock. Both methods support the shared `iv_atomic` commit mode.
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
`RECEIVE_PURCHASE_ORDER` offers a typed PO receipt request and builds the 101
movement rows from the PO number, item, quantity, unit, and optional material,
plant, storage location, and batch fields. Every line must include both the
SAP unit and its ISO code. `RECEIVE_PURCHASE_ORDERS_BULK` prevalidates all
distinct POs, then posts and commits each PO independently while continuing
after failures by default. Set `iv_stop_on_failure = abap_true` to stop after
the first failed receipt; later rows are marked `is_skipped` and counted
separately. The UOM bulk form supports the same option and converts the full
request before posting. `RECEIVE_PURCHASE_ORDERS_ATOMIC` prevalidates the group, stages
one movement call per PO, and commits once; a receipt or commit failure rolls
back the group and clears staged material-document identifiers. Both group
methods support BAPI test runs and return per-PO statuses and messages.
`RECEIVE_PO_ORDER_UOM` converts a single receipt using caller-supplied material
unit mappings. `RECEIVE_PO_ORDERS_BULK_UOM` and
`RECEIVE_PO_ORDERS_ATOMIC_UOM` convert and validate every line before posting;
the variants preserve PO item, batch, plant, and storage-location assignments.
`RETURN_PURCHASE_ORDER` provides a typed movement-122 vendor return using the
PO number and item, quantity, and unit, with optional material, plant, storage
location, and batch fields. `RETURN_PO_ORDER_UOM` converts from caller units
using material base-unit mappings. The bulk form commits each PO independently
and continues after failures by default; its `iv_stop_on_failure` option stops
later returns and marks unattempted rows skipped. The atomic form stages one
return per PO and commits once or rolls the group back. Both grouped UOM forms
convert every line before the first posting and return per-PO outcomes.
`RECEIVE_PROD_ORDER` maps a typed production-order request to movement type
101, GM code 02, and movement indicator `F`. `RECEIVE_PROD_ORDERS_BULK` commits
each order independently and continues after failures by default. Its
`iv_stop_on_failure` option stops later receipts after the first failure and
marks unattempted rows as skipped, counted separately from failed rows.
`RECEIVE_PROD_ORDERS_ATOMIC` stages the group and commits once or rolls back on
failure. Both prevalidate distinct production orders and all quantities and
units before posting, support BAPI test runs, and report material-document
identifiers only when the group remains committed. Receipt lines can include
the production order item number for co-product receipts; the adapter passes it
to `BAPI2017_GM_ITEM_CREATE-ORDER_ITM`. SAP lists the order item as an optional
co-product field for production-order goods receipts
([BAPI goods movement guidance](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
`RECEIVE_PROD_ORDER_UOM` converts a single receipt from caller-supplied
material unit mappings. `RECEIVE_PROD_ORDERS_BULK_UOM` supports the same stop
option. Both UOM group forms convert and validate the complete request before
the first movement and preserve batch and co-product item fields.
`ISSUE_STOCK_TRANSPORT_ORDER` posts movement 351 against a stock transport
purchase-order item from the supplying plant and storage location. It accepts
an optional batch per item, uses BAPI movement code 04 with a blank movement
indicator, and supports test runs. SAP describes 351 as the issuing-plant
goods issue for an STO without delivery; the receiving plant carries the
quantity in transit until the 101 goods receipt is posted
([STO issue flow](https://help.sap.com/docs/SAP_ERP/b704a8db767040a08100adc846218964/0601b953495bb44ce10000000a174cb4.html),
[BAPI movement codes](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
`ISSUE_STO_UOM` and `RECEIVE_STO_UOM` accept alternative-unit quantities and
convert them through caller-supplied material base-unit/ISO mappings before
posting, preserving the STO item, batch, and plant/location assignments.
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
351 for one pair does not stop later pairs by default. Set
`iv_stop_on_failure = abap_true` to stop after the first failed or ineligible
pair; later rows are marked `is_skipped`, with success, failure, and skipped
counts in the summary. Each pair returns its STO result, goods-issue result,
whether issue was attempted, and whether stock is now in transit. Test-run mode
simulates the goods issues for already committed STOs and does not set
`is_in_transit`. Rows already marked skipped by the STO creation batch remain
skipped here and are never posted.
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
Set `iv_stop_on_failure = abap_true` to stop after the first pair that is not
in transit or the first failed receipt; later rows are marked `is_skipped` and
counted separately. The default continues after failures. Skipped rows from the
issue result remain skipped and are never submitted for receipt.
Receipts commit independently by default. Set `iv_atomic = abap_true` to
require every pair to be in transit, post the 101 movements in one LUW, and
clear transit only after a shared commit succeeds. A receipt or commit failure
rolls back the group and leaves every pair in transit.
`CANCEL_ISSUED_STO` and `CANCEL_ISSUED_STO_PAIRS` reverse the whole committed
351 material document for an eligible in-transit pair through
`BAPI_GOODSMVT_CANCEL`. They prevalidate all document/year keys, cancel each PO
in a separate transaction, and continue after failures by default. Set
`iv_stop_on_failure = abap_true` on `CANCEL_ISSUED_STO_PAIRS` to stop after the
first ineligible pair or failed reversal. Later rows are marked `is_skipped`
and counted separately from successes and failures. A successful reversal
clears that pair's in-transit status. SAP selects the
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
Failures leave the receipt state unchanged while later documents continue by
default. Set `iv_stop_on_failure = abap_true` on
`CANCEL_RECEIVED_STO_PAIRS` to stop after the first ineligible pair or failed
reversal; later rows are marked `is_skipped` and counted separately.
The cancellation BAPI has no test-run option; SAP checks whether document
history, posting period, and current stock allow each reversal.
`CANCEL_MATERIAL_DOCUMENTS_BULK` accepts distinct document/year keys, optional
posting dates, and optional item lists per request. It validates the whole list
before calling SAP and returns one attempted/cancelled status with reversal
details per request. Calls commit independently and continue after failures by
default. Set `iv_stop_on_failure = abap_true` to stop after the first failed
reversal; later rows are marked `is_skipped` and counted separately. Set
`iv_atomic = abap_true` to stage all reversals in one LUW and commit once. A
reversal or commit failure rolls the staged group back, and unattempted rows
are reported as skipped.
Goods movement posting and document dates must be valid Gregorian calendar
dates; an omitted cancellation posting date keeps SAP's default. Malformed
dates are rejected before a goods movement BAPI call, while SAP still decides
whether a valid date falls in an open posting period.
Receipt cancellations commit independently by default. Set `iv_atomic =
abap_true` on `CANCEL_RECEIVED_STO_PAIRS` to require every pair to be received,
stage all 102 reversals together, and restore in-transit status only after the
shared commit succeeds. A reversal or commit failure rolls the group back.
`CANCEL_STO_RECEIPT_CHAIN` and `CANCEL_STO_RECEIPT_CHAIN_PAIRS` reverse both
goods movements for received pairs. They validate every eligible 101 and 351
document key before writing, then reverse the receipt first and the issue only
after that reversal succeeds. By default, failures do not stop later pairs. Set
`iv_stop_on_failure = abap_true` to stop after an ineligible pair or failed
101/351 reversal; later rows are marked `is_skipped` and counted separately.
`is_cancelled` reports the receipt reversal,
`is_issue_cancelled` reports the 351 reversal, and `is_fully_cancelled` is true
when both movements are reversed. A failed 101 stays received; a failed 351
leaves the reversed receipt in transit. This reverses the movements but does
not delete or close the STO purchase order.
By default, each cancellation commits independently. Set `iv_atomic =
abap_true` on either chain method to require every pair to be received, stage
each pair's 101 and 351 reversals, and commit the full group once. A failed
cancellation or commit rolls the group back and preserves each pair's received
state.
`RETRY_STO_CHAIN_ISSUE` and `RETRY_STO_CHAIN_ISSUE_PAIRS` accept the prior
chain result and retry the original 351 cancellation where the 101 reversal
succeeded but left the pair in transit. Completed rows are retained; rows whose
101 reversal failed remain received and keep the aggregate result incomplete.
Set `iv_stop_on_failure = abap_true` to stop after the first ineligible pair or
failed 351 reversal; later unfinished rows are marked `is_skipped` and counted
separately. Completed rows remain successful. The optional atomic mode shares
one commit across pending 351 reversals. It does not undo 101 reversals
committed by the earlier chain attempt.
`RETRY_STO_CHAIN_RECEIPT` and `RETRY_STO_CHAIN_RECEIPT_PAIRS` retry the 101
reversal from prior chain output when the pair remains received, including
after an atomic chain rollback.
Completed pairs and pairs already waiting for a 351 retry are preserved. A
successful receipt retry restores in-transit status; the aggregate chain result
stays incomplete until the 351 reversal is also successful. Atomic mode shares
one commit across the pending 101 reversals. Set `iv_stop_on_failure =
abap_true` to stop after the first failed 101 retry; later unfinished receipt
retries are marked `is_skipped` and counted separately.
`RETRY_STO_CHAIN` and `RETRY_STO_CHAIN_PAIRS` resume either pending stage from
the prior chain result: received pairs retry the 101 and then the 351, while
in-transit pairs retry only the 351. Completed pairs are retained. Atomic mode
stages every pending movement across both stages for one shared commit; a
failure restores each pair's state from before this retry. Any reversal already
committed by an earlier call remains committed. Set `iv_stop_on_failure =
abap_true` to stop after the first failed retry in the receipt-first execution
order; later unfinished pairs are marked `is_skipped` and counted separately.
`MARK_STO_FOR_DELETION` can separately set the deletion indicator on submitted
items from one successfully committed STO result, and
`MARK_STO_PAIRS_FOR_DELETION` can process a multi-pair result. Both reject
input orders from test-run or uncommitted creations, prevalidate eligible item
identities before the first change, commit each PO independently, and continue
after an individual failure by default. Set `iv_atomic = abap_true` on
`MARK_STO_PAIRS_FOR_DELETION` to require every input order to be eligible,
defer the commit across all pair changes, and roll back the group if a change
or commit fails. This is a logical item deletion indicator through
`BAPI_PO_CHANGE`, not a physical purchase-order deletion. SAP still checks
whether each item can
be marked for deletion based on its document history and system rules
([SAP BAPI_PO_CHANGE example](https://help.sap.com/docs/SUPPORT_CONTENT/home/3361892108.html?locale=ru-RU)).
Both methods accept `iv_test_run = abap_true` to simulate eligible committed
orders. Simulation results set `is_test_run` and `is_successful` while keeping
`is_deleted` false. The pair result's top-level `is_deleted` is true when at
least one deletion committed, including partial non-atomic runs. Atomic success
sets it after the shared commit; simulations and failed atomic groups leave it
false. The atomic option simulates every PO independently and skips commit and
rollback; it does not check whether a shared live commit would succeed.
`MARK_STO_PAIRS_FOR_DELETION` also accepts `iv_stop_on_failure`, defaulting
to `abap_false`. When enabled, the first ineligible order or failed item
change stops later changes. Later rows are returned with `is_skipped`; the
summary reports successful, failed, and skipped counts and keeps
`stopped_on_failure` true even when the failure is last. Non-atomic changes
committed before the failure remain committed. Atomic preflight failures skip
otherwise eligible rows without writing; a failed staged change rolls back the
group and marks unattempted rows skipped.
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
The pair method commits each order independently by default. Its top-level
`is_completed` is true when at least one order was marked and committed,
including partial non-atomic runs. Set `iv_atomic = abap_true` to require every
order to be eligible and defer the commit until all pair changes succeed; a
change or shared-commit failure rolls back the group and leaves the aggregate
false. The single and pair methods also accept `iv_test_run` to simulate each
change without commit or rollback. They report simulation success without
setting `is_completed`; atomic simulation validates each PO separately and does
not validate a shared commit.
`MARK_STO_PAIRS_DELIV_COMPLETE` also accepts `iv_stop_on_failure`, defaulting
to `abap_false`. When enabled, the first ineligible order or failed item
change stops later changes. Later rows are returned with `is_skipped`; the
summary reports successful, failed, and skipped counts and keeps
`stopped_on_failure` true even when the failure is last. Non-atomic changes
committed before the failure remain committed. Atomic preflight failures skip
otherwise eligible rows without writing; a failed staged change rolls back the
group and marks unattempted rows skipped.
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
plant's storage locations. Blank-location scalar and bulk totals accumulate in
high precision and raise `ZCX_INVALID_STOCK_REQUEST` if the result exceeds the
`MARD-UMLME` field range. These quantities stay separate from allocatable
unrestricted stock ([SAP stock in transfer fields](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362168094.html)).
`GET_STOCK_IN_TRANSFER_BULK` accepts uniquely keyed material/plant requests
with an optional storage location. It reads the requested plant and location
balances in bulk, returns results in request order, and preserves each request's
location aggregation. Blank required keys or duplicate request IDs are rejected
before repository access; an empty request returns without a read.
`GET_STOCK_IN_TRANSFER_BULK_UOM` adds a material-specific unit to each
request, caches repeated material/unit ratios, and returns both the base
quantities and converted quantities with the unit codes. It validates every
request and conversion ratio before the transfer-stock bulk read.
`GET_STOCK_IN_TRANSFER_IN_UNIT` returns both transfer quantities in a requested
material-specific unit and includes the requested and base units. It uses the
material's `MARA`/`MARM` conversion ratio and rejects an unknown unit before
reading transfer balances. Conversion overflow and nonzero base quantities that
round to zero at MARD-LABST precision also raise `ZCX_INVALID_STOCK_REQUEST`.
`GET_STOCK_IN_TRANSFER_BY_BATCH` reports nonzero storage-location transfer
quantities by batch and storage location from `MCHB-CUMLM`.
`GET_TRANSFER_LOCATIONS` enumerates nonzero `MARD-UMLME` quantities by storage
location without a batch breakdown. `GET_TRANSFER_LOCATIONS_BULK` returns the
same sorted location rows under uniquely keyed material/plant requests, with an
empty nested list when no transfer quantity is reported.
`GET_TRANSFER_LOCATIONS_IN_UNIT` and `GET_TRANSFER_LOCATION_BULK_UOM` add the
requested unit and retain each canonical base quantity. Bulk conversion caches
repeated material/unit ratios and validates all request keys and ratios before
the repository read.
`GET_TRANSFER_BATCHES_BULK` accepts uniquely keyed material/plant
requests and returns each request's batch rows in storage-location and batch
order. It performs one bulk MCHB read; invalid keys and duplicate request IDs
are rejected before the read, and requests without transfer rows return an
empty nested list.
`GET_TRANSFER_BATCHES_BULK_UOM` adds a requested material unit per request,
caches each material/unit ratio, and returns both base and converted batch
quantities while preserving request and batch order. It validates all request
IDs and unit ratios before the bulk transfer read.
`GET_BATCH_TRANSFER_IN_UNIT` adds the requested-unit quantity while
retaining the canonical base-unit balance. These batch rows describe transfers
between storage locations; plant-to-plant transfer stock remains available only
as an aggregate plant quantity.

`ZCL_SALES_ORDER_SERVICE` reads sales order item details through
`BAPISDORDER_GETDETAILEDLIST` and creates orders through
`BAPI_SALESORDER_CREATEFROMDAT2`. It can also change specified items and
schedule lines through `BAPI_SALESORDER_CHANGE`. Create and change operations
support test runs and use the BAPI transaction commit or rollback APIs. Live
creates require a returned sales document before reporting success; successful
test runs may omit that simulated number. Both services depend on interfaces
so their behavior can be tested without posting
to SAP. Order reads retain requested and delivered quantities in the sales
unit, calculate the undelivered open quantity, and provide requested and open
quantities in the material base unit using the sales item's conversion ratio.
The read also maps order type, sales area, sold-to party, customer PO number,
and document date from the BAPI header output.
An alternative-unit item with no valid ratio or material base unit makes the
read unsuccessful. Rejected items are returned in `order-rejected_items` with
their material, plant, sales quantity/unit, sales-unit ratio, converted base
quantity/unit, and rejection reason; they remain separate from the active
`order-items` collection used by allocation. A failed rejected-item conversion
also marks the read unsuccessful. An order containing only rejected items is
a successful read with a warning. Schedule-
line reads also retain `VBEP-BMENG` confirmed
quantities and the undelivered confirmed amount in both sales and base units.
Before single- or multi-order allocation, selected requested or material-
availability dates must be valid Gregorian calendar dates. Invalid dates from
the SAP order read return an error before stock allocation, ATP checks, or
reservation creation.
Pass `iv_use_confirmed_qty = abap_true` to `preview_order`, `reserve_order`, or
`preview_orders_by_date` to size demand from each schedule line's confirmed
quantity minus deliveries, capped at its ordered open quantity. The default
continues to use ordered open quantity. Confirmed-quantity mode requires
schedule-line confirmation data and returns an error before stock reads for an
open item without it.
`read_orders` accepts multiple distinct sales document numbers, validates all
keys before any BAPI call, and returns one result per request in caller order.
The adapter sends the complete document list in one
`BAPISDORDER_GETDETAILEDLIST` call and reads `VBAP`, `VBUP`, and `VBEP` for the
requested documents with one grouped query per table. Header output is
requested through the BAPI's header view and mapped into the order result.
SQLite-backed Open SQL tests cover the delivery repository's schedule ordering,
status mapping, multi-document selection, and VBAP quantity fallback when no
schedule lines exist.
`change_orders_atomic` accepts item changes for multiple distinct orders,
validates the full request before any BAPI call, and commits once after all
changes succeed. Any failed change or commit triggers a rollback. Test runs
return per-order results without committing; the response reports whether the
group succeeded and whether SAP committed it.
`create_orders_atomic` applies the same transaction boundary to a list of new
orders. It requires a returned document number for every non-test create and
rolls back the group when a create or commit fails.
`create_orders_bulk` and `change_orders_bulk` validate the complete input before
the first BAPI call, then commit or roll back each order independently and keep
processing after failures. Results stay in input order and expose each row's
`is_successful`, `is_test_run`, and `is_committed` state. Test runs simulate every
row without commits. The top-level `is_committed` is true when at least one
order commits and remains false for simulations or when no order commits.
Atomic write rows report the group outcome; document numbers from rolled-back
atomic creates are cleared.
`reject_order_items` sets configured rejection reasons for selected sales-order
items through `BAPI_SALESORDER_CHANGE`; `reject_orders_bulk` commits each order
independently, while `reject_orders_atomic` shares one commit and rolls back the
group after a failed change. All three validate item numbers and nonblank reason
codes before writing, preserve SAP messages, and support test runs. Rejection
codes must exist in the target system's sales-document customizing. The bulk
result's top-level `is_committed` reports whether any rejection update committed.
`clear_order_item_rejections` restores selected items by sending a blank reason
with the rejection field's update flag. `clear_order_rejections_bulk` commits
each order independently; `clear_order_rejections_atomic` commits once for the
group and rolls back after any failed update. Both modes validate distinct item
numbers and distinct sales documents before writing, preserve SAP messages, and
support test runs. The shared bulk result's top-level `is_committed` reports
whether any order committed.
`delete_order_items` requests deletion of selected sales-order items through
`BAPI_SALESORDER_CHANGE` using the item update flag. The bulk form commits each
sales document independently after validating the full request; the atomic
form stages all documents under one commit and rolls back the group on failure.
Both aggregate results report partial commits and support BAPI simulation. The
target SAP release's item-deletion behavior remains to be confirmed.

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
precision. Conversion overflow and nonzero quantities that round to zero at this
precision raise `ZCX_INVALID_STOCK_REQUEST`. Schedule
lines are prioritized by requested date within each sales order item. The
reservation BAPI runs its ATP check and commits the reservations in one
transaction; an error rolls the transaction back. Partial allocations are
reserved and the shortfall remains in the result. Test runs call the reservation
BAPI in simulation mode and do not commit. Reserve results echo `is_test_run`
and set `is_committed` only after a successful commit; successful no-op and
simulation results leave `is_committed` false. Callers may require full allocation;
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
code order. Pass `it_location_priority` to `preview_order` or `reserve_order`
to order fallback locations across the order; any per-line preferred location
still comes first. Separate batch and location selection lists cannot be combined.
Callers can select a batch for each open schedule line, or provide one
item-wide choice to apply to all its open schedule lines. A batch selection
can include a preferred `storage_location`; set `allow_fallback = abap_true`
to use other locations for that same batch if the preferred location is short.
Pass `it_location_priority` to order those fallback locations within the batch.
Preview and reservation use only the selected batch and pass it through to the
reservation BAPI. In FEFO mode, location priority breaks same-batch,
same-expiration ties without changing expiration order. Item-wide and
schedule-line choices cannot be mixed on one item.
In FEFO mode, `it_fefo_minimums` can set `minimum_shelf_life_days` for an item
or a specific schedule line. A schedule-line entry overrides an item-wide
entry; the greater of that value and `iv_fefo_min_days` applies. Batch splits
report the effective minimum. Positive per-demand values require
`iv_use_fefo_batches = abap_true`, and duplicate or unknown item keys are
rejected before stock allocation.
Set `iv_use_required_date_for_fefo = abap_true` to evaluate each dated demand
as of the later of its requested date and `iv_fefo_as_of_date`. The effective
date appears on each batch split; undated item-level demand keeps the shared
as-of date. The option requires FEFO and defaults to false. This keeps a batch
that expires before a future schedule line out of that line's allocation.

`reserve_so_stock_fefo` consumes `ZCL_SO_STOCK_SERVICE` FEFO splits for sales
order stock and creates one movement-231 reservation request per batch/location
split, preserving its sales-order item, batch, location, and base-unit quantity.
Full allocation is required by default; set `iv_require_full_allocation =
abap_false` to reserve covered splits only. `iv_required_date` can set the
reservation requirement date; when omitted, the reservation adapter uses the
current date. The method supports BAPI simulation and commits all created
reservations together, rolling back on API or commit failure. It rejects mixed
reservation cutoffs for one item because those preview groups use independent
stock pools. For a preview containing separate cutoff scenarios, use
`reserve_so_stock_fefo_selected` with the desired request IDs; it filters each
selected summary and its matching batch splits before running the same checks.
Empty, duplicate, and unknown request IDs are rejected. SAP's reservation ATP
check runs at creation, and the reservation service checks each split against
the location filters carried by the preview. The preview itself does not lock
stock.

`reserve_so_fefo_rechecked` accepts both the original and a caller-regenerated
FEFO preview. Pass `it_request_ids` to recheck and reserve selected scenarios
from a multi-cutoff result. It compares the selected summaries, full stock and
reservation snapshots, location filters, and batch/location splits, then
reserves from the fresh preview only when every row matches. The caller
performs the fresh read; stock can still change after that comparison and
before SAP creates the reservations.

`reserve_so_fefo_demands` and `reserve_so_fefo_demands_uom` take FEFO demand
requests, build the sales-order stock preview, and pass its batch/location
splits directly into reservation creation. The UOM method converts demand to
the material base unit and creates reservations in that unit. Both methods
accept the FEFO as-of date, minimum shelf life, shared undated-batch policy,
reservation required date, simulation flag, and full-allocation policy. Each
demand can set `allow_undated_batches = abap_true` to include undated stock even
when the shared option is false, or `require_known_expiry = abap_true` to exclude
it even when the shared option is true. The two row flags cannot both be true.
The preview echoes each row policy in its summary and batch splits, and the
reservation, goods-issue, and recheck paths validate it. Pass `it_request_ids`
to reserve a selected cutoff scenario from a multi-cutoff demand set; mixed
cutoffs for one item must be reserved separately. Each demand may also pin an
exact `storage_location`, which is carried through the preview and reservation
split validation. The allocation factory wires the sales-order stock service
into `CREATE_SALES_ORDER_ALLOC`.

For a previously shown preview, use `reserve_so_fefo_recheck` or
`reserve_so_fefo_uom_recheck` with the original preview and its demand requests.
The service reads a fresh preview using the supplied FEFO options, compares the
selected stock and splits, and creates reservations only when the result still
matches. Optional `it_request_ids` supports a selected scenario from a
multi-cutoff preview. A mismatch raises `zcx_invalid_stock_request` before the
reservation API is called.

`release_so_fefo_reservations` accepts a successfully committed, non-simulation
FEFO reservation result and releases the reservation numbers returned by SAP.
It checks that every number is unique and that the result rows still match the
preview splits. `iv_test_run = abap_true` simulates the release; a live result is
marked committed only after the reservation service's delete transaction
commits.
Pass `it_request_ids` to release only the reservation splits for selected FEFO
requests. An omitted or empty selection releases all rows; duplicate or unknown
request IDs are rejected before the reservation API is called. To release
individual batch/location splits, pass their SAP reservation numbers using
`it_reservation_numbers`; the two selectors cannot be combined.

`ZCL_RESERVATION_ISSUE_SERVICE=>PREVIEW_SO_ISSUE_REMAINING` reads selected
reservation numbers for one sales-order item and returns each issueable item's
remaining base-unit quantity, reservation item, location, and batch. It does
not post goods movements; both the material base unit and its ISO code must be
available. `POST_SO_ISSUE_REMAINING` issues those open quantities
and rejects reservations outside the requested sales-order item; fully
withdrawn items are skipped. The posting path rereads and validates each
reservation before posting, and commits each reservation independently. Use the
explicit quantity issue methods when only part of an item's remaining quantity
should be issued. `POST_SO_ISSUE_REMAINING_ATOMIC` provides the same selection
and quantity derivation but stages every reservation movement before one shared
commit or rollback. Set `iv_stop_on_failure = abap_true` on the bulk issue
methods to stop after the first failed reservation group; later groups remain
in the result as skipped, with separate successful, failed, and skipped
counts. The flag is checked before reservation reads or unit conversion, and
earlier independent commits remain committed.

For exact item selection, `PREVIEW_SO_ISSUE_REM_ITEMS` accepts unique
reservation/item keys and returns only those items' positive open quantities.
Missing, fully withdrawn, final-issued, or otherwise ineligible keys are
rejected. `POST_SO_ISSUE_REM_ITEMS_BULK` commits each reservation independently;
`POST_SO_ISSUE_REM_ITEMS_ATOMIC` stages all selected reservations before one
shared commit or rollback. The bulk method also accepts
`iv_stop_on_failure = abap_true` to retain and skip later reservation groups
after a failed post.

`PREVIEW_SO_REV_REMAINING` reads selected reservation numbers for one
sales-order item and returns each item's positive withdrawn base-unit quantity,
unit, location, and batch. `POST_SO_REV_REMAINING_BULK` reverses those balances
with one independently committed material document per reservation;
`POST_SO_REV_REMAINING_ATOMIC` stages the selected reversals together and uses
one shared commit or rollback. Both posting methods repeat the sales-order
scope and withdrawn-quantity checks before movement creation. Items with no
withdrawn balance are omitted from the preview; negative or over-withdrawn
reservation balances are rejected. Set `iv_stop_on_failure = abap_true` on
the bulk reversal methods to stop after the first failed reservation group;
later groups remain in the result as skipped with separate outcome counts.
Earlier independent commits remain committed.

For exact item selection, `PREVIEW_SO_REV_REMAINING_ITEMS` accepts unique
reservation/item keys and returns only those items' withdrawn balances. It
rejects missing keys and keys with no withdrawn balance. Use
`POST_SO_REV_REM_ITEMS_BULK` for independent per-reservation commits or
`POST_SO_REV_REM_ITEMS_ATOMIC` for one shared commit or rollback. The bulk
method accepts `iv_stop_on_failure = abap_true` to skip later reservation
groups after a failed reversal.

For `reserve_order`, `reserve_orders_by_date`, and
`reserve_orders_by_date_bulk`, set `iv_require_atp_confirmation = abap_true`
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
sales and base units. Single- and multi-order results include
`order_summaries`, grouped by sales document, material, plant, and base unit,
with checked requested, allocated, and shortfall base quantities and the number
of demand lines. Available totals are omitted because each line reports the
remaining shared-stock balance at its allocation step. Pass
`iv_use_confirmed_qty = abap_true` to size each
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
`it_demand_priorities` to the multi-order preview or reservation methods. Each entry keys a caller
priority by sales document, item, and schedule line; use a blank schedule line
for an item-level demand. Higher integer values receive stock first among
demands for the same material, plant, and date. Earlier dates still take
precedence; omitted priorities default to zero, and equal priorities preserve
input order. Results echo each applied priority in `sales_unit_allocations` and
`atp_checks`. Duplicate keys, entries for unselected orders, and keys that do
not match an order item/schedule line are rejected before allocation.
Both `reserve_orders_by_date` and `reserve_orders_by_date_bulk` carry the same
ordering into the quantities sent for reservation. This caller priority only
controls the local allocation sequence; it is not written to the sales order,
and same-date ATP diagnostics remain cumulative across all orders.

Pass `it_allocation_requirements` to the single- or multi-order preview
and reservation methods to make selected item demands all-or-nothing. Each row
contains `sales_document`, `item_number`, optional `schedule_line`, and
`require_full_quantity`. A blank schedule line applies to every line on that
item; an exact schedule-line row overrides the item-wide setting. The default
is `abap_false`. When a strict demand cannot be fully covered, it receives zero
allocation and leaves stock available to later demands. The result echoes the
effective flag on each `sales_unit_allocations` row. The reservation-wide
`iv_require_full_allocation = abap_true` gate remains available when any
shortfall should reject the complete reservation request.

Each allocation-requirement row can also set `require_atp_confirmation`, which
defaults to `abap_false`. A true value requires `iv_check_atp = abap_true`; the
result echoes the effective flag on its allocation row. Reservation methods
check the matching ATP row's cumulative confirmed quantity before calling the
reservation API. The comparison includes earlier demand accumulated for the
same material, plant, base unit, and required date. An exact schedule-line row
overrides the item-wide row for both requirement flags. The global
`iv_require_atp_confirmation = abap_true` option continues to require full
confirmation for every row before reservation calls begin. In
`reserve_orders_by_date_bulk`, row-level ATP or write failures mark that order
unsuccessful and later orders continue by default. Set
`iv_stop_on_failure = abap_true` to skip later orders after the first failure;
their result rows stay in input order with separate skipped counts.

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
The result echoes `is_test_run`; `is_committed` is true only after the shared
reservation transaction commits. A successful no-op or test run is not marked
committed.

`reserve_orders_by_date_bulk` uses the same shared preview and pre-write
allocation/ATP gates, then creates and commits each sales order separately in
input order. A failed create, response check, row-level ATP gate, or commit
rolls back that order and processing continues by default. Set
`iv_stop_on_failure = abap_true` to mark later unattempted orders as skipped;
`skipped_count` is separate from `failed_count`, and
`stopped_on_failure` remains true when the failed order is last. Earlier
committed orders remain committed. `order_results` reports each order's
messages, reservations, `is_successful`, `is_test_run`, `is_committed`, and
`is_skipped`. The top-level result is unsuccessful if any order fails, while
its reservations contain only successful commits (or successful simulations).
The top-level `is_committed` is true when any order committed and remains false
for simulations, no-op orders, or batches with no successful commit. An order
with no allocated quantity is a successful no-op. Test runs simulate each
nonempty order and never commit. Use
`reserve_orders_by_date` when all orders must share one commit or rollback
boundary.

Sales-order allocation methods reject invalid `abap_bool` values for allocation,
date, ATP, safety-stock, and dated-receipt options before reading orders or
stock. Use `abap_true` or `abap_false`; an unrecognized value is an input error
and is not treated as false.

Batch and location selections are also checked before reading the order or its
active reservations. Rows need their item and selection key, duplicate
item/schedule-line keys are rejected, and item-wide rows cannot be mixed with
schedule-line rows for the same item. Batch fallback also requires a preferred
storage location.

Call `preview_order` or `reserve_order` with `iv_use_fefo_batches = abap_true`
to choose batches automatically by earliest expiration date. The as-of date
defaults to the current date and can be set with `iv_fefo_as_of_date`. FEFO can
be combined with location selections: by default the selected location is a
hard restriction; with `allow_fallback`, it is used first and other locations
are searched afterward in expiration-date order. `it_batch_selections` can
restrict selected items or schedule lines to an exact batch while unselected
demands continue normal FEFO. Batch and location selection tables cannot be
combined. The service does not run SAP's configured batch
search strategy ([reservation requirements](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/0ca1613d5bcb4fcda6e66a8c57fa8624.html?locale=en-US&state=PRODUCTION&version=2023.latest)).
When FEFO is enabled, the service validates `iv_fefo_as_of_date` as a Gregorian
date before reading the order.

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
`DELETE_RESERVATIONS`, `DELETE_ORDER_RESERVATIONS`,
`DELETE_ORDERS_RESERVATIONS`, and `DELETE_ITEMS_RESERVATIONS` reject any
`iv_test_run` value other than `abap_true` or `abap_false` before BAPI or finder
calls. Its sales-order method discovers open movement-231 reservations from
`RESB`.
It only releases a document when every non-deleted item belongs to the
requested sales order and uses the same movement and stock scope. An order can
preview eligible reservation numbers without a BAPI call, optionally scoped to one
sales-order item. Item-scoped release requires every non-deleted document item
to match that item. An order with no matching documents returns success without
starting a BAPI transaction. SQLite-backed repository tests execute both
reservation-finder queries and cover order-only versus exact-item ownership,
mixed-owner documents, and closed or filtered reservation rows; target SAP still
determines whether an eligible document can be deleted after its use or status
changes.
`DELETE_ORDERS_RESERVATIONS` accepts a unique list of sales documents, returns
eligible reservation numbers grouped by order, and deletes the combined list in
one BAPI transaction. Empty matches are a successful no-op; blank or duplicate
sales document numbers are rejected before the finder runs. A reservation number
mapped to multiple orders is rejected before deletion. The write result reports
`is_committed` only after SAP accepts the shared commit; test runs and previews
leave it false.
`DELETE_ORDERS_RELEASE_BULK` uses the same single bulk lookup, then deletes and
commits each sales order independently. It continues after a failed delete or
commit by default. Set `iv_stop_on_failure = abap_true` to skip later orders;
result rows remain in request order with separate successful, failed, and
skipped counts. It returns only reservation numbers successfully deleted (or
simulated). Earlier orders remain released after a later failure; use
`DELETE_ORDERS_RESERVATIONS` when the entire set must share one rollback
boundary. Test runs simulate each nonempty order without committing, and orders
with no candidates succeed as no-ops. The top-level `is_committed` is true if
any sales order committed and stays false when the batch only simulated or had
no successful commits.
`PREVIEW_ORDERS_RELEASE` returns the same grouped candidates without calling the
delete BAPI.
`PREVIEW_ORDER_ITEMS_RELEASE` and `DELETE_ITEMS_RESERVATIONS` accept unique,
nonblank sales-order/item pairs. They return candidates grouped by item; release
deletes the combined list in one transaction. A document is eligible only when
all non-deleted rows match that exact order item. The delete result carries
`is_committed` from the shared transaction; preview results and test runs leave
it false.

`ZCL_SO_RESERVATION_READ_SERVICE` reads reservation items through
`BAPI_RESERVATION_GETDETAIL1`, including their SAP item number, record type,
status flags, requirement and withdrawal quantities, material, plant,
storage location, batch, and units. Failed reads do not return partial item
data; mismatched or duplicate item identities fail the document read.
`READ_RESERVATIONS` validates a list of nonblank, unique reservation
numbers before reading any document, then returns one result per number in
caller order. An empty list returns no results without an API call.

`ZCL_RESERVATION_ISSUE_SERVICE` posts a goods issue against selected
reservation items. It validates the complete request before reading the distinct
reservation documents in caller order, then rejects duplicate or unissueable
items and quantities above the remaining requirement. It sends the reservation
number, item, record type, quantity, and unit through
`BAPI_GOODSMVT_CREATE` with goods movement code 03. SAP derives the movement
type and material from the reservation. An unplanned storage location or
batch can be supplied by the caller. All issue items post as one material
document and share the goods movement service's simulation and transaction
handling.
`POST_GOODS_ISSUE_BULK` groups requests by reservation number in first-seen
order and creates one independent material document per reservation. A read,
validation, creation, or commit failure is reported for that reservation while
later groups continue. Multiple selected items from one reservation stay in a
single document. `POST_GOODS_ISSUE_REVERSAL_BULK` applies the same grouping to
withdrawal reversals. Both methods support test runs and report each group's
success and commit status. Their top-level `is_committed` is true if any
reservation group committed and false for simulations or when no group committed.
Empty input succeeds without a reservation read or goods movement call.
All four bulk forms accept `iv_stop_on_failure`, defaulting to
`abap_false`. When enabled, the first failed reservation group stops later
groups; their result rows are marked skipped and counted separately. The
option is validated before unit conversion, and earlier independent commits
remain committed.
`POST_GOODS_ISSUE_IN_UNIT` and `POST_GOODS_ISSUE_REV_IN_UNIT` accept a quantity
and unit per selected item. `POST_GOODS_ISSUE_BULK_UNIT` and
`POST_GOODS_ISSUE_REV_BULK_UNIT` preserve per-reservation documents while
accepting the same unit-aware lines. The service converts each line using the
material's unit ratio, checks the converted base quantity
against the item's open or withdrawn quantity, and passes the reservation's
base unit and ISO code to SAP. An unknown conversion or a base-unit mismatch
stops that reservation group's movement.
`POST_SALES_ORDER_ISSUE` and `POST_SALES_ORDER_ISSUE_UOM` additionally require
each reservation header to use movement type 231 and match the supplied sales
order and item. A mismatched reservation stops before the goods-movement BAPI.
`POST_SALES_ORDER_REVERSAL` and `POST_SALES_ORDER_REVERSAL_UOM` apply the same
scope check to a goods issue reversal and limit the requested return to the
quantity already withdrawn from the reservation.
`POST_SO_ISSUE_BULK` and `POST_SO_ISSUE_BULK_UOM`, plus
`POST_SO_REVERSAL_BULK` and `POST_SO_REVERSAL_BULK_UOM`, apply that order/item
scope check independently to each reservation document. Each valid reservation
gets its own goods-movement posting; a scope failure is returned on that
reservation's result while processing continues for later reservations by
default. Set `iv_stop_on_failure = abap_true` to retain later groups as skipped
after the first failed post. Result summaries report successful, failed, and
skipped groups separately, and earlier independent commits remain committed.
`POST_CC_GOODS_ISSUE` and `POST_CC_GOODS_ISSUE_IN_UNIT` also require every
selected reservation item to be an open item for the supplied cost center.
Their `_BULK` forms make one independently committed goods issue per
reservation, with the `_BULK_UNIT` form accepting alternative units. The
cost-center check reads the current open-reservation snapshot before reading
reservation detail or posting; malformed `iv_test_run` values are rejected
before that read. These bulk forms accept `iv_stop_on_failure`, defaulting to
`abap_false`; when enabled, later reservation groups are skipped after the
first failed post and separately counted. Concurrent changes after the scope
check are still subject to SAP's reservation and goods-movement validation.
`POST_CC_ISSUE_REV` and its `_BULK`, `_UNIT`, and `_BULK_UNIT` variants scope
withdrawal reversals to the reservation header's cost center. They look up the
requested reservation keys directly, so fully issued items remain eligible
even though they no longer appear in the open-reservation list. The common
movement pipeline still limits each reversal to the quantity already withdrawn.
`POST_CC_ISSUE_REV_ATOMIC` accepts unit-aware requests, validates every
reservation/item against the supplied cost center, and stages all reversals
before one shared commit or rollback, rechecking each reservation scope before
its movement is staged. `PREVIEW_CC_REV_REMAINING` reads selected 201
reservation items and reports their withdrawn base quantities and units.
`POST_CC_REV_REMAINING_ATOMIC` reverses those selected balances together, after
the previewed scope is checked again during atomic staging.
`POST_CC_REV_REMAINING_BULK` uses the same selection and preview, then commits
each reservation reversal separately and reports per-reservation failures. Its
`iv_stop_on_failure` option, also available on `POST_CC_ISSUE_REV_BULK` and
`POST_CC_ISSUE_REV_BULK_UNIT`, stops later reservation groups after the first
failed reversal. Skipped groups remain in the result and are counted
separately; earlier committed reversals remain committed.

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
support test runs. Bulk issue and return entry points reject malformed
`iv_test_run` values before reading component reservations. These base-unit methods take quantities in the component
reservation unit. `ISSUE_COMPONENTS_IN_UNIT` and
`ISSUE_COMPONENTS_BULK_IN_UNIT` also accept a quantity and material unit per
line; they convert every line to the reservation component unit and reject an
unknown or mismatched conversion before posting. The bulk unit-aware method
still posts all selected components in one material document. SAP generates
component reservations when production orders are created; movement type 261 is the
standard goods issue for order components
([withdrawing material components](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/c803b753128eb44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest)).
All component issue methods require movement type 261. `PREVIEW_REMAINING_COMPONENTS`
returns current open rows for explicit production-order/reservation/item keys,
and `ISSUE_REMAINING_COMPONENTS` issues those rows' full open quantities
through the existing bulk path after a second component read. It rejects
duplicate keys and does not issue non-261 reservations. `ISSUE_REMAINING_BULK`
groups those selected open quantities by production order and reservation,
commits one material document per reservation, and reports per-reservation
results while continuing after a failed group. It also rereads each order's
components before posting; earlier commits remain if a later group fails. The
top-level `is_committed` reports whether any reservation group committed.
`ISSUE_REMAINING_BULK` accepts `iv_stop_on_failure`, defaulting to
`abap_false`. When enabled, the first failed reservation group stops later
posts; unattempted rows stay in caller order with `is_skipped`, and
`skipped_count` is separate from `failed_count`. `stopped_on_failure` remains
true when the failed group is last.
`ZCL_PROD_ORDER_SERVICE->CREATE_ORDER` creates a production order directly
through `BAPI_PRODORD_CREATE`, without requiring a planned order first. The
request supplies material, production plant, optional planning plant, order
type, positive quantity and SAP unit, and at least one basic start or finish
date; the planning plant defaults to the production plant. The service commits
after a successful create and requests rollback after a create or commit
failure. The BAPI does not expose simulation mode through this interface. A
new order remains created and must be released before execution. SAP describes
manual order creation from material and production plant, and lists the BAPI
for production order creation
([create a production order](https://help.sap.com/docs/SAP_ERP_SPV/bfece09273bd474d82fdd97bae070c25/4901b753128eb44ce10000000a174cb4.html),
[production-order BAPI catalog](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
`CREATE_ORDERS_BULK` validates the complete request before writing, then
creates and commits each order independently while continuing after errors by
default. Set `iv_stop_on_failure = abap_true` to stop after the first failed
create or commit; later request rows remain in caller order and are marked
`is_skipped`, with `skipped_count` reported separately from `failed_count`.
`stopped_on_failure` is set even when the failed request is last. Invalid flag
values fail before the first BAPI call. Earlier independent commits remain
committed, and the top-level `is_committed` reports whether any order committed.
`CREATE_ORDERS_ATOMIC` sends the validated orders in one LUW and commits once;
it rolls the group back after any create or commit failure. Independent-commit
bulk methods expose top-level `is_committed`, true when at least one order or
operation committed and false when none did. This makes partial bulk completion
easy to distinguish while per-row results retain the affected order details.
Duplicate caller-assigned order numbers are rejected before the first BAPI call.
SAP's BAPI
transaction model permits multiple object creations in one LUW, but verify the
target release's production-order BAPI behavior before relying on atomic mode
([BAPI transaction model](https://help.sap.com/SAPHELP_SCM700_EHP02/helpdata/EN/4d/5b102ba1483d8fe10000000a42189e/content.htm)).
`ZCL_PROD_ORDER_SERVICE->RELEASE_ORDERS_ATOMIC` releases a validated set of
production orders through `BAPI_PRODORD_RELEASE` in one BAPI call and commits
once; any overall or per-order error rolls back the set.
`RELEASE_ORDERS_BULK` releases and commits one order at a time, continues after
failures by default, and reports per-order commit status and counts. Set
`iv_stop_on_failure = abap_true` to stop after the first failed release result
or commit; later rows remain in request order with `is_skipped`, and the
summary reports `skipped_count` and `stopped_on_failure`. Earlier successful
releases remain committed. Both methods require
the caller to supply the target system's release-control value for
`CO_RELEASE_CTRL_ORDER` and reject blank or duplicate order numbers before
calling SAP. Detailed BAPI messages are mapped back to their production-order
numbers. There is no simulation mode. SAP documents order and first-operation
release control options and the production-order release BAPI
([release processing](https://help.sap.com/docs/PRODUCT_ID/2bba750d1e124e1ea2a039bb1cd9b6c5/3905b753128eb44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=2602.500),
[BAPI release](https://help.sap.com/doc/ddd743d1660847cc98ed15b46ddf5307/6.0/en-US/Release_Notes_SAP_AFS_60E.PDF)).
`RELEASE_OPERATIONS_ATOMIC` and `RELEASE_OPERATIONS_BULK` release selected
production-order operations through `BAPI_PRODORD_RELEASE_OPERATION`. Each
request key contains an order number and a four-character SAP internal
operation number; callers must preserve leading zeros. Duplicate keys and
incomplete operation numbers are rejected before any BAPI call. Atomic mode
submits the full set and shares one commit, rolling the group back on any
operation error. Bulk mode calls SAP and commits each operation separately,
continuing after failures by default. Set `iv_stop_on_failure = abap_true` to
stop after the first failed API result or commit; skipped operation rows are
returned in caller order and counted separately. Earlier operation releases
remain committed, and `stopped_on_failure` is set even if the failure is last.
SAP marks a partially released order PREL and
requires preceding operations to be released first; the service returns SAP's
per-operation messages and leaves sequence eligibility to SAP
([operation release rules](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/34de0103497c4b80a7c7fbf6952ff971/73653beedd5241ed9ec3b4cee5229faa.html),
[operation release API](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/0a4262096d2e43258df27c594bdd1468.html)).
`CANCEL_CONFIRMATIONS_ATOMIC` and `CANCEL_CONFIRMATIONS_BULK` reverse
production confirmations through `BAPI_PRODORDCONF_CANCEL`. Requests include
the confirmation number, counter, and mandatory posting date. Duplicate
confirmation/counter pairs or missing values are rejected before SAP calls.
Atomic cancellation shares one commit and rolls back the group on any BAPI or
commit error; bulk mode commits each cancellation separately and continues
after failures by default. The response preserves each SAP message and commit result
([SAP cancellation mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-cancellation-for-production-time),
[SAP BAPI catalog](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
`READ_CONFIRMATIONS_BULK` retrieves operation confirmations for requested
production orders from `AFRU` and resolves operations and sequences through
`AFVC`. Each row includes the internal AFVC operation counter, operation and
suboperation numbers, routing sequence, operation description, control key,
resource object ID from `AFVC-ARBID`, work-center code and plant from
`CRHD-ARBPL` and `CRHD-WERKS`, order category, and order type from `AUFK-AUART`.
Pass `iv_work_center` or `iv_work_center_plant` to select an exact work-center
code or plant; a nonblank value filters by default. Set
`iv_filter_work_center` or `iv_filter_work_center_plant` to `abap_true` to
select a blank code or plant, including confirmations whose AFVC resource has
no matching CRHD row. Both flags accept only `abap_true` or `abap_false`; a
nonblank value continues to filter when its flag is false. The repository
applies these selectors before pagination, and the service checks returned
work-center scope. Each page includes `work_center_summaries`, grouped by
plant and code; blank assignments form a group. `confirmation_count` covers
only returned confirmations, excludes the lookahead row and later pages, and
the summary counts sum to `returned_count`. Each work-center group also has
`quantity_summaries`, split by confirmation unit (`AFRU-MEINH`). Per-unit
`confirmation_count` and gross `yield_quantity_total`, `rework_quantity_total`,
and `scrap_quantity_total` remain separate so unlike units are not added
together. `yield_non_reversed_total`, `rework_non_reversed_total`, and
`scrap_non_reversed_total` omit confirmations flagged as reversed; per-unit
counts sum to the work-center count. Work-center groups also report
`first_posting_date` and `last_posting_date` among dated confirmations, final,
partial, and reversed confirmation counts, and their percentages. Final and
partial counts partition the confirmation count; reversal count is independent.
Percentages use the confirmation count as their denominator. Each unit row
also reports its own dated posting span, final, partial, and reversed counts,
and percentages using that unit's confirmation count. Work-center rows, unit
rows, base-unit rows, operation summaries, and order summaries also report
`execution_start_count` and
`execution_finish_count` for confirmations with actual execution dates. They
also report `execution_start_pct` and `execution_finish_pct`, using each
summary's confirmation count as the denominator and returning zero for an
empty group. They identify the earliest start and latest finish as date/time
pairs, comparing date first and time second. A date with time `000000` counts
as midnight.
These metrics cover returned page rows; their dates and times stay initial
when no corresponding execution date is present. `exec_duration_seconds_total`
sums elapsed whole seconds across complete, valid execution intervals, and
`exec_duration_count` counts those intervals. `exec_duration_seconds_avg`
divides the total by that valid-interval count and is zero when the group has
no valid duration. `valid_exec_duration_pct` reports `exec_duration_count` as a
percentage of the group's `confirmation_count`, rounded to two decimal places;
it is zero for an empty group. `exec_duration_seconds_min` and
`exec_duration_seconds_max` report the shortest and longest valid interval in
seconds; both are zero when no valid interval exists.
`exec_duration_seconds_median` reports the middle valid duration after
sorting the group's intervals. Zero-duration rows participate; with an even
count it averages the two middle durations and retains half seconds. Reversed
confirmations remain included, and the value is zero when no valid duration
exists.
`exec_duration_seconds_p90` reports the nearest-rank 90th percentile of
valid durations. It selects the first sorted duration whose rank reaches 90%
of the valid count; zero-duration and reversed rows participate. It is zero
when no valid duration exists.
`exec_duration_p90_median_ratio`, `exec_nonrev_p90_median_ratio`, and
`exec_reversed_p90_median_ratio` divide each group's p90 duration by its
median. These ratios are dimensionless and return zero when the median is zero.
`exec_duration_p90_exceed_count` counts valid durations strictly greater than
the group's nearest-rank p90 threshold; `exec_duration_p90_exceed_pct` divides
that count by valid duration rows. Ties at p90 are excluded. The non-reversed
and reversed groups expose matching count and percentage fields using their own
p90 thresholds and valid row counts.
`exec_p90_tail_secs` sums valid durations strictly above p90;
`exec_p90_tail_pct` reports that sum as a share of all valid elapsed seconds.
The non-reversed and reversed groups expose matching tail seconds and share
fields using their own p90 thresholds and duration totals. Empty and zero-total
groups return zero.
`exec_duration_seconds_p95` reports the nearest-rank 95th percentile
of valid durations using the same sorted values. Zero-duration and reversed
rows participate, and it is zero when no valid duration exists.
`exec_duration_p95_exceed_count` counts valid durations strictly greater than
the group's nearest-rank p95 threshold; `exec_duration_p95_exceed_pct` reports
that count as a percentage of valid duration rows. Rows tied at p95 are not
counted, and both fields are zero when the group has no valid durations.
`exec_duration_p95_median_ratio` divides the group's p95 duration by its
median duration. It has no time unit and is zero when there are no valid
durations or the median is zero.
`exec_p95_tail_secs` sums valid durations strictly above
the p95 threshold; `exec_p95_tail_pct` reports that sum as a
share of all valid elapsed seconds. Both are zero when the valid-duration total
is zero.
`exec_duration_seconds_p99` reports the nearest-rank 99th percentile
of valid durations. Zero-duration and reversed rows participate, and it is
zero when no valid duration exists.
`exec_duration_seconds_p25` and `exec_duration_seconds_p75` report the
nearest-rank 25th and 75th percentile durations. Zero-duration and reversed
rows participate, and both are zero when no valid duration exists.
`exec_duration_seconds_iqr` reports the interquartile range: the nearest-rank
75th-percentile duration minus the nearest-rank 25th-percentile duration.
Zero-duration and reversed rows participate; it is zero when no valid duration
exists.
`exec_duration_iqr_median_ratio`, `exec_nonrev_iqr_median_ratio`, and
`exec_reversed_iqr_median_ratio` divide each group's IQR by its median. These
ratios are dimensionless and return zero when the median is zero.
`exec_duration_seconds_mad` reports the median absolute deviation of
valid durations: the median of each duration's absolute distance from the
group median. Zero-duration and reversed rows participate; it is zero when
no valid duration exists.
`exec_duration_mad_median_ratio`, `exec_nonrev_mad_median_ratio`, and
`exec_reversed_mad_median_ratio` divide each group's median absolute deviation
by its median. These ratios are dimensionless and return zero when the median
is zero.
`exec_pos_duration_count`, `exec_pos_median_secs`, and
`exec_pos_p90_secs` report the count, median, and nearest-rank 90th percentile
of valid durations strictly greater than zero. The non-reversed and reversed
groups expose matching `exec_nonrev_pos_count`, `exec_nonrev_pos_median_secs`,
`exec_nonrev_pos_p90_secs`, `exec_reversed_pos_count`,
`exec_reversed_pos_median_secs`, and `exec_reversed_pos_p90_secs` fields using
their own positive-duration rows. Zero-duration rows are excluded; an empty
positive-duration group returns zero for all three fields.
`exec_pos_duration_pct` divides `exec_pos_duration_count` by the summary's
`confirmation_count`. `exec_nonrev_pos_duration_pct` and
`exec_reversed_pos_duration_pct` use each reversal cohort's positive count and
confirmation count. Zero-duration, invalid, and missing-duration confirmations
remain in their cohort denominators; empty groups return zero.
`exec_pos_valid_pct` divides the positive-duration count by valid duration
count. `exec_nonrev_pos_valid_pct` and `exec_rev_pos_valid_pct` apply the same
measure within non-reversed and reversed valid intervals. These percentages
show the positive-versus-zero mix among valid durations; invalid and missing
rows are excluded, and a cohort without valid durations returns zero.
`exec_zero_valid_pct`, `exec_nonrev_zero_valid_pct`, and
`exec_rev_zero_valid_pct` report the zero-duration share among valid intervals
for the same cohorts. Each positive-valid and zero-valid pair partitions its
valid intervals; independent two-decimal rounding can differ from 100.00 by
0.01. Cohorts without valid intervals return zero.
`exec_zero_valid_count`, `exec_nonrev_zero_valid_count`, and
`exec_rev_zero_valid_count` expose the matching integer counts. Each is
the valid count minus the positive count for that cohort; empty cohorts
return zero.
`exec_nonrev_invalid_count` and `exec_rev_invalid_count` count invalid
duration statuses in their respective reversal cohorts.
`exec_nonrev_missing_count` and `exec_rev_missing_count` count missing
duration statuses. Together with the valid duration counts, the invalid
and missing counts partition each cohort’s confirmations; valid zero
durations remain in the valid count. Empty cohorts return zero.
`exec_nonrev_valid_pct`, `exec_nonrev_invalid_pct`, and
`exec_nonrev_missing_pct` divide each non-reversed status count by the
non-reversed confirmation count. The matching `exec_rev_valid_pct`,
`exec_rev_invalid_pct`, and `exec_rev_missing_pct` use the reversed
confirmation count. Each three-percentage set partitions its cohort;
independent rounding may differ from 100.00 by 0.01. Empty cohorts
return zero.
`exec_pos_p95_secs` and `exec_pos_p99_secs` report the nearest-rank 95th
and 99th percentile of valid positive durations. The non-reversed and reversed
groups expose matching `exec_nonrev_pos_p95_secs`, `exec_nonrev_pos_p99_secs`,
`exec_rev_pos_p95_secs`, and `exec_rev_pos_p99_secs` fields. Zero-duration rows
are excluded; an empty positive-duration group returns zero for both values.
`exec_pos_p25_secs`, `exec_pos_p75_secs`, `exec_pos_iqr_secs`, and
`exec_pos_mad_secs` report positive-only quartiles and robust spread. The
non-reversed and reversed groups expose matching `exec_nonrev_pos_*` and
`exec_rev_pos_*` fields. Their `*_iqr_med_ratio` and `*_mad_med_ratio` values
divide the spread by the same group's positive-only median; a zero median
returns zero. Zero-duration rows are excluded, and empty groups return zero.
`exec_pos_avg_secs`, `exec_nonrev_pos_avg_secs`, and
`exec_rev_pos_avg_secs` report arithmetic mean duration over each group's
strictly positive rows. The matching `exec_pos_avg_med_ratio`,
`exec_nonrev_pos_avg_med_ratio`, and `exec_rev_pos_avg_med_ratio` fields divide
each mean by that group's positive-only median; empty groups return zero.
`exec_pos_min_secs`, `exec_pos_max_secs`, and `exec_pos_range_secs` report the
minimum, maximum, and maximum-minus-minimum among positive valid durations.
The non-reversed and reversed groups expose matching `exec_nonrev_pos_*` and
`exec_rev_pos_*` fields. Zero-duration rows are excluded; empty groups return
zero for all three values.
`exec_pos_p95_gt_count` and `exec_pos_p99_gt_count` count positive durations
strictly above their own nearest-rank thresholds; matching `*_gt_pct` fields
divide by the positive-duration count. Matching `*_tail_secs` fields sum those
values, and `*_tail_pct` reports the sum as a share of positive elapsed seconds.
Non-reversed and reversed groups expose matching `exec_nonrev_pos_*` and
`exec_rev_pos_*` fields. Ties at the threshold are excluded; empty groups
return zero.
`exec_pos_p95_med_ratio`, `exec_nonrev_pos_p95_med_ratio`, and
`exec_rev_pos_p95_med_ratio` divide each positive-only p95 by the median from
the same cohort. The matching `*_p99_med_ratio` fields compare p99 to the same
median. These ratios are dimensionless and return zero when the positive median
is zero.
`exec_pos_p90_gt_count` counts positive durations strictly greater than
the nearest-rank positive-only p90; `exec_pos_p90_gt_pct` divides by the
positive-duration count. Ties at p90 are excluded. `exec_pos_p90_tail_secs`
sums those durations, and `exec_pos_p90_tail_pct` reports their share of total
valid elapsed seconds. The non-reversed group exposes matching
`exec_nonrev_pos_p90_gt_count`, `exec_nonrev_pos_p90_gt_pct`,
`exec_nonrev_pos_p90_tail_secs`, and `exec_nonrev_pos_p90_tail_pct` fields;
the reversed group exposes `exec_rev_pos_p90_gt_count`,
`exec_rev_pos_p90_gt_pct`, `exec_rev_pos_p90_tail_secs`, and
`exec_rev_pos_p90_tail_pct`. Each group uses its own positive-only p90 and
count. Empty groups return zero for all four fields.
`exec_pos_p90_med_ratio`, `exec_nonrev_pos_p90_med_ratio`, and
`exec_rev_pos_p90_med_ratio` divide each positive-only p90 by the median
from the same group. The ratios are dimensionless and return zero when the
group has no positive median.
`exec_duration_avg_median_ratio`, `exec_nonrev_avg_median_ratio`, and
`exec_reversed_avg_median_ratio` divide each group's average duration by its
median. These dimensionless ratios compare the arithmetic mean with the median;
a value above one means longer durations have raised the mean above the median.
They return zero when the median is zero.
`exec_nonrev_min_secs`, `exec_nonrev_max_secs`, `exec_reversed_min_secs`,
and `exec_reversed_max_secs` report the minimum and maximum valid elapsed
duration in each reversal group. Valid zero-duration rows participate, and
an empty subgroup returns zero.
`exec_nonrev_median_secs` and
`exec_reversed_median_secs` report the median valid duration for
each reversal group. They include valid zero-duration rows and return zero
for a group with no valid durations.
`zero_exec_duration_count` also counts complete valid intervals whose start
and finish match; `zero_exec_duration_pct` reports that count as a share of
the summary's `confirmation_count`, rounded to two decimals. These intervals
remain valid and contribute to all duration totals and extrema. Both fields
are zero when the group has no zero-duration interval.
`invalid_exec_duration_count` counts complete pairs with invalid dates/times or
a finish before its start;
`invalid_exec_duration_pct` reports that count as a share of
`confirmation_count`, rounded to two decimals. Rows missing either execution
date are omitted. `missing_exec_duration_count` and
`missing_exec_duration_pct` report their count and share of
`confirmation_count`; both percentages are zero for an empty group. Valid,
invalid, and missing counts partition the summary's confirmations. Totals include reversed
confirmations and may double-count overlapping intervals. Work-center
summaries also report `exec_covered_seconds`, the union of valid execution
intervals with overlaps merged and idle gaps excluded. The center-level value
combines confirmation units; each unit row computes its own union, and
base-work-center rows report the union within their base unit. Unit unions can
overlap across units and should not be summed to derive the center union.
Operation summaries also report the union within each operation and
confirmation-unit group; order summaries report it within each production-order
and confirmation-unit group. Base operation and order summaries report the
union within each base-unit group, merging source-unit intervals converted to
that unit. Each group computes its own union, so unions from different
operation, order, work-center, or unit groups should not be summed as though
they shared a scope. Reversed confirmations remain included in `exec_covered_seconds`.
`exec_nonrev_covered_secs` reports the same valid-interval union after
excluding confirmations marked reversed. Both values merge overlaps and
exclude idle gaps; invalid and missing intervals contribute nothing, and
zero-duration rows add no covered seconds. `exec_nonrev_duration_count`
counts valid non-reversed intervals, including zero-duration rows, and
`exec_nonrev_total_secs` sums their elapsed seconds, counting
overlaps per confirmation. `exec_nonrev_duration_avg_secs` divides that
total by the count, retains fractional seconds, and is zero when the
count is zero. `exec_nonrev_excess_secs` is `exec_nonrev_total_secs` minus
`exec_nonrev_covered_secs`, so it reports duration beyond the non-reversed
union. Invalid and missing rows contribute nothing.
`exec_reversed_duration_count` counts valid reversed intervals, including
zero-duration rows, and `exec_reversed_total_secs` sums their elapsed
seconds. `exec_rev_duration_avg_secs` divides that total by the count, retains
fractional seconds, and is zero when the count is zero.
`exec_reversed_covered_secs` reports the union
of positive-duration reversed intervals; `exec_reversed_excess_secs` is the
total minus that union. Invalid and missing rows do not contribute.
`exec_nonrev_duration_pct` and `exec_reversed_duration_pct` divide each
side's valid duration total by the group's total valid duration and round to
two decimal places. Overlapping intervals count once per confirmation in
both sums, so these shares describe summed duration rather than covered wall
time. Both percentages are zero when the group total is zero; otherwise they
partition 100 percent, with at most 0.01 percentage point difference from
independent rounding. These
`exec_overlap_excess_seconds` reports the difference between a group's summed
valid duration and its `exec_covered_seconds`. It represents duration counted
beyond the covered-time union, so a 30-second triple overlap contributes 60
excess seconds; touching or disjoint intervals contribute none. These
summaries also report `exec_peak_concurrency`, the maximum number of
simultaneously active valid, positive-duration intervals in each group. The
intervals use half-open boundaries, so a finish coinciding with another start
does not increase concurrency. Missing, invalid, and zero-duration intervals
do not count, and the value is zero when the group has no positive interval.
`exec_peak_concurrency_secs` reports elapsed time when active interval count
equaled the group's peak concurrency. It sums separate segments at the maximum
and is zero when the group has no positive interval.
`exec_peak_concurrency_pct` reports that time as a percentage of the same
positive-interval span, rounded to two decimal places. It is zero when the group
has no positive span.
`exec_peak_episode_count` counts continuous stretches at the final peak
concurrency. A higher peak discovered later replaces the earlier peak's
episodes; touching intervals that preserve the peak do not split one.
`exec_longest_peak_secs` reports the longest such stretch, and
`exec_peak_episode_avg_secs` divides `exec_peak_concurrency_secs` by the episode
count while retaining fractional seconds. All three are zero when there is no
positive interval.
`exec_avg_concurrency` divides summed valid interval duration by that span. It
includes uncovered time within the first-to-last interval envelope, can exceed
one when intervals overlap, and is zero when no positive span exists.
`exec_nonrev_p90_secs` and `exec_reversed_p90_secs` report nearest-rank
90th-percentile durations within their respective reversal groups. Valid
zero-duration rows participate, and an empty subgroup returns zero.
`exec_nonrev_p95_secs` and `exec_reversed_p95_secs` report nearest-rank
95th-percentile durations within their respective reversal groups. Valid
zero-duration rows participate, and an empty subgroup returns zero.
`exec_nonrev_p95_exceed_count` and `exec_reversed_p95_exceed_count` count
valid rows strictly above each group's p95 threshold; the matching
`exec_nonrev_p95_exceed_pct` and `exec_reversed_p95_exceed_pct` divide those
counts by each group's valid duration count. Ties at p95 are excluded, and
empty subgroups return zero for all four fields.
`exec_nonrev_p95_median_ratio` and `exec_reversed_p95_median_ratio` divide
each reversal group's p95 duration by its median duration. They have no time
unit and are zero for empty groups or groups with a zero median.
`exec_nonrev_p95_tail_secs` and
`exec_reversed_p95_tail_secs` sum valid durations above each group's
p95; `exec_nonrev_p95_tail_pct` and
`exec_reversed_p95_tail_pct` report those sums as shares of each group's
valid elapsed seconds. Empty or zero-total groups return zero.
`exec_duration_p99_exceed_count` counts valid durations strictly greater than
the group's nearest-rank p99 threshold; `exec_duration_p99_exceed_pct` divides
that count by valid duration rows. Ties at p99 are excluded, and both fields
are zero when the group has no valid durations. The non-reversed and reversed
groups expose matching `exec_nonrev_p99_exceed_count`,
`exec_nonrev_p99_exceed_pct`, `exec_reversed_p99_exceed_count`, and
`exec_reversed_p99_exceed_pct` fields using each subgroup's own p99 and valid
row count.
`exec_p99_tail_secs` sums valid durations strictly above the p99 threshold;
`exec_p99_tail_pct` reports that sum as a share of all valid elapsed seconds.
The non-reversed and reversed groups expose `exec_nonrev_p99_tail_secs`,
`exec_nonrev_p99_tail_pct`, `exec_reversed_p99_tail_secs`, and
`exec_reversed_p99_tail_pct` using each subgroup's own threshold and duration
total. All tail fields are zero when their group has no valid elapsed seconds.
`exec_duration_p99_median_ratio`, `exec_nonrev_p99_median_ratio`, and
`exec_reversed_p99_median_ratio` divide each group's p99 duration by its
median. The ratios have no time unit and return zero when the group's median is
zero.
`exec_nonrev_p99_secs` and `exec_reversed_p99_secs` report nearest-rank
99th-percentile durations within their respective reversal groups. Valid
zero-duration rows participate, and an empty subgroup returns zero.
`exec_nonrev_p25_secs`, `exec_nonrev_p75_secs`,
`exec_reversed_p25_secs`, and `exec_reversed_p75_secs` report the nearest-rank
25th and 75th percentile durations within each reversal group. Valid
zero-duration rows participate, and an empty subgroup returns zero.
`exec_nonrev_iqr_secs` and `exec_reversed_iqr_secs` report the nearest-rank
75th-percentile duration minus the nearest-rank 25th-percentile duration in
each reversal group. Valid zero-duration rows participate, and an empty
subgroup returns zero.
`exec_nonrev_mad_secs` and `exec_reversed_mad_secs` report median
absolute deviation within each reversal group. Valid zero-duration rows
participate, and an empty subgroup returns zero.
`exec_idle_gap_seconds` reports uncovered elapsed time inside the envelope
from the earliest start to latest finish of those intervals. It is that
envelope's elapsed seconds minus `exec_covered_seconds`; time before the first
or after the last positive interval is not counted, and zero-duration rows do
not set the envelope. A continuous chain of touching or overlapping intervals
has zero idle gap. No work calendar or shift availability is applied.
`exec_longest_idle_gap_secs` reports the longest continuous uncovered segment
between merged positive-duration intervals. It stays inside the same envelope,
so time before the first or after the last interval does not count. Touching or
overlapping intervals add no gap, and the value is zero when no internal gap
exists.
`exec_idle_gap_episode_count` reports the number of positive-duration internal
gaps between merged positive-duration intervals. Leading and trailing time,
touching intervals, zero-duration rows, and nonpositive intervals do not add
gaps; the value is zero when the group has no internal gap.
`exec_idle_gap_avg_secs` reports the arithmetic mean duration of those internal
gaps, computed from `exec_idle_gap_seconds` divided by
`exec_idle_gap_episode_count`. It is zero when no internal gap exists and keeps
fractional seconds when the mean is not a whole second.
`exec_interval_coverage_pct` reports the covered union as a percentage of the
elapsed span from the first to last positive-duration interval, rounded to two
decimal places. Overlapping time counts once; it is zero when no positive
interval sets a span. This ratio does not apply a work calendar or shift.
`exec_overlap_wall_pct` reports overlap wall time as a percentage of that same
positive-interval span, rounded to two decimal places. Instants with two or more
active intervals count once; the value is zero when no positive interval sets
a span.
`exec_single_active_seconds` reports time inside the covered union when exactly
one valid positive-duration interval is active. It partitions covered time with
`exec_overlap_wall_seconds`: their sum equals `exec_covered_seconds`. Missing,
invalid, and zero-duration intervals do not contribute.
`exec_single_active_pct` reports that single-active time as a percentage of the
positive-interval span, rounded to two decimal places. Together with
`exec_overlap_wall_pct`, it partitions `exec_interval_coverage_pct`; independent
rounding can leave a difference of at most 0.01 percentage point.
`exec_single_episode_count` reports distinct continuous stretches with
exactly one valid positive-duration interval active. Positive-duration overlaps
and uncovered gaps split episodes; touching intervals that preserve one active
interval do not. Missing, invalid, and zero-duration intervals do not count.
`exec_longest_single_secs` reports the duration of the longest such stretch in
seconds. Overlaps and uncovered gaps end a stretch; touching intervals that
preserve one active interval keep it continuous. It is zero when no such stretch
exists.
`exec_single_active_avg_secs` reports the arithmetic mean duration of those
stretches, calculated from `exec_single_active_seconds` divided by
`exec_single_episode_count`. It is zero when no single-active episode exists
and retains fractional seconds when episode lengths do not divide evenly.
`exec_high_concurrency_secs` reports wall-clock time with at least three valid
positive-duration intervals active. Each instant counts once regardless of
whether three or more intervals overlap; time below three-way concurrency and
missing, invalid, or zero-duration intervals do not contribute.
`exec_exactly_two_secs` reports wall-clock time with exactly two valid
positive-duration intervals active. Together with `exec_high_concurrency_secs`,
it partitions `exec_overlap_wall_seconds`; each instant counts once and
missing, invalid, or zero-duration intervals do not contribute.
`exec_exactly_two_pct` reports that time as a percentage of the same positive-
interval span, rounded to two decimal places. With `exec_3plus_pct`, it
partitions `exec_overlap_wall_pct`; independent rounding can differ by at most
0.01 percentage point. It is zero when no positive span exists.
`exec_3plus_episode_count` reports separate continuous stretches
with at least three valid positive-duration intervals active. Overlaps below
three-way concurrency and uncovered gaps split episodes; touching intervals
that preserve three-way concurrency do not. Missing, invalid, and zero-duration
intervals do not count.
`exec_longest_3plus_secs` reports the longest continuous stretch with at least
three valid positive-duration intervals active. `exec_3plus_avg_secs` divides
`exec_high_concurrency_secs` by `exec_3plus_episode_count` and retains fractional
seconds. Both values are zero when no three-way episode exists. A touching
interval that keeps the active count at three continues the episode; a gap or
drop below three ends it.
`exec_3plus_pct` reports `exec_high_concurrency_secs` as a percentage of the
same first-to-last positive-interval span used by `exec_interval_coverage_pct`,
rounded to two decimal places. It is zero when the group has no positive span
and cannot exceed `exec_overlap_wall_pct`, except for independent rounding.
`exec_overlap_wall_seconds` reports elapsed wall-clock time inside the positive
intervals' envelope when at least two valid positive-duration intervals were
active. Each instant counts once: a 30-second triple overlap contributes 30
seconds here and 60 excess seconds to `exec_overlap_excess_seconds`. Touching
and zero-duration intervals add no overlap wall time.
`exec_pairwise_overlap_secs` sums overlap duration for every unordered pair of
valid positive-duration intervals. A segment with `n` active intervals adds
`n * (n - 1) / 2` times its duration; a 30-second triple overlap therefore
contributes 90 pairwise seconds. Missing, invalid, and zero-duration intervals
do not contribute.
`exec_overlap_pair_count` counts each distinct pair of valid positive-duration
intervals that overlap for a positive duration once. Endpoint-only contact does
not count, and one shared three-way interval contributes three pairs. The count
is independent of how long each pair overlaps.
`exec_overlap_pair_avg_secs` divides `exec_pairwise_overlap_secs` by that pair
count. It reports the mean positive overlap duration per intersecting pair,
retains fractional seconds, and is zero when no pair overlaps.
`exec_longest_pair_overlap_secs` reports the longest positive-duration
intersection between any one pair of valid intervals. It compares individual
pairs rather than group-wide concurrency episodes and is zero when no pair
overlaps.
`exec_longest_overlap_secs` reports the longest continuous stretch with at least
two valid positive-duration intervals active. Separate episodes are compared
individually, and touching intervals do not create overlap.
`exec_overlap_episode_count` reports the number of separate continuous stretches
with at least two active intervals. A positive-duration gap starts a new episode;
overlap periods that meet at an endpoint remain one episode. Zero-duration,
missing, and invalid intervals do not contribute.
`exec_overlap_avg_secs` reports the arithmetic mean overlap-episode duration,
calculated from `exec_overlap_wall_seconds` divided by
`exec_overlap_episode_count`. It is zero when no episode exists and retains
fractional seconds when episode lengths do not divide evenly.
These page-level coverage values do not measure utilization because shift
calendars and availability are not applied. Pairwise overlap, overlap-pair
summaries, concurrency shares and averages, and peak-concurrency episodes use
the same returned page rows. Operation summaries group duration metrics by
operation and confirmation unit; order summaries aggregate them by production
order and confirmation unit. Each group uses its own confirmation count for
coverage percentages and selects its earliest start and latest finish.
Set `iv_order_category` to `10` for production orders or `40` for process
orders. Other nonblank values fail before the repository read; the repository
filters AUFK before operation resolution, and the service checks returned
category scope. Pass `iv_order_type` to restrict confirmations to one exact
AUFK order type; initial omits the filter. The repository applies the selection
before resolving operations, and the service checks returned order-type scope.
Pass `iv_operation_counter` to restrict confirmations to one exact AFVC-APLZL
counter; an initial value omits that filter. Set `iv_operation_counter_from`
and/or `iv_operation_counter_to` for inclusive AFVC-APLZL bounds; initial
values omit their bound, paired active bounds must ascend, and the exact
counter selector intersects with the range. The repository filters before
pagination, and the service validates returned counters. Optional
`iv_posting_date_from` and `iv_posting_date_to` bounds
select inclusive AFRU-BUDAT dates. Each noninitial bound must be a valid
Gregorian date; either bound can be omitted, and two active bounds must be
ascending. The repository applies these bounds before resolving operations,
and the service checks returned posting dates. Optional `iv_entry_date_from`
and `iv_entry_date_to` independently filter inclusive AFRU-ERSDA dates; each
active bound must be a valid Gregorian date, two active bounds must ascend, and
active entry-date filters omit confirmations without an entry date. The
repository filters before resolving operations, and the service checks returned
entry-date scope. Pass `iv_entered_by` or `iv_changed_by` to filter an exact
AFRU user; a nonblank value filters by default. Set `iv_filter_entered_by` or
`iv_filter_changed_by` to `abap_true` to select the exact blank user. The flags
accept only `abap_true` or `abap_false`, and service validation checks returned
user scope. Optional `iv_last_change_date_from` and
`iv_last_change_date_to` bounds filter AFRU-LAEDA inclusively. Each active bound
must be a valid Gregorian date; either may be omitted, and two active bounds
must ascend. Active bounds omit confirmations without a last-change date. The
repository filters before operation resolution and the service checks returned
dates. Each result also exposes AFRU-ISDD/ISDZ and AFRU-IEDD/IEDZ as
`execution_start_date`, `execution_start_time`, `execution_finish_date`, and
`execution_finish_time`; the service validates noninitial returned timestamps.
`exec_duration_status` is `V` for a complete valid interval, including a
zero-duration interval; `I` for a complete pair with invalid dates/times or a
finish before its start; and `M` when either execution date is missing. Each
row also exposes `exec_duration_issue_code` to identify the first applicable
cause: `MS` for missing start date, `MF` for missing finish date, `MD` when both
dates are missing, `IS` for an invalid start date, `IF` for an invalid finish
date, `TS` for an invalid start time, `TF` for an invalid finish time, or `NE`
when finish precedes start. Both missing dates take precedence, then a missing
start date, then a missing finish date; invalid date/time checks run in start
date, finish date, start time, finish time order, and negative duration is
checked last. The issue code is blank for a valid interval. Time `000000` is a
valid midnight value. The service calculates status and issue code on each
returned confirmation, and base-unit detail rows echo both. All seven summary
scopes also include `exec_duration_issue_counts`, a fixed eight-row table
sorted by issue code for `IF`, `IS`, `MD`, `MF`, `MS`, `NE`, `TF`, and `TS`.
Each row reports its `status` and `confirmation_count`; codes with no matching
confirmation stay present with count zero. Each row also reports
`confirmation_pct` against the summary's `confirmation_count`, returning zero
for an empty summary. Rows also split `nonrev_confirmation_count` and
`reversed_confirmation_count`, with `nonrev_confirmation_pct` and
`reversed_confirmation_pct` using the matching cohort's confirmation count.
An empty cohort returns zero percentages. Counts and percentages reconcile to
the invalid and missing totals for the full summary and each reversal cohort.
`issue_share_pct` reports each reason's share of all invalid and missing
confirmations, and is zero when the summary has no such confirmations.
`nonrev_issue_share_pct` and `reversed_issue_share_pct` report each reason's
share within the corresponding non-reversed or reversed invalid/missing
confirmations. They are zero when that cohort has no invalid or missing rows.
`status_share_pct` reports a reason's share within its own status: invalid
reasons use the invalid count, and missing reasons use the missing count. It is
zero when no invalid or missing intervals have that status.
`nonrev_status_share_pct` and `reversed_status_share_pct` split that
status-specific reason distribution by reversal cohort, using the cohort's
invalid or missing count. Empty cohort/status groups return zero.
Each summary also reports `exec_top_issue_code`, `exec_top_issue_status`,
`exec_top_issue_count`, and `exec_top_issue_pct` for its most frequent issue.
The percentage uses the summary's full `confirmation_count`. Ties select the
lexically first issue code; when the summary has no issues, code and status are
initial and count and percentage are zero.
Each summary also reports the most frequent invalid reason with
`exec_top_invalid_issue_code`, `exec_top_invalid_issue_count`, and
`exec_top_invalid_share_pct`, plus matching `exec_top_missing_*` fields. The
shares use all invalid and all missing confirmations respectively. Ties select
the lexically first code within each status; an empty status returns an initial
code and zero count and share.
Each summary also reports the most frequent issue within non-reversed and
reversed confirmations through `exec_top_nonrev_issue_code`,
`exec_top_nonrev_issue_status`, `exec_top_nonrev_issue_count`,
`exec_top_nonrev_issue_pct`, and matching `exec_top_reversed_issue_*` fields.
These percentages use each cohort's full `confirmation_count`. Ties select the
lexically first code; empty cohorts or cohorts without issues return initial
code/status and zero count and percentage.
Each row also exposes `exec_duration_seconds`, the elapsed whole seconds for a valid
interval, including zero. It is initial for invalid and missing intervals; use
the status and issue code to distinguish them from a valid zero-duration
interval. Base-unit detail rows echo the calculated value.
Optional `iv_execution_start_date_from` and `iv_execution_start_date_to` bounds
filter AFRU-ISDD inclusively. Either bound may be omitted; active bounds must be
valid Gregorian dates, paired bounds must ascend, and active bounds omit rows
without an actual execution start date. `iv_execution_finish_date_from` and
`iv_execution_finish_date_to` apply the same rules to AFRU-IEDD. Both date
ranges are applied before operation resolution and pagination, and the service
checks returned date scope. Set `iv_filter_execution_start_time` to
`abap_true` with both valid `iv_execution_start_time_from` and
`iv_execution_start_time_to` values to filter AFRU-ISDZ inclusively. Use
`iv_filter_exec_finish_time` with both valid
`iv_execution_finish_time_from` and `iv_execution_finish_time_to` values for
AFRU-IEDZ. A time filter requires a nonblank corresponding execution date;
`000000` is valid midnight, bounds must ascend, and disabled filters require
initial bounds. Both flags accept only `abap_true` or `abap_false`. The
repository applies them before pagination, and the service checks returned
timestamp scope. Set `iv_filter_entry_time` to `abap_true` with both valid
`iv_entry_time_from` and `iv_entry_time_to` bounds to select AFRU-ERZET
inclusively. Midnight `000000` is valid; bounds must ascend. Disabled filters
require initial bounds. The repository filters before operation resolution and
pagination, and the service checks returned times. Pass `iv_quantity_unit` to
restrict rows to one AFRU confirmation unit;
a nonblank value filters by default. Set `iv_filter_quantity_unit` to
`abap_true` to select only confirmations with a blank unit. The flag accepts
only `abap_true` or `abap_false`; the repository applies the scope before
operation resolution and the service validates returned units. Set
`iv_positive_yield_only`, `iv_positive_rework_only`, or
`iv_positive_scrap_only` to `abap_true` to require a positive corresponding
AFRU quantity. Set `iv_filter_yield_quantity_from` and `iv_filter_yield_quantity_to` with
the corresponding `iv_yield_quantity_from` and `iv_yield_quantity_to` values
to select inclusive AFRU-LMNGA ranges. The corresponding
`iv_filter_rework_quantity_from` / `iv_filter_rework_quantity_to` flags and
`iv_rework_quantity_from` / `iv_rework_quantity_to` values select AFRU-RMNGA;
the matching scrap flags and values select AFRU-XMNGA. Each bound is enabled
independently, disabled values must be initial, and paired bounds must ascend. Quantity ranges require one unit scope: provide a nonblank
`iv_quantity_unit`, or set `iv_filter_quantity_unit` to `abap_true` to select
one exact unit, including blank. Positive-only flags do not require a unit.
Repository filters run before operation resolution and pagination, and the
service validates returned quantities against every active selector. Repeat
the same order list and filters on cursor continuation requests.
Pass `iv_operation_number` to restrict confirmations to one exact AFVC-VORNR
value. It can be combined with the counter selector; initial omits the filter.
Set `iv_operation_number_from` and/or `iv_operation_number_to` for inclusive
AFVC-VORNR bounds; initial values omit their bound, paired active bounds must
ascend, and the exact `iv_operation_number` selector intersects with the range.
The repository filters before pagination, and the service validates returned
operation numbers. `iv_control_key`, `iv_operation_description`, and
`iv_resource_object_id` add
exact AFVC filters, with nonblank values filtering by default. Set the matching
`iv_filter_control_key`, `iv_filter_op_description`, or
`iv_filter_resource_object_id` flag to `abap_true` to match a blank value
exactly; each flag accepts only `abap_true` or `abap_false`. Resource IDs are
internal AFVC-ARBID object IDs. The repository filters these fields before
paging, and the service checks returned metadata scope.
Pass `iv_operation_sequence` to select one routing sequence; a nonblank value
filters by default. Set `iv_filter_operation_sequence` to `abap_true` to match
the exact initial sequence. Set `iv_operation_sequence_from` and/or
`iv_operation_sequence_to` for inclusive AFVC-PLNFL bounds; initial values omit
their bound, paired active bounds must ascend, and the exact sequence selector
intersects with the range. The repository applies the range before pagination,
and the service validates returned sequence scope. Pass `iv_suboperation_number` to select one suboperation; set `iv_filter_suboperation_number` to `abap_true` to select only
base operations. Set `iv_suboperation_number_from` and/or
`iv_suboperation_number_to` for inclusive AFVC-UVORN bounds; initial values omit
their bound, and paired active bounds must ascend. An active range requires an
exact noninitial `iv_operation_number`; the exact suboperation selector
intersects with the range. Both flags accept only `abap_true` or `abap_false`,
and the service checks returned routing scope. The repository applies these
selectors before mapping and pagination.
Pass `iv_confirmation_number` to select one AFRU confirmation; optionally pass
`iv_confirmation_counter` to select one counter, which requires a confirmation
number. The repository applies this pair before resolving operations, and the
service validates both returned fields.
Reversed rows are included by default. Set `iv_exclude_reversed` to
`abap_true` to omit them, or set `iv_reversed_only` to `abap_true` to return
only reversed rows. Both flags accept only `abap_true` or `abap_false`, cannot
both be true, and the service validates returned reversal scope.
`iv_final_only` keeps final confirmations; `iv_partial_only` keeps rows not
marked final. Both flags default to false, accept only `abap_true` or
`abap_false`, and cannot both be true. The repository applies these filters
before resolving operations, and the service validates returned status scope.
Set `iv_maximum_results` to limit each page to 1 through 500 rows; it defaults
to 500. Results sort by production order ascending, posting date descending,
confirmation number descending, and confirmation counter descending. A
truncated result returns `next_production_order`, `next_posting_date`,
`next_confirmation`, and `next_confirmation_counter`; pass all four back as
the matching `iv_after_*` parameters to continue. Partial cursors, invalid
posting dates, and cursor orders outside the request are rejected before the
repository read. Each order's `confirmation_count` and the result's
`returned_count` describe only rows returned on the current page.
The result includes confirmation number/counter, posting date, actual
yield/rework/scrap quantities and their entry unit, final status, and reversal
status. Quantity values remain in SAP's confirmation unit and are not converted
or netted; reversed rows remain visible so callers can distinguish them before
cancellation. Empty confirmation lists are reported per order. Each requested
order reports `confirmation_count`; the result's `returned_count` is the sum of
those per-order counts. Nonempty bulk results include a UTC `snapshot_timestamp`
captured after the repository read;
empty input leaves it initial. SAP documents
the AFRU yield, rework, scrap, and quantity-unit fields
([SAP confirmation API guide](https://help.sap.com/doc/9840fb99f9a74026ab7f1929fde9c454/3.0.3/en-US/SAPEdgeServicesOnPremEssentialBusinessFunctionsAPIGuide30FP03.pdf),
[confirmation fields](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/327cb6535fe6b74ce10000000a174cb4.html)).
`READ_OPERATIONS_BULK` returns routing operations for requested production and
process orders, including `order_category` from `AUFK-AUTYP`, `order_type` from
`AUFK-AUART`, internal operation counter, sequence, operation and suboperation
numbers, description, control key, and `resource_object_id` from `AFVC-ARBID`.
Each operation also returns work-center code and plant from CRHD. Pass
`iv_work_center` or `iv_work_center_plant` for an exact nonblank value; set
`iv_filter_work_center` or `iv_filter_work_center_plant` to `abap_true` with
an initial value to select blank assignments, including missing CRHD rows.
Both flags accept only `abap_true` or `abap_false`. The repository applies
these selectors before pagination, and the service checks returned code and
plant scope before grouping. Each page includes `work_center_summaries`,
grouped by work-center plant and code. Blank assignments form their own group;
summary counts include only returned operations, exclude the lookahead row and
later pages, and sum to `total_operation_count`. Each group reports
`order_count`, the distinct requested orders with returned operations in the
group. An order counts once per work-center group, even if it has multiple
operations there, and may count in more than one group. Each group also reports
`order_pct`, its distinct order count as a share of `found_count`, rounded to
two decimals. `found_count` is the number of requested orders with operations
on the returned page; order percentages are initial when it is zero.
Work-center groups can overlap, so their order percentages may
sum above 100. Each group also reports `operation_pct`, its share of page
operations rounded to two decimals. Its
denominator is `total_operation_count`; percentages are computed from page
counts, not averaged across orders. Empty pages leave percentages initial, and
nonempty page percentages sum to 100 before independent rounding.
Each page also includes `order_category_summaries`, grouped by AUFK-AUTYP.
Blank categories remain visible; counts include returned page operations only,
exclude lookahead and later pages, and sum to `total_operation_count`. Each
category reports `operation_pct`, its share of page operations rounded to two
decimals using `total_operation_count` as the denominator. Empty pages leave
these percentages initial. Each category also reports `order_count`, the
distinct requested orders with a returned operation in that category. Each
category also reports `order_pct`, its order count as a share of `found_count`,
rounded to two decimals. Each page also includes `order_type_summaries`,
grouped by AUFK-AUART. Blank order types remain visible; counts include
returned page operations only, exclude lookahead and later pages, and sum to
`total_operation_count`. Each order type reports `operation_pct`, its share of
page operations rounded to two decimals using `total_operation_count` as the
denominator. Empty pages leave these percentages initial. Each order type also
reports `order_count`, the distinct requested orders with a returned operation
of that type. Each order type also reports `order_pct`, its order count as a
share of `found_count`, rounded to two decimals. Each page also includes
`control_key_summaries`, grouped by
AFVC-STEU. Blank control keys
remain visible; counts include returned page operations only, exclude lookahead
and later pages, and sum to `total_operation_count`. Each control key reports
`operation_pct`, its share of page operations rounded to two decimals using
`total_operation_count` as the denominator. Empty pages leave these percentages
initial. Each control key also reports `order_count`, the distinct requested
orders with at least one returned operation using that key. Each control key
also reports `order_pct`, its order count as a share of `found_count`, rounded
to two decimals. An order may count in more than one control-key group, so
control-key order percentages may sum above 100.
Results are grouped per
order in request order; orders with no operation rows are reported as empty.
Set `iv_order_category` to `10` for production orders or `40` for process
orders; when omitted, both categories are included. Other nonblank values are
rejected before the repository read, and the service validates returned rows
against the selected category. Pass `iv_order_type` to restrict results to one
exact AUFK-AUART order type. Rows expose `order_type`, and the service checks
returned type scope. The repository applies this filter before pagination.
Pass `iv_resource_object_id` to restrict the rows to one assigned resource; a
nonblank value filters automatically. Set `iv_filter_resource_object_id` to
`abap_true` with an initial ID to select unassigned operations exactly. The
flag must be `abap_true` or `abap_false`; the service validates returned
resource scope before grouping. Pass `iv_control_key` to select a routing
control key; a nonblank key filters by default. Set `iv_filter_control_key` to
`abap_true` with an initial key to select operations whose control key is
blank. The flag must be `abap_true` or `abap_false`; the service validates
returned control-key scope before grouping.
Pass `iv_operation_description` to select an exact AFVC-LTXA1 operation text;
a nonblank value filters by default. Set `iv_filter_op_description` to
`abap_true` with an initial text to select operations with a blank description.
The flag must be `abap_true` or `abap_false`, and the service validates
returned operation-description scope before grouping.
Pass `iv_operation_number` to restrict results to one AFVC operation number;
an initial value leaves operation numbers unfiltered. It can be combined with
the resource and control-key selectors. Pass `iv_operation_counter` to select
one exact AFVC-APLZL counter, with or without an operation number. Set
`iv_operation_counter_from` and/or `iv_operation_counter_to` for inclusive
APLZL bounds; initial values omit their bound, and noninitial bounds must
ascend when both are supplied. The exact counter selector intersects with this
range. These filters apply before pagination, and the service validates
returned operation-number and counter scope before grouping. Set `iv_operation_number_from` and/or
`iv_operation_number_to` for inclusive AFVC-VORNR bounds; initial values omit
their bound, and noninitial bounds must ascend when both are supplied. The exact
`iv_operation_number` selector intersects with this range. The repository
applies the range before paging, and the service validates each returned operation number. Pass
`iv_operation_sequence` to select a routing sequence; set
`iv_filter_operation_sequence` to `abap_true` with an initial sequence to match
it exactly. Set `iv_operation_sequence_from` and/or
`iv_operation_sequence_to` for inclusive AFVC-PLNFL bounds; initial values omit
their bound, and noninitial bounds must ascend when both are supplied. The
exact sequence selector intersects with the range. The repository applies the
range before paging, and the service validates returned sequence scope. Pass
`iv_suboperation_number` to select
one suboperation; set `iv_filter_suboperation_number` to `abap_true` with an
initial value to select base operations only. Set `iv_suboperation_number_from`
and/or `iv_suboperation_number_to` for inclusive AFVC-UVORN bounds. Initial
values omit their bound, paired active bounds must ascend, and an active range
requires an exact noninitial `iv_operation_number`. The exact suboperation
selector intersects with the range. Both flags must be `abap_true` or
`abap_false`, and the service validates returned routing-key scope before
grouping. `iv_maximum_results` limits each page to 1 through 500 operations and
defaults to 500. Order, category, type, resource, control-key,
operation-description, operation-number, operation-counter, sequence,
suboperation, and suboperation-range filters apply before pagination.
Cursor traversal orders operation rows by production order, routing sequence,
operation number, suboperation number, and AFVC operation counter.
When `is_truncated` is true, pass all five `next_*` values back as the
corresponding `iv_after_*` values; pass the sequence and suboperation values
even when initial. Partial cursors and cursors for orders outside the request
are rejected. Keep the order list and filters unchanged across pages. Each order
reports its page-level `operation_count`; `total_operation_count` sums those
counts. `found_count` and `empty_count` describe the current page. Each page
is a separate read; multiple pages do not form one consistent snapshot.
Nonempty bulk results include a UTC `snapshot_timestamp` captured after the
repository read; empty input leaves it initial. The repository follows SAP's
routing linkage and operation identifiers
([SAP operation data view](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/afa5a1dc1d81424784b89e079cec0b48.html),
[SAP routing field mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-routing)).
SQLite-backed Open SQL tests execute the repository's order-item, status,
confirmation, and operation reads, including category and active-status
filters, status text mapping, confirmation ordering, and operation sorting.
`CREATE_CONFIRMATIONS_ATOMIC` and `CREATE_CONFIRMATIONS_BULK` post
production-operation time tickets through `BAPI_PRODORDCONF_CREATE_TT`.
Requests provide the order, four-character operation, six-character sequence,
posting date, yield, scrap, rework, ISO quantity unit, and optional
final-confirmation and open-reservation settings. Atomic mode stages each
ticket in one SAP LUW, commits once when every ticket succeeds, and rolls back
the group after a BAPI or commit error. Bulk mode commits each ticket
independently and continues after failures by default. The adapter requires both the
confirmation number and counter before reporting create success, and commits
only after that key is validated. The service maps detail-return messages and
confirmation keys. Atomic mode also accepts `iv_test_run`; it forwards SAP's
`TESTRUN = 'X'` to each time-ticket BAPI call and neither commits nor rolls
back the simulated group. A successful test run reports
`is_test_run = abap_true` and `is_committed = abap_false`; SAP may omit
confirmation numbers and counters in simulation, so those fields remain
initial. Simulated success indicates that the BAPI accepted the request in
test mode and does not represent a persisted confirmation. Blank final
confirmation means partial; `1` requests automatic final confirmation; `X`
marks final confirmation. The API may also trigger configured automatic goods
receipts or component backflush, so the target order and work-center settings
govern inventory effects ([SAP PCo example](https://help.sap.com/doc/302a83e81be74549bbc31509bb1b4246/15.5.5/en-US/Application_HELP_EN.pdf),
[SAP confirmation field mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-production-yield-confirmation),
[SAP BAPI TestRun guidance](https://help.sap.com/saphelp_snc70/helpdata/EN/df/0495dbbd6f11d1ad09080009b0fb56/content.htm?no_cache=true)).
`CANCEL_CONFIRMATIONS_BULK` and `CREATE_CONFIRMATIONS_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. When enabled, the first failed
API result or commit stops later requests; unattempted rows remain in caller
order with `is_skipped`, and `skipped_count` is separate from `failed_count`.
`stopped_on_failure` is set even when the failure is last, and earlier
independent commits remain committed. Confirmation creation defers its bulk
commit until the service verifies that the returned order, operation, and
sequence match the request. Invalid flag values fail before the first BAPI
call.
`RELEASE_ORDERS_AFTER_ATP` first checks all requested orders' open component
requirements with the configured `ZCL_PROD_COMP_SERVICE` and a caller-supplied
ATP check rule. It releases the group only when every component is fully
confirmed, and returns the per-order component quantities and readiness. A
short, malformed, or incomplete ATP result stops before the release BAPI.
Configure `ZCL_PROD_ORDER_ATP_CHECKER` with the same component service used by
the application. ATP confirmation is a point-in-time check, not a reservation;
SAP can still reject release if availability changes.
`RELEASE_ORDERS_BULK_AFTER_ATP` checks the complete request before making any
release calls, then releases and commits each fully confirmed order
independently. Orders with short components are returned as ATP-blocked and are
skipped while ready orders continue by default; results preserve request order
and carry both readiness and release/commit status. Set
`iv_stop_on_failure = abap_true` to stop after the first ATP-blocked request or
failed release/commit. The first failure row remains visible and later rows are
marked `is_skipped`; if an earlier ready order fails, a later ATP-blocked row is
skipped too. `skipped_count` is separate from `failed_count`, while
`atp_blocked_count` reports readiness diagnostics, including blocked rows that
were skipped. An incomplete or malformed checker response blocks all writes.
As with the atomic ATP-gated operation, the availability check is a point-in-time
preview rather than a stock reservation.
`CHANGE_ORDERS_ATOMIC` and `CHANGE_ORDERS_BULK` call
`BAPI_PRODORD_CHANGE` for selected order quantity, quantity unit, basic start
date, and basic finish date. Each request identifies changed fields explicitly;
quantity and its unit are updated together. Atomic mode shares one commit and
rolls the group back on the first error; bulk mode commits each order and
continues after failures by default. Set `iv_stop_on_failure = abap_true` to
stop later changes after the first failed API result or commit. Unattempted
rows stay in caller order with `is_skipped = abap_true`; the summary reports
`skipped_count` separately and sets `stopped_on_failure`, including when the
failed request is last. Earlier independent commits remain committed. Invalid
flag values fail before the first BAPI call. Requests are validated before the first BAPI call,
including duplicate keys, positive changed quantities, required units/dates,
and start-before-finish when both dates are changed. SAP's order-change app
supports header scheduling and quantity changes; the target system remains
authoritative for eligibility and rescheduling behavior
([SAP Change Production Order](https://help.sap.com/docs/SAP_S4HANA_CLOUD/2bba750d1e124e1ea2a039bb1cd9b6c5/c448c58b70c344cbb7af9bb6d05279cf.html),
[BAPI change-field conventions](https://help.sap.com/docs/ABAP_PLATFORM_NEW/166400f6be7b46e8adc6b90fd20f3516/4d5bc81fdbd42307e10000000a15822b.html)).
`COMPLETE_ORDERS_TECH_ATOMIC` sets technical completion through
`BAPI_PRODORD_COMPLETE_TECH` for a validated order group and shares one commit;
the first BAPI or commit error rolls back the group. `COMPLETE_ORDERS_TECH_BULK`
commits each order separately and continues after failures. Neither method has
a test-run option. SAP describes TECO as ending an order logistically, removing
open requirements such as reservations/capacities, and preventing further
changes to the order, so use it only when execution is being stopped or ended
([SAP technical completion](https://help.sap.com/docs/PRODUCT_ID/a6f0333202384ba2b48a841a4a6deb1b/8fdaaa01188d4f4d97fef1fbf72fa020.html)).
`SET_DELETION_FLAGS_ATOMIC` and `SET_DELETION_FLAGS_BULK` use
`BAPI_PRODORD_SET_DELETION_FLAG`. The atomic method shares one commit and rolls
back the group on the first error; the bulk method commits each order and
continues after failures. This sets the SAP deletion flag (DLFL); it does not
immediately remove the order. SAP may set the deletion indicator after a
configured residence time, and the deletion flag can be canceled
([SAP deletion-flag behavior](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/a6f0333202384ba2b48a841a4a6deb1b/8e9067167e7a4344be1e49e46a13af7c.html?locale=en-US&state=PRODUCTION&version=2025.001)).
`CLOSE_ORDERS_ATOMIC` and `CLOSE_ORDERS_BULK` call
`BAPI_PRODORD_CLOSE` to set status CLSD. The atomic operation closes a
validated group with one commit and rolls back on the first BAPI or commit
error. The bulk operation commits each order independently and continues after
failures. SAP documents closing orders in Released (REL) or Technically
Completed (TECO) status; target-system status profiles and order prerequisites
still apply ([SAP close-order operation](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/950a6264f8fa4168a89ac15f79f4880a.html?locale=en-US),
[SAP production-order BAPI catalog](https://help.sap.com/doc/ddd743d1660847cc98ed15b46ddf5307/6.0/en-US/Release_Notes_SAP_AFS_60E.PDF)).
`SET_DELETION_INDICATORS_ATOMIC` and `SET_DELETION_INDICATORS_BULK` call
`BAPI_PRODORD_SET_DEL_INDICATOR` to set DLT after the order already has DLFL.
Atomic mode shares one commit and rolls back on the first error; bulk mode
commits each order and continues. This is an indicator for SAP's deletion
process, not an immediate physical delete
([SAP deletion-indicator prerequisite](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/a6f0333202384ba2b48a841a4a6deb1b/756a590e8f7942a1a25549e80762e74f.html)).
The bulk completion, deletion-flag, close, and deletion-indicator methods accept
`iv_stop_on_failure`, defaulting to `abap_false`. When true, the first failed
API result or commit stops later calls. Unattempted rows remain in caller order
with `is_skipped`, and `skipped_count` is separate from `failed_count`.
`stopped_on_failure` is set even if the failed row is last; earlier independent
commits remain committed. Invalid values are rejected before the first BAPI
call.
`ZCL_PROD_ORDER_READ_SERVICE->READ_ORDERS_BULK` bulk-reads requested PP
production orders and process orders. Each order result retains all output
items rather than choosing a primary item. Each item reports
`order_quantity_base`, `received_quantity_base`, `open_quantity_base`, and
`over_receipt_quantity_base` in the material base unit. The over-receipt base
quantity uses the converted positive excess when receipt progress is valid and
conversion succeeds; it is zero for valid items without excess and initial
otherwise. Each item also reports
`open_quantity_order_unit`, `over_receipt_qty_order_unit`, and received
and open percentages of the AFPO order quantity in the order unit, plus
`over_receipt_pct_of_order_qty`, the over-receipt quantity as a percentage of
the order quantity before two-decimal rounding. It is zero for valid items
without an over-receipt and can exceed 100.00. Invalid AFPO quantities leave it
initial. Each item also reports `receipt_progress_status`: `N` (not started),
`P` (partial), `C` (fully
received), or `O` (over-received); matching `c_receipt_progress_*` constants
are exposed by the service. Open quantity is clamped at zero after full
receipt; received percentages can exceed 100, while open percentage is zero at
or above full receipt. Over-receipt quantity reports the excess in order units.
The status and quantities remain available independently of base-unit
conversion; invalid AFPO quantities leave the status initial. A valid
not-started item reports its full order quantity as open and an open percentage
of 100.00.
Each item also exposes `is_receipt_progress_valid`, true when the order
quantity is positive and received quantity is nonnegative. It remains false
for invalid raw quantities, independently of base-unit conversion success.
`receipt_progress_counts` exposes `not_started_item_count`,
`partial_item_count`, `complete_item_count`, `over_received_item_count`, and
`invalid_item_count`, and `total_item_count`. Each returned item contributes to
one status count, and `total_item_count` is the sum of the five status counts.
The invalid count covers nonpositive order quantities and negative received
quantities.
Each returned order also exposes `receipt_progress_counts` over every item
returned for that order. Its counts and total reconcile to the order's detail
rows; an itemless order leaves the summary initial. For finish-window reads the
all-item summary includes nonmatching detail items retained for scope-drift
reporting.
Each finish-window order's `matching_progress_counts` counts only its items
marked `matches_finish_selection`; direct bulk reads leave this structure
initial. The page-level `finish_match_progress_counts` aggregates those order
summaries, and its five counts sum to the `finish_window_match_count` values
across returned orders. Each finish-window order's matching-summary total
equals its `finish_window_match_count`, and the page-level matching total is
the sum of those per-order totals. Direct bulk reads leave matching totals
initial. A base-unit conversion failure does not erase a valid order-unit
progress state.
Each progress-count structure also exposes `not_started_pct`, `partial_pct`,
`complete_pct`, `over_received_pct`, and `invalid_pct`, using the sum of all
five state counts, including invalid items, exposed by `total_item_count` as the
denominator. Percentages are rounded to two decimal places; empty summaries
leave the total and percentages initial.
It also returns the order and base units; basic and scheduled start/finish
dates; raw AUFK phase and deletion
indicators; AFPO sales-order assignment, item, and schedule line, account-assignment category,
MRP area, planning and delivery plants, goods recipient, unloading point, special-stock indicator, stock type, production version, planned-order start date, storage location, batch, WBS element, and planned-order reference;
receipt and delivery-complete indicators;
and active SAP system and user statuses with codes, short names, and
logon-language names. Blank or duplicate
order numbers are rejected before repository reads; missing orders and
unit-conversion failures are reported per result. Categories other than 10 and
40 are not returned. The service rejects repository item/status rows for
unrequested orders and duplicate item or status keys before mapping. The
page-level `conversion_succeeded_count` and `conversion_failed_count`, and the
same per-order counts, reconcile to all returned detail items, including
nonmatching items retained by finish-window reads. These counts describe
base-unit conversion and are independent of receipt-progress validity.
Finish-window results also report `finish_match_conv_ok_count` and
`finish_match_conv_fail_count`, with per-order `matching_conv_ok_count` and
`matching_conv_fail_count`. These matching-only counts reconcile to
`finish_window_match_count`; direct bulk reads leave them initial.
Finish-window results also expose `finish_match_base_qty_summary` and per-order
`matching_base_qty_summary`, each with `item_count`, `excluded_item_count`,
`contributing_progress_counts`, `contributing_progress_qty`,
`invalid_progress_count`,
`valid_progress_conv_fail_count`,
`order_qty_base_total`, `received_qty_base_total`, `open_qty_base_total`, and
`over_rcpt_qty_base_total` in the selected material's base unit. `item_count`
includes matching items with valid receipt progress and successful conversion;
valid items without excess count and add zero to the over-receipt total.
`invalid_progress_count` includes invalid-progress rows even when conversion
also failed. `valid_progress_conv_fail_count` counts only conversion failures
with valid progress. These disjoint reason counts sum to `excluded_item_count`.
Per-order contributing and excluded counts sum to `finish_window_match_count`;
page counts sum across orders. Page values sum the
per-order summaries. Order plus over-receipt totals reconcile with received plus open
totals, subject to decfloat34 rounding. Direct bulk reads leave these
finish-window-only summaries initial. `contributing_item_pct` and
`excluded_item_pct` report the two counts as percentages of matched items,
rounded to two decimals; page values are weighted across matching items, not
averaged from order percentages. Empty summaries leave these percentages
initial. `invalid_progress_pct` and `valid_progress_conv_fail_pct` report each
disjoint exclusion reason as a percentage of all matched items. Their exact
shares sum to the excluded percentage, though independent two-decimal rounding
can create a 0.01 point difference. Empty summaries leave these percentages
initial too. `invalid_excluded_share_pct` and `conv_fail_excluded_share_pct`
report each disjoint reason's share of the
excluded items; their exact shares sum to 100%, subject to independent rounding.
Summaries without excluded items leave these shares initial.
`contributing_progress_counts` breaks contributing items down by not-started,
partial, complete, and over-received states. Its `total_item_count` equals
`item_count`, and percentages use `item_count` as the denominator. Page counts
sum per-order counts and percentages are weighted across contributing items.
This distribution can differ from the matching progress counts, which include
rows that failed conversion. Empty summaries leave its counts and percentages
initial. `contributing_progress_qty` reports order, received, open, and
over-receipt base-unit totals for the not-started, partial, complete,
over-received, and invalid groups. Sums across these groups reconcile with the
overall totals, subject to decfloat34 rounding; page groups sum per-order
groups. The invalid group is normally empty because invalid raw-progress items
do not contribute; it captures an unexpected status on a contributing row.
Empty summaries leave these groups initial. Each group also reports
`order_qty_total_share_pct`, `received_qty_total_share_pct`,
`open_qty_total_share_pct`, and `over_rcpt_qty_total_share_pct` as shares of the
corresponding overall totals. Page shares use aggregated page totals. A share
uses only a positive denominator and remains initial when that total is zero;
shares sum to 100 before independent two-decimal rounding. Each summary also includes
`received_pct_of_order_qty`, `open_pct_of_order_qty`, and
`over_rcpt_pct_of_order_qty`, calculated from the aggregate totals and rounded
to two decimals. These are weighted ratios, not averages of item percentages;
empty summaries leave the percentages initial, and over-receipt-to-order
percentages may exceed 100. `over_rcpt_pct_of_received_qty` divides the
aggregate over-receipt total by aggregate received quantity; it is at most
100% for valid contributing quantities and remains initial when received
quantity is zero.
Status codes remain available when the logon-language text is missing.
Nonempty bulk results include a UTC `snapshot_timestamp` captured
after the item and status reads; empty input leaves it initial. The
finish-window-only `key_selection_timestamp` remains initial for this method. It
marks read completion and does not make the separate reads transactionally
consistent. SAP
documents active status reporting and the distinction between
system and user statuses
([active production-order statuses](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/a144fb0d4c4a48958e1c39451391db22.html?locale=en-US&source=redirect&state=PRODUCTION&version=2602.500),
[system and user status behavior](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/8e04b753128eb44ce10000000a174cb4.html)). SAP also documents production-order quantities and basic
dates in its manufacturing references
([production-order header and item](https://help.sap.com/saphelp_autoid2007/helpdata/en/89/6166370f5a2a68e10000009b38f8cf/content.htm?no_cache=true),
[AFPO quantity fields](https://help.sap.com/doc/419ffea5f9b6488da138a9b8d65d508b/3.15/en-US/Sample%20Content%20Process%20Mining%20on%20SAP%20S4HANA%20Production%20Planning.pdf)).
`READ_ORDERS_BY_FINISH_WINDOW` finds production or process orders for one
material and plant with an inclusive basic-finish-date range. Its returned
items include the same order-unit open and over-receipt quantities,
over-receipt percentage, receipt-progress percentages, and status as
`READ_ORDERS_BULK`. Its top-level
`receipt_progress_counts` summarizes every output item on returned orders.
Set `filter_receipt_progress_status` to `abap_true` and provide
`receipt_progress_status` to select orders with a matching material/plant item
in that receipt state before pagination: `N` for not started, `P` for partial,
`C` for complete, `O` for over-received, or blank for invalid quantities
(nonpositive AFPO-PSMNG or negative AFPO-WEMNG). With the flag set to
`abap_false`, the status field must be blank. The flag accepts only
`abap_true` or `abap_false`, and invalid selections fail before repository
reads. The service checks the selected state again against detail rows and
reports drift through `finish_filter_lost`; all output items on selected orders
remain in the result and contribute to the progress counts.
Each item exposes `matches_finish_selection` to identify detail rows
that still match the selected item scope after the detail read. Other items
remain in the result with the flag false; direct `READ_ORDERS_BULK` results
leave it initial. Active status is checked separately through
`status_filter_lost`.
Each finish-window order exposes `finish_window_match_count`, the
number of returned detail rows that still match the selected item scope. Direct
bulk reads leave this count at zero.
Set `filter_received_qty_from` and `filter_received_qty_to` to apply inclusive
lower and upper bounds to AFPO-WEMNG in the order unit before pagination. Either
bound can be used alone; zero is valid, negative bounds are rejected, and two
active bounds must be ascending. Inactive flags require initial values, both
flags accept only `abap_true` or `abap_false`, and detail reads recheck the
selected bounds against returned receipt quantities.
Optional inclusive `filter_over_receipt_qty_from` and
`filter_over_receipt_qty_to` bounds select `over_receipt_qty_order_unit` in the
AFPO order unit. Either bound can be used alone; active bounds must be
nonnegative, inactive values must be initial, and two active bounds must be
ordered. The key query requires valid receipt progress and applies the bounds
before pagination; valid items without an over-receipt have a zero quantity.
Detail reads recheck the calculated over-receipt quantity and its validity.
Set `filter_over_receipt_pct_from` and `filter_over_receipt_pct_to` for inclusive
bounds on the raw over-receipt-to-order quantity ratio as a percentage before
two-decimal display rounding. Either bound can be used alone; active values
must be nonnegative with no upper cap, inactive values must be initial, and two
active bounds must be ordered. A zero lower bound includes all valid receipt
progress, and upper bounds include valid items with no over-receipt at zero
percent. The key query applies the bounds before pagination, and detail reads
recheck the raw quantity ratio.
Set `filter_received_pct_from` and `filter_received_pct_to` to apply inclusive
bounds to the raw received-to-order quantity ratio as a percentage, before the
two-decimal display rounding. Either bound can be used alone; zero is valid,
negative bounds are rejected, disabled bounds require initial values, and two
active bounds must be ordered. An enabled percentage bound excludes items with
nonpositive order quantities or negative received quantities. The repository
applies these bounds before pagination, and detail reads check them again for
scope drift.
Set `filter_unreceived_pct_from` and `filter_unreceived_pct_to` to apply
inclusive bounds to the existing `open_pct_of_order_qty`, calculated from
positive remaining AFPO order quantity before two-decimal display rounding.
Either bound can be used alone; values must be from 0 through 100, disabled
values require initial values, and two active bounds must be ordered. Enabled
bounds exclude nonpositive order quantities and negative received quantities;
completed and over-received items have zero open percentage. The repository
applies these bounds before pagination, and detail reads check them again for
scope drift.
Set the optional `sales_order` to filter AFPO-KDAUF assignments before
pagination. Set
`filter_sales_order` to `abap_true` to match exactly, including blank; the flag
accepts only `abap_true` or `abap_false`, and a nonblank sales order filters
when the flag is false. Returned items expose `sales_order`, and detail reads
check the selected value for drift. Set the optional
`sales_order_item` to filter AFPO-KDPOS before pagination. Set
`filter_sales_order_item` to `abap_true` to match exactly, including blank; the
flag accepts only `abap_true` or `abap_false`, and a nonblank item filters when
the flag is false. Returned items expose `sales_order_item`, and detail reads
check it for drift. Set the optional `sales_order_schedule_line` to filter
AFPO-KDEIN before pagination. Set `filter_sales_schedule_line` to `abap_true`
to match exactly, including blank; the flag accepts only `abap_true` or
`abap_false`, and a nonblank schedule line filters when the flag is false.
Returned items expose the sales-order schedule line, and detail reads check it
for drift. Set the optional `planned_order` to filter AFPO-PLNUM before
pagination. Set `filter_planned_order` to `abap_true` to match exactly, including
blank; the flag accepts only `abap_true` or `abap_false`, and a nonblank planned-
order number filters when the flag is false. Returned items expose
`planned_order`, and detail reads check it for drift. Set the optional
`planning_plant` to filter AFPO-PWERK before pagination; `plant` continues to
filter the production plant in AFPO-WERKS. Set `filter_planning_plant` to
`abap_true` to match exactly, including blank; the flag accepts only `abap_true`
or `abap_false`, and a nonblank planning plant filters when the flag is false.
Returned items expose `planning_plant`, and detail reads check it for drift.
Set the optional `delivery_plant` to filter AFPO-DWERK before pagination.
Set `filter_delivery_plant` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank delivery
plant filters when the flag is false. Returned items expose `delivery_plant`,
and detail reads check it for drift. Set the optional `special_stock_indicator`
to filter AFPO-SOBKZ before pagination. Set `filter_special_stock` to
`abap_true` to match exactly, including blank; the flag accepts only `abap_true`
or `abap_false`, and a nonblank indicator filters when the flag is false.
Returned items expose `special_stock_indicator`, and detail reads check it for
drift. Set the optional `stock_type` to filter AFPO-INSMK before pagination.
Set `filter_stock_type` to `abap_true` to match exactly, including blank; the
flag accepts only `abap_true` or `abap_false`, and a nonblank stock type
filters when the flag is false. Returned items expose `stock_type`, and detail
reads check it for drift. Set the optional `goods_recipient` to filter
AFPO-WEMPF before pagination. Set `filter_goods_recipient` to `abap_true` to
match exactly, including blank; the flag accepts only `abap_true` or
`abap_false`, and a nonblank recipient filters when the flag is false. Returned
items expose `goods_recipient`, and detail reads check it for drift. Set the
optional `unloading_point` to filter AFPO-ABLAD before pagination.
Set `filter_unloading_point` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank point filters
when the flag is false. Returned items expose `unloading_point`, and detail
reads check it for drift. Set the optional `production_version` to filter
AFPO-VERID before pagination.
Set `filter_production_version` to `abap_true` to match exactly, including
blank; the flag accepts only `abap_true` or `abap_false`, and a nonblank
production version filters when the flag is false. Returned items expose
`production_version`, and detail reads check it for drift. Set the optional
`planned_order_start_date` to filter AFPO-STRMP before pagination.
Set `filter_plan_start_date` to `abap_true` to match exactly,
including blank; the flag accepts only `abap_true` or `abap_false`, and a
nonblank date filters when the flag is false. Nonblank dates must be valid.
Returned items expose the planned-order start date, and detail reads check it
for drift. Set `storage_location` to select AFPO-LGORT before pagination. Set
`filter_storage_location` to `abap_true` to match exactly, including blank; the
flag accepts only `abap_true` or `abap_false`, and a nonblank location filters
when the flag is false. Returned items expose `storage_location`, and detail
reads check it for drift. Set the optional `batch` to filter AFPO-CHARG before
pagination. Set `filter_batch` to
`abap_true` to match exactly, including blank; the flag accepts only
`abap_true` or `abap_false`, and a nonblank batch filters when the flag is false.
Returned items expose `batch`, and detail reads check it for drift. Set the
optional `account_assignment_category` to filter AFPO-KNTTP before pagination.
Set `filter_assignment_category` to `abap_true` to match exactly,
including blank; the flag accepts only `abap_true` or `abap_false`, and a
nonblank category filters when the flag is false. Returned items expose
`account_assignment_category`, and detail reads check it for drift. Set the
optional `mrp_area` to filter AFPO-BERID before pagination. Set `filter_mrp_area`
to `abap_true` to match exactly, including blank; the flag accepts only
`abap_true` or `abap_false`, and a nonblank area filters when the flag is false.
Returned items expose `mrp_area`, and detail reads check it for drift. Set the
optional `wbs_element` to filter the AFPO-PROJN assignment by external
PRPS-POSID before pagination. Set `filter_wbs_element` to `abap_true` to match
exactly, including blank; blank selects items without an AFPO-PROJN assignment.
The flag accepts only `abap_true` or `abap_false`, and a nonblank WBS element
filters when the flag is false. Returned items expose the
external `wbs_element` and original `wbs_element_internal_id`; detail reads
check the external assignment for drift. Set both optional
`basic_start_date_from` and `basic_start_date_to` to constrain basic
start dates;
partial, invalid, or reversed bounds fail before repository reads. The repository
applies this filter before pagination. Set `filter_basic_start_date` to
`abap_true` to match the exact `basic_start_date`, including blank; a nonblank
date filters when the flag is false. The flag accepts only `abap_true` or
`abap_false`, and nonblank dates must be valid. The exact selector intersects
with the basic-start-date range, and returned keys and detail items are checked
against both. Both optional
`scheduled_start_date_from` and `scheduled_start_date_to` bounds filter the
inclusive AFKO-GSTRS scheduled-start-date range; both valid ascending dates are
required, and the range applies before pagination and during key and detail-read
scope checks. The result order and cursor continue to use basic finish dates.
Both optional
`scheduled_finish_date_from` and `scheduled_finish_date_to` bounds filter the
inclusive AFKO-GLTRS scheduled-finish-date range; both valid ascending dates are
required, and the range applies before pagination and during key and detail-read
scope checks. The result order and cursor continue to use basic finish dates.
Set `filter_scheduled_start_date` to `abap_true` to match the exact
`scheduled_start_date`, including blank; a nonblank date filters when the flag
is false. `filter_scheduled_finish_date` and `scheduled_finish_date` provide
the same exact-date behavior for AFKO-GLTRS. Both flags accept only
`abap_true` or `abap_false`, and nonblank dates must be valid. Exact-date and
scheduled-date range filters intersect, and returned keys and detail items are
checked against both filters.
Set `filter_scheduled_start_time` and `filter_scheduled_finish_time` to
`abap_true` to filter inclusive time-of-day ranges on AFKO-GSUZS and AFKO-GLUZS.
Each enabled filter requires two valid ascending times; `000000` is a valid
midnight bound. Both flags accept only `abap_true` or `abap_false`, and disabled
filters require initial bounds. The ranges apply before pagination and are
checked against returned keys and detail items. They apply on every matching
date and do not wrap across midnight. The result order and cursor remain based
on basic finish dates. An optional nonblank `production_item`
matches the exact AFPO-POSNR before pagination. Matching orders still return all
their items, and the detail-read drift check verifies that the selected item
remains present. An optional nonblank `order_unit` filters the exact AFPO-AMEIN
value before pagination and participates in detail-read drift checks. The
order-quantity bounds use this AFPO order unit. Set the optional `order_category`
to `10` for production orders or `40` for process orders; when
omitted, both categories are included. It returns the same item quantities and
active statuses as the number-based bulk read, and retains all items on each
matching production order. Each item also exposes scheduled start and finish
dates from AFKO-GSTRS and AFKO-GLTRS, and their time-of-day values from
AFKO-GSUZS and AFKO-GLUZS. The requested window, sort order, and cursor continue
to use basic finish dates. The optional
nonblank `order_type` filters on the
exact AUFK-AUART value before pagination; the later detail read checks it as
part of `finish_filter_lost`. Both `created_date_from` and `created_date_to`
filter the inclusive AUFK-ERDAT order-creation-date range; both valid ascending
dates are required, and returned items expose `created_date` for drift checks.
The optional nonblank `order_description` filters on the exact AUFK-KTEXT short
description before pagination and returns it on each item. Set
`filter_order_description` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank description
filters when the flag is false. The detail-read drift check includes this
selection.
The optional nonblank `order_created_by` filters on AUFK-ERNAM before
pagination, is returned on each item, and participates in drift checks. Set
`filter_order_created_by` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank creator
filters when the flag is false.
The optional nonblank `order_changed_by` filters on AUFK-AENAM before
pagination, is returned on each item, and participates in drift checks. Set
`filter_order_changed_by` to `abap_true` to match exactly, including blank; the
flag accepts only `abap_true` or `abap_false`, and a nonblank changer filters
when the flag is false. Both `changed_date_from` and `changed_date_to` filter
the inclusive AUFK-AEDAT
change-date range; both valid ascending dates are required, and returned items
expose `changed_date` for drift checks.
Set `exclude_deleted` to `abap_true` to require
blank AUFK-LOEKZ and AFPO-XLOEK indicators on the matching order and item; this
filter also applies before pagination and is checked for detail-read drift.
Set `receipt_expected_only` or `receipt_not_expected_only` to select marked or
blank AFPO-WEPOS values. `delivery_complete_only` and
`delivery_not_complete_only` select marked or blank AFPO-ELIKZ values. Each
selector applies before pagination and during drift checks; opposite selectors
for one indicator cannot both be true.
Set `required_phase` to `1`, `2`, or `3` to require the matching AUFK phase
indicator. Other nonblank values are rejected, and the phase is checked again
after the detail read.
Set `unreceived_quantity_only` to `abap_true` to
keep orders with positive `AFPO-PSMNG - AFPO-WEMNG` for the selected material
and plant. The quantities compare in the AFPO order unit, before pagination;
when false, the filter is disabled. Optional inclusive
`filter_unreceived_qty_from` / `unreceived_qty_from` and
`filter_unreceived_qty_to` / `unreceived_qty_to` pairs bound the positive
remaining quantity in the AFPO order unit. An enabled bound must be positive;
disabled bound values must be initial; when both are enabled, the lower bound
must not exceed the upper bound. These bounds apply before pagination. If the
later detail read has no item matching the remaining-quantity scope,
`finish_filter_lost` reports the drift. Optional inclusive
`filter_order_qty_from` / `order_qty_from` and
`filter_order_qty_to` / `order_qty_to` pairs bound `AFPO-PSMNG` in the AFPO
order unit. Enabled bounds must be positive; disabled values must be initial;
when both are enabled, the lower bound cannot exceed the upper bound. These
filters apply before pagination and participate in `finish_filter_lost` checks.
Optional inclusive `filter_order_qty_base_from` / `order_qty_base_from` and
`filter_order_qty_base_to` / `order_qty_base_to` pairs bound
`order_quantity_base` in the material base unit. Either bound can be used
alone; active values must be nonnegative, inactive values must be initial, and
two active bounds must be ordered. The repository applies them before
pagination using the AFPO order-to-base ratio, and rows without a valid
conversion cannot match. The detail-read drift check rechecks the converted
quantity and its conversion status.
Optional inclusive `filter_received_qty_base_from` /
`received_qty_base_from` and `filter_received_qty_base_to` /
`received_qty_base_to` pairs bound `received_quantity_base` in the material
base unit. Either bound can be used alone; active values must be nonnegative,
inactive values must be initial, and two active bounds must be ordered. The
repository applies them before pagination using the AFPO order-to-base ratio
and requires a successful quantity conversion. The detail-read drift check
rechecks the converted received quantity and its conversion status.
Optional inclusive `filter_over_rcpt_qty_base_from` and
`filter_over_rcpt_qty_base_to` bounds select `over_receipt_quantity_base` in
the material base unit. Either bound may be used alone; active values must be
nonnegative, inactive values must be initial, and two active bounds must be
ordered. Zero includes valid items without receipt excess. The repository
compares the positive excess and AFPO order-to-base ratio before pagination and
requires valid receipt progress and successful quantity conversion. Detail
reads recheck the converted excess and both statuses.
Optional inclusive `filter_unrecv_qty_base_from` /
`unrecv_qty_base_from` and `filter_unrecv_qty_base_to` /
`unrecv_qty_base_to` pairs bound `open_quantity_base` in the material base
unit. Either bound can be used alone; active values must be positive because
only positive remaining quantities qualify, inactive values must be initial,
and two active bounds must be ordered. The repository compares the AFPO
remaining quantity and order-to-base ratio before pagination and requires a
successful conversion. The detail-read drift check rechecks the converted open
quantity and its conversion status.
Results sort by finish
date and production-order number, return at most `maximum_results` (1 through
500), and set `is_truncated` when another matching order exists. Set the
optional `active_status_code` to require that exact currently active SAP system
or user status. Results still include all active statuses for each matching
order. Since detail/status reads happen later, `status_filter_lost` flags
a returned order when the requested status is no longer active;
`status_filter_lost_count` summarizes those orders. Changed orders remain
in the result for reconciliation. `active_status_codes` can select several
currently active SAP system or user statuses; at least one listed code must be
active. Use either this list or `active_status_code`, not both, and do not
include blank codes. The detail/status recheck flags `status_filter_lost` when
none of the selected codes remains active. After the detail read,
`finish_filter_lost`
marks an order if no returned item still matches its selected material,
production plant, planning and delivery plants, item number, category, order
type and description, order unit, sales-order assignment/item/schedule line,
planned-order reference and start date, production version, special-stock
indicator, stock type, goods recipient, unloading point, storage location,
batch, account-assignment category, MRP area, WBS assignment, order-quantity
and base-unit quantity bounds, received-quantity and over-receipt quantity
bounds, received-base-unit and over-receipt-base-unit quantity bounds,
received-percentage bounds,
unreceived-quantity and unreceived-base-unit quantity bounds,
unreceived-percentage bounds, and
receipt-progress state, order creator and
changer, creation and change-date ranges, required phase, deletion,
receipt-expected state, delivery-completion state, basic finish/start dates, and
scheduled start/finish dates and time ranges. `finish_filter_lost_count`
summarizes those rows.
This is separate from status drift. When truncated, the result's `next_finish_date` and
`next_production_order` form a cursor; pass both back as `after_finish_date`
and `after_order` to continue through orders that share a finish date. Partial
or out-of-range cursors and invalid selections are rejected before any
repository read. The service validates the returned key count, sort order, finish-date and
start-date ranges, cursor boundary, and unique nonblank order numbers before
reading details. Each result includes a UTC `key_selection_timestamp` for the
matching-key query and a UTC `snapshot_timestamp` after the later detail and
status reads, including when no keys match. These timestamps show the read gap;
they do not make the separate reads or later pages transactionally consistent,
and the query does not lock orders between pages.
`SEARCH_CONFIRMATIONS_BY_WINDOW` searches production and process-order
confirmations for orders containing one material at one plant, over an
inclusive posting-date range. An optional `production_order` restricts results
to one production or process order within the material and plant scope. An
optional `order_category` accepts `10` for production orders or `40` for process
orders, and each confirmation row reports its category. An optional nonblank
`order_type` filters the AUFK order type exactly. Set
`filter_order_type` to `abap_true` to match the exact value including blank;
otherwise it must be `abap_false`, and a nonblank type filters by default.
Each confirmation row reports `AUFK-AUART`, and the service checks the
selected type before returning the page. Set `exclude_deleted` to
`abap_true` to omit confirmations unless both AUFK-LOEKZ and the matching
AFPO-XLOEK are blank; the flag accepts only `abap_true` or `abap_false`
and defaults to false. Rows expose `order_deletion_indicator` from
AUFK-LOEKZ, which the service validates against the selected scope.
`operation_counter` can filter one AFVC internal operation counter and
requires `production_order`.
Optional `operation_counter_from` and `operation_counter_to` bounds filter
AFVC-APLZL inclusively before pagination; either bound can be omitted, paired
bounds must ascend, and active bounds require `production_order`. The exact
counter selector intersects with the range, and the service checks returned
rows against both bounds. Set `operation_number` to restrict results to one
routing operation. Optional
`operation_number_from` and `operation_number_to` bounds filter AFVC-VORNR
inclusively before pagination; either bound can be omitted, and paired bounds
must ascend. The exact operation selector intersects with the range, and the
service checks returned rows against both bounds. Noninitial
`operation_sequence` can restrict results to one routing sequence alone or
alongside an operation number. Optional `operation_sequence_from` and
`operation_sequence_to` bounds filter AFVC-PLNFL inclusively before pagination;
either bound can be omitted, paired bounds must ascend, and the exact sequence
selector intersects with the range. The service checks returned rows against
both bounds. Set `filter_operation_sequence` to `abap_true` to match the exact
sequence including its initial value; otherwise
it must be `abap_false`, and a noninitial value still filters. Invalid flag
values fail before the read, and returned rows are checked against the selected
sequence. An optional nonblank `resource_object_id` filters `AFVC-ARBID`, and
confirmation rows return the same field. An optional nonblank `work_center`
filters CRHD-ARBPL through the AFVC-ARBID / CRHD-OBJID link. Confirmation
rows and operation summaries expose the matching work-center code, and the
service checks the returned scope. Base-unit operation summaries preserve the
code as well. An optional nonblank `work_center_plant` filters `CRHD-WERKS`,
and matching confirmations and operation summaries report the assigned plant.
Set `filter_work_center_plant` to `abap_true` with a blank
`work_center_plant` to select operations without a resolved work-center plant.
This selector intersects with `work_center`, applies before pagination, and is
validated against returned rows. Its flag accepts only `abap_true` or
`abap_false`; base-unit operation summaries preserve the plant too.
`work_center_summaries` is also returned on each page, grouped by plant and
code. Blank assignments form a group; `confirmation_count` covers only
returned confirmations, sums to `returned_count`, and excludes the lookahead
row and later pages. Each center's `quantity_summaries` separates totals by
confirmation unit (`AFRU-MEINH`), with per-unit `confirmation_count` and gross
`yield_quantity_total`, `rework_quantity_total`, and `scrap_quantity_total`.
`yield_non_reversed_total`, `rework_non_reversed_total`, and
`scrap_non_reversed_total` omit rows flagged as reversed, and per-unit counts
sum to the center count. Work-center groups also expose `first_posting_date`,
`last_posting_date`, final, partial, and reversed counts and percentages. Final
and partial counts partition `confirmation_count`; reversed count is
independent, and percentages use `confirmation_count` as their denominator.
The base-unit window result also returns
`base_work_center_summaries`, grouped by plant, code, and base unit. Each row
includes `confirmation_count`, `yield_quantity_base_total`,
`rework_quantity_base_total`, `scrap_quantity_base_total`,
`yield_base_non_reversed_total`, `rework_base_non_reversed_total`, and
`scrap_base_non_reversed_total`. They also include `first_posting_date`,
`last_posting_date`, `final_confirmation_count`,
`partial_confirmation_count`, `reversed_confirmation_count`,
`final_confirmation_pct`, `partial_confirmation_pct`, and
`reversed_confirmation_pct`. Set
`filter_resource_object_id` to
`abap_true` to match the exact initial ID, including operations without an
assigned resource. Otherwise the flag must be `abap_false`, and a nonblank ID
filters by default. The service checks the flag and returned resource scope.
`AFVC-ARBID` is an SAP-internal object ID. For work-center assignments,
`CRHD-OBJID` identifies the same object and `CRHD-ARBPL` contains the
work-center identifier. Set `filter_work_center` to `abap_true` with a blank
`work_center` to select operations without a resolved work-center code. The
flag accepts only `abap_true` or `abap_false`; otherwise a nonblank code filters
by default. The repository applies this selector before pagination, and the
service checks the returned scope. A nonblank `operation_suboperation` filters
one suboperation and requires `operation_number`. By default, an initial
suboperation value includes the base step and all suboperations. Set
`filter_operation_suboperation` to
`abap_true` to match the exact initial value, selecting only the base step; this
flag also requires `operation_number`. Otherwise the flag must be `abap_false`,
and a nonblank suboperation continues to filter. Optional `operation_suboperation_from` and
`operation_suboperation_to` bounds filter AFVC-UVORN inclusively before
pagination; either bound can be omitted, paired bounds must ascend, and active
bounds require `operation_number`. The exact suboperation selector intersects
with the range, and returned rows are checked against both bounds. Invalid
flags and ranges fail before the read.
An optional nonblank `control_key` filters by the AFVC routing control key and
can be combined with or used without the operation filters. Set
`filter_control_key` to `abap_true` to match the exact key including blank;
otherwise it must be `abap_false`, and a nonblank key continues to filter.
Invalid flag values fail before the read and returned rows are checked against
the selected key. Pass `operation_description` to match exact AFVC-LTXA1
operation text. Nonblank text filters by default; set
`filter_operation_description` to `abap_true` to select the exact blank text.
Otherwise the flag must be `abap_false`. Invalid flags fail before the read,
the description filter applies before pagination, and returned rows are checked
against the selected description. An optional
nonblank `quantity_unit` restricts rows to one AFRU confirmation unit; when
initial, it omits the filter by default. Set `filter_quantity_unit` to
`abap_true` to match the exact unit including blank; otherwise it must be
`abap_false`, and a nonblank unit continues to filter. Invalid flag values fail
before the read and returned rows are checked against the selected unit. With
no unit filter, results can contain multiple units and summaries keep them
separate. An optional nonblank `entered_by` filters confirmations by AFRU-ERNAM.
Set `filter_entered_by` to `abap_true` to match the exact user including blank;
otherwise it must be `abap_false`, and a nonblank value continues to filter.
Invalid flag values fail before the read, and returned rows are checked against
the selected user. Confirmation rows expose this user as `entered_by`. The
optional `entry_date_from` and `entry_date_to` pair filters AFRU-ERSDA
inclusively before pagination; provide both valid dates in ascending order or
omit both. Returned rows expose `entry_date`, and the service checks it against
the selected range. This entry date identifies when the confirmation was
entered, separately from its posting date. The optional
`last_change_date_from` and `last_change_date_to` pair filters AFRU-LAEDA
inclusively before pagination; provide both valid dates in ascending order or
omit both. Returned rows expose `last_change_date`, checked against that range,
and `changed_by` from AFRU-AENAM. Optional `execution_start_date_from` and
`execution_start_date_to` bounds filter AFRU-ISDD inclusively before paging.
Either bound may be omitted, each active bound must be a valid date, and paired
bounds must ascend. Active bounds omit confirmations without an actual start
date, and returned rows are checked against the selected range. Optional
`filter_execution_start_time` requires both valid `execution_start_time_from`
and `execution_start_time_to` bounds and filters AFRU-ISDZ inclusively across
matching dates. A nonblank start date is required; `000000` is a valid
midnight bound. Bounds must ascend. When disabled, the flag must be
`abap_false` and both bounds must be initial. Optional
`execution_finish_date_from` and
`execution_finish_date_to` bounds filter AFRU-IEDD inclusively before paging.
Either bound may be omitted, each active bound must be a valid date, and paired
bounds must ascend. Active bounds omit confirmations without an actual finish
date. Rows also expose AFRU-ISDD, AFRU-ISDZ, AFRU-IEDD, and AFRU-IEDZ as
`execution_start_date`, `execution_start_time`, `execution_finish_date`, and
`execution_finish_time`. `filter_execution_finish_time` requires both valid
`execution_finish_time_from` and `execution_finish_time_to` bounds and filters
AFRU-IEDZ inclusively across matching dates. A nonblank finish date is
required; `000000` is a valid midnight bound. Bounds must ascend. When
disabled, the flag must be `abap_false` and both bounds must be initial.
A nonblank `changed_by` filters by default;
`filter_changed_by` enables exact matching including blank. Otherwise the flag
must be `abap_false`, and returned rows are checked against the selected user.
`filter_entry_time` enables an inclusive AFRU-ERZET time-of-day range; both
valid ascending bounds are required, and `000000` is a valid midnight bound.
Disabled filters require initial bounds. The range applies on every matching
entry date, combines with the entry-date range, and does not wrap across
midnight. Rows expose `entry_time`, checked against the selected range.
`positive_yield_only`, `positive_rework_only`, and `positive_scrap_only` select
rows whose corresponding AFRU quantity is greater than zero; when multiple
flags are true, every selected quantity must be positive. An optional
`filter_yield_quantity_from` / `filter_yield_quantity_to`,
`filter_rework_quantity_from` / `filter_rework_quantity_to`, and
`filter_scrap_quantity_from` / `filter_scrap_quantity_to` select inclusive raw
ranges over `AFRU-LMNGA`, `AFRU-RMNGA`, and `AFRU-XMNGA` before pagination.
These raw quantity bounds require a single confirmation unit scope: provide a
nonblank `quantity_unit` or set `filter_quantity_unit` to `abap_true` to select
an exact unit, including blank. This keeps raw values from different units out
of one numeric range. Either bound can be active alone, including a zero
endpoint;
inactive values must be initial, and two active bounds must be ascending. The
service validates the range on returned rows. An optional
`confirmation_number` restricts results to one AFRU confirmation;
`confirmation_counter` narrows that selection to one counter and requires a
confirmation number. Optional `confirmation_counter_from` and
`confirmation_counter_to` bounds filter AFRU-RMZHL inclusively before
pagination; either bound can be omitted, paired bounds must ascend, and active
bounds require `confirmation_number`. The exact counter selector intersects
with the range, and returned rows are checked against both bounds.
By default, an initial `operation_suboperation` includes the operation's base
step and all its suboperations. Set `filter_operation_suboperation` to
`abap_true` to match the exact initial value, selecting only the base step; this
flag also requires `operation_number`. Otherwise the flag must be
`abap_false`, and a nonblank suboperation continues to filter. Invalid flag
values fail before the read, and returned rows are checked against the selected
suboperation. Results
sort by posting date, production-order
number, confirmation number, and confirmation counter. The caller sets
`maximum_results` from 1 through 500; `is_truncated` indicates an additional
row, and the four `next_*` fields form the continuation cursor. By default,
final and partial confirmations are both returned. Set `final_only` to
`abap_true` to return only confirmations marked final. Set `partial_only` to
`abap_true` to return only confirmations not marked final; `final_only` and
`partial_only` cannot both be true. Reversed confirmations remain in the result
with `is_reversed` set by default. Set
`exclude_reversed` to `abap_true` to omit them when only non-reversed rows are
needed. Set `reversed_only` to `abap_true` to return only reversed rows; it
cannot be combined with `exclude_reversed`. Partial cursors, invalid flags, and
invalid selections are rejected
before repository reads. Each result includes a UTC `snapshot_timestamp`,
captured when the repository read returns; the base-unit wrapper preserves it
in its raw result. This marks read completion and does not make the read
transactionally consistent, so later pages can reflect a different state.
Each row also includes its AFVC operation counter,
operation subnumber, sequence, description, control key, and order category.
Window-search rows echo `scope_material` and `scope_plant` from the matching
AFPO item; the service checks both against the required selection. Number-based
bulk confirmation reads leave these two scope fields initial because they do
not have a material/plant search scope.
Each page is a separate point-in-time
read, so concurrent postings can change later pages. Each response also contains
`operation_summaries`, grouped by AFVC operation counter, operation number,
sequence, suboperation, and confirmation unit within each production order.
Summaries echo the order category and AUFK-AUART `order_type`, and include
`confirmation_count`,
`final_confirmation_count`, `partial_confirmation_count`, and
`reversed_confirmation_count`, plus the operation description and control key.
Each operation summary also reports `resource_object_id`, the assigned AFVC
resource ID. Base operation summaries retain it when merging source units.
Partial counts include confirmations whose `is_final` is not `abap_true`; final
and partial counts partition the returned rows, while reversed counts overlap
them. Each summary also reports `final_confirmation_pct`,
`partial_confirmation_pct`, and `reversed_confirmation_pct`, calculated over
`confirmation_count` and rounded to two decimal places. Final and partial
percentages may differ from 100.00 by 0.01 due to independent rounding;
reversed percentage is an overlapping share. Each summary also includes
`first_posting_date` and
`last_posting_date`, plus raw yield, rework, and scrap totals and corresponding
non-reversed totals in that unit. The latter are
`yield_non_reversed_total`, `rework_non_reversed_total`, and
`scrap_non_reversed_total`. Raw totals include reversed rows; non-reversed
totals include only returned rows whose `is_reversed` is not `abap_true`.
Each operation summary also reports its execution-start and execution-finish
counts and percentages, first-start and last-finish date/time pairs, valid and
invalid duration counts, and total elapsed seconds. Duration totals include
reversed confirmations. All summary fields cover only the returned page; the
lookahead row and later pages are excluded.
The same page also contains `order_summaries`, grouped by production order and
confirmation unit. Quantities in different units stay separate. Each summary
reports order category, date span, `confirmation_count`,
`final_confirmation_count`, `partial_confirmation_count`, and
`reversed_confirmation_count`, plus yield, rework, and scrap totals with and without
reversed rows. These summaries derive from the returned operation summaries
and reconcile within each order/unit. They also report execution coverage and
span fields, valid and invalid duration counts, and total elapsed seconds for
all returned rows in the group. They exclude the lookahead row and later pages.
`SEARCH_CONF_WINDOW_BASE_UNIT` returns the same paged search result plus one
base-quantity row per returned confirmation. Each row keeps the original
confirmation and reports yield, rework, and scrap converted from its AFRU
confirmation unit to the selected material's base unit. Conversion ratios are
cached per unit for the call; an unknown ratio, overflow, or nonzero quantity
that rounds to zero raises `zcx_invalid_stock_request` without returning a
partial result. Operation summaries remain in their original confirmation
units, as in the raw search result. `base_operation_summaries` merges those
operation/unit groups and totals their converted quantities in base units. It
retains the operation identity, order category, date span, and the four
confirmation counts used by the raw summaries. It also keeps separate totals
that include or exclude reversed confirmations and provides the same execution
coverage, span, and duration metrics.
`base_order_summaries` also groups converted quantities by production order
and base unit, merging source confirmation units and operations. They expose
the same four confirmation counts and execution metrics and keep
reversed-inclusive and non-reversed totals separate. Operation and order
summaries in both unit modes also include the same three two-decimal percentages over
`confirmation_count`.
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
`RETURN_COMPONENTS_IN_UNIT` and `RETURN_COMPONENTS_BULK_IN_UNIT` accept an
alternative material unit per line, convert all quantities to the reservation
unit, and validate the full request before posting one reversal movement.
`PREVIEW_RETURNABLE_COMPONENTS` lists withdrawn quantities for explicit
production-order/reservation/item keys, including items with no open quantity.
Its open quantity is calculated through the shared packed-quantity helper and
clamped to zero when withdrawals exceed the required quantity; the original
required and withdrawn amounts remain available for reconciliation.
`RETURN_REMAINING_COMPONENTS` returns the full withdrawn balance for those keys
after a second repository read and posts the selected reversals in one material
document. It rejects duplicate keys and invalid simulation flags before reads.
`RETURN_REMAINING_BULK` uses the same preview but posts one reservation at a
time, returning per-reservation results and continuing after a failed group.
Each group is re-read against its production order before the reversal; earlier
reservation commits remain if a later group fails. Its top-level `is_committed`
reports whether any reservation group committed. `RETURN_REMAINING_BULK` also
accepts `iv_stop_on_failure`, defaulting to `abap_false`; when enabled, the
first failed group stops later reversals, marks unattempted rows `is_skipped`,
and reports `skipped_count` separately from `failed_count`.
`CANCEL_COMPONENT_ISSUE` reverses a committed issue by calling
`BAPI_GOODSMVT_CANCEL` with its material document and fiscal year. Pass item
numbers to reverse only selected document lines; omit them to cancel the whole
document. SAP posts the corresponding reversal (261 issues reverse as 262).
This cancels full document lines. The method has no test-run mode. Use the
material document returned by the component issue call and let SAP validate
whether it is still reversible
([261-to-262 reversal](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/cc86c401ad5c40e1a09a6b5e49672b8d.html),
[goods movement BAPI guidance](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
`CANCEL_COMPONENT_ISSUES_BULK` accepts multiple issue material documents and
preserves per-document item selections and posting dates. It exposes the same
independent-commit and atomic LUW options as the generic bulk cancellation,
including `iv_stop_on_failure` to skip later documents after the first failed
reversal.
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
confirm an individual production reservation through this grouped request. Each
row exposes `is_fully_confirmed`, true when a relevant ATP check fully confirms
that component's incremental quantity. It remains false when ATP checking is
disabled or the check is not relevant.
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
The ATP preview's local estimate remains plant-level by default. Pass
`it_projected_batch_receipts` and/or `it_projected_location_receipts` to
`PREVIEW_COMPONENTS_ATP` or its bulk variant to use the scoped local allocator
with caller-assigned receipts. These options cannot be combined with the
SAP-derived local receipt flags above. The SAP ATP
request remains cumulative by material, plant, unit, and date; it does not
receive the local batch or location assignments and cannot confirm them.
When components have batch or location assignments, the local stock and ATP
previews can use SAP-derived standard PO or confirmation-aware PO receipts,
issued or unissued STO, scheduling-agreement, production-order, PR, STO PR, and
planned-order receipts when every selected row for that material/plant pair has
a receiving location. A row without a location sends only its material/plant
pair through the plant-level estimate; other pairs can remain scoped.
`iv_include_po_receipts` and `iv_include_po_confirmations` are mutually
exclusive. Standard PO, STO, and scheduling-agreement rows use the purchasing
item's `EKPO-LGORT` and schedule-line batch `EKET-CHARG`. Confirmation-aware PO
schedule remainder rows use those same fields; supplier-confirmation rows use
`EKPO-LGORT` and `EKES-CHARG`. Production-order rows use `AFPO-LGORT` and
`AFPO-CHARG`; PR and STO PR rows use `EBAN-LGORT`; planned and fixed
planned-order rows use `PLAF-LGORT`. SAP documents the assigned location and
batch for production-order items, and the location fields for requisitions and
planned orders ([production-order item
CDS](https://help.sap.com/docs/PRODUCT_ID/8308e6d301d54584a33cd04a9861bc52/9ecb6ea8a220445aa21a0435fafca571.html?locale=en-US),
[purchase requisition field catalog](https://help.sap.com/saphelp_aii710/helpdata/en/a3/9857a130f74936ae53aed874867dc3/content.htm?no_cache=true),
[planned-order field catalog](https://help.sap.com/docs/signavio-process-insights/administration-guide/be4b0a35f6d048eb979899f569509c78.html)).
Each material/plant receipt read is capped at that pair's latest component
required date.
If a selected receipt has no location, only that material/plant pair uses the
plant-level estimate. Enabling outgoing-STO subtraction uses the plant-level
estimate for every pair. The SAP ATP request remains plant-level in either
case.
`PREVIEW_COMPONENTS_STOCK` and `PREVIEW_COMPONENTS_STOCK_BULK` return the same
local date-group and per-component estimates without requiring an ATP checking
rule or calling the availability API. In those results, ATP confirmation
quantities and the raw ATP result remain initial.
The local estimate removes the selected components' own open reservation items
from the `RESB` deduction before allocating the component requirements. Other
active reservations remain deducted, and each selected component is charged once
by the local allocation.
All six component preview methods also accept call-wide
`it_excluded_reservations` keys to omit additional active standard-stock
reservation items from local stock netting. Keys must have a reservation number
and item, and must be unique; keys that match selected components are merged
once. This changes only the local estimate. In ATP previews, SAP's ATP result
continues to follow the supplied checking rule.
`PREVIEW_SCOPED_COMPONENTS` and `PREVIEW_SCOPED_COMPONENTS_BULK` provide an
explicit current-stock estimate that honors each open component's assigned
`RESB-LGORT` and/or `RESB-CHARG`. `PREVIEW_COMPONENTS_STOCK` selects this
allocation automatically when any component has a scope and no projected receipt
options are enabled. Quantities are converted to the material base unit. Overflow and nonzero reservation quantities that round to zero at MARD-LABST precision raise ZCX_INVALID_STOCK_REQUEST before stock is read. The
allocator processes earlier required dates first, then gives batch-and-location
and batch-only demands priority over location-only and unscoped demands.
Within each required-date and scope rank, higher integer `priority` values
allocate first and input order breaks ties. Direct `ALLOCATE_COMPONENT_STOCK`
callers can set `priority`, `require_full_quantity`, `minimum_coverage_pct`,
`allow_location_fallback`, `allow_batch_fallback`, `minimum_shelf_life_days`, and
`require_known_expiry` per demand. Production component previews expose these
controls through reservation-keyed allocation policies. `ALLOCATE_COMPONENT_STOCK`
also accepts `it_excluded_reservations`; complete unique keys are validated
before stock reads and omitted from competing open RESB events. Component
reservation keys are merged with these call-wide exclusions once, while
duplicate component demand keys remain invalid. Direct callers may
also pass `it_storage_location_priority` to order fallback locations for all
fallback-enabled demands in the request, or `it_request_location_priorities` to
override that order for individual request IDs. `it_request_batch_priorities`
can assign positive ranks to alternate batches for one fallback-enabled
request. The preferred batch remains first; FEFO expiry order remains primary,
and local ranks break ties among batches with equal expiry. Within such a tie,
lower ranks precede higher ranks, then unranked batches; rank ties and unranked
batches use batch code. A request's local rows override batch-code ordering
only within equal expiries. Preferred-batch rows, unknown requests, requests
without batch fallback, blank batches, nonpositive ranks, and duplicate
request/batch rows are rejected. These ranks order candidates without
restricting eligibility. `it_request_location_candidates` can restrict fallback
locations for one fallback-enabled request. If a request has candidate rows,
only those alternate locations and its preferred location can be allocated.
With no candidate rows, location fallback remains unrestricted. Candidate rows
must name unique nonblank alternate locations for known fallback-enabled
requests. When a candidate list is supplied, per-request location priorities
must name one of its candidates. `it_request_batch_candidates` can restrict
alternate batches for one fallback-enabled request. If a request has candidate rows, only
the named alternates can be allocated; its preferred batch remains first. With
no candidate rows, batch fallback remains unrestricted. Candidate rows must
name unique nonblank alternate batches for known fallback-enabled requests.
When a candidate list is supplied, batch priority rows must name one of its
candidates. For a full-quantity demand, if eligible scoped availability is
short, the row
receives zero and leaves stock available for later demands. Without that
option, partial allocation is allowed. Batch balances are tracked as part of
their location totals, so allocations share the same stock pool.
Batch-restricted and batchless demands require expiry at least the required
date plus the requested minimum shelf life. Unknown-expiry batches remain eligible when the
minimum is zero and known expiry is not required. Batchless demands consume
eligible batches in FEFO order across matching locations. Unscoped competing
reservations use the same ordering when they consume batch stock. The
`PREVIEW_COMPONENTS_STOCK`, `PREVIEW_COMPONENTS_STOCK_BULK`,
`PREVIEW_COMPONENTS_ATP`, `PREVIEW_COMPONENTS_ATP_BULK`,
`PREVIEW_SCOPED_COMPONENTS`, and `PREVIEW_SCOPED_COMPONENTS_BULK` accept
`it_allocation_policies`, keyed by reservation number and item, to set per-demand
`priority`, `require_full_quantity`, `minimum_coverage_pct`,
`allow_location_fallback`,
`allow_batch_fallback`,
`minimum_shelf_life_days`, and
`require_known_expiry` for individual open components. Set
`override_storage_location` or `override_batch` to replace the corresponding
reservation scope in the local preview with the policy value; a blank value
clears that scope. When an override flag is false, its policy value must be
blank and the reservation scope is retained. Set `override_required_date` to
use the policy's `required_date` for local allocation, shelf-life eligibility, projected receipt
horizon, ATP date grouping, and date summaries. The result preserves the source
component date and reports the planning date as `effective_required_date`. An
enabled date override requires a valid Gregorian date; when disabled, its
policy date must be blank. Set `override_open_quantity` to use the policy's
`open_quantity` instead of the open RESB quantity for local allocation and ATP
quantities. The override must be nonnegative. A value of zero removes the
component's demand from local allocation and ATP while keeping its result row. When
quantity override is disabled, the policy quantity must be blank.
`effective_open_quantity` reports the source-unit quantity used, while the
returned component retains its original open quantity. These quantity and date
overrides affect previews only and do not change SAP reservation data. Set `allow_location_fallback = abap_true` to keep the
effective storage location as the preferred location while allowing stock from
other locations when needed; this requires a nonblank effective location.
Set `allow_batch_fallback = abap_true` to keep a nonblank effective batch as
the first choice while allowing other eligible batches when needed. Alternate
batches follow FEFO ordering; location priorities break ties after expiry and
batch. Shelf-life and known-expiry rules apply to the preferred and alternate
batches, and location fallback remains independently controlled.
Without this flag, the effective batch remains an exact restriction.
Batch-fallback demands rank below exact-batch demands due on the same date, so
the exact batch gets first access to shared stock.
Location-only stock uses the preferred location first, then other locations in
ascending code order. For batch candidates, the preferred location breaks ties
after expiry and batch order. Location fallback keeps the location as a
preference when scope rank is calculated, so stricter location demands retain
precedence. Higher priority values
allocate first within each required-date and scope-rank group; input order breaks
ties. A full-quantity demand receives zero if eligible scoped stock is short,
leaving that stock for later demands. Duplicate or unmatched policy keys are
rejected. Without a matching policy, priority, all-or-nothing allocation,
location fallback, batch fallback, shelf-life controls, and scope overrides
remain at their defaults. A supplied policy routes its material/plant group
through the scoped local ledger; ATP fields remain SAP diagnostics and do not
use these local allocation rules. Each component result echoes its matching
input in `allocation_policy`; the field is initial when no row was supplied.
Each allocation policy may also set `minimum_coverage_pct` from 0 through 100.
The scoped allocator compares the floor with eligible base-unit stock after
required-date, location, batch, expiry, fallback, projected-receipt, and
safety-stock rules. A component below the floor receives zero allocation and
leaves stock for later components. ATP still checks the requested demand
separately. The threshold is echoed in both the `allocation_policy` and the
component's `component_local_estimate`. Per-component local estimates also
report `allocation_outcome` (`F`, `P`, or `U`) and `allocation_coverage_pct`
from base-unit quantities, rounded to two decimals and zero for zero demand.
The grouped `local_estimate` preserves the outcome and coverage from the
date-based plant summary.
Each component result also reports `effective_storage_location`,
`effective_required_date`, `effective_open_quantity`, and `effective_batch`,
showing the values used after overrides even when allocation is zero and there
are no split rows. `location_fallback_used` is true only when an
allocated batch or location split uses a storage location other than the
effective preferred location. `batch_fallback_used` is true only when an
allocated batch split uses a batch other than the effective preferred batch.
All six preview methods also accept `it_storage_location_priority`, shared by
fallback-enabled components. The effective preferred location stays first;
other listed locations follow the caller's order, then unlisted locations in
ascending code order. For batch stock, this list breaks ties after expiry and
batch ordering. Blank or duplicate locations are rejected, and the list is
rejected when no selected component enables location fallback.
They also accept `it_comp_location_priorities`, keyed by reservation number,
item, and storage location, to assign positive ranks to fallback locations for
one component. The preferred location stays first; lower local ranks precede
higher ranks, rank ties and unranked locations use location code. Local ranks
override the shared priority list for that component, and unranked locations
then follow by code. Unknown components, components without fallback, blank
locations, nonpositive ranks, and duplicate component/location rows are
rejected. The local ranks order candidates without restricting eligibility.
All six methods also accept `it_comp_location_candidates`, keyed by reservation
number, item, and storage location, to restrict fallback locations for one
fallback-enabled component. When a component has candidate rows, only those
alternates and the preferred location can be allocated. With no candidate rows,
fallback remains unrestricted. Candidate rows must reference selected
fallback-enabled components and cannot name the preferred location or duplicate
a component/location pair. If candidates and local priorities are both
supplied, every local priority row must name a listed candidate.
All six preview methods also accept `it_comp_batch_priorities`, keyed by
reservation number, item, and batch, to assign positive ranks to alternate
batches for one fallback-enabled component. The effective preferred batch stays
first; FEFO expiry order remains primary, and local ranks break ties among
batches with equal expiry. Lower ranks precede higher ranks, then unranked
batches; rank ties and unranked batches use batch code. Rows must reference
selected components with batch fallback enabled and cannot name the preferred
batch or duplicate a component/batch pair. The ranks do not restrict batch
eligibility.
All six methods also accept `it_comp_batch_candidates`, keyed by reservation
number, item, and batch, to restrict alternate batches for one fallback-enabled
component. When a component has candidate rows, only those alternates and the
preferred batch can be allocated. With no candidate rows, fallback remains
unrestricted. Candidate rows must reference selected fallback-enabled
components and cannot name the preferred batch or duplicate a component/batch
pair. If candidates and priorities are both supplied, every priority row must
name a listed candidate.
Policies cannot be combined with
`iv_subtract_unissued_sto = abap_true`, and automatic projected receipts for a
policy group need a receiving location or the request is rejected. The
allocator starts from raw unrestricted location and batch balances, excludes
the selected component reservation keys, and deducts other
active `RESB` open quantities by their assigned scope. A competing reservation
uses its assigned batch and location first, then any remaining quantity is
deducted from the rest of the plant stock. Competing reservations enter the
ledger by required date, before selected components due on that date. Batch
stock used by a component or competing reservation must remain eligible through
its required date; undated stock remains eligible. The estimate does not call
ATP. SAP-derived standard PO or confirmation-aware PO, issued or unissued STO,
scheduling-agreement, production-order, PR, STO PR, and planned-order receipts
can enter this ledger when they have a receiving location. PO confirmation
rows use `EKES-CHARG`; both PO modes use `EKPO-LGORT`. A material/plant pair
falls back to the plant-level path if any of its selected receipts has no
location. Enabling outgoing-STO subtraction uses that path for every pair.
Callers can provide `it_projected_batch_receipts` or
`it_projected_location_receipts` to the explicit scoped preview or the stock
preview with material, plant, storage location, receipt date, and base-unit
quantity; batch receipts also include a batch and optional expiration date.
Receipts enter the shared stock ledger on their
arrival date, before reservations due that date, so they cannot cover earlier
reservations. A receipt with no supplied expiration date inherits a known date
for that batch from current stock or another caller-supplied receipt; any known
expiry must be on or after each receipt date. Supplied dates must agree with
known batch expiry. Due receipts
replenish any remaining protected safety-stock buffer before the excess becomes
allocatable. Caller-assigned receipt rows are not checked against purchase
orders, transfers, production orders, or batch master data. Production-order
receipts use `AFPO-LGORT` and `AFPO-CHARG`; PR/STO PR rows use `EBAN-LGORT`;
planned and fixed planned-order rows use `PLAF-LGORT`. The
`it_projected_location_receipts` input accepts material, plant, storage
location, receipt date, and base-unit quantity for non-batch stock. It enters
the location's residual stock pool on its arrival date, before due reservations,
and can satisfy batchless components at that location (or unscoped components).
Exact-batch component demands cannot allocate location-only receipt quantities.
Both receipt inputs can be combined, but neither can be combined with the
SAP-derived local receipt flags. Without component scopes, the automatic
`PREVIEW_COMPONENTS_STOCK` path continues to use the plant-level estimate when
SAP-derived receipt options are enabled. With component scopes, the automatic
sources listed above use the scoped estimate for each material/plant pair
whose selected receipts all have a storage location. A pair with a missing
location falls back independently. Scoped results contain
component estimates and a shared date-group estimate. Batch totals and demand
scope sums use high precision before location clamping; an unrepresentable
group or demand total raises ZCX_INVALID_STOCK_REQUEST. Receipt additions to
scoped location or batch balances are checked and raise the same exception when
they exceed those fields. Group available quantity
counts each eligible stock pool once across the union of component scopes; the
group's requested, allocated, and shortfall quantities sum its components. ATP
fields remain initial. See `ANOMALIES.md` for the local snapshot limits.
`SUMMARIZE_COMPONENT_READINESS` rolls preview rows up by production order. It
reports the open, covered, short, and zero-demand component counts, total
requested, allocated, and shortfall base quantities, the required-date range,
the first local shortage date, and `is_locally_ready`. Covered counts include
positive-demand rows with no shortfall; zero-demand rows are reported separately.
Summary dates use `effective_required_date`, falling back to the original
component date when that field is initial. Quantity totals use checked sums and
raise `zcx_invalid_stock_request` if an order total exceeds `MARD-LABST`.
This status uses the local component allocations only; review the ATP results
separately for SAP confirmation status. `SUMMARIZE_COMPONENT_SHORTAGES` groups
the same rows by material, plant, base unit, and required date. It reports
component and affected-order counts, the distinct `affected_production_orders`
list, and requested, allocated, and shortfall base quantities, omitting groups
with no local shortfall. When callers provide this list, its nonblank unique IDs
must match `affected_order_count`. `SUMMARIZE_ORDER_ATP`
summarizes the per-component ATP split by production order, material, plant,
and base unit. A zero-quantity policy row with no cumulative group demand has
no ATP result; its all-zero quantities are accepted by the summary. It reports
fully, partially, and unconfirmed component counts,
requested/confirmed/unconfirmed base quantities, required-date range, first
unconfirmed date, and `is_split_fully_confirmed`. Quantities remain separated
by material and unit, and the status describes the deterministic component
split rather than an order-level result returned by SAP.
Grouped shortage and ATP summary quantities are checked against the
`MARD-LABST` range; an unrepresentable total raises
`zcx_invalid_stock_request`.
`SUGGEST_COMP_REPLENISHMENT` turns component shortage rows into base-unit
quantity suggestions. Caller policies override material master planning data.
For materials without an override, the service reads the base unit from `MARA`
and `MARC-DISLS`/`MRPPP`/`RDPRF`, lot quantities `BSTMI`/`BSTMA`/`MABST`/`BSTFE`/`BSTRF`,
procurement type `BESKZ`, special procurement key `SOBSL`, lead-time fields
`PLIFZ` and `WEBAZ`, plant calendar `T001W-FABKL`, and purchasing processing days
`T399D-BZTEK` in one bulk read. Lot-for-lot
(`EX`) suggestions apply minimum quantity, maximum lot
size, and PO rounding value; fixed lot (`FX`) suggestions use the fixed
quantity. Daily (`TB`), monthly (`MB`), and weekly (`WB`) lot sizing group
supplied shortage rows by material/plant/unit and calendar period. A daily
`TB` period starts and ends on the requirement date. SAP describes `TB` as the
daily lot-size procedure ([SAP daily lot-size guidance](https://learning.sap.com/courses/exploring-advanced-production-planning-with-sap-s-4hana-pp-ds/exploring-technical-steps-of-a-planning-run-in-sap-s-4hana-pp-ds-1),
[SAP daily lot-size KBA](https://userapps.support.sap.com/sap/support/knowledge/en/2221618)).
Planning-calendar (`PK`) lot
sizing uses `MARC-MRPPP` and overlapping periods read from `T439I`, keyed by
plant and calendar ID. Callers can pass resolved periods to bypass that lookup.
For additional period-based or custom procedure keys, pass
`it_resolved_lot_size_periods` rows with plant, procedure, and inclusive start
and end dates. The service uses those caller-resolved boundaries to group and
net shortages, then applies the procedure's minimum, maximum, and order
multiple. It does not infer week-count, posting-period, fiscal, or
customer-specific boundaries. Supplied periods for one plant/procedure cannot
overlap, and every shortage for a procedure with supplied periods must fall
within one. Built-in `EX`, `FX`, `HB`, `TB`, `MB`, `WB`, and `PK` handling cannot
be overridden through this input; `PK` continues to use the planning-calendar
input.
Projected PO, STO, production, purchase-requisition, and planned-order
receipts convert to the material base unit before netting. Overflow and
nonzero amounts that round to zero at MARD-LABST precision raise
zcx_invalid_stock_request. Projected receipts are netted against each shortage
date before each period total is lot-sized. A `PK` shortage without a matching period
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
For `EX`, `TB`, `MB`, `WB`, resolved `PK`, and caller-resolved custom periods,
the result includes the aggregate quantity, receipt count, and final receipt
quantity after maximum-lot splitting.
For supported lot-sizing policies, a caller or material-master `MARC-RDPRF`
applies static threshold rounding from plant/profile `RDPR` rows to each receipt
after lot sizing. The result reports the profile and updates the aggregate,
receipt count, final receipt, and rounding surplus. Every returned quantity
must fit `MARD-LABST`; a rounded aggregate beyond that field's range
raises `zcx_invalid_stock_request`. A profile that rounds a receipt above its
configured maximum lot size raises
`zcx_invalid_stock_request`; keep maximum lot size compatible with the profile.
SAP documents lot sizing before rounding and threshold-based static profiles
([procurement quantity calculation](https://help.sap.com/docs/SAP_ERP_SPV/85d3fce10e264972a0155c8b46ecf93b/dca5bb53707db44ce10000000a174cb4.html),
[static rounding profiles](https://help.sap.com/docs/SAP_ERP/85d3fce10e0e1416d83c0fdfa4060189d/f597b6535fe6b74ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest)).
Other lot-sizing procedures without caller-resolved periods or incompatible
`EX`/`MB`/`WB`/`PK` settings return the
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
Each request's delivery date is validated as a Gregorian date before
repository reads.
SQLite integration tests run this service through the EINA/EINE/EORD/MARC and
quota repository reads, checking deletion filtering, source-list eligibility,
vendor-specific source blocking, source flags, automatic-sourcing filtering,
exact-day validity expiry, and the default visibility of unlisted sources when
the material does not require a source list, alongside the opt-in listed-source
filter.
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
can review the whole candidate set. Each result's `has_active_vendor_quota`
flag is true only when that vendor has an in-date, external-supplier quota item
with a positive quota value. Each result also includes the matching `TMQ2`
usage rule, showing whether purchase requisitions, purchase orders,
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
`ZCL_REPLENISHMENT_REQ_SERVICE=>CREATE_FROM_PROJ_SHORTFALLS` turns
positive project-stock shortfalls into one purchase requisition. Each input row
becomes a material item assigned to account category `Q` and its stock-bearing
WBS element; quantity is expected in the supplied material unit, with a
required delivery date. Build these rows from the positive shortfalls and WBS
assignments returned by `ZCL_PROJECT_STOCK_SERVICE`. The adapter sends the item
and account assignment rows through `BAPI_PR_CREATE` and supports test runs.
SAP and purchasing configuration remain authoritative for whether the WBS is
stock-bearing and the requisition is valid.
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
Each request's delivery date must be a valid Gregorian date; malformed dates
are rejected before the source repository is read.
Results include the agreement/item, vendor, document and source-list validity
windows, fixed-source and MRP-use flags, and preferred-vendor match. Fixed
sources sort first, followed by the request's preferred vendor. Blocked source
list rows (including applicable vendor-level blocks), deleted documents/items,
completed items, source-list/header vendor mismatches, and sources outside
either validity window are omitted. This is review data: it does not check
release status, prices, remaining contract
quantity, scheduling-agreement schedule lines, or delivery confirmation, and
it does not assign or create a source. SQLite-backed tests exercise the
`EORD`/`EKKO`/`EKPO`/`MARC` reads through the service and verify the resulting
outline-candidate filtering for blocked sources, deleted headers or items,
completed items, validity-window boundaries and exclusions, plus K/L category
mapping and source-list flags. Validate the query and target-specific source
rules in the host SAP release.
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
For in-house planned receipts, `ZCL_PLANNED_ORDER_SERVICE->CREATE_FROM_SUGGESTIONS`
accepts internally procured (`E`) suggestions and creates one planned order per
receipt lot, retaining the required date and original suggestion/lot indexes.
It rejects external or special-procurement suggestions before writing. The
`PREPARE_FROM_SUGGESTIONS` method exposes the validated per-lot request list
without calling SAP, so clients can review quantities, end dates, and source
indexes before the write. The service also offers `CREATE_ORDERS_ATOMIC` for
explicit material, plant, base-unit quantity, and planned end-date requests.
Both write methods submit through
`BAPI_PLANNEDORDER_CREATE` and commit the full group once. A create or commit
failure rolls back the group and clears provisional planned-order numbers.
Covered zero-quantity suggestions are skipped. This path creates planned orders
only; production-order conversion is a separate, explicit operation. It does
not post goods movements.
Set `iv_test_run = abap_true` on atomic and bulk creation methods to pass SAP's
`TESTRUN = 'X'` flag to each create call. Simulated calls do not commit or roll
back, and a successful simulation may return no planned-order number. Result
rows retain their success state and suggestion/receipt indexes without claiming
that an order exists. `CREATE_ORDERS_BULK` and its suggestion wrapper also
retain the regular stop-on-failure behavior during simulation. SAP lists
`BAPI_PLANNEDORDER_CREATE` among its available MRP interfaces, documents the
standard BAPI TestRun contract, and documents planned-order creation inputs
([available interfaces](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html),
[planned-order creation](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/f92b46872df54aa79ca7c20038b98a31.html?locale=en-US),
[BAPI TestRun guidance](https://help.sap.com/saphelp_snc70/helpdata/EN/df/0495dbbd6f11d1ad09080009b0fb56/content.htm?no_cache=true)).
Verify the BAPI header fields, base-unit interpretation, and rollback behavior
in the target SAP release.
`DELETE_ORDERS_ATOMIC` accepts a list of planned-order numbers, validates all
keys and duplicates before writing, then calls `BAPI_PLANNEDORDER_DELETE` for
each order and commits once. A delete or commit failure rolls back the group.
It has no BAPI simulation mode; inspect the validated number list before
calling it. SAP lists the planned-order deletion BAPI among its available MRP
interfaces ([available interfaces](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html)).
Verify deletion eligibility and multi-call rollback behavior in the target
release.
`CHANGE_ORDERS_ATOMIC` accepts planned-order numbers with selected quantity,
start-date, end-date, and firming-indicator changes. Every field has an
explicit change flag; an explicitly selected blank firming indicator unfixes
the order.
Unselected fields must be initial, date changes require dates, quantity changes
must be positive, and a request must select at least one field. It validates
all keys and duplicate numbers before calling `BAPI_PLANNEDORDER_CHANGE`, then commits the group once
or rolls it back after a BAPI or commit failure. `CHANGE_ORDERS_BULK` applies
the same validation and changes each planned order with its own commit, then
continues after individual failures. Review its per-row commit status because
the batch can be partially completed; the top-level `is_committed` reports
whether any row committed. Neither method offers simulation; SAP
lists the planned-order change BAPI among its available MRP interfaces
([available interfaces](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
Verify the change fields, quantity unit, and transaction behavior in the target
release.
`READ_ORDERS_BULK` reads several planned-order numbers in one `PLAF` query and
returns rows in request order. Each row includes the material, production
plant, planning plant, planned-order creation date and user, last-change
timestamp, basic and scheduled start/finish dates and times, order quantity
and unit, base unit, planned-order type, storage
location, procurement indicator, MRP controller, production supervisor,
production version, MRP area, account-assignment category, fixed indicator,
planning scenario, special-stock indicator, sales-order assignment,
sales-order-item assignment, and sales-order schedule line. The service also
returns the converted base-unit quantity when the `MARA`/`MARM` unit ratio is
available; otherwise it preserves the raw header and marks that row's
conversion as failed. Missing orders are reported per row and make the overall
result unsuccessful. Blank or duplicate numbers are rejected before the read;
empty input returns an empty successful result with an initial
`snapshot_timestamp`. Nonempty results include a UTC `snapshot_timestamp`
captured after the repository read; it marks read completion and does not commit
or change SAP data.
Before mapping, the service rejects blank or duplicate returned planned-order
numbers and any row whose number was not requested. Missing requested orders
remain per-row not-found results.
`READ_ORDERS_BY_FINISH_WINDOW` searches by one material and production plant
(`PLAF-PWWRK`) over an inclusive planned-finish-date range. Set nonblank
`planning_plant` to match `PLAF-PLWRK` exactly; blank omits it by default. Set
`filter_planning_plant` to `abap_true` to match exactly, including blank. The
flag accepts only `abap_true` or `abap_false`, and nonblank values still filter
when it is false. Each returned header includes both plant fields. Set both `creation_date_from` and
`creation_date_to` to filter the inclusive planned-order creation-date range
(`PLAF-PERTR`); partial, invalid, or reversed pairs fail before reading. Set
Headers also return the raw packed-decimal short last-change timestamp
(`PLAF-PSTMP`); SAP notes it can differ from the apparent change time. Set
`last_change_timestamp_from`, `last_change_timestamp_to`, or both to filter that
field inclusively before pagination. Each supplied bound must be positive; if
both are supplied, the lower bound must not exceed the upper bound. Returned
timestamp values are checked against every supplied bound;
this source-field filter is not an exact wall-clock change-time cutoff. Set
`planned_order_user` to match the `PLAF-PUSER` user field exactly; blank omits
the filter by default. Set `filter_planned_order_user` to `abap_true` to match
exactly, including blank. The flag accepts only `abap_true` or `abap_false`; a
nonblank user value continues to filter when the flag is false. A nonblank `sales_order` or
`planning_scenario` selects that exact value. Set `filter_sales_order` to
`abap_true` to match the exact sales-order assignment, including the initial
value for unassigned orders; nonblank sales-order values continue to filter
without the flag. The flag accepts only `abap_true` or `abap_false`. Set
`filter_planning_scenario` to `abap_true` to match the exact scenario including
the initial value; the flag accepts only `abap_true` or `abap_false`. Set
`order_type` to match the exact `PLAF-PAART` planned-order type; an initial
value omits that filter by default. Set `filter_order_type` to `abap_true` to
match exactly, including blank. The flag accepts only `abap_true` or
`abap_false`, and a nonblank type continues to filter when the flag is false.
Set `filter_start_date` to `abap_true` to match the exact `start_date`, including
blank; a nonblank date filters when the flag is false. The flag accepts only
`abap_true` or `abap_false`, and nonblank dates must be valid. Exact-date and
range filters intersect. Set both `start_date_from` and `start_date_to` to
constrain planned start dates; partial, invalid, or reversed ranges fail before
the read. For scheduled
dates, provide both `scheduled_finish_date_from` and
`scheduled_finish_date_to` to filter `PLAF-GLTRS`, and both
`scheduled_start_date_from` and `scheduled_start_date_to` to filter
`PLAF-GSTRS`. Each range is inclusive and requires two valid dates in ascending
order; omit a pair to leave that date unrestricted. The filters apply before
pagination, which remains ordered by the basic finish date and planned-order
number. Set `filter_scheduled_start_date` to `abap_true` to match the exact
`scheduled_start_date`, including blank; a nonblank date filters when the flag
is false. `filter_scheduled_finish_date` and `scheduled_finish_date` work the
same way for `PLAF-GLTRS`. Each flag accepts only `abap_true` or `abap_false`,
and nonblank dates must be valid. Exact-date filters intersect with their date
ranges. `filter_scheduled_start_time` and
`filter_scheduled_finish_time` enable inclusive time-of-day ranges on
`PLAF-GSUZS` and `PLAF-GLUZS`. Each enabled filter requires two valid ascending
times; `000000` selects midnight when enabled. Both flags accept only
`abap_true` or `abap_false`; disabled filters require initial bounds. Time
ranges apply on every matching date, combine with scheduled-date
ranges, and do not cross midnight. Returned scheduled times are validated and
checked against enabled ranges. Set
`filter_storage_location` to `abap_true` to match `storage_location` exactly,
including blank for an unassigned location; a location without the flag is
rejected. Set `filter_procurement_indicator` to `abap_true` to match
`procurement_indicator` exactly, including blank; supplying a value without the
flag is rejected. SAP commonly uses this indicator to distinguish procurement
types. Set `filter_special_proc_type` to `abap_true` to match
`special_procurement_type` (`PLAF-SOBES`) exactly, including blank. A value
without the flag is rejected. The value is returned in each order header and
the filter runs before pagination. Set `positive_quantity_only` to `abap_true` to omit zero and negative
planned-order quantities. Set
`filter_quantity_from` and `filter_quantity_to` independently to `abap_true` to
select inclusive lower and upper bounds on `PLAF-GSMNG` using `quantity_from`
and `quantity_to`. Either bound can be used alone; when both are enabled, the
lower bound must not exceed the upper. Zero is a valid bound when enabled.
Set a flag to `abap_false` and leave its bound initial to omit that side of the
filter. Bounds use each order's `order_unit` and run before pagination,
independently of the optional base-unit quantity conversion. The service rejects
invalid flags, reversed ranges, values supplied for disabled bounds, and
returned rows outside selected bounds. A nonblank
`order_unit` also selects that exact planned-order unit. Set
`filter_order_unit` to `abap_true` to select an exact unit including blank; the
flag accepts only `abap_true` or `abap_false`, and a nonblank unit filters even
when the flag is false. The unit selection runs before pagination, and returned
rows are checked for unit scope drift. Set
`filter_base_quantity_from` and `filter_base_quantity_to` to apply inclusive
bounds to `quantity_in_base_unit` in the material base unit. Either bound can
be used alone; zero and negative values are allowed, inactive values must be
initial, and two active bounds must be ordered. Base-unit bounds compose with
order-unit bounds and `positive_quantity_only`, run before pagination, and
exclude rows without a valid conversion when the order unit differs from the
material base unit. The service checks returned quantities against the bounds.
Set
`filter_mrp_controller` to `abap_true` to match `mrp_controller` exactly,
including blank; a controller value without the flag is rejected. Set
`filter_production_supervisor` to `abap_true` to match
`production_supervisor` exactly, including blank; a value without the flag is
rejected. Set `filter_production_version` to `abap_true` to match
`production_version` exactly, including blank; a value without the flag is
rejected. Set `filter_mrp_area` to `abap_true` to match `mrp_area` exactly,
including blank; an area value without the flag is rejected. Set
`filter_account_category` to `abap_true` to match
`account_assignment_category` exactly, including blank; a category value
without the flag is rejected. Set
`filter_sales_order_item` to `abap_true` to match `sales_order_item` exactly,
including the initial `PLAF-KDPOS` value (`000000`). This filter requires a
nonblank `sales_order`; supplying an item without the flag is rejected. Set
`filter_sales_schedule_line` to `abap_true` to match
`sales_order_schedule_line` (`PLAF-KDEIN`) exactly, including the initial
`0000` value. This filter requires a nonblank `sales_order` and an enabled,
nonblank `sales_order_item` selection. A schedule-line value without its flag
is rejected. Set
`filter_special_stock` to `abap_true` to match `special_stock_indicator`
exactly, including blank for ordinary stock; an indicator without the flag is
rejected. Set `filter_fixed_indicator` to `abap_true` to select the exact
`fixed_indicator`: `abap_true` selects firmed orders and blank selects unfixed
orders. Values are restricted to `abap_true` and blank. All filters run before
pagination. The service returns at most `maximum_results` orders,
sorted by finish date and planned-order number, with base-unit quantity
conversion when the material ratio is available. `maximum_results` must be
between 1 and 500. The service reads one extra row to set `is_truncated` when
more orders match. When truncated, `next_finish_date` and `next_planned_order`
identify the last returned order; pass both fields back as `after_finish_date`
and `after_planned_order` to continue after that order, including when several
orders share a finish date. Omit both cursor fields for the first page. Invalid
or partial cursors, dates, incomplete scope, reversed ranges, and limits are
rejected before the repository read. The service validates the returned row
count and unique nonblank order numbers, then checks selected material,
production plant, planning plant, creation-date range, planned-order user,
sales order and item,
planning scenario, order type, storage location,
procurement and special procurement type, positive quantity, order- and
base-unit quantity bounds, MRP controller,
production supervisor,
production version, MRP area, account-assignment category, sales-order schedule
line, special-stock and fixed indicators. It also verifies the start-date and finish-date ranges,
cursor boundary, and sort order before mapping results. Each result includes a UTC `snapshot_timestamp`
marking repository-read completion, even when no orders match. It does not lock
orders or make later pages part of the same snapshot.

`CONVERT_PLANNED_ORDERS_ATOMIC` converts a validated list through
`BAPI_PRODORD_CREATE_FROM_PLORD` and commits the conversions together. Any
conversion or commit failure rolls back the group and clears returned
production-order numbers. `CONVERT_PLANNED_ORDERS_BULK` commits each conversion
separately, continues after failures, and returns per-order status and counts;
the bulk result's `is_committed` reports whether any conversion committed.
Use the rows to reconcile partial completion. Both methods reject blank or
duplicate planned-order numbers before the first BAPI call and have no
simulation mode. Verify the conversion function module and LUW behavior in the
target SAP release before use.
`CREATE_ORDERS_BULK` and `DELETE_ORDERS_BULK` validate every request or number
before the first BAPI call, then commit each planned-order operation separately
and continue after an individual BAPI or commit failure. Their row results show
which orders were attempted and committed, with successful and failed counts.
The top-level `is_committed` reports whether at least one order committed, so a
partial run is distinct from a batch where no operation committed. Review each
row for details. These methods do
not offer a simulation mode; use `PREPARE_FROM_SUGGESTIONS` to inspect creation
requests before submitting them.
`CREATE_FROM_SUGGESTIONS_BULK` prepares the same validated per-lot requests,
then uses the independent-commit bulk path. Each result row retains its
1-based source suggestion and receipt-lot indexes, so a partially completed
batch can be reconciled to the original suggestions. Covered zero-quantity
suggestions produce no order; if every row is covered, the result is an empty
successful no-op.
`CREATE_ORDERS_BULK`, `CREATE_FROM_SUGGESTIONS_BULK`, `DELETE_ORDERS_BULK`,
`CHANGE_ORDERS_BULK`, and `CONVERT_PLANNED_ORDERS_BULK` accept the optional
`iv_stop_on_failure` flag. It defaults to `abap_false`, preserving the behavior
of continuing after each failed BAPI result or commit. With `abap_true`, the
first failed request stops later API calls. Every request remains in the result
in caller order; later rows have `is_skipped = abap_true`, and `skipped_count`
is separate from `failed_count`. `stopped_on_failure` is true whenever the loop
stops this way, including when the failed request was last. Each option value
is validated before the first API call. Earlier successful per-order commits
remain committed, so stop-on-failure reports a partial run and does not make
the operation atomic.
Pass returned suggestions to `zcl_replenishment_req_service` to create a
purchase requisition through `BAPI_PR_CREATE`. It creates one requisition item
for each planned receipt lot, preserving the lot split, base unit, plant,
quantity, and required date; zero-quantity covered rows are skipped.
For a fixed-lot suggestion rounded by `MARC-RDPRF`, it validates that the total
equals the rounded final receipt quantity times the receipt count and creates
each item at that rounded quantity.
`iv_test_run = abap_true` asks the BAPI to simulate creation and skips commit.
Normal writes commit only after the BAPI succeeds and returns a requisition
number; errors trigger rollback. At the API boundary, live creates require
that returned number before reporting success; a successful test-run may omit
its simulated document number. The service accepts a requisition type (default
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
Call `PREPARE_FROM_SUGGESTIONS` to get the exact requisition type and item rows
after validation, lot splitting, and unit conversion without calling the BAPI.
`CREATE_FROM_SUGGESTIONS` uses this same prepared request before writing, so the
reviewed item numbers, source indexes, quantities, units, dates, and purchasing
fields match the submitted payload. Covered zero-quantity suggestions produce
an empty prepared request.
`PREPARE_FROM_SELECTED_SOURCES` applies reviewed PIR or agreement choices and
includes the chosen vendor, source reference, and purchasing-unit conversion.
`PREPARE_FROM_QUOTA_SPLITS` also verifies split reconciliation and returns one
item per selected quota share. Proposal quantities must fit `MARD-LABST`; an
oversized split raises `zcx_invalid_stock_request` before any BAPI call. The
matching create methods submit these same prepared rows.
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
For `create_from_selected_sources`, a selected PIR candidate's purchasing unit
and info-record conversion ratio are carried into each generated PR lot. Base
quantities are converted with `EINA-UMREZ`/`EINA-UMREN` before the BAPI call;
outline-agreement and unresolved sources keep the suggestion's base unit. Conversion overflow and nonzero base quantities that round to zero at
MARD-LABST precision raise `ZCX_INVALID_STOCK_REQUEST` before a BAPI call.
`create_from_quota_splits` connects the quota preview to PR creation. Pass rows
keyed by their original suggestion index with each `SIMULATE_SPLIT_QUOTA` split.
The service requires each selected suggestion's allocated shares to reconcile
exactly to its requested quantity, then creates one PR item per split at its
`proposal_quantity`, carrying the selected PIR vendor, info record, and
purchasing-unit conversion. Returned items retain the original suggestion
index. Proposal minimums and rounding can make ordered quantities exceed the
allocated shares; review that surplus before submitting. Quota previews are
snapshots and do not reserve quota or guarantee SAP will accept the source.
`create_from_suggestions` also accepts an explicit per-suggestion
`purchasing_unit` control with its order-to-base numerator and denominator.
Each returned SAP message preserves its BAPIRET2 type, class, number, text
variables, parameter, row, field, system, and log identifiers so callers can
present or log structured item-level diagnostics. Messages that point to a
`PRITEM` or `PRITEMX` row also include the corresponding generated item number
and source suggestion index when the row maps to a submitted item.
The result reports `is_test_run`, `bapi_was_called`, and `is_committed` so a
successful simulation or covered-row no-op can be distinguished from a
requisition committed to SAP.
`read_pr_items` reads item details for one requisition through
`BAPI_PR_GETDETAIL`. Each item includes material and text, plant and storage
location, quantity and unit, delivery date, purchasing and source references,
release and processing status, ordered quantity, follow-on PO keys, and fixed or
closed indicators. It preserves BAPI messages and includes deleted items as
returned by SAP. This read does not commit a transaction. SAP's generic
GetDetail BAPI reads the details for one keyed business object
([SAP GetDetail guidance](https://help.sap.com/docs/SAP_NETWEAVER_700/10a1c6d16c531014ac7b8c45ecd11874/8b40aed6c95c11d1ad0c080009b0fb56.html)).
`read_pr_items_bulk` accepts several requisition numbers, validates the full list
before the first BAPI call, preserves input order, and continues after a failed
read. It returns one result per requisition and marks the overall result failed
if any read fails. Empty input returns an empty successful result without a
BAPI call.

`update_pr_items` changes quantity, delivery date, purchasing group, purchasing
organization, or source references (vendor, info record, and outline agreement)
for selected items on one requisition. Every update row explicitly flags which
field is being changed; unflagged values must be initial, quantities must be
positive, and dates must be supplied. A flagged blank source value clears that
reference. The service validates the complete list before calling
`BAPI_PR_CHANGE`, sets update flags only for selected fields, and uses the same
test-run, commit, rollback, and item-level message handling as other PR writes.
SAP decides whether each field and item remains eligible for change. The X
flags follow SAP's change-BAPI update convention
([SAP change BAPI guidance](https://help.sap.com/docs/PRODUCT_ID/67ae2d27aed945b7bd0ad1d2185ec217/4d5bc81fdbd42307e10000000a15822b.html)).
`update_pr_items_bulk` accepts one update group per requisition, including the
same purchasing and source fields, and validates the complete list before
calling SAP. By default it commits or rolls back each requisition separately
and continues after failures. Set `iv_stop_on_failure = abap_true` to stop after
the first failed update or commit; later input rows remain in the result with
`is_skipped = abap_true`. The summary reports successful, failed, and skipped
counts and whether the batch stopped. Earlier independent commits remain. Set
`iv_atomic = abap_true` to commit once for the entire group or roll it back after
the first failure; atomic mode always stops and marks later rows skipped.
Results retain one row per input. Test runs simulate requests and skip commits.
`create_requisitions_atomic` accepts prepared requisition types and item lists
for several documents. It validates all item keys and required fields before
the first BAPI call, requires a returned requisition number for each live
create, and commits the group once. Any create or commit failure rolls back the
group and clears its returned requisition numbers; test runs call each create
in simulation mode and skip commit. The result preserves one row per input
document, including rows not attempted after a failure.
`create_requisitions_bulk` uses the same validation and per-document item
results, while committing or rolling back each PR separately and continuing
after failures by default. Set `iv_stop_on_failure = abap_true` to stop after
the first failed create or commit. Later rows remain in input order with
`is_skipped = abap_true`; the summary reports successful, failed, and skipped
counts and `stopped_on_failure`. Earlier independent commits remain. The
overall status is successful only when every attempted row succeeds; each
result row shows whether its document was committed. Top-level `is_committed`
is true if at least one PR committed and false for simulations or when none
committed. Test runs follow the same stop policy after a simulated failure,
retain later documents as skipped, and never commit.
`mark_pr_items_deleted` flags selected items on an existing requisition through
`BAPI_PR_CHANGE`; it does not physically remove the requisition or its history.
The method validates the requisition number, nonblank unique item numbers, and
test-run flag before calling SAP. Test runs skip commit; successful live calls
commit once, and BAPI or commit errors roll back. Its result echoes submitted
item numbers and preserves SAP messages. SAP determines whether each item can
be marked for deletion based on its current lifecycle and configuration
([purchase requisition item deletion](https://help.sap.com/docs/PRODUCT_ID/bb9f1469daf04bd894ab2167f8132a1a/f261a0af930349779a47b3639c10994d.html)).
`delete_all_pr_items` reads a requisition, then flags every item without a
deletion indicator through the same change and commit path. A read error stops
before any write; an already fully deleted requisition succeeds without a
change call. Test runs pass simulation through to SAP, and the returned result
includes the item snapshot and submitted item numbers.
`delete_all_pr_items_bulk` applies that read-and-delete flow to a validated list
of requisitions. Each document is handled independently, and later requisitions
are still read and processed after a failure by default. Set
`iv_stop_on_failure = abap_true` to stop after the first read, delete, or commit
failure; later requisitions remain in request order with `is_skipped = abap_true`.
The summary reports successful, failed, and skipped counts. Earlier independent
commits remain. Results show each document's commit state; top-level
`is_committed` reports whether any requisition committed.
`delete_pr_items_atomic` applies the same deletion to item groups across multiple
requisitions. It validates all document and item keys before calling SAP, stops
after the first failed requisition, and commits the group once or rolls it back.
Test runs call each requisition in simulation mode and skip the commit. Results
retain one row per input requisition; rows after a failure report that SAP was
not called. Confirm repeated `BAPI_PR_CHANGE` calls share the intended SAP LUW
in the target release.
`delete_pr_items_bulk` validates the same request list, then handles each
requisition in its own commit or rollback and continues when a requisition
fails by default. Set `iv_stop_on_failure = abap_true` to stop after the first
failed delete or commit; later rows remain in request order with
`is_skipped = abap_true`. The summary reports successful, failed, and skipped
counts, and `stopped_on_failure` identifies the stop. Earlier independent
commits remain. Its overall success is true only when every attempted row
succeeds; inspect each row's `is_committed`, `bapi_was_called`, and messages for
partial outcomes. Top-level `is_committed` is true if at least one requisition
committed; it stays false for simulations and when none committed. Test runs
simulate requested rows and skip commits.
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
with an ATP check and supports simulation and transaction rollback. The single
cost-center preview and reservation methods accept a scalar
`minimum_coverage_pct` from 0 through 100 as `iv_minimum_coverage_pct`; it gates
eligible base-unit coverage and is echoed in the result. The optional input
defaults to zero, preserving partial allocation. When the floor leaves no
allocation, the reservation method creates no document. Results also report
`allocation_outcome` (`F` fully covered, `P` partially covered, `U` zero
allocation) and `allocation_coverage_pct`, rounded to two decimals from base
quantities. SAP defines
movement type 201 as goods issue to cost center and stores the movement type
and account assignment on the reservation header ([movement type](https://help.sap.com/docs/SAP_ERP/a70c5fce76eb44adb0c86a9d3059e4dd/1663bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest), [reservation structure](https://help.sap.com/docs/SAP_ERP/c8f06b9bc95747ca832ad21e94f577fb/ade0ba538c95b54ce10000000a174cb4.html)).

`read_cost_center_reservations` lists active, open reservation items for a cost
center, including reservation/item keys, material, plant, storage location,
batch, requirement date, entry unit, required quantity, withdrawn quantity, and
remaining open quantity. The repository reads matching `RKPF` headers and
movement-type 201 `RESB` items in batches, then matches them by reservation
number because SAP stores the cost-center assignment on the reservation header
([reservation header](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/03a55f57017647368bfb386e41573ff7.html),
[cost center at header level](https://userapps.support.sap.com/sap/support/knowledge/en/3736490)).
Deleted, finally issued, special-stock, fully withdrawn, and non-201 items are
excluded. SQLite-backed Open SQL tests cover the query filters, cost-center
scope mapping, ordering, and open quantity calculation. The read is a snapshot;
it does not lock the reservation before later deletion or goods issue. The result marks malformed or duplicate repository
rows unsuccessful and clears the returned item list; an empty list is a valid
successful read. `read_cost_center_reservations` and
`read_cc_reservations_bulk` accept an optional `iv_required_through_date` to
exclude later dated items while retaining undated reservations; the cutoff is
validated before a read and applied in both the repository query and service.
`read_cc_resv_requests_bulk` accepts unique request IDs with a cost
center and an individual cutoff per row. It groups matching dates into bulk
reads, permits a cost center to appear in requests with different cutoffs, and
returns results in request order. IDs, centers, and dates are validated before
the first read; empty input performs no reads.
`ZCL_RESERVATION_ISSUE_SERVICE=>PREVIEW_CC_ISSUE_REMAINING` returns these
open cost-center rows without posting; pass reservation numbers to narrow the
result. `POST_CC_ISSUE_REMAINING` requires selected reservation numbers and
issues each selected item's open base-unit quantity through the existing
per-reservation bulk flow. That flow rereads cost-center scope and reservation
details before posting. `POST_CC_ISSUE_REMAINING_ATOMIC` stages the selected
reservation movements together and commits or rolls back the full set.
`PREVIEW_CC_REMAINING_ITEMS` narrows the preview to explicit reservation/item
keys, and `POST_CC_REMAINING_ITEMS_ATOMIC` issues only those items' current open
quantities in one shared LUW. It rechecks each item against the cost-center
scope before staging. `POST_CC_REMAINING_ITEMS` provides per-reservation
commits and continues processing later reservations after an individual
failure by default. Its `iv_stop_on_failure` option stops later groups and
retains them as skipped rows. `POST_CC_ISSUE_REMAINING` exposes the same option.

`read_cc_reservations_bulk` reads open reservation items for several unique
cost centers with one repository call. It returns one result per requested
center in input order; centers with no open items receive a successful empty
result. Blank or duplicate center keys are rejected before the read, and rows
for unrequested centers or malformed/duplicate rows make the overall and
affected center results unsuccessful. The repository reads matching `RKPF`
headers and `RESB` rows in two batched SQL statements; verify target-release
query and authorization behavior as noted in [ANOMALIES.md](ANOMALIES.md).

`delete_reservations` accepts reservation numbers returned by creation and
deletes each complete reservation document through `BAPI_RESERVATION_DELETE`.
It validates the full list before calling SAP, supports `iv_test_run`, and
commits the list once or requests rollback after a deletion or commit error.
SAP controls whether a document is eligible for deletion, including documents
with issued quantities; see the target-system caveat in
[ANOMALIES.md](ANOMALIES.md).

`delete_cc_reservation_items` marks selected item numbers for deletion while
leaving other items in the reservation document untouched. It checks that every
selected item is still open under the supplied cost center and reservation
number before calling SAP. Live calls use `BAPI_RESERVATION_CHANGE`, then commit
once or roll back on an API or commit error. `iv_test_run = abap_true` validates
the local snapshot and skips SAP calls and commit; it does not simulate SAP's
eligibility checks. A reservation can change between the read and update, so
SAP's BAPI response remains authoritative. SAP documents item-level deletion
when changing a reservation ([changing a reservation](https://help.sap.com/doc/a6a8c7536e8e2a4be10000000a174cb4/700_SFIN3E%20006/en-US/3b64bd534f22b44ce10000000a174cb4.html),
[reservation update BAPI](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).

`delete_reservation_items_bulk` accepts one cost center, reservation number,
and item list per row. It validates the full request shape, rejects repeated
reservation numbers, then processes each document independently and continues
after an item deletion or commit failure. Results stay in request order and
include each document's selected items, messages, commit state, and rollback
state. Set `iv_stop_on_failure = abap_true` to skip later requests after the
first failed item deletion; skipped rows and separate successful, failed, and
skipped counts remain in the result. Earlier document commits remain. Empty
input succeeds without a write. `iv_test_run` validates each document against
the local reservation snapshot and skips SAP calls and commits. The top-level
`is_committed` is true if any item deletion committed and false for simulations
or when no request committed.

`delete_reservations_bulk` also prevalidates the full list, then deletes each
document with its own commit and continues after failures by default. Set
`iv_stop_on_failure = abap_true` to skip later reservations after the first
failed deletion or commit. Its result reports success, messages, commit,
rollback, and skipped status for each reservation number, along with separate
successful, failed, and skipped counts. Earlier successful deletions remain
deleted if a later document fails. Empty input is a successful no-op;
`iv_test_run` validates each document without committing. The top-level
`is_committed` reports whether any reservation deletion committed.

`reserve_for_cost_center` can also return its own ATP precheck when
`iv_check_atp = abap_true` and `iv_atp_check_rule` are supplied. Set
`iv_require_atp_confirmation = abap_true` to stop before the reservation API
when SAP confirms less than the requested base quantity. This gate requires ATP
checking; a short result retains the ATP details and creates no reservation.
The result includes `is_fully_confirmed`, which is true only when confirmed
base quantity covers the full request; a check marked not relevant remains false.
The BAPI still performs its own ATP check. As with the preview, this precheck is
plant-level and does not constrain ATP to the selected batch or storage
location. Malformed `iv_test_run` values are rejected before the stock
allocation preview or optional ATP check. Single reservation and preview paths also reject malformed allocation and ATP boolean flags before stock allocation or ATP reads.

`preview_for_cost_center` runs the same allocation and validation steps but
does not call the reservation API. Set `iv_check_atp = abap_true` and supply
`iv_atp_check_rule` to attach a SAP ATP result in `atp_result`. ATP checks the
base-unit request at plant level and does not constrain the result to a selected
batch or storage location. The preview also reports confirmed and unconfirmed
base quantities derived from the ATP confirmation lines, plus
`is_fully_confirmed`. That flag is true only when the confirmed base quantity
covers the full request; a check marked not relevant remains false. The ATP data
is separate from local allocation and does not change the preview success flag
or splits. Full-allocation requirements are reported in the preview result.
`preview_cost_center_demands` evaluates multiple requests together in caller
order by default, converts each material-specific input unit, and consumes
each shared material/plant balance once across those requests. Add a `priority`
to each demand and set `iv_prioritize_by_priority = abap_true` to allocate
higher values first; result rows keep caller order and echo each priority.
Each row may set `require_full_quantity = abap_true` to leave stock available
when that request cannot be fully covered; the global
`iv_require_full_quantity` applies the rule to every row. Results echo the
effective setting. Each row may also set `minimum_coverage_pct` from 0
through 100. The allocator compares provisional coverage in unrounded base
units before consuming shared stock; a request below its floor gets zero and
leaves stock for later cost-center requests. Zero preserves partial
allocation, and the allocation result echoes the floor. It returns per-request
base and input-unit quantities, allocations, and shortfalls without calling
the reservation API. This bulk preview is plant-level and does not
select batches or storage locations. Set `iv_check_atp = abap_true` and provide
`iv_atp_check_rule` to attach SAP ATP diagnostics. By default, checks use
today's date; pass `iv_atp_check_date` to check against a different date. The
service groups checks by material, plant, and base unit using the combined
quantity allocated by the local preview. Each matching result row includes the grouped cumulative,
confirmed, and unconfirmed base quantities and `is_fully_confirmed`; these
diagnostics do not change its allocation. `preview_cost_center_by_date` adds a required date and
optional projected receipts to each demand. Earlier dates consume shared stock
first; on the same date, larger integer priorities allocate first and input
order breaks ties. A demand can require its full quantity while later demands
remain partially allocatable; the global `iv_require_full_quantity` applies
that rule to all rows.
Results stay in caller order, echo priority and effective full-quantity rules
for each request, and report base-unit and input-unit quantities. Its opt-in supply sources and safety-stock protection match the dated stock
allocator; this is still a plant-level preview and does not create reservations.
Each dated demand may set `minimum_coverage_pct` from 0 through 100. The
allocator compares the floor against eligible base-unit availability at that
request's required date, including enabled projected receipts, before consuming
shared stock. A demand below its floor receives zero so later requests can use
the balance. The date-first UOM and ATP paths preserve the floor and return it
in the allocation summary.
Set `iv_check_atp = abap_true` and provide `iv_atp_check_rule` to add SAP ATP
diagnostics. The service checks cumulative demand once per material, plant,
base unit, and required date, then returns the cumulative quantity and confirmed
and unconfirmed base quantities plus `is_fully_confirmed` on each matching
demand. ATP results remain separate from local allocation and do not change
its splits.
`preview_cost_center_locations` adds optional storage-location preferences to
multiple cost center demands. A location is a hard restriction by default;
set `fallback_to_other_locations = abap_true` to try it first and then use
other locations in ascending order. Requests share location balances in caller
order by default. Set `iv_prioritize_by_priority = abap_true` to allocate
higher `priority` values first while keeping results in caller order. Pass
`it_location_priority` to order fallback locations; a preferred location
remains first. `it_request_location_priorities` can override the shared order
for individual request IDs. Each row names a request and location with a
positive rank; lower ranks are used first, and unranked locations follow by
location code. A preferred location remains first when fallback is enabled.
Each result includes its priority and location splits in the requested unit and
base unit.
A demand may set `require_full_quantity = abap_true` to leave stock available
if its full request cannot be covered; `iv_require_full_quantity` applies this
to every demand. Each result echoes the effective setting. Set
`minimum_coverage_pct` on an individual row to require 0–100 percent coverage
in base units after the location scope, fallback, and safety-stock rules are
applied. A row below its floor gets zero and leaves location stock for later
demands. Priority and ATP paths preserve the floor; the allocation summary
echoes it.
`iv_check_atp = abap_true` and provide `iv_atp_check_rule` to attach SAP ATP
diagnostics. Checks use today's date unless `iv_atp_check_date` is set. The
service checks the combined locally allocated quantity once per material,
plant, and base unit. Matching rows include the grouped
cumulative, confirmed, and unconfirmed base quantities; those diagnostics do
not change the storage-location splits. Optional safety-stock protection is
available; batch selection and reservation creation are not part of this
preview. Location-only, exact-batch, and FEFO
previews accept `it_request_locations`; each request is limited to its listed
locations within the shared allowlist, and preview rows echo those scope rows.
Blank, unknown, duplicate, and preferred-outside-scope rows fail before stock
reads or unit conversion.
`preview_cc_locations_by_date` adds a required date and priority to
each location demand. Earlier dates consume shared location balances first;
higher priorities allocate first on the same date, and result rows stay in
caller order. Caller-resolved `it_projected_receipts` add base-unit supply at a
specific location once each demand reaches the receipt date. The method keeps
the same location ranks, scopes, allowlist, per-demand and global full-quantity
options, and optional grouped ATP diagnostics as the undated location preview.
Each result echoes the effective full-quantity setting.
Each dated row may also set `minimum_coverage_pct` from 0 through 100. The
allocator checks eligible base-unit stock at the required date, including
caller-provided projected receipts, after location scopes and safety-stock
protection. A row below its floor consumes no location balance; UOM and ATP
results preserve the threshold.
`issue_cc_locations_by_date` accepts these dated rows directly,
checks that every split echoes its preview date and priority, and then validates
the storage allocations before posting. It preserves row-level
`require_full_quantity` behavior when partial issue is enabled globally.
`preview_cost_center_batches` adds an explicit batch per demand and returns
batch, expiration, storage-location, and converted quantity splits. Requests
share balances for the selected material, plant, and batch in caller order by
default. Set `iv_prioritize_by_priority = abap_true` to allocate higher integer
priorities first; input order breaks ties, and result rows return in caller
order with priority echoed. `preview_cc_batches_by_date` instead processes
earlier required dates first, then higher priorities on the same date; an
omitted date uses today. Projected batch receipts become available only once a
demand reaches their receipt date. The date-first method returns rows in caller
order and echoes each required date. Set `require_full_quantity = abap_true` on a
request to leave stock available when that batch cannot fully cover it; the
global `iv_require_full_quantity` applies the rule to every request. Result
rows echo the effective setting.
Each exact-batch row may set `minimum_coverage_pct` from 0 through 100. The
allocator checks eligible base-unit stock after batch, expiry, shelf-life,
location, projected-receipt, and safety-stock rules. A row below its floor
receives zero before any batch balance is consumed. The allocation summary
and its batch splits echo the floor; the date-first wrapper preserves it.
An optional `required_date` filters the selected batch through that date; a
positive `minimum_shelf_life_days` extends the required life and excludes
unknown expirations. Expiration on the threshold date is eligible; an unknown
expiration remains eligible when no positive minimum is requested. An optional
storage location is hard by default; fallback mode tries it first and may use
other locations while staying within the selected batch. Its
`it_location_priority` option orders those fallback locations.
`it_request_location_priorities` overrides the shared order for an individual
demand; lower positive ranks are used first and unranked locations follow by
location code. The method does not substitute a different batch or create
reservations. Pass `it_projected_batch_receipts` to add caller-resolved supply
for the selected batch in material base units. A receipt contributes only at
its location and on or after its receipt date, once the demand's effective date
reaches that date; its expiration must remain eligible. The preview does not
derive projected rows from planning documents. Set
`iv_include_undated_batches = abap_false` to exclude batches without a known
expiration from availability and splits; the default is `abap_true`. Set
`iv_check_atp = abap_true` with `iv_atp_check_rule` to attach SAP ATP
diagnostics to each preview row. Checks group the locally allocated batch
splits by material, plant, base unit, and effective check date; cumulative
quantities and confirmations are reported beside the same local allocation.
The date-first wrapper forwards these checks using each split's required date,
while retaining caller-order rows and row-level full-quantity decisions.
`issue_cost_center_batches` carries the echoed required date, minimum shelf
life, and undated-batch policy into its posting check. It checks eligibility as
of the later of the required date and goods-movement posting date.
Location, exact-batch, and FEFO issue methods also preserve each preview row's
`require_full_quantity` rule when `iv_require_full_allocation = abap_false`.
They reject a partial split for a strict row before posting. A valid strict row
with zero allocation and no splits can remain in the same call as other rows
that have quantity to issue.
`preview_cost_center_fefo` selects eligible batches by earliest expiration for
multiple cost center demands. Requests share batch balances in caller order by
default. Set `iv_prioritize_by_priority = abap_true` to allocate higher integer
priorities first; input order breaks ties, and summaries still return in caller
order with priority echoed. The option applies across cost centers that share
material and plant stock.
Optional location fallback checks the preferred location first. Pass
`it_location_priority` to order locations when the same batch and expiration
date exist in multiple locations; expiration and batch order remain primary.
`it_request_location_priorities` can override that order for an individual
demand; lower positive ranks win within the same expiry and batch, and
unranked locations follow by location code. `preview_cost_center_fefo_date`
forwards the same ranks while allocating earlier required dates first.
Each demand may set `batch` to restrict its candidates to one exact batch; the
batch must still meet its effective shelf-life requirement, and the preview
does not substitute another batch.
The as-of date and shared minimum remaining shelf life apply to every demand.
Each demand can also specify `minimum_shelf_life_days`; the greater of the two
values applies to that row and appears in its preview. A demand may also set
`fefo_as_of_date`; the later of it and the shared `iv_as_of_date` controls the
expiry filter and appears on its result and batch splits. Results include the
selected batch splits with source-unit quantities. `issue_cost_center_fefo`
validates the row policy, effective date, and shelf life against every split
before posting. It also carries each preview's request-location scope into the
issue validator, which rejects malformed scope rows and splits outside the
request scope before the movement API call. This preview does not create
reservations or run SAP batch determination.
Base and dated FEFO demand rows can set `require_full_quantity = abap_true` for
row-level all-or-nothing allocation. A short row receives no batch split and
leaves its eligible stock for later rows; the existing shared
`iv_require_full_quantity` applies to every row. Preview summaries echo the
effective rule, including the shared setting, and invalid values fail before
stock reads or unit conversion.
Each FEFO row may also set `minimum_coverage_pct` from 0 through 100. The
floor is checked against eligible base-unit stock after expiry, shelf-life,
location, projected-receipt, and safety-stock rules; rejected rows consume no
batch balance. Summary rows and batch splits echo the floor through date-first
and ATP preview paths.
`preview_cost_center_fefo_date` adds a required date and integer priority to
each demand. Earlier required dates consume shared stock first; higher
priorities run first on the same date, and input order breaks ties. The preview
returns rows in caller order and echoes the date and priority. Each demand's
expiry cutoff is the latest of the shared as-of date, its `fefo_as_of_date`, and
its required date. It remains a local stock snapshot and does not reserve the
selected batches. Base and date-first previews also accept
caller-resolved `it_projected_batch_receipts` in material base units. Receipts
become available only when each demand's effective as-of date reaches the
receipt date, and still follow FEFO expiry eligibility and request-location
scopes; the service does not derive them from planning documents. The date-first
wrapper also accepts the ATP options and forwards them through its required-date
and priority ordering. With
`iv_check_atp = abap_true` and an
`iv_atp_check_rule`, the preview checks locally allocated splits once per
material, plant, base unit, and effective check date. Each matching row reports
the grouped cumulative request and SAP confirmation quantities without
changing its FEFO allocation.
`reserve_cc_fefo_date_atomic` applies the same ordering before preallocating and
creating one reservation per demand in a single atomic group. It requires full
coverage for every row and returns item results in caller order, while SAP
create calls follow date/priority order. Result rows include `required_date` and
`priority`. It also supports test runs and the same optional ATP precheck as the
undated atomic method.
`reserve_cc_fefo_date_bulk` follows that order while committing each demand
independently; a later failure does not undo earlier successful reservations.
It also returns rows in caller order with `required_date` and `priority`, and
supports test runs and ATP checks. Its top-level `is_committed` reports whether
any independent demand reservation committed.
Each multi-demand cost-center preview accepts
`iv_require_full_quantity = abap_true`. A demand that cannot be fully covered
gets zero allocation and leaves the remaining stock for later requests. This
applies to plant, dated, location, exact-batch, and FEFO previews; ATP-enabled
dated previews keep their SAP diagnostics separate from this local allocation
rule.
Atomic and bulk reservation demand rows also accept `minimum_coverage_pct`
from 0 through 100. The preallocation checks it against eligible base-unit
stock after location, exact-batch, FEFO, expiry, fallback, and safety-stock
rules; a rejected demand receives no allocation. The date-first FEFO atomic
and bulk wrappers preserve each row's floor. Atomic reservations still commit
or roll back the group together, while bulk results report each demand
independently.
`reserve_cost_centers_atomic` preallocates the full demand group before writing.
Use shared location balances, caller-selected batches on every demand, or set
`iv_use_fefo_batches = abap_true` to choose eligible batches by expiration. In
FEFO mode, a demand may set `batch` to restrict that row to one exact batch;
other rows still use FEFO. Without FEFO, location-only and explicit-batch
demands cannot be mixed in one group. Every requested quantity must be
available before it writes. Each row's `required_date` must be a Gregorian
date in every allocation mode; malformed dates are rejected before stock
reads. It creates one reservation per demand, commits the group once, and rolls
the group back if a creation or commit fails. Location
fallback and safety-stock protection are supported; `it_location_priority`
orders fallback locations while preserving a demand's preferred location as
first. `it_request_location_priorities` can override that order per request;
positive local ranks win before shared order, and unranked locations follow by
location code. Atomic and dated atomic reservations validate rank IDs, positive
ranks, and duplicate request/location rows before stock reads, then preserve
the ranks in their group preview. Bulk variants validate the full rank table
before reads or writes and scope it to each one-demand reservation. All reservation modes accept `it_request_locations`; each request is
restricted to its listed locations within the shared allowlist, and result
items preserve the caller's scope. Date-first FEFO preview and reservation
wrappers pass scopes through unchanged. Invalid scope rows fail before stock
reads or writes. `reserve_cc_atomic_by_date` applies the same
atomic prechecks and options while allocating and creating rows in ascending
required date, then descending priority on the same date. It returns item
results in caller order and rejects malformed dates before stock reads.
`reserve_cc_bulk_by_date` follows the same date and priority order while
committing each reservation independently. A later failure does not undo
earlier successful rows, and returned items remain in caller order. It accepts
the same scope, safety-stock, FEFO, ATP, and test-run options and validates
required dates before reading stock.
In FEFO mode, expiration and batch
order remain primary and location priority only resolves same-batch,
same-expiration ties. FEFO uses
`iv_fefo_as_of_date` and `iv_fefo_min_days`, with the greater of the shared
minimum and a demand's `minimum_shelf_life_days` applying to that demand. The
effective minimum is returned on each result row. Exact-batch demands also use
their `required_date` to filter expired stock; a positive per-demand minimum
extends the required life. Single preview/reservation calls accept
`iv_batch_min_days` for the same check, and the selected batch must be supplied.
FEFO also uses the later of the shared as-of date, a demand's
`fefo_as_of_date`, and its reservation `required_date`; the effective date is
returned with each result. A demand date override is rejected when FEFO is
disabled, and a nonzero demand minimum requires either FEFO or an exact batch.
`iv_include_undated_batches` defaults to `abap_true`; set it to `abap_false`
to exclude unknown-expiry stock from exact-batch and FEFO previews and
reservations. The atomic, bulk, and single-demand cost-center flows forward the
same option, and invalid values are rejected before unit conversion or stock
reads.
For FEFO groups or groups where every row selects an explicit batch, set
`iv_prioritize_by_priority = abap_true` to allocate higher integer priorities
first; caller order breaks ties, and result rows stay in caller order with each
priority echoed. Atomic creation calls follow the same priority order. The
option is rejected for unbatched requests.
`iv_test_run = abap_true` runs each reservation
in test mode and skips the commit; the result reports allocations, per-demand
API responses, commit status, and rollback status.
Non-test creates require a distinct reservation number for each demand. A
duplicate number fails the group and triggers rollback; reservation numbers are
cleared from the result after any group rollback.
Pass `iv_check_atp = abap_true` with `iv_atp_check_rule` to add cumulative SAP
ATP diagnostics by material, plant, base unit, and required date. Each date group
is checked with its cumulative quantity and the result is attached to each
matching demand with `is_fully_confirmed`; this diagnostic does not change the
local allocation. Set `iv_require_atp_confirmation = abap_true` to stop the entire group before any
reservation API call when a date group's confirmed quantity is short.

`reserve_cost_centers_bulk` accepts the same demand rows and allocation
options, but processes each demand independently in caller order. It validates
all request keys and shared options before the first write, then creates and
commits one reservation per successful demand. A failed demand is rolled back
and later demands still run; earlier successful reservations remain committed.
In FEFO mode, each row may set `batch` to constrain that demand to one exact
batch, as in atomic mode.
With `iv_prioritize_by_priority = abap_true`, independent FEFO or explicit-batch
creates run in descending priority order with stable input order for ties;
returned rows keep the caller's order. For explicit-batch mode, every row must
name a batch. Unbatched requests cannot use this option.
Results report each allocation, API messages, commit/rollback state, and
`is_fully_confirmed` when ATP checking is enabled. The top-level
`is_committed` is true if any demand committed and false for simulations or
when none committed.
Empty input succeeds without a stock read or write. Set `iv_test_run` to
validate each demand in SAP test mode without committing.
The method and its date-first bulk wrappers also accept
`iv_stop_on_failure`, defaulting to `abap_false`. When enabled, the first
failed reservation stops later creates in the method's execution order: caller
order by default, descending priority when priority ordering is enabled, and
required-date then priority order in the dated wrappers. Unattempted rows stay
in the result with `is_skipped`; successful, failed, and skipped counts are
separate, and `stopped_on_failure` remains true even when the failed demand is
last. Earlier independent reservations remain committed.

Set `iv_use_fefo_batches = abap_true` to reserve automatically selected
batches by earliest expiration date. The as-of date defaults to today;
`iv_fefo_min_days` can require a minimum remaining shelf life. Expired batches
are excluded, and undated batches are excluded when the minimum is positive.
`iv_batch` restricts FEFO to that batch while keeping the FEFO expiration and
shelf-life checks. `iv_fefo_min_days` applies to the FEFO demand, and a positive
`iv_batch_min_days` can raise the shelf-life threshold for that selected batch;
the greater minimum applies. A supplied storage location remains a hard
restriction unless `iv_allow_fallback = abap_true` is passed, in which case it
is tried first and other locations are considered afterward.

## SAP installation via abapGit

The repository includes [abapGit object metadata](https://docs.abapgit.org/development-guide/serializers/file-formats.html)
for its custom classes and interfaces. The root [`.abapgit.xml`](https://docs.abapgit.org/user-guide/repo-settings/dot-abapgit.html)
selects `/src/` as the starting folder, so abapGit imports the custom objects and
package definition from `src/`. The `stubs/`, `scripts/`, `deps/`, and `output/`
folders are tooling artifacts and are outside that SAP import folder.

1. Create or link an abapGit repository for this Git repository.
2. Assign it to a customer package in the target SAP system; `PREFIX` folder
   logic lets the repository use the package selected during installation.
3. Pull the repository and activate the imported objects.
4. Check that the target release provides the standard dictionary objects and
   BAPIs used by the adapters, then run SAP-side smoke tests before posting.

When adding a custom class or interface under `src/`, run
`npm run generate:abapgit` to create missing metadata, then run `npm test`.
Metadata generation is local tooling; it does not validate the target system's
ABAP release, DDIC definitions, BAPI signatures, or activation behavior.

## Production construction

`ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_STOCK_SERVICE()` wires the stock service
to the MARD repository, material UOM converter, and SAP availability adapter.
`CREATE_GOODS_MOVEMENT_SERVICE()` wires the goods-movement service to its BAPI
adapter and material UOM repository. `CREATE_RES_ISSUE_SERVICE()` wires
reservation detail reads and goods-movement posting to their BAPI adapters and
the material UOM repository. `CREATE_STO_ORDER_SERVICE()` wires the stock-
transfer order service to its purchase-order BAPI adapter.
`CREATE_SALES_ORDER_ALLOC()` wires the sales-order allocation
service to the sales-order BAPI, MARD stock repository, material-availability
BAPI, reservation BAPI, and sales-order stock service used for direct FEFO
reservations. `CREATE_SALES_ORDER_SERVICE()` wires sales-order
read and change operations to the sales-order BAPI. The service constructors
remain public for applications that supply their own adapters.
`CREATE_SALES_STOCK_SERVICE()` reads sales-order-specific stock and open
reservations by sales document item. `CREATE_SO_RES_READ_SERVICE()` wires
reservation detail reads to the reservation BAPI adapter.
`CREATE_SO_RESERVATION_SERVICE()` wires reservation release workflows to the
reservation BAPI adapter and stock repository used to find order reservations.
`CREATE_PROJECT_STOCK_SERVICE()`
wires WBS stock and reservation reads to the project-stock repository and the
material UOM converter. `CREATE_PROJECT_RESV_SERVICE()` wires the WBS
reservation workflow to the project reservation BAPI, project-stock reader,
material UOM converter, and goods-movement BAPI used for reservation issues.
`CREATE_STOCK_TRANSFER_SERVICE()` wires in-transit stock reads to the STO
repository and material UOM converter. `CREATE_PURCHASE_ORDER_SERVICE()` wires
PO creation and change workflows to the purchasing BAPI and material UOM
converter. `CREATE_PLANNED_ORDER_SERVICE()` wires planned-order management to
its BAPI. `CREATE_PLANNED_READ_SERVICE()` wires bulk planned-order reads
to the PLAF repository. `CREATE_PROD_COMP_SERVICE()` wires production-component
reads, stock and ATP checks, replenishment planning, and goods movements to
their SAP adapters. `CREATE_PROD_ORDER_SERVICE()` wires production-order
operations to their BAPI and connects the ATP release gate to the
production-component service. `CREATE_PROD_ORDER_READ_SERVICE()` wires bulk
order, status, operation, and confirmation reads to the production-order
repository.
`CREATE_PREQ_SERVICE()` wires purchase-requisition reads and writes to the PR
BAPI. `CREATE_CC_RESERVATION_SERVICE()` wires cost-center stock reservations
to the MARD repository, reservation API and reader, material UOM repository,
and ATP adapter. `CREATE_REPL_SOURCE_SERVICE()` wires purchasing-source
selection to the info-record, source-list, and quota repository.
`CREATE_QUALITY_STOCK_SERVICE()` combines the stock service and goods-movement
service for fresh FEFO rechecks before movements 321 and 322.

```abap
DATA(lo_stock_service) =
  zcl_stock_allocation_factory=>create_stock_service( ).
DATA(lo_quality_stock) =
  zcl_stock_allocation_factory=>create_quality_stock_service( ).
DATA(lo_reservation_issue) =
  zcl_stock_allocation_factory=>create_res_issue_service( ).
DATA(lo_sales_order_allocation) =
  zcl_stock_allocation_factory=>create_sales_order_alloc( ).
DATA(lo_sales_orders) =
  zcl_stock_allocation_factory=>create_sales_order_service( ).
DATA(lo_sales_stock) =
  zcl_stock_allocation_factory=>create_sales_stock_service( ).
DATA(lo_sales_reservations) =
  zcl_stock_allocation_factory=>create_so_res_read_service( ).
DATA(lo_sales_reservation_release) =
  zcl_stock_allocation_factory=>create_so_reservation_service( ).
DATA(lo_project_stock) =
  zcl_stock_allocation_factory=>create_project_stock_service( ).
DATA(lo_project_reservations) =
  zcl_stock_allocation_factory=>create_project_resv_service( ).
DATA(lo_stock_transfer) =
  zcl_stock_allocation_factory=>create_stock_transfer_service( ).
DATA(lo_purchase_orders) =
  zcl_stock_allocation_factory=>create_purchase_order_service( ).
DATA(lo_planned_orders) =
  zcl_stock_allocation_factory=>create_planned_order_service( ).
DATA(lo_planned_order_reads) =
  zcl_stock_allocation_factory=>create_planned_read_service( ).
DATA(lo_production_components) =
  zcl_stock_allocation_factory=>create_prod_comp_service( ).
DATA(lo_production_orders) =
  zcl_stock_allocation_factory=>create_prod_order_service( ).
DATA(lo_production_order_reads) =
  zcl_stock_allocation_factory=>create_prod_order_read_service( ).
DATA(lo_purchase_requisitions) =
  zcl_stock_allocation_factory=>create_preq_service( ).
DATA(lo_cc_reservations) =
  zcl_stock_allocation_factory=>create_cc_reservation_service( ).
DATA(lo_replenishment_sources) =
  zcl_stock_allocation_factory=>create_repl_source_service( ).
```

## Integration limits

The `stubs/src/` definitions model only fields used by the local tooling; SAP's
delivered dictionary and function module signatures are authoritative at
deployment. Local verification uses fake APIs and does not connect to an SAP
system. The delivery repository SQL is exercised against SQLite test tables;
this does not validate SAP authorization, DDIC, or database behavior.
`quantity` and `base_quantity` describe the requested item quantity;
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
Schedule lines also expose `material_availability_date` from `VBEP-MBDAT`.
`preview_order`, `reserve_order`, and the multi-order date methods use
`VBEP-EDATU` by default; set `iv_use_material_avail_date` to use MBDAT for
demand, ATP, and reservation requirement dates. In single-order methods,
`iv_prioritize_by_date = abap_true` then orders allocation by MBDAT. This option
requires every open demand to have a schedule line with a material availability
date. A blank EDATU is accepted when MBDAT is present; EDATU remains required
when the option is off. SAP identifies EDATU as the schedule-line date and MBDAT as the material availability date
([schedule-line field definitions](https://help.sap.com/saphelp_snc70/helpdata/en/dd/db9e759d4f453a8e081ad7df5f7770/content.htm?no_cache=true)).
If an item has no schedule lines, the read falls back to its `VBAP` item
quantities and has no requested date. `preview_order`, `reserve_order`, and the
multi-order date methods accept `iv_unscheduled_required_date` to supply one
validated date for open item-level rows whose requested date is blank. The
allocation and ATP result use that date, and reservation methods pass it as the
reservation requirement date. Schedule-line dates remain authoritative;
`iv_use_material_avail_date` still requires schedule-line MBDAT. Confirmed-
quantity mode rejects open items without schedule-line confirmation data.
The preview and reservation methods also accept `it_unscheduled_required_dates`,
with one `sales_document`, `item_number`, and `required_date` per item. Rows
must identify the selected order and an item without schedule lines; duplicate
keys and invalid dates are rejected. A matching per-item date takes precedence
over `iv_unscheduled_required_date`, which remains the default for other
unscheduled items.
Single-order preview and reservation results also include `order_summaries`,
grouped by sales document, material, plant, and base unit, with checked
requested, allocated, and shortfall base quantities and demand-line counts.
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
`GET_STOCK_STATUS` and its bulk variant report raw plant totals for `MARD-LABST`,
`MARD-INSME`, and `MARD-SPEME`, plus active unrestricted `RESB` reservations. Each reservation item's open
quantity is clamped to `max(BDMNG - ENMNG, 0)` before rows are aggregated,
so an over-withdrawn item cannot cancel another item's demand. The report
also includes a clamped available-unrestricted estimate. SQLite-backed
repository tests execute both scalar and bulk queries alongside scalar and bulk
MARD location reads, scalar and bulk RESB open-stock reservation reads, batch
reads, and standalone scalar and bulk MARC safety-stock reads.
They check plant totals, withdrawal netting, reservation lifecycle filters,
safety-stock subtraction, and caller-order results for duplicate and missing
bulk scopes, but do not model target-system ATP configuration. The report also
returns static `MARC-EISBE` and an available quantity after that buffer; neither
quantity represents every ATP element or dynamic safety-stock behavior. The
SQLite tests also execute `GET_UNRESTRICTED_STOCK` directly, including the zero
clamp when open reservations exceed unrestricted stock; that method does not
apply safety stock. It nets stock and open reservations in high precision, then
rejects an available result outside MARD-LABST. Plant stock status totals
accumulate stock categories and
open reservations in high precision. The bulk read keeps LGORT in its
FOR ALL ENTRIES projection so equal balances at separate locations are
both counted. If an output total cannot fit its SAP quantity field,
scalar and bulk status reads raise zcx_invalid_stock_request.

Date-based projections can add PO receipts, issued or unissued STO quantities,
subtract unissued outgoing STO quantities, and add production, PR/STO PR, and
planned-order receipts. These are local schedule estimates from `EKET`, `EKPO`,
`EKKO`, `AFPO`, `AFKO`, `AUFK`, `EBAN`, `MARA`, `MARM`, and `PLAF`. Direct
SQLite-backed tests execute bulk standard PO, confirmation-aware PO, external
scheduling-agreement, STO schedule, production/process-order, and PR/STO PR
reads. Direct scalar projection tests also cover PO, process-order, and
confirmation-aware PO rows.
The bulk dated-availability method reuses the projected-receipt reader for
standard PO and incoming-STO supply. It batches production item, date, and
release data separately from outgoing-STO deductions. Tests check header/item
eligibility, schedule and confirmation reductions, order release filters,
multiple date horizons, outgoing-STO deductions, unit conversion, and
requisition filters.
Planned-order tests cover fixed/unfixed flags and alternative-unit conversion.
Every source still needs validation against live schedules and target-system
units. These estimates do not replace SAP ATP. Plant-date availability nets
storage-location balances, projected receipts, outgoing transfers, and
reservations in high precision, then checks the final available quantity fits
MARD-LABST. Out-of-range results raise zcx_invalid_stock_request.

Caller-supplied cutoff dates, dated allocation requirements, and FEFO as-of
dates are checked as Gregorian calendar dates before UOM conversion, stock
reads, or ATP calls. This rejects malformed dates; SAP still determines whether
a valid date is usable for the material, plant, and planning horizon.
`GET_STOCK_STATUS_BY_LOCATION` aggregates the same category quantities by
`LGORT`; its available-unrestricted values use the location reservation
calculator, including the deterministic distribution of plant-level
reservations. Each RESB item is clamped to a nonnegative open quantity before
location totals are aggregated in high precision, avoiding overflow when
many reservations are combined. Negative location balances reduce the plant
total, so their deficit is carried across positive locations; location results
remain consistent with the plant-level available quantity. SQLite-backed
repository tests execute both scalar location queries and check category
totals, exact-location deductions, and distribution of unscoped reservations or
reservations assigned to a location with no MARD row.
`GET_STOCK_STATUS_BY_BATCH` returns unrestricted batch quantities and their
available estimates by `LGORT` and batch, including zero-available rows. It
reads the partial `MCHB`, `MCHA`, `MCH1`, and `RESB` stubs and uses the batch
reservation calculator. SQLite-backed repository tests execute both scalar
and bulk MCHB/MCHA/MCH1/RESB reads, check plant expiry precedence, exact
location/batch and unscoped reservation deductions, net negative batch balances
against positive batches, clamp open quantities per RESB item before batch
reservation totals are aggregated, ignore closed and special-stock reservations,
and verify that the scalar available-stock wrapper
omits zero balances. Service tests also verify mapping with doubles.
Sales-order previews also read active `RESB` reservations assigned to the order.
The repository clamps each item to `max(BDMNG - ENMNG, 0)` before grouping
positive open quantities by `KDAUF`, `KDPOS`, `KDEIN`, `BDTER`, material, and
plant, so an over-withdrawn item cannot cancel another item's demand. SQLite-backed tests execute this query and cover partial withdrawals,
schedule-line grouping, and deleted/final-issue/movement/special-stock filters.
Target-system BAPI field propagation and the fallback when schedule-line/date
keys do not match still need validation.
Cost-center reservations use movement type 201 and the `COSTCENTER` header
assignment with `BAPI_RESERVATION_CREATE1`; live creates require a returned
reservation number, while successful test runs may omit that simulated key.
Alternative units are converted through `MARA`/`MARM`. The local tests use repository/API doubles and do not
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
the allocation arithmetic, and a SQLite-backed repository test executes the
bulk `MARC` safety-stock read. Target-system ATP configuration remains
unverified. This does not model time-dependent safety stock or every
checking-rule scope.
Batch availability is a separate estimate based on `MCHB-CLABS` and open
`RESB` quantities. Reservations are deducted using storage location, batch, and
`RESB-BWTAR` when those fields are supplied. Blank selectors apply to compatible
balances in ascending location and batch order. An over-reserved valuation type
reduces only balances in that valuation type; other reservation overages reduce
remaining compatible balances to avoid overstating free quantity. `ALLOCATE_BY_BATCH` requires a caller-selected batch and never
substitutes another batch. It reads stock for all unique material/plant pairs
through one validated batch-status bulk call. Sales-order batch selections must
cover every positive-open schedule line; item-wide choices cover all open lines, while
schedule-line choices can select different batches on one item. Partial,
duplicate, or mixed item-wide and schedule-line choices are rejected before
stock is read. FEFO mode selects batches automatically by expiration date but
does not run SAP's configured batch determination. Batch status rows expose the
valuation type from `MCHA-BWTAR` for batch-managed materials and from
`MCHB-CHARG` for non-batch-managed split-valuated stock.
`GET_VALTYPE_STOCK_STATUS` and its bulk form group available quantities by
storage location and valuation type; reservation deductions honor
`RESB-BWTAR`. Their UOM forms convert each grouped quantity while returning
both base and requested unit codes. `PREVIEW_BY_VALTYPE` allocates requests by
effective `as_of_date` ascending, then descending integer `priority`; an
omitted date uses today and an omitted priority defaults to zero. Input order
breaks same-date, same-priority ties. Allocation summaries echo the priority
and one-based `allocation_sequence`; result rows keep caller order. Splits also
keep caller-demand order and echo `allocation_sequence`, so callers can restore
the demand-processing order by sorting the split rows. Each split also carries
a one-based `split_sequence` for source consumption within its demand. UOM
splits preserve both inside their nested `split` row; these fields describe
preview order, not a posting sequence.
split rows also echo `batch_priority_rank`: a positive value identifies an
explicit request rank, while zero means the source was unranked. Together, the
sequence and rank show how source eligibility and requested batch ordering
produced the local split. Each row also reports `available_before_qty` and
`available_after_qty` for that source balance around the split, in base units
and after safety-stock withholding. Later demands can consume an after-quantity
left by an earlier split. UOM split wrappers add `source_avail_before_qty` and
`source_avail_after_qty` in the requested unit; the after-value is the residual
after converting the allocation, so before = allocated + after. The nested
split continues to report base-unit quantities. Physical batches expired before each demand's
`as_of_date` are excluded; an omitted date uses the current date. Demands can
require a minimum shelf life or known expiry. Non-batch-managed split stock is not date-filtered.
`iv_protect_safety_stock` defaults to `abap_false`. When enabled, the preview
loads static plant-level `MARC-EISBE` once per material/plant and withholds it
across valuation balances: current stock is protected first in location,
valuation-type, and batch order, then projected receipts by receipt date. The
summary echoes the flag and base-unit safety-stock quantity; the UOM result
also returns `source_safety_stock_qty`. This is a static buffer, not a
time-dependent safety-stock policy.
`iv_include_undated_batches` defaults to `abap_true`; set it to `abap_false` to
exclude physical batches without an expiry date. A demand can set
`allow_undated_batches = abap_true` to opt back in, while
`require_known_expiry = abap_true` always excludes undated batches and cannot
be combined with that override. The summary echoes the row override and the
effective undated-batch setting.
Optional `it_projected_receipts` rows add caller-resolved quantities by material,
plant, location, and valuation type; `base_quantity` is in the material base
unit. Only receipts dated on or before the demand's effective date count; the
demand date defaults to today. Both base and UOM results echo the validated
receipt input rows in `projected_receipts` order, including receipts left
unused or excluded from a particular demand by its date or scope. Split rows
show the receipt quantities actually allocated. The summary separates current and projected
availability. It reports `current_allocated_quantity` and
`projected_allocated_quantity` separately, so callers can see how much of the
request came from posted stock and caller-projected receipts. In the UOM
result, `source_current_allocated_qty` and `source_projected_allocated_qty`
split `source_allocated_quantity`; current source quantity is the residual
after converting the projected allocation. `source_projected_qty` remains
eligible projected availability. Splits identify projected rows and their
availability dates.
The base, UOM, and ATP valuation previews accept the call-wide
`it_excluded_reservations` list. Each key must identify a positive open RESB
reservation for a material and plant in the demand set; keys must be complete
and unique. Matching reservation quantities are omitted from current batch
stock netting for the entire preview call, so the released quantity is shared
by its demands and can be split across them using the normal allocation rules.
Results echo the validated keys as `excluded_reservations`; UOM returns them
in its summary and ATP preserves them in `local_estimate`. This is a planning
override only and does not change or close the SAP reservation.
Projected splits retain `source_type`, `source_document`, `source_item`,
`source_plant`, and `source_schedule_line`; current-stock splits leave these
fields blank. Set `source_type` and `source_document` together. The remaining
source fields require a source document.
Each receipt sets `batch_managed`: managed material requires a physical `batch`;
non-managed split valuation leaves `batch` and `expiration_date` blank and uses
`valuation_type` as its identity. Repeated receipts for the same physical batch
must agree on valuation type and expiry. The marker must agree across all
receipt rows for the material/plant and with any current stock rows; a known
expiry on current stock must match the receipt. Do not include quantities already represented in
current stock. An optional
allowed location list restricts both availability and allocation. For each request,
request-specific location priorities take precedence over the global location
order; any remaining allowed locations follow alphabetically, then batches are
processed in order. `it_request_locations` can further restrict eligible
locations for each request. Scope rows must name an existing request and a
nonblank location, and duplicate pairs are rejected. Request scopes intersect
the global allowed-location list; a demand naming one location must include it
in its request scope. The result echoes the scope rows, and the UOM form
validates and forwards them before unit conversion. It returns both a summary
and detail splits. Both base and UOM results echo the validated request
location-priority rows in `request_location_priorities`, sorted by request,
rank, and storage location for audit. They also echo both global rules:
`storage_location_priority` preserves caller order, and
`allowed_storage_locations` lists eligible locations.
`it_request_batch_candidates` restricts the batch keys eligible for each
request. Candidate rows must name a known request and nonblank, unique batch
key. The same candidates constrain availability totals and splits and are
echoed in the result; the UOM form validates them before conversion. Keys match
the split `batch` field: for batch-managed material this is the physical batch;
for non-batch split valuation it is SAP's dummy `MCHB-CHARG` valuation key.
`it_request_batch_priorities` can order eligible batch keys for each request.
Ranks must be positive and each request/batch pair unique; when a candidate
list is present, every ranked batch must appear in that list. Within each
location and posted/projected group, ranked batches precede unranked batches
in rank order; batch code breaks rank ties and orders unranked batches. Posted
balances remain ahead of projected receipts. The UOM form validates and
forwards the ranks before conversion, and both forms echo them in the result.
`it_request_projected_sources` restricts caller-projected receipts per request
by optional `source_type`, `source_document`, `source_item`, `source_plant`,
and `source_schedule_line` selectors. Each row requires a known request and at
least one of `source_type` or `source_document`; blank selector values match
any value. Rows must be unique by the complete request/source tuple and match
at least one supplied projected receipt for that request's material, plant,
and valuation type, including every specified selector. When a request has
this list, only matching projected receipts count toward its availability or
splits; current stock remains eligible, and projected receipts that do not
match the selected source type or document are excluded for that request.
Base and UOM results echo the validated rows; UOM validates them before
conversion, and ATP forwards the same filter.
`it_req_projected_exclusions` removes matching projected receipts per
request, so callers can reject a source without listing every other eligible
source. Rows use the same source selectors and validation as the allowlist;
overlapping rows form a union. If both inclusion and exclusion rows are
supplied, a projected receipt must pass the inclusion selectors and match no
exclusion selector. Exclusions affect projected receipts only; current stock
remains eligible. Base and UOM results echo the rows as
`request_source_exclusions`; UOM validates them before conversion, and ATP
forwards the same exclusion list. Each allocation summary also reports
`excluded_projected_quantity`, the remaining projected balance that
passed the demand's location, batch, date, and shelf-life checks but failed a
source selector at that allocation step. Prior demands may already have
consumed part of those balances. The UOM summary reports the excluded amount
in the requested unit as `source_excluded_projected_qty`.
Allocation summaries also distinguish projected receipts dated after the
effective `as_of_date` as `future_projected_quantity`. Batches that are
available by that date but fail the effective expiry and shelf-life rules
contribute to `proj_expiry_excluded_qty`. That expiry total is split into
`undated_proj_excl_qty` for batches without an expiry date that the effective
policy rejects, and `dated_expiry_excl_qty` for known expiry dates that are
past the effective date or do not meet the minimum shelf life. The two base
quantities sum to `proj_expiry_excluded_qty`. These diagnostics are counted
after request location and batch-candidate scope, and before source-filter
exclusions; a receipt contributes to the first failed availability check
only. The UOM summary exposes the quantities as `source_future_projected_qty`,
`source_undated_proj_excl_qty`, `source_dated_expiry_excl_qty`, and
`source_expiry_excluded_qty`. Prior allocations are reflected in the
remaining quantity for each demand step.
`it_req_projected_priorities` orders projected source receipts per request
using the same source selectors. Rows require a known request, a positive
`priority_rank`, and at least one of `source_type` or `source_document`; blank
selectors are wildcards. Each row must match a projected receipt for that
request's material, plant, and valuation type. Exact selector tuples must be
unique. Overlapping rows use the lowest matching rank. Within each location,
current stock stays ahead of projected receipts; among projected receipts,
lower source ranks come first and ranked sources precede unranked ones. Source
ranks take precedence over batch ranks and FEFO ordering; those existing rules
order receipts within the same source rank. The split echoes
`source_priority_rank` for ranked receipts and leaves it zero otherwise. Base
and UOM results echo the validated rows as `request_source_priorities`, and
ATP forwards the same ordering option.
`iv_fefo` defaults to `abap_false`; when enabled, location order and posted
before projected grouping within each location remain in effect, and
explicitly ranked batch keys still take precedence within each source group.
Within each location and current/projected group, unranked physical batches
with known expiry dates are allocated earliest-expiry first. Non-batch split
valuation keys follow those dated batches, and undated physical batches come
last. Static safety-stock withholding keeps its deterministic
location/valuation-type/batch order and happens before request allocation. The
result echoes `use_fefo`; UOM and ATP previews forward the option. This is a
local ordering rule and does not invoke SAP configured batch determination.
A demand row can also set `use_fefo = abap_true` to opt into FEFO when the
shared flag is false; a true shared `iv_fefo` applies FEFO to every demand.
Each allocation summary's `use_fefo` reports its effective setting, while the
top-level result echoes the shared flag. UOM and ATP previews preserve both
the shared option and each demand's opt-in.
`PREVIEW_BY_VALTYPE_UOM` accepts an alternative unit and returns the quantities
in that unit alongside the base-unit allocation. For non-batch-managed split
valuation, SAP stores the valuation type in the dummy `MCHB-CHARG` key. The
`batch_managed` result flag distinguishes this key from a physical batch; use
`valuation_type` in a posting request and leave its batch field empty when the
material is not batch-managed. For batch-managed materials the split includes
the physical batch. `PREVIEW_BY_VALTYPE_UOM_ATP` adds grouped, cumulative SAP
ATP diagnostics by material, plant, base unit, and effective date. Its rows
report the allocated quantity for the date, cumulative quantity through that
date, and cumulative confirmed/unconfirmed quantities. SAP ATP remains
plant-level: it does not receive the local valuation type, batch, location, or
caller-resolved receipt assignments, and its result does not change the local
splits. `request_atp_checks` adds one row for each positive allocation in
`allocation_sequence` order. These rows identify the request and expose its
allocated quantity, cumulative quantity through that request, and incremental
confirmed/unconfirmed quantities attributed from the grouped ATP response.
Each row echoes the local `valuation_type` and `priority` for context; these
fields do not filter SAP ATP.
Base-unit fields match SAP's check unit; `source_unit` and the allocated,
confirmed, and unconfirmed source quantities give each request's values in its
requested UOM. Their `atp_result` is the same raw date-grouped result as
`atp_checks`; SAP is not called separately for each request. The base-unit and
ordinary UOM preview methods remain local estimates from current stock and
optional caller-resolved receipts; they do not run SAP ATP, configured batch
determination, or a stock lock. Verify valuation mapping and posting behavior
against the target system's material setup.
Explicit sales-order batch selections are checked through the effective
reservation date: the schedule line's requested date, or the current date when
the item has no schedule date. A batch expiring on that date remains eligible;
an earlier expiry produces a preview shortfall and blocks reservations when
full allocation is required. A selection can set
`minimum_shelf_life_days` to require additional days beyond that date. A batch
on the minimum boundary remains eligible, while unknown expiry dates are
excluded when the minimum is positive.
Reservations created for schedule lines use their requested dates. Reservations
for items without schedule lines use the current date. Live sales-order
reservation creates require each returned reservation number; successful
test runs may omit generated numbers. Verify
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

`npm test` validates the PLAN configuration, checks typed SAP table-field
references across custom ABAP against local stubs, and checks additional
required fields for stock, material UOM, replenishment policy, planning
calendar, and planned-order queries. It then runs abaplint, transpiles
the ABAP sources with open-abap-core, and runs ABAP Unit tests through the
transpiler runtime. SQLite-backed Open SQL tests exercise scalar and bulk MARD
location stock,
MARA/MARM unit-of-measure, MARC replenishment-policy, T439I planning-period,
PLAF planned-order, RESB production-component, and MARC/MARD/MCHB stock-transfer
reads, plus MARD scalar unrestricted-stock reads and plant-status aggregates,
and RESB sales-order reservation
finder reads, VBAP/MSKA/MARA/MCHA/MCH1/RESB sales-order stock reads, bulk
EKPO/EKKO/EKET/MARA PO, scheduling-agreement, and STO receipt reads, EKET/EKES
confirmation-aware PO receipt reads, and the
EINA/EINE/EORD/EKKO/EKPO/MARC/EQUK/EQUP/RDPR/TMQ2 replenishment-source reads.
Integration tests also run the PIR and outline-source services over their
SQLite-backed repository queries to verify end-to-end filtering and result
mapping. Factory-backed stock allocation tests run MARD/RESB netting and
multiple shared demands, plus MCHB/MCHA/RESB reads through FEFO allocation to
verify expiry ordering and batch splits in the production composition.
Separate tests exercise AFKO/AFPO/AUFK production-order items,
JEST/TJ02T/TJ30T
statuses, and AFRU/AFVC confirmations and operations.
The definitions in `stubs/src/` are local tooling stubs; the target SAP system
supplies the real standard tables.
GitHub Actions runs this same validation on pushes and pull requests with
Node.js 22 and a pinned open-abap-core revision.

See [PLAN.md](PLAN.md) for implementation requirements and [NOTES.md](NOTES.md)
for progress.
