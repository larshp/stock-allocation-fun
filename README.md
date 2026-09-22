# Stock allocation in ABAP

An ABAP library for deterministic stock allocation with SAP integration boundaries.
Custom objects live in `src/`; local SAP substitutes live in `stubs/`.

## Features

- Allocate by ascending numeric priority, requirement date, then request ID.
- Support partial fulfillment or complete-only requests; report every shortage.
- Explain each decision with a reason code and remaining availability before/after.
- Summarize demand, fulfillment and earliest shortages per material/location/unit.
- Report fulfillment per order with component counts and shortage details.
- Compare allocation scenarios per request, including gains, losses and shortages.
- Optionally enforce whole-lot demand and round partial allocation down to lot size.
- Optionally skip partial allocations below a caller-defined minimum quantity.
- Preserve a safety-stock floor and isolate material/plant/storage combinations.
- Subtract externally supplied commitments before allocating remaining stock.
- Reject duplicate keys, nonpositive demand and incompatible units.
- Read unrestricted stock from MARD and base units from MARA.
- Simulate through an injectable stock source.
- Limit general simulations to an inclusive requirement-date window.
- Read outstanding RESB order components within an optional inclusive date window.
- Preserve order/reservation provenance and reject independent writes of referenced demand.
- Create cost-center reservations through `BAPI_RESERVATION_CREATE1` (movement 201).
  BAPI test mode is the default; SAP errors retain the complete return-message table.
- Stage cost-center goods issues through `BAPI_GOODSMVT_CREATE`, also defaulting
  to test mode and leaving transaction completion to the integrating application.
- Stage goods issues against existing reservation items, preserving their SAP references.
- Revalidate reservation identity and remaining demand before staging referenced issues.

## Local development

Use Node.js 22 and Git:

```sh
npm ci
npm test
```

`npm test` runs abaplint, transpiles both `src` and `stubs` with open-abap-core,
then executes ABAP Unit tests using an isolated SQLite database. The lint rules
required by PLAN.md are enabled. The first run fetches the open-abap-core commit in
`dependencies.lock.json`; subsequent runs verify and reuse the clean `.deps/` cache.
Dependency preparation runs explicitly even when npm lifecycle hooks are disabled
with `ignore-scripts`. The lock and both tool configurations must point to the same revision. Generated
JavaScript, dependency caches and node_modules are ignored. CI executes the same command.

Run `npm run demo` for a verified, read-only example with fixed sample data. On
Windows with restricted PowerShell scripts, use `npm.cmd run demo` or `npm.cmd test`.
In SAP, execute report `ZSTOCK_ALLOC_DEMO`. Its three requests demonstrate priority,
safety stock, commitments, partial fulfillment and whole-lot rounding. Available
stock is 15 ST; allocations are 8, 4 and 3 ST. No database or BAPI is called.

## SAP installation and use

Import with abapGit into a customer package on an on-premise ABAP 7.50 or later
system. `.abapgit.xml` selects only `src/`. **Never import `stubs/` or open-abap-core
into SAP:** their standard objects already exist there. This implementation uses
classic on-premise APIs and is not an ABAP Cloud released-API solution.

```abap
DATA(requests) = VALUE zif_stock_alloc_types=>ty_requests(
  ( request_id = 'DEMAND-001' material = '000000000000000123'
    plant = '1000' storage = '0001' unit = 'ST' quantity = 5
    priority = 1 required_date = '20260930' allow_partial = abap_true ) ).
DATA(service) = NEW zcl_stock_alloc_service( NEW zcl_stock_source_sap( ) ).
TRY.
    DATA(allocations) = service->simulate( requests ).
  CATCH zcx_stock_alloc INTO DATA(error).
    " Present error->reason and error->messages in your application log.
ENDTRY.
```

Use SAP internal material, cost-center and unit representations; the current
material contract is 18 characters. No unit conversion, batch selection or special
stock handling is performed. For a pure calculation with safety stock, call
`zcl_stock_allocator->allocate` with your own stock rows.

`zcl_stock_alloc_service->simulate` accepts optional `from_date` and `through_date`
boundaries. Both are inclusive and default to the full supported calendar range.
Only requests in that window are passed to the stock source and returned as
allocations. Empty selections skip stock reads. All supplied requests are validated
before filtering, so a date window cannot conceal duplicate IDs or invalid demand.
The pure allocator continues to process every request it receives.

