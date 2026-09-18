CLASS ltcl_alloc_monte_carlo DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_monte_carlo.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_mean         TYPE i
        iv_spread       TYPE i
        iv_samples      TYPE i
        iv_seed         TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_monte_carlo=>ty_input.

    METHODS in_range
      IMPORTING
        iv_value     TYPE i
        iv_low       TYPE i
        iv_high      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS no_samples_empty   FOR TESTING.
    METHODS sample_count       FOR TESTING.
    METHODS honours_spread     FOR TESTING.
    METHODS clamps_at_zero     FOR TESTING.
    METHODS repeatable_by_seed FOR TESTING.
    METHODS min_max_average    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_monte_carlo IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_monte_carlo( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-mean = iv_mean.
    rs_input-spread = iv_spread.
    rs_input-samples = iv_samples.
    rs_input-seed = iv_seed.
  ENDMETHOD.

  METHOD in_range.
    IF iv_value >= iv_low AND iv_value <= iv_high.
      rv_ok = abap_true.
    ELSE.
      rv_ok = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD no_samples_empty.
    DATA(ls_input) = make_input( iv_mean = 100 iv_spread = 5
                                 iv_samples = 0 iv_seed = 1 ).
    DATA(ls_result) = mo_cut->simulate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-values ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-average exp = 0 ).
  ENDMETHOD.

  METHOD sample_count.
    DATA(ls_input) = make_input( iv_mean = 100 iv_spread = 5
                                 iv_samples = 20 iv_seed = 7 ).
    DATA(ls_result) = mo_cut->simulate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-values ) exp = 20 ).
  ENDMETHOD.

  METHOD honours_spread.
    DATA(ls_input) = make_input( iv_mean = 100 iv_spread = 5
                                 iv_samples = 50 iv_seed = 3 ).
    DATA(ls_result) = mo_cut->simulate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = in_range( iv_value = ls_result-minimum iv_low = 95 iv_high = 105 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = in_range( iv_value = ls_result-maximum iv_low = 95 iv_high = 105 )
      exp = abap_true ).

    LOOP AT ls_result-values INTO DATA(lv_value).
      cl_abap_unit_assert=>assert_equals(
        act = in_range( iv_value = lv_value iv_low = 95 iv_high = 105 )
        exp = abap_true ).
    ENDLOOP.
  ENDMETHOD.

  METHOD clamps_at_zero.
    DATA(ls_input) = make_input( iv_mean = 2 iv_spread = 500
                                 iv_samples = 30 iv_seed = 11 ).
    DATA(ls_result) = mo_cut->simulate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = in_range( iv_value = ls_result-minimum iv_low = 0 iv_high = 502 )
      exp = abap_true ).

    LOOP AT ls_result-values INTO DATA(lv_draw).
      cl_abap_unit_assert=>assert_equals(
        act = in_range( iv_value = lv_draw iv_low = 0 iv_high = 502 )
        exp = abap_true ).
    ENDLOOP.
  ENDMETHOD.

  METHOD repeatable_by_seed.
    DATA(ls_input) = make_input( iv_mean = 50 iv_spread = 10
                                 iv_samples = 10 iv_seed = 42 ).
    DATA ls_first TYPE zcl_alloc_monte_carlo=>ty_result.

    ls_first = mo_cut->simulate( ls_input ).
    DATA(ls_second) = mo_cut->simulate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_second-values[ 1 ] exp = ls_first-values[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_second-average exp = ls_first-average ).
  ENDMETHOD.

  METHOD min_max_average.
    DATA(ls_input) = make_input( iv_mean = 200 iv_spread = 20
                                 iv_samples = 25 iv_seed = 5 ).
    DATA(ls_result) = mo_cut->simulate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = in_range( iv_value = ls_result-average
                      iv_low   = ls_result-minimum
                      iv_high  = ls_result-maximum )
      exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
