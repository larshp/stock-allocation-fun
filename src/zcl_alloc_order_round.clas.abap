CLASS zcl_alloc_order_round DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS round_up
      IMPORTING
        iv_quantity     TYPE i
        iv_round_to     TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS round_down
      IMPORTING
        iv_quantity     TYPE i
        iv_round_to     TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS is_exact
      IMPORTING
        iv_quantity  TYPE i
        iv_round_to  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_order_round IMPLEMENTATION.

  METHOD round_up.
    " Without a rounding step the quantity is left as it is.
    IF iv_round_to <= 0.
      rv_value = iv_quantity.
      RETURN.
    ENDIF.

    rv_value = ( iv_quantity + iv_round_to - 1 ) DIV iv_round_to * iv_round_to.
  ENDMETHOD.

  METHOD round_down.
    IF iv_round_to <= 0.
      rv_value = iv_quantity.
      RETURN.
    ENDIF.

    rv_value = iv_quantity DIV iv_round_to * iv_round_to.
  ENDMETHOD.

  METHOD is_exact.
    " A quantity is exact when it already sits on a rounding step.
    rv_ok = xsdbool( iv_round_to > 0
                     AND iv_quantity MOD iv_round_to = 0 ).
  ENDMETHOD.

ENDCLASS.
