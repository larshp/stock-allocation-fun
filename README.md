# Stock Allocation for SAP ABAP

An incremental, test-driven stock allocation service for existing SAP systems.
The current implementation ranks demand, protects safety stock, supports partial
fulfillment, and separates pure allocation logic from SAP reads and reservation
writes.

## Implemented features

- Deterministic allocation by ascending priority and request ID.
- Earliest-requirement-date ordering within the same priority.
- Selectable priority/date, date/priority, and priority/request-ID strategies.
- Optional inclusive allocation horizon with an explicit `DEFERRED` outcome for
  later demand.
- All-or-nothing and partial-fulfillment requests.
- Optional full-batch enforcement that prevents every new posting when any new
  request is partial, rejected, invalid, deferred, or otherwise incomplete.
- Per-request minimum fulfillment percentages for partial allocations.
- Plant and storage-location-specific stock pools.
- Explicit quantity units with `MARA-MEINS` as the canonical base unit and
  material-specific alternative-unit conversion through `MARM-UMREZ/UMREN`.
- Shared plant-level safety-stock protection using `MARC-EISBE`, without
  repeated deductions for multiple storage locations.
- Rejection of invalid quantities, missing request IDs, duplicate request IDs,
  missing stock, and insufficient all-or-nothing stock.
- Fail-closed plant authorization through `M_MATE_WRK` activity `02`, checked
  once per plant before idempotency replay or stock access for productive and
  simulation runs.
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
- Cancellation-aware replay: a persisted reservation whose existing `RESB`
  items are all deletion-flagged is allocated again, with its old idempotency
  claim conditionally replaced in the same LUW as the new reservation.
- Versioned idempotency payloads: current claims store payload version `001`;
  legacy or unsupported rows are rejected explicitly before stock is read or a
  reservation can be posted.
- Aggregate availability revalidation after claims and before any BAPI call.
- Exclusive `MARD` stock-pool locks acquired in deterministic key order and
  held through BAPI commit or rollback.
- A production composition entry point with current-state operational audit in
  `ZSTOCK_ALOG` and append-only UUID-keyed history in `ZSTOCK_ALGH`, covering
  both productive and simulation runs.
- One generated run ID per application call, returned to the caller and stored
  on every current-state and history row produced by that call.
- Reconstructable audit context covering material, plant, storage location,
  movement, requirement date, request controls, run controls, account
  assignment, quantities, outcomes, and reservation replacement lineage.
- Stable machine-readable decision codes on allocation results and audit rows,
  so integrations do not need to parse diagnostic message text.
- Configurable audit-history retention through report
  `ZSTOCK_ALGH_RETENTION`, defaulting to a 365-day dry run and checking
  `S_TABU_NAM` before reading or deleting history.
