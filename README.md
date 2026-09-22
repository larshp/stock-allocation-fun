# Stock Allocation Fun

An ABAP stock allocation solution designed for integration with an existing SAP
system. Development is incremental; SAP dependencies used by local tooling live
under `stubs/`, while custom `Z*` objects live under `src/`.

## Current feature

The stock service reads unrestricted-use quantity for a material and plant from
`MARD-LABST`. The database read is isolated in `ZCL_MARD_STOCK_REPOSITORY` and
can be replaced through `ZIF_STOCK_REPOSITORY` in tests or other integrations.

## Development

Requires Node.js 22 or newer and npm.

```sh
npm install
npm test
```

`npm test` runs abaplint, transpiles the ABAP sources with open-abap-core, and
runs ABAP Unit tests through the transpiler runtime. The `MARD` definition in
`stubs/src/` is only a local tooling stub; the target SAP system supplies the
real standard table.

See [PLAN.md](PLAN.md) for implementation requirements and [NOTES.md](NOTES.md)
for progress.
