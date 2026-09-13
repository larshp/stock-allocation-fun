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

## A14 - A new default DB dependency breaks test doubles that do not declare it

* Symptom: after `zcl_stock_allocation_service` started defaulting to a safety
  stock reader that selects from the new `ZSAFETYSTK` table, an *unrelated* test
  (`ltcl_stock_alloc_run->runs_two_materials`) failed with
  `cx_sy_dynamic_osql_semantics` and `no such table: double.zsafetystk`.
* Cause: `cl_osql_test_environment=>create( i_dependency_list = ... )` only
  creates the tables that are listed. The run test declared `MARD` and `RESB`,
  built the default service internally, and therefore reached the new table
  through a default dependency it had never declared.
* Workaround: when a class gains a default dependency that reads a new table,
  every test double that exercises that class *indirectly* must add the table to
  its `i_dependency_list`. Adding a single default DB read can break tests that
  have nothing to do with the feature, so when a new table is involved, check
  unrelated failing tests for a missing dependency before suspecting the change
  itself.

## A15 - `find( )` is 0-based in the transpiler and does not set `sy-subrc`

* Symptom: a test that checked catalog field names against a CSV header with
  `IF find( val = lv_header sub = ls_field-fieldname ) > 0.` never matched and
  counted 0 hits, although the header visibly contained every field name.
* Cause: two things stack up.
  1. The transpiled `find( )` returns a **0-based index** (and `-1` when the
     substring is missing). In real ABAP `find( )` returns the 1-based position
     and sets `sy-subrc`; here neither the base nor the `sy-subrc` contract
     holds, so the portable idiom is `>= 0` / `= -1`, not `> 0` plus `sy-subrc`.
  2. A `TYPE c LENGTH n` component is space-padded, so the search string
     `'RUN_ID'` was actually `'RUN_ID' + 24 blanks` and never matched the trimmed
     text in the header.
* Workaround: compare against `-1` (or `>= 0`) instead of using `sy-subrc`, and
  build the expected string with a string template (`|{ ls_field-fieldname }|`)
  so trailing blanks are trimmed on both sides before comparing. Avoid searching
  a padded value inside a trimmed string.

## A16 - A `DATA` declaration inside a control block is not parsed

* Symptom: `parser_error, Statement does not exist in the configured ABAP version
  (or a parser error), "DATA", <file>:<line>` for a statement like
  `DATA lv_multiples TYPE i.` placed inside an `IF ... ENDIF.` block, followed by
  `"lv_multiples" not found` at its first use.
* Cause: the transpiler only accepts the explicit `DATA <name> TYPE <type>.` form
  at the start of a method (or globally); declaring it inside a control block is
  parsed as invalid. abaplint accepted the code.
* Workaround: move the declaration to the top of the method. Inline declarations
  with `DATA(lv_x) = ...` are accepted, so the issue is specific to the explicit
  form inside a block.

## A17 - A character field cannot be passed to a `TYPE string` parameter

* Symptom: `check_syntax, Method parameter type not compatible, <class>:<line>`
  at a call such as `escape( ls_overview-run_id )` where the parameter is declared
  `iv_value TYPE string` and `run_id` is a character field. abaplint accepted the
  code.
* Cause: the transpiler's call compatibility check requires the same type, and it
  does not consider the implicit `c -> string` conversion. Only a generic
  parameter (`TYPE c`, `TYPE any`) or an exact match is accepted. This is the same
  family as A11 (data element vs. inferred component) and A7.
* Workaround: avoid the helper and inline the value, or pass a value that is
  already a `string` (e.g. assign it to a `string` variable first, or use a string
  template `|{ ... }|`). A `TYPE c` parameter without a length was not tried; the
  simplest fix is to drop the conversion helper.

## A18 - A literal with trailing blanks loses them in the transpiled test run

* Symptom: a test asserting a padded value failed with
  `Expected 'AB', got 'AB   '` although the expected literal was written
  `'AB   '` (three trailing blanks) and the code under test clearly produced the
  blanks. The literal side was compared as `'AB'`.
* Cause: the transpiler trims trailing blanks from a text literal, so
  `'AB   '` becomes the string `'AB'`. Values produced at runtime by
  concatenating `` ` ` `` keep their blanks, only literals are affected.
