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
* Table `ZSAFETYSTK` (safety stock per material / plant / storage location)

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
27. **Safety stock per plant / storage location** - `zif_safety_stock` +
    `zcl_safety_stock` read the new custom `ZSAFETYSTK` table (`MATNR`, `WERKS`,
    `LGORT`, `QTY`). The allocator takes an optional `io_safety_stock` and, per
    material, deducts the configured quantity from the availability rows before
    allocating. A row with an explicit storage location only affects that
    location; a row with an empty `LGORT` applies to the whole plant and is
    consumed across the material's rows in order. The deduction is applied once
    per location, so several batches sharing a storage location are not
    double-counted. The run-wide `ty_policy-safety_stock` scalar still applies on
    top of it.
28. **Commitment expiry and cleanup** - `ZSTOCKRESV` gained a creation date,
    stamped by `commit( )`. `read_expired( before )` lists the rows older than a
    cutoff without touching them (dry run), `purge_before( before )` deletes them
    and returns the number removed (`sy-dbcnt`), and `purge_older_than( days )` is
    the convenience wrapper that derives the cutoff from `sy-datum`. The
    comparison is strict, so a row created exactly on the cutoff day is kept.
29. **Package-wise processing** - `zcl_stock_alloc_run=>run_in_packages(
    it_requests, iv_package_size )` splits the request list into packages of at
    most `iv_package_size` entries and runs each one through `run( )`, merging the
    per-material results, the shortage report and every statistic into a single
    `ty_run_result`. A size of `0` (or less) falls back to one single run, and the
    default is 100. This keeps a long material list out of one huge loop and gives
    a natural checkpoint boundary.
30. **ALV-style field catalog** - `zcl_alloc_run_report=>field_catalog( )` returns
    the overview columns as a typed catalog (`fieldname`, `text`, `rollname`,
    `outputlen`, `decimals`, `just`), which is the metadata a classic ALV or a grid
    control needs. `to_lines( )` now builds its CSV header from that catalog, so
    the catalog and the text output cannot drift apart.
31. **Safety stock in the substitution report** - `zcl_stock_substitution` now
    accepts an optional `io_safety_stock` and passes it to its internal
    allocator, so `availability( )` reports own and substitute quantities with the
    `ZSAFETYSTK` safety stock already deducted - the same figure a real
    allocation would use. The facade hands its own safety stock provider to the
    substitution service, so both paths agree.
32. **Cleanup service with simulation** - `zcl_alloc_cleanup` wraps the commitment
    cleanup. `run_before( cutoff, simulation )` collects the expired rows into
    `ty_outcome-rows`, reports how many matched (`candidates`) and, unless
    `simulation` is set, deletes them and reports `removed`. `run(
    retention_days, simulation )` derives the cutoff from `sy-datum`. Simulation
    defaults to `abap_true`, so calling the service without arguments can never
    delete anything.
33. **Request validation in the run** - `zcl_stock_alloc_run` now skips requests
    with an empty material or plant instead of allocating them (previously they
    produced an empty material result). `ty_stats` gained `skipped`, and
    `run_in_packages( )` carries that count across packages, so a run reports how
    many requests were ignored as well as how many were processed.
34. **Material overview across runs** - `zcl_alloc_material_report` joins the run
    headers (`ZSTOCKRUN`) and the allocation log (`ZSTOCKALLOC`) per material and
    plant. `overview( )` aggregates, across every run, the number of distinct runs,
    the requirement count and the requested / allocated / shortage quantities from
    the headers, and counts the logged allocation positions from the log. A derived
    `coverage_pct` is added per line. `overview_of_material( iv_matnr )` filters to
    one material, `to_lines( )` renders the same CSV form as the run report and
    `field_catalog( )` exposes the columns.     Log rows for a material that has no run
    header are ignored, so the header stays the source of truth. `zcl_alloc_log_reader`
    gained `read_all( )` for this.
35. **Minimum remaining shelf life** - `ty_policy-min_remaining_days` plus
    `reference_date` makes the allocator skip batches whose expiry date is earlier
    than `reference_date + min_remaining_days`. The cutoff is inclusive, batches
    without an expiry date stay usable, and the deduction applies to
    `available_quantity( )` as well because it is applied while the availability is
    built. Off by default.
36. **Storage location allow / exclude list** - `ty_policy-allowed_lgorts` is an
    allow-list (empty = every location) and `ty_policy-excluded_lgorts` a deny-list.
    The allocator filters stock rows through `is_lgort_allowed( )` while building
    availability, so allocations and `available_quantity( )` both honour it. The
    deny-list wins over the allow-list.
37. **Replenishment proposals** - `zcl_alloc_replenishment` turns an allocation
    result into order proposals: one line per requirement with a shortfall, carrying
    the material, the requirement id, the shortage and a proposed order quantity.
    The order quantity is rounded up to a whole multiple of `iv_round_to` (lot size,
    `0` = exact) and then raised to at least `iv_min_order`. A summary totals the
    proposals, the shortage and the order quantity. Fully covered requirements are
    skipped. Pure calculation, no database access.
38. **Run reversal / audit trail** - `zcl_alloc_run_header` gained the status `X`
    (`c_status_reversed`) and `reverse_run( iv_run_id )`, which stamps every header
    of a run as reversed and returns how many rows were touched. `read_active( )`
    returns the headers excluding reversed runs. `zcl_alloc_run_report` and
    `zcl_alloc_material_report` skip reversed runs, so a reversed run disappears
    from both overviews while its `ZSTOCKRUN` and `ZSTOCKALLOC` rows stay for the
    audit trail.
39. **Plant-to-plant transfer proposal** - `zcl_stock_transfer` reads the available
    quantity of a material in a source and a target plant (through an internal
    allocator, so any `ty_policy` applies) and proposes moving stock: the transfer
    quantity is the target's shortfall capped by the source's availability, and the
    remaining uncovered quantity is reported as shortage. When the target already
    covers the demand nothing is proposed. `available( )` exposes the per-plant
    availability on its own.
40. **Allocation result diff** - `zcl_alloc_diff` compares two allocation results
    per requirement id and classifies every line: `+` added, `-` removed from the
    new result, `~` changed and `=` unchanged. A line carries the old and new
    allocated quantity and the delta; unchanged lines are hidden unless
    `iv_include_unchanged` is set. The summary counts each class and totals the old,
    new and delta quantity. Pure calculation, no database access.
41. **Allocation overview JSON export** - `zcl_alloc_export` renders the run and
    material overviews as JSON arrays (`run_overview_json`,
    `material_overview_json`), mirroring the panel columns. It is meant to feed the
    overviews into a browser or a REST layer without going through CSV. Values are
    emitted unescaped on purpose - they are SAP identifiers (material, plant, run
    id, status) that cannot contain JSON metacharacters - see ANOMALIES.md A17 for
    why the escaping helper was dropped.
