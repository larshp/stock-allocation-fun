import {execFileSync} from "node:child_process";
import {existsSync, mkdirSync, readFileSync} from "node:fs";
import {fileURLToPath} from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const lock = JSON.parse(readFileSync(new URL("../dependencies.lock.json", import.meta.url)));
const dependency = lock["open-abap-core"];
if (dependency.url !== "https://github.com/open-abap/open-abap-core"
    || !/^[0-9a-f]{40}$/.test(dependency.commit)) {
  throw new Error("Invalid open-abap-core dependency lock");
}
const destination = fileURLToPath(new URL(`../.deps/${dependency.commit}/`, import.meta.url));
for (const [name, list] of [["abaplint.json", "dependencies"], ["abap_transpile.json", "libs"]]) {
  const config = JSON.parse(readFileSync(new URL(`../${name}`, import.meta.url)));
  const configured = config[list].find(entry => entry.url === dependency.url);
  if (configured?.folder !== `/.deps/${dependency.commit}`) {
    throw new Error(`${name} does not match dependencies.lock.json`);
  }
}
const git = (args, cwd = destination) => execFileSync("git", args, {cwd, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"]}).trim();
if (!existsSync(new URL(`../.deps/${dependency.commit}/.git`, import.meta.url))) {
  mkdirSync(new URL("../.deps/", import.meta.url), {recursive: true});
  git(["clone", "--quiet", "--no-checkout", "--", dependency.url, destination], root);
}
const changes = git(["status", "--porcelain", "--untracked-files=all"]);
// A no-checkout clone has staged deletions until the first checkout.
const marker = fileURLToPath(new URL(`../.deps/${dependency.commit}/src/`, import.meta.url));
if (existsSync(marker) && changes !== "") {
  throw new Error("Cached dependency has local changes; restore or move it before running tests");
}
if (!existsSync(marker) || git(["rev-parse", "HEAD"]) !== dependency.commit) {
  git(["checkout", "--quiet", "--detach", dependency.commit]);
}
if (git(["rev-parse", "HEAD"]) !== dependency.commit || git(["status", "--porcelain"]) !== "") {
  throw new Error("Dependency checkout does not match the clean locked revision");
}
console.log(`open-abap-core: ${dependency.commit}`);
