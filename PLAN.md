make a stock allocation solution in ABAP, add one feature at a time, keep improving it. It must integrate into existing SAP system and follow best practices for ABAP development.

use abaplint and transpiler for testing, record bugs and issues in ANOMALIES.md

open-abap does not include the business logic needed, add SAP standard stubs in a separate directory and include it in linting and transpiling. This includes stuff like reading stock and writing stock, reading and writing orders, etc via SAP standard APIs. Eg. database table MARD carries available stock, add it to the stubs for reading stock. All custom code starting with Z must be in the src folder.

keep your notes and progrss in NOTES.md

these abaplint rules also be enabled: modify_only_own_db_tables + align_type_expressions + easy_to_find_messages + max_one_method_parameter_per_line + align_parameters + local_testclass_consistency + allowed_object_naming + line_length

use https://github.com/open-abap/open-abap-core as a dependency in abaplint and the transpiler configurations

## Sales-order issue outcomes and minimum fill thresholds

Aggregate and FEFO sales-order issue previews expose `allocation_outcome` for
every demand: `F` means fully covered, `P` means partially covered, and `U`
means no quantity was allocated. When full quantity is required, an underfilled
demand remains unallocated and reports `U`. Unit-aware methods derive the code
from base-unit quantities, independent of rounding in converted display
quantities. The field complements `is_sufficient` by distinguishing partial
coverage from no coverage.
Aggregate base, unit-aware, and FEFO issue summaries also expose
`minimum_coverage_rejected`. It is true when the final base-unit allocation
fails a positive floor, including full-quantity rejections, and false when the
floor passes or is zero.

Each aggregate or FEFO request can set `minimum_coverage_pct` from 0 through
100. Its initial value preserves partial-allocation behavior. The service
compares provisional coverage against the threshold using unrounded base-unit
quantities; when the threshold is not met, it allocates zero for that demand
and leaves the shared balance for later requests. FEFO previews apply the gate
before consuming any eligible batch balances and echo the threshold on the
summary and batch split rows. Results echo the threshold. Call-wide or
per-demand full-quantity options continue to require full coverage.

Sales-order allocation previews and reservation creation also accept
`minimum_coverage_pct` on item allocation requirements, keyed by sales
document, item, and optional schedule line. A demand below its floor receives
zero allocation before stock is consumed. Ordinary, location, batch, FEFO,
and date-first paths preserve the floor and echo it with F/P/U outcome and
two-decimal base-unit coverage. Their summaries also expose
`minimum_coverage_rejected` when the final base-unit allocation fails a positive
floor, including full-quantity rejections; the flag is false when the floor
passes or is zero. A line-wide requirement applies to schedule lines without a
more specific requirement; full-allocation rules remain in force.

Single- and multi-order result `order_summaries` also report the aggregate
`allocation_outcome` (`F`, `P`, or `U`) and two-decimal
`allocation_coverage_pct`. Both are calculated from summed requested and
allocated base-unit quantities for each sales document, material, plant, and
base unit; coverage is zero when the grouped request quantity is zero. Each
summary also counts fully allocated, partially allocated, and unallocated
demand lines, counts lines rejected by a positive coverage floor, and validates
that the three outcome counts cover every demand line. `floor_rejected_line_pct`
reports the rejected-line count as a percentage of demand lines, rounded to two
decimals. The summaries also report `fully_allocated_line_pct`,
`partially_allocated_line_pct`, and `unallocated_line_pct`, each outcome count
as a share of demand lines rounded to two decimals. Each share is rounded
independently, so their displayed sum may differ slightly from 100%.

Single- and multi-order preview and reservation results also return one
`document_summaries` row for each sales document with positive open
demand. Its `allocation_outcome` is `F` when every demand line is fully
allocated, `U` when no line receives stock, and `P` otherwise. The row counts
fully allocated, partially allocated, unallocated, and coverage-floor-rejected
lines. It also reports `floor_rejected_line_pct` from the rejected share of demand
lines. It also reports `fully_allocated_line_pct`,
`partially_allocated_line_pct`, and `unallocated_line_pct` as each outcome's
share of demand lines rounded to two decimals. It also reports the dated-line
count and required-date span, plus the minimum and maximum allocation ranks and
their `S` or `M` scope. It does not
combine quantities across materials because their base units may differ; the
line outcome counts and percentages cover the full document.
Bulk reservation `order_results` also carry the matching `document_summary`
beside each write status, including rows whose reservation failed or was
skipped after an earlier failure; each nested summary retains its date and
allocation-rank metadata.

Multi-order preview and reservation results also expose `material_summaries`,
grouped across the selected documents by material, plant, and base unit. They
report checked requested, allocated, and shortfall totals, aggregate F/P/U
outcome and coverage, distinct document counts, and line counts; totals from
different base units remain separate. They also report `floor_rejected_line_pct`
as the rejected-line count divided by the demand-line count, rounded to two
decimals, and `fully_allocated_line_pct`, `partially_allocated_line_pct`, and
`unallocated_line_pct` as the respective outcome shares of demand lines rounded
to two decimals.
Both `order_summaries` and `material_summaries` also report the first and last
nonblank required dates among their demand lines; both fields stay initial when
the group has no dated lines. `dated_line_count` reports how many demand lines
contribute dates to the span.
They also report `first_allocation_sequence` and `last_allocation_sequence`,
the minimum and maximum processing ranks represented in the group. Other
material groups can occupy ranks between those values.
`allocation_sequence_scope` is `S` for a single-order summary and `M` for a
global date-first multi-order summary; material summaries use `M`.

## Shared material/plant demand coverage floors

Shared material/plant allocation APIs accept `iv_minimum_coverage_pct` on
single requests and `minimum_coverage_pct` on base and UOM demand rows,
including priority allocation and ATP wrappers. Local date-first requests and
base/UOM demand rows accept the same floor, including their ATP wrappers. Zero
preserves partial allocation. The service compares provisional coverage in
base units before consuming the shared balance; a demand below its floor gets
zero allocation so later requests can use the stock. Values from 0 through 100
are validated and the threshold is echoed on each allocation result.

## Undated local coverage floor rejection status

Undated material/plant allocation summaries expose
`minimum_coverage_rejected` for scalar, base-demand, UOM, priority, and UOM ATP
results. It is true when the resulting allocation fails a positive
`minimum_coverage_pct`, including full-quantity rejections, and false when the
floor passes or is zero. A rejected allocation consumes no shared stock, so a
later demand can use that balance; unit and ATP adapters preserve the status.
The same status is reported by storage-location, date-first location,
exact-batch, FEFO, and quality FEFO summaries that use the shared allocation
result type.

## Local date-first coverage floor rejection status

Date-first scalar, base-demand, UOM, and ATP allocations expose
`minimum_coverage_rejected` on each dated allocation summary. It is true when
the provisional base-unit allocation fails the configured positive
`minimum_coverage_pct` and false when the floor passes or is zero. A rejected
allocation consumes no shared stock, leaving it available to later demands.
UOM and single or bulk ATP adapters preserve the same status.

## Priority allocation trace sequences

Priority material/plant allocators also return a one-based
`allocation_sequence` on each result. It records the calculation order after
sorting by descending priority and caller input order for ties, while result
rows remain in caller order. The sequence includes rows allocated zero
quantity. Base, UOM, and priority ATP local-estimate results preserve it;
the corresponding non-priority material/plant allocation methods leave it
initial.

Sales-order aggregate and FEFO issue previews expose a one-based
`allocation_sequence` on each demand summary. FEFO batch splits echo the
summary's rank. It records the actual order after optional required-date and
priority sorting, including stable input-order ties, while output rows remain in
caller order. Every demand receives a rank, including zero-allocation rows.
Base and unit-aware results preserve the sequence.

Sales-order allocation results and their `sales_unit_allocations` summaries
also expose a one-based `allocation_sequence`, including zero-allocation rows.
Single-order previews rank the rows in the order passed to allocation after any
requested-date and priority ordering. `PREVIEW_ORDERS_BY_DATE` preserves the
shared allocator's date and priority rank while returning rows in its existing
result order. Each unit-aware row also reports `allocation_sequence_scope`: `S`
for a single-order sequence and `M` for the global multi-order sequence.

Cross-plant `ALLOCATE_PLANTS_PRIORITY` and `ALLOCATE_PLANTS_UOM_PRIORITY`
allocation summaries also expose this sequence. It follows descending demand
priority with input-order ties, while summaries remain in caller order; the
rank includes rows with zero allocation. The UOM priority ATP local estimate
preserves the sequence. Source-plant ordering within each request remains
caller-controlled.

`ALLOCATE_PLANTS_BATCH_PRIORITY` and `ALLOCATE_PLANTS_BATCH_UOM_PRIO` expose
the same sequence on demand summaries, source-plant rows, and location splits.
Ranks follow effective `as_of_date` order, treating blank dates as today, then
descending priority and stable input-order ties while results remain in caller
order. Each summary receives a rank, including zero allocations, and each emitted
split echoes its demand's rank. The UOM ATP local estimate preserves the summary
and split ranks.

`ALLOCATE_PLANTS_FEFO_PRIORITY` and `ALLOCATE_PLANTS_FEFO_UOM_PRIO` expose the
sequence on demand summaries, source-plant rows, and FEFO batch splits. Ranks
follow descending priority and stable input-order ties; rows return in caller
order. The UOM ATP local estimate preserves the summary and split ranks.

`ALLOCATE_LOCATION_PRIORITY` and `ALLOCATE_LOCATION_UOM_PRIORITY` expose the
same sequence on allocation summaries and storage-location splits. Ranks follow
descending demand priority and stable input-order ties, including rows with no
allocation. UOM ATP local estimates preserve the summary and split ranks.
Internal request mapping keeps repeated caller IDs distinguishable.

`ALLOCATE_BY_BATCH_PRIORITY` and `ALLOCATE_BY_BATCH_UOM_PRIORITY` expose the
same sequence on allocation summaries and batch splits. The default rank follows
descending demand priority and stable input-order ties. With date-first ordering,
earlier demand dates come first and priority breaks same-date ties. Results remain
in caller order, including zero-allocation rows and repeated request IDs. Every
summary receives a rank, and each emitted batch split echoes its demand's rank.
The UOM ATP local estimate preserves summary and split ranks.

`ALLOCATE_BY_EXPIRY_PRIORITY` and `ALLOCATE_FEFO_UOM_PRIORITY` expose the same
sequence on allocation summaries and batch splits. Ranks follow the selected
priority-first or date-first demand order, with stable input-order ties, while
results remain in caller order. Every summary receives a rank, including when
allocation is zero; each emitted batch split echoes its demand's rank. The UOM
ATP local estimate preserves summary and split ranks.

`ALLOCATE_QUALITY_FEFO_PRIORITY` and `ALLOCATE_QUALITY_UOM_PRIORITY` expose the
same sequence for quality-inspection batch allocation. Their summaries and batch
splits remain in caller order, and the quality UOM ATP local estimate preserves
the summary and split ranks.

`ALLOCATE_DEMANDS_BY_DATE` returns a one-based `allocation_sequence` on each
summary. It follows the allocator's material and plant grouping, then required
date ascending, priority descending, and caller order for ties. Results stay in
caller order, and every request receives a rank even when it gets zero stock.
`ALLOCATE_REQUEST_BY_DATE`, dated UOM results, and dated ATP local estimates
preserve the same rank.

`ALLOCATE_PLANTS_BY_DATE` exposes the same one-based sequence on each demand
summary and emitted source-plant row. It follows required date ascending,
priority descending, and caller order for ties. Summaries and source rows remain
in caller order; UOM and ATP local estimates preserve the summary and split
ranks. `ALLOCATE_PLANTS_BY_DATE_LOC` also exposes the rank on demand summaries,
source-plant rows, and location splits. Its UOM and ATP local estimates preserve
all three ranks.

`ALLOCATE_PLANTS_FEFO_BY_DATE` exposes the sequence on demand summaries,
source-plant rows, and FEFO batch splits. It follows material grouping, then
required date ascending, priority descending, and caller order for ties. Each
demand receives a rank even when it gets zero stock; emitted source and batch
rows echo that rank. The unit-aware and ATP local estimates preserve it.
`ALLOCATE_PLANTS_BATCH_BY_DATE` exposes the same trace on demand summaries,
source-plant rows, and location splits. Its rank follows required date
ascending, priority descending, and caller order for ties. Summaries remain in
caller order, zero-allocation demands receive a rank, and UOM and ATP local
estimates preserve each rank.

`ALLOCATE_LOCATION_BY_DATE` exposes a one-based sequence on each summary and
storage-location split. It follows required date ascending, priority descending,
and caller order for ties while results remain in caller order. Its UOM and ATP
local estimates preserve the summary and split ranks.

WBS `PREVIEW_FEFO_BY_DATE` exposes a one-based `allocation_sequence` on demand
summaries, batch splits, and WBS assignment rows. It follows required date
ascending, priority descending, and stable input order for ties while returning
rows in caller order. The sequence distinguishes repeated caller request IDs.
`PREVIEW_FEFO_BY_DATE_ATP` preserves it in the local estimate.

WBS `PREVIEW_BY_LOCATION_DATE` and `PREVIEW_TRANSFER_LOCATION_DATE` expose the
same one-based `allocation_sequence` on demand summaries, storage-location
splits, and WBS assignment rows. The rank follows required date ascending,
priority descending, and stable input order, while the returned rows retain
caller order. Their ATP adapters preserve the trace in each local estimate.
WBS `PREVIEW_TRANSFER_FEFO_BY_DATE` also exposes the sequence on demand
summaries, batch splits, and transfer assignment rows; its ATP adapter preserves
the same rank.

WBS priority FEFO and batchless location previews also expose a one-based
`allocation_sequence` on demand summaries, emitted batch or location splits,
and WBS assignment rows. Priority transfer FEFO and location previews expose
the same rank on transfer assignments. The rank follows descending priority
and stable input order, or required FEFO date followed by priority when
date-first mode is enabled. Results remain in caller order, zero-allocation
demands receive a rank, and ATP local estimates retain it.

## Production component minimum coverage floors

Production component allocation policies may set `minimum_coverage_pct` from
0 through 100 per reservation. The scoped allocator compares the floor with
eligible base-unit stock after the required-date, location, batch, expiry,
fallback, projected-receipt, and safety-stock rules have been applied. A
component below its floor receives no allocation and leaves stock for later
components. Component allocation summaries echo the floor; ATP remains a
separate confirmation of the requested demand. Per-component local estimates
also expose `allocation_outcome` (`F`, `P`, or `U`) and the allocated/requested
base-unit `allocation_coverage_pct`, rounded to two decimals and zero for a
zero-quantity component. The grouped local estimate preserves the outcome and
coverage percentage from its date-based plant summary.

## Production component coverage floor rejection status

Direct `ALLOCATE_COMPONENT_STOCK` results and per-component
`component_local_estimate` rows expose `minimum_coverage_rejected`. It is true
when eligible stock coverage is below a positive configured
`minimum_coverage_pct`, including when no stock is available, and false when the
floor is met or configured as zero. A floor-rejected component allocates zero and leaves eligible
stock for later components. Production-component previews copy the flag from the
scoped allocation result; the grouped `local_estimate` keeps this
per-component status initial.

## Production component allocation trace sequences

Each production component result exposes a one-based `allocation_sequence` on
its `component_local_estimate`, with `allocation_sequence_scope` identifying
the allocator path: `D` for dated plant allocation and `S` for scoped
component allocation. Dated per-component ranks follow material, plant,
required date, and input order; their grouped `local_estimate` retains the
date-group rank, which can be shared by components due on that date. Scoped
per-component ranks follow required date, scope rank, priority, and stable input
order, and every emitted batch or location split echoes that rank together with
`allocation_sequence_scope` set to `S`, so split rows are self-describing. Each
path has its own sequence counter. Component rows remain in repository order; a
scoped grouped `local_estimate` remains an aggregate without a single demand
sequence.

## Storage-location demand coverage floors

Undated `ALLOCATE_BY_STORAGE_LOCATION` base and UOM demand rows accept
`minimum_coverage_pct`, including priority and ATP wrappers. The allocator
compares eligible base-unit stock after location scopes, fallback rules, and
safety-stock protection. A demand below the floor gets zero allocation and
leaves each location balance available to later rows. Results echo the floor.
`ALLOCATE_LOCATION_BY_DATE` applies the same per-row floor against the balance
available at each required date, including eligible projected receipts. A
rejected dated demand consumes no stock; UOM and ATP wrappers preserve the
threshold.

## Exact-batch and FEFO demand coverage floors

Exact-batch, FEFO, and quality FEFO demand rows accept
`minimum_coverage_pct` from 0 through 100, including UOM, priority, and ATP
variants. The allocator compares the floor with eligible base-unit stock after
batch, expiry, shelf-life, location, receipt-date, and safety-stock rules have
been applied. It performs this check before consuming any batch or location
balance; a row below its floor receives no allocation, leaving stock for later
demands. Zero preserves partial-allocation behavior. Results echo the floor
on allocation summaries, and FEFO results retain it on batch splits. UOM
conversion does not change the coverage comparison. Existing full-quantity
options remain in force alongside the minimum floor.

Quality FEFO release and send wrappers reject any nonempty allocation rows or
embedded allocation location scopes, plus all direct location-scope inputs,
when the demand table is empty. The scope check covers shared location
priority, request-specific location priority, the shared location allowlist,
and request-specific allowed locations.

Valuation-type allocation requests accept the same floor on base and UOM demand
rows. Eligibility scopes for valuation type, location, batch, projected source,
expiry, receipt date, and safety stock determine provisional base-unit
availability. A request below its floor consumes no balance, while its summary
echoes the threshold and full shortfall. The UOM and ATP preview wrappers retain
the row value.

Cross-plant requests accept per-row coverage floors on ordinary, priority, UOM,
and dated demand rows, including ATP previews. The floor is compared with the
combined remaining availability from caller-selected source plants after
location scopes, receipt cutoffs, projected receipts, and safety-stock
protection. Planning-date allocations apply the comparison to availability by
the required date. A row below its floor consumes no source balance; summaries
echo the threshold and full shortfall. UOM conversion does not alter the
base-unit comparison.
Cross-plant exact-batch and FEFO demand rows, including date-first variants,
apply the same floor to combined eligible stock from their selected source
plants after exact-batch, expiry, shelf-life, location, projected-receipt, and
safety-stock rules. The comparison happens before any batch balance is
consumed. Base, UOM, priority, and ATP adapters preserve the threshold;
allocation summaries echo it, and FEFO batch splits retain it.

Cross-plant ordinary, date-first, exact-batch, and FEFO demand summaries also
expose `minimum_coverage_rejected`. It is true when the final base-unit
allocation fails a positive floor, including full-quantity rejections, and
false when the floor passes or is zero. Priority, UOM, date, batch, and ATP
wrappers preserve the status.

## Valuation-type coverage floor rejection status

Valuation-type allocation summaries also expose `minimum_coverage_rejected`.
It is true when the final allocation fails a positive
`minimum_coverage_pct`, including full-quantity rejections, and false when the
floor passes or is zero. UOM and ATP local-estimate wrappers preserve the
status from the base-unit allocation.

## Valuation-type allocation outcomes and coverage

`PREVIEW_BY_VALTYPE` allocation summaries also expose `allocation_outcome`:
`F` for fully allocated, `P` for partially allocated, and `U` when no quantity
was allocated. They report `allocation_coverage_pct` as allocated divided by
requested base-unit quantity, rounded to two decimals and zero for a zero
request. Full-quantity and minimum-floor rejections report `U` with zero
coverage. UOM and ATP local-estimate wrappers preserve both values from the
base-unit result.

Shared material/plant, location, batch, FEFO, and cross-plant ordinary, dated,
exact-batch, and FEFO allocation summaries expose `allocation_outcome`: `F`
for full coverage, `P` for partial coverage, and `U` when the allocation is
zero. They also expose `allocation_coverage_pct`, calculated from allocated
and requested base-unit quantities, rounded to two decimal places, and set to
zero when the request quantity is zero. Unit, priority, and ATP summaries
preserve both values from the base-unit allocation.
Local date-first request and demand allocations expose the same outcome and
percentage. Their UOM and ATP adapters preserve both values from the base-unit
summary.

## Cost-center aggregate demand coverage floors

Plant-level `PREVIEW_COST_CENTER_DEMANDS` rows accept
`minimum_coverage_pct` from 0 through 100. The floor is compared against
provisional base-unit availability before the shared material/plant balance
is consumed. A request below its floor receives zero allocation so later
cost-center requests can use the stock. Unit-aware, priority, and ATP preview
paths preserve the row floor; allocation results echo it. Zero keeps the
existing partial-allocation behavior, and the call-wide full-quantity option
continues to apply.

Date-first `PREVIEW_COST_CENTER_BY_DATE` rows accept the same floor. It is
checked against availability at the required date, after eligible projected
receipts and safety-stock protection. A rejected row consumes no balance for
later requests. UOM and ATP previews preserve and echo the per-row threshold.

`PREVIEW_COST_CENTER_LOCATIONS` rows accept the same coverage floor after
location scopes, fallback rules, and safety-stock protection determine eligible
stock. A row below its floor consumes no location balance. Priority and ATP
paths preserve the threshold, and the allocation summary echoes it.
`PREVIEW_CC_LOCATIONS_BY_DATE` applies the floor to eligible location stock at
the required date, including caller-provided projected receipts. Its UOM and
ATP paths retain the threshold after the date and location checks.
Exact-batch and FEFO cost-center previews also accept per-row floors. They are
checked after batch, expiry, shelf-life, location, projected-receipt, and
safety-stock rules determine eligible stock, before any batch balance is
consumed. Date-first and ATP adapters preserve the floor; allocation summaries
and FEFO batch splits echo it.

Single cost-center preview and reservation methods accept a scalar
`minimum_coverage_pct` from 0 through 100. The floor is evaluated in base units
against eligible stock after batch, FEFO, location, fallback, and safety-stock
rules. A request below the floor receives no allocation, and reservation
creation is skipped when no stock remains allocated. The preview and
reservation results echo the threshold, allocation outcome (`F`, `P`, or `U`),
and two-decimal `allocation_coverage_pct` calculated from base-unit quantities.
They also expose `minimum_coverage_rejected` when the final base-unit
allocation fails a positive floor, including full-quantity rejections; the
flag is false when the floor passes or is zero. The optional input defaults to
zero, preserving partial allocation.

Atomic and bulk cost-center reservation demand rows also accept
`minimum_coverage_pct` from 0 through 100. The reservation preview applies the
floor after location, exact-batch, FEFO, expiry, fallback, and safety-stock
eligibility. A rejected demand receives zero allocation and leaves stock
available to later rows; date-first FEFO wrappers preserve the value. Atomic
groups retain all-or-nothing posting, while bulk results report each demand
independently.

## Cost-center allocation trace sequences

`PREVIEW_COST_CENTER_BY_DATE` exposes the shared allocator's one-based
`allocation_sequence` on each result and nested allocation. It follows the
material/plant grouping and then required-date, priority, and stable input
ordering while results stay in caller order. ATP results preserve the same
rank.

`PREVIEW_CC_LOCATIONS_BY_DATE`, `PREVIEW_CC_BATCHES_BY_DATE`, and
`PREVIEW_COST_CENTER_FEFO_DATE` expose a one-based `allocation_sequence` on
each demand summary and every emitted storage-location or batch split. Ranks
follow required date ascending, priority descending, and input order for ties;
the exact-batch preview treats a blank required date as today. Returned rows
remain in caller order, and zero-allocation demands keep their scheduled rank.
ATP-enabled previews preserve the same summary and split ranks.

