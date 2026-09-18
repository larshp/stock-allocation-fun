CLASS ltcl_alloc_exp_smooth DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_exp_smooth.
    DATA mt_ser  TYPE zcl_alloc_exp_smooth=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series     FOR TESTING.
    METHODS full_weight      FOR TESTING.
    METHODS zero_weight      FOR TESTING.
    METHODS half_weight      FOR TESTING.
    METHODS single_value     FOR TESTING.
    METHODS alpha_clamped_up FOR TESTING.
    METHODS alpha_clamped_dn FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_exp_smooth IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_exp_smooth( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-smoothed ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 0 ).
  ENDMETHOD.

  METHOD full_weight.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-smoothed ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-smoothed[ 3 ] exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 30 ).
  ENDMETHOD.

  METHOD zero_weight.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-smoothed[ 2 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 10 ).
  ENDMETHOD.

  METHOD half_weight.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-smoothed[ 1 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-smoothed[ 2 ] exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 15 ).
  ENDMETHOD.

  METHOD single_value.
    add( iv_value = 42 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-smoothed ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 42 ).
  ENDMETHOD.

  METHOD alpha_clamped_up.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 150 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 20 ).
  ENDMETHOD.

  METHOD alpha_clamped_dn.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = -10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 10 ).
  ENDMETHOD.

ENDCLASS.
