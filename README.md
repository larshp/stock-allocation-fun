# Stock Allocation for SAP ABAP

An incremental, test-driven stock allocation service for existing SAP systems.
The current implementation ranks demand, protects safety stock, supports partial
fulfillment, and separates pure allocation logic from SAP reads and reservation
writes.

## Implemented features

- Deterministic allocation by ascending priority and request ID.
- Earliest-requirement-date ordering within the same priority.
- Selectable priority/date, date/priority, and priority/request-ID strategies.
- Optional inclusive allocation horizon with an explicit `DEFERRED` outcome for
  later demand.
- All-or-nothing and partial-fulfillment requests.
- Optional full-batch enforcement that prevents every new posting when any new
  request is partial, rejected, invalid, deferred, or otherwise incomplete.
- Per-request minimum fulfillment percentages for partial allocations.
- Plant and storage-location-specific stock pools.
- Explicit quantity units with `MARA-MEINS` as the canonical base unit and
  material-specific alternative-unit conversion through `MARM-UMREZ/UMREN`.
  Factor lookup and conversion success require exact affirmative results.
- Shared plant-level safety-stock protection using `MARC-EISBE`, without
  repeated deductions for multiple storage locations.
- Rejection of invalid quantities, missing request IDs, duplicate request IDs,
  missing stock, and insufficient all-or-nothing stock.
- Fail-closed validation of every public ABAP boolean: only `X` and blank are
  accepted for simulation, full-batch, and per-request partial-allocation flags.
- Fail-closed plant authorization through `M_MATE_WRK` activity `02`, checked
  once per plant before idempotency replay or stock access for productive and
  simulation runs. A replaceable authority must return a canonical boolean;
  malformed results stop the batch before protected reads.
- Simulation mode that calculates allocations without writing them.
- An orchestration service with injectable stock-reader and allocation-writer
  ports.
- Shared pure request preflight that excludes malformed rows from authorization,
  replay, reservation-status, and stock dependencies while preserving their
  final allocator outcomes.
- An SAP stock reader using `MARD-LABST` and `MARC-EISBE` with one set-oriented
  query, joined to `MARA-MEINS` for the material base unit.
- Transactional reservation posting through `BAPI_RESERVATION_CREATE1`, with
  batch commit, rollback on any create/commit error, and returned document IDs
  and retained warning diagnostics. Allocated quantities are posted with
  `ENTRY_UOM`; standard
  consumption reservations carry cost center (201/251), WBS element (221),
  sales order and item (231), asset and subnumber (241), order (261), or network
  and optional activity (281) account assignments in the reservation header.
  Each movement accepts only its modeled assignment family.
- Persistent request-ID claims in the owned `ZSTOCK_ALLOC` table, committed in
  the same LUW as reservation creation and acquired in deterministic request-ID
  order across each batch.
- Payload-aware idempotent replay: identical productive retries return the
  original allocation and reservation without consuming current stock, while
  changed input under an existing request ID is rejected.
- Set-oriented replay preflight that loads all unique, valid request IDs from
  `ZSTOCK_ALLOC` in one guarded database query per productive run.
- Cancellation-aware replay: a persisted reservation whose existing `RESB`
  items are all deletion-flagged is allocated again, with its old idempotency
  claim conditionally replaced in the same LUW as the new reservation. Status
  for all unique persisted reservation IDs is read in one guarded query.
- Versioned idempotency payloads: current claims store payload version `001`;
  legacy or unsupported rows are rejected explicitly before stock is read or a
  reservation can be posted.
- Aggregate availability revalidation after claims and before any BAPI call.
- Exclusive generic-location `MARD` locks acquired once per material/plant in
  deterministic key order and held through BAPI commit or rollback.
- A production composition entry point with current-state operational audit in
  `ZSTOCK_ALOG` and append-only UUID-keyed history in `ZSTOCK_ALGH`, covering
  both productive and simulation runs.
- One generated run ID per application call, returned to the caller and stored
  on every current-state and history row produced by that call.
- Reconstructable audit context covering material, plant, storage location,
  movement, requirement date, request controls, run controls, account
  assignment, quantities, outcomes, and reservation replacement lineage.
- Stable machine-readable decision codes on allocation results and audit rows,
  so integrations do not need to parse diagnostic message text.
- Per-result usable-stock evidence showing whether availability was evaluated
  and the canonical quantity visible immediately before the decision.
