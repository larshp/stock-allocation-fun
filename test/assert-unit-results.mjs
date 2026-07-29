import { readFile } from "node:fs/promises";

const results = JSON.parse(
  await readFile(new URL("../output/output.json", import.meta.url), "utf8"),
);
const failures = results.filter((result) => result.status !== "SUCCESS");

if (failures.length > 0) {
  for (const failure of failures) {
    console.error(
      `${failure.class_name}.${failure.method_name}: ${failure.message || failure.status}`,
    );
  }
  process.exitCode = 1;
} else {
  console.log(`${results.length} ABAP Unit tests passed`);
}