* Workaround: do not rely on trailing blanks in a literal. Build the expected
  value at runtime, e.g. concatenate single-space literals in a helper, and
  compare that variable. Internal blanks inside a literal (`'AB  CD'`) survive.

## A19 - Positional parameters in a functional method call are not parsed

* Symptom: `parser_error, Statement does not exist in the configured ABAP version
  (or a parser error), "lt_qty", <file>:<line>` for a call written with two
  positional parameters, `add( lt_qty '7' )`.
* Cause: the transpiler's parser does not accept a functional method call whose
  arguments are given positionally without a separator it recognises. abaplint
  accepted the code.
* Workaround: use named parameters in the call
  (`add( it_qty = lt_qty iv_quantity = '7' )`), which parses cleanly. This is the
  same family as A12 (functional call forms the parser rejects).

## A20 - Date arithmetic on a `d` field did not give the expected day counts

* Symptom: `zcl_alloc_calendar` computed a weekday as
  `lv_days = iv_date - '19000101'` and then `lv_days MOD 7`. The unit test
  expected `20260912` (a Saturday) to be a weekend day but `is_weekend` returned
  false, i.e. the day count was not the number of days since the reference date.
  Incrementing a date with `lv_date = lv_date + 1` is in the same family.
* Cause: the transpiler does not reproduce ABAP's date arithmetic on a `d` field
  faithfully (the reference literal is not treated as a date difference).
* Workaround: do not rely on `d`/`d` subtraction or on adding an integer to a `d`
  field. `zcl_alloc_calendar` extracts year/month/day with offset access
  (`iv_date+0(4)`), uses Zeller's congruence for the weekday and increments the
  day/month/year explicitly with a leap-year rule.

## A21 - Adding abapGit metadata XML switched on repo-wide XML linting

* Symptom: after adding the missing `.clas.xml` / `.intf.xml` files, `npm run
  lint` went from 530 to 786 analysed files and reported 38 `xml_consistency`
  errors - none of them in the new files. The existing DDIC metadata was
  incomplete: 26 `QUAN` fields had no `REFTABLE`/`REFFIELD` and three data
  elements declared `REPTEXT`/`SCRTEXT_*` without `HEADLEN`/`SCRLEN1-3`.
* Cause: `abaplint` only analyses object metadata XML once the repository looks
  like an abapGit repository (metadata files present); that same switch enables
  the `xml_consistency` rule for every XML file, including the pre-existing ones.
* Workaround: treat the XML as compiled DDIC. Every `QUAN` field needs
  `REFTABLE` and `REFFIELD`, and every data element with label texts needs the
  matching label lengths. `checkRequiredField` only requires a non-empty value,
  so a sensible reference (for example `MARA`/`MEINS` for material quantities)
  is enough.

## A22 - A `!` inside a heredoc is mangled by the shell

* Symptom: `node` rejected a generated helper script with `SyntaxError: Invalid
  or unexpected token` at `desc.has(name) === false`: the heredoc had turned the
  `!` into `\!` (history expansion), even though the heredoc delimiter was
  quoted.
* Cause: the interactive shell in this environment expands `!` while the command
  line is read, before the heredoc content is passed on.
* Workaround: avoid `!` in generated scripts - write `x === false` or
  `x === null` instead of `!x` - or create the file with an editor rather than a
  heredoc.

## A23 - Every serialized object XML needs a UTF-8 byte order mark

* Symptom: after refreshing the dependencies, `npm run lint` reported 275
  `xml_bom` errors ("XML file must start with a UTF-8 byte order mark") for every
  XML file, including files that had passed a few minutes earlier.
* Cause: `xml_bom` is enabled in `abaplint.jsonc`, but it only applies to files
  that abaplint accepts as abapGit objects. The refreshed dependency tree started
  applying it to all XML files, and none of the 277 repository XML files carried
  a BOM.
* Workaround: prefix every serialized object XML with the UTF-8 BOM
  (`EF BB BF`), which is what abapGit writes anyway. The transpiler reads the
  DDIC definitions from the BOM files unchanged.

## A24 - The first transpile after refreshing dependencies can miss a core class

* Symptom: directly after `npm install` (which reinstalled the toolchain), one
  `npm test` run failed at runtime with
  `ERR_MODULE_NOT_FOUND: Cannot find module output/cx_root.clas.mjs`, after 1021
  of the usual 1052 tests. The very next run reported all 1052 tests and no
  errors, and the file was present in `output/` afterwards.
