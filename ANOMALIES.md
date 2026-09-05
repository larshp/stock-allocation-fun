# Anomalies and limitations

## Open

- Transpiler 2.13.74 emits `let return = INPUT.tables?.return` for a BAPI TABLES
  parameter, while its references correctly use `$return`. The local test command
  applies an exact, single-line correction in generated `mb_bus2093.fugr.mjs`.
  The SAP ABAP signature is unchanged, and lint/transpile syntax checks stay enabled.
  Remove `test/fix-transpiled-bapi.mjs` after an upstream release fixes declarations.

- The transpiler does not emit implicit SAP client predicates for this SELECT.
  SQLite fixtures therefore use one client; native SAP client isolation needs an
  ABAP Unit/integration check in the target system. Production uses normal Open SQL
  automatic client handling, with no CLIENT SPECIFIED or cross-client access.

- No SAP system is connected. Transpiled tests can validate algorithm and adapter
  contracts, but cannot validate SAP authorizations, customizing, locking or updates.
- A MARD unrestricted-stock snapshot is not ATP. Production callers must account
  for existing requirements and obtain appropriate locks before making reservations.

## Resolved

- Initial validation accepted impossible dates such as 2026-02-29. Added Gregorian
  calendar validation, including century leap-year cases, at allocation and BAPI
  boundaries.

- The reservation stub initially transpiled to an empty function group because
  the SAPL main program and UXX include reference were missing. Added standard
  abapGit function-group program/include metadata so the BAPI is registered.

- Initial transpiled execution failed with `cl_abap_objectdescr is not defined`.
  The transpiler requires `addCommonJS: true` to emit class dependency imports.
  Enabled this option; all 12 initial ABAP Unit tests passed.
- Escaped `@requests-field` in a joined FOR ALL ENTRIES query was emitted as
  JavaScript object text followed by SQL subtraction. Classic syntax was also
  rejected by strict syntax checking. Replaced it with deduplicated, fully keyed
  SELECT SINGLE reads. A future bulk reader should retest FAE support first.
- The SQLite driver has an independent published version (2.13.40), rather than
  the transpiler/runtime version (2.13.74); pinned the available driver.
