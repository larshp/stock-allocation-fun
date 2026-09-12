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
* Table `ZSUBSTITUTE` (material substitution rules: `MATNR`, `SUBMATNR`, `PRIO`)
* Table `ZSTOCKRUN` (allocation run header: status and aggregated totals)
* Table `ZSTOCKRESV` (open stock commitments per material / plant / storage
  location)

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
12. **Whole sales units** - `ty_policy-whole_sales_units` restricts each pick to
    a whole multiple of the sales unit. The allocator asks the UoM converter for
    the base quantity of one sales unit and snaps every take down to that step,
    so odd remainders stay in stock and show up as shortage instead of being
    allocated. Off by default; ignored when the requirement has no unit or no
    converter is injected.
13. **Partial delivery control** - `ty_policy-max_picks` limits how many stock
    rows (storage locations / batches) a single requirement may be served from
    (`0` = unlimited). If the requirement cannot be covered within the limit it
    is skipped entirely: the reserved quantities are handed back to the stock
    rows and the full quantity is reported as shortage, so later requirements
    can still use that stock.
14. **Coverage / shortage report** - `zcl_alloc_shortage_report` turns an
    allocation result into a report: one line per requirement with a floored
    coverage percentage, an aggregate summary (requested, allocated, shortage,
    coverage, line and shortage counts) and a `critical` list of the lines below
    a caller-supplied minimum coverage. It is a pure calculation, no database
    access.
15. **Material substitution** - `zcl_stock_substitution` reads the substitution
    rules from the new custom `ZSUBSTITUTE` table in priority order, and
    `availability( )` reports the usable stock of the requested material plus
    each substitute, with own / substitute / total quantities and a `details`
    list (own material first).
16. **Run tracking** - `zcl_alloc_run_header` persists one header row per
    material/plant in the new custom `ZSTOCKRUN` table. `start_run( )` inserts
    the row with status `R` (running), `finish_run( )` aggregates the allocation
    result (requested / allocated / shortage quantities and item count) and
    upserts the row with status `D` (done), and `read_run( )` reads the rows of a
    run. The status values are exposed as the constants `c_status_running` and
    `c_status_done`.
17. **Allocating across substitutes** - `ty_allocation` now records the `matnr`
    each row came from, and `zcl_stock_allocator=>allocate_materials( )` builds
    availability from an *ordered list* of materials, so stock is consumed from
    the requested material first and then from the substitutes in the caller's
    order. The facade exposes this as
    `zcl_stock_allocation_service=>allocate_with_substitution( )`, which reads
    the `ZSUBSTITUTE` rules and builds that list. The log writer stores the
    material actually used on each allocation row.
18. **Under-delivery tolerance** - `ty_policy-under_tolerance` is a percentage.
    When a requirement's shortfall stays within that percentage of the requested
    quantity, the result row is flagged `within_tolerance` instead of counting
    as a hard miss; the shortage quantity is still reported. Default `0` means
    no tolerance, and a full delivery is never flagged.
19. **Tolerance-aware coverage report** - the report marks a line `covered` when
    it is delivered in full, when its shortfall is within the allocator's
    under-delivery tolerance (`within_tolerance`), when it is deferred, or when
    nothing was requested. Only lines that are *not* covered and fall below the
    minimum coverage become `critical`. The summary gained `covered_lines`.
20. **Delivery-date horizon** - `ty_policy-horizon_date` defers requirements
    whose requirement date lies after the horizon: they come back with
    `deferred = abap_true`, no allocation and their full quantity as shortage, so
    the stock stays available for requirements that are due now. The horizon is
    inclusive (a requirement exactly on the horizon is still allocated) and unset
    by default.
21. **Safety stock** - `ty_policy-safety_stock` keeps a quantity in the bins: it
    is consumed from the availability rows (in order) right after they are
    built, so neither the allocation nor `available_quantity( )` can use it. The
    remaining quantities are never driven below zero.
22. **Run overview report** - `zcl_alloc_run_report` turns the `ZSTOCKRUN`
    headers into a reporting view: `overview( )` lists every run and
    `overview_of_run( run_id )` a single one, each line adding a derived
    `coverage_pct` (allocated / requested, floored) on top of the stored status,
    item count and quantities. `zcl_alloc_run_header` gained `read_all( )` for
    this.
