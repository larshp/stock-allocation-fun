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

## A-003 — Cross-port atomicity

The service reserves through the stock port before saving order allocations.
The operations must participate in one SAP LUW, and adapter failures must roll
back both changes. In-memory test doubles cannot emulate SAP update tasks. The
productive adapter iteration must add an explicit transaction boundary or use a
single standard API that owns both confirmation and ATP consumption.
