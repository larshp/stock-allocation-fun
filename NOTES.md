# NOTES

## Iteration 22 (current)

### New features
- **Run configuration** (`ty_run_config): `run_with_config( )` bundles
  simulation flag, strategy name (resolved via the factory) and delivery-date
  horizon into one call - the full-featured entry point for production use.
- **Backorder detection** (`zcl_backorder_check): `detect( )` compares open
  order items against allocations and reports items with unmet quantity
  (`qty_open`). Wired into `run_with_config` via `ty_run_result-backorders`.

### Fixed / learned
- Types referenced in a class's public TYPES must be resolvable: use the
  qualified name (`zcl_alloc_audit=>ty_runnr`) when the type lives in another
  class.

### Test status
- abaplint: 0 issues
- transpiler unit tests: 40/40 pass

## Iteration 21

### New features
- **Strategy factory** (`zcl_alloc_strat_factory): creates strategy
  instances by name (`FIFO`, `LARGEST`); unknown names fall back to FIFO.
  Built-in strategies: `zcl_alloc_strat_fifo` (insertion order) and
  `zcl_alloc_strat_largest` (largest free stock first - fewer locations
  touched per order). Both implement `zif_alloc_strategy`.
- **JSON export** (`zcl_alloc_result_export): `to_json( ) serializes
  allocation rows to a JSON array string for external systems / logs.

### Fixed / learned
- Chained string template concatenation `a = b && |...| && |...|` is not
  parseable by abaplint - build intermediate strings or use CONCATENATE.
- Packed quantities must be converted to string via string template before
  CONCATENATE (source type not compatible otherwise).
- The transpiled runtime lacks `assert_contains` - use
  `assert_not_initial( find( val = ... sub = ... ) )`.

### Test status (iteration 21)
- abaplint: 0 issues
- transpiler unit tests: 39/39 pass

## Iteration 20

### New features
- **Run lock** (`zcl_alloc_lock): ENQUEUE-style lock preventing concurrent
  allocation runs from double-allocating the same stock. `acquire/release/
  is_locked`. `zcl_stock_alloc_run=>run` acquires the lock at the start and
  releases at the end; a locked run returns an E message ('LOCKED') and no
  allocations.
