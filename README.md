# stock-allocation-fun

A stock allocation solution written in ABAP: it works out who gets the stock
that is genuinely available, records the decision and reserves it in SAP.

Built to install into an existing SAP system with
[abapGit](https://abapgit.org), and developed against
[abaplint](https://abaplint.org) and the
[abaplint transpiler](https://github.com/abaplint/transpiler) so the ABAP Unit
tests run without a SAP system.

## What it does

`ZSTOCK_ALLOCATION` takes a plant and, optionally, a material. For each material
waiting for stock it

1. checks the user may allocate in the plant (`AUTHORITY-CHECK` on
   `M_MATE_WRK`) and locks the material for the run,
2. reads the book stock from `MARD` and takes off what is not up for
   allocation — open reservations and the plant's safety stock,
3. reads the open demand — sales orders from `VBAK`/`VBAP` and stock transport
   orders that take stock out of the plant from `EKKO`/`EKPO`/`EKET` — converts
   it to base units, takes off what has already been delivered or sent and what
   earlier runs already reserved for the same line, and drops anything beyond
   the horizon,
4. distributes what is left, either by delivery priority or as a fair share,
   giving an item that may only ship complete either all of it or none of it,
5. records the outcome in `ZSTOCK_ALLOC_RES`,
6. reserves the confirmed quantities through `BAPI_RESERVATION_CREATE1` and
   links the reservation back onto the recorded run.

One material failing does not stop the rest of the run; the report says which
ones failed and why.

**The selection screen defaults to a test run.** A test run does the whole
calculation and shows the result without recording or reserving anything.

`ZSTOCK_ALLOC_REORG` keeps `ZSTOCK_ALLOC_RES` from growing forever. It removes
recorded runs that are past the retention time **and** are no longer holding
anything back — a run whose reservation was rejected, deleted or is otherwise
gone. A run whose reservation is still there stays, because the demand netting
reads it. It defaults to a test run too.

## Installing into SAP

Pull the repository with abapGit. `.abapgit.xml` sets the starting folder to
`/src/`, so only the custom `Z` objects are installed — the SAP standard stubs
under `/sap-stubs/` exist for linting and testing and must never reach a real
system, where the real `MARD`, `VBAP` and `BAPI_RESERVATION_CREATE1` are already
there.

## Developing

```sh
npm install
npm test
```

| Script              | What it does                                            |
| ------------------- | ------------------------------------------------------- |
| `npm run lint`      | `abaplint` over `src/` and `sap-stubs/`                 |
| `npm run transpile` | ABAP -> JavaScript into `output/`                       |
| `npm run unit`      | runs the transpiled ABAP Unit tests                     |
| `npm test`          | all three, in that order                                |

The same three steps run on every push, see
[.github/workflows/test.yml](.github/workflows/test.yml).

## Where the seams are

Everything a customer is likely to want to change sits behind an interface, and
`ZCL_ALLOCATION_SERVICE=>create_default( )` is the only place that knows the
whole object graph:

| Interface                  | Swap it to change                                  |
| -------------------------- | -------------------------------------------------- |
| `ZIF_ALLOCATION_STRATEGY`  | who gets the stock when there is not enough        |
| `ZIF_STOCK_DEDUCTION`      | what counts as unavailable, one class per reason   |
| `ZIF_DEMAND_READER`        | where demand comes from, one class per source       |
| `ZIF_UNIT_CONVERTER`       | how quantities reach the base unit of measure      |
| `ZIF_RESERVATION_WRITER`   | how confirmed stock is earmarked                   |
| `ZIF_RESERVATION_READER`   | when an earlier reservation stops counting         |
| `ZIF_ALLOCATION_AUTHORITY` | which authorization object guards a run            |
| `ZIF_ALLOCATION_LOCK`      | how concurrent runs are kept apart                 |
| `ZIF_RUN_ID_SUPPLIER`      | how runs are numbered                              |
| `ZIF_ALLOCATION_STORE`     | where the result is recorded                       |

## Layout

- `src/` — the solution, all objects prefixed `Z`
- `sap-stubs/` — stubs of the SAP standard objects that open-abap does not ship
- `test/setup.mjs` — wires an in-memory SQLite database into the test run

## Documentation

- [PLAN.md](PLAN.md) — what is being built
- [NOTES.md](NOTES.md) — design decisions and progress, feature by feature
- [ANOMALIES.md](ANOMALIES.md) — toolchain defects found along the way