42. **Batch availability inquiry** - `zcl_batch_inquiry` lists the batches of a
    material/plant from any `zif_stock_reader` (typically the `MCHB` reader) in
    FEFO order: earliest expiry first, batches without an expiry date last, then by
    storage location and batch. Each line carries location, batch, expiry and the
    unrestricted quantity; the summary totals the batches, the quantity and the
    earliest expiry. A read-only report, no policy, no database of its own.
43. **Reservation document service** - `zcl_reservation_doc` presents the stock
    commitments as a document. `create( )` commits an allocation result under a
    document id (reusing `zcl_stock_commitment`), `items( )` returns the reservation
    rows of one document, `summarize( )` aggregates positions, distinct materials,
    total quantity and the earliest creation date, and `release( )` removes the
    document. The document id is the run id of the commitment rows, so no extra
    table is needed.

44. **CSV quoting and line builder** - `zcl_alloc_csv` centralises CSV escaping for
    every text export: `quote( )` wraps a value in double quotes and doubles inner
    quotes when it contains a quote, a semicolon or a comma, and `build_line( )`
    joins quoted fields with a configurable separator (default `;`). Plain values
    and the empty field list pass through unchanged.
45. **Fixed-width text table renderer** - `zcl_alloc_fixed_width`. `pad( )` truncates
    a value that is too long and right-pads it with blanks to the requested width
    (width `0` leaves it untouched); `build_line( )` zips a field list with a width
    list, using width `0` for fields without a configured width. Used for classic
    list output where CSV is not wanted.
46. **Markdown table for the run overview** - `zcl_alloc_markdown=>run_overview( )`
    renders a `zcl_alloc_run_report=>ty_overview_tt` as a Markdown table (title
    row, separator row, one row per run). Cells are added through an internal
    helper so the pipe-separated layout stays in one place.
47. **HTML table for the run overview** - `zcl_alloc_html=>run_overview( )` renders
    the same overview as an HTML `<table>` (one `<tr>` per run, `<th>` header,
    `<td>` cells). `escape( )` escapes `&`, `<` and `>` so a material number with
    metacharacters cannot break the markup.
48. **XML document for the run overview** - `zcl_alloc_xml=>run_overview( )` renders
    the run overview as an XML document (`<runs><run><run_id>...`), one `<run>`
    per header. `escape( )` escapes `&`, `<` and `>`; elements are built through a
    helper so the nesting stays in one place.
49. **JSON for the shortage report** - `zcl_alloc_shortage_json=>build( )` serialises
    a `zcl_alloc_shortage_report=>ty_report`: a `summary` object (requested,
    allocated, shortage, coverage, line and short-line counts) and a `lines`
    array with one object per requirement line. The `covered` flag is emitted as
    a JSON `true`/`false`, not as an ABAP `X`.
50. **JSON for the replenishment proposals** - `zcl_alloc_replen_json=>build( )`
    serialises a `zcl_alloc_replenishment=>ty_result` into `{"proposals":[...],
    "summary":{...}}`, one object per order proposal.
51. **JSON for the allocation diff** - `zcl_alloc_diff_json=>build( )` serialises a
    `zcl_alloc_diff=>ty_result` into `{"lines":[...],"summary":{...}}`, one
    object per diff line including the `change_type` marker.
52. **CSV for the shortage report** - `zcl_alloc_shortage_csv=>build( )` renders a
    shortage report as CSV: a header plus one line per requirement line, with the
    `covered` flag as `Y`/`N`. It reuses `zcl_alloc_csv` for quoting, so a value
    containing the separator is escaped correctly.
53. **CSV for the replenishment proposals** - `zcl_alloc_replen_csv=>build( )`
    renders the replenishment result as CSV (`MATNR;REQUIREMENT_ID;SHORTAGE;
    ORDER_QTY`), one line per order proposal, again through `zcl_alloc_csv`.
54. **Number and quantity formatting** - `zcl_alloc_number_format`. `format_qty( )`
    renders a `menge_d` the way a string template does (`'5.000'`), and
    `trim_zeros( )` strips trailing zeros and a dangling decimal point (`'5.500'`
    -> `'5.5'`, `'5.000'` -> `'5'`, `''` stays `''`).
55. **Percentage formatting and parsing** - `zcl_alloc_percent`. `ratio( )` returns
    the floored percentage of a part in a total (`0` for a non-positive total),
    `apply( )` returns the quantity for a percentage of a base, and `format( )`
    renders `'60 %'`.
56. **Duration (seconds) formatting** - `zcl_alloc_duration`. `to_text( )` renders
    a second count as `h:mm:ss` with zero-padded minutes and seconds (`3661` ->
    `'1:01:01'`), `to_seconds( )` is the inverse.
57. **Text alignment and padding** - `zcl_alloc_align`. `left_value( )` right-pads
    (truncating when too long), `right_value( )` left-pads, and `center_value( )`
    splits the padding, giving the extra blank at the end for an odd remainder.
    Width `0` leaves the value untouched.
58. **Allocation KPI summary** - `zcl_alloc_kpi=>summarize( )` turns an allocation
    result into KPIs: requirement count, fully delivered / short counts, requested
    / allocated / shortage totals, the floored quantity coverage and the floored
    order fill rate (fully delivered lines / lines). Divisions are guarded, so an
    empty result yields zeros.
59. **ABC classification of materials** - `zcl_alloc_abc=>classify( )` sorts a
    material/quantity list descending and adds `share_pct`, the running `cum_pct`
    and an A/B/C class. The class comes from the cumulative share *before* the
    line: `< 80` is A, `< 95` is B, otherwise C, so a single material is A and a
    90/10 split is A/B. A zero total yields share `0` without dividing.
60. **Top-N materials by allocated quantity** - `zcl_alloc_top_n=>top( )` sorts a
    material/quantity list descending and returns the first `iv_n` lines with a
    `rank` and a floored `share_pct` of the total. `iv_n` of `0` (or less) returns
    every line, and a limit above the list size is harmless.
61. **Quantity histogram / buckets** - `zcl_alloc_histogram=>build( )` assigns
    every item to a bucket of `iv_bucket_size` (`quantity DIV size`), then groups
    the buckets and returns them sorted with the bucket bounds, the number of
    items and the summed quantity. A size of `0` (or less) falls back to `1`.
62. **Demand variance across runs** - `zcl_alloc_demand_variance=>analyze( )`
    summarises a quantity series: count, total, mean, minimum, maximum, range and
    the population variance (mean of the squared deviations). An empty series
    yields zeros without dividing by zero.
63. **Moving average of allocated quantity** - `zcl_alloc_moving_average=>calculate( )`
    returns one line per input value with the average of the trailing `iv_window`
    values (the current one included). The first values are averaged over what is
    available, so the warm-up period is reported too; a window below `1` is
    treated as `1`. The running sum drops the value that leaves the window.
64. **Trend detection** - `zcl_alloc_trend=>analyze( )` compares the first and the
    last value of a quantity series and returns the count, both endpoints, the
    floored percentage change (guard for a zero first value) and a direction:
    `U` (rising), `D` (falling) or `F` (flat / empty / single value).
