# Stock allocation fun

An ABAP stock allocation vertical slice for an existing SAP system.

The current branch provides deterministic priority allocation, SAP-facing MARD and sales-order readers (VBAP/VBEP/VBAK), aggregate reservation posting through `BAPI_RESERVATION_CREATE1` plus `BAPI_TRANSACTION_COMMIT`, reservation-document persistence, and a custom `ZSTOCKALLOC` result table. SAP-standard table and API test stubs are kept in `sap_stubs/`; application objects beginning with `Z` are kept in `src/`.

Run the checks with:

```text
npm run lint
npm run transpile
node output/index.mjs
```

The transpiler configuration uses Open ABAP Core as a dependency and emits the ABAP Unit runner into `output/`.
