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
