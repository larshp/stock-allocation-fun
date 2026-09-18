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
  reader), `VBAK` (sales order header, carries the requested delivery date
  `VDATU`), `MCHB` (batch stock), `MCHA` (batch master, carries the expiry date
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
   skipped), maps `KWMENG` to the requested quantity, `VBAK-VDATU` to the
   requirement date and `LPRIO` to the priority (an initial priority is treated
   as 1), and builds the requirement id from `VBELN` + `POSNR`. It can be
   injected into `zcl_stock_allocation_service` in place of the `RESB` reader.
   The date originally came from a non-existent `VBAP-EDATU`; see bug fix F1.
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
254. **Message formatter** - `zcl_alloc_msg_format`. `format( )` renders
     `TYPE ID NUMBER TEXT` and `short( )` renders only type and number. The full text
     is built in one string template, because a standalone single-blank literal is
     trimmed (ANOMALIES.md A18), and the test therefore checks the trailing separator
     with `strlen( )` plus a prefix match.
255. **Error handler** - `zcl_alloc_error=>raise( )` appends an error unless its text is
     empty (so a blank error is never recorded) and `has_any( )` reports whether the
     error table holds entries.
256. **Exception mapper** - `zcl_alloc_exception_map=>map( )` classifies an exception by
     its class prefix: `CX_SY_` becomes a retryable `SYSTEM` error with HTTP 500,
     `CX_ABAP_` a non-retryable `ABAP` error with HTTP 500, anything else `UNKNOWN`
     with HTTP 400. Note: the prefix check uses the exact prefix length (`class(6)` for
     `CX_SY_`) - a longer slice compares beyond the prefix and never matches.
257. **BAPI goods movement wrapper** - `zcl_alloc_bapi_gm=>post( )` simulates the BAPI
     call: a missing material, a missing plant or a non-positive quantity is rejected
     with a message and no document, otherwise it reports `executed` plus the document
     number `4900000001`.
258. **BAPI availability wrapper** - `zcl_alloc_bapi_atp=>check( )` confirms the full
     requested quantity when the stock covers it, otherwise reports not available and
     confirms whatever stock exists (zero for an empty stock or a non-positive
     request).
259. **BAPI material read wrapper** - `zcl_alloc_bapi_mat=>read( )` returns
     `found` plus the material, a description and the base unit `ST`, or `found` false
     for an empty material number.
260. **BAPI plant read wrapper** - `zcl_alloc_bapi_plant=>read( )` returns `found` plus
     the plant, its name and country `DE`, or `found` false for an empty plant.
261. **BAPI caller facade** - `zcl_alloc_bapi_facade=>call( )` dispatches on the call
     name: `GOODS_MOVEMENT` posts through the goods movement wrapper and returns its
     document number (or the first rejection message), `AVAILABILITY` checks through
     the availability wrapper and reports the outcome, and any other name is answered
     with `Unknown BAPI`.
262. **RFC destination stub** - `zcl_alloc_rfc`. `ping( )` reports whether a
     destination is configured and `describe( )` renders `DESTINATION:FUNCTION`.
263. **IDoc writer** - `zcl_alloc_idoc_writer=>create( )` builds the segments `EDI_DC40`,
     `E1EDP19:<material>` and `E1EDP26:<quantity>` plus an IDoc number, and answers an
     empty material or a non-positive quantity with a single `IDoc not created`
     segment and no number.
264. **IDoc reader** - `zcl_alloc_idoc_reader=>read( )` inverts the writer: the control
     segment marks the IDoc valid and the `E1EDP19:` / `E1EDP26:` prefixes are stripped
     with `substring( off = 8 )` to recover material and quantity. A missing control
     segment adds `Header segment missing`.
265. **Batch input session builder** - `zcl_alloc_bdc_build=>add( )` appends a BDC row
     (program, dynpro, field, value) and ignores a request with an empty field or
     value.
266. **Batch input session runner (stub)** - `zcl_alloc_bdc_run=>run( )` reports a
     created session with the number of rows, and answers an empty session name or an
     empty row table with `Nothing to run`.
267. **Update task stub** - `zcl_alloc_update_task=>queue( )` collects update task names
     (an empty name is ignored) and `flush( )` reports how many are queued.
268. **Commit / rollback wrapper** - `zcl_alloc_commit`. `commit( )` reports a commit
     with the task count in the message and `rollback( )` reports a rollback, using the
     supplied reason or the default `Rolled back`. Note: the reason parameter is typed
     with a `TYPES` alias (`ty_reason`) because `TYPE c LENGTH 40` in a parameter list
     does not parse (ANOMALIES.md A7).
269. **Timeout guard** - `zcl_alloc_timeout=>check( )` reports whether the elapsed time
     has passed the limit, the remaining seconds (clamped at zero) and a message. A limit
     of zero or less means "no timeout": `is_expired( )` stays false and `remaining( )`
     reports 0.
270. **Retry policy** - `zcl_alloc_retry=>plan( )` decides whether an attempt may be
     retried (`should_retry( )`: attempt < max attempts, a max of 0 meaning never) and
     computes the delay with exponential backoff (`backoff( )` = base * 2^(n-1), capped
     at 300 seconds, 0 without a base delay).
271. **Circuit breaker** - `zcl_alloc_breaker` is a three-state breaker (`CLOSED`,
     `OPEN`, `HALF_OPEN`, exposed as the structured constant `state`). `record_failure( )`
     opens it once the threshold is reached - or immediately from `HALF_OPEN` -,
     `record_success( )` resets the counter and closes a half-open breaker, and
     `probe_half_open( )` moves an open breaker to half-open. `is_allowed( )` blocks calls
     only while it is open.
272. **Rate limiter (in-memory)** - `zcl_alloc_rate_limit`. `consume( )` accepts a request
     while the consumed units fit into the limit (a non-positive request is always
     accepted and consumes nothing) and `reset( )` restores the budget. The constructor
     takes the limit with `DEFAULT 10` and raises a non-positive limit to 1.
273. **Audit trail** - `zcl_alloc_audit` numbers and collects audit entries (kind, run id,
     detail) in memory. `of_run( )` filters by run id (manual loop, no `LOOP GROUP BY`)
     and `entries( )` returns the full trail.
274. **Operation log** - `zcl_alloc_op_log` records named operations with a duration and a
     status (`S`/`E`) and reports the entry count, the `errors( )` subset, the
     `total_ms( )` sum and the `slowest( )` name.
275. **Performance timer** - `zcl_alloc_timer` is a manual stopwatch: `start( )` resets and
     starts it, `add_ms( )` accumulates time only while it runs, `stop( )` ends it, and
     `summary( )` reports started / stopped / elapsed plus `Not started`, `Running` or
     `Elapsed <n> ms`.
276. **Stopwatch** - `zcl_alloc_stopwatch` records numbered laps and derives `total( )`,
     `fastest( )` and `slowest( )` (both 0 for an empty stopwatch).
277. **Run statistics collector** - `zcl_alloc_stats`. `note( )` feeds one request
     (requested / allocated) into the counters: request count, allocated and shortage
     totals (shortage clamped at zero, so an over-delivery never turns negative) and the
     fully / partially covered split; `runs( )` counts the noted requests.
278. **Session context** - `zcl_alloc_session` opens a session context (id, user, client,
     creation date `sy-datum`), `close( )` keeps the data but marks the session closed,
     and `is_open( )` / `context( )` read the state.
279. **User context** - `zcl_alloc_user` defaults an empty user to the constant `c_system`
     (`SYSTEM`), treats `SYSTEM` and `SAP*` as the system user and renders `User <name>`.
280. **Client context** - `zcl_alloc_client` defaults to client `000`, treats `000` and
     `066` as non-productive and renders `Client <n> (productive)` or
     `Client <n> (non-productive)`.
281. **Environment info** - `zcl_alloc_environment=>build( )` assembles a
     system/client/release record and flags it productive when the client is neither
     `000` nor `066`; `describe( )` renders `<sid>/<client> <release> (productive)` or
     `(non-productive)`.
282. **Feature flag registry** - `zcl_alloc_flags` keeps named flags in memory. `set( )`
     adds or overwrites a flag, `is_enabled( )` answers `abap_false` for an unknown flag,
     `enabled_flags( )` returns the enabled subset and `count( )` the number of flags.
283. **Configuration reader** - `zcl_alloc_config` is built from an entry table; `get( )`
     returns a value (empty for an unknown key), `has( )` tests existence, `keys( )`
     lists the keys and `count( )` the number of entries.
