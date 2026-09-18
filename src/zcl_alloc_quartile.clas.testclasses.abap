CLASS ltcl_alloc_quartile DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_quartile.
    DATA mt_ser TYPE zcl_alloc_percentile=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series FOR TESTING.
    METHODS four_points  FOR TESTING.
    METHODS five_points  FOR TESTING.
    METHODS iqr_is_span  FOR TESTING.
    METHODS single_point FOR TESTING.
    METHODS unsorted     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_quartile IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_quartile( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-minimum exp = 0 ).
  ENDMETHOD.

  METHOD four_points.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-minimum exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-q1 exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-median exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-q3 exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-maximum exp = 40 ).
  ENDMETHOD.

  METHOD five_points.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).
    add( iv_value = 50 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-q1 exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-median exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-q3 exp = 40 ).
  ENDMETHOD.

  METHOD iqr_is_span.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-iqr exp = 20 ).
  ENDMETHOD.

  METHOD single_point.
    add( iv_value = 7 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-minimum exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-median exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-maximum exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-iqr exp = 0 ).
  ENDMETHOD.

  METHOD unsorted.
    add( iv_value = 40 ).
    add( iv_value = 10 ).
    add( iv_value = 30 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-minimum exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-maximum exp = 40 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-median exp = 20 ).
  ENDMETHOD.

ENDCLASS.
