CLASS ltcl_alloc_seasonal DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_seasonal.
    DATA mt_ser TYPE zcl_alloc_seasonal=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series      FOR TESTING.
    METHODS zero_period       FOR TESTING.
    METHODS flat_series_all100 FOR TESTING.
    METHODS alternating_index FOR TESTING.
    METHODS period_one        FOR TESTING.
    METHODS short_series      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_seasonal IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_seasonal( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->index( it_series = mt_ser
                                     iv_period = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-index ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-overall exp = 0 ).
  ENDMETHOD.

  METHOD zero_period.
    add( iv_value = 10 ).

    DATA(ls_result) = mo_cut->index( it_series = mt_ser
                                     iv_period = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-index ) exp = 0 ).
  ENDMETHOD.

  METHOD flat_series_all100.
    add( iv_value = 5 ).
    add( iv_value = 5 ).
    add( iv_value = 5 ).
    add( iv_value = 5 ).

    DATA(ls_result) = mo_cut->index( it_series = mt_ser
                                     iv_period = 2 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-overall exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-index ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 1 ] exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 2 ] exp = 100 ).
  ENDMETHOD.

  METHOD alternating_index.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->index( it_series = mt_ser
                                     iv_period = 2 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-overall exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 1 ] exp = 66 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 2 ] exp = 133 ).
  ENDMETHOD.

  METHOD period_one.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->index( it_series = mt_ser
                                     iv_period = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-index ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 1 ] exp = 100 ).
  ENDMETHOD.

  METHOD short_series.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->index( it_series = mt_ser
                                     iv_period = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-index ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 1 ] exp = 66 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 2 ] exp = 133 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-index[ 3 ] exp = 0 ).
  ENDMETHOD.

ENDCLASS.
