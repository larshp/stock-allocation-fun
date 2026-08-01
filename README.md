# Stock allocation fun

An ABAP stock allocation vertical slice for an existing SAP system.

The current branch provides deterministic priority allocation with explicit full/partial/unallocated line status, preserved SAP sales-document/type/item/schedule-line keys, material-unit conversion for both demand and available stock, audited stock reads and conversions, audited allocation-calculation, snapshot-read, lock-acquisition, and audit-finalization failures, explicit material-existence and base-unit validation, SAP demand-unit validation, filtering of header- and item-delivery-blocked sales orders, rejection auditing for SAP demand-source validation failures, injectable SAP reservation and goods-movement authorization boundaries using `M_MRES_BWA`/`M_MRES_WWA` (reservation type/plant create/delete) and `M_MSEG_BWA`/`M_MSEG_WWA`/`M_MSEG_LGO` (goods-movement type/plant/storage) for both the allocation service and direct BAPI adapters, serialized allocation through an injected SAP enqueue/dequeue boundary, an explicit injectable allocation transaction boundary for replacement and retention writes, a report preview mode that calculates and audits outcomes without reservations or snapshot writes, rejection audit rows for pre-side-effect validation failures, unit-scoped audit history, summaries, and retention that removes linked allocation snapshots, optional batch-scoped stock and allocation snapshots through MCHB with required-batch, batch-existence, shelf-life, minimum remaining shelf-life, restricted-status, and delivery-date compatibility validation from MARA/MCHA, SAP-facing MARD/MARA and sales-order readers (VBAP/VBEP/VBAK), per-demand reservation posting through `BAPI_RESERVATION_CREATE1` plus `BAPI_TRANSACTION_COMMIT` with preserved BAPI rejection text, explicit goods-issue and sales-order schedule-line write boundaries through `BAPI_GOODSMVT_CREATE` and `BAPI_SALESORDER_CHANGE`, compensating reservation deletion on partial failure, reservation-document persistence with audit-run and allocation-unit correlation, unit-keyed `ZSTOCKALLOC` snapshots that preserve parallel allocations in different units while reconciling active cross-unit reservations against shared stock, queryable and explicitly retainable run-level audit history in `ZSTOCKALLOC_RUN` including the configured allocation unit, and a custom `ZSTOCKALLOC` result table. SAP-standard table and API test stubs are kept in `sap_stubs/`; application objects beginning with `Z` are kept in `src/`.

The service validates injected provider and allocator postconditions before side effects, preserves demand identity and source metadata, rejects inconsistent or stale snapshot reservation metadata, preflights cancellation authority for legacy reservations, and persists replacement snapshots before canceling superseded reservations. Cleanup uncertainty is recorded as a partial run with the actionable diagnostic; failed persistence leaves the prior snapshot/reservation pair untouched.

Snapshot persistence and reads verify that the supplied run ID exists in `ZSTOCKALLOC_RUN`, has a recognized lifecycle status, and belongs to the same material/plant/storage/batch/unit scope. Writes additionally require the run to be active, while reads accept any legitimate lifecycle status so operators can inspect finalized results. Direct result writers cannot create orphaned snapshots, and result readers cannot silently consume orphaned, malformed, or cross-scope rows.

Run the checks with:

```text
npm test
npm run verify
```

`npm test` transpiles and runs the generated ABAP Unit harness. `npm run verify` adds the lint pass. Open ABAP Core is pinned by commit as an npm development dependency; lint and transpilation use its installed local folder, so checks do not require a fresh GitHub clone after `npm install`. The transpiler emits the ABAP Unit runner into `output/`.

