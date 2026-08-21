// Checks that the README still describes what the repository contains.
//
// Two things drift the moment nobody is looking: a report that is added and
// never written down, and a Customizing table that is added and never
// explained. Both are invisible to abaplint and to the unit tests, because
// both are perfectly good ABAP -- the reader is the one who suffers. This runs
// with the rest of the test suite so that documentation is a thing that can
// fail.
import {readFileSync, readdirSync} from "fs";

const readme = readFileSync("README.md", "utf8");
const missing = [];

const files = readdirSync("src");

// every report has to appear in one of the tables of "The other programs",
// except the allocation itself, which the README opens with
const reports = files
  .filter(f => f.endsWith(".prog.abap"))
  .map(f => f.replace(".prog.abap", "").toUpperCase())
  .filter(name => name !== "ZSTOCK_ALLOCATION");

for (const report of reports) {
  if (!readme.includes("| `" + report + "`")) {
    missing.push("report " + report + " is in src/ and not in a table in README.md");
  }
}

// and every Customizing table -- delivery class C -- has to be in the
// Customizing section, because a table nobody documents is a table nobody
// maintains until a night behaves oddly
const customizing = files
  .filter(f => f.endsWith(".tabl.xml"))
  .filter(f => readFileSync("src/" + f, "utf8").includes("<CONTFLAG>C</CONTFLAG>"))
  .map(f => f.replace(".tabl.xml", "").toUpperCase());

for (const table of customizing) {
  if (!readme.includes("| `" + table + "`")) {
    missing.push("table " + table + " is Customizing and not in a table in README.md");
  }
}

if (missing.length > 0) {
  for (const line of missing) {
    console.log(line);
  }
  console.log("docs: " + missing.length + " thing(s) not written down");
  process.exit(1);
}

console.log("docs: " + reports.length + " report(s) and " + customizing.length +
  " Customizing table(s), all written down");
