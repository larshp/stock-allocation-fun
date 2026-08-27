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
- [x] Serialize material/plant safety-stock domains with a generic-location SAP
      enqueue lock rooted on `MARD`, held across recheck and commit/rollback.
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
- [x] Add decision-code filtering to authorized audit-history reads and the
      executable CSV export report.
- [x] Capture whether usable availability was evaluated and the quantity seen
      at each allocation decision in results, audit, and CSV export.
- [x] Add independent material, plant, and storage-location filters to the
      authorized audit-history reader and executable export report.
- [x] Add movement-type, allocation-status, and posting-status filters to
      authorized audit-history export.
- [x] Reject zero or negative canonical quantities before allocation arithmetic,
      including successful responses from replaceable unit converters.
- [x] Add exact produced- and prior-reservation filters to authorized audit
      history reads and executable CSV export.
- [x] Add an independent inclusive requirement-date interval to authorized
      audit-history reads and executable CSV export.
- [x] Fail closed on noncanonical ABAP boolean values before request arithmetic
      or run-level side effects, with explicit and auditable outcomes.
- [x] Enforce one modeled account-assignment family per supported movement type
      before unit conversion or stock evaluation.
- [x] Reject unsupported allocation strategies at the service boundary before
      authorization, replay, stock, conversion, or posting dependencies.
- [x] Share pure request validation with orchestration so malformed rows skip
      business-data dependencies without changing their final outcomes.
- [x] Acquire batch idempotency claims in deterministic request-ID order while
      preserving business order for recheck and reservation posting.
- [x] Preserve successful reservation create and commit warnings in posting
      results, audit history, and CSV export without weakening error rollback.
- [x] Load persisted idempotency replay payloads for a productive batch with one
      guarded set-oriented query over its unique valid request IDs.
- [x] Classify cancellation for all unique persisted reservation IDs with one
      guarded set-oriented `RESB` read while preserving fail-safe replay rules.
- [x] Align stock-lock granularity with plant-level safety stock by serializing
      all storage locations for each material/plant allocation domain.
- [x] Neutralize spreadsheet-active prefixes in every audit CSV field while
      preserving delimiter and embedded-quote escaping.
- [x] Enforce valid date ranges and a hard row ceiling inside the public audit
      history SQL reader, independent of export-facade validation.
- [x] Fail closed on malformed retention simulation flags at both the facade
      and destructive history-store boundary.
- [x] Bound retention arithmetic and reject future effective dates or cutoffs
      that are not strictly before the application server date.
- [x] Add exact audit-history filtering by logging user and make the default
      export window exactly 30 inclusive calendar dates.
- [x] Add optional time-of-day boundaries to audit-history reads and export,
      composing them with the inclusive log-date interval.
- [x] Add exact audit-history filters for every modeled consumption
      account-assignment component.
- [x] Add audit-history filters for source/canonical units, allocation strategy,
      and an inclusive horizon-date interval.
- [x] Add unambiguous tri-state audit filters for partial policy, strict-batch
      policy, and availability-evaluated evidence.
- [x] Fail closed on malformed stock-lock wait flags and noncanonical enqueue
      gateway acquisition results.
- [x] Require canonical success acknowledgements at every transactional writer
      gate before reservation posting can advance.
- [x] Fail closed on noncanonical authorization, conversion-factor, and
      unit-converter result flags before protected work or arithmetic.
- [x] Validate replay lookup scope and canonicalize remaining audit, retention,
      logger, and application adapter result flags.
- [x] Persist and export shortfall quantity and fulfillment percentage, with
      fail-closed validation of replayed canonical outcomes.
- [x] Add a tri-state shortage selector to authorized history reads and the
      executable CSV export pipeline.
- [x] Add full, partial, and none fulfillment-band filtering over persisted fill
      percentage throughout the authorized export pipeline.
- [x] Enforce the persistable `DEC(13,3)` numeric domain for request quantities,
      minimum-fill policy, priority, and converted canonical quantities.
- [x] Add evidence-aware positive and zero usable-stock filtering to authorized
      audit reads and the executable CSV export pipeline.
- [x] Add inclusive priority, requested-quantity, and allocated-quantity ranges
      to authorized audit reads and the executable CSV export pipeline.
- [x] Require an affirmative, scope-valid cancellation-status lookup before
      reopening persisted reservation requests.
- [x] Distinguish successful empty stock reads from failed or malformed reader
      results during allocation and transactional stock revalidation.
- [x] Validate successful stock snapshots for requested scope, persistable
      quantities, material-unit consistency, and shared safety-stock identity.
- [x] Require canonical batch-level success before interpreting set-oriented
      idempotency replay lookup rows.
- [x] Validate allocation-writer response cardinality, immutable payload,
      posting states, document evidence, and atomic batch consistency.
- [x] Fail closed on unknown or blank reservation API message types during both
      reservation creation and transactional commit.
- [x] Reject nonnumeric or duplicate reservation document IDs before linking
      them to idempotency claims or committing a posting batch.
- [x] Reject malformed or cross-request reused reservation IDs in persisted
      replay outcomes before cancellation classification or stock access.
- [x] Add an independent inclusive fulfillment-percentage range to authorized
      audit reads and CSV export, composable with fulfillment bands.
- [x] Add an independent inclusive minimum-fulfillment-policy range to
      authorized audit reads and the executable CSV export.
- [x] Add inclusive original-demand, observed-availability, and shortfall
      quantity ranges to authorized audit reads and CSV export.
- [x] Add exact immutable-row UUID and diagnostic-message selectors to
      authorized audit reads and the executable CSV export.
- [x] Revalidate every returned audit row against the complete requested export
      scope before producing CSV from a replaceable history reader.
- [x] Preflight pending allocation identity, quantity precision, status, and
      document state inside the public SAP writer before protected side effects.
- [x] Reject impossible retention-store affected-row evidence at the public
      cleanup facade.