- Configurable audit-history retention through report
  `ZSTOCK_ALGH_RETENTION`, defaulting to a 365-day dry run and checking
  `S_TABU_NAM` before reading or deleting history. Both the facade and store
  reject noncanonical simulation flags and unsafe dates before any destructive
  path.
- Read-only audit-history export through `ZSTOCK_ALGH_EXPORT`, with timestamp,
  requirement-date window, request, reservation lineage, stock-key, movement,
  unit conversion, allocation policy, account assignment, allocation/posting
  outcome, shortage evidence, run-mode, run-ID, decision-code, logging-user,
  fulfillment band, and row-limit filters plus CSV-safe quoting and spreadsheet-formula
  neutralization. The SQL reader
  independently enforces valid ranges and a hard fetch ceiling.

## Repository layout

- `src/`: deployable custom `Z*` ABAP code and ABAP Unit tests.
- `sap_stubs/`: minimal SAP standard DDIC definitions used only by local checks.
- `abaplint.json`: syntax, style, dependency, and ownership rules.
- `abap_transpile.json`: transpiler inputs and the `open-abap-core` dependency.
- `NOTES.md`: implementation decisions and progress.
- `ANOMALIES.md`: known defects, risks, and missing integration behavior.

## Local verification

Node.js 18 or newer is required.

```text
npm install
npm test
```

`npm test` runs abaplint, transpiles the ABAP with open-abap-core, and executes
the transpiled ABAP Unit suite.

## SAP integration

Import `src/` with abapGit into a customer package. Do not import `sap_stubs/`:
those objects model standard SAP definitions that already exist in the target
system. `zcl_reservation_gateway_sap` uses `BAPI_RESERVATION_CREATE1` and the
standard BAPI transaction functions. Validate the included minimal signatures
against the target release and verify the generated lock function parameters
before productive use. The supplied `EZSTOCK_POOL` enqueue object is rooted on
`MARD`. Allocation uses exact material and plant values with generic `LGORT`,
so compatible exact-location or plant-prefix locks from external processes
collide through SAP's central enqueue service.

