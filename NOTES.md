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
  requirements), `VBAP` (sales order item, used by the alternative requirement
  reader), `MCHB` (batch stock), `MCHA` (batch master, carries the expiry date
  `VFDAT`) and `MARM` (alternative units of measure, `UMREZ`/`UMREN` ratios)
* Structures: `BAPI2017_GM_HEAD_01`, `BAPI2017_GM_HEAD_RET`,
  `BAPI2017_GM_CODE`, `BAPI2017_GM_ITEM_CREATE`
* Function group: `BAPI_GOODSMVT` with `BAPI_GOODSMVT_CREATE` (movement types
  601/101, updates `MARD`)
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
6. **Goods movement posting** - `zif_allocation_poster` +
   `zcl_allocation_poster_bapi` were already stubbed; the facade now wires them
   in. `post_allocation( )` posts the allocated quantities as a goods issue
   (movement type 601 by default) through `BAPI_GOODSMVT_CREATE`, and
   `run_with_posting( )` performs the full flow in one call: allocate from
   `MARD`, post the goods issue, write the `ZSTOCKALLOC` audit rows. It returns
   `ty_run_result` with both the allocations and the posting result (document
   number). Nothing is posted when the allocation is empty.
7. **Sales order requirement source** - `zcl_requirement_reader_vbap` implements
   `zif_requirement_reader` on top of the new `VBAP` stub. It reads open sales
   order items (rejected items with an `ABGRU` reason and zero quantities are
   skipped), maps `KWMENG` to the requested quantity, `EDATU` to the requirement
   date and `LPRIO` to the priority (an initial priority is treated as 1), and
   builds the requirement id from `VBELN` + `POSNR`. It can be injected into
   `zcl_stock_allocation_service` in place of the `RESB` reader.
8. **Batch stock and FEFO** - `zif_stock_reader=>ty_stock` gained `charg` and
   `expiry_date`, and `zcl_stock_allocator=>ty_allocation` reports them back, so
   one allocation row exists per batch. `zcl_stock_reader_mchb` reads batch
   stock from `MCHB` and looks the expiry date up in `MCHA`. The new
   `ty_policy-use_fefo` flag switches the allocator from "first storage location
   first" to FEFO: batches are consumed in ascending expiry date order, and
   batches without a date sort last. FEFO is opt-in, the default keeps the
   reader order.
9. **Unit of measure conversion** - requirements now carry a `unit`
   (`zif_requirement_reader=>ty_requirement-unit`), populated by the `VBAP`
   reader from `MEINS`. `zif_uom_converter` + `zcl_uom_converter` convert a
   requirement quantity into the material base unit through the new `MARM` stub
   (`base = qty * UMREZ / UMREN`). The allocator takes an optional converter and
   converts every requirement that has a unit, so `requested_qty`,
   `allocated_qty` and `shortage_qty` are all reported in base units. Without a
   converter, or without a `MARM` entry, the quantity is passed through
   unchanged. This also fixed a latent bug: `allocated_qty` was computed from
   the raw (unconverted) requirement quantity.
10. **Multi-material run and shortage report** - `zcl_stock_alloc_run` drives the
    facade for a list of material/plant requests. `run( )` returns a
    `ty_run_result` with the per-material allocation results, aggregate
    `ty_stats` (number of materials and requirements, requested/allocated/
    shortage totals, count of materials with a shortfall) and a flat
    `ty_shortage_tt` shortage report listing every requirement that could not be
    fully covered, including its material and plant.
11. **Allocation log reporting** - `zcl_alloc_log_reader` reads the recorded
    `ZSTOCKALLOC` rows. `read_run( run_id )` returns the rows of a single run,
    `summarize_run( run_id )` aggregates them (distinct materials, number of
    positions, total allocated quantity) and `summarize_all( )` produces one
    summary per run id, ordered by run id. Grouping is done by sorting and
    comparing instead of `LOOP GROUP BY`, which the transpiler does not support.

Test coverage (75 ABAP Unit tests, run on Node through the transpiler):

* MARD reader: storage locations, quantity mapping, plant filter, empty result
* Allocator: priority order, shortage, split over bins, policy, over-allocation
  protection, empty stock, date tie-break, FEFO order, unknown expiry last,
  FEFO opt-in, unit conversion, unit without converter
* RESB reader: open items, withdrawn quantity, deletion/final-issue flags,
  material filter, id construction, date sorting
* VBAP reader: open item, rejection reason, zero quantity, material filter,
  date sorting, delivery priority, sales unit, id construction
* MCHB reader: batch with expiry, quantity mapping, plant filter, empty result,
  batch without batch master, one row per batch
* UoM converter: conversion, missing entry, base unit, zero denominator,
  fractional ratio, other material
* Writer: one row per allocation, header fields, empty result
* Service: end-to-end MARD + RESB allocation, shortage, bin spill-over,
  available quantity, total shortage, full recorded run, posting run (with a
  poster double), empty run skips posting, allocation from sales orders, batch
  FEFO through the facade, sales unit conversion through the facade
* Run: two materials, aggregated shortage report, materials-with-shortage count,
  requested/allocated/shortage totals, empty request list
* Log reader: run filter, position and quantity totals, distinct material count,
  per-run summaries, empty run

## Next candidates

* Rounding of allocated quantities up to whole sales units of measure.
* Persist run headers and a status (started / finished / posted).
* Report/ALV on `ZSTOCKALLOC` runs.
* Parallel or package-wise processing for large material lists.

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
