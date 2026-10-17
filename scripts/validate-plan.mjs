import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const errors = [];
const requiredRules = [
  "modify_only_own_db_tables",
  "align_type_expressions",
  "easy_to_find_messages",
  "max_one_method_parameter_per_line",
  "align_parameters",
  "local_testclass_consistency",
  "allowed_object_naming",
  "line_length",
];

function readJson(path) {
  try {
    return JSON.parse(readFileSync(join(projectRoot, path), "utf8"));
  } catch (error) {
    errors.push(`Could not read ${path}: ${error.message}`);
    return {};
  }
}

function normalizePath(path) {
  return path.replaceAll("\\", "/").replace(/^\/+/, "").toLowerCase();
}

const lintConfig = readJson("abaplint.json");
const transpileConfig = readJson("abap_transpile.json");

for (const rule of requiredRules) {
  if (lintConfig.rules?.[rule] !== true) {
    errors.push(`abaplint rule ${rule} must be enabled`);
  }
}

if (normalizePath(lintConfig.global?.files ?? "") !== "src/**/*.*") {
  errors.push("abaplint global files must include /src/**/*.*");
}

if (!lintConfig.dependencies?.some((dependency) =>
  dependency.url?.includes("open-abap/open-abap-core"))) {
  errors.push("abaplint must depend on open-abap/open-abap-core");
}

if (!lintConfig.dependencies?.some((dependency) =>
  normalizePath(dependency.folder ?? "") === "stubs/src")) {
  errors.push("abaplint must include stubs/src as a dependency");
}

if (!transpileConfig.input_folder?.some((folder) =>
  normalizePath(folder) === "src")) {
  errors.push("transpiler input_folder must include src");
}

if (!transpileConfig.input_folder?.some((folder) =>
  normalizePath(folder) === "stubs/src")) {
  errors.push("transpiler input_folder must include stubs/src");
}

if (!transpileConfig.libs?.some((library) =>
  library.url?.includes("open-abap/open-abap-core"))) {
  errors.push("transpiler must depend on open-abap/open-abap-core");
}

for (const path of [
  "PLAN.md",
  "NOTES.md",
  "ANOMALIES.md",
  "stubs/src/mard.tabl.xml",
  "stubs/src/mara.tabl.xml",
  "stubs/src/marm.tabl.xml",
  "stubs/src/t001w.tabl.xml",
  "stubs/src/t399d.tabl.xml",
  "stubs/src/rdpr.tabl.xml",
  "stubs/src/afko.tabl.xml",
  "stubs/src/aufk.tabl.xml",
  "stubs/src/afvc.tabl.xml",
  "stubs/src/afru.tabl.xml",
  "stubs/src/jest.tabl.xml",
  "stubs/src/tj02t.tabl.xml",
  "stubs/src/tj30t.tabl.xml",
  "stubs/src/eina.tabl.xml",
  "stubs/src/eine.tabl.xml",
  "stubs/src/eord.tabl.xml",
  "stubs/src/ekko.tabl.xml",
  "stubs/src/t439i.tabl.xml",
  "stubs/src/resb.tabl.xml",
  "stubs/src/rkpf.tabl.xml",
  "stubs/src/ekpo.tabl.xml",
  "stubs/src/eket.tabl.xml",
  "stubs/src/ekes.tabl.xml",
  "stubs/src/afpo.tabl.xml",
  "stubs/src/eban.tabl.xml",
  "stubs/src/plaf.tabl.xml",
  "stubs/src/vbap.tabl.xml",
  "stubs/src/vbep.tabl.xml",
  "stubs/src/vbup.tabl.xml",
  "stubs/src/mska.tabl.xml",
  "stubs/src/mspr.tabl.xml",
  "stubs/src/prps.tabl.xml",
  "stubs/src/mcha.tabl.xml",
  "stubs/src/mch1.tabl.xml",
  "src/zcl_mard_stock_repository.clas.abap",
  "src/zcl_material_uom_repository.clas.abap",
  "src/zcl_marc_repl_policy_repo.clas.abap",
  "src/zcl_prod_order_read_repo.clas.abap",
  "src/zcl_plaf_order_read_repo.clas.abap",
  "src/zcl_prod_comp_repo.clas.abap",
  "src/zcl_stock_transfer_repository.clas.abap",
  "src/zcl_so_stock_repository.clas.abap",
  "src/zcl_sales_order_delivery_repo.clas.abap",
  "src/zcl_cc_reservation_read_repo.clas.abap",
  "src/zcl_project_stock_repository.clas.abap",
  "src/zcl_t439i_cal_period_repo.clas.abap",
  "src/zcl_repl_source_repo.clas.abap",
]) {
  if (!existsSync(join(projectRoot, path))) {
    errors.push(`Required project artifact is missing: ${path}`);
  }
}

const requiredStubFields = {
  "stubs/src/mara.tabl.xml": ["MANDT", "MATNR", "MEINS"],
  "stubs/src/marm.tabl.xml": [
    "MANDT",
    "MATNR",
    "MEINH",
    "UMREZ",
    "UMREN",
  ],
  "stubs/src/t001w.tabl.xml": ["MANDT", "WERKS", "FABKL"],
  "stubs/src/t399d.tabl.xml": ["MANDT", "WERKS", "BZTEK"],
  "stubs/src/rdpr.tabl.xml": [
    "MANDT",
    "WERKS",
    "RDPRF",
    "RDZAE",
    "BDMNG",
    "VORMG",
  ],
  "stubs/src/eina.tabl.xml": [
    "MANDT", "INFNR", "MATNR", "LIFNR", "ESOKZ", "LOEKZ", "LIFAB",
    "LIFBI", "MEINS", "LMEIN", "UMREZ", "UMREN",
  ],
  "stubs/src/eine.tabl.xml": [
    "MANDT", "INFNR", "EKORG", "WERKS", "APLFZ", "LOEKZ", "AUT_SOURCE",
    "MINBM", "BSTMA",
  ],
  "stubs/src/eord.tabl.xml": [
    "MANDT", "MATNR", "WERKS", "ZEORD", "LIFNR", "EKORG", "EBELN",
    "EBELP", "VDATU", "BDATU", "NOTKZ", "FLIFN", "AUTET",
  ],
  "stubs/src/ekko.tabl.xml": [
    "MANDT", "EBELN", "BSTYP", "BSAKZ", "RESWK", "LIFNR", "EKORG",
    "KDATB", "KDATE", "LOEKZ",
  ],
  "stubs/src/ekpo.tabl.xml": [
    "MANDT", "EBELN", "EBELP", "MATNR", "WERKS", "PSTYP", "KNTTP",
    "LOEKZ", "ELIKZ", "RETPO", "UMREZ", "UMREN", "WEPOS", "INSMK",
    "STAPO", "LGORT",
  ],
  "stubs/src/equk.tabl.xml": [
    "MANDT", "MATNR", "WERKS", "BDATU", "VDATU", "QUNUM", "SCMNG",
  ],
  "stubs/src/equp.tabl.xml": [
    "MANDT", "QUNUM", "QUPOS", "BESKZ", "SOBES", "LIFNR", "QUOTE",
    "QUBMG", "QUMNG", "PREIH", "MINLS", "MAXLS", "KZEIN", "MAXMG",
    "RDPRF",
  ],
  "stubs/src/tmq2.tabl.xml": [
    "MANDT", "USEQU", "QBEST", "QLPET", "QPLAF", "QBANF", "QDISP",
    "QFAUF", "QFIR",
  ],
  "stubs/src/marc.tabl.xml": ["MANDT", "MATNR", "WERKS", "UMLMC"],
  "stubs/src/afko.tabl.xml": [
    "MANDT", "AUFNR", "AUFPL", "GSTRP", "GLTRP",
  ],
  "stubs/src/afpo.tabl.xml": [
    "MANDT", "AUFNR", "POSNR", "MATNR", "WERKS", "PSMNG", "WEMNG",
    "UMREZ", "UMREN", "WEPOS", "XLOEK", "ELIKZ", "AMEIN", "MEINS",
  ],
  "stubs/src/aufk.tabl.xml": [
    "MANDT", "AUFNR", "AUTYP", "PHAS1", "PHAS2", "PHAS3", "LOEKZ",
    "OBJNR", "STSMA",
  ],
  "stubs/src/afvc.tabl.xml": [
    "MANDT", "AUFPL", "APLZL", "PLNFL", "VORNR", "UVORN", "LTXA1",
    "STEUS",
  ],
  "stubs/src/afru.tabl.xml": [
    "MANDT", "RUECK", "RMZHL", "AUFNR", "AUFPL", "APLZL", "BUDAT",
    "AUERU", "STOKZ", "LMNGA", "RMNGA", "XMNGA", "MEINH",
  ],
  "stubs/src/jest.tabl.xml": [
    "MANDT", "OBJNR", "STAT", "CHGNR", "INACT",
  ],
  "stubs/src/tj02t.tabl.xml": [
    "MANDT", "ISTAT", "SPRAS", "TXT04", "TXT30",
  ],
  "stubs/src/tj30t.tabl.xml": [
    "MANDT", "STSMA", "ESTAT", "SPRAS", "TXT04", "TXT30",
  ],
  "stubs/src/t439i.tabl.xml": [
    "MANDT",
    "WERKS",
    "MRPPP",
    "PPVON",
    "PPBIS",
  ],
  "stubs/src/vbap.tabl.xml": [
    "MANDT",
    "VBELN",
    "POSNR",
    "KWMENG",
    "VSMNG",
    "MATNR",
    "WERKS",
  ],
  "stubs/src/vbep.tabl.xml": [
    "MANDT",
    "VBELN",
    "POSNR",
    "ETENR",
    "EDATU",
    "MBDAT",
    "WMENG",
    "BMENG",
    "VSMNG",
  ],
  "stubs/src/vbup.tabl.xml": ["MANDT", "VBELN", "POSNR", "LFSTA"],
  "stubs/src/mska.tabl.xml": [
    "MANDT",
    "MATNR",
    "WERKS",
    "LGORT",
    "CHARG",
    "SOBKZ",
    "KDAUF",
    "KDPOS",
    "KALAB",
  ],
  "stubs/src/mspr.tabl.xml": [
    "MANDT",
    "MATNR",
    "WERKS",
    "LGORT",
    "CHARG",
    "SOBKZ",
    "PSPNR",
    "PRLAB",
  ],
  "stubs/src/prps.tabl.xml": ["MANDT", "PSPNR", "POSID"],
  "stubs/src/mcha.tabl.xml": [
    "MANDT",
    "MATNR",
    "WERKS",
    "CHARG",
    "VFDAT",
  ],
  "stubs/src/mch1.tabl.xml": ["MANDT", "MATNR", "CHARG", "VFDAT"],
  "stubs/src/mard.tabl.xml": [
    "MANDT",
    "MATNR",
    "WERKS",
    "LGORT",
    "LABST",
    "UMLME",
  ],
  "stubs/src/mchb.tabl.xml": [
    "MANDT",
    "MATNR",
    "WERKS",
    "LGORT",
    "CHARG",
    "CUMLM",
  ],
  "stubs/src/resb.tabl.xml": [
    "MANDT",
    "MATNR",
    "WERKS",
    "RSNUM",
    "RSPOS",
    "BDTER",
    "BDMNG",
    "ENMNG",
    "LGORT",
    "CHARG",
    "SOBKZ",
    "XLOEK",
    "KZEAR",
  ],
  "stubs/src/rkpf.tabl.xml": ["MANDT", "RSNUM", "KOSTL"],
  "stubs/src/ekpo.tabl.xml": ["EBELN", "EBELP", "MATNR", "WERKS", "LGORT"],
  "stubs/src/eket.tabl.xml": ["EBELN", "EBELP", "ETENR", "EINDT", "CHARG"],
  "stubs/src/ekes.tabl.xml": ["EBELN", "EBELP", "ETENS", "EINDT", "CHARG"],
  "stubs/src/afpo.tabl.xml": ["LGORT", "CHARG"],
  "stubs/src/eban.tabl.xml": ["LGORT"],
  "stubs/src/plaf.tabl.xml": [
    "MANDT",
    "PLNUM",
    "MATNR",
    "PWWRK",
    "PSTTR",
    "PEDTR",
    "GSMNG",
    "MEINS",
    "AUFFX",
    "PLSCN",
    "SOBKZ",
    "KDAUF",
    "LGORT",
  ],
};

for (const [path, fields] of Object.entries(requiredStubFields)) {
  if (!existsSync(join(projectRoot, path))) {
    continue;
  }
  const stub = readFileSync(join(projectRoot, path), "utf8");
  for (const field of fields) {
    if (!stub.includes(`<FIELDNAME>${field}</FIELDNAME>`)) {
      errors.push(`${path} must define field ${field}`);
    }
  }
}

const salesDeliveryRepoPath =
  "src/zcl_sales_order_delivery_repo.clas.abap";
if (existsSync(join(projectRoot, salesDeliveryRepoPath))) {
  const salesDeliveryRepo = readFileSync(
    join(projectRoot, salesDeliveryRepoPath),
    "utf8",
  );
  const bulkStart = salesDeliveryRepo.indexOf(
    "METHOD zif_sales_order_delivery_repo~get_orders_items.",
  );
  const bulkEnd = salesDeliveryRepo.indexOf("ENDMETHOD.", bulkStart);
  const bulkMethod = salesDeliveryRepo.slice(bulkStart, bulkEnd);
  if (bulkStart < 0 || bulkEnd < 0
      || !/DATA lt_statuses TYPE HASHED TABLE OF vbup\s+WITH UNIQUE KEY vbeln posnr\./i.test(bulkMethod)
      || !/DATA lt_schedules TYPE SORTED TABLE OF vbep\s+WITH NON-UNIQUE KEY vbeln posnr edatu etenr\./i.test(bulkMethod)) {
    errors.push(
      `${salesDeliveryRepoPath} must index delivery status and sort schedule rows by order item/date`,
    );
  }
}

const stockTransferRepoPath = "src/zcl_stock_transfer_repository.clas.abap";
if (existsSync(join(projectRoot, stockTransferRepoPath))) {
  const stockTransferRepo = readFileSync(
    join(projectRoot, stockTransferRepoPath),
    "utf8",
  );
  const stockTransferStart = stockTransferRepo.indexOf(
    "METHOD zif_stock_transfer_repository~get_stock_in_transfer_bulk.",
  );
  const stockTransferEnd = stockTransferRepo.indexOf(
    "ENDMETHOD.",
    stockTransferStart,
  );
  const stockTransferBulk = stockTransferRepo.slice(
    stockTransferStart,
    stockTransferEnd,
  );
  const scalarStart = stockTransferRepo.indexOf(
    "METHOD zif_stock_transfer_repository~get_stock_in_transfer.",
  );
  const scalarEnd = stockTransferRepo.indexOf("ENDMETHOD.", scalarStart);
  const scalarMethod = stockTransferRepo.slice(scalarStart, scalarEnd);
  const stockTransferTestPath = join(
    projectRoot,
    "src/zcl_stock_transfer_repository.clas.testclasses.abap",
  );
  const stockTransferTests = existsSync(stockTransferTestPath)
    ? readFileSync(stockTransferTestPath, "utf8").toLowerCase()
      .replace(/\s+/g, " ")
    : "";
  const overflowTestStart = stockTransferTests.indexOf(
    "method rejects_location_sum_overflow.",
  );
  const overflowTestEnd = stockTransferTests.indexOf(
    "endmethod.",
    overflowTestStart,
  );
  const overflowTest = stockTransferTests.slice(
    overflowTestStart,
    overflowTestEnd,
  );
  const stockTransferInterface = readFileSync(
    join(projectRoot, "src/zif_stock_transfer_repository.intf.abap"),
    "utf8",
  ).toLowerCase();
  const locationsStart = stockTransferRepo.indexOf(
    "METHOD zif_stock_transfer_repository~get_transfer_locations_bulk.",
  );
  const locationsEnd = stockTransferRepo.indexOf("ENDMETHOD.", locationsStart);
  const locationsBulk = stockTransferRepo.slice(locationsStart, locationsEnd);
  const batchesStart = stockTransferRepo.indexOf(
    "METHOD zif_stock_transfer_repository~get_transfer_batches_bulk.",
  );
  const batchesEnd = stockTransferRepo.indexOf("ENDMETHOD.", batchesStart);
  const batchesBulk = stockTransferRepo.slice(batchesStart, batchesEnd);
  if (stockTransferStart < 0 || stockTransferEnd < 0
      || scalarStart < 0 || scalarEnd < 0
      || !/SELECT umlme\s+FROM mard[\s\S]*?INTO TABLE @lt_location_quantities/i.test(scalarMethod)
      || !/DATA lv_location_total TYPE decfloat34\./i.test(scalarMethod)
      || !/CONV mard-umlme\( lv_location_total \)/i.test(scalarMethod)
      || !/CATCH cx_sy_conversion_overflow\./i.test(scalarMethod)
      || !/CONV mard-umlme\( lv_location_quantity \)/i.test(stockTransferBulk)
      || !/CATCH cx_sy_conversion_overflow\./i.test(stockTransferBulk)
      || (stockTransferInterface.match(/RAISING\s+zcx_invalid_stock_request/gi) || []).length < 2
      || overflowTestStart < 0 || overflowTestEnd < 0
      || !overflowTest.includes("zif_stock_transfer_repository~get_stock_in_transfer(")
      || !overflowTest.includes("zif_stock_transfer_repository~get_stock_in_transfer_bulk(")
      || !stockTransferTests.includes("9999999999.999")
      || !overflowTest.includes("lv_scalar_rejected")
      || !overflowTest.includes("lv_bulk_rejected")
      || !overflowTest.includes("catch zcx_invalid_stock_request.")
      || !/ty_plant_totals TYPE HASHED TABLE OF ty_plant_row\s+WITH UNIQUE KEY material plant/i.test(stockTransferBulk)
      || !/INTO CORRESPONDING FIELDS OF TABLE @lt_plant_totals/i.test(stockTransferBulk)
      || !/ty_location_totals TYPE HASHED TABLE OF ty_location_total\s+WITH UNIQUE KEY material plant/i.test(stockTransferBulk)
      || !/ty_storage_location_totals TYPE HASHED TABLE OF\s+ty_storage_location_total\s+WITH UNIQUE KEY material plant storage_location/i.test(stockTransferBulk)
      || !/ty_location_rows TYPE STANDARD TABLE OF ty_location_row WITH EMPTY KEY/i.test(stockTransferBulk)
      || locationsStart < 0 || locationsEnd < 0
      || !/ty_location_rows TYPE SORTED TABLE OF ty_location_row\s+WITH NON-UNIQUE KEY material plant storage_location/i.test(locationsBulk)
      || batchesStart < 0 || batchesEnd < 0
      || !/ty_batch_rows TYPE SORTED TABLE OF ty_batch_row\s+WITH NON-UNIQUE KEY material plant storage_location batch/i.test(batchesBulk)) {
    errors.push(
      `${stockTransferRepoPath} must safely aggregate transfer quantities and key detail rows by scope`,
    );
  }
}

const productionOrderReadRepoPath = "src/zcl_prod_order_read_repo.clas.abap";
if (existsSync(join(projectRoot, productionOrderReadRepoPath))) {
  const productionOrderReadRepo = readFileSync(
    join(projectRoot, productionOrderReadRepoPath),
    "utf8",
  );
  const statusStart = productionOrderReadRepo.indexOf(
    "METHOD zif_prod_order_read_repo~read_order_statuses.",
  );
  const statusEnd = productionOrderReadRepo.indexOf("ENDMETHOD.", statusStart);
  const statusMethod = productionOrderReadRepo.slice(statusStart, statusEnd);
  if (statusStart < 0 || statusEnd < 0
      || !/ty_active_order_statuses TYPE SORTED TABLE OF\s+ty_active_order_status WITH NON-UNIQUE KEY objnr/i.test(statusMethod)) {
    errors.push(
      `${productionOrderReadRepoPath} must index active JEST rows by object number`,
    );
  }

  const operationsStart = productionOrderReadRepo.indexOf(
    "METHOD zif_prod_order_read_repo~read_operations.",
  );
  const operationsEnd = productionOrderReadRepo.indexOf(
    "ENDMETHOD.",
    operationsStart,
  );
  const operationsMethod = productionOrderReadRepo.slice(
    operationsStart,
    operationsEnd,
  );
  if (operationsStart < 0 || operationsEnd < 0
      || !/ty_order_routings TYPE SORTED TABLE OF ty_order_routing\s+WITH NON-UNIQUE KEY aufpl/i.test(operationsMethod)) {
    errors.push(
      `${productionOrderReadRepoPath} must index order routings by routing number`,
    );
  }
}