Request `lot_size` defaults to zero (no lot constraint). A positive value requires
the requested quantity to be an exact multiple. For example, demand 12 with lot
size 4 and stock 10 allocates 8, leaving 2 for later requests. Quantities use three
decimal places; fractional lots such as 0.100 are supported.

Request `min_allocation` defaults to zero. Set it to the smallest useful partial
quantity, between zero and the requested quantity. The allocator checks it after
lot rounding: demand 8, lot size 4, minimum 5 and stock 7 receives zero, leaving all
7 for later requests. The minimum need not be a whole lot; allocations still must
respect `lot_size`. Full fulfillment and complete-only requests retain their behavior.

Each allocation includes `available_before` and `available_after` for its location,
after commitments and safety stock and after earlier requests in allocation order.
These are snapshot diagnostics, not new SAP ATP promises. The `reason` field uses
constants from `zif_stock_alloc_types`:

| Reason | Meaning |
| --- | --- |
| `FULLY_ALLOCATED` | Entire requested quantity supplied. |
| `MISSING_STOCK` | No stock row was supplied for the location. |
| `NO_AVAILABLE_STOCK` | The location has no remaining allocatable quantity. |
| `INSUFFICIENT_STOCK` | Remaining quantity supplied as a partial allocation. |
| `COMPLETE_ONLY` | Positive stock is insufficient for a complete-only request. |
| `LOT_ROUNDED` | Lot rounding reduced the quantity, possibly to zero. |
| `BELOW_MINIMUM` | A positive quantity after lot rounding fell below the minimum. |

The last effective policy supplies the reason: a minimum can override lot rounding
when it rejects a positive rounded quantity. If rounding already produced zero,
the reason remains `LOT_ROUNDED`. Zero availability takes precedence over policies.

`NEW zcl_stock_alloc_summary( )->summarize( allocations )` returns rows sorted by
material, plant, storage and unit. Each contains requested, allocated and shortage
totals, counts of full/partial/unfilled requests, and the earliest date with a
shortage. Units are separate groups. Counts derive from quantities; optional display
status and reason fields are not required. Duplicate IDs, inconsistent quantities
and invalid dates are rejected through the same result validation as reservations.
Totals use the public quantity range (up to 9,999,999,999.999); exceeding it raises
`zcx_stock_alloc` before assignment. Empty input returns an empty summary.

To evaluate changes to stock, commitments, safety stock or allocation priority,
compare two runs of the same demand:

```abap
DATA(changes) = NEW zcl_stock_alloc_comparison( )->compare(
  baseline = baseline_allocations
  scenario = scenario_allocations ).
```

Rows are sorted by request ID and contain allocations and shortages before/after,
plus `allocation_delta` (scenario minus baseline). `change` uses the class constants
`change_improved`, `change_reduced` and `change_unchanged`. Unchanged requests remain
in the output. Units and origin are preserved on each row; quantities are never
combined across units. Both inputs undergo full allocation-result validation.
Request IDs, material/location/unit, requirement date, requested quantity and origin
must match between runs. Added, removed or altered demand raises `zcx_stock_alloc`;
input ordering, allocation reasons and availability diagnostics may differ. Two
empty runs return no rows. Use the same `TRY`/`CATCH` boundary as for simulation.

Each stock row may specify `committed` and `safety_stock`. Available quantity is
`max(0, physical - committed - safety_stock)`. To apply these to a SAP source,
wrap it in `zcl_stock_source_adjusted` and pass adjustment rows with zero `quantity`.
Commitments must exclude the demand being allocated in this run to avoid counting
that demand twice. The library does not discover external commitments automatically.

