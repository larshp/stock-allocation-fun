# Anomalies

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

Plant-date availability sums location balances, receipts, and reservations in
high precision before converting the final result. Totals outside MARD-LABST
range raise the request exception through the stock repository interface.

Scalar unrestricted availability now nets MARD and open RESB quantities in
high precision before converting the nonnegative result to MARD-LABST. An
available total outside that field range raises the stock-request exception.

Repeated scoped receipts now update location and batch balances with checked
high precision addition; totals outside those fields raise the stock-request
exception.

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
succeeded. Local tests verify that the service makes one commit and requests a
rollback on a ticket or commit error, but the SAP BAPI and automatic goods
movement update tasks are not exercised locally. Verify in the target release
that repeated time-ticket calls share one rollback-capable SAP LUW and that
automatic goods receipts or backflushes follow the same transaction boundary.
Its `iv_test_run` option issues those BAPI calls and then rolls back the LUW;
this is not a BAPI simulation flag, so verify that the target system's exits
and enhancements do not produce external effects before relying on it as a
no-write simulation.

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
and do not lock or reserve that stock. The
one-call WBS FEFO and location reservation methods rerun the same allocation
preview before creating reservations and reject the write if the full batch or
location split changes, including FEFO expiry order and location priority. SAP
does not lock these rows during that check, so another process can still
consume stock between the second preview and the write.

`ALLOCATE_DEMANDS_BY_PRIORITY` and `ALLOCATE_DEMANDS_UOM_PRIORITY` sort local
bulk demand by descending integer priority, then by input order for ties. They
require unique request IDs to restore caller order in the result and report the
priority used for each allocation. Priority only changes this preview's
calculation order; it does not lock stock, reserve it, or request an SAP ATP
confirmation.
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
priority order and return rows in caller order. The FEFO form works on
batch-managed stock; the location form works on batchless stock. The transfer
forms `PREVIEW_TRANSFER_FEFO_PRIORITY` and `PREVIEW_TRANSFER_LOC_PRIORITY`
apply that order to shared source-WBS stock and echo source/destination WBS
assignments. All four support repeated caller request IDs by correlating each
row with an internal ID; consumers that need to join individual rows should
retain a separate row key. Priority affects the local `MSPR`/reservation
snapshot: it does not lock or reserve stock, include future receipts, or post a
transfer. `PREVIEW_TRANSFER_FEFO_PRIO_ATP` and
`PREVIEW_TRANSFER_LOC_PRIO_ATP` add grouped plant-level diagnostics for positive
allocations by material, plant, base unit, and check date (default
`sy-datum`). They preserve caller-order local results and do not confirm
special WBS stock or a specific batch or storage location. Local tests use an
availability API double; verify the check rule and confirmations in the target
SAP system.

Unit-aware stock allocation converts demand to `MARD-LABST` precision before
reading stock. Overflow and nonzero source quantities that round to zero base
quantity are rejected by the shared checked converter. Public allocation and
stock-status tests cover both boundaries, including rejection before a stock
read. Target-system `MARM` ratios and ABAP quantity rounding still need
verification with live materials.

`ALLOCATE_BY_EXPIRY_PRIORITY` and `ALLOCATE_FEFO_UOM_PRIORITY` order shared
FEFO demand by descending integer priority, then stable input order. They
restore caller order in summaries and batch splits, so request IDs must be
unique. This only changes the local preview order; it does not reserve stock or
request SAP ATP confirmation.
The quality FEFO variants `ALLOCATE_QUALITY_FEFO_PRIORITY` and
`ALLOCATE_QUALITY_UOM_PRIORITY` apply the same local ordering to quality
inspection batches; they do not alter the standard unrestricted-stock pool.

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
rollback behavior for multiple creates in one LUW in the target release. The
adapter does not offer a BAPI simulation mode; inspect the pure prepared
request rows before calling the write method.

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

