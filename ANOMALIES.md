# ANOMALIES

Recorded bugs and issues found while developing with abaplint + the
open-abap transpiler.

## 1. `MODIFY TABLE ... FROM` matches first row unconditionally

- **Where**: `stubs/src/zcl_stub_mard.clas.abap`, method `insert_row`
- **Symptom**: inserting a second MARD row overwrote the first row; the table
  always ended up with one row.
- **Root cause**: the transpiler emits `modifyInternal(table, {from: row})`.
  In the runtime, `readTable` with only `from` looks up
  `table.getOptions().primaryKey.keyFields`. For standard tables the transpiler
  emits `keyFields: []`, so the key loop compares *no* fields, `matches` stays
  `true` for the first row and every `MODIFY TABLE` overwrites row 1.
- **Workaround**: use explicit `READ TABLE ... WITH KEY matnr = ... werks = ...
  lgort = ...` plus `APPEND` instead of `MODIFY TABLE ... FROM`.
- **Proper fix**: runtime/transpiler should derive key fields from the DDIC
  table definition (the keys exist in `_init.mjs` CREATE TABLE statements) or
  treat empty `keyFields` as "no match" (insert).

## 2. Packed numbers format with decimals in string templates

- **Where**: unit tests comparing quantities (`kwmeng`, `labst`)
- **Symptom**: `|{ ls_result-allocations[ 1 ]-qty_alloc }|` renders `5.000`,
  not `5`; assertions against `'5'` fail.
- **Root cause**: QUAN/DEC types are transpiled to `Packed` with
  `decimals: 3`; string templates render all decimals.
- **Workaround**: compare against `'5.000'` style strings in tests.

## 3. `CharacterFactory.get( len, val )` truncates silently

- **Where**: transpiled test code
- **Symptom**: `abap.CharacterFactory.get(1, '10')` yields `"1"` - the value is
  truncated to the given length without error (correct ABAP semantics for
  character assignment, but easy to trip over when writing tests with numeric
  literals).
- **Lesson**: pass the full length when constructing test values, e.g.
  `labst = '10'` needs length 2.

## 4. Structure equality in `READ TABLE ... FROM` / sort keys

- Related to issue 1: `eq` on two structures compares field by field, but the
  `FROM`-key lookup never reaches that comparison because of the empty
  `keyFields` fast path. Keep an eye on runtime updates that change this area.