65. **Simple forecast of the next quantity** - `zcl_alloc_forecast=>next_quantity( )`
    returns the average of the last `iv_window` values of a quantity series (the
    simple forecast for the next period). A window above the series length
    averages everything, a window below `1` is treated as `1`, and an empty
    series forecasts `0`.
66. **Service level (fill rate) per material** - `zcl_alloc_service_level=>summarize( )`
    groups requested / allocated quantity lines by material and returns one line
    per material with requested, allocated, shortage, line count and the floored
    fill rate (allocated / requested). Grouping is done by sorting and comparing
    the material, not with `LOOP GROUP BY`, which the transpiler rejects.
67. **Running totals over a result list** - `zcl_alloc_running_total=>calculate( )`
    returns one line per input quantity with its 1-based `index`, the quantity
    and the cumulative `total` up to and including that line.
68. **Confidence score for an allocation** - `zcl_alloc_confidence=>assess( )`
    derives a 0-100 confidence from an allocation result: the floored quantity
    coverage, the floored order fill rate (fully delivered lines / lines) and their
    average as the `score`. An empty result scores `0`.
69. **Risk score for a shortage list** - `zcl_alloc_risk=>assess( )` totals a list
    of shortage rows and, against a caller-supplied reference quantity, returns
    the floored risk percentage and a level: `H` at 50% or more, `M` at 20% or
    more, otherwise `L`. An empty list is `L`, and a non-positive reference yields
    `0` without dividing.
70. **Request validator** - `zcl_alloc_request_validator=>validate( )` returns one
    issue per failed rule for every request row: an empty material, an empty plant
    or a non-positive quantity, each with the row index, the field name and a
    message. A row can produce several issues, and a valid list produces none.
71. **Policy validator** - `zcl_alloc_policy_validator=>validate( )` checks a
    `zcl_stock_allocator=>ty_policy`: an under-delivery tolerance outside 0-100, a
    negative `max_picks`, `safety_stock` or `min_remaining_days`, a shelf-life rule
    without a reference date, and an allow-list combined with an exclude-list. The
    default policy is valid.
72. **Allocation consistency check** - `zcl_alloc_consistency=>check( )` re-derives
    the invariants of an allocation result and reports one issue per violated rule:
    a negative requested or allocated quantity, an allocation above the request and
    a shortage that does not equal requested minus allocated.
73. **Duplicate requirement detection** - `zcl_alloc_duplicate_check=>find( )`
    groups requirements by id (sort and compare, no `LOOP GROUP BY`) and returns
    only the ids that occur more than once, with their count. Unique ids and an
    empty list produce no result.
74. **Stock row data quality check** - `zcl_alloc_stock_check=>check( )` validates
    stock rows from any `zif_stock_reader`: an empty material, plant or storage
    location, a negative unrestricted quantity, or any other negative quantity
    each produce one issue carrying the material, location and message. A valid
    row produces none.
75. **Negative quantity detector** - `zcl_alloc_negative_check=>find( )` returns
    only the rows of an id/quantity list whose quantity is below zero; zero and
    positive quantities pass, and an empty list returns nothing.
76. **Over-allocation detector** - `zcl_alloc_over_check=>find( )` scans an
    allocation result and returns the requirements whose allocated quantity is
    greater than the requested quantity, with both quantities attached. An
    allocation exactly equal to the request is not over-allocated.
77. **Missing master data check** - `zcl_alloc_master_check=>check( )` takes a
    request list plus the known material and plant lists (one `ty_input`
    structure) and reports one issue per request whose material or plant has no
    master record. A fully known list produces no issue.
78. **Priority scoring from weighted rules** - `zcl_alloc_priority=>score( )`
    turns delivery priority (times 10), an urgency bonus (the days until due
    subtracted from 30, only for a due date in the next 30 days) and a customer
    weight into a single score. A due date of today contributes no bonus, and an
    all-zero factor set scores 0.
79. **Stock sequencing (FIFO / LIFO)** - `zcl_alloc_sequence=>order( )` sorts stock
    rows by goods receipt date: FIFO ascending, LIFO descending. Rows without a
    receipt date are always placed last by an internal sort key (`99991231` for
    FIFO, `00000000` for LIFO). Mode `F` is the default.
80. **Round-robin fair share** - `zcl_alloc_round_robin=>distribute( )` spreads an
    available quantity one unit at a time across the demands, so every demand is
    served in turn until the stock is gone or all demands are met. Each grant line
    carries the 1-based demand index and the granted quantity.
81. **Proportional (pro-rata) allocation** - `zcl_alloc_proportional=>distribute( )`
    gives every demand `available * demand / total` (floored, capped at the
    demand) and then hands the rounding remainder out one unit at a time in order.
    An available quantity above the total demand is capped per demand.
82. **Max-min fair allocation** - `zcl_alloc_maxmin=>allocate( )` water-fills the
    available quantity: it repeatedly gives every still-open demand an equal share
    (or a single unit when the share would be zero), redistributing the surplus of
    small demands. A demand of 2 next to a demand of 10 with 6 available gets 2/4.
83. **Capacity-constrained allocation** - `zcl_alloc_capacity=>allocate( )` serves
    the demands in order but stops once the total reaches `iv_capacity`;
    a negative demand is treated as zero and an exhausted capacity yields zeros.
84. **Load balancing across plants** - `zcl_alloc_load_balance=>balance( )` spreads
    a demand across plants in proportion to their availability, capped by the
    availability of each plant, then hands out the rounding remainder in order.
    If the total availability is below the demand, only what exists is granted.
85. **Requirement merge** - `zcl_alloc_req_merge=>merge( )` groups requirements by
    id (sort and compare) and sums their requested quantity, keeping the priority,
    date and unit of the first entry of each id.
86. **Requirement split by size** - `zcl_alloc_req_split=>split( )` cuts one
    requirement into parts of at most `iv_max_qty`; a non-positive maximum or a
    non-positive quantity returns the requirement unchanged in a single part.
87. **Requirement grouping by material** - `zcl_alloc_req_group=>group( )` turns a
    flat material/requirement list into one line per material with the number of
    requirements and the summed requested quantity, sorted by material.
88. **Requirement netting against stock** - `zcl_alloc_req_net=>net( )` consumes
    stock against the requirements in date order and returns the uncovered rest
    (only requirements with a remaining quantity), plus the covered quantity and
    the leftover stock.
89. **Reorder point calculation** - `zcl_alloc_reorder_point=>calculate( )` returns
    daily demand times lead time plus safety stock from a `ty_input` structure.
90. **Economic order quantity (EOQ)** - `zcl_alloc_eoq=>calculate( )` applies
    `sqrt(2 * annual_demand * order_cost / holding_cost)` with an internal integer
    square root, so no runtime `sqrt` is needed. A non-positive holding cost or
    demand yields `0`.
