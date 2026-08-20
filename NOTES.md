# Notes

Working notes and progress for the ABAP stock allocation solution.
Bugs and tool issues go in [ANOMALIES.md](ANOMALIES.md).

## Layout

| Path                      | Contents                                                          |
| ------------------------- | ----------------------------------------------------------------- |
| `src/`                    | Custom code, all objects prefixed `Z`                             |
| `sap-stubs/`              | Stubs of SAP standard objects that open-abap does not ship        |
| `test/setup.mjs`          | Wires an in-memory SQLite database into the transpiled unit tests |
| `abaplint.json`           | Lint configuration                                                |
| `abaplint-transpile.json` | Transpile configuration                                           |

`npm test` runs the whole loop: `abaplint` -> `abap_transpile` -> `node output/index.mjs`.

## Why `sap-stubs/` is a separate directory

The plan requires all custom `Z*` code to live in `src/`. The stubs are not custom
code: they carry SAP standard names (`MARD`, ...) and they simulate SAP-owned
behaviour, so they get their own directory and a narrow set of rule exemptions:

- `object_naming` is excluded there, because SAP objects do not start with `Z`.
- `modify_only_own_db_tables` is excluded there, because SAP-owned code is
  exactly the code that is allowed to write SAP tables.

Both directories are linted and transpiled together
(`"files": "/{src,sap-stubs}/**/*.*"`, `"input_folder": ["src", "sap-stubs"]`).

## abaplint configuration decisions

Starting point is `abaplint --default`, so all 188 rules are explicit in
`abaplint.json`. Deviations from the default, and why:

| Rule                         | Setting                                    | Reason                                                                                       |
| ---------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------------------- |
| `modify_only_own_db_tables`  | exclude `sap-stubs/`, `*.testclasses.abap` | Stubs are SAP-owned; test code seeds SAP tables to build fixtures. Production `Z` code is still fully covered. |
| `object_naming`              | exclude `sap-stubs/`                       | SAP standard names do not match `^ZC(L\|X)` etc.                                              |
| `downport`                   | `false`                                    | Target is a modern (7.5x+) system; 7.02-compatible syntax is not wanted.                       |
| `remove_descriptions`        | `false`                                    | Descriptions are kept in the abapGit XML so objects read properly in SE80/ADT.                 |
| `description_empty`          | `true` (default)                           | ... and they must actually be filled in.                                                       |
| `no_prefixes`                | `false`                                    | Conflicts with `local_variable_names` / `class_attribute_names`, which enforce `lv_`/`mo_`/`iv_`. |
| `unused_methods`             | `false`                                    | Public API methods look unused from inside the repo.                                           |
| `identical_descriptions`     | `false`                                    | Stub objects legitimately repeat SAP's own texts.                                              |
| `cyclic_oo`, `line_break_style` | `false`                                 | Same choice as the reference project `open-abap/open-abap-mbc`.                                |

The eight rules the plan calls out are all on: `modify_only_own_db_tables`,
`align_type_expressions`, `easy_to_find_messages`, `max_one_method_parameter_per_line`,
`align_parameters`, `local_testclass_consistency`, `allowed_object_naming`, `line_length`.

`syntax.version` is `open-abap` and `syntax.errorNamespace` is `.`, so every
object in the repo — stubs included — is fully syntax checked.

## Progress

### Feature 1 — read available stock (done)

- `sap-stubs/mard.tabl.xml`: `MARD` with the stock quantity fields. Fields are
  typed directly (`DATATYPE`/`LENG`/`DECIMALS`) instead of via `ROLLNAME`, which
  keeps the stub self-contained — no `DTEL`/`DOMA` objects needed. `LABST` is
  `DEC 13,3` rather than `QUAN 13,3` so no quantity-unit reference field is
  required; both map to `P LENGTH 7 DECIMALS 3` in ABAP, so custom code compiles
  identically against the real table.
- `src/zif_stock_reader.intf.abap`: read interface, so callers can be unit
  tested against a test double instead of the database.
- `src/zcl_stock_reader.clas.abap`: `SELECT` from `MARD`, skipping storage
  locations flagged for deletion (`LVORM`).
- `src/zcl_stock_reader.clas.testclasses.abap`: seeds `MARD`, asserts the read.
  Each test class uses its own material number and cleans up in `teardown`, so
  no test depends on another.

### Feature 2 — allocation engine (done)

- `src/zif_allocation.intf.abap`: the shared vocabulary — quantity, demand,
  allocation result. `ty_quantity` is `p LENGTH 7 DECIMALS 3`, the exact ABAP
  representation of the `MARD` quantity fields, so nothing is converted on the
  way in or out. No DDIC object is needed for it.
- `src/zif_allocation_strategy.intf.abap`: one method, `allocate`, taking the
  available quantity and the competing demand. Making this an interface is the
  point of the design: "who gets the stock" is the part that differs per
  business, and it can be swapped without touching the engine.
- `src/zcl_alloc_strategy_priority.clas.abap`: the first strategy. Sorts by
  priority, then requested date, then demand id, and serves each line in full
  until the stock runs out. The tie-break on demand id keeps the result
  deterministic, which matters because the tests compare whole tables.
- `src/zcl_allocation_engine.clas.abap`: pools the stock of every storage
  location in the plant and hands the total to the strategy. Both collaborators
  are injected through the constructor, so the engine is tested against a local
  double instead of the database.

Guarded behaviour worth keeping: negative book stock (which `MARD` can carry)
confirms nothing rather than producing negative confirmations, and `shortfall`
is never negative.

### Feature 3 — sales order demand (done)

- `sap-stubs/vbak.tabl.xml`, `sap-stubs/vbap.tabl.xml`: sales document header
  and item, cut down to the fields the allocation needs.
- `src/zif_demand_reader.intf.abap`: where demand comes from is now swappable
  too. Sales orders are the first source; stock transport orders and planned
  independent requirements can be added behind the same interface.
- `src/zcl_so_demand_reader.clas.abap`: joins `VBAP` to `VBAK` and returns open
  demand only — items with a reason for rejection (`ABGRU`) and items of a
  delivery-blocked order (`VBAK-LIFSK`) are filtered out in the `WHERE` clause
  rather than in ABAP, so the database does the work.

Mapping decisions:

- The demand id is `VBELN` (10) followed by `POSNR` (6), which is exactly the
  16 characters of `ty_demand_id`. It is built with offset writes rather than a
  string template so a short document number can never shift the item number.
  (Feature 28 takes the id down to the schedule line and widens it to 24.)
- SAP's delivery priority `VBAP-LPRIO` is the allocation priority directly.
  `LPRIO` is `NUMC 2`, so an item without a priority is `00` and would sort
  *first*. That is the opposite of what "no priority set" should mean, so an
  initial `LPRIO` is mapped to `99` and sorts last.

### Feature 4 — end to end allocation (done)

`ZCL_ALLOCATION_ENGINE` now takes a `ZIF_DEMAND_READER` as well, and offers two
entry points:

- `allocate_open_demand( iv_matnr, iv_werks )` — answers "who gets what" for the
  demand that is really on the books. This is the production path.
- `allocate( iv_matnr, iv_werks, it_demand )` — the same calculation against a
  demand list the caller supplies, for simulation and what-if. It deliberately
  never touches the demand reader, which is pinned by a test.

All three collaborators are constructor-injected, so the engine tests run
entirely against local doubles and need no database.

### Feature 5 — fair share strategy (done)

`ZCL_ALLOC_STRATEGY_FAIRSHARE` cuts every line back by the same proportion
instead of serving the top of the queue in full. Same interface, so it drops
straight into the engine.

The interesting part is the arithmetic. Quantities carry three decimals, and a
proportional split rarely lands on a whole thousandth, so two things had to be
true at once: nobody may be confirmed more than the pool holds, and the
confirmed quantities must add up to exactly what was available.

- Everything is scaled to whole thousandths and divided with `DIV`, which
  truncates. Ordinary `/` rounds, and rounding up can hand out stock that is
  not there.
- Each line's share is derived from the **running** total rather than computed
  per line. A per-line calculation loses up to a thousandth on every line and
  the losses accumulate; deriving from the running total means each rounding
  error is corrected by the next line. `10` split over three lines of `10`
  gives `3.333 / 3.333 / 3.334`, which adds back up to `10.000` exactly, and
  `1` split over seven lines still totals exactly `1`.
- The leftover thousandth therefore lands on the line that sorts last, i.e. the
  lowest priority. Sorting is the same as the priority strategy, so the outcome
  is deterministic.
- The intermediate type is `p LENGTH 16` (31 digits) because the running total
  is multiplied by the available quantity before dividing. `int8` would
  overflow on large quantities.

Both strategies now also treat a negative requested quantity as no demand at
all: it confirms nothing, its shortfall is zero rather than negative, and it
does not consume or dilute the stock available to the other lines.

### Feature 6 — persist the result (done)

An allocation is only useful if the answer survives the run.

- `src/zstock_alloc_res.tabl.xml`: the result table, keyed by run and demand
  line, with `CREATED_BY` / `CREATED_AT` so a run can be traced back.
- `src/zstock_alloc.msag.xml`: message class, and `src/zcx_allocation.clas.abap`
  the exception that carries it. The T100 constant pattern is what
  `easy_to_find_messages` wants — the message class and number are literals in
  the source, so a message can be traced to its `RAISE` with a plain search.
- `src/zif_allocation_store.intf.abap` / `src/zcl_allocation_store.clas.abap`:
  `save` and `read`.

Notes on the store:

- `save` deletes the run before inserting it, so re-running an allocation
  replaces the previous answer instead of accumulating duplicates. A `DELETE`
  that finds nothing reports `sy-subrc = 4`, which is the normal first-save case
  and is explicitly *not* treated as an error — only anything else is.
- This is the one place custom code writes to the database, and it writes to its
  own `Z` table. `modify_only_own_db_tables` is live over `src/` with no
  exemption, so it is checked rather than assumed.
- The run id is an input rather than something the store invents. Which id
  scheme to use is the caller's decision, and keeping it out means the store has
  no hidden state and the tests are deterministic.

### Feature 7 — the service (done)

`ZCL_ALLOCATION_SERVICE` is what an outside caller talks to. `run( iv_matnr,
iv_werks )` takes an id, allocates, stores the result and hands back both the id
and the confirmed quantities. It stores before it returns, so the caller can
always look the run up again.

- `ZIF_RUN_ID_SUPPLIER` / `ZCL_RUN_ID_UUID`: ids come from
  `cl_system_uuid=>create_uuid_c22_static( )`, which fills
  `ZSTOCK_ALLOC_RES-RUN_ID` exactly. Behind an interface, so a customer that
  wants a number range instead swaps one class, and so the service tests get a
  predictable id.
- `create_default( )` wires the production objects together — MARD reader, sales
  order reader, priority strategy, database store, UUID ids — so nothing outside
  needs to know the object graph. Passing a strategy overrides just that part.

Everything the service depends on is an interface except the engine itself,
which is a plain class because it is pure orchestration with nothing to swap.

### Feature 8 — reserve the confirmed stock (done)

Recording the answer is not the same as acting on it. A confirmed quantity is
only worth something if the stock is actually earmarked, which in SAP means a
reservation.

New stubs, all under SAP standard names:

- `resb.tabl.xml`, `rkpf.tabl.xml`: reservation item and header.
- `bapi2093_res_head.tabl.xml`, `bapi2093_res_item.tabl.xml`: the BAPI
  structures. `BAPIRET2` is *not* stubbed — open-abap-core already ships it, and
  a second copy trips `errorOnDuplicateFilenames`.
- `bapi_reservation.fugr.*`: the function group holding
  `BAPI_RESERVATION_CREATE1`, with the real signature so that the custom
  `CALL FUNCTION` is syntax checked against what a real system offers.
- `cl_stub_reservation.clas.abap`: the behaviour behind the function module —
  rejects an empty item table, hands out the next reservation number, writes
  `RKPF` and `RESB`. It exists because `reduce_procedural_code` caps a function
  module at 10 statements, which is the right rule: SAP's own BAPIs delegate to
  classes too. It is stub-internal, not part of the API the custom code sees.

Custom side:

- `ZIF_RESERVATION_WRITER` / `ZCL_RESERVATION_WRITER`: one reservation item per
  line that actually got something. Lines confirmed at zero are skipped, and if
  nothing was confirmed the BAPI is not called at all rather than being sent an
  empty reservation. `RETURN` messages of type `E` or `A` raise
  `ZCX_ALLOCATION`; warnings do not.
- The movement type is a constructor parameter, defaulting to `311`. Which
  movement type an allocation reserves under is Customizing, not something this
  code should decide for a customer.
- `ENTRY_UOM` is deliberately left empty so the BAPI falls back to the material's
  base unit of measure, which is where the quantity came from.

The requirement date needed to travel from the demand to the reservation, so
`ty_allocation` gained `req_date` and `ZSTOCK_ALLOC_RES` a `REQ_DATE` column.
An allocation answer that cannot say *when* the stock is needed is incomplete
anyway — reservations, and any report on the result, both want it.

**Testing the BAPI call.** The stub function group is linted but excluded from
transpiling, because a function module parameter named `RETURN` transpiles to
invalid JavaScript (ANOMALIES.md 2f). The writer's tests therefore replace
`BAPI_RESERVATION_CREATE1` with a function module double from
`cl_function_test_environment`, which open-abap-core supports for function
modules that do not exist in the transpiled output. The `CALL FUNCTION` itself
is executed, and the tests assert what the BAPI was handed, not just what came
back.

### Feature 9 — one run, end to end (done)

