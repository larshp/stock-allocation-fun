# Anomalies

No confirmed product defects are open.

## Resolved product defects

- The first database-backed stock-source test exposed that inline `SELECT labst ... INTO TABLE @DATA(...)` creates structured rows. The adapter incorrectly added the complete row to the result quantity; the keyed `MARD` read now selects directly into the quantity field, and the regression is covered by ABAP Unit.
- The first recommendation implementation reused a loop-local `lv_better` flag without clearing it. ABAP data declarations retain their value between loop iterations, causing the last exactly tied strategy to replace the stable first choice. The selector now clears the flag for every candidate, with a regression test proving input-order tie resolution.

## Tooling and environment observations

- The open-abap runtime can retain JavaScript floating residue in an untyped packed-number subtraction used directly in a comparison. The plan invariant gate assigns the expected shortage to the domain's three-decimal packed quantity before comparing it with the stored shortage; productive ABAP semantics are unchanged.
- Transpiler 2.13.47 cannot resolve the primitive type name in `CONV decfloat34( ... )`, although abaplint accepts the expression. Fairness calculations first assign packed quantities to the domain's `DECFLOAT34` aggregate type and then divide those typed variables; productive semantics are unchanged.
- The open-abap runtime provides an emulated database for unit testing, not SAP locking, update-task, authorization, or BAPI transactional behavior. Productive SAP integration still requires an integration test in the target system.
- The SAP-standard DDIC files under `sap_stubs` intentionally contain only fields used by this feature. They are compilation stubs and must never be imported into SAP.
- Initial local verification pinned transpiler/runtime 2.11.0, whose parser could not resolve the current interface table types. The project now pins 2.13.47; the global tool had masked this mismatch during the first run.
- A local `CX_NO_CHECK` test exception compiled with transpiler 2.13.47 but failed at runtime because the emitted local class symbol was not constructible. The exceptional-cleanup test uses standard `CX_SY_ZERODIVIDE` instead; production code is unaffected.
- Transpiler 2.13.47 did not execute a `CLEANUP` block while propagating `CX_SY_ZERODIVIDE` from the allocation sink. The service explicitly catches `CX_ROOT`, releases the lock, and wraps the failure in `ZCX_STOCK_ALLOCATION`; this path is covered by ABAP Unit.
- Transpiler 2.13.47 rejects APLO application-log metadata as a non-executable object type. `zstockalloc.aplo.json` remains covered by abaplint and abapGit but is explicitly excluded from transpilation.
- The generated transpiler unit runner does not initialize a database unless setup logic is configured. The first productive-adapter test therefore failed with `Runtime, database not initialized`; `test/runtime-setup.mjs` now connects the official pinned SQLite driver and loads the generated DDIC schema before tests run.
- The transpiled SQLite runtime does not provide SAP-compatible `sy-dbcnt` after bulk `MODIFY ... FROM TABLE`. Persistence verification therefore uses an Open SQL read-back check, which works consistently in the emulator and productive SAP.
- The open-abap packed-number runtime loses fractional precision close to the 15-digit field maximum because of its JavaScript numeric representation. The aggregate-overflow regression uses exact integer-valued quantities beyond the packed total ceiling; productive ABAP retains the declared three decimal places.
