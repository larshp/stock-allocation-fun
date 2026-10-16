CLASS ltcl_alloc_mape DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mape.
    DATA mt_fc  TYPE zcl_alloc_mad=>ty_series_tt.
    DATA mt_ac  TYPE zcl_alloc_mad=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_forecast TYPE menge_d
        iv_actual   TYPE menge_d.

    METHODS perfect_zero     FOR TESTING.
    METHODS averages_percent FOR TESTING.
    METHODS skips_zero_actual FOR TESTING.
    METHODS no_valid_points  FOR TESTING.
    METHODS single_point     FOR TESTING.
    METHODS percentages_listed FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mape IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mape( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_forecast TO mt_fc.
    APPEND iv_actual TO mt_ac.
  ENDMETHOD.

  METHOD perfect_zero.
    add( iv_forecast = 10 iv_actual = 10 ).
    add( iv_forecast = 40 iv_actual = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 0 ).
  ENDMETHOD.

  METHOD averages_percent.
    add( iv_forecast = 10 iv_actual = 10 ).
    add( iv_forecast = 20 iv_actual = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 25 ).
  ENDMETHOD.

  METHOD skips_zero_actual.
    add( iv_forecast = 10 iv_actual = 0 ).
    add( iv_forecast = 11 iv_actual = 10 ).

    DATA(lt_pct) = mo_cut->percentage_of( it_forecast = mt_fc
                                           it_actual  = mt_ac ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pct ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pct[ 1 ] exp = 10 ).
  ENDMETHOD.

  METHOD no_valid_points.
    add( iv_forecast = 10 iv_actual = 0 ).
    add( iv_forecast = 20 iv_actual = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 0 ).
  ENDMETHOD.

  METHOD single_point.
    add( iv_forecast = 11 iv_actual = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 10 ).
  ENDMETHOD.

  METHOD percentages_listed.
    add( iv_forecast = 12 iv_actual = 10 ).
    add( iv_forecast = 15 iv_actual = 10 ).

    DATA(lt_pct) = mo_cut->percentage_of( it_forecast = mt_fc
                                           it_actual  = mt_ac ).

    cl_abap_unit_assert=>assert_equals( act = lt_pct[ 1 ] exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pct[ 2 ] exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 35 ).
  ENDMETHOD.

ENDCLASS.