284. **Configuration writer (in-memory)** - `zcl_alloc_config_w`. `put( )` adds or
     overwrites a key, `remove( )` deletes it, `entries( )` returns the table and
     `get( )` reads a value. Note: the method is called `remove`, not `delete`, so it
     cannot collide with the ABAP `DELETE` statement.
285. **Configuration validation** - `zcl_alloc_config_val=>validate( )` reports one issue
     per entry with an empty key, an empty value, or a key that already occurred earlier
     in the table (`Key is empty` / `Value is empty` / `Duplicate key`); `is_valid( )` is
     true when no issue was found.
286. **Secret masking** - `zcl_alloc_secret_mask=>mask( )` keeps the first and last
     character and replaces the middle with `*` (`SECRET` -> `S****T`); one- and
     two-character secrets become all `*` and an empty secret stays empty. `is_masked( )`
     reports whether a text contains an asterisk and `mask_all( )` masks a list of
     secrets.
287. **Data masking** - `zcl_alloc_mask`. `mask_text( )` masks everything between a kept
     prefix and suffix, returning the text unchanged when both ends already cover it;
     `mask_email( )` keeps the first local-part character
     (`john.doe@example.com` -> `j*******@example.com`, falling back to prefix masking
     without an `@`); and `mask_last_digits( )` masks all but the last n characters.
288. **Pseudonymization helper** - `zcl_alloc_pseudo` derives the deterministic token
     `PSN-<checksum>` from value and salt (the salt contributes its characters as well as
     its position, so a different salt yields a different token), remembers the mapping
     and can `resolve( )` a token back to its value. `is_pseudonym( )` checks the `PSN-`
     prefix and `count( )` the number of mappings.
289. **Archive metadata** - `zcl_alloc_archive_meta=>build( )` assembles the archive
     record (object, run id, item count, `sy-datum`) and clamps a negative item count to
     zero; `is_complete( )` requires an object, a run id and at least one item, and
     `describe( )` renders `OBJECT/RUN: <n> items`.
290. **Archive index** - `zcl_alloc_archive_idx` keeps one entry per archived run:
     `add( )` appends only when the run id is not indexed yet (an existing entry keeps
     its original date), and `contains( )`, `count( )` and `entries( )` read it back.
291. **Retention policy** - `zcl_alloc_retention` holds a retention period in days
     (constructor, default 365, a negative period is clamped to 0). `is_expired( )`
     compares the age of the archived date against the period and `days_left( )` counts
     down to it (0 once expired). Note: the age is computed through an integer
     day-number conversion (Julian day) because the transpiler does not reproduce `d`
     date arithmetic (ANOMALIES.md A20).
292. **Deletion policy** - `zcl_alloc_deletion=>propose( )` takes archive candidates
     (run id + archived date) plus a request (retention, reference date, protected run)
     and returns the run ids that may be deleted: non-empty, not the protected run, and
     expired according to `zcl_alloc_retention`. Note: the call into the retention
     object uses named parameters because two positional parameters do not parse
     (ANOMALIES.md A19).
293. **Tenant isolation helper** - `zcl_alloc_tenant` holds a tenant (empty input falls
     back to `DEFAULT`). `belongs_to( )` compares a tenant, `is_default( )` tests for the
     default tenant, and `qualify( )` builds a tenant-scoped key `<tenant>::<key>` with a
     string template (so the padding of the character field is trimmed).
294. **Multi-client guard** - `zcl_alloc_mandt_guard` is constructed with the current and
     the allowed client; `is_current_allowed( )` compares them, `check( )` tests any
     client and `describe( )` renders `Client <n>, allowed <n>`.
295. **Authorization check stub** - `zcl_alloc_auth` is built from a grant table
     (object + activity). `is_authorized( )` matches object and activity, where an
     activity of `*` on a grant authorizes any activity of that object; `count( )`
     reports the number of grants.
296. **Role mapping** - `zcl_alloc_role_map`. `grant( )` adds a user/role assignment once
     (a duplicate is ignored), `has_role( )` tests one assignment, `roles_of( )` lists the
     roles of a user and `count( )` the number of assignments. Note: the method is called
     `grant`, not `assign`, so it cannot collide with the ABAP `ASSIGN` statement.
297. **Permission matrix** - `zcl_alloc_permission` keeps role/activity cells. `set( )`
     adds or overwrites a cell, `allows( )` reads it (an unknown cell denies) and
     `allowed_count( )` counts the granted cells.
298. **Field-level authorization** - `zcl_alloc_field_auth` is constructed with hidden
     fields. `is_visible( )` denies a hidden field and allows anything else, `hide( )`
     adds a field once and `visible_count( )` counts the fields of a list that are not
     hidden.
299. **Data access log** - `zcl_alloc_access_log` numbers read/write accesses (user,
     object, action) and reports the total `count( )`, `count_of_user( )` and the full
     `entries( )` table.
300. **Export audit log** - `zcl_alloc_export_audit` numbers export records (format,
     user, object, row count) and aggregates them through `total_rows( )` and
     `format_count( )`.
301. **CSV import reader** - `zcl_alloc_import_csv=>parse_line( )` splits one line on
     `;`, keeps separators inside double quotes and unescapes a doubled quote
     (`"say ""hi"""` -> `say "hi"`); `count_of( )` returns the number of fields. Note: the
     scan uses a `WHILE` with an explicit index - the skipped escaped quote would
     desynchronise a `DO <len> TIMES` counter and read past the end of the string.
302. **JSON import reader** - `zcl_alloc_import_json=>parse( )` turns a flat JSON object
     into key/value pairs (outer braces stripped, pairs split on `,`, key and value split
     on `:`, quotes and blanks trimmed); `count_of( )` counts the pairs. Note: a literal
     that holds only blanks is trimmed to an empty string by the transpiler
     (ANOMALIES.md A18), so the blank used for trimming comes from a backtick literal.
303. **Import validator** - `zcl_alloc_import_val=>validate( )` reports an `Empty value`
     issue (with the row number) for every imported row without a value and a
     `Missing field` issue (row number 0) for every required key that does not occur;
     `is_valid( )` is true when there is no issue.
304. **Import mapper** - `zcl_alloc_import_map=>map( )` turns a mapping table (source
     key, target key, default) into the target key/value list, taking the source value
     when it is present and non-empty and the default otherwise.
305. **Bulk loader** - `zcl_alloc_bulk_load` stages ids (a duplicate is ignored) and
     `commit( )` moves the staged ids into the loaded set, reports how many were loaded
     and clears the staging area; `is_loaded( )` and `loaded_count( )` read the result.
306. **Bulk validity check** - `zcl_alloc_bulk_check=>check( )` reports `Empty id`,
     `Id too short` (fewer than 3 characters) and `Duplicate id` (same id as an earlier
     row) together with the offending row number; `is_loadable( )` is true without any
     issue.
307. **Delta loader** - `zcl_alloc_delta_load=>compare( )` classifies incoming ids
     against the existing ones: new ids as `added`, ids in both lists as `kept` and
     existing ids missing from the incoming list as `removed`.
308. **Upsert helper (in-memory)** - `zcl_alloc_upsert=>upsert( )` inserts unknown keys
     and overwrites the value of known ones, reporting the inserted and updated counts;
     `entries( )` and `count( )` read the merged table.
309. **Dedupe key builder** - `zcl_alloc_dedupe_key` joins the non-empty parts of a list
     with `|` (`build`), splits a key back into its parts (`parts_of`, an empty key yields
     no parts) and counts them (`count_of`).
310. **Natural key builder** - `zcl_alloc_natural_key` composes a position-addressable
     key: every field is padded to 20 characters and concatenated, so `field_count( )` is
     `strlen / 20` and `field_at( )` extracts the nth field (padding trimmed, an
     out-of-range index returns an empty string). Note: `field_at` clamps the substring
     length to the remaining text so a partial key cannot read past the end.
311. **Surrogate key map** - `zcl_alloc_surrogate` maps a natural key to a generated
     surrogate id (`SID-<n>`): `get_or_create( )` creates it once and returns the same id
     afterwards, `lookup( )` only reads and `count( )` reports the mappings.
312. **Reference data cache** - `zcl_alloc_ref_cache` stores key/value pairs in memory:
     `put( )` inserts or overwrites, `get( )` / `has( )` read, `reset( )` empties the cache
     and `count( )` reports the entries. Note: the method is `reset`, not `clear`, so it
     cannot collide with the ABAP `CLEAR` statement.
313. **Cache invalidation policy** - `zcl_alloc_cache_policy` holds a maximum age in
     seconds and a maximum number of items (constructor, defaults 60 / 100) and answers
     `is_stale( )` / `is_full( )` at the limit; `describe( )` renders both limits.
