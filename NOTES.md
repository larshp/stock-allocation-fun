# Implementation progress

Scope: current branch `hvam/unionalpha1609` only. No code imported from other branches.

## Iteration 1 — toolchain and allocation primitive

- Local npm dependencies and lockfile for abaplint, transpiler, runtime and SQLite.
- Required lint rules enabled; open-abap-core dependency in both configurations.
- Pure allocation primitive with tests for full delivery, shortage and non-positive quantities.
- Validation in progress; later iterations add SAP adapters and decimal quantities.

## Planned next increments

1. Decimal quantities and MARD stock reader with database integration tests.
2. Prioritized order allocation, safety stock, shortages and full-delivery policy.
3. Goods-movement adapter with simulation and explicit caller-owned transaction handling.

Generated JavaScript and SAP standard stubs are development-only, not production deployables.
