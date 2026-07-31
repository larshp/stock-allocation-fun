import {SQLiteDatabaseClient} from "@abaplint/database-sqlite";
import {installBapiStockStub} from "../sap_stubs/bapi_reservation_create.mjs";

export async function initializeDatabase(abap, schemas, insert) {
  const database = new SQLiteDatabaseClient();
  await database.connect();
  await database.execute(schemas.sqlite);
  await database.execute(insert);
  await database.execute([
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-STOCK', '1000', '0001', 12);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-PRIO', '1000', '0001', 6);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('001', 'MATERIAL-STOCK', '1000', '0001', 99);",
    "INSERT INTO vbak (mandt, vbeln, vbtyp) VALUES ('000', 'PRIO000001', 'C');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp) VALUES ('001', 'PRIO000001', 'C');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp) VALUES ('000', 'QUOT000001', 'B');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'PRIO000001', '000010', 'MATERIAL-PRIO', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('001', 'PRIO000001', '000010', 'MATERIAL-PRIO', '1000', '', '10', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'QUOT000001', '000010', 'MATERIAL-PRIO', '1000', '', '02', 'EA');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng) VALUES ('000', 'PRIO000001', '000010', '0001', '20260815', 5, 0);",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng) VALUES ('000', 'PRIO000001', '000010', '0002', '20260820', 3, 1);",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng) VALUES ('001', 'PRIO000001', '000010', '0001', '20260817', 100, 0);",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng) VALUES ('000', 'QUOT000001', '000010', '0001', '20260816', 9, 0);"
  ]);
  abap.builtin.sy.get().mandt.set("000");
  abap.context.databaseConnections.DEFAULT = database;
  installBapiStockStub(abap);
}
