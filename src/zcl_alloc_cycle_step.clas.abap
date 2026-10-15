CLASS zcl_alloc_cycle_step DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS step
      IMPORTING
        iv_position    TYPE i
        iv_size        TYPE i
      RETURNING
        VALUE(rv_step) TYPE i.

    METHODS next_step
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


CLASS zcl_alloc_cycle_step IMPLEMENTATION.

  METHOD step.
    DATA lv_zero TYPE i.

    " The step a position falls into, numbered from one.
    IF iv_size <= 0 OR iv_position <= 0.
      RETURN.
    ENDIF.

    lv_zero = iv_position - 1.
    rv_step = lv_zero DIV iv_size + 1.
  ENDMETHOD.

  METHOD next_step.
    " The next step, held at the total once the cycle ends.
    rv_next = iv_current + 1.
    IF rv_next > iv_total.
      rv_next = iv_total.
    ENDIF.
  ENDMETHOD.

  METHOD is_last.
    " The cycle is on its last step once it reaches the total.
    rv_ok = xsdbool( iv_current >= iv_total ).
  ENDMETHOD.

ENDCLASS.
