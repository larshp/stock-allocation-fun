CLASS ltcl_alloc_load_test DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_load_test.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_users        TYPE i
        iv_iters        TYPE i
        iv_rows         TYPE i
        iv_ms           TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_load_test=>ty_input.

    METHODS no_users_zero      FOR TESTING.
    METHODS no_iterations_zero FOR TESTING.
    METHODS multiplies_users   FOR TESTING.
    METHODS computes_totals    FOR TESTING.
    METHODS seconds_truncated  FOR TESTING.
    METHODS zero_rows_zero_ms  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_load_test IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_load_test( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-virtual_users = iv_users.
    rs_input-iterations = iv_iters.
    rs_input-rows_per_iteration = iv_rows.
    rs_input-ms_per_row = iv_ms.
  ENDMETHOD.

  METHOD no_users_zero.
    DATA(ls_input) = make_input( iv_users = 0 iv_iters = 5 iv_rows = 10 iv_ms = 1 ).
    DATA(ls_plan) = mo_cut->plan( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-total_operations exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-total_rows exp = 0 ).
  ENDMETHOD.

  METHOD no_iterations_zero.
    DATA(ls_input) = make_input( iv_users = 4 iv_iters = 0 iv_rows = 10 iv_ms = 1 ).
    DATA(ls_plan) = mo_cut->plan( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-total_operations exp = 0 ).
  ENDMETHOD.

  METHOD multiplies_users.
    DATA(ls_input) = make_input( iv_users = 4 iv_iters = 5 iv_rows = 3 iv_ms = 2 ).
    DATA(ls_plan) = mo_cut->plan( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-total_operations exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-total_rows exp = 60 ).
  ENDMETHOD.

  METHOD computes_totals.
    DATA(ls_input) = make_input( iv_users = 4 iv_iters = 5 iv_rows = 3 iv_ms = 2 ).
    DATA(ls_plan) = mo_cut->plan( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-estimated_ms exp = 120 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-estimated_seconds exp = 0 ).
  ENDMETHOD.

  METHOD seconds_truncated.
    DATA(ls_input) = make_input( iv_users = 1 iv_iters = 1 iv_rows = 1 iv_ms = 2500 ).
    DATA(ls_plan) = mo_cut->plan( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-estimated_ms exp = 2500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-estimated_seconds exp = 2 ).
  ENDMETHOD.

  METHOD zero_rows_zero_ms.
    DATA(ls_input) = make_input( iv_users = 2 iv_iters = 3 iv_rows = 0 iv_ms = 0 ).
    DATA(ls_plan) = mo_cut->plan( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-total_operations exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-total_rows exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-estimated_ms exp = 0 ).
  ENDMETHOD.

ENDCLASS.