`ZCL_ALLOCATION_SERVICE->run( )` now does the whole job: allocate, record,
reserve, and link the record to the reservation. `ZSTOCK_ALLOC_RES` gained a
`RESERVATION` column and the store a `record_reservation` method.

The order is deliberate — **record first, reserve second**:

- If the reservation is rejected, there is still a record of what was decided.
  It can be looked up by run id and retried.
- The other way round, a failure between reserving and recording would leave
  stock earmarked in SAP with nothing in the custom tables pointing at it, which
  nobody would find.

`record_reservation` is a separate call rather than a parameter of `save`
because the reservation number does not exist yet when the result is written.
Linking a run that was never saved raises rather than silently updating nothing.

`ZCL_ALLOCATION_ENGINE` stays the entry point for working out an allocation
without recording or reserving anything.

### Feature 10 — do not allocate the same stock twice (done)

Up to here the available quantity came straight from `MARD`. That is book
stock, not available stock: once feature 8 started creating reservations, a
second run would have handed out the very same quantity again. Nothing in the
suite caught it, because every test started from an empty `RESB`.

`ZCL_STOCK_READER_NET` is a decorator around `ZIF_STOCK_READER`. It asks the
wrapped reader for the book stock, then subtracts what is already reserved:

- Open quantity is `BDMNG - ENMNG`, so a reservation that has already been
  partly withdrawn only ties up the remainder — the withdrawn part has left
  `MARD` already and must not be counted twice.
- Items flagged `XLOEK` reserve nothing.
- The result never goes below zero. Over-reserved stock reads as nothing
  available, not as a negative that would then be handed out as a credit.

It is a decorator rather than a change to `ZCL_STOCK_READER` because the two
questions really are separate — "what does the book say" and "what is still
free" — and a site that reserves through some other mechanism can leave the
wrapper off. `create_default( )` wires it on.

Reservations are not tied to the storage location the stock will come from, so
the deduction is consumed in storage location order. The plant total is what the
engine works with, and that comes out right.

### Feature 11 — something a user can actually run (done)

`ZSTOCK_ALLOCATION` is an executable program with material, plant and a "fair
share instead of priority" checkbox on the selection screen. It builds the
service through `create_default( )`, asks `ZCL_ALLOCATION_REPORT` for the lines
and writes them.

`ZCL_ALLOCATION_REPORT` returns the lines instead of writing them. `WRITE` output
cannot be asserted, a table of strings can — so the column layout, the totals
and the failure message are all covered by tests. The program itself is then
thin enough that there is nothing left in it worth testing, which also keeps it
under the 10 statement cap `reduce_procedural_code` puts on procedural code.

A rejected run comes back as a line saying so rather than as an exception. A
report has nowhere to throw to, and a short dump is not an error message.

`ZIF_ALLOCATION_SERVICE` was extracted in the same step. The report is the first
caller from outside, and it should depend on the same kind of seam everything
else does — and it lets the report tests run without a database.

### Feature 12 — safety stock, and netting made composable (done)

Safety stock (`MARC-EISBE`) is what the plant deliberately keeps back. It sits
in `MARD` like any other stock, so until now it was being handed out.

That is a second reason to hold stock back, after reservations, so the netting
became an interface instead of a hard-coded rule:

- `ZIF_STOCK_DEDUCTION` — "how much of this material in this plant is not up for
  allocation".
- `ZCL_DEDUCT_RESERVATIONS` — the `RESB` logic, moved out of the decorator.
- `ZCL_DEDUCT_SAFETY_STOCK` — `MARC-EISBE`, new.
- `ZCL_STOCK_READER_NET` now takes a list of deductions, adds them up and takes
  the total off. It no longer knows *why* anything is held back.

A site with its own rule — quality inspection stock, consignment, a
customer-specific set-aside — writes one small class and adds it to the list.
`create_default( )` wires both of the above.

`MARC` is stubbed with the fields the deduction needs. A material with no plant
data holds nothing back rather than failing: `MARC` missing is a master data
problem, not a reason to refuse to allocate.

This step also turned up the nastiest tool defect so far — an inline
`DATA(x) = a - b` over packed fields silently loses the decimals and rounds the
result (ANOMALIES.md 2h). It was only caught because this feature's tests used
a fractional quantity. Quantities here carry three decimals, so test data
should use them.

### Feature 13 — allocate a whole plant (done)

Allocating one material at a time is not how this gets used. A nightly job
covers everything in the plant that is waiting.

- `ZIF_DEMAND_READER` gained `materials_with_demand( iv_werks )`, filtered
  exactly like `read_open_demand` so a material only appears if it would
  actually get demand lines. Asking the demand source is right: it is the thing
  that knows what open demand looks like.
- `ZCL_ALLOCATION_MASS_RUN` runs the service per material and returns one
  outcome line each.

The point of the class is what it does with failure: **one material failing does
not stop the rest**. This runs unattended, and a single blocked material must not
cost a night's worth of allocations. The outcome line carries the reason instead
of a result, so the whole run can be read afterwards and the failures picked out.

`SELECT DISTINCT` turned out to be dropped by the transpiler (ANOMALIES.md 2i),
which showed up as a material with two open orders being allocated twice.
Deduplication now happens in ABAP.

### Feature 14 — the report covers the plant (done)

`ZSTOCK_ALLOCATION` now asks for a plant and, optionally, a material. Leaving
the material empty allocates everything in the plant that is waiting. The
material parameter lost `OBLIGATORY`; the plant kept it.

`ZCL_ALLOCATION_MASS_RUN->run` takes an optional material list and falls back to
asking the demand reader when it is empty, so the report always goes through the
same path and the program does not branch on it. `ZCL_ALLOCATION_REPORT` prints
one block per material and a footer counting how many were covered and how many
failed — the number a person actually looks for after an overnight job.

### Feature 15 — check the user may do this (done)

Custom code that writes to SAP has to check authorizations, and nothing here did.

- `ZIF_ALLOCATION_AUTHORITY` / `ZCL_AUTHORITY_PLANT`: `AUTHORITY-CHECK` on
  `M_MATE_WRK` with activity `02` and the plant — the same object the standard
  inventory transactions check.
- The check sits in `ZCL_ALLOCATION_SERVICE->run`, as its first statement. That
  is the object that writes to the database and creates reservations, so
  guarding it means no caller can get around the check by going in a different
  way. A test pins that a refused run writes nothing and reserves nothing.

Behind an interface because the check has to be exercised in a test, and because
a site that guards allocation with its own authorization object should be able
to swap it without touching the service.

open-abap answers every `AUTHORITY-CHECK` with "granted" and cannot be persuaded
otherwise (ANOMALIES.md 2j), so the statement itself is covered but its refusal
branch is not. Refusal is covered where it changes behaviour — at the service,
against a double.

### Feature 16 — installable, and checked on every push (done)

`.abapgit.xml` makes the repository something abapGit can pull. The setting that
matters is `STARTING_FOLDER = /src/`: only the custom `Z` objects are installed.
`/sap-stubs/` is explicitly ignored, and must be — installing a stub `MARD` or a
stub `BAPI_RESERVATION_CREATE1` into a real system would be a serious mistake,
so the safeguard belongs in the descriptor rather than in a warning nobody
reads.

`.github/workflows/test.yml` runs `npm ci && npm test` on every push and pull
request, which is the same lint, transpile and unit test loop used locally.

### Feature 17 — units of measure (done)

A real bug, not a new capability. `MARD` keeps stock in the material's **base**
unit. `VBAP-KWMENG` is in the **sales** unit, `VBAP-VRKME`. Everything up to
here compared the two numbers directly, so an order for 3 cartons of 12 was
competing for 3 pieces of stock, and would have been confirmed in full off
almost nothing.

- `sap-stubs/mara.tabl.xml`, `sap-stubs/marm.tabl.xml`: the base unit and the
  conversion factors.
- `ZIF_UNIT_CONVERTER` / `ZCL_UNIT_CONVERTER`: `to_base` reads `MARA-MEINS`, and
  for any other unit scales by `MARM-UMREZ / UMREN`.
- `ZCL_SO_DEMAND_READER` converts every item as it reads it, so everything
  downstream — engine, strategies, store, reservation — works in base units and
  needs no knowledge of this at all.

**A missing conversion is an error, not a factor of one.** Treating an
unconvertible quantity as if it were already in base units is exactly the bug
being fixed, so `to_base` raises when the material master is missing, the unit is
not defined for the material, or the denominator is zero. `read_open_demand` and
`allocate_open_demand` gained `RAISING zcx_allocation` to let that through, and
the mass run already turns a failing material into a reported outcome rather
than a stopped run.

The conversion is done with an explicitly typed variable rather than an inline
`DATA()`, for the reason in ANOMALIES.md 2h. A test converts 3 boxes of 5/2 kg
and expects `7.5`, which is what pins it.

### Feature 18 — do not serve the same demand twice (done)

The mirror image of feature 10, and just as wrong. Feature 10 stopped the
*stock* being handed out twice. Nothing stopped the *demand* being served twice:

> Run one: `D1` asks for 10, 10 is available, 10 is confirmed and reserved.
> Run two: `MARD` still shows 10 because nothing has been withdrawn yet, less
> the reservation of 10, so nothing is available. `D1` is still open in `VBAP`,
> so it is read again as asking for 10 — and comes back with a shortfall of 10
> even though it was fully served an hour ago.

`ZCL_DEMAND_READER_NET` wraps any demand reader and takes off what earlier runs
already confirmed for that demand line, from `ZSTOCK_ALLOC_RES`:

- A line served in full drops out. It has nothing left to ask for, and leaving
  it in with a zero quantity would only be noise in the report.
- A line served in part asks for the remainder.
- Only runs that actually produced a reservation count. A run that was recorded
  but whose reservation was rejected has not served anything, and the demand is
  still genuinely open. That is what the `RESERVATION` column added in feature 9
  is for.

Both nettings are decorators over the same two interfaces, which is why the
engine, the strategies and the report needed no change for either.

### Feature 19 — one run at a time per material (done)

Two runs on the same material at the same time would each read the same
available stock and each give it away. The nettings do not help: both runs read
before either writes.

- `src/ezstock_alloc.enqu.xml`: the lock object, on `MARC` by material and
  plant. It lives in `/src/` because a real system needs it to generate the
  enqueue function modules.
- `sap-stubs/ezstock_alloc.fugr.*`: stubs of exactly those generated function
  modules, so the custom `CALL FUNCTION` is checked against the real signature
  and can be executed in tests. `CL_STUB_ENQUEUE` plays the enqueue server.
- `ZIF_ALLOCATION_LOCK` / `ZCL_LOCK_MATERIAL`: `ENQUEUE_EZSTOCK_ALLOC` in mode
  `E`, scope `1` — the lock belongs to this work process and there is no update
  task to hand it to.
- `ZCL_ALLOCATION_SERVICE->run` takes the lock after the authorization check and
  before anything is read, and gives it back on both the success and the failure
  path.

The failure path is the part worth the test. The obvious way to write it is
`CLEANUP`, and the transpiler silently drops the body of a `CLEANUP` block
(ANOMALIES.md 2k) — the lock would simply never come back and nothing would say
so. It is written as `CATCH`, release, re-raise instead, and a test runs a
failing allocation and checks the material was let go.

### Feature 20 — allocation horizon (done)

Without a horizon, an order due in eight months competes on equal terms with one
due next week. The priority strategy sorts by date so the near one wins the tie,
but the far one still consumes stock once it sorts ahead on priority.

`ZCL_DEMAND_WITHIN_HORIZON` drops demand due beyond `sy-datum + n` days. Two
edges are deliberate and tested:

- A requirement **in the past** stays. Overdue is the most urgent thing there is,
  not something outside the window.
- A requirement **without a date** stays. It is wanted as soon as possible, and
  dropping it would silently starve it forever.

The default is no horizon at all. How far ahead to commit stock is a business
decision, not something this code should invent, so it is a parameter on
`create_default( )` and on the selection screen rather than a number baked in.

### Feature 21 — test run (done)

Every SAP report that changes something offers a test run, and this one changes
rather a lot: it writes a result table and creates reservations.

`ZIF_ALLOCATION_SERVICE->simulate` does the same calculation as `run` and stops
there. `RUN_ID` and `RESERVATION` come back initial because there is nothing to
look up. Three decisions worth stating:

- It **still checks authorization**. A simulation answers the same question as a
  real run and should not answer it for a plant the user cannot see.
- It **does not take the lock**. A test run that blocked the real one would be
  worse than a test run working from slightly stale numbers.
- The report **says so on the first line**, and prints no run id or reservation,
  so nobody mistakes a test run for a real one. A test loops over every output
  line to make sure no run id leaks into a simulated report.

`P_TEST` defaults to **on**. Someone who runs this program without reading the
selection screen should get a preview, not a night of reservations.

### Feature 22 — a cancelled reservation reopens the demand (done)

The two nettings disagreed with each other, and the disagreement only shows up
after somebody intervenes.

`ZCL_DEDUCT_RESERVATIONS` reads `RESB` live, so deleting a reservation
immediately frees the stock again. `ZCL_DEMAND_READER_NET` read only
`ZSTOCK_ALLOC_RES`, which still said the demand had been served. Delete a
reservation — because the order changed, or somebody re-planned — and the stock
came back while the demand stayed permanently netted off. That line would never
be served again.

`already_allocated` now only counts a recorded run while its reservation still
exists in `RESB` and is not flagged for deletion. Both nettings are anchored on
the same live data, so they can no longer drift apart.

Two cases are tested because they are different in the database and identical in
consequence: a reservation flagged `XLOEK`, and one that is not in `RESB` at all.

