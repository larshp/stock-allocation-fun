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

## 2026-07-29 - Feature 17: Plant-scoped authorization

- Added `WERKS` to both `ZSTK_RUN` and `ZSTK_PRI`, preventing an activity grant from implicitly authorizing every plant.
- Passed the validated requested plant into allocation execution, simulation, priority save, and priority deletion authorization checks.
- Extended service tests to prove the exact plant reaches each authorization boundary before locking or data access.

## 2026-07-29 - Feature 18: SAP-semantic boundary types

- Replaced anonymous material, plant, storage-location, sales-document, schedule-line, date, and unit typedefs with components of `MARD`, `VBBE`, and `MARA`.
- Productive report parameters now inherit the target SAP system's DDIC semantics and conversion behavior instead of only matching field lengths.
- Kept quantities and allocation status as application-owned types while the separate standard stubs preserve deterministic local linting and transpilation.

## 2026-07-29 - Feature 19: Scalable priority lookup

- Replaced the demand adapter's repeated linear priority scan with a uniquely keyed hashed table by sales order and item.
- Priority enrichment is now constant-time per open requirement while preserving the default priority of zero and existing FIFO behavior.

## 2026-07-29 - Feature 20: Operational failure signaling

- Replaced normal list output for caught allocation and priority-maintenance failures with exception-based error messages after rollback.
- Failed dialog or background executions now expose an error state instead of producing output that can be mistaken for a successful run.

## 2026-07-29 - Feature 21: Bulk snapshot persistence

- Replaced one `MODIFY` per allocation row with a single bulk custom-table write after the old scope snapshot is removed.
- Captured creation date, time, and user once per save so every row in a persisted snapshot carries identical audit provenance.
- Empty allocation results still clear stale rows without issuing an unnecessary bulk write.

## 2026-07-29 - Feature 22: Demand-contract validation

- Added service-boundary validation for every positive open demand before allocation, logging, or persistence.
- Rejected incomplete sales-order/item/schedule-line keys, missing material-availability dates, and duplicate schedule-line keys.
- Added a failure-path test proving malformed collaborator data releases the acquired lock and cannot reach BAL or the allocation sink.
- Added focused validator tests for incomplete positive demands and intentionally ignored non-positive rows.

## 2026-07-29 - Feature 23: Separate simulation authorization

- Added display activity `03` to plant-scoped authorization object `ZSTK_RUN` while retaining activity `16` for committed execution.
- Simulation-only users can now calculate plans without receiving permission to replace persisted allocation snapshots.
- Extended service tests to prove committed runs request `16` and previews request `03` for the validated plant.

## 2026-07-29 - Feature 24: Shortage-aware application logs

- Changed the BAL summary severity from success to warning whenever the calculated shortage quantity is positive.
- Fully covered and empty-demand runs remain success entries, while constrained plans are visible to standard application-log monitoring without parsing free text.

## 2026-07-29 - Feature 25: DDIC quantity semantics

- Changed requested, allocated, shortage, and reserve persistence fields from generic decimals to `QUAN` fields.
- Added explicit `ZSTOCKALLOC-MEINS` reference metadata to every persisted quantity so standard SAP dictionary, display, and reporting tools retain unit context.

## 2026-07-29 - Feature 26: Bounded priority reads

- Skipped the priority query entirely when the selected scope has no positive open requirements.
- Restricted priority retrieval with `FOR ALL ENTRIES` to sales-order items present in the selected VBBE result instead of loading every configured priority in the scope.
- Retained the hashed-table lookup for constant-time enrichment after the bounded database read.

## 2026-07-29 - Feature 27: Cross-release DDIC keys

- Linked custom allocation and priority table keys to standard SAP data elements for material, plant, storage location, sales document, item, and schedule line.
- Linked allocation date and unit fields to `MBDAT` and `MEINS`, preserving conversion exits and semantic metadata in productive SAP tools.
- The custom table material key now follows the target release's `MATNR` definition, keeping persisted and generic-lock key layouts consistent across ECC and S/4HANA.

## 2026-07-29 - Feature 28: Complete plan context

- Added a plan result containing observed stock, allocatable stock, reserve, unit, and allocation rows while retaining the original table-returning service methods for compatibility.
- Routed the executable report and BAL adapter through the richer plan result, preserving quantity/unit context even when a scope has no open demand.
- Expanded summaries and operational output with observed and allocatable stock quantities.

## 2026-07-29 - Feature 29: Synchronous commit verification

- Added explicit `sy-subrc` checks after `COMMIT WORK AND WAIT` in both executable reports.
- A failed synchronous allocation or priority commit now enters the existing rollback/error path instead of displaying a success result.
- Completed the installation checklist with both authorization objects and their containing authorization class.

## 2026-07-29 - Feature 30: Storage-location authorization

