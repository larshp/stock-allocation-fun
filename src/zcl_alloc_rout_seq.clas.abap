CLASS zcl_alloc_rout_seq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS sequence
      IMPORTING
        iv_position  TYPE i
        iv_step      TYPE i
      RETURNING
        VALUE(rv_op) TYPE i.

    METHODS next_op
      IMPORTING
        iv_current     TYPE i
        iv_total       TYPE i
      RETURNING
        VALUE(rv_next) TYPE i.

    METHODS is_last
      IMPORTING
        iv_current   TYPE i
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_rout_seq IMPLEMENTATION.

  METHOD sequence.
    DATA lv_zero TYPE i.

    " The operation a position falls into, numbered from one.
    IF iv_step <= 0 OR iv_position <= 0.
      RETURN.
    ENDIF.

    lv_zero = iv_position - 1.
    rv_op = lv_zero DIV iv_step + 1.
  ENDMETHOD.

  METHOD next_op.
    " The next operation, held at the total once the routing ends.
    rv_next = iv_current + 1.
    IF rv_next > iv_total.
      rv_next = iv_total.
    ENDIF.
  ENDMETHOD.

  METHOD is_last.
    " The routing is on its last operation once it reaches the total.
    rv_ok = xsdbool( iv_current >= iv_total ).
  ENDMETHOD.

ENDCLASS.
