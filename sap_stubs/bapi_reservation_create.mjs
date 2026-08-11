export function installBapiStockStub(abap) {
  let commitFails = false;
  let rollbackFails = false;
  let reservationCounter = 0;
  let movementCounter = 0;
  abap.FunctionModules["ENQUEUE_EZSTOCKALLOC"] = async (input) => {
    const material = input.exporting.matnr.get()?.trim();
    abap.builtin.sy.get().subrc.set(material === "MATERIAL-LOCK-ERROR" ? 1 : 0);
  };
  abap.FunctionModules["DEQUEUE_EZSTOCKALLOC"] = async (input) => {
    const material = input.exporting.matnr.get()?.trim();
    abap.builtin.sy.get().subrc.set(material === "MATERIAL-UNLOCK-ERROR" ? 1 : 0);
  };
  abap.FunctionModules["MD_CONVERT_MATERIAL_UNIT"] = async (input) => {
    const material = input.exporting.i_matnr.get()?.trim();
    const unitIn = input.exporting.i_in_me.get()?.trim();
    const unitOut = input.exporting.i_out_me.get()?.trim();
    const quantity = Number(input.exporting.i_menge.get());
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
    abap.builtin.sy.get().subrc.set(1);
  };
  abap.FunctionModules["BAPI_RESERVATION_CREATE1"] = async (input) => {
    const items = input.tables.reservationitems.array();
    const item = items[0]?.get();
    const material = item?.material_external?.get()?.trim()
      || item?.material?.get()?.trim();
    commitFails = material === "MATERIAL-COMMIT-ERROR"
      || material === "MATERIAL-ROLLBACK-ERROR";
    rollbackFails = material === "MATERIAL-ROLLBACK-ERROR"
      || material === "MATERIAL-ERROR-ROLLBACK";
    if (material === "MATERIAL-ERROR"
        || material === "MATERIAL-ERROR-ROLLBACK") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Reservation rejected by test double");
      input.tables.return.append(returnRow);
    }
    if (material === "MATERIAL-BAD-RETURN-TYPE") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid reservation return status");
      input.tables.return.append(returnRow);
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
    const items = input.tables.goodsmvt_item.array();
    const item = items[0]?.get();
    const material = item?.material_external?.get()?.trim()
      || item?.material?.get()?.trim();
    commitFails = material === "MATERIAL-GI-COMMIT"
      || material === "MATERIAL-GI-ROLLBACK";
    rollbackFails = material === "MATERIAL-GI-ROLLBACK"
      || material === "MATERIAL-GI-ERROR-ROLLBACK";
    if (material === "MATERIAL-GI-ERROR"
        || material === "MATERIAL-GI-ERROR-ROLLBACK"
        || !item?.plant?.get()?.trim()
        || !item?.stge_loc?.get()?.trim()
        || !item?.move_type?.get()?.trim()
        || !item?.entry_uom?.get()?.trim()) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", material === "MATERIAL-GI-ERROR"
        || material === "MATERIAL-GI-ERROR-ROLLBACK"
        ? "Goods movement rejected by test double"
        : "Goods movement item is incomplete");
      input.tables.return.append(returnRow);
    }
    if (material === "MATERIAL-GI-BAD-RETURN-TYPE") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid goods movement return status");
      input.tables.return.append(returnRow);
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
    const schedules = input.tables.schedule_lines.array();
    const schedule = schedules[0]?.get();
    const scheduleXs = input.tables.schedule_linesx.array();
    const scheduleX = scheduleXs[0]?.get();
    commitFails = salesDocument === "9999999903"
      || salesDocument === "9999999904";
    rollbackFails = salesDocument === "9999999904"
      || salesDocument === "9999999902";
    if (salesDocument === "9999999901"
        || salesDocument === "9999999902"
        || !schedule?.itm_number?.get()?.trim()
        || !schedule?.sched_line?.get()?.trim()
        || !scheduleX?.itm_number?.get()?.trim()
        || !scheduleX?.sched_line?.get()?.trim()
        || scheduleX?.updateflag?.get()?.trim() !== "U"
        || scheduleX?.req_qty?.get()?.trim() !== "X") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", salesDocument === "9999999901"
        || salesDocument === "9999999902"
        ? "Sales-order change rejected by test double"
        : "Sales-order schedule change is incomplete");
      input.tables.return.append(returnRow);
    }
    if (salesDocument === "9999999900") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid sales-order return status");
      input.tables.return.append(returnRow);
    }
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_RESERVATION_DELETE"] = async (input) => {
    const reservation = input.exporting.reservation.get()?.trim();
    commitFails = reservation === "9999999999";
    rollbackFails = reservation === "9999999999"
      || reservation === "9999999998";
    if (reservation === "9999999998") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Reservation deletion rejected by test double");
      input.tables.return.append(returnRow);
    }
    if (reservation === "9999999997") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "?");
      returnRow.setField("message", "Invalid reservation deletion return status");
      input.tables.return.append(returnRow);
    }
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_TRANSACTION_COMMIT"] = async () => {
    abap.builtin.sy.get().subrc.set(commitFails ? 1 : 0);
    commitFails = false;
  };
  abap.FunctionModules["BAPI_TRANSACTION_ROLLBACK"] = async () => {
    const failed = rollbackFails;
    rollbackFails = false;
    commitFails = false;
    abap.builtin.sy.get().subrc.set(failed ? 1 : 0);
  };
}
