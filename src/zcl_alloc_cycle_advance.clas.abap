CLASS zcl_alloc_cycle_advance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS advance
      IMPORTING
        iv_current     TYPE i
        iv_total       TYPE i
      RETURNING
        VALUE(rv_next) TYPE i.

    METHODS is_complete
      IMPORTING
        iv_current   TYPE i
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS remaining
      IMPORTING
        iv_current       TYPE i
        iv_total         TYPE i
      RETURNING
        VALUE(rv_remain) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cycle_advance IMPLEMENTATION.

  METHOD advance.
    " The cycle moves one step on, held at the total.
    rv_next = iv_current + 1.
    IF rv_next > iv_total.
      rv_next = iv_total.
    ENDIF.
  ENDMETHOD.

  METHOD is_complete.
    " The cycle is complete once it reaches the total.
    rv_ok = xsdbool( iv_current >= iv_total ).
  ENDMETHOD.

  METHOD remaining.
    " The steps still to run before the cycle completes.
    IF iv_current >= iv_total.
      RETURN.
    ENDIF.

    rv_remain = iv_total - iv_current.
  ENDMETHOD.

ENDCLASS.
