# Implementation notes

## 2026-08-18

- Created the Node-based ABAP development toolchain with pinned abaplint and
  transpiler versions. Both configurations load `open-abap-core`; SAP standard
  stubs are also transpiler inputs.
- Added `zcl_stock_allocator` as a side-effect-free domain service. Smaller
  numeric priorities run first, with request ID as a deterministic tie-breaker.
- Available quantity is bounded by both the selected location's `MARD-LABST`
  and the material/plant total remaining after one shared `MARC-EISBE` reserve.
  Quality and blocked stock are intentionally excluded.
- Stock reads join `MARA-MEINS`, and every request must name an internal SAP
  unit. `zcl_unit_converter` normalizes alternative units with cached
  material-specific `MARM-UMREZ/UMREN` factors and three-decimal rounding.
  Revalidation checks the canonical unit again, reservation items set
  `ENTRY_UOM`, and audit/export retain source and canonical quantities and units.
- All-or-nothing shortages consume no stock, so lower-priority requests can
  still use the balance. Partial requests consume only the available quantity.
- Added `zcl_stock_allocation_service`, `zif_stock_reader`, and
  `zif_allocation_writer`. Simulation uses the same calculation but skips the
  writer. Only positive allocations are sent to the writer.
- Added `zcl_stock_reader_sap`, which reads all requested stock keys in one
  `FOR ALL ENTRIES` query. Minimal `MARD` and `MARC` definitions live under
  `sap_stubs/` and are not deployable custom objects.
- Added `zcl_allocation_writer_sap` and `zcl_reservation_gateway_sap`.
  Successful allocations create individual material reservations, then commit
  once for the batch. Any BAPI create error, missing reservation number, or
  commit error rolls back the LUW and marks every allocation as failed.
- Allocation results now retain posting inputs and return posting status,
  reservation number, and error text. Simulation results are explicitly marked
  `SIMULATED`.
- Equal-priority requests are ordered by earliest requirement date before the
  request-ID tie-breaker.
- Added minimal standard stubs for `BAPI_RESERVATION_CREATE1`,
  `BAPI_TRANSACTION_COMMIT`, `BAPI_TRANSACTION_ROLLBACK`, and their reservation
  structures under `sap_stubs/`.
- Added `zif_idempotency_store`, `zcl_idempotency_store_sap`, and the owned
  `ZSTOCK_ALLOC` table. The unique request-ID key is claimed before a BAPI call;
  the reservation number is recorded before the same batch commit. A duplicate
  claim or failed update triggers BAPI rollback, which also rolls back the
  database changes in the shared SAP LUW.
- `ZSTOCK_ALLOC` now retains request identity, allocation policy, canonical
  quantities, and the committed outcome. Productive execution loads completed
  records before stock allocation: an identical retry reuses its reservation
  without consuming current stock, while changed input under the same ID is
  rejected. A claim collision arising after that pre-read remains fail-safe and
  rolls back, allowing a later retry to observe the completed record.
- Added standard consumption account assignments across request validation,
  allocation results, stock recheck, reservation headers, idempotency identity,
  audit storage, and CSV export. Movement 201 requires a cost center, 221 a WBS
  element, and 261 an order.
- Extended the same account-assignment contract to movement 231 (sales order
  and item), 241 (asset and subnumber), 251 (cost center), and 281 (network,
  with optional activity). The reservation gateway uses the corresponding
  `BAPI2093_RES_HEAD` fields. External WBS identifiers are mapped through
  `WBS_ELEMENT`, rather than the internal numeric `WBS_ELEM` representation.
- Added `PAYLOAD_VERSION` to `ZSTOCK_ALLOC`. New claims persist version `001`;
  completed rows are replayable only when their version is supported. Blank
  pre-upgrade rows and future unknown versions now produce a distinct invalid
  result before the stock read and writer, making the deployment boundary
  explicit without risking a duplicate reservation.
- Added a per-request minimum fulfillment percentage. A partial request below
  its threshold is rejected without consuming stock.
- Added three allocation ordering strategies: priority then requirement date,
  requirement date then priority, and priority then request ID. Unsupported
  strategy values return `CONFIG_ERROR` results without posting.
- Added `zcl_stock_rechecker_sap`. After all idempotency claims and before the
  first BAPI call, it rereads stock and compares the aggregate allocation for
  each material/plant/storage-location pool with unrestricted stock minus
  safety stock. Missing or reduced stock rolls back the whole batch.
