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
- Explicit quantity units with `MARA-MEINS` as the canonical base unit and
  material-specific alternative-unit conversion through `MARM-UMREZ/UMREN`.
- Shared plant-level safety-stock protection using `MARC-EISBE`, without
  repeated deductions for multiple storage locations.
- Rejection of invalid quantities, missing request IDs, duplicate request IDs,
  missing stock, and insufficient all-or-nothing stock.
- Simulation mode that calculates allocations without writing them.
- An orchestration service with injectable stock-reader and allocation-writer
  ports.
- An SAP stock reader using `MARD-LABST` and `MARC-EISBE` with one set-oriented
  query, joined to `MARA-MEINS` for the material base unit.
- Transactional reservation posting through `BAPI_RESERVATION_CREATE1`, with
  batch commit, rollback on any create/commit error, and returned document IDs
  and messages. Allocated quantities are posted with `ENTRY_UOM`; standard
  consumption reservations carry cost center (201/251), WBS element (221),
  sales order and item (231), asset and subnumber (241), order (261), or network
  and optional activity (281) account assignments in the reservation header.
- Persistent request-ID claims in the owned `ZSTOCK_ALLOC` table, committed in
  the same LUW as reservation creation.
- Payload-aware idempotent replay: identical productive retries return the
  original allocation and reservation without consuming current stock, while
  changed input under an existing request ID is rejected.
- Versioned idempotency payloads: current claims store payload version `001`;
  legacy or unsupported rows are rejected explicitly before stock is read or a
  reservation can be posted.
- Aggregate availability revalidation after claims and before any BAPI call.
- Exclusive `MARD` stock-pool locks acquired in deterministic key order and
  held through BAPI commit or rollback.
- A production composition entry point with current-state operational audit in
  `ZSTOCK_ALOG` and append-only UUID-keyed history in `ZSTOCK_ALGH`, covering
  both productive and simulation runs.
- Configurable audit-history retention through report
  `ZSTOCK_ALGH_RETENTION`, defaulting to a 365-day dry run and checking
  `S_TABU_NAM` before reading or deleting history.
- Read-only audit-history export through `ZSTOCK_ALGH_EXPORT`, with date,
  request, run-mode, and row-limit filters plus CSV-safe field quoting.

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
Each request must provide `unit_of_measure` equal to the material base unit
returned by `MARA-MEINS` or an internal SAP alternative unit maintained for the
material in `MARM`. Alternative quantities are converted and rounded to the
three-decimal stock precision before allocation. Results expose canonical
`requested_qty`, `allocated_qty`, `shortfall_qty`, and `unit_of_measure`, while
`source_requested_qty` and `source_unit_of_measure` retain the caller's input.
Movement types 201 and 251 require `cost_center`; 221 requires `wbs_element`;
231 requires `sales_order` and `sales_order_item`; 241 requires `asset_number`
and `asset_subnumber`; 261 requires `order_id`; and 281 requires `network_id`
with optional `network_activity`. These fields are part of the idempotency
payload and are retained in operational audit records and CSV exports.
The returned result contains all allocation/posting results plus `log_saved` so
callers can detect an operational-audit failure independently of posting. The
current-state and history records are saved atomically in one audit LUW.
Productive runs consult `ZSTOCK_ALLOC` before reading stock. Completed matching
requests are returned with `Existing reservation reused`; simulations always
recalculate and ignore productive replay state. Existing rows with a blank or
unsupported `PAYLOAD_VERSION` remain fail-safe: productive execution returns
`Stored request payload version is unsupported` and requires the row to be
reconciled during deployment rather than guessing whether its payload matches.

Run `ZSTOCK_ALGH_RETENTION` interactively or schedule it as a background job.
Keep `P_TEST` selected to preview the number of rows older than `P_DAYS`; clear
it only for the productive deletion run. The executing user needs
`S_TABU_NAM` activity `03` for preview and activity `06` for deletion on table
`ZSTOCK_ALGH`.

Run `ZSTOCK_ALGH_EXPORT` to produce semicolon-delimited CSV in an SAP list or
background spool. Blank dates select the latest 30-day window. `P_REQ` and
`P_MODE` narrow the result, while `P_MAX` bounds it to at most 10,000 rows.
If more rows match than `P_MAX`, the report stops and asks for narrower filters
instead of silently producing an incomplete archive.
The executing user needs `S_TABU_NAM` activity `03` for `ZSTOCK_ALGH`. Exported
fields are quoted and embedded quotes are doubled; the report uses a wide list
line so a complete history record is not wrapped.
