# ANOMALIES

Bugs and issues encountered while linting/transpiling/testing the ABAP code.
Each entry notes the symptom, the cause and the workaround used.

## A1 - Transpiler rejects method names longer than 30 characters

* Symptom: `check_syntax, Method name "..." is too long, maximum length is 30
  characters`, raised by `abap_transpile` only.
* Cause: abaplint's `open-abap` syntax version accepts names up to 61 characters,
  while the transpiler validates against the classic 30 character limit.
* Workaround: keep method names <= 30 characters. Renamed
  `read_stock_returns_all_locations` -> `returns_all_locations`.

## A2 - `TYPES BEGIN OF ... . TYPES comp TYPE t.` is not parsed by the transpiler

* Symptom: `parser_error, Statement does not exist in the configured ABAP version
  (or a parser error), "matnr", ...` for every structure component.
* Cause: the "new" structure declaration style is not part of the ABAP version the
  transpiler parses.
* Workaround: use the classic chained form
  `TYPES: BEGIN OF x, a TYPE t, END OF x.`

## A3 - `libs.folder` in `abap_transpile.json` does not select a subfolder of a clone

* Symptom: `0 files added from lib` and every open-abap-core type reported as
  `unknown_types`, even though the clone succeeded.
* Cause: `folder` is interpreted as a *local folder relative to the current working
  directory*. `/src/` accidentally matched the repository's own `src` folder, and
  the default glob `/src/**` was then applied inside it, so nothing was found.
* Workaround: for a git dependency only specify `url`; the transpiler defaults to
  the `/src/**` glob inside the clone.

## A4 - Duplicate DDIC filenames with open-abap-core

* Symptom: `Error: Duplicate filename:
  stubs/ddic/dtel/menge_d.dtel.xml already exists as
  <tmp>/src/ddic/dtel/menge_d.dtel.xml`.
* Cause: `errorOnDuplicateFilenames` is enabled and open-abap-core already ships
  `MATNR`, `MEINS`, `MENGE_D` and `MANDT`.
* Workaround: only stub data elements/tables that open-abap-core does not provide.
  Removed the duplicated `matnr`, `meins` and `menge_d` stubs.

## A5 - `modify_only_own_db_tables` blocks `INSERT` in test classes

* Symptom: `Modify only own DB tables (modify_only_own_db_tables) [E]` for
  `INSERT mard FROM @ls_mard` inside a test class.
* Cause: the rule intentionally only allows writes to tables owned by the custom
  namespace, and it also applies to test code.
* Workaround: use `mo_environment->insert_test_data( ... )` from
  `cl_osql_test_environment` instead of a direct `INSERT`.

## A6 - Interface method not reachable through a class reference

* Symptom: `check_syntax, Method "read_stock" not found, methodCallChain` (raised
  by the transpiler) while abaplint reported no issue.
* Cause: the method is declared in `zif_stock_reader`; a variable typed
  `REF TO zcl_stock_reader_mard` cannot call it without the interface prefix.
* Workaround: type the variable as `REF TO zif_stock_reader`.

## A7 - `TYPE c LENGTH n` in a method parameter list breaks the transpiler parser

* Symptom: `parser_error, Statement does not exist in the configured ABAP version
  (or a parser error), "METHODS", <file>:<line>` where `<line>` is the first line
  of the `METHODS ...` statement. The whole method definition is dropped, which
  cascades into `Method definition "<name>" not found` and `"<param>" not found,
  findTop` errors; every call site then reports `Method "<name>" not found`.
* Cause: the length specification (`TYPE c LENGTH 20`) is only accepted by the
  transpiler parser in `DATA`/`TYPES` statements, not in method parameter
  definitions. abaplint accepts it, so lint passes while the build fails.
* Workaround: reference a named component/type instead, e.g.
  `iv_id TYPE zcl_stock_allocator=>ty_requirement-id`, or declare a `TYPES`
  alias for the length and use that.
* Debug tip: the reported line is the start of the failing statement, so look at
  everything between that line and the terminating `.`.

## A8 - Table type used directly as a parameter type

* Symptom: same shape as A7 - `parser_error ... "METHODS"` at the first line of
  the method definition, then `Method definition "read_log" not found` and
  `"rt_log" not found, Target` at the call site / inside the body.
* Cause: `RETURNING VALUE(rt_log) TYPE STANDARD TABLE OF zstockalloc
  WITH DEFAULT KEY.` is not valid parameter syntax; a table type must be a named
  type. abaplint did not report this, the transpiler did.
* Workaround: declare `TYPES ty_log_tt TYPE STANDARD TABLE OF zstockalloc WITH
  DEFAULT KEY.` in the class and use `TYPE ty_log_tt` in the signature.
