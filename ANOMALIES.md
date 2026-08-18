# Anomalies

Bugs and rough edges found in the toolchain while building this solution.
Project decisions and progress live in [NOTES.md](NOTES.md).

## 1. Transpiled ESM output does not load without `addCommonJS`

- **Versions:** `@abaplint/transpiler-cli` 2.13.59, node 22.18.0
- **Symptom:** with `"options": {"addCommonJS": false}`, `node output/index.mjs`
  dies immediately:

  ```
  ReferenceError: cl_abap_objectdescr is not defined
      at output/cl_abap_classdescr.clas.mjs:1:34
  ```

- **Cause:** each generated `.mjs` refers to other objects as bare identifiers
  (`class cl_abap_classdescr extends cl_abap_objectdescr`) but emits no imports,
  and nothing is placed on `globalThis`. `output/init.mjs` imports the objects in
  **alphabetical** order, so `cl_abap_classdescr` is evaluated before its
  superclass `cl_abap_objectdescr` exists. The output is only loadable after a
  bundler has flattened it into a single scope.
- **Workaround:** `"addCommonJS": true`, which emits
  `const {cl_abap_objectdescr} = await import("./cl_abap_objectdescr.clas.mjs");`
  at the top of each module. Now in `abaplint-transpile.json`.

## 2. `initializeABAP()` builds a schema it never applies

- **Versions:** `@abaplint/transpiler-cli` 2.13.59
- **Symptom:** the first database statement in a unit test fails with
  `Error: Runtime, database not initialized`.
- **Cause:** the generated `initializeABAP()` builds `schemas` (the `CREATE TABLE`
  statements for every DDIC object) and `insert` (TADIR/REPOSRC seed rows) as
  local `const`s, then returns without opening a connection or executing either.
  Both values are unreachable from outside the function.
- **Workaround:** the values *are* passed to `options.setup.preFunction`, so a
  setup module has to do the work. `test/setup.mjs` opens
  `@abaplint/database-sqlite`, executes `schemas.sqlite` and `insert`, and
  registers the client as `abap.context.databaseConnections["DEFAULT"]`.
- **Note:** this is not documented in the transpiler-cli README; the wiring was
  found by reading `Initialization.script()` in the CLI bundle. `@abaplint/database-sqlite`
  is also not pulled in as a dependency of the CLI, so it has to be installed
  explicitly.

## 2b. `VALUE` table constructor ignores a per-row override of a default

- **Versions:** `@abaplint/transpiler-cli` 2.13.59
- **Symptom:** in a table constructor with default assignments in front of the
  rows, a row that assigns the same component again is ignored — the default
  wins. Reduced case, no database involved:

  ```abap
  lt_probe = VALUE #(
    a = 'DEF'
    ( b = 'R1' )
    ( b = 'R2' a = 'OVR' )
    ( b = 'R3' ) ).
  ```

  Transpiled result: `1:DEF 2:DEF 3:DEF`. In ABAP row 2 must come out as `OVR`,
  the row assignment overrides the default.
- **How it surfaced:** a `VBAP` test fixture set `werks` as a default and
  overrode it to a different plant on the last row, to prove the reader filters
  by plant. The override was dropped, the row stayed in the selected plant, and
  the reader looked like it was returning too many rows.
- **Not caught by abaplint:** the syntax check accepts the construct, so nothing
  warns about it.
- **Workaround:** do not use default assignments in table constructors — spell
  every component out on every row. Done in
  `src/zcl_so_demand_reader.clas.testclasses.abap`.

## 2c. `INTO TABLE @DATA()` produces no type for a join

- **Versions:** `@abaplint/transpiler-cli` 2.13.59
- **Symptom:** a `SELECT` with an `INNER JOIN` and an inline result table
  transpiles to a target that throws as soon as it is touched:

  ```js
  let lt_item = (() => { throw new Error("Void type: SELECT_todo3") })();
  ```

  The `SELECT` against a single table infers its type fine; only the join form
  fails. abaplint's syntax check passes, so this only shows up at runtime.
