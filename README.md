# Stock Allocation Fun

An ABAP stock allocation solution designed for integration with an existing SAP
system. Development is incremental; SAP dependencies used by local tooling live
under `stubs/`, while custom `Z*` objects live under `src/`.

## Current feature

The stock service reads unrestricted-use quantity for a material and plant from
`MARD-LABST` (in the material's base unit). The database read is isolated in
`ZCL_MARD_STOCK_REPOSITORY` and can be replaced through
`ZIF_STOCK_REPOSITORY` in tests or other integrations. The service can preview
one request or a batch of demand lines, returning each allocated amount and
shortfall. Batch lines use the input order as priority; each result reports the
remaining balance before its line is allocated. Each material/plant balance is
read once and consumed across the matching lines. Negative requests raise
`ZCX_INVALID_STOCK_REQUEST`; negative stock is treated as unavailable.
Previews do not persist allocations or write stock.

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
