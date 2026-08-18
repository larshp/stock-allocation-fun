# stock-allocation-fun

A stock allocation solution written in ABAP, built to run inside an existing SAP
system and developed against [abaplint](https://abaplint.org) and the
[abaplint transpiler](https://github.com/abaplint/transpiler).

## Getting started

```sh
npm install
npm test
```

`npm test` lints, transpiles and runs the ABAP Unit tests:

| Script            | What it does                                            |
| ----------------- | ------------------------------------------------------- |
| `npm run lint`    | `abaplint` over `src/` and `sap-stubs/`                 |
| `npm run transpile` | ABAP -> JavaScript into `output/`                     |
| `npm run unit`    | runs the transpiled ABAP Unit tests                     |

## Layout

- `src/` — the custom solution, all objects prefixed `Z`
- `sap-stubs/` — stubs of the SAP standard objects (`MARD`, ...) that open-abap
  does not ship, so the custom code can be linted and executed outside SAP
- `test/setup.mjs` — wires an in-memory SQLite database into the test run

## Documentation

- [PLAN.md](PLAN.md) — what is being built
- [NOTES.md](NOTES.md) — design decisions and progress
- [ANOMALIES.md](ANOMALIES.md) — toolchain bugs found along the way
