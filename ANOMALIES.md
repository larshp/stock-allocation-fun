# Anomalies and open issues

## RESOLVED-001: availability could change before posting

`zcl_stock_reader_sap` reads a snapshot before `zif_allocation_writer` is
called. The writer now claims request IDs, acquires exclusive generic-location
`MARD` locks per material/plant, performs an aggregate fresh-stock recheck, and
holds the locks through BAPI commit or rollback.

## RESOLVED-002: productive allocation writer was not implemented

Resolved on 2026-08-18 by `zcl_allocation_writer_sap` and
`zcl_reservation_gateway_sap`. The writer calls `BAPI_RESERVATION_CREATE1`,
commits successful batches, rolls back failed batches, and exposes reservation
numbers and BAPI messages through allocation results.

## RESOLVED-003: idempotency was execution-local

Resolved on 2026-08-18 with an atomic insert into the owned `ZSTOCK_ALLOC`
table. Its client/request-ID key arbitrates concurrent claims. The claim and
reservation number are committed by the same BAPI transaction commit; posting
failures roll both back.

## RESOLVED-004: safety stock was repeated per storage location

`MARC-EISBE` is plant-level while allocation pools are storage-location-level.
Resolved by reading all locations for requested material/plant pairs and
maintaining a shared plant balance. Allocation is limited by both location stock
and the plant total after one safety reserve; posting revalidation applies the
same aggregate rule.

## OPEN-005: standard stubs require target-release verification

The local BAPI and DDIC stubs contain only the fields and parameters used by
this solution. They prove local syntax and transpilation, not that a particular
SAP release has an identical activated interface. Compare the function-module
interfaces and field semantics in the target system before deployment.

## TOOL-001: transpiler did not escape function parameter `RETURN`

When the standard BAPI stubs were first transpiled, the generated JavaScript
declared `let return`, causing a strict-mode syntax error before tests ran. The
supported transpiler `options.keywords` setting now includes `return`, producing
the safe identifier `return_` while leaving the ABAP BAPI signature unchanged.

## RESOLVED-006: external stock locking was target-specific

Resolved with the custom `EZSTOCK_POOL` lock object rooted on `MARD`. SAP enqueue
collisions are based on locked table, lock argument, and mode, so compatible
external exact-location and material/plant-prefix locks collide even if they
originate from another lock object. Allocation leaves `LGORT` generic to cover
the plant-level safety domain. Deployment must still verify the key granularity
used by the target system's inventory processes.

## RESOLVED-007: operational audit was current-state only

`ZSTOCK_ALOG` continues to store the latest productive and simulation outcome
for each request ID. `ZSTOCK_ALGH` now also receives a UUID-keyed row for every
outcome. Both representations are persisted atomically through
`zif_allocation_log_store`.

## RESOLVED-008: audit history lacked a retention mechanism

Resolved with `zcl_allocation_log_retention` and report
`ZSTOCK_ALGH_RETENTION`. The report defaults to a 365-day dry run, exposes the
retention period as a parameter, checks `S_TABU_NAM` display or delete activity,
and reports the number of matching or deleted rows. Productive systems should
schedule it according to their approved retention policy.

## RESOLVED-009: audit history had deletion but no export

Resolved with the read-only `ZSTOCK_ALGH_EXPORT` report. It provides bounded
date, request-ID, and run-mode filtering; checks table-display authorization;
and emits CSV-safe records to a wide foreground list or background spool before
retention deletion is scheduled. Exports that exceed the selected row limit are
rejected rather than silently truncated.

## OPEN-010: automated archive delivery is target-specific

The export report deliberately stops at SAP list/spool output. Landscapes that
require unattended transfer to content storage still need a target-approved
destination, credential model, encryption policy, and delivery mechanism.

## RESOLVED-011: allocation quantities had no unit of measure

Resolved by reading `MARA-MEINS`, requiring it on every request, preserving it
in allocations and audit records, checking it again against fresh stock, and
passing it as `BAPI2093_RES_ITEM-ENTRY_UOM`. This prevents quantities expressed
in different units from being silently compared or posted.

## RESOLVED-012: alternative units were not converted