- Added the `EZSTOCK_POOL` enqueue object and `zcl_stock_lock_sap`. Unique stock
  pools are locked exclusively in sorted material/plant/storage-location order
  before revalidation. Locks use scope 3 and are explicitly released after
  commit or after rollback on every failure path. A lock collision fails the
  batch before any reservation BAPI is invoked.
- Added `zcl_stock_allocation_app=>create_sap( )` as the production composition
  root. It wires the reader, rechecker, idempotency store, reservation gateway,
  writer, service, and operational logger.
- Added the owned `ZSTOCK_ALOG` table and `zcl_allocation_logger_sap`. It keeps
  the latest productive and simulation outcome per request and reports logging
  success separately from allocation/posting success.
- Added append-only `ZSTOCK_ALGH` audit history and
  `zif_allocation_log_store`. Each outcome receives a RAW16 UUID; the SAP store
  saves current-state and history rows atomically, rolling both back if either
  write fails. Its client/date/UUID primary-key order supports retention scans
  by cutoff date without a separate database index.
- Added `zcl_allocation_log_retention`,
  `zif_allocation_history_store`, and executable report
  `ZSTOCK_ALGH_RETENTION`. Cleanup defaults to a 365-day simulation, validates
  positive retention periods, checks table display/delete authorization, and
  reports affected rows before a separately requested productive deletion.
- Added `zif_allocation_history_reader`, `zcl_allocation_history_reader`,
  `zcl_allocation_log_export`, and report `ZSTOCK_ALGH_EXPORT`. Reads require
  table-display authorization and accept date, request-ID, and run-mode filters
  with a hard 10,000-row ceiling. The reader fetches one extra row and rejects a
  would-be truncated export instead of presenting it as complete. The report
  emits quote-escaped, semicolon-delimited CSV to a 1023-character SAP list or
  background spool.
- SAP reads now return all storage locations for requested material/plant pairs.
  Allocation and posting revalidation sum unrestricted stock by plant, take the
  maximum repeated `MARC-EISBE` value as one reserve, and still enforce each
  requested location's physical quantity.
- Added seventy-six transpiled ABAP Unit scenarios covering allocation policy,
  validation, orchestration, posting success, create failure, missing document
  IDs, commit failure, rollback, idempotency, persistence failure, and empty
  batches, stale-stock rechecks, strategy selection, application composition,
  and logging delegation.

## Policy decisions

- Allocation results are returned in processing order, not input order.
- A missing stock row is treated as zero available stock.
- Request IDs are unique within one execution and persist across productive
  executions. Exact completed retries are replayed; payload conflicts are
  invalid, and simulations deliberately ignore replay state.
- Persisted replay compatibility is opt-in by payload version. Missing or
  unsupported versions are never inferred from partially populated fields.
- The allocation writer is a required dependency even for a service commonly
  used in simulation; this keeps productive construction explicit.
- Reservation posting is atomic at the allocation batch level: one failed item
  rolls back all reservation creations in that call.
- Idempotency claims deliberately use the same SAP LUW as reservation creation;
  no independent commit is issued by the store.
- Cost center, order, and WBS element are identity-bearing request fields.
  Productive retries must match the original account assignment exactly.
- Operational audit persistence occurs after posting and has its own commit.
  An audit failure is surfaced through `log_saved` but cannot undo an already
  committed reservation batch. Within that audit LUW, current-state and
  append-only history records succeed or roll back together.
- Audit-history cleanup is a separate administrative LUW. The executable report
  defaults to simulation; productive deletion must be explicitly selected and
  authorized through `S_TABU_NAM` for `ZSTOCK_ALGH`.
- Audit export is read-only and destination-neutral: the report produces an SAP
  list/spool so each landscape can apply its own approved transfer and archive
  controls without granting the allocation application filesystem access.
- Canonical allocation arithmetic always uses `MARA-MEINS`. Base-unit requests
  bypass factor lookup; alternative requests use the material's `MARM` factor.
  Missing, zero, or invalid factors reject the request without consuming stock.
  The caller's original request quantity/unit remains on the result and audit
  row alongside the converted request and allocation.
- The transpiler configuration explicitly renames the JavaScript keyword
  `return`; this preserves the standard BAPI `RETURN` parameter during local
  transpilation.
