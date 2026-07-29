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
- `sap-stubs/` contains the minimal standard DDIC surface needed by future SAP
  adapters. It is compiled only for local tooling and must not be transported.

The first iteration intentionally leaves the target-specific SAP write adapters
behind ports. Confirming a sales-order schedule line or creating an MM reservation
are different business operations and cannot safely share a guessed implementation.
See `ANOMALIES.md` for the decisions still required before productive integration.

`ZCL_SALLOC_TRANSACTION_SAP` supplies the productive LUW boundary. Stock and
order adapters used with the service must join that LUW and must not issue their
own commits. Any checked allocation or integration failure rolls the LUW back.

## Local verification

Requires Node.js 18 or newer.

```text
npm install
npm test
```

`npm test` runs abaplint, transpiles both `src/` and `sap-stubs/`, executes ABAP
Unit under open-abap, and fails if any test result is unsuccessful.
