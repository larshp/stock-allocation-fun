# Anomalies and known issues

## 2026-07-31

- Resolved: the local DDIC stubs initially omitted the abapGit wrapper and used unresolved SAP data elements. The stubs now use the standard wrapper plus built-in DDIC types and transpile successfully.
- Resolved: Open ABAP does not accept the attempted global SAP class stub in the application input set. The reservation adapter now calls the real SAP function-module names, while the test harness installs isolated FM doubles from `sap_stubs/`.
- Resolved: Open ABAP cannot execute selection-screen `PARAMETERS` in the generated Node harness. `importProg` is disabled for the transpiler bootstrap; the `ZSTOCK_ALLOCATE` report is still linted and transpiled for SAP deployment.
- Resolved: Open ABAP selects map result columns by name in the SQLite runtime. The order-source query now aliases SAP fields such as `LPRIO` and `WMENG` to the application structure names.
- Resolved: each allocated demand now receives its own reservation document, and previously created documents are compensated through `BAPI_RESERVATION_DELETE` if a later reservation fails.
- Resolved: sink persistence failures now trigger compensation for reservations created during the same allocation run.
- Resolved: repeat allocation runs no longer create duplicate reservations for unchanged allocated lines; the persisted snapshot is read first and matching reservation IDs are reused.
- Resolved: reservation reuse now compares the required date, movement type, and unit in addition to order and allocated quantity; changing movement type creates new reservations.
- Resolved: the initial goods-movement adapter draft used a nonstandard scalar return name; it now follows `BAPI_GOODSMVT_CREATE` and reads the material document from `GOODSMVT_HEADRET`.
- Resolved: reservation and goods-movement error paths now explicitly roll back the BAPI LUW before raising the domain exception.
- Resolved: the SAP-standard order-write requirement now has a dedicated schedule-line adapter and isolated FM stub; allocation does not change sales orders implicitly.
- Resolved: API stubs now validate the required goods-movement and schedule-line payload fields instead of accepting any non-error call shape.
- Resolved: timestamp-based audit IDs collided for same-second runs; audit records now use a UUID C32 key.
- Resolved: partial reservation cleanup is surfaced as audit status `P`, while ordinary reservation or persistence failures use status `E`.
- Resolved: audit history is now exposed through a typed query instead of requiring callers to read `ZSTOCKALLOC_RUN` directly.
- Resolved: audit retention is caller-invoked and date-scoped; active `R`unning records are protected from deletion.
- Resolved: consumers no longer need to infer line outcome from quantities; `ZSTOCKALLOC` now persists explicit full, partial, or unallocated status.
- Resolved: composite allocation order IDs no longer discard their SAP source keys; document, item, and schedule-line identifiers are now stored separately.
- Resolved: sales-order quantity units are no longer silently assumed to match the reservation unit; mismatches are rejected before allocation side effects.
- Resolved: reservation creation now checks `BAPIRET2` error types (`A`, `E`, and `X`) before calling `BAPI_TRANSACTION_COMMIT`.
- Resolved: the reservation adapter preserves the BAPI `sy-subrc` before looping over `RETURN`, because the loop itself changes `sy-subrc` for an empty message table.
- Resolved: the SQLite harness now sets `sy-mandt` to the seeded client `000`; Open ABAP’s default runtime client is `123`.
- Resolved: stock and sales-order readers now include explicit client predicates and client-aware joins; fixtures cover duplicate keys across clients.
- Resolved: a qualified `@sy-mandt` host expression was emitted incorrectly by the transpiler; the order reader now binds the client through a local variable.
- Resolved: allocation persistence now deletes the prior client/material/plant snapshot before writing the current demand set, preventing stale results.
- Resolved: reservation requests now carry the earliest allocated schedule date; direct reservation callers must provide a noninitial required date.
- Resolved: the allocator clears prior reservation identifiers when recalculating demand allocations.
- Resolved: the reservation adapter no longer passes application-only item field names to `BAPI_RESERVATION_CREATE1`; its local structures now mirror the standard BAPI communication structures.