Resolved with `zif_unit_converter`, the testable `zcl_unit_converter`, and a
cached SAP `MARM` factor reader. Alternative quantities are converted with
`UMREZ/UMREN`, rounded to the three-decimal stock precision, and allocated in
the `MARA-MEINS` base unit. Source and canonical values remain available in the
result, audit tables, and CSV export. Missing or invalid factors reject only the
affected request.

## OPEN-013: catch-weight and parallel units are not modeled

The converter supports classic material-specific `MARM` factors. Landscapes
using catch-weight materials, parallel units, batch-specific proportions, or
other industry extensions need a specialized conversion implementation behind
`zif_unit_converter` before those materials are admitted.

## RESOLVED-014: completed retries were reported as posting failures

`ZSTOCK_ALLOC` now persists the request identity, allocation policy, canonical
outcome, and reservation number. Productive execution resolves completed
records before allocation, so an identical retry returns the original result
without consuming current stock or invoking the writer. Reusing an ID with a
different payload is rejected. A concurrent duplicate appearing after the
pre-read remains a rollback failure and succeeds as a replay on a later retry.

## RESOLVED-015: legacy idempotency rows were ambiguous

Systems upgrading an existing `ZSTOCK_ALLOC` table may have reservation rows
without the expanded request identity. `PAYLOAD_VERSION` now distinguishes
current version `001` claims from blank legacy and future unsupported rows.
Unsupported records return a dedicated invalid result before stock access or
posting. Deployment must still reconcile, archive, or deliberately retain those
rows, but runtime behavior is explicit and cannot silently create a duplicate
reservation.

## RESOLVED-016: consumption reservations lacked account assignment

Requests now carry cost center, order, and WBS element through validation,
posting, idempotency, and audit. The allocator requires the standard assignment
for movement types 201, 221, and 261 before any stock is consumed or reservation
is attempted.

## RESOLVED-017: standard consumption assignments were incomplete

The request contract now covers the standard assignments for movement types
201, 221, 231, 241, 251, 261, and 281. Sales-order item, asset subnumber, and
network activity are retained through replay, posting, audit, and export. The
gateway also maps the external WBS identifier to `BAPI2093_RES_HEAD-WBS_ELEMENT`
instead of the internal numeric WBS field.

## RESOLVED-018: movement 291 and customized field selection are not modeled

Movement 291 permits arbitrary account assignments, and customer movement-type
customizing can make additional fields required or forbidden. The allocator
now admits only the explicitly modeled standard movements 201, 221, 231, 241,
251, 261, and 281. Movement 291 and customized movement types fail before unit
conversion or stock consumption. Verify target field selection and extend both
the validation and reservation mapping before adding another type to the
allowlist.

## RESOLVED-019: stock could be disclosed without a plant authorization check

The service previously read replay records and current stock for every supplied
plant without checking whether the caller was allowed to work in that plant.
`zif_allocation_authority` now guards the boundary, and the SAP implementation
checks `M_MATE_WRK` activity `02` once per unique plant. A denial invalidates
the whole batch before idempotency or stock access, for both productive and
simulation calls. The denial path is covered through an injected test double;
open-abap itself grants every `AUTHORITY-CHECK`, so target-role behavior still
needs the normal SAP integration test.

## RESOLVED-020: future demand always competed for current stock

Every supplied request previously entered allocation regardless of how far its
requirement date was in the future. Callers can now pass an inclusive horizon
date through the application and service. New requests beyond that date return
`DEFERRED` before stock reading, unit conversion, or posting, and create no
idempotency claim. Exact completed productive retries are resolved before the
horizon rule and continue to replay their committed reservation.

## RESOLVED-021: cancelled reservations replayed forever

An exact retry previously returned its stored reservation without checking
whether that reservation had subsequently been cancelled. The production
composition now reads `RESB` through `zif_reservation_status`. When an existing
document has items and every item is deletion-flagged, the request re-enters
allocation and the writer conditionally replaces the old request/document pair
inside the new reservation LUW. Changed payloads remain invalid, and concurrent
replacement attempts cannot both acquire the claim.

Missing `RESB` rows and consumed but undeleted items deliberately remain
replayable. Missing data can mean archiving rather than cancellation, while a
consumed reservation represents fulfilled demand; treating either as cancelled
could create a duplicate requirement.

