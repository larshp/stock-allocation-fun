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
