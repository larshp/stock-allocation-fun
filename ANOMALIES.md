# Anomalies

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
Local tests use a fake repository and cannot validate the target release's PLAF
DDIC fields, SQL behavior, planned-order lifecycle, conversion ratios, or live
selection results. SAP describes the selection
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

Sales-order reservations call `BAPI_RESERVATION_CREATE1` with movement type
231, ATP check enabled, and sales-order/item assignment. Verify BAPI
availability, signature, movement-type behavior, and ATP/customizing results
in the target release. The local stub covers only fields used by the adapter
and is not a replacement for that system's DDIC definition.

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
result. `preview_for_cost_center` uses the local stock estimate by default. Its
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

Order allocation subtracts active movement type 231 reservations from
`RESB-BDMNG - RESB-ENMNG`, grouped by material, plant, item, schedule line,
and requirement date for the sales order. It uses schedule-line and date keys
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

Reservation release calls `BAPI_RESERVATION_DELETE` once per reservation
number inside one BAPI transaction. SAP controls whether a reservation can be
deleted, including reservations already partly or fully issued. Verify the
BAPI signature and deletion behavior in the target release; local tests use
an API double and do not exercise SAP reservation status rules.

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
local tests use an API double and do not validate live reservation records.

Production-order component inquiry reads open reservation items from `RESB`
using `AUFNR`, `RSNUM`, `RSPOS`, `BDMNG`, and `ENMNG`, while returning the
reservation unit, movement type, date, location, and batch. Bulk inquiry uses a
guarded `FOR ALL ENTRIES` read for a unique production-order list.
`ISSUE_COMPONENTS` and `ISSUE_COMPONENTS_BULK` validate selected keys and
quantities against those open rows, then use the reservation detail read and
goods-movement APIs. Local service tests use repository and API doubles; they do
not execute the query or validate BAPI signatures and field behavior against
the target release. Production orders normally generate their component
reservations automatically, so this service exposes and issues those existing
reservations instead of creating duplicates.

Reservation issue posting calls `BAPI_GOODSMVT_CREATE` with GM code 03 and
reservation number, item, record type, blank movement indicator, quantity,
entry unit, and the detail item's ISO base unit. Movement type, material, and
plant are intentionally omitted so SAP derives them from the reservation.
The adapter maps these fields, but the transpiler tests cannot execute the
function module. Verify the BAPI signature, unit handling, reservation status
checks, and optional storage-location/batch behavior in the target release.
All goods movement requests now require both the SAP entry unit and its ISO
code. The local tests use `EA` for both fields; verify configured unit mappings
and required fields in the target release.

Purchase-order goods receipts and returns use `BAPI_GOODSMVT_CREATE` with GM
code 01, movement types 101 and 122 respectively, movement indicator `B`,
purchase-order number/item, quantity, and entry unit. Material, plant, and
storage location may be derived from the PO item. Verify optional-field
behavior, PO item numbering, return eligibility, and adapter field mapping in
the target SAP release. The test suite uses a fake API and does not exercise a
live PO or the BAPI signature ([SAP BAPI movement field
requirements](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html),
[goods movement types](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/ee6ff9b281d8448f96b4fe6c89f2bdc8/8b7b5fe73ef54063a2bfcfbe83cebd38.html)).

Production-order goods receipts use `BAPI_GOODSMVT_CREATE` with GM code 02,
movement type 101, movement indicator `F`, production order, quantity, and
entry unit. Material, plant, and storage location may be derived from the
production order. Verify optional-field behavior and order numbering in the
target SAP release; the test suite uses a fake API and does not post a live
production receipt ([SAP BAPI movement field requirements](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html)).

