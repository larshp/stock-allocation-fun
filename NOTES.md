# Implementation notes

## 2026-08-18

- Created the Node-based ABAP development toolchain with pinned abaplint and
  transpiler versions. Both configurations load `open-abap-core`; SAP standard
  stubs are also transpiler inputs.
- Added `zcl_stock_allocator` as a side-effect-free domain service. Smaller
  numeric priorities run first, with request ID as a deterministic tie-breaker.
- Available quantity is bounded by both the selected location's `MARD-LABST`
  and the material/plant total remaining after one shared `MARC-EISBE` reserve.
  Quality and blocked stock are intentionally excluded.
- Stock reads join `MARA-MEINS`, and every request must name an internal SAP
  unit. `zcl_unit_converter` normalizes alternative units with cached
  material-specific `MARM-UMREZ/UMREN` factors and three-decimal rounding.
  Revalidation checks the canonical unit again, reservation items set
  `ENTRY_UOM`, and audit/export retain source and canonical quantities and units.
- All-or-nothing shortages consume no stock, so lower-priority requests can
  still use the balance. Partial requests consume only the available quantity.
- Added `zcl_stock_allocation_service`, `zif_stock_reader`, and
  `zif_allocation_writer`. Simulation uses the same calculation but skips the
  writer. Only positive allocations are sent to the writer.
- Added `zcl_stock_reader_sap`, which reads all requested stock keys in one
  `FOR ALL ENTRIES` query. Minimal `MARD` and `MARC` definitions live under
  `sap_stubs/` and are not deployable custom objects.
- Added `zcl_allocation_writer_sap` and `zcl_reservation_gateway_sap`.
  Successful allocations create individual material reservations, then commit
  once for the batch. Any BAPI create error, missing reservation number, or
  commit error rolls back the LUW and marks every allocation as failed.
- Allocation results now retain posting inputs and return posting status,
  reservation number, and error text. Simulation results are explicitly marked
  `SIMULATED`.
- Equal-priority requests are ordered by earliest requirement date before the
  request-ID tie-breaker.
- Added minimal standard stubs for `BAPI_RESERVATION_CREATE1`,
  `BAPI_TRANSACTION_COMMIT`, `BAPI_TRANSACTION_ROLLBACK`, and their reservation
  structures under `sap_stubs/`.
- Added `zif_idempotency_store`, `zcl_idempotency_store_sap`, and the owned
  `ZSTOCK_ALLOC` table. The unique request-ID key is claimed before a BAPI call;
  the reservation number is recorded before the same batch commit. A duplicate
  claim or failed update triggers BAPI rollback, which also rolls back the
  database changes in the shared SAP LUW.
- `ZSTOCK_ALLOC` now retains request identity, allocation policy, canonical
  quantities, and the committed outcome. Productive execution loads completed
  records before stock allocation: an identical retry reuses its reservation
  without consuming current stock, while changed input under the same ID is
  rejected. A claim collision arising after that pre-read remains fail-safe and
  rolls back, allowing a later retry to observe the completed record.
- Added standard consumption account assignments across request validation,
  allocation results, stock recheck, reservation headers, idempotency identity,
  audit storage, and CSV export. Movement 201 requires a cost center, 221 a WBS
  element, and 261 an order.
- Extended the same account-assignment contract to movement 231 (sales order
  and item), 241 (asset and subnumber), 251 (cost center), and 281 (network,
  with optional activity). The reservation gateway uses the corresponding
  `BAPI2093_RES_HEAD` fields. External WBS identifiers are mapped through
  `WBS_ELEMENT`, rather than the internal numeric `WBS_ELEM` representation.
- Added `PAYLOAD_VERSION` to `ZSTOCK_ALLOC`. New claims persist version `001`;
  completed rows are replayable only when their version is supported. Blank
  pre-upgrade rows and future unknown versions now produce a distinct invalid
  result before the stock read and writer, making the deployment boundary
  explicit without risking a duplicate reservation.
- Added a per-request minimum fulfillment percentage. A partial request below
  its threshold is rejected without consuming stock.
