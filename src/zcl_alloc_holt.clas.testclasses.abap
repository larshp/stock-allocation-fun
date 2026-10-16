CLASS ltcl_alloc_holt DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_holt.
    DATA mt_ser TYPE zcl_alloc_holt=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series  FOR TESTING.
    METHODS single_value  FOR TESTING.
    METHODS flat_series   FOR TESTING.
    METHODS rising_series FOR TESTING.
    METHODS rising_half   FOR TESTING.
    METHODS alpha_clamped FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_holt IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_holt( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50
                                        iv_beta   = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-levels ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 0 ).
  ENDMETHOD.

  METHOD single_value.
    add( iv_value = 25 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50
                                        iv_beta   = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-levels ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-levels[ 1 ] exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 25 ).
  ENDMETHOD.

  METHOD flat_series.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50
                                        iv_beta   = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-trends[ 3 ] exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 10 ).
  ENDMETHOD.

  METHOD rising_series.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 100
                                        iv_beta   = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-trends[ 2 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-trends[ 3 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 40 ).
  ENDMETHOD.

  METHOD rising_half.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50
                                        iv_beta   = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-levels[ 2 ] exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-trends[ 2 ] exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-levels[ 3 ] exp = 23 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-trends[ 3 ] exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 28 ).
  ENDMETHOD.

  METHOD alpha_clamped.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 500
                                        iv_beta   = -5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-levels[ 2 ] exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-trends[ 2 ] exp = 0 ).
  ENDMETHOD.

ENDCLASS.
