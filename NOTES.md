# Implementation progress

Scope: current branch `hvam/unionalpha1609` only. No code imported from other branches.

## Iteration 1 — toolchain and allocation primitive

- Local npm dependencies and lockfile for abaplint, transpiler, runtime and SQLite.
- Required lint rules enabled; open-abap-core dependency in both configurations.
- Pure allocation primitive `zcl_stock_allocator=>allocate` with tests for full
  delivery, shortage and non-positive quantities.

## Iteration 2 — stock reader and database tests

- `zif_stock_reader` interface with injectable `read_stock`.
- `zcl_stock_reader_mard` reads positive stock from MARD with an explicit
  `mandt = @sy-mandt` predicate (the transpiled runtime does not add client
  handling automatically).
- Minimal SAP standard stubs `mard` and `mara` in `sap-stubs/`, included in
  linting and transpilation.
- Isolated SQLite fixture in `test/setup.mjs`; integration tests cover scoped
  reads, unknown material and missing plant.

## Iteration 3 — prioritized multi-order planning

- `zcl_stock_allocator=>plan` allocates requirements sorted stable by
  priority, due date, order and item against location-sorted stock.
- Safety stock reserve is consumed first; full-delivery policy leaves stock for
  later orders when a request cannot be satisfied completely; a horizon defers
  requirements with later due dates.
- Results carry allocated, shortage and deferred flags; picks carry per-location
  quantities. Input stock is never mutated and nothing is persisted.

## Iteration 4 — service integration and shortage summary

- `zcl_stock_allocation_service` wires the MARD reader to the planner; a custom
  reader can be injected, and no database access happens without demand.
- `zcl_stock_allocator=>summarize` totals requested, allocated and shortage
  quantities (non-positive demand excluded from requested) and lists shortages.
- Regression tests cover input immutability, wrong material/plant/client
  filtering, reserve exceeding stock and zero-quantity requirements.

## Current status

- `npm test` (lint + transpile + ABAP unit tests): 26 tests, all passing,
  0 lint issues.
- Checkpoint `ca3486c` exists on `hvam/unionalpha1609`; completed regression tests
  and documentation updates remain uncommitted.
- Local validation only; no activation or integration testing in a real SAP system.

## Known limitations

- Quantities are in the material base unit only; no unit-of-measure conversion.
- Planning is a snapshot simulation: no locks, reservations or persistence.
- No goods-movement posting yet; an allocation is not a goods issue. Posting
  must go through a documented SAP standard API owned by the caller.
- No sales-order reader; requirements are passed in by the caller.
- SAP standard stubs and generated JavaScript are development-only artifacts.

## Planned next increments

1. Goods-movement adapter with simulation default and explicit caller-owned
   transaction handling.
2. Sales-order based requirement collection.
3. Deployment guidance for real SAP systems (Z objects only).
