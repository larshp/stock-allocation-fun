export function installBapiStockStub(abap) {
  let commitFails = false;
  let reservationCounter = 0;
  let movementCounter = 0;
  abap.FunctionModules["BAPI_RESERVATION_CREATE1"] = async (input) => {
    const items = input.tables.reservationitems.array();
    const item = items[0]?.get();
    const material = item?.material_external?.get()?.trim()
      || item?.material?.get()?.trim();
    commitFails = material === "MATERIAL-COMMIT-ERROR";
    if (material === "MATERIAL-ERROR") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", "Reservation rejected by test double");
      input.tables.return.append(returnRow);
    }
    reservationCounter += 1;
    input.importing.reservation.set(String(reservationCounter).padStart(10, "0"));
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_GOODSMVT_CREATE"] = async (input) => {
    const items = input.tables.goodsmvt_item.array();
    const item = items[0]?.get();
    const material = item?.material_external?.get()?.trim()
      || item?.material?.get()?.trim();
    commitFails = material === "MATERIAL-GI-COMMIT";
    if (material === "MATERIAL-GI-ERROR"
        || !item?.plant?.get()?.trim()
        || !item?.stge_loc?.get()?.trim()
        || !item?.move_type?.get()?.trim()
        || !item?.entry_uom?.get()?.trim()) {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", material === "MATERIAL-GI-ERROR"
        ? "Goods movement rejected by test double"
        : "Goods movement item is incomplete");
      input.tables.return.append(returnRow);
    }
    movementCounter += 1;
    input.importing.goodsmvt_headret.setField(
      "mat_doc",
      String(movementCounter).padStart(10, "0")
    );
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_SALESORDER_CHANGE"] = async (input) => {
    const salesDocument = input.exporting.salesdocument.get()?.trim();
    const schedules = input.tables.schedule_lines.array();
    const schedule = schedules[0]?.get();
    const scheduleXs = input.tables.schedule_linesx.array();
    const scheduleX = scheduleXs[0]?.get();
    commitFails = salesDocument === "ORDCOMMIT1";
    if (salesDocument === "ORDERERR01"
        || !schedule?.itm_number?.get()?.trim()
        || !schedule?.sched_line?.get()?.trim()
        || !scheduleX?.itm_number?.get()?.trim()
        || !scheduleX?.sched_line?.get()?.trim()
        || scheduleX?.updateflag?.get()?.trim() !== "U"
        || scheduleX?.req_qty?.get()?.trim() !== "X") {
      const returnRow = input.tables.return.getRowType().clone();
      returnRow.setField("type", "E");
      returnRow.setField("message", salesDocument === "ORDERERR01"
        ? "Sales-order change rejected by test double"
        : "Sales-order schedule change is incomplete");
      input.tables.return.append(returnRow);
    }
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_RESERVATION_DELETE"] = async () => {
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_TRANSACTION_COMMIT"] = async () => {
    abap.builtin.sy.get().subrc.set(commitFails ? 1 : 0);
    commitFails = false;
  };
  abap.FunctionModules["BAPI_TRANSACTION_ROLLBACK"] = async () => {
    commitFails = false;
    abap.builtin.sy.get().subrc.set(0);
  };
}
