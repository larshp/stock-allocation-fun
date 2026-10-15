CLASS ltcl_alloc_forecast_ses DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_ses.
    DATA mt_val TYPE zcl_alloc_forecast_ses=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS smooths_series FOR TESTING.
    METHODS clamps_alpha   FOR TESTING.
    METHODS forecasts_next FOR TESTING.
    METHODS counts_history FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_forecast_ses IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_ses( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD smooths_series.
    DATA lt_smoothed TYPE zcl_alloc_forecast_ses=>ty_values_tt.

    add( 100 ).
    add( 200 ).

    lt_smoothed = mo_cut->smooth( it_values        = mt_val
                                  iv_alpha_percent = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_smoothed ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_smoothed[ 1 ] exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_smoothed[ 2 ] exp = 150 ).
  ENDMETHOD.

  METHOD clamps_alpha.
    DATA lt_smoothed TYPE zcl_alloc_forecast_ses=>ty_values_tt.

    add( 100 ).
    add( 200 ).

    lt_smoothed = mo_cut->smooth( it_values        = mt_val
                                  iv_alpha_percent = 150 ).

    cl_abap_unit_assert=>assert_equals( act = lt_smoothed[ 2 ] exp = 200 ).
  ENDMETHOD.

  METHOD forecasts_next.
    add( 100 ).
    add( 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_value( it_values        = mt_val
                                iv_alpha_percent = 50 )
      exp = 150 ).
  ENDMETHOD.

  METHOD counts_history.
    add( 100 ).
    add( 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->history_count( mt_val ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_smoothed TYPE zcl_alloc_forecast_ses=>ty_values_tt.

    lt_smoothed = mo_cut->smooth( it_values        = mt_val
                                  iv_alpha_percent = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_smoothed ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_value( it_values        = mt_val
                                iv_alpha_percent = 50 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
