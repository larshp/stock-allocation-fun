import { SQLiteDatabaseClient } from "@abaplint/database-sqlite";

export async function initializeDatabase(abap, schemas) {
  const database = new SQLiteDatabaseClient();
  await database.connect();
  await database.execute(schemas.sqlite);
  await database.execute([
    `INSERT INTO mara (mandt, matnr, meins) VALUES ('123', 'ZUT-SOURCE', 'EA')`,
    `INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('123', 'ZUT-SOURCE', 'UT01', 'UT01', 12.500)`,
    `INSERT INTO vbbe (mandt, vbeln, posnr, etenr, matnr, werks, lgort, mbdat, omeng)
       VALUES ('123', '0099999901', '000010', '0001', 'ZUT-SOURCE', 'UT01', 'UT01', '20260801', 7.000)`,
    `INSERT INTO vbbe (mandt, vbeln, posnr, etenr, matnr, werks, lgort, mbdat, omeng)
       VALUES ('123', '0099999902', '000020', '0001', 'ZUT-SOURCE', 'UT01', 'UT01', '20260802', 4.500)`,
    `INSERT INTO vbbe (mandt, vbeln, posnr, etenr, matnr, werks, lgort, mbdat, omeng)
       VALUES ('123', '0099999903', '000030', '0001', 'ZUT-SOURCE', 'UT01', 'UT01', '20260803', 0.000)`,
    `INSERT INTO zstockprio (mandt, matnr, werks, lgort, vbeln, posnr, priority)
       VALUES ('123', 'ZUT-SOURCE', 'UT01', 'UT01', '0099999902', '000020', 9)`,
  ]);
  abap.context.databaseConnections.DEFAULT = database;
}
