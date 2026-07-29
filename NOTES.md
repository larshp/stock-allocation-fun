# Progress notes

## 2026-07-29 — Iteration 1: allocation core

- Added a reproducible npm, abaplint, and open-abap transpiler setup.
- Added shared material, plant, quantity, order, and demand types.
- Added stock and order ports so business logic has no direct SAP dependency.
- Implemented deterministic priority/date/order allocation with partial fills.
- Added input validation before mutation, making validation failure atomic.
- Added an orchestration service and in-memory stock/order test doubles.
- Added minimal MARC, MARD, VBAK, and VBAP DDIC stubs in `sap-stubs/`.
- Added seven executable ABAP Unit tests and a result checker.

Verification: abaplint reports zero findings; transpilation includes all 14 ABAP
and DDIC files; all seven ABAP Unit tests pass.

## 2026-07-29 — Iteration 2: shortage visibility

- Added an explicit shortage quantity to every demand result.
- Shortage is calculated by the pure allocator for full, partial, and zero fills.
- Extended allocator and service tests to cover shortage propagation and saving.

## 2026-07-29 — Iteration 3: transactional orchestration

- Added `ZCX_SALLOC_INTEGRATION` so SAP access failures are explicit and checked.
- Added `ZIF_SALLOC_TRANSACTION` with SAP and in-memory implementations.
- Wrapped stock reservation and order allocation writes in one logical unit of work.
- Added rollback handling for validation, read/write, and commit failures.
- Added failure-path tests proving integration and validation errors roll back
  without commit.
- Increased the verified suite to nine ABAP Unit tests across 18 source objects.

## 2026-07-29 — Iteration 4: demand identity integrity

- Reject duplicate order IDs before sorting or changing allocation results.
- Added a regression test proving duplicate rejection leaves prior allocation and
  shortage values untouched.

## 2026-07-29 — Iteration 5: allocation simulation

- Added `iv_simulate` to calculate allocations and shortages without writes.
- Simulation performs no reserve, save, transaction begin, commit, or rollback.
- Added an end-to-end service test covering results and every side-effect boundary.
- Increased the verified suite to eleven ABAP Unit tests across 18 source objects.

## 2026-07-29 — Iteration 6: productive custom ledger adapters

- Selected the custom allocation ledger as the productive write target.
- Added `ZSALLOC_STOCK` and `ZSALLOC_ORDER` application tables.
- Added SAP adapters plus SQLite-backed ABAP Unit contract tests.
- Fixed generated-runner database initialization through a setup hook.

## 2026-07-29 — Iteration 7: end-to-end persistence

- Exercised stock reads, demand allocation, both ledger writes, transaction commit,
  release, reallocation, and repeat-run behavior through productive adapters.

## 2026-07-29 — Iteration 8: concurrency and release

- Rechecked physical availability while reserving.
- Added optimistic compare-and-update protection to both ledger tables.
- Added transactional release so cancelled allocations do not strand stock.

## 2026-07-29 — Iteration 9: schedule-line demand

- Replaced aggregate item demand with VBEP schedule-line quantities and requested
  delivery dates.
- Expanded identity to `VBELN + POSNR + ETENR` and adopted SAP type `MATNR`.

## 2026-07-29 — Iteration 10: runnable SAP entry point

- Added a productive dependency factory and simulation-first report `ZSALLOC_RUN`.
- Added MARC plant-extension validation before aggregating MARD stock.
- Increased the suite to twenty ABAP Unit tests across 28 source objects.

## 2026-07-29 — Iteration 11: automatic reconciliation

- Added reconciliation against current VBEP requested and confirmed quantities.
- Releases excess allocation after confirmation changes and all allocation after
  schedule-line deletion.
- Added simulation-first report `ZSALLOC_RECONCILE` for review and background use.
- Increased the suite to twenty-three ABAP Unit tests across 31 source objects.

## 2026-07-29 — Iteration 12: authorization boundary

- Added authorization object `Z_SALLOC` with activity and plant fields.
- Enforced display authorization for simulation and change authorization before
  any productive transaction begins.
- Added an injectable authorization port and denial-path regression test.
- Increased the suite to twenty-four ABAP Unit tests across 35 source objects.

## 2026-07-29 — Iteration 13: transactional audit logging

- Added UUID-keyed `ZSALLOC_LOG` and injectable logger implementations.
- Allocation and release audit rows now commit atomically with ledger changes.
- Kept simulation side-effect free and added database-backed logger coverage.

## 2026-07-29 — Iteration 14: contention safety probe

- Added an overlapping-reservation test to the mandatory npm pipeline.
- Verified contention never reserves more than physical availability.
- Recorded open-abap's shared `SY-SUBRC` limitation for concurrent promises.

## 2026-07-29 — Iteration 15: enforced audit operations

- Made the logger dependency mandatory; no implicit no-op logger remains.
- Added authorized report `ZSALLOC_LOG` for committed audit inspection.
- Added rollback coverage for audit-write failures.
- Increased the suite to twenty-six ABAP Unit tests across 41 source objects,
  plus the mandatory concurrency safety probe.

## 2026-07-29 — Iteration 16: target-SAP rollout gate

- Added authorized read-only invariant report `ZSALLOC_CHECK`.
- Added a repeatable two-user SAP concurrency protocol with pass/fail criteria and
  safe cleanup instructions in `SAP_CONCURRENCY_TEST.md`.
- Verified 42 source objects, twenty-six ABAP Unit tests, and the local contention
  safety probe through the complete npm pipeline.

## 2026-07-29 - Iteration 17: quantity-unit correctness

- Corrected productive demand and reconciliation arithmetic to use `VBEP-LMENG`
  in stockkeeping units instead of sales-unit `VBEP-WMENG`.
- Extended the VBEP test surface with `LMENG`.
- Added regression data with intentionally different sales and base quantities.
- Reverified 42 source objects, twenty-six ABAP Unit tests, and the contention
  safety probe through the complete npm pipeline.

## 2026-07-29 - Iteration 18: governed audit retention

- Added simulation-first, plant-scoped `ZSALLOC_LOG_CLEANUP`.
- Enforced display/change authorization and explicit cutoff timestamps.
- Made productive deletion transactional and retained a `LOG_RETENTION` event.
- Added simulation, scoped deletion, self-audit, and authorization regressions.
- Added `OPERATIONS.md` with scheduled controls and incident response.

## 2026-07-29 - Iteration 19: eligible SD demand only

- Excluded rejected `VBAP` items and non-order sales-document categories.
- Applied identical eligibility checks during reconciliation.
- Released allocations when an item's material or plant no longer matches its
  ledger context.
- Increased the verified suite to thirty-three ABAP Unit tests.

## Next iteration

Account for existing SAP-confirmed schedule quantities when deriving allocatable
on-hand stock, then continue the production-readiness audit. Target-SAP
multi-work-process execution remains a rollout activity described in
`SAP_CONCURRENCY_TEST.md`.
