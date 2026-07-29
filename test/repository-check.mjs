import { readFileSync, readdirSync } from "node:fs";
import { join, relative } from "node:path";

const root = process.cwd();
const lint = JSON.parse(readFileSync(join(root, "abaplint.json"), "utf8"));
const transpile = JSON.parse(
  readFileSync(join(root, "abap_transpile.json"), "utf8"),
);
const abapgit = readFileSync(join(root, ".abapgit.xml"), "utf8");
const allocationTable = readFileSync(
  join(root, "src", "zstockalloc.tabl.xml"),
  "utf8",
);
const allocationHeaderTable = readFileSync(
  join(root, "src", "zstockplan.tabl.xml"),
  "utf8",
);
const allocationHeaderHistory = readFileSync(
  join(root, "src", "zstockphist.tabl.xml"),
  "utf8",
);
const allocationDetailHistory = readFileSync(
  join(root, "src", "zstockahist.tabl.xml"),
  "utf8",
);
const priorityTable = readFileSync(
  join(root, "src", "zstockprio.tabl.xml"),
  "utf8",
);
const runAuthorization = readFileSync(
  join(root, "src", "zstk_run.suso.xml"),
  "utf8",
);
const priorityAuthorization = readFileSync(
  join(root, "src", "zstk_pri.suso.xml"),
  "utf8",
);
const applicationLog = JSON.parse(
  readFileSync(join(root, "src", "zstockalloc.aplo.json"), "utf8"),
);
const allocationDomain = readFileSync(
  join(root, "src", "zif_stock_allocation.intf.abap"),
  "utf8",
);
const allocationReport = readFileSync(
  join(root, "src", "zstock_allocate.prog.abap"),
  "utf8",
);
const allocationService = readFileSync(
  join(root, "src", "zcl_stock_allocation_service.clas.abap"),
  "utf8",
);
const allocationViewReport = readFileSync(
  join(root, "src", "zstock_plan_view.prog.abap"),
  "utf8",
);

