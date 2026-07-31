# Stock allocation fun

An ABAP stock allocation vertical slice for an existing SAP system.

The current branch provides deterministic priority allocation with explicit full/partial/unallocated line status, preserved SAP sales-document/item/schedule-line keys, and sales-unit validation, SAP-facing MARD and sales-order readers (VBAP/VBEP/VBAK), per-demand reservation posting through `BAPI_RESERVATION_CREATE1` plus `BAPI_TRANSACTION_COMMIT`, explicit goods-issue and sales-order schedule-line write boundaries through `BAPI_GOODSMVT_CREATE` and `BAPI_SALESORDER_CHANGE`, compensating reservation deletion on partial failure, reservation-document persistence, queryable and explicitly retainable run-level audit history in `ZSTOCKALLOC_RUN`, and a custom `ZSTOCKALLOC` result table. SAP-standard table and API test stubs are kept in `sap_stubs/`; application objects beginning with `Z` are kept in `src/`.

Run the checks with:

```text
npm test
npm run verify
```

`npm test` transpiles and runs the generated ABAP Unit harness. `npm run verify` adds the lint pass. The transpiler configuration uses Open ABAP Core as a dependency and emits the ABAP Unit runner into `output/`.
