INTERFACE zif_stock_rechecker PUBLIC.
  TYPES:
    BEGIN OF ty_result,
      is_valid TYPE abap_bool,
      message  TYPE string,
    END OF ty_result.

  METHODS recheck
    IMPORTING
      it_allocations   TYPE zcl_stock_allocator=>ty_allocations
    RETURNING
      VALUE(rs_result) TYPE ty_result.
ENDINTERFACE.
