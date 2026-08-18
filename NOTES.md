# Implementation notes

## 2026-08-18

- Created the Node-based ABAP development toolchain with pinned abaplint and
  transpiler versions. Both configurations load `open-abap-core`; SAP standard
  stubs are also transpiler inputs.
- Added `zcl_stock_allocator` as a side-effect-free domain service. Smaller
  numeric priorities run first, with request ID as a deterministic tie-breaker.
- Available quantity is `MARD-LABST - MARC-EISBE`, floored at zero. Quality and
  blocked stock are intentionally excluded.
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
- Added thirty-two transpiled ABAP Unit scenarios covering allocation policy,
  validation, orchestration, posting success, create failure, missing document
  IDs, commit failure, rollback, idempotency, persistence failure, and empty
  batches, stale-stock rechecks, strategy selection, application composition,
  and logging delegation.

## Policy decisions

- Allocation results are returned in processing order, not input order.
- A missing stock row is treated as zero available stock.
- Request IDs are unique within one execution. Cross-execution idempotency is a
  later persistence feature.
- The allocation writer is a required dependency even for a service commonly
  used in simulation; this keeps productive construction explicit.
- Reservation posting is atomic at the allocation batch level: one failed item
  rolls back all reservation creations in that call.
- Idempotency claims deliberately use the same SAP LUW as reservation creation;
  no independent commit is issued by the store.
- Operational audit persistence occurs after posting and has its own commit.
  An audit failure is surfaced through `log_saved` but cannot undo an already
  committed reservation batch.
- The transpiler configuration explicitly renames the JavaScript keyword
  `return`; this preserves the standard BAPI `RETURN` parameter during local
  transpilation.
