import { SQLiteDatabaseClient } from '@abaplint/database-sqlite';

// Isolated development database. No connection to a live SAP system.
export async function setup(abap, schemas, insert) {
  const database = new SQLiteDatabaseClient();
  await database.connect();
  abap.context.databaseConnections.DEFAULT = database;
  await database.execute(schemas.sqlite);
  await database.execute(insert);
  abap.builtin.sy.get().mandt.set('123');
  await database.execute([
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('123', 'MAT1', 'KG')",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('123', 'MAT1', '1000', '0001', 4.500)",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('123', 'MAT1', '1000', '0002', 8.250)",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('123', 'MAT1', '2000', '0001', 100)",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('123', 'MAT2', '1000', '0001', 100)",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('999', 'MAT1', '1000', '0001', 999)",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('999', 'FOREIGN', '1000', '0001', 999)"
  ]);
}