### Feature 23 — an index for the access path (done)

`ZSTOCK_ALLOC_RES` is keyed by run and demand line, which is right for reading a
run back. Both nettings read it by **material and plant** instead, and that table
grows by one row per demand line per run and is never pruned. On a plant running
this nightly that is a full table scan that gets slower every night.

Secondary index `MAT` on client, material and plant.

Worth being clear about what is *not* verified: abaplint's `check_ddic` covers a
table's field list but not its indexes — an index naming a field that does not
exist passes without a word (ANOMALIES.md 3) — and the transpiler does not create
indexes at all, so no test says anything about this. It is written and reviewed
by hand.

The table growing forever is a real limitation and is deliberately left alone.
Housekeeping cannot simply delete old runs: the demand netting reads them, so
deleting a run whose reservation is still live would reopen demand that has
already been served. Anything safe here has to key off the reservation being
closed, and that is a feature of its own rather than a line in this one.

### Feature 24 — what has been delivered is no longer demand (done)

The third one in the family of features 10 and 18, and the last obvious one.
`VBAP-KWMENG` is the **cumulative** order quantity: it does not go down when the
goods leave. So an order for 10 that was delivered in full a month ago was still
read as 10 units of open demand, and would compete for — and win — stock it has
no claim on any more.

Feature 18 does not cover this. It nets off what *this solution* confirmed and
reserved; a delivery made straight from the sales order, which is the normal
case for anything allocated before this was installed or delivered without a
reservation, is invisible to it.

- `sap-stubs/lips.tabl.xml`: delivery items, with the reference to the sales
  order item they were created from.
- `ZCL_SO_DEMAND_READER` takes the delivered quantity off each item, and an item
  delivered in full drops out of the demand entirely.

Decisions worth stating:

- The netting uses **`LIPS-LGMNG`, the delivered quantity in the base unit of
  measure**, not `LFIMG` in the sales unit. Both sides of the subtraction are
  then in the unit everything downstream works in, and nothing depends on the
  delivery having been created in the same sales unit as the order.
- Only delivery items whose predecessor is a **sales order** count
  (`LIPS-VGTYP = 'C'`). `VGBEL`/`VGPOS` can equally point at a purchase order or
  a stock transport order, and a document number that happens to collide must
  not net off demand that was never delivered.
- It is **delivered**, not **goods issued**. Once a delivery exists, that part of
  the order is no longer waiting for stock — it is on a document of its own with
  its own requirement. Waiting for the goods issue would hand the same stock out
  twice in the window between the two.
- A delivery quantity that is not positive takes nothing off, the same guard the
  other two nettings have.

`materials_with_demand` is deliberately *not* netted the same way: deciding
whether a material has anything left would mean converting every item in the
plant to base units, which is the expensive part of reading demand and can fail
on master data. The interface now says what it really is — a candidate list,
where the definitive filter is `read_open_demand`. A material that is listed and
then comes back with nothing costs an empty run and reserves nothing. This was
already true of the netting decorator from feature 18, which passes the material
list straight through; now it is written down.

### Feature 25 — a complete delivery line takes all of it or none (done)

`VBAP-KZTLF = 'C'` says the customer takes the item in one delivery. Confirming
6 of 10 for such an item is worse than confirming nothing: the 6 cannot ship, so
the stock sits reserved against a line that will not move, while a line that
*could* have shipped goes short. Every allocation up to here did exactly that.

- `ty_demand` gained `COMPLETE`, and `ZCL_SO_DEMAND_READER` sets it from `KZTLF`.
- `ZCL_ALLOC_ALL_OR_NOTHING` wraps any `ZIF_ALLOCATION_STRATEGY`: it lets the
  strategy distribute the stock, and if a complete-delivery line came back
  holding a part of what it asked for, that line is dropped and the whole
  quantity offered again to the rest. It repeats until no such line is left.

Why a decorator around the strategy rather than a rule inside each strategy:
which lines may be served in part is a property of the **demand**, not of the
distribution rule, and both strategies need it. `create_default( )` therefore
wraps whatever strategy it was given, including one passed in from outside.

The details that took thought:

- **One line is dropped per pass, not all of them at once.** Dropping every
  partially served line together over-corrects: freeing one line's stock is
  often enough to complete another. The loop is bounded by the number of demand
  lines, so it terminates, and the worst case is a pass per line.
- **Which line goes first.** The one furthest from complete — it frees the most
  and is the least likely to fit however much is freed later. On a tie, the line
  the strategy served *last* goes, which is the one the strategy favoured least.
  That is what makes the fair share case come out right: two equally short lines
  tie, the lower priority one is dropped, and the higher priority one is then
  confirmed in full.
- A line that got **nothing** is not a partial line and needs no second pass.
  Neither is a line confirmed in full. Only `0 < confirmed < requested` is.
- The dropped lines are answered too, with `CONFIRMED = 0` and the **whole**
  quantity as shortfall. The strategy contract is one allocation line per demand
  line, and a test pins that a dropped line is answered exactly once.

Not implemented, and deliberately: `VBAK-AUTLF`, complete delivery for the whole
**order**. Honouring it means all items of the order must be confirmable
together, and the items of one order are generally different materials — which
this solution allocates in separate runs, under separate locks, in whatever
order the material list comes out. An all-or-nothing rule spanning runs cannot
be decided inside one run, so pretending to support it would be worse than
leaving it out.

### Feature 26 — housekeeping, and one place that knows what a live reservation is (done)

Feature 23 left `ZSTOCK_ALLOC_RES` growing by a row per demand line per run,
forever, and said why the obvious fix is wrong: the demand netting reads that
table, so deleting a run whose reservation is still live would reopen demand that
has already been served. The rule that *is* safe follows from what the netting
actually counts:

> A recorded run is doing work exactly while its reservation is still there. A
> run that never got a reservation, or whose reservation has been deleted, is
> already ignored by the netting — deleting it changes no future allocation.

`ZCL_ALLOC_HOUSEKEEPING->run( iv_werks, iv_keep_days, iv_test )` deletes exactly
those, and only once they are older than the retention time. `ZSTOCK_ALLOC_REORG`
is the program, and like the allocation report it **defaults to a test run** and
then says how many runs it would have removed.

- The retention time is what keeps a **rejected reservation** retriable: feature 9
  writes the result before reserving precisely so a failed reservation can be
  looked up, and deleting that record the same night would defeat it. Nothing
  recorded today is ever removed, whatever the parameter says — a negative number
  of days is clamped rather than trusted.
- The cut-off is worked out in **UTC**, because `CREATED_AT` is written with
  `GET TIME STAMP`, which is UTC. Comparing a local midnight against UTC stamps
  would silently shift the boundary by the time zone offset.
- Housekeeping **checks authorization** on the plant, with the same object a run
  checks. Removing the record of an allocation is a change to the plant's data.
- It works **per run**, not per row. A run covers one material in one plant, so
  every row of it answers "is this still holding anything" the same way, and a
  run of three demand lines is one decision and one `DELETE`.

The interesting part is what this forced. "Is this reservation still there" was a
private method of `ZCL_DEMAND_READER_NET`, and housekeeping needs the same
question answered the same way — feature 22 exists precisely because two places
disagreed about it. So it moved out into `ZIF_RESERVATION_READER` /
`ZCL_RESERVATION_READER`, and the netting decorator now takes one. Two callers,
one `SELECT`, no room for drift. The netting gained a constructor parameter,
which is the price of it.

What is still not cleaned up, and why it is fine: a run whose reservation exists
but has been **fully withdrawn** is kept forever by this rule. The goods have
gone, so the reservation holds no stock any more, but the record is what stops the
demand being served twice. Since feature 24 the delivered quantity nets the demand
off anyway, so such a line is no longer open on the order — meaning the record is
belt and braces rather than load bearing. Deleting it would need the withdrawal
to be checked against the order, which is a bigger question than housekeeping.

### Feature 27 — stock transport orders compete too (done)

Feature 3 claimed the demand seam would take another source: "stock transport
orders and planned independent requirements can be added behind the same
interface". Nothing had ever tested that claim, and until it was tried the
solution was quietly wrong for any plant that supplies another one — a transfer
takes stock out of the plant exactly like a customer order, and it was invisible.

- `sap-stubs/ekko.tabl.xml`, `ekpo.tabl.xml`, `eket.tabl.xml`: purchasing
  document header, item and schedule lines.
- `ZCL_STO_DEMAND_READER`: open transfers out of the plant.
- `ZCL_DEMAND_SOURCES`: several `ZIF_DEMAND_READER`s read as one list. Stock is
  one pool, so everything competing for it has to reach the strategy together.

What the reader had to get right:

- **The supplying plant is on the header** (`EKKO-RESWK`), and that is the plant
  whose stock the transfer consumes. `EKPO-WERKS` is the *receiving* plant and is
  deliberately not what is filtered on — filtering on it would allocate the
  wrong plant's stock, which is the one mistake here that would be silent.
- **Open quantity comes from the schedule lines**, `EKET-MENGE - EKET-WAMNG`.
  `WAMNG` is the quantity already issued, so a transfer half sent asks for the
  remainder, exactly as feature 24 does for deliveries. An item flagged
  `ELIKZ` (delivery completed) or `LOEKZ` is closed whatever the quantities say.
- **An item with no schedule lines still counts**, at its full order quantity and
  with no date. Taking it as nothing would silently lose real demand, and "no
  committed date" already means "as soon as possible" to the horizon filter
  (feature 20).
- `EKET` carries no material or plant, so it is joined to `EKPO` to stay
  selective, and which of those lines belong to a transfer *out of this plant* is
  decided against the item list. Two two-table joins rather than one three-table
  join, which is the shape the transpiler is known to handle.
- **A transfer has no delivery priority.** SAP has no field for it, so where
  internal transfers rank against customer orders is a constructor parameter,
  defaulting to the middle of the range: ahead of an order with no priority set,
  behind an urgent one. Inventing a priority from the document would be making
  the business decision on the customer's behalf.
- **The demand id is marked.** A sales order line is `VBELN` + `POSNR`; a
  transfer line is `'P'` + `EBELN` + `EBELP`, which is the same 16 characters. Two
  documents from different number ranges can carry the same number, and an
  unmarked id would let a transfer net off a sales order line in
  `ZSTOCK_ALLOC_RES`. The marker is a letter, so it cannot collide with the
  all-digit sales order form.

The wiring moved as well. `ZCL_ALLOCATION_SERVICE=>create_default_demand( )` is
now the one place that knows which sources exist, and
`ZCL_ALLOCATION_MASS_RUN=>create_default( )` builds the whole plant wide run, so
`ZSTOCK_ALLOCATION` no longer assembles half an object graph of its own. That
mattered rather than being tidiness: the program built its own demand reader for
the material list, and a material that only a transfer is waiting for would have
been left out of a plant wide run. Two tests go through the real default wiring
against real fixtures — one that a transfer is confirmed, one that it is covered
by the plant list — because the classes were all correct in isolation and the
wiring is what would have been wrong.

### Feature 28 — a requirement is a schedule line, not a document item (done)

Up to here a sales order item was one requirement, for its whole quantity, on
`VBAK-VDATU` — the date the *order* asks for. Both halves of that are wrong:

- The date an item is wanted lives on its **schedule lines** (`VBEP-EDATU`), and
  items of one order routinely have different ones. Using the header date made
  the horizon (feature 20) and the date tie-break in both strategies work off a
  number that was often not the item's date at all.
- An item asking for 4 in January and 3 in March is **two** requirements. As one
  line of 7 it either competes entirely inside a 30 day horizon or not at all,
  and either answer is wrong.

So `ty_demand_id` grew from 16 to 24 characters and now goes down to the schedule
line, and both readers return one demand line per schedule line:

| Source                | Demand id                                     |
| --------------------- | --------------------------------------------- |
| Sales order           | `VBELN`(10) `POSNR`(6) `ETENR`(4)             |
| Stock transport order | `'P'` `EBELN`(10) `EBELP`(5) `ETENR`(4)       |

`ZSTOCK_ALLOC_RES-DEMAND_ID` grew with it, and the report's first column with
that. The offsets are fixed and written out, so a short document number can never
shift the item or the schedule line, the same reason feature 3 used offset writes
rather than a string template.

Decisions worth stating:

- **An item with no schedule lines is still one requirement**, for the whole
  order quantity, on the order's date, with schedule line `0000`. That is the old
  behaviour, kept as the fallback rather than dropped: `VBEP` missing is a
  master data oddity, not a reason to lose demand. The same holds for a purchase
  order item without `EKET` lines.
- **Delivered quantity is counted against the earliest schedule lines first.**
  `LIPS` records what has been delivered per *item*, not per schedule line, and
  the goods leave in date order — so an item of 4 + 3 with 5 delivered has
  nothing left on the January line and 2 on the March line. Spreading the
  delivered quantity evenly, or against the last line, would leave a requirement
  open in the past and satisfy one in the future.
- The schedule lines of an item are sorted **by date, then by counter**, and the
  delivered quantity is consumed in that order. Schedule line counters are
  normally in date order, but nothing guarantees it, and the rule that matters is
  the date.
- `VBEP` carries no material, so it is joined to `VBAP` to stay selective, the
  same shape as `EKET` to `EKPO` in feature 27.

One consequence to be honest about: demand ids recorded by an earlier version are
16 characters and will not match the new ones, so the demand netting of
feature 18 will not recognise those runs. The effect is bounded — the *stock* is
still held back by the reservations those runs created (feature 10), so the
demand reads as open but there is nothing free to serve it, which shows up as a
shortfall rather than as stock handed out twice. A site that cares can convert
`ZSTOCK_ALLOC_RES` by appending `0000` to the ids of runs whose items have no
schedule lines; there is no general conversion, because the old id genuinely does
not say which schedule line was served.

