CLASS ltcl_alloc_forecast_bias DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_bias.
    DATA mt_act TYPE zcl_alloc_forecast_bias=>ty_values_tt.
    DATA mt_for TYPE zcl_alloc_forecast_bias=>ty_values_tt.

    METHODS setup.

    METHODS add_actual
      IMPORTING
        iv_value TYPE i.

    METHODS add_forecast
      IMPORTING
        iv_value TYPE i.

    METHODS computes_bias FOR TESTING.
    METHODS over_rule     FOR TESTING.
    METHODS magnitude     FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_forecast_bias IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_bias( ).
  ENDMETHOD.

  METHOD add_actual.
    APPEND iv_value TO mt_act.
  ENDMETHOD.

  METHOD add_forecast.
    APPEND iv_value TO mt_for.
  ENDMETHOD.

  METHOD computes_bias.
    add_actual( 100 ).
    add_actual( 110 ).
    add_forecast( 90 ).
    add_forecast( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bias( it_actual = mt_act it_forecast = mt_for )
      exp = 20 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( 20 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( -5 ) exp = abap_false ).
  ENDMETHOD.

  METHOD magnitude.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->magnitude( -20 ) exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->magnitude( 15 ) exp = 15 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bias( it_actual = mt_act it_forecast = mt_for )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