- Added three allocation ordering strategies: priority then requirement date,
  requirement date then priority, and priority then request ID. Unsupported
  strategy values return `CONFIG_ERROR` results without posting.
- Added `zcl_stock_rechecker_sap`. After all idempotency claims and before the
  first BAPI call, it rereads stock and compares the aggregate allocation for
  each material/plant/storage-location with its unrestricted stock and the
  material/plant total with one shared safety reserve. Missing or reduced stock
  rolls back the whole batch.
- Added the `EZSTOCK_POOL` enqueue object and `zcl_stock_lock_sap`. Unique stock
  safety domains are locked exclusively in sorted material/plant order before
  revalidation. `LGORT` remains generic so different storage locations sharing
  one plant reserve serialize. Locks use scope 3 and are explicitly released
  after commit or rollback. A collision fails before any reservation BAPI.
- Added `zcl_stock_allocation_app=>create_sap( )` as the production composition
  root. It wires the reader, rechecker, idempotency store, reservation gateway,
  writer, service, and operational logger.
- Added the owned `ZSTOCK_ALOG` table and `zcl_allocation_logger_sap`. It keeps
  the latest productive and simulation outcome per request and reports logging
  success separately from allocation/posting success.
- Added append-only `ZSTOCK_ALGH` audit history and
  `zif_allocation_log_store`. Each outcome receives a RAW16 UUID; the SAP store
  saves current-state and history rows atomically, rolling both back if either
  write fails. Its client/date/UUID primary-key order supports retention scans
  by cutoff date without a separate database index.
- Added `zcl_allocation_log_retention`,
  `zif_allocation_history_store`, and executable report
  `ZSTOCK_ALGH_RETENTION`. Cleanup defaults to a 365-day simulation, validates
  positive retention periods, checks table display/delete authorization, and
  reports affected rows before a separately requested productive deletion.
- Added `zif_allocation_history_reader`, `zcl_allocation_history_reader`,
  `zcl_allocation_log_export`, and report `ZSTOCK_ALGH_EXPORT`. Reads require
  table-display authorization and accept date, request-ID, and run-mode filters
  with a hard 10,000-row ceiling. The reader fetches one extra row and rejects a
  would-be truncated export instead of presenting it as complete. The report
  emits quote-escaped, semicolon-delimited CSV to a 1023-character SAP list or
  background spool.
- SAP reads now return all storage locations for requested material/plant pairs.
  Allocation and posting revalidation sum unrestricted stock by plant, take the
  maximum repeated `MARC-EISBE` value as one reserve, and still enforce each
  requested location's physical quantity.
- Added seventy-six transpiled ABAP Unit scenarios covering allocation policy,
  validation, orchestration, posting success, create failure, missing document
  IDs, commit failure, rollback, idempotency, persistence failure, and empty
  batches, stale-stock rechecks, strategy selection, application composition,
  and logging delegation.
- Added `zif_allocation_authority` and the SAP implementation
  `zcl_allocation_authority_sap`. The orchestration service deduplicates plants
  and checks `M_MATE_WRK` change activity before idempotency lookup or stock
  access. One denied plant invalidates the whole atomic batch, including a
  simulation, without calling the reader, converter, or writer.
- Closed the custom-movement gap with an explicit allowlist for movements 201,
  221, 231, 241, 251, 261, and 281. Any other movement is invalid before unit
  conversion or stock consumption. The suite now contains eighty transpiled
  ABAP Unit scenarios.
- Added an optional inclusive allocation horizon to the app, service, and pure
  allocator. New requests beyond the cutoff return `DEFERRED` and are removed
  from the stock-reader input; completed productive requests are resolved first
  and still replay. The horizon is run policy rather than idempotency payload,
  so deferred requests remain eligible as the cutoff advances. The suite now
  contains eighty-three transpiled ABAP Unit scenarios.
- Added `zif_reservation_status` and `zcl_reservation_status_sap` to distinguish
  explicitly cancelled reservations from replayable outcomes. When every
  existing `RESB` item is deletion-flagged, an exact request retry re-enters
  allocation and carries the prior reservation ID into posting. The writer
  conditionally replaces that exact old claim in the same LUW as the new BAPI
  reservation and document update. Missing rows and consumed but undeleted
  reservations remain replays. The suite now contains eighty-six transpiled
  ABAP Unit scenarios, including a concurrent replacement loser.