### Feature 29 — the material master is read once, not once per quantity (done)

Feature 28 turned one conversion per order item into one per schedule line, and
`ZCL_UNIT_CONVERTER` went to the database twice for every one of them —
`MARA` for the base unit and `MARM` for the factor, with the same answer every
time. A nightly run over a plant does that thousands of times for a handful of
distinct materials.

The converter now keeps what it has read in two sorted tables, keyed by material
and by material and unit. Notes on the shape of it:

- The buffer is **on the instance**, not static. It therefore lasts exactly as
  long as the object that owns it, which is one run, and nothing is carried
  between runs or between programs — the trap with a static buffer is a report
  that answers from master data somebody changed an hour ago. A test pins this by
  taking the master data away and showing that a *fresh* converter refuses while
  the one that has already read it still answers.
- **Nothing that failed is buffered.** A missing material, a unit that is not
  defined and a zero denominator all still raise every time they are asked. They
  are master data errors, and a run must not turn one into a cached answer.
- Reading the same master data twice inside one run and getting two different
  answers would be worse than reading it once: the second half of an allocation
  would be worked out against a different base unit than the first.

`create_default_demand( )` hands the same converter to both demand readers, so
sales orders and transfers of the same material share what has been read.

### Feature 30 — allocate only from the storage locations that may be used (done)

The engine pools the stock of every storage location in the plant, and there was
no way to say that some of it is not up for allocation. Plants routinely have
locations whose stock must not be given away: returns waiting to be inspected, a
shipping area holding goods that are already picked, a location a customer owns.

`ZCL_STOCK_IN_LOCATIONS` wraps a `ZIF_STOCK_READER` and keeps only the lines of
the locations it was given. Three decisions:

- **An empty list is no restriction, not nothing allowed.** A plant that has not
  said which locations to use means all of them, which is what every existing
  installation would expect after upgrading. The opposite default would silently
  allocate nothing.
- It is a **list, not a rule read from the master data.** `MARD-DISKZ` looks
  tempting — it is SAP's own "storage location excluded from MRP" — but that is a
  *planning* indicator and does not say anything about availability, so acting on
  it would be inventing policy. Which locations may be allocated is a decision
  about the plant, so the decision is an input.
- It sits **innermost**, right around the `MARD` reader and inside the netting of
  feature 12, so the deductions come off what is left after the filter. Worth
  being explicit about the consequence: reservations and safety stock are plant
  totals and are not tied to a location, so restricting to one location and then
  taking off the whole plant's reservations under-allocates rather than
  over-allocates. That is the safe direction, and it is the same simplification
  feature 10 already documents.

`ZSTOCK_ALLOCATION` gained one storage location on the selection screen, which
`create_default( )` turns into a one entry list; a caller wiring the classes
itself can name as many as it likes. A test goes through the real default wiring
and shows the same stock being confirmed when its location is named and refused
when another one is.

### Feature 31 — look at what was decided (done)

`ZSTOCK_ALLOC_RES` was write-mostly: the run wrote it, the demand netting read it
back, and nobody could look at it. After a night's run a planner wants to know
what the plant got and what is still short, and `SE16` is not an answer.

- `ZIF_ALLOCATION_STORE->latest_per_material( )` reads the plant's recorded
  lines and keeps, per material, only the lines of its **newest** run. A material
  is allocated again and again, and only the last answer still stands.
- `ZCL_ALLOC_RESULT_REPORT` lays that out — a block per material headed by the
  run and reservation that decided it, the same four columns the allocation
  report uses, and totals over the whole display. `ZSTOCK_ALLOC_DISPLAY` is the
  program, with a "only lines that are short" checkbox, which is the list
  somebody chasing a backorder actually wants.
- It **allocates nothing and changes nothing**, so it can be run at any time,
  and it does not take the lock.

Two decisions worth stating:

- The newest run per material is picked **in ABAP, not in SQL**. It is a maximum
  per material, which a `WHERE` clause cannot express, and `GROUP BY` with
  `ORDER BY` does not parse (ANOMALIES.md 4). The rows of one plant are what
  housekeeping keeps bounded, so reading them and picking here is honest.
- The display checks authorization for **activity 03**, not 02.
  `ZCL_AUTHORITY_PLANT` took the activity as a constructor parameter for it:
  somebody who may see the answer need not be allowed to work it out again, and
  the interface stayed as it was — which activity to ask for is a property of the
  implementation, not of the seam.

A testing lesson, paid for by a failing assertion: ABAP's `CS` **ignores case and
trailing blanks**, so counting the lines that contain `'Material '` also counted
the heading "last recorded run per material", and counting `'SHORT'` also counted
the column heading "Shortfall". Assertions over rendered text have to name
something that cannot occur by accident. The test class also uses a plant of its
own rather than 1000: a display that reads a whole plant would otherwise depend
on what every other test class left behind.

### Feature 32 — no single customer takes the whole pool (done)

One large order can take everything a plant has, whichever strategy is in use:
priority serves it first because it is urgent, and fair share gives it most of
the stock because it asked for most. Neither is what a business wants when the
order is one customer's and there are twenty others waiting.

`ZCL_ALLOC_CUSTOMER_CAP` wraps any strategy and offers it at most a share of what
is available per customer. `ty_demand` gained `CUSTOMER`, which
`ZCL_SO_DEMAND_READER` fills from `VBAK-KUNNR`.

- **Within its share a customer is served in the order the strategies serve
  demand**, so what it loses is its least urgent lines, whole. The first version
  scaled a customer's lines proportionally and a test caught what that means: a
  customer with two lines of 50 and a share of 50 ended up with 25 and 25, two
  half lines that may well both be unshippable, instead of one line served in
  full. Cutting back from the far end needs no division either, so nothing is
  truncated.
- **The share of the pool is truncated to whole thousandths**, with `DIV`: a
  percentage of what is available must never come out above it. Same reasoning as
  feature 5, and a test pins a third of ten at `3.300`.
- **The answer is about the demand as it stands.** The strategy is handed a
  reduced demand, so the decorator puts the real requested quantity back into the
  result and works out the shortfall against it. Otherwise a line held back by
  the cap would look fully served, and the shortfall a planner chases would be
  hidden by the very rule that caused it.
- **A requirement with no customer is not part of anybody's share.** A stock
  transport order has no customer, and lumping every requirement without one
  together would cap them as if they were the same party.
- A line held back entirely stays in the demand with nothing to ask for, so the
  strategy still answers it and every demand line is still answered exactly once.

Where it sits matters: **inside** the complete delivery rule of feature 25. A line
that may only ship in full and is held back by its customer's share can never
ship, so the rule outside sees it fall short of the whole quantity and drops it,
freeing the stock for somebody who can use it. The other order would confirm a
part of a line that cannot leave.

It is **off by default** (`0` percent means no cap), and it is a percentage rather
than a quota table. SAP's own product allocation keeps quotas per customer,
material and period in its own tables and is the richer mechanism; this is a
deliberately simple version of the same idea, behind the strategy seam, so a site
that needs the real thing writes one class and swaps it in.

### Feature 33 — a delivery that has not left still holds its stock (done)

The hole feature 24 opened and did not close. Once a delivery exists, that part
of the order stops being open demand — the note there says so in as many words:
"it is on a document of its own with its own requirement". Nothing represented
that requirement. The goods issue has not been posted, so the stock is still in
`MARD`, and the order that asked for it no longer competes for it. Every run
handed that stock to somebody else, and the picker then found the shelf empty.

- `sap-stubs/likp.tabl.xml`: delivery headers, and `LIPS` gained `WBSTA`.
- `ZCL_DEDUCT_DELIVERIES`, a `ZIF_STOCK_DEDUCTION` like the other two, holds
  back what is on deliveries waiting for their goods issue.

The seam from feature 12 paid for itself here: one class, one reason, added to
the list in `create_default( )`. Nothing else changed.

Decisions worth stating:

- **Only outbound deliveries** (`LIKP-VBTYP = 'J'`). `LIPS` also carries inbound
  deliveries against purchase orders (`'7'`) and returns from customers (`'T'`),
  both of which bring stock *into* the plant. Holding those back would deduct
  goods that have not arrived from stock that is there — the sign is the wrong
  way round. This is what the `LIKP` stub is for; the item alone cannot say
  which direction it points.
- **`WBSTA <> 'C'`, not `WBSTA = 'A'`.** A posted goods issue has already taken
  the stock out of `MARD`, and only that releases the commitment. Every other
  value — including a status that is not set yet — means the goods are still
  there and spoken for. A test pins the blank case, because that is the value a
  reader is most likely to get wrong.
- **`LGMNG`, the delivery quantity in the base unit**, the same field and the
  same reasoning as feature 24. Nothing here has to convert anything.
- It reads deliveries **per plant, not per storage location**, like the other
  two deductions. `ZIF_STOCK_DEDUCTION` has no storage location in its
  signature, and feature 30 restricts which locations are pooled *before* the
  deductions come off the total. A run restricted to one location can therefore
  hold back a delivery picked from another. Making that exact means the
  interface has to carry the locations, which is a change to every deduction —
  worth doing when a site actually runs location-restricted allocations, and
  written down here so the next person does not have to rediscover it.

Where it can hold too much back, and why that is the right way to be wrong: a
sales order line this solution reserved (feature 10) and that has since been
delivered is counted twice — once as an open reservation in `RESB`, once as an
open delivery item. The delivery is not created *against* the reservation, so
nothing links them, and only a withdrawal posted against the reservation raises
`RESB-ENMNG`. Both deductions are of stock that is genuinely spoken for, so the
error is holding stock back rather than promising it twice, which is the
direction to err in. The delivery half clears itself at the goods issue. The
reservation half is the open end of feature 26 — a reservation whose goods left
on another document stays open — and closing it means matching reservations to
the demand they were written for, which is a feature of its own.

### Feature 34 — stock on its way is supply too (done)

Everything up to here allocated what was on the shelf this morning. A line
wanted in six weeks competed for it against a line wanted tomorrow, and the
container arriving next Tuesday did not exist. Both halves of that are wrong in
the same way: allocation is a question about a **timeline**, and the solution
only knew about one instant of it.

- `ZIF_SUPPLY_READER` answers "what is there to give away, and from when" as a
  list of quantities per availability date.
- `ZCL_SUPPLY_ON_HAND` wraps the stock reader — including all the deductions —
  and reports the plant total as one element.
- `ZCL_SUPPLY_RECEIPTS` reads open purchasing documents arriving in the plant,
  schedule line by schedule line, less what has already been received.
- `ZCL_SUPPLY_SOURCES` composes them, exactly as `ZCL_DEMAND_SOURCES` does on
  the other side.
- `ZCL_ALLOCATION_ENGINE` walks the supply in date order instead of adding it
  all up.

The engine's loop is the feature. Each day of supply is offered, through the
same strategy as ever, to the demand that can still wait for it; what nobody
takes stays in the pool for the next day, and a line served in part comes back
for the rest of it. That keeps the strategy seam untouched — priority, fair
share, the customer cap and the complete delivery rule all work per day of
supply and needed no change.

Decisions worth stating:

- **Stock on the shelf carries no date at all**, not today's. Dating it today
  would make an overdue line unservable from stock that is physically there,
  because the rule below would say the stock "arrives" after the line was
  wanted. What is on the shelf has been there since before any requirement was
  raised, and the initial date says exactly that, and sorts first.
- **A receipt can only serve demand wanted on or after it arrives.** The other
  way round is a promise that cannot be kept: confirming a line for the 1st out
  of a container landing on the 10th tells a planner the goods are covered when
  they are not. Such a line comes back as short instead, which is the answer
  somebody can act on. SAP's own ATP would give it a later *confirmation date*
  rather than nothing — that is feature 35.
- **A requirement without a date is wanted now**, so only stock on hand can
  serve it. Same rule, no special case: an undated line and an overdue line are
  in the same position.
- **Everything arriving on one day is one pool.** Two receipts landing on the
  same date, offered one after the other, would let fair share split what it
  would otherwise have handed out whole, and would give the complete delivery
  rule two chances to drop a line that one pool would have covered.
- **A receipt with no date is not supply.** A purchasing item with no schedule
  line has nothing saying when it arrives, and the only way to place it on the
  timeline would be to call it available now — promising stock nobody has
  committed to a day. It is left out. Note the demand readers do the opposite
  with an undated requirement and keep it: both choices err towards confirming
  less, which is the direction to err in.
- **A returns item brings nothing in**, so `EKPO-RETPO` items are excluded, and
  `EKPO-WERKS` is the plant filter — the receiving plant, where the STO demand
  reader filters on `EKKO-RESWK`, the supplying one. A stock transport order is
  therefore read from both ends: demand in the plant it leaves, supply in the
  plant it arrives at, which is what it is.
- **What has been received is not read twice.** `EKET-WEMNG` is off the
  receipt, because that part of it is in `MARD` and comes back as stock on hand.

The result is unchanged in shape: one line per demand line, confirmed and
short. What it does not yet say is *when* a confirmed line can be served, which
now matters, because it is no longer always "now".

### Feature 35 — say when a confirmed line is covered (done)

Feature 34 ended by saying what it had left undone: a line could now be
confirmed out of a receipt that has not landed, and the answer looked exactly
like one confirmed out of stock on the shelf. "Confirmed 10" is a different
sentence when the 10 arrive in three weeks, and a planner cannot tell the two
apart. So the answer carries the day.

