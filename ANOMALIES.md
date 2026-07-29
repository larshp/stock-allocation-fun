# Anomalies and open integration issues

## A-001 — MARC does not contain unrestricted-use stock

The plan cites MARC as carrying available stock. MARC identifies plant-level
material data and includes planning quantities such as safety stock (`EISBE`),
but unrestricted-use storage-location stock is held in MARD (`LABST`). Both
tables are stubbed so an SAP adapter can validate the material/plant in MARC and
aggregate physical stock from MARD. True ATP availability also depends on
receipts, requirements, checking rules, batches, and other configuration, so a
productive implementation should prefer the site's released ATP API.

## A-002 — The productive write operation was underspecified (resolved)

"Writing stock" may mean confirming SD schedule lines, creating an MM
reservation, posting a goods movement, or maintaining a custom allocation
ledger. These operations require different mandatory inputs and authorization,
locking, update-task, and rollback behavior. The implementation now deliberately
selects a custom allocation ledger. It does not change SD confirmations, create
an MM reservation, or post a goods movement.

## A-003 — Cross-port atomicity (addressed in iteration 3)

The service reserves through the stock port before saving order allocations.
Both operations now run behind `ZIF_SALLOC_TRANSACTION`; checked failures roll
back and successful runs commit. `ZCL_SALLOC_TRANSACTION_SAP` maps this contract
to the SAP LUW. Productive stock and order adapters must not commit independently.
In-memory test doubles record transaction decisions but do not emulate SAP update
tasks or reverse their own state, so SAP-side contract testing remains required.

## A-004 — Simulation is not a reservation

Simulation deliberately performs read-only port calls outside an SAP LUW. Stock
or open demand can change after a simulated result and before a productive run.
Consumers must present simulation as an estimate and must use the productive run's
returned allocations as the authoritative result.

## A-005 — Generated unit runner has no database by default (resolved)

The first database-backed adapter tests failed before ABAP execution with
`Runtime, database not initialized`. The transpiler-generated runner does not
configure a database unless an options `setup` hook is supplied. An older
`extraSetup` example was ignored by transpiler 2.13.43; its current structured
`setup.filename` and `setup.preFunction` configuration is required.
`test/setup.mjs` now creates the SQLite client and installs the generated DDIC
schema before ABAP Unit starts.

## A-006 — Database tests seed SAP standard stubs

The database-backed contract tests must insert and delete rows in local MARD,
VBAK, VBAP, and VBEP stubs. This triggers abaplint's
`modify_only_own_db_tables` rule even though productive classes only read those
tables. The rule uses a regular-expression exclusion for testclass files while
remaining active for all productive source. A glob-style exclusion was rejected
as an invalid regular expression during the first lint attempt.

## A-007 — External SD changes require reconciliation (addressed)

The ledger subtracts both current VBEP confirmed quantity and its own allocation
from open demand. If a schedule line is rejected, deleted, or confirmed by another
process, existing custom reservations can become stranded. `ZCL_SALLOC_RECONCILER`
now compares ledger allocations with current schedule-line quantities and releases
the unsupported amount. `ZSALLOC_RECONCILE` provides simulation-first interactive
or scheduled execution. Target operations must still schedule it at an appropriate
frequency.

## A-008 — Optimistic concurrency requires SAP-side load testing

Reservation and release recheck quantities and update ledgers only when the value
read has not changed. SQLite tests cover the SQL paths and stale-availability
failure, but cannot create true parallel SAP work processes. Multi-session testing
on the target database is still required before productive rollout.

## A-009 — Authorization roles require target-system maintenance

The repository defines and checks `Z_SALLOC`, but it cannot create customer role
assignments. Security administration must add activity `03` for simulation users
and activity `02` only for approved allocation/reconciliation operators, restricted
to the appropriate plants.

## A-010 — open-abap promises share system fields

Two concurrent transpiled calls share global `SY-SUBRC`. Under contention the
successful insert can therefore observe the losing insert's subrc and both callers
report failure, although the database correctly contains only one reservation.
The local concurrency gate asserts the safety invariant (no oversubscription), not
exactly one successful caller. Real SAP work processes have separate system fields;
target-system multi-session testing remains a required rollout gate.
