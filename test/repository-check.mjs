import { readFileSync, readdirSync } from "node:fs";
import { join, relative } from "node:path";

const root = process.cwd();
const lint = JSON.parse(readFileSync(join(root, "abaplint.json"), "utf8"));
const transpile = JSON.parse(
  readFileSync(join(root, "abap_transpile.json"), "utf8"),
);
const abapgit = readFileSync(join(root, ".abapgit.xml"), "utf8");

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