The `ZSTOCK_ALLOCATE` report prints the remaining quantity plus the unit-scoped run totals, allocated quantity, shortage, last audit run ID, start/finish timestamps, requested-delivery window, and status/message after a successful allocation. Set `p_from` and `p_until` to allocate only open schedule lines inside an inclusive requested-date window; either bound may be blank. Reversed windows are rejected before allocation side effects. Completed runs include explicit success or shortage messages; rejected allocations are reported with the latest audited status/message, while the original service diagnostic is retained if the audit summary itself is unavailable. Set `p_shelf` to require that a selected batch expires at least that many days from the allocation date. Select `p_test` to preview and audit the calculation without reservation or snapshot dependencies, reservations, or `ZSTOCKALLOC` writes. Selecting `p_json` emits the completed allocation summary as one JSON object with scope, quantities, counters, run identity, timestamps, status, and diagnostic fields; authorization or execution failures emit a JSON error envelope.
Run audit rows now also persist full, partial, and unallocated demand-line counts plus both requested-delivery window bounds. `ZSTOCK_ALLOCATE` and `ZSTOCK_ALLOC_HISTORY` display those values alongside quantity metrics.

The `ZSTOCK_ALLOC_PURGE` report previews eligible audit-run and linked-snapshot counts when `p_exec` is not selected, including older running rows that remain protected, and executes audit retention only when `p_exec` is selected. It rejects incomplete or future cutoff scopes, requires `S_TABU_NAM` delete authorization for both `ZSTOCKALLOC_RUN` and linked `ZSTOCKALLOC` rows, and reports execution failures with the returned authorization or persistence diagnostic. The audit API repeats the scope and future-date safeguards for direct callers. Material, plant, storage location, optional batch/unit, and the cutoff date scope the deletion; running audit rows remain protected by the audit service.

Selecting `p_json` on `ZSTOCK_ALLOC_PURGE` emits a JSON preview or execution summary with the retention scope, eligible/protected counts, linked snapshots, or deleted run count; validation, authorization, preview, and execution failures emit a JSON error envelope.

The allocation, history, and result reports require `S_TABU_NAM` read authorization for the audit or result table they query and report missing authorization cleanly. Allocation execution additionally requires activity `02` write authorization for `ZSTOCKALLOC_RUN` audit rows, activity `02` change authorization for `ZSTOCKALLOC` result rows, and activity `06` delete authorization for snapshot replacement; purge enforces activity `06` retention authorization for both affected tables at the API boundary. The concrete SAP adapters also default to their standard authorization ports when called directly without dependency injection, so callers cannot bypass these checks by omitting an optional port.

The read-only `ZSTOCK_ALLOC_HISTORY` report lists the scoped run ID, status, unit, requested-delivery window, available stock, demand count, allocated quantity, shortage, start and finish timestamps, elapsed duration in seconds, and diagnostic message for operational review; running rows have no finish timestamp or duration. It prints lifecycle, quantity, allocation coverage percentage, and full/partial/unallocated demand totals for the filtered population before the detail rows, omitting quantity aggregation when the rows use different units. `p_runid` optionally selects one exact audit run, while `p_reqf` and `p_until` filter the output to one persisted requested-delivery window; reversed horizon bounds are rejected. `p_stat` accepts `R`, `S`, `P`, or `E`, `p_from` and `p_to` optionally filter the output by run-start date, `p_ffrom`/`p_fto` optionally filter by finish date, `p_shf`/`p_sht` optionally filter by inclusive shortage range, `p_af`/`p_at` optionally filter by inclusive allocated-quantity range, `p_avf`/`p_avt` optionally filter by inclusive available-stock range, `p_qf`/`p_qt` optionally filter by inclusive derived requested-quantity range (`allocated + shortage`), `p_dfrom`/`p_dto` optionally filter by inclusive demand-count range, and `p_covf`/`p_covt` optionally filter by inclusive allocation-coverage percentage from 0 to 100. Runs with zero requested quantity are excluded when a coverage bound is supplied because coverage is not applicable. Selecting `p_shrt` orders history by descending shortage, then start chronology and run ID; without it, the default newest-started-first order is retained. Requesting a finish window excludes still-running rows. History read failures are reported cleanly. Direct summaries without a unit remain safe across parallel units: `mixed_units` is set and aggregate quantities are blank when runs use different units.

