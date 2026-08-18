# stock-allocation-fun

A stock allocation solution written in ABAP: it works out who gets the stock
that is actually available, records the decision and reserves it in SAP.

Built to install into an existing SAP system with
[abapGit](https://abapgit.org), and developed against
[abaplint](https://abaplint.org) and the
[abaplint transpiler](https://github.com/abaplint/transpiler) so the ABAP Unit
tests run without a SAP system.

## What it does

`ZSTOCK_ALLOCATION` takes a plant and, optionally, a material. For each material
waiting for stock it

1. reads the book stock from `MARD` and takes off what is not up for allocation
   — open reservations and the plant's safety stock,
2. reads the open sales order demand from `VBAK`/`VBAP`,
3. distributes what is left, either by delivery priority or as a fair share,
4. records the outcome in `ZSTOCK_ALLOC_RES`,
5. reserves the confirmed quantities through `BAPI_RESERVATION_CREATE1`.

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

## Layout

- `src/` — the solution, all objects prefixed `Z`
- `sap-stubs/` — stubs of the SAP standard objects that open-abap does not ship
- `test/setup.mjs` — wires an in-memory SQLite database into the test run

## Documentation

- [PLAN.md](PLAN.md) — what is being built
- [NOTES.md](NOTES.md) — design decisions and progress, feature by feature
- [ANOMALIES.md](ANOMALIES.md) — toolchain defects found along the way