91. **Days of supply** - `zcl_alloc_days_supply=>calculate( )` floors `stock /
    daily_demand`; a non-positive daily demand yields `0`.
92. **Stock turn rate** - `zcl_alloc_turn_rate=>calculate( )` floors `consumption /
    average_stock`; a non-positive average stock yields `0`.
93. **Inventory value at a price** - `zcl_alloc_inventory_value=>calculate( )`
    multiplies a quantity by a price.
94. **Weighted average price** - `zcl_alloc_avg_price=>calculate( )` sums quantity
    times price and divides by the total quantity, ignoring rows with a
    non-positive quantity. An empty list or zero total quantity yields `0`.
95. **Quantity rounding utilities** - `zcl_alloc_rounding` offers `round_to( )`
    (nearest multiple, half up), `round_up_to( )` and `round_down_to( )`. A
    non-positive step leaves the value untouched.
96. **Storage location ranking by quantity** - `zcl_alloc_location_rank=>rank( )`
    sorts locations by quantity descending and adds a `rank`.
97. **Consolidation (bin emptying) proposal** - `zcl_alloc_consolidation=>propose( )`
    returns the bins whose quantity is at or below `threshold_pct` of their
    capacity, skipping empty or capacity-less bins.
98. **Pick sequence within a plant** - `zcl_alloc_pick_sequence=>sequence( )`
    sorts picks by storage location and then batch so a picker works one bin at a
    time.
99. **Bin replenishment trigger** - `zcl_alloc_bin_replenish=>propose( )` returns
    the bins below a reorder point with their shortfall.
100. **Picking list from an allocation** - `zcl_alloc_pick_list=>build( )` flattens
     an allocation result into one pick line per allocation (requirement, storage
     location, batch, quantity), skipping zero quantities.
101. **Picking list confirmation** - `zcl_alloc_pick_confirm=>confirm( )` compares
     planned and confirmed quantities per line and reports the difference plus a
     `complete` flag; a missing confirmation counts as zero.
102. **Location scoring for selection** - `zcl_alloc_location_score=>score( )`
     scores a location as `fill_pct * 2 - distance - picks * 5`, clamped at zero.
103. **Working-day calendar** - `zcl_alloc_calendar` skips weekends: `is_weekend( )`
     uses Zeller's congruence (see ANOMALIES.md A20) and `add_working_days( )`
     advances the date day by day with an explicit leap-year rule, so it does not
     depend on `d`-field arithmetic.
104. **Date range splitting** - `zcl_alloc_date_range=>split( )` cuts a date range
     into consecutive chunks of at most `chunk_days`; a non-positive chunk size
     yields one range covering everything, and a reversed range yields nothing.
105. **Age of stock in days** - `zcl_alloc_stock_age=>calculate( )` returns the
     days between a goods receipt date and a reference date, `0` for an empty or
     future receipt.
106. **Backlog aging buckets** - `zcl_alloc_aging=>bucket( )` maps days overdue to a
     bucket: `0` not overdue, `1` 1-30, `2` 31-60, `3` 61-90, `4` above 90.
107. **Time slot assignment** - `zcl_alloc_slot=>assign( )` round-robins a number of
     items across `slots` slots (1-based); zero slots assigns slot `0` to all.
108. **Wave planning** - `zcl_alloc_wave=>plan( )` splits an item list into waves of
     at most `wave_size` items; a non-positive size puts everything in wave `0`.
109. **Material batching for picking** - `zcl_alloc_batching=>build( )` merges
     *consecutive* items of the same material into one batch line with a batch
     number and the summed quantity, so a material that reappears later starts a
     new batch.
110. **Per-plant report across runs** - `zcl_alloc_plant_report=>summarize( )`
     groups requested/allocated/shortage rows by plant and adds line count and the
     floored coverage percentage.
111. **Per-day report across runs** - `zcl_alloc_daily_report=>summarize( )`
     groups the same rows by date, adding line count and coverage.
112. **Material x plant pivot** - `zcl_alloc_pivot=>build( )` aggregates (material,
     plant) cells and adds each cell's share of its material's total quantity.
     Totals are accumulated by grouping the sorted list, not with `MODIFY TABLE`.
113. **Material x run matrix** - `zcl_alloc_matrix=>build( )` aggregates (material,
     run) cells with their total quantity, sorted by material then run.
114. **Shipment grouping** - `zcl_alloc_shipment=>build( )` turns picks into one
     shipment per storage location with a shipment number, position count and the
     total quantity.
115. **Delivery split proposal** - `zcl_alloc_delivery_split=>split( )` cuts a
     quantity into deliveries of at most `max_delivery`; a non-positive maximum or
     quantity returns the quantity unchanged in a single element.
116. **SLA compliance report** - `zcl_alloc_sla=>assess( )` compares each lead time
     against its target, flags the line `on_time` and summarises total, on-time,
     breached and the floored compliance percentage.
117. **Event timeline** - `zcl_alloc_timeline=>to_lines( )` sorts events by sequence
     and renders one text line per event (`1: PICK`).
118. **Search / text filter over overviews** - `zcl_alloc_search=>filter( )` returns
     the rows whose text contains the term, case-insensitively, keeping the input
     order.
119. **Pagination helper** - `zcl_alloc_paging=>page( )` turns total size, page size
     and page number into the 1-based from/to indexes, the page count and the
     number of rows on the page. A non-positive page size is one page with
     everything; an out-of-range page is empty.
120. **Generic sort helper for overviews** - `zcl_alloc_sort=>sort( )` returns a run
     overview sorted by run id (default), material, coverage (descending) or
     shortage (descending).
121. **Policy presets** - `zcl_alloc_policy_preset=>preset( )` returns a named policy:
     `FEFO`, `WHOLE`, `SAFE` (quality + blocked), `LIMIT` (one pick) or
     `TOLERANT` (10% under-delivery). An unknown name yields the default policy.
122. **Policy merge** - `zcl_alloc_policy_merge=>merge( )` layers an override policy
     on a base: a `true` flag wins, a non-zero scalar replaces, an empty table
     leaves the base alone. Because `false` and `unset` are indistinguishable, an
     override flag can only turn a setting on.
123. **Policy diff** - `zcl_alloc_policy_diff=>compare( )` lists the policy fields
     that differ, with the old and new value as text (flags, scalars and the sizes
     of the storage-location lists). An identical pair yields no lines.
124. **Run comparison summary** - `zcl_alloc_run_compare=>compare( )` compares two
     run overviews keyed by run id and material and classifies every entry:
     `+` added, `-` removed, `~` changed (coverage), `=` unchanged. Unchanged
     entries are hidden unless `include_unchanged` is set.
125. **Three-way allocation diff** - `zcl_alloc_diff3=>compare( )` merges three
     quantity sets (base, left, right) over the union of their keys and classifies
     each: `S` left = right (including when both changed the same way), `L` only
     the left changed, `R` only the right changed, `C` both changed differently.