Production component ATP preview groups open `RESB` quantities from the
supplied production orders by material, plant, base unit, and required date.
It converts reservation units with the material `MARA`/`MARM` ratio and sends
cumulative quantities through each date to the availability BAPI. The raw ATP
result and confirmed/unconfirmed cumulative quantities repeat on components
sharing a group. A separate local dated allocation estimate is also returned for
each material/plant/base-unit/date group, with optional PO/STO/production
receipts, unissued STO subtraction, and static safety-stock protection. This
projection follows the local stock repository's date rules and is not SAP ATP.
The preview also splits each date-group local allocation across component rows
in production-order/reservation/item order; that priority is a local preview
policy, not SAP component selection or picking.
`SUMMARIZE_COMPONENT_READINESS` aggregates those local component splits by
order, rejects incomplete or duplicate reservation keys and inconsistent
quantity splits, and does not infer an order-level SAP ATP status. A ready flag
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

Other procedures, including `FX` without a positive fixed quantity, `HB` without
a positive maximum stock quantity, and incompatible `EX`/`MB`/`WB`/`PK` limits, leave
the shortfall exact and return `policy_origin = UNSUPPORTED`. A missing MARC row
returns the exact shortfall with `policy_origin = NONE`. Caller policies without
`lot_size_procedure` continue to treat their minimum, fixed quantity,
and order multiple as direct rules. Unit mismatches, duplicate
policies/shortage keys, and inconsistent quantities are rejected. Multiple
due-date rows remain separate except for `MB` rows in the same material,
plant, and unit/month, `WB` rows in the same material, plant, and unit/week, and
`PK` rows in the same material, plant, and unit/planning-calendar period.

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
The local EINA/EINE/MARC/EORD/EQUK/EQUP/TMQ2 stubs are partial, and local tests use a repository
double rather than executing the table queries. Verify field availability,
deletion and blocking semantics, and SQL behavior in the target SAP release.
Pass a source only after the host application has selected it. Vendor calendars,
goods receipt capacity, and MRP scheduling margins are not modeled. The
estimate is indicative and does not create or reserve stock or a purchasing
document. Local tests do not execute the MARC/MARA/T001W/T399D query or
factory-calendar function modules; verify field availability, join keys,
function parameters, and dates against the target SAP release.