314. **Cache statistics** - `zcl_alloc_cache_stats` counts hits and misses
     (`note_hit`, `note_miss`), reports them and derives `hit_rate( )` as an integer
     percentage (0 while nothing was accessed).
315. **Cache warm-up helper** - `zcl_alloc_cache_warm=>missing( )` returns the wanted
     keys that are not cached yet and `cached_count( )` counts the wanted keys that are.
316. **Lazy loader** - `zcl_alloc_lazy` loads a value at most once: `load( )` sets the
     value only while nothing is loaded and always returns the effective value, `get( )`
     reads it, `is_loaded( )` reports the state and `reset( )` allows a new load.
317. **Pagination cursor** - `zcl_alloc_cursor` walks a total in pages: `open( )`
     normalises the page size (a size below 1 means one page), `next( )` advances the
     offset and clamps it at the total, `is_last( )` reports whether the current page is
     the final one and `remaining( )` counts the not yet consumed rows.
318. **Chunked read over a result** - `zcl_alloc_chunk_read=>read( )` returns chunk
     number `iv_index` (1-based) of a result list; a size below 1 returns everything and
     an index below 1 or past the end returns an empty table.
319. **Chunked write into batches** - `zcl_alloc_chunk_write=>write( )` splits a result
     list into numbered `ty_chunk` rows, each carrying its own line table. A size below 1
     produces one chunk holding everything and an empty list produces no chunk at all.
320. **Backpressure decision** - `zcl_alloc_backpressure=>assess( )` turns a queue depth
     and a capacity into an `accept` / `throttle` / `reject` decision. Below 80 % load it
     accepts, up to capacity it throttles by one tick, above capacity it throttles for
     the time needed to drain the excess, and over capacity without any drain it rejects.
321. **Batch size tuner** - `zcl_alloc_batch_tune=>tune( )` derives a batch size from
     the throughput (`rows_per_second * target_seconds`), applies an optional minimum and
     maximum, never exceeds the total row count, and returns the resulting batch count.
322. **Concurrency guard** - `zcl_alloc_concurrency` limits how many keys may be held at
     the same time. `acquire( )` is idempotent for a key that is already held, refuses a
     new key once the limit is reached and treats a limit below 1 as unlimited;
     `release( )`, `active_count( )` and `is_saturated( )` complete the API.
323. **Idempotency key** - `zcl_alloc_idem_key=>build( )` renders
     `<scope>#<part count>#<fingerprint>`, where the fingerprint is the position-weighted
     length sum of the non-empty parts. `is_valid( )` checks the shape and `scope_of( )`
     returns the scope in front of the first `#`.
324. **Exactly-once guard** - `zcl_alloc_once` remembers the keys it has seen. `run( )`
     returns `abap_true` only the first time a key is passed and `abap_false` afterwards;
     `has_run( )`, `count( )` and `reset( )` complete the API.
325. **Dedupe window** - `zcl_alloc_dedupe_win=>is_duplicate( )` treats a repeated key as
     a duplicate while the stamp difference is inside the window, otherwise it refreshes
     the stored stamp. `purge_before( )` drops entries older than a cutoff.
326. **Sequential numbering** - `zcl_alloc_seq_num` hands out consecutive numbers from a
     start value: `next( )` returns the current value and advances, `current( )` peeks and
     `reset( )` returns to the start.
327. **Gap detection** - `zcl_alloc_gap_check=>find( )` sorts a number list and returns
     one `ty_gap` row per jump greater than 1, carrying the two neighbours and how many
     numbers are missing between them.
328. **Sequence validation** - `zcl_alloc_seq_check=>check( )` reports whether a number
     list is strictly ascending, whether it contains duplicates (detected on the sorted
     copy, so non-adjacent repeats count too) and how many gaps it has.
329. **Checksum registry** - `zcl_alloc_checksum_reg` stores one checksum per key.
     `register( )` replaces an existing entry, `verify( )` only matches a registered key
     with the same checksum and `checksum_of( )` reads the stored value.
330. **Integrity check** - `zcl_alloc_integrity=>check( )` recomputes the result checksum
     with `zcl_alloc_checksum` and compares it with the expected value, returning both
     values, the line count and an `is_intact` flag.
331. **Reconciliation report** - `zcl_alloc_reconcile=>compare( )` matches two keyed
     quantity lists and labels every key `matched`, `differs`, `missing` (left only) or
     `extra` (right only), with the signed delta. `is_balanced( )` is true when every line
     is `matched`.
332. **Drift detection** - `zcl_alloc_drift=>detect( )` compares a current with a baseline
     value and returns the signed delta, the absolute percentage change, the direction
     (`up` / `down` / `flat`) and whether the move exceeds the tolerance. A zero baseline
     reports 100 % for any non-zero move.
333. **Heavy snapshot comparison** - `zcl_alloc_snap_heavy` returns the full union of the
     before and after snapshots (unlike `zcl_alloc_snapshot`, which only reports the
     changes), each line carrying previous, current, delta and a `changed` flag.
334. **Restore helper** - `zcl_alloc_restore=>plan( )` turns a target snapshot and a
     current result into the actions needed to get there: `create` for a new key,
     `update` when the quantity differs, `delete` for a key that is no longer wanted.
     Unchanged keys produce no action.
335. **Migration mapper** - `zcl_alloc_migration_map=>map( )` renames record fields
     according to a mapping table and leaves unmapped fields untouched; `is_mapped( )`
     checks a single field name.
336. **Migration validator** - `zcl_alloc_migration_val=>validate( )` reports `missing`
     for a required field that has no row and `empty` for a field whose value is blank,
     with the 1-based row index. `is_valid( )` is true when there are no issues.
337. **Cutover checklist** - `zcl_alloc_cutover=>build( )` counts the done and open steps
     of a cutover list, derives the truncated progress percentage and reports `ready` when
     nothing is open. `open_steps( )` returns the outstanding steps.
338. **Parallel run comparison** - `zcl_alloc_parallel_run=>compare( )` puts the union of
     an old and a new result side by side with the signed delta and marks each line
     `within_tol`. `mismatch_count( )` counts the lines outside the tolerance.
339. **Data volume estimator** - `zcl_alloc_volume=>estimate( )` multiplies rows, fields
     and bytes per field into a total (with KB and MB), and derives how many records fit
     into a package of the requested size, capped at the row count.
340. **Load test helper** - `zcl_alloc_load_test=>plan( )` multiplies virtual users,
     iterations and rows per iteration into the operation and row totals and turns the
     per-row milliseconds into an estimated duration.
341. **Smoke test runner** - `zcl_alloc_smoke` collects named checks; re-adding a name
     replaces it, `run( )` returns the pass/fail summary with an `ok` flag and `failed( )`
     lists the failures with their detail.
342. **Health check** - `zcl_alloc_health=>check( )` aggregates indicator states into a
     status of `up`, `degraded`, `down` or `unknown` (no indicators) plus the counts;
     `unhealthy_names( )` lists the failing indicator names.
343. **Readiness probe** - `zcl_alloc_readiness=>probe( )` reuses the health check and
     decides readiness either strictly (every check must pass) or leniently (at least one
     must pass), returning the reason and both counts.

**Roadmap batch 3 is complete: orders 244-343 (100 features) are delivered and
verified.** Order 143 (ALV grid binding and selection screen) is still the only
unbuilt item and stays that way because the transpiler cannot exercise it.

344. **Objective function evaluation** - `zcl_alloc_objective=>score( )` sums the
     quantities and the quantity-weighted costs of a result list and combines them
     into `quantity_weight * total_quantity - cost_weight * total_cost`, so a
     caller can score an allocation for a gain/cost trade-off.
345. **Greedy allocation solver** - `zcl_alloc_greedy=>solve( )` sorts the demands
     by priority and hands out the available stock first-come-first-served,
     reporting the allocation and the shortage per demand. A negative stock counts
     as zero and `total_shortage( )` sums the shortfalls.
346. **Cheapest source solver** - `zcl_alloc_cheapest=>solve( )` sorts the sources
     by unit cost and draws from them until the requested quantity is covered,
     returning the picks, the covered quantity, the shortfall and the total cost.
     Sources without stock are skipped.
347. **Knapsack allocation** - `zcl_alloc_knapsack=>solve( )` is an exact 0/1
     knapsack: it fills a capacity/weight table bottom-up and reconstructs the
     chosen items, returning them in input order with their total weight and
     value. Items heavier than the capacity are never taken, a weight of zero is
     free value and a negative weight is ignored (it has no physical meaning).