`RESERVE_CC_ATOMIC_BY_DATE`, `RESERVE_CC_BULK_BY_DATE`,
`RESERVE_CC_FEFO_DATE_ATOMIC`, and `RESERVE_CC_FEFO_DATE_BULK` expose the
same trace on reservation result items, nested allocation summaries, and
location or batch splits. Item rows remain in caller order. Bulk reservation
items also expose the sequence for their actual caller or priority processing
order; rows skipped after a stop-on-failure keep their scheduled rank.

Cost-center goods-issue adapters revalidate the echoed floor before posting
single, location, date-first location, exact-batch, and FEFO allocations. The
check uses base-unit requested and allocated quantities; malformed floors and
positive allocations below the threshold are rejected, while zero allocations
remain valid floor rejections subject to the existing full-allocation options.
Sales-order aggregate and FEFO issue adapters and quality-stock FEFO posting
adapters apply the same write-boundary validation to echoed floors before
creating a movement.

`PREVIEW_FEFO` and `PREVIEW_BY_LOCATION` WBS demands accept
`minimum_coverage_pct` from 0 through 100. The local allocator compares the
floor with eligible base-unit stock before consuming its shared WBS balance;
a rejected demand receives zero allocation and leaves the stock available to
later demands. Coverage equal to the floor passes. Their priority, date-first,
and ATP adapters preserve the row value. Allocation summaries expose F/P/U outcome
and two-decimal base-unit coverage; FEFO batch splits also echo the floor.
Summaries also expose `minimum_coverage_rejected`, true when final allocated
base quantity falls below a positive floor, including full-quantity rejections;
it is false when the floor passes or is zero. Priority, date-first, transfer,
and ATP results preserve the flag.
WBS transfer FEFO and location previews apply the same floor to eligible stock
on the source WBS. A rejected transfer receives zero allocation and leaves
source stock available to later demands; priority, date-first, and ATP transfer
adapters preserve the threshold.
WBS FEFO and location reservation methods carry the floor through their first
preview and fresh recheck, including priority and date-first methods.
Priority and date-first WBS location and FEFO issue wrappers, and WBS transfer
posting wrappers, carry the floor through their fresh stock rechecks.
The shared batchless and FEFO issue writers, plus location and batch transfer
writers, validate the echoed floor again against requested and allocated base
quantities immediately before movement creation.

Base WBS FEFO and location previews expose one-based `allocation_sequence`
values on demand summaries, emitted splits, and WBS assignment rows. Base
transfer FEFO and location previews expose the rank on transfer assignment
rows. Base ranks follow caller order, including demands with zero allocation.
Priority wrappers preserve the underlying rank after processing sorted demands;
their WBS and transfer assignments echo the same sequence. ATP local estimates
retain it.

Stock transport order creation validates the per-demand minimum coverage floor
carried by ordinary, date-first, date-location, exact-batch, and FEFO
cross-plant allocation results before building purchase-order requests. The
check uses requested and allocated base quantities, rejects malformed floors
and positive allocations below their threshold, and accepts zero allocations
as floor-rejected demands for the existing partial-allocation policy to handle.

## Batch expiry posting

Expired-batch scrapping consumes the base-unit expiry exposure report, accepts
explicit batch/location/valuation/cost-center quantities, and posts movement
551 only when a batch's expiration date precedes the posting date and its
reported available unrestricted balance covers the selected quantity. Exposure
status describes the batch at the snapshot's as-of date, so an upcoming batch
may become eligible by the posting date; status and expiration must agree at
the as-of date. An upcoming row may be selected only when its expiration is on
or before the inclusive `through_date`; later dates belong to the after-window
summary and are outside direct preview and posting scope. Batch exposure rows
sort by status, expiration date, batch,
storage location, and valuation type to keep equal-expiry FEFO allocation
order deterministic. Each dated detail row includes `days_to_expiration`,
calculated as `expiration_date - as_of_date`: negative values are expired, zero
expires on the as-of date, and positive values are upcoming. UOM detail rows echo
the same calendar-day distance in their nested base row. Batch details also
expose `manufacturing_date`, its `manufacturing_date_source`
(`P` for plant-level MCHA-HSDAT, `G` for the global MCH1-HSDAT fallback, blank
when unavailable), and signed `days_since_manufacture` calculated as
`as_of_date - manufacturing_date`. The age is initial when no manufacture date
is known; a future manufacture date produces a negative value. Dated and
undated rows both carry these fields, and UOM detail rows preserve them in their
nested base row. The date describes the batch's recorded manufacture date, not
the date inventory was received. The result also identifies
`oldest_manufacture_storage_loc`, `oldest_manufacture_batch`, and
`oldest_manufacture_val_type` for the chronologically earliest recorded
manufacture date among positive-stock rows that match the exposure filters.
`oldest_manufacturing_date_src` retains its plant/global/other source,
`days_since_oldest_manufacture` uses the same signed `as_of_date - date`
calculation, and UOM results echo the identity and date fields unchanged. Rows
without a manufacture date do not qualify; ties use batch, storage location,
then valuation type. Each result counts returned
batch/location/valuation rows
with positive stock as `expired_batch_row_count` and
`upcoming_batch_row_count`, plus `undated_batch_row_count` for positive-stock
batch/location/valuation rows with no resolved expiry date. The cumulative
`within_7d_batch_row_count`, `within_30d_batch_row_count`, and
`within_90d_batch_row_count` values, each with four category totals, summarize
upcoming rows with positive stock expiring from `as_of_date` through 7, 30, and
90 calendar days later, respectively, inclusive and within the requested window.
The 7-day and 30-day horizons are subsets of the longer horizons. UOM results
include each category total in base and requested units and preserve the counts.
Separate non-overlapping buckets report `within_7d_batch_row_count` for days
0–7, `from_8_to_30d_batch_row_count` for days 8–30,
`from_31_90d_batch_row_count` for days 31–90, and
`over_90d_batch_row_count` for day 91 onward, each with four category totals.
Together they partition upcoming positive-stock rows and their category totals;
counts and quantities reconcile to the upcoming totals. UOM results carry each
bucket in base and requested units and preserve the counts.
Undated rows stay out of dated detail and dated totals; base-unit totals by unrestricted,
available, quality-inspection, and blocked category show their stock. The
separate `undated_batches` list returns every positive-stock undated row in
batch, location, and valuation order. A nonblank `storage_location` filters the exposure to that exact location;
set `filter_storage_location` to `abap_true` to select blank locations. The flag
accepts only `abap_true` or `abap_false`. A nonblank `batch` also filters to
its exact batch; set `filter_batch` to `abap_true` to select blank batches. A
nonblank `valuation_type` filters to that exact valuation type; set
`filter_valuation_type` to `abap_true` to select blank valuation types. All
four flags accept only `abap_true` or `abap_false`, and the location, batch,
and valuation constraints intersect. `expiry_source` accepts `P` for a
plant-level expiry date, `G` for the global fallback, and `O` for any other
source value, including blank. Set `filter_expiry_source` to `abap_true` with a
blank `expiry_source` to select only rows without a resolved source. Nonblank
source values must be `P`, `G`, or `O`; the expiry-source scope intersects
with the other filters. Optional inclusive `expiration_date_from` and `expiration_date_to` bounds
filter rows by their resolved expiration date; either bound may be supplied,
and two bounds must be in ascending order. When either bound is supplied,
undated rows are omitted from the undated list, counts, and totals. The bounds
do not change expiry status relative to `as_of_date` or the after-window test
relative to `through_date`. The selected locations, batches, valuation types,
expiry source, date bounds, and flags are echoed on base and UOM results. Set `filter_expiry_status = abap_true` with `expiry_status` `E` for dates before `as_of_date`, `U` for dates from `as_of_date` through `through_date` inclusive, or `A` for dates after `through_date`. The status scope intersects with location, batch, valuation, source, and expiration-date bounds before dated counts, totals, and batch paging. When active, undated rows are omitted from undated details, counts, and totals. Only `E`, `U`, and `A` are accepted; `expiry_status` must be initial when disabled, and base and UOM results echo both selector fields. Allocation trace rows retain their independent scope. Set `filter_expiry_age_band = abap_true` with `expiry_age_band` `1` for 1–7 days since expiry, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector returns only expired rows, composes with status, source, and date bounds before counts, totals, and paging, and omits upcoming, after-window, and undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both selector fields. Set `filter_expiry_upcoming_band = abap_true` with `expiry_upcoming_band` `1` for 0–7 days from `as_of_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes the as-of date and only dates through the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. Set `filter_exp_after_window_band = abap_true` with `expiry_after_window_band` `1` for 1–7 days after `through_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes only dates after the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. Optional `filter_expiry_days_from` and `filter_expiry_days_to` with `expiry_days_from` and `expiry_days_to` set inclusive signed `expiration_date - as_of_date` bounds. Either bound may be used alone; expired values are negative, the as-of date is zero, future values are positive, and active bounds omit undated rows. Two active bounds must be ascending. These bounds compose before exposure counts, totals, and paging, and base and UOM results echo both flags and values. Optional inclusive `manufacturing_age_days_from` and `manufacturing_age_days_to` bounds, enabled by `filter_manufacturing_age_from` and `filter_manufacturing_age_to`, select rows by signed `days_since_manufacture` (`as_of_date - manufacturing_date`). Either bound may be used alone; future manufacture dates have negative ages and the as-of date has age zero. Active age bounds omit rows without a manufacture date, including expiry-undated detail rows. Two active bounds must be ascending. The bounds compose with other exposure filters before dated and undated summaries, counts, and paging; base and UOM results echo both flags and values.

Set `positive_available_only` to `abap_true` to retain only rows whose reservation-net `available_quantity` is positive. The selector accepts only `abap_true` or `abap_false` and defaults to false. It applies to dated and undated rows before expiry counts, category totals, source/status summaries, and detail paging; category balances on retained rows are unchanged. Base and UOM results echo the selector.
Optional inclusive `available_quantity_from` and `available_quantity_to` bounds, enabled by `filter_available_from` and `filter_available_to`, filter each row by reservation-net available quantity. Either bound may be used alone; two active bounds must be ascending, and zero or negative thresholds are valid. Thresholds use the material base stock unit for both base and UOM requests. Inactive values must be initial; base and UOM results echo the flags and values. The bounds compose with `positive_available_only` and all other filters before dated and undated summaries, counts, and detail paging.
Optional inclusive `available_pct_from` and `available_pct_to` bounds, enabled by `filter_available_pct_from` and `filter_available_pct_to`, select rows by their two-decimal `available_pct_of_unrestricted` value. The value is zero when unrestricted quantity is zero or negative; it can exceed 100 or be negative. Thresholds are unitless; either bound may be used alone, and two active bounds must be ascending. Inactive values must be initial. Base and UOM results echo the flags and values. These bounds compose with availability quantity bounds and all other filters before dated and undated summaries, counts, and detail paging.

Set `filter_positive_category` to `abap_true` and `positive_stock_category` to `U` for unrestricted, `A` for reservation-net available, `Q` for quality-inspection, or `B` for blocked quantity. Only these codes are accepted; the category must be initial when disabled. The filter retains rows with a positive balance in the selected category and composes with `positive_available_only` and all availability filters before counts, totals, and paging. Other category balances remain unchanged. Base and UOM results echo the selector, and allocation trace rows keep their independent scope.

Optional inclusive `category_quantity_from` and `category_quantity_to` bounds, enabled by `filter_category_quantity_from` and `filter_category_quantity_to`, further narrow rows selected by `filter_positive_category`. They use the category named by `positive_stock_category`, in material base units for both base and UOM requests. Either bound may be used alone; two active bounds must be ascending, inactive values must be initial, and base and UOM results echo the flags and values. These bounds apply before exposure summaries, counts, and paging; other category balances remain unchanged.

Optional inclusive `resv_deduction_from` and `resv_deduction_to` bounds, enabled by `filter_resv_deduction_from` and `filter_resv_deduction_to`, filter the signed difference `reservation_deduction_qty` = `unrestricted_quantity` − `available_quantity`. Either bound may be used alone; two active bounds must be ascending, and inactive values must be initial. The thresholds use material base stock units for both base and UOM requests. Base and UOM results echo the flags and values. The bounds apply before expiry summaries, counts, and detail paging.

The
repository still
reads material/plant stock to calculate reservation-net quantities across all
locations; the filters narrow returned stock rows, expiry and source counts,
and stock-category totals after netting. Reservation summaries remain
material/plant-wide. Those stock exposure filters do not narrow the allocation
trace; the independent reservation and pass filters can narrow its details,
while the allocation summary quantities and counts remain material/plant-wide.
The UOM list includes base rows and converted quantities.
The UOM result also carries summary totals in both base
and requested units. The first
undated row is identified by location, batch, and valuation type using batch,
location, and valuation order; its four category balances accompany it, with
base and requested-unit values in the UOM result. The result also
reports `after_window_batch_row_count` for positive-stock
batch/location/valuation rows with valid expiry dates after the requested
window, with separate category totals; the UOM result carries these totals in
base and requested units. The earliest after-window row is also identified by
location, batch, valuation, expiry date, and days from the as-of date, using
the same deterministic tie order; the UOM result echoes this identity and
date summary. `days_after_window_end` reports the days beyond the inclusive
`through_date`. Its fields are initial when there is no positive-stock row after
the window. Its unrestricted, available, quality-inspection, and blocked
quantities accompany the identity in base units; the UOM result carries both
base and requested-unit quantities. `after_next_expiry_batch_count` counts all
positive-stock rows sharing `after_next_expiration_date`;
`after_next_exp_unrestr_qty`, `after_next_exp_available_qty`,
`after_next_exp_quality_qty`, and `after_next_exp_blocked_qty` aggregate their
four categories. UOM results echo the count and include base/requested totals;
all are zero when there is no after-window row.
`after_next_exp_plant_count`, `after_next_exp_global_count`, and
`after_next_exp_other_count` split that cohort by resolved date source and
partition `after_next_expiry_batch_count`; UOM results echo them unchanged. Dated detail and row summaries report
whether expiry came from plant-level MCHA (`P`) or global MCH1 fallback
(`G`); unresolved dates have a blank source. UOM results echo those markers.
The results also count positive-stock dated rows by source in
`plant_expiry_source_row_count` and `global_expiry_source_row_count`,
including rows after the requested window; UOM results preserve those counts.
`other_expiry_source_row_count` counts dated positive-stock rows with an
other or blank source marker. The three counts partition all dated
positive-stock rows, including rows after the requested window; UOM results
echo the counts unchanged.
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
Each result also reports `open_reservation_row_count` for eligible RESB rows
with positive remaining quantities after effective exclusions; the UOM result
echoes the count. It records reservation rows considered by the local
availability calculation. `excluded_open_resv_row_count` reports RESB rows
whose remaining quantity is positive and whose reservation/item keys match
the effective exclusions. `unmatched_open_resv_excl_count` reports
effective keys without a positive open RESB match, and
`unmatched_excl_reservations` returns the unmatched keys in reservation/item
order; UOM results echo all three counts and the list unchanged.
`open_reservation_quantity` totals positive remaining quantities passed to
the local calculator, while `excluded_open_resv_quantity` totals the positive
remaining quantities removed by exclusions. Both are raw reservation totals
in the material base unit, not stock deductions. UOM results include base and
requested-unit fields for both totals. `fully_allocated_resv_count`,
`partially_allocated_resv_count`, and `unallocated_resv_count` classify
eligible open reservation rows by local allocation outcome. Fully allocated
rows have no residual; partially allocated rows have both a deduction and a
residual; unallocated rows have no local deduction. The counts sum to
`open_reservation_row_count`; exclusions are not included, and UOM expiry
results echo the counts. The three open-quantity totals, `fully_alloc_resv_open_qty`, `part_alloc_resv_open_qty`, and `unalloc_resv_open_qty`, partition eligible `open_reservation_quantity` by outcome using each row's entire open demand; excluded reservations are omitted. UOM expiry results provide base and requested-unit values for each total. `matched_allocation_quantity` and
`fallback_allocation_quantity` summarize the deductions made by the matching
and fallback passes. Together with `uncovered_open_resv_quantity`, they sum to
eligible `open_reservation_quantity`; excluded demand is outside that total.
UOM results return base and requested-unit fields for both pass totals, so a
caller can compare them without summing `allocation_details` rows.
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
`matched_allocation_row_count` and `fallback_allocation_row_count` count trace
rows for each pass. Each row is one positive deduction against one stock row;
the counts are not distinct reservation counts. UOM results echo the counts.
`uncovered_open_resv_quantity` reports the eligible open demand left after
the calculator's matching and fallback passes; it describes local allocation,
not an SAP-confirmed shortage. The UOM result carries base and requested-unit
values. `uncovered_open_resv_keys` lists reservation/item keys with a positive
residual after local allocation. `uncovered_open_reservations` also returns
each key's RESB requirement date, storage location, batch, valuation type,
required quantity, withdrawn quantity, open quantity, locally allocated
quantity, matched quantity, fallback quantity, and positive residual
quantity. Required and withdrawn quantities retain their RESB source values;
open equals required minus withdrawn. The matched quantity comes from the
selector-matching pass; fallback may widen location and batch matches while
retaining a specified valuation type. For each row, open quantity equals
matched plus fallback plus uncovered, and allocated equals matched plus
fallback. Uncovered row quantities sum to `uncovered_open_resv_quantity`. UOM
rows echo the reservation context and include base and requested units for
required, withdrawn, open, allocated, matched, fallback, and uncovered
quantities.
Each uncovered row also reports `allocation_coverage_pct`,
`allocation_shortage_pct`, `matched_share_pct`, and `fallback_share_pct` as
percentages of that row's open quantity. They use two decimal places. UOM
detail rows echo the percentages unchanged.

Uncovered-reservation details can be paged independently. `maximum_uncovered_rows = 0`
returns the complete list; values 1–500 cap each page. Set
`filter_uncovered_cursor = abap_true` with the previous row's reservation
number and item in `uncovered_cursor_number` and `uncovered_cursor_item`. The
exclusive cursor follows reservation/item order and requires both key fields;
without an active cursor, both cursor fields must be initial.
`total_uncovered_detail_count` and `uncovered_open_resv_row_count` report the
complete residual count, while `returned_uncovered_row_count` reports the page
size. `is_uncovered_truncated` indicates another page; when true,
`next_uncovered_cursor_number` and `next_uncovered_cursor_item` identify the
last returned row. In paged requests, `uncovered_open_resv_keys` and
`uncovered_open_reservations` contain the same page. UOM results echo page
metadata and convert the returned details. Each continuation recalculates
from current reservation data; pages do not retain a shared snapshot. Set `filter_uncovered_due_horizon = abap_true` with `uncovered_due_horizon` set to `O`, `T`, `1`, `2`, `3`, `4`, or `U` to select overdue, due-today, 1–7, 8–30, 31–90, over-90, or undated detail rows. Each returned uncovered detail row also exposes `due_horizon_band` using the same codes relative to `as_of_date`; UOM detail rows echo the code unchanged. Each uncovered detail also exposes `allocation_outcome`: `P` when allocated quantity is positive and `U` when it is zero; UOM detail rows echo the code unchanged. Overdue rows also report `overdue_age_days` as the exact positive calendar days late and `overdue_age_band` as `1` for 1–7 days late, `2` for 8–30, `3` for 31–90, or `4` for more than 90 days late. Both fields are initial for due-today, future, and undated rows; UOM detail rows echo them unchanged. `filtered_uncov_overdue_ages` returns four stable rows for 1-7, 8-30, 31-90, and over-90 days late, even when a band is empty. Each row summarizes every selector-matching overdue detail before cursor and page selection, with partial/unallocated counts, base and source quantities, and weighted coverage, shortage, matched, and fallback percentages; percentages stay zero for empty demand. Partial and unallocated open quantities partition each band's open demand, and their shortage quantities partition uncovered demand. Each band also reports partial-only coverage, shortage, matched, and fallback percentages using partial open quantity as the denominator; these remain zero without partial demand. UOM rows convert all four outcome quantities and echo the percentages. Each row also reports `first_required_date` and `last_required_date` across its matching dated reservations; both remain initial for empty bands and UOM results echo both dates. UOM results preserve band order, counts, and percentages while converting quantities. Set `filter_uncovered_age_band = abap_true` with `uncovered_age_band` set to `1`, `2`, `3`, or `4` to select overdue details 1-7, 8-30, 31-90, or over 90 days late. It composes with the other detail selectors before filtered summaries, counts, and paging; the disabled value must be initial, and UOM results echo both fields. Set `filter_overdue_age_days_from` and/or `filter_overdue_age_days_to` with the matching `overdue_age_days_from` and `overdue_age_days_to` values to select an inclusive overdue-age day range. Either bound may be omitted; active bounds must be positive and ascending, and inactive values must be initial. A day range excludes due-today, future, and undated rows, composes with the age-band and other detail selectors before totals and paging, and UOM results echo both flags and bounds. The selector filters details before cursor and page selection; `total_uncovered_detail_count` counts all horizon-matching rows independent of the cursor, while `uncovered_open_resv_row_count` and the reservation-level quantity summaries stay full-scope. Invalid active values and nonblank inactive selectors are rejected, and UOM results echo both fields. Set `omit_uncovered_detail_rows = abap_true` to return no uncovered detail rows or parallel keys while retaining the filtered detail total and full-scope shortage summaries. The flag requires `maximum_uncovered_rows = 0` and no active uncovered cursor; UOM results echo it, and non-boolean values are rejected. When omitted, the service calculates filtered totals and fixed horizon and overdue-age summaries directly from repository rows without building uncovered detail or key tables. Set `filter_uncovered_sequence = abap_true` with a positive `uncovered_sequence` to select one reservation's shortage row in shared-stock allocation order. It composes with the due-horizon filter and cursor before detail totals and paging. The disabled selector must be initial, and UOM results echo both fields. Optional inclusive `uncovered_required_date_from` and `uncovered_required_date_to` bounds select a caller-chosen required-date window. Either bound may be supplied; two bounds must be valid and ascending. When a bound is set, undated rows are omitted. The bounds compose with sequence, due-horizon, and cursor scopes before counts and paging, and UOM results echo both dates. Set `filter_uncovered_reservation = abap_true` with both `uncovered_reservation_number` and `uncovered_reservation_item` to select one shortage row. Both key fields are required when active and must be initial otherwise. This selector composes with sequence, due-horizon, date bounds, and cursor scopes before counts and paging; an active cursor must match the selected key, and UOM results echo all three selector fields. Set `filter_uncovered_outcome = abap_true` with `uncovered_outcome` set to `P` for rows with positive local allocated quantity (partially allocated), or `U` for rows with zero local allocated quantity (unallocated). The selector composes with reservation, sequence, due-horizon, date-window, and cursor scopes before filtered totals and paging; full-scope shortage summaries stay unchanged. Only `P` and `U` are valid active values, the disabled selector must be initial, and UOM results echo both fields. Set `filter_uncovered_pct_from = abap_true` with `uncovered_pct_from` and/or `filter_uncovered_pct_to = abap_true` with `uncovered_pct_to` to filter each row by `allocation_shortage_pct`. Bounds are inclusive and accept 0–100; if both are active they must ascend, and inactive values must be initial. The selector composes with the other detail filters before filtered totals and page selection; full-scope shortage summaries stay unchanged. UOM results echo both flags and values. Set `filter_uncovered_qty_from = abap_true` with `uncovered_qty_from` and/or `filter_uncovered_qty_to = abap_true` with `uncovered_qty_to` to filter each detail row by inclusive `uncovered_quantity` in the material base unit. Bounds must be nonnegative; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Quantity bounds compose with the other detail filters before filtered totals and page selection; full-scope shortage summaries stay unchanged. UOM results echo both flags and base-unit bounds unchanged. The result also reports `filtered_uncovered_qty`, the sum of `uncovered_quantity` for every row matching the detail selectors before cursor and page selection. The total stays the same across cursor continuations; UOM results report `base_filtered_uncovered_qty` and `src_filtered_uncovered_qty`. Set an open-demand detail range with `filter_uncovered_open_from = abap_true` and `uncovered_open_qty_from` and/or `filter_uncovered_open_to = abap_true` and `uncovered_open_qty_to` to filter each uncovered row by inclusive `open_quantity` in the material base unit. Bounds must be nonnegative; either is optional, both must be ascending, and disabled values must be initial. The range composes with the other detail selectors before filtered counts and sums, cursor, and page selection; UOM results echo both flags and base-unit bounds. The filtered uncovered-detail totals also include `filtered_open_demand_qty`, the sum of `open_quantity` for every row matching the detail selectors before cursor and page selection. This total stays the same across cursor continuations; `filtered_uncovered_qty` continues to report the shortage amount. UOM results report `base_filtered_open_demand_qty` and `src_filtered_open_demand_qty`. Filtered details also report `filtered_uncovered_alloc_qty`, the sum of `allocated_quantity` for every matching row before cursor and page selection. Filtered open demand reconciles as allocated plus uncovered quantity. UOM results report `base_filtered_uncov_alloc_qty` and `src_filtered_uncov_alloc_qty`. Filtered allocation is also split into `filtered_uncov_matched_qty` and `filtered_uncov_fallback_qty`, summing the matched and fallback quantities for the same rows. These totals reconcile with `filtered_uncovered_alloc_qty`; together with shortage they reconcile to open demand. UOM results report `base_uncov_matched_qty` / `src_uncov_matched_qty` and `base_uncov_fallback_qty` / `src_uncov_fallback_qty`. Results also include `filtered_uncov_partial_count` and `filtered_uncov_unalloc_count` across that same selector-matching row set before cursor and page selection. The two counts partition `total_uncovered_detail_count`; UOM results echo them unchanged. The weighted `filtered_uncov_coverage_pct` and `filtered_uncov_shortage_pct` use the same matched rows: allocated and uncovered totals divided by open-demand total. They sum to 100 when matching open demand exists and remain zero for an empty result; UOM results echo both percentages unchanged. Weighted `filtered_uncov_matched_pct` and `filtered_uncov_fallback_pct` also report matched/open and fallback/open for the same filtered rows; together they equal coverage. UOM results echo all four percentages unchanged. `filtered_uncov_due_horizons` returns the same selector-matching residual rows as a fixed seven-row due-horizon summary (`O`, `T`, `1`, `2`, `3`, `4`, `U`), including empty bands. Each band’s `partial_row_count` and `unalloc_row_count` partition its `row_count`. Open, allocated, matched, fallback, and uncovered quantities reconcile to the filtered totals before cursor and page selection; UOM results preserve band order and all counts and provide base and source quantities. Each band also reports weighted `coverage_pct`, `shortage_pct`, `matched_pct`, and `fallback_pct` from its own totals. Coverage and shortage, and matched and fallback, reconcile within 0.01 percentage points from independent rounding; percentages are zero for empty bands. UOM results echo these percentages unchanged. Partial-only `partial_coverage_pct`, `partial_shortage_pct`, `partial_matched_pct`, and `partial_fallback_pct` use `partial_open_qty` as their denominator: allocated, partial shortage, matched, and fallback quantities respectively. They stay zero when a band has no partial rows. Coverage and shortage, and matched and fallback, reconcile within 0.01 percentage points from independent rounding. UOM results echo these percentages unchanged.  The filtered detail result also exposes `filtered_partial_open_qty`, `filtered_unalloc_open_qty`, `filtered_partial_short_qty`, and `filtered_unalloc_short_qty`. The open quantities partition `filtered_open_demand_qty`; the shortage quantities partition `filtered_uncovered_qty`. UOM results provide base and source quantities for all four totals. Top-level `partial_coverage_pct`, `partial_shortage_pct`, `partial_matched_pct`, and `partial_fallback_pct` use the filtered partial open quantity as their denominator, matching the seven-band partial-only percentages. They remain zero when no partial rows match, reconcile within 0.01 percentage points from independent rounding, and UOM results echo unchanged. The outcome split also exposes `partial_open_qty`, `unalloc_open_qty`, `partial_short_qty`, and `unalloc_short_qty`; the first pair sums to `open_demand_quantity` and the second to `uncovered_quantity`. UOM rows return base and source quantities for all four. `first_required_date` and `last_required_date` show the actual date span among dated rows in each band. They remain initial for empty or undated bands; UOM results echo both dates unchanged.
`allocation_sequence` is one-based across positive eligible open reservations
and records calculator processing order: more specific selectors go first,
selector values break ties, and identical selector tuples retain caller input
order. Stock rows traverse by location, batch, valuation type, and expiry date;
equal stock keys retain input order. Trace and uncovered rows carry the
sequence, and UOM rows echo it. Result collections remain sorted by
reservation/item; sorting by `allocation_sequence` restores shared-stock
consumption order.
`uncovered_open_resv_row_count` reports all positive residual rows, including
when the detail list is paged; expiry/UOM results preserve the count.
`allocation_details` lists each positive reservation deduction with the
reservation's requested location, batch, and valuation type beside the actual
stock location, batch, valuation type, and expiry date. Each row also carries
`days_until_required`, calculated as `required_date - as_of_date`; negative is
overdue, zero is due on the as-of date, and positive is future-dated. An
initial required date leaves zero, and UOM rows echo the day count. Pass `M`
the reservation selectors; pass `F` widens location/batch matching while
retaining any specified valuation type. Entries sort by reservation/item and
preserve pass and stock traversal order within each key. For keys listed in the
uncovered summary, entry quantities sum to `allocated_quantity`; fully covered
reservations still appear in the trace. UOM entries include base and requested
amounts.

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
and no active allocation cursor; UOM results echo the flag. With omission
enabled, the service scans the local bulk row directly and sorts detail rows in
place for stable risk summaries without copying a response detail table.
Allocation-trace pages can be scoped to one reservation with
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
the flag. When omitted, the service calculates scoped totals from the local
bulk result without copying or sorting a response summary table. UOM pages
include base and requested-unit amounts for every quantity; each continuation
recalculates against current reservation and stock data.

