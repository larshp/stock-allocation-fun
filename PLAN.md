make a stock allocation solution in ABAP, add one feature at a time, keep improving it. It must integrate into existing SAP system and follow best practices for ABAP development.

use abaplint and transpiler for testing, record bugs and issues in ANOMALIES.md

open-abap does not include the business logic needed, add SAP standard stubs in a separate directory and include it in linting and transpiling. This includes stuff like reading stock and writing stock, reading and writing orders, etc via SAP standard APIs. Eg. database table MARD carries available stock, add it to the stubs for reading stock. All custom code starting with Z must be in the src folder.

keep your notes and progrss in NOTES.md

these abaplint rules also be enabled: modify_only_own_db_tables + align_type_expressions + easy_to_find_messages + max_one_method_parameter_per_line + align_parameters + local_testclass_consistency + allowed_object_naming + line_length

use https://github.com/open-abap/open-abap-core as a dependency in abaplint and the transpiler configurations

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
the same calendar-day distance in their nested base row. Each result counts
returned batch/location/valuation rows
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
plant-level expiry date or `G` for the global fallback; set
`filter_expiry_source` to `abap_true` with a blank `expiry_source` to select
rows without a resolved source. Nonblank source values must be `P` or `G`; the
expiry-source scope intersects with the other filters. Optional inclusive `expiration_date_from` and `expiration_date_to` bounds
filter rows by their resolved expiration date; either bound may be supplied,
and two bounds must be in ascending order. When either bound is supplied,
undated rows are omitted from the undated list, counts, and totals. The bounds
do not change expiry status relative to `as_of_date` or the after-window test
relative to `through_date`. The selected locations, batches, valuation types,
expiry source, date bounds, and flags are echoed on base and UOM results. The
repository still
reads material/plant stock to calculate reservation-net quantities across all
locations; the filters narrow returned stock rows, expiry and source counts,
and stock-category totals after netting. Reservation summaries and allocation
traces remain material/plant-wide.
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
results echo the counts. `matched_allocation_quantity` and
`fallback_allocation_quantity` summarize the deductions made by the matching
and fallback passes. Together with `uncovered_open_resv_quantity`, they sum to
eligible `open_reservation_quantity`; excluded demand is outside that total.
UOM results return base and requested-unit fields for both pass totals, so a
caller can compare them without summing `allocation_details` rows.
`matched_allocation_row_count` and `fallback_allocation_row_count` count trace
rows for each pass. Each row is one positive deduction against one stock row;
the counts are not distinct reservation counts. UOM results echo the counts.
`uncovered_open_resv_quantity` reports the eligible open demand left after
the calculator's matching and fallback passes; it describes local allocation,
not an SAP-confirmed shortage. The UOM result carries base and requested-unit
values. `uncovered_open_resv_keys` lists the reservation/item keys with a
positive residual after local allocation, sorted by reservation and item; UOM
results echo the keys unchanged. `uncovered_open_reservations` also returns
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
`allocation_sequence` is one-based across positive eligible open reservations
and records calculator processing order: more specific selectors go first,
selector values break ties, and identical selector tuples retain caller input
order. Stock rows traverse by location, batch, valuation type, and expiry date;
equal stock keys retain input order. Trace and uncovered rows carry the
sequence, and UOM rows echo it. Result collections remain sorted by
reservation/item; sorting by `allocation_sequence` restores shared-stock
consumption order.
`uncovered_open_resv_row_count` reports the number of returned residual rows,
and expiry/UOM results preserve the count.
`allocation_details` lists each positive reservation deduction with the
reservation's requested location, batch, and valuation type beside the actual
stock location, batch, valuation type, and expiry date. Pass `M` honors
the reservation selectors; pass `F` widens location/batch matching while
retaining any specified valuation type. Entries sort by reservation/item and
preserve pass and stock traversal order within each key. For keys listed in the
uncovered summary, entry quantities sum to `allocated_quantity`; fully covered
reservations still appear in the trace. UOM entries include base and requested
amounts.
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
today.
The repository-backed `ZIF_BATCH_EXPIRY_READER` exposes both base-unit and
unit-aware bulk expiry snapshots and forwards reservation exclusions to the
stock service. The direct batch-status bulk result also includes a UTC
`snapshot_timestamp`, captured after its grouped repository read; all result
rows from that read share the timestamp, and the UOM batch-status result echoes
it unchanged.
Each result includes a UTC `snapshot_timestamp`
and identifies the earliest positive-stock upcoming row through its storage
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
storage-location, procurement, special-stock and fixed indicators, and
positive-quantity, MRP-controller, production-supervisor, production-version,
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
nonblank `sales_order` values select orders assigned to that AFPO
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
`finish_filter_lost` drift detection. An optional `active_status_code` filters
on an exact currently
active SAP system or user status while the result retains all active statuses
for reconciliation. Because detail/status rows are read later,
each order flags `status_filter_lost` if that status is no longer active;
`status_filter_lost_count` summarizes those rows. Changed orders remain
in the result for reconciliation. After the detail read, `finish_filter_lost`
marks an order when none of its returned items still matches the selected
material, plant, item number, category, order type and description, order quantity,
order creator and changer, creation and
change-date ranges, required phase, deletion, receipt-expected state,
delivery-completion state, finish/start-date, and remaining-quantity
conditions; the group reports
`finish_filter_lost_count`.
The drift check also covers sales-order assignment and item, planned-order
reference and start date, planning plant, production version, storage location,
batch, account-assignment category, MRP area, and WBS assignment.
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
across separate repository reads.

