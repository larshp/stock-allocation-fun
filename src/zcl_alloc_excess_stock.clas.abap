CLASS zcl_alloc_excess_stock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_excess
      IMPORTING
        iv_stock     TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS excess_qty
      IMPORTING
        iv_stock      TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS excess_value
      IMPORTING
        iv_stock        TYPE i
        iv_target       TYPE i
        iv_unit_cost    TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

ENDCLASS.


CLASS zcl_alloc_excess_stock IMPLEMENTATION.

  METHOD is_excess.
    " The stock is excessive while it sits above the target.
    rv_ok = xsdbool( iv_stock > iv_target ).
  ENDMETHOD.

  METHOD excess_qty.
    " The excess is the part above the target, never negative.
    IF iv_stock <= iv_target.
      RETURN.
    ENDIF.

    rv_qty = iv_stock - iv_target.
  ENDMETHOD.

  METHOD excess_value.
    DATA lv_qty TYPE i.

    " The excess value prices the excess quantity.
    lv_qty = excess_qty( iv_stock = iv_stock iv_target = iv_target ).
    rv_value = lv_qty * iv_unit_cost.
  ENDMETHOD.

ENDCLASS.
