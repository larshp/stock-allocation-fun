import {SQLiteDatabaseClient} from "@abaplint/database-sqlite";

export async function setup(abap, schemas, insert) {
  const db = new SQLiteDatabaseClient();
  abap.context.databaseConnections.DEFAULT = db;
  await db.connect();
  await db.execute(schemas.sqlite);
  await db.execute(insert);
  // Fixtures are outside production ABAP; SAP standard tables are never written by src.
  await db.execute(`INSERT INTO mara (mandt, matnr, meins) VALUES
    ('123', 'MAT1', 'EA'), ('123', 'NEGATIVE', 'KG'), ('123', 'DELETED', 'EA');`);
  await db.execute(`INSERT INTO mard (mandt, matnr, werks, lgort, labst, lvorm) VALUES
    ('123', 'MAT1', '1000', '0001', 10, ''),
    ('123', 'MAT1', '1000', '0002', 25, ''),
    ('123', 'MAT1', '2000', '0001', 50, ''),
    ('123', 'NEGATIVE', '1000', '0001', -3, ''),
    ('123', 'DELETED', '1000', '0001', 100, 'X'),
    ('123', 'NO_MASTER', '1000', '0001', 5, '');`);
  const components = [
    ['0001', '000000001000', 10, 2, '20260906', '', '', 'H', ''],
    ['0002', '000000001000', 6, 0, '20260907', '', '', 'H', ''],
    ['0003', '000000001000', 5, 0, '20260906', 'X', '', 'H', ''],
    ['0004', '000000001000', 5, 0, '20260906', '', 'X', 'H', ''],
    ['0005', '000000001000', 5, 5, '20260906', '', '', 'H', ''],
    ['0006', '000000001000', 5, 7, '20260906', '', '', 'H', ''],
    ['0007', '000000001000', 5, 0, '20260906', '', '', 'S', ''],
    ['0008', '000000001000', 5, 0, '20260906', '', '', 'H', 'E'],
    ['0009', '000000002000', 99, 0, '20260906', '', '', 'H', ''],
  ];
  for (const [item, order, required, withdrawn, date, deleted, finalIssue, sign, special] of components) {
    await db.execute(`INSERT INTO resb
      (mandt, rsnum, rspos, rsart, aufnr, matnr, werks, lgort, meins,
       bdmng, enmng, bdter, xloek, kzear, shkzg, sobkz) VALUES
      ('123', '0000000100', '${item}', '', '${order}', 'MAT1', '1000', '0001', 'EA',
       ${required}, ${withdrawn}, '${date}', '${deleted}', '${finalIssue}', '${sign}', '${special}');`);
  }
}