126. **Allocation snapshot and compare** - `zcl_alloc_snapshot`. `take( )` captures
     the allocated quantity per requirement into a snapshot structure and
     `compare( )` reports every requirement that changed (before/after/delta),
     including new requirements (before = 0) and removed ones (after = 0).
127. **Checksum of an allocation result** - `zcl_alloc_checksum=>of_result( )`
     folds requirement ids, allocated and shortage quantities into one integer.
     It is stable for the same input and order-sensitive, so it can detect a
     changed or reordered result.
128. **Run / requirement id generator** - `zcl_alloc_id_gen=>generate( )` builds a
     `c LENGTH 20` id from a prefix and a number zero-padded to at least four
     digits.
129. **Run tagging (in-memory)** - `zcl_alloc_tag`. `add( )` appends a tag to a run
     unless the same run already carries it, and `of_run( )` filters the tags of
     one run.
130. **Annotation store (in-memory)** - `zcl_alloc_annotation`. `add( )` stores one
     text per run/material and replaces an existing one, `read( )` returns the text
     or an empty string. The key includes the run id, so the same material in two
     runs has two notes.

Note: the return type of `read( )` is a `TYPES` alias (`ty_text`), not
`TYPE c LENGTH 60`, because a length-typed method parameter does not parse
(ANOMALIES.md A7).
131. **Substitution chain resolver** - `zcl_alloc_subst_chain=>resolve( )` follows
     `from -> to` material rules from a start material and returns the whole path,
     the final material and the number of hops. The walk is capped at the number
     of rules, so a cyclic rule set terminates.
132. **Multi-plant availability aggregation** - `zcl_alloc_multi_plant=>summarize( )`
     groups availability rows by plant and returns the per-plant lines plus the
     grand total and the plant count.
133. **Transport cost comparison** - `zcl_alloc_transport_cost=>rank( )` computes
     `quantity * cost_per_unit` per plant and returns the lines ranked by total
     cost ascending.
134. **Cost-based source selection** - `zcl_alloc_cost=>select( )` fills a required
     quantity from the cheapest sources first, returning the taken quantity and
     cost per source, the total cost and any uncovered remainder.
135. **Footprint estimate for a transfer** - `zcl_alloc_footprint=>estimate( )`
     multiplies distance, quantity and a factor.
136. **Weighted source scoring** - `zcl_alloc_weight=>score( )` returns the
     weight-averaged factor (`sum(factor*weight) / sum(weight)`, floored); a zero
     total weight yields `0`.
137. **Material list from run headers** - `zcl_alloc_material_list=>build( )`
     returns the distinct materials of a run overview, sorted.
138. **Plant list from run headers** - `zcl_alloc_plant_list=>build( )` does the
     same for plants.
139. **Storage location list from a result** - `zcl_alloc_lgort_list=>build( )`
     collects the distinct storage locations used by the allocations of a result,
     sorted.
140. **Quantity bucket helper** - `zcl_alloc_bucket=>bucket( )` maps a value to a
     1-based bucket given ascending boundaries: below the first boundary is `1`,
     a value equal to a boundary already counts as the next bucket.
141. **Batch split proposal** - `zcl_alloc_batch_split=>split( )` packs the items
     into batches that stay within `max_batch`, starting a new batch when the next
     item would overflow. A non-positive maximum puts everything in one batch.
142. **Allocation quality grade (A-F)** - `zcl_alloc_grade=>grade( )` grades a
     result from its coverage and whether it has a shortage: `A` needs full
     coverage without a shortage, then `B` >= 95, `C` >= 80, `D` >= 60, `E` >= 40,
     otherwise `F`.
144. **CSV of the per-run allocations** - `zcl_alloc_export_alloc=>build( )` renders
     one CSV line per allocation (`REQUIREMENT_ID;MATNR;LGORT;CHARG;QUANTITY`) with
     a header line, skipping zero quantities.
145. **CSV of the per-material allocations** - `zcl_alloc_export_alloc_mat=>build( )`
     aggregates the allocations per material and renders `MATNR;POSITIONS;QUANTITY`,
     sorted by material.
146. **JSON of the per-run allocations** - `zcl_alloc_export_alloc_json=>build( )`
     emits an array of requirement objects, each with a nested `allocations` array.
147. **JSON of the per-material allocations** - `zcl_alloc_export_alloc_mjson=>build( )`
     emits an array of `{matnr, positions, quantity}` objects, sorted by material.
148. **XML of the allocations** - `zcl_alloc_export_alloc_xml=>build( )` writes an
     XML document with one `<allocation>` element per requirement and escaped
     values (`&`, `<`, `>`).
149. **Markdown of the allocations** - `zcl_alloc_export_alloc_md=>build( )` writes a
     Markdown table with a header and separator row.
150. **HTML of the allocations** - `zcl_alloc_export_alloc_html=>build( )` writes a
     `<table>` with a `<thead>` and escaped `<td>` cells.
151. **Fixed-width of the allocations** - `zcl_alloc_export_alloc_fw=>build( )`
     renders the allocations through `zcl_alloc_fixed_width` with the column widths
     20/18/6/10/12 (66 characters per line).

Note: the `escape( )` / `cell( )` helpers take `TYPE c`, not `TYPE string`, because
passing a character field to a `string` parameter is rejected (ANOMALIES.md A17).

152. **CSV of the allocation diff** - `zcl_alloc_diff_csv=>build( )` renders the lines
     of a `zcl_alloc_diff=>ty_result` as
     `REQUIREMENT_ID;OLD_QTY;NEW_QTY;DELTA_QTY;CHANGE_TYPE`.
153. **CSV of the run comparison** - `zcl_alloc_run_cmp_csv=>build( )` renders the
     run-comparison lines as
     `RUN_ID;MATNR;CHANGE_TYPE;OLD_COVERAGE;NEW_COVERAGE`.
154. **JSON of the run comparison** - `zcl_alloc_run_cmp_json=>build( )` emits an
     array of `{run_id, matnr, change_type, old_coverage, new_coverage}` objects.
155. **CSV of the SLA report** - `zcl_alloc_sla_csv=>build( )` renders the SLA lines
     with a `Y`/`N` on-time flag and appends a `SUMMARY;total;on_time;compliance`
     row, so an empty report still produces exactly two lines.
156. **JSON of the SLA report** - `zcl_alloc_sla_json=>build( )` emits the summary
     counters followed by a `lines` array with a `true`/`false` on-time flag.
157. **CSV of the aging report** - `zcl_alloc_aging_csv=>build( )` renders an
     `ID;DAYS_OVERDUE;BUCKET` line per entry, using `zcl_alloc_aging=>bucket( )`.
158. **JSON of the aging report** - `zcl_alloc_aging_json=>build( )` emits an array
     of `{id, days_overdue, bucket}` objects.
