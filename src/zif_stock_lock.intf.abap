INTERFACE zif_stock_lock PUBLIC.
  TYPES:
    BEGIN OF ty_result,
      acquired TYPE abap_bool,
      message  TYPE string,
    END OF ty_result.

  METHODS acquire
    IMPORTING
      it_allocations   TYPE zcl_stock_allocator=>ty_allocations
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS release.
ENDINTERFACE.
