CLASS ltcl_alloc_forecast_exc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_exc.
    DATA mt_fc  TYPE zcl_alloc_mad=>ty_series_tt.
    DATA mt_ac  TYPE zcl_alloc_mad=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_forecast TYPE menge_d
        iv_actual   TYPE menge_d.

    METHODS exact_match_skipped FOR TESTING.
    METHODS flags_large_error   FOR TESTING.
    METHODS respects_threshold  FOR TESTING.
    METHODS skips_zero_actual   FOR TESTING.
    METHODS reports_position    FOR TESTING.
    METHODS empty_list          FOR TESTING.
    METHODS shorter_wins        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_forecast_exc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_exc( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_forecast TO mt_fc.
    APPEND iv_actual TO mt_ac.
  ENDMETHOD.

  METHOD exact_match_skipped.
    add( iv_forecast = 10 iv_actual = 10 ).

    DATA(lt_list) = mo_cut->find( it_forecast  = mt_fc
                                  it_actual    = mt_ac
                                  iv_threshold = 20 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_list ) exp = 0 ).
  ENDMETHOD.

  METHOD flags_large_error.
    add( iv_forecast = 10 iv_actual = 20 ).

    DATA(lt_list) = mo_cut->find( it_forecast  = mt_fc
                                  it_actual    = mt_ac
                                  iv_threshold = 20 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_list ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_list[ 1 ]-deviation exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_list[ 1 ]-actual exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_list[ 1 ]-forecast exp = 10 ).
  ENDMETHOD.

  METHOD respects_threshold.
    add( iv_forecast = 10 iv_actual = 8 ).

    DATA(lt_list) = mo_cut->find( it_forecast  = mt_fc
                                  it_actual    = mt_ac
                                  iv_threshold = 25 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_list ) exp = 0 ).
  ENDMETHOD.

  METHOD skips_zero_actual.
    add( iv_forecast = 100 iv_actual = 0 ).

    DATA(lt_list) = mo_cut->find( it_forecast  = mt_fc
                                  it_actual    = mt_ac
                                  iv_threshold = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_list ) exp = 0 ).
  ENDMETHOD.

  METHOD reports_position.
    add( iv_forecast = 10 iv_actual = 10 ).
    add( iv_forecast = 10 iv_actual = 20 ).
    add( iv_forecast = 10 iv_actual = 30 ).

    DATA(lt_list) = mo_cut->find( it_forecast  = mt_fc
                                  it_actual    = mt_ac
                                  iv_threshold = 20 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_list ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_list[ 1 ]-position exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_list[ 2 ]-position exp = 3 ).
  ENDMETHOD.

  METHOD empty_list.
    DATA(lt_list) = mo_cut->find( it_forecast  = mt_fc
                                  it_actual    = mt_ac
                                  iv_threshold = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_list ) exp = 0 ).
  ENDMETHOD.

  METHOD shorter_wins.
    add( iv_forecast = 10 iv_actual = 20 ).
    APPEND 100 TO mt_fc.

    DATA(lt_list) = mo_cut->find( it_forecast  = mt_fc
                                  it_actual    = mt_ac
                                  iv_threshold = 20 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_list ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
