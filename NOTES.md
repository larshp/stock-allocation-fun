# Development notes

## 2026-07-29 - Feature 1: FIFO stock allocation

- Added a deterministic allocator that distributes available stock by requested delivery date, sales order, item, and schedule line.
- Full, partial, and unallocated demand are represented explicitly; non-positive demand is ignored and negative available stock is clamped to zero.
- Kept business logic independent of SAP database access through stock-source, demand-source, and allocation-sink interfaces.
- The SAP adapters read unrestricted stock from `MARD`, read open customer requirements from `VBBE`, and write only the custom `ZSTOCKALLOC` table.
- The executable report deliberately owns the transaction boundary. The reusable service does not issue `COMMIT WORK`, so it composes safely inside an existing SAP LUW.
- `sap_stubs` contains only SAP-standard development-time definitions. Every custom object remains in `src`.
- Verification is provided by abaplint, the open-abap transpiler, and ABAP Unit tests executed by the transpiled runtime.

## Next safe increments

- Add configurable allocation priorities without changing the FIFO default.
- Add enqueue/dequeue protection and an optimistic re-read before persistence for concurrent productive runs.
- Add an application log adapter and authorization checks appropriate to the target SAP system.
- Add a posting adapter if allocations must update confirmed schedule-line quantities rather than remain planning records; use the target system's released sales-order API instead of direct standard-table updates.