348. **Bin packing for pallets** - `zcl_alloc_bin_pack=>pack( )` is first-fit
     decreasing: the items are sorted by size descending and put into the first
     bin with room, opening a new numbered bin when none fits. Items larger than
     the bin capacity are skipped and reported by `oversized( )`.
349. **Transportation problem** - `zcl_alloc_transport=>solve( )` ships from supply
     nodes to demand nodes over cost-sorted lanes, never exceeding the supply or
     the demand of a node, and reports the shipments, the total cost and the
     quantity that could not be shipped.
350. **Assignment problem** - `zcl_alloc_assignment=>solve( )` assigns each demand
     to the cheapest still free source: the cost pairs are sorted ascending and a
     pair is taken when neither its demand nor its source is used yet. Demands
     without a free pair are returned with `assigned` false.
351. **Constraint set evaluation** - `zcl_alloc_constraint=>evaluate( )` counts the
     satisfied and violated constraints and treats a violated mandatory constraint
     as infeasible; `violated_ids( )` lists the violated mandatory constraint ids.
352. **Penalty calculator** - `zcl_alloc_penalty=>calculate( )` turns deviations
     into `|amount| * weight`, caps every single penalty and tracks the worst one.
353. **Feasibility check** - `zcl_alloc_feasible=>check( )` decides whether a
     demand can be ordered: no demand, insufficient supply, a demand below the
     minimum order quantity and an order above the supply each return a reason; a
     lot size rounds the order up and a maximum order size splits it into orders.
354. **Local search improvement** - `zcl_alloc_local_search=>improve( )` builds a
     conflict-free assignment by giving every slot, in order of appearance, its
     cheapest still unused option, and then improves it with pairwise swaps while
     the total cost drops. `steps` counts the swap passes, `swaps` the accepted
     exchanges.
355. **Swap optimisation** - `zcl_alloc_swap_opt=>improve( )` is a 2-opt for an
     ordered node list: it reverses every segment and keeps the order when the sum
     of the consecutive arc costs drops, repeating until no reversal helps (capped
     at 20 passes). An arc that is missing from the table counts as zero cost.
356. **Hill climbing** - `zcl_alloc_hill_climb=>climb( )` walks a scored point
     table from a start value, always stepping to the better scored of the two
     neighbours at `start +/- step`, and stops when neither is better or the step
     budget is used up.
357. **Simulated annealing (deterministic)** - `zcl_alloc_annealing=>anneal( )` is
     threshold accepting instead of random: a worse neighbour is accepted while its
     loss is within the current temperature, which cools by the given percentage
     each step. `accepted_worse` counts the uphill moves and `best_value` /
     `final_value` separate the best result from the place it stopped.
358. **Improvement tracker** - `zcl_alloc_improve_log` numbers the recorded
     improvement steps, and reports the highest scored entry (`best`), the initial
     one (`first`) and the difference between them (`gain`).

**Batch 7 (applying the scale-safe aggregation) is in progress: order 452 is
delivered and `zcl_alloc_network` is converted; batch 6 and everything before it
remain complete.**

452. **Scale-safe string keyed aggregation** - `zcl_alloc_key_agg_str` is the
     character-keyed companion to `zcl_alloc_key_agg` for the keys the affected
     classes actually use (material numbers, work centres, node ids). `add( )`
     appends one row, `sums( )` sorts by key once and merges in a single forward
     pass, and `find( )` looks a key up by binary search. Two properties make it a
     drop-in replacement rather than a behaviour change: it preserves the order in
     which keys were **first seen** (each raw row carries a sequence number, so the
     merged table is sorted back into first-appearance order), and a later `add( )`
     invalidates the cached result, so the accumulator is never frozen by a read.

**Conversion 1 of 15: `zcl_alloc_network` (fix, not a new order).** The degree
counting used `bump( )`, which read, deleted and appended the count table once per
lane, so it was quadratic in the number of lanes. It now collects the lane
endpoints with `zcl_alloc_key_agg_str` and reads them back with `find( )`, and the
count table and `bump( )` are gone. This is a purely internal change: the existing
network tests (degree counts, isolated nodes, unknown nodes being ignored, node
order) are the regression check and they pass unchanged.

What is *not* proven by a test here: the network test class cannot demonstrate the
complexity change itself, because generating many distinct node ids would need a
number-to-string conversion, which is unreliable in this transpiler (A31). The
linearity of the aggregation is proven in `zcl_alloc_key_agg_str`'s own test, which
doubles 1000 rows and asserts with `zcl_alloc_scale_guard` that the work does not
more than double; the conversion's evidence is that plus behaviour preservation.


450. **Scale-safe keyed aggregation** - `zcl_alloc_key_agg` collects rows with a
     single `add( )` append, then `sums( )` sorts once and merges equal keys in one
     forward pass, so grouping n rows costs O(n log n) instead of the O(n^2) of the
     read/delete/append pattern used elsewhere. It carries a running `visits( )`
     counter so the work can be asserted, and `find( )` looks a key up by binary
     search (eleven comparisons at most for 1024 keys). No microsecond clock exists
     here (`sy-uzeit` counts seconds), so counting work elements is the only
     deterministic way to check complexity.
451. **Growth classifier** - `zcl_alloc_scale_guard=>classify( )` compares two
     measurements (input size and work) and answers `linear`, `near_linear`,
     `quadratic` or `unknown`: work that grows no faster than the input is linear,
     up to twice the input growth is near linear, and anything beyond that is the
     quadratic signature. `ratio_x100( )` gives the percentage growth of one value.
     The test for 450 uses it to assert that doubling 1000 aggregation rows does not
     more than double the work, which is a property test rather than an example.

**Finding from batch 6, and the next batch it implies.** The read/delete/append
aggregation pattern (read the row, change it, delete it, append it) scans the whole
table once per input row, so it is quadratic in the number of rows. It appears in
about fifteen classes: `mrp`, `network`, `crp`, `workload`, `crossdock`, `sourcing`,
`transport`, `local_search`, `toc`, `rollout`, `checksum_reg`, `concurrency`,
`config_w`, `dedupe_win` and `path`. Batch 6 deliberately built only the tools and
the proof; applying them is a refactoring batch over existing behaviour and needs a
string-keyed variant of `zcl_alloc_key_agg`, because material numbers, work centres
and node ids are character keys.


Batch 5 exists because the per-class unit tests cannot catch a cross-cutting
failure: a run that looks plausible but breaks an invariant the business depends
on. Each checker below is a small class so it can be tested on its own and reused
wherever a run result or a stock movement set is produced.

444. **Allocation invariant check** - `zcl_alloc_invariant_check=>check( )` tests a
     run result against five rules and returns one row per rule with a `detail`
     text: `no_negative` (no line allocated below zero), `not_over_requested`,
     `shortage_consistent` (the reported shortage equals requested minus allocated),
     `trace_present` (the allocation details sum to the allocated quantity) and
     `within_available` (the allocated total does not exceed the stock the caller
     passes in; a zero stock figure means the rule passes by definition).
     `is_clean( )` is true when every rule passed.
445. **Run audit summary** - `zcl_alloc_run_audit=>audit( )` derives the line count,
     the requested and allocated totals and the shortage from the quantities rather
     than reading the reported shortage field, so it is an independent check of the
     run, and reports over-allocation, negative quantities, the deferred count and a
     `full` flag. An over-allocated run can still be `full` (nothing short) and an
     empty run is never `full`, so the flags stay independent of each other.
446. **Stock movement guard** - `zcl_alloc_stock_guard=>check( )` applies the
     movements to the opening stock of each storage location (`closing_of( )`) and
     reports the locations that would end below zero, with the closing quantity;
     a location that closes at exactly zero is fine. `first_negative( )` returns the
     first offending location, which is what a posting check needs.
447. **Regression baseline** - `zcl_alloc_regression_baseline=>capture( )` records a
     signature of a run as one row per requirement (id and allocated quantity) and
     `compare( )` diffs two signatures into `added`, `removed` and `changed` rows
     with the quantity before and after; `is_unchanged( )` is the yes/no answer a
     regression check needs. Comparing an empty baseline reports everything as
     added and comparing an empty run reports everything as removed.
448. **Scenario matrix** - `zcl_alloc_scenario_matrix=>build( )` scales the base
     demand and the base stock by a percentage per scenario (100 leaves a value
     unchanged, a negative scale floors at zero) and reports the requested,
     available, allocated and shortage quantities plus the fill rate. The matrix is
     the comparison table that makes several what-if settings readable side by side.