`first_uncovered_required_date` and its reservation/item fields identify the
earliest noninitial required date among those rows. Undated rows are skipped;
ties use reservation/item order. UOM results echo this summary unchanged.
`days_until_first_uncovered_req` is the earliest known requirement date minus
`as_of_date`, so negative means overdue and zero means due on the as-of date.
The UOM result echoes this integer.
Every expiry detail row also reports `days_until_required` relative to
`as_of_date`; negative is overdue, and zero is due that day when the required
date is present. An initial required date leaves the integer at zero, so use
the date field to identify undated rows. UOM rows echo the day count.
Uncovered residuals are grouped as overdue, due today, future-dated, or
undated. The base result returns each bucket's quantity and row count; the
four quantities reconcile to `uncovered_open_resv_quantity` and the counts to
`uncovered_open_resv_row_count`. UOM results return base/requested amounts for
each bucket and echo the counts. Initial required dates are undated, not due
today. All eligible open demand is also grouped into overdue, due-today, future-dated, and undated buckets, regardless of local allocation outcome. The four quantities reconcile to `open_reservation_quantity`, and the counts reconcile to `open_reservation_row_count`; demand already allocated remains included. UOM expiry results expose `base_overdue_open_resv_qty` / `src_overdue_open_resv_qty`, `base_due_today_open_resv_qty` / `src_due_today_open_resv_qty`, `base_future_open_resv_qty` / `src_future_open_resv_qty`, and `base_undated_open_resv_qty` / `src_undated_open_resv_qty`; counts are echoed unchanged.
`resv_alloc_open_demand_bands` cross-tabulates the same demand by allocation outcome (`F` fully allocated, `P` partial, `U` unallocated) and required-date bucket (`O` overdue, `T` due today, `F` future, `U` undated). It always returns all 12 combinations in outcome/date order, including zero rows; quantities and counts reconcile to `open_reservation_quantity` and `open_reservation_row_count`. UOM bands preserve the order and expose `base_open_quantity` and `source_open_quantity` with the row counts unchanged. `open_resv_due_horizon_bands` returns a fixed seven-row breakdown: `O` overdue, `T` due today, `1` due in 1–7 days, `2` due in 8–30 days, `3` due in 31–90 days, `4` due after 90 days, and `U` undated. These calendar-day ranges are non-overlapping and use `as_of_date`; counts and quantities sum to the eligible open reservation totals. UOM bands preserve order and counts and provide `base_open_quantity` and `source_open_quantity`. reservation summary pages can filter by the same codes with `filter_resv_alloc_due_horizon = abap_true` and `resv_alloc_due_horizon`; the scope composes with outcome, coarse date bucket, exact reservation, date range, and cursor filters before totals and pagination. unknown active codes and nonblank inactive selectors are rejected, and uom results echo the selector. set `filter_resv_alloc_sequence = abap_true` with a positive `resv_alloc_sequence` to select one summary by its shared-stock allocation processing position. This selector composes with the other summary filters before totals and pagination; a disabled selector must be initial, and UOM results echo both fields. Set `filter_resv_alloc_seq_from = abap_true` with `resv_alloc_seq_from` and/or `filter_resv_alloc_seq_to = abap_true` with `resv_alloc_seq_to` to filter summary rows by an inclusive `allocation_sequence` range. Bounds must be positive integers; either bound is optional, and when both are enabled the lower bound must not exceed the upper bound. Disabled values must be initial. Sequence bounds apply before summary counts and paging, compose with the exact-sequence selector, and leave full-scope allocation-detail counts unchanged. UOM results echo both flags and values. The result also reports `filtered_resv_alloc_qty`, `filtered_resv_matched_qty`, `filtered_resv_fallback_qty`, `filtered_resv_open_qty`, and `filtered_resv_uncovered_qty` for every summary row matching the selectors before cursor and page selection. These totals reconcile as allocated = matched + fallback and open = allocated + uncovered, and remain unchanged across cursor continuations. UOM results report base and requested-unit totals in `base_filtered_resv_alloc_qty` / `src_filtered_resv_alloc_qty`, `base_filtered_resv_matched_qty` / `src_filtered_resv_matched_qty`, `base_filtered_fallback_qty` / `src_filtered_fallback_qty`, `base_filtered_resv_open_qty` / `src_filtered_resv_open_qty`, and `base_filtered_resv_short_qty` / `src_filtered_resv_short_qty`. Filtered summary pages also report weighted `filtered_resv_coverage_pct` and `filtered_resv_shortage_pct`, based on allocated/open and uncovered/open totals for matching rows before cursor and page selection. The percentages sum to 100 when filtered open demand exists and remain zero when it does not; UOM results echo them unchanged. The same summaries report weighted `filtered_resv_matched_pct` and `filtered_resv_fallback_pct`, calculated from matched/open and fallback/open totals; together they equal coverage. UOM results echo both percentages unchanged. The base result also identifies `next_open_resv_required_date`, the earliest eligible dated open reservation with a required date on or after `as_of_date`; overdue and undated rows are skipped. `next_open_resv_number` and `next_open_resv_item` identify it, and `days_until_next_open_resv_req` reports the calendar-day distance, including zero when due today. Equal-date rows break ties by reservation number and item. UOM results echo all four fields unchanged.
The repository-backed `ZIF_BATCH_EXPIRY_READER` exposes both base-unit and
unit-aware bulk expiry snapshots and forwards reservation exclusions to the
stock service. The direct batch-status bulk result also includes a UTC
`snapshot_timestamp`, captured after its grouped repository read; all result
rows from that read share the timestamp, and the UOM batch-status result echoes
it unchanged.
Each base expiry result includes a UTC `snapshot_timestamp` captured after its
grouped repository read completes. Requests that share the same effective
reservation-exclusion set share that read timestamp. UOM results echo the same
timestamp unchanged. It marks read completion and does not make the stock read
transactionally consistent. Each result also identifies the earliest
positive-stock upcoming row through its storage
location, batch, valuation type, expiration date, and days from the as-of date.
The identity follows the deterministic row sort order; date and days fields are
`next_upcoming_expiration_date` and `days_to_next_expiration`. The row's four
stock-category quantities accompany the identity in base units; UOM results
carry both base and requested-unit quantities. Identity and date fields remain
initial, and quantities remain zero, when no in-window upcoming row has
positive stock.
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
`next_expiry_batch_count`; UOM results echo them unchanged. The first expired row is also identified by location, batch,
valuation, expiration date, and `days_since_first_expired_date`; its four stock
categories are included, with base and requested-unit quantities in the UOM
result. Its fields are initial or zero when no expired row has positive stock.
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
The timestamp is captured
after its grouped stock read completes; requests sharing a read share
the timestamp. This marks read completion but does not make the stock read
transactionally consistent. The unit-aware entry point converts caller
quantities to base units before applying those checks. All entry points support
SAP test-run simulation and optional configured movement reasons, and record
the snapshot freshness limitation in the README and ANOMALIES.md. Goods-movement postings and cancellations require both the returned material
document number and fiscal year; only successful create simulations may omit that key.
Live `BAPI_PR_CREATE` results also require the returned requisition number; a
successful test-run may omit its simulated number. Live sales-order creates
likewise require their returned sales document; successful simulations may omit
that generated number. Live `BAPI_PO_CREATE1` results from procurement and
stock-transfer adapters also require the returned purchase-order number;
successful test runs may omit that simulated key. Live reservation creates
also require returned reservation numbers; successful test runs may omit
those generated keys. Confirmation creates require both the returned
confirmation number and counter; live creates commit only after key validation,
and atomic test runs roll back their provisional keys. The
rechecked
entry point accepts a second exposure snapshot, verifies the selected batch
state and effective reservation exclusions are unchanged, and posts against
that snapshot. When the original report has a `snapshot_timestamp`, the
rechecked report must carry a strictly later timestamp; untimestamped legacy
reports retain the earlier comparison behavior. Its unit-aware form
converts selected quantities before rechecking and posting.
Expired quality-inspection stock also supports movement 553, limited by the
reported QI quantity on each selected batch row. Its unit-aware form converts
each selected quantity to the material base unit before applying the QI cap.
Its rechecked form compares a second exposure snapshot and posts against that
snapshot, including its effective reservation exclusions; SAP remains
authoritative after the comparison. The unit-aware
rechecked form converts selected quantities before the same comparison.
Expired blocked stock also supports movement 555, limited by the reported
blocked quantity on each selected batch row. Its unit-aware form converts each
selected quantity to the material base unit before applying the blocked cap.
Its rechecked form compares a second exposure snapshot and posts against that
snapshot, including its effective reservation exclusions; its unit-aware form
converts quantities before the comparison.
`SCRAP_EXPIRED_SCRAP` and `SCRAP_EXPIRED_SCRAP_UOM` accept the stock category
and route to the corresponding existing validation and posting path. UOM
selections are converted before that category-specific balance check, and an
unknown category is rejected before posting.
`SCRAP_EXPIRED_CAT_RECHECKED` and `SCRAP_EXP_CAT_RECHECK_UOM` extend category
selection to the rechecked posting paths; the unit-aware form converts each
selection before the snapshot comparison and posts against the rechecked
exposure.
`PREVIEW_EXPIRED_SCRAP` accepts a stock category and builds base-unit
selections from expired batches in FEFO order. It rejects exposure rows
without a storage location or batch before allocation. It reports shortfalls and
supports all-or-nothing requests. The category-specific blocked, QI, and
unrestricted methods are convenience wrappers. Each selected split also
appears in `selection_details` with its expiry date, source marker, and
`days_expired_at_posting` (posting date minus expiry date), in the same order as
`selections`; all-or-nothing shortfalls clear both lists.
Each detail row includes `location_priority_rank`: zero without a location
priority list, the caller's rank for listed locations, and one after the list
for locations not listed. This explains location tie ordering in FEFO results.
The material-base-unit `category_balance` is the source quantity used to cap
that split: reservation-net `available_quantity` for unrestricted stock,
`quality_inspection_quantity` for QI stock, or `blocked_quantity` for blocked
stock. It may exceed the selected `quantity` when the preview allocates only
part of the batch balance.
`snapshot_timestamp` echoes the source exposure timestamp and remains initial
for legacy exposures without one.
The result echoes the exposure request ID, material, plant, as-of date, through
date, and posting date; UOM and FEFO results preserve this context in their
nested preview.
`excluded_reservations` echoes the source exposure's reservation exclusions
unchanged, including an empty list; UOM and FEFO results preserve them in the
nested preview.
`PREVIEW_EXPIRED_SCRAP_UOM`
converts requested quantities, echoes caller and base units, and returns
posting-ready base-unit splits and their expiry provenance for all three
categories. The blocked-stock UOM method remains a compatibility wrapper.
`SCRAP_EXPIRED_FEFO` and `SCRAP_EXPIRED_FEFO_UOM` combine category allocation
and posting. They default to all-or-nothing, return the preview and posting
result together, optionally recheck a supplied second exposure, and retain SAP
test-run simulation. A supplied second exposure is validated before allocation;
its `is_rechecked` flag and `rechecked_snapshot_timestamp` are returned even
when a full-quantity shortfall prevents posting. The flag stays false and the
timestamp stays initial when no recheck is supplied. Bulk and atomic nested
FEFO rows, including bulk UOM requests, preserve this metadata on shortfall and
skipped requests. Skipped UOM rows also retain the converted base requested
quantity and shortfall preview.
Partial posting requires explicit opt-in. Direct FEFO results echo
`require_full_quantity`; bulk and atomic results echo the policy at the
group level and on each request's nested FEFO result, including empty,
shortfall, and skipped rows.
`SCRAP_EXPIRED_FEFO_BULK` and `SCRAP_EXPIRED_FEFO_BULK_UOM` prevalidate all
request IDs, units, and any supplied second exposure before the first post.
The complete recheck must match request context, have unique batch keys, and
contain valid expiry status/date values even if the request has no selection.
The method then returns per-request results and continues after posting failures. Successful
requests commit independently outside test-run mode, and the bulk result
reports partial success. Optional positive request-priority ranks, keyed by
exposure request ID, post lower ranks first, followed by unranked requests;
ties keep caller order. Priority rows are validated before posting. Result rows
remain in caller order and echo each rank and ranked status; without priorities,
posting follows caller order.
`iv_stop_on_failure` defaults to `abap_false`. When enabled, the first request
shortfall, returned posting error, or captured request-level exception stops
later posts; skipped requests are marked on their rows and counted separately
from failed requests. With priorities, stopping follows ranked posting order
while result rows remain in caller order. Each row exposes a one-based
`allocation_sequence` in ranked posting order; skipped rows retain their
scheduled sequence. Earlier successful independent commits remain committed.
The bulk summary sets `stopped_on_failure` whenever that option ends the
execution loop, including when the failed request was last and nothing was
skipped.
A `zcx_invalid_goods_movement` raised during one request's posting operation is
stored as an error message on that row so the bulk result retains earlier
successful commits and the request summary. The row marks `is_exception` and
leaves `is_attempted` false because no goods-movement result was returned.
`exception_count` reports these rows and is included in `failed_count`.
`SCRAP_EXP_FEFO_BULK_ATOMIC` and `SCRAP_EXP_FEFO_BULK_ATOMIC_UOM` prevalidate
the complete request set, units, and any supplied second exposure before any
movement call. Each recheck must match its request context, reservation keys,
and timestamp rules and contain unique, valid dated batch rows, even when a
full-quantity shortfall leaves no selection. They defer each request's commit,
then commit the group once. A
full-quantity shortfall prevents all movement calls. A movement or group-commit
failure rolls back provisional documents; full allocation remains the default,
with partial allocation available by opt-in. Test-run mode simulates each
movement without the group commit. Before allocation, each supplied recheck
must match request identity, date window, and reservation exclusions; a
timestamped original requires a later timestamp. Every recheck row must have
a unique batch key and valid expiry status/date, even when a full-quantity
shortfall leaves that request with no selection. Selected batches are then
compared for status, expiry, and category balances across snapshots; SAP still
validates live stock at posting time. The atomic preflight also groups selected
quantities by material, plant, location, batch, valuation type, and stock
category so overlapping exposures cannot allocate more than the smallest
reported balance. Atomic results return sorted `shared_capacities` rows for
pooled material/plant/location/batch/valuation/category keys. Each row includes
the base unit, minimum balance across supplied initial and recheck exposures,
planned `allocated_quantity`, remaining quantity, contributing exposure-row
and distinct-request counts, the `rechecked_exposure_count`, positive-balance tie
counts, minimum/maximum request IDs, capacity spread, snapshot timestamp
bounds, and allocation row
count. These are planned selections from supplied
snapshots, not committed stock changes; the summary is retained on shortfall or
later rollback. Optional positive `it_request_priorities` ranks, keyed by
exposure request ID, allocate and post lower ranks first, followed by unranked
requests and caller-order ties. Shared capacity is consumed in this order when
partial allocation is enabled. Each result row exposes a one-based
`allocation_sequence` in shared-capacity allocation and posting order.
Invalid, duplicate, and unknown priority rows are rejected before stock
reads in the stock-backed method; result rows remain
in caller order and echo rank metadata. A request-level
`zcx_invalid_goods_movement` during deferred execution is captured on that row;
pending movements are rolled back outside
test-run mode and provisional document numbers are cleared. The row sets
`is_exception` and leaves `is_attempted` false because no movement result was
returned. `exception_count` reports that exception and is included in
`failed_count` for the failed group.
`SCRAP_FEFO_ATOMIC_FROM_STOCK` accepts expiry windows and requested quantities,
loads the exposures through the injected batch-expiry reader, and forwards
call-wide and request-specific reservation exclusions to each bulk read. Each
request's keys combine with the call-wide exclusions only for that request;
requests with matching effective sets share a stock read, and each exposure
result echoes the effective keys. Both snapshots are checked against each
request's effective union, and duplicate location/batch/valuation rows are
rejected before allocation or posting. Rows without a storage location or
batch are rejected in both snapshots before allocation or posting. The first
snapshot is checked before requesting the recheck, so an invalid original
stops after one read. It validates
material-unit mappings and requested units before stock reads. Request fields, complete and unique call-wide and per-request reservation
exclusions, and priority rows are prevalidated before any UOM conversion or
repository read.
`iv_recheck_exposure` defaults to
`abap_true`, so the method reads and validates expiry snapshots before atomic
posting; both snapshots and the atomic posting result are returned. If the
original is timestamped, the recheck must carry a strictly later timestamp. The factory
wires the production reader, while direct construction can inject a test or
system-specific reader. Optional `it_request_priorities` validates before
exposure reads, allocates partial shared capacity by rank, and leaves result
rows in caller order.
`SCRAP_FEFO_BULK_FROM_STOCK` provides the independently committed alternative.
It validates requests, base-unit mappings, requested units, and priorities
before stock reads. Request fields, complete and unique call-wide and per-request reservation
exclusions, and priority rows are prevalidated before any UOM conversion or
repository read. It loads exposure in bulk and
defaults to a second snapshot
that checks selected batches before the first post. If the original snapshot
is timestamped, the recheck must be strictly later. Positive request ranks
control posting and shared-capacity allocation order, and result rows preserve
caller order. Stop-on-failure follows the ranked posting order while results
remain in caller order. Matching material/plant/location/batch/valuation/category
balances are pooled across requests using the smallest reported balance across
both snapshots. Capacity is consumed only after a successful movement result,
so a failed request releases it to later requests. Call-wide and request-specific
reservation exclusions are forwarded to both reads; requests with matching
effective exclusion sets share each stock read. Both snapshots are checked
against each request's effective union. Rows without a storage location or
batch and duplicate location/batch/valuation rows are rejected before posting.
The first snapshot is validated before requesting the recheck, so an invalid
original stops after one read.
Successful earlier requests remain committed
if a later post fails.
The stock-backed bulk method also supports `iv_stop_on_failure`; it stops after
the first request failure, including shortfalls, returned posting errors, and
captured request-level exceptions. Later rows are marked skipped, and
`skipped_count` distinguishes them from failures. Its bulk summary includes
`exception_count` within `failed_count` for request-level posting exceptions.

