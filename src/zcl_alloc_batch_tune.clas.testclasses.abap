CLASS ltcl_alloc_batch_tune DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_batch_tune.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_rows         TYPE i
        iv_rate         TYPE i
        iv_secs         TYPE i
        iv_min          TYPE i
        iv_max          TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_batch_tune=>ty_input.

    METHODS empty_input_zero   FOR TESTING.
    METHODS uses_rate_target   FOR TESTING.
    METHODS defaults_to_total  FOR TESTING.
    METHODS clamps_to_max      FOR TESTING.
    METHODS raises_to_min      FOR TESTING.
    METHODS min_above_total    FOR TESTING.
    METHODS exact_division     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_batch_tune IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_batch_tune( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-total_rows = iv_rows.
    rs_input-rows_per_second = iv_rate.
    rs_input-target_seconds = iv_secs.
    rs_input-min_batch = iv_min.
    rs_input-max_batch = iv_max.
  ENDMETHOD.

  METHOD empty_input_zero.
    DATA(ls_input) = make_input( iv_rows = 0 iv_rate = 10 iv_secs = 1
                                 iv_min = 0 iv_max = 0 ).
    DATA(ls_plan) = mo_cut->tune( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_size exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_count exp = 0 ).
  ENDMETHOD.

  METHOD uses_rate_target.
    DATA(ls_input) = make_input( iv_rows = 1000 iv_rate = 200 iv_secs = 1
                                 iv_min = 0 iv_max = 0 ).
    DATA(ls_plan) = mo_cut->tune( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_size exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_count exp = 5 ).
  ENDMETHOD.

  METHOD defaults_to_total.
    DATA(ls_input) = make_input( iv_rows = 700 iv_rate = 0 iv_secs = 0
                                 iv_min = 0 iv_max = 0 ).
    DATA(ls_plan) = mo_cut->tune( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_size exp = 700 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_count exp = 1 ).
  ENDMETHOD.

  METHOD clamps_to_max.
    DATA(ls_input) = make_input( iv_rows = 1000 iv_rate = 500 iv_secs = 1
                                 iv_min = 0 iv_max = 100 ).
    DATA(ls_plan) = mo_cut->tune( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_size exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_count exp = 10 ).
  ENDMETHOD.

  METHOD raises_to_min.
    DATA(ls_input) = make_input( iv_rows = 1000 iv_rate = 10 iv_secs = 1
                                 iv_min = 400 iv_max = 0 ).
    DATA(ls_plan) = mo_cut->tune( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_size exp = 400 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_count exp = 3 ).
  ENDMETHOD.

  METHOD min_above_total.
    DATA(ls_input) = make_input( iv_rows = 50 iv_rate = 0 iv_secs = 0
                                 iv_min = 500 iv_max = 0 ).
    DATA(ls_plan) = mo_cut->tune( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_size exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_count exp = 1 ).
  ENDMETHOD.

  METHOD exact_division.
    DATA(ls_input) = make_input( iv_rows = 900 iv_rate = 300 iv_secs = 1
                                 iv_min = 0 iv_max = 0 ).
    DATA(ls_plan) = mo_cut->tune( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-batch_count exp = 3 ).
  ENDMETHOD.

ENDCLASS.