function requireInvariant(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

const requiredRules = [
  "modify_only_own_db_tables",
  "align_type_expressions",
  "easy_to_find_messages",
  "max_one_method_parameter_per_line",
];
for (const rule of requiredRules) {
  requireInvariant(lint.rules?.[rule] === true, `Required abaplint rule disabled: ${rule}`);
}

const coreUrl = "https://github.com/open-abap/open-abap-core";
requireInvariant(
  lint.dependencies?.some((dependency) => dependency.url === coreUrl),
  "abaplint configuration is missing open-abap-core",
);
requireInvariant(
  transpile.libs?.some((dependency) => dependency.url === coreUrl),
  "transpiler configuration is missing open-abap-core",
);
requireInvariant(
  lint.global?.files?.includes("sap_stubs"),
  "abaplint configuration does not include sap_stubs",
);
requireInvariant(
  transpile.input_folder?.includes("sap_stubs"),
  "transpiler configuration does not include sap_stubs",
);
requireInvariant(
  /<STARTING_FOLDER>\/src\/<\/STARTING_FOLDER>/.test(abapgit),
  "abapGit starting folder must remain /src/ so SAP stubs are never imported",
);

for (const [name, definition] of [
  ["ZSTOCKALLOC", allocationTable],
  ["ZSTOCKPLAN", allocationHeaderTable],
  ["ZSTOCKPHIST", allocationHeaderHistory],
  ["ZSTOCKAHIST", allocationDetailHistory],
  ["ZSTOCKPRIO", priorityTable],
]) {
  requireInvariant(
    definition.includes("<CONTFLAG>A</CONTFLAG>"),
    `${name} must remain application data`,
  );
  requireInvariant(
    definition.includes("<BUFALLOW>N</BUFALLOW>"),
    `${name} must remain unbuffered`,
  );
}

requireInvariant(
  allocationHeaderTable.includes("<FIELDNAME>DEMAND_COUNT</FIELDNAME>"),
  "ZSTOCKPLAN must persist empty and populated snapshot cardinality",
);
for (const [name, definition] of [
  ["ZSTOCKPHIST", allocationHeaderHistory],
  ["ZSTOCKAHIST", allocationDetailHistory],
]) {
  requireInvariant(
    definition.includes("<FIELDNAME>VERSION_NO</FIELDNAME><KEYFLAG>X</KEYFLAG>"),
    `${name} must key immutable history by plan version`,
  );
}
for (const field of [
  "VERSION_NO",
  "STOCK_QTY",
  "AVAILABLE_QTY",
  "RESERVE_QTY",
  "MEINS",
  "STRATEGY",
  "START_DATE",
  "CUTOFF_DATE",
  "CREATED_ON",
  "CREATED_AT",
  "CREATED_BY",
]) {
  requireInvariant(
    allocationHeaderTable.includes(`<FIELDNAME>${field}</FIELDNAME>`),
    `ZSTOCKPLAN is missing plan context field ${field}`,
  );
}
requireInvariant(
  allocationTable.includes("<FIELDNAME>STRATEGY</FIELDNAME>"),
  "ZSTOCKALLOC must persist the effective allocation strategy",
);
requireInvariant(
  allocationTable.includes("<FIELDNAME>START_DATE</FIELDNAME>"),
  "ZSTOCKALLOC must persist the effective demand-window start",
);
requireInvariant(
  allocationTable.includes("<FIELDNAME>CUTOFF_DATE</FIELDNAME>"),
  "ZSTOCKALLOC must persist the effective demand cutoff",
);
for (const strategy of [
  "c_strategy_fifo",
  "c_strategy_proportional",
  "c_strategy_fair_share",
  "c_strategy_smallest_first",
  "c_strategy_complete_only",
]) {
  requireInvariant(
    allocationDomain.includes(strategy),
    `Allocation domain is missing strategy ${strategy}`,
  );
}
for (const objective of [
  "c_objective_service",
  "c_objective_fill",
  "c_objective_fairness",
  "c_objective_urgency",
]) {
  requireInvariant(
    allocationDomain.includes(objective),
    `Allocation domain is missing comparison objective ${objective}`,
  );
}
for (const severity of [
  "c_drift_severity_none",
  "c_drift_severity_stock",
  "c_drift_severity_demand",
  "c_drift_severity_outcome",
]) {
  requireInvariant(
    allocationDomain.includes(severity),
    `Allocation domain is missing drift severity ${severity}`,
  );
}
requireInvariant(
  /PARAMETERS\s+p_strat\s/i.test(allocationReport),
  "Allocation report must expose strategy selection",
);
requireInvariant(
  /PARAMETERS\s+p_comp\s/i.test(allocationReport),
  "Allocation report must expose side-effect-free strategy comparison",
);
requireInvariant(
  /PARAMETERS\s+p_from\s/i.test(allocationReport),
  "Allocation report must expose the demand-window start",
);
requireInvariant(
  /PARAMETERS\s+p_cutof\s/i.test(allocationReport),
  "Allocation report must expose the demand cutoff",
);
requireInvariant(
  /PARAMETERS\s+p_obj\s/i.test(allocationReport),
  "Allocation report must expose the comparison objective",
);
requireInvariant(
  /validate_plan\(\s*rs_plan\s*\)/i.test(allocationService),
  "Allocation service must validate every calculated plan",
);
requireInvariant(
  /zcl_allocation_query_service/i.test(allocationViewReport),
  "Persisted-plan report must use the authorized query service",
);
requireInvariant(
  /PARAMETERS\s+p_maxage\s/i.test(allocationViewReport),
  "Persisted-plan report must expose its freshness threshold",
);
requireInvariant(
  /PARAMETERS\s+p_live\s/i.test(allocationViewReport),
  "Persisted-plan report must expose optional live drift checking",
);
requireInvariant(
  /PARAMETERS\s+p_versn\s+TYPE\s+i\s+DEFAULT\s+0\./i.test(allocationViewReport),
  "Persisted-plan report must expose zero-as-current version selection",
);
requireInvariant(
  /zcl_allocation_plan_drift/i.test(allocationViewReport),
  "Persisted-plan report must compare saved and live plans through the drift checker",
);

for (const [name, definition] of [
  ["ZSTK_RUN", runAuthorization],
  ["ZSTK_PRI", priorityAuthorization],
]) {
  for (const field of ["ACTVT", "WERKS", "LGORT"]) {
    requireInvariant(
      definition.includes(`>${field}</FIEL`),
      `${name} is missing authorization field ${field}`,
    );
  }
}
for (const activity of ["03", "16"]) {
  requireInvariant(
    runAuthorization.includes(`<ACTVT>${activity}</ACTVT>`),
    `ZSTK_RUN is missing activity ${activity}`,
  );
}
for (const activity of ["02", "06"]) {
  requireInvariant(
    priorityAuthorization.includes(`<ACTVT>${activity}</ACTVT>`),
    `ZSTK_PRI is missing activity ${activity}`,
  );
}
for (const subobject of ["RUN", "PRIORITY"]) {
  requireInvariant(
    applicationLog.subobjects?.some((entry) => entry.name === subobject),
    `Application log is missing subobject ${subobject}`,
  );
}

function walk(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? walk(path) : [path];
  });
}

function walkRepository(directory) {
  const ignoredDirectories = new Set([".git", "node_modules", "output"]);
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    if (entry.isDirectory() && ignoredDirectories.has(entry.name)) {
      return [];
    }
    const path = join(directory, entry.name);
    return entry.isDirectory() ? walkRepository(path) : [path];
  });
}

const standardWritePattern = /\b(?:INSERT|UPDATE|MODIFY|DELETE)\s+(?:MARA|MARD|VBBE)\b/i;
for (const file of walk(join(root, "src")).filter((path) => path.endsWith(".abap"))) {
  requireInvariant(
    !standardWritePattern.test(readFileSync(file, "utf8")),
    `SAP-standard table write found in ${relative(root, file)}`,
  );
}

for (const file of walk(join(root, "sap_stubs"))) {
  requireInvariant(
    !/^z/i.test(relative(join(root, "sap_stubs"), file)),
    `Custom Z object found in sap_stubs: ${relative(root, file)}`,
  );
}

for (const file of walkRepository(root)) {
  const repositoryPath = relative(root, file).replaceAll("\\", "/");
  const isCustomObject = /^z.*\.(?:abap|xml|json)$/i.test(
    repositoryPath.split("/").at(-1),
  );
  requireInvariant(
    !isCustomObject || repositoryPath.startsWith("src/"),
    `Custom Z object found outside src: ${repositoryPath}`,
  );
}

console.log("Repository invariants verified");