Create the fully wired application with
`zcl_stock_allocation_app=>create_sap( )`, then call `run` with the requests,
simulation flag, and one of the strategy constants on `zcl_stock_allocator`.
Boolean controls must use canonical ABAP values: `abap_true` (`X`) or
`abap_false` (blank). An invalid simulation or full-batch value returns every
request as `CONFIG_ERROR` before authorization, replay, stock access,
conversion, or posting. An invalid per-request `allow_partial` value returns
that request as `INVALID` before availability is evaluated.
Authorization adapters must likewise return exact `abap_true` or `abap_false`.
A malformed response returns `AUTHORIZATION_RESULT_INVALID` as a
`CONFIG_ERROR`, distinct from a genuine `PLANT_UNAUTHORIZED` denial, before
replay or stock access.
Ordering strategy is validated at the same service boundary. Values other than
`PRIORITY_DUE`, `DUE_PRIORITY`, and `PRIORITY_ID` return
`STRATEGY_UNSUPPORTED` before authorization or any persistence, stock, or
conversion dependency is called. The pure allocator retains the same check for
direct use.
Structurally invalid requests are also preflighted through the allocator's
public pure validator. They remain in the final result with the same decision
code and message, but are excluded from plant authorization, idempotency,
reservation-status, and stock reads. Valid rows in a mixed batch continue
normally unless full-batch policy later aborts them. Duplicate request IDs use
one keyed replay lookup but retain every valid stock key until the allocator's
configured ordering determines which row is first.
Pass `iv_horizon_date` to limit a run to demand required on or before that
date; leave it initial for no cutoff. New requests after the cutoff are returned
as `DEFERRED` without stock reads, conversion, or posting. A completed matching
productive request still replays its committed reservation even when its date
is beyond the current horizon, because the cutoff does not invalidate prior
work. Deferred requests are not claimed and can be allocated by a later run
when the horizon advances.
Set `iv_require_full_batch` when every new request must be fully allocated
before any new reservation is posted. If one new result is not `ALLOCATED`, all
otherwise pending allocations become `ABORTED`, their allocated quantity is
cleared, and the writer is not called. The original incomplete rows retain
their statuses and messages so the cause remains visible. Simulation applies
the same policy. Previously committed replay rows are reported unchanged and
do not participate in the new-work completeness decision.
Each request must provide `unit_of_measure` equal to the material base unit
returned by `MARA-MEINS` or an internal SAP alternative unit maintained for the
material in `MARM`. Alternative quantities are converted and rounded to the
three-decimal stock precision before allocation. Results expose canonical
`requested_qty`, `allocated_qty`, `shortfall_qty`, `fill_pct`, and
`unit_of_measure`, while `source_requested_qty` and `source_unit_of_measure`
retain the caller's input. Fill percentage is actual allocated quantity divided
by requested quantity: 100 for full allocation, proportional for partial
allocation, and zero for rejected or strict-batch-aborted work.
Source quantities must be positive, no greater than 9,999,999,999.999, and
exactly representable with at most three decimal places. Minimum-fill
percentages must be between 0 and 100 with the same precision, and priorities
must be positive. These checks run before authorization, replay, stock,
conversion, or posting. Successful conversion output is independently capped
at the same `DEC(13,3)` maximum before allocation.
Movement types 201 and 251 require `cost_center`; 221 requires `wbs_element`;
231 requires `sales_order` and `sales_order_item`; 241 requires `asset_number`
and `asset_subnumber`; 261 requires `order_id`; and 281 requires `network_id`
with optional `network_activity`. Fields belonging to every other assignment
family must remain blank; mixed assignments return `REQUEST_RULE_INVALID`
before conversion or availability evaluation. These fields are part of the
idempotency payload and are retained in operational audit records and CSV
exports.
Only movement types 201, 221, 231, 241, 251, 261, and 281 are admitted. Other
standard or customized movement types are rejected until their field-selection
and account-assignment rules are implemented explicitly. The executing user
needs `M_MATE_WRK` activity `02` for every requested plant. If any plant check
fails, the complete call is returned as invalid before replay records or stock
are read, preserving the service's atomic batch boundary.
The returned result contains all allocation/posting results, a 32-character
hexadecimal `run_id`, and `log_saved` so callers can detect an operational-audit
failure independently of posting. The run ID is generated before allocation
and remains available even if audit saving fails. Every audit row from that
call carries the same run ID, while each history row retains its separate
`LOG_UUID`. Only an exact affirmative logger acknowledgement sets `log_saved`;
malformed custom logger or store results are normalized to false. Current-state
and history records are saved atomically in one audit
LUW. Existing audit rows from before this additive schema change have a blank
run ID.
Each allocation also carries `decision_code`, a stable allocation-layer reason
that is independent of `posting_status` and the human-readable
`posting_message`. Full and partial success use `FULLY_ALLOCATED` and
`PARTIALLY_ALLOCATED`. Stock policy uses `NO_AVAILABLE_STOCK`,
`PARTIAL_NOT_ALLOWED`, and `BELOW_MINIMUM_FILL`. Validation and configuration
use `INVALID_REQUEST`, `REQUEST_FLAG_INVALID`, `REQUEST_RULE_INVALID`,
`DUPLICATE_REQUEST_ID`, `RUN_POLICY_INVALID`, and `STRATEGY_UNSUPPORTED`.
Replay outcomes use `REPLAY_VERSION_UNSUPPORTED`,
`REPLAY_PAYLOAD_CONFLICT`, `REPLAY_RESERVATION_MISSING`,
`REPLAY_LOOKUP_INVALID`, `CANCELLATION_LOOKUP_INVALID`,
`REPLAY_OUTCOME_INVALID`, and
`RESERVATION_REPLAYED`. A replay lookup row must have a canonical found flag and
a request ID from the queried set; violations stop the batch before cancellation
or stock reads. The batch lookup itself must also affirm canonical success;
backend failure or a malformed success state produces `REPLAY_LOOKUP_INVALID`
rather than being interpreted as no prior claim. Completed replay quantities
must be positive, allocated quantity must not exceed requested quantity, and the
canonical unit must be present. The stored reservation number must contain ten
numeric characters and cannot be shared by distinct replay records in one
batch. Violations return `REPLAY_OUTCOME_INVALID`. Boundary outcomes use
`OUTSIDE_HORIZON`,
`STOCK_READ_INVALID`, `STOCK_SNAPSHOT_INVALID`, `STOCK_NOT_FOUND`,
`BASE_UNIT_MISSING`,
`UNIT_CONVERSION_FAILED`,
`CANONICAL_QUANTITY_INVALID`, `PLANT_UNAUTHORIZED`,
`AUTHORIZATION_RESULT_INVALID`, and `FULL_BATCH_ABORTED`.
`UNIT_CONVERSION_FAILED` reports a rejected conversion, including a
noncanonical factor-reader or converter result;
`CANONICAL_QUANTITY_INVALID` protects allocation when a converter claims
success but supplies a zero, negative, or oversized base quantity.
Results that reach a numeric usable-stock comparison set
`availability_checked` and expose `available_qty` in the canonical base unit.
The quantity is the balance visible immediately before that request is
evaluated, after safety-stock protection and any earlier allocations in the
same ordered run. A present stock row with no usable balance therefore records
checked plus zero. Replays, deferred demand, authorization or validation
failures, missing stock rows, and unit-configuration failures leave the flag
blank because no comparable availability was established. Consumers must not
interpret an initial quantity as observed stock unless the flag is set.
The replaceable stock-reader boundary must explicitly affirm success. A failed
or malformed initial read returns `STOCK_READ_INVALID` before conversion or
posting, while the same condition during the locked recheck fails the writer
gate. A canonical successful read with no matching rows remains the ordinary
`STOCK_NOT_FOUND` business outcome.
Every affirmed snapshot is then checked for requested material/plant scope,
complete material/plant/location identity, persistable three-decimal stock
quantities, one base unit per material, and one repeated safety-stock value per
material/plant. `STOCK_SNAPSHOT_INVALID` identifies an initial contract
violation; the same validation is repeated under the posting lock and stops the
writer if fresh data is inconsistent.
Audit rows also retain `material`, `plant`, `storage_location`, `movement_type`,
`requirement_date`, `minimum_fill_pct`, `priority`, `allow_partial`, allocation
strategy, horizon date, full-batch policy, and any prior reservation replaced
after cancellation. They also persist canonical shortfall quantity and fill
percentage, and CSV exports both metrics beside requested and allocated
quantity. These additive columns are initial on pre-upgrade rows; their original
requested and allocated quantities remain available for migration or analysis.
CSV export emits the same decision context and decision code, so an archived
row can be interpreted without retrieving the original request payload. Audit
rows written before the decision-code column was deployed have a blank code.
Current and historical audit rows plus CSV output retain the availability flag
and quantity. Pre-upgrade rows have a blank flag and an initial quantity, which
unambiguously means that availability evidence was not recorded.
Productive runs consult `ZSTOCK_ALLOC` before reading stock. Completed matching
requests are returned with `Existing reservation reused`; simulations always
recalculate and ignore productive replay state. Existing rows with a blank or
unsupported `PAYLOAD_VERSION` remain fail-safe: productive execution returns
`Stored request payload version is unsupported` and requires the row to be
reconciled during deployment rather than guessing whether its payload matches.
The replay lookup deduplicates structurally valid request IDs and reads their
persisted payloads with one `FOR ALL ENTRIES` query after plant authorization.
An empty ID set bypasses Open SQL, while duplicate request rows remain in the
allocator input so their established duplicate outcome and stock-key ordering
are unchanged.
Before replaying a completed row, the SAP composition reads its reservation
items from `RESB`. Persisted reservation IDs are deduplicated and their items
are loaded with one guarded `FOR ALL ENTRIES` query. Only an existing
reservation whose items are all marked for deletion is considered cancelled
and reopened. Fully or partially consumed reservations, reservations with any
undeleted item, and missing or archived `RESB` rows remain fail-safe replays.
The cancellation lookup must explicitly report canonical success and may return
only IDs from the requested set; failures, malformed states, and unexpected IDs
return `CANCELLATION_LOOKUP_INVALID` before stock access. Reopening does not
relax payload matching.
The writer conditionally removes the exact old request/document pair and
inserts the replacement claim in its posting LUW; a concurrent retry that no
longer finds that pair rolls back before reservation creation.
The public SAP writer independently preflights every positive pending row before
that LUW begins. Required posting identity, `DEC(13,3)` quantity precision,
requested-versus-allocated ordering, full/partial status consistency, and a
blank initial document must all hold; malformed direct-call input is failed
before idempotency, locking, stock recheck, or reservation APIs.
Every replaceable writer gate must prove success with exact `abap_true`:
idempotency claim, stock lock, fresh-stock recheck, and reservation-document
persistence. Canonical failures retain their business diagnostics; malformed
boolean acknowledgements roll back the LUW, release locks, fail every pending
allocation, and never advance to the next posting phase.
After the writer returns, orchestration also verifies that the response has the
same request set and immutable allocation payload, contains only atomic posted
or failed states, requires a document for every posted row, and forbids one for
failed rows. A malformed response is surfaced as failed posting evidence using
the original allocations instead of trusting mutated adapter data.
Before stock recheck, the writer acquires one exclusive `MARD` lock for each
unique material/plant in ascending lexical order. `LGORT` is initial and its
X-flag is blank, making the lock generic across every storage location in that
material/plant safety domain. The optional wait flag accepts only canonical
`X` or blank at both the coordinator and SAP gateway. Only an exact `X`
acquisition result is trusted; malformed gateway results fail the batch and
release every lock already acquired.
This serializes every allocation sharing one plant-level `MARC-EISBE`
reserve, including batches targeting different locations. Before those locks,
the writer claims every pending request ID in ascending lexical order. Stock
recheck, BAPI reservation creation, document assignment, and returned results
retain the allocator's original business order.
Reservation create and commit messages of type `E`, `A`, or `X` fail and roll
back the entire pending batch. Warning-only responses remain successful: each
row retains the first warning from its create call, and every posted row retains
the first warning from the shared commit. When present, the posting message is
ordered as replacement lineage, create warning, then commit warning. Current
audit, history, and CSV export preserve that composed diagnostic.
Both response tables may contain only standard BAPI message types `S`, `I`,
`W`, `E`, `A`, and `X`. An unknown or blank type is a malformed gateway
response and triggers rollback instead of being ignored as successful.
Every returned reservation number must also contain exactly ten numeric
characters and be unique across the writer batch. Invalid or repeated document
IDs roll back before commit and are removed from every failed result.

