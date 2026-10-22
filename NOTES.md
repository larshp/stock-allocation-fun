# Development notes

## 2026-10-21

- Batch expiry exposure now includes a fixed seven-row manufacturing-age
  distribution for filtered positive-stock rows, with future, today, four
  dated age bands, and unknown-date buckets. Each row reports row shares,
  stock-category quantities, and category shares; UOM results include converted
  quantities. A matching band selector filters base and UOM detail, including
  the unknown-date band. Regressions cover signed ages, unknown dates, band
  validation, and selector echo. A manufacture-date source filter selects plant,
  global-fallback, or blank-source rows and is covered in base and UOM flows.

- Batch expiry exposure now also reports the youngest recorded manufacture
  date among positive-stock rows matching the filters. The summary includes
  storage location, batch, valuation type, date source, and signed age; ties
  use the same deterministic identity ordering as the oldest-manufacture
  summary. Base and UOM regressions cover range-filtered and unit-aware
  results. PLAN validation, abaplint, transpilation, and ABAP Unit all pass.

- Fixed the failures uncovered by the full `npm test` run: the stock test
  double now carries valuation type into synthesized batch statuses, dated
  location UOM storage splits preserve allocation sequence, and manufacturing
  age/date-priority regression expectations now match the established output
  ordering and report horizon. The full pipeline now passes through the native
  Windows Node execution path; the regular WSL 1 launcher still cannot start
  Node.

- Batch expiry exposure details now include the recorded manufacturing date,
  the plant/global source marker, and signed days since manufacture for dated
  and undated batch rows. The repository prefers MCHA-HSDAT and falls back to
  MCH1-HSDAT; unit-aware details preserve the base row metadata. The validator
  and local stubs now cover both SAP date fields.

- Batch expiry exposure now identifies the chronologically earliest recorded
  manufacture date among positive-stock rows matching the exposure filters,
  including expiry-undated rows. The result returns the batch identity, date
  source, and signed age; the UOM result echoes those fields. The manufacturing
  age regression covers the base and UOM results. The configured Node gates
  could not be rerun in this WSL 1 environment.

- Sales-order aggregate and FEFO issue previews now expose one-based
  `allocation_sequence` ranks on summaries; FEFO batch splits echo the rank.
  Base and unit-aware date-first previews retain caller-order results and
  preserve the trace, including zero-allocation rows. Regressions cover date
  and priority precedence.

- Priority material/plant, cross-plant, and storage-location base and UOM
  allocators now expose a one-based `allocation_sequence` for the actual
  calculation order while retaining caller-order results. Priority UOM ATP
  local estimates preserve it. Regressions cover priority order, ties,
  repeated caller IDs, and zero-allocation rows. The WSL 1 Node launcher still
  blocks the project validation pipeline.

- Exact-batch base and UOM priority allocators now expose the same processing
  sequence on summaries and batch splits. Date-first ranks follow date then
  priority, and the ATP local estimate retains the ranks. Regressions cover
  caller-order output, repeated IDs, and zero-allocation rows. Project
  validation remains unavailable through the WSL 1 Node launcher.

- WBS date-first location and transfer previews now expose the processing rank
  on summaries, source splits, and assignment rows. Location and batch paths
  retain caller order and repeated-ID distinctions; the ATP estimates preserve
  the rank. Regressions cover date/priority order and adapter results. Validation
  remains unavailable through the WSL 1 Node launcher.

- Priority FEFO base and UOM allocators now expose the processing sequence on
  summaries and batch splits. Date-first ordering and caller-order ATP local
  estimates retain the same rank, including for zero-allocation demands.
- Quality FEFO priority allocators now expose the same sequence for quality
  summaries and batch splits; quality UOM ATP local estimates preserve it.

- Cross-plant exact-batch and FEFO priority allocators now trace demand order on
  summaries, source-plant rows, and location or batch splits. UOM ATP local
  estimates preserve the ranks, including rows that allocate zero. Cross-plant
  exact-batch ranks follow effective as-of date (blank means today), then
  priority and stable input order.

- Local multi-demand date-first allocation now exposes a one-based
  `allocation_sequence` in calculation order while retaining caller-order
  results. Single-request, UOM, and ATP local estimates preserve the rank;
  regression coverage includes date precedence, same-date priority, and
  zero-allocation requests.

- Cross-plant date-first allocations now expose the same rank on demand
  summaries, source-plant rows, and location splits. Date, priority, and stable
  input order determine the rank; unit and ATP local estimates retain it.

- Single-plant location allocation by date now exposes the sequence on demand
  summaries and storage-location splits. UOM and ATP local estimates keep the
  same date, priority, and stable caller-order ranks.

- Cross-plant dated FEFO and exact-batch allocation now expose the processing
  sequence on summaries and emitted splits. FEFO follows material, date,
  priority, and input order; exact-batch follows date, priority, and input
  order. UOM and ATP local estimates retain the ranks, including zero-stock
  summaries.

- WBS `PREVIEW_FEFO_BY_DATE` now reports processing order on summaries, batch
  splits, and WBS assignment rows. Date, priority, and stable input order rank
  the demands; ATP local estimates retain the trace for repeated caller IDs.

- Quality FEFO release and send wrappers now reject all location-scope inputs
  when the demand table is empty, including scopes carried by the preview,
  shared and per-request priorities, and shared allowlists. Regressions cover
  all four posting variants and assert empty calls make no stock reads or
  movement calls. The local WSL 1 Node launcher is unavailable, so lint,
  transpilation, and ABAP Unit could not be run in this environment.

- Fixed the planned-order finish-window query after its special-procurement
  regression returned no rows under the transpiler. The transpiled SQL mishandled
  `@is_selection-material`; a typed local material value now feeds both query
  branches, and PLAN validation checks that assignment and predicate. Full
  `npm test` passes under the installed Linux Node runtime.
- Sales-order allocation requirements now accept a per-item minimum coverage
  floor. Ordinary, location, batch, FEFO, and dated allocation paths pass the
  threshold to the shared allocator and echo it with F/P/U outcome and
  base-unit coverage; schedule-line rows inherit an item-wide requirement
  unless a more specific row is supplied.
- Sales-order aggregate and FEFO issue writers and quality FEFO writers now
  revalidate echoed coverage floors before movement creation. The shared
  high-precision check accepts zero allocations for the existing partial
  allocation policy and rejects positive quantities below their floor.
- Project-WBS issue writers and batch/location transfer writers now perform
  the same final coverage-floor check after their fresh allocation rechecks
  and before building the movement request.
- Aggregate sales-order issue previews now return `allocation_outcome` (`F`
  fully covered, `P` partially covered, `U` uncovered). Unit-aware results
  derive the outcome from base quantities so display-unit rounding cannot
  change it; full-quantity mode reports underfilled requests as uncovered.
- Aggregate issue requests now support a per-request `minimum_coverage_pct`
  from 0 through 100. If provisional base-unit coverage misses the threshold,
  the preview leaves shared stock untouched for later demands; zero preserves
  partial allocation behavior. FEFO previews apply the same gate before
  consuming batch balances, return F/P/U outcomes, and echo the threshold on
  summaries and batch splits.
- Shared material/plant allocation now applies `minimum_coverage_pct` to
  single requests, base and UOM demand rows, priority methods, and ATP
  wrappers. Thresholds are validated and echoed in allocation results; a
  demand below its base-unit coverage floor leaves stock for later requests.
- Local date-first material/plant single requests and base/UOM demand rows now
  accept the same coverage floor. It is applied against availability at each
  required date before consuming the shared balance, echoed on dated
  summaries, and preserved through date-first ATP wrappers.
- Production component allocation policies now accept `minimum_coverage_pct`
  per reservation. The scoped allocator checks eligible base-unit stock after
  date, location, batch, expiry, fallback, receipt, and safety-stock rules and
  leaves stock untouched for a component below its floor; summaries echo it.
- Production component local estimates now report F/P/U outcomes and the
  two-decimal base-unit `allocation_coverage_pct`; grouped estimates preserve
  their date-based plant summary values, and zero-demand percentages are zero.
- Plant-level cost-center demand previews now accept per-row
  `minimum_coverage_pct` floors. The floor is checked in base units before
  shared stock is consumed, passed through unit, priority, and ATP paths, and
  echoed on allocation results; PLAN validation, lint, and transpilation are
  the static gates for this change.
- Date-first cost-center demand previews now accept the same per-row coverage
  floor. It is evaluated against availability on each required date and
  projected receipts, then retained by UOM and ATP results.
- Cost-center location previews now also accept per-demand coverage floors,
  applied after location eligibility and before location balances are used.
  Priority allocation and ATP wrappers retain the floor and the allocation
  summary echoes it.
- Date-first cost-center location previews now pass the same floor to the
  dated location allocator, where it is checked against eligible stock and
  caller-provided receipts at each required date.
- Exact-batch and FEFO cost-center previews now pass per-row floors into the
  batch allocator. Thresholds are checked after expiry, shelf-life, location,
  receipt, and safety-stock eligibility; date-first FEFO and ATP adapters keep
  the floor on their allocation results.
- Atomic and bulk cost-center reservation demand rows now accept per-demand
  minimum coverage floors. The floor passes through location, exact-batch, and
  FEFO previews, including date-first ordering wrappers, and is checked before
  reservation writes.
- STO creation now revalidates carried minimum coverage floors against
  requested and allocated base quantities before building order requests.
  Zero allocations remain valid floor rejections; positive allocations below
  their threshold fail before any purchase-order write.
- Cost-center goods-issue adapters now revalidate echoed coverage floors before
  posting single, location, date-first location, exact-batch, or FEFO splits.
  Zero allocations remain valid floor rejections; positive below-floor issues
  fail before movement creation.
- Single cost-center preview and reservation methods now accept a scalar
  minimum coverage floor. It is validated before UOM conversion, passed into
  FEFO, exact-batch, or location allocation, and prevents reservation creation
  when eligible stock falls below the requested threshold. Results also expose
  F/P/U outcome and base-unit coverage rounded to two decimals.
- WBS project-stock FEFO and location previews now gate eligible base-unit
  stock by per-demand minimum coverage before changing the shared WBS balance.
  Priority, date-first, and ATP paths preserve the floor; summaries expose
  F/P/U outcome and coverage, and FEFO splits echo the floor.
- WBS transfer FEFO and location previews now carry per-demand coverage floors
  through base, priority, date-first, and ATP adapters. The floor applies to
  eligible source-WBS stock before the transfer consumes any shared balance.
- WBS FEFO and location reservation methods now preserve floors through the
  first preview and fresh recheck, including priority and date-first methods.
- Priority and date-first WBS location and FEFO issue wrappers, and WBS
  transfer posting wrappers, now carry the floor through fresh stock rechecks.
  PLAN validation passes; abaplint reports zero issues and transpilation passes.
- Undated `ALLOCATE_BY_STORAGE_LOCATION` base and UOM demand rows now support
  the same coverage floor. It is applied after location scope and safety
  stock; a rejected row consumes no location balance, and priority and ATP
  adapters carry the field.
- `ALLOCATE_LOCATION_BY_DATE` now applies the floor to availability on each
  demand's required date, including eligible projected receipts. Rejected rows
  preserve shared stock; UOM and ATP forms pass through the threshold.
- Exact-batch, FEFO, and quality FEFO allocations now validate and apply the
  per-demand coverage floor against eligible base-unit stock before consuming
  batch balances. UOM and priority adapters carry the threshold through, ATP
  wrappers retain it, and summaries plus FEFO splits echo it.
- Valuation-type allocations now accept the coverage floor on base and UOM
  demand rows. It is checked against eligible availability after valuation,
  location, batch, receipt, expiry, source, and safety-stock scopes; rejected
  rows consume no balance, and UOM and ATP paths preserve the threshold.
- Cross-plant ordinary and date-based allocation now applies the floor to
  combined source-plant availability after location, receipt, cutoff, and
  safety-stock rules. Rejected rows consume no source balance; priority, UOM,
  and ATP adapters carry and echo the threshold.
- Cross-plant exact-batch and FEFO allocation, including date-first forms, now
  checks each floor against combined eligible source-plant stock before
  consuming batch balances. UOM, priority, and ATP paths carry the threshold;
  summaries and FEFO batch splits echo it.
- Cross-plant ordinary, dated, exact-batch, and FEFO allocation summaries now
  report `allocation_outcome` as F/P/U from base-unit allocation quantities.
  UOM, priority, and ATP adapters preserve the summary outcome.
- Cross-plant ordinary, dated, exact-batch, and FEFO summaries now report
  `allocation_coverage_pct`, rounded to two decimals from allocated/requested
  base quantities and zero for zero-quantity demands. UOM, priority, and ATP
  adapters preserve the percentage.
- Shared material/plant, storage-location, dated-location, exact-batch, and
  FEFO summaries now report the same two-decimal `allocation_coverage_pct` from
  base quantities; UOM, priority, and ATP adapters preserve it.
- Local date-first single-request and demand-list summaries now report F/P/U
  and two-decimal `allocation_coverage_pct` from base quantities; UOM and ATP
  adapters preserve both summary values.
- Shared material/plant, location, batch, and FEFO summaries now report
  `allocation_outcome` as `F` (full), `P` (partial), or `U` (none), based on
  base-unit quantities. Unit, priority, and ATP results retain the same
  outcome on each local allocation.
- Production-order finish-window selection accepts `active_status_codes` for
  OR-matching multiple active SAP status codes. The selector is exclusive with
  `active_status_code`, rejects blank list entries, and rechecks that at least
  one requested status remains active after the detail/status reads.
- Production-order finish-window selection now supports inclusive lower and
  upper bounds on `over_receipt_qty_order_unit`. Bounds apply in the AFPO order
  unit before pagination; zero includes valid items without an over-receipt,
  and invalid receipt-progress quantities cannot match. Detail reads recheck
  the derived quantity and its validity.
- Production-order bulk and finish-window items now report
  `over_receipt_pct_of_order_qty`, the excess received quantity as a percentage
  of order quantity. It is zero for valid items without excess, can exceed
  100.00, and remains initial for invalid receipt-progress quantities.
- Production-order bulk and finish-window items now report
  `over_receipt_quantity_base`, converting the positive receipt excess into the
  material base unit when receipt progress and the quantity conversion are
  valid. It is zero for valid items without excess and initial otherwise.
- Finish-window selection now accepts inclusive lower and upper bounds on the
  raw over-receipt-to-order percentage. Bounds are nonnegative and unbounded
  above; filtering uses the unrounded ratio before pagination and rechecks it
  after detail reads.
- Finish-window selection now accepts inclusive base-unit over-receipt bounds.
  The key query compares positive AFPO receipt excess through its order-to-base
  ratio before pagination; the service checks receipt-progress validity and
  conversion success again after detail reads.

## 2026-10-20

- Production confirmation detail rows now expose `exec_duration_status`:
  valid (`V`), invalid complete pair (`I`), or missing execution date (`M`).
  They also expose `exec_duration_seconds` for valid intervals, with initial
  values for invalid or missing intervals. Zero-duration intervals remain
  valid. Both fields are carried into base-unit detail rows. Coverage includes
  positive, invalid, missing, and zero intervals. The full unit suite and PLAN
  validation pass; abaplint remains at the existing 627-finding baseline.
- Work-center confirmation summaries now expose `exec_covered_seconds`, the
  union of valid intervals after merging overlaps. Center totals combine units;
  nested unit rows and base-work-center rows report their own unions. Invalid
  and missing intervals are excluded, reversed intervals remain included, and
  zero-duration rows add no covered time. Coverage is page-scoped and is not
  shift-calendar utilization. The full unit suite and PLAN validation pass;
  abaplint remains at the existing 627-finding baseline.
- Operation and order confirmation summaries now expose `exec_covered_seconds`
  at their own group scope. Raw summaries keep quantity units separate, while
  base operation and order summaries merge source-unit intervals within each
  converted base-unit group. The regression checks raw and base unions across
  overlapping, gapped, zero-length, and cross-day intervals. The full unit
  suite and PLAN validation pass; abaplint remains at the existing
  627-finding baseline.
- Confirmation summaries now report `exec_overlap_excess_seconds`, the valid
  duration sum beyond the covered-time union. Triple overlaps count excess once
  for each interval beyond the first; a regression checks the raw-unit and
  converted base-unit groups against a three-way overlap. The full unit suite
  and PLAN validation pass; abaplint remains at the existing 627-finding
  baseline.
- Confirmation summaries now report `exec_peak_concurrency`, the maximum
  number of simultaneous valid positive-duration intervals in each group.
  Touching interval boundaries do not count as concurrent; zero-duration
  intervals are excluded. The full unit suite and PLAN validation pass;
  abaplint remains at the existing 627-finding baseline.
- Confirmation summaries now report `exec_idle_gap_seconds` within the
  envelope of positive-duration intervals. It excludes time before the first
  interval, after the last one, and zero-duration-only endpoints. The full
  unit suite and PLAN validation pass; abaplint remains at the existing
  627-finding baseline.
- Confirmation summaries now report `exec_overlap_wall_seconds`, elapsed
  wall time with at least two valid positive-duration intervals active. Triple
  overlaps count once per instant, distinct from excess-duration accounting.
  The full unit suite and PLAN validation pass; abaplint remains at the
  existing 627-finding baseline.
- Confirmation summaries now report `exec_overlap_episode_count` for separate
  continuous overlap stretches. A positive-duration gap starts another episode,
  while stretches meeting at an endpoint remain one. The full unit suite and
  PLAN validation pass.
- Confirmation summaries now report `exec_peak_concurrency_secs`, summing the
  elapsed time at the group's maximum concurrent interval count. Time at an
  earlier, lower peak is discarded if a higher peak occurs later. The full
  unit suite and PLAN validation pass; abaplint remains at the existing
  627-finding baseline.
- Confirmation summaries now report `exec_longest_overlap_secs` for the
  longest uninterrupted overlap episode; separate episodes are compared and
  only the longest contributes. The full unit suite and PLAN validation pass;
  abaplint remains at the existing 627-finding baseline.
- Confirmation summaries now report `exec_overlap_avg_secs` as the arithmetic
  mean duration of overlap episodes, retaining fractional seconds when needed.
  The full unit suite and PLAN validation pass; abaplint remains at the existing
  627-finding baseline.
- ABAP lint autofixes aligned parameter and type expressions in 11 files; the
  remaining nine parser-space findings were corrected manually. The formatting
  diff is whitespace-only and `npm test` now passes with zero abaplint issues.
- Confirmation summaries now report `exec_single_episode_count` for
  distinct stretches with exactly one valid interval active. Touching intervals
  stay in the same stretch; overlaps and gaps split episodes. `npm test` passes.
- Confirmation summaries now report `exec_longest_single_secs`, the length of
  the longest continuous stretch with exactly one valid interval active. The
  interval sweep accumulates each stretch and resets it at overlaps or gaps.
  `npm test` passes.
- Confirmation summaries now report `exec_single_active_avg_secs`, the mean
  single-active episode duration. The calculation preserves fractional seconds
  and is zero when there are no single-active episodes. `npm test` passes.
- Confirmation summaries now report `exec_high_concurrency_secs`, the wall time
  with three or more valid positive-duration intervals active. Each instant is
  counted once, independent of overlap depth. `npm test` passes.
- Confirmation summaries now report `exec_3plus_episode_count`, the
  count of continuous three-or-more-way concurrency stretches. Touching intervals
  that preserve concurrency three do not split an episode. `npm test` passes.
- Confirmation summaries now report `exec_single_active_pct` as the share of
  the positive-interval span with exactly one interval active. It complements
  coverage and overlap percentages; the full `npm test` gate passes.
- Confirmation summaries now report `exec_single_active_seconds` for time when
  exactly one positive-duration confirmation is active. Single-active and
  overlapping time partition the covered union. The full `npm test` gate passes.
- Confirmation summaries now report `exec_overlap_wall_pct` as the share of
  the positive-interval span spent with multiple intervals active; overlap time
  counts once and the result is rounded to two decimal places. The full unit
  suite and PLAN validation pass; abaplint remains at the existing 627-finding
  baseline.
- Confirmation summaries now report `exec_interval_coverage_pct` as the
  covered union divided by the elapsed first-to-last interval span, rounded to
  two decimal places; it stays zero when no positive interval exists. The full
  unit suite and PLAN validation pass; abaplint remains at the existing
  627-finding baseline.
- Confirmation summaries now report `exec_idle_gap_avg_secs` as the average
  duration of internal gaps, preserving fractional seconds and returning zero
  when there are no gaps. The full unit suite and PLAN validation pass; abaplint
  remains at the existing 627-finding baseline.
- Confirmation summaries now report `exec_idle_gap_episode_count` for the
  number of internal gaps between merged positive-duration execution intervals.
  The full unit suite and PLAN validation pass; abaplint remains at the existing
  627-finding baseline.
- Confirmation summaries now report `exec_longest_idle_gap_secs` for the
  longest uncovered period between positive-duration execution intervals. The
  full unit suite and PLAN validation pass; abaplint remains at the existing
  627-finding baseline.
- Production confirmation summaries now count zero-duration valid intervals
  and report their percentage of all confirmations. The intervals remain part
  of valid duration totals and extrema. A focused regression covers a valid
  same-instant start/finish pair across raw and base operation, order, and
  work-center summaries. The full unit suite and PLAN validation pass; lint
  remains at the 627-issue repository baseline.
- Production confirmation summaries now report the shortest and longest valid
  execution interval in seconds. Invalid and missing intervals are excluded;
  both values are zero when a group has no valid duration. Regression coverage
  checks mixed durations, single valid intervals, and empty-valid groups. The
  full unit suite and PLAN validation pass; abaplint remains at the 627-issue
  repository baseline.
- Production confirmation summaries now partition duration outcomes into valid,
  invalid, and missing-date intervals. `invalid_exec_duration_pct` and
  missing interval count/share accompany existing valid coverage, so the three
  counts reconcile to confirmations and their percentages show data quality.
  Regressions cover complete valid, complete invalid, and missing-date cases.
- Production confirmation summaries now report `valid_exec_duration_pct`,
  the valid-interval count as a share of the summary confirmation count,
  rounded to two decimals. Tests cover zero, 50%, 66.67%, and 100% coverage
  across raw, base, work-center, operation, and order groupings.
- Production confirmation summaries now include `exec_duration_seconds_avg`,
  calculated from total valid duration seconds and valid interval count, with
  zero for groups without valid intervals. Regression coverage includes a
  fractional average across two valid intervals while excluding a negative
  interval from the denominator.
- Production confirmation operation and order summaries now expose the same
  execution coverage, earliest-start and latest-finish spans, valid duration
  totals, and invalid interval counts as the work-center summaries. Raw
  summaries group by operation/order and confirmation unit; base summaries
  merge converted source units. Regression coverage checks valid cross-midnight,
  invalid negative, and missing-date intervals across all four groupings.
- Number-based production-confirmation reads now return CRHD work-center code and plant, with exact nonblank filters and explicit blank-match flags. The paged SQL path filters these fields before the lookahead limit; the unpaged path resolves CRHD after AFVC and filters before mapping. Repository and service regressions cover assigned and unresolved centers, plants, paging, and invalid flags.
- `READ_OPERATIONS_BULK` now returns and filters CRHD work-center code and plant before confirmations exist. The paged query joins CRHD before its lookahead limit; the unpaged path resolves assignments after AFVC. Regressions cover exact and blank selectors, result fields, paging, and invalid flags.
- Batch expiry results now include full-scope dated quality and blocked totals
  alongside unrestricted and available quantities. UOM output carries both
  base and converted values, including when dated detail rows are omitted.
  Regression coverage checks four-category totals in regular and summary-only
  reads; the PLAN validator now guards the aggregation and mappings.
- Batch expiry results now also expose full through-date aggregates for
  expired and upcoming stock, separately from after-window stock. The four
  category quantities, availability ratio, and signed deduction stay stable
  across paging and are available in base and requested UOM.
- Production-order item reads now return open and over-receipt quantities in
  order units plus received and open progress percentages against the AFPO
  order quantity and a not-started, partial, complete, or over-received status.
  They remain available if base-unit conversion fails; receipt progress can
  exceed 100 percent. Regression coverage checks partial, complete, over-, and
  invalid quantity cases, and the PLAN validator requires those checks and
  mappings. Bulk summaries count returned items in each receipt-progress state,
  including retained detail rows in finish-window results.
- Removed a duplicate `PRIVATE SECTION` from the stock-service class definition.
  A source-level check confirms visibility sections are unique and in order in
  all 68 class sources. The local Node bridge prevented rerunning the plan
  validator and transpiler after this correction.

- Production-order finish-window regression coverage now models a selected order
  whose later detail row no longer matches the requested material, alongside a
  still-matching order. It verifies the changed item is retained for
  reconciliation, only the drifted order is flagged, and
  `finish_filter_lost_count` is accurate. The PLAN validator now requires these
  assertions.
- Batch expiry resolved-date bounds now have direct regressions for inclusive
  endpoints, lower-only and upper-only ranges, undated-row exclusion, page
  totals, UOM forwarding, and reversed-range rejection before repository reads.
  The PLAN validator now requires this coverage.
- Batch expiry valuation selection now has regressions for implicit nonblank,
  explicit blank, summary totals, cursor continuation, UOM echo, and invalid
  selector rejection before repository reads. The PLAN validator also checks
  that valuation scope precedes dated/undated summaries and paging.
- Cumulative upcoming 7-, 30-, and 90-day horizons now have direct count and
  four-category quantity assertions in base and converted UOM results. The
  PLAN validator requires all horizon/category pairs.
- After-window exposure now asserts the earliest row, both calendar-day
  distances, and all four base and converted UOM quantities.
- First-expired and next-upcoming expiry date distances are now asserted in
  base and UOM results.

- Batch expiry reports can suppress dated detail rows with `omit_dated_batch_rows` while
  preserving full-scope totals and matrices; page summaries become zero and undated paging stays
  independent. Dated and undated summary-only paths derive first/next expiry cohorts, the
  earliest undated identity, and full-scope summaries during the stock scan without materializing
  detail rows. Uncovered,
  allocation, and reservation-allocation omission paths release their detail buffers after
  full-scope summaries are captured. Dated status/source-status
  summaries also carry row-share percentages;
  full overdue-age, upcoming, and after-window source matrices also report percentages within
  their status totals. Dated page shares use returned rows; the full source/status matrix uses
  all matching dated rows, including after-window stock. Page-wide category totals and
  page-local expiry-date spans remain available.
  Undated detail rows and the first-undated summary retain raw expiry-source provenance;
  page-local and full-scope summaries split positive-stock rows into fixed P/G/O buckets with
  row-share percentages. Full buckets stay stable across cursor pages
  and include UOM conversions.
  Regression coverage includes first and continuation pages, empty and after-window pages,
  dated and undated summary-only identities, cohort totals, blank and unknown sources, and UOM
  results. `npm test` remains
  blocked by the workspace WSL 1 Node shim, so PLAN validation, abaplint, transpilation, and ABAP
  Unit are unverified. Native `node.exe --version` also fails with a WSL interop
  `UtilBindVsockAnyPort` error.
- Batch expiry results expose the timestamp captured after each grouped stock read. Requests
  sharing the same effective reservation exclusions share that timestamp, and UOM results echo it
  unchanged. Regression coverage now asserts timestamp presence and shared-read equality; the
  PLAN validator guards the base assignment, UOM forwarding, and tests.

- Batch expiry exposure now accepts optional inclusive signed `expiry_days_from` and `expiry_days_to` bounds against `expiration_date - as_of_date`. Each bound works alone, zero represents the as-of date, negative values select expired dates, and positive values select future dates; active bounds omit undated rows and reversed ranges are rejected. The filter composes before exposure counts, totals, and paging, while UOM requests forward and echo both bounds. Regressions cover combined and one-sided ranges, exact zero and after-window days, paging, source composition, UOM, and invalid or inactive bounds. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Allocation trace filters now accept optional signed `alloc_expiry_days_from` and `alloc_expiry_days_to` bounds against `days_to_expiration`; either bound may be used alone, zero is valid, expired values are negative, and undated rows are omitted when active. Both filters compose before counts and paging, and UOM forwards and echoes them. Regression coverage checks negative, zero, positive, one-sided, combined, paged, source-composed, UOM, inverted, and inactive cases. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Allocation trace details now expose signed `days_to_expiration` from `as_of_date`; expired rows are negative, same-day rows are zero, future expiries are positive, and undated rows remain initial. UOM details echo the same day count. Regression coverage includes expired, as-of, after-window, and undated rows in base and UOM output. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Allocation trace pages now support inclusive lower and upper quantity bounds in base units. Bounds are independently optional and compose before filtered totals and pagination; zero is valid, negative and inverted ranges are rejected, and UOM requests/results forward and echo the base-unit bounds. Regression coverage includes one-sided and combined ranges, paging, source composition, UOM, and invalid values. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

## 2026-10-19

- Allocation trace pages now select expired-age bands `1`–`4` for 1–7, 8–30, 31–90, and over 90 days since expiry. The selector omits dates on or after `as_of_date`, composes before filtered totals and paging, and is forwarded and echoed by UOM. Regressions cover band boundaries, source composition, paging, UOM forwarding, and invalid selectors. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Allocation trace pages now select after-window expiry bands `1`–`4` for 1–7, 8–30, 31–90, and over 90 days beyond `through_date`. The selector omits dates on or before the window and undated rows, composes with expiry status, dates, and other trace scopes before totals and paging, and is forwarded and echoed by UOM. Regressions cover all band boundaries, window-edge exclusions, source composition, paging, UOM, and invalid selectors. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Allocation trace pages now select upcoming expiry lead-time bands `1`–`4` for 0–7, 8–30, 31–90, and over 90 days from `as_of_date`, bounded by the inclusive `through_date`. The filter composes before filtered totals and paging, and UOM results echo it. Regression coverage checks each band, day 0 and the through-date edge, expired, after-window, and undated exclusion, source composition, pagination, UOM forwarding, and invalid selectors. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.


- Batch expiry source filtering now accepts `O` for the catch-all source category used by the expiry matrices, matching source values other than `P` and `G`, including blank. An active blank selector still matches only blank sources. Base and UOM regressions cover unknown and blank sources and reject unsupported codes before reads.

- Batch expiry exposure now selects after-window lead-time bands `1`–`4` for 1–7, 8–30, 31–90, and over 90 days beyond `through_date`. The filter composes with status and other stock scopes, omits undated rows, and is echoed through UOM results. Regressions cover every band edge, source/status composition, UOM output, and invalid active or disabled values before reads.

- Batch expiry exposure can now select upcoming lead-time bands `1`–`4` for 0–7, 8–30, 31–90, and over 90 days from the as-of date, within the inclusive request window. The selector composes with expiry status and the other stock scopes, excludes undated rows, and is echoed through UOM results. Regression coverage checks all band endpoints, source/status composition, UOM output, and rejection before reads.

- Batch expiry exposure now filters dated rows by status (`E`, `U`, `A`) and expired age band (1–7, 8–30, 31–90, over 90 days). These selectors compose with location, batch, valuation, source, and date bounds; active status or age filtering omits undated rows. Active `A` selection returns paged after-window detail rows. Base and UOM requests echo both selectors; regressions cover boundaries, source intersection, and rejection before reads.

- Source/status, source-age, upcoming, and after-window expiry rows now report `expiration_date_span_days`, the elapsed calendar days from the first to last expiration date. Empty and single-date cells report zero; UOM rows echo the value. Regressions cover six-day spans in all four matrices and an empty status cell.

- Expiry source/status summaries now include the first and last dates in each
  nonempty source/status cell; empty cells keep both dates initial, and UOM
  results echo the spans. Regression expectations cover all nine cells in
  base and UOM output.

- Reservation summary pages now support inclusive percentage, base-unit
  quantity, and positive allocation-sequence ranges, plus filtered
  reconciliation totals for allocated, matched, fallback, open, and
  uncovered quantities before cursor/page selection. Uncovered detail
  filters include shortage-quantity and open-demand-quantity ranges; the
  shortage, open-demand, and allocated totals are computed across
  matching rows before cursor/page; open demand reconciles as allocated plus
  shortage. Filtered allocation totals also split into matched and
  fallback quantities, counts split partial from unallocated rows, and
  weighted coverage, shortage, matched, and fallback percentages
  summarize the filtered demand. UOM results echo counts and percentages
  and report converted quantities.
  Reservation summary pages now expose matching weighted coverage and
  shortage percentages alongside their filtered reconciliation totals,
  with matched/fallback shares that sum to coverage.
  Regressions cover inclusive endpoints, paging, UOM results, invalid
  ranges, and reconciliation. PLAN validation passed, abaplint reported
  0 issues across 252 files, transpilation passed, and the full ABAP Unit
  suite exited 0.

- Allocation trace summaries now report the largest positive gap in both directions: demand after expiry and expiry after required date. Both summaries retain the first stable detail row on ties, stay full-scope across detail filters, and expose converted UOM quantities. Filtered trace scopes also return a fixed 20-cell gap-band/pass matrix with UOM conversions. A full-scope 60-cell expiry-source/gap-band/pass matrix preserves zero combinations and converts quantities in UOM results. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite passed.

- Filtered allocation trace totals now also include a fixed six-cell expiry-source/pass matrix, preserving empty source/pass combinations. Its counts and quantities reconcile to the pre-page filtered totals, with UOM conversions. PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full ABAP Unit suite passed.
- Allocation trace requests can filter directly by a named signed expiry-gap
  band (`P1`–`P4`, `Z`, `N1`–`N4`, or `U`), alongside the arbitrary inclusive
  signed range selector. Invalid active and noninitial inactive codes are
  rejected; the selector is echoed through UOM results. Results now also
  report the base-unit quantity matching allocation-detail filters before
  cursor/page slicing, with a converted UOM total. A fixed two-row matched /
  fallback breakdown reconciles filtered counts and quantities and keeps zero
  passes present. Regressions cover band selection, zero-gap UOM, rejected
  inputs, and full totals across pages. The full-scope `max_expiry_due_gap`
  summary identifies the allocation with the largest positive expiry-to-demand
  gap; UOM output converts its quantity, and all fields stay initial when no
  allocation has a positive gap. PLAN validation passed, abaplint found 0
  issues across 252 files, transpilation passed, and the full ABAP Unit suite
  passed.

- Allocation expiry details now assign a signed due-gap band from `P1`–`P4`
  when demand follows expiry, `Z` for the same day, `N1`–`N4` when expiry
  follows demand, and `U` when either date is missing. The fixed 20-row
  `expiry_due_gap_bands` summary crosses those bands with matched/fallback
  passes and preserves zero cells. Tests cover all 1/7/8/30/31/90/91-day
  boundaries in both directions, totals, and UOM conversion. PLAN validation
  passed, abaplint found 0 issues across 252 files, transpilation passed, and
  the full ABAP Unit suite passed.

- Allocation trace details now carry the resolved expiry source from the stock
  repository through matched and fallback deductions. Callers can filter plant,
  global fallback, or blank markers; fixed source/pass and 24-row source/status/
  pass matrices report full-scope counts and quantities, with UOM conversions.
  Tests cover source propagation, blank-key selection, invalid/inactive inputs,
  matrix reconciliation, and UOM output. PLAN validation passed; abaplint found
  0 issues across 252 files, transpilation passed, and the full ABAP Unit suite
  passed.
- Allocation trace results now include a fixed 42-row source/due-horizon/pass
  matrix. It separates source provenance and matched/fallback allocations by
  overdue, today, four future bands, and undated requirement; base/UOM tests
  verify boundaries, empty combinations, reconciliation, and converted units.
  PLAN validation passed, abaplint found 0 issues across 252 files,
  transpilation passed, and the full ABAP Unit suite passed.
- Allocation details now expose whether batch expiry is before, on, or after
  the reservation required date, with a signed day gap and an unknown state
  when either date is missing. Callers can filter trace details by relation;
  invalid active values and noninitial inactive selectors are rejected. Base
  and UOM assertions cover all four states and selector echo. The fixed
  eight-row relation/pass summary keeps full-scope counts and quantities across
  pages and converts totals in UOM results. A signed inclusive gap filter can
  select risk windows and exact zero gaps; reversed and inactive bounds have regressions; zero-gap filtering is covered
  in base and UOM results. PLAN validation passed, abaplint found 0 issues
  across 252 files, transpilation passed, and the full ABAP Unit suite passed.

- After-window expiry reporting now splits its positive-stock counts and
  category quantities by date source and by 1–7, 8–30, 31–90, and over-90 day
  overruns past `through_date`. The fixed 12-row base/UOM matrices retain empty
  combinations; fixtures cover all boundaries and converted totals. An inline
  date-difference declaration inferred a date type in transpilation, so the
  overrun distance now uses an explicit integer local. PLAN validation passed,
  abaplint found 0 issues across 252 files, transpilation passed, and the full
  ABAP Unit suite passed.

- Upcoming expiry reporting now provides `upcoming_src_bands`, a stable
  12-row matrix across plant, global-fallback, and other/blank date sources and
  0–7, 8–30, 31–90, and over-90 day lead-time bands. Counts and stock-category
  totals partition upcoming exposure. Base and UOM regressions cover all cells.
  PLAN validation passed, abaplint found 0 issues across 252 files, transpilation
  passed, and the full ABAP Unit suite passed.

- Expired exposure now crosses its four overdue-age bands with plant,
  global-fallback, and other/blank expiry sources in a stable 12-row
  `expiry_src_age_bands` matrix. Each row reports the count and four stock
  categories; UOM results preserve row order and converted totals. Deep base
  and UOM regressions cover every intersection, including empty rows. PLAN
  validation passed, abaplint found 0 issues across 252 files, transpilation
  passed, and the full ABAP Unit suite passed.

- Batch-expiry exposure now splits expired stock into 1–7, 8–30, 31–90, and
  91+ day age buckets. Each bucket reports positive-stock row counts and four
  reservation-net stock categories; UOM responses preserve counts and convert
  each total. Tests cover every boundary and base/requested-unit values.
- The expiry report also provides cumulative expired-stock totals for rows
  1–7, 1–30, and 1–90 days overdue. They derive from the disjoint age bands,
  preserve row counts, and expose category totals in base and requested units.

- `ZIF_BATCH_EXPIRY_READER` now exposes the stock service’s unit-aware bulk
  expiry read alongside the base-unit read, forwarding reservation exclusions.
- Planned-order reads now return `PLAF-PSTMP` as a raw packed-decimal short
  last-change timestamp. SAP documents that this value can differ from the
  apparent change time.
- Planned-order reads now return `PLAF-PUSER` and finish-window searches
  can filter by an exact nonblank user or explicitly select blank with
  `filter_planned_order_user`. The repository filters before pagination, the
  service rejects returned scope drift, and regressions cover bad flags.

- Planned-order bulk and finish-window headers now return scheduled start
  and finish dates/times from `PLAF-GSTRS`/`GSUZS` and `GLTRS`/`GLUZS`,
  distinct from basic dates. Added returned-header regression assertions and
  local DDIC field shapes.

- Planned-order reads now return `PLAF-PERTR` and can filter an inclusive
  creation-date range. Both bounds are validated before reading, and returned
  rows are checked against the range; added filtering, partial-range, and
  scope-drift regressions.

- Planned-order bulk and finish-window reads now return both the production
  plant (`PLAF-PWWRK`) and planning plant (`PLAF-PLWRK`). Finish-window callers
  can optionally filter the exact planning plant or explicitly select blank with
  `filter_planning_plant`; invalid flags and returned scope drift have regressions.

- Planned-order bulk reads now reject blank, duplicate, or unrequested rows
  returned by the repository before mapping. Missing requested numbers remain
  per-row not-found results. Added regressions for all three malformed-result
  cases.

- Planned-order bulk and finish-window reads now return `PLAF-KDEIN`. Callers
  can filter a schedule line within a selected sales order and nonblank item,
  including the initial `0000` value. The service validates this scope before
  reads and checks returned rows; added specific, initial, invalid-input, and
  scope-drift regressions.

- Planned-order finish-window searches can now select an initial sales-order
  assignment explicitly with `filter_sales_order`, while existing nonblank
  `sales_order` filters remain compatible. The repository applies the predicate
  before pagination and the service checks returned scope. Added blank-value,
  invalid-flag, and scope-drift regressions; strengthened existing nonblank
  sales-order and planning-scenario drift assertions to check the read count.

- Planned-order finish-window searches can now select the initial planning
  scenario explicitly with `filter_planning_scenario`, while existing nonblank
  scenario filters remain compatible. The repository applies the predicate
  before pagination and the service validates the flag and returned scope.
  Added blank-scenario, invalid-flag, and scope-drift regressions.

- Planned-order bulk and finish-window reads now return the account-assignment
  category from `PLAF-KNTTP`. Finish-window callers can filter the exact
  category, including blank, using `filter_account_category`; the service
  validates both the flag/value combination and returned-row scope. Added
  matching, blank-category, invalid-input, and scope-drift regressions.

- Planned-order bulk and finish-window reads now return `PLAF-KDPOS`. The
  finish-window search can filter an exact sales-order item when a sales order
  is selected, including the initial `000000` value. Invalid flag/value
  combinations fail before reading, and returned items are checked for scope
  drift. Added specific-item, initial-item, validation, and drift regressions.

- Planned-order finish-window searches can now filter fixed (`AUFFX = X`) or
  unfixed (`AUFFX` blank) orders. An enable flag distinguishes selecting blank
  from omitting the filter; invalid values fail before the read. Returned headers
  are checked against the selected state. Added fixed/unfixed, validation, and
  scope-drift regressions.

- Planned-order finish-window searches can filter by `SOBKZ` exactly, including
  blank for ordinary stock. `filter_special_stock` distinguishes a blank-value
  filter from no filter; malformed flags and a value supplied while filtering is
  disabled fail before the repository read. Returned rows are scope-checked.
  Added blank-stock, flag-validation, and scope-drift regressions.

- Production-order finish-window searches now accept an optional inclusive
  basic-start-date range. The repository filters AFKO keys before pagination,
  both bounds are validated before reads, and returned keys are checked before
  detail reads. Added range, partial-bound, and scope-drift regressions.

- Planned-order finish-window reads now accept an optional inclusive start-date
  interval. Both dates are required together and must be valid and ordered; the
  repository filters before pagination, and returned headers are checked against
  the requested range. Added range filtering, partial-input, and scope-drift
  regressions.

- Planned-order finish-window searches now optionally filter by `planning_scenario`,
  alongside the sales-order filter. Both predicates run before pagination, and
  returned headers are checked against both selected values before details are
  mapped. Added scenario matching and scope-drift regressions.

- Planned-order finish-window reads can now select one sales order while
  preserving the same material/plant/date scope and keyset pagination. The
  service rejects repository rows whose sales-order assignment no longer
  matches the selection. Added matching and scope-drift regressions.

- Production-order finish-window reads now accept an optional `order_category`
  (`10` production or `40` process); omitted, the query includes both. The
  repository applies the filter before pagination, and invalid categories fail
  before the read. Added category-scope and prevalidation regressions.
- The production-order read test repository now honors requested order and
  status keys, so malformed-result guards test the service contract without
  unrelated fixture rows leaking into reads.

- Production-order bulk, confirmation, and operation results now expose UTC
  `snapshot_timestamp` values after their repository reads. Finish-window reads
  also expose a separate `key_selection_timestamp`; the later
  `snapshot_timestamp` marks detail/status completion. Empty direct bulk input
  leaves these fields initial, while finish-window searches timestamp empty
  results too. These values expose read timing without promising atomic snapshots.
- Production-order number-based bulk reads reject unrequested repository rows
  and duplicate item/status keys before mapping; added regressions for foreign
  and repeated order-item rows.
- Finish-window production-order results now flag an `active_status_code` that
  was active during key selection but disappeared by the later status read. Each
  affected order sets `status_filter_lost`; the top-level count summarizes
  the drift while keeping the order available for reconciliation.
- Planned-order bulk and finish-window reads now expose UTC
  `snapshot_timestamp` values after their repository queries. Empty direct bulk
  input leaves the field initial; window searches include it for empty results.

- Confirmation searches can select rows with positive rework and/or scrap
  quantities using independent flags. The repository and service apply both
  predicates, reject invalid flag values, and verify matching results.

- Confirmation window searches now have a `reversed_only` mode to isolate
  reversals. It cannot be combined with `exclude_reversed`; the service rejects
  invalid or conflicting flags before repository reads and validates returned
  rows against the requested reversal mode.

- Confirmation rows now expose the AFVC internal operation counter, and
  page summaries use it to keep otherwise identical routing operations distinct.
  Window searches can filter by this counter when a production order is supplied.
  Bulk/window repository tests and service regressions cover mapping and scoping.

- Confirmation window reads can filter by order category (`10` production or
  `40` process), and confirmation rows expose the category in both windowed and
  bulk reads. The repository and service validate the category scope.

- Confirmation window searches can now filter by AFRU confirmation number
  and, optionally, its counter. The counter requires a confirmation number; the
  service validates the selection before repository reads and checks returned
  rows against both filters. OSQL and service tests cover the exact pair and the
  invalid counter-only selection.

- Confirmation summaries now expose raw yield/rework/scrap totals alongside
  totals that skip rows flagged reversed. Added an optional AFVC control-key
  filter that works with the operation filters or on its own; repository and
  service result validation enforce it. Added an optional production-order
  filter, `partial_only` for confirmations
  not marked final, plus a quantity-unit filter; conflicting final/partial flags
  are rejected. Repository and service regressions cover these paths. The PLAN
  validator, README, PLAN, and ANOMALIES document the API. Abaplint reported 0
  issues across 252 files,
  transpilation succeeded, PLAN validation passed, the full ABAP Unit suite
  passed, and the CRLF-aware diff check was clean.

## 2026-10-18

- Production-order confirmation reads now support a bounded material/plant
  posting-date window with keyset paging by date, order, confirmation, and
  counter. Production and process orders are included; reversed rows retain
  their reversal flag by default, with options to exclude them and filter by
  operation number, routing fields, control key, or final-only state. Confirmation rows now carry routing
  sequence, suboperation, description,
  and control key on both bulk and posting-window reads. Repository tests
  exercise the AFVC mapping and paged search query. Coverage includes same-date
  tuple paging, material and category scoping,
  exact-limit results, reversal visibility/filtering, and validation before
  reads. The service also rejects over-sized, out-of-range, misfiltered,
  cursor-overlapping, and unsorted repository pages. Pages are point-in-time
  reads and do not share a snapshot. Results include page-local summaries by
  order/operation/sequence/unit with confirmation state counts, raw yield/rework/scrap totals, and matching
  non-reversed quantity totals that skip rows flagged reversed; the lookahead
  row is excluded.

- Production-order reads now support a bounded finish-window search by
  material and plant. The repository filters production and process orders,
  deduplicates orders with multiple matching AFPO items, and returns one extra
  key to identify truncation. The service reuses full item/base-quantity and
  status mapping, provides date/order keyset paging, and can filter by an exact
  active SAP status while retaining the full status list. Added coverage for
  same-date paging, status filtering, retaining all order items and statuses,
  exact-limit output, and validation before reads.

- Planned-order reads now include a bounded finish-window query scoped to one
  material and plant. The repository fetches one row beyond the caller's
  1-to-500 limit, sorts deterministically by finish date and planned-order
  number, and reports truncation with a keyset continuation cursor while
  reusing base-unit conversion. Added coverage for ordering, same-date paging,
  filtering, conversion, exact-limit results, truncation, and validation before
  reads. The query is a snapshot and does not lock orders for later changes.

- Planned-order creation now supports SAP BAPI TestRun mode across atomic,
  bulk, and suggestion-based paths. Simulated creates accept missing planned
  order numbers, skip commit and rollback, and preserve bulk stop-on-failure
  accounting. Added tests for atomic simulation, suggestion identity, bulk
  stop behavior, and invalid-flag rejection before API calls.

- Atomic production-order confirmation test runs now pass SAP's BAPI `TESTRUN`
  flag for each ticket. Simulations no longer commit or roll back, and a
  successful simulated result may omit confirmation keys. Added adapter and
  service regressions for forwarded flags, keyless success, and stopping on a
  simulated failure without changing prior simulated success rows.

- Added a purchase-requisition simulation regression for stop-on-failure. A
  simulated create error stops later requests, returns those rows as skipped,
  and makes no commit call. The PLAN guard now requires this case.

- Production-component remaining-quantity issue and return batches now accept
  `iv_stop_on_failure`, report one ordered row per reservation group, and mark
  every unattempted group as skipped after a failed post. Component issue
  cancellation forwards the option to generic material-document cancellation.
  Abaplint passed with 0 issues across 252 files, transpilation succeeded,
  PLAN validation passed, and the full ABAP Unit suite passed.

- Purchase-order independent bulk creation, deletion, delivery completion,
  schedule changes, and quantity changes now accept `iv_stop_on_failure`.
  Suggestion/requisition and base-unit wrappers forward it after full
  validation/conversion. Results retain an ordered row per PO with attempted
  and skipped flags plus separate outcome counts. Base-unit quantity and
  schedule regressions confirm every PO read and conversion completes before
  writes, the flag stops after the failed update, and the later row remains
  skipped. Invalid stop flags are rejected before schedule conversion reads.
  Abaplint passed with 0 issues across 252 files, transpilation succeeded,
  PLAN validation passed, and the full ABAP Unit suite passed.

- Added STO creation stop-on-failure coverage for source-plant creation, its
  ATP wrapper, and multi-pair creation. The tests verify that later suppliers
  or pairs remain in order as skipped after a failed create, and that atomic
  commit failure sets `stopped_on_failure` when requested. The PLAN guard now
  requires these cases. Abaplint passed with 0 issues across 252 files,
  transpilation succeeded, PLAN validation passed, and the full ABAP Unit suite
  passed.

- Added production-order stop-on-failure regressions for create, change,
  single-order release, operation release, and ATP-gated release. The ATP cases
  verify that skipped blocked orders still count in readiness diagnostics and
  that an earlier release failure takes precedence over a later ATP block. The
  PLAN guard requires these cases; abaplint, transpilation, PLAN validation, and
  the full ABAP Unit suite passed.

- Added planned-order stop-on-failure regressions across direct create,
  suggestion-based create, delete, change, and conversion. The suggestion case
  verifies skipped receipt rows retain their source suggestion and receipt
  indexes, and a final-row create failure still sets `stopped_on_failure` with
  no skipped rows. The PLAN guard requires the cases; abaplint, transpilation,
  PLAN validation, and the full ABAP Unit suite passed.

- Added purchase-requisition stop-on-failure regressions for delete-all read
  failures, item updates, selected-item deletion, and requisition creation.
  These verify earlier commits remain, later request rows retain their identity
  as skipped, invalid flags fail before API calls, and atomic update rollback
  marks uncalled rows skipped. The PLAN guard requires the cases; abaplint,
  transpilation, PLAN validation, and the full ABAP Unit suite passed.

- Purchase-requisition bulk item update, selected-item deletion, delete-all,
  and prepared document creation now accept `iv_stop_on_failure`. They validate
  the option and complete input before side effects, preserve later requests as
  skipped after the first failure, and report separate success/failure/skip
  counts. Independent commits before the failure remain; atomic update mode
  retains its group rollback boundary and identifies uncalled rows as skipped.
  README, PLAN, ANOMALIES, and the PLAN source guard document the behavior.
  Abaplint passed with 0 issues across 252 files; transpilation created 0,
  updated 3, and left 1187 unchanged; the CRLF-aware diff check passed. The PLAN
  validator runs but reports 26 outstanding checks in other feature guards;
  the new PR checks pass. Duplicate top-level declarations that prevented the
  validator from loading were removed. ABAP Unit was not run.

- Cost-center reservation bulk creation now accepts `iv_stop_on_failure`,
  including its date-first and FEFO date-first wrappers. It validates the full
  request first, stops at the first failed create in execution order, keeps
  later caller-order rows with `is_skipped`, and reports separate outcome
  counts. Earlier independent commits remain. README, PLAN, ANOMALIES, and the
  PLAN source guard document the behavior.

- Cost-center reservation document and item deletion batches now accept
  `iv_stop_on_failure`. They retain later rows as skipped after a failed
  deletion or commit, report separate success/failure/skip counts, and preserve
  each document's independent commit boundary. README, PLAN, ANOMALIES, and the
  PLAN source guard document the behavior. Abaplint passed with 0 issues across
  252 files; transpilation created 0, updated 6, and left 1184 unchanged. The
  CRLF-aware diff check passed. `validate:plan` could not launch because the
  Node shim reports WSL 1 as unsupported; ABAP Unit was not run.

- Cost-center reservation issue-reversal bulk methods now accept
  `iv_stop_on_failure`. The option is validated before scope reads and unit
  conversion; after a failed reservation group, later groups remain in result
  order as skipped with separate counts. Earlier independent commits remain.
  README, PLAN, ANOMALIES, and the PLAN source guard describe the behavior.
  Abaplint passed with 0 issues across 252 files; transpilation created 0,
  updated 3, and left 1187 unchanged. The CRLF-aware diff check passed.
  `validate:plan` remains unavailable under the WSL 1 Node shim; ABAP Unit was
  not run.

- Reservation-scoped sales-order issue and reversal batches now accept
  `iv_stop_on_failure`, including remaining-quantity and exact-item forms.
  They validate before reads or conversion, preserve later reservation groups
  as skipped, and report separate outcome counts. Earlier independent commits
  remain. README, PLAN, ANOMALIES, and the PLAN source guard document the
  behavior. Abaplint passed with 0 issues across 252 files; transpilation
  created 0, updated 4, and left 1186 unchanged. The CRLF-aware diff check
  passed. `validate:plan` remains unavailable under WSL 1; ABAP Unit was not
  run.

- General reservation goods-issue and reversal batches now accept
  `iv_stop_on_failure` in base-unit and UOM forms. The flag is validated before
  conversion; a failed reservation group skips later groups with separate
  outcome counts, while earlier commits remain. README, PLAN, ANOMALIES, and
  the PLAN source guard cover the behavior. Abaplint passed with 0 issues
  across 252 files; transpilation created 0, updated 5, and left 1185
  unchanged. The CRLF-aware diff check passed. `validate:plan` remains
  unavailable under WSL 1; ABAP Unit was not run.

- Cost-center reservation goods-issue batches now accept
  `iv_stop_on_failure` across base-unit, UOM, remaining-quantity, and exact-item
  entry points. The flag is checked before local reads or conversion; later
  reservation groups are skipped after a failure and prior commits remain.
  README, PLAN, ANOMALIES, and the PLAN source guard cover the behavior.
  Abaplint passed with 0 issues across 252 files; transpilation created 0,
  updated 4, and left 1186 unchanged. The CRLF-aware diff check passed.
  `validate:plan` remains unavailable under WSL 1; ABAP Unit was not run.

- Project WBS reservation document and item deletion batches now accept
  `iv_stop_on_failure`. They stop after the first failed deletion, preserve
  later rows as skipped, and report separate success, failure, and skip counts;
  earlier independent commits remain. README, PLAN, ANOMALIES, and the PLAN
  source guard document the behavior. Abaplint passed with 0 issues across 252
  files; transpilation created 0, updated 6, and left 1184 unchanged. The
  CRLF-aware diff check passed. `validate:plan` remains unavailable under WSL
  1; ABAP Unit was not run.

- Project WBS reservation rescheduling now accepts `iv_stop_on_failure`, with
  skipped result rows and separate outcome counts after a failure. The option
  is checked alongside full request/date validation before writes. Earlier
  independent commits remain. README, PLAN, ANOMALIES, and the PLAN source
  guard cover the behavior. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 6, and left 1184 unchanged. The CRLF-aware
  diff check passed. `validate:plan` remains unavailable under WSL 1; ABAP Unit
  was not run.

- Project WBS reservation quantity changes, final-issue marks/resets, and stock
  changes now accept `iv_stop_on_failure`. Each fully validates its request
  before writes, then retains later calls as skipped after the first failure.
  Result summaries count successes, failures, and skips separately; earlier
  commits remain. README, PLAN, ANOMALIES, and PLAN source guards cover these
  flows. Abaplint passed with 0 issues across 252 files; transpilation created
  0, updated 6, and left 1184 unchanged. The CRLF-aware diff check passed.
  `validate:plan` remains unavailable under WSL 1; ABAP Unit was not run.

- Reservation-backed project WBS issue and return bulk methods now expose
  `iv_stop_on_failure`, validate it before reading WBS/item scopes, and forward
  it to the per-reservation posting service. Later rows remain visible as
  skipped, separate from failures, while earlier successful documents stay
  committed. README, PLAN, ANOMALIES, and the PLAN source guard cover the
  behavior. Abaplint passed with 0 issues across 252 files; transpilation
  created 0, updated 4, and left 1186 unchanged. The CRLF-aware diff check
  passed. `validate:plan` could not launch because the WSL 1 Node shim fails;
  ABAP Unit was not run.

- Project WBS reservation creation now supports `iv_stop_on_failure` in direct
  `RESERVE_WBS_BULK`, allocation-based, FEFO, priority, dated, and location
  methods. The option is checked before previews or conversions; after a failed
  create/commit, later WBS groups remain in caller order as skipped. Atomic
  creation stops later calls when opted in and still rolls back attempted
  groups. Result summaries separate skipped and failed counts. README, PLAN,
  ANOMALIES, and PLAN source guards describe the behavior. Top-level
  `is_committed` now reflects any independent child commit and remains false
  for failed atomic groups. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 4, and left 1186 unchanged. The CRLF-aware
  diff check passed. `validate:plan` could not launch because the WSL 1 Node
  shim fails; ABAP Unit was not run.

- Sales-order reservation release and shared dated reservation creation now
  accept `iv_stop_on_failure`. Both validate it before reservation lookup or
  preview reads, preserve one result row per order, and count skipped orders
  separately after a delete, ATP, create, response, or commit failure. Earlier
  independent commits remain visible. README, PLAN, ANOMALIES, and PLAN source
  guards cover the behavior. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 10, and left 1180 unchanged. The CRLF-aware
  diff check passed. `validate:plan` could not launch because the WSL 1 Node
  shim fails; ABAP Unit was not run.

- STO deletion-indicator and delivery-completion pair updates now accept
  `iv_stop_on_failure`. STO source-plant and pair-order creation methods now
  expose the same option through their allocation wrappers. They retain
  caller-order rows, distinguish skipped work, report outcome counts, preserve
  earlier independent commits, and roll back staged atomic writes on failure.
  Goods-movement issue and receipt batches also preserve skipped state from
  the preceding creation or issue stage. README, PLAN, ANOMALIES, and PLAN
  source guards cover these flows.
  Abaplint passed with 0 issues across 252 files; transpilation created 0,
  updated 5, and left 1185 unchanged. The CRLF-aware diff check passed.
  `validate:plan` could not launch under WSL 1; ABAP Unit was not run.

- STO chain issue, receipt, and combined retry batches now accept
  `iv_stop_on_failure`. They retain completed rows, report successful, failed,
  and skipped counts, and preserve prior committed reversals when an atomic
  retry group rolls back. Combined retries preserve receipt-first execution;
  both issue-only and combined atomic retries now roll back their staged LUW
  when a retry BAPI fails. README, PLAN, ANOMALIES, and PLAN source guards
  describe the behavior. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 5, and left 1185 unchanged. The CRLF-aware
  diff check passed. `validate:plan` could not launch because the WSL 1 Node
  shim fails; ABAP Unit was not run.

- STO issue, receipt, and cancellation pair batches now accept
  `iv_stop_on_failure`. They prevalidate the full input, retain caller-order
  rows, stop after the first failed or ineligible pair when opted in, and
  report successful, failed, and skipped counts. Receipt-chain cancellation
  preserves its per-pair 101/351 state, while atomic failures still roll back
  staged reversals. README, PLAN, ANOMALIES, and PLAN source guards describe
  the behavior. Abaplint passed with 0 issues across 252 files; transpilation
  created 0, updated 6, and left 1184 unchanged. The CRLF-aware diff check
  passed. `validate:plan` could not launch because the WSL 1 Node shim fails;
  ABAP Unit was not run.

- STO issue and receipt pair batches now accept `iv_stop_on_failure`. They
  prevalidate the full pair list, stop after the first failed or ineligible
  pair when opted in, preserve caller-order rows, and report successful,
  failed, and skipped counts. STO issue, receipt, issued-PO cancellation,
  received-PO cancellation, and receipt-chain cancellation batches now share
  the same policy. Atomic failures still roll back staged movements. README,
  PLAN, ANOMALIES, and the PLAN source guards describe the behavior. Abaplint
  passed with 0 issues across 252 files; transpilation created 0, updated 6,
  and left 1184 unchanged. The CRLF-aware diff check passed. `validate:plan`
  could not launch because the WSL 1 Node shim fails; ABAP Unit was not run.

- Bulk material-document cancellation now accepts `iv_stop_on_failure` and
  reports success, failure, and skipped counts. Independent cancellations keep
  going by default; opt-in stop marks later rows as skipped. Atomic API or
  commit failures still roll back staged reversals and now distinguish
  unattempted documents from attempted rows. README, PLAN, ANOMALIES, and the
  PLAN source guard describe the contract. Abaplint passed with 0 issues across
  252 files; transpilation created 0, updated 10, and left 1180 unchanged. The
  CRLF-aware diff check passed. `validate:plan` could not launch because the
  WSL 1 Node shim fails. ABAP Unit was not run.

- Production-order component return and unplanned issue bulk methods now accept
  `iv_stop_on_failure` in base-unit and UOM forms. They prevalidate before
  writes, preserve caller-order rows, and count unattempted rows separately.
  README, PLAN, ANOMALIES, and the PLAN source guard cover the behavior. The
  same lint, transpilation, and diff checks passed; `validate:plan` could not
  launch because the WSL 1 Node shim fails.

- Production-order receipt bulk methods now accept `iv_stop_on_failure` in
  base-unit and UOM forms. They validate the complete request before writes,
  retain input-order result rows, and count later skipped receipts separately
  after a failed movement. README, PLAN, ANOMALIES, and the PLAN source guard
  describe the contract. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 6, and left 1184 unchanged. The CRLF-aware
  diff check passed. `validate:plan` could not launch because the WSL 1 Node
  shim fails; ABAP Unit was not run.

- Purchase-order receipt and return bulk methods now accept
  `iv_stop_on_failure` in base-unit and UOM forms. They prevalidate requests,
  keep caller-order result rows, and report skipped rows separately after the
  first failed movement when enabled. README, PLAN, ANOMALIES, and the PLAN
  source guard cover the behavior. Abaplint passed with 0 issues across 252
  files; transpilation created 0, updated 6, and left 1184 unchanged. The
  CRLF-aware diff check passed. `validate:plan` could not launch because the
  WSL 1 Node shim fails; ABAP Unit was not run.

- Project WBS issue and return bulk methods now accept
  `iv_stop_on_failure`, including both UOM forms. They prevalidate before
  writes, preserve input-order rows, and report skipped rows separately after
  the first failed posting. README, PLAN, ANOMALIES, and the PLAN source guard
  describe the behavior. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 6, and left 1184 unchanged. The CRLF-aware
  diff check passed. `validate:plan` could not launch because the WSL 1 Node
  shim fails; ABAP Unit was not run.

- Sales-order stock transfers into and out of sales-order stock now support
  `iv_stop_on_failure` in both base-unit and UOM bulk methods. They retain all
  caller-order rows, count skipped transfers separately, and preserve earlier
  successful commits. README, PLAN, ANOMALIES, and the PLAN source guard cover
  the behavior. Abaplint passed with 0 issues across 252 files; transpilation
  created 0, updated 6, and left 1184 unchanged. The CRLF-aware diff check
  passed. `validate:plan` could not launch because the WSL 1 Node shim fails;
  ABAP Unit was not run.

- Sales-order issue and return bulk methods now accept
  `iv_stop_on_failure` in base-unit and UOM forms, while preserving the existing
  special-stock option. All requests are validated before movement calls, UOM
  conversion completes before posting, and later rows are marked skipped after
  a failure when enabled. README, PLAN, ANOMALIES, and the PLAN source guard
  cover the behavior. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 6, and left 1184 unchanged. The CRLF-aware
  diff check passed. `validate:plan` could not launch because the WSL 1 Node
  shim fails; ABAP Unit was not run.

- Cost-center issue and return bulk methods now accept `iv_stop_on_failure` in
  base-unit and UOM forms. They prevalidate full requests, preserve caller-order
  rows, and mark later unattempted movements as skipped after the first failure.
  The UOM methods validate the flag and convert every request before posting.
  README, PLAN, ANOMALIES, and the PLAN source guard describe the contract.
  Abaplint passed with 0 issues across 252 files; transpilation created 0,
  updated 6, and left 1184 unchanged. The CRLF-aware diff check passed.
  `validate:plan` could not launch because the WSL 1 Node shim fails; ABAP Unit
  was not run.

- ATP-gated production-order bulk release now accepts `iv_stop_on_failure`.
  Readiness for the full request is still validated before writes. By default,
  ATP-ready orders continue past blocked rows; with the option enabled, the
  first ATP block or failed release/commit stops later work. A release failure
  earlier in request order makes a later blocked order skipped, while
  `atp_blocked_count` retains readiness diagnostics. README, PLAN, ANOMALIES,
  and the PLAN source guard cover the accounting. Abaplint passed with 0 issues
  across 252 files; transpilation created 0, updated 6, and left 1184 unchanged.
  The CRLF-aware diff check passed. `validate:plan` could not launch because the
  WSL 1 Node shim fails; ABAP Unit was not run.

- Production-order confirmation cancel and create bulk methods now support
  `iv_stop_on_failure`, preserve skipped rows, and keep earlier independent
  commits. Confirmation creation now asks the adapter to defer commit, validates
  the returned order/operation/sequence, then commits through the service; a
  mismatched result rolls back before persistence. README, PLAN, ANOMALIES, and
  the PLAN source guard cover the behavior. Abaplint passed with 0 issues across
  252 files; transpilation created 0, updated 6, and left 1184 unchanged. The
  CRLF-aware diff check passed. `validate:plan` could not launch because the
  WSL 1 Node shim fails; ABAP Unit was not run.

- Production-order technical completion, deletion flags, close, and deletion
  indicators now accept `iv_stop_on_failure` alongside create, change, and
  release operations. All order numbers are validated first; the bulk methods
  preserve every input row, count skipped orders separately, and retain earlier
  independent commits. README, PLAN, ANOMALIES, and the PLAN source guard cover
  the contract. Abaplint passed with 0 issues across 252 files; transpilation
  created 0, updated 6, and left 1184 unchanged. The CRLF-aware diff check
  passed. `validate:plan` still cannot launch through the WSL 1 Node shim;
  ABAP Unit was not run.

- Planned-order bulk create, suggestion create, delete, change, and conversion
  now accept `iv_stop_on_failure` (default false). They prevalidate the full
  request, preserve all caller-order result rows, stop after the first failed
  BAPI result or commit when opted in, and report skipped rows separately from
  failures. Earlier independent commits remain committed. Invalid option values
  fail before API calls. README, PLAN, ANOMALIES, and the PLAN source guard
  describe the behavior. Abaplint passed with 0 issues across 252 files;
  transpilation created 0, updated 6, and left 1184 unchanged. The CRLF-aware
  diff check passed. `validate:plan` could not launch because the WSL 1 Node
  shim fails; ABAP Unit was not run.

- Production-order `RELEASE_ORDERS_BULK` and `RELEASE_OPERATIONS_BULK` now
  accept the same validated stop-on-failure flag. Both retain all result rows
  in request order, count unattempted rows separately, and preserve earlier
  commits. README, PLAN, ANOMALIES, and the PLAN source guard describe the
  behavior. Abaplint passed with 0 issues across 252 files; transpilation
  created 0, updated 3, and left 1187 unchanged. The CRLF-aware diff check
  passed. `validate:plan` could not launch because the WSL 1 Node shim fails;
  ABAP Unit was not run.

- Production-order `CREATE_ORDERS_BULK` and `CHANGE_ORDERS_BULK` now accept the
  same optional stop-on-failure behavior. They prebuild caller-order result
  rows after full validation, preserve earlier commits, and mark later requests
  skipped after the first failed API result or commit. Duplicate returned
  create numbers remain request failures. README, PLAN, ANOMALIES, and the PLAN
  source guard cover the contract. Abaplint passed with 0 issues across 252
  files; transpilation created 0, updated 6, and left 1184 unchanged. The
  CRLF-aware diff check passed. `validate:plan` could not launch because the
  WSL 1 Node shim fails; ABAP Unit was not run.

- Caller-supplied expiry snapshots now follow the same inclusive window rule as
  stock-backed reads. The shared posting-date validator receives `through_date`
  at every direct and rechecked call site; full recheck validation also rejects
  upcoming rows beyond the window. README, PLAN, ANOMALIES, and the PLAN source
  guard cover direct preview and all three posting categories. Abaplint passed
  with 0 issues across 252 files; transpilation created 0, updated 4, and left
  1186 unchanged. Twenty-five focused source/documentation assertions and the
  CRLF-aware diff check passed. `validate:plan` still cannot launch because the
  WSL 1 Node shim fails; ABAP Unit was not run.

- The expiry-window check now applies to caller-supplied snapshots as well as
  stock-backed reads. Direct FEFO preview and unrestricted/QI/blocked posting
  reject upcoming rows after `through_date`; selected recheck rows and complete
  recheck snapshots enforce the same inclusive bound. The PLAN source guard and
  README/PLAN/ANOMALIES describe the rule. Abaplint passed with 0 issues across
  252 files; transpilation created 0, updated 4, and left 1186 unchanged.
  Sixteen focused source/documentation checks and the CRLF-aware diff check
  passed. `validate:plan` remains unavailable through the WSL 1 Node shim;
  ABAP Unit was not run.

- Stock-backed expiry exposure validation now rejects upcoming rows whose
  expiration is after the request's inclusive `through_date`; those quantities
  belong in the report's after-window summary and cannot enter FEFO capacity.
  README, PLAN, ANOMALIES, and the source guard cover this boundary. Abaplint
  passed with 0 issues across 252 files; transpilation created 0, updated 4,
  and left 1186 unchanged. Six focused source/documentation assertions and the
  CRLF-aware diff check passed. PLAN validation still cannot launch because
  WSL 1 blocks the Node shim; ABAP Unit was not run.

- Stock-backed expiry exposures now pass one shared pre-pooling validator in
  preview and posting paths. It checks complete request/date context, valid
  expiry dates and status/as-of consistency, duplicate batch keys, and
  available-unrestricted balances before shared-capacity summaries are built.
  README, PLAN, ANOMALIES, and the PLAN source guard document the contract.
  Abaplint passed with 0 issues across 252 files; transpilation created 0,
  updated 5, and left 1185 unchanged. The CRLF-aware diff check passed. PLAN
  validation still cannot launch because the WSL 1 Node shim cannot determine
  its install directory; ABAP Unit was not run.

- Live document-key checks cover goods-movement create/cancel, purchase
  requisition, sales-order, purchase-order, stock-transfer-order, cost-center
  reservation, and sales-order reservation APIs. Production-confirmation creates
  now require the returned number and counter before commit; BAPI errors or
  missing keys roll back. Successful create simulations may omit generated
  numbers. Five existing goods-movement helper ABAP Unit cases compiled but were
  not run. Abaplint passed with 0 issues across 252 files; transpilation created
  0, updated 4, and left 1186 unchanged. Focused source checks and the diff check
  passed. PLAN validation still cannot launch because the WSL Node shim cannot
  determine its install directory.

- PLAN coverage scan: it has no explicit TODO/FIXME or unchecked checklist
  items. A static cross-reference found all 103 backticked identifiers in
  `src` and confirmed both configs name the open-abap-core GitHub URL. This
  checks text presence only; it does not establish behavior or SAP runtime
  integration. The full PLAN validator still cannot launch through the
  current Node shim.

- Direct, bulk, and atomic FEFO results now echo `is_rechecked` and
  `rechecked_snapshot_timestamp` as soon as a supplied snapshot passes
  validation. Bulk UOM now fully validates every recheck before execution and
  retains the metadata on skipped rows. BOX regressions verify converted base
  quantities and shortfall previews for skipped rows; atomic UOM shortfall
  metadata is covered too, and malformed skipped rechecks are rejected before
  any post. Abaplint passed with 0 issues across 251 files; the latest transpilation created 0, updated 2, and
  left 1186 unchanged. Focused source checks and the CRLF-aware diff check
  passed. PLAN validation could not launch because WSL 1 blocks the Node shim.
  ABAP Unit was not run.

- Direct bulk and atomic FEFO now validate each supplied recheck before
  allocation, including request context, reservation exclusions, timestamp
  ordering, unique complete batch keys, and expiry status/date. A duplicate row
  is rejected even when full-quantity policy would otherwise shortfall with no
  selected rows. README, PLAN, ANOMALIES, and source guards cover the behavior.
  Abaplint passed with 0 issues across 251 files; transpilation created 0,
  updated 8, and left 1180 unchanged. Focused source checks and the CRLF-aware
  diff check passed. PLAN validation could not launch because WSL 1 blocks the
  Node shim. ABAP Unit was not run.

- Shared FEFO capacity rows now report `contributing_request_count`, counting
  distinct request IDs separately from initial/recheck exposure rows, and
  `rechecked_exposure_count`, counting rows from supplied second snapshots.
  Atomic aggregation tracks each request once per capacity key; stock-backed
  previews return zero rechecked rows. Regressions assert two requests and two
  rechecks across four atomic rows, and two requests across two preview rows.
  README, PLAN, and source guards document and require the fields.
  Abaplint passed with 0 issues across 251 files; transpilation created 0,
  updated 6, and left 1182 unchanged. The CRLF-aware diff check passed. PLAN
  validation could not launch because WSL 1 blocks the Node shim. ABAP Unit
  was not run.

- Atomic FEFO results now populate sorted `shared_capacities` rows from the
  initial and optional recheck exposure snapshots. Rows include the pooled
  minimum/maximum balances, exposure and timestamp counts, selected quantities,
  and remaining capacity; values describe the preflight plan and stay available
  on shortfall or rollback. The priority regression checks shared capacity,
  caller-order tie metadata, planned splits, and timestamp bounds across both
  snapshots. README, PLAN, and source guards cover the contract. Abaplint passed
  with 0 issues across 251 files; transpilation created 0 outputs, updated 2,
  and left 1186 unchanged. The CRLF-aware diff check passed. PLAN validation
  could not launch because WSL 1 blocks the Node shim. ABAP Unit was not run.

- FEFO bulk and atomic result rows now expose a one-based `allocation_sequence`
  in ranked processing order while remaining in caller order. Bulk rows skipped
  after stop-on-failure retain their scheduled sequence. Regressions cover
  default caller order, ranked UOM processing, skipped rows, and atomic shared
  capacity awarded by rank. PLAN, README, and source guards document and require
  the field. Abaplint passed with 0 issues across 251 files; transpilation
  created 0 outputs, updated 4, and left 1184 unchanged. The CRLF-aware diff
  check passed. PLAN validation could not launch because WSL 1 blocks the Node
  shim. ABAP Unit was not run.

- FEFO direct, bulk, and atomic posting results now echo `require_full_quantity`
  at the top level and on each per-request FEFO result. Empty, shortfall, and
  skipped outcomes retain the chosen policy. Regressions cover default and
  partial direct calls, bulk/UOM summaries, and atomic base/UOM rows; PLAN,
  README, and source guards cover the output contract. Abaplint passed with 0
  issues across 251 files; transpilation created 0 outputs, updated 6, and left
  1182 unchanged. The CRLF-aware diff check passed. PLAN validation could not
  launch because WSL 1 blocks the Node shim. ABAP Unit was not run.

- Stock-backed FEFO preview summaries now echo `require_full_quantity`, the
  all-or-nothing policy used for the request group, including empty input.
  Regressions cover the default, explicit partial allocation, and empty partial
  calls. PLAN, README, and the source guard describe the result field. Abaplint
  passed with 0 issues across 251 files; transpilation created 0 outputs,
  updated 6, and left 1182 unchanged. The CRLF-aware diff check passed. PLAN
  validation could not launch because WSL 1 blocks the Node shim. ABAP Unit was
  not run.

- FEFO `selection_details` now report the material-base-unit `category_balance`
  used to cap each split: reservation-net unrestricted, QI, or blocked stock.
  It can exceed the selected quantity when a split only uses part of a batch.
  Base and UOM regressions cover all stock categories and a partial split; PLAN,
  README, and source guards describe the field. Abaplint passed with 0 issues
  across 251 files; transpilation created 0 outputs, updated 6, and left 1182
  unchanged. The CRLF-aware diff check passed. PLAN validation could not launch
  because WSL 1 blocks the Node shim. ABAP Unit was not run.

- FEFO `selection_details` now expose `location_priority_rank` so callers can
  see how storage location affected same-expiry tie ordering. It is zero with
  no priority list, uses caller ranks for listed locations, and places
  unlisted locations after the list. Regressions cover preferred, unlisted,
  no-priority, and UOM results; PLAN, README, and source guards cover the field.
  Abaplint passed with 0 issues across 251 files; transpilation created 0
  outputs, updated 6, and left 1182 unchanged. The CRLF-aware diff check
  passed. PLAN validation could not launch because WSL 1 blocks the Node shim.
  ABAP Unit was not run.

- Direct expired-scrap preview results now echo the source exposure's
  `excluded_reservations`, unchanged and including an empty list. UOM and FEFO
  results retain the exclusions in their nested preview. Base and UOM
  regressions verify reservation/item keys, and the PLAN, README, and source
  guard cover the contract. Abaplint passed with 0 issues across 251 files;
  transpilation created 0 outputs, updated 1, and left 1187 unchanged. The
  CRLF-aware diff check passed. PLAN validation could not launch because WSL 1
  blocks the Node shim. ABAP Unit was not run.

- Direct expired-scrap preview results now echo the exposure request ID,
  material, plant, as-of date, through date, and requested posting date. UOM
  and FEFO results retain this context in the nested preview. Base and UOM
  regressions, README, PLAN, and source guards cover the fields. Abaplint passed
  with 0 issues across 251 files; transpilation created 0 outputs, updated 3,
  and left 1185 unchanged. The CRLF-aware diff check passed. PLAN validation
  could not launch because WSL 1 blocks the Node shim. ABAP Unit was not run.

- Direct FEFO posting results now expose the timestamp from a successfully
  compared second exposure as `rechecked_snapshot_timestamp`; it stays initial
  when no recheck runs. Base and UOM regressions cover returned timestamps and
  the no-recheck case. PLAN and README describe the result field. Abaplint
  passed with 0 issues across 251 files; transpilation created 0 outputs,
  updated 3, and left 1185 unchanged. The CRLF-aware diff check passed. PLAN
  validation could not launch because WSL 1 blocks the Node shim. ABAP Unit was
  not run.

- Direct expired-scrap previews now echo the source exposure's
  `snapshot_timestamp`; unit-aware and FEFO results retain it through their
  nested preview, while legacy untimestamped exposures leave it initial.
  Regression coverage checks both timestamped and untimestamped inputs. Abaplint
  passed with 0 issues across 251 files; transpilation updated 1 output and
  left 1187 unchanged. PLAN validation could not launch because WSL 1 blocks
  the Node shim. ABAP Unit was not run.

- FEFO preview `selection_details` now include `days_expired_at_posting`, the
  elapsed days from batch expiry to the requested posting date. Direct and UOM
  regressions cover the calculation and the source guard requires both paths.
  Abaplint passed with 0 issues across 251 files; transpilation updated 3
  outputs and left 1185 unchanged. PLAN validation could not launch because
  WSL 1 blocks the Node shim. ABAP Unit was not run.

- Expired-scrap previews now return `selection_details` alongside posting
  selections, preserving each selected batch's expiration date and source
  marker through base-unit and UOM previews. All-or-nothing shortfalls clear
  both lists. The regression also corrected an upcoming-batch fixture whose
  expiration date contradicted its status. Abaplint passed with 0 issues across
  251 files; transpilation updated 6 outputs and left 1182 unchanged. PLAN
  validation could not launch because WSL 1 blocks the Node shim. ABAP Unit was
  not run.

- Duplicate reservation exclusions now have preflight regressions across the
  stock-backed preview, atomic, and bulk FEFO entry points. Request-level and
  call-wide duplicates are rejected before UOM reads, expiry reads, or
  movement calls. The PLAN source guard requires all three cases. Abaplint
  passed with 0 issues across 251 files; transpilation updated 1 output and
  left 1187 unchanged. PLAN validation could not launch because WSL 1 blocks
  the Node shim. ABAP Unit was not run.

- Stock expiry exposure now has a regression for reservation exclusion
  grouping: requests with the same call-wide plus request-specific union share
  a repository read, distinct unions use separate reads, duplicate keys are
  removed, and output remains in caller order. The repository double records
  the grouped request sets and effective keys; the PLAN source guard requires
  the grouping and ordering assertions. The stock-backed FEFO preview fixture
  also captures each reader request and verifies different per-request keys
  combine with the call-wide keys in the returned rows. Abaplint passed with
  0 issues across 251 files; transpilation updated 8 outputs and left 1180
  unchanged. Duplicate call-wide and request-level exclusion cases verify
  rejection before UOM conversion or exposure reads. PLAN validation could not launch
  because the WSL 1 Node shim failed. ABAP Unit was not run.

- Direct and stock-backed FEFO previews now reject expiry detail rows without a
  storage location or batch instead of silently omitting them from allocation
  or pooled capacity. The PLAN, README, regression coverage, and source guard
  require that check. The shared stock-backed posting validator applies the
  same rule to both the original and rechecked exposure snapshots for atomic
  and independent bulk posting. Those posting paths validate the first
  snapshot before requesting the recheck; an invalid original fails after one
  stock read, with no movement attempt.

- Stock-backed FEFO preview tests now inspect the pooled-capacity rows: keys,
  minimum and maximum exposure balances, spread, selected quantity, remaining
  capacity, limiting and maximum request IDs, row counts, and timestamp bounds.
  A second prioritized read checks caller-order tie handling for the minimum
  and maximum, and that processing sequences can differ from result order. A
  separate case verifies partial allocation is available only by explicit
  opt-in and still reconciles the pooled capacity summary. Abaplint passed with
  0 issues across 251 files; transpilation updated 4 outputs and left 1184
  unchanged. PLAN validation could not launch because the WSL 1 Node shim
  failed. ABAP Unit was not run.

- Generic base-unit and UOM, plus stock-backed bulk FEFO, now cover
  request-level UOM exceptions. Exception rows are marked unattempted, counted
  as failed, and include an error message. Generic UOM cases verify that a
  rank-1 exception either stops the rank-2 request or, by default, allows it to
  commit, with result rows in caller order. The base-unit case verifies a final
  exception sets `stopped_on_failure` with no skipped rows. Stock-backed cases
  verify continuing and stopping. PLAN, user docs, and the source guard require
  these outcomes. Abaplint passed with 0 issues across 251 files; transpilation
  updated 4 outputs and left 1184 unchanged. PLAN validation could not launch
  because the WSL 1 Node shim failed. ABAP Unit was not run.

- Stock-backed atomic and independent FEFO posting now both have a regression
  proving ranked movement order while result rows stay in caller order and
  echo rank metadata. A bulk case also covers caller-order ties and puts
  unranked requests after ranked requests. Abaplint passed with 0 issues across
  251 files; final transpilation updated 4 outputs and left 1184
  unchanged. PLAN validation could not launch because the WSL 1 Node shim
  failed. ABAP Unit was not run.

- Stock-backed atomic posting now has a regression for unknown priority IDs,
  and independent posting has one for duplicate priority rows. Both assert
  rejection before any exposure read or movement call. The PLAN already
  requires this preflight ordering. Abaplint passed with 0 issues across 251
  files; transpilation updated 4 outputs and left 1184 unchanged. PLAN
  validation could not launch because the WSL 1 Node shim failed. ABAP Unit
  was not run.

- Stock-backed bulk FEFO now has assertions for both stop-on-failure cases:
  later requests are skipped after an earlier failure, and the summary still
  marks a stop when the final request fails with no rows to skip. This also
  verifies skip counts, attempt state, and an earlier successful commit.
  Abaplint passed with 0 issues across 251 files; final transpilation updated
  2 outputs and left 1186 unchanged. PLAN validation could not launch because
  the WSL 1 Node shim failed. ABAP Unit was not run.

- Stock-backed independent FEFO posting now has regression coverage that a
  failed request leaves shared capacity available to the next request. The
  test checks the later movement receives the full quantity, and the source
  guard requires this coverage. The PLAN already documents consume-on-success
  semantics. Abaplint passed with 0 issues across 251 files; transpilation
  updated 1 output and left 1187 unchanged. PLAN validation could not launch
  because the WSL 1 Node shim failed. ABAP Unit was not run.

- Duplicate location/batch/valuation stock rows now have regression coverage
  in both the atomic and independently committed FEFO posting paths. The
  bulk case asserts malformed exposure rows fail before any goods movement;
  the existing PLAN text already documents this rejection. Added its method
  to the source guard. The ABAP lint and transpilation results for this method
  are included with the shared-capacity regression immediately above.

- Stock-backed atomic and bulk FEFO posting now reject rechecks whose
  snapshot timestamp is equal to the initial read. Added regression coverage
  for both paths and guarded the bulk PLAN timestamp contract. The transpiler
  passed (0 created, 1 updated, 1187 unchanged), and abaplint passed with 0
  issues after the final alignment adjustment. PLAN validation could not
  launch because the WSL 1 Node shim failed. Static guard checks and the
  CRLF-aware diff check passed. ABAP Unit was not run.

- Stock-backed atomic and independently committed FEFO posting now verify
  both returned snapshots echo each request's effective call-wide and
  request-specific exclusions, and reject duplicate batch/location/
  valuation rows before allocation. Regression cases cover a mismatched
  initial snapshot, a mismatched recheck, and duplicate atomic rows.
  Updated PLAN, README, ANOMALIES, and source guard. Abaplint passed with
  0 issues across 251 files; transpilation updated 4 outputs and left
  1184 unchanged. PLAN validation could not launch because the WSL 1 Node
  shim rejects WSL 1. ABAP Unit was not run.

- Stock-backed FEFO preview rows now echo the request's cost center,
  movement reason, and storage-location priority, including a regression
  request with no selected stock. Added output assertions and extended the
  PLAN, README, ANOMALIES, and source guard. Abaplint passed with 0 issues
  across 251 files; transpilation updated 2 outputs and left 1186 unchanged.
  PLAN validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Stock-backed FEFO previews now reject duplicate location/batch/valuation
  rows from one exposure before pooling, avoiding duplicate capacity from
  malformed reader output. Request result rows also echo material, plant,
  expiry window, and stock category. Updated README, PLAN, ANOMALIES,
  regression assertions, and source guard. Abaplint passed with 0 issues
  across 251 files; transpilation updated 8 outputs and left 1180
  unchanged. PLAN validation could not launch because the WSL 1 Node shim
  rejects WSL 1. ABAP Unit was not run.

- Stock-backed FEFO preview rows now echo request material, plant, expiry
  window, and stock category, so each result identifies its request scope
  without a lookup. Updated README, PLAN, ANOMALIES, test assertions, and
  the source guard. Abaplint passed with 0 issues across 251 files;
  transpilation updated 6 outputs and left 1182 unchanged. PLAN validation
  could not launch because the WSL 1 Node shim rejects WSL 1. ABAP Unit
  was not run.

- Stock-backed FEFO previews now verify each reader result echoes the
  union of call-wide and request-specific reservation exclusions before
  pooling capacity. Updated the reader fixture, README, PLAN, ANOMALIES, and
  source guard. Abaplint passed with 0 issues across 251 files; transpilation
  updated 6 outputs and left 1182 unchanged. PLAN validation could not launch
  because the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Stock-backed FEFO preview request rows now echo the source exposure
  `snapshot_timestamp` in UTC, so callers can associate each preview with
  its exact stock read. Updated README, PLAN, ANOMALIES, and the source guard.
  Abaplint passed with 0 issues across 251 files; transpilation updated 6
  outputs and left 1182 unchanged. PLAN validation could not launch because
  the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Shared-capacity preview rows now include earliest/latest contributing
  snapshot timestamps and `untimestamped_exposure_count`, exposing read-time
  spread across exclusion groups while preserving rows from injected readers
  without timestamps. Updated README, PLAN, ANOMALIES, and the source guard.
  Abaplint passed with 0 issues across 251 files; transpilation updated 3
  outputs and left 1185 unchanged. PLAN validation could not launch because
  the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Shared-capacity preview rows now include `positive_exposure_count`,
  counting contributing exposure rows whose selected stock category has a
  positive balance. Updated README, PLAN, ANOMALIES, and the source guard.
  Abaplint passed with 0 issues across 251 files; transpilation updated 6
  outputs and left 1182 unchanged. PLAN validation could not launch because
  the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Shared-capacity preview rows now include `maximum_exposure_count`, counting
  exposure rows tied at the maximum; a newly higher report resets the count,
  and equal reports increment it. Updated README, PLAN, ANOMALIES, and the
  source guard. Abaplint passed with 0 issues across 251 files; transpilation
  updated 6 outputs and left 1182 unchanged. PLAN validation could not launch
  because the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Shared-capacity preview rows now include `minimum_exposure_count`, which
  counts exposure rows tied at the minimum balance; a newly lower report
  resets the count and equal reports increment it. Updated README, PLAN,
  ANOMALIES, and the source guard. Abaplint passed with 0 issues across 251
  files; transpilation updated 6 outputs and left 1182 unchanged. PLAN
  validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Shared-capacity preview rows now include `maximum_reported_request_id`,
  identifying the request that supplied the largest observed balance; ties
  keep the first request in caller order. Updated README, PLAN, ANOMALIES, and
  the source guard. Abaplint passed with 0 issues across 251 files;
  transpilation updated 3 outputs and left 1185 unchanged. PLAN validation
  could not launch because the WSL 1 Node shim rejects WSL 1. ABAP Unit was
  not run.

- Shared-capacity preview rows now include `maximum_reported_quantity` and
  `capacity_spread_quantity`, exposing the maximum observed balance and its
  spread from the minimum allocation cap. Updated README, PLAN, ANOMALIES,
  and the source guard. Abaplint passed with 0 issues across 251 files;
  transpilation updated 6 outputs and left 1182 unchanged. PLAN validation
  could not launch because the WSL 1 Node shim rejects WSL 1. ABAP Unit was
  not run.

- Shared-capacity preview rows now include `allocation_row_count`, counting
  positive request-preview selection rows assigned to each pooled stock key.
  Updated README, PLAN, ANOMALIES, and the source guard. Abaplint passed with 0
  issues across 251 files; transpilation updated 6 outputs and left 1182
  unchanged. PLAN validation could not launch because the WSL 1 Node shim
  rejects WSL 1. ABAP Unit was not run.

- Shared-capacity preview rows now report `reported_exposure_count` and
  `limiting_request_id` to show how many exposure balances contributed and
  which request supplied the minimum. Ties preserve caller order. Updated
  README, PLAN, ANOMALIES, and the source guard. Abaplint passed with 0 issues
  across 251 files; transpilation updated 6 outputs and left 1182 unchanged.
  PLAN validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Stock-backed FEFO previews now return sorted `shared_capacities` rows with
  material base units, the minimum reported balance, total selected quantity,
  and remaining shared capacity per material/plant/location/batch/valuation/
  category key. Updated README, PLAN, ANOMALIES, and the source guard. Abaplint
  passed with 0 issues across 251 files; transpilation updated 6 outputs and
  left 1182 unchanged. PLAN validation could not launch because the WSL 1 Node
  shim rejects WSL 1. ABAP Unit was not run.

- Stock-backed FEFO preview rows now include a one-based
  `allocation_sequence` for the rank/caller-order sequence used to consume
  shared batch capacity, while result rows remain in caller order. Updated
  README, PLAN, ANOMALIES, and the source guard. Abaplint passed with 0 issues
  across 251 files; transpilation updated 6 outputs and left 1182 unchanged.
  PLAN validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch allocation results now include a one-based `allocation_sequence` on
  uncovered reservations and every trace row. The calculator resolves equal
  reservation selectors by input order and traverses stock rows stably by
  location, batch, valuation type, and expiry date; callers can sort by the
  sequence to reconstruct shared-stock consumption. UOM rows echo it. Updated
  README, PLAN, ANOMALIES, and the source guard. Abaplint passed with 0 issues
  across 251 files; transpilation updated 30 outputs and left 1158 unchanged.
  PLAN validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch reservation summaries now classify eligible open rows as fully
  allocated, partially allocated, or unallocated. The three counts reconcile
  to the eligible open row count, exclude effective exclusions, and flow
  through direct, expiry, and UOM expiry results. Updated README, PLAN,
  ANOMALIES, and the source guard. Abaplint passed with 0 issues across 251
  files; transpilation updated 28 outputs and left 1160 unchanged. PLAN
  validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Allocation trace rows now include the reservation's requested location,
  batch, and valuation type beside the actual stock-row selectors. UOM trace
  rows echo the selectors, making fallback differences visible for fully
  covered reservations as well. Updated README, PLAN, ANOMALIES, and the source
  guard. Abaplint passed with 0 issues across 251 files; transpilation updated
  28 outputs and left 1160 unchanged. PLAN validation could not launch because
  the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch-stock summaries now count matched-pass and fallback-pass allocation
  trace rows. Each count represents a positive deduction against one stock row,
  not a distinct reservation, and UOM expiry results echo the counts. Updated
  README, PLAN, ANOMALIES, and the source guard. Abaplint passed with 0 issues
  across 251 files; transpilation updated 28 outputs and left 1160 unchanged.
  CRLF-aware diff checks passed. PLAN validation could not launch because the
  WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch-stock summaries now report total matched-pass and fallback-pass
  allocation quantities. Their sum plus the uncovered quantity reconciles to
  eligible open reservation demand; excluded demand stays separate. Base and
  requested-unit expiry results carry both totals, so callers can compare the
  passes without summing allocation trace entries. Updated README, PLAN,
  ANOMALIES, and the source guard. Abaplint passed with 0 issues across 251
  files; transpilation updated 28 outputs and left 1160 unchanged. CRLF-aware
  diff checks passed. PLAN validation could not launch because the WSL 1 Node
  shim rejects WSL 1. ABAP Unit was not run.

- Batch-stock results now return `allocation_details` for each positive
  reservation deduction, with the reservation key, required date, actual
  location/batch/valuation/expiry row, quantity, and matched (`M`) or fallback
  (`F`) pass. The calculator sorts traces stably by reservation/item, preserving
  allocation-pass and stock traversal order. Repository, expiry, and UOM results
  carry the trace; UOM entries include base and requested quantities. Updated
  README, PLAN, ANOMALIES, and the source guard. Abaplint passed with 0 issues
  across 251 files; transpilation updated 28 outputs and left 1160 unchanged.
  PLAN validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch expiry uncovered-reservation details now carry RESB requirement date,
  storage location, batch, valuation type, original required/withdrawn
  quantities, open quantity, locally allocated quantity, and selector-matched/
  fallback quantities through base and UOM results. Each row reconciles source
  required/withdrawn quantities to matched, fallback, and uncovered amounts,
  and reports days until its requirement date. Results report the residual row
  count and earliest known requirement date with its reservation key and
  calendar-day distance from the as-of date. UOM results convert required,
  withdrawn, open, allocated, matched, fallback, and uncovered quantities and
  echo the reservation context, per-row day counts, aggregate count, and date
  summary. Residuals are grouped into overdue, due-today, future-dated, and
  undated quantities and row counts; base totals reconcile to the uncovered
  amount and detail count. UOM results convert each bucket and echo counts.
  Undated requirements are skipped in the earliest-date summary and kept apart
  from due-today rows; ties use reservation/item order. Updated README, PLAN,
  ANOMALIES, and the PLAN source guard. Abaplint passed with 0 issues across
  251 files; transpilation updated 13 outputs and left 1175 unchanged.
  CRLF-aware diff checks passed. PLAN validation could not launch because the
  WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch expiry results now return each uncovered reservation/item key with its
  positive residual quantity. The row quantities reconcile to the aggregate
  uncovered total; UOM rows include base and requested-unit amounts. Updated
  README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed with 0
  issues across 251 files; transpilation updated 28 outputs and left 1160
  unchanged. Focused per-reservation/base/UOM checks and CRLF-aware diff checks
  passed. PLAN validation could not launch because the WSL 1 Node shim rejects
  WSL 1. ABAP Unit was not run.

- Batch expiry results now return `uncovered_open_resv_keys` for reservations
  left with positive demand after local allocation. The keys are sorted by
  reservation/item and echoed unchanged by UOM results. Updated README, PLAN,
  ANOMALIES, and the PLAN source guard. Abaplint passed with 0 issues across
  251 files; transpilation updated 4 outputs and left 1184 unchanged. Focused
  key-order/base/UOM flow checks and CRLF-aware diff checks passed. PLAN
  validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch expiry results now include `uncovered_open_resv_quantity`: positive
  eligible reservation demand left after the calculator's matching and
  fallback passes. The calculator exposes this summary without changing its
  existing stock-table API; UOM results convert the total to the requested
  unit. Updated README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint
  passed with 0 issues across 251 files; transpilation updated 3 outputs and
  left 1185 unchanged. Focused summary/UOM flow and CRLF-aware diff checks
  passed. PLAN validation could not launch because the WSL 1 Node shim rejects
  WSL 1. ABAP Unit was not run.

- Direct batch-stock status bulk results now carry a shared UTC
  `snapshot_timestamp`; the UOM wrapper echoes it, and expiry exposure reuses
  the grouped status timestamp. Updated README, PLAN, ANOMALIES, and the PLAN
  source guard. Abaplint passed with 0 issues across 251 files; transpilation
  updated 19 outputs and left 1169 unchanged. Focused timestamp capture,
  grouped-read consistency, UOM echo, and CRLF-aware diff checks passed. PLAN
  validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch expiry exposure now reports raw eligible and excluded open-reservation
  quantities alongside row counts. The UOM result includes each total in base
  and requested units; the totals describe reservation demand, not stock
  deductions. Updated README, PLAN, ANOMALIES, and the PLAN source guard.
  Abaplint passed with 0 issues across 251 files; transpilation updated 3
  outputs and left 1185 unchanged. Focused aggregation/UOM/source-flow checks
  passed. PLAN validation could not launch because the WSL 1 Node shim rejects
  WSL 1. ABAP Unit was not run.

- Batch expiry exposure now returns `unmatched_excl_reservations`, the
  effective reservation/item keys without positive open RESB matches, sorted
  by reservation and item. The UOM result echoes the list unchanged. Updated
  README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed with 0
  issues across 251 files; transpilation updated 3 outputs and left 1185
  unchanged. Focused collection/order/count and base/UOM flow checks plus
  CRLF-aware diff checks passed. PLAN validation could not launch because the
  WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch expiry exposure now reports `unmatched_open_resv_excl_count` for
  effective exclusion keys with no matching positive open RESB row. The UOM
  result echoes the value unchanged. Updated README, PLAN, ANOMALIES, and the
  PLAN source guard. Abaplint passed with 0 issues across 251 files;
  transpilation updated 26 outputs and left 1162 unchanged. Focused count-flow,
  UOM, and documentation checks plus CRLF-aware diff checks passed. PLAN
  validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch expiry exposure now reports `excluded_open_resv_row_count` for RESB
  rows with a positive remainder that match effective reservation exclusions.
  The UOM result echoes this count alongside eligible reservation rows.
  Updated README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed
  with 0 issues across 251 files; transpilation updated 3 outputs and left
  1185 unchanged. Focused count-flow/UOM/guard checks and CRLF-aware diff
  checks passed. PLAN validation could not launch because the WSL 1 Node shim
  rejects WSL 1. ABAP Unit was not run.

- Batch expiry exposure now reports `open_reservation_row_count` for eligible
  RESB rows with positive remaining quantities after effective exclusions.
  The count follows each request's local batch-status read and is echoed by
  UOM results. Updated README, PLAN, ANOMALIES, and the PLAN source guard.
  Abaplint passed with 0 issues across 251 files; transpilation updated 3
  outputs and left 1185 unchanged. Focused request-flow/UOM/guard checks and
  CRLF-aware diff checks passed. PLAN validation could not launch because the
  WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch expiry exposure now counts positive-stock dated rows sourced from
  plant-level MCHA and global MCH1 separately, including after-window rows.
  UOM results echo both counts. Updated README, PLAN, ANOMALIES, and the PLAN
  source guard. Abaplint passed with 0 issues across 251 files; transpilation
  updated 13 outputs and left 1175 unchanged. Focused boundary/UOM/guard checks
  and CRLF-aware diff checks passed. PLAN validation could not launch because
  the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch expiry rows now expose `expiration_date_source`: `P` for a resolved
  plant-level MCHA date, `G` for a resolved global MCH1 fallback, and blank
  when no date resolves. Dated details and expired, upcoming, and after-window
  summaries carry the marker; UOM results echo it. Updated README, PLAN,
  ANOMALIES, and the PLAN source guard. Abaplint passed with 0 issues across
  251 files; transpilation updated 4 outputs and left 1184 unchanged. Focused
  precedence/UOM/guard checks and CRLF-aware diff checks passed. PLAN validation
  could not launch because the WSL 1 Node shim rejects WSL 1. ABAP Unit was
  not run.

- Batch expiry exposure now returns every positive-stock row with no resolved
  expiry date in the sorted `undated_batches` list. UOM rows include base and
  requested units plus converted category balances. Updated README, PLAN,
  ANOMALIES, and the PLAN source guard. Abaplint passed with 0 issues across
  251 files; transpilation updated 3 outputs and left 1185 unchanged. Focused
  list/UOM/guard checks and CRLF-aware diff checks passed. PLAN validation
  could not launch because the WSL 1 Node shim rejects WSL 1. ABAP Unit was
  not run.

- Batch expiry exposure now identifies the first positive-stock undated row by
  batch, location, and valuation type, with its four category balances. UOM
  results include the same row's base and requested-unit values. Updated
  README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed with 0
  issues across 251 files; transpilation updated 13 outputs and left 1175
  unchanged. Focused selection/UOM/guard checks and CRLF-aware diff checks
  passed. PLAN validation could not launch because the WSL 1 Node shim rejects
  WSL 1. ABAP Unit was not run.

- Batch expiry exposure now identifies the first positive-stock expired row in
  expiration, batch, location, and valuation order. It reports the row identity,
  expiration date, days since expiry, and four stock-category balances; UOM
  results include base and requested-unit balances. Updated README, PLAN,
  ANOMALIES, and the PLAN source guard. Abaplint passed with 0 issues across
  251 files; transpilation updated 13 outputs and left 1175 unchanged. Focused
  row/UOM/guard checks and CRLF-aware diff checks passed. PLAN validation could
  not launch because the WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch expiry exposure now reports `days_after_window_end` for the earliest
  positive-stock row after the inclusive through date, alongside the existing
  days from as-of date. UOM results echo the day values. Updated README, PLAN,
  ANOMALIES, and the PLAN source guard. Abaplint passed with 0 issues across
  251 files; transpilation updated 13 outputs and left 1175 unchanged. Focused
  date/UOM/guard checks and CRLF-aware diff checks passed. PLAN validation
  could not launch because the WSL 1 Node shim rejects WSL 1. ABAP Unit was
  not run.

- The earliest after-window row now carries its unrestricted, available, QI,
  and blocked balances. UOM results provide each value in base and requested
  units. Updated README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint
  passed with 0 issues across 251 files; transpilation updated 3 outputs and
  left 1185 unchanged. Focused row/UOM/guard checks and CRLF-aware diff checks
  passed. PLAN validation could not launch because the WSL 1 Node shim rejects
  WSL 1. ABAP Unit was not run.

- Batch expiry exposure now identifies the earliest positive-stock row after
  the requested window by storage location, batch, and valuation type, with
  its expiration date and days from the as-of date. It follows expiry, batch,
  location, and valuation order; UOM results echo its identity and date fields.
  Updated README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed
  with 0 issues across 251 files; transpilation updated 13 outputs and left
  1175 unchanged. Focused ordering/UOM/guard checks and CRLF-aware diff checks
  passed. PLAN validation could not launch because the WSL 1 Node shim rejects
  WSL 1. ABAP Unit was not run.

- The earliest-upcoming batch summary now includes unrestricted,
  reservation-net available, QI, and blocked quantities for its identified
  row. UOM results carry each value in base and requested units. Updated
  README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed with 0
  issues across 251 files; transpilation updated 13 outputs and left 1175
  unchanged. Focused identity, quantity, UOM, and guard checks plus the
  CRLF-aware diff check passed. PLAN validation could not launch because the
  WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- The earliest-upcoming summary now echoes the selected row's storage
  location, batch, and valuation type. It selects the first upcoming row after
  the deterministic expiry/batch/location/valuation sort, keeping the identity
  aligned with the reported date; UOM results echo the identity unchanged.
  Updated README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed
  with 0 issues across 251 files; transpilation updated 3 outputs and left
  1185 unchanged. Focused sort/UOM checks and CRLF-aware diff checks passed.
  PLAN validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch expiry exposure now returns the earliest positive-stock upcoming
  expiration date within the requested window and its calendar-day distance
  from the as-of date. The day count is zero for expiry on the as-of date, and
  both fields remain initial when no upcoming row has positive stock. The UOM
  result echoes these values. Updated README, PLAN, ANOMALIES, and the PLAN
  source guard. Abaplint passed with 0 issues across 251 files; transpilation
  updated 13 outputs and left 1175 unchanged. Focused source/guard checks and
  CRLF-aware diff checks passed. PLAN validation could not launch because the
  WSL 1 Node shim rejects WSL 1. ABAP Unit was not run.

- Batch expiry exposure now reports positive-stock batch/location/valuation
  rows with valid expiry dates after the requested window in a separate count
  and unrestricted, available, QI, and blocked totals. The UOM result carries
  base and requested-unit totals; after-window rows remain outside dated
  detail and expired/upcoming totals. Updated README, PLAN, ANOMALIES, and the
  PLAN source guard. Abaplint passed with 0 issues across 251 files;
  transpilation updated 3 outputs and left 1185 unchanged. Focused
  source/documentation guard checks and CRLF-aware diff checks passed. PLAN
  validation could not launch because the WSL 1 Node shim rejects WSL 1.
  ABAP Unit was not run.

- Batch expiry exposure now reports undated positive-stock row counts and
  unrestricted, reservation-net available, QI, and blocked quantity totals.
  The UOM result includes both base and requested-unit totals, while undated
  rows stay outside the dated batch detail and expired/upcoming totals.
  Updated README, PLAN, ANOMALIES, and the PLAN source guard. Abaplint passed
  with 0 issues across 251 files; transpilation updated 13 outputs and left
  1175 unchanged. Focused source/guard checks and the CRLF-aware diff check
  passed. PLAN validation could not launch because of the WSL 1 Node shim
  error. ABAP Unit was not run.

- Batch expiry results now count positive-stock rows with no resolved expiry
  date and sum their unrestricted, reservation-net available, QI, and blocked
  quantities separately from dated exposure. The UOM result carries each
  quantity in base and requested units. Updated README, PLAN, ANOMALIES, and
  the PLAN source guard. Abaplint passed with 0 issues across 251 files;
  transpilation updated 13 outputs and left 1175 unchanged. Focused exposure
  and guard checks plus the CRLF-aware diff check passed. PLAN validation could
  not launch because the WSL 1 Node shim rejects WSL 1 before running the
  script. ABAP Unit was not run.

- Batch expiry reports now carry a UTC read-completion timestamp through the
  UOM result. Rechecked scrap posting rejects a second report whose timestamp
  is missing or not later when the original report is timestamped; legacy
  untimestamped reports keep the prior behavior. Updated README, PLAN,
  ANOMALIES, and the source guard. Abaplint passed with 0 issues across 251
  files; transpilation updated 6 outputs and left 1182 unchanged. Focused
  timestamp ordering and recheck source checks plus CRLF-aware diff checks
  passed. PLAN validation could not launch: the WSL 1 Node shim cannot find
  its installation directory, and direct node.exe launch hit a WSL socket
  error. ABAP Unit was not run.

- Batch expiry exposure results now report expired and upcoming row counts
  for returned batch/location/valuation rows with positive stock; the UOM
  result carries those counts unchanged. The earlier valuation-type tie-break
  also keeps equal-expiry selection deterministic. Updated README, PLAN,
  ANOMALIES, and the PLAN guard. Abaplint found 0 issues across 251 files;
  transpilation created 0 outputs, updated 3, and left 1185 unchanged. Focused
  row-count and CRLF-aware diff checks passed. PLAN validation could not launch
  because the WSL 1 Node shim reports WSL 1 unsupported and cannot determine
  the Node.js install directory. ABAP Unit was not run.

- Batch expiry exposure now sorts ties by valuation type after status, expiry,
  batch, and location, making equal-expiry FEFO selection deterministic when
  one batch/location appears in multiple valuations. Updated README, PLAN,
  ANOMALIES, and the PLAN guard. Abaplint found 0 issues across 251 files;
  transpilation created 0 outputs, updated 4, and left 1184 unchanged. The
  CRLF-aware diff check passed. PLAN validation could not launch because the
  WSL 1 Node shim rejects WSL 1 and cannot determine the Node.js install
  directory. ABAP Unit was not run.

- Stock-backed scrap preview, atomic posting, and independent posting now
  prevalidate all request structure, IDs, categories, exclusion keys, and
  priority rows before the first UOM conversion. A shared request validator
  handles date windows, quantities, units, and category fields. Updated the
  README, PLAN, ANOMALIES, and source guards. Abaplint found 0 issues across
  251 files; transpilation reported 0 created or updated outputs and 1188
  unchanged. Focused source-order and CRLF-aware diff checks passed. PLAN validation could not launch
  because the WSL 1 Node shim reports WSL 1 unsupported and cannot determine
  the Node.js install directory. ABAP Unit was not run.

- Stock-backed scrap preview, atomic posting, and independent posting now
  validate complete, unique call-wide and request-specific reservation keys
  before the first UOM conversion. Empty-input behavior is unchanged. Added
  a shared key validator and PLAN source guards, and documented the ordering
  in README, PLAN, and ANOMALIES. Abaplint found 0 issues across 251 files;
  transpilation completed with 0 created, 5 updated, and 1183 unchanged. The
  CRLF-aware diff check passed. PLAN validation could not launch because the
  WSL 1 Node shim reports that WSL 1 is unsupported and cannot determine the
  Node.js install directory. ABAP Unit was not run.

- Added request-specific reservation exclusions to bulk batch expiry exposure
  and its UOM variant. Each request's keys combine with call-wide exclusions,
  and requests with identical effective key sets share a stock read. Stock-backed
  scrap previews and posting requests now carry their own exclusions through
  initial and recheck reads. Base and UOM results echo the effective keys.
  Rechecked scrapping also requires effective exclusion sets to match;
  malformed or duplicate keys fail comparison. Updated README, PLAN, anomaly
  notes, and the PLAN guard. Abaplint passed with 0 issues across 251 files;
  transpilation passed with 0 created, 5 updated, and 1183 unchanged. The
  CRLF-aware diff check passed. PLAN validation could not launch because the
  WSL 1 Node shim reports that WSL 1 is unsupported and cannot determine the
  Node.js install directory. ABAP Unit was not run.

- Aligned expired-batch scrap preview, direct posting, and rechecked posting on
  the posting date. Exposure status is validated against its as-of date, then
  the expiration date determines eligibility at posting; a batch reported as
  upcoming can qualify if it expires before posting. Updated README, PLAN,
  anomaly notes, and the PLAN guard. Abaplint passed with 0 issues across 251
  files; transpilation passed with 0 created, 5 updated, and 1183 unchanged.
  The CRLF-aware diff check passed. PLAN validation could not launch because
  the WSL 1 Node shim reports that WSL 1 is unsupported and cannot determine
  the Node.js install directory. ABAP Unit was not run.

- Added optional request priorities to atomic FEFO posting, including the
  stock-backed entry point. Atomic preflight now allocates pooled
  material/plant/location/batch/valuation/category capacity in rank order,
  returns rows in caller order, and executes the group in the same priority
  order. Partial allocations share snapshot stock by rank; the group still
  commits or rolls back as one unit. Preflight keeps distinct errors for
  individual shortfalls and requests that exceed the shared pool. Updated
  README, PLAN, anomaly notes, and the PLAN guard. Abaplint passed with 0
  issues across 251 files; transpilation passed with 0 created, 4 updated, and
  1184 unchanged. The CRLF-aware diff check passed. PLAN validation remains
  unavailable because the WSL1 Node shim fails before the script launches.
  ABAP Unit was not run.

- Atomic FEFO bulk posting now catches a request-level
  `zcx_invalid_goods_movement` from deferred execution, rolls back the pending
  group outside test-run mode, retains the exception message on its row, and
  reports `exception_count`. Updated README, PLAN, anomaly notes, and the PLAN
  guard.
  Abaplint passed with 0 issues across 251 files; transpilation passed with 0
  created, 6 updated, and 1182 unchanged. The CRLF-aware diff check passed.
  PLAN validation remains unavailable because of the WSL1 Node shim failure.
  ABAP Unit was not run.

- Fixed shared-capacity allocation in the independent stock-backed FEFO bulk
  path. The preflight and posting passes pool matching material/plant/location/
  batch/valuation/category balances using the lower amount reported across the
  initial and recheck snapshots. Priorities determine allocation order, result
  rows remain in caller order, and only successful requests consume capacity.
  Failed requests release their allocation for later requests. Updated README,
  PLAN, anomaly notes, and the PLAN guard. Abaplint passed with 0 issues across
  251 files; transpilation passed with 0 created, 5 updated, and 1183 unchanged.
  The CRLF-aware diff check passed. PLAN validation remains unavailable because
  the WSL1 Node shim fails before the script launches. ABAP Unit was not run.

- Added `exception_count` to the independent FEFO bulk summary so callers can
  identify request-level posting exceptions without scanning result rows. It
  counts a subset of `failed_count`. Updated README, PLAN, anomaly notes, and
  the PLAN guard. Abaplint passed with 0 issues across 251 files;
  transpilation passed with 0 created, 5 updated, and 1183 unchanged. The
  CRLF-aware diff check passed. PLAN validation remains unavailable because of
  the WSL1 Node shim failure. ABAP Unit was not run.

- Added `stopped_on_failure` to the independent bulk summary. It records when
  stop-on-failure triggers even if the failed request was last and no rows are
  skipped. Updated README, PLAN, anomaly notes, and the PLAN guard. Abaplint
  passed with 0 issues across 251 files; transpilation passed with 0 created,
  6 updated, and 1182 unchanged. The CRLF-aware diff check passed. PLAN
  validation remains unavailable because of the WSL1 Node shim failure. ABAP
  Unit was not run.

- Updated independent FEFO bulk posting to catch a request-level
  `zcx_invalid_goods_movement` raised during posting. The row retains its
  preflight preview and receives the exception text as an error message, so
  prior independent commits remain visible in the returned summary. Updated
  README, PLAN, anomaly notes, and the PLAN guard. Abaplint passed with 0
  issues across 251 files; transpilation passed with 0 created, 6 updated, and
  1182 unchanged. PLAN validation could not launch because the WSL1 Node shim
  failed; direct `cmd.exe` invocation also hit the WSL interop socket error.
  The CRLF-aware diff check passed. ABAP Unit was not run.

- Added opt-in `iv_stop_on_failure` to both independent FEFO bulk methods and
  the stock-backed bulk method. A first shortfall or returned posting error
  stops later requests; result rows mark them `is_skipped` and `skipped_count`
  stays separate from `failed_count`. Earlier independent commits remain
  recorded. Updated README, PLAN, anomaly notes, and the PLAN guard. Abaplint
  passed with 0 issues across 251 files; transpilation passed with 0 created,
  6 updated, and 1182 unchanged. The CRLF-aware diff check passed. PLAN
  validation could not start because the WSL1 Node shim reports that WSL1 is
  unsupported and cannot determine the Node.js install directory. ABAP Unit was
  not run.

- Added optional request-priority ranks to `SCRAP_EXPIRED_FEFO_BULK` and its
  UOM form. Lower positive ranks post first, unranked requests follow, and ties
  keep caller order; results remain in caller order and echo rank metadata.
  Invalid, duplicate, and unknown priority rows are rejected before posting.
  Updated README, anomaly notes, PLAN, and its validation guard. Abaplint passed
  with 0 issues across 251 files; transpilation passed with 0 outputs created,
  6 updated, and 1182 unchanged. The CRLF-aware diff check passed. PLAN
  validation could not start because the WSL1 Node shim reports that WSL1 is
  unsupported and cannot determine the Node.js install directory. ABAP Unit was
  not run.

- Added `SCRAP_FEFO_BULK_FROM_STOCK` for stock-backed, independently committed
  FEFO posting. It validates requests, UOM mappings, and priority rows before
  stock reads, forwards reservation exclusions to the initial and optional
  recheck reads, and passes ranked requests into the existing bulk posting
  path. Updated README, anomaly notes, PLAN, and the PLAN guard. Abaplint passed
  with 0 issues across 251 files; transpilation passed with 0 outputs created,
  5 updated, and 1183 unchanged. The CRLF-aware diff check passed. PLAN
  validation remains unavailable because the WSL1 Node shim cannot determine
  the Node.js install directory. ABAP Unit was not run.

- Added `SCRAP_EXPIRED_QI_BATCH_STOCK` for expired batch stock in quality
  inspection. It validates expiry and selected quantity against the reported QI
  balance, then posts movement 553 with the required cost center. Added a
  success fixture where unrestricted stock is zero and a rejection above the
  QI quantity, plus README, anomaly, and PLAN guard updates. Validation:
  abaplint passed (0 issues across 247 files), transpilation passed (4 updated,
  1181 unchanged), and the CRLF-aware diff check passed. ABAP Unit was not run.
  PLAN validation could not start because the WSL1 Node shim reported that WSL1
  is unsupported and could not determine the Node.js install directory.

- Added `SCRAP_EXPIRED_QI_BATCH_UOM` to convert caller quantities to the
  material base unit before enforcing the reported QI balance. Added success,
  over-balance, and unknown-unit fixtures.

- Added `SCRAP_EXPIRED_QI_RECHECKED` to compare the selected batch across
  the original and second expiry exposure before posting movement 553 against
  the rechecked QI quantity. Added unchanged-snapshot and changed-QI fixtures.
  Validation: abaplint passed (0 issues across 247 files), transpilation passed
  (8 updated, 1177 unchanged), and the CRLF-aware diff check passed. ABAP Unit
  was not run. PLAN validation could not start because the WSL1 Node shim
  reported that WSL1 is unsupported and could not determine the Node.js install
  directory.

- Added `SCRAP_EXPIRED_QI_RECHECKED_UOM`, which converts per-selection units to
  base units before running the second-snapshot comparison. Added a successful
  conversion fixture. Final validation for the QI posting variants: abaplint
  passed (0 issues across 247 files), transpilation passed (8 updated, 1177
  unchanged), and the CRLF-aware diff check passed. ABAP Unit was not run.
  PLAN validation could not start because the WSL1 Node shim reported that
  WSL1 is unsupported and could not determine the Node.js install directory.

- Added `SCRAP_EXPIRED_BLOCKED_STOCK` for expired batch stock in the blocked
  category. It caps movement 555 against the selected row's blocked quantity,
  independent of unrestricted and QI balances. Added success and overage
  fixtures, README/anomaly notes, and a PLAN guard.

- Added `SCRAP_EXPIRED_BLOCKED_UOM` to convert selections into the material base
  unit before enforcing the blocked-stock cap. Added success and converted
  overage fixtures.

- Added blocked-stock recheck methods for base-unit and alternate-unit
  selections. They compare selected batch categories across two expiry reports
  before posting movement 555. Added unchanged-snapshot, changed-balance, and
  unit-conversion fixtures. Validation for the blocked-stock paths: abaplint
  passed (0 issues across 247 files), transpilation passed (8 updated, 1177
  unchanged), and the CRLF-aware diff check passed. ABAP Unit was not run.
  PLAN validation could not start because the WSL1 Node shim reported that
  WSL1 is unsupported and could not determine the Node.js install directory.

- Added `PREVIEW_EXPIRED_BLOCKED_SCRAP` to produce FEFO-ordered selections from
  expired blocked batches, including partial shortfalls or all-or-nothing
  behavior. Added FEFO, location-priority, upcoming-batch exclusion, and
  all-or-nothing shortfall fixtures. Final validation for the blocked-stock
  feature set: abaplint passed (0 issues across 247 files), transpilation passed
  (8 updated, 1177 unchanged), and the CRLF-aware diff check passed. ABAP Unit
  was not run. PLAN validation could not start because the WSL1 Node shim
  reported that WSL1 is unsupported and could not determine the Node.js install
  directory.

- Added `PREVIEW_EXPIRED_BLOCKED_SCRAP_UOM` to accept alternate-unit quantities,
  echo source and base units, and return posting-ready base-unit splits. Added
  success, converted-shortage, and unknown-unit fixtures. Final validation for
  the blocked-stock preview and posting paths: abaplint passed (0 issues across
  247 files), transpilation passed (8 updated, 1177 unchanged), and the
  CRLF-aware diff check passed. ABAP Unit was not run. PLAN validation could not
  start because the WSL1 Node shim reported that WSL1 is unsupported and could
  not determine the Node.js install directory.

- Added QI and unrestricted variants of the expired-scrap FEFO preview. They
  share the category-aware allocator while selecting from raw QI or
  reservation-net unrestricted quantities, and echo the corresponding
  movement type. Added a fixture that verifies category-specific balances and
  movements. Validation: abaplint passed (0 issues across 247 files),
  transpilation passed (8 updated, 1177 unchanged), and the CRLF-aware diff
  check passed. ABAP Unit was not run. PLAN validation could not start because
  the WSL1 Node shim reported that WSL1 is unsupported and could not determine
  the Node.js install directory.

- Generalized expired-scrap previews to accept a stock category directly and
  added `PREVIEW_EXPIRED_SCRAP_UOM` so blocked, QI, and unrestricted previews
  share the same material-unit conversion and base-unit result. Kept the
  blocked UOM entry point as a compatibility wrapper and added a fixture for
  all three categories, including an all-or-nothing unrestricted shortfall.
  Validation: abaplint passed (0 issues across 247 files), transpilation passed
  (0 created, 8 updated, 1177 unchanged), and the CRLF-aware diff check passed.
  ABAP Unit was not run. PLAN validation could not start because the WSL1 Node
  shim reported that WSL1 is unsupported and could not determine the Node.js
  install directory.

- Added `SCRAP_EXPIRED_SCRAP` and `SCRAP_EXPIRED_SCRAP_UOM` as category-selecting
  entry points over the existing guarded unrestricted, QI, and blocked posting
  paths. Added fixtures for 551, 553, and 555 dispatch in base and alternative
  units, plus invalid-category rejection before posting. Validation: abaplint
  passed (0 issues across 247 files), transpilation passed (0 created, 8
  updated, 1177 unchanged), and the CRLF-aware diff check passed. ABAP Unit was
  not run. PLAN validation could not start because the WSL1 Node shim reported
  that WSL1 is unsupported and could not determine the Node.js install
  directory.

- Added `SCRAP_EXPIRED_CAT_RECHECKED` and `SCRAP_EXP_CAT_RECHECK_UOM` to route
  category-selecting requests through the matching unrestricted, QI, or
  blocked second-snapshot validation. The UOM form converts selections before
  comparison. Fixtures cover all three movement types and invalid categories.
  Validation: abaplint passed (0 issues across 247 files), transpilation passed
  (0 created, 8 updated, 1177 unchanged), and the CRLF-aware diff check passed.
  ABAP Unit was not run. PLAN validation could not start because the WSL1 Node
  shim reported that WSL1 is unsupported and could not determine the Node.js
  install directory.

- Added `SCRAP_EXPIRED_FEFO` and `SCRAP_EXPIRED_FEFO_UOM` to allocate expired
  stock in FEFO order and pass the proposed splits to the selected category's
  posting method. Full quantity is required by default; callers can opt into
  partial posting, and may supply a second exposure for rechecking. Added
  fixtures for all three stock categories, unit conversion, shortfall without
  posting, partial posting, and changed-snapshot rejection. Validation:
  abaplint passed (0 issues across 247 files), transpilation passed (0 created,
  8 updated, 1177 unchanged), and the CRLF-aware diff check passed. ABAP Unit
  was not run. PLAN validation could not start because the WSL1 Node shim
  reported that WSL1 is unsupported and could not determine the Node.js install
  directory.

- Added `SCRAP_EXPIRED_FEFO_BULK` and `SCRAP_EXPIRED_FEFO_BULK_UOM`. They
  prevalidate unique exposure request IDs and all base or alternative units
  before posting, then return per-request results and continue after a returned
  BAPI failure. Successful requests commit independently outside test-run mode.
  Fixtures cover mixed 551,
  553, and 555 requests, UOM conversion, continued processing after a failed
  request, duplicate IDs, and an invalid later unit before the first post.
  Validation: abaplint passed (0 issues across 247 files), transpilation passed
  (0 created, 8 updated, 1177 unchanged), and the CRLF-aware diff check passed.
  ABAP Unit was not run. PLAN validation could not start because the WSL1 Node
  shim reported that WSL1 is unsupported and could not determine the Node.js
  install directory.

- Added `SCRAP_EXP_FEFO_BULK_ATOMIC` and `SCRAP_EXP_FEFO_BULK_ATOMIC_UOM` with
  full request preflight, one deferred movement per request, and one shared
  commit. A preflight shortfall stops all posts; movement or commit failures
  roll back the group and clear provisional document references. Added fixtures
  for mixed-category shared commit, create rollback, commit rollback, shortfall
  before posting, and UOM test-run behavior. Extended both bulk forms to
  prevalidate optional per-request second exposures before posting, including
  the atomic group; added unchanged and changed snapshot fixtures. Validation
  also groups atomic consumption by material, plant, location, batch, valuation
  type, and stock category to block overlapping requests from exceeding the
  smallest supplied balance and return a preflight diagnostic. A fixture covers
  repeated allocation from two individually valid snapshots. Validation:
  abaplint reported 0 issues across 247 files, transpilation reported 0
  created, 6 updated, and 1179 unchanged, and the CRLF-aware diff check passed.
  ABAP Unit was not run. PLAN validation
  could not start because the WSL1 Node shim reported that WSL1 is unsupported
  and could not determine the Node.js install directory.

- Added `SCRAP_FEFO_ATOMIC_FROM_STOCK`, an end-to-end path that bulk-reads expiry
  exposures, reads a second snapshot by default, checks selected batches, then
  uses the existing atomic UOM posting path. It validates request identities,
  dates, categories, base-unit mappings, and requested units before stock reads;
  it forwards reservation exclusions to both reads and returns both snapshots
  with posting outcomes. The production factory injects the repository-backed
  reader. Fixtures cover changed snapshots, pre-read unit rejection, empty input
  without an injected reader, and exclusion forwarding. Validation: abaplint
  reported 0 issues across 251 files; transpilation created 0 outputs, updated
  4, and left 1184 unchanged; the CRLF-aware diff check passed. PLAN validation
  could not start because the WSL1 Node shim reported that WSL1 is unsupported
  and could not determine the Node.js install directory. ABAP Unit was not run.

- Added `PREVIEW_EXP_SCRAP_FROM_STOCK` to bulk-read expiry exposures and return
  per-request, posting-ready FEFO splits without calling the goods-movement API.
  It validates unique request IDs, dates, categories, material base-unit
  mappings, and requested UOMs before stock reads, forwards reservation
  exclusions, and requires full allocation by default. It pools matching batch
  capacity across requests at the smallest reported balance and consumes it in
  caller order. Optional positive priority ranks allocate lower ranks first,
  preserve caller order for ties, and retain caller-order results; each output
  row echoes its rank and whether it was prioritized. Fixtures check BOX
  conversion, overlapping requests against one batch, explicit
  priority, an all-or-nothing shortfall, group counts and status, empty input,
  exclusion forwarding, no posting, and rejection of invalid UOM or priority
  rows before stock reads. Abaplint reported 0 issues across 251 files; the
  final transpilation created 0 outputs, updated 6, and left 1182 unchanged. The
  CRLF-aware diff check and focused source-flow checks
  passed. PLAN validation could not start because the WSL1 Node shim reported
  that WSL1 is unsupported and could not determine the Node.js install
  directory. ABAP Unit was not run.

- Added `SCRAP_EXPIRED_BATCH_STOCK`, which validates selected batches against an
  expiry exposure snapshot and posts movement 551 from reported available
  unrestricted stock to a caller-supplied cost center. It rejects upcoming
  batches, quantities above the snapshot, duplicate selections, an as-of date
  after the posting date, and a base-unit mapping that differs from the
  material's UOM master before posting. Added success and rejection fixtures,
  README and anomaly notes, and PLAN guards. SAP Help confirms movement 551 is
  for scrapping unrestricted stock.

- Added `SCRAP_EXPIRED_BATCH_UOM` for selected expiry quantities in alternative
  units. It checks report dates and unique batch selections before UOM reads,
  requires a cost center, converts each quantity to the material base unit, and
  reuses the guarded movement 551 path. Both input forms can pass a configured
  movement reason through the BAPI adapter. Added successful EA-to-BOX conversion
  and unknown-unit rejection fixtures, README coverage, BAPI adapter mapping,
  and PLAN guards. Abaplint found 0 issues across 247 files; transpilation
  created 0 outputs, updated 5, and left 1180 unchanged. A line-ending-aware
  diff check passed.
  ABAP Unit was not run. `validate:plan` cannot start because the Windows Node
  shim reports WSL 1.

- Added `SCRAP_EXPIRED_BATCH_RECHECKED`, which accepts the original and fresh
  expiry reports, verifies selected batch identity, expiry and stock-category
  balances remain unchanged, and posts only against the second report. Added
  matching-snapshot and changed-availability fixtures plus README, anomaly, and
  PLAN guard updates. Abaplint found 0 issues across 247 files; transpilation
  created 0 outputs, updated 3, and left 1182 unchanged. The line-ending-aware
  diff check passed. ABAP Unit was not run. `validate:plan` remains unavailable
  because the Windows Node shim reports WSL 1.

- Added `SCRAP_EXPIRED_RECHECKED_UOM` to convert requested-unit quantities before
  applying the same original-versus-rechecked batch comparison. Added an EA to
  BOX posting fixture and an unknown-unit rejection fixture. Abaplint found 0
  issues across 247 files; transpilation created 0 outputs, updated 3, and left
  1182 unchanged. The line-ending-aware diff check passed. ABAP Unit was not
  run; `validate:plan` cannot start because the Windows Node shim reports WSL 1.

- Added `GET_EXPIRY_EXPOSURE_UOM_BULK`, converting each expiry balance and the
  expired/upcoming totals into a requested material unit while retaining their
  base-unit quantities and batch identity. It validates dates and unique IDs
  before ratio reads, caches each material/unit ratio, then uses one bulk batch
  read. Added conversion and pre-read rejection fixtures plus README, anomaly,
  and PLAN guard updates. Abaplint found 0 issues across 247 files;
  transpilation updated 3 outputs and left 1182 unchanged. ABAP Unit was not
  run; `validate:plan` cannot start because the Windows Node shim reports WSL 1.

- Added bulk batch expiry exposure reporting with per-request as-of and cutoff
  dates. It separates expired and upcoming balances, preserves storage location,
  valuation type, and all stock categories, and uses checked positive totals.
  Same-day expiry remains upcoming; undated and non-batch split-valuation rows
  are excluded. Added ABAP Unit fixtures, README guidance, an anomaly note, and
  PLAN source guards. Abaplint found 0 issues across 247 files; transpilation
  updated 8 outputs and left 1177 unchanged. A line-ending-aware diff check
  passed. `validate:plan` cannot start because the Windows Node shim reports
  WSL 1; ABAP Unit was not run.

- Extended standard stock-reservation UOM rows to return required, withdrawn,
  and open quantities in both base and requested units. The repository now
  preserves the original RESB amounts, and an EA-to-BOX ABAP Unit fixture
  covers all six values. README and PLAN guards cover the row contract.
  Abaplint found 0 issues across 247 files; transpilation updated 21 outputs.
  Focused flow checks, all 92 SAP stub XML parses, consistent line endings,
  and `git diff --check` passed. `validate:plan` cannot start because the
  Windows Node shim reports WSL 1; ABAP Unit was not run.

- Added requested-unit `required_quantity` and `withdrawn_quantity` to
  sales-order reservation UOM rows, alongside the converted open quantity and
  corresponding base-unit values. Extended the UOM fixture with EA-to-BOX
  assertions for each amount. README and PLAN guards cover the paired unit
  fields. Abaplint found 0 issues across 247 files; transpilation updated 6
  outputs. Focused source checks, all 92 SAP stub XML parses, and
  `git diff --check` passed. `validate:plan` cannot start because the Windows
  Node shim reports WSL 1; ABAP Unit was not run.

- Added base-unit required and withdrawn quantities to sales-order reservation
  results, alongside the open amount. The UOM result echoes them as
  `base_required_quantity` and `base_withdrawn_quantity`, allowing callers to
  reconcile the net reservation. Updated the repository contract, README,
  PLAN guard, and ABAP Unit assertions. Abaplint found 0 issues across 247
  files; transpilation updated 21 outputs. Focused flow checks, all 92 SAP
  stub XML parses, and `git diff --check` passed. `validate:plan` cannot start
  because the Windows Node shim reports WSL 1; ABAP Unit was not run.

- Carried RESB storage location (`LGORT`) and batch (`CHARG`) through the
  sales-order reservation repository and unit-aware result rows, preserving
  physical reservation scope with each converted quantity. The repository
  query, result mapping, README, and PLAN guard now cover both fields. Extended
  the UOM ABAP Unit fixture to assert their propagation. Abaplint found 0
  issues across 247 files; transpilation updated 21 outputs. Focused flow
  checks, all 92 SAP stub XML parses, consistent line endings, and
  `git diff --check` passed. `validate:plan` cannot start because the Windows
  Node shim reports WSL 1; ABAP Unit was not run.

- Hardened sales-order reservation results: the scalar reader now delegates
  through the validated bulk path, which rejects missing or duplicate RESB
  reservation keys, rows outside the requested documents, and nonpositive
  quantities. Added ABAP Unit coverage for missing and duplicate keys; the
  existing UOM fixture now carries real-shaped reservation keys. README and
  PLAN guards cover the contract. Abaplint found 0 issues across 247 files;
  transpilation updated 4 outputs. Focused source-flow checks, all 92 SAP stub
  XML parses, and `git diff --check` passed. `validate:plan` cannot start
  because the Windows Node shim reports WSL 1; ABAP Unit was not run.

- Carried RESB `reservation_number` and `reservation_item` through the sales-
  order reservation repository contract and unit-aware result rows. The
  repository orders equal rows by those keys for stable traceability. README
  and PLAN guards cover key propagation. Abaplint found 0 issues across 247
  files; transpilation updated 21 outputs. Focused source-flow checks, all 92
  SAP stub XML parses, and `git diff --check` passed. `validate:plan` cannot
  start because the Windows Node shim reports WSL 1; ABAP Unit was not run.

- Added optional call-wide `iv_required_through_date` to scalar and bulk
  sales-order reservation reads. The repository pushes the cutoff into the
  RESB query; the service validates it before reads and reapplies the filter,
  retaining undated rows. The scalar repository reader forwards to the same
  bulk query. README and PLAN guards cover the behavior. Abaplint found 0
  issues across 247 files; transpilation updated 17 outputs. Focused flow
  checks, all 92 SAP stub XML parses, and `git diff --check` passed.
  `validate:plan` cannot start because the Windows Node shim reports WSL 1;
  ABAP Unit was not run.

- Extended sales-order reservation UOM rows with `base_open_quantity` alongside
  the converted `open_quantity`. The base field uses `RESB-BDMNG`; converted
  quantities use `MARD-LABST`, matching the unit-conversion helper's return
  type. The validator checks both fields and their documentation. Abaplint
  found 0 issues across 247 files; transpilation updated 3 outputs. Focused
  source-flow checks, all 92 SAP stub XML parses, line-ending preservation, and
  `git diff --check` passed. `validate:plan` cannot start because the Windows
  Node shim reports WSL 1; ABAP Unit was not run.

- Added per-request `required_through_date` to keyed and scalar sales-order
  reservation UOM reads. The bulk path validates every cutoff before the
  shared reservation read, applies each cutoff independently, retains undated
  rows, and echoes the cutoff with each result. Each row now exposes both
  `base_open_quantity` and converted `open_quantity`. README and PLAN guards
  cover the contract. Abaplint found 0 issues across 247 files; transpilation
  updated 6 outputs. Focused source-flow checks, all 92 SAP stub XML parses,
  line-ending preservation, and `git diff --check` passed. `validate:plan`
  cannot start because the Windows Node shim reports WSL 1; ABAP Unit was not
  run.

- Added scalar `GET_ORDER_RES_UOM` for a sales document, material, plant, and
  caller-selected unit. It delegates through the existing keyed bulk reader so
  blank keys, unknown units, open-row filtering, ratio handling, and converted
  quantities follow one implementation. README and PLAN guards cover the
  scalar contract. Abaplint found 0 issues across 247 files; transpilation
  updated 5 outputs. Focused source-flow checks, all 92 SAP stub XML parses,
  line-ending preservation, and `git diff --check` passed. `validate:plan`
  cannot start because the Windows Node shim reports WSL 1; ABAP Unit was not
  run.

- Added `GET_OPEN_STOCK_RES_UOM_BULK` for request-keyed, dated reservation
  reads in caller-selected units, plus scalar `GET_OPEN_STOCK_RES_UOM` for the
  same result shape. The bulk method validates all requests and distinct
  material/unit ratios before reading reservation rows, caches each ratio,
  returns both base and converted open quantities, and preserves request and
  reservation ordering. The scalar method delegates to the bulk path. README
  and PLAN guards describe the contract.
  Abaplint found 0 issues across 247 files; transpilation updated 5 outputs.
  Focused source-flow checks, all 92 SAP stub XML parses, line-ending
  preservation, and `git diff --check` passed. `validate:plan` cannot start
  because the Windows Node shim reports WSL 1; ABAP Unit was not run.

- Added `GET_OPEN_STOCK_RES_REQ_BULK` for independently dated material/plant
  reservation requests. It validates all IDs, keys, and dates before reading,
  groups the repository calls by cutoff, and echoes each cutoff with results in
  input order. README and PLAN guards protect the request contract. Abaplint
  found 0 issues across 247 files; transpilation updated 3 outputs. Focused
  validation/grouping/order checks, all 92 SAP stub XML parses, line-ending
  preservation, and `git diff --check` passed. `validate:plan` cannot start
  because the Windows Node shim reports WSL 1; ABAP Unit was not run.

- Added optional `iv_required_through_date` to bulk stock-reservation reads.
  The stock service validates the date before any repository access, forwards
  it to scalar and bulk RESB queries, retains undated reservations, and filters
  later dated rows again in the service. README and PLAN guards cover the
  contract. Abaplint found 0 issues across 247 files; transpilation updated 3
  outputs. Focused source-flow checks, all 92 SAP stub XML parses, line-ending
  preservation, and `git diff --check` passed. `validate:plan` cannot start
  because the Windows Node shim reports WSL 1; ABAP Unit was not run.

- Added `READ_CC_RESV_REQUESTS_BULK` with one cost center and required-date
  cutoff per unique request ID. It validates all requests before reads, groups
  distinct centers by cutoff, reuses the existing bulk reader once per date,
  and restores each result and request ID in input order. Duplicate centers are
  supported across cutoffs. README and PLAN guards describe the contract.
  Abaplint found 0 issues across 247 files; transpilation updated 8 outputs.
  Focused grouping/order checks, 92 SAP stub XML parses, CRLF preservation, and
  `git diff --check` passed. `validate:plan` cannot start because the Windows
  Node shim reports WSL 1; ABAP Unit was not run.

- Added optional required-through-date cutoffs to scalar and bulk cost-center
  reservation reads. The cutoff is validated before reads, pushed into the
  RESB query, and reapplied in the service while retaining undated rows; bulk
  scope validation still runs before service filtering. README and PLAN guards
  now cover the contract. Abaplint found 0 issues across 247 files;
  transpilation updated 5 outputs. Focused flow checks, all 92 SAP stub XML
  parses, CRLF preservation, and `git diff --check` passed. `validate:plan`
  cannot start because the Windows Node shim reports WSL 1; ABAP Unit was not
  run.

- Replaced the remaining scalar RESB required-minus-withdrawn calculations in
  production components, returnable component previews, cost-center and
  sales-order reservation reads, issue previews/posting, and plant stock
  reservation reads with `CALCULATE_OPEN_RES_QTY`. Added PLAN source guards for
  all eight methods and documented zero-clamping in the returnable-component
  view. Abaplint found 0 issues across 247 files; transpilation updated 12
  generated outputs. Focused guards, all 92 SAP stub XML parses, CRLF
  preservation, and `git diff --check` passed. `validate:plan` could not start
  because the Windows Node shim reported WSL 1; ABAP Unit was not run.

- Keyed project coverage now uses exact-key MSPR/RESB reads grouped by cutoff
  and identical request exclusions, with validated base units reused through
  the keyed and grouped cores. Coverage, available-stock, FEFO, and location
  paths push reservation cutoffs into RESB queries while retaining undated
  rows; service-side filtering remains in place. Open-item reads and reservation
  netting use the shared open-quantity calculator; full-item open quantities
  clamp at zero. Abaplint found 0 issues across 247 files; transpilation
  confirmed 1185 generated outputs unchanged. Focused source-flow, documentation,
  and validator-guard-content checks, all 92 SAP stub XML parses, CRLF
  preservation, and `git diff --check` passed.
  `validate:plan` cannot start in this WSL 1 environment; ABAP Unit was not run.

- Updated `READ_RESV_COVERAGE_BULK_UOM` to validate and cache each distinct
  material/unit ratio, then reuse `READ_RESV_COVERAGE_KEYS_BULK` for exact
  material/plant/WBS results. It forwards call-wide and per-request exclusions,
  returns zero coverage with the material base unit, and preserves request
  order. Abaplint found 0 issues across 247 files; transpilation updated 4
  outputs. Focused source-flow, documentation, and PLAN guard content checks,
  all 92 SAP stub XML parses, CRLF preservation, and `git diff --check` passed.
  `validate:plan` cannot start in this WSL 1 environment; ABAP Unit was not run.

- Added sorted `stock_reservation_deductions` to base and UOM coverage rows.
  Each trace row names the reservation/item and the stock location/batch that
  absorbed its quantity. Coverage verifies base trace sums against each stock
  detail's applied deduction; UOM traces retain base quantities and convert
  each applied row. Each included `open_reservations` row now reports covered
  and uncovered quantities after local allocation; base values reconcile to
  its reserved quantity and summary shortfall. The shared subtraction routine
  returns net stocks plus an opt-in trace and orders equal-specificity
  reservations by key for stable attribution. Abaplint found 0 issues across
  247 files; transpilation updated
  6 outputs. Focused source-flow, documentation, and PLAN guard content checks,
  all 92 SAP stub XML parses, CRLF preservation, and `git diff --check` passed.
  `validate:plan` cannot start in this WSL 1 environment; ABAP Unit was not run.

- Added sorted `stock_details` to base and UOM reservation coverage, grouped by
  storage location and batch. Detail rows reconcile gross project stock to the
  deduction applied by reservation distribution and net available stock; UOM
  rows retain base quantities, while any excess reservation remains summary
  shortfall. README, anomaly notes, and PLAN source guards now describe and
  protect this contract. Abaplint found 0 issues across 247 files;
  transpilation succeeded with 1185 outputs unchanged. Focused source-flow,
  documentation, and PLAN guard content checks, all 92 SAP stub XML parses,
  CRLF preservation, and `git diff --check` passed. `validate:plan` cannot
  start in this WSL 1
  environment; ABAP Unit was not run.

- Added `READ_RESV_COVERAGE_FOR_KEY` and
  `READ_RESV_COVERAGE_KEYS_BULK` for explicit material/plant/WBS requests.
  They return one row per requested key, including zero-quantity coverage with
  its material base unit when no balance exists. Bulk reads resolve each
  material's base unit once, reuse the existing date/exclusion-grouped coverage
  reader, and preserve per-request exclusions and input order. Abaplint found
  0 issues across 247 files; transpilation updated 4 outputs. Focused flow and
  documentation checks, PLAN guard syntax parsing, all 92 SAP stub XML parses,
  CRLF preservation, and `git diff --check` passed. `validate:plan` cannot
  start in this WSL 1 environment; ABAP Unit was not run.

- Added `READ_RESERVATION_ITEMS_UOM` and `READ_RESV_ITEMS_BULK_UOM` for
  full active Q reservation details. They retain final-issue and fully
  withdrawn rows with the complete source row and expose required, withdrawn,
  and open quantities in requested and base units. Converted required quantity
  derives from converted withdrawn plus open quantities to retain reconciliation
  after rounding. Bulk reads cache ratios
  before reusing WBS reads and preserve shared and per-request exclusions.
  Abaplint found 0 issues across 247 files; transpilation succeeded. Focused
  flow and documentation checks, PLAN guard syntax parsing, all 92 SAP stub
  XML parses, CRLF preservation, and `git diff --check` passed.
  `validate:plan` cannot start in this WSL 1 environment; ABAP Unit was not run.

- Added `READ_OPEN_RESERVATIONS_UOM` and `READ_OPEN_RESV_BULK_UOM`. Both
  return converted required, withdrawn, and open quantities while retaining the
  source RESB row and base quantities. Bulk requests cache material/unit ratios
  before reusing date-grouped reads and preserve shared and per-request
  exclusions. Abaplint found 0 issues across 247 files; transpilation updated
  4 outputs. Focused flow and documentation checks, PLAN guard syntax parsing,
  all 92 SAP stub XML parses, CRLF preservation, and `git diff --check` passed.
  `validate:plan` cannot start in this WSL 1 environment; ABAP Unit was not run.

- Extended excluded RESB reservation keys to undated same-plant and
  cross-plant base, unit-aware, priority, single, and ATP allocation. The
  repository omits matching open standard-stock rows before computing
  unrestricted or location-level availability; shared demands use the
  released balance. Keys must be complete and unique, and unit entry points
  validate them before conversion. README and structural validator guards were
  updated. Focused Python forwarding/repository/docs checks passed, all 92 stub
  XML files parsed, and CRLF-aware diff checks passed. ABAP lint and
  transpilation remain unavailable because this WSL 1 shell cannot launch the
  Windows Node runtime; ABAP Unit was not run.

- Extended call-wide excluded reservation keys through cross-plant dated base,
  UOM, and ATP allocation, including location-aware methods. The ordinary date
  repository applies exclusions with its existing required-date cutoff; the
  location-status repository omits matching rows before location-level RESB
  netting. Keys are complete and unique and are validated before UOM lookups.
  This preview option does not update SAP reservations. Focused Python
  forwarding/repository/docs checks
  passed and all 92 stub XML files parsed. CRLF-aware diff checks passed. ABAP lint and
  transpilation could not run because this WSL 1 environment cannot launch its
  Windows Node runtime; ABAP Unit was not run.

- Closed a dated-allocation forwarding gap: `ALLOCATE_REQUEST_BY_DATE` now
  accepts complete, unique excluded-reservation keys and forwards them to the
  date-availability repository. The bulk ATP and single ATP wrappers now pass
  the same call-wide option to their unit-aware/base estimators; the existing
  bulk and unit allocators retain their key validation. This aligns the code
  with the documented single-request behavior and does not modify RESB. Lint
  found 0 issues across 247 files; transpilation updated 5 outputs. Focused
  forwarding/docs/validator guards, all 92 SAP stub XML parses, and CRLF-aware
  diff checks passed. `validate:plan` is still unavailable under the WSL 1
  Windows Node launcher; ABAP Unit was not run.

- Valuation-type previews now accept call-wide excluded reservation keys.
  Complete, unique keys must match an open RESB row for a material/plant in
  the demand set; matched open quantities are omitted from batch reservation
  netting and shared by the preview's demands. Base and UOM results echo the
  keys, and ATP carries them in its local estimate. This is preview behavior
  only and does not update SAP reservations. Lint found 0 issues across 247
  files; transpilation updated 3 outputs. Focused API, service, repository,
  README, and validator guard checks passed; all 92 stub XML files parsed, and
  CRLF-aware diff checks passed. `validate:plan` remains unavailable because
  its Windows Node launcher rejects WSL 1; ABAP Unit was not run.

- Expiry-excluded projected quantity now has a base-unit breakdown: batches
  without expiry dates rejected by the effective policy contribute to
  `undated_proj_excl_qty`, while dated batches that are expired or fail the
  minimum shelf life contribute to `dated_expiry_excl_qty`. The two components
  reconcile to the existing `proj_expiry_excluded_qty` total, and UOM results
  expose converted components. Lint found 0 issues across 247 files;
  transpilation updated 4 outputs. Focused service/docs guards, all 92 SAP stub
  XML parses, and CRLF-aware diff checks passed. `validate:plan` remains
  unavailable because its Windows Node launcher rejects WSL 1; ABAP Unit was
  not run.

- Valuation allocation summaries now distinguish projected receipts dated
  after the effective `as_of_date` (`future_projected_quantity`) from
  projected batch balances that fail expiry or shelf-life rules
  (`proj_expiry_excluded_qty`). Both are counted after request location and
  batch-candidate scope; only the first failed availability check is reported
  for each projected receipt. UOM summaries expose converted quantities as
  `source_future_projected_qty` and `source_expiry_excluded_qty`. Lint found 0
  issues across 247 files; transpilation updated 4 outputs. Focused service and
  README guards passed, all 92 SAP stub XML files parsed, and CRLF-aware diff
  checks passed. `validate:plan` could not start because the Windows Node
  launcher rejects WSL 1; ABAP Unit was not run.

- Base valuation summaries now report `excluded_projected_quantity` for
  otherwise-eligible projected balances filtered by request source selectors.
  The count is taken after location, batch, date, and shelf-life checks and
  reflects quantities remaining when each demand is evaluated. UOM summaries
  return `source_excluded_projected_qty` in the requested unit. Lint found 0
  issues across 247 files; transpilation updated 4 outputs. All 129 service
  guards, 88 README guards, 92 stub XML parses, and CRLF-aware diff checks
  passed. `validate:plan` remains unable to start because the Windows Node
  launcher reports WSL 1; ABAP Unit was not run.

- Valuation previews now accept `it_req_projected_exclusions` to remove
  projected source receipts per request without enumerating all allowed
  sources. Exclusion selectors use the same validation and wildcard matching as
  the inclusion list; when both are supplied, receipts must match an inclusion
  row and no exclusion row. Exclusions affect projected receipts only, and
  current stock remains eligible. Base and UOM results echo exclusions; UOM
  validates them before conversion, and ATP forwards them. Lint found 0 issues
  across 247 files; transpilation updated 5 outputs. All 126 service guards,
  85 README guards, 92 stub XML parses, and CRLF-aware diff checks passed.
  `validate:plan` remains unable to start because the Windows Node launcher
  reports WSL 1; ABAP Unit was not run.

- Valuation previews now accept `it_req_projected_priorities` to order a
  request's projected receipts. Rows reuse the source selectors, require a
  known request and positive rank, and must match a receipt for that request's
  material, plant, and valuation type. Overlapping rows use the lowest rank;
  source ranks order projected receipts within each location, ahead of batch
  priority and FEFO ordering, while current stock remains first. Base and UOM
  results echo the rows, and each split exposes its applied
  `source_priority_rank`; ATP forwards the option. Lint found 0 issues across
  247 files; transpilation updated 5 outputs. All 119 service guards, 80 README
  guards, 92 stub XML parses, and CRLF-aware diff checks passed.
  `validate:plan` remains unable to start because the Windows Node launcher
  reports WSL 1; ABAP Unit was not run.

- Projected-source filters can select by `source_type` or `source_document`,
  then optionally refine by `source_item`, `source_plant`, and
  `source_schedule_line`; blank selectors act as wildcards. At least one of
  source type or document is required. Exact request/source tuples are rejected
  as duplicates, while overlapping filters form a union. Base and UOM
  validation require every specified selector to match a receipt for the
  request's material, plant, and valuation type, and both availability and
  split passes apply the same wildcard rules. Lint found 0 issues across 247
  files; transpilation updated 4 outputs. All 106 service guards, 72 README
  guards, 92 stub XML parses, and CRLF-aware diff checks passed.
  `validate:plan` remains unable to start because the Windows Node launcher
  reports WSL 1; ABAP Unit was not run.

- Valuation-type previews now accept request-level projected-source filters
  by `source_type` and `source_document`. Each filter must be unique, name a
  known request, and match a supplied receipt for that request's material,
  plant, and valuation type. It restricts projected availability and splits;
  current stock remains available. UOM validates before conversion, and ATP
  forwards the filter. Lint found 0 issues across 247 files; transpilation
  updated 5 outputs. All 134 source guards, 75 README guards, 92 stub XML
  parses, and CRLF-aware diff checks passed. `validate:plan` remains unable to
  start because the Windows Node launcher reports WSL 1; ABAP Unit was not run.

- Valuation-type split rows now echo each request's `allocation_sequence` in
  addition to their within-demand `split_sequence`. Sorting by the former
  reconstructs cross-demand consumption order; the latter orders source rows
  within a request, while final output remains in caller order. UOM results
  preserve both fields in each nested split. Lint found 0 issues across 247
  files; transpilation updated 4 outputs. All 116 source guards, 66 README
  guards, 92 stub XML parses, and CRLF-aware diff checks passed. The PLAN
  launcher still reports WSL 1 and prevents `validate:plan` from starting;
  ABAP Unit was not run.

- Valuation-type splits now report source availability immediately before and
  after each allocation. Base results expose both values in base units; UOM
  wrappers convert the before-value and derive the after-value as a residual
  after converted allocation, preserving the source-unit partition. Lint found
  0 issues across 247 files; transpilation updated 4 outputs. All 115 source
  guards, 65 README guards, 92 stub XML parses, and CRLF-aware diff checks
  passed. `validate:plan` still cannot start because the Windows Node launcher
  reports WSL 1; ABAP Unit was not run.

- Valuation-type split traces now show each source balance's base-unit
  `available_before_qty` and `available_after_qty` around the allocation.
  UOM split wrappers report the before-quantity converted to the requested
  unit, then derive the after-quantity as the residual after converted
  allocation so the values reconcile. The nested split retains base-unit
  quantities. The after-value is point-in-time; later demands may consume it.
  Lint found 0 issues across 247 files; transpilation updated 4 outputs. All
  113 source guards, 64 README guards, 92 stub XML parses, and CRLF-aware diff
  checks passed. `validate:plan` cannot start because the Windows Node launcher
  reports WSL 1; ABAP Unit was not run.

- Valuation-type split rows now echo `batch_priority_rank`. Positive values
  identify explicit request-ranked source keys, while zero indicates an
  unranked balance; nested UOM splits retain the field. This complements
  `split_sequence` so callers can audit the chosen source order and rank.
  Lint found 0 issues across 247 files; transpilation updated 4 outputs. All
  focused source/docs guards, 92 stub XML parses, and CRLF-aware diff checks
  passed. `validate:plan` remains unable to start because the Windows Node
  launcher reports WSL 1; ABAP Unit was not run.

- Valuation-type preview split rows now include one-based `split_sequence`,
  recording the order each request consumes locations, batches, and projected
  receipts. Final rows still group by caller demand; UOM splits retain the
  sequence in their nested split. Lint found 0 issues across 247 files and
  transpilation updated 4 outputs. All 108 source guards, 58 README guards,
  92 stub XML parses, and CRLF-aware diff checks passed. The PLAN runner remains
  unavailable because the Windows Node launcher reports WSL 1; ABAP Unit was
  not run.

- Valuation-type base, UOM, and ATP previews now accept `iv_fefo`, defaulting
  to the existing allocation order. Enabled FEFO keeps location sequence,
  current-before-projected ordering within each location, and explicit request
  batch ranks. It orders unranked physical batches by expiry, then non-batch
  split valuation keys, with undated physical batches last. Static
  safety-stock withholding retains its deterministic ordering before request
  allocation. Demand rows may opt into FEFO independently; a true shared flag
  enables it for every row, and each allocation reports its effective setting.
  `abaplint` found 0 issues across 247
  files and transpilation updated 4 outputs. All focused source/docs guards,
  92 stub XML parses, and CRLF-aware `git diff --check` passed.
  `validate:plan` could not start because the Windows Node launcher reports
  WSL 1; ABAP Unit was not run. Target SAP batch-determination behavior remains
  unverified.

- Project-reservation bulk deletion, item deletion, reschedule, quantity, final
  issue, and stock-key changes now expose top-level `is_committed` when any row
  commits. Simulations and failed rows do not raise the aggregate. Lint and
  transpilation are being run; ABAP Unit was not run.

- Independent bulk goods-movement results now summarize `is_committed` across
  cost-center, sales-order, WBS, production-order, and PO operations. Test runs
  remain uncommitted, and partial commits remain visible after later failures.
  Lint, transpilation, and local PLAN guard checks passed; ABAP Unit was not
  run. `validate:plan` cannot start because the Windows Node launcher rejects
  WSL 1.

- Production-order independent bulk create, release, completion, change,
  confirmation, close, and deletion actions now expose top-level
  `is_committed`, including ATP-gated release. Partial successes remain visible
  when later rows fail. Lint, transpilation, and local PLAN guard checks passed;
  ABAP Unit was not run. `validate:plan` cannot start because the Windows Node
  launcher rejects WSL 1.

- Planned-order bulk create, delete, change, and convert summaries now expose
  `is_committed` when at least one row commits, preserving visibility of partial
  completion alongside per-row status and counts. Lint, transpilation, and local
  PLAN guard checks passed; ABAP Unit was not run. `validate:plan` cannot start
  because the Windows Node launcher rejects WSL 1.

- STO pair deletion and delivery-completion results now expose aggregate
  `is_deleted` and `is_completed` flags. They report partial non-atomic commits,
  stay false for simulations, and become true for atomic groups only after the
  shared commit. Lint, transpilation, and local PLAN guard checks passed; ABAP
  Unit was not run. `validate:plan` cannot start because the Windows Node
  launcher rejects WSL 1.

- Cross-plant stock-transfer creation summaries now expose `is_committed`.
  It is true when at least one order committed, including a partial non-atomic
  run, and stays false for test runs and failed atomic groups. Lint,
  transpilation, and local PLAN guard checks passed; ABAP Unit was not run.
  `validate:plan` cannot
  start because the Windows Node launcher rejects WSL 1.

- Production component ATP rows now expose `is_fully_confirmed` for each
  component's incremental confirmed quantity; disabled or not-relevant checks
  remain false. The existing order summary retains its group-level status.
  Lint, transpilation, and local PLAN guard checks passed; ABAP Unit was not
  run. `validate:plan` cannot start because the Windows Node launcher rejects
  WSL 1.

- Cost-center ATP results now expose `is_fully_confirmed` across single-demand,
  shared, dated, location, batch, FEFO, atomic, and independent bulk flows.
  Reservation gates consume the same confirmed-versus-required status returned
  to callers. Lint, transpilation, and local PLAN guard checks passed;
  `validate:plan` cannot start under the current WSL 1 Node launcher. ABAP Unit
  was not run.

- Generic stock-service ATP results now expose `is_fully_confirmed` across
  per-demand, local, plant, dated-plant, and dated-batch results. The flag compares
  confirmed quantity with the complete requested/cumulative quantity, so a
  not-relevant SAP check is not treated as confirmed. Lint, transpilation, and
  local PLAN guard checks passed; `validate:plan` remains unavailable because
  the Windows Node launcher rejects WSL 1. ABAP Unit was not run.

- Sales-order allocation requirements now include per-item and per-schedule
  `require_atp_confirmation`. Reservation methods gate flagged lines against
  cumulative ATP confirmation before writes, with exact schedule-line
  requirements overriding item-wide settings. Bulk reservation skips an order
  whose row-level ATP requirement fails and continues with later orders; its
  global ATP gate still stops the whole batch before writes. Preview rows echo
  the effective flag, and each ATP check reports `is_fully_confirmed` for its
  cumulative request. Lint, transpilation, and the local PLAN guard review
  passed; `validate:plan` could not start because the npm Windows Node launcher
  reports WSL 1 unsupported. ABAP Unit was not run.

- Sales-order preview and reservation APIs now accept per-item all-or-nothing
  requirements. Exact schedule-line settings override item-wide defaults, and
  strict short demands leave shared stock for later demands. Lint and
  transpilation passed. `validate:plan` could not start because the npm Windows
  Node launcher reports WSL 1 unsupported; the new guard conditions were
  checked locally. ABAP Unit was not run.

- Single-order and shared multi-order reservation results now distinguish
  simulation, successful no-op, and committed outcomes with `is_test_run` and
  `is_committed`. Invalid test-run and all-allocation flags are rejected before
  preview or reservation work. Lint and transpilation passed; `validate:plan`
  could not start because npm's Windows Node launcher reports WSL 1 unsupported.
  ABAP Unit was not run.

- Sales-order allocation entrypoints now reject malformed `abap_bool` options
  before order or stock reads, including dated receipts, date modes, ATP, and
  safety-stock protection. FEFO also validates its caller-supplied as-of date
  before reading the order. Lint and transpilation passed. `validate:plan` could
  not start because the npm Windows Node launcher reports WSL 1 unsupported;
  the new input guards were checked locally. ABAP Unit was not run.

- Batch and location selection rows now reject missing keys, duplicate
  item/schedule-line keys, mixed item-wide and schedule-line modes, and batch
  fallback without a preferred location before order or reservation reads.
  Lint and transpilation passed, and the local PLAN guard checks passed;
  `validate:plan` could not start because the npm Windows Node launcher reports
  WSL 1 unsupported. ABAP Unit was not run.

- Sales-order preview and reservation results now return
  order/material/plant/base-unit summaries with demand-line counts and checked
  requested, allocated, and shortfall totals. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.

- Sales-order preview and reservation methods now accept a validated required
  date per unscheduled item. Per-item dates override the scalar fallback, while
  schedule-line dates and MBDAT rules remain in force.
  PLAN validation, lint, and transpilation passed; ABAP Unit was not run.

- Sales-order preview and reservation methods now accept an optional required
  date for open items without schedule lines. It is validated before reads and
  drives date allocation, ATP, and reservation requirements; existing schedule
  dates and MBDAT mode remain in control. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.

- Production readiness summaries now include order-level requested,
  allocated, and shortfall base quantities in addition to component counts.
  Totals use checked arithmetic and reject values outside `MARD-LABST`.
  PLAN validation, lint, and transpilation passed; ABAP Unit was not run.

- Production allocation policies can override a component's open quantity
  for local allocation and ATP while preserving the source RESB component.
  Results expose the effective source-unit quantity, and the override must be
  nonnegative; zero removes demand while keeping the result row and is counted
  separately from stock-covered components in readiness summaries. Disabled
  quantity overrides must be blank. PLAN validation, lint,
  and transpilation passed; ABAP Unit was not run.

- Production allocation policies can override each component's required date.
  The effective date drives local allocation, shelf-life eligibility, projected
  receipt horizons, ATP grouping, and summary dates; results retain the source
  component date and expose `effective_required_date`. Invalid enabled dates and
  nonblank dates on disabled overrides are rejected. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.

- Reservation-keyed production allocation policies now expose priority,
  all-or-nothing allocation, shelf-life requirements, and storage-location or
  batch overrides plus preferred-location fallback through single and bulk
  stock, ATP, and scoped previews. Callers can order fallback locations with a
  shared list or component-keyed ranks; local ranks override the shared order,
  preferred locations stay first, and batch FEFO order remains primary.
  Overrides only affect local previews; a blank value clears that reservation
  scope when its override flag is true. Higher priority wins within a
  required-date and scope-rank group; short all-or-nothing demands leave stock
  for later components. Component results echo the matching input policy and
  report the effective storage location and batch after overrides, plus whether
  allocated splits used a nonpreferred location. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.
- Scoped production demands and reservation-keyed policies now support an
  opt-in preferred-batch fallback. The assigned batch stays first, alternates
  follow FEFO, shelf-life rules filter both, and results report when an
  alternate batch was allocated. Exact-batch behavior remains the default.
  PLAN validation, lint, and transpilation passed; ABAP Unit was not run.
- Production callers can rank alternate batches per component. Expiry remains
  primary; ranks order batches with equal expiry, and unranked batches follow
  ranked ones by batch code. The preferred batch remains first. PLAN validation,
  lint, and transpilation passed; ABAP Unit was not run.
- Production callers can restrict location fallback with
  `it_comp_location_candidates`. The preferred location stays eligible, while
  supplied rows limit alternates; absent rows preserve unrestricted fallback.
  Local location ranks must refer to listed candidates. PLAN validation, lint,
  and transpilation passed; ABAP Unit was not run.
- Production callers can restrict batch fallback with
  `it_comp_batch_candidates`. For components with candidate rows, only those
  alternates and the preferred batch can allocate; absent rows preserve
  unrestricted fallback. Candidate rows and batch priorities are validated
  together. PLAN validation, lint, and transpilation passed; ABAP Unit was not
  run.
- The scoped allocator now indexes validated per-request fallback ranks by
  request and storage location in a hashed table, keeping candidate lookups
  keyed inside location and batch loops. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.
- Reservation-keyed shelf-life policies now flow through single and bulk stock,
  ATP, and scoped production component previews. ATP applies them only to the
  local estimate. Unsupported unissued-STO subtraction or locationless
  automatic receipts for a policy group are rejected. PLAN validation, lint,
  and transpilation passed; ABAP Unit was not run.
- Production `PREVIEW_SCOPED_COMPONENTS` methods now accept optional
  reservation-keyed shelf-life policies and route matching material/plant
  groups through the scoped allocator. Duplicate and unmatched keys are
  rejected. PLAN validation, lint, and transpilation passed; ABAP Unit was not
  run.
- Scoped component demands now support minimum shelf life and a known-expiry
  requirement. The same expiry filter drives group availability, per-demand
  availability, and allocated batch splits; existing defaults preserve the use
  of undated batches. PLAN validation, lint, and transpilation passed; ABAP
  Unit was not run.
- Scoped component allocation now supports per-demand all-or-nothing
  allocation. A short demand receives zero and leaves its eligible stock for
  later demands; production previews keep the option false. PLAN validation,
  lint, and transpilation passed; ABAP Unit was not run.
- Component-scoped allocation now accepts per-demand integer priority. Higher
  priority wins within the same required date and scope rank; input order breaks
  ties, while constrained scopes keep precedence. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.
- Scoped component allocation now selects eligible batch stock by FEFO across
  matching locations for batchless demands and unscoped competing reservations.
  Undated batches follow known expiries. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.
- Component-scoped allocations now retain projected batch and location receipt
  date and source identity in separate balances, return per-demand splits, and
  forward caller-supplied and SAP-derived identities through production
  component checks. PLAN validation, lint, and transpilation passed; ABAP Unit
  was not run.
- Cross-plant exact-batch and standard FEFO allocators now preserve projected
  receipt source metadata through base and date-first splits. Cross-plant output
  uses `receipt_source_plant` to distinguish receipt origin from the supplying
  stock plant; priority, UOM, and ATP adapters retain it. PLAN validation, lint,
  and transpilation passed; ABAP Unit was not run.
- Single-plant exact-batch, standard FEFO, and quality FEFO allocations now
  preserve optional projected batch receipt source identity in separate
  balances and returned splits. PLAN validation, lint, and transpilation
  passed; ABAP Unit was not run.
- Single-plant and cross-plant date allocators now add cumulative allocated
  counters through the checked quantity helper. Totals outside MARD-LABST range
  raise `ZCX_INVALID_STOCK_REQUEST`. PLAN validation, lint, and transpilation
  passed; ABAP Unit was not run.
- Cross-plant standard/date-first FEFO and exact-batch cores now use checked
  high-precision sums for merged receipts, eligible availability, and source
  allocation totals. Out-of-range totals raise
  `ZCX_INVALID_STOCK_REQUEST`. PLAN validation, lint, and transpilation passed;
  ABAP Unit was not run.
- Single-plant location allocators now use checked high-precision sums for
  available totals, allocated summaries, and matching projected receipt
  balances. Totals outside MARD-LABST range raise
  `ZCX_INVALID_STOCK_REQUEST`. PLAN validation, lint, and transpilation passed;
  ABAP Unit was not run.
- Single-plant exact-batch, standard FEFO, and quality FEFO allocators now use
  checked high-precision sums for merged projected receipts, available totals,
  and allocation summaries. Out-of-range totals raise
  `ZCX_INVALID_STOCK_REQUEST`. PLAN validation, lint, and transpilation passed;
  ABAP Unit was not run.
- Date-first unrestricted-location splits now expose `available_from_date`.
  Projected balances remain separate by receipt date, posted stock keeps the
  field initial, and the UOM and dated ATP adapters preserve the date. PLAN
  validation, lint, and transpilation passed; ABAP Unit was not run.
- Cross-plant location splits now keep projected receipt dates separate from
  posted source-plant stock and report `available_from_date` through base,
  priority, dated, unit-aware, and ATP results. PLAN validation, lint, and
  transpilation passed; ABAP Unit was not run.
- Location receipt inputs now accept optional source type, document, item,
  source plant, and schedule line metadata. Date-first and cross-plant location
  splits preserve different source identities separately and echo the metadata.
  PLAN validation, lint, and transpilation passed; ABAP Unit was not run.
- Batchless WBS location previews now accept caller-resolved projected
  location receipts through base, priority, date-first, and ATP variants.
  Receipts are scoped to WBS/material/plant and gated by each demand's
  effective location date; duplicate receipt totals use checked high-precision
  addition. Tests cover date gating, WBS isolation, adapter forwarding,
  unmatched input, and overflow.
- WBS FEFO and transfer previews now accept caller-resolved projected batch
  receipts through base, priority, date-first, and ATP variants. Receipts are
  scoped to WBS/material/plant and become eligible when the demand's effective
  FEFO date reaches the receipt date; expiry, location, and quantity-overflow
  checks still apply. Regressions cover future-date gating, WBS isolation,
  adapter forwarding, and invalid WBS/expiry rejection before stock reads. The
  caller-resolved supply boundary is documented in `README.md` and
  `ANOMALIES.md`. Full `npm test` passed: PLAN validation, 0 lint issues across
  247 files, transpilation, and ABAP Unit.
- Stock-transfer-order pair validators now accumulate demand, plant, batch,
  location, and dated ATP totals in `decfloat34`. This prevents malformed split
  groups from overflowing while checking them against bounded preview or ATP
  quantities. Added a dated-batch ATP overflow regression and PLAN guards.
- The plant-transfer overflow regression now covers both one-step and
  two-step posting entry points, confirming that neither reaches the movement
  adapter with a split total that exceeds its allocation summary.

## 2026-10-17

- WBS FEFO transfer previews now support per-demand `require_full_quantity`
  across base, priority, and dated demands. Fresh transfer posting checks keep
  strict rows all-or-none while allowing other rows to transfer partial stock;
  they compare allocation summaries as well as batch splits, including zero-
  split rows. Direct transfer validation rejects forged partial strict
  allocations. Added preview, mixed posting, changed-snapshot, and invalid
  allocation regressions plus PLAN guards and README guidance.
- WBS location transfer previews and posting adapters now preserve per-demand
  `require_full_quantity` across base, priority, and date-first flows. A short
  strict row gets no location splits while partial rows may proceed when the
  shared option is false; posting validation rejects forged partial strict
  summaries, and both allocation summaries and location splits are compared
  across the fresh stock snapshots. Added mixed-row, stale-snapshot, and forged
  allocation regressions plus PLAN guards and README guidance.
- WBS batchless location issue now preserves per-demand `require_full_quantity`
  through base, priority, and date-first posting rechecks. With global partial
  issue enabled, short strict rows leave stock for eligible partial rows; the
  returned summaries echo each effective rule. Updated mixed-row issue
  regressions, PLAN guards, README, and anomaly notes.
- WBS batchless location reservations now preserve per-demand
  `require_full_quantity` across base, priority, and date-first flows. Short
  strict rows leave stock available to partial rows; fresh checks compare full
  allocation summaries and splits so zero-split rows still detect changed
  availability. Added mixed-row and stale-summary regressions, plus PLAN and
  documentation updates.
- WBS FEFO reservations now preserve per-demand `require_full_quantity` in
  base, priority, and date-first flows. Strict short rows leave eligible stock
  for partial rows; fresh checks compare full allocation summaries and batch
  splits so changed availability on zero-split rows blocks writes. Added mixed
  row and stale-summary regressions, plus PLAN guards and documentation.
- Direct WBS batch and location preview reservations now validate summary
  quantity identities and per-row `require_full_quantity`, rejecting malformed
  or partially allocated strict rows before writes. Added adapter regressions
  and PLAN guards for the shared validator.
- Direct WBS reservation split totals and WBS/date/material stock-key totals
  now accumulate in `decfloat34`. The shared adapter rejects totals above the
  `MARD-LABST` range before unit conversion or reservation writes; regressions
  cover overflow within a request and across requests sharing one stock key.
- Goods-movement allocation validators now sum batch and location splits in
  `decfloat34` across cost-center, WBS, sales-order, and quality-stock issue
  paths. Forged overfull split sets now reach the controlled mismatch rejection
  before any movement API call. Added cost-center and WBS overflow regressions
  and PLAN guards.
- Dated location and FEFO ATP transfer rechecks now accumulate grouped demand
  and split totals in `decfloat34`. Overfull supplied source or batch/location
  quantities fail through the movement validation exception before posting;
  regressions cover both transfer paths and PLAN guards protect the totals.
- One-step and two-step plant transfer validators also accumulate their
  per-request location and batch totals in `decfloat34`; an overfull caller
  split set now reaches the normal mismatch rejection before movement creation.
  Added a 12-billion split regression and a PLAN guard.

- Cost-center location, exact-batch, and FEFO issue adapters now enforce each
  preview row's `require_full_quantity` setting when global partial issue is
  enabled. A valid strict row with zero allocation can coexist with rows that
  have issueable splits. Added partial-forgery and mixed-row regressions plus
  PLAN guards and README guidance.
- Added `issue_cc_locations_by_date` to post dated cost-center location preview
  splits. It verifies every split repeats the preview's required date and
  priority, preserves request scopes and row-level full-quantity handling, and
  delegates item and split validation to the shared location issue adapter.
  Regressions cover posting, stale date/priority metadata, and strict partial
  rejection with global partial issue enabled.
- Date-first exact-batch previews now have regression coverage for grouped ATP
  checks at each effective required date alongside row-level strict allocation.
  README and PLAN guards document and protect the forwarding behavior. The full
  `npm test` pipeline passed: PLAN validation, 0 abaplint issues across 247
  files, transpilation, and ABAP Unit.

- Added `preview_cc_batches_by_date` to allocate exact-batch demand by earliest
  required date, then descending priority on the same date, while returning
  rows in caller order. Projected batch receipts respect their receipt date;
  invalid dates fail before stock reads. Strengthened regressions for date and
  priority ordering and no-read validation. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added `reserve_cc_atomic_by_date` to preallocate and create a cost-center
  reservation group by ascending required date and descending same-date
  priority. Reservation API calls follow that order while result items return
  in caller order; invalid dates are rejected before stock reads. Tests verify
  request order, output order, group commit, and no-read rejection. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and ABAP Unit.
- Added `reserve_cc_bulk_by_date` with independent commits in ascending
  required-date order and descending priority for same-date requests. The
  wrapper returns per-request results in caller order and rejects malformed
  dates before reads. Regressions verify API call order, independent commits,
  result ordering, and no-read validation. Full `npm test` passed with PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Exact-batch cost-center issues now carry required date, minimum shelf life,
  and undated-batch policy from previews into the posting check. The movement
  adapter rejects splits that are ineligible by the later required or posting
  date.
  Added a required-date expiry regression and explicit known-good issue cases;
  full `npm test` passed with PLAN validation, 0 abaplint issues across 247
  files, transpilation, and ABAP Unit.
- Extended project WBS batchless transfer previews and 415/Q posting flows with request-specific location ranks across base, priority, and dated variants. ATP adapters forward the ranks; posting methods map ranks through internal IDs and preserve them in the fresh stock recheck. Added conflicting shared-order regressions for previews, ATP, duplicate caller IDs, and movement items, plus README/ANOMALIES updates and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Extended project WBS FEFO transfer previews with request-specific location ranks after expiry and batch ordering, including priority, dated, and ATP variants. The three 415/Q posting flows map caller ranks to internal IDs and repeat them for the fresh stock snapshot. Added ATP split, duplicate-ID base transfer, priority transfer, and dated transfer regressions; updated README, ANOMALIES, and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Carried request-specific FEFO location ranks through all four quality posting rechecks. Fresh recomputation now uses the same rank rows as the caller's preview for release/send, including priority and UOM paths. Added location-split regressions using identical batch/expiry ties, README/ANOMALIES notes, and PLAN validation coverage. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added request-specific location ranks to the base WBS project FEFO preview, ATP adapter, and `RESERVE_WBS_FEFO` fresh check. Matching batch/expiry locations use local rank, while invalid IDs and duplicate request/location rows fail before UOM or stock reads. Added preview, pre-read rejection, and end-to-end reservation split regressions, README/ANOMALIES notes, and a PLAN guard. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Extended WBS FEFO request-specific location ranks through the priority preview, ATP wrapper, and priority reservation recheck. The wrappers map each caller rank row to internal IDs, preserving the same local order for repeated request IDs; regressions cover duplicate-ID splits across locations through reservation. Updated README, ANOMALIES, and PLAN guard. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added request-specific location ranks to dated WBS FEFO preview and ATP adapter, and preserved them across `RESERVE_WBS_FEFO_BY_DATE` preview/recheck. Caller ranks are mapped to internal rows when request IDs repeat. Added dated preview and end-to-end reservation split regressions, README/ANOMALIES notes, and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added request-specific storage-location ranks to batchless WBS location previews, dated previews, ATP adapters, and dated reservations. The dated wrappers remap repeated caller IDs to internal rows; ranks override shared order, and unranked locations remain deterministic. Added split-order, duplicate-ID ATP/reservation, and pre-read unknown-ID regressions, plus docs and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Extended per-request location ranks through priority ordered batchless WBS previews, ATP, and `RESERVE_WBS_LOCATION_PRIORITY` rechecks. The priority wrapper maps each caller rank to internal rows for repeated IDs; tests cover rank order changes and duplicate-ID reservations. Updated README, ANOMALIES, and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Carried request-specific location ranks through `ISSUE_PROJECT_WBS_LOCATION`, priority, and dated issue flows. Each adapter maps caller rows to internal IDs, then uses those ranks for both previews before movement posting. Added duplicate-ID split and posting assertions for each flow, documentation, and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added request-specific location ranks to unrestricted cross-plant allocation and dated location allocation. Local ranks choose locations within each source plant, retaining caller plant order; rank checks run before stock reads or UOM conversion and flow through priority and ATP adapters. Added wrapper and invalid-ID regressions, documentation, and PLAN guard coverage. Full `npm test` passed: PLAN validation, zero abaplint issues across 247 files, transpilation, and ABAP Unit.
- Extended request-specific location ranks to cross-plant FEFO and exact-batch allocation. FEFO ranks break ties within source plant, expiry, and batch; exact-batch ranks order locations within each source plant while preserving caller plant order. Added validation before stock or UOM reads, forwarding through dated/UOM/priority/ATP variants, regression coverage, README/ANOMALIES notes, and PLAN guard checks.
- Extended request-specific location ranks to exact-batch and single-plant unrestricted and quality FEFO allocation. FEFO still sorts expiry and batch first, then uses per-request ranks within matching lots; UOM, priority, and ATP wrappers forward or remap the rows. Added base/UOM/priority/ATP split coverage and invalid-ID no-read coverage, plus README, anomaly, and PLAN guard updates. Full `npm test` passed: PLAN validation, zero abaplint issues across 247 files, transpilation, and ABAP Unit.
- Extended request-specific location ranks through priority-ordered, dated, and ATP location allocation. Dated UOM validates ranks before conversion reads; dated ATP wrappers forward the same rows, and projected-receipt allocation applies ranks only to locations available by each request date. Added priority/base/UOM/ATP forwarding coverage, invalid-ID/no-read coverage, docs, and PLAN guard checks. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added request-specific location ranks to general base-unit and UOM location allocation. The local order overrides the shared order per request; selected-location fallback stays first, then ranked and unranked locations sort deterministically. UOM validation happens before conversion reads and maps ranks through internal request IDs. Added distinct-order and invalid-input/no-read regressions, docs, and PLAN guard coverage. Full `npm test` passed: PLAN validation, zero abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added request-specific storage-location ranks to both sales-order FEFO preview forms and the base/UOM issue rechecks. Local rows override the shared tie order for their request; selected-location fallback remains first, then ranked and unranked locations sort deterministically. Added distinct per-request and unranked-location allocation coverage, invalid-rank/duplicate/unknown-ID checks, and docs/PLAN guard updates. Full `npm test` passed: PLAN validation, zero abaplint issues across 247 files, transpilation, and ABAP Unit.
- Carried shared and request-specific location order through direct base/UOM sales-order FEFO reservations and both fresh reservation rechecks. Added split-order assertions for both direct and rechecked reservation paths; full `npm test` passed again with PLAN validation, zero abaplint issues across 247 files, transpilation, and ABAP Unit.
- Added caller-defined storage-location tie priority to both sales-order FEFO preview forms and the rechecking issue service. Expiry and batch order remain primary; listed locations choose the split order for matching lots, then unlisted locations use ascending code. A posting regression caught and fixed an index collision between the priority lookup and the stock-balance row index. Added base, UOM, and posting-path regressions, duplicate-priority validation, README, anomaly, and PLAN guard coverage. Full `npm test` passed: PLAN validation, zero abaplint issues across 247 files, transpilation, and ABAP Unit.
- Extended `TRANSFER_WBS_FEFO` to preserve repeated caller IDs through unique internal row IDs, both expiry-aware previews, and 415/Q movement validation. Added a duplicate-ID batch-transfer regression and updated README, anomaly, and PLAN guard coverage.
- Extended `TRANSFER_WBS_BY_LOCATION` to preserve repeated caller request IDs with unique internal row IDs through both location previews and 415/Q validation. Added a duplicate-ID transfer regression and updated README, anomaly, and PLAN guard coverage.
- Extended `ISSUE_PROJECT_WBS_LOCATION` to preserve repeated caller request IDs through unique internal row IDs, both location snapshots, and WBS movement validation. Added a duplicate-ID posting regression and updated README, anomaly, and PLAN guard coverage.
- Extended `ISSUE_PROJECT_WBS_FEFO` to preserve repeated caller IDs with unique internal row IDs through both batch previews and 221/Q movement validation. Added a duplicate-ID FEFO posting regression and updated README, anomaly, and PLAN guard coverage.
- Added `ISSUE_PROJECT_WBS_LOC_DATE` for batchless project WBS issue, ordering demands by required date and same-date priority. It rechecks date, priority, allocation and location splits, preserves duplicate caller IDs through internal row IDs, and posts 221/Q only when the snapshots match. Added ordered posting and stale-snapshot regressions, docs, and a PLAN guard.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,025 ABAP Unit methods.
- Added `ISSUE_PROJECT_WBS_LOC_PRIORITY` to issue project WBS stock by descending demand priority and preferred storage location. It validates two ordered previews, preserves duplicate caller IDs through internal row IDs, and posts 221/Q only when snapshots match. Added priority, duplicate-ID, and stale-snapshot regressions plus README, anomaly, and PLAN guard coverage.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,019 ABAP Unit methods.
- Added ISSUE_PROJECT_WBS_LOCATION to issue batchless project WBS stock
  from the location preview. It forwards location ordering, scope, and
  reservation cutoff, compares a fresh second snapshot, and posts 221/Q only
  when allocations and location splits still match. Added prioritized posting
  and stale-location regressions, docs, and a PLAN guard. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  2,017 ABAP Unit methods.


- Cost-center FEFO issue carries the shared undated setting from its preview
  and validates each split against its effective date, shelf life, and row
  policy before posting. Strict rows reject undated splits. Added opt-in and
  strict-rejection regressions plus README, anomaly, and PLAN guard coverage.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and the ABAP Unit runner.

- Added `ISSUE_PROJECT_WBS_FEFO_PRIO` to post priority-ordered project WBS
  FEFO issues, including the existing optional date-first ordering mode. The
  adapter rechecks the priority allocation, preserves repeated caller IDs with
  internal row IDs, and posts 221/Q only when both snapshots match. Added
  priority, date-order, duplicate-ID, and stale-snapshot regressions plus docs
  and a PLAN guard. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 2,015 ABAP Unit methods.

- Added `ISSUE_PROJECT_WBS_FEFO_BY_DATE` for date-first project WBS goods
  issue. It preserves required date and priority during snapshot comparison,
  supports repeated caller request IDs through internal IDs, and restores the
  caller values in the returned preview. Added ordering and stale-snapshot
  regressions, README and anomaly documentation, and a PLAN guard. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 2,013 ABAP Unit methods.

- Added `ISSUE_PROJECT_WBS_FEFO` for WBS goods issue. It previews twice and
  compares allocation summaries, expiry-aware batch splits, and WBS assignment
  before posting 221/Q; changed snapshots return a warning without calling the
  movement API. Added posting and stale-snapshot regressions, README and anomaly
  documentation, and a PLAN guard. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 2,011 ABAP Unit
  methods.

- FEFO STO creation now rechecks each selected split's echoed as-of date,
  effective undated-stock setting, minimum shelf life, and demand row policy
  before any PO write. Stock previews now carry the effective expiry inputs
  through base, priority, dated, and unit conversion paths. Added regressions
  for strict undated rejection and insufficient shelf life, plus README,
  anomaly, and PLAN guard coverage.

- Added per-demand known-expiry and undated-batch overrides to WBS FEFO base,
  priority, and date requests, including ATP and reservation wrappers. Row flags
  flow through internal request IDs and allocation summaries/batch splits;
  reservations verify the effective undated policy during their fresh preview.
  Positive shelf-life minimums still exclude undated stock, and conflicting row
  flags fail before conversion or stock reads. Added mixed-policy, priority,
  dated, and reservation regressions, docs, and a PLAN guard. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and the ABAP Unit runner.

- Extended WBS FEFO row policies to project-stock transfer previews and
  movement posting. Base, priority, dated, and ATP paths preserve the row
  flags through internal request IDs; fresh transfer snapshots compare the
  echoed policy before posting. Added undated opt-in, conflict-before-read,
  and priority/date echo regressions plus README, anomaly, and PLAN guards.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247
  files, transpilation, and the ABAP Unit runner.

- Added per-demand undated-stock policy overrides to sales-order FEFO previews
  and reservations. Base-unit and UOM requests can opt in to undated batches
  when the shared option is false, while `require_known_expiry` keeps a row
  strict when the shared option is true. Conflicting flags fail before stock
  reads; summaries and splits echo the policy, and reservation, goods-issue,
  and recheck paths validate or compare it. Added direct, UOM, reservation, and
  goods-issue regressions, documentation, and PLAN guards. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and the ABAP Unit runner.

- Added per-demand `require_known_expiry` and `allow_undated_batches` overrides
  to cost-center exact-batch and FEFO allocation. Multi-demand previews, dated
  FEFO, atomic and bulk reservations, and single-request preview/reservation
  paths forward the settings and echo them in summaries and batch splits.
  Conflicting or inapplicable flags fail before UOM conversion or stock reads.
  Added mixed-policy, wrapper, and early-rejection regressions, documentation,
  and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 2,008 ABAP Unit methods.

- Added per-demand `allow_undated_batches` as an override for cross-plant
  exact-batch allocation. Rows can use undated current or projected stock when
  the shared option excludes it; contradictory row flags fail before UOM or
  stock reads. Summaries and batch/location splits echo the policy across base,
  dated, unit, priority, and ATP paths. Added wrapper, ATP, and early-rejection
  regressions, README/ANOMALIES documentation, and PLAN guards. Full `npm test`
  exited successfully: PLAN validation, abaplint, transpilation, and the ABAP
  Unit runner.

- Added `allow_undated_batches` as a per-demand override to single-plant
  exact-batch allocation. Rows can opt into undated current or projected stock
  when the shared option excludes it; contradictory row flags fail before UOM
  or stock reads. Summaries and batch splits echo the setting across base, UOM,
  priority, and ATP paths. Added wrapper and early-rejection regressions,
  README/ANOMALIES documentation, and PLAN guards. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  2,008 ABAP Unit methods.

- Added per-demand known-expiry and undated-stock overrides to single-plant
  FEFO and quality FEFO. Row policies flow through base, unit, priority, and ATP
  methods, are echoed in summaries and batch splits, and constrain safety-stock
  eligibility to stock some compatible demand can use. Added mixed-policy,
  quality-stock, wrapper, and early-rejection regressions, README/ANOMALIES notes,
  and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 2,008 ABAP Unit methods.

- Added per-demand `require_known_expiry` to single- and cross-plant exact-batch
  allocation across base, date, unit, priority, and ATP variants. Strict rows
  skip undated current or projected stock while inclusive rows can still use
  it; summaries and successful location splits echo the policy. Added mixed
  policy and wrapper regressions, README/ANOMALIES notes, and PLAN guards. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 2,008 ABAP Unit methods.

- Added per-demand `allow_undated_batches` across cross-plant FEFO base,
  dated, unit, priority, and ATP variants. A row can opt into undated stock
  when the call-wide setting excludes it; contradictory row flags are rejected.
  Shared safety-stock protection now considers undated stock only when an
  eligible demand can use it. Ordinary allocators reject FEFO-only expiry flags
  before stock reads or UOM conversion. Added mixed-policy and early-rejection
  regressions, README/ANOMALIES documentation, and PLAN guards. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 2,008 ABAP Unit methods.

- Added per-demand known-expiry filtering across cross-plant FEFO base, date,
  unit, priority, and ATP variants. Result summaries and batch splits echo the
  policy, so mixed requests can exclude undated stock selectively.
- Added direct STO adapters for base, priority, unit-aware, UOM, ATP, batch,
  FEFO, and dated cross-plant allocation results, including the base dated
  FEFO adapter for `ALLOCATE_PLANTS_FEFO_BY_DATE`, plus the unit-aware FEFO
  adapter for undated `ALLOCATE_PLANTS_FEFO_IN_UNITS` results. Base-only results use a
  caller material/base-unit map; the adapters preserve exact batches,
  source locations, priorities, and allocation dates through the existing
  validated pair-order workflows. Added order-mapping and missing/duplicate
  unit-map regressions, README/anomaly documentation, and PLAN guards. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 2,008 ABAP Unit methods.

- Added `CREATE_FOR_UOM_ATP_PLANT_PAIRS` for direct STO creation from
  `ALLOCATE_PLANTS_UOM_ATP_PRIO` output. It requires full current-date
  confirmation by material/source plant/base unit, preserves issuing location
  splits, and assigns a caller-supplied delivery date. Test coverage includes
  base-unit order mapping and rejection of short ATP before writes. Added README
  and anomaly notes plus a PLAN guard. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 2,007 ABAP Unit
  methods.

- Added `CREATE_FOR_UOM_FEFO_PAIRS` for direct STO creation from
  `ALLOCATE_PLANTS_FEFO_UOM_PRIO` results. It applies the caller's delivery
  date and carries priority metadata, FEFO batches, issuing locations, and
  source-unit quantities into the validated pair workflow. Added an end-to-end
  BOX item regression, documentation, and a PLAN guard. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  2,006 ABAP Unit methods.

- Added `CREATE_FOR_UOM_BATCH_PAIRS` for direct STO creation from
  `ALLOCATE_PLANTS_BATCH_UOM_PRIO` results. It unwraps priority metadata while
  retaining exact batches, issuing locations, and alternative-unit quantities.
  The BOX item regression checks the order quantity and unit after mapping.
  README and anomaly notes plus a PLAN guard cover the adapter. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 2,005 ABAP Unit methods.

- Added `CREATE_FOR_UOM_FEFO_ATP_PAIRS` for direct STO creation from
  `ALLOCATE_PLANTS_FEFO_UOM_ATP` results. It unwraps priority metadata while
  retaining exact FEFO batches, issuing locations, and source-unit quantities,
  then delegates to the existing ATP validation and atomic pair creation path.
  Added a BOX item regression, README and anomaly documentation, and a PLAN
  guard. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247
  files, transpilation, and all 2,004 ABAP Unit methods.

- Added `CREATE_FOR_UOM_ATP_BATCH_PAIRS` for direct STO creation from
  `ALLOCATE_PLANTS_BATCH_UOM_ATP` results. It unwraps priority metadata while
  retaining exact batch, source location, base quantities, and source-unit
  quantities, then reuses the same per-date ATP checks and pre-write validation.
  The regression verifies an alternative-unit item remains in BOX through
  order creation. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 2,003 ABAP Unit methods.

- Updated `CREATE_FOR_ATP_BATCH_PAIRS` to validate exact-batch ATP groups by
  each demand's `as_of_date`, matching the cross-plant allocator. Blank dates
  default to today; malformed dates, missing groups, and mismatched confirmations
  are rejected before order writes. Added successful multi-date handoff and
  mismatch regressions, documented the behavior, and guarded it in PLAN
  validation. Full `npm test` passed: PLAN validation, 0 abaplint issues across
  247 files, transpilation, and all 2,002 ABAP Unit methods.

- Aligned base-unit cross-plant exact-batch ATP with the UOM ATP path: checks
  now group by each demand's `as_of_date`, with blank dates defaulting to today.
  Added a regression for separate date groups and invalid-date rejection before
  reads, and updated the ATP contract docs and PLAN guard. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 2,000 ABAP Unit methods.


- Added per-demand `as_of_date` to cross-plant exact-batch UOM demands. The
  priority allocator now retains caller dates through base-unit conversion,
  validates bad dates before UOM reads, and its ATP wrapper groups checks by
  the demand date. Tests cover date-over-priority consumption, same-date
  priority, caller-order results, bad-date rejection, and separate ATP groups.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,999 ABAP Unit methods.


- Added opt-in date-first ordering to exact-batch priority allocation for base
  and UOM demands, plus the UOM ATP wrapper. Earlier per-demand `as_of_date`
  values now allocate first, priority breaks same-date ties, and output remains
  in caller order; ATP uses its shared date for rows without one. Tests cover
  scarce batch splits, missing-date rejection before reads, and grouped ATP.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,998 ABAP Unit methods.


- Extended opt-in date-first ordering to WBS project-stock FEFO previews and source-WBS transfer previews, including ATP wrappers and TRANSFER_WBS_FEFO_PRIORITY posting rechecks. Tests cover date-over-priority ordering, same-date priority, caller-order results, missing-date rejection before repository reads, and movement posting with the same order on both snapshots. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,997 ABAP Unit methods.

- Added opt-in date-first ordering to priority FEFO allocation, ATP, and quality posting rechecks. Earlier per-demand FEFO dates now take precedence, priority breaks same-date ties, and returned rows remain in caller order; date mode rejects missing dates before stock reads. Added base and UOM allocation, ATP, and movement-posting regressions, documented the option, and guarded the feature in PLAN validation. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,995 ABAP Unit methods.

- Added `ALLOCATE_QUALITY_UOM_ATP_PRIO` to combine priority-ordered quality FEFO allocation with grouped plant ATP diagnostics. It forwards location scopes, projected quality receipts, expiry filters, and full-quantity policy; the regression verifies that the higher-priority request consumes scarce quality stock first while results return in caller order. Documented that ATP remains diagnostic and may not cover quality-inspection stock. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,992 ABAP Unit methods.

- Checked packed totals in non-dated cross-plant allocation: source-location sums, same-location stock plus projected receipts, qualifying receipt totals, and per-plant availability now use the checked quantity helper. Added two maximum-value regressions and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,989 ABAP Unit methods.

- Preserved individual open RESB rows in bulk sales-order reservation reads instead of summing same-date rows into packed `RESB-BDMNG`. Consumers reconcile separate rows without an overflowing intermediate. Added a two-maximum-reservation regression and updated the grouped-row contract test. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,987 ABAP Unit methods.

- Hardened confirmed PO receipt totals in single-request and bulk dated allocation. Stock and each qualifying receipt now combine through the checked `decfloat34` helper before MARD-LABST conversion. Added two maximum-value regressions and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,986 ABAP Unit methods.

- Checked dated cross-plant availability totals and per-plant confirmed receipt additions before narrowing to MARD-LABST. Overflow now raises `zcx_invalid_stock_request`; added maximum-value regressions and a PLAN guard. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,984 ABAP Unit methods.

- Hardened sales-order ATP previews against daily and cumulative demand overflow. Both single-order and multi-order previews now add grouped quantities in `decfloat34` and reject totals outside MARD-LABST before calling SAP ATP. Added two maximum-value regressions and PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,982 ABAP Unit methods.

- Hardened WBS reservation coverage grouping: project stock, reservations,
  and available stock now aggregate in `decfloat34` before checked conversion
  to `MSPR-PRLAB`. Coverage and available-stock UOM reads now reject overflow
  and nonzero quantities rounded to zero. Added maximum-value and rounding
  regressions plus PLAN guards. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,980 ABAP Unit
  methods.
- Replaced packed arithmetic in production-order ATP release, cost-center
  reservation validation, all plant/two-step goods movement allocation checks,
  and sales-order FEFO reservation validation with `decfloat34` comparisons.
  Added maximum-quantity regressions and PLAN guards; invalid totals are
  rejected before release, reservation, or movement API calls. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,975 ABAP Unit methods.
- Extended checked aggregation to production-component ATP daily and cumulative requests and monthly shortage groups. Added regressions for same-date and cross-date ATP overflow and monthly shortage overflow.
- Hardened production-order ATP summaries: grouped component and order quantities now use checked high-precision totals, rejecting results outside MARD-LABST instead of overflowing. Added regressions for component and order-level summaries plus a PLAN guard.
- Added checked high-precision accumulation to ATP allocation groups, daily demand totals, and cumulative requests. Totals beyond MARD-LABST now raise the stock-request exception before an SAP ATP call; added an overflow regression and PLAN guard.
- Preserved individual open RESB rows in bulk location and batch status reads
  so their high-precision calculators can net large reservation sets without
  an overflowing `RESB-BDMNG` intermediate. Added SQLite regressions for two
  maximum reservations at both scopes and a PLAN guard. Full npm test passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,966 ABAP Unit methods. Target SAP SQL result behavior remains to be checked.
- Hardened scalar and bulk stock-transfer location totals. MARD rows now
  accumulate in `decfloat34`, then convert with an explicit range check;
  overflow raises `ZCX_INVALID_STOCK_REQUEST` through the repository
  interface. Added two-maximum-balance coverage and a PLAN guard. Full npm
  test passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,965 ABAP Unit methods. Target SAP conversion
  behavior remains to be checked.
- Checked repeated projected receipt additions to scoped component
  location and batch balances. Out-of-range aggregates now raise the stock
  request exception; added a two-maximum-receipt regression and a PLAN
  guard. Full npm test passed: PLAN validation, 0 abaplint issues across
  247 files, transpilation, and all 1,964 ABAP Unit methods.
- Hardened scoped component allocation sums. Batch totals, demand scope
  availability, and shared group availability now accumulate in high
  precision before location clamping and checked result conversion. Added
  a regression with two maximum batch balances under one location and a
  PLAN guard. Full npm test passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,963 ABAP Unit methods.
- Hardened sales-order stock snapshots against aggregate overflow. The
  service now sums unrestricted stock and eligible open reservations in
  high precision, then rejects totals outside the snapshot fields. Added
  stock and reservation boundary coverage plus a PLAN guard. Full npm test
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,962 ABAP Unit methods.
- Moved location reservation sums and batch negative-stock carry to
  decfloat34 so multiple large rows can be netted without intermediate
  quantity overflow. Added calculator regressions where the internal total
  exceeds SAP quantity range but the final available result is zero. Added
  PLAN guards and documented the boundary. Full npm test passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all
  1,961 ABAP Unit methods.
- Fixed plant stock-status reads to retain LGORT in the bulk projection, so
  equal balances from separate locations are not deduplicated. Stock category
  and reservation totals now accumulate in high precision with checked SAP
  quantity conversion. Scalar unrestricted availability also nets MARD and
  open RESB quantities in high precision and checks the final result. Added
  regressions for identical maximum balances, stock overflow, reservation
  overflow, and the zero clamp. Full npm test passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,959 ABAP Unit
  methods.
- Hardened plant-date availability aggregation in the stock repository.
  Storage stock, reservations, receipts, and outgoing transfers now net in
  high precision before the final MARD-LABST conversion; unrepresentable
  results raise the request exception. Added a boundary regression and updated
  the repository contract and PLAN guard. Full npm test passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,957
  ABAP Unit methods.
- Hardened quota-split PR preparation against oversized candidate proposals.
  A split that exceeds MARD-LABST now raises the request exception before
  request submission. Added public preparation coverage and a PLAN guard. Full
  npm test passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,956 ABAP Unit methods.
- Hardened projected-receipt base-unit conversion in the stock repository.
  Oversized values and nonzero amounts that round to zero now raise the stock
  request exception across PO, scheduling agreement, STO, production, PR,
  planned-order, and confirmed-PO receipts. Added public-read regression
  coverage and a PLAN guard. Full npm test passed: PLAN validation, 0 abaplint
  issues across 247 files, transpilation, and all 1,955 ABAP Unit methods.
- Hardened production-component replenishment quantity conversion. Aggregate
  and receipt quantities that exceed MARD-LABST now raise the request
  exception, including lot-multiple rounding beyond the field limit. Added
  regression coverage and a PLAN guard. Full npm test passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,954 ABAP Unit
  methods.
- Hardened purchase-order suggestion preparation for purchasing-unit overflow.
  It now raises the request exception before any BAPI call; added a public
  preparation regression and PLAN guard. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all
  1,953 ABAP Unit methods.
- Hardened stock-transfer quantity conversion for unit-aware inquiries.
  Overflow and nonzero base quantities that round to zero now raise the
  request exception; added public inquiry coverage for both boundaries and a
  PLAN guard. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,952 ABAP Unit methods.
- Hardened replenishment PR purchasing-unit conversion. Overflow and nonzero
  base quantities that round to zero now raise the request exception before
  any BAPI call; added preparation regressions and a PLAN guard. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,951 ABAP Unit methods.
- Hardened sales-order allocation result conversion. Overflowing sales-unit
  quantities and nonzero base quantities that round to zero now raise the
  stock-request exception. Added public preview regressions for both cases and
  PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,950 ABAP Unit methods.
- Added a checked base-unit converter to production component stock and ATP
  previews. Overflow and nonzero reservation quantities that round to zero
  now fail before stock reads; added a public preview regression and PLAN
  guard, and documented the boundary. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all
  1,949 ABAP Unit methods.
- Routed stock-service alternative-unit demand conversions through one checked
  converter. It rejects overflow and nonzero source quantities that round to
  zero at stock precision before reading stock. Added a public allocation
  regression and PLAN guard. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,948 ABAP Unit
  methods.
- Netted negative unrestricted MCHB batch balances against positive batches
  in stable location/batch order so batch availability reconciles with the
  plant total. Added direct calculator coverage and SQLite scalar/bulk checks
  that compare batch availability with plant-level MARD status; the negative
  batch sorts after positive stock. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,945 ABAP Unit methods.
- Fixed location availability when an active reservation names a storage
  location with no MARD row. The open demand now joins the existing
  ascending-location distribution, keeping it in the plant-level net total.
  Added a calculator regression and SQLite repository coverage. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,944 ABAP Unit methods.
- Reconciled location availability with plant totals when negative location
  stock is allowed. Location deficits are carried across positive locations so
  the location results do not exceed plant-level net stock. Added a regression
  for -10 at one location and +100 at another; full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,943
  ABAP Unit methods.
- Made all shared material-unit conversion paths return an unsuccessful result
  when the converted quantity overflows `MARD-LABST` or a nonzero source rounds
  to zero. Added coverage for direct sales-unit ratios, MARM lookups, reverse
  conversion, and sales-order rejected-item mapping. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,942 ABAP Unit methods. Target-SAP quantity precision remains an anomaly to
  verify.
- Hardened `SIMULATE_SPLIT_QUOTA` duplicate-item validation: repeated rows for
  one quota item must agree on minimum/maximum lot sizes and its once-only flag.
  Added a regression with conflicting duplicate values. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,939 ABAP Unit methods.
- Fixed split-quota failure handling: when all assigned quota items are already
  at `MAXMG`, or every proposed share would reach the maximum, the preview now
  raises `zcx_invalid_stock_request` instead of returning an empty split list.
  Added regressions for both exhausted stored quantities and un-coverable
  proposed shares. Updated the quota-filter expectation for the vendor-specific
  active-quota flag. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and ABAP Unit.
- Fixed `has_active_vendor_quota` so a candidate is marked only when its own
  vendor has an in-date, external-supplier quota item with a positive quota.
  Previously, any active arrangement for the material and plant marked every
  vendor candidate as having a quota. Updated the internal match field and
  documented the result contract in README.
- Fixed reservation aggregation so an over-withdrawn RESB item cannot
  cancel another item's open demand. Added a shared
  `max(BDMNG - ENMNG, 0)` calculator and applied it before aggregation in
  plant, date, storage-location, batch, and sales-order stock reads.
  Added SQLite regressions for over-withdrawn rows across scalar and bulk
  paths, and PLAN guards for the shared clamp and aggregation readers.
  Updated README and `ANOMALIES.md` with the behavior and target-SAP
  query limitation. Full `npm test` passed: PLAN validation, 0 abaplint
  issues across 247 files, transpilation, and all 1,936 ABAP Unit methods.
- Extended the WBS project-reservation repository to use the shared
  per-item open-quantity clamp. Added over-withdrawn RESB data to its
  direct SQLite tests, checking that open reservation reads exclude it while
  active-item inquiry retains the source quantities. PLAN validation now
  guards both WBS query paths and the regression fixture. Corrected the
  project-stock documentation to reflect direct SQL coverage. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,936 ABAP Unit methods.
- Added a SQLite-backed integration test that runs
  `GET_VALID_OUTLINE_SOURCES` through the real EORD/EKKO/EKPO/MARC
  repository and service. It verifies agreement filtering, exclusion of
  a matching blocked source, and source-list flags; PLAN validation now
  guards the integration fixture.
  Updated README and `ANOMALIES.md` to distinguish local SQL coverage from
  target-SAP verification. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,937 ABAP Unit
  methods.
- Extended the source integration fixture with a deleted agreement header
  and a delivery-complete item. Repository assertions verify both flags
  survive the SQL reads, while the service still returns only the two valid
  agreements. PLAN validation now guards both fixtures and mapped fields.
- Added a deleted agreement item and a valid scheduling agreement to the same
  SQLite integration fixture. Repository assertions cover item deletion and
  K/L category mapping; the service result confirms deleted items are filtered
  while a valid L-category agreement remains eligible. PLAN validation guards
  the new cases. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,937 ABAP Unit methods.
- Both PIR and outline-source selection now reject impossible Gregorian
  delivery dates before reading source data. Added `20260230` regressions for
  each API, PLAN validation guards, and README/`ANOMALIES.md` documentation.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,938 ABAP Unit methods.
- Expanded the SQLite outline fixture to check exact-date inclusive validity
  at both EORD and EKKO, plus rejection of an EORD source-list entry and an
  agreement header that begin after the requested delivery date. PLAN guards
  the mapped boundaries and the end-to-end candidate result. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,938 ABAP Unit methods.
- Added an end-to-end SQLite test for `GET_VALID_PIR_CANDIDATES` using the real
  EINA/EINE/EORD/MARC and quota repository reads. It checks general and
  purchasing-record deletion filtering, source-list eligibility, fixed/MRP and
  automatic-sourcing flags, vendor-specific blocked-source exclusion, the
  auto-source filter, and exclusion after the source-list validity date. It
  also verifies unlisted records remain visible when the source-list flag is
  off and disappear when `iv_require_source_listed` is enabled. PLAN validation
  guards the integration fixture and assertions. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,939
  ABAP Unit methods.

## 2026-10-16

- Added `validate:plan` to check that the required abaplint rules, open-abap-core
  dependency, SAP stub inputs, and Z-object source layout stay aligned with
  `PLAN.md`. It also checks the MARD and RESB fields used by the current stock
  and reservation queries. Direct Node execution passed; the WSL 1 `npm`
  launcher is unavailable here, so lint, transpilation, and ABAP Unit were run
  through their local binaries.
- Added `PREVIEW_SCOPED_COMPONENTS` and its bulk variant for local production
  component estimates that respect `RESB-LGORT` and `RESB-CHARG`. The stock
  allocator shares location totals with batch sub-balances, allocates by
  required date and scope, and deducts competing open reservations from raw
  unrestricted balances by required date after excluding selected component
  reservation keys. Competing reservations due later do not reduce earlier
  component allocations; their balances are deducted before components due on
  those later dates. Batchless scoped demands also skip batches that expire
  before the component required date; competing reservations use only batches
  eligible through their due date.
  The default stock preview now selects this path whenever a component has an
  assigned scope and no projected receipt option is on. Regression coverage
  checks batch limits, location limits, shared stock, and competing open
  reservations, and expiry filtering for batchless demands. Future receipts are
  not included, and snapshot limitations are documented in `ANOMALIES.md`.
  Scoped rows also carry a date-group estimate whose available quantity counts
  shared stock once across the union of component scopes.
- Extended the explicit scoped component previews with caller-assigned dated
  batch receipts. Receipt events enter the shared ledger before same-date
  reservations and cannot cover earlier reservation demand. Receipts inherit a
  known batch expiry when omitted and replenish any remaining safety-stock
  buffer before becoming allocatable. Regression coverage checks receipt date
  ordering against a competing reservation, safety-stock replenishment, and
  expiry inheritance when an earlier receipt is fully withheld.
  ATP preview wrappers now accept the same input for their local estimate while
  leaving the cumulative SAP ATP requests unchanged; that mode rejects the
  SAP-derived receipt flags rather than mixing incompatible receipt balances.
  These receipts remain caller-resolved and are not checked against SAP receipt
  documents; automatic SAP-derived receipt options still use the plant-level
  estimate. abaplint reported 0 issues across 138 files, transpilation passed,
  and the 1,866-method ABAP Unit suite exited 0. Plan validation also passed.
  Target-system limits are recorded in `ANOMALIES.md`.
- Added `it_projected_location_receipts` to scoped, stock, and ATP component
  previews for caller-assigned non-batch supply. Receipts enter the assigned
  location's residual pool on their arrival date, replenish remaining protected
  safety stock, and precede same-date reservations. Coverage checks dated
  allocation, location scope, and forwarding through ATP while preserving the
  SAP request. abaplint, transpilation, and all 1,867 ABAP Unit methods passed.
  Both receipt inputs are caller-resolved; the SAP request remains plant-level.
- Added combined batch and location receipt coverage through scoped, stock, and
  ATP bulk previews across two production orders. The regression confirms that
  batch supply stays restricted to its batch and location-only supply serves a
  batchless component; ATP requests remain grouped by required date. abaplint
  reported 0 issues across 138 files, transpilation succeeded, all 1,868 ABAP
  Unit methods passed, and `validate:plan` passed.
- Extended SAP-derived PO, issued/unissued STO, and scheduling-agreement
  projections with receiving-location and schedule-line batch assignments.
  Scoped component stock and ATP previews now feed those rows into the shared
  location/batch ledger when every selected receipt has a storage location.
  This first extension covered those three source families. Added `EKPO-LGORT`
  and `EKET-CHARG` stubs and required them in plan
  validation. Regression coverage checks exact-batch and location receipt
  matching, ATP forwarding, and the plant-level fallback. abaplint reported
  0 issues across 138 files, transpilation succeeded, all 1,869 ABAP Unit
  methods passed, and `validate:plan` passed. The repository SQL still needs
  validation against the target SAP release.
- Extended scoped SAP-derived receipts to production orders, PR/STO PRs, and
  planned/fixed planned orders. Production rows carry `AFPO-LGORT` and
  `AFPO-CHARG`; requisitions carry `EBAN-LGORT`; planned orders carry
  `PLAF-LGORT`. Scoped stock and ATP previews now use all these receipt sources
  when every selected receipt has a location, with the existing plant-level
  fallback for missing locations or outgoing-STO subtraction. Added table stub
  fields and a mixed-source regression covering all receipt categories.
  abaplint reported 0 issues across 138 files, transpilation succeeded, all
  1,869 ABAP Unit methods passed, `validate:plan` passed, and the CRLF-aware diff
  check was clean. Real SAP SQL behavior still needs target-system validation.
- Added confirmation-aware PO receipts to single and bulk component stock/ATP
  previews. Supplier confirmation rows carry `EKPO-LGORT` and `EKES-CHARG`, and
  the schedule remainder rows retain `EKPO-LGORT` and `EKET-CHARG`; the PO
  confirmation option remains exclusive with ordinary PO receipts. The scoped
  regression now exercises ordinary PO and confirmation-aware PO batch supply
  alongside the other mapped receipt sources, plus missing-location fallback
  and mutually exclusive PO option validation. SAP field mappings and
  target-query validation are recorded in [ANOMALIES.md](ANOMALIES.md).
  abaplint reported 0 issues across
  138 files, transpilation succeeded, all 1,869 ABAP Unit methods passed,
  `validate:plan` passed, and the CRLF-aware diff check was clean.
- Strengthened `validate:plan` to check that receipt storage-location stubs
  are `CHAR(4)` and batch stubs are `CHAR(10)`, in addition to checking field
  presence. The validator passes against the current SAP table stubs.
- Limited scoped receipt reads to each material/plant's latest component date.
  This keeps a later unlocated receipt for one plant from forcing plant-level
  fallback for another plant whose component horizon ends sooner. The regression
  covers separate plants with different horizons and a later unlocated PO row.
  abaplint reported 0 issues, transpilation succeeded, all 1,869 ABAP Unit
  methods passed, and `validate:plan` passed.
- Added `CREATE_PROD_COMP_SERVICE()` to the production factory and reused it
  when wiring the production-order ATP release gate. Applications can now get
  the SAP-backed component service directly. Factory coverage checks both
  component and production-order service construction.
- Added factory methods for planned-order and production-order read services.
  They wire the existing bulk read services to the PLAF and production-order
  repositories, and the factory test checks all three production services.
- Added `CREATE_SO_RES_READ_SERVICE()` to wire sales-order reservation detail
  reads to the reservation BAPI adapter, and covered it in the factory test.
- Added `CREATE_SO_RESERVATION_SERVICE()` for SAP-backed order reservation
  release workflows, with the BAPI adapter and reservation finder wired in the
  factory and included in factory coverage.
- Verification passed: abaplint reported 0 issues across 138 files, the
  transpiler completed, and all 1,861 ABAP Unit methods ran with exit code 0.

## 2026-10-15

- Added priority-only ordering to cost-center FEFO previews. Higher-priority
  demands consume shared plant batches first; preview rows retain caller order
  and echo each priority. Tests cover split selection, invalid flags before
  stock reads, and summary ordering. `npm run lint` found 0 issues across 138
  files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added priority-only ordering to aggregate sales-order issue previews in base
  and alternative units. Higher priorities consume a shared item/cutoff
  balance first, results return in caller order, and malformed option flags are
  rejected before stock reads. Tests cover partial coverage and converted UOM
  totals. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Added priority-only ordering to sales-order FEFO preview and issue flows.
  Base-unit and UOM requests now allocate shared item stock by descending
  priority without requiring dates, preserve caller order in results, and
  recheck with the same ordering before movement 231. Tests cover priority batch
  splits in both units and both posting workflows. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0.
- Added `SEND_QUALITY_FEFO_PRIORITY` to apply priority-ordered unrestricted
  stock FEFO to movement 322. The service repeats the priority allocation,
  verifies priority echoes and batch splits, and supports location filters and
  safety-stock protection. Tests cover priority stock consumption, movement
  type, split quantities, and rejection of a modified priority or changed stock
  split before posting. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `RELEASE_QUALITY_FEFO_PRIORITY` to connect priority-ordered quality
  stock allocation to movement 321. The service recomputes the same priority
  preview, verifies priority echoes and batch splits, then posts unit-mapped
  quantities. Tests cover a high-priority demand consuming the earliest batch
  first, rejection of a modified priority, and rejection of a changed split
  before the goods-movement call. `npm run lint` found 0 issues across 138
  files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `ALLOCATE_DEMANDS_UOM_ATP` for ordinary bulk alternative-unit
  allocations. It preserves the unit-aware local result and checks cumulative
  positive quantities by material, plant, and base unit; the optional ATP date
  defaults to `sy-datum`. Tests cover mixed units, grouped partial confirmation,
  the default date, and early rejection of blank rules or invalid dates.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_PRIO_ATP` and
  `PREVIEW_TRANSFER_LOC_PRIO_ATP` for undated priority-ordered WBS transfers.
  They report grouped plant ATP diagnostics for positive local allocations
  without changing caller-order priority results; the optional check date
  defaults to `sy-datum`. Tests cover repeated IDs, priority FEFO/location
  splits, destination assignments, ATP grouping, and early rejection of bad
  dates and blank rules. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_PRIORITY_ATP` and `PREVIEW_LOCATION_PRIORITY_ATP` for
  undated priority-ordered WBS allocations. Their ATP checks aggregate positive
  quantities by material, plant, base unit, and check date while retaining the
  local priority allocation and caller-order rows. Tests cover repeated IDs,
  priority stock selection, grouped ATP quantities, date defaults/validation,
  and blank-rule rejection before reads. `npm run lint` found 0 issues across
  138 files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_ATP` and `PREVIEW_TRANSFER_LOC_ATP` for undated
  project WBS transfer previews. Checks group positive allocations by material,
  plant, base unit, and ATP date; the optional date defaults to `sy-datum` and
  does not alter the local transfer split. Tests cover batch/location splits,
  destination mapping, aggregation, date validation, and blank-rule rejection
  before reads. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_ATP` and `PREVIEW_BY_LOCATION_ATP` for undated project
  WBS previews. Both check positive allocations cumulatively by material,
  plant, base unit, and ATP date; the optional date defaults to `sy-datum` and
  does not change the current local stock estimate. Tests cover grouping,
  location preference, custom/default dates, and blank-rule or invalid-date
  rejection before reads. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_DATE_ATP` and `PREVIEW_TRANSFER_LOC_DATE_ATP`
  for cumulative plant-level ATP diagnostics on dated project WBS transfers.
  Checks group positive local allocations by material, plant, base unit, and
  required date; they do not alter batch or location splits. Tests cover
  repeated IDs, destination assignments, transfer stock splits, aggregation,
  and blank-rule rejection before reads. `npm run lint` found 0 issues across
  138 files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_BY_LOCATION_DATE_ATP`, pairing batchless dated WBS location
  allocation with cumulative plant-level SAP ATP diagnostics. Checks aggregate
  positive allocations by material, plant, base unit, and date; they do not
  alter the local location split. Tests cover duplicate IDs, location priority,
  same-date ATP aggregation, and blank-rule rejection before stock reads.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_BY_DATE_ATP`, which keeps the dated project WBS FEFO
  estimate and reports cumulative plant-level SAP ATP checks by material,
  plant, base unit, and required date. Confirmed/unconfirmed quantities remain
  diagnostic and do not gate the local allocation. Tests cover cumulative date
  grouping, partial confirmations, and rejection of a blank check rule before
  stock reads. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Updated `PREVIEW_FEFO_BY_DATE`, `PREVIEW_BY_LOCATION_DATE`,
  `PREVIEW_TRANSFER_FEFO_BY_DATE`, and `PREVIEW_TRANSFER_LOCATION_DATE` to
  assign unique internal IDs to each input row. Repeated caller IDs now work in
  direct dated preview calls as well as transfer wrappers, and allocations,
  splits, and assignments retain caller order and IDs. Added regression tests
  for all four preview types. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Updated `TRANSFER_WBS_BY_LOCATION_DATE` to use unique internal IDs through
  the dated source-WBS location preview, recheck, and 415/Q movement posting.
  Repeated caller IDs now work across required dates, and the result restores
  caller IDs/order for allocations, location splits, and transfer assignments.
  Tests cover date-based location choice and destination WBS mapping. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Updated `TRANSFER_WBS_FEFO_BY_DATE` to use unique internal IDs through the
  dated source-WBS preview, recheck, and 415/Q movement posting. Repeated caller
  IDs now work across required dates, with caller IDs and input order restored
  in allocations, batch splits, and transfer assignments. Tests cover distinct
  date-based batches and destination WBS mapping. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Updated `RESERVE_WBS_BY_LOCATION_DATE` to use unique internal IDs through
  the dated location preview, recheck, and reservation steps. Repeated caller
  IDs now work across requirement dates, while returned previews preserve the
  original IDs and input order. Tests cover separate date groups, locations
  selected by date order, and duplicate ID mapping. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP
  Unit with exit 0.
- Updated `RESERVE_WBS_FEFO_BY_DATE` to use unique internal IDs through the
  dated preview, recheck, and reservation steps. Repeated caller IDs now work
  across multiple required dates, with caller IDs and order restored in the
  preview. Tests cover duplicate IDs, date-prioritized FEFO batch selection,
  and separate reservation groups per date. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Added `RESERVE_WBS_LOCATION_PRIORITY` for rechecked priority-ordered
  batchless WBS reservations. Higher priorities consume shared stock first and
  equal priorities keep input order; returned previews restore caller order and
  IDs, while internal IDs preserve repeated demands during posting. Full
  quantity is required by default, with partial reservation opt-in. Tests cover
  repeated IDs, preferred-location allocation, grouped item quantities, and
  rejection when rechecking finds a newly preferred location. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added `RESERVE_WBS_FEFO_PRIORITY` for rechecked priority-ordered undated WBS
  batch reservations. It preserves stable input order for ties, restores caller
  order and IDs in the preview, and uses unique internal IDs through reservation
  creation so repeated caller IDs remain safe. Full quantity is required by
  default; partial reservations are opt-in. Tests cover duplicate IDs, FEFO
  split grouping, and stale allocation rejection before writes. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added `TRANSFER_WBS_LOC_PRIORITY` to recheck priority-ordered batchless WBS
  location splits before posting movement 415/Q. Internal IDs preserve distinct
  demands with repeated caller IDs, while the result preview restores caller
  IDs. Full demand coverage is required by default; partial transfer is
  opt-in. Tests cover storage-location preference, caller-order posting, and
  stale snapshot rejection. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `TRANSFER_WBS_FEFO_PRIORITY`, which runs the undated priority FEFO
  preview twice, compares the full source/destination batch transfer splits,
  then posts the matched result as movement 415/Q. Internal IDs keep duplicate
  caller IDs distinct through posting while the returned preview preserves
  caller IDs. Full demand is required by default; partial priority transfer is
  opt-in. Tests cover priority allocation, posted batch/WBS mapping, and stale
  snapshot rejection. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_TRANSFER_FEFO_PRIORITY` and
  `PREVIEW_TRANSFER_LOC_PRIORITY` for undated WBS stock transfers. Higher
  priorities consume shared source-WBS batch or location balances first, ties
  preserve input order, and allocation splits plus WBS assignments return in
  caller order with priority echoed. Internal row IDs allow repeated caller
  request IDs. Tests cover FEFO and location splitting, stable ties, and source
  location preference. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added `PREVIEW_BY_LOCATION_PRIORITY` for undated batchless project/WBS stock.
  Higher priorities allocate shared location balances first, ties preserve
  input order, and summaries, location splits, and WBS assignments return in
  caller order with priority echoed. Internal row IDs support repeated caller
  request IDs; the test also checks storage-location preference. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added `PREVIEW_FEFO_PRIORITY` for undated project/WBS stock demands. Higher
  priorities allocate shared project batches first, ties preserve input order,
  and summaries, batch splits, and WBS assignments return in caller order with
  priority echoed. Internal row IDs preserve repeated caller request IDs.
  Regression coverage checks shared FEFO batches and duplicate IDs.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0. Snapshot and correlation limits are
  documented in `README.md` and `ANOMALIES.md`.
- Added `ALLOCATE_DEMANDS_UOM_ATP_PRIO` for grouped ATP checks on positive
  priority-based local UOM allocations. Higher priorities retain shared stock
  precedence; confirmations remain separate from the local allocation.
  Regression coverage checks caller-order quantities and grouped confirmation.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added `ALLOCATE_FEFO_UOM_ATP_PRIO` to check priority-aware single-plant FEFO
  UOM allocations against grouped plant ATP. ATP confirmations remain separate
  from the local batch split. Regression coverage checks priority allocation,
  caller-order results, and confirmed/unconfirmed totals. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0.
- Added priority-aware single-plant exact-batch allocation for base-unit and
  UOM demands, plus a grouped UOM ATP wrapper. Higher priorities consume shared
  batch stock first, ties preserve input order, and summaries/batch splits
  return in caller order with priority echoed. Repeated request IDs are
  preserved through internal row mapping. Regression coverage checks base/UOM
  quantities and grouped ATP confirmation. `npm run lint` found 0 issues across
  138 files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added priority-aware base-unit and UOM allocation across single-plant storage
  locations, plus a UOM ATP wrapper. Higher priorities consume shared stock
  first, ties preserve input order, and summaries/location splits return in
  caller order with priority echoed. Repeated request IDs are preserved through
  internal row mapping. Regression coverage checks duplicate IDs, UOM
  conversions, location preferences, and grouped ATP quantities. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added priority-aware undated ordinary cross-plant allocation for base-unit
  and UOM demands, preserving projected receipt and cutoff inputs. Higher
  priorities consume shared source balances first, stable ties preserve input
  order, and results return in caller order. Added the UOM ATP wrapper, which
  checks grouped source-plant quantities separately. Tests cover shared
  receipts, stable ties, base/UOM allocations, duplicate rejection before UOM
  reads, and ATP grouping. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added priority-aware cross-plant exact-batch allocation for base and
  alternative-unit demands, plus a UOM ATP wrapper. Priority applies among
  requests with the same as-of date, while earlier dates remain first. Results
  return in caller order with priorities echoed, and duplicate IDs fail before
  stock or UOM reads. Regression coverage checks base/UOM quantities,
  location splits, duplicate rejection, and grouped ATP quantities.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added priority-aware undated cross-plant FEFO allocation for base and
  alternative-unit demands. Higher priorities consume shared source-plant
  batches first, equal priorities preserve input order, and summaries plus
  source/batch splits return in caller order with priority echoed. Duplicate
  IDs are rejected before stock reads or UOM conversion. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0. The snapshot and SAP batch-determination limits are recorded in
  `README.md` and `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_FEFO_UOM_ATP` for priority-aware UOM cross-plant FEFO.
  It preserves the caller-order local split and checks positive allocations by
  material, source plant, and base unit, returning confirmations separately.
  Regression coverage verifies priority allocation and grouped ATP quantity.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0. ATP remains plant-level and does not
  confirm batch/location selection.
- Added priority-aware quality FEFO allocation for base and alternative-unit
  demands. Higher priorities consume shared quality batches first, while
  summaries and splits return in caller order. Both entry points reject
  duplicate IDs before repository or UOM reads. Regression coverage verifies
  base and UOM quantities, split restoration, and duplicate rejection.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added priority-aware FEFO allocation for base and alternative-unit demands.
  Higher priorities consume shared batches first, equal priorities keep input
  order, and summaries plus batch splits return in caller order with priority
  echoed. Missing or duplicate request IDs fail before stock reads. Tests cover
  stable ties, shared FEFO batches, UOM amounts, caller order, and duplicate
  rejection. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Rejected positive stock-service UOM demand that rounds to zero at
  `MARD-LABST` precision, before any stock read. Centralized the guard across
  unit-aware allocation paths and covered single, bulk, and dated location
  allocation with a tiny ratio. `npm run lint` found 0 issues across 138 files;
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added opt-in prioritized bulk allocation entry points for base and
  alternative-unit demand. Higher integer priority consumes shared
  material/plant stock first, ties keep input order, and results return in
  caller order with priority echoed. Duplicate or missing request IDs are
  rejected before stock reads. Tests cover base/UOM allocation, stable ties,
  echoed priorities, and duplicate rejection. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Extended dated cross-plant ordinary and FEFO allocation with per-demand
  `require_full_quantity`, including date UOM and ATP wrappers. The row flag
  combines with the shared option, is validated before stock/UOM reads, and
  leaves shared balances untouched when a short request is skipped. README and
  anomaly notes document the policy. `npm run lint` found 0 issues across 138
  files; `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Extended dated location-aware cross-plant ordinary allocation with the same
  per-demand policy in base and UOM requests, including the ATP wrapper. The
  flag passes through date/priority sorting into shared plant/location balance
  allocation, and invalid UOM row values are rejected before conversion.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added per-demand `require_full_quantity` to exact-batch cross-plant base and
  UOM demands in both undated and date-prioritized allocation. The shared flag
  still applies to all rows, and ATP wrappers preserve the local decision.
  Invalid row values are rejected before stock reads or UOM conversion.
  Regression coverage includes mixed row policies for local and cross-plant
  location, batch, dated, UOM, FEFO, and ATP paths. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP
  Unit with exit 0.
- Extended per-demand `require_full_quantity` to single-plant ordinary and
  location-aware base/UOM allocation, including dated location previews and ATP
  wrappers. Also added it to single-plant exact-batch base/UOM demand rows.
  Short flagged lines consume no shared balance, and invalid UOM row flags are
  rejected before conversion. README and anomaly notes document the scope.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Extended request-level `require_full_quantity` to ordinary and undated FEFO
  cross-plant base/UOM demands. A short flagged row consumes no source-plant
  stock and leaves it for later rows; the shared flag and ATP diagnostics keep
  their existing behavior. Mixed-demand and invalid-flag tests cover base,
  UOM, FEFO, ATP, and pre-conversion validation. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0.
- Added request-level `require_full_quantity` to stock-service FEFO base and
  UOM demands, including quality-stock FEFO and cost-center dated/undated
  previews. A short flagged request gets no batch split and leaves its eligible
  balance for later requests; the existing shared flag still applies to all
  rows. Preview results echo the cost-center row policy, and invalid values are
  rejected before stock reads or UOM conversion. Mixed-policy regression tests
  cover base, converted-unit, quality, and cost-center flows. `npm run lint`
  found 0 issues across 138 files; `npm run unit` completed transpilation and
  ABAP Unit with exit 0.
- Added per-request `require_full_quantity` to sales-order FEFO base and UOM
  demands. It combines with the existing shared flag; a short row receives no
  split and leaves remaining stock for subsequent requests, while unflagged
  rows retain partial behavior. Invalid values fail before stock reads.
  Regression coverage verifies mixed policies in base and converted-unit
  demand sets. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Carried the shared and per-request SO FEFO location filters in the allocation
  result. Goods-issue and reservation writers check every selected split
  against it; rechecks also compare filter metadata, and selected request
  results keep only the matching scoped rows. Regression cases cover excluded
  issue/reservation splits, scope changes at recheck, and filter preservation
  through selected and generated reservation previews. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP Unit
  with exit 0.
- Added request-specific storage-location scopes to SO FEFO previews, issue
  rechecks, and reservation previews. Scope rows intersect with the shared
  allowlist; mixed-demand tests cover separate location sets in base and UOM
  flows, invalid scope rejection before reads, and issue/reservation forwarding.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added a shared SO FEFO storage-location allowlist for base and UOM previews,
  plus fresh goods-issue and reservation preview paths. A preferred location
  must belong to the allowlist; excluded locations do not contribute to
  availability or splits. Tests cover both units, rejection before reads, and
  propagation through issue and reservation. `npm run lint` found 0 issues
  across 138 files; `npm run unit` completed transpilation and ABAP Unit with
  exit 0. The SAP storage-type and authorization limits are recorded in
  `ANOMALIES.md`.
- Sales-order FEFO now rejects malformed nonblank expiration dates from the
  repository before sorting or allocating; a regression supplies an impossible
  Gregorian date. `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0.
- Added per-demand preferred storage locations with optional fallback to
  sales-order FEFO previews in base and alternative units. Expiry and batch
  order remain primary; preference breaks location ties within the same batch
  and expiration date. Issue and reservation consumers validate the echoed
  preference, and full-location fallback tests cover both posting paths.
  `npm run lint` found 0 issues across 138 files; `npm run unit` completed
  transpilation and ABAP Unit with exit 0.
- Added a per-demand `require_known_expiry` option to sales-order FEFO requests.
  It excludes unknown-expiry batches for that demand while other requests can
  still use them under the shared undated-batch setting. Summaries and splits
  report the effective policy; base and UOM tests cover mixed demands and bad
  flag rejection before reads. The issue workflow regression confirms an
  undated batch is not posted for a known-expiry demand. `npm run lint` found 0
  issues across 138 files; `npm run unit` completed transpilation and ABAP
  Unit with exit 0. Local expiry metadata limits remain documented in
  `ANOMALIES.md`.
- Added a per-demand `minimum_shelf_life_days` constraint to sales-order FEFO
  previews in base and alternative units. The greater of the request value and
  shared `iv_min_days` now drives batch eligibility; summaries and splits echo
  the effective value so issue and reservation consumers retain the rule.
  Regression coverage checks differing minima against shared balances, UOM
  propagation, and rejection before reads for negative values. Validation
  passed: `npm run lint` found 0 issues across 138 files; `npm run unit`
  completed transpilation and ABAP Unit with exit 0. SAP expiry and batch
  determination limits are recorded in `ANOMALIES.md`.
- Hardened sales-order FEFO posting after finding that rechecked previews did
  not compare newly added summary `required_date` and `priority` fields, and
  posting did not require those values to match batch splits. Rechecks now
  compare them; posting validates date syntax/cutoff and matching split metadata.
  Added regressions for changed summaries, inconsistent splits, and dates after
  the effective cutoff. `npm run lint` passed with 0 issues across 136 files;
  `npm run unit` passed transpilation and ABAP Unit with exit 0. The combined
  `npm test` wrapper still fails at WSL 1 startup; individual scripts work.
- Added `ZCL_SO_FEFO_ISSUE_SERVICE->ISSUE_FEFO` and `ISSUE_FEFO_UOM` to recompute
  the same sales-order FEFO demand snapshot immediately before posting through
  the existing rechecked movement path. Optional request IDs select a subset
  from a multi-demand result after validating the IDs before stock reads. Added
  production factory wiring and tests for matching previews, base-unit movement
  mapping, selected cutoffs, stale stock rejection before the movement API, and
  empty input. `npm run lint` passed with 0 issues across 138 files;
  `npm run unit` passed transpilation and ABAP Unit with exit 0. The combined
  `npm test` wrapper still fails at WSL 1 startup; individual scripts work.
- Added exact storage-location filtering to sales-order FEFO demands in base and
  alternative units. The requested location is echoed on summaries and batch
  splits; goods issue and reservation creation now reject splits that violate
  it, including during refreshed-preview comparisons. Tests cover location-only
  FEFO in both units and pre-write rejection in both posting paths. Final lint
  passed with 0 issues across 138 files; transpilation and ABAP Unit passed
  with exit 0. The combined `npm test` wrapper still fails at WSL 1 startup;
  individual scripts work.
- Added `ALLOCATE_LOCATION_DATE_ATP` for dated location demands already
  expressed in base units. The caller supplies each demand's base unit; positive
  local allocations are combined by material, plant, unit, and required date,
  then checked cumulatively so later dates include earlier allocations. Tests
  cover early rejection, same-date aggregation, confirmations, and cumulative
  requests. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Plant-level ATP does not
  confirm the storage-location split; see `ANOMALIES.md`.
- Added `ALLOCATE_QUALITY_BY_EXPIRY_ATP`, which combines the quality-inspection
  FEFO UOM preview with grouped plant-level ATP checks for positive batch
  allocations. Tests verify early rule rejection, UOM conversion, FEFO splits,
  and partial ATP confirmation. `npm test` passed with 0 abaplint issues across
  136 files, successful transpilation, and ABAP Unit exit 0. ATP's coverage of
  quality stock and the exact batch remains target-system dependent.
- Added caller-resolved, dated storage-location receipts to
  `ALLOCATE_LOCATION_BY_DATE` and its base-unit ATP diagnostic. Receipts become
  available at their location on the stated date, are shared by later demands,
  and replenish any uncovered static safety-stock buffer first. Tests cover an
  invalid date, late receipt eligibility, location scope, safety-stock
  protection, and ATP forwarding. `npm test` passed with 0 abaplint issues
  across 136 files, successful transpilation, and ABAP Unit exit 0. Receipt
  identity remains caller-provided; see `ANOMALIES.md`.
- Added `ALLOCATE_QUALITY_BY_EXPIRY` and its `ALLOCATE_QUALITY_BY_EXPIRY_UOM`
  form. Both allocate raw `MCHB-CINSM` stock in FEFO order, share each
  material/plant balance across demands, preserve batch/location splits, apply
  expiry and minimum-shelf-life rules, and support all-or-nothing allocation.
  The UOM method returns base and source quantities. Tests cover expiry,
  undated-stock filtering, shared balances, full-quantity behavior, and UOM
  conversion. `npm test` passed with 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0. Quality-management and stock
  snapshot limits are recorded in `ANOMALIES.md`.
- Added `RELEASE_QUALITY_FEFO_RECHECKED` to post a unit-aware quality FEFO
  allocation after requiring an identical refreshed summary and batch split.
  It validates mappings, base/source quantities, split totals, and batch
  eligibility through the posting date, then posts canonical base-unit
  quantities with movement 321. Tests cover successful posting and stale
  preview rejection before the BAPI call. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit exit 0. The
  stock snapshot race and SAP quality controls are recorded in `ANOMALIES.md`.
- Added `SEND_QUALITY_FEFO_RECHECKED` for movement 322. It shares the same
  matching-preview, conversion, split-total, and posting-date eligibility
  checks, and preserves FEFO batches in the movement items. Tests verify both
  batch lines and base-unit quantities. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit exit 0.
- Added `ZCL_QUALITY_STOCK_SERVICE` to recompute quality or unrestricted FEFO
  allocations from the stock service immediately before posting movements 321
  or 322. Changed batch splits are rejected before the goods-movement API call;
  tests cover matching rechecks, changed QI stock, and empty requests.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
- Added storage-location priorities and allowlists to quality FEFO base and UOM
  allocation, and passed the options through the fresh quality-release service.
  Tests cover tie-breaking order, filtering, invalid preferred locations, and
  unit-aware rechecking with a filter. `npm test` passed with 0 abaplint issues
  across 136 files, successful transpilation, and ABAP Unit exit 0.
- Added optional exact-batch filters to base and unit-aware FEFO demands. Both
  unrestricted and quality FEFO now limit availability and splits to the
  requested batch while retaining expiry checks and shared balances. Tests
  cover base and UOM allocation for both stock categories. `npm test` passed
  with 0 abaplint issues across 136 files, successful transpilation, and ABAP
  Unit exit 0.

## 2026-10-14

- Added quality-inspection batch visibility to the batch stock-status readers.
  Base and bulk results now report `MCHB-CINSM` and `MCHB-CSPEM` beside
  unrestricted and reservation-net availability; UOM results convert all four
  quantities. The repository aggregates batch quantities in one `MCHB` query.
  Tests cover field mapping and alternative-unit conversion. `npm test` passed:
  0 abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0. The database mapping limitation is recorded in `ANOMALIES.md`.
- Added own-stock quality-inspection transfers: `RELEASE_QUALITY_STOCK`/321
  and `SEND_STOCK_TO_QUALITY`/322, with base and alternative-unit forms. Shared
  validation preserves location and optional batch data. Tests cover movement
  mapping and UOM conversion. `npm test` passed with 0 abaplint issues across
  134 files, successful transpilation, and ABAP Unit exit 0. SAP quality
  management controls are recorded in `ANOMALIES.md`.
- Added `BLOCK_UNRESTRICTED_STOCK` and `BLOCK_UNRESTRICTED_STOCK_UOM` using
  movement 344. The APIs preserve plant, storage location, optional batch, and
  quantity, with UOM conversion to the mapped material base unit. Tests cover
  movement mapping, batch forwarding, conversion, and invalid input rejection.
  `npm test` passed with 0 abaplint issues across 134 files, successful
  transpilation, and ABAP Unit exit 0.
- Added `RELEASE_BLOCKED_STOCK` and `RELEASE_BLOCKED_STOCK_UOM` using movement
  343. Requests retain plant, storage location, optional batch, and quantity;
  the UOM path converts to the mapped material base unit. Tests cover movement
  mapping, batch forwarding, conversion, and rejection before the API call.
  `npm test` passed with 0 abaplint issues across 134 files, successful
  transpilation, and ABAP Unit exit 0.
- Extended sales-order FEFO issue previews with an optional exact-batch filter
  in base and alternative units. Each demand allocates only from its selected
  batch, repeated demands share that batch's remaining balance, and expiration
  and shelf-life checks still apply. Reservation assignment remains global
  FEFO where the reservation has no physical batch scope; the aggregate stock
  snapshot is retained for audit. Tests cover repeated batch demands, partial
  coverage, expired batches, and UOM quantities. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added sales-order stock reads by owning sales document and item. Callers can
  supply item/material/plant directly or resolve material and plant from `VBAP`.
  The service reads `MSKA` stock, nets open `RESB` special-stock E reservations,
  and returns gross stock rows, open reservation detail, base unit, and
  aggregate availability. Added stubs, production factory wiring, tests, and
  docs. `npm test` passed: zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit. Target query semantics and stock snapshot limits
  are recorded in `ANOMALIES.md`.
- Added an optional reservation cutoff to sales-order stock reads. Reservations
  due after `RESB-BDTER` cutoff dates no longer reduce the net available total;
  undated requirements still count, and all open rows remain available for
  audit. The cutoff flows through both explicit material/plant reads and
  `VBAP`-resolved item reads. Tests cover the date boundary, undated rows,
  invalid dates, and forwarding. `npm test` passed with zero lint issues across
  134 files, successful transpilation, and ABAP Unit. The current-stock-only
  scope is recorded in `ANOMALIES.md`.
- Added `PREVIEW_ISSUE_DEMANDS` for multiple sales-order item quantities. It
  resolves materials and plants from `VBAP`, compares base-unit requests with
  net `MSKA`/`RESB` availability, and returns covered amounts and shortfalls
  with each stock snapshot. Duplicate item requests are rejected to prevent
  double counting; results are aggregate and do not assign a batch/location
  split. Tests cover full coverage, shortfall, duplicate demand, and empty
  input. `npm test` passed with zero lint issues across 134 files, successful
  transpilation, and ABAP Unit. Split and snapshot limits are in
  `ANOMALIES.md`.
- Added `PREVIEW_ISSUE_DEMANDS_IN_UNIT` to the sales-order stock service. It
  converts demand through the material UOM converter and returns requested,
  available, covered, and shortfall quantities in both source and base units.
  Unknown ratios and positive quantities that convert to zero are rejected.
  Tests cover exact coverage, partial coverage with fractional source units,
  unknown units, and sub-precision conversion. `npm test` passed with zero lint
  issues across 134 files, successful transpilation, and ABAP Unit. Target
  conversion data and aggregate-only limitations are recorded in
  `ANOMALIES.md`.
- Extended both sales-order demand previews to allow multiple request rows for
  one item without reusing the same available stock. Each row consumes the
  shared item's remaining balance in input order; unit-aware rows can use
  different units. Rows with the same item and cutoff share a balance. Tests
  cover partial cumulative coverage and cross-unit allocation. `npm test` passed
  with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit. Target aggregate-snapshot and
  date-cutoff limits remain in `ANOMALIES.md`.
- Extended both sales-order demand previews to accept multiple cutoffs for the
  same item. Each cutoff gets an independent remaining-availability pool, while
  requests within one item/cutoff group still consume stock cumulatively in
  input order. Tests cover base and UOM demand at two cutoffs. `npm test` passed
  with zero abaplint issues across 134 files, successful transpilation, and
  ABAP Unit.
- Added FEFO sales-order issue previews in base and alternative units. They
  return batch/location splits after deducting scoped reservations, allocating
  unscoped reservations against eligible batches, applying expiry and minimum
  shelf-life filters, and reconciling splits to aggregate availability. Tests
  cover multiple demands, cutoff handling, alternate units, expired and undated
  stock, minimum shelf life, and aggregation of duplicate stock rows. `npm test`
  passed with zero abaplint issues across 134 files, successful transpilation,
  and ABAP Unit.
  Target `MCHA`/`MCH1` and reservation assignment behavior remain documented in
  `ANOMALIES.md`.
- Added `ISSUE_SALES_ORDER_FEFO` to consume the new preview. It validates each
  summary and batch/location split, confirms base-unit mappings and the echoed
  expiry/shelf-life/undated-batch policy, then posts one 231/E document. Full
  allocation is required by default; partial posting is opt-in. Tests cover
  split preservation, default shortfall rejection, partial posting, and
  expired-batch rejection. `npm test` passed with zero abaplint issues across
  134 files, successful transpilation, and ABAP Unit.
- Added `ISSUE_SO_FEFO_RECHECKED` for callers that rerun the same preview before
  posting. It compares every result summary, physical stock and reservation row,
  and batch/location split, then posts only the identical refreshed result.
  Tests cover matching previews plus changed batch and stock snapshots.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Hardened FEFO posting against combining independent cutoff scenarios for the
  same sales-order item. Repeated demands with one cutoff remain supported;
  mixed-cutoff groups are rejected before the movement API so identical
  physical stock cannot be suggested twice in one posting. Tests cover both
  same-cutoff cumulative posting and mixed-cutoff rejection.
- Added `ISSUE_SO_FEFO_SELECTED` to post selected request IDs from a multi-demand
  preview. This lets callers post one cutoff scenario while retaining the
  duplicate-stock guard on the remaining requests. Tests verify selection from
  a result containing multiple cutoff scenarios, and reject unknown or
  duplicate IDs. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit.
- Added `ISSUE_SO_FEFO_SEL_RECHECKED` to extract the requested IDs from both an
  original multi-demand preview and its fresh rerun, compare the selected stock,
  reservation, summary, and split data, and post the refreshed selection only
  when unchanged. Tests cover successful selected recheck and changed splits.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added `reserve_so_stock_fefo` to turn sales-order stock FEFO splits into
  movement-231 reservation requests, preserving the order item, batch, location,
  and base-unit quantity. Full allocation is required by default; partial
  reservation is opt-in. The method validates split/cutoff/expiry metadata,
  supports simulation, checks returned reservation rows, and commits once with
  rollback on API or commit failure. Tests cover mapping, simulation, shortfall,
  expiry, API failure, and commit failure. `npm test` passed with zero abaplint
  issues across 134 files, successful transpilation, and ABAP Unit.
- Added `reserve_so_stock_fefo_selected` to reserve selected request IDs from a
  multi-cutoff preview. It filters summaries and matching batch splits, then
  runs the shared full-allocation, cutoff, expiry, API-result, and transaction
  checks. Empty, duplicate, and unknown IDs are rejected. Tests verify that one
  cutoff can be reserved without mixing the other pool. `npm test` passed with
  zero abaplint issues across 134 files, successful transpilation, and ABAP Unit.
- Added `reserve_so_fefo_rechecked` for full or selected FEFO reservation
  previews. It compares the caller's fresh result with the original, including
  stock balances, open reservations, allocation summaries, and batch/location
  splits, and reserves only from an unchanged result. Tests cover matching full
  and selected results plus changed stock. `npm test` passed with zero abaplint
  issues across 134 files, successful transpilation, and ABAP Unit. The remaining
  post-check stock race is documented in `ANOMALIES.md`.
- Added `reserve_so_fefo_demands` and `reserve_so_fefo_demands_uom` to run a
  sales-order FEFO stock preview and create the resulting reservations in one
  call. The UOM path converts to material base-unit quantities before sending
  the batch/location requests. Both methods support selected request IDs for
  multi-cutoff previews. Full allocation remains the default, and the methods
  support simulation and shelf-life/undated-batch options. Wired the stock
  service through `CREATE_SALES_ORDER_ALLOC`. Tests cover direct and selected
  FEFO reservation, UOM-to-base mapping, and shortfall rejection. `npm test`
  passed with zero abaplint issues across 134 files, successful transpilation,
  and ABAP Unit; the stock race before the BAPI call is recorded in
  `ANOMALIES.md`.
- Added `reserve_so_fefo_recheck` and `reserve_so_fefo_uom_recheck` to refresh a
  previously displayed FEFO preview internally before reservation creation.
  They compare the fresh preview with the original, support selected cutoff
  request IDs, and make no reservation API call when stock or splits changed.
  Tests cover unchanged base-unit previews, selected cutoffs, changed stock,
  and UOM demand. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit. The remaining stock race after the
  refresh is documented in `ANOMALIES.md`.
- Added `release_so_fefo_reservations` to release reservation numbers from a
  successful, committed FEFO creation result. It validates number uniqueness
  and matches reservation rows to the original batch/location splits before
  delegating to the existing transactional delete service. Test-run, delete
  failure, commit rollback, uncommitted-result rejection, and tampered-row cases
  are covered. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit; SAP reservation status rules remain
  documented in `ANOMALIES.md`.
- Added single and bulk sales-order stock reads in a requested unit. Results
  expose unrestricted, reserved, and available quantities in both the requested
  unit and material base unit; duplicate item reads share one stock snapshot.
  Tests cover alternate-unit conversion, shared bulk reads, and unknown units.
  `npm test` passed with zero abaplint issues across
  134 files, successful transpilation, and ABAP Unit. Target conversion data and
  rounding remain documented in `ANOMALIES.md`.
- Extended bulk unit stock reads to accept different reservation cutoffs for the
  same sales-order item. The service reuses the batched physical-stock read and
  calculates each cutoff's reservation and availability totals independently.
  Tests verify both cutoff totals and the retained cutoff in each result.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added order-scoped reservation issue methods for base-unit and UOM quantities.
  They check every reservation header for movement type 231 and the requested
  sales order/item before reusing the existing issue validation and posting
  flow. Tests cover valid base/UOM issues, wrong sales-order assignment, and a
  non-231 reservation. `npm test` passed with zero abaplint issues across 134
  files, successful transpilation, and ABAP Unit. Target BAPI header behavior
  and SAP-side stock checks remain in `ANOMALIES.md`.
- Added matching sales-order reservation reversal methods in base units and
  alternative units. They validate the same movement type and order/item header
  scope and reuse the existing withdrawn-quantity limit and movement code 06
  flow. Tests cover base and UOM reversals and a mismatched sales order.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added bulk sales-order issue and reversal methods for base-unit and UOM
  quantities. Each reservation document is checked against movement type 231
  and the requested order/item before its separate posting; a scope failure is
  isolated to that reservation while later reservations continue. Tests cover
  all four entry points and continuation after a mismatched reservation.
  `npm test` passed with zero abaplint issues across 134 files, successful
  transpilation, and ABAP Unit.
- Added `CREATE_RES_ISSUE_SERVICE()` to wire the reservation reader,
  goods-movement adapter, and UOM repository through the production factory.
  Construction coverage and README usage are updated.
- Extended sales-order issue and return postings with opt-in special stock E in
  both base-unit and unit-aware methods. The shared movement validator permits
  E only for movements 231/232 with sales-order assignment; blank remains the
  unrestricted-stock default. Tests cover E mapping and rejection of other
  indicators. `npm test` passed with zero lint issues and successful ABAP Unit;
  target movement customizing and return eligibility remain in
  `ANOMALIES.md`.
- Added `TRANSFER_SALES_ORDER_STOCK`/411E and `TRANSFER_TO_SALES_STOCK`/413E,
  with UOM variants for both directions between sales-order stock and own stock.
  The shared movement validator requires the special-stock indicator, correct
  GM code, and sales-order/item assignment. Tests cover base and converted
  quantities plus missing assignment rejection.
  `npm test` passed with zero lint issues across 134 files, successful
  transpilation, and ABAP Unit. Target authorizations and movement configuration
  are recorded in `ANOMALIES.md`.
- Added `TRANSFER_SALES_ORDER_ALLOC` to post the location/batch splits from a
  sales-order allocation preview as movement 413/E. It reuses the strict
  summary/split validation shared with sales-order issue posting, and requires
  full allocation by default. Tests verify 413/E mapping and split preservation.
  `npm test` passed with zero lint issues and ABAP Unit; preview snapshot limits
  are documented in `ANOMALIES.md`.
- Added `ISSUE_SO_ALLOC_RECHECKED` and `TRANSFER_SO_ALLOC_RECHECKED` to compare
  an original sales-order allocation preview with a caller-regenerated preview
  before posting. They check summary, sales-item, location, and batch rows, and
  post the fresh result only when all rows match. Changed previews are rejected
  before the movement API call. Tests cover a 231 issue, a 413 transfer, and
  changed splits. `npm test` passed with zero abaplint issues across 134 files,
  successful transpilation, and ABAP Unit. Caller freshness and the remaining
  stock race are documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_REPL_SOURCE_SERVICE` to expose
  SAP-backed purchasing-source selection through the production factory.
  Added its constructor to the wiring test and README. Source-list and quota
  query semantics remain documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_SALES_ORDER_SERVICE` for the
  standard sales-order read and change workflow, backed by the SAP sales-order
  BAPI adapter. Added the constructor to production coverage and README;
  target BAPI semantics remain in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_CC_RESERVATION_SERVICE` to bind
  cost-center reservation flows to MARD stock, the reservation BAPI and
  reader, material units, and ATP. Added construction coverage and README
  wiring instructions. SAP reservation semantics remain documented in
  `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PREQ_SERVICE` to bind the
  replenishment-requisition workflow to its standard BAPI adapter. Added it to
  construction coverage and the production wiring README. Target PR API
  behavior remains documented in `ANOMALIES.md`.
- Added production factory methods for planned-order and production-order
  services. The production-order constructor now includes its component ATP
  checker, so the existing ATP-gated release methods are available through the
  standard composition. Extended construction coverage and README; target BAPI
  and ATP semantics remain recorded in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PURCHASE_ORDER_SERVICE` to wire
  PO workflows to the purchase-order BAPI and material UOM converter.
  Construction coverage and README now include the production entry point.
  Local validation checks the binding; purchasing BAPI behavior remains
  documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_STOCK_TRANSFER_SERVICE` to wire
  in-transit stock reads to the SAP transfer-stock repository and material UOM
  converter. Extended the construction test and README. Target STO and
  `MARD-UMLME` query behavior remains documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PROJECT_RESV_SERVICE` to compose
  the project reservation BAPI, WBS stock reader, shared material UOM
  converter, and goods-movement adapter used for reservation issues. Extended
  production construction coverage and README. Local validation confirms
  construction only; target BAPI and WBS behavior remain listed in
  `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_PROJECT_STOCK_SERVICE` to wire
  WBS stock and reservation reads to the project-stock repository and UOM
  converter. Extended production construction coverage and README; local tests
  verify construction, while target `MSPR`/`RESB` query semantics remain
  documented in `ANOMALIES.md`.
- Added `ZCL_STOCK_ALLOCATION_FACTORY=>CREATE_SALES_ORDER_ALLOC`
  to wire the sales-order allocation workflow to its sales-order BAPI, MARD
  stock repository, ATP adapter, and reservation BAPI. Extended the production
  construction coverage and README. Local validation checks service
  construction; target BAPI behavior remains covered by the existing
  sales-order reservation notes in `ANOMALIES.md`.
- Added item- and schedule-line-specific FEFO minimum shelf life to sales-order
  previews and reservations. Schedule-line settings override item-wide
  settings, while `iv_fefo_min_days` remains a floor; batch results report the
  effective minimum. Negative values and positive settings without FEFO are
  rejected before reads, and duplicate or unknown demand keys stop allocation.
  An opt-in required-date mode now checks each dated demand's expiry eligibility
  from the later of its requested date and the shared FEFO as-of date, returning
  that effective date on each batch split. Base-unit and unit-aware stock FEFO
  demand types also accept a per-demand as-of date; the shared minimum-shelf-life
  floor is still applied from the effective date.
  `npm run lint` reports zero issues across 128 files, and `npm run unit`
  passes after transpiling 1,141 outputs.
- Added `minimum_shelf_life_days` to ordinary and project-stock FEFO demands,
  including unit-aware ordinary-stock demands and WBS transfers. Each demand
  uses the greater of its own minimum and the shared minimum, which remains a
  floor for all demands. Cross-plant base-unit, dated, unit-aware, and ATP FEFO
  variants now follow the same rule; ordinary methods sharing their demand
  types reject nonzero FEFO options before stock reads. Splits report the
  effective minimum so reservation prevalidation preserves the policy.
  Cost-center FEFO previews and atomic/bulk cost-center reservations now carry
  the same per-demand rule; reservation result rows report its effective value.
  The FEFO stock-balance merge now rejects duplicate batch/location rows with
  conflicting expiry dates instead of silently keeping whichever date arrived
  first, and rejects impossible nonblank expiry dates before allocating them.
  Location-only and location-transfer previews reject shelf-life options before
  reads because those paths cannot validate batch expiry. Regression tests
  cover these checks and both bad-data cases.
  Tests cover different buffers within one request set, the shared floor,
  negative-value rejection before reads, transfer forwarding, and a reservation
  that skips a batch too close to expiry. Cross-plant tests cover base-unit,
  dated, unit-aware, and ATP forwarding plus ordinary allocator rejection.
  `npm run lint` reports zero issues across 128 files, and `npm run unit` passes
  after transpiling 1,141 outputs and running 1,388 test methods. Explicitly
  typing the date difference as an integer also fixes a transpiler inference
  that had treated the day count as a date.
- Added `TRANSFER_WBS_FEFO` and `TRANSFER_WBS_BY_LOCATION` as one-call WBS Q
  stock transfer flows. Each returns its preview, reruns the allocation before
  posting, and refuses the 415/Q movement when the batch or location split has
  changed. Tests cover successful batch/location posting and stale batch or
  preferred-location choices. `npm run lint` passed with zero issues across
  128 files; `npm run unit` exited successfully after transpiling 1,141 outputs.
- Added a second FEFO/location preview before WBS reservation creation and
  compare the full split plan. The one-call paths stop without a write if
  availability, batch expiry, FEFO order, or location priority changes between
  previews. Regression cases cover shared demand IDs, reduced stock, changed
  expiry, a newly available earlier batch, and a newly available preferred
  location. `npm run lint` passed with zero issues across 128 files, and
  `npm run unit` exited successfully after transpiling 1,141 outputs.
- Resolved the test-runner environment issue: native Linux Node is installed at
  `/home/lars/.nvm/versions/node/v22.22.2/bin`. Running
  `PATH=/home/lars/.nvm/versions/node/v22.22.2/bin:$PATH npm test` now passes:
  abaplint reports zero issues across 128 files, transpilation writes 1,140
  outputs, and ABAP Unit exits successfully. Earlier WSL errors came from
  invoking the Windows Node launcher.
- The full suite exposed that `prepare_from_suggestions` accepted impossible
  Gregorian required dates although bulk preparation rejected them. Added the
  missing date check in `build_suggestion_order_request`; the header date was
  already checked. The existing `rejects_bad_po_dates` regression covers it.
- Added `RESERVE_ORDERS_BY_DATE_BULK`, which shares the dated multi-order
  allocation preview and its full-allocation/ATP gates, then commits each
  order independently and continues after a failed create or commit. Results
  preserve each order's messages, reservations, success, test-run, and commit
  status; the top-level result makes partial failure visible. Added coverage
  for failed creates, failed commits, test runs, and continuation after failure.
  Repeated reservation BAPI LUW behavior and stale-stock exposure between
  preview and commits are recorded in `ANOMALIES.md`.
- Added `DELETE_ORDERS_RELEASE_BULK`, which discovers reservations with one
  validated grouped lookup and deletes/commits per order, continuing after an
  order failure. The result includes per-order messages and commit status and
  preserves earlier and later successes. Tests cover continuation after a
  failed delete and test-run behavior; target BAPI transaction behavior is
  noted in `ANOMALIES.md`.
- Sales-order allocation now rejects malformed Gregorian dates returned on
  open schedule lines, covering requested delivery dates and selected material
  availability dates in single- and multi-order previews/reservations. Local
  tests cover malformed EDATU and MBDAT plus no allocation, ATP, or reservation
  write. Bulk order reservation lookup still occurs before sales-order reads in
  the multi-order path.
- Added saved sales-order header mapping for order type, sales area, sold-to,
  customer PO, and document date using `BAPISDORDER_GETDETAILEDLIST` header
  output. The adapter requests these fields through the BAPI's header view.
  Header mapper tests cover the fields. Multi-document BAPI output behavior
  still needs target-SAP verification, recorded in `ANOMALIES.md`.
- Optimized `ZCL_SALES_ORDER_SERVICE->READ_ORDERS` to send the validated list
  through one API dispatch. The BAPI adapter now calls
  `BAPISDORDER_GETDETAILEDLIST` once for all requested sales documents, and the
  delivery repository groups its `VBAP`, `VBUP`, and `VBEP` reads by that list.
  Results retain caller order. Tests verify prevalidation, header mapping, and
  one batch API dispatch; actual BAPI multi-document behavior and grouped SQL
  behavior still need target-SAP verification, recorded in `ANOMALIES.md`.
  `npm test` passed with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and a successful ABAP Unit run.
- Added `ISSUE_PROJECT_WBS_BULK` for base-unit WBS issues. It prevalidates all
  request rows, posts and commits once per WBS, retains results in request
  order, and continues after a posting failure. Tests cover separate commits,
  continuation, prevalidation, test-run mode, and original request indexes.
  Target BAPI and transaction behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_PROJECT_WBS_BULK_UOM`, which converts all source quantities to
  each material's mapped base unit before the first posting call, then delegates
  to the bulk WBS posting flow. Tests cover multi-WBS conversion, batch
  preservation, separate commits, and rejection of a later unsupported unit
  before any write. Target unit ratios and ISO mappings are noted in
  `ANOMALIES.md`.
- Added `RETURN_PROJECT_WBS_BULK` for movement-222 returns across WBS elements.
  It prevalidates all rows, commits each WBS independently, preserves input
  ordering, reports partial failures, and supports test-run mode. Tests cover
  WBS/special-stock/batch mapping, continuation, prevalidation, and simulation.
  Target transaction behavior and the unreferenced-return limitation are
  recorded in `ANOMALIES.md`.
- Added `RETURN_PROJECT_WBS_BULK_UOM`, which converts every source-unit row to
  the mapped base unit before the first movement-222 call. Tests verify
  quantities, base units, batch/WBS mapping, and prevalidation when a later
  conversion is unsupported. Target material ratios and ISO mappings are
  recorded in `ANOMALIES.md`.
- Added atomic bulk WBS issue and return forms. They prevalidate all rows,
  stage one goods-movement BAPI call per WBS, commit once, and roll back the
  group after a create or commit failure. Results expose attempt, commit, and
  rollback state for each row and the group. Target SAP LUW behavior is
  recorded in `ANOMALIES.md`.
- Added unit-aware atomic WBS issue and return wrappers. Shared conversion now
  prepares and validates all source quantities before any BAPI call; the same
  conversion path serves per-WBS bulk and atomic modes. Tests cover conversions
  for both movements and rejection of a later unsupported unit before writes.
- Added `ISSUE_RESERVED_WBS_ITEMS` for selected items on an existing WBS
  reservation. It checks WBS/reservation/item scope and open status, then uses
  the reservation-backed issue service for SAP state validation, unit
  conversion, and posting. New tests cover base posting with alternative-unit
  conversion, simulation, and WBS scope rejection. The full suite also exposed
  a missing storage-location assignment in the shared reservation issue flow;
  it now retains the reservation's location, with production-component tests
  updated for that mapping. `npm test` passed: abaplint found zero issues in
  128 files, transpilation wrote 1,141 outputs, and ABAP Unit succeeded. SAP
  reservation-reference and 221/Q behavior are recorded in `ANOMALIES.md`.
- Added `ISSUE_RESERVED_WBS_ITEMS_BULK` for selected items across multiple WBS
  reservations. It checks every WBS/item scope before posting, then uses the
  reservation issue service's per-reservation material documents, commits, and
  continuation behavior. Tests cover two WBS reservations and rejection of a
  later wrong-WBS row before any issue call. Target multi-call transaction
  behavior is documented in `ANOMALIES.md`.
- Added single and bulk WBS reservation returns. The service requires a
  withdrawn balance but allows finalized items, then uses the reservation
  reversal API to return quantities up to the live withdrawn amount. Tests
  cover alternative-unit return, final-item reversal, and one commit per
  reservation. SAP reversal and `XSTOB` behavior are documented in
  `ANOMALIES.md`. `npm test` passed with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added atomic WBS reservation issues and returns across unique reservations.
  The service stages one reservation-referenced movement per reservation and
  commits once; create, validation, or commit failure rolls back the group.
  Tests cover group commit, later create failure, commit failure, finalized
  item reversal, and the shared suite passes with zero lint issues, 1,141
  transpiler outputs, and successful ABAP Unit. Target LUW behavior is recorded
  in `ANOMALIES.md`.
- Added `RESERVE_WBS_BULK` for direct reservation requests across unique WBS
  elements. It validates dates, stock keys, and every unit conversion before
  the first create; requests commit independently by default or share one
  atomic commit/rollback when requested. Test-run avoids transaction calls.
  Tests cover base-unit conversion, no-write prevalidation, bulk continuation,
  group commit, create and commit rollback, and simulation. `npm test` passed
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit. Target multi-call BAPI behavior is recorded in
  `ANOMALIES.md`.
- Extended `RESERVE_BATCH_ALLOCATION` and `RESERVE_LOCATION_ALLOCATION` to
  accept a distinct required date for each assigned WBS, alongside the existing
  shared-date option. The service validates complete, unique date coverage
  before any create, sends each WBS date to its reservation call, and returns
  the applied date in each result row. Tests cover separate dates for batch and
  location flows, atomic batches, and missing-date rejection before writes.
  Target BAPI date and LUW behavior is recorded in `ANOMALIES.md`. `npm test`
  passed with zero lint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Added `READ_AVAILABLE_STOCK_BULK` with per-request reservation cutoffs and
  detailed batch/location stock rows. It groups by cutoff, deduplicates stock
  keys within each group, and returns rows in request order. Tests verify
  different net availability across horizons, shared results for duplicate
  keys at one cutoff, grouped repository reads, invalid-date prevalidation, and
  empty input behavior. Target grouped query behavior is recorded in
  `ANOMALIES.md`. `npm test` passed with zero lint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added `READ_OPEN_RESERVATIONS_BULK` with an individual required-through date
  per WBS request. It groups repository reads by date, deduplicates WBS elements
  within each group, and preserves request order. Tests cover undated and dated
  reservations, shared request horizons, invalid-date prevalidation, empty
  input, and grouped reads. Target RESB/PRPS query behavior is recorded in
  `ANOMALIES.md`. The complete `npm test` run passed with zero lint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Validation after atomic and unit-aware WBS additions passed: `npm test`
  reported zero abaplint issues across 128 files, transpilation produced 1,141
  outputs, and ABAP Unit exited successfully. The CRLF-aware diff check passed.
- Validation after the WBS bulk additions passed: `npm test` reported zero
  abaplint issues across 128 files, wrote 1,141 transpiler outputs, and exited
  successfully after the ABAP Unit suite. The CRLF-aware diff whitespace check
  also passed.
- Extended `ZCL_PURCHASE_ORDER_SERVICE` to reject impossible Gregorian PO
  document and item delivery dates before `BAPI_PO_CREATE1`. The bulk and
  atomic entry points validate all request dates before their first write;
  suggestion preparation rejects malformed header and required dates too.
  Added cases for bad header dates, bad delivery dates, malformed dates in
  later bulk and atomic requests, and suggestion preparation. SAP
  purchasing-date eligibility is recorded in `ANOMALIES.md`.
- Extended the purchase-order schedule update service to reject malformed
  Gregorian delivery dates before `BAPI_PO_CHANGE`. Single, bulk, and atomic
  forms share the check, and regression coverage verifies invalid dates are
  rejected before any PO update.
- Added `CHANGE_RESV_STOCK_ATOMIC` for coordinated changes across WBS
  reservations. It validates all request fields and item scopes before any
  BAPI call, applies one API call per reservation, and uses one group commit or
  rollback. Test-run performs the same scope checks without BAPI or transaction
  calls. Local tests cover success, pre-write scope rejection, BAPI failure,
  commit failure, and simulation. Target SAP LUW behavior is recorded in
  `ANOMALIES.md`. Initial lint caught identifiers over ABAP's 30-character
  method-name limit; shortening them resolved the issue. Final `npm test`
  passed with zero lint issues across 126 files, 1,136 transpiler outputs, and
  successful ABAP Unit execution.
- Added `CHANGE_RESV_QTY_ATOMIC` for all-or-nothing quantity updates across WBS
  reservations. It validates all item scopes, entry units, UOM conversions,
  and withdrawn-quantity limits before BAPI writes, then shares one commit or
  rollback. Tests cover conversion-aware success, pre-write scope rejection,
  BAPI failure, commit failure, and test-run. Target SAP LUW behavior is
  recorded in `ANOMALIES.md`. Initial lint caught a misaligned parameter in
  the API payload expression; the explicit mapping loop resolved it. Final
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `RESCHEDULE_ITEMS_ATOMIC` for required-date updates across multiple WBS
  reservations. It validates the complete request and every item scope before
  BAPI writes, then shares one commit or rollback; test-run skips all update and
  transaction calls. Tests cover group success, pre-write scope rejection,
  BAPI failure, commit failure, and simulation. Target repeated-call LUW
  behavior is recorded in `ANOMALIES.md`. `npm test` passed with zero lint
  issues across 126 files, 1,136 transpiler outputs, and successful ABAP Unit
  execution.
- Added `SET_RESV_FINAL_ATOMIC` to mark open or reset finalized WBS reservation
  items across multiple reservations in one transaction. It prevalidates every
  requested item state before writes and supports test-run. Tests cover both
  mark and reset success, invalid current state, BAPI failure, commit failure,
  and simulation. Target SAP LUW behavior is documented in `ANOMALIES.md`.
  Initial lint found parameter alignment errors in the test calls; aligning the
  `it_requests` parameter resolved them. `npm test` passed with zero lint
  issues across 126 files, 1,136 transpiler outputs, and successful ABAP Unit
  execution.
- Added `DELETE_RESV_ITEMS_ATOMIC` for WBS reservation-item deletions across
  multiple reservations. It validates every item scope before the first BAPI
  call, then uses one group commit or rollback. Tests cover group success,
  pre-write scope rejection, a later API failure, commit failure, and test-run.
  Target SAP repeated-call LUW behavior is recorded in `ANOMALIES.md`.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `DELETE_RESERVATIONS_ATOMIC` for full reservation cancellation across
  multiple reservation numbers. It prevalidates the complete unique list and
  shares one live commit or rollback; test-run forwards SAP's simulation mode
  and makes no transaction call. Tests cover success, duplicate rejection,
  later BAPI failure, commit failure, and simulation. Target SAP repeated-call
  LUW behavior is recorded in `ANOMALIES.md`. Initial lint caught duplicate
  test method names with item deletion; renaming the whole-reservation cases
  resolved it. `npm test` passed with zero lint issues across 126 files, 1,136
  transpiler outputs, and successful ABAP Unit execution.

- Added optional atomic creation to `RESERVE_BATCH_ALLOCATION` and
  `RESERVE_LOCATION_ALLOCATION`. With `iv_atomic = abap_true`, allocation
  splits for all WBS elements are validated before BAPI calls, then the staged
  reservations share one commit or rollback. Test-run simulates each WBS
  request without transaction calls. Aggregate results expose row messages and
  report committed state when all independent live reservations succeeded.
  Tests cover both allocation modes, full prevalidation, BAPI and commit
  failures, duplicate returned numbers, and simulation. Target LUW and
  reservation-number behavior are documented in `ANOMALIES.md`. `npm test`
  passed with zero lint issues across 126 files, 1,136 transpiler outputs, and
  successful ABAP Unit execution.
- Added Gregorian calendar validation for WBS reservation required dates.
  Added reusable `ZCL_DATE_VALIDATION` and applied it to direct and allocation-
  based reservation creation, single/bulk/atomic rescheduling, project-stock
  cutoff reads, reservation coverage horizons, and FEFO as-of dates. Invalid
  numeric dates, impossible month/day combinations, and invalid leap days are
  rejected before reads or writes; optional empty cutoffs remain supported.
  Tests cover Gregorian century rules, invalid input across entry points, and
  rejection before repository access. SAP business-date and planning-horizon
  behavior remains authoritative and is recorded in `ANOMALIES.md`. `npm test`
  passed with zero lint issues across 128 files, 1,140 transpiler outputs, and
  successful ABAP Unit execution.
- Extended `ZCL_DATE_VALIDATION` to stock-service receipt cutoffs, FEFO status
  dates, dated allocation demands, and their unit-aware, cross-plant, batch, and
  ATP entry points. Invalid caller dates are rejected before UOM, stock, or ATP
  access. Added ABAP Unit cases for impossible demand, unit-aware, and FEFO
  dates, including pre-read rejection. Documentation records the remaining
  target-SAP planning-date checks. Static lint passed with zero issues across
  128 files before these integration cases were added. The final `npm test` and
  lint reruns could not start because the WSL 1 Node launcher rejected this
  environment before transpilation or ABAP Unit execution.
- Extended Gregorian date validation to goods-movement posting and document
  dates, plus optional cancellation posting dates. Bulk cancellation validates
  every supplied date before the first BAPI call, preserving group preflight.
  Added tests for invalid movement headers and cancellation dates; run the
  repository verifier after the WSL 1 Node launcher issue is resolved.
- Extended Gregorian date validation to stock-transfer purchase-order schedule
  dates from dated allocations, FEFO allocations, and caller-supplied batch
  dates. Invalid values are rejected while building requests, before any order
  create call. Regression cases cover dated and batch requests. The full test
  command remains unavailable because the WSL 1 Node launcher exits before
  lint, transpilation, or ABAP Unit starts; targeted source checks pass.

## 2026-10-13

- Added `RESCHEDULE_RESERVATION_ITEMS` and its bulk form to change the required
  date on selected open WBS reservation items. The service verifies item scope,
  supports scope-only test runs, and commits or rolls back each reservation
  independently. Tests cover live change, wrong-WBS rejection, simulation,
  commit failure, and bulk continuation after a BAPI error. Classic BAPI field
  and target LUW behavior still require SAP verification in `ANOMALIES.md`.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `CHANGE_RESERVATION_ITEM_QTY` and its bulk form for open WBS reservation
  items. Callers provide a new total quantity in each item's current entry unit;
  the service checks unit identity, converts to base units before comparing with
  withdrawn quantity, and commits each reservation independently. Tests cover
  a BOX entry quantity against an EA base unit, reductions above withdrawn
  quantity, rejection at the withdrawn quantity, test-run, and bulk continuation
  after a BAPI error. Classic BAPI fields and target availability-check behavior
  remain to verify in `ANOMALIES.md`. `npm test` passed with zero lint issues
  across 126 files,
  1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `CHANGE_RESERVATION_ITEM_STOCK` and its bulk form to adjust open WBS
  reservation items' storage location and/or batch. Per-field flags allow an
  explicit value or clear operation. The service verifies WBS scope and commits
  each reservation independently. Tests cover combined location/batch changes,
  batch clearing, scope rejection, test-run, commit rollback, and bulk
  continuation. Target BAPI fields and availability checks are in
  `ANOMALIES.md`. `npm test` passed with zero lint issues across 126 files,
  1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `MARK_RESERVATION_ITEMS_FINAL` and `RESET_RESERVATION_ITEMS_FINAL`,
  with bulk forms, for WBS reservation items. `READ_RESERVATION_ITEMS` now
  includes active final and fully withdrawn rows with their final-issue state.
  The service verifies open or finalized state and scope, supports test-run, and
  commits each reservation independently. Tests cover the raw reader, live mark
  and reset, scope rejection, simulation, and bulk continuation after a BAPI
  error. Classic BAPI fields and target behavior are recorded in `ANOMALIES.md`.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution.
- Added `READ_RESERVATION_COVERAGE_BULK` for keyed WBS coverage requests with
  independent required-through dates. It batches distinct WBS elements by date,
  returns results in caller order, rejects blank or duplicate request IDs, and
  skips reads for empty input. Tests cover mixed horizons, query grouping,
  validation, and empty input. `npm test` passed with zero lint issues across
  126 files, 1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `READ_RESERVATION_COVERAGE`, grouping project stock and open reservation
  quantity by WBS/material/plant in material base units. It reports free stock,
  reservation shortfall, open-item count, and full-coverage status; it supports
  the required-through date filter and excludes unlocated stock that previews
  cannot allocate. Tests cover exact and broad reservations, date cutoff,
  unlocated stock, and an uncovered reservation. `npm test` passed with zero
  lint issues across 126 files, 1,136 transpiler outputs, and successful ABAP
  Unit execution. Query limitations are recorded in `ANOMALIES.md`.
- Added `DELETE_RESERVATION_ITEMS` and `DELETE_RESERVATION_ITEMS_BULK` for
  WBS-scoped item cancellation. The service validates item ownership against
  open Q reservations before calling SAP, simulates scope checks without BAPI
  writes, and commits each reservation independently. Tests cover live deletion,
  wrong-WBS rejection, simulation, commit failure, and continuing after a failed
  reservation.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution. Target change-BAPI behavior is
  documented in `ANOMALIES.md`.
- Added `READ_OPEN_RESERVATIONS` to return open Q reservation items for scoped
  WBS elements, with reservation item identity and remaining open
  quantity. It filters rows outside requested WBS elements, validates item
  identities, rejects duplicates, and returns date/document/item order. Tests
  cover open quantity, WBS filtering, duplicate rejection, and the empty-input
  path. An optional required-through date filters later dated items and keeps
  undated rows; tests cover this cutoff.
  `npm test` passed with zero lint issues across 126 files, 1,136 transpiler
  outputs, and successful ABAP Unit execution. Target SQL and DDIC checks are in
  `ANOMALIES.md`.
- Added `DELETE_RESERVATION` and `DELETE_RESERVATIONS_BULK` for WBS reservation
  cancellation. Bulk requests validate before processing and return per-number
  results while each deletion commits independently. Tests cover live delete,
  test-run without a transaction, duplicate rejection, and continuing after an
  individual failure and commit failure. `npm test` passed with zero lint
  issues across 126 files, 1,136 transpiler outputs, and successful ABAP Unit
  execution. Target BAPI and deletion eligibility checks are recorded in
  `ANOMALIES.md`.
- Added `RESERVE_BATCH_ALLOCATION` and `RESERVE_LOCATION_ALLOCATION` to bridge
  project-stock previews into WBS reservations. They validate assignments and
  split totals before writing, combine repeated stock-key splits, and create one
  independently committed reservation per WBS. Short allocations are rejected
  by default, with partial reservation opt-in. Tests cover two-WBS batch
  grouping, duplicate split aggregation, batchless location mapping, and
  default shortfall rejection. `npm test` passed with zero lint issues across
  126 files, 1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `ZCL_PROJECT_RESV_SERVICE=>RESERVE_FOR_WBS` with a dedicated
  `BAPI_RESERVATION_CREATE1` adapter for project/WBS reservations. It maps
  movement type 221 and WBS assignment, converts alternative units to base
  units, and supports test-run, commit, and rollback handling. Tests cover
  multi-item creation, BOX-to-EA conversion, duplicate-key rejection,
  simulation, create failure, and commit failure. Target BAPI fields,
  reservation special-stock output, and project configuration checks are
  documented in `ANOMALIES.md`. `npm test` passed with zero lint issues across
  126 files, 1,136 transpiler outputs, and successful ABAP Unit execution.
- Added `READ_AVAILABLE_STOCK` to `ZCL_PROJECT_STOCK_SERVICE` for direct
  material/plant/WBS balance inquiries. It returns located batch and batchless
  rows with net available quantity and material base unit, and accepts the same
  reservation-date cutoff as the previews. Reservation netting runs across
  both stock types together so broad reservations are deducted only once.
  Tests cover key scoping, mixed batch stock, batch-specific and broad
  reservations, and cutoff behavior. `npm test` passed with zero lint issues
  across 122 files, 1,129 transpiler outputs, and successful ABAP Unit
  execution. Target SAP query and DDIC behavior remains noted in
  `ANOMALIES.md`.
- Added direct project-WBS goods issues (movement 221) and returns (movement
  222), with unit-aware variants that convert to supplied material base-unit
  mappings. The BAPI adapter maps WBS_ELEMENT, and the service validates the
  project account assignment and rejects mixed account keys. Tests cover both
  movements, batch preservation, BOX-to-EA conversion, and missing-WBS
  rejection. `npm test` passed with zero lint issues across 118 files, 1,118
  transpiler outputs, and successful ABAP Unit execution. SAP's WBS requirement
  and target-system checks are recorded in `ANOMALIES.md`.
- Added `ISSUE_PROJECT_WBS_ALLOCATION` to post location splits from the stock
  service's unit-aware allocation result. It maps request IDs to WBS elements,
  validates demand/split totals and unit mappings, and requires full allocation
  by default with partial posting opt-in. Tests cover mixed WBS assignments,
  multiple locations, and default shortfall rejection. `npm test` passed with
  zero lint issues across 118 files, 1,118 transpiler outputs, and successful
  ABAP Unit execution.
- Added `ISSUE_PROJECT_WBS_BATCH_ALLOC` for explicit-batch and FEFO unit
  allocation results. It retains each batch/location split under the mapped
  WBS element and validates totals and unit mappings before posting. Tests
  cover multiple dated batches and storage locations. `npm test` passed with
  zero lint issues across 118 files, 1,118 transpiler outputs, and successful
  ABAP Unit execution.
- Added project special-stock `Q` support to direct WBS issue/return methods,
  including their UOM variants. The adapter maps `SPEC_STOCK`; blank remains
  the unrestricted-stock default, and allocation-based issue paths remain
  restricted to unrestricted stock. Tests cover Q propagation through all four
  methods and rejection of unsupported special-stock codes. `npm test` passed
  with zero lint issues across 118 files, 1,118 transpiler outputs, and
  successful ABAP Unit execution.
- Added `ZCL_PROJECT_STOCK_REPOSITORY` for Q stock reads from `MSPR` joined to
  `PRPS`, and `ZCL_PROJECT_STOCK_SERVICE=>PREVIEW_FEFO` for WBS-scoped,
  unit-aware batch allocation from project stock. It honors expiry and location
  filters, shares stock across demands, and returns WBS assignments with the
  batch splits. `ISSUE_PROJECT_WBS_BATCH_ALLOC` now accepts special stock Q so
  the preview can be posted as movement 221. Tests cover BOX-to-EA allocation,
  FEFO ordering, WBS separation, shared balances, and Q propagation. `npm test`
  passed with zero lint issues across 122 files, 1,127 transpiler outputs, and
  successful ABAP Unit execution. SQL target-system validation and the
  batch-managed/valuated-unrestricted scope are recorded in `ANOMALIES.md`.
- Added `PREVIEW_BY_LOCATION` for batchless Q project stock. It aggregates
  unbatched `PRLAB` balances by storage location, applies location priority,
  converts units, and retains WBS assignments; batched rows and explicit batch
  demands are excluded. `ISSUE_PROJECT_WBS_ALLOCATION` now accepts special
  stock Q for this result. Tests cover unit conversion, priority ordering,
  batch exclusion, and Q propagation. `npm test` passed with zero lint issues
  across 122 files, 1,127 transpiler outputs, and successful ABAP Unit
  execution. The caller must pair the Q flag with a project-stock preview.
- Added `TRANSFER_PROJECT_WBS_STOCK` for same-plant, same-location movement
  415/Q transfers between WBS elements. It converts material units, retains
  batches, sets the receiving stock keys, and maps destination/source WBS
  values to `WBS_ELEMENT` and `VAL_WBS_ELEM`; same-WBS transfers are rejected.
  Tests cover the Q movement,
  source/destination mapping, BOX-to-EA conversion, batch retention, and
  self-transfer rejection. `npm test` passed with zero lint issues across 122
  files, 1,127 transpiler outputs, and successful ABAP Unit execution. SAP
  grouping-WBS eligibility and BAPI behavior are documented in `ANOMALIES.md`.
- Added `PREVIEW_TRANSFER_FEFO` to allocate dated project-stock batches from a
  source WBS for transfer to a destination WBS, plus `TRANSFER_WBS_BATCH_ALLOC`
  to validate and post those splits as 415/Q. The poster checks demand and
  batch totals, retains source/destination assignments and batches, and
  requires full allocation by default. Tests cover FEFO selection, WBS mapping,
  multiple batch splits, and default shortfall rejection. `npm test` passed
  with zero lint issues across 122 files, 1,127 transpiler outputs, and
  successful ABAP Unit execution. SAP validates grouping-WBS eligibility and
  stock at posting time.
- Added `PREVIEW_TRANSFER_BY_LOCATION` and `TRANSFER_WBS_LOCATION_ALLOC` for
  batchless project-stock transfers. The preview scopes availability to each
  source WBS and returns prioritized storage-location splits with the
  source/destination WBS assignments; the poster validates totals and posts
  movement 415/Q with full allocation required by default and partial posting
  available by opt-in. Tests cover batched-row exclusion, location splits, WBS
  mapping, default shortfall rejection, and partial posting. `npm test` passed
  with zero lint issues across 122 files, 1,127 transpiler outputs, and
  successful ABAP Unit execution. SAP validates grouping-WBS eligibility and
  stock at posting time.
- Made project-stock previews subtract outstanding Q reservations from the
  same WBS/material/plant before allocating. The repository reads RESB rows with
  `SOBKZ = 'Q'`, excludes deleted and final-issued rows, and the service nets
  `BDMNG - ENMNG` against matching location/batch balances, applying specific
  reservations first and keeping any over-reservation within its WBS. Tests
  cover exact-batch, location-specific, partially withdrawn, and cross-WBS
  reservations. `npm test` passed with zero lint issues across 122 files,
  1,127 transpiler outputs, and successful ABAP Unit execution. The RESB/PRPS
  query still needs validation against the target SAP release.
- Restricted reservation deductions to the stock rows eligible for each
  project preview before applying them. This prevents unlocated rows and
  batched rows in the batchless location path from absorbing reservations and
  inflating eligible balances. Batch-specific reservations are excluded from
  the batchless path. Regression tests cover both preview modes.
  `npm test` passed with zero lint issues across 122 files, 1,127 transpiler
  outputs, and successful ABAP Unit execution.
- Added material-level `MCH1-VFDAT` fallback when the project-stock repository
  has no plant-level `MCHA-VFDAT`, matching the generic stock repository's
  batch-expiry lookup. The existing MCH1 SAP stub supports linting and
  transpilation. `npm test` passed with zero lint issues across 122 files,
  1,127 transpiler outputs, and successful ABAP Unit execution. The local suite
  does not execute either batch-master SQL query; the target-release query
  check is recorded in `ANOMALIES.md`.
- Added `RETURN_FROM_SALES_ORDER` for direct movement-232 returns and
  `RETURN_FROM_SALES_ORDER_UOM` for alternative-unit quantities. Both preserve
  sales order, item, and batch assignments; the UOM form converts to base
  units and checks the supplied ISO map. Tests cover mapping, BOX-to-base
  conversion, and invalid quantity rejection. `npm test` passed with zero lint
  issues across 118 files, 1,118 transpiler outputs, and successful ABAP Unit
  execution. Movement semantics and target-release checks are in
  `ANOMALIES.md`.
- Added `RETURN_TO_PRODUCTION_ORDER` for direct movement-262 component
  returns and `RETURN_TO_PRODUCTION_ORDER_UOM` for alternative-unit requests.
  Both retain the supplied production order, plant/location, and batch; the
  UOM form converts to the material base unit. Tests cover return mapping,
  BOX-to-base conversion, and invalid quantities. `npm test` passed with zero
  lint issues across 118 files, 1,118 transpiler outputs, and successful ABAP
  Unit execution. SAP target behavior and the unreferenced-return limitation
  are recorded in `ANOMALIES.md`.
- Added `REVERSE_TO_COST_CENTER` for direct movement-202 returns without a
  reservation or source-document key, plus `REVERSE_TO_COST_CENTER_UOM` for
  alternative-unit quantities. The UOM form converts to the material base unit
  and checks the supplied base-unit/ISO map. Tests cover 202 mapping, batch and
  cost-center preservation, BOX-to-base conversion, and invalid quantities.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution. SAP's unreferenced and partial
  reversal behavior and target BAPI checks are recorded in `ANOMALIES.md`.
- Added `ISSUE_COST_CENTER_BATCHES` and `ISSUE_COST_CENTER_FEFO` to post
  multi-demand explicit-batch and FEFO previews. They preserve each demand's
  cost center, batch, and location splits, validate preview totals and unit
  mappings, and post one 201 document. Full allocation is required by default;
  partial issue is opt-in. Tests cover mixed cost centers and units, batch and
  FEFO split preservation, partial posting, shortfall rejection, and split
  mismatch. `npm test` passed with zero lint issues across 118 files, 1,118
  transpiler outputs, and successful ABAP Unit execution. Target multi-account
  BAPI behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_COST_CENTER_LOCATIONS` to post multi-demand cost-center
  location previews together in one movement-201 document while retaining each
  demand's cost center. It validates unique request IDs, base-unit mappings,
  summary totals, and storage split sums; full allocation is the default and
  partial issue is opt-in. Tests cover mixed cost centers and units, multiple
  location lines, partial posting, shortfall rejection, and split mismatch.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution. Multi-account-assignment BAPI
  behavior in the target release is recorded in `ANOMALIES.md`.
- Added `ISSUE_COST_CENTER_ALLOCATION` to turn a successful cost-center
  preview into 201 goods movement items while preserving its storage-location
  and batch splits. It requires a matching base-unit/ISO mapping, rejects a
  result that already carries a reservation number, and requires full
  allocation by default. Tests cover location and batch issues, partial issue,
  shortfall rejection, reservation-result rejection, and split mismatch.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution.
- Added `ISSUE_SALES_ORDER_ALLOCATION` to turn a successful single-order stock
  preview into movement 231 items. It preserves location and selected-batch
  splits, requires matching base-unit/ISO mappings, reconciles both preview
  summaries and split totals, and defaults to requiring full allocation.
  Unrestricted-stock only; preview stock is not re-read at posting time. Tests
  cover location and batch posting, partial posting, shortfall rejection, and
  split mismatch. `npm test` passed with zero lint issues across 118 files,
  1,118 transpiler outputs, and successful ABAP Unit execution.
- Added `ISSUE_UNPLANNED_PROD_BULK`, which accepts distinct production
  orders and posts a separate movement 261 document for each. It prevalidates
  the complete batch before the first BAPI call, continues after per-order
  failures, and reports attempted, committed, successful, and failed rows.
  Tests cover multiple order mapping, continuation after failure, and rejection
  of a malformed later request before posting, plus test-run simulation.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution.
- Added direct sales-order issues with movement type 231 and unplanned
  production-order issues with movement type 261. Both have unit-aware forms
  that convert quantities to material base units and validate caller-provided
  base-unit/ISO mappings. The production method explicitly supports withdrawals
  outside the order component list; reservation-backed issue remains the path
  that updates reservation quantities. Tests cover field mapping, conversion,
  simulation, commit, and invalid-unit/input rejection. `npm test` passed with
  zero lint issues across 118 files, 1,118 transpiler outputs, and successful
  ABAP Unit execution. Target SAP behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_TO_COST_CENTER` for direct 201 goods issue without a reservation
  key, plus `ISSUE_TO_COST_CENTER_IN_UNIT` for alternative-unit quantities. The
  methods post one document with standard simulation and transaction handling;
  the unit-aware form converts to base quantities and checks caller-provided
  base-unit/ISO mappings. Tests cover field mapping, conversion, mapping and
  unit rejection, blank cost center, invalid quantity, commit, and simulation.
  `npm test` passed with zero lint issues across 118 files, 1,118 transpiler
  outputs, and successful ABAP Unit execution. Target stock, UOM, batch, and
  authorization behavior are recorded in `ANOMALIES.md`.
- Added cost-center-scoped reservation issue and reversal entry points for
  base-unit and alternative-unit requests, including independent
  per-reservation bulk posting. Issues require open items under the requested
  cost center; reversals use a key-based `RESB`/`RKPF` lookup so fully issued
  items remain in scope. Tests cover successful issue/reversal, rejection of a
  wrong cost center before movement, and BOX-to-base conversion for both issue
  directions. `npm run lint` passed with zero issues across 118 files;
  `npm run unit` passed with 1,118 transpiler outputs and successful ABAP Unit
  execution. Snapshot timing, SQL validation, and target authorization are
  recorded in `ANOMALIES.md`.
- Added unit-aware goods issue and reversal methods, including per-reservation
  bulk variants. Each line's quantity converts through the material UOM ratio
  into the reservation item's base unit before open/withdrawn quantity checks;
  SAP receives the converted quantity and reservation ISO unit. Tests cover
  single issue, single/bulk reversal, grouped multi-item issue, unknown units,
  and base-unit mismatch rejection.
  `npm run lint` passed with zero issues across 118 files; `npm run unit`
  passed with 1,118 transpiler outputs and successful ABAP Unit execution.
  Target MARM ratios and rounding are recorded in `ANOMALIES.md`.
- Added `POST_GOODS_ISSUE_BULK` and `POST_GOODS_ISSUE_REVERSAL_BULK` for
  independent reservation movement documents. Requests are grouped by
  reservation in first-seen order; selected items for one reservation share a
  document, while read, validation, or posting failures leave later groups
  eligible to proceed. Added success, read/commit failure continuation,
  simulation, reversal, duplicate-key prevalidation, and empty-input tests.
  `npm run lint` passed with zero issues across 118 files; `npm run unit`
  passed with 1,118 transpiler outputs and successful ABAP Unit execution.
  Target BAPI grouping and commit behavior is recorded in `ANOMALIES.md`.
- Added `RESERVE_COST_CENTERS_BULK` for independent reservation creation. It
  prevalidates request keys and shared options, then processes demands in caller
  order with a separate reservation and commit per successful demand. Failures
  roll back that demand and later demands continue; test runs skip commits.
  Tests cover success, API and commit failure continuation, simulation,
  duplicate request keys, and empty input. `npm run lint` passed with zero
  issues across 118 files; `npm run unit` passed with 1,118 transpiler outputs
  and successful ABAP Unit execution. Target LUW behavior is recorded in
  `ANOMALIES.md`.
- Added `READ_CC_RESERVATIONS_BULK` to read open reservation items for multiple
  cost centers with one repository call. Results preserve caller order, empty
  centers succeed, and blank/duplicate center keys or malformed repository
  rows fail validation. Tests cover grouping, order, input errors, duplicate
  rows, and empty input. `npm test` passed: zero abaplint issues across 118
  files, 1,118 transpiler outputs, and successful ABAP Unit execution. Target
  SQL validation is recorded in `ANOMALIES.md`.
- Added `DELETE_CC_RESERVATION_ITEMS` to release selected open items without
  deleting their entire reservation document. The service verifies cost-center
  scope and open status before using `BAPI_RESERVATION_CHANGE`, and commits or
  rolls back the update. Test runs validate the local snapshot only. Tests cover
  selective deletion, malformed and unscoped keys, simulation, and API/commit
  rollback; BAPI details are recorded in `ANOMALIES.md`. `npm test` passed:
  zero abaplint issues across 118 files, 1,118 transpiler outputs, and
  successful ABAP Unit execution.
- Added `DELETE_RESERVATION_ITEMS_BULK` to apply selected-item deletion across
  reservation documents. It prevalidates all request keys, rejects duplicate
  reservation groups, commits each document separately, and continues after
  per-document failures. Tests cover partial success, simulation,
  prevalidation, and empty input. `npm test` passed: zero abaplint issues
  across 118 files, 1,118 transpiler outputs, and successful ABAP Unit
  execution. BAPI LUW validation is recorded in `ANOMALIES.md`.
- Added `READ_COST_CENTER_RESERVATIONS` to list open movement-type 201
  reservation items by header cost center. The repository joins `RESB` to
  `RKPF`, returns required, withdrawn, and open quantities plus item identity,
  and orders the result by material, plant, and requirement date. The service
  validates reservation keys, cost-center scope, quantities, and duplicate
  items. Added success, malformed-row, duplicate-row, and blank-key tests; SQL
  and status filters are documented in `ANOMALIES.md`. `npm test` passed: zero abaplint
  issues across 118 files, 1,116 transpiler outputs, and successful ABAP Unit
  execution.
- Added opt-in MBDAT scheduling to single- and multi-order sales-order previews
  and reservations. The delivery repository reads `VBEP-MBDAT`; allocation,
  ATP checks, and reservation requirement dates can use it instead of
  `VBEP-EDATU`. Single-order date-prioritized allocations sort by MBDAT. Open
  items without a dated schedule line are rejected in this mode; MBDAT alone is
  sufficient when EDATU is blank. Added
  allocation, reservation, ATP-date, missing-date, and invalid-flag tests;
  target SAP field population is recorded in `ANOMALIES.md`.
  `npm test` passed: zero abaplint issues across 116 files, 1,112 transpiler
  outputs, and successful ABAP Unit execution.
- Added `DELETE_RESERVATIONS_BULK` for independent cost-center reservation
  deletion. It validates the entire list before calling SAP, commits each
  document separately, continues after API or commit failures, and returns
  per-reservation messages and transaction status. Added tests for partial
  success, commit failure continuation, simulation, and prevalidation.
  `npm test` passed: zero abaplint issues across 116 files, 1,112 transpiler
  outputs, and successful ABAP Unit execution.
- Added `DELETE_RESERVATIONS` to the cost-center reservation service. It
  prevalidates reservation numbers, calls `BAPI_RESERVATION_DELETE` for each
  complete document, supports test runs, and commits once or rolls back after
  API/commit errors. Added tests for success, simulation, both rollback paths,
  and invalid lists. SAP eligibility and multi-document LUW behavior are
  recorded in `ANOMALIES.md`. `npm test` passed: zero abaplint issues across
  116 files, 1,112 transpiler outputs, and successful ABAP Unit execution.
- Extended `READ_CONFIRMATIONS_BULK` to return each confirmation's raw yield,
  rework, and scrap quantities with the AFRU entry unit. Expanded the local
  AFRU stub and added service mapping assertions. SAP documents these as
  separate confirmation quantities; local values remain unconverted and
  reversal quantity semantics need target-system validation, recorded in
  `ANOMALIES.md`. `npm test` passed: abaplint found zero issues across 116
  files, transpilation wrote 1,112 outputs, and all ABAP Unit tests passed.
- Added `CREATE_CONFIRMATIONS_ATOMIC` for production-order time tickets. The
  adapter can defer its normal per-ticket commit so the service can commit the
  group once or roll it back after a BAPI or commit failure. Its `iv_test_run`
  option stages and rolls back the complete group; result flags distinguish a
  successful simulation from committed confirmations, and generated keys are
  documented as provisional. Tests cover shared commit, API and commit failure,
  test-run rollback, and invalid test-run values. `npm test` passed: abaplint
  found zero issues across 116 files, transpilation wrote 1,112 outputs, and
  all ABAP Unit tests passed. Target-system LUW and automatic goods-movement
  behavior is recorded in `ANOMALIES.md`.

## 2026-10-11

- Added `PREPARE_FROM_SUGGESTIONS` to `ZCL_PURCHASE_ORDER_SERVICE`. It returns
  the validated single-PO request with selected sources, schedule lines, and
  converted quantities without calling the PO API; creation submits that same
  request. Tests cover source and unit mapping plus no-write preparation.
- Added `PREPARE_FROM_SUGGESTIONS_BULK` to expose the validated PO request
  groups before writing. Bulk and atomic suggestion creation now share those
  prepared groups. Tests cover vendor grouping, original suggestion indexes,
  converted quantities, and no-write preparation. `npm.cmd test` passed with
  zero abaplint issues across 116 files and 1,156 transpiler outputs; all unit
  tests passed.
- Added `PREPARE_FROM_REQUISITION_ITEMS` to the PO service. It validates
  selected PR rows and returns the header plus remaining-quantity PO items and
  PR references without calling the PO API. `CREATE_FROM_REQUISITION_ITEMS`
  now submits this prepared request. Tests verify the request and the no-write
  preparation path. `npm.cmd test` passed with zero abaplint issues across 116
  files and 1,156 transpiler outputs; all unit tests passed.
- Added `PREPARE_FROM_REQUISITIONS` for grouped PO conversion from selected PR
  items. It validates all references and returns first-seen vendor/organization
  groups with remaining quantities; bulk and atomic creation now consume this
  same prepared list. Tests cover grouping, item mapping, and no-write preview.
  `npm.cmd test` passed with zero abaplint issues across 116 files and 1,156
  transpiler outputs; all unit tests passed.
- Added `PREPARE_FROM_SUGGESTIONS`, `PREPARE_FROM_SELECTED_SOURCES`, and
  `PREPARE_FROM_QUOTA_SPLITS` to the purchase-requisition service. They validate
  and map direct replenishment rows, caller-selected sources, or reconciled
  quota shares into the exact PR request without an API call. All matching
  create methods now submit those prepared requests, preserving source indexes
  and unit conversions. Tests cover split quantities, source/unit mapping,
  quota reconciliation, and no-write preparation. `npm.cmd test` passed with
  zero abaplint issues across 116 files and 1,156 transpiler outputs; all unit
  tests passed.
- Added `READ_CONFIRMATIONS_BULK` to retrieve production-operation time
  confirmations by order from AFRU and join AFVC for operation/sequence data.
  Results preserve confirmation number/counter, posting date, final flag, and
  reversal status; empty results are reported per order. The repository and
  service validate requested orders and returned confirmation keys.
  `npm.cmd test` passed with zero abaplint issues across 116 files and 1,156
  transpiler outputs; all unit tests passed.
- Added `READ_OPERATIONS_BULK` for production and process orders. It reads the
  AFKO routing key and joins AFVC to return ordered operations, including their
  internal counter, sequence, operation/suboperation numbers, description, and
  control key. Results preserve request order, report empty orders, and reject
  foreign or duplicate repository rows before grouping. `npm.cmd test` passed
  with zero abaplint issues across 116 files and 1,156 transpiler outputs; all
  unit tests passed. Target table/query details remain in `ANOMALIES.md`.
- Added per-operation production time-ticket confirmations through
  `BAPI_PRODORDCONF_CREATE_TT`. Requests carry the order, operation and
  sequence, posting date, yield/scrap/rework quantities, ISO unit, final flag,
  and optional reservation clearing. The adapter closes each SAP LUW directly
  after the BAPI call; the service maps detail-return keys and messages and
  continues after failures. Local validation, mapper, bulk continuation, and
  commit-failure tests were added; SAP's BAPI call and automatic inventory
  effects still require target-system verification.
- Added atomic and per-confirmation bulk cancellation through
  `BAPI_PRODORDCONF_CANCEL`. Requests require unique confirmation/counter pairs
  and a posting date; the service maps SAP messages, shares rollback for atomic
  groups, and commits bulk cancellations independently while continuing after
  errors. `npm.cmd test` passed: abaplint found zero issues across 116 files,
  transpilation wrote 1,151 outputs, and all 1,024 ABAP Unit methods passed.
- Added atomic and per-operation bulk release for production-order operations
  through `BAPI_PRODORD_RELEASE_OPERATION`. Requests use unique order/operation
  keys and four-character internal operation numbers; atomic release shares one
  commit/rollback while bulk release commits each operation and continues after
  errors. Adapter tests cover detail-message mapping; service tests cover
  commits, rollback, continuation, and key validation. `npm.cmd test` passed:
  abaplint found zero issues across 116 files, transpilation wrote 1,151
  outputs, and all 1,019 ABAP Unit methods passed.
- Added atomic and per-order bulk quantity/date changes for production orders
  through `BAPI_PRODORD_CHANGE`. Requests explicitly select quantity with its
  unit, basic start date, and/or basic finish date; the adapter sets matching
  X-structure flags. The service prevalidates the full request, supports shared
  rollback or independent commits, and continues bulk processing after
  failures. `npm.cmd test` passed: abaplint found zero issues across 116 files,
  transpilation wrote 1,150 outputs, and all 1,014 ABAP Unit methods passed.
- Extended `ZCL_PROD_ORDER_READ_SERVICE->READ_ORDERS_BULK` with active system
  and user statuses for production and process orders. The repository filters
  inactive JEST rows and resolves language-specific text from TJ02T or TJ30T;
  status codes remain available when a translation is missing. Added SAP table
  stubs for JEST and status texts, and extended AUFK with its object number and
  status profile. `npm.cmd test` passed: abaplint found zero issues across 116
  files, transpilation wrote 1,148 outputs, and all 1,007 ABAP Unit methods
  passed.
- Added atomic and per-order bulk deletion-indicator operations for production
  orders through `BAPI_PRODORD_SET_DEL_INDICATOR`. They apply DLT after SAP has
  set DLFL; atomic mode shares one commit/rollback, while bulk mode continues
  after per-order failures. Tests cover adapter mapping, rollback, commit
  failures, continuation, and prevalidation. `npm.cmd test` passed: abaplint
  found zero issues across 116 files, transpilation wrote 1,145 outputs, and
  all 1,006 ABAP Unit methods passed.
- Added `CLOSE_ORDERS_ATOMIC` and `CLOSE_ORDERS_BULK` to the production-order
  service through `BAPI_PRODORD_CLOSE`. Atomic close shares one commit and
  rolls back the group on a BAPI or commit error; bulk close commits each order
  and continues after failures. Tests cover mapping, rollback, continuation,
  commit errors, and request validation. `npm.cmd test` passed: abaplint found
  zero issues across 116 files, transpilation wrote 1,145 outputs, and all
  1,000 ABAP Unit methods passed.
- Added `ZCL_PROD_ORDER_READ_SERVICE->READ_ORDERS_BULK` for production and
  process orders. It groups all AFPO output items under each requested order
  while preserving request order. It converts ordered, received, and open
  quantities to the material base unit,
  and exposes basic dates and raw order/item indicators. Missing orders and
  unit conversion failures are counted separately; duplicate or blank keys
  fail before the repository query. `npm.cmd test` passed: abaplint reported
  zero issues across 116 files, transpilation wrote 1,145 outputs, and all 978
  ABAP Unit methods passed.
- Added `RELEASE_ORDERS_BULK_AFTER_ATP` to the production-order service. It
  validates the complete ATP response before writing, skips orders with short
  components, then releases each ready order with an independent commit while
  continuing after release/commit failures. Results keep original request
  indexes and per-order readiness, release, and commit status. Tests cover a
  mixed ready/short request, continuation after a release error, incomplete
  checker results, and missing checker configuration. `npm.cmd test` passed:
  abaplint reported zero issues across 116 files, transpilation wrote 1,145
  outputs, and all 982 ABAP Unit methods passed.
- Added atomic and per-order bulk technical completion for production orders
  through `BAPI_PRODORD_COMPLETE_TECH`. Atomic completion shares one commit and
  rolls back on the first BAPI/commit failure; bulk completion commits each
  order and continues after failures. Tests cover shared rollback, continuation
  after a completion and commit error, and prevalidation. `npm.cmd test` passed:
  abaplint reported zero issues across 116 files, transpilation wrote 1,145
  outputs, and all 988 ABAP Unit methods passed.
- Added atomic and per-order bulk production-order deletion-flag operations
  through `BAPI_PRODORD_SET_DELETION_FLAG`. They validate the full key list
  before writing; atomic mode shares one commit/rollback, while bulk mode
  continues after per-order failures. Tests cover mapping, rollback, commit
  failures, continuation, and prevalidation. `npm.cmd test` passed: abaplint
  reported zero issues across 116 files, transpilation wrote 1,145 outputs,
  and all 994 ABAP Unit methods passed.
- Sales-order reads now expose rejected quantities in both the sales unit and
  material base unit. The adapter converts each rejected item using its
  sales-unit ratio, retains the rejection reason, and reports a failed read
  when conversion is unavailable. Added mapper tests for alternative-unit
  conversion and missing ratios. `npm.cmd test` passed: abaplint reported zero
  issues across 95 files, transpilation wrote 1,101 outputs, and all 925 ABAP
  Unit methods passed.
- Added `ZCL_PLANNED_ORDER_SERVICE` and a `BAPI_PLANNEDORDER_CREATE` adapter.
  `CREATE_FROM_SUGGESTIONS` maps in-house suggestions to one planned order per
  receipt lot, preserving required dates and source suggestion/lot indexes;
  `PREPARE_FROM_SUGGESTIONS` returns the exact validated per-lot requests and
  source indexes without calling SAP, so callers can review the payload before
  writing. `CREATE_ORDERS_ATOMIC` also accepts explicit requests. All orders
  share one commit, and create or commit failure rolls back the group and
  clears provisional order numbers. Tests cover BAPI field mapping, lot
  splitting, no-write preparation, source types, prevalidation, create failure,
  and commit failure.
  `npm.cmd test` passed: abaplint reported zero issues across 100 files,
  transpilation wrote 1,112 outputs, and all 933 ABAP Unit methods passed.
- Added `DELETE_ORDERS_ATOMIC` through `BAPI_PLANNEDORDER_DELETE`. It rejects
  blank or duplicate planned-order numbers before writes, stops on the first
  delete error, and shares one commit or rollback across the group. Tests cover
  successful batches, prevalidation, BAPI failure, and commit failure.
  `npm.cmd test` passed: abaplint reported zero issues across 100 files,
  transpilation wrote 1,112 outputs, and all 937 ABAP Unit methods passed.
- Added `CREATE_ORDERS_BULK` and `DELETE_ORDERS_BULK` for planned orders. Both
  prevalidate the complete list, commit each operation independently, continue
  after BAPI or commit failures, and return per-row status plus success/failure
  counts. Tests cover individual commits, failure continuation, and clearing
  provisional create numbers and delete rollback after commit errors.
  `npm.cmd test` passed:
  abaplint reported zero issues across 100 files, transpilation wrote 1,112
  outputs, and all 942 ABAP Unit methods passed.
- Added `CREATE_FROM_SUGGESTIONS_BULK` for planned-order receipt lots. It uses
  the validated suggestion-to-lot preparation path, commits each lot
  independently, and retains the original suggestion and receipt indexes in
  each row so partial completion can be reconciled. Its test covers multiple
  lots, independent commits, a failed lot, continuation, and source index
  mapping. `npm.cmd test` passed: abaplint reported zero issues across 100
  files, transpilation wrote 1,112 outputs, and all 943 ABAP Unit methods
  passed.
- Added atomic and bulk planned-order changes through
  `BAPI_PLANNEDORDER_CHANGE`. Requests explicitly select quantity, start and
  finish dates, and firming state, reject blank, duplicate, ambiguous, or invalid updates
  before writes, and expose per-order commit status in bulk mode. Adapter tests
  cover field mapping and update flags; service tests cover group rollback,
  per-order continuation, and commit failures. `npm.cmd test` passed: abaplint
  reported zero issues across 100 files, transpilation wrote 1,114 outputs, and
  all 950 ABAP Unit methods passed.
- Added `READ_ORDERS_BULK` for planned orders. It reads requested headers in a
  single `PLAF` query, returns rows in input order, exposes fixed/scenario/
  special-stock/assignment state, and converts quantities to the material base
  unit when `MARM` has a valid ratio. Missing numbers and failed conversions are
  explicit per-row results; blank and duplicate inputs fail before the query.
  Tests cover ordering, conversion, missing orders, missing ratios, duplicate
  validation, and empty input. `npm.cmd test` passed: abaplint reported zero
  issues across 104 files, transpilation wrote 1,121 outputs, and all 955 ABAP
  Unit methods passed.
- Extended planned-order changes to update the start date through
  `BAPIPLAF_I2-ORDER_START_DATE` and its X flag. Selected dates must be supplied;
  a start date supplied without its change flag is rejected. Mapper and service
  tests cover start/end scheduling fields and prevalidation. `npm.cmd test`
  passed: abaplint reported zero issues across 104 files, transpilation wrote
  1,121 outputs, and all 955 ABAP Unit methods passed.
- Added planned-order conversion through `BAPI_PRODORD_CREATE_FROM_PLORD`.
  `CONVERT_PLANNED_ORDERS_ATOMIC` validates all order numbers before one shared
  commit and clears provisional production-order numbers after rollback.
  `CONVERT_PLANNED_ORDERS_BULK` commits each conversion independently, continues
  after failures, and returns per-order commit results and counts. SAP-side BAPI
  availability and LUW behavior remain target-release checks recorded in
  `ANOMALIES.md`. `npm.cmd test` passed: abaplint reported zero issues across
  104 files, transpilation wrote 1,121 outputs, and all 960 ABAP Unit methods
  passed.
- Added `ZCL_PROD_ORDER_SERVICE` release operations through
  `BAPI_PRODORD_RELEASE`. Atomic release sends the full validated order list in
  one BAPI call and commit; bulk release commits each order independently and
  continues after failures. Both require a caller-supplied SAP release-control
  value, map per-order BAPI messages, and reject blank or duplicate keys before
  writing. Added local DDIC stubs for the BAPI order key, detail return, and
  application log. `npm.cmd test` passed: abaplint reported zero issues across
  109 files, transpilation wrote 1,133 outputs, and all 967 ABAP Unit methods
  passed.
- Added `RELEASE_ORDERS_AFTER_ATP`. A configured component ATP checker runs the
  existing bulk ATP preview and produces per-order readiness totals. The
  release service calls `BAPI_PRODORD_RELEASE` only when every open component
  is fully confirmed; incomplete or malformed readiness data blocks the call.
  Tests cover the fully confirmed path, a short component, missing rows,
  summary mapping, and orders without open components. `npm.cmd test` passed:
  abaplint reported zero issues across 112 files, transpilation wrote 1,138
  outputs, and all 972 ABAP Unit methods passed.
- Added demand-to-source reconciliation before ordinary STO writes. Single-pair,
  one-target multi-source, and multi-target pair creation now reject source
  plant rows that do not match each demand's allocated base quantity. A
  tampered-total test confirms rejection before the first order call. `npm.cmd
  test` passed: abaplint reported zero issues across 94 files, transpilation
  wrote 1,099 outputs, and all 922 ABAP Unit methods passed.
- Extended undated exact-batch STO creation to retain issuing-location splits as
  separate PO items with `SUPPL_STLOC`. Before writing, demand quantities must
  match source-plant totals, and source-plant totals must match location splits
  when they are supplied. Legacy results without location detail keep their
  plant-level item mapping. The same increment keeps dated FEFO total checks at
  the shared STO boundary and corrects fixtures that mixed source-unit values
  with base-unit totals. `npm.cmd test` passed: abaplint reported zero issues
  across 94 files, transpilation wrote 1,099 outputs, and all 921 ABAP Unit
  methods passed.
- Hardened dated exact-batch STO input validation: demand base quantities must
  reconcile to source-plant splits, then to location splits, before creating
  orders. Added tampered-summary and tampered-location rejection cases.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 917 ABAP Unit methods passed.
- Added `create_dated_batch_pairs` for date/priority exact-batch previews. It
  maps each selected batch and issuing location to an STO item with the
  request's required date, and preserves one shared atomic commit across all
  source/target pairs. Tests cover multiple required dates in one pair order.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 916 ABAP Unit methods passed.
- Added `create_dated_batch_atp_pairs` to prevalidate full cumulative ATP
  confirmation for every material/source-plant/base-unit/date group before
  creating any STO. It keeps each selected exact batch and issuing location,
  puts the required date on its item, and uses one shared commit in atomic mode.
  Tests cover a multi-date order and reject short confirmation before writes.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 915 ABAP Unit methods passed.
- Added date- and priority-ordered exact-batch cross-plant allocation, including
  the alternative-unit wrapper and `allocate_plants_date_batch_atp`. ATP checks
  group positive local allocations by material, source plant, base unit, and
  required date, accumulating quantities through each date; the local exact
  batch splits remain unchanged. Tests cover date/priority allocation order,
  mixed-unit cumulative checks, and invalid ATP rules before reads. `npm.cmd
  test` passed: abaplint reported zero issues across 94 files, transpilation
  wrote 1,099 outputs, and all 913 ABAP Unit methods passed.
- Added `allocate_plants_fefo_atp` for undated unit-aware cross-plant FEFO
  allocations. It retains local batch/location splits and groups positive source
  allocations by material, source plant, and base unit for current-date SAP ATP
  checks. ATP remains separate from batch selection and local quantities. Tests
  cover invalid options before reads, full-quantity shortfall skipping ATP,
  mixed-unit groups, and confirmation splitting. `npm.cmd test` passed:
  abaplint reported zero issues across 94 files and transpilation wrote 1,099
  outputs; all 901 ABAP Unit methods passed.
- Added `create_for_fefo_atp_pairs` to turn undated FEFO ATP results into STOs.
  It validates full ATP confirmation for each material/source-plant/base-unit
  group before any BAPI write, assigns the caller's delivery date to every
  selected batch item, and retains source-unit quantities and atomic commit
  support. Tests cover batch and UOM item mapping, delivery date, shared commit,
  and short ATP rejection before writes. `npm.cmd test` passed: abaplint reported
  zero issues across 94 files, transpilation wrote 1,099 outputs, and all 903
  ABAP Unit methods passed.
- Added `allocate_plants_batch_atp` for unit-aware exact-batch cross-plant
  allocation. It preserves batch/location splits and groups positive source
  quantities by material, source plant, and base unit for current-date SAP ATP
  checks. Tests cover mixed-unit batches, grouped requests, partial confirmation,
  and check-rule rejection before reads. `npm.cmd test` passed: abaplint reported
  zero issues across 94 files, transpilation wrote 1,099 outputs, and all 905
  ABAP Unit methods passed.
- Added `create_for_atp_batch_pairs` for exact-batch ATP results. It requires a
  matching, fully confirmed ATP check for every positive material/source-plant/
  base-unit group before creating orders, then carries the caller's delivery
  date, exact batches, source units, receiving locations, and atomic commit
  behavior into the STOs. Tests cover multi-pair batch item mapping and reject a
  short confirmation before writes. `npm.cmd test` passed: abaplint reported
  zero issues across 94 files, transpilation wrote 1,099 outputs, and all 907
  ABAP Unit methods passed.
- Added `iv_include_undated_batches` to single-plant and cross-plant FEFO
  previews, including UOM, dated, and ATP wrappers. It defaults to true;
  setting it false removes undated batches from eligible availability,
  safety-stock handling, and allocation splits. Invalid values fail before UOM
  or stock reads. `npm.cmd test` passed: abaplint reported zero issues across
  94 files, transpilation wrote 1,099 outputs, and all 900 ABAP Unit methods
  passed.
- Extended `iv_require_full_quantity` across single-plant ordinary, dated,
  storage-location, exact-batch, and FEFO allocation, including unit-aware and
  ATP wrappers where available. A demand that exceeds remaining eligible stock
  receives zero local allocation, so later rows can use the unchanged balance;
  the default still permits partial allocation. Invalid values fail before UOM
  or stock reads. Dated ATP still checks the requested quantity. `npm.cmd test`
  passed: abaplint reported zero issues across 94 files, transpilation wrote
  1,099 outputs, and all 898 ABAP Unit methods passed.
- Added opt-in `iv_require_full_quantity` to undated and dated cross-plant
  ordinary, exact-batch, and FEFO allocation, including unit and ATP variants.
  The default keeps partial allocation; when enabled, insufficient requests
  allocate zero and leave stock for later demands after all source, location,
  safety-stock, batch, shelf-life, and date rules are applied. ATP wrappers
  check only positive local splits. Tests cover no-consumption-on-shortfall,
  later-demand reuse, unit forwarding, dated FEFO, ATP skipping, and invalid
  flags before reads. `npm.cmd test` passed: abaplint reported zero issues
  across 94 files, transpilation wrote 1,099 outputs, and all 895 ABAP Unit
  methods passed.
- Added `allocate_plants_atp` for undated unit-aware cross-plant allocation.
  It groups positive local source splits by material, source plant, and base
  unit, checks SAP ATP once per group for the current date, and returns capped
  confirmed/unconfirmed base quantities alongside the unchanged local estimate.
  Missing check rules fail before stock/UOM reads. Tests cover mixed input units,
  grouped ATP requests, partial confirmations, and pre-read rejection.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 892 ABAP Unit methods passed.
- Added per-request, per-source-plant `it_source_locations` scopes to ordinary,
  exact-batch, and FEFO cross-plant allocation and their unit-aware variants.
  The scopes intersect the existing shared allowlist and location priority;
  when supplied, every source pair must have at least one mapped location.
  Duplicate, blank, and unmapped entries fail before stock/UOM reads, while
  safety stock remains based on each full source-plant balance. Tests cover all
  six allocation paths and pre-read validation. `npm.cmd test` passed: abaplint
  reported zero issues across 94 files, transpilation wrote 1,099 outputs, and
  all 890 ABAP Unit methods passed.
- Extended `it_allowed_storage_locations` to ordinary, exact-batch, and FEFO
  cross-plant allocations and their unit-aware variants. The shared list filters
  candidate locations in every source plant; empty or omitted lists leave all
  locations eligible. Safety stock is still deducted from each full source-plant
  balance before filtering. Tests cover ordinary, batch, FEFO, and UOM paths.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 886 ABAP Unit methods passed.
- Added optional `it_storage_location_priority` to ordinary, exact-batch, and
  FEFO cross-plant allocations and their unit-aware variants. Source-plant order
  remains primary; ordinary and exact-batch paths prefer listed locations,
  while FEFO uses location order only for the same batch and expiration date.
  The existing allowlist still filters both availability and allocation, and
  invalid priorities fail before stock/UOM reads. Tests cover priority order,
  allowlist interaction, FEFO ties, unit-aware forwarding, and pre-read checks.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 886 ABAP Unit methods passed.
- Extended caller location priority to dated cross-plant FEFO and its unit-aware
  and ATP variants. Location order breaks ties only for the same batch and
  expiration date; required-date, source-plant, expiry, and batch order stay
  primary. Duplicate priorities fail before stock or UOM reads. Tests cover
  base-unit selection, UOM and ATP forwarding, allowlist interaction, and
  pre-read validation.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and all 888 ABAP Unit methods passed.
- Added optional `it_allowed_storage_locations` filtering to single-plant
  location, exact-batch, and FEFO allocation. Empty or omitted lists preserve
  unrestricted behavior; blank and duplicate entries are rejected before
  stock/UOM reads, and a preferred location outside a nonempty list is rejected.
  Caller priority orders only allowed candidates. Safety stock remains deducted
  from the full inventory balance before candidate filtering. Forwarded the
  option through sales-order preview/reservation, cost-center previews, atomic
  reservations, and single cost-center paths. Added unit tests for filtered
  stock splits, exact batch/FEFO filtering, pre-read validation, and wrapper
  propagation. `npm.cmd test` passed: abaplint reported zero issues across 94
  files, transpilation wrote 1,099 outputs, and all 882 ABAP Unit methods
  passed.
- Added caller-defined storage-location priority to
  `allocate_by_storage_location` and its unit-aware variant. Explicit per-demand
  locations remain first; listed fallback locations follow caller order, then
  unlisted locations follow ascending code order. Blank and duplicate priority
  entries are rejected before repository reads. The option now passes through
  sales-order preview/reservation, cost-center location, batch, and FEFO
  previews, atomic reservations, and single cost-center preview/reservation.
  Explicit preferred locations remain first. FEFO expiration and batch order
  remain primary, with location priority resolving same-batch, same-expiration
  ties. Tests cover wrapper forwarding, preferred-location precedence, custom
  fallback order, UOM forwarding, and duplicate rejection.
- Extended exact-batch stock allocation with the caller-defined storage-location
  priority. Preferred locations remain first, listed fallback locations follow
  caller order, and unlisted locations follow the existing ascending-code order.
  The option is available in base and unit-aware stock allocation and passes
  through sales-order and cost-center exact-batch flows. Tests cover split order,
  selected-batch isolation, unit-aware preview forwarding, and reservation
  forwarding.
- Extended FEFO stock allocation with location-priority tie-breaking. Expiration
  date and batch remain primary; the caller order resolves locations only for
  matching batch/date rows, while a demand's preferred location remains first.
  The option passes through the unit-aware, sales-order, and cost-center FEFO
  paths. `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and ABAP Unit completed successfully.
- Expanded dated open production receipts to include released process orders
  (`AUFK-AUTYP = 40`) alongside PP production orders (`AUTYP = 10`). The
  projection keeps its existing opt-in flag and quantity/date rules, and labels
  rows as `PROCESS_ORDER` so callers can distinguish their source. SAP table
  joins and release-phase behavior still need validation on the target release;
  see `ANOMALIES.md`.
- Added `iv_test_run` to STO item deletion and delivery completion, including
  the single-pair and atomic pair methods. Both adapters pass `TESTRUN` to
  `BAPI_PO_CHANGE`; successful simulations set `is_successful` and
  `is_test_run`, leave `is_deleted`/`is_completed` false, and skip
  commit/rollback. Atomic simulations validate all pairs independently and
  preserve each pair's outcome, including after a failed pair. Tests cover
  forwarding, success/error result flags, continued validation, transaction
  suppression, and invalid flags. `npm.cmd test` passed: abaplint reported zero
  issues across 94 files, transpilation wrote 1,099 outputs, and ABAP Unit
  completed successfully. Target BAPI behavior and messages remain to be
  confirmed; see `ANOMALIES.md`.
- Added `iv_test_run` to PO item deletion, delivery completion, schedule changes,
  item quantity changes, and their bulk, atomic, and base-unit variants. The BAPI
  adapter forwards the flag to `BAPI_PO_CHANGE`; simulations return per-PO
  messages and skip commit/rollback. Atomic simulations validate each PO call
  independently and do not establish multi-PO commit behavior. Invalid flags are
  rejected before reads or writes. Tests cover service flag forwarding, single
  and atomic simulations, transaction suppression, and invalid-flag rejection.
  `npm.cmd test` passed: abaplint reported zero issues across 94 files,
  transpilation wrote 1,099 outputs, and ABAP Unit completed successfully.
  `BAPI_PO_CHANGE` test-run behavior and returned messages still need validation
  on the target SAP release; see `ANOMALIES.md`.
- Added `iv_include_po_confirmations` to the standard projected-receipt APIs,
  including base-unit, requested-unit, global bulk, and per-request option
  variants. Bulk option requests can select different PO projections for the
  same material/plant; each request rejects selecting both regular and
  confirmation-aware PO receipts. Added the option to single, grouped,
  unit-aware, ATP, and cross-plant dated allocation; grouped demands share one
  confirmation projection per material/source plant through the latest demand
  date. Tests cover source merging, UOM conversion, deadline filtering, grouped
  queries, chronological netting, source-plant allocation, and conflicting-
  source validation. `npm.cmd test` passed with zero abaplint issues across 94
  files and 1,099 transpiler outputs. EKES/EKET confirmation semantics still
  need target-SAP validation as recorded in `ANOMALIES.md`.

## 2026-10-03

- Added `SIMULATE_SPLIT_QUOTA` for a bounded split preview over one request's
  quota-assigned standard vendor candidates. It checks shared arrangement and
  base-unit context, distributes by quota value, uses the maintained
  `EQUK-SCMNG` minimum split quantity (with an optional caller override) for
  small requests and trailing remainders, and returns each positive source
  split with its candidate. The caller confirms that split-quota customizing
  applies. Added tests for candidate propagation, a four-source split,
  below-minimum routing, and unit mismatch. SAP source
  rating recalculation, per-source lot sizes/capacity, and quota maximums
  remain outside the preview; see `ANOMALIES.md`.
- Added quota-item priority to PIR candidates and split ordering. Sources with
  a maintained priority are ordered ahead of unprioritized sources, smallest
  number first; ties and unprioritized rows follow quota value. Split amounts
  remain quota-ratio based. Tests cover priority propagation and an override of
  the default quota order without changing the calculated share, including
  multiple priority values and below-minimum allocation selection.
- Applied quota-item `MINLS`/`MAXLS` to split proposal quantities and carried
  the maintained once-only indicator. Results now distinguish demand-share
  `allocated_quantity` from source-adjusted `proposal_quantity`; max lots expand
  into multiple rows and minimum lots can exceed their demand share. An
  only-once source whose share exceeds its max is rejected because overflow
  redistribution and quota re-evaluation are not modeled. Tests cover field
  propagation, min/max lot behavior, and once-only rejection.
- Verification after split quota threshold, priority, and lot-size support: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 707 objects, and
  all 453 ABAP Unit methods passed. `git diff --check` passed.

## 2026-10-02

- Added opt-in projection of dated stock-transfer schedule quantities that
  have not yet been issued. The stock repository calculates the difference
  between `EKET-MENGE` and `EKET-WAMNG`, converts it to the material base unit,
  and shares the existing STO filters and schedule-date cutoff. It skips items
  marked completely delivered and can be combined with issued in-transit
  quantities.
- Carried the option through single, bulk, unit-aware, ATP, and cross-plant
  dated allocation methods. Added quantity-calculator and local allocation
  tests for default-off behavior, alternative STO states, and combined totals.
- Target-system verification remains necessary for STO query filters and
  schedule-line quantity/unit semantics; local tests use repository doubles.
- Verification: `npm.cmd test` passed; abaplint reported zero issues across 64
  files, and the transpiler ran all 332 ABAP Unit methods.
- Added `iv_subtract_unissued_sto` to subtract open outbound STO schedule
  quantities from the supplying plant's dated balance. The amount is
  `EKET-MENGE - EKET-WAMNG`, converted to the material base unit and scoped by
  `EKKO-RESWK`, with STO item/document filters and a due-date cutoff. It is
  opt-in and carried through single, bulk, unit-aware, ATP, and cross-plant date paths.
  Added service coverage for single requests, shared bulk priority, and
  cross-plant source balances.
- Verification after outgoing STO deductions: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 333 ABAP
  Unit methods.
- Added `preview_orders_by_date` for multi-sales-order dated allocation. Open
  items share each material/plant balance, requested dates determine priority,
  and document/item order resolves same-date ties. The preview subtracts each
  order's active reservations, returns sales- and base-unit summaries, and
  supports confirmed-demand sizing plus optional dated receipts, STO
  quantities, production receipts, safety-stock protection, and cumulative
  SAP ATP checks. Added coverage for shared stock, confirmed quantities, ATP
  aggregation, and sales-unit conversions across orders.
- Verification after multi-order dated preview: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 335 ABAP
  Unit methods.
- Added `reserve_orders_by_date` to reserve positive allocations from the
  shared multi-order date plan. It supports simulation and full-allocation
  enforcement, sends all line requests through one reservation transaction,
  and rolls back if creation or commit fails. Allocation results now retain
  required dates for reservation mapping. Tests cover cross-order quantities,
  full-allocation rejection, simulation, and create/commit rollback.
- Latest verification after multi-order reservation support: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files, and the transpiler ran
  all 340 ABAP Unit methods.
- Sorted multi-order reservation requests by material, plant, and required
  date so API calls follow the same due-date priority as shared-stock planning;
  stable sorting preserves caller order for ties. Added a regression test with
  input document/date order reversed.
- Verification after due-date-ordered reservation submission: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files, and the transpiler ran
  all 341 ABAP Unit methods.
- Added reservation-response reconciliation to both single- and multi-order
  flows. Each returned row must match one pending request by request ID,
  quantity, date, and any explicit storage location or batch; regular runs also
  require a reservation number. A mismatch rolls back before commit. Added a
  malformed cross-order response test.
- Verification after reservation-response validation: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files, and the transpiler ran all
  342 ABAP Unit methods.
- Added a bulk sales-order reservation query and used it in multi-order dated
  previews, replacing one reservation read per order with one keyed query.
  Empty document lists return without running the database selection; the
  preview validates blank and duplicate keys before the bulk call. Added tests
  for per-order matching and read-count reduction.
- Verification after bulk reservation reads: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 343 ABAP
  Unit methods.
- `reserve_orders_by_date` now accepts the preview's optional cumulative ATP
  diagnostics and returns them beside its reservation results. The diagnostics
  remain separate from local allocation and the reservation API's own ATP
  checks. Extended cross-order reservation coverage for shared-date ATP totals.
- Verification after ATP diagnostics on multi-order reservation: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files, and the transpiler ran
  all 343 ABAP Unit methods.
- Replaced multi-order request-context scans with a hashed request-ID index
  and sorted bulk-reservation rows by sales document, avoiding repeated full
  table scans while retaining caller and date priority.
- Verification after keyed multi-order lookups: `npm.cmd test` passed; abaplint
  reported zero issues across 64 files, and the transpiler ran all 343 ABAP
  Unit methods.

## 2026-09-23

- Sales-order reads retain the `BAPISDIT-SALES_QTY1/SALES_QTY2` conversion
  ratio. Preview and reserve results now include sales-unit allocation
  summaries while keeping allocations and reservation requests in the base
  unit. Alternative-unit lines without a usable ratio fail before stock reads.
- Added tests for sales-unit requested, available, allocated, and shortfall
  quantities, reserve-result propagation, and missing-ratio rejection.
- Added cross-plant allocation preview with ordered source-plant splits,
  source-location splits, shared source balances across demand rows,
  per-demand shortfalls, optional source safety-stock protection, and input
  validation before stock reads. The preview does not create transfers or
  reservations.
- Added test coverage for ordered location splits and protected source-plant
  safety stock.
- Added `allocate_plants_in_units`, which caches unit ratios, converts demand
  before stock reads, and returns source-unit and base-unit demand, plant, and
  location quantities. Added allocation and unknown-unit rejection tests.
- Added exact-batch allocation across source plants with per-plant and
  batch/location splits, optional source safety-stock protection, and tests for
  source priority, shared stock, batch preservation, safety-stock protection,
  and missing-batch rejection.
- Added `allocate_plants_batch_in_units` for exact-batch cross-plant demands in
  material-specific units. It caches and validates ratios before stock reads
  and returns converted demand, plant, and location quantities. Added tests for
  shared converted allocations and unknown-unit rejection.
- Added cross-plant FEFO allocation with caller-ordered source plants,
  minimum-shelf-life filtering, optional safety-stock protection, and
  batch/location detail. Added tests for FEFO ordering and invalid input.
- Added `ALLOCATE_PLANTS_FEFO_IN_UNITS` to convert alternative-unit cross-plant
  FEFO demands before stock reads and return both unit views for demand, plant,
  and batch/location results. Added tests for shared stock across plants,
  FEFO/minimum-shelf-life filtering, rounded source units, and unknown units.
- Added opt-in confirmed-demand sizing for sales-order previews and reservations
  using schedule-line confirmed quantities, capped at ordered open quantities.
  Confirmed demand is converted to the material base unit; open item-level
  fallback rows are rejected before stock reads. Added preview, reservation,
  alternative-unit summary, and missing-schedule tests.
- Added `TRANSFER_PLANT_ALLOCATION`, which validates cross-plant demand and
  location splits and posts them as one 301 goods movement using per-request
  destination locations and per-material base-unit/ISO mappings. Complete
  allocation is required by default, with an explicit partial-transfer option.
  Added tests for multiple source splits, success, shortfall rejection, and
  inconsistent split rejection.
- Added `TRANSFER_PLANT_BATCH_ALLOC` and `TRANSFER_PLANT_FEFO_ALLOC` to post
  exact-batch and FEFO cross-plant location splits while preserving batch IDs.
  Shared demand/split validation with the non-batch bridge. Added tests for
  exact-batch and multi-batch FEFO transfers, shortfall rejection, split
  mismatch, and missing-batch rejection.
- Added `TRANSFER_PLANT_UNITS_ALLOC` and `TRANSFER_PLANT_BATCH_UNITS` so
  unit-aware cross-plant allocation results post directly from canonical
  base-unit split quantities. The service checks result base units against the
  supplied material-unit mapping. Added tests for non-batch splits, batch
  preservation, base-unit quantities, and mapping mismatch rejection.
- Added `TRANSFER_PLANT_FEFO_UNITS` to post unit-aware FEFO cross-plant splits
  as a single 301 movement, retaining batch IDs and canonical base-unit
  quantities. Added success and base-unit mismatch tests.
- Resolved the earlier schedule-date note: schedule-line dates now pass into
  reservations; confirmed delivery dates remain outside the read model.
- Latest verification: `npm.cmd test` passed; abaplint reported zero issues
  and the transpiler ran all 241 ABAP Unit test methods.

## 2026-09-22

- Bootstrapped abaplint and open-abap transpiler configuration with the required
  `open-abap-core` dependency.
- Added a local SAP `MARD` dictionary stub in `stubs/` and included that directory
  in both lint and transpiler inputs.
- Pointed abaplint at the existing local `open-abap-core` checkout and enabled
  every additional rule requested in `PLAN.md`.
- Added the first feature: read unrestricted-use quantity (`MARD-LABST`) for a
  material and plant through an injectable stock repository.
- Added service unit tests for a positive stock quantity and a zero-stock case.
- Added allocation previews that cap an individual request to available stock,
  report a shortfall, treat negative stock as unavailable, and reject negative
  requested quantities.
- Added ordered multi-line allocation with per-material/plant stock caching so
  repeated demand lines cannot allocate the same stock more than once.
- Added confirmed goods-movement posting through `BAPI_GOODSMVT_CREATE`, with
  test-run support, validation for cost center, order, and sales order goods
  issues plus one-step storage/plant transfers, and commit/rollback handling
  through an injectable API.
- Added sales-order item reads through `BAPISDORDER_GETDETAILEDLIST` and sales
  order create/change through `BAPI_SALESORDER_CREATEFROMDAT2` and
  `BAPI_SALESORDER_CHANGE`, with test-run support and transaction handling.
- Added partial local DDIC stubs for the BAPI structures used by the adapters.
- Added a material-unit converter that reads the base unit from `MARA` and uses
  the sales-to-stockkeeping-unit ratio returned on each sales order item.
- Sales-order reads now retain the requested sales-unit quantity and add its
  converted base-unit quantity; reads fail when an alternative-unit item has
  no usable ratio or material base unit.
- Added open-demand quantities by reading delivered quantity and item delivery
  status from `VBAP` and `VBUP`; complete and non-delivery items return zero,
  while open and partially delivered items subtract delivered quantity from
  requested quantity and clamp over-delivery to zero.
- Added an order allocation preview that converts positive open base-unit
  quantities into prioritized batch demands and keys results by sales document
  and item. Failed reads and open lines missing material, plant, or base unit
  do not reach the stock repository.
- Added `reserve_order` to create movement type 231 reservations for each
  positively allocated sales order item with `BAPI_RESERVATION_CREATE1`. The
  BAPI ATP check is enabled, all item reservations share one commit/rollback
  boundary, and test runs do not commit.
- Stock availability now subtracts undelivered quantities of active, non-deleted
  unrestricted-stock reservations in `RESB` from physical unrestricted stock
  in `MARD`. The quantity calculator clamps negative balances to zero.
- Added storage-location stock reads grouped from `MARD` and `RESB`. Allocation
  consumes locations in ascending `LGORT` order, returns the quantity split by
  location, and reserves each positive split against its source location.
- Plant-level reservations without `LGORT` are deducted from available
  storage locations in ascending location-code order. This preserves the total
  free quantity but is a deterministic estimate of location-level availability.
- Extracted location balance calculation into a pure class with unit tests for
  location reservations, plant-level reservations, and over-reserved locations.
- Added partial local stubs for `BAPI2093_RES_HEAD`, `BAPI2093_RES_ITEM`,
  `BAPI2093_ATPCHECK`, `BAPI2093_RES_KEY`, and the queried `RESB` fields.
- Added reservation API fakes and tests for partial allocation reservation,
  simulation, create errors, commit errors, and failed sales-order reads. Added
  helper tests for open-reservation subtraction and stock balance clamping.
- Remaining reservation limits: schedule-line requirement dates are not read,
  so reservation items currently use today's date. Stock checks subtract open
  `RESB` reservations but do not reproduce all SAP ATP/customizing rules; the
  BAPI ATP behavior and movement type must be validated in the target release.
- Added a local `MARA` stub, the conversion fields to the partial `BAPISDIT`
  stub, partial `VBAP` and `VBUP` stubs, and tests for unit conversion and open
  quantity status rules.
- Verification before the reservation feature: `npm.cmd test` passed; abaplint
  reported zero issues and the transpiler ran all 42 ABAP Unit test methods.
- Remaining integration work: validate adapter calls, `BAPISDIT` conversion
  fields, the `VBAP`/`VBUP` reads, and reservation behavior against the target
  SAP release. Schedule-line-specific confirmed quantities are not yet used.
  No live SAP system was available for posting or interface validation.
- Latest verification after location-aware allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 56 ABAP Unit methods.
- Added reservation release by reservation number through
  `BAPI_RESERVATION_DELETE`, with duplicate/blank input validation, simulation,
  and one commit/rollback boundary for the requested list. Added service tests
  for success, simulation, deletion errors, commit errors, and invalid input.
- SAP decides whether each complete reservation document is eligible for
  deletion; no live system was available to verify delete behavior or the
  target release's exact BAPI signature.
- Latest verification after reservation release: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 61 ABAP Unit methods.
- Added reservation detail reads through `BAPI_RESERVATION_GETDETAIL1` with an
  injectable reader adapter. Results include reservation item identity, record
  type, status flags, requested and withdrawn quantities, and material/location
  details. Failed or empty reads do not expose partial item data.
- Latest verification after reservation inquiry: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 66 ABAP Unit methods.
- Added goods issue posting against reservation items through
  `BAPI_GOODSMVT_CREATE` using GM code 03. The service reads reservation
  details, validates issueable status and remaining base-unit quantity, uses
  the reservation's ISO base unit, and posts all requested items in one
  material document. Added tests for success, simulation, read errors,
  over-issue, closed items, and duplicates.
- Reservation-linked goods movement fields and quantity behavior still need
  validation against the target SAP release; local tests use API doubles.
- Goods movement requests now carry both the SAP entry unit and its ISO code;
  requests missing either value are rejected before calling the BAPI.
- Latest verification after reservation issue posting: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 74 ABAP Unit methods.
- Added batch stock reads from `MCHB-CLABS`, subtracting open reservation
  quantities by batch and storage location. Reservations missing either
  dimension are distributed deterministically across matching balances; excess
  over-reservation is deducted conservatively from remaining stock.
- Added exact-batch allocation previews with optional storage-location
  restriction, ordered demand consumption, location splits, caching, and
  shortfall reporting. A missing requested batch is rejected and another batch
  is never substituted. SAP automatic batch determination and non-batch-managed
  valuation-type allocation remain outside this feature.
- Latest verification after batch-aware allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 81 ABAP Unit methods.
- Added `ALLOCATE_BY_EXPIRY`, an explicit FEFO batch preview that sorts dated
  stock by expiration date, excludes dates earlier than its as-of date, puts
  undated batches last, and honors optional storage-location restrictions. The
  batch repository reads expiration from plant-level `MCHA-VFDAT`, falling back
  to material-level `MCH1-VFDAT`. This does not reproduce configurable SAP batch
  search strategies. Tests cover FEFO order, expired and undated batches,
  location filtering, and invalid input.
- Latest verification after FEFO preview: `npm.cmd test` passed; abaplint
  reported zero issues and the transpiler ran all 122 ABAP Unit methods.
- Added optional per-item batch choices to sales-order previews and reservation
  creation. Selected batches flow into `BAPI2093_RES_ITEM-BATCH`; partial or
  duplicate selection sets are rejected before reading stock or creating
  reservations. Added tests for a batch split across locations and incomplete
  item selection.
- SAP reservation documentation exposes batch and valuation-type requirements;
  with batch-managed split valuation, the supplied batch identifies the
  valuation type. Non-batch valuation-type allocation remains unmodeled.
- Latest verification after batch-aware order reservations: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 83 ABAP Unit
  methods.
- Sales-order reads now expand schedule lines from `VBEP`, calculate each
  line's open quantity from `WMENG - VSMNG`, and carry its requested date into
  stock priority and reservation `REQ_DATE`. Items without schedule rows keep
  the prior item-level quantity behavior and current-date reservation default.
- Added a local `VBEP` stub and a reservation-flow test proving separate
  schedule-line allocations retain unique keys, due dates, and ordered stock
  priority. Confirmed schedule quantities/dates and live SAP query behavior
  remain to be validated.
- Latest verification after schedule-line-aware allocation: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 85 ABAP Unit
  methods.
- Batch selections for sales-order reservations can now be keyed by both item
  and schedule line, so one item may allocate different schedule lines from
  different batches. The existing item-only selection still applies one batch
  across all open schedule lines. Duplicate, partial, and mixed selection modes
  are rejected before stock access; tests cover different batches per line and
  incomplete schedule-line choices.
- Latest verification after schedule-line-specific batch selection:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 89 ABAP Unit methods.
- Added purchase-order goods receipt posting through the existing goods
  movement service. It requires GM code 01, movement type 101, movement
  indicator `B`, PO number/item, quantity, and entry unit; SAP can derive
  material, plant, and storage location from the PO item. Added service tests
  for a valid receipt, a missing PO item, a wrong GM code, and mixed PO/non-PO
  items in one request.
- Latest verification after purchase-order receipt support: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 93 ABAP Unit
  methods.
- Added `iv_require_full_allocation` to sales-order reservation creation. When
  enabled, any local preview shortfall prevents all reservation BAPI calls;
  the default still reserves partial quantities. Added tests for shortfall
  rejection and a fully covered order.
- Latest verification after full-allocation reservation mode: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 95 ABAP Unit
  methods.
- Added storage-location selections for sales-order previews and reservations.
  Choices can be keyed per schedule line or apply item-wide; selected locations
  are hard restrictions by default. `allow_fallback` makes a location the
  first preference before ascending-code fallback. Batch and location
  selections cannot be combined. Tests cover schedule-line and item-wide
  locations, incomplete choices, exclusivity, restricted shortfall, and
  preferred-location fallback.
- Latest verification after sales-order location selection: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 101 ABAP Unit
  methods.
- Added production-order goods receipts to the goods-movement service using GM
  code 02, movement type 101, movement indicator `F`, and the production order
  reference. The service validates receipt fields and prevents mixing these
  items with other movement modes. Tests cover a successful receipt, missing
  movement indicator, and mixed receipt/item movements.
- Latest verification after production-order receipt support: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 104 ABAP Unit
  methods.
- Added full material-document cancellation through `BAPI_GOODSMVT_CANCEL`.
  Callers provide the original material document and year, with an optional
  reversal posting date. The service validates the key, checks for a returned
  cancellation document, and commits or rolls back the BAPI transaction. Tests
  cover successful cancellation, a missing document key or return document,
  SAP errors, and commit failure.
- Latest verification after goods-movement cancellation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 109 ABAP Unit methods.
- Extended goods-movement cancellation to support selected material-document
  items through `BAPI_GOODSMVT_CANCEL`; an empty item list continues to cancel
  the full document. Duplicate or blank item numbers are rejected before the
  BAPI call. Added the standard `BAPI2017_GM_ITEM_04` structure stub and tests
  for selected-item forwarding and duplicate rejection.
- Latest verification after item-level cancellation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 112 ABAP Unit methods.
- Added PO-referenced returns to vendor with movement type 122, GM code 01,
  movement indicator `B`, and purchase-order/item references. The existing
  validation now permits both PO receipts (101) and returns (122), while
  rejecting a return with the wrong goods movement code. Tests cover posting
  and rejection before the BAPI call.
- Latest verification after PO returns: `npm.cmd test` passed; abaplint reported
  zero issues and the transpiler ran all 114 ABAP Unit methods.
- Added two-step stock transfers: plant removal/putaway with movement types
  303/305 and storage-location removal/putaway with 313/315. The service
  validates each movement's destination fields and posts each leg through the
  existing goods-movement transaction flow. Tests cover all four postings and
  missing destinations on the removal legs.
- Latest verification after two-step transfer support: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 116 ABAP Unit methods.
- Added a stock-in-transfer inquiry backed by `MARC-UMLMC` and `MARD-UMLME`.
  Callers can request one storage location or aggregate storage-location
  transfer quantities across the plant. In-transfer stock stays separate from
  allocatable unrestricted stock. Added partial standard table stubs and
  service tests for location selection and required keys.
- Latest verification after stock-in-transfer inquiry: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 119 ABAP Unit methods.
- Integrated FEFO batch allocation with sales-order preview and reservation via
  opt-in `iv_use_fefo_batches`; `iv_fefo_as_of_date` defaults to the current
  date. The resulting batch splits are passed into reservation requests without
  manual batch selections. FEFO can use a hard location restriction or honor
  `allow_fallback` by searching the preferred location first, then other
  locations in FEFO order. Explicit batch selections and FEFO mode are rejected
  together. Tests cover order preview, split reservations, preferred-location
  fallback, and conflicting inputs.
- Latest verification after FEFO sales-order integration: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 126 ABAP Unit methods.

## 2026-09-23

- Added opt-in safety-stock protection using static `MARC-EISBE`, exposed by
  `iv_protect_safety_stock` on stock allocation and sales-order preview and
  reservation methods. The flag defaults to false. Location and batch paths
  distribute the buffer deterministically; FEFO preserves earlier-expiring
  batches first.
- Added stock-level tests for unrestricted, location, exact-batch, and FEFO
  allocations, plus a sales-order reservation integration test. SAP ATP and
  time-dependent safety-stock behavior remain outside this calculation.
- Latest verification after safety-stock protection: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 131 ABAP Unit methods.
- Added a minimum remaining shelf-life filter to FEFO stock allocation and
  sales-order preview/reservation. The day count is measured from the as-of
  date; the boundary date is eligible, while undated batches are excluded when
  the count is positive. Positive counts require FEFO mode and negative counts
  are rejected before stock reads.
- Added unit and end-to-end tests for the cutoff boundary, undated stock,
  invalid inputs, preview output, and reservation batch selection.
- Latest verification after the FEFO shelf-life filter: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 136 ABAP Unit methods.
- Added opt-in `iv_prioritize_by_date` for sales-order preview and reservation.
  It orders all dated open lines by requested date across the whole order,
  keeps source order for equal dates, and places undated item-level demand
  after dated lines. Reservation requests use the same priority order.
- Added preview coverage for the default and date-priority paths plus a
  reservation-flow test proving that the earlier-due line receives stock first.
- Latest verification after order date priority: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 138 ABAP Unit methods.
- Added `GET_STOCK_STATUS` to report plant totals for unrestricted,
  quality-inspection, and blocked stock separately, with active reservations
  net of withdrawals and an unrestricted availability estimate. Added
  `MARD-INSME` and `MARD-SPEME` to the local stub; quality and blocked stock
  do not enter allocation.
- Added `GET_STOCK_STATUS_BY_LOCATION` for category totals and available
  unrestricted quantities by `LGORT`. It uses the same deterministic handling
  of plant-level reservations as location-aware allocation.
- Added static `MARC-EISBE` and `available_after_safety_qty` to the plant status
  result, with a pure calculator that clamps negative safety-stock values and
  availability at zero. Existing opt-in allocation protection now uses the
  same calculator.
- Added service tests for plant and location status mapping; fake repositories
  do not exercise the MARD/RESB/MARC aggregate queries.
- Latest verification after stock-status safety metrics: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 141 ABAP Unit methods.
- Added `GET_STOCK_STATUS_BY_BATCH` to report unrestricted and available
  quantities with expiration date by storage location and batch. Zero-available
  batches remain in the result, and allocation and inquiry now share the same
  repository calculation.
- Added service mapping coverage for populated and zero-available batch rows;
  fake repositories do not exercise the MCHB/MCHA/MCH1/RESB reads.
- Latest verification after batch stock status: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 142 ABAP Unit methods.
- Order previews and reservations now subtract active movement type 231
  reservations assigned to the sales order. The repository groups RESB
  quantities by item, schedule line, and requirement date; unmatched quantities
  are distributed across the same item's open lines in allocation order.
- Added tests for schedule-line and date matching and for skipping a BAPI call
  when the order's open quantity is already reserved. Local doubles do not
  exercise the RESB query or prove field population in the target SAP release.
- Latest verification after existing order reservation handling: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 144 ABAP Unit
  methods.
- Added single-request allocation in a material-specific alternative unit. The
  service reads `MARA-MEINS` and `MARM-UMREZ`/`UMREN`, converts to base quantity,
  then delegates to the existing allocator. The result preserves the source
  unit and quantity and returns base-unit quantity with allocation details.
- Added a local `MARM` stub and converter/service tests for ratio conversion,
  partial allocation, and unknown-unit rejection. Local doubles do not exercise
  the SAP `MARA`/`MARM` queries.
- Latest verification after alternative-unit allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 149 ABAP Unit
  methods.
- Explicit batch reservations can now prefer a selected storage location and,
  when enabled, fill the remainder from other locations for the same batch.
  Added allocator and order-reservation tests for preference order, plus input
  validation when fallback is requested without a preferred location.
- Latest verification after batch-location fallback: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 152 ABAP Unit
  methods.
- Added `GET_FEFO_BATCH_STATUS` to show batch-status rows that satisfy an
  as-of date and minimum remaining shelf-life requirement. Dated rows are
  sorted by earliest expiration; undated rows appear last when the minimum is
  zero. A shared eligibility calculator now drives this inquiry and FEFO
  allocation.
- Latest verification after FEFO-eligible batch inquiry: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 161 ABAP Unit
  methods.
- Added a cost-center reservation service for movement type 201. It validates
  the material base unit, previews unrestricted stock at one storage location
  and optional batch, then creates a reservation for the allocated quantity
  through an injectable BAPI adapter. Full-allocation and test-run options are
  supported; create or commit errors trigger rollback.
- Added fake API and repository tests for partial and batch reservations,
  full-stock requirements, simulation, no-stock handling, errors, and unit
  validation. Updated the partial SAP reservation header stub with `COSTCENTER`.
- Latest verification after cost-center reservations: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 169 ABAP Unit
  methods.
- Cost-center reservations now accept material-specific alternative units.
  The service converts requested quantities to the material base unit for
  allocation and BAPI creation, while returning both source and base quantities
  and units. Added coverage for a partial allocation after unit conversion.
- Latest verification after cost-center alternative-unit support:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 171 ABAP Unit methods.
- Cost-center requests can now omit the storage location to allocate across
  locations in ascending code order. The BAPI adapter creates one reservation
  with an item for each positive location split, including split items for an
  exact batch across locations. Supplied locations remain hard restrictions.
- Added tests for unbatched location splits and batch/location splits; local
  doubles do not validate the multi-item BAPI call in SAP.
- Latest verification after multi-location cost-center reservations:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 174 ABAP Unit methods.
- Cost-center reservation requests can opt into FEFO batch selection with an
  as-of date and minimum remaining shelf life. The service reserves the
  resulting batch/location splits in the same multi-item BAPI request and
  rejects mixing FEFO with a manual batch or using shelf-life days without
  FEFO.
- Added coverage for expiry ordering, the minimum-day boundary, expired and
  undated exclusions, and invalid FEFO options.
- Latest verification after FEFO cost-center reservations: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 178 ABAP
  Unit methods.
- Added `preview_for_cost_center`, which returns the same allocation and
  validation result as reservation creation without calling the BAPI. Both
  paths now share the preparation method, keeping UOM conversion, FEFO,
  location splits, and full-allocation handling consistent.
- Added tests for a FEFO preview with no transaction API calls and a full-stock
  preview that reports shortfall without creating a reservation.
- Latest verification after cost-center reservation preview:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 180 ABAP Unit methods.
- Cost-center reservation previews and creations now accept
  `iv_allow_fallback` to prefer a supplied storage location, then use other
  locations for any remainder. This applies to location, exact-batch, and FEFO
  allocation; fallback without a location is rejected. Tests check preferred
  location ordering and reservation item splits in all three paths.
- Latest verification after cost-center location fallback:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 184 ABAP Unit methods.
- Added `ZCL_PROD_COMP_SERVICE->GET_OPEN_COMPONENTS` to read active, open
  production-order component reservation items from `RESB`. Results include
  reservation/item keys and the remaining quantity, ready for selection by the
  existing reservation issue service. `ISSUE_COMPONENTS` validates selected
  keys and quantities against those open rows before delegating to the existing
  reservation issue service. Added local tests for partial, complete, deleted,
  final-issue, over-withdrawn, and mismatched-order rows, plus successful
  selected-item issue and rejection of an item outside the order.
- Added partial `RESB` stub fields for production order, reservation keys, and
  reservation unit; live SAP query behavior remains an integration check.
- Latest verification after production-order component inquiry:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 189 ABAP Unit methods.
- Added `GET_STOCK_STATUS_IN_UNIT`, which converts the full plant stock status
  from the material base unit to a requested material-specific unit. The
  converter now exposes one validated `MARM` numerator/denominator ratio and
  converts in both directions. Tests cover the ratio, reverse conversion,
  all stock-status values, and unknown-unit rejection before stock reads.
- Latest verification after stock-status unit conversion:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 194 ABAP Unit methods.
- Added `ALLOCATE_DEMANDS_IN_UNITS` to convert and allocate multiple
  material-specific demand units in one shared allocation pass. It validates
  all material/unit ratios before reading stock, caches each ratio during the
  request, and returns both source-unit and base-unit details. Tests cover
  competing demands against shared stock and reject an unknown unit before any
  stock read.
- Latest verification after bulk alternative-unit allocation:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 196 ABAP Unit methods.
- Added alternative-unit stock-status inquiries by location and batch, plus a
  FEFO batch inquiry in the requested unit. Results preserve their location,
  batch, and expiration details, report both units, and validate the unit before
  stock reads. FEFO results keep the existing date filter and ordering. Tests
  cover conversion, ordering, and rejecting unknown units before repository
  reads.
- Latest verification after location and batch status unit conversion:
  `npm.cmd test` passed; abaplint reported zero issues and the transpiler ran
  all 200 ABAP Unit methods.
- Added `GET_STOCK_IN_TRANSFER_IN_UNIT`, converting the plant and optional
  storage-location in-transfer quantities to a requested material unit. It
  returns both base and requested units, and rejects missing or invalid ratios
  before reading transfer balances. Tests cover both conversions and unknown-
  unit rejection without a repository read.
- Latest verification after in-transfer unit conversion: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 202 ABAP Unit
  methods.
- Added `ALLOCATE_BY_EXPIRY_IN_UNITS` for shared FEFO allocation from multiple
  demands in material-specific units. The service validates and caches each
  material/unit ratio before stock reads, keeps demand order and existing FEFO
  rules, and returns base-unit summaries and splits with converted source-unit
  quantities. Tests cover mixed units consuming shared batches and rejecting
  an unknown unit before stock access.
- Latest verification after unit-aware FEFO allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 204 ABAP Unit
  methods.
- Added `ALLOCATE_BY_BATCH_IN_UNITS` for multiple exact-batch requests in
  material-specific units. It validates and caches ratios before stock reads,
  keeps each requested batch fixed, shares balances across input demands, and
  returns base and source-unit summaries plus location/batch splits. Tests cover
  mixed-unit demands, preferred-location fallback, shared stock, and rejection
  before reads for an unknown unit.
- Latest verification after exact-batch unit allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 206 ABAP Unit
  methods.
- Added `ALLOCATE_BY_LOCATION_IN_UNITS` for shared storage-location allocation
  from demands in material-specific units. It preserves preferred-location
  fallback, validates all ratios before stock reads, and returns base and
  source-unit summaries and location splits. Tests cover mixed-unit requests
  sharing balances across locations and unknown-unit rejection before reads.
- Latest verification after location unit allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 208 ABAP Unit
  methods.
- Added `ALLOCATE_REQUEST_BY_DATE` for a date-scoped plant availability estimate.
  It nets active unrestricted reservations due by the requested date, returns
  the usual available/allocated/shortfall quantities, and supports optional
  static safety-stock protection. Tests cover the dated split, safety-stock
  adjustment, and missing-date rejection. This remains a local estimate based
  on current stock and does not model future receipts or SAP ATP.
- Latest verification after date-scoped allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 244 ABAP Unit
  methods.
- Added the `ZIF_MATERIAL_AVAILABILITY_API` boundary and BAPI adapter for
  `BAPI_MATERIAL_AVAILABILITY`. `ALLOCATE_REQUEST_DATE_ATP` now returns the
  SAP-confirmed quantity/date and dialog status beside the date-scoped local
  allocation, using the caller's unit and checking rule. Tests verify request
  mapping and preserve the distinction between local and SAP quantities; the
  adapter still requires validation against the target SAP function signature.
- Latest verification after the ATP adapter: `npm.cmd test` passed; abaplint
  reported zero issues and the transpiler ran all 246 ABAP Unit methods.
- Extended `preview_order` with opt-in `iv_check_atp` and a caller-supplied
  checking rule. It requests a check per positive open schedule line using the
  cumulative open demand for that material, plant, and base unit through the
  required date. Same-date lines use the combined quantity due that day, and
  results retain both line and cumulative quantities in original order. The
  checks remain separate from local allocations. It rejects missing rules
  before order/stock reads and missing dates before stock allocation. Tests
  cover out-of-order and same-date lines, separate ATP/local quantities, and
  invalid rule/date inputs. SAP documents accumulation limits for this BAPI,
  so target checking configuration and live results still require validation.
- Latest verification after cumulative sales-order ATP checks: `npm.cmd test`
  passed; abaplint reported zero issues and the transpiler ran all 249 ABAP
  Unit methods.
- Added `ALLOCATE_DEMANDS_BY_DATE` for a set of requests sharing dated stock.
  It validates the full list before reads, allocates in ascending required-date
  order with input order as the tie-breaker, shares stock across later dates,
  caches repeated date snapshots and safety stock, and returns rows in input
  order. Tests cover an out-of-order list, repeated dates, shared stock,
  safety-stock protection, read caching, and rejection before reads.
- Latest verification after bulk dated allocation: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 251 ABAP Unit
  methods.
- Added opt-in `iv_include_po_receipts` to single-date, bulk-date, and
  date-based ATP comparison methods. The MARD repository adds the open
  remainder of dated standard stock
  PO schedule lines from `EKET`, filters deleted, completed, account-assigned,
  return, no-GR, and non-unrestricted stock-type items in `EKPO`, and converts
  PO units to base units through `UMREZ/UMREN`. Added a pure schedule-quantity
  converter with tests for partial receipts, conversion ratios, closed lines,
  and invalid ratios. The option is off by default; PO release and supplier-
  confirmation state are not modeled.
- Latest verification after purchase-receipt projections: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 256 ABAP Unit
  methods.
- Added opt-in `iv_include_sto_in_transit` to single-date, bulk-date, and
  date-based ATP comparison methods. The MARD repository projects schedule-line
  quantities already issued from stock-transfer items (`EKPO-PSTYP = '7'`) and
  still outstanding at receipt (`EKET-WAMNG - EKET-WEMNG`), due by the required
  date. It requires a supplying plant, excludes transport-document types and
  statistical items, and accepts PO/scheduling-agreement document categories.
  It converts the PO unit to the base unit and filters deleted,
  account-assigned, returns, no-GR, and non-unrestricted receiving items. Planned
  but unissued transfers are excluded, and the flag is off by default. Tests
  cover the converter, independent and combined PO/STO options, bulk allocation,
  and ATP comparison. Live STO schedule data and stock-type behavior still need
  validation in the target SAP system.
- Latest verification after STO in-transit projection: `npm.cmd test` passed;
  abaplint reported zero issues and the transpiler ran all 258 ABAP Unit
  methods.
- Added opt-in `iv_include_prod_receipts` to single-date, bulk-date, and
  date-based ATP comparison. The MARD repository projects open production-order
  item quantity (`AFPO-PSMNG - AFPO-WEMNG`) from released, GR-relevant category
  10 orders due by `AFKO-GLTRP`. It excludes deleted, completed, make-to-order,
  and account-assigned items and converts production units with
  `AFPO-UMREZ/UMREN`. A pure converter and dated-allocation tests cover partial
  receipts, closed orders, invalid conversions, and the opt-in behavior. Basic
  finish date and expected stock type remain estimates; target SAP validation
  is still needed.
- Latest verification after production-receipt projection: `npm.cmd test`
  passed; abaplint reported zero issues across 63 files and the transpiler ran
  all 262 ABAP Unit methods.
- Extended `ZIF_MATERIAL_AVAILABILITY_API` results with all `WMDVEX` dated
  confirmation lines, including requested date/quantity and confirmed
  date/quantity. The BAPI adapter maps every returned row; the existing scalar
  confirmation fields continue to mirror the first row. Added pure mapping
  tests for multiple and empty confirmation tables, plus a stock-service test
  that verifies multiple rows survive the ATP comparison result.
- Latest verification after preserving full ATP confirmations: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 264 ABAP Unit methods.
- Added `ENDLEADTME` to the material availability result as
  `end_of_replenishment_lead_time`, typed from `BAPICM61M-WZTER`. The BAPI
  adapter maps the date and the stock-service test verifies it survives the ATP
  result path. SAP documents that this date is returned when replenishment lead
  time is active; the target release's function signature still needs live
  validation.
- Latest verification after exposing the replenishment lead-time date:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 264 ABAP Unit methods.
- Updated sales-order ATP preview to call the availability API once per unique
  material/plant/base-unit/required-date group. Same-date lines continue to
  report their individual demand and shared cumulative quantity, while reusing
  the group's ATP result. The regression test verifies two calls for three
  positive schedule lines spanning two dates.
- Latest verification after reusing same-date ATP results: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 264 ABAP Unit methods.
- Added `ALLOCATE_DATE_DEMANDS_IN_UNITS` to combine date-priority allocation
  with material-specific input units. It validates request IDs and unit ratios
  before stock reads, caches repeated ratios, shares dated balances in base
  units, applies the existing receipt and safety-stock options, and returns
  canonical base quantities with rounded source-unit availability/allocation
  values. Tests cover out-of-order mixed-unit demand, all three receipt options,
  safety stock, and unknown-unit rejection before stock reads.
- Latest verification after dated unit-aware allocation: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 266
  ABAP Unit methods.
- Added `ALLOCATE_PLANTS_BY_DATE` to allocate dated demands from caller-ordered
  source plants. It processes earliest dates first, shares each source balance
  across requests, caches date snapshots and safety stock, supports projected
  PO/STO/production receipts, and returns plant splits in request/source order.
  It is a planning preview without storage-location splits. Tests cover reversed
  input dates, per-request source priority, shared stock across dates, receipts,
  safety-stock protection, and missing-source rejection before stock reads.
- Latest verification after dated cross-plant allocation: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 268 ABAP Unit methods.
- Added `ALLOCATE_PLANTS_DATE_UNITS` to combine dated cross-plant allocation
  with material-specific input units. It caches unit ratios, converts demand to
  base units, preserves date priority and caller source order, and returns
  converted demand and source-plant split details alongside canonical base-unit
  values. Tests cover receipt projection, shared stock across dates, source
  priority, output order, unit conversion, and unknown-unit rejection.
- Latest verification after dated cross-plant unit allocation: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 270 ABAP Unit methods.
- Corrected `ALLOCATE_REQUEST_DATE_ATP` to convert the caller's unit quantity
  to the material base unit for the local stock estimate while keeping the
  original unit and quantity on the SAP ATP request. Added an alternative-unit
  regression test and supplied the UOM test double to the existing ATP test.
- Latest verification after the ATP unit correction: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 271
  ABAP Unit methods.
- Added `ALLOCATE_DATE_DEMANDS_ATP` to compare unit-aware dated allocations with
  SAP ATP using cumulative base-unit demand per material/plant/unit/date. It
  shares one ATP response across same-day requests, returns results in input
  order, and keeps SAP ATP separate from the local receipt/safety-stock estimate.
  The test covers mixed input units, same-day aggregation, date priority, and
  reduced ATP calls for shared date groups.
- Latest verification after bulk dated ATP comparison: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 273
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_ALLOCATION` to post `ALLOCATE_BY_STORAGE_LOCATION`
  source splits as movement 311 items to a caller-selected destination per
  request. It reuses transfer completeness, split-total, unit-mapping, simulation,
  and transaction checks, and rejects a destination equal to a source location.
  Tests cover multiple source locations and same-location rejection.
- Latest verification after storage-location allocation transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 275 ABAP Unit methods.
- Added `TRANSFER_LOCATION_BATCH_ALLOC` for exact-batch `ALLOCATE_BY_BATCH`
  results. It posts movement 311 items per source location, retains each batch,
  and rejects a result that mixes batches for one request before calling SAP.
  Tests cover a multi-location batch transfer and mixed-batch rejection.
- Latest verification after batch location transfer: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 277
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_UNITS_ALLOC` to post unit-aware storage-location
  allocations as movement 311 items, carrying canonical base-unit split
  quantities and validating the result's base unit against the supplied
  material mapping. Tests cover multiple base-unit splits and unit mismatch
  rejection.
- Latest verification after unit-aware location transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 298 ABAP Unit methods.
- Added `TRANSFER_LOCATION_BATCH_UNITS` to post unit-aware exact-batch location
  allocations as movement 311 items. It preserves each batch, uses canonical
  base-unit split quantities, and rejects mixed batches or base-unit mismatches
  before the BAPI call. Tests cover a multi-location transfer and both invalid
  result cases.
- Latest verification after unit-aware batch location transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 301 ABAP Unit methods.
- Added `TRANSFER_LOCATION_FEFO_ALLOC` to post same-plant FEFO batch/location
  splits as 311 items. It carries each selected batch and keeps the preview's
  split order, including requests allocated from more than one batch. Tests
  cover a two-batch transfer and missing-batch rejection before the BAPI call.
- Latest verification after FEFO location transfer: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 303
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_FEFO_UNITS` for unit-aware FEFO location results. It
  posts canonical base-unit quantities and supports multiple FEFO-selected
  batches per request, preserving the preview's split order. Tests cover a
  mixed-batch transfer and rejection of a base-unit mismatch.
- Latest verification after unit-aware FEFO location transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 305 ABAP Unit methods.
- Added `TRANSFER_LOCATION_TWO_STEP` to turn validated storage-location splits
  into movement 313 removals and one 315 putaway item per request. Its result
  exposes both posting responses and marks stock still in transit when the
  second posting fails after removal committed. Tests cover both steps,
  preflight rejection, test run behavior, and pending putaway reporting.
- Latest verification after two-step location transfer: `npm.cmd test` passed;
  abaplint reported zero issues across 64 files and the transpiler ran all 311
  ABAP Unit methods.
- Added `TRANSFER_LOCATION_2STEP_UNITS`, which validates unit-aware location
  summaries and splits against material base-unit mappings before using the
  313/315 flow. It posts canonical base-unit quantities and reuses the two-step
  result status for failures between removal and putaway. Tests cover posting
  both legs and pre-post rejection of summary and split unit mismatches.
- Latest verification after unit-aware two-step location transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 314 ABAP Unit methods.
- Added `TRANSFER_PLANT_TWO_STEP` to map cross-plant allocation location splits
  to movement 303 removals and one 305 putaway item per request. The shared
  two-step flow validates all demands and source splits before posting and
  reports in-transit stock when putaway fails after removal. Tests cover the
  two movement legs and reject same-plant source splits before calling SAP.
- Latest verification after cross-plant two-step transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 316 ABAP Unit methods.
- Added `TRANSFER_PLANT_2STEP_UNITS` to accept unit-aware cross-plant location
  allocations. It checks summary and split base units against material unit
  mappings, then posts canonical base-unit quantities through 303/305.
  Tests cover both posting legs and pre-post summary and split unit mismatches.
- Latest verification after unit-aware cross-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 319 ABAP Unit methods.
- Added a plant two-step regression for a 303 removal that commits before the
  305 putaway fails. It confirms the result reports stock in transit and keeps
  the removal and putaway responses separate.
- Latest verification after plant putaway failure coverage: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 320 ABAP Unit methods.
- Added `TRANSFER_PLANT_BATCH_TWO_STEP` for exact-batch cross-plant allocations.
  It preserves a demand's selected batch across every 303 removal and its 305
  putaway, and rejects mismatched source batches before posting. Tests cover
  multiple source splits and batch mismatch rejection.
- Latest verification after batch-aware cross-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 322 ABAP Unit methods.
- Added `TRANSFER_PLANT_BATCH_2STEP_UOM` for unit-aware exact-batch cross-plant
  results. It checks summary and split base units against the material mapping
  and posts canonical quantities through 303/305 without losing the batch.
  Tests cover both posting legs and pre-post summary and split unit mismatches.
- Latest verification after unit-aware batch two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 325 ABAP Unit methods.
- Added `TRANSFER_PLANT_FEFO_TWO_STEP` for cross-plant FEFO results. It retains
  preview order on 303 removals and groups putaway quantities by request and
  batch, so source splits from one batch become one 305 item. Tests cover
  multiple batches, same-batch split grouping, and missing batch rejection.
- Latest verification after cross-plant FEFO two-step transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 327 ABAP Unit methods.
- Added `TRANSFER_PLANT_FEFO_2STEP_UOM` for unit-aware cross-plant FEFO results.
  It checks summary and batch split base units against the supplied material
  mapping and retains canonical quantities through grouped 303/305 posting.
  Tests cover batch grouping and pre-post summary and split unit mismatches.
- Latest verification after unit-aware cross-plant FEFO two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 330 ABAP Unit methods.
- Added `TRANSFER_LOCATION_FEFO_2STEP` for same-plant FEFO results. It retains
  preview order on 313 removals and combines same-batch source-location splits
  into per-batch 315 putaway items. Tests cover order, grouping, and rejection
  of a missing batch before posting.
- Latest verification after same-plant FEFO two-step transfer: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 332 ABAP Unit methods.
- Added `TRANSFER_LOC_FEFO_2STEP_UOM` for unit-aware same-plant FEFO results.
  It checks summary and batch split base units against material mappings, then
  posts canonical quantities through grouped 313/315 movements. Tests cover
  batch grouping and pre-post summary and split unit mismatches.
- Latest verification after unit-aware same-plant FEFO two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 335 ABAP Unit methods.
- Added `TRANSFER_LOCATION_BATCH_2STEP` for exact-batch location allocation
  results. It preserves the one batch across 313 source removals and combines
  same-batch source-location splits into one 315 putaway per request. Tests
  cover movement fields, combined quantity, and rejection of mixed batches
  before posting.
- Latest verification after exact-batch same-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 337 ABAP Unit methods.
- Added `TRANSFER_LOC_BATCH_2STEP_UOM` for unit-aware exact-batch location
  results. It checks the summary and source split base units against the
  material mapping, then posts canonical quantities through 313/315. Tests
  cover grouped batch quantities and pre-post summary and split unit mismatches.
- Latest verification after unit-aware exact-batch same-plant two-step transfer:
  `npm.cmd test` passed; abaplint reported zero issues across 64 files and the
  transpiler ran all 340 ABAP Unit methods.
- Added optional SAP ATP checking to `PREVIEW_FOR_COST_CENTER`. The result
  carries a separate plant-level ATP response based on the requested material
  base quantity and required date; it does not alter local allocation or
  success. Tests cover a local shortfall with ATP confirmation and missing-rule
  rejection before stock reads.
- Latest verification after cost-center preview ATP support: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 342 ABAP Unit methods.
- Added `GET_STOCK_IN_TRANSFER_BY_BATCH` for storage-location stock in transfer
  from `MCHB-CUMLM`, plus `GET_BATCH_TRANSFER_IN_UNIT` for requested-unit
  quantities with the base-unit balance retained. Tests cover batch/location
  mapping, alternative-unit conversion, and validation before repository reads.
- Latest verification after batch-level stock-transfer inquiry: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 346 ABAP Unit methods.
- Added `ALLOCATE_PLANTS_DATE_ATP` for unit-aware dated cross-plant estimates.
  It returns the unchanged local allocation plus plant-level ATP checks for
  positive source splits, grouping allocated base quantities cumulatively by
  source plant and date. Tests cover shared same-date groups, later cumulative
  quantities across requests, and early rejection of a missing check rule.
- Latest verification after dated cross-plant ATP support: `npm.cmd test`
  passed; abaplint reported zero issues across 64 files and the transpiler ran
  all 348 ABAP Unit methods.
- Added sales-order-scoped reservation release. The finder discovers open
  movement-231 RESB documents, excluding documents with another non-deleted
  item outside the requested order and stock scope. The service reuses the
  existing simulation, commit, and rollback path; no matching reservations is
  an idempotent success. It also previews eligible numbers without calling the
  BAPI and supports narrowing to one order item. Item-scoped releases skip a
  reservation document containing a non-deleted item for another order line.
  Local tests cover preview, item-scope forwarding, deletion, simulation, no
  matches, and blank order input. The database query still needs target-SAP
  validation.
- Latest verification after reservation release preview: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 353
  ABAP Unit methods.
- Added optional sales-order item scoping to reservation preview and release.
  The finder only returns complete documents whose non-deleted items match that
  order item. The item filter is forwarded through the injectable finder and is
  covered by preview and committing deletion tests.
- Latest verification after item-scoped reservation release: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 355 ABAP Unit methods.
- Added bulk sales-order reservation release for a unique order list. The finder
  uses one bulk candidate read and one scope-verification read, maps eligible
  reservation numbers back to each order, and deletes the deduplicated list in
  one transaction. `PREVIEW_ORDERS_RELEASE` returns those scopes without calling
  the delete BAPI. Empty matches are an idempotent success; blank or duplicate
  order numbers are rejected before database access. Tests cover grouped results,
  duplicate candidate deduplication, ambiguous reservation ownership rejection,
  read-only preview, one commit, empty matches, and invalid lists.
- Latest verification after bulk release preview:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 360 ABAP Unit methods.
- Added bulk reservation preview and release for explicit sales-order/item
  pairs. One bulk `RESB` read finds open matching lines and a second read excludes
  reservation documents containing a non-deleted row for another item. All
  selected item scopes share one delete transaction. Tests cover grouped item
  results, preview without BAPI calls, test-run without commit, invalid scopes,
  and ambiguous reservation ownership.
- Latest verification after item-scoped bulk release: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 365
  ABAP Unit methods.
- Added bulk production-order component inquiry and issue. The repository reads
  component rows for a unique order list in one guarded query. The service
  validates each selected reservation item against its originating order and
  sends multi-order issue requests through one goods-movement transaction.
  Existing single-order methods now use the shared bulk paths. Tests cover sorted
  component results, one repository read, one combined multi-order posting, and
  invalid order lists rejected before repository access.
- Latest verification after bulk production component issue: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 368 ABAP Unit methods.
- Two-step transfer results now retain their exact planned putaway items.
  `RETRY_TRANSFER_PUTAWAY` validates a pending transfer and posts only its 305 or
  315 items, preserving the committed removal. Simulations and failed retries
  remain in transit; only a successful committed retry clears the state. Tests
  cover simulation, repeated failure, recovery, completed-transfer rejection,
  and rejection of a removal movement in the putaway payload.
- Latest verification after putaway retry support: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 370
  ABAP Unit methods.
- Added `CANCEL_TRANSFER_IN_TRANSIT` as the compensating recovery path. It
  cancels the original removal document through the existing cancellation API,
  retains the pending state after a cancellation error, and exposes the reversal
  result plus an `is_cancelled` flag after commit. Tests cover cancellation API
  and commit failures followed by success, plus rejection of a second
  cancellation after completion.
- Latest verification after pending-transfer cancellation: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 372 ABAP Unit methods, including recovery of a same-plant 313/315 transfer.
- Added `ALLOCATE_PLANTS_FEFO_BY_DATE` for cross-plant date-prioritized batch
  allocation. Earlier requirements consume shared balances first, shelf life is
  checked against each required date, and source-plant order remains caller
  controlled. Static safety stock can be protected, and output order matches the
  input. Tests cover date priority, per-demand expiry eligibility, safety-stock
  protection, input ordering, and missing-date rejection.
- Latest verification after dated cross-plant FEFO: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 370
  ABAP Unit methods.
- Added `ALLOCATE_PLANTS_FEFO_DATE_UOM`, which converts dated cross-plant FEFO
  requests to base units while preserving date priority, per-demand shelf-life
  filtering, and unit-aware demand/source/batch results. Added
  `TRANSFER_FEFO_DATE_UOM` and `TRANSFER_FEFO_DATE_UOM_2STEP` adapters for 301
  and 303/305 goods movements. Tests cover date-sorted shared allocation, unit
  conversion, required-date validation, and both transfer flows.
- Added `ALLOCATE_PLANTS_FEFO_DATE_ATP` to compare positive FEFO source-plant
  allocations with cumulative SAP ATP by required date and base unit. The local
  FEFO estimate and ATP confirmations remain separate in the result.
- Latest verification after dated FEFO ATP and transfer adapters:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 376 ABAP Unit methods.
- Added an optional `it_allowed_storage_locations` allowlist to base, unit-aware,
  and ATP-enabled dated cross-plant FEFO allocation. The same validated list is
  applied to every source plant; empty input retains unrestricted selection.
  Tests verify excluded earlier-expiring stock, allowlist propagation through
  unit and ATP paths, and rejection of blank or duplicate locations before stock
  reads.
- Latest verification after FEFO source-location filtering: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 378 ABAP Unit methods.
- Added `it_source_locations` for request/source-plant-specific storage
  restrictions across base, unit-aware, and ATP-enabled dated FEFO allocation.
  The table must cover every source pair; when the shared allowlist is also set,
  the filters intersect. Tests cover distinct location assignments per request,
  propagation through unit conversion and ATP, and invalid/uncovered mappings.
- Latest verification after scoped FEFO storage rules: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 380
  ABAP Unit methods.
- Added direct confirmed and unconfirmed base-unit quantities to dated
  cross-plant ATP checks, including FEFO ATP.
  The service totals multiple confirmation lines, caps the confirmation
  at the cumulative quantity checked, and leaves the raw SAP result intact.
  Tests cover partial multi-line confirmation and the fully available case.
- Latest verification after ATP quantity splits: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 380
  ABAP Unit methods.
- Extended the direct quantity split to `ALLOCATE_DATE_DEMANDS_ATP`; repeated
  dated rows now expose the same cumulative confirmed and unconfirmed base
  quantities. Tests cover a multi-line partial confirmation shared by requests
  due on the same date.
- Latest verification after dated ATP response consistency: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 380 ABAP Unit methods.
- Added the same base-unit confirmation split to `ALLOCATE_REQUEST_DATE_ATP`.
  The helper converts all alternative-unit confirmation lines with the validated
  material ratio before capping the total. Tests cover multiple confirmations
  in base and alternative units.
- Latest verification after single-request ATP quantity reporting:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 380 ABAP Unit methods.
- Promoted `GET_ATP_CONFIRMATION_SPLIT` as a shared stock-service API and added
  base-unit confirmed/unconfirmed quantities to single-order and multi-order ATP
  checks. Same-date sales-order rows reuse the same split; tests cover
  multi-line confirmations and the multi-order reservation preview path.
- Latest verification after sales-order ATP quantity reporting: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 380 ABAP Unit methods.
- Hardened the shared ATP confirmation splitter to reject negative requested
  base quantities and nonpositive conversion ratios before calculation. Added a
  regression test for a zero denominator and negative request.
- Latest verification after ATP split input validation: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 381
  ABAP Unit methods.
- Extended `preview_for_cost_center` with direct confirmed and unconfirmed
  base-unit quantities from its optional ATP check. The preview shares the
  cross-service splitter, and its alternative-unit request is already converted
  before ATP, so returned split quantities remain in the stock base unit.
- Latest verification after cost-center ATP quantity reporting: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 381 ABAP Unit methods.
- Added single-order and bulk production-component ATP previews. They convert
  open reservation quantities to base units, accumulate checks by material,
  plant, base unit, and required date, and return raw SAP ATP results with
  confirmed/unconfirmed cumulative quantities. Blank rules and undated or
  incomplete open components are rejected before any ATP call.
- Latest verification after production-component ATP preview: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 385 ABAP Unit methods. The SAP repository query and live ATP behavior
  remain unverified locally.
- Extended both production-component ATP preview entry points with a separate
  local dated stock estimate. It shares stock across component dates and can
  include PO/STO/production receipts, subtract unissued STO demand, and protect
  static safety stock. Added coverage for date-group aggregation, receipt
  projection, safety-stock protection, and the single-order wrapper.
- Latest verification after component stock/ATP comparison: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 385 ABAP Unit methods.
- Added `component_local_estimate` so each production component gets a
  deterministic share of the date group's local allocation. Components consume
  the shared date balance in production-order, reservation, and item order;
  group-level estimates remain available beside the per-component split. Tests
  cover partial allocation across same-date components, including an
  alternative-unit component.
- Latest verification after per-component stock splits: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 385
  ABAP Unit methods.
- Added `SUMMARIZE_COMPONENT_READINESS` to roll local component allocations up
  by production order, including covered/short counts, date range, first
  shortage date, and a local-ready flag. It validates reservation keys and
  quantity consistency. Tests cover mixed-ready orders, date ranges, first
  shortage selection, and malformed rows.
- Latest verification after component readiness summaries: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 387 ABAP Unit methods.
- Added single-order and bulk local-only component stock previews. They share
  the same conversion, dated stock grouping, receipt projection, safety-stock,
  and component-split logic as ATP previews, while skipping the ATP API and
  checking-rule requirement. Tests verify local shortfall output and zero ATP
  calls through both entry points.
- Latest verification after local-only component previews: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 388 ABAP Unit methods.
- Added `SUMMARIZE_COMPONENT_SHORTAGES`, which groups valid component preview
  rows by material, plant, base unit, and required date. It reports component
  counts, distinct affected production orders, and summed requested, allocated,
  and shortfall quantities, returning only groups with local shortfall. The
  validation also ensures every local allocation matches the row's available
  quantity before this roll-up is calculated.
- Latest verification after component shortage summaries: `npm.cmd test`
  passed; abaplint reported zero issues across 65 files and the transpiler ran
  all 389 ABAP Unit methods.
- Added component-level ATP confirmation and unconfirmed quantities. The split
  assigns each date's nonnegative increase in cumulative confirmation across
  same-date component rows in production-order/reservation/item order, while
  preserving the existing repeated cumulative group totals. Tests cover
  partial same-date allocation and the increase at a later required date.
- Latest verification after per-component ATP confirmation splits:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 389 ABAP Unit methods.
- Added `SUMMARIZE_ORDER_ATP` for check-relevant component ATP rows. It groups
  counts and quantities by production order, material, plant, and base unit,
  tracks date range and first unconfirmed date, and rejects inconsistent or
  unchecked ATP rows. Tests cover partial, full, and unconfirmed components
  across different base units and dates.
- Latest verification after order ATP summaries: `npm.cmd test` passed;
  abaplint reported zero issues across 65 files and the transpiler ran all 390
  ABAP Unit methods.
- Made production-component ATP confirmation date-aware. The shared confirmation
  splitter now accepts an optional required-date cutoff; component previews use
  it to exclude confirmations after the requirement date and undated lines,
  while retaining the complete raw ATP response. Existing callers without a
  cutoff keep their prior all-lines behavior. Tests cover due, later, and
  undated confirmation lines and the downstream component split.
- Latest verification after date-limited component ATP confirmation:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 391 ABAP Unit methods.
- Added `SUGGEST_COMP_REPLENISHMENT` to turn local component shortage rows into
  base-unit quantity suggestions using optional per-material/plant/unit
  minimums and order multiples. It rounds up, reports surplus, validates
  policy and shortage keys, and uses the exact shortfall if no policy is
  supplied. It does not create SAP purchasing documents or adjust dates for
  lead times.
- Latest verification after component replenishment suggestions:
  `npm.cmd test` passed; abaplint reported zero issues across 65 files and the
  transpiler ran all 393 ABAP Unit methods.
- Integrated replenishment suggestions with a bulk MARC/MARA policy repository.
  Caller overrides win. SAP lot-for-lot (`DISLS = EX`) applies `BSTMI` and
  `BSTRF`; fixed lot (`FX`) applies `BSTFE`; other procedures return the exact
  shortfall with an explicit unsupported origin. Results report policy origin
  and lot-size procedure. Added MARC stubs for the required planning fields and
  documented the procedures that are not modeled.
- Latest verification after procedure-aware MARC replenishment policies:
  `npm.cmd test` passed; abaplint reported zero issues across 67 files and the
  transpiler ran all 393 ABAP Unit methods. `git diff --check` passed.
- Added maximum-lot splitting for `EX` replenishment suggestions from
  `MARC-BSTMA`. Results include total receipt count and the final receipt
  quantity; a split remainder is raised to minimum quantity and rounded. Invalid
  minimum/maximum combinations or an unfit rounded remainder are marked
  unsupported and fall back to the exact shortage.
- Latest verification after maximum-lot splitting: `npm.cmd test` passed;
  abaplint reported zero issues across 67 files and the transpiler ran all 393
  ABAP Unit methods.
- Added the raw material procurement type (`MARC-BESKZ`) and special
  procurement key (`MARC-SOBSL`) to the policy lookup and recommendation result.
  This exposes SAP's routing context to callers without trying to resolve
  vendor/source-of-supply customizing in the quantity suggestion service.
- Latest verification after adding procurement-route context: `npm.cmd test`
  passed; abaplint reported zero issues across 67 files and the transpiler ran
  all 393 ABAP Unit methods.
- Added material-master lead-time estimates to replenishment suggestions for
  externally procured materials without a special procurement key. The bulk
  lookup now returns `MARC-PLIFZ`/`WEBAZ`, `T001W-FABKL`, and `T399D-BZTEK`;
  the dates use calendar days for planned delivery and factory-calendar
  workdays for goods receipt and purchasing processing. Results distinguish
  missing policy/calendar data, special sourcing, in-house/ambiguous
  procurement, unsupported procurement, calendar errors, and estimates. Public
  status constants make the result contract easier for callers to consume.
  Added tests for a successful date calculation, unsupported routes, missing
  calendar data, and calendar API failure. The estimate is material-master
  based and indicative; source-specific purchasing data and MRP margins are not
  modeled. The target SAP calendar function modules and joined customizing
  tables still require target-release validation.
- Latest verification after replenishment timing estimates and status constants:
  `npm.cmd test` passed; abaplint reported zero issues across 69 files and the
  transpiler ran all 393 ABAP Unit methods.
- Added source-specific planned delivery time support for a purchasing info
  record already resolved by the caller. Caller policies can pass vendor,
  purchasing organization, info-record number/category, and `EINE-APLFZ`; a
  positive source lead time takes precedence over the policy's generic planned
  delivery value. Zero falls back to that caller-supplied material lead time.
  Suggestions preserve source identity and identify the source of effective
  planned delivery days. Incomplete source identity or a source supplied for a
  non-external/special-procurement policy is rejected. Added minimal EINA/EINE
  stubs for DDIC typing and tests for positive source override, zero fallback,
  and invalid source context. No automatic source determination or EINA/EINE
  query is performed; the host must apply SAP's source-list, quota, validity,
  and purchasing-organization rules before passing a source.
- Latest verification after source-specific delivery-time support:
  `npm.cmd test` passed; abaplint reported zero issues across 69 files and the
  transpiler ran all 393 ABAP Unit methods.
- Added deterministic requisition-release urgency to replenishment suggestions.
  Callers can supply an as-of date; it defaults to `sy-datum`. When a release
  date estimate exists, results report whether that date is overdue and the
  elapsed calendar days. Tests cover an overdue source-based date and a release
  due today, including the explicit as-of date in the result.
- Latest verification after release-date urgency: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 393
  ABAP Unit methods.
- Added optional chronological netting of lot-size rounding surplus across
  dated component shortages. The default still plans each date independently;
  `iv_net_prior_surplus = abap_true` orders shortages by material, plant, unit,
  and date, carries leftover surplus forward, and emits `COVERED_BY_SURPLUS`
  rows when no new receipt is needed. Results expose each row's net planning
  quantity, prior surplus used, and remaining carry. The behavior only nets
  suggestions produced in this call and assumes prior surplus is available by
  later required dates; it does not replace projected receipt previews.
- Latest verification after dated surplus netting: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 394
  ABAP Unit methods. `git diff --check` passed.
- Added optional dated receipt netting to replenishment suggestions. Callers can
  pass validated PO, stock-transfer, or production receipt quantities; the
  service consumes supply by material, plant, unit, and receipt date, and
  reports `projected_receipt_used_qty` separately from suggestion rounding
  surplus. Optional receipt source identities are returned with each consumed
  line for traceability. Fully covered dates identify receipt-only or combined
  receipt and surplus coverage. Receipt input triggers chronological shortage
  processing through a key/date-sorted supply index that preserves caller order
  within a date; the service performs no receipt-source query.
- Latest verification after projected receipt netting: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 395
  ABAP Unit methods.
- Added `GET_PROJECTED_RECEIPTS` to the stock repository and stock service. It
  exposes source-level PO, issued/unissued STO, and released production receipt
  rows with base-unit quantity, receipt date, and document/item/schedule-line
  identity. Callers can map those rows directly into replenishment suggestions;
  each source group remains opt-in and the target SAP queries still require
  release validation.
- Added `SUGGEST_COMP_REPL_FROM_STOCK`, which gathers selected receipt
  types once per unique material/plant through the latest shortage date, then
  nets the returned rows by base-unit key and required date. This removes the
  manual receipt mapping step while preserving caller policy and date controls.
- Latest verification after receipt-source integration: `npm.cmd test` passed;
  abaplint reported zero issues across 69 files and the transpiler ran all 397
  ABAP Unit methods.
- Filtered PO, STO, and production receipt rows after conversion to the stock
  quantity type. Very small positive calculated quantities can round to zero at
  that boundary; the adapter now omits those zero-quantity rows so the public
  receipt contract stays strictly positive.
- Latest verification after the SAP receipt precision guard: `npm.cmd test`
  passed; abaplint reported zero issues across 69 files and the transpiler ran
  all 397 ABAP Unit methods. `git diff --check` passed.
- Added `pr_release_urgency` to replenishment suggestions as a direct status for
  estimated requisition release timing: `NO_ESTIMATE`, `OVERDUE`, `DUE_TODAY`,
  or `UPCOMING`. Existing release-date, overdue flag, and day-count fields stay
  available. Tests cover all four states using a fixed as-of date.
- Latest verification after release urgency categorization: `npm.cmd test`
  passed; abaplint reported zero issues across 69 files and the transpiler ran
  all 398 ABAP Unit methods. `git diff --check` passed.
- Added purchase requisition creation from replenishment suggestions through a
  `BAPI_PR_CREATE` adapter and injectable API. Positive suggestions become one
  requisition item per planned receipt lot, preserving maximum/fixed lot splits;
  inconsistent count/quantity combinations are rejected before the BAPI call.
  The service supports BAPI test-run mode, commits only successful writes with a
  returned requisition number, and rolls back API, document-number, and commit
  failures. Covered zero-quantity suggestions are a successful no-op. The
  service accepts a caller-selected PR type plus optional purchasing group and
  organization, and leaves vendor/source selection to SAP.
- Added minimal local DDIC stubs for the BAPI PR header and item structures.
  The function module and transaction calls are isolated in the SAP adapter;
  local service tests use a fake. Target-release BAPI fields and customizing
  remain unverified here.
- Latest verification after requisition creation: `npm.cmd test` passed;
  abaplint reported zero issues across 73 files and the transpiler ran all 403
  ABAP Unit methods. `git diff --check` passed.
- Restricted requisition creation to suggestions explicitly marked as externally
  procured (`F`) with no special procurement key. Missing, in-house, ambiguous,
  and special-procurement routes now fail validation before any BAPI call;
  tests cover those cases.
- Latest verification after requisition procurement-route validation:
  `npm.cmd test` passed; abaplint reported zero issues across 73 files and the
  transpiler ran all 403 ABAP Unit methods. `git diff --check` passed.
- Added `submitted_items` to the requisition result. Each row returns its PR
  item number and 1-based source suggestion index, preserving the mapping when
  a maximum/fixed-lot suggestion expands into multiple PR items. The mapping is
  available for normal writes and BAPI test-runs.
- Latest verification after PR item-to-suggestion mapping: `npm.cmd test`
  passed; abaplint reported zero issues across 73 files and the transpiler ran
  all 403 ABAP Unit methods. `git diff --check` passed.
- Added optional per-suggestion purchasing group and purchasing organization
  overrides for requisition creation. Controls use the returned 1-based source
  suggestion index; blank fields inherit method defaults. Duplicate,
  out-of-range, covered-suggestion, and empty controls fail before the BAPI.
- Latest verification after per-suggestion purchasing controls: `npm.cmd test`
  passed; abaplint reported zero issues across 73 files and the transpiler ran
  all 403 ABAP Unit methods. `git diff --check` passed.
- Preserved structured `BAPIRET2` message context in requisition results,
  including message class/number, variables, parameter, item row, field,
  system, and log identifiers for create and commit messages. Tests confirm
  errors retain their field/item context through rollback handling.
- Latest verification after structured requisition diagnostics: `npm.cmd test`
  passed; abaplint reported zero issues across 73 files and the transpiler ran
  all 403 ABAP Unit methods. `git diff --check` passed.
- Mapped BAPI `PRITEM` and `PRITEMX` message rows back to the generated
  requisition item number and original source suggestion index. Rows outside
  the submitted item table remain unlinked instead of being assigned a false
  source.
- Latest verification after requisition message-to-suggestion correlation:
  `npm.cmd test` passed; abaplint reported zero issues across 73 files and the
  transpiler ran all 403 ABAP Unit methods. `git diff --check` passed.
- Added explicit requisition outcome flags for test-run mode, whether the BAPI
  was called, and whether commit succeeded. Covered-only suggestions return a
  successful no-op with both BAPI/commit flags false; simulation calls remain
  uncommitted.
- Latest verification after requisition outcome flags: `npm.cmd test` passed;
  abaplint reported zero issues across 73 files and the transpiler ran all 403
  ABAP Unit methods. `git diff --check` passed.
- Preserved caller-resolved purchasing source details when creating requisitions:
  the selected vendor is sent as the PR fixed vendor, the source purchasing
  organization is used ahead of the global default, and explicit per-suggestion
  controls remain able to override it. Extracted BAPI item/flag mapping into a
  testable mapper and reject partial source identities before calling SAP.
- Latest verification after selected-source propagation: `npm.cmd test`
  passed; abaplint reported zero issues across 75 files and the transpiler ran
  all 404 ABAP Unit methods. `git diff --check` passed.
- Forwarded the selected purchasing info-record number to the PR item as
  `INFO_REC`, including its X flag; the mapper test also confirms both values
  stay initial for automatically sourced items. Source category remains
  available in the originating suggestion.
- Latest verification after info-record propagation: `npm.cmd test` passed;
  abaplint reported zero issues across 75 files and the transpiler ran all 404
  ABAP Unit methods. `git diff --check` passed.
- Added opt-in purchase requisition receipts to projected supply. Remaining
  quantity is `EBAN-MENGE - EBAN-BSMNG`, converted from the requisition unit to
  the material base unit and traced to BANFN/BNFPO. The repository excludes
  deleted, completed, requester-blocked, nonstandard, account-assigned, and
  special-stock items. The flag flows through stock receipt reads and component
  replenishment suggestions; it defaults off. Release strategy and supplier
  commitment are not evaluated, so the projection remains indicative.
- Added local quantity-calculator and service coverage for open and fully
  ordered quantities, alternate-unit conversion, default-off behavior, and
  shortage netting. Typed the calculator test values to avoid character-based
  numeric comparison in the transpiler runtime.
- Latest verification after PR receipt projection: `npm.cmd test` passed;
  abaplint reported zero issues across 77 files and the transpiler ran all 407
  ABAP Unit methods. `git diff --check` passed.
- Extended `iv_include_pr_receipts` through single, bulk, unit-aware, ATP
  preview, and cross-plant dated stock allocation. Dated local availability
  reuses the centralized projected-receipt rows and adds only PRs due by the
  requested date. SAP ATP requests remain unchanged. Added coverage for
  default-off and opt-in dated allocation.
- Verification after dated PR receipt support: `npm.cmd test` passed;
  abaplint reported zero issues across 77 files and the transpiler ran all 407
  ABAP Unit methods. `git diff --check` passed.
- Carried the option into component stock/ATP previews and multi-sales-order
  dated previews and reservations. Component coverage verifies local supply
  changes while ATP stays independent; sales-order coverage verifies the
  default-off and enabled paths.
- Verification after higher-level PR projection integration: `npm.cmd test`
  passed; abaplint reported zero issues across 77 files and the transpiler ran
  all 407 ABAP Unit methods. `git diff --check` passed.
- Added a distinct opt-in `iv_include_sto_pr_receipts` source for stock-transfer
  requisitions (EBAN item category 7). It projects open `MENGE - BSMNG` by
  requested date, converts to the base unit, identifies rows as `STO_PR`, and
  exposes issuing plant `RESWK` as `source_plant`. The option flows through
  dated allocation, component replenishment, component previews, and
  multi-sales-order previews/reservations. It remains separate from direct
  vendor PRs and stock-transfer orders.
- Added local coverage for source selection/traceability, default-off and
  enabled dated allocation, component replenishment, and sales-order preview.
  Verification after stock-transfer requisition projection: `npm.cmd test`
  passed; abaplint reported zero issues across 77 files and the transpiler ran
  all 409 ABAP Unit methods. `git diff --check` passed.
- Added opt-in planned-order supply from `PLAF`, distinct from released
  production orders. The projection excludes fixed orders, planning scenarios,
  special stock, and sales-order-specific proposals. It converts `GSMNG` to the
  material base unit, dates supply by `PEDTR`, and requires the basic start and
  finish dates to fall within the
  current allocation horizon. `PLANNED_ORDER` preserves the source order number.
  The new flag defaults off and flows through stock allocation, component
  replenishment and previews, and sales-order dated preview/reservation APIs.
- Added calculator and service-double coverage for unit conversion,
  default-off behavior, dated availability, replenishment netting, and the
  component and sales-order flows. Planned-order database selection remains
  unverified against a live SAP release; see `ANOMALIES.md` for the field and
  lifecycle assumptions.
- Verification after planned-order supply support: `npm.cmd test` passed;
  abaplint reported zero issues across 79 files and the transpiler ran all 413
  ABAP Unit methods. `git diff --check` passed.
- Added a bulk read-only purchasing info-record candidate lookup keyed by
  material, plant, purchasing organization, and delivery date. It filters
  standard, nondeleted candidates within inclusive validity dates, keeps both
  plant-specific and organization-level records, and ranks an optional
  preferred vendor first followed by plant-specific matches. It returns all
  matches so the caller can apply configured SAP source-list/quota/contract
  rules and choose the source. Local service
  tests cover ranking, date boundaries, filtering, and invalid requests; the
  live EINA/EINE join still needs target-release validation.
- Added optional request-level preferred-vendor ranking to source candidates.
  Preferred vendors sort before plant-specific scope; both flags are returned
  and all valid matches remain visible for caller review. Added coverage for a
  preferred organization-level candidate outranking a plant-specific record.
- Included the info-record's inclusive `valid_from`/`valid_to` dates in each
  candidate so callers can display the matched source window alongside the
  requested delivery date.
- Latest verification after source candidate ranking and validity details:
  `npm.cmd test` passed; abaplint reported zero issues across 83 files, the
  transpiler wrote 699 objects, and the transpiler ran all 417 ABAP Unit
  methods. `git diff --check` passed.
- Extended purchasing-source review with plant source-list rules. The repository
  bulk-reads `MARC-KORDB` and `EORD`; blocked matching sources are excluded, and
  mandatory source lists require an unblocked entry covering the delivery date.
  Only vendor-only source-list records validate an info-record candidate;
  outline-agreement entries remain separate sources.
  Candidates expose fixed-source and MRP-use flags plus the source-list record
  and validity period, and return the material's quota-arrangement usage flag.
  When quota usage is configured, the service reads active classic
  external-supplier items from `EQUK`/`EQUP`, calculates their documented
  `(allocated + base) / quota` rating, and ranks matching quota items before
  the existing fixed-source, preferred-vendor, and plant-specific signals.
  Equal zero ratings use higher quota first. Candidates with no matching quota
  item remain available after assigned quota candidates. Tests cover quota
  ratings, zero-rating ties, and avoiding quota reads when `MARC-USEQU` is
  unset, alongside source-list filtering and date rules.
  This remains an advisory snapshot: it does not reserve quota, model splitting
  quotas or special procurement, or replace SAP source determination.
- Verification after quota-aware candidate ranking: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 702
  objects, and the project contains 425 ABAP Unit test methods.
  `git diff --check` passed. The `EQUK`/`EQUP` SQL has not been executed against a live
  SAP system.
- Added a bulk `TMQ2` read keyed by the material's `MARC-USEQU` code. Candidate
  results now carry the configured inclusion flags for requisitions, purchase
  orders, scheduling-agreement schedules, planned orders, automatic MRP,
  production orders, and invoices; quota items are loaded only when a matching
  usage rule exists. For direct requisition previews, equal quota ratings now
  follow quota item sequence. SAP Help and its direct requisition sourcing
  guidance describe different zero-rating tie behavior, so the discrepancy and
  target-workflow validation are documented in `ANOMALIES.md`.
- Verification after quota-usage context support: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, transpilation wrote 703
  objects, and 426 ABAP Unit test methods are present. `git diff --check`
  passed. The `TMQ2`/`EQUK`/`EQUP` queries still need target-system validation.
- Added `EINE-AUT_SOURCE` to the info-record read and expose it on each candidate
  as `is_auto_source_relevant`. This closes the automatic-sourcing visibility
  gap while retaining non-marked records for manual review; the flag does not
  replace source determination. SAP identifies the field in KBA 2411004 and
  documents its MRP role. Tests cover both marked and unmarked candidate
  results. The backend `EINE` field and query still need target-release
  validation.
- Verification after automatic-sourcing metadata: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, transpilation wrote 703
  objects, and the project contains 427 ABAP Unit test methods.
  `git diff --check` passed.
- Added optional base-unit request quantities to source candidate lookup.
  Candidates now return `EINE-MINBM`/`EINE-BSTMA` in the purchasing unit and
  converted bounds using `EINA-UMREZ`/`UMREN`; `quantity_limit_status` reports
  inclusive range, below/above limit, unit mismatch, missing conversion, or
  invalid range. Requests without a quantity retain the candidate and report
  `NOT_REQUESTED`. The result is advisory because SAP MRP may handle minimum
  quantities differently by workflow; see `ANOMALIES.md`.
- Verification after quantity-range preview: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, transpilation wrote 703 objects, and
  431 ABAP Unit test methods are present. The transpiled runner executed the
  source-candidate boundary, conversion, unit-mismatch, missing-conversion,
  invalid-range, and request-validation tests. `git diff --check` passed.
- Added `GET_VALID_OUTLINE_SOURCES` as a separate read-only preview for
  source-list-linked purchase contracts and scheduling agreements. It joins
  the source-list entry to its purchasing document and item, filters agreement
  category and both validity windows, excludes blocked/deleted/completed rows
  and source-list/header vendor mismatches, honors vendor-level source blocks,
  and returns fixed-source, MRP-use, and preferred-vendor details. Fixed sources
  rank ahead of the preferred vendor. It does not resolve SAP release status,
  agreement capacity, prices, schedule lines, or final source assignment.
- Added repository-double coverage for result metadata/ranking, validity and
  lifecycle filters, vendor-level blocks, and invalid requests. Extended the
  local EKKO stub with the fields used by the read.
- Carried caller-selected outline agreements through replenishment policies
  and suggestions into purchase-requisition items. The mapper sends `AGREEMENT`
  and `AGMT_ITEM` plus their update flags; the requisition service also passes
  the selected vendor and purchasing organization. Info-record and agreement
  references are exclusive, and incomplete pairs are rejected before writing.
- Added coverage for agreement-reference propagation in component suggestions,
  PR creation inputs, BAPI item mapping, and rejection of partial or mixed
  source identities. Expanded the local BAPI input and update-flag stubs.
- Verification after the agreement-source requisition path: `npm.cmd test`
  passed; abaplint reported zero issues across 83 files, the transpiler wrote
  703 objects, and all 436 ABAP Unit methods ran. `git diff --check` passed.
- Added an opt-in scheduling-agreement receipt source to projected-receipt
  reads and component replenishment suggestions. It projects open external
  standard-item schedule quantities by delivery date and returns agreement,
  item, and schedule-line identity; it remains disabled by default.
- Separated purchasing-document categories in the existing PO receipt query,
  so scheduling-agreement lines cannot leak into the PO source when the new
  flag is false. Fixture tests cover opt-in filtering and source identity.
- Verification after scheduling-agreement receipt support: `npm.cmd test`
  passed; abaplint reported zero issues across 83 files, the transpiler wrote
  703 objects, and all 438 ABAP Unit methods ran. `git diff --check` passed.
- Extended the scheduling-agreement switch through dated stock availability,
  single, bulk, unit-aware, plant-source and ATP allocation paths, component
  stock/ATP previews, and multi-sales-order previews/reservations. The dated
  repository aggregates scheduling-agreement quantities through the shared
  projected-receipt source; these quantities affect local estimates, not SAP
  ATP requests.
- Added coverage for dated stock allocation, component preview, sales-order
  preview, and simulated reservation propagation with the switch both off and
  on. Updated the README and anomaly notes with the wider API coverage and ATP
  behavior.
- Verification after dated scheduling-agreement support: `npm.cmd test`
  passed; abaplint reported zero issues across 83 files, the transpiler wrote
  703 objects, and all 439 ABAP Unit methods ran. `git diff --check` passed.
- Added optional `iv_require_auto_source` filtering to purchasing info-record
  candidates. The default still exposes unmarked records for review; callers
  can require `EINE-AUT_SOURCE = 'X'` when they need that indicator. Expanded
  the existing test to cover default and filtered results.
- Verification after automatic-sourcing filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 439 ABAP Unit methods ran. `git diff --check` passed.
- Added optional `iv_require_source_listed` filtering to info-record
  candidates. The default keeps unlisted valid records when source lists are
  not mandatory; callers can require an active matching vendor entry, subject
  to the existing date, block, and outline-agreement rules. Tests cover both
  default visibility and opt-in filtering.
- Verification after source-list filtering: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 440 ABAP Unit methods ran. `git diff --check` passed.
- Validated both source-candidate filter flags before processing requests, so
  unsupported `abap_bool` values raise `zcx_invalid_stock_request`, including
  for an empty request table. Added test coverage for each invalid option.
- Verification after source-filter validation: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 441 ABAP Unit methods ran. `git diff --check` passed.
- Added `iv_require_mrp_relevant` to require a matching listed source with its
  `EORD-AUTET` automatic-MRP usage set. Tests distinguish general source-list
  membership from MRP-relevant membership; all source-filter booleans are
  validated even for empty request lists.
- Verification after MRP source-list filtering: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 441 ABAP Unit methods ran. `git diff --check` passed.
- Added caller-supplied integer priority to dated plant/material demands. Earlier
  required dates still allocate first; within a date, larger priorities allocate
  before smaller values, with input order breaking ties. Results remain in input
  order and echo priority. The unit-aware wrapper carries the same priority
  through base-unit conversion; ATP checks remain grouped by date.
- Added coverage proving date precedence, descending same-date priority, stable
  ties, input-order results, and priority propagation through unit conversion.
- Verification after dated request priorities: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  the runner passed all 443 ABAP Unit methods. `git diff --check` passed.
- Corrected the recent scheduling and source-filter test counts above after
  comparing them with the executable test-method inventory.
- Extended dated request priority to cross-plant demand allocation and its
  unit-aware wrapper. Earlier dates still win; higher same-date priority is
  allocated first while each request keeps its caller-ordered source plants.
  Priority is echoed in demand summaries and source-plant split rows; ATP stays
  grouped by material, source plant, unit, and date.
- Added tests for cross-plant priority, output ordering, source split order,
  date precedence, and unit conversion.
- Verification after cross-plant demand priorities: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and the runner passed all 445 ABAP Unit methods. `git diff --check`
  passed.
- Extended same-date caller priority to cross-plant FEFO allocation, its
  unit-aware wrapper, and its ATP preview path. Earlier dates still take shared
  batches first; within each date, higher priority consumes eligible batches
  first while each request retains source-plant order. Priority is echoed on
  demand, source, and batch split rows; ATP remains grouped by date.
- Expanded FEFO tests to prove earlier-date precedence over a higher later
  priority, priority ordering within a date, FEFO batch choice, input-order
  results, and priority propagation through unit conversion.
- Verification after dated FEFO priorities: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  the runner passed all 445 ABAP Unit methods. `git diff --check` passed.
- Added HB replenishment up to maximum stock for supplied component shortages.
  The policy repository reads `MARC-MABST`; caller policies can supply the same
  maximum-stock value. Suggestions cover the remaining shortage or top up to
  the configured maximum, whichever is larger. Added material-master and
  caller-policy tests for both cases, and documented that this is not a full
  MRP stock/requirements calculation.
- Verification after HB maximum-stock sizing: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 446 ABAP Unit methods passed. `git diff --check` passed.
- Added opt-in `iv_require_qty_in_range` filtering to purchase-info-record
  candidates. For requests with a quantity, it retains only candidates whose
  converted minimum/maximum status is within range. Requests without a quantity
  remain reviewable; the filter is disabled by default because MRP does not
  necessarily enforce every maintained minimum quantity. Boolean validation
  also covers empty request lists.
- Verification after quantity-feasible source filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 446 ABAP Unit methods passed. `git diff --check` passed.
- Added opt-in sequential quota simulation to `GET_VALID_PIR_CANDIDATES`.
  Requests are evaluated by material, plant, due date, and input order; each
  selected source is added to a local quota balance when a positive request
  quantity is supplied and the quota usage rule counts purchase requisitions.
  Later candidate rankings use the updated local rating while the existing
  quota fields continue to show the stored snapshot. The nested
  `quota_simulation` result reports the selected source and pre-request quota
  rating and balance. It remains a local preview and does not write SAP quota
  data. Added coverage for due-date sequencing, changed later selection,
  unchanged default rankings, quota-usage configuration, and unit validation.
- Verification after sequential quota simulation: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added optional `iv_require_mrp_relevant` filtering to
  `GET_VALID_OUTLINE_SOURCES`. The default retains valid agreements for manual
  review; callers can require a matching source-list agreement entry marked
  for automatic MRP. Invalid filter values are rejected even for empty input.
  Tests cover the default list, filtered list, and invalid boolean validation.
- Verification after outline-source MRP filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added independent `iv_require_fixed_source` filtering to
  `GET_VALID_OUTLINE_SOURCES`. Callers can require the source-list fixed
  indicator; the default keeps non-fixed valid agreements visible. Invalid
  filter values are rejected even for empty input, with test coverage alongside
  the MRP-relevance filter.
- Verification after outline-source fixed filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added the matching `iv_require_fixed_source` option to
  `GET_VALID_PIR_CANDIDATES`, so callers can require that an info-record source
  list entry is fixed; unlisted and non-fixed sources are omitted only when
  requested. Empty-request boolean validation and fixed/non-fixed result cases
  are covered by the existing source-list tests.
- Verification after PIR fixed-source filtering: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added integer request priority to source-preview requests. Quota simulation
  processes earlier delivery dates first, then higher priorities within a date,
  using input position to break ties; candidate output remains in input order
  and echoes the priority. Added same-date quota-consumption coverage where the
  higher-priority later input receives the first quota item.
- Verification after priority-aware quota simulation: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added per-request `candidate_rank` to PIR and outline-source results. PIR
  ranks preserve either the stored quota ordering or the simulated ordering;
  outline ranks preserve fixed-source and preferred-vendor ordering. Tests
  verify rank sequence in both APIs and the per-request rank reset during
  quota simulation.
- Verification after explicit source candidate ranks: `npm.cmd test` passed;
  abaplint reported zero issues across 83 files, the transpiler wrote 703
  objects, and all 448 ABAP Unit methods passed. `git diff --check` passed.
- Added calendar-month (`MB`) lot sizing to component replenishment previews.
  Same-material/plant/unit shortages in a calendar month consolidate into one
  suggestion after projected receipts are applied against each shortage date.
  The result reports period bounds and grouped shortage count; the first
  shortage date drives the timing estimate. Added a leap-year month-boundary
  case with a receipt between two shortage dates and a second monthly group.
  The advisory limitations around planning-calendar settings and aggregated
  affected-order counts are recorded in `ANOMALIES.md`.
- Verification after monthly `MB` grouping: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 449 ABAP Unit methods passed. `git diff --check` passed.
- Added weekly (`WB`) component replenishment grouping, with caller-selectable
  `iv_week_start_weekday` from Monday=1 through Sunday=7 (default Monday).
  Date-specific projected receipts are netted before the weekly total is
  lot-sized. Tests cover a week crossing the year boundary, a between-demand
  receipt, a Sunday-start week, and invalid weekday input. SAP's planning
  calendar and full MRP behavior remain outside this preview; see `ANOMALIES.md`.
- Verification after weekly `WB` grouping: `npm.cmd test` passed; abaplint
  reported zero issues across 83 files, the transpiler wrote 703 objects, and
  all 450 ABAP Unit methods passed. `git diff --check` passed.
- Added planning-calendar (`PK`) replenishment grouping from resolved SAP
  `T439I` periods. The MARC policy read now returns `MRPPP`; the service bulk
  loads overlapping plant/calendar windows for shortage horizons, while
  caller-supplied periods can bypass that lookup. It validates period bounds and
  overlap, nets projected receipts before lot sizing, and keeps shortages
  without a matching period at date level. See `ANOMALIES.md` for the limits.
- Verification after `PK` grouping and `T439I` loading: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 452 ABAP Unit methods passed. `git diff --check` passed.
- Added `EQUP-MAXMG` to the quota arrangement repository read and candidate
  snapshot. Split previews now omit exhausted items and recalculate shares when
  a proposed share, including minimum-lot expansion, would reach the item
  maximum; below-threshold requests try the next ranked eligible item.
- Sequential quota assignment also omits exhausted items and skips a proposed
  base-unit request that would reach the maximum when `TMQ2` counts purchase
  requisitions. The previews use stored `QUMNG` snapshots and do not reserve
  quota; see `ANOMALIES.md` for scope limits and target-release checks.
- Verification after quota-maximum eligibility: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 453 ABAP Unit methods passed. `git diff --check` passed.
- Added optional `affected_production_orders` identities to component shortage
  rows and replenishment suggestions. `SUMMARIZE_COMPONENT_SHORTAGES` supplies
  distinct order IDs; monthly, weekly, and planning-calendar groups now union
  complete identity lists and count an order once across dates. Legacy or mixed
  inputs retain additive counts and omit partial order lists. Supplied lists
  reject blank IDs or a mismatch with `affected_order_count`.
- Verification after period-group affected-order deduplication:
  `npm.cmd test` passed; abaplint reported zero issues across 86 files, the
  transpiler wrote 707 objects, and all 453 ABAP Unit methods passed.
- Added `CANCEL_COMPONENT_ISSUE` to reverse a posted component issue by its
  material document, fiscal year, and optional item numbers. It shares the
  goods movement API instance used for issue posting and reuses cancellation's
  validation, commit, and rollback path. Tests cover selected-line routing and
  commit. This cancels complete document lines; partial-quantity returns are
  handled separately by `RETURN_COMPONENTS` and `RETURN_COMPONENTS_BULK`.
- Verification after component issue cancellation: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 454 ABAP Unit methods passed. `git diff --check` passed.
- Added `RETURN_COMPONENTS` and `RETURN_COMPONENTS_BULK` for partial returns
  against production component reservations. The service requires a live
  movement-type-261 component with a positive withdrawn balance, validates the
  requested return against `RESB-ENMNG` and reservation detail, and submits
  BAPI goods movement code 06 with `XSTOB` so SAP derives movement type 262.
  Unit coverage includes a partial return against a final-issue reservation
  and rejection above the withdrawn balance. A bulk case posts returns for
  two production orders in one material document.
- Verification after partial component returns: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 707 objects, and
  all 459 ABAP Unit methods passed. `git diff --check` passed.
- Updated `SIMULATE_SPLIT_QUOTA` for an only-once source whose ratio share
  exceeds `MAXLS`: it assigns one max-lot proposal, removes that source, and
  recalculates the remaining shares over eligible candidates. Below-threshold
  remainders continue through ranked fallback; the preview rejects when no
  alternate source can cover the request. Tests cover proportional
  redistribution, below-threshold fallback, and the no-alternate case.
- Verification after once-only max-lot redistribution: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 459 ABAP Unit methods passed. `git diff --check` passed.
- Extended `SIMULATE_SPLIT_QUOTA` so a non-once source that reaches `MAXLS`
  emits one max-lot proposal and recalculates shares for the remaining demand.
  Its simulated `QUMNG` is advanced for `MAXMG` checks; only-once sources still
  leave the candidate pool after one proposal. Tests cover repeated max lots,
  minimum-lot interaction, cumulative `MAXMG` eligibility, and exact demand
  conservation. SAP's split-quota documentation confirms that shares use quota
  values, while the lot-size documentation describes quota redetermination
  after maximum-sized proposals.
- Verification after iterative max-lot re-rating: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 707
  objects, and all 459 ABAP Unit methods passed. `git diff --check` passed.
- Added quota-item static rounding-profile support to `SIMULATE_SPLIT_QUOTA`.
  Candidate lookup exposes `EQUP-RDPRF`; the repository loads plant/profile
  levels from `RDPR`, and each proposal uses the threshold-based upward rounding
  procedure. Rounded quantities participate in `MAXMG` eligibility. The preview
  rejects a rounding result above `MAXLS`. Tests cover threshold examples,
  unchanged quantities below the lowest threshold, max-lot proposals, the
  `MAXMG` boundary, and incompatible profile/max-lot settings.
- Verification after quota-item rounding profiles: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 459 ABAP Unit methods passed. `git diff --check` passed.
- Added static material and caller rounding-profile support to
  `SUGGEST_COMP_REPLENISHMENT`. The policy read returns `MARC-RDPRF`, then
  loads threshold levels from `RDPR`; each modeled receipt is rounded after
  lot sizing, and totals, receipt counts, final receipt sizes, and rounding
  surplus reflect that result. Missing profile data and rounded quantities
  above maximum lot size are rejected. The requisition creator validates and
  emits fixed-lot receipts at the rounded final quantity while preserving the
  original fixed-lot setting. Tests cover caller and MARC profiles, fixed-lot
  and max-lot splits, PR item creation, and both rejection cases.
- Verification after replenishment rounding profiles: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 462 ABAP Unit methods passed. `git diff --check` passed.
- Added `get_suggestion_pir_candidates` to connect replenishment suggestions
  with the existing ranked standard PIR lookup. It maps each candidate back to
  the original suggestion index, passes quantity/date/purchasing-organization
  context through existing source filters and quota logic, and leaves source
  selection to the caller. Internal, special-source, covered, and
  unspecified-procurement rows are omitted; outline agreements remain separate.
  Tests cover filtered-index mapping, delivery-date propagation, quantity-limit
  evaluation, and the required purchasing organization.
- Verification after suggestion source options: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 464 ABAP Unit methods passed. `git diff --check` passed.
- Added `get_suggestion_outline_sources` to connect eligible replenishment
  suggestions with ranked outline-agreement candidates. It returns contract and
  scheduling-agreement options mapped to original suggestion indexes, passes
  the suggested quantity/unit and required date, and supports preferred-vendor,
  fixed-source, and MRP-relevant filtering. It leaves source selection to the
  caller. Tests cover filtered-index mapping, ranking, date propagation, and
  required purchasing organization.
- Verification after suggestion outline options: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 466 ABAP Unit methods passed. `git diff --check` passed.
- Added `get_suggestion_source_options` as a combined view over standard PIR and
  outline agreement suggestions. It returns the original suggestion index,
  source kind, local candidate rank, and the matching typed candidate; results
  are grouped by suggestion with PIR before outline options. Ranking remains
  local to each source kind and no source is assigned. A combined lookup test
  checks the two option variants and their source identities.
- Verification after combined suggestion sources: `npm.cmd test` passed;
  abaplint reported zero issues across 86 files, the transpiler wrote 708
  objects, and all 467 ABAP Unit methods passed. `git diff --check` passed.
- Added `apply_suggestion_source_option` to copy a selected PIR or agreement
  identity onto the indexed replenishment suggestion. It checks the candidate
  against the unchanged suggestion's material, plant, and date, clears the
  unselected source fields, and preserves the caller's original table. It does
  not reread customizing; SAP remains the final source validator at requisition
  creation. Tests cover both source mappings and mismatched-candidate rejection.
- Verification after applying source options: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 708 objects, and
  all 469 ABAP Unit methods passed. `git diff --check` passed.
- Added `apply_selected_source_options` for applying a set of reviewed source
  choices to multiple suggestions in one call. It returns a copied table,
  leaves unselected rows unchanged, reuses the single-option consistency
  checks, and rejects duplicate choices for one suggestion. Tests cover mixed
  PIR/agreement application and duplicate selection rejection.
- Verification after bulk source selection: `npm.cmd test` passed; abaplint
  reported zero issues across 86 files, the transpiler wrote 708 objects, and
  all 471 ABAP Unit methods passed. `git diff --check` passed.
- Added `create_from_selected_sources` to connect reviewed PIR/agreement
  options directly to the existing purchase-requisition workflow. It applies
  chosen options to a copied suggestion list, then runs the same validation,
  BAPI simulation/write, and commit behavior as `create_from_suggestions`.
  Unselected rows retain normal SAP source determination. An integration test
  submits both PIR and agreement identities through the fake API.
- Verification after selected-source requisition creation: `npm.cmd test`
  passed; abaplint reported zero issues across 86 files, the transpiler wrote
  708 objects, and all 472 ABAP Unit methods passed. `git diff --check` passed.
- Added `ZCL_STOCK_XFER_ORDER_SVC->CREATE_FROM_ALLOCATION` to build a single
  `UB` stock transport order for one selected source/target plant pair from
  dated unit-aware allocation rows. Items preserve source units and demand
  dates; short allocation is rejected by default, and BAPI test runs skip the
  commit. A BAPI adapter maps purchase-order items and schedule lines, with
  transaction commit/rollback handling. Tests cover source-pair selection,
  order mapping, test-run behavior, shortfall rejection, and rollback after
  create or commit errors.
- Verification after STO creation: `npm.cmd test` passed; abaplint reported
  zero issues across 90 files, the transpiler wrote 718 objects, and all 477
  ABAP Unit methods passed. `git diff --check` passed.
- Added `ISSUE_STOCK_TRANSPORT_ORDER` to post movement 351 against a selected
  STO item from the supplying plant/storage location, with optional batch and
  test-run support. The service uses BAPI movement code 04 and SAP's blank
  movement-indicator rule, then reuses the existing commit/rollback flow.
  Tests cover the BAPI payload, simulation, and rejection of incomplete issue
  data.
- Verification after STO goods issue support: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 480 ABAP Unit methods passed. `git diff --check` passed.
- Added the companion `RECEIVE_STOCK_TRANSPORT_ORDER` helper for 101 receipts
  against STO PO items. It maps indicator `B`, source item identity, quantity,
  units, and optional receiving plant/location/material/batch; test runs reuse
  the same no-commit behavior. Tests cover payload mapping, simulation, and
  incomplete-item rejection.
- Verification after STO goods receipt support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 483 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FROM_SOURCE_PLANTS` to turn the positive allocation rows for one
  receiving plant into one prevalidated STO request per supplying plant,
  preserving source priority. It attempts each independent order and returns
  per-source committed results plus an aggregate success flag; later suppliers
  still run if one BAPI creation fails. Tests cover grouping, no writes before
  full validation, and partial failure reporting.
- Verification after grouped STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 486 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FOR_ALL_PLANT_PAIRS` for dated unit-aware allocations spanning
  multiple receiving plants. It creates one request per positive source/target
  pair, applies a validated target-plant storage-location map, and prepares all
  requests before writing. Per-pair results preserve independent commit status.
  Tests cover pair grouping, target-location mapping, prevalidation, and partial
  BAPI failure reporting.
- Verification after all-pair STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 489 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FROM_BATCH_ALLOCATION` for unit-aware exact-batch allocations.
  Each selected request/material/batch becomes a separate STO item, preserving
  batch and source-unit quantity; the caller supplies the schedule date because
  this allocator does not produce one. The BAPI adapter maps `BATCH` and its
  item-X flag. Tests cover batch/unit/date mapping and reject missing batch
  identity before any write. Verify target-system behavior with the site's SAP
  release and batch configuration.
- Verification after batch-aware STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 491 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FOR_BATCH_PAIRS` to carry exact-batch allocations through the
  multi-target STO workflow. It prepares one batch-preserving `UB` order per
  source/target pair, applies validated receiving-location mappings, and keeps
  independent per-order commit results. Tests cover multi-target batch splits
  and reject a malformed later pair before any BAPI call.
- Verification after multi-pair batch STO creation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 493 ABAP Unit methods passed. `git diff --check` passed.
- Added `CREATE_FOR_FEFO_PAIRS` to build one STO per positive pair from dated,
  unit-aware FEFO output. It preserves selected batch/location splits, maps
  the issuing storage location to `SUPPL_STLOC`, uses each split's required
  date, and applies target-plant receiving-location mappings. Tests verify
  batch, both storage locations, source-unit quantity, per-split dates, and
  all-pair validation before the first write. SAP's STO availability check
  does not check batch stock when a batch is entered, so posting remains a
  later revalidation step.
- Verification after FEFO-aware STO creation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 495 ABAP Unit methods passed. `git diff --check` passed.
- Added `ISSUE_CREATED_STO` as a bridge from a committed STO result to the
  existing 351 goods-issue path. It maps PO item identity, selected batch,
  source plant/location, quantity, and caller-supplied unit ISO data, and
  rejects uncommitted/test-run orders or incomplete items before the BAPI.
  Tests cover payload preservation and missing commit/unit-ISO validation.
- Verification after the committed-STO issue bridge: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 498 ABAP Unit methods passed. `git diff --check` passed.
- Added `ISSUE_CREATED_STO_PAIRS` to dispatch multi-pair STO creation results.
  It prevalidates every successful, committed PO before issuing, skips failed
  creations, and continues across independent 351 transactions after a pair
  failure. Per-pair results preserve STO status, issue result, attempted state,
  and committed in-transit state. Tests cover multiple POs, a later issue
  failure, and no writes when a later PO item is malformed.
- Verification after multi-pair STO issue support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 502 ABAP Unit methods passed. `git diff --check` passed.
- Added `RECEIVE_ISSUED_STO` and `RECEIVE_ISSUED_STO_PAIRS` to continue the
  no-delivery STO lifecycle from committed in-transit issue results. They copy
  PO item, batch, receiving
  plant/location, quantity, and caller-mapped ISO unit into one 101 per PO.
  It prevalidates eligible pairs, skips pairs not in transit, preserves transit
  after failed or simulated receipts, and continues after an individual receipt
  failure. Tests cover single and multiple orders, payload mapping, partial failure,
  simulation, and prevalidation before the first BAPI call.
- Verification after multi-pair STO receipt support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 508 ABAP Unit methods passed. `git diff --check` passed.
- Added `CANCEL_ISSUED_STO` and `CANCEL_ISSUED_STO_PAIRS` to reverse committed
  351 issue material documents while their issue results still show in-transit
  stock. Every eligible PO document/year is validated before the first cancel;
  each cancellation commits independently, and a failed reversal leaves that
  pair in transit while later pairs continue. SAP's cancellation BAPI has no
  test-run mode, so SAP remains the authority for whether document history and
  current stock allow reversal. Tests cover single and multiple documents,
  independent failure, and all-document prevalidation.
- Verification after STO issue cancellation support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 512 ABAP Unit methods passed. `git diff --check` passed.
- Added opt-in fixed planned-order receipts through `PLAF-AUFFX`, while keeping
  the existing `iv_include_planned_receipts` flag scoped to unfixed orders.
  `iv_include_fixed_planned` returns fixed rows as `FIXED_PLAN_ORDER` and can
  be combined with the unfixed flag. The option flows through dated stock reads
  and allocations, production component previews, and component replenishment
  suggestions. Corrected the PLAF selection so the fixed-order branch is not
  suppressed by an unconditional blank-`AUFFX` filter. Tests cover both flag
  combinations, component supply netting, and invalid option values. Target SAP
  SQL and DDIC behavior still require validation; see `ANOMALIES.md`.
- Verification after fixed planned-order receipts: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 512 ABAP Unit methods passed. `git diff --check` passed.
- Added `CANCEL_RECEIVED_STO` and `CANCEL_RECEIVED_STO_PAIRS` to reverse a
  committed 101 receipt from its receipt result. Eligible documents are all
  validated before cancellation starts, each reversal commits independently,
  and successful reversals return the pair to in-transit state so callers can
  then reverse the original 351 issue. Failed receipts remain received while
  later documents continue. Tests cover single and multiple receipts, partial
  failure, and prevalidation before the first BAPI call.
- Verification after received-STO cancellation support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 515 ABAP Unit methods passed. `git diff --check` passed.
- Added `CANCEL_STO_RECEIPT_CHAIN` and `CANCEL_STO_RECEIPT_CHAIN_PAIRS` to
  reverse both committed goods movements for received STO pairs. They validate
  every eligible 101 and 351 document/year key before the first cancellation,
  reverse 101 first, and reverse 351 only when the receipt reversal succeeds.
  Results distinguish receipt reversal, issue reversal, in-transit state, and
  complete movement reversal. Tests cover the successful chain, failures at
  both reversal steps with later-pair processing, and all-pair prevalidation.
- Verification after STO receipt-chain cancellation support: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 519 ABAP Unit methods passed. `git diff --check` passed.
- Added `MARK_STO_FOR_DELETION` and `MARK_STO_PAIRS_FOR_DELETION` to set the
  item deletion indicator on eligible items from committed STO creation results.
  The pair workflow prevalidates eligible item identities, skips failed,
  simulated, or uncommitted orders, commits each PO independently, and
  continues after item/API/commit failures. Local tests cover success, skip,
  prevalidation, independent failure, and rollback behavior. SAP retains
  eligibility checks and this operation marks items logically rather than
  physically deleting a PO; see `ANOMALIES.md`.
- Verification after STO deletion-indicator support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 524 ABAP Unit methods passed.
- Added `MARK_STO_DELIVERY_COMPLETE` and `MARK_STO_PAIRS_DELIV_COMPLETE` to set
  the purchase-order delivery-completed indicator on submitted items from
  committed STO results. SAP can close the remaining open PO quantity even
  after partial receipt, so this method represents a business decision that no
  more receipt is expected; it does not post stock. Tests cover single and
  multi-pair calls, independent failures, prevalidation, skipping uncommitted
  orders, and rollback after a failed commit. SAP-side BAPI behavior, including
  split valuation cases, remains a target-system check documented in
  `ANOMALIES.md`.
- Verification after STO delivery-completion support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 529 ABAP Unit methods passed.
- Added caller-supplied `it_demand_priorities` to multi-sales-order dated
  previews and reservations. Priorities key sales document, item, and schedule
  line; higher values win only within the same material/plant/date, while
  earlier dates and stable input-order ties remain unchanged. Invalid, duplicate,
  foreign-order, or unknown item/schedule keys fail before physical allocation.
  Each returned sales-unit allocation echoes the applied priority. Tests cover
  equal-date prioritization, reservation propagation, and invalid-order-key
  rejection. ATP remains cumulative by date and is not reordered by local
  priority; see `ANOMALIES.md`.
- Verification after multi-order demand priority: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 532 ABAP Unit methods passed.
- Aligned sequential `BAPI_RESERVATION_CREATE1` calls with same-date caller
  priorities in `reserve_orders_by_date`; the API adapter processes reservations
  one at a time, so the higher-priority requests are now sent first. Added a
  regression test that verifies the actual request order when both demands fit.
- Verification after priority-aware reservation sequencing: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 533 ABAP Unit methods passed. `git diff --check` passed.
- Added optional `it_item_priorities` to single-order previews and reservations.
  Same-date item/schedule lines now use caller priority after requested date;
  earlier dates still win, omitted values default to zero, and ties retain the
  order's source sequence. Invalid and duplicate keys fail before stock
  allocation. Sales-unit results echo the applied priority, and reservation
  BAPI calls follow the same order. A test caught and fixed source-index capture
  after priority-map lookup. ATP remains cumulative by date; see `ANOMALIES.md`.
- Verification after single-order item priority: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 536 ABAP Unit methods passed.
- Extended sales-order `atp_checks` with the caller priority for each item or
  schedule line in both single-order and multi-order previews. The SAP request
  still aggregates demand by date, and confirmation quantities remain shared at
  that date level. Added checks that both APIs echo priority without changing
  the cumulative ATP quantity.
- Verification after ATP priority diagnostics: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 537 ABAP Unit methods passed.
- Added optional `iv_check_atp` and `iv_atp_check_rule` to `reserve_order` and
  returned its per-line ATP diagnostics in the reservation result. The check
  uses the same grouped logic as `preview_order`, validates dates and rule
  before stock reads, and remains diagnostic; the reservation BAPI performs its
  own ATP check. Extended coverage for priority propagation and missing-rule
  rejection.
- Verification after single-order reservation ATP diagnostics: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 537 ABAP Unit methods passed.
- Added `iv_require_atp_confirmation` to single-order and multi-order
  reservations. It requires `iv_check_atp`, compares each cumulative date
  confirmation to its demand, and returns the ATP diagnostics without calling
  the reservation API if any date is short. The reservation BAPI still performs
  its own ATP check. Tests cover short and full confirmations in both flows and
  reject the gate when ATP checking is omitted, and reject invalid boolean
  values before repository reads.
- Verification after ATP-gated reservations: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 718 objects, and
  all 541 ABAP Unit methods passed.
- Extended the ATP precheck and strict confirmation gate to cost-center
  reservations. The gate compares the confirmed base quantity with the full
  requested base quantity and blocks the reservation API on a short response;
  tests cover short and full confirmation, missing ATP enablement, missing
  check rules, and invalid gate values.
- Latest verification after cost-center ATP-gated reservations: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 544 ABAP Unit methods passed.
- Passed required dates to the shared ATP confirmation splitter from dated
  stock, cross-plant/FEFO, sales-order, and cost-center flows. Confirmation
  lines after the demand date, plus undated lines, remain in the raw SAP result
  but no longer count as confirmed for that date. Added strict-gate tests for
  later confirmations and updated dated fixtures.
- Latest verification after date-scoped ATP confirmation splits:
  `npm.cmd test` passed; abaplint reported zero issues across 90 files, the
  transpiler wrote 718 objects, and all 547 ABAP Unit methods passed.
- Added `CREATE_FROM_ATP_SOURCE_PLANTS`, which accepts dated plant-allocation
  ATP results and prevalidates a matching full confirmation for every positive
  source split before the first STO BAPI call. Tests cover successful multi-
  supplier creation and short-confirmation rejection with zero writes.
- Latest verification after ATP-gated STO creation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 549 ABAP Unit methods passed.
- Added opt-in `iv_atomic` mode to multi-source STO creation, including the ATP-
  gated entry point. It creates all prepared supplier orders before one shared
  commit, rolls back and stops on create or commit failure, and marks all
  returned order results uncommitted when the group fails. Added tests for the
  single shared commit, create failure rollback, and commit failure rollback.
- Latest verification after atomic multi-source STO creation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 552 ABAP Unit methods passed.
- Extended `iv_atomic` to all-pair, batch-pair, and FEFO-pair STO creation using
  a shared executor. Pair test coverage now checks one commit on success and
  group rollback on both create and commit failures.
- Latest verification after atomic multi-pair STO creation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 554 ABAP Unit methods passed.
- Added `CREATE_FOR_ATP_PLANT_PAIRS` to prevalidate full, relevant date ATP
  confirmations for every positive source/target split before creating orders
  across receiving plants. Added successful atomic creation and short-check
  rejection coverage.
- Latest verification after ATP-gated multi-pair STO creation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 556 ABAP Unit methods passed.
- Added `CREATE_FOR_ATP_FEFO_PAIRS`, which accepts FEFO plant-allocation ATP
  output, validates positive source/date totals before writes, and preserves
  batch/location items through the FEFO pair creator. Added success and short-
  confirmation tests using atomic commit mode.
- Latest verification after ATP-gated FEFO STO creation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 558 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `MARK_STO_PAIRS_FOR_DELETION`. Atomic mode refuses
  mixed or ineligible input groups before writing, stages all item changes
  before one commit, and clears every deletion result after a change or commit
  failure. Added shared-commit and rollback coverage.
- Latest verification after atomic STO pair deletion: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 562 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `MARK_STO_PAIRS_DELIV_COMPLETE`. Atomic mode
  rejects mixed or ineligible groups before writes, stages each delivery
  completion before one shared commit, and clears completion results after a
  change or commit failure. Added success, rollback, commit-failure, and
  ineligible-input coverage.
- Latest verification after atomic STO pair delivery completion: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 566 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `ISSUE_CREATED_STO_PAIRS`. Atomic mode requires
  eligible committed STOs before writes, stages every 351 movement before a
  shared commit, and reports `is_in_transit` only after that commit. A movement
  or commit failure clears the group's uncommitted material document IDs.
- Added opt-in `iv_atomic` to `RECEIVE_ISSUED_STO_PAIRS`. Atomic mode requires
  every pair to remain in transit, stages all 101 receipts in one LUW, and
  clears transit only after the shared commit. Failures roll back the group
  while preserving the in-transit state.
- Latest verification after atomic pair issue and receipt: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  718 objects, and all 574 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `CANCEL_ISSUED_STO_PAIRS`. Atomic mode requires
  every supplied issue to remain in transit, stages all 352 reversals in one
  LUW, and clears transit only after a shared commit. A reversal or commit
  failure rolls the group back and clears uncommitted reversal document IDs.
- Latest verification after atomic issue cancellation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 578 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `CANCEL_RECEIVED_STO_PAIRS`. Atomic mode requires
  every supplied receipt to remain received, stages all 102 reversals in one
  LUW, and restores transit only after the group commits. A reversal or commit
  failure rolls back the group and preserves received status.
- Latest verification after atomic receipt cancellation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 718
  objects, and all 582 ABAP Unit methods passed.
- Added opt-in `iv_atomic` to `CANCEL_STO_RECEIPT_CHAIN` and
  `CANCEL_STO_RECEIPT_CHAIN_PAIRS`. Atomic mode requires every pair to be
  received, stages each 101 reversal before its matching 351 reversal, then
  commits the full group once. A cancellation or commit failure rolls back the
  group and restores received state. Tests cover the single-pair and multi-pair
  entry points, one shared commit, failure at both reversal stages, commit
  failure, and rejection before writes when a pair is not received.
  Target-release rollback behavior is documented in `ANOMALIES.md`.
- Latest verification after atomic receipt-chain cancellation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 588 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `RETRY_STO_CHAIN_ISSUE` and `RETRY_STO_CHAIN_ISSUE_PAIRS` to retry a
  pending 351 reversal from prior receipt-chain cancellation output. The retry
  validates the prior receipt reversal, preserves already completed pairs,
  leaves rows with a failed 101 reversal untouched, and can atomically commit
  the outstanding issue reversals. Tests cover recovery after a failed 351,
  grouped retry, preservation of completed rows, API failure rollback, commit
  failure, and receipt-pending rejection in atomic mode. The retry scope and
  SAP state caveat are recorded in `ANOMALIES.md`.
- Latest verification after STO issue-reversal retry support: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 594 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `RETRY_STO_CHAIN_RECEIPT` and `RETRY_STO_CHAIN_RECEIPT_PAIRS` to retry
  101 reversals for pairs still received after a failed cancellation or atomic
  chain rollback. The methods preserve completed rows and 351-pending rows,
  restore in-transit status after a successful 101 retry, and keep the
  aggregate result incomplete until the issue reversal is also complete.
  Atomic mode groups the pending 101 retries in one LUW. Tests cover recovery
  through both retry stages, group-abort recovery, shared commit, rollback, and
  commit failure; target SAP status and rollback limits are recorded in
  `ANOMALIES.md`.
- Latest verification after STO receipt-reversal retry support: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 599 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `RETRY_STO_CHAIN` and `RETRY_STO_CHAIN_PAIRS` to resume mixed
  receipt-chain cancellation results. Non-atomic recovery commits each
  outstanding stage independently; atomic recovery stages all remaining 101
  and 351 reversals in one LUW while preserving the input states on failure.
  Added tests for mixed pending stages, completed-row preservation, atomic
  rollback, and the single-pair wrapper. SAP eligibility and rollback caveats
  are recorded in `ANOMALIES.md`.
- Latest verification after composite STO chain retry: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 604 ABAP Unit methods passed, and `git diff --check`
  passed.
- Hardened plant, storage-location, and batch stock-status reads against blank
  material or plant keys. The service now raises `ZCX_INVALID_STOCK_REQUEST`
  before repository access, avoiding broad database reads from incomplete
  selection keys. Added no-read regression coverage and documented the boundary.
- Latest verification after stock-status key validation: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 605 ABAP Unit methods passed, and `git diff --check`
  passed.
- Extended the stock-read key guard to `GET_UNRESTRICTED_STOCK`, and reject
  invalid `iv_protect_safety_stock` values before the repository read. Added
  regression coverage for blank material, blank plant, and invalid flags.
- Latest verification after unrestricted-stock key validation: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 606 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added key validation to the sales-order reservation read methods. Single
  reads reject a blank sales document; bulk reads reject blank entries and
  return immediately for an empty input list. Added no-read coverage for each
  case and updated the stock-read assumptions.
- Latest verification after sales-order reservation key validation:
  `npm.cmd test` passed; abaplint reported zero issues across 90 files, the
  transpiler wrote 1090 output files, all 607 ABAP Unit methods passed, and
  `git diff --check` passed.
- Added `GET_STOCK_STATUS_BULK` to read keyed material/plant status requests in
  one repository call. The MARD, RESB, and MARC rows are selected in batches,
  aggregated by material/plant, and returned in request order. The service
  rejects blank fields, duplicate request IDs, and malformed repository result
  sets; empty input returns without a read. Tests cover input validation,
  output ordering, one repository call, and mismatched or missing repository
  results. SQL execution in SAP remains to be checked as recorded in
  `ANOMALIES.md`.
- Latest verification after bulk stock-status reads: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 610 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_LOCATION_STOCK_STATUS_BULK` for keyed material/plant requests. It
  batches MARD and RESB reads, aggregates by material, plant, and storage
  location, then applies the existing location reservation calculator. Results
  retain zero-available MARD locations and request order. Blank fields,
  duplicate request IDs, malformed repository results, and empty input follow
  the same validation contract as the plant-level bulk read. Both bulk RESB
  selections include reservation number and item so identical quantity rows
  stay distinct under `FOR ALL ENTRIES`; the target SQL behavior remains listed
  in `ANOMALIES.md`.
- Latest verification after bulk location stock status: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 612 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_BATCH_STOCK_STATUS_BULK` for multiple keyed material/plant
  requests. It batches MCHB stock, MCHA/MCH1 expiration-date, and RESB
  reservation reads, then reuses the batch reservation calculator. Results
  preserve request and location/batch order, retain zero-available MCHB rows,
  and resolve plant-specific expiration dates before global batch dates. The
  service rejects blank keys, duplicate request IDs, and malformed repository
  results; empty input returns without a read. Local SQL validation limits are
  in `ANOMALIES.md`.
- Latest verification after bulk batch stock status: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 614 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_FEFO_BATCH_STATUS_BULK` with a per-request as-of date and minimum
  shelf-life window. It validates the full input set before reading, performs
  one bulk batch-status read, and filters and sorts each response with the
  existing FEFO eligibility helper. Tests cover request-specific windows,
  dated-first ordering, undated batches at a zero-day minimum, zero-available
  batches, invalid inputs, and one repository call. SAP batch determination
  and ATP remain outside this local estimate, as recorded in `ANOMALIES.md`.
- Latest verification after bulk FEFO batch status: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 616 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_FEFO_BATCH_STATUS_BULK_UOM`. Each request supplies its material
  unit; the service returns eligible batch rows with quantities in that unit
  and both base/request unit codes. It caches conversion ratios by
  material/unit, validates all requests and ratios before the single batch
  stock read, and retains the same per-request FEFO filtering and ordering.
  Tests cover repeated ratio reuse, quantity conversion, different shelf-life
  windows, unit errors, and one stock read. Target-system ratio/precision and
  ATP limitations are recorded in `ANOMALIES.md`.
- Latest verification after bulk FEFO unit conversion: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, all 618 ABAP Unit methods passed, and `git diff --check` passed.
- Added `GET_STOCK_STATUS_BULK_IN_UNIT` for keyed material/plant/unit requests.
  It validates the full request set, caches ratios by material/unit, reads
  plant statuses in one bulk call, and converts all stock, reservation,
  availability, safety-stock, quality, and blocked quantities to the requested
  units. Tests cover all converted fields, ratio reuse, input ordering, invalid
  and unknown units, empty input, and one stock read. SAP ratio and rounding
  assumptions are documented in `ANOMALIES.md`.
- Latest verification after bulk stock status unit conversion: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, all 620 ABAP Unit methods passed, and `git diff --check`
  passed.
- Added `GET_LOCATION_STOCK_BULK_UOM` for keyed material/plant/unit requests.
  It validates inputs and conversion ratios before reading, caches ratios by
  material/unit, performs one bulk location-status read, and converts
  unrestricted, available, quality-inspection, and blocked quantities while
  preserving zero-available locations. Tests cover request order, all converted
  fields, zero availability, repeated ratio reuse, invalid and unknown units,
  empty input, and one stock read. Target-system ratio and rounding assumptions
  are documented in `ANOMALIES.md`.
- Added `GET_BATCH_STOCK_BULK_UOM` for keyed batch-status requests with a
  requested material unit. It validates all keys and ratios before one bulk
  batch read, then converts unrestricted and available quantities while
  preserving batch, location, and expiration details, including zero-available
  batches. Tests cover request order, quantity conversion, ratio reuse, invalid
  and unknown units, empty input, and one stock read. Target-system ratio and
  rounding assumptions are documented in `ANOMALIES.md`.
- Added `GET_ORDER_RES_BULK_UOM` for keyed sales-document/material/plant/unit
  requests. It validates all keys and conversion ratios before reading,
  deduplicates sales documents for one bulk reservation read, and converts
  matching open reservation quantities while preserving request order and line
  details. Tests cover conversion, ratio reuse, ordering, invalid and unknown
  units, empty input, and one read. The assumption that repository reservation
  quantities are in the material base unit is recorded in `ANOMALIES.md` for
  target-system confirmation.
- Added `GET_PROJECTED_RECEIPTS_IN_UNIT` to return PO, STO, production,
  requisition, planned-order, and scheduling-agreement receipt rows in a
  requested material unit. It preserves source identity, dates, and both unit
  codes, validates all source flags and the conversion ratio before reading,
  and reuses the existing projection query. Tests cover converted quantities,
  source metadata, invalid flags, unknown units, and one repository read.
  Target-system conversion and rounding assumptions are in `ANOMALIES.md`.
- Added `GET_PROJECTED_RECEIPTS_BULK` for keyed material/plant/deadline
  requests with shared receipt-source flags. It preserves request order and
  returns each deadline's matching receipt rows. Repeated material/plant pairs
  share one projection through their latest deadline; empty requests and
  requests with no enabled source types perform no repository read. Tests cover
  per-deadline filtering, repeated-pair grouping, distinct-pair reads, invalid
  keys and flags, empty input, and no-source behavior. Existing SQL limitations
  are documented in `ANOMALIES.md`.
- Added `GET_PROJ_RECEIPTS_BULK_UOM` with per-request material units. It
  validates request keys and all conversion ratios before calling the bulk
  projection service, then converts quantities while preserving deadline
  filtering, source identity, request order, and base/request unit codes. Ratio
  caching is by material/unit and projection grouping remains by material/plant.
  Tests cover quantity conversion, per-deadline filtering, ratio reuse, invalid
  flags and units, duplicate IDs, and no-read cases. Target-system conversion
  assumptions are in `ANOMALIES.md`.
- Added `GET_PROJ_RECEIPTS_OPTS_BULK` with receipt-source flags on each
  material/plant/deadline request. It unions source types per material/plant,
  queries through the latest deadline, and filters each result by that row's
  own date and source options. Requests with no enabled sources skip repository
  reads, including when other request groups do have sources. Tests cover
  different source types, per-request deadline filtering, grouped reads,
  disabled source groups, duplicate IDs, invalid dates/options, and empty input.
  Existing projection SQL limitations remain documented in `ANOMALIES.md`.
- Added `GET_PROJ_RECEIPTS_OPTS_UOM` to combine per-request receipt-source
  choices and requested units. It validates all request keys, source flags,
  and unit ratios before calling the grouped projection service; results retain
  per-request filtering, source details, order, and both unit codes. Tests cover
  different source types, unit conversion, ratio reuse, malformed options,
  duplicate IDs, missing and unknown units, and empty input. Target-system UOM
  assumptions are recorded in `ANOMALIES.md`.
- Latest verification after per-request source selection with UOM:
  `npm.cmd test` passed; abaplint reported zero issues across 90 files, the
  transpiler wrote 1090 output files, all 636 ABAP Unit methods passed, and
  `git diff --check` passed.
## Latest progress

- Added `GET_STOCK_IN_TRANSFER_BULK` with request IDs and optional storage
  locations. It validates required keys and duplicate IDs before repository
  access, returns rows in request order, and lets each request aggregate either
  one location or the full plant. The repository reads MARC and MARD rows in
  bulk and applies each request's location filter. Tests cover mixed location
  aggregation, result ordering, blank keys, duplicate IDs, mismatched or
  incomplete repository output, and empty input. SAP SQL checks are documented
  in `ANOMALIES.md`.
- Added `GET_STOCK_IN_TRANSFER_BULK_UOM` for requests with material-specific
  units. It validates request IDs and conversion ratios before stock access,
  caches repeated material/unit ratios, and returns both base and converted
  quantities in request order. Tests cover conversion, ratio reuse, invalid
  units, duplicate IDs, and empty input. Target-system UOM assumptions are in
  `ANOMALIES.md`.
- Verification after the aggregate transfer bulk additions: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, ABAP Unit passed, and `git diff --check` passed.
- Added `GET_TRANSFER_BATCHES_BULK` with keyed material/plant
  requests and nested batch results. The repository reads matching `MCHB`
  rows once, and the service preserves request order while sorting each result
  by storage location and batch. Tests cover grouping, ordering, duplicate IDs,
  mismatched repository rows, and empty input; SAP query validation is noted in
  `ANOMALIES.md`.
- Added `GET_TRANSFER_BATCHES_BULK_UOM` for per-request units. It validates the
  full request set before UOM reads, caches repeated material/unit ratios, and
  returns base and converted batch quantities with the sorted batch details.
  Tests cover conversion, cache reuse, invalid units, duplicate IDs, and empty
  input; target-system conversion assumptions are in `ANOMALIES.md`.
- Verification after the bulk batch transfer additions: `npm.cmd test`
  passed; abaplint reported zero issues across 90 files, the transpiler wrote
  1090 output files, ABAP Unit passed, and `git diff --check` passed.
- Added purchasing-unit support to replenishment requisition items. A selected
  PIR source carries its EINA order-unit ratio into every split lot; callers can
  also provide a per-suggestion purchasing unit and ratio directly. The service
  validates ratios before BAPI access and returns converted item quantities
  with the submitted unit. Tests cover selected-source ratio propagation,
  split-lot conversion, direct unit controls, and invalid ratios; SAP mapping
  assumptions are in `ANOMALIES.md`.
- Verification after purchasing-unit support: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, ABAP Unit passed, and `git diff --check` passed.
- Added `read_orders` to the sales order service. It validates all document
  numbers and duplicates before reading, preserves caller order, and returns
  each API result independently. Tests cover ordering, invalid lists, and empty
  input; each document still uses the standard detail BAPI, as recorded in
  `ANOMALIES.md`.
- Latest verification after the sales order multi read: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1090
  output files, ABAP Unit passed, and `git diff --check` passed.
- Added `change_orders_atomic` for multiple sales orders. It validates all
  documents and item lists before BAPI access, preserves one write result per
  order, and performs a single commit or group rollback; test runs skip the
  commit. Tests cover success, simulated execution, change and commit failures,
  and duplicate-key rejection. Validate the SAP LUW boundary in the target
  release as recorded in `ANOMALIES.md`.
- Added `create_orders_atomic` with full header and item prevalidation, one
  result per created order, and a single commit or group rollback. Non-test
  creates without a returned document number fail the group. Tests cover
  success, test runs, BAPI errors, missing document numbers, and rejection
  before any create call; target SAP LUW assumptions are in `ANOMALIES.md`.
- Shared atomic commit handling between multi-create and multi-change calls.
  Single writes now reject invalid test-run flags, detect error-severity commit
  messages, and return a clear error when a write fails without a message.
  Latest validation: `npm.cmd test` passed with zero abaplint issues, 1,090
  transpiler outputs, ABAP Unit success, and `git diff --check` passed.
- Added `preview_cost_center_demands` for multi-line cost-center planning. It
  validates all request IDs and fields before conversion or stock reads,
  converts per-material units, shares each material/plant balance in caller
  order, and returns per-request allocations and shortfalls without creating
  reservations. Tests cover conversion, shared stock, order preservation,
  duplicate IDs, and empty input. See `ANOMALIES.md` for plant-level scope.
- Wired the cost center service's configured UOM converter into its stock
  allocator, keeping conversions on the injected repository in tests and
  integrations. Verification after the bulk preview: `npm.cmd test` passed;
  abaplint reported zero issues across 90 files, the transpiler wrote 1,090
  outputs, ABAP Unit completed successfully, and `git diff --check` passed.
- Added `preview_cost_center_by_date` with shared stock across dated demands,
  material-specific units, same-date priority, optional projected receipt
  sources, and safety-stock protection. It returns results in input order and
  performs no reservation writes. Tests cover date before priority, priority
  ties, unit conversion, duplicate IDs, invalid dates and flags, and empty
  input. SAP query and unit assumptions are in `ANOMALIES.md`.
- Added `preview_cost_center_locations` with per-demand hard locations or
  preferred-location fallback. It shares location balances across requests,
  returns converted location splits, validates the full request list before
  reads, and does not create reservations. Tests cover preferred-first splits,
  alternative-unit quantities, duplicate IDs, invalid flags, and empty input.
  `npm.cmd test` passed with zero abaplint issues, 1,090 transpiler outputs,
  ABAP Unit success, and `git diff --check` passed; SAP query limits are in
  `ANOMALIES.md`.
- Added `preview_cost_center_batches` for explicit batch demand lines. It
  shares the selected batch/location balances in caller order, supports
  preferred-location fallback without batch substitution, returns expiration
  and unit-converted splits, and validates all rows before stock reads. Tests
  cover split conversion, duplicate IDs, missing batches, invalid flags, and
  empty input. A stocked alternate batch does not satisfy a selected-batch
  shortfall. Verification: `npm.cmd test` passed with zero abaplint issues,
  1,090 transpiler outputs, ABAP Unit success, and `git diff --check` passed;
  target-system batch query assumptions are in `ANOMALIES.md`.
- Added `preview_cost_center_fefo` for multiple cost center demands. It shares
  batch balances in caller order, applies one as-of date and minimum shelf life,
  preserves preferred-location fallback, and returns converted per-batch
  splits. Tests cover date eligibility, shared stock shortfalls, preferred
  locations, unit conversion, invalid input, and empty input. Target-system
  query and batch-determination limits are recorded in `ANOMALIES.md`.
- Extended `preview_cost_center_by_date` with optional cumulative ATP
  diagnostics. Requests are checked by material, plant, base unit, and required
  date; local dated allocations remain separate and results stay in caller
  order. Tests cover grouped cumulative quantities, unit conversion, invalid
  ATP options, and zero reservation writes. Target ATP behavior is recorded in
  `ANOMALIES.md`. Latest combined validation: `npm.cmd test` passed; abaplint
  reported zero issues across 90 files, the transpiler wrote 1,090 outputs,
  ABAP Unit completed successfully, and `git diff --check` passed.
- Added `reserve_cost_centers_atomic` for all-or-nothing multi-demand writes. It
  validates the full list, preallocates shared location stock, requires full
  quantity coverage, creates one reservation per demand, and commits once or
  rolls back on an API or commit failure. Tests cover shared location splits,
  stock shortfall before writes, create and commit rollback, simulation, invalid
  input, and empty input. Confirm SAP LUW behavior as recorded in
  `ANOMALIES.md`. Validation passed: abaplint reported zero issues across 90
  files, the transpiler wrote 1,090 outputs, and ABAP Unit completed
  successfully. Extended the same method to support groups using either an
  explicit batch on every demand or automatic FEFO selection. Tests cover
  shared batch balances, alternate-batch exclusion, expiry filtering, and batch
  fields in reservation items; mixed batch strategies are rejected before
  stock reads. The full suite passed again after this extension.
- Added optional cumulative ATP diagnostics and an all-or-nothing confirmation
  gate to `reserve_cost_centers_atomic`. Demand is grouped by material, plant,
  base unit, and required date; each check receives the cumulative quantity
  through that date. The gate returns before any reservation API call if any
  group is short. Tests cover same-date aggregation, later-date cumulative
  demand, gate rejection, and invalid ATP options. `npm.cmd test` passed with
  zero abaplint issues across 90 files, 1,090 transpiler outputs, and ABAP Unit
  success. Target availability rule and confirmation behavior are recorded in
  `ANOMALIES.md`.
- Atomic reservation creates now reject duplicate reservation numbers returned
  for distinct demands and roll the group back. Reservation numbers are cleared
  from every item after create or commit rollback. Tests cover duplicate API
  results and cleared numbers after commit failure. Final `npm.cmd test` passed:
  abaplint reported zero issues across 90 files, the transpiler wrote 1,090
  outputs, and ABAP Unit completed successfully; `git diff --check` passed.
- Added `read_reservations` to the reservation inquiry service. It validates all
  reservation numbers before any reads, rejects blanks and duplicates, preserves
  caller order, and returns each document's existing validation result. Tests
  cover ordered reads, mixed success/failure, invalid lists, and empty input; SAP
  detail-field limits remain documented in `ANOMALIES.md`. `npm.cmd test` passed
  with zero abaplint issues across 90 files, 1,090 transpiler outputs, and ABAP
  Unit success; `git diff --check` passed.
- Refactored reservation goods issue to validate every selected item and the
  test-run flag before inquiry, then read distinct reservation documents through
  `read_reservations` in first-seen order. A read failure prevents the single
  goods movement call. Tests cover invalid late input with zero reads and issue
  items from multiple reservation documents in caller order. `npm.cmd test`
  passed with zero abaplint issues across 90 files, 1,090 transpiler outputs,
  and ABAP Unit success.
- Reservation detail reads now reject repeated item numbers within one document
  and clear all items on a malformed response. Added a regression test for a
  duplicate item number; `npm.cmd test` passed with zero abaplint issues across
  90 files, 1,090 transpiler outputs, and ABAP Unit success.
- Component stock and ATP previews now exclude the selected components' own
  reservation keys from dated `RESB` deductions before allocating their open
  quantities. Other active reservations remain netted, preventing the selected
  components from being counted twice. Added a fake-repository regression case
  for restoring the component's reservation quantity and allocating it once.
  `npm.cmd test` passed: abaplint reported zero issues across 90 files, the
  transpiler wrote 1,090 outputs, and ABAP Unit completed successfully.
- Added `cancel_material_documents_bulk` for validated multi-document reversals.
  It returns per-document attempt and cancellation state, supports item-specific
  cancellation and posting dates, and offers independent commits or one atomic
  LUW. Tests cover atomic success, rollback after an API and commit failure,
  continued processing in independent mode, and prevalidation before any BAPI
  call. Verify the target SAP release's multi-call LUW behavior as recorded in
  `ANOMALIES.md`. `npm.cmd test` passed: abaplint reported zero issues across 90
  files, the transpiler wrote 1,090 outputs, and ABAP Unit completed
  successfully.
- Exposed the bulk material-document reversal through
  `cancel_component_issues_bulk`, preserving the production-component service
  entry point while carrying item selections, posting dates, per-document
  results, and atomic mode through to the shared cancellation implementation.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,090
  transpiler outputs, and ABAP Unit success.
- Added `mark_pr_items_deleted` to flag selected replenishment requisition items
  through `BAPI_PR_CHANGE`, including test-run support and shared commit/rollback
  handling. The service validates the complete item list before the BAPI call;
  local DDIC stubs now include the deletion value and update flag. SAP item
  eligibility and exact target-release mapping remain recorded in
  `ANOMALIES.md`.
- Added two multi-requisition deletion modes. `delete_pr_items_atomic` validates
  the full group, commits once on success, and rolls back the group after the
  first BAPI error; `delete_pr_items_bulk` commits or rolls back each request
  and continues through later requisitions. Both preserve per-document
  messages, item-level message mapping, and test-run behavior. Requisition
  validation is shared across both modes. PR writes now also treat error-level
  commit messages as failure, even when the adapter success flag is true.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,090
  transpiler outputs, and ABAP Unit success; target SAP LUW behavior is
  documented in `ANOMALIES.md`.
- Added prepared-item multi-create methods. `create_requisitions_atomic`
  validates every document before calling `BAPI_PR_CREATE`, commits once, and
  rolls back and clears returned document numbers after any create or commit
  failure. `create_requisitions_bulk` commits or rolls back each requisition
  independently and keeps processing after errors. Test runs skip commits, and
  result rows preserve SAP messages and item mappings. Shared PR write handling
  now reports an error-level fallback when an adapter indicates a failed write
  or commit without an error message. Tests cover prevalidation, required live
  document numbers, item-level message mapping, group rollback, independent
  continuation, simulation, and commit-message inconsistencies. `npm.cmd test`
  passed with zero abaplint issues across 90 files, 1,090 transpiler outputs,
  and ABAP Unit success; `git diff --check` passed. Target SAP transaction
  behavior is documented in `ANOMALIES.md`.
- Expanded `update_pr_items` and `update_pr_items_bulk` to change purchasing
  group, purchasing organization, fixed vendor, info record, and outline
  agreement references alongside quantity and delivery date. Each selected
  field receives its `PRITEMX` update flag; a selected blank source reference
  can clear that value, while unselected values must remain initial. Mapper and
  service tests cover all fields, invalid flags, payload propagation, bulk
  modes, and transaction failures. `npm.cmd test` passed: abaplint reported
  zero issues across 90 files, the transpiler wrote 1,090 outputs, and ABAP Unit
  completed successfully. Live SAP field eligibility and clearing behavior
  remain release-dependent as documented in `ANOMALIES.md`.
- Added `read_pr_items` through `BAPI_PR_GETDETAIL` and the validated
  `read_pr_items_bulk` wrapper. Item results include material, stock location,
  quantity/unit, delivery date, buyer and source assignments, release and
  processing state, ordered quantity, follow-on PO keys, and fixed/closed
  indicators. Bulk reads preserve order, prevalidate all keys, return one row
  per requisition, and continue after failures; empty input makes no call. The
  `BAPIMEREQITEM` local stub models only the fields used here. `npm.cmd test`
  passed: abaplint reported zero issues across 90 files, the transpiler wrote
  1,091 outputs, and ABAP Unit completed successfully. Target-system BAPI fields,
  permissions, and result behavior remain documented in `ANOMALIES.md`.
- Added `delete_all_pr_items`, which reads a requisition and submits every item
  without a deletion indicator through the existing test-run and commit path.
  Read failures prevent writes; already-deleted requisitions return success
  without a change call. Tests cover active/deleted item selection, no-op
  behavior, read failure, and the successful commit path. `npm.cmd test` passed:
  abaplint reported zero issues across 90 files, the transpiler wrote 1,091
  outputs, and ABAP Unit completed successfully. The read/change race and target
  deletion rules are recorded in `ANOMALIES.md`.
- Added `delete_all_pr_items_bulk` for validated multi-requisition deletion by
  document number. Each requisition is read and processed independently; later
  requests continue after a read, change, or commit failure, with per-row
  messages and commit state. Tests cover continuation after read failure and
  validation before any read. `npm.cmd test` passed: abaplint reported zero
  issues across 90 files, the transpiler wrote 1,091 outputs, and ABAP Unit
  completed successfully. SAP read/change race and per-document transaction
  limits are recorded in `ANOMALIES.md`.
- Added `create_orders_bulk` and `change_orders_bulk` for independent sales-order
  writes. Both validate every request before writing, commit/rollback per order,
  and continue after a failed row. `ty_write_result` now reports test-run and
  commit state for single, bulk, and atomic operations; atomic rollback marks
  every row unsuccessful and clears document numbers from rolled-back creates.
  Tests cover mixed successes, validation before any write, simulations, and
  atomic rollback status. `npm.cmd test` passed: abaplint reported zero issues
  across 90 files, the transpiler wrote 1,091 outputs, and ABAP Unit completed
  successfully. SAP transaction limits are documented in `ANOMALIES.md`.
- Added sales-order item rejection updates using `BAPISDITM-REASON_REJ` and its
  `BAPISDITMX` update flag. `reject_order_items` validates unique item numbers
  and nonblank reason codes; `reject_orders_bulk` commits each order
  independently, and `reject_orders_atomic` uses one shared commit or rollback.
  All modes preserve SAP messages and support test runs. Tests cover single
  commits, simulations, bulk continuation, atomic success, and atomic rollback.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,091
  transpiler outputs, and ABAP Unit success. Target-system rejection reasons,
  BAPI field behavior, and transaction handling are recorded in `ANOMALIES.md`.
- Order reads now return rejected items separately from active allocation items,
  including item number, material, plant, sales quantity/unit, and rejection
  reason. A fully rejected order remains a successful read with a warning; its
  items cannot flow into the active-demand collection. Tests cover mixed and
  rejected-only read results. `npm.cmd test` passed with zero abaplint issues,
  1,091 transpiler outputs, and ABAP Unit success. Verify the target release's
  `BAPISDIT` output fields and rejected-item quantity semantics as documented in
  `ANOMALIES.md`.
- Added rejection clearing for single orders and for multi-order bulk or atomic
  groups. Each selected item is sent with a blank rejection reason and the BAPI
  update flag set; clear requests validate distinct item numbers and distinct
  document keys before writing. Tests verify the blank payload, independent
  bulk continuation, shared atomic commit, and rollback on an atomic failure.
  `npm.cmd test` passed with zero abaplint issues across 90 files, 1,091
  transpiler outputs, and ABAP Unit success. SAP documents blank-reason clearing
  for sales-order processing, but the `BAPI_SALESORDER_CHANGE` behavior must be
  confirmed on the target release as recorded in `ANOMALIES.md`.
- Added `ZCL_PURCHASE_ORDER_SERVICE` for standard external POs from explicitly
  selected PIR or outline-agreement sources, plus bulk independent and atomic
  creation. Bulk input is fully validated before any BAPI call; individual
  failures do not prevent later requests from running. Atomic creation shares
  one commit and rolls back the group on a create or commit failure. Added
  `DELETE_ORDER_ITEMS` and `DELETE_ORDERS_ITEMS_BULK` to set SAP's PO item
  deletion indicator, and added `MARK_DELIVERY_COMPLETE` with a validated bulk
  counterpart to close remaining open-order quantity when no further supply is
  expected. Added `READ_ORDER` and `READ_ORDERS` for saved header, item-status,
  quantity, and schedule-line details via `BAPI_PO_GETDETAIL1`. Added
  `CREATE_FROM_SUGGESTIONS` to turn source-selected external replenishment rows
  into PO items with optional base-to-purchasing-unit conversion.
  Tests cover mixed outcomes, continuation, atomic rollback, prevalidation,
  selected item payloads, multi-PO reads, suggestion source/quantity mapping,
  and simulations for creation.
  `npm.cmd test` passed:
  abaplint reported zero issues across 94 files, the transpiler wrote 1,098
  outputs, and all 805 ABAP Unit methods completed. The local API double cannot
  verify target BAPI fields, source pricing, item eligibility, or multi-PO LUW
  behavior, or BAPI output population; delivery-completion and read limits are
  recorded in `ANOMALIES.md`.
- Added `CREATE_FROM_SUGGESTIONS_BULK`, which groups positive replenishment rows
  by vendor and purchasing organization, validates all mapped groups before
  writing, and then creates one independently committed PO per group while
  continuing after failures. Each item retains its original suggestion index in
  `source_request_id`; an all-zero batch returns a successful no-op result.
  Tests cover vendor grouping, quantity conversion, batch continuation,
  prevalidation, and the no-op path. `npm.cmd test` passed with zero abaplint
  issues across 94 files, 1,098 transpiler outputs, and all 809 ABAP Unit methods.
  Target BAPI source, pricing, UOM, locking, and per-PO transaction behavior are
  documented in `ANOMALIES.md`.
- Added `CREATE_FROM_REQUISITION_ITEMS` to create one PO from selected rows of a
  purchase requisition read. It carries `PREQ_NO`/`PREQ_ITEM` to each PO item,
  uses the unconverted quantity remaining after prior orders, and rejects
  deleted, closed, exhausted, duplicate, vendor-mismatched, or organization-
  mismatched rows before writing. Tests cover reference and quantity mapping,
  commit behavior, and prevalidation. `npm.cmd test` passed with zero abaplint
  issues across 94 files, 1,098 transpiler outputs, and all 811 ABAP Unit
  methods. Validate target BAPI fields, release/source checks, PR quantity
  semantics, and reference updates as recorded in `ANOMALIES.md`.
- Added `CREATE_FROM_REQUISITIONS_BULK` to combine selected PR items into one PO
  per first-seen vendor and purchasing-organization group. It preserves each
  PR item reference, uses remaining quantity, and validates all groups before
  writing; individual PO failures do not stop later groups. Tests cover
  grouping, mapping, continuation, and no writes after a later validation
  error. `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 817 ABAP Unit methods. Target BAPI and PR status
  behavior are recorded in `ANOMALIES.md`.
- Added `CHANGE_ORDER_SCHEDULES` and its bulk counterpart for explicit
  schedule-line quantity and delivery-date changes through `BAPI_PO_CHANGE`.
  The bulk method validates every PO group first, then commits each PO
  independently and continues after a failed change. Tests cover field mapping,
  per-order continuation, rollback after failure, and batch prevalidation.
  `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 814 ABAP Unit methods. Target schedule eligibility,
  PO item quantity consistency, and BAPI update behavior are recorded in
  `ANOMALIES.md`.
- Added `CREATE_REQUISITIONS_ATOMIC` for selected PR rows grouped by the chosen
  vendor and purchasing organization. It validates all groups before writing,
  commits all created POs together, and rolls the batch back on create or commit
  failure. Tests cover successful grouped creation and rollback cleanup.
  `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 819 ABAP Unit methods. Target SAP LUW behavior is
  recorded in `ANOMALIES.md`.
- Added `CREATE_FROM_SUGGESTIONS_ATOMIC`, using the same grouped request builder
  and optional purchasing-unit conversion as the independent batch path. All
  supplier POs commit together; a create failure rolls back the batch, and an
  all-zero selection returns a no-op result. Tests cover mapping, one shared
  commit, failure cleanup, and the no-op case. `npm.cmd test` passed with zero
  abaplint issues across 94 files, 1,098 transpiler outputs, and all 822 ABAP
  Unit methods. Target SAP LUW behavior is recorded in `ANOMALIES.md`.
- Added `CHANGE_ORDER_SCHEDULES_ATOMIC` for multi-PO schedule-line changes. It
  validates every PO first, applies all schedule updates, and commits once;
  failed updates or commits roll back the batch. Tests cover prevalidation,
  update mapping, one shared commit, and both rollback paths. `npm.cmd test`
  passed with zero abaplint issues across 94 files, 1,098 transpiler outputs,
  and all 826 ABAP Unit methods. Target SAP LUW behavior is documented in
  `ANOMALIES.md`.
- Added atomic multi-PO item deletion and delivery-completion methods. They
  validate the full selection before writing, commit all changes together, and
  roll back the batch after any failed update or commit. Tests cover both
  actions, result mapping, prevalidation, and update failure rollback.
  `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 830 ABAP Unit methods. Target SAP LUW and item
  eligibility checks are documented in `ANOMALIES.md`.
- Added support for the standard `TB` daily lot-size procedure in replenishment
  suggestions. Each daily period uses the shortage date as both boundaries and
  keeps the procedure's configured lot constraints. Tests verify daily period
  output. `npm.cmd test` passed with zero abaplint issues across 94 files, 1,098
  transpiler outputs, and all 831 ABAP Unit methods. Remaining configured
  custom period intervals are still noted in `ANOMALIES.md`.
- Added caller-resolved replenishment periods for period-based or custom lot-size
  procedure keys, including separate ranges by plant and procedure. The service
  validates dates, duplicate/overlapping ranges, and coverage for shortage dates;
  custom procedures apply their configured minimum, maximum, and order multiple
  to netted period requirements. Tests cover `W2` and `PB` groupings, overlap,
  uncovered-date rejection, and PO receipt netting through the stock-backed
  convenience method. `npm.cmd test` passed with zero abaplint issues across 94
  files and 1,098 transpiler outputs.
- Added PO item quantity changes through `BAPI_PO_CHANGE`, including single-PO,
  per-PO bulk, and shared-commit atomic methods. Requests require unique item
  numbers and positive quantities in the existing purchase-order unit. Tests
  cover request mapping, prevalidation, batch continuation, atomic commit, and
  rollback after an update or commit failure. `npm.cmd test` passed with zero
  abaplint issues across 94 files and 1,098 transpiler outputs; SAP field
  controls and multi-PO LUW behavior remain documented in `ANOMALIES.md`.
- Added `CHANGE_QTY_FROM_BASE` plus bulk and atomic forms. They read each PO,
  validate selected items, and convert material base-unit quantities to the PO
  item's unit before any writes. Missing conversion data rejects the full
  request. Tests cover conversion, validation before writes, atomic commit, and
  conversion failure. `npm.cmd test` passed with zero abaplint issues across 94
  files and 1,098 transpiler outputs. Target UOM ratios, PO item eligibility,
  and multi-document LUW behavior remain documented in `ANOMALIES.md`.
- Added `CHANGE_BASE_SCHEDULES` plus bulk and atomic forms. Quantity-bearing
  schedule rows convert material base units to the PO item unit after reading
  and validating the item; date-only rows keep the existing no-read path. Bulk
  and atomic forms finish all reads/conversions before writes. Tests cover
  conversion, date-only preservation, batch prevalidation, atomic commit, and
  conversion rejection. `npm.cmd test` passed with zero abaplint issues across
  94 files and 1,098 transpiler outputs. Target UOM and schedule eligibility
  behavior remains in `ANOMALIES.md`.
- Added `CREATE_FROM_QUOTA_SPLITS` to bridge quota split previews to PR creation.
  It validates that allocated shares reconcile to each selected suggestion,
  then creates one vendor-specific PR item per split at the proposal quantity,
  including purchasing-unit conversion and original suggestion-index mapping.
  Tests cover two-source item mapping, conversion, commit, and incomplete-split
  rejection. `npm.cmd test` passed with zero abaplint issues across 94 files
  and 1,098 transpiler outputs. Quota snapshot staleness and SAP source
  acceptance remain documented in `ANOMALIES.md`.
- Added `GET_PO_CONFIRMED_RECEIPTS` to return standard PO schedule remainder
  rows alongside open MRP-relevant EKES supplier confirmations. It uses the
  stored EKET/EKES MRP-reduced quantities and converts each row to the material
  base unit; `GET_PO_CONF_RECEIPTS_IN_UNIT` also converts the result to a
  requested material unit. `GET_PO_CONF_RECEIPTS_BULK` and its `_UOM` variant
  group repeated material/plant requests, filter by each deadline, and cache
  unit ratios. `SUGGEST_COMP_REPL_FROM_STOCK` can net these confirmations into
  component shortage suggestions through `iv_include_po_confirmations`, which
  is mutually exclusive with regular PO receipt projection. Tests cover service
  contracts, invalid horizons, query grouping, deadline filtering, ratio reuse,
  conversion, reduction arithmetic, shortage netting, and source exclusivity.
  `npm.cmd test` passed with zero abaplint issues across 94 files and 1,099
  transpiler outputs. Confirmation-category configuration and DABMG/WEMNG
  behavior still require target-SAP validation, documented in `ANOMALIES.md`.
- Added `ISSUE_COMPONENTS_IN_UNIT` and `ISSUE_COMPONENTS_BULK_IN_UNIT` for
  production component issues requested in a material's alternative unit. The
  service reads each reservation component once, converts all requested lines
  to the component's base unit, validates the complete batch, and posts one
  reservation goods movement. Tests cover box-to-base conversion, base-unit
  BAPI mapping, a single component read, and rejection of an unknown unit in a
  mixed batch before any goods movement. `npm.cmd test` passed with zero
  abaplint issues across 116 files and 1,156 transpiler outputs. Live
  `MARA`/`MARM` ratio, rounding, and reservation behavior remain documented in
  `ANOMALIES.md`.
- Added `RETURN_COMPONENTS_IN_UNIT` and `RETURN_COMPONENTS_BULK_IN_UNIT` for
  partial component returns requested in an alternative material unit. The
  service reads the selected component rows once, converts every quantity to
  its reservation unit, validates all lines against withdrawn quantities, and
  posts one reservation reversal. Tests cover box-to-base reversal mapping,
  single-read behavior, and unknown-unit rejection before posting. The latest
  `npm.cmd test` run passed with zero abaplint issues across 116 files and
  1,156 transpiler outputs; live UOM and reversal behavior is recorded in
  `ANOMALIES.md`.
- Added direct `CREATE_ORDER` support to `ZCL_PROD_ORDER_SERVICE` through
  `BAPI_PRODORD_CREATE`, for callers that need a production order without a
  planned-order conversion. The service validates material, plants, order type,
  quantity/unit, and basic dates, defaults planning plant to production plant,
  and owns the commit/rollback boundary. Added the SAP `BAPI_PP_ORDER_CREATE`
  stub with only mapped fields. Tests cover BAPI input/result mapping, valid
  creation, input rejection before the API, and rollback after create or commit
  failure. `npm.cmd test` passed: zero abaplint issues across 116 files,
  1,157 transpiler outputs, and a successful ABAP Unit run. Target BAPI and
  order-master behavior remain documented in `ANOMALIES.md`.
- Added `CREATE_ORDERS_BULK` and `CREATE_ORDERS_ATOMIC` for multi-order direct
  production-order creation. Both validate the complete request before calling
  SAP. Bulk mode commits each order independently and continues after an item
  failure; atomic mode shares one commit and rolls back the group on a create
  or commit failure. Tests cover partial bulk failure, continued processing,
  shared commit, prevalidation, duplicate returned order numbers, and atomic
  rollback. `npm.cmd test` passed with zero abaplint issues across 116 files,
  1,157 transpiler outputs, and a successful ABAP Unit run. Repeated-call LUW
  behavior still requires target-SAP validation, as recorded in
  `ANOMALIES.md`.
- Added typed `RECEIVE_PURCHASE_ORDER`, `RECEIVE_PURCHASE_ORDERS_BULK`, and
  `RECEIVE_PURCHASE_ORDERS_ATOMIC` methods for PO goods receipts. They map PO
  references and item quantities to movement 101/code 01 with indicator `B`,
  prevalidate the full request, and provide either per-PO commits or one shared
  commit with rollback. Tests cover field mapping, partial bulk failure,
  continued processing, invalid duplicate-PO input, rollback on receipt
  failure, and rollback on commit failure. Target-SAP repeated-call LUW
  behavior is recorded in `ANOMALIES.md`. The complete `npm.cmd test` run
  passed with zero abaplint issues across 116 files, 1,157 transpiler outputs,
  and a successful ABAP Unit run.
- Added typed `RECEIVE_PROD_ORDER`, `RECEIVE_PROD_ORDERS_BULK`, and
  `RECEIVE_PROD_ORDERS_ATOMIC` methods for production-order goods receipts.
  They map finished output to movement 101/code 02 with indicator `F`,
  prevalidate each order and quantity/unit, and support independent commits or
  a shared rollback boundary. Tests cover mapping, bulk continuation, atomic
  create and commit failures, duplicate-order rejection, and test-run behavior.
  The complete `npm.cmd test` run passed with zero abaplint issues across 116
  files, 1,157 transpiler outputs, and a successful ABAP Unit run. SAP receipt
  eligibility and repeated-call LUW behavior are recorded in `ANOMALIES.md`.
- Added optional `iv_reservation_through_date` to project-stock FEFO, location,
  and WBS transfer previews. The repository now returns `RESB-BDTER`; open
  reservations dated after the cutoff are excluded, while undated reservations
  and the prior all-open default remain conservative. Tests cover the cutoff
  and default behavior for batch and batchless stock and verify cutoff
  forwarding through WBS transfers. Target `RESB-BDTER` behavior and the fact
  that this remains a current-stock snapshot are documented in `ANOMALIES.md`.
- Added `CREATE_FROM_PROJ_SHORTFALLS` to the replenishment requisition
  service. It builds one `Q` account-assigned PR item per validated shortfall,
  retaining the material, base unit, delivery date, and stock-bearing WBS.
  `BAPI_PR_CREATE` now receives matching `PRACCOUNT` and `PRACCOUNTX` rows; the
  standard item/account DDIC stubs and mapper tests cover those fields. Added
  service tests for successful multiple-WBS creation and rejection before SAP
  calls. Target BAPI signature, account assignment rules, and WBS validity are
  documented in `ANOMALIES.md`.
- Added FEFO batch-expiry validation to `RESERVE_BATCH_ALLOCATION`. A selected
  batch must remain valid through its WBS required date, and the new optional
  `iv_minimum_shelf_life_days` can require additional remaining life. Unknown
  expiry is allowed with no minimum and rejected with a positive minimum.
  Tests cover per-WBS expiry, the shelf-life boundary, short shelf life, and
  unknown expiry before writes. Target SAP batch checks and snapshot limits are
  documented in `ANOMALIES.md`.
- Added `RESERVE_WBS_FEFO` to run the project-stock FEFO preview and batch
  reservation in one service call, returning both results. Complete coverage
  is the default; a preview shortfall is returned to the caller without any
  create call, while opt-in partial mode reserves the available splits. The
  wrapper forwards WBS-specific required dates, shelf-life rules, test-run,
  and atomic options. Tests cover FEFO batch order, split quantities, required
  date forwarding, commit, and shortfall no-write behavior.
- Added `RESERVE_WBS_BY_LOCATION` for one-call batchless project-stock preview
  and reservation. It returns both results, defaults to full coverage, and
  retains a shortfall preview without making reservation calls. Required-date
  input validation is shared with the FEFO wrapper and runs before stock reads.
  Tests cover storage-location reservation mapping, commit, and no-write
  shortfall handling. `npm test` passed after both reservation enhancements:
  abaplint found zero issues across 128 files, transpilation wrote 1,141
  outputs, and ABAP Unit exited successfully.
- Updated project-stock FEFO to accept `fefo_as_of_date` on each demand. The
  later of the demand date and shared as-of date drives the shelf-life check,
  and each returned batch split echoes that effective date. `RESERVE_WBS_FEFO`
  now previews against the WBS required date, so it skips batches that cannot
  survive to the reservation date and can use later eligible batches. Added
  coverage for per-demand expiry, invalid date rejection before reads, and the
  later-batch reservation case, including WBS transfers. A positive shelf-life
  minimum also excludes undated batches in the reservation preview, returning
  a shortfall without a create attempt. The subsequent full `npm test` passed
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Extended cost-center FEFO with per-demand `fefo_as_of_date`. Preview rows
  use the later of the shared as-of date and the row override; single and
  atomic reservations also include the reservation's required date. Results
  and batch splits report the effective date, and bulk reservations preserve
  the same row behavior. Tests cover preview, single, atomic, and bulk flows,
  batches that expire before the effective date, and invalid row dates rejected
  before stock reads. `npm test` passes with zero abaplint issues across 128
  files and a successful transpile and ABAP Unit run.
- Added required-date expiry filtering to exact-batch cost-center allocation.
  Single preview and reservation calls check the chosen batch through the
  required date; `iv_batch_min_days` can require more remaining life. Atomic and
  bulk demand rows carry their required date and optional minimum through the
  unit-aware batch allocator. Expired or short-life stock yields a shortfall
  without a reservation write; unknown expiry remains eligible with no minimum.
  Tests cover expiration before the date, the inclusive date boundary, extra
  shelf life, and atomic no-write handling. `npm test` passes with zero
  abaplint issues across 128 files, 1,141 transpiler outputs, and successful
  ABAP Unit. Target SAP batch behavior is recorded in `ANOMALIES.md`.
- Fixed cost-center reservation date validation: atomic and bulk requests now
  require every `required_date` to be a valid Gregorian date, even when FEFO is
  disabled. This prevents malformed dates from reaching stock allocation or
  the reservation API. Regression tests verify both entry points reject an
  invalid date before stock reads or writes. The resolved gap is recorded in
  `ANOMALIES.md`. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added expiry filtering to explicit sales-order batch selection. Each selected
  batch is checked through its schedule requested date, or `sy-datum` for an
  undated item, matching the reservation adapter's effective required date.
  Expired stock produces a preview shortfall; full-allocation reservation mode
  makes no write. Expiry on the required date remains eligible. Target SAP batch
  validation and snapshot limits are recorded in `ANOMALIES.md`. `npm test`
  passes with zero abaplint issues across 128 files, 1,141 transpiler outputs,
  and successful ABAP Unit.
- Added `minimum_shelf_life_days` to explicit sales-order batch selections.
  Each item or schedule line can require extra days beyond its effective
  reservation date; the boundary is inclusive and unknown expiry is excluded
  when the minimum is positive. Negative minimums fail before repository reads.
  Tests cover the boundary, short shelf life, unknown expiry, and early
  validation. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Sales-order batch and location selections now validate `allow_fallback` as
  `abap_true` or `abap_false` before reading reservations or stock. Regression
  tests verify malformed flags fail before repository reads. `npm test` passes
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- The shared stock allocator now validates `fallback_to_other_locations` in
  location, exact-batch, and FEFO demands, including unit-aware variants.
  Malformed flags fail before stock or unit-conversion reads. Tests cover all
  six allocation entry points. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Location, exact-batch, and FEFO allocation methods now also validate
  `iv_protect_safety_stock` in base and unit-aware forms. Invalid values fail
  before stock or unit-conversion reads; tests cover all six entry points.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit.
- Single-plant stock, dated, unit-aware, and ATP allocation entry points now
  also accept only `abap_true` or `abap_false` for
  `iv_protect_safety_stock`. Cross-plant, dated, FEFO, batch, unit, and ATP
  entry points apply the same check before stock or UOM access. Regression
  tests cover the single-plant and cross-plant method families, including no
  repository reads for malformed values. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Dated single-plant and cross-plant allocation now validate all receipt-option
  flags as `abap_true` or `abap_false` before stock, UOM, or ATP work. The
  existing PO receipts and PO confirmations mutual exclusion is checked by
  the same validator. Tests cover each malformed option and all dated
  allocation entry points. `npm test` passes with zero abaplint issues across
  128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Completed the allocation-flag audit for `iv_require_full_quantity`. The
  single-request and dated cross-plant batch ATP entry points now reject
  malformed values locally before delegating or reading stock. Regression
  tests cover both paths with zero repository reads. `npm test` passes with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Added `ALLOCATE_BY_EXPIRY_ATP` for unit-aware single-plant FEFO demands. It
  returns the local FEFO estimate and groups ATP checks by material, plant,
  base unit, and effective FEFO date, accumulating allocated quantity through
  each date. It skips ATP when no eligible stock was allocated. Tests cover
  split selection, cumulative dates and confirmations, missing-rule rejection
  before reads, and no ATP call for an expired-only shortfall. `npm test` passes
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit. Target ATP behavior is recorded in `ANOMALIES.md`.
- Added `ALLOCATE_BY_BATCH_ATP` for exact-batch unit-aware demands. It fills
  omitted row dates from `iv_as_of_date`, preserves explicit dates and the
  selected batch, applies local expiry checks, then reuses the shared
  date-grouped ATP confirmation logic. Tests cover exact batch selection,
  partial allocation, row-date override, cumulative confirmations, and bad
  check-rule rejection before reads. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
  Target ATP behavior is recorded in `ANOMALIES.md`.
- Added `ALLOCATE_BY_LOCATION_ATP` for unit-aware single-plant location demand.
  It aggregates positive local allocations by material, plant, and base unit,
  then checks ATP at an optional date that defaults to today. The local estimate
  remains based on current stock. Tests cover aggregation across demand rows,
  unit conversion, partial confirmations, early rule/date rejection, and
  skipping ATP after a full-quantity local shortfall. Target SAP checking scope
  is documented in `ANOMALIES.md`. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Added `ALLOCATE_LOCATION_BY_DATE_UOM` for dated unit-aware location demands.
  It allocates earlier dates first and higher priorities within a date, then
  preserves input order for equal-date, equal-priority requests and returns
  demand and storage-location splits in caller order. Dates and unique request
  IDs are validated before UOM or stock reads. The preview uses current
  location balances only; the receipt-location limitation is recorded in
  `ANOMALIES.md`. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit.
- Added `ALLOCATE_LOCATION_DATE_UOM_ATP` for dated location previews. It checks
  positive allocations cumulatively by material, plant, base unit, and required
  date, and returns confirmation and unconfirmed quantities without changing
  local allocation. Tests cover cumulative requests, partial confirmation,
  invalid-rule rejection before reads, and no ATP call for a zero allocation.
  Target-system ATP scope is recorded in `ANOMALIES.md`. `npm test` passes with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit.
- Added `READ_AVAILABLE_STOCK_IN_UNIT` and `READ_AVAILABLE_STOCK_BULK_UOM` for
  project stock. They preserve location, batch, and expiry details while
  returning both requested-unit and base-unit quantities. The bulk method
  caches material/unit ratios, retains the cutoff-grouped stock read, and
  rejects every unknown unit before stock access. Tests cover conversion,
  ratio reuse, and no reads on invalid units. `npm test` passes with zero
  abaplint issues across 128 files, 1,141 transpiler outputs, and successful
  ABAP Unit.
- Added `PREVIEW_FEFO_BY_DATE` for project stock. Earlier required dates consume
  shared WBS/material/plant balances first; same-date priority runs descending,
  and equal priorities retain input order. Results and batch splits return in
  caller order with required date and priority. Batch expiry is checked through
  each requirement date, and invalid dates or duplicate request IDs fail before
  stock reads. Tests cover date/priority allocation and caller-order results.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Snapshot limitations are in
  `ANOMALIES.md`.
- Added `RESERVE_WBS_FEFO_BY_DATE` to reserve the date-prioritized project FEFO
  preview. It groups items by WBS and required date, reruns and compares the
  complete batch split before writing, and supports the existing test-run and
  atomic transaction options. Tests cover stock consumption priority, caller
  order, multiple reservation dates for one WBS, and invalid dates before reads.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Target BAPI behavior is recorded
  in `ANOMALIES.md`.
- Added `PREVIEW_BY_LOCATION_DATE` for batchless project stock. It allocates
  earlier requirements first, then higher priorities within the same date,
  while preserving caller order for summaries and location splits. Invalid
  dates and duplicate IDs are rejected before stock reads. Tests cover date and
  priority ordering plus caller-order results. `npm test` passes with zero
  abaplint issues across 128 files, 1,141 transpiler outputs, and successful
  ABAP Unit. Location snapshot limitations are recorded in `ANOMALIES.md`.
- Added `RESERVE_WBS_BY_LOCATION_DATE` to reserve dated batchless project-stock
  allocations. It groups reservations by WBS and required date, checks the
  location split again before writing, and supports full-quantity, test-run,
  and atomic transaction options. Tests verify priority allocation, date-based
  reservation grouping, and invalid-date rejection before reads. `npm test`
  passes with zero abaplint issues across 128 files, 1,141 transpiler outputs,
  and successful ABAP Unit. Target behavior is recorded in `ANOMALIES.md`.
- Added `READ_RESERVATION_COVERAGE_UOM` for a single material/plant/WBS key.
  It returns requested-unit and base-unit totals and checks the material UOM
  ratio before stock or reservation reads. Tests cover conversion and early
  rejection of an unknown unit. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
  Target unit semantics are recorded in `ANOMALIES.md`.
- Added `READ_RESV_COVERAGE_BULK_UOM` for multiple material/plant/WBS requests.
  It validates and caches each requested-unit ratio before delegating to the
  cutoff-grouped coverage reader, then returns both unit views in request
  order. Tests cover conversion, shared reads, and unknown-unit rejection before
  stock access. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit. Query limitations are in
  `ANOMALIES.md`.
- Added `READ_RESERVATION_ITEMS_BULK` for multiple WBS requests. It validates
  unique request IDs, deduplicates WBS reads, and preserves final and fully
  withdrawn items in each response. Tests cover repeated WBS requests, item
  ordering, shared reads, and rejection before a read on duplicate IDs.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Query limitations are in
  `ANOMALIES.md`.
- Added `PREVIEW_TRANSFER_FEFO_BY_DATE` and `TRANSFER_WBS_FEFO_BY_DATE` for
  date and priority ordered project-stock batch transfers. The goods movement
  adapter repeats the dated preview and rejects changed batch splits before
  posting 415/Q. Tests cover caller-order output, date and priority allocation,
  successful posting, invalid dates before reads, and stale snapshot rejection.
  `npm test` passes with zero abaplint issues across 128 files, 1,141
  transpiler outputs, and successful ABAP Unit. Target SAP snapshot and
  movement limitations are recorded in `ANOMALIES.md`.
- Added `PREVIEW_TRANSFER_LOCATION_DATE` and
  `TRANSFER_WBS_BY_LOCATION_DATE` for dated batchless WBS transfers. The preview
  applies date and same-date priority ordering while preserving caller-order
  results; the movement adapter compares the repeated location split before
  posting 415/Q. Tests cover priority allocation, posting, and stale snapshot
  rejection. `npm test` passes with zero abaplint issues across 128 files,
  1,141 transpiler outputs, and successful ABAP Unit. Target snapshot behavior
  is recorded in `ANOMALIES.md`.
- Added a GitHub Actions validation workflow for pushes and pull requests. It
  installs Node.js 22, checks out the exact open-abap-core revision used in
  this workspace, and runs `npm test`. The workflow YAML parses locally, and
  the same validation command passes with zero lint issues and 1,141
  transpiler outputs.
- Added `ALLOCATE_LOCATION_BY_DATE` for base-unit location demand. Earlier
  required dates consume shared stock first, same-date priority runs descending,
  and input order breaks ties. Results return in caller order and retain the
  existing location priority, allowlist, safety-stock, and full-quantity
  options. Tests cover date and priority ordering, output ordering, invalid
  dates and duplicate IDs before reads. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
  Current location snapshot limits are in `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_BY_DATE_LOC` for date-prioritized cross-plant
  allocation from current location balances. It preserves each request's
  source-plant order, returns plant and location splits in caller order, and
  supports location scopes, priority, safety stock, and full-quantity policy.
  Tests cover date-over-priority ordering, same-date input ties, split ordering,
  shared stock across requests, and invalid dates before reads. `npm test`
  passes with zero abaplint issues across 128 files, 1,141 transpiler outputs,
  and successful ABAP Unit. Receipt and snapshot limits are recorded in
  `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_DATE_LOC_UOM` for dated, unit-aware cross-plant
  allocation with location splits. It caches material/unit ratios, preserves
  date and priority allocation plus caller-order results, and returns demand,
  source-plant, and location quantities in both units. Tests cover competing
  dates and priorities, rounded alternate-unit splits, conversion reuse, and
  unknown-unit rejection before stock reads. Receipt and stock snapshot limits
  are recorded in `ANOMALIES.md`.
- Added `ALLOCATE_PLANTS_DATE_LOC_ATP` to compare positive dated source-plant
  splits with SAP ATP. It groups cumulative quantities by source plant and
  required date, retains location-level local results, and skips checks for
  unallocated shortfalls. Tests cover date accumulation, caller-order results,
  skipped shortfalls, and invalid-rule rejection before reads. ATP scope limits
  are recorded in `ANOMALIES.md`. `npm test` passes with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Added `CREATE_DATE_LOC_PAIRS` and `CREATE_DATE_LOC_ATP_PAIRS` to create STOs
  from dated, unit-aware source-location allocations. Each source location
  becomes a dated PO item in canonical base units; demand, plant, and location
  totals are checked before writes. The ATP entry point rejects incomplete
  cumulative confirmation before BAPI calls. Tests cover item mapping, atomic
  commit, test-run behavior, split mismatch, and short ATP. Target BAPI field
  behavior is recorded in `ANOMALIES.md`. `npm test` passes with zero abaplint
  issues across 128 files, 1,141 transpiler outputs, and successful ABAP Unit.
- Added `TRANSFER_PLANT_DATE_LOC_UOM` and `TRANSFER_DATE_LOC_UOM_2STEP` to
  post dated cross-plant location results as 301 or 303/305 transfers. Both
  preserve source locations and canonical base quantities, validate date and
  priority consistency, and check unit mappings. Tests cover both posting flows
  and reject mismatched split dates before a BAPI call. `npm test` passed with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit execution.
- Added `TRANSFER_DATE_LOC_ATP` and `TRANSFER_DATE_LOC_ATP_2STEP` for dated
  location allocations with ATP diagnostics. Both require one matching,
  relevant, cumulatively confirmed ATP check per positive source/date split
  before posting, and reconcile the ATP-confirmed source quantities with the
  location rows. Tests cover both posting flows and reject short ATP and a
  mismatched source-location split before creating a goods movement. Target ATP
  and movement behavior is recorded in `ANOMALIES.md`. `npm test` passed with
  zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit execution.
- Added `GET_TRANSFER_LOCATIONS`, `GET_TRANSFER_LOCATIONS_BULK`, and unit-aware
  variants to enumerate aggregate `MARD-UMLME` quantities by storage location.
  Bulk results preserve request order and sort locations, reject duplicate or
  mismatched rows, and cache repeated unit ratios. Tests cover single and bulk
  reads, conversion, requests with no transfer rows, empty input, and invalid
  repository rows. `npm test` passed
  with zero abaplint issues across 128 files, 1,141 transpiler outputs, and
  successful ABAP Unit execution. Aggregate-versus-batch query semantics are
  recorded in `ANOMALIES.md`.
- Added `TRANSFER_FEFO_DATE_ATP` and `TRANSFER_FEFO_DATE_ATP_2STEP` for dated
  FEFO allocation results with ATP checks. Before posting 301 or 303/305, the
  adapters require one matching relevant ATP result per positive request,
  source, and date, require full cumulative confirmation, and reconcile plant
  totals with batch/location splits. Tests cover both movement flows, short
  ATP, and split mismatch; plant-level ATP and stock-snapshot limits are
  recorded in `ANOMALIES.md`. `npm test` passed: zero abaplint issues across
  128 files, 1,141 transpiler outputs, and successful ABAP Unit execution.
- Strengthened the dated FEFO ATP movement gate to recompute confirmations from
  the raw ATP result using the required-date cutoff and compare them with the
  convenience confirmed/unconfirmed totals. Added a rejection case for
  inconsistent summary values. The gate also verifies demand/source dates,
  priorities, units, and allocated totals, since the posting adapter otherwise
  strips date metadata. Tests cover date-cutoff confirmations and reject a
  demand/source date mismatch. `npm test` passed with zero abaplint issues
  across 128 files, 1,141 transpiler outputs, and successful ABAP Unit
  execution. Details are in `ANOMALIES.md`.
- Added required-date and priority checks to the existing dated unit-aware FEFO
  301 and 303/305 movement adapters. The checks keep demand, source, and batch
  split metadata consistent before posting drops date/priority fields. Tests
  reject a mismatched demand date before the goods-movement API; `npm test`
  passed with zero abaplint issues, 1,141 transpiler outputs, and successful
  ABAP Unit execution.
- Added `ZCL_STOCK_ALLOCATION_FACTORY` as a production composition root for
  stock preview, goods movement, and STO creation. It binds the standard MARD,
  UOM, ATP, movement, and purchase-order adapters; direct constructor injection
  remains available for custom integrations and tests. Construction is covered
  by ABAP Unit. `npm test` passed with zero lint issues across 130 files and
  1,145 transpiler outputs. Target SAP API validation remains in
  `ANOMALIES.md`.
- Added `POST_SO_ISSUE_REMAINING` to issue all remaining quantities from a
  caller-selected set of reservations for one sales-order item. It verifies
  movement type and order/item scope, skips fully withdrawn items, derives
  base-unit requests, and delegates to the existing per-reservation bulk issue
  path for a second state check and posting. Tests cover open-quantity mapping,
  wrong scope, and fully withdrawn reservations. The double read, live BAPI
  validation, and independent per-reservation commits are recorded in
  `ANOMALIES.md`.
- Added `POST_SO_ISSUE_REMAINING_ATOMIC`, which uses the same validated open
  quantities and sales-order scope but stages all selected reservation issues
  before one shared commit. Tests cover successful posting and rollback when
  the order scope changes between the initial read and the posting recheck.
  Verify shared-LUW behavior in the target SAP release; see `ANOMALIES.md`.
- Added request-ID selection to `RELEASE_SO_FEFO_RESERVATIONS`. The method still
  validates the full committed result, then deletes all batch/location
  reservations for selected demand IDs; empty selection releases all. Tests
  cover selecting one of two demands and duplicate-ID rejection before the
  delete API.
- Added reservation-number selection to `RELEASE_SO_FEFO_RESERVATIONS` so a
  caller can release one batch/location split from a multi-split FEFO demand.
  The service validates selected numbers against the fully matched committed
  result, rejects duplicates, unknown numbers, and mixed selector modes, and
  keeps the existing all-rows default when no selector is supplied.
- Hardened release validation to reject blank, nonpositive, or duplicate
  request/location/batch split keys before deletion, including a correlated
  result tampering case where both preview and reservation rows repeat a split.
- Added `PREVIEW_SO_ISSUE_REMAINING` as a read-only entry point for the selected
  sales-order reservations. It returns issueable item keys, remaining base-unit
  quantities, base-unit ISO codes, locations, and batches without posting; it
  rejects missing ISO mappings, and the posting methods keep their own re-read
  and eligibility checks.
- Added `PREVIEW_CC_ISSUE_REMAINING` and `POST_CC_ISSUE_REMAINING`. The preview
  can list all open cost-center reservations or filter by selected reservation
  numbers; posting requires an explicit selection and issues the open
  base-unit quantities through the existing scope-checked bulk path.
- Added `POST_CC_ISSUE_REMAINING_ATOMIC`. It uses the same selected open
  quantities, rechecks cost-center scope before each reservation movement, and
  requests one shared commit or rollback. Target LUW behavior remains noted in
  `ANOMALIES.md`.
- Added `POST_CC_ISSUE_REV_ATOMIC` for unit-aware cost-center withdrawal
  reversals. It rejects invalid simulation flags and missing posting dates
  before repository reads, validates the full selected scope before staging the
  group, and requests one shared commit or rollback. Tests cover unit conversion,
  commit behavior, and early flag rejection; target scope-query and LUW behavior
  remain noted in `ANOMALIES.md`.
- Added `PREVIEW_REMAINING_COMPONENTS` and `ISSUE_REMAINING_COMPONENTS` for an
  explicit set of production-order reservation items. The preview returns only
  open 261 components; posting issues the captured open quantities through the
  existing bulk path, which rereads and revalidates before one material
  document. Duplicate keys, invalid test flags, and non-261 issues are rejected;
  invalid flags fail before reads. The read snapshot limits are recorded in
  `ANOMALIES.md`.
- Added `PREVIEW_RETURNABLE_COMPONENTS` and `RETURN_REMAINING_COMPONENTS` for
  selected production-order reservation items. The preview includes fully
  withdrawn 261 items and reports the withdrawn balance; posting rereads and
  reverses those captured quantities together. Tests cover final-issue rows,
  duplicate selection, UOM-free full-balance posting, and early test-flag
  rejection. SAP reversal eligibility remains documented in `ANOMALIES.md`.
- Added `PREVIEW_CC_REV_REMAINING` and `POST_CC_REV_REMAINING_ATOMIC` for
  selected cost-center reservation items. The preview requires movement 201
  and reports withdrawn base quantities; posting reverses the full selected
  balances in one LUW and rechecks cost-center scope before staging each
  reservation. Tests cover preview mapping, one-commit posting, duplicate-key
  rejection, and rollback when scope changes. Target SAP behavior is recorded
  in `ANOMALIES.md`.
- Added `PREVIEW_CC_REMAINING_ITEMS` and `POST_CC_REMAINING_ITEMS_ATOMIC` so
  callers can choose exact reservation/item keys instead of issuing every item
  in selected reservation documents. Duplicate or missing keys are rejected;
  atomic posting rechecks cost-center scope and commits the selected items once.
  Exact-item tests cover selection, quantity mapping, and duplicate rejection.
- Added `POST_CC_REMAINING_ITEMS` as the independent-commit counterpart. It
  applies the exact item selection, then continues per reservation while
  returning per-document bulk results; the partial-success behavior is
  recorded in `ANOMALIES.md`.
- Added `POST_CC_REV_REMAINING_BULK` alongside the atomic full-balance reversal.
  It uses the same exact item preview but commits each reservation separately;
  tests verify two selected reservations produce two documents and commits.
  Partial-success and target SAP behavior remain in `ANOMALIES.md`.
- Added `PREVIEW_SO_REV_REMAINING` and bulk/atomic posting methods for the
  withdrawn balances of selected sales-order reservation documents. The preview
  validates movement 231 and sales-order item scope, rejects duplicate or
  missing selections, rejects negative or over-withdrawn rows, and skips
  zero-withdrawal items. Posting repeats the
  reservation check; bulk mode commits per reservation and atomic mode requests
  one shared commit. Tests cover quantity mapping, malformed balances,
  two-document bulk behavior, atomic grouping, and mismatched order scope.
  Target SAP LUW and reversal
  behavior are recorded in `ANOMALIES.md`. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit completion.
- Added exact-item sales-order reversal selection with
  `PREVIEW_SO_REV_REMAINING_ITEMS`, `POST_SO_REV_REM_ITEMS_BULK`, and
  `POST_SO_REV_REM_ITEMS_ATOMIC`. It reuses the movement-231 and order-item
  validation, rejects duplicate or unavailable reservation/item keys, and
  delegates posting to the per-reservation or shared-LUW paths. Tests cover
  selecting one of two items, bulk and atomic posting, missing keys, and
  duplicate-key rejection. Snapshot and SAP reversal limits are in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  transpilation completed, and ABAP Unit exited successfully.
- Added exact-item sales-order issue methods with
  `PREVIEW_SO_ISSUE_REM_ITEMS`, `POST_SO_ISSUE_REM_ITEMS_BULK`, and
  `POST_SO_ISSUE_REM_ITEMS_ATOMIC`. They validate movement 231 and order-item
  scope, require positive open quantities on every selected key, and re-read
  selected reservations before posting. Tests cover selecting one of two items,
  bulk and atomic posting, and missing/duplicate-key rejection. Snapshot and SAP
  LUW limits are recorded in `ANOMALIES.md`. `npm test` passed with 0 abaplint
  issues across 134 files, successful transpilation, and ABAP Unit completion.
- Added `RETURN_REMAINING_BULK` to return selected production component balances
  with independent per-reservation commits. It reuses the exact-key preview,
  groups multiple selected items into one reservation movement, rereads each
  production order before posting, and reports success or failure per
  reservation. Tests cover two reservations producing separate documents and
  commits, plus continuation after a later reservation read fails. Target SAP
  reversal and snapshot limits are recorded in `ANOMALIES.md`. `npm test` passed
  with 0 abaplint issues across 134 files, successful transpilation, and ABAP
  Unit completion.
- Added `ISSUE_REMAINING_BULK` for selected production component balances. It
  groups open 261 quantities per reservation, commits each group independently,
  returns per-reservation outcomes, and continues after a failed group. Tests
  cover multiple items grouped into one reservation document, separate
  reservation commits, and continuation after a later reservation detail read
  fails. Snapshot and
  partial-success limits are recorded in `ANOMALIES.md`. `npm test` passed:
  0 abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added optional production order item mapping to production receipts. The
  typed receipt line now carries AFPO's item number through the goods-movement
  interface to BAPI `ORDER_ITM`, enabling co-product receipt selection. A test
  verifies the production item survives receipt request construction; target
  BAPI field behavior is recorded in `ANOMALIES.md`.
- Added `ISSUE_UNPLANNED_PROD_BULK_UOM`. It converts all production-order
  issue lines to their mapped material base unit before the first goods
  movement, then preserves the existing per-order commit and continuation
  results. Tests cover two converted orders and reject a bad later unit before
  any create or commit. Target ratios and BAPI quantity behavior are noted in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added `RETURN_PROD_ORDERS_BULK` and `RETURN_PROD_ORDERS_BULK_UOM` for direct
  movement-262 returns across distinct production orders. The base-unit path
  validates all orders and lines before posting, commits independently per
  order, and continues after a BAPI failure. The UOM path converts every line
  before the first post. Tests cover continuation, two converted orders, and
  rejection of an unsupported later unit before any create or commit. SAP
  posting and reversal limits are recorded in `ANOMALIES.md`.
- Added `RETURN_PROD_ORDERS_ATOMIC` and `RETURN_PROD_ORDERS_ATOMIC_UOM` to stage
  one 262 movement per order and commit the group once, rolling back all staged
  results when a movement or commit fails. The UOM wrapper converts the full
  request before staging. Tests cover success, create and commit rollback,
  converted quantities, and invalid-unit prevalidation. Repeated-call LUW
  behavior remains a target SAP verification item. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added `RETURN_SALES_ORDERS_BULK` and `RETURN_SALES_ORDERS_BULK_UOM` for
  independent movement-232 returns across distinct sales documents. Bulk mode
  validates every order and line before posting, then continues after a failed
  order while retaining per-order outcomes. The UOM variant converts the full
  request before the first post. Tests cover special-stock E mapping,
  continuation, converted quantities, and unsupported later-unit rejection.
  Sales-order and stock eligibility remain SAP checks in `ANOMALIES.md`.
- Added `RETURN_SALES_ORDERS_ATOMIC` and `RETURN_SALES_ORDERS_ATOMIC_UOM` to
  stage one movement-232 document per distinct sales order and commit the group
  once. Movement and commit failures roll back provisional results; the UOM
  method converts the full request before staging. Tests cover group success,
  movement and commit rollback, special-stock E, converted quantities, and
  invalid-unit prevalidation. Target SAP LUW behavior is in `ANOMALIES.md`.
  `npm test` passed: 0 abaplint issues across 134 files, successful
  transpilation, and ABAP Unit exit 0.
- Added `ISSUE_SALES_ORDERS_BULK` and `ISSUE_SALES_ORDERS_BULK_UOM` for
  independent movement-231 issues across distinct sales documents. The base
  path prevalidates the full request and continues after an order failure; the
  UOM path converts every line before the first post. Tests cover special-stock
  E mapping, failure continuation, converted quantities, and rejection of an
  unsupported later unit before any create or commit. SAP issue eligibility is
  recorded in `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134
  files, successful transpilation, and ABAP Unit exit 0.
- Added `ISSUE_SALES_ORDERS_ATOMIC` and `ISSUE_SALES_ORDERS_ATOMIC_UOM` to stage
  one movement-231 document per distinct sales order and commit the group once.
  Movement and commit failures roll back provisional results; UOM conversion
  validates the full request before staging. Tests cover group success,
  movement and commit rollback, special-stock E, converted quantities, and
  invalid-unit prevalidation. Target SAP LUW behavior is recorded in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added `ISSUE_PROD_ORDERS_ATOMIC` and `ISSUE_PROD_ORDERS_ATOMIC_UOM` for
  group-wide movement-261 issue across distinct production orders. The service
  validates every order and line before staging, converts all UOM lines before
  staging, and rolls back provisional results when a movement or shared commit
  fails. Tests cover success, movement and commit rollback, converted
  quantities, and invalid-unit prevalidation. Repeated-call SAP LUW behavior is
  recorded in `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134
  files, successful transpilation, and ABAP Unit exit 0.
- Added `TRANSFER_SALES_STOCK_BULK` and `TRANSFER_SALES_STOCK_ATOMIC` for
  movement-411/E transfers from sales-order stock to own stock across distinct
  sales documents, with UOM variants. Bulk mode commits each order separately
  and continues after a posting failure; atomic mode stages all orders and
  commits once, clearing provisional document results after movement or commit
  failure. Tests cover mapping, continuation, shared commit and rollback,
  converted quantities, and invalid-unit prevalidation. SAP LUW and eligibility
  checks are noted in `ANOMALIES.md`. `npm test` passed with 0 abaplint issues
  across 134 files, successful transpilation, and ABAP Unit exit 0.
- Added grouped movement-413/E transfers from own stock into sales-order stock:
  `TRANSFER_TO_SALES_STOCK_BULK`, `TRANSFER_TO_SALES_STOCK_ATOMIC`, and their
  UOM forms. Bulk mode commits independently and continues after a failed order;
  atomic mode stages one document per order and rolls back on movement or commit
  failure. Tests cover mapping, continuation, atomic commit and rollback,
  converted quantities, and full-request invalid-unit rejection. Target SAP LUW
  and eligibility checks are in `ANOMALIES.md`. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit exit
  0.
- Added UOM-aware production receipts for single orders and multi-order bulk
  and atomic posting. The service requires material identity for conversion,
  applies caller-supplied base-unit/ISO mappings, and preserves optional batch,
  location, and co-product item fields. Multi-order UOM methods convert the
  full request before posting. Tests cover the single, bulk, and atomic mappings
  and reject an unsupported later unit before any movement. Target ratio,
  rounding, and BAPI unit behavior are recorded in `ANOMALIES.md`. `npm test`
  passed: 0 abaplint issues across 134 files, transpilation succeeded, and ABAP
  Unit exited 0.
- Added UOM-aware purchase-order receipts for single, bulk, and atomic flows.
  The service converts each material quantity to the mapped base unit while
  preserving PO item, plant, storage location, and batch fields. Bulk and
  atomic forms convert and validate the complete request before posting. Tests
  cover all three entry points and reject an unsupported later unit before any
  receipt call. PO-unit, open-quantity, and rounding checks are recorded in
  `ANOMALIES.md`. `npm test` passed: 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added `ISSUE_STO_UOM` and `RECEIVE_STO_UOM` for alternative-unit STO goods
  issue and receipt. Both prevalidate material mappings and all lines, convert
  quantities to mapped base units, and preserve PO item, batch, and plant/
  storage-location data. Tests verify 351/101 movement mapping and reject a
  later unsupported unit before any BAPI call. Target STO item-unit and
  remaining-quantity behavior is recorded in `ANOMALIES.md`. `npm test` passed
  with 0 abaplint issues across 134 files, successful transpilation, and ABAP
  Unit exit 0.
- Added grouped cost-center issue APIs. Bulk mode prevalidates all distinct
  cost centers and lines, commits once per center, and continues after errors;
  its UOM form converts all quantities before posting. Atomic mode stages all
  center documents and shares one commit, with rollback and provisional-result
  clearing after movement or commit failure. Tests cover unit conversion,
  invalid later units, and both rollback paths. Target LUW limits are recorded
  in `ANOMALIES.md`.
- Added grouped cost-center return APIs for movement 202. Bulk and atomic forms
  mirror the issue transaction scopes, with UOM variants converting the full
  request before posting. The result preserves per-center outcomes, and atomic
  failures clear staged document identifiers after rollback. Tests cover the
  movement mapping, per-center continuation, conversion, invalid later units,
  and both rollback paths. `npm test` passed with 0 abaplint issues across 134
  files, successful transpilation, and ABAP Unit exit 0.
- Added typed PO vendor returns with movement 122: single, bulk, atomic, and
  UOM-aware entry points. Bulk mode commits each PO independently; atomic mode
  shares one commit and clears provisional document identifiers on failure.
  UOM forms convert the full request before posting. Tests cover mapping,
  conversion, continuation, prevalidation, and rollback. Target PO eligibility
  and LUW behavior are recorded in `ANOMALIES.md`. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added material-to-material transfer posting with movement 309 and an
  alternative-unit form. The service carries source and receiving materials,
  optional receiving plant/location and batch, converts source quantities to
  base units, and requires matching base-unit/ISO mappings for both materials.
  Movement-309 target-system and catch-weight limitations are recorded in
  `ANOMALIES.md`. `npm test` passed with 0 abaplint issues across 134 files,
  successful transpilation, and ABAP Unit exit 0.
- Added direct material-to-material LIFO posting with movement 310 and a UOM
  form. Both entry points share the 309 validation and preserve receiving
  plant/location and batch fields; UOM quantities convert to the matched
  source/receiving base unit. SAP's direct-MIGO LIFO description and the API
  posting-path caveat are recorded in `ANOMALIES.md`. `npm test` passed with 0
  abaplint issues across 134 files, successful transpilation, and ABAP Unit
  exit 0.
- Added an optional exact batch to multi-demand cost-center FEFO previews. The
  selected batch remains subject to the same effective expiry and shelf-life
  checks, and other batches cannot fill its shortfall. Tests cover a partial
  allocation with another eligible batch available. `npm test` passed with 0
  abaplint issues across 136 files, successful transpilation, and ABAP Unit
  exit 0; validation details are in `ANOMALIES.md`.
- Extended atomic cost-center FEFO reservations to accept an optional exact
  batch on individual demand rows while other rows continue normal FEFO. The
  full group still preallocates before creating reservations. `npm test` passed
  with 0 abaplint issues across 136 files, successful transpilation, and ABAP
  Unit exit 0; SAP stock and reservation behavior remains documented in
  `ANOMALIES.md`.
- Extended single cost-center FEFO preview and reservation to accept an exact
  batch filter. `iv_batch_min_days` can further raise that selected batch's
  minimum remaining shelf life; FEFO still applies the later effective date.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
- Extended sales-order FEFO with partial exact-batch selections. Selected items
  or schedule lines stay on their chosen batch; unselected demand still follows
  FEFO, and per-selection shelf-life requirements combine with FEFO minimums.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
- Extended bulk cost-center FEFO to honor an optional exact batch per demand,
  forwarding the filter through the atomic per-demand allocation path. The
  selected lot still must meet the effective expiry date. `npm test` passed
  with 0 abaplint issues across 136 files, successful transpilation, and ABAP
  Unit exit 0.
- Extended `ALLOCATE_LOCATION_BY_DATE_UOM` and
  `ALLOCATE_LOCATION_DATE_UOM_ATP` with the same caller-resolved projected
  location receipts accepted by the base-unit APIs. Demand quantities convert
  through cached material UOM ratios; receipt quantities stay in base units,
  and both results preserve caller order. Regression coverage checks receipt
  date validation before reads, source/base-unit splits, location selection,
  safety-stock replenishment, duplicate-request rejection before repository
  reads, and cumulative ATP checks. `npm test` passed with 0 abaplint issues
  across 136 files, successful transpilation, and ABAP Unit exit 0. Validation
  notes are in `ANOMALIES.md`.
- Extended `ALLOCATE_PLANTS_BY_DATE_LOC`, its UOM wrapper, and its ATP preview
  with caller-resolved location receipts in material base units. Receipts are
  source-plant scoped, become available on their date, replenish any remaining
  static safety-stock buffer, and retain source-location filtering. Regression
  tests cover date ordering, late receipt availability, location splits,
  safety-stock protection, invalid-date rejection before reads, UOM conversion,
  and ATP requests. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Target-system limitations are
  in `ANOMALIES.md`.
- Extended dated cross-plant FEFO allocation, its UOM wrapper, and its ATP
  preview with caller-resolved projected batch receipts in material base units.
  Receipts enter the shared FEFO balance on their receipt date and keep the
  existing expiry, shelf-life, location-filter, and safety-stock behavior.
  Regression coverage checks date gating, safety-stock replenishment, UOM
  quantities, ATP forwarding, and invalid receipt dates before stock reads.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0.
  Callers provide the receipt's source plant, location, batch, expiry, and
  quantity; the service does not derive or confirm those assignments from SAP
  planning documents. Details and target-system caveats are in `README.md` and
  `ANOMALIES.md`.
- Extended the as-of-date cross-plant FEFO snapshot, its unit-aware wrapper, and
  its ATP preview with the same caller-resolved batch receipts. Receipts dated
  on or before the snapshot date join its balances before safety-stock
  protection; later receipts are ignored. Regression coverage checks the
  snapshot cutoff, FEFO splits, safety-stock handling, base-unit conversion,
  ATP request totals, and invalid dates before stock or UOM reads. `npm test`
  passed with 0 abaplint issues across 136 files, successful transpilation, and
  ABAP Unit exit 0. Callers still provide the snapshot quantity and SAP ATP does
  not receive the batch assignments; details are in `README.md` and
  `ANOMALIES.md`.
- Extended single-plant FEFO allocation, its unit-aware wrapper, and its ATP
  preview with caller-resolved dated batch receipts. Per-demand as-of dates
  gate receipt availability even when demands are processed out of date order,
  and due receipts replenish a remaining static safety-stock buffer before
  allocation. Regression coverage checks date gating, buffer replenishment,
  UOM conversion, ATP forwarding, and invalid receipt rejection before UOM
  reads. `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Target-system limits are in
  `README.md` and `ANOMALIES.md`.
- Extended quality-stock FEFO, its UOM wrapper, and ATP comparison with
  caller-resolved projected batch receipts interpreted as future
  quality-inspection stock. Receipts follow per-demand as-of dates and retain
  expiry, location, and batch filters. Tests cover receipt cutoff, unit
  conversion, ATP forwarding, and bad-date rejection before UOM or stock reads.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Target stock-category and ATP limits are
  recorded in `ANOMALIES.md`.
- Extended exact-batch allocation, its UOM wrapper, and ATP preview with
  caller-resolved projected batch receipts. Receipt availability follows each
  demand's as-of date, and due receipts replenish the residual static
  safety-stock buffer before allocation. Regression coverage checks cutoff,
  safety-stock, UOM, ATP, and pre-UOM date validation. `npm test` passed with 0
  abaplint issues across 136 files, successful transpilation, and ABAP Unit exit
  0. Target-system limits are recorded in `README.md` and `ANOMALIES.md`.
- Extended cross-plant exact-batch allocation, date-prioritized allocation,
  their UOM wrappers, and ATP previews with caller-resolved projected batch
  receipts in material base units. Receipt quantities enter the mapped source
  plant/batch balance on their receipt date, using each demand's `as_of_date`
  or `required_date` as its cutoff. Due receipts replenish a remaining static
  safety-stock buffer. Regression coverage checks current-date and dated
  cutoffs, date ordering, unit conversion, and invalid source mapping before
  UOM reads. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. SAP routing, receipt, and ATP
  behavior limits are in `README.md` and `ANOMALIES.md`.
- Added per-demand `minimum_shelf_life_days` to cross-plant exact-batch
  allocation, date-prioritized demands, UOM conversions, and ATP previews.
  The base demand form requires an explicit as-of date for positive minimums;
  the undated UOM wrapper uses today and date-aware wrappers use
  `required_date`. Positive minimums reject unknown or too-near expiry and
  filter both availability totals and source/location splits.
  Regression coverage checks the expiry boundary and the date ATP/UOM
  propagation. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. SAP batch master and ATP
  behavior limits are in `README.md` and `ANOMALIES.md`.
- Added `iv_include_undated_batches` to single- and cross-plant exact-batch
  allocation, including date-prioritized, UOM, and ATP wrappers. Its default
  keeps existing behavior; setting it false excludes current stock and
  projected receipts without a known expiry from availability and allocation
  splits. Invalid flag values fail before UOM or stock reads. Regression
  coverage checks both current and projected undated batches, wrapper
  forwarding, ATP suppression for excluded stock, and pre-read validation.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Target expiry-data and ATP limits are in
  `README.md` and `ANOMALIES.md`.
- Added `iv_include_undated_batches` to cost-center exact-batch and FEFO
  previews, atomic and bulk reservations, and single-demand preview/reservation.
  The default preserves inclusion of batches with unknown expiry; setting the
  flag false removes them from available quantity and selected splits. Tests
  cover batch and FEFO selection and option forwarding across reservation
  entry points. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Target metadata and ATP
  limits are recorded in `README.md` and `ANOMALIES.md`.
- Added `iv_require_full_quantity` to cost-center plant, dated, location,
  exact-batch, and FEFO multi-demand previews. Short demands now receive zero
  allocation under this option, leaving the remaining balance available for
  later requests; dated ATP previews apply the same local rule while retaining
  separate SAP diagnostics. Regression coverage exercises every preview path
  and both dated ATP modes. `npm test` passed with 0 abaplint issues across 136
  files, successful transpilation, and ABAP Unit exit 0. The snapshot and
  concurrency limits are documented in `ANOMALIES.md`.
- Added `iv_require_full_quantity` to sales-order FEFO previews in base and
  alternative units. An underfilled request receives zero allocation and does
  not consume eligible item stock, allowing a later smaller request to use the
  balance. The option is validated before stock reads and defaults to the
  existing partial behavior. Regression coverage includes repeated base-unit
  and UOM requests. `npm test` passed with 0 abaplint issues across 136 files,
  successful transpilation, and ABAP Unit exit 0. Snapshot and locking limits
  are recorded in `README.md` and `ANOMALIES.md`.
- Extended `iv_require_full_quantity` to aggregate sales-order issue previews
  in base and alternative units. Underfilled requests now receive zero
  coverage without consuming the shared item/cutoff balance. Tests verify a
  later smaller request can use that balance, including after UOM conversion.
  `npm test` passed with 0 abaplint issues across 136 files, successful
  transpilation, and ABAP Unit exit 0. Snapshot limits remain in
  `ANOMALIES.md`.
- Added `preview_cost_center_fefo_date` for date-prioritized batch previews.
  Earlier required dates consume shared stock first, descending integer
  priority breaks same-date ties, and input order is stable for equal keys.
  Results return in caller order and echo each date and priority; expiry checks
  use the latest of shared as-of, row FEFO as-of, and required date. Regression
  coverage checks date/priority allocation, caller-order results, and rejection
  of invalid dates before stock reads. `npm run lint` reported zero issues,
  and `npm run unit` completed transpilation and ABAP Unit with exit 0. The
  combined `npm test` launcher hits a WSL 1 nested-Node error, so its two
  constituent scripts were run separately.
- Added `reserve_cc_fefo_date_atomic`, which applies required-date and
  descending-priority order to the existing preallocate/create/commit flow and
  returns result items in caller order. Its regression checks allocation order,
  same-date priority, caller-order results with echoed date/priority, and
  test-run behavior. `npm run lint` reported zero issues, and `npm run unit`
  completed transpilation and ABAP Unit with exit 0. Validate the local snapshot
  and concurrency limits in `ANOMALIES.md`.
- Added `reserve_cc_fefo_date_bulk`, which runs independent FEFO reservations
  in required-date and descending-priority order, then returns item rows in
  caller order with echoed date/priority. Regression coverage checks call
  ordering, output ordering, and invalid-date rejection before stock reads. The
  bulk method keeps per-demand commit behavior, so earlier successful calls
  remain committed after a later failure. `npm run lint` reported zero issues,
  and `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added opt-in required-date/priority ordering to aggregate sales-order stock
  issue previews in base and alternative units. Earlier dates consume repeated
  item/cutoff balances first, higher priorities run first within a date, and
  equal keys preserve input order. Results return in caller order and echo date
  and priority; invalid required dates are rejected before repository reads.
  `npm run lint` reported zero issues and `npm run unit` completed transpilation
  and ABAP Unit with exit 0. The reservation cutoff remains independent from
  demand ordering; the snapshot limit is recorded in `ANOMALIES.md`.
- Extended FEFO sales-order stock issue previews in base and alternative units
  with the same optional date/priority ordering. A demand's required date raises
  its expiry cutoff, so earlier requests can use a batch that expires before a
  later demand; result summaries and splits return in caller order. Regression
  coverage checks batch eligibility by row date, priority, UOM conversion, and
  invalid-date rejection before reads. `npm run lint` reported zero issues and
  `npm run unit` completed transpilation and ABAP Unit with exit 0.
- Added opt-in priority handling to cost-center FEFO atomic and bulk reservations.
  Atomic allocation and create calls now process higher integer priorities
  first while keeping result rows and API responses attached to caller-order
  requests. Bulk reservation calls run independently in priority order and
  restore caller order afterward. Invalid flags and priority mode on unbatched
  non-FEFO requests are rejected before stock reads. Tests verify FEFO batch
  assignment, create-call order, result order, and priority echo. `npm run lint`
  reported zero issues across 138 files; `npm run unit` completed transpilation
  and ABAP Unit with exit 0. Stock snapshot and concurrency limits are in
  `ANOMALIES.md`.
- Added the same priority option to explicit-batch cost-center previews and
  reservation flows. Shared stock for the selected batch is allocated by
  descending priority with stable input-order ties; atomic and bulk create calls
  follow that order while returning results in caller order. Unbatched requests
  cannot enable priority mode. Regression tests cover shared batch/location
  allocation, API dispatch order, echoed priority, and response mapping.
  `npm run lint` reported zero issues across 138 files, and `npm run unit`
  completed transpilation and ABAP Unit with exit 0. The snapshot and SAP
  reservation visibility limits are recorded in `ANOMALIES.md`.
- Split automatic projected-receipt previews by material/plant pair: a pair with
  any selected receipt missing its receiving location now falls back to the
  plant-level allocator without disabling scoped allocation for other pairs.
  Each pair still queries only through its latest component required date.
  Added stock and ATP regressions for a missing-location receipt beside a
  scoped pair with a later out-of-horizon receipt. Updated README and anomaly
  notes to match. `abaplint` reported zero issues across 138 files;
  transpilation and `validate:plan` passed; ABAP Unit passed all 1,869 cases;
  `git diff --check` passed with CRLF handling.
- Expanded `validate:plan` to derive every SAP `table~field` used by the stock
  repository and verify that the corresponding local table stub declares it.
  This now covers the receipt-source queries alongside the explicit MARD,
  RESB, PO, confirmation, production, requisition, and planned-order checks.
  All referenced fields were already present in the stubs. README development
  instructions now describe the validator.
- Added a multi-pair repository read for confirmation-aware purchase-order
  receipts. It fetches schedule remainders and MRP-relevant confirmations in
  two queries across all requested pairs, filters each pair to its own maximum
  deadline, and returns request rows in caller order. Shared-flag, per-request
  option, and UOM bulk projections now use that path. Local tests cover horizon
  filtering and verify that the service dispatches one repository bulk call;
  live EKET/EKES joins remain a target-system validation item. `abaplint` found
  zero issues across 138 files, PLAN validation passed, transpilation succeeded,
  and all 1,869 ABAP Unit cases passed. `git diff --check` passed with CRLF
  handling.
- Applied the per-material/plant deadline inside both FAE statements, so a
  longer horizon for one pair does not widen another pair's database read.
  Extended `validate:plan` to require those EKET and EKES deadline predicates.
  PLAN validation, abaplint, transpilation, all 1,869 ABAP Unit cases, and the
  CRLF-aware diff check passed. SAP execution of the joins remains unverified.
- Extended the repository bulk projection to batch purchase-order,
  scheduling-agreement, STO, production, requisition, and planned-order reads
  across unique material/plant scopes. Each FAE query now uses that pair's own
  maximum deadline; results are trimmed to each request cutoff and returned in
  caller order. The plan validator checks source-query counts, batching, date
  bounds, and service delegation. Regression coverage verifies one bulk
  repository dispatch alongside request ordering and cutoff filtering.
  `validate:plan` passed, abaplint reported zero issues across 138 files,
  transpilation passed, and all 1,869 ABAP Unit cases passed. SAP execution of
  the receipt joins and query plans remains unverified.
- Batched `GET_PROJ_RECEIPTS_OPTS_BULK` by matching material/plant source
  selections, while keeping PO confirmations on their separate bulk path. Each
  pair still queries only through its own latest request date, and each result
  retains its per-request source and date filters. Regression coverage checks
  that different pairs with the same combined source selection use one
  repository bulk dispatch. `validate:plan` passed, abaplint reported zero
  issues across 138 files, transpilation passed, all 1,869 ABAP Unit cases
  passed, and the CRLF-aware diff check passed. SAP query execution remains
  unverified.
- Added `get_available_stock_date_bulk` and switched dated demand allocation to
  fetch unique material/plant/date availability scopes together. The repository
  batches MARD stock, cutoff-scoped RESB rows, PO/STO schedules, outgoing STOs,
  and production receipts, and reuses the projected-receipt bulk path for PR,
  planned-order, and scheduling-agreement sources. The service still applies
  PO confirmations and safety stock per cutoff before sharing balances. Tests
  verify allocation output, duplicate-scope caching, and one bulk dispatch.
  `validate:plan` now checks batch scopes, per-request date predicates, and
  selected row keys that prevent duplicate FAE rows from collapsing. abaplint
  reported zero issues across 138 files, transpilation passed, all 1,869 ABAP
  Unit cases passed, and the CRLF-aware diff check passed. Target SAP SQL checks
  remain open.
- Extended the same dated availability batch to `ALLOCATE_PLANTS_BY_DATE`.
  Candidate source-plant/date scopes are deduplicated across all demands, read
  together, then combined with cutoff-specific PO confirmations and cached
  safety stock before source balances are allocated. Regression coverage checks
  one repository bulk dispatch across four source-plant/date scopes. abaplint
  reported zero issues across 138 files, transpilation passed, all 1,869 ABAP
  Unit cases passed, and the CRLF-aware diff check passed. Target SAP SQL
  behavior remains unverified.
- Changed `ALLOCATE_PLANTS_FEFO_BY_DATE` to fetch batch status for all unique
  material/source-plant pairs in one validated bulk repository call. The
  service keeps positive-quantity filtering, safety-stock protection, source
  location rules, projected receipts, and existing FEFO ordering. Added a
  regression assertion for one bulk dispatch despite repeated demands sharing
  a pair, and added a plan-validator check that prevents reintroducing the
  per-pair read. Target SAP query-plan and reservation-subtraction behavior
  remain to be checked.
- Applied the same bulk batch-status read to `ALLOCATE_PLANTS_BY_EXPIRY`. It
  retains caller-ordered source plants, date eligibility, receipt handling,
  location rules, and safety-stock behavior while deduplicating current-stock
  reads by material/source-plant pair. The FEFO regression now checks one bulk
  dispatch across repeated demands. `validate:plan` checks both cross-plant
  FEFO entry points for bulk dispatches; SAP query-plan and reservation
  subtraction behavior remain unverified. Verification after both FEFO changes:
  plan validation passed, abaplint reported zero issues across 138 files,
  transpilation passed, and all 1,869 ABAP Unit cases passed.
- Changed `ALLOCATE_PLANTS_BY_BATCH` to load all unique material/source-plant
  batch statuses through one validated bulk call. Dated, undated, and unit-aware
  wrappers inherit the single dispatch while preserving exact-batch matching,
  cutoff ordering, projected receipts, and safety-stock behavior. Added bulk
  dispatch assertions and extended `validate:plan` to catch per-pair reads.
  `validate:plan` passed, abaplint reported zero issues across 138 files,
  transpilation passed, and all 1,869 ABAP Unit cases passed. Target SAP query
  plans and reservation subtraction still need review.
- Batched current stock in the single-plant `ALLOCATE_BY_BATCH` preview after
  validating all demands and receipt options. The allocator fetches each unique
  material/plant batch status once, then preserves its existing batch, date,
  location, receipt, and safety-stock calculations. Added bulk-dispatch coverage
  for multiple requests sharing one pair and extended `validate:plan` to reject
  the per-pair read. Updated cost-center and sales-order test doubles to return
  configured batch stock from the bulk API. `validate:plan` passed, abaplint
  reported zero issues across 138 files, transpilation passed, and all 1,869
  ABAP Unit cases passed. Target SAP query plans and reservation subtraction
  still need review.
- Changed single-plant `ALLOCATE_BY_EXPIRY` to fetch all unique material/plant
  batch statuses in one validated bulk call after demand and receipt validation.
  Positive stock filtering and existing FEFO, location, shelf-life, receipt,
  and safety-stock behavior are unchanged. Added a wrapper regression assertion
  and extended `validate:plan` to prevent the per-pair read. Updated the
  quality-stock test double to model unrestricted batch reads and rechecks
  separately from quality stock. `validate:plan` passed, abaplint reported zero
  issues across 138 files, transpilation passed, and all 1,869 ABAP Unit cases
  passed. Target SAP query plans and reservation subtraction still need review.
- Batched scoped component reads for location stock, batch stock, open
  reservations, and protected safety stock. `ALLOCATE_COMPONENT_STOCK`
  deduplicates material/plant scopes before dispatch and maps validated
  responses into the existing per-scope balance logic. The MARD adapter reads
  eligible RESB rows and MARC safety stock through guarded `FOR ALL ENTRIES`
  queries; safety stock is read only when protection is enabled. The RESB query
  retains the single-scope filters for special stock, deletion, final issue,
  and open quantity. A two-plant regression checks four dispatches and
  allocation results. Also batched safety-stock reads in single-plant exact
  batch, single-plant FEFO, and dated and undated cross-plant FEFO and exact
  batch allocation; two-scope regressions verify one safety dispatch for each
  allocator and preserve their allocations. `validate:plan` guards service and
  repository paths. Plan validation passed, abaplint reported zero issues across
  138 files, transpilation passed, all 1,871 ABAP Unit cases passed, and the
  CRLF-aware diff check passed. Target SAP query plans and reservation
  visibility remain unverified.
- Replaced per-scope location reads in `ALLOCATE_ACROSS_PLANTS`,
  `ALLOCATE_BY_STORAGE_LOCATION`, and the projected-receipt path of
  `ALLOCATE_LOCATION_BY_DATE` with one validated
  `GET_LOCATION_STOCK_STATUS_BULK` dispatch across unique material/plant pairs.
  The repository already applies the same reservation-adjusted location
  quantity calculation as the former single-pair method. Safety stock is also
  fetched once per allocator, then consumed across locations before projected
  receipts are applied. Regressions cover two-scope dispatch counts and
  existing allocation outputs; `validate:plan` guards both bulk paths.
  Plan validation passed, abaplint reported zero issues across 138 files,
  transpilation passed, all 1,871 ABAP Unit cases passed, and the CRLF-aware
  diff check passed.
- Added SQLite-backed Open SQL integration cases for bulk MARC safety stock,
  eligible RESB reservations and open quantities, and reservation-adjusted MARD
  location balances. `scripts/run-unit.mjs` configures the default SQLite
  connection and test schemas before the generated ABAP Unit runner starts.
  `validate:plan` passed, abaplint found 0 issues across 139 files,
  transpilation passed, and all 1,874 ABAP Unit cases passed. Target SAP DDIC,
  query-plan, and live reservation-visibility checks remain outstanding.

- Extended SQLite-backed adapter coverage to batch stock. The new case executes
  the MCHB, MCHA, MCH1, and RESB query paths, checking plant expiry precedence,
  global expiry fallback, duplicate scope results, stock categories, and both
  specific and unassigned reservation deductions. Full `npm test` passed:
  plan validation, 0 abaplint issues across 139 files, transpilation, and all
  1,875 ABAP Unit cases. Target SAP checks remain recorded in `ANOMALIES.md`.

- Added SAP import scaffolding: `.abapgit.xml` points abapGit at `/src/`,
  `src/package.devc.xml` defines the installable package, and all 67 classes and
  29 interfaces now have object metadata. Added `npm run generate:abapgit` for
  new objects and plan validation that checks metadata coverage and unit-test
  flags. README now documents package assignment and SAP-side activation checks.
  Metadata follows abapGit's documented XML shape; a target SAP import remains
  unverified.
  `npm run generate:abapgit` reports no missing files on a second run. `npm test`
  passes with 0 abaplint issues across 236 files, successful transpilation, and
  all 1,875 ABAP Unit cases; all 98 abapGit XML files parse and the diff check
  is clean. Target SAP import and activation remain unverified.

- Hardened the public batch-eligibility check to validate the as-of date and every dated expiry as Gregorian dates before date comparison. Invalid calendar dates now raise `zcx_invalid_stock_request`; blank expiry remains the supported undated-batch representation. Added ABAP Unit cases for an impossible as-of date and expiry. Full `npm test` passed: plan validation, 0 abaplint issues across 236 files, transpilation, and all 1,877 ABAP Unit cases.

- Hardened projected-supply quantity calculators against negative receipt,
  ordered, issue, and MRP-reduction counters. Invalid negative counters now
  yield zero projected quantity instead of inflating open supply; valid
  partial quantities and unit conversion are unchanged. Added regression
  coverage for PO schedule, PO confirmation, unissued STO, PR, and
  production-order calculations. Full `npm test` passed: plan validation,
  0 abaplint issues across 236 files, transpilation, and 1,880 ABAP Unit
  cases.

- Added SQLite-backed Open SQL coverage for `ZCL_MATERIAL_UOM_REPOSITORY`: MARA base-unit reads, MARM alternative unit ratios keyed by material and unit, and missing-row results. Extended the runner schema and PLAN validation for required MARA/MARM fields, and added MANDT to both client-dependent table stubs. Full `npm test` passed with 0 abaplint issues across 237 files and all 1,884 ABAP Unit cases. Target SAP DDIC behavior remains to be checked.

- Added SQLite-backed Open SQL tests for `ZCL_MARC_REPL_POLICY_REPO`, covering MARC policy selection, required MARA base units, optional T001W/T399D values, missing materials, and RDPR profile levels. Reworked the join into batched reads and kept RDPR fields unqualified to avoid malformed FAE SQL generated by the local transpiler. Updated the local schema, PLAN checks, README, and target-SAP caveats. Full `npm test` passed: PLAN validation, 0 abaplint issues across 238 files, transpilation, and all 1,886 ABAP Unit cases. Target SAP DDIC and SQL behavior remain to be checked.

- Added SQLite-backed Open SQL coverage for `ZCL_T439I_CAL_PERIOD_REPO`. The test checks inclusive overlap at both horizon boundaries and filters out rows for other plants, calendars, and dates. Kept query fields unqualified for correct local FAE code generation. Added the T439I schema and required stub fields to PLAN validation; updated the README and target-SAP caveat. Full `npm test` passed: PLAN validation, 0 abaplint issues across 238 files, transpilation, and all 1,887 ABAP Unit cases. Target SAP T439I behavior remains unverified.

- Added SQLite-backed tests for `ZCL_PLAF_ORDER_READ_REPO` covering order selection and sorting, base units, alternative-unit ratios, and left-join behavior when MARA or MARM data is missing. Replaced the alias-qualified join with batched PLAF/MARA/MARM reads to keep local FAE generation correct. Added client field `MANDT` to the PLAF stub, extended its PLAN checks and local SQLite schema, and documented the coverage. Full `npm test` passed: PLAN validation, 0 abaplint issues across 239 files, transpilation, and all 1,889 ABAP Unit cases. Target SAP DDIC and SQL behavior remain to be checked.

- Added SQLite-backed tests for `ZCL_PROD_COMP_REPO` that execute the RESB bulk query and single-order wrapper, verify reservation-item ordering and component mapping, and ensure deleted/final-issue rows remain available to downstream service logic. Added its required source artifact to PLAN validation and documented the SQL coverage. Full `npm test` passed: PLAN validation, 0 abaplint issues across 240 files, transpilation, and all 1,891 ABAP Unit cases. Target SAP RESB behavior remains unverified.

- Added SQLite-backed SQL coverage for `ZCL_STOCK_TRANSFER_REPOSITORY`: plant-level transfer totals, all-location and exact-location balances, nonzero location/batch detail reads, the ordered single-batch query, and empty bulk guards. Added required MARC/MARD/MCHB field checks to PLAN validation and updated the local SQL coverage notes. Full `npm test` passed: PLAN validation, 0 abaplint issues across 241 files, transpilation, and all 1,894 ABAP Unit cases. Target SAP transfer-stock behavior remains unverified.

- Strengthened PLAN validation after finding that unqualified SQL field names bypassed its `table~field` scan. The validator now checks typed SAP table-field references in every custom ABAP source against the local DDIC stubs, while retaining explicit checks for query-required fields. Full `npm test` passed: PLAN validation, 0 abaplint issues across 241 files, transpilation, and all 1,894 ABAP Unit cases.

- Added SQLite-backed tests for `ZCL_SO_STOCK_REPOSITORY` covering order-item resolution, base-unit reads, MSKA stock filtering and MARA-required rows, plant/global expiry precedence, RESB open-reservation filters, and empty-request guards. Reworked the stock join into batched MSKA/MARA reads while preserving its inner-join behavior. Added MANDT to the VBAP stub and query-field validation/schema, including KWMENG and VSMNG in the runner’s VBAP DDL for test-environment inserts. Full `npm test` passed: PLAN validation, 0 abaplint issues across 242 files, transpilation, and all 1,898 ABAP Unit cases. Target SAP DDIC and SQL behavior remain to be checked.
- Added SQLite-backed Open SQL tests for `ZCL_SALES_ORDER_DELIVERY_REPO`, checking ordered schedule lines, requested and material-availability dates, ordered/confirmed/delivered quantities, status presence, multi-document selection, VBAP fallback for items without schedule lines, the single-document wrapper, and empty input. Added client/key metadata to VBUP and local VBEP/VBUP schemas, and expanded PLAN validation and integration notes. Full validation passed: PLAN validation, 0 abaplint issues across 243 files, transpilation, and all 1,900 ABAP Unit cases. Target SAP query behavior remains to be checked.
- Added SQLite-backed Open SQL tests for `ZCL_CC_RESERVATION_READ_REPO`, covering RESB/RKPF cost-center scope, movement and status filters, remaining quantity, sort order, the single-center wrapper, item-scope lookup, and empty requests. Reworked the join into batched header and item reads to avoid malformed local transpiler join/FAE SQL while preserving inner-join behavior; moved the remaining-quantity comparison into the merge loop. Added RKPF schema and PLAN field checks, and updated the SQL coverage caveat. Full `npm test` passed: PLAN validation, 0 abaplint issues across 244 files, transpilation, and all 1,903 ABAP Unit cases. Target SAP query plans and authorization remain to be checked.
- Added SQLite-backed Open SQL coverage for all five `ZCL_PROJECT_STOCK_REPOSITORY` methods. Tests cover MSPR positive-Q stock selection by key and WBS, PRPS mapping, plant-first/global-fallback expiry, open RESB quantity filters and calculations, and final-issue/fully withdrawn reservation-item visibility. Reworked aliased joins as batched PRPS/MSPR and PRPS/RESB reads while preserving WBS and lifecycle filters; moved the two-column open-quantity comparisons into ABAP. Added MSPR/PRPS schemas and PLAN field checks and updated target-system notes. Full `npm test` passed: PLAN validation, 0 abaplint issues across 245 files, transpilation, and all 1,908 ABAP Unit cases. Target SAP query plans and DDIC behavior remain unverified.
- Added SQLite-backed Open SQL tests for all six `ZCL_REPL_SOURCE_REPO` methods, covering purchasing info records across exact and global plants, source-list agreement joins and source contexts, quota headers/items, rounding levels, usage rules, and empty-input guards. Corrected the local EINA MATNR stub to match the 40-character material type used by the repository, replaced broad reads with explicit field lists, keyed EINE reads by info record/org/plant, and changed source-context FAE selects to unqualified fields. Expanded SQLite schemas, PLAN field/shape checks, class test metadata, and integration notes. Full `npm test` passed: PLAN validation, 0 abaplint issues across 246 files, transpilation, and all 1,915 ABAP Unit cases. Confirm the EINA material-number length and source/quota data semantics against the target SAP release.
- Added SQLite-backed Open SQL tests for all four `ZCL_PROD_ORDER_READ_REPO` methods, covering AFPO item mapping and sorting, active JEST status filtering with TJ02T/TJ30T text, AFRU/AFVC confirmation joins and ordering, AFKO/AFVC operation mapping, category filters, and empty input. Replaced multi-table joins with narrow batched reads and ABAP key merges after local tests returned no rows from the aliased joins; added the SQLite schemas, required PLAN stub fields, and class test metadata. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,920 ABAP Unit cases. Target SAP DDIC fields, status semantics, and operation-key behavior remain unverified.

- Added SQLite-backed Open SQL coverage for bulk projected purchase-order
  receipts. The test exercises narrow EKPO/EKKO/MARA/EKET reads and key merges,
  including open-item filters, schedule cutoffs, partial receipt netting, and
  PO-unit conversion. Reworked the joined PO receipt read into guarded batched
  selects after the local transpiler returned no joined rows, and updated PLAN
  validation to accept item-key deadlines derived from material/plant scopes.
  Updated README and ANOMALIES coverage notes. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,921
  ABAP Unit methods. Target SAP DDIC and schedule semantics remain unverified.

- Added SQLite-backed coverage for the bulk scheduling-agreement receipt
  path and replaced its alias-qualified EKET/EKPO/EKKO/MARA join with guarded
  batched reads and keyed merges. The test verifies the blank supplying-plant
  rule, category and item filters, schedule cutoffs, quantity conversion, and
  source metadata. PLAN validation accepts the derived item-deadline keys.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,922 ABAP Unit methods. Target SAP field and schedule
  behavior remain unverified.

- Added SQLite-backed coverage for bulk STO projected receipts and replaced
  the alias-qualified EKET/EKPO/EKKO/MARA join with guarded batch reads and
  keyed merges. Tests exercise both issued-minus-received in-transit supply
  and scheduled-minus-issued supply, PO-unit conversion, per-request dates,
  document categories, supplying-plant and transport-document rules, and
  item deletion, statistical, account-assignment, returns, GR, and inspection
  stock filters. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,923 ABAP Unit methods. Target SAP
  transfer-order lifecycle and DDIC behavior remain unverified.

- Added SQLite-backed Open SQL coverage for the bulk confirmation-aware PO
  receipt repository. The join-based EKET/EKPO/EKKO/MARA and
  EKES/EKPO/EKKO/MARA reads now use guarded item, header, material, schedule,
  and confirmation batches merged by document/item keys. Coverage checks
  schedule and confirmation MRP reductions, KZDIS/deletion filters, eligible
  PO/header rows, unit conversion, and per-request deadlines. Updated PLAN
  validation, SQLite schema, README, and ANOMALIES. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,924 ABAP Unit methods. Target SAP confirmation semantics remain to be
  checked.

- Added SQLite-backed coverage for standard and stock-transfer purchase
  requisition projections. Replaced alias-qualified EBAN/MARA/MARM joins with
  separate guarded EBAN reads plus MARA/MARM batches merged by material and
  requisition unit. The merge applies open-quantity and STO supplying-plant
  comparisons, preserves the MARA-required and optional-MARM behavior, and
  combines the two EBAN results without the local FAE `APPENDING` reset. Tests
  cover item filters, unit conversion, missing material/unit rows, and
  request-specific deadlines. Updated PLAN validation and integration notes.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,925 ABAP Unit methods. Verify EBAN/MARM DDIC and PR
  planning semantics in the target release.

- Added SQLite-backed coverage for bulk production-order projected receipts.
  Replaced the alias-qualified AFPO/AFKO/AUFK/MARA join with guarded AFPO,
  AFKO, AUFK, and MARA reads merged by order/material keys; the merge retains
  each scope deadline and checks the ten-character AFPO-KDAUF blank value.
  Tests cover production and process order categories, receipt/item/release
  eligibility, base-unit quantities, storage location, batch, and per-request
  dates. Updated PLAN validation and target-system notes. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,926 ABAP Unit methods. Confirm target release fields and order
  status semantics in SAP.

- Added SQLite-backed coverage for bulk date-availability outgoing-STO
  deductions. Replaced the EKET/EKPO/EKKO join with guarded item, header, and
  schedule reads merged by document/item, carrying the maximum date for each
  material/source-plant scope and checking the receiving plant during the
  merge. Tests verify open scheduled-minus-issued quantities, UOM conversion,
  request cutoffs, document and item categories, special procurement, deleted
  items, and same-plant exclusion. Updated PLAN validation, README, and
  ANOMALIES. Full `npm test` passed: PLAN validation, 0 abaplint issues across
  247 files, transpilation, and all 1,927 ABAP Unit methods. Verify target
  transfer lifecycle and DDIC behavior in SAP.

- Added SQLite-backed coverage for bulk planned and fixed planned-order
  receipts. Replaced the PLAF/MARA/MARM join with guarded PLAF proposal, MARA
  base-unit, and MARM conversion batches merged by material/order unit. The
  merge applies fixed/unfixed, scenario, special-stock, and sales-order rules;
  the PLAF-PLSCN and PLAF-KDAUF blank checks avoid local fixed-width SQLite
  comparison differences. Tests cover both inclusion flags, storage location,
  alternative-unit conversion, missing MARM, and request-specific dates.
  Updated PLAN validation and integration notes. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,928 ABAP Unit methods. Confirm proposal eligibility and field behavior in
  the target SAP release.

- Added direct SQLite coverage for bulk date-availability standard PO,
  incoming STO, and production-order receipts. The method now reuses
  `GET_PROJECTED_RECEIPTS_BULK` for standard PO and incoming STO quantities;
  its production path batches AFPO items, AFKO dates, and AUFK release data by
  material/plant and unique order keys, then applies the maximum request date
  and production/process-order eligibility during the merge. The scalar date
  method now delegates to the same bulk implementation and forwards excluded
  reservation keys. Tests verify early and late horizons, both STO quantity
  components, UOM conversion, make-to-order exclusion, process-order inclusion,
  and scalar/bulk parity. Updated PLAN validation, README, and ANOMALIES. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,930 ABAP Unit methods. Confirm query and release-
  status behavior in the target SAP system.

- Added SQLite-backed coverage for scalar `GET_PROJECTED_RECEIPTS` and routed
  its single material/plant/date request through `GET_PROJECTED_RECEIPTS_BULK`.
  The scalar method maps the keyed receipt rows back to its result and retains
  source/date sorting, removing duplicate schedule/order joins. The test checks
  standard PO and process-order quantities, PO batch and location metadata,
  and make-to-order exclusion. Added a PLAN validator check to keep the scalar
  method on the shared bulk path. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods. Verify query behavior and source filters against the target SAP
  release.

- Added direct SQLite checks for scalar `GET_PO_CONFIRMED_RECEIPTS` and routed
  its one-request result through `GET_PO_CONFIRMED_RECEIPTS_BULK`. This removes
  duplicate EKET/EKES joins while retaining PO schedule and confirmation rows.
  Assertions cover result count, reduced quantities, and confirmation batch
  metadata. PLAN validation now prevents reintroducing scalar SELECTs. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods. Verify confirmation fields
  and behavior in the target SAP release.

- Changed the sales-order delivery bulk reader to keep VBUP status rows in a
  hashed table and VBEP schedule rows in document/item/date order. The item
  loop can now use keyed access instead of scanning all status and schedule
  rows for every VBAP item. Existing SQLite tests verify date ordering,
  delivered and confirmed quantities, status fallback, and empty input. Added
  a PLAN validation guard for both table keys. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,931
  ABAP Unit methods.

- Changed stock-transfer bulk reads to fetch MARC totals directly into a
  hashed table and aggregate MARD quantities once into hashed material/plant
  and material/plant/location totals. Location and batch detail rows now use
  sorted keys for their request scopes. SQLite tests cover repeated requests
  as well as existing ordering and quantity cases. Added a PLAN validation
  guard for these table keys. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Changed replenishment outline-agreement reads to de-duplicate request scopes,
  range over EORD rows by material/plant, and read EKKO/EKPO rows by hashed
  document and item keys. SQLite coverage checks duplicate P001 requests and
  separate P002 matching, while retaining plant and agreement values. Added a
  PLAN validation guard for the keys. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Changed replenishment candidate reads to keep EINA rows ordered by material
  and EINE rows ordered by info record/purchasing org/plant, so repeated
  candidate assembly uses keyed ranges. SQLite coverage adds a separate
  purchasing-org case alongside repeated dates and plant-specific records.
  Added a PLAN validation guard for both keys. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,931
  ABAP Unit methods.

- Changed quota-arrangement assembly to read matching EQUP items from a sorted
  quota-number range rather than scanning the full item buffer for every EQUK
  header. Existing SQLite coverage checks multiple headers and their item
  fields. Added a PLAN validation guard for the key. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,931 ABAP Unit methods.

- Changed source-context enrichment to build a hashed MARC policy lookup keyed
  by material/plant while keeping the returned context table in its original
  standard form. SQLite coverage now maps two policy scopes onto their source
  list rows. Added a PLAN guard for the lookup key. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,931 ABAP Unit methods.

- Changed production-order status assembly to keep active JEST rows sorted by
  object number, so each AUFK header reads its matching status range. Existing
  SQLite coverage checks active/inactive rows and system/user status texts.
  Added a PLAN guard for the key. Full `npm test` passed: PLAN validation, 0
  abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Changed production-order operation assembly to keep AFKO routing rows sorted
  by routing number, so AFVC operations use their matching routing range.
  Existing SQLite coverage checks operation ordering and suboperations across
  orders. Added a PLAN validation guard for the key. Full `npm test` passed:
  PLAN validation, 0 abaplint issues across 247 files, transpilation, and all
  1,931 ABAP Unit methods.

- Changed project-stock WBS mappings to hashed lookups by external element and
  internal PSPNR. Key-scoped reads use the element index; stock and reservation
  reads driven by WBS lists build the reverse index once per call. Existing
  SQLite coverage exercises multiple WBS stock/reservation mappings. Added a
  PLAN guard for both directions. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Added secondary material/plant keys to the MARD, reservation, outgoing-STO,
  and production-receipt buffers used by bulk date availability. Request merges
  now iterate only each scope's indexed range while retaining request-date and
  exclusion checks. PLAN validation guards all four keys and merge loops. Full
  `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Changed the bulk safety-stock MARC result buffer to a hashed material/plant
  key and used an explicit table-key read for each output row. Existing SQLite
  coverage checks duplicate requests and a missing plant result. PLAN
  validation now guards the hash and read key. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,931
  ABAP Unit methods.

- Added keyed reservation ranges to bulk open-stock reservation assembly and
  to the sales-order reservation-number and item checks. These loops now read
  the matching material/plant or reservation-number range rather than scanning
  every fetched RESB row per request or candidate. PLAN validation guards all
  three keys and loops. Full `npm test` passed: PLAN validation, 0 abaplint
  issues across 247 files, transpilation, and all 1,931 ABAP Unit methods.

- Added a sorted material/plant key to the bulk projected-receipt buffer.
  Each request now reads its matching scope range, then applies its cutoff date
  while retaining the existing row order and deterministic result sort. PLAN
  validation guards the key, loop, and sort.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Added an order-preserving scope index for confirmed-PO receipt batches. The
  sorted index stores material, plant, and each receipt's original row number;
  matching requests visit those positions in source order. Single-request calls
  keep the direct traversal. PLAN validation guards the index and both paths.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Reused the PO schedule, production-order, and available-quantity calculator
  objects across requests in bulk date availability. The calculators are
  stateless, so the method now creates each enabled calculator once per call.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,931 ABAP Unit methods.

- Indexed multi-center cost-center reservation results by cost center and
  original row number. Bulk validation now gathers each center's reservations
  from its indexed positions while preserving the reader's row order; one-center
  calls retain direct traversal. Added a PLAN shape guard. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,931 ABAP Unit methods.

- Indexed BAPI sales-order delivery rows by document, item, requested date, and
  schedule line, so each BAPI item reads only its schedule range. Documented
  the row-order contract on the delivery repository interface and added a PLAN
  guard for the keyed mapping loop. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,931 ABAP Unit
  methods.

- Hashed the BAPI sales-order headers by document and added a sorted
  document/row-position index for item batches. Mapping now visits each
  document's BAPI item rows in their original order; single-document calls use
  the direct filter. PLAN validation guards both lookups. Full `npm test`
  passed: PLAN validation, 0 abaplint issues across 247 files, transpilation,
  and all 1,931 ABAP Unit methods.


- Added direct SQLite-backed coverage for sales-order reservation aggregation
  from `RESB`. The test verifies grouping by document, item, schedule line,
  requirement date, material, and plant; nets withdrawals; filters fully
  withdrawn, deleted, final-issue, wrong-movement, and special-stock rows; and
  checks the final document/item ordering. The PLAN validator now guards the
  query filters, grouping, open-quantity calculation, and test method. Updated
  README integration limits and recorded the remaining target-SAP key and
  fallback checks in `ANOMALIES.md`.


- Added SQLite-backed tests for both `ZIF_SO_RESERVATION_FINDER` repository
  methods. The test runs the RESB candidate and full-document reads, exercises
  order-wide multi-item ownership versus exact-item ownership, and excludes
  mixed sales documents, wrong movement types, special stock, fully withdrawn,
  deleted, and final-issue candidates. It also checks empty input, optional
  item scoping, and deterministic result order. Extended PLAN validation to
  guard request filters, lifecycle fields, owner checks, and both test calls.
  README and `ANOMALIES.md` record the coverage and remaining target-SAP
  deletion checks.


- Added direct SQLite coverage for the plant-level `GET_STOCK_STATUS` aggregate.
  It checks unrestricted, quality, and blocked MARD totals; nets open RESB
  withdrawals and filters closed, deleted, special-stock, and other-material
  reservations; reads MARC safety stock; and verifies available quantities
  before and after safety-stock subtraction. The PLAN validator now guards the
  query fields and safety-stock calculation. Updated README coverage and the
  target-system caveat in `ANOMALIES.md`.


- Extended the SQLite stock-status test to execute `GET_STOCK_STATUS_BULK` as
  well as the scalar method. It verifies batched MARD/RESB/MARC aggregation,
  repeated material/plant requests, missing scopes, and caller-order output.
  Added PLAN guards for the hashed material/plant totals, lifecycle filters,
  and bulk merge loop. Updated README and `ANOMALIES.md` to describe the expanded
  coverage and target-system limits.


- Extended the direct stock-status repository test to execute
  `GET_UNRESTRICTED_STOCK` as well. It verifies normal MARD/RESB netting and the
  zero clamp when open reservations exceed unrestricted stock, without applying
  safety stock. Added a PLAN guard for the scalar query and clamp path, and
  updated README and `ANOMALIES.md` coverage notes.


- Added direct SQLite coverage for scalar `GET_STOCK_BY_LOCATION` and
  `GET_STOCK_STATUS_BY_LOCATION`. Tests verify gross category totals, exact
  location deductions, distribution of unscoped reservations in ascending
  location order, and exclusion of closed, deleted, and special-stock rows.
  The PLAN validator now guards both grouped queries and their RESB filters.
  Updated README and `ANOMALIES.md` with the direct coverage and SAP limits.


- Fixed `GET_STOCK_BY_LOCATION`: its grouped MARD and RESB selects returned
  `LGORT` into `CORRESPONDING FIELDS` structures named `storage_location`,
  dropping the location key and producing an empty allocation result. Both
  queries now alias the key correctly. The new direct SQL test reproduces the
  empty result without the aliases and verifies both location balances after
  exact and unscoped reservations.


- Extended the direct RESB Open SQL test to cover scalar
  `GET_OPEN_STOCK_RESERVATIONS` as well as the bulk method. It checks reservation
  number/item, requirement date, location, batch, net open quantity, and the
  empty result for a missing material. Added a PLAN guard for the scalar query's
  scope/lifecycle filters and output mapping; documented the expanded local
  coverage in README.


- Fixed scalar batch reservation mapping: `GET_STOCK_STATUS_BY_BATCH` selected
  `RESB-LGORT` and `RESB-CHARG` into differently named fields, dropping the
  exact reservation scope. Added scalar SQLite coverage for exact batch/location
  deduction, zero-balance status, closed/special-stock filters, and
  `GET_STOCK_BY_BATCH` positive-row ordering; strengthened the shared batch
  fixture so the bulk method covers the same cases. Added a PLAN guard and
  documented the defect and target-SAP limitation. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,935
  ABAP Unit methods.


- Added direct SQLite coverage for scalar `GET_SAFETY_STOCK`, verifying a
  present result, separate values for the same material at two plants, and the
  initial result for a missing material. Added a PLAN guard for the scalar MARC
  query and all three cases. Updated README and `ANOMALIES.md` to distinguish
  scalar and bulk safety-stock coverage. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,935
  ABAP Unit methods.


- Added direct SQLite coverage for scalar `GET_SAFETY_STOCK` with both an
  existing and missing MARC row, alongside the existing aggregate and bulk
  coverage. PLAN validation now guards the scalar query and its two result
  cases. Updated README and `ANOMALIES.md` to distinguish scalar and bulk
  coverage. Full `npm test` passed: PLAN validation, 0 abaplint issues across
  247 files, transpilation, and all 1,935 ABAP Unit methods.


- Strengthened production-order readiness overflow coverage. The regression
  now independently rejects overflowing requested, confirmed, and unconfirmed
  totals, and PLAN validation checks each packed-field conversion and boundary
  case. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247
  files, transpilation, and all 1,989 ABAP Unit methods.


- Added an end-to-end stock allocation test using the production factory and
  SQLite-backed MARD/RESB reads. It checks reservation netting and shared stock
  consumption across two demands. PLAN validation guards the factory-backed
  path; README and `ANOMALIES.md` record coverage and the SAP-runtime limit.
  Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files,
  transpilation, and all 1,990 ABAP Unit methods.


- Extended the factory integration to FEFO allocation with SQLite MCHB, MCHA,
  MCH1, and RESB rows. It verifies that an open batch reservation reduces the
  earliest-expiry lot, then checks the resulting two-lot split and expiry order.
  PLAN validation guards the scenario. Full `npm test` passed: PLAN validation,
  0 abaplint issues across 247 files, transpilation, and all 1,991 ABAP Unit
  methods.


- Fixed cross-plant preview validation so a request cannot list its receiving
  plant as a source. The transfer-order service already rejected those pairs,
  which let previews suggest unusable stock splits. Added regression coverage
  for ordinary, dated, location-aware, FEFO, and batch allocator paths, plus a
  PLAN guard and README/`ANOMALIES.md` notes. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,992
  ABAP Unit methods.

- Extended project WBS FEFO goods issue with request-specific storage-location ranks across base, priority, and date-first demand APIs. Ranks are validated against caller IDs, remapped for repeated IDs, and reused for both fresh stock snapshots before posting. Regression cases prove that ranked locations override shared order while preserving FEFO and caller-order movement splits. README and `ANOMALIES.md` document the behavior. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,992 ABAP Unit methods.

- Added per-demand preferred-location fallback to batchless WBS location
  allocation. `allow_location_fallback` consumes the requested location first,
  then uses other eligible locations for any remainder. Base, priority, and
  date-first previews carry it through ATP, reservation, and goods-issue
  rechecks; FEFO demands continue to reject the batchless-only option. Tests
  cover rank precedence, partial preferred stock, fallback when the preferred
  location is empty, issue splits, and reservations. README and `ANOMALIES.md`
  document the behavior. Full `npm test` passed: PLAN validation, 0 abaplint
  issues across 247 files, transpilation, and all 1,992 ABAP Unit methods.

- Extended preferred-location fallback to batch-managed WBS FEFO demands. A
  preferred location now leads eligible locations with the same expiry date;
  FEFO eligibility, allowlists, request ranks, and batch/location splits remain
  enforced. Base, priority, date-first, reservation, and goods-issue adapters
  preserve the option through fresh previews. Regression coverage checks
  partial preferred stock, rank precedence, reservation and movement splits,
  and rejection when fallback has no preferred location. Added PLAN guards and
  documented the behavior and SAP snapshot limitation in README and
  `ANOMALIES.md`. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,992 ABAP Unit methods.

- Extended preferred-location fallback through batch-managed WBS FEFO transfer
  previews and posting rechecks. Base, priority, and date-first transfer demand
  types and goods-movement adapters carry the preference into both snapshots.
  Tests cover fallback from an unavailable preferred location and a partial
  preferred-location allocation that overrides per-request ranks. Added PLAN
  guards and updated README/`ANOMALIES.md`. Full `npm test` passed: PLAN
  validation, 0 abaplint issues across 247 files, transpilation, and all 1,992
  ABAP Unit methods.

- Extended preferred-location fallback through batchless WBS transfer previews
  and posting rechecks. Base, priority, and date-first transfer demands retain
  the flag through request-ID remapping and both stock snapshots. Tests cover
  duplicate request IDs, preferred-stock splits that override location ranks,
  fallback from an empty preferred location, and 415/Q posting. Added PLAN
  guards and clarified the batchless and FEFO behavior in README and
  `ANOMALIES.md`. Full `npm test` passed: PLAN validation, 0 abaplint issues
  across 247 files, transpilation, and all 1,992 ABAP Unit methods.

- Added priority- and date-first WBS reservation tests for partial preferred-location fallback; both verify that the reservation API receives the preferred and fallback splits.
- Added request-specific location ranks to cost-center location previews. Different demands can now apply different warehouse orders while sharing the stock snapshot. README and `ANOMALIES.md` describe the rank rules.
- Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 1,995 ABAP Unit methods.

- Added integration coverage for priority- and date-first WBS reservations that use partial preferred-location fallback.
- Added request-specific location ranks to cost-center location, exact-batch, FEFO, and date-first FEFO previews. Atomic and bulk reservations, including date-first FEFO wrappers, now preserve those ranks; bulk validates the complete rank table before writes and filters it per demand. README and `ANOMALIES.md` describe the behavior, and PLAN validation guards each adapter.
- Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,002 ABAP Unit methods.

- Added a bulk-reservation regression proving an unknown request-specific location rank is rejected before stock reads or reservation writes. PLAN validation checks the guard. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,003 ABAP Unit methods.

- Strengthened cost-center reservation rank validation: atomic reservations now reject unknown request IDs, nonpositive ranks, and duplicate request/location pairs before stock reads or API writes, matching bulk behavior. Added a no-read/no-write regression and PLAN guard. Date-first atomic and bulk FEFO tests now reverse demand dates to verify rank rows remain attached through sorting. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,004 ABAP Unit methods.

- Added factory-backed SQLite coverage for project WBS FEFO allocation. The production project-stock service now runs through real local `MSPR`/`PRPS`/`MCHA`/`RESB` queries; the regression verifies an open exact-batch reservation reduces the early lot and FEFO allocates the remaining 4 + 6 units. Added PLAN coverage and README/`ANOMALIES.md` notes. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,005 ABAP Unit methods.

- Hardened project-stock location and FEFO previews against packed-quantity overflow. Duplicate-key balances, per-demand availability, grouped ATP demand, cumulative ATP demand, and confirmation totals now accumulate in `DECFLOAT34` and are checked against `MARD-LABST` before conversion or API calls. Added three regressions for location, FEFO, and ATP overflow, including a no-ATP-call assertion. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,008 ABAP Unit methods.

- Added request-specific storage-location scopes to base WBS FEFO and batchless location previews. Each request's locations intersect the shared allowlist; invalid, duplicate, or unknown scope rows fail before UOM/stock reads, and preferred locations must be inside the request scope. Results echo the validated scopes, and both ATP preview adapters preserve them. Added FEFO/location split, allowlist intersection, ATP-forwarding, and no-read validation regressions plus PLAN guards and README/`ANOMALIES.md` documentation. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,012 ABAP Unit methods.

- Extended request-specific WBS storage-location scopes through priority and per-request-date FEFO/location previews, all four ATP adapters, and the matching reservation flows. Wrappers validate and remap caller scopes across internal request IDs, return caller-facing scope rows, and use the same mapped scope in initial and fresh reservation checks. Added scoped split, no-read invalid-scope, four-adapter ATP, and four reservation-posting regressions; documented the contract and added PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,082 ABAP Unit methods.

- Extended WBS request-specific storage-location scopes to project-stock transfer previews: FEFO and batchless location transfers now support base, priority, and per-request-date forms plus their ATP adapters. Scope rows map through internal transfer IDs, invalid rows fail before stock reads, results preserve the caller-facing rows, and source/destination assignments remain intact. Added regressions across all six preview and ATP variants plus invalid-scope no-read coverage; documented the contract and added PLAN guards. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,085 ABAP Unit methods.

- Added request-specific storage-location scopes to all six WBS goods-movement transfer wrappers: base, priority, and date-first FEFO and batchless location posting. Wrappers reject blank, unknown, and duplicate scope rows before reads, map caller IDs through internal preview IDs, reuse the mapped scopes for the fresh-stock recheck, and return caller-facing scopes. Added posting coverage across all six paths, a competing-location FEFO case, a no-read unknown-scope regression, PLAN guards, and README/`ANOMALIES.md` documentation. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,086 ABAP Unit methods.

- Extended request-specific storage-location scopes through all six WBS goods-issue posting wrappers: base, priority, and date-first FEFO and batchless location issue. The wrappers reject invalid scopes before reads, map caller IDs through internal rows, reuse scopes for fresh-stock checks, and return the caller-facing scope in their preview. Added scoped posting regressions for each variant and an unknown-scope no-read test; updated PLAN guards and README/`ANOMALIES.md`. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,087 ABAP Unit methods.

- Added per-request storage-location scopes to the core unrestricted-stock base, unit-aware, and ATP allocators. The adapters remap scopes through internal demand IDs, echo caller rows, intersect with shared allowlists, and reject invalid scopes before stock or UOM reads. PLAN validation, lint, transpilation, and all 2,090 ABAP Unit methods passed.

- Priority unrestricted-stock location previews now accept request-specific storage-location scopes. The priority wrappers validate and remap caller IDs, preserve scope echoes, and forward restrictions through UOM and ATP forms. PLAN validation, lint, transpilation, and all 2,090 ABAP Unit methods passed.

- Date-first unrestricted-stock location allocation now supports request-specific scopes through base, UOM, and ATP methods. Scopes constrain on-hand balances and projected receipts, validate before UOM reads, and echo the caller rows. PLAN validation, lint, transpilation, and all 2,090 ABAP Unit methods passed.

- Exact-batch unrestricted-stock previews now accept request-specific scopes through base, unit-aware, priority, and ATP methods. Scope filters apply to on-hand balances and projected receipts, priority adapters remap IDs, and invalid scopes fail before stock or UOM reads. PLAN validation, lint, transpilation, and all 2,090 ABAP Unit methods passed.

- Unrestricted-stock FEFO now applies request-specific location scopes across base, unit, priority, and ATP variants. Scopes constrain on-hand batches and projected receipts, unit/priority adapters preserve caller IDs, and invalid scope/preferred-location rows fail before stock or UOM reads. The new regression covers all six adapters and excludes an out-of-scope projected receipt. PLAN validation, lint, transpilation, and all 2,090 ABAP Unit methods passed.

- Quality-stock FEFO now supports request-specific location scopes across base, unit, priority, and ATP variants. Scopes constrain quality stock and projected receipts; adapters remap and echo caller rows, and invalid/preferred-outside-scope inputs fail before stock or UOM reads. Regressions cover all six methods and an excluded projected receipt. PLAN validation, lint, transpilation, and all 2,090 ABAP Unit methods passed.

- Quality FEFO release and send wrappers now accept request-specific scopes and forward them into the fresh allocation check. All four posting paths preserve the preview restriction; empty-demand calls reject nonempty scopes, and invalid scopes stop before stock/UOM reads or movement creation. PLAN validation, lint, transpilation, and all 2,091 ABAP Unit methods passed.

- Cost-center FEFO previews and reservation APIs now accept request-specific storage-location scopes. Date-first wrappers preserve scope IDs, atomic and bulk result items echo scopes, and bulk inputs validate all scope rows before processing. Invalid preview scopes fail before stock reads or UOM conversion; non-FEFO reservation modes reject FEFO scopes. PLAN validation, lint, transpilation, and all 2,091 ABAP Unit methods passed.

- Cost-center FEFO issue posting now carries request-location scopes from previews and rejects malformed scope rows or out-of-scope batch splits before the movement API call. PLAN guards and regressions cover out-of-scope and duplicate scope rows. Full npm pipeline passed with 0 lint issues across 247 files and 2,091 ABAP Unit methods.

- Cost-center location-only, exact-batch, and FEFO paths now share request-specific location scopes through previews, atomic/bulk reservations, and posting validators. Result rows echo scopes; issue methods reject out-of-scope splits before movement creation. PLAN validation, lint, transpilation, and all 2,091 ABAP Unit methods passed.

- Added grouped SAP ATP diagnostics to plant-level bulk and location-aware cost-center previews. Each path validates the ATP flag and rule before stock reads, returns grouped cumulative and confirmation quantities beside the existing local allocation, and preserves location splits. Added cross-unit grouped-check and no-read validation coverage, README guidance, and PLAN guards. Full npm pipeline passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,091 ABAP Unit methods.
- WBS FEFO priority, required-date, and goods-issue flows now preserve per-demand full-quantity rules. Strict rows allocate all or none when shared partial allocation is enabled, allocation summaries echo the effective rule, and mixed WBS issues post only eligible partial rows. Added priority/date preview regressions and mixed issue tests; PLAN guards and README guidance are updated.
- Cost-center exact-batch and FEFO previews now attach grouped SAP ATP diagnostics to their existing local batch splits, using each split's effective check date and base unit. Cross-unit grouped checks and missing-rule no-read regressions are covered by PLAN guards and README guidance. Full npm pipeline passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,091 ABAP Unit methods.
- Date-first cost-center FEFO previews now forward grouped ATP checks through the required-date and priority ordering while returning rows in caller order. Added mixed-unit grouping and missing-rule no-read regressions, README guidance, and PLAN guards. Full npm pipeline passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,091 ABAP Unit methods.
- Cost-center exact-batch and FEFO previews now accept caller-resolved projected batch receipts. The existing allocator gates receipts by each demand's effective date, expiry, selected batch, and location scope; date-first FEFO preserves those cutoffs through priority ordering. Added scoped exact-batch, FEFO, and date-gating regressions, README guidance, and PLAN guards. Full npm pipeline passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and all 2,091 ABAP Unit methods.
- Added `preview_cc_locations_by_date` for cost-center location allocation with date and priority ordering, caller-resolved projected location receipts, location scopes/ranks, full-quantity handling, and grouped ATP checks. Regressions cover separate date groups, receipt cutoffs, caller-order output, and missing-rule/invalid-date rejection before reads. README and PLAN guards are updated. Full npm pipeline passed with 0 lint issues across 247 files and 2,091 ABAP Unit methods.
- Cost-center location previews now support opt-in priority allocation. Higher-priority requests consume shared location stock first while results remain in caller order; grouped ATP diagnostics follow the priority allocation. Invalid priority flags fail before stock reads. Full PLAN validation, lint, transpilation, and ABAP Unit pipeline passed.
- Plant-level and location-only cost-center previews now support opt-in priority allocation in both local and ATP paths. Higher-priority requests consume shared stock first, results remain in caller order, and output rows echo priority. Full npm pipeline passed.
- Cost-center plant-level and location-only previews now accept an explicit ATP check date, defaulting to today when omitted. Both standard and priority allocation branches forward the date; malformed dates fail before stock reads. Dated plant-level preview rows now echo priority directly. Full npm pipeline passed.
- Plant-level cost-center preview demands can now require full quantity per row, alongside the existing global setting. An unfillable strict request consumes no stock, so following rows can still allocate; malformed row flags fail before reads. README and PLAN guards cover the behavior. Full npm pipeline passed.
- Undated cost-center location demands now support per-request full-quantity requirements, and each result reports the effective setting including the global override. Strict unfillable requests leave locations available for later rows. Invalid flags fail before stock reads. Full npm pipeline passed.
- Exact-batch cost-center preview demands now support row-level full-quantity requirements alongside the global setting, and results echo the effective value. Unfilled strict requests leave selected-batch stock available to later rows; malformed flags are rejected. Full npm pipeline passed.
- Dated plant-level cost-center preview demands now support row-level full-quantity requirements, echoing the effective setting alongside priority. A strict unfillable request leaves stock for later requests on the same date, including priority-ordered runs. Full npm pipeline passed.
- Dated location-only cost-center previews now echo the effective per-request full-quantity requirement, including the global override, alongside each date-first allocation. Existing per-row strictness and full npm validation pass.
- Preview outputs now consistently report the effective full-quantity rule, including when the global option applies across plant, dated plant, location, dated location, batch, and FEFO paths. Regression coverage checks the shared setting across these result types. Full npm pipeline passed.
- Batchless WBS location previews now accept caller-resolved projected receipts. Shared and per-demand cutoffs gate receipt dates, receipts stay isolated by WBS/material/plant/location, and base, priority, date-first, and ATP adapters preserve the forecast rows. Regression coverage checks date gating, WBS isolation, all adapters, unmatched rows, and overflow. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Batchless WBS transfer previews now accept caller-resolved projected location receipts, matched to each transfer's source WBS. Demand and date-first cutoffs preserve receipt timing through base, priority, and ATP adapters; posting rechecks remain based on posted stock. Tests cover all six transfer preview adapters. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- WBS FEFO batch splits and batchless location splits now expose `available_from_date`; posted balances leave it initial and projected receipts report their receipt date. The field flows through priority, date-first, ATP, and WBS transfer previews. README and `ANOMALIES.md` document the output. Full `npm test` passed: PLAN validation, 0 abaplint issues across 247 files, transpilation, and ABAP Unit.
- Batch allocation output now carries projected receipt dates in the shared `ty_batch_allocation` row. Exact-batch, standard FEFO, quality FEFO, unit-aware, cost-center, and WBS outputs preserve the date; posted stock leaves it initial. Updated README, anomaly notes, and PLAN guards. PLAN validation passed, abaplint found 0 issues across 247 files, and transpilation completed. ABAP Unit was not run.
- Cross-plant FEFO now keeps projected balances separate by receipt date, reports `available_from_date` on its FEFO-specific split type, and preserves it through priority, date-first, unit-aware, and ATP outputs. Updated README, `ANOMALIES.md`, and PLAN guards. PLAN validation passed, abaplint found 0 issues across 247 files, and transpilation completed. ABAP Unit was not run.
- Cross-plant exact-batch allocations now retain posted and projected quantities in separate date-keyed balances and expose `available_from_date` on location splits, including dated, priority, UOM, and ATP adapters. Updated README and `ANOMALIES.md`. PLAN validation passed, abaplint found 0 issues across 247 files, and transpilation completed. ABAP Unit was not run.

- Project-reservation independent bulk deletion, item deletion, rescheduling, quantity changes, final-issue marking/reset, and stock-key changes now aggregate child `is_committed` flags. Partial persistence and test runs are represented accurately. Lint passed with 0 issues across 247 files and transpilation passed; ABAP Unit was not run. Target SAP reservation-update behavior remains unverified.
- Reservation-issue bulk posting now exposes top-level `is_committed` when any independently committed reservation group succeeds. Simulated and failed groups leave the aggregate false; per-group statuses remain authoritative.
- Production-component remaining bulk issues and returns now expose top-level `is_committed` when any reservation group commits. Simulated runs and failed groups stay false, and the existing per-reservation rows retain individual outcomes.
- Sales-order reservation release bulk now exposes top-level `is_committed` when any independent order release commits. Failed later orders do not erase earlier persistence; simulations and successful no-op orders remain uncommitted.
- Purchase-requisition bulk creation and deletion now aggregate child commit status across per-document operations. Partial successes remain visible after later failures; test runs and batches without commits stay false.
- Sales-order bulk create, change, rejection, and rejection-clear results now expose top-level `is_committed` whenever any child order commits. The aggregate preserves partial writes after later failures and stays false for simulations or failed batches.
- Purchase-order bulk create, delete, delivery-complete, schedule-change, and quantity-change results now aggregate child `is_committed` flags. Partial document commits remain visible after later failures; simulations and all-failed batches stay false.
- Cost-center reservation bulk creation and deletion now expose top-level `is_committed` when any demand or reservation commits. Per-row commit state remains authoritative; simulations and no-commit batches stay false.
- Sales-order reservation deletion now reports shared-transaction `is_committed` on single-order and combined bulk results, propagating the flag only after a successful live commit. Preview and simulation results remain uncommitted.
- Multi-sales-order dated bulk reservations now expose top-level `is_committed` when any sales order reservation commits. The aggregate preserves earlier commits after later failures and remains false for simulations and successful no-op orders.
- Sales-order reservation deletion wrappers now reject malformed `iv_test_run` values before order lookup, including successful no-match paths; the lower-level combined delete also validates before the API call.
- Cost-center reservation issue and reversal methods now validate `iv_test_run` before reading reservation scope. This prevents malformed flags from triggering repository reads across single, bulk, and unit-aware entry points.
- Production-component bulk issue and return entry points now reject malformed `iv_test_run` values before reading component reservations, including unit-aware requests.
- WBS FEFO and location transfer wrappers now reject malformed `iv_test_run` values before their first stock snapshot; single cost-center reservations reject them before allocation or optional ATP reads.
- Single cost-center reservation and preview paths now reject malformed ATP-check flags before stock reads; shared preparation validates fallback, FEFO, safety-stock, and full-allocation booleans before unit conversion or allocation.
- Added sales-order item deletion through the sales-order BAPI adapter, with single-document, independently committed bulk, and shared-commit atomic service flows. All document and item keys validate before writes; results preserve per-document messages and aggregate commit status.

- Quality-stock and sales-order FEFO posting services now validate boolean
  options before successful empty-demand returns, including `iv_test_run`,
  allocation policy, and FEFO selection flags. Local source guards, lint, and
  transpilation passed. `validate:plan` could not start in WSL 1; ABAP Unit was
  not run.

- Direct cost-center and sales-order movements carry optional valuation types
  through base-unit, UOM, bulk, atomic, and sales-stock paths. Material-to-
  material 309/310 transfers now carry source and receiving valuation types
  through base-unit and UOM paths to `BAPI_GOODSMVT_CREATE`. Local valuation-
  type stock allocation remains unsupported. Local source guards passed, lint
  found 0 issues across 247 files, and transpilation updated 22 outputs.
  `validate:plan` could not start in WSL 1. Target SAP DDIC and posting behavior
  need verification; ABAP Unit was not run.

- Batch-stock snapshots now expose split valuation by resolving non-batch-managed
  stock from `MCHB-CHARG` and batch-managed stock from `MCHA-BWTAR`. Reservation
  deductions use `RESB-BWTAR` as an additional stock scope. Added single and bulk
  valuation-type status previews grouped by storage location. Added
  `PREVIEW_BY_VALTYPE`, which consumes ordered demand against the typed stock
  balances and returns location/batch splits with full-quantity shortfalls. Its
  UOM form converts demand and detail quantities through the existing material
  unit converter while retaining base-unit values. Split rows expose `XCHAR`
  state so callers can distinguish physical batches from dummy `CHARG` keys.
  Lint and transpilation passed; `validate:plan` could not start in WSL 1.
  Target SAP mapping remains to verify; ABAP Unit was not run.

- Valuation-type previews now accept global and per-request storage-location
  priorities plus an optional allowed-location list. Per-request priorities
  override the global order; unlisted allowed locations follow alphabetically.
  The allowed set restricts both availability totals and allocation splits;
  the UOM wrapper passes these options through to the base-unit allocator.
  Added single and bulk UOM forms for grouped valuation-type status, converting
  all four per-location quantities and returning both unit codes. Corrected a
  mismatched `INTTYPE` tag in the AUFK stub; all 92 stub XML files
  now parse. Local source guards, lint (0 issues across 247 files), and
  transpilation (5 outputs updated) passed. `validate:plan` could not start in
  WSL 1; target SAP mapping remains to verify. ABAP Unit was not run.

- Valuation-type allocation now filters physical batches by the demand's
  `as_of_date` (current date by default), minimum shelf life, and known-expiry
  requirement. Expiration on the effective date remains eligible; non-batch
  split-valuated stock is not date-filtered. Summaries expose the effective
  date and expiry controls, and detail splits return each batch expiration.
  `abaplint` found 0 issues across 247 files; transpilation updated 3 outputs.
  Focused source guards passed. `validate:plan` could not start in WSL 1, and
  ABAP Unit was not run; verify batch expiry mapping in the target SAP system.

- `PREVIEW_BY_VALTYPE` and its UOM form now accept caller-resolved projected
  receipts in base units. Receipts enter demand availability only on/after their
  receipt date. The summary separates current/projected balances; splits include
  availability date and projected marker. Receipt rows explicitly identify
  batch-managed materials; managed rows require a physical batch, while
  non-managed split valuation keeps batch and expiry blank. Repeated physical-
  batch identity and expiry are checked against existing balances when present;
  receipt rows also agree on the material/plant management marker.
  Projected splits now preserve caller source type/document/item/plant/schedule
  line identity through the UOM wrapper; posted stock leaves those fields blank.
  The undated-batch option defaults inclusive, can be disabled globally, and
  supports a per-demand opt-in; `require_known_expiry` takes precedence. The
  result echoes the effective policy. `abaplint` found 0 issues in 247 files;
  transpilation updated 5 outputs and focused source/XML guards passed. PLAN
  validation remains unable to start in WSL 1; ABAP Unit was not run. Avoid
  double-counting posted receipts.

- `PREVIEW_BY_VALTYPE` and its UOM form now accept request-specific location
  scopes. Scopes constrain available totals and splits, intersect the global
  allowlist, reject duplicate or unknown request/location rows, and require an
  explicitly requested location to be in scope. Results echo the scope rows;
  the UOM form validates them before conversion. `abaplint` found 0 issues
  across 247 files, transpilation updated 5 outputs, focused source/XML guards
  passed, and `git diff --check` passed. The PLAN runner still cannot start in
  WSL 1; ABAP Unit was not run.
- Fixed `GET_PROJ_RECEIPTS_BULK_UOM` to reject duplicate request IDs before
  unit conversion, matching its keyed result contract and existing regression
  coverage.

- `PREVIEW_BY_VALTYPE` and its UOM form now accept per-request batch-key
  candidates. Candidates filter availability summaries and allocation splits,
  are validated before UOM conversion, and are echoed in results. The key is
  the physical batch for batch-managed stock and the dummy `CHARG` valuation
  key for non-batch split stock. `abaplint` found 0 issues across 247 files;
  transpilation updated 3 outputs. Focused source/docs guards, all 92 stub XML
  parses, and `git diff --check` passed. `validate:plan` cannot start in WSL 1;
  ABAP Unit was not run.

- `PREVIEW_BY_VALTYPE` and its UOM form now accept positive per-request batch
  ranks. Ranked batches are allocated before unranked batches within each
  location and posted/projected group; posted stock remains ahead of projected
  receipts, and batch code breaks rank ties. When candidates are supplied,
  every ranked key must be among them. Both result forms echo validated ranks.
  `abaplint` found 0 issues across 247 files; transpilation updated 5 outputs.
  Focused source/docs guards, all 92 stub XML parses, and `git diff --check`
  passed. `validate:plan` cannot start in WSL 1; ABAP Unit was not run.

- Valuation-type demand rows now accept an integer priority, echoed in base and
  UOM allocation summaries. Earlier effective `as_of_date` values consume
  shared balances first; higher priorities order requests on the same date,
  with input order breaking ties. Omitted dates use today and omitted
  priorities default to zero. Allocation and split results remain in caller
  order after priority-based consumption; summaries expose the one-based
  allocation sequence for traceability.
  `abaplint` found 0 issues across 247 files and transpilation updated 4
  outputs. Focused source/docs guards, all 92 stub XML parses, and
  `git diff --check` passed. `validate:plan` cannot start in WSL 1; ABAP Unit
  was not run.

- Valuation-type previews now optionally protect static plant-level
  `MARC-EISBE` safety stock once per material/plant across all valuation
  balances. The deterministic reserve order takes current stock first, then
  projected receipts by date. Base and UOM summaries echo the protection and
  safety-stock quantities. `abaplint` found 0 issues across 247 files and
  transpilation updated 5 outputs. Focused source/docs guards, all 92 stub XML
  parses, and `git diff --check` passed. `validate:plan` cannot start in WSL 1;
  ABAP Unit was not run.

- Added `PREVIEW_BY_VALTYPE_UOM_ATP`, which attaches cumulative SAP ATP
  diagnostics to local UOM allocations grouped by material, plant, base unit,
  and effective date. The check summarizes quantity allocated on each date,
  cumulative quantity through the date, and confirmed/unconfirmed totals. SAP
  ATP remains plant-level and does not see local valuation, batch, location,
  or caller-projected receipt assignments. `abaplint` found 0 issues across
  247 files; transpilation updated 5 outputs. Focused source/docs guards, all
  92 stub XML parses, and `git diff --check` passed. `validate:plan` cannot
  start in WSL 1; ABAP Unit was not run.

- Extended `PREVIEW_BY_VALTYPE_UOM_ATP` with `request_atp_checks`, one row per
  positive allocation in allocation-sequence order. Each row reports the
  incremental confirmed/unconfirmed quantities attributed from its date's
  grouped ATP result and retains that raw result; no request-specific SAP call
  is made. The validator and README now guard/document this mapping. Target
  checking-rule confirmation behavior remains unverified. Lint passed with 0
  issues across 247 files and transpilation updated 5 outputs; focused source
  and docs guards, all 92 stub XML parses, and `git diff --check` passed.
  `validate:plan` cannot start in WSL 1; ABAP Unit was not run.

- Valuation-type allocation summaries now report projected receipt quantity
  actually allocated, separately from eligible projected availability. The
  UOM summary exposes the consumed amount in the requested unit as
  `source_projected_allocated_qty`. `abaplint` found 0 issues across 247 files;
  transpilation updated 4 outputs. Focused source/docs guards, all 92 stub XML
  parses, and `git diff --check` passed. `validate:plan` cannot start in WSL 1;
  ABAP Unit was not run. Target receipt execution remains external to this
  preview.

- Request-level valuation ATP checks now also expose allocated, confirmed,
  and unconfirmed quantities in each demand's requested UOM while retaining
  base-unit quantities for SAP diagnostics. The row returns `source_unit` to
  identify those converted quantities; SAP is still checked in the base unit.
  `abaplint` found 0 issues across 247 files and transpilation updated 5
  outputs. Focused source/docs guards, all 92 stub XML parses, and CRLF-aware
  `git diff --check` passed. `validate:plan` cannot start in WSL 1; ABAP Unit
  was not run.

- Request-level valuation ATP rows now echo the local valuation type and
  request priority alongside the allocation sequence. These fields explain
  local allocation context only; SAP ATP remains plant-level and does not
  filter by them. `abaplint` found 0 issues across 247 files and transpilation
  updated 4 outputs. Focused source/docs guards, all 92 stub XML parses, and
  CRLF-aware `git diff --check` passed. `validate:plan` cannot start in WSL 1;
  ABAP Unit was not run.

- Valuation-type allocation summaries now expose current and projected
  consumption separately. The UOM result reports both in source units and
  derives current consumption as the residual after projected conversion so
  the two amounts reconcile to total source allocation. `abaplint` found 0
  issues across 247 files and transpilation updated 4 outputs. Focused
  source/docs guards matched all 62 service and 36 README checks; all 92 stub
  XML parses and CRLF-aware `git diff --check` passed. The README guard now
  normalizes whitespace, so ordinary wrapping does not invalidate phrases.
  `validate:plan` cannot start in WSL 1; ABAP Unit was not run.

- Base and UOM valuation previews now echo validated request-specific location
  priorities in `request_location_priorities`, sorted by request, rank, and
  storage location. This makes the chosen location sequence auditable from
  the result. `abaplint` found 0 issues across 247 files and transpilation
  updated 4 outputs. All 64 service guards and 37 README guards passed, along
  with 92 stub XML parses and CRLF-aware `git diff --check`.
  `validate:plan` cannot start in WSL 1; ABAP Unit was not run.

- Valuation preview results now also echo the global fallback location order
  and the allowed-location list as `storage_location_priority` and
  `allowed_storage_locations`. The list and ordering rules can be inspected
  with the request-specific priorities in the same result. `abaplint` found 0
  issues across 247 files and transpilation updated 4 outputs. All 68 service
  guards and 39 README guards passed, along with 92 stub XML parses and
  CRLF-aware `git diff --check`. `validate:plan` cannot start in WSL 1; ABAP
  Unit was not run.

- Base and UOM valuation preview results now echo all validated projected
  receipt inputs, including receipts that were unused by the allocation. The
  result preserves input order; split rows show the receipt quantities that
  were actually allocated. `abaplint` found 0 issues across 247 files and
  transpilation updated 4 outputs. All 70 service guards and 40 README guards
  passed, along with 92 stub XML parses and CRLF-aware `git diff --check`.
  `validate:plan` cannot start in WSL 1; ABAP Unit was not run.


- Extended call-wide reservation exclusions through the public single-plant
  and cross-plant unrestricted-stock exact-batch, FEFO, and storage-location
  allocation families, including cross-plant batch ATP. Base, date, priority,
  UOM, and ATP wrappers validate and forward the same unique reservation keys
  into stock netting. UOM paths validate before conversion. The README and PLAN
  validator now cover these 40 public methods. Focused source-flow checks, all
  92 SAP stub XML parses, and CRLF-aware `git diff --check` passed. The validator and
  abaplint/transpilation could not run because Node is absent in WSL and the
  Windows runtime launch failed with `UtilBindVsockAnyPort:307: socket failed 1`;
  ANOMALIES.md records the runtime issue. Target SAP batch reservation
  semantics remain to be verified.

- Call-wide reservation exclusions now flow through all six production
  component preview APIs and the direct `ALLOCATE_COMPONENT_STOCK` helper.
  Complete, unique keys are validated before stock reads; selected component
  reservations are merged once with caller exclusions while duplicate demand
  keys remain invalid. This affects local stock netting only, including the
  local estimate in ATP previews. README and PLAN validator guards cover the
  API forwarding and merge behavior. Focused source-flow checks and all 92 SAP
  stub XML parses passed. Node is unavailable in WSL, and the Windows runtime
  launch for `validate:plan`, abaplint, and transpilation failed with
  `UtilBindVsockAnyPort:307: socket failed 1`; ABAP Unit was not run.

- Project-stock reads and all 24 project-stock preview variants now accept
  call-wide reservation keys. Matching WBS RESB rows are skipped during local
  reservation deductions; the FEFO, location, dated, priority, transfer, and
  ATP wrapper chains all forward the same keys. The single and bulk UOM readers
  validate exclusions before conversion. Added source and README guards plus
  docs describing local-only ATP impact. Focused interface/forwarding checks,
  all 92 SAP stub XML parses, and CRLF-aware `git diff --check` passed. Node is
  unavailable in WSL, and the Windows runtime launch for `validate:plan`,
  abaplint, and transpilation failed with
  `UtilBindVsockAnyPort:307: socket failed 1`; ABAP Unit was not run.


- Reservation coverage now accepts the same call-wide RESB exclusions across
  single, bulk, and UOM APIs. Selected open reservations are removed from
  reserved quantities, item counts, and free-stock netting. The PLAN validator
  now guards declarations, forwarding, filtering, and validation order. Focused
  source checks, all 92 SAP stub XML parses, CRLF preservation, and
  `git diff --check` passed.
  PLAN validation, abaplint, and transpilation could not launch: Node is absent
  in WSL and Windows runtime startup failed with
  `UtilBindVsockAnyPort:307: socket failed 1`. ABAP Unit was not run.


- Reservation-coverage results now report `excluded_open_resv_items`
  per WBS/material/plant balance and preserve the count in UOM results. Only
  matching open rows count; unknown, closed, or out-of-scope keys remain zero.
  Focused source-flow checks, all 92 SAP stub XML parses, type alignment,
  CRLF preservation, and `git diff --check` passed. `validate:plan`, abaplint,
  and transpilation still cannot launch because Windows runtime startup fails
  with `UtilBindVsockAnyPort:307: socket failed 1`; ABAP Unit was not run.


- Bulk reservation coverage now accepts exclusions per request as well as
  call-wide. It validates request IDs and unique reservation keys before reads
  or UOM conversion, combines overlapping global and request keys once, and
  groups reads by date and identical exclusion sets. The PLAN validator checks
  validation, grouping, forwarding, and docs. Focused source-flow and ordering
  checks, all 92 stub XML parses, CRLF and field alignment, and
  `git diff --check` passed. `validate:plan`, abaplint, and transpilation still
  cannot launch because Windows runtime startup fails with
  `UtilBindVsockAnyPort:307: socket failed 1`; ABAP Unit was not run.


- Bulk project-stock reads now accept exclusions per request, including the UOM
  form. They validate request IDs and unique complete keys before stock reads
  or UOM conversion, merge request keys with call-wide keys once, and group
  shared reads by cutoff date and identical exclusion sets. The PLAN validator
  guards declarations, validation order, grouping, forwarding, and docs.
  Focused source-flow checks, all 92 SAP stub XML parses, line and field
  alignment, CRLF preservation, JavaScript guard parsing, and
  `git diff --check` passed. `validate:plan`, abaplint, and transpilation could
  not launch: Windows runtime startup fails with
  `UtilBindVsockAnyPort:307: socket failed 1`; ABAP Unit was not run.


- Reservation coverage results now include the exact excluded reservation and
  item keys alongside the excluded item count. Base-unit, UOM, and bulk result
  structures carry the same matching keys, allowing callers to reconcile each
  count; unknown and closed keys remain absent. The public count field uses
  `excluded_open_resv_items` to stay within ABAP's 30-character identifier
  limit. The PLAN validator and README cover this output.


- Single and bulk open-reservation reads now accept shared exclusions, and the
  bulk form also supports per-request keys. It validates complete unique keys
  and request references before repository reads, applies shared exclusions
  during reads and request keys when mapping results, and preserves request
  ordering. The PLAN validator covers the API, flow, and
  documentation. Focused source checks, JavaScript guard parsing, all 92 SAP
  stub XML parses, CRLF preservation, and `git diff --check` passed. Abaplint
  reports 0 issues across 247 files and transpilation succeeds. The PLAN
  validator cannot start in this WSL 1 environment (`WSL 1 is not supported`);
  ABAP Unit was not run.


- Full reservation-item reads now accept call-wide RESB exclusions, and their
  bulk API also filters per request after reusing shared WBS reads. Both forms
  validate complete unique keys and request IDs before repository access. The
  README, PLAN source guards, and ANOMALIES document the local-only behavior.
  Focused source-flow checks, PLAN guard JavaScript syntax parsing, all 92 SAP
  stub XML parses, CRLF preservation, and `git diff --check` passed. Abaplint
  reports 0 issues across 247 files and transpilation succeeds. `validate:plan`
  still cannot start in this WSL 1 environment; ABAP Unit was not run.


- Reservation coverage now returns per-item included quantities in the result
  and base units, plus source RESB required, withdrawn, and open quantities,
  material and entry units, requirement date, storage location, and batch.
  Excluded open rows retain their original RESB details. Included base quantities
  reconcile to base summary quantities; both detail sets carry through UOM and
  bulk results. README and PLAN source guards cover conversion and traceability.
  Focused source-flow checks, validator JavaScript syntax parsing, all 92 SAP
  stub XML parses, CRLF preservation, and `git diff --check` passed. Abaplint
  reports 0 issues across 247 files and transpilation succeeds. `validate:plan`
  cannot start in this WSL 1 environment (`WSL 1 is not supported`); ABAP Unit
  was not run.


- Corrected the scoped component preview's grouped available balance so eligible
  batch quantities contribute alongside residual location stock. The focused
  preview regression now passes: grouped availability is 8, allocation is 8,
  and shortfall is 4. Updated stale PLAN guard expectations for bulk lifecycle
  summaries whose result types now include count fields after commit status.

- Production confirmation window reads now accept a suboperation filter,
  requiring its parent operation. Unfiltered operation reads include both the
  base step's initial suboperation value and numbered suboperations, while
  page summaries keep those suboperations separate. Repository and service
  regression tests cover filtering, metadata, blank suboperations, and summary
  grouping. The full ABAP Unit suite passes, abaplint reports 0 issues across
  252 files, transpilation succeeds, and PLAN validation passes.

- Confirmation window searches can now filter by routing sequence while still
  allowing a sequence-only scope across operations. Repository OSQL fixtures
  and service tests cover orders with the same operation number in distinct
  sequences. The filter is checked against repository results and is described
  in README.md and PLAN.md. The full ABAP Unit suite passes, abaplint reports
  0 issues across 252 files, transpilation succeeds, and PLAN validation passes.

- Page-local operation summaries now include the first and last posting dates
  represented by returned confirmations. The regression fixture places a
  same-group confirmation in the lookahead slot and verifies it does not widen
  the summary date span or quantity totals. The full ABAP Unit suite passes,
  abaplint reports 0 issues across 252 files, transpilation succeeds, and PLAN
  validation passes.

- Operation summaries now also carry the AFVC description and control key
  already present on their confirmations, keeping the grouped result
  self-describing without another repository read. Tests verify routing
  metadata for separate production orders.


- Production confirmation window searches now filter for positive yield,
  rework, or scrap quantities, with multiple flags combined as an AND. SQL
  filters the repository reads and the service rejects rows that violate the
  selected quantity filters. Service and OSQL regression cases, README and
  PLAN guidance, and PLAN source guards were updated. Abaplint reports 0
  issues across 252 files, transpilation succeeds, PLAN validation passes, and
  the CRLF-aware diff check is clean. ABAP Unit was not run.


- Production confirmation operation summaries now echo `order_category`,
  preserving production/process context in aggregates without another read.
  Added regression assertions for summaries from both orders and updated the
  README, PLAN, and PLAN source guards. Abaplint reports 0 issues across 252
  files, transpilation succeeds, PLAN validation passes, and the CRLF-aware
  diff check is clean. ABAP Unit was not run.


- Added `SEARCH_CONF_WINDOW_BASE_UNIT`, which preserves the existing paged
  confirmation response and appends base-unit yield, rework, and scrap values
  per returned row. Material-unit ratios are read once per confirmation unit;
  unknown units, overflow, and nonzero quantities rounded to zero reject the
  conversion without returning partial results. The factory injects the UOM
  converter, and the README, PLAN, ANOMALIES, and PLAN source guards document
  the behavior and target-system assumption. Abaplint reports 0 issues across
  252 files, transpilation succeeds, PLAN validation passes, and the
  CRLF-aware diff check is clean. ABAP Unit was not run.


- Extended the confirmation base-unit result with `base_operation_summaries`,
  which merges source-unit groups for the same operation and reports base-unit
  yield, rework, and scrap totals, including separate non-reversed totals,
  counts, and date spans. The source-unit summaries remain available inside
  `raw_result`. Regression coverage checks mixed EA/BOX aggregation and
  reversal accounting; PLAN guards now enforce all three quantity totals.
  Abaplint reports 0 issues across 252 files, transpilation succeeds, PLAN
  validation passes, and the CRLF-aware diff check is clean. ABAP Unit was not
  run.


- Confirmation window results now expose a UTC `snapshot_timestamp`, captured
  immediately after the repository read and preserved by the base-unit wrapper.
  Added result assertions and documented that this marks query completion,
  while pages remain independent reads. Updated ANOMALIES and PLAN source
  guards. Abaplint reports 0 issues across 252 files, transpilation succeeds,
  PLAN validation passes, and the CRLF-aware diff check is clean. ABAP Unit
  was not run.


- Planned-order reads return `PLAF-PAART`; finish-window searches can match
  a nonblank type or select blank explicitly with `filter_order_type`. The
  repository filters before pagination, and the service checks returned scope.
  Added blank-match, invalid-flag, and scope-drift regressions. Abaplint
  reports 0 issues across 252 files, transpilation succeeds, PLAN validation
  passes, and the CRLF-aware diff check is clean. ABAP Unit was not run.


- Planned-order bulk and finish-window headers now include `PLAF-LGORT`.
  Finish-window callers can filter an exact location, including blank, by
  enabling `filter_storage_location`; supplying a location without the flag or
  an invalid flag fails before reading. Returned rows are checked against the
  selected location. Added assigned/unassigned selection, invalid-input, and
  scope-drift regression cases, plus PLAN validator coverage. Abaplint reports
  0 issues across 252 files, transpilation succeeds, PLAN validation passes,
  and the CRLF-aware diff check is clean. ABAP Unit was not run.


- Planned-order bulk and finish-window headers now include `PLAF-BESKZ`.
  Finish-window callers can filter its exact procurement indicator, including
  blank, with `filter_procurement_indicator`. Invalid enable flags or a value
  without the flag fail before the read, and returned rows must stay in scope.
  Added regression cases for indicator values, blank selection, invalid input,
  and repository scope drift. SAP's field mapping identifies `PLAF-BESKZ` as
  the procurement indicator; verify target DDIC and customizing values before
  integration. Abaplint reports 0 issues across 252 files, transpilation
  succeeds, PLAN validation passes, and the CRLF-aware diff check is clean.
  ABAP Unit was not run.


- Planned-order finish-window reads now accept an inclusive scheduled-finish
  date range on `PLAF-GLTRS`, in addition to the existing basic-finish range.
  Both valid bounds are required and returned scheduled dates are checked
  before pagination; cursor ordering remains based on basic finish date and
  planned-order number. Added assigned/out-of-range, partial, invalid-date,
  and scope-drift regression cases, with PLAN, README, ANOMALIES, and validator
  updates. Abaplint reports 0 issues across 252 files, transpilation succeeds,
  PLAN validation passes, and the CRLF-aware diff check is clean. ABAP Unit
  was not run.


- `READ_ORDERS_BY_FINISH_WINDOW` now supports `positive_quantity_only` to keep
  zero and negative planned-order quantities out of candidate supply when
  requested. The repository filters before pagination, and the service checks
  returned quantities against the same rule. Added positive/zero/negative,
  invalid-flag, and repository scope-drift regression cases and updated the
  PLAN validator. Abaplint reports 0 issues across 252 files, transpilation
  succeeds, PLAN validation passes, and the CRLF-aware diff check is clean.
  ABAP Unit was not run.


- Planned-order reads now include `PLAF-DISPO` and can filter by exact MRP
  controller, including blank through an explicit flag. SAP's planned-order
  field mapping identifies `DISPO` as the MRP controller. Added scope, blank,
  and invalid-flag regression cases; updated the PLAF stub and source guards.
  Abaplint reports 0 issues across 252 files, transpilation succeeds, PLAN
  validation passes, and the CRLF-aware diff check is clean. ABAP Unit was not
  run.


- Planned-order reads now include `PLAF-PLGRP` and can filter by exact
  production supervisor, including blank through an explicit flag. Added
  assigned/unassigned selection, invalid-flag, and scope-drift regression
  cases, plus stub and PLAN validator checks. Abaplint reports 0 issues across
  252 files, transpilation succeeds, PLAN validation passes, and the
  CRLF-aware diff check is clean. ABAP Unit was not run.


- Planned-order reads now return `PLAF-VERID` and can filter by exact
  production version, including blank through an explicit flag. Added
  assigned/unassigned selection, invalid-flag, and repository scope-drift
  regression cases. SAP documents `VERID` as the four-character production
  version on planned-order data. Abaplint reports 0 issues across 252 files,
  transpilation succeeds, PLAN validation passes, and the CRLF-aware diff
  check is clean. ABAP Unit was not run.


- Planned-order reads now return `PLAF-BERID` and can filter by exact MRP area,
  including blank through an explicit flag. Added assigned/unassigned,
  invalid-flag, and repository scope-drift regression cases, and extended the
  local PLAF stub and PLAN validator. SAP field mapping identifies `BERID` as
  the planned-order MRP area; target area assignment behavior still needs
  system validation. Abaplint reports 0 issues across 252 files, transpilation
  succeeds, PLAN validation passes, and the CRLF-aware diff check is clean.
  ABAP Unit was not run.


- Planned-order finish-window reads now accept an inclusive scheduled-start
  date range on `PLAF-GSTRS`, paired with the existing scheduled-finish range
  on `PLAF-GLTRS`. Both bounds must be valid and supplied together; the service
  validates returned rows, while pagination continues by basic finish date and
  planned-order number. Added match, partial/invalid-range, and scope-drift
  regression cases, and updated PLAN, README, ANOMALIES, and validator guards.
  Abaplint reports 0 issues across 252 files, transpilation succeeds, PLAN
  validation passes, and the CRLF-aware diff check is clean. ABAP Unit was not
  run.


- Planned-order finish-window searches now support opt-in scheduled start and
  finish time-of-day ranges on `PLAF-GSUZS` and `PLAF-GLUZS`. The ranges support
  midnight, validate HHMMSS bounds, can combine with scheduled-date ranges, and
  apply before pagination. Returned times are validated before range checks.
  Added shared time validation and regression cases for filtering,
  malformed/reversed bounds, malformed returned values, and returned-scope
  drift. PLAN, README, ANOMALIES, and validator guards are updated. Abaplint
  reports 0 issues across 252 files, transpilation succeeds, PLAN validation
  passes, and the CRLF-aware diff check is clean. ABAP Unit was not run.


- Planned-order finish-window searches now accept an inclusive range on the raw
  `PLAF-PSTMP` last-change timestamp. Either inclusive lower or upper bound can
  be used alone; supplied values must be positive, and two bounds must be
  ascending. Returned values are checked against every supplied bound. PLAN,
  README, ANOMALIES, and validator guards document the field semantics and
  SAP's warning that it may differ from apparent change time. Abaplint reports
  0 issues across 252 files, transpilation succeeds, PLAN validation passes,
  and the CRLF-aware diff check is clean. ABAP Unit was not run.


- Planned-order finish-window searches now support exact scheduled-start and
  scheduled-finish date filters, including explicit selection of blank dates.
  Nonblank values filter by default, malformed flags and dates fail validation,
  returned rows are checked against exact selections, and exact filters compose
  with existing inclusive date ranges. PLAN, README, ANOMALIES, and validator
  guards are updated. Abaplint reports 0 issues across 252 files, transpilation
  succeeds, PLAN validation passes, and the CRLF-aware diff check is clean.
  ABAP Unit was not run.


- Planned-order finish-window searches now support an exact basic start-date
  filter on `PLAF-PSTTR`, including explicit blank-date matching. Nonblank values
  filter by default, returned rows are checked against the exact selection, and
  exact filters intersect with the existing inclusive start-date range. PLAN,
  README, ANOMALIES, and validator guards are updated. Abaplint reports 0 issues
  across 252 files, transpilation succeeds, PLAN validation passes, and the
  CRLF-aware diff check is clean. ABAP Unit was not run.


- The planned-order read fake repository now mirrors the production filters for
  independent `PLAF-PSTMP` bounds and exact basic/scheduled-date selections.
  Validator guards check that the service fake remains in sync. Abaplint reports
  0 issues across 252 files, transpilation succeeds, PLAN validation passes,
  and the CRLF-aware diff check is clean. ABAP Unit was not run.


- Planned-order finish-window reads now accept independent inclusive lower and
  upper bounds on `PLAF-GSMNG` in the order unit, plus exact order-unit selection
  with blank matching. Either quantity bound can be used alone; zero is valid
  when enabled, and both bounds must be ascending. All filters apply before
  pagination. The service rejects invalid flags, reversed bounds, disabled
  bounds, and returned quantity/unit scope drift. The fake repository mirrors
  both filters. PLAN, README, ANOMALIES, and validator guards are updated.
  Abaplint reports 0 issues across 252 files, transpilation succeeds, PLAN
  validation passes, and the CRLF-aware diff check is clean. ABAP Unit was not
  run.


- Production confirmation-window rows now carry `scope_material` and
  `scope_plant` from their matching AFPO item. The service rejects returned
  confirmations whose material or plant does not match the request; bulk
  confirmation rows leave these window-scope fields initial. The fake
  repository, PLAN, README, ANOMALIES, and validator guards are updated.
  Abaplint reports 0 issues across 252 files, transpilation succeeds, PLAN
  validation passes, and the CRLF-aware diff check is clean. ABAP Unit was not
  run.


- Production confirmation-window searches can now select an exact blank
  `AFRU-MEINH` value with `filter_quantity_unit`. Nonblank units continue to
  filter by default; invalid flag values and returned unit-scope drift are
  rejected. The repository and fake apply the filter before pagination. PLAN,
  README, ANOMALIES, and validator guards are updated. Abaplint reports 0 issues
  across 252 files, transpilation succeeds, PLAN validation passes, and the
  CRLF-aware diff check is clean. ABAP Unit was not run.


- Production confirmation-window searches can now select an exact blank
  `AFVC-STEUS` value with `filter_control_key`. Nonblank control keys continue
  to filter by default; invalid flag values and returned control-key scope drift
  are rejected. The repository and fake apply the filter before pagination.
  PLAN, README, ANOMALIES, and validator guards are updated. Abaplint reports 0
  issues across 252 files, transpilation succeeds, PLAN validation passes, and
  the CRLF-aware diff check is clean. ABAP Unit was not run.


- Production confirmation-window searches can now select the exact initial
  `AFVC-PLNFL` operation sequence with `filter_operation_sequence`. Noninitial
  values continue to filter by default; invalid flags and returned sequence
  scope drift are rejected. The repository and fake apply the filter before
  pagination. PLAN, README, ANOMALIES, and validator guards are updated.
  Abaplint reports 0 issues across 252 files, transpilation succeeds, PLAN
  validation passes, and the CRLF-aware diff check is clean. ABAP Unit was not
  run.


- Production confirmation-window searches can now select the initial
  `AFVC-UVORN` base step alone with `filter_operation_suboperation`. By default,
  an initial suboperation still includes the base step and all suboperations;
  exact blank matching requires an operation number. Invalid flags and returned
  suboperation scope drift are rejected. The repository and fake apply the
  filter before pagination. PLAN, README, ANOMALIES, and validator guards are
  updated. Abaplint reports 0 issues across 252 files, transpilation succeeds,
  PLAN validation passes, and the CRLF-aware diff check is clean. ABAP Unit was
  not run.

- Production confirmation-window reads now filter and return the AFRU entered-by
  user. `filter_entered_by` enables exact blank matching; nonblank users filter
  by default. The repository applies the selector before pagination and the
  service validates returned user scope. PLAN, README, ANOMALIES, and validator
  guards are updated. Static gates pass; ABAP Unit was not run.

- Production confirmation-window reads can now filter by the inclusive
  AFRU-ERSDA entry-date range. Both valid ascending bounds are required;
  repository selection occurs before pagination, and service validation checks
  returned dates. Confirmation rows expose entry date separately from posting
  date. PLAN, README, ANOMALIES, and validator guards are updated. Static gates
  pass; ABAP Unit was not run.

- Production confirmation results now expose AFRU last-change date and user,
  filter by an optional inclusive last-change-date range, and support exact
  blank matching for `changed_by`. The repository applies both filters before
  pagination; the service validates date bounds and returned scope. PLAN,
  README, ANOMALIES, and validator guards are updated. Static gates pass; ABAP
  Unit was not run.

- Production confirmation-window searches now support inclusive AFRU-ERZET
  time-of-day bounds through `filter_entry_time`. Midnight is valid, enabled
  bounds must be valid and ascending, disabled bounds must be initial, and the
  range applies per entry date without wrapping midnight. Repository filtering
  precedes pagination and returned times are validated. PLAN, README, ANOMALIES,
  and source guards are updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window results now report `finish_filter_lost` when
  the later detail read has no item matching the selected material, plant,
  order category, and date ranges. A group-level count is included; rows remain
  visible for reconciliation and status drift stays separate. PLAN, README,
  ANOMALIES, and validator guards are updated. Static gates pass; ABAP Unit was
  not run.

- Production-order finish-window search now accepts `unreceived_quantity_only`
  to select matching AFPO items with positive order quantity remaining after
  receipts. The repository applies it before pagination, and `finish_filter_lost`
  detects when the later detail read no longer has a qualifying item. PLAN,
  README, ANOMALIES, and validator guards are updated. Static gates pass; ABAP
  Unit was not run.

- Production-order finish-window search now accepts optional inclusive lower
  and upper bounds for positive unreceived quantity in the AFPO order unit.
  Enabled bounds must be positive, disabled values must be initial, and lower
  cannot exceed upper. Bounds apply before pagination and participate in
  `finish_filter_lost` drift detection. PLAN, README, ANOMALIES, and validator
  guards are updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now filters by exact nonblank
  `AUFK-AUART` order type before pagination, returns order type on each detail
  item, and includes it in `finish_filter_lost` drift checks. PLAN, README,
  ANOMALIES, the AUFK stub, and validator guards are updated. Static gates pass;
  ABAP Unit was not run.

- Production-order finish-window search now supports `exclude_deleted`, which
  requires blank AUFK-LOEKZ and AFPO-XLOEK on the matching order/item before
  pagination. Detail-read drift checks both indicators. PLAN, README, ANOMALIES,
  and validator guards are updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now filters matching items by the
  AFPO-WEPOS receipt-expected indicator and AFPO-ELIKZ delivery-complete
  indicator. The selectors compose, run before pagination, and participate in
  `finish_filter_lost`. PLAN, README, ANOMALIES, and validator guards are
  updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now accepts `required_phase` values
  `1`, `2`, or `3` to filter by the matching AUFK phase indicator. Invalid
  values fail before reads; the repository filters before pagination and the
  detail read checks phase drift. PLAN, README, ANOMALIES, and validator guards
  are updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now filters by inclusive AUFK-ERDAT
  bounds through `created_date_from` and `created_date_to`. Both valid ascending
  dates are required; detail rows expose `created_date`, which participates in
  selection-drift detection. PLAN, README, ANOMALIES, the AUFK stub, and
  validator guards are updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now filters on nonblank AUFK-ERNAM
  through `order_created_by` and returns the creator on each detail item. The
  repository applies the selector before pagination and detail-read drift
  includes it. PLAN, README, ANOMALIES, the AUFK stub, and validator guards are
  updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now returns AUFK-AENAM/AEDAT and can
  filter by the last changer plus an inclusive last-change-date range. Both
  filters apply before pagination and participate in detail-read drift checks;
  date bounds must be valid, paired, and ascending. PLAN, README, ANOMALIES,
  the AUFK stub, and validator guards are updated. Static gates pass; ABAP Unit
  was not run.

- Production-order finish-window search now filters both marked and unmarked
  AFPO-WEPOS and AFPO-ELIKZ states. Opposite selectors for the same indicator
  are rejected, and selected states participate in pre-pagination filtering
  and detail-read drift checks. PLAN, README, ANOMALIES, and validator guards are
  updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window results now expose AUFK-KTEXT as
  `order_description`, with an optional exact nonblank description filter
  applied before pagination and during drift checks. PLAN, README, ANOMALIES,
  the AUFK stub, and validator guards are updated. Static gates pass; ABAP Unit
  was not run.

- Production-order finish-window search now supports inclusive order-quantity
  bounds on AFPO-PSMNG in the AFPO order unit. Enabled bounds must be positive,
  disabled values must be initial, and selected bounds run before pagination
  and participate in drift checks. PLAN, README, ANOMALIES, and validator guards
  are updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now accepts an exact optional
  `production_item` filter on AFPO-POSNR. Matching orders retain all their items;
  the query applies the selector before pagination and the detail read checks
  item-scope drift. PLAN, README, ANOMALIES, and validator guards are updated.
  Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now accepts an exact optional
  `order_unit` filter on AFPO-AMEIN. It applies before pagination, participates
  in detail-read drift checks, and identifies the unit used by order-quantity
  bounds. PLAN, README, ANOMALIES, and validator guards are updated. Static
  gates pass; ABAP Unit was not run.

- Production-order detail results now expose AFKO scheduled start and finish
  dates (`GSTRS` and `GLTRS`) and times (`GSUZS` and `GLUZS`) beside the existing
  basic dates. Finish-window selection and continuation still use the basic
  finish date. The AFKO stub, PLAN, README, ANOMALIES, and validator guards are
  updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now accepts paired inclusive
  `scheduled_finish_date_from` and `scheduled_finish_date_to` bounds on
  AFKO-GLTRS. Repository selection, key validation, and detail drift checks
  enforce the schedule range while sorting and cursors remain based on basic
  finish date. PLAN, README, ANOMALIES, and validator guards are updated. Static
  gates pass; ABAP Unit was not run.

- Production-order finish-window search now also accepts paired inclusive
  `scheduled_start_date_from` and `scheduled_start_date_to` bounds on AFKO-GSTRS.
  The query, returned-key validation, and detail drift checks enforce the range;
  ordering and cursors remain based on basic finish date. PLAN, README,
  ANOMALIES, and validator guards are updated. Static gates pass; ABAP Unit was
  not run.

- Production-order finish-window search now supports opt-in inclusive scheduled
  start and finish time-of-day ranges on AFKO-GSUZS and AFKO-GLUZS. Enabled
  ranges require valid ascending pairs, allow midnight, and apply before
  pagination; returned keys and detail items are checked. Basic-finish-date
  ordering remains unchanged. PLAN, README, ANOMALIES, and validator guards are
  updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now supports exact scheduled start and
  finish dates on AFKO-GSTRS and AFKO-GLTRS, including explicit blank matching.
  Nonblank values still filter by default, and exact selectors intersect with
  date ranges. Query keys and detail items check the selections. PLAN, README,
  ANOMALIES, and validator guards are updated. Static gates pass; ABAP Unit was
  not run.

- Production-order finish-window search now supports an exact AFKO-GSTRP basic
  start-date selector, including blank matching. Nonblank values filter by
  default and intersect with the optional date range. Key and detail reads check
  the selection. PLAN, README, ANOMALIES, and validator guards are updated.
  Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now supports `filter_order_description`
  to match an exact AUFK-KTEXT description, including blank. Nonblank values
  filter by default; the repository applies the selector before pagination and
  detail reads check for drift. PLAN, README, ANOMALIES, and validator guards are
  updated. Static gates pass; ABAP Unit was not run.

- Production-order finish-window search now supports `filter_order_changed_by`
  to match an exact AUFK-AENAM value, including blank. Nonblank values filter by
  default, and the detail read checks the selected value for drift. PLAN, README,
  ANOMALIES, and validator guards are updated. Static gates pass; ABAP Unit was
  not run.

- Production-order finish-window search now supports `filter_order_created_by`
  to match an exact AUFK-ERNAM value, including blank. Nonblank values filter by
  default, and the detail read checks the selected value for drift. PLAN, README,
  ANOMALIES, and validator guards are updated. Static gates pass; ABAP Unit was
  not run.

- Production-order items now expose AFPO-KDAUF as `sales_order`. Finish-window
  search can select an exact assignment, including blank with `filter_sales_order`;
  it applies before pagination and is checked during detail drift detection.
  PLAN, README, ANOMALIES, and validator guards are updated. Static gates pass;
  ABAP Unit was not run.

- Production-order items now expose AFPO-LGORT as `storage_location`. Finish-window
  search can select an exact location, including blank with
  `filter_storage_location`; the repository filters before pagination and the
  detail read checks for drift. PLAN, README, ANOMALIES, and validator guards are
  updated. Static gates pass; ABAP Unit was not run.

- Production-order items now expose AFPO-CHARG as `batch`. Finish-window search
  can select an exact batch, including blank with `filter_batch`; the repository
  filters before pagination and detail reads check the selection for drift.
  PLAN, README, ANOMALIES, and validator guards are updated. Static gates pass;
  ABAP Unit was not run.

- Production-order item reads now expose AFPO-KNTTP as
  `account_assignment_category`. Finish-window search selects an exact category,
  including blank with `filter_assignment_category`; repository filtering runs
  before pagination and detail reads check for drift. PLAN, README, ANOMALIES,
  and validator guards are updated. PLAN validation passed, abaplint found 0
  issues across 252 files, and transpilation updated 14 outputs. The scoped
  whitespace check passed. ABAP Unit was not run.

- Production-order item reads now expose AFPO-KDPOS as `sales_order_item`.
  Finish-window search selects an exact sales-order item, including blank with
  `filter_sales_order_item`; repository filtering runs before pagination and
  detail reads check for drift. Added the KDPOS DDIC stub and validator shape
  guard. PLAN validation passed, abaplint found 0 issues across 252 files, and
  transpilation updated 14 outputs. `git diff --check` passed; ABAP Unit was
  not run.

- Production-order item reads now expose AFPO-BERID as `mrp_area`.
  Finish-window search selects an exact MRP area before pagination, including
  blank with `filter_mrp_area`; detail reads validate the selected area for
  drift. PLAN, README, ANOMALIES, validator guards, and the AFPO stub shape are
  updated. PLAN validation passed, abaplint found 0 issues across 252 files,
  and transpilation updated 14 outputs. `git diff --check` passed; ABAP Unit
  was not run.

- Production-order item reads resolve AFPO-PROJN to external `wbs_element`
  through PRPS-POSID and retain the internal ID. Finish-window queries filter by
  exact external WBS element before pagination; blank selects items with no
  AFPO-PROJN assignment, and orphaned IDs remain visible in the internal field.
  Detail reads check the assignment for drift. PLAN validation passed, abaplint
  found 0 issues across 252 files, transpilation updated 8 outputs, and the
  scoped whitespace check passed. ABAP Unit was not run.

- Production-order item reads now expose AFPO-PLNUM as `planned_order`.
  Finish-window search filters the exact planned-order reference before
  pagination, including blank with `filter_planned_order`; detail reads check
  the reference for drift. The AFPO stub, PLAN, README, ANOMALIES, and validator
  guards are updated. PLAN validation passed, abaplint found 0 issues across
  252 files, transpilation updated 14 outputs, and the scoped whitespace check
  passed. ABAP Unit was not run.

- Production-order item reads now expose AFPO-PWERK as `planning_plant`, distinct
  from the production `plant` in AFPO-WERKS. Finish-window search filters an
  exact planning plant before pagination, including blank with
  `filter_planning_plant`; detail reads check the value for drift. The AFPO stub,
  PLAN, README, ANOMALIES, and validator guards are updated. PLAN validation
  passed, abaplint found 0 issues across 252 files, transpilation updated 14
  outputs, and the scoped whitespace check passed. ABAP Unit was not run.

- Production-order item reads now expose AFPO-VERID as `production_version`.
  Finish-window search filters the exact production version before pagination,
  including blank with `filter_production_version`; detail reads check the value
  for drift. The AFPO stub, PLAN, README, ANOMALIES, and validator guards are
  updated. PLAN validation passed, abaplint found 0 issues across 252 files,
  transpilation updated 14 outputs, and the scoped whitespace check passed.
  ABAP Unit was not run.

- Production-order item reads now expose AFPO-STRMP as
  `planned_order_start_date`. Finish-window search filters the exact source
  planned-order start date before pagination, including blank with
  `filter_plan_start_date`; nonblank dates must be valid, and detail
  reads check the value for drift. The AFPO stub, PLAN, README, ANOMALIES, and
  validator guards are updated. PLAN validation passed, abaplint found 0 issues
  across 252 files, transpilation updated 14 outputs, and the scoped whitespace
  check passed. ABAP Unit was not run.

- Production-order item reads now expose AFPO-DWERK as `delivery_plant` and
  distinguish it from the production and planning plants. Finish-window search
  filters the exact delivery plant before pagination, including blank with
  `filter_delivery_plant`; detail reads check the value for drift. The AFPO stub,
  PLAN, README, ANOMALIES, and validator guards are updated. PLAN validation
  passed, abaplint found 0 issues across 252 files, transpilation updated 14
  outputs, and the scoped whitespace check passed. ABAP Unit was not run.

- Production-order item reads now expose AFPO-SOBKZ as
  `special_stock_indicator`. Finish-window search filters the exact special
  stock indicator before pagination, including blank with `filter_special_stock`;
  detail reads check the value for drift. The AFPO stub, PLAN, README, ANOMALIES,
  and validator guards are updated. PLAN validation passed, abaplint found 0
  issues across 252 files, transpilation updated 14 outputs, and the scoped
  whitespace check passed. ABAP Unit was not run.

- Production-order item reads now expose AFPO-INSMK as `stock_type`. Finish-
  window search filters the exact stock type before pagination, including blank
  with `filter_stock_type`; detail reads check the value for drift. The AFPO
  stub, PLAN, README, ANOMALIES, and validator guards are updated. PLAN
  validation passed, abaplint found 0 issues across 252 files, transpilation
  updated 14 outputs, and the scoped whitespace check passed. ABAP Unit was not
  run.

- Production-order item reads now expose AFPO-WEMPF as `goods_recipient` and
  AFPO-ABLAD as `unloading_point`. Finish-window search can select either exact
  value before pagination, including blank with its selector flag; detail reads
  check both values for drift. The AFPO stub, PLAN, README, ANOMALIES, and
  validator guards are updated. PLAN validation passed, abaplint found 0 issues
  across 252 files, and transpilation updated 14 outputs. The scoped whitespace
  check passed; ABAP Unit was not run.

- Production-order item reads now expose AFPO-KDEIN as
  `sales_order_schedule_line`. Finish-window search selects the exact schedule
  line before pagination, including blank with `filter_sales_schedule_line`;
  detail reads check the value for drift. The AFPO stub, PLAN, README, ANOMALIES,
  and validator guards are updated. PLAN validation passed, abaplint found 0
  issues across 252 files, and transpilation updated 14 outputs. The scoped
  whitespace check passed; ABAP Unit was not run.

- Batch-expiry detail rows now report `days_to_expiration`, the signed calendar
  day difference between expiration and the request's as-of date: negative for
  expired batches, zero for expiry on that date, and positive for upcoming
  batches. Unit-aware rows preserve it in their nested base row. PLAN, README,
  ANOMALIES, and validator guards are updated. PLAN validation passed, abaplint
  found 0 issues across 252 files, transpilation updated 13 outputs, and the
  scoped whitespace check passed. ABAP Unit was not run.


- Batch-expiry exposure requests now accept an optional storage-location scope.
  Nonblank locations select that location by default; setting
  `filter_storage_location` selects an exact value, including blank. The filter
  scopes returned batch rows and stock totals after whole material/plant stock
  is used for reservation netting, and base/UOM results echo the scope. PLAN,
  README, ANOMALIES, and validator guards are updated. PLAN validation passed,
  abaplint found 0 issues across 252 files, transpilation updated 3 outputs,
  and the scoped whitespace check passed. ABAP Unit was not run.

- Batch-expiry exposure now accepts an exact batch scope. A nonblank batch filters
  by default; `filter_batch` selects an exact value including blank. This scope
  intersects with the optional storage-location filter, is applied after whole
  material/plant reservation netting, and is echoed and checked through the UOM
  wrapper. PLAN validation passed, abaplint found 0 issues across 252 files,
  transpilation updated 3 outputs, and the scoped whitespace check passed.
  ABAP Unit was not run.

- Batch-expiry exposure now accepts an exact valuation-type scope, including
  blank with `filter_valuation_type`. It intersects with storage-location and
  batch scopes, applies after whole material/plant reservation netting, and is
  echoed and checked by the UOM wrapper. PLAN validation passed, abaplint found
  0 issues across 252 files, transpilation updated 3 outputs, and the scoped
  whitespace check passed. ABAP Unit was not run.

- Batch-expiry exposure now filters by expiry-date source: `P` for plant-level
  dates or `G` for the global fallback. `filter_expiry_source` selects rows with
  no resolved source when `expiry_source` is blank; nonblank values are validated.
  The scope intersects with location, batch, and valuation filters and is echoed
  and checked by the UOM wrapper. PLAN validation passed, abaplint found 0 issues
  across 252 files, transpilation updated 13 outputs, and the scoped whitespace
  check passed. ABAP Unit was not run.

- Batch-expiry exposure now accepts optional inclusive `expiration_date_from`
  and `expiration_date_to` bounds. It validates both dates and their order before
  reads, filters every expiry cohort after reservation netting, omits undated rows
  while a bound is active, and echoes both bounds through the UOM wrapper. PLAN,
  README, ANOMALIES, and validator guards are updated. PLAN validation passed,
  abaplint found 0 issues across 252 files, transpilation updated 13 outputs, and
  the scoped whitespace check passed. ABAP Unit was not run.

- Batch-expiry exposure now includes `within_30d_batch_row_count` and four
  reservation-net category totals for positive-stock upcoming rows expiring from
  `as_of_date` through 30 calendar days later, inclusive, within the requested
  window. The UOM result carries base and requested-unit totals and preserves the
  count. PLAN, README, ANOMALIES, and validator guards are updated. PLAN validation
  passed, abaplint found 0 issues across 252 files, transpilation updated 13
  outputs, and the scoped whitespace check passed. ABAP Unit was not run.

- Batch-expiry exposure now reports cumulative 7-, 30-, and 90-day upcoming
  horizons. Each horizon counts positive-stock batch/location/valuation rows and
  totals unrestricted, reservation-net available, QI, and blocked quantities for
  expiry dates from as_of_date through the inclusive horizon within the request
  window. The shorter horizons are subsets of the longer ones; UOM results carry
  base and requested-unit totals and preserve counts. PLAN, README, ANOMALIES, and
  validator guards are updated. PLAN validation passed, abaplint found 0 issues
  across 252 files, transpilation updated 13 outputs, and the scoped whitespace
  check passed. ABAP Unit was not run.


- Batch-expiry risk reporting now includes disjoint 0–7, 8–30, 31–90, and
  91+ day buckets alongside the existing cumulative horizons. Each bucket
  reports positive-stock row counts and unrestricted, reservation-net available,
  quality-inspection, and blocked quantities; together they reconcile to the
  in-window upcoming totals. UOM results include base and requested-unit
  quantities and preserve counts. Boundary and conversion coverage is included
  in the stock-service ABAP Unit cases. PLAN, README, ANOMALIES, and validator
  guards are updated. PLAN validation and abaplint passed, transpilation passed,
  and the focused `reports_expiry_risk_buckets` ABAP Unit case passed. The full
  ABAP Unit run stopped at `reads_bulk_prod_receipts` on an AFPO duplicate-key
  insert; ANOMALIES records the issue.


- Batch-expiry exposure now aggregates all positive-stock rows sharing the
  earliest upcoming expiration date, in addition to identifying the first
  sorted batch row. Base and UOM results report the cohort count and four stock
  categories across locations, batches, and valuation types. Regressions cover
  a shared earliest date and converted totals. PLAN validation passed, abaplint
  found 0 issues across 252 files, transpilation passed, and the scoped
  whitespace check passed. The focused exposure, UOM, and risk-bucket ABAP Unit
  cases passed.


- Batch-expiry exposure now aggregates all positive-stock rows sharing the
  earliest expired date, alongside the existing first-row identity. Base and
  UOM results report the cohort count and four stock categories across batches,
  locations, and valuation types. Regression fixtures cover multiple batches
  on the same expired date and converted quantities. PLAN validation passed,
  abaplint found 0 issues across 252 files, transpilation passed, and the
  focused exposure, UOM, and risk-bucket ABAP Unit cases passed.

- The full transpiled ABAP Unit suite now passes. Updated the runner's AFPO,
  AFKO, AUFK, AFRU, and PLAF SQLite schemas to match their SAP stubs, added the
  missing PRPS OSQL test dependency, and repaired planned-order and
  production-order test fixtures that were masking service validation or
  omitting required base-unit context. Corrected confirmation conversion-call
  and reversed-scrap total expectations. ANOMALIES records the root causes and
  resolution.

- Batch-expiry exposure now splits the earliest expired-date cohort into plant,
  global fallback, and other/blank source counts. The three source counts
  partition `first_expiry_batch_count`; UOM results echo them unchanged. Regressions
  cover mixed plant/global sources in the same cohort for base and converted
  requests. PLAN validation passed, abaplint found 0 issues across 252 files,
  transpilation passed, and the full transpiled ABAP Unit suite passed.

- The earliest upcoming-date cohort now carries the same resolved-source split as
  the earliest expired cohort: plant, global fallback, and other/blank counts
  partition `next_expiry_batch_count`, with UOM results echoing each count.
  Regression fixtures cover same-date plant/global cohorts in base and UOM
  results. PLAN validation passed, abaplint found 0 issues across 252 files,
  transpilation passed, and the full transpiled ABAP Unit suite passed.

- Batch-expiry exposure now rolls up every positive-stock row sharing the earliest
  after-window expiry date. The base result returns the cohort count and four
  category totals; UOM results echo the count and convert each total. Regressions
  cover multiple rows on the same after-window date and converted totals. PLAN
  validation passed, abaplint found 0 issues across 252 files, transpilation
  passed, and the full transpiled ABAP Unit suite passed.

- The earliest after-window expiry cohort also reports plant, global fallback,
  and other/blank source counts. Those counts partition its cohort count and
  remain unchanged in UOM results. Base and converted tests use same-date rows
  from plant and global sources. PLAN validation passed, abaplint found 0 issues
  across 252 files, transpilation passed, and the full transpiled ABAP Unit
  suite passed.

- Batch-expiry exposure now totals unrestricted, available, quality-inspection,
  and blocked stock separately for plant-level, global fallback, and
  other/blank expiry sources. The totals use the same dated positive-stock scope
  as source row counts, including after-window rows; UOM results include base
  and requested-unit totals. Regression fixtures cover all source groups and
  stock categories in base and converted units.

- Expiry row counts now also split by source and status: expired, upcoming,
  and after-window rows each have plant, global-fallback, and other/blank
  counts. The three source counts partition each status total, and the UOM
  result echoes all nine counts. Base and converted regressions cover each
  source/status combination. PLAN validation, abaplint, transpilation, and the
  full transpiled ABAP Unit suite passed.

- Expiry results now include a fixed nine-row source/status matrix for plant,
  global fallback, and other/blank date sources across expired, upcoming, and
  after-window stock. Each row includes count and four category totals; UOM
  rows carry base and requested-unit amounts in the same stable order. Deep
  base/UOM regressions cover all rows, including empty intersections. PLAN
  validation, abaplint, transpilation, and full ABAP Unit passed.

- Batch-expiry dated details now support keyset pagination with a maximum page
  size of 500. The cursor follows the existing status/date/batch/location/
  valuation order, allows blank key components, and returns an exclusive
  continuation tuple and explicit total/current-page row counts. Summary
  aggregates remain complete across pages; UOM requests forward the same page
  contract. Undated details now have their own keyset page and continuation
  tuple. The opt-in `omit_undated_batch_rows` flag can suppress that detail list
  without changing its summary; each continuation performs a new stock read.

- Uncovered reservation details now support a separate keyset page of up to
  500 rows, ordered by reservation/item. The exclusive continuation cursor
  advances from the previous page's final key; full uncovered totals remain
  available, and the parallel key list follows the returned detail page. UOM
  results echo page metadata and convert the returned rows.

- Added ABAP Unit coverage for uncovered-reservation first and continuation
  pages, the unpaged default, page/key-list ordering, full summary preservation,
  UOM conversion, and invalid cursor/size inputs. Updated the PLAN guard for the
  pagination contract and its tests. `npm test` passed: PLAN validation,
  abaplint (0 issues across 252 files), transpilation (15 outputs updated), and
  the full transpiled ABAP Unit suite.


- Allocation trace pages now support reservation/item and `M`/`F` pass filters.
  Filters apply before keyset pagination, cursor keys must stay within the active
  filter, and full allocation summary totals remain unchanged. UOM results echo
  both filters; tests cover filtered continuation pages, pass selection, summary
  preservation, UOM conversion, and invalid scopes/cursors. `npm test` passed: PLAN
  validation, abaplint (0 issues across 252 files), transpilation, and the full
  transpiled ABAP Unit suite.


- Added `resv_allocation_summaries`, one row for every keyed open
  reservation, including fully allocated, partially allocated, and unallocated
  outcomes. The calculator preserves requested context and the quantity
  reconciliation; the expiry API pages summaries independently by
  reservation/item and UOM results carry base and requested amounts. Tests cover
  all three outcomes, continuation, summary preservation, UOM conversion, and bad
  cursor/size inputs. `npm test` passed: PLAN validation, abaplint (0 issues across
  252 files), transpilation, and the full transpiled ABAP Unit suite.

- Allocation summary pages can now be restricted to full, partial, or unallocated
  outcomes before counting and pagination. The page total reflects the selected
  outcome while allocation counters remain complete; UOM results echo the filter.
  Added tests for filtered summaries, UOM forwarding, and invalid selectors.
  PLAN validation, abaplint, transpilation, and the full ABAP Unit suite passed.

- Reservation-allocation summary pages now combine outcome selection, an exact
  reservation/item key, and inclusive required-date bounds before counting and
  pagination. Undated rows are excluded when a date bound is active; UOM results
  echo each scope. Summary rows also report `days_until_required` relative to
  `as_of_date`, with undated rows left at zero. Regression tests cover combined
  filters, UOM forwarding, invalid selectors and dates, cursor mismatches, and
  due-day offsets. `npm test` passed: PLAN validation, abaplint (0 issues across
  252 files), transpilation, and the full transpiled ABAP Unit suite.

- Allocation summaries now support `omit_resv_alloc_summary_rows`; the request
  retains selector-scoped totals while returning zero summary rows. Allocation
  trace details have the parallel `omit_allocation_detail_rows` option, which
  retains scoped trace counts and full pass totals. Both flags are validated and
  echoed by UOM results. Reservation summaries and trace rows also report
  `days_until_required`. `npm test` passed: PLAN validation, abaplint (0 issues
  across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Batch availability summaries now report open reservation demand by local
  allocation outcome: fully allocated, partially allocated, and unallocated.
  The totals partition eligible open demand, exclude reservations removed by
  the effective exclusions, and include base/requested-unit values in UOM
  expiry responses. Calculator, MARD repository, service, and UOM tests cover
  the quantities and their reconciliation. `npm test` passed: PLAN validation,
  abaplint (0 issues across 252 files), transpilation, and the full transpiled
  ABAP Unit suite.

- The expiry exposure result now partitions all eligible open reservation demand
  into overdue, due-today, future-dated, and undated buckets using `as_of_date`.
  These quantities include locally allocated demand, reconcile to total open
  reservation demand, and have base/requested-unit UOM values. Tests cover all
  four buckets, count/quantity reconciliation, and conversion. `npm test` passed:
  PLAN validation, abaplint (0 issues across 252 files), transpilation, and the
  full transpiled ABAP Unit suite.

- Reservation allocation summary pages now accept `filter_resv_alloc_date_bucket`
  with overdue, due-today, future-dated, or undated selection based on
  `as_of_date`. It composes with outcome, exact reservation, date-range, and
  cursor scopes before page counting; UOM results echo the selector. Tests cover
  all four buckets, invalid and inactive selectors, and UOM forwarding.
  `npm test` passed: PLAN validation, abaplint (0 issues across 252 files),
  transpilation, and the full transpiled ABAP Unit suite.

- Allocation trace pages now accept a due-date bucket selector (`O`, `T`, `F`,
  or `U`) based on `as_of_date`. It composes with reservation and allocation
  pass filters before counting and pagination; UOM results echo the selector.
  Tests cover all buckets plus invalid/inactive inputs and UOM forwarding.
  `npm test` passed: PLAN validation, abaplint (0 issues across 252 files),
  transpilation, and the full transpiled ABAP Unit suite.

- Allocation trace pages now accept inclusive `allocation_required_date_from`
  and `allocation_required_date_to` bounds. Either bound works alone; active
  bounds omit undated rows and must be valid and ascending. The scope composes
  with bucket, reservation, and pass filters before totals and pagination; UOM
  results echo it. Tests cover inclusive and one-sided ranges, undated omission,
  invalid dates, inverted bounds, and UOM forwarding. `npm test` passed: PLAN
  validation, abaplint (0 issues across 252 files), transpilation, and the full
  transpiled ABAP Unit suite.

- Expiry exposure results now include `resv_alloc_open_demand_bands`, a fixed 12-cell matrix of eligible open demand by allocation outcome and required-date bucket. Base and UOM rows preserve outcome/date order, zero combinations, counts, and reconciled quantities. Tests cover all date buckets and outcomes, a zero cell, total reconciliation, and UOM conversion. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Expiry exposure results now identify the earliest eligible open reservation due on or after `as_of_date`, with its reservation/item key and calendar-day distance. Overdue and undated rows are skipped; equal dates use reservation/item order. Tests cover choosing due today over overdue demand, a later input row winning the date/key tie-break, and UOM echoing. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Expiry exposure results now include seven non-overlapping open-reservation due horizons: overdue, due today, 1–7 days, 8–30 days, 31–90 days, over 90 days, and undated. Counts and quantities reconcile to all eligible open demand; UOM rows include converted values. Tests exercise every band, fixed row count, reconciliation, and UOM conversion. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Reservation allocation summary pages now support `filter_resv_alloc_due_horizon` for overdue, due today, 1–7, 8–30, 31–90, over 90, and undated rows. It composes with outcome, coarse date bucket, exact reservation, required-date range, and cursor scopes before totals and pagination. Active/inactive selector validation and UOM echo are covered. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Allocation trace pages now accept `filter_allocation_due_horizon` with overdue, due-today, 1–7, 8–30, 31–90, over-90, and undated scopes. It composes with reservation, pass, coarse bucket, and inclusive date-range filters before totals and pagination; invalid/inactive selectors are rejected and UOM echoes the selection. Tests cover every horizon, scope composition, and UOM forwarding. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Allocation trace pages now support an exact positive `allocation_sequence` filter. It composes with reservation, pass, date bucket, due horizon, and inclusive required-date scopes before counting and pagination; UOM results echo the selector. Invalid active and noninitial inactive values are rejected. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Reservation allocation summary pages now accept an exact positive `resv_alloc_sequence` filter. It composes with outcome, date bucket, due horizon, exact reservation, required-date range, and cursor scopes before summary counts and paging; overall allocation detail counts stay full-scope. UOM requests and results forward and echo the selector. Tests cover sequence 2, selector composition, invalid/inactive inputs, scope boundaries, and UOM echo. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Uncovered reservation detail pages now accept `filter_uncovered_due_horizon` for overdue, due today, 1–7, 8–30, 31–90, over 90, and undated rows. The filtered total is computed before cursor paging, while overall uncovered row and quantity summaries stay full-scope. UOM forwards and echoes the selector. Tests cover every band, continuation totals, invalid/inactive codes, and UOM echo. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Uncovered details now support `omit_uncovered_detail_rows`. Count-only requests retain the due-filter-scoped total and full-scope shortage summaries, clear both detail payloads, and require an unpaged request with no uncovered cursor. UOM results echo the flag. Tests cover payload omission, retained counts, invalid paging combinations, and UOM output. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Uncovered reservation pages now accept an exact positive `uncovered_sequence` filter. It composes with due horizon and cursor scopes before filtered totals and page results; full-scope shortage counts and quantities remain unchanged. UOM forwards and echoes both selector fields. Tests cover sequence 2, due-horizon composition, invalid/inactive inputs, and UOM forwarding. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Uncovered detail pages now accept inclusive `uncovered_required_date_from` and `uncovered_required_date_to` bounds. One-sided windows are supported, undated rows are omitted when a bound is active, and bounds compose with sequence, due horizon, and cursor filters before count/page output. UOM results echo the dates. Tests cover inclusive boundaries, a one-sided bound, undated omission, invalid dates, ascending order, and UOM echo. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Uncovered details now accept inclusive required-date bounds through `uncovered_required_date_from` and `uncovered_required_date_to`. Either bound can be used alone; active bounds omit undated rows and compose with sequence, due-horizon, and cursor scopes before totals and paging. UOM echoes both dates. Tests cover inclusive and one-sided windows, undated omission, invalid/inverted dates, and UOM echo. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Uncovered detail pages now accept an exact reservation/item key filter. Both
  keys are required when active and must be initial otherwise; it composes with
  sequence, due-horizon, date-window, and cursor scopes before counts and paging.
  An active cursor must match the selected key, and UOM requests/results forward
  and echo the selector. Tests cover combined filtering, invalid key states,
  cursor mismatch, and UOM echo. `npm test` passed: PLAN validation, abaplint
  (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit
  suite.

- Uncovered detail pages now filter by allocation outcome: `P` selects rows with
  positive local allocation and a remaining shortage, while `U` selects rows
  with no local allocation. The selector composes with reservation, sequence,
  due-horizon, date-window, and cursor scopes before filtered totals and paging;
  full-scope shortage summaries remain unchanged. Tests cover both outcomes,
  composed filtering, page totals, invalid active/inactive selectors, and UOM
  forwarding and echo. `npm test` passed: PLAN validation, abaplint (0 issues
  across 252 files), transpilation, and the full transpiled ABAP Unit suite.

- Allocation trace pages now accept `filter_allocation_val_type` to select an
  exact valuation type, including blank valuation types. It composes with the
  reservation, pass, sequence, date-bucket, due-horizon, and date-window scopes
  before filtered totals and paging; pass totals and reservation summaries stay
  full-scope. UOM forwards and echoes the selector. Tests cover valued and blank
  rows, invalid inactive input, and UOM echo. `npm test` passed: PLAN validation,
  abaplint (0 issues across 252 files), transpilation, and the full transpiled
  ABAP Unit suite.

- Allocation trace pages now select exact stock storage locations and batches
  with independent `filter_allocation_location` and `filter_allocation_batch`
  flags. Active blank keys can be selected; disabled values must be initial.
  The filters compose with valuation type and other trace scopes before totals
  and paging. UOM forwards and echoes both selectors. Tests cover combined
  stock keys, blank location and batch, invalid inactive input, and UOM echo.
  `npm test` passed: PLAN validation, abaplint (0 issues across 252 files),
  transpilation, and the full transpiled ABAP Unit suite.

- Allocation trace pages now accept inclusive `allocation_expiry_date_from` and
  `allocation_expiry_date_to` bounds against the stock row's expiry date. Either
  bound works alone, and active bounds omit undated trace rows. The scope is
  validated and applied before filtered counts and paging; UOM forwards and
  echoes it. Tests cover exact and one-sided windows, undated omission, invalid
  and inverted dates, and UOM echo. `npm test` passed: PLAN validation, abaplint
  (0 issues across 252 files), transpilation, and the full transpiled ABAP Unit
  suite.

- Allocation trace pages can now filter stock deductions by expiry status:
  `E` before `as_of_date`, `U` from `as_of_date` through `through_date`, `A`
  after `through_date`, and `D` undated. The selector composes with explicit
  expiry-date bounds and other trace filters before counts and paging. UOM
  forwards and echoes it. Tests cover each state and reject invalid or inactive
  values. `npm test` passed: PLAN validation, abaplint (0 issues across 252
  files), transpilation, and the full transpiled ABAP Unit suite.

- Expiry exposure results now include a fixed four-row allocation summary for
  expired, within-window, after-window, and undated trace rows. Counts and
  base-unit quantities reconcile to matched plus fallback allocations; UOM
  results carry requested-unit quantities. The summary remains full-scope under
  trace filters and pagination. Tests cover all four states and quantity/count
  reconciliation. `npm test` passed: PLAN validation, abaplint (0 issues across
  252 files), transpilation, and the full transpiled ABAP Unit suite.

- Filtered allocation trace summaries now include `filtered_alloc_src_gap_bands`,
  a fixed 60-cell expiry-source × signed-gap-band × pass matrix computed over
  active trace filters before pagination. Empty cells remain present; counts
  and quantities reconcile to the filtered totals. UOM results preserve the
  matrix order and counts and convert its quantities. Tests cover populated and
  empty cells, reconciliation, and conversion. The Windows `npm` wrapper could
  not start under the current WSL 1 environment, so its stages were run directly:
  PLAN validation passed, abaplint reported 0 issues across 252 files,
  transpilation passed, and the full transpiled ABAP Unit suite exited 0.

- Filtered allocation summaries now also provide fixed source/status/pass
  (24-cell), source/required-date-horizon/pass (42-cell), relation/pass
  (8-cell), and source/relation/pass (24-cell) matrices. Every matrix is built
  after active trace filters and before pagination, retains empty cells, and
  reconciles row counts and quantities to the filtered totals. UOM rows keep
  the same keys and counts and convert quantities. Coverage checks populated
  and empty cells, reconciliation, and UOM conversion. PLAN validation passed,
  abaplint reported 0 issues across 252 files, transpilation passed, and the
  full transpiled ABAP Unit suite exited 0.

- Filtered allocation traces now expose `filtered_max_due_after_exp_gap` and
  `filtered_max_before_exp_gap`, identifying the first row at each largest
  positive signed expiry/required-date difference within the active filter
  scope. Both retain reservation, pass, stock keys, dates, and quantity; UOM
  results preserve the identity and convert quantity. Tests cover both gap
  directions, no-match initial values, UOM quantities, and filtered scoping.
  PLAN validation passed, abaplint reported 0 issues across 252 files,
  transpilation passed, and the full transpiled ABAP Unit suite exited 0.

- Added compact filtered marginal summaries for expiry status by pass
  (`filtered_alloc_exp_statuses`, 8 cells) and required-date horizon by pass
  (`filtered_alloc_due_horizons`, 14 cells). Both are calculated across the
  active trace-filter scope before pagination, keep zero combinations, and
  reconcile to filtered counts and quantities. UOM results preserve order and
  convert quantities. PLAN validation passed, abaplint reported 0 issues across
  252 files, transpilation passed, and the full transpiled ABAP Unit suite
  exited 0.

- Filtered allocation trace summaries now include an eight-cell required-date
  bucket/pass marginal and a 32-cell expiry-status/required-date-bucket/pass
  risk matrix. Both use the active trace filters before pagination, retain
  empty cells, and reconcile counts and quantities to the filtered total. UOM
  results preserve ordering and counts and convert quantities. Tests cover
  populated and empty cells, reconciliation, and UOM conversion. PLAN validation
  passed, abaplint reported 0 issues across 252 files, transpilation passed,
  and the full transpiled ABAP Unit suite exited 0.

- Allocation exposure results now include `allocation_coverage_pct` and
  `allocation_shortage_pct`, calculated from matched/fallback allocation and
  uncovered demand over eligible open demand. Both report two decimal places,
  are zero when demand is zero, and UOM results echo them unchanged. Tests cover
  partial coverage, zero demand, and UOM output. PLAN validation passed,
  abaplint reported 0 issues across 252 files, transpilation passed, and the
  full transpiled ABAP Unit suite exited 0.

- Reservation allocation summary rows now include `allocation_coverage_pct`
  and `allocation_shortage_pct`, calculated per reservation from allocated and
  uncovered quantities over open demand. Both use two decimal places and carry
  unchanged through UOM results and summary paging. Calculator tests cover
  full, partial (66.67% / 33.33%), and zero allocation; UOM tests cover the
  echoed percentages. PLAN validation passed, abaplint reported 0
  issues across 252 files, transpilation passed, and the full transpiled ABAP
  Unit suite exited 0.

- Reservation summary pages now support inclusive coverage-percentage and
  uncovered-quantity ranges. Coverage bounds accept 0–100; uncovered bounds
  are nonnegative material-base-unit quantities. Both selector families check
  flag/value consistency and ascending ranges, filter counts and pages, and
  echo through UOM results. Tests cover zero boundaries, continuation pages,
  invalid inputs, and UOM echoes.

- Reservation summary rows now report `matched_share_pct` and
  `fallback_share_pct` alongside total coverage and shortage. The new values
  show each allocator pass as a two-decimal percentage of that reservation's
  open demand and echo unchanged in UOM summaries. Calculator tests cover
  matched-only, fallback-only contribution, and mixed shares; service tests
  verify UOM echoes.

- Paged uncovered-reservation rows now carry the same four allocation
  percentages as reservation summary rows, based on each row's open
  quantity. UOM detail rows echo those percentages unchanged.

- Aggregate expiry exposure now reports matched-pass and fallback-pass shares of eligible open demand. They use two decimals, default to zero without eligible demand, and are echoed unchanged by UOM results.

- Uncovered detail pages can now filter by an inclusive shortage-percentage
  range. Bounds accept 0–100, compose before filtered totals and pagination, and
  echo through UOM results. Tests cover both inclusive endpoints, cursor
  continuation, UOM forwarding, and invalid bounds. PLAN validation passed,
  abaplint reported 0 issues across 252 files, transpilation passed, and the
  full transpiled ABAP Unit suite exited 0.

- Filtered uncovered details now include a fixed seven-row due-horizon breakdown, retaining empty bands and summing the same selector-matching rows before cursor and paging. Per-band partial and unallocated row counts partition each band count. Each dated band reports its first and last required dates; undated and empty bands leave both dates initial, and UOM results echo the dates. Band quantities are now split between partial and unallocated rows for both open demand and uncovered shortage, with base/source conversions in UOM results. Each band reconciles open, allocated, matched, fallback, and uncovered quantities and reports weighted coverage, shortage, matched, and fallback percentages; UOM results preserve counts, convert quantities, and echo percentages. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full transpiled ABAP Unit suite exited 0.

- Due-horizon summaries now report partial-only coverage, shortage, matched, and fallback percentages using `partial_open_qty` as the denominator. All four remain zero without partial rows and are echoed through UOM summaries. Tests cover mixed partial/unallocated bands, zero-partial bands, and UOM echoes. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Uncovered detail rows now carry their computed due-horizon band (`O`, `T`, `1`–`4`, or `U`) and their `P`/`U` allocation outcome; UOM detail rows echo both codes. The seven-band fixture checks every horizon code, and outcome tests cover partial, unallocated, and UOM results. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Filtered uncovered totals now report partial and unallocated open-demand and shortage quantities at the top level. The two open totals partition filtered open demand, and the two shortage totals partition filtered uncovered quantity. UOM results convert all four; mixed partial/unallocated regressions verify base and source totals. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Top-level partial coverage, shortage, matched, and fallback percentages now use partial open demand as their denominator, matching the due-horizon breakdown. They remain zero when no partial rows match and are echoed unchanged in UOM results. Mixed-row tests prove the partial denominator and UOM echo. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Overdue uncovered details now carry a fixed age band for 1–7, 8–30, 31–90, and more than 90 days late. The field stays initial on due/future/undated rows; boundary regressions cover the range edges and UOM echoes.

- Filtered uncovered results now include a fixed four-band overdue-age summary (1-7, 8-30, 31-90, and over 90 days late). It aggregates the selector-matching rows before cursor and paging, keeps empty bands, converts base quantities to UOM, and reports weighted allocation percentages. Page-limited and UOM regressions cover the summary. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Uncovered detail requests can now select one overdue-age band with `filter_uncovered_age_band` and `uncovered_age_band`. The filter composes with the existing selectors before counts, summaries, and page selection; UOM requests and results echo both values. Tests cover age-band selection, paging, UOM echo, and invalid active and inactive values. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Overdue-age summaries now split open demand and shortage quantities between partially allocated and unallocated rows. The split quantities partition each band's totals, and partial-only coverage, shortage, matched, and fallback percentages use partial open demand as their denominator. UOM summaries convert the four quantities and echo the percentages. Mixed-outcome and UOM tests pass; PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Overdue-age summary rows now include the earliest and latest required dates within each band. Dates are initial for empty bands and echo unchanged through UOM results. Tests cover bands spanning multiple dates, empty bands, and UOM echoes. PLAN validation passed, abaplint found 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Uncovered detail filters can now set an inclusive overdue-age day range with optional lower and upper bounds. The range composes with age-band and other selectors before counts and paging; due-today, future, and undated rows are excluded. UOM requests and results echo both bounds. Tests cover inclusive 8/30-day boundaries, one-sided bounds, selector composition, paging, UOM echo, and invalid values. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Uncovered overdue detail rows now expose `overdue_age_days`, the exact positive calendar-day age used by the new range selector. Due-today, future, and undated rows leave it initial, and UOM details echo it unchanged. Boundary tests cover 1, 7, 8, 30, 31, 90, and 91 days, plus a due-today row and UOM output. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- The fixed expired source-by-age matrix now reports the earliest and latest expiration date in each of its 12 rows. Empty combinations keep both dates initial; UOM results echo the date spans. Base and UOM fixtures include a source-age band spanning 1 and 7 days plus empty combinations. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Upcoming and after-window source-band matrices now include first/last expiration dates in every row, with empty rows initial and UOM rows echoing the spans. Base regressions include multi-date rows in both windows; UOM regressions verify date propagation. PLAN validation passed, abaplint reported 0 issues across 252 files, transpilation passed, and the full ABAP Unit suite exited 0.

- Reservation allocation summary omission now scans and enriches the local bulk
  result directly, avoiding the response-table copy and sort when payload rows
  are suppressed. The existing omitted-summary regression checks selector-scoped
  totals and zero returned rows. Validation was not rerun: the configured Node
  shim is unavailable in this WSL 1 environment, as recorded in ANOMALIES.md.

- Allocation-trace omission now computes filtered totals and risk summaries
  against the assigned local bulk row, without copying detail payload into
  the response. It sorts the local rows in place to preserve stable gap
  selection. The omitted-detail regression now checks the selected quantity;
  the summary omission regression checks its filtered quantities. The configured
  Node-based validation gates remain unavailable in this WSL 1 environment.

- Uncovered-detail omission now skips response row and key materialization. A
  shared row mapper feeds the selector-scoped totals, due-horizon bands, and
  overdue-age bands directly from repository reservations in summary-only mode.
  The existing omission regression now asserts filtered demand, shortage, and
  due-band totals. Configured Node-based gates could not run in this WSL 1
  environment; see ANOMALIES.md.

- Planned-order finish-window searches now filter and return the exact special procurement type (`PLAF-SOBES`), including explicit blank matching. Service and Open SQL regressions cover nonblank/blank selection, invalid or inactive selectors, repository scope drift, projected values, and lookahead pagination when earlier rows do not match. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Expiry UOM regressions now verify open, matched, fallback, overdue, due-today, future, undated, excluded, and uncovered reservation quantities in base and requested units. The uncovered fixture spans all four date buckets and checks its earliest overdue identity and day distance. Tests also cover exclusion keys/counts, next-open identity/date, the fixed seven-band horizon and 12-cell outcome/date matrix, row-count reconciliation, and converted band totals. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Expiry UOM tests now assert the earliest expired and upcoming row identities, date sources, and all four base/requested-unit category quantities. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Undated expiry UOM coverage now checks that first-row selection follows batch, location, and valuation order, and verifies its identity and four converted category balances. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Earliest after-window summary regressions now check storage location, valuation type, and plant/global/other source identity in both base and UOM results. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Batch expiry storage-location filtering now has regressions for implicit exact nonblank selection, explicit blank selection across dated and undated stock, UOM echoes, and invalid-flag rejection before repository reads. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Expiry risk UOM regressions now assert all category conversions in the disjoint 8–30, 31–90, and over-90-day buckets, including each bucket’s row count. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Expiry UOM coverage now checks all four category totals for the returned dated page and the returned undated page, including fractional conversion rounding. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Expiry reporting tests now assert all four base-category balances for first-expired and next-upcoming rows, and all base/requested-unit categories for expired, upcoming, after-window, next-date, and undated summaries. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Batch expiry filtering now has regression coverage for exact nonblank batch selection, its intersection with storage location, and explicit blank-batch selection across dated and undated stock. Base and UOM results check selector echoes, selected identities, category totals, conversions, and rejection of an invalid selector flag before repository reads. The configured Node-based gates remain unavailable in this WSL 1 environment.

- STO source-plant bulk regressions now cover atomic rollback after a second-supplier failure with a third supplier left unattempted, including separate attempted-failure and skipped counts. The atomic commit-failure test also checks `stopped_on_failure` when enabled; the PLAN validator requires both cases. Runtime validation remains unavailable in this WSL 1 environment.

- Cost-center issue and reversal bulk stop-on-failure regressions now prove that a successful earlier reservation stays committed, a later failed group is counted as failed, and the following group is retained as skipped. Invalid stop flags are checked on base, UOM, remaining-quantity, and exact-item entry points before reservation reads. The configured runtime gates remain unavailable in this WSL 1 environment.

- STO plant-pair stop-on-failure coverage now asserts that earlier successful pairs remain committed, the failed pair was attempted but not committed, and every skipped pair never called the BAPI. The PLAN validator requires these transaction-boundary assertions. Runtime validation remains unavailable in this WSL 1 environment.

- Atomic STO plant-pair create-failure coverage now enables `iv_stop_on_failure` and verifies `stopped_on_failure`, failed and skipped counts, unattempted rows, and rollback. The PLAN validator requires this atomic failure path. Runtime validation remains unavailable in this WSL 1 environment.

- Added stop-on-failure coverage through `create_for_atp_plant_pairs`. The regression confirms the wrapper forwards the option to the executor, commits the first pair, and leaves later pairs skipped without BAPI calls. PLAN validation now requires the ATP wrapper case; runtime validation remains unavailable in this WSL 1 environment.

- Extended the PLAN validator to check all 34 public STO pair methods that accept `iv_atomic`: each must expose `iv_stop_on_failure` and either validate it directly or forward it to the next method. Source inspection found no current forwarding gaps. Runtime validation remains unavailable in this WSL 1 environment.

- Added a repository-wide PLAN validator guard for all public methods declaring `iv_stop_on_failure`. Across 152 methods in 12 classes, each currently validates the flag or forwards it to a downstream method. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Added a repository-wide PLAN validator guard for public methods declaring `iv_test_run`. A source scan covered 403 methods in 16 classes, including the public class method, and found each uses or forwards the simulation flag. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Added a repository-wide PLAN validator guard for public methods declaring `iv_atomic`. A source scan covered 58 methods in five classes and found each validates or forwards atomic mode. The configured Node-based gates remain unavailable in this WSL 1 environment.

- Added direct coverage for the base expired-scrap preview across unrestricted, QI, and blocked stock. Tests verify expired and soon-to-expire allocation order, exclude stock expiring on the posting date, check preview metadata and location ranks, validate strict full-quantity shortfall clearing, and reject an unknown category. The PLAN validator requires the direct base-method cases. Runtime gates remain unavailable in this WSL 1 environment.

- Dated expiry pages now include a fixed source-by-expired-age-band matrix for
  returned rows, with date spans, category quantities, and shares of the page's
  expired rows. UOM output converts all four categories. Regressions cover all
  age boundaries, source grouping, empty pages, summary-only output, and unit
  conversion. PLAN, README, and the PLAN validator now include this contract.
  The configured Node gates could not run in this WSL 1 environment.

- Upcoming and after-window expiry pages now expose fixed source-by-lead-time
  matrices based on the returned page, alongside their full-scope summaries.
  Each matrix reconciles row counts and four stock categories; UOM results
  convert each category. Regressions cover 0/1, 7, 8, 30, 31, 90, and 91-day
  boundaries, source mapping, empty pages, date spans, and UOM conversions.
  PLAN, README, and validator guards now cover the contract. Runtime validation
  remains unavailable in this WSL 1 environment.

- Dated expiry pages now also report source-by-window-band summaries for
  upcoming and after-window stock. Upcoming aging follows `as_of_date` through
  the inclusive `through_date`; after-window aging starts one day after the
  window. The page matrices reconcile to their status counts and categories and
  preserve all page keys and quantities through UOM conversion. Tests include
  empty and summary-only pages plus each inclusive band edge. Runtime gates are
  still unavailable in this WSL 1 environment.

- Page expiry status summaries now include status-specific first/last expiration
  dates and elapsed spans, while retaining the independent overall page range.
  Regressions cover upcoming and after-window date spans, cursor continuation,
  empty and summary-only results, and UOM metadata. PLAN, README, and validator guards include the new
  contract. Runtime gates remain unavailable in this WSL 1 environment.

- Page status rows now report each status's percentage of the corresponding
  page-wide stock-category total. Shares handle zero category totals as zero
  and are echoed through UOM output. Regression coverage exercises mixed
  statuses, category-specific zero cases, empty and summary-only pages, and UOM.

- The page source/status matrix now reports each source/status pair's share of
  each returned-page stock-category total. Tests cover source/status rounding,
  zero categories, empty and summary-only pages, and UOM echo.

- Full-scope dated source/status rows now report category shares against the
  complete matching dated totals, including after-window stock, independent of
  page detail and cursors. UOM rows echo them. Regressions use distinct
  after-window quantities to prove page-limit and cursor independence, plus
  summary-only output and page-local source/status shares.

- Undated summary-only base and UOM regressions now preserve raw unknown `expiration_date_source = 'X'` on the first matching batch while grouping its source totals under `O`. The PLAN validator checks both results.
- Full source/status quantity shares now have base and summary-only UOM regressions for an active expiry-status filter, proving excluded statuses do not affect the denominators.
- Planned-order create regressions now prove stop-on-failure at a failed final commit and through suggestion-based receipts. They retain earlier commits, mark remaining lot rows skipped with their suggestion and receipt indexes, and report separate outcome counts. Default suggestion creation also continues after a commit failure. The PLAN validator checks these paths.

- Added a suggestion-based planned-order test-run regression spanning two
  suggestions. A failed receipt marks later rows skipped with original
  suggestion and receipt indexes, while outcome counts remain separate and no
  commit or rollback runs. Expanded invalid test-run flag coverage across all
  four create entry points and added PLAN validator guards. Runtime gates remain
  unavailable in this WSL 1 environment.

- Added undated expiry-source category shares for both returned-page and
  full filtered summaries. Each stock category uses its matching scope total,
  zero denominators produce zero, and UOM results preserve the shares. Updated
  PLAN and README contracts.

- Added the full-scope `expiry_statuses` summary for expired, upcoming, and
  after-window dated stock. It reports count and category shares, date spans,
  and base/UOM quantities, independent of detail paging. Updated PLAN and
  README contracts.

- Added direct P/G/O dated expiry-source summaries for returned pages and the
  full filtered scope, including category shares and date ranges. Full values
  remain independent of detail cursors and page limits, and UOM results preserve
  shares while converting quantities. Updated PLAN and README.

- Added `status_row_share_pct` to dated page and full source/status matrices. It
  reports each source's share within its expiry status while preserving the
  existing overall row and category shares; UOM results echo the new percentage.
  Updated PLAN and README contracts.

- Added `source_row_share_pct` to the dated page/full source-status matrix so
  both status-relative and source-relative row percentages are available. The
  two-source expired regression checks both denominators, full/page summaries,
  empty, summary-only and filtered results, and UOM percentage echo with converted
  quantities. PLAN validator guards cover the calculations and mappings;
  runtime validation remains unavailable in this WSL 1 environment.

- Added mixed-quantity undated-source regressions for all four category shares.
  They cover full and one-row page denominators, zero-share rows, empty
  full/page denominators, summary-only UOM output, unknown source grouping
  under `O`, and UOM percentage echo. The PLAN validator checks all four
  calculations, both UOM mappings, and the regression cases; runtime gates
  remain unavailable.
- Added status-relative category shares to every dated source/status cell.
  Page percentages use the matching page status totals; full percentages use
  full status totals. Regressions cover four categories, rounding, zero
  denominators, empty results, page scope, and UOM echo. PLAN and README
  contracts plus source guards were updated; runtime validation remains
  unavailable in this WSL 1 environment.
- Added source-relative category shares to dated source/status cells, paired
  with the status-relative shares. Page and full denominators come from the
  matching source summaries; UOM output echoes all four categories. Regressions
  cover mixed status/source quantities, page-local values, zero denominators,
  and UOM results. PLAN validator guards cover calculations, mappings, and
  fixtures; runtime validation remains unavailable in this WSL 1 environment.
- Added category quantity shares to the full and page expired source/age
  matrices. Page denominators use returned expired quantities; full
  denominators use full expired totals. Coverage includes limited pages, zero
  denominators, empty results, UOM echo, and PLAN validator guards; runtime
  validation remains unavailable in this WSL 1 environment.
- Extended the full and page upcoming/after-window source-band matrices with
  four stock-category quantity shares. Shares use their matching full or page
  status totals, remain zero for empty categories, and pass through UOM output.
  Regressions cover all categories, limited-page denominators, empty results,
  UOM echo, and PLAN source guards; runtime validation remains unavailable.

- Added source-relative and band-relative row percentages to full and page
  expiry source/age and source/window matrices. The percentages use matching
  status-scope denominators, stay zero for empty groups, and pass through UOM
  results. Regressions cover full, page, and UOM output; a filtered one-row
  page proves the full 50% shares differ from page-local 100% shares. Empty
  cases and PLAN, README, and validator guards are included.

- Added source-relative quantity shares to the full and page expiry
  source/age and source/window matrices. Each of the four categories uses its
  matching source total; empty categories yield zero and UOM output echoes the
  percentages. Regressions cover base, limited-page, empty, and UOM scopes;
  PLAN, README, and validator guards were updated.
- Added band-relative category quantity shares to full and page expiry age/window matrices. Each `band_*_share_pct` uses the matching age or lead-time band total across sources, with independent denominators for full and returned-page data. Mixed-source fixtures verify 42.86/57.14 age shares and 66.67/33.33 window shares, while limited and summary-only pages, empty bands, and UOM echoes cover page scope and zero denominators. PLAN, README, and validator contracts now include the fields; runtime gates still need an available Node toolchain.
- Added `available_pct_of_unrestricted` to every full and page expiry source/age and source/window cell. It measures reservation-net available quantity as a percentage of unrestricted quantity per cell, uses zero when unrestricted quantity is zero, and is echoed by all six UOM matrices. Typed full-scope rows and base, limited-page, empty, summary-only, and UOM regressions cover the calculation; PLAN, README, and validator guards were updated. Runtime gates remain unavailable because Windows Node interop fails in this WSL environment.
- Added `reservation_deduction_qty` to each full/page age and window cell as unrestricted minus reservation-net available quantity. UOM matrices expose the same value in base and requested units, including signed differences. All six aggregation scopes and conversions have explicit mapping; regressions cover mixed-source cells, limited pages, empty and summary-only results, and UOM output. PLAN, README, and validator checks were updated; runtime gates remain blocked by WSL Windows-process interop.
- Added availability ratios and signed reservation deductions to full and page
  dated status/source summaries, undated-source summaries, and source/status
  cells. UOM output echoes the ratio and carries base and converted deductions.
  Regressions cover full/page/limited/cursor, empty and summary-only scopes,
  zero denominators, availability above 100%, and converted negative
  deductions. PLAN guards and README/PLAN contracts were updated; runtime gates
  remain unavailable in this WSL setup.

- Extended `available_pct_of_unrestricted` and signed
  `reservation_deduction_qty` to each returned dated, undated, and
  after-window batch row. UOM detail echoes the percentage and converts the
  signed deduction. Added coverage for dated/undated details, after-window
  rows, and a negative conversion; PLAN, README, and validator guards now
  describe these fields. Runtime verification remains unavailable in this WSL
  setup.

- Added direct availability ratios and signed reservation deductions to the
  dated and independent undated expiry page totals. UOM results echo the ratios
  and expose base/requested-unit deductions; regressions cover positive, empty,
  and negative pages. PLAN, README, and validator guards describe the new fields.

- Added `undated_avail_pct` and signed
  `undated_resv_deduct_qty` to full-scope undated totals. UOM results
  echo the ratio and convert the deduction, including summary-only results.
  Empty and negative cases are covered alongside positive totals; PLAN, README,
  and validator guards include the contract.

- Added combined full-scope dated unrestricted and available totals with a
  guarded availability ratio and signed reservation deduction. UOM maps the
  base totals and converts the deduction; summary-only, empty, and negative
  fixtures cover the contract. PLAN, README, and validator guards were updated.

- Added a production-order finish-window receipt-progress selector for not
  started, partial, complete, over-received, and invalid quantities. The
  repository applies it before pagination across all active-status and cursor
  query branches, and the detail read rechecks the matching item's status for
  scope drift. Added service/repository regressions, PLAN/README documentation,
  and validator guards. Runtime gates remain unavailable in this WSL setup.

- Extended production-order finish-window selection with inclusive received-
  quantity bounds in the AFPO order unit. Zero bounds are supported, invalid
  flags/negative values/reversed ranges fail before repository reads, and both
  bounds are applied before pagination and rechecked against detail rows.
  Regressions cover zero, exact values, filtered pagination, detail-filter drift, and input errors;
  PLAN/README and validator guards were updated. Runtime gates remain
  unavailable in this WSL setup.

- Audited the production-order finish-window drift contract against the
  service's detail predicate. Updated the consolidated PLAN, README, and
  ANOMALIES lists to include receipt-progress state and received-quantity bounds,
  and extended the validator guard for the full set.

- Added `matches_finish_selection` to each production-order item result.
  Finish-window reads mark every detail item that still matches the selected
  item scope while retaining nonmatching items; number-based bulk reads leave
  the marker initial. Regressions cover a matching and nonmatching item on one
  returned order and the bulk default. PLAN/README and validator guards were
  updated.

- Added `finish_window_match_count` to production-order results. Finish-
  window reads count the detail rows that still match the selected item scope;
  direct bulk reads leave the count at zero. PLAN and README describe the count.
  Regressions now assert both the finish-window total and bulk-read default.

- Audited the production-order detail drift predicate against the consolidated
  contract. PLAN, README, ANOMALIES, and the validator guard now list every
  selected item attribute, quantity/status scope, and basic/scheduled date-time
  constraint that can set `finish_filter_lost`.

- Added `finish_match_progress_counts` to finish-window results. It summarizes
  receipt status only for items still marked as matching; the existing
  `receipt_progress_counts` continues to cover every returned item. The new
  counts sum to `finish_window_match_count`, while bulk reads leave the summary
  initial. Regressions, PLAN/README, and validator guards cover both scopes.

- Added per-order `matching_progress_counts` for the items that still match the
  finish-window selection. The page-level matching summary now aggregates those
  per-order counts. Regression coverage checks both matched status totals and the
  initial direct-bulk default; PLAN, README, and validator guards describe the
  per-order/page relationship.

- Receipt-progress count summaries now include a two-decimal percentage for
  each status. Each summary uses its own five status counts as the denominator,
  including invalid-quantity items; empty summaries keep the percentages
  initial. Regressions cover bulk, all-item finish-window, matched-item page and
  per-order shares, and a mixed valid/invalid bulk summary.

- Added `total_item_count` to each nonempty receipt-progress summary. It equals
  the five status counts combined, matches the finish-window match count on
  each order, and rolls up across the page. Tests cover bulk, invalid, all-item,
  matched-page, and per-order totals; empty and direct-bulk matching summaries
  remain initial.

- Finish-window searches can now bound raw received-to-order progress by an
  inclusive percentage range before pagination. Invalid raw quantities cannot
  match an enabled bound; continuation and detail-drift checks use the same
  unrounded ratio. Repository and service regressions cover range endpoints,
  over-receipt, zero receipt, pagination, invalid inputs, and scope drift.

- Every production-order result now includes per-order receipt-progress counts
  and percentages across all returned items. Finish-window results retain the
  separate matching-only summary, so an order's complete item set remains
  reconcilable with its selected subset. Regression cases cover direct bulk,
  invalid quantities, itemless orders, and nonmatching finish-window items.

- Shortened finish-window receipt result and test identifiers to fit ABAP's
  30-character name limit, and aligned the affected service result types after
  the first lint/transpiler run exposed overlong identifiers.
  Targeted abaplint over the order-read source, regression files, and direct
  dependencies now passes with 0 issues across 12 files. The latest full lint
  still reports 2,012 issues across 252 files, while full transpilation fails
  on errors in other files. PLAN validation remains blocked by the WSL 1 Node
  launcher, so ABAP Unit has not run.

- Production-order items now expose `is_receipt_progress_valid` so an initial
  status can be distinguished from malformed raw AFPO quantities without
  recomputing the validity rule. The flag depends only on positive order
  quantity and nonnegative received quantity; tests cover valid data despite
  failed UOM conversion, zero and negative order quantities, and negative
  receipts. PLAN, README, and validator guards document the contract. Current
  WSL 1 Node startup failures prevent the configured validation gates from
  running.

- Production-order read results now count successful base-unit conversions
  alongside conversion failures at both page and per-order level. The counts
  reconcile to all returned detail rows, including nonmatching rows retained by
  finish-window reads, and remain separate from receipt-progress validity.
  Bulk, conversion-failure, and finish-window regressions plus PLAN, README,
  and validator guards cover the contract. Runtime validation is still blocked
  because the WSL 1 Node launcher exits before starting Node.

- Finish-window production-order results now also summarize conversion success
  and failure over only the items that still match the selected scope. These
  counts reconcile to `finish_window_match_count`, separately from the all-item
  conversion totals. Regression coverage includes a selected row with a failed
  conversion and a retained nonmatching row with a successful conversion;
  direct bulk counts remain initial. PLAN, README, and validator guards cover
  the contract. Runtime validation remains blocked by the WSL 1 Node launcher.

- Confirmation posting-window results now provide order-level summaries in the
  original confirmation unit, alongside the operation summaries. The base-unit
  search also returns order-level totals grouped by production order and base
  unit, merging operations and source units. Both preserve date spans and
  reversed-inclusive/non-reversed counts and quantity totals; tests verify page
  lookahead exclusion and source-unit merging. PLAN, README, and validator
  guards describe the new summaries. Runtime gates remain unavailable under
  the WSL 1 Node launcher.

- Confirmation operation, order, and base-unit summaries now expose
  `partial_confirmation_count`, partitioning each returned page group with
  `final_confirmation_count`; reversal counts remain overlapping. They also
  report two-decimal final, partial, and reversed percentages over each group's
  `confirmation_count`. Added aggregation and raw/base regression assertions
  plus PLAN, README, and validator coverage. The ABAP Unit run exposed a related
  existing bug: a valid not-started receipt item reported zero open quantity.
  Its raw open quantity
  and percentage now report the full order quantity and 100%. The follow-up
  run could not start Node because the WSL 1 launcher exited before scripts ran.

- Confirmation posting-window reads now support inclusive lower and upper
  bounds on yield, rework, and scrap quantities. Each bound has an explicit
  flag, so zero is selectable; raw quantity ranges require one confirmation
  unit scope and are applied before paging. The service rejects disabled values,
  malformed flags, reversed ranges, missing unit scope, and repository rows
  outside any selected bound. Repository and service regressions cover the three
  metrics, both endpoints, one-sided ranges, zero, validation, and detail drift.
  A late matching repository row remains visible with a one-row limit, and the
  service returns matching-range cursors across truncated pages.
  PLAN validation passes, and the full transpiled ABAP Unit suite passes.
  Full abaplint reports 497 issues across 252 files; the confirmation repository,
  interface, and test files add no findings, while the read service has four
  existing alignment findings. CRLF-aware `git diff --check` passes.

- Confirmation-window searches now filter and return the AFVC resource object
  ID, with explicit exact-blank matching for unassigned operations. Direct
  confirmation and routing-operation reads populate the same field, including
  operations without confirmations. Routing-operation bulk reads also filter by
  resource ID and support exact-blank selection. Operation and base-operation
  summaries preserve the ID, including when source units merge. Regression coverage
  checks nonblank and blank selection, invalid flags, result-scope drift, and
  summary mapping. The Windows command bridge fails before launching Node in
  this shell (`UtilBindVsockAnyPort`), and the WSL Node launcher reports WSL 1;
  PLAN validation and ABAP Unit could not run here. CRLF-aware diff checks pass.

- `READ_OPERATIONS_BULK` now filters by resource, control key, operation number,
  routing sequence, and suboperation. Nonblank control keys filter by default;
  the control-key flag selects an exact blank value. Sequence and suboperation
  flags support exact initial-value matches, including base-operation-only
  selection. The repository applies all selectors before returning rows, and
  the service rejects invalid flags or rows outside the selected scope. PLAN,
  README, and anomaly notes document the filters. Runtime validation was not
  run in this turn.

- Routing-operation results now preserve the order category selected from
  `AUFK-AUTYP`, distinguishing production orders (`10`) from process orders
  (`40`). `iv_order_category` can restrict a mixed order list to one category;
  invalid values and returned category drift are rejected. PLAN, README, and
  anomaly notes describe the field and selector.

- `READ_OPERATIONS_BULK` now returns pages of up to 500 operations, with a
  keyset cursor over order, sequence, operation, suboperation, and AFVC counter.
  Results include page-level and per-order operation counts. Partial cursors
  and cursors outside the requested order list are rejected. PLAN, README, and
  anomaly notes document the paging contract. The repository now applies the
  selection and cursor in one ordered AUFK/AFKO/AFVC query and returns at most
  one lookahead row; the service validates the returned scope and builds the
  cursor. Unit and PLAN validation were not run in this turn.

- Routing-operation results now preserve the order category selected from
  `AUFK-AUTYP`, distinguishing production orders (`10`) from process orders
  (`40`) at the row level. PLAN, README, and anomaly notes describe the field.

- `READ_OPERATIONS_BULK` now filters exact AFVC-LTXA1 operation descriptions.
  Nonblank text filters by default, and an explicit flag selects blank text;
  invalid flags or returned description-scope drift are rejected. The filter
  applies before repository paging. PLAN, README, and anomaly notes document
  the selector.

- Confirmation-window searches now filter exact AFVC-LTXA1 operation
  descriptions. Nonblank text filters by default, and an explicit flag selects
  blank descriptions. The repository applies the filter in both cursor query
  branches, while the service validates the flag and returned scope. PLAN,
  README, and anomaly notes document the selector; runtime validation was not
  run.

- Confirmation-window searches now filter by exact AUFK-AUART order type
  before pagination, and confirmations expose `order_type` in both window and
  direct bulk reads. Operation-, order-, and base-unit summaries also carry the
  type. PLAN, README, and anomaly notes describe the new field and filter.
  Runtime validation was not run.

- Routing-operation bulk reads now expose AUFK-AUART `order_type` and accept
  `iv_order_type` to filter before paging. Repository pagination and legacy
  reads apply the selector, and service validation checks returned type scope.
  PLAN, README, and anomaly notes document the addition; runtime validation was
  not run.

- `READ_OPERATIONS_BULK` now filters an exact AFVC-APLZL operation counter with
  `iv_operation_counter`, before pagination. The service checks returned
  counter scope, and both paginated and legacy repository paths apply the
  selector. PLAN, README, and anomaly notes document the filter; runtime
  validation was not run.

- `READ_CONFIRMATIONS_BULK` now accepts `iv_order_type` to restrict results to
  one exact AUFK-AUART value. The repository filters orders before resolving
  operations, and service validation rejects returned type drift. PLAN, README,
  and anomaly notes document the selector; runtime validation was not run.

- `READ_CONFIRMATIONS_BULK` also accepts `iv_operation_counter` to select an
  exact AFVC-APLZL counter. The repository filters AFVC before mapping
  confirmations and the service validates returned counter scope. PLAN, README,
  and anomaly notes document the selector; runtime validation was not run.

- `READ_CONFIRMATIONS_BULK` now reports `confirmation_count` per requested
  order and a result-level `returned_count`; per-order counts sum to that
  total. PLAN, README, and anomaly notes describe the count contract. Runtime
  validation was not run.

- `READ_CONFIRMATIONS_BULK` now accepts `iv_exclude_reversed`, defaulting to
  `abap_false`. The repository removes reversed AFRU rows before operation
  resolution, and service validation checks the flag and returned reversal
  scope. PLAN, README, and anomaly notes document the option; runtime
  validation was not run.

- `READ_CONFIRMATIONS_BULK` now supports mutually exclusive `iv_final_only`
  and `iv_partial_only` filters. The repository filters AFRU final status
  before resolving AFVC operations, and service validation checks returned
  rows. PLAN, README, and anomaly notes document both filters; runtime
  validation was not run.

- `READ_CONFIRMATIONS_BULK` now filters exact AFVC-VORNR values through
  `iv_operation_number`, which can be combined with the operation-counter
  selector. The repository filters before mapping, and the service validates
  returned operation-number scope. PLAN, README, and anomaly notes document the
  selector; runtime validation was not run.

- `READ_CONFIRMATIONS_BULK` now accepts `iv_confirmation_number` and optional
  `iv_confirmation_counter` filters. A counter without a confirmation number
  is invalid; both filters run before AFVC mapping, and service validation
  checks returned confirmation scope. PLAN, README, and anomaly notes document
  the selection; runtime validation was not run.

- `READ_CONFIRMATIONS_BULK` now filters routing sequence and suboperation, with
  flags for exact initial-value matching. Suboperation selection requires an
  operation number. Repository filters, service checks, and the fake repository
  share those semantics. PLAN, README, and anomaly notes document the fields;
  runtime validation was not run.

- `READ_CONFIRMATIONS_BULK` now pages number-based confirmation reads in a
  stable production-order/posting-date/confirmation/counter order. It accepts a
  1-to-500 page size and a complete four-field continuation cursor; the
  repository returns one lookahead row, and the service returns next-cursor
  fields plus page counts. The fake repository mirrors filtering and paging.
  PLAN and README describe the contract; no tests or runtime validation were
  run.

- Number-based `READ_CONFIRMATIONS_BULK` reads now accept optional inclusive
  posting-date bounds. Each bound is validated independently; two active bounds
  must be valid and ascending. The repository filters AFRU before resolving
  operations, and service result validation checks the selected date scope.
  Pagination continues within the same bounds. No tests or runtime validation
  were run.

- Number-based `READ_CONFIRMATIONS_BULK` now filters by AUFK order category
  (`10` production or `40` process) before confirmation operation resolution.
  Invalid values fail before repository access, and service validation checks
  returned category scope. The fake repository and both read guides mirror the
  selector; no tests or runtime validation were run.

- `READ_CONFIRMATIONS_BULK` now supports `iv_reversed_only` alongside
  `iv_exclude_reversed`. The flags accept only boolean values and cannot both
  be true; repository filtering and service result validation enforce the
  selected reversal scope. The fake and both read guides are aligned. No tests
  or runtime validation were run.

- Number-based `READ_CONFIRMATIONS_BULK` now supports inclusive AFRU-ERSDA
  entry-date bounds, independently of posting date. Active bounds are validated
  and omit confirmations without an entry date; repository and service result
  checks preserve the selected scope across cursor pages. The fake and read
  guides mirror the behavior. No tests or runtime validation were run.

- `READ_CONFIRMATIONS_BULK` now filters by AFVC control key, operation
  description, and resource object ID. Nonblank values filter by default, and
  boolean flags enable exact blank matching. Repository page queries, the fake,
  and service result validation use the same scopes; PLAN and README describe
  them. No tests or runtime validation were run.

- Number-based confirmation reads now filter control key, operation text, and
  resource object ID. The operation-text blank-match flag is named
  `iv_filter_op_description` in both confirmation and operation reads to stay
  within the ABAP method-parameter limit.
  The transpiler passed after correcting its reported identifier and helper-call
  errors. `npm run lint` reported 653 issues across 252 files on its initial
  run; a rerun was blocked by the WSL Node launcher, so current lint status is
  unknown.

- Number-based `READ_CONFIRMATIONS_BULK` now accepts exact AFRU entered-by and changed-by filters, including exact blank matching, plus optional inclusive AFRU-LAEDA bounds. Active date bounds exclude rows without last-change dates. Repository SQL applies all filters before operation lookup and pagination; service validation checks flags, dates, users, and returned scope. The fake repository and service regression coverage mirror the behavior. PLAN and README were updated.

- Verification for the confirmation audit filters: `npm run transpile` passed. The launched abaplint run reported 700 issues across 252 files, mostly alignment findings; the repository's existing broad lint backlog remains. `validate:plan` could not launch because the WSL Node shim reports WSL 1 unsupported, and ABAP Unit could not launch because `node` is unavailable in the Linux PATH. Source-level checks and the CRLF-aware diff check passed.

- Number-based `READ_CONFIRMATIONS_BULK` now filters by AFRU confirmation unit. Nonblank units filter by default and `iv_filter_quantity_unit` enables exact blank-unit matching. The repository applies this filter before operation lookup and pagination; service scope validation and the fake repository mirror it. A service regression covers nonblank, blank, and invalid-flag cases; a repository regression queries BOX with a one-row page and checks that the SQL-filtered result is returned. PLAN and README were updated.

- Confirmation-unit filter verification: `npm run transpile` passed. abaplint reported 682 issues across 252 files, down from 700 after aligning the newly added signatures; remaining findings are mostly existing alignment issues. `validate:plan` could not launch under the WSL 1 Node shim, and ABAP Unit could not launch because Linux `node` is unavailable. Source-contract checks and CRLF-aware diff validation were reviewed.

- `READ_CONFIRMATIONS_BULK` now accepts an inclusive `AFRU-ERZET` entry-time window. Enabling the filter requires both valid, ascending bounds, with midnight accepted; disabled filters require initial bounds. SQL and the fake filter before pagination, and the service validates returned times. Service and repository regressions cover inclusive midnight/end bounds and pre-read rejection. PLAN and README were updated.

- Entry-time window verification: `npm run transpile` passed after the implementation and repository fixture updates. abaplint reported 682 issues across 252 files; the new time signatures and regressions add no findings. `validate:plan` still cannot launch under the WSL 1 Node shim, and the ABAP Unit runner cannot start because Linux `node` is unavailable. CRLF-aware diff and static source checks passed.

- `READ_CONFIRMATIONS_BULK` now filters positive yield, rework, and scrap, and accepts independent inclusive quantity bounds for each measure. Quantity ranges require a single unit scope through `iv_quantity_unit` or exact blank-unit selection; positive-only selectors remain unit-independent. Service validation, repository SQL, the fake, and regression coverage use the same rules. PLAN and README were updated.

- Verification for the confirmation quality filters: `npm run transpile` passed; the latest abaplint run reported 606 issues across 252 files, down from 682 before this step's alignment cleanup. PLAN validation failed to launch under the WSL 1 Node shim. ABAP Unit remains unavailable because Linux `node` is not installed. Source contracts, method parameter lengths, ABAP line lengths, newline styles, and the CRLF-aware diff check passed.

- `READ_OPERATIONS_BULK` now supports inclusive `AFVC-VORNR` lower and upper bounds. Either endpoint may be omitted, paired bounds must ascend, and the exact operation selector intersects the range. Repository filtering occurs before pagination; service validation and fake behavior match SQL. Service and repository regressions cover boundaries, intersection, reversed bounds, and both repository query paths. PLAN, README, and anomaly notes were updated.

- `READ_OPERATIONS_BULK` also supports inclusive `AFVC-APLZL` bounds through `iv_operation_counter_from` and `iv_operation_counter_to`. Bounds can be supplied separately, paired bounds must ascend, and `iv_operation_counter` intersects the range. Repository paging and fallback queries, service checks, the fake repository, and regressions cover the shared selection rules.

- Operation-number and operation-counter range verification: `npm run transpile` passed after both AFVC-VORNR and AFVC-APLZL ranges, and `npm run lint` reported 547 issues across 252 files (606 before the selector-range work and alignment cleanup). `npm run validate:plan` could not launch because the WSL 1 Node shim cannot locate Node; ABAP Unit remains unavailable because Linux `node` is not installed. Source length/identifier/newline checks and the CRLF-aware diff check pass.

- `READ_OPERATIONS_BULK` now accepts inclusive routing-sequence bounds through `iv_operation_sequence_from` and `iv_operation_sequence_to`. Either bound may be supplied alone, paired bounds must ascend, and the exact sequence selector intersects with the range. Repository page and fallback SQL, service validation, the fake repository, and regression cases use the same bounds.

- Sequence-range verification: `npm run transpile` passed; `npm run lint` reported 547 issues across 252 files, unchanged from the preceding operation-range pass. `npm run validate:plan` could not start because the WSL 1 Node shim could not locate Node. Source-contract checks, CRLF/LF checks, ABAP line/identifier limits, and `git diff --check` passed. ABAP Unit was not run because Linux `node` is unavailable.


`READ_OPERATIONS_BULK` now supports inclusive AFVC-UVORN bounds through
`iv_suboperation_number_from` and `iv_suboperation_number_to`. Initial values omit
a bound, paired active bounds must ascend, and an active suboperation range
requires an exact operation number. The exact suboperation selector intersects
with the range. Repository queries apply both bounds before paging, while the
service validates returned suboperation scope. Regressions cover inclusive and
one-sided bounds, exact intersection, invalid ranges and missing operation
scope, result drift, and paged/unpaged SQL reads.


`READ_CONFIRMATIONS_BULK` now accepts inclusive AFVC-UVORN bounds through
`iv_suboperation_number_from` and `iv_suboperation_number_to`. Active ranges
require an exact operation number, paired bounds must ascend, and the exact
suboperation selector intersects with the range. The repository filters before
pagination and operation resolution; service result validation and the fake
repository enforce the same bounds. Regression cases cover one-sided and paired
bounds, exact intersection, invalid requests, result drift, and paged/unpaged
SQL reads.


`READ_CONFIRMATIONS_BULK` now accepts optional inclusive AFVC-VORNR bounds via
`iv_operation_number_from` and `iv_operation_number_to`. Each endpoint is
independent, paired bounds must ascend, and the exact operation-number selector
intersects with the range. Both repository paths filter before pagination and
operation resolution; the service and fake validate returned scope. Regression
coverage includes paired and one-sided bounds, exact intersection, inverted
ranges, result drift, and paged/unpaged SQL reads.

- `READ_CONFIRMATIONS_BULK` now accepts inclusive AFVC-PLNFL bounds through
  `iv_operation_sequence_from` and `iv_operation_sequence_to`. Either bound
  may be omitted, paired active bounds must ascend, and an exact sequence
  selector intersects with the range. Repository page and fallback paths,
  service result validation, the fake, and regression cases cover the range.
  PLAN, README, and source-contract validation were updated.

- `READ_CONFIRMATIONS_BULK` now accepts inclusive AFVC-APLZL bounds through
  `iv_operation_counter_from` and `iv_operation_counter_to`. Either bound can
  be omitted, paired active bounds must ascend, and `iv_operation_counter`
  intersects with the range. Repository page/fallback SQL, service result
  validation, the fake, and regression coverage apply the same scope. PLAN,
  README, and source-contract checks were updated.


- `SEARCH_CONFIRMATIONS_BY_WINDOW` now accepts inclusive AFVC-VORNR bounds.
  Either endpoint may be omitted, paired bounds must ascend, and the exact
  operation selector intersects with the range. SQL filters before
  pagination, and the service checks returned rows. Regressions cover paired
  and one-sided bounds, intersection, inverted bounds, result drift, and a
  later matching operation on a one-row page.

- Confirmation-window reads now accept inclusive AFVC-PLNFL bounds. Either
  endpoint may be omitted, paired bounds must ascend, and the exact sequence
  selector intersects with the range. SQL filters before pagination, and the
  service rejects out-of-range rows. Regressions cover one-sided and paired
  bounds, intersection, inverted bounds, result drift, and filtered pages.

- Confirmation-window reads now accept inclusive AFVC-UVORN bounds scoped to
  an operation number. Either endpoint may be omitted, paired bounds must
  ascend, and the exact suboperation selector intersects with the range. SQL
  filters before pagination; service validation rejects missing operation
  scope, inverted ranges, and result drift. Regressions cover both endpoints,
  intersection, filtered pages, and pre-read validation.

- Confirmation-window reads now accept inclusive AFVC-APLZL bounds scoped to
  one production or process order. Either endpoint may be omitted, paired
  bounds must ascend, and the exact counter selector intersects with the
  range. SQL filters before pagination; service validation checks order and
  counter scope. Regressions cover both endpoints, intersection, paging, and
  pre-read rejection.

- Confirmation-window reads now accept inclusive AFRU-RMZHL bounds scoped to
  one confirmation. Either endpoint may be omitted, paired bounds must
  ascend, and active bounds require the confirmation number. The exact
  counter selector intersects with the range. SQL filters before pagination;
  service validation rejects missing scope, inverted bounds, and result drift.
  Regression coverage includes both endpoints, intersection, paged matches,
  and pre-read validation.


- Confirmation-window searches now accept an exact nonblank `work_center` selector for CRHD-ARBPL. The repository joins CRHD through AFVC-ARBID / CRHD-OBJID and filters before paging. Confirmation rows and operation summaries return the work-center code, with service scope validation and fake-repository coverage.

- Added `filter_work_center` so confirmation-window callers can select operations with no resolved work-center code. The repository applies the blank-code match before paging, the service validates its boolean flag and returned rows, and repository/service regressions cover it. Added a minimal CRHD SAP-table stub because Open ABAP core does not include that table.

- Confirmation-window results now expose and filter `CRHD-WERKS` as `work_center_plant`. Its optional blank-match flag composes with the work-center code selector and is applied before paging. Confirmation, source-unit summary, base-unit summary, and fake-repository tests cover the field.

- Confirmation-window searches now support explicit blank AUFK-AUART matching
  through `filter_order_type`. The repository applies the selector before
  pagination, and service validation checks the returned order type. PLAN and
  README document the default nonblank and explicit blank behavior.

- Added deleted-order filtering to confirmation-window reads.
  `exclude_deleted` removes rows without an active matching AFPO item
  or with a marked AUFK deletion flag; confirmation rows expose the
  order header deletion indicator. Service and repository tests cover
  filtering, flag validation, and result-scope drift.

- Typed the CRHD object-type join key in confirmation-window SQL. The
  SQLite-backed unit environment does not ignore trailing blanks on
  fixed-width CHAR values, so the typed host value keeps work-center
  joins consistent with the CRHD DDIC field length.

- The full unit run exposed stale READ_OPERATIONS_BULK range counts. An
  initial suboperation selector omits that filter, so operation-number
  ranges include matching suboperations; tests now assert those rows.

- Confirmation-window searches now return AFRU ISDD/ISDZ/IEDD/IEDZ actual execution timestamps. Inclusive ISDD and IEDD date bounds support either endpoint alone, validate Gregorian dates and order, and omit undated confirmations. Paired ISDZ and IEDZ time filters use explicit boolean flags, require valid ascending bounds, accept midnight `000000`, and require the associated execution date. SQL filters before paging; service validation, the fake repository, repository/service regressions, the AFru stub, and the SQLite schema cover the same behavior.

- Verification completed with Linux Node at `/home/lars/.nvm/versions/node/v22.22.2/bin/node`: `npm run unit` and `npm run validate:plan` pass, and `git diff --check` passes. `npm run lint` reports 627 issues across 252 files, primarily alignment findings.

- `READ_CONFIRMATIONS_BULK` now returns actual AFRU execution start/finish timestamps and accepts independently optional execution-date bounds plus paired start/finish time ranges. Both repository query branches filter before pagination, the service validates returned timestamps and scope, and the fake repository mirrors the filters. Regression coverage includes midnight `000000`, paged and unpaged SQL reads, and invalid ranges. Linux Node `npm run unit` and `npm run validate:plan` pass.

- `READ_OPERATIONS_BULK` now returns page-scoped work-center summaries by CRHD plant and code, including blank assignments; counts exclude lookahead rows and reconcile to the page operation count. Number-based confirmation reads and posting-window searches expose the corresponding confirmation summaries. Tests cover repeated work centers, blank groups, and page lookahead exclusion.

- Work-center summary verification: `npm run unit` and `npm run validate:plan` pass. `npm run lint` reports 627 issues across 252 files, matching the existing baseline, and the CRLF-aware diff check passes.

- Confirmation work-center rollups now include yield, rework, and scrap totals split by `AFRU-MEINH`; gross totals preserve reversed rows, and non-reversed totals omit them. The base-unit confirmation-window result adds equivalent totals by work center and material base unit. Counts remain scoped to returned page rows.

- Confirmation work-center summaries also include the first and last dated postings, final/partial/reversed counts, and percentages. Final and partial counts partition each center's confirmations; reversed count is independent.

- Work-center confirmation quantity-unit rows now include their own first and
  last dated postings, final/partial/reversed counts, and percentages. These
  metrics are grouped by `AFRU-MEINH`; final and partial counts partition the
  unit count, while the reversed count is independent.

- Work-center rollups now report the count of actual execution start and finish
  dates and the earliest start/latest finish date-time pairs. Raw, quantity-unit,
  and base-unit summaries share the same page scope; dated `000000` values count
  as midnight. Regression data includes cross-midnight spans and midnight rows.

- The same execution rollups now report start and finish coverage percentages
  against each group’s confirmation count. Missing actual dates count as zero
  coverage; an empty group keeps both percentages at zero.

- Work-center summaries now sum elapsed seconds for valid actual execution
  intervals and report valid and invalid interval counts. Missing start or finish
  dates are omitted; invalid date/time values and finishes before starts are
  counted without adding seconds. Totals include reversed rows and do not imply
  utilization when confirmation intervals overlap.

- Confirmation summaries now report `exec_longest_3plus_secs` and `exec_3plus_avg_secs` across work-center, quantity-unit, raw operation, raw order, and base-unit scopes. The mean retains fractional seconds; touching intervals that keep concurrency at three stay in one episode. The dedicated regression checks two separated episodes, a touching threshold transition, and a 2.5-second mean. `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.

- Confirmation summaries now include `exec_3plus_pct`, the share of the positive-interval span spent at concurrency three or higher. It rounds to two decimals and remains zero for groups without a positive span. Regressions cover triple and two-way intervals, touching boundaries, base-unit and raw scopes, and empty data. `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.

- Confirmation summaries now report `exec_exactly_two_secs` and `exec_exactly_two_pct`. The duration splits overlap wall time with 3+ concurrency time; their percentages split overlap wall percentage within 0.01 percentage point after rounding. Regressions cover mixed unit overlaps, base summaries, touching intervals, separate episodes, and zero-duration data. A first test run caught a two-second exactly-two tail in the dedicated fixture; the expected value was corrected. `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.

- Confirmation summaries now expose `exec_pairwise_overlap_secs`, the sum of overlap time across all confirmation pairs. A segment with three active intervals contributes three times its duration, distinct from once-counted overlap wall seconds and excess-duration seconds. Tests cover triple and pair overlaps, raw and base scopes, touching intervals, and separated episodes. `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.

- Confirmation summaries now expose `exec_peak_concurrency_pct`, the share of the positive-interval span spent at the group's observed maximum concurrency. It uses the same peak-duration resets as `exec_peak_concurrency_secs` and is zero without a positive span. Tests cover group scopes, the peak increasing later, a continuous chain, separate peak episodes, and zero-duration-only data. The full `npm test` suite passes.

- Confirmation summaries now report `exec_avg_concurrency`, summed valid duration divided by the positive-interval span. The value includes internal idle gaps and can exceed one when intervals overlap; groups without a positive span return zero. Tests cover mixed units, raw and base scopes, touching intervals, separated overlaps, and zero-duration-only data. `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.

- Confirmation summaries now include `exec_overlap_pair_count`, counting distinct pairs of valid positive-duration intervals with a positive-length intersection. Endpoint-only contact, zero-length, invalid, and missing intervals do not add pairs. Regressions cover triple overlap, separated pair overlaps, raw and base scopes, touching intervals, and empty data. `npm test` passes with zero lint issues, successful transpilation, and full ABAP Unit success.

- Confirmation summaries now report `exec_overlap_pair_avg_secs`, the mean overlap duration across distinct intersecting confirmation pairs. It divides pairwise overlap seconds by the positive-overlap pair count, retains fractional seconds, and stays zero without a pair. Tests cover triple overlaps, pair-only overlaps, fractional averages, raw and base scopes, and empty data. The full `npm test` suite passes.

- Confirmation summaries now report `exec_longest_pair_overlap_secs`, the longest intersection of one pair of valid positive-duration intervals. This is distinct from the longest group-wide overlap episode. Tests cover raw/base scopes, a longer and a shorter pair, a three-way fixture, touching intervals, and empty execution data. `npm test` passes.

- Peak-concurrency summaries now expose `exec_peak_episode_count`, `exec_longest_peak_secs`, and `exec_peak_episode_avg_secs`. They use only episodes at the final observed peak; discovering a higher peak resets earlier lower-level episodes, while touching handoffs at the peak remain continuous. Tests include a later peak increase, two separated peak episodes, touching intervals, and no positive durations. The full `npm test` suite passes with zero lint issues.
- Confirmation summaries now expose non-reversed execution metrics beside
  the gross totals: `exec_nonrev_duration_count`,
  `exec_nonrev_total_secs`, `exec_nonrev_duration_avg_secs`,
  `exec_nonrev_covered_secs`, and `exec_nonrev_excess_secs`. Matching
  reversed-only values are `exec_reversed_duration_count`,
  `exec_reversed_total_secs`, `exec_rev_duration_avg_secs`,
  `exec_reversed_covered_secs`, and `exec_reversed_excess_secs`. Both
  sides also report `exec_nonrev_duration_pct` and
  `exec_reversed_duration_pct`, their shares of summed valid duration.
  counts include valid zero-duration rows; averages divide each sum by its
  count, unions exclude zero durations, and overlap excess is summed duration
  minus that union. Tests compare work-center, unit, raw, and base scopes with one
  reversed overlapping interval. `npm test` passes with
  zero lint issues, successful transpilation, and full ABAP Unit success.

- Confirmation summaries now report `exec_duration_seconds_median` as the
  median of valid elapsed durations. Zero-duration and reversed intervals
  participate; even-sized groups average their two middle values, and empty
  groups return zero. Tests cover work-center, unit, operation, order, and base
  scopes, plus a zero-only group.

- Confirmation summaries now expose `exec_duration_seconds_p90`, the
  nearest-rank 90th percentile of valid elapsed durations. Zero-duration and
  reversed confirmations participate; empty groups return zero. Regression
  assertions cover work-center, unit, operation, order, and base scopes.

- Confirmation summaries now expose `exec_duration_seconds_p95`, the
  nearest-rank 95th percentile of valid elapsed durations. Zero-duration and
  reversed confirmations participate; empty groups return zero. A 20-sample
  regression distinguishes p90 at 1,080 seconds from p95 at 1,140 seconds.

- Confirmation summaries now report `exec_duration_seconds_mad`, the
  median absolute deviation of valid elapsed durations. Zero-duration and
  reversed confirmations participate, and empty groups return zero. Tests
  cover a 20-value sequence with a 300-second MAD, a work-center overlap
  group, and zero-only data.

- Reversal-aware confirmation summaries now report separate non-reversed and
  reversed duration medians. Valid zero-duration rows participate, and an
  empty subgroup returns zero. Tests compare work-center, unit, operation,
  order, and base scopes, including a zero-only subgroup.

- Reversal-aware confirmation summaries now report separate non-reversed and
  reversed p90 durations using nearest-rank calculation. Valid zero-duration
  rows participate, and empty groups return zero. Tests cover unit, raw, base,
  20-row tail, and zero-only cases.

- Reversal-aware confirmation summaries now report a separate median absolute
  deviation for non-reversed and reversed valid durations. Zero-duration rows
  participate, and empty subgroups return zero. Tests cover work-center, unit,
  raw operation/order, base, 20-row, and zero-only cases.

- Reversal-aware confirmation summaries now report nearest-rank p95 durations for non-reversed and reversed confirmations. Valid zero-duration rows participate, and empty subgroups return zero. The shared p95 calculation is mapped to all seven summary scopes.

- Reversal-aware confirmation summaries now report separate minimum and maximum valid elapsed durations for non-reversed and reversed confirmations. Valid zero-duration rows participate, and empty subgroups return zero. The bounds flow through all seven summary scopes; regression coverage includes mixed units, base-unit summaries, and a zero-only group.

- Production confirmation duration summaries now include nearest-rank p99 for gross, non-reversed, and reversed duration groups. All use one shared percentile rank calculation; valid zero-duration rows participate, empty groups return zero, and tests cover a 20-row tail plus mixed-unit and base scopes.

- Confirmation summaries now expose gross, non-reversed, and reversed execution-duration IQR. Each is nearest-rank p75 minus p25, includes valid zero-duration rows, and returns zero for an empty group. Regression coverage spans work-center, unit, raw, base-unit, and zero-only groups.

- Confirmation summaries now expose nearest-rank p25 and p75 elapsed durations for gross, non-reversed, and reversed groups, alongside the IQR. Valid zero-duration rows participate; empty groups return zero. Regressions cover tail ranks, mixed units, base scopes, and zero-only groups.

- Confirmation summaries now report counts and percentages of valid execution durations strictly above each gross, non-reversed, or reversed nearest-rank p95. Percentages use valid duration rows as their denominator, ties at p95 are excluded, and empty groups report zero. Regressions cover a 5% gross upper-tail case, split groups, mixed units, base scopes, and zero-only data.

- Confirmation summaries now report the dimensionless ratio of p95 duration to median duration for gross and reversal groups. Ratios return zero when the median is zero; regressions cover a skewed 20-row sample, each reversal subset, and zero-only data.

- Production confirmation summaries now report elapsed seconds above each p95 threshold and that tail sum as a share of all valid duration seconds, for gross and reversal groups. Ties at p95 are excluded, and shares are zero when the group has no positive duration total. Regressions include a 1,200-second tail contributing 9.52% of the group total.

- Production confirmation summaries now report valid p99 exceedance counts and percentages, plus elapsed seconds above each gross, non-reversed, and reversed p99 threshold and their shares of total duration. Strict comparisons exclude ties; a 101-row split-group regression covers positive tails and zero-only summaries cover empty tails.

- Production confirmation summaries now expose p99-to-median duration ratios for gross, non-reversed, and reversed groups. Ratios retain seconds-free units and return zero for empty or zero-median groups. Regressions cover skewed, split, and zero-only samples.

- Production confirmation summaries now expose p90-to-median duration ratios for gross, non-reversed, and reversed groups. Ratios are dimensionless and return zero for empty or zero-median groups; skewed and zero-only samples cover the behavior.

- Production confirmation summaries now include strict p90 exceedance counts, percentages, elapsed tail seconds, and tail shares for gross, non-reversed, and reversed groups. Counts use valid rows; elapsed shares use each group's total valid duration. A skewed 20-row sample and zero-only data cover the behavior.

- Production confirmation summaries now report dimensionless IQR-to-median ratios for gross, non-reversed, and reversed durations. Ratios are zero for empty or zero-median groups; skewed and zero-only regressions cover the result.

- Production confirmation summaries now expose dimensionless MAD-to-median ratios for gross, non-reversed, and reversed duration groups. Zero medians return zero; skewed and zero-duration regressions cover both normal and empty-spread cases.

- Production confirmation summaries now expose average-to-median duration ratios for gross, non-reversed, and reversed groups. Ratios are dimensionless and zero when the median is zero.

- Production confirmation summaries now report positive-only valid duration counts, medians, and p90s for gross, non-reversed, and reversed groups. Zero-duration rows are excluded; empty groups return zero.

- Positive-only execution summaries now report p90-to-median ratios for gross, non-reversed, and reversed groups. Ratios are dimensionless and zero when the group has no positive median.

- Production confirmation summaries now report positive-only p90 greater-than counts and percentages plus elapsed tail seconds and shares for gross, non-reversed, and reversed groups. Counts use positive rows; tail shares use each group’s valid elapsed total.

- Production confirmation summaries now report positive-only p95 and p99 durations for gross, non-reversed, and reversed groups. Nearest-rank percentiles exclude zero-duration rows; empty groups return zero.
- Production confirmation summaries now report positive-only p25/p75, IQR, and median absolute deviation for gross, non-reversed, and reversed durations, plus IQR-to-median and MAD-to-median ratios. Zero-duration rows are excluded; empty groups and zero medians return zero.
- Production confirmation summaries now report positive-only average durations and average-to-median ratios for gross, non-reversed, and reversed groups; empty groups return zero.
- Production confirmation summaries now report positive-only minimum, maximum, and duration range for gross, non-reversed, and reversed groups; zero-duration rows are excluded and empty groups return zero.
- Production confirmation summaries now report positive-only p95 and p99 exceed counts, percentages, tail seconds, and tail shares for gross, non-reversed, and reversed groups. Rows tied at the nearest-rank threshold are excluded.
- Production confirmation summaries now expose positive-only p95/median and p99/median ratios for gross, non-reversed, and reversed cohorts; empty positive-duration groups return zero.
- Production confirmation summaries now report positive-duration counts as percentages of all confirmations, with matching non-reversed and reversed cohort percentages; missing, invalid, and zero-duration rows stay in the denominator.
- Production confirmation summaries now report positive-duration shares within valid intervals for gross, non-reversed, and reversed cohorts; invalid and missing rows are excluded from these denominators.
- Production confirmation summaries now report zero-duration shares within valid intervals for gross, non-reversed, and reversed cohorts, complementing positive-valid shares.

- Production confirmation summaries now expose exact zero-duration counts for gross, non-reversed, and reversed valid-interval cohorts. The counts are valid rows minus positive rows and match the zero-valid percentages. Tests cover skewed, all-positive, and zero-only groups.

- Production confirmation summaries now expose invalid and missing execution-duration counts separately for non-reversed and reversed cohorts. These counts combine with each cohort’s valid count to partition its confirmations; a fixture exercises both statuses in both cohorts.

- Production confirmation summaries now report valid, invalid, and missing duration percentages within each reversal cohort. Each uses that cohort’s full confirmation count; the three percentages partition the cohort, with an empty cohort returning zero. Empty cohorts return zero; each rate uses its cohort confirmation count as denominator.

- Production confirmation details now identify why an execution interval is missing or invalid: separate start/finish date and time codes, both-dates-missing, and negative elapsed time. Valid and zero-duration intervals return a blank issue code; `000000` remains a valid midnight time.

- Production confirmation summaries now include a fixed, issue-code-sorted count table for all eight missing/invalid interval reasons. Empty reasons remain present at zero, and the counts reconcile to invalid plus missing durations.
- Each execution-duration issue row now reports its percentage of the summary's confirmations; empty summaries return zero, and issue percentages reconcile to invalid plus missing duration percentages.
- The execution-duration issue matrix now splits counts and rates into non-reversed and reversed confirmations, using each cohort's confirmation count as its percentage denominator.
- Each issue row now reports `issue_share_pct`, the reason's share of all invalid and missing confirmations in that summary.
- Issue shares now also split non-reversed and reversed exceptions; each rate uses invalid-plus-missing confirmations from its matching cohort.
- The issue table now reports `status_share_pct`, showing a reason's share within invalid reasons or missing reasons separately.
- Status-specific reason shares now also split non-reversed and reversed confirmations using their matching invalid or missing counts.
- Confirmation summaries now identify the most common duration issue code and status, with count and full-summary percentage; lexical code order breaks ties.
- Confirmation summaries now identify the most common invalid and missing issue reasons separately, with counts and shares within each status.
- Confirmation summaries now report the most common issue by reversal cohort, including its status and share of the cohort's full confirmations.
- Batch expiry exposure can filter to positive reservation-net available quantity before dated and undated summaries and detail paging; the selector is validated and echoed by base and UOM results.
- Batch expiry exposure now accepts inclusive reservation-net available quantity bounds in the material base unit; either bound is optional, and the filters compose before summaries and paging.
- Batch expiry exposure can now filter by inclusive percentage bounds on available stock as a share of unrestricted stock, using the same rounded ratio reported on each detail row.
- Batch expiry exposure can now retain rows with positive unrestricted, available, quality-inspection, or blocked balances while preserving every category amount in the returned rows.
- Batch expiry exposure can now restrict a selected positive stock category to inclusive base-unit quantity bounds; base and UOM requests validate and echo the bounds.
- Batch expiry exposure can now filter on signed reservation-deduction quantity bounds before the expiry summaries and page rows.
- Production-order finish-window reads can now filter by inclusive bounds on remaining order quantity percentage, including validation and detail-read drift checks.
- Planned-order finish-window reads can now filter on converted material base-unit quantity before pagination, alongside existing order-unit bounds.
- Production-order finish-window reads can now bound converted AFPO order quantity in the material base unit before pagination and recheck conversion scope on details.
- Production-order finish-window reads can now bound converted AFPO received quantity in the material base unit before pagination and recheck conversion scope on details.
- Production-order finish-window reads can now bound positive remaining quantity in the material base unit before pagination and recheck conversion scope on details.
- Production-order finish-window reads can now select orders by any of several active system or user status codes and report when none remain active on the later status read.
- Production-order finish-window reads can now select over-receipt by converted material base-unit quantity, including valid zero-excess items and detail-read drift checks.
- Production-order finish-window results now include page and per-order matching summaries for converted order, received, open, and over-receipt quantities in the selected material's base unit, quantity totals and quantity shares by contributing receipt state, weighted quantity/coverage percentages, contributing-item receipt-state counts and rates, over-receipt as a share of received quantity, disjoint exclusion counts and percentages, and each exclusion reason's share of excluded items.
- `READ_OPERATIONS_BULK` work-center summaries now report each group's percentage of returned page operations, weighted from page counts and excluding lookahead rows.
- `READ_OPERATIONS_BULK` now summarizes returned page operations by AUFK-AUTYP, retaining blank categories and reporting each category's page count and share.
- `READ_OPERATIONS_BULK` now summarizes returned page operations by AUFK-AUART, retaining blank order types and reporting each type's page count and share.
- `READ_OPERATIONS_BULK` work-center summaries now include distinct contributing order counts, counting an order once per center even when it has multiple operations there.
- `READ_OPERATIONS_BULK` now groups returned page operations by AFVC-STEU control key, retaining blank keys and reporting each key's operation count and share.
- Operation category, order-type, and control-key summaries now include distinct contributing order counts, so repeated operations from one order do not inflate order totals.
- Operation summary groups now report `order_pct`, their distinct order count as a share of page `found_count`; work-center and control-key shares can overlap.
- Cost-center date-first previews and reservation results now expose one-based allocation sequences on summaries and emitted storage or batch splits, preserving caller-order rows and scheduled ranks for skipped bulk requests.
- Scoped production component previews now expose the allocator's one-based sequence on per-component local estimates and emitted batch or location splits; a priority fixture verifies processing order survives caller-order output. Source contract checks and scoped `git diff --check` pass. `npm test` cannot start because the environment's WSL 1 Node launcher fails before running the suite.
- Production component sequence tracing now covers the unscoped date allocator too. `allocation_sequence_scope` distinguishes `D` date-group allocation from `S` scoped allocation; dated component rows follow material, plant, required date, and input order, while grouped estimates retain date-group ranks. Priority, same-date tie, ATP, and split propagation assertions plus source-contract checks are in place. `git diff --check` passes; `npm test` remains unavailable because the WSL 1 Node launcher fails before starting Node.

- Scoped production component batch and location splits now include the `S` allocation sequence scope beside their rank, making split trace rows self-describing. Regressions and PLAN/README/validator contracts cover both split types. `npm test` could not start under WSL 1 because the Windows Node launcher reports that WSL 1 is unsupported; source contracts and CRLF-aware `git diff --check` passed.

- Production component local estimates and direct scoped allocation results now report `minimum_coverage_rejected` when eligible stock fails a per-component coverage floor. The regression proves that the rejected demand takes no stock and the later component allocates it. PLAN, README, and source-contract checks cover the status; runtime validation remains unavailable under the recorded WSL 1 Node launcher failure.

- Shared date-first scalar, base, UOM, and ATP allocation results now expose `minimum_coverage_rejected`; all adapters preserve the dated result field. Regression coverage checks rejection, stock preservation for a later demand, and the scalar, UOM, and ATP paths. Focused source contracts and diff checks passed; `npm test` failed before Node started because the Windows launcher rejects WSL 1.

- Undated shared material/plant scalar, base, UOM, priority, and UOM ATP results now expose `minimum_coverage_rejected`. The same final-allocation status is populated by storage-location, date-first location, batch, FEFO, and quality FEFO summaries. Regressions cover wrapper propagation, full-quantity rejection, and stock preservation for the next demand. Focused source contracts and CRLF-aware `git diff --check` passed; full runtime validation remains unavailable under the WSL 1 Node launcher issue recorded in `ANOMALIES.md`.

- Cross-plant ordinary, date-first, date/location, exact-batch, and FEFO summaries now expose `minimum_coverage_rejected`; unit, priority, date, and ATP wrappers preserve it. Regressions cover every summary shape and prove ordinary cross-plant rejection leaves stock for a later request. The date/location adapter now copies the flag when rebuilding its summary; focused source-contract checks and CRLF-aware `git diff --check` pass. ABAP lint, transpilation, and ABAP Unit remain unavailable under the WSL 1 Node launcher issue recorded in `ANOMALIES.md`.

- Valuation-type allocation summaries now report `minimum_coverage_rejected` from final base-unit quantities. UOM and ATP local estimates preserve the field, including full-quantity rejection when provisional coverage meets the floor but cannot satisfy the full request. Regressions cover floor rejection, zero floors, and both wrappers; PLAN, README, and validator contracts were updated.

- Single cost-center preview and reservation results now expose `minimum_coverage_rejected` from the final base-unit allocation. The prepared result copies the underlying status; regressions cover ordinary rejection, full-quantity rejection below the floor, and a zero floor.

- Sales-order aggregate and FEFO issue summaries now expose `minimum_coverage_rejected` from final base-unit quantities. Base, UOM, and FEFO regressions cover rejected stock preservation, full-quantity rejection, zero floors, and both FEFO display units; PLAN, README, and validator contracts are updated.

- Sales-order unit-aware allocation summaries now preserve the shared
  allocator's `minimum_coverage_rejected` flag in single-order and
  date-prioritized results. Regressions cover both summary builders, verify the
  rejected line leaves stock available for the next line, and check the floor
  pass status for an unconfigured line.

- Sales-order allocation results and their unit-aware summaries now expose
  one-based `allocation_sequence` values. Single-order results rank processing
  order after any date sort; date-first multi-order results preserve the shared
  allocator's global date rank while retaining result row order. Regressions
  verify ranks on both arrays and 2/1 for caller-ordered rows with reversed dates.

- Sales-order allocation trace rows now report `allocation_sequence_scope`:
  `S` marks a single-order rank and `M` marks a global date-first multi-order
  rank. Regressions check scope values on single, date-sorted single, and
  caller-ordered multi-order results.

- Valuation-type allocation summaries now report `F`, `P`, or `U` outcomes and a two-decimal base-unit coverage percentage. Floor and full-quantity rejections report `U` and zero coverage; UOM and ATP local estimates retain both fields. Regression assertions cover all three outcomes and wrapper propagation. PLAN, README, and validator contracts were updated.

- Base WBS FEFO and location previews now rank demand summaries and emitted
  splits and expose the same rank on WBS assignment rows. Base transfer
  previews now include it on transfer assignments. Priority, date-first,
  transfer, and ATP wrappers preserve the rank on their result rows.
  PLAN, README, and validator contracts document the result shape.

- WBS FEFO and location summaries now set `minimum_coverage_rejected` from the
  final base-unit allocation. This includes all-or-none rejections below a
  positive floor, while zero floors remain false; priority, dated, transfer,
  and ATP previews preserve the nested summary field.

- Added WBS regressions for caller-order and priority-order ranks on summaries,
  splits, and assignment rows, plus FEFO/location floor-status behavior and
  full-quantity/zero-floor cases. Focused source contracts and CRLF-aware diff
  checks pass. `npm test` stops before validation because the WSL 1 Node shim
  reports that WSL 1 is unsupported and cannot locate Node.js.

- Added WBS FEFO, location, and transfer regressions proving floor-rejected
  demands leave stock available to the next demand. The assertions also verify
  that zero-allocation rows retain their sequence and that later-demand splits
  echo the later row's sequence. PLAN now states the stock-reuse behavior
  explicitly. Exact-threshold partial allocations also pass in all four base
  issue and transfer preview paths.
  Focused source checks and CRLF-aware diff checks pass; `npm test` again stops
  before validation under the WSL 1 Node launcher issue recorded in
  `ANOMALIES.md`.

- Date-first WBS FEFO and location ATP regressions now verify that coverage-floor rejection and stock reuse survive the date and ATP adapters. Transfer FEFO and location date/ATP adapters receive the same checks, including later-demand split ranks. The static PLAN guard now requires these tests. Abaplint quick fixes aligned the source to the enabled rules; `npm run lint` passes with 0 issues across 252 files, and `npm run transpile` succeeds. `npm test` and `npm run validate:plan` still stop before Node starts because the WSL 1 launcher cannot locate Node.js; ABAP Unit therefore did not run.
- Shared priority FEFO UOM result structures now declare the `allocation_sequence` fields already emitted by the adapter for source and batch split rows. Fixed malformed priority ATP assertions and related test paths, removed the invalid multi-order result access, normalized the sales-order class's missing spaces around 66 assignments/conditions, and corrected surfaced field-name/type mismatches. Abaplint's auto-fix pass applied alignment updates required by the enabled rules; the subsequent full lint and transpilation pass.
- STO source-plant creation now has a three-supplier regression for a successful first commit, failure on the last attempted supplier, and a skipped third supplier. It verifies that earlier commits remain visible, the failure still sets `stopped_on_failure` on the last row, and success/failure/skip counts stay separate. The PLAN guard checks this scenario.

- Manufacture-source-by-age summaries now include the same fixed 21-cell view for the returned detail page. It reports page-only stock quantities, counts, source and age-band shares, positive contributor counts and within-cell shares by category, availability, reservation deductions, and manufacture-date spans; each date endpoint identifies its batch, location, and valuation type with deterministic ties. UOM responses preserve shares, counts, and identities and convert quantities. Tests cover the current page and UOM propagation.

- Sales-order `order_summaries` now expose aggregate F/P/U outcomes and
  two-decimal coverage calculated from grouped base-unit totals. Summaries also
  count full, partial, unallocated, and positive coverage-floor-rejected lines;
  the three outcome counts are checked against the demand-line total. Regressions
  cover weighted 5/15 coverage and all outcome groups through single- and
  multi-order previews. Focused contract checks pass, abaplint reports 0 issues
  across 252 files, and transpilation succeeds. The PLAN validator and ABAP Unit
  could not run because the WSL Node launcher rejects WSL 1; direct `node.exe`
  invocation also fails at the WSL vsock layer.

- Added `document_summaries` to single-order, multi-order, and bulk reservation
  results. Each represented document reports F/P/U from its line outcomes and
  counts each outcome plus coverage-floor rejections without combining
  quantities across base units. Bulk `order_results` also carry the matching
  summary when a write fails or is skipped. Regressions cover all document
  outcomes, reservation forwarding, and nested bulk-row summaries. Abaplint
  reports 0 issues across 252 files; transpilation and focused checks pass. The
  PLAN validator and ABAP Unit remain unavailable through the WSL 1 Node
  launcher.

- Multi-order preview, reservation, and bulk reservation results now include
  `material_summaries` grouped across documents by material, plant, and base
  unit. The summaries merge checked quantities and line outcomes, compute
  weighted coverage, and report the number of represented sales documents.
  Regressions cover mixed preview outcomes, reservation totals, and bulk totals.
  Abaplint reports 0 issues across 252 files; transpilation and focused checks
  pass. The PLAN validator and ABAP Unit remain blocked before startup by the
  WSL 1 Node launcher.

- Sales-order material and per-document material summaries now include the
  earliest and latest nonblank required dates plus `dated_line_count`. Undated
  lines do not change the span, and date fields stay initial when a group has
  no dated demand. Lint and transpilation pass; the PLAN validator and ABAP
  Unit remain unavailable through the WSL 1 Node launcher.

- Sales-order allocation summaries now report the minimum and maximum
  `allocation_sequence` represented by each material/unit group. The min/max
  values retain the actual processing rank even when other groups occupy ranks
  between them. `allocation_sequence_scope` marks single-order ranks as `S` and
  global date-first ranks as `M`. Invalid or mixed scopes are rejected. Lint
  and transpilation pass; the PLAN validator and ABAP Unit remain unavailable
  through the WSL 1 Node launcher. The summaries also count dated demand lines
  and validate that count against their date spans.

- Sales-order order, document, and cross-document material summaries now
  report `floor_rejected_line_pct`, the two-decimal share of demand lines
  rejected by a positive coverage floor. Regressions cover zero, partial, and
  full rejection shares at all three levels. Lint passes with 0 issues across
  252 files, and transpilation succeeds. The PLAN validator still stops before
  Node startup because the WSL 1 launcher cannot locate Node.js.

- Sales-order `document_summaries` now retain the number and span of dated
  demand lines, the minimum and maximum allocation ranks, and their `S`/`M`
  scope. The nested summary remains available on bulk result rows that fail or
  are skipped. Regressions cover single, date-first, and failed bulk rows.
  Lint reports 0 issues across 252 files, and transpilation passes. The PLAN
  validator remains blocked before Node startup by the WSL 1 launcher.

- Sales-order order, document, and material summaries now report the full,
  partial, and unallocated line shares, each rounded to two decimals. A mixed
  three-line regression checks the 33.33% shares at all three summary levels;
  the docs explain that independently rounded shares may not total exactly
  100%. Abaplint reports 0 issues across 252 files and transpilation passes.
  The focused percentage regression passes. The full ABAP Unit suite stops
  earlier at `reports_cc_floor_rejection` in `zcl_cc_reservation_service`
  (expected `X`, got initial), before reaching sales-order tests. The PLAN
  validator still cannot start through the WSL 1 Node launcher.

- Batch expiry detail rows now expose `manufacturing_age_band` directly for
  dated and undated rows, using the same F/T/1–4/U codes as the aggregate.
  UOM nested base rows preserve the code. The PLAN validator's undated-row
  type fingerprint was updated to include the added field and now guards the
  row constructors, base/UOM assertions, and docs. Full `npm test` passes:
  PLAN validation, abaplint (0 issues across 252 files), transpilation, and
  ABAP Unit.

- Manufacturing-age summary bands now include available percentage of
  unrestricted stock and reservation deduction (`unrestricted - available`),
  with the percentage preserved and deduction converted in UOM results.
  Regression coverage checks a 50.00% available share and a 0.500 base-unit /
  0.042 BOX deduction. The PLAN validator guards the calculations, UOM mapping,
  test values, and docs. Full `npm test` passes.

- Seven-row manufacturing-age summaries now expose the earliest and latest known manufacture dates, their batch/location/valuation identities, and elapsed span, derived from the existing source-by-age cells. UOM results preserve these date fields. Tests cover empty unknown-date bands and a cross-source equal-date tie. `npm test` initially caught stale percentage expectations after adding the tie fixture; the expectations now account for all four batches, and the full pipeline passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Seven-row manufacturing-age endpoints now retain the resolved source group (`P` plant, `G` global fallback, or `O` other/blank) alongside their dates and batch/location/valuation identities; UOM summaries echo the markers. Regressions cover all three source groups, including an `O` earliest date, a `G` filtered result, and a latest cross-source tie resolved to `P`; they include UOM results and initial markers for undated bands. PLAN validation passes, abaplint reports 0 issues across 252 files, and full `npm test` passes.

- Manufacturing-age endpoint tie coverage now verifies the full stable order: ascending batch, then storage location, then valuation type. A same-batch equal-date fixture makes location and valuation type independently determine both endpoints, and checks that UOM output preserves the selected identities. PLAN validation, abaplint (0 issues across 252 files), transpilation, and full ABAP Unit all pass.

- Manufacturing-age endpoint summaries now verify positive signed offsets as well as zero and future-negative offsets. The base and UOM tests assert both first and last endpoint ages for a past-date band, and the PLAN validator enforces those checks. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Full and page `manufacturing_age_source_bands` cells now report signed days since their first and last manufacture dates. Empty/unknown-date cells retain zero offsets, and UOM results echo both values. Regressions cover future-date offsets in both matrices, UOM mappings, and unknown-date zeros. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Extended full and page upcoming/after-window expiry source-band rows with `days_to_first_expiration` and `days_to_last_expiration`, each calculated as `expiration_date - as_of_date`; empty cells stay zero and UOM rows echo both offsets. Regression coverage checks 1/7-day upcoming and 8/14-day after-window endpoints in full, page, and UOM results. Updated exact matrix fixtures, PLAN/README/ANOMALIES, and validator guards. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Full and page expiry source/status and expired source/age matrices now expose `days_to_first_expiration` and `days_to_last_expiration` as signed `expiration_date - as_of_date` offsets. Expired endpoints are negative, upcoming and after-window endpoints are positive, empty cells remain zero, and all four UOM matrices echo the values. Tests cover -7/-1, 1/7, and 8/14 day endpoints across full, page, and UOM output. Updated exact matrix fixtures, PLAN/README/ANOMALIES, and validator guards. `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Direct full and page expiry status/source summaries now expose signed `days_to_first_expiration` and `days_to_last_expiration` offsets, calculated as expiration date minus as-of date. Regression coverage checks expired, upcoming, after-window, page-scoped results, empty source groups, and UOM echoes. Updated PLAN/README/ANOMALIES and validator guards. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Page-wide batch expiry summaries now expose `days_to_page_earliest_exp` and `days_to_page_latest_exp` as signed endpoint offsets from `as_of_date`. Empty pages retain zero offsets, and UOM results echo both values. Regressions cover expired and future dates, empty pages, and UOM output; PLAN/README/ANOMALIES and validator guards are updated. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Page-wide batch expiry endpoints now identify the selected batch, storage location, valuation type, and raw expiry-date source. Equal endpoint dates use ascending batch, location, then valuation type as the stable tie-break; empty pages retain initial keys, and UOM results echo the identity. Added base/UOM tie and empty-page regressions and PLAN validator guards. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Full and page expiry source/status cells now identify the batch, storage location, valuation type, and raw expiry source for both first and last dates. Equal-date ties use ascending batch, location, then valuation type; regressions cover full, page, after-window, UOM echo, and empty-cell behavior. Added PLAN/README/ANOMALIES and validator guards. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Full and page expiry source/age, upcoming, and after-window cells now identify the batch, storage location, valuation type, and raw expiry source for both date endpoints. Equal-date ties use ascending batch, location, then valuation type; regression coverage checks full, page, UOM echoes, blank-source `O` rows, and empty cells. Updated PLAN/README/ANOMALIES and validator guards. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Full and page expiry source-only summaries now identify the batch, storage location, valuation type, and raw source at their first and last dates. They aggregate source/status endpoints with the same tie order and UOM echoes; regressions cover tied `P` endpoints, blank-source `O`, and empty pages. Full npm test passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Production component reads now support open planned-order components through `RESB-PLNUM`. The service validates requested planned orders and returned reservation keys, filters closed/deleted/final rows, and calculates positive open quantities. Repository and service regressions cover bulk ordering, open quantity, invalid keys, and skipped rows. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit. The first run exposed that the manual SQLite schema in `scripts/run-unit.mjs` also needed `PLNUM`; the schema and validator guard now include it.
- Planned-order component ATP previews now accept single and bulk planned-order numbers and reuse the production-component ATP engine, preserving the planned-order key on each result. Regression coverage checks ATP quantity conversion, single and bulk wrappers, invalid check-rule rejection before reads, and API calls. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Full `expiry_statuses` and page `page_expiry_statuses` now identify the batch, storage location, valuation type, and raw source at both date endpoints; UOM rows echo those keys. Regression coverage checks cross-source ties, after-window output, and empty page rows, and multi-date blank-source `O` endpoint selection in full/page UOM output. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Component ATP summaries now support planned orders and retain the `PLNUM` alongside production-order summaries. Results group by order identity, material, plant, and base unit; regression coverage checks planned-order identity and quantities. Full `npm test` passes, including PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Planned-order local stock previews now have single and bulk entry points using the shared dated stock allocator. `SUMMARIZE_COMPONENT_READINESS` groups checks by production or planned order and retains the order identity. Regression coverage checks allocated quantity, readiness counts, both wrappers, and planned-order identity. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Component shortage summaries now retain affected planned-order numbers. Replenishment suggestions carry those identifiers through monthly lot-size grouping and deduplicate a planned order that has shortages on multiple dates. An end-to-end regression covers the summary and grouped suggestion. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Added `SUMMARIZE_COMP_MATERIAL_READY`, which breaks local readiness down by order, material, plant, and base unit. Each row reports component counts, allocated and shortfall quantities, required-date span, first shortage date, material readiness, and overall order readiness. Planned-order regression coverage checks a ready component material beside a short material. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Order-level and material-level component readiness summaries now include weighted `allocation_coverage_pct`, calculated from total allocated divided by total requested quantity and rounded to two decimals. Zero-demand summaries return 0%. Regressions cover partial and full coverage; PLAN, README, and validator guards were updated. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Production/planned-order and material readiness summaries now report weighted shortage percentages alongside weighted coverage. Both percentages use aggregate quantities, round to two decimals, and return 0% for zero demand. Added partial, zero-shortage, and fully covered regression assertions and updated PLAN/README validator checks. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Component readiness summaries now report both the first and last local shortage dates at order and material scope. They reduce effective required dates independently of input order, and covered groups leave both dates initial. Regression coverage checks unsorted shortage dates and empty endpoints; PLAN/README and validator guards are updated. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Component local estimates now expose weighted `shortage_pct` beside `allocation_coverage_pct` for both individual and grouped demand. Each uses base-unit quantities, two-decimal rounding, and zero for zero demand. Regressions cover 66.67% coverage / 33.33% shortage and zero-demand behavior; PLAN/README and validator guards are updated. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Production/planned-order readiness and material readiness summaries now include `short_component_pct`: short positive-demand rows divided by covered plus short positive-demand rows. Zero-demand components do not affect the denominator, and a scope with no positive demand reports 0%. Regression fixtures verify 66.67% with an extra zero-demand row and 100% for two short rows plus a zero-demand row. PLAN/README and validator guards are updated. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Readiness summaries now include `zero_demand_component_pct`, the zero-demand component count over all component rows. Both order and material scopes return 100% for all-zero groups; weighted coverage, shortage share, and short-component share remain zero where their demand denominator is zero. Tests cover mixed and zero-only groups. PLAN/README and validator checks are updated. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Order and material readiness summaries now split short components into `partial_component_count` and `unallocated_component_count`. The counts partition `short_component_count`: partial rows have positive allocation and positive shortfall; unallocated rows have zero allocation and positive shortfall. Regression fixtures cover both outcomes, covered rows, and zero-demand rows. Updated PLAN/README and validator checks. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Production/planned-order component readiness summaries now expose the aggregate `allocation_outcome` (`F` fully covered, `P` partly covered, `U` with no allocation); zero-demand groups follow the existing full outcome convention. Regressions cover all three outcomes at order and material scope, including zero demand. Full `npm test` passes with the Linux Node runtime: PLAN validation, abaplint, transpilation, and ABAP Unit.
- Order- and material-level component readiness summaries now accept and echo `iv_as_of_date` (default `sy-datum`) and split shortages into overdue, due-today, and future short-component counts at order scope, plus base-unit shortfall quantities at material scope. The three bands partition short counts and material quantities; covered and zero-demand rows are excluded. Tests cover all bands, multi-row aggregation, fully covered rows, and invalid as-of dates.
- Readiness summaries now report overdue, due-today, and future shortage shares. Order and material rows include the share of short components in each band; material rows also include each band's share of shortfall in the group base unit. Empty shortage sets return zero, and shares round independently to two decimals. Tests cover mixed and empty bands.
- Component readiness summaries now expose the first and last overdue
  shortage dates and the first and last future shortage dates at both
  order and material scope. Empty horizons retain initial dates; due-today
  shortages are represented by the as-of date and count. Regression tests
  cover populated endpoints and empty horizons.
- Planned and production-order ATP summaries now report confirmed and
  unconfirmed quantity shares in the group's base unit. Shares round
  independently to two decimals and are both zero for zero-demand groups.
  Regression coverage checks partial, full, none, and zero-demand cases.
- Order-level ATP summaries now include the first and last required dates
  among unconfirmed components. The span remains initial when a group is
  fully confirmed or has zero demand; tests cover same-day and multi-date
  unconfirmed rows plus an empty span.
- Planned and production-order ATP summaries now report fully confirmed,
  partially confirmed, and unconfirmed component-count shares. Shares are
  relative to all rows, independently rounded to two decimals, and retain
  the existing rule that zero-demand rows count as fully confirmed. Tests
  cover mixed statuses, all-unconfirmed, and zero-demand groups.
- ATP component summaries now expose `confirmation_outcome` as `F` fully
  confirmed, `P` partially confirmed, or `U` with no confirmed quantity.
  Zero-demand groups use `F`, matching the existing fully-confirmed row
  convention. Tests cover planned-order, mixed, unconfirmed, and zero-demand
  summaries.
- Planned and production-order ATP summaries now report the first and last
  required dates for components with positive confirmed quantity. These
  endpoints remain initial when no quantity is confirmed; regressions cover
  multiple dates, a no-confirmation group, and zero demand.
- ATP component summaries now expose the first and last required dates for
  partially confirmed components, alongside the existing confirmed and
  unconfirmed spans. A partial row must have both positive confirmed and
  unconfirmed quantities; empty status spans remain initial. Regression
  tests cover mixed status dates and empty spans.
- ATP summary unconfirmed date endpoints now return the reservation number and item that produced each endpoint. Same-date rows resolve by ascending reservation number and item; a reversed-order tie fixture verifies the result, and no-unconfirmed groups retain initial identities.
- ATP summary endpoints now identify the reservation number and item for confirmed and partially confirmed date bounds as well as unconfirmed bounds. All status endpoints use ascending reservation number/item ties; regression rows arrive in reverse item order for each status.
- Order- and material-level component readiness summaries now identify the reservation number/item at first and last local shortage dates.
  Same-date endpoints use ascending reservation keys; regression checks cover reversed item order and initial identities for a covered material group.
  Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Readiness summaries now identify the reservation number/item at first and last overdue and future shortage dates. Same-date ties use ascending reservation keys, with reverse-order tie regressions at both order and material scope; empty horizons retain initial identities.
  Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Order- and material-level readiness summaries now identify the reservation number/item at first and last overall required dates. All rows, including covered and zero-demand rows, contribute; date ties use ascending reservation keys. Regression coverage confirms the zero-demand lower key wins a tied endpoint.
- Order- and material-level readiness summaries now expose the lowest and highest reservation number/item among due-today shortages. Reservation numbers sort first, with items breaking ties; empty due-today identities stay initial. Regression coverage reverses two tied reservation items and checks empty groups. Horizon counts now split into partial and unallocated components, which reconcile to each horizon total. Material horizon shortfall quantities now split along the same line and reconcile to each horizon quantity. Both summary scopes now report partial/unallocated percentages within each horizon, with zero values for empty horizons.
- Readiness summaries now report partial and unallocated percentages within each overdue, due-today, and future horizon. Percentages are zero for empty horizons and sum to 100% for populated horizons. Regression coverage checks mixed and empty horizons at order and material scope. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Component readiness summaries now return first and last shortage date endpoints separately for partial and unallocated components, with reservation number/item identities. Same-date identities use ascending keys. Tests verify reversed ties at order and material scope and initial endpoints for a covered-only group. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Material readiness summaries now report partial and unallocated shares of each horizon's shortfall quantity. Empty horizons report zero; populated pairs reconcile to 100%. Regression coverage checks overdue, due-today, and rounded future shares, plus empty horizons. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Material readiness summaries now expose aggregate partial and unallocated shortage quantities. They partition total shortfall and reconcile with the sums of their corresponding horizon quantities. Regression coverage checks mixed and empty groups. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Material readiness now reports aggregate `partial_shortfall_pct` and `unalloc_shortfall_pct` against total shortfall. The pair is zero for empty shortage groups and reconciles to 100% otherwise; tests cover rounded mixed and empty groups.
- Order and material readiness now report `partial_component_pct` and `unallocated_component_pct` as shares of short components. Empty shortage groups report zero and populated pairs reconcile to 100%; coverage tests verify both scopes.
- Component readiness endpoints now expose day offsets: overdue endpoints count back from `as_of_date`, while future endpoints count forward. Empty horizons report zero; order/material tests cover mixed and empty groups. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Partial and unallocated readiness endpoints now report signed day offsets from `as_of_date`, so consumers can distinguish overdue, due-today, and future shortage endpoints without date arithmetic. Tests cover negative, positive, and empty-group results. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Material readiness now identifies the largest single component shortfall, its date and reservation key, and its share of group shortfall. Equal quantities use ascending reservation keys; covered groups return zero values and initial identity. Tests cover a mixed tie, a unique largest component, and an empty group. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- The largest component shortfall now includes `largest_short_outcome`: `P` for partial allocation and `U` for no allocation. Empty groups keep it initial; coverage tests exercise both populated outcomes. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- The largest-shortfall material summary now includes that component's requested and allocated base quantities, reconciling with its shortfall. Tests cover partial, unallocated, and covered groups. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Material readiness now reports `largest_shortfall_req_pct`, the largest shortfall as a share of that component's requested quantity. Tests cover partial, unallocated, and empty groups. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Order-level readiness now prechecks component base units before adding quantities. It reports `quantity_base_unit` and `has_single_base_unit`; mixed or missing units leave quantity totals and weighted percentages at zero while counts, outcomes, and readiness flags remain valid. Material summaries retain per-unit quantities. Added mixed-unit and missing-unit regression tests. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- Component shortage rows now expose `allocation_outcome`, partial/unallocated short-component counts and shares, and matching shortfall quantities and shares. Count and quantity pairs reconcile to their totals and sum to 100% for populated rows. Fully covered groups remain omitted. Tests cover mixed and entirely unallocated groups. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Component shortage summary rows now echo a caller-selected `as_of_date` and report signed `required_date_offset` values (overdue negative, due today zero, future positive). Tests cover all three offsets. The PLAN, README, and validator now describe and guard the contract; full `npm test` passes.

- Component shortage rows now list each affected reservation item with
  its production or planned order, reservation number, and item.
  Lot-size replenishment suggestions preserve and deduplicate those
  identities across combined shortage dates. Regression coverage
  checks production and planned-order summaries and a multi-date
  suggestion. PLAN and README document the contract.

- Replenishment suggestions now include `pr_release_days_until`, the positive
  calendar-day distance to an upcoming requisition release. Overdue, due-
  today, and unestimated results return zero; urgency regressions verify
  all four statuses and the overdue/upcoming day counts. Updated PLAN,
  README, and validator guards.

- Replenishment suggestions now report signed `estimated_delivery_day_offset`
  from `as_of_date`, calculated as `estimated_delivery_date - as_of_date`.
  Tests cover past, same-day, future, and unestimated delivery dates.
  Updated PLAN, README, and validator guards.

- Replenishment suggestions now expose signed `latest_po_day_offset`
  from `as_of_date`, identifying past PO dates, today's date, and future
  PO dates. The urgency regression covers past, zero, future, and missing
  PO dates. Updated PLAN, README, and validator checks.

- Replenishment suggestions now include signed `required_date_offset`, calculated as
  `required_date - as_of_date`. Regression coverage checks overdue, due-today,
  future, and missing-estimate suggestions. PLAN, README, and validator checks
  now cover the field.

- Replenishment suggestions now expose signed `pr_release_day_offset` values
  from `latest_pr_release_date - as_of_date`, covering overdue, due-today,
  upcoming, and unestimated releases. Added regression checks and updated PLAN,
  README, and validator guards.

- Component shortage rows now identify the reservation component with the
  largest individual shortfall, including its production/planned order and
  reservation key. Equal quantities resolve by reservation number then item.
  Replenishment suggestions carry the maximum and its identity through grouped
  periods when all input rows provide complete metadata. Tests cover propagation
  and incomplete groups; updated PLAN and README. Full `npm test` passes.

- Component shortage rows and grouped replenishment suggestions now report
  `largest_shortfall_pct`, the largest component shortfall as a share of total
  shortfall. Incomplete grouped identity returns zero; regressions cover 91.67%,
  60.00%, and incomplete metadata.

- Component shortage rows and grouped replenishment suggestions now include
  `largest_shortfall_req_pct`, the selected component shortfall as a share of its
  own requested quantity. The selected request quantity flows through lot-size
  grouping; older inputs without it return zero for this percentage. Regression
  coverage checks a 64.71% summary share, a 100% planned-order group share, and
  incomplete monthly metadata. PLAN, README, and validator guards are updated.

- Component shortage summaries and replenishment suggestions now carry the
  selected component's requested and allocated quantities and `P`/`U` outcome.
  Suggestions preserve explicit outcomes or derive them when request metadata is
  available; incomplete identity groups clear the selected-component detail.
  Regressions cover partial and unallocated shortages, incomplete metadata, and
  invalid or contradictory outcomes. Full `npm test` passes: PLAN validation,
  abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Component shortage summaries and grouped replenishment suggestions now expose
  `largest_short_date`, the selected component's required date. Grouped results
  preserve it when the maximum changes and clear it with incomplete largest-
  component metadata; older inputs fall back to their row's `required_date`.
  Tests distinguish the selected date from the period's earliest date and reject
  invalid supplied dates. Full `npm test` passes.

- Grouped replenishment suggestions now report `largest_short_date_offset`, the
  signed day difference from `as_of_date` to the largest-shortfall component's
  required date. Tests cover future and overdue offsets, plus zero when grouped
  largest-component metadata is incomplete. PLAN validation, abaplint,
  transpilation, and ABAP Unit pass.

- Order and material readiness, component-shortage summaries, and grouped replenishment suggestions now report the largest positive component shortfall and its tie count when quantities share a base unit. Tied components retain the lowest reservation-number/item winner; mixed-unit order summaries leave largest-component details initial. Replenishment treats an omitted legacy count as one, clears counts when grouped metadata is incomplete, and rejects invalid counts. Regression coverage checks ties across a monthly period, readiness and suggestion outputs, deterministic selection, mixed units, incomplete metadata, and invalid counts. Full npm test passes on 2026-10-22: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Component readiness summaries now expose signed offsets for the selected largest-shortfall date. `SUMMARIZE_ORDER_ATP` accepts and echoes `iv_as_of_date`, reports signed offsets for required-date and confirmation-status endpoints, and identifies the first/last required-date components with deterministic reservation-key ties. Regressions cover overdue, due-today, future, tied endpoints, mixed units, and invalid reference dates. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- `SUMMARIZE_ORDER_ATP` now partitions outstanding component quantities into overdue, due-today, and future horizons and reports each horizon's share of total unconfirmed quantity. Partially confirmed remainders are included; shares are independently rounded and zero for an empty total. Regression coverage checks 11.11%, 22.22%, and 66.67%, with zero shares for an empty group. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- `SUMMARIZE_ORDER_ATP` also reports `overdue_balance_count`, `due_today_balance_count`, and `future_balance_count`: counts of components with any unconfirmed balance in each required-date horizon. The counts include partial remainders, partition all components with an outstanding quantity, and are zero for empty horizons. Tests cover one component in each horizon, including partially confirmed remainders, and an empty group. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- ATP summaries now expose `balance_component_count` and overdue, due-today, and future balance-count percentages. The three counts partition components with outstanding quantity; the percentages use that total and round independently, so three equal buckets report 33.33% each and sum to 99.99%. Regression coverage checks the total, partition, rounding, and empty-group zeros. Full `npm test` passes: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
- ATP balance horizons now identify the most overdue and nearest upcoming components through `oldest_overdue_balance_date` and `next_future_balance_date`, with deterministic reservation-key ties and signed date offsets. Regressions cover tied overdue and future dates, tie selection, offsets, and empty-horizon defaults. Full `npm test` passes with exit code 0.
- ATP horizon endpoint ranges are complete: summaries identify oldest and latest overdue components, nearest and latest future components, and the lowest/highest due-today reservation keys. Date endpoints include signed day offsets and deterministic tie selection; empty buckets return initial identities and zero offsets. Full `npm test` passes with exit code 0.
- ATP summaries now expose `overdue_unconfirmed_req_pct`, `due_today_unconfirmed_req_pct`, and `future_unconfirmed_req_pct`, each horizon's outstanding amount as a share of requested quantity. They round independently and return zero for zero demand. Regression checks cover 8.33%, 16.67%, and 50.00%, their reconciliation to total unconfirmed demand, and zero-demand groups. Full `npm test` passed with exit code 0.
- ATP overdue balances are split into 1-7, 8-30, 31-90, and over-90-day bands. Each band reports component count and outstanding quantity; counts partition overdue components and quantities reconcile to overdue unconfirmed quantity. Partially confirmed remainders are included. Boundary regressions cover 1, 7, 8, 30, 31, 90, and 91 days, plus empty bands. Full `npm test` passed with exit code 0.

- ATP overdue age bands now report count shares of `overdue_balance_count` and quantity shares of `overdue_unconfirmed_base_qty`. Shares are rounded independently to two decimals and return zero for empty overdue totals. Regression checks cover the 1-7, 8-30, 31-90, and over-90-day shares, rounding to 100%, and empty-band defaults. PLAN validation passed, abaplint reported 0 issues across 252 files, and full `npm test` passed with exit code 0.

- ATP overdue age bands now also report `overdue_1_7_req_pct`, `overdue_8_30_req_pct`, `overdue_31_90_req_pct`, and `overdue_over_90_req_pct`, each band's outstanding quantity as a share of requested base quantity. The four shares reconcile to `overdue_unconfirmed_req_pct` subject to rounding and return zero for zero demand. Tests cover exact band percentages, reconciliation, and empty-group defaults. Full `npm test` passed with exit code 0.

- ATP overdue age-band summaries now report partial component counts and outstanding remainder quantities for each of the four bands. These are subsets of band totals; fully unconfirmed counts and quantities can be derived by subtraction. Regressions cover partial remainders in every age band and zero defaults for empty groups. Full `npm test` passed with exit code 0.

- Batch expiry availability selectors now have direct regression coverage for inclusive negative/positive base-unit quantity bounds, composition with positive-only filtering, negative/zero/over-100 availability percentages, selected-category quantity bounds, UOM echo, and invalid ranges before reads. The negative-availability case exposed page summaries using a nonnegative-only accumulator; dated and undated page totals now preserve signed availability with overflow checks. Full `npm test` passed with exit code 0, and PLAN validation passed after the documentation update.

- Batch-expiry regressions now check oldest and youngest manufacture-date identities through storage location, valuation type, and raw source for tied dates in base and UOM results. Availability coverage also exercises inclusive signed reservation-deduction bounds in base units, summary reconciliation, UOM selector echo, and reversed or inactive bounds before reads. Full `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Production-order finish-window regressions now cover inclusive unreceived-percent boundaries, zero-open completed and over-received orders, percentage filtering before pagination, cursor continuation, detail drift, invalid selections before reads, and over-receipt percentages on bulk and finish-window reads. Fixed two ABAP test syntax errors found by lint. Full `npm test` passed with exit code 0.

- Production-order finish-window reads now support `filter_order_type` to select an exact AUFK-AUART value, including blank; nonblank order types still filter by default. The repository applies the selector before pagination, and detail reads report type drift. SQLite and service regressions cover blank/nonblank matching, invalid flags, drift, and one-row cursor continuation. Full `npm test` passed with exit code 0.

- Production and planned-order open-component reads now accept an optional inclusive required-date window. Either bound may stand alone; active windows exclude undated rows, invalid flags/dates and reversed bounds are rejected before reads, and RESB applies the predicates in SQL. SQLite repository and service regressions cover inclusive endpoints, one-sided bounds, undated exclusion, single/bulk forwarding, and invalid input. PLAN, README, and validator guards document the contract. Full `npm test` passed: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- The component required-date window now flows through production/planned single and bulk stock, ATP, and scoped previews. The shared preview pipeline validates the selection before reads and filters source RESB dates before evaluation; allocation-policy date overrides apply after the source-date filter. Regressions cover planned ATP/stock and production ATP/stock preview paths, plus invalid preview selection before reads. PLAN, README, and validator guards cover the contract. Full `npm test` exited 0: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Component reservation selectors now support overdue (`O`), due-today (`T`), future (`F`), and undated (`U`) buckets relative to a validated `as_of_date`. Buckets intersect with inclusive date windows, and service validation rejects invalid selectors before repository reads. Production and planned reads share the SQL behavior; tests cover all buckets, range composition, and invalid input. Full `npm test` passes with exit code 0: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Component required-date buckets now include `N` for future dates after `as_of_date` through a configurable positive `required_date_horizon_days`. The bound composes with inclusive date ranges and rejects date overflow before repository access. Added Gregorian-safe day arithmetic and tests across month, leap-day, and supported-date boundaries, plus production and planned repository/service regressions. Full `npm test` passes with exit code 0: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.

- Required-date bucket `R` now selects recent overdue component dates from `as_of_date - required_date_horizon_days` through yesterday. It composes with inclusive date bounds for production and planned orders; nonpositive horizons and lower-bound underflow are rejected before reads. Regression coverage includes repository SQL, single-order service reads, and date-range composition. Full `npm test` passes with exit code 0: PLAN validation, abaplint (0 issues across 252 files), transpilation, and ABAP Unit.
