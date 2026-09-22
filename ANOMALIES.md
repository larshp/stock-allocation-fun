# Anomalies and limitations

## Open

- The transpiler does not emit implicit SAP client predicates for this SELECT.
  SQLite fixtures therefore use one client; native SAP client isolation needs an
  ABAP Unit/integration check in the target system. Production uses normal Open SQL
  automatic client handling, with no CLIENT SPECIFIED or cross-client access.

- No SAP system is connected. Transpiled tests can validate algorithm and adapter
  contracts, but cannot validate SAP authorizations, customizing, locking or updates.
- A MARD unrestricted-stock snapshot is not ATP. Production callers must account
  for existing requirements and obtain appropriate locks before making reservations.
- The goods-issue adapters cover independent cost-center consumption (201) and
  reservation-referenced issues. Batch, serial number and special-stock parameters
  are not exposed. Their local standard stub always returns an error; real SAP posting and accounting
  behavior require development-system integration validation.
- The reserved-issue adapter maps reservation keys; SAP derives material, plant,
  movement and account assignment from those keys. The optional checked wrapper
  re-reads RESB identity and outstanding demand, but does not acquire locks or check
  stock, order status, movement permission or backflush eligibility. Callers must
  keep the snapshot stable under appropriate locks through posting and supply those
  remaining checks. The low-level writer can still be used independently.
- The RESB adapter reads explicitly selected order components but does not check
  order release/TECO status. It excludes special stock rather than allocating it;
  callers must select eligible orders and use the appropriate downstream process.
- The stock reader currently performs one MARD read per distinct location and one
  MARA read per distinct found material per call. Large selection performance
  still needs SAP measurement; repeated material-master reads across locations
  were removed without introducing a cache across calls.

## Resolved

- Runtime 2.13.90 failed with `Cannot read properties of undefined (reading 'get')`
  when inserting a request into a hashed table keyed by nested `origin-reservation`
  components. Lint and transpilation had succeeded. The checked-issue wrapper now
  indexes a flat reservation key with the request as payload; duplicate/missing-key
  regressions and the complete SAP-reader-to-writer fixture pass in both tool stages.

- Transpiler 2.13.74 emitted the reserved JavaScript identifier `return` for a BAPI
  TABLES declaration. Inspected fresh output from pinned 2.13.90: both standard
  function groups now emit `$return` correctly. Removed the generated-code patch
  and validated direct transpiler output with reservation and goods-issue stub tests.

- The order service validated request quantities and dates but trusted source order
  membership and policy. An injected source could allocate stock to an unselected
  order or omit provenance, bypassing downstream guards against independent writes.
  Reproduced with an unselected-order regression, then added hashed membership and
  priority/partial-policy checks before stock reads. Missing origins are rejected;
  custom order sources must now populate the documented provenance/policy contract.

- With npm `ignore-scripts=true`, automatic prelint/preunit hooks were skipped.
  Without `.deps`, lint and transpile silently cloned the current dependency head,
  violating the revision lock (and failing offline). Main lint/unit commands now
  invoke dependency preparation explicitly, which checks the lock and clean cache
  before either tool starts. Validated with lifecycle hooks disabled and the pinned
  local checkout; no global npm setting was changed.

- Reservation validation rejected valid decimal allocations in the transpiled
  runtime: `0.300 - 0.100` compared directly with `0.200` used binary floating-point
  expression precision. Assigning the expected shortage to the three-decimal
  quantity type before comparison restores the ABAP quantity contract. Added a
  fractional reservation regression test.
- Inline DATA declarations in START-OF-SELECTION transpiled without JavaScript
  variable declarations. The demo uses explicit global declarations and has a
  report execution smoke check in addition to ABAP Unit tests.
- Windows PowerShell execution policy blocks npm.ps1 on this workstation. Use
  `npm.cmd test` to run the same validation without changing execution policy.

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
