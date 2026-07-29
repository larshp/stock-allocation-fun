import { readFile, readdir } from "node:fs/promises";
import { extname, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(fileURLToPath(new URL("..", import.meta.url)));
const ignored = new Set([".git", "node_modules", "output"]);
const artifacts = [];

async function walk(directory) {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    if (ignored.has(entry.name)) continue;
    const fullPath = resolve(directory, entry.name);
    if (entry.isDirectory()) {
      await walk(fullPath);
    } else if ([".abap", ".xml"].includes(extname(entry.name).toLowerCase())) {
      artifacts.push(relative(root, fullPath).replaceAll("\\", "/"));
    }
  }
}

await walk(root);
const misplaced = artifacts.filter(
  (path) => /^z/i.test(path.split("/").at(-1)) && !path.startsWith("src/"),
);
if (misplaced.length > 0) {
  throw new Error(`Custom Z artifacts outside src/: ${misplaced.join(", ")}`);
}

const lint = JSON.parse(await readFile(resolve(root, "abaplint.json"), "utf8"));
const transpile = JSON.parse(
  await readFile(resolve(root, "abap_transpile.json"), "utf8"),
);
const lintFiles = lint.global?.files || "";
if (!lintFiles.includes("src") || !lintFiles.includes("sap-stubs")) {
  throw new Error("abaplint must include both src/ and sap-stubs/");
}
const inputs = new Set(transpile.input_folder || []);
if (!inputs.has("src") || !inputs.has("sap-stubs")) {
  throw new Error("transpiler must include both src/ and sap-stubs/");
}
const abapgit = await readFile(resolve(root, ".abapgit.xml"), "utf8");
if (!abapgit.includes("<STARTING_FOLDER>/src/</STARTING_FOLDER>")) {
  throw new Error("abapGit starting folder must isolate productive src/");
}

console.log(`Layout policy passed: ${artifacts.length} ABAP/XML artifacts checked`);
