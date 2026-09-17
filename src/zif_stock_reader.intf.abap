INTERFACE zif_stock_reader PUBLIC.
  TYPES ty_stock_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
  METHODS read_stock
    IMPORTING iv_material     TYPE mard-matnr
              iv_plant        TYPE mard-werks
    RETURNING VALUE(rt_stock) TYPE ty_stock_tt.
ENDINTERFACE.