- Added `LGORT` to both custom authorization objects alongside activity and plant.
- Passed the validated storage location through allocation execution, simulation, priority save, and priority deletion checks.
- Extended allocation and priority service tests to prove the exact plant/storage scope reaches authorization before locking or data access.

## 2026-07-29 - Feature 31: Transaction-safe report output

- Delayed priority save/remove success output until after the synchronous commit check, preventing misleading success spools when commit fails.
- Added material, plant, and storage-location scope to allocation output and echoed the complete priority-maintenance key.
- Added material-availability date to allocation detail rows so the visible result explains FIFO ordering.

## 2026-07-29 - Feature 32: Executable repository invariants

- Added a dependency-free repository check to the default test pipeline.
- The gate verifies every mandated abaplint rule, both open-abap-core dependencies, `sap_stubs` inclusion, the `/src/` abapGit import boundary, placement of every custom Z object, and absence of MARA/MARD/VBBE writes in custom ABAP.
- Future changes can no longer satisfy `npm test` after silently weakening the structural constraints in `PLAN.md`.
- The gate also protects operational delivery classes, unbuffered mutable tables, activity/plant/storage authorization fields, required activities, and both BAL subobjects.

## 2026-07-29 - Feature 33: Verified persistence outcomes

- Added checked allocation and priority sink contracts that can report persistence failures explicitly.
- Bulk allocation saves read back the scope cardinality and require it to match the complete validated snapshot, preventing partial writes from being treated as success.
- Priority upserts read back the exact saved value; deletion remains intentionally idempotent and verifies that the key is absent afterward.

## 2026-07-29 - Feature 34: Client-portable database fixtures

- Removed the hard-coded open-abap client from SQLite fixtures.
- Database-backed source and integration tests now derive their client key from runtime `sy-mandt`, avoiding coupling to a particular emulator default.

## 2026-07-29 - Feature 35: Priority change application logs

- Added BAL subobject `PRIORITY` and a dedicated logging boundary for priority saves and removals.
- Recorded scope, sales-order item, activity, priority value, date, time, and user in the same SAP LUW as the priority change.
- Made audit logging mandatory before persistence and added a failure-path test proving an unlogged priority change releases its lock and cannot reach the sink.

## 2026-07-29 - Feature 36: Target-SAP verification checklist

- Converted the remaining environment limitation into explicit acceptance steps for DDIC activation, scoped roles, enqueue concurrency, source-data reconciliation, BAL history, rollback, and commit behavior.
- The checklist separates locally proven behavior from the SAP kernel and release-specific evidence required before productive scheduling.

## 2026-07-29 - Feature 37: Overflow-safe summary totals

- Kept individual stock and demand quantities aligned with the packed 15-digit persistence fields while moving aggregate summary quantities to `DECFLOAT34`.
- Added a regression test summing two individually valid maximum quantities beyond the packed-number ceiling.
- Large allocation scopes can now be summarized and logged without arithmetic overflow solely because their valid rows exceed one line's numeric range.

## 2026-07-29 - Feature 38: Operational priority lifecycle

- Corrected `ZSTOCKPRIO` from customizing delivery class `C` to application-data class `A`.
- Sales-order-specific priorities now remain client-local operational records rather than being treated as configuration intended for cross-system transport.

## 2026-07-29 - Feature 39: Selectable allocation strategies

- Retained priority/FIFO as the backward-compatible default and added proportional, max-min fair-share, and smallest-demand-first strategies.
- Applied each strategy independently inside strict descending priority tiers, so lower-priority demand cannot consume stock needed by a higher tier.
- Made proportional rounding deterministic and stock-conserving by recalculating each share from the remaining stock and remaining demand.
- Made fair sharing complete small demands first and divide the balance among larger demands without exceeding any request.
- Added a smallest-first policy that maximizes the count of completely supplied schedule lines inside each tier.
- Propagated the effective strategy through plan and allocation results, committed snapshots, report output, and BAL run summaries.
- Rejected unknown strategy codes before authorization, locking, reads, logging, or persistence.
- Added allocator, service, validator, and Open SQL persistence tests for strategy behavior, tier isolation, rounding conservation, audit propagation, and failure ordering.

## 2026-07-29 - Feature 40: Consistent strategy comparison

- Added `PREVIEW_ALL_STRATEGIES` to calculate FIFO, proportional, max-min fair-share, and smallest-first plans from one stock and demand snapshot.
- Reused the display-only authorization and reserve/scope validation while keeping comparison free of locks, logs, persistence, and commits.
- Added report option `P_COMP` with comparable fulfillment counts, allocated quantity, and shortage quantity for every strategy.
- Refactored context loading from plan construction so comparison performs one initial stock read, one demand read, and one latest-stock recheck instead of observing different data per strategy.
- Added a service test proving all four plans share the latest stock snapshot and no side-effect boundary is invoked.

## 2026-07-29 - Feature 41: Fulfillment KPIs

