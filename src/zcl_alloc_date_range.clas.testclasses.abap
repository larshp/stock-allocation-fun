CLASS ltcl_alloc_date_range DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_date_range.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_from       TYPE d
        iv_to         TYPE d
        iv_chunk      TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_date_range=>ty_input.

    METHODS uneven_chunks  FOR TESTING.
    METHODS exact_chunks   FOR TESTING.
    METHODS single_day     FOR TESTING.
    METHODS zero_chunk     FOR TESTING.
    METHODS empty_range    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_date_range IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_date_range( ).
  ENDMETHOD.

  METHOD input.
    rs_row-from_date = iv_from.
    rs_row-to_date = iv_to.
    rs_row-chunk_days = iv_chunk.
  ENDMETHOD.

  METHOD uneven_chunks.
    DATA(lt_lines) = mo_cut->split( input( iv_from  = '20260101'
                                           iv_to    = '20260110'
                                           iv_chunk = 3 ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-to_date
                                        exp = '20260103' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 4 ]-from_date
                                        exp = '20260110' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 4 ]-to_date
                                        exp = '20260110' ).
  ENDMETHOD.

  METHOD exact_chunks.
    DATA(lt_lines) = mo_cut->split( input( iv_from  = '20260101'
                                           iv_to    = '20260106'
                                           iv_chunk = 3 ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-to_date
                                        exp = '20260106' ).
  ENDMETHOD.

  METHOD single_day.
    DATA(lt_lines) = mo_cut->split( input( iv_from  = '20260101'
                                           iv_to    = '20260101'
                                           iv_chunk = 5 ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-from_date
                                        exp = '20260101' ).
  ENDMETHOD.

  METHOD zero_chunk.
    DATA(lt_lines) = mo_cut->split( input( iv_from  = '20260101'
                                           iv_to    = '20260105'
                                           iv_chunk = 0 ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-to_date
                                        exp = '20260105' ).
  ENDMETHOD.

  METHOD empty_range.
    DATA(lt_lines) = mo_cut->split( input( iv_from  = '20260110'
                                           iv_to    = '20260101'
                                           iv_chunk = 3 ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_lines ).
  ENDMETHOD.

ENDCLASS.
