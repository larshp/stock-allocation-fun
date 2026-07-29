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

- Add a posting adapter if allocations must update confirmed schedule-line quantities rather than remain planning records; use the target system's released sales-order API instead of direct standard-table updates.

## 2026-07-29 - Feature 2: Concurrency-safe runs

- Added an allocation-lock boundary and SAP adapter using standard `ENQUEUE_E_TABLE` and `DEQUEUE_E_TABLE` APIs.
- Serialized allocation runs before reading demand or stock. Successful scope-2 locks remain held until the caller commits the SAP LUW; failed runs dequeue explicitly before propagating wrapped collaborator failures.
- Added an optimistic stock re-read after demand retrieval; allocation always uses the latest observed quantity.
- Added tests for successful commit-scoped retention, overlapping-run rejection, changing stock, exceptional release, and preservation of the original exception chain.

## 2026-07-29 - Feature 3: Configurable demand priority

- Added optional item priorities in `ZSTOCKPRIO` without changing SAP standard order data.
- Higher integer priorities allocate first; equal priorities continue to use delivery date, order, item, and schedule-line FIFO ordering.
- Persisted the effective priority with each allocation for auditability.
- Added a focused allocator test proving that priority precedes delivery date.

## 2026-07-29 - Feature 4: Authorization enforcement

- Added authorization class `ZSTK` and object `ZSTK_RUN` with execute activity `16`.
- Added a testable authorization boundary; the SAP adapter uses `AUTHORITY-CHECK`.
- Authorization is evaluated before the enqueue request, stock reads, demand reads, or allocation writes.
- Added a denied-path test proving an unauthorized run produces no persistence or lock side effects.

## 2026-07-29 - Feature 5: Transactional application logging

- Added application-log object `ZSTOCKALLOC` with subobject `RUN` and a testable logging boundary.
- Added a classic SAP BAL adapter using `BAL_LOG_CREATE`, `BAL_LOG_MSG_ADD_FREE_TEXT`, and `BAL_DB_SAVE` for broad on-premise compatibility.
- Saved only the newly created log handle rather than every log in the current internal session.
- Logging occurs before allocation persistence in the same SAP LUW; a logging failure aborts the run, releases the enqueue, and leaves the allocation sink untouched.
- Added a failure-path test proving logging is mandatory and lock cleanup still occurs.

## 2026-07-29 - Feature 6: Side-effect-free simulation

- Extracted one calculation path shared by committed runs and previews, preventing behavioral drift.
- Added a `PREVIEW` service method that performs authorization and fresh stock/demand reads without enqueue, application log, persistence, or transaction control.
- Added report parameter `P_SIM`, selected by default, so interactive execution is safe unless persistence is explicitly requested.
- Added a service test proving simulation returns allocations without invoking any side-effect boundary.

## 2026-07-29 - Feature 7: Key-scoped concurrency

- Replaced the table-wide enqueue with an `RSTABLE-VARKEY` prefix containing client, material, plant, and storage location in the exact `ZSTOCKALLOC` primary-key order.
- Retained scope-2 ownership through commit while allowing unrelated allocation scopes to run concurrently.
- Centralized key construction so acquisition and exceptional release cannot drift.
- Strengthened service tests to prove both enqueue and dequeue receive the exact requested scope.

## 2026-07-29 - Feature 8: Controlled priority maintenance

- Added report `ZSTOCK_PRIORITY` and a dependency-injected maintenance service for saving and removing item priorities.
- Added authorization object `ZSTK_PRI`, separating change activity `02` from delete activity `06`.
- Reused the allocation scope lock so a priority cannot change while the matching allocation plan is being calculated or committed.
- Kept successful locks until commit and explicitly released failed writes with their original exception chain preserved.
- Added four tests covering save, remove, denied authorization, and persistence failure.

## 2026-07-29 - Feature 9: Service-boundary validation

- Added one reusable validator for allocation scopes and priority keys.
- Applied validation at committed, preview, and priority-maintenance service boundaries rather than relying only on report selection screens.
- Invalid material/plant/storage-location or sales-order/item keys fail before authorization checks and every external side effect.
- Added service tests proving invalid calls do not request authorization, enqueue, application logging, or persistence.
