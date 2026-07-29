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

## 2026-07-29 - Feature 10: Explicit quantity units

- Extended the stock boundary to return unrestricted quantity together with the material base unit from `MARA-MEINS`.
- Propagated the unit through allocator results, `ZSTOCKALLOC`, report output, and Business Application Log summaries.
- Added a minimal `MARA` standard-table stub and unit-focused assertions.
- Allocation arithmetic continues to use the stockkeeping/base-unit quantities supplied by SAP ATP and inventory tables.
- Missing base-unit master data now rejects the run before logging or persistence and releases an acquired lock.

## 2026-07-29 - Feature 11: Stock reserve buffer

- Added optional report/service reserve quantity `P_RESRV`, defaulting to zero for backward-compatible behavior.
- Subtracted the reserve from the latest observed unrestricted stock and clamped allocatable stock at zero.
- Propagated the selected buffer through allocation rows, `ZSTOCKALLOC`, report output, and BAL summaries.
- Rejected negative buffers before authorization or side effects.
- Added tests for constrained allocation and invalid-buffer ordering.

## 2026-07-29 - Feature 12: Allocation summaries

- Added one pure summary service for demand counts, status counts, requested quantity, allocated quantity, shortage, reserve, and unit.
- Reused it in interactive report output and Business Application Log messages so operational totals cannot drift.
- Added mixed full/partial/none and empty-result tests.

## 2026-07-29 - Feature 13: Persistence audit metadata

- Added creation date, time, and SAP user to every `ZSTOCKALLOC` snapshot row.
- Added change date, time, and SAP user to every saved `ZSTOCKPRIO` row.
- Kept BAL as the historical execution record while making the current database state independently attributable.

## 2026-07-29 - Feature 14: Persistence adapter verification

- Added database-backed ABAP Unit coverage for the productive custom-table adapters rather than proving persistence only through service fakes.
- Verified that allocation saves replace an entire scope snapshot, remove stale schedule lines, and clear the snapshot when demand becomes empty.
- Verified allocation and priority audit metadata together with priority deletion against the transpiled Open SQL runtime.
- Used isolated `ZUT-*` keys and teardown cleanup; no SAP-standard table is modified by the tests.
- Added the official `@abaplint/database-sqlite` driver and a transpiler setup hook so database-backed tests run against the generated DDIC schema.

## 2026-07-29 - Feature 15: SAP read-adapter verification

- Added ephemeral `MARA`, `MARD`, and `VBBE` fixtures to the SQLite-only test setup; productive ABAP continues to treat every SAP-standard table as read-only.
- Added ABAP Unit coverage proving the stock adapter returns unrestricted quantity with the material base unit.
- Simplified the keyed `MARD` lookup to `SELECT SINGLE`, avoiding an unnecessary internal table and the row-shape defect found by the new test.
- Added ABAP Unit coverage proving the demand adapter excludes zero requirements, preserves schedule-line data, defaults missing priority to zero, and joins configured item priority.

## 2026-07-29 - Feature 16: Cross-adapter integration test

- Added a database-backed test that composes the productive stock source, demand source, allocation service, and allocation sink against one generated DDIC schema.
- Verified configured priority ordering, reserve application, base-unit propagation, application-log invocation, commit-scoped lock retention, and persisted row count in one run.
- Kept authorization, enqueue, and BAL behind test doubles because those SAP kernel/application services are outside the open-abap database runtime.
