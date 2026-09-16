# Bugs and issues

## A1 — initial lint configuration was invalid (fixed)

The initial configuration contained a non-JSON value and an incorrectly nested rules section.
Replaced it with a valid top-level rules configuration; lint and transpilation now execute.

## A2 — parameter alignment (fixed)

`align_type_expressions` includes the returning parameter when calculating the TYPE column.
Aligned the importing parameters to the returning parameter; lint passes.

## A3 — scaffold helper unavailable

The project setup helper reported no valid VS Code workspace despite the current directory
being accessible. Project files are created with editor tools in the existing repository instead.

## A4 — abaplint release identifier (fixed)

`"release": "750"` is rejected by abaplint 2.120.53 ("Unknown version"). The installed
version maps on-premise 750 to release `v762`, which is now configured.

## A5 — transpiler needs addCommonJS (fixed)

Without `"options": { "addCommonJS": true }` in `abap_transpile.json`, generated code fails
at runtime with `ReferenceError: cl_abap_objectdescr is not defined`.

## A6 — no automatic client handling in transpiled SQL (fixed)

`SELECT ... FROM mard` returned rows of other clients in the SQLite fixture. The MARD
reader now filters explicitly with `WHERE mandt = @sy-mandt`. Verify client handling
against real SAP DDIC metadata before production deployment.

## A7 — safety-stock test expectation (fixed)

The safety-stock test expected two picks, but consuming the reserve first leaves only
one location with remaining stock. The test was corrected; the algorithm was right.

## A8 — declared but unimplemented test methods (fixed)

Adding test method declarations without implementations passes abaplint but fails
transpilation with `implement_methods` errors. Declarations and implementations must
be added together.

## A9 — test file corruption from malformed edits (fixed)

Repeated partial edits produced a duplicated `horizon` method and stray assertions,
breaking the transpiler with `check_syntax "second" not found`. The file was recreated
in full. Lesson: re-read the edited region after each edit instead of assuming content.
