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

## Next iteration

Select the productive allocation target (SD schedule-line confirmation, MM
reservation, or a custom allocation ledger). Then add the matching SAP adapter,
standard API stubs, rollback behavior, and contract tests without changing the
pure allocator.
