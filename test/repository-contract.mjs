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

function collectFiles(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    if ([".git", "node_modules", "output"].includes(entry.name)) {
      continue;
    }
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectFiles(entryPath));
    } else {
      files.push(entryPath);
    }
  }
  return files;
}

const abaplint = readJson("abaplint.json");
const transpiler = readJson("transpiler.json");
const packageJson = readJson("package.json");
const packageLock = readJson("package-lock.json");
const readmeSource = fs.readFileSync(path.join(repositoryDirectory, "README.md"), "utf8");
const workflowPath = path.join(repositoryDirectory, ".github", "workflows", "verify.yml");
assert.ok(fs.existsSync(workflowPath), "CI verification workflow must be present");
const workflowSource = fs.readFileSync(workflowPath, "utf8");
assert.match(workflowSource, /npm ci/, "CI workflow must install the locked dependency tree");
assert.match(workflowSource, /npm test/, "CI workflow must run the complete test pipeline");

for (const filePath of collectFiles(repositoryDirectory).filter(
  (fileName) => fileName.endsWith(".abap"),
)) {
  const relativePath = path.relative(repositoryDirectory, filePath);
  const sourceText = fs.readFileSync(filePath, "utf8");
  if (/^src[\\/]/i.test(relativePath)) {
    continue;
  }
  assert.doesNotMatch(
    sourceText,
    /^\s*(?:REPORT|CLASS|INTERFACE)\s+Z[A-Z0-9_]+/im,
    `${relativePath} contains a Z-namespaced ABAP object outside src/`,
  );
}
for (const filePath of collectFiles(repositoryDirectory).filter(
  (fileName) => fileName.endsWith(".xml"),
)) {
  const relativePath = path.relative(repositoryDirectory, filePath);
  if (/^src[\\/]/i.test(relativePath)) {
    continue;
  }
  assert.doesNotMatch(
    path.basename(relativePath),
    /^(?:Z|Y)[A-Z0-9_]*\.(?:clas|intf|prog|tabl)\.xml$/i,
    `${relativePath} contains Z/Y-namespaced abapGit metadata outside src/`,
  );
}

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
for (const fileName of fs.readdirSync(sourceDirectory).filter(
  (name) => name.endsWith(".prog.abap"),
)) {
  const reportSource = fs.readFileSync(path.join(sourceDirectory, fileName), "utf8");
  if (reportSource.includes("zcl_stock_json=>")) {
    assert.doesNotMatch(
      reportSource,
      /zcl_stock_json=>error\(/,
      `${fileName} must not emit an unversioned JSON error envelope`,
    );
    assert.match(
      reportSource,
      /zcl_stock_json=>error_with_schema/,
      `${fileName} must use a schema-versioned JSON error envelope`,
    );
  }
  if (reportSource.includes("zcl_stock_csv=>")) {
    assert.doesNotMatch(
      reportSource,
      /zcl_stock_csv=>error\(/,
      `${fileName} must not emit an unversioned CSV error envelope`,
    );
    assert.match(
      reportSource,
      /zcl_stock_csv=>error_with_schema/,
      `${fileName} must use a schema-versioned CSV error envelope`,
    );
  }
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
const openAbapCoreSpec = packageJson.devDependencies["open-abap-core"];
assert.equal(
  packageLock.packages?.[""].devDependencies?.["open-abap-core"],
  openAbapCoreSpec,
  "package-lock root must preserve the package.json open-abap-core pin",
);
assert.equal(
  packageLock.packages?.["node_modules/open-abap-core"]?.resolved,
  openAbapCoreSpec,
  "package-lock resolved open-abap-core entry must preserve the pinned archive",
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
  "marc.tabl.xml",
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
    const callEnd = sourceText.indexOf(".", match.index);
    const callSource = sourceText.slice(match.index, callEnd + 1);
    assert.match(
      callSource,
      /EXCEPTIONS[\s\S]*OTHERS\s*=\s*1/,
      `${fileName} function-module call ${match[1]} must catch classic OTHERS exceptions`,
    );
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
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_CREATE1[\s\S]*const header = input\.exporting\.reservationheader\.get\(\)[\s\S]*const moveType = header\?\.move_type\?\.get\(\)\?\.trim\(\)[\s\S]*const entryQuantity = Number\(item\?\.entry_qnt\?\.get\(\)\)[\s\S]*const payloadIncomplete = [\s\S]*!isSapNumericKey\(moveType, 3\)[\s\S]*!isValidSapDate\(header\?\.res_date\?\.get\(\)\?\.trim\(\)[\s\S]*!header\?\.created_by\?\.get\(\)\?\.trim\(\)[\s\S]*items\.length !== 1[\s\S]*item\?\.plant\?\.get\(\)[\s\S]*item\?\.stge_loc\?\.get\(\)[\s\S]*!Number\.isFinite\(entryQuantity\)[\s\S]*item\?\.entry_uom\?\.get\(\)\?\.trim\(\)[\s\S]*!isValidSapDate\(item\?\.req_date\?\.get\(\)\?\.trim\(\)\)/,
  "reservation API stub must validate the required header and item payload",
);
assert.match(
  sapApiStub,
  /if \(payloadIncomplete\)[\s\S]*Reservation payload is incomplete/,
  "reservation API stub must return an error for incomplete payloads",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_CREATE1[\s\S]*if \(payloadIncomplete\)[\s\S]*Reservation payload is incomplete[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*reservationCounter \+= 1/,
  "reservation API stub must not fabricate a document after payload rejection",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_CREATE1[\s\S]*Reservation rejected by test double[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*if \(material === "MATERIAL-BAD-RETURN-TYPE"\)/,
  "reservation API stub must not fabricate a document after BAPI error",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_CREATE1[\s\S]*Invalid reservation return status[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*if \(material === "MATERIAL-BAD-RESERVATION"\)/,
  "reservation API stub must not fabricate a document after invalid BAPI status",
);
assert.match(
  sapApiStub,
  /BAPI_GOODSMVT_CREATE[\s\S]*const header = input\.exporting\.goodsmvt_header\.get\(\)[\s\S]*const code = input\.exporting\.goodsmvt_code\.get\(\)[\s\S]*const movementType = item\?\.move_type\?\.get\(\)\?\.trim\(\)[\s\S]*const entryQuantity = Number\(item\?\.entry_qnt\?\.get\(\)\)[\s\S]*const payloadIncomplete = [\s\S]*!isValidSapDate\(header\?\.pstng_date\?\.get\(\)\?\.trim\(\)\)[\s\S]*!isValidSapDate\(header\?\.doc_date\?\.get\(\)\?\.trim\(\)\)[\s\S]*gm_code\?\.get\(\)\?\.trim\(\) !== "03"[\s\S]*items\.length !== 1[\s\S]*!isSapNumericKey\(movementType, 3\)[\s\S]*!Number\.isFinite\(entryQuantity\)[\s\S]*item\?\.entry_uom\?\.get\(\)/,
  "goods-movement API stub must validate the required header, code, and item payload",
);
assert.match(
  sapApiStub,
  /payloadIncomplete\)[\s\S]*Goods movement payload is incomplete/,
  "goods-movement API stub must return an error for incomplete payloads",
);
assert.match(
  sapApiStub,
  /BAPI_GOODSMVT_CREATE[\s\S]*if \(payloadIncomplete\)[\s\S]*Goods movement payload is incomplete[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*movementCounter \+= 1/,
  "goods-movement API stub must not fabricate a document after payload rejection",
);
assert.match(
  sapApiStub,
  /BAPI_GOODSMVT_CREATE[\s\S]*Goods movement rejected by test double[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*if \(material === "MATERIAL-GI-BAD-RETURN-TYPE"\)/,
  "goods-movement API stub must not fabricate a document after BAPI error",
);
assert.match(
  sapApiStub,
  /BAPI_GOODSMVT_CREATE[\s\S]*Invalid goods movement return status[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*movementCounter \+= 1/,
  "goods-movement API stub must not fabricate a document after invalid BAPI status",
);
assert.match(
  sapApiStub,
  /BAPI_SALESORDER_CHANGE[\s\S]*const headerX = input\.exporting\.order_header_inx\.get\(\)[\s\S]*const payloadIncomplete = [\s\S]*headerX\?\.updateflag\?\.get\(\)\?\.trim\(\) !== "U"[\s\S]*schedules\.length !== 1[\s\S]*scheduleXs\.length !== 1[\s\S]*scheduleX\?\.updateflag\?\.get\(\)\?\.trim\(\) !== "U"[\s\S]*scheduleX\?\.req_qty\?\.get\(\)\?\.trim\(\) !== "X"/,
  "sales-order API stub must validate the required header and schedule payload",
);
assert.match(
  sapApiStub,
  /payloadIncomplete\)[\s\S]*Sales-order change payload is incomplete/,
  "sales-order API stub must return an error for incomplete payloads",
);
assert.match(
  sapApiStub,
  /const isSapNumericKey = \(value, length\) =>[\s\S]*normalized !== "0"\.repeat\(length\)/,
  "SAP API stubs must provide NUMC-key validation",
);
assert.match(
  sapApiStub,
  /BAPI_SALESORDER_CHANGE[\s\S]*const scheduleQuantity = Number\(schedule\?\.req_qty\?\.get\(\)\)[\s\S]*!isSapNumericKey\(salesDocument, 10\)[\s\S]*!isSapNumericKey\(scheduleItem, 6\)[\s\S]*!isSapNumericKey\(scheduleLine, 4\)[\s\S]*!Number\.isFinite\(scheduleQuantity\)[\s\S]*scheduleXItem !== scheduleItem[\s\S]*scheduleXLine !== scheduleLine/,
  "sales-order API stub must validate numeric keys, finite quantity, and row correlation",
);
assert.match(
  sapApiStub,
  /BAPI_SALESORDER_CHANGE[\s\S]*Sales-order change payload is incomplete[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*if \(salesDocument === "9999999900"\)/,
  "sales-order API stub must terminate after payload rejection",
);
assert.match(
  sapApiStub,
  /BAPI_SALESORDER_CHANGE[\s\S]*Invalid sales-order return status[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*abap\.FunctionModules\["BAPI_RESERVATION_DELETE"\]/,
  "sales-order API stub must terminate after invalid return status",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_DELETE[\s\S]*const payloadIncomplete = [\s\S]*reservation\.length !== 10[\s\S]*\^\[0-9\]\+\$[\s\S]*reservation === "0000000000"/,
  "reservation-delete API stub must validate the SAP reservation key shape",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_DELETE[\s\S]*if \(payloadIncomplete\)[\s\S]*Reservation deletion payload is incomplete[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*commitFails = reservation === "9999999999"/,
  "reservation-delete API stub must reject malformed payloads before transaction behavior",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_DELETE[\s\S]*Reservation deletion rejected by test double[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*if \(reservation === "9999999997"\)/,
  "reservation-delete API stub must terminate after BAPI error",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_DELETE[\s\S]*Invalid reservation deletion return status[\s\S]*input\.tables\.return\.append\(returnRow\)[\s\S]*abap\.builtin\.sy\.get\(\)\.subrc\.set\(0\)[\s\S]*return;[\s\S]*abap\.FunctionModules\["BAPI_TRANSACTION_COMMIT"\]/,
  "reservation-delete API stub must terminate after invalid return status",
);
assert.match(
  sapApiStub,
  /ENQUEUE_EZSTOCKALLOC[\s\S]*const material = input\.exporting\.matnr\.get\(\)\?\.trim\(\)[\s\S]*const plant = input\.exporting\.werks\.get\(\)\?\.trim\(\)[\s\S]*const storageLocation = input\.exporting\.lgort\.get\(\)\?\.trim\(\)[\s\S]*if \(!material \|\| !plant \|\| !storageLocation\)[\s\S]*throw \{classic: "OTHERS"\}/,
  "allocation enqueue stub must require material, plant, and storage scope",
);
assert.match(
  sapApiStub,
  /DEQUEUE_EZSTOCKALLOC[\s\S]*const material = input\.exporting\.matnr\.get\(\)\?\.trim\(\)[\s\S]*const plant = input\.exporting\.werks\.get\(\)\?\.trim\(\)[\s\S]*const storageLocation = input\.exporting\.lgort\.get\(\)\?\.trim\(\)[\s\S]*if \(!material \|\| !plant \|\| !storageLocation\)[\s\S]*throw \{classic: "OTHERS"\}/,
  "allocation dequeue stub must require material, plant, and storage scope",
);
assert.match(
  sapApiStub,
  /MD_CONVERT_MATERIAL_UNIT[\s\S]*const payloadIncomplete = [\s\S]*!material[\s\S]*!unitIn[\s\S]*!unitOut[\s\S]*!Number\.isFinite\(quantity\)[\s\S]*quantity < 0[\s\S]*if \(payloadIncomplete\)[\s\S]*throw \{classic: "OTHERS"\}/,
  "material-unit conversion stub must reject incomplete or negative input payloads",
);
assert.match(
  sapApiStub,
  /const isValidSapDate = \(value\) =>[\s\S]*value === "00000000"[\s\S]*leapYear[\s\S]*monthDays/,
  "SAP API stubs must provide calendar-date validation",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_CREATE1[\s\S]*!isValidSapDate\(header\?\.res_date\?\.get\(\)\?\.trim\(\)\)[\s\S]*!isValidSapDate\(item\?\.req_date\?\.get\(\)\?\.trim\(\)\)/,
  "reservation API stub must validate header and required dates",
);
assert.match(
  sapApiStub,
  /BAPI_GOODSMVT_CREATE[\s\S]*!isValidSapDate\(header\?\.pstng_date\?\.get\(\)\?\.trim\(\)\)[\s\S]*!isValidSapDate\(header\?\.doc_date\?\.get\(\)\?\.trim\(\)\)/,
  "goods-movement API stub must validate posting and document dates",
);
assert.match(
  sapApiStub,
  /BAPI_RESERVATION_CREATE1[\s\S]*const moveType = header\?\.move_type\?\.get\(\)\?\.trim\(\)[\s\S]*const entryQuantity = Number\(item\?\.entry_qnt\?\.get\(\)\)[\s\S]*!isSapNumericKey\(moveType, 3\)[\s\S]*!Number\.isFinite\(entryQuantity\)[\s\S]*entryQuantity <= 0/,
  "reservation API stub must validate movement type and finite positive quantity",
);
assert.match(
  sapApiStub,
  /BAPI_GOODSMVT_CREATE[\s\S]*const movementType = item\?\.move_type\?\.get\(\)\?\.trim\(\)[\s\S]*const entryQuantity = Number\(item\?\.entry_qnt\?\.get\(\)\)[\s\S]*!isSapNumericKey\(movementType, 3\)[\s\S]*!Number\.isFinite\(entryQuantity\)[\s\S]*entryQuantity <= 0/,
  "goods-movement API stub must validate movement type and finite positive quantity",
);
const productionSourceTableNames = new Set();
const productionDatabaseWrites = new Set();
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
  for (const match of sourceText.matchAll(/^\s*(?:DELETE\s+FROM|UPDATE|MODIFY)\s+([A-Z0-9_]+)|^\s*INSERT\s+([A-Z0-9_]+)\s+FROM\b/gim)) {
    productionDatabaseWrites.add((match[1] ?? match[2]).toUpperCase());
  }
}
for (const tableName of productionDatabaseWrites) {
  assert.match(
    tableName,
    /^Z/,
    `production database write must target a custom Z table: ${tableName}`,
  );
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
for (const fileName of fs.readdirSync(stubDirectory).filter(
  (name) => name.endsWith(".tabl.xml"),
)) {
  const tableStub = fs.readFileSync(path.join(stubDirectory, fileName), "utf8");
  const tableName = /<TABNAME>\s*([A-Z0-9_]+)\s*<\/TABNAME>/i.exec(tableStub)?.[1]?.toUpperCase();
  assert.ok(tableName, `${fileName} must declare a SAP table identity`);
  assert.doesNotMatch(
    tableName,
    /^Z/,
    `${fileName} must describe a standard SAP table, not a custom table`,
  );
  assert.match(
    tableStub,
    /<DD03P>[\s\S]*?<FIELDNAME>MANDT<\/FIELDNAME>[\s\S]*?<KEYFLAG>X<\/KEYFLAG>[\s\S]*?<\/DD03P>/i,
    `${fileName} must expose MANDT as a key field for client-safe test SQL`,
  );
  const fieldRows = [...tableStub.matchAll(/<DD03P>([\s\S]*?)<\/DD03P>/gi)];
  assert.ok(fieldRows.length > 0, `${fileName} must declare DDIC fields`);
  const fieldNames = new Set();
  for (const fieldRow of fieldRows) {
    const row = fieldRow[1];
    const fieldName = /<FIELDNAME>\s*([A-Z0-9_]+)\s*<\/FIELDNAME>/i.exec(row)?.[1]?.toUpperCase();
    const dataType = /<DATATYPE>\s*([A-Z0-9_]+)\s*<\/DATATYPE>/i.exec(row)?.[1]?.toUpperCase();
    const length = /<LENG>\s*(\d+)\s*<\/LENG>/i.exec(row)?.[1];
    assert.ok(fieldName, `${fileName} contains a DDIC row without FIELDNAME`);
    assert.equal(fieldNames.has(fieldName), false, `${fileName} contains duplicate field ${fieldName}`);
    fieldNames.add(fieldName);
    assert.equal(
      /<TABNAME>\s*([A-Z0-9_]+)\s*<\/TABNAME>/i.exec(row)?.[1]?.toUpperCase(),
      tableName,
      `${fileName} field ${fieldName} must identify its containing table`,
    );
    assert.ok(dataType, `${fileName} field ${fieldName} must declare DATATYPE`);
    assert.ok(length && Number(length) > 0, `${fileName} field ${fieldName} must declare a positive LENG`);
    assert.match(row, /<POSITION>\s*\d+\s*<\/POSITION>/i, `${fileName} field ${fieldName} must declare POSITION`);
    if (dataType === "DATS") {
      assert.equal(length, "000008", `${fileName} date field ${fieldName} must be eight characters`);
    }
    if (dataType === "UNIT") {
      assert.equal(length, "000003", `${fileName} unit field ${fieldName} must be three characters`);
    }
    if (dataType === "QUAN") {
      assert.match(row, /<DECIMALS>\s*\d+\s*<\/DECIMALS>/i, `${fileName} quantity field ${fieldName} must declare DECIMALS`);
      assert.match(row, /<REFTABLE>\s*[A-Z0-9_]+\s*<\/REFTABLE>/i, `${fileName} quantity field ${fieldName} must declare REFTABLE`);
      assert.match(row, /<REFFIELD>\s*[A-Z0-9_]+\s*<\/REFFIELD>/i, `${fileName} quantity field ${fieldName} must declare REFFIELD`);
    }
  }
}
const requiredSapTableFields = new Map([
  ["MARA", ["MATNR", "MEINS", "XCHPF", "LVORM"]],
  ["MARC", ["MATNR", "WERKS", "LVORM"]],
  ["MARD", ["MATNR", "WERKS", "LGORT", "LABST", "LVORM"]],
  ["MARM", ["MATNR", "MEINH", "UMREZ", "UMREN"]],
  ["MCHA", ["MATNR", "WERKS", "CHARG", "VFDAT", "ZUSTD", "LVORM"]],
  ["MCHB", ["MATNR", "WERKS", "LGORT", "CHARG", "CLABS", "LVORM"]],
  ["VBAK", ["VBELN", "VBTYP", "AUART", "LIFSK"]],
  ["VBAP", ["VBELN", "POSNR", "MATNR", "WERKS", "ABGRU", "LPRIO", "VRKME", "LOEKZ", "LIFSP"]],
  ["VBEP", ["VBELN", "POSNR", "ETENR", "EDATU", "WMENG", "BMENG", "LIFSP"]],
]);
for (const [tableName, fieldNames] of requiredSapTableFields) {
  const tableStubPath = path.join(stubDirectory, `${tableName.toLowerCase()}.tabl.xml`);
  const tableStub = fs.readFileSync(tableStubPath, "utf8");
  for (const fieldName of fieldNames) {
    assert.match(
      tableStub,
      new RegExp(`<FIELDNAME>\\s*${fieldName}\\s*</FIELDNAME>`, "i"),
      `SAP table stub ${tableName} must expose field ${fieldName}`,
    );
  }
}
for (const fileName of fs.readdirSync(sourceDirectory).filter(
  (name) => name.endsWith(".abap") && !name.endsWith(".testclasses.abap"),
)) {
  const sourceText = fs.readFileSync(path.join(sourceDirectory, fileName), "utf8");
  const aliases = new Map();
  for (const match of sourceText.matchAll(
    /\b(?:FROM|JOIN)\s+([A-Z0-9_]+)(?:\s+AS\s+([A-Z0-9_]+))?/gim,
  )) {
    const tableName = match[1].toUpperCase();
    const alias = (match[2] ?? tableName).toUpperCase();
    aliases.set(alias, tableName);
  }
  for (const match of sourceText.matchAll(/\b([A-Z0-9_]+)~([A-Z0-9_]+)\b/gim)) {
    const tableName = aliases.get(match[1].toUpperCase());
    if (!tableName || tableName.startsWith("Z")) {
      continue;
    }
    const tableStubPath = path.join(stubDirectory, `${tableName.toLowerCase()}.tabl.xml`);
    assert.ok(
      fs.existsSync(tableStubPath),
      `${fileName} qualified SQL reference ${match[1]}~${match[2]} must have a SAP table stub`,
    );
    const tableStub = fs.readFileSync(tableStubPath, "utf8");
    assert.match(
      tableStub,
      new RegExp(`<FIELDNAME>\\s*${match[2]}\\s*</FIELDNAME>`, "i"),
      `${fileName} qualified SQL field ${match[1]}~${match[2]} must be declared in ${tableName}`,
    );
  }
}
for (const fileName of fs.readdirSync(sourceDirectory).filter(
  (name) => name.endsWith(".tabl.xml"),
)) {
  const tableSource = fs.readFileSync(path.join(sourceDirectory, fileName), "utf8");
  const tableName = /<TABNAME>\s*([A-Z0-9_]+)\s*<\/TABNAME>/i.exec(tableSource)?.[1]?.toUpperCase();
  assert.ok(tableName, `${fileName} must declare a custom table identity`);
  assert.match(
    tableName,
    /^Z/,
    `${fileName} must remain in the custom Z table namespace`,
  );
  assert.match(
    tableSource,
    /<DD02V>[\s\S]*?<CLIDEP>X<\/CLIDEP>[\s\S]*?<\/DD02V>/i,
    `${fileName} must be client-dependent`,
  );
  assert.match(
    tableSource,
    /<DD03P>[\s\S]*?<FIELDNAME>MANDT<\/FIELDNAME>[\s\S]*?<KEYFLAG>X<\/KEYFLAG>[\s\S]*?<\/DD03P>/i,
    `${fileName} must expose MANDT as a key field for client-safe persistence`,
  );
}
const vbapStubSource = fs.readFileSync(
  path.join(stubDirectory, "vbap.tabl.xml"),
  "utf8",
);
assert.match(
  vbapStubSource,
  /<FIELDNAME>LIFSP<\/FIELDNAME>/,
  "VBAP SAP table stub must expose the item delivery-block field",
);
const marcStubSource = fs.readFileSync(
  path.join(stubDirectory, "marc.tabl.xml"),
  "utf8",
);
assert.match(
  marcStubSource,
  /<FIELDNAME>LVORM<\/FIELDNAME>/,
  "MARC SAP table stub must expose the plant material deletion flag",
);
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
const allocationDateSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_allocation_date_sap.clas.abap"),
  "utf8",
);
const allocationTimeSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_allocation_time_sap.clas.abap"),
  "utf8",
);
assert.match(
  stockSourceSource,
  /FROM marc/,
  "SAP stock source must read plant-specific material status",
);
assert.match(
  stockSourceSource,
  /Material is marked for deletion at plant/,
  "SAP stock source must reject plant-deleted materials",
);
assert.match(
  stockSourceSource,
  /Plant material data is missing/,
  "SAP stock source must reject material stock without plant data",
);
const orderSourceSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_order_source_sap.clas.abap"),
  "utf8",
);
const sourceAuthoritySource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_source_read_auth_sap.clas.abap"),
  "utf8",
);
assert.match(
  sourceAuthoritySource,
  /iv_table\s*=\s*'MARC'[\s\S]*Plant material read authorization failed/,
  "stock read authorization must cover MARC plant data",
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
const auditInterfaceSource = fs.readFileSync(
  path.join(sourceDirectory, "zif_allocation_audit.intf.abap"),
  "utf8",
);
const auditTableSource = fs.readFileSync(
  path.join(sourceDirectory, "zstockalloc_run.tabl.xml"),
  "utf8",
);
const auditTestSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_allocation_audit_sap.clas.testclasses.abap"),
  "utf8",
);
const compareSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_allocation_compare.clas.abap"),
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
const allocationLockSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_allocation_lock_sap.clas.abap"),
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
const orderUpdateReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_order_update.prog.abap"),
  "utf8",
);
const goodsIssueReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_goods_issue.prog.abap"),
  "utf8",
);
const stockReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_stock.prog.abap"),
  "utf8",
);
const reservationCancelReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_res_cancel.prog.abap"),
  "utf8",
);
const reservationCreateReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_reserve.prog.abap"),
  "utf8",
);
const conversionReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_convert.prog.abap"),
  "utf8",
);
const stockJsonSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_json.clas.abap"),
  "utf8",
);
const stockCsvSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_csv.clas.abap"),
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
  /iv_shortage_limit_active[\s\S]*iv_max_shortage[\s\S]*Maximum shortage limit exceeded/,
  "allocation service must enforce the maximum-shortage guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_coverage_limit_active[\s\S]*iv_min_coverage[\s\S]*Minimum coverage limit not met/,
  "allocation service must enforce the minimum-coverage guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_full_line_limit_active[\s\S]*iv_min_full_line_pct[\s\S]*Minimum full-line percentage not met/,
  "allocation service must enforce the minimum full-line guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_full_count_limit_active[\s\S]*iv_min_full_lines[\s\S]*Minimum full lines not met/,
  "allocation service must enforce the minimum full-line-count guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_max_full_count_limit_active[\s\S]*iv_max_full_lines[\s\S]*Maximum full lines limit exceeded/,
  "allocation service must enforce the maximum full-line-count guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_demand_limit_active[\s\S]*iv_max_demand_count[\s\S]*Maximum demand count exceeded/,
  "allocation service must enforce the maximum-demand guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_quantity_limit_active[\s\S]*iv_max_requested_quantity[\s\S]*Maximum requested quantity exceeded/,
  "allocation service must enforce the maximum-quantity guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_allocation_limit_active[\s\S]*iv_max_allocated_quantity[\s\S]*Maximum allocated quantity exceeded/,
  "allocation service must enforce the maximum-allocation guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_min_alloc_limit_active[\s\S]*iv_min_allocated_quantity[\s\S]*Minimum allocated quantity not met/,
  "allocation service must enforce the minimum-allocation guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_min_line_limit_active[\s\S]*iv_min_alloc_lines[\s\S]*Minimum allocated lines not met/,
  "allocation service must enforce the minimum-allocation-line guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_line_limit_active[\s\S]*iv_max_alloc_lines[\s\S]*Maximum allocated lines exceeded/,
  "allocation service must enforce the maximum-allocation-line guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_spct_limit_active[\s\S]*iv_max_shortage_pct[\s\S]*Maximum shortage percentage exceeded/,
  "allocation service must enforce the maximum-shortage-percentage guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_unalloc_limit_active[\s\S]*iv_max_unalloc_lines[\s\S]*Maximum unallocated lines exceeded/,
  "allocation service must enforce the maximum-unallocated-line guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_partial_limit_active[\s\S]*iv_max_partial_lines[\s\S]*Maximum partial lines exceeded/,
  "allocation service must enforce the maximum-partial-line guard before writes",
);
assert.match(
  allocationServiceSource,
  /iv_shline_limit_active[\s\S]*iv_max_shortage_lines[\s\S]*Maximum shortage lines exceeded/,
  "allocation service must enforce the maximum-shortage-line guard before writes",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-allocation_run_id\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_demand>-allocation_strategy\s+IS\s+NOT\s+INITIAL[\s\S]*<ls_demand>-allocation_unit\s+IS\s+NOT\s+INITIAL/,
  "allocation service must reject allocator-owned allocation metadata mutation",
);
assert.match(
  allocationServiceSource,
  /iv_requested_on_from[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*Requested delivery date range is invalid/,
  "allocation service must reject malformed requested-date bounds",
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
  /iv_sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*iv_sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*iv_sales_document\s+CN\s+'0123456789'[\s\S]*iv_sales_document\s*=\s*'0000000000'/,
  "allocation result reads must reject malformed sales-document filters",
);
assert.match(
  allocationSinkSource,
  /iv_reservation_id\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*iv_reservation_id\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*iv_reservation_id\s+CN\s+'0123456789\s*'[\s\S]*lv_reservation_document_filter\s+CN\s+'0123456789'[\s\S]*lv_reservation_document_filter\s*=\s*'0000000000'/,
  "allocation result reads must reject malformed numeric reservation filters",
);
assert.match(
  allocationSinkSource,
  /is_demand-reservation_id\s*=\s*'0000000000'/,
  "allocation snapshots must reject the all-zero reservation sentinel",
);
assert.match(
  allocationSinkSource,
  /METHOD validate_demand[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*is_demand-requested_on[\s\S]*is_demand-reservation_date/,
  "allocation snapshots must reject malformed demand and reservation dates",
);
assert.match(
  allocationSinkSource,
  /lv_run_requested_on_from[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*Allocation snapshot run requested horizon is invalid/,
  "allocation snapshots must reject malformed persisted run horizons",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-reservation_id\s*=\s*'0000000000'/,
  "allocation reconciliation must reject the all-zero reservation sentinel",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~start_run[\s\S]*iv_requested_on_from[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*Audit requested date range is invalid/,
  "audit run creation must reject malformed requested-date bounds",
);
assert.match(
  auditInterfaceSource,
  /BEGIN OF ty_run[\s\S]*preview\s+TYPE abap_bool/,
  "audit run API must expose persisted preview provenance",
);
assert.match(
  auditInterfaceSource,
  /METHODS start_run[\s\S]*iv_strategy[\s\S]*iv_preview\s+TYPE abap_bool OPTIONAL/,
  "audit run creation must accept preview provenance",
);
assert.match(
  auditInterfaceSource,
  /METHODS get_runs[\s\S]*iv_status[\s\S]*iv_preview_filter\s+TYPE ty_preview_filter OPTIONAL/,
  "audit history reads must accept a preview provenance filter",
);
assert.match(
  auditTableSource,
  /<FIELDNAME>PREVIEW<\/FIELDNAME>[\s\S]*<DATATYPE>CHAR<\/DATATYPE>[\s\S]*<LENG>000001<\/LENG>/,
  "audit run table must persist a one-character preview marker",
);
assert.match(
  allocationServiceSource,
  /iv_strategy\s*=\s*lv_strategy[\s\S]*iv_preview\s*=\s*iv_preview/,
  "allocation service must persist preview provenance when starting an audit run",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~start_run[\s\S]*iv_preview IS NOT INITIAL[\s\S]*Audit preview flag is invalid[\s\S]*ls_run-preview\s*=\s*iv_preview/,
  "audit run creation must validate and persist preview provenance",
);
assert.match(
  auditInterfaceSource,
  /METHODS record_rejection[\s\S]*iv_message\s+TYPE ty_message[\s\S]*iv_preview\s+TYPE abap_bool OPTIONAL/,
  "audit rejection writes must accept preview provenance",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~record_rejection[\s\S]*iv_preview IS NOT INITIAL[\s\S]*Audit preview flag is invalid[\s\S]*ls_run-preview\s*=\s*iv_preview/,
  "audit rejection writes must validate and persist preview provenance",
);
assert.match(
  allocationServiceSource,
  /mv_preview\s*=\s*xsdbool\(\s*iv_preview\s*=\s*abap_true\s*\)[\s\S]*iv_preview\s*=\s*mv_preview/,
  "allocation rejection audits must carry the request preview provenance",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~get_runs[\s\S]*strategy,[\s\S]*preview,[\s\S]*start_date/,
  "audit history reads must return preview provenance",
);
assert.match(
  auditSource,
  /lv_preview_filter\s*=\s*to_upper\( iv_preview_filter \)[\s\S]*Audit preview filter is invalid[\s\S]*lv_preview_filter = 'P'[\s\S]*<ls_run>-preview <> abap_true/,
  "audit history reads must validate and apply preview provenance filters",
);
assert.match(
  auditTestSource,
  /METHOD records_preview_provenance[\s\S]*iv_preview\s*=\s*abap_true[\s\S]*-preview/,
  "audit tests must cover preview provenance persistence and reads",
);
assert.match(
  auditTestSource,
  /METHOD filters_preview_runs[\s\S]*iv_preview_filter\s*=\s*'p'[\s\S]*iv_preview_filter\s*=\s*'o'/,
  "audit tests must cover preview-only and operational-only filtering",
);
assert.match(
  auditSource,
  /METHOD validate_run[\s\S]*is_run-start_date[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*Audit run data is invalid/,
  "audit reads must reject malformed persisted run dates",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~get_runs[\s\S]*validate_date[\s\S]*iv_start_date_from[\s\S]*iv_finish_date_to/,
  "audit history filters must reject malformed lifecycle dates",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~get_purge_preview[\s\S]*validate_date[\s\S]*iv_before_date[\s\S]*iv_deadline_age_date/,
  "audit purge previews must reject malformed date filters",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~purge_runs_before[\s\S]*validate_date[\s\S]*iv_before_date[\s\S]*iv_deadline_age_date/,
  "audit purge execution must reject malformed date filters",
);
assert.equal(
  (auditSource.match(/SORT lt_candidates BY start_date ASCENDING start_time ASCENDING\s+run_id ASCENDING/g) || []).length,
  2,
  "audit purge preview and execution must sort candidates deterministically",
);
assert.equal(
  (auditSource.match(/IF iv_max_runs > 0 AND lv_selected_count >= iv_max_runs/g) || []).length,
  6,
  "audit purge caps must apply to finalized statuses after reservation protection checks",
);
assert.equal(
  (auditSource.match(/Audit purge candidate is invalid/g) || []).length,
  6,
  "audit purge preview and execution must validate persisted candidate timestamps and horizons",
);
assert.match(
  auditSource,
  /LOOP AT lt_candidates[\s\S]*zcl_allocation_time_sap=>is_valid_or_initial[\s\S]*Audit purge candidate is invalid[\s\S]*cl_abap_tstmp=>td_subtract/,
  "audit purge candidates must validate timestamp shape before duration arithmetic",
);
assert.match(
  auditSource,
  /LOOP AT lt_candidates INTO ls_candidate[\s\S]*requested_on_from IS NOT INITIAL[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*lv_requested_deadline/,
  "audit purge candidates must validate persisted requested horizons before deadline arithmetic",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~get_runs[\s\S]*status = 'E'[\s\S]*requested_on_from[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*iv_sort_by_deadline_age[\s\S]*DELETE rt_runs/,
  "audit history must exclude malformed error horizons from deadline arithmetic and sorting",
);
assert.match(
  auditSource,
  /METHOD zif_allocation_audit~get_runs[\s\S]*status = 'E'[\s\S]*CLEAR <ls_run>-requested_deadline/,
  "audit history must not expose a malformed derived deadline to report consumers",
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
  allocationDateSource,
  /CLASS-METHODS\s+is_valid_or_initial[\s\S]*lv_year\s+MOD\s+400[\s\S]*WHEN 2\.[\s\S]*lv_days\s*=\s*29/,
  "shared SAP date validation must check calendar month lengths and leap years",
);
assert.match(
  allocationTimeSource,
  /CLASS-METHODS\s+is_valid_or_initial[\s\S]*lv_hour[\s\S]*lv_minute[\s\S]*lv_second[\s\S]*lv_hour\s*<=\s*23[\s\S]*lv_minute\s*<=\s*59[\s\S]*lv_second\s*<=\s*59/,
  "shared SAP time validation must check clock bounds",
);
assert.match(
  auditSource,
  /zcl_allocation_time_sap=>is_valid_or_initial[\s\S]*is_run-start_time[\s\S]*is_run-finish_time/,
  "audit run validation must reject malformed persisted clock times",
);
assert.match(
  stockSourceSource,
  /zcl_allocation_date_sap=>is_valid_or_initial\([\s\S]*batch_expiration_date/,
  "stock source must reject malformed batch expiration dates",
);
assert.match(
  sourceAuthoritySource,
  /check_stock\.[\s\S]*verify_table\([\s\S]*iv_table\s*=\s*'MARA'[\s\S]*verify_table\([\s\S]*iv_table\s*=\s*'MARC'[\s\S]*IF iv_batch IS INITIAL[\s\S]*iv_table\s*=\s*'MARD'[\s\S]*ELSE[\s\S]*iv_table\s*=\s*'MCHB'[\s\S]*iv_table\s*=\s*'MCHA'/,
  "stock read authority must match batch and non-batch table access",
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
  /item_delivery_block\s+TYPE\s+c\s+LENGTH\s+2[\s\S]*item~lifsp\s+AS\s+item_delivery_block[\s\S]*<ls_schedule>-item_delivery_block\s+IS\s+NOT\s+INITIAL/,
  "order source must exclude item-level delivery-blocked sales-order items",
);
assert.match(
  orderSourceSource,
  /ls_demand-sales_document\s*=\s*'0000000000'/,
  "order source must reject the all-zero sales-document sentinel",
);
assert.match(
  orderSourceSource,
  /schedule~wmeng\s*<\s*0[\s\S]*schedule~bmeng\s*<\s*0[\s\S]*requested\s*<\s*0[\s\S]*confirmed\s*<\s*0/,
  "order source must select and reject negative schedule quantities",
);
assert.match(
  orderSourceSource,
  /requested\s*<=\s*<ls_schedule>-confirmed[\s\S]*CONTINUE/,
  "order source must skip only genuinely fulfilled nonnegative schedules after validation",
);
assert.match(
  orderSourceSource,
  /schedule~edatu\s*>=\s*'00000000'[\s\S]*schedule~edatu\s*<=\s*'99999999'[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial/,
  "order source must validate every candidate requested date before horizon filtering",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-sales_document\s*=\s*'0000000000'/,
  "allocation service must reject the all-zero sales-document sentinel",
);
assert.match(
  allocationServiceSource,
  /zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*batch_expiration_date[\s\S]*Open demand requested date is invalid/,
  "allocation service must reject malformed provider dates before side effects",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-requested_on[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*<ls_existing>-reservation_date/,
  "allocation service must reject malformed existing snapshot dates before reconciliation",
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
assert.match(
  allocationSinkSource,
  /zcl_allocation_time_sap=>is_valid_or_initial[\s\S]*<ls_strategy_run>-start_time[\s\S]*<ls_strategy_run>-finish_time[\s\S]*Allocation result audit run is invalid[\s\S]*cl_abap_tstmp=>td_subtract/,
  "allocation result reads must validate originating audit timestamps before duration arithmetic",
);
assert.match(
  allocationSinkSource,
  /METHOD validate_date[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*raise_error/,
  "allocation result reads must provide a shared calendar-date validation boundary",
);
assert.match(
  allocationSinkSource,
  /validate_date\([\s\S]*iv_date\s*=\s*iv_overdue_date[\s\S]*validate_date\([\s\S]*iv_date\s*=\s*iv_run_deadline_age_date[\s\S]*validate_date\([\s\S]*iv_date\s*=\s*iv_requested_on_from[\s\S]*validate_date\([\s\S]*iv_date\s*=\s*iv_run_deadline_from[\s\S]*validate_date\([\s\S]*iv_date\s*=\s*iv_reservation_date_from/,
  "allocation result reads must validate caller-supplied date filters before comparisons or arithmetic",
);
assert.match(
  compareSource,
  /METHOD zif_stock_allocation_compare~get_running_age[\s\S]*is_run-finish_time IS NOT INITIAL[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*zcl_allocation_time_sap=>is_valid_or_initial[\s\S]*cl_abap_tstmp=>td_subtract/,
  "comparison running-age reads must validate timestamp shape before arithmetic",
);
assert.match(
  fs.readFileSync(path.join(sourceDirectory, "zstock_alloc_compare.prog.abap"), "utf8"),
  /p_rmov\s*=\s*zif_stock_allocation=>c_zero_movement_type[\s\S]*p_ormov\s*=\s*zif_stock_allocation=>c_zero_movement_type[\s\S]*p_nrmov\s*=\s*zif_stock_allocation=>c_zero_movement_type/,
  "comparison movement-type filters must reject the zero sentinel",
);
assert.match(
  reservationSource,
  /iv_required_date[\s\S]*zcl_allocation_date_sap=>is_valid_or_initial[\s\S]*Reservation input is invalid/,
  "SAP reservation creation must reject malformed required dates",
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
  /IF iv_batch IS INITIAL[\s\S]*iv_table\s*=\s*'MARD'[\s\S]*ELSE[\s\S]*iv_table\s*=\s*'MCHB'[\s\S]*iv_table\s*=\s*'MCHA'/,
  "source read authority must scope storage-table checks to the selected read path",
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
assert.match(
  allocationReportSource,
  /p_shg[\s\S]*p_shmax/,
  "allocation report must expose the shortage guard selections",
);
assert.match(
  allocationReportSource,
  /iv_shortage_limit_active\s*=\s*p_shg[\s\S]*iv_max_shortage\s*=\s*p_shmax/,
  "allocation report must pass the shortage guard selections to the service",
);
assert.match(
  allocationReportSource,
  /p_covg[\s\S]*p_covmin/,
  "allocation report must expose the coverage guard selections",
);
assert.match(
  allocationReportSource,
  /iv_coverage_limit_active\s*=\s*p_covg[\s\S]*iv_min_coverage\s*=\s*p_covmin/,
  "allocation report must pass the coverage guard selections to the service",
);
assert.match(
  allocationReportSource,
  /coverage_guard_active[\s\S]*minimum_coverage_pct/,
  "allocation report exports must expose coverage guard provenance",
);
assert.match(
  allocationReportSource,
  /p_fullg[\s\S]*p_fmin/,
  "allocation report must expose the full-line guard selections",
);
assert.match(
  allocationReportSource,
  /iv_full_line_limit_active\s*=\s*p_fullg[\s\S]*iv_min_full_line_pct\s*=\s*p_fmin/,
  "allocation report must pass the full-line guard selections to the service",
);
assert.match(
  allocationReportSource,
  /full_line_guard_active[\s\S]*minimum_full_line_pct/,
  "allocation report exports must expose full-line guard provenance",
);
assert.match(
  allocationReportSource,
  /p_flg[\s\S]*p_flmin/,
  "allocation report must expose the minimum full-line-count guard selections",
);
assert.match(
  allocationReportSource,
  /iv_full_count_limit_active\s*=\s*p_flg[\s\S]*iv_min_full_lines\s*=\s*p_flmin/,
  "allocation report must pass the minimum full-line-count guard selections to the service",
);
assert.match(
  allocationReportSource,
  /full_line_count_guard_active[\s\S]*minimum_full_lines/,
  "allocation report exports must expose minimum full-line-count guard provenance",
);
assert.match(
  allocationReportSource,
  /p_mflg[\s\S]*p_mflmax/,
  "allocation report must expose the maximum full-line-count guard selections",
);
assert.match(
  allocationReportSource,
  /iv_max_full_count_limit_active\s*=\s*p_mflg[\s\S]*iv_max_full_lines\s*=\s*p_mflmax/,
  "allocation report must pass the maximum full-line-count guard selections to the service",
);
assert.match(
  allocationReportSource,
  /maximum_full_line_count_guard_active[\s\S]*maximum_full_lines/,
  "allocation report exports must expose maximum full-line-count guard provenance",
);
assert.match(
  allocationReportSource,
  /p_dg[\s\S]*p_dmax/,
  "allocation report must expose the demand-count guard selections",
);
assert.match(
  allocationReportSource,
  /iv_demand_limit_active\s*=\s*p_dg[\s\S]*iv_max_demand_count\s*=\s*p_dmax/,
  "allocation report must pass the demand-count guard selections to the service",
);
assert.match(
  allocationReportSource,
  /demand_guard_active[\s\S]*maximum_demand_count/,
  "allocation report exports must expose demand-count guard provenance",
);
assert.match(
  allocationReportSource,
  /p_qg[\s\S]*p_qmax/,
  "allocation report must expose the requested-quantity guard selections",
);
assert.match(
  allocationReportSource,
  /iv_quantity_limit_active\s*=\s*p_qg[\s\S]*iv_max_requested_quantity\s*=\s*p_qmax/,
  "allocation report must pass the requested-quantity guard selections to the service",
);
assert.match(
  allocationReportSource,
  /quantity_guard_active[\s\S]*maximum_requested_quantity/,
  "allocation report exports must expose requested-quantity guard provenance",
);
assert.match(
  allocationReportSource,
  /p_ag[\s\S]*p_amax/,
  "allocation report must expose the allocated-quantity guard selections",
);
assert.match(
  allocationReportSource,
  /iv_allocation_limit_active\s*=\s*p_ag[\s\S]*iv_max_allocated_quantity\s*=\s*p_amax/,
  "allocation report must pass the allocated-quantity guard selections to the service",
);
assert.match(
  allocationReportSource,
  /allocation_guard_active[\s\S]*maximum_allocated_quantity/,
  "allocation report exports must expose allocated-quantity guard provenance",
);
assert.match(
  allocationReportSource,
  /p_mg[\s\S]*p_mmin/,
  "allocation report must expose the minimum-allocation guard selections",
);
assert.match(
  allocationReportSource,
  /iv_min_alloc_limit_active\s*=\s*p_mg[\s\S]*iv_min_allocated_quantity\s*=\s*p_mmin/,
  "allocation report must pass the minimum-allocation guard selections to the service",
);
assert.match(
  allocationReportSource,
  /minimum_allocation_guard_active[\s\S]*minimum_allocated_quantity/,
  "allocation report exports must expose minimum-allocation guard provenance",
);
assert.match(
  allocationReportSource,
  /p_ilg[\s\S]*p_imin/,
  "allocation report must expose the minimum-allocation-line guard selections",
);
assert.match(
  allocationReportSource,
  /iv_min_line_limit_active\s*=\s*p_ilg[\s\S]*iv_min_alloc_lines\s*=\s*p_imin/,
  "allocation report must pass the minimum-allocation-line guard selections to the service",
);
assert.match(
  allocationReportSource,
  /minimum_allocation_line_guard_active[\s\S]*minimum_allocated_lines/,
  "allocation report exports must expose minimum-allocation-line guard provenance",
);
assert.match(
  allocationReportSource,
  /p_lg[\s\S]*p_lmax/,
  "allocation report must expose the allocated-line guard selections",
);
assert.match(
  allocationReportSource,
  /iv_line_limit_active\s*=\s*p_lg[\s\S]*iv_max_alloc_lines\s*=\s*p_lmax/,
  "allocation report must pass the allocated-line guard selections to the service",
);
assert.match(
  allocationReportSource,
  /allocation_line_guard_active[\s\S]*maximum_allocated_lines/,
  "allocation report exports must expose allocated-line guard provenance",
);
assert.match(
  allocationReportSource,
  /p_spg[\s\S]*p_spmax/,
  "allocation report must expose the shortage-percentage guard selections",
);
assert.match(
  allocationReportSource,
  /iv_spct_limit_active\s*=\s*p_spg[\s\S]*iv_max_shortage_pct\s*=\s*p_spmax/,
  "allocation report must pass the shortage-percentage guard selections to the service",
);
assert.match(
  allocationReportSource,
  /shortage_pct_guard_active[\s\S]*maximum_shortage_pct/,
  "allocation report exports must expose shortage-percentage guard provenance",
);
assert.match(
  allocationReportSource,
  /p_ug[\s\S]*p_umax/,
  "allocation report must expose the unallocated-line guard selections",
);
assert.match(
  allocationReportSource,
  /iv_unalloc_limit_active\s*=\s*p_ug[\s\S]*iv_max_unalloc_lines\s*=\s*p_umax/,
  "allocation report must pass the unallocated-line guard selections to the service",
);
assert.match(
  allocationReportSource,
  /unallocated_line_guard_active[\s\S]*maximum_unallocated_lines/,
  "allocation report exports must expose unallocated-line guard provenance",
);
assert.match(
  allocationReportSource,
  /p_pg[\s\S]*p_pmax/,
  "allocation report must expose the partial-line guard selections",
);
assert.match(
  allocationReportSource,
  /iv_partial_limit_active\s*=\s*p_pg[\s\S]*iv_max_partial_lines\s*=\s*p_pmax/,
  "allocation report must pass the partial-line guard selections to the service",
);
assert.match(
  allocationReportSource,
  /partial_line_guard_active[\s\S]*maximum_partial_lines/,
  "allocation report exports must expose partial-line guard provenance",
);
assert.match(
  allocationReportSource,
  /p_slg[\s\S]*p_slmax/,
  "allocation report must expose the shortage-line guard selections",
);
assert.match(
  allocationReportSource,
  /iv_shline_limit_active\s*=\s*p_slg[\s\S]*iv_max_shortage_lines\s*=\s*p_slmax/,
  "allocation report must pass the shortage-line guard selections to the service",
);
assert.match(
  allocationReportSource,
  /shortage_line_guard_active[\s\S]*maximum_shortage_lines/,
  "allocation report exports must expose shortage-line guard provenance",
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
  /<ls_existing>-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*<ls_existing>-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*<ls_existing>-sales_document\s+CN\s+'0123456789'/,
  "allocation service must reject malformed existing sales documents",
);
assert.match(
  allocationServiceSource,
  /<ls_existing>-reservation_id\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*<ls_existing>-reservation_id\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*<ls_existing>-reservation_id\s+CN\s+'0123456789\s*'/,
  "allocation service must reject short numeric existing reservation documents",
);
assert.match(
  allocationServiceSource,
  /ls_available-batch_restricted\s+<>\s+abap_true[\s\S]*ls_available-batch_restricted\s+<>\s+abap_false[\s\S]*Available stock result is invalid/,
  "allocation service must reject noncanonical stock flags",
);
assert.match(
  allocationServiceSource,
  /iv_batch\s+IS\s+INITIAL[\s\S]*ls_available-batch_found\s*=\s*abap_true[\s\S]*ls_available-batch_restricted\s*=\s*abap_true[\s\S]*ls_available-batch_expiration_date\s+IS\s+NOT\s+INITIAL[\s\S]*Available stock result is invalid/,
  "allocation service must reject batch metadata when no batch is requested",
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
  orderUpdateReportSource,
  /lv_sales_document_type\s*=\s*to_upper\(\s*p_auart\s*\)/,
  "sales-order update reports must canonicalize the displayed order type",
);
assert.match(
  orderUpdateReportSource,
  /iv_sales_document_type\s*=\s*lv_sales_document_type/,
  "sales-order update reports must send the canonical order type",
);
assert.match(
  orderUpdateReportSource,
  /quote\(\s*lv_sales_document_type\s*\)/,
  "sales-order update report exports must expose the canonical order type",
);
assert.match(
  goodsIssueReportSource,
  /lv_unit\s*=\s*to_upper\(\s*p_meins\s*\)/,
  "goods-issue reports must canonicalize the displayed unit",
);
assert.match(
  goodsIssueReportSource,
  /iv_unit\s*=\s*lv_unit/,
  "goods-issue reports must send the canonical unit",
);
assert.match(
  goodsIssueReportSource,
  /quote\(\s*lv_unit\s*\)/,
  "goods-issue report exports must expose the canonical unit",
);

for (const [reportName, reportSource] of [
  ["allocation", allocationReportSource],
  ["stock", stockReportSource],
  ["unit conversion", conversionReportSource],
  ["reservation creation", reservationCreateReportSource],
  ["reservation cancellation", reservationCancelReportSource],
  ["goods issue", goodsIssueReportSource],
  ["sales-order update", orderUpdateReportSource],
]) {
  assert.equal(
    (reportSource.match(/iv_name\s*=\s*'schema_version'/g) ?? []).length,
    2,
    `${reportName} report must expose schema_version in typed and untyped JSON`,
  );
}
assert.match(
  stockJsonSource,
  /CLASS-METHODS\s+error_with_schema/,
  "JSON helper must expose a schema-versioned error envelope",
);
assert.match(
  stockJsonSource,
  /CLASS-METHODS\s+error_with_schema_run_id/,
  "JSON helper must preserve run IDs in schema-versioned errors",
);
assert.match(
  stockJsonSource,
  /iv_name\s*=\s*'schema_version'/,
  "JSON helper schema-versioned errors must include schema_version",
);
assert.match(
  stockCsvSource,
  /CLASS-METHODS\s+error_with_schema/,
  "CSV helper must expose a schema-versioned error envelope",
);
assert.match(
  stockCsvSource,
  /CLASS-METHODS\s+error_with_schema_run_id/,
  "CSV helper must preserve run IDs in schema-versioned errors",
);
assert.equal(
  (allocationReportSource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
  28,
  "allocation report must version all JSON error envelopes, including run-ID variants",
);
for (const [reportName, reportSource, expectedCount] of [
  ["stock", stockReportSource, 4],
  ["unit conversion", conversionReportSource, 3],
  ["reservation creation", reservationCreateReportSource, 4],
  ["reservation cancellation", reservationCancelReportSource, 4],
  ["goods issue", goodsIssueReportSource, 5],
  ["sales-order update", orderUpdateReportSource, 5],
]) {
  assert.equal(
    (reportSource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
    expectedCount,
    `${reportName} report must version all JSON error envelopes`,
  );
}
assert.match(
  readmeSource,
  /JSON and typed JSON use schema version `4`/,
  "README must document stock JSON schema parity",
);
assert.match(
  readmeSource,
  /## SAP integration checklist[\s\S]*Import the ABAP objects under `src\/`[\s\S]*do not import `sap_stubs\/`[\s\S]*ZSTOCKALLOC_RUN[\s\S]*MARD[\s\S]*MARM[\s\S]*BAPI_RESERVATION_CREATE1[\s\S]*S_TABU_NAM[\s\S]*M_MRES_BWA[\s\S]*V_VBAK_AAT[\s\S]*P_EXEC[\s\S]*npm test/,
  "README must document the SAP import, dependency, authorization, report, and verification checklist",
);
assert.doesNotMatch(
  readmeSource,
  /activity `06` for result replacement, reservation cancellation/,
  "README must not assign custom-table delete authorization to direct reservation cancellation",
);
assert.match(
  readmeSource,
  /M_MRES_BWA`\/`M_MRES_WWA` activity `01` for reservation creation and activity `06` for cancellation[\s\S]*M_MSEG_BWA`\/`M_MSEG_WWA`\/`M_MSEG_LGO` activity `01` for goods issue/,
  "README must document the operation activities enforced by reservation and goods-movement adapters",
);
assert.match(
  readmeSource,
  /Successful CSV and JSON allocation contracts now use schema version `49`/,
  "README must document allocation JSON schema parity",
);
assert.match(
  readmeSource,
  /Result detail\/summary schemas are `40`\/`46`, and comparison CSV\/contextual JSON schemas are `98`/,
  "README must document current result and comparison schemas",
);
assert.doesNotMatch(
  readmeSource,
  /Comparison summary CSV\/JSON and comparison detail CSV\/JSON metadata envelopes expose numeric `schema_version: 36`/,
  "README must not present historical comparison schema 36 as the current contract",
);

assert.match(
  stockReportSource,
  /REPORT\s+zstock_alloc_stock\./,
  "stock report must be present as a Z report",
);
assert.match(
  stockReportSource,
  /lo_source->get_available\(/,
  "stock report must use the stock-source contract",
);
assert.match(
  stockReportSource,
  /mode;generated_date;generated_time;schema_version;material;plant;[\s\S]*storage_location;batch;quantity;unit;[\s\S]*base_quantity;base_unit;[\s\S]*target_unit;converted;[\s\S]*minimum_quantity;minimum_threshold_active;[\s\S]*minimum_threshold_evaluated;below_minimum;maximum_quantity;[\s\S]*maximum_threshold_active;maximum_threshold_evaluated;above_maximum;[\s\S]*availability_status;[\s\S]*material_found;batch_managed;/,
  "stock report CSV output must expose the availability contract",
);
assert.match(
  stockReportSource,
  /PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit\.[\s\S]*zcl_unit_conversion_auth_sap[\s\S]*zcl_unit_conversion_sap[\s\S]*io_authority\s*=\s*lo_authority[\s\S]*lv_output_quantity\s*=\s*lo_converter->convert\(/,
  "stock report must use the authorized unit-conversion path for an output unit",
);
assert.match(
  stockReportSource,
  /PARAMETERS p_min TYPE zif_stock_allocation=>ty_quantity DEFAULT 0\.[\s\S]*lv_minimum_evaluated[\s\S]*lv_output_quantity < p_min[\s\S]*below_minimum/,
  "stock report must evaluate the minimum threshold after output conversion",
);
assert.match(
  stockReportSource,
  /PARAMETERS p_max TYPE zif_stock_allocation=>ty_quantity DEFAULT 0\.[\s\S]*lv_maximum_evaluated[\s\S]*lv_output_quantity > p_max[\s\S]*above_maximum/,
  "stock report must evaluate the maximum threshold after output conversion",
);
assert.match(
  stockReportSource,
  /p_min > 0 AND p_max > 0 AND p_min > p_max[\s\S]*Minimum output quantity cannot exceed maximum output quantity/,
  "stock report must reject an inverted active output range",
);
assert.match(
  stockReportSource,
  /iv_name\s*=\s*'base_quantity'[\s\S]*iv_name\s*=\s*'base_unit'[\s\S]*iv_name\s*=\s*'target_unit'[\s\S]*iv_name\s*=\s*'converted'/,
  "stock report JSON must expose quantity conversion provenance",
);
assert.match(
  stockReportSource,
  /iv_name\s*=\s*'schema_version'[\s\S]*iv_value\s*=\s*4/,
  "stock report JSON must publish schema version 4",
);
assert.match(
  stockReportSource,
  /iv_name\s*=\s*'minimum_quantity'[\s\S]*iv_name\s*=\s*'minimum_threshold_active'[\s\S]*iv_name\s*=\s*'minimum_threshold_evaluated'[\s\S]*iv_name\s*=\s*'below_minimum'[\s\S]*iv_name\s*=\s*'availability_status'/,
  "stock report JSON must expose threshold decision provenance",
);
assert.match(
  stockReportSource,
  /iv_name\s*=\s*'maximum_quantity'[\s\S]*iv_name\s*=\s*'maximum_threshold_active'[\s\S]*iv_name\s*=\s*'maximum_threshold_evaluated'[\s\S]*iv_name\s*=\s*'above_maximum'/,
  "stock report JSON must expose maximum-threshold provenance",
);
assert.match(
  stockReportSource,
  /iv_name\s*=\s*'typed'[\s\S]*iv_name\s*=\s*'quantity'[\s\S]*iv_name\s*=\s*'material_found'/,
  "stock report typed JSON must expose numeric and boolean availability fields",
);
assert.match(
  reservationCancelReportSource,
  /REPORT\s+zstock_alloc_res_cancel\./,
  "reservation cancellation report must be present as a Z report",
);
assert.match(
  reservationCancelReportSource,
  /IF p_exec <> abap_true[\s\S]*Select P_EXEC to cancel the reservation/,
  "reservation cancellation report must require explicit execution",
);
assert.match(
  reservationCancelReportSource,
  /lo_reservation->cancel\([\s\S]*iv_document\s*=\s*p_resid[\s\S]*iv_plant\s*=\s*p_werks[\s\S]*iv_movement_type\s*=\s*p_bwart/,
  "reservation cancellation report must pass the complete cancellation scope",
);
assert.match(
  reservationCancelReportSource,
  /mode;generated_date;generated_time;schema_version;[\s\S]*reservation_document;plant;movement_type;status;message/,
  "reservation cancellation report must expose a stable machine-readable contract",
);
assert.match(
  reservationCreateReportSource,
  /REPORT\s+zstock_alloc_reserve\./,
  "reservation creation report must be present as a Z report",
);
assert.match(
  reservationCreateReportSource,
  /IF p_exec <> abap_true[\s\S]*Select P_EXEC to create the reservation/,
  "reservation creation report must require explicit execution",
);
assert.match(
  reservationCreateReportSource,
  /lv_unit\s*=\s*to_upper\(\s*p_meins\s*\)/,
  "reservation creation report must canonicalize its unit",
);
assert.match(
  reservationCreateReportSource,
  /lv_document\s*=\s*lo_reservation->reserve\([\s\S]*iv_material\s*=\s*p_matnr[\s\S]*iv_required_date\s*=\s*p_reqdt[\s\S]*iv_batch\s*=\s*p_charg/,
  "reservation creation report must pass the complete reservation scope",
);
assert.match(
  reservationCreateReportSource,
  /mode;generated_date;generated_time;schema_version;material;plant;'[\s\S]*reservation_document;status;message/,
  "reservation creation report must expose a stable machine-readable contract",
);
for (const [reportName, reportSource, executionMessage] of [
  [
    "reservation create",
    reservationCreateReportSource,
    "Select P_EXEC to create the reservation",
  ],
  [
    "reservation cancel",
    reservationCancelReportSource,
    "Select P_EXEC to cancel the reservation",
  ],
  [
    "goods issue",
    goodsIssueReportSource,
    "Select P_EXEC to execute the goods issue",
  ],
  [
    "sales-order update",
    orderUpdateReportSource,
    "Select P_EXEC to execute the sales-order update",
  ],
]) {
  assert.match(
    reportSource,
    /PARAMETERS p_exec AS CHECKBOX\./,
    `${reportName} report must expose an explicit execution switch`,
  );
  assert.match(
    reportSource,
    new RegExp(
      `IF p_exec <> abap_true[\\s\\S]*${executionMessage}[\\s\\S]*RETURN\\.`,
    ),
    `${reportName} report must stop before the SAP mutation when execution is not selected`,
  );
}
assert.match(
  goodsIssueReportSource,
  /CREATE OBJECT lo_authority TYPE zcl_stock_move_auth_sap[\s\S]*CREATE OBJECT lo_movement TYPE zcl_stock_movement_sap[\s\S]*io_authority\s*=\s*lo_authority/,
  "goods-issue report must inject the SAP movement authority into its adapter",
);
assert.match(
  orderUpdateReportSource,
  /CREATE OBJECT lo_authority TYPE zcl_order_sink_authority_sap[\s\S]*CREATE OBJECT lo_sink TYPE zcl_order_sink_sap[\s\S]*io_authority\s*=\s*lo_authority/,
  "sales-order report must inject the SAP order authority into its adapter",
);
for (const [adapterName, adapterSource, authorityCall] of [
  ["goods movement", movementSource, "check"],
  ["sales-order change", orderSinkSource, "check"],
  ["reservation create/cancel", reservationSource, "check"],
]) {
  assert.match(
    adapterSource,
    new RegExp(`mo_authority->${authorityCall}\\(`),
    `${adapterName} adapter must check authorization before its BAPI call`,
  );
  assert.match(
    adapterSource,
    /CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'/,
    `${adapterName} adapter must commit successful BAPI work`,
  );
  assert.match(
    adapterSource,
    /CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'/,
    `${adapterName} adapter must rollback failed BAPI work`,
  );
  assert.match(
    adapterSource,
    /CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'[\s\S]*IMPORTING[\s\S]*return\s*=\s*ls_commit_return[\s\S]*EXCEPTIONS/,
    `${adapterName} adapter must import the SAP transaction-commit return structure`,
  );
  assert.match(
    adapterSource,
    /ls_commit_return-type\s+IS\s+NOT\s+INITIAL[\s\S]*ls_commit_return-type\s+<>\s+'S'[\s\S]*ls_commit_return-type\s+<>\s+'X'/,
    `${adapterName} adapter must reject noncanonical transaction-commit return statuses`,
  );
  assert.match(
    adapterSource,
    /CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'[\s\S]*IMPORTING[\s\S]*return\s*=\s*ls_rollback_return[\s\S]*EXCEPTIONS/,
    `${adapterName} adapter must import the SAP transaction-rollback return structure`,
  );
  assert.match(
    adapterSource,
    /ls_rollback_return-type\s+IS\s+NOT\s+INITIAL[\s\S]*ls_rollback_return-type\s+<>\s+'S'[\s\S]*ls_rollback_return-type\s+<>\s+'X'/,
    `${adapterName} adapter must reject noncanonical transaction-rollback return statuses`,
  );
}
assert.match(
  transactionAdapterSource,
  /CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'[\s\S]*IMPORTING[\s\S]*return\s*=\s*ls_return[\s\S]*EXCEPTIONS/,
  "SAP transaction adapter must import the transaction-commit return structure",
);
assert.match(
  transactionAdapterSource,
  /ls_return-type\s+IS\s+NOT\s+INITIAL[\s\S]*ls_return-type\s+<>\s+'S'[\s\S]*ls_return-type\s+<>\s+'X'/,
  "SAP transaction adapter must reject noncanonical transaction-commit return statuses",
);
assert.match(
  transactionAdapterSource,
  /CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'[\s\S]*IMPORTING[\s\S]*return\s*=\s*ls_return[\s\S]*EXCEPTIONS/,
  "SAP transaction adapter must import the explicit transaction-rollback return structure",
);
assert.match(
  transactionAdapterSource,
  /ls_return-type\s+IS\s+NOT\s+INITIAL[\s\S]*ls_return-type\s+<>\s+'S'[\s\S]*ls_return-type\s+<>\s+'X'/,
  "SAP transaction adapter must reject noncanonical explicit transaction-rollback return statuses",
);
assert.match(
  reservationSource,
  /mo_authority->check_cancel\(/,
  "reservation cancellation must use its dedicated cancellation authority check",
);
assert.match(
  conversionReportSource,
  /REPORT\s+zstock_alloc_convert\./,
  "unit conversion report must be present as a Z report",
);
assert.match(
  conversionReportSource,
  /lv_unit_from\s*=\s*to_upper\(\s*p_from\s*\)[\s\S]*lv_unit_to\s*=\s*to_upper\(\s*p_to\s*\)/,
  "unit conversion report must canonicalize both unit inputs",
);
assert.match(
  conversionReportSource,
  /lo_converter->convert\([\s\S]*iv_material\s*=\s*p_matnr[\s\S]*iv_unit_from\s*=\s*lv_unit_from[\s\S]*iv_unit_to\s*=\s*lv_unit_to/,
  "unit conversion report must use the conversion contract",
);
assert.match(
  conversionReportSource,
  /mode;generated_date;generated_time;schema_version;material;'[\s\S]*converted_quantity;status;message/,
  "unit conversion report must expose a stable machine-readable contract",
);
assert.match(
  conversionReportSource,
  /iv_name\s*=\s*'typed'[\s\S]*iv_name\s*=\s*'quantity'[\s\S]*iv_name\s*=\s*'converted_quantity'/,
  "unit conversion typed JSON must expose numeric quantities",
);
assert.match(
  allocationReportSource,
  /lv_unit\s*=\s*to_upper\(\s*p_meins\s*\)/,
  "allocation reports must canonicalize the displayed unit",
);
assert.match(
  allocationReportSource,
  /iv_unit\s*=\s*lv_unit/,
  "allocation reports must send the canonical unit",
);
assert.match(
  allocationReportSource,
  /quote\(\s*lv_unit\s*\)/,
  "allocation report exports must expose the canonical unit",
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
  /is_demand-reservation_id\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*is_demand-reservation_id\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*is_demand-reservation_id\s+CN\s+'0123456789\s*'/,
  "allocation snapshots must reject malformed reservation documents",
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
  /strlen\(\s*ls_demand-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*ls_demand-sales_document\s+CN\s+'0123456789'/,
  "SAP order reads must enforce the exact ten-character numeric document contract",
);
assert.match(
  allocationServiceSource,
  /<ls_demand>-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*<ls_demand>-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*<ls_demand>-sales_document\s+CN\s+'0123456789'/,
  "allocation service must reject malformed sales documents",
);
assert.match(
  allocationSinkSource,
  /is_demand-sales_document\s+IS\s+NOT\s+INITIAL[\s\S]*strlen\(\s*is_demand-sales_document\s*\)\s*<>\s*zif_stock_allocation=>c_sap_document_length[\s\S]*is_demand-sales_document\s+CN\s+'0123456789'/,
  "allocation snapshots must reject malformed sales documents",
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
  reservationSource,
  /iv_movement_type\s*=\s*zif_stock_allocation=>c_zero_movement_type/,
  "reservation BAPI adapter must reject the zero movement-type sentinel",
);
assert.match(
  movementSource,
  /strlen\(\s*iv_movement_type\s*\)\s*<>\s*zif_stock_allocation=>c_movement_type_length[\s\S]*iv_movement_type\s+CN\s+'0123456789'/,
  "goods-movement BAPI adapter must enforce the exact three-character movement-type contract",
);
assert.match(
  movementSource,
  /iv_movement_type\s*=\s*zif_stock_allocation=>c_zero_movement_type/,
  "goods-movement BAPI adapter must reject the zero movement-type sentinel",
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
  /ty_movement_type\s+TYPE\s+c\s+LENGTH\s+3[\s\S]*c_movement_type_length\s+TYPE\s+i\s+VALUE\s+3[\s\S]*c_zero_movement_type\s+TYPE\s+ty_movement_type\s+VALUE\s+'000'/,
  "the shared movement-type contract must define a three-character length and zero sentinel",
);
assert.match(
  auditSource,
  /iv_movement_type\s*=\s*zif_stock_allocation=>c_zero_movement_type/,
  "audit movement-type boundaries must reject the zero sentinel",
);
assert.match(
  allocationSinkSource,
  /iv_movement_type\s*=\s*zif_stock_allocation=>c_zero_movement_type/,
  "allocation result movement-type boundaries must reject the zero sentinel",
);
assert.match(
  allocationServiceSource,
  /iv_movement_type\s*=\s*zif_stock_allocation=>c_zero_movement_type/,
  "allocation service movement-type boundaries must reject the zero sentinel",
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
  auditSource,
  /available_context\s*=\s*<ls_run>-available[\s\S]*available_context_ok|mixed_available/,
  "audit summaries must classify a consistent available-stock context",
);
assert.match(
  auditSource,
  /rs_summary-available_context_ok\s*=\s*abap_false[\s\S]*rs_summary-mixed_available\s*=\s*abap_true/,
  "audit summaries must suppress mixed available-stock context",
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
  /PARAMETERS p_prev TYPE zif_allocation_audit=>ty_preview_filter\./,
  "health must expose a preview provenance filter",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id\./,
  "health must expose an exact run-ID filter",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_rid TYPE zif_allocation_audit=>ty_run_id\./,
  "health must expose a run-ID fragment filter",
);
assert.equal(
  (healthReportSource.match(/iv_run_id\s+= p_runid/g) ?? []).length,
  2,
  "health must propagate the exact run-ID filter to both summary reads",
);
assert.equal(
  (healthReportSource.match(/iv_run_id_contains\s+= p_rid/g) ?? []).length,
  2,
  "health must propagate the run-ID fragment filter to both summary reads",
);
assert.match(
  healthReportSource,
  /iv_status\s+= p_stat/,
  "health must propagate the audit status filter to audit reads",
);
assert.match(
  healthReportSource,
  /iv_preview_filter\s+= p_prev/,
  "health must propagate the preview provenance filter to audit reads",
);
assert.match(
  healthReportSource,
  /status_filter/,
  "health machine-readable output must expose audit status provenance",
);
assert.match(
  healthReportSource,
  /preview_filter/,
  "health machine-readable output must expose preview provenance",
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
  /rs_health-last_requested_on_from\s*=\s*is_summary-last_requested_on_from[\s\S]*rs_health-last_requested_on_to\s*=\s*is_summary-last_requested_on_to[\s\S]*rs_health-last_requested_deadline\s*=\s*is_summary-last_requested_deadline/,
  "health evaluator must propagate the latest requested horizon",
);
assert.match(
  healthReportSource,
  /last_requested_on_from|last_requested_on_to|last_requested_deadline/,
  "health report must expose the latest requested horizon",
);
assert.match(
  healthSource,
  /rs_health-deadline_age_reference_date\s*=\s*is_summary-deadline_age_reference_date/,
  "health evaluator must propagate deadline-age provenance",
);
assert.match(
  healthReportSource,
  /iv_value = 116 \) TO lt_json_fields/,
  "health JSON schema must include the preview-filter contract version",
);
assert.match(
  readmeSource,
  /Health JSON errors use schema `116`, matching the successful health envelope\./,
  "README must document the current health JSON error schema",
);
assert.match(
  healthSource,
  /last_line_rates_available|last_full_line_pct|last_partial_line_pct|last_unallocated_line_pct/,
  "health evaluator must expose latest line-rate telemetry",
);
assert.match(
  healthReportSource,
  /last_line_rates_available|last_full_line_pct|last_partial_line_pct|last_unallocated_line_pct/,
  "health report must expose latest line-rate telemetry",
);
assert.match(
  healthSource,
  /last_shortage_pct_available|last_shortage_pct/,
  "health evaluator must expose latest shortage-rate telemetry",
);
assert.match(
  healthReportSource,
  /last_shortage_pct_available|last_shortage_pct/,
  "health report must expose latest shortage-rate telemetry",
);
assert.match(
  healthSource,
  /last_age_available|last_age_seconds/,
  "health evaluator must expose latest completed-age telemetry",
);
assert.match(
  healthReportSource,
  /last_age_available|last_age_seconds/,
  "health report must expose latest completed-age telemetry",
);
assert.match(
  healthSource,
  /last_completed_run_id|last_completed_finish_date|last_completed_status/,
  "health evaluator must expose latest completed-run context",
);
assert.match(
  healthReportSource,
  /last_completed_run_available|last_completed_run_id|last_completed_finish_date|last_completed_duration_seconds/,
  "health report must expose latest completed-run context",
);
assert.match(
  healthSource,
  /last_completed_requested|last_completed_allocated|last_completed_shortage|last_completed_coverage/,
  "health evaluator must expose latest completed allocation outcome",
);
assert.match(
  healthReportSource,
  /last_completed_requested|last_completed_allocated|last_completed_shortage|last_completed_coverage_pct|last_completed_full_line_count/,
  "health report must expose latest completed allocation outcome",
);
assert.match(
  healthSource,
  /last_completed_shortage_pct_available|last_completed_shortage_pct|last_completed_line_rates_available/,
  "health evaluator must expose latest completed normalized rates",
);
assert.match(
  healthReportSource,
  /last_completed_shortage_pct_available|last_completed_shortage_pct|last_completed_full_line_pct|last_completed_unallocated_line_pct/,
  "health report must expose latest completed normalized rates",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'material'[\s\S]*iv_name\s*=\s*'plant'[\s\S]*iv_name\s*=\s*'storage_location'[\s\S]*iv_name\s*=\s*'batch'/,
  "health JSON must expose selected material, plant, storage, and batch provenance",
);
assert.match(
  healthReportSource,
  /mode;schema_version;status;message;reason_code;material;plant;[\s\S]*storage_location;batch;movement_type_filter;unit_filter;/,
  "health CSV must expose selected scope and movement/unit filter provenance",
);
assert.match(
  healthReportSource,
  /'Material:',\s*p_matnr,[\s\S]*'Plant:',\s*p_werks,[\s\S]*'Storage location:',\s*p_lgort,[\s\S]*'Batch:',\s*p_charg,[\s\S]*'Movement type filter:',\s*p_mvt,[\s\S]*'Unit filter:',\s*p_meins/,
  "health human output must expose selected scope and movement/unit filter provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'minimum_shelf_life_filter'[\s\S]*iv_name\s*=\s*'safety_stock_filter'[\s\S]*iv_name\s*=\s*'minimum_safety_stock_filter'[\s\S]*iv_name\s*=\s*'maximum_safety_stock_filter'[\s\S]*iv_name\s*=\s*'requested_on_from_filter'[\s\S]*iv_name\s*=\s*'requested_on_to_filter'/,
  "health JSON must expose shelf-life, safety-stock, and requested-horizon provenance",
);
assert.match(
  healthReportSource,
  /minimum_shelf_life_filter;[\s\S]*safety_stock_filter;[\s\S]*minimum_safety_stock_filter;[\s\S]*maximum_safety_stock_filter;[\s\S]*requested_on_from_filter;[\s\S]*requested_on_to_filter;/,
  "health CSV must expose shelf-life, safety-stock, and requested-horizon provenance",
);
assert.match(
  healthReportSource,
  /'Minimum shelf life:',\s*p_shelf,[\s\S]*'Safety-stock filter:',\s*p_safon,[\s\S]*'Minimum safety stock:',\s*p_saf,[\s\S]*'Maximum safety stock:',\s*p_safto,[\s\S]*'Requested delivery from:',\s*p_reqf,[\s\S]*'Requested delivery to:',\s*p_until/,
  "health human output must expose shelf-life, safety-stock, and requested-horizon provenance",
);
assert.match(
  healthSource,
  /policy_context_available|mixed_policies|movement_type_context|minimum_shelf_life_context|safety_stock_context/,
  "health evaluator must expose actual policy-context telemetry",
);
assert.match(
  healthSource,
  /is_summary-policy_context_available|is_summary-mixed_policies|is_summary-movement_type_context|is_summary-min_shelf_life_context|is_summary-safety_stock_context/,
  "health evaluator must propagate actual policy context from the audit summary",
);
assert.match(
  healthReportSource,
  /policy_context_available|mixed_policies|movement_type_context|minimum_shelf_life_context|safety_stock_context/,
  "health report must expose actual policy-context telemetry",
);
assert.match(
  healthSource,
  /mixed_units/,
  "health evaluator must expose mixed-unit state",
);
assert.match(
  healthReportSource,
  /mixed_units/,
  "health report must expose mixed-unit state",
);
assert.match(
  healthSource,
  /available_stock_context_available|available_stock_context|mixed_available_stock/,
  "health evaluator must expose available-stock context telemetry",
);
assert.match(
  healthSource,
  /is_summary-available_context_ok|is_summary-available_context|is_summary-mixed_available/,
  "health evaluator must propagate available-stock context from the audit summary",
);
assert.match(
  healthReportSource,
  /available_stock_context_available|available_stock_context|mixed_available_stock/,
  "health report must expose available-stock context telemetry",
);
assert.match(
  healthSource,
  /stale_threshold_active|stale_threshold|stale_above_threshold/,
  "health evaluator must expose stale-threshold state",
);
assert.match(
  healthSource,
  /iv_stale_threshold|stale_above_threshold[\s\S]*lv_stale/,
  "health evaluator must derive stale-threshold breach state",
);
assert.match(
  healthReportSource,
  /p_stale|stale_threshold_seconds|stale_above_threshold/,
  "health report must expose stale-threshold provenance",
);
assert.match(
  healthSource,
  /coverage_threshold\s*=\s*iv_min_coverage|shortage_threshold\s*=\s*iv_max_shortage_pct/,
  "health evaluator must retain configured percentage thresholds",
);
assert.match(
  healthReportSource,
  /coverage_threshold|shortage_threshold/,
  "health report must expose configured percentage thresholds",
);
assert.match(
  healthSource,
  /rs_health-success_runs\s*=\s*is_summary-success_runs/,
  "health evaluator must propagate successful-run counts",
);
assert.match(
  healthReportSource,
  /success_runs/,
  "health report must expose successful-run counts",
);
assert.match(
  healthSource,
  /rs_health-completion_pct\s*=\s*is_summary-completion_pct/,
  "health evaluator must propagate completion percentage",
);
assert.match(
  healthSource,
  /rs_health-success_rate_pct\s*=\s*is_summary-success_rate_pct/,
  "health evaluator must propagate success rate",
);
assert.match(
  healthReportSource,
  /completion_pct|success_rate_pct|partial_rate_pct|error_rate_pct/,
  "health report must expose run-quality rates",
);
assert.match(
  healthSource,
  /rs_health-demand_count\s*=\s*is_summary-demand_count[\s\S]*rs_health-full_count\s*=\s*is_summary-full_count[\s\S]*rs_health-partial_count\s*=\s*is_summary-partial_count[\s\S]*rs_health-unallocated_count\s*=\s*is_summary-unallocated_count/,
  "health evaluator must propagate line-outcome counts",
);
assert.match(
  healthReportSource,
  /demand_count[\s\S]*full_count[\s\S]*partial_count[\s\S]*unallocated_count/,
  "health report must expose line-outcome counts",
);
assert.match(
  healthSource,
  /rs_health-full_line_pct\s*=\s*is_summary-full_count\s*\*\s*100[\s\S]*rs_health-partial_line_pct\s*=\s*is_summary-partial_count\s*\*\s*100[\s\S]*rs_health-unallocated_line_pct\s*=\s*is_summary-unallocated_count\s*\*\s*100/,
  "health evaluator must calculate line-outcome rates",
);
assert.match(
  healthReportSource,
  /full_line_pct[\s\S]*partial_line_pct[\s\S]*unallocated_line_pct/,
  "health report must expose line-outcome rates",
);
assert.match(
  healthSource,
  /full_line_threshold_active|full_line_threshold|full_line_below_threshold/,
  "health evaluator must expose full-line-rate threshold state",
);
assert.match(
  healthSource,
  /iv_min_full_line_rate|full_line_below_threshold[\s\S]*demand_count > 0/,
  "health evaluator must apply a zero-demand-safe full-line-rate threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_flmin|minimum_full_line_rate|full_line_threshold|full_line_below_threshold/,
  "health report must expose full-line-rate threshold provenance",
);
assert.match(
  healthSource,
  /unallocated_line_threshold_active|unallocated_line_threshold|unallocated_line_above_threshold/,
  "health evaluator must expose unallocated-line-rate threshold state",
);
assert.match(
  healthSource,
  /iv_max_unalloc_line_rate|unallocated_line_above_threshold[\s\S]*demand_count > 0/,
  "health evaluator must apply a zero-demand-safe unallocated-line-rate threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_ulmax|maximum_unallocated_line_rate|unallocated_line_threshold|unallocated_line_above_threshold/,
  "health report must expose unallocated-line-rate threshold provenance",
);
assert.match(
  healthSource,
  /partial_line_threshold_active|partial_line_threshold|partial_line_above_threshold/,
  "health evaluator must expose partial-line-rate threshold state",
);
assert.match(
  healthSource,
  /iv_max_partial_line_rate|partial_line_above_threshold[\s\S]*demand_count > 0/,
  "health evaluator must apply a zero-demand-safe partial-line-rate threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_plmax|maximum_partial_line_rate|partial_line_threshold|partial_line_above_threshold/,
  "health report must expose partial-line-rate threshold provenance",
);
assert.match(
  healthSource,
  /full_count_threshold_active|full_count_threshold|full_count_below_threshold/,
  "health evaluator must expose full-line-count threshold state",
);
assert.match(
  healthSource,
  /iv_min_full_line_count|full_count_below_threshold[\s\S]*demand_count > 0/,
  "health evaluator must apply a zero-demand-safe full-line-count threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_flcnt|minimum_full_line_count|full_count_threshold|full_count_below_threshold/,
  "health report must expose full-line-count threshold provenance",
);
assert.match(
  healthSource,
  /demand_count_threshold_active|demand_count_threshold|demand_count_above_threshold/,
  "health evaluator must expose demand-count threshold state",
);
assert.match(
  healthSource,
  /iv_max_demand_count|demand_count_above_threshold[\s\S]*iv_max_demand_count/,
  "health evaluator must apply a demand-count threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_dmax|maximum_demand_count_threshold|demand_count_threshold|demand_count_above_threshold/,
  "health report must expose demand-count threshold provenance",
);
assert.match(
  healthSource,
  /running_count_threshold_active|running_count_threshold|running_count_above_threshold/,
  "health evaluator must expose running-count threshold state",
);
assert.match(
  healthSource,
  /iv_max_running_count|running_count_above_threshold[\s\S]*iv_max_running_count/,
  "health evaluator must apply a maximum running-count threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_rmax|maximum_running_count_threshold|running_count_threshold|running_count_above_threshold/,
  "health report must expose running-count threshold provenance",
);
assert.match(
  healthSource,
  /shortage_quantity_threshold_active|shortage_quantity_threshold|shortage_quantity_above_threshold/,
  "health evaluator must expose shortage-quantity threshold state",
);
assert.match(
  healthSource,
  /iv_max_shortage_quantity|shortage_quantity_above_threshold[\s\S]*shortage_available = abap_true/,
  "health evaluator must apply a mixed-unit-safe shortage-quantity threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_shmax|maximum_shortage_quantity_threshold|shortage_quantity_threshold|shortage_quantity_above_threshold/,
  "health report must expose shortage-quantity threshold provenance",
);
assert.match(
  healthSource,
  /avail_stock_min_threshold_active|avail_stock_min_threshold|avail_stock_below_threshold/,
  "health evaluator must expose minimum available-stock threshold state",
);
assert.match(
  healthSource,
  /iv_min_available_stock|avail_stock_below_threshold[\s\S]*available_stock_context_available = abap_true/,
  "health evaluator must apply a comparable-context-safe minimum available-stock threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_avmin|minimum_available_stock_threshold|available_stock_min_threshold|available_stock_below_threshold/,
  "health report must expose minimum available-stock threshold provenance",
);
assert.match(
  healthSource,
  /avail_stock_max_threshold_active|avail_stock_max_threshold|avail_stock_above_threshold/,
  "health evaluator must expose maximum available-stock threshold state",
);
assert.match(
  healthSource,
  /iv_max_available_stock|avail_stock_above_threshold[\s\S]*available_stock_context_available = abap_true/,
  "health evaluator must apply a comparable-context-safe maximum available-stock threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_avmax|maximum_available_stock_threshold|available_stock_max_threshold|available_stock_above_threshold/,
  "health report must expose maximum available-stock threshold provenance",
);
assert.match(
  healthSource,
  /rs_health-legacy_runs\s*=\s*is_summary-legacy_strategy_runs/,
  "health evaluator must propagate legacy-strategy run counts",
);
assert.match(
  healthSource,
  /rs_health-legacy_requested\s*=\s*is_summary-legacy_requested/,
  "health evaluator must propagate legacy-strategy quantities",
);
assert.match(
  healthReportSource,
  /legacy_runs|legacy_requested|legacy_coverage_pct/,
  "health report must expose legacy-strategy telemetry",
);
assert.match(
  healthSource,
  /rs_health-priority_runs\s*=\s*is_summary-priority_runs/,
  "health evaluator must propagate priority strategy counts",
);
assert.match(
  healthSource,
  /rs_health-best_runs\s*=\s*is_summary-best_runs/,
  "health evaluator must propagate best-fit strategy counts",
);
assert.match(
  healthReportSource,
  /priority_runs|fifo_runs|full_only_runs|smallest_runs|largest_runs|best_runs/,
  "health report must expose core strategy mix counts",
);
assert.match(
  healthSource,
  /rs_health-priority_requested\s*=\s*is_summary-priority_requested/,
  "health evaluator must propagate priority strategy quantities",
);
assert.match(
  healthSource,
  /rs_health-best_coverage\s*=\s*is_summary-best_coverage/,
  "health evaluator must propagate best-fit strategy coverage",
);
assert.match(
  healthReportSource,
  /priority_requested|fifo_requested|full_only_requested|smallest_requested|largest_requested|best_requested/,
  "health report must expose core strategy quantity telemetry",
);
assert.match(
  healthSource,
  /rs_health-last_run_id\s*=\s*is_summary-last_run_id/,
  "health evaluator must propagate the latest run identity",
);
assert.match(
  healthSource,
  /rs_health-average_duration_seconds\s*=\s*is_summary-average_duration_seconds/,
  "health evaluator must propagate duration aggregates",
);
assert.match(
  healthSource,
  /rs_health-oldest_running_run_id\s*=\s*is_summary-oldest_running_run_id/,
  "health evaluator must propagate oldest running identity",
);
assert.match(
  healthReportSource,
  /last_run_available|last_run_id|last_duration_seconds|average_duration_seconds|oldest_running_run_id|newest_running_run_id/,
  "health report must expose recency and performance telemetry",
);
assert.match(
  healthSource,
  /last_available_stock\s*=\s*is_summary-last_avail|last_available_stock_available/,
  "health evaluator must expose latest available-stock telemetry",
);
assert.match(
  healthReportSource,
  /last_available_stock_available|last_available_stock_unit|last_available_stock/,
  "health report must expose latest available-stock telemetry",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_lcov|minimum_last_coverage|last_coverage_threshold|last_coverage_below_threshold/,
  "health report must expose latest-run coverage threshold provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_lshmax|maximum_last_shortage_quantity|last_shortage_quantity_threshold|last_shortage_quantity_above_threshold/,
  "health report must expose latest-run shortage threshold provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_lspct|maximum_last_shortage_pct|last_shortage_pct_threshold|last_shortage_pct_above_threshold/,
  "health report must expose latest-run shortage-percentage threshold provenance",
);
assert.match(
  healthSource,
  /iv_max_last_age|last_age_above_threshold|last_age_reason/,
  "health evaluator must support latest-run age threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_lage|maximum_last_age|last_age_threshold|last_age_above_threshold|last_age_reason/,
  "health report must expose latest-run age threshold provenance",
);
assert.match(
  healthSource,
  /iv_max_last_completed_deadline_age|last_completed_deadline_age_above_threshold/,
  "health evaluator must support latest-completed deadline-age threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cdag|maximum_last_completed_deadline_age|last_completed_deadline_age_threshold|last_completed_deadline_age_above_threshold/,
  "health report must expose latest-completed deadline-age threshold provenance",
);
assert.match(
  healthSource,
  /iv_max_last_completed_demand_count|last_completed_demand_count_above_threshold/,
  "health evaluator must support latest-completed demand-count threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cdmax|maximum_last_completed_demand_count|last_completed_demand_count_threshold|last_completed_demand_count_above_threshold/,
  "health report must expose latest-completed demand-count threshold provenance",
);
assert.match(
  healthReportSource,
  /last_age_reference_date|last_age_reference_time/,
  "health report must expose the age calculation reference timestamp",
);
assert.match(
  auditInterfaceSource,
  /last_completed_run_id|last_completed_finish_date|last_completed_status/,
  "audit summary must expose latest completed-run context",
);
assert.match(
  auditSource,
  /last_completed_run_id|last_completed_finish_date|last_completed_status/,
  "audit implementation must derive latest completed-run context",
);
assert.match(
  auditSource,
  /lt_completed_runs|last_completed_success_streak|last_completed_non_success_streak|SORT lt_completed_runs/,
  "audit summary must calculate completed run-quality streaks",
);
assert.match(
  auditInterfaceSource,
  /last_completed_requested|last_completed_allocated|last_completed_shortage|last_completed_coverage/,
  "audit summary must expose latest completed allocation outcome",
);
assert.match(
  auditSource,
  /last_completed_requested|last_completed_allocated|last_completed_shortage|last_completed_coverage/,
  "audit implementation must derive latest completed allocation outcome",
);
assert.match(
  auditInterfaceSource,
  /last_completed_avail|last_completed_avail_unit|last_completed_avail_ok/,
  "audit summary must expose latest completed available-stock context",
);
assert.match(
  auditSource,
  /last_completed_avail|last_completed_avail_unit|last_completed_avail_ok/,
  "audit implementation must derive latest completed available-stock context",
);
assert.match(
  auditInterfaceSource,
  /last_completed_message/,
  "audit summary must expose the latest completed diagnostic message",
);
assert.match(
  auditSource,
  /last_completed_message\s*=\s*<ls_run>-message/,
  "audit implementation must derive the latest completed diagnostic message",
);
assert.match(
  auditInterfaceSource,
  /last_completed_start_date|last_completed_start_time/,
  "audit summary must expose latest completed start timestamp",
);
assert.match(
  auditSource,
  /last_completed_start_date\s*=\s*<ls_run>-start_date[\s\S]*last_completed_start_time\s*=\s*<ls_run>-start_time/,
  "audit implementation must derive latest completed start timestamp",
);
assert.match(
  auditInterfaceSource,
  /last_completed_policy_available|last_completed_movement_type|last_completed_min_shelf_life|last_completed_safety_stock/,
  "audit summary must expose latest completed policy context",
);
assert.match(
  auditSource,
  /last_completed_policy_available\s*=\s*abap_true[\s\S]*last_completed_movement_type\s*=\s*<ls_run>-movement_type[\s\S]*last_completed_min_shelf_life\s*=\s*<ls_run>-min_shelf_life[\s\S]*last_completed_safety_stock\s*=\s*<ls_run>-safety_stock/,
  "audit implementation must derive latest completed policy context",
);
assert.match(
  auditInterfaceSource,
  /last_completed_horizon_available|last_completed_requested_on_from|last_completed_requested_on_to|last_completed_requested_deadline/,
  "audit summary must expose latest completed requested horizon",
);
assert.match(
  auditSource,
  /last_completed_horizon_available\s*=\s*abap_true[\s\S]*last_completed_requested_on_from\s*=\s*<ls_run>-requested_on_from[\s\S]*last_completed_requested_on_to\s*=\s*<ls_run>-requested_on_to[\s\S]*last_completed_requested_deadline\s*=\s*<ls_run>-requested_deadline/,
  "audit implementation must derive latest completed requested horizon",
);
assert.match(
  auditInterfaceSource,
  /last_completed_deadline_age_available|last_completed_deadline_age_days|last_completed_deadline_age_reason/,
  "audit summary must expose latest completed deadline age",
);
assert.match(
  auditSource,
  /last_completed_deadline_age_available\s*=\s*abap_true[\s\S]*last_completed_deadline_age_days\s*=\s*lv_deadline_age_reference_date/,
  "audit implementation must derive latest completed deadline age",
);
assert.match(
  healthSource,
  /last_completed_available_stock|last_completed_available_stock_available|last_completed_message|last_completed_start_date|last_completed_policy_available|last_completed_horizon_available|last_completed_deadline_age_available|last_completed_deadline_age_reason/,
  "health evaluator must expose latest completed available-stock context",
);
assert.match(
  healthReportSource,
  /last_completed_available_stock|last_completed_available_stock_available|last_completed_message|last_completed_start_date|last_completed_start_time|last_completed_policy_available|last_completed_movement_type|last_completed_horizon_available|last_completed_requested_on_from|last_completed_deadline_age_available|last_completed_deadline_age_reason/,
  "health report must expose latest completed result context",
);
assert.match(
  healthSource,
  /iv_min_last_coverage|last_coverage_below_threshold/,
  "health evaluator must support latest-run coverage threshold evaluation",
);
assert.match(
  healthSource,
  /iv_max_last_shortage_qty|last_shortage_qty_above_threshold/,
  "health evaluator must support latest-run shortage threshold evaluation",
);
assert.match(
  healthSource,
  /iv_max_last_shortage_pct|last_shortage_pct_above_threshold/,
  "health evaluator must support latest-run shortage-percentage threshold evaluation",
);
assert.match(
  healthSource,
  /iv_min_last_completed_coverage|last_completed_coverage_below_threshold/,
  "health evaluator must support latest-completed coverage threshold evaluation",
);
assert.match(
  healthSource,
  /iv_max_last_completed_coverage|last_completed_coverage_above_threshold/,
  "health evaluator must support maximum latest-completed coverage threshold evaluation",
);
assert.match(
  healthSource,
  /iv_max_last_completed_shortage_pct|last_completed_shortage_pct_above_threshold/,
  "health evaluator must support latest-completed shortage-percentage threshold evaluation",
);
assert.match(
  healthSource,
  /iv_max_last_completed_shortage_qty|last_completed_shortage_qty_above_threshold/,
  "health evaluator must support latest-completed shortage-quantity threshold evaluation",
);
assert.match(
  healthSource,
  /iv_min_last_completed_allocated|last_completed_allocated_below_threshold/,
  "health evaluator must support latest-completed allocated-quantity threshold evaluation",
);
assert.match(
  healthSource,
  /iv_max_last_completed_allocated|last_completed_allocated_above_threshold/,
  "health evaluator must support maximum latest-completed allocated-quantity threshold evaluation",
);
assert.match(
  healthSource,
  /iv_max_last_completed_requested|last_completed_requested_above_threshold/,
  "health evaluator must support latest-completed requested-quantity threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_ccov|minimum_last_completed_coverage|last_completed_coverage_threshold/,
  "health report must expose latest-completed coverage threshold provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_ccvmax|maximum_last_completed_coverage|last_completed_coverage_max_threshold/,
  "health report must expose maximum latest-completed coverage threshold provenance",
);
assert.match(
  healthReportSource,
  /p_ccov\s*>\s*0[\s\S]*p_ccvmax\s*>\s*0[\s\S]*p_ccov\s*>\s*p_ccvmax[\s\S]*Latest completed coverage minimum cannot exceed its maximum/,
  "health report must reject an inverted latest-completed coverage threshold range",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_coverage_max_threshold_active'[\s\S]*ls_health-last_completed_coverage_max_threshold_active/,
  "health JSON must expose maximum latest-completed coverage threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_coverage_above_threshold'[\s\S]*ls_health-last_completed_coverage_above_threshold/,
  "health JSON must expose maximum latest-completed coverage breach state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cspct|maximum_last_completed_shortage_pct|last_completed_shortage_pct_threshold/,
  "health report must expose latest-completed shortage-percentage threshold provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cshmax|maximum_last_completed_shortage_quantity|last_completed_shortage_qty_threshold/,
  "health report must expose latest-completed shortage-quantity threshold provenance",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_camin|minimum_last_completed_allocated_quantity|last_completed_allocated_threshold/,
  "health report must expose latest-completed allocated-quantity threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_threshold_active'[\s\S]*ls_health-last_completed_allocated_threshold_active/,
  "health JSON must expose latest-completed allocated-quantity threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_below_threshold'[\s\S]*ls_health-last_completed_allocated_below_threshold/,
  "health JSON must expose latest-completed allocated-quantity breach state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_crqmax|maximum_last_completed_requested_quantity|last_completed_requested_threshold/,
  "health report must expose latest-completed requested-quantity threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_requested_threshold_active'[\s\S]*ls_health-last_completed_requested_threshold_active/,
  "health JSON must expose latest-completed requested-quantity threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_requested_above_threshold'[\s\S]*ls_health-last_completed_requested_above_threshold/,
  "health JSON must expose latest-completed requested-quantity breach state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_caqmax|maximum_last_completed_allocated_quantity|last_completed_allocated_max_threshold/,
  "health report must expose maximum latest-completed allocated-quantity threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_max_threshold_active'[\s\S]*ls_health-last_completed_allocated_max_threshold_active/,
  "health JSON must expose maximum latest-completed allocated-quantity threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_above_threshold'[\s\S]*ls_health-last_completed_allocated_above_threshold/,
  "health JSON must expose maximum latest-completed allocated-quantity breach state",
);
assert.match(
  healthSource,
  /iv_min_last_completed_avail_stock|last_completed_avail_stock_below_threshold|iv_max_last_completed_avail_stock|last_completed_avail_stock_above_threshold/,
  "health evaluator must support latest-completed available-stock thresholds",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cavmin|PARAMETERS p_cavmax|minimum_last_completed_available_stock|maximum_last_completed_available_stock|last_completed_avail_stock_min_threshold|last_completed_avail_stock_max_threshold/,
  "health report must expose latest-completed available-stock threshold provenance",
);
assert.match(
  healthSource,
  /iv_min_last_completed_full_line_rate|last_completed_full_line_below_threshold/,
  "health evaluator must support latest-completed full-line-rate threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cflmin|minimum_last_completed_full_line_rate|last_completed_full_line_threshold/,
  "health report must expose latest-completed full-line-rate threshold provenance",
);
assert.match(
  healthSource,
  /iv_max_last_completed_full_line_rate|last_completed_full_line_above_threshold/,
  "health evaluator must support maximum latest-completed full-line-rate threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cflmax|maximum_last_completed_full_line_rate|last_completed_full_line_max_threshold/,
  "health report must expose maximum latest-completed full-line-rate threshold provenance",
);
assert.match(
  healthReportSource,
  /p_cflmin\s*>\s*0[\s\S]*p_cflmax\s*>\s*0[\s\S]*p_cflmin\s*>\s*p_cflmax[\s\S]*Latest completed full-line rate minimum cannot exceed its maximum/,
  "health report must reject an inverted latest-completed full-line-rate threshold range",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_full_line_max_threshold_active'[\s\S]*ls_health-last_completed_full_line_max_threshold_active/,
  "health JSON must expose maximum latest-completed full-line threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_full_line_above_threshold'[\s\S]*ls_health-last_completed_full_line_above_threshold/,
  "health JSON must expose maximum latest-completed full-line breach state",
);
assert.match(
  healthSource,
  /iv_max_last_completed_unalloc_line_rate|last_completed_unalloc_line_above_threshold/,
  "health evaluator must support latest-completed unallocated-line-rate threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_culmax|maximum_last_completed_unallocated_line_rate|last_completed_unalloc_line_threshold/,
  "health report must expose latest-completed unallocated-line-rate threshold provenance",
);
assert.match(
  healthSource,
  /iv_max_last_completed_partial_line_rate|last_completed_partial_line_above_threshold/,
  "health evaluator must support latest-completed partial-line-rate threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cplmax|maximum_last_completed_partial_line_rate|last_completed_partial_line_threshold/,
  "health report must expose latest-completed partial-line-rate threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_partial_line_threshold_active'[\s\S]*ls_health-last_completed_partial_line_threshold_active/,
  "health JSON must expose latest-completed partial-line threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_partial_line_above_threshold'[\s\S]*ls_health-last_completed_partial_line_above_threshold/,
  "health JSON must expose latest-completed partial-line breach state",
);
assert.match(
  healthSource,
  /iv_min_last_completed_full_line_count|last_completed_full_count_below_threshold/,
  "health evaluator must support latest-completed full-line-count threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cflcnt|minimum_last_completed_full_line_count|last_completed_full_count_threshold/,
  "health report must expose latest-completed full-line-count threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_full_count_threshold_active'[\s\S]*ls_health-last_completed_full_count_threshold_active/,
  "health JSON must expose latest-completed full-count threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_full_count_below_threshold'[\s\S]*ls_health-last_completed_full_count_below_threshold/,
  "health JSON must expose latest-completed full-count breach state",
);
assert.match(
  healthSource,
  /iv_min_last_completed_alloc_lines|last_completed_allocated_count_below_threshold/,
  "health evaluator must support latest-completed allocated-line-count threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cacnt|minimum_last_completed_allocated_line_count|last_completed_allocated_count_threshold/,
  "health report must expose latest-completed allocated-line-count threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_count_threshold_active'[\s\S]*ls_health-last_completed_allocated_count_threshold_active/,
  "health JSON must expose latest-completed allocated-line-count threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_count_below_threshold'[\s\S]*ls_health-last_completed_allocated_count_below_threshold/,
  "health JSON must expose latest-completed allocated-line-count breach state",
);
assert.match(
  healthSource,
  /iv_max_last_completed_alloc_lines|last_completed_alloc_count_max_above_threshold/,
  "health evaluator must support maximum latest-completed allocated-line-count threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cacmax|maximum_last_completed_allocated_line_count|last_completed_allocated_count_max_threshold/,
  "health report must expose maximum latest-completed allocated-line-count threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_count_max_threshold_active'[\s\S]*ls_health-last_completed_alloc_count_max_threshold_active/,
  "health JSON must expose maximum latest-completed allocated-line-count threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_allocated_count_above_threshold'[\s\S]*ls_health-last_completed_alloc_count_max_above_threshold/,
  "health JSON must expose maximum latest-completed allocated-line-count breach state",
);
assert.match(
  healthSource,
  /iv_max_last_completed_unalloc_line_count|last_completed_unalloc_count_above_threshold/,
  "health evaluator must support latest-completed unallocated-line-count threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_culcnt|maximum_last_completed_unallocated_line_count|last_completed_unalloc_count_threshold/,
  "health report must expose latest-completed unallocated-line-count threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_unalloc_count_threshold_active'[\s\S]*ls_health-last_completed_unalloc_count_threshold_active/,
  "health JSON must expose latest-completed unallocated-count threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_unalloc_count_above_threshold'[\s\S]*ls_health-last_completed_unalloc_count_above_threshold/,
  "health JSON must expose latest-completed unallocated-count breach state",
);
assert.match(
  healthSource,
  /iv_max_last_completed_partial_line_count|last_completed_partial_count_above_threshold/,
  "health evaluator must support latest-completed partial-line-count threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cplcnt|maximum_last_completed_partial_line_count|last_completed_partial_count_threshold/,
  "health report must expose latest-completed partial-line-count threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_partial_count_threshold_active'[\s\S]*ls_health-last_completed_partial_count_threshold_active/,
  "health JSON must expose latest-completed partial-count threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_partial_count_above_threshold'[\s\S]*ls_health-last_completed_partial_count_above_threshold/,
  "health JSON must expose latest-completed partial-count breach state",
);
assert.match(
  healthSource,
  /iv_max_last_completed_shortage_line_count|last_completed_shortage_count_above_threshold/,
  "health evaluator must support latest-completed shortage-line-count threshold evaluation",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cshcnt|maximum_last_completed_shortage_line_count|last_completed_shortage_count_threshold/,
  "health report must expose latest-completed shortage-line-count threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_shortage_count_threshold_active'[\s\S]*ls_health-last_completed_shortage_count_threshold_active/,
  "health JSON must expose latest-completed shortage-count threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_shortage_count_above_threshold'[\s\S]*ls_health-last_completed_shortage_count_above_threshold/,
  "health JSON must expose latest-completed shortage-count breach state",
);
assert.match(
  healthSource,
  /iv_min_last_completed_requested|last_completed_requested_below_threshold/,
  "health evaluator must support a minimum latest-completed requested-quantity threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_crqmin|minimum_last_completed_requested_quantity|last_completed_requested_min_threshold/,
  "health report must expose minimum latest-completed requested-quantity threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_requested_min_threshold_active'[\s\S]*ls_health-last_completed_requested_min_threshold_active/,
  "health JSON must expose minimum latest-completed requested-quantity threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_requested_below_threshold'[\s\S]*ls_health-last_completed_requested_below_threshold/,
  "health JSON must expose minimum latest-completed requested-quantity breach state",
);
assert.match(
  healthReportSource,
  /p_crqmin\s*>\s*0[\s\S]*p_crqmax\s*>\s*0[\s\S]*p_crqmin\s*>\s*p_crqmax[\s\S]*Minimum latest completed requested quantity cannot exceed maximum/,
  "health report must reject an inverted latest-completed requested-quantity range",
);
assert.match(
  healthReportSource,
  /p_camin\s*>\s*0[\s\S]*p_caqmax\s*>\s*0[\s\S]*p_camin\s*>\s*p_caqmax[\s\S]*Minimum latest completed allocated quantity cannot exceed maximum/,
  "health report must reject an inverted latest-completed allocated-quantity range",
);
assert.match(
  healthSource,
  /iv_min_last_completed_demand_count|last_completed_demand_count_below_threshold/,
  "health evaluator must support a minimum latest-completed demand-count threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cdmin|minimum_last_completed_demand_count|last_completed_demand_count_min_threshold/,
  "health report must expose minimum latest-completed demand-count threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_demand_count_min_threshold_active'[\s\S]*ls_health-last_completed_demand_count_min_threshold_active/,
  "health JSON must expose minimum latest-completed demand-count threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_demand_count_below_threshold'[\s\S]*ls_health-last_completed_demand_count_below_threshold/,
  "health JSON must expose minimum latest-completed demand-count breach state",
);
assert.match(
  healthReportSource,
  /p_cdmin\s*>\s*0[\s\S]*p_cdmax\s*>\s*0[\s\S]*p_cdmin\s*>\s*p_cdmax[\s\S]*Minimum latest completed demand count cannot exceed maximum/,
  "health report must reject an inverted latest-completed demand-count range",
);
assert.match(
  healthReportSource,
  /minimum_coverage;[\s\S]*minimum_last_coverage;[\s\S]*maximum_average_duration/,
  "health CSV must keep latest-coverage provenance in parameter order",
);
assert.match(
  healthSource,
  /last_requested_quantity\s*=\s*is_summary-last_requested|last_coverage_pct\s*=\s*is_summary-last_coverage/,
  "health evaluator must expose latest-run outcome telemetry",
);
assert.match(
  healthReportSource,
  /last_requested_quantity|last_allocated_quantity|last_shortage_quantity|last_coverage_pct|last_unallocated_line_count/,
  "health report must expose latest-run outcome telemetry",
);
assert.match(
  healthSource,
  /priority_mix_pct|fifo_mix_pct|full_only_mix_pct|smallest_mix_pct|largest_mix_pct|best_mix_pct/,
  "health evaluator must calculate strategy-mix percentages",
);
assert.match(
  healthReportSource,
  /priority_mix_pct|fifo_mix_pct|full_only_mix_pct|smallest_mix_pct|largest_mix_pct|best_mix_pct|legacy_mix_pct/,
  "health report must expose strategy-mix percentages",
);
assert.match(
  healthSource,
  /duration_above_threshold|duration_threshold_active|last_duration_available/,
  "health evaluator must expose latest-duration threshold state",
);
assert.match(
  healthReportSource,
  /maximum_last_duration|duration_threshold|duration_above_threshold/,
  "health report must expose latest-duration threshold provenance",
);
assert.match(
  healthSource,
  /iv_max_last_completed_duration|last_completed_duration_above_threshold/,
  "health evaluator must expose latest-completed-duration threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cdurmx|maximum_last_completed_duration|last_completed_duration_threshold/,
  "health report must expose latest-completed-duration threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_duration_threshold_active'[\s\S]*ls_health-last_completed_duration_threshold_active/,
  "health JSON must expose latest-completed-duration threshold state",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_duration_above_threshold'[\s\S]*ls_health-last_completed_duration_above_threshold/,
  "health JSON must expose latest-completed-duration breach state",
);
assert.match(
  healthSource,
  /iv_min_last_completed_duration|last_completed_duration_below_threshold/,
  "health evaluator must expose minimum latest-completed-duration threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cdurmn|minimum_last_completed_duration|last_completed_duration_min_threshold/,
  "health report must expose minimum latest-completed-duration threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_duration_below_threshold'[\s\S]*ls_health-last_completed_duration_below_threshold/,
  "health JSON must expose minimum latest-completed-duration breach state",
);
assert.match(
  healthSource,
  /iv_require_last_completed_success|last_completed_success_breach/,
  "health evaluator must expose latest-completed-success requirement state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_csucc|require_last_completed_success|last_completed_success_required_active/,
  "health report must expose latest-completed-success requirement provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_success_breach'[\s\S]*ls_health-last_completed_success_breach/,
  "health JSON must expose latest-completed-success breach state",
);
assert.match(
  healthSource,
  /iv_min_last_completed_success_streak|last_completed_success_streak_below_threshold/,
  "health evaluator must expose minimum latest-completed-success-streak threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cstrk|minimum_last_completed_success_streak|last_completed_success_streak_threshold/,
  "health report must expose minimum latest-completed-success-streak threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_success_streak_below_threshold'[\s\S]*ls_health-last_completed_success_streak_below_threshold/,
  "health JSON must expose latest-completed-success-streak breach state",
);
assert.match(
  healthSource,
  /last_completed_success_streak\s*=\s*is_summary-last_completed_success_streak/,
  "health evaluator must propagate latest-completed-success streak telemetry",
);
assert.match(
  healthReportSource,
  /last_completed_success_streak/,
  "health report must expose latest-completed-success streak telemetry",
);
assert.match(
  healthSource,
  /iv_max_last_completed_non_success_streak|last_completed_non_success_above_threshold/,
  "health evaluator must expose maximum latest-completed-non-success-streak threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cfail|maximum_last_completed_non_success_streak|last_completed_non_success_threshold/,
  "health report must expose maximum latest-completed-non-success-streak threshold provenance",
);
assert.match(
  healthReportSource,
  /iv_name\s*=\s*'last_completed_non_success_streak_above_threshold'[\s\S]*ls_health-last_completed_non_success_above_threshold/,
  "health JSON must expose maximum latest-completed-non-success-streak breach state",
);
assert.match(
  healthSource,
  /last_completed_non_success_streak\s*=\s*is_summary-last_completed_non_success_streak/,
  "health evaluator must propagate latest-completed non-success streak telemetry",
);
assert.match(
  healthSource,
  /average_duration_above_threshold|average_duration_threshold_active|average_duration_threshold/,
  "health evaluator must expose average-duration threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_avgmax|maximum_average_duration|average_duration_threshold|average_duration_above_threshold/,
  "health report must expose average-duration threshold provenance",
);
assert.match(
  healthSource,
  /maximum_duration_above_threshold|maximum_duration_threshold_active|maximum_duration_threshold/,
  "health evaluator must expose maximum-duration threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_maxdur|maximum_completed_duration|maximum_duration_threshold|maximum_duration_above_threshold/,
  "health report must expose maximum-duration threshold provenance",
);
assert.match(
  healthSource,
  /success_below_threshold|success_threshold_active|success_threshold/,
  "health evaluator must expose success-rate threshold state",
);
assert.match(
  healthReportSource,
  /minimum_success_rate|success_threshold|success_below_threshold/,
  "health report must expose success-rate threshold provenance",
);
assert.match(
  healthSource,
  /success_count_threshold_active|success_count_threshold|success_count_below_threshold/,
  "health evaluator must expose success-count threshold state",
);
assert.match(
  healthSource,
  /iv_min_success_count|success_count_below_threshold[\s\S]*iv_min_success_count/,
  "health evaluator must apply a minimum successful-run count threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_sucnt|minimum_success_count|success_count_threshold|success_count_below_threshold/,
  "health report must expose success-count threshold provenance",
);
assert.match(
  healthSource,
  /duration_count_threshold_active|duration_count_threshold|duration_count_below_threshold/,
  "health evaluator must expose duration-count threshold state",
);
assert.match(
  healthSource,
  /iv_min_duration_count|duration_count_below_threshold[\s\S]*iv_min_duration_count/,
  "health evaluator must apply a minimum duration sample-count threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_durcnt|minimum_duration_count|duration_count_threshold|duration_count_below_threshold/,
  "health report must expose duration-count threshold provenance",
);
assert.match(
  healthSource,
  /run_count_threshold_active|run_count_threshold|run_count_below_threshold/,
  "health evaluator must expose total-run-count threshold state",
);
assert.match(
  healthSource,
  /iv_min_run_count|run_count_below_threshold[\s\S]*total_runs < iv_min_run_count/,
  "health evaluator must apply a minimum total-run-count threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_runcnt|minimum_run_count|run_count_threshold|run_count_below_threshold/,
  "health report must expose total-run-count threshold provenance",
);
assert.match(
  healthSource,
  /deadline_count_threshold_active|deadline_count_threshold|deadline_count_below_threshold/,
  "health evaluator must expose deadline-count threshold state",
);
assert.match(
  healthSource,
  /iv_min_deadline_count|deadline_count_below_threshold[\s\S]*deadline_count < iv_min_deadline_count/,
  "health evaluator must apply a minimum deadline-bearing-run threshold",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_dcmin|minimum_deadline_count|deadline_count_threshold|deadline_count_below_threshold/,
  "health report must expose deadline-count threshold provenance",
);
assert.match(
  healthSource,
  /mixed_policy_warning_active|mixed_policy_breach/,
  "health evaluator must expose mixed-policy warning state",
);
assert.match(
  healthSource,
  /iv_warn_mixed_policies|mixed_policy_breach[\s\S]*is_summary-mixed_policies/,
  "health evaluator must apply the mixed-policy warning switch",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_pmix|warn_mixed_policies|mixed_policy_warning_active|mixed_policy_breach/,
  "health report must expose mixed-policy warning provenance",
);
assert.match(
  healthSource,
  /mixed_unit_warning_active|mixed_unit_breach/,
  "health evaluator must expose mixed-unit warning state",
);
assert.match(
  healthSource,
  /iv_warn_mixed_units|mixed_unit_breach[\s\S]*is_summary-mixed_units/,
  "health evaluator must apply the mixed-unit warning switch",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_umix|warn_mixed_units|mixed_unit_warning_active|mixed_unit_breach/,
  "health report must expose mixed-unit warning provenance",
);
assert.match(
  healthSource,
  /error_above_threshold|error_threshold_active|error_threshold/,
  "health evaluator must expose error-rate threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_errmax|maximum_error_rate|error_threshold|error_above_threshold/,
  "health report must expose error-rate threshold provenance",
);
assert.match(
  healthSource,
  /partial_above_threshold|partial_threshold_active|partial_threshold/,
  "health evaluator must expose partial-run-rate threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_prtmax|maximum_partial_rate|partial_threshold|partial_above_threshold/,
  "health report must expose partial-run-rate threshold provenance",
);
assert.match(
  healthSource,
  /completion_below_threshold|completion_threshold_active|completion_threshold/,
  "health evaluator must expose completion-rate threshold state",
);
assert.match(
  healthReportSource,
  /PARAMETERS p_cmin|minimum_completion_rate|completion_threshold|completion_below_threshold/,
  "health report must expose completion-rate threshold provenance",
);
assert.match(
  healthSource,
  /threshold_breach_count|threshold_breaches/,
  "health evaluator must aggregate threshold breaches",
);
assert.match(
  healthReportSource,
  /threshold_breach_count|threshold_breaches/,
  "health report must expose aggregated threshold breaches",
);
assert.equal(
  (healthReportSource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
  70,
  "health report must version all JSON error envelopes",
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
const purgeReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_purge.prog.abap"),
  "utf8",
);
assert.equal(
  (purgeReportSource.match(/iv_name\s*=\s*'schema_version'/g) ?? []).length,
  4,
  "purge preview and execution JSON must expose schema_version in typed and untyped modes",
);
assert.equal(
  (purgeReportSource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
  24,
  "purge report must version all JSON error envelopes",
);
for (const [mode, schemaVersion] of [["preview", 27], ["execution", 28]]) {
  assert.equal(
    (purgeReportSource.match(new RegExp(`iv_value\\s*=\\s*${schemaVersion}\\s*\\)`, "g")) ?? []).length,
    2,
    `purge ${mode} JSON schema must be present in typed and untyped modes`,
  );
  assert.match(
    purgeReportSource,
    new RegExp(
      `IF p_typed = abap_false\\.[\\s\\S]{0,260}iv_name\\s*=\\s*'schema_version'[\\s\\S]{0,80}iv_value\\s*=\\s*${schemaVersion}`,
    ),
    `purge ${mode} untyped JSON must expose schema_version`,
  );
}
assert.match(
  purgeReportSource,
  /PARAMETERS\s+p_prev\s+TYPE\s+zif_allocation_audit=>ty_preview_filter\./,
  "purge report must expose the preview provenance filter",
);
assert.match(
  purgeReportSource,
  /PARAMETERS\s+p_max\s+TYPE\s+i\./,
  "purge report must expose a maximum-run retention cap",
);
assert.match(
  purgeReportSource,
  /PARAMETERS\s+p_to\s+TYPE\s+d\./,
  "purge report must expose an audit start-date upper bound",
);
assert.match(
  purgeReportSource,
  /iv_preview_filter\s*=\s*p_prev/,
  "purge report must propagate preview provenance to both retention paths",
);
assert.match(
  purgeReportSource,
  /iv_max_runs\s*=\s*p_max/,
  "purge report must propagate the maximum-run cap to both retention paths",
);
assert.match(
  purgeReportSource,
  /iv_start_date_to\s*=\s*p_to/,
  "purge report must propagate the audit start-date upper bound to both retention paths",
);
assert.match(
  purgeReportSource,
  /Preview filter must be P or O/,
  "purge report must validate preview provenance values",
);
assert.match(
  purgeReportSource,
  /Maximum purge runs must not be negative/,
  "purge report must validate the maximum-run cap",
);
assert.match(
  purgeReportSource,
  /max_runs_filter/,
  "purge output must expose the maximum-run cap provenance",
);
assert.match(
  purgeReportSource,
  /start_date_to_filter/,
  "purge output must expose the audit start-date upper-bound provenance",
);
assert.match(
  purgeReportSource,
  /capped_audit_runs/,
  "purge output must expose runs skipped by the maximum-run cap",
);
const compareReportSource = fs.readFileSync(
  path.join(sourceDirectory, "zstock_alloc_compare.prog.abap"),
  "utf8",
);
assert.equal(
  (compareReportSource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
  114,
  "comparison report must version all JSON error envelopes",
);
for (const previewParameter of ["P_PREV", "P_OPREV", "P_NPREV"]) {
  assert.match(
    compareReportSource,
    new RegExp(`PARAMETERS\\s+${previewParameter}\\s+TYPE\\s+zif_allocation_audit=>ty_preview_filter`, "i"),
    `comparison report must expose ${previewParameter}`,
  );
}
for (const previewBinding of [
  /iv_preview_filter\s*=\s*lv_old_preview/,
  /iv_preview_filter\s*=\s*lv_new_preview/,
  /iv_preview_filter\s*=\s*lv_old_preview[\s\S]*iv_strategy/,
  /iv_preview_filter\s*=\s*lv_new_preview[\s\S]*iv_strategy/,
]) {
  assert.match(
    compareReportSource,
    previewBinding,
    `comparison report must propagate preview provenance: ${previewBinding}`,
  );
}
for (const previewContractText of [
  "Common and side-specific preview filters cannot be combined",
  "Preview filter is invalid",
  "Old preview filter is invalid",
  "New preview filter is invalid",
  "preview_filter",
  "old_preview_filter",
  "new_preview_filter",
  "old_run_preview",
  "new_run_preview",
]) {
  assert.match(
    compareReportSource,
    new RegExp(previewContractText.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")),
    `comparison preview contract missing ${previewContractText}`,
  );
}
const compareClassSource = fs.readFileSync(
  path.join(sourceDirectory, "zcl_stock_allocation_compare.clas.abap"),
  "utf8",
);
assert.match(
  historySource,
  /Safety stock context:/,
  "history human summary must expose safety-stock context",
);
for (const [reportName, reportSource] of [
  ["history", historySource],
  ["result", resultSource],
  ["watch", watchSource],
  ["purge", purgeReportSource],
]) {
  assert.match(
    reportSource,
    /TRANSLATE\s+p_meins\s+TO\s+UPPER\s+CASE\./,
    `${reportName} must canonicalize lowercase unit filters before reads and exports`,
  );
}
assert.match(
  historySource,
  /TRANSLATE\s+p_stat\s+TO\s+UPPER\s+CASE\./,
  "history must canonicalize the lifecycle status filter before reads and exports",
);
assert.match(
  historySource,
  /PARAMETERS p_prev TYPE zif_allocation_audit=>ty_preview_filter\.[\s\S]*TRANSLATE\s+p_prev\s+TO\s+UPPER\s+CASE\./,
  "history must canonicalize the preview provenance filter before reads and exports",
);
for (const filterName of ["p_stat", "p_auart", "p_ounit", "p_runit"]) {
  assert.match(
    resultSource,
    new RegExp(`TRANSLATE\\s+${filterName}\\s+TO\\s+UPPER\\s+CASE\\.`),
    `result must canonicalize ${filterName} before reads and exports`,
  );
}
assert.match(
  resultSource,
  /PARAMETERS p_prev TYPE zif_allocation_audit=>ty_preview_filter\.[\s\S]*TRANSLATE\s+p_prev\s+TO\s+UPPER\s+CASE\./,
  "result must canonicalize the preview provenance filter before reads and exports",
);
for (const filterName of ["p_auart", "p_oauart", "p_nauart"]) {
  assert.match(
    compareReportSource,
    new RegExp(`TRANSLATE\\s+${filterName}\\s+TO\\s+UPPER\\s+CASE\\.`),
    `comparison must canonicalize ${filterName} before reads and exports`,
  );
}
assert.match(
  compareReportSource,
  /TRANSLATE\s+p_chg\s+TO\s+UPPER\s+CASE\./,
  "comparison must canonicalize the change-type filter before validation and exports",
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
  /iv_preview_filter\s+= p_prev/,
  "history must propagate the preview provenance filter to audit reads",
);
assert.match(
  historySource,
  /preview_filter/,
  "history machine-readable output must expose preview provenance filter provenance",
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
  /iv_value = 44 \) TO lt_json_fields/,
  "history summary JSON schema must include the preview-filter contract version",
);
assert.match(
  historySource,
  /iv_value = 27 \) TO lt_json_fields/,
  "history detail JSON schema must include the preview-filter contract version",
);
assert.equal(
  (historySource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
  37,
  "history report must version all JSON error envelopes",
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
  /PARAMETERS p_prev TYPE zif_allocation_audit=>ty_preview_filter\./,
  "watch must expose a preview provenance filter",
);
assert.match(
  watchSource,
  /PARAMETERS p_from TYPE d\./,
  "watch must expose an audit start-date lower bound",
);
assert.match(
  watchSource,
  /PARAMETERS p_to TYPE d\./,
  "watch must expose an audit start-date upper bound",
);
assert.match(
  watchSource,
  /PARAMETERS p_ffrom TYPE d\./,
  "watch must expose an audit finish-date lower bound",
);
assert.match(
  watchSource,
  /PARAMETERS p_rid TYPE zif_allocation_audit=>ty_run_id\./,
  "watch must expose the standard run-ID fragment alias",
);
assert.match(
  watchSource,
  /IF p_runq IS NOT INITIAL AND p_rid IS NOT INITIAL\./,
  "watch must reject ambiguous run-ID fragment aliases",
);
assert.match(
  watchSource,
  /p_runq and p_rid cannot both be supplied/,
  "watch must explain the ambiguous run-ID fragment aliases",
);
assert.match(
  watchSource,
  /iv_run_id_contains\s+= lv_run_contains_value/,
  "watch must propagate the effective run-ID fragment filter",
);
assert.match(
  watchSource,
  /PARAMETERS p_fto TYPE d\./,
  "watch must expose an audit finish-date upper bound",
);
assert.match(
  watchSource,
  /iv_safety_filter\s+= p_safon/,
  "watch must propagate the safety-stock filter switch to audit reads",
);
assert.match(
  watchSource,
  /iv_preview_filter\s+= p_prev/,
  "watch must propagate the preview provenance filter to audit reads",
);
assert.match(
  watchSource,
  /iv_start_date_from\s+= p_from/,
  "watch must propagate the audit start-date lower bound to audit reads",
);
assert.match(
  watchSource,
  /iv_start_date_to\s+= p_to/,
  "watch must propagate the audit start-date upper bound to audit reads",
);
assert.match(
  watchSource,
  /iv_finish_date_from\s+= p_ffrom/,
  "watch must propagate the audit finish-date lower bound to audit reads",
);
assert.match(
  watchSource,
  /iv_finish_date_to\s+= p_fto/,
  "watch must propagate the audit finish-date upper bound to audit reads",
);
assert.match(
  watchSource,
  /preview_filter/,
  "watch machine-readable output must expose preview provenance",
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
  /start_date_from_filter|start_date_to_filter/,
  "watch machine-readable filters must expose audit start-date bounds",
);
assert.match(
  watchSource,
  /finish_date_from_filter|finish_date_to_filter/,
  "watch machine-readable filters must expose audit finish-date bounds",
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
  /number\( 60 \)/,
  "watch CSV schema must include the preview-filter contract version",
);
assert.match(
  watchSource,
  /iv_value = 63 \)/,
  "watch JSON schema must include the preview-filter contract version",
);
assert.equal(
  (watchSource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
  4,
  "watch report must version all JSON error envelopes",
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
  /iv_preview_filter\s+= p_prev/,
  "result must propagate the preview provenance filter to audit and sink reads",
);
assert.match(
  resultSource,
  /iv_run_start_date_from\s*= p_sfrom[\s\S]*iv_run_start_date_to\s*= p_sto/,
  "result must propagate audit start-date bounds to sink reads",
);
assert.match(
  resultSource,
  /iv_run_finish_date_from\s*= p_ffrom[\s\S]*iv_run_finish_date_to\s*= p_fto/,
  "result must propagate audit finish-date bounds to sink reads",
);
assert.match(
  resultSource,
  /iv_start_date_from\s*= p_sfrom[\s\S]*iv_start_date_to\s*= p_sto/,
  "result must propagate audit start-date bounds to audit reads",
);
assert.match(
  resultSource,
  /iv_finish_date_from\s*= p_ffrom[\s\S]*iv_finish_date_to\s*= p_fto/,
  "result must propagate audit finish-date bounds to audit reads",
);
assert.match(
  resultSource,
  /audit_start_date_from_filter[\s\S]*audit_start_date_to_filter/,
  "result machine-readable output must expose audit start-date provenance",
);
assert.match(
  resultSource,
  /audit_finish_date_from_filter[\s\S]*audit_finish_date_to_filter/,
  "result machine-readable output must expose audit finish-date provenance",
);
assert.match(
  resultSource,
  /preview_filter/,
  "result machine-readable output must expose preview provenance",
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
  /APPEND zcl_stock_csv=>number\( 46 \)/,
  "result summary CSV schema must include the safety-stock contract version",
);
assert.match(
  resultSource,
  /APPEND zcl_stock_csv=>number\( 40 \)/,
  "result detail CSV schema must include the safety-stock contract version",
);
assert.equal(
  (resultSource.match(/zcl_stock_json=>error_with_schema/g) ?? []).length,
  35,
  "result report must version all JSON error envelopes",
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
assert.match(
  unitConversionSource,
  /CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'[\s\S]*EXCEPTIONS[\s\S]*OTHERS\s*=\s*1/,
  "unit conversion must map classic function-module exceptions into sy-subrc",
);
for (const functionModule of ["ENQUEUE_EZSTOCKALLOC", "DEQUEUE_EZSTOCKALLOC"]) {
  assert.match(
    allocationLockSource,
    new RegExp(
      `CALL FUNCTION '${functionModule}'[\\s\\S]*EXCEPTIONS[\\s\\S]*OTHERS\\s*=\\s*1`,
    ),
    `${functionModule} must map classic function-module exceptions into sy-subrc`,
  );
}

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