159. **CSV of the plant report** - `zcl_alloc_plant_csv=>build( )` renders the plant
     report lines as
     `WERKS;LINES;REQUESTED_QTY;ALLOCATED_QTY;SHORTAGE_QTY;COVERAGE_PCT`.
160. **CSV of the daily report** - `zcl_alloc_daily_csv=>build( )` renders the daily
     report lines as `RUN_DATE;LINES;REQUESTED_QTY;ALLOCATED_QTY;COVERAGE_PCT`.
161. **JSON of the plant report** - `zcl_alloc_plant_json=>build( )` emits an array
     of plant objects with all report measures.
162. **JSON of the daily report** - `zcl_alloc_daily_json=>build( )` emits an array
     of day objects with all report measures.
163. **CSV of the KPI summary** - `zcl_alloc_kpi_csv=>build( )` writes the header
     `REQUIREMENTS;FULLY_DELIVERED;SHORT;REQUESTED_QTY;ALLOCATED_QTY;SHORTAGE_QTY;`
     `COVERAGE_PCT;FILL_RATE_PCT` plus one value row.
164. **JSON of the KPI summary** - `zcl_alloc_kpi_json=>build( )` emits the KPI
     measures as one JSON object (an empty KPI still produces a full object).
165. **CSV of the ABC classification** - `zcl_alloc_abc_csv=>build( )` writes
     `MATNR;QUANTITY;SHARE_PCT;CUM_PCT;CLASS`.
166. **JSON of the ABC classification** - `zcl_alloc_abc_json=>build( )` emits an
     array of `{matnr, quantity, share_pct, cum_pct, class}` objects.
167. **CSV of the histogram** - `zcl_alloc_hist_csv=>build( )` writes
     `BUCKET_FROM;BUCKET_TO;COUNT;QUANTITY`.
168. **JSON of the histogram** - `zcl_alloc_hist_json=>build( )` emits the buckets as
     JSON objects with from/to, count and quantity.
169. **CSV of the top-N list** - `zcl_alloc_topn_csv=>build( )` writes
     `RANK;MATNR;QUANTITY;SHARE_PCT`.
170. **JSON of the top-N list** - `zcl_alloc_topn_json=>build( )` emits the ranked
     entries as JSON objects.
171. **CSV of the moving average** - `zcl_alloc_mavg_csv=>build( )` writes
     `INDEX;QUANTITY;AVERAGE`.
172. **JSON of the moving average** - `zcl_alloc_mavg_json=>build( )` emits the
     series as JSON objects with index, quantity and average.
173. **CSV of the trend analysis** - `zcl_alloc_trend_csv=>build( )` writes
     `COUNT;FIRST_QTY;LAST_QTY;CHANGE_PCT;DIRECTION` plus one value row.
174. **JSON of the trend analysis** - `zcl_alloc_trend_json=>build( )` emits the trend
     as one JSON object.
175. **CSV of the forecast** - `zcl_alloc_forecast_csv=>build( )` lists the history
     as `INDEX;QUANTITY` rows and appends a `FORECAST;<qty>` row produced by
     `zcl_alloc_forecast=>next_quantity( )` with the input window.
176. **JSON of the forecast** - `zcl_alloc_forecast_json=>build( )` emits
     `{forecast, window, values[]}`.
177. **CSV of the service level** - `zcl_alloc_service_csv=>build( )` writes
     `MATNR;REQUESTED_QTY;ALLOCATED_QTY;SHORTAGE_QTY;FILL_RATE_PCT;LINES`.
178. **JSON of the service level** - `zcl_alloc_service_json=>build( )` emits an
     array of the per-material service levels.
179. **CSV of the confidence score** - `zcl_alloc_conf_csv=>build( )` writes
     `REQUIREMENTS;COVERAGE_PCT;FILL_RATE_PCT;SCORE`.
180. **JSON of the confidence score** - `zcl_alloc_conf_json=>build( )` emits the four
     confidence measures as one object.
181. **CSV of the risk score** - `zcl_alloc_risk_csv=>build( )` writes
     `LINES;SHORTAGE_QTY;RISK_PCT;LEVEL`.
182. **JSON of the risk score** - `zcl_alloc_risk_json=>build( )` emits the risk
     measures as one object.
183. **CSV of the request validation** - `zcl_alloc_reqval_csv=>build( )` writes
     `INDEX;FIELD_NAME;MESSAGE`.
184. **JSON of the request validation** - `zcl_alloc_reqval_json=>build( )` emits the
     issues as `{index, field_name, message}` objects.
185. **CSV of the policy validation** - `zcl_alloc_polval_csv=>build( )` writes
     `FIELD_NAME;MESSAGE`.
186. **JSON of the policy validation** - `zcl_alloc_polval_json=>build( )` emits the
     policy issues as JSON objects.
187. **CSV of the consistency check** - `zcl_alloc_consist_csv=>build( )` writes
     `REQUIREMENT_ID;MESSAGE`.
188. **JSON of the consistency check** - `zcl_alloc_consist_json=>build( )` emits the
     consistency issues as JSON objects.
189. **CSV of the duplicate check** - `zcl_alloc_dupc_csv=>build( )` writes
     `ID;COUNT`.
190. **JSON of the duplicate check** - `zcl_alloc_dupc_json=>build( )` emits
     `{id, count}` objects.
191. **CSV of the stock check** - `zcl_alloc_stockchk_csv=>build( )` writes
     `MATNR;LGORT;MESSAGE`.
192. **JSON of the stock check** - `zcl_alloc_stockchk_json=>build( )` emits the stock
     issues as JSON objects.
193. **CSV of the negative check** - `zcl_alloc_negchk_csv=>build( )` writes
     `ID;QUANTITY` for the negative rows.
194. **JSON of the negative check** - `zcl_alloc_negchk_json=>build( )` emits
     `{id, quantity}` objects.
195. **CSV of the over-allocation check** - `zcl_alloc_overchk_csv=>build( )` writes
     `REQUIREMENT_ID;REQUESTED_QTY;ALLOCATED_QTY`.
196. **JSON of the over-allocation check** - `zcl_alloc_overchk_json=>build( )` emits
     the over-allocations as JSON objects.
197. **CSV of the master data check** - `zcl_alloc_mastchk_csv=>build( )` writes
     `MATNR;WERKS;MESSAGE`.
198. **JSON of the master data check** - `zcl_alloc_mastchk_json=>build( )` emits the
     master-data issues as JSON objects.
199. **CSV of the priority list** - `zcl_alloc_prio_csv=>build( )` writes
     `REQUIREMENT_ID;DELIVERY_PRIORITY;DAYS_UNTIL_DUE;CUSTOMER_WEIGHT;SCORE`,
     computing the score per row with `zcl_alloc_priority=>score( )`.
200. **JSON of the priority list** - `zcl_alloc_prio_json=>build( )` emits the factors
     plus the computed score per requirement.
201. **CSV of the pick list** - `zcl_alloc_pickl_csv=>build( )` writes
     `REQUIREMENT_ID;LGORT;CHARG;QUANTITY`.