`p_tfrom`/`p_tto` optionally filter completed history rows by inclusive elapsed duration in seconds; running rows are excluded whenever a duration bound is requested, and negative or reversed bounds are rejected.

Selecting `p_tdur` orders history by elapsed duration descending, with start timestamp and run ID as deterministic tie-breakers. Coverage-first ordering takes precedence, followed by duration-first and then shortage-first ordering.

`p_msg` optionally filters history by a case-insensitive substring of the persisted diagnostic message, which is useful for isolating failure and cleanup reasons.

Selecting `p_monly` keeps only runs with a nonblank persisted diagnostic message; it can be combined with `p_msg` to narrow that diagnostic population further.
Direct sales-order schedule-line mutations can inject `V_VBAK_AAT` authorization for activity `02` using the supplied sales document type.

The `ZSTOCK_ALLOC_ORDER_UPDATE` report changes one sales-order schedule-line quantity through the authorized adapter only when `p_exec` is selected; without the checkbox it performs no mutation and reports BAPI failures cleanly.

Selecting `p_json` on `ZSTOCK_ALLOC_ORDER_UPDATE` emits a structured success object or JSON error envelope.

The `ZSTOCK_ALLOC_GOODS_ISSUE` report posts one authorized goods issue through `BAPI_GOODSMVT_CREATE` only when `p_exec` is selected; without the checkbox it performs no mutation and reports BAPI failures cleanly. Successful output includes both the material-document number and document year from `GOODSMVT_HEADRET`.

Selecting `p_json` on `ZSTOCK_ALLOC_GOODS_ISSUE` emits a structured success object or JSON error envelope, including the complete material-document identity.

The read-only `ZSTOCK_ALLOC_RESULT` report displays the scoped per-demand allocation status, requested delivery date, normalized allocation unit, original sales-order unit, requested/allocated/shortage quantities, sales-document type, reservation ID and lifecycle metadata (date, movement type, and unit), and audit run ID from `ZSTOCKALLOC`.

`ZSTOCK_ALLOC_RESULT` accepts an optional `p_meins` unit filter plus optional `p_runid`, `p_stat`, `p_vbeln`, `p_auart`, `p_posnr`, `p_etenr`, `p_ounit`, `p_order`, `p_resid`, `p_rmov`, `p_runit`, `p_rsv`, `p_rfrom`, `p_rto`, `p_from`, `p_to`, `p_priof`, `p_priot`, `p_shf`, `p_sht`, `p_qf`, `p_qt`, `p_af`, and `p_at` filters plus `p_pri`, `p_date`, and `p_shrt` sort checkboxes. When `p_meins` is blank, parallel result snapshots in all allocation units are displayed together. `p_runid` restricts output to one persisted audit run and prints that run’s lifecycle context, audit counters, and diagnostic message, even when the run has no snapshot rows yet. When `p_runid` is the only detail filter, the report also reconciles snapshot line/outcome counts and allocated/shortage quantities against the audit row and prints `OK` or `MISMATCH`; filtered views intentionally omit that comparison. `p_stat` accepts `F`, `P`, and `U` to show only fully allocated, partially allocated, or unallocated result lines, `p_vbeln` selects the persisted sales document, `p_auart` selects its document type, `p_posnr` selects its item, `p_etenr` selects its schedule line, `p_ounit` selects the original sales-order unit, `p_order` selects one derived demand key, `p_resid` selects a SAP reservation document, `p_rmov` selects a reservation movement type, `p_runit` selects the persisted reservation unit, `p_rsv` keeps only rows with a reservation ID, `p_rfrom`/`p_rto` select an inclusive reservation-posting-date window, `p_from`/`p_to` select an inclusive requested-delivery-date window, `p_priof`/`p_priot` select an inclusive allocator-priority range, `p_shf`/`p_sht` select an inclusive shortage-quantity range, `p_qf`/`p_qt` select an inclusive requested-quantity range, and `p_af`/`p_at` select an inclusive allocated-quantity range. Selecting `p_pri` orders rows by allocation unit, persisted priority, and order key; selecting `p_date` orders globally by requested delivery date, then allocation unit, priority, and order key; selecting `p_shrt` orders by descending shortage, then requested date, unit, priority, and order key. Sort precedence is `p_pri`, then `p_date`, then `p_shrt`. The report prints unit-safe requested, allocated, shortage, and allocation coverage totals plus the exact order ID and persisted allocation priority for reconciliation.