449. **End-to-end scenario gate** - `zcl_alloc_e2e_scenario=>run( )` composes the
     three checkers into one verdict: the audit totals, the number of failed
     invariants, the stock alerts and a `posting_ok` flag, with `reason` naming the
     first broken rule (or `stock would go negative`, or `ok`). It is the dry run to
     put in front of a posting.
     Note on scope: the order was planned as "load a scenario into the stub tables
     and run the full service flow". That was **not** built, because a production
     class must not insert test data into MARD/RESB and no stock reader exists that
     takes local data instead (all three read tables, and the stub-table loading
     helpers live in the service test class). The gate takes an already produced
     result plus its stock context, so it is database free and reusable in
     production; a real stub-table end-to-end run stays where it belongs, in the
     service test class.

441. **Release note builder** - `zcl_alloc_release_notes=>build( )` turns version
     entries into numbered notes, skipping entries without text because they carry
     nothing for the reader. `count_of( )` counts the notes of one kind (`feature`,
     `fix`, `change`) and `titles_of( )` lists the distinct versions in the order
     they first appear, without duplicates.
442. **Change request tracker** - `zcl_alloc_change_request=>build( )` orders the
     requests by priority (a lower number is more urgent, ties broken by the id) and
     reports the rank, the status, the owner and an `is_open` flag: everything that
     is not explicitly `closed` still needs work, so an unknown status counts as
     open. `open_count( )` totals the open requests.
443. **Roll-out wave planner** - `zcl_alloc_rollout=>plan( )` sorts the sites by
     region and then by size descending and packs them into waves that never mix
     regions and respect the user cap; a site larger than the cap still gets its own
     wave so no site is dropped. A cap that is not positive means one wave per
     region. `wave_count( )` returns the number of waves.

433. **Column width fitting** - `zcl_alloc_colwidth=>fit( )` sizes each column from
     the longer of its title and its widest cell value, caps the result at a given
     maximum and never goes below one character.
434. **Excel-friendly CSV** - `zcl_alloc_csv_excel=>render( )` writes the `sep=;`
     hint line that spreadsheets look for and then renders the data with a semicolon
     separator through `zcl_alloc_csv_export`, so the quoting rules stay in one
     place. `separator( )` and `hint( )` expose the two conventions.
435. **Tab-separated codec** - `zcl_alloc_tsv` is the low-level counterpart to the
     TSV renderer: `join( )` puts cells on one line separated by the tab from
     `cl_abap_char_utilities`, `split( )` takes a line apart again (an empty line has
     no cells) and `cell_count( )` counts them. Join followed by split is lossless
     for cells that contain no tab.
436. **SQL literal escaping** - `zcl_alloc_sql_escape=>escape( )` doubles every single
     quote, `literal( )` additionally wraps the text in quotes and `needs_escape( )`
     answers the question without touching the text, which is what a dynamic
     `WHERE` clause needs before it is passed to a generated SELECT.
437. **URL query builder** - `zcl_alloc_query=>build( )` joins `name=value` pairs with
     an ampersand and percent-encodes both parts; `encode( )` covers the space, the
     ampersand, the equals sign, the question mark, the hash, the plus and the
     percent sign, and passes everything else through.
438. **Deep-link builder** - `zcl_alloc_deeplink=>build( )` appends the query from
     `zcl_alloc_query` to a base path only when there is at least one parameter;
     `is_absolute( )` reports whether a link starts with the http scheme.
439. **Report signature block** - `zcl_alloc_signature=>build( )` collects the
     signature lines from the user and the system/client that are actually filled
     and passes the run date and time through for the caller to format.
440. **Print pagination** - `zcl_alloc_print_page` reserves the header and footer
     lines from the page size: `capacity_of( )` is the number of data lines per page
     (at least one, so a furniture block larger than the page cannot loop forever)
     and `paginate( )` returns one row per page with the line range. Without a page
     size the whole list goes on a single page.

425. **Report footer with totals** - `zcl_alloc_footer=>build( )` sums the allocated
     quantities of a result list, counts the lines and carries the requested
     caption, so a report can end with a totals block. Negative allocations net
     against the total.
426. **Conditional highlighting rules** - `zcl_alloc_highlight=>apply( )` fires every
     rule whose threshold the value reaches; `worst_severity( )` ranks the hits and
     returns `error`, `warning`, `info` or an empty string when nothing fired.
427. **Traffic-light status** - `zcl_alloc_trafficlight=>of_value( )` returns 1, 2 or
     3 for a value inside the green band, between the two limits or above both
     (the limits themselves count as inside), and `text_of( )` names the light
     `green`, `yellow`, `red` or `unknown`.
428. **Unit-aware display** - `zcl_alloc_unit_display=>format( )` turns a requested
     number of decimals (0 to 3) into a scale factor and returns the quantity as an
     exact whole number of scaled units, so the caller can render it with its unit
     and without floating point arithmetic.
429. **Text wrapping** - `zcl_alloc_text_wrap=>wrap( )` fills lines up to the given
     width, breaking between words and only moving a word to the next line when it
     plus the separating blank would not fit. Repeated blanks collapse and a single
     word longer than the width keeps its own line.
430. **Text truncation with ellipsis** - `zcl_alloc_text_trunc=>truncate( )` keeps a
     text that fits and otherwise cuts it so that the marker still fits inside the
     width. When the width cannot hold the whole marker, as much of the marker as
     fits is returned. `fits( )` answers the same question without cutting.
431. **CSV export** - `zcl_alloc_csv_export=>render( )` writes a header line from the
     column titles and one line per row, taking the values by field name so a
     missing value becomes an empty cell; the separator is a parameter.
     `escape( )` quotes only the values that contain a quote and doubles the inner
     quotes, which is the RFC 4180 convention.
432. **TSV export** - `zcl_alloc_tsv_export` uses the tab from
     `cl_abap_char_utilities` as the separator (`separator( )`) and, because TSV has
     no quoting convention, `clean( )` replaces a tab inside a value with a blank
     and a double quote with an apostrophe so a value can never break the structure.

421. **Row numbering for reports** - `zcl_alloc_row_number=>apply( )` turns an
     allocation result into display rows with a 1-based row number, the requirement
     id and the allocated quantity, keeping the input order; `count_of( )` returns
     the number of rows.
422. **Column definition builder** - `zcl_alloc_columns=>build( )` turns a column
     list into positioned definitions: the position is sequential, a width of zero or
     less falls back to 10 and is capped at 255, and a numeric column is marked right
     aligned while a text column stays left aligned. `total_width( )` sums the widths.
423. **Table of contents for a report** - `zcl_alloc_toc=>build( )` numbers up to
     three chapter levels with per-level counters, so a new level 1 chapter resets its
     children (`1`, `1.1`, `2`, `2.1`) and reports an indent per level. A level below
     1 counts as 1 and one above 3 as 3.
424. **Report header block** - `zcl_alloc_header=>build( )` collects the non-empty
     header lines (title, subtitle and a `User:` line), passes the run date through
     and builds a rule of dashes of the requested width, clamped to 200 characters.

413. **Percentile calculation** - `zcl_alloc_percentile=>value( )` sorts the series
     and returns the nearest-rank percentile: the rank is the smallest one whose
     cumulative share reaches the requested percentage
     (`(pct * n + 99) DIV 100`), clamped to the valid range. `rank_of( )` exposes
     the rank. A percentage below 0 or above 100 is clamped.
414. **Median and quartiles** - `zcl_alloc_quartile=>calculate( )` reports the
     minimum, the first quartile, the median, the third quartile and the maximum
     using the same nearest-rank rule as `zcl_alloc_percentile`, plus the
     interquartile range.
415. **Standard deviation** - `zcl_alloc_stddev=>calculate( )` returns the count,
     the truncated mean, the variance in hundredths and the standard deviation in
     hundredths. The deviation uses an integer square root, so a series without
     spread reports exactly zero.
416. **Coefficient of variation** - `zcl_alloc_cv=>calculate( )` divides the
     standard deviation by the mean - both taken from `zcl_alloc_stddev` - and
     scales the result to ten-thousandths; `band_of( )` maps it to `low`,
     `moderate` or `high` at 0.10 and 0.25. A non-positive mean or spread reports 0.
417. **Moving range control chart** - `zcl_alloc_control_chart=>build( )` is the
     XmR chart: the centre line is the mean and the limits are 2.660 average moving
     ranges away from it (3.267 for the moving range chart itself).
     `out_of_control( )` lists the points outside the limits with their rank and
     which side they are on.
418. **Benchmark comparison** - `zcl_alloc_benchmark=>compare( )` places a measured
     value against a benchmark series (best, median, average) for a lower-is-better
     KPI: `behind` is the distance from the best value and `ahead` is true when the
     measured value beats the average.
