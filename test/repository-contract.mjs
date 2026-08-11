import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const testDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryDirectory = path.resolve(testDirectory, "..");
const sourceDirectory = path.join(repositoryDirectory, "src");
const stubDirectory = path.join(repositoryDirectory, "sap_stubs");

function readJson(fileName) {
  return JSON.parse(fs.readFileSync(path.join(repositoryDirectory, fileName), "utf8"));
}

const abaplint = readJson("abaplint.json");
const transpiler = readJson("transpiler.json");
const packageJson = readJson("package.json");
const readmeSource = fs.readFileSync(path.join(repositoryDirectory, "README.md"), "utf8");

for (const fileName of fs.readdirSync(sourceDirectory).filter((name) => name.endsWith(".abap"))) {
  if (fileName.endsWith(".testclasses.abap")) {
    continue;
  }
  assert.match(
    fileName,
    /^z/i,
    `production ABAP object must use the Z namespace: ${fileName}`,
  );
}
for (const fileName of fs.readdirSync(sourceDirectory).filter(
  (name) => /\.(clas|intf|prog)\.abap$/i.test(name) && !name.endsWith(".testclasses.abap"),
)) {
  const objectKind = /\.(clas|intf|prog)\.abap$/i.exec(fileName)[1].toLowerCase();
  const objectName = fileName.replace(/\.(clas|intf|prog)\.abap$/i, "").toUpperCase();
  const metadataPath = path.join(
    sourceDirectory,
    fileName.replace(/\.abap$/i, ".xml"),
  );
  assert.ok(
    fs.existsSync(metadataPath),
    `${fileName} must have matching abapGit metadata`,
  );
  const metadata = fs.readFileSync(metadataPath, "utf8");
  const serializer = objectKind === "clas"
    ? "LCL_OBJECT_CLAS"
    : objectKind === "intf"
      ? "LCL_OBJECT_INTF"
      : "LCL_OBJECT_PROG";
  const identityTag = objectKind === "prog" ? "NAME" : "CLSNAME";
  assert.match(
    metadata,
    new RegExp(`serializer=\\"${serializer}\\"`, "i"),
    `${fileName} metadata must use the ${serializer} serializer`,
  );
  assert.match(
    metadata,
    new RegExp(`<${identityTag}>\\s*${objectName}\\s*<\\/${identityTag}>`, "i"),
    `${fileName} metadata identity must match the ABAP object name`,
  );
}
assert.deepEqual(
  fs.readdirSync(stubDirectory).filter((name) => name.endsWith(".abap")),
  [],
  "SAP stubs must remain separate from custom ABAP source objects",
);

assert.ok(
  abaplint.global.files.includes("/src/**/*.*"),
  "abaplint must lint custom source objects",
);
assert.ok(
  abaplint.global.files.includes("/sap_stubs/**/*.*"),
  "abaplint must lint SAP standard stubs",
);
assert.deepEqual(
  transpiler.input_folder,
  ["src", "sap_stubs"],
  "transpiler must compile custom objects and SAP standard stubs",
);

for (const [name, dependencies] of [["abaplint", abaplint.dependencies], ["transpiler", transpiler.libs]]) {
  const openAbapCore = dependencies.find((entry) => entry.url.includes("open-abap-core"));
  assert.ok(openAbapCore, `${name} must configure open-abap-core as a dependency`);
  assert.equal(
    openAbapCore.folder,
    "/node_modules/open-abap-core",
    `${name} must use the installed open-abap-core folder`,
  );
  assert.equal(
    openAbapCore.files,
    "/src/**/*.*",
    `${name} must load the open-abap-core source files`,
  );
}
assert.equal(
  packageJson.devDependencies["open-abap-core"].includes("open-abap-core"),
  true,
  "package.json must pin open-abap-core",
);

for (const ruleName of [
  "modify_only_own_db_tables",
  "align_type_expressions",
  "easy_to_find_messages",
  "max_one_method_parameter_per_line",
  "align_parameters",
  "local_testclass_consistency",
  "allowed_object_naming",
]) {
  assert.equal(abaplint.rules[ruleName], true, `abaplint rule must remain enabled: ${ruleName}`);
}