Run `ZSTOCK_ALGH_RETENTION` interactively or schedule it as a background job.
Keep `P_TEST` selected to preview the number of rows older than `P_DAYS`; clear
it only for the productive deletion run. The executing user needs
`S_TABU_NAM` activity `03` for preview and activity `06` for deletion on table
`ZSTOCK_ALGH`. Programmatic callers must pass only `X` or blank for simulation;
any other value is rejected by both the retention service and the SAP store.
Retention accepts 1 through 36,500 days and rejects a supplied effective date
later than the application server date before performing date arithmetic. The
store independently requires a noninitial cutoff strictly before `sy-datum`
before authorization or SQL. The retention facade accepts only canonical store
success states and reports malformed adapter responses as failure. Store counts
must be nonnegative, and a failed store response cannot claim affected rows.

Run `ZSTOCK_ALGH_EXPORT` to produce semicolon-delimited CSV in an SAP list or
background spool. Blank `P_FROM` and `P_TO` select the latest 30-day audit
window. `P_FTIME` and `P_TTIME` optionally narrow the first and last log dates;
blank values include the complete boundary days. `P_RFROM` and `P_RTO`
independently bound the underlying requirement
date; either endpoint may be blank for an open interval, and both endpoints are
inclusive. `P_UUID`, `P_REQ`, `P_RES`, `P_PRIOR`, `P_MAT`, `P_PLANT`, `P_SLOC`,
`P_MOVE`, `P_SUNIT`, `P_UNIT`, `P_STRAT`, `P_HFROM`, `P_HTO`, `P_PART`,
`P_FULL`, `P_AVAIL`, `P_STOCK`, `P_SHORT`, `P_FILL`, `P_FPFROM`, `P_FPTO`,
`P_MFFROM`, `P_MFTO`, `P_PRIFRM`, `P_PRITO`,
`P_RQFROM`, `P_RQTO`, `P_AQFROM`, `P_AQTO`, `P_COST`, `P_ORD`, `P_WBS`,
`P_SQFROM`, `P_SQTO`, `P_VQFROM`, `P_VQTO`, `P_SHFROM`, `P_SHTO`,
`P_SALES`, `P_SITEM`,
`P_ASSET`, `P_ASUB`, `P_NET`, `P_NACT`, `P_ASTAT`, `P_PSTAT`, `P_MODE`,
`P_RUN`, `P_DECIDE`, `P_MSG`, and `P_USER` further narrow the result, while `P_MAX`
bounds it to at most 10,000 rows.
`P_RES`
matches the reservation produced by an outcome; `P_PRIOR` matches the cancelled
reservation replaced by that outcome. Material, plant, and storage location are
independent exact filters: supply any combination to inspect a material across
plants, a plant across materials, or one exact stock pool. `P_MOVE`, `P_ASTAT`,
and `P_PSTAT` select an exact movement type, allocation status, and posting
status. The nine account-assignment parameters are independent exact filters;
combine parent and subordinate fields to select one sales item, asset
subnumber, or network activity, or supply only the parent to include all of its
children. `P_SUNIT` selects the original request unit and `P_UNIT` the canonical
base unit. `P_STRAT` selects an exact recorded allocation strategy, including
values produced by a newer application version. `P_HFROM` and `P_HTO` form an
independent inclusive horizon-date interval; either endpoint may be blank for
an open interval. `P_PART`, `P_FULL`, and `P_AVAIL` use a tri-state selector:
blank leaves the dimension unrestricted, `X` selects true, and `-` selects the
stored blank false value. They filter partial-request policy, strict-batch
policy, and whether usable availability was evaluated. `P_STOCK` uses the same
selector symbols for measured usable stock: `X` requires a positive
`AVAILABLE_QTY`, `-` requires an observed zero, and blank is unrestricted. A
nonblank stock selector also requires `AVAILABILITY_CHECKED = X`; combining it
with `P_AVAIL = -` is rejected. Pre-upgrade rows without evidence are therefore
excluded from both stock bands. `P_SHORT` uses the same selector convention:
`X` requires positive `SHORTFALL_QTY`, `-` requires zero, and blank is
unrestricted. Pre-upgrade rows have an initial shortfall and are included by
`-`. `P_FILL` selects fulfillment bands: `F` is exactly 100 percent, `P` is
0.001 through 99.999 percent, `N` is zero, and blank is unrestricted. Pre-upgrade
rows have an initial fill percentage and are included by `N`.
`P_FPFROM` and `P_FPTO` independently bound stored fill percentage from 0
through 100. The interval is inclusive, may have one blank endpoint, and
intersects with `P_FILL` when both are supplied.
`P_MFFROM` and `P_MFTO` form a separate inclusive 0-through-100 interval over
the request's configured minimum-fill policy; either endpoint may be blank.
`P_PRIFRM`/`P_PRITO`, `P_RQFROM`/`P_RQTO`, and `P_AQFROM`/`P_AQTO` form
independent inclusive ranges for priority, canonical requested quantity, and
allocated quantity. A blank endpoint leaves that side open; an inverted closed
range is rejected before authorization or history access.
`P_SQFROM`/`P_SQTO`, `P_VQFROM`/`P_VQTO`, and `P_SHFROM`/`P_SHTO` form
independent inclusive ranges for original source demand, observed available
stock, and shortfall. Source demand uses `P_SUNIT`; available stock and
shortfall use the canonical base unit selected by `P_UNIT`. An available-stock
range automatically requires affirmative availability evidence and cannot be
combined with `P_AVAIL = -`. Blank endpoints are open; negative and inverted
closed ranges are rejected before authorization or history access.
`P_MODE` accepts `P` for
productive, `S` for simulation, or `I` for a
call rejected because its simulation flag was invalid. Leave any dimension
blank to keep it unrestricted. `P_DECIDE` performs an exact match against the
stable decision code; leave it blank to include every code and pre-upgrade
blank row. `P_UUID` selects one immutable append-only audit record, and `P_MSG`
performs an exact match against the persisted diagnostic text. `P_USER`
performs an exact match against the SAP user recorded in `LOGGED_BY`.
If more rows match than `P_MAX`, the report stops and asks for narrower filters
instead of silently producing an incomplete archive.
The export facade also revalidates every row returned by the history reader
against the complete requested scope before producing the CSV header. This
fail-closed boundary prevents a replaceable reader from leaking out-of-window
or out-of-filter audit records; one mismatch rejects the entire export.
The underlying public history reader independently requires noninitial ordered
log dates, rejects an inverted time interval when both endpoints fall on the
same date, rejects inverted closed requirement- and horizon-date intervals, and
rejects policy selectors outside blank, `X`, and `-`. It permits at most 10,001
rows. The export limit remains 10,000; its one additional reader row is used
only as a truncation sentinel. Export also requires an exact affirmative reader
result before emitting a CSV header or data row.
The executing user needs `S_TABU_NAM` activity `03` for `ZSTOCK_ALGH`. Exported
fields, including the complete decision context, are quoted and embedded quotes
are doubled. Values beginning with `=`, `+`, `-`, `@`, tab, carriage return, or
line feed receive a leading apostrophe before quoting so spreadsheet software
treats them as text. The report uses a wide list line so a complete history
record is not wrapped.