23. **Stock commitments** - `zcl_stock_commitment` records the allocated
    quantities per material / plant / storage location in the new custom
    `ZSTOCKRESV` table (`commit( )`), can release a whole run
    (`release_run( )`) and aggregates the open quantities per storage location
    (`read_open( )`). `zcl_stock_reader_reserved` decorates any
    `zif_stock_reader` and subtracts those commitments from the unrestricted
    quantity per storage location (never below zero), so a later run sees the
    stock as already committed. The decorator is opt-in.
24. **Commit in the run flow** - the facade takes `io_commitment` and offers
    `commit_allocations( )` and `run_with_commitment( )`, which allocates,
    commits the allocations as reservations and writes the `ZSTOCKALLOC` audit
    rows in one call.
25. **Post and commit** - `run_post_and_commit( )` performs the full flow:
    allocate, commit the allocations to `ZSTOCKRESV`, post the goods issue and -
    only when the posting succeeded - release the commitment again, because the
    goods issue already reduced the stock and keeping it would count the same
    quantity twice. The audit rows are written last.
26. **Overview text output** - `zcl_alloc_run_report=>to_lines( )` renders an
    overview as CSV text (header plus one line per run/material) for a classic
    list report or a download. Lines are built with single `&&` concatenations,
    because the transpiler does not parse chained `&&` expressions.

Test coverage (143 ABAP Unit tests, run on Node through the transpiler):

* MARD reader: storage locations, quantity mapping, plant filter, empty result
* Allocator: priority order, shortage, split over bins, policy, over-allocation
  protection, empty stock, date tie-break, FEFO order, unknown expiry last,
  FEFO opt-in, unit conversion, unit without converter, whole sales units
  (rounding, full demand, across bins, off by default, without unit), pick limit
  (unlimited, one pick, skip when spans, two picks, stock released on skip),
  multi-material (substitute after own, own first, row material), under-delivery
  tolerance (accepted, rejected, off by default, full delivery), horizon (late
  deferred, inclusive, off by default, early requirement gets the stock), safety
  stock (reduces stock, spans bins, off by default, never negative, available
  quantity)
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
  FEFO through the facade, sales unit conversion through the facade,
  allocation across substitutes through the facade, commit run,
  post-and-release for a run
* Run: two materials, aggregated shortage report, materials-with-shortage count,
  requested/allocated/shortage totals, empty request list
* Log reader: run filter, position and quantity totals, distinct material count,
  per-run summaries, empty run
* Shortage report: full coverage, floored partial coverage, summary aggregation,
  critical below threshold, no shortage, zero request, empty result, tolerance
  line covered, short line not covered, full delivery covered, deferred covered
* Substitution: rules ordered by priority, no rules, own + substitute
  availability, detail list order, other material ignored
* Run header: running status on start, totals and done status on finish, finish
  without start, per-run read, empty result totals
* Run report: computed coverage, all runs listed, single run filter, full
  coverage, empty log, CSV header, CSV row formatting
* Commitment: written rows, per-location aggregation, row material used,
  requested material default, release, empty result
* Reserved reader: subtracts commitment, clamps at zero, other locations,
  no reservation, other material

## Next candidates

* ALV / grid UI on top of the run overview.
* Parallel or package-wise processing for large material lists.
* Safety stock per plant / storage location instead of one run-wide figure.
* Commit expiry / cleanup job for stale reservations.

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
* `LOOP GROUP BY` is not supported by the transpiler - group manually by sorting
  and comparing instead.
* Chained string concatenation (`a = b && |x| && |y|`) is not parsed; use one
  `&&` per statement.
* `DELETE FROM <table> WHERE ...` and `MODIFY <table> FROM @wa` work on own `Z`
  tables, so the `modify_only_own_db_tables` configuration stays minimal.
* A method call used as a standalone statement must not pass `CHANGING` in the
  functional form, and `APPEND <method call> TO itab` is not parsed either (see
  ANOMALIES.md A12).
* `align_type_expressions` aligns the `TYPE` keyword of method parameters and of
  consecutive `DATA` statements to `indent + longest name + 1`. Keeping one long,
  descriptive name per signature makes this predictable.
* Tests are local test classes in `<class>.clas.testclasses.abap` files.
* Test doubles for interfaces are plain local classes inside the test file
  (`lcl_stock_reader_stub`), so no dependency on a mocking framework is needed.
