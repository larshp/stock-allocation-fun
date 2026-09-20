// Test bootstrap for the transpiled ABAP.
//
// The transpiler generates output/init.mjs, which builds the SQLite schema for
// every DDIC table found in /sap-stubs plus the metadata tables the runtime
// needs, but it does not open a database connection itself. This module is
// wired in via "options.setup" in abaplint-transpile.json and is called as
//   setupDatabase(globalThis.abap, schemas, insert)
// before any transpiled object is imported.
import {SQLiteDatabaseClient} from "@abaplint/database-sqlite";

export async function setupDatabase(abap, schemas, insert) {
  const client = new SQLiteDatabaseClient();
  await client.connect();
  await client.execute(schemas.sqlite);
  await client.execute(insert);
  abap.context.databaseConnections["DEFAULT"] = client;
}
