# Implementation plan

Build a stock allocation solution in ABAP one production-capable feature at a
time. It must integrate into an existing SAP system and follow ABAP development
best practices.

## Engineering constraints

- Keep all custom objects beginning with `Z` in `src/`.
- Keep local SAP standard API and DDIC stubs in `sap_stubs/` and include that
  directory in linting and transpilation.
- Use `open-abap/open-abap-core` as a dependency in both configurations.
- Run abaplint and transpiled ABAP Unit tests for every feature.
- Record implementation progress in `NOTES.md` and defects or risks in
  `ANOMALIES.md`.
- Enable `modify_only_own_db_tables`, `align_type_expressions`,
  `easy_to_find_messages`, `max_one_method_parameter_per_line`,
  `align_parameters`, `local_testclass_consistency`, `allowed_object_naming`,
  and `line_length`.

## Roadmap

- [x] Establish abaplint, transpiler, open-abap-core, and ABAP Unit tooling.
- [x] Allocate by priority across material/plant/storage-location stock pools.
- [x] Support safety stock, partial fulfillment, and all-or-nothing requests.
- [x] Reject invalid and duplicate requests deterministically.
- [x] Add simulation and injectable read/write integration ports.
- [x] Read unrestricted and safety stock from SAP `MARD` and `MARC` tables.
- [x] Protect one shared plant-level safety reserve across multiple storage
      locations without deducting `MARC-EISBE` repeatedly.
- [x] Rank equal-priority demand by earliest requirement date.
- [x] Write successful allocations through a release-appropriate SAP standard
      reservation or order API, with commit/rollback and message handling.
- [x] Add idempotency persistence so a request cannot be posted twice across
      processes or retries.
- [x] Add a minimum fulfillment threshold for partial allocations.
- [x] Add selectable ordering strategies beyond priority and requirement date.
- [x] Recheck aggregate availability after idempotency claims and immediately
      before reservation posting.
- [x] Serialize stock pools with an exclusive SAP enqueue lock rooted on
      `MARD`, held across recheck and reservation commit/rollback.
- [x] Add an application entry point and operational logging suitable for the
      target SAP landscape.
- [x] Retain append-only UUID-keyed audit history alongside current-state
      operational records.
- [x] Add configurable, authorization-checked audit-history retention with a
      dry-run-first executable report.
- [x] Add bounded, filterable CSV audit-history export for foreground use or
      background spool processing.
- [x] Carry the material base unit through allocation, revalidation,
      reservation posting, audit persistence, and export.
- [x] Convert material-specific alternative units to the base unit using cached
      `MARM` numerator/denominator factors while retaining source values.
- [x] Replay completed idempotent requests before allocation and reject request
      IDs reused with a different payload.
- [x] Validate and carry the standard consumption account assignments for
      movement types 201 (cost center), 221 (WBS element), and 261 (order).
- [x] Version persisted idempotency payloads and reject legacy or unsupported
      records explicitly before stock reads or posting.
- [x] Support the remaining standard consumption assignments for sales orders
      (231), assets (241), sales cost centers (251), and networks (281).
- [x] Check plant-level `M_MATE_WRK` change authorization before idempotency
      replay or stock access, including for simulation runs.
- [x] Reject movement types outside the explicitly modeled standard
      consumption set before conversion, allocation, or posting.
- [x] Add an optional allocation horizon that defers future demand before stock
      reads while preserving completed idempotent replay.
- [x] Reopen an exactly matching request after its reservation is explicitly
      cancelled, replacing the old claim atomically with the new posting.
- [x] Add an opt-in full-batch policy that posts new reservations only when
      every new request is fully allocatable.
- [x] Correlate every application call and its audit rows with a shared,
      filterable run ID returned to the caller.
- [x] Persist the complete stock identity and request/run decision policy in
      current and historical audit rows and CSV export.
- [x] Add stable machine-readable decision codes to allocation results,
      operational audit, history, and CSV export.
