CLASS zcl_alloc_cycle_count DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS count
      IMPORTING
        iv_total         TYPE i
        iv_per_cycle     TYPE i
      RETURNING
        VALUE(rv_cycles) TYPE i.

    METHODS after
      IMPORTING
        iv_cycles       TYPE i
        iv_per_cycle    TYPE i
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_count     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cycle_count IMPLEMENTATION.

  METHOD count.
    " The number of cycles needed to cover the total, rounding up.
    IF iv_per_cycle <= 0.
      RETURN.
    ENDIF.

    rv_cycles = ( iv_total + iv_per_cycle - 1 ) DIV iv_per_cycle.
  ENDMETHOD.

  METHOD after.
    " The amount covered after that many cycles.
    rv_total = iv_cycles * iv_per_cycle.
  ENDMETHOD.

  METHOD is_zero.
    " A count at zero means no cycles have run.
    rv_ok = xsdbool( iv_count = 0 ).
  ENDMETHOD.

ENDCLASS.
