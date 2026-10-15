CLASS ltcl_alloc_forecast_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_trend.
    DATA mt_val TYPE zcl_alloc_forecast_trend=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS rising_sign     FOR TESTING.
    METHODS falling_sign    FOR TESTING.
    METHODS projects_values FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_forecast_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_trend( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD rising_sign.
    add( 10 ).
    add( 20 ).
    add( 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slope_sign( mt_val ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( mt_val ) exp = abap_true ).
  ENDMETHOD.

  METHOD falling_sign.
    add( 30 ).
    add( 20 ).
    add( 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slope_sign( mt_val ) exp = -1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( mt_val ) exp = abap_false ).
  ENDMETHOD.

  METHOD projects_values.
    add( 10 ).
    add( 20 ).
    add( 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->project( it_values = mt_val iv_periods = 2 )
      exp = 50 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slope_sign( mt_val ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->project( it_values = mt_val iv_periods = 2 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
