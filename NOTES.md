# Development notes

## Current status

Iteration 1 is complete: the allocator orders demand by priority and required
date, consumes batches by earliest expiry, preserves safety stock, and reports
shortages. The implementation passes abaplint and transpiled ABAP Unit tests.

Iteration 2 is complete: an optional complete-delivery constraint performs a
preflight check, and an all-or-nothing demand does not consume stock unless its
full quantity is available.

Iteration 3 is complete: fail-fast validation uses the checked exception
`zcx_stock_allocation`, so invalid business quantities cannot silently enter
allocation. The exception identifies the affected request or batch.

Iteration 4 is complete: demand-specific minimum remaining shelf life is
calculated from the requirement date and enforced inside the SAP ATP boundary.
Complete-delivery preflight and actual batch consumption share that threshold.

Iteration 5 is complete: fractional demand quantities are normalized into the
material base unit using SAP-style numerator/denominator conversion factors.
Stock and allocation results remain in the base unit, inverse conversion is
supported, and invalid or missing unit data fails before results are returned.

Iteration 6 is complete: `allocate_with_projection` exposes one request-level
outcome per demand and a remaining-stock projection. The allocation-only method
remains as a compatibility wrapper for existing callers.

Iteration 7 is complete: request IDs are unique and non-empty, demand and stock
rows require material/plant keys, and the allocation date is mandatory. All
identity validation runs before business processing.

Iteration 8 is complete: `zcl_sap_stock_facade` maps sales requirements,
inventory, and unit factors into the domain engine and maps detailed results
back into SAP-shaped structures without taking over transaction control.

Iteration 9 is complete: duplicate material/plant/batch stock rows and duplicate
material/unit-pair conversion records are rejected, including inverse records.
Keys remain independently scoped by plant or material as appropriate.

Iteration 10 is complete: external material/plant/batch reservations reduce ATP
only during their validity windows. Allocation neither consumes nor persists
reservation records, and the SAP facade maps reservation document/item fields.

Iteration 11 is complete: deterministic audit events record request evaluation,
batch allocation, shortage or complete rejection, and final request completion.
The SAP facade restores sales-document/item correlation on every event.

Iteration 12 is complete: batch selection supports FEFO, FIFO by receipt/posting
date, and ascending batch code. FEFO remains the compatibility default, and
unknown dates sort after known dates.

Iteration 13 is complete: caller-supplied allocation run IDs and demand groups
propagate through detailed results and audit events. Group summaries provide
full, partial, shortage, and total request counts.

Iteration 14 is complete: each material may have one validated batch-strategy
override, while materials without an override use the run-level strategy.

Iteration 15 is complete: allocation runs expose request/service counts and
percentages, while quantity fill rates are grouped safely by material, plant,
and unit. Empty runs return zero-safe metrics.

Iteration 16 is complete: demand ordering supports priority/date, date/priority,
and request-ID policies. Priority/date remains the compatibility default, and
the effective policy is present in detailed and audit results.

Iteration 17 is complete: one simulation call evaluates all supported demand
policies against the same caller-owned input snapshot. Each stable, labeled
scenario contains a complete independent projection, and the SAP facade maps
the nested results back to sales-document and inventory fields.

## Architecture and SAP integration

- `zcl_stock_allocator` is a deterministic domain service. It has no database,
  transaction, UI, or framework dependency, so an existing SAP application can
  call it without hidden commits or updates.
- `zcl_sap_atp_rules` in `sap/` is the explicit compatibility boundary for ATP
  semantics that open-abap does not provide. It currently models unrestricted,
  quality-inspection, blocked, expired, and safety stock.
- The public API uses ABAP-native structures and internal tables. A productive
  SAP adapter should map system stock and demand data into these structures,
  call the allocator, and persist accepted results in the caller's transaction.
- `src/`, `sap/`, and `test/` are included in both linting and transpilation.

## Decisions

- A lower numeric priority is allocated first.
- Equal priorities are ordered by requirement date and request ID.
- Eligible batches are consumed by earliest expiry date and then batch ID.
- Shelf life is measured from the requirement date; a batch expiring exactly on
  the calculated threshold remains eligible.
- Shortages are explicit result rows with an empty batch.
- The input tables are copied before sorting and consumption; caller-owned data
  is never mutated.
- Detailed results keep batch allocation lines, request summaries, and projected
  stock together so SAP callers can persist them in one transaction.
- Request ID is the correlation key for exactly one demand summary and must be
  unique within an allocation call.
- The SAP facade owns field mapping only. Database reads, enqueue/dequeue,
  persistence, and `COMMIT WORK` remain the responsibility of its caller.
- Stock identity is material/plant/batch. A conversion identity is material plus
  an unordered source/target unit pair, so both directions cannot conflict.
- Reservations are external, read-only holds. Active quantities reduce ATP,
  while expired and future reservations do not affect an allocation run.
- Audit events are return data, not side effects. Stable codes and sequences let
  a SAP caller decide whether and how to write application logs.
- Unknown expiry or receipt dates sort after known dates. The effective strategy
  is part of detailed and audit results for reproducibility.
- Demand groups are reporting/correlation metadata and do not alter priority or
  inventory competition. Group summaries count outcomes rather than combining
  quantities with potentially different units.
- A material strategy override affects only that material; audit events record
  the resolved strategy used for each demand.
- Run-level service percentages use request counts. Quantity fill percentages
  are calculated only within material/plant/unit groups.
- Demand policy changes ordering only; the effective policy is returned and
  included in every audit event for reproducibility.
- Policy simulations run in priority/date, date/priority, and request-ID order.
  They reuse the normal validated allocation path and never carry stock
  consumption from one scenario into the next.
- Conversion factors follow `target = source * numerator / denominator`; the
  inverse direction is derived automatically.

## Candidate iterations

1. Required-date lateness and urgency scoring.
2. Policy comparison deltas and recommendation criteria.
