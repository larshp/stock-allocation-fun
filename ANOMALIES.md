# Anomalies and open issues

## RESOLVED-001: availability could change before posting

`zcl_stock_reader_sap` reads a snapshot before `zif_allocation_writer` is
called. The writer now claims request IDs, acquires exclusive `MARD` pool locks,
performs an aggregate fresh-stock recheck, and holds the locks through BAPI
commit or rollback.

## RESOLVED-002: productive allocation writer was not implemented

Resolved on 2026-08-18 by `zcl_allocation_writer_sap` and
`zcl_reservation_gateway_sap`. The writer calls `BAPI_RESERVATION_CREATE1`,
commits successful batches, rolls back failed batches, and exposes reservation
numbers and BAPI messages through allocation results.

## RESOLVED-003: idempotency was execution-local

Resolved on 2026-08-18 with an atomic insert into the owned `ZSTOCK_ALLOC`
table. Its client/request-ID key arbitrates concurrent claims. The claim and
reservation number are committed by the same BAPI transaction commit; posting
failures roll both back.

## RESOLVED-004: safety stock was repeated per storage location

`MARC-EISBE` is plant-level while allocation pools are storage-location-level.
Resolved by reading all locations for requested material/plant pairs and
maintaining a shared plant balance. Allocation is limited by both location stock
and the plant total after one safety reserve; posting revalidation applies the
same aggregate rule.

## OPEN-005: standard stubs require target-release verification

The local BAPI and DDIC stubs contain only the fields and parameters used by
this solution. They prove local syntax and transpilation, not that a particular
SAP release has an identical activated interface. Compare the function-module
interfaces and field semantics in the target system before deployment.

## TOOL-001: transpiler did not escape function parameter `RETURN`

When the standard BAPI stubs were first transpiled, the generated JavaScript
declared `let return`, causing a strict-mode syntax error before tests ran. The
supported transpiler `options.keywords` setting now includes `return`, producing
the safe identifier `return_` while leaving the ABAP BAPI signature unchanged.

## RESOLVED-006: external stock locking was target-specific

Resolved with the custom `EZSTOCK_POOL` lock object rooted on `MARD`. SAP enqueue
collisions are based on locked table, lock argument, and mode, so compatible
external locks on the same material/plant/storage-location pool collide even if
they originate from another lock object. Deployment must still verify the key
granularity used by the target system's inventory processes.

## RESOLVED-007: operational audit was current-state only

`ZSTOCK_ALOG` continues to store the latest productive and simulation outcome
for each request ID. `ZSTOCK_ALGH` now also receives a UUID-keyed row for every
outcome. Both representations are persisted atomically through
`zif_allocation_log_store`.

## RESOLVED-008: audit history lacked a retention mechanism

Resolved with `zcl_allocation_log_retention` and report
`ZSTOCK_ALGH_RETENTION`. The report defaults to a 365-day dry run, exposes the
retention period as a parameter, checks `S_TABU_NAM` display or delete activity,
and reports the number of matching or deleted rows. Productive systems should
schedule it according to their approved retention policy.

## RESOLVED-009: audit history had deletion but no export

Resolved with the read-only `ZSTOCK_ALGH_EXPORT` report. It provides bounded
date, request-ID, and run-mode filtering; checks table-display authorization;
and emits CSV-safe records to a wide foreground list or background spool before
retention deletion is scheduled. Exports that exceed the selected row limit are
rejected rather than silently truncated.

## OPEN-010: automated archive delivery is target-specific

The export report deliberately stops at SAP list/spool output. Landscapes that
require unattended transfer to content storage still need a target-approved
destination, credential model, encryption policy, and delivery mechanism.

## RESOLVED-011: allocation quantities had no unit of measure

Resolved by reading `MARA-MEINS`, requiring it on every request, preserving it
in allocations and audit records, checking it again against fresh stock, and
passing it as `BAPI2093_RES_ITEM-ENTRY_UOM`. This prevents quantities expressed
in different units from being silently compared or posted.

## RESOLVED-012: alternative units were not converted

Resolved with `zif_unit_converter`, the testable `zcl_unit_converter`, and a
cached SAP `MARM` factor reader. Alternative quantities are converted with
`UMREZ/UMREN`, rounded to the three-decimal stock precision, and allocated in
the `MARA-MEINS` base unit. Source and canonical values remain available in the
result, audit tables, and CSV export. Missing or invalid factors reject only the
affected request.

## OPEN-013: catch-weight and parallel units are not modeled

The converter supports classic material-specific `MARM` factors. Landscapes
using catch-weight materials, parallel units, batch-specific proportions, or
other industry extensions need a specialized conversion implementation behind
`zif_unit_converter` before those materials are admitted.

## RESOLVED-014: completed retries were reported as posting failures

`ZSTOCK_ALLOC` now persists the request identity, allocation policy, canonical
outcome, and reservation number. Productive execution resolves completed
records before allocation, so an identical retry returns the original result
without consuming current stock or invoking the writer. Reusing an ID with a
different payload is rejected. A concurrent duplicate appearing after the
pre-read remains a rollback failure and succeeds as a replay on a later retry.

## RESOLVED-015: legacy idempotency rows were ambiguous

Systems upgrading an existing `ZSTOCK_ALLOC` table may have reservation rows
without the expanded request identity. `PAYLOAD_VERSION` now distinguishes
current version `001` claims from blank legacy and future unsupported rows.
Unsupported records return a dedicated invalid result before stock access or
posting. Deployment must still reconcile, archive, or deliberately retain those
rows, but runtime behavior is explicit and cannot silently create a duplicate
reservation.

## RESOLVED-016: consumption reservations lacked account assignment

Requests now carry cost center, order, and WBS element through validation,
posting, idempotency, and audit. The allocator requires the standard assignment
for movement types 201, 221, and 261 before any stock is consumed or reservation
is attempted.

## RESOLVED-017: standard consumption assignments were incomplete

The request contract now covers the standard assignments for movement types
201, 221, 231, 241, 251, 261, and 281. Sales-order item, asset subnumber, and
network activity are retained through replay, posting, audit, and export. The
gateway also maps the external WBS identifier to `BAPI2093_RES_HEAD-WBS_ELEMENT`
instead of the internal numeric WBS field.

## OPEN-018: movement 291 and customized field selection are not modeled

Movement 291 permits arbitrary account assignments, and customer movement-type
customizing can make additional fields required or forbidden. The allocator
intentionally validates the standard fixed mappings only. Verify target field
selection and extend the policy before admitting movement 291 or customized
movement types.
