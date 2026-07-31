# Stock allocation fun

An ABAP stock allocation vertical slice for an existing SAP system.

The current branch provides deterministic priority allocation with explicit full/partial/unallocated line status, preserved SAP sales-document/type/item/schedule-line keys, material-unit conversion for both demand and available stock, audited stock reads and conversions, audited allocation-calculation, snapshot-read, lock-acquisition, and audit-finalization failures, explicit material-existence and base-unit validation, SAP demand-unit validation, filtering of header- and item-delivery-blocked sales orders, rejection auditing for SAP demand-source validation failures, injectable SAP reservation and goods-movement authorization boundaries using `M_RES_BWA` and `M_MSEG_WMB` for both the allocation service and direct BAPI adapters, serialized allocation through an injected SAP enqueue/dequeue boundary, a report preview mode that calculates and audits outcomes without reservations or snapshot writes, rejection audit rows for pre-side-effect validation failures, unit-scoped audit history, summaries, and retention, optional batch-scoped stock and allocation snapshots through MCHB with required-batch, batch-existence, shelf-life, minimum remaining shelf-life, restricted-status, and delivery-date compatibility validation from MARA/MCHA, SAP-facing MARD/MARA and sales-order readers (VBAP/VBEP/VBAK), per-demand reservation posting through `BAPI_RESERVATION_CREATE1` plus `BAPI_TRANSACTION_COMMIT` with preserved BAPI rejection text, explicit goods-issue and sales-order schedule-line write boundaries through `BAPI_GOODSMVT_CREATE` and `BAPI_SALESORDER_CHANGE`, compensating reservation deletion on partial failure, reservation-document persistence with audit-run and allocation-unit correlation, unit-keyed `ZSTOCKALLOC` snapshots that preserve parallel allocations in different units, queryable and explicitly retainable run-level audit history in `ZSTOCKALLOC_RUN` including the configured allocation unit, and a custom `ZSTOCKALLOC` result table. SAP-standard table and API test stubs are kept in `sap_stubs/`; application objects beginning with `Z` are kept in `src/`.

Run the checks with:

```text
npm test
npm run verify
```

`npm test` transpiles and runs the generated ABAP Unit harness. `npm run verify` adds the lint pass. The transpiler configuration uses Open ABAP Core as a dependency and emits the ABAP Unit runner into `output/`.

The `ZSTOCK_ALLOCATE` report prints the remaining quantity plus the unit-scoped run totals, allocated quantity, shortage, and last audit run ID/status/message after a successful allocation. Completed runs include explicit success or shortage messages; rejected allocations are reported with the latest audited status/message instead of escaping unhandled. Set `p_shelf` to require that a selected batch expires at least that many days from the allocation date. Select `p_test` to preview and audit the calculation without reservation or snapshot dependencies, reservations, or `ZSTOCKALLOC` writes.

The `ZSTOCK_ALLOC_PURGE` report executes audit retention only when `p_exec` is selected, rejects future cutoff dates, requires `S_TABU_NAM` delete authorization for `ZSTOCKALLOC_RUN`, and reports execution failures without an unhandled error. Material, plant, storage location, optional batch/unit, and the cutoff date scope the deletion; running audit rows remain protected by the audit service.

The read-only `ZSTOCK_ALLOC_HISTORY` report lists the scoped run ID, status, unit, available stock, demand count, allocated quantity, shortage, start timestamp, and diagnostic message for operational review; `p_stat` accepts `R`, `S`, `P`, or `E`, while `p_from` and `p_to` optionally filter the output by run-start date. History read failures are reported cleanly.
Direct sales-order schedule-line mutations can inject `V_VBAK_AAT` authorization for activity `02` using the supplied sales document type.

The `ZSTOCK_ALLOC_ORDER_UPDATE` report changes one sales-order schedule-line quantity through the authorized adapter only when `p_exec` is selected; without the checkbox it performs no mutation and reports BAPI failures cleanly.

The `ZSTOCK_ALLOC_GOODS_ISSUE` report posts one authorized goods issue through `BAPI_GOODSMVT_CREATE` only when `p_exec` is selected; without the checkbox it performs no mutation and reports BAPI failures cleanly.