`PREVIEW_EXP_SCRAP_FROM_STOCK` bulk-loads expiry exposure and returns a
posting-ready FEFO preview for each uniquely keyed request without calling a
goods-movement API. It validates request identity, dates, category, base-unit
mapping, and requested UOM. Request fields, complete and unique call-wide and per-request reservation
exclusions, and priority rows are prevalidated before any UOM conversion or
repository read. Call-wide and per-request
reservation exclusions are supported, and matching effective sets share a
stock read. Each returned exposure is validated against its request's effective
exclusions before allocation. Its request identity and dates must be complete
and valid. Every dated batch row must have a valid expiry date and a status
consistent with the exposure's as-of date; upcoming rows must also expire on
or before `through_date`, while later dates belong in the after-window summary.
Negative available-unrestricted balances and available balances above
nonnegative unrestricted stock are rejected. A row without a storage location
or batch is rejected before
capacity is pooled. Duplicate location/batch/valuation rows in one exposure
are also rejected before capacity is pooled. Full allocation is required by
default. Partial previews require
explicit opt-in; returned stock and selections remain snapshots and do not
reserve inventory. It pools matching batch capacity across requests by
material, plant, location, batch, valuation type, and stock category, using the
smallest reported balance and consuming it in caller order.
`shared_capacities` returns each pooled key with its material base unit, the
smallest reported balance as `available_quantity`, total selections across
requests as `allocated_quantity`, and their difference as `remaining_quantity`.
`reported_exposure_count` counts contributing exposure rows, and
`contributing_request_count` counts distinct requests represented by those
rows; initial and recheck snapshots from one request count once.
`rechecked_exposure_count` counts rows from supplied second snapshots; it
is zero for stock-backed previews, which read one snapshot per request.
`positive_exposure_count`
counts rows whose selected stock category has a
positive balance. `earliest_snapshot_timestamp` and `latest_snapshot_timestamp`
bound the UTC read times of contributing rows with timestamps; both remain
initial when none have one. `untimestamped_exposure_count` counts rows without a read
timestamp. `limiting_request_id` identifies a request whose balance set
the minimum; ties
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
The result includes request, fully allocated, and shortfall counts plus a
group-level allocation flag; empty input is fully allocated with zero requests.
`require_full_quantity` echoes the chosen all-or-nothing policy, including for
empty input.
Optional positive request-priority ranks allocate lower ranks first; unranked
requests follow ranked ones, ties keep caller order, and returned rows stay in
caller order. Each result row echoes its rank, ranked status, one-based
`allocation_sequence` in processing order, its request's UTC
`snapshot_timestamp`, and effective `excluded_reservations` from the source
exposure. Each row also echoes its request's `material`, `plant`, `as_of_date`,
`through_date`, `stock_category`, `cost_center`, `movement_reason`, and
`storage_location_priority`, including when no stock is selected. Nested
preview `selection_details` retain each selected batch's expiry date and
source marker and days past expiry on the requested posting date.
Unranked rows return rank zero and false. Invalid, duplicate, or unknown
priority rows are rejected before the stock read.

## Batch expiry overdue-age buckets

The bulk batch-expiry exposure result also partitions positive-stock expired
batch/location/valuation rows into `expired_1_7_row_count`,
`expired_8_30_row_count`, `expired_31_90_row_count`, and
`expired_ov90_row_count` age buckets. Their matching category totals use the
`expired_1_7_*`, `expired_8_30_*`, `expired_31_90_*`, and `expired_ov90_*`
prefixes. Age is measured in
calendar days before `as_of_date`; the expiration date itself remains upcoming
when it equals `as_of_date`. Each bucket reports its row count and unrestricted,
reservation-net available, quality-inspection, and blocked totals. The four
buckets partition the expired row count and category totals. UOM results echo
counts and expose each category total through matching `base_*` and `src_*`
fields. Coverage checks all four boundaries and converted quantities.
The report also exposes cumulative expired horizons through 7, 30, and 90 days
with `expired_7d_row_count`, `expired_30d_row_count`, and
`expired_90d_row_count`, respectively, each with all four category totals. The
horizons are inclusive, the shorter totals are subsets of the longer totals,
and their quantities equal the corresponding disjoint-band sums. UOM results
preserve the counts and convert all category totals. The base result also
includes `expiry_src_age_bands`, a fixed 12-row matrix ordered by source
(`P`, `G`, `O`) and expired age band (`1` = 1–7 days, `2` = 8–30,
`3` = 31–90, `4` = over 90). Each row has a positive-stock row count, first
and last expiration dates, the four stock-category totals, and four
`*_qty_share_pct` fields. Each row's `row_share_pct` is its percentage of all
matching expired rows. `source_row_share_pct` divides its count by all expired
rows for the same source, and `age_band_row_share_pct` divides it by all rows in
the same age band across sources. Each quantity share is its percentage of the
matching full expired category total. The four `source_*_share_pct` fields use
the full expired category total for that source, so their shares across age
bands sum to 100 for each nonzero source/category, aside from independent
rounding. The four `band_*_share_pct` fields divide each category quantity by
that age band's full category total across sources; their source shares sum to
100 within each nonzero category, aside from rounding. Percentages round to two decimals, are
zero when their denominator is zero, and may sum slightly away from 100 due to
independent rounding. Dates show the actual span within each source-age
combination and remain initial when empty. The rows partition each disjoint age
bucket by expiry-date source; zero-count combinations remain present. UOM results
retain the same order, counts, percentages, and date spans, with base and
requested-unit quantities for every category.

## Batch expiry source-specific upcoming lead-time bands

The exposure result also includes `upcoming_src_bands`, a fixed 12-row matrix
ordered by expiry-date source (`P`, `G`, `O`) and lead-time band (`1` = 0–7
days, `2` = 8–30, `3` = 31–90, `4` = over 90). It covers positive-stock
upcoming rows within the requested window; expiry on `as_of_date` belongs to
the 0–7 day band. Each row reports its count, `row_share_pct`, unrestricted, reservation-net
available, quality-inspection, and blocked totals, plus four `*_qty_share_pct`
fields. `source_row_share_pct` uses all upcoming rows for the same source, and
`through_band_row_share_pct` uses all upcoming rows in the same lead-time band
across sources. The four `source_*_share_pct` fields use each source's full
upcoming category total, so shares across bands sum to 100 per nonzero
source/category, aside from independent rounding. The four `band_*_share_pct`
fields divide each category quantity by its full lead-time-band total across
sources, so nonzero band/category shares sum to 100 aside from rounding. The row
share uses the full matching upcoming row count; quantity shares use the corresponding full
upcoming category total. Percentages round to two
decimals, are zero when their denominator is zero, and may sum slightly away
from 100 due to independent rounding. The matrix
partitions the disjoint upcoming bands and reconciles to upcoming counts and
category totals. All source/band combinations remain present when empty. Every
row reports its first and last expiration dates across matching stock; both
remain initial when empty. UOM results preserve row order, counts, percentages,
and date spans, with base and requested-unit category quantities. The
`after_window_src_bands` result provides
the same 12-row source matrix for positive-stock rows after the inclusive
`through_date`, using bands 1–7, 8–30, 31–90, and over 90 days beyond that date.
It reports `row_share_pct` within the full matching after-window row count
and four `*_qty_share_pct` fields using the corresponding full after-window
category totals. `source_row_share_pct` uses all after-window rows for the same
source, and `through_band_row_share_pct` uses all after-window rows in the same
band across sources. The four `source_*_share_pct` fields use each source's full
after-window category total, so shares across bands sum to 100 per nonzero
source/category, aside from independent rounding. The four `band_*_share_pct`
fields divide each category quantity by its full after-window band total across
sources, so nonzero band/category shares sum to 100 aside from rounding.
Percentages round to two decimals, are zero when their denominator is zero, and
may sum slightly away from 100 due to independent rounding. The matrix partitions the after-window count and category totals,
retains zero combinations, and carries dates, counts, percentages, and
base/requested units through the UOM result.

Set `filter_expiry_upcoming_band = abap_true` with `expiry_upcoming_band` `1` for 0–7 days from `as_of_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes the as-of date and only dates through the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. The selector uses the four `upcoming_src_bands` lead-time boundaries, including day 0 in band 1. Set `filter_exp_after_window_band = abap_true` with `expiry_after_window_band` `1` for 1–7 days after `through_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes only dates after the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields.

Dated `batches` details can be returned as keyset pages. `maximum_batch_rows = 0`
keeps the complete legacy list; values 1–500 cap each page. With
`filter_batch_cursor = abap_true`, a request supplies the previous row's status,
expiration date, batch, storage location, and valuation type. The cursor is
exclusive and follows the row order (status, date, batch, location, valuation).
Status values are `A`, `E`, and `U`; blank batch, location, or valuation keys
are valid cursor components. `total_dated_batch_row_count` reports all matching
dated rows, while `returned_batch_row_count` reports rows in the current page.
`is_truncated` indicates another page exists. When true, `next_cursor_*`
identifies the last returned row; otherwise the continuation fields are initial.
Cursor use requires a
positive page limit, and unused cursor fields must be initial. Summary counts,
quantities, and earliest-row cohorts still cover the complete filtered result.
Undated rows have an independent keyset page. `maximum_undated_batch_rows = 0`
keeps the complete list; values 1–500 cap each page. Set
`filter_undated_batch_cursor = abap_true` and supply the prior row's batch,
location, and valuation type in `undated_cursor_batch`,
`undated_cursor_location`, and `undated_cursor_val_type`. The exclusive cursor
follows batch, location, and valuation type order; blank key components are
valid. `total_undated_batch_row_count` and the existing
`undated_batch_row_count` report all matching rows, while
`returned_undated_row_count` reports the current page size.
`is_undated_truncated` indicates another page exists. When true,
`next_undated_cursor_batch`, `next_undated_cursor_location`, and
`next_undated_cursor_val_type` identify its last row; otherwise those fields are
initial. An inactive cursor requires all `undated_cursor_*` fields to be
initial. Setting `omit_undated_batch_rows = abap_true` suppresses undated details while
preserving counts, quantities, and earliest-row identity; it cannot be combined
with a positive undated page limit or active undated cursor. The flag defaults
to `abap_false`. With omission, the earliest-row identity and full source totals
are derived during the stock scan without materializing undated detail rows.
Base and UOM requests and results carry both page contexts;
UOM detail rows are converted for each selected page. Each continuation is a
new stock read and does not pin the first page's snapshot.

## Batch expiry summary-only dated results

Set `omit_dated_batch_rows = abap_true` to suppress dated detail rows while
keeping the full filtered counts, quantities, first/next cohorts, and source
matrices. The flag defaults to `abap_false` and requires
`maximum_batch_rows = 0` with no active dated cursor. With omission,
first/next cohorts are derived directly from stock rows, without
materializing dated detail rows. The result has an empty `batches` list, zero
returned-row and page summaries, initial page dates
and cursors, and `is_truncated = abap_false`. The independent undated page and
all full-scope summaries remain available. Base and UOM results echo the flag;
UOM full summaries retain their normal base/requested-unit values.

## Batch expiry page-level totals

Paged expiry results report page-scoped summaries in addition to the full filtered totals. The
dated page includes `page_expired_row_count`, `page_upcoming_row_count`, and
`page_after_window_row_count`, plus `page_unrestricted_qty`, `page_available_qty`,
`page_quality_qty`, and `page_blocked_qty` for its returned rows. The independent undated page
reports `undated_page_unrestricted_qty`, `undated_page_available_qty`,
`undated_page_quality_qty`, and `undated_page_blocked_qty`. These values cover only rows
returned after the exclusive cursor and page limit; the existing totals continue to cover the
complete filtered result. UOM results echo the status counts and expose dated totals through
`base_page_unrestricted_qty`, `src_page_unrestricted_qty`, `base_page_available_qty`,
`src_page_available_qty`, `base_page_quality_qty`, `src_page_quality_qty`,
`base_page_blocked_qty`, and `src_page_blocked_qty`. Undated UOM totals use
`base_und_page_unrestr_qty`, `src_und_page_unrestr_qty`, `base_und_page_avail_qty`,
`src_und_page_avail_qty`, `base_und_page_quality_qty`, `src_und_page_quality_qty`,
`base_und_page_blocked_qty`, and `src_und_page_blocked_qty`. The page totals
also expose `page_avail_pct` and signed
`page_reservation_deduction_qty`; the independent undated page uses
`und_page_avail_pct` and
`und_page_resv_deduct_qty`. Each ratio is available divided by
unrestricted quantity, rounded to two decimals, and zero for a zero denominator.
Each deduction is unrestricted minus available and preserves negative values.
UOM results echo both percentages and provide base/requested-unit deductions in
`base_page_resv_deduct_qty` / `src_page_resv_deduct_qty`
and `base_und_page_resv_deduct_qty` /
`src_und_page_resv_deduct_qty`.

## Batch expiry page date ranges

Each dated expiry page reports `page_earliest_expiration_date`, `page_latest_expiration_date`,
and `page_expiration_date_span_days` across only the rows returned after its cursor and page
limit. The dates are the minimum and maximum expiration dates regardless of status ordering; the
span is latest minus earliest in elapsed calendar days. Empty pages return initial dates and a
zero span, and one-row pages have a zero span. UOM results copy all three fields unchanged; full
filtered date summaries remain unchanged.

## Batch expiry page status summaries

Each dated page returns a fixed `page_expiry_statuses` table for expired (`E`), upcoming (`U`),
and after-window (`A`) stock, including zero-valued rows when a status is absent or the page is
empty. Each row contains `expiry_status`, `row_count`, `row_share_pct`, `unrestricted_qty`,
`available_qty`, `quality_qty`, and `blocked_qty`; the three rows reconcile to the page totals
and status counts. `row_share_pct` is each status's percentage of returned dated rows, rounded
to two decimals and zero on empty pages; independent rounding may shift the sum slightly from
100. UOM rows preserve the percentage and contain
`base_unrestricted_qty`/`unit_unrestricted_qty`, `base_available_qty`/`unit_available_qty`,
`base_quality_qty`/`unit_quality_qty`, and `base_blocked_qty`/`unit_blocked_qty`. These values
cover only returned dated rows and do not change the full filtered summaries.

## Batch expiry page status date ranges

Each row in `page_expiry_statuses` also reports its first and last expiration
dates and their elapsed day span, calculated from only returned dated rows of
that status. The page-wide date range remains available independently. Statuses
with no returned rows retain initial dates and a zero span; summary-only dated
requests return the same zero page ranges. UOM results copy the date fields
unchanged.

## Batch expiry page status quantity shares

Each `page_expiry_statuses` row also includes `unrestricted_qty_share_pct`,
`available_qty_share_pct`, `quality_qty_share_pct`, and `blocked_qty_share_pct`.
Each percentage divides that status's quantity by the matching category total
for the returned dated page and rounds to two decimals. Shares sum to 100 per
nonzero category except for independent rounding. A zero category total yields
zero shares for every status. Empty and summary-only pages return zero shares,
and UOM results echo the percentages unchanged.

## Batch expiry page source/status summaries

Each dated page returns a fixed nine-row `page_expiry_src_statuses` matrix for plant (`P`),
global (`G`), and other (`O`) expiry-date sources crossed with expired (`E`), upcoming (`U`),
and after-window (`A`) status. Empty cells remain present with zero counts and quantities. Each
row reports `source_group`, `expiry_status`, `row_count`, `row_share_pct`,
`status_row_share_pct`, `source_row_share_pct`, `first_expiration_date`,
`last_expiration_date`, `expiration_date_span_days`,
`unrestricted_qty`, `available_qty`, `quality_qty`, and `blocked_qty`, plus the four `status_*_share_pct` and four `source_*_share_pct` percentages,
aggregated only from the returned dated page. `row_share_pct` uses the returned
page's dated row count. Percentages round to two decimals, remain zero on an
empty page or zero denominator, and may sum slightly away from 100 because of
independent rounding. `status_row_share_pct` uses the matching page-status count, and
`source_row_share_pct` uses the matching page-source count; each is zero when
its denominator is empty. Each cell also reports `status_unrestricted_share_pct`,
`status_available_share_pct`, `status_quality_share_pct`, and
`status_blocked_share_pct`: its share of the matching page status's quantity
for that category. These status-relative quantity shares sum to 100 across
sources for each nonzero status category, aside from independent rounding, and
remain zero for zero totals. Blank and unknown source values map to `O`. UOM
results preserve the matrix keys, counts, dates, and percentages, and return
base/requested-unit quantities for all four categories. The matrix reconciles
to the page status and category summaries without changing full filtered totals.

## Batch expiry page source/status quantity shares

Each `page_expiry_src_statuses` cell reports its contribution to each
category's total page quantity in the four `*_qty_share_pct` fields. These
percentages use the corresponding returned-page total and round to two decimals.
Shares across the nine cells sum to 100 for each nonzero category except for
independent rounding. The four `status_*_share_pct` fields instead divide each
cell's category quantity by the matching page status's category total. Shares
across sources sum to 100 within each nonzero status/category, except for
independent rounding. The four `source_*_share_pct` fields divide each cell's
category quantity by the matching page source's category total, so shares
across statuses sum to 100 for each nonzero source/category except for
independent rounding. All shares are zero when their denominator is zero.
Empty and summary-only pages return zero shares. UOM results echo the percentages
unchanged.

## Batch expiry page source/age-band summaries

Each dated page also returns a fixed 12-cell `page_expiry_src_age_bands` matrix
for expired rows only. It crosses plant (`P`), global (`G`), and other or blank
(`O`) expiry sources with age bands 1–7, 8–30, 31–90, and over 90 days before
`as_of_date`. Each row includes the count, share of the page's expired rows,
`source_row_share_pct` within its source, `age_band_row_share_pct` within its age
band, first and last expiration dates, date span, all four stock-category
totals, and four `*_qty_share_pct` fields. Source shares use returned expired
rows for that source; age-band shares use returned expired rows in that band
across sources. The four `source_*_share_pct` fields use the matching returned
expired category total for that source. The four `band_*_share_pct` fields use
the matching returned-page category total for that age band across sources.
Quantity shares use the matching category total among returned expired rows; all percentages round to two decimals and are zero
when their denominator is zero. Blank and unknown sources map to `O`. The matrix
reconciles to expired rows on the current page and is independent of the full
filtered `expiry_src_age_bands` summary. UOM results preserve keys, counts,
dates, spans, and shares and provide base and requested-unit quantities for all
four categories. Summary-only dated requests return all 12 cells with zero page
counts and quantities.

## Batch expiry page source/window-band summaries

Each dated page returns two fixed 12-cell source/window matrices:
`page_upcoming_src_bands` covers upcoming rows within the inclusive request
window, and `page_after_window_src_bands` covers after-window rows. Both cross
plant (`P`), global (`G`), and other or blank (`O`) expiry sources with four
bands. Upcoming bands are 0–7, 8–30, 31–90, and over 90 days from
`as_of_date`; after-window bands are 1–7, 8–30, 31–90, and over 90 days after
`through_date`. Each cell includes row count, `row_share_pct` within its page
status, `source_row_share_pct` within its source, and
`through_band_row_share_pct` within its window band. Four `source_*_share_pct`
fields divide category quantities by their matching page-status source totals.
The four `band_*_share_pct` fields use each returned page status's category total
within that lead-time band across sources. First and last
expiration dates, elapsed date span, all four stock-category totals, and four
`*_qty_share_pct` fields, each using its matching page status category total.
Source shares use all returned rows for that status and source; band shares use
all returned rows for that status and band across sources. Empty cells stay
present; all percentages round to two
decimals and are zero when their denominator is zero. Blank and unknown sources map
to `O`. UOM results preserve keys, counts, dates, spans, and shares, and
provide base and requested-unit quantities for all categories. Summary-only
dated requests return both matrices with zero page counts and quantities;
full-scope upcoming and after-window summaries remain unchanged.

## Batch expiry age/window availability ratios

Every row in the full and page source/age and source/window matrices includes
`available_pct_of_unrestricted`. It is the cell's reservation-net
`available_qty` divided by its `unrestricted_qty`, multiplied by 100. Full
matrices use full filtered cell quantities; page matrices use only returned
rows. The ratio rounds to two decimals and is zero when unrestricted quantity
is zero. Each cell also reports `reservation_deduction_qty`, calculated as
unrestricted quantity minus available quantity. UOM rows provide
`base_reservation_deduction_qty` and converted `unit_reservation_deduction_qty`;
the raw difference is retained if it is negative. UOM results echo the ratio
unchanged.

## Batch expiry full-scope dated source/status matrix

The full `expiry_src_statuses` source/status matrix includes `row_share_pct`,
calculated across all matching positive-stock dated rows (including
after-window rows) after request filters, independent of page cursors and page
limits. `status_row_share_pct` gives each source's share within its matching
expiry status. `source_row_share_pct` gives each status's share within its
matching source, using that source's full dated row count as its denominator.
Each cell also reports its percentage of each full dated stock-category total
in the four `*_qty_share_pct` fields. These category shares use the matching
full dated total as their denominator. The four `status_*_share_pct` fields
divide each cell's category quantity by the corresponding full status summary
quantity instead. The four `source_*_share_pct` fields divide each cell's
category quantity by the corresponding full source summary quantity, so shares
across statuses sum to 100 for each nonzero source/category except for
independent rounding. Both sets round to two decimals and remain zero when their
denominator is zero. Empty matrices have zero shares. UOM results echo all
percentages unchanged.

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

## Batch expiry full-scope status summaries

`expiry_statuses` provides three direct full-scope rows for expired, upcoming,
and after-window stock. Each row includes count, row share, first and last
expiration dates, date span, and all four stock-category quantities with
category shares. The shares use the same complete matching dated rows and
category totals as `expiry_src_statuses`, including after-window stock, and
remain stable across page cursors, page limits, and omitted detail rows. Empty
statuses remain present with zero shares and initial date ranges. UOM results
echo counts, dates, spans, and percentages and provide base/requested-unit
quantities.

## Batch expiry source summaries

`expiry_sources` and `page_expiry_sources` each return fixed plant (`P`),
global (`G`), and other (`O`) rows for dated stock; blank and unknown source
markers map to `O`. Rows include counts, date ranges, four category totals, and
row/category shares rounded to two decimals. Page summaries use returned dated
details and their category totals. Full summaries use every matching dated
row and full category totals, including after-window stock, and remain stable
across page limits and cursors. Shares are zero when their denominator is zero.
Empty source rows remain present with zero shares and initial dates. UOM results
preserve counts, date ranges, and shares and provide base/requested-unit
quantities.

## Batch expiry undated page source summaries

Undated detail rows expose their raw `expiration_date_source`. Each undated page returns a fixed `undated_page_expiry_sources` table for plant (`P`), global (`G`), and other (`O`) sources, with a row count and `unrestricted_qty`, `available_qty`, `quality_qty`, and `blocked_qty` per source. `row_share_pct` gives each source's share of the returned undated rows, rounded to two decimals; shares may not sum to exactly 100 after rounding, and empty pages return zero shares. Blank and unknown source values map to `O`. These rows cover only undated details returned after the independent undated cursor and page limit; zero-valued source rows stay present on empty pages. UOM results preserve the source group, row count, and percentage and provide base/requested-unit quantities for all four categories. Existing full undated scalar totals remain unchanged.

## Batch expiry full-scope undated source summaries

Each batch expiry result also returns a fixed `undated_expiry_sources` table
for plant (`P`), global fallback (`G`), and other or blank (`O`) sources. It
summarizes every matching positive-stock undated row after request filters,
independent of the undated cursor, page limit, or omission of detail rows. The
three rows remain present when empty and reconcile to the full undated row count
and four category totals. Each row's `row_share_pct` reports its percentage
of the full filtered undated row count, rounded to two decimals and zero when
there are no rows. UOM results preserve keys, counts, and percentages and
report base and requested-unit quantities for all categories. The scalar full
undated totals also report `undated_avail_pct` and signed
`undated_resv_deduct_qty`; UOM results echo the percentage and provide
`base_undated_resv_deduct_qty` and
`src_undated_resv_deduct_qty`. Page-local
`undated_page_expiry_sources` continues to summarize only returned details.

