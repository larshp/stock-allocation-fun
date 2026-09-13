CLASS ltcl_alloc_error DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_error.

    METHODS setup.

    METHODS error
      IMPORTING
        iv_code       TYPE c
        iv_text       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_error=>ty_error.

    METHODS input
      IMPORTING
        it_errors     TYPE zcl_alloc_error=>ty_error_tt
        is_error      TYPE zcl_alloc_error=>ty_error
        iv_text       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_error=>ty_input.

    METHODS raises_error   FOR TESTING.
    METHODS skips_empty    FOR TESTING.
    METHODS keeps_previous FOR TESTING.
    METHODS detects_any    FOR TESTING.
    METHODS detects_none   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_error IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_error( ).
  ENDMETHOD.

  METHOD error.
    rs_row-code = iv_code.
    rs_row-text = iv_text.
  ENDMETHOD.

  METHOD input.
    rs_row-errors = it_errors.
    rs_row-error = is_error.
    rs_row-text = iv_text.
  ENDMETHOD.

  METHOD raises_error.
    DATA lt_errors TYPE zcl_alloc_error=>ty_error_tt.

    DATA(lt_new) = mo_cut->raise(
      input( it_errors = lt_errors
             is_error  = error( iv_code = 'Z001' iv_text = 'Missing stock' )
             iv_text   = 'Missing stock' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-code exp = 'Z001' ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_errors TYPE zcl_alloc_error=>ty_error_tt.

    DATA(lt_new) = mo_cut->raise(
      input( it_errors = lt_errors
             is_error  = error( iv_code = 'Z001' iv_text = '' )
             iv_text   = '' ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_new ).
  ENDMETHOD.

  METHOD keeps_previous.
    DATA lt_errors TYPE zcl_alloc_error=>ty_error_tt.

    DATA(lt_first) = mo_cut->raise(
      input( it_errors = lt_errors
             is_error  = error( iv_code = 'Z001' iv_text = 'First' )
             iv_text   = 'First' ) ).

    DATA(lt_second) = mo_cut->raise(
      input( it_errors = lt_first
             is_error  = error( iv_code = 'Z002' iv_text = 'Second' )
             iv_text   = 'Second' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_second ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_second[ 2 ]-code exp = 'Z002' ).
  ENDMETHOD.

  METHOD detects_any.
    DATA lt_errors TYPE zcl_alloc_error=>ty_error_tt.

    APPEND error( iv_code = 'Z001' iv_text = 'First' ) TO lt_errors.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->has_any( lt_errors )
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD detects_none.
    DATA lt_errors TYPE zcl_alloc_error=>ty_error_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->has_any( lt_errors )
                                        exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
