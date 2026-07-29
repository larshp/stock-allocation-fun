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

## A-011 — Rolled-back failures are not stored in the transactional audit table

`ZSALLOC_LOG` is intentionally in the business LUW, so failed operations and their
audit inserts roll back together. Committed changes are never unlogged, but failure
diagnostics must come from job logs, dumps, or external monitoring. A future BAL
integration could persist failure diagnostics independently without weakening the
ledger transaction.

## A-012 - Sales and stockkeeping quantities cannot be mixed (resolved)

The original VBEP adapter subtracted `BMENG` from `WMENG`. `WMENG` is the order
quantity in the sales unit, while MARD stock is managed in the material's base
unit. The adapter and reconciler now use `LMENG`, SAP's required quantity for
material management in stockkeeping units, with `BMENG` as the confirmed
quantity. A regression fixture deliberately makes `WMENG` differ from `LMENG`
so sales-unit arithmetic cannot silently return.

## A-013 - Ineligible sales documents can retain schedule lines (resolved)

VBEP rows alone do not prove that a demand remains eligible. The original join
could include rejected items and document categories other than sales orders,
while reconciliation could preserve allocations after rejection or a material or
plant change. Productive selection now requires sales-order category `VBTYP = C`,
an initial `VBAP-ABGRU`, and matching material/plant context. Reconciliation uses
the same eligibility rules and releases unsupported ledger quantities.

## A-014 - Empty joined aggregates fail in open-abap

The transpiled SQLite runtime returns JavaScript `null` for `SUM` over an empty
result and then fails while assigning it to an ABAP packed quantity. SAP Open SQL
initializes the aggregate target. Physical and confirmed quantity calculations
therefore select only their quantity columns into internal tables and total them
in ABAP. This preserves empty-result semantics in both runtimes at the cost of
transferring one small quantity per matching row.

## A-015 - Physical stock is not full ATP availability (partially addressed)

Using MARD alone allowed the custom ledger to reserve on-hand stock already
committed by SAP confirmations. Availability and `ZSALLOC_CHECK` now subtract
eligible `VBEP-BMENG` quantities as well as custom reservations. This is a safer
on-hand-stock invariant, but it still does not model future receipts, checking
groups/rules, scopes of check, batches, or every ATP element. A target-approved
released ATP API remains preferable where those semantics are required.

## A-016 - Reconciliation simulation skipped authorization (resolved)

The first reconciler delegated authorization to release operations. Simulation
and productive no-op runs therefore read ledger and sales-order state without an
authorization check. `ZCL_SALLOC_RECONCILER` now requires its own authorization
dependency, validates context, and checks activity `03` or `02` before its first
database access. Individual productive releases retain their service-level check.

## A-017 - Order identity cannot be upserted across contexts (resolved)

`ZSALLOC_ORDER` is keyed by the globally unique schedule-line identity. A generic
`MODIFY` could overwrite its material/plant attributes if an SAP item changed
context before its old allocation was reconciled, leaving the old stock aggregate
stranded. New ledger entries now use conflict-checked `INSERT`; an identity found
under another context is rejected before any write. Operators must reconcile the
old context before allocating the changed item.

## A-018 - Reconciliation release inflated shortage (resolved)

The generic release path assumes demand is unchanged, so it preserves requested
quantity and adds the released amount to shortage. Reusing it after confirmation,
rejection, or deletion left stale requested quantities and artificial shortages.
Reconciliation now supplies current supported demand, resets requested/shortage
accordingly, and records `RECONCILE`; manual `RELEASE` semantics remain unchanged.