const projectStockRepoPath = "src/zcl_project_stock_repository.clas.abap";
if (existsSync(join(projectRoot, projectStockRepoPath))) {
  const projectStockRepo = readFileSync(
    join(projectRoot, projectStockRepoPath),
    "utf8",
  );
  const wbsElementLookupReads = projectStockRepo.match(
    /READ TABLE lt_wbs_mappings INTO DATA\(ls_wbs_mapping\)\s+WITH TABLE KEY wbs_element =/gi,
  ) ?? [];
  const wbsNumberLookupReads = projectStockRepo.match(
    /READ TABLE lt_wbs_number_mappings INTO DATA\(ls_wbs_mapping\)\s+WITH TABLE KEY wbs_number =/gi,
  ) ?? [];
  const wbsNumberFaes = projectStockRepo.match(
    /FOR ALL ENTRIES IN @lt_wbs_number_mappings/gi,
  ) ?? [];
  const projectOpenReservationTestsPath = join(
    projectRoot,
    "src/zcl_project_stock_repository.clas.testclasses.abap",
  );
  const projectOpenReservationTests = existsSync(
    projectOpenReservationTestsPath,
  )
    ? readFileSync(projectOpenReservationTestsPath, "utf8")
    : "";
  const compactProjectOpenReservationTests = projectOpenReservationTests
    .replace(/\s+/g, " ")
    .toLowerCase();
  const projectOpenReservationMethods = [
    "METHOD zif_project_stock_repository~read_project_reservations.",
    "METHOD zif_project_stock_repository~read_project_reservations_wbs.",
  ];
  let projectOpenReservationNettingIsGuarded = true;
  for (const methodName of projectOpenReservationMethods) {
    const methodStart = projectStockRepo.indexOf(methodName);
    const methodEnd = projectStockRepo.indexOf("ENDMETHOD.", methodStart);
    const methodBody = projectStockRepo
      .slice(methodStart, methodEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (methodStart < 0 || methodEnd < 0
        || !methodBody.includes("calculate_open_res_qty(")
        || !methodBody.includes("if lv_open_quantity <= 0.")) {
      projectOpenReservationNettingIsGuarded = false;
    }
  }
  if (!/ty_wbs_mappings TYPE HASHED TABLE OF ty_wbs_mapping\s+WITH UNIQUE KEY wbs_element/i.test(projectStockRepo)
      || !/ty_wbs_number_mappings TYPE HASHED TABLE OF ty_wbs_mapping\s+WITH UNIQUE KEY wbs_number/i.test(projectStockRepo)
      || wbsElementLookupReads.length !== 2
      || wbsNumberLookupReads.length !== 3
      || wbsNumberFaes.length !== 3
      || !projectOpenReservationNettingIsGuarded
      || !/rspos = '0006'[\s\S]{0,300}bdmng = '2\.000'[\s\S]{0,60}enmng = '4\.000'/i.test(
        projectOpenReservationTests,
      )
      || !compactProjectOpenReservationTests.includes(
        "exp = 2 act = lines( lt_by_key )",
      )
      || !compactProjectOpenReservationTests.includes(
        "exp = 2 act = lines( lt_by_wbs )",
      )
      || !compactProjectOpenReservationTests.includes(
        "exp = 4 act = lines( lt_items )",
      )) {
    errors.push(
      `${projectStockRepoPath} must hash WBS mappings and clamp/test open project RESB quantities per item`,
    );
  }
}

const replenishmentSourceRepoPath = "src/zcl_repl_source_repo.clas.abap";
if (existsSync(join(projectRoot, replenishmentSourceRepoPath))) {
  const replenishmentSourceRepo = readFileSync(
    join(projectRoot, replenishmentSourceRepoPath),
    "utf8",
  );
  const candidatesStart = replenishmentSourceRepo.indexOf(
    "METHOD zif_repl_source_repo~get_candidates_bulk.",
  );
  const candidatesEnd = replenishmentSourceRepo.indexOf(
    "ENDMETHOD.",
    candidatesStart,
  );
  const candidatesMethod = replenishmentSourceRepo.slice(
    candidatesStart,
    candidatesEnd,
  );
  if (candidatesStart < 0 || candidatesEnd < 0
      || !/ty_general_infos TYPE SORTED TABLE OF ty_general_info\s+WITH NON-UNIQUE KEY matnr/i.test(candidatesMethod)
      || !/ty_purchasing_infos TYPE SORTED TABLE OF ty_purchasing_info\s+WITH NON-UNIQUE KEY infnr ekorg werks/i.test(candidatesMethod)) {
    errors.push(
      `${replenishmentSourceRepoPath} must index info-record buffers by material and purchasing scope`,
    );
  }

  const quotasStart = replenishmentSourceRepo.indexOf(
    "METHOD zif_repl_source_repo~get_quota_arrangements_bulk.",
  );
  const quotasEnd = replenishmentSourceRepo.indexOf("ENDMETHOD.", quotasStart);
  const quotasMethod = replenishmentSourceRepo.slice(quotasStart, quotasEnd);
  if (quotasStart < 0 || quotasEnd < 0
      || !/ty_quota_items TYPE SORTED TABLE OF ty_quota_item\s+WITH NON-UNIQUE KEY qunum/i.test(quotasMethod)) {
    errors.push(
      `${replenishmentSourceRepoPath} must index quota items by quota number`,
    );
  }

  const contextsStart = replenishmentSourceRepo.indexOf(
    "METHOD zif_repl_source_repo~get_source_contexts_bulk.",
  );
  const contextsEnd = replenishmentSourceRepo.indexOf(
    "ENDMETHOD.",
    contextsStart,
  );
  const contextsMethod = replenishmentSourceRepo.slice(
    contextsStart,
    contextsEnd,
  );
  if (contextsStart < 0 || contextsEnd < 0
      || !/ty_policy_lookups TYPE HASHED TABLE OF ty_policy_lookup\s+WITH UNIQUE KEY material plant/i.test(contextsMethod)
      || !/READ TABLE lt_policy_lookups[\s\S]+?WITH TABLE KEY material = ls_entry-material\s+plant = ls_entry-plant/i.test(contextsMethod)) {
    errors.push(
      `${replenishmentSourceRepoPath} must key source-context policy joins by material and plant`,
    );
  }

  const outlineStart = replenishmentSourceRepo.indexOf(
    "METHOD zif_repl_source_repo~get_outline_agreements_bulk.",
  );
  const outlineEnd = replenishmentSourceRepo.indexOf("ENDMETHOD.", outlineStart);
  const outlineMethod = replenishmentSourceRepo.slice(outlineStart, outlineEnd);
  if (outlineStart < 0 || outlineEnd < 0
      || !/ty_source_list_entries TYPE SORTED TABLE OF ty_source_list_entry\s+WITH NON-UNIQUE KEY matnr werks/i.test(outlineMethod)
      || !/ty_agreement_headers TYPE HASHED TABLE OF ty_agreement_header\s+WITH UNIQUE KEY ebeln/i.test(outlineMethod)
      || !/ty_agreement_items TYPE HASHED TABLE OF ty_agreement_item\s+WITH UNIQUE KEY ebeln ebelp/i.test(outlineMethod)
      || !/ty_request_keys TYPE SORTED TABLE OF ty_request_key\s+WITH UNIQUE KEY material plant purchasing_org/i.test(outlineMethod)
      || !/FOR ALL ENTRIES IN @lt_request_keys/i.test(outlineMethod)
      || !/READ TABLE lt_ekko[\s\S]+?WITH TABLE KEY ebeln = ls_eord-ebeln/i.test(outlineMethod)
      || !/READ TABLE lt_ekpo[\s\S]+?WITH TABLE KEY ebeln = ls_eord-ebeln\s+ebelp = ls_eord-ebelp/i.test(outlineMethod)) {
    errors.push(
      `${replenishmentSourceRepoPath} must key outline-agreement joins by request, document, and item`,
    );
  }

  const outlineServicePath = join(
    projectRoot,
    "src/zcl_repl_source_service.clas.abap",
  );
  const outlineService = existsSync(outlineServicePath)
    ? readFileSync(outlineServicePath, "utf8")
    : "";
  const pirCandidatesStart = outlineService.indexOf(
    "METHOD get_valid_pir_candidates.",
  );
  const pirCandidatesEnd = outlineService.indexOf(
    "ENDMETHOD.",
    pirCandidatesStart,
  );
  const pirCandidatesMethod = outlineService
    .slice(pirCandidatesStart, pirCandidatesEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const outlineServiceStart = outlineService.indexOf(
    "METHOD get_valid_outline_sources.",
  );
  const outlineServiceEnd = outlineService.indexOf(
    "ENDMETHOD.",
    outlineServiceStart,
  );
  const outlineServiceMethod = outlineService
    .slice(outlineServiceStart, outlineServiceEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const outlineServiceTestPath = join(
    projectRoot,
    "src/zcl_repl_source_service.clas.testclasses.abap",
  );
  const outlineServiceTests = existsSync(outlineServiceTestPath)
    ? readFileSync(outlineServiceTestPath, "utf8")
    : "";
  const compactOutlineServiceTests = outlineServiceTests
    .replace(/\s+/g, " ")
    .toLowerCase();
  const invalidOutlineRequestStart = outlineServiceTests.indexOf(
    "METHOD rejects_bad_agreement_request.",
  );
  const invalidOutlineRequestEnd = outlineServiceTests.indexOf(
    "ENDMETHOD.",
    invalidOutlineRequestStart,
  );
  const invalidOutlineRequestTest = outlineServiceTests
    .slice(invalidOutlineRequestStart, invalidOutlineRequestEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const invalidPirDateStart = outlineServiceTests.indexOf(
    "METHOD rejects_invalid_pir_date.",
  );
  const invalidPirDateEnd = outlineServiceTests.indexOf(
    "ENDMETHOD.",
    invalidPirDateStart,
  );
  const invalidPirDateTest = outlineServiceTests
    .slice(invalidPirDateStart, invalidPirDateEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  if (pirCandidatesStart < 0 || pirCandidatesEnd < 0
      || !pirCandidatesMethod.includes(
        "zcl_date_validation=>is_valid_gregorian_date(",
      )
      || invalidPirDateStart < 0 || invalidPirDateEnd < 0
      || !invalidPirDateTest.includes("delivery_date = '20260230'")
      || !invalidPirDateTest.includes("act = lv_invalid_date_rejected")
      || !compactOutlineServiceTests.includes(
        "methods rejects_invalid_pir_date for testing",
      )
      || outlineServiceStart < 0 || outlineServiceEnd < 0
      || !outlineServiceMethod.includes(
        "zcl_date_validation=>is_valid_gregorian_date(",
      )
      || invalidOutlineRequestStart < 0 || invalidOutlineRequestEnd < 0
      || !invalidOutlineRequestTest.includes("delivery_date = '20260230'")
      || !invalidOutlineRequestTest.includes(
        "act = lv_bad_date_rejected",
      )
      || !compactOutlineServiceTests.includes(
        "lv_bad_date_rejected type abap_bool",
      )) {
    errors.push(
      `${outlineServicePath} must validate PIR and outline delivery dates as Gregorian dates and test invalid inputs`,
    );
  }

  const outlineIntegrationTestPath = join(
    projectRoot,
    "src/zcl_repl_source_repo.clas.testclasses.abap",
  );
  const outlineIntegrationTests = existsSync(outlineIntegrationTestPath)
    ? readFileSync(outlineIntegrationTestPath, "utf8")
    : "";
  const compactOutlineIntegrationTests = outlineIntegrationTests
    .replace(/\s+/g, " ")
    .toLowerCase();
  const outlineIntegrationStart = outlineIntegrationTests.indexOf(
    "METHOD tests_outline_service_sql.",
  );
  const outlineIntegrationEnd = outlineIntegrationTests.indexOf(
    "ENDMETHOD.",
    outlineIntegrationStart,
  );
  const outlineIntegrationMethod = outlineIntegrationTests
    .slice(outlineIntegrationStart, outlineIntegrationEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const pirIntegrationStart = outlineIntegrationTests.indexOf(
    "METHOD tests_pir_service_sql.",
  );
  const pirIntegrationEnd = outlineIntegrationTests.indexOf(
    "ENDMETHOD.",
    pirIntegrationStart,
  );
  const pirIntegrationMethod = outlineIntegrationTests
    .slice(pirIntegrationStart, pirIntegrationEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  if (outlineIntegrationStart < 0 || outlineIntegrationEnd < 0
      || !outlineIntegrationMethod.includes(
        "new zcl_repl_source_repo(",
      )
      || !outlineIntegrationMethod.includes(
        "new zcl_repl_source_service(",
      )
      || !outlineIntegrationMethod.includes("get_valid_outline_sources(")
      || !outlineIntegrationMethod.includes(
        "exp = 3 act = lines( lt_candidates )",
      )
      || !outlineIntegrationMethod.includes("exp = 'ag-1'")
      || !outlineIntegrationMethod.includes("exp = 'ag-2'")
      || !outlineIntegrationMethod.includes("exp = 'ag-10'")
      || !outlineIntegrationMethod.includes("exp = 'l'")
      || !compactOutlineIntegrationTests.includes(
        "methods tests_outline_service_sql for testing",
      )
      || pirIntegrationStart < 0 || pirIntegrationEnd < 0
      || !pirIntegrationMethod.includes("new zcl_repl_source_repo(")
      || !pirIntegrationMethod.includes("new zcl_repl_source_service(")
      || !pirIntegrationMethod.includes("get_valid_pir_candidates(")
      || !pirIntegrationMethod.includes(
        "exp = 2 act = lines( lt_candidates )",
      )
      || !pirIntegrationMethod.includes(
        "exp = 'info-1'",
      )
      || !pirIntegrationMethod.includes(
        "act = lt_candidates[ record_plant = '1000' ]-is_source_listed",
      )
      || !pirIntegrationMethod.includes(
        "iv_require_auto_source = abap_true",
      )
      || !pirIntegrationMethod.includes(
        "exp = 1 act = lines( lt_candidates )",
      )
      || !pirIntegrationMethod.includes(
        "delivery_date = '20261006'",
      )
      || !pirIntegrationMethod.includes(
        "exp = 0 act = lines( lt_candidates )",
      )
      || !pirIntegrationMethod.includes("material = 'mat-2'")
      || !pirIntegrationMethod.includes("plant = '2000'")
      || !pirIntegrationMethod.includes(
        "exp = abap_false act = lt_candidates[ 1 ]-source_list_required",
      )
      || !pirIntegrationMethod.includes(
        "exp = abap_false act = lt_candidates[ 1 ]-is_source_listed",
      )
      || !pirIntegrationMethod.includes(
        "iv_require_source_listed = abap_true",
      )
      || !compactOutlineIntegrationTests.includes(
        "methods tests_pir_service_sql for testing",
      )
      || !compactOutlineIntegrationTests.includes(
        "exp = 8 act = lines( lt_candidates )",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_candidates[ info_record = 'info-3' ]-general_deletion_indicator",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_candidates[ info_record = 'info-4' ]-purchasing_deletion_indicator",
      )
      || !compactOutlineIntegrationTests.includes("zeord = '00014'")
      || !compactOutlineIntegrationTests.includes("zeord = '00015'")
      || !compactOutlineIntegrationTests.includes("vdatu = '20261005'")
      || !compactOutlineIntegrationTests.includes("bdatu = '20261005'")
      || !compactOutlineIntegrationTests.includes("notkz = 'x'")
      || !compactOutlineIntegrationTests.includes("loekz = 'x'")
      || !compactOutlineIntegrationTests.includes("elikz = 'x'")
      || !compactOutlineIntegrationTests.includes(
        "exp = 10 act = lines( lt_agreements )",
      )
      || !compactOutlineIntegrationTests.includes(
        "exp = 16 act = lines( lt_contexts )",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_contexts[ source_list_record = '00015' ]-source_list_blocked",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-1' ]-source_list_valid_from",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-1' ]-source_list_valid_to",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-1' ]-agreement_valid_from",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-1' ]-agreement_valid_to",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-6' ]-source_list_blocked",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-7' ]-header_deletion_indicator",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-8' ]-item_delivery_complete",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-9' ]-item_deletion_indicator",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-10' ]-document_category",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-11' ]-source_list_valid_from",
      )
      || !compactOutlineIntegrationTests.includes(
        "act = lt_agreements[ purchasing_document = 'ag-12' ]-agreement_valid_from",
      )) {
    errors.push(
      `${outlineIntegrationTestPath} must exercise outline-source policy over the SQLite repository queries`,
    );
  }
}

const policyRepositoryPath = "src/zcl_marc_repl_policy_repo.clas.abap";
if (existsSync(join(projectRoot, policyRepositoryPath))) {
  const policyRepository = readFileSync(
    join(projectRoot, policyRepositoryPath),
    "utf8",
  );
  const policyTableFields = new Map();
  for (const [, rawTable, rawField] of policyRepository.matchAll(
    /\b([a-z][a-z0-9_]*)~([a-z][a-z0-9_]*)\b/gi,
  )) {
    const table = rawTable.toLowerCase();
    if (table.startsWith("zif_")) {
      continue;
    }
    const fields = policyTableFields.get(table) ?? new Set();
    fields.add(rawField.toUpperCase());
    policyTableFields.set(table, fields);
  }

  for (const [table, fields] of policyTableFields) {
    const path = `stubs/src/${table}.tabl.xml`;
    if (!existsSync(join(projectRoot, path))) {
      errors.push(
        `${path} must exist for SAP fields referenced by ${policyRepositoryPath}`,
      );
      continue;
    }
    const stub = readFileSync(join(projectRoot, path), "utf8");
    const definedFields = new Set(
      [...stub.matchAll(/<FIELDNAME>([^<]+)<\/FIELDNAME>/g)]
        .map(([, field]) => field.toUpperCase()),
    );
    for (const field of fields) {
      if (!definedFields.has(field)) {
        errors.push(
          `${path} must define field ${field} referenced by ${policyRepositoryPath}`,
        );
      }
    }
  }
}

const requiredStubShapes = {
  "stubs/src/eina.tabl.xml": { MATNR: ["CHAR", "000040"] },
  "stubs/src/ekpo.tabl.xml": { LGORT: ["CHAR", "000004"] },
  "stubs/src/eket.tabl.xml": { CHARG: ["CHAR", "000010"] },
  "stubs/src/ekes.tabl.xml": { CHARG: ["CHAR", "000010"] },
  "stubs/src/afpo.tabl.xml": {
    LGORT: ["CHAR", "000004"],
    CHARG: ["CHAR", "000010"],
  },
  "stubs/src/eban.tabl.xml": { LGORT: ["CHAR", "000004"] },
  "stubs/src/plaf.tabl.xml": { LGORT: ["CHAR", "000004"] },
};

for (const [path, fields] of Object.entries(requiredStubShapes)) {
  if (!existsSync(join(projectRoot, path))) {
    continue;
  }
  const stub = readFileSync(join(projectRoot, path), "utf8");
  const fieldEntries = [...stub.matchAll(/<DD03P>([\s\S]*?)<\/DD03P>/g)];
  for (const [field, [expectedType, expectedLength]] of Object.entries(fields)) {
    const entry = fieldEntries.find(([, body]) =>
      body.includes(`<FIELDNAME>${field}</FIELDNAME>`));
    if (!entry) {
      continue;
    }
    const [, body] = entry;
    const actualType = body.match(/<DATATYPE>([^<]+)<\/DATATYPE>/)?.[1];
    const actualLength = body.match(/<LENG>([^<]+)<\/LENG>/)?.[1];
    if (actualType !== expectedType || actualLength !== expectedLength) {
      errors.push(
        `${path} field ${field} must be ${expectedType} length ${expectedLength}`,
      );
    }
  }
}

const stockRepositoryPath = "src/zcl_mard_stock_repository.clas.abap";
if (existsSync(join(projectRoot, stockRepositoryPath))) {
  const stockRepository = readFileSync(
    join(projectRoot, stockRepositoryPath),
    "utf8",
  );
  const tableFields = new Map();
  for (const [, rawTable, rawField] of stockRepository.matchAll(
    /\b([a-z][a-z0-9_]*)~([a-z][a-z0-9_]*)\b/gi,
  )) {
    const table = rawTable.toLowerCase();
    if (table.startsWith("zif_")) {
      continue;
    }
    const fields = tableFields.get(table) ?? new Set();
    fields.add(rawField.toUpperCase());
    tableFields.set(table, fields);
  }

  for (const [table, fields] of tableFields) {
    const path = `stubs/src/${table}.tabl.xml`;
    if (!existsSync(join(projectRoot, path))) {
      errors.push(
        `${path} must exist for SAP fields referenced by ${stockRepositoryPath}`,
      );
      continue;
    }

    const stub = readFileSync(join(projectRoot, path), "utf8");
    const definedFields = new Set(
      [...stub.matchAll(/<FIELDNAME>([^<]+)<\/FIELDNAME>/g)]
        .map(([, field]) => field.toUpperCase()),
    );
    for (const field of fields) {
      if (!definedFields.has(field)) {
        errors.push(
          `${path} must define field ${field} referenced by ${stockRepositoryPath}`,
        );
      }
    }
  }

  const bulkMethodStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_po_confirmed_receipts_bulk.",
  );
  const bulkMethodEnd = stockRepository.indexOf("ENDMETHOD.", bulkMethodStart);
  if (bulkMethodStart < 0 || bulkMethodEnd < 0) {
    errors.push(
      `${stockRepositoryPath} must implement get_po_confirmed_receipts_bulk`,
    );
  } else {
    const bulkMethod = stockRepository.slice(bulkMethodStart, bulkMethodEnd);
    const boundedQueries = [
      {
        table: "EKET",
        pattern: /SELECT[\s\S]*?FROM eket[\s\S]*?INTO CORRESPONDING FIELDS OF TABLE @lt_eket_schedule_rows\./i,
        dateCondition: /eindt\s*<=\s*@lt_po_read_keys-through_date/i,
      },
      {
        table: "EKES",
        pattern: /SELECT[\s\S]*?FROM ekes[\s\S]*?INTO CORRESPONDING FIELDS OF TABLE @lt_ekes_confirmation_rows\./i,
        dateCondition: /eindt\s*<=\s*@lt_po_read_keys-through_date/i,
      },
    ];
    for (const query of boundedQueries) {
      const statement = bulkMethod.match(query.pattern)?.[0];
      if (!statement?.match(/FOR ALL ENTRIES IN @lt_po_read_keys/i)) {
        errors.push(
          `${stockRepositoryPath} must batch its ${query.table} read across PO item scopes`,
        );
      }
      if (!statement?.match(query.dateCondition)) {
        errors.push(
          `${stockRepositoryPath} must apply each lt_scopes deadline to its ${query.table} read`,
        );
      }
    }
    if (!bulkMethod.includes("IF lt_po_read_keys IS NOT INITIAL.")) {
      errors.push(
        `${stockRepositoryPath} must guard EKET and EKES reads against empty PO item scopes`,
      );
    }
  }

  const projectionBulkStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_projected_receipts_bulk.",
  );
  const projectionBulkEnd = stockRepository.indexOf(
    "ENDMETHOD.",
    projectionBulkStart,
  );
  const projectionScalarStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_projected_receipts.",
  );
  const projectionScalarEnd = stockRepository.indexOf(
    "ENDMETHOD.",
    projectionScalarStart,
  );
  const projectionScalarMethod = stockRepository.slice(
    projectionScalarStart,
    projectionScalarEnd,
  );
  if (projectionScalarStart < 0 || projectionScalarEnd < 0
      || !projectionScalarMethod.includes(
        "zif_stock_repository~get_projected_receipts_bulk(",
      )
      || /\bSELECT\b/i.test(projectionScalarMethod)) {
    errors.push(
      `${stockRepositoryPath} must route scalar projected receipts through the bulk implementation`,
    );
  }

  const confirmedScalarStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_po_confirmed_receipts.",
  );
  const confirmedScalarEnd = stockRepository.indexOf(
    "ENDMETHOD.",
    confirmedScalarStart,
  );
  const confirmedScalarMethod = stockRepository.slice(
    confirmedScalarStart,
    confirmedScalarEnd,
  );
  if (confirmedScalarStart < 0 || confirmedScalarEnd < 0
      || !confirmedScalarMethod.includes(
        "zif_stock_repository~get_po_confirmed_receipts_bulk(",
      )
      || /\bSELECT\b/i.test(confirmedScalarMethod)) {
    errors.push(
      `${stockRepositoryPath} must route scalar confirmed-PO receipts through the bulk implementation`,
    );
  }

  const confirmedBulkStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_po_confirmed_receipts_bulk.",
  );
  const confirmedBulkEnd = stockRepository.indexOf(
    "ENDMETHOD.",
    confirmedBulkStart,
  );
  const confirmedBulkMethod = stockRepository.slice(
    confirmedBulkStart,
    confirmedBulkEnd,
  );
  const compactConfirmedBulkMethod = confirmedBulkMethod
    .replace(/\s+/g, " ");
  if (confirmedBulkStart < 0 || confirmedBulkEnd < 0
      || !/ty_receipt_positions type sorted table of ty_receipt_position with unique key material plant row_number\./i.test(
        compactConfirmedBulkMethod,
      )
      || !/if lines\( it_requests \) > 1\./i.test(
        compactConfirmedBulkMethod,
      )
      || !/row_number = lv_receipt_row_number\s*\) into table lt_receipt_positions\./i.test(
        compactConfirmedBulkMethod,
      )
      || !/loop at lt_receipt_positions into data\(ls_receipt_position\) where material = ls_request-material and plant = ls_request-plant\./i.test(
        compactConfirmedBulkMethod,
      )
      || !/read table lt_receipts into ls_receipt index ls_receipt_position-row_number\./i.test(
        compactConfirmedBulkMethod,
      )
      || !/loop at lt_receipts into ls_receipt where material = ls_request-material and plant = ls_request-plant and receipt_date <= ls_request-through_date\./i.test(
        compactConfirmedBulkMethod,
      )) {
    errors.push(
      `${stockRepositoryPath} must preserve confirmed-PO receipt order while indexing repeated scope lookups`,
    );
  }

  if (projectionBulkStart < 0 || projectionBulkEnd < 0) {
    errors.push(
      `${stockRepositoryPath} must implement get_projected_receipts_bulk`,
    );
  } else {
    const projectionBulkMethod = stockRepository.slice(
      projectionBulkStart,
      projectionBulkEnd,
    );
    const statements = [...projectionBulkMethod.matchAll(
      /\bSELECT\b[\s\S]*?\./gi,
    )].map(([statement]) => statement);
    const batchedSources = [
      {
        table: "EKET",
        count: 3,
        drivers: ["lt_scopes", "lt_po_schedule_keys"],
        dates: [
          /(?:eket~)?eindt\s*<=\s*@(lt_scopes-through_date|lt_po_schedule_keys-through_date)/i,
        ],
      },
      { table: "AFPO", count: 1, drivers: ["lt_scopes"], dates: [] },
      {
        table: "AFKO",
        count: 1,
        drivers: ["lt_production_order_keys"],
        dates: [/gltrp\s*<=\s*@lt_production_order_keys-through_date/i],
      },
      {
        table: "AUFK",
        count: 1,
        drivers: ["lt_production_order_keys"],
        dates: [],
      },
      {
        table: "EBAN",
        count: 2,
        drivers: ["lt_scopes"],
        dates: [/\blfdat\s*<=\s*@lt_scopes-through_date/i],
      },
      {
        table: "PLAF",
        count: 1,
        drivers: ["lt_scopes"],
        dates: [
          /(?:plaf~)?psttr\s*<=\s*@lt_scopes-through_date/i,
          /(?:plaf~)?pedtr\s*<=\s*@lt_scopes-through_date/i,
        ],
      },
    ];

    for (const source of batchedSources) {
      const sourceStatements = statements.filter((statement) =>
        new RegExp(`\\bFROM\\s+${source.table}\\b`, "i").test(statement),
      );
      if (sourceStatements.length !== source.count) {
        errors.push(
          `${stockRepositoryPath} must keep ${source.count} batched ${source.table} receipt reads`,
        );
      }
      for (const statement of sourceStatements) {
        const drivers = source.drivers ?? ["lt_scopes"];
        const allowedDrivers = new RegExp(
          `FOR ALL ENTRIES IN @(${drivers.join("|")})`,
          "i",
        );
        if (!allowedDrivers.test(statement)) {
          errors.push(
            `${stockRepositoryPath} must batch ${source.table} reads across their request scopes`,
          );
        }
        for (const dateCondition of source.dates) {
          if (!dateCondition.test(statement)) {
            errors.push(
              `${stockRepositoryPath} must apply scope-derived deadlines to its ${source.table} read`,
            );
          }
        }
      }
    }

    if (projectionBulkMethod.includes(
      "zif_stock_repository~get_projected_receipts(",
    )) {
      errors.push(
        `${stockRepositoryPath} must not fall back to per-pair projected-receipt reads`,
      );
    }

    const compactProjectionBulkMethod = projectionBulkMethod
      .replace(/\s+/g, " ");
    if (!/types ty_projected_receipt_rows type standard table of zif_stock_repository=>ty_projected_receipt with empty key with non-unique sorted key by_scope components material plant\./i.test(
      compactProjectionBulkMethod,
    )
        || !/data lt_receipts type ty_projected_receipt_rows\./i.test(
          compactProjectionBulkMethod,
        )
        || !/loop at lt_receipts using key by_scope into data\(ls_receipt\) where material = ls_request-material and plant = ls_request-plant and receipt_date <= ls_request-through_date\./i.test(
          compactProjectionBulkMethod,
        )
        || !/sort ls_result-receipts by material plant base_unit receipt_date source_type source_document source_item source_schedule_line\./i.test(
          compactProjectionBulkMethod,
        )) {
      errors.push(
        `${stockRepositoryPath} must use indexed projected-receipt ranges and retain deterministic result sorting`,
      );
    }
  }

  const dateAvailabilityStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_available_stock_date_bulk.",
  );
  const dateAvailabilityEnd = stockRepository.indexOf(
    "ENDMETHOD.",
    dateAvailabilityStart,
  );
  if (dateAvailabilityStart < 0 || dateAvailabilityEnd < 0) {
    errors.push(
      `${stockRepositoryPath} must implement get_available_stock_date_bulk`,
    );
  } else {
    const dateAvailabilityMethod = stockRepository.slice(
      dateAvailabilityStart,
      dateAvailabilityEnd,
    );
    const statements = [...dateAvailabilityMethod.matchAll(
      /\bSELECT\b[\s\S]*?\./gi,
    )].map(([statement]) => statement);
    const reads = [
      {
        table: "MARD",
        count: 1,
        drivers: ["it_requests"],
        dates: [],
        keyFields: [/lgort\s+as\s+storage_location/i],
      },
      {
        table: "RESB",
        count: 1,
        drivers: ["it_requests"],
        dates: [
          /bdter\s*<=\s*@it_requests-required_date/i,
          /bdter\s*=\s*@lv_initial_date/i,
        ],
        keyFields: [/rsnum\s+as\s+reservation_number/i, /rspos\s+as\s+reservation_item/i],
      },
      {
        table: "EKET",
        count: 1,
        drivers: ["lt_outgoing_sto_schedule_keys"],
        dates: [
          /(?:eket~)?eindt\s*<=\s*@lt_outgoing_sto_schedule_keys-through_date/i,
        ],
        keyFields: [/(?:eket~)?ebeln\s+as\s+source_document/i, /(?:eket~)?ebelp\s+as\s+source_item/i, /(?:eket~)?etenr\s+as\s+schedule_line/i],
      },
      {
        table: "EKPO",
        count: 1,
        drivers: ["lt_outgoing_sto_scopes"],
        dates: [],
        keyFields: [/ebeln\s+as\s+source_document/i, /ebelp\s+as\s+source_item/i],
      },
      {
        table: "EKKO",
        count: 1,
        drivers: ["lt_outgoing_sto_items"],
        dates: [],
        keyFields: [/ebeln\s+as\s+source_document/i],
      },
      {
        table: "AFPO",
        count: 1,
        drivers: ["lt_prod_scopes"],
        dates: [],
        keyFields: [/aufnr\s+as\s+production_order/i, /posnr\s+as\s+production_item/i],
      },
      {
        table: "AFKO",
        count: 1,
        drivers: ["lt_prod_order_keys"],
        dates: [],
        keyFields: [/aufnr\s+as\s+production_order/i, /gltrp\s+as\s+receipt_date/i],
      },
      {
        table: "AUFK",
        count: 1,
        drivers: ["lt_prod_order_keys"],
        dates: [],
        keyFields: [/aufnr\s+as\s+production_order/i, /autyp\s+as\s+order_category/i],
      },
    ];

    for (const read of reads) {
      const sourceStatements = statements.filter((statement) =>
        new RegExp(`\\bFROM\\s+${read.table}\\b`, "i").test(statement),
      );
      if (sourceStatements.length !== read.count) {
        errors.push(
          `${stockRepositoryPath} must keep ${read.count} batched ${read.table} date-availability reads`,
        );
      }
      for (const statement of sourceStatements) {
        const drivers = read.drivers ?? ["it_requests"];
        const allowedDrivers = new RegExp(
          `FOR ALL ENTRIES IN @(${drivers.join("|")})`,
          "i",
        );
        if (!allowedDrivers.test(statement)) {
          errors.push(
            `${stockRepositoryPath} must batch ${read.table} date-availability reads across their scope keys`,
          );
        }
        for (const dateCondition of read.dates) {
          if (!dateCondition.test(statement)) {
            errors.push(
              `${stockRepositoryPath} must apply each request date to its ${read.table} read`,
            );
          }
        }
        for (const keyField of read.keyFields) {
          if (!keyField.test(statement)) {
            errors.push(
              `${stockRepositoryPath} must select row keys in batched ${read.table} reads to preserve duplicate FAE rows`,
            );
          }
        }
      }
    }

    const scopeMergeBuffers = [
      ["lt_mard_rows", "ty_mard_rows", "ty_mard_row", "ls_mard_row"],
      [
        "lt_reservation_rows",
        "ty_reservation_rows",
        "ty_reservation_row",
        "ls_reservation_row",
      ],
      ["lt_outgoing_stos", "ty_outgoing_stos", "ty_outgoing_sto", "ls_outgoing_sto"],
      ["lt_prod_receipts", "ty_prod_receipts", "ty_prod_receipt", "ls_prod_receipt"],
    ];
    const compactDateAvailabilityMethod = dateAvailabilityMethod
      .replace(/\s+/g, " ")
      .toLowerCase();
    for (const [buffer, tableType, rowType, rowVariable] of scopeMergeBuffers) {
      const sortedScopeType = new RegExp(
        `types ${tableType} type standard table of ${rowType} with empty key with non-unique sorted key by_scope components material plant\\.`,
      );
      if (!sortedScopeType.test(compactDateAvailabilityMethod)) {
        errors.push(
          `${stockRepositoryPath} must index ${buffer} by material and plant for date-availability merging`,
        );
      }
      const indexedScopeLoop = new RegExp(
        `loop at ${buffer} using key by_scope into data\\(${rowVariable}\\) where material = ls_request-material and plant = ls_request-plant\\.`,
      );
      if (!indexedScopeLoop.test(compactDateAvailabilityMethod)) {
        errors.push(
          `${stockRepositoryPath} must merge ${buffer} through its material/plant key`,
        );
      }
    }

    if (!compactDateAvailabilityMethod.includes("calculate_open_res_qty(")
        || !compactDateAvailabilityMethod.includes(
          "lv_reserved_quantity = lv_reserved_quantity + zcl_stock_avail_qty_calc=>calculate_open_res_qty(",
        )
        || !existsSync(join(
          projectRoot,
          "src/zcl_mard_stock_repository.clas.testclasses.abap",
        ))
        || !readFileSync(join(
          projectRoot,
          "src/zcl_mard_stock_repository.clas.testclasses.abap",
        ), "utf8").toLowerCase().includes("rsnum = '0000000902'")) {
      errors.push(
        `${stockRepositoryPath} must clamp each RESB item's open quantity before dated availability aggregation`,
      );
    }

    const productionMergeRules = [
      /ls_prod_order_date-receipt_date\s*>\s*ls_prod_scope-through_date/i,
      /ls_prod_order_status-order_category\s*<>\s*'10'/i,
      /autyp\s*=\s*'10'\s+or\s+autyp\s*=\s*'40'/i,
      /ls_prod_order_status-order_category\s*<>\s*'40'/i,
      /ls_prod_item_raw-sales_order\s+is\s+not\s+initial/i,
    ];
    for (const rule of productionMergeRules) {
      if (!rule.test(dateAvailabilityMethod)) {
        errors.push(
          `${stockRepositoryPath} must preserve production receipt date, category, and make-to-order eligibility during batch merging`,
        );
      }
    }

    if (!dateAvailabilityMethod.includes(
      "zif_stock_repository~get_projected_receipts_bulk(",
    )) {
      errors.push(
        `${stockRepositoryPath} must batch requisition, planned-order, and scheduling-agreement availability reads`,
      );
    }
    if (dateAvailabilityMethod.includes(
      "zif_stock_repository~get_available_stock_by_date(",
    )) {
      errors.push(
        `${stockRepositoryPath} must not fall back to per-request date-availability reads`,
      );
    }

    const reservationBulkStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_open_stock_res_bulk.",
    );
    const reservationBulkEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      reservationBulkStart,
    );
    const reservationBulkMethod = stockRepository.slice(
      reservationBulkStart,
      reservationBulkEnd,
    );
    if (reservationBulkStart < 0 || reservationBulkEnd < 0
        || !reservationBulkMethod.includes(
          "FOR ALL ENTRIES IN @it_requests",
        )
        || !reservationBulkMethod.includes(
          "matnr = @it_requests-material",
        )
        || !reservationBulkMethod.includes(
          "werks = @it_requests-plant",
        )
        || !reservationBulkMethod.includes("IF it_requests IS INITIAL.")) {
      errors.push(
        `${stockRepositoryPath} must guard and batch open RESB reservations by material and plant`,
      );
    }

    const orderReservationTestPath = join(
      projectRoot,
      "src/zcl_mard_stock_repository.clas.testclasses.abap",
    );
    const orderReservationTests = existsSync(orderReservationTestPath)
      ? readFileSync(orderReservationTestPath, "utf8").toLowerCase()
      : "";

    const scalarOpenReservationStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_open_stock_reservations.",
    );
    const scalarOpenReservationEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      scalarOpenReservationStart,
    );
    const scalarOpenReservationMethod = stockRepository
      .slice(scalarOpenReservationStart, scalarOpenReservationEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (scalarOpenReservationStart < 0 || scalarOpenReservationEnd < 0
        || !scalarOpenReservationMethod.includes("from resb")
        || !scalarOpenReservationMethod.includes("where matnr = @iv_material")
        || !scalarOpenReservationMethod.includes("and werks = @iv_plant")
        || !scalarOpenReservationMethod.includes("sobkz = @space")
        || !scalarOpenReservationMethod.includes("xloek = @space")
        || !scalarOpenReservationMethod.includes("kzear = @space")
        || !scalarOpenReservationMethod.includes("rsnum as reservation_number")
        || !scalarOpenReservationMethod.includes("lgort as storage_location")
        || !scalarOpenReservationMethod.includes(
          "required_quantity - ls_row-withdrawn_quantity",
        )
        || !scalarOpenReservationMethod.includes("if lv_open_quantity <= 0.")
        || !orderReservationTests.includes("method reads_open_reservations.")
        || !orderReservationTests.includes("get_open_stock_reservations(")) {
      errors.push(
        `${stockRepositoryPath} must filter and test scalar open RESB reservation rows`,
      );
    }

    const orderReservationStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_order_reservations_bulk.",
    );
    const orderReservationEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      orderReservationStart,
    );
    const orderReservationMethod = stockRepository.slice(
      orderReservationStart,
      orderReservationEnd,
    );
    const compactOrderReservationMethod = orderReservationMethod
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (orderReservationStart < 0 || orderReservationEnd < 0
        || !compactOrderReservationMethod.includes(
          "if it_sales_documents is initial.",
        )
        || !compactOrderReservationMethod.includes(
          "for all entries in @it_sales_documents",
        )
        || !compactOrderReservationMethod.includes("bwart = '231'")
        || !compactOrderReservationMethod.includes("sobkz = @space")
        || !compactOrderReservationMethod.includes("xloek = @space")
        || !compactOrderReservationMethod.includes("kzear = @space")
        || !compactOrderReservationMethod.includes(
          "rsnum as reservation_number",
        )
        || !compactOrderReservationMethod.includes(
          "rspos as reservation_item",
        )
        || !compactOrderReservationMethod.includes("from resb")
        || !compactOrderReservationMethod.includes("calculate_open_res_qty(")
        || !compactOrderReservationMethod.includes("if lv_open_quantity <= 0.")
        || compactOrderReservationMethod.includes("ty_reservation_totals")
        || !compactOrderReservationMethod.includes(
          "open_quantity = lv_open_quantity",
        )
        || !orderReservationTests.includes("method keeps_large_resv_rows.")
        || !orderReservationTests.includes("9999999999.999")
        || !orderReservationTests.includes(
          "method reads_sales_order_reservations.",
        )) {
      errors.push(
        `${stockRepositoryPath} must preserve each open sales-order RESB reservation row`,
      );
    }

    const plantStatusStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_stock_status.",
    );
    const plantStatusEnd = stockRepository.indexOf("ENDMETHOD.", plantStatusStart);
    const plantStatusMethod = stockRepository.slice(plantStatusStart, plantStatusEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (plantStatusStart < 0 || plantStatusEnd < 0
        || !plantStatusMethod.includes("get_stock_status_bulk(")
        || plantStatusMethod.includes("select sum(")
        || !orderReservationTests.includes("method reads_plant_stock_status.")) {
      errors.push(
        `${stockRepositoryPath} must aggregate and test plant stock, reservations, and safety stock`,
      );
    }

    const bulkPlantStatusStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_stock_status_bulk.",
    );
    const bulkPlantStatusEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      bulkPlantStatusStart,
    );
    const bulkPlantStatusMethod = stockRepository
      .slice(bulkPlantStatusStart, bulkPlantStatusEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (bulkPlantStatusStart < 0 || bulkPlantStatusEnd < 0
        || !bulkPlantStatusMethod.includes("if it_requests is initial.")
        || !bulkPlantStatusMethod.includes("for all entries in @it_requests")
        || !bulkPlantStatusMethod.includes("matnr = @it_requests-material")
        || !bulkPlantStatusMethod.includes("werks = @it_requests-plant")
        || !bulkPlantStatusMethod.includes("lgort as storage_location")
        || !bulkPlantStatusMethod.includes("sobkz = @space")
        || !bulkPlantStatusMethod.includes("xloek = @space")
        || !bulkPlantStatusMethod.includes("kzear = @space")
        || !bulkPlantStatusMethod.includes("calculate_open_res_qty(")
        || !/ty_stock_totals type hashed table of ty_stock_total with unique key material plant[,;.]/i.test(
          bulkPlantStatusMethod,
        )
        || !/ty_reservation_totals type hashed table of ty_reservation_total with unique key material plant[,;.]/i.test(
          bulkPlantStatusMethod,
        )
        || !/ty_safety_stocks type hashed table of ty_safety_stock with unique key material plant[,;.]/i.test(
          bulkPlantStatusMethod,
        )
        || !bulkPlantStatusMethod.includes("loop at it_requests into data(ls_request).")
        || !bulkPlantStatusMethod.includes("calculate_with_safety_stock(")
        || !orderReservationTests.includes("get_stock_status_bulk(")
        || !orderReservationTests.includes("request_id = 'mat-1-dup'")) {
      errors.push(
        `${stockRepositoryPath} must batch and test plant stock-status aggregation by material and plant`,
      );
    }

    const scalarLocationRules = [
      {
        method: "METHOD zif_stock_repository~get_stock_by_location.",
        testCall: "zif_stock_repository~get_stock_by_location(",
        requirements: [
          "select lgort as storage_location, sum( labst ) as quantity",
          "group by lgort",
          "select lgort as storage_location, bdmng as required_quantity",
          "enmng as withdrawn_quantity",
          "sobkz = @space",
          "xloek = @space",
          "kzear = @space",
          "new zcl_stock_location_qty_calc( )->calculate(",
        ],
      },
      {
        method: "METHOD zif_stock_repository~get_stock_status_by_location.",
        testCall: "zif_stock_repository~get_stock_status_by_location(",
        requirements: [
          "select lgort as storage_location, sum( labst ) as unrestricted_quantity",
          "sum( insme ) as quality_inspection_qty",
          "sum( speme ) as blocked_quantity",
          "select lgort as storage_location, bdmng as required_quantity",
          "enmng as withdrawn_quantity",
          "group by lgort",
          "sobkz = @space",
          "xloek = @space",
          "kzear = @space",
          "new zcl_stock_location_qty_calc( )->calculate(",
        ],
      },
    ];
    for (const rule of scalarLocationRules) {
      const methodStart = stockRepository.indexOf(rule.method);
      const methodEnd = stockRepository.indexOf("ENDMETHOD.", methodStart);
      const methodBody = stockRepository.slice(methodStart, methodEnd)
        .replace(/\s+/g, " ")
        .toLowerCase();
      if (methodStart < 0 || methodEnd < 0
          || rule.requirements.some((requirement) => !methodBody.includes(requirement))
          || !methodBody.includes("where matnr = @iv_material")
          || !methodBody.includes("and werks = @iv_plant")
          || !orderReservationTests.includes(rule.testCall)
          || !orderReservationTests.includes("method reads_scalar_location_stock.")) {
        errors.push(
          `${stockRepositoryPath} must execute and test the scalar location query in ${rule.method.slice(7, -1)}`,
        );
      }
    }

    const scalarBatchStatusStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_stock_status_by_batch.",
    );
    const scalarBatchStatusEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      scalarBatchStatusStart,
    );
    const scalarBatchStatusMethod = stockRepository
      .slice(scalarBatchStatusStart, scalarBatchStatusEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    const scalarBatchStockStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_stock_by_batch.",
    );
    const scalarBatchStockEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      scalarBatchStockStart,
    );
    const scalarBatchStockMethod = stockRepository
      .slice(scalarBatchStockStart, scalarBatchStockEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (scalarBatchStatusStart < 0 || scalarBatchStatusEnd < 0
        || !scalarBatchStatusMethod.includes("from mchb")
        || !scalarBatchStatusMethod.includes("from resb")
        || !scalarBatchStatusMethod.includes(
          "select lgort as storage_location, charg as batch, bdmng as required_quantity",
        )
        || !scalarBatchStatusMethod.includes("enmng as withdrawn_quantity")
        || !scalarBatchStatusMethod.includes(
          "new zcl_stock_batch_qty_calc( )->calculate(",
        )
        || !scalarBatchStatusMethod.includes("where matnr = @iv_material")
        || !scalarBatchStatusMethod.includes("and werks = @iv_plant")
        || !scalarBatchStatusMethod.includes("sobkz = @space")
        || !scalarBatchStatusMethod.includes("xloek = @space")
        || !scalarBatchStatusMethod.includes("kzear = @space")
        || scalarBatchStockStart < 0 || scalarBatchStockEnd < 0
        || !scalarBatchStockMethod.includes(
          "if ls_batch_status-available_quantity <= 0.",
        )
        || !scalarBatchStockMethod.includes("continue.")
        || !orderReservationTests.includes("method reads_batch_stock.")
        || !orderReservationTests.includes("get_stock_status_by_batch(")
        || !orderReservationTests.includes("get_stock_by_batch(")) {
      errors.push(
        `${stockRepositoryPath} must map scoped scalar batch reservations and test positive-stock filtering`,
      );
    }

    const reservationQuantityCalculatorPath = join(
      projectRoot,
      "src/zcl_stock_avail_qty_calc.clas.abap",
    );
    const reservationQuantityCalculatorTestPath = join(
      projectRoot,
      "src/zcl_stock_avail_qty_calc.clas.testclasses.abap",
    );
    const reservationQuantityCalculator = existsSync(
      reservationQuantityCalculatorPath,
    )
      ? readFileSync(reservationQuantityCalculatorPath, "utf8").toLowerCase()
      : "";
    const reservationQuantityCalculatorTests = existsSync(
      reservationQuantityCalculatorTestPath,
    )
      ? readFileSync(reservationQuantityCalculatorTestPath, "utf8").toLowerCase()
      : "";
    const compactReservationQuantityCalculatorTests =
      reservationQuantityCalculatorTests.replace(/\s+/g, " ");
    const locationQuantityCalculatorPath = join(
      projectRoot,
      "src/zcl_stock_location_qty_calc.clas.abap",
    );
    const batchQuantityCalculatorPath = join(
      projectRoot,
      "src/zcl_stock_batch_qty_calc.clas.abap",
    );
    const locationQuantityCalculator = existsSync(locationQuantityCalculatorPath)
      ? readFileSync(locationQuantityCalculatorPath, "utf8").toLowerCase()
      : "";
    const locationQuantityCalculatorTestPath = join(
      projectRoot,
      "src/zcl_stock_location_qty_calc.clas.testclasses.abap",
    );
    const locationQuantityCalculatorTests = existsSync(
      locationQuantityCalculatorTestPath,
    )
      ? readFileSync(locationQuantityCalculatorTestPath, "utf8").toLowerCase()
      : "";
    const compactLocationQuantityCalculatorTests =
      locationQuantityCalculatorTests.replace(/\s+/g, " ");
    const batchQuantityCalculator = existsSync(batchQuantityCalculatorPath)
      ? readFileSync(batchQuantityCalculatorPath, "utf8").toLowerCase()
      : "";
    const batchQuantityCalculatorTestPath = join(
      projectRoot,
      "src/zcl_stock_batch_qty_calc.clas.testclasses.abap",
    );
    const batchQuantityCalculatorTests = existsSync(
      batchQuantityCalculatorTestPath,
    )
      ? readFileSync(batchQuantityCalculatorTestPath, "utf8").toLowerCase()
      : "";
    const compactBatchQuantityCalculator =
      batchQuantityCalculator.replace(/\s+/g, " ");
    const compactBatchQuantityCalculatorTests =
      batchQuantityCalculatorTests.replace(/\s+/g, " ");
    if (!reservationQuantityCalculator.includes(
      "class-methods calculate_open_res_qty",
    )
        || !reservationQuantityCalculator.includes(
          "rv_quantity = iv_required_quantity - iv_withdrawn_quantity.",
        )
        || !reservationQuantityCalculator.includes("if rv_quantity <= 0.")
        || !reservationQuantityCalculatorTests.includes(
          "method clamps_open_reservation.",
        )
        || !compactReservationQuantityCalculatorTests.includes(
          "iv_required_quantity = '3.000' iv_withdrawn_quantity = '7.000'",
        )
        || !locationQuantityCalculator.includes("lv_unassigned_reservation type decfloat34")
        || !locationQuantityCalculator.includes("lv_location_reservation type decfloat34")
        || !locationQuantityCalculator.includes("conv decfloat34(")
        || !locationQuantityCalculator.includes("if lv_outstanding_quantity > 0.")
        || !locationQuantityCalculator.includes(
          "read table lt_stock transporting no fields",
        )
        || !locationQuantityCalculator.includes("if sy-subrc <> 0.")
        || !locationQuantityCalculatorTests.includes(
          "method spreads_missing_loc_resv.",
        )
        || !compactLocationQuantityCalculatorTests.includes(
          "storage_location = '0002' quantity = '100.000'",
        )
        || !compactLocationQuantityCalculatorTests.includes(
          "storage_location = '0001' required_quantity = '10.000'",
        )
        || !compactLocationQuantityCalculatorTests.includes(
          "exp = conv mard-labst( '90.000' ) act = lt_result[ 1 ]-available_quantity",
        )
        || !locationQuantityCalculatorTests.includes(
          "method nets_large_reservations.",
        )
        || !compactLocationQuantityCalculatorTests.includes(
          "required_quantity = '9999999999.999' withdrawn_quantity = '0.000'",
        )
        || !batchQuantityCalculator.includes("lv_outstanding type decfloat34")
        || !batchQuantityCalculator.includes("lv_negative_stock type decfloat34")
        || !batchQuantityCalculator.includes("conv decfloat34(")
        || !batchQuantityCalculator.includes("if lv_outstanding <= 0.")
        || !compactBatchQuantityCalculator.includes(
          "lv_negative_stock = lv_negative_stock - ls_negative_stock-quantity.",
        )
        || !batchQuantityCalculatorTests.includes(
          "method nets_negative_batch_stock.",
        )
        || !compactBatchQuantityCalculatorTests.includes(
          "storage_location = '0001' batch = 'b-1' quantity = '100.000'",
        )
        || !compactBatchQuantityCalculatorTests.includes(
          "storage_location = '0001' batch = 'b-9' quantity = '-10.000'",
        )
        || !compactBatchQuantityCalculatorTests.includes(
          "exp = conv mchb-clabs( '90.000' ) act = lt_result[ 1 ]-available_quantity",
        )
        || !batchQuantityCalculatorTests.includes(
          "method nets_large_negative_batch.",
        )
        || !compactBatchQuantityCalculatorTests.includes(
          "quantity = '-9999999999.999'",
        )) {
      errors.push(
        "stock reservation quantity netting must clamp over-withdrawn RESB rows before location and batch allocation",
      );
    }

    const locationBulkStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_location_stock_status_bulk.",
    );
    const locationBulkEnd = stockRepository.indexOf("ENDMETHOD.", locationBulkStart);
    const locationBulkMethod = stockRepository
      .slice(locationBulkStart, locationBulkEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    const batchBulkStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_batch_stock_status_bulk.",
    );
    const batchBulkEnd = stockRepository.indexOf("ENDMETHOD.", batchBulkStart);
    const batchBulkMethod = stockRepository
      .slice(batchBulkStart, batchBulkEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    const compactStockRepositoryTests = orderReservationTests.replace(/\s+/g, " ");
    if (locationBulkStart < 0 || locationBulkEnd < 0
        || !/ty_reservation_rows type sorted table of ty_reservation_row\s+with non-unique key material plant storage_location\./i.test(locationBulkMethod)
        || locationBulkMethod.includes("ty_reservation_totals")
        || !locationBulkMethod.includes("calculate_open_res_qty(")
        || !locationBulkMethod.includes("required_quantity = lv_open_reservation_quantity")
        || batchBulkStart < 0 || batchBulkEnd < 0
        || !/ty_reservation_rows type sorted table of ty_reservation_row\s+with non-unique key material plant storage_location batch,/i.test(batchBulkMethod)
        || batchBulkMethod.includes("ty_reservation_totals")
        || !batchBulkMethod.includes("calculate_open_res_qty(")
        || !batchBulkMethod.includes("required_quantity = lv_open_reservation_quantity")
        || !orderReservationTests.includes("method nets_large_bulk_reservations.")
        || !orderReservationTests.includes("9999999999.999")
        || !compactStockRepositoryTests.includes("available_unrestricted_qty")
        || !compactStockRepositoryTests.includes("available_quantity")
        || !compactStockRepositoryTests.includes("conv mard-labst( '0.000' )")
        || !compactStockRepositoryTests.includes("conv mchb-clabs( '0.000' )")) {
      errors.push(
        `${stockRepositoryPath} must preserve individual location and batch RESB rows through high-precision allocation`,
      );
    }

    const reservationAggregationRules = [
      "METHOD zif_stock_repository~get_available_stock_date_bulk.",
      "METHOD zif_stock_repository~get_order_reservations_bulk.",
      "METHOD zif_stock_repository~get_stock_status_bulk.",
      "METHOD zif_stock_repository~get_location_stock_status_bulk.",
      "METHOD zif_stock_repository~get_batch_stock_status_bulk.",
    ];
    for (const methodName of reservationAggregationRules) {
      const methodStart = stockRepository.indexOf(methodName);
      const methodEnd = stockRepository.indexOf("ENDMETHOD.", methodStart);
      const methodBody = stockRepository
        .slice(methodStart, methodEnd)
        .replace(/\s+/g, " ")
        .toLowerCase();
      if (methodStart < 0 || methodEnd < 0
          || !methodBody.includes("calculate_open_res_qty(")) {
        errors.push(
          `${stockRepositoryPath} must clamp each RESB row before aggregation in ${methodName.slice(7, -1)}`,
        );
      }
    }

    const unrestrictedStockStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_unrestricted_stock.",
    );
    const unrestrictedStockEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      unrestrictedStockStart,
    );
    const unrestrictedStockMethod = stockRepository
      .slice(unrestrictedStockStart, unrestrictedStockEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (unrestrictedStockStart < 0 || unrestrictedStockEnd < 0
        || !unrestrictedStockMethod.includes("select labst as quantity")
        || !unrestrictedStockMethod.includes("from mard")
        || !unrestrictedStockMethod.includes("where matnr = @iv_material")
        || !unrestrictedStockMethod.includes("and werks = @iv_plant")
        || !unrestrictedStockMethod.includes("bdmng as required_quantity")
        || !unrestrictedStockMethod.includes("enmng as withdrawn_quantity")
        || !unrestrictedStockMethod.includes("lv_unrestricted_quantity type decfloat34")
        || !unrestrictedStockMethod.includes("lv_reserved_quantity type decfloat34")
        || !unrestrictedStockMethod.includes("conv decfloat34(")
        || !unrestrictedStockMethod.includes("if lv_open_quantity > 0.")
        || !unrestrictedStockMethod.includes("if lv_unrestricted_quantity < 0.")
        || !unrestrictedStockMethod.includes("if lv_available_quantity < 0.")
        || !unrestrictedStockMethod.includes("convert_to_stock_quantity(")
        || !unrestrictedStockMethod.includes("sobkz = @space")
        || !unrestrictedStockMethod.includes("xloek = @space")
        || !unrestrictedStockMethod.includes("kzear = @space")
        || !orderReservationTests.includes("method nets_unrestricted_stock_safely.")
        || !orderReservationTests.includes("mat-unrestricted-range")
        || !orderReservationTests.includes("mat-reservation-range")
        || !orderReservationTests.includes("bdmng = '9999999999.999'")
        || !orderReservationTests.includes("catch zcx_invalid_stock_request.")) {
      errors.push(
        `${stockRepositoryPath} must test scalar unrestricted stock netting and the zero clamp`,
      );
    }

    const safetyStockBulkStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_safety_stock_bulk.",
    );
    const safetyStockBulkEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      safetyStockBulkStart,
    );
    const safetyStockBulkMethod = stockRepository.slice(
      safetyStockBulkStart,
      safetyStockBulkEnd,
    );
    const compactSafetyStockBulkMethod = safetyStockBulkMethod
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (safetyStockBulkStart < 0 || safetyStockBulkEnd < 0
        || !safetyStockBulkMethod.includes(
          "FOR ALL ENTRIES IN @it_requests",
        )
        || !safetyStockBulkMethod.includes(
          "matnr = @it_requests-material",
        )
        || !safetyStockBulkMethod.includes(
          "werks = @it_requests-plant",
        )
        || !safetyStockBulkMethod.includes("IF it_requests IS INITIAL.")
        || !/ty_safety_stock_rows type hashed table of ty_safety_stock_row with unique key material plant\./i.test(
          compactSafetyStockBulkMethod,
        )
        || !/read table lt_safety_stock_rows into data\(ls_safety_stock_row\) with table key material = <ls_status>-material plant = <ls_status>-plant\./i.test(
          compactSafetyStockBulkMethod,
        )) {
      errors.push(
        `${stockRepositoryPath} must guard, batch, and key MARC safety-stock reads by material and plant`,
      );
    }

    const scalarSafetyStockStart = stockRepository.indexOf(
      "METHOD zif_stock_repository~get_safety_stock.",
    );
    const scalarSafetyStockEnd = stockRepository.indexOf(
      "ENDMETHOD.",
      scalarSafetyStockStart,
    );
    const scalarSafetyStockMethod = stockRepository
      .slice(scalarSafetyStockStart, scalarSafetyStockEnd)
      .replace(/\s+/g, " ")
      .toLowerCase();
    const scalarSafetyStockTestStart = orderReservationTests.indexOf(
      "method reads_plant_stock_status.",
    );
    const scalarSafetyStockTestEnd = orderReservationTests.indexOf(
      "endmethod.",
      scalarSafetyStockTestStart,
    );
    const scalarSafetyStockTest = orderReservationTests.slice(
      scalarSafetyStockTestStart,
      scalarSafetyStockTestEnd,
    );
    const compactScalarSafetyStockTest = scalarSafetyStockTest
      .replace(/\s+/g, " ")
      .toLowerCase();
    if (scalarSafetyStockStart < 0 || scalarSafetyStockEnd < 0
        || !scalarSafetyStockMethod.includes("select single eisbe")
        || !scalarSafetyStockMethod.includes("from marc")
        || !scalarSafetyStockMethod.includes("where matnr = @iv_material")
        || !scalarSafetyStockMethod.includes("and werks = @iv_plant")
        || scalarSafetyStockTestStart < 0 || scalarSafetyStockTestEnd < 0
        || !scalarSafetyStockTest.includes(
          "zif_stock_repository~get_safety_stock(",
        )
        || !compactScalarSafetyStockTest.includes(
          "exp = conv marc-eisbe( '4.000' ) act = lv_scalar_safety_stock ).",
        )
        || !compactScalarSafetyStockTest.includes(
          "exp = conv marc-eisbe( '7.000' ) act = lv_other_plant_safety_stock ).",
        )
        || !compactScalarSafetyStockTest.includes(
          "exp = conv marc-eisbe( '0.000' ) act = lv_missing_safety_stock ).",
        )
        || !scalarSafetyStockTest.includes("matnr( 'mat-1' )")
        || !scalarSafetyStockTest.includes("werks( '2000' )")
        || !scalarSafetyStockTest.includes("matnr( 'mat-3' )")) {
      errors.push(
        `${stockRepositoryPath} must test scalar MARC safety stock for present and missing rows`,
      );
    }

    const reservationScanRules = [
      {
        method: "METHOD zif_stock_repository~get_open_stock_res_bulk.",
        type: /ty_reservation_rows type standard table of ty_reservation_row with empty key with non-unique sorted key by_scope components material plant\./i,
        loop: /loop at lt_rows using key by_scope into data\(ls_row\) where material = <ls_result>-material and plant = <ls_result>-plant\./i,
      },
      {
        method: "METHOD zif_so_reservation_finder~get_open_reservations_bulk.",
        type: /data lt_reservation_items type standard table of ty_reservation_item_scope with empty key with non-unique sorted key by_reservation_number components reservation_number\./i,
        loop: /loop at lt_reservation_items using key by_reservation_number into data\(ls_reservation_item\) where reservation_number = ls_candidate-reservation_number\./i,
      },
      {
        method: "METHOD zif_so_reservation_finder~get_open_item_reservations.",
        type: /data lt_reservation_items type standard table of ty_reservation_item_scope with empty key with non-unique sorted key by_reservation_number components reservation_number\./i,
        loop: /loop at lt_reservation_items using key by_reservation_number into data\(ls_reservation_item\) where reservation_number = ls_candidate-reservation_number\./i,
      },
    ];
    for (const rule of reservationScanRules) {
      const methodStart = stockRepository.indexOf(rule.method);
      const methodEnd = stockRepository.indexOf("ENDMETHOD.", methodStart);
      const methodBody = stockRepository.slice(methodStart, methodEnd);
      const compactMethodBody = methodBody.replace(/\s+/g, " ");
      if (methodStart < 0 || methodEnd < 0
          || !rule.type.test(compactMethodBody)
          || !rule.loop.test(compactMethodBody)) {
        errors.push(
          `${stockRepositoryPath} must use indexed reservation ranges in ${rule.method.slice(7, -1)}`,
        );
      }
    }

    const reservationCandidateRules = [
      {
        method: "METHOD zif_so_reservation_finder~get_open_reservations_bulk.",
        guard: "if it_sales_documents is initial.",
        requestTable: "for all entries in @it_sales_documents",
        candidateScope: "kdauf = @it_sales_documents-table_line",
        ownerCheck: "ls_reservation_item-sales_document <> ls_candidate-sales_document",
      },
      {
        method: "METHOD zif_so_reservation_finder~get_open_item_reservations.",
        guard: "if it_sales_order_items is initial.",
        requestTable: "for all entries in @it_sales_order_items",
        candidateScope: "kdpos = @it_sales_order_items-item_number",
        ownerCheck: "ls_reservation_item-item_number <> ls_candidate-item_number",
      },
    ];
    for (const rule of reservationCandidateRules) {
      const methodStart = stockRepository.indexOf(rule.method);
      const methodEnd = stockRepository.indexOf("ENDMETHOD.", methodStart);
      const methodBody = stockRepository.slice(methodStart, methodEnd)
        .replace(/\s+/g, " ")
        .toLowerCase();
      if (methodStart < 0 || methodEnd < 0
          || !methodBody.includes(rule.guard)
          || !methodBody.includes(rule.requestTable)
          || !methodBody.includes(rule.candidateScope)
          || !methodBody.includes("bwart = '231'")
          || !methodBody.includes("sobkz = @space")
          || !methodBody.includes("xloek = @space")
          || !methodBody.includes("kzear = @space")
          || !methodBody.includes("for all entries in @lt_candidate_numbers")
          || !methodBody.includes("where rsnum = @lt_candidate_numbers-table_line")
          || !methodBody.includes(rule.ownerCheck)
          || !methodBody.includes("ls_reservation_item-movement_type <> '231'")
          || !methodBody.includes("ls_reservation_item-special_stock <> space")) {
        errors.push(
          `${stockRepositoryPath} must validate candidate reservation ownership in ${rule.method.slice(7, -1)}`,
        );
      }
    }
    if (!orderReservationTests.includes(
      "method reads_so_resv_candidates.",
    ) || !orderReservationTests.includes("get_open_reservations_bulk(")
        || !orderReservationTests.includes("get_open_item_reservations(")) {
      errors.push(
        `${stockRepositoryPath} must exercise both sales-order reservation finders against RESB test data`,
      );
    }
  }
}