- Added `iv_require_full_batch` to the app and service as an opt-in run policy.
  After allocation, any incomplete new result changes every pending allocation
  to `ABORTED`, restores its full shortfall, and prevents the writer call.
  Rejected or invalid rows retain their root-cause result, and committed replay
  rows remain untouched. Productive, simulation, abort, and success paths bring
  the suite to eighty-nine transpiled ABAP Unit scenarios.
- Added a 32-character hexadecimal run ID to application results and both audit
  tables. One ID is generated before each app call, passed to the logger, shared
  by every current/history row from that call, and retained in the result even
  when logging fails. History reads, the export class, CSV output, and report
  parameter `P_RUN` support direct correlation filtering. Per-row `LOG_UUID`
  remains the append-only history key. Separate-call uniqueness coverage brings
  the suite to ninety transpiled ABAP Unit scenarios.
- Expanded both audit tables and CSV output with the complete allocation
  identity and policy: stock key, movement and requirement date, minimum fill,
  priority, partial flag, strategy, horizon, strict-batch flag, and prior
  reservation replaced after cancellation. The application passes run policy
  explicitly to the logger, so persisted outcomes can be reconstructed without
  the original in-memory request. The schema change is additive.
- Added a stable `DECISION_CODE` to allocation results, current audit, history,
  and CSV export. It classifies allocation-layer outcomes independently of
  mutable diagnostic text and posting/BAPI status, including distinct shortage,
  replay, horizon, authorization, validation, and strict-batch reasons. Four
  boundary scenarios for zero stock, missing stock, missing base-unit setup,
  and incomplete replay bring the suite to ninety-four transpiled ABAP Unit
  scenarios. The audit schema change is additive.
- Added optional exact decision-code filtering to the history-reader port, SAP
  SQL reader, export service, and `ZSTOCK_ALGH_EXPORT` report parameter
  `P_DECIDE`. The existing bounded-read and table-display authorization rules
  continue to apply after the additional predicate.
- Added `AVAILABILITY_CHECKED` and `AVAILABLE_QTY` to allocation results,
  current audit, history, and CSV export. The allocator records the usable
  canonical balance immediately before each numeric decision, so sequential
  requests expose their actual declining balance. Missing stock/configuration,
  replay, deferral, validation, and authorization paths remain explicitly
  unchecked. Existing allocator, logger, and export scenarios cover the new
  evidence without changing the ninety-four-scenario suite size.
- Added independent exact material, plant, and storage-location predicates to
  the history-reader interface and SQL, carried through the export service to
  report parameters `P_MAT`, `P_PLANT`, and `P_SLOC`. Existing authorization,
  date-window, deterministic ordering, and row-limit behavior is unchanged.
- Added exact movement-type, allocation-status, and posting-status predicates
  through the same path, exposed by `P_MOVE`, `P_ASTAT`, and `P_PSTAT`. The
  export test double verifies all filters compose in one bounded reader call.
- Added `CANONICAL_QUANTITY_INVALID` as a defensive allocator outcome for any
  converter that reports success with a zero or negative base quantity. The SAP
  converter also rejects source quantities that round to zero at three-decimal
  stock precision. Two focused scenarios bring the suite to ninety-six
  transpiled ABAP Unit scenarios.
- Added exact reservation lineage predicates to the history-reader interface
  and SQL, the export service, and `ZSTOCK_ALGH_EXPORT`. `P_RES` selects the
  produced reservation and `P_PRIOR` selects a cancelled reservation referenced
  by its replacement. Existing filter-composition coverage now asserts both.
- Added an optional requirement-date interval through the history reader,
  export service, and report parameters `P_RFROM` and `P_RTO`. Each endpoint is
  inclusive and independently optional. An inverted closed interval is rejected
  before the reader call, bringing the suite to ninety-seven transpiled ABAP
  Unit scenarios.
