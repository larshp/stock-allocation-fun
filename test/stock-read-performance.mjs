import assert from "node:assert/strict";
import "../output/_init.mjs";
const {ltcl_source} = await import("../output/zcl_stock_source_sap.clas.testclasses.mjs");

const db = abap.context.databaseConnections.DEFAULT;
const select = db.select.bind(db);
const reads = [];
db.select = async (options) => {
  reads.push(options.select);
  return select(options);
};

try {
  const test = await new ltcl_source().constructor_();
  const access = test.FRIENDS_ACCESS_INSTANCE;
  // Empty FAE drivers must never reach SQL; their ABAP semantics ignore WHERE.
  await access.setup();
  await access.empty_selection();
  assert.equal(reads.length, 0, "Empty requests must not read any table");
  await access.deleted_location();
  assert.equal(reads.length, 1, "No found stock must skip the MARA query");
  reads.length = 0;
  await access.setup();
  await access.multiple_material_locations();
  const count = (table) => reads.filter(sql => new RegExp(`\\bFROM\\s+["']?${table}\\b`, "i").test(sql)).length;
  // The transpiler expands FAE into per-key SELECTs; native SAP may package them.
  assert.equal(count("mard"), 3, "Expand each distinct location once");
  assert.equal(count("mara"), 2, "Expand each distinct found material once");

  // Reuse the same source instance after master data changes: no cache across calls.
  await db.execute("UPDATE mara SET meins = 'ST' WHERE matnr = 'MAT1'");
  reads.length = 0;
  const stocks = await access.source.get().zif_stock_source$read({requests: access.requests});
  assert.equal(stocks.array()[0].get().unit.get().trim(), "ST");
  assert.equal(stocks.array()[1].get().unit.get().trim(), "ST");
  assert.equal(count("mara"), 2, "Refresh material units on each read");
  console.log("Stock reader: empty guards, deduplicated bulk keys and fresh units verified");
} finally {
  db.select = select;
  await db.disconnect();
}