- **Workaround:** declare the result structure and table type explicitly and
  select `INTO TABLE @lt_item`. Done in `src/zcl_so_demand_reader.clas.abap` —
  arguably the better ABAP anyway, since the join result is then a named type.

## 2d. Join conditions keep ABAP tilde syntax in the generated SQL

- **Versions:** `@abaplint/transpiler-cli` 2.13.59, `@abaplint/database-sqlite` 2.13.40
- **Symptom:** the left side of an `ON` condition is quoted properly but the
  right side is passed through verbatim:

  ```sql
  ... INNER JOIN "vbak" AS header ON "header"."vbeln" = item~vbeln ...
  ```

- **Impact:** none today. The SQLite driver runs `replace(/~/g, ".")` over every
  statement, so `item~vbeln` becomes `item.vbeln` before it reaches SQLite. The
  transpiler output is nevertheless inconsistent, and a driver without that
  substitution would get a syntax error.

## 2e. Host expressions `@( ... )` are copied into the SQL verbatim

- **Versions:** `@abaplint/transpiler-cli` 2.13.59, `@abaplint/database-sqlite` 2.13.40
- **Symptom:** a `WHERE` clause using a host expression rather than a host
  variable reaches the database untouched:

  ```abap
  WHERE demand_id = @( CONV zstock_alloc_res-demand_id( 'D1' ) )
  ```

  ```sql
  ... AND "demand_id" = @( CONV zstock_alloc_res-demand_id( 'D1' ) ) UP TO 1 ROWS
  ```

  which fails at runtime with `unrecognized token: "@"`. Host *variables*
  (`@lv_x`, `@c_x`) are substituted correctly; only the expression form is
  passed through. abaplint's syntax check accepts it.
- **Workaround:** assign to a variable or constant first and use a plain host
  variable. Done in `src/zcl_allocation_store.clas.testclasses.abap`.

## 2f. A function module parameter named RETURN produces invalid JavaScript

- **Versions:** `@abaplint/transpiler-cli` 2.13.59, node 22.18.0
- **Symptom:** the whole test run dies on import with

  ```
  output/bapi_reservation.fugr.mjs:16
    let return = INPUT.tables?.return;
        ^^^
  SyntaxError: Unexpected strict mode reserved word
  ```

- **Cause:** the transpiler knows `return` is a reserved word — `return` is in
  its `DEFAULT_KEYWORDS` set, and every *usage* is emitted correctly as
  `$return.set(...)`. Only the *declaration* line skips the escaping. The two
  halves disagree, so the module cannot parse.
- **Why it matters here:** every SAP BAPI has a `RETURN` table parameter. As
  long as this stands, no faithful BAPI stub can be transpiled.
- **Workaround:** keep the function group faithful and lint it, but exclude it
  from transpiling (`exclude_filter` in `abaplint-transpile.json`), and let the
  unit tests replace the BAPI with a function module double from
  `cl_function_test_environment`. The custom `CALL FUNCTION` is still checked
  against the real signature by abaplint and still executed by the tests.
  Renaming the parameter was rejected: the point of the stub is that the custom
  code compiles unchanged against a real SAP system.

## 2g. Inline declarations inside a function module are never declared

- **Versions:** `@abaplint/transpiler-cli` 2.13.59
- **Symptom:** `DATA(ls_result) = ...` in a function module body transpiles to a
  use of `ls_result` with no `let ls_result` anywhere in the module:

  ```js
  ls_result.set((await abap.Classes['CL_STUB_RESERVATION'].create({...})));
  ```

  which is a `ReferenceError` the moment the function module runs. The same
  construct inside a class method is declared correctly.
- **Workaround:** declare explicitly with `DATA ls_result TYPE ...` in function
  module bodies. Moot for this repo, since 2f already keeps the stub function
  group out of the transpiled output.

## 2h. Inline declarations drop the decimal places of a packed expression

- **Versions:** `@abaplint/transpiler-cli` 2.13.59
- **Severity:** the worst one found so far — it silently changes numbers.
- **Symptom:** given two fields of type `p LENGTH 7 DECIMALS 3`,

  ```abap
  DATA(lv_open) = ls_reserved-requirement - ls_reserved-withdrawn.
  ```

  transpiles to

  ```js
  let lv_open = new abap.types.Packed({length: 8, decimals: 0});
  ```

  The decimals are gone, so `2.5 - 0` lands in the variable as `3`. Nothing
  fails; the quantity is just wrong from then on. Reserving `2.5` of something
  held back `3`.
