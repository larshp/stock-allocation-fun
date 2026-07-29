# Stock allocation for SAP

This repository contains a small, production-oriented ABAP stock-allocation service. It reads unrestricted-use stock from `MARD`, reads open sales requirements from `VBBE`, allocates stock FIFO by material-availability date, and persists the result in the custom table `ZSTOCKALLOC`.

## Design

The pure allocator has no SAP dependencies. Interfaces isolate reads and writes, while SAP-specific adapters live at the edge. This makes the allocation rule ABAP Unit-testable and keeps standard tables read-only. The report `ZSTOCK_ALLOCATE` is the transaction boundary and commits the completed allocation run.

Allocation statuses are `F` (full), `P` (partial), and `N` (none). Results retain the sales-order schedule-line key, so multiple requirements for one item cannot overwrite each other. Re-running the report replaces the planning records for the selected material, plant, and storage location.

## Install in SAP

Clone the repository with abapGit. Its configuration imports only `/src/`; `sap_stubs` remains outside the SAP source folder because those definitions model SAP-standard objects only for local linting/transpilation. Confirm the standard `MARD` and `VBBE` fields in the target release, activate `ZSTOCKALLOC`, assign authorizations to the report, and perform a target-system integration test before scheduling productive runs.

## Local verification

Requirements: Node.js and npm.

```text
npm install
npm test
```

Both tool configurations load `open-abap/open-abap-core`. The lint configuration includes `src` and `sap_stubs` and enables all rules required by [PLAN.md](PLAN.md).

Implementation decisions and follow-up increments are in [NOTES.md](NOTES.md); confirmed defects and tooling limitations belong in [ANOMALIES.md](ANOMALIES.md).
