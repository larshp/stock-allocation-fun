# NOTES

## Iteration 5

- Scaffolded project: `package.json`, `abaplint.json`, `transpile.json`.
- Project structure:
  - `src/` — all custom Z* ABAP code.
  - `stubs/` — SAP standard stubs (MARD, orders, etc.) for linting/transpiling.
  - `output/` — transpiled JS (gitignored).
- abaplint rules enabled per PLAN.md: `modify_only_own_db_tables`, `align_type_expressions`, `easy_to_find_messages`, `max_one_method_parameter_per_line`, `align_parameters`, `local_testclass_consistency`, `allowed_object_naming`, `line_length`.
- Dependency: `@open-abap/open-abap-core` used in abaplint + transpiler configs (cloned from GitHub).
- Tooling: `@abaplint/core`, `@abaplint/transpiler-cli`, `@abaplint/runtime`.
- Build: `npm run build` = lint + transpile + test.

## Implemented (iteration 5)

- `src/zif_stock_allocation.intf.abap` — interface with demand/allocation types and `allocate` method.
- `src/zcl_stock_allocator.clas.abap` — allocates available stock to demands in order.
- `src/zcl_stock_allocator.clas.testclasses.abap` — 3 unit tests (full, partial, none).
- Stubs (SAP standard, abapGit XML format):
  - `stubs/mard.tabl.xml` — MARD table (available stock).
  - `stubs/werks_d.dtel.xml`, `stubs/labst.dtel.xml`, `stubs/lgort_d.dtel.xml` — data elements.
  - `stubs/bapi_material_availability.fugr.abap` — reads stock from MARD.
- `matnr` and `meins` come from open-abap-core dependency.

## Verified

- `npm run lint` — 0 issues.
- `npm run transpile` — 543 objects written.
- `npm run test` — 3 unit tests pass.