## RESOLVED-022: callers could not require complete batch fulfillment

Request-level all-or-nothing behavior did not prevent other requests in the
same call from posting when one request was partial, rejected, invalid, or
deferred. Callers can now set `iv_require_full_batch`. The service preserves
the original incomplete results, changes every otherwise pending new result to
`ABORTED`, clears its allocation, and skips the writer entirely. Simulations
use the same rule. Existing committed replays remain unchanged because a new
call cannot atomically undo work committed by an earlier call.

## RESOLVED-023: audit rows could not be correlated to one application run

History rows had unique `LOG_UUID` values and request IDs, but no shared value
identified the batch that produced them. The application now generates one
32-character hexadecimal run ID before service execution, returns it to the
caller, and supplies it to every current and history row. History reads and CSV
export accept the run ID as a filter. The ID remains available when audit saving
fails, allowing callers to correlate their own diagnostics with the failed run.
The new audit columns are additive; rows written before deployment remain blank.

## RESOLVED-024: audit rows omitted allocation identity and policy

Operational and history records previously retained quantities, assignments,
statuses, and reservation IDs but omitted the material/plant/location key,
movement, requirement date, request policy, and run policy. An exported outcome
therefore could not be interpreted without the original request. Both audit
tables and CSV output now carry those fields plus the prior reservation replaced
after cancellation. The application passes strategy, horizon, and full-batch
policy to the logger explicitly. Existing rows remain valid with blank values
in the additive columns.

## RESOLVED-025: outcome reasons required message-text parsing

Allocation status described only the broad result, while integrations had to
parse English `POSTING_MESSAGE` text to distinguish no stock, minimum-fill
failure, replay conflict, horizon deferral, authorization denial, and other
decisions. Allocation results now expose a stable `DECISION_CODE`. The logger
persists it in current and historical audit rows, and CSV export includes the
same value. The code describes the allocation-layer decision; posting status
and BAPI diagnostics remain separate. Existing audit rows remain valid with a
blank value in the additive column.

## RESOLVED-026: audit export could not filter by decision reason

Decision codes were present in history and CSV output, but operators still had
to export every outcome in a date/run window to isolate one reason. The history
reader and `ZSTOCK_ALGH_EXPORT` now accept an optional exact decision-code
filter exposed as `P_DECIDE`. The filter remains subject to the existing
authorization and row bound. It intentionally accepts future code values and
uses blank to mean no predicate, preserving visibility of pre-upgrade rows.

## RESOLVED-027: outcomes omitted the stock quantity behind the decision

Allocation results and audit rows showed requested and allocated quantities,
but not the usable balance seen when the allocator made its choice. They also
could not distinguish an observed zero from a path that skipped stock access.
Results now carry `AVAILABILITY_CHECKED` and `AVAILABLE_QTY`; the logger stores
both in current/history audit and CSV export emits them. The quantity is the
canonical balance after safety-stock protection and earlier decisions in the
same run. Skipped paths and pre-upgrade rows retain a blank flag, so their
initial numeric value cannot be mistaken for observed stock.

## RESOLVED-028: audit export could not isolate a stock pool

Audit history retained material, plant, and storage location, but the export
reader could only narrow by dates, request/run identity, mode, and decision.
Operational analysis therefore exported unrelated materials or locations from
busy runs. The reader SQL and `ZSTOCK_ALGH_EXPORT` now expose independent exact
filters through `P_MAT`, `P_PLANT`, and `P_SLOC`. They compose with the existing
authorization, date, decision, correlation, and row-bound controls; blank keeps
the corresponding stock-key dimension unrestricted.

## RESOLVED-029: audit export could not isolate operational outcomes

Operators could filter by decision code but not by movement type, broad
allocation status, or posting status. Finding posting failures or all rejected
movement-201 requests still required exporting unrelated rows. The history
reader and `ZSTOCK_ALGH_EXPORT` now expose exact predicates through `P_MOVE`,
`P_ASTAT`, and `P_PSTAT`. They compose with every existing authorization,
identity, stock-key, decision, date, and row-limit control. Unknown future
values remain queryable, while blank leaves each dimension unrestricted.

