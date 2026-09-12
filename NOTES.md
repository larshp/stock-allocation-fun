# NOTES

Working notes and progress log for the stock allocation solution.

## Goal

A stock allocation solution written in ABAP that integrates into an existing SAP
system, follows ABAP best practices, is linted with abaplint and unit tested by
transpiling the ABAP to JavaScript and running it on Node.

## Repository layout

| Path                 | Contents                                                        |
| -------------------- | --------------------------------------------------------------- |
| `src/`               | All custom code. Every object name starts with `Z`.              |
| `stubs/`             | SAP standard stubs (tables, data elements, function modules, ...) |
| `test/`              | Node test harness (SQLite connection for the transpiler runtime) |
| `abaplint.jsonc`     | Linting configuration, depends on `open-abap/open-abap-core`     |
| `abap_transpile.json`| Transpiler configuration, uses `open-abap-core` as a lib         |
| `ANOMALIES.md`       | Bugs / issues found while working with the toolchain             |

## Commands

```
npm run lint    # abaplint
npm run build   # clean + abap_transpile -> output/
npm run unit    # run transpiled ABAP Unit tests on node
npm test        # lint + build + unit
```

## Toolchain decisions

* `@abaplint/cli`, `@abaplint/transpiler-cli`, `@abaplint/runtime` and
  `@abaplint/database-sqlite` (pure WASM, no native compilation).
* `open-abap-core` is referenced from both `abaplint.jsonc` (`dependencies`) and
  `abap_transpile.json` (`libs`) as required by PLAN.md.
* `syntax.version` is `open-abap` so that the linting syntax matches the runtime
  the transpiler targets.
* Enabled rules required by PLAN.md: `modify_only_own_db_tables`,
  `align_type_expressions`, `easy_to_find_messages`,
  `max_one_method_parameter_per_line`, `align_parameters`,
  `local_testclass_consistency`, `allowed_object_naming`, `line_length`.
* Database statements are executed against SQLite. Tests use
  `cl_osql_test_environment`, which requires `sy-dbsys = 'sqlite'`; this is why
  `test/setup.mjs` registers a `SQLiteDatabaseClient` on the `DEFAULT` connection.

## SAP standard stubs

open-abap-core does not contain business logic, so SAP standard artefacts needed
by the solution are added under `stubs/`. Stubs must not duplicate objects that
open-abap-core already ships (otherwise `errorOnDuplicateFilenames` fails).

Currently stubbed:

* Tables: `MARD` (storage location stock), `RESB` (reservations / dependent
  requirements)
* Data elements: `WERKS_D`, `LGORT_D` (`MATNR`, `MEINS`, `MENGE_D`, `MANDT` come
  from open-abap-core)

Custom `Z` DDIC objects live under `src/ddic/` and are part of the solution:

* Data element `ZSTOCK_RUN_ID` (CHAR 20)
* Table `ZSTOCKALLOC` (allocation log)

## Feature log

1. **Read stock from MARD** - `zif_stock_reader` + `zcl_stock_reader_mard`.
   Reads unrestricted, quality inspection, blocked, restricted and in-transit
   quantities per storage location for a material/plant.
2. **Allocation engine** - `zcl_stock_allocator`. Allocates available stock to
   requirements ordered by priority, then requirement date, then id. Reports
   allocated quantity, shortage and the per-storage-location split. An
   `is_policy` switch decides which stock categories may be used (unrestricted
   only by default). `available_quantity( )` exposes the usable total.
3. **Requirement reader for RESB** - `zif_requirement_reader` +
   `zcl_requirement_reader_resb`. Reads open reservation items for a
   material/plant, skipping deleted (`XLOEK`) and finally issued (`KZEAR`)
   items and subtracting already withdrawn quantity (`ENMNG`).
4. **Facade service** - `zcl_stock_allocation_service`. Wires the default
   readers and the allocator, so callers get a one-call API
   (`allocate`, `allocate_for_requirements`, `available_quantity`,
   `total_shortage`). Readers/writer/policy can be injected for testing.
5. **Allocation log** - `zif_allocation_writer` + `zcl_allocation_writer_db`.
   Writes one row per allocation into `ZSTOCKALLOC`; usable through
   `zcl_stock_allocation_service=>allocate_and_record( )`.

Test coverage (30 ABAP Unit tests, run on Node through the transpiler):

* MARD reader: storage locations, quantity mapping, plant filter, empty result
* Allocator: priority order, shortage, split over bins, policy, over-allocation
  protection, empty stock, date tie-break
* RESB reader: open items, withdrawn quantity, deletion/final-issue flags,
  material filter, id construction, date sorting
* Writer: one row per allocation, header fields, empty result
* Service: end-to-end MARD + RESB allocation, shortage, bin spill-over,
  available quantity, total shortage, full recorded run

## Next candidates

* Stock movement posting through a BAPI stub (`BAPI_GOODSMVT_CREATE`) instead of
  touching `MARD` directly.
* Read requirements from `VBAP`/`VBBE` (sales orders) as an alternative
  requirement source.
* Rounding of allocated quantities to sales units of measure.
* Report/ALV on `ZSTOCKALLOC` runs.

## Conventions

* Method names must be 30 characters or shorter.
* Do not use `TYPE c LENGTH n` in a method parameter list - use a named type or a
  component reference instead (see ANOMALIES.md A7).
* Do not use `TYPE STANDARD TABLE OF ...` directly in a parameter either; declare
  a `TYPES` alias first (see ANOMALIES.md A9).
* DDIC structures use the classic chained `TYPES: BEGIN OF ... END OF ...` form,
  which is the syntax the transpiler parses.
* Reusable data types live in interfaces or in the `PUBLIC SECTION` of classes,
  so no `Z` DDIC structure is needed for the API.
* Each interface owns the data type it produces: `zif_stock_reader` owns the
  stock item, `zif_requirement_reader` owns the requirement, and the allocator
  owns its result and policy types.
* Tests are local test classes in `<class>.clas.testclasses.abap` files.
* Test doubles for interfaces are plain local classes inside the test file
  (`lcl_stock_reader_stub`), so no dependency on a mocking framework is needed.