const ccReservationServicePath = "src/zcl_cc_reservation_service.clas.abap";
if (existsSync(join(projectRoot, ccReservationServicePath))) {
  const ccReservationService = readFileSync(
    join(projectRoot, ccReservationServicePath),
    "utf8",
  );
  const bulkReadStart = ccReservationService.indexOf(
    "METHOD read_cc_reservations_bulk.",
  );
  const bulkReadEnd = ccReservationService.indexOf("ENDMETHOD.", bulkReadStart);
  const bulkReadMethod = ccReservationService.slice(bulkReadStart, bulkReadEnd);
  const compactBulkReadMethod = bulkReadMethod.replace(/\s+/g, " ");
  if (bulkReadStart < 0 || bulkReadEnd < 0
      || !/ty_reservation_positions type sorted table of ty_reservation_position with unique key cost_center row_number\./i.test(
        compactBulkReadMethod,
      )
      || !/if lines\( it_cost_centers \) > 1\./i.test(
        compactBulkReadMethod,
      )
      || !/row_number\s*=\s*lv_reservation_row_number\s*\)\s*into table lt_reservation_positions\./i.test(
        compactBulkReadMethod,
      )
      || !/loop at lt_reservation_positions into data\(ls_reservation_position\) where cost_center = lv_cost_center\./i.test(
        compactBulkReadMethod,
      )
      || !/read table lt_reservations into ls_center_reservation index ls_reservation_position-row_number\./i.test(
        compactBulkReadMethod,
      )
      || !/loop at lt_reservations into ls_center_reservation where cost_center = lv_cost_center\./i.test(
        compactBulkReadMethod,
      )) {
    errors.push(
      `${ccReservationServicePath} must preserve per-center reservation order through its row-position index`,
    );
  }
}

