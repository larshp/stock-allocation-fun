CLASS ltcl_alloc_bias DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bias.
    DATA mt_fc  TYPE zcl_alloc_mad=>ty_series_tt.
    DATA mt_ac  TYPE zcl_alloc_mad=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_forecast TYPE menge_d
        iv_actual   TYPE menge_d.

    METHODS zero_bias          FOR TESTING.
    METHODS over_forecast      FOR TESTING.
    METHODS under_forecast     FOR TESTING.
    METHODS signs_cancel       FOR TESTING.
    METHODS errors_listed      FOR TESTING.
    METHODS empty_zero         FOR TESTING.
    METHODS shorter_wins       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bias IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bias( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_forecast TO mt_fc.
    APPEND iv_actual TO mt_ac.
  ENDMETHOD.

  METHOD zero_bias.
    add( iv_forecast = 12 iv_actual = 10 ).
    add( iv_forecast = 18 iv_actual = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( it_forecast = mt_fc it_actual = mt_ac )
      exp = 'unbiased' ).
  ENDMETHOD.

  METHOD over_forecast.
    add( iv_forecast = 15 iv_actual = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( it_forecast = mt_fc it_actual = mt_ac )
      exp = 'over' ).
  ENDMETHOD.

  METHOD under_forecast.
    add( iv_forecast = 4 iv_actual = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = -6 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( it_forecast = mt_fc it_actual = mt_ac )
      exp = 'under' ).
  ENDMETHOD.

  METHOD signs_cancel.
    add( iv_forecast = 20 iv_actual = 10 ).
    add( iv_forecast = 0 iv_actual = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 0 ).
  ENDMETHOD.

  METHOD errors_listed.
    add( iv_forecast = 20 iv_actual = 10 ).
    add( iv_forecast = 10 iv_actual = 30 ).

    DATA(lt_errors) = mo_cut->errors_of( it_forecast = mt_fc
                                         it_actual   = mt_ac ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_errors ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_errors[ 1 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_errors[ 2 ] exp = -20 ).
  ENDMETHOD.

  METHOD empty_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( it_forecast = mt_fc it_actual = mt_ac )
      exp = 'unbiased' ).
  ENDMETHOD.

  METHOD shorter_wins.
    add( iv_forecast = 10 iv_actual = 10 ).
    APPEND 99 TO mt_fc.

    DATA(lt_errors) = mo_cut->errors_of( it_forecast = mt_fc
                                         it_actual   = mt_ac ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_errors ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
