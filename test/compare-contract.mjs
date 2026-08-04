import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const testDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryDirectory = path.resolve(testDirectory, "..");
const sourceDirectory = path.join(repositoryDirectory, "src");
const source = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_compare.prog.abap"),
  "utf8",
);
const xml = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_compare.prog.xml"),
  "utf8",
);
const readme = fs.readFileSync(path.join(repositoryDirectory, "README.md"), "utf8");

const parameters = [...source.matchAll(/^PARAMETERS\s+([A-Z0-9_]+)/gim)].map(
  (match) => match[1].toUpperCase(),
);
const xmlKeys = [...xml.matchAll(/<KEY>\s*([A-Z0-9_]+)\s*<\/KEY>/gim)].map(
  (match) => match[1].toUpperCase(),
);

function extractParameters(reportSource) {
  return [...reportSource.matchAll(/^PARAMETERS\s+([A-Z0-9_]+)/gim)].map(
    (match) => match[1].toUpperCase(),
  );
}

function extractXmlKeys(reportXml) {
  return [...reportXml.matchAll(/<KEY>\s*([A-Z0-9_]+)\s*<\/KEY>/gim)].map(
    (match) => match[1].toUpperCase(),
  );
}

function extractSelectionTexts(reportXml) {
  return new Map(
    [...reportXml.matchAll(
      /<ID>\s*S\s*<\/ID>\s*<KEY>\s*([A-Z0-9_]+)\s*<\/KEY>\s*<ENTRY>\s*([^<]+?)\s*<\/ENTRY>/gim,
    )].map((match) => [match[1].toUpperCase(), match[2].trim()]),
  );
}

function extractProgramName(reportXml) {
  return /<PROGDIR>[\s\S]*?<NAME>\s*([A-Z0-9_]+)\s*<\/NAME>/i.exec(reportXml)?.[1]?.toUpperCase();
}

const reportContractCounts = [];
for (const fileName of fs.readdirSync(sourceDirectory).filter((name) => name.endsWith(".prog.abap"))) {
  const xmlPath = path.join(sourceDirectory, fileName.replace(/\.abap$/i, ".xml"));
  assert.ok(fs.existsSync(xmlPath), `${fileName} must have matching XML metadata`);
  const reportSource = fs.readFileSync(path.join(sourceDirectory, fileName), "utf8");
  const reportXml = fs.readFileSync(xmlPath, "utf8");
  const reportParameters = extractParameters(reportSource);
  const reportKeys = extractXmlKeys(reportXml);
  const selectionTexts = extractSelectionTexts(reportXml);
  const expectedProgramName = fileName.replace(/\.prog\.abap$/i, "").toUpperCase();
  assert.equal(
    extractProgramName(reportXml),
    expectedProgramName,
    `${fileName} XML program identity must match the ABAP report name`,
  );
  assert.equal(
    new Set(reportParameters).size,
    reportParameters.length,
    `${fileName} contains duplicate selection-screen parameters`,
  );
  assert.equal(
    new Set(reportKeys).size,
    reportKeys.length,
    `${fileName} XML contains duplicate parameter keys`,
  );
  assert.deepEqual(
    reportParameters,
    reportKeys,
    `${fileName} parameters and XML keys must match in declaration order`,
  );
  for (const parameter of reportParameters) {
    assert.ok(
      selectionTexts.has(parameter) && selectionTexts.get(parameter).length > 0,
      `${fileName} must provide nonempty SAP selection text for ${parameter}`,
    );
  }
  reportContractCounts.push(`${fileName.replace(/\.prog\.abap$/i, "")}:${reportParameters.length}`);
}

assert.ok(parameters.length > 0, "compare report must declare parameters");
assert.equal(
  new Set(parameters).size,
  parameters.length,
  "compare report contains duplicate selection-screen parameters",
);
assert.equal(
  new Set(xmlKeys).size,
  xmlKeys.length,
  "compare report XML contains duplicate parameter keys",
);
assert.deepEqual(
  parameters,
  xmlKeys,
  "compare report parameters and XML keys must match in declaration order",
);

const documentedSchema = /^The current comparison CSV and contextual JSON schemas are `(\d+)`/m.exec(
  readme,
);
assert.ok(documentedSchema, "README must document the current comparison schema");
const schema = Number(documentedSchema[1]);
const schemaMarker = new RegExp(
  `APPEND zcl_stock_csv=>number\\(\\s*${schema}\\s*\\)|iv_value\\s*=\\s*${schema}\\s*\\)`,
  "g",
);
const previousSchemaMarker = new RegExp(
  `APPEND zcl_stock_csv=>number\\(\\s*${schema - 1}\\s*\\)|iv_value\\s*=\\s*${schema - 1}\\s*\\)`,
  "g",
);
assert.equal(
  (source.match(schemaMarker) ?? []).length,
  4,
  `comparison schema ${schema} must be present in all four CSV/JSON markers`,
);
assert.equal(
  (source.match(previousSchemaMarker) ?? []).length,
  0,
  `comparison schema ${schema - 1} markers must be retired`,
);

