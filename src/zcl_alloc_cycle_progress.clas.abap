CLASS zcl_alloc_cycle_progress DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS progress_percent
      IMPORTING
        iv_done           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_done
      IMPORTING
        iv_done      TYPE i
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS remaining
      IMPORTING
        iv_done          TYPE i
        iv_total         TYPE i
      RETURNING
        VALUE(rv_remain) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cycle_progress IMPLEMENTATION.

  METHOD progress_percent.
    " Progress is the steps done as a share of the whole cycle.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_done * 100 DIV iv_total.
  ENDMETHOD.

  METHOD is_done.
    " The cycle is done once every step has run.
    rv_ok = xsdbool( iv_done >= iv_total ).
  ENDMETHOD.

  METHOD remaining.
    " The steps still to run.
    IF iv_done >= iv_total.
      RETURN.
    ENDIF.

    rv_remain = iv_total - iv_done.
  ENDMETHOD.

ENDCLASS.
