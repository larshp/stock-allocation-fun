# Stock allocation for SAP

This repository contains a small, production-oriented ABAP stock-allocation service. It reads unrestricted-use stock from `MARD`, reads open sales requirements from `VBBE`, applies optional demand priorities from `ZSTOCKPRIO`, allocates stock by priority and FIFO material-availability date, and persists the result in `ZSTOCKALLOC`.

## Design

The pure allocator has no SAP dependencies. Interfaces isolate reads, writes, locking, authorization, and audit logging, while SAP-specific adapters live at the edge. This makes the allocation rule ABAP Unit-testable and keeps standard tables read-only. The report `ZSTOCK_ALLOCATE` is the transaction boundary and commits the completed allocation run. Authorization is checked before locking or database access, a client/material/plant/storage-location SAP lock remains held until that commit, stock is re-read immediately before persistence, and each successful plan is written to the Business Application Log in the same logical unit of work. Unrelated allocation scopes can run concurrently.

Allocation statuses are `F` (full), `P` (partial), and `N` (none). Results retain the sales-order schedule-line key, so multiple requirements for one item cannot overwrite each other. Re-running the report replaces the planning records for the selected material, plant, and storage location.

Priorities are optional signed integers stored in `ZSTOCKPRIO` for a material, plant, storage location, sales order, and item. Maintain them through report `ZSTOCK_PRIORITY`; its save and delete paths use the same allocation-scope lock, so configuration cannot change during an allocation run. Higher values allocate first. Equal priorities—including the default value zero—retain FIFO ordering, so existing behavior is unchanged when no configuration exists.

Execution requires activity `16` on authorization object `ZSTK_RUN`. Assign it only to roles allowed to replace the persisted allocation plan.

Priority maintenance uses authorization object `ZSTK_PRI`: activity `02` saves a priority and activity `06` removes one. Successful changes retain their scope lock until the report commits.

The report starts in simulation mode. Leave `P_SIM` selected to calculate and display a fresh plan without enqueueing, logging, persisting, or committing. Clear it only when the displayed scope should replace the saved allocation plan.

Execution summaries are stored under application-log object `ZSTOCKALLOC`, subobject `RUN`. A logging failure aborts allocation persistence, ensuring a committed plan always has an audit entry. View entries with the target system's application-log viewer (commonly transaction `SLG1`).

## Install in SAP

Clone the repository with abapGit. Its configuration imports only `/src/`; `sap_stubs` remains outside the SAP source folder because those definitions model SAP-standard objects only for local linting/transpilation. Confirm the standard `MARD` and `VBBE` fields in the target release, activate `ZSTOCKALLOC`, `ZSTOCKPRIO`, authorization object `ZSTK_RUN`, and application-log object `ZSTOCKALLOC`, assign authorizations to the report and priority maintenance, and perform a target-system integration test before scheduling productive runs.

## Local verification

Requirements: Node.js and npm.

```text
npm install
npm test
```

Both tool configurations load `open-abap/open-abap-core`. The lint configuration includes `src` and `sap_stubs` and enables all rules required by [PLAN.md](PLAN.md).

Implementation decisions and follow-up increments are in [NOTES.md](NOTES.md); confirmed defects and tooling limitations belong in [ANOMALIES.md](ANOMALIES.md).
