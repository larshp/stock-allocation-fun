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

## 3. The generated unit test runner stops at the first failure

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
