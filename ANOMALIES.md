# Anomalies

Known scope limitation: local `MARD`, `MARC`, `MARA`, `VBAP`, `VBEP`, `VBUP`, and BAPI
dictionary definitions model only the fields used by this project. The SAP
system's delivered definitions are authoritative at deployment time. BAPI
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
does not change the local allocation or preview success flag. Preview does not
persist a reservation. The ATP API is mocked locally, so confirm the target
release's BAPI signature and check-rule behavior in SAP.

Order allocation subtracts active movement type 231 reservations from
`RESB-BDMNG - RESB-ENMNG`, grouped by material, plant, item, schedule line,
and requirement date for the sales order. It uses schedule-line and date keys
to reduce the matching open demand, then distributes any unmatched remainder
across that item's open lines in allocation order. Local tests use repository
doubles; verify `KDAUF`, `KDPOS`, `KDEIN`, `BDTER`, and the BAPI's target-release
assignment behavior in SAP. SAP documents the reservation requirement date on the
reservation item ([reservation requirement date](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167776.html)).

Reservation release calls `BAPI_RESERVATION_DELETE` once per reservation
number inside one BAPI transaction. SAP controls whether a reservation can be
deleted, including reservations already partly or fully issued. Verify the
BAPI signature and deletion behavior in the target release; local tests use
an API double and do not exercise SAP reservation status rules.

Reservation inquiry reads items through `BAPI_RESERVATION_GETDETAIL1`. Its
adapter maps the partial local `BAPI2093_RES_ITEM_DETAIL` stub. Verify the
function signature and detail-field semantics against the target release;
local tests use an API double and do not validate live reservation records.

Production-order component inquiry reads open reservation items from `RESB`
using `AUFNR`, `RSNUM`, `RSPOS`, `BDMNG`, and `ENMNG`, while returning the
reservation unit, movement type, date, location, and batch. `ISSUE_COMPONENTS`
validates selected keys and quantities against those open rows, then uses the
reservation detail read and goods-movement APIs. Local service tests use
repository and API doubles; they do not execute the query or validate the
BAPI signatures and field behavior against the target release. Production
orders normally generate their component reservations automatically, so this
service exposes and issues those existing reservations instead of creating
duplicates.

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
allocation and reservation requests. When `iv_check_atp` is enabled, preview
also asks SAP about each remaining open schedule line; the resulting
confirmation can still differ from local allocation and configured priority
rules can change the result at reservation time.

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
Only issued-minus-received quantity is projected; planned but unissued transfers
are excluded. The schedule date is treated as the date stock can be used. This
does not validate actual delivery dates, cross-company behavior, schedule-line
unit consistency, or target-system filters, so confirm these against live STOs.

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
`ALLOCATE_DEMANDS_BY_DATE` sorts valid unique request IDs by material, plant,
required date, and input position, then subtracts earlier allocations from each
later date's local estimate so the same stock is not promised twice. Repeated
material/plant/date estimates and static safety-stock reads are cached during a
call. Results return in input order. Same-date requests retain input priority;
the optional PO receipt projection is applied to each date snapshot. This
remains a deterministic local estimate, not SAP's full ATP calculation.
`ALLOCATE_DATE_DEMANDS_IN_UNITS` converts each dated demand with the material's
`MARA`/`MARM` ratio before stock reads, caches repeated ratios, and reuses the
same dated allocation path. Base-unit quantities are canonical; source-unit
availability, allocation, and shortfall are rounded to the quantity-field
precision. Tests use UOM and stock repository doubles and do not execute the
live `MARA`/`MARM` or date-based stock queries.
`ALLOCATE_PLANTS_BY_DATE` applies the date projection to caller-ordered source
plants and shares each material/source-plant balance across earlier demands.
It returns plant-level splits only; projected receipts cannot be assigned to a
storage location, so this result is for planning and cannot be posted directly
as the location-level transfer allocation.
`ALLOCATE_PLANTS_DATE_UNITS` converts each dated demand using `MARA`/`MARM`
before invoking that same plant-level projection. Returned base-unit values are
canonical; source-unit demand and split quantities are rounded to the quantity
field's precision. Local tests use UOM and stock repository doubles and do not
execute the live unit-ratio or dated-stock queries. The result remains a
planning estimate without location splits.
`ALLOCATE_PLANTS_DATE_ATP` checks only positive source splits from that local
estimate. Its client-side cumulative quantity is grouped by source plant,
base unit, and date from this request list; it does not check an unallocated
shortfall, model concurrent requests, or replace SAP's checking-rule scope.
The ATP result remains separate from local allocation and success.

`ALLOCATE_DATE_DEMANDS_ATP` groups dated unit-aware demands by material, plant,
base unit, and required date. It checks the cumulative base-unit quantity once
per date group and shares the result with requests due on that date. This
client-side accumulation only includes the supplied request list and cannot
replace SAP's checking-rule configuration or account for concurrent demand.
The local estimate's receipt and safety-stock options do not modify the SAP ATP
request; validate both results against the target system.

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
local `MARA`/`MARM` ratio and should be checked in the target release.
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
The client-side total includes only open lines in this preview and does not
reproduce all configured accumulation or concurrent demand, so validate the
checking rule and results in the target system. Checks use base-unit quantities
and preserve the local allocation and success values. The result set is
separate from local batch/location splits and does not model SAP picking or
batch determination.

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
