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
  abap.FunctionModules["ENQUEUE_EZSTOCKALLOC"] = async (input) => {
    const material = input.exporting.matnr.get()?.trim();
    const plant = input.exporting.werks.get()?.trim();
    const storageLocation = input.exporting.lgort.get()?.trim();
    if (!material || !plant || !storageLocation) {
      throw {classic: "OTHERS"};
    }
    if (material === "MATERIAL-LOCK-ERROR") {
      throw {classic: "OTHERS"};
    }
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["DEQUEUE_EZSTOCKALLOC"] = async (input) => {
    const material = input.exporting.matnr.get()?.trim();
    const plant = input.exporting.werks.get()?.trim();
    const storageLocation = input.exporting.lgort.get()?.trim();
    if (!material || !plant || !storageLocation) {
      throw {classic: "OTHERS"};
    }
    if (material === "MATERIAL-UNLOCK-ERROR") {
      throw {classic: "OTHERS"};
    }
    abap.builtin.sy.get().subrc.set(0);
  };
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
    if (material === "MATERIAL-BOX" && unitIn === "BOX" && unitOut === "EA") {
      input.importing.e_menge.set(String(quantity * 10));
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (material === "MATERIAL-BOX" && unitIn === "EA" && unitOut === "BOX") {
      input.importing.e_menge.set(String(quantity / 10));
      abap.builtin.sy.get().subrc.set(0);
      return;
    }
    if (unitIn === unitOut) {
      input.importing.e_menge.set(String(quantity));
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
    } else if (material === "MATERIAL-SHORT-RESERVATION") {
      input.importing.reservation.set("123");
    } else if (material === "MATERIAL-BAD-ZERO-RESERVATION") {
      input.importing.reservation.set("0000000000");
    } else {
      reservationCounter += 1;
      input.importing.reservation.set(String(reservationCounter).padStart(10, "0"));
    }
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_GOODSMVT_CREATE"] = async (input) => {
    const header = input.exporting.goodsmvt_header.get();
    const code = input.exporting.goodsmvt_code.get();
    const items = input.tables.goodsmvt_item.array();
    const item = items[0]?.get();
    const material = item?.material_external?.get()?.trim()
      || item?.material?.get()?.trim();
    const movementType = item?.move_type?.get()?.trim();
    const entryQuantity = Number(item?.entry_qnt?.get());
    const payloadIncomplete = !isValidSapDate(header?.pstng_date?.get()?.trim())
      || !isValidSapDate(header?.doc_date?.get()?.trim())
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
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_TRANSACTION_ROLLBACK"] = async (input) => {
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