- Added strict canonical validation for `allow_partial`, `iv_simulation`, and
  `iv_require_full_batch`. Invalid request flags return `REQUEST_FLAG_INVALID`;
  invalid run flags return batch-level `RUN_POLICY_INVALID` before authority,
  replay, stock, conversion, or writer calls. Audit logging records malformed
  simulation input as run mode `I`, which export filtering accepts. Four focused
  scenarios bring the suite to one hundred one transpiled ABAP Unit scenarios.
- Enforced account-assignment exclusivity for all seven supported consumption
  movements. After required fields are present, any field from another modeled
  assignment family returns `REQUEST_RULE_INVALID` before conversion or stock
  evaluation. One matrix scenario covers every family and brings the suite to
  one hundred two transpiled ABAP Unit scenarios.
- Moved allocation-strategy validation to the orchestration boundary while
  retaining the allocator's direct-call safeguard. Unsupported values now
  return `STRATEGY_UNSUPPORTED` before authority, replay, reservation-status,
  stock, conversion, or writer calls. Focused dependency-counter coverage
  brings the suite to one hundred three transpiled ABAP Unit scenarios.
- Extracted structural request rules into `validate_request`, a public pure
  allocator method reused by orchestration preflight. Invalid rows no longer
  reach authorization, idempotency, reservation-status, or stock dependencies,
  but the allocator still returns their established per-row outcomes. Replay
  lookup is deduplicated by request ID while all valid duplicate stock keys are
  preserved for allocator ordering. Invalid-only, mixed-validity, and duplicate
  scenarios bring the suite to one hundred six transpiled ABAP Unit scenarios.
- Idempotency claims are now acquired from a request-ID-sorted copy of pending
  allocations before stock locking. Recheck and BAPI processing retain the
  allocator's business order. A focused two-order scenario brings the suite to
  one hundred seven transpiled ABAP Unit scenarios.
- Successful reservation posting now retains the first warning from each item
  create call and the first warning from the shared commit. Replacement
  lineage, create warning, and commit warning are composed in that order and
  flow through the existing audit and CSV message fields. Warning-only success
  coverage brings the suite to one hundred eight transpiled ABAP Unit
  scenarios.
- Added a bulk idempotency lookup contract and a guarded `FOR ALL ENTRIES`
  implementation for `ZSTOCK_ALLOC`. Productive replay preflight now loads all
  unique structurally valid request IDs in one store call after authorization;
  simulations and empty valid sets still skip the store. Multi-ID and duplicate
  coverage brings the suite to one hundred nine transpiled ABAP Unit scenarios.
- Added bulk reservation cancellation classification. Productive preflight now
  deduplicates persisted reservation IDs, loads their `RESB` deletion flags in
  one guarded query, and returns only IDs having at least one item with every
  item deleted. Multi-reservation coverage brings the suite to one hundred ten
  transpiled ABAP Unit scenarios.
- Added `zif_stock_lock_gateway` and moved generated enqueue calls behind its
  SAP adapter. The lock coordinator now deduplicates allocations by
  material/plant and requests a generic storage-location lock for each key,
  matching the scope of shared `MARC-EISBE`. Ordering, deduplication, complete
  release, and partial-failure cleanup coverage bring the suite to one hundred
  thirteen transpiled ABAP Unit scenarios.
- Hardened audit CSV cells against spreadsheet formula execution. The shared
  field encoder prefixes values beginning with formula operators or control
  characters with an apostrophe before applying existing quote escaping. One
  end-to-end scenario covers all seven prefixes and brings the suite to one
  hundred fourteen transpiled ABAP Unit scenarios.
- Hardened `zcl_allocation_history_reader` as an independent public boundary.
  It now rejects initial or inverted log dates, inverted closed requirement
  dates, and row limits outside 1 through 10,001 before authorization or SQL.
  Four direct scenarios bring the suite to one hundred eighteen transpiled
  ABAP Unit scenarios.
- Made audit retention fail closed at both public layers. A simulation value
  other than `X` or blank is rejected before cutoff calculation in the facade
  and before authorization in the SAP store; the store also rejects an initial
  cutoff. Three scenarios bring the suite to one hundred twenty-one transpiled
  ABAP Unit scenarios.
