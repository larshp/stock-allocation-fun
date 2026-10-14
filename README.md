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
`ALLOCATE_BY_STORAGE_LOCATION` accepts an optional
`it_storage_location_priority` list. For a demand with a preferred storage
location and fallback enabled, that location remains first, followed by listed
locations in caller order; remaining locations follow in ascending code order.
Without a preferred location, the list is applied first. Unlisted locations
remain eligible, so this is an ordering rule rather than an allowlist. Blank or
duplicate entries are rejected before stock reads. The unit-aware variant
accepts and forwards the same priority list. An optional
`it_allowed_storage_locations` list filters eligible locations; an omitted or
empty list keeps all locations eligible. Blank and duplicate allowlist entries
are rejected before stock or UOM reads. A preferred location outside a
nonempty allowlist is invalid. Priority entries outside the allowlist are
ignored. Safety stock is deducted across the full plant inventory before the
allowlist filters allocation candidates.
The same `it_location_priority` and `it_allowed_storage_locations` options are
available on sales-order preview and reservation, cost-center location, exact-
batch, and FEFO previews, atomic cost-center reservations, and single
cost-center preview/reservation. A demand's preferred location stays first.
Exact-batch allocations remain within the selected batch; FEFO keeps expiration
and batch order, using location priority only to break ties for the same batch
and expiration date.
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
Repeated material/unit ratios are read once per allocation call.
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
reserve stock.
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
storage location. The optional `it_storage_location_priority` list orders
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
`ALLOCATE_PLANTS_ATP` adds a current-date SAP ATP comparison to the
unit-aware cross-plant preview. It groups positive local source allocations by
material, source plant, and base unit, then checks each group once with the
supplied `iv_check_rule`. The result keeps the local location splits and reports
the grouped ATP result plus confirmed and unconfirmed base quantities; ATP does
not change the local allocation or resolve its shortfalls.
`ALLOCATE_PLANTS_FEFO_ATP` adds the same current-date ATP comparison to
undated cross-plant FEFO allocations. It preserves source-plant and batch/location
splits from the local FEFO estimate, and groups positive allocations by material,
source plant, and base unit for ATP checks. ATP remains a plant-level diagnostic;
it does not confirm a selected batch or change its FEFO allocation.
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
`ALLOCATE_PLANTS_BY_DATE_LOC` applies the same date and priority ordering to
current stock and returns the actual source-plant and storage-location splits
in caller order. It supports source-plant order, source-location scopes,
location priority, allowlists, safety-stock protection, and full-quantity
allocation. It does not include projected receipts, since those sources have
no location assignment.
`ALLOCATE_PLANTS_DATE_LOC_UOM` accepts the same dated location-aware
cross-plant demands in material-specific units. It preserves date and priority
ordering, caller-order summaries and splits, and returns demand, source-plant,
and location quantities in both source and base units. Repeated material/unit
ratios are read once per call; base-unit quantities remain canonical when a
converted split rounds to the quantity field's precision. It uses current
location stock only and does not project receipts.
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
ATP remains diagnostic and does not change the local location allocation.
The dated ordinary cross-plant methods and their unit/ATP variants also accept
`iv_require_full_quantity`. It defaults to `abap_false`; when enabled, each
date/priority-ordered request consumes stock only when its full quantity is
available at that point in the shared allocation. A short request allocates
zero and leaves stock available to later requests. Dated ATP checks are made
only for positive local allocations.
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
`ALLOCATE_PLANTS_BATCH_ATP` adds a current-date SAP ATP comparison to the
unit-aware exact-batch cross-plant preview. It groups positive source splits by
material, source plant, and base unit for one check per group, while preserving
the caller's batch and storage-location allocations. The result reports ATP
confirmation separately; it does not change the local split or reserve stock.
`ALLOCATE_PLANTS_BATCH_IN_UNITS` accepts the same exact-batch demand in a
material-specific alternative unit. It validates and caches conversion ratios
before reading stock and returns demand, plant, and location splits in both
units; base-unit quantities remain canonical when converted amounts round.
`ALLOCATE_PLANTS_BATCH_BY_DATE` adds required-date ordering and integer priority
to exact-batch cross-plant allocation. Earlier dates consume shared batch stock
first; higher priority values run first within a date, with input order breaking
ties. Results return in caller order with date, priority, batch, plant, and
location details. `ALLOCATE_PLANTS_DATE_BATCH_UOM` accepts these dated requests
in material-specific units and validates conversions before stock reads.
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
greater than zero. This is a preview based on local stock estimates and does
not run SAP batch determination or create a transfer.
`ALLOCATE_PLANTS_BY_EXPIRY`, `ALLOCATE_PLANTS_FEFO_BY_DATE`, and their
unit-aware and ATP variants also accept `iv_include_undated_batches`, defaulting
to `abap_true`. Set it to `abap_false` to remove undated batches from eligible
source stock and FEFO splits. Invalid values are rejected before UOM or stock
reads.
`ALLOCATE_PLANTS_FEFO_BY_DATE` combines that cross-plant FEFO split with dated
demand priority. Earlier required dates consume shared batches first. Within
the same date, higher integer `priority` values consume shared batches first;
the default zero keeps input order, which also breaks equal-priority ties.
Results still return in input order with priorities on demand and batch splits.
Each batch must meet the requested minimum shelf life as of that demand's
required date. `it_storage_location_priority` breaks ties between locations
holding the same batch and expiration date without changing demand, source-plant,
expiry, or batch order.
Optional safety-stock protection withholds the buffer from latest-expiring
batches eligible for the earliest compatible demand. Undated batches qualify
only when `iv_min_days = 0` and sort after dated batches. The method considers
current batch stock only; it does not add projected receipts or replace SAP's
configured batch determination.
`ALLOCATE_PLANTS_FEFO_BY_DATE` and its unit-aware and ATP variants also accept
`iv_require_full_quantity`. The request must be fully coverable by batches that
meet its shelf-life requirement at its required date after source-location and
allowlist filters; a rejected short request leaves those batches available to
later dated demands.
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
priority, allowlist, safety-stock, and full-quantity options.
`ALLOCATE_LOCATION_BY_DATE_UOM` adds required dates and integer priority to
these location demands. Earlier dates consume shared location balances first;
higher priorities win within the same date, with input order breaking ties.
Results include dates and priorities and return in caller order. The preview
uses current stock only because projected receipts do not identify a storage
location.
`ALLOCATE_LOCATION_DATE_UOM_ATP` adds cumulative ATP checks for positive local
allocations, grouped by material, plant, base unit, and required date. The ATP
quantity for a later date includes earlier local allocations in that group;
zero local allocations do not trigger a check. The result remains a comparison
preview and does not reserve stock.
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
uses the material's `MARA`/`MARM` ratio.
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
`GET_LOCATION_STOCK_STATUS_BULK` accepts the same keyed requests and returns a
location breakdown for each material/plant pair in request order. Each nested
location row includes unrestricted, quality-inspection, and blocked stock plus
available unrestricted stock after the existing deterministic reservation
distribution. Its input validation and empty-request behavior match
`GET_STOCK_STATUS_BULK`.
`GET_LOCATION_STOCK_BULK_UOM` adds a requested unit to each keyed request and
converts every location quantity while preserving its storage-location key.
It retains zero-available locations, caches ratios by material/unit, and uses
one bulk location read for the whole request set.
`GET_STOCK_STATUS`, `GET_STOCK_STATUS_BY_LOCATION`, and
`GET_STOCK_STATUS_BY_BATCH` require both a material and plant key. A blank key
raises `ZCX_INVALID_STOCK_REQUEST` before the repository read.
`GET_SALES_ORDER_RESERVATIONS` rejects a blank sales-document key, and
`GET_ORDER_RESERVATIONS_BULK` rejects blank entries. An empty bulk request
returns an empty result without reading the repository.
`GET_ORDER_RES_BULK_UOM` accepts keyed sales-document, material, plant, and unit
requests and returns matching open reservation rows in that unit, with both
base and requested unit codes. It caches ratios by material/unit, preserves
request order, and reads all distinct sales documents once. Blank keys,
duplicate request IDs, and unknown units are rejected before the reservation
read; empty input returns without a repository read.
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
Set `iv_include_po_confirmations = abap_true` to use the confirmation-aware PO
schedule and supplier-confirmation projection instead. The PO flags are
mutually exclusive. `ALLOCATE_DEMANDS_BY_DATE` groups confirmation reads by
material/plant through the latest demand date, then adds only receipts due by
each demand date before sharing the resulting stock across demands. Unit and
ATP dated-allocation methods, including cross-plant source allocation, pass this
option through to the same local estimate. Cross-plant reads group by
material/source plant through the latest mapped demand date.
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
requests, reads each distinct pair once through its latest deadline, and
filters each result to that request's horizon. Its `_UOM` variant converts
receipts to each requested unit and reuses conversion ratios by material/unit.
`GET_PROJECTED_RECEIPTS_BULK` accepts uniquely keyed material/plant/deadline
requests with shared receipt-source flags, including
`iv_include_po_confirmations`. It returns one result per request in input order
and filters each receipt list to that request's deadline. Repeated
material/plant pairs share projections through their latest requested date.
Invalid keys or source flags are rejected before reads; empty input and requests
with no enabled receipt sources do not read the repository.
`GET_PROJ_RECEIPTS_OPTS_BULK` accepts source flags on each keyed request. It
accepts `include_po_confirmations` as an alternative to `include_po_receipts`,
unions enabled source types for each material/plant read through that pair's
latest deadline, then filters rows by each request's own source flags and date.
Requests sharing a pair may select different PO projections; one request may
not select both.
Results preserve input order; request groups with no enabled source types skip
the repository read.
`GET_PROJ_RECEIPTS_BULK_UOM` adds a requested material unit per keyed request
and returns converted receipt quantities with base/request unit codes. It
validates every ratio before projection reads and reuses both ratio and
material/plant deadline caches across the call.
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
repository read.
`GET_BATCH_STOCK_BULK_UOM` adds a requested unit to each keyed batch-status
request and converts unrestricted and available quantities for every batch.
It retains zero-available batches and their storage locations and expiration
dates, caches ratios by material/unit, and uses one bulk batch read.
It rejects blank fields, duplicate request IDs, and unknown units before the
stock read; empty input returns without a repository read.
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
other locations in expiration-date order. An optional
`it_storage_location_priority` list breaks ties between locations for the same
batch and expiration date; it does not override the FEFO order. This is a simple
VFDAT ordering;
SAP's configurable batch determination and search strategies are not reproduced
([batch stock](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/d664bd534f22b44ce10000000a174cb4.html),
[batch search strategies](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/4eb099dbc8a6435c9b36a854a7e05522/16feb753128eb44ce10000000a174cb4.html),
[ascending shelf-life expiration sort](https://help.sap.com/docs/SAP_ERP_SPV/96bf9ad642cf4b26a29595e3d573fb8c/fa60bd534f22b44ce10000000a174cb4.html)).
`ALLOCATE_BY_EXPIRY` and `ALLOCATE_BY_EXPIRY_IN_UNITS` accept
`iv_include_undated_batches`, defaulting to `abap_true`. Set it to
`abap_false` to exclude batches without an expiration date from availability,
safety-stock protection, and allocation. Invalid values are rejected before
unit conversion or stock reads.
`ALLOCATE_BY_EXPIRY_IN_UNITS` accepts multiple FEFO demands in material-specific
units, validates and caches every material/unit ratio before reading stock, and
allocates shared batch stock in demand order. Results include base-unit
allocation summaries and batch splits alongside converted source-unit
quantities. Base-unit split quantities remain the canonical values when
conversion to a source unit rounds to `MARD-LABST` precision.
Each base-unit or unit-aware FEFO demand can set `minimum_shelf_life_days`.
The greater of this value and the shared `iv_min_days` applies to that demand;
a positive effective minimum excludes undated batches. Batch splits report the
effective minimum, and the unit-aware method carries each demand's value through
base-unit conversion.
Base-unit and unit-aware FEFO demands can also set `fefo_as_of_date`; the later
of that date and the shared `iv_as_of_date` controls expiry checks, and batch
splits report the effective date.
`ALLOCATE_BY_EXPIRY_ATP` accepts unit-aware FEFO demands and a checking rule.
It returns the local FEFO estimate plus ATP checks grouped by material, plant,
base unit, and effective FEFO date. Each check covers the cumulative local
allocation through that date; rows with no local allocation do not trigger an
ATP call. This remains a preview and does not reserve stock.
`ALLOCATE_BY_BATCH_ATP` provides the same comparison for unit-aware demands
that name an exact batch. A row's `as_of_date` overrides the shared
`iv_as_of_date` default, and the selected batch is retained through local
expiry filtering and allocation. ATP checks group the positive batch splits
by material, plant, base unit, and date, with cumulative quantities through
each date. It does not substitute a different batch or reserve stock.

Confirmed stock changes go through `ZCL_GOODS_MOVEMENT_SERVICE`, which calls
`BAPI_GOODSMVT_CREATE` through an injectable adapter. It validates common item
fields and cost center or order assignments for movement types 201/202 and
261/262; sales-order issues (231/232) require the sales order and item, and
project-WBS movements (221/222) require a WBS element. One-step plant transfers
(301/302) require a receiving plant and storage location;
two-step plant transfers use separate 303 removal and 305 putaway postings.
`ISSUE_TO_COST_CENTER` posts caller-selected material lines directly to one
cost center with movement type 201 and GM code 03. Each line includes plant,
storage location, optional batch, quantity, and entry unit/ISO code; the unit
is passed through without local conversion. All lines share one material
document and the standard simulation and commit handling. The method does not
run an allocation preview, so callers supply the quantities to issue.
`ISSUE_TO_COST_CENTER_IN_UNIT` accepts per-line source units and converts each
quantity to the material base unit. Pass one base-unit/ISO mapping per material;
the service checks that the conversion agrees with that mapping before posting.
`REVERSE_TO_COST_CENTER` posts movement type 202 for caller-selected return
quantities without a material-document reference. Its UOM-aware form,
`REVERSE_TO_COST_CENTER_UOM`, converts quantities to the mapped base unit first.
Both retain the cost center and optional batch and use the standard simulation
and commit handling; a partial quantity can be returned.
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
the sales order or estimate available stock.
`RETURN_FROM_SALES_ORDER` posts movement type 232 against the supplied sales
order and item keys. `RETURN_FROM_SALES_ORDER_UOM` converts source quantities
to the mapped base unit first; both retain batch assignments and use the
standard simulation and commit flow. Returns are entered without a reference to
the original material document.
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
and continuing after a posting failure. Review every row for partial success.
Its test-run mode simulates each WBS without committing.
`ISSUE_PROJECT_WBS_BULK_UOM` accepts source units with a material base-unit/ISO
mapping, converts and validates the complete request first, then uses the same
per-WBS posting and result behavior.
`RETURN_PROJECT_WBS_BULK` accepts base-unit return items and posts one movement
222 document per WBS. It validates the full request before posting and returns
per-WBS outcomes in input order, continuing after a failed posting. These
returns do not reference an original material document.
`RETURN_PROJECT_WBS_BULK_UOM` accepts source units and a base-unit/ISO mapping,
converts every row before the first return posting, and preserves the same
per-WBS transaction and result behavior.
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
independently and later requests continue after a failure; inspect each result
row for partial success. Set `iv_atomic = abap_true` to stage the group under
one commit or rollback boundary. Test-run calls simulate each row without
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
independently, and returns each reservation's result; later reservations are
still attempted after a failure, so review for partial success. Test-run
simulates every reservation without commit.
`RETURN_RESERVED_WBS_ITEMS` reverses a selected quantity already withdrawn
from a WBS reservation. It checks that the item is scoped to the WBS and has a
withdrawn balance, then posts a reservation-referenced reversal; finalized
items remain eligible when they have a withdrawn quantity. Its bulk form
accepts unique reservations, checks every WBS/item before posting, and commits
one return document per reservation while continuing after failures. The
requested return quantity is checked against the current SAP withdrawn amount.
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
life; undated batches are rejected when this minimum is positive.
`RESERVE_WBS_FEFO` combines `PREVIEW_FEFO` with batch reservation and returns
both the preview and reservation outcome. It accepts the same location,
reservation-cutoff, and shelf-life options plus a shared required date or a
date per WBS. Full demand coverage is required by default; if the preview has a
shortfall, the method returns that preview and creates nothing. Set
`iv_require_full_quantity = abap_false` to reserve available splits. Test-run
and atomic commit behavior are forwarded to the reservation step.
`RESERVE_WBS_FEFO_BY_DATE` uses required date and integer priority on each
demand. Earlier dates consume shared stock first, and higher priorities lead
within a date; equal priorities keep input order. The preview and batch splits
return in caller order. Reservations are grouped by WBS and required date, so a
WBS with multiple requirement dates receives a separate reservation per date.
Each group commits independently by default; `iv_atomic = abap_true` stages all
groups for one commit or rollback. The method reruns the dated preview and
compares all batch splits before creating reservations.
`RESERVE_WBS_BY_LOCATION_DATE` applies the same date and priority ordering to
batchless project stock. It reruns the preview and compares location splits
before writing, grouping reservations by WBS and required date. Different dates
for one WBS can share an atomic commit with `iv_atomic = abap_true`.
`RESERVE_WBS_BY_LOCATION` provides the same one-call flow for batchless stock,
using `PREVIEW_BY_LOCATION` and returning both preview and reservation result.
It accepts storage-location priority/allow lists and a reservation cutoff. Full
coverage is required by default; a shortfall returns the preview without
creating reservations, while `iv_require_full_quantity = abap_false` reserves
available splits.
`DELETE_RESERVATION` cancels one reservation by number. Its test-run mode
reports the BAPI result without commit, and a live delete is reported as
deleted only after commit succeeds. `DELETE_RESERVATIONS_BULK` validates the
full list first, then processes each reservation in its own transaction and
returns a result per number; an individual failure is rolled back while later
numbers continue. SAP determines whether a reservation can be deleted based
on its current use and status. `DELETE_RESERVATIONS_ATOMIC` prevalidates the
full unique list, then requests one shared commit or rollback. Test-run calls
the delete BAPI in simulation mode and skips transaction calls.
`DELETE_RESERVATION_ITEMS` deletes selected open item numbers after confirming
they belong to the supplied WBS and reservation. Its test-run mode performs the
scope check without calling the change BAPI. Live requests mark the selected
items for deletion and commit; `DELETE_RESERVATION_ITEMS_BULK` processes one
reservation per request, reports each outcome, and continues after a failure.
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
continues after individual failures. `RESCHEDULE_ITEMS_ATOMIC` accepts several
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
`PREVIEW_TRANSFER_FEFO_BY_DATE` adds each transfer's required date and integer
priority. Earlier dates consume shared source-WBS stock first; higher priority
runs first on the same date, and input order breaks ties. The dated allocation
and batch splits return in caller order with date and priority attached.
`TRANSFER_WBS_FEFO_BY_DATE` reruns that same dated preview and compares the
batch, source and destination WBS, expiry, quantity, and unit before posting.
It posts the validated splits as 415/Q through the existing movement path.
Batch expiry is checked through each transfer's required date, but the dated
preview remains a current stock snapshot and does not reserve stock until the
movement is posted.
`ISSUE_PROJECT_WBS_ALLOCATION` accepts the location allocation result from
`ZCL_STOCK_SERVICE=>ALLOCATE_BY_LOCATION_IN_UNITS` and a request-ID-to-WBS
mapping. It posts the positive location splits as movement 221 items, keeps
each demand assigned to its WBS element, and checks split totals and unit maps.
Full allocation is required by default; partial issue is opt-in. The allocation
is a stock snapshot and is not re-read before posting.
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
current snapshot and does not reserve stock.
`READ_AVAILABLE_STOCK_BULK` accepts unique request IDs with a material,
plant, WBS element, and optional reservation cutoff for each request. It groups
requests by cutoff and reads each distinct stock key once per date group,
returns detailed batch/location rows in request order, and copies the result to
requests sharing the same key and cutoff. Invalid keys, dates, or duplicate IDs
are rejected before reads; empty input performs no reads.
`READ_AVAILABLE_STOCK_IN_UNIT` returns the same project-stock detail in a
requested material unit while preserving its base-unit quantity. The bulk
`READ_AVAILABLE_STOCK_BULK_UOM` accepts a unit per request, caches conversion
ratios by material and unit, and validates every ratio before stock reads.
Repeated WBS stock keys still share the existing cutoff-grouped read.
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
`READ_RESERVATION_ITEMS` returns active Q reservation items for unique WBS
elements, including final-issue state, base and entry units, required and
withdrawn quantities, and the remaining quantity. It includes finalized and
fully withdrawn items that `READ_OPEN_RESERVATIONS` omits.
`READ_RESERVATION_ITEMS_BULK` accepts unique request IDs and WBS elements,
reads the full item view once for distinct WBS values, and returns each WBS's
items in request order. Repeating a WBS under another request ID reuses the
read; final and fully withdrawn items remain included.
`READ_RESERVATION_COVERAGE` summarizes by WBS/material/plant, returning
eligible project stock, open reserved quantity, free quantity after
reservations, and any reservation shortfall. It includes batch and batchless
stock with a storage location, converts reservation quantities to the
material base unit, and accepts the same optional required-through date. This
is a snapshot; it does not lock stock or assign each reservation to a batch.
`READ_RESERVATION_COVERAGE_BULK` accepts request IDs with individual WBS
elements and required-through dates. It groups requests by date for shared
stock and reservation reads, returns coverage in request order, and performs no
reads for an empty request list. Request IDs must be nonblank and unique.
`READ_RESERVATION_COVERAGE_UOM` returns the same coverage for one
material/plant/WBS key in a requested material unit, along with the canonical
base-unit quantities. It validates the material's UOM ratio before stock and
reservation reads. A key with no stock or reservations returns zero quantities
and the requested/base units.
`READ_RESV_COVERAGE_BULK_UOM` accepts a requested unit and reservation cutoff
per unique request. It caches material/unit ratios before the grouped coverage
reads and returns converted and base-unit quantities in request order.
Project-stock previews read positive `PRLAB` quantities from `MSPR` for the
requested WBS elements and return FEFO batch splits with the matching WBS
assignments.
It also reads open project reservations from `RESB`, maps `RESB-PSPEL` through
`PRPS`, and deducts `BDMNG - ENMNG` for the same WBS, material, and plant.
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
Both project-stock previews subtract open Q reservations before allocation;
their results remain snapshots and do not lock project stock.
All four project-stock previews also accept optional
`iv_reservation_through_date`. When supplied, reservations with `RESB-BDTER`
after that date are left out of the deduction; undated open reservations remain
deducted. Omit the option to retain the default behavior, which deducts all
open project reservations. This date filter does not project receipts or
change the current `MSPR` stock snapshot.
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
`PREVIEW_FEFO_BY_DATE` adds a required date and integer priority to each
project-stock FEFO demand. Earlier dates consume shared WBS/material/plant
balances first; higher priorities run first within the same date, and input
order breaks ties. Allocations and batch splits return in caller order and echo
the required date and priority. Expiry eligibility uses the latest of the
shared as-of date, the demand's `fefo_as_of_date`, and its required date. This
is still a current project-stock snapshot and does not add future receipts or
reserve the selected batches.
`PREVIEW_BY_LOCATION_DATE` applies the same required-date and same-date
priority ordering to batchless project stock. It returns allocation and
storage-location splits in caller order and echoes date and priority. The
preview uses current batchless location balances and does not assign future
receipts to locations.
Shelf-life filters apply only to batch FEFO; location-only previews reject a
nonzero demand-level minimum because those balances have no batch expiry to
check.
For a batchless transfer, `PREVIEW_TRANSFER_BY_LOCATION` scopes the preview to
each source WBS and returns source/destination assignments with its location
splits. `TRANSFER_WBS_LOCATION_ALLOC` validates those totals and posts the
positive splits as movement 415/Q; full allocation is required by default.
Set `iv_require_full_allocation = abap_false` to post only available splits.
The preview is a stock snapshot and is not reserved before posting.
`PREVIEW_TRANSFER_LOCATION_DATE` adds required dates and integer priorities to
batchless WBS transfers. Earlier dates consume source WBS location balances
first; priority breaks ties, then input order. It returns location splits and
source/destination assignments in caller order. `TRANSFER_WBS_BY_LOCATION_DATE`
repeats the dated preview and checks the location, source and destination WBS,
quantity, and unit before posting 415/Q. It uses current batchless stock and
does not assign future receipts to locations.
`ISSUE_SALES_ORDER_ALLOCATION` accepts a successful single-order preview from
`ZCL_SALES_ORDER_ALLOC_SERVICE=>PREVIEW_ORDER` and the material base-unit/ISO
mappings. It posts the preview's positive location or batch splits as 231 items,
preserving selected storage locations and batches. Full allocation is required
by default; set `iv_require_full_allocation = abap_false` to post only allocated
quantities. The service verifies the preview summaries and split totals before
posting. This path covers unrestricted stock represented by the preview, not
special sales-order stock. A preview is a stock snapshot; SAP remains the final
authority when stock or order state changes before posting.
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
`ISSUE_UNPLANNED_PROD_BULK` accepts distinct production orders and
posts one independent material document per order. It validates every order
and line before posting, then continues after an individual posting failure;
review each row result because the batch can partially succeed. Test runs
simulate each order without committing.
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
committing. This creates the order proposal only; it does not post goods issue
or receipt. SAP documents `UB` and item category `U` for a stock transport
order without delivery, with subsequent 351/101 goods movements
([STO without delivery](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/5213b953495bb44ce10000000a174cb4.html)).
Schedule dates taken from dated allocations and caller-supplied batch delivery
dates must be valid Gregorian calendar dates before `BAPI_PO_CREATE1` is called.
SAP still determines whether a valid date satisfies purchasing and planning
rules for the target system.
The adapter maps the request through `BAPI_PO_CREATE1`; its `TESTRUN` flag
suppresses database updates and successful writes use the BAPI transaction
commit ([BAPI_PO_CREATE1](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167600.html),
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
PO and commits it independently. It continues after an order fails and returns
one result per request. Every request in one bulk call must use the same test-run
setting. Check the per-order messages and commit state for partial completion.
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
the base quantity using the supplied order-to-base ratio. Review candidates
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
independently, while atomic commits the complete group together. The target SAP
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

`CREATE_FROM_SOURCE_PLANTS` handles an allocation for one receiving plant
across multiple supplying plants. It prepares one `UB` order per supplying
plant in allocation priority order, validates every order request before the
first BAPI call, including that source-plant base quantities reconcile to each
demand's allocated base quantity, and returns the result and submitted items
for each order.
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
It validates the full result, demand-to-source totals, and every location entry
before writing, and returns per-pair results. Orders commit independently by
default. Set
`iv_atomic = abap_true` on this method, `CREATE_FOR_BATCH_PAIRS`, or
`CREATE_FOR_FEFO_PAIRS` to defer one shared commit until all pair orders are
created; a create or commit failure rolls back the pending group and stops
further pair calls.
Previews do not reserve stock, so availability can change before posting.
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
`CREATE_FOR_ATP_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_BATCH_ATP` output and
requires full current-date confirmation for each positive material/source-
plant/base-unit group before it creates any order. It retains each exact batch,
uses the caller's shared delivery date, and supports the same receiving-location
map and atomic commit option.
`CREATE_DATED_BATCH_PAIRS` accepts `ALLOCATE_PLANTS_DATE_BATCH_UOM` output and
creates one order per positive source/target pair. It retains each exact batch
and issuing location, and puts that request's required date on its PO item.
Before writing, it checks that demand quantities match source-plant totals and
that each source-plant base quantity matches its issuing-location splits.
Orders commit independently by default; `iv_atomic` shares one commit across
all pair orders. This entry point does not run or validate SAP ATP.
`CREATE_DATED_BATCH_ATP_PAIRS` accepts `ALLOCATE_PLANTS_DATE_BATCH_ATP` output.
It validates full cumulative confirmation at every source/date group before any
write, then creates one order per positive source/target pair with an item for
each selected request, batch, and issuing location. Each item carries its
required date as the delivery date; `iv_atomic` shares one commit across all
pair orders.
`CREATE_FOR_FEFO_PAIRS` accepts the dated, unit-aware cross-plant FEFO result
and creates one order per positive source/target pair. Each selected
batch/location split becomes a PO item with its batch, issuing storage
location, source-unit quantity, and FEFO required date. Before writing, it
checks that demand totals match source-plant totals and that source-plant totals
match batch/location splits in base units. The caller can map a receiving
storage location per target plant. FEFO is a preview and does not
reserve stock; SAP also documents that STO availability checks do not check
batch stock when a batch is entered ([STO availability check](https://help.sap.com/docs/SAP_ERP_SPV/96bf9ad642cf4b26a29595e3d573fb8c/b160bd534f22b44ce10000000a174cb4.html)).
Orders commit independently by default; the opt-in `iv_atomic` mode defers the
commit across all source/target pairs.
`CREATE_FOR_ATP_FEFO_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_DATE_ATP` output and
checks each positive source/target/date total before creating any pair order.
The ATP check remains plant-level; it does not confirm a specific batch, and it
does not reserve stock. This entry point also supports the shared `iv_atomic`
commit mode.
`CREATE_FOR_FEFO_ATP_PAIRS` accepts `ALLOCATE_PLANTS_FEFO_ATP` output. It
requires one matching, fully confirmed current-date ATP check per positive
material/source-plant/base-unit group before writing. The caller supplies one
delivery date for the undated FEFO request; each selected batch/location split
becomes an STO item in its source unit. ATP is a precheck and does not reserve
the selected stock. The method supports the shared `iv_atomic` commit mode.
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
after failures. `RECEIVE_PURCHASE_ORDERS_ATOMIC` prevalidates the group, stages
one movement call per PO, and commits once; a receipt or commit failure rolls
back the group and clears staged material-document identifiers. Both group
methods support BAPI test runs and return per-PO statuses and messages.
`RECEIVE_PROD_ORDER` maps a typed production-order request to movement type
101, GM code 02, and movement indicator `F`. `RECEIVE_PROD_ORDERS_BULK` commits
each order independently and continues after failures;
`RECEIVE_PROD_ORDERS_ATOMIC` stages the group and commits once or rolls back on
failure. Both prevalidate distinct production orders and all quantities and
units before posting, support BAPI test runs, and report material-document
identifiers only when the group remains committed.
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
`CANCEL_MATERIAL_DOCUMENTS_BULK` accepts distinct document/year keys, optional
posting dates, and optional item lists per request. It validates the whole list
before calling SAP and returns one attempted/cancelled status with reversal
details per request. Calls commit independently by default; set `iv_atomic =
abap_true` to stage all reversals in one LUW and commit once. A reversal or
commit failure rolls the staged group back.
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
after that reversal succeeds. `is_cancelled` reports the receipt reversal,
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
The optional atomic mode shares one commit across pending 351 reversals. It
does not undo 101 reversals committed by the earlier chain attempt.
`RETRY_STO_CHAIN_RECEIPT` and `RETRY_STO_CHAIN_RECEIPT_PAIRS` retry the 101
reversal from prior chain output when the pair remains received, including
after an atomic chain rollback.
Completed pairs and pairs already waiting for a 351 retry are preserved. A
successful receipt retry restores in-transit status; the aggregate chain result
stays incomplete until the 351 reversal is also successful. Atomic mode shares
one commit across the pending 101 reversals.
`RETRY_STO_CHAIN` and `RETRY_STO_CHAIN_PAIRS` resume either pending stage from
the prior chain result: received pairs retry the 101 and then the 351, while
in-transit pairs retry only the 351. Completed pairs are retained. Atomic mode
stages every pending movement across both stages for one shared commit; a
failure restores each pair's state from before this retry. Any reversal already
committed by an earlier call remains committed.
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
`is_deleted` false. The atomic option simulates every PO independently and
skips commit and rollback; it does not check whether a shared live commit would
succeed.
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
back the group. The single and pair methods also accept `iv_test_run` to
simulate each change without commit or rollback. They report simulation success
without setting `is_completed`; atomic simulation validates each PO separately
and does not validate a shared commit.
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
reading transfer balances.
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
support test runs and use the BAPI transaction commit or rollback APIs. Both
services depend on interfaces so their behavior can be tested without posting
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
row without commits. Atomic write rows now report the group outcome; document
numbers from rolled-back atomic creates are cleared.
`reject_order_items` sets configured rejection reasons for selected sales-order
items through `BAPI_SALESORDER_CHANGE`; `reject_orders_bulk` commits each order
independently, while `reject_orders_atomic` shares one commit and rolls back the
group after a failed change. All three validate item numbers and nonblank reason
codes before writing, preserve SAP messages, and support test runs. Rejection
codes must exist in the target system's sales-document customizing.
`clear_order_item_rejections` restores selected items by sending a blank reason
with the rejection field's update flag. `clear_order_rejections_bulk` commits
each order independently; `clear_order_rejections_atomic` commits once for the
group and rolls back after any failed update. Both modes validate distinct item
numbers and distinct sales documents before writing, preserve SAP messages, and
support test runs.

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

`reserve_orders_by_date_bulk` uses the same shared preview and pre-write
allocation/ATP gates, then creates and commits each sales order separately in
input order. A failed create, response check, or commit rolls back that order
and processing continues with the next order; earlier committed orders remain
committed. `order_results` reports each order's messages, reservations,
`is_successful`, `is_test_run`, and `is_committed`. The top-level result is
unsuccessful if any order fails, while its reservations contain only successful
commits (or successful simulations). An order with no allocated quantity is a
successful no-op. Test runs simulate each nonempty order and never commit.
Use `reserve_orders_by_date` when all orders must share one commit or rollback
boundary.

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
`DELETE_ORDERS_RELEASE_BULK` uses the same single bulk lookup, then deletes and
commits each sales order independently. It keeps processing after a failed
delete or commit, reports per-order messages and commit status, and returns only
reservation numbers successfully deleted (or simulated). Earlier orders remain
released after a later failure; use `DELETE_ORDERS_RESERVATIONS` when the entire
set must share one rollback boundary. Test runs simulate each nonempty order
without committing, and orders with no candidates succeed as no-ops.
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
success and commit status. Empty input succeeds without a reservation read or
goods movement call.
`POST_GOODS_ISSUE_IN_UNIT` and `POST_GOODS_ISSUE_REV_IN_UNIT` accept a quantity
and unit per selected item. `POST_GOODS_ISSUE_BULK_UNIT` and
`POST_GOODS_ISSUE_REV_BULK_UNIT` preserve per-reservation documents while
accepting the same unit-aware lines. The service converts each line using the
material's unit ratio, checks the converted base quantity
against the item's open or withdrawn quantity, and passes the reservation's
base unit and ISO code to SAP. An unknown conversion or a base-unit mismatch
stops that reservation group's movement.
`POST_CC_GOODS_ISSUE` and `POST_CC_GOODS_ISSUE_IN_UNIT` also require every
selected reservation item to be an open item for the supplied cost center.
Their `_BULK` forms make one independently committed goods issue per
reservation, with the `_BULK_UNIT` form accepting alternative units. The
cost-center check reads the current open-reservation snapshot before reading
reservation detail or posting; concurrent changes after that check are still
subject to SAP's reservation and goods-movement validation.
`POST_CC_ISSUE_REV` and its `_BULK`, `_UNIT`, and `_BULK_UNIT` variants scope
withdrawal reversals to the reservation header's cost center. They look up the
requested reservation keys directly, so fully issued items remain eligible
even though they no longer appear in the open-reservation list. The common
movement pipeline still limits each reversal to the quantity already withdrawn.

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
support test runs. These base-unit methods take quantities in the component
reservation unit. `ISSUE_COMPONENTS_IN_UNIT` and
`ISSUE_COMPONENTS_BULK_IN_UNIT` also accept a quantity and material unit per
line; they convert every line to the reservation component unit and reject an
unknown or mismatched conversion before posting. The bulk unit-aware method
still posts all selected components in one material document. SAP generates
component reservations when production orders are created; movement type 261 is the
standard goods issue for order components
([withdrawing material components](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/c803b753128eb44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest)).
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
creates and commits each order independently while continuing after errors.
`CREATE_ORDERS_ATOMIC` sends the validated orders in one LUW and commits once;
it rolls the group back after any create or commit failure. Duplicate caller-
assigned order numbers are rejected before the first BAPI call. SAP's BAPI
transaction model permits multiple object creations in one LUW, but verify the
target release's production-order BAPI behavior before relying on atomic mode
([BAPI transaction model](https://help.sap.com/SAPHELP_SCM700_EHP02/helpdata/EN/4d/5b102ba1483d8fe10000000a42189e/content.htm)).
`ZCL_PROD_ORDER_SERVICE->RELEASE_ORDERS_ATOMIC` releases a validated set of
production orders through `BAPI_PRODORD_RELEASE` in one BAPI call and commits
once; any overall or per-order error rolls back the set.
`RELEASE_ORDERS_BULK` releases and commits one order at a time, continues after
failures, and reports per-order commit status and counts. Both methods require
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
continuing after failures. SAP marks a partially released order PREL and
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
after failures. The response preserves each SAP message and commit result
([SAP cancellation mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-cancellation-for-production-time),
[SAP BAPI catalog](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
`READ_CONFIRMATIONS_BULK` retrieves operation confirmations for requested
production orders from `AFRU`, joined to `AFVC` for the operation and sequence.
The result includes confirmation number/counter, posting date, actual
yield/rework/scrap quantities and their entry unit, final status, and reversal
status. Quantity values remain in SAP's confirmation unit and are not converted
or netted; reversed rows remain visible so callers can distinguish them before
cancellation. Empty confirmation lists are reported per order. SAP documents
the AFRU yield, rework, scrap, and quantity-unit fields
([SAP confirmation API guide](https://help.sap.com/doc/9840fb99f9a74026ab7f1929fde9c454/3.0.3/en-US/SAPEdgeServicesOnPremEssentialBusinessFunctionsAPIGuide30FP03.pdf),
[confirmation fields](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/327cb6535fe6b74ce10000000a174cb4.html)).
`READ_OPERATIONS_BULK` returns routing operations for requested production and
process orders, including internal operation counter, sequence, operation and
suboperation numbers, description, and control key. Results are grouped per
order in request order; orders with no operation rows are reported as empty.
The repository follows SAP's routing linkage and operation identifiers
([SAP operation data view](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/afa5a1dc1d81424784b89e079cec0b48.html),
[SAP routing field mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-routing)).
`CREATE_CONFIRMATIONS_ATOMIC` and `CREATE_CONFIRMATIONS_BULK` post
production-operation time tickets through `BAPI_PRODORDCONF_CREATE_TT`.
Requests provide the order, four-character operation, six-character sequence,
posting date, yield, scrap, rework, ISO quantity unit, and optional
final-confirmation and open-reservation settings. Atomic mode stages each
ticket in one SAP LUW, commits once when every ticket succeeds, and rolls back
the group after a BAPI or commit error. Bulk mode commits each ticket
independently and continues after failures. The service maps detail-return
messages and confirmation keys. Atomic mode also accepts `iv_test_run`; it
stages the complete group and rolls it back on success, reporting
`is_test_run = abap_true` and `is_committed = abap_false`. Returned confirmation
keys from a test run are provisional and must not be treated as persisted
records. Blank final
confirmation means partial; `1` requests automatic final confirmation; `X`
marks final confirmation. The API may also trigger configured automatic goods
receipts or component backflush, so the target order and work-center settings
govern inventory effects ([SAP PCo example](https://help.sap.com/doc/302a83e81be74549bbc31509bb1b4246/15.5.5/en-US/Application_HELP_EN.pdf),
[SAP confirmation field mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-production-yield-confirmation)).
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
skipped while ready orders continue; results preserve request order and carry
both readiness and release/commit status. An incomplete or malformed checker
response blocks all writes. As with the atomic ATP-gated operation, the
availability check is a point-in-time preview rather than a stock reservation.
`CHANGE_ORDERS_ATOMIC` and `CHANGE_ORDERS_BULK` call
`BAPI_PRODORD_CHANGE` for selected order quantity, quantity unit, basic start
date, and basic finish date. Each request identifies changed fields explicitly;
quantity and its unit are updated together. Atomic mode shares one commit and
rolls the group back on the first error; bulk mode commits each order and
continues after failures. Requests are validated before the first BAPI call,
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
`ZCL_PROD_ORDER_READ_SERVICE->READ_ORDERS_BULK` bulk-reads requested PP
production orders and process orders. Each order result retains all output
items rather than choosing a primary item, and reports ordered, received, and
open quantities in the material base unit. It also returns the order and base
units, basic start/finish dates, raw AUFK phase and deletion indicators, AFPO
receipt and delivery-complete indicators, and active SAP system and user
statuses with codes, short names, and logon-language names. Blank or duplicate
order numbers are rejected before repository reads; missing orders and
unit-conversion failures are reported per result. Categories other than 10 and
40 are not returned. Status codes remain available when the logon-language text
is missing. SAP documents active status reporting and the distinction between
system and user statuses
([active production-order statuses](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/a144fb0d4c4a48958e1c39451391db22.html?locale=en-US&source=redirect&state=PRODUCTION&version=2602.500),
[system and user status behavior](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/8e04b753128eb44ce10000000a174cb4.html)). SAP also documents production-order quantities and basic
dates in its manufacturing references
([production-order header and item](https://help.sap.com/saphelp_autoid2007/helpdata/en/89/6166370f5a2a68e10000009b38f8cf/content.htm?no_cache=true),
[AFPO quantity fields](https://help.sap.com/doc/419ffea5f9b6488da138a9b8d65d508b/3.15/en-US/Sample%20Content%20Process%20Mining%20on%20SAP%20S4HANA%20Production%20Planning.pdf)).
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
independent-commit and atomic LUW options as the generic bulk cancellation.
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
The local estimate removes the selected components' own open reservation items
from the `RESB` deduction before allocating the component requirements. Other
active reservations remain deducted, and each selected component is charged once
by the local allocation.
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
For `EX`, `TB`, `MB`, `WB`, resolved `PK`, and caller-resolved custom periods,
the result includes the aggregate quantity, receipt count, and final receipt
quantity after maximum-lot splitting.
For supported lot-sizing policies, a caller or material-master `MARC-RDPRF`
applies static threshold rounding from plant/profile `RDPR` rows to each receipt
after lot sizing. The result reports the profile and updates the aggregate,
receipt count, final receipt, and rounding surplus. A profile that rounds a
receipt above its configured maximum lot size raises
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
The BAPI does not expose a test-run flag through this adapter, so these methods
have no simulation mode. SAP lists `BAPI_PLANNEDORDER_CREATE` among its
available MRP interfaces and documents planned-order creation inputs
([available interfaces](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html),
[planned-order creation](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/f92b46872df54aa79ca7c20038b98a31.html?locale=en-US)).
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
the batch can be partially completed. Neither method offers simulation; SAP
lists the planned-order change BAPI among its available MRP interfaces
([available interfaces](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
Verify the change fields, quantity unit, and transaction behavior in the target
release.
`READ_ORDERS_BULK` reads several planned-order numbers in one `PLAF` query and
returns rows in request order. Each row includes the material, plant, start and
finish dates, order quantity and unit, base unit, fixed indicator, planning
scenario, special-stock indicator, and sales-order assignment. The service also
returns the converted base-unit quantity when the `MARA`/`MARM` unit ratio is
available; otherwise it preserves the raw header and marks that row's
conversion as failed. Missing orders are reported per row and make the overall
result unsuccessful. Blank or duplicate numbers are rejected before the read;
empty input returns an empty successful result. The read does not commit or
change SAP data.
`CONVERT_PLANNED_ORDERS_ATOMIC` converts a validated list through
`BAPI_PRODORD_CREATE_FROM_PLORD` and commits the conversions together. Any
conversion or commit failure rolls back the group and clears returned
production-order numbers. `CONVERT_PLANNED_ORDERS_BULK` commits each conversion
separately, continues after failures, and returns per-order status and counts;
use those rows to reconcile partial completion. Both methods reject blank or
duplicate planned-order numbers before the first BAPI call and have no
simulation mode. Verify the conversion function module and LUW behavior in the
target SAP release before use.
`CREATE_ORDERS_BULK` and `DELETE_ORDERS_BULK` validate every request or number
before the first BAPI call, then commit each planned-order operation separately
and continue after an individual BAPI or commit failure. Their row results show
which orders were attempted and committed, with successful and failed counts.
Review each row because the batch can be partially completed. These methods do
not offer a simulation mode; use `PREPARE_FROM_SUGGESTIONS` to inspect creation
requests before submitting them.
`CREATE_FROM_SUGGESTIONS_BULK` prepares the same validated per-lot requests,
then uses the independent-commit bulk path. Each result row retains its
1-based source suggestion and receipt-lot indexes, so a partially completed
batch can be reconciled to the original suggestions. Covered zero-quantity
suggestions produce no order; if every row is covered, the result is an empty
successful no-op.
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
Call `PREPARE_FROM_SUGGESTIONS` to get the exact requisition type and item rows
after validation, lot splitting, and unit conversion without calling the BAPI.
`CREATE_FROM_SUGGESTIONS` uses this same prepared request before writing, so the
reviewed item numbers, source indexes, quantities, units, dates, and purchasing
fields match the submitted payload. Covered zero-quantity suggestions produce
an empty prepared request.
`PREPARE_FROM_SELECTED_SOURCES` applies reviewed PIR or agreement choices and
includes the chosen vendor, source reference, and purchasing-unit conversion.
`PREPARE_FROM_QUOTA_SPLITS` also verifies split reconciliation and returns one
item per selected quota share. The matching create methods submit these same
prepared rows.
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
outline-agreement and unresolved sources keep the suggestion's base unit.
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
calling SAP. By default it commits or rolls back each
requisition separately and continues after failures. Set `iv_atomic =
abap_true` to commit once for the entire group or roll it back after the first
failure. Results retain one row per input; inspect each row for item messages
and per-document commit state. Test runs simulate every request and skip
commits.
`create_requisitions_atomic` accepts prepared requisition types and item lists
for several documents. It validates all item keys and required fields before
the first BAPI call, requires a returned requisition number for each live
create, and commits the group once. Any create or commit failure rolls back the
group and clears its returned requisition numbers; test runs call each create
in simulation mode and skip commit. The result preserves one row per input
document, including rows not attempted after a failure.
`create_requisitions_bulk` uses the same validation and per-document item
results, while committing or rolling back each PR separately and continuing
after failures. The overall status is successful only when every row succeeds;
each result row shows whether its document was committed. Test runs simulate
every requested document and skip commits.
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
are still read and processed if an earlier one fails. Results stay in request
order and show each document's commit state.
`delete_pr_items_atomic` applies the same deletion to item groups across multiple
requisitions. It validates all document and item keys before calling SAP, stops
after the first failed requisition, and commits the group once or rolls it back.
Test runs call each requisition in simulation mode and skip the commit. Results
retain one row per input requisition; rows after a failure report that SAP was
not called. Confirm repeated `BAPI_PR_CHANGE` calls share the intended SAP LUW
in the target release.
`delete_pr_items_bulk` validates the same request list, then handles each
requisition in its own commit or rollback and continues when a requisition
fails. Its overall success is true only when every row succeeds; inspect each
row's `is_committed`, `bapi_was_called`, and messages for partial outcomes.
Test runs simulate every row and skip commits.
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

`read_cost_center_reservations` lists active, open reservation items for a cost
center, including reservation/item keys, material, plant, storage location,
batch, requirement date, entry unit, required quantity, withdrawn quantity, and
remaining open quantity. It reads movement-type 201 items from `RESB` and joins
`RKPF` by reservation number because SAP stores the cost-center assignment on
the reservation header ([reservation header](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/03a55f57017647368bfb386e41573ff7.html),
[cost center at header level](https://userapps.support.sap.com/sap/support/knowledge/en/3736490)).
Deleted, finally issued, special-stock, fully withdrawn, and non-201 items are
excluded. The read is a snapshot; it does not lock the reservation before later
deletion or goods issue. The result marks malformed or duplicate repository
rows unsuccessful and clears the returned item list; an empty list is a valid
successful read.

`read_cc_reservations_bulk` reads open reservation items for several unique
cost centers with one repository call. It returns one result per requested
center in input order; centers with no open items receive a successful empty
result. Blank or duplicate center keys are rejected before the read, and rows
for unrequested centers or malformed/duplicate rows make the overall and
affected center results unsuccessful. The repository uses one `RESB`/`RKPF`
query for the requested centers; verify its SQL and authorization behavior in
the target SAP release as noted in [ANOMALIES.md](ANOMALIES.md).

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
state. Empty input succeeds without a write. `iv_test_run` validates each
document against the local reservation snapshot and skips SAP calls and
commits.

`delete_reservations_bulk` also prevalidates the full list, then deletes each
document with its own commit and continues after failures. Its result reports
success, messages, commit, and rollback status for each reservation number, so
earlier successful deletions remain deleted if a later document fails. Empty
input is a successful no-op; `iv_test_run` validates each document without
committing.

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
`preview_cost_center_demands` evaluates multiple requests together in caller
order, converts each material-specific input unit, and consumes each shared
material/plant balance once across those requests. It returns per-request base
and input-unit quantities, allocations, and shortfalls without calling the
reservation API. This bulk preview is plant-level and does not select batches
or storage locations.
`preview_cost_center_by_date` adds a required date and optional projected
receipts to each demand. Earlier dates consume shared stock first; on the same
date, larger integer priorities allocate first and input order breaks ties.
Results stay in caller order and report base-unit and input-unit quantities.
Its opt-in supply sources and safety-stock protection match the dated stock
allocator; this is still a plant-level preview and does not create reservations.
Set `iv_check_atp = abap_true` and provide `iv_atp_check_rule` to add SAP ATP
diagnostics. The service checks cumulative demand once per material, plant,
base unit, and required date, then returns the cumulative quantity and confirmed
and unconfirmed base quantities on each matching demand. ATP results remain
separate from local allocation and do not change its splits.
`preview_cost_center_locations` adds optional storage-location preferences to
multiple cost center demands. A location is a hard restriction by default;
set `fallback_to_other_locations = abap_true` to try it first and then use
other locations in ascending order. Requests share location balances in caller
order. Pass `it_location_priority` to order fallback locations; a preferred
location remains first. Each result includes its location splits in the
requested unit and base unit. Optional safety-stock protection is available;
batch selection and reservation creation are not part of this preview.
`preview_cost_center_batches` adds an explicit batch per demand and returns
batch, expiration, storage-location, and converted quantity splits. Requests
share balances for the selected material, plant, and batch in caller order.
An optional `required_date` filters the selected batch through that date; a
positive `minimum_shelf_life_days` extends the required life and excludes
unknown expirations. Expiration on the threshold date is eligible; an unknown
expiration remains eligible when no positive minimum is requested. An optional
storage location is hard by default; fallback mode tries it first and may use
other locations while staying within the selected batch. Its
`it_location_priority` option orders those fallback locations. The method does
not substitute a different batch or create reservations.
`preview_cost_center_fefo` selects eligible batches by earliest expiration for
multiple cost center demands. Requests share batch balances in caller order;
optional location fallback checks the preferred location first. Pass
`it_location_priority` to order locations when the same batch and expiration
date exist in multiple locations; expiration and batch order remain primary.
The as-of date and shared minimum remaining shelf life apply to every demand.
Each demand can also specify `minimum_shelf_life_days`; the greater of the two
values applies to that row and appears in its preview. A demand may also set
`fefo_as_of_date`; the later of it and the shared `iv_as_of_date` controls the
expiry filter and appears on its result and batch splits. Results include the
selected batch splits with source-unit quantities. This preview does not create
reservations or run SAP batch determination.
`reserve_cost_centers_atomic` preallocates the full demand group before writing.
Use shared location balances, caller-selected batches on every demand, or set
`iv_use_fefo_batches = abap_true` to choose eligible batches by expiration;
these strategies cannot be mixed in one group. Every requested quantity must be
available before it writes. Each row's `required_date` must be a Gregorian
date in every allocation mode; malformed dates are rejected before stock
reads. It creates one reservation per demand, commits the group once, and rolls
the group back if a creation or commit fails. Location
fallback and safety-stock protection are supported; `it_location_priority`
orders fallback locations while preserving a demand's preferred location as
first. In FEFO mode, expiration and batch order remain primary and location
priority only resolves same-batch, same-expiration ties. FEFO uses
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
`iv_test_run = abap_true` runs each reservation
in test mode and skips the commit; the result reports allocations, per-demand
API responses, commit status, and rollback status.
Non-test creates require a distinct reservation number for each demand. A
duplicate number fails the group and triggers rollback; reservation numbers are
cleared from the result after any group rollback.
Pass `iv_check_atp = abap_true` with `iv_atp_check_rule` to add cumulative SAP
ATP diagnostics by material, plant, base unit, and required date. Each date group
is checked with its cumulative quantity and the result is attached to each
matching demand; this diagnostic does not change the local allocation. Set
`iv_require_atp_confirmation = abap_true` to stop the entire group before any
reservation API call when a date group's confirmed quantity is short.

`reserve_cost_centers_bulk` accepts the same demand rows and allocation
options, but processes each demand independently in caller order. It validates
all request keys and shared options before the first write, then creates and
commits one reservation per successful demand. A failed demand is rolled back
and later demands still run; earlier successful reservations remain committed.
Results report each allocation, API messages, and commit/rollback state.
Empty input succeeds without a stock read or write. Set `iv_test_run` to
validate each demand in SAP test mode without committing.

Set `iv_use_fefo_batches = abap_true` to reserve automatically selected
batches by earliest expiration date. The as-of date defaults to today;
`iv_fefo_min_days` can require a minimum remaining shelf life. Expired batches
are excluded, and undated batches are excluded when the minimum is positive.
FEFO cannot be combined with an explicit `iv_batch`; a supplied storage
location remains a hard restriction unless `iv_allow_fallback = abap_true` is
passed, in which case it is tried first and other locations are considered
afterward.

## Production construction

`ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_STOCK_SERVICE()` wires the stock service
to the MARD repository, material UOM converter, and SAP availability adapter.
`CREATE_GOODS_MOVEMENT_SERVICE()` wires the goods-movement service to its BAPI
adapter and material UOM repository. `CREATE_STO_ORDER_SERVICE()` wires the
stock-transfer order service to its purchase-order BAPI adapter. The service
constructors remain public for applications that supply their own adapters.

```abap
DATA(lo_stock_service) =
  zcl_stock_allocation_factory=>create_stock_service( ).
```

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
Caller-supplied cutoff dates, dated allocation requirements, and FEFO as-of
dates are checked as Gregorian calendar dates before UOM conversion, stock
reads, or ATP calls. This rejects malformed dates; SAP still determines whether
a valid date is usable for the material, plant, and planning horizon.
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
Explicit sales-order batch selections are checked through the effective
reservation date: the schedule line's requested date, or the current date when
the item has no schedule date. A batch expiring on that date remains eligible;
an earlier expiry produces a preview shortfall and blocks reservations when
full allocation is required. A selection can set
`minimum_shelf_life_days` to require additional days beyond that date. A batch
on the minimum boundary remains eligible, while unknown expiry dates are
excluded when the minimum is positive.
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
real standard table. GitHub Actions runs this same validation on pushes and
pull requests with Node.js 22 and a pinned open-abap-core revision.

See [PLAN.md](PLAN.md) for implementation requirements and [NOTES.md](NOTES.md)
for progress.
