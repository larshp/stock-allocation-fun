# Stock allocation for SAP

This repository contains a small, production-oriented ABAP stock-allocation service. It reads unrestricted-use stock from `MARD`, reads open sales requirements from `VBBE`, applies optional demand priorities from `ZSTOCKPRIO`, allocates stock with a selectable deterministic strategy, and persists the result in `ZSTOCKALLOC`.

## Design

The pure allocator has no SAP dependencies. Interfaces isolate reads, writes, locking, authorization, and audit logging, while SAP-specific adapters live at the edge. This makes the allocation rule ABAP Unit-testable and keeps standard tables read-only. The report `ZSTOCK_ALLOCATE` is the transaction boundary and commits the completed allocation run. Authorization is checked before locking or database access, a client/material/plant/storage-location SAP lock remains held until that commit, stock is re-read immediately before persistence, and each successful plan is written to the Business Application Log in the same logical unit of work. Unrelated allocation scopes can run concurrently.

Allocation statuses are `F` (full), `P` (partial), and `N` (none). Quantities carry the material base unit read from `MARA`, the unit in which SAP manages material stock. Results retain the sales-order schedule-line key, so multiple requirements for one item cannot overwrite each other. Re-running the report replaces the planning records for the selected material, plant, and storage location.

`P_RESRV` keeps a non-negative quantity of unrestricted stock outside the allocation pool. The buffer applies identically to simulation and committed execution, and its value is persisted and included in the application-log summary. If the buffer exceeds stock, allocatable stock is zero.

`P_CUTOF` optionally limits the planning horizon by material-availability date. Leave it blank to include every positive open requirement, or enter a date to read only `VBBE` schedule lines whose `MBDAT` is on or before that date. The cutoff applies identically to a selected strategy and to `P_COMP`, is pushed into the database query before priority enrichment, and is retained in plan rows, persisted snapshots, report output, and BAL summaries.

Priorities are optional signed integers stored as client-dependent application data in `ZSTOCKPRIO` for a material, plant, storage location, sales order, and item. Maintain them through report `ZSTOCK_PRIORITY`; its save and delete paths use the same allocation-scope lock, so configuration cannot change during an allocation run. Higher values allocate first. Equal priorities—including the default value zero—retain FIFO ordering, so existing behavior is unchanged when no configuration exists.

`P_STRAT` selects how constrained stock is distributed among demands with the same priority. `F` is strict FIFO by material-availability date and remains the default. `P` allocates proportionally to requested quantity. `E` applies max-min fair sharing: small demands are completed first, then the remaining stock is divided equally among larger demands. `S` serves the smallest demands first, maximizing the number of fully supplied schedule lines in the tier. `C` is complete-only FIFO: it skips requests that cannot be supplied completely and never creates partial shipments. If any demand in a priority tier remains incomplete under `C`, unused stock is held instead of passing to a lower tier. All strategies process higher-priority tiers first, use sales-order keys as deterministic tie breakers, conserve stock through three-decimal rounding, and never allocate more than requested. The effective code is shown in report output, persisted per allocation row, and recorded in the application-log summary.

Select `P_COMP` to compare all five policies in one side-effect-free run. The service reads and rechecks stock once, reads demand once, and calculates every candidate from that same snapshot. The report displays full, partial, and unallocated demand counts, quantity fill percentage, complete-demand service-level percentage, stock-utilization percentage, normalized fulfillment fairness, allocated and shortage quantities, and unused allocatable stock for each strategy; comparison never locks, logs, persists, or commits.

`P_OBJ` controls the deterministic recommendation printed by comparison. `S` maximizes the number of completely supplied demand lines, then allocated quantity, then minimizes partial lines. `Q` maximizes allocated quantity, then completely supplied lines, then minimizes partial lines. `F` maximizes Jain's fairness index across each demand's fulfillment ratio, then allocated quantity, then completely supplied lines. Fairness is reported from 0 to 100; equal fulfillment ratios score 100, while concentrated allocation scores lower. Exact ties retain comparison order, making FIFO the stable default when every outcome is equivalent. The recommendation is advisory; only a normal non-simulation run using `P_STRAT` persists a plan.

