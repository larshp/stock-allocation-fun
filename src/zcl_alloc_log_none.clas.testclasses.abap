CLASS ltcl_alloc_log_none DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zif_allocation_log.

    METHODS setup.
    METHODS a_whole_run_writes_nothing FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_log_none IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_log_none( ).
  ENDMETHOD.

  METHOD a_whole_run_writes_nothing.

    " there is nothing to assert about a log that keeps nothing, other than
    " that a run can talk to it from beginning to end without being stopped
    mo_cut->start( '1000' ).
    mo_cut->allocated(
      iv_matnr       = 'LOG-NONE-01'
      iv_run_id      = 'RUN-0000000000000001'
      iv_short_lines = 2 ).
    mo_cut->failed(
      iv_matnr  = 'LOG-NONE-02'
      iv_reason = 'something went wrong' ).
    mo_cut->save( ).

    cl_abap_unit_assert=>assert_bound(
      act = mo_cut
      msg = 'a run must be able to keep no diary without noticing' ).

  ENDMETHOD.

ENDCLASS.
