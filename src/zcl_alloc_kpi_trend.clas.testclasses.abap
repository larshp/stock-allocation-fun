CLASS ltcl_alloc_kpi_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_kpi_trend.
    DATA mt_ser TYPE zcl_alloc_kpi_trend=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series FOR TESTING.
    METHODS rising       FOR TESTING.
    METHODS falling      FOR TESTING.
    METHODS flat         FOR TESTING.
    METHODS single_point FOR TESTING.
    METHODS extremes     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_kpi_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_kpi_trend( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->analyze( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-direction exp = 'empty' ).
  ENDMETHOD.

  METHOD rising.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->analyze( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-first exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-last exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-delta exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-direction exp = 'up' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-average exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 3 ).
  ENDMETHOD.

  METHOD falling.
    add( iv_value = 30 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->analyze( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-delta exp = -10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-direction exp = 'down' ).
  ENDMETHOD.

  METHOD flat.
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(ls_result) = mo_cut->analyze( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-delta exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-direction exp = 'flat' ).
  ENDMETHOD.

  METHOD single_point.
    add( iv_value = 7 ).

    DATA(ls_result) = mo_cut->analyze( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-first exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-last exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-direction exp = 'flat' ).
  ENDMETHOD.

  METHOD extremes.
    add( iv_value = 5 ).
    add( iv_value = 40 ).
    add( iv_value = 15 ).

    DATA(ls_result) = mo_cut->analyze( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-minimum exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-maximum exp = 40 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-average exp = 20 ).
  ENDMETHOD.

ENDCLASS.