419. **Scorecard builder** - `zcl_alloc_scorecard=>build( )` turns metrics with a
     target, an actual value and a weight into rows that carry the signed gap and a
     `met` flag (reaching the target exactly counts as met); `met_count( )` counts
     the met metrics.
420. **Weighted score model** - `zcl_alloc_weighted_score=>score( )` sums the
     weights of the met metrics against the total weight and expresses the result in
     ten-thousandths, with `grade_of( )` mapping 0.90, 0.75 and 0.60 to the grades
     `A`, `B`, `C` and `D`. Metrics without a positive weight are ignored, and a
     scorecard without weight reports grade `D`.

405. **KPI trend over runs** - `zcl_alloc_kpi_trend=>analyze( )` summarises a KPI
     series: first value, last value, signed delta, the direction `up`, `down`,
     `flat` or `empty`, the minimum, the maximum, the truncated average and the
     number of points.
406. **Pareto analysis** - `zcl_alloc_pareto=>build( )` sorts the items by quantity
     descending and reports the rank, the share in percent and the running
     cumulative share. An item is still `vital` while the cumulative share *before*
     it is below 80 %, so the item that crosses the threshold is included;
     `vital_count( )` counts them.
407. **Concentration index (HHI)** - `zcl_alloc_hhi=>calculate( )` sums the squares
     of the integer percentage shares, giving the classic 0..10000 Herfindahl index
     (10000 is a monopoly, 5000 a duopoly); `band_of( )` maps it to `low`,
     `moderate` or `high` at the usual 1500 / 2500 limits.
408. **Gini coefficient** - `zcl_alloc_gini=>calculate( )` sorts the values ascending
     and evaluates `2 * sum(i * x_i) / (n * sum(x_i)) - (n + 1) / n` in
     ten-thousandths, so 0 is perfect equality and 5000 is the maximum for two
     values. A zero total reports 0.
409. **Lorenz curve points** - `zcl_alloc_lorenz=>build( )` returns, per rank, the
     cumulative population share against the cumulative value share in percent;
     `gap_of( )` returns the largest gap between the two, which is 0 for a perfectly
     equal distribution.
410. **Correlation of two series** - `zcl_alloc_correlation=>calculate( )` computes
     r squared exactly in ten-thousandths by cross multiplication, takes the integer
     square root and gives it the sign of the covariance, so a perfectly correlated
     pair reports 10000 and an inversely proportional pair -10000.
411. **Linear regression** - `zcl_alloc_regression=>fit( )` returns the least squares
     slope in thousandths, the intercept, the number of points and a `rising` flag.
     A set of points with no spread in x has no slope and is reported as empty.
412. **Outlier detection (z-score)** - `zcl_alloc_outlier` derives the mean and the
     standard deviation of a series (`sd_of( )` uses the integer square root) and
     `find( )` reports the points whose absolute z-score exceeds the given
     threshold, with the 1-based rank and the score in hundredths. A series without
     spread has no outliers.

393. **Distribution network model** - `zcl_alloc_network=>build( )` returns one row
     per node in the input order with its outgoing and incoming lane count and an
     `isolated` flag. Lanes that mention an unknown node are ignored rather than
     inventing a node, so the result stays aligned with the node list.
394. **Sourcing rule evaluation** - `zcl_alloc_sourcing=>evaluate( )` groups the
     rules by material and plant and picks one source per group: the lowest priority
     number wins, and a quota percentage breaks a tie. `shares` counts how many
     sources were offered for the group.
395. **Lane cost matrix** - `zcl_alloc_lane=>build( )` turns lanes into cells with
     `distance * cost_per_km` and drops lanes without a distance or a rate;
     `cost_of( )` looks a pair up (zero when absent) and `cheapest_lane( )` returns
     the cheapest cell.
396. **Shortest path over lanes** - `zcl_alloc_path=>shortest( )` is a Dijkstra over
     the lane distance, returning whether the target is reachable, the total
     distance, the number of hops and the ordered node list. Nodes are collected
     from the lanes plus both endpoints, so a start or target without a lane is
     still handled.
397. **Multi-stop route builder** - `zcl_alloc_route=>build( )` sequences the stops by
     their sequence number and sums the lane distance between consecutive stops,
     counting the legs. A missing lane contributes nothing.
398. **Route cost estimate** - `zcl_alloc_route_cost=>estimate( )` separates the
     distance cost (`distance * cost_per_km`) from the stop cost
     (`stops * fixed_per_stop`) and returns both plus the total. Negative distances
     count as zero.
399. **Milk-run grouping** - `zcl_alloc_milk_run=>group( )` is a first-fit-decreasing
     tour builder: the stops are sorted by demand descending and each one joins the
     first tour with room, otherwise a new numbered tour is opened. Stops larger
     than the capacity are skipped and listed by `unassigned( )`.
400. **Cross-dock proposal** - `zcl_alloc_crossdock=>propose( )` matches inbound
     loads to outbound demands in order, taking only goods that are already
     unloaded (`arrival <= departure`) and reporting the waiting time per move.
     `shortfall_of( )` returns the demand that could not be covered.
401. **Safety stock by service level** - `zcl_alloc_safety_level=>calculate( )`
     multiplies the service factor (`z * 100`, so 165 is 95 %) with the demand
     deviation and the square root of the lead time. `sqrt_of( )` is an integer
     square root so no floating point is involved.
402. **Reorder point with variability** - `zcl_alloc_rop_var=>calculate( )` adds the
     cycle stock (`average demand * lead time`) to the safety stock from
     `zcl_alloc_safety_level` and returns all three parts.
403. **Fill rate simulation** - `zcl_alloc_fill_sim=>simulate( )` serves at most what
     is in stock per period, counts the stockout periods and returns the served
     quantity against the total demand as a truncated percentage.
404. **Inventory policy comparison** - `zcl_alloc_policy_cmp=>compare( )` runs the
     fill rate simulation for every policy on the same demand series and marks the
     policy with the highest fill rate (`best`); an earlier policy wins a tie.

385. **Scheduling: earliest due date** - `zcl_alloc_sched_edd=>schedule( )` sequences
     the jobs by due day back-to-back from day zero and reports the start, the
     finish, the lateness in days and an `is_late` flag per job; `late_count( )`
     counts the late jobs.
386. **Scheduling: shortest processing time** - `zcl_alloc_sched_spt=>schedule( )`
     does the same but sequences by work time ascending, which keeps the average
     finish day low; `avg_finish( )` returns that average.
387. **Scheduling: critical ratio** - `zcl_alloc_sched_cr=>schedule( )` computes the
     critical ratio `slack * 100 DIV work_time` per job and sequences the smallest
     ratio first, because that is the job with the least slack per unit of work.
388. **Capacity levelling** - `zcl_alloc_levelling=>level( )` runs a forward pass
     over a demand series and defers any excess above the capacity into the next
     period, returning the levelled load per period, the quantity that could not be
     placed inside the horizon (`rest`) and an `overloaded` flag. A capacity of zero
     or less leaves the demand untouched.
389. **Capacity requirement planning** - `zcl_alloc_crp=>calculate( )` aggregates
     `quantity * hours_per_unit` per work centre and counts the orders per centre;
     `total_hours( )` sums the load.
390. **Work centre load** - `zcl_alloc_workload=>build( )` aggregates the operation
     hours per work centre and period and flags a cell as `over` when it exceeds the
     capacity; `overload_count( )` counts the overloaded cells.
391. **Queue estimation** - `zcl_alloc_queue=>estimate( )` works on rates scaled by
     100 and derives the utilisation, the queue length (`rho^2 / (1 - rho)`, also in
     hundredths) and the waiting time via Little's law. An arrival rate at or above
     the capacity is reported as `saturated`.
392. **Rough-cut capacity check** - `zcl_alloc_rough_cut=>check( )` compares the
     required with the available capacity per work centre and reports the gap and an
     `ok` flag per line; `is_feasible( )` is true only when nothing is short and
     `gap_total( )` sums the positive gaps. A work centre without a capacity row
     counts as zero available.

379. **Material requirements planning run** - `zcl_alloc_mrp=>run( )` explodes a
     demand list over a bill of material for a given number of levels: every level
     is exploded from the quantities of the previous level (`parent quantity *
     qty_per`) and all levels are aggregated per material, so the result is the
     total planned quantity per material including the top level demand.
380. **MRP net requirements** - `zcl_alloc_mrp_net=>calculate( )` nets a demand
     against stock plus scheduled receipts minus safety stock (floored at zero) and
     returns the open net requirement plus the quantity that is already covered.
