CLASS zcl_alloc_cycle_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS run
      IMPORTING
        iv_done        TYPE i
        iv_batch       TYPE i
        iv_total       TYPE i
      RETURNING
        VALUE(rv_done) TYPE i.

    METHODS is_finished
      IMPORTING
        iv_done      TYPE i
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS steps_done
      IMPORTING
        iv_total         TYPE i
        iv_batch         TYPE i
      RETURNING
        VALUE(rv_passes) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cycle_run IMPLEMENTATION.

  METHOD run.
    " One batch of steps runs and the total is held at the cycle size.
    rv_done = iv_done + iv_batch.
    IF rv_done > iv_total.
      rv_done = iv_total.
    ENDIF.
  ENDMETHOD.

  METHOD is_finished.
    " The run is finished once every step has gone through.
    rv_ok = xsdbool( iv_done >= iv_total ).
  ENDMETHOD.

  METHOD steps_done.
    " The number of batches needed to run the whole cycle, rounding up.
    IF iv_batch <= 0.
      RETURN.
    ENDIF.

    rv_passes = ( iv_total + iv_batch - 1 ) DIV iv_batch.
  ENDMETHOD.

ENDCLASS.
