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

## OPEN-004: safety stock is repeated per storage location

`MARC-EISBE` is plant-level while allocation pools are storage-location-level.
Applying the full plant safety stock to every requested storage location is
conservative but can under-allocate multi-location plants. A configurable
plant-level policy is needed before multi-location optimization is added.

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

## OPEN-007: operational audit is current-state, not append-only

`ZSTOCK_ALOG` stores the latest productive and simulation outcome for each
request ID. This supports operations without unbounded growth, but does not
preserve every simulation attempt. Use the target system's SAP Application Log
policy if append-only history or formal retention is required.
