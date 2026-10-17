import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const sourceRoot = join(projectRoot, "src");
const bom = "\uFEFF";

function escapeXml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

function describe(objectName) {
  const terms = new Map(Object.entries({
    afko: "AFKO",
    afpo: "AFPO",
    api: "API",
    atp: "ATP",
    avail: "Availability",
    bapi: "BAPI",
    cc: "Cost Center",
    calc: "Calculator",
    comp: "Component",
    ekes: "EKES",
    eket: "EKET",
    ekko: "EKKO",
    ekpo: "EKPO",
    fefo: "FEFO",
    mch1: "MCH1",
    mcha: "MCHA",
    mchb: "MCHB",
    mara: "MARA",
    marc: "MARC",
    mard: "MARD",
    marm: "MARM",
    mat: "Material",
    mska: "MSKA",
    mspr: "MSPR",
    plaf: "PLAF",
    po: "Purchase Order",
    pr: "Purchase Requisition",
    preq: "Purchase Requisition",
    prps: "PRPS",
    qty: "Quantity",
    repl: "Replenishment",
    repo: "Repository",
    req: "Request",
    res: "Reservation",
    resb: "RESB",
    resv: "Reservation",
    rkpf: "RKPF",
    sap: "SAP",
    so: "Sales Order",
    sto: "Stock Transfer Order",
    svc: "Service",
    t001w: "T001W",
    t399d: "T399D",
    t439i: "T439I",
    tj02t: "TJ02T",
    tj30t: "TJ30T",
    tmq2: "TMQ2",
    uom: "Unit of Measure",
    vbap: "VBAP",
    vbep: "VBEP",
    vbup: "VBUP",
    wbs: "WBS",
    xfer: "Transfer",
  }));
  const name = objectName
    .replace(/^Z(?:CL|IF|CX)_/, "")
    .replaceAll("_", " ")
    .split(/\s+/)
    .map((word) => terms.get(word.toLowerCase())
      ?? word.charAt(0) + word.slice(1).toLowerCase())
    .join(" ");
  return `Stock allocation: ${name}`.slice(0, 60).trimEnd();
}

function writeIfMissing(relativePath, content) {
  const target = join(projectRoot, relativePath);
  if (existsSync(target)) {
    return false;
  }
  writeFileSync(target, `${bom}${content.trimEnd()}\n`, "utf8");
  return true;
}

const repoConfig = `<?xml version="1.0" encoding="utf-8"?>
<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
    <DATA>
      <MASTER_LANGUAGE>E</MASTER_LANGUAGE>
      <STARTING_FOLDER>/src/</STARTING_FOLDER>
      <FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>
    </DATA>
  </asx:values>
</asx:abap>`;
const packageMetadata = `<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">
  <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
    <asx:values>
      <DEVC>
        <CTEXT>Stock Allocation Fun</CTEXT>
      </DEVC>
    </asx:values>
  </asx:abap>
</abapGit>`;

let created = 0;
if (writeIfMissing(".abapgit.xml", repoConfig)) created++;
if (writeIfMissing("src/package.devc.xml", packageMetadata)) created++;

for (const filename of readdirSync(sourceRoot).sort()) {
  const isClass = filename.endsWith(".clas.abap");
  const isInterface = filename.endsWith(".intf.abap");
  if (!isClass && !isInterface) continue;

  const objectName = filename
    .replace(/\.(?:clas|intf)\.abap$/i, "")
    .toUpperCase();
  const source = readFileSync(join(sourceRoot, filename), "utf8");
  const declaration = isClass
    ? source.match(/\bCLASS\s+([A-Z0-9_]+)\s+DEFINITION\b/i)
    : source.match(/\bINTERFACE\s+([A-Z0-9_]+)\b/i);
  if (!declaration || declaration[1].toUpperCase() !== objectName) {
    throw new Error(`${filename} does not declare ${objectName}`);
  }

  const type = isClass ? "clas" : "intf";
  const serializer = isClass ? "CLAS" : "INTF";
  const description = escapeXml(describe(objectName));
  const hasUnitTests = existsSync(
    join(sourceRoot, `${objectName.toLowerCase()}.clas.testclasses.abap`),
  );
  const objectMetadata = isClass
    ? `<VSEOCLASS>
        <CLSNAME>${objectName}</CLSNAME>
        <LANGU>E</LANGU>
        <DESCRIPT>${description}</DESCRIPT>
        <STATE>1</STATE>
        <CLSCCINCL>X</CLSCCINCL>
        <FIXPT>X</FIXPT>
        <UNICODE>X</UNICODE>${hasUnitTests ? "\n        <WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>" : ""}
      </VSEOCLASS>`
    : `<VSEOINTERF>
        <CLSNAME>${objectName}</CLSNAME>
        <LANGU>E</LANGU>
        <DESCRIPT>${description}</DESCRIPT>
        <EXPOSURE>2</EXPOSURE>
        <STATE>1</STATE>
        <UNICODE>X</UNICODE>
      </VSEOINTERF>`;
  const xml = `<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_${serializer}" serializer_version="v1.0.0">
  <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
    <asx:values>
      ${objectMetadata}
    </asx:values>
  </asx:abap>
</abapGit>`;
  if (writeIfMissing(`src/${objectName.toLowerCase()}.${type}.xml`, xml)) {
    created++;
  }
}

console.log(`Created ${created} missing abapGit metadata file(s).`);