`ZCL_PROD_ORDER_SERVICE` passes the caller's release-control value to
`BAPI_PRODORD_RELEASE`, maps `BAPI_ORDER_RETURN` detail rows by order number,
and commits either a group or individual orders. Local tests exercise the
mapping and transaction service with API doubles, not SAP. Verify the target
system's `CO_RELEASE_CTRL_ORDER` values, release eligibility, BAPI parameter
signature, application-log behavior, and group rollback boundary before use.
The local BAPI order-key, detail-return, and application-log stubs include only
the fields used by this adapter.

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
leading zeros preserved. SAP's OData API independently exposes a
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
SAP release before using these methods operationally.

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
`BAPI_PRODORDCONF_CREATE_TT`, then the adapter calls `BAPI_TRANSACTION_COMMIT`
immediately as SAP recommends. SAP's examples map order, operation, sequence, yield, scrap, rework,
and final-confirmation values and call `BAPI_TRANSACTION_COMMIT` after the
BAPI. The adapter reads the per-row `BAPI_CORU_RETURN` message and confirmation
number/counter. Local stubs model only fields used by this feature, and local
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
shortage blocks only its own order; a BAPI or commit failure can leave other
orders committed. The overall result is therefore not atomic and callers must
reconcile per-order ATP, release, and commit states. The availability check is
not a reservation, and local tests use a readiness double rather than SAP ATP.

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

`CREATE_ORDERS_BULK` and `DELETE_ORDERS_BULK` commit each planned-order
operation separately and continue after failures. Local tests verify per-order
result accounting, but do not confirm the target BAPIs' LUW behavior or that a
failed operation leaves no pending update before the next call. Verify this
failure boundary in the target SAP release. The batch may be partially
completed; use each row's commit status rather than only the overall flag.
`CREATE_FROM_SUGGESTIONS_BULK` uses this same per-lot write boundary and retains
the source suggestion and receipt indexes in each row. Review both indexes and
the row commit status when reconciling a partially completed suggestion batch.

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
default includes it. This depends on local batch-expiry metadata and does not
make SAP ATP or the reservation BAPI confirm the selected expiry. Single and
multi-demand FEFO accept an optional exact-batch filter,
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
failure can follow already committed reversals.

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
representative reservations.

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
splits to the source unit. Its optional location-priority list orders eligible
fallback locations after each demand's preferred location; locations omitted
from the list remain eligible in ascending code order. Local tests use stock
and UOM doubles; validate the MARD/RESB query, storage-location order,
target-system UOM ratios, and safety stock distribution in SAP. This preview
does not select batches or post reservations.
`preview_cost_center_batches` uses the batch stock repository and its local
reservation deductions for the caller-selected batch. Tests use repository and
UOM doubles; validate MCHB/MCHA/MCH1/RESB selections, target-system conversion,
batch expiration mapping, and location order in SAP. Its optional priority list
orders fallback locations within the selected batch. The opt-in demand priority
sort is local, descending, and stable; verify that repeated stock reads observe
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
reservations. Its optional location priority only breaks ties between locations
for the same batch and expiration date. A demand's optional exact-batch filter
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
an optional priority list orders fallback locations after a demand's preferred
location. FEFO demands can optionally constrain individual rows to one exact
batch. Tests use stock/UOM and BAPI doubles; validate MARD/MCHB/MCHA/MCH1/RESB
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
later demands continue after an earlier failure. FEFO rows can use the same
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
The local tests verify continuation after a failed order, per-order rollback,
and the preservation of prior successes; they cannot verify live
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
each sales order. Its local tests verify continuation after an order-level
delete failure and preservation of later successes. Confirm that the target
release isolates each delete call with its transaction API; a later failure
does not restore reservations already released for earlier orders. Reservation
status and concurrent issue behavior remain SAP-controlled.

`ZCL_CC_RESERVATION_SERVICE=>DELETE_RESERVATIONS` applies that release path to
cost-center reservations. It deletes complete reservation documents by number;
it does not select individual items. SAP's reservation API documents deletion
at the reservation-document header level ([Delete Reservation Document](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/eb2a39dd0c124fed8252f684002d55e1/569b8cdbac5c4d2db987d34e0e99a5b2.html)).
Verify the target release's BAPI signature, document eligibility, and shared
LUW rollback behavior with representative reservations.