- Bounded retention to 1 through 36,500 days, rejected caller-supplied effective
  dates later than `sy-datum`, and required every store cutoff to be strictly in
  the past. These guards precede date arithmetic, authorization, and SQL as
  applicable. Three scenarios bring the suite to one hundred twenty-four
  transpiled ABAP Unit scenarios.
- Added an optional exact `LOGGED_BY` predicate to the history-reader port, SAP
  SQL reader, export service, and report parameter `P_USER`. The default export
  start now subtracts 29 days from its inclusive end date, so the documented
  window contains exactly 30 calendar dates. Existing filter-composition and
  default-date scenarios cover both behaviors; the suite remains at one hundred
  twenty-four transpiled ABAP Unit scenarios.
- Added optional log-time endpoints to the public history reader, export facade,
  and report parameters `P_FTIME` and `P_TTIME`. The SQL combines them with the
  first and last log dates as one inclusive timestamp interval; blank endpoints
  mean midnight and 23:59:59. Both public layers reject an inverted same-day
  interval before dependencies, authorization, or SQL. Two focused scenarios
  bring the suite to one hundred twenty-six transpiled ABAP Unit scenarios.
- Added independent exact audit predicates for cost center, order, WBS element,
  sales order/item, asset/subnumber, and network/activity. They flow through the
  history-reader port, one bounded SQL query, the export facade, and report
  parameters `P_COST`, `P_ORD`, `P_WBS`, `P_SALES`, `P_SITEM`, `P_ASSET`,
  `P_ASUB`, `P_NET`, and `P_NACT`. Existing composition coverage asserts every
  field together; the suite remains at one hundred twenty-six scenarios.
- Added exact source-unit, canonical-unit, and allocation-strategy predicates,
  plus an independently optional inclusive horizon-date interval. The reader,
  export facade, and report expose these as `P_SUNIT`, `P_UNIT`, `P_STRAT`,
  `P_HFROM`, and `P_HTO`. Both public layers reject an inverted closed horizon
  interval before dependencies, authorization, or SQL. Two focused scenarios
  bring the suite to one hundred twenty-eight transpiled ABAP Unit scenarios.
- Added a shared tri-state selector for `ALLOW_PARTIAL`, `REQUIRE_FULL_BATCH`,
  and `AVAILABILITY_CHECKED`. Blank means unrestricted, `X` means true, and `-`
  maps to the exact stored blank false value. The reader, facade, and report
  expose `P_PART`, `P_FULL`, and `P_AVAIL`; malformed selectors fail before
  dependencies, authorization, or SQL. Two focused scenarios bring the suite
  to one hundred thirty transpiled ABAP Unit scenarios.
- Hardened the stock-lock coordinator and SAP gateway around canonical boolean
  values. A wait flag outside `X` or blank fails before enqueue access, and only
  an exact `X` gateway result counts as acquired. A malformed result releases
  earlier locks and returns a deterministic failure. Three focused scenarios
  bring the suite to one hundred thirty-three transpiled ABAP Unit scenarios.
- Hardened all boolean acknowledgements consumed by the transactional writer.
  Idempotency claim, stock-lock acquisition, fresh-stock recheck, and document
  update now require exact `X`; any other nonblank value follows rollback,
  release, and batch failure with a phase-specific diagnostic. Four scenarios
  bring the suite to one hundred thirty-seven transpiled ABAP Unit scenarios.

## Policy decisions

- Allocation results are returned in processing order, not input order.
- A missing stock row is treated as zero available stock.
- Request IDs are unique within one execution and persist across productive
  executions. Exact completed retries are replayed; payload conflicts are
  invalid, and simulations deliberately ignore replay state.
- Persisted replay compatibility is opt-in by payload version. Missing or
  unsupported versions are never inferred from partially populated fields.
- The allocation writer is a required dependency even for a service commonly
  used in simulation; this keeps productive construction explicit.
- Reservation posting is atomic at the allocation batch level: one failed item
  rolls back all reservation creations in that call.
