CLASS ltcl_alloc_bdc_run DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bdc_run.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_session    TYPE c
        it_rows       TYPE zcl_alloc_bdc_build=>ty_row_tt
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bdc_run=>ty_input.

    METHODS creates_session FOR TESTING.
    METHODS rejects_session FOR TESTING.
    METHODS rejects_empty_rows FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bdc_run IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bdc_run( ).
  ENDMETHOD.

  METHOD input.
    rs_row-session = iv_session.
    rs_row-rows = it_rows.
  ENDMETHOD.

  METHOD creates_session.
    DATA lt_rows TYPE zcl_alloc_bdc_build=>ty_row_tt.
    DATA ls_row  TYPE zcl_alloc_bdc_build=>ty_row.

    ls_row-program = 'SAPLZALLOC'.
    ls_row-dynpro = '0100'.
    ls_row-field = 'MATNR'.
    ls_row-value = 'MAT-1'.
    APPEND ls_row TO lt_rows.

    DATA(rs_result) = mo_cut->run( input( iv_session = 'ZALLOC_1'
                                          it_rows    = lt_rows ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-created
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-row_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Session created' ).
  ENDMETHOD.

  METHOD rejects_session.
    DATA lt_rows TYPE zcl_alloc_bdc_build=>ty_row_tt.
    DATA ls_row  TYPE zcl_alloc_bdc_build=>ty_row.

    ls_row-field = 'MATNR'.
    ls_row-value = 'MAT-1'.
    APPEND ls_row TO lt_rows.

    DATA(rs_result) = mo_cut->run( input( iv_session = ''
                                          it_rows    = lt_rows ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-created
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD rejects_empty_rows.
    DATA lt_rows TYPE zcl_alloc_bdc_build=>ty_row_tt.

    DATA(rs_result) = mo_cut->run( input( iv_session = 'ZALLOC_1'
                                          it_rows    = lt_rows ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Nothing to run' ).
  ENDMETHOD.

ENDCLASS.
