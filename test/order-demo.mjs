import assert from "node:assert/strict";
import runtime from "@abaplint/runtime";
import "../output/_top.mjs";

// Load pure objects only: no SQLite, SAP source classes or BAPI function groups.
abap.console = new runtime.MemoryConsole();
abap.context.console = abap.console;
for (const file of ["zif_stock_alloc_types.intf", "zcx_stock_alloc.clas",
  "zif_stock_source.intf", "zif_stock_order_source.intf", "zif_stock_reservation_source.intf",
  "zif_stock_goods_issue.intf", "zif_stock_reserved_issue.intf",
  "zcl_stock_alloc_date.clas", "zcl_stock_alloc_origin.clas", "zcl_stock_alloc_result.clas",
  "zcl_stock_allocator.clas", "zcl_stock_alloc_service.clas", "zcl_stock_order_policy.clas",
  "zcl_stock_order_service.clas", "zcl_stock_order_summary.clas", "zcl_stock_alloc_comparison.clas",
  "zcl_stock_reserved_checked.clas"]) {
  await import(`../output/${file}.mjs`);
}
await import("../output/zstock_order_demo.prog.mjs");
const output = abap.console.get().trim().replace(/ +/g, " ");
assert.match(output, /Order 000000001000: FULL, full 2, partial 0, unfilled 0/);
assert.match(output, /Order 000000002000: PARTIAL, full 0, partial 1, unfilled 0/);
assert.match(output, /Shortage ORDER2-PART: 6(?:\.0+)? ST/);
assert.match(output, /ORDER1-FLUID: UNCHANGED, delta 0(?:\.0+)? KG/);
assert.match(output, /ORDER1-PART: UNCHANGED, delta 0(?:\.0+)? ST/);
assert.match(output, /ORDER2-PART: IMPROVED, delta 6(?:\.0+)? ST/);
assert.match(output, /Checked preview: 3 items, simulated X/);
assert.match(output, /Local preview only; no SAP call/);
assert.match(output, /Reduced stock: blocked; preview calls 1/);
assert.match(output, /Current stock cannot cover the proposed issue for ORDER2-PART/);
assert.doesNotMatch(output, /Unexpected:|Demo failed:/);
assert.equal(output.split("\n").length, 13);
console.log(output);
