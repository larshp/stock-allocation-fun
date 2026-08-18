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