## RESOLVED-030: a successful converter could supply zero canonical demand

The concrete unit converter rejects quantities that round to zero at stock
precision, but the allocator trusted every successful converter response. A
replaceable converter returning zero or a negative quantity could therefore
reach fill-percentage arithmetic with an invalid denominator. The allocator
now rejects that response before availability calculation or stock consumption
with `CANONICAL_QUANTITY_INVALID`, preserving the caller's source quantity and
unit for diagnosis. The concrete converter's rounding edge and the allocator's
independent contract both have regression coverage.

## RESOLVED-031: audit export could not trace reservation replacements

Audit history retained the reservation created by an outcome and the cancelled
reservation it replaced, but neither identifier was queryable. Operators had
to export a wider date window and search the CSV after authorization and row
limits had already been applied. The history reader and `ZSTOCK_ALGH_EXPORT`
now expose independent exact filters through `P_RES` and `P_PRIOR`. They
compose with all existing date, identity, stock, outcome, run, authorization,
and row-bound controls, while blank leaves the corresponding lineage role
unrestricted.

## RESOLVED-032: audit export could not select a demand-date window

The export date interval applied only to `LOGGED_ON`. Although audit rows also
retained `REQUIREMENT_DATE`, operators could not isolate demand due within a
planning window without exporting unrelated records. The history reader and
`ZSTOCK_ALGH_EXPORT` now expose independent inclusive endpoints through
`P_RFROM` and `P_RTO`. Either endpoint may be blank for an open interval, while
an inverted closed interval is rejected before reading history. The demand
window composes with the audit date window and every existing authorization,
identity, stock, outcome, run, lineage, and row-bound control.

## RESOLVED-033: noncanonical boolean values could enable productive posting

ABAP boolean parameters are character fields, so callers could supply values
other than `X` and blank. The service compared simulation only with `X`; a value
such as `Y` therefore followed the productive path and could create
reservations. A malformed `allow_partial` value also silently behaved as false.
The allocator now rejects invalid request flags with `REQUEST_FLAG_INVALID`,
and the service rejects invalid simulation or full-batch policy for the entire
call with `RUN_POLICY_INVALID` before authorization, replay, stock access,
conversion, or posting. Invalid simulation input is logged as run mode `I`
rather than being mislabeled productive, and audit export can filter that mode.

## RESOLVED-034: reservations could contain conflicting account assignments

Validation required the correct assignment for each supported movement but did
not require unrelated assignment fields to be blank. Because the reservation
gateway maps every populated field into `BAPI2093_RES_HEAD`, a movement-201
request could carry both a cost center and an order, for example, leaving the
BAPI to reject or interpret an ambiguous header. Each movement now admits only
its modeled assignment family: cost center, WBS, sales order/item,
asset/subnumber, order, or network/activity. Mixed families return
`REQUEST_RULE_INVALID` before unit conversion, availability evaluation, stock
consumption, or posting.

## RESOLVED-035: unsupported strategies reached request dependencies

The allocator returned `STRATEGY_UNSUPPORTED` without posting, but the service
did not validate the strategy until after plant authorization, idempotency
lookup, reservation-status inspection, and stock reading. An invalid run policy
therefore caused unnecessary business-data access and could fail in a
dependency before returning its actual configuration error. The service now
accepts only the three published strategy constants before any request-level
dependency is called. It returns the existing `CONFIG_ERROR` and
`STRATEGY_UNSUPPORTED` outcome for each request, while the allocator keeps its
own validation for direct callers.

## RESOLVED-036: invalid requests reached business-data dependencies

Structural request validation occurred inside allocation, after the service had
already checked plant authorization, queried idempotency and reservation
status, and selected stock. Malformed rows could therefore access business data
or fail in a dependency before returning their actual validation outcome. The
allocator now exposes its pure validator for orchestration preflight. Invalid
rows skip every request-level dependency while remaining in the final result;
valid rows in the same call continue under the existing full-batch policy.
Replay lookup is performed once per request ID, but valid duplicate rows retain
all stock keys because allocation ordering, not input order, determines which
row is processed first.