- Read-only audit-history export through `ZSTOCK_ALGH_EXPORT`, with date,
  request, run-mode, run-ID, and row-limit filters plus CSV-safe field quoting.

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
Pass `iv_horizon_date` to limit a run to demand required on or before that
date; leave it initial for no cutoff. New requests after the cutoff are returned
as `DEFERRED` without stock reads, conversion, or posting. A completed matching
productive request still replays its committed reservation even when its date
is beyond the current horizon, because the cutoff does not invalidate prior
work. Deferred requests are not claimed and can be allocated by a later run
when the horizon advances.
Set `iv_require_full_batch` when every new request must be fully allocated
before any new reservation is posted. If one new result is not `ALLOCATED`, all
otherwise pending allocations become `ABORTED`, their allocated quantity is
cleared, and the writer is not called. The original incomplete rows retain
their statuses and messages so the cause remains visible. Simulation applies
the same policy. Previously committed replay rows are reported unchanged and
do not participate in the new-work completeness decision.
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
Only movement types 201, 221, 231, 241, 251, 261, and 281 are admitted. Other
standard or customized movement types are rejected until their field-selection
and account-assignment rules are implemented explicitly. The executing user
needs `M_MATE_WRK` activity `02` for every requested plant. If any plant check
fails, the complete call is returned as invalid before replay records or stock
are read, preserving the service's atomic batch boundary.
The returned result contains all allocation/posting results, a 32-character
hexadecimal `run_id`, and `log_saved` so callers can detect an operational-audit
failure independently of posting. The run ID is generated before allocation
and remains available even if audit saving fails. Every audit row from that
call carries the same run ID, while each history row retains its separate
`LOG_UUID`. Current-state and history records are saved atomically in one audit
LUW. Existing audit rows from before this additive schema change have a blank
run ID.
Each allocation also carries `decision_code`, a stable allocation-layer reason
that is independent of `posting_status` and the human-readable
`posting_message`. Full and partial success use `FULLY_ALLOCATED` and
`PARTIALLY_ALLOCATED`. Stock policy uses `NO_AVAILABLE_STOCK`,
`PARTIAL_NOT_ALLOWED`, and `BELOW_MINIMUM_FILL`. Validation and configuration
use `INVALID_REQUEST`, `REQUEST_RULE_INVALID`, `DUPLICATE_REQUEST_ID`, and
`STRATEGY_UNSUPPORTED`. Replay outcomes use `REPLAY_VERSION_UNSUPPORTED`,
`REPLAY_PAYLOAD_CONFLICT`, `REPLAY_RESERVATION_MISSING`, and
`RESERVATION_REPLAYED`. Boundary outcomes use `OUTSIDE_HORIZON`,
`STOCK_NOT_FOUND`, `BASE_UNIT_MISSING`, `UNIT_CONVERSION_FAILED`,
`PLANT_UNAUTHORIZED`, and `FULL_BATCH_ABORTED`.
Audit rows also retain `material`, `plant`, `storage_location`, `movement_type`,
`requirement_date`, `minimum_fill_pct`, `priority`, `allow_partial`, allocation
strategy, horizon date, full-batch policy, and any prior reservation replaced
after cancellation. These additive columns are blank on pre-upgrade rows. CSV
export emits the same decision context and decision code, so an archived row
can be interpreted without retrieving the original request payload. Audit rows
written before the decision-code column was deployed have a blank code.
Productive runs consult `ZSTOCK_ALLOC` before reading stock. Completed matching
requests are returned with `Existing reservation reused`; simulations always
recalculate and ignore productive replay state. Existing rows with a blank or
unsupported `PAYLOAD_VERSION` remain fail-safe: productive execution returns
`Stored request payload version is unsupported` and requires the row to be
reconciled during deployment rather than guessing whether its payload matches.
Before replaying a completed row, the SAP composition reads its reservation
items from `RESB`. Only an existing reservation whose items are all marked for
deletion is considered cancelled and reopened. Fully or partially consumed
reservations, reservations with any undeleted item, and missing or archived
`RESB` rows remain fail-safe replays. Reopening does not relax payload matching.
The writer conditionally removes the exact old request/document pair and
inserts the replacement claim in its posting LUW; a concurrent retry that no
longer finds that pair rolls back before reservation creation.

Run `ZSTOCK_ALGH_RETENTION` interactively or schedule it as a background job.
Keep `P_TEST` selected to preview the number of rows older than `P_DAYS`; clear
it only for the productive deletion run. The executing user needs
`S_TABU_NAM` activity `03` for preview and activity `06` for deletion on table
`ZSTOCK_ALGH`.

Run `ZSTOCK_ALGH_EXPORT` to produce semicolon-delimited CSV in an SAP list or
background spool. Blank dates select the latest 30-day window. `P_REQ`,
`P_MODE`, and `P_RUN` narrow the result, while `P_MAX` bounds it to at most
10,000 rows.
If more rows match than `P_MAX`, the report stops and asks for narrower filters
instead of silently producing an incomplete archive.
The executing user needs `S_TABU_NAM` activity `03` for `ZSTOCK_ALGH`. Exported
fields, including the complete decision context, are quoted and embedded quotes
are doubled; the report uses a wide list line so a complete history record is
not wrapped.
