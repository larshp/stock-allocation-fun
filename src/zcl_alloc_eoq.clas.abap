CLASS zcl_alloc_eoq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             annual_demand TYPE menge_d,
             order_cost    TYPE menge_d,
             holding_cost  TYPE menge_d,
           END OF ty_input.

    METHODS calculate
      IMPORTING
        is_input      TYPE ty_input
      RETURNING
        VALUE(rv_qty) TYPE menge_d.

  PRIVATE SECTION.
    METHODS square_root
      IMPORTING
        iv_value       TYPE menge_d
      RETURNING
        VALUE(rv_root) TYPE i.

ENDCLASS.


CLASS zcl_alloc_eoq IMPLEMENTATION.

  METHOD square_root.
    DATA lv_limit TYPE i.

    lv_limit = iv_value.
    IF lv_limit < 0.
      lv_limit = 0.
    ENDIF.

    WHILE ( rv_root + 1 ) * ( rv_root + 1 ) <= lv_limit.
      rv_root = rv_root + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD calculate.
    DATA lv_under TYPE menge_d.

    IF is_input-holding_cost <= 0.
      rv_qty = 0.
      RETURN.
    ENDIF.

    lv_under = 2 * is_input-annual_demand * is_input-order_cost
      DIV is_input-holding_cost.

    IF lv_under <= 0.
      rv_qty = 0.
      RETURN.
    ENDIF.

    rv_qty = square_root( lv_under ).
  ENDMETHOD.

ENDCLASS.
