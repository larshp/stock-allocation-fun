# stock-allocation-fun

Stock allocation for ABAP, developed and tested outside a SAP system with
[abaplint](https://abaplint.org) and the
[open-abap transpiler](https://github.com/abaplint/transpiler).

## What it does

- `zcl_stock_allocator=>allocate` — pure primitive: how much of a request can be
  served from an available quantity.
- `zcl_stock_allocator=>plan` — prioritized multi-order planning:
  - requirements sorted stable by priority, due date, order, item;
  - safety stock protected before any allocation;
  - optional full-delivery policy (no partial allocations);
  - optional horizon that defers requirements due after it;
  - optional storage-location allowlist (`it_locations`), also exposed by the service;
  - per-location picks and per-requirement results (allocated, shortage, deferred).
- `zcl_stock_allocator=>summarize` — totals and shortage list for a plan.
- `zif_stock_reader` / `zcl_stock_reader_mard` — injectable stock reading from
  table MARD (positive stock, current client, ordered by primary key).
- `zcl_stock_allocation_service` — wires reader and planner; accepts an injected
  reader for tests.

Planning is a read-only snapshot simulation. It never mutates stock, holds no
locks, and posts nothing — an allocation is not a goods issue.

### Storage-location selection

Pass `it_locations` to `zcl_stock_allocator=>plan` or
`zcl_stock_allocation_service->run` to restrict the stock pool. Omitted or empty
lists allow all locations. Nonempty lists allow only matching IDs; unknown IDs
never fall back to other locations. Duplicate IDs do not multiply stock, and picks
remain ordered by location. Safety stock and full-delivery checks apply only to
the selected pool. This is a planning policy, not an authorization check.

## Layout

- `src/` — all custom Z objects (abapGit file format).
- `sap-stubs/` — minimal SAP standard table stubs (MARD, MARA) for linting and
  transpilation only. Never deploy these to a SAP system.
- `test/setup.mjs` — isolated SQLite fixture for integration tests.
- `output/` — generated JavaScript (development only, not committed).

## Development

```sh
npm install
npm test   # abaplint + transpile + ABAP unit tests
```

Requires Node.js. Tests run against an in-memory SQLite database; no SAP
connection is needed.

## Deploying to SAP

Only the objects in `src/` are deployable (all start with Z). Do not deploy
`sap-stubs/`, `test/`, or `output/` — they exist solely for the local toolchain.
On a real system, MARD is SAP standard; the stub is only a local stand-in.

## Notes

- `NOTES.md` tracks progress and known limitations.
- `ANOMALIES.md` records bugs and issues found along the way.
