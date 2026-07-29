# Anomalies and open integration issues

## A-001 — MARC does not contain unrestricted-use stock

The plan cites MARC as carrying available stock. MARC identifies plant-level
material data and includes planning quantities such as safety stock (`EISBE`),
but unrestricted-use storage-location stock is held in MARD (`LABST`). Both
tables are stubbed so an SAP adapter can validate the material/plant in MARC and
aggregate physical stock from MARD. True ATP availability also depends on
receipts, requirements, checking rules, batches, and other configuration, so a
productive implementation should prefer the site's released ATP API.

## A-002 — The productive write operation is underspecified

"Writing stock" may mean confirming SD schedule lines, creating an MM
reservation, posting a goods movement, or maintaining a custom allocation
ledger. These operations require different mandatory inputs and authorization,
locking, update-task, and rollback behavior. The current ports expose the
decision boundary and test the orchestration, but no productive adapter guesses
which irreversible SAP document operation is intended.

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