## RESOLVED-037: idempotency claims had strategy-dependent lock order

The writer claimed `ZSTOCK_ALLOC` rows in allocation order. Because strategy,
priority, and due date can order the same request IDs differently across two
overlapping batches, the database row locks could be acquired in opposite
orders before either process reached the deterministically ordered stock
enqueue locks. The writer now claims a request-ID-sorted copy of pending
allocations. Stock recheck and reservation creation continue in the original
allocation order, so the concurrency fix does not alter posting priority,
document mapping, or returned result order.

## RESOLVED-038: successful BAPI warnings were discarded

The writer inspected reservation create and commit messages for transactional
errors but cleared posting messages after a successful commit. Operators could
therefore see a posted reservation without the warning returned by SAP, and the
diagnostic never reached current audit, history, or CSV export. Successful rows
now retain the first item-level create warning and the first batch commit
warning. Replacement lineage is composed before those warnings. Error, abort,
and exit messages still roll back the full pending batch and replace any
provisional warning with the failure diagnostic.

## RESOLVED-039: replay preflight issued one query per request

The service called the idempotency store once for every unique request ID, and
the SAP implementation used `SELECT SINGLE` each time. Large allocation batches
therefore incurred an avoidable sequence of database round trips before their
already set-oriented stock read. The store now accepts a sorted unique ID set
and loads matching `ZSTOCK_ALLOC` payloads with one guarded
`FOR ALL ENTRIES` query. Productive orchestration performs that call only after
validation and plant authorization. Duplicate rows remain in allocation input,
and simulations or batches without valid requests perform no replay query.

## RESOLVED-040: cancellation checks issued one query per reservation

After replay payload loading, the service called the reservation-status port
once for every persisted document, and the SAP implementation selected `RESB`
items separately each time. A large replay batch therefore retained an N+1
database access pattern even after idempotency loading became set-oriented.
The status port now accepts a sorted unique document set and classifies all
matching items from one guarded `FOR ALL ENTRIES` read. It returns a document
only when at least one item exists and every item is deletion-flagged, preserving
the prior fail-safe behavior for missing data and reservations with active
items.

## RESOLVED-041: location locks did not protect shared plant safety stock

Availability protects one `MARC-EISBE` reserve across every storage location
for a material/plant, but posting previously locked each requested `MARD` row
independently. Concurrent batches targeting different locations could both
recheck against the same plant balance and consume the shared reserve. The lock
coordinator now deduplicates and sorts material/plant keys, while the SAP
gateway calls `EZSTOCK_POOL` with initial `LGORT` and a blank `X_LGORT` flag.
That generic prefix lock serializes all locations sharing the reserve. Focused
tests verify key ordering, cross-location deduplication, explicit release, and
cleanup when acquisition fails partway through a batch.

## RESOLVED-042: quoted CSV cells could execute spreadsheet formulas

CSV quoting protected delimiters and embedded quotes but did not stop common
spreadsheet applications from evaluating a cell beginning with `=`, `+`, `-`,
`@`, tab, carriage return, or line feed. Audit fields such as request IDs,
account assignments, and diagnostic messages can contain externally supplied
text, so opening an export could execute a crafted formula. The shared field
encoder now prefixes those values with an apostrophe before doubling quotes and
wrapping the cell. Ordinary values and the established semicolon-delimited
shape remain unchanged.

## RESOLVED-043: direct history reads bypassed export bounds

The export service rejected invalid date ranges and row limits above 10,000,
but `zcl_allocation_history_reader` was public and passed its parameters
directly into Open SQL. A direct authorized caller could therefore supply
initial or inverted dates and an arbitrarily large `UP TO` value, bypassing the
bounded-read contract. The reader now validates its own log and requirement
date ranges and limits every fetch to 10,001 rows. The extra row preserves the
exporter's truncation sentinel while preventing unbounded direct reads.

## RESOLVED-044: malformed retention flags enabled productive deletion

The retention API treated only `X` as simulation and passed every other value
to the store. The store used the same comparison to choose authorization and
SQL, so a noncanonical value such as `Y` selected activity `06` and executed
productive deletion. The facade and concrete store now independently accept
only `X` and blank, rejecting malformed intent before cutoff work,
authorization, or SQL. The store also rejects an initial cutoff date, keeping
direct destructive calls fail closed even when the facade is bypassed.