`ty_allocation` gained `AVAIL_DATE`, `ZSTOCK_ALLOC_RES` a column for it, and
both reports a column. The engine already knew the day each part of a
confirmation came from; it only had to keep it.

- **It is the latest day that contributed**, not the earliest. A line covered 4
  off the shelf, 3 on the 1st and 3 on the 10th is not there until the 10th —
  the day it is complete is the day it can ship.
- **Initial means "already there"**, the same convention `ty_supply` uses, and
  it is what a line served entirely from stock gets. The reports write it as
  `now`; the raw date field stays empty rather than being stamped with the run
  date, so re-reading an old run does not claim the stock was there on a day
  nobody checked.
- **A line that was confirmed nothing has no day at all**, and the reports leave
  the column empty rather than printing `now` for stock it never got.
- `AVAIL_DATE` is never later than `REQ_DATE`, because feature 34 does not serve
  a line from supply arriving after it is wanted. That makes the column a
  promise a planner can act on rather than a warning to chase.

The strategies were not touched. They answer with the date field initial, and
the engine — the only part that knows which day of supply paid for what — fills
it in when it composes the result. That is the same split as `REQUESTED`: the
strategy says how much, the engine says what it means.

The reservation still carries `REQ_DATE`, not this. A reservation says when the
goods are *wanted*, which is what SAP schedules against; when they turn up is
the allocation's own bookkeeping.

### Feature 36 — a plant's settings live in Customizing (done)

Everything the run does differently per site — priority or fair share, how far
ahead to look, which storage location, the customer cap, how long a recorded run
is kept — was on two selection screens and nowhere else. A nightly job carried
them in a variant per plant, which is a copy of the same decision in as many
places as there are plants, invisible to anybody reading the system and not
transportable with the rest of the configuration.

`ZSTOCK_ALLOC_CFG` is one row per plant, delivery class `C`, and
`ZCL_ALLOC_CONFIG` reads it behind `ZIF_ALLOC_CONFIG`. Both programs default to
**Settings come from the plant**; unticking it hands the screen back.

- **A plant with no row is not an error.** It gets the defaults, which are the
  ones the parameters had before this existed, so nothing changes for a site
  that never configures anything. Customizing then only has to say what differs
  from the default, which is what Customizing is for.
- **A setting that cannot be honoured is corrected, not obeyed.** A negative
  horizon is no horizon, a negative cap is no cap, and a cap above 100 percent
  is 100 — a share of the pool cannot be more than the pool. A nightly run must
  not stop because somebody typed a minus, and a fixed-value domain on the
  field is the DDIC's half of the same job.
- **Zero retention days is a real answer**, meaning keep nothing beyond today,
  so the 90 day default only applies to a plant with no row at all. The
  distinction only exists because the field is a number where zero is a value:
  the strategy and the storage location have no such ambiguity.
- **The keep days are read here but clamped in housekeeping**, which owns that
  rule and already had it. Two places would be two rules.
- **The programs stay glue.** They read the settings and pass them to the same
  factory as before, so nothing in the object graph knows a configuration table
  exists. Tests cover `ZCL_ALLOC_CONFIG`; the programs have no logic left worth
  testing.

Not done, and deliberately: a maintenance view. `SE11` can generate one for the
table in a minute and the generated objects belong to the system that generates
them, not in a repository that has to install cleanly with abapGit.

### Feature 37 — a run is a unit of work (done)

Nothing in the solution had ever committed anything. `INSERT zstock_alloc_res`
and `BAPI_RESERVATION_CREATE1` both sat in the caller's LUW waiting for
somebody else to make them real, and what made them real was the implicit
commit at the end of the report. That is not an integration into an SAP system,
it is a program that happens to work when run interactively.

Three things were wrong with it, and all three are the same thing:

1. **A BAPI is committed the way SAP says to commit it.** `BAPI_RESERVATION_CREATE1`
   puts its work on the update task; `BAPI_TRANSACTION_COMMIT` is what runs it.
2. **A plant wide run reads what it has already written.** The open reservation
   deduction and the demand netting both read the database, so material two of
   a run has to see the reservation material one created. Without a commit that
   waits, it does not — and the same stock is offered twice in one job.
3. **A job that dies half way leaves whatever it had written.** Whether that is
   an answer or half of one was, until now, up to chance.

`ZIF_UNIT_OF_WORK` / `ZCL_UNIT_OF_WORK` wrap the two transaction BAPIs, the
service commits, and `ZCL_ALLOC_HOUSEKEEPING` commits each removal.

- **`WAIT = 'X'`.** Point 2 is the whole reason: the commit returns only once the
  update has been written, so the next material of the same job reads a
  database that includes this one. It costs a round trip per material and buys
  a plant wide run that cannot give the same stock away twice.
- **Two commits per material, not one.** The recorded decision is committed
  before the reservation is attempted, which is what makes feature 9's promise
  true at last: a rejected reservation leaves a run somebody can look up and
  retry. It holds no stock back on its own — the netting only counts a run whose
  reservation is live (feature 26) — so the intermediate state is safe. The
  reservation and the link to it are then the second unit: a reservation nothing
  points at would be stock held back that no run admits to holding.
- **A failed run rolls back.** What it managed to write is half an answer, and
  the next run would read it as a whole one. The rollback goes where the lock is
  given back, in the `CATCH`, because the transpiler drops `CLEANUP` blocks
  (ANOMALIES.md 2k).
- **A simulation commits nothing.** It writes nothing, and calling a commit
  anyway would make somebody else's uncommitted work durable — a report that
  changes nothing must not be the thing that saves your unrelated changes.
- **The lock stays scope 1**, and the reason is now interesting rather than
  incidental: handing the lock to the update task would release it at the run's
  own commit, which happens *before* the run is over. The run keeps the lock
  across its commit and gives it back itself.
- **Housekeeping commits per run**, so a reorg of a plant with a year of history
  that is stopped half way keeps the removals it managed.

`sap-stubs/bapi_transaction.fugr.*` joins the reservation stub in
`exclude_filter` for the same reason it is there: both have a parameter called
`RETURN` and the transpiler cannot declare it (ANOMALIES.md 2f). The unit tests
double both BAPIs with `cl_function_test_environment`, so the calls are still
checked against the real signatures by abaplint and still executed by a test.

### Feature 38 — what the plant is about to make is supply too (done)

Feature 34 put stock on its way onto the timeline, but only the stock somebody
is buying. A plant that makes what it sells had nothing on the timeline beyond
what was on the shelf: every production order in the works was invisible, so a
line wanted the week after the order finishes came back short while the goods
were being made for it. The two sources are the same kind of thing — a
quantity, a day, a document somebody has committed to — and now they read the
same way.

`ZCL_SUPPLY_PRODUCTION` reads `AFPO` for the item, `AFKO` for the dates,
`AUFK` for the order master and `JEST` for the statuses, and answers
`ZIF_SUPPLY_READER` like every other source. Stubs for the four tables joined
`sap-stubs/`.

- **`AFPO-DWERK` is the plant**, the plant the order *delivers into*, which is
  not always the plant it is produced in. Supply belongs where the goods land,
  the same reasoning that made `EKPO-WERKS` the filter for a receipt.
- **The open quantity is `PSMNG - WEMNG`.** What has already been delivered to
  stock is in `MARD` and comes back as stock on hand; counting it here as well
  would give it away twice. Same rule as `EKET-WEMNG`, and the reason a
  finished order contributes nothing rather than everything.
- **Three dates, in order of how much they promise**: the item's own delivery
  date `AFPO-LTRMP` is what the order says about this material, `AFKO-GLTRS` is
  what scheduling worked out for the order, `AFKO-GLTRP` is what somebody asked
  for when it was created. The first one that is filled wins. An order with
  none of them is left out — placing it on the timeline would mean calling it
  available now, which is feature 34's rule for a purchasing item without a
  schedule line.
- **An unreleased order is still a receipt.** MRP plans against it, the
  material is expected on the day it says, and leaving it out would hold stock
  back from the very demand the order was created to cover. Release is a
  statement about whether work may start, not about whether the goods are
  coming.
- **What does take an order out of supply** is the deletion indicator on the
  order master, the delivery completed indicator on the item, and an active
  system status of technically complete, closed or flagged for deletion. Those
  three are `I0045`, `I0046` and `I0076` in `JEST`, because there is no field
  on the order that carries them, and `JEST-INACT` marks a status the order
  used to have and no longer has. An order in any of those states will not
  deliver the rest of its quantity however much of it is still open, and
  confirming against it promises goods nobody is going to make.
- **`JEST` is read once for the material, not once per order.** It carries no
  material or plant of its own, so it is joined through `AUFK` to `AFPO` to
  stay selective — the same shape as the `EKET` read, and the same reason
  feature 29 gave for buffering the material master: a plant wide run must not
  turn one read into one read per document.
- **Every item of an order counts on its own day.** A production order can
  deliver its material in more than one item, and merging them would flatten
  two different days into one, which is what feature 34 refused to do with two
  schedule lines.

Nothing else changed. The engine already walks whatever the supply sources hand
it in date order, so a production order competes with a purchase order and with
the shelf without knowing the others exist — which is what the composition was
for.

### Feature 39 — a blocked line takes no stock (done)

The run has excluded delivery blocked *orders* since feature 3, because
`VBAK-LIFSK` was the field that happened to be there. A delivery block is not
only a header field: it sits on the header, on the item (`VBAP-LIFSP`) and on a
single schedule line (`VBEP-LIFSP`), and the two lower ones were being read as
ordinary demand. A blocked line then took stock off the pool, kept it out of
the reservation of a line that could actually ship, and reported a confirmed
quantity for goods nobody was going to send.

Wherever the block sits, it says the same thing, and now it is treated the same
way.

- **The item block is a `WHERE` clause**, in both `READ_ITEMS` and
  `MATERIALS_WITH_DEMAND` — a material whose only item is blocked has nothing
  to allocate, so a plant wide run should not pick it up at all and write an
  empty result for it.
- **The schedule line block is not a `WHERE` clause**, and that is the only
  interesting part of this feature. Feature 28 gave an item with no schedule
  lines a synthetic one for the whole order quantity, on the order's date.
  Filtering blocked lines out in the `SELECT` would make an item whose every
  line is blocked look like an item with no lines, and it would come back
  asking for its full quantity — the opposite of what the block says. So the
  lines are read as they are, the "does this item have schedule lines" question
  is answered first, and the blocked ones are dropped afterwards.
- **A block on one date says nothing about the others.** An item with a blocked
  line in March and an open line in January keeps the January line: the block
  is on a quantity on a day, not on the item.
- **What has been delivered is still netted against the earliest lines**,
  blocked or not, which is feature 24's rule and unchanged. Goods that have
  already gone out went out before the block existed.

Nothing was added: two fields in the `WHERE` clauses, one loop, and two columns
in the stubs. The reason it is worth a feature of its own is that all three
blocks were one rule pretending to be one field.

### Feature 40 — a run that nobody watched can still be read back (done)

Everything the solution had to say about a run, it wrote to a list. That is
fine for somebody sitting in front of it and useless for the thing this is
built to be: a job that runs at four in the morning. The spool is gone in a
week, nobody reads it while it is there, and the one question anybody ever
asks afterwards — *why did material X get nothing on Tuesday?* — had no answer
in the system at all.

`ZIF_ALLOCATION_LOG` and `ZCL_ALLOC_LOG_BAL` write the application log,
`BAL_LOG_CREATE` / `BAL_LOG_MSG_ADD` / `BAL_DB_SAVE` under the object
`ZSTOCK_ALLOC`, so a night's run is in `SLG1` for as long as the log retention
says. Messages 008 to 011 join the message class; stubs for the three function
modules, `BAL_S_LOG`, `BAL_S_MSG`, `BALLOGHNDL` and `BAL_T_LOGH` join
`sap-stubs/`.

- **The log cannot fail the run.** Nothing on the interface raises, and every
  BAL call that comes back with a non-zero `SY-SUBRC` clears the handle and
  stops the logging for good. A run that has already reserved stock must not
  be reported as failed because its diary was not writable, and a plant whose
  every material would log the same failure must not pay a round trip per
  material to be told so again.
- **No log object, no log.** `ZSTOCK_ALLOC` has to exist in `SLG0`, which is
  Customizing and not a repository object — the same call feature 36 made
  about a maintenance view. Without it `BAL_LOG_CREATE` refuses the header and
  the run carries on exactly as it did before this feature.
- **A test run keeps no diary.** It changes nothing, so there is nothing to
  account for; and `BAL_DB_SAVE` needs a commit, which is precisely what
  feature 37 said a simulation must never issue.
- **A material that got everything is one line; one that fell short is two.**
  The second is a warning at a problem class of its own, because SLG1 filters
  on exactly that, and the whole point of opening the log is to find the lines
  that did not work out. A failed material is an error at the highest class,
  carrying the reason.
- **The reason is spread over three message variables.** `BAL_S_MSG` holds
  fifty characters per variable and an exception text is a sentence. It goes
  through a fixed length field first so a short reason pads instead of reading
  past its own end.
- **Saving is its own unit of work.** `BAL_DB_SAVE` puts the log on the update
  task like everything else, so `ZIF_UNIT_OF_WORK` commits it after the last
  material — and a commit that is refused there is swallowed, because
  everything the log describes is already durable.
- **`ZCL_ALLOC_LOG_NONE` is a null object**, which is what the report tests and
  a system without the SLG0 object use. Its four methods are empty, which is
  the one place in this repository where an empty method is the right answer,
  so `method_length` excludes that file rather than being turned off.