Simulation requires display activity `03` and committed execution requires activity `16`, together with the requested plant (`WERKS`) and storage location (`LGORT`), on authorization object `ZSTK_RUN`. This allows planners to preview without receiving permission to replace persisted plans or access unrelated inventory scopes.

Priority maintenance uses authorization object `ZSTK_PRI`: activity `02` saves a priority and activity `06` removes one, both restricted by plant (`WERKS`) and storage location (`LGORT`). Successful changes retain their scope lock until the report commits. Every save and removal is recorded under application-log subobject `PRIORITY`, preserving deletion history after the current priority row is gone.

The report starts in simulation mode. Leave `P_SIM` selected to calculate and display a fresh plan—including the selected reserve buffer—without enqueueing, logging, persisting, or committing. Clear it only when the displayed scope should replace the saved allocation plan.

Execution summaries are stored under application-log object `ZSTOCKALLOC`, subobject `RUN`. Checked context, quantity, and KPI messages include observed stock, allocatable stock, reserve, demand, allocation, shortage, unused stock, fill, service, utilization, fairness, and unit even when no demand rows exist. Splitting the summary keeps each entry readable within SAP BAL text limits. A failure adding any message or saving the log aborts allocation persistence, ensuring a committed plan always has a complete audit entry. Current allocation rows also retain their creation date, time, and SAP user; priority rows retain corresponding change metadata. View log entries with the target system's application-log viewer (commonly transaction `SLG1`).

## Install in SAP

Clone the repository with abapGit. Its configuration imports only `/src/`; `sap_stubs` remains outside the SAP source folder because those definitions model SAP-standard objects only for local linting/transpilation. Confirm the standard `MARD` and `VBBE` fields in the target release, activate `ZSTOCKALLOC`, `ZSTOCKPRIO`, authorization class `ZSTK`, authorization objects `ZSTK_RUN` and `ZSTK_PRI`, and application-log object `ZSTOCKALLOC`, assign the plant/storage-scoped authorizations, and perform a target-system integration test before scheduling productive runs.

## Target-system verification

1. Activate every `/src/` object and confirm the custom table key data elements match the target release's material and sales-document definitions.
2. Test a display-only role (`ZSTK_RUN`, activity `03`) and prove it can simulate only its assigned plant/storage scopes and cannot execute.
3. Test execute (`16`) and priority change/delete (`02`/`06`) roles against both allowed and denied storage locations.
4. Start overlapping allocation and priority sessions: the same scope must conflict, while a different material/plant/storage scope must proceed.
5. Compare `F`, `P`, `E`, `S`, and `C` simulations for one constrained priority tier, verify `P_OBJ` recommendations for service, quantity, and fairness goals, test both blank and dated `P_CUTOF`, then reconcile each calculation with `MARD-LABST`, `MARA-MEINS`, and the selected positive `VBBE-OMENG` schedule lines.
6. Verify `RUN` and `PRIORITY` entries in the application-log viewer, including warning severity for shortages and retained history after priority deletion.
7. Force a reversible failure before commit and confirm allocation rows, priority changes, and BAL entries roll back together; then verify successful synchronous commits release their locks.

## Local verification

Requirements: Node.js and npm.

```text
npm install
npm test
```

Both tool configurations load `open-abap/open-abap-core`. The lint configuration includes `src` and `sap_stubs` and enables all rules required by [PLAN.md](PLAN.md). `npm test` first verifies these repository invariants and rejects SAP-standard table writes from custom ABAP. The transpiler then initializes an ephemeral SQLite database from the generated DDIC schema, allowing ABAP Unit to exercise the productive Open SQL readers and custom-table writers as well as the pure allocation logic.

Implementation decisions and follow-up increments are in [NOTES.md](NOTES.md); confirmed defects and tooling limitations belong in [ANOMALIES.md](ANOMALIES.md).
