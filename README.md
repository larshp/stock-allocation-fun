# Stock allocation in ABAP

An ABAP library for deterministic stock allocation with SAP integration boundaries.
Custom objects live in `src/`; local SAP substitutes live in `stubs/`.

## Features

- Allocate by ascending numeric priority, requirement date, then request ID.
- Support partial fulfillment or complete-only requests; report every shortage.
- Explain each decision with a reason code and remaining availability before/after.
- Summarize demand, fulfillment and earliest shortages per material/location/unit.
- Optionally enforce whole-lot demand and round partial allocation down to lot size.
- Optionally skip partial allocations below a caller-defined minimum quantity.
- Preserve a safety-stock floor and isolate material/plant/storage combinations.
- Subtract externally supplied commitments before allocating remaining stock.
- Reject duplicate keys, nonpositive demand and incompatible units.
- Read unrestricted stock from MARD and base units from MARA.
- Simulate through an injectable stock source.
- Limit general simulations to an inclusive requirement-date window.
- Read outstanding RESB order components with an optional requirement-date horizon.
- Create cost-center reservations through `BAPI_RESERVATION_CREATE1` (movement 201).
  BAPI test mode is the default; SAP errors retain the complete return-message table.
- Stage cost-center goods issues through `BAPI_GOODSMVT_CREATE`, also defaulting
  to test mode and leaving transaction completion to the integrating application.

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
The lock and both tool configurations must point to the same revision. Generated
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
allocator. It validates order selections and dates before reading, skips empty
work, and rejects returned demand outside the horizon. Both sources are injectable:

```abap
DATA(order_service) = NEW zcl_stock_order_service(
  order_source = NEW zcl_stock_order_source_sap( )
  stock_source = NEW zcl_stock_source_sap( ) ).
DATA(order_allocations) = order_service->simulate(
  orders = VALUE #( ( order_id = '000000001000' priority = 1 allow_partial = abap_true ) )
  through_date = '20260930' ).
```

Wrap these calls in the same `TRY`/`CATCH zcx_stock_alloc` boundary shown above.
An adjusted stock source can account for caller-supplied external commitments.

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
the proper reservation-referenced process for those demands, rather than posting
them again as independent cost-center consumption.

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
apply. Batch/serial-managed materials, special stock and reservation references
are outside this adapter's contract; use a specialized integration for them.

Pure allocator and test-double tests are portable ABAP Unit tests. Database fixture
and standard-stub tests run locally through the transpiler; they are not native SAP
integration tests. Verify real APIs, client isolation, permissions and transaction
behavior in a development SAP system before productive use.

See [NOTES.md](NOTES.md) for progress and [ANOMALIES.md](ANOMALIES.md) for known issues.