The mass run is the only caller: it is where a plant wide job begins and ends,
and the single material case goes through it too. It knows nothing about BAL —
it starts a log, says what happened to each material, and saves.

`SY-REPID` had to be left out of the log header, which the transpiler does not
implement (ANOMALIES.md 2l). `BAL_LOG_CREATE` fills the date, time, user and
program itself when they are not supplied, which is the better code anyway.

### Feature 41 — a plant may allocate against its own plan (done)

Feature 38 put production orders on the timeline. Below them sits the layer
MRP works in: the planned order, which is what the system intends to make or
buy before anybody has said yes. Whether that counts as supply is not a
question with one right answer, and this is the first thing in the solution
where the honest reply is "it depends on the plant".

- A make to stock plant with a stable plan runs out of confirmations long
  before it runs out of intention, and the planner allocating by hand is
  reading exactly those planned orders off MD04.
- A plant whose plan is re-cut every night by MRP would be promising customers
  stock against a proposal that will not exist tomorrow.

So `ZCL_SUPPLY_PLANNED` reads `PLAF` and answers `ZIF_SUPPLY_READER` like every
other source, and it is only in the object graph when the plant's Customizing
says so. `ZSTOCK_ALLOC_CFG-PLANNED` is the switch, off for a plant that has
never heard of it, and the selection screen has the same checkbox for somebody
trying it out.

- **Firmed only, by default.** A firmed order (`PLAF-AUFFX`) is one MRP has
  been told to leave alone, which is the closest thing a planned order has to a
  human agreeing to it. `IV_FIRM_ONLY` can be switched off by a caller wiring
  the class itself, and the constructor defaults to the safe answer rather than
  the complete one. That distinction is per class, not per plant, because a
  plant that wants its whole plan counted is asking a different question from a
  plant that wants none of it.
- **A converted order is not read twice.** `PLAF-UMSKZ` says what it proposed
  is a production order or a purchase requisition now, and feature 38 or 34
  reads it there. Both would be the same goods given away twice.
- **Long term planning stays out.** A simulative order lives in the same table
  under a planning scenario of its own (`PLAF-PLSCN`), and it describes a
  future somebody was asking about. Only the operative plan, `000`, is supply.
- **No finish date, no supply**, the rule feature 34 set and feature 38
  repeated: placing an undated receipt on the timeline means calling it
  available now.
- **The switch is read where every other setting is**, so a nightly job still
  only has to be told the plant. `ZCL_ALLOC_CONFIG` reads anything but `X` as
  no — the one setting in the table that promises stock nobody has ordered is
  the one to be sure about.

Adding a fourth supply source is now a two line change to `CREATE_DEFAULT`,
which is what feature 34 built the composition for. The engine, the strategies
and the demand side did not move.

### Feature 42 — stock that belongs to somebody already does not compete (done)

`MARD` is anonymous stock: the pieces on the shelf that any order may have.
Stock made or bought for one sales order or one project is not in it — sales
order stock is in `MSKA`, project stock in `MSPR`, each in a segment of its
own. The demand side did not know that. A made to order item was read as
ordinary demand and competed for the free pool, which is wrong twice over: the
item cannot be shipped from that pool, and every item that has nothing but the
pool lost stock to it.

`VBAP-SOBKZ` says an item has a segment of its own, and an item that has one is
no longer read as demand, in `READ_ITEMS` and in `MATERIALS_WITH_DEMAND` alike.

- **Any special stock indicator, not just `E`.** The reason is the same for
  sales order stock, project stock and everything else the field can hold: the
  goods this item will ship are counted somewhere `MARD` is not.
- **This is the safe half of the answer.** The complete one would read the
  segment as well and allocate it to the item that owns it, and it would need
  `MSKA`, `MSPR` and a pool per segment rather than one per material. Leaving
  the demand out confirms less and never promises stock that cannot ship;
  reading the segments is a feature, not a footnote, and it is not this one.
- **The stock transport order reader is untouched.** `EKPO-SOBKZ` exists too,
  but a stock transport order moving special stock between plants is a rarity
  that deserves its own thinking rather than a line copied across.

### Feature 43 — a customer who orders cartons is confirmed in cartons (done)

Everything inside the engine is in base units, which is what makes stock and
demand comparable at all (feature 17). What leaves the plant is not: a line
ordered as five cartons of twelve ships in cartons, and confirming it 20 pieces
is confirming one carton and two thirds of another. Somebody in shipping then
has to decide what that means, and the eight pieces are held back from a line
that could have used them either way.

`ZCL_ALLOC_WHOLE_UNITS` wraps a strategy and cuts every confirmation down to a
whole number of the line's own order unit. `ZSTOCK_ALLOC_CFG-WHOLE_UNITS`
switches it on per plant, off by default.

- **The unit comes from the document, not from the material.** `ZIF_ALLOCATION`
  gained `UNIT_SIZE`, the number of base units in one unit of the ordering
  document, and both demand readers fill it from the converter they already
  hold. A line in the base unit gets 1 and is never touched, which is most
  lines in most plants: the rule costs nothing where it does not apply.
- **What is cut off is offered again.** The decorator caps the line at the
  whole part and asks the strategy once more, so the pieces one line cannot use
  reach a line that can — usually one that sells in the base unit. That is
  feature 25's pass loop, with capping in place of dropping, and the same
  bound on the number of passes.
- **The last word is a cut, not a pass.** Whatever the passes settled on, the
  final answer cuts anything still holding part of a unit. A loop that runs out
  of passes must not be able to break the rule it exists to keep.
- **The answer is about the demand as it was asked for.** The passes cap
  quantities to steer the strategy; the allocation that comes back carries the
  original requested quantity and the shortfall against it, so nothing about
  the capping leaks into what a planner reads.
- **It goes inside the complete delivery rule**, next to the customer cap and
  for the same reason feature 32 gave: a line cut back to whole cartons may no
  longer reach the quantity it has to ship in one go, and the rule outside has
  to see the cut number rather than the one before it.
- **Off by default.** Cutting a confirmation holds stock back, and a plant that
  is happy to ship a part carton should not be made to keep it. Like feature
  41's switch, this is a decision about a site, so it lives with the site.

### Feature 44 — a run can be cut down to what one planner owns (done)

A plant wide run is one job that either finishes or does not. In a plant with
fifty thousand materials that is a bad unit of work: it cannot be spread over
several background processes, a failure halfway means repeating everything, and
a planner who wants their own materials looked at has to ask for the whole
plant to be run.

MRP controller is how a plant is already divided among the people who look
after it, so that is the line to cut along. `ZCL_DEMAND_OF_CONTROLLER` wraps a
`ZIF_DEMAND_READER` and keeps only the materials of the controllers it was
given, and `ZSTOCK_ALLOCATION` has a field for one.

- **It decorates the material list, not the demand.** `READ_OPEN_DEMAND` is
  passed straight through: what a material is owed does not depend on who
  looks after it, and a caller naming a material outright means that material.
  Only `MATERIALS_WITH_DEMAND`, the question "what should this run cover",
  gets an answer that depends on the controller.
- **An empty list is every controller**, the same answer
  `ZCL_STOCK_IN_LOCATIONS` gives an empty list of storage locations. A plant
  that has never split its run keeps the run it had.
- **A material flagged for deletion in the plant is dropped with it.**
  `MARC-LVORM` is on the row that is being read anyway, and a material on its
  way out of the plant is not worth a reservation. It is the one thing here
  that is not about controllers, and it is here because this is the first time
  anything in the solution reads `MARC` per material list rather than per
  material.
- **`MARC` is read once for the run**, filtered by a range of controllers,
  rather than once per candidate material. Feature 29 made that argument about
  the material master and it is the same argument.
- **The controller stays on the selection screen** even when the settings come
  from the plant. Which materials a job covers is a property of the job — of
  how the work was split between background processes tonight — not of the
  plant, and putting it in Customizing would tie the two together.

### Feature 45 — what can be promised, without allocating anything (done)

Everything so far answers one question: given all the demand there is, who gets
the stock. There is a second question, asked far more often and by different
people — *can I promise a customer 500 of this by the 12th?* — and the solution
could only answer it by running a whole allocation and reading the result,
which reserves stock and takes a lock to answer a question nobody asked it to
act on.

`ZIF_ATP_QUERY` / `ZCL_ATP_QUERY` answer it directly. They walk the same supply
timeline a run distributes and say how much of the quantity asked for is there,
and on what day it is complete. `ZSTOCK_ALLOC_ATP` is the same thing with a
selection screen.

- **It is the timeline the run uses, not a second opinion.**
  `ZCL_ALLOCATION_SERVICE=>CREATE_DEFAULT_SUPPLY` was pulled out of
  `CREATE_DEFAULT` so both wire up the same object graph — free stock less what
  is held back, plus receipts, production orders and, if the plant says so,
  planned orders. An availability answer that disagreed with the run that acts
  on it would be worse than none.
- **A date cuts the timeline, it does not move it.** With a date the answer
  counts only what is there by that day, which is what a customer asking for
  the 12th means. Without one the answer is the earliest day the whole quantity
  can be there — the two questions a salesperson actually asks.
- **The day is the day the promise is complete**, the last one that
  contributed, and initial means the stock is on the shelf. Same convention as
  feature 35, because it is the same statement.
- **A promise of nothing carries no date.** Saying "none, on the third" would
  put a day against goods nobody is offering.
- **It reserves nothing and locks nothing.** A question asked from a sales
  order screen must not hold stock or block the nightly run; what turns an
  answer into a hold is an allocation run, which is the thing that writes.
- **It still asks whether the user may see the plant**, at display activity.
  A promise is a statement about a plant's stock, and somebody who may not see
  that plant may not have it read out to them either.

What it does not do is subtract demand that no run has confirmed yet. Between
runs, two people can be promised the same piece; the run is what decides who
really gets it. That is a property of allocating in batches rather than a gap
in the query, and pretending otherwise would mean holding stock for a promise
nobody recorded.

### Feature 46 — a front door for callers outside this repository (done)

Feature 45's query is an ABAP interface, which is the right thing for ABAP and
no use to anything else. The people most likely to want it are not in this
system: a sales order user exit is, but a Fiori service, a shop floor screen or
the planning system on the other end of an RFC destination are not.

`Z_STOCK_ALLOC_PROMISE` in function group `ZSTOCK_ALLOC_API` is remote enabled
and answers the same question, with `ZSTOCK_ALLOC_PROMISE` as the result
structure and `ZCL_ALLOC_ATP_API` behind it.

- **The function module holds no logic.** It hands its parameters to a class
  and copies the answer back, which is what `reduce_procedural_code` insists on
  and what makes the same answer testable. Everything a remote caller can do,
  an ABAP caller can do without going through RFC.
- **A `BAPIRET2`, not an exception.** A caller on the other side of an RFC
  destination cannot catch an ABAP exception. What went wrong is said in the
  structure every SAP caller already knows how to read, carrying the message
  class and number of the exception it came from rather than a sentence only a
  human can use.
- **Nothing to promise is not an error.** An empty answer with no message is
  the honest reply to "can you give me ten of these" when the plant has none;
  a message is for a question that could not be answered at all.
- **Flat DDIC types throughout**, because RFC has no interfaces, no references
  and no packed types of its own choosing. `ZSTOCK_ALLOC_PROMISE` exists to be
  that shape, and the quantity and date fields of the answer are typed from it.
- **The plant's settings are read, not asked for.** A remote caller should not
  have to know whether this plant counts planned orders; it asks about goods
  and gets the plant's own answer. A storage location may still be narrowed,
  because that is a statement about which goods the caller means.

### Feature 47 — say why a line did not get everything (done)

A line that comes back short says how much is missing and nothing else, and by
now there are five different reasons it could be short, three of which are the
plant's own rules. "Confirmed 4 of 10" sends a planner to look for stock that
may not be the problem at all: the stock might be there and held by another
customer's share, or cut off because the line is sold in cartons, or dropped
because the item ships in one go, or on its way and arriving too late. Each of
those is a different thing to do next, and the report could not tell them
apart.

`ZIF_ALLOCATION=>C_REASON` names the five, `TY_ALLOCATION` carries one, and
both reports show it in a column of its own.

- **The rule that held a line back is the one that says so.** The customer cap,
  the whole units rule and the complete delivery rule each set their own reason
  on the line they cut, because each of them is the only thing that knows it
  did. Nothing outside has to guess from the numbers.
- **The engine explains the two reasons that are nobody's rule**: a line no day
  of supply could be offered to, because every receipt lands after it is
  wanted, and a line the pool simply did not stretch to. The first is a
  scheduling problem and the second a purchasing one, which is exactly why they
  must not read the same.
- **The last word wins.** A line the cap held back in January and the stock
  held back in March was stopped by the stock in the end, so the reason from
  the latest day of supply is the one kept.
- **A rule only explains a line it actually cut.** The whole units rule sets
  its reason when a pass caps a line or the final cut takes something off it,
  not when the line was already short before it looked. Otherwise the last rule
  in the chain would take the blame for everything.
- **A line that got everything has no reason at all**, and the column is empty
  rather than saying "fine".
- **An unfamiliar code is printed as it stands.** A customer with a strategy of
  its own can answer with a reason of its own, and a letter nobody here
  recognises still says more than an empty column.

The reason is stored with the run in `ZSTOCK_ALLOC_RES`, so the display report
answers the question a week later, which is when it is usually asked.

### Feature 48 — the list a planner works through in the morning (done)

`ZSTOCK_ALLOC_DISPLAY` answers "what happened to this material", one block per
material in material order. That is the right shape for looking something up
and the wrong shape for the question somebody actually starts the day with:
*what is short here, and which of it matters first?* Material order is
alphabetical order, which has nothing to do with urgency, and a plant with two
thousand materials buries the three that need a phone call.