`DELETE_RESERVATIONS_BULK` commits each reservation deletion separately and
continues after API or commit failures. Earlier successful deletions remain
committed when a later number fails. The local tests validate per-number
result mapping and continuation through API and commit failures; verify the
target release's BAPI test-run response and one-reservation LUW behavior there.

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
and commit per cost center while continuing after errors. The UOM form converts
the complete request before posting. `ISSUE_COST_CENTERS_ATOMIC` and its UOM
form stage one movement document per cost center and request one shared commit;
an issue or commit error requests rollback and clears provisional document
results. Local tests verify request shaping, conversion, continuation, and
rollback with doubles. They do not establish that repeated
`BAPI_GOODSMVT_CREATE` calls share the expected SAP LUW or that rollback removes
all staged documents in the target release. Verify the transaction boundary,
commit messages, movement eligibility, and authorization in a nonproduction
SAP system.

`RETURN_COST_CENTERS_BULK` and `RETURN_COST_CENTERS_BULK_UOM` prevalidate
distinct cost centers and return lines, then post and commit one movement-202
document per cost center while continuing after errors. Their atomic variants
stage one return document per cost center and request one shared commit; any
movement or commit error requests rollback and clears provisional document
results. UOM variants convert every line before posting. Local tests validate
mapping, conversion, and rollback through doubles. They do not confirm that
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
after an individual BAPI failure. Earlier issues remain posted if a later
order fails. The UOM variant converts every line before the first post. Local
tests use an API double and do not verify live sales-item state, stock
eligibility, or cross-document behavior.
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
after an individual BAPI failure. Earlier returns remain posted if a later
order fails. The UOM form converts every line before the first post. Local
tests use an API double and do not verify live sales-item state, stock
eligibility, or cross-document posting behavior.
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
after individual failures. Earlier rows remain committed when a later transfer
fails. Its UOM variant converts all rows before the first posting. The atomic
forms request one shared commit or rollback after staging one BAPI movement per
order. Local tests cover validation, mapping, conversion, and orchestration,
not live stock availability, repeated-call SAP LUW behavior, or order-item
eligibility; verify these in the target release before production use.
`TRANSFER_TO_SALES_STOCK_BULK` applies the same independent-commit and
continuation policy to movement 413/E, and its UOM form converts every order
before the first posting. `TRANSFER_TO_SALES_STOCK_ATOMIC` stages one movement
per order and requests a shared commit or rollback; the UOM form validates all
conversions before staging. Tests use an API double and do not verify SAP
cross-document LUW behavior, stock availability, or sales-item eligibility.

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
earlier committed issues, and later rows are still attempted. Local tests cover
ordering, continued processing, validation-before-write, and test-run behavior;
verify repeated `BAPI_GOODSMVT_CREATE` calls and per-row commit handling in the
target SAP release. WBS status and project-stock availability remain SAP-side
checks. `ISSUE_PROJECT_WBS_BULK_UOM` converts every source-unit row before the
first goods-movement call; local tests cover conversion, mapping, and rejection
of a later unsupported conversion before posting. Verify `MARA`/`MARM` ratios
and base-unit ISO codes against the target system. `RETURN_PROJECT_WBS_BULK`
uses the same per-WBS commit and continuation behavior for movement 222; local
tests cover key mapping, prevalidation, partial failure, and simulation. It
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
changed batch or location split before posting. Neither preview locks stock;
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
`PRLAB` as valued unrestricted-use stock ([SAP project-stock reporting](https://help.sap.com/docs/PRODUCT_ID/4dd8cb7b1c484b4b93af84d00f60fdb8/e5f4c353b677b44ce10000000a174cb4.html), [MSPR table fields](https://www.sapdatasheet.org/abap/tabl/mspr.html)). `PREVIEW_FEFO` uses plant-level `MCHA-VFDAT` when present and falls back to material-level `MCH1-VFDAT`; SAP's FEFO guidance references both batch-master fields ([SAP batch expiration fields](https://help.sap.com/doc/6afeeafa6a424b9b8060d91da975c497/2025.1/en-US/CPP-EN.pdf)). Each FEFO demand can set its own `fefo_as_of_date`; the later of that date and the shared as-of date drives expiry eligibility, and selected batch splits echo the effective date. Each demand can also set a minimum shelf life; allocation applies the greater of that value and the shared minimum, and a positive effective minimum excludes batches without an expiry date. Selected splits echo the effective minimum so `RESERVE_WBS_FEFO` can repeat its expiry validation before writing. Duplicate repository rows for one batch/location key are merged only when their expiry dates agree; conflicting expiry dates reject the preview as ambiguous. Nonblank expiry values are validated as Gregorian dates before FEFO selection. The method converts demand units and shares balances across demands for the same WBS/material/plant. It skips rows without a batch or storage location because its output is consumed by the batch posting method. It does not allocate quality-inspection, blocked, restricted, or non-valuated project stock, and it does not lock or reserve the selected stock. Service tests use repository and UOM doubles; separate SQLite tests execute the repository SQL but do not validate target-system DDIC, query plans, or WBS formatting. Confirm these mappings and query behavior in the target SAP release.

`READ_AVAILABLE_STOCK` exposes the same reservation-netted project balances
without requiring a demand quantity. It returns located batch and batchless
rows in material base units and applies a reservation date cutoff when given.
The result remains a read snapshot; it is not locked and is not an ATP result.
The local test uses repository and UOM doubles, so confirm `MSPR`/`PRPS` and
`MARA` field availability and query behavior in the target SAP release.
`PREVIEW_FEFO_BY_DATE` orders shared project batch stock by required date and
same-date priority while keeping results in caller order. It evaluates batch
expiry through each demand's required date, but remains a local snapshot: future
receipts, concurrent issues, SAP batch determination, and target-system batch
checks are not modeled. Validate the selected batch and reservation date in the
target release before posting. The dated preview correlates repeated caller
IDs with internal row IDs; downstream consumers should keep a separate row key
when they need to distinguish repeated IDs.
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
`PREVIEW_BY_LOCATION_DATE` orders batchless project stock by required date and
same-date priority, then restores caller-order results. Its location quantities
come from the current snapshot; future receipts have no assigned location, and
concurrent changes are not locked. Validate location-level eligibility in the
target system before reservation or issue. The dated preview correlates
repeated caller IDs with internal row IDs; downstream consumers should keep a
separate row key when they need to distinguish repeated IDs.
`PREVIEW_BY_LOCATION_DATE_ATP` adds cumulative plant-level ATP diagnostics to
the local WBS location estimate. SAP ATP does not confirm the selected storage
location or reserve the project stock. Local tests use an availability API
double; verify the check rule and confirmation behavior in the target SAP
system.
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
`READ_RESERVATION_ITEMS_BULK` deduplicates WBS values, reads reservation items
once, then returns all matching items in each request row. It includes final
and fully withdrawn items by design. Local tests verify request ordering and
shared reads with a repository double; they do not execute the RESB/PRPS query
in SAP.

`READ_RESERVATION_COVERAGE` aggregates project stock and open reservations by
WBS/material/plant. It counts only positive stock with a storage location,
matching the allocation previews' eligible stock scope, converts reservation
quantities to the material base unit, and reports reserved quantity beyond
eligible stock as shortfall. Local tests use repository and UOM doubles; they
do not execute the MSPR/PRPS/RESB queries or validate live stock aggregation.
The summary is a snapshot and does not reserve or lock stock.
`READ_RESERVATION_COVERAGE_BULK` groups WBS requests by cutoff date before
calling the same summary logic. Tests verify one stock and reservation read
per date group with doubles; they do not measure or validate database query
behavior in SAP.
`READ_RESERVATION_COVERAGE_UOM` validates the requested material-unit ratio
before reading project stock, then converts each base-unit coverage total using
that ratio. Local tests verify conversion and early rejection of unknown units;
confirm the target `MARA`/`MARM` ratios and project-stock unit semantics in SAP.
`READ_RESV_COVERAGE_BULK_UOM` prevalidates and caches the requested ratios,
then uses the cutoff-grouped coverage reader. Local tests verify request order,
shared reads, conversion, and rejection of unknown units before stock reads;
they do not measure the grouped MSPR/RESB query in SAP.

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
the atomic mode issues repeated reservation-create BAPI calls and then requests
one shared commit or rollback. Local tests use an API double and cannot verify
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
reservation and commits each material document independently. Local doubles
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
mode commits each PO separately; atomic mode stages the group before one
commit. UOM forms convert all quantities to caller-mapped material base units
before posting. Local tests validate BAPI shaping, conversion, continuation,
and rollback using doubles. They do not verify returnable quantity, PO history,
or eligibility rules in a live system, nor that repeated BAPI calls share a
rollback-capable LUW. Verify those conditions and unit rounding in the target
SAP release.

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
database behavior.

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
after an individual BAPI failure. Earlier orders remain committed if a later
return fails, so callers must inspect each row result. The UOM variant converts
and validates all lines before the first post. Local tests use an API double and
do not cover SAP locking, reversal eligibility, or cross-document behavior.
`RETURN_PROD_ORDERS_ATOMIC` stages one `BAPI_GOODSMVT_CREATE` call per order
and requests a shared commit or rollback. Local tests verify service
orchestration only, not repeated-call LUW behavior or return eligibility. Verify
movement 262 configuration, reservation and order updates, and rollback after a
later movement or commit failure in the target release before relying on the
group transaction.
`ISSUE_UNPLANNED_PROD_BULK` prevalidates distinct orders and every
movement line, then posts one independent 261 document per order and continues
after an individual BAPI failure. Earlier orders may already be committed when
a later order fails; inspect every row result. Local tests verify validation,
field mapping, continuation, and commit behavior with an API double, not SAP
locking or cross-document posting behavior.
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
The ATP preview's local estimate is plant-level by default. Passing either
`it_projected_batch_receipts` or `it_projected_location_receipts` opts it into
the scoped local allocator; these inputs cannot be combined with SAP-derived
receipt flags. The SAP ATP request remains plant/date grouped and does not
receive caller batch/location assignments, so it does not verify that local
receipt allocation.
`PREVIEW_SCOPED_COMPONENTS` and its bulk variant provide a local estimate that
shares location totals with batch sub-balances and honors component batch and
location assignments. Batchless demands skip known batches that expire before
the component required date; undated batches remain eligible. Overflow and nonzero reservation quantities that round to zero at
MARD-LABST precision raise ZCX_INVALID_STOCK_REQUEST before stock is read.
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
mode ends each request with its own commit or rollback; atomic mode ends the
group with one commit or rollback. Local tests verify both control flows but
cannot verify target-system locks, update tasks, workflow triggers, or message
behavior across those transaction boundaries. Confirm these details for the
target release before using either mode in production.
`DELETE_PR_ITEMS_ATOMIC` calls `BAPI_PR_CHANGE` once per requisition and ends
the group with one `BAPI_TRANSACTION_COMMIT` or `BAPI_TRANSACTION_ROLLBACK`.
SAP's BAPI transaction model permits several calls to be grouped in one LUW,
but this implementation's behavior with repeated requisition changes has not
been exercised in a live target system. Confirm locks, update behavior, and
message handling for the target release before using atomic groups
([SAP BAPI transaction model](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_FOR_SOH_740/166400f6be7b46e8adc6b90fd20f3516/4d5b102ba1483d8fe10000000a42189e.html?version=7.40.16)).
`DELETE_PR_ITEMS_BULK` uses the same BAPI but commits or rolls back each
requisition before continuing. Local tests verify that a failed row does not
prevent later rows from being attempted; they cannot confirm target-system
lock release, update-task, or commit behavior between repeated BAPI calls.
Verify those transaction boundaries in the target release before using this
mode for production changes.

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
commit or rollback and continues after a failed document. Verify that the
target release releases locks and completes update tasks at each transaction
boundary, and review number assignment and returned messages with representative
creates.

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
results return in caller order. The UOM wrapper validates duplicate request IDs
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

`ALLOCATE_LOCATION_PRIORITY` and its UOM variant allocate higher-priority
demands first while returning summaries and location splits in caller order.
Internal row mapping preserves repeated caller request IDs. The UOM ATP wrapper
reports plant-level availability separately; it does not confirm the local
location split or reserve stock. Local tests use repository doubles, so verify
the target plant's location and ATP data before relying on the result.

`ALLOCATE_BY_BATCH` and its unit-aware variant also accept the location-priority
list. Allocation stays within the requested batch; a preferred location remains
first, listed fallback locations follow caller order, and unlisted locations
follow ascending code order. Local tests use repository doubles; verify that
the target batch stock query supplies the expected location/batch rows.

`ALLOCATE_BY_BATCH_PRIORITY` and `ALLOCATE_BY_BATCH_UOM_PRIORITY` consume
shared exact-batch stock by descending demand priority and return rows in caller
order. Internal row mapping preserves repeated request IDs. The ATP wrapper
checks grouped plant availability separately and does not reserve stock or
validate SAP batch determination settings. Local tests use repository and ATP
doubles; verify batch, expiry, and confirmation behavior against the target SAP
configuration.

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

Cross-plant FEFO allocation applies the caller's source-plant order first, then
orders eligible batches by expiration date within each plant. It uses the same
local `MCHB`/`MCHA`/`MCH1` and `RESB` stock estimate and eligibility rules as the
single-plant FEFO preview. The optional `it_storage_location_priority` list
breaks ties between locations for the same batch and expiration date; it does
not change source-plant, expiration-date, or batch order. The same list is
available on unit-aware and dated FEFO allocation, including its ATP wrapper.
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
selection. Their summaries and source/batch splits return in caller order. The
UOM wrapper validates conversions before stock reads, and both methods reject
duplicate request IDs before repository reads. `ALLOCATE_PLANTS_FEFO_UOM_ATP`
checks positive local source allocations by material, source plant, and base
unit; SAP ATP does not confirm the selected batch or location split and does not
change the priority allocation. These remain local previews with no stock lock
or reservation; SAP batch determination and transfer rules can produce a
different result. Local regression tests use stock, UOM, and ATP doubles.

Each cross-plant FEFO demand also supports `minimum_shelf_life_days`; the larger
of the demand value and shared `iv_min_days` controls its batch eligibility,
and every FEFO split reports that effective value. The rule passes through
dated, unit-aware, and ATP wrappers. Shared demand structures are also accepted
by ordinary allocators, which reject a nonzero shelf-life value before reading
stock because those paths do not evaluate expiry.

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
its atomic option stages those calls in one LUW and rolls them back together on
an API or commit failure. Verify multi-call commit/rollback behavior with the
target release because local API doubles cannot establish SAP LUW semantics.

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
It continues after an issue failure and returns per-pair issue-attempt and
in-transit status; earlier PO issues remain committed if a later one fails.
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
a failed receipt remains in transit while later PO receipts continue. A receipt
test run does not clear in-transit status. The service trusts the supplied issue
result, and SAP remains responsible for rechecking PO history, quantities,
batches, receiving locations, and posting-period rules. API-double tests do not
verify a live 351/101 sequence.
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
document independently. Cancellation is not simulatable through this API; a
failed reversal keeps the pair marked in transit and does not stop later
documents. This state comes from the caller's prior issue result and may be
stale if another process has since posted a receipt or changed the document.
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
in-transit only after a successful reversal. Callers can then reverse the
original 351 issue separately. The result trusts its supplied receipt state;
SAP validates the document history, posting period, and current stock. The
cancellation API has no test-run mode, and local doubles do not verify live
101/102 cancellation behavior.
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
on earlier pairs by default. With `iv_atomic = abap_true`, every input pair must
be received, all 101 and 351 cancellations share one commit, and a cancellation
or commit failure rolls back the group while preserving each pair's received
state. This depends on the target release honoring rollback for multiple
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
rolls back. Local doubles cover state handling, not live SAP document status or
rollback behavior.

`RETRY_STO_CHAIN_RECEIPT` and `RETRY_STO_CHAIN_RECEIPT_PAIRS` use a prior
receipt-chain cancellation result to retry 101 receipt reversals for pairs that
remain received, including pairs restored by an atomic chain rollback. Pairs
whose receipt reversal already succeeded remain in transit for the separate
351 issue retry, and the aggregate chain result remains incomplete until both
movements are reversed. The methods trust the supplied prior state;
SAP validates document history, posting periods, and current stock. Atomic mode
groups only pending 101 reversals, so a later 351 retry is a separate LUW. Local
doubles cover state mapping and transaction handling, not live SAP eligibility
or rollback behavior.

`RETRY_STO_CHAIN` and `RETRY_STO_CHAIN_PAIRS` recover both retryable stages
from the caller-supplied prior result. Received rows retry their 101 reversal
before the original 351; rows already in transit retry only the 351; completed
rows are preserved. Atomic mode groups all newly pending reversals, including
both stages for a received pair, into one LUW. On failure it restores the input
state and clears reversal document IDs created in that LUW. Prior reversals
committed by an earlier call remain committed. SAP still validates current
document history, posting periods, and stock eligibility, and the shared
rollback guarantee for multiple `BAPI_GOODSMVT_CANCEL` calls must be checked on
the target release. Local doubles cover result mapping and call ordering only.

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
PO separately while continuing after failures. A returned batch can therefore
contain committed POs alongside failed requests; callers must inspect each
result. All requests in a call must use the same test-run setting. Local API
double tests verify ordering, prevalidation, per-order continuation, and commit
counts, but not SAP locks, update tasks, workflow, or LUW behavior between PO
creates. Validate multiple independent creates and rollback behavior with the
target release before using a bulk batch operationally.

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

## Resolved

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
  handling still needs target-release verification.
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
are unchanged from `GET_PROJECTED_RECEIPTS`.
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
non-test create. Confirm multiple creates share the intended SAP LUW and that
the returned document numbers and commit messages match the target release.
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
receipts remain posted when a later PO fails. Both methods prevalidate unique
PO numbers and line items, but SAP still decides PO history, open quantity,
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
earlier orders received when a later call fails.
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
replenish the residual static safety-stock buffer. The UOM and ATP wrappers
forward receipts, but ATP does not confirm their batch assignment. Local tests
use stock and ATP doubles; validate batch identity, receipt assignment, and
safety-stock behavior in the target SAP release.

Cross-plant exact-batch allocation accepts the same caller-resolved receipt
fields and requires each receipt's material, source plant, and batch to map to
a demand/source pair. The undated API uses a demand's optional `as_of_date` or
today; the date-prioritized API uses the demand's `required_date`. A positive
`minimum_shelf_life_days` excludes unknown expiries and batches that do not
meet the remaining-life requirement. UOM and ATP wrappers preserve this local
estimate, while ATP remains plant-level. Local tests do not validate
source-plant routing, batch master data, or static safety-stock semantics in
SAP.

`ALLOCATE_PLANTS_BATCH_PRIORITY` and `ALLOCATE_PLANTS_BATCH_UOM_PRIO` order
same-as-of-date requests by descending priority, preserving input order for
ties; an earlier as-of date still takes precedence. Their summaries and
source/location splits return in caller order. Duplicate request IDs are
rejected before stock reads or UOM conversion. `ALLOCATE_PLANTS_BATCH_UOM_ATP`
checks positive allocations by material, source plant, and base unit. The ATP
result does not confirm the selected batch or location, and these local
previews do not reserve stock. Local tests use stock, UOM, and ATP doubles.

Single- and cross-plant exact-batch methods accept
`iv_include_undated_batches` to exclude stock or projected receipts with no
expiry date when callers require expiry data. The default remains inclusive.
This is only as reliable as the expiry values supplied by the repository or
caller; ATP remains a plant-level comparison and does not confirm batch expiry
or assignment.

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