## Batch expiry undated source quantity shares

Both `undated_page_expiry_sources` and `undated_expiry_sources` include four
category-share fields alongside their quantity totals. Page shares use each
returned page category total as the denominator. Full shares use each complete
filtered undated category total, independent of cursor, page limit, or omitted
detail rows. Each share is rounded to two decimals and remains zero when its
denominator is zero; row-count shares keep their existing denominators. UOM
results preserve all percentage fields and provide base/requested-unit
quantities.

## Batch expiry first-undated source marker

The first-undated-row summary includes `first_undated_expiry_source`, copied
from the raw expiry-date source on the first positive-stock undated row in
batch, location, and valuation order. The marker remains blank when there is no
such row. Base and UOM results report the same value without normalizing blank
or unknown sources, so callers can distinguish the selected row's raw
provenance; the P/G/O source summaries continue to provide grouped totals.

## Planned-order bulk stop-on-failure

Planned-order create, suggestion-based create, delete, change, and conversion
bulk methods accept `iv_stop_on_failure`, defaulting to `abap_false`. The
default continues after each per-request BAPI or commit failure. When enabled,
the first failed request stops later API calls after prevalidation has checked
the full input. Earlier successful independent commits remain committed.
Results retain every input row in caller order, mark unattempted rows with
`is_skipped`, and report `skipped_count` separately from `failed_count`.
`stopped_on_failure` is set when execution stops, even if the failed row was the
last input. Suggestion-based create also forwards the option and retains the
source suggestion and receipt-lot indexes on skipped rows. Only `abap_true` or
`abap_false` is accepted; invalid values raise before any API call.

## Planned-order create simulation

Atomic and independent planned-order creates, including suggestion-based
wrappers, accept `iv_test_run`, defaulting to `abap_false`. The adapter forwards
`TESTRUN = 'X'` to `BAPI_PLANNEDORDER_CREATE`. Successful simulation may return
no planned-order number; the service treats that as success only in test-run
mode. Simulations retain per-request results and stop-on-failure accounting,
and make no commit or rollback calls. Invalid flag values fail before a BAPI
call.

## Planned-order finish-window read

`READ_ORDERS_BY_FINISH_WINDOW` searches planned orders for one required
material and production plant (`PLAF-PWWRK`) over an inclusive finish-date
interval. A nonblank `planning_plant` selects the exact planning plant
(`PLAF-PLWRK`); blank omits this filter by default. Set
`filter_planning_plant` to `abap_true` to match exactly, including blank. The
flag accepts only `abap_true` or `abap_false`, and a nonblank value continues
to filter when the flag is false. Returned headers expose the planning plant
alongside the production `plant`.
The optional `creation_date_from` and `creation_date_to` pair filters the
planned-order creation date (`PLAF-PERTR`), which is returned in each
header; provide both valid dates in ascending order or omit both. An optional
`planned_order_user` matches `PLAF-PUSER` exactly when nonblank; blank omits
the filter by default. Set `filter_planned_order_user` to `abap_true` to match
exactly, including an initial user value. The flag accepts only `abap_true` or
`abap_false`; a nonblank value filters even when the flag is false. The selected
user is returned in each header. Headers also include the last-change timestamp (`PLAF-PSTMP`) as
a packed-decimal short timestamp. Optional
`last_change_timestamp_from` and `last_change_timestamp_to` bounds filter that
raw field inclusively before pagination; either bound can be supplied alone.
Each supplied bound must be positive, and both must be in ascending order when
supplied together. Returned timestamps are checked against every supplied
bound. This is a source-field filter, not an exact wall-clock change-time cutoff,
because SAP notes that `PSTMP` can differ from the apparent change time. The
header also includes scheduled start and finish dates/times
(`GSTRS`/`GSUZS` and `GLTRS`/`GLUZS`) separately from the basic dates used by
this search. The optional `scheduled_finish_date_from` and
`scheduled_finish_date_to` pair filters `PLAF-GLTRS` inclusively before
pagination; both valid dates in ascending order are required, or both must be
omitted. Returned scheduled finish dates are checked against the selected
range. The optional `scheduled_start_date_from` and
`scheduled_start_date_to` pair filters `PLAF-GSTRS` inclusively before
pagination; both valid dates in ascending order are required, or both must be
omitted. Returned scheduled start dates are checked against the selected
range. Set `filter_scheduled_start_date` to `abap_true` to match the exact
`scheduled_start_date`, including blank; a nonblank value continues to filter
when the flag is false. The flag accepts only `abap_true` or `abap_false`, and
nonblank dates must be valid. `filter_scheduled_finish_date` and
`scheduled_finish_date` provide the same exact-match behavior for `PLAF-GLTRS`.
Exact-date and date-range filters intersect when both are supplied.
`filter_scheduled_start_time` and
`filter_scheduled_finish_time` are boolean opt-ins for inclusive scheduled
time-of-day ranges on `PLAF-GSUZS` and `PLAF-GLUZS`. Each enabled filter needs
valid `scheduled_start_time_from`/`scheduled_start_time_to` or
`scheduled_finish_time_from`/`scheduled_finish_time_to` bounds in ascending
order. `000000` is a valid midnight bound when its filter is enabled. Both flags
accept only `abap_true` or `abap_false`; disabled filters require initial bounds.
These time ranges apply on every matching date,
can be combined with the scheduled-date ranges, and do not wrap across midnight.
Returned scheduled times are validated and checked against enabled ranges.
Ordering and continuation still use the basic finish date. SAP notes
that `PSTMP` can differ from the apparent change time,
so callers should treat it as a source-system timestamp. Optional
nonblank `sales_order` and `planning_scenario` values restrict the search to
orders assigned to those values. Set `filter_sales_order` to `abap_true` to
match `sales_order` exactly, including the initial value for orders without a
sales-order assignment; nonblank values continue to filter when the flag is
false. The flag must be `abap_true` or `abap_false`. Set
`filter_planning_scenario` to
`abap_true` to match the exact scenario, including an unmaintained scenario;
the flag must be `abap_true` or `abap_false`. An optional nonblank `order_type`
filter matches the exact planned-order type
in `PLAF-PAART`; blank omits it by default. Set `filter_order_type` to
`abap_true` to match exactly, including blank. The flag accepts only `abap_true`
or `abap_false`, and a nonblank type continues to filter when the flag is
false. Set `filter_start_date` to `abap_true` to match the exact `start_date`,
including blank; a nonblank value filters when the flag is false. The flag
accepts only `abap_true` or `abap_false`, and nonblank dates must be valid. The
optional `start_date_from` and `start_date_to` pair adds an inclusive
planned-start-date range; callers must provide both valid dates in ascending
order or omit both. Exact-date and range filters intersect when both are set.
Set `filter_storage_location` to `abap_true` to match the exact
`storage_location`, including blank for orders without an assigned storage
location. A noninitial location without the flag is invalid.
Set `filter_procurement_indicator` to `abap_true` to match the exact
`procurement_indicator`, including blank; a value without the flag is invalid.
Set `filter_special_proc_type` to `abap_true` to match the exact
`special_procurement_type` (`PLAF-SOBES`), including blank. A value without
the flag is invalid. The selected value is returned in each planned-order
header, and the filter applies before pagination.
Set `positive_quantity_only` to `abap_true` to exclude zero and negative planned
order quantities; when false, the finish-window search retains them. Optional
`filter_quantity_from` and `filter_quantity_to` flags select inclusive lower
and upper bounds on `PLAF-GSMNG` independently. Each flag accepts only
`abap_true` or `abap_false`; zero is a valid bound when its flag is enabled.
When both flags are enabled, the lower bound must not exceed the upper bound.
Disabled bounds must be initial. The bounds use the planned order's
`order_unit` and apply before pagination; they do not use converted base-unit
quantities. The service rejects invalid flags, disabled bounds supplied with a
value, reversed ranges, and returned rows outside either selected bound. A
nonblank `order_unit` can also restrict results to one exact unit. Set
`filter_order_unit` to `abap_true` to match the exact unit including blank;
otherwise the flag must be a boolean and a nonblank unit still filters. The
unit filter runs before pagination and is validated against returned rows.
`filter_base_quantity_from` and `filter_base_quantity_to` add inclusive bounds
for `quantity_in_base_unit` in the material base unit. Either bound can be used
alone; values may be zero or negative, disabled values must be initial, and two
active bounds must be ordered. These filters compose with the order-unit bounds
and `positive_quantity_only`, run before pagination, and require a valid
base-unit conversion when the order unit differs from the material base unit.
Returned rows are rechecked against the converted quantity.
Set `filter_mrp_controller` to `abap_true` to match the exact `mrp_controller`,
including blank; a controller value without the flag is invalid.
Set `filter_production_supervisor` to `abap_true` to match the exact
`production_supervisor`, including blank; a supervisor value without the flag
is invalid.
Set `filter_production_version` to `abap_true` to match the exact
`production_version`, including blank; a version value without the flag is
invalid.
Set `filter_mrp_area` to `abap_true` to match the exact `mrp_area`, including
blank; an area value without the flag is invalid.
Set `filter_account_category` to `abap_true` to match the exact
`account_assignment_category`, including blank; a category value without the
flag is invalid.
Set `filter_sales_order_item` to `abap_true` to match the exact
`sales_order_item` (`PLAF-KDPOS`), including its initial value. This filter
requires a nonblank `sales_order`; an item value without the flag is invalid.
Set `filter_sales_schedule_line` to `abap_true` to match
`sales_order_schedule_line` (`PLAF-KDEIN`) exactly, including the initial value
`0000`. This filter requires a nonblank sales order and a selected, nonblank
sales-order item. A schedule-line value without the flag is invalid.
Set `filter_special_stock` to `abap_true` to filter by the exact
`special_stock_indicator`; this includes blank for ordinary stock. When the flag
is false, a noninitial indicator is invalid. Set `filter_fixed_indicator` to
`abap_true` to select the exact `fixed_indicator` value: `abap_true` selects
firmed orders and blank selects unfixed orders. Only those two values are
accepted; a value without the flag is invalid. All selected filters are applied
before pagination.

The caller sets `maximum_results` from 1 through 500. The repository returns at
most one extra row so the service can report `is_truncated` while preserving at
most the requested number of result rows. Results sort by finish date and
planned-order number, and reuse the existing base-unit quantity conversion.
Invalid dates, missing scope, reversed ranges, partial cursors, and out-of-range
limits fail before the read. After the query, the service rejects more than
`maximum_results + 1` rows, blank or duplicate numbers, mismatched
selected material, production plant, planning plant, creation-date range,
planned-order user, sales order, planning scenario, order type,
storage-location, procurement, special procurement type, special-stock and
fixed indicators, and
positive-quantity, order- and base-unit quantity bounds, MRP-controller,
production-supervisor, production-version,
MRP-area, account-assignment-category, sales-order-item, and schedule-line
scope, start-date scope, finish dates outside the requested range, cursor
regressions, and duplicate or out-of-order rows.
When more rows match, the result returns a continuation cursor made from the
last returned finish date and planned-order number; callers pass both back to
continue without repeating same-date orders. Number-based bulk reads and
finish-window queries include a UTC `snapshot_timestamp` marking repository-read
completion. It remains initial for empty direct bulk input, while a finish-window
query returns it even when no orders match. The timestamp does not lock planned
orders or make later pages part of the same snapshot.

## Planned-order bulk read integrity

`READ_ORDERS_BULK` validates repository results before mapping them. Returned
planned-order numbers must be nonblank, unique, and present in the requested
number list. A blank, duplicate, or unrequested repository row raises
`ZCX_INVALID_STOCK_REQUEST`; requested numbers omitted by the repository remain
per-row not-found results.

## Production-order finish-window read

`READ_ORDERS_BY_FINISH_WINDOW` searches production and process orders for one
material and plant over an inclusive basic-finish-date interval. Optional
`filter_receipt_progress_status` selects orders with at least one matching
material/plant item in the requested receipt state before pagination. Set the
flag to `abap_true` and use `receipt_progress_status` `N` (not started), `P`
(partial), `C` (complete), `O` (over-received), or blank for an invalid
quantity (nonpositive AFPO-PSMNG or negative AFPO-WEMNG). When the flag is
`abap_false`, `receipt_progress_status` must be blank. The flag accepts only
`abap_true` or `abap_false`; invalid selections fail before repository reads.
Detail reads recheck the selected state and mark orders whose matching item
changed as `finish_filter_lost`. All output items on selected orders remain in
the result, and `receipt_progress_counts` continues to count every output item.
Each finish-window item sets `matches_finish_selection` when its detail
row still matches the selected item scope. Other items remain in the result
with the flag false; direct `READ_ORDERS_BULK` results leave it initial. Active
status remains an order-level check reported separately by `status_filter_lost`.
Each finish-window order reports `finish_window_match_count`, the number
of returned detail rows still matching the selected item scope. Direct bulk
reads leave this count at zero.
`filter_received_qty_from` and `filter_received_qty_to` add inclusive lower and
upper bounds for AFPO-WEMNG in the order unit, before pagination. Either bound
can be active by itself; zero is valid, negative bounds are rejected, and two
active bounds must be ordered. An inactive flag requires its quantity to be
initial, and each flag accepts only `abap_true` or `abap_false`. Detail reads
recheck both bounds against returned order-unit receipt quantities.
Optional inclusive `filter_over_receipt_qty_from` and
`filter_over_receipt_qty_to` bounds select `over_receipt_qty_order_unit` in the
AFPO order unit. Either bound can be used alone; active bounds must be
nonnegative, inactive values must be initial, and two active bounds must be
ordered. The key query requires valid receipt progress and applies the bounds
before pagination; valid items without an over-receipt have a zero quantity.
Detail reads recheck the calculated over-receipt quantity and its validity.
`filter_over_receipt_pct_from` and `filter_over_receipt_pct_to` add inclusive
bounds for the raw over-receipt-to-order quantity ratio, expressed as a
percentage before two-decimal display rounding. Either bound can be used alone;
active bounds must be nonnegative with no upper cap, inactive values must be
initial, and two active bounds must be ordered. A zero lower bound includes all
valid receipt-progress items; upper bounds include items without an
over-receipt, whose percentage is zero. The key query applies the bounds before
pagination, and detail reads recheck them against raw quantities.
`filter_received_pct_from` and `filter_received_pct_to` add inclusive bounds for
the raw received-to-order quantity ratio, expressed as a percentage before
two-decimal display rounding. Each bound may be used alone; zero is valid,
negative bounds are rejected, disabled bounds must be initial, and two active
bounds must be ordered. Items with nonpositive order quantities or negative
received quantities cannot match an enabled percentage bound. The repository
applies the bounds before pagination, and detail reads check them again for
scope drift.
`filter_unreceived_pct_from` and `filter_unreceived_pct_to` add inclusive bounds
for `open_pct_of_order_qty`, calculated from the positive remaining AFPO order
quantity before two-decimal display rounding. Either bound may be used alone;
values must be from 0 through 100, inactive values must be initial, and two
active bounds must be ordered. Only items with positive order quantity and
nonnegative received quantity match. Completed and over-received items have
zero open percentage. The repository applies the bounds before pagination,
and detail reads recheck them for scope drift.
Other optional nonblank `sales_order` values select orders assigned to that AFPO
sales-order number. Set `filter_sales_order` to `abap_true` to match the exact
AFPO-KDAUF value, including blank; the flag accepts only `abap_true` or
`abap_false`, and a nonblank value filters when the flag is false. The
repository applies the filter before pagination, returns the value on each
item, and checks it during detail-read drift detection.
The optional nonblank `sales_order_item` selects AFPO-KDPOS before pagination.
Set `filter_sales_order_item` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank item filters
when the flag is false. Returned items expose the sales-order item, and detail
reads check it for scope drift.
The optional nonblank `sales_order_schedule_line` selects AFPO-KDEIN before
pagination. Set `filter_sales_schedule_line` to `abap_true` to match exactly,
including blank; the flag accepts only `abap_true` or `abap_false`, and a
nonblank schedule line filters when the flag is false. Returned items expose
the sales-order schedule line, and detail reads check it for scope drift.
The optional nonblank `planned_order` selects AFPO-PLNUM before pagination. Set
`filter_planned_order` to `abap_true` to match exactly, including blank; the flag
accepts only `abap_true` or `abap_false`, and a nonblank planned-order number
filters when the flag is false. Returned items expose the planned-order number,
and detail reads check it for scope drift.
The optional nonblank `planning_plant` selects AFPO-PWERK before pagination;
`plant` continues to select the production plant in AFPO-WERKS. Set
`filter_planning_plant` to `abap_true` to match exactly, including blank. The
flag accepts only `abap_true` or `abap_false`, and a nonblank planning plant
filters when the flag is false. Returned items expose `planning_plant`, and
detail reads check it for scope drift.
The optional nonblank `delivery_plant` selects AFPO-DWERK before pagination.
Set `filter_delivery_plant` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank delivery
plant filters when the flag is false. Returned items expose `delivery_plant`,
and detail reads check it for scope drift.
The optional nonblank `special_stock_indicator` selects AFPO-SOBKZ before
pagination. Set `filter_special_stock` to `abap_true` to match exactly,
including blank; the flag accepts only `abap_true` or `abap_false`, and a
nonblank indicator filters when the flag is false. Returned items expose
`special_stock_indicator`, and detail reads check it for scope drift.
The optional nonblank `stock_type` selects AFPO-INSMK before pagination. Set
`filter_stock_type` to `abap_true` to match exactly, including blank; the flag
accepts only `abap_true` or `abap_false`, and a nonblank stock type filters
when the flag is false. Returned items expose `stock_type`, and detail reads
check it for scope drift.
The optional nonblank `goods_recipient` selects AFPO-WEMPF before pagination.
Set `filter_goods_recipient` to `abap_true` to match exactly, including
blank; the flag accepts only `abap_true` or `abap_false`, and a nonblank
recipient filters when the flag is false. Returned items expose
`goods_recipient`, and detail reads check it for scope drift.
The optional nonblank `unloading_point` selects AFPO-ABLAD before pagination.
Set `filter_unloading_point` to `abap_true` to match exactly, including
blank; the flag accepts only `abap_true` or `abap_false`, and a nonblank point
filters when the flag is false. Returned items expose `unloading_point`, and
detail reads check it for scope drift.
The optional nonblank `production_version` selects AFPO-VERID before
pagination. Set `filter_production_version` to `abap_true` to match exactly,
including blank; the flag accepts only `abap_true` or `abap_false`, and a
nonblank production version filters when the flag is false. Returned items
expose `production_version`, and detail reads check it for scope drift.
The optional nonblank `planned_order_start_date` selects AFPO-STRMP before
pagination. Set `filter_plan_start_date` to `abap_true` to match
exactly, including blank; the flag accepts only `abap_true` or `abap_false`,
and a nonblank date filters when the flag is false. Nonblank dates must be valid.
Returned items expose the planned-order start date, and detail reads check it
for scope drift.
The optional nonblank `storage_location` selects AFPO-LGORT before pagination.
Set `filter_storage_location` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank location
filters when the flag is false. Returned items expose the storage location, and
detail reads check it for scope drift.
The optional nonblank `batch` selects AFPO-CHARG before pagination. Set
`filter_batch` to `abap_true` to match exactly, including blank; the flag accepts
only `abap_true` or `abap_false`, and a nonblank batch filters when the flag is
false. Returned items expose the batch, and detail reads check it for scope
drift.
The optional nonblank `account_assignment_category` selects AFPO-KNTTP before
pagination. Set `filter_assignment_category` to `abap_true` to match
exactly, including blank; the flag accepts only `abap_true` or `abap_false`, and
a nonblank category filters when the flag is false. Returned items expose the
category, and detail reads check it for scope drift.
The optional nonblank `mrp_area` selects AFPO-BERID before pagination. Set
`filter_mrp_area` to `abap_true` to match exactly, including blank; the flag
accepts only `abap_true` or `abap_false`, and a nonblank area filters when the
flag is false. Returned items expose the MRP area, and detail reads check it for
scope drift.
The optional nonblank `wbs_element` selects the AFPO-PROJN assignment by its
external PRPS-POSID before pagination. Set `filter_wbs_element` to `abap_true`
to match exactly, including blank; blank selects items without an AFPO-PROJN
assignment. The flag accepts only `abap_true` or `abap_false`, and a nonblank WBS
element filters when the flag is false. Returned
items expose the external `wbs_element` and the original internal
`wbs_element_internal_id`; detail reads check the external assignment for drift.
Optional `basic_start_date_from` and `basic_start_date_to` bounds restrict orders by their
inclusive basic-start-date range; provide both valid dates in order or omit both.
Set `filter_basic_start_date` to `abap_true` to match the exact
`basic_start_date`, including blank; a nonblank date also filters when the
flag is false. The flag accepts only `abap_true` or `abap_false`, and a
nonblank date must be valid. The exact selector intersects with the optional
range, and returned keys and detail items are checked against both.
Optional `scheduled_start_date_from` and `scheduled_start_date_to` bounds
restrict the inclusive AFKO-GSTRS scheduled-start-date range. Provide both
valid dates in ascending order or omit both. The repository applies the range
before keyset pagination; the later key and detail reads check schedule-date
scope, while sorting and cursors remain based on basic finish date.
Optional `scheduled_finish_date_from` and `scheduled_finish_date_to` bounds
restrict the inclusive AFKO-GLTRS scheduled-finish-date range. Provide both
valid dates in ascending order or omit both. The repository applies the range
before keyset pagination; the requested result order and cursor remain based on
the basic finish date. The key and detail reads check scheduled-finish-date
drift.
Set `filter_scheduled_start_date` to `abap_true` to match the exact
`scheduled_start_date`, including blank; a nonblank date also filters when the
flag is false. `filter_scheduled_finish_date` and `scheduled_finish_date`
provide the same behavior for AFKO-GLTRS. Both flags accept only `abap_true` or
`abap_false`, and nonblank dates must be valid. Exact-date filters intersect
with their scheduled-date ranges, and the query, returned keys, and detail read
all check the selected dates.
Set `filter_scheduled_start_time` and `filter_scheduled_finish_time` to
`abap_true` to apply inclusive time-of-day ranges to AFKO-GSUZS and AFKO-GLUZS.
Each enabled filter requires two valid ascending times; `000000` is a valid
midnight bound. Both flags accept only `abap_true` or `abap_false`, and disabled
filters require initial bounds. The repository applies these ranges before
pagination, and returned keys and detail items are checked against them.
Time ranges apply on every matching date and do not wrap across midnight;
result ordering and cursors still use the basic finish date.
An optional nonblank `production_item` selects the exact `AFPO-POSNR` item
before pagination. The result still includes all items for each matching
order, and the later detail read checks the selected item in
`finish_filter_lost` drift detection.
An optional nonblank `order_unit` selects the exact `AFPO-AMEIN` value before
pagination and participates in detail-read drift checks. Order-quantity bounds
use this AFPO order unit.
All selected filters apply before keyset pagination. The repository returns all
items and active statuses for each matching order, with the existing base-unit
quantity conversion. Each item also exposes scheduled start and finish dates
from `AFKO-GSTRS` and `AFKO-GLTRS`, with their time-of-day values from
`AFKO-GSUZS` and `AFKO-GLUZS`. The requested window, sort order, and cursor
continue to use the basic finish date. An optional
`order_category` selects production
orders (`10`) or process orders (`40`); omitted, the search includes both
categories. An optional nonblank `order_type` filters on the exact AUFK-AUART
order type. The repository applies it before keyset pagination, and the later
detail read includes it in `finish_filter_lost` drift detection.
The optional nonblank `order_description` filters on the exact AUFK-KTEXT
short description and is returned on each detail item. Set
`filter_order_description` to `abap_true` to match exactly, including blank;
the flag accepts only `abap_true` or `abap_false`, and a nonblank description
filters when the flag is false. The repository applies the filter before
pagination, and the detail-read drift check includes it.
An optional nonblank `order_created_by` filters on AUFK-ERNAM and is returned
on each detail item. Set `filter_order_created_by` to `abap_true` to match
exactly, including blank; the flag accepts only `abap_true` or `abap_false`,
and a nonblank creator continues to filter when the flag is false. The
repository applies it before pagination, and the detail-read drift check
includes the selected creator.
Optional `created_date_from` and `created_date_to` bounds filter inclusively on
AUFK-ERDAT, the order creation date. Provide both valid dates in ascending
order or omit both. Returned items expose `created_date`, and the detail-read
drift check includes the selected range.
An optional nonblank `order_changed_by` filters on AUFK-AENAM and is returned
on each detail item. Set `filter_order_changed_by` to `abap_true` to match
exactly, including blank; the flag accepts only `abap_true` or `abap_false`,
and a nonblank changer continues to filter when the flag is false. Optional
`changed_date_from` and `changed_date_to` bounds
filter inclusively on AUFK-AEDAT; provide both valid ascending dates or omit
both. Returned items expose `changed_date`, and both selectors participate in
detail-read drift detection.
Set `exclude_deleted` to `abap_true` to require both a blank AUFK-LOEKZ order
deletion indicator and a blank AFPO-XLOEK matching-item deletion indicator.
The filter runs before pagination and participates in `finish_filter_lost`.
`receipt_expected_only` and `receipt_not_expected_only` select AFPO-WEPOS items
with the indicator set or blank, respectively. `delivery_complete_only` and
`delivery_not_complete_only` do the same for AFPO-ELIKZ. Each selector is a
boolean filter applied before pagination and checked by the detail-read drift
diagnostic. Opposite selectors for the same indicator cannot both be enabled.
The optional `required_phase` accepts `1`, `2`, or `3` and requires the
corresponding AUFK-PHAS1, AUFK-PHAS2, or AUFK-PHAS3 indicator. It applies before
pagination, is checked for detail-read drift, and rejects other nonblank values.
`unreceived_quantity_only` is a boolean opt-in that keeps orders
with positive `AFPO-PSMNG - AFPO-WEMNG` for the selected material and plant.
Optional inclusive `filter_unreceived_qty_from` and
`filter_unreceived_qty_to` bounds select a positive remaining quantity in the
AFPO order unit; enabled bounds must be positive, disabled bound values must be
initial, and the lower bound cannot exceed the upper bound. These filters run
before pagination. If the later detail read no longer has an item matching the
selected remaining-quantity scope, `finish_filter_lost` reports the drift.
Optional inclusive `filter_order_qty_from` and `filter_order_qty_to` bounds
select items by `AFPO-PSMNG` in the AFPO order unit. Enabled bounds must be
positive, disabled bound values must be initial, and the lower bound cannot
exceed the upper bound. These filters run before pagination and participate in
`finish_filter_lost` drift detection.
Optional inclusive `filter_order_qty_base_from` and
`filter_order_qty_base_to` bounds select `order_quantity_base` in the material
base unit. Either bound can be used alone; active bounds must be nonnegative,
inactive values must be initial, and two active bounds must be ordered. The
repository applies these bounds before pagination using the AFPO order-to-base
ratio, and only rows with a valid conversion can match. Detail reads recheck
the converted quantity and its conversion status.
Optional inclusive `filter_received_qty_base_from` and
`filter_received_qty_base_to` bounds select `received_quantity_base` in the
material base unit. Either bound may be used alone; active values must be
nonnegative, inactive values must be initial, and two active bounds must be
ordered. The repository applies these bounds before pagination using the AFPO
order-to-base ratio and requires a successful quantity conversion. Detail reads
recheck the converted received quantity and its conversion status.
Optional inclusive `filter_over_rcpt_qty_base_from` and
`filter_over_rcpt_qty_base_to` bounds select `over_receipt_quantity_base` in
the material base unit. Either bound may be used alone; active values must be
nonnegative, inactive values must be initial, and two active bounds must be
ordered. Zero includes valid items without receipt excess. The key query
compares the positive excess and AFPO order-to-base ratio before pagination and
requires valid receipt progress and successful quantity conversion. Detail
reads recheck both statuses and the converted excess.
Optional inclusive `filter_unrecv_qty_base_from` and
`filter_unrecv_qty_base_to` bounds select `open_quantity_base` in the
material base unit. Either bound may be used alone; active values must be
positive because only positive remaining quantities qualify, inactive values
must be initial, and two active bounds must be ordered. The repository compares
the AFPO remaining quantity and order-to-base ratio before pagination and
requires a positive remaining quantity and successful conversion. Detail reads
recheck the converted open quantity and its conversion status.
An optional `active_status_code` filters
on an exact currently
active SAP system or user status while the result retains all active statuses
for reconciliation. Because detail/status rows are read later,
each order flags `status_filter_lost` if that status is no longer active;
`status_filter_lost_count` summarizes those rows. Changed orders remain
in the result for reconciliation. `active_status_codes` can select several
currently active SAP system or user statuses; at least one listed code must be
active. Use either this list or `active_status_code`, not both, and do not
include blank codes. The detail/status recheck flags `status_filter_lost` when
none of the selected codes remains active. After the detail read,
`finish_filter_lost`
marks an order when none of its returned items still matches the selected
material, production plant, planning and delivery plants, item number, category,
order type and description, order unit, sales-order assignment/item/schedule
line, planned-order reference and start date, production version, special-stock
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
scheduled start/finish dates and time ranges. The result reports
`finish_filter_lost_count`.
This is separate from status drift. Results sort by basic finish date and
production-order number and are bounded to the caller's 1-to-500 result limit.
The result reports `is_truncated` and returns the last row's date/order cursor;
callers pass both cursor values to continue through same-date orders. Invalid
dates, missing scope, reversed ranges, incomplete cursors, and invalid limits
fail before repository reads. After the key read, the service rejects more than
`maximum_results + 1` rows, blank or duplicate orders, dates outside the requested
finish-date range, start-date range, cursor regressions, and keys that are
duplicate or out of sort order, before reading order details. `key_selection_timestamp` marks completion of the
matching-key query. `snapshot_timestamp` marks completion of the later detail and
status reads, including when no keys match. The timestamps make the read gap
visible; the separate reads do not form a transactionally consistent snapshot,
and the query does not lock orders between pages.