- **Where it hides:** only inline declarations *from an arithmetic expression*
  are affected. `DATA(x) = some_packed_field.`, `DATA(x) = method( )` and
  `DATA(x) = CONV|COND|REDUCE type( ... )` all keep the right type — checked
  across every packed variable in this repo, and this was the only one.
- **How it was caught:** a test that added up `4 + 2.5 + 1` and expected `7.5`.
  The same code shipped one commit earlier with the same defect and the tests
  passed, because every quantity in them was a whole number. Fractional test
  data is not a nicety here — quantities carry three decimals, so the tests
  should too.
- **Workaround:** declare the variable with an explicit type whenever the right
  hand side does arithmetic. Done in `src/zcl_deduct_reservations.clas.abap`.

## 2i. `SELECT DISTINCT` loses the DISTINCT

- **Versions:** `@abaplint/transpiler-cli` 2.13.59
- **Severity:** silent — the statement runs and returns the wrong number of rows.
- **Symptom:**

  ```abap
  SELECT DISTINCT item~matnr AS matnr
    FROM vbap AS item
    INNER JOIN vbak AS header ON header~vbeln = item~vbeln
    ...
  ```

  becomes

  ```sql
  SELECT "item"."matnr"AS matnr  FROM "vbap" AS item INNER JOIN ...
  ```

  The `DISTINCT` keyword is simply not emitted, so a material with demand on two
  orders comes back twice. (The missing space in `"matnr"AS` is cosmetic —
  SQLite accepts it.)
- **Workaround:** `ORDER BY` the column and follow the `SELECT` with
  `DELETE ADJACENT DUPLICATES`. Done in `src/zcl_so_demand_reader.clas.abap`.

## 3. abaplint rejects `GROUP BY` followed by `ORDER BY`

- **Versions:** `@abaplint/cli` 2.120.26
- **Symptom:** a `SELECT` that groups and then sorts fails to parse:

  ```abap
  SELECT lgort,
         SUM( bdmng ) AS requirement,
         SUM( enmng ) AS withdrawn
    FROM resb
    WHERE matnr = @iv_matnr
    GROUP BY lgort
    ORDER BY lgort
    INTO TABLE @lt_reserved.
  ```

  ```
  Add ORDER BY (select_add_order_by) [E]
  Identifiers should be lower case: "ORDER" (keyword_case) [E]
  ```

  `ORDER` is reported as an *identifier*, so the clause was never recognised as
  `ORDER BY`. Deleting the `GROUP BY` line makes the same `ORDER BY ... INTO
  TABLE` parse cleanly, which pins the problem on the combination. The clause
  order is the one ABAP specifies: `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`,
  `INTO`.
- **Trap:** dropping the `GROUP BY` to silence it produces an aggregate next to
  a plain column, which abaplint then accepts but a real SAP system rejects.
- **Workaround:** select the reservation rows and add the open quantities up in
  ABAP instead of in SQL. Done in `src/zcl_stock_reader_net.clas.abap`. For the
  handful of open reservations one material has, the difference is not worth
  writing SQL that cannot be checked.

## 4. The generated unit test runner stops at the first failure

- **Versions:** `@abaplint/transpiler-cli` 2.13.59
- **Symptom:** `output/index.mjs` runs test methods in a plain loop with no
  `try`/`catch` per method. The first failing assertion propagates out of `run()`,
  so every later test method — in that class and in all following classes — is
  skipped. Exit code is `1` (correct), but the report is incomplete.
- **Additional:** the failure output is a raw `console.log` of the exception
  object, tens of lines of runtime internals around the useful
  `msg: "Expected '3', got '2'"`. There is no pass/fail summary line.
- **Impact:** low for now — verified that a deliberately broken assertion does
  fail the build. Revisit with a custom runner if the suite grows enough that
  losing the tail of the report costs real time.
