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
result. `preview_for_cost_center` and the pre-BAPI allocation use the local
stock estimate only; preview itself does not call SAP ATP or persist a
reservation.

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
`TRANSFER_PLANT_BATCH_UNITS`; these methods post canonical base-unit split
quantities and validate the supplied material/base-unit mapping. Use 303/305
postings when the process requires two-step in-transit handling. The unit-aware
allocation variant converts through
`MARA`/`MARM` and rounds displayed source-unit values to quantity-field
precision; use the base-unit splits as canonical amounts. Local tests use
repository doubles; validate source eligibility, conversion factors, ATP, and
the goods movement in the target system.

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
preview does not emulate SAP's picking or ATP decision. Validate target-system
picking strategy before using the result as warehouse instructions.

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
allocation and reservation requests. SAP's later ATP check and configured
priority rules can produce a different confirmation result.

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
