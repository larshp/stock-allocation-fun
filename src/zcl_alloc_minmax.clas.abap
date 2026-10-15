CLASS zcl_alloc_minmax DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_below_min
      IMPORTING
        iv_stock     TYPE i
        iv_min       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS order_quantity
      IMPORTING
        iv_stock      TYPE i
        iv_max        TYPE i
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS target
      IMPORTING
        iv_stock         TYPE i
        iv_min           TYPE i
        iv_max           TYPE i
      RETURNING
        VALUE(rv_target) TYPE i.

ENDCLASS.


CLASS zcl_alloc_minmax IMPLEMENTATION.

  METHOD is_below_min.
    " A reorder is triggered while the stock sits below the minimum.
    rv_ok = xsdbool( iv_stock < iv_min ).
  ENDMETHOD.

  METHOD order_quantity.
    " The order fills the stock back up to the maximum.
    IF iv_stock >= iv_max.
      RETURN.
    ENDIF.

    rv_qty = iv_max - iv_stock.
  ENDMETHOD.

  METHOD target.
    " Below the minimum the stock is raised to the maximum; above it, the stock
    " is already the target.
    IF iv_stock < iv_min.
      rv_target = iv_max.
    ELSE.
      rv_target = iv_stock.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
