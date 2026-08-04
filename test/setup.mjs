import {SQLiteDatabaseClient} from "@abaplint/database-sqlite";
import {installBapiStockStub} from "../sap_stubs/bapi_reservation_create.mjs";

export async function initializeDatabase(abap, schemas, insert) {
  const database = new SQLiteDatabaseClient();
  await database.connect();
  await database.execute(schemas.sqlite);
  await database.execute(insert);
  await database.execute([
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-STOCK', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-PRIO', 'ea');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-TXN-FAIL', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-BOX', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-DEMAND-FAIL', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-NO-TYPE', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-ERROR', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-NO-UNIT', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-NO-BASE', '');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-NEGATIVE', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins, lvorm) VALUES ('000', 'MATERIAL-DELETED', 'EA', 'X');",
    "INSERT INTO mara (mandt, matnr, meins) VALUES ('000', 'MATERIAL-STOCK-DELETED', 'EA');",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-BATCH-DELETED', 'EA', 'X');",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-BATCH-MASTER-DELETED', 'EA', 'X');",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-BATCH', 'EA', 'X');",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-BATCH-PRIO', 'EA', 'X');",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-BATCH-NO-MASTER', 'EA', 'X');",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-STOCK', '1000', '0001', 12);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst, lvorm) VALUES ('000', 'MATERIAL-STOCK-DELETED', '1000', '0001', 8, 'X');",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-NO-BASE', '1000', '0001', 1);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-TXN-FAIL', '1000', '0001', 1);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-NEGATIVE', '1000', '0001', -1);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-PRIO', '1000', '0001', 6);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-DEMAND-FAIL', '1000', '0001', 5);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-NO-TYPE', '1000', '0001', 5);",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('000', 'MATERIAL-ERROR', '1000', '0001', 1);",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-STOCK', '1000', '0001', 'BATCH-001', 4);",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-PRIO', '1000', '0001', 'BATCH-001', 6);",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-BATCH', '1000', '0001', 'BATCH-001', 4);",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-BATCH-PRIO', '1000', '0001', 'BATCH-001', 4);",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-BATCH-NO-MASTER', '1000', '0001', 'NOMASTER01', 4);",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs, lvorm) VALUES ('000', 'MATERIAL-BATCH-DELETED', '1000', '0001', 'BATCH-DEL', 8, 'X');",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-BATCH-MASTER-DELETED', '1000', '0001', 'BATCH-MDEL', 8);",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-EXPIRED', 'EA', 'X');",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-EXPIRED', '1000', '0001', 'EXPIRED-01', 4);",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat) VALUES ('000', 'MATERIAL-STOCK', '1000', 'BATCH-001', '20261231');",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat) VALUES ('000', 'MATERIAL-PRIO', '1000', 'BATCH-001', '20261231');",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat) VALUES ('000', 'MATERIAL-BATCH', '1000', 'BATCH-001', '20261231');",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat) VALUES ('000', 'MATERIAL-BATCH-PRIO', '1000', 'BATCH-001', '20261231');",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat) VALUES ('000', 'MATERIAL-EXPIRED', '1000', 'EXPIRED-01', '20200101');",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat, lvorm) VALUES ('000', 'MATERIAL-BATCH-MASTER-DELETED', '1000', 'BATCH-MDEL', '20261231', 'X');",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-RESTRICTED', 'EA', 'X');",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-RESTRICTED', '1000', '0001', 'BLOCKED-01', 4);",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat, zustd) VALUES ('000', 'MATERIAL-RESTRICTED', '1000', 'BLOCKED-01', '20261231', 'X');",
    "INSERT INTO mara (mandt, matnr, meins, xchpf) VALUES ('000', 'MATERIAL-EXPIRING', 'EA', 'X');",
    "INSERT INTO mchb (mandt, matnr, werks, lgort, charg, clabs) VALUES ('000', 'MATERIAL-EXPIRING', '1000', '0001', 'EXPIRE-01', 4);",
    "INSERT INTO mcha (mandt, matnr, werks, charg, vfdat) VALUES ('000', 'MATERIAL-EXPIRING', '1000', 'EXPIRE-01', '20260810');",
    "INSERT INTO mard (mandt, matnr, werks, lgort, labst) VALUES ('001', 'MATERIAL-STOCK', '1000', '0001', 99);",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'PRIO000001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'TXNFAIL0001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('001', 'OTHERCL001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'QUOT000001', 'B', 'QT', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'EXPIR00001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'BATCH00001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'NOUNIT0001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'DEMANDFAIL1', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'NOTYPE0001', 'C', '', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'MALFORM001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'NODATE0001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'RESERROR001', 'C', 'OR', '');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'BLKHEAD001', 'C', 'OR', '01');",
    "INSERT INTO vbak (mandt, vbeln, vbtyp, auart, lifsk) VALUES ('000', 'BLKITEM001', 'C', 'OR', '');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'PRIO000001', '000010', 'MATERIAL-PRIO', '1000', '', '01', 'ea');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'TXNFAIL0001', '000010', 'MATERIAL-TXN-FAIL', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('001', 'OTHERCL001', '000010', 'OTHER-CLIENT-MATERIAL', '1000', '', '10', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'QUOT000001', '000010', 'MATERIAL-PRIO', '1000', '', '02', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'EXPIR00001', '000010', 'MATERIAL-EXPIRING', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'BATCH00001', '000010', 'MATERIAL-BATCH-PRIO', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'NOUNIT0001', '000010', 'MATERIAL-NO-UNIT', '1000', '', '01', '');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'DEMANDFAIL1', '000010', 'MATERIAL-DEMAND-FAIL', '1000', '', '01', 'BOX');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'NOTYPE0001', '000010', 'MATERIAL-NO-TYPE', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'MALFORM001', '000000', 'MATERIAL-MALFORMED', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'NODATE0001', '000010', 'MATERIAL-NO-DATE', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'RESERROR001', '000010', 'MATERIAL-ERROR', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'BLKHEAD001', '000010', 'MATERIAL-PRIO', '1000', '', '01', 'EA');",
    "INSERT INTO vbap (mandt, vbeln, posnr, matnr, werks, abgru, lprio, vrkme) VALUES ('000', 'BLKITEM001', '000010', 'MATERIAL-PRIO', '1000', '', '01', 'EA');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'PRIO000001', '000010', '0001', '20260815', 5, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'TXNFAIL0001', '000010', '0001', '20260815', 1, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'PRIO000001', '000010', '0002', '20260820', 3, 1, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('001', 'OTHERCL001', '000010', '0001', '20260817', 100, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'QUOT000001', '000010', '0001', '20260816', 9, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'EXPIR00001', '000010', '0001', '20260815', 1, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'BATCH00001', '000010', '0001', '20260815', 4, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'NOUNIT0001', '000010', '0001', '20260815', 1, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'DEMANDFAIL1', '000010', '0001', '20260815', 1, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'RESERROR001', '000010', '0001', '20260815', 1, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'BLKHEAD001', '000010', '0001', '20260815', 2, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'BLKITEM001', '000010', '0001', '20260815', 2, 0, '01');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'NOTYPE0001', '000010', '0001', '20260815', 1, 0, '');",
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'MALFORM001', '000000', '0000', '20260815', 1, 0, '');"
  ]);
  await database.execute([
    "INSERT INTO vbep (mandt, vbeln, posnr, etenr, edatu, wmeng, bmeng, lifsp) VALUES ('000', 'NODATE0001', '000010', '0001', '00000000', 1, 0, '')"
  ]);
  abap.builtin.sy.get().mandt.set("000");
  abap.context.databaseConnections.DEFAULT = database;
  abap.Classes["KERNEL_AUTHORITY_CHECK"] = {
    call: async () => {
      abap.builtin.sy.get().subrc.set(0);
    },
  };
  installBapiStockStub(abap);
}