For any filtered result set, the report prints total lines and counts of fully allocated, partially allocated, and unallocated demands before the detailed rows. It also prints requested/allocated/shortage quantity totals when all rows share one allocation unit; mixed-unit result sets intentionally omit quantity aggregation.

Result-line `p_covf`/`p_covt` filters select inclusive allocation-coverage percentages from 0 to 100, calculated as allocated quantity divided by requested quantity. Lines with zero requested quantity are excluded when coverage bounds are supplied.

Selecting result-report `p_cov` orders lines by ascending allocation coverage, then descending shortage, requested date, allocation unit, priority, and order key. Sort precedence is priority (`p_pri`), coverage (`p_cov`), requested date (`p_date`), then shortage (`p_shrt`).

Result-report `p_max` caps the returned rows after filtering and sorting; a positive value is required for a cap, and capped exact-run views do not claim full reconciliation.

Selecting result-report `p_big` orders by descending requested quantity, then descending shortage, requested date, allocation unit, priority, and order key. Sort precedence is priority, coverage, largest demand (`p_big`), requested date, then shortage.

Selecting `p_done` orders by descending allocated quantity, then requested quantity, shortage, requested date, allocation unit, priority, and order key. It follows `p_big` and precedes requested-date/shortage ordering.

Selecting result-report `p_rdate` orders by reservation date ascending, then allocation unit, priority, and order key; unreserved rows sort first so reservation follow-up is immediately visible. It follows requested-date ordering and precedes shortage ordering.

Selecting result-report `p_csv` emits only the filtered detail rows as semicolon-delimited output with a stable header, including coverage and reservation provenance; human-readable summaries and reconciliation text are intentionally omitted.

CSV data fields are quoted and embedded quotes are doubled, so identifiers containing delimiters or quotes remain importable by standard CSV tools.

Selecting result-report `p_json` emits the same filtered detail rows as a JSON array with stable property names; JSON mode is mutually exclusive with `p_csv`, and validation, authorization, or read failures emit JSON error envelopes.

Empty result or history JSON selections emit `[]`.

Selecting `p_bklg` keeps only lines with positive shortage, combining partial and unallocated demand for backlog follow-up; capped or filtered exact-run views do not claim full reconciliation.

Selecting result-report `p_ovrd` keeps only lines whose requested delivery date is before today; blank dates and today/future dates are excluded, and the filtered view is not treated as an exact-run reconciliation.

Selecting result-report `p_unrsv` keeps only lines without a reservation ID for reservation follow-up; it is mutually exclusive with `p_rsv` and filtered views do not claim exact-run reconciliation.

History `p_csv` emits one semicolon-delimited row per filtered run with scope, requested horizon, quantities, coverage, lifecycle status, diagnostic message, outcome counts, and start/finish timestamps; human-readable summary text is omitted.

History `p_json` emits the same filtered runs as a JSON array with stable properties, including each run’s diagnostic message, and is mutually exclusive with history `p_csv`; validation, authorization, or read failures emit JSON error envelopes.

History `p_cov` orders runs by ascending allocation coverage, then descending shortage, newest start chronology, and run ID; it takes precedence over history `p_shrt` when both are selected.

History and result detail rows include a calculated Coverage column; rows with no requested quantity display `n/a`.

Selecting `p_sum` in either read-only report keeps the filtered totals and status metrics while suppressing detail rows; result-report exact-run context and reconciliation output are still shown.

Combining `p_sum` with `p_json` emits one compact summary object containing counts and unit-safe quantity totals instead of detail arrays; mixed-unit totals are reported as `n/a`.

History `p_max` caps returned runs after filtering and sorting; a negative value is rejected.
