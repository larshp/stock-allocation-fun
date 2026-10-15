CLASS ltcl_alloc_forecast_wma DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_wma.
    DATA mt_per TYPE zcl_alloc_forecast_wma=>ty_period_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value  TYPE i
        iv_weight TYPE i.

    METHODS forecasts        FOR TESTING.
    METHODS sums_weights     FOR TESTING.
    METHODS counts_periods   FOR TESTING.
    METHODS empty_input      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_forecast_wma IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_wma( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_period TYPE zcl_alloc_forecast_wma=>ty_period.

    ls_period-value = iv_value.
    ls_period-weight = iv_weight.
    APPEND ls_period TO mt_per.
  ENDMETHOD.

  METHOD forecasts.
    add( iv_value = 10 iv_weight = 1 ).
    add( iv_value = 20 iv_weight = 2 ).
    add( iv_value = 30 iv_weight = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->forecast( mt_per ) exp = 23 ).
  ENDMETHOD.

  METHOD sums_weights.
    add( iv_value = 10 iv_weight = 1 ).
    add( iv_value = 20 iv_weight = 2 ).
    add( iv_value = 30 iv_weight = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weight_sum( mt_per ) exp = 6 ).
  ENDMETHOD.

  METHOD counts_periods.
    add( iv_value = 10 iv_weight = 1 ).
    add( iv_value = 0 iv_weight = 3 ).
    add( iv_value = 30 iv_weight = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->periods( mt_per ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->forecast( mt_per ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weight_sum( mt_per ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
