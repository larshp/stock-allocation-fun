CLASS zcl_alloc_cleanup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_outcome,
             simulation TYPE abap_bool,
             cutoff     TYPE d,
             candidates TYPE i,
             removed    TYPE i,
             rows       TYPE zcl_stock_commitment=>ty_resv_tt,
           END OF ty_outcome.

    METHODS constructor
      IMPORTING
        io_commitment TYPE REF TO zcl_stock_commitment OPTIONAL.

    METHODS run
      IMPORTING
        iv_retention_days TYPE i DEFAULT 30
        iv_simulation     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_outcome) TYPE ty_outcome.

    METHODS run_before
      IMPORTING
        iv_cutoff         TYPE d
        iv_simulation     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_outcome) TYPE ty_outcome.

  PRIVATE SECTION.
    DATA mo_commitment TYPE REF TO zcl_stock_commitment.

ENDCLASS.


CLASS zcl_alloc_cleanup IMPLEMENTATION.

  METHOD constructor.
    IF io_commitment IS SUPPLIED.
      mo_commitment = io_commitment.
    ENDIF.
    IF mo_commitment IS NOT BOUND.
      mo_commitment = NEW zcl_stock_commitment( ).
    ENDIF.
  ENDMETHOD.

  METHOD run.
    DATA lv_cutoff TYPE d.

    lv_cutoff = sy-datum - iv_retention_days.

    rs_outcome = run_before( iv_cutoff     = lv_cutoff
                             iv_simulation = iv_simulation ).
  ENDMETHOD.

  METHOD run_before.
    rs_outcome-simulation = iv_simulation.
    rs_outcome-cutoff = iv_cutoff.

    rs_outcome-rows = mo_commitment->read_expired( iv_before = iv_cutoff ).
    rs_outcome-candidates = lines( rs_outcome-rows ).

    IF iv_simulation = abap_true OR rs_outcome-candidates = 0.
      RETURN.
    ENDIF.

    rs_outcome-removed = mo_commitment->purge_before( iv_before = iv_cutoff ).
  ENDMETHOD.

ENDCLASS.
