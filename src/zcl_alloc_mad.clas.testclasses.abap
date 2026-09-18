CLASS ltcl_alloc_mad DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mad.
    DATA mt_fc  TYPE zcl_alloc_mad=>ty_series_tt.
    DATA mt_ac  TYPE zcl_alloc_mad=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_forecast TYPE menge_d
        iv_actual   TYPE menge_d.

    METHODS identical_zero  FOR TESTING.
    METHODS averages_errors FOR TESTING.
    METHODS truncates_mean  FOR TESTING.
    METHODS shorter_wins    FOR TESTING.
    METHODS empty_zero      FOR TESTING.
    METHODS errors_reported FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mad IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mad( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_forecast TO mt_fc.
    APPEND iv_actual TO mt_ac.
  ENDMETHOD.

  METHOD identical_zero.
    add( iv_forecast = 10 iv_actual = 10 ).
    add( iv_forecast = 20 iv_actual = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 0 ).
  ENDMETHOD.

  METHOD averages_errors.
    add( iv_forecast = 10 iv_actual = 12 ).
    add( iv_forecast = 20 iv_actual = 16 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 3 ).
  ENDMETHOD.

  METHOD truncates_mean.
    add( iv_forecast = 10 iv_actual = 12 ).
    add( iv_forecast = 20 iv_actual = 18 ).
    add( iv_forecast = 30 iv_actual = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 1 ).
  ENDMETHOD.

  METHOD shorter_wins.
    add( iv_forecast = 10 iv_actual = 20 ).
    add( iv_forecast = 10 iv_actual = 20 ).
    APPEND 99 TO mt_fc.

    DATA(lt_errors) = mo_cut->deviation_of( it_forecast = mt_fc
                                            it_actual   = mt_ac ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_errors ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 10 ).
  ENDMETHOD.

  METHOD empty_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_forecast = mt_fc it_actual = mt_ac )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->deviation_of( it_forecast = mt_fc
                                         it_actual   = mt_ac ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD errors_reported.
    add( iv_forecast = 10 iv_actual = 12 ).
    add( iv_forecast = 20 iv_actual = 14 ).

    DATA(lt_errors) = mo_cut->deviation_of( it_forecast = mt_fc
                                            it_actual   = mt_ac ).

    cl_abap_unit_assert=>assert_equals( act = lt_errors[ 1 ] exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_errors[ 2 ] exp = 6 ).
  ENDMETHOD.

ENDCLASS.