## Production confirmation posting-window read

`SEARCH_CONFIRMATIONS_BY_WINDOW` searches confirmations for production
and process orders containing one material at one plant over an inclusive
posting-date range. An optional `production_order` restricts the search to one
production or process order within the material and plant scope. An optional
`order_category` accepts `10` for production orders or `40` for process orders;
each confirmation row reports its category. An optional `operation_counter`
filters one AFVC internal counter and requires `production_order`. An optional
operation number
restricts the search to one routing operation. A noninitial
`operation_sequence` restricts the search to one routing sequence and may be
used with or without an operation number. Set `filter_operation_sequence` to
`abap_true` to match exactly, including the initial sequence value; otherwise
it must be `abap_false`, and a noninitial sequence still filters. Invalid flag
values fail before the read, and returned rows are checked against the selected
sequence.
An optional nonblank suboperation number narrows the search to that
suboperation and requires the operation number. By default, an initial
`operation_suboperation` omits that filter, including the base step and every
suboperation. Set `filter_operation_suboperation` to `abap_true` to match the
exact initial value for the base step only; this flag also requires a selected
operation number. Otherwise the flag must be `abap_false`, and a nonblank
suboperation continues to filter. Invalid flag values fail before the read,
and returned rows are checked against the selected suboperation.
An optional nonblank `control_key` filters by
the AFVC routing control key and can be combined with or used without the
operation filters. Set `filter_control_key` to `abap_true` to match the exact
control key including blank; otherwise it must be `abap_false`, and a nonblank
key continues to filter. Invalid flag values fail before the read, and returned
rows are checked against the selected key. An optional nonblank `quantity_unit`
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
positive. An optional `confirmation_number` restricts
results to one AFRU
confirmation; `confirmation_counter` narrows that selection to one counter and
requires the confirmation number. An initial suboperation filter includes the base step and every
suboperation for the selected operation.
Confirmation rows include the AFVC operation counter, operation/suboperation
numbers, sequence, operation description, control key, entered-by user, and order
category. They
also include `scope_material` and `scope_plant` from the matching AFPO item. The
service verifies material and plant scope on every returned row before mapping.
Number-based bulk confirmations leave these scope fields initial because they
do not have a material/plant search scope. Results have a stable
ordering by posting date, order,
confirmation, and counter. The caller's 1-to-500 limit is enforced in the
repository with one extra row to detect truncation. The service returns the
last returned tuple as a four-field keyset cursor and rejects partial or
out-of-range cursor selections before the read. Reversed confirmations are
retained with their reversal indicator by default; `exclude_reversed` lets
callers request only non-reversed rows, while `reversed_only` selects only
reversed rows. The two reversal flags are mutually exclusive. `final_only` limits results to final
confirmations when true; `partial_only` returns confirmations not marked final.
The two flags are mutually exclusive; the default includes both partial and
final rows. Before
returning rows, the service checks the repository's limit-plus-one bound,
requested filters, inclusive date range, cursor boundary, and stable tuple
ordering. Each response also groups the returned page by production order,
AFVC operation counter, operation number, sequence, suboperation, and
confirmation unit. Summaries echo the order category and include counts, raw
yield/rework/scrap totals, and corresponding non-reversed totals
(`yield_non_reversed_total`, `rework_non_reversed_total`, and
`scrap_non_reversed_total`). Raw totals include reversed rows; non-reversed
totals include only returned rows whose `is_reversed` is not `abap_true`.
Summaries also carry the operation description and control key.
`first_posting_date` and `last_posting_date` identify the earliest and latest
posting dates among its returned confirmations. These summaries exclude the
lookahead row and later pages. Invalid flag values fail before the read. Each
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
with separate reversed-inclusive and non-reversed totals, date spans, and
confirmation counts.

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
commits remain committed.

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
