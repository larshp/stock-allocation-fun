CLASS ltcl_alloc_forecast_mad DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_mad.
    DATA mt_act TYPE zcl_alloc_forecast_mad=>ty_values_tt.
    DATA mt_for TYPE zcl_alloc_forecast_mad=>ty_values_tt.

    METHODS setup.

    METHODS add_actual
      IMPORTING
        iv_value TYPE i.

    METHODS add_forecast
      IMPORTING
        iv_value TYPE i.

    METHODS sums_deviation FOR TESTING.
    METHODS per_period     FOR TESTING.
    METHODS counts_pairs   FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_forecast_mad IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_mad( ).
  ENDMETHOD.

  METHOD add_actual.
    APPEND iv_value TO mt_act.
  ENDMETHOD.

  METHOD add_forecast.
    APPEND iv_value TO mt_for.
  ENDMETHOD.

  METHOD sums_deviation.
    add_actual( 100 ).
    add_actual( 110 ).
    add_forecast( 90 ).
    add_forecast( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->deviation( it_actual = mt_act it_forecast = mt_for )
      exp = 20 ).
  ENDMETHOD.

  METHOD per_period.
    add_actual( 100 ).
    add_actual( 110 ).
    add_forecast( 90 ).
    add_forecast( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_period( it_actual = mt_act it_forecast = mt_for )
      exp = 10 ).
  ENDMETHOD.

  METHOD counts_pairs.
    add_actual( 100 ).
    add_actual( 110 ).
    add_forecast( 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( it_actual = mt_act it_forecast = mt_for )
      exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->deviation( it_actual = mt_act it_forecast = mt_for )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_period( it_actual = mt_act it_forecast = mt_for )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
