CLASS ltcl_alloc_cv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cv.
    DATA mt_ser TYPE zcl_alloc_stddev=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series   FOR TESTING.
    METHODS four_points    FOR TESTING.
    METHODS no_spread_zero FOR TESTING.
    METHODS zero_mean      FOR TESTING.
    METHODS parts_reported FOR TESTING.
    METHODS bands          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cv( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-cv_x10000 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mean_x100 exp = 0 ).
  ENDMETHOD.

  METHOD four_points.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 1118 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mean_x100 exp = 2500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv_x10000 exp = 4472 ).
  ENDMETHOD.

  METHOD no_spread_zero.
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv_x10000 exp = 0 ).
  ENDMETHOD.

  METHOD zero_mean.
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-mean_x100 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv_x10000 exp = 0 ).
  ENDMETHOD.

  METHOD parts_reported.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mean_x100 exp = 1500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv_x10000 exp = 3333 ).
  ENDMETHOD.

  METHOD bands.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->band_of( 500 ) exp = 'low' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->band_of( 1000 ) exp = 'moderate' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->band_of( 2499 ) exp = 'moderate' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->band_of( 2500 ) exp = 'high' ).
  ENDMETHOD.

ENDCLASS.