for (const requiredParameter of [
  "P_OMATNR",
  "P_NMATNR",
  "P_OWERKS",
  "P_NWERKS",
  "P_OLGORT",
  "P_NLGORT",
  "P_OBATCH",
  "P_NBATCH",
  "P_TFROM",
  "P_TTO",
  "P_OTFROM",
  "P_OTTO",
  "P_NTFROM",
  "P_NTTO",
  "P_AVF",
  "P_AVT",
  "P_OAVF",
  "P_OAVT",
  "P_NAVF",
  "P_NAVT",
  "P_RAGETO",
  "P_ORAGTO",
  "P_NRAGTO",
]) {
  assert.ok(parameters.includes(requiredParameter), `missing ${requiredParameter}`);
}
for (const durationBinding of [
  /iv_run_duration_from\s*=\s*lv_old_duration_from/,
  /iv_run_duration_to\s*=\s*lv_old_duration_to/,
  /iv_run_duration_from\s*=\s*lv_new_duration_from/,
  /iv_run_duration_to\s*=\s*lv_new_duration_to/,
  /iv_duration_from\s*=\s*lv_old_duration_from/,
  /iv_duration_to\s*=\s*lv_old_duration_to/,
  /iv_duration_from\s*=\s*lv_new_duration_from/,
  /iv_duration_to\s*=\s*lv_new_duration_to/,
]) {
  assert.match(source, durationBinding, `missing duration propagation: ${durationBinding}`);
}
for (const durationContractText of [
  "Audit-duration bounds must not be negative",
  "The audit-duration start must not be after the end value",
  "The old audit-duration start must not be after the end value",
  "The new audit-duration start must not be after the end value",
  "Common and side-specific audit-duration ranges cannot be combined",
  "audit_duration_range",
  "old_audit_duration_range",
  "new_audit_duration_range",
]) {
  assert.match(source, new RegExp(durationContractText.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
}
for (const availableBinding of [
  /iv_run_available_from\s*=\s*lv_old_available_from/,
  /iv_run_available_to\s*=\s*lv_old_available_to/,
  /iv_run_available_from\s*=\s*lv_new_available_from/,
  /iv_run_available_to\s*=\s*lv_new_available_to/,
  /iv_available_from\s*=\s*lv_old_available_from/,
  /iv_available_to\s*=\s*lv_old_available_to/,
  /iv_available_from\s*=\s*lv_new_available_from/,
  /iv_available_to\s*=\s*lv_new_available_to/,
]) {
  assert.match(source, availableBinding, `missing available-stock propagation: ${availableBinding}`);
}
for (const availableContractText of [
  "Available-stock bounds must not be negative",
  "The common available-stock start must not be after the end",
  "The old available-stock start must not be after the end",
  "The new available-stock start must not be after the end",
  "Common and side-specific available-stock ranges cannot be combined",
  "available_stock_range",
  "old_available_stock_range",
  "new_available_stock_range",
]) {
  assert.match(source, new RegExp(availableContractText.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
}
for (const availableProvenanceField of [
  "minimum_available_stock",
  "maximum_available_stock",
  "old_minimum_available_stock",
  "old_maximum_available_stock",
  "new_minimum_available_stock",
  "new_maximum_available_stock",
  "available_stock_from_filter",
  "available_stock_to_filter",
  "old_available_stock_from_filter",
  "old_available_stock_to_filter",
  "new_available_stock_from_filter",
  "new_available_stock_to_filter",
]) {
  assert.match(
    source,
    new RegExp(availableProvenanceField),
    `missing available-stock provenance field: ${availableProvenanceField}`,
  );
}
for (const ageBinding of [
  /iv_reservation_age_from\s*=\s*lv_old_rage/,
  /iv_reservation_age_to\s*=\s*lv_old_rageto/,
  /iv_reservation_age_from\s*=\s*lv_new_rage/,
  /iv_reservation_age_to\s*=\s*lv_new_rageto/,
]) {
  assert.match(source, ageBinding, `missing reservation-age propagation: ${ageBinding}`);
}
for (const ageContractText of [
  "Reservation age filters must not be negative",
  "Side-specific reservation age filters must not be negative",
  "The common reservation age start must not be after the end value",
  "The old reservation age start must not be after the end value",
  "The new reservation age start must not be after the end value",
  "Common and side-specific reservation age filters cannot be combined",
]) {
  assert.match(source, new RegExp(ageContractText.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
}
for (const ageProvenanceField of [
  "maximum_reservation_age",
  "old_maximum_reservation_age",
  "new_maximum_reservation_age",
  "maximum_reservation_age_filter",
  "old_maximum_reservation_age_filter",
  "new_maximum_reservation_age_filter",
]) {
  assert.match(
    source,
    new RegExp(ageProvenanceField),
    `missing maximum reservation-age provenance field: ${ageProvenanceField}`,
  );
}

const resultSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_result.prog.abap"),
  "utf8",
);
const purgeSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_purge.prog.abap"),
  "utf8",
);
const auditInterfaceSource = fs.readFileSync(
  path.join(sourceDirectory, "zif_allocation_audit.intf.abap"),
  "utf8",
);
const auditSapSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_allocation_audit_sap.clas.abap"),
  "utf8",
);
const purgeParameters = extractParameters(purgeSource);
for (const requiredParameter of ["P_TFROM", "P_TTO"]) {
  assert.ok(purgeParameters.includes(requiredParameter), `purge report missing ${requiredParameter}`);
}
assert.match(purgeSource, /iv_duration_from\s*=\s*p_tfrom/);
assert.match(purgeSource, /iv_duration_to\s*=\s*p_tto/);
for (const purgeContractText of [
  "Duration bounds must not be negative",
  "The duration start must not be after the end value",
  "audit_duration_range",
  "audit_duration_from_filter",
  "audit_duration_to_filter",
]) {
  assert.match(
    purgeSource,
    new RegExp(purgeContractText.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")),
  );
}
assert.equal(
  (purgeSource.match(/APPEND zcl_stock_csv=>number\( 20 \)/g) ?? []).length,
  1,
  "purge preview CSV schema must be 20",
);
assert.equal(
  (purgeSource.match(/APPEND zcl_stock_csv=>number\( 21 \)/g) ?? []).length,
  1,
  "purge execution CSV schema must be 21",
);
assert.equal(
  (purgeSource.match(/iv_value = 22 \) TO lt_json_fields/g) ?? []).length,
  1,
  "purge preview JSON schema must be 22",
);
assert.equal(
  (purgeSource.match(/iv_value = 23 \) TO lt_json_fields/g) ?? []).length,
  1,
  "purge execution JSON schema must be 23",
);
assert.match(
  readme,
  /Purge JSON schemas are now typed preview `22` and execute `23`/,
  "README must document current purge JSON schemas",
);
assert.match(
  readme,
  /numeric `schema_version` `20` for preview or `21` for execution/,
  "README must document current purge CSV schemas",
);
for (const reservationContractText of [
  "reserved_count",
  "ev_reserved_runs",
  "protected_reservation_runs",
  "reservation_id",
]) {
  assert.match(
    purgeSource + auditInterfaceSource + auditSapSource,
    new RegExp(reservationContractText.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")),
    `purge reservation contract missing ${reservationContractText}`,
  );
}
const resultParameters = extractParameters(resultSource);
for (const requiredParameter of [
  "P_DFROM",
  "P_DTO",
  "P_AVF",
  "P_AVT",
  "P_TFROM",
  "P_TTO",
  "P_RAGETO",
]) {
  assert.ok(resultParameters.includes(requiredParameter), `result report missing ${requiredParameter}`);
}
assert.match(resultSource, /iv_run_demand_from\s*=\s*p_dfrom/);
assert.match(resultSource, /iv_run_demand_to\s*=\s*p_dto/);
assert.match(resultSource, /iv_run_available_from\s*=\s*p_avf/);
assert.match(resultSource, /iv_run_available_to\s*=\s*p_avt/);
assert.match(resultSource, /iv_run_duration_from\s*=\s*p_tfrom/);
assert.match(resultSource, /iv_run_duration_to\s*=\s*p_tto/);
assert.match(resultSource, /iv_reservation_age_to\s*=\s*p_rageto/);
assert.match(resultSource, /maximum_reservation_age_days/);
assert.match(
  resultSource,
  /Reservation age start must not be after the end value/,
  "result report must reject reversed reservation-age bounds",
);
assert.equal(
  (resultSource.match(/APPEND zcl_stock_csv=>number\( 39 \)/g) ?? []).length,
  1,
  "result summary CSV schema must be 39",
);
assert.equal(
  (resultSource.match(/APPEND zcl_stock_csv=>number\( 37 \)/g) ?? []).length,
  1,
  "result detail CSV schema must be 37",
);
assert.equal(
  (resultSource.match(/iv_value = 39 \) TO lt_json_fields/g) ?? []).length,
  2,
  "result summary JSON schemas must be 39",
);
assert.equal(
  (resultSource.match(/iv_value = 37 \) TO lt_json_fields/g) ?? []).length,
  2,
  "result detail JSON schemas must be 37",
);

assert.doesNotMatch(
  source,
  /^PARAMETERS\s+P_WERKS\b[^.]*\bOBLIGATORY\b/im,
  "common plant must remain optional so an old/new plant pair can be supplied",
);
for (const pairValidationMessage of [
  "Plant requires a common value or both old and new values",
  "Material requires a common value or both old and new values",
  "Storage location requires a common value or both old and new values",
  "Batch requires a common value or both old and new values",
]) {
  assert.match(
    source,
    new RegExp(pairValidationMessage),
    `missing complete-pair validation: ${pairValidationMessage}`,
  );
}

console.log(
  `report-contract: ${reportContractCounts.length} reports (${reportContractCounts.join(", ")})`,
);
console.log(`compare-contract: ${parameters.length} parameters/XML keys, schema ${schema}`);