## RESOLVED-045: future retention dates could widen deletion scope

The retention facade exposed an effective-date override for deterministic
execution but allowed it to be later than the application server date. A caller
could therefore calculate a future cutoff and select recent or current history
for deletion. Unbounded retention days could also drive unsafe date arithmetic,
while direct store calls accepted present or future cutoffs. Retention is now
limited to 1 through 36,500 days, future effective dates are rejected before
subtraction, and the store requires every cutoff to be noninitial and strictly
earlier than `sy-datum` before authorization or SQL.

## RESOLVED-046: audit export could not isolate a logging user

Audit history recorded `LOGGED_BY`, but authorized readers and the export
report could not use it as a predicate. Operational investigations therefore
had to export unrelated users' rows and filter the CSV afterward. The exact
optional filter now flows through the public reader, SQL, export facade, and
report parameter `P_USER`. While adding it, the blank-date default was corrected
from subtracting 30 days to subtracting 29: because both endpoints are
inclusive, the former selected 31 calendar dates despite the documented
30-day window.

## RESOLVED-047: audit export could not bound time within a day

The history reader and export report bounded `LOGGED_ON` but not `LOGGED_AT`.
Operators investigating a short incident on a high-volume day therefore had to
export the entire day, potentially exceeding the row ceiling even when the
relevant interval was small. Optional start and end times now qualify the first
and last selected dates as one inclusive timestamp interval. Blank endpoints
retain full-day behavior, and both the facade and direct reader reject an
inverted interval when the date endpoints are equal.

## RESOLVED-048: audit export could not filter account assignments

Audit rows and CSV output retained all modeled consumption assignments, but the
authorized history query could not select them. Investigating one cost center,
order, project, sales item, asset, or network activity therefore required a
broader export and client-side filtering, which could hit the row ceiling before
the relevant records were returned. Every assignment component is now an
optional exact predicate in the public reader, bounded SQL, export facade, and
report. Parent and subordinate components remain independent so operators can
choose either a whole business object or one exact child.

## RESOLVED-049: audit export could not isolate conversion or run policy

Although history retained source and canonical units, allocation strategy, and
the run horizon, operators could not select them before the bounded SQL read.
Diagnosing one conversion path or comparing one policy therefore required a
broader client-side export that could exceed the row ceiling. Exact source-unit,
base-unit, and strategy predicates plus an inclusive horizon-date interval now
flow through the public reader, export facade, and report. The reader and facade
independently reject inverted closed horizon intervals before authorization or
data access.

## RESOLVED-050: false audit policies could not be filtered explicitly

Several audit dimensions are stored as canonical ABAP booleans, where blank is
false. An optional boolean filter therefore cannot distinguish "select false"
from "do not filter," leaving operators unable to isolate all-or-nothing
requests, ordinary non-strict runs, or decisions where availability was not
evaluated. A shared tri-state selector now uses blank for unrestricted, `X` for
true, and `-` for the stored blank false value. It is exposed for all three
dimensions through the bounded reader, export facade, and report, and invalid
selector values are rejected at both public layers before data access.

## RESOLVED-051: malformed stock-lock booleans could be trusted

The lock coordinator forwarded any constructor wait value to the enqueue
gateway, and treated every gateway acquisition value except blank as success. A
noncanonical character could therefore alter generated enqueue behavior or make
the writer proceed without proven lock ownership. The coordinator and SAP
gateway now reject wait values outside `X` and blank before enqueue access. The
coordinator trusts only an exact `X` acquisition result; any malformed result
releases earlier locks and fails with a deterministic diagnostic.

## RESOLVED-052: malformed writer acknowledgements could advance posting

The reservation writer tested idempotency claim, lock acquisition, stock
recheck, and document update only for canonical false. A replaceable adapter
returning another nonblank character was therefore treated as success, which
could advance the LUW without a proven claim, lock, availability decision, or
document link. Each gate now requires exact `abap_true`. Canonical failures keep
their existing diagnostics; noncanonical acknowledgements produce a
phase-specific error, roll back, release locks, and fail all pending rows before
the next posting phase.