381. **Lot sizing: fixed lot** - `zcl_alloc_lot_fixed` rounds a requirement up to a
     whole multiple of the lot size; `lots_of( )` returns the number of lots. A lot
     size of zero or less leaves the requirement unchanged.
382. **Lot sizing: period lot** - `zcl_alloc_lot_period=>size( )` groups the demand
     of `n` consecutive periods into one lot and reports the period range and the
     summed quantity per lot; a trailing group may be shorter. A period length below
     1 behaves like 1.
383. **Lot sizing: least unit cost** - `zcl_alloc_lot_luc=>size( )` grows a lot from
     the current period while the average cost per unit falls, where the cost is the
     setup cost plus the material cost plus the holding cost of every unit carried
     into later periods. Costs are kept in hundredths of the currency and two
     averages are compared by cross multiplication, so no rounding decides the
     result.
384. **Lot sizing: part period balancing** - `zcl_alloc_lot_ppb=>size( )` accumulates
     periods into a lot while the holding cost of the units carried forward stays
     below the setup cost that is saved, with the same hundredths cost model as the
     least unit cost and an optional maximum number of periods per lot.

374. **Forecast accuracy (MAPE)** - `zcl_alloc_mape=>percentage_of( )` returns the
     absolute percentage error per observation and `calculate( )` their truncated
     mean. Observations with an actual of zero are skipped because the percentage
     is undefined there, so the map is taken over the remaining points only.
375. **Forecast bias** - `zcl_alloc_bias=>errors_of( )` returns the signed errors
     (`forecast - actual`), `calculate( )` their truncated mean and `direction( )`
     classifies it as `over`, `under` or `unbiased`, which is how a systematically
     too high or too low forecast is spotted.
376. **Forecast exception list** - `zcl_alloc_forecast_exc=>find( )` reports the
     observations whose absolute deviation exceeds a percentage threshold, with the
     1-based position, both values and the deviation. Zero actuals are skipped.
377. **Demand classification** - `zcl_alloc_demand_class=>classify( )` computes the
     average inter-demand interval (ADI, scaled by 100) and the squared coefficient
     of variation of the non-zero demands (CV2, scaled by 10000) and derives the
     standard four classes: `smooth`, `intermittent`, `erratic` or `lumpy` (limits
     1.32 and 0.49, matching the usual ADI/CV2 scheme). An empty series is
     `unknown` and an all-zero series is `no demand`.
378. **Intermittent demand (Croston)** - `zcl_alloc_croston=>forecast( )` smooths the
     non-zero demand sizes and the inter-demand intervals separately with the given
     alpha and divides them, which is the usual Croston estimate for sporadic
     demand. The result exposes the smoothed size and interval as well.

364. **Demand uplift scenario** - `zcl_alloc_uplift=>apply( )` scales every
     allocated quantity by a percentage and then adds a fixed amount, clamping the
     outcome at zero; `total_of( )` sums a result list.
365. **Capacity reduction scenario** - `zcl_alloc_capacity_cut=>apply( )` rations a
     result list down to a capacity: when the total exceeds the capacity every line
     is scaled by `quantity * capacity DIV total`, an optional per-line maximum caps
     single lines, and the result reports the totals before and after plus a
     `reduced` flag. Truncation means the rationed total can stay slightly below the
     capacity, which is the safe direction.
366. **Stress test ladder** - `zcl_alloc_stress=>ladder( )` builds a list of levels
     from a start to an end value; `assess( )` turns each level into a threshold
     (`base * level DIV 100`) and marks it as breached when a total exceeds it.
367. **Sensitivity analysis** - `zcl_alloc_sensitivity=>analyze( )` varies the
     available stock by `steps` increments of `step_pct` percent each side of the
     base and reports, per variant, the stock, the allocation (capped by the demand)
     and the quantity delta against the base allocation. Negative stock is clamped at
     zero.
368. **Break-even analysis** - `zcl_alloc_breakeven=>solve( )` divides the fixed
     cost by the contribution margin (`unit_price - unit_cost`), rounding up, and
     reports the units, the margin and whether the break-even is reachable within an
     optional maximum volume. A margin of zero or less is never reachable.
369. **Exponential smoothing** - `zcl_alloc_exp_smooth=>forecast( )` applies
     `alpha * value + (100 - alpha) * previous` (integer percent, clamped to 0..100)
     to a series, returns the smoothed series and uses its last value as the
     forecast. The first smoothed value is the first observation.
370. **Holt linear trend** - `zcl_alloc_holt=>forecast( )` keeps a level and a trend
     per observation, updates them with the alpha and beta percentages and forecasts
     with `level + trend`. The first observation seeds the level and the trend starts
     at zero.
371. **Seasonal index** - `zcl_alloc_seasonal=>index( )` averages the observations
     per season position (`(position - 1) MOD period + 1`) and expresses each average
     as a percentage of the overall average. Positions without observations get an
     index of 0, and a zero overall average is never divided by.
372. **Seasonally adjusted forecast** - `zcl_alloc_season_forecast` deseasonalises
     the last full period with the seasonal index, averages the deseasonalised values
     (an index of 0 leaves a value as it is) and reseasonalises that baseline with the
     index of the season being forecast. `baseline_of( )` exposes the baseline.
373. **Mean absolute deviation** - `zcl_alloc_mad=>deviation_of( )` pairs forecast
     and actual observations (stopping at the shorter series) and returns the absolute
     errors; `calculate( )` returns their truncated mean.

359. **Monte Carlo demand sampler** - `zcl_alloc_monte_carlo=>simulate( )` draws a
     number of demand samples around a mean with a symmetric spread, using a
     seeded generator so a run can be reproduced. Negative draws are clamped at
     zero and the result reports the values, the minimum, the maximum and the
     truncated average.
360. **Seeded random generator** - `zcl_alloc_random` is a small deterministic
     linear congruential generator with a 16 bit modulus (`25173 * state + 13849`),
     chosen so the product cannot overflow a 32 bit integer. `next( )` returns the
     raw value, `between( )` maps it into a range, `reset( )` reseeds a zero seed
     to 1 so a sequence never degenerates, and `state( )` exposes the position.
361. **Scenario definition** - `zcl_alloc_scenario=>define( )` stores an id, a note
     and a list of per-requirement quantity deltas; `apply( )` adds those deltas to
     a result list, clamps the outcome at zero and leaves requirements without a
     delta (and with the same line count) untouched.
362. **Scenario comparison** - `zcl_alloc_scenario_cmp=>compare( )` returns only the
     requirements whose allocated quantity changed, with the base value, the
     scenario value and the signed delta, plus the changed count and the summed
     delta. Requirements only present in one of the two lists are reported too.
363. **What-if stock shock** - `zcl_alloc_shock=>apply( )` reduces every stock row's
     unrestricted quantity by a percentage and then by an absolute amount, applies
     a floor and never goes below zero, keeping all other stock fields.
     `available_of( )` totals the unrestricted quantities.

## Bug fixes

F1. **Sales order requirement date read from a non-existent field** - reported by
    the abapGit syntax check in a real SAP system as
    `Unknown column name "EDATU"`, followed by a cascade of
    `Field "LT_VBAP" is unknown` / `LS_VBAP~... is unknown` errors in
    `zcl_requirement_reader_vbap`. The table `VBAP` has no `EDATU` field; the
    requested delivery date is `VBAK-VDATU`, while `VBEP-EDATU` is the schedule
    line date (one per schedule line). The reader now joins `VBAK` on `VBELN`
    and maps `VDATU` to `requested_date`; the `VBAP` stub lost the invented
    `EDATU` field and a `VBAK` stub (`MANDT`, `VBELN`, `VDATU`) was added.
    `build_id( )` / `to_priority( )` are now typed with local `TYPES` aliases
    instead of `TYPE vbap-...` component references. See ANOMALIES.md A25.

F2. **Test double environment created once per test method** - running the unit
    tests in the real SAP system reported `CX_OSQL_FAILURE` (raised in
    `cl_osql_test_environment->chk_for_multiple_env_instance`) and
    `CX_SY_REF_IS_INITIAL` (at `mo_environment->destroy( )`) for all 19 test
    classes that mock the database. The SQL test double environment must be
    created once per test class, not once per test method. All 19 classes now
    use `CLASS-DATA mo_environment` with `class_setup` (create) and
    `class_teardown` (destroy, guarded with `IS BOUND`), while `setup` only
    calls `clear_doubles( )`. See ANOMALIES.md A26.