`zcl_stock_order_source_sap` reads open issue components for explicitly selected
order numbers, calculating demand as `BDMNG - ENMNG`. It excludes deleted, finally
issued, fully withdrawn, receipt and special-stock rows. SAP documents these
[reservation quantity and status fields](https://help.sap.com/docs/SCMCSCPP/b654ceec39734aca96c6d395cdc7c69f/fb40892b730c10148e1ab0818e3f0a53.html).
Callers select authorized, operationally eligible orders; order release/TECO status
is not evaluated here. Existing order-component reservations are for simulation
and downstream order processing; do not create new cost-center reservations for
them through the separate movement-201 adapter.

`zcl_stock_order_service` connects the order and stock readers with the same pure
allocator. Both it and `zif_stock_order_source~read` accept `from_date` (default
`00010101`) and `through_date` (default `99991231`). The window is inclusive;
invalid dates or a reversed window fail before any reads, even for empty selections.
The SAP source filters RESB before allocation, so earlier components do not consume
stock within the selected window. Empty work skips stock reads, and the service
rejects any demand an injected source returns outside the window. Both sources are injectable:

```abap
DATA(order_service) = NEW zcl_stock_order_service(
  order_source = NEW zcl_stock_order_source_sap( )
  stock_source = NEW zcl_stock_source_sap( ) ).
DATA(order_allocations) = order_service->simulate(
  orders = VALUE #( ( order_id = '000000001000' priority = 1 allow_partial = abap_true ) )
  from_date = '20260901'
  through_date = '20260930' ).
```

Wrap these calls in the same `TRY`/`CATCH zcx_stock_alloc` boundary shown above.
An adjusted stock source can account for caller-supplied external commitments.

An injected order source must set `origin-order_id` on every returned request to
one of the selected orders, and copy that order's `priority` and `allow_partial`.
The service rejects missing/unselected origins or changed policies before reading
stock. Custom source implementations written against the earlier, less strict
contract must populate these fields. An order may return no outstanding components.

Use `NEW zcl_stock_order_summary( )->summarize( order_allocations )` to report
fulfillment per order. Rows are sorted by order ID and include request counts,
full/partial/unfilled counts, earliest shortage date and a `shortages` table of
the original unfilled or partially filled allocations, sorted by requirement date
then request ID. Details retain each material, unit, quantity and reservation origin.
The report never sums quantities across materials or units. `status` is `FULL`
when all supplied components are fulfilled, `SHORTAGE` when none receives stock,
and `PARTIAL` otherwise; it derives these from quantities, not display statuses.

All rows must carry an order ID and pass allocation-result validation. Empty input
returns no orders. The report describes only the allocations supplied: a date-window
simulation omits components outside that window, and an order with no returned demand
has no summary row. `FULL` therefore does not certify production readiness, order
release status or availability of components outside the selected demand.

Requests and allocations carry `origin` with `order_id`, `reservation`,
`reservation_item` and `reservation_type`. The RESB reader populates these fields,
and the allocator preserves them through sorting, shortages and partial fulfillment.
Reservation number and item must be supplied together; type cannot be supplied
without a reservation. Independent demand leaves origin initial. Both cost-center
write adapters reject rows referencing an order or reservation before calling SAP,
including zero-allocated rows. Keep origin intact when passing results downstream.

The stock reader supplies a physical snapshot. It does not subtract existing
commitments or constitute an ATP promise. The BAPI adapter requests an SAP ATP check;
actual behavior depends on target-system customizing. SAP describes MARD-LABST as
[unrestricted stock](https://help.sap.com/docs/SCMCSCPP/7497fe04b3da40b98a1f748d75dea162/fb40a46f730c1014b20cb6168adf95d3.html).

To validate a cost-center reservation, call `zif_stock_reservation~create` on
`zcl_stock_reservation_sap`, passing allocations, cost center and base date.
Its default `test_run = abap_true` creates no document. An explicit false value
stages one reservation in the caller's SAP LUW. It does not post a goods movement
or directly update MARD. The adapter never commits or rolls back the caller's work.

The integrating application owns authorization checks, locking/revalidation,
idempotency, and `BAPI_TRANSACTION_COMMIT` or `BAPI_TRANSACTION_ROLLBACK` handling.
Do not reuse an old simulation as a concurrent-stock guarantee or retry a write
blindly after an uncertain commit. Review BAPI warnings before committing.

For direct cost-center consumption, use `zif_stock_goods_issue~create` on
`zcl_stock_goods_issue_sap` with allocations, cost center, posting date and document
date. It maps positive allocated quantities to movement 201 and GM code 03 with a
blank movement indicator, following SAP's
[goods-issue BAPI contract](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html?locale=en-US).
It does not consume an existing reservation or order-component reservation. Use
the reservation-referenced adapter below for those demands.

```abap
DATA issuer TYPE REF TO zif_stock_goods_issue.
issuer = NEW zcl_stock_goods_issue_sap( ).
DATA(issue_result) = issuer->create(
  allocations = allocations
  cost_center = '0000001000'
  posting_date = '20260906'
  document_date = '20260905' ). " Default: test mode only
```

Use `TRY`/`CATCH zcx_stock_alloc` as above. Explicit `test_run = abap_false` stages
an actual material document in the SAP LUW. A successful actual call returns both
material document and year; simulation clears both. SAP errors/aborts retain all
messages, and warnings are returned for caller review. The adapter never commits
or rolls back. The same authorization, fresh-stock, locking and retry responsibilities
apply. Batch/serial-managed materials and special stock require a specialized integration.

For existing reservation demand, call `zif_stock_reserved_issue~create` on
`zcl_stock_reserved_issue_sap`. It requires a reservation number and item on every
allocation, including zero-allocated rows. Each reservation number/item/type combination
may occur once per call, even under different request IDs or order IDs. Independent
demand and order-only references are rejected. It posts only positive allocations.

```abap
DATA reserved_issuer TYPE REF TO zif_stock_reserved_issue.
reserved_issuer = NEW zcl_stock_reserved_issue_sap( ).
DATA(reserved_result) = reserved_issuer->create(
  allocations = order_allocations
  posting_date = '20260922'
  document_date = '20260922' ). " Default: test mode only
```

Use the same `TRY`/`CATCH zcx_stock_alloc` boundary as above. The adapter maps origin
to `RESERV_NO`, `RES_ITEM` and `RES_TYPE`, plus allocated quantity, internal entry
unit and storage location. Record type is copied unchanged, including a blank value.
GM code is 03 with a blank movement indicator. Following the
[SAP reservation-reference contract](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html),
material, plant, movement type and account assignment are left for SAP to derive
from the reservation. The adapter leaves `WITHDRAWN` initial; it never forces final
issue when a shortage remains. SAP controls reservation updates and completion.

Test mode clears document keys; explicit `test_run = abap_false` stages a material
document and requires a complete returned document/year. Errors retain all SAP
messages; warnings remain available to review. Both goods-issue adapters use the
same protected BAPI boundary and result validation and never commit or roll back.
Callers must verify that reservation identity, material/location/unit, outstanding
quantity and eligibility still match the allocation under appropriate locks before
posting. This adapter does not re-read RESB, resolve backflush rules or add batch,
serial-number or special-stock parameters. The local stub proves mapping and error
handling only; reservation withdrawals must be verified in a development SAP system.

Wrap the reserved writer in `zcl_stock_reserved_checked` to revalidate current
reservation demand before invoking it:

```abap
reserved_issuer = NEW zcl_stock_reserved_checked(
  source = NEW zcl_stock_reserv_source_sap( )
  writer = NEW zcl_stock_reserved_issue_sap( ) ).
reserved_result = reserved_issuer->create(
  allocations = order_allocations
  posting_date = '20260922'
  document_date = '20260922' ). " Still defaults to test mode
```

The wrapper validates dates, quantities and unique reservation references before
reading. It reads only positive allocations and requires exactly those current
reservation keys, without duplicates. Order, material, plant, storage, unit and
requirement date must still match. Outstanding demand must cover the proposed issue;
it may differ from the original requested quantity. All rows pass before the writer
is called once with the unchanged allocation table. Source and writer errors propagate,
and every call performs a fresh read, including simulation calls. Empty or all-zero
issues fail before reading. Zero allocations still need valid unique references but
are not revalidated against current demand because they generate no posting item.

`zif_stock_reservation_source` is injectable. Its SAP implementation reads RESB by
reservation number, item and record type and returns `BDMNG - ENMNG` for open issue
items, including manual reservations without an order. Deleted, finally issued,
fully withdrawn, receipt and special-stock items are omitted. Duplicate input keys
are read once; incomplete keys and negative open-item quantities are rejected.
Source request IDs need not match the original simulation: matching uses reservation
keys and the identity fields above. The wrapper rejects unexpected source items.

This check covers a reservation snapshot, not stock availability, movement permission,
order status or backflush eligibility. The caller must hold suitable locks through
revalidation and posting and own commit/rollback. Without those locks, a reservation
can change after the read. The low-level SAP writer remains available for applications
that already implement these checks in their transaction boundary.

Pure allocator and test-double tests are portable ABAP Unit tests. Database fixture
and standard-stub tests run locally through the transpiler; they are not native SAP
integration tests. Verify real APIs, client isolation, permissions and transaction
behavior in a development SAP system before productive use.

See [NOTES.md](NOTES.md) for progress and [ANOMALIES.md](ANOMALIES.md) for known issues.
