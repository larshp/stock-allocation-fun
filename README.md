# stock-allocation-fun

A small, test-driven stock allocation engine in ABAP.

The first feature allocates unrestricted stock to demand in priority and
requirement-date order. Batches are consumed by earliest expiry first. Expired
stock, quality-inspection stock, blocked stock, and safety stock are not
available for allocation. Any unmet demand is returned as a shortage line.

Set `complete_delivery = abap_true` on a demand to require all-or-nothing
fulfilment. If eligible stock cannot cover the full quantity, the allocator
returns a full shortage and leaves all batches available for later demands.

The checked exception `zcx_stock_allocation` rejects non-positive demand
quantities and negative stock quantities before allocation begins. SAP callers
must either handle or declare this exception; no partial result is returned for
invalid input.

Set `minimum_shelf_life_days` when a demand requires stock to remain usable
after its requirement date. A batch is eligible only when its expiry date is on
or after the requirement date plus the requested number of days. The same rule
is used for complete-delivery preflight and actual batch consumption.

Quantities use a packed number with three decimal places, matching the common
precision of SAP quantity fields while preserving fractional stock. A demand
may provide `requested_unit` and the material `base_unit`; allocation normalizes
the request into the base unit using conversion factors passed from the SAP
boundary. Stock and result rows carry `unit_of_measure` and remain in the base
unit. Direct and inverse factors are supported, while missing factors, invalid
factors, and mixed stock units fail before a result is returned.

Use `allocate_with_projection` when the caller needs more than batch-level
lines. It returns those allocations plus one request summary (`FULL`, `PARTIAL`,
or `SHORTAGE`) and a post-allocation stock projection. The projection retains
safety stock and all non-consumed stock attributes. The original input tables
remain unchanged. Existing callers may continue using `allocate`, which is a
compatibility wrapper returning only allocation lines.

Validation also requires an allocation date, unique non-empty request IDs, and
material/plant keys on every demand and stock row. Violations are reported via
specific `zcx_stock_allocation` reasons before any business processing starts,
which keeps request summaries unambiguous for SAP persistence and tracing.

`zcl_sap_stock_facade` is the integration entry point for an existing SAP
application. Its types use familiar sales and inventory field names (`VBELN`,
`POSNR`, `MATNR`, `WERKS`, `CHARG`, `LABST`, `VRKME`, `MEINS`, `UMREZ`, and
`UMREN`). It maps those records to the pure engine and maps detailed results
back to SAP-shaped structures. The facade intentionally performs no database
updates, commits, or lock handling; the calling application retains its normal
SAP LUW and persistence policy.

Input identity is strict: stock is unique by `MATNR`/`WERKS`/`CHARG`, and a
conversion is unique by material plus its unordered unit pair. Supplying both
directions is therefore rejected rather than allowing inconsistent factors.
Conversion material, source unit, and target unit are mandatory. These checks
prevent double-counted inventory and conversion results that depend on table
order.

Optional external reservations reduce stock only while their validity window is
active on the allocation date. Reservations are identified independently and
match one material/plant/batch stock row; they are not consumed by allocation.
The SAP facade maps `RSNUM`, `RSPOS`, and `BDMNG` into this read-only hold model.
Open-ended start or end dates are supported, while invalid windows, quantities,
and identities are rejected before allocation.

Detailed results also include ordered audit events with stable codes:
`REQUEST_EVALUATED`, `BATCH_ALLOCATED`, `SHORTAGE_RECORDED`,
`COMPLETE_REJECTED`, and `REQUEST_COMPLETED`. Events carry the allocation date,
business keys, quantities, unit, and final status but are not persisted or sent
to a logger by the engine. The SAP facade restores `VBELN`/`POSNR`, allowing the
caller to forward them to BAL or its existing application-log infrastructure.

Batch selection is configurable per run. `FEFO` is the default and consumes the
earliest expiry first, `FIFO` consumes the earliest receipt/posting date, and
`BATCH` uses ascending batch code. Missing expiry or receipt dates sort after
known dates. The SAP facade maps `BUDAT` for FIFO and returns the effective
strategy in both the detailed result and every audit event.

Callers may supply a `run_id` and a `demand_group`/SAP `group_id`. Correlation is
returned on allocations, request summaries, group summaries, and audit events.
Group summaries count total, full, partial, and shortage requests without
adding quantities across incompatible materials or units. An omitted group
defaults to the request ID. Grouping is deliberately observational: established
priority/date order and stock competition do not change.

Per-material strategy overrides may replace the run-level batch strategy for
selected materials. Overrides are unique by material, validated against the
same FEFO/FIFO/BATCH codes, returned with the detailed result, and reflected in
each affected audit event. Materials without an override continue using the
run-level default.

Run metrics report request counts, full/partial/shortage outcomes, served
requests, allocation/audit/stock record counts, full-service percentage, and
served-request percentage. Quantity totals and fill rates are deliberately
grouped by material, plant, and unit so unlike quantities are never added.
Empty runs return zero-safe metrics. The SAP facade maps material metrics back
to `MATNR`, `WERKS`, and `MEINS`.

Demand ordering is configurable per run. `PRIORITY_DATE` remains the default,
`DATE_PRIORITY` gives requirement date precedence, and `REQUEST_ID` provides a
stable identifier-only order. The effective policy is returned in detailed and
SAP facade results and copied to every audit event. Invalid policy names fail
before any stock is consumed.

Use `simulate_demand_policies` to compare all three policies from one immutable
input snapshot. It returns labeled scenarios in `PRIORITY_DATE`,
`DATE_PRIORITY`, and `REQUEST_ID` order; every scenario contains the same full
projection available from a normal allocation call, including summaries,
metrics, audit events, and remaining stock. The SAP facade exposes the same API
with nested results mapped back to SAP-shaped fields. Simulation has no database
or transaction side effects, and stock consumption never leaks between
scenarios.

## Layout

- `src/` contains application allocation logic.
- `sap/` contains the SAP business-semantics compatibility layer that is not
  supplied by open-abap. Keeping it separate makes the emulated standard rules
  explicit and replaceable on a real SAP system.
- `test/` contains ABAP Unit tests executed by the transpiler.
- `ANORMALIES.md` records toolchain and runtime discrepancies.
- `NOTES.md` records progress, design decisions, and the next iterations.

Both `abaplint.jsonc` and `abap_transpile.json` include all three ABAP source
directories.

## Test

```sh
npm install
npm test
```