Test coverage (1260 ABAP Unit tests, run on Node through the transpiler):

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
  date sorting, delivery priority, sales unit, id construction, item without a
  VBAK header is skipped
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
* Timeout / retry / breaker / limiter: limit reached, remaining clamped, unlimited,
  attempts exhausted, exponential backoff with cap, open-reset-half-open, consume
  and reset
* Audit / operation log / timer / stopwatch / stats: entry numbering, run filter,
  error subset, totals and slowest, accumulate and ignore-after-stop, lap min/max,
  coverage split and shortage clamping
* Contexts: closed session, open/close, default system user, `SAP*`, productive and
  non-productive clients
* Configuration and privacy: environment info and description, feature flags (set,
  overwrite, unknown flag, enabled subset), config reader/writer/validation, secret and
  data masking (prefix/suffix, email, last digits), pseudonym tokens (stability, salt
  sensitivity, resolve, prefix detection)
* Archive lifecycle: metadata build/completeness/description, index add/dedupe/count,
  retention (within, at the limit, days left, zero days) and deletion proposals
  (expired, protected, empty run id)
* Access control and audit: tenant matching and key qualification, client guard, grants
  (exact, wildcard, unknown object/activity), role mapping (dedupe, per-user list),
  permission matrix (overwrite, unknown cell, granted count), hidden fields, access and
  export audit logs (numbering, per-user/-format counts, row totals)
* Import and bulk movement: CSV parsing (plain, quoted separator, escaped quotes, empty
  line), flat JSON objects (spaces, empty object, unquoted number), import validation
  (empty value, missing field), mapping with defaults, bulk load staging/commit/dedupe,
  bulk checks (empty, short, duplicate), delta classification and upsert
* Keys and caching: dedupe key build/split/count, fixed-width natural keys (compose,
  count, nth field, out-of-range), surrogate id creation/reuse/lookup, reference cache
  (put, overwrite, reset), invalidation policy (stale, full, description), statistics
  (hit rate, reset), warm-up (missing keys, cached count) and the lazy loader

## Next candidates

**Roadmap batches 1-3 are complete**: orders 44-142, 144-243 and 244-343 are
delivered and verified. The single unbuilt item across all three batches is 143
(the ALV grid / selection screen), which the transpiler cannot exercise.

Batch 4 (**optimisation, simulation and planning intelligence** - solvers
(objective, greedy, knapsack, bin packing, transport, assignment), constraints and
local search, seeded simulation and scenario analysis, forecasting and demand
classification, MRP and lot sizing, finite scheduling and capacity, distribution
network and routing, KPI / statistics, report presentation helpers, roll-out
governance) is planned in `PLAN.md` for orders 344-443 and is now being built:
orders 344-443 are delivered and verified.

files no longer apply; batches 4, 5 and 6 are complete, and batch 7 is the active
work (converting the fifteen quadratic classes, of which `zcl_alloc_network` is
done). That list is the concrete follow-up; anything beyond it needs a new batch
agreed in `PLAN.md` first, so that scope stays a decision rather than an
improvisation.

Standing instruction from the user: when a 100-item roadmap is done, plan another
100 items in the same style and keep iterating (one feature per iteration,
`npm test` green, documented in `NOTES.md`/`ANOMALIES.md`).

Conventions reminder for the next feature: keep method names <= 30 chars, use the
classic `TYPES: BEGIN OF ... END OF ...` form, declare a `TYPES` alias instead of
`TYPE c LENGTH n` or `TYPE STANDARD TABLE OF ...` in parameters, use one `&&` per
statement, align `TYPE` expressions to one space after the longest name of the
group (`npx abaplint --fix` does it for you), declare `DATA` at the top of the
method instead of inside a control block, never put a semicolon after a block
terminator (`ENDIF;` breaks the parser - the whole class fails with
`structure, Expected ENDMETHOD`), never pass a logical expression directly as an
`act` argument (`assert_equals( act = a = b ... )` is a parser error - compute an
`abap_bool` variable first), write decimal values as quoted literals (`'1.5'`,
never a bare `1.5` - the transpiler drops the whole statement, see ANOMALIES.md
A30), and do not put trailing blanks in test literals (ANOMALIES.md A18).

**Run `grep -nE "(ENDIF|ENDWHILE|ENDLOOP|ENDDO|ENDCLASS|ENDMETHOD);" src/*.abap`
before every `npm test`.** A stray semicolon after a block terminator makes the
transpiler reject the whole class with a message that names the first line of the
file, and abaplint reports nothing at all (ANOMALIES.md A28).

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
* A literal that holds only blanks is trimmed to an empty string by the transpiler
  (ANOMALIES.md A18), so `IF lv_char <> ' '` never matches and a `DO <len> TIMES`
  counter runs out of step with a manually advanced index. Use a backtick literal
  (`` ` ` ``) for a blank and a `WHILE` loop when characters are skipped.
* Functional method calls take named parameters as soon as they have more than one
  argument - two positional arguments do not parse (ANOMALIES.md A19). In a
  multi-line call the `=` of every parameter must line up at the column after the
  longest parameter name (`align_parameters`); keeping the call on one line avoids
  that entirely.
* Do not rely on `d` date arithmetic (`date - date`, `date + n`); it is not
  reproduced by the transpiler (ANOMALIES.md A20). Convert to an integer day number
  instead, as `zcl_alloc_retention` does.
* `align_type_expressions` aligns the `TYPE` keyword of method parameters, of
  consecutive `DATA` statements and of structure components to exactly one space
  after the longest name of the group (equivalently `indent + longest name + 2`; a
  blank line ends a group). Because the target column depends on the longest name,
  let `npm run lint` report it - the message names the current and the expected
  column - and widen the shorter names by that difference.
* Every abapGit XML file must start with a UTF-8 BOM (`EF BB BF`); the `xml_bom`
  rule fails the build without it, so each new `<object>.<type>.xml` file is written
  with the BOM as part of its content.
* Tests are local test classes in `<class>.clas.testclasses.abap` files.
* Database-dependent test classes create the SQL test double environment in
  `class_setup` and destroy it in `class_teardown`; `setup` only calls
  `clear_doubles( )`. Creating it per test method fails in a real SAP system
  (see ANOMALIES.md A26).
* Test doubles for interfaces are plain local classes inside the test file
  (`lcl_stock_reader_stub`), so no dependency on a mocking framework is needed.

## abapGit serialization

The repository is set up for abapGit: `.abapgit.xml` at the root selects `/src/`
as the starting folder and every object carries its serialized metadata next to
the source (`<object>.<type>.xml`).

* `src/*.clas.xml` - one per class. Serializer `LCL_OBJECT_CLAS` with
  `CLSNAME`, `LANGU`, `DESCRIPT`, `STATE`, `CLSCCINCL`, `FIXPT`,
  `WITH_UNIT_TESTS` (set for every class here, because all 250 have a local test
  class) and `UNICODE`, plus an `R` text-pool entry holding the description.
* `src/*.intf.xml` - one per interface (6). Serializer `LCL_OBJECT_INTF` with
  `CLSNAME`, `LANGU`, `DESCRIPT`, `EXPOSURE` 2, `STATE` and `UNICODE`.
* Descriptions are taken from the `PLAN.md` / `NOTES.md` feature titles where the
  class is documented and are derived from the class name otherwise.
* Objects that already had metadata (the DDIC data elements, tables and
  structures plus the BAPI function group under `stubs/`) were left alone, apart
  from completing the fields `xml_consistency` requires: `REFTABLE`/`REFFIELD` on
  the 26 `QUAN` fields and `HEADLEN`/`SCRLEN1-3` on the three data elements that
  declare label texts.
* The function module `bapi_goodsmvt_create` deliberately has no XML of its own: a
  function module is not an abapGit object, its interface is described inside
  `stubs/fugr/bapi_goodsmvt.fugr.xml` under `FUNCTIONS/item`.
* Every XML file starts with a UTF-8 byte order mark (`EF BB BF`), which is what
  abapGit writes and what the `xml_bom` rule requires. The transpiler reads the
  DDIC definitions from the BOM files without complaining.
* `npm run clean` uses `rimraf output` (`rimraf` is a dev dependency) instead of a
  `node -e` one-liner.
* Metadata exists for every class (roadmap orders 1-452). The classes from order
  309 on were generated by a small shell helper that writes the UTF-8 byte
  order mark as raw bytes and then the serialized XML, because the editor's file
  tools strip a BOM from the start of the content. The metadata is what abapGit
  expects, so the whole repository can be serialized; `npm test` does not depend
  on it.

With the metadata present, `abaplint` additionally runs `xml_consistency` and
`xml_bom` over every XML file (see `ANOMALIES.md` A21 and A23).