## Production-order bulk read completion times

`READ_ORDERS_BULK` captures `snapshot_timestamp` after its item and status
repository reads complete. `READ_CONFIRMATIONS_BULK` and `READ_OPERATIONS_BULK`
capture it after their grouped repository reads. `READ_ORDERS_BULK` rejects
item/status rows for unrequested orders and duplicate item or status keys before
mapping results. Empty direct bulk input leaves the timestamp initial; nonempty
reads return the UTC read-completion time. The
finish-window-only `key_selection_timestamp` remains initial for number-based bulk
reads. These timestamps do not imply a transactionally consistent snapshot
across separate repository reads. Number-based `READ_CONFIRMATIONS_BULK`
results also include page-scoped `work_center_summaries`, grouped by work-center
plant and code. Blank assignments form a group; each group's
`confirmation_count` covers only returned rows, excludes lookahead and later
pages, and the counts sum to `returned_count`. Each group also has
`quantity_summaries` by `AFRU-MEINH`; they report confirmation counts and gross
yield, rework, and scrap totals without adding incompatible units. Their
non-reversed totals exclude rows flagged as reversed, and per-unit counts sum
to the center count. Work-center summaries also report the first and last
posting dates among dated page confirmations, final, partial, and reversed
confirmation counts, and percentages based on the returned confirmation count.
Final and partial counts partition that count; reversal count is independent.
Operation rows from
`READ_OPERATIONS_BULK`
also expose `order_category` from AUFK-AUTYP, `order_type` from AUFK-AUART,
`resource_object_id` from AFVC-ARBID, and work-center code and plant from
CRHD-ARBPL and CRHD-WERKS, including operations without confirmations. Pass
`iv_work_center` or `iv_work_center_plant` to select an exact nonblank value;
nonblank selectors filter by default. Set `iv_filter_work_center` or
`iv_filter_work_center_plant` to `abap_true` with an initial value to select
blank assignments, including operations without a matching CRHD row. Both
flags accept only `abap_true` or `abap_false`. The repository applies these
filters before pagination, and the service validates returned code and plant
scope before mapping operations. Each page also returns
`work_center_summaries`, grouped by work-center code and plant in plant/code
order. The groups include blank assignments and summarize only operations on
the returned page; lookahead and later-page rows are excluded. Their
`operation_count` values sum to `total_operation_count`. Each group also
reports `order_count`, the number of distinct requested orders contributing
returned operations to that work center. An order counts once per work-center
group even when it has multiple operations there, and can count in more than
one group. Each group also reports `order_pct`, its distinct order count as a
share of `found_count`, rounded to two decimals. `found_count` is the number of
requested orders with operations on the returned page; order percentages are
initial when it is zero. Work-center groups can overlap, so their order
percentages can sum above 100. Each group also reports
`operation_pct`, its share of the returned
page's operations, rounded to two decimals. The percentage uses
`total_operation_count` as its denominator;
page percentages are computed from page counts rather than averaged across
orders. Empty pages leave percentages initial, and nonempty page percentages
sum to 100 before independent rounding. Each page also returns
`order_category_summaries`, grouped by AUFK-AUTYP. Blank categories remain
visible. Counts include returned page operations only, exclude lookahead and
later pages, and sum to `total_operation_count`. Each category reports
`operation_pct`, its share of page operations rounded to two decimals, using
`total_operation_count` as the denominator. Empty pages leave these percentages
initial. Each category also reports `order_count`, the number of distinct
requested orders with a returned operation in that category. Each category
reports `order_pct`, its order count as a share of `found_count`, rounded to two
decimals. Each page also
returns `order_type_summaries`, grouped by AUFK-AUART.
Blank order types remain visible; counts include returned page operations only,
exclude lookahead and later pages, and sum to `total_operation_count`. Each
order type reports `operation_pct`, its share of page operations rounded to two
decimals using `total_operation_count` as the denominator. Empty pages leave
these percentages initial. Each order type also reports `order_count`, the
number of distinct requested orders with a returned operation of that type.
Each order type reports `order_pct`, its order count as a share of
`found_count`, rounded to two decimals. Each page also returns
`control_key_summaries`,
grouped by AFVC-STEU. Blank control keys remain visible; counts include
returned page operations only, exclude lookahead and later pages, and sum to
`total_operation_count`. Each control key reports `operation_pct`, its share of
page operations rounded to two decimals using `total_operation_count` as the
denominator. Empty pages leave these percentages initial. Each control key also
reports `order_count`, the number of distinct requested orders with at least
one returned operation using that key. Each control key also reports
`order_pct`, its order count as a share of `found_count`, rounded to two
decimals. An order can appear in more than one control-key group, so control-key
order percentages can sum above 100. Pass
`iv_resource_object_id` to return
operations assigned to one resource; a nonblank ID filters by default. Set
`iv_filter_resource_object_id` to `abap_true` with an initial ID to select
unassigned operations exactly. The flag must be `abap_true` or `abap_false`,
and the service checks returned rows against the selected resource before
mapping them to orders. Pass `iv_control_key` to select a routing control key;
a nonblank key filters by default. Set `iv_filter_control_key` to `abap_true`
with an initial key to select operations whose control key is blank. The flag
must be `abap_true` or `abap_false`, and the service checks returned rows
against the selected key before mapping them to orders.
Pass `iv_operation_description` to select an exact AFVC-LTXA1 operation text;
a nonblank value filters by default. Set `iv_filter_op_description` to
`abap_true` with an initial text to select operations with a blank description.
The flag must be `abap_true` or `abap_false`, and the service checks returned
rows against the selected description.
Pass `iv_operation_number` to restrict results to one AFVC operation number;
an initial value leaves operation numbers unfiltered. It can be combined with
the resource and control-key selectors, and returned rows are checked against
the selected operation number. Set
`iv_operation_number_from` and/or `iv_operation_number_to` for inclusive
AFVC-VORNR bounds; initial values omit their bound, and noninitial bounds must
ascend when both are supplied. The exact `iv_operation_number` selector
intersects with the range. Pass
`iv_operation_counter` to select one exact AFVC-APLZL counter, with or without
an operation number. Set `iv_operation_counter_from` and/or
`iv_operation_counter_to` for inclusive APLZL bounds; initial values omit their
bound, and noninitial bounds must ascend when both are supplied. The exact
counter selector intersects with this range. All selectors apply before
pagination, and returned rows are checked against both selected ranges. Pass
`iv_operation_sequence` to select a routing sequence; set
`iv_filter_operation_sequence` to `abap_true` with an initial sequence to match
that value exactly. Set `iv_operation_sequence_from` and/or
`iv_operation_sequence_to` for inclusive AFVC-PLNFL bounds; initial values omit
their bound, and noninitial bounds must ascend when both are supplied. The
exact `iv_operation_sequence` selector intersects with the range. The
repository applies the range before pagination, and returned rows are checked
against it. Pass `iv_suboperation_number` to select one suboperation; set `iv_filter_suboperation_number` to `abap_true` with an
initial value to select only base operations. Set
`iv_suboperation_number_from` and/or `iv_suboperation_number_to` for inclusive
AFVC-UVORN bounds. Initial values omit their bound, paired active bounds must
ascend, and an active range requires an exact noninitial
`iv_operation_number`. The exact suboperation selector intersects with the
range. Both flags must be `abap_true` or `abap_false`, and the service checks
returned rows against all selected routing keys. Set `iv_order_category` to `10` for production orders
or `40` for process orders. When omitted, both categories are included. Other
nonblank category values fail before the repository read, and the service
checks returned rows against the selected category. Pass `iv_order_type` to
restrict results to one exact AUFK-AUART order type; operation rows report the
type and the service checks returned scope. This filter applies before
pagination. `iv_maximum_results`
limits each returned page to 1 through 500 operations and defaults to 500.
The selected order, category, type, resource, control-key, operation-description,
operation-number, operation-counter, sequence, suboperation, and suboperation
range filters apply before pagination.
Cursor traversal orders operation rows by production order, routing sequence,
operation number, suboperation number, and AFVC operation counter. When
`is_truncated` is true, pass all five `next_*` values back as the corresponding
`iv_after_*` values to continue after the last
returned operation; sequence and suboperation values must be passed even when
initial. Partial cursors and cursors whose production order is outside the
requested order list fail before repository reads. Keep the requested order
list and filters unchanged across pages. Each order reports its
page-level `operation_count`, and `total_operation_count` equals the sum of
those counts. `found_count` and `empty_count` describe orders with and without
operations on the current page. Each page has a UTC `snapshot_timestamp`; pages
are separate reads and do not form one transactionally consistent snapshot.

## Production-order quantity conversion summaries

Production-order bulk and finish-window results expose
`conversion_succeeded_count` alongside the existing page-level
`conversion_failed_count`. Each returned order exposes both counts for its own
returned items. A successful count increments when an item has completed its
base-unit quantity conversion; a failed count increments when required units,
quantities, or conversion ratios prevent that conversion. For each order and
page, the two counts sum to the returned detail-item count. Finish-window
conversion summaries include every returned item on selected orders, including
nonmatching detail rows retained for scope-drift reporting. An order with no
returned detail rows has zero counts, and an unreturned order keeps its result
counts initial. These conversion counts are independent of receipt-progress
validity and do not change the existing overall success behavior.
Finish-window results additionally expose `finish_match_conv_ok_count` and
`finish_match_conv_fail_count`, with matching per-order counts
`matching_conv_ok_count` and `matching_conv_fail_count`. These counts include
only items marked `matches_finish_selection`; each order's two counts sum to
its `finish_window_match_count`, and the page counts sum across the returned
orders. Direct bulk reads leave these matching-only counts initial. This lets
callers reconcile conversion quality for the selected item scope separately
from retained nonmatching details. The two matching counts can be zero when an
order has no matching detail rows, while its all-item conversion counts remain
nonzero if retained detail rows exist.
Finish-window results also expose `finish_match_base_qty_summary` and the
per-order `matching_base_qty_summary`, each with `item_count`,
`excluded_item_count`, `contributing_progress_counts`,
`contributing_progress_qty`, `invalid_progress_count`,
`valid_progress_conv_fail_count`, `order_qty_base_total`,
`received_qty_base_total`, `open_qty_base_total`, and
`over_rcpt_qty_base_total` in the selected material's base unit. `item_count`
includes matching items with valid receipt progress and successful conversion;
valid items without excess count and add zero to the over-receipt total.
`invalid_progress_count` includes every matching item with invalid receipt
progress, even if conversion also failed. `valid_progress_conv_fail_count`
counts only matching items with valid receipt progress and failed conversion.
These disjoint reason counts sum to `excluded_item_count`. For each order,
contributing and excluded counts sum to `finish_window_match_count`; page counts
sum the per-order counts. The page values sum the per-order matching summaries.
Order plus over-receipt totals
reconcile with received plus open totals, subject to decfloat34 rounding.
`contributing_item_pct` and `excluded_item_pct` show the two counts as
percentages of all matching items, rounded to two decimals. These are weighted
page or order ratios rather than averages of smaller summaries; empty summaries
leave them initial. `invalid_progress_pct` and
`valid_progress_conv_fail_pct` expose each disjoint exclusion reason as a
percentage of all matching items. The underlying reason percentages sum to the
excluded percentage; independent two-decimal rounding can cause a 0.01 point
difference. Empty summaries leave these percentages initial too.
`invalid_excluded_share_pct` and `conv_fail_excluded_share_pct` show each
disjoint reason's share of `excluded_item_count`. Their exact shares sum to
100%; independent two-decimal rounding can cause a 0.01 point difference.
Summaries without excluded items leave these shares initial.
`contributing_progress_counts` partitions contributing rows among not-started,
partial, complete, and over-received states. Its `total_item_count` equals
`item_count`; invalid progress items are excluded, and its percentages use
`item_count` as the denominator. Page counts sum the per-order counts and page
percentages are weighted across contributing items. This distribution can
differ from `matching_progress_counts`, which also includes rows that failed
base-unit conversion. Empty summaries leave its counts and percentages initial.
`contributing_progress_qty` reports order, received, open, and over-receipt
base-unit totals for each `not_started`, `partial`, `complete`,
`over_received`, and `invalid` status group. Summing each quantity across the
groups reconciles with its overall total, subject to decfloat34 rounding; page
groups sum the per-order groups. The invalid group is normally empty because
invalid raw-progress items do not contribute; it captures an unexpected status
value on an otherwise contributing row. Empty summaries leave the groups
initial. Each group also exposes `order_qty_total_share_pct`,
`received_qty_total_share_pct`, `open_qty_total_share_pct`, and
`over_rcpt_qty_total_share_pct`, showing its share of the corresponding overall
quantity total. Page shares are calculated from page totals, so they are
weighted across orders. Shares use only positive denominators, remain initial
when their corresponding total is zero, and sum to 100 before independent
two-decimal rounding.
Each summary also reports `received_pct_of_order_qty`,
`open_pct_of_order_qty`, and `over_rcpt_pct_of_order_qty`. Each percentage is
its corresponding aggregate quantity total divided by `order_qty_base_total`,
expressed as a percentage and rounded to two decimals; this is a weighted ratio
of totals, not an average of item percentages. Empty summaries leave the
percentages initial. The over-receipt percentage can exceed 100.
`over_rcpt_pct_of_received_qty` divides aggregate over-receipt by aggregate
received base quantity; it is also weighted across totals, is at most 100% for
valid contributing quantities, and remains initial when received quantity is
zero. Direct bulk reads leave these finish-window-only summaries initial.

## Production-order receipt progress quantities and status

Each production-order item returned by `READ_ORDERS_BULK` or
`READ_ORDERS_BY_FINISH_WINDOW` reports `open_quantity_order_unit`,
`over_receipt_qty_order_unit`, `over_receipt_pct_of_order_qty`,
`over_receipt_quantity_base`, `received_pct_of_order_qty`, and
`open_pct_of_order_qty`, plus
`receipt_progress_status`. The status is
`N` for not started, `P` for partial, `C` for fully received, and `O` for
over-received; the service exposes matching `c_receipt_progress_*` constants.
It remains initial when the order quantity is nonpositive or the received
quantity is negative. The derived quantities, percentages, and
status use the AFPO order and received quantities in the order unit,
independently of base-unit conversion. Open quantity is clamped at zero when
receipts meet or exceed the order quantity. For a valid not-started item, open
quantity equals the full order quantity and open percentage is 100.00.
Over-receipt quantity is the excess above the order quantity, or zero otherwise.
`over_receipt_pct_of_order_qty` is that excess divided by the order quantity,
expressed as a percentage before two-decimal display rounding. It is zero for a
valid item without an over-receipt and can exceed 100.00 when the excess is
greater than the order quantity.
When base-unit conversion succeeds, `over_receipt_quantity_base` reports the
positive excess converted with the AFPO order-to-base ratio. It is zero for a
valid item without an over-receipt, and remains initial when receipt progress
is invalid or base-unit conversion fails.
The received percentage can exceed 100 when receipts exceed the order quantity
and is returned to two decimal places. Open percentage is zero when receipts
meet or exceed the order quantity. A nonpositive order quantity or negative
received quantity leaves the five derived numeric values initial. These values
describe the item read and do not alter quantities or order state.
Each item also exposes `is_receipt_progress_valid`. It is true exactly when
the order quantity is positive and received quantity is nonnegative, and false
otherwise. This raw-quantity validity is independent of base-unit conversion
success and makes an initial progress status unambiguous to callers.
The result-level `receipt_progress_counts` structure provides
`not_started_item_count`, `partial_item_count`, `complete_item_count`,
`over_received_item_count`, and `invalid_item_count`. Each returned item
contributes to one count. `total_item_count` equals the sum of all five status
counts. The invalid count covers nonpositive order quantities
and negative received quantities. Finish-window summaries count every output
item on returned orders, including nonmatching detail items retained for
scope-drift reporting. Each returned order also exposes
`receipt_progress_counts`, calculated over all of that order's returned items;
an itemless order leaves the summary initial. Its five counts and
`total_item_count` reconcile to that order's detail rows. Each finish-window
order's all-item summary includes nonmatching rows retained for scope-drift
reporting, while its separate `matching_progress_counts` counts only items
marked `matches_finish_selection`; direct bulk reads leave this structure
initial. The page-level `finish_match_progress_counts` aggregates
those order summaries. Its five counts sum to the `finish_window_match_count`
values across returned orders; direct bulk reads leave it initial. Each
finish-window order's matching-summary `total_item_count` equals its
`finish_window_match_count`, and the page-level matching total equals the sum
of the per-order matching totals.
Each receipt-progress summary also exposes `not_started_pct`, `partial_pct`,
`complete_pct`, `over_received_pct`, and `invalid_pct`. Each percentage uses
`total_item_count` as its denominator, including invalid-quantity items, and is
rounded to two decimal places. Empty summaries leave the total and all
percentages initial.
Conversion failures do not change a valid raw-quantity progress state.

## Production confirmation posting-window read

