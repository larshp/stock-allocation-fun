import {SQLiteDatabaseClient} from "@abaplint/database-sqlite";
import {installBapiStockStub} from "../sap_stubs/bapi_reservation_create.mjs";

export async function initializeDatabase(abap, schemas, insert) {
  const database = new SQLiteDatabaseClient();
  await database.connect();
  await database.execute(schemas.sqlite);
  await database.execute(insert);
  await database.execute([
    "INSERT INTO vbak (mandt, vbeln, vbtyp) VALUES ('000', 'PRIO000001', 'C');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp) VALUES ('000', 'QUOT000001', 'B');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio) VALUES ('000', 'PRIO000001', '000010', 'MATERIAL-PRIO', '1000', '', '01');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio) VALUES ('000', 'QUOT000001', '000010', 'MATERIAL-PRIO', '1000', '', '02');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng) VALUES ('000', 'PRIO000001', '000010', '0001', '20260815', 5, 0);",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng) VALUES ('000', 'PRIO000001', '000010', '0002', '20260820', 3, 1);",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng) VALUES ('000', 'QUOT000001', '000010', '0001', '20260816', 9, 0);"
  ]);
  abap.context.databaseConnections.DEFAULT = database;
  installBapiStockStub(abap);
}