* Cause: the transpiler obtains the `open-abap-core` sources from a cached clone
  and re-creates that cache after the dependency tree changes; when the
  sandboxed terminal has no network access, the first run after a refresh can
  come up short on core classes.
* Workaround: re-run `npm test`. The second run uses the refreshed cache and is
  complete. Treat a single `ERR_MODULE_NOT_FOUND` for a core class right after a
  dependency change as transient, but a repeat of it as a real problem.

## A25 - `VBAP` has no `EDATU` column, only the stub did

* Symptom: the abapGit syntax check in a real SAP system reported
  `Unknown column name "EDATU"` at the `SELECT` in
  `zcl_requirement_reader_vbap=>zif_requirement_reader~read_requirements`, and
  the unknown column then cascaded into `Field "LT_VBAP" is unknown` (the inline
  `@DATA(lt_vbap)` was never typed) and `LS_VBAP~KWMENG is unknown` /
  `LS_VBAP~... is unknown` on every later use. `abaplint` and the transpiler
  were green because the local `VBAP` stub invented an `EDATU` field.
* Cause: the sales order item table `VBAP` carries no requested-delivery-date
  field. The requested delivery date is `VBAK-VDATU` (header); `VBEP-EDATU` is
  the schedule line date and lives one level deeper (one row per schedule line).
  Only `VBAK`, `VBEP` and `VBAP` share the system's view - the stub had the
  realistic-looking but wrong field.
* Workaround: join `VBAK` in the reader
  (`FROM vbap AS item INNER JOIN vbak AS head ON head~vbeln = item~vbeln`) and
  map `head~vdatu` to `requested_date`. Removed `EDATU` from the `VBAP` stub and
  added a `VBAK` stub (`MANDT`, `VBELN`, `VDATU`). The transpiler accepts the
  `INNER JOIN` in a `SELECT ... INTO TABLE @DATA(...)`, including the aliased
  `ORDER BY head~vdatu`. An item without a `VBAK` header is skipped by the inner
  join (covered by a test).

## A26 - The SQL test double environment must be created once per test class

* Symptom: running the unit tests in the real SAP system (Code Inspector,
  variant `SWF_ABAP_UNIT`) reported two errors for every one of the 19 test
  classes that mock the database: `Exception Error <CX_OSQL_FAILURE>` raised in
  `cl_osql_test_environment->chk_for_multiple_env_instance` and
  `Exception Error <CX_SY_REF_IS_INITIAL>` at the `teardown` line
  `mo_environment->destroy( )`.
* Cause: the test double environment was created in the per-test-method `setup`
  (`mo_environment = cl_osql_test_environment=>create( ... )`) and destroyed in
  `teardown`. In a real SAP system only one test environment instance may exist
  per test class execution, so the second and every later test method raised
  `CX_OSQL_FAILURE` when their `setup` called `create( )` again. Because that
  `setup` aborted, `mo_environment` stayed unbound and `teardown` then failed
  with `CX_SY_REF_IS_INITIAL` - a secondary error that hides the real one. The
  open-abap transpiler does not enforce the "one environment" rule, so the
  transpiled test run stayed green.
* Workaround: use the pattern SAP documents for the SQL test double framework:
  `CLASS-DATA mo_environment`, `CLASS-METHODS class_setup` (calls `create( )`),
  `CLASS-METHODS class_teardown` (calls `destroy( )`), and a `setup` that only
  calls `mo_environment->clear_doubles( )` so every test method starts with
  empty doubles. The per-method `teardown` was removed. `class_teardown` is
  guarded with `IF mo_environment IS BOUND.` so a failing `class_setup` cannot
  produce a second, misleading exception. open-abap's unit runner
  (`kernel_unit_runner`) already calls `CLASS_SETUP` / `CLASS_TEARDOWN`, so
  `npm test` still passes.
* Toolchain gap (open-abap): `cl_osql_test_environment=>create( )` only rejects a
  second environment while one is still active - it throws when the global SQL
  schema prefix is already set. It does not model SAP's "one environment per
  test-class execution" rule, so a per-method `create` / `destroy` pair stays
  green in the transpiler although it fails in a real system. The unit runner
  itself matches SAP: `CLASS_SETUP` once, `SETUP` / `TEARDOWN` per test method,
  `CLASS_TEARDOWN` once. Everything else in this entry was a bug in this
  repository's own test classes.