202. **JSON of the pick list** - `zcl_alloc_pickl_json=>build( )` emits the pick
     positions as JSON objects.
203. **CSV of the pick confirmation** - `zcl_alloc_pickc_csv=>build( )` writes
     `INDEX;PLANNED;CONFIRMED;DIFFERENCE;COMPLETE` with a `Y`/`N` completeness flag.
204. **JSON of the pick confirmation** - `zcl_alloc_pickc_json=>build( )` emits the
     confirmation lines with a `true`/`false` completeness flag.
205. **CSV of the pick sequence** - `zcl_alloc_picks_csv=>build( )` writes
     `LGORT;CHARG;QUANTITY`.
206. **JSON of the pick sequence** - `zcl_alloc_picks_json=>build( )` emits the pick
     path as JSON objects.
207. **CSV of the location ranking** - `zcl_alloc_lrank_csv=>build( )` writes
     `RANK;LGORT;QUANTITY`.
208. **JSON of the location ranking** - `zcl_alloc_lrank_json=>build( )` emits the
     ranked locations as JSON objects.
209. **CSV of the location score** - `zcl_alloc_lscore_csv=>build( )` writes
     `LGORT;FILL_PCT;DISTANCE;PICKS;SCORE`, computing the score per row with
     `zcl_alloc_location_score=>score( )`.
210. **JSON of the location score** - `zcl_alloc_lscore_json=>build( )` emits the
     inputs plus the computed score per location.
211. **CSV of the shipments** - `zcl_alloc_ship_csv=>build( )` writes
     `SHIPMENT;LGORT;POSITIONS;QUANTITY`.
212. **JSON of the shipments** - `zcl_alloc_ship_json=>build( )` emits the shipments as
     JSON objects.
213. **CSV of the waves** - `zcl_alloc_wave_csv=>build( )` writes
     `WAVE;INDEX;QUANTITY`.
214. **JSON of the waves** - `zcl_alloc_wave_json=>build( )` emits the planned waves as
     JSON objects.
215. **CSV of the batches** - `zcl_alloc_batch_csv=>build( )` writes
     `BATCH;MATNR;QUANTITY`.
216. **JSON of the batches** - `zcl_alloc_batch_json=>build( )` emits the packed batches
     as JSON objects.
217. **CSV of the tags** - `zcl_alloc_tag_csv=>build( )` writes `RUN_ID;TAG`.
218. **JSON of the tags** - `zcl_alloc_tag_json=>build( )` emits `{run_id, tag}`
     objects.
219. **CSV of the annotations** - `zcl_alloc_note_csv=>build( )` writes
     `RUN_ID;MATNR;TEXT`.
220. **JSON of the annotations** - `zcl_alloc_note_json=>build( )` emits
     `{run_id, matnr, text}` objects.
221. **CSV of the timeline** - `zcl_alloc_timeline_csv=>build( )` writes
     `SEQUENCE;NAME`.
222. **JSON of the timeline** - `zcl_alloc_timeline_json=>build( )` emits the events as
     JSON objects.
223. **CSV of the snapshot diff** - `zcl_alloc_snap_csv=>build( )` writes
     `REQUIREMENT_ID;BEFORE_QTY;AFTER_QTY;DELTA_QTY`.
224. **JSON of the snapshot diff** - `zcl_alloc_snap_json=>build( )` emits the changes as
     JSON objects.
225. **CSV of the three-way diff** - `zcl_alloc_diff3_csv=>build( )` writes
     `ID;BASE_QTY;LEFT_QTY;RIGHT_QTY;STATUS`.
226. **JSON of the three-way diff** - `zcl_alloc_diff3_json=>build( )` emits the merged
     lines as JSON objects.
227. **CSV of the cost selection** - `zcl_alloc_cost_csv=>build( )` writes
     `WERKS;TAKEN;COST` per source and appends a `SUMMARY;total_cost;remaining` row, so
     an empty result still produces exactly two lines.
228. **JSON of the cost selection** - `zcl_alloc_cost_json=>build( )` emits
     `{lines:[...], total_cost, remaining}`.
229. **CSV of the transport costs** - `zcl_alloc_tcost_csv=>build( )` writes
     `WERKS;COST_TOTAL;RANK`.
230. **JSON of the transport costs** - `zcl_alloc_tcost_json=>build( )` emits the ranked
     costs as JSON objects.
231. **CSV of the substitution chain** - `zcl_alloc_subst_csv=>build( )` writes the path
     as `STEP;MATNR` rows followed by `FINAL;<matnr>` and `STEPS;<n>` rows.
232. **JSON of the substitution chain** - `zcl_alloc_subst_json=>build( )` emits
     `{path:[...], final_matnr, steps}`.
233. **CSV of the multi-plant summary** - `zcl_alloc_mplant_csv=>build( )` writes
     `WERKS;QUANTITY` rows plus `TOTAL;<qty>` and `PLANTS;<n>` rows.
234. **JSON of the multi-plant summary** - `zcl_alloc_mplant_json=>build( )` emits
     `{plants:[...], total, plant_count}`.
235. **CSV of the grade distribution** - `zcl_alloc_grade_csv=>build( )` counts the
     grades of a list of coverage/shortage rows and writes `GRADE;COUNT` for all six
     grades A-F, so an empty list still yields six rows.
236. **JSON of the grade distribution** - `zcl_alloc_grade_json=>build( )` emits one
     object per input row with its coverage and computed grade.
237. **CSV of the bucket report** - `zcl_alloc_bucket_csv=>build( )` writes
     `VALUE;BUCKET` for a list of values against shared boundaries.
238. **JSON of the bucket report** - `zcl_alloc_bucket_json=>build( )` emits
     `{value, bucket}` objects.
239. **Unified export facade** - `zcl_alloc_export_facade` dispatches on a format kind:
     `as_csv( )` supports `ALLOC`, `MAT` and `PICK` (the last one converting the result
     to pick lines first), `as_json( )` supports `ALLOC` and `MAT` and returns `[]` for
     an unknown kind.
240. **Export format registry** - `zcl_alloc_format_registry=>add( )` inserts an entry
     or replaces the format of an existing name and keeps the table sorted.
241. **Default export format per consumer** - `zcl_alloc_format_default=>default_for( )`
     maps `EMAIL` to HTML, `API` to JSON, `PRINT` to fixed width and everything else
     to CSV.
242. **Export registry lookup by name** - `zcl_alloc_format_lookup=>lookup( )` returns
     the registered format or an empty string.
243. **Export registry listing** - `zcl_alloc_format_list` returns the distinct entry
     names sorted (`names( )`) and their count (`count( )`).
244. **Lock manager abstraction** - `zcl_alloc_lock` keeps a lock table in memory:
     `acquire( )` adds a lock unless the object/key pair is already locked,
     `release( )` rebuilds the table without that pair (no `DELETE`) and
     `is_locked( )` reports whether it is held.
