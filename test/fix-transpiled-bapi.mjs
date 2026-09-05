import {readFileSync, writeFileSync} from "node:fs";

// Transpiler 2.13.74 renames references to RETURN as $return, but leaves the
// function-module TABLES declaration unescaped. Keep the real SAP signature.
const filename = new URL("../output/mb_bus2093.fugr.mjs", import.meta.url);
const source = readFileSync(filename, "utf8");
const broken = "let return = INPUT.tables?.return;";
const corrected = "let $return = INPUT.tables?.return;";
if (source.includes(broken)) {
  if (source.split(broken).length !== 2) {
    throw new Error("Unexpected number of BAPI RETURN declarations; review the transpiler workaround");
  }
  writeFileSync(filename, source.replace(broken, corrected));
  console.log("Applied scoped transpiler workaround for BAPI TABLES RETURN declaration");
} else if (!source.includes(corrected)) {
  throw new Error("BAPI stub output changed; review the transpiler workaround");
}