- Idempotency claims deliberately use the same SAP LUW as reservation creation;
  no independent commit is issued by the store.
- Cost center, order, and WBS element are identity-bearing request fields.
  Productive retries must match the original account assignment exactly.
- Operational audit persistence occurs after posting and has its own commit.
  An audit failure is surfaced through `log_saved` but cannot undo an already
  committed reservation batch. Within that audit LUW, current-state and
  append-only history records succeed or roll back together.
- Audit-history cleanup is a separate administrative LUW. The executable report
  defaults to simulation; productive deletion must be explicitly selected and
  authorized through `S_TABU_NAM` for `ZSTOCK_ALGH`.
- Audit export is read-only and destination-neutral: the report produces an SAP
  list/spool so each landscape can apply its own approved transfer and archive
  controls without granting the allocation application filesystem access.
- Audit CSV safety takes precedence over byte-for-byte reproduction for values
  beginning with `=`, `+`, `-`, `@`, tab, carriage return, or line feed. A
  leading apostrophe is part of the exported representation and prevents common
  spreadsheet clients from evaluating the cell as a formula.
- The history-reader ceiling is one row above the public export ceiling. This
  allows the export service to detect a would-be 10,001st row without granting
  direct callers an unbounded `UP TO` value. Reader validation is repeated even
  though the export facade validates its own parameters.
- Retention simulation is a destructive-control flag and accepts only canonical
  ABAP boolean values. The concrete store repeats facade validation so a direct
  caller cannot turn an intended dry run into deletion by supplying an arbitrary
  nonblank character; initial cutoffs are invalid at that boundary as well.
- Retention date arithmetic is capped at 100 years. A supplied effective date
  may be current or historical but never future, while the store accepts only a
  cutoff earlier than its own application-server date. This protects direct
  callers and prevents future-dated test seams from widening deletion scope.
- Canonical allocation arithmetic always uses `MARA-MEINS`. Base-unit requests
  bypass factor lookup; alternative requests use the material's `MARM` factor.
  Missing, zero, or invalid factors and nonpositive rounded results reject the
  request without consuming stock. The allocator independently enforces a
  positive canonical quantity before calculating fill percentages.
  The caller's original request quantity/unit remains on the result and audit
  row alongside the converted request and allocation.
- The transpiler configuration explicitly renames the JavaScript keyword
  `return`; this preserves the standard BAPI `RETURN` parameter during local
  transpilation.
- Authorization is fail-closed at the service call boundary. A mixed-plant
  batch is not split into separately authorized writes because reservation
  posting is atomic for the batch and partial authorization would make that
  contract ambiguous.
- Movement-type support is opt-in. Unknown and customized types are rejected
  even when they happen not to require an account assignment in the standard
  system; admitting one requires an explicit validation and gateway mapping.
- The allocation horizon is inclusive and optional. It affects only new work:
  exact completed retries retain their committed result, while deferred
  requests create no persistent claim and may be reconsidered later.
- Reservation cancellation is recognized only from explicit deletion flags on
  an existing `RESB` document. Absence is not proof of cancellation because
  the document may have been archived; consumption is fulfillment, not a reason
  to create the demand again.
- A cancelled claim is replaced with a conditional delete followed by an insert
  in the reservation LUW. The database row lock arbitrates concurrent retries,
  and rollback restores the old claim if locking, stock recheck, BAPI creation,
  document persistence, or commit fails.
- Full-batch enforcement applies to new work only. It cannot and does not roll
  back an earlier committed replay; those rows are excluded when deciding
  whether the current run's pending allocations may be posted.
- Run IDs identify one application invocation, not one request or reservation.
  They are correlation metadata and never participate in allocation ordering,
  request idempotency, reservation posting, or table keys.
- Audit policy fields describe the call that produced the outcome. They are
  evidence for diagnosis and export, not inputs read back into allocation or
  replay decisions.
- Decision codes are a stable integration contract for allocation-layer
  outcomes. Posting status and message remain separate because a successfully
  calculated allocation can still fail during locking, recheck, BAPI creation,
  or commit.