const bapiSalesOrderPath = "src/zcl_bapi_sales_order_api.clas.abap";
if (existsSync(join(projectRoot, bapiSalesOrderPath))) {
  const bapiSalesOrder = readFileSync(
    join(projectRoot, bapiSalesOrderPath),
    "utf8",
  );
  const mapOrderReadStart = bapiSalesOrder.indexOf("METHOD map_order_read.");
  const mapOrderReadEnd = bapiSalesOrder.indexOf("ENDMETHOD.", mapOrderReadStart);
  const mapOrderRead = bapiSalesOrder.slice(mapOrderReadStart, mapOrderReadEnd);
  const compactBapiSalesOrder = bapiSalesOrder.replace(/\s+/g, " ");
  const compactMapOrderRead = mapOrderRead.replace(/\s+/g, " ");
  const readOrdersStart = bapiSalesOrder.indexOf(
    "METHOD zif_sales_order_api~read_orders.",
  );
  const readOrdersEnd = bapiSalesOrder.indexOf("ENDMETHOD.", readOrdersStart);
  const readOrders = bapiSalesOrder.slice(readOrdersStart, readOrdersEnd);
  const compactReadOrders = readOrders.replace(/\s+/g, " ");
  if (mapOrderReadStart < 0 || mapOrderReadEnd < 0
      || readOrdersStart < 0 || readOrdersEnd < 0
      || !/types ty_indexed_delivery_items type standard table of zif_sales_order_delivery_repo=>ty_order_item with empty key with non-unique sorted key by_document_item_date components sales_document item_number requested_date schedule_line\./i.test(
        compactBapiSalesOrder,
      )
      || !/it_delivery_items type ty_indexed_delivery_items/i.test(
        compactBapiSalesOrder,
      )
      || !/loop at it_delivery_items using key by_document_item_date into data\(ls_delivery_item\) where sales_document = iv_sales_document and item_number = ls_bapi_item-itm_number\./i.test(
        compactMapOrderRead,
      )
      || !/ty_bapi_item_positions type sorted table of ty_bapi_item_position with unique key sales_document row_number\./i.test(
        compactBapiSalesOrder,
      )
      || !/types ty_order_header_lookup type hashed table of bapisdhd with unique key doc_number\./i.test(
        compactReadOrders,
      )
      || !/if lines\( it_sales_documents \) > 1\./i.test(
        compactReadOrders,
      )
      || !/row_number = lv_bapi_item_row_number\s*\) into table lt_bapi_item_positions\./i.test(
        compactReadOrders,
      )
      || !/read table lt_order_header_lookup into data\(ls_order_header\) with table key doc_number = lv_requested_document\./i.test(
        compactReadOrders,
      )
      || !/it_bapi_item_positions = lt_bapi_item_positions/i.test(
        compactReadOrders,
      )
      || !/loop at it_bapi_item_positions into data\(ls_bapi_item_position\) where sales_document = iv_sales_document\./i.test(
        compactMapOrderRead,
      )
      || !/read table it_bapi_items into ls_bapi_item index ls_bapi_item_position-row_number\./i.test(
        compactMapOrderRead,
      )
      || !/loop at it_bapi_items into ls_bapi_item where doc_number = iv_sales_document\./i.test(
        compactMapOrderRead,
      )
      || !/loop at lt_document_bapi_items into ls_bapi_item\./i.test(
        compactMapOrderRead,
      )) {
    errors.push(
      `${bapiSalesOrderPath} must index order headers, BAPI item scopes, and delivery rows while preserving item order`,
    );
  }
}