`ZCL_REPLENISHMENT_REQ_SERVICE` creates requisitions from positive suggestions
through `BAPI_PR_CREATE`, one PR item per planned lot. It validates that lot
count, final-lot quantity, and total suggestion reconcile before calling SAP.
For a fixed-lot suggestion carrying a rounding profile, it validates the total
against the rounded final receipt quantity and sends that rounded quantity on
each item.
Covered zero-quantity rows are skipped. `iv_test_run = abap_true` invokes the
BAPI simulation path and skips commit; normal writes commit only after a
successful BAPI response with a requisition number, and roll back errors. The
service passes material, plant, base unit, required date, and optional
purchasing group/organization. It only accepts explicit external procurement
(`MARC-BESKZ = F`) with no special procurement key; in-house, ambiguous,
special-source, and missing procurement routes are rejected before the BAPI
call. It does not select a vendor or source of supply, create account
assignments, or create services/non-stock items. When the caller has resolved a
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
SAP documents `BAPI_PR_CREATE` as the supported Enjoy requisition
interface and recommends committing successful BAPI writes with
`BAPI_TRANSACTION_COMMIT` ([purchasing BAPIs](https://help.sap.com/docs/SUPPORT_CONTENT/spmm/3362167428.html));
its BAPI guide defines `TESTRUN = 'X'` as simulation without database updates
([test-run behavior](https://help.sap.com/saphelp_aii710/helpdata/en/df/0495dbbd6f11d1ad09080009b0fb56/content.htm?no_cache=true)).

The policy lookup also returns raw `MARC-BESKZ` procurement type and `SOBSL`
special procurement key so the caller can route a suggestion. Standard material
master procurement types distinguish in-house (`E`), external (`F`), and both
(`X`); special procurement keys depend on system customizing ([SAP procurement
types](https://help.sap.com/docs/SAP_S4HANA_CLOUD/c0c54048d35849128be8e872df5bea6d/050d78ed8b954b308256fa86506fc938.html),
[SAP special procurement](https://help.sap.com/docs/SAP_ERP_SPV/85d3fce10e264972a0155c8b46ecf93b/8d1eba53422bb54ce10000000a174cb4.html)).
The service does not resolve vendors, source lists, quota arrangements, or
source-of-supply priorities.

The lot-size procedure controls which master settings SAP considers: SAP
documents minimum lot size, maximum lot size, and rounding for lot-for-lot
planning, while fixed lot sizing is a separate procedure ([SAP lot-sizing
procedure](https://help.sap.com/docs/PRODUCT_ID/cd9e0c364e1e41e19ea633db7862222e/e52ec95360267614e10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=7.0.3),
[SAP fixed lot size](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/f899ce30af9044299d573ea30b533f1c/4e30c95360267614e10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=2023.latest),
[SAP rounding and maximum-lot splitting](https://help.sap.com/saphelp_SCM700_ehp01/helpdata/en/be/30c95360267614e10000000a174cb4/content.htm?no_cache=true)).
This suggestion API models `EX`, `FX`, `HB`, calendar-month `MB`, weekly `WB`,
and planning-calendar `PK` from resolved plant/calendar periods. Unless callers
pass their own periods, the service reads overlapping `T439I` rows for the
requested horizon using `MARC-MRPPP`. Static `MARC-RDPRF` profiles are read
from `RDPR` and applied to each modeled receipt after lot sizing; a rounded
receipt above maximum lot size is rejected. The service does not generate or
extend calendar periods, and it does not model other period intervals,
automatic source determination, or MRP area settings. SAP documents lot sizing
before rounding and threshold-based static profiles ([procurement quantity
calculation](https://help.sap.com/docs/SAP_ERP_SPV/85d3fce10e264972a0155c8b46ecf93b/dca5bb53707db44ce10000000a174cb4.html),
[static rounding profiles](https://help.sap.com/docs/SAP_ERP/85d3fce10e0e1416d83c0fdfa4060189d/f597b6535fe6b74ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest)). SAP documents planning calendars as flexible
period lengths that group proposals falling within each period ([SAP planning
calendars](https://help.sap.com/docs/SAP_ERP/85d3fce10e264972a0155c8b46ecf93b/f1f8c0534b22b64ce10000000a174cb4.html)).
The week-start weekday can be set by the caller; validate the matching week
definition and planning-calendar behavior in the target SAP configuration.
Source-specific planned delivery time is used only when the caller
provides a pre-resolved purchasing info record. Local lint/transpilation does not execute the
MARC/MARA, `T439I`, or `RDPR` queries against an SAP system; verify table/field
availability and SQL behavior against the target release before deployment.
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
repository read. Local tests use fake stock and UOM repositories; verify unit
ratios, both fields, and the aggregate query against the target SAP release
([SAP stock in transfer fields](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362168094.html)).
The batch inquiry reads `MCHB-CUMLM` for nonzero storage-location transfer
balances and returns them by batch and location. SAP lists this field as stock
in transfer between storage locations ([SAP stock types](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167795.html)).
The local MCHB stub and tests cover only the required field and service mapping;
verify the query and unit semantics against the deployed release.

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

Exact-batch cross-plant allocation uses the repository's `MCHB-CLABS` and
`RESB` availability estimate and preserves the requested batch across source
plants. It does not run SAP batch determination or check transfer configuration;
verify batch, source location, and any subsequent goods movement in the target
system. The alternative-unit variant converts through `MARA`/`MARM` and rounds
source-unit output to the quantity field's precision; the base-unit splits are
canonical. Local tests use repository doubles.

Cross-plant FEFO allocation applies the caller's source-plant order first, then
orders eligible batches by expiration date within each plant. It uses the same
local `MCHB`/`MCHA`/`MCH1` and `RESB` stock estimate and eligibility rules as the
single-plant FEFO preview. `ALLOCATE_PLANTS_FEFO_IN_UNITS` converts its demand
through `MARA`/`MARM` and returns canonical base-unit batch splits alongside
rounded source-unit quantities. This selection does not run SAP batch
determination, check transfer configuration, or validate a subsequent goods
movement. Local tests use repository doubles; verify batch determination,
source-plant priority, conversion factors, and any transfer process in the
target system.

`ALLOCATE_PLANTS_FEFO_BY_DATE` gives earlier required dates first use of shared
batch balances, applies the minimum remaining shelf life against each demand's
required date, and then consumes source plants in caller order with FEFO within
each plant. Higher caller priorities allocate first among same-date demands;
required date remains the primary order and input order breaks equal-priority
ties. Priority also appears on the demand, source, and batch split previews.
Static safety stock is withheld from latest-expiring stock eligible for the
earliest compatible demand. Undated batches qualify only when the minimum is
zero and sort after dated batches. It uses current `MCHB`/`RESB` estimates; it
does not add dated PO/STO/production receipts or invoke SAP's configured batch
strategy. SAP supports dynamic shelf-life criteria based on delivery dates
([dynamic date determination](https://help.sap.com/docs/SAP_ERP/3db8848948314edeabbea684714e1055/f8fdb753128eb44ce10000000a174cb4.html));
verify the local required-date policy against the target process before posting
the returned splits.
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
303/305 transfer paths and validate material base units. Local tests use a
goods-movement double; verify UOM mappings, batch fields, movement configuration,
and transfer behavior in the target SAP release.

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

Material-document cancellation uses `BAPI_GOODSMVT_CANCEL` for the full
document or selected items, identified by material document number and fiscal
year. An optional posting date is supplied for the reversal; when blank, SAP
applies its default. SAP determines whether the original document or item is
eligible for cancellation. The local tests cover service behavior only; verify
the function signature, `BAPI2017_GM_ITEM_04` item-field mapping, posting-date
default, cancellation eligibility, and returned reversal document in the target
release. SAP documents item-level cancellation in its [Material Document
API](https://help.sap.com/docs/SAP_S4HANA_CLOUD/3f57e7df4a114edabffe8b2d581a59ed/1aef4e402acd4c8b8ec2ea2bfda7715b.html).

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
batch selections still must cover every open schedule line or use one item-wide
selection. Batch-managed split valuation uses the supplied batch.
Non-batch-managed split valuation by valuation type (`BWTAR`) remains
unmodeled. Reservations missing a location or batch are distributed across
matching balances in ascending location and batch order.
When an over-reservation exceeds the matching balances, the remaining deficit
is distributed across other positive balances in that order, a conservative
estimate rather than SAP's ATP result.
Sales order open demand now uses `VBEP-WMENG - VBEP-VSMNG` and the item status
from `VBUP-LFSTA`, with requested dates from `VBEP-EDATU`. Order items without
schedule lines fall back to `VBAP` quantities and use the current date when
reserved. The opt-in `iv_use_confirmed_qty` mode uses `VBEP-BMENG - VBEP-VSMNG`
clamped to the ordered open quantity, and rejects open item-level fallback rows
without schedule-line confirmation data. Confirmed delivery dates are not read.
Local tests verify calculations and service behavior with doubles; they do not
execute the database queries or prove that the target system's BAPI updates the
fields in the assumed way. Verify `VBEP-BMENG` availability and conversion on
the target release. The sales-order adapter also retains the BAPI's
`BAPISDIT-SALES_QTY1/SALES_QTY2` conversion ratio so allocation results can show
quantities in both the sales unit and material base unit. Local tests verify
the ratio mapping with doubles; confirm these fields, conversion direction, and
quantity rounding on the target SAP release.

Without an explicit location choice, location-aware allocation consumes
available `LGORT` balances in ascending code order because no warehouse picking
strategy is configured. Open reservations without `LGORT` are deducted from
the first available locations in that order. A sales-order location choice is
a hard restriction by default; callers may opt to use it as the first
preference and fall back to other locations in ascending code order. The
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
fake repository and do not exercise the `MARC` query or target-system ATP
configuration ([SAP safety stock in availability checking](https://help.sap.com/docs/PRODUCT_ID/32da8359c8ee4e8b8e8c5e15cacba5aa/741d645473c50d4ee10000000a423f68.html).

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
there; the plant-level safety-stock adjustment is reported separately. Tests
exercise service delegation and the pure safety-stock calculator, not the
MARD/RESB/MARC database reads or live stock values. Batch status reports
`MCHB-CLABS`, batch expiration date, and available quantity after the batch
reservation calculator; its service tests do not execute the MCHB/MCHA/MCH1 or
RESB queries. These estimates are not SAP's complete ATP calculation.

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
Rows with nonpositive conversion ratios are ignored. Local tests use repository
doubles and do not execute the `EKET`/`EKPO` join or validate it against live
purchasing data, so confirm field definitions and filters in the target SAP
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
target-system filters, so confirm these against live STOs. Local tests use
repository doubles and do not execute the `EKET`/`EKPO`/`EKKO` query.

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
from released production-order items (`AFPO-PSMNG - AFPO-WEMNG`) with a goods
receipt expected, due by the order's basic finish date (`AFKO-GLTRP`). It
restricts to production-order category 10, excludes deleted, delivery-complete,
make-to-order, and account-assigned items, and ignores orders outside the
released phase or already completed/closed. Quantities are converted to the
material base unit with `AFPO-UMREZ/UMREN`. SAP documents `GLTRP` as the basic
finish date and `PSMNG`/`WEMNG` as order quantity and received quantity
([production-order header fields](https://help.sap.com/docs/SAP_PROFITABILITY_PERFORMANCE_MANAGEMENT/7fa13890d47b4c69bbb62175e84e4aa8/76029ca2ca28471e97fd73d0ffed318f.html),
[production-order item fields](https://help.sap.com/doc/63369768645a4883b468546b2c122b23/3.19/en-US/Sample%20Content%20Process%20Mining%20on%20SAP%20S4HANA%20Production%20Planning.pdf)).
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
When `iv_include_pr_receipts` is true, both APIs also return purchase
requisition items due by the requested horizon. The query subtracts ordered
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
release; local repository tests use a fake and do not execute the query.
Treat this projection as planning supply, not confirmed inbound supply.
The dated stock-allocation methods accept the same opt-in flag and add the
projected PR amount to their local available quantity. The scalar stock
estimate does not retain PR document trace rows, and combining it with an ATP
preview does not send the PR data to SAP or change the ATP result. Local tests
verify flag propagation and arithmetic with a repository double; they do not
execute the `EBAN` query. Component stock/ATP previews and multi-sales-order
dated preview/reservation methods also carry the flag through to that local
estimate. A reservation based on future PR supply is still subject to the live
BAPI and ATP checks; the projection itself does not reserve or confirm inbound
stock.
Stock-transfer requisitions are selected separately with
`iv_include_sto_pr_receipts`: the query requires item category 7 and a nonblank
`EBAN-RESWK` that differs from the receiving `EBAN-WERKS`, returns source type `STO_PR`, and retains `RESWK` as
`source_plant`. SAP documents purchase requisitions as stock-transfer
documents and describes the stock-transfer requisition item category
([stock transfer in Purchasing](https://help.sap.com/docs/SAP_ERP/b704a8db767040a08100adc846218964/0f62bd534f22b44ce10000000a174cb4.html?locale=en-US&state=PRODUCTION&version=6.18.latest),
[requirement coverage filters](https://help.sap.com/docs/SCMCSCPP/b654ceec39734aca96c6d395cdc7c69f/f39d21900a69431c9a71f12ea897ccc4.html)).
The remaining quantity still uses `MENGE - BSMNG` and the requested delivery
date. It excludes the same deleted, completed, blocked, account-assigned, and
special-stock items, and does not check release status, supplying-plant
availability, or transfer execution. Verify `RESWK`, item-category values, and
the conversion behavior in the target release.
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
It continues after an issue failure and returns per-pair issue-attempt and
in-transit status; earlier PO issues remain committed if a later one fails.
Test-run mode validates and simulates each eligible PO issue without marking
stock in transit. Tests use API doubles and cannot confirm a live multi-PO BAPI
sequence or concurrent STO changes.

`ZCL_GOODS_MOVEMENT_SERVICE->RECEIVE_ISSUED_STO` and
`RECEIVE_ISSUED_STO_PAIRS` accept a prior non-simulated issue result and prepare
a 101 receipt only for pairs still marked in transit after a successful 351.
All eligible receipt items are
validated before the first BAPI call. Each PO receipt commits independently;
a failed receipt remains in transit while later PO receipts continue. A receipt
test run does not clear in-transit status. The service trusts the supplied issue
result, and SAP remains responsible for rechecking PO history, quantities,
batches, receiving locations, and posting-period rules. API-double tests do not
verify a live 351/101 sequence.

`ZCL_GOODS_MOVEMENT_SERVICE->CANCEL_ISSUED_STO` and
`CANCEL_ISSUED_STO_PAIRS` call `BAPI_GOODSMVT_CANCEL` for the complete material
document from each committed 351 result marked in transit. They validate every
eligible material-document/year pair before canceling, then process each PO
document independently. Cancellation is not simulatable through this API; a
failed reversal keeps the pair marked in transit and does not stop later
documents. This state comes from the caller's prior issue result and may be
stale if another process has since posted a receipt or changed the document.
SAP selects the reversal movement type and checks document history and current
stock; local doubles cannot establish live cancellation eligibility.

`ZCL_GOODS_MOVEMENT_SERVICE->CANCEL_RECEIVED_STO` and
`CANCEL_RECEIVED_STO_PAIRS` reverse committed 101 receipt documents from prior
receipt results. They prevalidate all eligible receipt material-document/year
keys, cancel documents independently, and restore the pair's local state to
in-transit only after a successful reversal. Callers can then reverse the
original 351 issue separately. The result trusts its supplied receipt state;
SAP validates the document history, posting period, and current stock. The
cancellation API has no test-run mode, and local doubles do not verify live
101/102 cancellation behavior.

`CANCEL_STO_RECEIPT_CHAIN` and `CANCEL_STO_RECEIPT_CHAIN_PAIRS` coordinate the
101 reversal and then the original 351 reversal for each received pair. Both
movement document/year keys are validated before the first cancellation. If
101 reversal fails, that pair remains received; if 351 reversal fails after a
successful 101 reversal, the pair remains in transit. Each BAPI cancellation
commits independently, so a failure on one pair does not undo completed work
on earlier pairs. The operation reverses material documents; it does not delete
or close the STO purchase order. Local doubles cover sequencing and result
state, not live SAP eligibility or concurrency.

`ZCL_STOCK_XFER_ORDER_SVC->MARK_STO_FOR_DELETION` and
`MARK_STO_PAIRS_FOR_DELETION` use `BAPI_PO_CHANGE` to set the item deletion
indicator on submitted STO items after a committed creation result. This is a
logical deletion mark; SAP retains the purchasing document and determines
whether its history, authorization, and configuration permit the change. The
local stubs and API doubles do not validate the target release's exact
`BAPIMEPOITEM`/`BAPIMEPOITEMX` signature or eligibility behavior. SAP's example
uses `DELETE_IND` with the corresponding item-X data
([BAPI_PO_CHANGE example](https://help.sap.com/docs/SUPPORT_CONTENT/home/3361892108.html?locale=en-US)).
Validate this on representative STOs in the target system. Reversing 101/351
material documents by itself does not set the PO deletion indicator.

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

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_SOURCE_PLANTS` builds one STO per
supplying plant for a selected receiving plant. It validates all payloads
before calling the BAPI, but each resulting order is a separate transaction;
one supplier can commit even if a later supplier's BAPI call fails. The result
retains each supplier's order status and submitted items, and the aggregate
success flag is false if any order fails. The method does not reserve stock or
provide all-or-nothing processing across the independent purchase orders.

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FOR_ALL_PLANT_PAIRS` extends STO creation
across every positive source/target pair in a dated unit-aware allocation.
Receiving storage locations are supplied by target plant; a missing entry is
sent blank so SAP can apply order/configuration defaults. Duplicate mappings
and mappings for targets without allocations are rejected before BAPI calls.
Pair requests are all prepared before the first write, but each purchase order
commits independently and cannot be rolled back as one batch. Local tests use
API doubles and do not verify the target release's allowed plant/company-code
combinations or storage-location defaults.

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
independently. A shared delivery date is required and target storage-location
maps follow `CREATE_FOR_ALL_PLANT_PAIRS` behavior. API-double tests verify
batch grouping and no writes when a later pair is invalid; they do not confirm
the target system's BAPI or batch customizing behavior.

`ZCL_STOCK_XFER_ORDER_SVC->CREATE_FOR_FEFO_PAIRS` preserves every positive
dated FEFO batch/location split as a separate PO item, including the issuing
storage location (`SUPPL_STLOC`). The source-unit split quantity and required
date become the item quantity and schedule date. This reflects the reviewed
allocation only: it does not reserve stock, and SAP documents that STO
availability checks do not check batch stock if a batch was entered. Recheck
availability before goods issue; local tests use an API double and cannot
confirm target-system BAPI handling of `SUPPL_STLOC` and batch.

## Resolved

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

`GET_VALID_OUTLINE_SOURCES` reads source-list-linked purchase contracts and
scheduling agreements by joining `EORD` to `EKKO` and `EKPO`. The local stub
now models the required header fields and the service filters categories K/L,
source-list and agreement validity, blocked entries, deletion indicators,
completed items, and conflicting source-list/header vendors. Unit tests use a repository double; they do not execute this
join or confirm that target-system releases, item categories, or source-list
blocking semantics match the local assumptions. SAP identifies K as purchase
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
The repository query is not executed by local repository-double tests; validate
field availability, item-selection rules, and sample quantities in the target
SAP release before using these advisory receipts for procurement decisions.
The dated stock-availability method now aggregates this source through the same
projected-receipt query when its flag is enabled. Its value affects local stock
allocation estimates only; ATP requests and SAP's ATP result remain unchanged.
Local tests cover flag propagation with repository doubles, not the live SQL.

`ZCL_PROD_COMP_SERVICE->RETURN_COMPONENTS` posts partial reservation-backed
returns with goods movement code 06 and the `XSTOB` reversal flag. The service
requires movement type 261 on the production component and caps the quantity at
the withdrawn balance reported by both `RESB-ENMNG` and
`BAPI_RESERVATION_GETDETAIL1`. SAP derives the reversal type from the
reservation. Local tests use doubles and cannot verify the target release's
BAPI field mapping, whether the BAPI detail's withdrawn quantity reflects prior
returns, or how final-issue reservations behave during reversal; validate these
cases with representative documents before rollout.

`ZCL_PROD_COMP_SERVICE->CANCEL_COMPONENT_ISSUE` calls
`BAPI_GOODSMVT_CANCEL` for a supplied material document and fiscal year, with
optional item numbers. It can reverse selected full document lines or the whole
document; it does not read the document to prove that it came from
`ISSUE_COMPONENTS`, and callers should pass the issue result's document. SAP
validates cancellation eligibility and posting-period rules. The local test
double covers routing and commit handling only.
