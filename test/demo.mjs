import assert from "node:assert/strict";
import runtime from "@abaplint/runtime";
import "../output/_top.mjs";

// The pure demo requires neither SQLite fixtures nor any SAP connection.
abap.console = new runtime.MemoryConsole();
abap.context.console = abap.console;
for (const file of ["zif_stock_alloc_types.intf", "zcx_stock_alloc.clas",
  "zcl_stock_alloc_date.clas", "zcl_stock_alloc_origin.clas", "zcl_stock_allocator.clas"]) {
  await import(`../output/${file}.mjs`);
}
await import("../output/zstock_alloc_demo.prog.mjs");
const output = abap.console.get().trim().replace(/ +/g, " ");
assert.match(output, /available 15 ST/);
assert.match(output, /URGENT: allocated 8(?:\.0+)? ST, shortage 0(?:\.0+)?, FULL/);
assert.match(output, /WHOLE-LOTS: allocated 4(?:\.0+)? ST, shortage 4(?:\.0+)?, PARTIAL/);
assert.match(output, /REMAINDER: allocated 3(?:\.0+)? ST, shortage 2(?:\.0+)?, PARTIAL/);
assert.equal(output.split("\n").length, 4);
console.log(output);
