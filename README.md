# Stock Allocation for ABAP

A small, dependency-injected stock allocation core for an existing SAP system.
It distributes a material/plant's available quantity across open demands in a
deterministic order: highest priority first, then earliest requested date, then
order ID. Partial fulfillment is supported. Each result carries both the
allocated quantity and its remaining shortage.

Duplicate order IDs are rejected before any result is changed. Callers may pass
`iv_simulate = abap_true` to calculate the same result without reserving stock,
saving allocations, or opening a transaction.

## Design

- `ZCL_SALLOC_ALLOCATOR` contains pure allocation and validation logic.
- `ZCL_SALLOC_SERVICE` orchestrates stock and order ports.
- `ZIF_SALLOC_STOCK` and `ZIF_SALLOC_ORDERS` isolate SAP-specific access.
- `ZIF_SALLOC_TRANSACTION` makes SAP LUW ownership and rollback explicit.
- `ZCL_SALLOC_*_STUB` are in-memory test doubles.
- `ZCL_SALLOC_STOCK_SAP` reads MARC/MARD and maintains `ZSALLOC_STOCK`.
- `ZCL_SALLOC_ORDERS_SAP` reads VBAP/VBEP and maintains `ZSALLOC_ORDER`.
- `ZCL_SALLOC_FACTORY` assembles the productive adapters and SAP LUW boundary.
- `sap-stubs/` contains only standard DDIC test surfaces and is not transported.

The productive target is a custom allocation ledger. It reserves quantities for
sales-order schedule lines without posting a goods movement, creating an MM
reservation, or changing SD confirmations. Allocation identity is
`VBELN + POSNR + ETENR`.

Stock and demand quantities are compared in the material's base/stockkeeping
unit: physical stock comes from `MARD-LABST`, schedule-line requirements from
`VBEP-LMENG`, and confirmed quantities from `VBEP-BMENG`. `VBEP-WMENG` is a
sales-unit quantity and is intentionally not used for stock allocation.

Demand selection is limited to sales-order document category `C`, excludes items
with `VBAP-ABGRU`, and matches the requested material and plant. Reconciliation
uses the same rules so rejection or item-context changes release stale allocation.
Standard `VBAP-LPRIO` drives productive priority: because SAP value `01` is
highest, it is translated to a descending internal rank before allocation.
An allocated schedule-line identity cannot be reassigned to another material or
plant; reconcile its old context before allocating the changed item.

Allocatable on-hand stock is `MARD-LABST` less eligible SAP-confirmed
`VBEP-BMENG` and less `ZSALLOC_STOCK` reservations. This prevents the custom
ledger from double-committing stock already confirmed by SD; it remains an
on-hand proxy rather than a replacement for a configured ATP API.

`ZCL_SALLOC_TRANSACTION_SAP` supplies the productive LUW boundary. Stock and
order adapters used with the service must join that LUW and must not issue their
own commits. Any checked allocation or integration failure rolls the LUW back.

## SAP usage

Install the Z objects from `src/`, then run report `ZSALLOC_RUN`. It starts in
simulation mode. Clear the simulation checkbox only after the custom ledger and
operational procedures are approved for the target system.

Productive access is checked with authorization object `Z_SALLOC`: activity `03`
for simulation and `02` for allocation, release, and reconciliation writes, scoped
by plant (`WERKS`).

Run `ZSALLOC_RECONCILE` to detect allocations no longer supported by current VBEP
quantities, including deleted schedule lines. It also defaults to simulation and
reports every affected schedule line plus the total quantity that would be
released. Reconciliation resets ledger demand and shortage to current
SAP-supported quantities and logs `RECONCILE`, while a manual release retains
demand and increases shortage.

Run `ZSALLOC_RELEASE` for an explicit material, plant, and
`VBELN + POSNR + ETENR` allocation identity. It defaults to a read-only ledger
check; productive mode uses the same authorized, transactional, audited release
operation as reconciliation.

Run `ZSALLOC_LOG` to inspect the authorized plant's committed allocation and
release audit records. Logging is mandatory in the service constructor; an audit
failure rolls the transaction back. Allocation events are recorded per sales-order
schedule line rather than as an untraceable aggregate.

Run simulation-first `ZSALLOC_LOG_CLEANUP` with an explicit cutoff timestamp for
authorized, plant-scoped retention. Productive cleanup commits its own retained
`LOG_RETENTION` audit event. See `OPERATIONS.md` for scheduling and incident
procedures.

Run read-only `ZSALLOC_CHECK` to compare physical MARD stock with commitments and
to prove the stock-ledger total equals summed per-order allocations. Follow
`SAP_DEPLOYMENT.md` and `SAP_CONCURRENCY_TEST.md` before each productive rollout.

## Local verification

Requires Node.js 18 or newer.

```text
npm install
npm test
```

`npm test` runs abaplint, transpiles both `src/` and `sap-stubs/`, executes ABAP
Unit under open-abap, and runs a concurrent reservation safety probe.