- **Shortage report** (`zcl_shortage_report): `build( )` groups run
  allocations per material/plant and reports affected item counts plus the
  overall run shortage - the planner's view of unmet demand.

### Fixed / learned
- `LOOP ... GROUP BY is not supported by the transpiler (Void type:
  todoGroupBy) - use READ TABLE with manual grouping instead.
- Locks are class state: tests sharing a class must release locks in setup.

### Test status (iteration 20)
- abaplint: 0 issues
- transpiler unit tests: 35/35 pass

## Iteration 19

### New features
- **Multi-plant allocation** (`allocate_multi_plant): plants are consumed in
  caller-defined order; each plant serves up to its usable stock (total stock
  minus safety stock). Returns `tt_sub_allocations` rows carrying the plant,
  so per-plant deliveries can be created. Safety stock per plant is enforced
  via a run-level class variable set from `iv_safety_stock`.

### Lesson learned
- Allocation mutates a local copy of the MARD rows - repeated allocations see
  unchanged stub stock unless posting happens. Tests must assert stub state
  accordingly (stock only changes through reduce_stock on posting).

### Test status (iteration 19)
- abaplint: 0 issues
- transpiler unit tests: 33/33 pass

## Iteration 18

### New features
- **Material substitution** (`zcl_stub_substitution): substitution rules
  (original material -> substitute, priority ordered). New
  `allocate_with_substitution( iv_matnr, iv_werks )`: allocates from the
  requested material first; remaining demand is served by substitutes in
  priority order. Returns `tt_sub_allocations` with both `matnr_req` and
  `matnr_used` per row so the caller sees exactly which material covered
  which part of the demand.

### Lesson learned
- Alphabetical sort surprises: 'MATS1' < 'MATSB' (digits before letters).
  When tests rely on sorted order, verify the actual collation or index by
  content instead of position.

### Test status (iteration 18)
- abaplint: 0 issues
- transpiler unit tests: 32/32 pass

## Iteration 17

### New features
- **Partial delivery control**: order items carry MAXPW (integer).
  - `maxpw = 0` (initial): unlimited partial deliveries (default)
  - `maxpw = 1`: full delivery from ONE storage location only; if no single
    SLoc covers the whole demand the item is skipped entirely with a W
    message ('FULL') and counted as shortage
  - `maxpw = N`: at most N allocation rows
- **Stock transfer suggestions** (`zcl_stock_transfer_sugg): when a preferred
  storage location cannot cover the demand, `suggest( )` proposes UB-like
  transfers from other locations. Sources are chosen by descending free
  stock so fewer transfers are needed; each suggestion carries source,
  destination and exact quantity.

### Lesson learned
- Integer flags default to 0 - design flag semantics accordingly (0 =
  unlimited/unset, not "full delivery only"). The first maxpw design broke
  every existing test because unset items became full-delivery-only.
- Allocation works on a copy of stock rows: repeated allocations in one test
  see the same stub stock unless posting happens.

### Test status (iteration 17)
- abaplint: 0 issues
- transpiler unit tests: 31/31 pass

## Iteration 16

### New features
- **Requested delivery date horizon**: order items carry EDATU (schedule
  line date, new DDIC stub edatu.dtel.xml). New
  `allocate_material_until( iv_date )` allocates only items due up to the
  horizon; items due later keep their stock free. Undated items count as
  urgent (always included). `read_open_items_until` added to the stub.
- **Pluggable allocation strategy** (`zif_alloc_strategy): interface with
  `sort_stock( it_mard, iv_matnr, iv_werks )` returning the consumption
  order. New `allocate_material_by_strategy( io_strategy )` accepts any
  implementation - custom strategies (e.g. transport-cost optimized) can be
  added without touching the engine. Test uses a local `lcl_reverse_strategy`
  that consumes locations in descending lgort order.

### Fixed
- align_parameters rule: keyword parameters of a call must align consistently
  (`iv_matnr    = ...` / `io_strategy = ...`).

### Test status (iteration 16)
- abaplint: 0 issues
- transpiler unit tests: 26/26 pass

## Iteration 15

### New features
- **Stock reservations** (`zcl_stub_mard): `reserve_stock` /
  `release_reservation` / `get_available` / `is_available`. Reservations
  reduce the stock visible to allocation (available = unrestricted stock
  minus reserved). Over-reserving fails with rv_ok = abap_false.
- **Material availability check**: `is_available( matnr, werks, lgort, qty )`
  answers whether a quantity is fully allocatable at one storage location -
  useful for ATP-like checks before promising a delivery date.
- The allocator's `get_available_stock now subtracts reservations per
  location, so allocation automatically respects them.

### Test status (iteration 15)
- abaplint: 0 issues
- transpiler unit tests: 24/24 pass

## Iteration 14

### New features
- **Order type blocking**: sales order items carry an order type (AUART).
  `zcl_stub_sales_order=>block_order_type / unblock_order_type / is_blocked`
  control which order types are excluded from allocation (e.g. orders with
  pending credit blocks). Blocked items are filtered in `read_open_items`.
- **Run audit trail** (`zcl_alloc_audit): every run through
  `zcl_stock_alloc_run=>run` is recorded with run number, date/time,
  simulation flag and full statistics. `record/read_log/read_entry/clear`
  API; the run number is returned in `ty_run_result-runnr`.

### Fixed
- Inline `TYPE n LENGTH 10` in structure definitions breaks the abaplint
  parser ("Statement does not exist in the configured ABAP version") - use a
  named local type (`TYPES ty_runnr TYPE n LENGTH 10.`) instead.
- Packed quantities render as `'10.000'` in string templates - again.

### Test status (iteration 14)
- abaplint: 0 issues
- transpiler unit tests: 23/23 pass

## Iteration 13

### New features
- **Unit-of-measure conversion** (`zcl_stub_uom): order items are kept in
  sales units (VRKME, e.g. CS) while stock is managed in base units (MEINS,
  e.g. PC). `allocate_from_sorted now converts every order quantity via
  `convert_to_base (base = qty * umrez / umren, rounded half up). Without a
  rule the quantity passes through unchanged. New DDIC stubs: meins.dtel.xml,
  umrez.dtel.xml, umren.dtel.xml.
- **Allocation documents** (`zcl_alloc_document): each run creates a
  persistent document (number range starting at 5000000001) holding all
  allocation rows with status O (open) -> P (posted). `create/read/
  set_posted/clear API. This is the artifact a real SAP system would post
  goods movements against.

### Test status (iteration 13)
- abaplint: 0 issues
- transpiler unit tests: 20/20 pass

## Iteration 12

### New features
- **FEFO strategy** (`allocate_material_fefo): stock locations are consumed
  by ascending batch date BDATR (first expired, first out). Locations without
  a date are used last. New DDIC element `bdatr.dtel.xml` (DATS) added to the
  MARD stub table.
- **Allocation statistics**: `ty_result-stats` (items_total/full/partial/none,
  qty_requested, qty_allocated); aggregated across materials in
  `zcl_stock_alloc_run=>ty_run_result-stats. Shown in the report.
- **One allocation row per storage location**: when an order item is fulfilled
  from several SLocs, each location now gets its own allocation row with its
  exact quantity (previously a single row held the sum and only the *last*
  SLoc reference - a real design bug found by the FEFO test).

### Fixed
- `ty_stats` was defined after `ty_result referenced it -> transpiler
  unknown_types error. Types must be declared before use.
- Tests updated for per-SLoc rows: multi_location_allocation now expects 2 rows,
  no_stock_shortage expects no rows at all.

### Test status (iteration 12)
- abaplint: 0 issues
- transpiler unit tests: 17/17 pass

## Iteration 11

### New features
- **Minimum quantity threshold for posting**: `post_allocations( )` now takes
  optional `iv_min_qty`. Allocations below the threshold are skipped and stay
  open for a later run (order item and stock untouched).
- **Preferred storage location strategy**:
  `allocate_material_with_sloc( iv_matnr, iv_werks, iv_lgort )` - stock is
  taken from the preferred SLoc first; remaining demand falls back to the
  other locations in their original order.
- Refactoring: the allocation core moved into private
  `allocate_from_sorted( )`, shared by both public allocation methods;
  `sort_mard_preferred( )` builds the preferred-SLoc-first stock list.

### Lesson learned
- `allocate_from_sorted` mutates its local copy of the MARD rows (fresh table
  from `read_by_material_plant`), so repeated allocations see the *full* stub
  stock unless `post_allocations`/`reduce_stock` actually posts. Tests must
  post between runs to observe stock consumption.

### Test status (iteration 11)
- abaplint: 0 issues
- transpiler unit tests: 14/14 pass

## Iteration 10

### New features
- **`zcl_stock_alloc_run`**: multi-material allocation run.
  - `run( it_materials, iv_werks, iv_simulate )` aggregates allocations,
    shortages and messages over several materials in one call.
  - **Simulation mode** (`iv_simulate = abap_true`): calculates allocations
    without posting - stock and order items stay untouched; an I message
    `SIMULATION` is added to the log.
  - **Delivery priority handling**: items are allocated by ascending LPRIO
    (1 = highest) before FIFO by document number. `lprio` added to the order
    item stub, VBAP stub DDIC and `ty_allocation`.
- Stub helper `zcl_stub_sales_order=>count_items( )` for tests.
- Report rewritten to use the run class; `p_sim` checkbox toggles simulation,
  output shows priority column and simulation marker.

### Fixed
- `priority_before_fifo` test asserted swapped indexes after `SORT BY vbeln`;
  corrected (order 31 = 1 pc, order 32 = 4 pc).
- abaplint `local_testclass_consistency`: class XML needs
  `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` when a testclass include exists.

### Test status (iteration 10)
- abaplint: 0 issues
- transpiler unit tests: 12/12 pass

## Ideas for next iterations
- FEFO/FIFO by batch date instead of MARD row order.
- Unit-of-measure conversion (VRKME vs base UoM).
- Replace stubs with real SAP APIs behind an interface for on-prem usage.

## Iteration 9

### Fixed
- Unit test assertions compared `condense( |{ qty }| )` (e.g. `5`) against
  transpiled packed output `5.000`. Removed `condense`, compare against
  `'X.000'` strings directly.
- **Bug in `zcl_stub_mard=>insert_row`**: used `MODIFY TABLE gt_mard FROM is_mard`.
  The transpiler runtime does not populate `keyFields` for standard tables
  (`keyFields: []`), so the `FROM`-key lookup matched the *first* row
  unconditionally and overwrote it. Replaced with explicit
  `READ TABLE ... ASSIGNING ... WITH KEY matnr werks lgort` + `APPEND`.
- **Bug in `zcl_stock_allocator=>allocate_material`**: allocated stock was never
  consumed between order items - every item saw the full stock. Added
  `<ls_mard>-labst = <ls_mard>-labst - lv_qty_take` inside the storage location
  loop.
- `fifo_order_respected` test data/expectations were inconsistent; rewritten.

### New features (iteration 9)
- `post_allocations( )`: posts allocations - confirms quantities on sales order
  items (`zcl_stub_sales_order=>confirm_quantity`) and reduces unrestricted
  stock (`zcl_stub_mard=>reduce_stock`, new stub method).
- Message logging: `ty_result-messages` (type `zcl_stub_message=>tt_message`).
  Each order item logs S (fully allocated), W (partial), E (no stock) with the
  simulated message class `ZSTOCK_ALLOC`.
- Report `zstock_allocation`: new `p_post` checkbox to post allocations,
  displays messages in the result list. Removed unused `p_test`.

### Test status (iteration 9)
- abaplint: 0 issues
- transpiler unit tests: 9/9 pass

### Test status
- abaplint: 0 issues
- transpiler unit tests: 9/9 pass

## Ideas for next iterations
- Allocation run as a single transaction over several materials with a common
  log (BAL-like), plus display of the log.
- Priority handling: urgent orders (delivery priority / document type) before FIFO.
- Locking/simulation mode: run allocation without posting (what-if).
- Replace stubs with real SAP APIs (BAPI_GOODSMVT_CREATE, BAPI_SALESORDER_CHANGE)
  behind an interface for on-prem usage.