`SEARCH_CONFIRMATIONS_BY_WINDOW` searches confirmations for production
and process orders containing one material at one plant over an inclusive
posting-date range. An optional `production_order` restricts the search to one
production or process order within the material and plant scope. An optional
`order_category` accepts `10` for production orders or `40` for process orders;
each confirmation row reports its category. An optional nonblank `order_type`
filters the AUFK order type exactly. Set
`filter_order_type` to `abap_true` to match the exact value including blank;
otherwise it must be `abap_false`, and a nonblank order type filters by
default. Each confirmation row reports `AUFK-AUART`. The selector is applied
before pagination, and the service validates its returned scope. Set
`exclude_deleted` to `abap_true` to omit confirmations unless both AUFK-LOEKZ
and the matching AFPO-XLOEK are blank; the flag accepts only
`abap_true` or `abap_false` and defaults to false. Confirmation rows expose
`order_deletion_indicator` from AUFK-LOEKZ. The repository applies this
scope before pagination, and the service validates the returned order
deletion indicator. An optional `operation_counter` filters one AFVC
internal counter and requires
`production_order`. Optional
`operation_counter_from` and `operation_counter_to` bounds filter AFVC-APLZL
inclusively before pagination; either bound can be omitted, paired bounds must
ascend, and active bounds require `production_order`. The exact counter
selector intersects with the range, and returned rows are checked against both
bounds. An optional `operation_number` restricts the search to one routing
operation. Optional
`operation_number_from` and `operation_number_to` bounds filter AFVC-VORNR
inclusively before pagination; either bound can be omitted, and paired bounds
must ascend. The exact `operation_number` selector intersects with the range,
and returned rows are checked against both bounds. Optional
`operation_sequence_from` and `operation_sequence_to` bounds filter AFVC-PLNFL
inclusively before pagination; either bound can be omitted, and paired bounds
must ascend. The exact sequence selector intersects with the range, and
returned rows are checked against both bounds. A noninitial
`operation_sequence` restricts the search to one routing sequence and may be
used with or without an operation number. Set `filter_operation_sequence` to
`abap_true` to match exactly, including the initial sequence value; otherwise
it must be `abap_false`, and a noninitial sequence still filters. Invalid flag
values fail before the read, and returned rows are checked against the selected
sequence.
The optional nonblank `resource_object_id` filters `AFVC-ARBID` and each row
reports that resource object ID. An optional nonblank `work_center` filters
`CRHD-ARBPL` through the `AFVC-ARBID` / `CRHD-OBJID` link; matching
confirmations and operation summaries report the selected work-center code.
Set `filter_work_center` to `abap_true` with a blank `work_center` to select
operations with no resolved work-center code. The flag accepts only
`abap_true` or `abap_false`; otherwise a nonblank code filters by default.
The repository applies this filter before pagination, and the service checks
returned scope. Base-unit operation summaries preserve the code as well. Set
an optional nonblank `work_center_plant` to filter `CRHD-WERKS`; returned
confirmations and operation summaries report the assigned work-center plant.
Set `filter_work_center_plant` to `abap_true` with a blank
`work_center_plant` to select operations without a resolved work-center plant.
This plant selector intersects with `work_center`, applies before pagination,
and is validated against returned rows. Its flag accepts only `abap_true` or
`abap_false`; base-unit operation summaries preserve the plant as well.
`work_center_summaries` is also returned on each page, grouped by work-center
plant and code. Blank assignments form a group; `confirmation_count` covers
only returned confirmations and sums to `returned_count`, excluding lookahead
and later-page rows. Each center's `quantity_summaries` separates totals by
`AFRU-MEINH`, so unlike units are never added together. Each unit row includes
its `confirmation_count`, gross `yield_quantity_total`, `rework_quantity_total`,
and `scrap_quantity_total`, plus `yield_non_reversed_total`,
`rework_non_reversed_total`, and `scrap_non_reversed_total`, which omit
confirmations flagged as reversed. The unit counts sum to the work-center
confirmation count. Each unit row also reports its own first and last dated
posting, final, partial, and reversed confirmation counts, and percentages.
Final and partial counts partition that unit's confirmation count; reversal
count is independent, and percentages use the unit count as their denominator.
Work-center groups also report `first_posting_date` and
`last_posting_date` among dated confirmations, plus final, partial, and
reversed counts and percentages. Final and partial counts partition the
confirmation count; reversal count is independent. Percentages use the
confirmation count as their denominator. The base-unit window result also returns
`base_work_center_summaries`, grouped by plant, code, and base unit. It reports
`confirmation_count`, `yield_quantity_base_total`,
`rework_quantity_base_total`, `scrap_quantity_base_total`, and the corresponding
`yield_base_non_reversed_total`, `rework_base_non_reversed_total`, and
`scrap_base_non_reversed_total`. It also includes `first_posting_date`,
`last_posting_date`, the final, partial, and reversed confirmation counts, and
their percentages. Work-center summaries, per-unit rows, base-unit rows,
operation summaries, and order summaries also report
`execution_start_count` and `execution_finish_count`, counting
returned confirmations with a noninitial AFRU-ISDD or AFRU-IEDD respectively.
`execution_start_pct` and `execution_finish_pct` divide those counts by the
summary's `confirmation_count` and report percentages to two decimal places;
they remain zero when the summary has no confirmations.
`first_execution_start_date` and `first_execution_start_time` identify the
earliest dated start, ordered by date then time; `last_execution_finish_date`
and `last_execution_finish_time` identify the latest dated finish with the same
ordering. A present execution date with time `000000` counts as midnight.
`exec_duration_seconds_total` sums elapsed whole seconds for complete, valid
start/finish date-time pairs; `exec_duration_count` counts those pairs.
`exec_duration_seconds_avg` divides the total by that valid-pair count and is
zero when the group has no valid duration. `valid_exec_duration_pct` divides
`exec_duration_count` by the summary's `confirmation_count`, rounded to two
decimal places; it is zero when the summary has no confirmations.
`exec_duration_seconds_min` and `exec_duration_seconds_max` report the shortest
and longest valid interval in seconds; both are zero when the group has no
valid duration.
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
`zero_exec_duration_count` counts valid intervals whose start and finish are
the same instant. `zero_exec_duration_pct` reports that count as a share of the
summary's `confirmation_count`, rounded to two decimal places; both fields are
zero when there are no zero-duration intervals. Zero-duration rows remain part
of `exec_duration_count` and are included in the valid-interval totals and
minimum/maximum.
`invalid_exec_duration_count` counts complete pairs with invalid dates or
times, or a finish before its start; `invalid_exec_duration_pct` divides that
count by `confirmation_count`, rounded to two decimal places. Rows missing
either execution date are omitted from duration totals and counts;
`missing_exec_duration_count` and `missing_exec_duration_pct` report their
count and share of `confirmation_count`, with zero for an empty group. Valid,
invalid, and missing counts partition `confirmation_count`. Duration totals include reversed
confirmations and can double-count overlapping intervals. Work-center
summaries also report `exec_covered_seconds`, the union of valid execution
intervals with overlaps merged and idle gaps excluded. The center-level value
combines confirmation units; each `quantity_summaries` row computes the union
within its own unit. Base work-center summaries report the same union within
their base unit. Unit unions can overlap across units and should not be summed
to derive the center union. Operation summaries also report the union within
each operation and confirmation-unit group; order summaries report it within
each production-order and confirmation-unit group. Base operation and order
summaries report the union within each base-unit group, merging source-unit
intervals converted to that unit. Each group computes its own union, so unions
from different operation, order, work-center, or unit groups should not be
summed as though they shared a scope. Reversed confirmations remain included
in `exec_covered_seconds`.
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
independent rounding.
`exec_overlap_excess_seconds` reports the difference between a
group's summed valid duration and its `exec_covered_seconds`. It represents
duration counted beyond the covered-time union, so a 30-second triple overlap
contributes 60 excess seconds; touching or disjoint intervals contribute none.
Each summary also reports `exec_peak_concurrency`, the maximum number of
simultaneously active valid, positive-duration intervals in that group. The
intervals use half-open boundaries, so a finish coinciding with another start
does not increase concurrency. Missing, invalid, and zero-duration intervals
do not count, and the value is zero when the group has no positive interval.
`exec_peak_concurrency_secs` reports the elapsed time during which active
interval count equaled that group's peak concurrency. It sums separate segments
at the maximum; when the group has no positive interval, the value is zero.
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
`exec_idle_gap_seconds` reports the uncovered elapsed time inside the envelope
from the earliest start to the latest finish of those intervals. It equals
that envelope's elapsed seconds minus `exec_covered_seconds`; time before the
first or after the last positive interval is not counted, and zero-duration
rows do not set the envelope. A continuous chain of touching or overlapping
intervals has zero idle gap. No work calendar or shift availability is applied.
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
intervals' envelope when two or more valid positive-duration intervals were
active. Each instant counts once, so a 30-second triple overlap contributes 30
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
These page-level coverage values still do not measure utilization because
shift calendars and availability are not applied. The spans, totals, union,
pairwise overlap, overlap-pair summaries, single/two/three-plus concurrency
shares, average concurrency, peak-concurrency episodes, idle gap, overlap wall
time, and group-wide overlap episodes use only returned page rows. These
summaries stay initial or zero when no matching execution data exists.
Operation summaries report these metrics within each operation and
confirmation-unit group; order summaries roll them up by production order and
confirmation unit. Their duration counts and totals aggregate the complete
rows in each group, while first-start and last-finish values select the
earliest and latest date/time pair. Set
`filter_resource_object_id` to
`abap_true` to select the exact initial value for operations without an assigned
resource; otherwise it must be `abap_false`, and a nonblank ID filters by
default. The service validates the flag and returned resource scope.
`AFVC-ARBID` is an SAP-internal object ID. For work-center assignments,
`CRHD-OBJID` identifies the same object and `CRHD-ARBPL` contains the
work-center identifier.
An optional nonblank suboperation number narrows the search to that
suboperation and requires the operation number. By default, an initial
`operation_suboperation` omits that filter, including the base step and every
suboperation. Set `filter_operation_suboperation` to `abap_true` to match the
exact initial value for the base step only; this flag also requires a selected
operation number. Otherwise the flag must be `abap_false`, and a nonblank
suboperation continues to filter. Optional
`operation_suboperation_from` and `operation_suboperation_to` bounds filter
AFVC-UVORN inclusively before pagination; either bound can be omitted, paired
bounds must ascend, and active bounds require `operation_number`. The exact
suboperation selector intersects with the range, and returned rows are checked
against both bounds. Invalid flags and ranges fail before the read.
An optional nonblank `control_key` filters by
the AFVC routing control key and can be combined with or used without the
operation filters. Set `filter_control_key` to `abap_true` to match the exact
control key including blank; otherwise it must be `abap_false`, and a nonblank
key continues to filter. Invalid flag values fail before the read, and returned
rows are checked against the selected key. Pass `operation_description` to
match exact AFVC-LTXA1 operation text. Nonblank text filters by default; set
`filter_operation_description` to `abap_true` to select the exact blank text.
Otherwise the flag must be `abap_false`. Invalid flags fail before the read,
the description filter applies before pagination, and returned rows are checked
against the selected description. An optional nonblank `quantity_unit`
restricts rows to one AFRU
confirmation unit. When initial, it omits the filter by default, so results can
contain multiple units and summaries keep them separate. Set
`filter_quantity_unit` to `abap_true` to match the exact unit including blank;
otherwise it must be `abap_false`, and a nonblank unit continues to filter.
Invalid flag values fail before the read, and returned rows are checked against
the selected unit. An optional nonblank `entered_by` filters confirmations by
AFRU-ERNAM. Set `filter_entered_by` to `abap_true` to match the exact entered-by
value including blank; otherwise it must be `abap_false`, and a nonblank value
continues to filter. Invalid flag values fail before the read, and returned
rows are checked against the selected user. The optional `entry_date_from` and
`entry_date_to` pair filters AFRU-ERSDA inclusively before pagination; provide
both valid dates in ascending order or omit both. Returned confirmation rows
expose `entry_date`, and the service checks it against the selected range. This
entry date identifies when the confirmation was entered, separately from its
posting date. The optional `last_change_date_from` and `last_change_date_to`
pair filters AFRU-LAEDA inclusively before pagination; provide both valid dates
in ascending order or omit both. Rows expose `last_change_date`, which the
service validates against the selected range, and `changed_by` from AFRU-AENAM.
Optional `execution_start_date_from` and `execution_start_date_to` bounds
filter AFRU-ISDD inclusively before pagination. Either bound may be omitted;
active bounds must be valid dates, and paired bounds must ascend. Active bounds
omit confirmations without an actual execution start date. The service checks
returned start-date scope.
Set `filter_execution_start_time` to `abap_true` with both valid
`execution_start_time_from` and `execution_start_time_to` values to filter
AFRU-ISDZ inclusively. The time range applies across matching execution dates
and requires a nonblank actual start date; `000000` is valid midnight. The
bounds must ascend. When disabled, the flag must be `abap_false` and both bounds
must be initial.
Optional `execution_finish_date_from` and `execution_finish_date_to` bounds
filter AFRU-IEDD inclusively before pagination. Either bound may be omitted;
active bounds must be valid dates, and paired bounds must ascend. Active bounds
omit confirmations without an actual execution finish date. Rows expose
AFRU-ISDD/ISDZ and AFRU-IEDD/IEDZ as `execution_start_date`,
`execution_start_time`, `execution_finish_date`, and `execution_finish_time`,
preserving actual execution timing separately from posting date. The service
validates returned timestamps and both execution-date scopes.
Set `filter_execution_finish_time` to `abap_true` with both valid
`execution_finish_time_from` and `execution_finish_time_to` values to filter
AFRU-IEDZ inclusively. The time range applies across matching execution dates
and requires a nonblank actual finish date; `000000` is valid midnight. The
bounds must ascend. When disabled, the flag must be `abap_false` and both bounds
must be initial.
An optional nonblank `changed_by` filters the last-change user; set
`filter_changed_by` to `abap_true` to match exactly, including blank. Otherwise
the flag must be `abap_false`, and nonblank values continue to filter. Invalid
flags fail before the read, and returned rows are checked against the selected
user. `filter_entry_time` enables an inclusive time-of-day range on AFRU-ERZET;
when enabled, both valid bounds are required and must be in ascending order.
`000000` is a valid midnight bound. Disabled filters require initial bounds.
The time range applies on every matching entry date, can be combined with the
entry-date range, and does not wrap across midnight. Confirmation rows expose
`entry_time`, which the service validates against the selected range.
`positive_yield_only`,
`positive_rework_only`, and
`positive_scrap_only` select rows with a positive quantity in the corresponding
AFRU field; when multiple flags are true, every selected quantity must be
positive. The yield, rework, and scrap ranges use respectively
`filter_yield_quantity_from` / `filter_yield_quantity_to`,
`filter_rework_quantity_from` / `filter_rework_quantity_to`, and
`filter_scrap_quantity_from` / `filter_scrap_quantity_to`. They apply inclusive
lower and upper bounds to `AFRU-LMNGA`, `AFRU-RMNGA`, and `AFRU-XMNGA` before
pagination. These raw quantity bounds require a single confirmation unit scope:
provide a nonblank `quantity_unit` or set `filter_quantity_unit` to
`abap_true` to select an exact unit, including blank. This prevents comparing
values from different units. Either bound may be enabled alone, including a
zero bound; disabled values must be initial, and two active bounds must be
ascending. The service checks each returned row against every active bound. An
optional `confirmation_number` restricts
results to one AFRU
confirmation; `confirmation_counter` narrows that selection to one counter and
requires the confirmation number. Optional `confirmation_counter_from` and
`confirmation_counter_to` bounds filter AFRU-RMZHL inclusively before
pagination; either bound can be omitted, paired bounds must ascend, and active
bounds require `confirmation_number`. The exact counter selector intersects
with the range, and returned rows are checked against both bounds. An initial
suboperation filter includes the base step and every
suboperation for the selected operation.
Confirmation rows include the AFVC operation counter, operation/suboperation
numbers, sequence, operation description, control key, resource object ID from
AFVC-ARBID, work-center code from CRHD-ARBPL, entered-by user, order category, and order type from AUFK-AUART. They
also include `scope_material` and `scope_plant` from the matching AFPO item.
They expose actual execution start/finish dates and times from AFRU-ISDD/ISDZ
and AFRU-IEDD/IEDZ. The
service verifies material and plant scope on every returned row before mapping.
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
Set `iv_order_category` to `10` for production orders or `40` for process
orders. Other noninitial values are rejected before the repository read; the
repository filters AUFK before resolving operations, and the service validates
returned category scope. Pass `iv_order_type` to restrict number-based bulk
confirmation reads to one exact AUFK-AUART value. An initial value omits the
filter; the repository filters orders before resolving operations, and the
service validates the returned type scope. Number-based bulk rows also expose
work-center code and plant from CRHD-ARBPL and CRHD-WERKS. Pass
`iv_work_center` or `iv_work_center_plant` for exact values; nonblank values
filter by default. Set `iv_filter_work_center` or
`iv_filter_work_center_plant` to `abap_true` to match blank values, including
AFVC resources without a CRHD row. Both flags accept only `abap_true` or
`abap_false`; repository filtering runs before pagination, and the service
validates returned work-center scope. Pass `iv_operation_counter` to
select one exact AFVC-APLZL
counter; an initial value omits it. The repository applies both selectors
before returning rows, and the service validates both result scopes. Optional
`iv_posting_date_from` and `iv_posting_date_to` bounds select confirmations by
inclusive AFRU-BUDAT dates. Each noninitial bound must be a valid Gregorian
date; either bound may be omitted, and two active bounds must be ascending. The
repository applies date bounds before operation lookup, and the service checks
every returned posting date. Optional `iv_entry_date_from` and
`iv_entry_date_to` apply inclusive AFRU-ERSDA bounds independently of posting
date; each active bound must be a valid Gregorian date, and two bounds must be
ascending. Active entry-date bounds omit confirmations without an entry date.
The repository applies the entry-date scope before operation lookup, and the
service checks returned entry dates. Pass `iv_entered_by` or `iv_changed_by` to
filter exact AFRU users; nonblank values filter by default. Set
`iv_filter_entered_by` or `iv_filter_changed_by` to `abap_true` to select the
exact blank user. These flags accept only `abap_true` or `abap_false`, and the
repository and service validate the user scope. Optional
`iv_last_change_date_from` and `iv_last_change_date_to` bounds filter AFRU-LAEDA
inclusively. Each active bound must be a valid Gregorian date; either bound may
be omitted, and two active bounds must ascend. An active bound excludes
confirmations without a last-change date. The repository filters before
operation lookup and the service checks the returned date scope. Repeat the
same order list and filters on each cursor continuation request. Set
`iv_filter_entry_time` to `abap_true` and provide both valid `iv_entry_time_from`
and `iv_entry_time_to` bounds to select AFRU-ERZET inclusively. Midnight
`000000` is valid; bounds must ascend. When disabled, both values must be
initial. The repository filters before operation lookup and pagination, and the
service checks every returned time. Set `iv_execution_start_date_from` and/or
`iv_execution_start_date_to` for inclusive AFRU-ISDD bounds;
`iv_execution_finish_date_from` and/or `iv_execution_finish_date_to` select
AFRU-IEDD. Either endpoint may be omitted; active bounds must be valid
Gregorian dates, paired bounds must ascend, and active ranges omit confirmations
without the corresponding actual execution date. The repository applies these
selectors before operation lookup and pagination, and the service checks every
returned execution date. Set `iv_filter_execution_start_time` or
`iv_filter_exec_finish_time` to `abap_true` with both corresponding valid
`*_time_from` and `*_time_to` values to filter AFRU-ISDZ or AFRU-IEDZ
inclusively. A time filter requires its actual execution date; midnight
`000000` is valid and bounds must ascend. Disabled flags require initial time
bounds. Both flags accept only `abap_true` or `abap_false`. The repository
filters before pagination, and the service validates returned timestamp scope.
Pass `iv_quantity_unit` to restrict rows to one AFRU confirmation unit; a nonblank
unit filters by default. Set `iv_filter_quantity_unit` to `abap_true` to select
confirmations whose unit is blank exactly. The flag accepts only `abap_true` or
`abap_false`, and returned unit scope is checked by the service. The repository
applies the unit filter before operation lookup and pagination. Set
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
Repository filters run before operation lookup and pagination, and the service
validates returned quantities against every active selector.
Pass `iv_operation_counter` to select one exact AFVC-APLZL counter. Set
`iv_operation_counter_from` and/or `iv_operation_counter_to` for inclusive
AFVC-APLZL bounds; initial values omit their bound, paired active bounds
must ascend, and the exact counter selector intersects with the range. The
repository filters before pagination, and the service validates returned
counters. Pass `iv_operation_number` to select one exact AFVC-VORNR value;
it can be combined with the operation-counter selector. An initial value
omits this filter. Set `iv_operation_number_from` and/or
`iv_operation_number_to` for inclusive AFVC-VORNR bounds; initial values omit
their bound, and noninitial bounds must ascend when both are supplied. The
exact `iv_operation_number` selector intersects with the range. The repository
filters before pagination, and the service validates returned operation
numbers. Pass `iv_control_key`,
`iv_operation_description`, or
`iv_resource_object_id` to filter by exact AFVC metadata; nonblank values filter
by default. Set the matching `iv_filter_control_key`,
`iv_filter_op_description`, or `iv_filter_resource_object_id` flag to
`abap_true` to match an exact blank value. Each flag accepts only `abap_true`
or `abap_false`. Resource IDs are AFVC-ARBID internal object IDs. The
repository filters these fields before paging, and the service validates every
returned metadata value.
Pass `iv_operation_sequence` to select one routing sequence; nonblank values
filter by default, and `iv_filter_operation_sequence = abap_true` selects the
exact initial sequence. Set `iv_operation_sequence_from` and/or
`iv_operation_sequence_to` for inclusive AFVC-PLNFL bounds; initial values
omit their bound, paired active bounds must ascend, and the exact sequence
selector intersects with the range. The repository filters before
pagination, and the service validates returned sequence scope. Pass
`iv_suboperation_number` to select one
suboperation; `iv_filter_suboperation_number = abap_true` selects base
operations only. Set `iv_suboperation_number_from` and/or
`iv_suboperation_number_to` for inclusive AFVC-UVORN bounds; initial values omit
their bound, and paired active bounds must ascend. An active range requires an
exact noninitial `iv_operation_number`; the exact suboperation selector
intersects with the range. Both flags accept only `abap_true` or `abap_false`,
and the service validates returned scope. The repository applies these
selectors before mapping and pagination.
Pass `iv_confirmation_number` to select one AFRU confirmation; optionally pass
`iv_confirmation_counter` to select one counter, which requires a confirmation
number. The repository filters this pair before operation resolution, and the
service validates both returned fields.
Reversed rows are included by default. Set `iv_exclude_reversed` to
`abap_true` to omit them, or set `iv_reversed_only` to `abap_true` to return
only reversed rows. Both flags accept only `abap_true` or `abap_false` and are
mutually exclusive. The repository filters AFRU before operation resolution,
and the service validates returned reversal scope.
Set `iv_final_only` to keep final confirmations or `iv_partial_only` to keep
confirmations not marked final. Both flags default to false, accept only
`abap_true` or `abap_false`, and are mutually exclusive. The repository filters
these statuses before operation resolution, and the service validates returned
status scope.
Number-based bulk confirmations leave these scope fields initial because they
do not have a material/plant search scope. `iv_maximum_results` limits each
page to 1 through 500 rows and defaults to 500. The repository applies the
four-field keyset cursor and returns at most one extra row so the service can
set `is_truncated`. Rows use the stable order production order ascending,
posting date descending, confirmation number descending, and confirmation
counter descending. When `is_truncated` is true, pass all four `next_*` values
back as `iv_after_production_order`, `iv_after_posting_date`,
`iv_after_confirmation`, and `iv_after_confirmation_counter`. Posting date,
confirmation number, and counter must be noninitial and the order must be in
the requested order list. Supplying only part of the cursor, an invalid posting
date, or an order outside the request fails before the repository read. Each
requested order reports the number of confirmations returned on that page, and
result-level `returned_count` sums those page counts. Reversed confirmations
are retained with their reversal indicator by default; `iv_exclude_reversed`
returns only non-reversed rows, while `iv_reversed_only` returns only reversed
rows. `iv_final_only` limits results to
final confirmations, and `iv_partial_only` returns confirmations not marked
final; these status filters are mutually exclusive.
final rows. Before
returning rows, the service checks the repository's limit-plus-one bound,
requested filters, inclusive date range, cursor boundary, and stable tuple
ordering. Each response also groups the returned page by production order,
AFVC operation counter, operation number, sequence, suboperation, and
confirmation unit. Summaries echo the order category and AUFK-AUART
`order_type`. They include `confirmation_count`, `final_confirmation_count`,
`partial_confirmation_count`, and `reversed_confirmation_count`, raw
yield/rework/scrap totals, and
corresponding non-reversed totals
(`yield_non_reversed_total`, `rework_non_reversed_total`, and
`scrap_non_reversed_total`). Partial counts include confirmations whose
`is_final` is not `abap_true`; final and partial counts partition the returned
rows, while reversed counts overlap them. Raw totals include reversed rows; non-reversed
totals include only returned rows whose `is_reversed` is not `abap_true`.
Each summary also reports `final_confirmation_pct`,
`partial_confirmation_pct`, and `reversed_confirmation_pct`, each divided by
`confirmation_count` and rounded to two decimal places. Final and partial
percentages may differ from 100.00 by 0.01 due to independent rounding;
reversed percentage is an overlapping share.
Summaries also carry the operation description, control key, and assigned
`resource_object_id`. Base operation summaries preserve the same resource ID
when they merge confirmation units.
`first_posting_date` and `last_posting_date` identify the earliest and latest
posting dates among its returned confirmations. Operation summaries also
report execution-start and execution-finish counts and percentages, first-start
and last-finish date/time pairs, and valid and invalid duration counts with
total elapsed seconds. Execution percentages use the operation summary's
confirmation count; duration totals include reversed confirmations. These
summaries exclude the
lookahead row and later pages. The same page also includes `order_summaries`,
grouped by production order and confirmation unit so quantities from different
units are never combined. Each order/unit summary reports category, first and
last posting dates, `confirmation_count`, `final_confirmation_count`,
`partial_confirmation_count`, and `reversed_confirmation_count`, plus yield,
rework, and scrap totals including and excluding reversed rows. The order
summaries derive from the returned operation summaries and reconcile their
counts and totals within each order/unit group. They also report execution
coverage and span fields, plus valid and invalid duration counts and total
elapsed seconds using all returned rows in that order/unit group. They exclude
lookahead and later pages. Invalid flag values fail before the read. Each
page is an independent snapshot: new or changed postings can affect subsequent
pages.
Each result carries a UTC `snapshot_timestamp`, captured after the repository
read completes. The base-unit wrapper preserves it in its raw result. This
marks read completion, not a transactionally consistent snapshot; later pages
are independent reads.
`SEARCH_CONF_WINDOW_BASE_UNIT` returns the same paged result together with one
base-quantity row for each returned confirmation. It preserves the raw
confirmation and converts yield, rework, and scrap from the AFRU confirmation
unit to the selected material's base unit, caching the material-unit ratio per
unit during the read. Unknown ratios, quantity overflow, and nonzero values
that round to zero fail the request without returning partial converted rows.
The raw operation summaries retain their source-unit grouping and totals; the
base-unit result also provides `base_operation_summaries`, merging source units
for the same operation and reporting converted yield, rework, and scrap totals
with separate reversed-inclusive and non-reversed totals, date spans, the same
four confirmation counts, and execution coverage, span, and duration metrics.
It also provides `base_order_summaries`,
grouped by production order and base unit while merging all confirmation units
and operations. These summaries expose the same four counts and execution
metrics and reconcile with the operation summaries, preserving the
reversed-inclusive and non-reversed distinction. Operation and order summaries
in both unit modes include the same three two-decimal percentages over
`confirmation_count`.