for (const fileName of [
  "mara.tabl.xml",
  "marm.tabl.xml",
  "mard.tabl.xml",
  "mcha.tabl.xml",
  "mchb.tabl.xml",
  "vbak.tabl.xml",
  "vbap.tabl.xml",
  "vbep.tabl.xml",
  "bapi_reservation_create.mjs",
]) {
  assert.equal(
    fs.existsSync(path.join(repositoryDirectory, "sap_stubs", fileName)),
    true,
    `required SAP integration stub is missing: ${fileName}`,
  );
}
const productionFunctionModules = new Set();
for (const fileName of fs.readdirSync(sourceDirectory).filter(
  (name) => name.endsWith(".abap") && !name.endsWith(".testclasses.abap"),
)) {
  const sourceText = fs.readFileSync(path.join(sourceDirectory, fileName), "utf8");
  for (const match of sourceText.matchAll(/CALL FUNCTION\s+'([A-Z0-9_]+)'/g)) {
    productionFunctionModules.add(match[1]);
  }
}
const sapApiStub = fs.readFileSync(
  path.join(stubDirectory, "bapi_reservation_create.mjs"),
  "utf8",
);
for (const functionModule of productionFunctionModules) {
  assert.match(
    sapApiStub,
    new RegExp(`FunctionModules\\[\\"${functionModule}\\"\\]`),
    `SAP function-module stub is missing ${functionModule}`,
  );
}
const productionSourceTableNames = new Set();
for (const fileName of fs.readdirSync(sourceDirectory).filter(
  (name) => name.endsWith(".abap") && !name.endsWith(".testclasses.abap"),
)) {
  const sourceText = fs.readFileSync(path.join(sourceDirectory, fileName), "utf8");
  for (const match of sourceText.matchAll(/^\s*(?:FROM|(?:INNER|LEFT|RIGHT)?\s*JOIN)\s+([A-Z0-9_]+)/gim)) {
    const tableName = match[1].toUpperCase();
    if (!tableName.startsWith("Z")) {
      productionSourceTableNames.add(tableName);
    }
  }
}
for (const tableName of productionSourceTableNames) {
  const tableStubPath = path.join(stubDirectory, `${tableName.toLowerCase()}.tabl.xml`);
  assert.ok(
    fs.existsSync(tableStubPath),
    `SAP table stub is missing for production source dependency ${tableName}`,
  );
  const tableStub = fs.readFileSync(tableStubPath, "utf8");
  assert.match(
    tableStub,
    new RegExp(`<TABNAME>${tableName}<\\/TABNAME>`),
    `SAP table stub identity must match ${tableName}`,
  );
}
for (const fileName of [
  "zif_source_read_authority.intf.abap",
  "zcl_source_read_auth_sap.clas.abap",
  "zif_unit_conversion_authority.intf.abap",
  "zcl_unit_conversion_auth_sap.clas.abap",
]) {
  assert.equal(
    fs.existsSync(path.join(sourceDirectory, fileName)),
    true,
    `source authorization boundary is missing: ${fileName}`,
  );
}
const stockSourceSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_source_sap.clas.abap"),
  "utf8",
);
const orderSourceSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_order_source_sap.clas.abap"),
  "utf8",
);
const sourceAuthoritySource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_source_read_auth_sap.clas.abap"),
  "utf8",
);
const allocationReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_allocate.prog.abap"),
  "utf8",
);
const transactionInterfaceSource = fs.readFileSync(
  path.join(sourceDirectory, "zif_allocation_transaction.intf.abap"),
  "utf8",
);
const transactionAdapterSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_allocation_transaction_sap.clas.abap"),
  "utf8",
);
const allocationServiceSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_allocation_service.clas.abap"),
  "utf8",
);
const stockAllocationInterfaceSource = fs.readFileSync(
  path.join(sourceDirectory, "zif_stock_allocation.intf.abap"),
  "utf8",
);
const auditSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_allocation_audit_sap.clas.abap"),
  "utf8",
);
const healthReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_health.prog.abap"),
  "utf8",
);
const healthSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_allocation_health.clas.abap"),
  "utf8",
);
const unitConversionSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_unit_conversion_sap.clas.abap"),
  "utf8",
);
const reservationSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_reservation_sap.clas.abap"),
  "utf8",
);
const movementSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_movement_sap.clas.abap"),
  "utf8",
);
const orderSinkSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_order_sink_sap.clas.abap"),
  "utf8",
);
const unitConversionAuthoritySource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_unit_conversion_auth_sap.clas.abap"),
  "utf8",
);
for (const allocatorFile of [
  "zcl_stock_allocator.clas.abap",
  "zcl_stock_allocator_auto.clas.abap",
  "zcl_stock_allocator_best.clas.abap",
  "zcl_stock_allocator_fair.clas.abap",
  "zcl_stock_allocator_fifo.clas.abap",
  "zcl_stock_allocator_full.clas.abap",
  "zcl_stock_allocator_large.clas.abap",
  "zcl_stock_allocator_small.clas.abap",
  "zcl_stock_allocator_weighted.clas.abap",
]) {
  const allocatorSource = fs.readFileSync(
    path.join(sourceDirectory, allocatorFile),
    "utf8",
  );
  assert.match(
    allocatorSource,
    /priority\s*<\s*0/,
    `${allocatorFile} must reject negative priorities`,
  );
  assert.match(
    allocatorSource,
    /priority\s*>\s*zif_stock_allocation=>c_max_priority/,
    `${allocatorFile} must reject priorities above the SAP range`,
  );
}
assert.match(
  allocationServiceSource,
  /<ls_existing>-priority\s*<\s*0/,
  "allocation service snapshot reconciliation must reject negative priorities",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-priority\s*>\s*zif_stock_allocation=>c_max_priority/,
  "allocation service snapshot reconciliation must reject high priorities",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-allocation_strategy\s+IS\s+NOT\s+INITIAL[\s\S]*to_upper\(\s*<ls_existing>-allocation_strategy\s*\)\s*<>\s*'P'[\s\S]*to_upper\(\s*<ls_existing>-allocation_strategy\s*\)\s*<>\s*'W'/,
  "allocation service snapshot reconciliation must reject unknown strategies",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-reservation_movement_type\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_existing>-reservation_movement_type\s+CN\s+'0123456789'/,
  "allocation service snapshot reconciliation must reject malformed reservation movement types",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-priority\s*>\s*zif_stock_allocation=>c_max_priority/,
  "allocation service must reject high open-demand priorities",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-allocation_run_id\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_demand>-allocation_strategy\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_demand>-allocation_unit\s+IS\s+NOT\s+INITIAL/,
  "allocation service must reject allocator-owned allocation metadata mutation",
);
assert.match(
  allocationServiceSource,
  /LOOP AT lt_existing ASSIGNING <ls_existing>[\s\S]*<ls_existing>-allocation_unit\s*=\s*[\s\S]*to_upper[\s\S]*<ls_existing>-allocation_status\s*=\s*[\s\S]*to_upper/,
  "allocation service must canonicalize injected snapshot metadata",
);
assert.match(
  allocationServiceSource,
  /lv_reserved_quantity\s+>=\s+lv_available[\s\S]*lv_converted_quantity\s+>=\s+lv_available\s*-\s*lv_reserved_quantity[\s\S]*lv_reserved_quantity\s*=\s+lv_available/,
  "allocation service must cap cross-unit reservation accumulation at available stock",
);
const allocationSinkSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_allocation_sink_sap.clas.abap"),
  "utf8",
);
assert.match(
  allocationSinkSource,
  /iv_priority_from\s+IS\s+NOT\s+INITIAL[\s\S]*iv_priority_from\s*<\s*0[\s\S]*iv_priority_from\s*>\s*zif_stock_allocation=>c_max_priority[\s\S]*iv_priority_to\s*>\s*zif_stock_allocation=>c_max_priority/,
  "allocation result reads must reject priority filters outside the SAP range",
);
assert.match(
  allocationSinkSource,
  /iv_sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*iv_sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*iv_sales_document\s*=\s*'0000000000'/,
  "allocation result reads must reject malformed sales-document filters",
);
assert.match(
  allocationSinkSource,
  /iv_reservation_id\s+IS\s+NOT\s+INITIAL[\s\S]*iv_reservation_id\s*=\s*'0000000000'[\s\S]*iv_reservation_id\s+CO\s+'0123456789\s*'[\s\S]*strlen\(\s*iv_reservation_id\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "allocation result reads must reject malformed numeric reservation filters",
);
assert.match(
  allocationSinkSource,
  /is_demand-reservation_id\s*=\s*'0000000000'/,
  "allocation snapshots must reject the all-zero reservation sentinel",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-reservation_id\s*=\s*'0000000000'/,
  "allocation reconciliation must reject the all-zero reservation sentinel",
);
assert.match(
  stockSourceSource,
  /io_authority\s+TYPE REF TO zif_source_read_authority/,
  "stock source must expose an injectable read-authority port",
);
assert.match(
  stockSourceSource,
  /mo_authority->check_stock\(\s*iv_batch\s*=\s*iv_batch\s*\)/,
  "stock source must check read authority before selecting SAP stock",
);
assert.match(
  stockSourceSource,
  /batch_managed\s*<>\s*abap_true[\s\S]*batch_managed\s*<>\s*abap_false/,
  "stock source must reject noncanonical material batch-management flags",
);
assert.match(
  stockSourceSource,
  /batch_restricted\s*<>\s*abap_true[\s\S]*batch_restricted\s*<>\s*abap_false/,
  "stock source must reject noncanonical batch restriction flags",
);
assert.match(
  stockSourceSource,
  /lv_stock_deleted\s*<>\s*abap_true[\s\S]*lv_stock_deleted\s*<>\s*abap_false/,
  "stock source must reject noncanonical stock deletion flags",
);
assert.match(
  stockSourceSource,
  /lv_material_deleted\s*<>\s*abap_true[\s\S]*lv_material_deleted\s*<>\s*abap_false/,
  "stock source must reject noncanonical material deletion flags",
);
assert.match(
  stockSourceSource,
  /lv_batch_deleted\s*<>\s*abap_true[\s\S]*lv_batch_deleted\s*<>\s*abap_false/,
  "stock source must reject noncanonical batch deletion flags",
);
assert.match(
  orderSourceSource,
  /io_authority\s+TYPE REF TO zif_source_read_authority/,
  "order source must expose an injectable read-authority port",
);
assert.match(
  orderSourceSource,
  /mo_authority->check_orders\(\s*\)/,
  "order source must check read authority before selecting SAP demand",
);
assert.match(
  orderSourceSource,
  /item_deleted\s+TYPE\s+c\s+LENGTH\s+1[\s\S]*item~loekz\s+AS\s+item_deleted[\s\S]*<ls_schedule>-item_deleted\s*<>\s*abap_true[\s\S]*<ls_schedule>-item_deleted\s*<>\s*abap_false[\s\S]*<ls_schedule>-item_deleted\s*=\s*abap_true/,
  "order source must validate and exclude deleted sales-order items",
);
assert.match(
  orderSourceSource,
  /ls_demand-sales_document\s*=\s*'0000000000'/,
  "order source must reject the all-zero sales-document sentinel",
);
assert.match(
  orderSourceSource,
  /requested\s*<\s*0[\s\S]*confirmed\s*<\s*0/,
  "order source must reject negative schedule quantities",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-sales_document\s*=\s*'0000000000'/,
  "allocation service must reject the all-zero sales-document sentinel",
);
assert.match(
  allocationSinkSource,
  /is_demand-sales_document\s*=\s*'0000000000'/,
  "allocation snapshots must reject the all-zero sales-document sentinel",
);
assert.match(
  allocationSinkSource,
  /is_demand-allocation_unit\s+IS\s+INITIAL/,
  "allocation snapshots must reject blank allocation units",
);
assert.match(
  allocationSinkSource,
  /lv_run_movement_type\s+CN\s+'0123456789'/,
  "allocation snapshots must reject corrupt run movement metadata",
);
assert.match(
  allocationSinkSource,
  /lv_run_min_shelf_life\s*<\s*0[\s\S]*lv_run_safety_stock\s*<\s*0/,
  "allocation snapshots must reject corrupt run policy metadata",
);
assert.match(
  allocationSinkSource,
  /lv_run_requested_on_from\s+IS\s+NOT\s+INITIAL[\s\S]*lv_run_requested_on_to\s+IS\s+NOT\s+INITIAL[\s\S]*lv_run_requested_on_from\s*>\s*lv_run_requested_on_to/,
  "allocation snapshot run references must reject inverted requested horizons",
);
for (const tableName of ["MARA", "MARD", "MCHB", "MCHA", "VBAK", "VBAP", "VBEP"]) {
  assert.match(
    sourceAuthoritySource,
    new RegExp(`iv_table\\s*=\\s*'${tableName}'`),
    `source read authority must cover ${tableName}`,
  );
}
assert.match(
  sourceAuthoritySource,
  /IF iv_batch IS NOT INITIAL/,
  "source read authority must scope batch-table checks to batch reads",
);
assert.match(
  sourceAuthoritySource,
  /AUTHORITY-CHECK OBJECT 'S_TABU_NAM'/,
  "source read authority must use S_TABU_NAM",
);
assert.match(
  sourceAuthoritySource,
  /ID 'ACTVT' FIELD '03'/,
  "source read authority must check activity 03",
);
assert.match(
  allocationReportSource,
  /CREATE OBJECT lo_source_read_authority TYPE zcl_source_read_auth_sap/,
  "allocation report must construct the SAP source-read authority",
);
assert.match(
  allocationReportSource,
  /p_safstk/,
  "allocation report must expose the safety-stock selection",
);
assert.match(
  allocationReportSource,
  /iv_safety_stock\s*=\s*p_safstk/,
  "allocation report must pass the safety-stock selection to the service",
);
assert.equal(
  (allocationReportSource.match(/io_authority\s*=\s*lo_source_read_authority/g) ?? []).length,
  2,
  "allocation report must wire source-read authority to both SAP readers",
);
assert.match(
  transactionInterfaceSource,
  /METHODS commit[\s\S]*METHODS rollback/,
  "transaction port must expose commit and rollback operations",
);
assert.match(
  transactionAdapterSource,
  /CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'/,
  "SAP transaction adapter must implement rollback",
);
assert.match(
  reservationSource,
  /strlen\(\s*iv_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "SAP reservation cancellation must use the shared document-length contract",
);
assert.match(
  reservationSource,
  /lv_document\s+CN\s+'0123456789'[\s\S]*lv_document\s*=\s*'0000000000'/,
  "SAP reservation cancellation must validate nonzero numeric reservation documents",
);
assert.match(
  reservationSource,
  /lv_reservation\s+CN\s+'0123456789'[\s\S]*lv_reservation\s*=\s*'0000000000'/,
  "SAP reservation creation must validate a nonzero returned reservation document",
);
assert.match(
  reservationSource,
  /strlen\(\s*lv_reservation\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "SAP reservation creation must enforce the exact ten-character document length",
);
assert.equal(
  (reservationSource.match(/<ls_return>-type\s+IS\s+NOT\s+INITIAL/g) ?? []).length,
  2,
  "SAP reservation create and cancel must validate nonblank BAPI return statuses",
);
assert.match(
  reservationSource,
  /<ls_return>-type\s+<>\s+'S'[\s\S]*<ls_return>-type\s+<>\s+'I'[\s\S]*<ls_return>-type\s+<>\s+'W'[\s\S]*<ls_return>-type\s+<>\s+'E'[\s\S]*<ls_return>-type\s+<>\s+'A'[\s\S]*<ls_return>-type\s+<>\s+'X'/,
  "SAP reservation adapters must allow only canonical BAPI return statuses",
);
assert.match(
  auditSource,
  /is_run-min_shelf_life\s*<\s*0[\s\S]*is_run-safety_stock\s*<\s*0/,
  "audit run reads must reject negative policy values",
);
assert.match(
  auditSource,
  /is_run-status\s*<>\s*'R'[\s\S]*is_run-full_count\s*\+\s*is_run-partial_count[\s\S]*is_run-unallocated_count\s*<>\s*is_run-demand_count/,
  "finalized audit run reads must require exact outcome counts",
);
assert.match(
  auditSource,
  /iv_full_count\s*\+\s*iv_partial_count[\s\S]*iv_unallocated_count\s*<>\s*lv_current_demand_count/,
  "audit finalization must require exact outcome counts",
);
assert.match(
  auditSource,
  /lv_status\s*=\s*'S'[\s\S]*iv_message\s+IS\s+NOT\s+INITIAL[\s\S]*Audit final message is invalid/,
  "audit finalization must reject diagnostics on successful runs",
);
assert.match(
  allocationServiceSource,
  /to_upper\(\s*iv_status\s*\)\s*=\s*'S'[\s\S]*CLEAR\s+lv_message/,
  "allocation service must not persist diagnostics on successful runs",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-allocated\s*>\s*0[\s\S]*<ls_existing>-reservation_id\s+IS\s+INITIAL[\s\S]*<ls_existing>-reservation_date\s+IS\s+INITIAL[\s\S]*<ls_existing>-reservation_movement_type\s+IS\s+INITIAL[\s\S]*<ls_existing>-reservation_unit\s+IS\s+INITIAL/,
  "allocation service must reject allocated snapshots without reservation provenance",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*<ls_existing>-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "allocation service must reject short existing sales documents",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-reservation_id\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_existing>-reservation_id\s+CO\s+'0123456789\s*'[\s\S]*strlen\(\s*<ls_existing>-reservation_id\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "allocation service must reject short numeric existing reservation documents",
);
assert.match(
  allocationServiceSource,
  /ls_available-batch_restricted\s+<>\s+abap_true[\s\S]*ls_available-batch_restricted\s+<>\s+abap_false[\s\S]*Available stock result is invalid/,
  "allocation service must reject noncanonical stock flags",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-requested\s*>\s*0[\s\S]*<ls_demand>-order_unit\s+IS\s+INITIAL[\s\S]*Open demand unit is missing/,
  "allocation service must reject positive demand without an order unit",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-requested\s*>\s*0[\s\S]*<ls_demand>-requested_on\s+IS\s+INITIAL[\s\S]*Open demand requested date is missing/,
  "allocation service must reject positive demand without a requested date",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_demand>-sales_document_type\s+IS\s+INITIAL[\s\S]*Open demand source identity is incomplete/,
  "allocation service must reject incomplete injected sales-order identity",
);
assert.match(
  allocationServiceSource,
  /LOOP AT lt_demands ASSIGNING <ls_demand>[\s\S]*<ls_demand>-order_unit\s*=\s*to_upper\(\s*<ls_demand>-order_unit\s*\)/,
  "allocation service must canonicalize injected order units",
);
assert.match(
  allocationServiceSource,
  /ls_available-unit\s*=\s*to_upper\(\s*ls_available-unit\s*\)/,
  "allocation service must canonicalize injected stock units",
);
assert.match(
  orderSourceSource,
  /ls_demand-sales_document_type\s*=\s*[\s\S]*to_upper\(\s*<ls_schedule>-sales_document_type\s*\)/,
  "order source must canonicalize sales-document types",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-sales_document_type\s*=\s*[\s\S]*to_upper\(\s*<ls_demand>-sales_document_type\s*\)/,
  "allocation service must canonicalize injected sales-document types",
);
assert.match(
  allocationSinkSource,
  /<ls_demand>-sales_document_type\s*=\s*[\s\S]*to_upper\(\s*<ls_demand>-sales_document_type\s*\)/,
  "allocation snapshots must canonicalize sales-document types",
);
assert.match(
  orderSinkSource,
  /lv_sales_document_type\s*=\s*to_upper\(\s*iv_sales_document_type\s*\)/,
  "sales-order writes must canonicalize sales-document types",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-sales_document_type\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_existing>-sales_item\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_existing>-schedule_line\s+IS\s+NOT\s+INITIAL/,
  "allocation service snapshot reconciliation must inspect complete sales-order identity",
);
assert.match(
  allocationSinkSource,
  /is_demand-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*is_demand-sales_document_type\s+IS\s+INITIAL[\s\S]*is_demand-sales_item\s+IS\s+INITIAL[\s\S]*is_demand-schedule_line\s+IS\s+INITIAL/,
  "allocation snapshots must reject incomplete sales-order identity",
);
assert.match(
  allocationSinkSource,
  /is_demand-reservation_id\s+IS\s+NOT\s+INITIAL[\s\S]*is_demand-reservation_id\s+CO\s+'0123456789\s*'[\s\S]*strlen\(\s*is_demand-reservation_id\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "allocation snapshots must reject short numeric reservation documents",
);
assert.match(
  allocationServiceSource,
  /strlen\(\s*<ls_demand>-reservation_id\s*\)[\s\S]*lv_reservation_document\s+CN\s+'0123456789'[\s\S]*lv_reservation_document\s*=\s*'0000000000'[\s\S]*Reservation document is invalid/,
  "allocation service must reject invalid reservation documents from providers",
);
assert.match(
  movementSource,
  /ls_headret-mat_doc\s+CN\s+'0123456789'[\s\S]*ls_headret-mat_doc\s*=\s*'0000000000'/,
  "SAP goods movement must validate a nonzero returned material document",
);
assert.match(
  movementSource,
  /strlen\(\s*ls_headret-mat_doc\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "SAP goods movement must enforce the exact ten-character document length",
);
assert.match(
  movementSource,
  /ls_headret-doc_year\s+CN\s+'0123456789'[\s\S]*ls_headret-doc_year\s*=\s*'0000'/,
  "SAP goods movement must validate a nonzero returned document year",
);
assert.match(
  movementSource,
  /strlen\(\s*ls_headret-doc_year\s*\)\s*<>\s*zif_stock_allocation=>c_fiscal_year_length/,
  "SAP goods movement must enforce the exact four-character fiscal-year length",
);
assert.match(
  stockAllocationInterfaceSource,
  /c_fiscal_year_length\s+TYPE\s+i\s+VALUE\s+4/,
  "the shared fiscal-year contract must define a four-character length",
);
assert.match(
  movementSource,
  /<ls_return>-type\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_return>-type\s+<>\s+'S'[\s\S]*<ls_return>-type\s+<>\s+'I'[\s\S]*<ls_return>-type\s+<>\s+'W'[\s\S]*<ls_return>-type\s+<>\s+'E'[\s\S]*<ls_return>-type\s+<>\s+'A'[\s\S]*<ls_return>-type\s+<>\s+'X'/,
  "SAP goods movement must allow only canonical BAPI return statuses",
);
assert.match(
  orderSinkSource,
  /iv_sales_document\s+CN\s+'0123456789'[\s\S]*iv_sales_document\s*=\s*'0000000000'/,
  "SAP sales-order change must validate a nonzero sales document",
);
assert.match(
  orderSinkSource,
  /strlen\(\s*iv_sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "SAP sales-order change must enforce the exact ten-character document length",
);
assert.match(
  orderSourceSource,
  /strlen\(\s*ls_demand-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "SAP order reads must enforce the exact ten-character document length",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*<ls_demand>-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "allocation service must reject short nonblank sales documents",
);
assert.match(
  allocationSinkSource,
  /is_demand-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*is_demand-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length/,
  "allocation snapshots must reject short nonblank sales documents",
);
assert.match(
  stockAllocationInterfaceSource,
  /ty_sales_document\s+TYPE\s+c\s+LENGTH\s+10[\s\S]*c_sap_document_length\s+TYPE\s+i\s+VALUE\s+10/,
  "the shared SAP document contract must define a ten-character length",
);
assert.match(
  orderSinkSource,
  /<ls_return>-type\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_return>-type\s+<>\s+'S'[\s\S]*<ls_return>-type\s+<>\s+'I'[\s\S]*<ls_return>-type\s+<>\s+'W'[\s\S]*<ls_return>-type\s+<>\s+'E'[\s\S]*<ls_return>-type\s+<>\s+'A'[\s\S]*<ls_return>-type\s+<>\s+'X'/,
  "SAP sales-order change must allow only canonical BAPI return statuses",
);
assert.match(
  allocationServiceSource,
  /strlen\(\s*iv_movement_type\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*iv_movement_type\s+CN\s+'0123456789'/,
  "allocation service must enforce the exact three-character movement-type contract",
);
assert.match(
  reservationSource,
  /strlen\(\s*iv_movement_type\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*iv_movement_type\s+CN\s+'0123456789'/,
  "reservation BAPI adapter must enforce the exact three-character movement-type contract",
);
assert.match(
  movementSource,
  /strlen\(\s*iv_movement_type\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*iv_movement_type\s+CN\s+'0123456789'/,
  "goods-movement BAPI adapter must enforce the exact three-character movement-type contract",
);
assert.match(
  auditSource,
  /strlen\(\s*iv_movement_type\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*iv_movement_type\s+CN\s+'0123456789'/,
  "audit APIs must enforce the exact three-character movement-type contract",
);
assert.match(
  allocationSinkSource,
  /strlen\(\s*iv_movement_type\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*iv_movement_type\s+CN\s+'0123456789'/,
  "allocation result reads must enforce the exact three-character movement-type contract",
);
assert.match(
  stockAllocationInterfaceSource,
  /ty_movement_type\s+TYPE\s+c\s+LENGTH\s+3[\s\S]*c_movement_type_length\s+TYPE\s+i\s+VALUE\s+3/,
  "the shared movement-type contract must define a three-character length",
);
assert.match(
  allocationServiceSource,
  /mo_transaction->rollback\(\s*\)/,
  "allocation service must rollback failed persistence before finalization",
);
assert.match(
  allocationServiceSource,
  /IF io_reservation IS BOUND[\s\S]*CREATE OBJECT mo_reservation TYPE zcl_stock_reservation_sap/,
  "allocation service must default the reservation port to the SAP adapter",
);
assert.match(
  allocationServiceSource,
  /IF io_sink IS BOUND[\s\S]*CREATE OBJECT mo_sink TYPE zcl_allocation_sink_sap/,
  "allocation service must default the sink port to the SAP adapter",
);
assert.match(
  allocationServiceSource,
  /IF io_unit_converter IS BOUND[\s\S]*CREATE OBJECT mo_unit_converter TYPE zcl_unit_conversion_sap/,
  "allocation service must default the unit-conversion port to the SAP adapter",
);
assert.match(
  allocationServiceSource,
  /iv_safety_stock\s+TYPE zif_stock_allocation=>ty_quantity OPTIONAL/,
  "allocation service must expose an optional safety-stock input",
);
assert.match(
  allocationServiceSource,
  /lv_available = lv_available - iv_safety_stock/,
  "allocation service must protect the configured safety-stock floor",
);
assert.match(
  auditSource,
  /ls_run-safety_stock = iv_safety_stock/,
  "audit persistence must retain the safety-stock policy",
);
assert.match(
  auditSource,
  /weighted_runs|weighted_requested|weighted_coverage/,
  "audit summaries must expose weighted strategy analytics",
);
assert.match(
  allocationReportSource,
  /weighted_runs|weighted_requested|weighted_coverage/,
  "allocation summaries must expose weighted strategy analytics",
);
assert.match(
  healthReportSource,
  /weighted_runs|weighted_requested|weighted_coverage/,
  "health output must expose weighted strategy analytics",
);
assert.match(
  readmeSource,
  /Current strategy contract:.*`P`.*`F`.*`N`.*`S`.*`L`.*`B`.*`E`.*`A`.*`W`/s,
  "README must document the complete current strategy contract",
);
assert.match(
  healthReportSource,
  /iv_stale_scope_evaluated\s*=\s*xsdbool\(\s*p_stale\s*>\s*0\s*\)/,
  "health report must identify when its stale-run scope was evaluated",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_legacy AS CHECKBOX\./,
  "health must expose an explicit legacy-strategy filter",
);
assert.match(
  healthReportSource,
  /iv_legacy_strategy\s+= p_legacy/,
  "health must propagate the legacy-strategy filter to audit reads",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status\./,
  "health must expose an audit status filter",
);
assert.match(
  healthReportSource,
  /iv_status\s+= p_stat/,
  "health must propagate the audit status filter to audit reads",
);
assert.match(
  healthReportSource,
  /status_filter/,
  "health machine-readable output must expose audit status provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message\./,
  "health must expose a diagnostic message filter",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_monly AS CHECKBOX\./,
  "health must expose a message-only filter",
);
assert.match(
  healthReportSource,
  /iv_message_contains\s+= p_msg/,
  "health must propagate the diagnostic message filter to audit reads",
);
assert.match(
  healthReportSource,
  /iv_message_only\s+= p_monly/,
  "health must propagate the message-only filter to audit reads",
);
assert.match(
  healthReportSource,
  /message_filter|message_only/,
  "health machine-readable output must expose message provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_dfrom TYPE i\./,
  "health must expose a minimum demand-count bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_dto TYPE i\./,
  "health must expose a maximum demand-count bound",
);
assert.match(
  healthReportSource,
  /iv_demand_from\s+= p_dfrom/,
  "health must propagate the minimum demand-count bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_demand_to\s+= p_dto/,
  "health must propagate the maximum demand-count bound to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_demand_count|maximum_demand_count/,
  "health machine-readable output must expose demand-count provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_avf TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a minimum available-stock bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_avt TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a maximum available-stock bound",
);
assert.match(
  healthReportSource,
  /iv_available_from\s+= p_avf/,
  "health must propagate the minimum available-stock bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_available_to\s+= p_avt/,
  "health must propagate the maximum available-stock bound to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_available_stock|maximum_available_stock/,
  "health machine-readable output must expose available-stock provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_qf TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a minimum requested-quantity bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_qt TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a maximum requested-quantity bound",
);
assert.match(
  healthReportSource,
  /iv_requested_from\s+= p_qf/,
  "health must propagate the minimum requested-quantity bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_requested_to\s+= p_qt/,
  "health must propagate the maximum requested-quantity bound to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_requested_quantity|maximum_requested_quantity/,
  "health machine-readable output must expose requested-quantity provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_af TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a minimum allocated-quantity bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_at TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a maximum allocated-quantity bound",
);
assert.match(
  healthReportSource,
  /iv_allocated_from\s+= p_af/,
  "health must propagate the minimum allocated-quantity bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_allocated_to\s+= p_at/,
  "health must propagate the maximum allocated-quantity bound to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_allocated_quantity|maximum_allocated_quantity/,
  "health machine-readable output must expose allocated-quantity provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a minimum shortage-quantity bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_sht TYPE zif_stock_allocation=>ty_quantity\./,
  "health must expose a maximum shortage-quantity bound",
);
assert.match(
  healthReportSource,
  /iv_shortage_from\s+= p_shf/,
  "health must propagate the minimum shortage-quantity bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_shortage_to\s+= p_sht/,
  "health must propagate the maximum shortage-quantity bound to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_shortage_quantity|maximum_shortage_quantity/,
  "health machine-readable output must expose shortage-quantity provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_spf TYPE zif_allocation_audit=>ty_coverage\./,
  "health must expose a minimum shortage-percentage bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_spt TYPE zif_allocation_audit=>ty_coverage\./,
  "health must expose a maximum shortage-percentage bound",
);
assert.match(
  healthReportSource,
  /iv_shortage_pct_from\s+= p_spf/,
  "health must propagate the minimum shortage-percentage bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_shortage_pct_to\s+= p_spt/,
  "health must propagate the maximum shortage-percentage bound to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_shortage_pct|maximum_shortage_pct/,
  "health machine-readable output must expose shortage-percentage provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_covf TYPE zif_allocation_audit=>ty_coverage\./,
  "health must expose a minimum coverage-percentage bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage\./,
  "health must expose a maximum coverage-percentage bound",
);
assert.match(
  healthReportSource,
  /iv_coverage_from\s+= p_covf/,
  "health must propagate the minimum coverage-percentage bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_coverage_to\s+= p_covt/,
  "health must propagate the maximum coverage-percentage bound to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_coverage_pct|maximum_coverage_pct/,
  "health machine-readable output must expose coverage-percentage provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_tfrom TYPE i\./,
  "health must expose a minimum audit-duration bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_tto TYPE i\./,
  "health must expose a maximum audit-duration bound",
);
assert.match(
  healthReportSource,
  /iv_duration_from\s+= p_tfrom/,
  "health must propagate the minimum audit-duration bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_duration_to\s+= p_tto/,
  "health must propagate the maximum audit-duration bound to audit reads",
);
assert.match(
  healthReportSource,
  /audit_duration_from_filter|audit_duration_to_filter/,
  "health machine-readable output must expose audit-duration provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_from TYPE d\./,
  "health must expose an audit start-date lower bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_to TYPE d\./,
  "health must expose an audit start-date upper bound",
);
assert.match(
  healthReportSource,
  /iv_start_date_from\s+= p_from/,
  "health must propagate the audit start-date lower bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_start_date_to\s+= p_to/,
  "health must propagate the audit start-date upper bound to audit reads",
);
assert.match(
  healthReportSource,
  /start_date_from_filter|start_date_to_filter/,
  "health machine-readable output must expose audit start-date provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_ffrom TYPE d\./,
  "health must expose an audit finish-date lower bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_fto TYPE d\./,
  "health must expose an audit finish-date upper bound",
);
assert.match(
  healthReportSource,
  /iv_finish_date_from\s+= p_ffrom/,
  "health must propagate the audit finish-date lower bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_finish_date_to\s+= p_fto/,
  "health must propagate the audit finish-date upper bound to audit reads",
);
assert.match(
  healthReportSource,
  /finish_date_from_filter|finish_date_to_filter/,
  "health machine-readable output must expose audit finish-date provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_age_to TYPE i\./,
  "health must expose a maximum running-age bound",
);
assert.match(
  healthReportSource,
  /iv_running_age_to\s+= p_age_to/,
  "health must propagate the maximum running-age bound to audit reads",
);
assert.match(
  healthReportSource,
  /maximum_running_age_filter/,
  "health machine-readable output must expose running-age provenance",
);
assert.match(
  healthReportSource,
  /legacy_strategy_filter/,
  "health machine-readable output must expose legacy-strategy provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_ovrd AS CHECKBOX\./,
  "health must expose overdue requested-horizon filtering",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_odate TYPE d\./,
  "health must expose an overdue as-of date",
);
assert.match(
  healthReportSource,
  /iv_requested_overdue\s+= p_ovrd/,
  "health must propagate overdue filtering to audit reads",
);
assert.match(
  healthReportSource,
  /iv_overdue_date\s+= lv_overdue_date/,
  "health must propagate the overdue as-of date to audit reads",
);
assert.match(
  healthReportSource,
  /overdue_only|requested_overdue_as_of/,
  "health machine-readable output must expose overdue provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_dead AS CHECKBOX\./,
  "health must expose requested-deadline filtering",
);
assert.match(
  healthReportSource,
  /iv_deadline_only\s+= p_dead/,
  "health must propagate requested-deadline filtering to audit reads",
);
assert.match(
  healthReportSource,
  /requested_deadline_only/,
  "health machine-readable output must expose requested-deadline provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_deadf TYPE d\./,
  "health must expose a requested-deadline lower bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_deadt TYPE d\./,
  "health must expose a requested-deadline upper bound",
);
assert.match(
  healthReportSource,
  /iv_deadline_from\s+= p_deadf/,
  "health must propagate the requested-deadline lower bound to audit reads",
);
assert.match(
  healthReportSource,
  /iv_deadline_to\s+= p_deadt/,
  "health must propagate the requested-deadline upper bound to audit reads",
);
assert.match(
  healthReportSource,
  /requested_deadline_from|requested_deadline_to/,
  "health machine-readable output must expose requested-deadline range provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_dagef TYPE i\./,
  "health must expose a minimum deadline-age bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_daget TYPE i\./,
  "health must expose a maximum deadline-age bound",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_daged TYPE d\./,
  "health must expose a deadline-age as-of date",
);
assert.match(
  healthReportSource,
  /iv_deadline_age_from\s+= p_dagef/,
  "health must propagate the minimum deadline age to audit reads",
);
assert.match(
  healthReportSource,
  /iv_deadline_age_to\s+= p_daget/,
  "health must propagate the maximum deadline age to audit reads",
);
assert.match(
  healthReportSource,
  /iv_deadline_age_date\s+= lv_deadline_age_date/,
  "health must propagate the deadline-age as-of date to audit reads",
);
assert.match(
  healthReportSource,
  /minimum_deadline_age_days|maximum_deadline_age_days|deadline_age_as_of/,
  "health machine-readable output must expose deadline-age provenance",
);
assert.match(
  healthReportSource,
  /deadline_count|earliest_requested_deadline|deadline_age_reference_date/,
  "health machine-readable output must expose selected deadline telemetry",
);
assert.match(
  healthSource,
  /rs_health-deadline_count\s*=\s*is_summary-deadline_count/,
  "health evaluator must propagate deadline counts",
);
assert.match(
  healthSource,
  /rs_health-deadline_age_reference_date\s*=\s*is_summary-deadline_age_reference_date/,
  "health evaluator must propagate deadline-age provenance",
);
assert.match(
  healthReportSource,
  /iv_value = 28 \) TO lt_json_fields/,
  "health JSON schema must include the running-age contract version",
);
const historySource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_history.prog.abap"),
  "utf8",
);
const watchSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_watch.prog.abap"),
  "utf8",
);
const resultSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_result.prog.abap"),
  "utf8",
);
const compareReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_compare.prog.abap"),
  "utf8",
);
const compareClassSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_allocation_compare.clas.abap"),
  "utf8",
);
assert.match(
  historySource,
  /Safety stock context:/,
  "history human summary must expose safety-stock context",
);
assert.match(
  historySource,
  /<ls_run>-safety_stock/,
  "history human detail must expose persisted safety stock",
);
assert.match(
  historySource,
  /safety_stock_context/,
  "history machine-readable summaries must expose safety-stock context",
);
assert.match(
  historySource,
  /PARAMETERS p_safon AS CHECKBOX\./,
  "history must expose an explicit safety-stock filter switch",
);
assert.match(
  historySource,
  /PARAMETERS p_saf TYPE zif_stock_allocation=>ty_quantity\./,
  "history must expose a minimum safety-stock filter bound",
);
assert.match(
  historySource,
  /PARAMETERS p_safto TYPE zif_stock_allocation=>ty_quantity\./,
  "history must expose a maximum safety-stock filter bound",
);
assert.match(
  historySource,
  /iv_safety_filter\s+= p_safon/,
  "history must propagate the safety-stock filter switch to audit reads",
);
assert.match(
  historySource,
  /minimum_safety_stock_filter/,
  "history machine-readable filters must expose the minimum safety-stock bound",
);
assert.match(
  historySource,
  /maximum_safety_stock_filter/,
  "history machine-readable filters must expose the maximum safety-stock bound",
);
assert.match(
  historySource,
  /APPEND zcl_stock_csv=>number\( <ls_run>-safety_stock \)/,
  "history machine-readable detail must expose persisted safety stock",
);
assert.match(
  historySource,
  /iv_value = 43 \) TO lt_json_fields/,
  "history summary JSON schema must include the safety-stock contract version",
);
assert.match(
  historySource,
  /iv_value = 26 \) TO lt_json_fields/,
  "history detail JSON schema must include the safety-stock contract version",
);
assert.match(
  watchSource,
  /safety_stock\s*=\s*<ls_run>-safety_stock/,
  "watch alerts must retain persisted safety stock",
);
assert.match(
  watchSource,
  /safety_stock_context/,
  "watch summaries must expose safety-stock context",
);
assert.match(
  watchSource,
  /PARAMETERS p_safon AS CHECKBOX\./,
  "watch must expose an explicit safety-stock filter switch",
);
assert.match(
  watchSource,
  /iv_safety_filter\s+= p_safon/,
  "watch must propagate the safety-stock filter switch to audit reads",
);
assert.match(
  watchSource,
  /minimum_safety_stock_filter/,
  "watch machine-readable filters must expose the minimum safety-stock bound",
);
assert.match(
  watchSource,
  /maximum_safety_stock_filter/,
  "watch machine-readable filters must expose the maximum safety-stock bound",
);
assert.match(
  watchSource,
  /adaptive_branch/,
  "watch alerts must expose adaptive branch provenance",
);
assert.match(
  watchSource,
  /adaptive_priority_runs/,
  "watch summaries must expose adaptive priority branch counts",
);
assert.match(
  watchSource,
  /adaptive_fair_runs/,
  "watch summaries must expose adaptive fair-share branch counts",
);
assert.match(
  watchSource,
  /weighted_strategy_runs/,
  "watch summaries must expose weighted strategy run counts",
);
assert.match(
  watchSource,
  /weighted_requested|weighted_allocated|weighted_coverage_pct/,
  "watch summaries must expose weighted quantity analytics",
);
assert.match(
  watchSource,
  /weighted_strategy/,
  "watch alerts must expose weighted strategy provenance",
);
assert.match(
  watchSource,
  /number\( 56 \)/,
  "watch CSV schema must include the safety-stock contract version",
);
assert.match(
  watchSource,
  /iv_value = 59 \)/,
  "watch JSON schema must include the safety-stock contract version",
);
assert.match(
  resultSource,
  /'Safety stock:', <ls_run>-safety_stock/,
  "result exact-run human context must expose persisted safety stock",
);
assert.match(
  resultSource,
  /audit_safety_stock/,
  "result machine-readable output must expose persisted safety stock",
);
assert.match(
  resultSource,
  /PARAMETERS p_safon AS CHECKBOX\./,
  "result must expose an explicit safety-stock filter switch",
);
assert.match(
  resultSource,
  /iv_safety_filter\s+= p_safon/,
  "result must propagate the safety-stock filter to audit and sink reads",
);
assert.match(
  resultSource,
  /minimum_safety_stock/,
  "result machine-readable filters must expose the minimum safety-stock bound",
);
assert.match(
  resultSource,
  /maximum_safety_stock/,
  "result machine-readable filters must expose the maximum safety-stock bound",
);
assert.match(
  resultSource,
  /APPEND zcl_stock_csv=>number\( 43 \)/,
  "result summary CSV schema must include the safety-stock contract version",
);
assert.match(
  resultSource,
  /APPEND zcl_stock_csv=>number\( 37 \)/,
  "result detail CSV schema must include the safety-stock contract version",
);
assert.match(
  compareClassSource,
  /iv_old_run-safety_stock\s*<>\s*iv_new_run-safety_stock[\s\S]*iv_reason = 'safety_stock'/,
  "comparison metadata must detect safety-stock policy changes",
);
for (const compareField of ["old_safety_stock", "new_safety_stock"]) {
  assert.match(
    compareReportSource,
    new RegExp(compareField),
    `comparison report must expose ${compareField}`,
  );
}
assert.match(
  compareReportSource,
  /p_rmov\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*p_rmov\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*p_ormov\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*p_ormov\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*p_nrmov\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*p_nrmov\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length/,
  "comparison report reservation movement filters must enforce the shared length contract",
);
assert.match(
  auditSource,
  /rollback_and_raise\(/,
  "audit purge must have a rollback path for persistence failures",
);
assert.match(
  auditSource,
  /SELECT SINGLE run_id[\s\S]*lv_remaining_run_id[\s\S]*IF sy-subrc = 0/,
  "audit purge must verify each run deletion",
);
assert.match(
  unitConversionSource,
  /io_authority\s+TYPE REF TO zif_unit_conversion_authority/,
  "unit conversion must expose an injectable read-authority port",
);
assert.match(
  unitConversionSource,
  /mo_authority->check\(\s*\)/,
  "unit conversion must check authority before calling SAP conversion",
);
assert.match(
  unitConversionAuthoritySource,
  /iv_table\s*=\s*'MARA'[\s\S]*iv_table\s*=\s*'MARM'/,
  "unit conversion authority must cover material and unit tables",
);

for (const scriptName of ["lint", "transpile", "test"]) {
  assert.equal(typeof packageJson.scripts[scriptName], "string", `missing npm script: ${scriptName}`);
}
assert.match(
  packageJson.scripts.test,
  /repository-contract\.mjs/,
  "default test pipeline must run the repository contract",
);

const setupSource = fs.readFileSync(path.join(repositoryDirectory, "test", "setup.mjs"), "utf8");
assert.match(
  setupSource,
  /\.\.\/sap_stubs\/bapi_reservation_create\.mjs/,
  "test setup must load the SAP API stub module",
);
assert.match(
  setupSource,
  /installBapiStockStub\(abap\)/,
  "test setup must install the SAP API stub module",
);

console.log("repository-contract: SAP stubs, open-abap-core, lint rules, and test wiring are present");
