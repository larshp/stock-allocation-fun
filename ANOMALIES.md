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

## A9 - `modify_only_own_db_tables` has no file-level exclusion

* Symptom: `Modify only own DB tables (modify_only_own_db_tables) [E]` for
  `MODIFY mard FROM ls_mard` in the standard stub
  `stubs/fugr/bapi_goodsmvt.fugr.bapi_goodsmvt_create.abap`, although the stub
  *emulates* SAP standard behaviour (the real BAPI updates `MARD`).
* Cause: the rule is driven by a single global regex (`ownTables`, default
  `^[yz]`) and abaplint's config has no per-rule `exclude`, so a stub cannot be
  exempted separately. Because the stub declares `MARD` itself, the table
  resolves as a local reference and is reported.
* Workaround: configure the rule in `abaplint.jsonc` and extend `ownTables` with
  the stubbed standard tables that own code legitimately posts through:
  `"ownTables": "^(?:[yz]|mard)"`. Keep the regex anchored at the start (do not
  add `$`) so `Z*`/`Y*` tables still match.

## A10 - `READ TABLE <ddic-table>` is not valid, the transpiler catches it

* Symptom: `check_syntax, "mard" not found, findTop,
  bapi_goodsmvt.fugr.bapi_goodsmvt_create.abap:38` at the line
  `READ TABLE mard INTO ls_mard WITH KEY ...`.
* Cause: `MARD` is a transparent DDIC table, not an internal table. `READ TABLE`
  requires an internal table; abaplint happened to not flag it, but the
  transpiler's syntax check rejects it.
* Workaround: read single rows with `SELECT SINGLE * FROM mard INTO @ls_mard
  WHERE ...` (host variables escaped with `@`). Direct `MODIFY mard FROM ls_mard`
  is valid and stays as is.

## A11 - Method parameter typed with a data element vs. an inferred SELECT field

* Symptom: `check_syntax, Method parameter type not compatible, IV_MATNR,
  zcl_stock_reader_mchb.clas.abap:57` at the call
  `read_expiry( iv_matnr = ls_mchb-matnr ... )`, where `ls_mchb` comes from
  `SELECT matnr, ... FROM mchb INTO TABLE @DATA(lt_mchb)` and the parameter was
  declared `iv_matnr TYPE matnr`.
* Cause: the transpiler types the inferred SELECT structure component as a plain
  character type, and its call compatibility check does not treat that as
  identical to the data element `MATNR`. A component reference to the very table
  being read is accepted.
* Workaround: declare the parameter with the component reference of the source
  table, e.g. `iv_matnr TYPE mchb-matnr`.

## A12 - Functional method calls: `CHANGING` in a call and `APPEND <call> TO`

* Symptom:
  `parser_error, Statement does not exist in the configured ABAP version (or a
  parser error), "add_result", <file>:<line>` at every *call site* of a local
  helper that was invoked as a standalone statement with a `CHANGING` parameter,
  i.e. `add_result( iv_id = 'X' CHANGING ct_result = lt_result ).`. The helper's
  definition and implementation parsed fine, only the calls failed. A variant of
  the same error appeared for `APPEND result( ... ) TO lt_result.`.
* Cause: the transpiler's parser does not accept (a) an explicit `CHANGING`
  parameter in the functional call form without the preceding `EXPORTING`
  keyword, nor (b) a functional method call used directly as the source of
  `APPEND ... TO`.
* Workaround: prefer a helper that returns the table via `RETURNING` and use it
  in an assignment, which is parsed cleanly:

  ```abap
  lt_result = add_line( it_result = lt_result
                        iv_id     = 'REQ-1' ).
  ```

  and inside the helper build a work area first, then
  `APPEND ls_line TO rt_result.`.

## A13 - Typo in a component reference passes abaplint but fails the transpiler

* Symptom: `unknown_types, Contains unknown, Field "EXPIRY" not found in
  structure, <file>:<line>` for a parameter typed
  `zif_stock_reader=>ty_stock-expiry-date`, while abaplint reported no issue.
* Cause: the structure component is `expiry_date`; the type reference was
  written with a hyphen instead of the underscore (`...-expiry-date`). abaplint's
  lint rules did not catch the wrong component, the transpiler's type check did.
  The error names only the first unknown segment (`EXPIRY`), which makes the
  actual field easy to overlook.
* Workaround: use the exact component name, or avoid the chain altogether and
  type the parameter directly (e.g. `iv_vfdat TYPE d`).
