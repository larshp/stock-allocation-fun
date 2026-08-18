# Stock Allocation for SAP ABAP

An incremental, test-driven stock allocation service for existing SAP systems.
The current implementation ranks demand, protects safety stock, supports partial
fulfillment, and separates pure allocation logic from SAP reads and reservation
writes.

## Implemented features

- Deterministic allocation by ascending priority and request ID.
- Earliest-requirement-date ordering within the same priority.
- Selectable priority/date, date/priority, and priority/request-ID strategies.
- All-or-nothing and partial-fulfillment requests.
- Per-request minimum fulfillment percentages for partial allocations.
- Plant and storage-location-specific stock pools.
- Safety-stock protection using plant-level `MARC-EISBE`.
- Rejection of invalid quantities, missing request IDs, duplicate request IDs,
  missing stock, and insufficient all-or-nothing stock.
- Simulation mode that calculates allocations without writing them.
- An orchestration service with injectable stock-reader and allocation-writer
  ports.
- An SAP stock reader using `MARD-LABST` and `MARC-EISBE` with one set-oriented
  query.
- Transactional reservation posting through `BAPI_RESERVATION_CREATE1`, with
  batch commit, rollback on any create/commit error, and returned document IDs
  and messages.
- Persistent request-ID claims in the owned `ZSTOCK_ALLOC` table, committed in
  the same LUW as reservation creation.
- Aggregate availability revalidation after claims and before any BAPI call.
- Exclusive `MARD` stock-pool locks acquired in deterministic key order and
  held through BAPI commit or rollback.
- A production composition entry point and current-state operational audit in
  `ZSTOCK_ALOG`, with separate productive and simulation records.

## Repository layout

- `src/`: deployable custom `Z*` ABAP code and ABAP Unit tests.
- `sap_stubs/`: minimal SAP standard DDIC definitions used only by local checks.
- `abaplint.json`: syntax, style, dependency, and ownership rules.
- `abap_transpile.json`: transpiler inputs and the `open-abap-core` dependency.
- `NOTES.md`: implementation decisions and progress.
- `ANOMALIES.md`: known defects, risks, and missing integration behavior.

## Local verification

Node.js 18 or newer is required.

```text
npm install
npm test
```

`npm test` runs abaplint, transpiles the ABAP with open-abap-core, and executes
the transpiled ABAP Unit suite.

## SAP integration

Import `src/` with abapGit into a customer package. Do not import `sap_stubs/`:
those objects model standard SAP definitions that already exist in the target
system. `zcl_reservation_gateway_sap` uses `BAPI_RESERVATION_CREATE1` and the
standard BAPI transaction functions. Validate the included minimal signatures
against the target release and configure the target-specific locking roadmap
behavior before productive use. The supplied `EZSTOCK_POOL` enqueue object is
rooted on `MARD`; external processes locking the same table/key collide through
SAP's central enqueue service.

Create the fully wired application with
`zcl_stock_allocation_app=>create_sap( )`, then call `run` with the requests,
simulation flag, and one of the strategy constants on `zcl_stock_allocator`.
The returned result contains all allocation/posting results plus `log_saved` so
callers can detect an operational-audit failure independently of posting.