- Decision-code export filtering accepts any noninitial exact value instead of
  validating against the current catalog. This permits diagnosis of rows from
  newer producers during staggered deployments; a blank parameter deliberately
  means no predicate and includes legacy rows whose code is blank.
- Availability quantity is meaningful only when its companion checked flag is
  set. This distinguishes a measured zero usable balance from paths that never
  established a canonical stock quantity and from pre-upgrade audit rows.
- Stock-key export filters are independent and exact. Blank means no predicate
  for that dimension; supplied values compare with the internal values stored
  in the audit row and can be combined with every existing filter.
- Movement and outcome filters accept any noninitial exact value instead of
  rejecting values outside the current producer catalog. This preserves access
  to history from newer producers during staggered deployments; blank means no
  predicate.
- Produced- and prior-reservation filters are independent exact predicates.
  This supports both forward tracing from a new reservation and reverse tracing
  from a cancelled claim without conflating the two roles; blank means no
  predicate.
- Audit log dates and requirement dates are separate filter dimensions. Log
  dates bound when the decision was recorded and retain the default 30-day
  window; requirement dates bound when demand was due and have no implicit
  default. One blank requirement endpoint creates an open interval.
- Logging-user filtering is an optional exact predicate over the stored SAP
  user. A blank value deliberately keeps both legacy blank rows and all named
  users in scope.
- Log-time filters qualify only the first and last dates of the log-date window.
  Intermediate dates remain complete even when the start time is later than the
  end time, because the combined timestamp interval is still ordered.
- Account-assignment filters are independent. A parent value without its
  subordinate component intentionally selects all matching sales-order items,
  asset subnumbers, or network activities; blank dimensions remain
  unrestricted and include legacy audit rows.
- Unit predicates distinguish the original request unit from the canonical base
  unit used for allocation and posting. Strategy filtering accepts any exact
  noninitial value so newer producers remain diagnosable during staggered
  deployments. A one-sided horizon endpoint creates an open interval.
- Boolean audit filters cannot use ordinary optional `abap_bool` parameters
  because blank must represent both false and omission. The explicit `-`
  selector makes false queryable; it also includes pre-upgrade blank rows, which
  share the persisted representation.
- Public boolean inputs accept only `abap_true` and `abap_false`. Treating an
  arbitrary nonblank character as false is unsafe for simulation because it can
  turn intended dry runs into productive calls; run-policy validation therefore
  precedes authorization and every persistence or stock dependency.
- Audit run mode `I` denotes a call rejected for a malformed simulation flag.
  It is distinct from `P` and `S`, remains filterable, and prevents invalid input
  from being recorded as a productive execution.
- Reservation account assignment is exclusive by movement type. The gateway
  maps every populated header field, so accepting a required assignment plus
  foreign fields would delegate an ambiguous request to the BAPI. Validation
  rejects the ambiguity in the pure allocator instead.
- Run-level configuration is validated before request-dependent infrastructure.
  The service owns the early strategy check because otherwise an invalid value
  would still trigger authorization, replay, and stock reads; the allocator
  repeats the check because it remains independently callable.
- Structural validation has one implementation in the allocator and two uses:
  result construction and service dependency preflight. Preflight does not
  remove invalid rows from the call result or make valid rows atomic with them;
  `iv_require_full_batch` remains the explicit atomic-completeness policy.
- Duplicate request IDs are deduplicated only for request-ID keyed replay
  lookup. Their stock keys are deliberately retained because rows sharing an ID
  may differ in material, plant, location, priority, or requirement date, and
  allocator ordering decides which row receives the duplicate outcome.
- Transactional lock acquisition has two independent deterministic orders:
  request IDs for `ZSTOCK_ALLOC` row claims, then material/plant for enqueue
  locks. The location component is deliberately generic because safety stock is
  shared by every location in that material/plant. Reservation creation still
  follows allocation order because lock ordering is concurrency control, not
  business priority.
- Lock configuration and acquisition state are fail-closed at both replaceable
  boundaries. This prevents a noncanonical character from changing enqueue wait
  behavior or being interpreted as successful lock ownership.
