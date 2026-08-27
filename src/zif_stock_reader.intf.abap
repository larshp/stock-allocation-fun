INTERFACE zif_stock_reader PUBLIC.
  TYPES:
    BEGIN OF ty_result,
      is_success TYPE abap_bool,
      message    TYPE string,
      stock      TYPE zcl_stock_allocator=>ty_stock_balances,
    END OF ty_result.

  METHODS read_stock
    IMPORTING
      it_requests      TYPE zcl_stock_allocator=>ty_requests
    RETURNING
      VALUE(rs_result) TYPE ty_result.
ENDINTERFACE.
