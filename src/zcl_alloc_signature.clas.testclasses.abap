CLASS ltcl_alloc_signature DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_signature.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_user         TYPE string
        iv_system       TYPE string
        iv_client       TYPE string
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_signature=>ty_input.

    METHODS empty_input      FOR TESTING.
    METHODS user_only        FOR TESTING.
    METHODS user_and_system  FOR TESTING.
    METHODS without_client   FOR TESTING.
    METHODS passes_date_time FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_signature IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_signature( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-user_id = iv_user.
    rs_input-system_id = iv_system.
    rs_input-client_id = iv_client.
  ENDMETHOD.

  METHOD empty_input.
    DATA(ls_input) = make_input( iv_user = '' iv_system = '' iv_client = '' ).
    DATA(ls_result) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 0 ).
  ENDMETHOD.

  METHOD user_only.
    DATA(ls_input) = make_input( iv_user = 'LARS' iv_system = ''
                                 iv_client = '' ).
    DATA(ls_result) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 1 ] exp = 'User: LARS' ).
  ENDMETHOD.

  METHOD user_and_system.
    DATA(ls_input) = make_input( iv_user = 'LARS' iv_system = 'DEV'
                                 iv_client = '100' ).
    DATA(ls_result) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 2 ] exp = 'System: DEV/100' ).
  ENDMETHOD.

  METHOD without_client.
    DATA(ls_input) = make_input( iv_user = '' iv_system = 'QAS'
                                 iv_client = '' ).
    DATA(ls_result) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 1 ] exp = 'System: QAS' ).
  ENDMETHOD.

  METHOD passes_date_time.
    DATA(ls_input) = make_input( iv_user = 'LARS' iv_system = ''
                                 iv_client = '' ).
    ls_input-run_date = '20260918'.
    ls_input-run_time = '120000'.

    DATA(ls_result) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-run_date exp = '20260918' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-run_time exp = '120000' ).
  ENDMETHOD.

ENDCLASS.