const stockServicePath = "src/zcl_stock_service.clas.abap";
if (existsSync(join(projectRoot, stockServicePath))) {
  const stockService = readFileSync(join(projectRoot, stockServicePath), "utf8");
  const stockServiceTestPath = join(
    projectRoot,
    "src/zcl_stock_service.clas.testclasses.abap",
  );
  const stockServiceTests = existsSync(stockServiceTestPath)
    ? readFileSync(stockServiceTestPath, "utf8").toLowerCase()
    : "";
  const compactStockServiceTests = stockServiceTests.replace(/\s+/g, " ");
  const stockQuantityConversionStart = stockService.indexOf(
    "METHOD convert_stock_quantity.",
  );
  const stockQuantityConversionEnd = stockService.indexOf(
    "ENDMETHOD.",
    stockQuantityConversionStart,
  );
  const stockQuantityConversionMethod = stockService
    .slice(stockQuantityConversionStart, stockQuantityConversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  if (stockQuantityConversionStart < 0 || stockQuantityConversionEnd < 0
      || !stockQuantityConversionMethod.includes("catch cx_sy_conversion_overflow.")
      || !stockQuantityConversionMethod.includes(
        "if iv_base_quantity <> 0 and rv_quantity is initial.",
      )
      || !stockServiceTests.includes("method rejects_stock_uom_overflow.")
      || !stockServiceTests.includes("method rejects_stock_uom_round_zero.")
      || !compactStockServiceTests.includes(
        "unrestricted_quantity = conv mard-labst( '9999999999.999' )",
      )
      || !compactStockServiceTests.includes("iv_denominator = 99999")
      || !compactStockServiceTests.includes("iv_numerator = 99999")
      || !compactStockServiceTests.includes(
        "catch zcx_invalid_stock_request.",
      )) {
    errors.push(
      `${stockServicePath} must reject overflowing and zero-rounded stock UOM results`,
    );
  }
  const compactStockService = stockService.replace(/\s+/g, " ").toLowerCase();
  const stockQuantitySumStart = stockService.indexOf(
    "METHOD sum_stock_quantities.",
  );
  const stockQuantitySumEnd = stockService.indexOf(
    "ENDMETHOD.",
    stockQuantitySumStart,
  );
  const stockQuantitySumMethod = stockService
    .slice(stockQuantitySumStart, stockQuantitySumEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const atpAggregationMethods = [
    "build_unit_atp_checks",
    "allocate_date_demands_atp",
    "allocate_plants_date_loc_atp",
    "allocate_plants_date_atp",
    "allocate_plants_fefo_date_atp",
    "allocate_plants_date_batch_atp",
    "allocate_plants_atp",
    "allocate_plants_uom_atp_prio",
    "allocate_plants_batch_atp",
    "allocate_plants_batch_uom_atp",
    "allocate_plants_fefo_atp",
    "allocate_plants_fefo_uom_atp",
    "allocate_by_location_atp",
    "allocate_location_uom_atp_prio",
    "allocate_location_date_uom_atp",
    "allocate_location_date_atp",
    "build_batch_atp_checks",
  ];
  const missingAtpQuantityGuards = atpAggregationMethods.filter((name) => {
    const start = compactStockService.indexOf(`method ${name}.`);
    const end = compactStockService.indexOf("endmethod.", start);
    return start < 0 || end < 0
      || !compactStockService.slice(start, end).includes("sum_stock_quantities(");
  });
  if (stockQuantitySumStart < 0 || stockQuantitySumEnd < 0
      || !stockQuantitySumMethod.includes("conv decfloat34")
      || !stockQuantitySumMethod.includes("catch cx_sy_conversion_overflow.")
      || missingAtpQuantityGuards.length > 0
      || /<ls_atp_check>-allocated_base_quantity = <ls_atp_check>-allocated_base_quantity \+/.test(compactStockService)
      || /<ls_atp_day>-demand_quantity = <ls_atp_day>-demand_quantity \+/.test(compactStockService)
      || /lv_cumulative_quantity = lv_cumulative_quantity \+/.test(compactStockService)
      || !stockServiceTests.includes("method rejects_atp_quantity_overflow.")) {
    errors.push(
      `${stockServicePath} must check ATP allocation and cumulative quantity sums before SAP quantity conversion`,
    );
  }
  const datedPlantAllocationStart = stockService.indexOf(
    "METHOD allocate_plants_by_date.",
  );
  const datedPlantAllocationEnd = stockService.indexOf(
    "ENDMETHOD.",
    datedPlantAllocationStart,
  );
  const datedPlantAllocation = stockService
    .slice(datedPlantAllocationStart, datedPlantAllocationEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  if (datedPlantAllocationStart < 0 || datedPlantAllocationEnd < 0
      || (datedPlantAllocation.match(/sum_stock_quantities\(/g) || []).length < 2
      || !stockServiceTests.includes(
        "method rejects_xplant_date_overflow.",
      )
      || !stockServiceTests.includes(
        "method rejects_date_conf_sum_overflow.",
      )
      || !stockServiceTests.includes("9999999999.999")) {
    errors.push(
      `${stockServicePath} must reject overflowing dated receipt and cross-plant quantity totals`,
    );
  }
  const datedReceiptMethods = [
    "allocate_request_by_date",
    "allocate_demands_by_date",
  ];
  const missingDatedReceiptGuards = datedReceiptMethods.filter((name) => {
    const start = compactStockService.indexOf(`method ${name}.`);
    const end = compactStockService.indexOf("endmethod.", start);
    return start < 0 || end < 0
      || !compactStockService.slice(start, end)
        .includes("sum_stock_quantities(");
  });
  if (missingDatedReceiptGuards.length > 0
      || !stockServiceTests.includes("method rejects_date_receipt_overflow.")
      || !stockServiceTests.includes("method rejects_bulk_receipt_overflow.")
      || !stockServiceTests.includes("9999999999.999")) {
    errors.push(
      `${stockServicePath} must reject overflowing confirmed receipts in dated single and bulk allocation`,
    );
  }
  const crossPlantAllocationStart = stockService.indexOf(
    "METHOD allocate_across_plants.",
  );
  const crossPlantAllocationEnd = stockService.indexOf(
    "ENDMETHOD.",
    crossPlantAllocationStart,
  );
  const crossPlantAllocation = stockService
    .slice(crossPlantAllocationStart, crossPlantAllocationEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  if (crossPlantAllocationStart < 0 || crossPlantAllocationEnd < 0
      || (crossPlantAllocation.match(/sum_stock_quantities\(/g) || []).length < 4
      || !stockServiceTests.includes("method rejects_xplant_avail_overflow.")
      || !stockServiceTests.includes("method rejects_xplant_rcpt_overflow.")
      || !stockServiceTests.includes("9999999999.999")) {
    errors.push(
      `${stockServicePath} must check cross-plant location and projected receipt totals`,
    );
  }
  const crossPlantSourceCores = [
    "allocate_across_plants",
    "allocate_plants_by_date",
    "allocate_plants_by_expiry",
    "allocate_plants_fefo_by_date",
    "allocate_plants_by_batch",
  ];
  const missingDistinctSourceValidation = crossPlantSourceCores.filter(
    (name) => {
      const start = stockService.toLowerCase().indexOf(`method ${name}.`);
      const end = stockService.toLowerCase().indexOf("endmethod.", start);
      return start < 0 || end < 0
        || !stockService.slice(start, end).toLowerCase().includes(
          "validate_xplant_sources(",
        );
    },
  );
  if (missingDistinctSourceValidation.length > 0
      || !stockServiceTests.includes(
        "method rejects_same_plant_source.",
      )
      || !stockServiceTests.includes("get_read_count( )")) {
    errors.push(
      `${stockServicePath} must reject same-plant sources before cross-plant reads`,
    );
  }
  const sourceQuantityConversionStart = stockService.indexOf(
    "METHOD convert_source_stock_quantity.",
  );
  const sourceQuantityConversionEnd = stockService.indexOf(
    "ENDMETHOD.",
    sourceQuantityConversionStart,
  );
  const sourceQuantityConversionMethod = stockService
    .slice(sourceQuantityConversionStart, sourceQuantityConversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const sourceOverflowTestStart = stockServiceTests.indexOf(
    "method rejects_uom_input_overflow.",
  );
  const sourceOverflowTestEnd = stockServiceTests.indexOf(
    "endmethod.",
    sourceOverflowTestStart,
  );
  const sourceOverflowTest = stockServiceTests
    .slice(sourceOverflowTestStart, sourceOverflowTestEnd)
    .replace(/\s+/g, " ");
  const rawSourceConversions = stockService.match(
    /CONV mard-labst\(\s*CONV decfloat34\([^)]*\)\s*\*\s*CONV decfloat34\([^)]*numerator[^)]*\)\s*\/\s*CONV decfloat34\(/gi,
  );
  if (sourceQuantityConversionStart < 0 || sourceQuantityConversionEnd < 0
      || !sourceQuantityConversionMethod.includes(
        "rv_base_quantity = convert_stock_quantity(",
      )
      || !sourceQuantityConversionMethod.includes(
        "iv_numerator = iv_denominator",
      )
      || !sourceQuantityConversionMethod.includes(
        "iv_denominator = iv_numerator",
      )
      || sourceOverflowTestStart < 0 || sourceOverflowTestEnd < 0
      || !sourceOverflowTest.includes(
        "requested_quantity = '9999999999.999'",
      )
      || !sourceOverflowTest.includes("iv_numerator = 99999")
      || !sourceOverflowTest.includes(
        "act = lo_repository->get_read_count( )",
      )
      || rawSourceConversions) {
    errors.push(
      `${stockServicePath} must route stock demand conversions through the checked helper and cover input overflow`,
    );
  }
  const bulkMethodStart = stockService.indexOf(
    "METHOD get_projected_receipts_bulk.",
  );
  const bulkMethodEnd = stockService.indexOf("ENDMETHOD.", bulkMethodStart);
  const bulkMethod = stockService.slice(bulkMethodStart, bulkMethodEnd);
  if (bulkMethodStart < 0 || bulkMethodEnd < 0
      || !bulkMethod.includes("mo_stock_repository->get_projected_receipts_bulk(")) {
    errors.push(
      `${stockServicePath} must delegate bulk projections to the repository bulk method`,
    );
  }

  const optionBulkStart = stockService.indexOf(
    "METHOD get_proj_receipts_opts_bulk.",
  );
  const optionBulkEnd = stockService.indexOf("ENDMETHOD.", optionBulkStart);
  const optionBulkMethod = stockService.slice(optionBulkStart, optionBulkEnd);
  if (optionBulkStart < 0 || optionBulkEnd < 0
      || !optionBulkMethod.includes(
        "mo_stock_repository->get_projected_receipts_bulk(",
      )
      || optionBulkMethod.includes("get_projected_receipts(")) {
    errors.push(
      `${stockServicePath} must batch per-request projection options through the repository bulk method`,
    );
  }

  const dateAllocationStart = stockService.indexOf(
    "METHOD allocate_demands_by_date.",
  );
  const dateAllocationEnd = stockService.indexOf("ENDMETHOD.", dateAllocationStart);
  const dateAllocationMethod = stockService.slice(
    dateAllocationStart,
    dateAllocationEnd,
  );
  if (dateAllocationStart < 0 || dateAllocationEnd < 0
      || !dateAllocationMethod.includes(
        "mo_stock_repository->get_available_stock_date_bulk(",
      )
      || (dateAllocationMethod.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
      || dateAllocationMethod.includes(
        "mo_stock_repository->get_safety_stock(",
      )
      || dateAllocationMethod.includes("mo_stock_repository->get_available_stock_by_date(")) {
    errors.push(
      `${stockServicePath} must batch dated availability and safety-stock reads`,
    );
  }

  const crossPlantDateStart = stockService.indexOf(
    "METHOD allocate_plants_by_date.",
  );
  const crossPlantDateEnd = stockService.indexOf(
    "ENDMETHOD.",
    crossPlantDateStart,
  );
  const crossPlantDateMethod = stockService.slice(
    crossPlantDateStart,
    crossPlantDateEnd,
  );
  if (crossPlantDateStart < 0 || crossPlantDateEnd < 0
      || !crossPlantDateMethod.includes(
        "mo_stock_repository->get_available_stock_date_bulk(",
      )
      || (crossPlantDateMethod.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
      || crossPlantDateMethod.includes(
        "mo_stock_repository->get_safety_stock(",
      )
      || crossPlantDateMethod.includes(
        "mo_stock_repository->get_available_stock_by_date(",
      )) {
    errors.push(
      `${stockServicePath} must batch dated source-plant availability and safety-stock reads`,
    );
  }

  for (const methodName of [
    "allocate_across_plants",
    "allocate_by_storage_location",
    "allocate_location_by_date",
  ]) {
    const methodStart = stockService.indexOf(`METHOD ${methodName}.`);
    const methodEnd = stockService.indexOf("ENDMETHOD.", methodStart);
    const method = stockService.slice(methodStart, methodEnd);
    if (methodStart < 0 || methodEnd < 0
        || (method.match(/get_location_stock_status_bulk\(/g) ?? []).length !== 1
        || method.includes("mo_stock_repository->get_stock_by_location(")
        || (method.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
        || method.includes("mo_stock_repository->get_safety_stock(")) {
      errors.push(
        `${stockServicePath} must batch location and safety-stock reads in ${methodName}`,
      );
    }
  }

  const crossPlantFefoDateStart = stockService.indexOf(
    "METHOD allocate_plants_fefo_by_date.",
  );
  const crossPlantFefoDateEnd = stockService.indexOf(
    "ENDMETHOD.",
    crossPlantFefoDateStart,
  );
  const crossPlantFefoDateMethod = stockService.slice(
    crossPlantFefoDateStart,
    crossPlantFefoDateEnd,
  );
  if (crossPlantFefoDateStart < 0 || crossPlantFefoDateEnd < 0
      || (crossPlantFefoDateMethod.match(/get_batch_stock_status_bulk\(/g) ?? []).length !== 1
      || (crossPlantFefoDateMethod.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
      || crossPlantFefoDateMethod.includes(
        "mo_stock_repository->get_safety_stock(",
      )
      || !crossPlantFefoDateMethod.includes(
        "get_batch_stock_status_bulk(",
      )
      || crossPlantFefoDateMethod.includes(
        "mo_stock_repository->get_stock_by_batch(",
      )) {
    errors.push(
      `${stockServicePath} must batch dated cross-plant FEFO stock reads`,
    );
  }

  const crossPlantFefoStart = stockService.indexOf(
    "METHOD allocate_plants_by_expiry.",
  );
  const crossPlantFefoEnd = stockService.indexOf(
    "ENDMETHOD.",
    crossPlantFefoStart,
  );
  const crossPlantFefoMethod = stockService.slice(
    crossPlantFefoStart,
    crossPlantFefoEnd,
  );
  if (crossPlantFefoStart < 0 || crossPlantFefoEnd < 0
      || (crossPlantFefoMethod.match(/get_batch_stock_status_bulk\(/g) ?? []).length !== 1
      || (crossPlantFefoMethod.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
      || crossPlantFefoMethod.includes(
        "mo_stock_repository->get_safety_stock(",
      )
      || crossPlantFefoMethod.includes(
        "mo_stock_repository->get_stock_by_batch(",
      )) {
    errors.push(
      `${stockServicePath} must batch undated cross-plant FEFO stock and safety-status reads`,
    );
  }

  const crossPlantBatchStart = stockService.indexOf(
    "METHOD allocate_plants_by_batch.",
  );
  const crossPlantBatchEnd = stockService.indexOf(
    "ENDMETHOD.",
    crossPlantBatchStart,
  );
  const crossPlantBatchMethod = stockService.slice(
    crossPlantBatchStart,
    crossPlantBatchEnd,
  );
  if (crossPlantBatchStart < 0 || crossPlantBatchEnd < 0
      || (crossPlantBatchMethod.match(/get_batch_stock_status_bulk\(/g) ?? []).length !== 1
      || (crossPlantBatchMethod.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
      || crossPlantBatchMethod.includes(
        "mo_stock_repository->get_safety_stock(",
      )
      || crossPlantBatchMethod.includes(
        "mo_stock_repository->get_stock_by_batch(",
      )) {
    errors.push(
      `${stockServicePath} must batch cross-plant exact-batch stock and safety-status reads`,
    );
  }

  const batchStart = stockService.indexOf("METHOD allocate_by_batch.");
  const batchEnd = stockService.indexOf("ENDMETHOD.", batchStart);
  const batchMethod = stockService.slice(batchStart, batchEnd);
  if (batchStart < 0 || batchEnd < 0
      || (batchMethod.match(/get_batch_stock_status_bulk\(/g) ?? []).length !== 1
      || (batchMethod.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
      || batchMethod.includes("mo_stock_repository->get_safety_stock(")
      || batchMethod.includes("mo_stock_repository->get_stock_by_batch(")) {
    errors.push(
      `${stockServicePath} must batch exact-batch stock and safety-status reads`,
    );
  }

  const fefoStart = stockService.indexOf("METHOD allocate_by_expiry.");
  const fefoEnd = stockService.indexOf("ENDMETHOD.", fefoStart);
  const fefoMethod = stockService.slice(fefoStart, fefoEnd);
  if (fefoStart < 0 || fefoEnd < 0
      || (fefoMethod.match(/get_batch_stock_status_bulk\(/g) ?? []).length !== 1
      || (fefoMethod.match(/get_safety_stock_bulk\(/g) ?? []).length !== 1
      || fefoMethod.includes("mo_stock_repository->get_safety_stock(")
      || fefoMethod.includes("mo_stock_repository->get_stock_by_batch(")) {
    errors.push(
      `${stockServicePath} must batch single-plant FEFO stock and safety-status reads`,
    );
  }

  const componentStockStart = stockService.indexOf(
    "METHOD allocate_component_stock.",
  );
  const componentStockEnd = stockService.indexOf(
    "ENDMETHOD.",
    componentStockStart,
  );
  const componentStockMethod = stockService.slice(
    componentStockStart,
    componentStockEnd,
  );
  if (componentStockStart < 0 || componentStockEnd < 0
      || (componentStockMethod.match(
        /get_location_stock_status_bulk\(/g,
      ) ?? []).length !== 1
      || (componentStockMethod.match(
        /get_batch_stock_status_bulk\(/g,
      ) ?? []).length !== 1
      || (componentStockMethod.match(
        /get_open_stock_res_bulk\(/g,
      ) ?? []).length !== 1
      || (componentStockMethod.match(
        /get_safety_stock_bulk\(/g,
      ) ?? []).length !== 1
      || componentStockMethod.includes(
        "mo_stock_repository->get_stock_status_by_location(",
      )
      || componentStockMethod.includes(
        "mo_stock_repository->get_stock_status_by_batch(",
      )
      || componentStockMethod.includes(
        "mo_stock_repository->get_open_stock_reservations(",
      )
      || componentStockMethod.includes(
        "mo_stock_repository->get_safety_stock(",
      )) {
    errors.push(
      `${stockServicePath} must batch component stock-status and reservation reads`,
    );
  }
}

const prodCompPath = "src/zcl_prod_comp_service.clas.abap";
if (existsSync(join(projectRoot, prodCompPath))) {
  const prodComp = readFileSync(join(projectRoot, prodCompPath), "utf8");
  const prodCompTestPath = join(
    projectRoot,
    "src/zcl_prod_comp_service.clas.testclasses.abap",
  );
  const prodCompTests = existsSync(prodCompTestPath)
    ? readFileSync(prodCompTestPath, "utf8").toLowerCase()
    : "";
  const conversionStart = prodComp.indexOf(
    "METHOD convert_component_quantity.",
  );
  const conversionEnd = prodComp.indexOf("ENDMETHOD.", conversionStart);
  const conversionMethod = prodComp
    .slice(conversionStart, conversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const overflowTestStart = prodCompTests.indexOf(
    "method rejects_component_uom_overflow.",
  );
  const overflowTestEnd = prodCompTests.indexOf(
    "endmethod.",
    overflowTestStart,
  );
  const overflowTest = prodCompTests
    .slice(overflowTestStart, overflowTestEnd)
    .replace(/\s+/g, " ");
  const rawComponentConversions = prodComp.match(
    /CONV mard-labst\(\s*CONV decfloat34\( ls_component-open_quantity \)/gi,
  );
  if (conversionStart < 0 || conversionEnd < 0
      || !conversionMethod.includes("catch cx_sy_conversion_overflow.")
      || !conversionMethod.includes(
        "if iv_source_quantity <> 0 and rv_base_quantity is initial.",
      )
      || overflowTestStart < 0 || overflowTestEnd < 0
      || !overflowTest.includes("required_quantity = '9999999.999'")
      || !overflowTest.includes("iv_numerator = 99999")
      || !overflowTest.includes(
        "get_location_bulk_call_count( )",
      )
      || rawComponentConversions) {
    errors.push(
      `${prodCompPath} must reject overflowing or zero-rounded component UOM quantities before stock reads`,
    );
  }

  const milliConversionStart = prodComp.indexOf(
    "METHOD milli_to_stock_quantity.",
  );
  const milliConversionEnd = prodComp.indexOf(
    "ENDMETHOD.",
    milliConversionStart,
  );
  const milliConversionMethod = prodComp
    .slice(milliConversionStart, milliConversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const quantityOverflowTestStart = prodCompTests.indexOf(
    "method rejects_repl_qty_overflow.",
  );
  const quantityOverflowTestEnd = prodCompTests.indexOf(
    "endmethod.",
    quantityOverflowTestStart,
  );
  const quantityOverflowTest = prodCompTests
    .slice(quantityOverflowTestStart, quantityOverflowTestEnd)
    .replace(/\s+/g, " ");
  const suggestionStart = prodComp.indexOf(
    "METHOD suggest_comp_replenishment.",
  );
  const suggestionEnd = prodComp.indexOf("ENDMETHOD.", suggestionStart);
  const suggestionMethod = prodComp
    .slice(suggestionStart, suggestionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const rawMilliCasts = /conv mard-labst\(\s*conv decfloat34\(\s*conv string\(/i
    .test(suggestionMethod);
  if (milliConversionStart < 0 || milliConversionEnd < 0
      || !milliConversionMethod.includes("catch cx_sy_conversion_overflow.")
      || quantityOverflowTestStart < 0 || quantityOverflowTestEnd < 0
      || suggestionStart < 0 || suggestionEnd < 0
      || !suggestionMethod.includes("milli_to_stock_quantity(")
      || rawMilliCasts
      || !quantityOverflowTest.includes(
        "shortfall_base_quantity = '9999999999.998'",
      )
      || !quantityOverflowTest.includes(
        "order_multiple_base_quantity = '999999999.999'",
      )
      || !quantityOverflowTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${prodCompPath} must reject replenishment suggestions beyond MARD quantity limits`,
    );
  }
}

const prodOrderAtpCheckerPath = "src/zcl_prod_order_atp_checker.clas.abap";
const prodOrderAtpCheckerTestPath =
  "src/zcl_prod_order_atp_checker.clas.testclasses.abap";
if (existsSync(join(projectRoot, prodOrderAtpCheckerPath))) {
  const checker = readFileSync(join(projectRoot, prodOrderAtpCheckerPath), "utf8")
    .toLowerCase();
  const checkerTests = existsSync(join(projectRoot, prodOrderAtpCheckerTestPath))
    ? readFileSync(join(projectRoot, prodOrderAtpCheckerTestPath), "utf8")
      .toLowerCase()
    : "";
  const mapStart = checker.indexOf("method map_summaries.");
  const mapEnd = checker.indexOf("endmethod.", mapStart);
  const mapMethod = checker.slice(mapStart, mapEnd).replace(/\s+/g, " ");
  const readinessOverflowStart = checkerTests.indexOf(
    "method rejects_readiness_overflow.",
  );
  const readinessOverflowEnd = checkerTests.indexOf(
    "endmethod.",
    readinessOverflowStart,
  );
  const readinessOverflowTest = checkerTests
    .slice(readinessOverflowStart, readinessOverflowEnd)
    .replace(/\s+/g, " ");
  const prodCompPath = "src/zcl_prod_comp_service.clas.abap";
  const prodCompTestPath = "src/zcl_prod_comp_service.clas.testclasses.abap";
  const prodComp = readFileSync(join(projectRoot, prodCompPath), "utf8")
    .toLowerCase();
  const prodCompTests = existsSync(join(projectRoot, prodCompTestPath))
    ? readFileSync(join(projectRoot, prodCompTestPath), "utf8")
      .toLowerCase()
    : "";
  const quantitySumStart = prodComp.indexOf("method sum_stock_quantities.");
  const quantitySumEnd = prodComp.indexOf("endmethod.", quantitySumStart);
  const quantitySumMethod = prodComp
    .slice(quantitySumStart, quantitySumEnd)
    .replace(/\s+/g, " ");
  const shortageStart = prodComp.indexOf("method summarize_component_shortages.");
  const shortageEnd = prodComp.indexOf("endmethod.", shortageStart);
  const atpSummaryStart = prodComp.indexOf("method summarize_order_atp.");
  const atpSummaryEnd = prodComp.indexOf("endmethod.", atpSummaryStart);
  const componentAtpStart = prodComp.indexOf("method preview_components_internal.");
  const componentAtpEnd = prodComp.indexOf("endmethod.", componentAtpStart);
  const monthlyShortageStart = prodComp.indexOf(
    "method suggest_comp_replenishment.",
  );
  const monthlyShortageEnd = prodComp.indexOf("endmethod.", monthlyShortageStart);
  if (mapStart < 0 || mapEnd < 0
      || !mapMethod.includes("type decfloat34")
      || !mapMethod.includes("catch cx_sy_conversion_overflow.")
      || !mapMethod.includes(
        "ls_readiness-requested_base_quantity = conv mard-labst(",
      )
      || !mapMethod.includes(
        "ls_readiness-confirmed_base_quantity = conv mard-labst(",
      )
      || !mapMethod.includes(
        "ls_readiness-unconfirmed_base_quantity = conv mard-labst(",
      )
      || readinessOverflowStart < 0 || readinessOverflowEnd < 0
      || !readinessOverflowTest.includes(
        "requested_base_quantity = lv_max_quantity",
      )
      || !readinessOverflowTest.includes(
        "confirmed_base_quantity = lv_max_quantity",
      )
      || !readinessOverflowTest.includes(
        "unconfirmed_base_quantity = lv_max_quantity",
      )
      || quantitySumStart < 0 || quantitySumEnd < 0
      || !quantitySumMethod.includes("conv decfloat34")
      || !quantitySumMethod.includes("catch cx_sy_conversion_overflow.")
      || !prodComp.includes("data lv_open_quantity type resb-bdmng.")
      || !prodComp.includes("lv_open_quantity = ls_item-required_quantity")
      || shortageStart < 0 || shortageEnd < 0
      || !prodComp.slice(shortageStart, shortageEnd)
        .includes("sum_stock_quantities(")
      || atpSummaryStart < 0 || atpSummaryEnd < 0
      || !prodComp.slice(atpSummaryStart, atpSummaryEnd)
        .includes("sum_stock_quantities(")
      || componentAtpStart < 0 || componentAtpEnd < 0
      || !prodComp.slice(componentAtpStart, componentAtpEnd)
        .includes("sum_stock_quantities(")
      || monthlyShortageStart < 0 || monthlyShortageEnd < 0
      || !prodComp.slice(monthlyShortageStart, monthlyShortageEnd)
        .includes("sum_stock_quantities(")
      || !prodCompTests.includes("method rejects_atp_summary_overflow.")
      || !prodCompTests.includes("method rejects_atp_date_overflow.")
      || !prodCompTests.includes("method rejects_month_qty_overflow.")
      || !checkerTests.includes("method rejects_readiness_overflow.")) {
    errors.push(
      "production-order ATP readiness must reject unrepresentable requested, confirmed, and unconfirmed totals",
    );
  }
}

const prodOrderServicePath = "src/zcl_prod_order_service.clas.abap";
const prodOrderServiceTestPath =
  "src/zcl_prod_order_service.clas.testclasses.abap";
if (existsSync(join(projectRoot, prodOrderServicePath))
    && existsSync(join(projectRoot, prodOrderServiceTestPath))) {
  const prodOrderService = readFileSync(
    join(projectRoot, prodOrderServicePath),
    "utf8",
  ).toLowerCase().replace(/\s+/g, " ");
  const prodOrderServiceTests = readFileSync(
    join(projectRoot, prodOrderServiceTestPath),
    "utf8",
  ).toLowerCase();
  const checkedReadinessSum =
    "conv decfloat34( ls_readiness-confirmed_base_quantity ) + "
    + "conv decfloat34( ls_readiness-unconfirmed_base_quantity ) <> "
    + "conv decfloat34( ls_readiness-requested_base_quantity )";
  for (const methodName of [
    "release_orders_after_atp",
    "release_orders_bulk_after_atp",
  ]) {
    const start = prodOrderService.indexOf(`method ${methodName}.`);
    const end = prodOrderService.indexOf("endmethod.", start);
    if (start < 0 || end < 0
        || !prodOrderService.slice(start, end).includes(checkedReadinessSum)) {
      errors.push(
        `${prodOrderServicePath} must compare ATP quantity sums in high precision`,
      );
      break;
    }
  }
  if (!prodOrderServiceTests.includes("method rejects_atp_sum_overflow.")) {
    errors.push(
      `${prodOrderServiceTestPath} must cover maximum ATP quantities`,
    );
  }
}

const ccReservationQuantityServicePath =
  "src/zcl_cc_reservation_service.clas.abap";
const ccReservationServiceTestPath =
  "src/zcl_cc_reservation_service.clas.testclasses.abap";
if (existsSync(join(projectRoot, ccReservationQuantityServicePath))
    && existsSync(join(projectRoot, ccReservationServiceTestPath))) {
  const ccReservationService = readFileSync(
    join(projectRoot, ccReservationQuantityServicePath),
    "utf8",
  ).toLowerCase().replace(/\s+/g, " ");
  const ccReservationServiceTests = readFileSync(
    join(projectRoot, ccReservationServiceTestPath),
    "utf8",
  ).toLowerCase();
  const readMethodStart = ccReservationService.indexOf(
    "method validate_reservation_read.",
  );
  const readMethodEnd = ccReservationService.indexOf(
    "endmethod.",
    readMethodStart,
  );
  const checkedReservationSum =
    "conv decfloat34( ls_reservation-open_quantity ) + "
    + "conv decfloat34( ls_reservation-withdrawn_quantity ) <> "
    + "conv decfloat34( ls_reservation-required_quantity )";
  if (readMethodStart < 0 || readMethodEnd < 0
      || !ccReservationService.slice(readMethodStart, readMethodEnd)
        .includes(checkedReservationSum)) {
    errors.push(
      `${ccReservationQuantityServicePath} must validate reservation sums in high precision`,
    );
  }
  if (!ccReservationServiceTests.includes("method rejects_cc_sum_overflow.")) {
    errors.push(
      `${ccReservationServiceTestPath} must cover maximum reservation quantities`,
    );
  }
}

const goodsMovementQuantityPath = "src/zcl_goods_movement_service.clas.abap";
const goodsMovementQuantityTestPath =
  "src/zcl_goods_movement_service.clas.testclasses.abap";
if (existsSync(join(projectRoot, goodsMovementQuantityPath))
    && existsSync(join(projectRoot, goodsMovementQuantityTestPath))) {
  const goodsMovementService = readFileSync(
    join(projectRoot, goodsMovementQuantityPath),
    "utf8",
  ).toLowerCase().replace(/\s+/g, " ");
  const goodsMovementTests = readFileSync(
    join(projectRoot, goodsMovementQuantityTestPath),
    "utf8",
  ).toLowerCase();
  const checkedDemandSum =
    "conv decfloat34( ls_demand-allocated_quantity ) + "
    + "conv decfloat34( ls_demand-shortfall_quantity ) <> "
    + "conv decfloat34( ls_demand-requested_quantity )";
  const hasUncheckedDemandSum =
    /\b(?:allocated_quantity|allocated_base_quantity|covered_base_quantity)\s+\+\s+(?:shortfall_quantity|shortfall_base_quantity)\s+<>\s+/;
  if (hasUncheckedDemandSum.test(goodsMovementService)) {
    errors.push(
      `${goodsMovementQuantityPath} has an unchecked allocation/shortfall sum`,
    );
  }
  for (const methodName of [
    "transfer_plant_splits",
    "transfer_two_step_splits",
  ]) {
    const start = goodsMovementService.indexOf(`method ${methodName}.`);
    const end = goodsMovementService.indexOf("endmethod.", start);
    if (start < 0 || end < 0
        || !goodsMovementService.slice(start, end).includes(checkedDemandSum)) {
      errors.push(
        `${goodsMovementQuantityPath} must compare transfer totals in high precision`,
      );
      break;
    }
  }
  if (!goodsMovementTests.includes("method rejects_transfer_sum_overflow.")
      || !goodsMovementTests.includes("9999999999.999")) {
    errors.push(
      `${goodsMovementQuantityTestPath} must cover maximum transfer demand`,
    );
  }
}

const projectCoveragePath = "src/zcl_project_stock_service.clas.abap";
const projectCoverageTestPath =
  "src/zcl_project_stock_service.clas.testclasses.abap";
if (existsSync(join(projectRoot, projectCoveragePath))
    && existsSync(join(projectRoot, projectCoverageTestPath))) {
  const projectCoverageService = readFileSync(
    join(projectRoot, projectCoveragePath),
    "utf8",
  ).toLowerCase();
  const projectCoverageTests = readFileSync(
    join(projectRoot, projectCoverageTestPath),
    "utf8",
  ).toLowerCase();
  const coverageStart = projectCoverageService.indexOf(
    "method read_reservation_coverage.",
  );
  const coverageEnd = projectCoverageService.indexOf("endmethod.", coverageStart);
  const coverageMethod = projectCoverageService
    .slice(coverageStart, coverageEnd)
    .replace(/\s+/g, " ");
  const coverageConversionStart = projectCoverageService.indexOf(
    "method convert_coverage_to_unit.",
  );
  const coverageConversionEnd = projectCoverageService.indexOf(
    "endmethod.",
    coverageConversionStart,
  );
  const coverageConversionMethod = projectCoverageService
    .slice(coverageConversionStart, coverageConversionEnd)
    .replace(/\s+/g, " ");
  const stockUnitStart = projectCoverageService.indexOf(
    "method read_available_stock_bulk_uom.",
  );
  const stockUnitEnd = projectCoverageService.indexOf("endmethod.", stockUnitStart);
  const stockUnitMethod = projectCoverageService
    .slice(stockUnitStart, stockUnitEnd)
    .replace(/\s+/g, " ");
  if (coverageStart < 0 || coverageEnd < 0
      || !coverageMethod.includes("project_stock_quantity type decfloat34")
      || !coverageMethod.includes("reserved_quantity type decfloat34")
      || !coverageMethod.includes("available_quantity type decfloat34")
      || !coverageMethod.includes("catch cx_sy_conversion_overflow.")
      || coverageConversionStart < 0 || coverageConversionEnd < 0
      || !coverageConversionMethod.includes("catch cx_sy_conversion_overflow.")
      || !coverageConversionMethod.includes(
        "is_coverage-project_stock_quantity <> 0 and rs_coverage-project_stock_quantity is initial",
      )
      || stockUnitStart < 0 || stockUnitEnd < 0
      || !stockUnitMethod.includes("catch cx_sy_conversion_overflow.")
      || !stockUnitMethod.includes(
        "ls_base_stock-available_quantity <> 0 and lv_converted_quantity is initial",
      )
      || !projectCoverageTests.includes("method rejects_cov_stock_overflow.")
      || !projectCoverageTests.includes("method rejects_coverage_uom_overflow.")
      || !projectCoverageTests.includes("method rejects_coverage_uom_rounding.")
      || !projectCoverageTests.includes("method rejects_stock_uom_overflow.")
      || !projectCoverageTests.includes("method rejects_stock_uom_rounding.")
      || !projectCoverageTests.includes("9999999999.999")
      || !projectCoverageTests.includes("iv_denominator      = 99999")
      || !projectCoverageTests.includes("iv_numerator        = 99999")) {
    errors.push(
      `${projectCoveragePath} must guard WBS coverage totals against SAP quantity limits`,
    );
  }
}

const stockRepositoryLimitsPath = "src/zcl_mard_stock_repository.clas.abap";
if (existsSync(join(projectRoot, stockRepositoryLimitsPath))) {
  const stockRepository = readFileSync(
    join(projectRoot, stockRepositoryLimitsPath),
    "utf8",
  );
  const stockRepositoryTestPath = join(
    projectRoot,
    "src/zcl_mard_stock_repository.clas.testclasses.abap",
  );
  const stockRepositoryTests = existsSync(stockRepositoryTestPath)
    ? readFileSync(stockRepositoryTestPath, "utf8").toLowerCase()
    : "";
  const conversionStart = stockRepository.indexOf(
    "METHOD convert_to_stock_quantity.",
  );
  const conversionEnd = stockRepository.indexOf("ENDMETHOD.", conversionStart);
  const conversionMethod = stockRepository
    .slice(conversionStart, conversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const limitsTestStart = stockRepositoryTests.indexOf(
    "method rejects_receipt_uom_limits.",
  );
  const limitsTestEnd = stockRepositoryTests.indexOf(
    "endmethod.",
    limitsTestStart,
  );
  const limitsTest = stockRepositoryTests
    .slice(limitsTestStart, limitsTestEnd)
    .replace(/\s+/g, " ");
  const projectedStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_projected_receipts_bulk.",
  );
  const projectedEnd = stockRepository.indexOf("ENDMETHOD.", projectedStart);
  const projectedMethod = stockRepository.slice(projectedStart, projectedEnd)
    .toLowerCase();
  const confirmationsStart = stockRepository.indexOf(
    "METHOD zif_stock_repository~get_po_confirmed_receipts_bulk.",
  );
  const confirmationsEnd = stockRepository.indexOf(
    "ENDMETHOD.",
    confirmationsStart,
  );
  const confirmationsMethod = stockRepository
    .slice(confirmationsStart, confirmationsEnd)
    .toLowerCase();
  if (conversionStart < 0 || conversionEnd < 0
      || !conversionMethod.includes("catch cx_sy_conversion_overflow.")
      || !conversionMethod.includes("if iv_quantity <> 0 and rv_quantity is initial.")
      || projectedStart < 0 || projectedEnd < 0
      || !projectedMethod.includes("convert_to_stock_quantity(")
      || /conv mard-labst\s*\(/i.test(projectedMethod)
      || confirmationsStart < 0 || confirmationsEnd < 0
      || !confirmationsMethod.includes("convert_to_stock_quantity(")
      || /conv mard-labst\s*\(/i.test(confirmationsMethod)
      || limitsTestStart < 0 || limitsTestEnd < 0
      || !limitsTest.includes("menge = '9999999999.999'")
      || !limitsTest.includes("umren = 99999")
      || !limitsTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${stockRepositoryLimitsPath} must reject overflowing and zero-rounded projected receipt quantities`,
    );
  }
}

const dateAvailabilityRepoPath =
  "src/zcl_mard_stock_repository.clas.abap";
if (existsSync(join(projectRoot, dateAvailabilityRepoPath))) {
  const dateAvailabilityRepo = readFileSync(
    join(projectRoot, dateAvailabilityRepoPath),
    "utf8",
  );
  const dateAvailabilityInterfacePath = "src/zif_stock_repository.intf.abap";
  const dateAvailabilityInterface = readFileSync(
    join(projectRoot, dateAvailabilityInterfacePath),
    "utf8",
  ).toLowerCase().replace(/\s+/g, " ");
  const dateAvailabilityTestsPath =
    "src/zcl_mard_stock_repository.clas.testclasses.abap";
  const dateAvailabilityTests = existsSync(
    join(projectRoot, dateAvailabilityTestsPath),
  )
    ? readFileSync(join(projectRoot, dateAvailabilityTestsPath), "utf8")
      .toLowerCase()
    : "";
  const dateMethodStart = dateAvailabilityRepo.indexOf(
    "METHOD zif_stock_repository~get_available_stock_date_bulk.",
  );
  const dateMethodEnd = dateAvailabilityRepo.indexOf(
    "ENDMETHOD.",
    dateMethodStart,
  );
  const dateMethod = dateAvailabilityRepo
    .slice(dateMethodStart, dateMethodEnd)
    .toLowerCase();
  const dateTestStart = dateAvailabilityTests.indexOf(
    "method rejects_date_stock_overflow.",
  );
  const dateTestEnd = dateAvailabilityTests.indexOf(
    "endmethod.",
    dateTestStart,
  );
  const dateTest = dateAvailabilityTests
    .slice(dateTestStart, dateTestEnd)
    .replace(/\s+/g, " ");
  const scalarMethodStart = dateAvailabilityInterface.indexOf(
    "methods get_available_stock_by_date",
  );
  const bulkMethodStart = dateAvailabilityInterface.indexOf(
    "methods get_available_stock_date_bulk",
    scalarMethodStart,
  );
  const projectedMethodStart = dateAvailabilityInterface.indexOf(
    "methods get_projected_receipts",
    bulkMethodStart,
  );
  const scalarMethod = dateAvailabilityInterface.slice(
    scalarMethodStart,
    bulkMethodStart,
  );
  const bulkMethod = dateAvailabilityInterface.slice(
    bulkMethodStart,
    projectedMethodStart,
  );
  if (dateMethodStart < 0 || dateMethodEnd < 0
      || !dateMethod.includes("convert_to_stock_quantity(")
      || /conv mard-labst\s*\(/i.test(dateMethod)
      || dateTestStart < 0 || dateTestEnd < 0
      || !dateTest.includes("labst = '9999999999.999'")
      || !dateTest.includes("catch zcx_invalid_stock_request.")
      || scalarMethodStart < 0 || bulkMethodStart < 0
      || !scalarMethod.includes("raising zcx_invalid_stock_request.")
      || !bulkMethod.includes("raising zcx_invalid_stock_request.")) {
    errors.push(
      `${dateAvailabilityRepoPath} must net dated availability in high precision and reject unrepresentable results`,
    );
  }
}

const stockStatusRangePath =
  "src/zcl_mard_stock_repository.clas.abap";
if (existsSync(join(projectRoot, stockStatusRangePath))) {
  const stockStatusRepository = readFileSync(
    join(projectRoot, stockStatusRangePath),
    "utf8",
  );
  const stockStatusInterface = readFileSync(
    join(projectRoot, "src/zif_stock_repository.intf.abap"),
    "utf8",
  ).toLowerCase().replace(/\s+/g, " ");
  const stockStatusTestPath =
    "src/zcl_mard_stock_repository.clas.testclasses.abap";
  const stockStatusTests = existsSync(join(projectRoot, stockStatusTestPath))
    ? readFileSync(join(projectRoot, stockStatusTestPath), "utf8")
      .toLowerCase()
    : "";
  const statusBulkStart = stockStatusRepository.indexOf(
    "METHOD zif_stock_repository~get_stock_status_bulk.",
  );
  const statusBulkEnd = stockStatusRepository.indexOf(
    "ENDMETHOD.",
    statusBulkStart,
  );
  const statusBulkMethod = stockStatusRepository
    .slice(statusBulkStart, statusBulkEnd)
    .toLowerCase();
  const statusScalarStart = stockStatusRepository.indexOf(
    "METHOD zif_stock_repository~get_stock_status.",
  );
  const statusScalarEnd = stockStatusRepository.indexOf(
    "ENDMETHOD.",
    statusScalarStart,
  );
  const statusScalarMethod = stockStatusRepository
    .slice(statusScalarStart, statusScalarEnd)
    .toLowerCase();
  const statusTestStart = stockStatusTests.indexOf(
    "method rejects_stock_status_overflow.",
  );
  const statusTestEnd = stockStatusTests.indexOf("endmethod.", statusTestStart);
  const statusTest = stockStatusTests
    .slice(statusTestStart, statusTestEnd)
    .replace(/\s+/g, " ");
  const statusScalarInterfaceStart = stockStatusInterface.indexOf(
    "methods get_stock_status ",
  );
  const statusBulkInterfaceStart = stockStatusInterface.indexOf(
    "methods get_stock_status_bulk",
    statusScalarInterfaceStart,
  );
  const statusLocationInterfaceStart = stockStatusInterface.indexOf(
    "methods get_stock_status_by_location",
    statusBulkInterfaceStart,
  );
  const statusScalarInterface = stockStatusInterface.slice(
    statusScalarInterfaceStart,
    statusBulkInterfaceStart,
  );
  const statusBulkInterface = stockStatusInterface.slice(
    statusBulkInterfaceStart,
    statusLocationInterfaceStart,
  );
  if (statusBulkStart < 0 || statusBulkEnd < 0
      || !statusBulkMethod.includes("convert_to_stock_quantity(")
      || !statusBulkMethod.includes("unrestricted_quantity       type decfloat34")
      || !statusBulkMethod.includes("reserved_quantity type decfloat34")
      || statusScalarStart < 0 || statusScalarEnd < 0
      || !statusScalarMethod.includes("get_stock_status_bulk(")
      || statusScalarMethod.includes("select sum(")
      || statusTestStart < 0 || statusTestEnd < 0
      || !statusTest.includes("labst = '9999999999.999'")
      || !statusTest.includes("bdmng = '9999999999.999'")
      || !statusTest.includes("catch zcx_invalid_stock_request.")
      || statusScalarInterfaceStart < 0 || statusBulkInterfaceStart < 0
      || !statusScalarInterface.includes("raising zcx_invalid_stock_request.")
      || !statusBulkInterface.includes("raising zcx_invalid_stock_request.")) {
    errors.push(
      `${stockStatusRangePath} must aggregate plant stock status in high precision and reject totals beyond quantity fields`,
    );
  }
}

const soStockAggregatePath = "src/zcl_so_stock_service.clas.abap";
if (existsSync(join(projectRoot, soStockAggregatePath))) {
  const soStockService = readFileSync(
    join(projectRoot, soStockAggregatePath),
    "utf8",
  ).toLowerCase();
  const soStockTestPath = "src/zcl_so_stock_service.clas.testclasses.abap";
  const soStockTests = existsSync(join(projectRoot, soStockTestPath))
    ? readFileSync(join(projectRoot, soStockTestPath), "utf8")
      .toLowerCase()
      .replace(/\s+/g, " ")
    : "";
  const soReadBulkStart = soStockService.indexOf("method read_stock_bulk.");
  const soReadBulkEnd = soStockService.indexOf("endmethod.", soReadBulkStart);
  const soReadBulk = soStockService.slice(soReadBulkStart, soReadBulkEnd);
  const soAggregateTestStart = soStockTests.indexOf(
    "method rejects_stock_total_overflow.",
  );
  const soAggregateTestEnd = soStockTests.indexOf(
    "endmethod.",
    soAggregateTestStart,
  );
  const soAggregateTest = soStockTests.slice(
    soAggregateTestStart,
    soAggregateTestEnd,
  );
  if (soReadBulkStart < 0 || soReadBulkEnd < 0
      || !soReadBulk.includes("lv_unrestricted_total type decfloat34")
      || !soReadBulk.includes("lv_reserved_total type decfloat34")
      || !soReadBulk.includes("lv_unrestricted_total += conv decfloat34(")
      || !soReadBulk.includes("lv_reserved_total += conv decfloat34(")
      || !soReadBulk.includes("catch cx_sy_conversion_overflow.")
      || soAggregateTestStart < 0 || soAggregateTestEnd < 0
      || !soAggregateTest.includes("9999999999.999")
      || !soAggregateTest.includes("lv_stock_overflow_rejected")
      || !soAggregateTest.includes("lv_res_overflow_rejected")
      || !soAggregateTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${soStockAggregatePath} must aggregate sales-order stock in high precision and reject unrepresentable totals`,
    );
  }
}

const scopedComponentPath = "src/zcl_stock_service.clas.abap";
if (existsSync(join(projectRoot, scopedComponentPath))) {
  const scopedComponentService = readFileSync(
    join(projectRoot, scopedComponentPath),
    "utf8",
  ).toLowerCase();
  const scopedComponentTestPath =
    "src/zcl_stock_service.clas.testclasses.abap";
  const scopedComponentTests = existsSync(
    join(projectRoot, scopedComponentTestPath),
  )
    ? readFileSync(join(projectRoot, scopedComponentTestPath), "utf8")
      .toLowerCase()
      .replace(/\s+/g, " ")
    : "";
  const scopedComponentStart = scopedComponentService.indexOf(
    "method allocate_component_stock.",
  );
  const scopedComponentEnd = scopedComponentService.indexOf(
    "endmethod.",
    scopedComponentStart,
  );
  const scopedComponentMethod = scopedComponentService.slice(
    scopedComponentStart,
    scopedComponentEnd,
  ).replace(/\s+/g, " ");
  const scopedComponentTestStart = scopedComponentTests.indexOf(
    "method nets_large_scoped_batches.",
  );
  const scopedComponentTestEnd = scopedComponentTests.indexOf(
    "endmethod.",
    scopedComponentTestStart,
  );
  const scopedComponentTest = scopedComponentTests.slice(
    scopedComponentTestStart,
    scopedComponentTestEnd,
  );
  const scopedBatchReceiptStart = scopedComponentService.indexOf(
    "method receive_component_batch.",
  );
  const scopedBatchReceiptEnd = scopedComponentService.indexOf(
    "endmethod.",
    scopedBatchReceiptStart,
  );
  const scopedBatchReceipt = scopedComponentService.slice(
    scopedBatchReceiptStart,
    scopedBatchReceiptEnd,
  ).replace(/\s+/g, " ");
  const scopedReceiptTestStart = scopedComponentTests.indexOf(
    "method rejects_scope_receipt_range.",
  );
  const scopedReceiptTestEnd = scopedComponentTests.indexOf(
    "endmethod.",
    scopedReceiptTestStart,
  );
  const scopedReceiptTest = scopedComponentTests.slice(
    scopedReceiptTestStart,
    scopedReceiptTestEnd,
  );
  const scopedLocationReceiptStart = scopedComponentService.indexOf(
    "method receive_component_location.",
  );
  const scopedLocationReceiptEnd = scopedComponentService.indexOf(
    "endmethod.",
    scopedLocationReceiptStart,
  );
  const scopedLocationReceipt = scopedComponentService.slice(
    scopedLocationReceiptStart,
    scopedLocationReceiptEnd,
  ).replace(/\s+/g, " ");
  if (scopedComponentStart < 0 || scopedComponentEnd < 0
      || !scopedComponentMethod.includes("lv_batch_total type decfloat34")
      || !scopedComponentMethod.includes("lv_candidate_quantity type decfloat34")
      || !scopedComponentMethod.includes("lv_group_available_quantity type decfloat34")
      || !scopedComponentMethod.includes("catch cx_sy_conversion_overflow.")
      || !scopedComponentMethod.includes("lv_available_result_quantity = conv mard-labst(")
      || !scopedComponentMethod.includes("lv_group_result_quantity = conv mard-labst(")
      || scopedComponentTestStart < 0 || scopedComponentTestEnd < 0
      || !scopedComponentTest.includes("9999999999.999")
      || !scopedComponentTest.includes("lo_cut->allocate_component_stock(")
      || !scopedComponentTest.includes("group_available_quantity")
      || scopedBatchReceiptStart < 0 || scopedBatchReceiptEnd < 0
      || !scopedBatchReceipt.includes("lv_aggregate_quantity type decfloat34")
      || !scopedBatchReceipt.includes("catch cx_sy_conversion_overflow.")
      || scopedLocationReceiptStart < 0 || scopedLocationReceiptEnd < 0
      || !scopedLocationReceipt.includes("lv_aggregate_quantity type decfloat34")
      || !scopedLocationReceipt.includes("catch cx_sy_conversion_overflow.")
      || scopedReceiptTestStart < 0 || scopedReceiptTestEnd < 0
      || !scopedReceiptTest.includes("9999999999.999")
      || !scopedReceiptTest.includes("it_projected_location_receipts")
      || !scopedReceiptTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${scopedComponentPath} must net scoped component balances in high precision and reject totals outside output fields`,
    );
  }
}

const salesAllocPath = "src/zcl_sales_order_alloc_service.clas.abap";
if (existsSync(join(projectRoot, salesAllocPath))) {
  const salesAlloc = readFileSync(join(projectRoot, salesAllocPath), "utf8");
  const salesAllocTestPath = join(
    projectRoot,
    "src/zcl_sales_order_alloc_service.clas.testclasses.abap",
  );
  const salesAllocTests = existsSync(salesAllocTestPath)
    ? readFileSync(salesAllocTestPath, "utf8").toLowerCase()
    : "";
  const conversionStart = salesAlloc.indexOf(
    "METHOD convert_base_to_sales_unit.",
  );
  const conversionEnd = salesAlloc.indexOf("ENDMETHOD.", conversionStart);
  const conversionMethod = salesAlloc
    .slice(conversionStart, conversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const limitTestStart = salesAllocTests.indexOf(
    "method rejects_sales_uom_limits.",
  );
  const limitTestEnd = salesAllocTests.indexOf("endmethod.", limitTestStart);
  const limitTest = salesAllocTests
    .slice(limitTestStart, limitTestEnd)
    .replace(/\s+/g, " ");
  if (conversionStart < 0 || conversionEnd < 0
      || !conversionMethod.includes("catch cx_sy_conversion_overflow.")
      || !conversionMethod.includes(
        "if iv_base_quantity <> 0 and rv_quantity is initial.",
      )
      || limitTestStart < 0 || limitTestEnd < 0
      || !limitTest.includes("quantity = '9999999.999'")
      || !limitTest.includes("sales_unit_denominator = 99999")
      || !limitTest.includes("sales_unit_numerator = 99999")
      || !limitTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${salesAllocPath} must reject overflowing and zero-rounded sales-unit results`,
    );
  }
  const fefoReserveStart = salesAlloc.indexOf(
    "METHOD reserve_so_stock_fefo.",
  );
  const fefoReserveEnd = salesAlloc.indexOf("ENDMETHOD.", fefoReserveStart);
  const fefoReserveMethod = salesAlloc
    .slice(fefoReserveStart, fefoReserveEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const checkedAllocationSum =
    "conv decfloat34( ls_allocation-covered_base_quantity ) + "
    + "conv decfloat34( ls_allocation-shortfall_base_quantity ) <> "
    + "conv decfloat34( ls_allocation-requested_base_quantity )";
  if (fefoReserveStart < 0 || fefoReserveEnd < 0
      || !fefoReserveMethod.includes(checkedAllocationSum)
      || !salesAllocTests.includes("method rejects_fefo_sum_overflow.")
      || !salesAllocTests.includes("9999999999.999")) {
    errors.push(
      `${salesAllocPath} must reject overflowing FEFO allocation totals before reservation`,
    );
  }
  const atpMethod = (methodName) => {
    const methodStart = salesAlloc.indexOf(`METHOD ${methodName}.`);
    const methodEnd = salesAlloc.indexOf("ENDMETHOD.", methodStart);
    return {
      start: methodStart,
      end: methodEnd,
      source: salesAlloc
        .slice(methodStart, methodEnd)
        .replace(/\s+/g, " ")
        .toLowerCase(),
    };
  };
  const orderAtpMethod = atpMethod("build_order_atp_checks");
  const multiOrderAtpMethod = atpMethod("preview_orders_by_date");
  const quantitySumMethod = atpMethod("sum_stock_quantities");
  if (orderAtpMethod.start < 0 || orderAtpMethod.end < 0
      || (orderAtpMethod.source.match(/sum_stock_quantities\(/g) || []).length < 2
      || multiOrderAtpMethod.start < 0 || multiOrderAtpMethod.end < 0
      || (multiOrderAtpMethod.source.match(/sum_stock_quantities\(/g) || []).length < 2
      || quantitySumMethod.start < 0 || quantitySumMethod.end < 0
      || !quantitySumMethod.source.includes("data lv_total type decfloat34.")
      || !quantitySumMethod.source.includes("catch cx_sy_conversion_overflow.")
      || !salesAllocTests.includes("method rejects_order_atp_overflow.")
      || !salesAllocTests.includes("method rejects_multi_atp_overflow.")
      || !salesAllocTests.includes("9999999999.999")) {
    errors.push(
      `${salesAllocPath} must reject overflowing daily and cumulative order ATP quantities`,
    );
  }
}

const replenishmentReqPath = "src/zcl_replenishment_req_service.clas.abap";
if (existsSync(join(projectRoot, replenishmentReqPath))) {
  const replenishmentReq = readFileSync(
    join(projectRoot, replenishmentReqPath),
    "utf8",
  );
  const replenishmentReqTestPath = join(
    projectRoot,
    "src/zcl_replenishment_req_service.clas.testclasses.abap",
  );
  const replenishmentReqTests = existsSync(replenishmentReqTestPath)
    ? readFileSync(replenishmentReqTestPath, "utf8").toLowerCase()
    : "";
  const conversionStart = replenishmentReq.indexOf(
    "METHOD convert_to_purchasing_unit.",
  );
  const conversionEnd = replenishmentReq.indexOf("ENDMETHOD.", conversionStart);
  const conversionMethod = replenishmentReq
    .slice(conversionStart, conversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const limitsTestStart = replenishmentReqTests.indexOf(
    "method rejects_purch_uom_limits.",
  );
  const limitsTestEnd = replenishmentReqTests.indexOf(
    "endmethod.",
    limitsTestStart,
  );
  const limitsTest = replenishmentReqTests
    .slice(limitsTestStart, limitsTestEnd)
    .replace(/\s+/g, " ");
  if (conversionStart < 0 || conversionEnd < 0
      || !conversionMethod.includes("catch cx_sy_conversion_overflow.")
      || !conversionMethod.includes(
        "if iv_base_quantity <> 0 and rv_quantity is initial.",
      )
      || limitsTestStart < 0 || limitsTestEnd < 0
      || !limitsTest.includes("suggested_base_quantity = '9999999.999'")
      || !limitsTest.includes("order_to_base_den = 99999")
      || !limitsTest.includes("order_to_base_num = 99999")
      || !limitsTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${replenishmentReqPath} must reject overflowing and zero-rounded purchasing-unit quantities`,
    );
  }
}

const replenishmentRequestPath =
  "src/zcl_replenishment_req_service.clas.abap";
if (existsSync(join(projectRoot, replenishmentRequestPath))) {
  const replenishmentRequest = readFileSync(
    join(projectRoot, replenishmentRequestPath),
    "utf8",
  );
  const replenishmentRequestTestPath = join(
    projectRoot,
    "src/zcl_replenishment_req_service.clas.testclasses.abap",
  );
  const replenishmentRequestTests = existsSync(replenishmentRequestTestPath)
    ? readFileSync(replenishmentRequestTestPath, "utf8").toLowerCase()
    : "";
  const preparationStart = replenishmentRequest.indexOf(
    "METHOD prepare_from_quota_splits.",
  );
  const preparationEnd = replenishmentRequest.indexOf(
    "ENDMETHOD.",
    preparationStart,
  );
  const preparationMethod = replenishmentRequest
    .slice(preparationStart, preparationEnd)
    .toLowerCase();
  const overflowTestStart = replenishmentRequestTests.indexOf(
    "method rejects_quota_split_overflow.",
  );
  const overflowTestEnd = replenishmentRequestTests.indexOf(
    "endmethod.",
    overflowTestStart,
  );
  const overflowTest = replenishmentRequestTests
    .slice(overflowTestStart, overflowTestEnd)
    .replace(/\s+/g, " ");
  if (preparationStart < 0 || preparationEnd < 0
      || !preparationMethod.includes("catch cx_sy_conversion_overflow.")
      || overflowTestStart < 0 || overflowTestEnd < 0
      || !overflowTest.includes(
        "proposal_quantity = '99999999999.000'",
      )
      || !overflowTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${replenishmentRequestPath} must reject oversized quota proposal quantities before BAPI calls`,
    );
  }
}

const stockTransferPath = "src/zcl_stock_transfer_service.clas.abap";
if (existsSync(join(projectRoot, stockTransferPath))) {
  const stockTransfer = readFileSync(
    join(projectRoot, stockTransferPath),
    "utf8",
  );
  const stockTransferTestPath = join(
    projectRoot,
    "src/zcl_stock_transfer_service.clas.testclasses.abap",
  );
  const stockTransferTests = existsSync(stockTransferTestPath)
    ? readFileSync(stockTransferTestPath, "utf8").toLowerCase()
    : "";
  const conversionStart = stockTransfer.indexOf(
    "METHOD convert_transfer_quantity.",
  );
  const conversionEnd = stockTransfer.indexOf("ENDMETHOD.", conversionStart);
  const conversionMethod = stockTransfer
    .slice(conversionStart, conversionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const limitsTestStart = stockTransferTests.indexOf(
    "method rejects_transfer_uom_limits.",
  );
  const limitsTestEnd = stockTransferTests.indexOf(
    "endmethod.",
    limitsTestStart,
  );
  const limitsTest = stockTransferTests
    .slice(limitsTestStart, limitsTestEnd)
    .replace(/\s+/g, " ");
  if (conversionStart < 0 || conversionEnd < 0
      || !conversionMethod.includes("catch cx_sy_conversion_overflow.")
      || !conversionMethod.includes(
        "if iv_base_quantity <> 0 and rv_quantity is initial.",
      )
      || limitsTestStart < 0 || limitsTestEnd < 0
      || !limitsTest.includes("plant_transfer_quantity = '9999999.999'")
      || !limitsTest.includes("iv_unit = 'big'")
      || !limitsTest.includes("iv_unit = 'sml'")
      || !limitsTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${stockTransferPath} must reject overflowing and zero-rounded transfer-unit quantities`,
    );
  }
}

const poServicePath = "src/zcl_purchase_order_service.clas.abap";
if (existsSync(join(projectRoot, poServicePath))) {
  const poService = readFileSync(join(projectRoot, poServicePath), "utf8");
  const poServiceTestPath = join(
    projectRoot,
    "src/zcl_purchase_order_service.clas.testclasses.abap",
  );
  const poServiceTests = existsSync(poServiceTestPath)
    ? readFileSync(poServiceTestPath, "utf8").toLowerCase()
    : "";
  const suggestionStart = poService.indexOf(
    "METHOD build_suggestion_order_request.",
  );
  const suggestionEnd = poService.indexOf("ENDMETHOD.", suggestionStart);
  const suggestionMethod = poService
    .slice(suggestionStart, suggestionEnd)
    .replace(/\s+/g, " ")
    .toLowerCase();
  const overflowTestStart = poServiceTests.indexOf(
    "method rejects_po_unit_overflow.",
  );
  const overflowTestEnd = poServiceTests.indexOf(
    "endmethod.",
    overflowTestStart,
  );
  const overflowTest = poServiceTests
    .slice(overflowTestStart, overflowTestEnd)
    .replace(/\s+/g, " ");
  if (suggestionStart < 0 || suggestionEnd < 0
      || !suggestionMethod.includes("catch cx_sy_conversion_overflow.")
      || overflowTestStart < 0 || overflowTestEnd < 0
      || !overflowTest.includes("suggested_base_quantity = '9999999.999'")
      || !overflowTest.includes("order_to_base_den = 99999")
      || !overflowTest.includes("catch zcx_invalid_stock_request.")) {
    errors.push(
      `${poServicePath} must reject overflowing purchase-order unit quantities before BAPI calls`,
    );
  }
}

const excludedDirectories = new Set([
  ".git",
  "deps",
  "node_modules",
  "output",
]);
const customObjectFile = /^z[a-z0-9_]+(?:\.[a-z0-9_]+)*\.(?:abap|xml)$/i;
const customAbapDeclaration =
  /\b(?:CLASS|INTERFACE|REPORT|PROGRAM|FUNCTION-POOL|TYPE-POOL)\s+Z[A-Z0-9_]+\b/i;
const stubDirectory = join(projectRoot, "stubs", "src");
const sapTables = new Set(
  readdirSync(stubDirectory)
    .filter((entry) => entry.toLowerCase().endsWith(".tabl.xml"))
    .map((entry) => entry.slice(0, -".tabl.xml".length).toLowerCase()),
);
const typedTableFields = new Map();

function walk(directory) {
  for (const entry of readdirSync(directory)) {
    if (excludedDirectories.has(entry)) {
      continue;
    }

    const absolutePath = join(directory, entry);
    const relativePath = relative(projectRoot, absolutePath).split(sep).join("/");
    const stat = statSync(absolutePath);
    if (stat.isDirectory()) {
      walk(absolutePath);
      continue;
    }

    const basename = entry.toLowerCase();
    const isInSource = relativePath.startsWith("src/");
    const sourceText = basename.endsWith(".abap")
      ? readFileSync(absolutePath, "utf8")
      : undefined;
    if (customObjectFile.test(basename) && !isInSource) {
      errors.push(`Custom ABAP object must be under src/: ${relativePath}`);
    }

    if (!isInSource && sourceText
        && customAbapDeclaration.test(sourceText)) {
      errors.push(`Z-named ABAP declaration must be under src/: ${relativePath}`);
    }

    if (isInSource && sourceText) {
      for (const [, rawTable, rawField] of sourceText.matchAll(
        /\b([a-z][a-z0-9_]*)-([a-z][a-z0-9_]*)\b/gi,
      )) {
        const table = rawTable.toLowerCase();
        if (!sapTables.has(table)) {
          continue;
        }
        const fields = typedTableFields.get(table) ?? new Set();
        fields.add(rawField.toUpperCase());
        typedTableFields.set(table, fields);
      }
    }
  }
}

walk(projectRoot);

for (const [table, fields] of typedTableFields) {
  const path = `stubs/src/${table}.tabl.xml`;
  const stub = readFileSync(join(projectRoot, path), "utf8");
  const definedFields = new Set(
    [...stub.matchAll(/<FIELDNAME>([^<]+)<\/FIELDNAME>/g)]
      .map(([, field]) => field.toUpperCase()),
  );
  for (const field of fields) {
    if (!definedFields.has(field)) {
      errors.push(
        `${path} must define field ${field} referenced by custom ABAP source`,
      );
    }
  }
}

const abapGitConfigPath = join(projectRoot, ".abapgit.xml");
if (!existsSync(abapGitConfigPath)) {
  errors.push(".abapgit.xml must configure the SAP import folder");
} else {
  const config = readFileSync(abapGitConfigPath, "utf8");
  if (!config.includes("<STARTING_FOLDER>/src/</STARTING_FOLDER>")) {
    errors.push(".abapgit.xml must limit SAP imports to /src/");
  }
  if (!config.includes("<FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>")) {
    errors.push(".abapgit.xml must use portable PREFIX package mapping");
  }
}

const packageMetadataPath = join(projectRoot, "src", "package.devc.xml");
if (!existsSync(packageMetadataPath)) {
  errors.push("src/package.devc.xml must define the installable SAP package");
} else if (!readFileSync(packageMetadataPath, "utf8")
  .includes('serializer="LCL_OBJECT_DEVC"')) {
  errors.push("src/package.devc.xml must use the abapGit DEVC serializer");
}

const objectMetadataFiles = new Set();
for (const filename of readdirSync(join(projectRoot, "src"))) {
  const isClass = filename.endsWith(".clas.abap");
  const isInterface = filename.endsWith(".intf.abap");
  if (!isClass && !isInterface) continue;

  const objectName = filename.replace(/\.(?:clas|intf)\.abap$/i, "").toUpperCase();
  const type = isClass ? "clas" : "intf";
  const metadataPath = join(
    projectRoot,
    "src",
    `${objectName.toLowerCase()}.${type}.xml`,
  );
  if (!existsSync(metadataPath)) {
    errors.push(`Missing abapGit metadata for ${objectName}`);
    continue;
  }

  const metadata = readFileSync(metadataPath, "utf8");
  objectMetadataFiles.add(`${objectName.toLowerCase()}.${type}.xml`);
  const serializer = isClass ? "CLAS" : "INTF";
  if (!metadata.includes(`serializer="LCL_OBJECT_${serializer}"`)
      || !metadata.includes(`<CLSNAME>${objectName}</CLSNAME>`)) {
    errors.push(`Invalid abapGit metadata for ${objectName}`);
  }
  const source = readFileSync(join(projectRoot, "src", filename), "utf8");
  const declaration = isClass
    ? source.match(/\bCLASS\s+([A-Z0-9_]+)\s+DEFINITION\b/i)
    : source.match(/\bINTERFACE\s+([A-Z0-9_]+)\b/i);
  if (!declaration || declaration[1].toUpperCase() !== objectName) {
    errors.push(`${filename} must declare ${objectName}`);
  }
  const metadataBytes = readFileSync(metadataPath);
  if (!metadataBytes.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf]))) {
    errors.push(`${metadataPath.replace(`${projectRoot}/`, "")} must use a UTF-8 BOM`);
  }
  if (metadata.includes("\r")) {
    errors.push(`${metadataPath.replace(`${projectRoot}/`, "")} must use LF line endings`);
  }
  if (isClass) {
    const testclassesPath = join(
      projectRoot,
      "src",
      `${objectName.toLowerCase()}.clas.testclasses.abap`,
    );
    if (existsSync(testclassesPath)
        !== metadata.includes("<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>")) {
      errors.push(`Unit-test metadata is inconsistent for ${objectName}`);
    }
  }
}

for (const filename of readdirSync(join(projectRoot, "src"))) {
  if (!filename.endsWith(".clas.xml") && !filename.endsWith(".intf.xml")) {
    continue;
  }
  if (!objectMetadataFiles.has(filename.toLowerCase())) {
    errors.push(`AbapGit metadata has no matching source object: src/${filename}`);
  }
}

const stockFactoryTestPath =
  "src/zcl_stock_allocation_factory.clas.testclasses.abap";
const stockFactoryTests = existsSync(join(projectRoot, stockFactoryTestPath))
  ? readFileSync(join(projectRoot, stockFactoryTestPath), "utf8").toLowerCase()
  : "";
const stockFactoryIntegrationStart = stockFactoryTests.indexOf(
  "method allocates_using_sap_repository.",
);
const stockFactoryIntegrationEnd = stockFactoryTests.indexOf(
  "endmethod.",
  stockFactoryIntegrationStart,
);
const stockFactoryIntegration = stockFactoryTests
  .slice(stockFactoryIntegrationStart, stockFactoryIntegrationEnd)
  .replace(/\s+/g, " ");
const stockFactoryFefoStart = stockFactoryTests.indexOf(
  "method allocates_fefo_from_db.",
);
const stockFactoryFefoEnd = stockFactoryTests.indexOf(
  "endmethod.",
  stockFactoryFefoStart,
);
const stockFactoryFefo = stockFactoryTests
  .slice(stockFactoryFefoStart, stockFactoryFefoEnd)
  .replace(/\s+/g, " ");
if (stockFactoryIntegrationStart < 0 || stockFactoryIntegrationEnd < 0
    || !stockFactoryTests.includes("append 'mard' to lt_tables.")
    || !stockFactoryTests.includes("append 'resb' to lt_tables.")
    || !stockFactoryIntegration.includes("create_stock_service(")
    || !stockFactoryIntegration.includes("allocate_demands(")
    || !stockFactoryIntegration.includes("labst = '20.000'")
    || !stockFactoryIntegration.includes("bdmng = '8.000'")
    || !stockFactoryIntegration.includes("enmng = '3.000'")
    || !stockFactoryIntegration.includes("'15.000'")
    || !stockFactoryIntegration.includes("'10.000'")
    || !stockFactoryIntegration.includes("'5.000'")
    || !stockFactoryIntegration.includes("'2.000'")) {
  errors.push(
    "the production stock factory must have SQLite-backed coverage for repository netting and shared allocations",
  );
}
if (stockFactoryFefoStart < 0 || stockFactoryFefoEnd < 0
    || !stockFactoryTests.includes("append 'mchb' to lt_tables.")
    || !stockFactoryTests.includes("append 'mcha' to lt_tables.")
    || !stockFactoryTests.includes("append 'mch1' to lt_tables.")
    || !stockFactoryFefo.includes("create_stock_service(")
    || !stockFactoryFefo.includes("allocate_by_expiry(")
    || !stockFactoryFefo.includes("iv_as_of_date = '20261017'")
    || !stockFactoryFefo.includes("charg = 'b-early' clabs = '8.000'")
    || !stockFactoryFefo.includes("charg = 'b-late' clabs = '10.000'")
    || !stockFactoryFefo.includes("bdmng = '5.000' enmng = '1.000'")
    || !stockFactoryFefo.includes("'b-early'")
    || !stockFactoryFefo.includes("'b-late'")
    || !stockFactoryFefo.includes("'4.000'")
    || !stockFactoryFefo.includes("'6.000'")) {
  errors.push(
    "the production stock factory must exercise FEFO batch selection against SQLite MCHB, MCHA, MCH1, and RESB rows",
  );
}

if (errors.length > 0) {
  console.error(`PLAN validation failed with ${errors.length} issue(s):`);
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exitCode = 1;
} else {
  console.log("PLAN validation passed: rules, dependencies, stubs, and src layout are configured.");
}
