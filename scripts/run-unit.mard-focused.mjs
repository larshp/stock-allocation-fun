import "../output/init.mjs";
import { SQLiteDatabaseClient } from "@abaplint/database-sqlite";

const database = new SQLiteDatabaseClient();
abap.context.databaseConnections.DEFAULT = database;
await database.connect();
await database.execute([
  `CREATE TABLE 'marc' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), umlmc DECIMAL(13,3),
    eisbe DECIMAL(13,3), bstmi DECIMAL(13,3), bstfe DECIMAL(13,3),
    bstrf DECIMAL(13,3), disls NCHAR(2), bstma DECIMAL(13,3),
    beskz NCHAR(1), sobsl NCHAR(2), plifz DECIMAL(3,0), webaz DECIMAL(3,0),
    kordb NCHAR(1), usequ NCHAR(1), mabst DECIMAL(13,3), mrppp NCHAR(3),
    rdprf NCHAR(4), xchar NCHAR(1), PRIMARY KEY(mandt, matnr, werks)
  );`,
  `CREATE TABLE 'mara' (
    mandt NCHAR(3), matnr NCHAR(40), meins NCHAR(3),
    PRIMARY KEY(mandt, matnr)
  );`,
  `CREATE TABLE 'marm' (
    mandt NCHAR(3), matnr NCHAR(40), meinh NCHAR(3),
    umrez DECIMAL(5,0), umren DECIMAL(5,0),
    PRIMARY KEY(mandt, matnr, meinh)
  );`,
  `CREATE TABLE 'eban' (
    mandt NCHAR(3), banfn NCHAR(10), bnfpo NCHAR(5), matnr NCHAR(40),
    werks NCHAR(4), lfdat NCHAR(8), menge DECIMAL(13,3),
    bsmng DECIMAL(13,3), meins NCHAR(3), loekz NCHAR(1), ebakz NCHAR(1),
    blckd NCHAR(1), pstyp NCHAR(1), knttp NCHAR(1), sobkz NCHAR(1),
    reswk NCHAR(4), lgort NCHAR(4), PRIMARY KEY(mandt, banfn, bnfpo)
  );`,
  `CREATE TABLE 't001w' (
    mandt NCHAR(3), werks NCHAR(4), fabkl NCHAR(2),
    PRIMARY KEY(mandt, werks)
  );`,
  `CREATE TABLE 't399d' (
    mandt NCHAR(3), werks NCHAR(4), bzteK NCHAR(2),
    PRIMARY KEY(mandt, werks)
  );`,
  `CREATE TABLE 'rdpr' (
    mandt NCHAR(3), werks NCHAR(4), rdprf NCHAR(4), rdzae NCHAR(6),
    bdmng DECIMAL(13,3), vormg DECIMAL(13,3),
    PRIMARY KEY(mandt, werks, rdprf, rdzae)
  );`,
  `CREATE TABLE 'eina' (
    mandt NCHAR(3), infnr NCHAR(10), matnr NCHAR(40), lifnr NCHAR(10),
    esokz NCHAR(1), loekz NCHAR(1), lifab NCHAR(8), lifbi NCHAR(8),
    meins NCHAR(3), lmein NCHAR(3), umrez DECIMAL(5,0), umren DECIMAL(5,0),
    PRIMARY KEY(mandt, infnr)
  );`,
  `CREATE TABLE 'eine' (
    mandt NCHAR(3), infnr NCHAR(10), ekorg NCHAR(4), werks NCHAR(4),
    aplfz DECIMAL(3,0), loekz NCHAR(1), aut_source NCHAR(1),
    minbm DECIMAL(13,3), bstma DECIMAL(13,3),
    PRIMARY KEY(mandt, infnr, ekorg, werks)
  );`,
  `CREATE TABLE 'eord' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), zeord NCHAR(5),
    lifnr NCHAR(10), ekorg NCHAR(4), ebeln NCHAR(10), ebelp NCHAR(5),
    vdatu NCHAR(8), bdatu NCHAR(8), notkz NCHAR(1), flifn NCHAR(1),
    autet NCHAR(1), PRIMARY KEY(mandt, matnr, werks, zeord)
  );`,
  `CREATE TABLE 'ekko' (
    mandt NCHAR(3), ebeln NCHAR(10), bstyp NCHAR(1), bsakz NCHAR(1),
    reswk NCHAR(4), lifnr NCHAR(10), ekorg NCHAR(4), kdatb NCHAR(8),
    kdate NCHAR(8), loekz NCHAR(1), PRIMARY KEY(mandt, ebeln)
  );`,
  `CREATE TABLE 'ekpo' (
    mandt NCHAR(3), ebeln NCHAR(10), ebelp NCHAR(5), matnr NCHAR(40),
    werks NCHAR(4), pstyp NCHAR(1), knttp NCHAR(1), loekz NCHAR(1),
    elikz NCHAR(1), retpo NCHAR(1), umrez DECIMAL(5,0), umren DECIMAL(5,0),
    wepos NCHAR(1), insmk NCHAR(1), stapo NCHAR(1), lgort NCHAR(4),
    PRIMARY KEY(mandt, ebeln, ebelp)
  );`,
  `CREATE TABLE 'eket' (
    mandt NCHAR(3), ebeln NCHAR(10), ebelp NCHAR(5), etenr NCHAR(4),
    eindt NCHAR(8), menge DECIMAL(13,3), wemng DECIMAL(13,3),
    wamng DECIMAL(13,3), dabmg DECIMAL(13,3), charg NCHAR(10),
    PRIMARY KEY(mandt, ebeln, ebelp, etenr)
  );`,
  `CREATE TABLE 'ekes' (
    mandt NCHAR(3), ebeln NCHAR(10), ebelp NCHAR(5), etens NCHAR(4),
    ebtyp NCHAR(2), eindt NCHAR(8), menge DECIMAL(13,3),
    dabmg DECIMAL(13,3), loekz NCHAR(1), kzdis NCHAR(1), charg NCHAR(10),
    PRIMARY KEY(mandt, ebeln, ebelp, etens)
  );`,
  `CREATE TABLE 'equk' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), bdatu NCHAR(8),
    vdatu NCHAR(8), qunum NCHAR(10), scmng DECIMAL(13,3),
    PRIMARY KEY(mandt, matnr, werks, qunum)
  );`,
  `CREATE TABLE 'equp' (
    mandt NCHAR(3), qunum NCHAR(10), qupos NCHAR(3), beskz NCHAR(1),
    sobes NCHAR(2), lifnr NCHAR(10), quote DECIMAL(3,0),
    qubmg DECIMAL(13,3), qumng DECIMAL(13,3), preih NCHAR(2),
    minls DECIMAL(13,3), maxls DECIMAL(13,3), kzein NCHAR(1),
    maxmg DECIMAL(13,3), rdprf NCHAR(4),
    PRIMARY KEY(mandt, qunum, qupos)
  );`,
  `CREATE TABLE 'tmq2' (
    mandt NCHAR(3), usequ NCHAR(1), qbest NCHAR(1), qlpet NCHAR(1),
    qplaf NCHAR(1), qbanf NCHAR(1), qdisp NCHAR(1), qfauf NCHAR(1),
    qfir NCHAR(1), PRIMARY KEY(mandt, usequ)
  );`,
  `CREATE TABLE 'afko' (
    mandt NCHAR(3), aufnr NCHAR(12), aufpl NCHAR(10), gltrp NCHAR(8),
    gstrp NCHAR(8), gstrs NCHAR(8), gltrs NCHAR(8), gsuzs NCHAR(6),
    gluzs NCHAR(6), PRIMARY KEY(mandt, aufnr)
  );`,
  `CREATE TABLE 'afpo' (
    mandt NCHAR(3), aufnr NCHAR(12), posnr NCHAR(4), matnr NCHAR(40),
    werks NCHAR(4), psmng DECIMAL(13,3), wemng DECIMAL(13,3),
    umrez DECIMAL(5,0), umren DECIMAL(5,0), wepos NCHAR(1), xloek NCHAR(1),
    elikz NCHAR(1), kdauf NCHAR(10), knttp NCHAR(1), amein NCHAR(3),
    meins NCHAR(3), lgort NCHAR(4), charg NCHAR(10), kdpos NCHAR(6),
    berid NCHAR(10), projn NCHAR(8), plnum NCHAR(10), pwerk NCHAR(4),
    verid NCHAR(4), strmp NCHAR(8), dwerk NCHAR(4), sobkz NCHAR(1),
    insmk NCHAR(1), wempf NCHAR(12), ablad NCHAR(25), kdein NCHAR(4),
    PRIMARY KEY(mandt, aufnr, posnr)
  );`,
  `CREATE TABLE 'aufk' (
    mandt NCHAR(3), aufnr NCHAR(12), autyp NCHAR(2), phas1 NCHAR(1),
    phas2 NCHAR(1), phas3 NCHAR(1), loekz NCHAR(1), objnr NCHAR(22),
    stsma NCHAR(8), auart NCHAR(4), erdat NCHAR(8), ernam NCHAR(12),
    aedat NCHAR(8), aenam NCHAR(12), ktext NCHAR(40),
    PRIMARY KEY(mandt, aufnr)
  );`,
  `CREATE TABLE 'afvc' (
    mandt NCHAR(3), aufpl NCHAR(10), aplzl NCHAR(8), plnfl NCHAR(6),
    vornr NCHAR(4), uvorn NCHAR(4), ltxa1 NCHAR(40), steus NCHAR(4),
    PRIMARY KEY(mandt, aufpl, aplzl)
  );`,
  `CREATE TABLE 'afru' (
    mandt NCHAR(3), rueck NCHAR(10), rmzhl NCHAR(8), aufnr NCHAR(12),
    aufpl NCHAR(10), aplzl NCHAR(8), budat NCHAR(8), aueru NCHAR(1),
    stokz NCHAR(1), lmnga DECIMAL(13,3), rmnga DECIMAL(13,3),
    xmnga DECIMAL(13,3), meinh NCHAR(3),
    PRIMARY KEY(mandt, rueck, rmzhl)
  );`,
  `CREATE TABLE 'jest' (
    mandt NCHAR(3), objnr NCHAR(22), stat NCHAR(5), chgnr NCHAR(3),
    inact NCHAR(1), PRIMARY KEY(mandt, objnr, stat, chgnr)
  );`,
  `CREATE TABLE 'tj02t' (
    mandt NCHAR(3), istat NCHAR(5), spras NCHAR(1), txt04 NCHAR(4),
    txt30 NCHAR(30), PRIMARY KEY(mandt, istat, spras)
  );`,
  `CREATE TABLE 'tj30t' (
    mandt NCHAR(3), stsma NCHAR(8), estat NCHAR(5), spras NCHAR(1),
    txt04 NCHAR(4), txt30 NCHAR(30),
    PRIMARY KEY(mandt, stsma, estat, spras)
  );`,
  `CREATE TABLE 't439i' (
    mandt NCHAR(3), werks NCHAR(4), mrppp NCHAR(3),
    ppbis NCHAR(8), ppvon NCHAR(8),
    PRIMARY KEY(mandt, werks, mrppp, ppbis, ppvon)
  );`,
  `CREATE TABLE 'vbap' (
    mandt NCHAR(3), vbeln NCHAR(10), posnr NCHAR(6),
    kwmeng DECIMAL(13,3), vsmng DECIMAL(13,3),
    matnr NCHAR(40), werks NCHAR(4), PRIMARY KEY(mandt, vbeln, posnr)
  );`,
  `CREATE TABLE 'vbup' (
    mandt NCHAR(3), vbeln NCHAR(10), posnr NCHAR(6), lfsta NCHAR(1),
    PRIMARY KEY(mandt, vbeln, posnr)
  );`,
  `CREATE TABLE 'vbep' (
    mandt NCHAR(3), vbeln NCHAR(10), posnr NCHAR(6), etenr NCHAR(4),
    edatu NCHAR(8), mbdat NCHAR(8), wmeng DECIMAL(13,3),
    bmeng DECIMAL(13,3), vsmng DECIMAL(13,3),
    PRIMARY KEY(mandt, vbeln, posnr, etenr)
  );`,
  `CREATE TABLE 'mska' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), lgort NCHAR(4),
    charg NCHAR(10), sobkz NCHAR(1), kdauf NCHAR(10), kdpos NCHAR(6),
    kalab DECIMAL(13,3),
    PRIMARY KEY(mandt, matnr, werks, lgort, charg, sobkz, kdauf, kdpos)
  );`,
  `CREATE TABLE 'plaf' (
    mandt NCHAR(3), plnum NCHAR(10), matnr NCHAR(40), pwwrk NCHAR(4),
    psttr NCHAR(8), pedtr NCHAR(8), gsmng DECIMAL(13,3), meins NCHAR(3),
    auffx NCHAR(1), plscn NCHAR(3), sobkz NCHAR(1), kdauf NCHAR(10),
    lgort NCHAR(4), paart NCHAR(4), beskz NCHAR(1), dispo NCHAR(3),
    plgrp NCHAR(3), verid NCHAR(4), berid NCHAR(10), knttp NCHAR(1),
    kdpos NCHAR(6), kdein NCHAR(4), plwrk NCHAR(4), pertr NCHAR(8),
    gstrs NCHAR(8), gsuzs NCHAR(6), gltrs NCHAR(8), gluzs NCHAR(6),
    puser NCHAR(12), pstmp DECIMAL(15,0), sobes NCHAR(1),
    PRIMARY KEY(mandt, plnum)
  );`,
  `CREATE TABLE 'mard' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), lgort NCHAR(4),
    labst DECIMAL(13,3), umlme DECIMAL(13,3), insme DECIMAL(13,3),
    speme DECIMAL(13,3), PRIMARY KEY(mandt, matnr, werks, lgort)
  );`,
  `CREATE TABLE 'mchb' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), lgort NCHAR(4),
    charg NCHAR(10), clabs DECIMAL(13,3), cumlm DECIMAL(13,3),
    cinsm DECIMAL(13,3), cspem DECIMAL(13,3),
    PRIMARY KEY(mandt, matnr, werks, lgort, charg)
  );`,
  `CREATE TABLE 'mcha' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), charg NCHAR(10),
    vfdat NCHAR(8), bwtar NCHAR(10),
    PRIMARY KEY(mandt, matnr, werks, charg)
  );`,
  `CREATE TABLE 'mch1' (
    mandt NCHAR(3), matnr NCHAR(40), charg NCHAR(10), vfdat NCHAR(8),
    PRIMARY KEY(mandt, matnr, charg)
  );`,
  `CREATE TABLE 'mspr' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), lgort NCHAR(4),
    charg NCHAR(10), sobkz NCHAR(1), pspnr NCHAR(8), prlab DECIMAL(13,3),
    PRIMARY KEY(mandt, matnr, werks, lgort, charg, sobkz, pspnr)
  );`,
  `CREATE TABLE 'prps' (
    mandt NCHAR(3), pspnr NCHAR(8), posid NCHAR(24),
    PRIMARY KEY(mandt, pspnr)
  );`,
  `CREATE TABLE 'resb' (
    mandt NCHAR(3), matnr NCHAR(40), werks NCHAR(4), lgort NCHAR(4),
    sobkz NCHAR(1), xloek NCHAR(1), kzear NCHAR(1), bdmng DECIMAL(13,3),
    enmng DECIMAL(13,3), charg NCHAR(10), bwart NCHAR(3), kdauf NCHAR(10),
    kdpos NCHAR(6), kdein NCHAR(4), bdter NCHAR(8), aufnr NCHAR(12),
    rsnum NCHAR(10), rspos NCHAR(4), meins NCHAR(3), pspel NCHAR(8),
    erfme NCHAR(3), bwtar NCHAR(10), PRIMARY KEY(mandt, rsnum, rspos)
  );`,
  `CREATE TABLE 'rkpf' (
    mandt NCHAR(3), rsnum NCHAR(10), kostl NCHAR(10),
    PRIMARY KEY(mandt, rsnum)
  );`,
]);

await import("../output/index.mard-focused.mjs");
