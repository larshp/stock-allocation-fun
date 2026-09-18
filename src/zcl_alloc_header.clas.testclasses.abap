CLASS ltcl_alloc_header DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_header.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_title        TYPE string
        iv_subtitle     TYPE string
        iv_user         TYPE string
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_header=>ty_input.

    METHODS empty_input      FOR TESTING.
    METHODS title_only       FOR TESTING.
    METHODS all_lines        FOR TESTING.
    METHODS rule_has_width   FOR TESTING.
    METHODS rule_zero_width  FOR TESTING.
    METHODS rule_is_clamped  FOR TESTING.
    METHODS date_is_passed_on FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_header IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_header( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-title = iv_title.
    rs_input-subtitle = iv_subtitle.
    rs_input-user_id = iv_user.
  ENDMETHOD.

  METHOD empty_input.
    DATA(ls_input) = make_input( iv_title = '' iv_subtitle = '' iv_user = '' ).
    DATA(ls_result) = mo_cut->build( is_input = ls_input iv_width = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rule exp = '-----' ).
  ENDMETHOD.

  METHOD title_only.
    DATA(ls_input) = make_input( iv_title = 'Stock Allocation'
                                 iv_subtitle = '' iv_user = '' ).
    DATA(ls_result) = mo_cut->build( is_input = ls_input iv_width = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 1 ] exp = 'Stock Allocation' ).
  ENDMETHOD.

  METHOD all_lines.
    DATA(ls_input) = make_input( iv_title    = 'Stock Allocation'
                                 iv_subtitle = 'Plant 1000'
                                 iv_user     = 'LARS' ).
    DATA(ls_result) = mo_cut->build( is_input = ls_input iv_width = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 2 ] exp = 'Plant 1000' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 3 ] exp = 'User: LARS' ).
  ENDMETHOD.

  METHOD rule_has_width.
    DATA(ls_input) = make_input( iv_title = 'T' iv_subtitle = '' iv_user = '' ).
    DATA(ls_result) = mo_cut->build( is_input = ls_input iv_width = 8 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-rule exp = '--------' ).
  ENDMETHOD.

  METHOD rule_zero_width.
    DATA(ls_input) = make_input( iv_title = 'T' iv_subtitle = '' iv_user = '' ).
    DATA(ls_result) = mo_cut->build( is_input = ls_input iv_width = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-rule exp = '' ).
  ENDMETHOD.

  METHOD rule_is_clamped.
    DATA(ls_input) = make_input( iv_title = 'T' iv_subtitle = '' iv_user = '' ).
    DATA(ls_big) = mo_cut->build( is_input = ls_input iv_width = 999 ).
    DATA(ls_max) = mo_cut->build( is_input = ls_input iv_width = 200 ).

    cl_abap_unit_assert=>assert_equals( act = ls_big-rule exp = ls_max-rule ).
  ENDMETHOD.

  METHOD date_is_passed_on.
    DATA(ls_input) = make_input( iv_title = 'T' iv_subtitle = '' iv_user = '' ).
    ls_input-run_date = '20260918'.

    DATA(ls_result) = mo_cut->build( is_input = ls_input iv_width = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-run_date exp = '20260918' ).
  ENDMETHOD.

ENDCLASS.
