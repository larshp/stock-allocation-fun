export function installBapiStockStub(abap) {
  abap.FunctionModules["BAPI_RESERVATION_CREATE1"] = async (input) => {
    input.importing.reservation.set("STUB-RESERVATION");
    abap.builtin.sy.get().subrc.set(0);
  };
  abap.FunctionModules["BAPI_TRANSACTION_COMMIT"] = async () => {
    abap.builtin.sy.get().subrc.set(0);
  };
}