## Production-order bulk create and change stop-on-failure

`CREATE_ORDERS_BULK` and `CHANGE_ORDERS_BULK` accept the same optional
stop-on-failure policy. Both prevalidate all requests before calling SAP and
preserve every input row in caller order. The default continues after failed
API or commit results; `abap_true` stops after the first failure, marks later
rows `is_skipped`, and reports `skipped_count` separately from `failed_count`.
`stopped_on_failure` remains true when the failure occurs on the last row.
Earlier successful independent commits remain committed. Invalid flag values
raise before any BAPI call.

## Production-order release bulk stop-on-failure

`RELEASE_ORDERS_BULK` and `RELEASE_OPERATIONS_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. Both validate the complete
request set before writes and return all rows in caller order. When enabled,
the first failed release API result or commit stops later calls; those rows are
marked `is_skipped` and counted separately. `stopped_on_failure` is set even if
the failure occurs on the last row. Earlier independent commits remain
committed, and invalid flag values raise before the first release call.

## ATP-gated production-order release bulk stop-on-failure

`RELEASE_ORDERS_BULK_AFTER_ATP` accepts `iv_stop_on_failure`, defaulting to
`abap_false`. It validates the complete readiness response before any release
call and preserves every result row in caller order. By default, ready orders
continue after ATP-blocked rows. With stop-on-failure enabled, the first ATP
block or failed release/commit ends processing; a release failure in an earlier
ready order takes precedence over a later readiness block. Unattempted rows are
marked `is_skipped` and counted separately from failures. `atp_blocked_count`
continues to report readiness diagnostics for skipped rows. Earlier independent
commits remain committed, and incomplete or malformed checker results block all
writes before processing.

## Cost-center movement bulk stop-on-failure

`ISSUE_COST_CENTERS_BULK`, `ISSUE_COST_CENTERS_BULK_UOM`,
`RETURN_COST_CENTERS_BULK`, and `RETURN_COST_CENTERS_BULK_UOM` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They prevalidate the full
request, preserve every result row in caller order, and continue after movement
failures by default. When enabled, the first failed movement stops later posts;
unattempted rows are marked `is_skipped` and counted separately from failures.
`stopped_on_failure` is set even when the failed movement is the last request.
The UOM forms validate the flag before conversion and convert all requests
before the first post. Earlier successful independent commits remain committed.

## Sales-order movement bulk stop-on-failure

`ISSUE_SALES_ORDERS_BULK`, `ISSUE_SALES_ORDERS_BULK_UOM`,
`RETURN_SALES_ORDERS_BULK`, and `RETURN_SALES_ORDERS_BULK_UOM` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They prevalidate all requests
before movement calls, preserve caller-order result rows, and continue after
failures by default. When enabled, the first failed movement stops later posts;
unattempted rows are marked `is_skipped` and counted separately from failures.
The summary sets `stopped_on_failure` even when the failed movement is last.
UOM forms validate the flag before conversion and convert all requests before
the first post. Earlier successful independent commits remain committed.

## Sales-order stock transfer bulk stop-on-failure

`TRANSFER_SALES_STOCK_BULK`, `TRANSFER_SALES_STOCK_BULK_UOM`,
`TRANSFER_TO_SALES_STOCK_BULK`, and `TRANSFER_TO_SO_STOCK_BULK_UOM` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They prevalidate the complete
request and preserve caller-order result rows. When enabled, the first failed
movement stops later transfers; unattempted rows are marked `is_skipped` and
counted separately from failures. The summary sets `stopped_on_failure` even
when the failed transfer is last. UOM forms validate the flag before converting
all requests, and earlier successful independent commits remain committed.

## Project WBS movement bulk stop-on-failure

`ISSUE_PROJECT_WBS_BULK`, `ISSUE_PROJECT_WBS_BULK_UOM`,
`RETURN_PROJECT_WBS_BULK`, and `RETURN_PROJECT_WBS_BULK_UOM` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They validate the complete
request before writes and preserve every row in input order. The default
continues after movement failures; when enabled, the first failed posting stops
later calls and marks unattempted rows as `is_skipped`. `skipped_count` is
separate from `failed_count`, and `stopped_on_failure` is set even when the
failed row is last. UOM methods validate the flag before converting all
requests. Earlier successful independent commits remain committed.

## Project reservation issue and return bulk stop-on-failure

`ISSUE_RESERVED_WBS_ITEMS_BULK` and `RETURN_RESERVED_WBS_ITEMS_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They validate the option
before WBS/item scope reads and preserve result rows in caller order. By
default, processing continues after a failed reservation group; when enabled,
later groups are skipped and counted separately from failures. Earlier
successful independent commits remain committed.

## Purchase-order receipt and return bulk stop-on-failure

`RECEIVE_PURCHASE_ORDERS_BULK`, `RECEIVE_PO_ORDERS_BULK_UOM`,
`RETURN_PURCHASE_ORDERS_BULK`, and `RETURN_PO_ORDERS_BULK_UOM` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They prevalidate requests
before writes, preserve every result row in caller order, and continue after
failures by default. When enabled, the first failed movement stops later posts;
unattempted rows are marked `is_skipped` and counted separately from failures.
`stopped_on_failure` remains true when the failed movement is last. UOM forms
validate the flag before converting all requests. Earlier independent commits
remain committed.

## Purchase-order independent bulk write stop-on-failure

`CREATE_ORDERS_BULK`, suggestion and requisition grouped creation, item
deletion, delivery completion, schedule changes, and item quantity changes
accept `iv_stop_on_failure`, defaulting to `abap_false`. Base-unit bulk
quantity and schedule wrappers validate and convert the full input before
forwarding the option. All rows are prevalidated before SAP writes. When
enabled, the first failed PO operation stops later calls; each unattempted PO
remains in input order with `is_skipped`, while result rows distinguish
`is_attempted`. The bulk summary reports successful, failed, and skipped row
counts and sets `stopped_on_failure`, including when the failed row is last.
Earlier independent commits remain committed. Suggestion and requisition
references remain on skipped request rows so partial batches can be reconciled.

## Production-order receipt bulk stop-on-failure

`RECEIVE_PROD_ORDERS_BULK` and `RECEIVE_PROD_ORDERS_BULK_UOM` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They validate all requests
before posting and preserve each result row in caller order. The default
continues after receipt failures. When enabled, the first failed receipt stops
later posts and marks unattempted rows `is_skipped`; `skipped_count` is separate
from `failed_count`, and `stopped_on_failure` remains true when the failure is
last. The UOM form validates the flag before converting the full request.
Earlier successful independent commits remain committed.

## Production-order component movement bulk stop-on-failure

`RETURN_PROD_ORDERS_BULK`, `RETURN_PROD_ORDERS_BULK_UOM`,
`ISSUE_UNPLANNED_PROD_BULK`, and `ISSUE_UNPLANNED_PROD_BULK_UOM` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They prevalidate requests
before writes and preserve input-order result rows. The default continues after
movement failures. When enabled, the first failed movement stops later posts;
unattempted rows are marked `is_skipped` and counted separately from failures.
`stopped_on_failure` remains true when the failed row is last. UOM forms
validate the flag before conversion and convert the full request. Earlier
successful independent commits remain committed.

## Production-component reservation bulk stop-on-failure

`ISSUE_REMAINING_BULK` and `RETURN_REMAINING_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They fully validate selected
component keys and quantities before posting one movement per reservation.
When enabled, the first failed issue or return stops later groups; unattempted
result rows remain in caller order with `is_skipped`, `skipped_count`, and
`stopped_on_failure`. The summary counts skipped groups separately from failed
groups, including when the failed group is last. Earlier successful reservation
commits remain committed. `CANCEL_COMPONENT_ISSUES_BULK` forwards the same
option to bulk material-document cancellation. Bulk issue and return methods
that post all supplied components in one material document remain one posting
unit and do not split that document into per-component commits.

## Production-order confirmation bulk stop-on-failure

`CANCEL_CONFIRMATIONS_BULK` and `CREATE_CONFIRMATIONS_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They prevalidate all requests
and preserve every row in caller order. The first failed API result or commit
stops later calls when enabled; skipped rows have `is_skipped`, are counted
separately, and set `stopped_on_failure` even if no later row remains. Earlier
independent commits remain committed. Bulk confirmation creation defers commit
until the service verifies the returned order, operation, and sequence against
the request; mismatches roll back before commit. Invalid flag values raise
before any BAPI call.

## Atomic production-order confirmation simulation

`CREATE_CONFIRMATIONS_ATOMIC` forwards `iv_test_run` to the standard
`BAPI_PRODORDCONF_CREATE_TT` `TESTRUN` parameter for every ticket. Simulation
does not commit or roll back the SAP LUW. A successful simulated ticket may
have no confirmation number or counter; the adapter treats missing keys as an
error only for live writes. The group reports simulation state separately from
commit and rollback state.

## Production-order lifecycle bulk stop-on-failure

Technical completion, deletion-flag, order-close, and deletion-indicator bulk
methods accept `iv_stop_on_failure`, defaulting to `abap_false`. They validate
all order numbers before writing and preserve result rows in caller order. When
enabled, the first failed API result or commit stops later calls; unattempted
rows are marked `is_skipped` and counted separately. The summary sets
`stopped_on_failure` even when no rows remain, and earlier independent commits
remain committed. Invalid flag values raise before the first API call.

## Material-document cancellation bulk stop-on-failure

`CANCEL_MATERIAL_DOCUMENTS_BULK` accepts `iv_stop_on_failure`, defaulting to
`abap_false`. It validates the entire request list before cancellation and
continues after independent reversal failures by default. When enabled, the
first failed reversal stops later calls; unattempted rows are marked
`is_skipped`, with `skipped_count` separate from `failed_count`, and
`stopped_on_failure` remains true even when the failed reversal is last. Atomic
cancellation continues to roll back all staged reversals on an API or commit
failure and marks unattempted documents skipped.

## STO cancellation pair bulk stop-on-failure

`CANCEL_ISSUED_STO_PAIRS`, `CANCEL_RECEIVED_STO_PAIRS`, and
`CANCEL_STO_RECEIPT_CHAIN_PAIRS` accept `iv_stop_on_failure`, defaulting to
`abap_false`. They prevalidate the full input and document keys before
cancellation. The default continues after ineligible pairs or failed
reversals. When enabled, the first ineligible pair or failed reversal stops
later cancellation calls; later rows are marked `is_skipped`, and successful,
failed, and skipped counts are reported separately. Atomic cancellation still
rolls back all staged reversals on an API or commit failure.

## STO issue and receipt pair bulk stop-on-failure

`ISSUE_CREATED_STO_PAIRS` and `RECEIVE_ISSUED_STO_PAIRS` accept
`iv_stop_on_failure`, defaulting to `abap_false`. Both validate the complete
input and prepare eligible PO items before any movement call. The default
continues after ineligible source rows or failed movements. When enabled, the
first failed or ineligible pair stops later postings; unattempted rows are
marked `is_skipped`, and successful, failed, and skipped counts are returned
separately. Earlier independent commits remain committed. Atomic mode still
stages the eligible movements in one LUW and rolls back the group on a
movement or commit failure. Issue and receipt results preserve rows already
marked skipped by the preceding STO creation or issue stage and do not submit
those rows to SAP.

## STO chain retry bulk stop-on-failure

`RETRY_STO_CHAIN_ISSUE_PAIRS`, `RETRY_STO_CHAIN_RECEIPT_PAIRS`, and
`RETRY_STO_CHAIN_PAIRS` accept `iv_stop_on_failure`, defaulting to
`abap_false`. They preserve completed pairs and prevalidate retryable document
keys before writes. The default continues after a failed retry. When enabled,
the first failed or ineligible retry stops later eligible retries in the
receipt-first execution order; unfinished rows are marked `is_skipped` and
counted separately from successful and failed rows. Atomic retry rolls back
the staged retry group, while reversals committed by an earlier attempt remain
committed. The receipt retry result remains incomplete until its separate 351
retry also succeeds.

## STO deletion and delivery completion pair stop-on-failure

`MARK_STO_PAIRS_FOR_DELETION` and `MARK_STO_PAIRS_DELIV_COMPLETE` accept
`iv_stop_on_failure`, defaulting to `abap_false`. The default continues after
ineligible orders and failed PO changes. When enabled, the first ineligible
order or failed change stops later updates; untouched rows are marked
`is_skipped`, with successful, failed, and skipped counts reported separately.
Non-atomic changes committed before the failure remain committed. Atomic
preflight failures perform no changes, while a failed staged update rolls back
the group and marks unattempted eligible rows skipped.

## Cost-center reservation bulk stop-on-failure

`RESERVE_COST_CENTERS_BULK`, `RESERVE_CC_BULK_BY_DATE`, and
`RESERVE_CC_FEFO_DATE_BULK` accept `iv_stop_on_failure`, defaulting to
`abap_false`. They validate all demands and shared options before writing.
When enabled, the first failed reservation stops later independent creates in
execution order; unattempted rows retain `is_skipped`, with separate success,
failure, and skipped counts. Priority, required-date, and FEFO date ordering
remain the execution order while results retain caller order. Earlier
successful independent reservations stay committed.

## Cost-center reservation deletion bulk stop-on-failure

`DELETE_RESERVATION_ITEMS_BULK` and `DELETE_RESERVATIONS_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They validate the complete
request before deletion. When enabled, the first item or document deletion
failure stops later independent requests; those rows remain in request order
with `is_skipped`, and the result reports successful, failed, and skipped
counts. Each document keeps its own commit boundary, so earlier successful
deletions remain committed.

## Cost-center reservation reversal bulk stop-on-failure

`POST_CC_ISSUE_REV_BULK`, `POST_CC_ISSUE_REV_BULK_UNIT`, and
`POST_CC_REV_REMAINING_BULK` accept `iv_stop_on_failure`, defaulting to
`abap_false`. They prevalidate the option before scope reads or unit
conversion. When enabled, the first failed reservation reversal stops later
reservation groups, which remain in the result as skipped rows. Successful,
failed, and skipped groups are counted separately, and earlier independent
commits remain committed.

## Sales-order reservation movement bulk stop-on-failure

The reservation-scoped sales-order issue and reversal bulk methods, including
remaining-quantity and exact-item forms, accept `iv_stop_on_failure`, defaulting
to `abap_false`. They validate the flag before reservation reads or unit
conversion. When enabled, the first failed reservation group stops later
groups, which remain in the result as skipped rows; success, failure, and skip
counts are reported separately. Earlier independent commits remain committed.

## Sales-order dated reservation bulk stop-on-failure

`reserve_orders_by_date_bulk` accepts `iv_stop_on_failure`, defaulting to
`abap_false`. It validates the option before preview reads and preserves one
result row per sales document. By default, row-level ATP, create, response, and
commit failures do not prevent later orders; when enabled, later orders remain
in caller order as skipped with separate outcome counts. Earlier independent
commits remain committed. Each `order_results` row also includes its
document-level allocation summary when the order has positive open demand, so
the preview outcome stays visible if reservation creation fails or the row is
skipped.

## Reservation goods-issue bulk stop-on-failure

`POST_GOODS_ISSUE_BULK`, `POST_GOODS_ISSUE_REVERSAL_BULK`,
`POST_GOODS_ISSUE_BULK_UNIT`, and `POST_GOODS_ISSUE_REV_BULK_UNIT` accept
`iv_stop_on_failure`, defaulting to `abap_false`. The option is validated
before UOM conversion. When enabled, the first failed reservation group stops
later groups; result rows mark them as skipped and report separate outcome
counts. Each reservation remains its own commit boundary, so prior successful
groups stay committed.

## Cost-center reservation issue bulk stop-on-failure

`POST_CC_GOODS_ISSUE_BULK`, `POST_CC_GOODS_ISSUE_BULK_UNIT`,
`POST_CC_ISSUE_REMAINING`, and `POST_CC_REMAINING_ITEMS` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They validate the option
before a reservation read or unit conversion. When enabled, a failed group
stops later cost-center reservation issues; skipped groups remain visible and
are counted separately from failures. Earlier independent commits remain.

## Project WBS reservation deletion bulk stop-on-failure

`DELETE_RESERVATIONS_BULK` and `DELETE_RESERVATION_ITEMS_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. They validate the flag and
complete request set before writes. When enabled, the first failed document or
item deletion stops later independent requests; those remain in input order as
skipped rows, with separate successful, failed, and skipped counts. Earlier
successful reservation commits remain committed.

## Project WBS reservation bulk stop-on-failure

`RESERVE_WBS_BULK`, `RESERVE_BATCH_ALLOCATION`,
`RESERVE_LOCATION_ALLOCATION`, `RESERVE_WBS_FEFO`,
`RESERVE_WBS_FEFO_PRIORITY`, `RESERVE_WBS_FEFO_BY_DATE`,
`RESERVE_WBS_BY_LOCATION_DATE`, `RESERVE_WBS_BY_LOCATION`, and
`RESERVE_WBS_LOCATION_PRIORITY` accept `iv_stop_on_failure`, defaulting to
`abap_false`. They validate the option before request conversion or preview
reads and validate the full allocation/request before the first create. In
independent mode the first failed create or commit skips later requests, which
remain in caller order with `is_skipped` and separate skipped counts. In
atomic mode the option stops later create calls, while any attempted group
still rolls back after failure. The top-level `is_committed` summary reflects
any independent child commit and is set for atomic mode only after the group
commit succeeds. Earlier independent commits remain committed.

## Project WBS reservation reschedule bulk stop-on-failure

`RESCHEDULE_ITEMS_BULK` accepts `iv_stop_on_failure`, defaulting to
`abap_false`. It validates the flag and all request dates/scopes before writes.
When enabled, the first failed reservation reschedule stops later requests;
those rows remain in input order with `is_skipped`, and successful, failed,
and skipped counts are reported separately. Earlier independent commits
remain committed.

## Sales-order reservation release bulk stop-on-failure

`DELETE_ORDERS_RELEASE_BULK` accepts `iv_stop_on_failure`, defaulting to
`abap_false`. It validates the option before the reservation lookup and keeps
one result row per requested sales order. When enabled, the first failed delete
or commit skips later orders with separate success, failure, and skipped
counts; earlier independent releases remain committed.

## Project WBS reservation maintenance bulk stop-on-failure

`CHANGE_RESERVATION_QTY_BULK`, `MARK_RESERVATION_FINAL_BULK`,
`RESET_RESERVATION_FINAL_BULK`, and `CHANGE_RESERVATION_STOCK_BULK` accept
`iv_stop_on_failure`, defaulting to `abap_false`. Each validates the option and
the complete request before writes. When enabled, the first failed reservation
operation stops later calls; later rows remain in request order as skipped and
the summary separates successful, failed, and skipped counts. Earlier
independent commits remain committed.

## Purchase-requisition bulk stop-on-failure

Purchase-requisition bulk item update, selected-item deletion, delete-all, and
prepared requisition creation accept `iv_stop_on_failure`, defaulting to
`abap_false`. Each method validates the flag and complete input before the
first SAP write; delete-all also validates all requisition keys before its
first read. With the option enabled, the first read, BAPI, response, or commit
failure stops later requests. The output retains skipped rows in caller order,
marks each with `is_skipped`, and reports successful, failed, and skipped
counts plus `stopped_on_failure`. Independent commits made before the failure
remain. Atomic update mode always stops and rolls back its shared group at the
first failure, regardless of the option; rows not sent to SAP are marked
skipped. Simulation follows the same stop policy without committing.

## STO creation pair bulk stop-on-failure

`CREATE_FROM_SOURCE_PLANTS`, `CREATE_FROM_ATP_SOURCE_PLANTS`, and the STO pair
creation methods accept `iv_stop_on_failure`, defaulting to `abap_false`.
Request validation and order preparation finish before the first BAPI call.
When enabled, the first failed create stops later calls, preserves every result
row in caller order, marks unattempted suppliers or pairs `is_skipped`, and
reports successful, failed, and skipped counts. Earlier independent commits
remain committed. Atomic failures roll back the staged group and distinguish
unattempted rows; an atomic commit failure sets `stopped_on_failure` when the
option is enabled.