## RESOLVED-053: malformed decision adapter flags could be trusted

Plant authorization, material conversion-factor lookup, and unit conversion
tested replaceable adapter results only for canonical false. Another nonblank
character could therefore bypass an authorization denial or enter conversion
arithmetic without a proven factor or successful conversion. Each boundary now
accepts only exact `abap_true` or `abap_false`. Malformed authorization returns
`CONFIG_ERROR` with `AUTHORIZATION_RESULT_INVALID` before replay or stock access;
malformed factor and converter results fail conversion before arithmetic or
availability evaluation.

## RESOLVED-054: adapter response envelopes were only partially validated

Set-oriented replay lookup accepted rows outside the requested ID set and
treated malformed found flags as absent, so allocation could continue without
trustworthy idempotency evidence. Audit export, retention, and logging paths
also allowed noncanonical success values to escape as successful outcomes.
Replay rows now require canonical flags and requested IDs before cancellation
or stock access, with violations returning `REPLAY_LOOKUP_INVALID`. Audit and
retention facades reject malformed states, while logger and application results
normalize persistence acknowledgements to canonical booleans.

## RESOLVED-055: fulfillment evidence disappeared after allocation

Allocation results exposed shortfall quantity, but operational and historical
audit dropped it, and the percentage used to assess partial fulfillment was not
retained anywhere. Operators therefore had to reconstruct shortages from CSV
quantities and could not distinguish a persisted metric from an inferred one.
`SHORTFALL_QTY` and `FILL_PCT` now flow through results, both audit tables, and
CSV export. Strict-batch abort resets fill to zero. Replayed outcomes are
validated before derivation; impossible quantities or a missing canonical unit
return `REPLAY_OUTCOME_INVALID` instead of producing negative shortfall or fill
above 100 percent.

## RESOLVED-056: shortage evidence could not narrow audit exports

Persisting shortfall quantity made shortage analysis possible but still forced
operators to export every matching outcome and filter client-side. A shared
tri-state selector now flows through the authorized history reader, export
facade, and executable report. Blank leaves shortfall unrestricted, `X` emits
only positive shortages, and `-` emits zero-shortfall rows. Invalid selectors
fail before authorization or SQL. Because the column is additive, pre-upgrade
rows remain part of the zero selection rather than being misclassified as a
known positive shortage.

## RESOLVED-057: audit could not distinguish fulfillment bands

Shortage presence alone could not isolate partially served demand from rows
with no allocation, nor identify exactly fulfilled outcomes without combining
status and decision assumptions. The authorized reader, export facade, and
report now accept a dedicated fill selector: `F` for exactly 100 percent, `P`
for 0.001 through 99.999 percent, `N` for zero, and blank for unrestricted.
Invalid values fail before authorization or SQL. Pre-upgrade rows retain their
initial fill value and consequently remain in the none band.

## RESOLVED-058: request numeric values could change during persistence

Public request quantities and minimum-fill percentages use `DECFLOAT34`, while
reservation and audit persistence use three-decimal packed fields. Values with
extra decimals could therefore be allocated on one value and later rounded in
the persisted idempotency payload; oversized values could overflow SAP-facing
fields. Shared request validation now requires quantities to fit `DEC(13,3)`
exactly, caps them at 9,999,999,999.999, bounds minimum fill to 0 through 100,
and requires positive priority before any dependency call. Successful converter
output is independently capped before availability arithmetic. Input failures
retain `INVALID_REQUEST`; invalid canonical output retains
`CANONICAL_QUANTITY_INVALID`.

## RESOLVED-059: audit could not isolate observed stock exhaustion

Audit history retained usable-stock evidence but exposed only whether a value
had been measured. Operators could not directly separate decisions made with a
positive balance from those made at an observed zero, and filtering the numeric
column alone would misclassify pre-upgrade rows whose evidence flag is blank.
The authorized reader, export facade, and report now accept `P_STOCK`: `X`
selects positive observed stock, `-` selects observed zero, and blank is
unrestricted. Every nonblank selection also requires the canonical checked flag.
A contradictory `P_AVAIL = -` combination fails before authorization or SQL.
