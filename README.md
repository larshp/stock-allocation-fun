# Stock allocation in ABAP

An ABAP library for deterministic stock allocation with SAP integration boundaries.
Custom objects live in `src/`; local SAP substitutes live in `stubs/`.

## Features

- Allocate by ascending numeric priority, requirement date, then request ID.
- Support partial fulfillment or complete-only requests; report every shortage.
- Optionally enforce whole-lot demand and round partial allocation down to lot size.
- Preserve a safety-stock floor and isolate material/plant/storage combinations.
- Subtract externally supplied commitments before allocating remaining stock.
- Reject duplicate keys, nonpositive demand and incompatible units.
- Read unrestricted stock from MARD and base units from MARA.
- Simulate through an injectable stock source.
- Read outstanding RESB order components with an optional requirement-date horizon.
- Create cost-center reservations through `BAPI_RESERVATION_CREATE1` (movement 201).
  BAPI test mode is the default; SAP errors retain the complete return-message table.

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

Request `lot_size` defaults to zero (no lot constraint). A positive value requires
the requested quantity to be an exact multiple. For example, demand 12 with lot
size 4 and stock 10 allocates 8, leaving 2 for later requests. Quantities use three
decimal places; fractional lots such as 0.100 are supported.

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

Pure allocator and test-double tests are portable ABAP Unit tests. Database fixture
and standard-stub tests run locally through the transpiler; they are not native SAP
integration tests. Verify real APIs, client isolation, permissions and transaction
behavior in a development SAP system before productive use.

See [NOTES.md](NOTES.md) for progress and [ANOMALIES.md](ANOMALIES.md) for known issues.