`ZCL_ALLOC_SHORTAGE_LIST` and `ZSTOCK_ALLOC_SHORT` read the same recorded runs
and turn them into one list across the plant.

- **The day it is wanted decides the order**, because that is what makes one
  shortage more urgent than another. Within a day the biggest hole comes first,
  and the material keeps ties steady so the list does not shuffle between runs.
  A line with no date is wanted now and sorts first without a special case.
- **Only what is short is in it.** A worklist that includes what worked out is
  a report, and there is already a report.
- **A cut-off date narrows it to this week**, which is how a planner reads it:
  what lands after the horizon they are working to is somebody else's problem
  this morning.
- **A line limit is honest about what it dropped.** The footer says "2 of 17
  short lines shown", because a truncated list that looks complete is worse
  than a long one.
- **The reason is the point.** Feature 47 gave each line a reason and this is
  what it was for: the list says not only what is short but what kind of
  problem each one is, so purchasing, scheduling and sales can be handed
  different parts of it.

It changes nothing and checks display authority, like the other read-only
programs. There is no allocation logic in it at all: everything it shows was
decided by a run and written down.

### Feature 49 — a run can take back what an earlier one set aside (done)

Every run so far could only add. Feature 18 made sure a line already served is
not served twice, feature 26 made sure a live reservation still counts, and
between them a decision once made was permanent until housekeeping removed it.
That is right for a plant where demand only ever arrives, and wrong for every
other one: an urgent order that comes in this morning can only have what last
night's run happened to leave over, however far away the lines holding the rest
are due.

SAP calls the answer backorder rescheduling. Here it is one switch on the run:
give the earlier allocations back, then allocate everything from scratch.

- **Cancelling is part of earmarking**, so `ZIF_RESERVATION_WRITER` gained
  `CANCEL` rather than a new interface. Whoever knows how to hold stock back
  knows how to stop holding it.
- **Only what is still held is given back.** The items of the reservation are
  read first and the ones already carrying `RESB-XLOEK` are left alone: there
  is nothing to release, and a BAPI told to delete what is deleted answers with
  an error that means nothing went wrong.
- **The release happens inside the lock.** Feature 19's lock is taken before
  anything is read; the release sits inside it, so no other run can take the
  freed stock between the moment it is given back and the moment it is
  allocated again.
- **And it is committed before the readers run.** The stock deduction and the
  demand netting both ask the database what is still reserved. A cancellation
  nobody has committed is not there yet, and the run would give away the same
  stock twice — the same reasoning feature 37 gave for `WAIT = 'X'`.
- **The recorded runs stay.** They are what was decided at the time, the
  display shows the newest one anyway, and housekeeping removes them once they
  are old and no longer holding anything back. Deleting them here would throw
  away the only record that the earlier promise was ever made.
- **A run that released nothing commits nothing.** It has nothing of its own
  to make durable, and committing anyway would make somebody else's unrelated
  work durable for them — the same reason feature 37 gives for a simulation
  committing nothing.
- **A run whose reservation was rejected holds nothing**, so there is nothing
  to cancel and it is skipped. Feature 37 left that state deliberately
  reachable and this is one more thing that has to cope with it.
- **It is off by default and lives on the screen, not in Customizing.**
  Whether tonight's job re-cuts is a decision about tonight — a plant does not
  want its allocations re-cut every night by accident, and the switch that says
  "throw last night's promises open again" should be one somebody ticks.

`BAPI_RESERVATION_CHANGE` joins the stub function group, with the two item
structures it takes. The X structure is honoured: a field is only taken when
the change indicator says so, which is what makes a blank different from a
field nobody set, and the stub refuses a reservation that is not there.

### Feature 50 — stock that will not keep is not stock to promise (done)

`MARD` counts a batch that went off last month exactly like one made
yesterday. For a material with a shelf life that makes the whole answer wrong
in the worst direction: the run confirms a customer against goods that cannot
legally leave the warehouse, the delivery fails at picking, and the line that
could have been served waited for nothing.

`ZCL_DEDUCT_SHELF_LIFE` is one more `ZIF_STOCK_DEDUCTION`, which is what
feature 12 built that interface for: another reason some of what `MARD`
reports cannot be given away, in a class of its own.

- **The minimum remaining shelf life is the line, not the expiry date.**
  `MARA-MHDRZ` is what a customer is owed when the goods arrive, so a batch
  expiring inside it cannot be sent even though it has not expired. Measuring
  against today alone would confirm stock that shipping will refuse.
- **A material with no minimum only loses what has already gone off**, which
  falls out of the same arithmetic rather than needing a case of its own.
- **A material that is not batch managed loses nothing.** It has no expiry
  dates to read and `MCHB` has nothing to say about it, so the deduction leaves
  it alone rather than reading batch tables that will never answer.
- **An undated batch is kept.** Guessing an expiry would hold back stock that
  may be perfectly good; whether a date is required is a decision on the
  material master, and a plant that wants one enforced enforces it there.
- **A batch flagged for deletion is not counted**, because it is not in the
  book stock this deduction is subtracting from either. Deducting it would take
  the same quantity off twice.
- **Today is handed in.** The class takes the day to measure from, so a test
  can say what today is instead of the tests being right only until the
  fixtures expire.

The engine did not change. It never sees batches at all: the shelf life
question is answered where the book stock is turned into what can be given
away, which is the seam that existed for it.

### Feature 51 — a business can say which customers come first (done)

Demand is served in delivery priority order, and delivery priority is
`VBAP-LPRIO`: a field on the order, filled when the order was typed in, from
the customer master default of the day. That is the right place for "this
order is urgent" and the wrong place for "this customer is a key account".
A standing decision about a customer changes without the orders changing, and
nobody is going to go back through open order lines to reflect it.

`ZSTOCK_ALLOC_PRI` holds it once per customer, and `ZCL_DEMAND_CUSTOMER_PRIO`
puts it on the demand after the readers have built it.

- **It is a decorator on the demand reader**, so nothing downstream knows the
  table exists: the strategies still sort by `PRIORITY`, and the priority they
  sort by is simply better informed. The alternative — teaching both document
  readers about a Customizing table — would have put the same lookup in two
  places and left the next reader to remember it.
- **A row for the plant beats a row for every plant.** A key account is usually
  a decision of the business, which is what an empty plant means; a site that
  has decided otherwise for itself is not overruled by it.
- **A customer nobody ranked keeps what the order says.** The table is a list
  of exceptions, not a replacement for delivery priority, so a plant with no
  rows at all allocates exactly as it did before.
- **Demand with no customer is not ranked**, the same line the customer cap
  draws: a stock transport order is not a customer and has no share of this.
- **It overrides rather than adds.** Two numbers for the same line — one from
  the order and one from the table — would need a rule for combining them, and
  every rule for combining them is a rule somebody has to learn. Whichever
  answer is more specific wins outright, which is the same shape as the plant
  row beating the general one.

### Feature 52 — where a transfer stands against a customer order (done)

Feature 27 let stock transport orders compete with sales orders and gave them
a priority of 50, in the middle of the range, with a comment saying that is a
decision somebody may want to make differently. Two years of plants later, it
plainly is: a distribution centre feeding shops treats a transfer as the most
important thing it does, and a factory that also sells direct treats one as
whatever is left over. Both were stuck with 50, or with wiring the class
themselves.

`ZSTOCK_ALLOC_CFG-STO_PRIO` says it per plant, next to everything else a plant
decides, and the selection screen offers it to somebody trying it out.

- **Zero is a field nobody filled, not a priority.** The strategies read 01 as
  first, so taking an empty field literally would put every transfer in front
  of every customer — the one answer nobody asked for. An empty field means the
  default.
- **The default is still 50**, and it is still the reader's own constant: the
  configuration class points at `ZCL_STO_DEMAND_READER=>C_DEFAULT_PRIORITY`
  rather than repeating the number, so there is one place that says what a
  transfer is worth when nobody has said.
- **It reaches the reader through the factory**, like every other setting. The
  reader has taken a priority since feature 27; all that is new is who tells it.

### Feature 53 — a plant too big for one job (done)

Feature 44 split a run by MRP controller, which is the split a business
already has. It is not always the split a machine wants: controllers are
uneven, one of them owns half the plant, and a site that does not use them at
all is back to one job. What a background process wants is n roughly equal
pieces, and it does not care which materials are in which.

`ZCL_DEMAND_IN_PACKAGE` gives it that. `ZSTOCK_ALLOCATION` gains two numbers —
how many jobs share the plant, and which one this is — so the same report,
scheduled four times with four variants, is four processes doing a quarter of
the work each.

- **A material's package follows from the material number**, not from its
  position in the list. That is the whole trick: the four jobs read the plant
  seconds apart and see slightly different lists, and they still agree about
  every material either of them sees. No material is allocated twice, and none
  falls between two jobs because an order arrived while they were starting.
- **An alphabet lookup, not a character code.** The answer has to be the same
  in every system whatever the code page, so the characters are looked up in a
  fixed alphabet and weighted by position. It is not a checksum and does not
  have to be one: the only thing it must be is repeatable.
- **A package number nobody set means no split**, not an empty plant. Zero
  packages, one package, or a package number of zero all allocate everything —
  the failure mode of an unset parameter must not be a run that quietly does
  nothing.
- **The split is on the material list, not on the demand**, the same shape as
  the controller filter it wraps. Both can be used at once: the packages then
  divide what the controllers left.
- **The jobs need no coordination.** They do not talk to each other, share no
  state and start in any order; the material lock (feature 19) is still there
  for the case that somebody schedules two jobs with the same package number
  by mistake.

Deliberately not done: submitting the jobs. `SM36` schedules a report four
times with four variants and does it better than anything this repository
would write, and a program that submitted background jobs would need the job
API stubbed to be tested at all.

### Feature 54 — a material with nothing waiting is not a run (done)

A plant wide run covers every material anything is waiting for, and most of
those turn out to have nothing left to serve by the time the netting has taken
off what is delivered and what earlier runs already hold. The run still handed
each of them a run id, wrote nothing under it, and committed twice — twice,
because feature 37 waits for each commit, so an empty material cost two round
trips to the update task and a line in the log leading to an empty page.

The service now stops as soon as the engine answers with nothing.

- **No demand is not the same as no confirmation.** A line confirmed nothing is
  still an answer and is recorded; a material with no demand lines at all has
  no answer to record. The test for it is the allocation being empty, not the
  confirmed quantity being zero.
- **The run id is handed out after the calculation**, not before, so a material
  that turns out to have nothing waiting does not consume one. Nothing depends
  on the ids being consecutive, but a number that leads nowhere is still a
  number somebody will look up one day.
- **The log says nothing about it either.** A diary entry for a material that
  was not allocated is a line to check and find nothing behind.
- **The lock is still taken and given back.** Whether there is anything to do
  is only known after reading, and reading is exactly what the lock is there to
  make safe.

### Feature 55 — show the working, not only the answer (done)

Feature 47 made a short line say what stopped it, which answers "what kind of
problem is this". The next question is always "are you sure?", and nothing in
the solution could answer that. A planner looking at *confirmed 4 of 10, not
enough stock* has to go and add up `MARD`, the open purchase orders, the
production orders, the reservations, the deliveries and the safety stock by
hand — which is the calculation the run just did and threw away.

`ZCL_ALLOC_EXPLAIN` and `ZSTOCK_ALLOC_WHY` show it: the supply timeline, the
demand competing for it, and what a run would confirm now.

- **It reads the same sources a run reads.** `CREATE_DEFAULT_SUPPLY` and
  `CREATE_DEFAULT_DEMAND` wire the same object graph, so the working shown is
  the working done. An explanation assembled from different reads would be a
  second opinion, and the one thing worse than no explanation is one that
  disagrees with the answer.
- **It works the answer out again rather than reading the last run.** The
  recorded result says what was true last night; the question is always about
  now, and between the two a delivery went out and an order arrived.
- **It reserves nothing, records nothing and locks nothing**, and asks only for
  display authority. It is a question, and asking a question must not change
  the answer for everybody else.
- **The reason is shown next to the working**, which is where somebody deciding
  whether to chase purchasing or shipping wants both.
- **An empty timeline says "nothing" rather than nothing at all.** A blank
  section reads as a bug; the word is an answer.

### Feature 56 — housekeeping keeps a diary too (done)

Feature 40 gave the allocation run an application log because a job nobody
watches has to be able to say afterwards what it did. Housekeeping is exactly
such a job and it is the one that *deletes* things: it removes recorded runs
on a schedule, and until now the only trace of what it removed was the spool
of the job that removed it.

`ZIF_ALLOCATION_LOG` gained `REMOVED`, message 012 joined the message class,
and `ZCL_ALLOC_HOUSEKEEPING` takes a log like the mass run does.

- **One log interface, not two.** The interface is what a job of this solution
  did, and there are two kinds of job. A second interface with its own BAL
  class would have been the same plumbing twice over so that the word
  "allocation" in a name stayed accurate.
- **A test run keeps no diary**, the same rule and the same reason as feature
  40: it changes nothing, and saving a log commits, which a run that promises
  to change nothing must not do.
- **The line is written after the removal is committed**, not before. A log
  saying a run was removed when the delete had yet to go through would be a
  worse record than none.
- **The reorg is otherwise untouched.** It reads the plant's retention from
  Customizing, removes what is not holding anything back, and now says so
  where `SLG1` can find it.

### Feature 57 — where a run and its reservation disagree (done)

