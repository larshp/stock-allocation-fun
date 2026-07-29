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

## Next iteration

Select the productive allocation target (SD schedule-line confirmation, MM
reservation, or a custom allocation ledger). Then add the matching SAP adapters,
standard API stubs, and contract tests without changing the pure allocator or
transaction boundary.