245. **Enqueue wrapper** - `zcl_alloc_enqueue=>enqueue( )` validates a lock request and
     returns `{ accepted, message }`: an empty object or key is rejected with a reason,
     otherwise the lock is reported as accepted.
246. **Dequeue wrapper** - `zcl_alloc_dequeue=>dequeue( )` clears a lock request and
     `distinct_count( )` counts the distinct objects in a list of requests.
247. **Number range interval reader** - `zcl_alloc_number_range`. `next( )` advances by
     the interval, `in_range( )` checks a number against a from/to interval and
     `remaining( )` returns the free numbers (never negative).
248. **Number range writer (in-memory)** - `zcl_alloc_number_range_w=>reserve( )` grants
     the smaller of the request and the available numbers (zero for a non-positive
     request or availability) and `exhausted( )` reports a fully used range.
249. **Change document writer (in-memory)** - `zcl_alloc_change_doc=>add( )` appends a
     change entry but skips it when the old and new value are equal, so only real
     changes are documented.
250. **Change document reader** - `zcl_alloc_change_read` filters the entries of one
     object/key pair (`of_object( )`) and counts the entries touching one field
     (`field_count( )`).
251. **Application log writer** - `zcl_alloc_app_log` appends an entry
     (`write( )`) keeping the history and counts the entries of one level
     (`count_of_level( )`).
252. **Application log reader** - `zcl_alloc_app_log_read` returns the messages of one
     level (`messages( )`) and reports whether any entry is an error
     (`has_errors( )`).
253. **Message collector** - `zcl_alloc_messages` collects a message unless its text is
     empty (`collect( )`) and counts a message table (`count( )`).

Test coverage (1001 ABAP Unit tests, run on Node through the transpiler):

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
  quantity), per-location safety stock (per location, plant-wide, other location
  untouched, batches deducted once, no config, available quantity)
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
  requested/allocated/shortage totals, empty request list, package-wise run
  (matches single run, size 1, size 0, larger than the list), invalid requests
  (empty material, empty plant, mixed list, skipped count across packages)
* Log reader: run filter, position and quantity totals, distinct material count,
  per-run summaries, empty run
* Shortage report: full coverage, floored partial coverage, summary aggregation,
  critical below threshold, no shortage, zero request, empty result, tolerance
  line covered, short line not covered, full delivery covered, deferred covered
* Substitution: rules ordered by priority, no rules, own + substitute
  availability, detail list order, other material ignored, safety stock reduces
  own availability, safety stock reduces a substitute
* Run header: running status on start, totals and done status on finish, finish
  without start, per-run read, empty result totals
* Run report: computed coverage, all runs listed, single run filter, full
  coverage, empty log, CSV header, CSV row formatting, catalog columns, catalog
  matches header, catalog quantity metadata
* Commitment: written rows, per-location aggregation, row material used,
  requested material default, release, empty result, creation date stamp,
  purge older rows, cutoff day kept, purge count, retention wrapper,
  read_expired is a dry run
* Cleanup: simulation keeps rows, execute removes rows, newer rows kept,
  retention days applied, nothing to do
* Reserved reader: subtracts commitment, clamps at zero, other locations,
  no reservation, other material
* Safety stock reader: config rows, all locations, other plant, other material,
  no config
* Material report: positions joined from the log, runs aggregated per material,
  material/plant grouping, material filter, log-only rows ignored, coverage,
  empty result, CSV header, catalog columns
* Allocator shelf life: short-dated skipped, long-dated kept, unknown expiry kept,
  cutoff inclusive, off by default, available quantity
* Allocator location filter: allow-list only, empty allow-list allows all,
  deny-list skipped, allow plus deny, available quantity
* Replenishment: shortage proposal, full delivery skipped, round up to multiple,
  exact multiple kept, minimum order, rounding off, summary totals, empty result
* Run reversal: status set, touched count, unknown run zero, active read excludes
* Reversed in reports: run report excluded, single reversed run empty, material
  report excluded
* Transfer: target covers, transfers shortfall, limited by source, no stock,
  multiple bins summed, other material ignored, availability sums
* Diff: added, removed, changed, unchanged hidden, include unchanged, summary
  totals, reduced to zero is changed, empty both
* Export: empty run JSON, run JSON fields, two rows separated, empty material
  JSON, material JSON fields
* Batch inquiry: FEFO order, unknown expiry last, quantity sum, earliest expiry,
  other plant ignored, empty result
* Reservation document: create and summarize, items per document, distinct
  materials, release removes items, empty summary

## Next candidates

**Both roadmap batches are complete**: orders 44-142 and 144-243 are delivered and
verified (963 tests). The single unbuilt item across both batches is 143 (the ALV
grid / selection screen), which the transpiler cannot exercise.

Per the standing instruction, the next step is to plan a third 100-item batch and
keep iterating. Planned theme for batch 3: **SAP integration and operations** -
lock/enqueue wrappers, number ranges, change documents, application log, message
and exception handling, BAPI/RFC/IDoc and batch-input stubs, commit/rollback and
retry policies, timers and statistics, context (user/client/environment), feature
flags and configuration, masking and authorization stubs, caching, streaming,
idempotency and reconciliation.

Next up (in order):

1. 254 `zcl_alloc_msg_format` - message formatter.
2. 255 `zcl_alloc_error` - error handler.
3. 256 `zcl_alloc_exception_map` - exception mapper.
4. 257 `zcl_alloc_bapi_gm` - BAPI goods movement wrapper.
5. 258 `zcl_alloc_bapi_atp` - BAPI availability wrapper.
6. 259 `zcl_alloc_bapi_mat` - BAPI material read wrapper.
7. 260 `zcl_alloc_bapi_plant` - BAPI plant read wrapper.
8. 261 `zcl_alloc_bapi_facade` - BAPI caller facade.
9. 262 `zcl_alloc_rfc` - RFC destination stub.
10. 263 `zcl_alloc_idoc_writer` - IDoc writer.

Then continue strictly in order 258-343, one feature per iteration, always keeping
`npm test` green.

Standing instruction from the user: when this 100-item roadmap (44-143) is done,
plan another 100 items in the same style and keep iterating (one feature per
iteration, `npm test` green, documented in `NOTES.md`/`ANOMALIES.md`).

Conventions reminder for the next feature: keep method names <= 30 chars, use the
classic `TYPES: BEGIN OF ... END OF ...` form, declare a `TYPES` alias instead of
`TYPE c LENGTH n` or `TYPE STANDARD TABLE OF ...` in parameters, use one `&&` per
statement, and do not put trailing blanks in test literals (ANOMALIES.md A18).

## Conventions

* Method names must be 30 characters or shorter.
* Do not use `TYPE c LENGTH n` in a method parameter list - use a named type or a
  component reference instead (see ANOMALIES.md A7).
* Do not pass a character field to a `TYPE string` parameter; the transpiler does
  not accept the implicit conversion (see ANOMALIES.md A17).
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