A recorded run says how much it confirmed; its reservation is what actually
holds that stock back. Feature 37 writes the two in one unit of work so they
start out agreeing, and after that they are on their own: anybody with `MB22`
can change or delete the reservation, a goods issue can consume it, and the
demand netting goes on believing whichever one it happens to read. The two
drifting apart is not a bug that can be prevented from inside — it is a thing
that has to be *noticed*.

`ZSTOCK_ALLOC_CHECK` notices it. One line per run that no longer matches, and
a footer saying how many were looked at.

- **Four ways to disagree, and they mean different things.** A reservation
  that is gone means the stock is free again and the record is stale; one
  holding less means somebody took part of it; one holding more means stock is
  held back that no run admits to; never reserved at all is the state feature
  37 deliberately leaves behind for somebody to retry. A single "inconsistent"
  would have made the report useless.
- **Agreement is silent.** A check that lists everything it checked is a check
  nobody reads twice.
- **`HELD_QUANTITY` joins `ZIF_RESERVATION_READER`**, next to the question of
  whether a reservation is live at all. What counts as live is defined once
  (feature 26) and the quantity is measured the same way, so the check and the
  netting cannot disagree about what they are looking at.
- **It changes nothing, not even the stale records it finds.** What to do about
  a run whose reservation is gone is a decision — re-run the material, or leave
  housekeeping to remove the record — and a report that quietly picked one
  would be the thing nobody expected.

### Feature 58 — when is this going to run out (done)

Everything in the solution so far answers a question about today: who gets the
stock that is there, what did not get any, why. The question a planner asks
*before* any of that is whether there is going to be enough at all, and if not
from when — and the numbers to answer it were already being read every night
and thrown away.

`ZCL_ALLOC_PROJECTION` puts them in periods: what comes in, what goes out,
what is left at the end, week by week. `ZSTOCK_ALLOC_PROJ` shows it.

- **It is the run's own numbers.** The same supply sources and the same demand
  readers, so a projection that says a week is short and a run that confirms
  everything in that week cannot both happen. A forecast built from its own
  reads would be a different opinion with no way to tell which is right.
- **The past lands in the first period.** Stock on the shelf carries no date
  and is there now; a receipt that was due last week is there now too; a
  requirement that was wanted in January is wanted now. Putting either into a
  period of its own would be honest about the calendar and useless to a
  planner.
- **Everything beyond the last period lands in one more.** Otherwise the
  columns add up to what fitted on the screen rather than to what the material
  has, and a total that is not a total is worse than no total.
- **The balance is carried from one period to the next**, which is the only
  reason to have periods at all: a week that is short on its own may be
  covered by what the week before left over.
- **The week it runs out is said in words**, under the row it happens in.
  Somebody came to the report for that one fact and should not have to find
  the first negative number in a column.
- **A projection that ends well says so**, because a report that just stops is
  a report somebody re-runs to check it worked.

### Feature 59 — a reservation that says what it is holding stock for (done)

A reservation created by a run has one item per confirmed line, and nothing
says which line. In `MB23` a planner sees a quantity held back by a
reservation with a number they have never seen, created by a background user,
against a movement type used for half a dozen things. The link exists in
`ZSTOCK_ALLOC_RES`, which is this solution's own table and not where anybody
looking at a reservation starts.

The item text now carries it: `ALLOC` and the demand line the item is for.

- **A prefix, so it can be told apart.** A text this solution wrote looks
  different from one somebody typed, which matters the moment anybody starts
  reading these programmatically — including the next feature in this
  repository.
- **It is the demand id**, the same string the recorded result and both reports
  use, so a reservation item, a line in the run and a line in `SLG1` all name
  the requirement the same way.
- **Nothing reads it back yet.** It is there for a person in `MB23` and for the
  consistency check to grow into; writing it costs one field on a structure the
  BAPI already takes.

### Feature 60 — the buying half of a plan (done)

Feature 41 let a plant allocate against its own plan and read `PLAF`, which is
where MRP writes what the plant will *make*. For everything the plant *buys*
MRP writes a purchase requisition instead, and a distribution centre that buys
everything it sells got exactly nothing out of the switch it had just been
given. The feature was half a feature and did not say so.

`ZCL_SUPPLY_REQUISITIONS` reads `EBAN` and is added by the same switch.

- **One switch, not two.** "Trust the plan" is one decision. A plant does not
  believe its planned orders and disbelieve its requisitions; the two are the
  same MRP run writing down what it intends, in the table that fits the way the
  material is procured.
- **What has been ordered is not counted here.** `EBAN-BSMNG` is the part that
  has become a purchase order, and feature 34 reads that as a receipt. Only
  what is still a proposal is left.
- **A converted item is out altogether**, because `EBAN-EBELN` says the whole
  of it is a purchase order now. Deleted and closed items are out for the
  reasons those flags exist.
- **No delivery date, no supply**, which is the rule every source in this
  solution follows, and the reason is the same every time: putting an undated
  receipt on the timeline means calling it available now.
- **A requisition is not firmed the way a planned order is.** `ZCL_SUPPLY_PLANNED`
  can insist on firming because `PLAF-AUFFX` says whether MRP will leave the
  order alone; a requisition has no such flag in the same sense, so the class
  takes what it finds. A plant that wants only committed receipts leaves the
  switch off, which is where that decision belongs.

### Feature 61 — what the run was told to do, and how the night went (done)

The log said what happened to each material and nothing about the run itself.
Two questions come up every time somebody opens one, and neither could be
answered from it: *what settings did this run use* — because the variant can
have been changed since — and *how did the night go as a whole*, which four
hundred lines each describing one material do not say.

Two more messages: the settings under the opening line, and a closing summary.

- **The settings are rendered where they are known.** `CREATE_DEFAULT` is the
  only place that has all of them at once, so it turns them into a line and
  hands it to the mass run, which hands it to the log. The alternative — the
  program building the text — would have put the same knowledge in a second
  place, and the class would have had to be told twice.
- **The strategy is named by what it is.** A customer that swapped in one of
  its own reads its own class name in the log rather than a word this
  repository chose for it.
- **A night with something wrong in it says so at a problem class SLG1 filters
  on**, so a list of logs shows which ones are worth opening. A night where
  nothing failed is a success message and stays quiet.
- **The summary counts materials, not lines.** How many lines fell short is a
  question for the display; how many *materials* need looking at is the one a
  planner starts with in the morning.
- **A test run still keeps no diary**, and a run with nothing to say about its
  settings writes no settings line rather than an empty one.

### Feature 62 — a planner's own materials, in the reports too (done)

Feature 44 let a *run* cover one MRP controller. The two reports a planner
actually opens could not be narrowed the same way, so somebody responsible for
two hundred materials in a plant of five thousand read five thousand.

Both now take a controller, and the lookup they share came out of the run's
decorator into `ZCL_ALLOC_OWNED_BY`.

- **One question, one place.** The run, the display and the shortage list all
  mean the same thing by "this planner's materials", so they ask the same
  class. Before this the run had the `SELECT` in a private method of a demand
  decorator, which is not somewhere a report can reach without becoming a
  demand decorator.
- **An empty list is no restriction**, everywhere, which is why `IS_OWNED`
  takes the list of controllers as well as the list it produced: without it,
  "nobody asked" and "nobody owns anything" would look the same to a caller,
  and the reports would show nothing at all.
- **Deleted materials are dropped in the shared place**, so a material flagged
  in the plant disappears from the run and from the reports for the same
  reason and by the same rule.
- **The filter is applied to the recorded lines**, not to the store query. The
  store answers what the last run decided; which of those a planner wants to
  see is a question about the material master, and putting it in the store
  would have taught the store about `MARC`.

### Feature 63 — a test of the whole thing as it ships (done)

Every class here is tested against doubles, which is what makes the tests fast
and the failures readable, and there is one kind of mistake it cannot catch: a
source that was written, tested and never added to `CREATE_DEFAULT`. The class
passes, the wiring is wrong, and the run quietly leaves a whole category of
stock or demand out. Twenty features of composition later that is the risk
worth spending a test on.

`ltcl_end_to_end` builds a plant in the database — stock on the shelf, a
purchase order landing in March, two sales orders at different priorities and
dates — and runs `ZCL_ALLOCATION_MASS_RUN=>CREATE_DEFAULT` over it.

- **Only the function modules are doubled**, because they are the edge of the
  system: `BAPI_RESERVATION_CREATE1`, the two transaction BAPIs and the three
  BAL calls. Everything inside — the readers, the netting, the engine, the
  strategies, the store — is the real thing, wired the way the report wires it.
- **The doubles answer with nothing**, which every caller here reads as "it
  worked". What those calls do when they answer with something is covered
  where they are made; here they only have to exist.
- **The scenario is chosen so that three rules interact.** The urgent line
  takes the shelf, the receipt lands too late for the line that wanted it
  sooner, and the line left out says the pool did not stretch. Any one of
  priority, the availability date or the reason breaking shows up as a
  different number.
- **It asserts what was written down as well as what was returned**, because
  the recording is the part a report reads afterwards, and a test run is
  asserted to leave the table empty.

### Feature 64 — a basket in one call (done)

Feature 46 opened the promise to callers outside ABAP, one line per call. A
sales order with twenty items priced over an RFC destination is then twenty
round trips, and each of them reads the plant's Customizing again and builds
the whole object graph again to answer one question. The interface was right
and the granularity was wrong.

`Z_STOCK_ALLOC_PROMISES` takes a table of lines and answers all of them.

- **The settings are read once per plant and the sources wired once per plant
  and location.** That is the whole point: the work a single call repeats is
  not the reading of stock, it is everything around it.
- **The lines carry their own numbers.** The caller says which line each
  question is, and gets it back on the answer, so nothing depends on the order
  the answers come in — even though they do come back in order.
- **A line nobody can answer carries the reason and the rest are still
  answered.** One material that does not exist, or one plant the caller may
  not see, must not cost a whole basket. The single line call keeps the
  `BAPIRET2` because that is what one answer looks like in SAP; a table of
  them would have to say which line each message belonged to, which is what
  the message field on the answer line does.
- **Nothing to promise is still not a failure**, the same rule feature 46 set.
  An empty quantity with no message means the plant has none.

### Feature 65 — what the other rule would have done (done)

A plant chooses between priority and fair share once, in Customizing, and then
lives with it. Nobody ever sees the other answer, so the choice is made on a
feeling about how the business ought to behave rather than on what it would
cost — and the two rules can differ enormously on the same stock without
differing at all in the total they hand out.

`ZSTOCK_ALLOC_TRY` runs both over the same material and puts the answers next
to each other.

- **The demand is read once and both rules are given the same of it.** Reading
  it twice would let an order arriving between the two reads look like a
  difference between the rules, which is exactly the mistake this report exists
  to prevent somebody making by hand.
- **The wrapping is the same on both sides.** The customer cap, the whole units
  rule and the complete delivery rule go around each strategy in the order the
  run puts them in, so what is compared is the rule and not the decorators.
- **The totals are usually equal, and that is the point.** Both rules hand out
  the same stock; what differs is who ends up with a line they can ship, so the
  footer counts the lines served in full under each. That number is the choice.
- **The cap and the whole units rule are on the screen**, because a plant
  weighing up fair share is usually weighing it up together with them.
- **It changes nothing** and asks for display authority, like every other
  question-shaped program here.

### Feature 66 — a material somebody is looking at is not a lost cause (done)

Feature 19 takes a lock per material and gives up the moment somebody else has
it. In a quiet system that is right; in a real one a nightly job walks into a
planner who happens to have `MM02` open, or into another allocation job that
started a second earlier, and reports a material it could not do — an error
nobody can act on, because by the time anybody reads it the lock is long gone.

The enqueue call now asks to be waited for.

- **`_WAIT = 'X'` is the SAP answer**, not a retry loop of our own. The enqueue
  server keeps trying for a time the system sets (`enque/delay_max` and its
  neighbours), which is a decision about the system rather than about this
  program, and it does the waiting in the right place — in the lock server
  rather than in a work process holding a database connection.
- **The refusal still exists.** Waiting is not waiting forever: a material
  genuinely held for a long time still comes back as a failure, one material
  fails and the run goes on, which is what feature 13 built.
- **A run of one material takes a second or two**, so two jobs meeting on the
  same material is exactly the case that waiting fixes, and it is far more
  common than the case that gives up.

### Feature 67 — a run that would do nothing says so (done)

Feature 53's split has one way to go wrong that nobody would notice: package 5
of 4. It matches no material, so the job reads the plant, allocates nothing,
writes a diary saying it started and finished, and reports success. A typing
mistake in a variant becomes a plant that quietly stopped being allocated.

`ZCL_DEMAND_IN_PACKAGE=>IS_A_PACKAGE` says whether two numbers describe a job
that will run, and `ZSTOCK_ALLOCATION` stops before reading anything if they
do not. The same pass fixed the projection, where a period count of zero
printed a heading, no rows, and the words "enough for every period shown" —
true, and useless.

- **Both numbers empty is a package.** A plant that never split its run has
  nothing on the screen, and that must go on working.
- **Half a thought is not.** A package number without a count, or a count
  without a number, is somebody who filled in one field of two.
- **The check is in the class, not in the program.** The rule is about what
  `PACKAGE_OF` will do, and the class is where that is known; the program asks.
- **It writes the reason rather than issuing a message**, because abaplint
  cannot see the messages of a hand written message class and `MESSAGE` would
  not lint — ANOMALIES.md 6, which this feature is what turned up.
- **A number nobody set is the default, not an empty answer.** That is the
  projection's rule now, and it is the same instinct: a parameter left alone
  should give the sensible answer, never a blank one.