- Added quantity fill percentage (`allocated / requested`) and complete-demand service-level percentage (`full demand lines / demand lines`) to allocation summaries.
- Defined both KPIs as zero for empty demand sets, avoiding division failures in reports and BAL logging.
- Displayed the KPIs in normal runs and strategy comparisons and included them in committed run logs.
- Added exact and empty-result unit coverage for both calculations.

## 2026-07-29 - Feature 42: Demand planning horizon

- Added optional report/service cutoff date `P_CUTOF`; blank preserves the existing all-open-demand behavior.
- Pushed dated horizon filtering into the productive `VBBE` query before priority enrichment, reducing both requirement and priority-read volume.
- Applied the same cutoff to selected-strategy previews, committed runs, and single-snapshot strategy comparisons.
- Propagated the effective cutoff through plans, allocation rows, `ZSTOCKALLOC`, report scope output, and BAL run summaries.
- Added database-backed adapter coverage for the cutoff and service coverage for source propagation and plan-row audit metadata.

## 2026-07-29 - Feature 43: Complete-only allocation

- Added strategy `C` for operations that prohibit partial shipments.
- Preserved FIFO evaluation inside each priority tier, skipped demands that could not be supplied completely, and continued looking for a later complete fit in the same tier.
- Held any unused stock when that tier remained incomplete, preventing a lower priority from consuming stock withheld from an unsatisfied higher tier.
- Included the policy in validation, single-snapshot comparison, repository invariants, and cross-strategy priority coverage.

## 2026-07-29 - Feature 44: Objective-based recommendation

- Added pure strategy selection for service objective `S` and quantity objective `Q`.
- Ranked service recommendations by full demand lines, allocated quantity, then fewer partial lines; ranked quantity recommendations by allocated quantity, full lines, then fewer partial lines.
- Kept exact ties stable in comparison order, yielding FIFO when all five productive candidates are equivalent.
- Exposed `P_OBJ` and the recommended strategy in side-effect-free comparison output without automatically persisting the recommendation.
- Added focused tests for both objectives, deterministic ties, and invalid recommendation inputs.

## 2026-07-29 - Feature 45: Stock-utilization KPIs

- Added unused allocatable quantity and stock-utilization percentage to allocation summaries.
- Clamped unused quantity at zero for defensive handling of externally supplied result tables and defined utilization as zero when allocatable stock is zero.
- Exposed both measures in selected-plan output, five-strategy comparison, and committed BAL summaries.
- Added empty-plan and exact 50-percent utilization coverage.

## 2026-07-29 - Feature 46: Fulfillment fairness

- Added Jain's fairness index over positive-demand fulfillment ratios as a normalized 0-to-100 summary KPI.
- Defined fairness as zero when no demand receives stock and ignored nonpositive requested quantities defensively.
- Added comparison objective `F`, ranked by fairness, then allocated quantity, then completely supplied lines.
- Exposed fairness in selected-plan output, five-strategy comparison, BAL summaries, repository invariants, and target-system guidance.
- Added exact equal-share and concentrated-allocation KPI tests, a selector test that recommends proportional allocation, and an end-to-end comparison assertion using real candidate plans.

## 2026-07-29 - Feature 47: Complete BAL strategy evidence

- Split the expanding allocation audit summary into context, quantity, fulfillment, and utilization/fairness messages rather than relying on one oversized free-text entry.
- Checked every message insertion and retained the existing rule that any incomplete audit log aborts allocation persistence.
- Preserved shortage-aware warning severity consistently across every message in the run.

## 2026-07-29 - Feature 48: Stable planning snapshots

- Bracketed each demand read with stock reads so a plan is built only when its stock context remains unchanged while requirements are loaded.
- Retried the complete stock/demand snapshot up to three times when unrestricted stock moves during the read.
- Rejected continuously volatile snapshots before logging or persistence, with committed runs releasing their scope lock through the existing failure path.

## 2026-07-29 - Feature 49: Transparent recommendation ties

- Added a recommendation API that returns every strategy tied on the complete objective-specific ranking tuple.
- Retained the first tied strategy as the backward-compatible deterministic primary recommendation.
- Exposed equivalent best strategies in comparison output so planners can distinguish a unique recommendation from an input-order tie.

## 2026-07-29 - Feature 50: Shortage urgency indicators

- Added the number of demands affected by shortage and their earliest material-availability date to allocation summaries.
- Exposed both indicators in selected-plan and cross-strategy output, making equally sized shortages easier to prioritize operationally.
- Recorded the shortage count and earliest affected date in the checked BAL run evidence.

## 2026-07-29 - Feature 51: Due-date urgency recommendations

- Added comparison objective `D` to prefer plans with no shortage or, when every plan is constrained, the latest earliest-shortage date.
- Broke equal dates by fewer affected demands and then lower shortage quantity while preserving stable comparison order for exact ties.
- Protected the new objective in repository invariants and covered its end-to-end recommendation behavior.
