CLASS ltcl_alloc_benchmark DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_benchmark.
    DATA mt_ser TYPE zcl_alloc_percentile=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series   FOR TESTING.
    METHODS benchmark_part FOR TESTING.
    METHODS behind_best    FOR TESTING.
    METHODS ahead_of_avg   FOR TESTING.
    METHODS median_middle  FOR TESTING.
    METHODS unsorted_input FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_benchmark IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_benchmark( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->compare( it_values   = mt_ser
                                       iv_measured = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-measured exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-ahead exp = abap_false ).
  ENDMETHOD.

  METHOD benchmark_part.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->compare( it_values   = mt_ser
                                       iv_measured = 25 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-best exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-median exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-average exp = 20 ).
  ENDMETHOD.

  METHOD behind_best.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->compare( it_values   = mt_ser
                                       iv_measured = 25 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-behind exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-ahead exp = abap_false ).
  ENDMETHOD.

  METHOD ahead_of_avg.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->compare( it_values   = mt_ser
                                       iv_measured = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-behind exp = -5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-ahead exp = abap_true ).
  ENDMETHOD.

  METHOD median_middle.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).
    add( iv_value = 50 ).

    DATA(ls_result) = mo_cut->compare( it_values   = mt_ser
                                       iv_measured = 30 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-median exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-average exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-ahead exp = abap_true ).
  ENDMETHOD.

  METHOD unsorted_input.
    add( iv_value = 30 ).
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->compare( it_values   = mt_ser
                                       iv_measured = 15 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-best exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-median exp = 20 ).
  ENDMETHOD.

ENDCLASS.