- Transactional adapter success is affirmative, not inferred from non-false.
  This keeps a malformed test double, custom implementation, or staggered
  deployment from advancing the reservation LUW without proven ownership,
  revalidation, or persistence.
- Decision-path adapter booleans are also affirmative. Plant authorization,
  factor lookup, and unit conversion accept only canonical results. Malformed
  authorization returns `CONFIG_ERROR` / `AUTHORIZATION_RESULT_INVALID` before
  replay or stock access; malformed factor and converter flags fail conversion
  before arithmetic or availability evaluation. Three focused scenarios bring
  the transpiled suite to one hundred forty.
- Reservation messages of type `E`, `A`, or `X` roll back the batch. Type `W`
  does not change a successful posting status; only the first create warning
  per row and first batch commit warning are retained to keep the operational
  message deterministic and bounded.
- Idempotency replay lookup is set-oriented by unique request ID, but replay
  application still follows first request appearance. The SAP store guards an
  empty input before `FOR ALL ENTRIES` so an empty batch can never broaden into
  a full-table read.
- Replay lookup results are an exact response envelope. Every returned row must
  use a canonical found flag and belong to the requested ID set; otherwise the
  whole batch returns `CONFIG_ERROR` / `REPLAY_LOOKUP_INVALID` before
  cancellation classification or stock access. Canonical not-found rows never
  contribute document IDs to cancellation reads.
- Audit reader and retention-store results require canonical success states.
  Logger-store and application-logger acknowledgements are normalized to exact
  true or false so malformed custom adapters cannot report persisted audit data.
  Seven focused scenarios bring the transpiled suite to one hundred forty-seven.
- Fulfillment evidence now includes `shortfall_qty` and `fill_pct` in allocation
  results, current audit, append-only history, and CSV. Fill is allocated divided
  by requested on the result's quantity basis: 100 for full, proportional for
  partial, and zero for rejected or strict-batch-aborted work. Replays derive
  both values from persisted canonical quantities only after validating a
  positive request, a positive allocation no greater than the request, and a
  noninitial canonical unit. Two scenarios bring the suite to one hundred
  forty-nine.
- Shortage filtering reuses the audit tri-state convention across the public SQL
  reader, export facade, and report: blank is unrestricted, `X` selects positive
  `SHORTFALL_QTY`, and `-` selects zero. Both public layers reject other values
  before authorization or data access. Pre-upgrade rows have an initial
  shortfall and therefore belong to the zero selection. Two scenarios bring the
  suite to one hundred fifty-one.
- Fulfillment-band filtering is separate from shortage presence. `F` selects an
  exact 100 percent fill, `P` selects the stored three-decimal interval from
  0.001 through 99.999 percent, `N` selects zero, and blank is unrestricted.
  Reader and export validation are independent; pre-upgrade rows have an initial
  fill percentage and therefore appear in the `N` band. Two scenarios bring the
  suite to one hundred fifty-three.
- Reservation cancellation status is set-oriented by unique document ID. A
  document is returned as cancelled only when its `RESB` result has at least one
  row and no row with an initial deletion flag; missing rows and any active item
  remain conservative replays. Empty input bypasses Open SQL.
- Request quantities now fit the persisted `DEC(13,3)` domain exactly: they must
  be positive, no greater than 9,999,999,999.999, and have at most three decimal
  places. Minimum-fill percentages must be from 0 through 100 with the same
  precision, and priorities must be positive. Shared service preflight rejects
  invalid input before authorization, replay, stock, conversion, or posting.
  Successful converter output is independently capped at the same maximum.
  Six allocator boundaries and one orchestration scenario bring the suite to
  one hundred sixty.
- Usable-stock filtering now complements the availability-evidence selector.
  Blank leaves observed stock unrestricted, `X` selects positive
  `AVAILABLE_QTY`, and `-` selects an observed zero. Both nonblank choices also
  require `AVAILABILITY_CHECKED = X`, so pre-upgrade rows with an initial value
  but no evidence are excluded. Combining a stock band with an explicit
  unchecked-availability filter fails before authorization or reader access.
  Four focused scenarios bring the suite to one hundred sixty-four.
