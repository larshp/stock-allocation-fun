CLASS zcl_stock_allocator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS allocate
      IMPORTING iv_available_qty   TYPE i
                iv_requested_qty   TYPE i
      RETURNING VALUE(rv_quantity) TYPE i.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    IF iv_available_qty <= 0 OR iv_requested_qty <= 0.
      rv_quantity = 0.
    ELSEIF iv_available_qty < iv_requested_qty.
      rv_quantity = iv_available_qty.
    ELSE.
      rv_quantity = iv_requested_qty.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
