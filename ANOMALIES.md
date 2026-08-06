# ANOMALIES

Bugs and issues found during development. Each entry: date, description, resolution.

- 2026-08-06: `@open-abap/open-abap-core` is not on npm. Resolved by using it as a GitHub dependency in `abaplint.json` and `transpile.json` (cloned by the tools).
- 2026-08-06: abaplint `files` glob must be an array, not a comma-separated string. Resolved by using an array.
- 2026-08-06: Data elements like `werks_d`, `labst` are not in open-abap-core. Resolved by adding SAP-standard DTEL stubs in abapGit XML format under `stubs/`.
- 2026-08-06: `@abaplint/transpiler` has no per-file `transpile()` method; use `@abaplint/transpiler-cli` (`abap_transpile`) which handles open-abap-core dependency loading.
- 2026-08-06: Transpiled output requires `@abaplint/runtime` to run unit tests. Resolved by adding it as a dependency.