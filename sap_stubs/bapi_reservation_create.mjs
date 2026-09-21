const isValidSapDate = (value) => {
  if (!/^\d{8}$/.test(value) || value === "00000000") {
    return false;
  }
  const year = Number(value.slice(0, 4));
  const month = Number(value.slice(4, 6));
  const day = Number(value.slice(6, 8));
  if (year < 1 || month < 1 || month > 12 || day < 1) {
    return false;
  }
  const leapYear = year % 4 === 0
    && (year % 100 !== 0 || year % 400 === 0);
  const monthDays = [31, leapYear ? 29 : 28, 31, 30, 31, 30,
    31, 31, 30, 31, 30, 31];
  return day <= monthDays[month - 1];
};

const isSapNumericKey = (value, length) => {
  const normalized = value?.trim();
  return normalized?.length === length
    && /^\d+$/.test(normalized)
    && normalized !== "0".repeat(length);
};

export function installBapiStockStub(abap) {
  let commitFails = false;
  let rollbackFails = false;
  let commitThrows = false;
  let commitReturnError = false;
  let commitReturnInvalid = false;
  let rollbackThrows = false;
  let rollbackReturnError = false;
  let rollbackReturnInvalid = false;
  let reservationCounter = 0;
  let movementCounter = 0;
  const pendingReservationItems = [];
  const pendingReservationDeletions = new Set();
  const pendingGoodsMovements = [];
  const pendingSalesOrderChanges = [];
  let pendingDatabaseTransaction = false;
  const quoteSql = (value) => `'${String(value).replaceAll("'", "''")}'`;
  const toScaledQuantity = (value) => {
    const match = /^(\d+)(?:\.(\d{1,3}))?$/.exec(String(value ?? "").trim());
    if (!match) {
      return undefined;
    }
    return BigInt(match[1]) * 1000n
      + BigInt((match[2] ?? "").padEnd(3, "0"));
  };
  const fromScaledQuantity = (value) => {
    const whole = value / 1000n;
    const fraction = String(value % 1000n).padStart(3, "0");
    return `${whole}.${fraction}`;
  };
  const positiveInteger = (value) => {
    const normalized = String(value ?? "").trim();
    if (!/^\d+$/.test(normalized)) {
      return undefined;
    }
    const result = BigInt(normalized);
    return result > 0n ? result : undefined;
  };
  const getMaterialUomData = (material, client) => {
    const database = abap.context.databaseConnections.DEFAULT;
    const clientSql = quoteSql(client);
    const materialSql = quoteSql(material);
    const materialRows = database?.sqlite?.exec(
      `SELECT meins FROM mara WHERE mandt = ${clientSql} `
      + `AND matnr = ${materialSql}`,
    );
    const materialRow = materialRows?.[0]?.values?.[0];
    if (!materialRow) {
      return undefined;
    }
    const baseUnit = materialRow[0]?.toString()?.trim()?.toUpperCase() ?? "";
    const alternativeRows = database?.sqlite?.exec(
      `SELECT meinh, umrez, umren FROM marm WHERE mandt = ${clientSql} `
      + `AND matnr = ${materialSql}`,
    );
    const alternatives = new Map();
    for (const row of alternativeRows?.[0]?.values ?? []) {
      alternatives.set(String(row[0]).trim().toUpperCase(), {
        numerator: positiveInteger(row[1]),
        denominator: positiveInteger(row[2]),
      });
    }
    return {baseUnit, alternatives};
  };
  const getUnitRatio = (unit, unitData) => {
    if (unit === unitData.baseUnit) {
      return {numerator: 1n, denominator: 1n};
    }
    const ratio = unitData.alternatives.get(unit);
    if (!ratio?.numerator || !ratio?.denominator) {
      return undefined;
    }
    return ratio;
  };
  const convertScaledQuantity = (quantity, fromRatio, toRatio) => {
    const numerator = quantity * fromRatio.numerator * toRatio.denominator;
    const denominator = fromRatio.denominator * toRatio.numerator;
    if (denominator <= 0n) {
      return undefined;
    }
    return (numerator + denominator / 2n) / denominator;
  };
  const getBaseReservationQuantity = (item, material, client) => {
    const entryQuantity = Number(item?.entry_qnt?.get());
    const entryUnit = item?.entry_uom?.get()?.trim()?.toUpperCase();
    const unitData = getMaterialUomData(material, client);
    if (!unitData) {
      return {quantity: entryQuantity, unit: entryUnit};
    }
    if (!entryUnit) {
      return undefined;
    }
    const baseUnit = unitData.baseUnit;
    if (baseUnit === entryUnit) {
      return {quantity: entryQuantity, unit: baseUnit};
    }
    const ratio = getUnitRatio(entryUnit, unitData);
    const scaledQuantity = toScaledQuantity(item?.entry_qnt?.get());
    if (ratio && scaledQuantity !== undefined) {
      return {
        quantity: fromScaledQuantity(convertScaledQuantity(
          scaledQuantity,
          ratio,
          {numerator: 1n, denominator: 1n},
        )),
        unit: baseUnit,
      };
    }
    return undefined;
  };
  const persistReservationChanges = async () => {
    const statements = [];
    const stockUpdateStatements = new Set();
    const salesOrderUpdateStatements = new Set();
    const reservationDeleteStatements = new Set();
    for (const item of pendingReservationItems) {
      statements.push(
        `INSERT INTO resb `
        + `(mandt, rsnum, rspos, werks, bwart, matnr, lgort, charg, sobkz, `
        + `bdmng, meins, enmng, kzear, xloek) VALUES (`
        + `${quoteSql(item.client)}, ${quoteSql(item.reservation)}, `
        + `${quoteSql(item.position)}, ${quoteSql(item.plant)}, `
        + `${quoteSql(item.movementType)}, ${quoteSql(item.material)}, `
        + `${quoteSql(item.storageLocation)}, ${quoteSql(item.batch)}, `
        + `${quoteSql("")}, ${quoteSql(item.quantity)}, `
        + `${quoteSql(item.unit)}, 0, ${quoteSql("")}, ${quoteSql("")})`,
      );
    }
    for (const movement of pendingGoodsMovements) {
      const quantity = quoteSql(fromScaledQuantity(movement.quantity));
      const stockScope = `WHERE mandt = ${quoteSql(movement.client)} `
        + `AND matnr = ${quoteSql(movement.material)} `
        + `AND werks = ${quoteSql(movement.plant)} `
        + `AND lgort = ${quoteSql(movement.storageLocation)} `;
      if (movement.batch) {
        const batchUpdate =
          `UPDATE mchb SET clabs = clabs - ${quantity} `
          + `${stockScope}AND charg = ${quoteSql(movement.batch)} `
          + `AND clabs >= ${quantity}`;
        statements.push(batchUpdate);
        stockUpdateStatements.add(batchUpdate);
      }
      const aggregateUpdate =
        `UPDATE mard SET labst = labst - ${quantity} `
        + `${stockScope}AND labst >= ${quantity}`;
      statements.push(aggregateUpdate);
      stockUpdateStatements.add(aggregateUpdate);
    }
    for (const change of pendingSalesOrderChanges) {
      const scheduleUpdate =
        `UPDATE vbep SET wmeng = ${quoteSql(fromScaledQuantity(change.quantity))} `
        + `WHERE mandt = ${quoteSql(change.client)} `
        + `AND vbeln = ${quoteSql(change.salesDocument)} `
        + `AND posnr = ${quoteSql(change.item)} `
        + `AND etenr = ${quoteSql(change.scheduleLine)}`;
      statements.push(scheduleUpdate);
      salesOrderUpdateStatements.add(scheduleUpdate);
    }
    for (const reservation of pendingReservationDeletions) {
      const deletion =
        `DELETE FROM resb WHERE mandt = ${quoteSql(reservation.client)} `
        + `AND rsnum = ${quoteSql(reservation.reservation)}`;
      statements.push(deletion);
      reservationDeleteStatements.add(deletion);
    }
    if (statements.length > 0) {
      const database = abap.context.databaseConnections.DEFAULT;
      try {
        await database.beginTransaction();
        pendingDatabaseTransaction = true;
        for (const statement of statements) {
          await database.execute(statement);
          if (stockUpdateStatements.has(statement)
              && database.sqlite.getRowsModified() !== 1) {
            throw {classic: "OTHERS"};
          }
          if (salesOrderUpdateStatements.has(statement)
              && database.sqlite.getRowsModified() !== 1) {
            throw {classic: "OTHERS"};
          }
          if (reservationDeleteStatements.has(statement)
              && database.sqlite.getRowsModified() < 1) {
            throw {classic: "OTHERS"};
          }
        }
        await database.commit();
        pendingDatabaseTransaction = false;
      } catch {
        if (pendingDatabaseTransaction && database.inTransaction) {
          try {
            await database.rollback();
            pendingDatabaseTransaction = false;
          } catch {
            // BAPI_TRANSACTION_ROLLBACK retries an unfinished database rollback.
          }
        }
        throw {classic: "OTHERS"};
      }
    }
    pendingReservationItems.length = 0;
    pendingReservationDeletions.clear();
    pendingGoodsMovements.length = 0;
    pendingSalesOrderChanges.length = 0;
  };
  const allocationLocks = new Map();
  const releaseUpdateOwnerLocks = () => {
    for (const [lockKey, lockScope] of allocationLocks) {
      if (lockScope === "2") {
        allocationLocks.delete(lockKey);
      }
    }
  };
  const protectedLockFunctions = new Set();
  // ENQU transpilation imports no-op lock modules after this test setup.
  abap.FunctionModules = new Proxy(abap.FunctionModules, {
    set(target, property, value) {
      if (protectedLockFunctions.has(property)) {
        return true;
      }
      target[property] = value;
      return true;
    },
  });
  abap.FunctionModules["ENQUEUE_EZSTOCKALLOC"] = async (input) => {
    const lockScope = input.exporting._scope.get()?.trim();
    const client = input.exporting.mandt.get()?.trim();
    const material = input.exporting.matnr.get()?.trim();
    const plant = input.exporting.werks.get()?.trim();
    const storageLocation = input.exporting.lgort.get()?.trim();
    const lockKey = `${client}|${material}|${plant}|${storageLocation}`;
    if ((lockScope !== "1" && lockScope !== "2")
      || !client || !material || !plant || !storageLocation) {
      throw {classic: "OTHERS"};
    }
    if (allocationLocks.has(lockKey)) {
      throw {classic: "FOREIGN_LOCK"};
    }
    if (material === "MATERIAL-LOCK-ERROR") {
      throw {classic: "OTHERS"};
    }
    allocationLocks.set(lockKey, lockScope);
    abap.builtin.sy.get().subrc.set(0);
  };
  protectedLockFunctions.add("ENQUEUE_EZSTOCKALLOC");
  abap.FunctionModules["DEQUEUE_EZSTOCKALLOC"] = async (input) => {
    const lockScope = input.exporting._scope.get()?.trim();
    const client = input.exporting.mandt.get()?.trim();
    const material = input.exporting.matnr.get()?.trim();
    const plant = input.exporting.werks.get()?.trim();
    const storageLocation = input.exporting.lgort.get()?.trim();
    const lockKey = `${client}|${material}|${plant}|${storageLocation}`;
    if ((lockScope !== "1" && lockScope !== "2")
      || !client || !material || !plant || !storageLocation) {
      throw {classic: "OTHERS"};
    }
    if (material === "MATERIAL-UNLOCK-ERROR") {
      allocationLocks.delete(lockKey);
      throw {classic: "OTHERS"};
    }
    allocationLocks.delete(lockKey);
    abap.builtin.sy.get().subrc.set(0);
  };
  protectedLockFunctions.add("DEQUEUE_EZSTOCKALLOC");
  abap.FunctionModules["MD_CONVERT_MATERIAL_UNIT"] = async (input) => {
    const material = input.exporting.i_matnr.get()?.trim();
    const unitIn = input.exporting.i_in_me.get()?.trim();
    const unitOut = input.exporting.i_out_me.get()?.trim();
    const quantity = Number(input.exporting.i_menge.get());
    const payloadIncomplete = !material
      || !unitIn
      || !unitOut
      || !Number.isFinite(quantity)
      || quantity < 0;
    if (payloadIncomplete) {
      throw {classic: "OTHERS"};
    }
    if (material === "MATERIAL-ZERO-CONVERSION") {
      input.importing.e_menge.set("0");
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-NEGATIVE-CONVERSION") {
      input.importing.e_menge.set("-1");
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-POSITIVE-ZERO-CONVERSION") {
      input.importing.e_menge.set("1");
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (unitIn === unitOut) {
      input.importing.e_menge.set(String(quantity));
      abap.builtin.sy.get().subrc.set(0);
      return;
    }

    const client = abap.builtin.sy.get().mandt.get()?.trim();
    const unitData = getMaterialUomData(material, client);
    const fromRatio = unitData && getUnitRatio(unitIn, unitData);
    const toRatio = unitData && getUnitRatio(unitOut, unitData);
    const scaledQuantity = toScaledQuantity(input.exporting.i_menge.get());
    const convertedQuantity = fromRatio && toRatio
      && scaledQuantity !== undefined
      ? convertScaledQuantity(scaledQuantity, fromRatio, toRatio)
      : undefined;
    if (convertedQuantity !== undefined) {
      if (convertedQuantity > 9999999999999n) {
        throw {classic: "OTHERS"};
      }
      input.importing.e_menge.set(fromScaledQuantity(convertedQuantity));
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    throw {classic: "OTHERS"};
  };
  abap.FunctionModules["BAPI_RESERVATION_CREATE1"] = async (input) => {
    const header = input.exporting.reservationheader.get();
    const items = input.tables.reservationitems.array();
    const item = items[0]?.get();
    const material = item?.material_external?.get()?.trim()
      || item?.material?.get()?.trim();
    const moveType = header?.move_type?.get()?.trim();
    const entryQuantity = Number(item?.entry_qnt?.get());
    const payloadIncomplete = !isSapNumericKey(moveType, 3)
      || !isValidSapDate(header?.res_date?.get()?.trim())
      || !header?.created_by?.get()?.trim()
      || items.length !== 1
      || !material
      || !item?.plant?.get()?.trim()
      || !item?.stge_loc?.get()?.trim()
      || !Number.isFinite(entryQuantity)
      || entryQuantity <= 0
      || !item?.entry_uom?.get()?.trim()
      || !isValidSapDate(item?.req_date?.get()?.trim());
    commitFails = material === "MATERIAL-COMMIT-ERROR"
      || material === "MATERIAL-COMMIT-RETURN-ROLLBACK"
      || material === "MATERIAL-ROLLBACK-ERROR";
    commitReturnError = material === "MATERIAL-COMMIT-RETURN-ERROR";
    commitReturnInvalid = material === "MATERIAL-COMMIT-BAD-RETURN";
    rollbackFails = material === "MATERIAL-ROLLBACK-ERROR"
      || material === "MATERIAL-ERROR-ROLLBACK";
    rollbackReturnError = material === "MATERIAL-ROLLBACK-RETURN-ERROR"
      || material === "MATERIAL-COMMIT-RETURN-ROLLBACK"
      || material === "MATERIAL-ERROR-ROLLBACK-RETURN";
    rollbackReturnInvalid = material === "MATERIAL-ROLLBACK-BAD-RETURN";
    commitThrows = material === "MATERIAL-COMMIT-FM-ERROR";
    rollbackThrows = material === "MATERIAL-FM-ROLLBACK-ERROR"
      || material === "MATERIAL-ROLLBACK-FM-ERROR";
    if (material === "MATERIAL-FM-ERROR"
        || material === "MATERIAL-FM-ROLLBACK-ERROR") {
      throw {classic: "OTHERS"};
    }
    if (payloadIncomplete) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Reservation payload is incomplete");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-ERROR"
        || material === "MATERIAL-ERROR-ROLLBACK"
        || material === "MATERIAL-ROLLBACK-BAD-RETURN"
        || material === "MATERIAL-ERROR-ROLLBACK-RETURN") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Reservation rejected by test double");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-BAD-RETURN-TYPE") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid reservation return status");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-BAD-RESERVATION") {
      input.importing.reservation.set("BAD-RES");
    } else if (material === "MATERIAL-PAD-RESERVATION") {
      input.importing.reservation.set("123");
    } else if (material === "MATERIAL-BAD-ZERO-RESERVATION") {
      input.importing.reservation.set("0000000000");
    } else {
      const client = abap.builtin.sy.get().mandt.get()?.trim();
      const materialNumber = item?.material_external?.get()?.trim()
        || item?.material?.get()?.trim();
      const baseQuantity = getBaseReservationQuantity(item, materialNumber, client);
      if (!baseQuantity) {
        const returnRow = input.tables.return.getRowType().clone();
        returnRow.setField("type", "E");
        returnRow.setField("message", "Reservation unit is invalid");
        input.tables.return.append(returnRow);
        abap.builtin.sy.get().subrc.set(0);
        return;
      }
      reservationCounter += 1;
      const reservation = String(reservationCounter).padStart(10, "0");
      input.importing.reservation.set(reservation);
      pendingReservationItems.push({
        client,
        reservation,
        position: "0001",
        plant: item?.plant?.get()?.trim(),
        movementType: moveType,
        material: materialNumber,
        storageLocation: item?.stge_loc?.get()?.trim(),
        batch: item?.batch?.get()?.trim(),
        quantity: baseQuantity.quantity,
        unit: baseQuantity.unit,
      });
    }
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_GOODSMVT_CREATE"] = async (input) => {
    const header = input.exporting.goodsmvt_header.get();
    const headerText = header?.header_txt?.get()?.trim();
    const code = input.exporting.goodsmvt_code.get();
    const items = input.tables.goodsmvt_item.array();
    const item = items[0]?.get();
    const material = item?.material_external?.get()?.trim()
      || item?.material?.get()?.trim();
    const movementType = item?.move_type?.get()?.trim();
    const entryQuantity = Number(item?.entry_qnt?.get());
    const headerTextMissing = material === "MATERIAL-GI-HEADER"
      && headerText !== "ZSTOCK_ALLOC_GOODS_ISSUE";
    const payloadIncomplete = !isValidSapDate(header?.pstng_date?.get()?.trim())
      || !isValidSapDate(header?.doc_date?.get()?.trim())
      || headerTextMissing
      || code?.gm_code?.get()?.trim() !== "03"
      || items.length !== 1
      || !material
      || !item?.plant?.get()?.trim()
      || !item?.stge_loc?.get()?.trim()
      || !isSapNumericKey(movementType, 3)
      || !Number.isFinite(entryQuantity)
      || entryQuantity <= 0
      || !item?.entry_uom?.get()?.trim();
    commitFails = material === "MATERIAL-GI-COMMIT"
      || material === "MATERIAL-GI-ROLLBACK";
    commitReturnError = material === "MATERIAL-GI-COMMIT-RETURN-ERROR";
    commitReturnInvalid = material === "MATERIAL-GI-COMMIT-BAD-RETURN";
    rollbackFails = material === "MATERIAL-GI-ROLLBACK"
      || material === "MATERIAL-GI-ERROR-ROLLBACK";
    rollbackReturnError = material === "MATERIAL-GI-ROLLBACK-RETURN-ERROR"
      || material === "MATERIAL-GI-ERROR-ROLLBACK-RETURN";
    rollbackReturnInvalid = material === "MATERIAL-GI-ROLLBACK-BAD-RETURN";
    commitThrows = material === "MATERIAL-GI-COMMIT-FM-ERROR";
    rollbackThrows = material === "MATERIAL-GI-FM-ROLLBACK-ERROR";
    if (material === "MATERIAL-GI-FM-ERROR"
        || material === "MATERIAL-GI-FM-ROLLBACK-ERROR") {
      throw {classic: "OTHERS"};
    }
    if (payloadIncomplete) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Goods movement payload is incomplete");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-GI-ERROR"
        || material === "MATERIAL-GI-ERROR-ROLLBACK"
        || material === "MATERIAL-GI-ROLLBACK-BAD-RETURN"
        || material === "MATERIAL-GI-ERROR-ROLLBACK-RETURN") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", material === "MATERIAL-GI-ERROR"
        || material === "MATERIAL-GI-ERROR-ROLLBACK"
        || material === "MATERIAL-GI-ROLLBACK-BAD-RETURN"
        || material === "MATERIAL-GI-ERROR-ROLLBACK-RETURN"
        ? "Goods movement rejected by test double"
        : "Goods movement payload is incomplete");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-GI-BAD-RETURN-TYPE") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid goods movement return status");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    const client = abap.builtin.sy.get().mandt.get()?.trim();
    const movementBatch = item?.batch?.get()?.trim();
    const unitData = getMaterialUomData(material, client);
    if (!unitData) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Material master data not found");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    const batchFlagRows = abap.context.databaseConnections.DEFAULT.sqlite.exec(
      `SELECT xchpf FROM mara `
      + `WHERE mandt = ${quoteSql(client)} `
      + `AND matnr = ${quoteSql(material)}`,
    );
    const batchIndicator = batchFlagRows?.[0]?.values?.[0]?.[0]
      ?.toString()?.trim()?.toUpperCase() ?? "";
    if (batchIndicator !== "" && batchIndicator !== "X") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Material batch-management indicator is invalid");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (batchIndicator === "X" && !movementBatch) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Batch is required for batch-managed material");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    const baseQuantity = getBaseReservationQuantity(item, material, client);
    const scaledQuantity = baseQuantity
      && toScaledQuantity(baseQuantity.quantity);
    if (scaledQuantity === undefined) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Goods movement unit is invalid");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    const table = movementBatch ? "mchb" : "mard";
    const quantityField = movementBatch ? "clabs" : "labst";
    const batchPredicate = movementBatch
      ? `AND charg = ${quoteSql(movementBatch)} `
      : "";
    const stockRows = abap.context.databaseConnections.DEFAULT.sqlite.exec(
      `SELECT ${quantityField} FROM ${table} `
      + `WHERE mandt = ${quoteSql(client)} `
      + `AND matnr = ${quoteSql(material)} `
      + `AND werks = ${quoteSql(item?.plant?.get()?.trim())} `
      + `AND lgort = ${quoteSql(item?.stge_loc?.get()?.trim())} `
      + batchPredicate,
    );
    const availableQuantity = toScaledQuantity(
      stockRows?.[0]?.values?.[0]?.[0],
    );
    if (availableQuantity === undefined || availableQuantity < scaledQuantity) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Insufficient unrestricted stock");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (movementBatch) {
      const aggregateRows = abap.context.databaseConnections.DEFAULT.sqlite.exec(
        `SELECT labst FROM mard `
        + `WHERE mandt = ${quoteSql(client)} `
        + `AND matnr = ${quoteSql(material)} `
        + `AND werks = ${quoteSql(item?.plant?.get()?.trim())} `
        + `AND lgort = ${quoteSql(item?.stge_loc?.get()?.trim())}`,
      );
      const aggregateQuantity = toScaledQuantity(
        aggregateRows?.[0]?.values?.[0]?.[0],
      );
      if (aggregateQuantity === undefined || aggregateQuantity < scaledQuantity) {
        const returnRow = input.tables.return.getRowType().clone();
        returnRow.setField("type", "E");
        returnRow.setField("message", "Insufficient unrestricted stock");
        input.tables.return.append(returnRow);
        abap.builtin.sy.get().subrc.set(0);
        return;
      }
    }
    pendingGoodsMovements.push({
      client,
      material,
      plant: item?.plant?.get()?.trim(),
      storageLocation: item?.stge_loc?.get()?.trim(),
      batch: movementBatch,
      quantity: scaledQuantity,
    });
    movementCounter += 1;
    input.importing.goodsmvt_headret.setField(
      "mat_doc",
      material === "MATERIAL-GI-BAD-DOCUMENT"
        ? "BAD-DOC"
        : material === "MATERIAL-GI-SHORT-DOCUMENT"
          ? "123"
        : material === "MATERIAL-GI-ZERO-DOCUMENT"
          ? "0000000000"
        : String(movementCounter).padStart(10, "0")
    );
    if (material !== "MATERIAL-GI-NO-YEAR") {
      input.importing.goodsmvt_headret.setField(
        "doc_year",
        material === "MATERIAL-GI-ZERO-YEAR"
          ? "0000"
          : "2026"
      );
    }
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_SALESORDER_CHANGE"] = async (input) => {
    const salesDocument = input.exporting.salesdocument.get()?.trim();
    const headerX = input.exporting.order_header_inx.get();
    const schedules = input.tables.schedule_lines.array();
    const schedule = schedules[0]?.get();
    const scheduleItem = schedule?.itm_number?.get()?.trim();
    const scheduleLine = schedule?.sched_line?.get()?.trim();
    const scheduleQuantity = Number(schedule?.req_qty?.get());
    const scaledScheduleQuantity = toScaledQuantity(schedule?.req_qty?.get());
    const scheduleXs = input.tables.schedule_linesx.array();
    const scheduleX = scheduleXs[0]?.get();
    const scheduleXItem = scheduleX?.itm_number?.get()?.trim();
    const scheduleXLine = scheduleX?.sched_line?.get()?.trim();
    const payloadIncomplete = !salesDocument
      || headerX?.updateflag?.get()?.trim() !== "U"
      || schedules.length !== 1
      || !isSapNumericKey(salesDocument, 10)
      || !isSapNumericKey(scheduleItem, 6)
      || !isSapNumericKey(scheduleLine, 4)
      || !Number.isFinite(scheduleQuantity)
      || scheduleQuantity <= 0
      || scaledScheduleQuantity === undefined
      || scheduleXs.length !== 1
      || !isSapNumericKey(scheduleXItem, 6)
      || !isSapNumericKey(scheduleXLine, 4)
      || scheduleXItem !== scheduleItem
      || scheduleXLine !== scheduleLine
      || scheduleX?.updateflag?.get()?.trim() !== "U"
      || scheduleX?.req_qty?.get()?.trim() !== "X";
    commitFails = salesDocument === "9999999903"
      || salesDocument === "9999999904";
    commitReturnError = salesDocument === "9999999907";
    commitReturnInvalid = salesDocument === "9999999908";
    rollbackFails = salesDocument === "9999999904"
      || salesDocument === "9999999902";
    rollbackReturnError = salesDocument === "9999999910";
    rollbackReturnInvalid = salesDocument === "9999999911";
    commitThrows = salesDocument === "9999999905";
    rollbackThrows = salesDocument === "9999999906";
    if (salesDocument === "9999999905"
        || salesDocument === "9999999906") {
      throw {classic: "OTHERS"};
    }
    if (salesDocument === "9999999901"
        || salesDocument === "9999999902"
        || salesDocument === "9999999910"
        || salesDocument === "9999999911"
        || payloadIncomplete) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", salesDocument === "9999999901"
        || salesDocument === "9999999902"
        || salesDocument === "9999999910"
        || salesDocument === "9999999911"
        ? "Sales-order change rejected by test double"
        : "Sales-order change payload is incomplete");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (salesDocument === "9999999900") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid sales-order return status");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    const client = abap.builtin.sy.get().mandt.get()?.trim();
    const scheduleRows = abap.context.databaseConnections.DEFAULT.sqlite.exec(
      `SELECT schedule_row.vbeln FROM vbak AS header_row `
      + `INNER JOIN vbap AS item_row `
      + `ON item_row.mandt = header_row.mandt `
      + `AND item_row.vbeln = header_row.vbeln `
      + `INNER JOIN vbep AS schedule_row `
      + `ON schedule_row.mandt = item_row.mandt `
      + `AND schedule_row.vbeln = item_row.vbeln `
      + `AND schedule_row.posnr = item_row.posnr `
      + `WHERE header_row.mandt = ${quoteSql(client)} `
      + `AND header_row.vbeln = ${quoteSql(salesDocument)} `
      + `AND item_row.posnr = ${quoteSql(scheduleItem)} `
      + `AND schedule_row.etenr = ${quoteSql(scheduleLine)}`,
    );
    if (scheduleRows?.[0]?.values?.length !== 1) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Sales-order item or schedule line was not found");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    pendingSalesOrderChanges.push({
      client,
      salesDocument,
      item: scheduleItem,
      scheduleLine,
      quantity: scaledScheduleQuantity,
    });
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_RESERVATION_DELETE"] = async (input) => {
    const reservation = input.exporting.reservation.get()?.trim();
    const payloadIncomplete = !reservation
      || reservation.length !== 10
      || !/^[0-9]+$/.test(reservation)
      || reservation === "0000000000";
    if (payloadIncomplete) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Reservation deletion payload is incomplete");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    commitFails = reservation === "9999999999";
    commitReturnError = reservation === "9999999994";
    commitReturnInvalid = reservation === "9999999993";
    rollbackFails = reservation === "9999999999"
      || reservation === "9999999998";
    rollbackReturnError = reservation === "9999999992";
    rollbackReturnInvalid = reservation === "9999999991";
    commitThrows = reservation === "9999999996";
    rollbackThrows = reservation === "9999999995";
    if (reservation === "9999999996"
        || reservation === "9999999995") {
      throw {classic: "OTHERS"};
    }
    if (reservation === "9999999998"
        || reservation === "9999999992"
        || reservation === "9999999991") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", reservation === "9999999991" ? "?" : "E");
      returnRow.setField("message", reservation === "9999999991"
        ? "Invalid reservation deletion return status"
        : "Reservation deletion rejected by test double");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (reservation === "9999999997") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid reservation deletion return status");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    const client = abap.builtin.sy.get().mandt.get()?.trim();
    const reservationRows = abap.context.databaseConnections.DEFAULT.sqlite.exec(
      `SELECT COUNT(*) FROM resb `
      + `WHERE mandt = ${quoteSql(client)} `
      + `AND rsnum = ${quoteSql(reservation)}`,
    );
    if (Number(reservationRows?.[0]?.values?.[0]?.[0] ?? 0) < 1) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Reservation does not exist");
      input.tables.return.append(returnRow);
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    pendingReservationDeletions.add({
      client,
      reservation,
    });
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_TRANSACTION_COMMIT"] = async (input) => {
    if (commitReturnError || commitReturnInvalid) {
      input.importing.return.setField(
        "type",
        commitReturnInvalid ? "?" : "E",
      );
      input.importing.return.setField(
        "message",
        commitReturnInvalid
          ? "Invalid transaction commit return status"
          : "Transaction commit rejected by test double",
      );
      commitReturnError = false;
      commitReturnInvalid = false;
      commitFails = false;
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (commitThrows || commitFails) {
      commitThrows = false;
      commitFails = false;
      throw {classic: "OTHERS"};
    }
    await persistReservationChanges();
    releaseUpdateOwnerLocks();
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_TRANSACTION_ROLLBACK"] = async (input) => {
    const database = abap.context.databaseConnections.DEFAULT;
    let databaseRollbackFailed = false;
    if (pendingDatabaseTransaction && database.inTransaction) {
      try {
        await database.rollback();
        pendingDatabaseTransaction = false;
      } catch {
        databaseRollbackFailed = true;
      }
    } else if (pendingDatabaseTransaction) {
      pendingDatabaseTransaction = false;
    }
    pendingReservationItems.length = 0;
    pendingReservationDeletions.clear();
    pendingGoodsMovements.length = 0;
    pendingSalesOrderChanges.length = 0;
    releaseUpdateOwnerLocks();
    if (databaseRollbackFailed) {
      throw {classic: "OTHERS"};
    }
    if (rollbackReturnError || rollbackReturnInvalid) {
      input.importing.return.setField(
        "type",
        rollbackReturnInvalid ? "?" : "E",
      );
      input.importing.return.setField(
        "message",
        rollbackReturnInvalid
          ? "Invalid transaction rollback return status"
          : "Transaction rollback rejected by test double",
      );
      rollbackReturnError = false;
      rollbackReturnInvalid = false;
      commitFails = false;
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (rollbackThrows || rollbackFails) {
      rollbackThrows = false;
      rollbackFails = false;
      commitFails = false;
      throw {classic: "OTHERS"};
    }
    commitFails = false;
    abap.builtin.sy.get().subrc.set(0);
  };
}
