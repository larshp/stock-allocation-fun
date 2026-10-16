CLASS zcl_alloc_wip_progress DEFINITION
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

    METHODS is_complete
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


CLASS zcl_alloc_wip_progress IMPLEMENTATION.

  METHOD progress_percent.
    " Progress is the work done as a share of the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_done * 100 DIV iv_total.
  ENDMETHOD.

  METHOD is_complete.
    " The work in progress is complete once every step has run.
    rv_ok = xsdbool( iv_done >= iv_total ).
  ENDMETHOD.

  METHOD remaining.
    " The work still to run before completion.
    IF iv_done >= iv_total.
      RETURN.
    ENDIF.

    rv_remain = iv_total - iv_done.
  ENDMETHOD.

ENDCLASS.
