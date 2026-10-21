# Anomalies

Batch expiry can now suppress dated detail rows while preserving full-scope summaries; the
independent undated page remains available and dated page values become zero. Summaries also
include dated row-share percentages for page status buckets and
source/status matrices. Page shares use returned dated rows; the full source/status matrix uses
all matching dated rows, including after-window stock, and is independent of cursors and page
limits. Full overdue-age, upcoming, and after-window source matrices report shares within their
matching status totals. Undated
summaries include page-local and full-filtered P/G/O source buckets; full buckets remain stable
across cursors and page limits, including when detail rows are omitted, and both full and page
buckets report row-share percentages. The first-undated identity also echoes the raw expiry
source marker.
Regression cases cover P, G, unknown-to-O,
continuation stability, empty pages, and UOM conversion. They have not been
executed in this WSL 1 environment: the workspace Node shim cannot start, and
direct `node.exe --version` fails with `UtilBindVsockAnyPort`. ABAP lint,
transpilation, and ABAP Unit status remain unverified.

Planned-order finish-window reads are bounded to at most 500 returned orders
and expose `is_truncated` when another matching row exists. The continuation
cursor uses both finish date and planned-order number to traverse same-date
ties without repeating a returned order. Results are ordered by those keys.
Planned-order bulk and finish-window results expose a UTC
`snapshot_timestamp` after their repository reads. Empty direct bulk input leaves
it initial; finish-window searches return it even when no orders match.
Number-based planned-order bulk reads reject blank, duplicate, and unrequested
repository rows before mapping; missing requested rows remain per-row not-found
results. The timestamp marks read completion and does not lock a planned order
before a subsequent change or make separate pages a transactional snapshot.
The service rejects malformed result rows before mapping, including duplicate or
blank order numbers, mismatched material, production-plant, planning-plant,
sales-order, planning-scenario,
order type, storage-location, procurement, special-procurement-type,
positive-quantity and order- and base-unit quantity bounds, MRP-controller,
production-supervisor, production-version, MRP-area, account-assignment
category, sales-order-item and schedule-line, special-stock and fixed indicators, start-date and
finish-date filters, cursor regressions, unstable sort order, and more than one
lookahead row.
Base-unit quantity bounds join MARA and MARM into the finish-window key query
so they apply before the lookahead limit. The repository compares rational
conversion products without rounding; returned headers are independently
converted and checked by the service. Verify SQL arithmetic and conversion
ratios against the target SAP release.
The `plant` scope uses `PLAF-PWWRK`, the plant where in-house production is
manufactured. The optional `planning_plant` scope uses `PLAF-PLWRK`, where
requirements planning or forecasting is carried out. SAP documents this field
distinction in its [planned-order interface](https://help.sap.com/docs/SAP_ERP/e1d2edc3460848fdb57a2323fc931758/031fbf53d25ab64ce10000000a174cb4.html?version=6.18.latest).
Bulk and finish-window headers return both plant fields and the creation
date. `filter_planning_plant` selects an exact `PLAF-PLWRK` value, including
blank; invalid flag values fail before reading and returned rows are checked
for scope drift. The local stub models `PLWRK` as a four-character plant.
Confirm target DDIC and cross-plant planning behavior before integration.
Planned-order headers now return scheduled execution dates and times
(`PLAF-GSTRS`/`GSUZS` and `GLTRS`/`GLUZS`) separately from the basic
start/finish dates. SAP documents the scheduled date/time fields in its
[planned-order interface](https://help.sap.com/docs/SAP_ERP/e1d2edc3460848fdb57a2323fc931758/031fbf53d25ab64ce10000000a174cb4.html?version=6.18.latest).
The local stub models them as DATS and TIMS; verify scheduling semantics in
the target release. Finish-window searches can select inclusive scheduled-start
and scheduled-finish date ranges on `PLAF-GSTRS` and `PLAF-GLTRS`; the service
validates both bounds and rejects returned rows outside either selected range.
Exact-date filters can also select an initial scheduled date by setting the
matching filter flag; nonblank values filter by default. Exact and range filters
intersect. A corresponding `filter_start_date` option selects exact basic
planned start dates from `PLAF-PSTTR`, including blank, and also intersects with
the optional planned-start-date range.
Pagination order remains based on the basic finish date and planned-order
number. Optional start/finish time-of-day ranges filter `PLAF-GSUZS` and
`PLAF-GLUZS` on every matching date. The service validates the flags, bounds,
and validates returned times before checking them against selected ranges.
These ranges can combine with scheduled-date filters and do not wrap over
midnight.
The optional `planned_order_user` filter matches `PLAF-PUSER` exactly when
nonblank; blank omits it by default. `filter_planned_order_user` selects an
exact value including blank, and malformed flag values fail before reading. The
service checks returned users against either selected value. Bulk and finish-window
headers return the field. SAP maps `PUSER` to a user field in its [PLAF field catalog](https://help.sap.com/docs/signavio-process-insights/administration-guide/be4b0a35f6d048eb979899f569509c78.html).
The local stub uses a 12-character field; confirm the target DDIC definition
and user-field semantics during integration.
The returned last-change timestamp is raw `PLAF-PSTMP` data. Finish-window
searches can filter it with inclusive positive lower and upper bounds, each
optional; when both are supplied, the lower bound must not exceed the upper
bound. The service checks returned values against every supplied bound.
[SAP KBA 1803240](https://userapps.support.sap.com/sap/support/knowledge/en/1803240)
documents that it can differ from the apparent time of a change. Treat it as
a source-system value, not an authoritative wall-clock audit time.
The optional creation-date range uses `PLAF-PERTR`, documented as the
planned-order creation date. Both valid bounds are required, and returned rows
are checked against the inclusive range before mapping. SAP lists the field in
its [planned-order header mapping](https://help.sap.com/docs/SAP_ERP_SPV/548d9774d38f4f31adbc2e3d0554921c/d31ebf53d25ab64ce10000000a174cb4.html).
The local stub models it as a date; confirm its value semantics in the target
release.
The finish-window query can match an exact nonblank `PLAF-PAART` planned-order
type, or use `filter_order_type` to select an exact value including blank. The
service rejects invalid flags before reading and validates returned scope. The
local PLAF stub covers the field for lint and transpiler checks; verify its
domain against the target system's DDIC before integration.
Sales-order filtering retains exact nonblank matching and can explicitly match
initial `PLAF-KDAUF` with `filter_sales_order`. Returned rows are checked
against the selected value. SAP's [planned-order interface documentation](https://help.sap.com/docs/SAP_ERP/e1d2edc3460848fdb57a2323fc931758/031fbf53d25ab64ce10000000a174cb4.html?version=6.18.latest)
documents `KDAUF` as the sales-order key and says its use with `KDPOS` requires
a make-to-order planned-order profile. Verify assignment behavior and the
target DDIC field definition during integration.
Storage-location filtering uses the same exact-scope check, with an explicit
flag to select initial `PLAF-LGORT` values. Local tests cannot establish how
the target system assigns or interprets planned-order storage locations.
Special-procurement-type selection matches `PLAF-SOBES` exactly when
`filter_special_proc_type` is enabled, including an initial value. The
finish-window repository applies the filter before pagination and returns the
field in each header; the service rejects invalid selector flags, inactive
values, and repository rows outside the selected type.
Procurement-indicator filtering matches `PLAF-BESKZ` exactly and uses an
explicit flag so initial values can be requested. The local stub does not
validate the target system's domain configuration or customizing values.
The optional positive-quantity filter removes zero and negative `PLAF-GSMNG`
rows before pagination. The service also rejects nonpositive quantities if a
repository returns them despite the selected filter.
The optional `filter_quantity_from` and `filter_quantity_to` flags filter
`PLAF-GSMNG` inclusively before pagination, in each planned order's `order_unit`;
they do not compare converted base-unit quantities. Either bound can be used
alone, zero is valid when enabled, and two bounds must be in ascending order.
Invalid flags, values supplied for disabled bounds, reversed ranges, and
repository rows outside selected bounds are rejected before mapping.
The optional `order_unit` selection matches `PLAF-MEINS` exactly; a nonblank
unit filters by default, while `filter_order_unit` enables explicit matching of
the initial value. The service validates the flag and returned unit, and the
filter runs before pagination. This can be combined with the quantity range to
avoid comparing numeric quantities from different units.
MRP-controller filtering reads the exact `PLAF-DISPO` value, including blank
when explicitly enabled. SAP field documentation identifies `DISPO` as the
planned-order MRP controller; local tests do not exercise the target system's
controller assignments or authorizations.
Production-supervisor filtering reads exact `PLAF-PLGRP`, including blank when
explicitly enabled. Confirm target DDIC and supervisor assignment behavior in
the deployed release.
Production-version filtering matches `PLAF-VERID` exactly, including blank
when enabled. SAP documents this field as a four-character production version;
verify target-system assignment and customizing before using it to choose a
production source.
MRP-area filtering matches `PLAF-BERID` exactly, including blank when enabled.
SAP field mapping identifies `BERID` as the planned-order MRP area; the local
stub models the ten-character field. Validate area assignments and stock
partition behavior in the target system.
Account-assignment filtering matches `PLAF-KNTTP` exactly, including blank
when enabled. SAP identifies this field as the account-assignment category;
verify allowed values and assignment behavior in the target release.
Nonblank planning-scenario values retain their exact-match behavior. The
`filter_planning_scenario` flag also allows an exact match on initial `PLSCN`,
so callers can isolate orders with no planning scenario from orders in a named
scenario. The service rejects malformed flag values and checks returned rows;
the local stub does not validate target-system scenario customizing.
Sales-order schedule-line filtering uses `PLAF-KDEIN` and requires the parent
sales order and a selected nonblank sales-order item. It can match the initial
`0000` value explicitly. SAP maps `KDEIN` to the sales-order schedule field;
the local stub models it as a four-digit numeric value. SAP's [planned-order
field map](https://help.sap.com/docs/signavio-process-insights/administration-guide/be4b0a35f6d048eb979899f569509c78.html)
identifies `KDEIN` as the sales-order schedule. Verify the target DDIC
definition and assignment behavior during integration.
Sales-order-item filtering matches `PLAF-KDPOS` exactly when a sales order is
also selected. The initial item value (`000000`) can be requested explicitly;
the local stub models SAP's six-digit numeric field. SAP's [planned-order
interface documentation](https://help.sap.com/docs/SAP_ERP/e1d2edc3460848fdb57a2323fc931758/031fbf53d25ab64ce10000000a174cb4.html?version=6.18.latest)
describes `KDPOS` as a six-digit item number and associates it with `KDAUF` for
make-to-order planned orders. Verify item assignment behavior in the target
release.

Production-order finish-window reads can also filter on an inclusive basic
start-date range. Partial, invalid, and reversed bound pairs fail before the key
query; returned keys outside the range are rejected before detail reads.
The optional `filter_sales_order` flag selects an exact AFPO-KDAUF assignment,
including blank. A nonblank `sales_order` filters by default; returned details
expose the value and participate in selection-drift checks.
The optional `filter_sales_order_item` flag selects an exact AFPO-KDPOS value,
including blank. Nonblank sales-order items filter by default; returned details
expose the value and participate in selection-drift checks.
The optional `filter_sales_schedule_line` flag selects an exact AFPO-KDEIN
value, including blank. Nonblank schedule lines filter by default; returned
details expose the value and participate in selection-drift checks.
The optional `filter_storage_location` flag selects an exact AFPO-LGORT value,
including blank. Nonblank locations filter by default; returned details expose
the value and participate in selection-drift checks.
The optional `filter_batch` flag selects an exact AFPO-CHARG value, including
blank. Nonblank batch values filter by default; returned details expose the
value and participate in selection-drift checks.
The optional `filter_assignment_category` flag selects an exact
AFPO-KNTTP value, including blank. Nonblank categories filter by default;
returned details expose the value and participate in selection-drift checks.
The optional `filter_mrp_area` flag selects an exact AFPO-BERID value, including
blank. Nonblank MRP areas filter by default; returned details expose the value
and participate in selection-drift checks.
AFPO-PROJN stores the internal WBS ID; production-order reads expose PRPS-POSID
as `wbs_element` and retain the original value as `wbs_element_internal_id`.
The optional `filter_wbs_element` flag selects the exact external WBS element.
An exact blank selects items without an AFPO-PROJN assignment; nonblank values
filter by default, and returned details check the selected assignment for drift.
The optional `filter_planned_order` flag selects an exact AFPO-PLNUM value,
including blank. Nonblank planned-order numbers filter by default; returned
details expose the reference and participate in selection-drift checks.
AFPO-PWERK is the planning plant for the order, distinct from AFPO-WERKS, the
production plant. The optional `filter_planning_plant` flag selects an exact
AFPO-PWERK value, including blank. Nonblank planning plants filter by default;
returned details expose the value and participate in selection-drift checks.
AFPO-DWERK maps to the sales-item plant. The optional
`filter_delivery_plant` flag selects an exact AFPO-DWERK value, including
blank. Nonblank delivery plants filter by default; returned details expose the
value and participate in selection-drift checks.
The optional `filter_special_stock` flag selects an exact AFPO-SOBKZ value,
including blank. The indicator identifies special-stock handling, such as
sales-order or project stock; returned details expose it and participate in
selection-drift checks.
The optional `filter_stock_type` flag selects an exact AFPO-INSMK value,
including blank. Nonblank stock types filter by default; returned details
expose the value and participate in selection-drift checks.
The optional `filter_goods_recipient` and `filter_unloading_point` flags
select exact AFPO-WEMPF and AFPO-ABLAD values, including blank. Nonblank values
filter by default; returned details expose both values and participate in
selection-drift checks.
The optional `filter_production_version` flag selects an exact AFPO-VERID
value, including blank. Nonblank versions filter by default; returned details
expose the value and participate in selection-drift checks.
The optional `filter_plan_start_date` flag selects an exact
AFPO-STRMP date, including blank. Nonblank dates filter by default and must be
valid; returned details expose the value and participate in selection-drift
checks.
The optional `filter_basic_start_date` flag selects an exact AFKO-GSTRP value,
including blank. A nonblank value filters by default, and supplied dates must be
valid. The exact selector intersects with the basic-start-date range, with key
and detail reads checking the selected value.
The optional `filter_order_description` flag selects an exact AUFK-KTEXT value,
including blank. Nonblank descriptions filter by default, and returned details
are checked for scope drift.
The optional `filter_order_changed_by` flag selects an exact AUFK-AENAM value,
including blank. Nonblank changer values filter by default; detail reads check
the selected value for drift.
The optional `filter_order_created_by` flag selects an exact AUFK-ERNAM value,
including blank. Nonblank creator values filter by default; detail reads check
the selected value for drift.
Production-order number-based bulk reads reject item/status rows for
unrequested orders and duplicate item/status keys before mapping. Bulk results
for orders, confirmations, and operations include UTC `snapshot_timestamp`
values after their repository reads; empty
bulk input leaves them initial. Number-based bulk results leave
`key_selection_timestamp` initial. Order finish-window results include `key_selection_timestamp` for completion
of the key query and `snapshot_timestamp` for completion of the later
detail/status reads, even when the key query returns no orders. They expose the
read gap but do not create an atomic snapshot across separate key, detail, and
status reads. An optional order-category filter selects production (`10`) or
process (`40`) orders while the default includes both. Finish-window searches
return full order detail after first selecting matching material/plant/date
keys. Orders can change between the key
query and detail/status reads, or between pages, because these reads do not
lock production orders. The service rejects malformed key sets before detail reads, including blank or
duplicate orders, out-of-range dates, cursor regressions, unstable ordering, and
more than one lookahead row. The continuation cursor prevents revisiting earlier
sort keys in an unchanged result set; it does not create a cross-page database
snapshot. `active_status_code` tests one active JEST status, while
`active_status_codes` accepts several and matches when any listed status is
active at key selection time. Use one selector at a time and omit blank list
entries. The later status read can observe a change; in that case the order
remains in the result with `status_filter_lost = abap_true`, and
`status_filter_lost_count` reports how many returned orders lost the
selected status. Production-order items also expose
`over_receipt_pct_of_order_qty`, computed from valid AFPO order and received
quantities before two-decimal display rounding. Valid items without excess
report zero; invalid quantity items leave the metric initial. It is independent
of base-unit conversion. `over_receipt_quantity_base` exposes the excess in the
material base unit when conversion succeeds; valid items without excess report
zero, while invalid receipt progress or failed conversion leaves it initial.
The detail read also checks the selected material, production
plant, planning and delivery plants, item number, category, order type and
description, order unit, sales-order assignment/item/schedule line, planned-order
reference and start date, production version, special-stock indicator, stock
type, goods recipient, unloading point, storage location, batch,
account-assignment category, MRP area, WBS assignment, order-quantity and
base-unit quantity bounds, received-quantity and over-receipt quantity
bounds, received-base-unit and over-receipt-base-unit quantity bounds,
received-percentage bounds,
unreceived-quantity and
unreceived-base-unit quantity bounds, unreceived-percentage bounds, and
receipt-progress state,
order creator and changer, creation
and change-date ranges, required phase, deletion, receipt-expected state,
delivery-completion state, basic finish/start dates, and scheduled start/finish
dates and time ranges. If no returned item still matches, `finish_filter_lost`
is set on that order and `finish_filter_lost_count` counts it. Changed orders
remain visible for reconciliation. The optional scheduled start and finish
dates and time-of-day values are returned alongside
basic dates; the finish window, result order, and continuation cursor still use basic finish
dates. Optional AFKO-GLTRS scheduled-finish-date bounds must be provided as a
valid ascending pair and apply before pagination. The key and detail reads both
check that range, while cursors remain based on basic finish dates. The optional
AFKO-GSTRS scheduled-start-date range follows the same paired validation and
pre-pagination, key-read, and detail-read checks; cursors still use basic finish
dates. The optional
`filter_scheduled_start_date` and `filter_scheduled_finish_date` flags select
exact AFKO-GSTRS and AFKO-GLTRS dates, including blank values. Nonblank values
filter by default, and nonblank dates must be valid. Exact and range filters
intersect; query keys and detail items are checked for drift.
AFKO-GSUZS and AFKO-GLUZS time-of-day ranges are enabled by boolean flags and
require valid ascending bound pairs, with midnight `000000` allowed. Disabled
filters require initial bounds. They apply before pagination and are checked
against returned keys and detail items; ranges apply on every matching date,
do not wrap across midnight, and do not change basic-finish-date ordering.
`unreceived_quantity_only` filter compares AFPO-PSMNG and AFPO-WEMNG in their
order unit before pagination; the later detail read includes the condition in
its selection-drift diagnostic. Optional inclusive lower and upper bounds use
`filter_unreceived_qty_from` / `unreceived_qty_from` and
`filter_unreceived_qty_to` / `unreceived_qty_to`. Enabled bounds must be
positive, disabled values must be initial, and a lower bound cannot exceed an
upper bound. Bounds select positive remaining quantities in the AFPO order unit
before pagination, and the detail-read drift diagnostic includes them.
`filter_over_receipt_qty_from` and `filter_over_receipt_qty_to` select
inclusive bounds on the derived `over_receipt_qty_order_unit` in the AFPO order
unit. The key query applies them before pagination and requires valid receipt
progress; valid items with no excess have a zero over-receipt quantity. The
service rechecks the selected quantity and validity after reading details.
`filter_over_receipt_pct_from` and `filter_over_receipt_pct_to` select
inclusive bounds on the raw over-receipt-to-order ratio before display
rounding. Bounds are nonnegative and have no upper cap; valid items without an
over-receipt have zero percent. The repository applies them before pagination,
and the detail read rechecks the raw values.
`filter_order_qty_base_from` and `filter_order_qty_base_to` select inclusive
bounds on `order_quantity_base` in the material base unit. The key query uses
AFPO-UMREZ/UMREN cross-products before pagination and excludes rows whose order
unit, base unit, order quantity, received quantity, or conversion ratio would
leave quantity conversion unsuccessful. The service rechecks the converted
quantity and conversion status after reading details.
`filter_received_qty_base_from` and `filter_received_qty_base_to` select
inclusive bounds on `received_quantity_base` in the material base unit. The key
query compares AFPO-WEMNG against the AFPO-UMREZ/UMREN ratio before pagination
and requires a successful quantity conversion. The service rechecks the
converted received quantity and conversion status after reading details.
`filter_over_rcpt_qty_base_from` and `filter_over_rcpt_qty_base_to` select
inclusive bounds on `over_receipt_quantity_base` in the material base unit.
Zero includes valid items without excess. The key query compares AFPO receipt
excess against the order-to-base ratio before pagination and requires valid
receipt progress and successful conversion; the detail read rechecks all three.
`filter_unrecv_qty_base_from` and `filter_unrecv_qty_base_to` select
inclusive bounds on `open_quantity_base` in the material base unit. The key
query compares the positive AFPO-PSMNG minus AFPO-WEMNG quantity against the
AFPO-UMREZ/UMREN ratio before pagination and requires successful quantity
conversion. The service rechecks the converted open quantity and conversion
status after reading details.

Finish-window results also report `finish_match_base_qty_summary` and each
order reports `matching_base_qty_summary`, with `item_count`,
`excluded_item_count`, `contributing_progress_counts`,
`contributing_progress_qty`, `invalid_progress_count`,
`valid_progress_conv_fail_count`, and order, received, open, and over-receipt
quantity totals in the selected material's base unit. `item_count` counts
matched items with valid receipt progress and successful conversion.
`invalid_progress_count` includes invalid-progress rows even when conversion
also failed; `valid_progress_conv_fail_count` counts conversion failures with
valid progress. These disjoint reason counts sum to `excluded_item_count`.
Per-order contributing and excluded counts sum to `finish_window_match_count`;
page counts sum the per-order values.
`contributing_item_pct` and `excluded_item_pct` report the two counts as
percentages of matching items, rounded to two decimals. Page percentages are
weighted across the matched rows. `invalid_progress_pct` and
`valid_progress_conv_fail_pct` report each disjoint exclusion reason as a share
of matched items; their exact shares sum to the excluded percentage. Independent
two-decimal rounding can cause a 0.01 point difference. Empty summaries leave
these percentages initial.
`invalid_excluded_share_pct` and `conv_fail_excluded_share_pct` report
each reason's share of excluded items; the exact shares sum to 100%, subject to
independent two-decimal rounding. Summaries without exclusions leave these
shares initial.
`contributing_progress_counts` breaks contributing items down by not-started,
partial, complete, and over-received states. Its total equals `item_count`, and
percentages use `item_count` as denominator. Page percentages are weighted
across contributing rows. This distribution can differ from matching progress
percentages, which include conversion failures. Empty summaries leave its
counts and percentages initial. `contributing_progress_qty` reports order,
received, open, and over-receipt base-unit totals for each progress-state group.
Summing by quantity reconciles with the overall totals, subject to decfloat34
rounding; page groups sum per-order groups. The invalid group is normally empty
because invalid raw-progress rows are excluded, but captures an unexpected
status on a contributing row. Empty summaries leave the groups initial.
Each group also exposes order, received, open, and over-receipt quantity share
percentages relative to their corresponding overall totals. Page shares are
weighted from page totals. Shares use positive denominators and stay initial
when a matching total is zero; they sum to 100 before independent two-decimal
rounding.
Order plus over-receipt totals reconcile with received plus open totals,
subject to decfloat34 rounding. Page values sum the per-order summaries, and
direct bulk reads leave these finish-window-only summaries initial. Each
summary also reports received, open, and over-receipt percentages computed from
the aggregate totals and rounded to two decimals. These weighted ratios are not
averages of item percentages; empty summaries leave them initial, and the
over-receipt-to-order percentage can exceed 100.
`over_rcpt_pct_of_received_qty` reports over-receipt as a share of received base
quantity; it is at most 100% for valid contributing quantities and remains
initial when received quantity is zero.

Production-confirmation posting-window searches retain reversed confirmation
rows and expose their reversal flag for reconciliation by default. Callers can
exclude reversed rows or set `reversed_only` to request only reversals; those
flags cannot both be true.
Yield, rework, and scrap quantity bounds compare `AFRU-LMNGA`, `AFRU-RMNGA`,
and `AFRU-XMNGA` inclusively before pagination. They require an exact
confirmation-unit scope because values in different `AFRU-MEINH` units are not
comparable; a nonblank `quantity_unit` or `filter_quantity_unit = abap_true`
supplies that scope. Explicit flags make a zero endpoint selectable. Disabled
values must be initial, reversed ranges and unscoped ranges fail before the
repository read, and returned-row drift is rejected. Repository and service
regressions cover each metric, both endpoints, one-sided bounds, zero, invalid
flags, bad ranges, and a repository row outside the bound.

The optional `production_order` filter remains constrained by the material and
plant scope. The
optional `order_category` filter accepts `10` for production orders or `40` for
process orders, and returned rows expose the category. The optional
`operation_counter` filters AFVC-APLZL and requires `production_order` because
internal counters are scoped to a routing. Confirmation searches can also
filter AFVC-ARBID using `resource_object_id`, and returned rows expose that
resource ID. The explicit `filter_resource_object_id` flag matches initial IDs
for operations without an assigned resource; invalid flags and returned
resource-scope drift are rejected. AFVC-ARBID is an SAP-internal object ID;
for work-center assignments, CRHD-OBJID identifies the same object and
CRHD-ARBPL contains the work-center identifier. Direct confirmation and operation reads
populate the field from AFVC, so IDs are available even when no confirmation
exists. `READ_OPERATIONS_BULK` can filter by nonblank `iv_resource_object_id`;
its explicit `iv_filter_resource_object_id` flag selects unassigned operations,
and the service rejects invalid flags or returned resource-scope drift. The
operation rows also expose their production/process order category from
AUFK-AUTYP. `iv_order_category` restricts routing reads to production orders
(`10`) or process orders (`40`); other values and returned category drift are
rejected. The optional `iv_control_key` filters routing operations; its explicit
`iv_filter_control_key` flag selects an initial control key, and returned
control-key drift is rejected. `iv_operation_number` optionally restricts the
operation number and the service rejects rows outside that selection.
`iv_operation_sequence` and `iv_suboperation_number` also filter routing rows;
their explicit flags support exact initial-value matches, including a
base-operation-only selection. Invalid flags and returned routing-key drift
are rejected.
`iv_operation_description` filters exact AFVC-LTXA1 values; its explicit flag
supports exact blank-description matching, and invalid flags or returned text
drift are rejected.
Operation reads return at most 500 rows per page by default and expose a
keyset cursor over order, sequence, operation, suboperation, and AFVC counter.
The full cursor must be supplied to continue; cursors outside the requested
order list and partial cursors are rejected. Operation counts are reported per
page and per requested order. Pages have separate timestamps and are not a
transactionally consistent multi-page snapshot.
Operation and base operation summaries also report the assigned
resource ID, including when base summaries merge confirmation units.
`partial_only` returns confirmations not marked final; `final_only` and
`partial_only` cannot
both be true. The optional `quantity_unit` filter matches AFRU-MEINH; without
it, a page can contain multiple units and the summaries keep them separate. The
`filter_quantity_unit` flag enables exact matching of an initial unit value.
The repository applies it before pagination, and the service rejects invalid
flag values and returned unit-scope drift. The
optional nonblank `control_key` filter matches AFVC-STEUS. The
`filter_control_key` flag enables exact matching of a blank control key; the
repository applies it before pagination, and the service validates the flag and
returned control-key scope. The optional `confirmation_number` filter matches
AFRU-RUECK; an optional `confirmation_counter` narrows it to one AFRU-RMZHL and
requires the number. A noninitial `operation_sequence` filters AFVC-PLNFL. The
`filter_operation_sequence` flag enables exact matching of its initial value;
the repository applies the filter before pagination, and the service validates
the flag and returned sequence scope. Confirmation-window searches also support
an optional AFRU-ERNAM entered-by filter; `filter_entered_by` selects the exact
initial user, and returned rows expose and validate the selected user. The
optional AFRU-ERSDA entry-date range requires both valid ascending bounds, is
applied before pagination, and is checked against returned confirmation rows.
Rows expose the entry date separately from the posting date. Confirmation
searches also expose the last-change date and user (`AFRU-LAEDA` and
`AFRU-AENAM`). The optional last-change date range requires both valid
ascending bounds and is applied before pagination; `filter_changed_by` enables
exact matching of a blank change user. Returned rows are checked against both
selected scopes. An explicit `filter_entry_time` applies a validated inclusive
AFRU-ERZET time-of-day range before pagination; midnight is valid, disabled
bounds must be initial, and the range does not wrap across midnight. Returned
entry times are checked against the selected bounds.
By default, an initial `operation_suboperation` includes the base step and all
suboperations. The `filter_operation_suboperation` flag selects only the base
step; it requires an operation number, is applied before pagination, and its
returned scope is validated.
The service rejects counter-only selections before reading and verifies both
confirmation filters against repository rows. `positive_rework_only` and
`positive_scrap_only` select positive AFRU rework or scrap quantities; enabling
both requires both quantities to be positive. The
four-part cursor is deterministic for a stable result set, but each page is a
separate database read; concurrent postings or corrections can change later
pages.
Window-search confirmations now carry the matching AFPO material and plant in
`scope_material` and `scope_plant`; the service rejects rows that drift from
the required selection. Number-based bulk confirmation rows leave these scope
fields initial because they have no material/plant query scope.
Operation summaries are page-local and are grouped by production order,
AFVC operation counter, operation number, sequence, suboperation, and quantity
unit, with the routing
description and control key from their confirmation rows. They do not represent
totals for later pages or for the complete date window when the result is
truncated. First and last posting dates follow the same returned-page boundary
and exclude the lookahead confirmation. Raw quantity totals include every
returned row, including reversed confirmations. The
`yield_non_reversed_total`, `rework_non_reversed_total`, and
`scrap_non_reversed_total` fields include only rows whose `is_reversed` is not
`abap_true`; they are page-local and do not represent an SAP-calculated net
balance.

Component replenishment quantities are exposed in `MARD-LABST` fields.
Valid lot-size multiples can make a suggested aggregate exceed the field range
even when the shortage and each receipt fit individually. Those results now
raise `zcx_invalid_stock_request` instead of overflowing during quantity
conversion. The result field cannot represent an aggregate outside the
quantity field's range.

Projected alternative-unit receipt quantities from purchasing, transfer,
production, or planned orders must also fit MARD-LABST precision. Overflow and
nonzero quantities that round to zero now raise the request exception instead
of aborting in the repository conversion.

Quota-split proposal amounts outside MARD-LABST range are also rejected
before the purchase-requisition BAPI call.

ATP allocation groups and cumulative date totals are exposed through
MARD-LABST fields and BAPI request quantities. Their internal sums now use
high-precision arithmetic and reject totals outside that range before calling
SAP ATP; the public result and BAPI fields cannot represent larger totals.

The valuation-type FEFO option orders local preview balances from batch expiry
dates; it does not execute SAP configured batch determination or reproduce
target-system strategy settings. Confirm the selected batch sequence against
the material's SAP batch-determination configuration before using it for a
posting decision.

Direct FEFO rechecks were previously validated only for batches selected for
posting. A full-quantity atomic shortfall could leave malformed unselected rows
in the returned shared-capacity summary. Direct, bulk, and atomic preflight now
check recheck identity, date window, reservation exclusions, timestamp order,
unique batch keys, and expiry status/date before allocation, including when no
selection is possible. Selected rows still receive the full status and balance
comparison.

FEFO results previously returned the rechecked snapshot timestamp only after a
selection reached the posting path. Direct, bulk, and atomic results now echo
the validated timestamp and `is_rechecked` flag on full-quantity shortfalls and
skipped rows too, without issuing a movement call. The bulk UOM path previously
let stop-on-failure bypass full validation for later rechecks and omitted their
timestamps on skipped rows. It now validates every supplied recheck before
execution and retains the same metadata as base-unit bulk rows. UOM preflight
previews use each request's requested unit, so skipped rows keep converted base
quantities and shortfall state.

Production-order component and readiness summaries also expose MARD-LABST
quantity totals. They now accumulate in high precision and reject grouped totals
outside that field range before returning the summary. Readiness overflow
regressions exercise requested, confirmed, and unconfirmed totals independently.

Component ATP daily demand, cumulative quantity, and monthly shortage totals
share the same MARD-LABST output limit and now reject overflowing groups.

The local transpiler inferred a scale-zero intermediate for inline
subtraction of packed RESB quantities. `GET_OPEN_COMPONENTS_BULK` now declares
the open quantity as `RESB-BDMNG` before subtracting withdrawn quantity so
high-precision fixture values retain their decimal scale.
Scalar open RESB quantities across plant stock, project stock, sales-order
stock, cost-center reservations, production components, and reservation issue
flows now use the shared `CALCULATE_OPEN_RES_QTY` helper for the same
packed-quantity calculation. Full-item views clamp over-withdrawn rows to zero
open quantity while retaining their required and withdrawn source quantities.
Plant-date availability sums location balances, receipts, and reservations in
high precision before converting the final result. Totals outside MARD-LABST
range raise the request exception through the stock repository interface.

Scalar unrestricted availability now nets MARD and open RESB quantities in
high precision before converting the nonnegative result to MARD-LABST. An
available total outside that field range raises the stock-request exception.

Repeated scoped receipts now update location and batch balances with checked
high precision addition; totals outside those fields raise the stock-request
exception.

Single-plant location allocation also sums available quantities, allocated
summary totals, and matching projected receipt balances. Those totals now use
checked `DECFLOAT34` addition and raise `zcx_invalid_stock_request` when they
exceed the `MARD-LABST` range, instead of overflowing an intermediate packed
quantity field.

Single-plant exact-batch, standard FEFO, and quality FEFO allocation also sum
merged projected receipts, available balances, and allocation summaries.
Those totals now use checked `DECFLOAT34` addition and raise
`zcx_invalid_stock_request` when they exceed the `MARD-LABST` range, rather
than overflowing an intermediate packed quantity field.

Scoped component availability sums batch balances in high precision before
clamping to location totals. Group and demand totals that exceed their output
quantity fields raise the stock-request exception.

Sales-order stock snapshots now aggregate unrestricted stock and eligible open
reservations in high precision, rejecting totals outside their SAP quantity
fields before constructing the snapshot.

Location and batch reservation calculators now keep reservation sums and
negative-balance carry in high precision. Multiple large RESB or MCHB rows no
longer overflow intermediate quantity fields before availability is clamped.

Cross-plant previews previously accepted the receiving plant as a source, even
though stock-transfer order creation rejects same-plant pairs. The ordinary,
dated, FEFO, and batch allocation cores now reject same-plant sources before
reading stock. Local demand should use the single-plant allocation methods.

Plant stock-status category and reservation totals can also exceed the SAP
quantity fields when many locations or reservations are combined. The bulk
FOR ALL ENTRIES read retains LGORT so equal balances from separate locations
are not deduplicated. Scalar and bulk reads report out-of-range totals with
the stock-request exception.

`CREATE_CONFIRMATIONS_ATOMIC` calls `BAPI_PRODORDCONF_CREATE_TT` once per
ticket and defers the shared `BAPI_TRANSACTION_COMMIT` until every ticket has
`iv_test_run` now forwards SAP's `TESTRUN = 'X'` parameter to every ticket, so
simulation does not commit or roll back and does not require generated
confirmation keys. Local tests verify forwarding and keyless simulated
success; the SAP BAPI and automatic goods movement update tasks are not
exercised locally. Verify in the target release that repeated live time-ticket
calls share one rollback-capable SAP LUW, that test runs do not trigger
external effects in installed exits or enhancements, and that automatic goods
receipts or backflushes follow the documented transaction boundary.

`iv_require_full_quantity` on stock allocation previews is a local policy based
on selected stock, location scopes, safety-stock rules, date horizon, batch,
and FEFO filters. It does not reserve stock or make a later SAP reservation or
transfer atomic; another process may consume stock after the preview. Cost-center
multi-demand previews expose this policy across plant, date, location, exact-
batch, and FEFO methods. ATP-enabled dated previews keep SAP diagnostics
separate and do not change the local all-or-nothing allocation. The
sales-order aggregate previews apply the shared option to each remaining
item/cutoff balance. Stock-service and sales-order FEFO base/UOM previews also
allow the all-or-nothing rule on individual demands. Undated cross-plant base
and UOM demand rows support the same option in ordinary, exact-batch, and FEFO
allocation. Their ATP wrappers preserve the local decision and skip checks for
rejected rows. Dated cross-plant ordinary, exact-batch, and FEFO base/UOM demand
rows also support the policy, as do dated location-aware cross-plant demands.
Their ATP wrappers keep it in the local estimate. Single-plant ordinary and
location-aware base/UOM demand rows support it too; date and ATP wrappers
preserve the policy in the local estimate. These previews remain read snapshots
and do not lock or reserve that stock. `ALLOCATE_COMPONENT_STOCK` also supports
per-demand `require_full_quantity`; a short demand receives zero and leaves its
eligible stock available for later demands. The one-call WBS FEFO and location
reservation methods rerun the same allocation
preview before creating reservations and reject the write if the full batch or
location split changes, including FEFO expiry order and location priority.
`ISSUE_PROJECT_WBS_FEFO` uses the same second-snapshot check for WBS goods issue,
comparing allocation summaries, batch splits, effective expiry policy, and WBS
assignments before posting 221/Q. It uses internal request IDs so repeated
caller IDs remain distinct through movement validation. `ISSUE_PROJECT_WBS_FEFO_BY_DATE` also compares
required dates and priority, while `ISSUE_PROJECT_WBS_FEFO_PRIO` compares
priority and forwards optional date-first ordering. Both use internal request
IDs so repeated caller IDs remain distinct through movement validation. SAP
does not lock these rows during that check, so another process can still
consume stock between the second preview and the write. `TRANSFER_WBS_FEFO` also
compares allocation summaries, including effective row-level full-quantity
policy, and batch splits before posting. The base, priority, and dated WBS
location transfer methods compare allocation summaries and location splits the
same way. These checks detect changed snapshots but do not lock project stock.

`ALLOCATE_DEMANDS_BY_PRIORITY` and `ALLOCATE_DEMANDS_UOM_PRIORITY` sort local
bulk demand by descending integer priority, then by input order for ties. They
require unique request IDs to restore caller order in the result and report the
priority used for each allocation. Priority only changes this preview's
calculation order; it does not lock stock, reserve it, or request an SAP ATP
confirmation.
Both methods now expose one-based `allocation_sequence` values in their
caller-order summaries. The sequence records calculation rank across all
demands, including zero-allocation rows; the priority UOM ATP local estimate
preserves it. The corresponding non-priority material/plant methods leave the field initial.
`ALLOCATE_DEMANDS_UOM_ATP_PRIO` checks the resulting positive allocations as a
group per material, plant, and base unit. It reports confirmation separately
and does not reserve stock. Local tests use UOM and ATP doubles; verify base-unit
conversion and the availability check rule against the target SAP setup.
`ALLOCATE_DEMANDS_UOM_ATP` applies the same diagnostic to ordinary bulk UOM
allocations, grouping positive quantities by material, plant, base unit, and
check date (default `sy-datum`). Local tests use repository, UOM, and ATP
doubles; SAP confirmations do not replace the local stock snapshot.

`ZCL_PROJECT_STOCK_SERVICE=>PREVIEW_FEFO_PRIORITY` and
`PREVIEW_BY_LOCATION_PRIORITY` allocate shared project stock in descending
priority order by default and return rows in caller order. The FEFO form also
accepts `iv_prioritize_by_date = abap_true`; it then requires valid per-demand
FEFO dates, processes earlier dates first, and uses priority and input order to
break ties. Its ATP wrapper forwards the option. The FEFO form works on
batch-managed stock; the location form works on batchless stock. The transfer
forms `PREVIEW_TRANSFER_FEFO_PRIORITY` and `PREVIEW_TRANSFER_LOC_PRIORITY`
apply that order to shared source-WBS stock; the transfer FEFO form accepts and
forwards the same optional date-first option to its ATP wrapper. All four
support repeated caller request IDs by correlating each row with an internal
ID; consumers that need to join individual rows should retain a separate row
key. Priority affects the local `MSPR`/reservation snapshot: it does not lock or
reserve stock, include future receipts, or post a transfer.
Batchless WBS priority previews also accept request-specific location ranks.
They map ranks through internal request IDs for repeated caller IDs, and both
the ATP wrapper and `RESERVE_WBS_LOCATION_PRIORITY` preserve the mapped rows
through fresh location checks.
`PREVIEW_TRANSFER_FEFO_PRIO_ATP` and `PREVIEW_TRANSFER_LOC_PRIO_ATP` add grouped
plant-level diagnostics for positive allocations by material, plant, base
unit, and check date (default `sy-datum`). They preserve caller-order local
results and do not confirm special WBS stock or a specific batch or storage
location. Local tests use an availability API double; verify the check rule
and confirmations in the target SAP system.

Unit-aware stock allocation converts demand to `MARD-LABST` precision before
reading stock. Overflow and nonzero source quantities that round to zero base
quantity are rejected by the shared checked converter. Public allocation and
stock-status tests cover both boundaries, including rejection before a stock
read. Target-system `MARM` ratios and ABAP quantity rounding still need
verification with live materials.

`ALLOCATE_BY_EXPIRY_PRIORITY` and `ALLOCATE_FEFO_UOM_PRIORITY` order shared
FEFO demand by descending integer priority, then stable input order by default.
Summaries and batch splits expose a one-based `allocation_sequence` in demand
processing order. Every summary receives a rank, including zero-allocation
demands; each emitted split echoes its demand's rank. With
`iv_prioritize_by_date = abap_true`, they require a valid FEFO date
and process earlier dates first, with priority and input order breaking ties.
They restore caller order in summaries and splits, so request IDs must be
unique. The ATP local estimate preserves the sequence. This only changes the
local preview order; it does not reserve stock or request SAP ATP confirmation.
The quality FEFO variants `ALLOCATE_QUALITY_FEFO_PRIORITY` and
`ALLOCATE_QUALITY_UOM_PRIORITY` expose the same processing sequence on quality
summaries and batch splits and apply the optional date-first ordering to
quality inspection batches; they do not alter the standard unrestricted-stock
pool. Quality UOM ATP local estimates preserve the summary and split ranks.
ATP wrappers, quality posting rechecks, and
`TRANSFER_WBS_FEFO_PRIORITY` posting snapshots forward the option so preview
and posting use the same order.

Planned-order receipts are an optional local estimate from `PLAF`, not a firm
commitment. `iv_include_planned_receipts` selects unfixed orders (`AUFFX` blank);
`iv_include_fixed_planned` selects fixed orders (`AUFFX` nonblank), and enabling
both flags returns both groups as `PLANNED_ORDER` and `FIXED_PLAN_ORDER` rows.
Both groups must be outside planning scenarios (`PLSCN` blank) and
special-stock segments (`SOBKZ` blank), have no sales-order assignment
(`KDAUF` blank), positive `GSMNG`, and basic start/finish dates from today
through the requested horizon. Quantity conversion uses `PLAF-MEINS` and the
material's `MARA-MEINS`/`MARM` conversion. SAP identifies `AUFFX` as the fixed
indicator ([planned-order fields](https://help.sap.com/docs/SAP_ERP_SPV/548d9774d38f4f31adbc2e3d0554921c/d31ebf53d25ab64ce10000000a174cb4.html)).
Selection-service tests use a fake repository. SQLite-backed repository tests
exercise PLAF selection and MARA/MARM conversion reads against a local schema;
they cannot validate the target release's DDIC fields, SQL behavior,
planned-order lifecycle, conversion ratios, or live selection results. SAP describes the selection
fields and dates in its [planned-order coverage criteria](https://help.sap.com/docs/SCMCSCPP/b654ceec39734aca96c6d395cdc7c69f/f39d21900a69431c9a71f12ea897ccc4.html)
and explains that a planned order remains a proposal until
[conversion](https://help.sap.com/docs/PRODUCT_ID/af9ef57f504840d2b81be8667206d485/c498b6535fe6b74ce10000000a44147b.html?locale=en-US&state=PRODUCTION&version=latest).
Planned orders may be rescheduled, changed, or deleted, and the local estimate
does not reserve capacity, validate component availability, or call SAP ATP.

Known scope limitation: local `MARD`, `MARC`, `MARA`, `PLAF`, `EINA`, `EINE`,
`VBAP`, `VBEP`, `VBUP`, and BAPI dictionary definitions model only the fields
used by this project. The SAP system's delivered definitions are authoritative
at deployment time. BAPI
calls and the sales-order repository's database reads cannot be exercised by
the local transpiler tests; those tests use fake APIs. Local linting and
transpilation also do not validate `CALL FUNCTION` parameter names against SAP
function module signatures. Check those calls in the target system's BAPI
Explorer or equivalent SAP development tooling. The sales-order base-unit
conversion depends on the target release populating `BAPISDIT-SALES_QTY1` and
`SALES_QTY2`; verify this with a known material and order in that system. Open
schedule-line open quantity calculation reads `VBEP-WMENG`, `VBEP-VSMNG`, and
`VBUP-LFSTA`; fallback item quantities read `VBAP-KWMENG` and `VBAP-VSMNG`.
Verify these fields and delivery status behavior in the target SAP release.

`ALLOCATE_QUALITY_UOM_ATP_PRIO` checks the result of priority-ordered
quality-inspection allocation through the ordinary plant ATP API. ATP results
remain diagnostic and may not include the quality-inspection quantities being
allocated; verify the checking rule and stock-category behavior in the target
SAP system before using confirmations as a quality-stock commitment.

The production stock factory is now exercised end to end against SQLite MARD,
RESB, MCHB, MCHA, and MCH1 fixtures. Tests cover reservation netting, shared
demand allocation, FEFO expiry ordering, and batch splits. This verifies local
service/repository composition but does not validate live SAP DDIC definitions,
authorizations, or Open SQL behavior.

`ZCL_SO_STOCK_SERVICE` resolves a sales item's material and plant from `VBAP`
when called by order/item, then reads sales-order stock from `MSKA-KALAB`,
scoped by sales document, item, material, plant, and special-stock indicator E, then
subtracts open, non-deleted special-stock E requirements from `RESB`. The
returned location/batch rows contain gross stock quantities; only the result's
aggregate `available_quantity` is net of reservations. The result also returns
the active open reservation rows with their outstanding quantities; closed
rows are excluded. An optional `reservation_through_date` deducts dated rows
whose `RESB-BDTER` requirement date is on or before the cutoff; undated rows are
still deducted conservatively. Future rows remain visible in reservation
detail, but are excluded from the net total. SAP describes `RESB-BDTER` as the
item-level requirement date ([reservation date guidance](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167776.html)). This remains a current `MSKA`
stock snapshot, not a date-phased projection: it adds no future supply and does
not reserve or lock stock. SAP documents sales-order stock as assigned to the
relevant order/item ([sales-order stock
overview](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91b21005dded4984bcccf4a69ae1300c/6362bd534f22b44ce10000000a174cb4.html)).
`READ_STOCK_IN_UNIT` and `READ_STOCK_BULK_IN_UNIT` convert the aggregate
unrestricted, reserved, and available quantities with the material UOM ratio.
Bulk unit reads for the same item and cutoff share one calculated snapshot;
different cutoffs return separate reservation and availability totals from the
same batched stock read. The attached stock snapshot and row details remain in
base units. Local tests use UOM repository doubles and do not verify the target
system's `MARM` conversion ratios or quantity rounding; unknown or invalid
ratios are rejected.
`PREVIEW_ISSUE_DEMANDS` compares each requested quantity with the item's
aggregate net availability. Repeated requests for one item and cutoff share a
stock snapshot and consume it in input order. Different cutoffs use independent
availability pools. A row's available quantity is the remaining aggregate
balance before its demand, while the attached stock snapshot retains the
initial balance for that cutoff. These aggregate methods do not identify a
batch/location split; `MSKA` rows remain gross.
`PREVIEW_ISSUE_DEMANDS_IN_UNIT` converts using the material's `MARA-MEINS` and
`MARM-UMREZ`/`UMREN` ratio and returns both source-unit and base-unit totals. It
rejects missing or invalid ratios and a positive request that converts to zero
base quantity. Repeated item demands, including demands in different source
units, share the same remaining base-unit balance within each cutoff group;
different cutoffs have independent balances. Validate live material conversion
data and rounding behavior in the target release; the result remains an
aggregate availability snapshot.
Both aggregate issue previews can order requests by required date and descending
priority before consuming a shared item/cutoff balance. They return results in
caller order and echo those fields. The ordering is advisory; it does not set
reservation dates, lock `MSKA` stock, or change how SAP posts an issue.
Their priority-only option orders by descending integer priority without
requiring dates, and input order breaks ties. It has the same snapshot and
posting limitations.
`PREVIEW_ISSUE_DEMANDS_BY_FEFO` and `PREVIEW_ISSUE_FEFO_UOM` add an advisory
batch/location split using the `MSKA` quantities and expiration dates from
`MCHA`/`MCH1`. Reservation rows with a location or batch are deducted from
matching balances first. Open reservation quantities without a full scope are
assigned against eligible FEFO balances first, then the eligible split total is
capped at the aggregate reserved-net quantity. This avoids suggesting more than
the aggregate total, but it cannot determine which physical stock SAP will
consume for an unscoped reservation. Expired lots and lots below the requested
minimum shelf life are excluded. Local tests use repository and UOM doubles;
verify `MCHA`/`MCH1` lookup semantics, `RESB` assignment behavior, and split
rounding in the target release. The result remains a snapshot and does not lock
stock; SAP validates the actual issue. A request can optionally name one batch;
that demand reads its availability and creates splits only from that batch,
while repeated requests for the same batch share the remaining balance. The
stock snapshot on each summary remains aggregate. Unscoped reservation
assignment still follows the FEFO policy across all batches before exact-batch
demands are allocated, so this is a policy-based estimate when reservations do
not identify their physical batch. A FEFO demand can also set an exact
`storage_location`, optionally together with `batch`. By default the location
is a hard filter. With `allow_location_fallback`, it is preferred only among
locations for the same batch and expiration date; expiry and batch order remain
primary, then other locations follow ascending code. The selected location and
fallback flag are echoed for consumers. This local policy does not change SAP's
ATP scope or lock stock.
Both FEFO previews accept `it_storage_location_priority` to resolve ties when
expiry date and batch match across locations. Listed locations follow caller
order; unlisted locations follow ascending code order. The preference is a
tie-break after expiry and batch sorting, so it does not override FEFO order.
When fallback is enabled, the request's selected location remains first within
that tie. Blank and duplicate entries are rejected before stock reads. The
issue service forwards the same list into its base-unit and UOM rechecks; local
coverage verifies the selected splits, while live SAP batch and stock behavior
remains unverified.
Both FEFO previews also accept request-specific location priorities. Positive
ranks override the shared location list for that request; equal ranks use
location code, and unranked locations follow ranked locations by code. A
selected location with fallback enabled remains first. Blank rows, nonpositive
ranks, repeated request/location pairs, and unknown request IDs are rejected
before stock reads. The issue and reservation services forward the priorities
through base and UOM rechecks; the same snapshot and live SAP behavior
limitation applies.
FEFO issue demands can carry a required date, which raises that demand's local
expiry cutoff to the later of the shared as-of date and its required date. The
optional priority mode orders shared item/cutoff balances by required date and
priority, then restores caller order. It remains a snapshot over current `MSKA`
and open `RESB` data; the date does not lock stock or change SAP's issue rules.
The priority-only option orders those balances by descending integer priority;
input order breaks ties, and any required date still sets its local expiry
cutoff. It uses the same snapshot and read-to-post limitations.
Each demand can also require its own minimum remaining shelf life; the larger
of the per-demand value and shared `iv_min_days` filters its eligible batches.
The effective value is echoed on summaries and splits and checked by the issue
and reservation consumers. This policy uses local `MCHA`/`MCH1` expiry data and
does not invoke SAP batch determination. `require_known_expiry` can exclude
unknown-expiry batches for one demand while the shared option allows them for
other demands; the decision relies on local expiry metadata and does not ask
SAP to determine a batch. Nonblank expiry dates returned by the SO stock
repository are checked as Gregorian dates; corrupt repository data rejects the
preview instead of entering the FEFO sort.
`ISSUE_SALES_ORDER_FEFO` consumes these splits as movement 231/E after checking
the summary totals, base-unit mappings, batch identity, expiry date, and echoed
shelf-life policy. It validates required-date and priority metadata against each
batch split and checks that a supplied required date is valid and no later than
the effective FEFO cutoff. When a location preference is present, it requires
the summary and batch split echoes to agree; without fallback, every physical
split must use that location. Sales-order FEFO reservation creation applies
the same check. It defaults to full allocation and does not reread or lock
stock, so a concurrent stock change can still make SAP reject the posting.
The preview can contain multiple independent cutoff groups for the same order
item. The posting consumer rejects mixing those groups in one document to avoid
issuing the same physical stock twice; submit each cutoff scenario separately.
`ISSUE_SO_FEFO_SELECTED` can filter a multi-cutoff result by unique request IDs
before posting, so one scenario can be selected without rebuilding the preview.
`ISSUE_SO_FEFO_SEL_RECHECKED` applies the same selection to an original and a
fresh result, compares only the selected rows and their snapshots, and posts
the refreshed rows when identical. The caller still needs to recompute the
preview immediately before posting.
`ISSUE_SO_FEFO_RECHECKED` compares the original output with a second preview,
including stock, reservation, and split rows, and posts the second output only
when the result is identical. The caller must rerun the preview with matching
demands and options immediately before posting; this check still does not lock
the SAP stock. `ZCL_SO_FEFO_ISSUE_SERVICE->ISSUE_FEFO` runs the second preview
inside the posting workflow, reducing the chance that callers compare different
options or fail to refresh. `ISSUE_FEFO_UOM` applies the same recheck flow after
converting alternative-unit demands into base-unit splits. Optional request IDs
select a subset after rechecking the full demand set; malformed or unknown IDs
are rejected before stock reads. The read-to-post race remains because the
service does not lock sales-order stock.
The service provides a read snapshot only; it does not lock stock or create a
reservation. SQLite-backed repository tests execute the VBAP/MSKA/MARA/MCHA/
MCH1/RESB read paths, but do not validate target-release field availability,
special-stock reservation rules, authorizations, or concurrent changes.
Verify `VBAP-MATNR`/`WERKS`, the queries, and quantity semantics in the target
system before using the aggregate as a posting decision.

`ZCL_PLANNED_ORDER_SERVICE` sends planned-order material, planning plant,
quantity, and end date to `BAPI_PLANNEDORDER_CREATE`. Local tests validate the
adapter mapping and the service's shared-commit rollback behavior, but do not
run the SAP BAPI. The stub models only the header fields used here. Verify the
function signature, base-unit quantity semantics, end-date scheduling, and
rollback behavior for multiple creates in one LUW in the target release.
Create services now expose `iv_test_run` and pass `TESTRUN = 'X'` through the
adapter; local tests cover keyless simulated success, no commit/rollback, and
bulk stop behavior. Confirm the TestRun parameter and its behavior in the
target release, including installed exits or enhancements.

`DELETE_ORDERS_ATOMIC` uses `BAPI_PLANNEDORDER_DELETE` and commits the group
once. The local API double verifies prevalidation and rollback handling, but
does not confirm the BAPI parameter names, delete eligibility, or rollback of
multiple delete calls in the target SAP release. Check these in BAPI Explorer
and with a representative planned order before integration.

`CHANGE_ORDERS_ATOMIC` and `CHANGE_ORDERS_BULK` send selected quantity,
start-date, finish-date, and firming-indicator fields with their `BAPIPLAF_I2X`
update flags to `BAPI_PLANNEDORDER_CHANGE`. The firming value corresponds to
the planned-order fixed indicator (`PLAF-AUFFX`); verify the target release's
BAPI mapping and blank-value unfix behavior. Local stubs contain only fields
used here, and tests use an API double. Confirm the function signature,
supported change fields, quantity unit, and multi-call commit/rollback boundary
in the target SAP release before use.

`READ_ORDERS_BULK` selects requested planned orders from `PLAF` and reads
`MARA`/`MARM` for base units and order-unit ratios. SQLite-backed repository
tests exercise these batched reads, including missing optional material and
unit rows, but not target SAP SQL, authorization, or live conversion data.
Verify those in the target release. The service preserves raw quantities and
reports conversion failure when a required base-unit ratio is missing.

`CONVERT_PLANNED_ORDERS_ATOMIC` and `CONVERT_PLANNED_ORDERS_BULK` call
`BAPI_PRODORD_CREATE_FROM_PLORD`. Local API doubles cannot validate that the
function module is available in the target release, its parameter signature,
conversion eligibility, or whether multiple conversions share the expected
LUW boundary. Confirm the BAPI and its transaction behavior in the deployed
system before use. A bulk call can partially complete; reconcile its per-order
commit results.

`ZCL_PROD_ORDER_SERVICE->CREATE_ORDER` sends the request fields modeled in the
local `BAPI_PP_ORDER_CREATE` stub to `BAPI_PRODORD_CREATE`, then commits through
`BAPI_TRANSACTION_COMMIT`. The bulk form commits each created order separately;
the atomic form calls the create BAPI repeatedly before one shared commit and
requests rollback if any create or commit fails. Local tests validate mapping
and transaction orchestration with an API double; they do not invoke SAP.
Verify the target release's BAPI signature, required order-data fields,
order-number assignment, planning-plant behavior, material/UOM, date scheduling,
BOM and routing determination, and commit/rollback behavior across repeated
create calls. The service requires callers to supply quantity in the provided
SAP internal unit and at least one basic date; there is no BAPI simulation flag.
Bulk create and change now support opt-in stop-on-failure after a returned BAPI
or commit failure. The result keeps every validated row and identifies
unattempted rows separately; earlier independent commits remain committed.
Local static validation does not establish the target release's update-task or
rollback behavior, so verify that a failed operation leaves the LUW ready for
the next request when continuing in default mode.

`ZCL_PROD_ORDER_SERVICE` passes the caller's release-control value to
`BAPI_PRODORD_RELEASE`, maps `BAPI_ORDER_RETURN` detail rows by order number,
and commits either a group or individual orders. Local tests exercise the
mapping and transaction service with API doubles, not SAP. Verify the target
system's `CO_RELEASE_CTRL_ORDER` values, release eligibility, BAPI parameter
signature, application-log behavior, and group rollback boundary before use.
The local BAPI order-key, detail-return, and application-log stubs include only
the fields used by this adapter. Independent bulk release methods now support
opt-in stop-on-failure with separate skipped-row accounting; earlier commits
remain. Local validation does not establish target SAP update-task behavior
after a failed release.

`RELEASE_OPERATIONS_ATOMIC` and `RELEASE_OPERATIONS_BULK` call
`BAPI_PRODORD_RELEASE_OPERATION` and map detail returns by order and operation.
SAP documents operation-level release, the PREL order status while only some
operations are released, and the prerequisite that preceding operations are
released first ([operation release rules](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/34de0103497c4b80a7c7fbf6952ff971/73653beedd5241ed9ec3b4cee5229faa.html),
[SAP BAPI catalog](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
Local tests use API doubles and do not validate the target function-module
signature, `BAPI_ORDER_OPERATION_KEY`/`BAPI_ORDER_RETURN` operation fields,
release-control value, operation-number conversion, authorization, or multi-call
LUW behavior. Confirm those details in the target system before operational
use; the service expects a four-character internal operation number with
leading zeros preserved. Bulk operation release supports opt-in
stop-on-failure; earlier per-operation commits remain. SAP's OData API independently exposes a
`ReleaseOperation` action keyed by manufacturing order and operation
([Production Order API](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/0a4262096d2e43258df27c594bdd1468.html)).

`CANCEL_CONFIRMATIONS_ATOMIC` and `CANCEL_CONFIRMATIONS_BULK` call
`BAPI_PRODORDCONF_CANCEL` with the confirmation number, counter, and mandatory
posting date documented by SAP
([cancellation field mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-cancellation-for-production-time),
[SAP BAPI catalog](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
Local tests use API doubles. Confirm the target function-module signature,
posting-date behavior, cancellation side effects on confirmation-linked goods
movements, authorization, and shared/individual LUW boundaries in the deployed
SAP release before using these methods operationally. Bulk cancellation also
supports opt-in stop-on-failure; earlier cancellation commits remain in place.

`READ_CONFIRMATIONS_BULK` selects AFRU confirmation rows for requested
production/process orders and joins AFVC by routing number and operation
counter to return the operation and sequence. It also returns AFRU yield
(`LMNGA`), rework (`RMNGA`), scrap (`XMNGA`), and entry-unit (`MEINH`) values
without converting or netting them. The local AFRU and AFVC stubs contain only
fields used by this query. Local service tests use a repository double and
cannot verify target table fields, quantity semantics for reversals, join
cardinality, authorizations, or whether archived confirmations are available.
Confirm the selection and reversal semantics against the target release and
representative orders
([SAP operation-confirmation fields](https://help.sap.com/doc/9840fb99f9a74026ab7f1929fde9c454/3.0.3/en-US/SAPEdgeServicesOnPremEssentialBusinessFunctionsAPIGuide30FP03.pdf),
[SAP quantity confirmation fields](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/327cb6535fe6b74ce10000000a174cb4.html)).

`READ_OPERATIONS_BULK` reads AFKO routing numbers and joins AFVC by AUFPL to
return operation counters, sequences, operation/suboperation numbers,
descriptions, and control keys. Local tests validate bulk grouping and response
checks through a repository double; they do not execute this SQL against SAP.
Verify the target release's AFKO/AFVC field definitions, routing join
cardinality, sequence/suboperation representation, and authorization behavior
with production and process orders. SAP's operation view and routing mapping
document these identifiers
([operation data view](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/afa5a1dc1d81424784b89e079cec0b48.html),
[routing field mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-routing)).

`CREATE_CONFIRMATIONS_BULK` sends one operation time ticket at a time to
`BAPI_PRODORDCONF_CREATE_TT`; the bulk service defers commit until it verifies
the returned order, operation, and sequence match the request. SAP's examples map order, operation, sequence, yield, scrap, rework,
and final-confirmation values and call `BAPI_TRANSACTION_COMMIT` after the
BAPI. The adapter reads the per-row `BAPI_CORU_RETURN` message and confirmation
number/counter. Both bulk confirmation methods support opt-in stop-on-failure;
earlier independent commits remain. Local stubs model only fields used by this feature, and local
tests use an API double; verify the BAPI signature and detail-return key fields
in the target release. Configured automatic goods receipt and backflush can
post inventory as part of confirmation; failed goods movements may need COGI
reprocessing. Review order/work-center configuration and test representative
orders before production use
([SAP PCo example](https://help.sap.com/doc/302a83e81be74549bbc31509bb1b4246/15.5.5/en-US/Application_HELP_EN.pdf),
[SAP time-ticket mapping](https://help.sap.com/docs/sap-digital-manufacturing/integration-guide/mapping-production-yield-confirmation),
[SAP confirmation test case](https://help.sap.com/docs/SUPPORT_CONTENT/prodord/3138697834.html?locale=en-US)).

`RELEASE_ORDERS_AFTER_ATP` uses a fresh component ATP preview as a release gate,
but the check does not reserve stock. Concurrent issues or receipt changes can
make the subsequent release unavailable; the target BAPI and release-control
customizing remain authoritative. The checker summarizes open components
selected through `RESB`; confirm those filters and the chosen ATP check rule in
the target release. Orders with no open component rows have no component
shortage to block release. Local tests use a readiness-checker double and do
not exercise the SAP ATP BAPI or its concurrency behavior.

`RELEASE_ORDERS_BULK_AFTER_ATP` validates the complete readiness response before
the first release call, then commits each ATP-ready order independently. A
shortage blocks only its own order by default; `iv_stop_on_failure` can stop at
the first ATP block or failed release/commit. If an earlier ready order fails,
a later blocked order is skipped, while `atp_blocked_count` still reports its
readiness diagnostic. Skipped rows are separate from failures. A BAPI or commit
failure can leave earlier orders committed. The overall result is therefore
not atomic and callers must reconcile per-order ATP, release, and commit states.
The availability check is not a reservation, and local tests use a readiness
double rather than SAP ATP.

`CHANGE_ORDERS_ATOMIC` and `CHANGE_ORDERS_BULK` call
`BAPI_PRODORD_CHANGE` with the quantity/date subset of
`BAPI_PP_ORDER_CHANGE` and corresponding `BAPI_PP_ORDER_CHANGEX` flags. Local
tests verify payload flags and service transactions with API doubles; they do
not verify target DDIC fields, quantity-unit semantics, supported field
combinations, scheduling recalculation, or multi-call LUW behavior. Confirm
these details in the target BAPI Explorer and with a representative order.
Bulk changes may partially commit, so reconcile every request row's BAPI and
commit result.

`COMPLETE_ORDERS_TECH_ATOMIC` and `COMPLETE_ORDERS_TECH_BULK` call
`BAPI_PRODORD_COMPLETE_TECH` and use the shared transaction API for commit or
rollback. Local tests do not verify the target function-module signature,
whether multiple BAPI calls share one LUW, or status-transition eligibility.
SAP documents technical completion as a logistics end state that removes open
requirements and prevents further order changes. Confirm the order's component
and capacity state and the target BAPI behavior before invoking it; the methods
do not offer a test-run mode.

`SET_DELETION_FLAGS_ATOMIC` and `SET_DELETION_FLAGS_BULK` call
`BAPI_PRODORD_SET_DELETION_FLAG`; they set DLFL and do not delete order data.
Local tests use an API double and do not validate target status prerequisites,
residence-time customizing, BAPI signature, or LUW behavior. SAP documents an
AFS limitation: the BAPI does not remove fixed batch assignments and update
related stock tables, so it is not recommended for AFS orders with fixed batches
([SAP AFS BAPI limitation](https://help.sap.com/doc/ddd743d1660847cc98ed15b46ddf5307/6.0/en-US/Release_Notes_SAP_AFS_60E.PDF)).
The caller must confirm whether that limitation applies to the target system.

`CLOSE_ORDERS_ATOMIC` and `CLOSE_ORDERS_BULK` call `BAPI_PRODORD_CLOSE` and
set status CLSD. Local tests use an API double and cannot validate the target
function signature, status profile, closure prerequisites, or multi-call LUW
behavior. SAP documents the close operation for orders in REL or TECO status;
verify target-system eligibility and reconcile per-order commits when using
the bulk operation ([SAP close-order operation](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/950a6264f8fa4168a89ac15f79f4880a.html?locale=en-US)).

`SET_DELETION_INDICATORS_ATOMIC` and `SET_DELETION_INDICATORS_BULK` call
`BAPI_PRODORD_SET_DEL_INDICATOR` and assume SAP has already set DLFL. Local
tests use an API double and cannot validate the target BAPI signature,
DLFL/DLT status transition, authorization, or multi-call LUW behavior. SAP
documents DLFL as a prerequisite for setting the deletion indicator; verify
the target system's status profile and deletion/archiving process before use
([SAP deletion-indicator prerequisite](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/a6f0333202384ba2b48a841a4a6deb1b/756a590e8f7942a1a25549e80762e74f.html)).
Technical completion, deletion-flag, close, and deletion-indicator bulk writes
also support opt-in stop-on-failure. Their result rows identify unattempted
orders separately; earlier commits remain committed. Local API doubles do not
verify whether a failed lifecycle BAPI leaves pending SAP updates before a
subsequent call in default continue mode.

`ZCL_PROD_ORDER_READ_REPO` reads AFPO output items for order categories 10 and
40, then matches AFKO dates and AUFK raw phase/deletion flags. It separately
reads active JEST statuses and resolves system text from TJ02T and user text
from TJ30T using the logon language and AUFK status profile. Confirmation
reads match AFRU to AFVC by routing and operation counters; operation reads
match AFKO routings to AFVC operations and retain only production/process order
categories. Missing status text leaves the code visible with blank names.
Orders with no matching AFPO item are reported as not found. Quantities are
converted using AFPO's order-to-base ratio; a missing order or base unit,
negative quantity, or nonpositive ratio leaves that item's converted quantities
unset and increments the conversion-failure count. Items stay separate because
an order can have multiple outputs. SQLite-backed Open SQL tests execute all
four repository reads and cover category and active-status filtering, text
mapping, inner-join behavior, and result ordering. Service-level tests use
repository doubles. The local tests do not validate the target's table fields,
status-code convention, language-specific text coverage, order-item
conventions, or authorization behavior. SAP documents that the read status API returns active statuses and
distinguishes system from user status
([active production-order statuses](https://help.sap.com/docs/SAP_S4HANA_CLOUD/d35113ee62644d3abee1aaec148291d9/a144fb0d4c4a48958e1c39451391db22.html?locale=en-US&source=redirect&state=PRODUCTION&version=2602.500),
[production-order system and user statuses](https://help.sap.com/docs/SAP_ERP/bfece09273bd474d82fdd97bae070c25/8e04b753128eb44ce10000000a174cb4.html)). SAP describes
AFPO order/received quantities, AUFK order categories, and AFKO basic dates
([production-order item quantities](https://help.sap.com/doc/419ffea5f9b6488da138a9b8d65d508b/3.15/en-US/Sample%20Content%20Process%20Mining%20on%20SAP%20S4HANA%20Production%20Planning.pdf),
[production-order categories](https://help.sap.com/docs/SUPPORT_CONTENT/bwdabc/3361383658.html),
[basic order dates](https://help.sap.com/docs/SCMCSMLM/30a17d2e0ca94c9dbf22cff7767c78ae/10d50b3f79f01014becffb4ca746ffe7.html)).

`CREATE_ORDERS_BULK`, `DELETE_ORDERS_BULK`, `CHANGE_ORDERS_BULK`, and
`CONVERT_PLANNED_ORDERS_BULK` commit each planned-order operation separately
and continue after failures by default. Their optional `iv_stop_on_failure`
flag halts later calls after the first failed BAPI result or commit. This does
not undo earlier committed rows. Local API doubles cannot confirm the target
BAPIs' LUW behavior or that a failed operation leaves no pending update before
the next call. Verify this failure boundary in the target SAP release. Reconcile
the per-row attempted, skipped, and commit status rather than relying only on
the overall flag.
`CREATE_FROM_SUGGESTIONS_BULK` uses this same per-lot write boundary and retains
the source suggestion and receipt indexes in each row. Review both indexes and
the row attempt, skipped, and commit status when reconciling a partially
completed suggestion batch; it forwards the same stop-on-failure option.

Sales-order item rejection updates map `BAPISDITM-REASON_REJ` and its
`BAPISDITMX` update flag through `BAPI_SALESORDER_CHANGE`. The caller must use
a reason code configured in the target system under Sales and Distribution >
Sales > Sales Documents > Sales Document Item > Define Reasons for Rejection
([SAP Help](https://help.sap.com/docs/SAP_S4HANA_ONPREMISE/7b24a64d9d0941bda1afa753263d9e39/a172c6d76bcb4db0863f39fa22a94362.html)).
Local tests use a fake API, so verify the BAPI field names, reason-code
validation, simulation behavior, and transaction handling in the deployed SAP
release. The local BAPISDITM/BAPISDITMX stubs model only fields used here.
`clear_order_item_rejections` sends an initial `REASON_REJ` value while setting
the matching `BAPISDITMX` update flag. SAP documents that a blank rejection
reason removes an existing reason in its inbound sales-order API
([SAP Help](https://help.sap.com/doc/ce01d82756b947a1a043a5d5a3204226/2308.502/en-US),
[SAP Help, ERP document fast change](https://help.sap.com/doc/63531b2cfef44d9eb63b4a5d9c70c7c1)).
That supports the clear operation's intended semantics, but does not confirm
the behavior of `BAPI_SALESORDER_CHANGE` in every target release. Verify the
blank-field update with a test order before integration; fully delivered items
or follow-on documents may also restrict changes.
Order reads expose rejected items separately using `BAPISDIT-REASON_REJ`,
`REQ_QTY`, `SALES_UNIT`, and `SALES_QTY1/SALES_QTY2`; they do not load delivery
schedule data or enter allocation demand. The adapter converts rejected sales
quantities to the material base unit and reports conversion failure on the read.
Verify these fields and the sales-unit ratio meaning in the target release.

Sales-order reservations call `BAPI_RESERVATION_CREATE1` with movement type
231, ATP check enabled, and sales-order/item assignment. Verify BAPI
availability, signature, movement-type behavior, and ATP/customizing results
in the target release. The local stub covers only fields used by the adapter
and is not a replacement for that system's DDIC definition.
`reserve_so_stock_fefo` maps each batch/location split to this reservation API
and commits the reservation requests as one transaction. SAP's reservation
document documentation requires both sales order and item for movement 231
([SAP Help](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/03a55f57017647368bfb386e41573ff7.html)).
`reserve_so_stock_fefo_selected` filters the caller's preview to selected
request IDs and their matching batch splits, allowing separate cutoff scenarios
to be reserved independently. The selection validates ID presence and
uniqueness but does not refresh stock.
`reserve_so_fefo_rechecked` compares an original preview with a caller-supplied
fresh result, including stock rows, open reservations, summary quantities, and
batch/location splits. It can compare selected request IDs from a multi-cutoff
result. It does not itself execute the preview read or lock stock; inventory can
change between comparison and reservation creation.
`reserve_so_fefo_demands` and its UOM variant perform the preview and BAPI
reservation steps in one service call, but the repository read still does not
lock the sales-order stock, so another SAP transaction can consume it before the
BAPI reservation succeeds or fails its ATP check.
Each FEFO demand may set `allow_undated_batches` to opt into undated stock when
the shared option is false, or `require_known_expiry` to exclude it when the
shared option is true. The flags conflict when both are true; the preview echoes
the policy and reservation, goods-issue, and recheck paths validate it.
`reserve_so_fefo_recheck` and `reserve_so_fefo_uom_recheck` obtain a fresh
preview inside the service and compare it with the caller's original. They
narrow the stale-preview window but cannot prevent stock changes between that
read and BAPI creation.
The SO FEFO `it_location_allowlist` is one shared location set for the whole
request collection. `it_request_locations` adds request-specific sets, and the
two filters intersect when both are supplied. Unknown request IDs, duplicate
scope rows, and selected preferred locations outside their applicable sets are
rejected. These filters inspect only locally read sales-order stock rows; they
do not check SAP storage-type, warehouse, or authorization rules. The preview
returns the filters with its allocation; goods-issue and reservation consumers
check selected splits against them, and rechecks compare the filters as well as
the snapshot and split data. Selected-request results retain the shared filter
and only the selected requests' scoped rows. Validate the same lists and
business restrictions in the target system.
The local tests exercise the adapter contract with a fake API, not the deployed
`BAPI_RESERVATION_CREATE1`; verify sales-order stock E handling, batch/plant
semantics, ATP behavior, and the selected requirement date in the target
release. The preview does not lock the stock before reservation creation.

Cost-center reservations call `BAPI_RESERVATION_CREATE1` with movement type
201 and the cost-center account assignment in the reservation header. The
local `BAPI2093_RES_HEAD` stub now includes `COSTCENTER`, but the transpiler
tests use a fake API and cannot verify the BAPI signature, field semantics,
ATP behavior, cost-center validation, or target-system configuration. Confirm
the header assignment and item fields against the deployed SAP release before
integration. Alternative input units use the local `MARA` base-unit and
`MARM-UMREZ`/`UMREN` queries; tests use repository doubles and do not validate
those fields, SAP quantity conversion, or rounding precision in the target
release. The BAPI receives the allocated quantity in the material base unit.
When no storage location is supplied, the adapter sends one reservation item
for each positive location or batch/location allocation in a single
`BAPI_RESERVATION_CREATE1` call. A supplied location is a hard restriction by
default; `iv_allow_fallback` makes it the first choice and permits other
locations afterward for the remainder. The fake API tests verify the split
mapping, but the multi-item BAPI behavior must be checked in the target
release. Opt-in
FEFO cost-center reservations reuse the local `MCHB`/`MCHA`/`MCH1` expiry and
reservation estimate; the test doubles do not validate those reads. This local
FEFO choice bypasses SAP's configured batch-determination strategy; verify that
the target BAPI accepts the selected item-level batches and check its ATP
result. The optional `iv_include_undated_batches` flag filters unknown-expiry
stock from exact-batch and FEFO previews and reservations when false; the
default includes it. Single- and cross-plant exact-batch and FEFO demand rows
can set `require_known_expiry` to exclude undated quantities for that request,
and FEFO rows can opt in with `allow_undated_batches` when the shared setting
is false. Cost-center batch and FEFO previews and reservation demands support
both row overrides, and the single-request preview and reservation APIs accept
them as scalar inputs. Result summaries and batch/location splits echo the row
policy. `issue_cost_center_batches` repeats exact-batch eligibility checks
from the preview and uses the later of its required date and the goods-movement
posting date as the expiry cutoff. This remains dependent on local batch-expiry
metadata; it does not lock or refresh stock, invoke SAP batch determination, or
confirm how the target movement API handles expired batches.
This depends on local batch-expiry metadata and does not make SAP ATP or the
reservation BAPI confirm the selected expiry. Single and multi-demand FEFO
accept an optional exact-batch filter,
which narrows this local estimate without changing the SAP batch-determination
or ATP limitations. `preview_for_cost_center` uses the local stock estimate by
default. Its
optional `iv_check_atp` setting adds a plant-level SAP ATP result separately;
the ATP request does not retain a batch or storage-location restriction and
does not change the local allocation or preview success flag. The preview's
confirmed and unconfirmed base quantities total and cap the returned
confirmation lines; SAP's raw result remains available. Preview does not persist
a reservation. `reserve_for_cost_center` can request the same plant-level
precheck; `iv_require_atp_confirmation` stops before reservation creation when
the requested base quantity is not fully confirmed. The flag requires ATP
checking and accepts only `abap_true` or `abap_false`. The ATP API is mocked
locally, so confirm the target release's BAPI signature and check-rule behavior
in SAP.

`read_cost_center_reservations` reads the relevant `RKPF` headers and `RESB`
reservation items in batches, then matches them by reservation number and
filters the header-level cost center. It returns open movement-type 201
standard-stock items and excludes deleted or finally issued rows. SAP
documents the cost-center assignment on the reservation header and
movement type 201 as a cost-center goods issue ([reservation header](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/03a55f57017647368bfb386e41573ff7.html),
[header-level cost center](https://userapps.support.sap.com/sap/support/knowledge/en/3736490),
[movement type 201](https://help.sap.com/docs/SAP_ERP/a70c5fce76eb44adb0c86a9d3059e4dd/1663bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest)).
SQLite-backed Open SQL tests exercise the batched reads, filters, scope mapping,
and sorting. They do not validate SAP query plans, authorization, or target
DDIC behavior. The single-center wrapper and bulk read use the same two batched
queries. The inquiry is not a lock;
an item can change after the read and before a subsequent delete or goods
movement.
`PREVIEW_CC_ISSUE_REMAINING` exposes this open-item snapshot, optionally
filtered by reservation number. `POST_CC_ISSUE_REMAINING` requires an explicit
number list and delegates positive open quantities to the cost-center bulk
issue path, which checks the scope again and reads reservation details before
posting. Commits remain independent per reservation; a later failure can leave
earlier issues committed. `POST_CC_ISSUE_REMAINING_ATOMIC` rechecks each
reservation's cost-center scope before staging its movement, then requests one
shared commit or rollback. Local tests use reader and movement doubles; verify
repeated reservation-referenced BAPI calls share a LUW in the target release.
`PREVIEW_CC_REMAINING_ITEMS` lets callers select exact reservation/item pairs;
`POST_CC_REMAINING_ITEMS_ATOMIC` stages only those open quantities and
revalidates each item against the cost-center scope before posting. Its inquiry
and scope reads do not lock `RESB`; verify race behavior and the shared LUW in
the target SAP release. `POST_CC_REMAINING_ITEMS` uses independent commits per
reservation, so earlier reservations can remain issued if a later one fails.
`POST_CC_ISSUE_REV_ATOMIC` validates selected reservation/item scopes before
staging and rechecks each reservation before its unit-aware reversal in one
shared LUW. `PREVIEW_CC_REV_REMAINING` reads reservation details after a
cost-center scope check; `POST_CC_REV_REMAINING_ATOMIC` uses the previewed
withdrawn balances and checks each scope again before staging. Local tests use
scope-reader and movement doubles; verify scope-query behavior, movement-type
reporting, and repeated reversal calls in the target SAP release.
`POST_CC_REV_REMAINING_BULK` commits per reservation, so a later reservation
failure can follow already committed reversals. Its optional
`iv_stop_on_failure` setting, also supported by the cost-center issue-reversal
bulk methods, retains later groups as skipped after a failed reversal; prior
commits remain. Local API doubles cannot establish the target SAP LUW behavior.
Sales-order reservation issue and reversal bulk methods use the same opt-in
group stop behavior. Their independent commits remain durable after a later
failure, and local API doubles do not establish target-system LUW behavior.
General reservation goods-issue and reversal bulk methods now expose the same
option, including their unit-aware forms. Stopping affects later reservation
groups only; a successful earlier reservation remains committed.
Cost-center reservation issue batches also support stop-on-failure across
base-unit, UOM, remaining-quantity, and exact-item entry points. The service
checks local reservation scope before posting; SAP remains authoritative if
the scope changes after that read.

`delete_cc_reservation_items` reads the selected cost-center reservation items,
then calls `BAPI_RESERVATION_CHANGE` to mark them for deletion. SAP documents
item deletion as a reservation change and lists the BAPI as a material
reservation update ([changing a reservation](https://help.sap.com/doc/a6a8c7536e8e2a4be10000000a174cb4/700_SFIN3E%20006/en-US/3b64bd534f22b44ce10000000a174cb4.html),
[BAPI catalog](https://help.sap.com/docs/SAP_S4HANA_BEST_PRACTICES/7c85a9907ecf4b039f4cf574cc299d93/5d55fc2d126844039fc4084ef3e945c9.html?locale=en-US)).
The local stubs model only the changed item number and deletion flag; fake API
tests do not validate the target release's function-module parameter names,
change-indicator structure, item eligibility, or multi-call LUW behavior.
Verify these in BAPI Explorer and on representative reservations. The local
`iv_test_run` path performs prevalidation only and does not call the BAPI.
`delete_reservation_items_bulk` commits each reservation separately, so a
later failure does not undo earlier successful item releases. Local tests use
an API double and verify continuation, but do not exercise repeated
`BAPI_RESERVATION_CHANGE` calls or the target LUW behavior; verify on
representative reservations. Both reservation deletion bulk methods accept
opt-in `iv_stop_on_failure`; later requests are retained as skipped rows after
the first item deletion, document deletion, or commit failure. Already
committed documents remain committed.

`preview_cost_center_demands` converts every request unit before stock access,
then allocates shared material/plant balances in caller order. Local tests use
stock and UOM doubles; they verify quantity sharing and request validation but
do not execute MARD/MARC queries or target-system `MARA`/`MARM` conversions.
This bulk path reports plant-level availability without location, batch, or ATP
splits; use the single-demand preview when those details are required.
`preview_cost_center_by_date` uses the dated receipt projection and safety-stock
paths in `ZCL_STOCK_SERVICE`, sharing each material/plant allocation across
dates and returning rows in caller order. Its local tests use stock and UOM
doubles; validate the projected-receipt SQL, target-system unit ratios, and
safety-stock data in SAP before relying on those estimates. Optional ATP checks
use `BAPI_MATERIAL_AVAILABILITY` once per cumulative material/plant/base-unit/
required-date group. The local API double does not validate the target check rule,
cumulative confirmation behavior, or the target release's availability fields.

`GET_PROJECTED_RECEIPTS_BULK` groups purchase-order, scheduling-agreement, STO,
production, purchase-requisition, and planned-order reads by material/plant
scope. Each batched Open SQL query applies that scope's latest requested date,
then results are filtered to each individual request's cutoff. Service tests
use repository doubles; a separate SQLite-backed repository test now executes
the standard PO, confirmation-aware PO, external scheduling-agreement, STO
schedule, and PR/STO PR reads, including filters, quantity reductions, unit
conversion, and request cutoffs. The production-order branch also has direct
SQLite coverage for item and release-state filters, order categories,
quantity conversion, and request cutoffs. The date-availability path also has
direct SQLite coverage for outgoing-STO item/header selection, open quantities,
unit conversion, plant matching, and request dates. The planned-order branch
also has direct SQLite coverage for planned/fixed flags, eligibility,
unit conversion, and date cutoffs. Verify target-release field availability,
SQL behavior, query plans, and result cardinality in SAP before relying on large
bulk requests.
`GET_PROJ_RECEIPTS_OPTS_BULK` also sends material/plant pairs with matching
unioned non-confirmation flags through one bulk repository call; its confirmation
rows use the separate batched path. Local tests validate flag and cutoff
filtering with doubles, not the target database reads.
`ALLOCATE_DEMANDS_BY_DATE` and `ALLOCATE_PLANTS_BY_DATE` now fetch each unique
material/source-plant/date availability scope in one repository call. The MARD,
RESB, EKET, and AFPO queries use `FOR ALL ENTRIES`, and selected
requisition/planned/scheduling receipts use the projected-receipt bulk path.
Local tests verify service dispatch and allocation results with doubles; verify
target-release Open SQL syntax, FAE row cardinality, reservation cutoffs, and
query plans in SAP.
Single-plant sales-order and cost-center allocation can take an explicit
`it_allowed_storage_locations` list. This list filters the local location,
exact-batch, and FEFO estimate; a preferred location outside a nonempty list is
rejected, and caller priority only orders locations that remain eligible. The
same option filters ordinary, exact-batch, and FEFO cross-plant allocations;
there its shared list applies to every source plant. In all cases the list is a
caller-provided constraint, not a read of SAP storage-location customizing or
authorization. Verify that reservation and goods-movement APIs accept every
location supplied by the caller in the target system. Safety stock is deducted
across each full plant inventory before allocation candidates are filtered.
`preview_cost_center_locations` uses the location stock repository, shares each
material/plant/location balance across requests, and converts the resulting
splits to the source unit. Its optional shared location-priority list orders
eligible fallback locations after each demand's preferred location; locations
omitted from the list remain eligible in ascending code order. Request-specific
location ranks override that shared order for the named request; the underlying
unit-aware allocator validates request IDs and rank rows before stock and UOM
reads. Local tests use stock and UOM doubles; validate the MARD/RESB query,
storage-location order, target-system UOM ratios, and safety stock distribution
in SAP. This preview does not select batches or post reservations.
`preview_cost_center_batches` uses the batch stock repository and its local
reservation deductions for the caller-selected batch. Tests use repository and
UOM doubles; validate MCHB/MCHA/MCH1/RESB selections, target-system conversion,
batch expiration mapping, and location order in SAP. Its optional shared
priority list orders fallback locations within the selected batch, while
request-specific positive ranks override that order for one request. The opt-in
demand priority sort is local, descending, and stable; verify that repeated
stock reads observe
reservations in the target release before relying on the snapshot for posting.
It never runs SAP batch determination and does not create reservations.
`preview_cost_center_fefo` runs the same local batch availability and FEFO
eligibility rules across multiple cost center demands, sharing balances in input
order unless priority ordering is requested. Priority mode consumes shared
material/plant balances by descending integer priority, with input order breaking
ties, then restores caller order in the result. Tests use stock and UOM doubles;
validate MCHB/MCHA/MCH1/RESB selections,
expiration dates, unit conversion, and safety-stock deductions in SAP. FEFO
ordering is local and does not invoke SAP batch determination or create
reservations. Request-specific location ranks also apply within one expiry
and batch and are forwarded by date-first previews. `issue_cost_center_fefo`
validates shared and row expiry policies, effective dates, shelf life, and split
echoes before posting; it still uses the supplied snapshot and does not re-read
or lock stock. Its optional shared location priority only breaks ties between
locations for the same batch and expiration
date. A demand's optional exact-batch filter
still uses this local expiration snapshot and requires validation of the batch
selection and shelf-life behavior in SAP.
Its base and dated UOM demand rows can request all-or-nothing allocation;
short requests leave their eligible balance for later demands. The preview
echoes the row flag, and invalid values are rejected before stock reads or unit
conversion.
`preview_cost_center_fefo_date` changes the local demand order to required date,
then descending integer priority, while preserving input order for ties and
returning results in caller order. It applies each required date to the local
expiry cutoff but still reads a current stock snapshot; it does not lock batches,
run SAP batch determination, or reserve them. Validate concurrent stock changes
and target batch eligibility in SAP before relying on a preview for a later
reservation.
`reserve_cc_fefo_date_atomic` orders local allocation and reservation API calls
by required date and priority, then returns item rows in caller order. Its
preallocation still uses repository snapshots and cannot lock stock between the
read and each SAP reservation create. The atomic rollback handles API/commit
failures, but it cannot guarantee that the preselected batch remains available
under concurrent SAP activity; validate reservation behavior in the target
system.
`reserve_cc_fefo_date_bulk` uses the same date/priority order but commits each
reservation independently. Its later calls read the repository again, but that
read does not lock stock; a later failure cannot roll back earlier commits.
Concurrent SAP changes can still invalidate a selected batch between reads and
creates, so confirm current availability in the target system.
Each preview demand accepts `minimum_shelf_life_days`; the greater of that value
and shared `iv_min_days` controls its eligibility, and the effective value is
reported in the preview. Atomic and bulk cost-center reservations forward this
per-demand rule and reject a nonzero value when FEFO is disabled.
`reserve_cost_centers_atomic` prechecks full demand using the local location,
explicit batch, or FEFO allocator, then makes one `BAPI_RESERVATION_CREATE1`
call per demand and one commit or rollback for the group. In the location path,
an optional shared priority list orders fallback locations after a demand's
preferred location. Request-specific positive ranks override that shared order
for one demand. Atomic reservation validates every rank ID, positive rank, and
request/location pair before reading stock or creating reservations. Bulk
reservation validates rank rows against all request IDs before reads or writes,
then scopes each rank set to the individual reservation before atomic planning.
Dated FEFO wrappers preserve the same ranks through date ordering. FEFO demands
can optionally constrain individual rows to one exact batch. Tests use
stock/UOM and BAPI doubles; validate MARD/MCHB/MCHA/MCH1/RESB
availability, expiration eligibility, and unit conversion in SAP. Confirm the repeated creates share the
intended SAP LUW, that each successful non-test create returns a distinct and
reliable reservation number, and that the target release's commit/rollback and
test-run behavior matches this boundary. The service rejects duplicate numbers
and clears provisional numbers after rollback.
Its optional ATP diagnostic groups demand by material, plant, base unit, and
required date, then checks cumulative quantities through each date. Tests use
the availability API double; confirm the target check rule, confirmation-date
semantics, and returned quantities with representative SAP material data. The
optional full-confirmation gate blocks every reservation create when any group
is short; it does not change the local stock precheck or SAP's own reservation
validation.

`reserve_cost_centers_bulk` invokes the atomic reservation flow once per demand,
so each successful demand has its own `BAPI_RESERVATION_CREATE1` and commit and
later demands continue after an earlier failure by default. Set
`iv_stop_on_failure = abap_true` to retain later demands as skipped without
calling SAP for them. The option follows priority or date-first execution order
and the result rows are restored to caller order. FEFO rows can use the same
optional exact-batch filter as atomic reservation; it still narrows the local
stock snapshot and does not invoke SAP batch determination. Tests use stock and
BAPI doubles. Verify that each call has the intended SAP LUW boundary, that
test-run creates leave no staged changes, and that failed calls do not affect a
later demand in the target release.

Order allocation subtracts active movement type 231 reservation quantities
from sales-order demand. It clamps each `RESB` item to
`max(BDMNG - ENMNG, 0)` before grouping by material, plant, item, schedule
line, and requirement date for the sales order. It uses schedule-line and date keys
to reduce the matching open demand, then distributes any unmatched remainder
across that item's open lines in allocation order. Local tests use repository
doubles; verify `KDAUF`, `KDPOS`, `KDEIN`, `BDTER`, and the BAPI's target-release
assignment behavior in SAP. SAP documents the reservation requirement date on the
reservation item ([reservation requirement date](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167776.html)).

`preview_orders_by_date` extends that reservation deduction across each supplied
sales document and allocates all remaining dated items against shared local
material/plant estimates. Local tests verify cross-order stock priority using
fakes; they do not exercise live order reads, reservation queries, or dated
stock projections. Confirmed-demand mode uses `VBEP-BMENG - VBEP-VSMNG`, capped
at ordered open quantity, and requires schedule-line confirmation data. Confirm
the open-item dates, confirmation quantities, and reservation matching against
real orders, and compare the preview with SAP stock/ATP results before relying
on it for operational decisions. Optional ATP responses are a separate BAPI
check and do not alter the local estimate or success flag; the fake ATP API in
local tests cannot verify live check-rule behavior. The method itself does not
post reservations.
Single and multi-order allocation now reject malformed Gregorian requested or
selected material-availability dates returned by the sales-order read before
allocating stock or calling ATP/reservation APIs. The multi-order path reads
active reservations before reading orders, so this input guard does not avoid
that initial bulk reservation query.
Single-order FEFO also validates the caller-supplied `iv_fefo_as_of_date`
before reading the sales order; a malformed nonblank date is rejected.

The multi-order preview now loads active sales-order reservation totals with a
bulk `RESB` selection keyed by the supplied documents, then applies each row to
its matching order. Local tests use a repository double and cannot validate the
target system's `FOR ALL ENTRIES` SQL plan or `RESB` filters; inspect the query
and its runtime cost with representative order lists in SAP.

`reserve_orders_by_date` sends the shared preview's positive allocations as
separate sales-order reservation requests and commits them in one transaction.
Local API doubles verify the rollback path and request mapping, but cannot
validate multiple `BAPI_RESERVATION_CREATE1` calls for different sales orders
within one live SAP transaction. Check this flow, ATP/customizing behavior,
and SAP's storage-location and batch determination in the target release.

`it_demand_priorities` is a caller-supplied local ordering override keyed by
sales document, item, and schedule line. It affects shared allocation only
when material, plant, and required date also match; it does not update a SAP
sales-order priority field. `reserve_orders_by_date` also sorts its positive
requests by this priority before `BAPI_RESERVATION_CREATE1` calls, which the
adapter performs sequentially. Same-date ATP diagnostics still aggregate all
documents, so ATP checks do not reproduce the local priority sequence. Local
tests verify allocation and call ordering with fakes, not SAP order priority or
live ATP behavior.

`reserve_orders_by_date_bulk` creates reservation requests from one shared
dated allocation snapshot but commits each sales order in its own BAPI LUW.
It continues after per-order ATP, create, response, or commit failures by
default. `iv_stop_on_failure` preserves later rows as skipped with separate
counts after the first such failure. The local tests verify default
continuation after a failed order, per-order rollback, and the preservation of
prior successes; they cannot verify live
`BAPI_RESERVATION_CREATE1` commit or rollback behavior. Confirm in the target
release that each create call is isolated by the subsequent
`BAPI_TRANSACTION_COMMIT` or `BAPI_TRANSACTION_ROLLBACK`. A later order can
fail after earlier reservations have committed, and stock can change between
the shared preview and later per-order commits.

Reservation release calls `BAPI_RESERVATION_DELETE` once per reservation
number inside one BAPI transaction. SAP controls whether a reservation can be
deleted, including reservations already partly or fully issued. Verify the
BAPI signature and deletion behavior in the target release; local tests use
an API double and do not exercise SAP reservation status rules.
`release_so_fefo_reservations` validates the FEFO creation result and delegates
the unique returned numbers to the existing transactional reservation service;
it does not bypass SAP's deletion eligibility or status checks.

`DELETE_ORDERS_RELEASE_BULK` performs one grouped reservation lookup, then
starts and commits or rolls back a separate `BAPI_RESERVATION_DELETE` LUW for
each sales order. It continues after failures by default; its optional
`iv_stop_on_failure` marks later orders as skipped with separate counts. Its
local tests verify continuation after an order-level delete failure and
preservation of later successes. Confirm that the target release isolates each
delete call with its transaction API; a later failure does not restore
reservations already released for earlier orders. Reservation status and
concurrent issue behavior remain SAP-controlled.

`ZCL_CC_RESERVATION_SERVICE=>DELETE_RESERVATIONS` applies that release path to
cost-center reservations. It deletes complete reservation documents by number;
it does not select individual items. SAP's reservation API documents deletion
at the reservation-document header level ([Delete Reservation Document](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/569b8cdbac5c4d2db987d34e0e99a5b2.html)).
Verify the target release's BAPI signature, document eligibility, and shared
LUW rollback behavior with representative reservations.

`DELETE_RESERVATIONS_BULK` commits each reservation deletion separately and
continues after API or commit failures by default. Its optional
`iv_stop_on_failure` mode skips later reservation numbers after a failure;
earlier successful deletions remain committed. The item-deletion bulk method
has the same option. The local tests validate per-number result mapping and
continuation; verify the target release's BAPI test-run response and
one-reservation LUW behavior there.

Sales-order-scoped release uses one `FOR ALL ENTRIES` read to discover open
movement-231 items for all requested orders or item pairs, then a second guarded
read to exclude documents with non-deleted items outside the requested scope.
The two reads are not an SAP reservation lock; concurrent changes can still
occur before the BAPI delete. Verify the `RESB` filters and document behavior on
the target release. The local transpiler does not execute these queries or
confirm the SQL plan.

Reservation inquiry reads items through `BAPI_RESERVATION_GETDETAIL1`. Its
adapter maps the partial local `BAPI2093_RES_ITEM_DETAIL` stub. Verify the
function signature and detail-field semantics against the target release;
bulk inquiry calls the detail BAPI once per reservation number in caller order.
Local tests use an API double and do not validate live reservation records or
the target system's behavior and response time for repeated calls.
The service rejects duplicate item numbers within one returned document and
clears the entire item result on that malformed response; confirm item identity
and numbering semantics against representative target-system reservations.
Reservation issue validates the complete selected-item list before inquiry and
reuses the bulk reader for distinct reservation documents. SAP still receives
one detail call per document; the issue BAPI is called only after all documents
are read and all requested items pass local validation.
The sales-order issue and reversal methods check the detail header's movement
type, sales order, and item before posting. The local adapter maps
`BAPI2093_RES_HEAD_DETAIL-MOVE_TYPE`, `SALES_ORD`, and `S_ORD_ITEM`; verify that
`BAPI_RESERVATION_GETDETAIL1` returns these fields for movement type 231 in the
target release. The goods-movement BAPI still derives the physical stock
assignment from the reservation; local header matching does not replace SAP's
special-stock, authorization, or availability checks. Reversals are limited by
the detail item's withdrawn quantity; verify the target system's reversal
movement and transaction behavior with representative reservations. SAP
documents reversing a goods issue with reference to its reservation and
reversing the reservation updates ([planned goods issue reversal](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91b21005dded4984bcccf4a69ae1300c/9564bd534f22b44ce10000000a174cb4.html)).
Sales-order bulk issue and reversal also enforce this scope independently for
each reservation before its goods-movement call. Scope failures appear on the
corresponding per-reservation result, and later reservations continue. Local
tests exercise this isolation with API doubles; verify mixed-validity behavior
and transaction results in the target SAP system.
`POST_SO_ISSUE_REMAINING` reads selected reservation details to derive each
positive open quantity, then invokes that bulk path, which reads the details a
second time before posting. This narrows stale-quantity risk and the second
read catches intervening withdrawals, but it cannot lock reservations between
reads; SAP remains the final eligibility check. The path commits each
reservation independently, so a later reservation can fail after earlier ones
have posted. `POST_SO_ISSUE_REMAINING_ATOMIC` uses one shared commit or rollback
for all selected reservation documents, subject to the target BAPI calls
sharing one SAP LUW. Local tests use reader and goods-movement doubles; confirm
rollback behavior across repeated reservation-referenced goods-movement calls
in the target release. `PREVIEW_SO_ISSUE_REMAINING` exposes the first read as a
read-only list; posting always performs its own read again, so a displayed
quantity remains a snapshot until the movement is posted. The preview also
requires the reservation's base-unit ISO mapping because the goods-movement
adapter cannot post the item without it.
`PREVIEW_SO_ISSUE_REM_ITEMS` applies the same movement-231 and sales-order item
scope checks to exact reservation/item keys, requiring each selected item to
have a positive open quantity. The preview is a read snapshot and does not lock
`RESB`; both bulk and atomic posting reread the reservation before movement
creation. Bulk mode can leave earlier reservation issues committed after a
later failure, while atomic mode depends on repeated BAPI calls sharing one SAP
LUW. Local doubles verify selection and orchestration; validate concurrent
changes, reservation eligibility, and LUW behavior in the target release.
`PREVIEW_SO_REV_REMAINING` and its bulk/atomic posting methods use the same
sales-order header fields to scope movement type 231 reservations and reverse
their currently withdrawn quantities. The preview omits items with no
withdrawn quantity; each posting path rereads before movement creation but
does not lock reservation state. Bulk commits remain independent per
reservation, while atomic mode depends on repeated goods-movement calls sharing
one SAP LUW. Local doubles verify those orchestration paths; validate reservation
mapping, reversal eligibility, and LUW behavior in the target release.
The exact-item sales-order reversal preview filters this same reservation
snapshot and rejects requested keys that are missing or have no withdrawn
balance. Its posting methods reread selected reservations, but neither read
locks reservation state; SAP remains authoritative for concurrent changes and
reversal eligibility.

FEFO release can select complete request-ID groups; every batch/location split
for each selected demand is released together. The selector is checked against
the committed result before deletion, while the result's full reservation and
split mapping is validated first. `it_reservation_numbers` can instead select
individual SAP reservation documents, which are one batch/location split each
in the FEFO result. The selection modes are mutually exclusive.

Production-order component inquiry reads open reservation items from `RESB`
using `AUFNR`, `RSNUM`, `RSPOS`, `BDMNG`, and `ENMNG`, while returning the
reservation unit, movement type, date, location, and batch. Bulk inquiry uses a
guarded `FOR ALL ENTRIES` read for a unique production-order list.
`ISSUE_COMPONENTS` and `ISSUE_COMPONENTS_BULK` validate selected keys and
quantities against those open rows, require movement type 261, then use the
reservation detail read and goods-movement APIs. `PREVIEW_REMAINING_COMPONENTS`
and `ISSUE_REMAINING_COMPONENTS` accept explicit item keys; posting derives the
open quantities from a read and validates them again through the bulk issue
path. The reads do not lock `RESB`, so SAP reservation and movement validation
remain authoritative after the second read. Local service tests use repository
and API doubles. A separate SQLite-backed repository test executes the guarded
RESB read and checks row ordering and component mapping; neither test type
validates BAPI signatures or field behavior against the target release. Production orders normally
generate their component reservations automatically, so this service exposes
and issues those existing reservations instead of creating duplicates.
`ISSUE_REMAINING_BULK` groups exact selected keys by reservation and production
order, rereads the component rows, and commits each reservation separately.
Earlier commits remain when a later read or movement fails, and the source
`RESB` snapshot is not locked between preview and posting. Validate concurrent
reservation changes, per-reservation document grouping, and SAP LUW behavior in
the target release; local doubles only verify orchestration and continuation.
`CANCEL_COMPONENT_ISSUES_BULK` delegates multiple issue reversals to the generic
material-document cancellation service; the same target-system check for
multi-call cancellation LUWs applies.
Component stock and ATP previews pass their selected `(RSNUM, RSPOS)` keys to the
dated stock estimate. The repository omits those keys from the active `RESB`
reservation deduction, then the preview allocates each component's open
quantity once; other matching reservations remain deducted. With exclusions,
the repository reads reservation rows to omit the selected keys instead of using
the aggregate sum query. Validate that branch, its date and status filters, and
its query cost with representative material/plant volumes in the target release.

Reservation issue posting calls `BAPI_GOODSMVT_CREATE` with GM code 03 and
reservation number, item, record type, blank movement indicator, quantity,
entry unit, and the detail item's ISO base unit. Movement type, material, and
plant are intentionally omitted so SAP derives them from the reservation.
The adapter maps these fields, but the transpiler tests cannot execute the
function module. Verify the BAPI signature, unit handling, reservation status
checks, and optional storage-location/batch behavior in the target release.
All goods movement requests now require both the SAP entry unit and its ISO
code. The local tests use `EA` for both fields; verify configured unit mappings
and required fields in the target release. The bulk issue methods make one BAPI
call and commit per reservation, grouping selected lines for that reservation
into one material document. Verify this document grouping, per-document commit
behavior, and failure continuation in the target release.
Unit-aware issue methods convert each request through the material's `MARA`
base unit and `MARM` alternative-unit ratio, then confirm that the converted
base unit matches the reservation item. Local tests use a unit repository
double. Verify the target system's material unit ratios, rounding precision,
and unit configuration for materials with alternative units. SAP documents
`MARM.UMREZ`/`UMREN` as the numerator and denominator of the alternative-to-base
unit ratio ([SAP product unit-of-measure fields](https://help.sap.com/docs/sap-responsible-design-and-production/user-guide-sap-rdp/overview-d805fb0d75aa430f8dd30dfb8c803986)).
SAP also documents that each `BAPI_GOODSMVT_CREATE` call creates one material
document ([SAP goods movement BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)); verify that grouping against the target release.

`ISSUE_TO_COST_CENTER` sends movement type 201 and cost center with each
material/plant/storage-location line through `BAPI_GOODSMVT_CREATE`. The caller
supplies quantity, entry unit, and ISO code; this variant does not convert units
or estimate available stock. `ISSUE_TO_COST_CENTER_IN_UNIT` converts each line
through the material's `MARA`/`MARM` ratio and checks the result against a
caller-supplied base-unit/ISO mapping. SAP documents movement type 201 as goods
issue for a cost center and describes the BAPI's simulation and material-document
behavior ([movement types](https://help.sap.com/docs/SAP_ERP/a70c5fce76eb44adb0c86a9d3059e4dd/1663bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest),
[goods movement BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). Neither variant estimates available stock. Local tests use API and UOM doubles; verify unit codes, conversion ratios and rounding, batch rules,
authorization, stock eligibility, and posting-period behavior in the target
system.

`ISSUE_COST_CENTERS_BULK` and `ISSUE_COST_CENTERS_BULK_UOM` prevalidate
distinct cost centers and all issue lines, then make one movement-201 BAPI call
and commit per cost center while continuing after errors by default. Their
`iv_stop_on_failure` option stops later posts after the first failed movement
and marks unattempted rows separately. The UOM form converts the complete
request before posting. `ISSUE_COST_CENTERS_ATOMIC` and its UOM form stage one
movement document per cost center and request one shared commit; an issue or
commit error requests rollback and clears provisional document results. Local
tests verify request shaping, conversion, default continuation, and rollback
with doubles; they do not cover the stop-on-failure option. They do not establish
that repeated
`BAPI_GOODSMVT_CREATE` calls share the expected SAP LUW or that rollback removes
all staged documents in the target release. Verify the transaction boundary,
commit messages, movement eligibility, and authorization in a nonproduction
SAP system.

`RETURN_COST_CENTERS_BULK` and `RETURN_COST_CENTERS_BULK_UOM` prevalidate
distinct cost centers and return lines, then post and commit one movement-202
document per cost center while continuing after errors by default. Their
`iv_stop_on_failure` option stops after the first failed movement and reports
later rows as skipped. Their atomic variants stage one return document per cost
center and request one shared commit; any movement or commit error requests
rollback and clears provisional document results. UOM variants convert every
line before posting. Local tests validate mapping, conversion, default
continuation, and rollback through doubles; they do not cover the
stop-on-failure option. They do not confirm that
repeated `BAPI_GOODSMVT_CREATE` calls share the expected SAP LUW or that the
target release rolls back every staged document. Verify the transaction
boundary, unreferenced return eligibility, batch behavior, and posting-period
rules in a nonproduction SAP system.

`REVERSE_TO_COST_CENTER` and `REVERSE_TO_COST_CENTER_UOM` post unreferenced
movement-202 returns to a cost center. SAP documents that a reversal movement
can be entered without a reference to the original material document and can
reverse a partial quantity ([SAP reversal movement procedure](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/4f63bd534f22b44ce10000000a174cb4.html)). The UOM form converts through `MARA`/`MARM` and validates the caller's base-unit/ISO mapping. Local tests verify request mapping and transaction handling with API/UOM doubles; verify movement configuration, required BAPI fields, cost-center eligibility, batch behavior, and stock updates in the target release. Since this path does not reference the original material document, callers must supply the correct return quantity and source assignment.

`ISSUE_COST_CENTER_ALLOCATION` consumes a successful
`ZCL_CC_RESERVATION_SERVICE=>PREVIEW_FOR_COST_CENTER` result, validates its
base-unit totals and storage or batch split sum, and posts movement type 201
with the preview's cost center. A result containing a reservation number is
rejected to prevent treating an existing reservation as unreserved demand. The
caller supplies the base-unit/ISO mapping; optional partial posting uses only
the preview's allocated portion. SAP documents movement type 201 as goods
issue for a cost center ([movement types](https://help.sap.com/docs/SAP_ERP/a70c5fce76eb44adb0c86a9d3059e4dd/1663bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest),
[goods movement BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). Preview data is a snapshot and does not confirm stock or cost-center state at posting time. Local tests use API doubles and do not exercise target authorizations, batch eligibility, or live BAPI behavior.

`ISSUE_COST_CENTER_LOCATIONS` consumes multi-demand location previews and
posts their positive storage-location splits together in one GM-code-03
document, retaining each demand's cost-center account assignment. The service
checks unique demand IDs, material/base-unit mappings, preview allocation
totals, and each split sum before the BAPI call; partial posting is opt-in.
SAP documents movement type 201 for cost-center goods issue and the BAPI's
material-document behavior ([movement types](https://help.sap.com/docs/SAP_ERP/a70c5fce76eb44adb0c86a9d3059e4dd/1663bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.17.latest),
[goods movement BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). Local tests validate adapter requests only. Confirm that the target release accepts multiple cost-center assignments in one call and verify stock eligibility, authorization, unit codes, batch handling, and posting periods. Preview data remains a snapshot and can be stale before posting.

`ISSUE_COST_CENTER_BATCHES` consumes explicit-batch multi-demand previews;
`ISSUE_COST_CENTER_FEFO` consumes FEFO previews. Both preserve the selected
batch and storage-location splits, validate their totals against each demand,
and post the lines for their respective cost centers together in one 201
document. The same live BAPI, account-assignment, authorization, stock, and
snapshot limits above apply. Local tests confirm item mapping with API doubles;
they do not confirm target-system batch eligibility or multi-account posting.

`ISSUE_CC_LOCATIONS_BY_DATE` accepts date-first location previews, validates
each split's required-date and priority echo, and forwards the row-level
full-quantity rule into the shared issue validator. It posts the supplied
preview snapshot without a fresh stock read, so availability may change before
the movement call.

`ISSUE_TO_SALES_ORDER` sends movement type 231, sales document, and item with
each selected material line using GM code 03. Its unit-aware form converts
through the material's `MARA`/`MARM` ratio and uses a caller-supplied base-unit
ISO mapping. Both methods accept `iv_special_stock = 'E'` to post from sales-
order stock; the default blank indicator continues to use unrestricted stock.
The shared validator restricts E to movements 231/232 with GM code 03 and
411/413 with GM code 04, each with sales-order/item assignment. This service
does not read sales-order status or estimate stock.
`ISSUE_SALES_ORDERS_BULK` validates all distinct sales documents and lines
before posting, then commits one movement-231 document per order and continues
after an individual BAPI failure by default. `iv_stop_on_failure` stops later
posts after the first failure and marks remaining requests as skipped. Earlier
issues remain posted if a later order fails. The UOM variant converts every
line before the first post. Local tests use an API double and do not cover the
stop option or verify live sales-item state, stock eligibility, or
cross-document behavior.
`ISSUE_SALES_ORDERS_ATOMIC` stages one goods-movement BAPI call per sales
document and requests a shared commit or rollback. Local tests cover
orchestration only; verify repeated-call LUW behavior, special-stock E
eligibility, and rollback after a later issue or commit failure in the target
SAP release.
SAP documents movement type 231 as consumption by sales order, and requires the
sales-order key fields for valuated sales-order stock ([goods movement
operation](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/1dad2180e6f34b75ac77afce5cb5eda1/24fafa70cd8311dc2b8d000f20fcb6a9.html),
[goods movement BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). SAP's [sales-order stock guidance](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91b21005dded4984bcccf4a69ae1300c/6362bd534f22b44ce10000000a174cb4.html) requires the relevant movement type, special-stock indicator E, and sales-order/item keys for other goods movements. Local tests use API and UOM doubles; verify account assignment, special-stock configuration, order status, stock eligibility, unit ratios, and posting-period rules in the target release.

`RETURN_FROM_SALES_ORDER` and `RETURN_FROM_SALES_ORDER_UOM` post unreferenced
movement-232 returns while preserving the sales-order/item assignment. SAP
identifies 232 as the reversal movement for 231 and requires the sales-order
keys for both movements. Both methods accept `iv_special_stock = 'E'` to return
to sales-order stock; blank remains the default. See the
[movement-type reference](https://help.sap.com/docs/SAP_ERP_SPV/cfff13ea14f3430488af41bbc02dbb69/e2f4c353b677b44ce10000000a174cb4.html),
[sales-order key requirements](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/03a55f57017647368bfb386e41573ff7.html). The UOM form converts through `MARA`/`MARM` and verifies a caller-provided base-unit/ISO map. Local tests verify mapping and conversion only; confirm target movement configuration, return eligibility, stock category, batch behavior, and posting-period rules in the target release.
`RETURN_SALES_ORDERS_BULK` validates all distinct sales documents and lines
before posting, then commits one 232 movement per sales order and continues
after an individual BAPI failure by default. `iv_stop_on_failure` stops later
posts after the first failure and marks remaining requests as skipped. Earlier
returns remain posted if a later order fails. The UOM form converts every line
before the first post. Local tests use an API double and do not cover the stop
option or verify live sales-item state, stock eligibility, or cross-document
posting behavior.
`RETURN_SALES_ORDERS_ATOMIC` stages one goods-movement BAPI call per sales
document and requests a shared commit or rollback. Local tests cover orchestration
only; verify repeated-call LUW behavior, special-stock E eligibility, and
rollback after a later return or commit failure in the target SAP release.

`TRANSFER_SALES_ORDER_STOCK` posts movement 411/E from sales-order stock to
own stock. `TRANSFER_TO_SALES_STOCK` posts movement 413/E from own stock into
the assigned sales order/item. Both have UOM variants and transfer the same
material without reading stock before posting. SAP documents 411 as transfer
of sales-order stock to own stock and 413 as transfer posting to sales-order
stock ([sales-order stock guidance](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91b21005dded4984bcccf4a69ae1300c/6362bd534f22b44ce10000000a174cb4.html),
[movement-type reference](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/ee6ff9b281d8448f96b4fe6c89f2bdc8/8b7b5fe73ef54063a2bfcfbe83cebd38.html)). The SAP Inventory Clerk authorization table lists movement 311 authorization alongside both 411 and 413; verify the applicable BAPI/MIGO authorizations in the target system ([authorization guidance](https://help.sap.com/docs/SAP_S4HANA_CLOUD/32da8359c8ee4e8b8e8c5e15cacba5aa/c9d9e2576941bf12e10000000a4450e5.html)). Also verify valuation/configuration behavior, batch handling, and posting-period rules. Local tests use a goods-movement API double.

`TRANSFER_SALES_STOCK_BULK` validates every distinct sales document and line
before posting, then commits one movement-411 document per order and continues
after individual failures by default. `iv_stop_on_failure` stops later
transfers after the first failure and marks unattempted rows as skipped. Earlier
rows remain committed when a later transfer fails. Its UOM variant converts
all rows before the first posting. The atomic forms request one shared commit
or rollback after staging one BAPI movement per order. Local tests cover
validation, mapping, conversion, and orchestration, but not the stop option,
live stock availability, repeated-call SAP LUW behavior, or order-item
eligibility; verify these in the target release before production use.
`TRANSFER_TO_SALES_STOCK_BULK` applies the same independent-commit and
continuation policy to movement 413/E by default. It also accepts
`iv_stop_on_failure` and marks later rows skipped after a failed movement; the
UOM form converts every order before the first posting. `TRANSFER_TO_SALES_STOCK_ATOMIC`
stages one movement per order and requests a shared commit or rollback; the UOM
form validates all conversions before staging. Tests use an API double and do
not verify stop-option behavior, SAP cross-document LUW behavior, stock
availability, or sales-item eligibility.

`TRANSFER_SALES_ORDER_ALLOC` accepts a result from the MARD-based sales-order
allocation preview and posts its location or batch splits as 413/E after
cross-checking summary totals, assignment keys, unit mappings, and split totals.
Full allocation is required by default, with partial posting opt-in. It does
not re-read the MARD stock or revalidate the sales item before posting; stock,
order status, and transfer eligibility may change after the preview. Local
tests use an allocation value and goods-movement API double.

`ISSUE_SO_ALLOC_RECHECKED` and `TRANSFER_SO_ALLOC_RECHECKED` compare an
original preview with a caller-supplied fresh preview, including summary rows,
sales-item rows, and every location or batch split. Callers must regenerate the
second preview with the same allocation options immediately before posting.
The methods cannot prove when or how the second result was created, and stock
can still change between that read and the BAPI posting; SAP's posting result
remains authoritative.

`ISSUE_TO_PROJECT_WBS` and `RETURN_FROM_PROJECT_WBS` post movement types 221
and 222 with the supplied WBS element in each BAPI item. The UOM forms convert
through the material `MARA`/`MARM` ratio and check the caller-provided
base-unit/ISO mapping. SAP identifies 221 as project consumption and 222 as
its reversal, and marks the WBS element mandatory for both in its goods-movement
input guidance ([movement reference](https://help.sap.com/docs/sap_erp/a682fa6741124711924f679d6159ed85/e2f4c353b677b44ce10000000a174cb4.html?locale=en-US),
[input-template WBS requirement](https://help.sap.com/docs/IRPA_S4HANA/18862e3cddb74ce7ac751f49e568c1e0/6c2deb7184a8463693944a74acda8cbe.html)). These methods do not verify WBS status, stock eligibility, or remaining returnable quantity, and a return has no reference to its original material document. Confirm the target release's BAPI field behavior, project stock/account assignment, movement configuration, batch rules, and posting periods. Local tests use API and UOM doubles only.

`ISSUE_PROJECT_WBS_BULK` validates all request rows before posting, then invokes
the issue flow and commit separately for each WBS. A failed row does not undo
earlier committed issues, and later rows are still attempted by default.
`iv_stop_on_failure` stops later calls after the first failure and marks
unattempted rows as skipped. Local tests cover ordering, default continuation,
validation-before-write, and test-run behavior, but not the stop option; verify
repeated `BAPI_GOODSMVT_CREATE` calls and per-row commit handling in the
target SAP release. WBS status and project-stock availability remain SAP-side
checks. `ISSUE_PROJECT_WBS_BULK_UOM` converts every source-unit row before the
first goods-movement call; local tests cover conversion, mapping, and rejection
of a later unsupported conversion before posting. Verify `MARA`/`MARM` ratios
and base-unit ISO codes against the target system. `RETURN_PROJECT_WBS_BULK`
uses the same per-WBS commit and continuation behavior for movement 222; local
tests cover key mapping, prevalidation, default continuation, partial failure,
and simulation, but not the stop option. It
retains the direct return method's lack of an original-document reference.
`RETURN_PROJECT_WBS_BULK_UOM` converts all quantities before posting; verify
its `MARA`/`MARM` ratios and supplied base-unit ISO codes in the target system.

`ISSUE_PROJECT_WBS_BULK_ATOMIC` and `RETURN_PROJECT_WBS_BULK_ATOMIC` defer
commit across one `BAPI_GOODSMVT_CREATE` call per WBS and then commit or roll
back the group. SAP's BAPI guidance assigns transaction control to the caller
and says each call creates one material document
([Goods Movements with BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
Local tests verify staged-call ordering, one group commit, rollback after a
failed create or commit, and test-run behavior. Verify repeated-call LUW and
rollback behavior on the target SAP release before production use. The
unit-aware atomic variants convert all requests before BAPI calls; verify their
`MARA`/`MARM` ratios and base-unit ISO codes in the target system as well.

`TRANSFER_PROJECT_WBS_STOCK` posts same-plant, same-storage-location movement
415/Q items between different WBS elements. It sets `WBS_ELEMENT` to the
destination and `VAL_WBS_ELEM` to the source, based on BAPI examples for 415/Q
([SAP Knowledge Base preview](https://userapps.support.sap.com/sap/support/knowledge/en/3140891),
[BAPI field example](https://community.sap.com/t5/application-development-and-automation-discussions/bapi-goodsmvt-create-415-q/m-p/9803978)). It also sets `MOVE_MAT`, `MOVE_PLANT`, `MOVE_STLOC`, and `MOVE_BATCH` to the unchanged receiving stock keys. SAP describes 415/416 as
project-stock group-to-group transfer and cancellation movements
([SAP Group-to-Group Transfers](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/4dd8cb7b1c484b4b93af84d00f60fdb8/66f5c353b677b44ce10000000a174cb4.html)). The service does not validate that WBS elements are valid grouping elements or that stock is available; target-system BAPI behavior and configuration need verification. Reverse posted transfers through material-document cancellation. Local tests use a goods-movement API and UOM repository double.

`TRANSFER_WBS_FEFO` and `TRANSFER_WBS_BY_LOCATION` combine project-stock
preview with the matching 415/Q poster. Each reruns the preview and rejects a
changed batch or location split before posting. Both use internal request IDs
to keep repeated caller IDs distinct until validation finishes, then restore
caller IDs in the result. Neither preview locks stock;
stock may still change between the second read and `BAPI_GOODSMVT_CREATE`.
`TRANSFER_WBS_FEFO_PRIORITY` applies the same recheck to priority-ordered
batch splits, and `TRANSFER_WBS_LOC_PRIORITY` rechecks batchless location
splits. Both use internal row IDs while posting repeated caller request IDs.
Priority and the second preview do not lock source WBS stock; SAP remains
authoritative for the movement.
Verify grouping-WBS eligibility, movement fields, and posting behavior in the
target SAP release.

Direct WBS issue and return methods accept `iv_special_stock = 'Q'` to pass
the project special-stock indicator through `BAPI2017_GM_ITEM_CREATE-SPEC_STOCK`;
blank remains the default for unrestricted stock assigned to the WBS. SAP's
goods-movement documentation distinguishes unrestricted stock from project
stock Q, and describes WBS as the key for project stock ([goods movement types](https://help.sap.com/docs/SAP_ERP/1a781c11dd4f41829c798db4d8ff3a41/87dfcfe2d9b911da2b24000f20dac9ef.html?version=6.06.latest),
[goods issue from project stock](https://help.sap.com/docs/s4hana-cloud-best-practices/project-control-resourcing-and-procurement-4rf-co/goods-issue-from-project-stock)). `ZCL_STOCK_SERVICE` allocations use unrestricted stock; the `ZCL_PROJECT_STOCK_SERVICE` previews below read project stock Q. Direct Q requests rely on SAP for project-stock validation; the local service does not read the project's stock balance or verify that the supplied WBS is the stock-bearing WBS. Confirm BAPI field semantics and target configuration.

`ISSUE_PROJECT_WBS_ALLOCATION` consumes a `ZCL_STOCK_SERVICE` location
allocation result plus a request-ID-to-WBS mapping. It checks that assignment
and allocation demand IDs match, verifies each unit summary and location split,
and posts the positive base-unit splits as movement 221 items with the mapped
WBS element. Full allocation is the default; partial posting is opt-in. The
stock preview is not re-read before posting, so a changed stock balance can
still make the BAPI fail. Local tests use synthetic allocation data and an API
double; they do not confirm live stock, WBS status, or project account
assignment behavior.
ISSUE_PROJECT_WBS_LOCATION obtains the project stock preview itself, reads it
again before posting, and rejects changed allocation or location splits. It
uses internal request IDs so repeated caller IDs remain distinct through both
previews and movement validation. Request-specific location ranks are mapped
through those IDs and retained for the fresh preview. The second read narrows
the stale window but does not lock stock. Its local tests verify adapter mapping
with repository and movement doubles; they do not confirm live stock or
target-system BAPI behavior.
ISSUE_PROJECT_WBS_LOC_PRIORITY additionally rechecks the same priority order
and keeps repeated caller IDs distinct with internal request IDs until after
movement validation. Request-specific location ranks survive both preview
reads. It still relies on SAP for the final stock check.
ISSUE_PROJECT_WBS_LOC_DATE rechecks required-date and same-date
priority metadata together with location splits, and keeps repeated caller IDs
distinct until movement validation finishes. It maps request-specific location
ranks to each internal row and reuses them on both reads. The second read
narrows the stale window but cannot lock project stock; SAP remains
authoritative at posting.

`ISSUE_PROJECT_WBS_BATCH_ALLOC` accepts a unit-aware batch allocation
result and posts positive batch/location splits with the request's WBS element.
The same method can consume explicit-batch or FEFO results. It checks split
totals, batch and location keys, and the material base-unit mapping; full
allocation is the default. The result remains a stock snapshot, and the method
does not verify batch eligibility or WBS status in SAP. Local tests use
synthetic batch splits and a goods-movement API double.

`ZCL_PROJECT_STOCK_REPOSITORY` reads Q project stock from `MSPR`, maps
`MSPR-PSPNR` to the external WBS ID from `PRPS-POSID`, and selects positive
valued unrestricted quantities from `MSPR-PRLAB`. Its stock and reservation
methods fetch WBS mappings and corresponding `MSPR` or `RESB` rows in batches,
then associate rows by internal WBS number. SQLite-backed Open SQL tests cover
all five repository methods, including key and WBS selection, reservation
filters, open-quantity calculation, final-issue item inclusion, and
plant/global batch-expiry fallback. SAP
describes MSPR as project stock grouped by WBS, plant, and material, and lists
`PRLAB` as valued unrestricted-use stock ([SAP project-stock reporting](https://help.sap.com/docs/PRODUCT_ID/4dd8cb7b1c484b4b93af84d00f60fdb8/e5f4c353b677b44ce10000000a174cb4.html), [MSPR table fields](https://www.sapdatasheet.org/abap/tabl/mspr.html)). `PREVIEW_FEFO` uses plant-level `MCHA-VFDAT` when present and falls back to material-level `MCH1-VFDAT`; SAP's FEFO guidance references both batch-master fields ([SAP batch expiration fields](https://help.sap.com/doc/6afeeafa6a424b9b8060d91da975c497/2025.1/en-US/CPP-EN.pdf)). Each FEFO demand can set its own `fefo_as_of_date`; the later of that date and the shared as-of date drives expiry eligibility, and selected batch splits echo the effective date. Each demand can also set a minimum shelf life; allocation applies the greater of that value and the shared minimum, and a positive effective minimum excludes batches without an expiry date. Selected splits echo the effective minimum so `RESERVE_WBS_FEFO` can repeat its expiry validation before writing. Each demand can set `allow_undated_batches` to opt in when the shared option is false, or `require_known_expiry` to force exclusion when it is true; these flags conflict when both are true. A positive effective shelf-life minimum still excludes undated batches. Allocation summaries and batch splits echo the row policy. WBS FEFO reservation, transfer, and goods-issue posting paths preserve it through their fresh stock rechecks. Base, priority, and dated WBS goods issue map caller location ranks to internal request IDs so repeated caller IDs keep the same tie-break order in both snapshots. Duplicate repository rows for one batch/location key are merged only when their expiry dates agree; conflicting expiry dates reject the preview as ambiguous. Nonblank expiry values are validated as Gregorian dates before FEFO selection. The method converts demand units and shares balances across demands for the same WBS/material/plant. It skips rows without a batch or storage location because its output is consumed by the batch posting method. It does not allocate quality-inspection, blocked, restricted, or non-valuated project stock, and it does not lock or reserve the selected stock. Service tests use repository and UOM doubles; separate SQLite tests execute the repository SQL but do not validate target-system DDIC, query plans, or WBS formatting. Confirm these mappings and query behavior in the target SAP release.

An additional factory-backed SQLite integration creates the production project
stock service and verifies the complete `MSPR`/`PRPS`/`MCHA`/`RESB` path: an open
reservation reduces early-expiry stock before the FEFO allocation is split.
This checks local Open SQL and service wiring, but not target SAP DDIC,
authorization, or concurrent reservation behavior.

Project-stock location and FEFO previews now accumulate eligible availability
and duplicate-key balances in `DECFLOAT34`, then reject totals outside the
`MARD-LABST` range. Project ATP demand groups, cumulative demand, and returned
confirmation totals use the same checked conversion before an ATP call or
result write. Regressions cover overflowing location and FEFO totals and verify
an overflowing ATP group is rejected before the availability API is called.

The base FEFO preview now accepts request-specific location ranks and validates
their IDs and duplicate request/location pairs before UOM conversion or stock
reads. `RESERVE_WBS_FEFO` forwards the same rows into the initial and fresh
previews; otherwise an unchanged allocation could be rejected when the recheck
fell back to the default location order.

`READ_AVAILABLE_STOCK` exposes the same reservation-netted project balances
without requiring a demand quantity. It returns located batch and batchless
rows in material base units and applies a reservation date cutoff when given.
The result remains a read snapshot; it is not locked and is not an ATP result.
Direct WBS FEFO and batchless location previews accept request-specific
storage-location sets. Each set intersects the shared allowlist, and invalid or
duplicate rows are rejected before UOM or stock reads. The ATP adapters retain
the scope for their local preview. Base FEFO and batchless WBS reservation
flows accept the same rows for both preview reads, so a scope is not lost during
their stale-allocation check. These remain client-side snapshots and do not lock
stock or constrain unrelated SAP postings.
The local test uses repository and UOM doubles, so confirm `MSPR`/`PRPS` and
`MARA` field availability and query behavior in the target SAP release.
`PREVIEW_FEFO_BY_DATE` orders shared project batch stock by required date and
same-date priority while keeping results in caller order. It evaluates batch
expiry through each demand's required date, but remains a local snapshot: future
receipts, concurrent issues, SAP batch determination, and target-system batch
checks are not modeled. Validate the selected batch and reservation date in the
target release before posting. The dated preview correlates repeated caller
IDs with internal row IDs; downstream consumers should keep a separate row key
when they need to distinguish repeated IDs. Request-specific location ranks
are mapped to those internal rows for repeated caller IDs and retained by the
ATP wrapper. `RESERVE_WBS_FEFO_BY_DATE` uses the same mapped ranks for its
initial preview and fresh allocation check.
`PREVIEW_FEFO_BY_DATE_ATP` adds cumulative plant-level ATP diagnostics to this
local WBS estimate. ATP does not confirm the selected WBS batch or reserve
stock, and other plant stock may affect the SAP response. Local tests use an
availability API double; verify check-rule behavior and returned confirmations
in the target SAP system.
`PREVIEW_FEFO_ATP` checks positive allocations from the undated local FEFO
estimate, grouped by material, plant, base unit, and ATP date (default
`sy-datum`). A future ATP date does not change the current estimate or confirm
the selected WBS batch. Verify the checking rule and confirmation lines in SAP.
`PREVIEW_FEFO_PRIORITY_ATP` applies the same diagnostic to priority-ordered
FEFO allocations. The returned local allocations preserve caller order and
priority; ATP checks remain grouped by material, plant, base unit, and check
date. Local tests use an availability API double.
Priority WBS FEFO previews now map request-specific location ranks through
their internal request IDs, including repeated caller IDs. The ATP wrapper and
`RESERVE_WBS_FEFO_PRIORITY` preserve the rows for the fresh preview; this keeps
unchanged ranked batch splits from being rejected under the default location
order.
Project WBS FEFO and batchless location demands can opt into preferred-location
fallback by supplying `storage_location` with `allow_location_fallback =
abap_true`. Batchless allocation consumes that location first, then uses other
eligible locations for any remainder. FEFO keeps expiry ordering and prefers the
selected location among stock with the same expiration date. Shared allowlists
still constrain candidates, and caller ranks order the remaining locations.
Base, priority, and date-first previews retain the flag; ATP, reservation,
goods-issue, and both FEFO and batchless WBS transfer wrappers preserve it
through their fresh checks. Local tests verify partial preferred stock,
fallback to another location, reservation and movement splits, and rejection
when the preferred location is missing. They use repository, UOM, reservation,
and movement doubles; SAP remains authoritative for stock and batch selection,
and neither previews nor the second read lock project stock.
`PREVIEW_BY_LOCATION_DATE` orders batchless project stock by required date and
same-date priority, then restores caller-order results. Its location quantities
come from the current snapshot; future receipts have no assigned location, and
concurrent changes are not locked. Validate location-level eligibility in the
target system before reservation or issue. The dated preview correlates
repeated caller IDs with internal row IDs; downstream consumers should keep a
separate row key when they need to distinguish repeated IDs. Request-specific
location ranks are validated against caller IDs and mapped to internal rows,
including repeated IDs. The ATP wrapper retains those ranks, and
`RESERVE_WBS_BY_LOCATION_DATE` forwards the mapped rows to both previews.
`PREVIEW_BY_LOCATION_DATE_ATP` adds cumulative plant-level ATP diagnostics to
the local WBS location estimate. SAP ATP does not confirm the selected storage
location or reserve the project stock. Local tests use an availability API
double; verify the check rule and confirmation behavior in the target SAP
system. Request-specific location ranks override shared ordering for each
demand; the dated preview maps ranks through internal IDs for repeated caller
IDs and the reservation recheck preserves the same rows.
Batchless WBS location demands can set `allow_location_fallback = abap_true`
with an exact `storage_location` to prefer it and use other eligible locations
for any remainder. The preferred location leads request-specific and shared
ranks. Base, priority, and date-first previews validate and apply the option;
ATP, reservation, goods-issue, and transfer paths preserve it across fresh
checks. A preferred location must remain inside the shared allowlist when one
is given.
`PREVIEW_BY_LOCATION_ATP` provides the same diagnostic for undated batchless
location allocations. The ATP date defaults to `sy-datum`, while local stock
remains a current snapshot. Plant-level ATP does not confirm the selected
storage location; local tests use an availability API double.
`PREVIEW_LOCATION_PRIORITY_ATP` applies this diagnostic to priority-ordered
batchless location allocations and preserves caller order and priority. ATP
remains plant-level and does not confirm the selected storage location.
`READ_AVAILABLE_STOCK_BULK` groups requests by reservation cutoff and dedupes
stock keys within each group before calling the same reader. Local tests verify
cutoff-specific results, request ordering, and one stock/reservation read per
date group with repository doubles. They do not measure grouped MSPR/RESB query
behavior or authorization in the target release.

`READ_OPEN_RESERVATIONS` exposes open Q reservation items, including
`RESB-RSNUM`, `RSPOS`, `BDTER`, `MEINS`, `BDMNG`, and `ENMNG`, scoped through
`RESB-PSPEL` to the requested WBS elements in `PRPS`. It omits deleted and
final-issued rows and derives open quantity as required minus withdrawn. Local
tests exercise filtering, item identity, duplicate detection, and quantity
calculation with a repository double; they do not execute the RESB/PRPS query
or verify these fields against the target release. Confirm the DDIC fields and
WBS conversion in SAP. The optional required-through date is applied after the
query, retains undated rows, and does not make the result a time-phased stock
balance.
`READ_OPEN_RESERVATIONS_BULK` groups requests by required-through date and
deduplicates WBS elements within each group before reading reservation rows.
Local tests verify date filtering, request ordering, and one repository read per
date group; they do not execute the grouped RESB/PRPS query in the target SAP
release.
`READ_OPEN_RESERVATIONS_UOM` and `READ_OPEN_RESV_BULK_UOM` convert RESB
required, withdrawn, and open quantities from the material base unit using the
material's maintained UOM ratio. The result keeps each original RESB row and
base quantities for reconciliation. Conversion rounding, source-unit mapping,
and maintained ratios still need validation against target-system materials.
`READ_RESERVATION_ITEMS_BULK` deduplicates WBS values, reads reservation items
once, then returns all matching items in each request row. It includes final
and fully withdrawn items by design. Local tests verify request ordering and
shared reads with a repository double; they do not execute the RESB/PRPS query
in SAP.
`READ_RESERVATION_ITEMS_UOM` and `READ_RESV_ITEMS_BULK_UOM` apply material
unit conversion to the full active Q item view, including final-issue and fully
withdrawn rows. Rows with negative or internally inconsistent source quantities
are rejected; verify those assumptions and conversion rounding against live
RESB data.

`READ_RESERVATION_COVERAGE` aggregates project stock and open reservations by
WBS/material/plant. It counts only positive stock with a storage location,
matching the allocation previews' eligible stock scope, converts reservation
quantities to the material base unit, and reports reserved quantity beyond
eligible stock as shortfall. Local tests use repository and UOM doubles; they
do not execute the MSPR/PRPS/RESB queries or validate live stock aggregation.
The summary is a snapshot and does not reserve or lock stock.
`READ_RESV_COVERAGE_FOR_KEY` and `READ_RESV_COVERAGE_KEYS_BULK` return
explicit zero rows when the requested material/plant/WBS key has no eligible
stock or reservation balance. They use the repository's exact-key MSPR and
RESB readers, grouped by cutoff and exclusion set, and carry the validated base
units through the grouped coverage calculation. The cutoff is pushed into the
keyed and WBS-level RESB queries, including reservations with no required date;
the service retains a defensive cutoff check. The exact-key reservation query
also applies the cutoff for `READ_AVAILABLE_STOCK` and FEFO/location previews,
which still filter reservations during subtraction. Local source guards verify
key routing, request grouping, and the query predicate; they do not validate
SAP SQL execution plans or live query performance. Validate base-unit
resolution, cutoff behavior, and zero-row semantics against the target SAP
system.
The keyed service path computes each open quantity through the shared RESB
quantity helper and rejects a nonpositive result.
Coverage `stock_details` rows aggregate gross and net quantities by storage
location and batch after the existing reservation-specificity distribution.
They expose the reservation amount applied to each stock key, not a one-to-one
reservation-to-stock assignment. Any open reservation amount left after all
eligible stock is exhausted appears as summary shortfall; verify the local
distribution against target WBS stock and reservation data.
UOM detail conversion rounds each row independently, so requested-unit detail
sums can differ slightly from summary totals; use base-unit fields for exact
reconciliation.
Coverage `stock_reservation_deductions` retains the reservation/item key for
each amount applied to a stock key. Summed base quantities reconcile with that
key's `stock_details` deduction; excess reservation quantity remains summary
shortfall without an applied-deduction row. The local trace follows the
service's specificity-first allocation; verify it against target WBS stock and
reservation data in SAP.
Each included coverage reservation row now reports covered and uncovered
amounts after that local distribution. `base_covered_quantity` plus
`base_uncovered_quantity` reconciles to `base_reserved_quantity`, and summed
base uncovered amounts equal the summary shortfall; requested-unit values are
locally converted. This preview does not update or claim SAP reservation state.
`READ_RESERVATION_COVERAGE_BULK` groups WBS requests by cutoff date before
calling the same summary logic. Tests verify one stock and reservation read
per date group with doubles; they do not measure or validate database query
behavior in SAP.
`READ_RESERVATION_COVERAGE_UOM` validates the requested material-unit ratio
before reading project stock, checks its base unit against the UOM repository,
passes that unit to the shared coverage core, then converts each base-unit
coverage total using that ratio. Local tests verify conversion and early
rejection of unknown units; confirm the target `MARA`/`MARM` ratios and
project-stock unit semantics in SAP.
`READ_RESV_COVERAGE_BULK_UOM` prevalidates and caches the requested ratios,
then checks one UOM-repository base unit per material against those ratios.
The keyed and grouped coverage cores reuse the validated units when creating
stock and excluded-reservation balances, avoiding separate lookups in those
reads. It returns only each requested material/plant/WBS row. Local checks
verify request order, base-unit reuse, exclusion forwarding, conversion, and
rejection of unknown units before stock reads; they do not measure the grouped
MSPR/RESB query in SAP.

Project-stock FEFO and reservation cutoff inputs are checked as Gregorian
calendar dates before repository reads. This rejects malformed dates but does
not validate planning horizons or business-date eligibility in the target SAP
system.

`ZCL_PROJECT_RESV_SERVICE=>RESERVE_FOR_WBS` creates a movement-221 reservation
with the WBS element in `BAPI2093_RES_HEAD-WBS_ELEMENT`; it converts item
quantities to base units and commits only outside test-run mode. SAP documents
project-stock reservation as a 221 demand and says WBS reservations depend on
the project's stock settings ([project stock reservation](https://help.sap.com/docs/SAP_S4HANA_CLOUD/f369b2eff700401494ba6e7c9a573288/302bbfc4cc0a498aae4cef4256046cf6.html), [Project System procurement settings](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/4dd8cb7b1c484b4b93af84d00f60fdb8/79ceb65334e6b54ce10000000a174cb4.html)). The local adapter and stubs do not prove that every target release exposes this header field or accepts the same POSID representation, movement settings, and ATP behavior. Validate the BAPI signature, reservation's `SOBKZ`/`PSPEL` result, project-profile configuration, and test-run messages in a controlled target system. This direct-request method does not read or lock project stock before creation.

`RESERVE_WBS_BULK` prevalidates and converts each direct request before the
first reservation create. Its default mode commits each WBS independently;
`iv_stop_on_failure` stops later create calls after a failed create or commit
and leaves unattempted request rows marked as skipped. In atomic mode this
option stops later create calls while the attempted group still rolls back on
failure. The atomic mode otherwise issues repeated reservation-create BAPI
calls and then requests one shared commit or rollback. Local tests use an API
double and cannot verify
the target BAPI signature, whether repeated creates share a rollback-capable
SAP LUW, or test-run behavior with configured exits and enhancements. Verify
these behaviors and project stock/ATP eligibility in the target release. This
direct-request method does not preview or lock stock before reservation.

`RESERVE_BATCH_ALLOCATION` and `RESERVE_LOCATION_ALLOCATION` can assign a
separate required date to each WBS reservation. The local service checks that
the date map contains exactly one valid date for every assigned WBS and passes
that date on each reservation-create call. Local API doubles do not verify the
target BAPI's required-date handling or multi-create LUW behavior; validate
date eligibility and atomic rollback in the target release. These lower-level
methods trust the supplied allocation snapshot; the one-call FEFO and location
methods rerun their previews but cannot lock stock before the write.

`ISSUE_RESERVED_WBS_ITEMS` checks selected reservation items against active WBS
reservation rows read from `RESB`/`PRPS`, then delegates to the reservation
goods-issue service. That service reads reservation details again and validates
movement permission, final-issue status, quantity, and unit conversion before
posting. SAP documents reservation-backed goods issue from project stock and
requires the reservation item reference for the movement
([goods issue from project stock](https://help.sap.com/docs/s4hana-cloud-best-practices/project-control-resourcing-and-procurement-4rf-be/goods-issue-from-project-stock-e0e1a23885fe4e158f7bfba707d88166),
[goods movements with BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). The adapter supplies reservation number, item, record type, entry quantity, and unit while SAP derives reservation account assignment. Verify the target release's `RES_TYPE` mapping, movement 221/Q behavior, current-state checks, and commit behavior; local data reads and API mapping do not prove target SAP results.

`ISSUE_RESERVED_WBS_ITEMS_BULK` validates every WBS/item scope before it calls
the existing reservation bulk issue service, which groups requests by
reservation and commits each material document independently. By default it
continues after a failed reservation; `iv_stop_on_failure` stops later groups,
leaves their rows marked as skipped, and counts them separately. Local doubles
verify ordering, prevalidation, and per-reservation outcomes but cannot prove
repeated `BAPI_GOODSMVT_CREATE` calls and commits behave independently in the
target SAP release. Verify success, a later reservation failure, and test-run
behavior against the target system; earlier committed reservations remain
posted if a later group fails.

`RETURN_RESERVED_WBS_ITEMS` and its bulk form use GM code 06 with a reservation
reference and the reversal flag, allowing SAP to derive the movement type from
the reservation item. SAP documents reversing or returning a reservation
withdrawal by referencing the reservation, and notes that the posting updates
the quantities and values changed by the original issue
([Reversing a Planned Goods Issue](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91b21005dded4984bcccf4a69ae1300c/9564bd534f22b44ce10000000a174cb4.html),
[goods movements with BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). Local tests verify request mapping, final-item eligibility, and per-reservation commits. Confirm the target release's `XSTOB` behavior, reversal movement mapping, available withdrawn quantity, and transaction behavior before live use.

The return bulk form continues after failed reservation groups by default.
Its `iv_stop_on_failure` option marks later groups as skipped and counts them
separately from failed rows; earlier successful returns remain committed.
Confirm the target release's independent commit behavior for repeated return
movements.

`ISSUE_RESERVED_WBS_ATOMIC` and `RETURN_RESERVED_WBS_ATOMIC` issue one BAPI
goods-movement call per reservation and request one shared commit or rollback.
SAP assigns transaction handling to the BAPI caller
([goods movements with BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). Local tests cover group success, a later create failure, commit failure, reversal of a finalized item, and test-run behavior. Confirm repeated reservation-referenced calls share a LUW and that rollback restores every staged movement in the target release.

The reservation service rejects non-digit and impossible Gregorian required
dates before calling the BAPI, including invalid month lengths and non-leap
February 29 values. SAP still decides whether a valid date is permitted for the
plant, project, and planning period in the target system.

`RESERVE_WBS_FEFO` and `RESERVE_WBS_BY_LOCATION` run their project-stock
preview twice and compare the complete batch/location split before reservation
creation. A changed allocation stops before the first write. The lower-level
`RESERVE_BATCH_ALLOCATION` and `RESERVE_LOCATION_ALLOCATION` methods accept a
preview result and assignments directly and trust that snapshot. Reservations
are grouped by WBS; each WBS reservation commits independently by default, or
`iv_atomic = abap_true` stages the group for one commit or rollback. Local tests
use API and UOM doubles and do not verify repeated `BAPI_RESERVATION_CREATE`
calls in one LUW, rollback after later BAPI or commit failure, or whether the
target configuration accepts each selected batch/location/date combination.
SAP does not lock stock during the latest preview, so it can still change
before the write.
All of these direct and preview-backed reservation entry points also accept
`iv_stop_on_failure`. The option is checked before preview reads and unit
conversion, then skips later WBS groups after a failed create or commit. Atomic
calls stop later creates when opted in and still roll back all attempted groups
on failure; local doubles cannot establish target SAP LUW behavior. The summary's
`is_committed` reflects any independently committed WBS reservation, while
atomic results set it only after a successful group commit.
`RESERVE_WBS_FEFO_PRIORITY` applies priority-aware undated FEFO allocation and
uses internal request IDs while rechecking and creating reservations, so
repeated caller IDs remain distinct. It returns the preview with caller IDs in
input order and compares all batch splits before writing. Like the other
rechecked reservation flows, it observes stock twice but does not lock it;
stock may change after the second preview. Local tests cover duplicate IDs,
priority order, and stale-snapshot rejection, but do not verify the target
system's BAPI behavior or reservation acceptance for each selected batch.
`RESERVE_WBS_FEFO_BY_DATE` groups by WBS and required date, creating separate
reservation requests when one WBS has multiple dates. It applies earlier-date
and same-date priority ordering to its local preview and repeats the selection
before writing. It uses internal request IDs so repeated caller IDs can remain
distinct when their required dates differ, then restores caller IDs and order
in the preview. Local tests verify grouping, duplicate IDs, and split
preservation; confirm multi-call transaction behavior and date acceptance in
the target system.
`RESERVE_WBS_BY_LOCATION_DATE` uses the same WBS/date grouping for batchless
stock and compares location splits before writing. It uses internal request IDs
to preserve repeated caller IDs across dates, then restores caller IDs and
order in the preview. Its preview remains a current stock snapshot; verify
movement and reservation behavior for each date in the target system.

`RESERVE_WBS_BY_LOCATION` composes the batchless project-stock location preview
with reservation creation. It uses the same required-date and transaction
handling, and full demand coverage is required by default. The result retains
the preview when a shortfall or changed split prevents writes. Local tests
verify the service flow only; SAP controls the accepted project-stock
reservation items and stock can change after the second preview.
`RESERVE_WBS_LOCATION_PRIORITY` adds stable priority ordering to that flow and
uses internal request IDs to keep repeated caller IDs distinct during the
recheck and reservation creation. It compares the selected location splits
before writing. SAP does not lock stock after the second preview, and local
tests cannot confirm target-system BAPI behavior or project-stock reservation
acceptance for every location.

`RESERVE_BATCH_ALLOCATION` carries each previewed batch expiry and effective
minimum shelf life into local prevalidation and rejects
batches that expire before their assigned WBS required date or do not meet the
effective minimum. `iv_minimum_shelf_life_days` remains a shared floor, and
undated batches cannot satisfy a positive effective minimum. The lower-level
allocation method uses expiry data in the supplied preview. `RESERVE_WBS_FEFO`
reruns its preview before writing, but neither path locks the batch before SAP
processes the reservation. The local API double does not verify target SAP
batch validity checks or date-dependent reservation rules.

`DELETE_RESERVATION` and `DELETE_RESERVATIONS_BULK` call
`BAPI_RESERVATION_DELETE`. Bulk deletion validates all supplied numbers before
calling SAP, then performs and commits each deletion independently; failures
are rolled back per number and do not stop later attempts. Test-run mode skips
commit and rollback, and only a committed live deletion is marked deleted.
Local tests use an API double and do not confirm the target release's BAPI
signature, deletion eligibility for reservations with withdrawals or dependent
documents, or whether a successful test-run message guarantees a later live
deletion will succeed. Verify these cases in the target SAP system.

`DELETE_RESERVATIONS_ATOMIC` stages one delete BAPI call per reservation and
requests a shared commit or rollback. Test-run forwards SAP's simulation flag
per reservation and does not commit or roll back. Local doubles verify the
service flow only; confirm that repeated delete calls share a LUW and that
later BAPI and commit failures revert all earlier staged deletions in the
target release. Initial local lint found duplicate test names with the
reservation-item atomic delete cases; the whole-reservation test names were
made distinct and the final lint run reports zero issues.

`DELETE_RESERVATION_ITEMS` scopes selected item numbers to the supplied WBS by
reading open Q reservation items, then uses `BAPI_RESERVATION_CHANGE` with the
item deletion indicator. Bulk item deletion commits each reservation
independently. Test-run only verifies that the items are currently open under
the requested WBS and skips the BAPI because this change call has no test-run
parameter in the adapter. Local tests use API and repository doubles; confirm
the change structure fields, item-level deletion rules, and behavior for
partially withdrawn items in the target release.

`DELETE_RESV_ITEMS_ATOMIC` validates all open WBS/item scopes before calling
the item deletion API once per reservation, then requests one shared commit or
rollback. Local doubles verify prevalidation and group orchestration only.
Confirm that repeated `BAPI_RESERVATION_CHANGE` calls share a LUW and that all
staged item deletions are reverted after a later BAPI or commit failure in the
target release.
`RESCHEDULE_RESERVATION_ITEMS` scopes selected open Q items to the supplied
WBS, then maps the new required date through `BAPI_RESERVATION_CHANGE` item
change and change-indicator tables. SAP's reservation-document update service
supports changing an item's quantity in entry units and its required date
([Update Reservation Document](https://help.sap.com/docs/SAP_S4HANA_CLOUD/3f57e7df4a114edabffe8b2d581a59ed/18dea68a1d25444f85d2bc6e634b65d5.html?locale=en-US)); this does not verify the classic BAPI parameter names or DDIC field types used by this adapter. The local structures are partial stubs. Confirm `BAPI2093_RES_ITEM_CHANGE-REQ_DATE`, its X-field, item eligibility for partially withdrawn reservations, and commit/rollback behavior in the target release. Local tests use API and repository doubles.

Single, bulk, and atomic reschedule requests now reject invalid Gregorian dates
before the scope read or BAPI call. SAP still determines whether a valid date
is permitted by the reservation, plant, and planning period.
`RESCHEDULE_ITEMS_BULK` also accepts `iv_stop_on_failure`; later reservations
remain in the result as skipped after the first failed reschedule. Earlier
independent commits remain, and target SAP LUW behavior for repeated change
BAPI calls still requires verification.
Quantity-change, final-issue mark/reset, and stock-change bulk mutation methods
also stop later independent reservation calls on request when a failure occurs.
Their earlier commits remain durable; local doubles cannot establish target
SAP transaction behavior.

`RESCHEDULE_ITEMS_ATOMIC` validates every requested item scope before calling
the update BAPI once per reservation, then requests one shared commit or
rollback. Local doubles verify group orchestration, but cannot prove that
repeated `BAPI_RESERVATION_CHANGE` calls share a LUW in the target release or
that a later failure reverses every staged date change. Verify multi-reservation
success, a later BAPI error, and commit failure in a controlled SAP system.

`CHANGE_RESERVATION_ITEM_QTY` sends the new total required quantity through
`BAPI2093_RES_ITEM_CHANGE-ENTRY_QNT` and its X-field. SAP's reservation update
service defines this quantity in the item's entry unit and supports updating it
([Update Reservation Document](https://help.sap.com/docs/SAP_S4HANA_CLOUD/3f57e7df4a114edabffe8b2d581a59ed/18dea68a1d25444f85d2bc6e634b65d5.html?locale=en-US)). The caller supplies the existing unit, and the service checks it against `RESB-ERFME`, converts the proposed total to base units, and compares it with withdrawn quantity in `RESB-ENMNG`. SAP documents `RESB-MEINS` as the base unit and `RESB-ERFME` as the entry unit ([RESB fields](https://help.sap.com/docs/SAP_ERP/45eb5df17d514d5b8d0517193a0f921b/2b75bb53707db44ce10000000a174cb4.html)). The classic BAPI mapping remains unverified against target DDIC structures, and the local stubs are partial. Test quantity increases and reductions above withdrawn quantity, availability-check responses, and behavior for partially withdrawn items in the target system. Local tests use repository and API doubles.

`CHANGE_RESV_QTY_ATOMIC` validates every reservation item, entry unit, unit
conversion, and withdrawn-quantity limit before making repeated
`BAPI_RESERVATION_CHANGE` calls and requesting one shared commit or rollback.
Local doubles verify prevalidation and orchestration, but cannot confirm that
the target release keeps those calls in one LUW or reverts every staged update
after a later BAPI or commit failure. Verify successful multi-reservation
updates and both rollback paths in a controlled target system.
Initial local lint found a misaligned parameter in the generated API payload
expression; it was replaced with an explicit mapping loop and the final lint
run reports zero issues.

`MARK_RESERVATION_ITEMS_FINAL` sets the final-issue indicator on selected open
WBS reservation items, and `RESET_RESERVATION_ITEMS_FINAL` clears it on selected
finalized items. SAP documents that the indicator completes an item and keeps
it from being proposed for later goods issues, and that users can set or reset
it ([final-issue indicator](https://help.sap.com/docs/SAP_ERP/75c4b203fca64320b998cc04e2eb1468/4a64bd534f22b44ce10000000a174cb4.html?version=6.06.latest)). The reset path reads active Q reservation items including `RESB-KZEAR`; test-run checks that the item currently has the requested state. The local adapter assumes the classic change field is `FINAL_ISSUE` in both `BAPI2093_RES_ITEM_CHANGE` structures; verify the field names, partial-withdrawal behavior, availability checks, and commit/rollback semantics in the target release. Local tests use API and repository doubles.

`SET_RESV_FINAL_ATOMIC` supports both setting and resetting the indicator
across multiple reservations after validating every item's current state. It
calls the change API per reservation and requests one shared commit or rollback.
Local doubles verify group orchestration only. Confirm that repeated final-issue
updates share a LUW and roll back together after a later BAPI or commit failure
in the target release. Initial local lint found misaligned `it_requests`
parameters in the new tests; the calls were aligned and final lint reports zero
issues.

`CHANGE_RESERVATION_ITEM_STOCK` updates `STGE_LOC` and/or `BATCH` through
`BAPI_RESERVATION_CHANGE`, setting the matching X flags for each selected
field. SAP documents storage location and batch as reservation item fields that
can be changed ([Update Reservation Document](https://help.sap.com/docs/SAP_S4HANA_CLOUD/3f57e7df4a114edabffe8b2d581a59ed/18dea68a1d25444f85d2bc6e634b65d5.html?locale=en-US)). The classic adapter assumes `BAPI2093_RES_ITEM_CHANGE` and `BAPI2093_RES_ITEM_CHANGEX` expose `STGE_LOC` and `BATCH`; verify those DDIC fields, clearing behavior, destination stock checks, and commit semantics in the target release. Local tests use API and repository doubles, so they do not validate target batch eligibility or availability checking.

`CHANGE_RESV_STOCK_ATOMIC` validates the full WBS/item scope, calls the
reservation change API once per reservation, and requests one shared commit or
rollback. Local API doubles verify call ordering and result handling, but they
cannot confirm that the target release keeps repeated `BAPI_RESERVATION_CHANGE`
calls in one LUW or reverts all staged changes after a later BAPI or commit
failure. Confirm group success and both rollback paths in a controlled SAP
system before relying on the all-or-nothing behavior. The per-reservation bulk
method remains independently committed and can report partial success. Initial
local lint also rejected overlength ABAP method identifiers; the API and test
names were shortened to fit the language limit.

The repository also reads open Q reservations from `RESB`, joins `RESB-PSPEL`
to `PRPS-PSPNR`, and subtracts each item's `max(BDMNG - ENMNG, 0)` quantity
from matching WBS/material/plant stock before either preview allocates it.
Deleted (`XLOEK`) and final-issued (`KZEAR`) rows are excluded. More specific
location/batch reservations are applied first; blank keys match broader stock,
and any over-reservation is deducted from remaining balances only within the
same WBS in stable storage-location/batch order. SAP describes project open
reservations using the required and withdrawn quantities ([Open Reservations
for Project](https://help.sap.com/saphelp_ssb/helpdata/en/d9/663952f8b2a91ae10000000a445394/content.htm?no_cache=true), [RESB quantity fields](https://help.sap.com/docs/SAP_ERP/45eb5df17d514d5b8d0517193a0f921b/2b75bb53707db44ce10000000a174cb4.html)). SQLite-backed tests execute the RESB/PRPS reads and cover partial, fully withdrawn, and over-withdrawn rows. The deduction remains a local snapshot and does not lock stock; confirm field availability and reservation semantics on the target SAP release.

Reservation netting now narrows stock to the rows each preview can allocate
before applying deductions: FEFO requires a batch and storage location, while
location previews require a storage location and no batch. This prevents
unlocated or wrong-stock-type rows from absorbing a reservation deduction and
inflating the preview's eligible quantity. Batch-specific reservations are
skipped by the batchless location path. Local regression tests cover both
preview scopes; the repository SQL remains subject to target-release checks.
The FEFO, location, and transfer previews accept optional
`iv_reservation_through_date`, which excludes open reservation rows whose
`RESB-BDTER` is later than the supplied date. Undated rows are still deducted,
and omitting the option deducts all open reservations. SAP describes `BDTER`
as the requirement date on each reservation item
([reservation requirement dates](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167776.html)).
This only changes which reservations are netted against the current `MSPR`
snapshot; it does not add future receipts or create a time-phased stock balance.
Local tests use a repository double and cannot validate the target release's
`RESB-BDTER` field or live reservation data.

`PREVIEW_TRANSFER_FEFO` scopes each demand to its source WBS and returns a
source/destination assignment alongside the ordinary unit-aware batch
allocation. It rejects a transfer to the same WBS but does not validate that
either WBS is eligible for group-to-group transfer. `TRANSFER_WBS_BATCH_ALLOC`
checks assignment, summary, and split totals before passing base-unit batch
lines to `TRANSFER_PROJECT_WBS_STOCK`; full allocation is required by default.
The posting method does not re-read stock, and target WBS grouping eligibility
remains an SAP check. Local tests use synthetic stock and goods-movement API
doubles.

`PREVIEW_BY_LOCATION` handles batchless rows from the same project-stock query,
aggregates quantities by WBS/material/plant/storage location, and returns the
unit-aware location result for `ISSUE_PROJECT_WBS_ALLOCATION`. It intentionally
skips stock rows with a batch and rejects demands with an explicit batch, so
the location-only movement cannot discard a batch assignment. Both project
stock previews remain snapshots and do not re-read or reserve stock.

`PREVIEW_TRANSFER_BY_LOCATION` scopes batchless transfer demands to their
source WBS and returns location splits with source/destination assignments.
`TRANSFER_WBS_LOCATION_ALLOC` validates the summaries, assignments, and split
totals before posting the positive splits as 415/Q; full allocation is required
by default, with partial posting available by setting
`iv_require_full_allocation = abap_false`. It does not re-read stock or validate
grouping-WBS eligibility, so SAP remains the authority at posting time. Local
tests use synthetic project stock and goods-movement API doubles.
The base, priority, and dated transfer previews accept request-specific
location ranks, which override the shared order for that demand. ATP adapters
forward the same rows; each WBS transfer posting wrapper maps them through
internal request IDs and reuses them for the fresh location snapshot. The
second read narrows the stale window but does not lock stock. Local regressions
cover rank remapping, ATP forwarding, and posted split order; live 415/Q and ATP
behavior still depends on target SAP configuration.

`ISSUE_PROJECT_WBS_BATCH_ALLOC` accepts `iv_special_stock = 'Q'` for project
stock splits produced by `PREVIEW_FEFO`. The adapter passes this indicator to
`BAPI2017_GM_ITEM_CREATE-SPEC_STOCK`; SAP remains responsible for revalidating
the WBS assignment and stock at posting time. `ISSUE_PROJECT_WBS_ALLOCATION`
also accepts Q for batchless project-stock results. Both methods accept the
same generic allocation result types as unrestricted-stock posting, so callers
must match the special-stock flag to the stock source; the posting service
does not prove that the preview came from the project-stock repository.

`ISSUE_SALES_ORDER_ALLOCATION` accepts the single-order allocation preview,
cross-checks its base-unit summaries against the raw allocation rows, validates
that every location or batch split totals to its demand allocation, and posts
the positive splits as movement 231 with the sales-document/item keys. The
caller supplies the base-unit/ISO mapping. The preview reads unrestricted stock
and does not represent special sales-order stock; this posting path therefore
does not set special-stock indicator `E`. SAP documents movement 231 for
unrestricted stock and requires the sales-order keys; separate sales-order
stock movements require special-stock handling ([goods movement operation](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/1dad2180e6f34b75ac77afce5cb5eda1/87dfcfe2d9b911da2b24000f20dac9ef.html),
[sales-order stock](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91b21005dded4984bcccf4a69ae1300c/6362bd534f22b44ce10000000a174cb4.html)). These checks validate the supplied preview structure only; stock and order state may change before the BAPI call. Local tests use a goods-movement API double and do not establish live stock eligibility or account-assignment behavior.

Purchase-order goods receipts and returns use `BAPI_GOODSMVT_CREATE` with GM
code 01, movement types 101 and 122 respectively, movement indicator `B`,
purchase-order number/item, quantity, and entry unit. Material, plant, and
storage location may be derived from the PO item. Verify optional-field
behavior, PO item numbering, return eligibility, and adapter field mapping in
the target SAP release. The test suite uses a fake API and does not exercise a
live PO or the BAPI signature ([SAP BAPI movement field
requirements](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html),
[goods movement types](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/ee6ff9b281d8448f96b4fe6c89f2bdc8/8b7b5fe73ef54063a2bfcfbe83cebd38.html)).

`RETURN_PURCHASE_ORDER` and its bulk, atomic, and UOM variants build movement
122 with GM code 01, movement indicator `B`, and the PO/item reference. Bulk
mode commits each PO separately and continues after failures by default;
`iv_stop_on_failure` stops later returns after the first failure and reports
them as skipped. Atomic mode stages the group before one commit. UOM forms
convert all quantities to caller-mapped material base units before posting.
Local tests validate BAPI shaping, conversion, default continuation, and
rollback using doubles, but not the stop option. They do not verify returnable
quantity, PO history, or eligibility rules in a live system, nor that repeated
BAPI calls share a rollback-capable LUW. Verify those conditions and unit
rounding in the target SAP release.

`TRANSFER_MATERIAL_TO_MATERIAL` builds movement 309 with the source material
and `MOVE_MAT` destination material; it also forwards optional destination
plant, storage location, and batch. Its UOM form converts the source quantity
to base units and requires both caller mappings to declare the same base unit
and ISO code. SAP describes movement 309 as assigning stock from the old
material number to the new one and requires equal base units for standard
non-catch-weight material pairs ([material-to-material transfer](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/cb64bd534f22b44ce10000000a174cb4.html),
[movement type 309](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/ee6ff9b281d8448f96b4fe6c89f2bdc8/8b7b5fe73ef54063a2bfcfbe83cebd38.html),
[catch-weight transfer prerequisites](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/95f56a29a41e4861ba3424598848ee2b/4d89884eb6190f88e10000000a42189b.html)). `TRANSFER_MAT_TO_MAT_LIFO` and its UOM form build movement 310 with the same item fields and base-unit matching. SAP documents a direct movement 310 posting as reducing the old material stock in LIFO order, while 309 reduces it in FIFO order ([material-to-material transfers](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/cc8f759e1b0e4f3b8048c3cf808d4068/0692e59705164d4b8b293c63b2a76bf9.html)). That source describes direct MIGO behavior; this service submits through the goods-movement API, so confirm LIFO selection, movement configuration, receiving-material batch requirements, valuation, authorizations, and catch-weight behavior in the target release. Local tests cover request shaping and conversion only.

`RELEASE_BLOCKED_STOCK` and its UOM form submit own-stock movement 343 with
material, plant, storage location, optional batch, and quantity. SAP documents
343 as a transfer from blocked stock to unrestricted-use stock
([movement type 343](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/ee6ff9b281d8448f96b4fe6c89f2bdc8/8b7b5fe73ef54063a2bfcfbe83cebd38.html)). Local tests validate movement mapping and UOM conversion only; they do not establish that blocked stock exists, is eligible, or can be released in the target release. Verify movement configuration, authorization, batch handling, and any quality or restricted-stock controls before posting.
`BLOCK_UNRESTRICTED_STOCK` and its UOM form submit own-stock movement 344 with
the same fields and conversion rules. SAP describes direct movement 344 as a
transfer from unrestricted-use stock to blocked stock ([post unrestricted
stock to blocked stock](https://help.sap.com/docs/SAP_S4HANA_CLOUD_BEST_PRACTICES/b43d1faa9829967f85892e9d366862f9/cac24c0ba75a4918a4a6e10a77289744.html)). When correcting a particular material document, use document cancellation instead of treating a new 344 posting as a document-specific reversal. Local tests validate request mapping only; verify stock eligibility, movement configuration, authorization, batch handling, and posting-date behavior in the target release.

`RELEASE_QUALITY_STOCK` and `SEND_STOCK_TO_QUALITY` submit own-stock
movements 321 and 322 with the same location, batch, and unit handling. SAP
defines 321 as quality-inspection to unrestricted-use and 322 as the reverse
([stock type transfer movements](https://help.sap.com/docs/SAP_S4HANA_CLOUD/aff0b3f5f46c42a2b2c0fabfc233bab2/724f8054884f415be10000000a4450e5.html)). A direct 322 is a new stock-status transfer, not cancellation of a specific material document. SAP quality management may require an inspection usage decision or other lot controls before movement 321; verify those controls, eligibility, configuration, authorization, batch handling, and posting date in the target release ([batch status changes](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/4eb099dbc8a6435c9b36a854a7e05522/07feb753128eb44ce10000000a174cb4.html)). Local tests cover BAPI request mapping and UOM conversion only.

`RELEASE_QUALITY_FEFO_RECHECKED` compares the caller's original and freshly
recomputed unit-aware FEFO allocations and rejects different summaries or
splits before posting 321 in base units. It checks quantity conversions and
batch expiry through the posting date, but the comparison is not a stock lock:
inventory can change after the recheck and before SAP posts. The SAP posting
remains authoritative and may reject stock, inspection-lot, usage-decision, or
configuration conditions not represented by the preview. Local tests use
stock and BAPI doubles and do not establish target-system behavior.
`ZCL_QUALITY_STOCK_SERVICE` performs a fresh repository allocation using the
caller's original demand and allocation options before invoking these posting
methods. It rejects changes found during that read, but the repository read
does not lock stock through the later material-document posting.
`RELEASE_QUALITY_FEFO_PRIORITY` repeats the same check for priority UOM FEFO
demands and rejects changed priority echoes or batch splits. The second read
still does not lock quality stock; target SAP quality-management controls and
movement 321 remain authoritative.
`SEND_QUALITY_FEFO_PRIORITY` applies the priority check to unrestricted stock
before movement 322. Its second read does not lock stock through posting, and
SAP remains authoritative for stock status, quality controls, and movement
configuration.
The quality posting service now also forwards request-specific location ranks
into all four fresh FEFO allocation checks. Without that option, a valid preview
could be recomputed in default location order and rejected as a changed split
even when stock was unchanged. Regression coverage uses identical batch and
expiry values across locations to isolate the rank tie-break. The recheck still
does not lock stock through posting.
`SEND_QUALITY_FEFO_RECHECKED` applies that validation to the unrestricted-stock
FEFO result before movement 322. The caller must build the preview from
unrestricted stock; SAP remains authoritative for the stock-status transfer
and target-system quality controls.

Batch stock-status reads now report raw quality-inspection and blocked quantities
from `MCHB-CINSM` and `MCHB-CSPEM` alongside unrestricted and reservation-net
available quantities from `MCHB-CLABS`. SAP's stock-table guidance identifies
these as the quality-inspection and blocked batch quantities
([SAP batch stock fields](https://help.sap.com/doc/daeef66499fb4cadb0b934a998e44dcf/2020.1/en-US/TLG_EN.pdf)). Reservations are netted only from unrestricted stock; the
quality and blocked values are raw category totals. Local tests cover result
mapping and unit conversion, not the database aggregation or target-release DDIC
semantics; verify batch stock behavior and special stock handling in SAP.

`ALLOCATE_QUALITY_BY_EXPIRY` allocates the raw `MCHB-CINSM` batch quantities
from a stock snapshot and shares them across demand rows in input order. It does
not net quality-inspection reservations, lock stock, or check inspection lots,
usage decisions, or authorization. An optional exact-batch filter narrows local
FEFO candidates but does not change those limits. A resulting FEFO split is
only a candidate for movement 321; the BAPI and SAP quality-management
configuration remain authoritative. Local tests use stock-status doubles and
do not verify the target system's stock snapshot or quality-management behavior.
Location priority and allowlists are applied to batch rows returned for a
material/plant; the repository read itself remains material/plant scoped. Local
tests verify allocation filtering and order, not query performance or live SAP
database behavior. All six quality FEFO entry points accept
`it_request_location_priorities`; request ranks override the shared order only
within matching batches and expiration dates. Earlier expiry and batch order
remain primary. UOM methods validate before conversion reads, map ranks through
internal request IDs, and ATP wrappers forward the rows to their local estimate.
Preferred-location fallback remains first. Local tests cover all entry points
and invalid-ID/no-read behavior, but live quality-stock and ATP semantics remain
unverified.

`ISSUE_UNPLANNED_PROD_ORDER` posts direct production-order withdrawals with GM
code 03 and movement type 261, including materials that are not order
components. `ISSUE_UNPLANNED_PROD_ORDER_UOM` converts entry quantities through
the material `MARA`/`MARM` ratio and checks a caller-supplied base-unit/ISO
mapping. These entry points do not inspect components or reservations and do
not estimate stock. SAP documents 261 as goods issue for an order; an unplanned
withdrawal does not update a reservation ([goods issue for order](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/21aead0c98bd4755abdacd91c99e3393/8487bf53f106b44ce10000000a174cb4.html),
[unplanned goods issue behavior](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/ee6ff9b281d8448f96b4fe6c89f2bdc8/8b7b5fe73ef54063a2bfcfbe83cebd38.html),
[goods movement BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)). Verify order/account assignment, stock eligibility, unit ratios, authorization, and posting-period behavior in the target system.
`RETURN_TO_PRODUCTION_ORDER` and `RETURN_TO_PRODUCTION_ORDER_UOM` post direct
movement-262 component returns against the supplied order, preserving batch
and base-unit assignments. SAP documents movement 262 when reversing component
goods issues ([production-order split and reversal](https://help.sap.com/docs/SAP_S4HANA_CLOUD/2bba750d1e124e1ea2a039bb1cd9b6c5/91ae3df61c814b739b328b0fb2486d2b.html)). These methods do not reference the original material document or reservation item; local tests verify request mapping and UOM conversion only. Confirm target movement configuration, allowable return quantities, stock eligibility, and account assignment before live use.
`RETURN_PROD_ORDERS_BULK` validates all distinct orders and lines before
posting, then creates and commits one 262 document per order and continues
after an individual BAPI failure by default. `iv_stop_on_failure` stops later
returns after the first failure and marks them as skipped. Earlier orders
remain committed if a later return fails, so callers must inspect each row
result. The UOM variant converts and validates all lines before the first post.
Local tests use an API double and do not cover the stop option, SAP locking,
reversal eligibility, or cross-document behavior.
`RETURN_PROD_ORDERS_ATOMIC` stages one `BAPI_GOODSMVT_CREATE` call per order
and requests a shared commit or rollback. Local tests verify service
orchestration only, not repeated-call LUW behavior or return eligibility. Verify
movement 262 configuration, reservation and order updates, and rollback after a
later movement or commit failure in the target release before relying on the
group transaction.
`ISSUE_UNPLANNED_PROD_BULK` prevalidates distinct orders and every
movement line, then posts one independent 261 document per order and continues
after an individual BAPI failure by default. `iv_stop_on_failure` stops later
orders after the first failure and marks them as skipped. Earlier orders may
already be committed when a later order fails; inspect every row result. Local
tests verify validation, field mapping, default continuation, and commit
behavior with an API double, but not the stop option, SAP locking, or
cross-document posting behavior.
`ISSUE_UNPLANNED_PROD_BULK_UOM` converts all request lines before the first
movement, then delegates to that same independently committed path. Local tests
cover conversion and ensure a later invalid unit causes no earlier order post;
target material ratios, precision, and posting eligibility still need SAP
validation.
`ISSUE_PROD_ORDERS_ATOMIC` stages one 261 movement call per distinct
production order and requests a shared commit or rollback. Its UOM variant
converts and validates the entire group before staging. Local tests verify
service orchestration, including movement and commit rollback, but not repeated
`BAPI_GOODSMVT_CREATE` calls in one SAP LUW. Verify 261 configuration,
authorization, and target-system LUW behavior before relying on the group
transaction.

Production-order goods receipts use `BAPI_GOODSMVT_CREATE` with GM code 02,
movement type 101, movement indicator `F`, production order, quantity, and
entry unit. Material, plant, and storage location may be derived from the
production order. Verify optional-field behavior and order numbering in the
target SAP release; the test suite uses a fake API and does not post a live
production receipt ([SAP BAPI movement field requirements](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).

Production component ATP preview groups open `RESB` quantities from the
supplied production orders by material, plant, base unit, and effective required
date (`RESB-BDTER` unless a reservation-keyed policy overrides it). The date
override is preview-only and does not change the reservation. It converts
reservation units with the material `MARA`/`MARM` ratio and sends positive
cumulative quantities through each date to the availability BAPI. A group with
no cumulative demand has no BAPI call and leaves its ATP result initial. The raw
ATP result and confirmed/unconfirmed cumulative quantities repeat on components
sharing a checked group. A separate local dated allocation estimate is also returned for
each material/plant/base-unit/date group, with optional PO/STO/production
receipts, unissued STO subtraction, and static safety-stock protection. This
projection follows the local stock repository's date rules and is not SAP ATP.
The preview also splits each date-group local allocation across component rows
in production-order/reservation/item order; that priority is a local preview
policy, not SAP component selection or picking.
`SUMMARIZE_COMPONENT_READINESS` aggregates those local component splits by
order, rejects incomplete or duplicate reservation keys and inconsistent
quantity splits, and does not infer an order-level SAP ATP status. It also
returns requested, allocated, and shortfall base quantities summed across the
order; checked sums outside the `MARD-LABST` range raise
`ZCX_INVALID_STOCK_REQUEST`. Covered counts include positive-demand rows with no
shortfall, and zero-demand rows have their own count. Summary dates
use `effective_required_date`, falling back to the original component date when
that field is initial. A ready flag
therefore means only that the supplied preview rows have no local shortfall.
`SUMMARIZE_COMPONENT_SHORTAGES` groups valid supplied preview rows by material,
plant, base unit, and required date, and returns only groups with positive local
shortfall. It returns the distinct `affected_production_orders` list and count
for each date group; requested, allocated, and shortfall totals describe the
supplied component rows. Caller-supplied identity lists must contain nonblank
unique order numbers whose count matches `affected_order_count`. It is a
prioritization summary of the local preview
allocation, not a reservation or an independent recalculation of SAP ATP.
`PREVIEW_COMPONENTS_STOCK` and its bulk variant run the same local estimate
without an ATP checking rule or availability BAPI call; their ATP fields are
left initial. Their repository reads still depend on the local projection
implementation and are covered with test doubles, not a target SAP database.
Local tests use repository and ATP doubles; they do not execute the `RESB`
query, projected-receipt database reads, or validate live ATP rule behavior.
The cumulative input includes open components only from supplied orders, and
the plant-level ATP request does not retain batch or storage-location
restrictions. Validate the BAPI result and checking rule in the target system
before operational use.
The ATP preview's local estimate is plant-level by default. Passing either
`it_projected_batch_receipts` or `it_projected_location_receipts` opts it into
the scoped local allocator; these inputs cannot be combined with SAP-derived
receipt flags. The SAP ATP request remains plant/date grouped and does not
receive caller batch/location assignments, so it does not verify that local
receipt allocation.
`PREVIEW_SCOPED_COMPONENTS` and its bulk variant provide a local estimate that
shares location totals with batch sub-balances and honors component batch and
location assignments. Direct scoped demands can require a minimum shelf life
and known expiry. Batch expiry must be at least the required date plus the
requested minimum; unknown expiry remains eligible only when the minimum is zero
and known expiry is not required. Batch-restricted and batchless demand availability
and allocation apply the same filter. Batchless demands consume eligible
batches by FEFO across matching locations; unscoped competing reservations use
the same order, and batches without expiry remain eligible under the default
zero-minimum policy. Component stock, ATP, and scoped production previews accept
`it_allocation_policies` keyed by reservation number and item, covering
priority, all-or-nothing allocation, minimum shelf life, and known-expiry
requirements. `override_storage_location` and `override_batch` replace the
reservation scope in the local preview; an enabled override with a blank value
clears that scope, while disabled overrides require a blank value and retain the
reservation scope. `override_required_date` uses the policy's `required_date`
for local allocation, shelf-life eligibility, projected receipt horizon, ATP
date grouping, and date summaries. Results retain the source component date and
report the planning date as `effective_required_date`. An enabled date override
requires a valid Gregorian date; when disabled, its policy date must be blank.
`override_open_quantity` uses the policy's `open_quantity` instead of the open
RESB quantity for local allocation and ATP quantities. The override must be
nonnegative; zero removes demand from the local allocation and ATP while
keeping the result row. When disabled, the policy quantity must be blank.
Results report the source-unit value as `effective_open_quantity` and preserve
the original component quantity. Date and quantity overrides affect previews only
and do not change SAP reservation data.
`allow_location_fallback` treats the effective storage location as preferred
and falls back to other locations when needed; it requires a nonblank effective
location. Location-only stock uses the preferred location first. For batch
candidates, the preferred location breaks ties after expiry and batch order.
`allow_batch_fallback` treats a nonblank effective batch as preferred and
allows other eligible batches when needed. Other batches follow FEFO order;
location ranks break ties after expiry and batch. Shelf-life and known-expiry
rules apply to both preferred and alternate batches.
Without this flag, the effective batch remains an exact restriction.
Batch-fallback demands rank below exact-batch demands due on the same date, so
exact batches retain first access to shared stock. Location fallback keeps the
location as a preference for scope ranking, so stricter location demands
retain precedence. Higher
priority values allocate first within a required-date and scope-rank group;
input order breaks ties. A short all-or-nothing demand receives zero and leaves
stock for later demands. Duplicate and unmatched keys raise
ZCX_INVALID_STOCK_REQUEST. A matching policy routes its material/plant group
through the scoped local ledger; ATP remains a separate SAP diagnostic. The
component result echoes the matching policy row in `allocation_policy`, which is
initial when no policy was supplied. Results also return
`effective_storage_location`, `effective_required_date`,
`effective_open_quantity`, and `effective_batch` after applying overrides.
`location_fallback_used` is true only when an allocated batch or location split
uses a storage location other than the effective preferred location.
`batch_fallback_used` is true only when an allocated batch split uses a batch
other than the effective preferred batch.
Production previews accept a shared `it_storage_location_priority` list for
fallback-enabled components. The effective preferred location stays first,
listed fallback locations follow caller order, and unlisted locations follow
ascending location code. For batch stock, location order breaks ties after
expiry and batch. Blank or repeated locations are rejected, and the list is
invalid when no selected component enables fallback.
`it_comp_location_priorities` adds per-component positive ranks; these override
the shared list for that component, preserve the preferred location first, and
order unranked locations by code. Rows must reference selected components with
fallback enabled and cannot duplicate a component/location pair.
`it_comp_location_candidates` restricts fallback locations for a component when
candidate rows are supplied; absent rows keep the current unrestricted fallback.
The preferred location remains eligible. Candidate rows cannot name it or
duplicate a component/location pair. Local priorities must name listed
candidates when the component has an explicit candidate list.
`it_comp_batch_priorities` adds positive ranks for alternate batches for one
fallback-enabled component. The effective preferred batch stays first and FEFO
expiry order remains primary; local ranks break ties among equal-expiry
batches. Lower ranks precede higher ranks, then unranked batches; ties and
unranked batches use batch code. Preferred-batch rows, unknown components,
components without batch fallback, blank batches, nonpositive ranks, and
duplicate component/batch rows are rejected. Ranks do not restrict eligibility.
`it_comp_batch_candidates` restricts alternate batches per fallback-enabled
component when rows are supplied; absent rows retain unrestricted fallback.
Candidate rows cannot name the preferred batch or duplicate a component/batch
pair. A batch priority must name a listed candidate when that component has an
explicit candidate list.
The policy cannot be combined with
unissued-STO subtraction, and automatic receipts
for that group need a receiving location. Otherwise the request is rejected
instead of silently dropping an allocation rule. Overflow and
nonzero reservation quantities that round to zero at
MARD-LABST precision raise ZCX_INVALID_STOCK_REQUEST before stock is read.
Within a required date and scope-rank class, direct `ALLOCATE_COMPONENT_STOCK`
demands can use integer priority; higher values allocate first and input order
breaks ties. Production component previews accept reservation-keyed allocation
policies to set priority and all-or-nothing allocation alongside shelf-life,
location-fallback, and scope-override rules; unmatched components keep the
defaults. Preferred-location fallback consumes that location first for residual
stock. Batch-stock expiry and batch order remain primary, with the preferred
location breaking ties.
`PREVIEW_COMPONENTS_STOCK` selects this path by default when any component is
scoped and no SAP-derived projected receipt option is enabled. Callers may also
provide assigned receipts directly to `PREVIEW_COMPONENTS_STOCK`, its bulk
variant, the explicit scoped previews, or ATP previews. Explicit scoped
previews accept caller-resolved `it_projected_batch_receipts`, with material,
plant, storage location, batch, receipt date, base-unit quantity, and optional
expiration date. They also accept `it_projected_location_receipts`, with
material, plant, storage location, receipt date, and base-unit quantity. These
receipts enter the location residual pool and are available to batchless
components at that location or unscoped components; exact-batch component rows
cannot allocate location-only receipts. Both receipt types can be combined, but
neither can be combined with SAP-derived receipt flags. For scoped components,
the automatic local estimate can use SAP-derived standard PO or
confirmation-aware PO, issued or unissued STO, scheduling-agreement,
production-order, PR, STO PR, and planned-order receipts when every selected
row has a receiving location. Standard PO, STO, and scheduling-agreement rows
use `EKPO-LGORT` and `EKET-CHARG`. The confirmation-aware PO projection uses
those fields for schedule remainder rows and `EKPO-LGORT`/`EKES-CHARG` for
supplier confirmations ([SAP purchasing item mapping](https://help.sap.com/docs/SCMCSSLC/28656302ed964c8fa89038673b0fbdbb/c82ef1c487b54e63afe94d0c828aa3ac.html?locale=en-US&state=PRODUCTION&version=2020.1),
[SAP schedule-line API](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/1d6f6bea1c3b4f049742e15a81ff86a0.html));
production orders use `AFPO-LGORT` and `AFPO-CHARG`; requisitions use
`EBAN-LGORT`; planned orders use `PLAF-LGORT` ([EKES batch field mapping](https://help.sap.com/docs/signavio-process-insights/administration-guide/be4b0a35f6d048eb979899f569509c78.html),
[AFPO production-order item CDS](https://help.sap.com/docs/PRODUCT_ID/8308e6d301d54584a33cd04a9861bc52/9ecb6ea8a220445aa21a0435fafca571.html?locale=en-US),
[EBAN field catalog](https://help.sap.com/saphelp_aii710/helpdata/en/a3/9857a130f74936ae53aed874867dc3/content.htm?no_cache=true),
[PLAF field catalog](https://help.sap.com/docs/signavio-process-insights/administration-guide/be4b0a35f6d048eb979899f569509c78.html)).
If any selected row for a material/plant pair has no location, only that pair's
automatic estimate remains plant-level; other pairs still use scoped allocation.
Enabling outgoing-STO subtraction keeps all pairs on the plant-level path.
Receipts enter the ledger on their arrival date before
reservations due that date, so earlier reservations cannot consume future
receipts. Receipts can replenish the remaining protected safety-stock buffer;
the balance becomes allocatable only after that buffer is filled. Omitted
expiration dates inherit known expiry from current stock or another supplied
receipt for the same batch. A known expiry cannot precede any receipt date, and
supplied dates must match known batch expiry. Caller-assigned receipt rows are
not checked against SAP documents or batch master data. Scoped estimates
start with raw unrestricted location and batch balances, exclude the selected
component reservation keys, and deduct other active general-stock `RESB` rows
from the shared location/batch ledger. A competing reservation is charged to
its assigned batch and location first; any uncovered quantity is charged to
the remaining plant stock. Competing reservations enter the shared ledger by
required date before selected components due that day. Batch stock used by a
component or competing reservation must remain eligible through its required
date; undated stock remains eligible. Local tests use repository doubles and do
not validate live receipt assignments, SAP batch expiry, or `RESB` query
semantics. The repository query and SAP field semantics still need validation
against the target system. These methods are advisory; they do not call SAP ATP
or reserve stock. The date-group local estimate reports the union of stock eligible under
that date group's component scopes, counting shared batch/location balances
once; its requested, allocated, and shortfall totals sum the component rows.
Component ATP quantities are requested cumulatively by material, plant, base
unit, and date. The per-component confirmation fields split the nonnegative
increase in confirmations dated on or before each required date between
successive cumulative checks across same-date component rows in
production-order/reservation/item order, capped at that date's demand. Undated
and later confirmations stay in the raw SAP result but are excluded from the
date-limited split. This is a deterministic allocation for review; it does not
identify which SAP reservation received a confirmation, and changes to SAP
confirmations across dates can change the group totals. Date-scoped stock,
sales-order, and cost-center callers also pass the shared splitter their
required date, so later or undated confirmation lines remain in the raw result
but are excluded from their confirmed quantity. Callers that omit the optional
date continue to count all returned confirmation lines.
`SUMMARIZE_ORDER_ATP` accepts only check-relevant ATP rows with internally
consistent group and component quantities. It aggregates component splits per
order/material/plant/base-unit so unlike units are never added together. Its
order summary inherits the preview's deterministic allocation policy and is
not an SAP production-order confirmation status.
`SUGGEST_COMP_REPLENISHMENT` rounds supplied
material/plant/unit/date shortages independently, except for monthly (`MB`),
weekly (`WB`), and planning-calendar (`PK`) lot sizing, which groups shortages
for the same material/plant/unit and resolved calendar period into one suggestion.
Caller policies
override the plant material settings.
If an override is absent, one guarded bulk read loads `MARA-MEINS` and
`MARC-DISLS`, `MRPPP`, `BSTMI`, `BSTMA`, `MABST`, `BSTFE`, `BSTRF`, `BESKZ`, `SOBSL`,
`PLIFZ`,
and `WEBAZ`, plus plant calendar `T001W-FABKL` and purchasing processing time
`T399D-BZTEK`. For the supported
lot-for-lot procedure (`EX`), it applies minimum quantity, maximum lot size,
and rounding value. When maximum lot splitting creates a final partial receipt,
minimum and rounding are applied to that remainder; the result reports
aggregate quantity, receipt count, and final receipt quantity. For fixed lot
(`FX`), it uses the fixed quantity. For `HB`, a positive maximum stock quantity
(`MARC-MABST`) raises a shortage-triggered suggestion to at least that amount;
when the remaining shortage is larger, the suggestion stays at the shortage.
This uses the supplied shortage rows and is not a full MRP stock/requirements
calculation. SAP documents the HB procedure as replenishment up to maximum stock,
with requirements above the configured maximum taking precedence
([SAP lot-sizing procedure](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/c897b6535fe6b74ce10000000a174cb4.html)).
For `MB`, `WB`, and `PK`, the preview nets caller-supplied projected receipts against
each dated shortage before consolidating the remaining period total, then
applies the minimum, maximum, and rounding settings to that total. It dates the
result to the first shortage date in the period and returns the period bounds
and grouped shortage count. `MB` uses calendar months. `WB` uses seven-day
weeks whose first weekday is supplied by `iv_week_start_weekday` (Monday=1
through Sunday=7, default Monday). For `PK`, callers can supply resolved periods
keyed by plant and `MARC-MRPPP`; otherwise the service reads overlapping
`T439I` periods for the requested shortage-date horizon. Shortages without a
matching period remain date-level suggestions. The service does not generate or
extend planning-calendar periods. This uses the supplied shortage rows and does not
evaluate coverage profiles or MRP's full stock/requirements calculation. SAP
defines planning calendars as flexible period lengths and groups proposals that
fall within a defined period ([SAP planning calendars](https://help.sap.com/docs/SAP_ERP/85d3fce10e264972a0155c8b46ecf93b/f1f8c0534b22b64ce10000000a174cb4.html)). Shortage inputs and suggestions can carry
`affected_production_orders`. When every date row in a period group has a
complete identity list, the result unions those IDs and reports a distinct
`affected_order_count`. Legacy rows or mixed groups without complete identity
data keep additive counts and return an empty order list; callers should pass
the same complete IDs on each shortage date to deduplicate across the period.
For other period-based or custom procedure keys, callers can pass
`it_resolved_lot_size_periods` rows keyed by plant and procedure with inclusive
start/end dates. The service groups and nets requirements in those intervals,
then applies minimum, maximum, and order-multiple constraints. It does not infer
multi-week, posting-period, fiscal, or customer-specific boundaries. Periods
must not overlap, and shortages for a procedure with supplied periods must be
covered by one; uncovered shortage dates raise `zcx_invalid_stock_request`.
These rows cannot override `EX`, `FX`, `HB`, `TB`, `MB`, `WB`, or `PK`; `PK`
continues to use planning-calendar periods.

Other configured procedures without caller-resolved periods remain unsupported.
`FX` without a positive fixed quantity, `HB` without a positive maximum stock
quantity, and incompatible `EX`/`MB`/`WB`/`PK` limits leave the shortfall exact
and return `policy_origin = UNSUPPORTED`. A missing MARC row returns the exact
shortfall with `policy_origin = NONE`. Caller policies without
`lot_size_procedure` continue to treat their minimum, fixed quantity, and order
multiple as direct rules. Unit mismatches, duplicate policies/shortage keys, and
inconsistent quantities are rejected. Multiple due-date rows group by
material/plant/unit and date for `TB`, calendar month for `MB`, week for `WB`,
planning-calendar period for `PK`, or the matching caller-resolved interval for
another configured procedure.

For externally procured materials with no special procurement key, the
suggestion estimates latest receipt, purchase-order, and requisition release
dates. It subtracts `WEBAZ` and `BZTEK` in plant factory-calendar workdays, and
`PLIFZ` as calendar days; the factory calendar is read from `T001W-FABKL`. SAP
describes these separate scheduling inputs for individual procurement
([scheduling inputs](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/7b24a64d9d0941bda1afa753263d9e39/5a66b65334e6b54ce10000000a174cb4.html),
[calendar functions](https://help.sap.com/docs/PRODUCT_ID/4605bbe706b94a13a97c8befa17f76d9/48dfbc1aab14280fe10000000a42189c.html)).
The result compares the latest requisition release date with `iv_as_of_date`
(default `sy-datum`) and reports `pr_release_is_overdue` plus calendar days
overdue. These fields only indicate lateness relative to the estimate; an
empty release date means there is no estimate to compare, so callers must also
check `lead_time_status`. `pr_release_urgency` summarizes the same date as
`NO_ESTIMATE`, `OVERDUE`, `DUE_TODAY`, or `UPCOMING`; the numeric overdue count
and original date remain available for prioritization.
Without projected receipts, non-period shortages are lot-sized independently
unless the caller opts into prior-surplus netting with
`iv_net_prior_surplus = abap_true`. `MB` and `WB` shortages, and `PK` shortages
with supplied matching calendar periods, are grouped by their periods in either
mode.
Netting sorts rows by material,
plant, base unit, and required date, then carries rounding excess forward only
within that key. Results report the remaining planning quantity and prior
surplus consumed; a fully covered date has zero suggested quantity and
`COVERED_BY_SURPLUS` status. In this mode, `rounding_surplus_base_quantity`
reports the carry left after the current date. Callers can also pass validated
dated supply rows through `it_projected_receipts`; the service consumes matching
receipts on or before each requirement date and reports their use separately.
Optional source type/document/item values flow to `projected_receipt_uses` for
traceability; source type and document must be supplied together. When receipts
are supplied, shortage rows are processed in chronological key and date order.
The service does not query PO, STO, or production receipt sources; callers must
ensure the input rows are valid for the planning horizon.
Check delivery-date and lead-time status fields before acting on a netted plan.
The result marks missing policy/calendar, unsupported procurement, special
sources, and calendar failures explicitly. Callers that already resolved an
external purchasing source can include its vendor, purchasing organization,
info-record number/category, and `EINE-APLFZ` value in the caller policy. A
positive source delivery time overrides `MARC-PLIFZ`; a zero source time falls
back to the `planned_delivery_days` supplied on that policy. The result returns
the source identity and a `lead_time_days_origin` of `INFO_RECORD`, `CALLER`,
`MATERIAL`, or `NONE`. The service does not determine or validate the source.
SAP source determination depends on sources valid for the requirement date and
may consider source lists and quota arrangements ([source determination](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/79bbb853dcfcb44ce10000000a174cb4.html?locale=en-US&q=procurement+scheduling+agreements&version=LATEST));
info-record data is maintained by vendor/material and purchasing organization
or plant ([purchasing info record](https://help.sap.com/docs/SAP_S4HANA_CLOUD_PE/af9ef57f504840d2b81be8667206d485/4b7fb65334e6b54ce10000000a174cb4.html?version=2023.latest)).
`ZCL_REPL_SOURCE_SERVICE` offers a read-only candidate list from `EINA`/`EINE`
and source-list context from `MARC`/`EORD`. It filters standard info records by
material, purchasing organization, plant scope, deletion indicators, and
inclusive `EINA-LIFAB`/`LIFBI` dates. When `MARC-KORDB` requires a source list,
it returns a vendor only when an unblocked vendor-only `EORD` entry without an
outline-agreement item covers the delivery date; an active matching blocked
vendor entry is excluded. Candidates expose
the list requirement, listed/fixed/MRP-usage flags, and source-list record and
validity window, plus the `MARC-USEQU` quota-usage setting. When quota usage is
configured, the service also reads active `EQUK`/`EQUP` classic external
supplier quota items and reports the rating `(QUMNG + QUBMG) / QUOTE` for a
matching vendor item. Assigned items rank by ascending rating. For this
purchase-requisition candidate path, equal ratings use ascending quota item
number; other candidates remain visible after quota items, then fixed-source,
preferred-vendor, and plant-specific flags rank the remaining candidates. SAP
documents the formula and highest-quota tie for zero ratings in its [quota
source determination guide](https://help.sap.com/docs/PRODUCT_ID/af9ef57f504840d2b81be8667206d485/907fb65334e6b54ce10000000a174cb4), while its direct requisition sourcing guidance says equal ratings use the first item ([requisition sourcing](https://learning.sap.com/courses/purchasing-in-sap-s-4hana/controlling-source-determination-with-quota-arrangements-1)).
The service now reads the matching `TMQ2` usage rule and returns the flags that
show whether purchase requisitions, purchase orders, scheduling-agreement
schedules, planned orders, automatic MRP, production orders, and invoices
contribute to quota allocation. SAP documents quota usage as controlling which
business operations contribute to quota allocation ([quota usage](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/7d97b6535fe6b74ce10000000a174cb4.html)).
A missing rule prevents the quota-item query.
PIR results expose `candidate_rank` per request. Without simulation it records
the stored-snapshot order; with simulation it records the recalculated order
for that request. This rank describes the local preview ordering and is not a
SAP source assignment.
With `iv_simulate_quota_assignment = abap_true`, the candidate method processes
requests by material, plant, delivery date, descending caller priority, and
input position. Higher-priority same-date requests consume simulated quota
first; equal priorities retain input order. It adds each selected candidate's
supplied quantity to a local quota-item balance only when
the matching `TMQ2` rule says purchase requisitions count, then recalculates
ratings for later requests. The nested `quota_simulation` result records the
selection and pre-request rating; the existing quota fields remain the stored
snapshot. SAP describes the rating as `(quota-allocated quantity + quota base
quantity) / quota` and says quota-allocated quantity includes purchase
requisitions when the quota-usage configuration includes them
([quota source determination](https://help.sap.com/docs/SAP_ERP_SPV/967e1c2a6a8c4183b7e07d28e7574445/907fb65334e6b54ce10000000a174cb4.html)).
For a quantity it increments, the simulation requires the request unit to be
the material base unit when its selected quota item counts purchase
requisitions. It omits an item when stored or locally simulated `QUMNG` is
already at `MAXMG`, and also when a positive base-unit request counted as a
purchase requisition would bring it to that boundary. It is advisory: it does
not write quota data, model split recommendations, or reproduce all
source-determination rules. Validate behavior in the target release.
The caller still must validate the correct tie path and quota usage behavior for
the target SAP workflow and release.
`get_suggestion_pir_candidates` maps the standard PIR lookup to positive
replenishment suggestions that explicitly indicate external procurement
(`BESKZ = F`) without a special-procurement key. It uses each suggestion's
required date and suggested base-unit quantity and returns the original
suggestion index with each ranked candidate. Covered, internal, special-source,
and unspecified-procurement rows are omitted. This does not assign or write a
source; the caller must review a returned candidate before copying its identity
onto a suggestion. `get_suggestion_outline_sources` applies the same positive,
external, no-special-source eligibility and index mapping to the valid outline
agreement lookup. It passes required date and quantity/unit through the shared
request model and supports preferred-vendor ranking plus fixed-source and
MRP-relevant source-list filters. It returns options only and does not assign a
source. Both wrappers require a purchasing organization when an eligible
suggestion is present. `get_suggestion_source_options` combines both sets into
one suggestion-indexed list. Its `source_kind` is `P` for a PIR and `O` for an
outline agreement, and each row carries the matching nested candidate. It
orders options by suggestion, PIR before outline, then candidate rank; ranks
remain local to each source kind and are not a cross-kind preference. The
combined method remains advisory and does not select a source.
`apply_suggestion_source_option` applies one combined option to the indexed
suggestion in a copied table. It checks the option kind/rank, source identity,
and candidate material, plant, and delivery date against that suggestion; it
then clears fields for the unselected source kind. The helper makes no
repository call and cannot detect customizing changes after lookup. Callers
should apply an option to the same unchanged suggestions and rely on SAP's
requisition processing to validate the source at write time.
`apply_selected_source_options` applies multiple reviewed rows in one call,
leaves unselected suggestions untouched, and rejects duplicate selections for
one suggestion index. It checks each option through the single-option helper;
it does not require a source choice for every eligible suggestion.
`ZCL_REPL_SOURCE_SERVICE->SIMULATE_SPLIT_QUOTA` provides a separate local split
preview for one request index. It accepts only quota-assigned standard vendor
candidates from the same material, plant, purchasing organization, delivery
date, quota arrangement, and base unit. It orders candidates by maintained
quota priority first (smallest number first), then by quota value descending;
split quantities remain proportional to quota values. It sends a trailing
remainder below the maintained minimum split quantity to the next candidate in
that local order. Requests below that minimum use the highest-ranked candidate
for the whole quantity. SAP documents that priorities override the split
sequence and that the smallest numbered priority comes first
([split quota guide](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/8697b6535fe6b74ce10000000a174cb4.html),
[quota priority guidance](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/9297b6535fe6b74ce10000000a174cb4.html)). By default,
the service uses `EQUK-SCMNG`; callers can supply an override in the material
base unit. SAP exposes the same minimum as `SCMNG` in its released [purchasing
quota-arrangement CDS view](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/6aece8e36db0478ebd6b31f0a90a7db7.html) and
documents split quotas and this minimum-quantity behavior in its [split quota
guide](https://help.sap.com/docs/SAP_ERP_SPV/66326f67e0e1416d83c0fdfa4060189d/8697b6535fe6b74ce10000000a174cb4.html).
SAP's quota arrangement API names the item field
`QuotaDeterminationPriority` ([API example](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/91af7f8d3acd47da90d33aaacfcd0d59/58072494f7514201a032fb4adb30bf01.html));
verify the classic `EQUP-PREIH` mapping and SQL behavior in the target release.
The caller must confirm split-quota customizing and verify `EQUK-SCMNG` field
availability. The repository reads `EQUP-MINLS`, `EQUP-MAXLS`, `EQUP-KZEIN`,
`EQUP-MAXMG`, and `EQUP-RDPRF`, plus static rounding levels from `RDPR`; the
quantity fields are interpreted in the candidate material's base unit. A zero
`MAXMG` is treated as no maximum. An item is
ineligible when its stored `QUMNG` is already at the maximum or when its
proposed split (including minimum-lot expansion) would reach it. Split shares
are recalculated over the remaining eligible items. For a below-threshold
request, the service tries the next ranked item if the first would reach its
maximum. SAP describes an item as unavailable when its allocated quantity is,
or would become, greater than or equal to its maximum
([quota-arrangement learning](https://learning.sap.com/courses/sourcing-in-sap-s4hana/controlling-source-determination-with-quota-arrangements)).
The split result preserves demand share in `allocated_quantity` and reports the
source-lot-adjusted proposal in `proposal_quantity`; maximum lots can yield
multiple rows and minimum lots can make proposal quantity exceed the demand
share. SAP documents quota-item lot sizes as overriding material-master values
and describes quota re-evaluation after each maximum-sized proposal
([quota-item lot sizes](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/8c97b6535fe6b74ce10000000a174cb4.html?locale=en-US&version=6.18.latest)).
When a quota-derived share exceeds its max lot, the preview emits one max-lot
proposal and recalculates shares for the remaining demand. Non-once sources
remain eligible and can receive several max-lot proposals. An only-once source
is removed after its first max-lot proposal, and its remainder is recalculated
over the other eligible candidates. The preview rejects if the remaining
candidates cannot cover the request. SAP states that split shares use quota
values rather than quota ratings
([splitting quota arrangement](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/8697b6535fe6b74ce10000000a174cb4.html?version=6.18.latest));
this ratio preview does not model every MRP proposal and planning-element
interaction. Static `RDPRF` levels adjust each proposal upward by their
threshold and rounding values; quantities below the lowest threshold stay
unchanged. Rounded proposal quantity is included in `MAXMG` eligibility. If
rounding would make a proposal exceed `MAXLS`, the preview rejects the
incompatible limits. SAP describes threshold-based static rounding and
quota-item profile use ([static rounding](https://help.sap.com/docs/SAP_ERP/85d3fce10e264972a0155c8b46ecf93b/f597b6535fe6b74ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest),
[quota-item rounding profiles](https://help.sap.com/docs/SAP_ERP/66326f67e0e1416d83c0fdfa4060189d/8c97b6535fe6b74ce10000000a174cb4.html?locale=en-US&version=6.18.latest)).
The preview supports static profiles only and does not apply other procurement
categories or source-capacity limits.
Quota maximum handling uses the `EQUP-MAXMG` and `EQUP-QUMNG` snapshot; it does
not read all planning-element usage or reserve quota. Verify the classic field
mappings and SQL behavior in the target release.
The candidate read also exposes `EINE-AUT_SOURCE` as
`is_auto_source_relevant`. SAP documents that an info record must be marked for
automatic sourcing to serve as an MRP source ([source determination](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/79bbb853dcfcb44ce10000000a174cb4.html?locale=en-US&q=procurement+scheduling+agreements); [SAP KBA field identification](https://userapps.support.sap.com/sap/support/knowledge/en/2411004)).
The service keeps unmarked info records in the advisory result by default so
direct/manual review remains possible. Callers can opt in to
`iv_require_auto_source` to filter records without the flag; this only applies
that one indicator and is not a complete decision that SAP will select the
source. Field availability and SQL behavior still require verification in the
target SAP release. `iv_require_source_listed` can separately require a valid,
unblocked matching vendor source-list entry even when `MARC-KORDB` is not set;
`iv_require_fixed_source` can require that matching entry to be fixed, omitting
unlisted and non-fixed candidates;
`iv_require_mrp_relevant` further requires that matching entry's `EORD-AUTET`
usage for automatic MRP. SAP source determination checks for an MRP-relevant
source-list entry before assigning a source during planning
([MRP source determination](https://help.sap.com/docs/sap_erp/85d3fce10e264972a0155c8b46ecf93b/79bbb853dcfcb44ce10000000a174cb4.html)).
These filters do not check the remaining SAP assignment rules.
When a request supplies a positive quantity and base unit, the candidate also
compares it with `EINE-MINBM`/`EINE-BSTMA` after converting those purchasing-unit
limits through `EINA-UMREZ`/`EINA-UMREN`. The status distinguishes within range,
below minimum, above maximum, base-unit mismatch, missing conversion, and an
invalid range. This is only a comparison of maintained PIR limits: SAP KBA
2468048 documents MRP PR scenarios where the minimum quantity is not considered
([KBA 2468048](https://userapps.support.sap.com/sap/support/knowledge/en/2468048)).
Callers can opt into `iv_require_qty_in_range` to omit quantity-bearing
requests unless the status is within the inclusive PIR limits; requests without
a quantity retain all candidates. This remains a filter over maintained info
record limits, not a promise that MRP enforces those limits. Confirm the exact
quantity behavior for the source-determination workflow and target release. The
`EINA`/`EINE` fields and conversion orientation still need validation against
the live backend.
SAP identifies `EORD-AUTET` as usage in automatic
MRP ([source-list field catalog](https://help.sap.com/docs/signavio-process-insights/administration-guide/be4b0a35f6d048eb979899f569509c78.html)).
SAP defines source-list periods for when orders
may or may not be placed and describes fixed and blocked sources
([source-list behavior](https://help.sap.com/docs/PRODUCT_ID/af9ef57f504840d2b81be8667206d485/7b7fb65334e6b54ce10000000a174cb4.html),
[material/plant attributes](https://help.sap.com/docs/SAP_ERP/beef6a3baaa149d18944b7170c427838/a785d45556af7b43e10000000a4450e5.html)).
This is still a candidate lookup, not SAP source determination: quota ratings
are read-only snapshots and do not reserve or increment allocated quantities.
The candidate lookup does not automatically split a request;
`SIMULATE_SPLIT_QUOTA` is a separate bounded ratio preview and applies the
classic quota-item maximum quantity to its eligibility checks. Other
procurement categories, special procurement types, additional source-specific
split constraints, and all remaining purchasing and release-specific rules
are outside it. The service also does not evaluate contracts or conditions
([source determination](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/79bbb853dcfcb44ce10000000a174cb4.html?locale=en-US&q=procurement+scheduling+agreements&version=LATEST)).
The local EINA/EINE/MARC/EORD/EQUK/EQUP/TMQ2 stubs are partial. Edge-case unit
tests use a repository double; SQLite-backed repository tests execute the
EINA/EINE/MARC/EORD/EQUK/EQUP/RDPR/TMQ2 reads, and an integration test runs
`GET_VALID_PIR_CANDIDATES` through those queries, including general and
purchasing-record deletion filtering, a vendor-specific source-list block, and
the unlisted-source default plus its opt-in listed-source filter. Verify field
availability, deletion and blocking semantics, and SQL behavior in the target
SAP release.
Pass a source only after the host application has selected it. Vendor calendars,
goods receipt capacity, and MRP scheduling margins are not modeled. The
estimate is indicative and does not create or reserve stock or a purchasing
document. SQLite-backed repository tests exercise the MARC/MARA/T001W/T399D
reads, but they do not verify target-system field availability, client behavior,
factory-calendar function parameters, or dates. Check those against the target
SAP release.

`ZCL_REPLENISHMENT_REQ_SERVICE` creates requisitions from positive suggestions
through `BAPI_PR_CREATE`, one PR item per planned lot. It validates that lot
count, final-lot quantity, and total suggestion reconcile before calling SAP.
For a fixed-lot suggestion carrying a rounding profile, it validates the total
against the rounded final receipt quantity and sends that rounded quantity on
each item.
Covered zero-quantity rows are skipped. `iv_test_run = abap_true` invokes the
BAPI simulation path and skips commit; normal writes commit only after a
successful BAPI response with a requisition number, and roll back errors. The
raw adapter now applies the same key requirement to live creates while allowing
successful test-run simulation to omit its generated number. SAP's BAPI guide
specifies that test runs do not assign internal numbers ([test-run behavior](https://help.sap.com/saphelp_snc70/helpdata/EN/df/0495dbbd6f11d1ad09080009b0fb56/content.htm?no_cache=true)). The
service passes material, plant, base unit, required date, and optional
purchasing group/organization. It only accepts explicit external procurement
(`MARC-BESKZ = F`) with no special procurement key; in-house, ambiguous,
special-source, and missing procurement routes are rejected before the BAPI
call. This suggestion path does not select a vendor or source, attach account
assignments, or create service items. When the caller has resolved a
complete info-record source, the service forwards its vendor as `FIXED_VEND`
and its purchasing organization to the item. A per-suggestion purchasing
control can explicitly override that organization; the info-record category
remains source metadata, while its number is also sent in the `INFO_REC` item
field. SAP's
Fieldglass integration mapping also uses the BAPI item's `FIXED_VEND` and
`PURCH_ORG` fields ([SAP mapping reference](https://help.sap.com/docs/SAP%20Fieldglass%20Integration%20Add-On/e745d2cc4d114bbf92d2eea49eda9af4/9de8ee962b294286874958a919381f93.html)).
The local `BAPIMEREQITEMIMP`/`BAPIMEREQITEMX` stubs and mapper include
`INFO_REC` and the outline-agreement `AGREEMENT`/`AGMT_ITEM` references with
update flags; confirm the fields and flag behavior against the target SAP
release. Local tests use a fake API and a local BAPI mapper;
verify `BAPI_PR_CREATE`, DDIC field names, required-field behavior, custom PR
type, authorization, and purchasing defaults against the target SAP release.
The returned `submitted_items` table preserves each generated item number and
its 1-based source suggestion index, including the same source index for all
lots split from one suggestion. It reports submitted proposal rows for both
normal creation and test runs; it does not claim item acceptance independently
of the overall BAPI result.

`CREATE_FROM_PROJ_SHORTFALLS` accepts validated positive shortfall
rows and creates one requisition item for each row with account assignment
category `Q`, one account row, and the supplied WBS element and quantity. The
caller maps quantities, delivery dates, and WBS assignments from the project
stock preview. SAP documents that project-stock procurement uses the
stock-bearing WBS element and account assignment category `Q`
([project stock procurement](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/cc8f759e1b0e4f3b8048c3cf808d4068/baceb6535fe6b54ce10000000a174cb4.html)).
The local mapper and `BAPIMEREQACCOUNT`/`BAPIMEREQACCOUNTX` stubs model the
single-WBS payload only. Confirm the target `BAPI_PR_CREATE` signature, account
assignment serial/quantity fields, WBS representation, category `Q` settings,
and purchasing validation in the target release. Tests use API doubles and do
not create a live requisition or confirm the selected WBS holds the project
stock.
`prepare_from_suggestions` performs the same validation, receipt-lot expansion,
and purchasing-unit conversion without an API call; `create_from_suggestions`
uses the returned request directly. The prepared rows therefore show the
payload the service will submit, but cannot predict SAP source determination,
pricing, field acceptance, or later BAPI messages.
`prepare_from_selected_sources` includes the chosen source and its purchasing
unit conversion, and `prepare_from_quota_splits` reconciles and maps the chosen
quota shares to the original suggestion indexes. Their create counterparts use
the prepared request before the BAPI call.
`create_from_selected_sources` is a convenience path that applies caller
selected source options before running the same validations and BAPI flow. It
does not read source customizing or choose candidates; callers must pass the
original suggestion list and previously reviewed options. Unselected rows
continue through ordinary SAP source determination.
Callers can pass `it_purchasing_controls` keyed by the source suggestion index
to override purchasing group and/or organization on selected suggestions;
blank fields inherit the method defaults. Duplicate, out-of-range, covered-row,
and empty controls are rejected before BAPI execution. SAP still validates the
item-level purchasing values against the target system's configuration.
The result preserves the BAPIRET2 message identifiers, text variables,
parameter/row/field location, system, and log identifiers for both create and
commit responses. Local tests verify service-level propagation with fake API
messages; create messages for `PRITEM`/`PRITEMX` rows also carry generated item
number and source suggestion index. `is_test_run`, `bapi_was_called`, and
`is_committed` distinguish simulation and covered-row no-op results from
committed requisitions. The live BAPI call and target-release message set are
not exercised.
`create_from_quota_splits` validates split totals against the selected
suggestions and maps each previewed PIR candidate to a separate PR item. It
uses the split's proposal quantity, including any configured minimum-lot or
rounding surplus. The quota preview reads a snapshot of quota usage and does
not reserve or update the arrangement; a later MRP run or another purchasing
transaction may change eligibility. Local tests cover item mapping, base-to-
purchasing-unit conversion, original suggestion indexes, and incomplete-split
rejection. Verify source references, quota behavior, item precision, and BAPI
acceptance in the target SAP release.
SAP documents `BAPI_PR_CREATE` as the supported Enjoy requisition
interface and recommends committing successful BAPI writes with
`BAPI_TRANSACTION_COMMIT` ([purchasing BAPIs](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167428.html));
its BAPI guide defines `TESTRUN = 'X'` as simulation without database updates
([test-run behavior](https://help.sap.com/saphelp_aii710/helpdata/en/df/0495dbbd6f11d1ad09080009b0fb56/content.htm?no_cache=true)).

`mark_pr_items_deleted` calls `BAPI_PR_CHANGE` with `DELETE_IND` set in
`PRITEM` and the corresponding update flag in `PRITEMX`; test runs use `TESTRUN`
and live successes commit through `BAPI_TRANSACTION_COMMIT`. The local DDIC
stubs and service tests model this contract, but cannot confirm the target
release's exact field names, BAPI behavior, or deletion eligibility. SAP may
reject requisition items based on their source, release state, or follow-on
documents; verify representative generated requisitions before using this write
path ([SAP item deletion behavior](https://help.sap.com/docs/PRODUCT_ID/bb9f1469daf04bd894ab2167f8132a1a/f261a0af930349779a47b3639c10994d.html),
[requisition deletion constraints](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167301.html)).
`READ_PR_ITEMS` uses `BAPI_PR_GETDETAIL` to return the PR item rows and BAPI
messages. Quantities and units are copied as SAP returns them; the method does
not convert item units or filter deleted/closed rows. The local `BAPIMEREQITEM`
stub contains only the fields used by this service and does not verify actual
target DDIC types or the function module signature. Confirm output fields,
authorizations, deleted-row behavior, and target-release compatibility in the
system where this adapter will run
([SAP GetDetail BAPI guidance](https://help.sap.com/docs/SAP_NETWEAVER_700/10a1c6d16c531014ac7b8c45ecd11874/8b40aed6c95c11d1ad0c080009b0fb56.html)).
`READ_PR_ITEMS_BULK` makes one detail BAPI call per requisition in caller order;
it validates all keys before reading and continues after a read error. The bulk
method does not combine requests into one SAP call. Local tests cover ordering,
prevalidation, empty input, and continuation, but not target-system authorization
or read consistency across changing requisitions.
`DELETE_ALL_PR_ITEMS` reads the item list, then submits the currently undeleted
item numbers to `BAPI_PR_CHANGE`. A requisition can change between those two
calls; SAP may reject stale items or the entire change. Test the read/change
race, item-level rejection behavior, locks, and release-state handling in the
target system. The local tests verify only the ordered service control flow.
`DELETE_ALL_PR_ITEMS_BULK` repeats this read/change sequence per requisition,
committing each separately and continuing after failure. The read/change race
and SAP commit behavior apply independently to every row; local tests cannot
verify lock release or update tasks between those transactions.
`UPDATE_PR_ITEMS` sends item numbers and only the requested `QUANTITY`,
`DELIV_DATE`, `PUR_GROUP`, `PURCH_ORG`, `FIXED_VEND`, `INFO_REC`, `AGREEMENT`,
and/or `AGMT_ITEM` values, with matching `PRITEMX` flags. A selected source field
can be sent blank to clear that reference; unselected fields remain initial.
SAP's generic change BAPI contract requires the update flag for each changed field
([SAP change BAPI guidance](https://help.sap.com/docs/PRODUCT_ID/67ae2d27aed945b7bd0ad1d2185ec217/4d5bc81fdbd42307e10000000a15822b.html)).
Mapper and service tests verify the local payload contract; they do not confirm
field support, whether fields can be cleared, item eligibility, workflow
effects, or release-specific behavior in a live SAP system. Verify representative
PR quantity, date, purchasing, and source changes in the target release.
`UPDATE_PR_ITEMS_BULK` repeats `BAPI_PR_CHANGE` across requisitions. Its default
mode ends each request with its own commit or rollback and continues after a
failure unless `iv_stop_on_failure` is true; then later requests are reported as
skipped and earlier commits remain. Atomic mode ends the group with one commit
or rollback and always stops at the first failure. Local checks cannot verify
target-system locks, update tasks, workflow triggers, or message behavior
across those transaction boundaries. Confirm these details for the target
release before using either mode in production.
`DELETE_PR_ITEMS_ATOMIC` calls `BAPI_PR_CHANGE` once per requisition and ends
the group with one `BAPI_TRANSACTION_COMMIT` or `BAPI_TRANSACTION_ROLLBACK`.
SAP's BAPI transaction model permits several calls to be grouped in one LUW,
but this implementation's behavior with repeated requisition changes has not
been exercised in a live target system. Confirm locks, update behavior, and
message handling for the target release before using atomic groups
([SAP BAPI transaction model](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_FOR_SOH_740/166400f6be7b46e8adc6b90fd20f3516/4d5b102ba1483d8fe10000000a42189e.html?version=7.40.16)).
`DELETE_PR_ITEMS_BULK` uses the same BAPI but commits or rolls back each
requisition. It continues after a failure by default; with
`iv_stop_on_failure`, it preserves later rows as skipped while retaining any
earlier commits. `DELETE_ALL_PR_ITEMS_BULK` applies that policy to its
read/change sequence, so a read failure can also stop later requisitions. Local
checks cannot confirm target-system lock release, update-task, or commit
behavior between repeated BAPI calls. Verify those transaction boundaries in
the target release before using this mode for production changes.

The policy lookup also returns raw `MARC-BESKZ` procurement type and `SOBSL`
special procurement key so the caller can route a suggestion. Standard material
master procurement types distinguish in-house (`E`), external (`F`), and both
(`X`); special procurement keys depend on system customizing ([SAP procurement
types](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/050d78ed8b954b308256fa86506fc938.html),
[SAP special procurement](https://help.sap.com/docs/SAP_ERP_SPV/85d3fce10e264972a0155c8b46ecf93b/8d1eba53422bb54ce10000000a174cb4.html)).
The service does not resolve vendors, source lists, quota arrangements, or
source-of-supply priorities.

`CREATE_REQUISITIONS_ATOMIC` validates all prepared documents before calling
`BAPI_PR_CREATE` for each, then commits once or rolls back the shared LUW. SAP's
BAPI transaction guidance allows multiple instances of the same object type
within one LUW, but local tests cannot confirm how repeated PR creates interact
with target-system number assignment, locks, update tasks, and custom exits.
Verify those behaviors and the target BAPI message set before using atomic
multi-create in production
([SAP BAPI transaction model](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_FOR_SOH_740/166400f6be7b46e8adc6b90fd20f3516/4d5b102ba1483d8fe10000000a42189e.html?version=7.40.16)).
`CREATE_REQUISITIONS_BULK` runs each `BAPI_PR_CREATE` with an independent
commit or rollback and continues after a failed document by default. With
`iv_stop_on_failure`, later documents remain in the result as skipped and
previous commits remain. Verify that the target release releases locks and
completes update tasks at each transaction boundary, and review number
assignment and returned messages with representative creates.

The lot-size procedure controls which master settings SAP considers: SAP
documents minimum lot size, maximum lot size, and rounding for lot-for-lot
planning, while fixed lot sizing is a separate procedure ([SAP lot-sizing
procedure](https://help.sap.com/docs/PRODUCT_ID/cd9e0c364e1e41e19ea633db7862222e/e52ec95360267614e10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=7.0.3),
[SAP fixed lot size](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/f899ce30af9044299d573ea30b533f1c/4e30c95360267614e10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=2023.latest),
[SAP rounding and maximum-lot splitting](https://help.sap.com/saphelp_SCM700_ehp01/helpdata/en/be/30c95360267614e10000000a174cb4/content.htm?no_cache=true)).
This suggestion API models `EX`, `FX`, `HB`, daily `TB`, calendar-month `MB`,
weekly `WB`, and planning-calendar `PK` from resolved plant/calendar periods,
and supports additional period-based or custom keys when callers provide
resolved bounds in `it_resolved_lot_size_periods`.
Daily `TB` proposals use the requirement date as both period boundaries.
Unless callers pass their own periods, the service reads overlapping `T439I` rows for the
requested horizon using `MARC-MRPPP`. Static `MARC-RDPRF` profiles are read
from `RDPR` and applied to each modeled receipt after lot sizing; a rounded
receipt above maximum lot size is rejected. The service does not generate or
extend calendar periods or infer other period boundaries. Additional supplied
periods must be non-overlapping and cover each affected shortage date; otherwise
the request is rejected. The service also does not model automatic source
determination or MRP area settings. SAP documents lot sizing
before rounding and threshold-based static profiles ([procurement quantity
calculation](https://help.sap.com/docs/SAP_ERP_SPV/85d3fce10e264972a0155c8b46ecf93b/dca5bb53707db44ce10000000a174cb4.html),
[static rounding profiles](https://help.sap.com/docs/SAP_ERP/85d3fce10e0e1416d83c0fdfa4060189d/f597b6535fe6b74ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest)). SAP documents planning calendars as flexible
period lengths that group proposals falling within each period ([SAP planning
calendars](https://help.sap.com/docs/SAP_ERP/85d3fce10e264972a0155c8b46ecf93b/f1f8c0534b22b64ce10000000a174cb4.html)).
The week-start weekday can be set by the caller; validate the matching week
definition and planning-calendar behavior in the target SAP configuration.
Source-specific planned delivery time is used only when the caller
provides a pre-resolved purchasing info record. SQLite-backed tests execute
the MARC/MARA/T001W/T399D policy reads, RDPR profile reads, and T439I period
overlap query against a local schema; they do not establish target-system
table/field availability, client behavior, or SQL behavior. Verify these
against the target release before deployment.
SAP documents planning calendars as flexible MRP periods ([SAP planning
calendars](https://help.sap.com/docs/SAP_ERP/85d3fce10e264972a0155c8b46ecf93b/f1f8c0534b22b64ce10000000a174cb4.html)); an SAP support article records an upgrade issue where `T439I` was absent ([SAP upgrade note](https://help.sap.com/docs/SUPPORT_CONTENT/sl/3362917348.html)). The field names and descriptions are listed in [SAP material and plant attributes](https://help.sap.com/docs/SAP_ERP/beef6a3baaa149d18944b7170c427838/a785d45556af7b43e10000000a4450e5.html).

Two-step stock transfers use separate goods-movement calls: 303/305 between
plants and 313/315 between storage locations. Removal items carry the receiving
plant or storage location; putaway items use the receiving plant and storage
location as the item's plant and storage location. SAP owns the stock-in-transfer
checks and whether a material-document reference is needed in the target
configuration. Verify BAPI field mapping and available transfer quantities in
the target release; local tests use an API double ([SAP movement types and
two-step transfer guidance](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/8b7b5fe73ef54063a2bfcfbe83cebd38.html),
[plant transfer procedure](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/232f32546c741e6ee10000000a441470.html)).

The stock-transfer inquiry reads `MARC-UMLMC` for plant stock in transfer and
`MARD-UMLME` for storage-location stock in transfer. A blank location aggregates
the location quantity across the plant; the plant quantity is always reported
separately. This inquiry does not include in-transfer quantities in allocation.
The unit-aware inquiry converts these base-unit quantities using the material's
`MARA` base unit and `MARM` ratio, rejecting an unknown unit before the transfer
repository read. Overflow and nonzero base quantities that round to zero at
MARD-LABST precision are rejected. Local tests use fake stock and UOM
repositories; verify unit ratios, both fields, and the aggregate query against
the target SAP release
([SAP stock in transfer fields](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362168094.html)).
The batch inquiry reads `MCHB-CUMLM` for nonzero storage-location transfer
balances and returns them by batch and location. SAP lists this field as stock
in transfer between storage locations ([SAP stock types](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167795.html)).
The local MCHB stub and tests cover only the required field and service mapping;
verify the query and unit semantics against the deployed release.

Blank-location scalar and bulk transfer totals now sum MARD rows in high
precision and reject values outside the output field range. SQLite tests cover
both overflow paths with two maximum location balances. Verify the target SAP
conversion and query behavior against the deployed release.

The local transpiler test harness can miss fixed-width SAP character keys when a
repository method receives a short literal directly. Repository tests use
DDIC-typed material and plant variables so SQLite comparisons include the full
field width. This is a local harness behavior; verify normal key matching on the
target SAP release.

`GET_TRANSFER_LOCATIONS` and its bulk form enumerate nonzero storage-location
quantities from `MARD-UMLME`; these are aggregate rows without batch detail and
must not be combined with the batch-level `MCHB-CUMLM` inquiry as though they
were disjoint. Local tests cover service grouping, ordering, and unit conversion
with repository doubles, not the SQL or target-release stock semantics. Verify
the MARD row scope and quantities against the deployed SAP release.

Cross-plant allocation preview consumes unrestricted stock estimates from the
source plants in the caller-supplied order and location balances in ascending
`LGORT` order. Plant-level reservations follow the stock repository's
deterministic location distribution. `ZCL_GOODS_MOVEMENT_SERVICE` can post
base-unit location splits as a single 301 goods movement, using a caller-supplied
receiving storage location per request and base-unit/ISO mapping per material.
`TRANSFER_PLANT_ALLOCATION` handles non-batch results;
`TRANSFER_PLANT_BATCH_ALLOC` handles exact-batch results; and
`TRANSFER_PLANT_FEFO_ALLOC` handles FEFO results. The latter two preserve each
source split's batch in its goods-movement item. Complete allocation is required
by default; partial allocations can be posted explicitly. The preview does not
reserve stock, so SAP can reject the transfer if balances change. The workflow
does not check stock-transfer configuration, plant-specific material
extensions, transfer lead times, or in-transit quantities. Unit-aware result
wrappers are accepted directly by `TRANSFER_PLANT_UNITS_ALLOC` and
`TRANSFER_PLANT_BATCH_UNITS`; `TRANSFER_PLANT_FEFO_UNITS` also accepts the
unit-aware FEFO result and preserves the selected batch on each movement item.
These methods post canonical base-unit split quantities and validate the supplied
material/base-unit mapping. Use 303/305 postings when the process requires
two-step in-transit handling. The unit-aware allocation variant converts through
`MARA`/`MARM` and rounds displayed source-unit values to quantity-field
precision; use the base-unit splits as canonical amounts. Local tests use
repository doubles; validate source eligibility, conversion factors, ATP, and
the goods movement in the target system.
`TRANSFER_LOCATION_ALLOCATION` maps `ALLOCATE_BY_STORAGE_LOCATION` base-unit
splits to movement 311 items and uses one destination storage location per
request. It checks split totals and rejects a destination matching any source
location. The preview does not reserve stock; local tests use a BAPI double, so
verify movement 311 fields and storage-location transfer configuration in the
target release.
`TRANSFER_LOCATION_BATCH_ALLOC` uses the same path for `ALLOCATE_BY_BATCH`
results and preserves the selected batch on each source-location item. Its
summary type does not contain a batch, so the transfer boundary derives and
validates one consistent batch from the split rows for each request. Validate
batch field behavior with movement 311 in the target release.

`TRANSFER_LOCATION_UNITS_ALLOC` maps unit-aware storage-location splits to
movement 311 items using the canonical base-unit quantities. It checks the
allocation's base unit against the supplied material unit mapping. The local
test uses a BAPI double; verify movement fields and storage-location transfer
configuration in the target release.

`TRANSFER_LOCATION_BATCH_UNITS` maps `ALLOCATE_BY_BATCH_IN_UNITS` splits to
movement 311 items with canonical base-unit quantities and preserves the exact
batch. The result summary has no batch field, so the transfer boundary derives
and checks one consistent batch per request. Local tests use a BAPI double;
verify movement fields and storage-location transfer configuration in the
target release.

`TRANSFER_LOCATION_FEFO_ALLOC` maps `ALLOCATE_BY_EXPIRY` batch/location splits
to movement 311 items and preserves the preview's batch order, including
multiple batches for one request. It trusts the supplied result's batch and
quantity values; the preview does not reserve stock. Local tests use a BAPI
double, so verify movement fields and storage-location transfer configuration
in the target release.

`TRANSFER_LOCATION_FEFO_UNITS` maps unit-aware FEFO batch/location splits to
movement 311 items using canonical base-unit quantities. It permits several
FEFO-selected batches per request and validates every split's base unit against
the material mapping. Local tests use a BAPI double; verify the movement fields
and transfer configuration in the target release.

`TRANSFER_LOCATION_TWO_STEP` posts movement 313 removals and then one 315
putaway item per request, combining that request's source splits. The postings
commit separately. If putaway fails after a
successful removal, stock remains in transit and the result reports
`is_in_transit = abap_true` so the caller can reconcile or retry putaway. Local
tests use a BAPI double; verify movement 313/315 fields and transfer
configuration in the target release.

`TRANSFER_LOCATION_2STEP_UNITS` converts unit-aware split results to the same
two-step flow only after checking summary and split base units against the
material mapping. Local tests use a BAPI double; verify canonical quantities
and movement fields in the target release.

`TRANSFER_LOCATION_FEFO_2STEP` preserves FEFO split order for movement 313 and
combines same-request, same-batch source splits into separate 315 putaway items.
Local tests use a BAPI double; verify batch fields and transfer configuration
in the target release.

`TRANSFER_LOC_FEFO_2STEP_UOM` checks summary and split base units against
material mappings before posting canonical quantities. Local tests use a BAPI
double; verify unit and batch behavior in the target release.

`TRANSFER_PLANT_TWO_STEP` maps cross-plant location allocations to movement 303
removals and one 305 putaway item per request. The two postings commit
separately; a successful removal followed by failed putaway leaves stock in
transit and is reported in the result. Local tests use a BAPI double; verify
movement fields and transfer configuration in the target release.

Pending two-step results include the exact putaway item table and can be passed
to `RETRY_TRANSFER_PUTAWAY`, which validates that removal committed and posts
only 305/315 items. Persist the pending result if recovery must survive a process
restart. The method does not look up later postings, so callers must reconcile
the transfer before retrying a stale result to avoid duplicating a putaway posted
outside this service. Validate retry behavior against the target SAP release.

`CANCEL_TRANSFER_IN_TRANSIT` uses `BAPI_GOODSMVT_CANCEL` for the complete
removal material document and clears the pending state only after cancellation
commits. SAP cancellation depends on the current stock situation still allowing
the original document to be reversed; see the [BAPI goods movement guidance](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)
and [cancellation rules](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/e72f747389b340229f7fa343975bfa57/7bdbc353b677b44ce10000000a174cb4.html).
SAP guidance says the 303/313 document serves as input help for a 305/315
putaway and the two documents need not be linked ([two-step transfer guidance](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167780.html)).
Callers must reconcile any out-of-band putaway before cancelling a stale
pending result. Verify reversal behavior and posting-period rules in the target
system.

`TRANSFER_PLANT_2STEP_UNITS` accepts unit-aware allocation results only when
summary and split base units match the material unit mapping. It posts canonical
base-unit quantities. Local tests use a BAPI double; verify quantities and
movement fields in the target release.

`TRANSFER_PLANT_DATE_LOC_UOM` and `TRANSFER_DATE_LOC_UOM_2STEP` preserve dated
allocation location splits and canonical base quantities, and reject a split
whose required date or priority differs from its demand. The required date
remains planning metadata; the movement uses the caller's shared posting date.
Local tests exercise the mapping through a BAPI double, not SAP's stock checks
or movement customizing.
The allocation is a local snapshot and does not lock stock before posting.

`TRANSFER_DATE_LOC_ATP` and `TRANSFER_DATE_LOC_ATP_2STEP` require exactly one
relevant, matching, cumulative confirmation for each positive source/date
allocation before posting, and reconcile the source-plant totals with the
location rows that will post. The ATP result is plant-level and does not
confirm the selected storage location or lock stock for the later movement.
BAPI tests use doubles; verify ATP checking-rule scope and movement behavior in
the target SAP release.

`TRANSFER_PLANT_BATCH_TWO_STEP` preserves the selected exact batch on both
303/305 legs and rejects a source split whose batch differs from the demand.
Local tests use a BAPI double; verify batch handling for these movements in the
target release.

`TRANSFER_PLANT_BATCH_2STEP_UOM` also checks summary and source split base
units against material mappings before posting canonical quantities. Local
tests use a BAPI double; verify batch and unit behavior in the target release.

`TRANSFER_PLANT_FEFO_TWO_STEP` preserves the FEFO split order for movement 303
and combines source splits by request and batch into separate movement 305
putaway items. Local tests use a BAPI double; verify batch and transfer
configuration in the target release.

`TRANSFER_PLANT_FEFO_2STEP_UOM` checks summary and batch split base units
against material mappings before posting canonical quantities. Local tests use
a BAPI double; verify quantity and batch behavior in the target release.

`ALLOCATE_ACROSS_PLANTS` keeps the caller's source-plant order primary. Within
each plant, an optional `it_storage_location_priority` list selects locations
first and leaves unlisted locations in ascending code order. The optional
allowlist filters availability and allocation candidates; static safety stock
is deducted from the full source-plant balance before that filter. This is a
local routing choice and does not validate storage-location configuration. The
optional `it_source_locations` list can further scope locations by request and
source plant; when provided, every request/source pair needs a nonempty scope.
When omitted, the prior unrestricted request/source routing applies. The
ordinary, exact-batch, and FEFO methods and their unit-aware variants use the
same scope rules. Local tests use repository doubles.
These methods also accept `it_request_location_priorities`. Positive
request-local ranks override the shared order within a source plant, followed
by unranked locations in ascending code order. Caller source-plant order stays
primary. Dated, priority, UOM, and ATP variants forward the rows; UOM ranks are
validated before conversion reads. Local tests cover ranked and unranked
locations, source order, wrapper forwarding, and invalid IDs before reads.

`ALLOCATE_PLANTS_ATP` checks the current-date local cross-plant estimate once
per material/source-plant/base-unit group with the caller's ATP check rule.
Confirmed quantities total the returned confirmation lines through the check
date and are capped at the locally allocated quantity. ATP is reported
separately; it does not reserve stock or change local source selection. The
availability API is mocked locally, so verify the target check rule, BAPI
signature, and confirmation behavior in SAP.

`ALLOCATE_PLANTS_PRIORITY` and `ALLOCATE_PLANTS_UOM_PRIORITY` order shared
undated ordinary source balances by descending priority, preserving input order
for ties. Source-plant order remains caller-controlled within each request, and
results return in caller order. Each allocation summary exposes a one-based
`allocation_sequence` that includes rows with zero allocation and preserves
stable input-order ties. The UOM wrapper validates duplicate request IDs
before conversion. Both wrappers preserve the caller's projected receipt table
and demand cutoff mapping; receipt rows remain caller-resolved, local estimates.
`ALLOCATE_PLANTS_UOM_ATP_PRIO` checks positive local source allocations by
material, source plant, and base unit. Its ATP response is plant-level and does
not confirm storage-location routing or reserve stock. Local tests use stock,
UOM, and ATP doubles.

Exact-batch cross-plant allocation uses the repository's `MCHB-CLABS` and
`RESB` availability estimate and preserves the requested batch across source
plants. It does not run SAP batch determination or check transfer configuration;
verify batch, source location, and any subsequent goods movement in the target
system. The alternative-unit variant converts through `MARA`/`MARM` and rounds
source-unit output to the quantity field's precision; the base-unit splits are
canonical. `it_storage_location_priority` orders locations within each source
plant after the caller's source-plant order; unlisted locations follow ascending
location code. Local tests use repository doubles.

`ALLOCATE_BY_STORAGE_LOCATION` and its unit-aware variant can order eligible
storage locations using a caller-supplied priority list. A demand's explicit
preferred location remains first when fallback is enabled; locations omitted
from the priority list remain eligible afterward in ascending code order.
Blank and duplicate priority entries are rejected before repository access.
The priority list does not verify plant-specific storage-location
configuration, and local tests use repository doubles rather than target MARD
data.
Both methods accept `it_request_location_priorities` to override the shared
order for one request. Lower positive ranks win, equal ranks sort by location
code, and unranked locations follow by code. The UOM variant maps each request's
order through internal row IDs; invalid and duplicate rows are rejected before
repository or UOM reads. These ranks only order the existing candidate set and
do not change location eligibility.

`ALLOCATE_LOCATION_PRIORITY` and its UOM variant allocate higher-priority
demands first while returning summaries and location splits in caller order.
Internal row mapping preserves repeated caller request IDs. Summaries and
location splits expose one-based `allocation_sequence` values that follow
priority and stable input-order ties, including unallocated rows. The UOM
ATP local estimate preserves both summary and split ranks. The UOM ATP wrapper
reports plant-level availability separately; it does not confirm the local
location split or reserve stock. Local tests use repository doubles, so verify
the target plant's location and ATP data before relying on the result.
The dated base and UOM location allocators accept the same request-specific
ranks, and dated ATP wrappers forward them to the local estimate. With
projected receipts, ranks apply only when a location is eligible by the demand
date. This remains a local forecast and does not confirm or reserve routed
stock in SAP.

`ALLOCATE_BY_BATCH` and its unit-aware variant also accept the location-priority
list. Allocation stays within the requested batch; a preferred location remains
first, listed fallback locations follow caller order, and unlisted locations
follow ascending code order. Local tests use repository doubles; verify that
the target batch stock query supplies the expected location/batch rows.
The base, UOM, priority, and ATP batch variants accept request-specific ranks.
Valid ranks override the shared order per request, ties use location code, and
unranked locations follow by code. Preferred-location fallback remains first.
Invalid or unknown rows fail before repository or UOM reads, and priority
adapters remap ranks with their internal row IDs. The ranks only order eligible
locations for the selected batch; they do not reproduce SAP batch-determination
strategy. Local tests use stock, UOM, and ATP doubles.

`ALLOCATE_BY_BATCH_PRIORITY` and `ALLOCATE_BY_BATCH_UOM_PRIORITY` consume
shared exact-batch stock by descending demand priority by default and return
rows in caller order. Summaries and batch splits expose a one-based
`allocation_sequence` in processing order. Every summary receives a rank,
including zero-allocation demands; each emitted split echoes its demand's
rank. With `iv_prioritize_by_date = abap_true`, they require valid dates and
process earlier dates first, with priority breaking same-date ties. Internal
row mapping preserves repeated request IDs. The ATP wrapper forwards the
option; blank demand dates use its shared `iv_as_of_date`, and the local
estimate preserves summary and split ranks. It checks grouped plant
availability separately and does not reserve stock or validate SAP batch
determination settings. Local tests use repository and ATP doubles; verify
batch, expiry, and confirmation behavior against the target SAP configuration.

`ALLOCATE_FEFO_UOM_ATP_PRIO` reports grouped ATP confirmation for allocations
from the priority-aware FEFO UOM preview. It retains the local split even when
ATP confirms less, and it does not reserve stock. Tests use repository and ATP
doubles; verify batch determination and confirmation behavior in the target SAP
system.

`ALLOCATE_BY_EXPIRY` and its unit-aware variant use the list only to break ties
between locations containing the same batch with the same expiration date.
Expiration and batch order remain primary, and an explicit preferred location
remains first during fallback. Local tests use repository doubles; confirm the
target release's batch expiration mapping and compare the resulting split with
its configured batch strategy. Each demand can request a minimum shelf life;
the greater of this value and the shared `iv_min_days` applies, and the split
reports the effective minimum. The unit-aware wrapper forwards this rule while
converting demand quantities.
The base, UOM, priority, and ATP methods also accept
`it_request_location_priorities`. Valid per-request ranks override the shared
location order only within a matching batch and expiration date; earlier expiry
and batch ordering remain primary. Unranked locations follow ranked locations
by code, and a preferred location remains first during fallback. UOM ranks are
validated before conversion reads and mapped through internal demand IDs.
Invalid or unknown rows fail before stock reads. Local tests cover the six
single-plant FEFO entry points; live batch selection and ATP behavior still need
verification in the target SAP system.

Cross-plant FEFO allocation applies the caller's source-plant order first, then
orders eligible batches by expiration date within each plant. It uses the same
local `MCHB`/`MCHA`/`MCH1` and `RESB` stock estimate and eligibility rules as the
single-plant FEFO preview. Each demand can set `require_known_expiry` to
exclude batches with no expiry date, or `allow_undated_batches` to opt into them
when the shared include-undated option is off. These flags cannot both be true.
The effective row policies are echoed on demand summaries and selected splits
and flow through base, date, unit, priority, and ATP variants. Safety-stock
protection considers undated stock only when a compatible demand can use it
with a zero effective shelf-life minimum. Local tests use stock,
UOM, and ATP doubles; verify expiry data and batch selection in SAP. The optional
`it_storage_location_priority` list
breaks ties between locations for the same batch and expiration date; it does
not change source-plant, expiration-date, or batch order. The same list is
available on unit-aware and dated FEFO allocation, including its ATP wrapper.
The cross-plant FEFO base, dated, UOM, priority, and ATP methods also accept
`it_request_location_priorities`. Request ranks override the shared location
order within the same source plant, expiration date, and batch; caller source
plant order and FEFO batch order remain primary, and unranked locations follow
ranked locations by code. UOM rank validation runs before conversion reads, and
the wrappers forward the rows. Local tests cover caller source order, tied
locations, UOM/priority/ATP forwarding, and invalid request IDs before reads.
Priority validation occurs before UOM reads. `ALLOCATE_PLANTS_FEFO_IN_UNITS`
converts its demand through `MARA`/`MARM` and returns canonical base-unit batch
splits alongside rounded source-unit quantities. This selection does not run
SAP batch determination, check transfer configuration, or validate a subsequent
goods movement. Local tests use repository doubles; verify batch determination,
source-plant priority, conversion factors, and any transfer process in the
target system. `ALLOCATE_PLANTS_BY_EXPIRY` also accepts
caller-resolved `it_projected_batch_receipts`; rows dated on or before
`iv_as_of_date` join the local batch balance and future rows are ignored. The
UOM and ATP wrappers forward quantities in base units. The caller must provide
the quantity still expected at the snapshot date and validate its source plant,
location, batch, and expiry. These rows are not derived from SAP planning
documents or sent to SAP ATP. Local tests use stock, UOM, and ATP doubles; verify
receipt assignments, batch expiry, and ATP scope in the target system.

`ALLOCATE_PLANTS_FEFO_PRIORITY` and `ALLOCATE_PLANTS_FEFO_UOM_PRIO` order
undated cross-plant demands by descending priority, preserving input order for
ties, while keeping each demand's caller-ordered source plants and FEFO batch
selection. Summaries, source-plant rows, and batch splits expose a one-based
`allocation_sequence`; every summary gets a rank, and emitted split rows echo
their demand's rank. Results remain in caller order. The UOM wrapper validates
conversions before stock reads, and both methods reject duplicate request IDs
before repository reads. `ALLOCATE_PLANTS_FEFO_UOM_ATP` checks positive local
source allocations by material, source plant, and base unit; its local estimate
preserves the sequence. SAP ATP does not confirm the selected batch or location
split and does not change the priority allocation. These remain local previews
with no stock lock or reservation; SAP batch determination and transfer rules
can produce a different result. Local regression tests use stock, UOM, and ATP
doubles.
`CREATE_FOR_UOM_FEFO_PAIRS` accepts priority UOM FEFO output and applies the
caller-supplied delivery date while carrying exact batches, issuing locations,
priorities, and source units into STO items. It validates that demand, source,
and location totals match before writes. `CREATE_FOR_UOM_FEFO_ATP_PAIRS` accepts
the priority UOM ATP result and carries its exact batches, issuing locations,
and source units into STO items after the same full ATP confirmation check used
by `CREATE_FOR_FEFO_ATP_PAIRS`.

Each cross-plant FEFO demand also supports `minimum_shelf_life_days`; the larger
of the demand value and shared `iv_min_days` controls its batch eligibility,
and every FEFO split reports that effective value. The rule passes through
dated, unit-aware, and ATP wrappers. Shared demand structures are also accepted
by ordinary allocators, which reject nonzero shelf-life values and set expiry
policy flags before reading stock or performing unit conversion because those
paths do not evaluate expiry.

`ALLOCATE_PLANTS_FEFO_BY_DATE` gives earlier required dates first use of shared
batch balances, applies the minimum remaining shelf life against each demand's
required date, and then consumes source plants in caller order with FEFO within
each plant. Higher caller priorities allocate first among same-date demands;
required date remains the primary order and input order breaks equal-priority
ties. Priority also appears on the demand, source, and batch split previews.
Static safety stock is withheld from latest-expiring stock eligible for the
earliest compatible demand. Undated batches qualify only when the minimum is
zero and sort after dated batches. The dated cross-plant FEFO preview can add
caller-resolved `it_projected_batch_receipts` to its time-phased balances. These
rows carry material, source plant, storage location, batch, optional expiration
date, receipt date, and base quantity. Receipts become available on their
receipt date and remain subject to batch expiry, demand shelf life, location
filters, and safety-stock protection. The service does not derive these rows
from PO/STO/production documents or invoke SAP's configured batch strategy;
callers must supply accurate receipt assignments and expiry dates. SAP supports
dynamic shelf-life criteria based on delivery dates
([dynamic date determination](https://help.sap.com/docs/SAP_ERP/3db8848948314edeabbea684714e1055/f8fdb753128eb44ce10000000a174cb4.html));
verify the local required-date policy against the target process before posting
the returned splits.
The UOM and ATP wrappers forward the same base-unit receipt rows. ATP still
checks only the resulting cumulative quantity at the source plant; the caller's
receipt rows are not sent to SAP ATP, which may apply a different supply scope.
Local tests use stock, UOM, and ATP doubles and do not validate receipt
assignments, live batch expiry data, or ATP configuration in the target system.
The optional `it_allowed_storage_locations` list filters local batch-stock rows
consistently across all requests and source plants. `it_source_locations` applies
request/source-plant-specific location rules and must cover every source pair;
when both are supplied their filters intersect. These lists do not validate that
a location is configured for each plant; a location without eligible local stock
simply contributes no quantity.

`ALLOCATE_PLANTS_FEFO_DATE_UOM` converts each demand to the material base unit
before sharing dated FEFO balances. Demand priority, required-date shelf-life
checks, source-plant order, and safety-stock handling follow the base-unit
variant; rounded source-unit amounts are informational while base-unit split
quantities remain canonical. `TRANSFER_FEFO_DATE_UOM` and
`TRANSFER_FEFO_DATE_UOM_2STEP` map the dated result into the existing 301 and
303/305 transfer paths, validate material base units, and require positive
source and batch rows to match demand dates and priorities before those fields
are mapped out. Local tests use a goods-movement double; verify UOM mappings,
batch fields, movement configuration, and transfer behavior in the target SAP
release.

`ALLOCATE_PLANTS_FEFO_DATE_ATP` checks cumulative positive FEFO source-plant
quantities by material, base unit, and required date through the material
availability API. The ATP result is diagnostic and does not adjust the local
batch selection, reserve inventory, or post a transfer. Local tests use an API
double; verify check-rule configuration, planning scope, confirmations, and
date behavior against live ATP in the target system. The direct confirmed and
unconfirmed base quantities include only lines dated on or before the required
date and cap the confirmed amount at the cumulative request; later or undated
lines remain in the raw API result. Checks marked irrelevant return zero in
these convenience fields.

`TRANSFER_FEFO_DATE_ATP` and `TRANSFER_FEFO_DATE_ATP_2STEP` validate the
matching dated ATP rows and reconcile the confirmed source-plant totals against
the selected batch/location splits before posting. Source rows must match their
demand's date, priority, unit, and allocated quantity. The adapter recomputes
date-eligible confirmation from the raw result and rejects inconsistent derived
totals. ATP confirms at plant level; it does not identify or reserve a selected
batch or storage location. Tests use an API double and do not verify the target
system's ATP rule, batch handling, movement configuration, or stock changes
between preview and posting.

Material-document cancellation uses `BAPI_GOODSMVT_CANCEL` for the full
document or selected items, identified by material document number and fiscal
year. An optional posting date is supplied for the reversal; when blank, SAP
applies its default. SAP determines whether the original document or item is
eligible for cancellation. The local tests cover service behavior only; verify
the function signature, `BAPI2017_GM_ITEM_04` item-field mapping, posting-date
default, cancellation eligibility, and returned reversal document in the target
release. SAP documents item-level cancellation in its [Material Document
API](https://help.sap.com/docs/SAP_S4HANA_CLOUD/3f57e7df4a114edabffe8b2d581a59ed/1aef4e402acd4c8b8ec2ea2bfda7715b.html).
The service now rejects malformed Gregorian posting/document dates before
`BAPI_GOODSMVT_CREATE`, and rejects a malformed optional cancellation date
before `BAPI_GOODSMVT_CANCEL`. Blank optional reversal dates remain supported;
SAP still controls posting-period eligibility for valid dates.
`CANCEL_MATERIAL_DOCUMENTS_BULK` issues one BAPI call per distinct document;
by default it continues after an independently committed reversal fails. Its
`iv_stop_on_failure` option stops after the first failure and reports later
documents as skipped. The atomic option stages calls in one LUW and rolls them
back together on an API or commit failure. Verify multi-call commit/rollback
behavior with the target release because local API doubles cannot establish
SAP LUW semantics.

The stock adapter subtracts active, non-deleted `RESB` quantities with no
special-stock indicator from `MARD-LABST`, net of withdrawn quantity. This is
an application-level balance estimate, not SAP's complete ATP calculation: it
does not account for every requirement, checking rule, picking strategy, or
custom availability logic. Batch-level availability and explicit batch
allocation now use `MCHB-CLABS` and the batch/location dimensions on `RESB`.
The optional full-allocation reservation mode uses this local stock preview to
reject shortfalls before the BAPI call; SAP's ATP check can still reject a
complete preview allocation at reservation time.
Exact-batch allocation still requires the caller to name the batch and never
substitutes another one. The FEFO preview and sales-order allocation mode sort
by expiration date (`MCHA-VFDAT`, falling back to `MCH1-VFDAT` for
material-level batch expiration), exclude batches expired before the as-of
date, and put batches without an expiration date last. `reserve_order` passes
the resulting batch splits into reservation requests. A location choice can be
a hard restriction or, when fallback is enabled, is searched first before
other locations are considered in FEFO order. This is not equivalent to SAP's
configurable batch search strategy, which may use classification, other sort
criteria, and system configuration. The local tests use fake repository data
and do not validate the MCHA/MCH1 reads against a target SAP release. Exact
batch selections must cover every open schedule line or use one item-wide
selection in explicit-batch mode. FEFO can use optional batch selections to
constrain listed open rows while leaving unselected rows to FEFO. Batch-managed
split valuation uses the supplied batch.
Direct cost-center and sales-order issue/return line items can pass a
caller-supplied valuation type to `BAPI_GOODSMVT_CREATE`; material-to-material
309/310 transfers also pass source and receiving valuation types. Stock status
now resolves non-batch-managed split valuation from `MCHB-CHARG`, batch-managed
valuation from `MCHA-BWTAR`, and reservation scope from `RESB-BWTAR`. The
single and bulk UOM status methods convert each grouped quantity and retain
base/requested unit codes.
`PREVIEW_BY_VALTYPE` consumes shared balances by effective `as_of_date`
ascending, then descending demand priority. An omitted date uses today and the
default zero priority preserves input order for same-date ties. Allocation
summaries echo priority and one-based allocation sequence, while allocation and
split result rows remain in caller order. Physical batches expired before each
demand's `as_of_date` are excluded;
an omitted date uses the current date. Demands may set a minimum shelf life or
require known expiry. Non-batch-managed split stock is not date-filtered.
`iv_include_undated_batches` defaults to `abap_true`; setting it false excludes
physical batches with no expiry. A demand may opt back in with
`allow_undated_batches`, unless `require_known_expiry` is true; those two row
flags cannot both be true. Summary rows echo the row override and effective
setting.
Optional `it_projected_receipts` rows add base-unit caller supply by valuation
type and are available only on or after their receipt dates. Summary rows
separate current and projected availability; splits mark projected supply and
its availability date. Each row identifies whether its material is
`batch_managed`; managed rows require a physical batch, while non-managed split
valuation rows leave batch and expiry blank and use valuation type as the key.
Projected splits preserve source type, document, item, plant, and schedule-line
identity; current-stock rows leave source fields blank. Source type/document
must be supplied together, and remaining identity fields require a document.
Receipt rows for a material/plant must agree on the management marker, as must
any matching current stock. Repeated physical-batch receipts and any known
current-stock expiry must agree.
Avoid including supply already represented in current stock. An optional
allowed-location list restricts both the availability
summary and allocation. `it_request_locations` can limit locations per request;
rows require a known request and nonblank location, duplicates are invalid, and
an explicit demand location must be in its scope. Request scopes intersect the
global allowlist and are echoed in base/UOM results. The UOM form validates the
rows before conversion. `it_request_batch_candidates` similarly restricts the
split batch key by request, rejects duplicate/unknown/blank rows, filters
summary and allocation, and is echoed through UOM results. It uses the returned
`batch` key, which is physical for batch-managed stock and SAP's dummy
`MCHB-CHARG` key for non-batch split valuation. Request-specific location priorities take precedence
over the global location order; unlisted allowed locations follow
alphabetically. Its UOM form applies the same constraints and order and
converts summary and split quantities to the requested unit while retaining
base-unit detail. For non-batch-managed split
valuation the batch key is SAP's dummy `CHARG` representation of the valuation
type; `batch_managed` distinguishes it from a physical batch. Callers should
use `valuation_type` and leave the posting batch empty for non-batch-managed
materials. These are local estimates using current stock and optional
caller-resolved receipts; they do not run SAP ATP, configured batch
determination, or stock locking. Verify `XCHAR`, `BWTAR`,
`VAL_TYPE`, and `MOVE_VAL_TYPE` behavior against the target release.
Reservations missing a location or batch are distributed across
matching balances in ascending location and batch order.
When an over-reservation exceeds the matching balances, the remaining deficit
is distributed across other positive balances in that order, a conservative
estimate rather than SAP's ATP result.
Sales order open demand now uses `VBEP-WMENG - VBEP-VSMNG` and the item status
from `VBUP-LFSTA`, with requested dates from `VBEP-EDATU`. Order items without
schedule lines fall back to `VBAP` quantities. Callers can supply
`iv_unscheduled_required_date` to use a validated date for item-level rows with
no requested date during preview, ATP, date ordering, or reservation. Without
that option, existing item-level reservation behavior remains unchanged. The
preview and reservation methods also accept `it_unscheduled_required_dates`,
keyed by sales document and item. They reject duplicate keys, invalid dates,
unselected orders, and items with schedule lines. A matching row-specific date
takes precedence over the scalar fallback. Local tests use order API doubles
and do not validate this behavior against SAP. The
Single- and multi-order preview results return `order_summaries`, grouped by
sales document, material, plant, and base unit. Requested, allocated, and
shortfall quantities use checked MARD-LABST arithmetic, and reservation results
carry the same summaries through. Available totals are omitted because line
results show the changing shared-stock balance rather than additive
availability.
Sales-order preview and reservation methods now accept
`it_allocation_requirements` for selected all-or-nothing demands. An
item-wide row applies to every schedule line, and an exact schedule-line row
overrides it. Strict short demands allocate zero and leave stock for later
demands; results echo the effective requirement. Rows can also require
`require_atp_confirmation`, which requires ATP checking and makes reservation
calls reject an insufficient cumulative confirmation before writing. The
result echoes the effective policy. Each ATP check also exposes
`is_fully_confirmed` from its cumulative confirmed and requested quantities.
In bulk reservations, a row-level ATP failure marks only its sales order
unsuccessful and the method continues with later orders by default.
`iv_stop_on_failure` skips later orders after the first row-level ATP or write
failure. The global full-ATP and full-allocation gates still stop the complete
batch before any order is committed.
Single-order and shared multi-order reservation results now expose
`is_test_run` and `is_committed`. The commit flag is set only after a successful
commit; successful simulations and no-op reservations remain uncommitted.
Sales-order allocation now rejects malformed boolean mode flags before order
or stock reads. This includes date, ATP, safety-stock, and dated-receipt
options, which previously could silently behave like false or fail only after
the order had been read.
Batch and location selection rows also reject missing fields, duplicate
item/schedule keys, and mixed item-wide/schedule-line modes before reading the
sales order or its active reservations. Batch fallback requires a preferred
storage location.
opt-in `iv_use_confirmed_qty` mode uses `VBEP-BMENG - VBEP-VSMNG`
clamped to the ordered open quantity, and rejects open item-level fallback rows
without schedule-line confirmation data. Schedule-line `VBEP-MBDAT` is also
read as `material_availability_date`. Single-order preview and reservation
methods and the multi-order date methods can opt to use it for local allocation,
ATP checks, and reservation requirement dates; an open demand without a
schedule line and MBDAT is rejected. The adapter accepts MBDAT when EDATU is
blank so this opt-in mode can proceed; default allocation still requires
EDATU. Local service tests use order API doubles; separate SQLite-backed Open
SQL tests execute the `VBAP`, `VBUP`, and `VBEP` repository reads. They do not
validate those queries against SAP. Verify MBDAT population and the intended
reservation requirement date in the target release. Also verify `VBEP-BMENG`
availability and conversion there.
The sales-order adapter retains the BAPI's
`BAPISDIT-SALES_QTY1/SALES_QTY2` conversion ratio so allocation results can show
quantities in both the sales unit and material base unit. Local tests verify
the ratio mapping with doubles. Overflow and nonzero quantities that round to
zero are rejected by the preview conversion; confirm these fields, conversion
direction, and quantity rounding on the target SAP release.

Without an explicit location choice, location-aware allocation consumes
available `LGORT` balances in ascending code order because no warehouse picking
strategy is configured. Open reservations without `LGORT` are deducted from
the first available locations in that order. A caller-supplied location-priority
list reorders eligible fallback locations, while a sales-order location choice
remains first. Locations not in the list stay eligible in ascending code order.
A sales-order location choice is a hard restriction by default; callers may opt
to use it as the first preference and fall back to other locations. The
preview does not emulate SAP's picking strategy. `preview_order` can opt into
plant-level ATP checks with `iv_check_atp`; those results are returned beside
the local allocation and do not change its splits. ATP checks do not emulate
local location or FEFO selection, and the default preview remains local-only.
Validate target-system picking strategy before using the result as warehouse
instructions.

Sales-order batch choices may identify an order item and schedule line to
select a separate batch per open schedule line. An item-only choice continues
to apply that batch to all open schedule lines on the item. The service rejects
partial selections and combinations of item-wide and schedule-line choices for
the same item before reading stock. The opt-in FEFO mode selects batches for
the order without manual batch choices and accepts optional location choices.

Opt-in safety-stock protection reads static plant/material `MARC-EISBE` and
subtracts it from allocatable stock when `iv_protect_safety_stock` is true; the
default is false. Location and batch paths distribute the buffer in a
deterministic key order, while FEFO keeps earlier-expiring balances available
first. This is not SAP's complete availability check: time-dependent safety
stock and configured checking-rule scope are not modeled. Local tests use a
fake repository; a separate SQLite-backed repository test executes the bulk
MARC-EISBE read. Target-system ATP configuration still needs verification ([SAP safety stock in availability checking](https://help.sap.com/docs/PRODUCT_ID/32da8359c8ee4e8b8e8c5e15cacba5aa/741d645473c50d4ee10000000a423f68.html).

FEFO can apply a caller-supplied minimum remaining shelf-life day count. A
positive value excludes batches without an expiration date because their
eligibility cannot be established. The date arithmetic and filtering are
covered with local fake repository data; the tests do not validate the target
system's `MCHA` / `MCH1` expiration-date reads.

Opt-in order date priority uses the requested schedule date to order the local
allocation and reservation requests. When `iv_check_atp` is enabled on
`preview_order` or `reserve_order`, the service asks SAP about each remaining
open schedule line; the resulting confirmation can still differ from local
allocation and configured priority rules can change the result at reservation
time. On reservation methods, this ATP result is diagnostic by default; the
optional `iv_require_atp_confirmation` gate stops before reservation API calls
if any cumulative material/plant/unit/date quantity is short. The reservation
BAPI still performs its own ATP check, and concurrent changes or customizing
can make its result differ from this precheck. The gate flag accepts only
`abap_true` and `abap_false`; invalid values raise before stock or order reads.
Optional `it_item_priorities`
changes only the local order of same-date lines and is not written to the SAP
sales order. `atp_checks` echoes each row's priority, but requested and confirmed
quantities remain cumulative for the same date; these diagnostics do not split
SAP's aggregate response by priority. Local fakes test allocation, diagnostic
priority, and reservation-call order, not SAP's ATP or reservation behavior.

The stock-status inquiry aggregates the partial local `MARD` stub's `LABST`,
`INSME`, and `SPEME` fields and net active unrestricted `RESB` reservations
by material and plant. It also reports static plant safety stock from
`MARC-EISBE` and the unrestricted quantity remaining after that buffer.
Location status aggregates the stock categories by storage location and uses
the location reservation calculator for available unrestricted quantities
there; the plant-level safety-stock adjustment is reported separately. Service
tests use doubles; SQLite-backed repository tests execute the MARD location and
plant-status aggregates, RESB reservation, and standalone scalar and bulk MARC
safety-stock reads, but do not validate live stock values or target-system ATP
behavior. Scalar location status and available-stock queries now run against
SQLite too, including the distribution of unscoped reservations across location
balances. Batch status reports
`MCHB-CLABS`, batch expiration date, and available quantity after the batch
reservation calculator. Its service tests use doubles, while SQLite-backed
tests execute scalar and bulk MCHB/MCHA/MCH1 and RESB reads, checking expiry
precedence, scoped and unscoped reservation deductions, and active-reservation
filters. These estimates are not SAP's complete ATP calculation.

Single and bulk alternative-unit allocation and plant, location, and batch
stock-status conversion read the base unit from `MARA` and the material-specific
ratio from `MARM`. Bulk allocation methods cache ratios for each material/unit
pair before reading stock, so an invalid unit rejects the full demand set
without a partial stock read. Local tests cover ratio arithmetic and service
handoff with repository doubles; they do not execute these SAP queries. Verify
`MARM-UMREZ`/`UMREN` values, material units, and quantity decimal behavior
against the target release. Conversion rounds to the `MARD-LABST` field
precision and does not invoke SAP's standard unit conversion functionality or
cover batch-specific or catch-weight units.
Location, exact-batch, and FEFO allocation in alternative units convert each
returned location or batch split independently to that field precision; use
the accompanying base-unit splits when exact quantity totals are required.
Local tests cover mixed units, shared stock, converted batch/location splits,
and rejecting an unknown unit before stock reads; they do not execute the SAP
MARM or MCHB/RESB queries.

Explicit batch allocation can prefer a storage location and fall back to other
locations for the same batch in ascending location-code order. This is local
selection policy, not SAP's configured stock-determination or batch-search
strategy. Tests use fake stock and reservation repositories; verify selected
storage locations and reservation behavior against the target SAP
configuration.

`GET_FEFO_BATCH_STATUS` filters the batch-status repository result by the same
expiration-date rule used by local FEFO allocation and sorts eligible dated
batches first. The local query estimates availability from `MCHB` and `RESB`;
verify stock status and expiration-date selection against live data in the
target release. This inquiry does not invoke SAP batch determination.

`ALLOCATE_REQUEST_BY_DATE` uses current unrestricted `MARD-LABST` and subtracts
active unrestricted `RESB` requirements whose `BDTER` is on or before the
requested date, including rows with an initial date. By default it does not
project receipts, reconstruct historical stock, or apply SAP ATP checking rules.
When `iv_include_po_receipts` is true, it adds open, dated schedule quantities
from standard stock purchasing items (`EKPO-PSTYP = '0'`, blank account
assignment, not deleted, not delivery-complete, not a returns item, and goods
receipt expected and `EKPO-INSMK` blank for unrestricted stock). It uses
`EKET-MENGE - EKET-WEMNG` and converts the remaining PO-unit quantity to the
material base unit with `EKPO-UMREZ/UMREN`. SAP maps
schedule-line ordered and received quantities to `EKET-MENGE` and `EKET-WEMNG`
([purchase-order schedule lines](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/af9ef57f504840d2b81be8667206d485/1d6f6bea1c3b4f049742e15a81ff86a0.html))
and defines `UMREZ/UMREN` as the order-unit to base-unit conversion
([purchase-unit conversion](https://help.sap.com/docs/SUPPORT_CONTENT/bwdabc/3361382941.html)).
SAP identifies `EKPO-INSMK` as the purchasing-item stock type
([EKPO field mapping](https://help.sap.com/docs/signavio-process-insights/administration-guide/be4b0a35f6d048eb979899f569509c78.html)); SAP notes that inspection
stock is not available for stock removal
([inspection stock behavior](https://help.sap.com/docs/SAP_ERP/34fc810a607e4ae5a287b6e233b8566f/9e8fc95360267214e10000000a174cb4.html?version=6.17.latest)).
This estimate does not check PO release status, supplier confirmations,
delivery blocks, subcontracting receipts, or returns; scheduled supply may not
arrive as planned. Material QM settings and goods-receipt posting can also
route a receipt to a different stock type than the PO item's `INSMK` value suggests
([PO receipt stock types](https://help.sap.com/docs/PRODUCT_ID/91b21005dded4984bcccf4a69ae1300c/9763bd534f22b44ce10000000a174cb4.html)).
Rows with nonpositive conversion ratios are ignored. The scalar dated-stock
path is covered with repository doubles; a separate SQLite-backed test executes
the bulk PO schedule read and checks its filters, cutoffs, and conversion.
Confirm field definitions and live purchasing data behavior in the target SAP
release.

When `iv_include_sto_in_transit` is true, the date estimate separately adds
stock-transfer item schedule quantities already issued but not yet received
(`EKET-WAMNG - EKET-WEMNG`) when `EKET-EINDT` is on or before the required date.
It filters deleted, returns, no-GR, account-assigned, and non-unrestricted
receiving items, requires a supplying plant in `EKKO-RESWK`, excludes transport
document types and statistical `EKPO-STAPO` items, and accepts purchasing
document categories `F` and `L`. It converts from the PO unit to the material
base unit with `EKPO-UMREZ/UMREN`. SAP defines `WAMNG` as the quantity issued
from the supplying plant and `WEMNG` as the schedule-line quantity received
([STO schedule-line quantities](https://help.sap.com/docs/PRODUCT_ID/368810f3ef2842fab17899c6ffd4e0c8/662f8e536beee647e10000000a441470.html)).
SAP's cross-company in-transit view also filters for an issuing plant, excludes
transport-document types and statistical items, and derives in-transit quantity
from issued minus received
([SAP STO in-transit filters](https://help.sap.com/docs/CARAB/e95c8443f589486bbfec99331049704a/6d107c520ca9214fe10000000a445394.html)).
The repository base is `MARD-LABST`, not the receiving plant's stock-in-transit
balance; SAP documents `MARC-TRAME` as stock in transit for applicable
intra-company stock transport orders and says it decreases at goods receipt
([stock in transit](https://help.sap.com/docs/nullSUPPORT_CONTENT/erpscm/3362168094.html)).
Only issued-minus-received quantity is projected by default. When
`iv_include_unissued_sto` is true, the estimate also adds scheduled-minus-issued
quantity (`EKET-MENGE - EKET-WAMNG`) for items not marked completely delivered.
Both values are converted from the PO unit to the material base unit; SAP
exposes the schedule, issued, and received quantities on STO schedule lines
([STO schedule-line quantities](https://help.sap.com/docs/PRODUCT_ID/368810f3ef2842fab17899c6ffd4e0c8/662f8e536beee647e10000000a441470.html)).
The schedule date is treated as the date stock can be used. The planned amount
may not be issued or received on schedule. This does not validate actual
delivery dates, cross-company behavior, schedule-line unit consistency, or
target-system filters, so confirm these against live STOs. Dated-stock
service tests use repository doubles. A separate SQLite-backed test executes
the bulk EKPO/EKKO/EKET/MARA read for both in-transit and unissued quantities,
including document/item filters, schedule horizons, and unit conversion; it
does not validate the scalar query or live STO lifecycle behavior.

When `iv_subtract_unissued_sto` is true, the date estimate also subtracts
outstanding scheduled STO quantities not yet issued at the supplying plant in
`EKKO-RESWK`. It uses `EKET-MENGE - EKET-WAMNG` due by the required date, skips
completed, deleted, statistical, returns, account-assigned, and no-GR items,
and converts the order unit through `EKPO-UMREZ/UMREN`. SAP documents `RESWK`
as the supplying (issuing) plant
([EKKO field definition](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/6b120435270a45c8b81b203e74c62aae/a1cfb17cbdfa48418b665ae94c15dc79.html)).
Issued quantities are already reflected in source stock and are not subtracted
again. The schedule date is only a planning cutoff; local tests do not execute
this database query or validate target-system STO lifecycle behavior.

When `iv_include_prod_receipts` is true, the date estimate adds open quantities
from released PP production-order and process-order items
(`AFPO-PSMNG - AFPO-WEMNG`) with a goods receipt expected, due by the order's
basic finish date (`AFKO-GLTRP`). It includes order categories 10 (PP
production order) and 40 (process order), labels the projected source as
`PRODUCTION` or `PROCESS_ORDER`, and excludes deleted, delivery-complete,
make-to-order, and account-assigned items. It ignores orders outside the
released phase or already completed/closed. Quantities are converted to the
material base unit with `AFPO-UMREZ/UMREN`. SAP documents `GLTRP` as the basic
finish date and `PSMNG`/`WEMNG` as order quantity and received quantity
([production-order header fields](https://help.sap.com/docs/SAP_PROFITABILITY_PERFORMANCE_MANAGEMENT/7fa13890d47b4c69bbb62175e84e4aa8/76029ca2ca28471e97fd73d0ffed318f.html),
[production-order item fields](https://help.sap.com/doc/63369768645a4883b468546b2c122b23/3.19/en-US/Sample%20Content%20Process%20Mining%20on%20SAP%20S4HANA%20Production%20Planning.pdf)).
SAP classifies AUFK category 40 as a process order and documents manufacturing
orders across AUFK, AFKO, and AFPO
([order categories and manufacturing-order tables](https://help.sap.com/docs/SAP_SUS_SDI/b15a1be1941c44d4be60ba206536283d/d640bfb7e9c24f98b455a492d70328a8.html)).
SAP's manufacturing-order date view also limits receipts to at least partially
released orders that expect a goods receipt
([manufacturing-order date filters](https://help.sap.com/docs/SAP_HANA_LIVE/e31f67ce301b459b81a0c92d3b51d65b/6b9c57f2bc3443ad98d3cd7fb470112a.html)).
The local estimate treats basic finish date as stock-availability date and does
not account for production delays, scrap/tolerance, QM inspection routing, or
special stocks beyond the excluded sales-order/account assignments. Confirm the
phase flags, quantity units, date choice, and receipt stock type against the
target release; repository doubles do not execute these joins.
`GET_PROJECTED_RECEIPTS` returns the individual rows behind these estimates,
including base-unit quantity and PO/STO schedule-line or production-order item
identity. Its source flags are independent; open unissued STO quantity is
separate from issued-but-unreceived transfer quantity. The method uses the same
filters and quantity converters as the dated-stock estimate so callers can
feed its rows to replenishment netting without rebuilding SAP joins. Local
tests exercise the stock-service contract with a repository double; they do not
run the `MARA`/`EKET`/`EKPO`/`EKKO`/`AFPO`/`AFKO`/`AUFK` queries. Validate field
availability, status filters, date choice, and conversions in the target SAP
release. `SUGGEST_COMP_REPL_FROM_STOCK` gathers one receipt result per
unique material/plant through the latest shortage date, retains only matching
base units, and applies the same chronological receipt netting. It does not
change the source filters or verify supplier and schedule execution status.
`ZCL_STOCK_SERVICE->GET_PO_CONFIRMED_RECEIPTS` adds a separate projection for
standard stock POs. It selects EKES rows with `KZDIS = 'X'` and no deletion
indicator, projects each `MENGE - DABMG` remainder at `EINDT`, and also emits
schedule-line remainder using `EKET-MENGE - MAX(EKET-WEMNG, EKET-DABMG)`. This
uses SAP-maintained MRP reduction quantities instead of recreating the
confirmation-category sequence. SAP documents that higher confirmation
categories reduce earlier categories and that reduction values are distributed
by date and category order
([confirmation reduction sequence](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362168302.html)).
Service tests cover the contract and arithmetic with doubles. A separate
SQLite-backed repository test executes the bulk EKES/EKET reads and checks
confirmation and schedule-line mapping, filters, cutoffs, MRP reductions, and
unit conversion. This does not verify SAP's configuration-specific
redistribution. Check confirmation-category customizing, DABMG/WEMNG overlap,
PO units, and receipt totals against MD04 and representative target documents. Use this API instead of the
ordinary PO receipt flag, because those outputs should not be added together.
`GET_PO_CONF_RECEIPTS_BULK` and its `_UOM` variant group repeated requests by
material/plant and use a repository bulk read for all pairs. The repository
selects schedule remainders and confirmations in two multi-pair queries, then
applies each pair's own latest deadline in SQL; the service applies each
request's own deadline afterward. The per-request-options and shared-flags projection
bulk APIs use this same path. The unit form also caches material/unit
conversion ratios. Local service tests verify routing, request ordering,
deadline filtering, and ratio reuse with doubles. A direct SQLite-backed
repository test executes both bulk EKET/EKES reads and the item/header/material
merges, including individual request horizons. Verify target DDIC behavior,
query plans, and confirmation totals on representative SAP data.
The standard projected-receipt APIs also accept `iv_include_po_confirmations`,
including their unit and bulk forms; per-request bulk options accept
`include_po_confirmations`. The option is mutually exclusive with ordinary PO
receipts on each request. Local tests cover combining confirmation rows with
other projection sources, unit conversion, shared horizons, and requests that
choose different PO projections for the same material/plant. The bulk
repository query and merge are covered with local SQLite data; target-system
confirmation semantics and the separate scalar query still require validation.
`ALLOCATE_REQUEST_BY_DATE` and the multi-demand, unit, and ATP dated allocation
methods can also select the confirmation-aware projection. Multi-demand reads
are grouped by material/plant and latest required date; cross-plant reads group
by material/source plant. Receipts are added to each date balance before
safety-stock protection and allocation. Local tests cover arithmetic, grouping,
and source-plant allocation with repository doubles; they do not validate the
live available-stock SQL together with EKES/EKET data in a target system.
Caller-supplied projected-receipt cutoffs, dated allocation requirements, and
FEFO as-of dates are checked as Gregorian calendar dates before UOM conversion,
stock reads, and ATP calls. This catches malformed month/day and leap-day
values; SAP still controls planning-horizon and business-date eligibility.
`SUGGEST_COMP_REPL_FROM_STOCK` can use this bulk projection through
`iv_include_po_confirmations`; it rejects simultaneous use of the ordinary PO
receipt flag. Local tests verify confirmation receipts net component shortages
and the mutually exclusive source selection, but use doubles. Validate the
confirmation quantities, due dates, and resulting shortage suggestions against
MD04 in the target release using the same configuration checks above.
In `GET_PROJECTED_RECEIPTS` and `SUGGEST_COMP_REPL_FROM_STOCK`, enabling
`iv_include_pr_receipts` also returns purchase requisition items due by the
requested horizon. The confirmation-aware PO method returns PO rows only. The
PR query subtracts ordered
quantity (`EBAN-BSMNG`) from requested quantity (`EBAN-MENGE`), converts the
remaining amount from `EBAN-MEINS` to `MARA-MEINS` with `MARM-UMREZ`/`UMREN`,
and traces each row to BANFN/BNFPO. It excludes deleted, completed, requester-
blocked, nonstandard, account-assigned, and special-stock items. SAP's
cross-plant planning guidance documents the deletion, completion, blocked,
item-category, and account-assignment filters
([requirement coverage selection](https://help.sap.com/docs/SCMCSCPP/b654ceec39734aca96c6d395cdc7c69f/f39d21900a69431c9a71f12ea897ccc4.html));
the EBAN field catalog identifies MENGE as requisition quantity and BSMNG as
ordered quantity ([purchase requisition fields](https://help.sap.com/saphelp_aii710/helpdata/en/a3/9857a130f74936ae53aed874867dc3/content.htm?no_cache=true)).
The local estimate does not check release strategy/status, purchasing
organization, source determination, or supplier commitment, and it assumes the
remaining PR quantity will arrive on its requested delivery date. Check these
policies, EBAN/MARM field availability, and conversion/rounding in the target
release. SQLite-backed repository coverage executes both bulk EBAN reads and
the MARA/MARM enrichment, including item filters, request cutoffs, base-unit
conversion, and missing material/unit rows. This verifies only the local
schema and transpiled SQL behavior.
Treat this projection as planning supply, not confirmed inbound supply.
The dated stock-allocation methods accept the same opt-in flag and add the
projected PR amount to their local available quantity. The scalar stock
estimate does not retain PR document trace rows, and combining it with an ATP
preview does not send the PR data to SAP or change the ATP result. Local tests
verify flag propagation and arithmetic with a repository double; the bulk
repository test separately executes the `EBAN` query. Component stock/ATP
previews and multi-sales-order dated preview/reservation methods also carry the
flag through to that local estimate. A reservation based on future PR supply is
still subject to the live BAPI and ATP checks; the projection itself does not
reserve or confirm inbound stock.
Stock-transfer requisitions are selected separately with
`iv_include_sto_pr_receipts`: the read selects item category 7 and the merge
requires a nonblank `EBAN-RESWK` that differs from the receiving `EBAN-WERKS`.
It returns source type `STO_PR` and retains `RESWK` as
`source_plant`. SAP documents purchase requisitions as stock-transfer
documents and describes the stock-transfer requisition item category
([stock transfer in Purchasing](https://help.sap.com/docs/SAP_ERP/b704a8db767040a08100adc846218964/0f62bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest),
[requirement coverage filters](https://help.sap.com/docs/SCMCSCPP/b654ceec39734aca96c6d395cdc7c69f/f39d21900a69431c9a71f12ea897ccc4.html)).
The remaining quantity still uses `MENGE - BSMNG` and the requested delivery
date. It excludes the same deleted, completed, blocked, account-assigned, and
special-stock items, and does not check release status, supplying-plant
availability, or transfer execution. Verify `RESWK`, item-category values, and
the conversion behavior in the target release. The SQLite-backed repository
test executes this read and checks category, supplying-plant, eligibility,
date, and conversion behavior against the local schema.
`ALLOCATE_DEMANDS_BY_DATE` sorts valid unique request IDs by material, plant,
required date, descending caller priority, and input position, then subtracts
earlier allocations from each later date's local estimate so the same stock is
not promised twice. Required date always outranks caller priority; equal
priorities use input order. Repeated material/plant/date estimates and static
safety-stock reads are cached during a call. Results return in input order.
Priority only controls the local same-date allocation preview; it does not
change SAP ATP's cumulative date grouping. `atp_checks` echoes each request's
priority, but confirmation quantities remain shared at the date level and are
not split by priority. The optional PO receipt projection is applied to each
date snapshot. This remains a deterministic local estimate, not SAP's full ATP
calculation.
`ALLOCATE_DATE_DEMANDS_IN_UNITS` converts each dated demand with the material's
`MARA`/`MARM` ratio before stock reads, caches repeated ratios, and reuses the
same dated allocation path, including same-date caller priorities. Base-unit
quantities are canonical; source-unit
availability, allocation, and shortfall are rounded to the quantity-field
precision. Tests use UOM and stock repository doubles and do not execute the
live `MARA`/`MARM` or date-based stock queries.
`ALLOCATE_PLANTS_BY_DATE` applies the date projection to caller-ordered source
plants and shares each material/source-plant balance across earlier demands.
Earlier dates sort first; within one date, higher caller priority takes stock
first and input order breaks ties. The source-plant list remains in caller order
for each request, and summary/source split results return in demand input order.
Priority is local planning behavior and does not change SAP ATP's date grouping.
It returns plant-level splits only; projected receipts cannot be assigned to a
storage location, so this result is for planning and cannot be posted directly
as the location-level transfer allocation.
`ALLOCATE_PLANTS_BY_DATE_LOC` returns location splits from source-location stock using
that same date/priority order and accepts caller-resolved `it_projected_receipts`
with source plant, storage location, receipt date, and base quantity. Receipts
enter on their date, replenish any remaining static safety buffer, and are
filtered by the same source-location rules. The service does not derive their
assignments from SAP planning documents or lock source locations before a later
transfer.
`ALLOCATE_PLANTS_DATE_LOC_UOM` converts each demand using the material's
`MARA`/`MARM` ratio before reading current source-location stock. Base-unit
quantities remain canonical; converted source-unit quantities are rounded to
the quantity field's precision. It forwards caller-resolved `it_projected_receipts`
in base units. Tests use UOM and stock repository doubles and do not execute the
live unit-ratio or location-stock queries. This is still a planning snapshot
without source-location locking.
`ALLOCATE_PLANTS_DATE_UNITS` converts each dated demand using `MARA`/`MARM`
before invoking that same priority-aware plant-level projection. Returned base-unit values are
canonical; source-unit demand and split quantities are rounded to the quantity
field's precision. Local tests use UOM and stock repository doubles and do not
execute the live unit-ratio or dated-stock queries. The result remains a
planning estimate without location splits.
`ALLOCATE_PLANTS_DATE_ATP` checks only positive source splits from that local
estimate. Its client-side cumulative quantity is grouped by source plant,
base unit, and date from this request list; it does not check an unallocated
shortfall, model concurrent requests, or replace SAP's checking-rule scope.
The ATP result remains separate from local allocation and success. Its direct
confirmed and unconfirmed base quantities include confirmation lines dated on
or before the required date and cap confirmation at the cumulative request;
later or undated lines stay in the raw SAP result. These convenience quantities
are zero when SAP marks a check as irrelevant.
`ALLOCATE_PLANTS_DATE_LOC_ATP` applies the same client-side cumulative ATP
comparison to positive plant splits from the unit-aware, location-aware dated
preview. The grouping uses this request list and does not account for
concurrent demand or replace the configured SAP checking rule. ATP remains a
diagnostic; it does not confirm a storage location or change the local split.

`ALLOCATE_DATE_DEMANDS_ATP` groups dated unit-aware demands by material, plant,
base unit, and required date. It checks the cumulative base-unit quantity once
per date group and shares the result with requests due on that date. This
client-side accumulation only includes the supplied request list and cannot
replace SAP's checking-rule configuration or account for concurrent demand.
The local estimate's receipt and safety-stock options do not modify the SAP ATP
request; validate both results against the target system. Each returned row
includes convenience confirmed and unconfirmed base quantities summed from
confirmation lines dated on or before the required date and capped at the
cumulative request. Later or undated lines remain in `atp_result` but do not
count for that date; the convenience fields are zero for checks SAP marks
irrelevant.

`ALLOCATE_REQUEST_DATE_ATP` combines that local estimate with
`BAPI_MATERIAL_AVAILABILITY`, passing one required date and quantity in
`WMDVSX` and mapping plant availability plus all dated confirmation rows from
`WMDVEX`; the scalar confirmation fields retain the first row for convenience.
It also returns `ENDLEADTME` as `end_of_replenishment_lead_time`; SAP only
populates this date when replenishment lead time is active for the check.
SAP describes `WMDVEX` as an output table containing ATP dates and receipt
quantities ([BAPI output](https://help.sap.com/docs/SUPPORT_CONTENT/sapo/3354623243.html)).
SAP documents blank `DIALOGFLAG` as fully available, `X` as partial
or unavailable, and `N` as not relevant to the check
([BAPI availability behavior](https://help.sap.com/docs/SUPPORT_CONTENT/sapo/3354623243.html)).
The result depends on the requested checking rule and target ATP configuration.
Local tests use an API double and cannot validate the FM parameter names, DDIC
types, checking-rule behavior, or returned quantities in the target SAP
release. The adapter uses `BAPICM61M-WZTER` for `ENDLEADTME`; verify this and
the returned date against the target release. The local estimate converts the
supplied quantity from `iv_unit` to the material base unit before reading stock;
the SAP API still receives the original quantity and unit. This relies on the
local `MARA`/`MARM` ratio and should be checked in the target release. Direct
confirmed and unconfirmed base quantities include only confirmation lines
dated on or before the requested date and convert alternative-unit
confirmations with that same ratio. Later or undated confirmations remain in
the raw SAP result for release-specific interpretation.
`preview_order` can request one such plant-level check per positive
open schedule line; item-level fallback rows without a date are rejected.
Before checking, it sorts those lines by required date and accumulates demand
within each material/plant/base-unit group. All lines in the same group and date
are checked against the full cumulative quantity due through that date, while
the result reports both the line quantity and cumulative quantity. This avoids
checking each line as an independent request against the same ATP balance. The
service now makes one BAPI call per unique material/plant/base-unit/date group
and attaches that result to each matching schedule line. SAP
documents that checks without cumulative quantities can overconfirm and
recommends accumulation rule 3 in the relevant configuration
([ATP accumulation](https://help.sap.com/docs/SUPPORT_CONTENT/sapo/3354623235.html));
SAP also documents limitations checking requirement quantities with this BAPI
([KBA 1751389](https://userapps.support.sap.com/sap/support/knowledge/en/1751389)).
The service exposes a shared confirmation splitter that totals the returned
confirmation lines dated on or before the check's required date, caps them at
the cumulative base quantity, and leaves the raw SAP response on every check.
Later and undated confirmations do not count for that demand date. Nonpositive
quantities or conversion factors are rejected before conversion. Confirmed and
unconfirmed values are diagnostic;
they do not account for ATP scope outside the supplied order lines.
The client-side total includes only open lines in this preview and does not
reproduce all configured accumulation or concurrent demand, so validate the
checking rule and results in the target system. Checks use base-unit quantities
and preserve the local allocation and success values. The result set is
separate from local batch/location splits and does not model SAP picking or
batch determination.

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_ALLOCATION` maps only the selected
supply/receiving plant pair from a dated unit-aware allocation into one
`BAPI_PO_CREATE1` purchase order with document type `UB` and item category
`U`. It uses the allocation's source-unit quantity and demand date directly;
it does not calculate transfer lead time or reserve source stock. The service
supports test runs and commits successful BAPI results, while local tests use
an API double and cannot validate the live BAPI signature or target-release
field semantics. SAP's documented no-delivery STO flow uses `UB`/`U` and later
351/101 goods movements
([STO without delivery](https://help.sap.com/docs/SAP_ERP/96bf9ad642cf4b26a29595e3d573fb8c/5213b953495bb44ce10000000a174cb4.html),
[BAPI_PO_CREATE1](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167600.html)).
The service rejects malformed Gregorian schedule/delivery dates before the
create BAPI; valid-date purchasing and planning eligibility still depend on
the target SAP system.
The local BAPI DDIC stubs intentionally cover only the fields mapped here.
Verify document-type/item-category customizing, supplying-plant assignment,
plant/material extensions, required header data, unit conversion, delivery
dates, and BAPI messages in the target SAP release before using the creator.

`ZCL_GOODS_MOVEMENT_SERVICE->ISSUE_STOCK_TRANSPORT_ORDER` maps a supplying-plant
issue against an STO item to movement type 351, BAPI movement code 04, and a
blank movement indicator. Its companion `RECEIVE_STOCK_TRANSPORT_ORDER` maps
the receipt to movement type 101, BAPI movement code 01, and indicator `B`.
SAP describes the 351 step as an issue entered with the issuing plant and
storage location; the BAPI guide classifies code 04 as a transfer posting and
requires a blank movement indicator for that code
([351 issue process](https://help.sap.com/docs/SAP_ERP_SPV/b704a8db767040a08100adc846218964/1562bd534f22b44ce10000000a174cb4.html),
[STO receipt process](https://help.sap.com/docs/SAP_ERP/b704a8db767040a08100adc846218964/0601b953495bb44ce10000000a174cb4.html),
[BAPI movement codes](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).
The local tests validate routing and transaction behavior only; they cannot
confirm that the target release accepts the PO reference and plant/location
fields together for these BAPI calls. SAP performs the final STO history,
batch, stock, and posting-period checks. Validate with representative STOs
before production use.
`ISSUE_STO_UOM` and `RECEIVE_STO_UOM` convert each material quantity to its
caller-mapped base unit before creating the same 351/101 requests. Each line
must include material identity for conversion. Local tests use a fake converter
and API double; verify that the target STO's PO item unit accepts the converted
quantity, including ratio precision and remaining-quantity checks, before
production use.

`ZCL_GOODS_MOVEMENT_SERVICE->ISSUE_CREATED_STO` consumes the committed result
from one STO creation call and builds the 351 payload from its submitted items.
It requires caller-provided unit-to-ISO mappings and a supplying storage
location on every item; FEFO-created items provide that location. The STO PO
and the goods issue are separate commits. If the issue fails, the committed PO
remains and callers must treat it as not issued. Use one call per successful
result when creation returned multiple plant-pair orders. API-double tests
verify mapping and prevalidation, not a live PO/BAPI sequence.

`ZCL_GOODS_MOVEMENT_SERVICE->ISSUE_CREATED_STO_PAIRS` prebuilds requests for
all successful, committed orders before the first BAPI call, skips failed or
uncommitted STO results, then posts one independent 351 goods movement per PO.
It continues after an issue failure by default. With
`iv_stop_on_failure = abap_true`, the first failed or ineligible pair ends
later postings; those rows are marked skipped and counted separately. Earlier
PO issues remain committed if a later one fails. It returns per-pair
issue-attempt and in-transit status.
An STO-creation row already marked `is_skipped` is carried forward as skipped
and is not posted by this method.
Test-run mode validates and simulates each eligible PO issue without marking
stock in transit. Tests use API doubles and cannot confirm a live multi-PO BAPI
sequence or concurrent STO changes.
By default, each issue commits separately. With `iv_atomic = abap_true`, the
method requires every input STO to be eligible, stages all 351 movements in
one LUW, and sets `is_in_transit` only after one shared commit. A movement or
commit failure rolls back the group and clears the returned material document
identifiers. This depends on the target SAP release honoring rollback for
multiple `BAPI_GOODSMVT_CREATE` calls in one LUW; API doubles cannot verify
that behavior. Validate with representative STOs in the target system.

`ZCL_GOODS_MOVEMENT_SERVICE->RECEIVE_ISSUED_STO` and
`RECEIVE_ISSUED_STO_PAIRS` accept a prior non-simulated issue result and prepare
a 101 receipt only for pairs still marked in transit after a successful 351.
All eligible receipt items are
validated before the first BAPI call. Each PO receipt commits independently;
a failed receipt remains in transit while later PO receipts continue by
default. With `iv_stop_on_failure = abap_true`, the first ineligible pair or
failed receipt skips later pairs and reports them separately. A receipt test
run does not clear in-transit status. The service trusts the supplied issue
result, and SAP remains responsible for rechecking PO history, quantities,
batches, receiving locations, and posting-period rules. API-double tests do
not verify a live 351/101 sequence.
Rows already marked skipped by the issue result stay skipped and are not
submitted for receipt.
By default, each receipt commits separately. With `iv_atomic = abap_true`, all
input pairs must be eligible, 101 movements share one LUW, and in-transit state
is cleared only after one shared commit. A receipt or commit failure rolls the
group back and preserves in-transit status. The guarantee depends on the target
SAP release honoring rollback for multiple `BAPI_GOODSMVT_CREATE` calls in one
LUW; local doubles cannot verify this behavior. Validate with representative
STOs in the target system.

`ZCL_GOODS_MOVEMENT_SERVICE->CANCEL_ISSUED_STO` and
`CANCEL_ISSUED_STO_PAIRS` call `BAPI_GOODSMVT_CANCEL` for the complete material
document from each committed 351 result marked in transit. They validate every
eligible material-document/year pair before canceling, then process each PO
document independently. By default, a failed reversal keeps the pair marked in
transit and processing continues. With `iv_stop_on_failure = abap_true`, the
first ineligible pair or failed reversal skips later documents and reports the
skipped count. Cancellation is not simulatable through this API. This state
comes from the caller's prior issue result and may be stale if another process
has since posted a receipt or changed the document.
SAP selects the reversal movement type and checks document history and current
stock; local doubles cannot establish live cancellation eligibility.
Pair cancellations commit independently by default. With `iv_atomic =
abap_true`, the group must be fully eligible before writes and all reversal
calls share one commit. A reversal or commit failure rolls back the group and
preserves every pair's in-transit state. This depends on the target release
honoring rollback for multiple `BAPI_GOODSMVT_CANCEL` calls in one LUW; local
doubles cannot verify that behavior. Validate with representative STOs.

`ZCL_GOODS_MOVEMENT_SERVICE->CANCEL_RECEIVED_STO` and
`CANCEL_RECEIVED_STO_PAIRS` reverse committed 101 receipt documents from prior
receipt results. They prevalidate all eligible receipt material-document/year
keys, cancel documents independently, and restore the pair's local state to
in-transit only after a successful reversal. By default, later documents are
processed after a failure; with `iv_stop_on_failure = abap_true`, the first
ineligible pair or failed reversal skips later documents and reports them
separately. Callers can then reverse the original 351 issue separately. The
result trusts its supplied receipt state; SAP validates the document history,
posting period, and current stock. The cancellation API has no test-run mode,
and local doubles do not verify live 101/102 cancellation behavior.
Receipt cancellations commit independently by default. With `iv_atomic =
abap_true`, every input pair must be received before writes, all 102 reversals
share one commit, and in-transit status is restored only after success. A
reversal or commit failure rolls the group back and preserves received status.
This depends on the target release honoring rollback for multiple
`BAPI_GOODSMVT_CANCEL` calls in one LUW; local doubles cannot verify it.

`CANCEL_STO_RECEIPT_CHAIN` and `CANCEL_STO_RECEIPT_CHAIN_PAIRS` coordinate the
101 reversal and then the original 351 reversal for each received pair. Both
movement document/year keys are validated before the first cancellation. If
101 reversal fails, that pair remains received; if 351 reversal fails after a
successful 101 reversal, the pair remains in transit. Each BAPI cancellation
commits independently, so a failure on one pair does not undo completed work
on earlier pairs by default. With `iv_stop_on_failure = abap_true`, the first
ineligible pair or failed 101/351 reversal skips later pairs and reports them
separately. With `iv_atomic = abap_true`, every input pair must be received,
all 101 and 351 cancellations share one commit, and a cancellation or commit
failure rolls back the group while preserving each pair's received state. This
depends on the target release honoring rollback for multiple
`BAPI_GOODSMVT_CANCEL` calls in one LUW; local doubles cannot verify it. The
operation reverses material documents; it does not delete or close the STO
purchase order. Local doubles cover sequencing and result state, not live SAP
eligibility or concurrency.

`RETRY_STO_CHAIN_ISSUE` and `RETRY_STO_CHAIN_ISSUE_PAIRS` consume a previous
receipt-chain cancellation result and retry only the original 351 issue
reversal for pairs whose 101 reversal succeeded. Pairs still received after a
failed receipt reversal are returned as incomplete and are not changed by this
retry. The methods trust the supplied prior result and do not reread document
history or current stock; SAP validates whether the 351 cancellation remains
eligible. Atomic retry covers only the pending issue reversals. Any 101
reversal committed by the earlier call remains committed if the retry group
rolls back. With `iv_stop_on_failure = abap_true`, the first ineligible pair or
failed 351 reversal skips later unfinished pairs and reports them separately;
completed pairs remain preserved. Local doubles cover state handling, not live
SAP document status or rollback behavior.

`RETRY_STO_CHAIN_RECEIPT` and `RETRY_STO_CHAIN_RECEIPT_PAIRS` use a prior
receipt-chain cancellation result to retry 101 receipt reversals for pairs that
remain received, including pairs restored by an atomic chain rollback. Pairs
whose receipt reversal already succeeded remain in transit for the separate
351 issue retry, and the aggregate chain result remains incomplete until both
movements are reversed. The methods trust the supplied prior state;
SAP validates document history, posting periods, and current stock. Atomic mode
groups only pending 101 reversals, so a later 351 retry is a separate LUW. Local
doubles cover state mapping and transaction handling, not live SAP eligibility
or rollback behavior. With `iv_stop_on_failure = abap_true`, the first failed
101 retry skips later unfinished receipt retries; rows already waiting for the
351 stage remain preserved.

`RETRY_STO_CHAIN` and `RETRY_STO_CHAIN_PAIRS` recover both retryable stages
from the caller-supplied prior result. Received rows retry their 101 reversal
before the original 351; rows already in transit retry only the 351; completed
rows are preserved. Atomic mode groups all newly pending reversals, including
both stages for a received pair, into one LUW. On failure it restores the input
state and clears reversal document IDs created in that LUW. Prior reversals
committed by an earlier call remain committed. With
`iv_stop_on_failure = abap_true`, the first failed retry in the receipt-first
execution order skips later unfinished pairs and reports them separately.
SAP still validates current document history, posting periods, and stock
eligibility, and the shared rollback guarantee for multiple
`BAPI_GOODSMVT_CANCEL` calls must be checked on the target release. Local
doubles cover result mapping and call ordering only.

`ZCL_STOCK_XFER_ORDER_SVC->MARK_STO_FOR_DELETION` and
`MARK_STO_PAIRS_FOR_DELETION` use `BAPI_PO_CHANGE` to set the item deletion
indicator on submitted STO items after a committed creation result. This is a
logical deletion mark; SAP retains the purchasing document and determines
whether its history, authorization, and configuration permit the change. The
local stubs and API doubles do not validate the target release's exact
`BAPIMEPOITEM`/`BAPIMEPOITEMX` signature or eligibility behavior. SAP's example
uses `DELETE_IND` with the corresponding item-X data
([BAPI_PO_CHANGE example](https://help.sap.com/docs/SUPPORT_CONTENT/home/3361892108.html?locale=en-US)).
`MARK_STO_PAIRS_FOR_DELETION` commits independently by default; `iv_atomic =
abap_true` stages all eligible changes in one LUW and rolls the group back when
an item update or shared commit fails. The group guarantee depends on the
target release honoring rollback for multiple `BAPI_PO_CHANGE` calls in one
LUW; local doubles cannot verify that behavior.
Validate this on representative STOs in the target system. Reversing 101/351
material documents by itself does not set the PO deletion indicator.
Single and pair methods now support `iv_test_run`, which forwards `TESTRUN` to
`BAPI_PO_CHANGE` and suppresses commit/rollback. Successful simulations report
`is_successful = abap_true`, `is_test_run = abap_true`, and
`is_deleted = abap_false`. Local doubles verify flag forwarding and transaction
suppression, but cannot confirm the target release honors the BAPI flag or
returns useful messages. Atomic simulation validates each PO independently and
does not test the shared live LUW.

`ZCL_STOCK_XFER_ORDER_SVC->MARK_STO_DELIVERY_COMPLETE` and
`MARK_STO_PAIRS_DELIV_COMPLETE` set `BAPIMEPOITEM-NO_MORE_GR` through
`BAPI_PO_CHANGE`. SAP defines this flag as no further goods receipt expected;
the open PO quantity can become zero even when the item was only partially
received. That is a business closure decision and does not move stock. SAP KBA
3731949 reports cases where this BAPI update fails or leaves the PO open,
including split-valuation context and PO-item number handling. Local stubs and
doubles only exercise the mapped flag, item X flag, message handling, and
transaction flow. Validate the target release, item numbering, valuation, PO
history, and any required fields against representative STOs before using this
operation ([SAP delivery-completed indicator](https://help.sap.com/docs/SAP_ERP/39615c43587c4405aba2de8ebf33cd66/35cee35751bfd812e10000000a4450e5.html),
[SAP KBA 3731949 preview](https://userapps.support.sap.com/sap/support/knowledge/en/3731949)).
Pair orders commit independently by default. With `iv_atomic = abap_true`, all
pair inputs must be eligible before writes, changes share one commit, and a
change or commit failure rolls the group back. The group guarantee depends on
the target release honoring rollback for multiple `BAPI_PO_CHANGE` calls in
one LUW; local doubles cannot verify that behavior. Validate this on
representative STOs in the target system.
The single and pair methods accept `iv_test_run`; the adapter forwards it to
`BAPI_PO_CHANGE`, and successful simulations leave `is_completed` false and
skip commit/rollback. Atomic simulation continues through every PO so each
result contains its own validation status, but it cannot establish shared-LUW
behavior. Confirm that the target release honors `TESTRUN` and returns the
expected messages for both item updates.

Both pair methods now also support opt-in `iv_stop_on_failure`. Their result
rows retain the original order, identify later unattempted rows with
`is_skipped`, and report successful, failed, and skipped counts. In non-atomic
mode, earlier committed PO changes remain. Atomic preflight failure prevents
all changes; a failed staged update rolls back the shared LUW and distinguishes
attempted rows from unattempted rows. The local doubles do not establish target
system rollback behavior for multiple `BAPI_PO_CHANGE` calls in one LUW.

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_SOURCE_PLANTS` builds one STO per
supplying plant for a selected receiving plant. It validates all payloads
before calling the BAPI. By default, each order commits independently, so one
supplier can commit even if a later supplier's BAPI call fails. The result
retains each supplier's order status and submitted items, and the aggregate
success flag is false if any order fails. The method does not reserve stock.
With `iv_atomic =
abap_true`, the service defers the commit until all supplier orders are created;
a create or commit failure rolls back the pending group and stops processing.
This depends on the target SAP release honoring the BAPI transaction rollback
for multiple uncommitted PO creates in one LUW, which local doubles cannot
verify.

`CREATE_FROM_ATP_SOURCE_PLANTS` accepts `ALLOCATE_PLANTS_DATE_ATP` output and
prevalidates matching, relevant, fully confirmed cumulative source/date checks
for every positive split to the selected receiving plant before creating any
PO. This reuses the supplied ATP snapshot; it does not lock stock or rerun ATP
inside `BAPI_PO_CREATE1`, so availability may change before creation. Supplier
orders commit independently by default; `iv_atomic = abap_true` uses the same
single-commit group behavior described above. Tests use allocation and API
doubles and cannot confirm that the target SAP release applies the same ATP
scope to the resulting STO.

`CREATE_FOR_ATP_PLANT_PAIRS` applies the same precheck to all positive
source/target pairs in the supplied allocation, then delegates to the pair
creator. Every split must have exactly one matching relevant check with a full
cumulative confirmation. This prevents missing or short pair checks from
reaching the first PO BAPI call; the snapshot still does not reserve stock or
guarantee the target BAPI's live ATP scope.

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FOR_ALL_PLANT_PAIRS` extends STO creation
across every positive source/target pair in a dated unit-aware allocation.
Receiving storage locations are supplied by target plant; a missing entry is
sent blank so SAP can apply order/configuration defaults. Duplicate mappings
and mappings for targets without allocations are rejected before BAPI calls.
Pair requests are all prepared before the first write, but each purchase order
commits independently by default. With `iv_atomic = abap_true`, the service
defers the commit across the prepared pairs and rolls back the pending group
after a create or commit failure. The batch and FEFO pair methods use the same
transaction behavior. This depends on the target SAP release honoring rollback
for multiple uncommitted PO creates in one LUW. Local tests use API doubles and
do not verify the target release's allowed plant/company-code combinations or
storage-location defaults.

All STO creation pair methods now accept `iv_stop_on_failure`. The default
continues after independent BAPI failures; opting in stops later calls while
preserving every caller-order row and identifying unattempted pairs as skipped.
Summary counts distinguish success, failure, and skipped work. The single-
receiving-plant source method uses the same policy and the ATP wrapper forwards
it. In atomic mode, a create failure rolls back earlier staged orders and
marks not-yet-attempted rows skipped; a shared commit failure reports the
group failure. Local doubles do not verify target-system rollback behavior
for multiple uncommitted PO creations in one LUW.

`CREATE_DATE_LOC_PAIRS` consumes dated, unit-aware location allocations and
maps each source location to a separate STO item. It sends canonical base-unit
quantities, preserving the allocator's base-unit totals when alternative-unit
splits round. Local API-double tests verify mapped dates, locations, units,
totals, and prevalidation. They do not verify target-release `BAPI_PO_CREATE1`
handling of supplying storage locations or schedule dates; run a test order in
the target SAP configuration before relying on those fields. ATP-gated creation
through `CREATE_DATE_LOC_ATP_PAIRS` requires the supplied cumulative checks to
be relevant and fully confirmed. It does not rerun or lock ATP before PO
creation, so availability may change between preview and the BAPI call.

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_BATCH_ALLOCATION` creates a single-pair
STO from a unit-aware exact-batch allocation. Since this allocator has no
delivery-date field, the caller supplies the PO schedule date explicitly. The
BAPI adapter sends the chosen batch through the PO item and its X structure.
Whether SAP accepts and applies that batch to the STO as intended depends on
the target release and batch configuration; validate a test-run and a
representative order before relying on the setting operationally. This path
does not post goods issue or receipt. SAP documents that batch is unsupported
by the S/4HANA Cloud Stock Transport Order OData V4 API at item level, but that
restriction is specific to OData and does not establish the behavior of
`BAPI_PO_CREATE1` ([SAP STO OData V4 constraints](https://help.sap.com/docs/SAP_S4HANA_CLOUD/bb9f1469daf04bd894ab2167f8132a1a/807b2c79e22c4ef7a4c30c928bb3344e.html)).

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FOR_BATCH_PAIRS` extends this mapping to all
positive source/target pairs in one unit-aware batch allocation. Every pair
request is built and validated before the first BAPI call, but each PO commits
independently by default; `iv_atomic = abap_true` uses the shared pair-order
transaction behavior above. A shared delivery date is required and target
storage-location maps follow `CREATE_FOR_ALL_PLANT_PAIRS` behavior. API-double tests verify
batch grouping and no writes when a later pair is invalid; they do not confirm
the target system's BAPI or batch customizing behavior.

`ZCL_PURCHASE_ORDER_SERVICE->CREATE_ORDER` maps a caller-selected vendor and
each item's purchase info record or outline-agreement reference into
`BAPI_PO_CREATE1`. Its local BAPI DDIC stubs cover only the mapped fields, and
the service tests use an API double; they cannot confirm target-release field
availability, reference validation, pricing, source/vendor consistency, or
document-type customizing. SAP describes `BAPI_PO_CREATE1` as a PO creation
interface with header, item, and transaction handling
([SAP BAPI_PO_CREATE1 documentation](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167600.html)),
but verify the exact fields and selected-source behavior in the target system.
In particular, confirm that the target release accepts `INFO_REC` and
`AGREEMENT`/`AGMT_ITEM` as mapped and applies the expected conditions and price.

`CREATE_FROM_SUGGESTIONS` maps already source-selected external replenishment
rows into one PO, requiring one vendor and purchasing organization across all
positive rows. It creates one PO item and schedule line per suggestion and can
convert from the base unit using caller-supplied ratios. It aggregates each
suggestion's quantity into that single item and does not repeat MRP lot splitting
or select a source. Local tests cover source identity, ratio conversion,
prevalidation, and zero-quantity no-ops; they cannot validate the target BAPI's
pricing, source checks, or target-system unit rounding. Locally, conversion
overflow raises the request exception and nonzero quantities rounded to zero are
rejected before the BAPI call. Validate these mappings with the target release
and selected PIR/agreement records.
`prepare_from_suggestions` returns the same validated header, item, source, and
schedule payload without an API call, and `create_from_suggestions` submits it.
Preparation cannot confirm that SAP accepts the selected source, UOM precision,
pricing, or BAPI fields.

`CREATE_FROM_SUGGESTIONS_BULK` groups positive suggestions by vendor and
purchasing organization, validates every group's mapping before the first write,
then creates one independently committed PO per group and continues after
failures. The result preserves the original suggestion index as each item's
`source_request_id`; a failed group can coexist with committed POs from other
groups. Local API-double tests cover grouping order, index preservation,
prevalidation, continuation, and all-zero no-op behavior. They do not verify SAP
locking, pricing, source validation, unit rounding, or partial batch behavior in
the target LUW. Check each per-order result and validate with representative
source records in the target release.

`CREATE_FROM_SUGGESTIONS_ATOMIC` shares the same request builder as the
independent-commit path, then submits every vendor group before one commit.
Service-double tests cover unit conversion, group creation, failure rollback,
provisional-number cleanup, and the no-op path. They cannot confirm whether
multiple `BAPI_PO_CREATE1` calls and their update tasks share the intended LUW
in the target SAP release; verify success and failure batches there.
`prepare_from_suggestions_bulk` returns the complete validated group list
without calling the PO API. Bulk and atomic writes consume this list, but it
cannot validate source eligibility, BAPI field acceptance, or multi-PO LUW
behavior in the target SAP release.

`CREATE_FROM_REQUISITION_ITEMS` maps each selected PR row to a PO item with
`BAPIMEPOITEM-PREQ_NO` and `PREQ_ITEM`, and sets the corresponding item update
flags. SAP's PO creation guidance identifies `POITEM`/`POITEMX` as the item
structures, and SAP's requisition-conversion mapping shows `PREQ_NO` and
`PREQ_ITEM` in `BAPIMEPOITEM`
([BAPI_PO_CREATE1](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167600.html),
[SAP requisition conversion mapping](https://help.sap.com/doc/44c78f4213c44c46bfcf544e832c5ad9/2025.1/de-DE/MCF%28Konfig%29-DE.pdf)).
The adapter's local stubs and service-double tests do not prove those fields or
their X flags exist and behave the same way in the target release. The service
uses the PR read row's `quantity - ordered_quantity` as the PO quantity; the PR
adapter copies `BAPIMEREQITEM-ORDERED` into `ordered_quantity`, so verify that
field's unit and meaning with representative partial and fully ordered items.
The service rejects deleted, closed, exhausted, duplicate, vendor-mismatched,
and purchasing-organization-mismatched rows before calling the PO API. It does
not decide whether the PR is released or source eligible; SAP validates those
conditions. Verify source inheritance, PR ordered-quantity updates, release
behavior, and PO/PR transaction handling in a target-system test.

`prepare_from_requisition_items` performs the same row checks and item mapping
without a PO API call; `create_from_requisition_items` submits that prepared
request. Local tests verify this payload flow but still cannot establish that
the target SAP release accepts the PR references or updates ordered quantities
as expected.

`CREATE_FROM_REQUISITIONS_BULK` accepts selected PR item snapshots paired with
the caller-selected vendor and purchasing organization. It groups by that pair,
keeps each source requisition/item reference, calculates remaining quantity,
and validates every group before the first write. The service rejects duplicate
PR item keys and any assigned PR vendor/organization that conflicts with the
selected values. Local API-double tests cover first-seen grouping, reference
and remaining-quantity mapping, prevalidation, and continuation after a failed
PO. They cannot verify target BAPI field behavior, release and source checks,
PR updates, or LUW behavior across multiple POs. Each group commits separately,
so review all result rows and validate partial completion and PR status updates
in the target release.

`CREATE_REQUISITIONS_ATOMIC` uses the same grouping and prevalidation, then
creates every PO before one shared commit; a create or commit failure triggers
rollback and clears provisional PO numbers. Service-double tests cover that
control flow and result cleanup, but cannot establish whether successive
`BAPI_PO_CREATE1` calls and update tasks share the intended LUW in the target
release. Verify a multi-supplier batch, a mid-batch create failure, and commit
failure in a nonproduction SAP system before operational use.
`prepare_from_requisitions` returns the validated vendor/organization request
groups without calling the PO API. Bulk and atomic writers consume this same
list; preparation still cannot verify SAP source eligibility, BAPI field
acceptance, PR updates, or multi-PO transaction behavior.

`CHANGE_ORDER_SCHEDULES` sends selected item/schedule-line keys and changed
quantity or delivery date through `BAPI_PO_CHANGE` using `POSCHEDULE` and
`POSCHEDULEX`. SAP's integration mapping identifies those schedule structures
and their schedule-line, quantity, and date fields
([SAP field mapping](https://help.sap.com/http.svc/rc/c89a68e4c09c490d9ba03d6f2a3dca88/7.0/en-US/CGIntegrationW7op12.pdf)).
The adapter and local DDIC stubs model only the fields used here; service-double
tests do not validate the target BAPI structure or update flags. The service
does not read schedule lines before writing. It passes `iv_test_run` to
`BAPI_PO_CHANGE` and skips commit and rollback during simulation; SAP's standard
BAPI guidance describes test-run as validation without a database update
([Test Run Parameters](https://help.sap.com/saphelp_snc70/helpdata/EN/df/0495dbbd6f11d1ad09080009b0fb56/content.htm?no_cache=true)).
Confirm `BAPI_PO_CHANGE` honors that option and returns useful messages in the
target release. SAP must also validate item eligibility, schedule-key
existence, schedule quantity versus item total, release/confirmation effects,
and transaction behavior. Bulk simulation validates each PO independently;
atomic simulation does not establish that a shared multi-PO commit would
succeed. Live bulk changes commit each PO independently and may return partial
completion. Verify these cases with representative PO items and multiple
schedule lines in the target release. The service rejects malformed Gregorian
delivery dates before the API update; SAP still determines whether a valid
date can be applied to the selected item's purchasing state.

`CHANGE_ORDER_SCHEDULES_ATOMIC` validates every PO group before calling
`BAPI_PO_CHANGE`, then commits once or rolls the entire set back on a change or
commit error. Service-double tests cover prevalidation, a shared commit,
per-PO result mapping, rollback, and commit failure. They cannot verify that
multiple change BAPI calls share the intended LUW in the target release; test
both successful and failing multi-PO batches there. In test-run mode each PO is
simulated independently and no shared commit or rollback is attempted, so that
mode validates the individual requests only.

`CHANGE_BASE_SCHEDULES` converts requested material-base quantities into each
PO item's unit before passing the schedule rows to the same adapter. Quantity
changes require a successful PO read and reject missing, deleted, or
delivery-complete items; date-only changes do not require a read. Local tests
cover conversion, date-only preservation, batch validation before writes, and
the shared atomic commit. They do not verify live UOM ratios, schedule
eligibility, or target LUW behavior. The BAPI still validates schedule quantity
against the item and its receipt, release, and confirmation state.

`CHANGE_ITEM_QUANTITIES` maps the requested quantity to `POITEM-QUANTITY` and
sets `POITEMX-QUANTITY` for each selected item. The value is the existing PO
item's purchase-order unit. It rejects blank/duplicate item numbers and
nonpositive quantities. SAP's example describes `POITEM`/`POITEMX` item quantity
and the quantity update flag ([SAP BAPI example](https://help.sap.com/docs/SUPPORT_CONTENT/ABAP/3353524339.html?locale=en-US&state=PRODUCTION&version=LATEST)).
`CHANGE_QTY_FROM_BASE` reads the PO item, then converts the requested base-unit
quantity to its purchase-order unit using the material UOM service. It rejects
missing/closed items or unavailable conversion ratios before making a BAPI
call. Both bulk variants read and convert every PO group before writes begin.
The methods forward `iv_test_run` through single, bulk, and atomic updates.
Simulation still performs the local PO reads and unit conversions, then asks SAP
to validate each update without committing. SAP's ME22N field controls govern whether
an item can be changed, and SAP determines how the updated quantity interacts
with existing schedule lines, receipts, release state, and confirmations. Local
tests verify conversion, request shaping, and transaction handling; validate
UOM ratios and quantity changes on representative items in the target release.
`CHANGE_ITEM_QUANTITIES_BULK` commits each PO separately and can report partial
completion. `CHANGE_ITEM_QUANTITIES_ATOMIC` prevalidates all groups, issues each
change, and requests one commit or a rollback for the group. Local tests cover
prevalidation, continuation, shared commit, and rollback; they cannot establish
multi-document LUW behavior in the target release. SAP requires
`BAPI_TRANSACTION_COMMIT` to persist successful BAPI writes
([SAP purchasing BAPI guidance](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167428.html)).
All item-quantity methods accept `iv_test_run`; simulation skips both commit and
rollback. The atomic form therefore validates each PO independently and does
not verify the result of a shared commit.
The base-quantity bulk method shares the per-PO transaction behavior, and its
atomic method shares the single-LUW behavior; local tests cannot establish
target-system conversion configuration or multi-document LUW semantics.

`CREATE_ORDERS_BULK` prevalidates every request, then creates and commits each
PO separately while continuing after failures by default. Its optional
`iv_stop_on_failure` stops later BAPI calls after the first failed create or
commit, retaining all input rows and identifying skipped rows separately.
Earlier committed POs remain committed. All requests in a call must use the
same test-run setting. Local API double tests verify ordering, prevalidation,
per-order continuation, and commit counts, but not SAP locks, update tasks,
workflow, or LUW behavior between PO creates. Validate multiple independent
creates and rollback behavior with the target release before using a bulk batch
operationally.

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FOR_FEFO_PAIRS` preserves every positive
dated FEFO batch/location split as a separate PO item, including the issuing
storage location (`SUPPL_STLOC`). The source-unit split quantity and required
date become the item quantity and schedule date. This reflects the reviewed
allocation only: it does not reserve stock, and SAP documents that STO
availability checks do not check batch stock if a batch was entered. Recheck
availability before goods issue; local tests use an API double and cannot
confirm target-system BAPI handling of `SUPPL_STLOC` and batch.
`CREATE_FOR_ATP_FEFO_PAIRS` prevalidates the matching full plant/source/date ATP
checks before creating those orders. These checks cover the plant-level total,
not each selected batch. The ATP result is a snapshot and neither reserves stock
nor establishes that the target system will enforce the same batch ATP scope.

`ZCL_STOCK_ALLOCATION_FACTORY` composes the production stock, goods-movement,
and STO service adapters. Local tests verify that these services construct;
they do not call the target system's database or BAPIs. Confirm adapter class
availability and standard API signatures in the SAP release where this code is
installed.

## Local PLAN validation findings (2026-10-18)

The PLAN validator previously could not load because two top-level `const`
declarations were duplicated in `scripts/validate-plan.mjs`. Those duplicate
bindings are removed and the script now executes. Its current run reports 26
checks that still fail outside the new purchase-requisition bulk guard. They
cover MARD scoped-batch filtering and reservation allocation, stock-service ATP
and exclusion propagation, production-order ATP bounds, missing XML BOMs,
sales-order reservation UOM and cutoff behavior, project reservation exclusions,
committed-child summaries for several bulk APIs, cost-center flag validation,
and batch-expiry exposure, preview, and posting checks. These are source-guard
findings, not live-SAP observations; each may be a stale assertion or an
implementation gap and needs individual review before treating it as resolved.
The new PR stop-on-failure checks pass. Re-run the PLAN validator after each
triage so remaining failures stay visible.

## Resolved

- `GET_LOCATION_STOCK_STATUS_BULK` accepted excluded reservation keys and
  validated them in the service layer, but the MARD repository did not apply
  them when building location-specific RESB deductions. Matching open
  reservation/item rows are now omitted before location allocation. The
  repository regression verifies that excluding an open 3-unit reservation
  releases exactly those 3 units to the matching location; other reservations
  remain deducted. This affects the local estimate only; SAP reservation state
  is unchanged.
- Expired-stock preview and stock-backed posting paths silently skipped exposure
  rows with no storage location or batch, which could hide malformed snapshot
  data from the caller. Direct and stock-backed previews now reject those rows;
  the shared stock-backed validator rejects them in both the original and
  rechecked snapshots. Atomic and independent stock-backed posting validates
  the first snapshot before requesting a recheck, so invalid original data fails
  after one read without reaching the movement API. Lint and transpilation pass;
  ABAP Unit was not run.
- Stock-service unit conversions bypassed the shared converter's result checks
  and could overflow `MARD-LABST` or silently round a nonzero quantity to zero.
  The conversion helper now catches overflow and rejects both outcomes;
  regressions exercise it through the public plant-status UOM API.
- Negative unrestricted MCHB balances were omitted when reporting positive
  batch availability. The batch calculator now carries their deficit across
  positive batches in stable location/batch order. Direct calculator and
  SQLite scalar/bulk repository regressions cover the net quantity. SAP's
  batch quantity proposal documentation accounts for negative-stock allowance
  per batch ([SAP Help](https://help.sap.com/docs/SAP_S4HANA_CLOUD/32da8359c8ee4e8b8e8c5e15cacba5aa/ec24dd0896fc40199688b235502b8c4e.html)). This local carry order can differ from configured
  SAP batch determination; verify live MCHB behavior and configuration in the
  target release.
- Open reservations assigned to a storage location without a grouped MARD row
  were omitted from location availability. The calculator now distributes
  those quantities like unscoped reservations across returned stock locations.
  Direct calculator and SQLite repository regressions cover the deduction.
- Material-unit conversions could overflow the `MARD-LABST` result type or
  report success after a nonzero quantity rounded to zero. The shared converter
  now returns an unsuccessful result for both cases. ABAP Unit covers direct
  sales-unit ratios, MARM ratios, reverse conversion, and the sales-order
  rejected-item mapping; confirm quantity precision and overflow behavior in
  the target SAP release.
- Several stock readers grouped reservation requirements and withdrawals
  separately before subtracting the totals. Because SAP documents cases
  where issued quantity exceeds a reservation requirement ([KBA 2698885](https://userapps.support.sap.com/sap/support/knowledge/en/2698885)),
  an over-withdrawn item could cancel another item's open demand. Plant,
  dated, location, batch, and sales-order paths now clamp each active RESB
  item to `max(BDMNG - ENMNG, 0)` before aggregation. Local SQLite tests
  cover the affected scalar and bulk paths; they do not execute the SQL or
  validate live reservation data in the target SAP system.
- Project Q reservation reads used an equivalent row filter but duplicated
  the `BDMNG - ENMNG` calculation. Both keyed and WBS-wide readers now use
  the shared clamp. SQLite regression coverage verifies over-withdrawn rows
  are omitted from open totals while the active-item inquiry still returns
  their source quantities for item-level operations.
- Sales-order FEFO rechecked posting compared batch splits but omitted the new
  required-date and priority fields from summary comparison. Posting also did
  not bind those summary fields to each split. Rechecks now compare both fields;
  posting rejects invalid or inconsistent date/priority echoes before the
  movement API call.
- Ordinary, exact-batch, and FEFO STO creation previously trusted nested
  allocation totals while building items from source-plant and issuing-location
  splits. These paths now reconcile demand to source-plant totals in base units
  before any order BAPI call; exact-batch and FEFO also match source-plant totals
  to location splits when those details are present. Undated exact-batch
  creation maps each location split to its own PO item with `SUPPL_STLOC`.
  Tampered summary and split totals are rejected; SAP-side `BAPI_PO_CREATE1`
  handling still needs target-release verification. FEFO STO creation also
  validates each split's echoed as-of date, minimum shelf life, effective
  undated-stock setting, and demand row policy before writing. This validates
  the supplied preview snapshot; it does not re-read or reserve stock.
- The transpiler rejects ABAP method names longer than 30 characters even when
  abaplint accepts them. The allocation unit test name was shortened to comply.
- The transpiler parser rejected an inline `TYPE c LENGTH` method parameter.
  A named interface type alias is used for that parameter instead.
- abaplint attempted a network clone for `open-abap-core` despite an existing
  local checkout. Its dependency now includes the local folder path.
- abaplint and the transpiler do not accept standalone `.func.abap` stubs in this
  project configuration. The adapters keep standard `CALL FUNCTION` calls;
  local tests exercise their interfaces with fakes instead.
- A character literal passed directly to a method parameter typed as
  `MCHA-VFDAT` remained character data in transpiler tests, breaking date
  subtraction. The shared eligibility helper uses generic `TYPE d`, which
  normalizes the DATS value; date-boundary tests and FEFO regression tests pass.
- The transpiler runtime's `DECFLOAT34` conversion from `INT8` fails because
  its conversion path expects a `get()` method. Replenishment quantity scaling
  converts the integer through `STRING` before `DECFLOAT34`; lot-split unit
  tests pass with that workaround.
- SAP receipt calculators can return a positive fractional quantity that rounds
  to zero when converted to the stock quantity type. The receipt adapter now
  validates the converted value before appending a source row, preserving the
  contract that projected receipt quantities are positive.
- Flat source-list contexts repeat plant-level settings alongside detail rows.
  A later row with an initial quota flag could clear the material's `USEQU`
  value during candidate assembly. The service now preserves a noninitial
  setting across rows; the quota-usage assertion covers the regression.

`GET_VALID_PIR_CANDIDATES` and `GET_VALID_OUTLINE_SOURCES` reject malformed
Gregorian delivery dates before repository access. The outline method reads
source-list-linked purchase contracts and scheduling agreements by joining
`EORD` to `EKKO` and `EKPO`. The local stub
now models the required header fields and the service filters categories K/L,
source-list and agreement validity, blocked entries, deletion indicators,
completed items, and conflicting source-list/header vendors. Unit tests use
a repository double for service edge cases; a SQLite-backed integration
test now runs `GET_VALID_OUTLINE_SOURCES` over the real
EORD/EKKO/EKPO/MARC repository reads and checks filtering for blocked source-list
rows, deleted headers or items, completed items, and sources outside either
validity window. The fixture also checks an exact-date inclusive boundary,
K/L category mapping, and source-list flags. SQLite does not confirm
target-system agreement release semantics, item categories, or source-list
blocking semantics. SAP identifies K as purchase
contract and L as scheduling agreement, and describes the source-list link and
validity behavior ([purchase contracts](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/29193bf0ebdd4583930b2176cb993268/59acf04a594348839b8020ff725eb520.html),
[scheduling agreements](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/29193bf0ebdd4583930b2176cb993268/b1cbbdc144ed44fa82645ae0a84c7640.html),
[source lists](https://help.sap.com/docs/SAP_ERP/967e1c2a6a8c4183b7e07d28e7574445/7b7fb65334e6b54ce10000000a174cb4.html)).
The result is not a source assignment and does not check agreement release
status, remaining contract quantity, prices, schedule lines, or delivery
confirmation. Validate the selection with representative documents in the
target SAP release before using it for procurement decisions.
Outline-source results expose `candidate_rank` per request, reflecting the
local fixed-source and preferred-vendor ordering only.
Callers can set `iv_require_mrp_relevant` to filter out agreement links whose
source-list entry lacks `EORD-AUTET` for automatic MRP. The option defaults to
false for review and accepts only the ABAP true/false constants, including for
empty requests. `iv_require_fixed_source` can independently require the fixed
source-list indicator. These filters do not cover the remaining SAP assignment
rules.

`GET_PROJECTED_RECEIPTS` can optionally include scheduling-agreement delivery
schedule lines (`iv_include_sched_agmt_receipts`). It selects external
standard stock items with a due schedule line and projects the remaining
`EKET-MENGE - EKET-WEMNG`, converted by the PO item unit ratio. This does not
check whether the corresponding vendor release was transmitted, whether the
vendor confirmed the schedule, or whether a delivery is still expected. SAP
documents delivery schedule quantities and vendor release transmission as
separate steps ([scheduling-agreement schedules and releases](https://help.sap.com/docs/SAP_ERP/15f6005df5a343d096f63b554e47e14a/217fb65334e6b54ce10000000a174cb4.html)).
A SQLite-backed test now executes the bulk schedule-agreement receipt read
and checks header/item filters, conversion, and cutoff behavior. The separate
single-receipt repository query is still covered only through repository
doubles. Validate field availability, item-selection rules, and sample
quantities in the target SAP release before using these advisory receipts.
The dated stock-availability method now aggregates this source through the same
projected-receipt query when its flag is enabled. Its value affects local stock
allocation estimates only; ATP requests and SAP's ATP result remain unchanged.
Local tests cover flag propagation with repository doubles, not the live SQL.

`ZCL_PROD_COMP_SERVICE->RETURN_COMPONENTS` posts partial reservation-backed
returns with goods movement code 06 and the `XSTOB` reversal flag. The service
requires movement type 261 on the production component and caps the quantity at
the withdrawn balance reported by both `RESB-ENMNG` and
`BAPI_RESERVATION_GETDETAIL1`. SAP derives the reversal type from the
reservation. SQLite-backed repository tests execute the RESB bulk selection,
ordering, and component-field mapping. Local service tests use doubles and
cannot verify the target release's BAPI field mapping, whether the BAPI detail's
withdrawn quantity reflects prior returns, or how final-issue reservations
behave during reversal; validate these cases with representative documents
before rollout.
`PREVIEW_RETURNABLE_COMPONENTS` reads selected keys directly from the component
repository so finally issued rows remain visible; `RETURN_REMAINING_COMPONENTS`
uses that withdrawn balance and rereads before posting. The reads do not lock
the reservation, so SAP's current withdrawn quantity and reversal eligibility
remain authoritative.
`RETURN_REMAINING_BULK` groups the previewed keys by reservation, re-reads the
component repository for each production order, and commits each reservation
independently. Earlier reversals can remain committed when a later group fails;
the second read also does not lock `RESB`. Local doubles verify grouping and
continuation mechanics, but validate scope races, reservation BAPI behavior,
and reversal eligibility in the target SAP release.

`ISSUE_COMPONENTS_IN_UNIT` and `ISSUE_COMPONENTS_BULK_IN_UNIT` convert the
requested alternative-unit quantity to the component unit from `RESB-MEINS`
before posting. Unknown ratios and converter results whose base unit differs
from the reservation component are rejected before the goods-movement call.
Local tests use an in-memory `MARA`/`MARM` converter repository and API doubles;
confirm target-material ratios, BAPI quantity precision and rounding, and
reservation eligibility with representative components in the target SAP
release.

`RETURN_COMPONENTS_IN_UNIT` and `RETURN_COMPONENTS_BULK_IN_UNIT` convert
alternative-unit return quantities to the reservation component unit before
posting. Unknown ratios or a base unit different from `RESB-MEINS` are rejected
before the goods-movement call. Local tests use an in-memory `MARA`/`MARM`
converter repository and API doubles; verify target-material ratios, BAPI
quantity precision and rounding, returned quantities, and reversal eligibility
with representative components in the target SAP release.

`ZCL_PROD_COMP_SERVICE->CANCEL_COMPONENT_ISSUE` calls
`BAPI_GOODSMVT_CANCEL` for a supplied material document and fiscal year, with
optional item numbers. It can reverse selected full document lines or the whole
document; it does not read the document to prove that it came from
`ISSUE_COMPONENTS`, and callers should pass the issue result's document. SAP
validates cancellation eligibility and posting-period rules. The local test
double covers routing and commit handling only.

The public stock-status methods and `GET_UNRESTRICTED_STOCK` reject a blank
material or plant before they call the repository, preventing an incomplete
key from widening the stock queries across records. `GET_UNRESTRICTED_STOCK`
also rejects invalid `iv_protect_safety_stock` values before any read. The
repository interface itself does not enforce this service-level contract;
callers that invoke a repository implementation directly must provide both
keys. Sales-order reservation readers reject blank document keys before a
repository query, and empty bulk requests return without a read. Local tests
verify rejection before a fake read; direct SQLite tests execute the scalar
stock and status repository reads with valid keys. These tests do not verify
target SAP authorization or database behavior.

`GET_STOCK_STATUS_BULK` reads requested plant/material pairs with batched MARD,
RESB, and MARC queries and aggregates the returned rows in ABAP. Local tests
exercise request validation and result mapping with a repository double; they
do not execute the `FOR ALL ENTRIES` SQL or validate database behavior and
quantity totals in a target SAP release. Verify the selected MARD stock
categories and active-reservation filters against representative plant data
before using the result for allocation decisions.
`GET_LOCATION_STOCK_STATUS_BULK` batches its MARD and RESB selections and
applies location-level reservation distribution. SQLite coverage executes the
bulk query and checks two maximum open reservations at one location; each RESB
row reaches the high-precision calculator separately, so the available result
clamps to zero without overflowing an intermediate quantity. Both bulk reads
select `RESB-RSNUM` and `RESB-RSPOS` so `FOR ALL ENTRIES` duplicate elimination
does not merge distinct reservation items that happen to have identical
quantities. Confirm the result shape and aggregate behavior with representative
target-system data.
`GET_BATCH_STOCK_STATUS_BULK` batches MCHB stock, MCHA/MCH1 expiration, and
RESB reservation queries, then applies the existing batch allocation
calculator. SQLite coverage executes this bulk query and checks two maximum
open reservations at one location and batch, preserving each row through
allocation. The local tests do not validate batch-master fallback or reservation
assignment against live SAP data. Verify the result with representative
batch-managed materials in the target release.
`GET_FEFO_BATCH_STATUS_BULK` applies the same local date-eligibility helper as
single-request FEFO status after its bulk read. Its tests use repository
doubles; it does not run SAP batch determination or ATP, and live expiration
and batch-status data remain subject to the batch-query checks above.
`GET_FEFO_BATCH_STATUS_BULK_UOM` converts the eligible batch quantities using
the existing material-unit ratio converter and caches each material/unit
ratio within one call. Local tests use UOM and stock doubles; confirm `MARA`/
`MARM` ratios and quantity precision in the target SAP release. The result is
still a local estimate and does not run SAP batch determination or ATP.
`GET_STOCK_STATUS_BULK_IN_UNIT` also uses cached `MARA`/`MARM` ratios to convert
all plant status quantities after one bulk stock read. Its local tests use UOM
and repository doubles; confirm target-system unit ratios and quantity
rounding. The underlying plant-status SQL has the separate bulk-query checks
documented above.
`GET_LOCATION_STOCK_BULK_UOM` converts location-level stock and reservation
estimates with the same UOM converter. Local tests use UOM and repository
doubles; confirm `MARA`/`MARM` ratios and quantity rounding in the target
release. Its underlying MARD/RESB query behavior is covered by the bulk
location-status caveat above.
`GET_ORDER_RES_BULK_UOM` converts open order reservation quantities from the
repository's base-unit result with cached `MARA`/`MARM` ratios. Its local tests
use UOM and repository doubles; confirm target-system reservation quantity
units, conversion ratios, and rounding with representative `RESB` data.
`GET_BATCH_STOCK_BULK_UOM` converts unrestricted and available batch quantities
with cached material-unit ratios before returning results. Local tests use UOM
and stock repository doubles; confirm `MARA`/`MARM` ratios and quantity
rounding in the target SAP release. Its underlying batch queries and
reservation assignment are covered by the bulk batch-status caveat above.
`GET_PROJECTED_RECEIPTS_IN_UNIT` converts receipt quantities returned in the
material base unit with the existing `MARA`/`MARM` converter. Local tests use
repository and UOM doubles; verify alternative-unit ratios and quantity
rounding with target-system material masters. Its receipt selection limitations
are the same as `GET_PROJECTED_RECEIPTS` above.
`GET_PROJECTED_RECEIPTS_BULK` groups repeated material/plant requests and calls
the existing projection query once through the latest requested date for each
pair. Its local tests use a repository double; distinct pairs still invoke the
existing SQL separately, and the live-data limitations documented for
`GET_PROJECTED_RECEIPTS` remain.
`GET_PROJ_RECEIPTS_BULK_UOM` converts these base-unit rows using cached
`MARA`/`MARM` ratios. Local tests use repository and UOM doubles; verify unit
ratios and quantity rounding in the target release. Receipt-query limitations
are unchanged from `GET_PROJECTED_RECEIPTS`. Review found duplicate request
IDs were not rejected before ratio conversion even though the bulk result is
keyed by request ID; the wrapper now rejects duplicates before conversion.
`GET_PROJ_RECEIPTS_OPTS_BULK` unions per-request source flags for each
material/plant query and filters the grouped rows back to the requested sources
and deadlines. Local tests use a repository double; query and live receipt-data
limitations are unchanged from `GET_PROJECTED_RECEIPTS`.
`GET_PROJ_RECEIPTS_OPTS_UOM` converts those per-request filtered rows with
cached `MARA`/`MARM` ratios. Local tests use repository and UOM doubles; verify
target-system unit ratios and quantity rounding. Projection query limitations
are unchanged.
`GET_STOCK_IN_TRANSFER_BULK` reads MARC and MARD rows with `FOR ALL ENTRIES`,
then aggregates storage-location quantities per request. SQLite-backed
repository tests exercise plant totals, location sums, and exact-location
reads; target-system transfer-stock fields and query behavior still require
verification with representative data.
`GET_STOCK_IN_TRANSFER_BULK_UOM` converts the bulk results with cached
`MARA`/`MARM` ratios. Local tests use UOM and repository doubles; verify target
unit ratios and quantity rounding, together with the bulk-query behavior, in
the target SAP release.
`GET_TRANSFER_BATCHES_BULK` reads matching `MCHB` rows with `FOR
ALL ENTRIES` and groups them by request in the service. SQLite-backed
repository tests execute the batch reads and ordering against a local schema;
verify the `CUMLM` selection and result ordering with target-system data.
`GET_TRANSFER_BATCHES_BULK_UOM` converts each batch row with cached
`MARA`/`MARM` ratios. Local tests use UOM and repository doubles; verify target
unit ratios and quantity rounding with representative batch-managed materials.
Purchase requisitions selected from a PIR now convert each lot using the
candidate's `EINA-UMREZ`/`EINA-UMREN` ratio and submit the purchasing unit in
`BAPI_PR_CREATE`. Overflow and nonzero base quantities that round to zero at
MARD-LABST precision are rejected before the BAPI call. Local tests exercise
the service and mapper contracts with doubles; confirm the target release's
info-record ratio, BAPI `UNIT` semantics, and quantity precision with
representative purchasing records.
`ZCL_SALES_ORDER_SERVICE->READ_ORDERS` validates the complete document list,
then makes one `BAPISDORDER_GETDETAILEDLIST` API call for the complete list and
requests headers and items from the BAPI. It groups the `VBAP`, `VBUP`, and
`VBEP` delivery reads by requested document. Local service tests verify
batching and header field mapping; separate SQLite-backed tests exercise the
repository SQL and schedule/fallback mapping. Neither suite executes the SAP
BAPI or validates database behavior against SAP. Confirm multi-document BAPI
input, returned header/item grouping, authorization behavior, and target-release
query behavior with representative orders.
`ZCL_SALES_ORDER_SERVICE->CHANGE_ORDERS_ATOMIC` validates every order and item
before calling `BAPI_SALESORDER_CHANGE` for each order, then commits once or
rolls back the group on any change or commit error. Local tests use an API
double; verify that repeated change BAPIs share the intended SAP LUW and that
the target release's message and commit behavior supports this transaction
boundary.
`CREATE_ORDERS_ATOMIC` applies one commit or rollback to repeated
`BAPI_SALESORDER_CREATEFROMDAT2` calls and requires a document number for each
non-test create. The raw adapter now enforces this result key too, while
successful test-run simulations may omit the generated number. Confirm multiple
creates share the intended SAP LUW and that the returned document numbers and
commit messages match the target release.
`CREATE_ORDERS_BULK` and `CHANGE_ORDERS_BULK` make one BAPI call and one commit
or rollback per order, continuing after failures. Local tests verify
prevalidation, per-order continuation, and result flags, but not target-system
lock release, update tasks, or workflow behavior between documents. Atomic row
results reflect the group rollback; verify the target adapter's returned
document numbers after rollback.
Single-order create and change calls also reject invalid test-run flag values.
Write services treat A/E/X commit messages as failure even if the commit
adapter's success flag is true; local tests cover this inconsistent response,
but verify the target adapter's commit return mapping.

`DELETE_ORDER_ITEMS` sets `BAPIMEPOITEM-DELETE_IND` and its X flag through
`BAPI_PO_CHANGE`; this is a deletion indicator, so the PO remains and SAP
enforces document-history and eligibility rules. SAP's Help Portal includes a
sample that applies the indicator through `POITEM` and `POITEMX`
([BAPI_PO_CHANGE deletion example](https://help.sap.com/docs/SUPPORT_CONTENT/home/3361892108.html)).
The local API double validates request shaping and transaction handling, not
whether a target PO item can be deleted or how that release represents the
indicator. Single, bulk, and atomic variants pass `iv_test_run` to the BAPI and
skip commit and rollback during simulations. Atomic simulation validates the
individual PO calls and does not prove a shared commit. Validate that the target
release honors `TESTRUN`, along with item eligibility and returned messages,
with representative documents in a controlled target-system process.

`DELETE_ORDERS_ITEMS_BULK` prevalidates distinct PO numbers and all selected
item lists, then commits each document separately and continues after errors.
Partial completion is expected and must be reviewed item by item. Local tests
do not verify SAP locking, downstream workflow, or concurrent changes between
the validation and BAPI calls.

`DELETE_ORDERS_ITEMS_ATOMIC` prevalidates every PO/item group, issues each
`BAPI_PO_CHANGE`, and commits once; any change or commit error requests a
rollback. Tests cover group validation, shared commit, and rollback while
preserving PO identifiers. They cannot confirm multi-document LUW behavior or
item deletion eligibility in the target SAP release; verify a successful and
failing batch there. Its test-run option sends the same changes to SAP for
individual validation without commit or rollback.

`CREATE_ORDERS_ATOMIC` issues multiple `BAPI_PO_CREATE1` calls before one
`BAPI_TRANSACTION_COMMIT`, or calls rollback if any create or the commit fails.
The local fake API verifies service result handling and that the shared commit
or rollback is requested; it cannot establish that the target SAP release
places every created PO in the same LUW or removes all pending changes after a
rollback. Test mixed success/failure and commit failure in a nonproduction SAP
system before relying on the group guarantee.

`MARK_DELIVERY_COMPLETE` and its bulk form set `BAPIMEPOITEM-NO_MORE_GR` and
the corresponding X flag through `BAPI_PO_CHANGE`. SAP describes this indicator
as closing open PO quantity even when the full quantity was not delivered;
further receipts may still be possible under the document's rules
([delivery-completed indicator](https://help.sap.com/doc/saphelp_em700_ehp01/7.0.1/en-US/c7/51a6390f515130e10000000a114084/content.htm?no_cache=true)).
Local API-double tests verify the selected document/item requests and commit
handling, not the target release's allowed item states, authorization, or open
quantity update. Validate with representative short-delivered and fully
delivered items before operational use. Single, bulk, and atomic variants accept
`iv_test_run`; they simulate each PO without commit or rollback. Verify
`BAPI_PO_CHANGE` test-run messages and item eligibility behavior in the target
release.
`MARK_DELIVERY_COMPLETE_ATOMIC` shares the all-group validation and one-commit
transaction with item deletion. Local tests cover grouped calls and shared
commit/rollback; they do not verify that the target release applies each item
flag in one LUW or accepts the selected item states.

`READ_ORDER` calls `BAPI_PO_GETDETAIL1` for header, item, and schedule-line
outputs; `READ_ORDERS` validates unique PO numbers first and then makes one BAPI
call per document. SAP's purchase-order notification flow also uses
`BAPI_PO_GETDETAIL1`, and its schedule-line view exposes scheduled quantity,
delivery date, and goods-receipt quantity
([notification flow](https://help.sap.com/docs/sap_erp_spv/1a781c11dd4f41829c798db4d8ff3a41/c2ae57a5ad6511dc2b8d000f20fcb6a9.html),
[schedule-line view](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/8308e6d301d54584a33cd04a9861bc52/6e52f71dfb5a481b810ce0697708baf2.html)).
The local DDIC structures contain only fields mapped by this adapter, and the
local tests use an API double. They do not verify the target BAPI's output
population or status flags. This reader does not request PO history or derive
remaining open quantity; use the separate projected-receipt service for supply
netting, and verify the receipt projection against target-system PO history.

`RECEIVE_PURCHASE_ORDERS_ATOMIC` stages one `BAPI_GOODSMVT_CREATE` call per PO
and requests one shared commit or a rollback for the complete group. Local API
doubles verify mapping and service orchestration only; they cannot confirm that
the target release keeps repeated goods-movement BAPIs in one LUW or removes
all staged receipts on rollback. Validate multi-PO success, a later receipt
failure, and commit failure in a controlled target system before relying on the
group guarantee. The bulk method commits each PO independently, so earlier
receipts remain posted when a later PO fails. Bulk mode continues by default
and supports `iv_stop_on_failure` to skip later POs after the first failure.
Local tests do not cover the stop option. Both methods prevalidate unique PO
numbers and line items, but SAP still decides PO history, open quantity,
batch, storage location, and posting-period eligibility.
The PO receipt UOM variants require material on each line for conversion to
the mapped base unit; base-unit receipts may omit material when the PO can
provide it. The bulk and atomic forms convert the full request before posting.
Local tests use a fake converter and API double. Verify the applicable PO unit,
ratio precision, open-quantity checks, and BAPI behavior in the target release.

`RECEIVE_PROD_ORDERS_ATOMIC` stages one `BAPI_GOODSMVT_CREATE` call per
production order with GM code 02, movement type 101, and indicator `F`, then
requests a shared commit or group rollback. Local doubles validate request
mapping and service orchestration, not repeated-call LUW behavior or production
order receipt eligibility in SAP. Verify order status, remaining order quantity,
automatic goods receipt/backflush configuration, batch and storage-location
rules, and rollback after a later receipt or commit failure in the target
release. The bulk method commits each order separately and can therefore leave
earlier orders received when a later call fails. It continues by default and
supports `iv_stop_on_failure` to mark later orders skipped after the first
failed receipt. Local tests do not cover this option.
Production receipt lines also map an optional production order item to
`BAPI2017_GM_ITEM_CREATE-ORDER_ITM` for co-products. Local tests verify that
the service preserves the item number in the goods-movement request, but do
not execute the BAPI adapter against SAP. Verify the field and co-product
receipt behavior on the target release.
The production-receipt UOM variants require a material on each line so they
can convert to the mapped material base unit; base-unit receipts may still
omit material when SAP can derive it from the order. Bulk and atomic wrappers
convert the full request before posting. Local tests use a fake converter and
API double; verify material ratios, rounding, the BAPI's accepted receipt unit,
and co-product quantity behavior in the target release.

`ZCL_PURCHASE_ORDER_SERVICE->CREATE_ORDER`, `CREATE_ORDERS_BULK`, and
`CREATE_ORDERS_ATOMIC` reject malformed Gregorian header document dates and
item delivery dates before calling `BAPI_PO_CREATE1`. Bulk and atomic methods
validate every request before the first write. Suggestion preparation also
rejects malformed header and required dates before returning a request. Local
tests use an API double and cannot verify purchasing-date eligibility or
target-release field behavior; SAP remains authoritative for those checks.

`POST_CC_GOODS_ISSUE` validates selected reservation keys against the current
open cost-center reservation read before fetching reservation detail or calling
`BAPI_GOODSMVT_CREATE`. Unit-aware and per-reservation bulk forms use the same
scope check. Reversal variants use a separate key-based `RESB`/`RKPF` read so
fully issued rows can still be scoped; the normal movement pipeline checks the
withdrawn quantity before posting. Both checks are read snapshots: cost-center
assignment, quantities, or reservation status can change before the movement,
so SAP remains the final authority. Local service tests use repository and BAPI
doubles, while separate SQLite-backed tests exercise the repository SQL.
Verify query, authorization, and concurrent update behavior in the target
release.

Resolved local validation gap: `reserve_cost_centers_atomic` and
`reserve_cost_centers_bulk` previously validated `required_date` as a Gregorian
date only when FEFO was enabled, even though both pass that date to SAP in all
allocation modes. They now reject malformed dates before stock reads or writes.
Regression tests cover both entry points; SAP still applies its own posting and
reservation date rules.

Cost-center exact-batch allocation now filters against the reservation required
date and optional minimum remaining shelf life using the repository's batch
expiration data. This is a local stock snapshot; verify `MCHB`/batch expiry
behavior and the target reservation BAPI's batch checks in SAP. A concurrent
stock or batch-master change after preview can still invalidate the result.

Sales-order explicit batch allocation now filters the caller-selected batch
through the schedule requested date, or the current date when no schedule date
is supplied, using the batch expiration date in the local stock snapshot. This
does not run SAP batch determination or protect against a stock or batch-master
change after preview. Verify `MCHB`/batch expiry data and the target
`BAPI_RESERVATION_CREATE1` checks in SAP.

The sales-order batch selection's `minimum_shelf_life_days` is evaluated from
the same effective reservation date and the local batch-expiration snapshot.
It does not replace SAP's batch checks or guarantee that the batch remains
available through posting; validate shelf-life and expiration handling in the
target release.

Test-runner environment note: native Linux Node is available at
`/home/lars/.nvm/versions/node/v22.22.2/bin`. Run
`PATH=/home/lars/.nvm/versions/node/v22.22.2/bin:$PATH npm test` to execute
abaplint, transpilation, and ABAP Unit. Invoking the Windows Node launcher from
WSL fails before the suite starts; use the native Linux runtime instead.

`ZCL_STOCK_SERVICE->ALLOCATE_BY_EXPIRY_ATP` and
`ALLOCATE_BY_BATCH_ATP` apply local unit-aware batch allocation before checking
ATP for positive allocated quantities. They group checks by material, plant,
base unit, and effective date, and report cumulative confirmations through
each date. The local tests verify this orchestration with doubles; they do not
verify that target SAP ATP sees the same batch, stock, or checking-rule scope.
The exact-batch path preserves the caller's selected batch, while FEFO follows
local expiration-date order. Treat both results as comparison previews and
validate them with representative target-system materials.

`ZCL_STOCK_SERVICE->ALLOCATE_BY_LOCATION_ATP` aggregates positive unit-aware
location allocations by material, plant, and base unit and checks them using
the caller's date or `sy-datum`. The local allocation always uses current stock,
even when ATP is checked for a future date. Local doubles verify grouping,
conversion, date validation, and partial-confirmation reporting. They do not
establish whether SAP ATP's stock and checking-rule scope matches the
location-level estimate; the method remains a diagnostic preview, not a
reservation.

`ZCL_STOCK_SERVICE->ALLOCATE_LOCATION_DATE_UOM_ATP` adds dated ATP diagnostics
to the local location estimate. Its checks are plant-level and do not confirm
that a specific storage location or batch will be available. Verify the
checking-rule scope and confirmation lines in the target SAP system.

`ZCL_STOCK_SERVICE->ALLOCATE_LOCATION_BY_DATE_UOM` orders location balances by
required date and same-date priority. Its optional `it_projected_receipts`
input is caller-resolved and expressed in the material base unit, regardless
of each demand's requested unit. The service does not verify receipts against
purchase orders, transfers, or live schedules. The result remains a local
estimate and does not reserve stock; validate location-level availability and
concurrent stock changes in the target SAP system.

`ZCL_STOCK_SERVICE->ALLOCATE_LOCATION_DATE_UOM_ATP` applies plant-level ATP
checks to positive allocations from that local estimate. Receipt projections
affect the local location split but do not make SAP ATP confirm a specific
storage location. Verify the checking-rule scope and confirmation lines in the
target SAP system.

`ZCL_STOCK_SERVICE->ALLOCATE_LOCATION_BY_DATE` applies the same date ordering
to base-unit demands without material UOM conversion. Its optional
`it_projected_receipts` input uses caller-resolved material, plant, location,
date, and base-unit quantities. The service does not verify the receipt against
purchase orders, transfers, or live schedules. When safety-stock protection is
enabled, the service withholds opening stock for the static buffer and incoming
receipts replenish any remaining buffer before becoming allocatable. This
estimate does not reserve stock; validate receipt assignments, buffer
semantics, and concurrent changes in the target SAP system.

`ZCL_PROJECT_STOCK_SERVICE->READ_AVAILABLE_STOCK_IN_UNIT` and
`READ_AVAILABLE_STOCK_BULK_UOM` convert the project-stock repository's base-unit
quantities using material UOM ratios. Local tests cover conversion and early
rejection of unknown units; validate the target `MARA`/`MARM` ratios and
`MSPR-PRLAB` unit semantics in the target SAP release.

`PREVIEW_TRANSFER_FEFO_BY_DATE` prioritizes current project WBS batches by
required date and same-date priority, then checks expiry through each required
date. `TRANSFER_WBS_FEFO_BY_DATE` repeats the preview and compares the complete
batch split before posting movement 415/Q. These are local snapshots: the
second read does not lock project stock, so stock or batch data can still
change before SAP posts the movement. SAP remains authoritative for special
stock transfer and batch checks; verify movement 415/Q and the WBS fields in
the target release. The dated preview and transfer wrapper use internal row IDs
to keep repeated caller IDs distinct, then restore caller IDs and input order
in returned allocations and batch splits. Consumers that need to join repeated
IDs should keep a separate row key.
Base, priority, and dated FEFO transfer previews accept request-specific
location ranks after expiry and batch order tie. Priority and dated adapters
map the ranks through internal rows; ATP adapters forward them, and the three
WBS FEFO transfer methods retain them during both stock snapshots. Local tests
cover shared IDs, competing locations, and 415/Q split mapping. These previews
remain snapshots, and target SAP posting behavior still needs validation.
`PREVIEW_TRANSFER_FEFO_ATP` checks positive undated batch allocations,
grouped by material, plant, base unit, and ATP date (default `sy-datum`). A
future ATP date does not change the current WBS stock estimate or confirm the
selected batch. Local tests use an availability API double.
`PREVIEW_TRANSFER_FEFO_DATE_ATP` adds cumulative plant-level ATP checks for
positive dated batch allocations, grouped by material, plant, base unit, and
required date. ATP does not confirm special WBS stock or the selected batch,
and the checks do not reserve stock. Local tests use an API double; verify the
checking rule and confirmation lines in the target SAP system.

`PREVIEW_TRANSFER_LOCATION_DATE` orders batchless source-WBS location balances
by required date and same-date priority. `TRANSFER_WBS_BY_LOCATION_DATE`
rechecks the location splits before posting movement 415/Q, but that second
read does not lock stock and future receipts are not assigned to locations.
The dated preview and transfer wrapper use internal row IDs to preserve
repeated caller IDs, then restore caller IDs and input order in returned
allocations and location splits. Consumers that need to join repeated IDs
should keep a separate row key. Verify the destination/source WBS fields and
movement behavior in the target SAP release.
`PREVIEW_TRANSFER_LOC_ATP` adds plant-level ATP checks for positive
undated location allocations. The ATP date defaults to `sy-datum`; the local
stock estimate remains current and ATP does not confirm the selected storage
location. Local tests use an availability API double.
`PREVIEW_TRANSFER_LOC_DATE_ATP` adds cumulative plant-level ATP checks for
positive dated location allocations, grouped by material, plant, base unit,
and required date. ATP does not confirm special WBS stock or the selected
storage location, and the checks do not reserve stock. Local tests use an API
double; verify the checking rule and confirmation lines in the target SAP
system.

`ALLOCATE_LOCATION_DATE_ATP` checks the positive portions of the local dated
location allocation using cumulative plant-level ATP quantities by material,
plant, base unit, and required date. Callers supply the base unit for each
demand; the service does not validate that mapping against the live material
master. SAP ATP does not confirm the local storage-location split, and the
diagnostic does not reserve stock. Local tests use doubles rather than the
target ATP configuration.

`ALLOCATE_PLANTS_BY_DATE_LOC` and its UOM/ATP variants accept caller-resolved
`it_projected_receipts` with a source plant, storage location, receipt date, and
material base-unit quantity. The service validates that each row maps to a
requested material/source plant but does not verify it against a PO, STO, or
production schedule. Source-location filters still apply to allocation. The
ATP variant checks plant-level availability and does not confirm the projected
receipt's location assignment. Local tests use doubles; validate receipt
assignments, buffer behavior, and ATP configuration in the target SAP system.

`ALLOCATE_QUALITY_BY_EXPIRY_ATP` runs the local quality-stock FEFO preview in
the requested UOM, then checks each positive material/plant/base-unit/date
group through SAP ATP. The ATP call is plant-level and does not establish that
SAP ATP includes quality-inspection stock or honors the local batch split.
Local tests use fake quality stock, conversion, and ATP APIs; validate stock
category, checking-rule, and confirmation behavior in the target release.

Single-plant `ALLOCATE_BY_EXPIRY` and its unit/ATP wrappers accept
caller-resolved projected batch receipts in material base units. The local
preview applies the receipt date and the demand's effective FEFO as-of date,
checks supplied expiry values against known current batch expiry, and lets due
receipts replenish any residual static safety-stock buffer. It does not read or
verify purchase orders, transfers, or production schedules. SAP ATP checks the
resulting local quantity by plant/date and does not receive the projected
batch assignment. Local tests use doubles; validate receipt dates, batch
master expiry, safety-stock meaning, and ATP scope in the target release.

Quality-stock FEFO accepts the same receipt fields and interprets their base
quantities as projected quality-inspection stock. It adds those quantities only
to the local `MCHB-CINSM` estimate after their receipt dates and applies the
same effective date and expiry rules. No SAP planning document is consulted,
and plant-level ATP does not validate quality stock or batch assignment. Local
tests use doubles; confirm stock-category and quality-management behavior in
the target release.

Exact-batch allocation accepts caller-resolved dated batch receipts in base
units. The selected batch and location rules still apply; receipt dates gate
their balances against each demand's as-of date, and projected quantities can
replenish the residual static safety-stock buffer. Single-plant and
cross-plant exact-batch rows can require known expiry individually; local
summaries and batch/location splits echo the setting. The UOM and ATP wrappers
forward row policy and receipts, but ATP does not confirm their batch
assignment. Local tests use stock and ATP doubles; validate batch identity,
receipt assignment, and safety-stock behavior in the target SAP release.

Cross-plant exact-batch allocation accepts the same caller-resolved receipt
fields and requires each receipt's material, source plant, and batch to map to
a demand/source pair. The undated API uses a demand's optional `as_of_date` or
today; the date-prioritized API uses the demand's `required_date`. A positive
`minimum_shelf_life_days` excludes unknown expiries and batches that do not
meet the remaining-life requirement. UOM and ATP wrappers preserve this local
estimate, while ATP remains plant-level. Local tests do not validate
source-plant routing, batch master data, or static safety-stock semantics in
SAP.
The base, dated, UOM, priority, and ATP forms also accept
`it_request_location_priorities`. A request's positive local ranks override
the shared location order within its selected batch and each source plant;
unranked locations follow in location-code order. Caller source-plant order
remains primary. UOM forms validate rank request IDs before conversion reads,
and the wrappers forward the rows. Local tests cover source-plant order,
ranked and unranked locations, wrapper forwarding, and invalid IDs before
reads.

`ALLOCATE_PLANTS_BATCH_PRIORITY` and `ALLOCATE_PLANTS_BATCH_UOM_PRIO` accept
per-demand `as_of_date`; blank dates use today. Earlier dates take precedence,
then descending priority and input order break ties. Their one-based
`allocation_sequence` follows that effective date order, treating blank dates
as today. Summaries and source/location splits return in caller order. Each
summary gets a rank, including zero allocations;
emitted source/location rows echo their demand's rank. Duplicate request IDs and
invalid UOM dates are rejected before stock reads or UOM conversion. The UOM
ATP local estimate preserves the summary and split ranks.
`ALLOCATE_PLANTS_BATCH_ATP` and `ALLOCATE_PLANTS_BATCH_UOM_ATP` group positive
allocations by material, source plant, base unit, and demand `as_of_date`;
blank dates use today. `CREATE_FOR_PRIO_FEFO_PAIRS` accepts priority base FEFO results with the
caller material/base-unit map, preserving priority, batch, and source-location
splits through the validated FEFO pair-order path.
`CREATE_FOR_UNIT_FEFO_PAIRS` accepts unit-aware cross-plant FEFO results
with a caller delivery date, retaining source-unit quantities, selected batch,
and issuing location through validated pair-order creation.
`CREATE_FOR_BASE_FEFO_PAIRS` accepts base cross-plant expiry allocations
with a caller material/base-unit map and delivery date, preserving the
FEFO-selected batch and issuing location through STO creation.
`CREATE_FOR_PRIO_BATCH_PAIRS` accepts priority base batch allocations with
the caller material/base-unit map and retains the selected batch, priority,
and issuing location in the pair-order flow.
`CREATE_FOR_BASE_BATCH_PAIRS` accepts base exact-batch allocations with a
caller-supplied material/base-unit map and preserves batch and location
splits through the validated pair-order path. `CREATE_FOR_UOM_BATCH_PAIRS` carries priority UOM
allocations into STO items while retaining exact batch, issuing location, and
source-unit quantity. `CREATE_FOR_UOM_ATP_PLANT_PAIRS` accepts priority UOM
plant ATP output, validates full current-date confirmation per material/source
plant/base unit, then carries date and location splits into STO items in base
units. `CREATE_BASE_DATED_BATCH_PAIRS` accepts dated base batch allocations with a
caller material/base-unit map, preserving the request date, exact batch, and
issuing-location split in STO items.
`CREATE_BASE_DATED_FEFO_PAIRS` accepts dated base FEFO allocations with a
caller material/base-unit map, preserving the request date, FEFO priority,
selected batch, and issuing-location split in STO items.
`CREATE_FOR_BASE_DATE_PAIRS` accepts dated base plant results with a caller
material/base-unit map and preserves the allocation delivery dates through
source/target pair-order creation.
`CREATE_FOR_BASE_DATE_LOC_PAIRS` accepts dated base location allocations with
a caller material/base-unit map, preserving the per-demand dates, priorities,
and issuing-location splits through the validated STO path.
`CREATE_FOR_BASE_PLANT_PAIRS` and `CREATE_FOR_PRIO_PLANT_PAIRS` accept
base cross-plant results with a caller-supplied material/base-unit map; they
reject missing or duplicate unit mappings before order writes. The caller
must keep those values aligned with `MARA-MEINS`.
`CREATE_FOR_UNIT_PLANT_PAIRS` and `CREATE_FOR_UOM_PLANT_PAIRS` accept
the ordinary and priority unit-aware cross-plant results, preserve source
locations, write base quantities, and apply the caller delivery date.
`CREATE_FOR_UNIT_ATP_PAIRS` accepts the non-priority unit-aware ATP
result and delegates through the same confirmation and location-aware creation
path. `CREATE_FOR_ATP_BATCH_PAIRS` and
`CREATE_FOR_UOM_ATP_BATCH_PAIRS` validate the same date-scoped groups and reject
incomplete or mismatched confirmation before any order write. The ATP result
does not confirm the selected batch or location, and the local preview does not
reserve stock. Local tests use stock, UOM, ATP, and STO doubles.

Single- and cross-plant exact-batch methods accept
`iv_include_undated_batches` to exclude stock or projected receipts with no
expiry date when callers require expiry data. The default remains inclusive.
Exact-batch demand rows can set `require_known_expiry` to force exclusion or
`allow_undated_batches` to opt in when the shared setting is false; both flags
cannot be true. Cost-center batch and FEFO preview and reservation paths also
carry these row policies. The policy is echoed in allocation summaries and
batch splits. This is only as reliable as the expiry values supplied by the
repository or caller; ATP remains a plant-level comparison and does not
confirm batch expiry or assignment.

Priority ordering in cost-center FEFO and explicit-batch flows controls the
local allocation snapshot and reservation API call sequence. It does not lock
stock between preview and posting; concurrent SAP activity can change
availability, and the stock or reservation adapters must expose current
reservations for subsequent bulk calls to account for earlier commits. Local
tests verify ordering with doubles, not SAP's reservation visibility or
concurrency behavior.

`ALLOCATE_BY_BATCH`, `ALLOCATE_BY_EXPIRY`, `ALLOCATE_PLANTS_BY_EXPIRY`,
`ALLOCATE_PLANTS_FEFO_BY_DATE`, and `ALLOCATE_PLANTS_BY_BATCH` now fetch batch
status for all unique material/plant pairs through one bulk repository call.
Regression tests verify dispatch counts and existing allocation behavior with
doubles. The target SAP release still needs a query-plan check for large pair
sets and confirmation that bulk reservation subtraction matches the former
single-pair reads.

`ALLOCATE_COMPONENT_STOCK` now fetches location status, batch status, and open
reservations for all unique material/plant pairs through validated bulk calls;
protected safety stock is also fetched in bulk when enabled. Single-plant exact
batch and FEFO allocation, plus cross-plant exact-batch and dated and undated
FEFO allocation, use the same bulk safety-stock path. The MARD adapter batches
RESB reservations and MARC safety-stock rows in guarded queries, and the RESB
query retains the existing eligibility filters. Regression tests verify
multi-scope allocation results and dispatch counts using doubles. Confirm the
adapter's query plans and reservation visibility in the target SAP release.

`ALLOCATE_ACROSS_PLANTS`, `ALLOCATE_BY_STORAGE_LOCATION`, and dated location
allocation with projected receipts now use bulk location status and safety
stock reads for unique material/plant pairs. Their outputs are verified with
local doubles; the target SAP release still needs query-plan and reservation
visibility checks for these bulk location paths.


The MARD adapter's bulk safety-stock, reservation, and location-stock SQL now
has local Open SQL integration coverage through `cl_osql_test_environment`.
`scripts/run-unit.mjs` supplies the SQLite connection and minimal MARC, MARD,
and RESB schemas used by those cases. The cases cover duplicate scope mapping,
missing safety-stock rows, reservation eligibility and open quantities, and
location-level reservation netting. This closes the local SQL execution gap;
target SAP DDIC compatibility, query plans, and live reservation visibility
still require release-specific validation.


Bulk batch-stock adapter queries now also have local SQLite coverage for
MCHB quantities, exact and unassigned RESB deductions, MCHA plant-level expiry,
and MCH1 global fallback. The tests verify duplicate material/plant requests
receive the same batch snapshot, and that an MCHA expiry takes precedence over
a conflicting MCH1 value. SAP DDIC and release-specific query behavior remain
unverified.


SAP import scaffolding now includes `.abapgit.xml`, a `src/package.devc.xml`,
and class/interface metadata for all custom source objects. The configured
starting folder is `/src/`, which excludes tooling and local SAP stubs. Metadata
uses the documented classic abapGit object format, but it has not been imported
or activated in a target SAP system. Validate serializer compatibility, release
DDIC/BAPI availability, and activation in the target system before production.


The public `ZCL_STOCK_BATCH_ELIGIBILITY->IS_ELIGIBLE` method now validates both its required as-of date and each nonblank expiration date as Gregorian dates before comparing them. Impossible or malformed values raise `ZCX_INVALID_STOCK_REQUEST`; an initial expiry still means an undated batch and follows the existing include-undated/minimum-shelf-life rules. Local ABAP Unit cases cover impossible dates.


Projected-supply quantity calculators return zero when their source has a negative ordered, received, issued, or MRP-reduced counter. This fail-closed behavior prevents inconsistent source quantities from increasing local availability. The corresponding PO, confirmation, STO, PR, and production-order rows therefore contribute no projected supply; investigate negative counters in SAP source data. Local unit tests cover these cases, while live SAP data semantics still require target-release validation.

SAP documents cases where inconsistent EKES/EKET/EKBE records can produce negative quantities in planning views and recommends reviewing and correcting the affected source records. Check those records before treating a local projection as available supply ([SAP quantity inconsistency guide](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362168546.html)).


The replenishment-source repository now has local SQLite-backed tests for its
EINA/EINE purchasing info records, EORD/EKKO/EKPO agreements, MARC/EORD source
contexts, EQUK/EQUP quota arrangements, RDPR rounding levels, and TMQ2 usage
rules. The tests exposed an 18-character MATNR in the local EINA stub while the
repository request uses the 40-character MARA material type; the stub now uses
40 characters. Verify the actual EINA MATNR domain length and source/quota data
semantics in the target SAP release. Local SQLite execution does not establish
target DDIC compatibility or SAP query behavior.


During SQLite tests, the production-order item's AFPO/AFKO/AUFK query and the
AUFK/JEST status and AFRU/AFVC/AUFK confirmation queries returned no matches
with their alias-qualified joins in the local transpiler. Those methods now
read each table in batches and merge by order, routing, and operation keys.
The source-context MARC FAE query also needed unqualified field names to return
rows locally. These are local transpiler compatibility findings; verify the
corresponding Open SQL behavior and keys in the target SAP release.

The bulk projected-receipt PO, scheduling-agreement, and STO branches also
returned no rows with alias-qualified EKET/EKPO/EKKO/MARA joins in the local
transpiler. They now batch narrow EKPO, EKKO, MARA, and EKET reads and merge
by document/item/material/plant keys, with each item carrying its scope
deadline. The schedule-agreement supplying-plant check and STO header
category/supplying-plant/transport-document checks are applied during the
merge. SQLite tests cover the included fixtures and filters; verify Open SQL
behavior, DDIC compatibility, and query plans in the target SAP release.
The PR/STO PR branch also returned no rows with its alias-qualified
EBAN/MARA/MARM join. It now batches EBAN, MARA, and MARM reads and merges by
material and requisition unit. The local transpiler also emitted invalid SQL
for EBAN column-to-column comparisons and clears an `APPENDING` destination on
FAE reads; open-quantity and STO supplying-plant checks now run in the merge,
and standard/STO PR results are read into separate tables before combining.
SQLite tests cover both PR types, conversions, exclusions, and request
deadlines. Verify fields, filters, and query behavior in the target SAP
release.

The bulk production-order receipt branch returned no rows with its
AFPO/AFKO/AUFK/MARA join. It now batches AFPO items, AFKO order dates, AUFK
release/category status, and MARA base units, then merges by order and material
while applying each material/plant deadline. The `AFPO-KDAUF` blank check is
also applied after selection because its ten-character field does not compare
like a one-character blank in the local SQLite schema. Tests cover eligible
production/process orders, item and release filters, quantity conversion,
storage location/batch mapping, and per-request dates. Verify query behavior,
field semantics, and order-release status interpretation in the target SAP
release.

The date-availability outgoing-STO branch returned no rows with its
EKET/EKPO/EKKO join. It now batches eligible EKPO items, EKKO headers, and EKET
schedule lines, keyed by document/item and bounded by the latest date for each
material/source-plant scope. The receiving-plant versus supplying-plant check
runs during the merge. SQLite tests cover document and item categories,
special-procurement and deletion filters, plant matching, unit conversion, and
per-request cutoffs. Verify transfer lifecycle and field behavior in the target
SAP release.

The planned-order receipt branch returned no rows with its PLAF/MARA/MARM
join. It now batches PLAF proposals, MARA base units, and MARM conversions and
merges by material/order unit. Fixed versus unfixed inclusion, scenario,
special-stock, and sales-order assignment checks run in ABAP; this also avoids
local fixed-width blank comparisons for PLAF-PLSCN and PLAF-KDAUF. SQLite tests
cover both opt-in flags, item eligibility, storage location, unit conversion,
missing MARM conversion, and per-request dates. Verify MRP-area/plant behavior,
field semantics, and proposal eligibility in the target SAP release.

The confirmation-aware bulk PO reader had the same local zero-row result
with its EKES/EKPO/EKKO/MARA joins; it now batches eligible PO items,
headers, material units, EKET schedules, and EKES confirmations, then merges
by document/item. Tests exercise schedule and confirmation reduction rules,
confirmation/deletion flags, filters, conversions, and request horizons.

The date-availability bulk PO and incoming-STO schedule joins were not covered
and returned no receipt quantities in the direct date-horizon fixture. That
method now delegates those options to `GET_PROJECTED_RECEIPTS_BULK`, which
already batches schedule rows and conversions. A SQLite test checks standard
PO receipts and both STO quantity components across early and late request
dates. Outgoing-STO deductions remain on their source-plant-specific batch
path.

The date-availability production-order AFPO/AFKO/AUFK join also returned no
rows in a direct SQLite fixture. It now batches AFPO items by material/plant,
then AFKO dates and eligible AUFK release/category rows by order number. The
merge applies the latest scope deadline, includes production (`AUTYP = 10`) and
process orders (`AUTYP = 40`), and excludes make-to-order supply. The scalar
date method now delegates to this bulk implementation and preserves excluded
reservation keys. Tests check date horizons, conversion, both order categories,
make-to-order exclusion, and scalar/bulk parity. Verify the query and release-
status behavior against the target SAP release.

The scalar `GET_PROJECTED_RECEIPTS` PO/process-order fixture returned zero rows
through its EKET/EKPO/EKKO and AFPO/AFKO/AUFK joins. The scalar method now sends
one keyed request through `GET_PROJECTED_RECEIPTS_BULK`, copies the receipt
rows, and retains its documented sort order. A direct SQLite test checks PO
and process-order quantities, batch/location metadata, and make-to-order
exclusion. Existing bulk tests continue to cover the other source types and
unit conversions.

The scalar confirmation-aware `GET_PO_CONFIRMED_RECEIPTS` query returned no
rows in a direct SQLite fixture even though the bulk confirmed-PO reader
returned the expected schedule and confirmation rows. The scalar method now
adapts one request to `GET_PO_CONFIRMED_RECEIPTS_BULK`. Direct assertions cover
the schedule remainder, confirmation remainder, source metadata, and result
count; bulk tests continue to exercise reduction flags and request horizons.

The bulk sales-order delivery reader scanned its full VBUP status table for
each VBAP item and rescanned VBEP schedules for every item. Status rows now use
a hashed document/item key, and schedule rows are kept sorted by
document/item/requested-date/schedule-line so matching item loops use the
leading key. Existing SQLite coverage verifies ordering, status presence,
schedule fallback, and empty input; target Open SQL and runtime plans still
need SAP verification for large document sets.

The stock-transfer inquiry bulk reader previously rescanned all fetched MARD
locations for each material/plant request. It now aggregates full-plant and
exact-location quantities once into hashed keys. Location and batch detail
buffers are sorted by material/plant scope so each request scans its matching
range in key order. SQLite coverage verifies duplicate requests, output order,
and quantities; confirm Open SQL behavior and runtime plans for large request
sets in the target SAP system.

The replenishment outline-agreement reader nested source-list, header, item,
and request scans over standard tables. It now de-duplicates material/plant/
purchasing-org request scopes, indexes EORD rows by material/plant, and looks
up EKKO and EKPO by document/item keys. Direct SQLite coverage checks multiple
purchasing organizations and repeated scopes; confirm Open SQL behavior and
runtime plans for large request sets in the target SAP system.

The replenishment info-record candidate reader rescanned all EINA rows for
each material and all EINE rows for each info-record/purchasing-org pair.
EINA rows are now sorted by material and EINE rows by info record, org, and
plant, allowing those loops to use keyed ranges. SQLite coverage checks
plant-specific and plant-independent rows across purchasing organizations;
confirm Open SQL behavior and runtime plans for large request sets in SAP.

Quota-arrangement assembly rescanned all fetched EQUP rows for every EQUK
header. The item buffer now uses a sorted quota-number key so each header walks
only its item range. SQLite coverage verifies multiple quota headers and item
fields; confirm Open SQL behavior and runtime plans for large quota sets in the
target SAP system.

Source-context enrichment previously searched the full MARC policy result for
every EORD row. It now builds one hashed material/plant policy lookup and
preserves the standard context result table. SQLite coverage maps two policy
scopes onto source-list rows; confirm Open SQL behavior and runtime plans for
large material/plant sets in the target SAP system.

Production-order status assembly previously scanned the full active JEST
buffer for each AUFK order header. Active status rows now use a sorted object-
number key, while the returned statuses keep their existing order sort. SQLite
coverage includes multiple statuses and inactive-row exclusion; confirm Open
SQL behavior and runtime plans for large order sets in SAP.

Production-order operation assembly rescanned the AFKO routing buffer for
every AFVC operation. AFKO rows now use a sorted AUFPL key so each operation
visits its routing range. SQLite coverage checks operation ordering and
suboperations; confirm Open SQL behavior and runtime plans for large order
sets in the target SAP system.

Project-stock methods repeatedly searched PRPS mappings from WBS element to
PSPNR and back for each stock or reservation row. The repository now keeps a
hashed element index and builds a hashed PSPNR index for WBS-wide reads.
SQLite coverage spans multiple WBS assignments; confirm Open SQL behavior and
runtime plans for large project sets in SAP.

Bulk date availability previously rescanned the full MARD, reservation,
outgoing-STO, and production-receipt buffers for every request. Those buffers
now have secondary sorted material/plant keys and each request reads its
matching ranges; request-date and excluded-reservation behavior are unchanged.
The local suite passes, but target SAP runtime plans for large request batches
remain to be confirmed.

Bulk safety-stock output rows used to linearly search the fetched MARC values
for each request. The query result now uses a hashed material/plant key;
duplicate requests still receive the same safety-stock value and missing MARC
rows remain zero. Local SQLite coverage verifies both cases. Confirm target
SAP read behavior and runtime for large request sets.

Bulk open-stock reservations scanned all fetched RESB rows for every requested
material/plant. Sales-order reservation validation also rescanned all fetched
reservation items for each candidate reservation. These merges now use sorted
secondary keys for material/plant and reservation number, respectively. The
local suite passes; confirm runtime plans for large scopes in target SAP.

Bulk projected-receipt assembly previously rescanned the full collected receipt
buffer for every request. It now reads a secondary sorted material/plant range,
applies each request's cutoff date, and retains the existing result order and
sort. Confirm runtime plans for large batches in target SAP.

The local transpiler reordered equal-scope rows when confirmed-PO receipt
assembly iterated a secondary material/plant key, moving a confirmation ahead
of an earlier-added schedule row. The bulk path now indexes material/plant and
original row number, then reads the standard receipt table by those positions.
This keeps schedule/confirmation order explicit. Single-request calls skip the
index. Keep the row number in any future scope index where output order matters.

Cost-center bulk validation previously rescanned all returned reservations for
each requested center. Multi-center calls now use a sorted center/row-position
index, preserving reservation order within each center. Local tests cover
out-of-request-order reader results; target runtime for large center batches
still needs SAP verification.

BAPI sales-order mapping previously rescanned the full delivery result for each
sales-order item and the full BAPI item/header tables for each document. It now
uses a secondary delivery index keyed by document, item, requested date, and
schedule line, a hashed header lookup, and a sorted item-position index that
preserves BAPI row order. The delivery-repository interface documents its row
order; injected implementations must match it. The full local suite passes,
though it does not call `BAPISDORDER_GETDETAILEDLIST` through this mapping.
Verify representative header/item results and schedule ordering in SAP.


Sales-order reservation aggregation now has direct SQLite coverage for its
`RESB` query, grouped by document/item/schedule/date/material/plant and netted
as `BDMNG - ENMNG`. The tests verify that fully withdrawn, deleted, final-issue,
non-231, and special-stock rows are excluded. SQLite does not verify target SAP
authorization or database behavior, and it cannot validate the BAPI-populated
schedule/date keys or the service's fallback when those keys do not match.


The sales-order reservation finder now has direct SQLite coverage for both
order-wide and item-scoped RESB queries. It checks that order-wide discovery
accepts a reservation spanning items on one order, while item-scoped discovery
requires every non-deleted line to match the requested order item. Mixed owners,
movement types, and special stock are rejected; closed, deleted, and final-issue
rows do not seed candidates. This does not verify SAP authorization, deletion
eligibility after use, or target database query plans.


The scalar and bulk plant-status aggregates now run in SQLite-backed coverage.
The direct unrestricted-stock read is also covered, including the zero clamp
when reservations exceed stock. The tests verify MARD category totals, net
active unrestricted reservation withdrawals, ignore deleted/final-issue/special-
stock rows, and subtract static MARC safety stock. This local schema does not
model target ATP configuration or production database behavior.


Bulk plant-status aggregation is now exercised alongside the scalar status reader.
The local test checks shared material/plant totals, duplicate and missing request
scopes, and caller-order result preservation. SQLite still does not model SAP ATP
configuration or validate live stock values.


Scalar storage-location stock and category-status reads now have direct SQLite
coverage for their MARD/RESB grouped queries. Tests cover per-location
reservations, unscoped reservation distribution, and lifecycle/special-stock
filters. Target SAP query behavior and live stock values remain unverified.

The new test exposed and fixed a scalar mapping defect: `GET_STOCK_BY_LOCATION`
selected `LGORT` into `CORRESPONDING FIELDS` targets named `storage_location`,
so both grouped MARD and RESB location keys were lost and the calculator
returned no rows. Both selects now alias `LGORT AS storage_location`; SQLite
coverage verifies two locations survive and receive the expected deductions.


The scalar `GET_OPEN_STOCK_RESERVATIONS` query now runs directly in SQLite
coverage alongside the bulk reader. The test checks row identity, date, location,
batch, withdrawn quantity, active-row filters, and missing-material results.
This does not validate live RESB authorization or SAP query behavior.


Scalar batch-status and available-batch stock reads now run directly in SQLite
coverage alongside the bulk batch-status path. The tests verify exact
location/batch deductions, unscoped reservation distribution, expiry precedence,
RESB lifecycle filters, zero-available status rows, and omission of zero
balances from the scalar stock wrapper. The new case exposed a mapping defect:
the scalar RESB aggregate
selected `LGORT` and `CHARG` into `CORRESPONDING FIELDS` targets named
`storage_location` and `batch`, so scoped reservation keys were lost. Both
columns are now aliased to the target field names. Target SAP SQL behavior
remains unverified.

Input integrity checks that reconcile allocation, shortfall, and requested
quantities now compare in `decfloat34` for production-order ATP release,
cost-center reservation reads, sales-order FEFO reservations, and
goods-movement transfers. Packed-field addition could overflow before an
invalid mismatch was rejected; these paths now reject it before invoking
a release, reservation, or movement API.

WBS reservation coverage groups project stock, converted reservations, and
available stock for each material, plant, and WBS element. These aggregates
now use `decfloat34` internally and check the `MSPR-PRLAB` result range;
unrepresentable totals raise `zcx_invalid_stock_request`. Alternative-unit conversions in coverage and available-stock reads also
reject values outside the result field or values that round a nonzero
quantity to zero.

Sales-order ATP preview grouped multiple item demands into daily and cumulative MARD-LABST quantities using packed arithmetic. Several valid maximum-sized items could overflow before the ATP check, causing an uncontrolled conversion error. Single-order and multi-order previews now accumulate in `decfloat34`, check the MARD-LABST range, and raise `zcx_invalid_stock_request` before the SAP availability API is called. ABAP Unit regressions cover same-date demand overflow in both previews. Live SAP quantity conversion and ATP behavior still require target-system validation.

Dated cross-plant allocation added confirmed PO quantities to per-plant availability and then combined source-plant balances in the packed MARD-LABST field. Large but valid values could overflow in either sum. Both additions now use checked `decfloat34` accumulation and reject totals outside the field range before returning an allocation. Local regressions cover receipt-plus-stock overflow and overflow across two source plants; live SAP quantity and receipt semantics still require target-system validation.

Single-request and bulk dated allocation also added confirmed PO receipts directly to packed MARD-LABST availability. A stock balance near the field maximum plus a small confirmed receipt could overflow. Both paths now use checked high-precision addition and fail with `zcx_invalid_stock_request` when the result is not representable. Local ABAP Unit cases cover each entry point; target SAP quantity behavior remains to be validated.

Bulk sales-order reservation reads summed individual open RESB rows with the same order item, schedule line, and requirement date into one packed `RESB-BDMNG` result. Valid multiple reservations could exceed the field range before consumers could net them. The repository now returns each positive open row separately, matching the location and batch reservation readers; downstream consumers process rows individually. A local SQLite regression covers two maximum open rows. Live SAP SELECT behavior still requires target-system validation.

Non-dated cross-plant allocation accumulated available stock across locations and source plants in packed MARD-LABST fields. It also added projected receipts into both location balances and demand totals. Large valid balances could overflow before a preview completed. Each addition now checks the MARD-LABST range through high-precision arithmetic and rejects unrepresentable totals. Local regressions cover multiple maximum source balances and a maximum balance plus a projected receipt.

Cross-plant exact-batch and standard/date-first FEFO previews also added
projected receipts, eligible balances, and source allocation totals directly in
packed quantity fields. These sums now use checked `DECFLOAT34` arithmetic and
raise `zcx_invalid_stock_request` when they exceed `MARD-LABST` range.

Date-first single-plant and cross-plant allocators also track quantities already
assigned across requirements. Those cumulative packed counters now use checked
high-precision addition and reject totals outside `MARD-LABST` range before
they can overflow during a later availability calculation.
Request-specific storage-location scopes now apply to base, priority, and
per-request-date WBS FEFO and batchless location previews, with matching ATP
adapters. Priority and date-first wrappers translate caller request IDs to
their internal allocation IDs, then return the original scope rows. The
corresponding reservation flows reuse that translated scope on the fresh stock
read before posting. Local regressions verify scoped splits, early rejection of
unknown or duplicate rows, and the posted reservation location. These checks
exercise the local service contract and do not validate live SAP stock or
reservation behavior.
Project WBS transfer previews now accept the same per-request storage-location
scopes as allocation previews. FEFO and batchless location transfers, including
priority/date-first and ATP adapters, constrain source stock before allocating
and echo the caller-facing scope rows. The source and destination WBS
assignments remain attached to the transfer result. Local regressions verify
scoped source splits across each variant and rejection before reads for an
unknown request scope; live SAP stock and movement behavior remain outside the
local test environment.

WBS goods-movement transfer wrappers now carry request-specific storage-location
scopes through their initial allocation and fresh-stock recheck. Each wrapper
validates caller request IDs and duplicate request/location pairs, remaps scope
rows through internal preview IDs, restores caller-facing rows in its result,
and only posts the transfer when the source allocation still matches. Local
regressions cover FEFO, priority/date-first, and batchless location posting;
live SAP movement behavior remains outside the local test environment.

Request-specific storage-location scopes now continue through WBS goods-issue
posting wrappers as well as their previews and transfer counterparts. The six
FEFO and batchless location issue variants validate and remap caller scopes,
reuse the mapped rows for the fresh stock check, and restore the caller IDs in
the returned preview. Local regressions cover each posting variant and confirm
unknown scopes fail before stock reads; live SAP stock and movement behavior
remain outside the local test environment.

The base unrestricted-stock location allocator now supports per-request storage
location scopes. Its UOM and ATP adapters preserve those scopes through internal
request IDs, enforce the intersection with the shared allowlist, and return the
caller-facing rows. Invalid and duplicate scopes fail before stock reads; the
unit-aware path also rejects them before conversion reads. These local checks do
not validate live SAP stock behavior.
Priority-based unrestricted-stock location previews now carry request-specific
storage-location scopes through the base and unit-aware allocators and grouped
ATP adapter. Scope validation runs before the stock read (and before UOM reads
in the unit-aware path); wrappers translate caller request IDs to internal
priority rows and return the original scope rows. Local tests cover scoped
priority splits, ATP forwarding, and early rejection of unknown or duplicate
rows. Live SAP stock and ATP behavior remain unverified.
Date-first unrestricted-stock location allocation now accepts request-specific
storage-location scopes in its base, UOM, and ATP forms. The scope filters
existing stock and projected receipts alike, including available-quantity
checks for full-quantity demands. The UOM form rejects unknown and
preferred-location mismatches before conversion reads; local tests cover all
four entry points and a projected receipt outside the request scope. Target SAP
receipt and stock behavior remains unverified.
Exact-batch unrestricted-stock previews now accept request-specific
storage-location scopes across base, unit-aware, priority, and ATP forms. The
scope filters on-hand batch balances and projected batch receipts within the
requested batch while intersecting with the shared location allowlist. Priority
wrappers map caller IDs through internal rows and restore the original scope
rows. Local tests cover all six entry points, a receipt outside the allowed
scope, and invalid scopes before stock or UOM reads. Live SAP batch and receipt
behavior remains unverified.

Unrestricted-stock FEFO allocation now accepts request-specific storage-location
scopes across base, unit-aware, priority, and ATP variants. Scopes filter both
on-hand FEFO balances and projected batch receipts while retaining expiry
ordering among eligible stock. Unit and priority adapters preserve caller rows
through internal demand IDs. Blank, unknown, duplicate, and preferred-location
mismatches fail before stock or UOM reads. Local regressions cover all six
entry points and an out-of-scope projected receipt; live SAP stock and ATP
behavior remain unverified.

Quality-stock FEFO allocation now accepts request-specific storage-location
scopes in base, unit-aware, priority, and ATP variants. The scope filters
quality-inspection balances and projected quality receipts. Unit and priority
adapters remap caller IDs as needed and return the original scope rows. Blank,
unknown, duplicate, and preferred-location mismatches fail before stock or UOM
reads. Local regressions cover all six entry points and an out-of-scope
projected receipt; live SAP quality-stock and ATP behavior remain unverified.

Quality FEFO release and send wrappers now carry request-specific location
scopes into the fresh stock allocation immediately before movement posting.
Empty-demand requests reject nonempty allocation rows and embedded location
scopes, as well as shared location priorities, request-specific priorities,
shared allowlists, and request-specific location scopes; unknown, duplicate, and
preferred-outside-scope rows fail before stock or UOM reads. Local regressions
cover quality release, unrestricted-stock send, priority variants, and invalid
scopes without a posting call. Live SAP movement behavior remains unverified.

Cost-center FEFO previews and reservations now accept per-request storage-location
scopes. Scopes intersect the shared allowlist, flow through date-first wrappers,
and are returned with preview and reservation items. Invalid and duplicate rows
are rejected before stock reads or unit conversion; non-FEFO reservation modes
reject supplied FEFO scopes. Local tests cover filtering, scope echoes, date
forwarding, and duplicate rejection. Live SAP reservation behavior remains
unverified.

Cost-center FEFO goods issues now preserve each preview's request-location scope
and reject duplicate, blank, mismatched, or out-of-scope rows before creating a
material document. Local regressions cover an excluded split and duplicate scope
rows without an API write. Live SAP goods-movement behavior remains unverified.

Cost-center location-only, exact-batch, and FEFO previews and reservations now
share request-specific storage-location scopes. The unit-aware allocators filter
stock before conversion, reservations preserve scopes through atomic/bulk and
date-first paths, and cost-center issue validators reject out-of-scope splits.
Local regressions cover all three allocation modes and posting checks. Live SAP
stock and movement behavior remains unverified.

WBS location issue now preserves a per-demand full-quantity rule through base,
priority, and date-first posting snapshots. A strict short row produces no
location splits and does not consume stock, while partial rows may still post
when the shared option allows it. The recheck compares effective policy in the
allocation summary as well as quantities and splits. These reads remain
snapshots and do not lock project stock; target SAP movement behavior remains
unverified.

WBS location reservations use the same per-demand full-quantity rule through
base, priority, and date-first flows. Their fresh snapshots compare allocation
summaries in addition to positive reservation splits, so an availability
change on a strict zero-split row prevents reservation creation. These reads
remain snapshots and do not lock project stock; target SAP reservation
behavior remains unverified.

WBS FEFO reservations now retain each demand's full-quantity rule through the
base, priority, and date-first preview/recheck paths. Strict short rows leave
stock for partial rows, and the fresh snapshot comparison includes full
allocation summaries as well as batch splits. This catches changed availability
for strict rows that had no positive split; project-stock reads remain snapshots
and do not lock stock. Target SAP reservation behavior remains unverified.

The direct WBS batch and location preview reservation adapters now validate
summary quantity identities and per-row `require_full_quantity`, rejecting
malformed summaries or partial strict rows before any reservation API call,
including when global partial reservation is enabled. Split totals and grouped
reservation items accumulate in high precision and reject quantities above the
`MARD-LABST` range before conversion or writes. They validate the supplied
preview and splits but do not re-read or lock stock; live SAP reservation
behavior remains unverified.

Allocation-backed goods-movement adapters also receive caller-provided split
rows. Summing individually representable split quantities in a bounded SAP
quantity field could overflow before the validator noticed the split total did
not match its preview summary. These totals now use `DECFLOAT34`, so malformed
overfull inputs are rejected as allocation mismatches before the movement API
call. The fields sent to SAP remain bounded by their existing quantity types.

Dated location and FEFO ATP transfer snapshots also group caller-supplied plant,
location, and batch rows for cross-checks. Their aggregate totals now use
`DECFLOAT34` so forged overfull groups fail as validation mismatches rather
than arithmetic overflow; the SAP movement fields remain bounded quantities.
One-step and two-step plant transfers apply the same high-precision accumulation
to caller-provided splits before checking them against the requested allocation.

Stock-transfer-order creation revalidates caller-provided demand, source-plant,
batch, location, and ATP totals. These internal sums now use `DECFLOAT34`; an
overfull group is rejected against the bounded preview/ATP quantity before any
purchase-order call.

WBS FEFO batch receipts and batchless location receipts are caller-resolved
planning inputs. The project-stock repository reads posted `MSPR` stock, so
incoming project supply is not inferred from purchasing or production
documents. Receipt previews can inform planning and ATP checks, but reservation
and goods-issue methods still require a fresh posted-stock snapshot; target SAP
integration must supply and reconcile the projected receipt data.

Batchless WBS transfer previews now accept the same caller-resolved projected
location receipts as location allocation previews. Each row is matched against
the source WBS, material, and plant; the shared as-of date and any demand or
required date gate receipt availability. Priority, date-first, and ATP transfer
adapters preserve the rows. Goods-movement posting still rechecks posted
project stock without forecasts, and live SAP integration remains unverified.

WBS FEFO and batchless location splits now echo `available_from_date`, keeping
caller-resolved future supply distinguishable from posted stock even when both
feed the same preview. For posted balances the field is initial; projected
splits carry their receipt date. This is planning metadata and does not change
the movement or reservation inputs.

Generic exact-batch, standard FEFO, and quality FEFO results previously used
projected receipts for date-gated allocation but omitted the source date from
the returned batch allocation. The shared batch row now reports
`available_from_date`, and unit-aware stock, quality, cost-center, and WBS
split adapters preserve it. Posted stock leaves the field initial; no
SAP receipt document is inferred by the allocator. Single-plant exact-batch,
standard FEFO, and quality FEFO receipts can carry caller-supplied source type,
document, item, source plant, and schedule line. Cross-plant exact-batch and
standard FEFO now preserve the same identity; their splits use
`receipt_source_plant` to distinguish the receipt origin from the supplying
stock plant. These fields participate in balance merging and are echoed in
splits; posted stock leaves them initial. Component-scoped allocation keeps
projected batch and location balances separate by receipt date and identity,
then returns those fields in per-demand `batch_allocations` and
`location_allocations`. Posted balances leave source date and identity initial.

Cross-plant FEFO previously merged posted stock and every due receipt with the
same batch and location into one balance, so a split could not identify which
receipt supplied its quantity. FEFO balances now stay separate by
`available_from_date`, and the base, priority, date-first, unit-aware, and ATP
results preserve that date. Exact-batch cross-plant allocation had the same
output gap; its balance key now includes the availability date, and its base,
dated, priority, unit-aware, and ATP location splits report the source date.

Date-first unrestricted-location allocation previously merged projected
receipts into each location's posted balance, hiding which receipt date
supplied a split. Its shared balance is now keyed by material, plant, location,
and availability date. Location splits report initial dates for posted stock
and receipt dates for projected supply; the unit-aware and dated ATP adapters
preserve that metadata. A location may therefore appear more than once in the
split output, with each row's quantities limited to its date-specific balance.
Callers may also provide optional source identity fields; matching fields are
echoed into splits and remain separate balance buckets. If those fields are
omitted, the date alone does not identify an individual receipt document.

Cross-plant location allocation also merged caller-resolved receipts into the
posted source-location balance, obscuring the supply date. Its allocation
balance now keeps posted stock and receipt dates separate, and location splits
expose `available_from_date` through base, priority, date-first, unit-aware, and
ATP results. This field reports the date bucket used for the split; it does not
identify individual receipt documents unless the caller supplies optional
source metadata. When posted stock and receipts from different dates or with
different source identities contribute at one location, the output contains a
row per balance bucket and reports the quantities for that bucket.
Generic stock ATP result rows now expose `is_fully_confirmed` beside the
confirmed and unconfirmed quantities, including per-demand dated results. The
status compares confirmed quantity
with the full requested or cumulative quantity; ATP checks marked not relevant
remain false because their confirmation quantities are zero. Sales-order ATP
checks expose the same status, and reservation gates use that returned value.
Cost-center preview and reservation rows now expose `is_fully_confirmed`
with their ATP quantities across single-demand, shared, dated, location, batch,
FEFO, atomic, and independent bulk flows. The flag compares confirmed base
quantity with the full cumulative requirement; a not-relevant ATP result stays
false. Reservation gates consume the same status returned to callers.
Production component ATP previews now expose `is_fully_confirmed` per
component alongside the cumulative group quantities. The flag reflects the
incremental confirmed quantity assigned to that component and is false when
ATP checking is disabled or the group check is not relevant. Group summaries
retain their existing `is_split_fully_confirmed` status.


Cross-plant stock-transfer creation summaries now report `is_committed` when
at least one contained order committed. This preserves the distinction between
failed aggregate success and partial non-atomic persistence, while simulations
and failed atomic groups remain uncommitted. Lint and transpilation passed;
ABAP Unit was not run. Live SAP commit behavior remains unverified.


STO pair deletion and delivery-completion summaries now expose aggregate
`is_deleted` and `is_completed` flags. A successful non-atomic child keeps the
summary true if a later child fails; atomic changes set the summary only after
the shared commit, and rollback or simulation leaves it false. Lint and
transpilation passed; ABAP Unit was not run. Target SAP update behavior
remains unverified.


Planned-order independent bulk create, delete, change, and convert summaries
now include `is_committed` when at least one row committed. Per-row results and
success/failure counts remain authoritative for which operations completed;
the aggregate distinguishes partial persistence from no commits. Lint and
transpilation passed; ABAP Unit was not run. Target SAP transaction behavior
remains unverified.


Production-order independent bulk create, operation/order release,
confirmation create/cancel, technical completion, change, close, and deletion
actions now expose a top-level `is_committed` summary. It becomes true when an
individual operation commit succeeds and remains true if a later row fails; the
ATP-gated bulk release forwards this status for its ready orders. Per-row
results remain authoritative. Lint and transpilation passed; ABAP Unit was not
run. Target SAP transaction behavior remains unverified.


Row-wise independent bulk goods-movement results now include top-level
`is_committed`, true when at least one non-test request committed and false when
all operations failed or the batch was simulated. This applies to cost-center,
sales-order, WBS, production-order issue/return/receipt, stock transfer, and PO
receipt/return batches. The row results remain authoritative. Lint and transpilation passed; ABAP
Unit was not run. Target SAP posting behavior remains unverified.


Project-reservation independent bulk deletion, item deletion, rescheduling,
quantity changes, final-issue marking/reset, and stock-key changes now expose
top-level `is_committed`. The flag is derived from committed child rows, so
partial persistence remains visible when a later row fails and test runs remain
uncommitted. Lint passed with 0 issues across 247 files and transpilation passed;
ABAP Unit was not run. Target SAP reservation-update behavior remains
unverified.


Reservation-issue bulk results now summarize whether any reservation group committed. The aggregate follows successful per-group posting and remains false for test runs or all-failed batches. Lint and transpilation passed; ABAP Unit was not run. Target SAP posting behavior remains unverified.


Production-component remaining bulk issue and return results now aggregate per-reservation commit status. The flag is true for any committed group and false for test runs or batches with no committed group. Lint and transpilation passed; ABAP Unit was not run. Target SAP goods-movement posting behavior remains unverified.


Sales-order reservation release bulk results now report whether any independently processed order committed. Earlier successful releases remain visible when later orders fail; simulations and no-candidate no-ops leave the aggregate false. Lint and transpilation passed; ABAP Unit was not run. Target SAP reservation deletion behavior remains unverified.


Purchase-requisition bulk create and delete summaries now expose top-level `is_committed` if any document commits. This preserves partial-persistence reporting while child rows continue to identify each request. Lint and transpilation passed; ABAP Unit was not run. Target SAP purchase-requisition BAPI behavior remains unverified.


Sales-order independent bulk create, change, rejection, and rejection-clear summaries now aggregate committed child orders. Per-order result rows remain the source of individual outcomes; the top-level flag preserves partial-persistence visibility. Lint and transpilation passed; ABAP Unit was not run. Target SAP sales-order change behavior remains unverified.


Purchase-order independent bulk write summaries now expose top-level `is_committed` if any purchase order committed. This covers create, item deletion, delivery completion, schedule changes, and quantity changes; per-order results remain authoritative. Lint and transpilation passed; ABAP Unit was not run. Target SAP purchase-order update behavior remains unverified.


Cost-center reservation bulk creation, item deletion, and document deletion now summarize child commits with top-level `is_committed`. Partial completion remains visible after later failures, while test runs and no-op rows stay uncommitted. Lint and transpilation passed; ABAP Unit was not run. Target SAP reservation BAPI behavior remains unverified.


Sales-order reservation delete results now expose `is_committed` after a successful shared transaction. The API result, single-order result, and bulk preview/write-compatible result carry the commit status; preview and test-run paths leave it false. Lint and transpilation passed; ABAP Unit was not run. Target SAP reservation deletion behavior remains unverified.


Multi-sales-order dated bulk reservation results now aggregate the per-order commit flags. Partial commits remain visible after a later order fails; simulations and successful no-op orders leave the aggregate false. Lint and transpilation passed; ABAP Unit was not run. Target SAP reservation BAPI behavior remains unverified.


Review found sales-order reservation delete wrappers could perform finder reads before validating `iv_test_run`; no-match requests could return without validating it. All public deletion entry points now reject malformed boolean values before reads or writes. Lint and transpilation passed; ABAP Unit was not run.


Review found cost-center reservation issue and reversal wrappers could read the reservation scope before the delegated movement method validated `iv_test_run`. All eight single, bulk, and unit-aware entry points now reject malformed flags before scope reads. Lint and transpilation passed; ABAP Unit was not run. Target SAP scope and posting behavior remains unverified.

Review found production-component bulk issue and return wrappers could read `RESB` components before the delegated goods-movement path validated `iv_test_run`. All four base-unit and unit-aware bulk entry points now reject malformed flags before repository reads. Lint and transpilation passed; ABAP Unit was not run. Target SAP component eligibility and movement behavior remain unverified.

Review found WBS transfer posting wrappers could take stock snapshots before the movement path rejected malformed `iv_test_run`, and single cost-center reservation could allocate stock before rejecting the same malformed flag. All six WBS FEFO/location transfer entry points and `reserve_for_cost_center` now validate first. Lint and transpilation passed; ABAP Unit was not run. SAP posting and reservation behavior remain unverified.

The repository PLAN validator could not run in this WSL 1 environment: `npm run validate:plan` exits before invoking its JavaScript with `WSL 1 is not supported` and `Could not determine Node.js install directory`. The local source guards, abaplint, and transpilation ran successfully.

On 2026-10-18, the direct `node` command was unavailable in WSL, and launching
the Windows Node runtime through `cmd.exe` failed before running
`npm run validate:plan`, `npm run lint`, or `npm run transpile`, with
`UtilBindVsockAnyPort:307: socket failed 1`. Focused Python source checks and
stub XML parsing are narrower evidence; rerun the PLAN validator, abaplint, and
transpilation from a working Node environment.

Review found single cost-center reservation accepted malformed `iv_check_atp`, allocation fallback, FEFO, safety-stock, and full-allocation flags inconsistently; some could silently behave as false or fail only after unit conversion. Both reserve and preview paths now validate the relevant options before stock or ATP reads, and shared preparation rejects malformed allocation flags before conversion and allocation. Lint and transpilation passed; ABAP Unit was not run.

Added sales-order item deletion through `BAPI_SALESORDER_CHANGE`, passing selected item numbers with `BAPISDITMX-UPDATEFLAG = D` and using the service transaction helpers for simulation, independent bulk commits, and atomic rollback. The field mapping follows the local SAP stub; exact item-deletion semantics and eligibility remain to be verified against the target SAP release. Lint reported zero issues across 247 files and transpilation updated 11 outputs; ABAP Unit was not run.

Empty-demand quality-stock and sales-order FEFO posting calls do not read stock
or post movements, but they now reject malformed boolean options before
returning success. This keeps flag validation consistent between no-op and
non-empty calls.

Valuation-type previews now accept per-request batch ranks alongside their
batch candidate filters. Ranks are validated before UOM conversion and echoed
in both base and unit-aware results; when candidates are supplied, every ranked
key must belong to that request's candidate list. Within each location and
posted/projected group, ranked batches precede unranked batches, and ties use
the batch key. This remains a local stock estimate, not SAP batch
determination; target-system allocation behavior is unverified.

Valuation-type previews can optionally protect static plant-level
`MARC-EISBE` safety stock. The quantity is withheld once per material/plant
across valuation balances in deterministic location, valuation-type, and batch
order; if current stock is insufficient, the remaining buffer is withheld from
projected receipts by receipt date. This does not model time-dependent safety
stock, ATP, or stock locking; verify the target plant policy and valuation
setup.

`PREVIEW_BY_VALTYPE_UOM_ATP` now attaches cumulative plant-level SAP ATP checks
to positive local allocations grouped by material, plant, base unit, and
effective date. ATP ignores the local valuation-type, batch, location, and
caller-projected-receipt assignments; its confirmation is diagnostic and does
not change local splits. Target checking-rule behavior and SAP release mapping
remain to verify.

Its `request_atp_checks` rows attribute each date group's cumulative response
to positive allocations in local allocation-sequence order. These incremental
quantities are derived from the grouped response and are not independent SAP
checks or reservations. Confirming the attribution against the target SAP
checking rule remains necessary, especially when dates or priorities change
which request consumes the cumulative confirmation first.

The request rows also convert allocated, confirmed, and unconfirmed values
back to each demand's requested unit using its material-unit ratio. These
source-unit quantities are a presentation of the base-unit ATP result; SAP
still checks only the material base unit.

Request ATP rows echo the local valuation type and priority for traceability.
Neither field is sent to or used by the plant-level SAP ATP check.

Valuation-type preview summaries now distinguish eligible projected receipt
quantity from projected receipt quantity actually consumed by a request, and
show current-stock consumption separately. This is a local accounting of
caller-provided receipts; it does not validate that a receipt will arrive or
that its source document remains open in SAP. Both preview results echo the
validated receipt inputs, including unused assumptions. UOM source quantities
preserve the allocated total by deriving current quantity as the residual
after the projected quantity is converted.

Production component previews and the direct scoped component allocator now
accept call-wide RESB reservation exclusions for local stock netting. Their
keys are validated before stock reads and merged with the selected components'
own reservations. Focused source-flow checks pass; ABAP Unit was not run in
this iteration. Verify live RESB selection and ATP behavior in
the target SAP release.

Project-stock availability reads and all FEFO, location, dated, priority,
transfer, and ATP preview variants now accept call-wide RESB exclusions.
Matching WBS reservation items are omitted from local stock deductions; SAP ATP
still follows its check rule. Source-flow and interface checks pass. Live WBS
reservation selection and ATP behavior remain to verify in the target system.


Reservation coverage exclusions affect only local open-reservation aggregation
and stock netting. Their behavior depends on the project's RESB/PRPS open-item
selection; verify reservation identity and open-quantity semantics in the target
SAP release.

Reservation coverage reports included RESB keys and per-item quantities in the
requested and base units, along with omitted keys. Included detail rows retain
the source required, withdrawn, and open quantities, material and entry units,
requirement date, storage location, and batch when quantities are converted.
These details reflect the local RESB/PRPS
selection and request cutoff; verify identity, open-quantity, unit conversion,
and cutoff semantics in the target SAP release.

Coverage also returns full source-unit RESB rows for excluded open items.
These rows explain which items were omitted without converting or deducting
them; target-system RESB field and unit semantics still require verification.

Open-reservation list exclusions only filter matching open RESB rows from the
returned local snapshot; they do not change SAP reservations. The bulk reader
applies call-wide keys during shared reads and per-request keys during result
mapping. Verify the target system's RESB selection and open-quantity semantics.

Reservation-item list exclusions filter only the returned full RESB item view,
including finalized or fully withdrawn rows when selected. They do not delete or
update reservation records in SAP. Verify item identity and the source view's
row coverage in the target release.

Batch expiry exposure classifies the local batch-status snapshot using MCHB
quantities and MCHA/MCH1 expiry resolution, with open RESB deductions applied
to available unrestricted stock. It is an inventory report, not SAP ATP or a
posting validation. Results include counts of returned batch/location/valuation
rows with positive stock, split into expired and upcoming exposure, plus
`undated_batch_row_count` for positive-stock batch rows with no resolved expiry
date. Base-unit category totals expose the unrestricted, available, QI, and
blocked undated quantities without adding them to dated detail or dated totals.
The separate `undated_batches` list returns all such rows in batch, location,
and valuation order; its UOM variant carries base and requested-unit
quantities. The result also identifies the first row by batch, location, and
valuation type, with its category balances in base and requested units.
It also reports the chronologically earliest recorded manufacture date among
positive-stock rows matching the exposure filters through
`oldest_manufacture_storage_loc`, `oldest_manufacture_batch`,
`oldest_manufacture_val_type`, `oldest_manufacturing_date`,
`oldest_manufacturing_date_src`, and signed `days_since_oldest_manufacture`.
Unknown manufacture dates are skipped; ties sort by batch, location, and
valuation type. UOM results echo the identity and date fields unchanged.
Positive-stock batch/location/valuation rows with valid expiry dates after the requested window have a
separate count and category
totals; they remain out of the dated detail and expired/upcoming totals. The
earliest after-window row is identified by storage location, batch, valuation,
expiry date, and days from the as-of date. Its identity follows expiry, batch,
location, and valuation order. `days_after_window_end` gives the gap beyond
the inclusive window end. These fields are initial when there is no
positive-stock row after the window. The in-window upcoming summary also
identifies its earliest positive-stock row and reports its four stock-category
quantities; the after-window row summary reports the same four categories.
`after_next_expiry_batch_count` counts all positive-stock rows sharing
`after_next_expiration_date`; `after_next_exp_unrestr_qty`,
`after_next_exp_available_qty`, `after_next_exp_quality_qty`, and
`after_next_exp_blocked_qty` aggregate their four categories. UOM results echo
the count and include base/requested totals; all are zero when no after-window
row has positive stock.
`after_next_exp_plant_count`, `after_next_exp_global_count`, and
`after_next_exp_other_count` split that cohort by resolved date source and
partition `after_next_expiry_batch_count`; UOM results echo them unchanged.
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
The
cumulative `within_7d_batch_row_count`, `within_30d_batch_row_count`, and
`within_90d_batch_row_count` values, each with four category totals, summarize
upcoming rows with positive stock expiring from `as_of_date` through 7, 30, and
90 calendar days later, respectively, inclusive and within the requested window.
The shorter horizons are subsets of the longer horizons. UOM results return
each amount in base and requested units and echo all three row counts.
Separate non-overlapping buckets report `within_7d_batch_row_count` for days
0–7, `from_8_to_30d_batch_row_count` for days 8–30,
`from_31_90d_batch_row_count` for days 31–90, and
`over_90d_batch_row_count` for day 91 onward, each with four category totals.
Together they partition upcoming positive-stock rows and their category totals;
counts and quantities reconcile to the upcoming totals. UOM results carry each
bucket in base and requested units and preserve the counts. The UOM result carries base and requested-unit values for both summaries.
These fields are initial or zero when no in-window upcoming row has positive stock.
The earliest expired row is also identified using expiration, batch, location,
and valuation order, with its date, days since expiry, and four stock-category
balances. The UOM result carries both base and requested-unit balances; these
summary fields are initial or zero when no expired row has positive stock.
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
The UTC `snapshot_timestamp` is captured after each grouped status read returns; it
marks read completion but does not guarantee a transactionally consistent
database snapshot. Requests sharing a read group share its timestamp. Call-wide
exclusions apply to all requests; per-request exclusions combine with them,
and requests with identical effective sets share
a repository read. Base and UOM results echo the effective keys. Batch rows
sort by status, expiration date, batch, storage location, and valuation type
so equal-expiry allocation order is deterministic. A nonblank `storage_location`
filters the stock exposure to that location; `filter_storage_location = abap_true`
selects blank locations. Nonblank `batch` filters by batch by default;
`filter_batch = abap_true` selects blank batches. A nonblank
`valuation_type` selects that exact valuation type;
`filter_valuation_type = abap_true` selects blank valuation types. The location,
batch, and valuation scopes intersect and are echoed in results. `expiry_source`
accepts `P` for plant-level dates, `G` for the global fallback, and `O` for
any other source value, including blank. Setting `filter_expiry_source =
abap_true` with blank `expiry_source` selects only rows without a resolved
source; nonblank values must be `P`, `G`, or `O`. This scope also intersects
with the location, batch, and valuation filters. Optional inclusive
`expiration_date_from` and `expiration_date_to` bounds filter resolved dates;
either may be supplied, and two must be ascending. A date bound omits undated
rows from undated results, counts, and totals without changing status relative
to `as_of_date` or the after-window test relative to `through_date`. Base and UOM
results echo the bounds. Set `filter_expiry_status = abap_true` with `expiry_status` `E` for dates before `as_of_date`, `U` for dates from `as_of_date` through `through_date` inclusive, or `A` for dates after `through_date`. The scope intersects with location, batch, valuation, source, and date bounds before dated counts and totals; active status filtering omits undated rows from their list, counts, and totals. Only `E`, `U`, and `A` are accepted, and the status value must be initial when its flag is disabled. Base and UOM results echo both fields. Allocation trace rows retain their independent scope. Set `filter_expiry_age_band = abap_true` with `expiry_age_band` `1` for 1–7 days since expiry, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. It returns only expired rows, composes with status, source, and date bounds before counts, totals, and paging, and omits upcoming, after-window, and undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. Set `filter_expiry_upcoming_band = abap_true` with `expiry_upcoming_band` `1` for 0–7 days from `as_of_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes the as-of date and only dates through the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. Set `filter_exp_after_window_band = abap_true` with `expiry_after_window_band` `1` for 1–7 days after `through_date`, `2` for 8–30 days, `3` for 31–90 days, or `4` for over 90 days. The selector includes only dates after the inclusive `through_date`; it composes with status, source, location, batch, valuation, and date bounds before counts, totals, and paging, and omits undated rows. Only `1`–`4` are accepted; the value must be initial when disabled, and base and UOM results echo both fields. Optional `filter_expiry_days_from` and `filter_expiry_days_to` with `expiry_days_from` and `expiry_days_to` set inclusive signed `expiration_date - as_of_date` bounds. Either bound may be used alone; expired values are negative, the as-of date is zero, future values are positive, and active bounds omit undated rows. Two active bounds must be ascending. These bounds compose before exposure counts, totals, and paging, and base and UOM results echo both flags and values. Optional inclusive `manufacturing_age_days_from` and `manufacturing_age_days_to` bounds, enabled by `filter_manufacturing_age_from` and `filter_manufacturing_age_to`, select rows by signed `days_since_manufacture` (`as_of_date - manufacturing_date`). Either bound may be used alone; future manufacture dates have negative ages and the as-of date has age zero. Active age bounds omit rows without a manufacture date, including expiry-undated detail rows. Two active bounds must be ascending. The bounds compose with other exposure filters before dated and undated summaries, counts, and paging; base and UOM results echo both flags and values.

Returned batch rows, expiry and source counts, and
category totals reflect the filters. The repository still reads material/plant
stock to net reservation demand across locations, then narrows returned stock
rows and totals.
Reservation summaries remain material/plant-wide. Stock exposure filters
do not narrow allocation trace rows; the independent reservation and pass
filters can narrow the details while summary quantities and counts remain full
scope. The
request scope is echoed for reconciliation. Each dated detail row
includes `days_to_expiration`, computed as expiration date minus as-of date:
negative is expired, zero expires on the as-of date, and positive is upcoming.
UOM detail rows echo the value in the nested base row. These keys adjust only
the local available estimate and do not change SAP reservations. Direct batch-status
bulk results also return the grouped read timestamp, and the UOM wrapper echoes
it unchanged.
Confirm expiry-date resolution, reservation matching, and stock-category
semantics in the target SAP release. The UOM
variant converts that snapshot through the material's maintained unit ratio;
verify the ratio and rounding precision against the target material master.
Each dated expiry row and the expired, upcoming, and after-window summaries
identify whether its date came from plant-level MCHA (`P`) or the global MCH1
fallback (`G`). An unresolved date has a blank marker; verify the source
precedence in the target SAP release. `plant_expiry_source_row_count`,
`global_expiry_source_row_count`, and `other_expiry_source_row_count` partition
dated positive-stock rows by source, including positive-stock dates after the
request window. UOM results echo the counts unchanged.
`plant_exp_unrestr_qty`, `plant_exp_avail_qty`, `plant_exp_quality_qty`, and
`plant_exp_blocked_qty` aggregate the four stock categories for plant-level
expiry dates; `global_exp_*` and `other_exp_*` provide the corresponding
fallback and other/blank totals. The totals cover the same dated positive-stock
rows as the source counts, including dates after the request window. UOM results
carry base and converted totals for each source/category pair.
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
The expiry summary's `open_reservation_row_count` reports eligible RESB rows
with positive remaining quantities after exclusions. It counts rows passed to
the local availability calculation and does not quantify batch-level
deductions. `excluded_open_resv_row_count` counts RESB rows whose remaining
quantity is positive and whose reservation/item keys match the effective
exclusions. `unmatched_open_resv_excl_count` counts effective keys
without a positive open RESB match, and `unmatched_excl_reservations` returns
those keys in reservation/item order; UOM results echo all three counts and
the list unchanged. `open_reservation_quantity` sums positive outstanding
quantities considered by the local calculator, while
`excluded_open_resv_quantity` sums positive outstanding quantities removed by
exclusions. `fully_allocated_resv_count`, `partially_allocated_resv_count`,
and `unallocated_resv_count` classify eligible open RESB rows by local
allocation outcome. Fully allocated rows have no residual; partial rows have
both a deduction and a residual; unallocated rows have no local deduction.
The counts sum to `open_reservation_row_count`; excluded rows are not included,
and UOM expiry results echo the counts. The three open-quantity totals, `fully_alloc_resv_open_qty`, `part_alloc_resv_open_qty`, and `unalloc_resv_open_qty`, partition eligible `open_reservation_quantity` by outcome using each row's entire open demand; excluded reservations are omitted. UOM expiry results provide base and requested-unit values for each total. `matched_allocation_quantity` and
sum deductions from the matching and fallback passes. Together with
`uncovered_open_resv_quantity`, they reconcile to eligible
`open_reservation_quantity`; excluded demand is outside this reconciliation.
UOM results return base and requested-unit fields for each pass total, letting
callers compare them without summing `allocation_details` rows.
`matched_allocation_row_count` and `fallback_allocation_row_count` count trace
rows by pass. Each row represents one positive deduction against one stock
row, so the counts do not represent distinct reservations; UOM results echo
them unchanged.
`uncovered_open_resv_quantity` reports eligible demand left after
the local calculator's matching and fallback passes. These are local
reservation diagnostics, not SAP-confirmed shortage values. UOM results return
all three quantities in base and requested units. `uncovered_open_resv_keys`
lists reservation/item keys with positive residuals after local allocation,
sorted by reservation and item; UOM results echo them unchanged.
`allocation_sequence` is one-based across positive eligible open reservations
and records calculator processing order: more specific selectors go first,
selector values break ties, and identical selector tuples retain caller input
order. Stock rows traverse by location, batch, valuation type, and expiry date;
equal stock keys retain input order. Trace and uncovered rows carry the
sequence, and UOM rows echo it. Result collections remain sorted by
reservation/item; sorting by `allocation_sequence` restores shared-stock
consumption order.
`uncovered_open_reservations` includes each key's positive residual quantity,
requirement date, storage location, batch, valuation type, required and
withdrawn source quantities, open quantity, and locally allocated, matched,
and fallback quantities. Required and withdrawn retain the RESB source values;
open equals required minus withdrawn. The matched quantity is
deducted in the selector-matching pass; fallback may widen location and batch
matching while retaining a specified valuation type. Each row reconciles open
quantity as matched plus fallback plus uncovered, and allocated as matched
plus fallback. Uncovered row totals reconcile to
`uncovered_open_resv_quantity`. UOM rows echo this reservation context and
include base and requested-unit values for open, allocated, matched, fallback,
and uncovered quantities. `uncovered_open_resv_row_count` counts all positive
residual rows and is carried unchanged through expiry and UOM results.
Uncovered detail rows support an independent keyset page of up to 500 rows,
ordered by reservation/item. The optional exclusive cursor uses both fields from
the previous page's final row. Total residual counts and allocation summaries
remain complete, while the detail rows and parallel key list contain the same
page. UOM results echo the page metadata and convert returned details. Each
continuation recalculates from current reservation data; pages do not retain a
shared snapshot. ABAP Unit covers sorted first and continuation pages, complete
unpaged output, full summary counts, base/UOM page alignment, and invalid cursor
and size inputs. Set `filter_uncovered_due_horizon = abap_true` with `uncovered_due_horizon` set to `O`, `T`, `1`, `2`, `3`, `4`, or `U` to select overdue, due-today, 1–7, 8–30, 31–90, over-90, or undated detail rows. The selector filters details before cursor and page selection; `total_uncovered_detail_count` counts all horizon-matching rows independent of the cursor, while `uncovered_open_resv_row_count` and quantity summaries stay full-scope. Invalid active values and nonblank inactive selectors are rejected, and UOM results echo both fields. Set `omit_uncovered_detail_rows = abap_true` to return no uncovered detail rows or parallel keys while retaining the filtered detail total and full-scope shortage summaries. The flag requires `maximum_uncovered_rows = 0` and no active uncovered cursor; UOM results echo it, and non-boolean values are rejected. Set `filter_uncovered_sequence = abap_true` with a positive `uncovered_sequence` to select one reservation's shortage row in shared-stock allocation order. It composes with the due-horizon filter and cursor before detail totals and paging. The disabled selector must be initial, and UOM results echo both fields. Optional inclusive `uncovered_required_date_from` and `uncovered_required_date_to` bounds select a caller-chosen required-date window. Either bound may be supplied; two bounds must be valid and ascending. When a bound is set, undated rows are omitted. The bounds compose with sequence, due-horizon, and cursor scopes before counts and paging, and UOM results echo both dates. Set `filter_uncovered_reservation = abap_true` with both `uncovered_reservation_number` and `uncovered_reservation_item` to select one shortage row. Both key fields are required when active and must be initial otherwise. This selector composes with sequence, due-horizon, date bounds, and cursor scopes before counts and paging; an active cursor must match the selected key, and UOM results echo all three selector fields. Set `filter_uncovered_outcome = abap_true` with `uncovered_outcome` set to `P` for rows with positive local allocated quantity (partially allocated), or `U` for rows with zero local allocated quantity (unallocated). The selector composes with reservation, sequence, due-horizon, date-window, and cursor scopes before filtered totals and paging; full-scope shortage summaries stay unchanged. Only `P` and `U` are valid active values, the disabled selector must be initial, and UOM results echo both fields.
`allocation_details` records positive deductions by reservation and actual
stock row, and includes the reservation's requested location, batch, and
valuation type beside the actual stock selectors. Each row also carries
`days_until_required`, calculated as `required_date - as_of_date`; negative is
overdue, zero is due on the as-of date, and positive is future-dated. An
initial required date leaves zero, and UOM rows echo the day count. `M` marks
selector-matching pass and `F` the fallback pass.
For reservations listed in the uncovered summary, detail quantities reconcile
to the locally allocated amount. Fully covered reservations appear in the
trace without an uncovered-summary row; UOM rows carry base and requested
quantities.

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
the page metadata and convert only the returned rows. The base result's `filtered_allocation_quantity` sums every row matching the active allocation-detail filters before cursor and page selection, even when detail rows are omitted. UOM results expose the base-unit `base_filtered_alloc_qty` and converted `source_filtered_alloc_qty`. `filtered_allocation_passes` adds a fixed two-row (`M`, `F`) breakdown for the same filter scope before cursor and page selection, retaining zero-count passes; its counts and quantities reconcile to the filtered total. UOM rows preserve pass order and counts with base and converted quantities. Each continuation reads
current reservation and stock data; pages do not retain a shared snapshot.
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
the selected bounds. Set `filter_allocation_val_type = abap_true` to select trace rows with `allocation_val_type`, including a blank value to select rows without a valuation type. The selector composes with reservation, pass, sequence, date-bucket, due-horizon, and required-date scopes before filtered totals and pagination; full allocation totals and reservation summaries stay material/plant-wide. The value must be initial when disabled, and UOM results echo both selector fields. Set `filter_allocation_location = abap_true` with `allocation_location` and `filter_allocation_batch = abap_true` with `allocation_batch` to narrow trace rows to those stock keys; either active filter can select a blank key. Both filters intersect with valuation type and the other trace scopes before filtered totals and paging. Their values must be initial when disabled, and UOM results echo both flags and values. Optional inclusive `allocation_expiry_date_from` and `allocation_expiry_date_to` bounds also restrict trace rows by the stock row's expiration date. Either bound may be supplied; two bounds must be valid and ascending. When either is set, rows without an expiry date are omitted. Expiry-date bounds compose with valuation type, stock keys, reservation, pass, and required-date scopes before counts and paging; UOM results echo both dates. Set `filter_allocation_expiry = abap_true` with `allocation_expiry_status` set to `E` for rows expiring before `as_of_date`, `U` for rows expiring from `as_of_date` through `through_date` inclusive, `A` for rows after `through_date`, or `D` for rows without an expiry date. The status filter composes with expiry-date bounds and other trace scopes before filtered totals and paging. Only these four active codes are accepted; the value must be initial when disabled, and UOM results echo both fields. Set `filter_allocation_expiry_band = abap_true` with `allocation_expiry_band` `1` for 0–7 days from `as_of_date`, `2` for 8–30, `3` for 31–90, or `4` for over 90. It selects dated upcoming rows only, including `as_of_date` and dates through the inclusive `through_date`; it composes with expiry status, date bounds, and other trace scopes before filtered totals and paging. UOM results echo both fields; invalid active codes and noninitial disabled values are rejected. Set `filter_allocation_after_band = abap_true` with `allocation_after_band` `1` for 1–7 days after `through_date`, `2` for 8–30, `3` for 31–90, or `4` for over 90. It selects only dated rows after the inclusive `through_date`; it composes with expiry status, date bounds, and other trace scopes before filtered totals and paging. UOM results echo both fields; invalid active codes and noninitial disabled values are rejected. Set `filter_allocation_age_band = abap_true` with `allocation_age_band` `1` for 1–7 days since expiry, `2` for 8–30, `3` for 31–90, or `4` for over 90. It selects only rows expiring before `as_of_date`; it composes with other trace scopes before filtered totals and paging. UOM results echo both fields; invalid active codes and noninitial disabled values are rejected. Set `filter_allocation_qty_from` with `allocation_qty_from` and `filter_allocation_qty_to` with `allocation_qty_to` independently to select rows by inclusive allocation-quantity bounds in base units. Active bounds may be zero but not negative; disabled bound values must be initial, and two active bounds must be ascending. Quantity bounds compose with the other trace scopes before filtered totals and paging; UOM requests forward them and results echo the base-unit values. Each batch expiry result also reports `allocation_expiry_statuses`, a fixed eight-row matrix keyed by expiry state (`E`, `U`, `A`, `D`) and allocation pass (`M`, `F`) in that order. Zero combinations remain present. The counts sum to matched plus fallback allocation row counts, and the quantities sum to matched plus fallback allocation quantity; this summary stays full-scope across trace filters and pages. UOM results preserve expiry-state/pass order and counts and include base and requested-unit quantities. Allocation detail rows expose `expiration_date_source`: `P` for the plant-level MCHA date, `G` for the global MCH1 fallback, or blank when no source was resolved; UOM details echo the marker. Set `filter_allocation_source = abap_true` and `allocation_expiry_source` to `P`, `G`, or blank to select that source. An active blank value selects blank markers; only `P`, `G`, and blank are valid, and the value must be initial when disabled. This filter composes with the other allocation scopes before filtered totals and paging. Each result also includes `allocation_expiry_sources`, a fixed six-row matrix in source/pass order: `P/M`, `P/F`, `G/M`, `G/F`, blank/M, blank/F. Its counts and quantities reconcile to the full matched plus fallback allocation totals and stay full-scope across trace filters and pages. UOM rows retain source/pass order and counts and provide base and requested-unit quantities. The `alloc_expiry_src_statuses` result adds a fixed 24-row cross-matrix ordered by source (`P`, `G`, blank), expiry status (`E`, `U`, `A`, `D`), and allocation pass (`M`, `F`). It partitions both existing matrices, keeps zero combinations, and reports counts plus quantities; UOM rows preserve this order and convert each quantity. Each allocation result also includes `alloc_due_src_bands`, a fixed 42-row matrix ordered by expiry-date source (`P`, `G`, blank), due horizon (`O` overdue, `T` today, `1` 1–7 days, `2` 8–30, `3` 31–90, `4` over 90, `U` undated), and allocation pass (`M`, `F`). It partitions the full allocation details by source and pass, retains zero combinations, and reports row counts and quantities; UOM results preserve the order and counts and convert each quantity. Allocation detail rows also report `days_to_expiration`, calculated as `expiration_date - as_of_date`: negative values are expired, zero is the as-of date, and positive values are upcoming or after-window. The value remains initial for undated rows and is echoed unchanged in UOM detail. Optional `filter_alloc_expiry_days_from` with `alloc_expiry_days_from` and `filter_alloc_expiry_days_to` with `alloc_expiry_days_to` apply inclusive signed day-delta bounds; either bound can be used alone, and two active bounds must be ascending. Negative values select expired rows, zero selects expirations on `as_of_date`, and positive values select upcoming or after-window rows. Active bounds omit undated rows, and UOM results echo the base-day values. Allocation detail rows also report `expiry_due_relation`: `B` when expiry precedes the required date, `S` on the same date, `A` after the required date, or `U` when either date is missing. `days_required_after_expiry` is the signed difference `required_date - expiration_date`; positive values show how many days demand follows expiry, negative values show expiry follows demand, and the value is initial when either date is missing. UOM detail rows echo both fields. Set `filter_allocation_expiry_due = abap_true` and `allocation_expiry_due` to `B`, `S`, `A`, or `U` to filter allocation details by this relation. The selector composes with the other allocation filters before filtered counts and pagination; UOM results echo both fields. Each allocation result also includes `expiry_due_relations`, a fixed eight-row summary ordered by relation (`B`, `S`, `A`, `U`) and allocation pass (`M`, `F`). It reports full-scope row counts and quantities across trace filters and pages, retains zero combinations, and reconciles to matched plus fallback totals; UOM results preserve the order and counts and convert each quantity. The active selector uses both inclusive signed bounds; zero is a valid endpoint, and `allocation_expiry_gap_from` must not exceed `allocation_expiry_gap_to`. Rows with either date missing are omitted. The filter composes before counts and pagination, and UOM results echo the flag and bounds. Allocation details also expose `expiry_due_gap_band`: `P1` through `P4` mean demand falls 1–7, 8–30, 31–90, or over 90 days after expiry; `Z` is the same day; `N1` through `N4` mean expiry falls 1–7, 8–30, 31–90, or over 90 days after demand; `U` means either date is missing. Each result includes `expiry_due_gap_bands`, a fixed 20-row matrix ordered by those ten bands and allocation pass (`M`, `F`), retaining empty combinations. Counts and quantities reconcile to matched plus fallback allocations across trace filters and pages. UOM details echo the band, and UOM summary rows preserve order and counts while converting quantities. Set `filter_allocation_gap_band = abap_true` with `allocation_gap_band` set to `P1`, `P2`, `P3`, `P4`, `Z`, `N1`, `N2`, `N3`, `N4`, or `U` to filter trace details by one named band. It composes with the signed range and other allocation scopes before counts and pagination. Invalid active codes and noninitial inactive values are rejected; UOM results echo both fields. Each allocation result also reports `max_expiry_due_gap`, the largest positive `required_date - expiration_date` difference across the full trace, with reservation, pass, actual stock keys, dates, and quantity. Equal gaps keep the first row in stable detail order; fields are initial when no allocation has a positive gap. UOM results echo the identity and convert the quantity.

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
results echo the bounds. Set `omit_resv_alloc_summary_rows = abap_true` to
omit summary-row payload while retaining the scoped total count. It requires
`maximum_resv_alloc_rows = 0` and no active summary cursor; UOM results echo
the flag. UOM pages include base and requested-unit amounts for every
quantity; each continuation recalculates against current
reservation and stock data.

`first_uncovered_required_date` with its reservation number and item identifies
the earliest known required date; undated rows are skipped and ties use
reservation/item order. The UOM result echoes the date and key.
`days_until_first_uncovered_req` reports calendar days from `as_of_date` to
that requirement date, with negative values indicating overdue demand.
Each expiry detail row also returns `days_until_required`; zero means due on
the as-of date only when `required_date` is set. Initial-date rows leave the
integer at zero, and the UOM detail echoes the day count.
Uncovered residuals are grouped into overdue, due-today, future-dated, and
undated buckets. The bucket quantities and counts reconcile to the uncovered
quantity and row-count summaries. UOM results carry base/requested amounts and
the same counts; undated rows remain separate from due-today rows.
All eligible open demand is also grouped into overdue, due-today, future-dated, and undated buckets, regardless of local allocation outcome. The four quantities reconcile to `open_reservation_quantity`, and the counts reconcile to `open_reservation_row_count`; demand already allocated remains included. UOM expiry results expose `base_overdue_open_resv_qty` / `src_overdue_open_resv_qty`, `base_due_today_open_resv_qty` / `src_due_today_open_resv_qty`, `base_future_open_resv_qty` / `src_future_open_resv_qty`, and `base_undated_open_resv_qty` / `src_undated_open_resv_qty`; counts are echoed unchanged.
`resv_alloc_open_demand_bands` cross-tabulates the same demand by allocation outcome (`F` fully allocated, `P` partial, `U` unallocated) and required-date bucket (`O` overdue, `T` due today, `F` future, `U` undated). It always returns all 12 combinations in outcome/date order, including zero rows; quantities and counts reconcile to `open_reservation_quantity` and `open_reservation_row_count`. UOM bands preserve the order and expose `base_open_quantity` and `source_open_quantity` with the row counts unchanged. `open_resv_due_horizon_bands` returns a fixed seven-row breakdown: `O` overdue, `T` due today, `1` due in 1–7 days, `2` due in 8–30 days, `3` due in 31–90 days, `4` due after 90 days, and `U` undated. These calendar-day ranges are non-overlapping and use `as_of_date`; counts and quantities sum to the eligible open reservation totals. UOM bands preserve order and counts and provide `base_open_quantity` and `source_open_quantity`. reservation summary pages can filter by the same codes with `filter_resv_alloc_due_horizon = abap_true` and `resv_alloc_due_horizon`; the scope composes with outcome, coarse date bucket, exact reservation, date range, and cursor filters before totals and pagination. unknown active codes and nonblank inactive selectors are rejected, and uom results echo the selector. set `filter_resv_alloc_sequence = abap_true` with a positive `resv_alloc_sequence` to select one summary by its shared-stock allocation processing position. This selector composes with the other summary filters before totals and pagination; a disabled selector must be initial, and UOM results echo both fields. The base result also identifies `next_open_resv_required_date`, the earliest eligible dated open reservation with a required date on or after `as_of_date`; overdue and undated rows are skipped. `next_open_resv_number` and `next_open_resv_item` identify it, and `days_until_next_open_resv_req` reports the calendar-day distance, including zero when due today. Equal-date rows break ties by reservation number and item. UOM results echo all four fields unchanged.

Expired-batch scrapping validates selected quantities against the available
unrestricted balances in a caller-supplied expiry snapshot, then posts movement
551 with the caller-supplied cost center. The exposure status is checked against
the snapshot's as-of date, while posting eligibility compares the expiration
date with the posting date; a batch marked upcoming at the snapshot can qualify
if it expires before posting. The snapshot does not lock stock or trigger a
second local stock read, so the available balance can change before posting;
SAP's goods-movement API must validate live stock, cost-center account
assignment, movement-reason configuration, and target-system movement settings.
The rechecked posting path compares selected batch expiry and stock-category
balances and effective reservation exclusion keys across caller-supplied
reports, which narrows but does not close that window; a balance may still
change after the second read. If the original report carries a read-completion
timestamp, the rechecked report must carry a strictly later timestamp. Reports
created before timestamp support keep the earlier comparison behavior. A later
timestamp confirms read order only; it does not prove transaction isolation or
lock stock through posting.

Quality-inspection batch scrapping uses the QI quantity from the local expiry
report and movement 553. It does not net a separate QI reservation balance;
target SAP inspection status, movement configuration, and live stock checks
remain authoritative. The unit-aware entry point converts selected quantities
to the material base unit before checking that reported QI quantity. Both entry
points use the same local snapshot and do not lock stock through posting.
The rechecked entry point compares the original and second QI report for the
selected batch, which narrows but does not close the stale-snapshot window. Its
unit-aware form converts selected quantities before that comparison.

Expired blocked-batch scrapping uses the raw blocked quantity in the local
expiry report and movement 555. It does not count unrestricted or QI balances
toward the blocked limit and does not net separate blocked-stock reservations.
The unit-aware method converts caller quantities to the material base unit
before checking that limit. A rechecked method compares the original and second
reports for selected batches, which narrows but does not close the stale
snapshot window; its unit-aware form converts before comparison. SAP remains
authoritative for blocked stock status, account assignment, and live balances
at posting time.

`SCRAP_EXPIRED_SCRAP` and `SCRAP_EXPIRED_SCRAP_UOM` dispatch using one
explicit stock-category value. Each delegates to the existing category-specific
expiry, balance, and base-unit validation before posting; invalid categories
raise before a goods-movement call. This keeps 551, 553, and 555 balance rules
separate while giving callers one category-selecting entry point.
`SCRAP_EXPIRED_CAT_RECHECKED` and `SCRAP_EXP_CAT_RECHECK_UOM` extend the same
dispatch to second-snapshot posting. Each path keeps the existing category
comparison and posts against the rechecked exposure; UOM values are converted
before comparison. Rechecking narrows the stale-snapshot window and does not
lock stock between the comparison and SAP posting.

`PREVIEW_EXPIRED_SCRAP` allocates the requested stock category in the
caller-supplied exposure and returns FEFO-ordered candidate splits. It does not
reserve stock, and a later posting still depends on SAP's live stock checks.
`PREVIEW_EXPIRED_SCRAP_UOM` converts the requested quantity to base units for
blocked, QI, and unrestricted categories, then echoes the source and base units;
returned selection quantities remain in base units for posting. Blocked stock
uses blocked quantity, QI uses raw quality-inspection quantity, and unrestricted
uses reservation-net available quantity. All categories share the same expiry,
tie-break, and no-reservation behavior.
`SCRAP_EXPIRED_FEFO` and `SCRAP_EXPIRED_FEFO_UOM` pass the preview splits into
the category-specific posting path. Full allocation is the default; partial
posting requires explicit opt-in. The returned result distinguishes a preview
that did not attempt posting from a posting result. A supplied second exposure
is checked before the post, while SAP remains authoritative after that check.
The bulk FEFO methods validate all keyed requests and UOM conversions before
the first post, then process each request and continue after a returned posting
error. Each successful non-test-run request commits
independently. This allows partial commits, which the result reports by request
and in its summary.
Optional positive `it_request_priorities` rows key ranks by exposure
`request_id`. Lower ranks post first, unranked requests follow, and ties retain
caller order. The service validates every priority row before the first post;
result rows remain in caller order and echo rank and ranked status. Therefore,
priority changes which request can commit before a later posting failure, while
the independent-commit behavior remains visible in the per-request results.
`iv_stop_on_failure = abap_true` stops subsequent calls after the first request
with no postable allocation, a returned goods-movement error, or a captured
request-level exception. Those result rows
are flagged with `is_skipped` and counted separately in `skipped_count`; commits
completed before the failure remain in place.
When priorities are supplied, the stop applies to ranked execution order while
result rows remain in caller order.
The bulk summary records `stopped_on_failure` when the option ends the loop,
even when no later rows remain to be marked skipped.
A `zcx_invalid_goods_movement` raised while handling one request is returned
as an error message on that row; the bulk response still reports any earlier
independent commits. The row sets `is_exception`; `is_attempted` remains false
because no goods-movement result was returned. The bulk summary exposes
`exception_count` as a subset of `failed_count`.

The atomic bulk FEFO methods use one SAP commit after all per-request goods
movements return successfully. They can compare each request's selected batch
status, expiry, and category balances against a supplied second snapshot before
the first movement call. A failed comparison prevents all posts. A failed
movement causes the executor to roll back the pending LUW; a failed final
commit triggers a shared rollback and the service clears provisional
material-document references. Snapshot comparison does not reserve stock, so
another process can change stock between preflight and posting. Atomic preflight
aggregates planned quantities by material, plant, location, batch, valuation
type, and stock category, using the smallest reported balance when snapshots
differ. Optional positive `it_request_priorities` ranks allocate shared
capacity in rank order, then unranked caller order; result rows preserve caller
order and echo the ranks. With partial allocation enabled, higher-ranked
requests receive shared snapshot capacity first. A request-level
`zcx_invalid_goods_movement` during deferred execution is captured on its
result row, leaves `is_attempted` false when no movement result was returned,
and rolls back earlier pending movements. The summary's
`exception_count` reports that row. Verify deferred BAPI commit behavior,
rollback scope, and 551/553/555 movement settings in the target SAP release.

Request fields, complete and unique call-wide and per-request reservation
exclusions, and priority rows are prevalidated before any UOM conversion or
repository read.
The call-wide and per-request lists are checked separately; overlapping keys
are combined for each request.

`SCRAP_FEFO_ATOMIC_FROM_STOCK` obtains both exposure snapshots in bulk and
rejects selected-batch changes before posting. The reads and comparison do not
hold a stock lock; quantities can still change between the second read and the
goods-movement calls. The lower reported balance also makes overlapping
request allocation conservative when the two reports differ. SAP remains
authoritative for live stock and LUW behavior.
`SCRAP_FEFO_BULK_FROM_STOCK` uses the same injected reader but commits each
successful request independently. Positive ranks determine posting order after
the exposure snapshots are read, while returned rows retain caller order.
Invalid priority rows are rejected before stock reads. Recheck narrows the
stale-snapshot window but does not lock stock; earlier successful requests
remain committed if a later goods-movement call fails.
The independent path pools matching batch capacity across requests using the
smallest balance across the first and recheck snapshots. It allocates in rank
order and consumes capacity only after a successful request, so a failed post
releases its allocation to later requests in the same call. SAP remains
authoritative for live stock after the snapshots are read.

The atomic and independently committed stock-backed FEFO posting paths now
validate both initial and rechecked exposures against the effective union of
call-wide and request-specific exclusions. Duplicate
location/batch/valuation rows are rejected before allocation or posting, so a
reader response cannot inflate the shared stock capacity. Timestamped initial
snapshots also require a strictly later recheck timestamp in both posting paths.

`PREVIEW_EXP_SCRAP_FROM_STOCK` verifies each returned exposure echoes the
request's effective reservation exclusions before pooling capacity. A reader
that returns a mismatched set is rejected. Duplicate location/batch/valuation
rows from an injected reader are also rejected before capacity pooling, so one
stock row cannot contribute more than once to a request's reported balance.
The shared validator also rejects incomplete exposure context, invalid expiry
dates or status/date combinations, negative available-unrestricted balances,
and available balances above nonnegative unrestricted stock before capacity
pooling. Upcoming rows after the inclusive exposure window are rejected too,
since after-window stock belongs only in the report's after-window summary.
The shared posting-date check now enforces the same bound for caller-supplied
exposures used by direct preview and category-specific posting methods. This
protects preview and posting results from malformed or out-of-window rows,
including responses from injected readers.
The method returns a posting-ready selection from a bulk expiry snapshot but
does not reserve stock. Inventory can change after the
preview and before a later posting; callers must use the guarded posting path
and treat SAP's live stock validation as authoritative. Its result rows retain
caller order and include a one-based `allocation_sequence` that records the
priority order used to consume shared capacity. Each request row also echoes
its UTC `snapshot_timestamp` and effective `excluded_reservations` from the
source exposure. Rows also echo request material, plant, as-of date,
through date, stock category, cost center, movement reason, and location
preference, including when no stock is selected. `shared_capacities` exposes
the pooled base-unit balance, aggregate selections, and remaining quantity by
material/plant/location/batch/valuation/category key. Its earliest and latest
UTC snapshot timestamps bound contributing reads when timestamps are present;
`untimestamped_exposure_count` reports rows without a timestamp. Different
exclusion groups can use separate reads, and these times do not imply one
transactionally consistent snapshot. It also reports the
number of contributing exposure rows and the request that supplied the
minimum balance; ties keep the first request in caller order.
`positive_exposure_count` counts contributing rows with positive stock in the
selected category. `minimum_exposure_count` counts rows tied at that minimum.
`allocation_row_count` counts positive request-preview selection rows consumed
from each key. `maximum_reported_quantity` and `capacity_spread_quantity` show
the exposure range. `maximum_reported_request_id` identifies a request that
supplied the maximum; ties keep the first request in caller order.
`maximum_exposure_count` counts rows tied at that maximum. The minimum remains
the capacity cap.


The goods-movement adapter previously marked a BAPI call successful when it
returned no error message even if no material-document key was present.
Production postings and cancellations now require both the returned
material-document number and fiscal year. Only create test-run simulation may
return without generated numbers. Local pure-method regressions cover missing
and partial keys, simulation, and a complete key.


The procurement and stock-transfer adapters previously allowed a live
`BAPI_PO_CREATE1` call to appear successful when its purchase-order number
was blank. Both adapters now require that returned key for live creates and
allow successful test-run simulations to omit the generated number.


Live cost-center and sales-order reservation results now require the
reservation number returned by `BAPI_RESERVATION_CREATE1`; test-run
simulation may omit generated numbers. Project-reservation validation now
adds the missing-key error only when no BAPI error has already failed the
request. SAP's BAPI guide says test runs do not assign internal numbers
([test-run behavior](https://help.sap.com/saphelp_scm70/helpdata/ru/df/0495dbbd6f11d1ad09080009b0fb56/content.htm)).


Production-confirmation creation now requires both the returned confirmation
number and counter. The adapter validates this before committing; a BAPI
error or missing key rolls back the single-create LUW. Atomic simulations
keep their generated keys provisional and roll back the group. SAP's
production-confirmation create operation returns the confirmation number
and counter ([SAP confirmation create](https://help.sap.com/docs/SAP_ERP/1a781c11dd4f41829c798db4d8ff3a41/04be184d8b3711da36bb000f20dac9ef.html)).


The scoped production-component stock preview undercounted group availability
for eligible batch stock in the transpiled unit run. The batch eligibility
condition was written as a positive boolean comparison; rewriting it to skip
ineligible batches before setting the match flag keeps the generated control
flow correct. The regression now confirms the full 8-unit scoped balance,
8-unit allocation, and 4-unit shortfall for the grouped request.


Production-component remaining-quantity issue and return batches now expose
`iv_stop_on_failure`. A failed reservation group can stop later independent
posts while preserving those groups as skipped result rows; earlier successful
commits remain committed. Component issue-document cancellation forwards the
same option to the generic material-document cancellation service. Bulk
component methods that submit one movement document for all selected lines
remain a single posting unit.


Purchase-order independent bulk write methods now accept `iv_stop_on_failure`
and report attempted, skipped, successful, and failed rows. The shared
summarizer reports partial commits; base-unit wrappers validate and convert
the complete batch before forwarding the option. Suggestion and requisition
source references remain available on skipped creation rows.

In the transpiled OSQL runtime, using structure-component host variables
directly in a joined SELECT produced malformed generated SQL and no matches.
The production confirmation window repository now copies its scope, date, and
cursor values into typed scalar locals before binding them. This keeps the
repository query testable under the current transpiler while remaining valid
ABAP SQL.


Production confirmation base-unit reads convert `AFRU-MEINH` through the
selected material's `MARA-MEINS` and `MARM-UMREZ`/`UMREN` ratio. Local
coverage checks base-unit and alternative-unit quantities, ratio reuse,
unknown units, overflow handling, and nonzero rounding to zero. Confirm on the
target SAP release that every confirmation unit is material-specific and
MARM-convertible, and verify its quantity precision and rounding behavior.


Production confirmation-window results now include a UTC timestamp captured
after the repository returns. It marks query completion only; paging remains
non-transactional, and later pages may observe changed postings.


## Transpiled ABAP Unit run (2026-10-19)

The first full transpiled ABAP Unit run stopped in the MARD repository test
`reads_bulk_prod_receipts`. The runner's SQLite schemas for AFPO, AFKO, and AUFK
lagged behind their SAP stubs, so inserts failed with a generic duplicate-key
message. The same drift affected AFRU and PLAF; the production-order repository
test also omitted PRPS from its OSQL test-environment dependencies. These runner
schemas and dependencies are now aligned.

The complete suite then exposed test defects: planned-order filter fixtures did
not include the base-unit data required by the shared result mapper, and the
production-order repository double filtered out the unrequested row that its
service-integrity test intended to return. Those fixtures and the double now
exercise the intended behavior. Confirmation base-unit assertions now include
the reversed EA scrap quantity in the overall total and exclude it from the
non-reversed total. The ratio-read assertion also reflects one cached BOX
conversion lookup. The full transpiled ABAP Unit suite now passes.

The signed allocation expiry-gap filter initially rejected an active `0..0`
request because initial integer bounds were treated as an omitted range. Active
requests now accept equal zero endpoints and reject only reversed bounds; base
and UOM regressions verify exact same-day selection.


Expired batch exposure now splits positive-stock rows into 1–7, 8–30, 31–90,
and 91+ day age buckets. Their counts and four stock-category totals partition
the expired totals. UOM results preserve counts and convert each category
quantity. Expiration on `as_of_date` remains upcoming at age zero. Boundary and
conversion tests cover each band.


Batch-expiry exposure also reports cumulative expired-stock horizons through
7, 30, and 90 days. Counts and four category totals follow the inclusive
horizon, the shorter horizons are subsets of longer ones, and totals reconcile
to the disjoint expired-age buckets. UOM results carry the same counts and
converted category amounts.


Expired batch exposure now provides `expiry_src_age_bands`, a fixed 12-row
matrix crossing plant, global-fallback, and other/blank sources with the four
disjoint overdue-age bands. Counts and four stock categories partition each
age band; zero intersections stay present. Unit-aware results preserve source,
band, count, and row order while returning base and requested-unit quantities.
Regression coverage checks every row in base and converted requests.


Upcoming batch exposure now includes `upcoming_src_bands`, a fixed 12-row
matrix crossing plant, global-fallback, and other/blank sources with the four
0–7, 8–30, 31–90, and over-90 day lead-time bands. It covers positive-stock
in-window rows, retains empty combinations, and reconciles to the upcoming
summary. Unit-aware rows preserve counts and order while converting all four
category quantities. Boundary fixtures cover every band and source group.


After-window batch exposure now includes `after_window_src_bands`, a fixed
12-row matrix crossing plant, global-fallback, and other/blank sources with
1–7, 8–30, 31–90, and over-90 day overruns beyond the inclusive `through_date`.
Counts and category totals partition the after-window summary, empty
combinations remain present, and UOM output preserves the counts while
converting all four stock categories. Regression fixtures cover every band
boundary and source group.


The first after-window source-band implementation declared the date subtraction
inline. The transpiler inferred a date-shaped local for the overrun distance,
so comparisons assigned rows to the wrong band. The service now stores the
subtraction in an explicitly typed integer local; the 1, 7, 8, 30, 31, 90, and
91 day regression boundaries pass in the full transpiled ABAP Unit run.


## Confirmation quantity range validation (2026-10-20)

PLAN validation and the full transpiled ABAP Unit suite pass for inclusive
yield, rework, and scrap quantity bounds in the production-confirmation window.
The full abaplint run still reports 497 issues across 252 files. The new
confirmation repository and regression code add no findings; four existing
alignment findings remain in the production-order read service. The
CRLF-aware diff check passes. Regressions also show that quantity filtering
precedes a one-row repository limit and that truncated service pages retain a
cursor over the filtered result set.


Batch-expiry detailed rows now support keyset pagination through
`maximum_batch_rows` (1–500) and the `batch_cursor_*` tuple. The tuple follows
the exact dated-row ordering and may contain blank batch/location/valuation
keys. Results return `is_truncated`, `next_cursor_*`,
`total_dated_batch_row_count`, and `returned_batch_row_count`; when truncated,
`next_cursor_*` identifies the last row returned. The default limit of zero
preserves the complete dated list. Summary values remain based on all matching
rows. Undated details have their own 1–500 keyset page, ordered by batch,
location, and valuation type; zero retains the complete list. Their total count
and summary remain complete. A continuation cursor is returned only when the
undated page is truncated. `omit_undated_batch_rows = abap_true` suppresses
details and conflicts with an active undated cursor or nonzero undated limit.
UOM requests pass both page contexts to the base result. Each page is a new
stock read and does not retain a snapshot across calls.


Batch expiry page totals, dated/undated source matrices, and page-local date spans were added
on 2026-10-20, but this workspace could not run `npm test`: the WSL 1 Node shim exited before
invoking the scripts
with `WSL 1 is not supported` and `Could not determine Node.js install
directory`. PLAN validation, abaplint, transpilation, and ABAP Unit have not
been run against this change. Re-run the configured pipeline in a working Node
environment before treating the feature as validated.

The 2026-10-20 reservation-summary and allocation-detail omission optimizations
also remain unvalidated by the configured gates for the same WSL 1 Node runtime
failure above. Source-level checks and diff whitespace checks passed; PLAN
validation, abaplint, transpilation, and ABAP Unit did not run for these changes.

Uncovered-detail summary-only scanning also remains unvalidated by the configured
PLAN validator, abaplint, transpiler, and ABAP Unit gates because the WSL 1 Node
runtime failure above persists. The focused source checks and diff whitespace
check passed; this is not a substitute for those configured gates.


The 2026-10-20 planned-order special-procurement filter addition is not yet validated by PLAN validation, abaplint, transpilation, or ABAP Unit because the configured Node runtime is unavailable in this WSL 1 environment. Regression coverage and source-level contract guards were added; run the configured gates when Node interop is available.

Further 2026-10-20 expiry reporting regressions now cover every base and UOM result field, including all dated/undated page category balances, summary identities, and reservation shortage conversions. Structural and field-reference checks passed, but the same WSL 1 Node limitation prevented PLAN validation, abaplint, transpilation, and ABAP Unit execution for these additions.

The batch-expiry exact/blank batch-selector regression additions are also not
validated by PLAN validation, abaplint, transpilation, or ABAP Unit. The
configured Node runtime still fails before running those gates in this WSL 1
environment.

The STO source-plant atomic-failure regressions are not runtime-validated for
the same reason. Static checks and diff whitespace validation can confirm the
source contracts but do not replace PLAN validation, abaplint, transpilation,
or ABAP Unit execution.

The cost-center bulk issue/reversal stop-on-failure regressions are also not
runtime-validated. PLAN validation, abaplint, transpilation, and ABAP Unit still
cannot run because the configured Node runtime fails in this WSL 1 environment.

The STO plant-pair committed-state and unattempted-row assertions are source-
level checked but not runtime-validated for the same Node runtime failure.

The atomic STO plant-pair create-failure stop-flag regression and its PLAN
source guard also await runtime validation for the same reason.

The ATP-gated STO plant-pair stop-on-failure regression and its wrapper
forwarding guard also await runtime validation for the same WSL 1 Node issue.

The new public STO method stop-option validation/forwarding guard is source
checked against 34 declarations but cannot be executed by PLAN validation until
the WSL 1 Node runtime issue is resolved.

The repository-wide public stop-option preservation guard is source-checked
against 152 declarations but has not run under PLAN validation because the
configured Node runtime still fails in this WSL 1 environment.

The repository-wide public simulation-flag guard is source-checked against 403
declarations across 16 classes but has not run under PLAN validation for the
same WSL 1 Node runtime issue.

The repository-wide atomic-mode propagation guard is source-checked against
58 declarations across five classes but has not run under PLAN validation for
the same WSL 1 Node runtime issue.

The direct base expired-scrap preview regressions for unrestricted, QI, and
blocked stock, strict full-quantity shortfall, and unknown-category rejection
and their PLAN source guards are also not runtime-validated for the same WSL 1
Node runtime failure. Source-level inspection and whitespace checks are the
available local validation until the configured pipeline can run in a
supported environment.

The 2026-10-20 dated-page source/expired-age-band matrix and its regression
coverage are not runtime-validated. The configured WSL 1 Node shim still fails
before PLAN validation, abaplint, transpilation, or ABAP Unit can start. Source
contracts and whitespace checks are the available local validation.

The 2026-10-20 upcoming and after-window page source-band matrices and their
boundary, empty-page, and UOM regressions are not runtime-validated because the
configured WSL 1 Node shim fails before the project gates can start. Source
checks and whitespace validation remain the available local evidence.

The 2026-10-20 source/window-band summaries for upcoming and after-window
expiry pages, including their boundary and UOM regressions, have not run through
PLAN validation, abaplint, transpilation, or ABAP Unit. The WSL 1 Node shim
fails before those gates start; static source checks and diff whitespace checks
are the available validation.

The 2026-10-20 page-status date ranges and their empty, summary-only, and UOM
regressions have not run through PLAN validation, abaplint, transpilation, or
ABAP Unit. The WSL 1 Node shim fails before those gates start; static source and
diff whitespace checks are the available validation.

The 2026-10-20 page status quantity-share fields and their mixed-category,
zero-denominator, empty, summary-only, and UOM regressions have not run through
PLAN validation, abaplint, transpilation, or ABAP Unit. The WSL 1 Node shim fails
before those gates start; static source checks and diff whitespace checks are
the available validation.

The 2026-10-20 page source/status category-share fields and their source/status,
rounding, empty, summary-only, and UOM regressions have not run through PLAN
validation, abaplint, transpilation, or ABAP Unit. The WSL 1 Node shim fails
before those gates start; static source checks and diff whitespace checks are
the available validation.

The 2026-10-20 full-scope source/status category-share fields, including their
after-window denominators, plus limited-page, cursor-continuation, summary-only,
empty-result, and UOM regressions have not run through PLAN validation,
abaplint, transpilation, or ABAP Unit. The WSL 1 Node shim fails before those gates start; static source
and diff whitespace checks are the available validation.

The 2026-10-20 summary-only regression for raw unknown undated source `X` in base and UOM results has not run through PLAN validation, abaplint, transpilation, or ABAP Unit. The WSL 1 Node shim fails before those gates start; static source and diff whitespace checks are the available validation.

The active expiry-status filter regression for full category shares, including summary-only UOM output, also remains unrun through the runtime gates.

The planned-order default-continuation and stop-on-failure regressions, including
simulated suggestion receipt failure across suggestions, skipped-row source and
receipt indexes, zero test-run commit/rollback calls, and invalid flags across
all four create entry points, have not run through PLAN validation, abaplint,
transpilation, or ABAP Unit; the WSL 1 Node shim fails before those gates start.

Undated page and full-scope expiry-source category shares now have focused
regression assertions for mixed denominators, empty pages and full totals,
summary-only output, unknown-source grouping, and UOM echo. The dated
`expiry_statuses`, direct page/full source summaries, and both status-relative
and source-relative row shares also have focused assertions and PLAN validator
guards. The regressions and source guards have not run through PLAN validation,
abaplint, transpilation, or ABAP Unit
because the configured WSL 1 Node shim fails before those gates start; source
inspection and diff whitespace checks are the available local validation.
The 2026-10-20 status-relative category shares on dated source/status cells and
their full/page, rounding, zero-denominator, empty-result, and UOM regressions
have not run through PLAN validation, abaplint, transpilation, or ABAP Unit. The
configured WSL 1 Node shim fails before those gates start; source inspection and
diff whitespace checks are the available local validation.
The 2026-10-20 source-relative category shares on dated source/status cells and
their full/page, zero-denominator, empty-result, and UOM regressions have not run
through PLAN validation, abaplint, transpilation, or ABAP Unit. The configured
WSL 1 Node shim fails before those gates start; source inspection and diff
whitespace checks are the available local validation.
The 2026-10-20 expired source/age quantity-share fields and their full,
limited-page, zero-denominator, empty-result, and UOM regressions have not run
through PLAN validation, abaplint, transpilation, or ABAP Unit. The configured
WSL 1 Node shim fails before those gates start; source inspection and diff
whitespace checks are the available local validation.
The 2026-10-20 upcoming and after-window source/window category-share fields
and their full/page, limited-page, empty-result, and UOM regressions have not
run through PLAN validation, abaplint, transpilation, or ABAP Unit. The
configured WSL 1 Node shim fails before those gates start; source inspection and
diff whitespace checks are the available local validation.

The 2026-10-20 source-relative and band-relative row shares on full and page
expiry source/age and source/window matrices, including limited-page, empty,
and UOM regressions, have not run through PLAN validation, abaplint,
transpilation, or ABAP Unit. The configured WSL 1 Node shim fails before those
gates start; source inspection and diff whitespace checks are the available
validation.

The 2026-10-20 source-relative category-share fields on full and page expiry
source/age and source/window matrices, including limited-page, empty, and UOM
regressions, have not run through PLAN validation, abaplint, transpilation, or
ABAP Unit. The configured WSL 1 Node shim fails before those gates start;
source inspection and diff whitespace checks are the available validation.
The 2026-10-20 band-relative category shares on full and page expiry source/age
and source/window matrices, including mixed-source, limited-page, summary-only, empty-band,
and UOM regressions, have not run through PLAN validation, abaplint,
transpilation, or ABAP Unit. The configured WSL 1 Node shim fails before those
gates start; source inspection and diff whitespace checks remain the available
local validation.
The 2026-10-20 `available_pct_of_unrestricted` field on full and page expiry
source/age and source/window matrices, including full typed rows, limited-page,
empty, summary-only, and UOM regressions, has not run through PLAN validation,
abaplint, transpilation, or ABAP Unit. The Windows Node executable returns a
WSL `UtilBindVsockAnyPort` error before validation starts; static source review
and `git diff --check` are available locally.
The 2026-10-20 `reservation_deduction_qty` fields on full and page expiry
source/age and source/window matrices, including typed full-scope values,
limited-page, empty, summary-only, and base/requested-unit UOM regressions, have
not run through PLAN validation, abaplint, transpilation, or ABAP Unit. Windows
Node invocation still fails with WSL `UtilBindVsockAnyPort` before validation;
static inspection and `git diff --check` remain available.

The 2026-10-20 expiry summary, undated-summary, and source/status availability
ratios and signed reservation-deduction fields, with full/page/limited/cursor,
empty/summary-only, and UOM regressions, have not run through PLAN validation,
abaplint, transpilation, or ABAP Unit. `npm test` exits before starting because the
Windows npm launcher reports that WSL 1 is unsupported and cannot locate the
Node installation. Static source checks and `git diff --check` remain available
locally.


The dated, undated, and after-window expiry detail availability ratios and
signed reservation deductions, including converted UOM detail, have not run
through PLAN validation, abaplint, transpilation, or ABAP Unit. The existing
WSL 1 Windows Node launcher failure still prevents those runtime gates.


The dated and undated expiry page-total availability ratios and signed
reservation deductions, including UOM conversions, have not run through PLAN
validation, abaplint, transpilation, or ABAP Unit. The WSL 1 Windows Node
launcher issue recorded above still prevents those runtime gates.


The new full-scope undated expiry ratio and signed deduction fields, including
summary-only UOM conversion, have not run through PLAN validation, abaplint,
transpilation, or ABAP Unit. The recorded WSL 1 Windows Node launcher issue
continues to block those runtime checks.


The combined full-scope dated expiry totals, guarded availability ratio, and
signed deduction have not run through PLAN validation, abaplint, transpilation,
or ABAP Unit. The existing WSL 1 Windows Node launcher failure still prevents
those runtime gates.

The 2026-10-20 production-order finish-window receipt-progress filter and its
service/repository regressions have not run through PLAN validation, abaplint,
transpilation, or ABAP Unit. `npm run validate:plan` exits before Node starts
because WSL 1 is unsupported; direct `node.exe` invocation fails with WSL
`UtilBindVsockAnyPort`. Source inspection and CRLF-aware `git diff --check` are
available locally.

The 2026-10-20 production-order finish-window received-quantity bounds and
service/repository regressions have not run through PLAN validation, abaplint,
transpilation, or ABAP Unit. The WSL 1 npm launcher and Windows Node interop
errors recorded above continue to block those runtime gates; source review and
CRLF-aware `git diff --check` are available locally.

The 2026-10-20 `matches_finish_selection` output marker and its matching,
nonmatching, and direct-bulk regressions have not run through PLAN validation,
abaplint, transpilation, or ABAP Unit. The WSL 1 Node startup failures recorded
above continue to block runtime gates; source review and CRLF-aware
`git diff --check` are available locally.

The 2026-10-20 `finish_window_match_count` output field has not run
through PLAN validation, abaplint, transpilation, or ABAP Unit. Runtime checks
remain unavailable because of the WSL 1 Node startup failures recorded above.
The consolidated finish-filter drift contract and its validator guard were
expanded to cover all detail-predicate fields; the validator has not run for
the same launcher failure.

Validation follow-up on 2026-10-20: the latest full abaplint run reported 2,012
issues across 252 files. After the finish-window identifier and alignment fixes,
targeted abaplint over the repository, service, their regression files, and
direct dependencies reports 0 issues across 12 files. Full transpilation runs
but still fails on errors in other files, including `zcl_stock_service` and
unrelated planned-order and goods-movement tests; it reports no production-order
read file errors. `npm run validate:plan` still exits before Node starts because
of WSL 1, so `npm test` does not reach ABAP Unit. `git diff --check` passes.
The recent production-order changes have targeted lint and source-contract
checks, but still lack a complete repository transpile and ABAP Unit run.

The 2026-10-20 per-order `matching_progress_counts` output and regression
assertions pass targeted abaplint with 0 findings across 12 files. Full
transpilation still fails on errors in other files; the PLAN validator launcher
and ABAP Unit blockers above remain.

The 2026-10-20 receipt-progress summary percentages pass targeted abaplint with
0 findings across the same 12 production-order read files. The full transpiler
still exits on existing errors in other services and test files. PLAN validation
and ABAP Unit remain unavailable because the configured Node launcher reports
that WSL 1 is unsupported.

The 2026-10-20 finish-window received-percentage bounds and their repository,
service, pagination, invalid-input, and detail-drift regressions pass targeted
abaplint with 0 findings across 12 files. The full PLAN validator and ABAP Unit
suite have not run because the Node launcher cannot start under WSL 1; the full
repository transpiler remains blocked by errors in other service and test files.

The `total_item_count` field on receipt-progress summaries and its regression
assertions pass targeted abaplint with 0 findings across the same 12 files.
Source-contract checks pass; full PLAN validation and ABAP Unit remain blocked
by WSL 1, while repository transpilation continues to report failures outside
the production-order read files.

Per-order receipt-progress summaries and full-item versus matching-item
regressions pass targeted abaplint with 0 findings across the same 12 files,
and `git diff --check` passes. `npm run validate:plan` still exits before Node
starts because this workspace uses WSL 1. Full transpilation reports the same
pre-existing issues in stock-service, planned-order, and goods-movement files;
it reports no production-order-read errors. ABAP Unit therefore remains
unavailable in this environment.

The 2026-10-20 per-item receipt-progress validity flag and regressions could not
be checked with the configured Node gates: `npm run validate:plan` reports that
WSL 1 is unsupported and cannot locate Node.js, while direct `node` invocation
is unavailable in this shell. The blocked-stock preview regression also had an
incorrect expected `category_balance` of 3.000 for a fixture batch with a full
blocked balance of 2.000; the assertion now matches the reported source
balance. Source review and CRLF-aware diff checks remain available.

The 2026-10-20 production-order conversion summary extension adds per-order
success/failure counts and a page-level successful conversion count, including
finish-window detail rows retained outside the matching selection. Regression
coverage and PLAN guards were added, but `npm run unit` exits before reaching
transpilation or ABAP Unit because the configured Node launcher reports that
WSL 1 is unsupported.

The 2026-10-20 finish-window matched-conversion summaries add page and per-order
success/failure counts over rows still matching the selected item scope. Their
regression covers a selected conversion failure beside a retained nonmatching
successful row, but runtime gates remain unavailable because the WSL 1 Node
launcher exits before starting the project scripts.

The 2026-10-20 production-confirmation window now aggregates returned pages by
production order and source unit, and its base-unit wrapper aggregates by
production order and base unit. Regression coverage checks reversed versus
non-reversed totals, UOM merging, and page lookahead exclusion; Node-based
runtime validation remains unavailable in this WSL 1 environment.

The 2026-10-20 confirmation summaries now count partial confirmations beside
final and reversed rows at operation, order, and base-unit levels, with two-
decimal status percentages over each group's confirmation count. A unit run
also exposed that valid not-started receipt items left open order quantity and
open percentage initial; the service now reports the full remaining quantity
and 100%. The initial run reached that ABAP Unit failure, but the follow-up
`npm run unit` stopped before Node started because this shell reports that WSL 1
is unsupported. The summary changes therefore still need runtime validation.

The 2026-10-20 confirmation-window search now filters exact AFVC-LTXA1
operation descriptions, including explicit blank-text matching. The repository
applies the selector in both posting-date cursor branches, and service-side
validation checks the flag and returned description scope. Source review and
CRLF-aware diff checks remain available; unit and PLAN validation were not run.

The 2026-10-20 confirmation-window search now filters by AUFK-AUART order type
before pagination and exposes that type on confirmation rows. Direct bulk
confirmation reads and operation-, order-, and base-unit summaries expose the
order type as well. Source review and CRLF-aware diff checks remain available;
unit and PLAN validation were not run.

The 2026-10-20 routing-operation bulk read now reports AUFK-AUART and accepts
`iv_order_type` to filter before paging. Both the paginated join and legacy read
path apply the selector, and service validation checks returned type scope.
Source review and CRLF-aware diff checks remain available; unit and PLAN
validation were not run.

The 2026-10-20 routing-operation bulk read now accepts `iv_operation_counter`
to filter exact AFVC-APLZL values before pagination. Both paginated and legacy
repository paths apply the filter, and the service checks returned counter
scope. Source review and CRLF-aware diff checks remain available; unit and PLAN
validation were not run.

The 2026-10-20 number-based confirmation bulk read now accepts `iv_order_type`
to filter by AUFK-AUART before operation lookup and validates the returned type.
Source review and CRLF-aware diff checks remain available; unit and PLAN
validation were not run.

The 2026-10-20 number-based confirmation bulk read also accepts
`iv_operation_counter` to filter exact AFVC-APLZL values before returning rows.
The service validates the returned counter scope. Source review and CRLF-aware
diff checks remain available; unit and PLAN validation were not run.

The number-based confirmation bulk result now includes per-order
`confirmation_count` and page-level `returned_count`, with the per-order counts
reconciling to the total. Source review and CRLF-aware diff checks remain
available; unit and PLAN validation were not run.

The number-based confirmation bulk read now supports `iv_exclude_reversed`.
The repository filters AFRU reversal rows before operation resolution, and the
service rejects invalid flags or returned reversed rows. Source review and
CRLF-aware diff checks remain available; unit and PLAN validation were not run.

The number-based confirmation bulk read now supports mutually exclusive
`iv_final_only` and `iv_partial_only` flags. AFRU status filtering happens
before AFVC lookup, and service validation checks returned status scope. Source
review and CRLF-aware diff checks remain available; unit and PLAN validation
were not run.

The number-based confirmation bulk read now accepts `iv_operation_number` to
filter exact AFVC-VORNR values, including with the counter selector. The
repository filters before mapping, and the service validates the returned
operation number. Source review and CRLF-aware diff checks remain available;
unit and PLAN validation were not run.

The number-based confirmation bulk read now accepts an AFRU confirmation and
optional counter pair. A counter without a confirmation number is rejected;
both fields are applied before AFVC resolution and checked on returned rows.
Source review and CRLF-aware diff checks remain available; unit and PLAN
validation were not run.

The number-based confirmation bulk read now filters routing sequence and
suboperation. Flags allow exact initial-value selection, and suboperation
filters require an operation number. Repository filtering, service validation,
and the fake repository follow the same selectors. Source review and CRLF-aware
diff checks remain available; unit and PLAN validation were not run.

The number-based confirmation bulk read now enforces the documented 1-to-500
page size in the repository and returns a four-field keyset cursor when another
page exists. Cursor completeness, date validity, requested-order scope, and
returned-row scope are checked in the service. Static review and CRLF-aware diff
checks remain available; unit and PLAN validation were not run.
Number-based confirmation bulk reads also accept optional inclusive posting-date
bounds. Invalid or reversed ranges fail before repository access; returned rows
are checked against each enabled bound. CRLF-aware diff checks remain
available; unit and PLAN validation were not run.
The number-based confirmation bulk read now accepts an exact AUFK order-category
filter for production (`10`) or process (`40`) orders. Invalid nonblank values
are rejected before repository access, and returned category scope is checked.
CRLF-aware diff checks remain available; unit and PLAN validation were not run.
The number-based confirmation bulk read now supports `iv_reversed_only` in
addition to `iv_exclude_reversed`. The boolean selectors are mutually
exclusive; repository filters and service result checks enforce the selected
reversal scope. CRLF-aware diff checks remain available; unit and PLAN
validation were not run.
The number-based confirmation bulk read now accepts inclusive AFRU-ERSDA entry-date
bounds independent of posting date. Active bounds exclude blank entry dates;
repository filtering and service result checks enforce the scope. CRLF-aware
diff checks remain available; unit and PLAN validation were not run.
The number-based confirmation bulk read now filters by AFVC control key, operation
description, and resource object ID, with flags for exact blank matching. The
repository filters before pagination and the service validates returned scope.
CRLF-aware diff checks remain available; unit and PLAN validation were not run.
Confirmation and operation reads use `iv_filter_op_description` for blank
AFVC-LTXA1 matching; the shorter name satisfies the transpiler's parameter-name
limit. The transpiler completed successfully after correcting reported method
calls and identifiers. The initial lint run reported 653 issues across 252
files, mostly alignment findings. A later lint rerun and `validate:plan` could
not start because the WSL Node launcher reported WSL 1 unsupported / socket
errors; lint status after the fixes remains unverified.

Number-based `READ_CONFIRMATIONS_BULK` now filters AFRU entered-by and changed-by users, with flags for exact blank values, and accepts optional inclusive AFRU-LAEDA bounds. Active bounds exclude rows without a last-change date. The service validates selectors and returned rows; the repository applies filters before operation resolution and paging. Source review and CRLF-aware diff checks remain available; validation outcomes are recorded below.

The confirmation audit-filter change transpiles successfully. The launched abaplint run reported 700 repository-wide issues across 252 files, mostly alignment findings. PLAN validation could not launch because the WSL Node shim reports WSL 1 unsupported; ABAP Unit could not launch because `node` is unavailable in the Linux PATH. Source-level checks and the CRLF-aware diff check passed.

Number-based `READ_CONFIRMATIONS_BULK` now accepts `iv_quantity_unit`, with nonblank values filtering by default and `iv_filter_quantity_unit = abap_true` selecting exact blank-unit rows. Repository filtering precedes operation resolution and pagination; service validation and the fake repository enforce the same scope. Service regression coverage includes nonblank, blank, and invalid flag inputs. The repository regression queries BOX with a one-row page and checks the SQL-filtered confirmation.

The confirmation-unit filter passes transpilation. abaplint reported 682 issues across 252 files; the newly added public and repository parameter declarations were aligned, reducing the prior 700 issue count. PLAN validation remains unavailable because the WSL 1 Node shim fails to locate Node; ABAP Unit remains unavailable because Linux `node` is not installed. Source-level contract checks and the CRLF-aware diff check pass.

`READ_CONFIRMATIONS_BULK` now supports an inclusive AFRU-ERZET time window with mandatory valid ascending bounds when enabled. Midnight is valid, and inactive bounds must be initial. Repository filtering precedes pagination and service result validation checks the window. Service and repository regressions cover the boundary values and invalid ranges.

The AFRU entry-time window transpiles successfully. abaplint reports 682 issues across 252 files, with no findings on the new entry-time declarations or regression cases. PLAN validation cannot launch under the WSL 1 Node shim, and ABAP Unit cannot start because Linux `node` is unavailable. CRLF-aware diff and source checks pass.

`READ_CONFIRMATIONS_BULK` now filters positive AFRU yield, rework, and scrap and supports inclusive per-quantity lower and upper bounds. Bounds may be enabled independently; disabled values must be initial, paired bounds must ascend, and any quantity range requires an exact confirmation-unit scope. Repository SQL filters before routing resolution and pagination; service validation checks returned rows. The fake and service/repository regressions cover unit-required ranges, positive-only filters, and inclusive boundaries.

The number-based confirmation quality filters transpile successfully. abaplint reports 606 repository-wide issues across 252 files, mostly from the existing alignment backlog; the count was 682 before the current signature and call alignment cleanup. The PLAN validator cannot launch under the WSL 1 Node shim, and the ABAP Unit runner remains unavailable because Linux `node` is not installed. Source contract checks, line-length and parameter-name checks, newline checks, and the CRLF-aware diff check pass.

`READ_OPERATIONS_BULK` accepts inclusive `iv_operation_number_from` and
`iv_operation_number_to` bounds for AFVC-VORNR. Each endpoint is optional;
paired noninitial bounds must ascend, and the exact `iv_operation_number`
filter intersects with the range. Repository page and fallback queries filter
before pagination, while service validation rejects returned rows outside the
selected range. Regression cases cover inclusive endpoints, exact-selector
intersection, reversed bounds, result-scope drift, and paged/unpaged SQL paths.

`READ_OPERATIONS_BULK` also accepts inclusive `iv_operation_counter_from`
and `iv_operation_counter_to` bounds for AFVC-APLZL. Initial values omit a
bound, paired noninitial bounds must ascend, and `iv_operation_counter`
intersects with the range. Both repository query paths and service result
validation apply the bounds before paging/mapping. Regression cases cover
boundaries, exact-counter intersection, reversed bounds, and both query paths.

The AFVC-VORNR and AFVC-APLZL operation ranges transpile successfully.
abaplint reported 547 findings across 252 files, down from 606 before these
selectors and related alignment cleanup. PLAN validation still cannot launch
under the WSL 1 Node shim, and ABAP Unit cannot start because Linux `node` is
not installed. Source length/identifier/newline checks and CRLF-aware diff
validation pass.

`READ_OPERATIONS_BULK` now supports inclusive AFVC-PLNFL bounds through
`iv_operation_sequence_from` and `iv_operation_sequence_to`. Initial values omit
a bound, paired noninitial bounds must ascend, and an exact sequence selector
intersects with the range. Both repository queries filter before pagination,
and the service validates returned sequence scope. Regressions cover inclusive
bounds, one-sided bounds, exact intersection, reversed bounds, and result drift.

The AFVC-PLNFL range transpiles. abaplint reports 547 existing findings
across 252 files, unchanged from the prior operation-range pass. PLAN
validation cannot launch under the WSL 1 Node shim, and ABAP Unit cannot start
because Linux `node` is unavailable. Source-contract, newline, line-length,
identifier, and CRLF-aware diff checks pass.


`READ_OPERATIONS_BULK` now accepts inclusive AFVC-UVORN bounds. Active ranges
require an exact `iv_operation_number`; blank bounds are inactive, and paired
active bounds must ascend. Repository filtering occurs before pagination and the
service checks returned rows against the requested range.


`READ_CONFIRMATIONS_BULK` now supports inclusive AFVC-UVORN range filters. The
range requires an exact operation number and is applied before result paging in
both repository query paths. The service rejects inverted bounds and checks
returned confirmations against the selected suboperation range.


`READ_CONFIRMATIONS_BULK` now supports inclusive AFVC-VORNR bounds. Each bound
may be omitted independently, paired bounds must ascend, and an exact operation
number intersects with the selected range. SQL filtering runs before paging in
both repository paths and service validation rejects returned rows outside the
selected operation-number scope.

`READ_CONFIRMATIONS_BULK` now supports inclusive AFVC-PLNFL bounds. Either
bound can be supplied alone, paired active bounds must ascend, and an exact
sequence selector intersects with the range. Both repository query paths
filter before pagination, and service validation checks returned sequence
scope. Regression coverage includes boundaries, one-sided bounds, exact
intersection, reversed bounds, result drift, and paged/unpaged SQL reads.

`READ_CONFIRMATIONS_BULK` now accepts inclusive AFVC-APLZL bounds. Either
bound may be omitted, paired active bounds must ascend, and the exact counter
selector intersects with the range. Both repository query paths filter before
pagination, and service validation checks returned counter scope. Regression
coverage includes paired and one-sided bounds, exact intersection, reversed
bounds, result drift, and paged/unpaged SQL reads.


`SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts inclusive AFVC-VORNR bounds.
Either endpoint may be omitted, paired bounds must ascend, and the exact
operation selector intersects with the range. Repository SQL filters before
pagination; service validation rejects returned rows outside the selected
range.

`SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts inclusive AFVC-PLNFL bounds.
Either endpoint may be omitted, paired bounds must ascend, and the exact
sequence selector intersects with the range. Repository SQL filters before
pagination; the service checks returned rows against the selected sequence
range.

`SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts inclusive AFVC-UVORN bounds
scoped to an operation number. Either endpoint may be omitted, paired bounds
must ascend, and the exact suboperation selector intersects with the range.
Repository SQL filters before pagination, and service validation rejects
missing operation scope and returned rows outside the range.

`SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts inclusive AFVC-APLZL bounds
scoped to one selected order. Either endpoint may be omitted, paired bounds
must ascend, and the exact counter selector intersects with the range.
Repository SQL filters before pagination; service validation enforces the
selected order and counter range.

`SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts inclusive AFRU-RMZHL bounds
scoped to a selected confirmation. Either endpoint may be omitted, paired
bounds must ascend, and active bounds require the confirmation number. The
exact counter selector intersects with the range; repository SQL filters
before pagination and service validation rejects range drift.


`SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts an exact nonblank work-center
selector on CRHD-ARBPL. The repository joins CRHD through AFVC-ARBID and
CRHD-OBJID, filters before pagination, and returns the work-center code on
confirmation rows and operation summaries. The service validates returned
work-center scope.


The confirmation work-center read introduced CRHD fields outside the current Open ABAP core snapshot. Added a minimal SAP-standard CRHD stub for MANDT, OBJTY, OBJID, and ARBPL so the transpiler can resolve DDIC types and the repository tests can register the joined table.

The work-center selector also supports an explicit blank-code match through `filter_work_center`; invalid flag values fail before the query, and the service rejects rows outside the requested code scope.

`CRHD-WERKS` is now exposed as `work_center_plant` and filters confirmations before pagination. `filter_work_center_plant` explicitly selects unresolved blank plants; the CRHD stub includes WERKS for type checking and repository test data.


`SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts `filter_order_type` to select
confirmations whose AUFK-AUART order type is blank. A nonblank `order_type`
continues to filter by default; invalid flag values fail before the read. SQL
filters before pagination, and service validation checks returned order types.


`SEARCH_CONFIRMATIONS_BY_WINDOW` now exposes the AUFK-LOEKZ
`order_deletion_indicator`. Set `exclude_deleted` to `abap_true` to
require an undeleted order and at least one matching AFPO item with
blank `XLOEK`; repository SQL applies this before pagination, and the
service validates the order-header deletion scope.

A one-character CRHD object-type SQL literal failed to match the
fixed-width OBJTY test value in the SQLite runtime. The join now uses
a typed CRHD-OBJTY host variable, preserving work-center matches in
the transpiled query and the SAP DDIC type.

The READ_OPERATIONS_BULK range regression expected base operations
only even when no suboperation selector was active. The repository
correctly returns matching suboperations by default; the test now
covers the returned suboperation and corresponding result counts.

`READ_CONFIRMATIONS_BULK` now returns AFRU-ISDD/ISDZ and IEDD/IEDZ and accepts
the same inclusive execution-date and time filters as the window search. The
number-based repository applies these filters before operation resolution and
pagination; its service validates actual timestamps and selected scope. The
finish-time boolean is named `iv_filter_exec_finish_time` to stay within the
ABAP 30-character method-parameter limit.


`READ_CONFIRMATIONS_BULK` now returns the assigned work-center code and plant. Nonblank values filter exactly; `iv_filter_work_center` and `iv_filter_work_center_plant` explicitly select blank fields, including operations with no matching CRHD row. The paged query applies these CRHD selectors before its lookahead limit. The unpaged path resolves centers from CRHD after the AFVC lookup and checks the same selectors before returning confirmations. Service checks reject rows outside the requested code or plant. Regressions cover exact and blank matches in both paging modes and invalid selector flags.


`READ_OPERATIONS_BULK` now returns the same CRHD work-center code and plant fields as confirmation reads. Exact selectors and explicit blank matches filter before pagination and are checked by the service. Its unpaged path fetches CRHD assignments after AFVC operations; the paged path joins CRHD before applying the lookahead limit. Regressions cover exact code and plant selections, blank assignments, paging, and invalid flags.


`READ_OPERATIONS_BULK` now returns page-scoped `work_center_summaries` grouped by CRHD plant and code. Blank or unresolved assignments are grouped together, lookahead and later-page operations are excluded, and the summary operation counts reconcile to `total_operation_count`.
Each work-center summary also reports the number of distinct contributing
requested orders; repeated operations from one order count once per work-center
group. It reports `operation_pct`, the group's share of returned page
operations. The page denominator includes returned rows only, not the lookahead
operation; page rates are computed from aggregated counts.
`READ_OPERATIONS_BULK` also returns page-scoped `order_category_summaries`
grouped by AUFK-AUTYP. Blank categories remain visible; counts reconcile to
`total_operation_count`, and each category's `operation_pct` uses
`total_operation_count` as its denominator. `order_count` reports distinct
requested orders represented in each category.
`READ_OPERATIONS_BULK` also returns page-scoped `order_type_summaries` grouped
by AUFK-AUART. Blank order types remain visible; counts reconcile to
`total_operation_count`, and each order type's `operation_pct` uses
`total_operation_count` as its denominator. `order_count` reports distinct
requested orders represented in each type.
`READ_OPERATIONS_BULK` also returns page-scoped `control_key_summaries` grouped
by AFVC-STEU. Blank control keys remain visible; counts reconcile to
`total_operation_count`, and each control key's `operation_pct` uses
`total_operation_count` as its denominator. `order_count` reports distinct
requested orders represented in each key; one order can contribute to several
control keys. All operation summaries also report `order_pct` as
`order_count` divided by page `found_count`, the number of requested orders
with returned operations. Work-center and control-key groups can overlap, so
their order percentages need not sum to 100.


Number-based `READ_CONFIRMATIONS_BULK` now includes page-scoped `work_center_summaries`, grouped by CRHD plant and code. Blank assignments are retained as a group, lookahead and later-page confirmations are excluded, and the counts reconcile to `returned_count`.


`SEARCH_CONFIRMATIONS_BY_WINDOW` now includes the same page-scoped work-center summary. Confirmation rows group by CRHD plant and code; blank assignments remain visible, and summary counts exclude lookahead and later-page rows while reconciling to the returned count.

Confirmation work-center summaries now include yield, rework, and scrap totals grouped by confirmation unit, with separate gross and non-reversed values. The base-unit window result also groups converted quantities by work center and material base unit, avoiding invalid totals across mixed confirmation units.

Work-center confirmation summaries also report the date span among dated rows, final/partial/reversed counts, and count percentages. The final and partial counts partition the returned confirmations, while reversed rows remain visible in the counts and gross quantity totals.


Current verification uses the installed Linux Node runtime at
`/home/lars/.nvm/versions/node/v22.22.2/bin/node`; this resolves the
earlier WSL Node-launcher failure. The AFRU execution date/time
filters pass transpilation, ABAP Unit, and PLAN validation. abaplint
still reports 627 issues across 252 files, primarily alignment
findings; the CRLF-aware diff check passes. Operation work-center selectors
and page-scoped operation, confirmation, and window-search summary regressions pass with the
unit suite. Duration summaries now also report minimum and maximum valid
intervals and count zero-duration valid intervals separately; mixed, single,
empty-valid, and zero-duration cases pass in the full unit suite. PLAN validation
passes and abaplint remains at 627 findings across 252 files.

The PLAN validator's `valid_exec_duration_pct` field-count pattern also matched
the name `invalid_exec_duration_pct`, producing a false failure after the
invalid-duration metric was added. A word boundary now keeps the count check
specific to the valid field.


Production confirmation detail rows now expose `exec_duration_seconds` alongside `exec_duration_status`. Valid intervals report elapsed whole seconds, including zero; invalid and missing intervals return an initial duration and retain `I`/`M` status. Regressions cover positive, invalid, missing, and zero intervals across window, number-based, and base-unit detail. The full ABAP Unit suite and PLAN validator pass; abaplint remains at the 627-finding baseline. CRLF-aware added-line checks pass.


Work-center confirmation summaries now expose `exec_covered_seconds`, the union of valid intervals after overlap merging. The regression uses overlapping confirmations in different units, a zero-length interval, a gap, and a cross-day interval ending at `000000`; center totals merge across units, unit rows stay separate, and base-unit summaries return the same union. The midnight finish contributes to coverage because SAP `TIMS` value `000000` is valid midnight.

Verification: transpilation, the full ABAP Unit suite, and PLAN validation pass. abaplint reports the existing 627 findings across 252 files with no new findings. The CRLF-aware added-line check passes.

Operation and order confirmation summaries now expose `exec_covered_seconds` at their own group scope. Raw summaries keep quantity units separate; base operation and order summaries merge source-unit intervals within each converted base-unit group. The regression checks each scope across overlapping, gapped, zero-length, and cross-day intervals. Verification: transpilation and the full unit suite pass, PLAN validation passes, and abaplint remains at the existing 627-finding baseline.

Confirmation summaries also report `exec_overlap_excess_seconds`, the difference between summed valid duration and the covered-time union. Three intervals overlapping for 30 seconds contribute 60 excess seconds. The regression checks raw work-center and unit scopes plus raw and base operation/order scopes. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.

Confirmation summaries now report `exec_peak_concurrency`, the maximum number of simultaneous valid positive-duration intervals in each group. Touching boundaries use half-open interval semantics and do not increase the count; zero-duration rows are excluded. Regressions cover a triple overlap, raw and base-unit groups, and intervals that only touch. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.

Confirmation summaries now report `exec_idle_gap_seconds` inside the envelope of positive-duration intervals. It excludes time before the first or after the last interval and does not let zero-duration rows set the envelope. Tests cover separate gaps, touching intervals, a cross-day finish, raw units, and converted base-unit groups. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.

Confirmation summaries now report `exec_overlap_wall_seconds`, the wall-clock time with at least two valid positive-duration intervals active. Each instant counts once; a 30-second triple overlap contributes 30 wall seconds but 60 excess seconds. Tests cover raw and base-unit groups, triple overlap, and touching intervals. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.


Confirmation summaries now report `exec_overlap_episode_count`, the number of distinct continuous stretches with at least two valid positive-duration intervals active. A positive-duration gap starts a new episode, while overlaps meeting at an endpoint remain one episode. Tests cover one triple-overlap episode and two overlap episodes separated by gaps. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.

Confirmation summaries now report `exec_peak_concurrency_secs`, the elapsed time at the group's observed maximum concurrency. Separate segments at the same maximum are summed; when a higher peak occurs, time accumulated at the lower peak no longer contributes. Groups without positive intervals report zero. Tests cover single intervals, triple overlap, zero-only data, touching intervals, and separated overlap episodes. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.

Confirmation summaries now report `exec_longest_overlap_secs`, the longest continuous stretch with at least two valid positive-duration intervals active. Separate overlap episodes are compared and only the longest is returned; touching, zero-duration, missing, and invalid intervals do not contribute. Tests compare raw and base-unit groups and separated overlap episodes. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.

Confirmation summaries now report `exec_overlap_avg_secs`, the arithmetic mean duration of separate overlap episodes, computed from total overlap wall time divided by episode count. It remains zero with no episodes and preserves fractional seconds. Tests cover 1,800-second and 901-second episodes with a 1,350.5-second mean. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.

Confirmation summaries now report `exec_longest_idle_gap_secs`, the longest uncovered segment between merged positive-duration intervals inside the execution envelope. Leading and trailing time, zero-duration rows, and nonpositive intervals do not set the gap. Tests cover cross-day gaps, zero-duration endpoints, touching intervals, raw/base groups, and a separate-gap fixture. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.
Confirmation summaries also report `exec_idle_gap_episode_count`, the count of internal gaps between merged positive-duration intervals. Leading and trailing time, touching intervals, zero-duration rows, and nonpositive intervals do not add gaps. Tests verify separated gaps and zero-gap groups across raw and base summaries. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.
Confirmation summaries now report `exec_idle_gap_avg_secs`, the arithmetic mean duration of internal gaps. It divides total internal idle seconds by the gap count, returns zero when there are no gaps, and retains fractional seconds. Tests include two gaps averaging 1.5 seconds. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.
Confirmation summaries now report `exec_interval_coverage_pct`, covered union as a percentage of the elapsed first-to-last positive interval span. Overlapping time counts once, results round to two decimal places, and groups without a positive interval report zero. Tests cover overlapping units, separated intervals, touching intervals, and zero-only data. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.
Confirmation summaries now report `exec_overlap_wall_pct`, overlap wall time as a percentage of the positive-interval envelope. Simultaneously active time counts once and results round to two decimal places. Tests cover separate units, triple and pair overlaps, separated episodes, and groups without overlap. Verification: transpilation, the full unit suite, and PLAN validation pass; abaplint remains at the existing 627-finding baseline.
Abaplint quick fixes removed 627 alignment findings from 11 ABAP files, and nine remaining parser-space findings were corrected. The source diff is whitespace-only. `npm test` now passes with zero lint issues across 252 files, followed by transpilation and the complete ABAP Unit suite.
Confirmation summaries now report `exec_single_active_seconds`, time inside the covered union when exactly one positive-duration interval is active. It partitions covered time with `exec_overlap_wall_seconds`; their sum equals `exec_covered_seconds`. Missing, invalid, and zero-duration intervals do not contribute. Tests cover raw and base summaries, unit separation, overlaps, touching intervals, and no-interval groups. Verification: `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.
Confirmation summaries now report `exec_single_active_pct`, single-active time as a percentage of the positive-interval span. It is rounded to two decimal places and partitions interval coverage with overlap wall percentage within 0.01 percentage point of independent rounding. Tests cover raw and base groups, touching intervals, overlap episodes, and empty execution data. Verification: `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.
Confirmation summaries now report `exec_single_episode_count`, the number of distinct continuous stretches with exactly one valid positive-duration interval active. Overlaps and uncovered gaps split stretches; touching intervals that preserve concurrency one do not. Tests cover separated stretches, overlap interruption, touching intervals, and empty groups. Verification: `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.
Confirmation summaries now report `exec_longest_single_secs`, the longest continuous stretch with exactly one valid positive-duration interval active. Overlaps and uncovered gaps split stretches, while touching intervals that preserve one active interval remain continuous. Tests cover all summary scopes, unit groups, touching and overlapping intervals, and empty duration data. Verification: `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.
Confirmation summaries now report `exec_single_active_avg_secs`, the arithmetic mean duration of single-active stretches, calculated from `exec_single_active_seconds` divided by `exec_single_episode_count`. It is zero without episodes and retains fractional seconds. Tests cover all summary scopes and unit groups, touching and overlapping intervals, fractional means, and empty duration data. Verification: `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.
Confirmation summaries now report `exec_high_concurrency_secs`, wall-clock time when at least three valid positive-duration intervals are active. Each instant counts once regardless of concurrency depth, and missing, invalid, and zero-duration intervals are ignored. Tests cover triple overlap, unit groups, two-way overlap, touching intervals, and empty execution data. Verification: `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.
Confirmation summaries now report `exec_3plus_episode_count`, separate continuous stretches with at least three valid positive-duration intervals active. Drops below three or uncovered gaps split episodes; touching intervals that preserve concurrency three do not. Tests cover three-way overlap, unit-level groups, two-way overlap, touching intervals, and empty data. Verification: `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.

Production confirmation summaries now report the longest and mean duration of separate three-or-more-way concurrency episodes. Initial regressions only asserted the mean when there was one episode, which could not distinguish it from the longest duration. A dedicated case now verifies two episodes with a fractional mean and an interval handoff at a shared endpoint. Validator, abaplint, transpilation, and full ABAP Unit checks pass.

A three-or-more-way concurrency percentage has been added to all confirmation-summary scopes. It divides time at concurrency three or higher by the first-to-last positive-interval span and rounds to two decimal places; zero-span groups return zero. PLAN validation, abaplint, transpilation, and the full ABAP Unit suite pass.

Confirmation summaries now split overlap wall time into exact-two and three-or-more concurrency durations, with corresponding shares of the positive-interval span. A test fixture includes a two-second tail at concurrency two after a three-way interval ends; its initial test expectation was corrected. Validation, lint, transpilation, and ABAP Unit pass.

Confirmation execution summaries now include pairwise overlap seconds and peak-concurrency percentage alongside interval coverage. Pairwise time weights each active interval pair independently; peak share uses the positive-span denominator. PLAN validation, abaplint, transpilation, and the full ABAP Unit suite pass.

Confirmation summaries now report average active-interval concurrency as valid elapsed duration divided by the first-to-last positive interval span. The value includes internal gaps and returns zero without a positive span. PLAN validation, lint, transpilation, and the full ABAP Unit suite pass.

Confirmation execution summaries now count distinct interval pairs with positive-duration overlap, once per pair regardless of overlap length. Endpoint-only contact and invalid or zero-duration intervals are excluded. PLAN validation, lint, transpilation, and full ABAP Unit pass.

Confirmation execution summaries now report mean overlap duration per intersecting interval pair, preserving fractional seconds and returning zero with no overlaps. PLAN validation, lint, transpilation, and full ABAP Unit pass.

Confirmation summaries now include the longest individual pair intersection and count, longest duration, and mean of episodes at the final peak concurrency. The pair duration is measured per intersecting pair; lower-level peak episodes are reset when a later higher peak is observed. PLAN validation, lint, transpilation, and full ABAP Unit pass.


Confirmation execution summaries now split valid interval statistics into
non-reversed and reversed groups while preserving the original gross totals.
Both groups report valid count, duration total and average, covered union,
overlap excess, and share of total valid duration. Counts include valid
zero-duration rows; unions do not. The work-center, unit, raw operation/order,
and base-unit regression marks one overlapping BOX confirmation reversed.
Verification: PLAN validation, abaplint, transpilation, and full ABAP Unit
pass.

Confirmation summaries now report `exec_duration_seconds_median`. It sorts
valid elapsed durations, includes zero-duration and reversed rows, averages
the middle two for even-sized groups, and returns zero for no valid duration.
The regression covers work-center, unit, operation, order, and base scopes as
well as a zero-only group. PLAN validation, abaplint, transpilation, and full
ABAP Unit pass.

Confirmation summaries now include `exec_duration_seconds_p90`, the
nearest-rank 90th percentile of valid elapsed durations. Zero-duration
and reversed confirmations participate; empty groups return zero. Tests
cover work-center, unit, operation, order, and base scopes.
PLAN validation, abaplint, transpilation, and full ABAP Unit pass.

Confirmation summaries now include `exec_duration_seconds_p95`, the
nearest-rank 95th percentile of valid elapsed durations. The regression
uses twenty one-minute-step confirmations to distinguish the 90th
percentile (1,080 seconds) from the 95th percentile (1,140 seconds).
PLAN validation, abaplint, transpilation, and full ABAP Unit pass.

Confirmation summaries now include `exec_duration_seconds_mad`, the
median absolute deviation of valid elapsed durations. It includes zero-
duration and reversed rows and is zero without valid durations. A 20-value
regression distinguishes a 300-second MAD from the median and percentiles.
PLAN validation, abaplint, transpilation, and full ABAP Unit pass.

Reversal-aware confirmation summaries now report separate medians for
non-reversed and reversed valid durations. Zero-duration rows count,
and empty subgroups return zero. Tests cover work-center, unit, raw
operation/order, base, and zero-only scopes.

Reversal-aware confirmation summaries now report nearest-rank p90 values
for non-reversed and reversed intervals. Zero-duration rows count,
and empty subgroups return zero. Tests cover unit, raw, base, 20-row,
and zero-only groups.
PLAN validation, abaplint, transpilation, and full ABAP Unit pass.

Reversal-aware confirmation summaries now report median absolute
deviation separately for non-reversed and reversed valid durations.
Zero-duration rows count; empty subgroups return zero. Tests cover
work-center, unit, raw operation/order, base, 20-row, and zero-only
groups.

Reversal-aware confirmation summaries now report separate nearest-rank p95 durations for non-reversed and reversed valid intervals. Zero-duration rows participate; empty subgroups return zero. The shared p95 helper feeds all seven summary scopes.

Reversal-aware confirmation summaries now report separate minimum and maximum valid elapsed durations for non-reversed and reversed rows. Valid zero-duration rows participate; empty groups return zero. Mixed-unit and base-unit regressions cover the summary paths.

Production confirmation summaries now expose gross and reversal-specific nearest-rank p99 execution durations. The shared calculation uses valid elapsed values, including zeros, and returns zero for empty groups. Tests cover the upper tail and each summary scope.

Confirmation summaries now report IQR as nearest-rank p75 minus p25 for gross, non-reversed, and reversed duration groups. Valid zero durations participate; empty groups return zero. Mixed-unit, base-unit, tail, and zero-only regressions cover the behavior.

Confirmation summaries now expose nearest-rank p25 and p75 durations for gross and reversal groups in addition to IQR. Zero-duration rows participate, and empty groups return zero. Mixed-unit, base-unit, tail, and zero-only regressions exercise the fields.

Confirmation summaries now count valid durations strictly above the gross and reversal-specific p95 thresholds and report each count as a share of valid duration rows. Ties at the cutoff do not count. Regressions cover a 5% gross exceedance and empty or reversal-split groups.

Confirmation summaries now include a dimensionless p95-to-median duration ratio for gross and reversal groups. Groups with a zero median return zero instead of dividing. Regression coverage includes skewed and zero-only duration sets.

Production confirmation summaries now report elapsed seconds above the gross and reversal-specific p95 thresholds and each tail sum as a share of all valid duration seconds. Ties at p95 are excluded. Zero-total groups return a zero share; the regression tail is 1,200 seconds or 9.52%.

Production confirmation p99 tail counts and duration shares use strict greater-than comparisons against nearest-rank p99. Percentages use valid-row counts; elapsed-time shares use each group’s summed valid duration, with zero-total groups returning zero.

Production confirmation p99-to-median ratios are dimensionless and use the same group's nearest-rank p99 and median. Empty groups or zero medians return zero.

Production confirmation p90-to-median ratios use the same group's nearest-rank p90 and median. They are dimensionless; empty groups or zero medians return zero.

Production confirmation p90 tail counts exclude values tied at nearest-rank p90. Count percentages use valid rows, and elapsed shares use each group's total valid duration; zero-total groups return zero.

Production confirmation IQR-to-median ratios are dimensionless and use each group's nearest-rank interquartile range divided by its median. Empty groups or zero medians return zero.

Production confirmation MAD-to-median ratios use the median absolute deviation and median from the same duration group. Ratios are dimensionless; empty groups or zero medians return zero.
Production confirmation average-to-median ratios divide each duration group’s arithmetic mean by its median. Ratios are dimensionless and return zero for empty groups or zero medians.
Production confirmation positive-only duration counts, medians, and p90s exclude valid zero-duration rows. Each reversal group uses its own values; empty positive-duration groups return zero.
Positive-only production duration p90-to-median ratios use each group’s own positive-duration p90 and median. They return zero when the group has no positive median.
Positive-only production p90 greater-than percentages divide by positive-duration counts. Tail seconds sum only rows above each positive-only threshold, and tail shares use group elapsed totals. Empty groups return zero.
Positive-only production confirmation p95 and p99 values use nearest-rank percentiles over strictly positive valid durations. Zero-duration rows do not affect their rank; empty groups return zero.
Positive-only production confirmation quartiles, IQR, and median absolute deviation exclude zero-duration rows and return zero for empty groups; normalized spreads return zero when the positive median is zero.
Positive-only production confirmation average durations use the valid elapsed-time total divided by positive-duration row count; mean-to-median ratios use the positive-only median and return zero for empty groups.
Positive-only production confirmation minimum, maximum, and range use strictly positive valid durations; empty groups return zero.
Positive-only production confirmation p95 and p99 tails sum only positive durations strictly above their nearest-rank threshold; ties are excluded, and percentages use positive-only row and elapsed-second totals.
Positive-only production confirmation p95 and p99 median ratios compare each cohort with its positive-only median and return zero when that median is zero.
Positive-duration percentages use all confirmations in the corresponding gross, non-reversed, or reversed cohort as the denominator, so zero, missing, and invalid duration rows remain represented.
Positive-duration valid shares divide positive interval counts by valid interval counts; invalid and missing duration rows are excluded, and empty valid groups return zero.
Zero-duration valid shares divide zero interval counts by valid interval counts for gross, non-reversed, and reversed groups; empty valid groups return zero.

The Open ABAP transpiler emits an invalid SQL host expression for
`@is_selection-material` in the planned-order finish-window query. Assigning
the component to typed local `lv_material` first avoids the malformed output;
the special-procurement finish-window regression verifies the filtered rows.


Local, cross-plant, and location date-first allocation now expose one-based `allocation_sequence` values in calculation order. Cross-plant source and location rows and local storage-location splits echo their demand rank; single-request, UOM, and ATP local estimates preserve ranks while summaries retain caller order. Regression coverage includes earlier-date precedence, same-date priority, and zero-allocation demands. The regression suite is not executable in this WSL 1 environment: the Windows Node launcher fails before npm starts.


Cross-plant dated FEFO and exact-batch allocation now expose one-based allocation sequences on demand summaries, source-plant rows, and emitted splits. The date-first UOM and ATP local estimates retain these ranks. Regression assertions cover caller-order summaries, date and priority precedence, source and split propagation, and zero-allocation demands. Validation remains blocked in this WSL 1 environment: `npm test` stops before Node starts with "WSL 1 is not supported" and "Could not determine Node.js install directory".


WBS date-first location and transfer previews now return one-based allocation sequences on demand summaries, location or batch splits, and assignment rows. ATP local estimates preserve the trace, including repeated caller IDs. Regression assertions cover date and priority order and wrapper propagation. The project validation runtime remains unavailable because the WSL 1 Node launcher fails before npm starts.


Sales-order aggregate and FEFO issue previews now expose demand processing sequences, and FEFO batch splits echo their demand rank. Base and UOM results retain caller order while preserving the sequence. Static contract checks passed. Full validation could not start: the direct Windows Node executable exits with WSL `UtilBindVsockAnyPort` error in this WSL 1 environment.


`npm test` attempts for the production-component trace-scope and date-first coverage-floor status changes on 2026-10-21 failed before Node started: the installed Windows Node launcher reports that WSL 1 is unsupported. PLAN validation, abaplint, transpilation, and ABAP Unit remain unavailable for the component and date-first rejection-status changes. Focused source-contract checks and CRLF-aware `git diff --check` passed.

Valuation-type allocation outcomes now include full, partial, and unallocated
codes plus base-unit coverage percentages. Regression assertions were added
for all outcome classes and UOM/ATP propagation. PLAN validation, abaplint,
transpilation, and ABAP Unit could not be run in this WSL 1 environment because
the installed Node launcher fails before starting Node.

WBS priority FEFO, batchless location, and transfer priority previews now
expose `allocation_sequence` on their outer summary, split, and assignment
rows. The rank is copied from the underlying shared-stock result, so the
priority wrappers and their ATP local estimates retain the same caller-order
view of processing order. Source-contract validation covers these mappings
and the PLAN/README documentation. Runtime ABAP validation remains
unavailable because the installed Node launcher rejects WSL 1.

WBS FEFO and location allocation summaries now set the existing
`minimum_coverage_rejected` field from final base-unit quantities. This
correctly reports all-or-none rows whose final zero allocation falls below
a positive floor, while a zero floor remains false. Priority, dated,
transfer, and ATP wrappers preserve the nested status. Runtime ABAP
validation remains unavailable because the installed Node launcher rejects
WSL 1.

Base WBS FEFO and location previews now assign ranks to their demand
summaries and emitted unit splits in processing order. Priority wrappers sort
rows before invoking those allocators, so the same base rank carries through
priority and transfer results. The two WBS allocators also now calculate
`minimum_coverage_rejected` from final allocated quantities, including strict
full-quantity rejections below a positive floor.

Base WBS FEFO and location assignment rows, plus base FEFO and location
transfer assignment rows, now expose the same caller-order sequence as their
demand summaries and splits. Priority, date-first, transfer, and ATP adapters
preserve the rank in their caller-facing result rows.

WBS regression coverage now checks base and priority `allocation_sequence`
values across summaries, splits, assignments, and ATP local estimates. The new
floor-status case covers FEFO full-quantity rejection below a positive floor,
location and transfer floor rejection, and zero-floor partial allocation. `npm test` was
attempted but stopped before PLAN validation: its launcher reports that WSL 1
is unsupported and cannot determine the Node.js install directory.

The 2026-10-21 npm test attempt after adding WBS floor-rejection stock-reuse regressions again stopped before validation. The WSL 1 npm launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory. Focused source-contract assertions and CRLF-aware git diff checks pass; abaplint, transpilation, and ABAP Unit did not start.

Validation update (2026-10-21): abaplint quick fixes applied 64 alignment edits. `npm run lint` now passes with 0 issues across 252 files, and `npm run transpile` succeeds after correcting the sales-order parser spacing, test result paths, and related type errors. Added date-first WBS FEFO/location and transfer ATP floor-rejection stock-reuse coverage. `npm test` and `npm run validate:plan` still fail before Node starts because the Windows Node launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory. ABAP Unit and the PLAN validator did not run.
Final 2026-10-21 validation after the STO stop-on-failure regression hit the same WSL 1 launcher error in `npm test`. The latest `npm run lint` and `npm run transpile` completed successfully; the PLAN validator and ABAP Unit still did not start.

The 2026-10-21 `npm run validate:plan` attempt after adding document-level sales-order summaries stopped before Node startup. The launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory.

The 2026-10-21 `npm run validate:plan` attempt after adding document summaries to bulk reservation rows again stopped before Node startup. The WSL 1 launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory.

The 2026-10-21 `npm run validate:plan` attempt after adding cross-order material summaries again stopped before Node startup. The WSL 1 launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory.

The 2026-10-21 npm run validate:plan attempt after adding sales-order summary date counts and allocation-sequence scopes stopped before Node startup. The WSL 1 launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory.

The 2026-10-21 npm run validate:plan attempt after adding sales-order floor-rejected-line percentages stopped before Node startup. The WSL 1 launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory.

The 2026-10-21 npm run validate:plan attempt after adding required-date spans and allocation-rank metadata to sales-document summaries stopped before Node startup. The WSL 1 launcher reports that WSL 1 is unsupported and cannot determine the Node.js install directory.

Validation follow-up (2026-10-21): the full `npm test` pipeline now passes via
the native Windows Node execution path. ABAP Unit exposed three regressions:
the stock test double omitted valuation type from synthesized batch statuses,
the dated location UOM adapter dropped allocation sequence from storage-split
wrappers, and manufacturing-age assertions disagreed with expiry ordering and
the report horizon. The double projection and UOM adapter are fixed; tests now
follow the established priority and expiry ordering and include the relevant
expiry window. PLAN validation, abaplint, transpilation, and ABAP Unit all pass.
The regular WSL 1 npm launcher still fails before Node startup.
