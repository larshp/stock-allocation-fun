CLASS ltcl_alloc_croston DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_croston.
    DATA mt_ser TYPE zcl_alloc_croston=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series      FOR TESTING.
    METHODS all_zero_series   FOR TESTING.
    METHODS single_demand     FOR TESTING.
    METHODS full_weight       FOR TESTING.
    METHODS half_weight       FOR TESTING.
    METHODS zero_weight_keeps FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_croston IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_croston( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-interval exp = 0 ).
  ENDMETHOD.

  METHOD all_zero_series.
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 0 ).
  ENDMETHOD.

  METHOD single_demand.
    add( iv_value = 0 ).
    add( iv_value = 5 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-size exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-interval exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 2 ).
  ENDMETHOD.

  METHOD full_weight.
    add( iv_value = 0 ).
    add( iv_value = 10 ).
    add( iv_value = 0 ).
    add( iv_value = 0 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-size exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-interval exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 6 ).
  ENDMETHOD.

  METHOD half_weight.
    add( iv_value = 0 ).
    add( iv_value = 10 ).
    add( iv_value = 0 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-size exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-interval exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 7 ).
  ENDMETHOD.

  METHOD zero_weight_keeps.
    add( iv_value = 0 ).
    add( iv_value = 10 ).
    add( iv_value = 0 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->forecast( it_series = mt_ser
                                        iv_alpha  = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-size exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-interval exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-forecast exp = 5 ).
  ENDMETHOD.

ENDCLASS.
